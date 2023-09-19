#include "Protheus.ch"
#include "TOTVS.ch"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define CMD_OPENWORKBOOK			1
#define CMD_CLOSEWORKBOOK			2
#define CMD_ACTIVEWORKSHEET			3
#define CMD_READCELL				4
#define CRLF chr(13) + chr(10)  
/*/{Protheus.doc} ZPECF037
Importacao de planilha de Produtos somente FOB
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	12/09/2023
@return  	NIL
@obs
@project
@history    alterar no produto existente valor e moeda FOB 
/*/
User Function ZPECF037(oDlg,_nX,nOpcao,aPergs,cCaminho)
    Local nHdl 		   := 0       //ExecInDLLOpen ('readexcel.dll')//('C:\TEMP\readexcel.dll')//('readexcel.dll')   //Esse arquivo precisa estar dentro da smartclient do usuario
    Local nBytes       := 0
    Local cBuffer	   := ''
    Local cFileOpen    := ""
    Local cDir         := Alltrim(MV_PAR01) 
     
    Private _cUser     := Substr(cUserName,1,20)
    Private _cCdUser   := RetCodUsr()
    Private _dData     := Dtoc(DATE())
    Private _cTime     := Time()
    Private cINTCSV    := ""          
    Private cExt       := ".XLSX"
    Private lRet       := .T.
    Private cCOD       := (TamSX3( "B1_COD"     )[1])
    Private cDESC      := (TamSX3( "B1_DESC"    )[1])
    Private cMSBLQL    := (TamSX3( "B1_MSBLQL"   )[1])
    Private cXVLDINM   := Date()
    Private cXDTULT    := Date()
    Private cXAUDIT    := ""
    Private cTexto     := ""
    Private aPrdInt    := {}
    Private aRetP 	   := {}
    Private _cNota     := ""
    Private _cTableName:= ""
    Private _lExtrai   := .T.
    Private _aStruLog  := {}
    Private _aErro     := {}
    Private _nPos      := 0
    Private _cLog 	   := ""
    Private _aCelulas  := {}
    Private aCab       := {}
    Private aItens     := {}
    Private aAmar      := {}
    Private nItDoc     := 0
    Private nOpca      := 0
    Private cOperacao  := ""

    // Montagem das Celulas do Cabeçalho

    AADD(_aCelulas,{'COD'       ,"B",02,'C',23,0})  //2
    AADD(_aCelulas,{'XPRCFOB'   ,"AP",2,'N',15,5})  //3
    AADD(_aCelulas,{'XMOEFOB'   ,"AQ",2,'C',01,0})  //4

    AADD(_aStruLog,{"LOG","C",280,0})
    AADD(_aStruLog,{"COD","C",023,0}) 

    _cArqTRB   := Criatrab(_aStruLog,.T.)
	_cIndice   := CriaTrab(Nil,.F.)
    _cChaveInd := "COD"

	If Select("TRB1") > 0
		dbSelectArea("TRB1")
		dbCloseArea()
        TCDelFile(_cArqTRB)
	EndIf

    dbCreate( _cArqTRB , _aStruLog , "TOPCONN" )
	dbUseArea( .T., __LocalDriver, _cArqTRB , "TRB1", .F., .F. )
    dbCreateIndex( _cArqTRB ,_cChaveInd )

    dbSelectArea( "TRB1" )
	dbSetOrder(1)
  
    If !File(AllTrim(cDir))
   	   MsgStop("[ZPECF037] - "+"Arquivo não existente! ")
	   lRet := .F.
       Return()
    Else
	   cExtAux := SubsTr(AllTrim(cDir),len(AllTrim(cDir))-4,5)     //cExt
       cFileOpen := cDir 
    Endif	

    //Nova integração ler o arquivo no formato XLSX nativo do Excel
    If UPPER(AllTrim(cExtAux)) == ".XLSX"
	   //cINTCSV := u_SV_XLS2CSV(AllTrim(cDiretorio), cExt)
	   cINTCSV := GeraVBS( cFileOpen )
	    While !File(cINTCSV)
		    MsgInfo("Falha na conversão do Arquivo .xlsx"+ Chr(13) + Chr(10) + "Verifique se há janelas abertas do MSExcel com mensagens. "+"[ZPECF037]")
		    If MsgYesNo("Deseja Tentar novamente ? "+"[ZPECF037]")
			   //cINTCSV := u_SV_XLS2CSV(AllTrim(cDiretorio), cExt)
			   cINTCSV := GeraVBS( cFileOpen )			
		    Else
			   MsgStop("Conversão do arquivo mal sucedida! Abortando... "+"[ZPECF037]")
               lRet := .F.
			   Return .F.
		    Endif
	    End
    Endif
    
// Elementos da Matriz _aCelulas
// 1o.-> Descrição do Campo
// 2o.-> Coluna da Planilha
// 3o.-> Linha da Planilha
// 4o.-> Tipo do dado a ser Gravado( Caracter,Numerico,Data)
// 5o.-> Tamanho do Dado a Ser Gravado
// 6o.-> Casas decimais do dado a ser Gravado

    // Verifica se Conseguiu efetuar a Abertura do Arquivo
    nHdl := Fopen(cINTCSV)
    If ( nHdl >= 0 )
        // Carrega o Excel e Abre o arquivo
        cBuffer := cINTCSV + Space(512)
        nBytes  := FSeek(nHdl, 0, 2)
        //nBytes  := ExeDLLRun2(nHdl, CMD_OPENWORKBOOK, @cBuffer)

        If ( nBytes < 0 )
            // Erro critico na abertura do arquivo sem msg de erro
            MsgInfo("Não foi possível abrir o arquivo :" + cINTCSV , " [ZPECF037]")
            lRet := .F.
            Return
        EndIf

        // Extrai os Dados 
        ImpFOB(cINTCSV,_aCelulas,_lExtrai)
        
        IF lRet = .F.
            FCLOSE(nHdl)
            Return()
        ENDIF

        dbSelectArea("TRB1")
        dbGotop()
        If TRB1->(!EOF())
            Processa({|| IMPEXC() },"Gerando Relatorio de Log... "+"[ZPECF037]")
        Else
            // Fecha o arquivo e remove o excel da memoria
            cBuffer := Space(512)
            ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
            ExecInDLLClose(nHdl)
        Endif
    Else
        MsgStop('Nao foi possivel abrir o arquivo. '+"[ZPECF037]")
    EndIf
    
    FCLOSE(nHdl)

    Ferase(cINTCSV)

Return()


/*/{Protheus.doc} ZPECF037
Importacao de planilha de Cadastro de Produtos FOB
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	12/09/2023
@return  	NIL
@obs        Retorna o Conteudo de Uma planilha Excel para o Protheus
@project
@history
/*/
Static Function ImpFOB(_nAqr,_cMatriz,_lExtrai)
Local _cRetorno	 := ''
Local _cNewRet   := ''
Local _cTipo	 := ''
Local _cTamanho	 := ''
Local _cDecimal	 := ''
Local _cString	 := ''
Local cSeparador := ""						// Separador do arquivo
Local cLinha     := ""                      // Linha importar do arquivo
Local aDados 	 := {}						// Array dos dados da linha do laco
Local aLog   	 := {}	
Local _nY        := 0
Local _nI        := 0
//Local _nX        := 0
//Local _nElem     := 0
Local _nPos01    := 1
Local _lExist    := .F.
Local _cQuery    := ""
Local _cQAlias   := "QSB1"
Local oModel 
Local nLinTot    := 0
Local _nItem     := 0

    IncProc()
    FT_FUSE(_nAqr)
    FT_FGOTOP()
    nLinTot := FT_FLastRec()-1      //total de linhas do arquivo
    FT_FGOTOP()
    FT_FSKIP(1)  //Linhas a saltar

    ProcRegua(nLinTot)

    Begin Transaction
    
    While !FT_FEOF() .AND. lRet = .T.
        _nItem++

        IncProc("Processando registro " + cValToChar(_nItem) + " de " + cValToChar(nLinTot) + ", aguarde.")

        cLinha  := FT_FREADLN()
        _nPos01 := AT(Chr(09),cLinha)

        cSeparador := Substr(cLinha,_nPos01,1)
        If !(cSeparador $ (";,"+Chr(09)))
            MSGINFO("Separador do arquivo invalido! "+"[ZPECF037]")
	        fErase(_nAqr+GetDbExtension())
	        fErase(cSysPath+AllTrim(_nAqr))
            lRet := .F.
            DisarmTransaction()
	        Return(.F.)
        Endif

        aDados  := Separa(cLinha,cSeparador)

        IF LEN(aDados) <> 3
            lRet := .F.
            DisarmTransaction()            
            MSGINFO("Lay-out invalido para esta importação ! Verifique o Fleg p/ somente FOB. "+"[ZPECF037]")
	        Return(.F.)   
        ENDIF

        cItens  :=    '0000'

        FOR _nY := 1 TO LEN(aDados)
            // Realiza tratamento do campo usado de acordo com o Tipo
                _cRetorno := aDados[_nY]
                _cTipo    := _aCelulas[_nY][4]
                _cTamanho := _aCelulas[_nY][5]
                _cDecimal := _aCelulas[_nY][6]
                If _cTipo == 'N' // Numerico
                    _cString   := ' '
                    _cNewRet   := ' '
                    _cString   := STRTRAN(_cRetorno, '"', '')
                    _cString   := STRTRAN(_cString, ',', '')
                    _cString   := STRTRAN(_cString, '$', '')
                    _cNewRet   := Val(_cString)
                    _cRetorno  := Round(_cNewRet,_cDecimal)
                Endif

                If _cTipo == 'C'   // .AND. _lExtrai // Caracter e extração de caracteres
 
                    _cString := ' '
                    _cNewRet := ' '
 
                    //For _nElem	 := 1 To Len(_cRetorno)
                    //    _cString := SubStr(_cRetorno,_nElem,1)
                    //    If _cString $ '#/#,#.#-'
                    //        Loop
                    //    Endif
                    //Next _nElem
                    
                    _cNewRet  := Alltrim(_cRetorno)+_cString
                    _cRetorno := FwNoAccent(_cNewRet) 

                Endif

                If _cTipo == 'C'   // Ajusta O Tamanho da variavel
                    _cRetorno := Alltrim(_cRetorno)
                    _cRetorno := _cRetorno+Space(_cTamanho-Len(_cRetorno))
                Endif
                aDados[_nY] := _cRetorno

        NEXT
        
        cCOD      := aDados[01] 
        cXPRCFOB  := aDados[02]            //Val(AllTrim( aDados[02] ) )    //39 
        cXMOEFOB  := AllTrim( Substr(aDados[03],1,1) ) //40

        IncProc("Montando dados de entrada...")

        If Empty(cCod) 
           //lRet := .F.
           Exit
        Endif

        If Select( (_cQAlias) ) > 0
			(_cQAlias)->(DbCloseArea())
		EndIf

        _lExist := .F.
        _cQuery := " "

		_cQuery := " SELECT B1_COD,B1_DESC,B1_XPRCFOB,B1_XMOEFOB,R_E_C_N_O_ RECORD"
 		_cQuery += "  FROM "+retsqlName('SB1')
		_cQuery += "  WHERE B1_FILIAL = '"+xFilial('SB1')+"'"
		_cQuery += "    AND B1_COD    = '" + Alltrim(cCod) + "'"
		_cQuery += "    AND D_E_L_E_T_=' ' "

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cQAlias, .F., .T. )

        IF !(_cQAlias)->( EOF() )
            SB1->( dbGoto( (_cQAlias)->RECORD ))     // posiciona o registro na SB1
            _lExist := .T.
        EndIf

        AADD(aPrdInt,{cCOD}) 

        DBSelectArea("SB1")
        SB1->(DBSetOrder(1))
    
        IF _lExist       //SB1->(DBSeek(xFilial("SB1")+cCod))
            nOpca := 4
            cOperacao := "Alteracao"

            IF Empty(aDados[02])
                aDados[02] := (_cQAlias)->B1_XPRCFOB
            ENDIF
            IF Empty(aDados[03])           
                aDados[03] := (_cQAlias)->B1_XMOEFOB
            ENDIF

            cXaudit := B1_XAUDIT   //(_cQAlias)->

            _cTexto := (" ZPECF037-" + cOperacao +  " Usuário: " +  _cUser + " Data: " + _dData + "-" + _cTime) 
           
            cXaudit += CHR(13) + CHR(10) + _cTexto

            _lExist := .F.

            cItens := Soma1(cItens,4)
            
            aTemp := {}

            oModel  := FwLoadModel ("MATA010")
            oModel:SetOperation(MODEL_OPERATION_UPDATE)
            oModel:Activate()
            oModel:SetValue("SB1MASTER","B1_COD"        ,AllTrim( aDados[01] ) )
            oModel:SetValue("SB1MASTER","B1_XPRCFOB"    ,aDados[02] )
            oModel:SetValue("SB1MASTER","B1_XMOEFOB"    ,AllTrim(Substring( aDados[03],1,1 )  ) )

            If oModel:VldData()
                oModel:CommitData()

                _cLog := "[ZPECF037] - Registro ALTERADO! " + cCod + "  Opcao: " + cOperacao
                GERLOG()
            
            Else
                aLog  := oModel:GetErrorMessage()
                _cLog := ""
            
                For _nI := 1 To Len(aLog)
                    If !Empty(aLog[_nI]) .AND. _nI = 6
                        _cLog += Alltrim(aLog[_nI]) + " Produto " + cCod + CRLF
                        GERLOG()
                    EndIf
                Next
            EndIf       
                
            oModel:DeActivate()
            oModel:Destroy()
            
            oModel := NIL
    
        ENDIF

        aCab := {}
        FT_FSKIP()

    END
    
    End Transaction

    FT_FUSE("TRB1")

Return()


/*/{Protheus.doc} ZPECF037
Importacao de planilha cadastro de produtos FOB
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	12/09/2023
@return  	NIL
@obs        Grava log das inconsistencias encontradas
@project
@history
/*/
Static Function GERLOG()
    dbSelectArea("TRB1")
    If !dbSeek(_cLog)
        RecLock("TRB1",.T.)
        TRB1->COD          := cCod
        TRB1->LOG          := _cLog
        TRB1->( msUnlock() )
    Endif

Return()


/*/{Protheus.doc} ZPECF037
Importacao de planilha cadastro de produtos FOB
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	12/09/2023
@return  	NIL
@obs        Imprime Log das Inconsistencias encontradas
@project
@history
/*/
Static Function IMPEXC()
    Local oReport
    Private _cQuebra := " "

    If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
        oReport := ReportDef()
        oReport:SetTotalInLine(.F.)
        oReport:PrintDialog()
    EndIf

Return()


/*/{Protheus.doc} ZPECF037
Importacao de planilha cadastro produtos FOB
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	12/09/2023
@return  	NIL
@obs        Impressão Log das Inconsistencias encontradas
@project
@history
/*/
Static Function ReportDef()
    Local oReport
    Local oSection1

    oReport := TReport():New("IMPEXC","Log",,{|oReport| PrintReport(oReport)},"Este relatorio irá imprimir Log")

    oSection1 := TRSection():New(oReport,OemToAnsi("Log"),{"TRB"})

    TRCell():New(oSection1,"LOG","TRB1","LOG","@!",280)
    //TRCell():New(oSection1,"NOTA","TRB1","NOTA",PesqPict("LOG","NOTA"),TamSX3("F1_DOC")[1],/*lPixel,{|| (TRB1)->NOTA }*/)

    oSection1:Cell("LOG")  :SetHeaderAlign("RIGHT")
    //oSection1:Cell("NOTA") :SetHeaderAlign("RIGHT")

Return oReport


/*/{Protheus.doc} ZPECF037
Importacao de planilha produtos FOB
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	12/09/2023
@return  	NIL
@obs        Processo de Impressão Log das Inconsistencias encontradas
@project
@history
/*/
Static Function PrintReport(oReport)

    Local oSection1 := oReport:Section(1)
    oSection1:SetTotalInLine(.F.)
    oSection1:SetTotalText("Total Geral  ")  // Imprime Titulo antes do Totalizador da Seção
    oReport:OnPageBreak(,.T.)

// Impressao da Primeira secao
    DbSelectArea("TRB1")
    DbGoTop()

    oReport:SetMeter(RecCount())
    oSection1:Init()
    While  !Eof()
        If oReport:Cancel()
            Exit
        EndIf
        oSection1:PrintLine()

        DbSelectArea("TRB1")
        DbSkip()
        oReport:IncMeter()
    EndDo
    oSection1:Finish()

Return


/*---------------------------------------------------------------------------------------
{Protheus.doc} GeraVBS
Conversao do XLSX para TXT Tab Delimited via VBS na maquina do usuario

@class		Nenhum
@from 		Nenhum
@param    	Nenhum
@attrib    	Nenhum
@protected  Nenhum
@author     A. Oliveira
@version    P.12
@since      12/09/2023
@return    	Nenhum
@sample   	Nenhum
@obs      	Nenhum
@project    Nenhum
@menu    	Nenhum
@history    Nenhum
---------------------------------------------------------------------------------------*/
Static Function GeraVBS(cDiretorio) 
Local cScript    := ""
Local cArquivo   := cDiretorio
Local cDrive     := ""
Local cNome      := ""
Local cExtensao  := ""

// Somente prosseguir se o arquivo ainda não estiver no formato TXT Tab Delimited:

SplitPath( cArquivo, @cDrive, @cDiretorio, @cNome, @cExtensao )

cScript += 'if WScript.Arguments.Count < 2 Then'+Chr(13)
cScript += '    WScript.Echo "Please specify the source and the destination files. Usage: ExcelToCsv <xls/xlsx source file> <csv destination file>"'+Chr(13)
cScript += '    Wscript.Quit'+Chr(13)
cScript += 'End If'+Chr(13)
cScript += ''+Chr(13)
cScript += 'txt_format = -4158'+Chr(13)
cScript += ''+Chr(13)
cScript += 'Set objFSO = CreateObject("Scripting.FileSystemObject")'+Chr(13)
cScript += ''+Chr(13)
cScript += 'src_file = objFSO.GetAbsolutePathName(Wscript.Arguments.Item(0))'+Chr(13)
cScript += 'dest_file = objFSO.GetAbsolutePathName(WScript.Arguments.Item(1))'+Chr(13)
cScript += ''+Chr(13)
cScript += 'Dim oExcel'+Chr(13)
cScript += 'Set oExcel = CreateObject("Excel.Application")'+Chr(13)
cScript += ''+Chr(13)
cScript += 'Dim oBook'+Chr(13)
cScript += 'Set oBook = oExcel.Workbooks.Open(src_file)'+Chr(13)
cScript += ''+Chr(13)
cScript += 'oBook.SaveAs dest_file, txt_format'+Chr(13)
cScript += ''+Chr(13)
cScript += 'oBook.Close False'+Chr(13)
cScript += 'oExcel.Quit'+Chr(13)

MemoWrite( cDrive+cDiretorio+"xls2txt.vbs", cScript )

cNome := StrTran(cNome," ","")

__CopyFile( cArquivo, cDrive+cDiretorio+"p_"+cNome+cExtensao )

shellExecute( "Open", cDrive+cDiretorio+"xls2txt.vbs", "p_"+cNome+cExtensao+" t_"+cNome+cExtensao, cDrive+cDiretorio, 1 )

Sleep(4000) // esperar 4 segundos para o excel ser finalizado

__CopyFile( cDrive+cDiretorio+cNome+cExtensao, cArquivo )

Ferase(cDrive+cDiretorio+"p_"+cNome+cExtensao)
Ferase(cDrive+cDiretorio+"xls2txt.vbs")

Return(cDrive+cDiretorio+"t_"+cNome+cExtensao)
