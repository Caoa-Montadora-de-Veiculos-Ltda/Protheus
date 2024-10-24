#include "Protheus.ch"
#include 'parmtype.ch'
#include "TOTVS.ch"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define CMD_OPENWORKBOOK			1
#define CMD_CLOSEWORKBOOK			2
#define CMD_ACTIVEWORKSHEET			3
#define CMD_READCELL				4
#define CRLF chr(13) + chr(10)  
/*/{Protheus.doc} ZPECF023
Importacao de planilha de Produtos
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	15/07/2022
@return  	NIL
@obs
@project
@history    Validar Inclus�o campos obrigat�rio e Altera��o o que tiver na planilha alterar no produto existente 
/*/

User Function ZPECF023()

    LOCAL oDlg
    LOCAL _nX         := 0
    LOCAL nOpcao      := 0
    Local aPergs 	  := {}
    Local cCaminho    := Space(60)
    
    Private _cUser    := Substr(cUserName,1,20)
    Private _cCdUser  := RetCodUsr()
    Private _dData    := Dtoc(DATE())
    Private _cTime    := Time()
    Private cINTCSV   := ""          
    Private cExt      := ".XLSX"
    Private lRet      := .T.
    Private cCOD      := (TamSX3( "B1_COD"     )[1])
    Private cDESC     := (TamSX3( "B1_DESC"    )[1])
    /*Private cFILIAL   := (TamSX3( "B1_FILIAL"  )[1])
    Private cTIPO     := (TamSX3( "B1_TIPO"    )[1])
    Private cCODITE   := (TamSX3( "B1_CODITE"  )[1])
    Private cUM       := (TamSX3( "B1_UM"      )[1])
    Private cLOCPAD   := (TamSX3( "B1_LOCPAD"  )[1])
    Private cGRUPO    := (TamSX3( "B1_GRUPO"   )[1])
    Private cSEGUM    := (TamSX3( "B1_SEGUM"   )[1])
    Private cXINTEG   := (TamSX3( "B1_XINTEG"  )[1])
    Private cCONV     := (TamSX3( "B1_CONV"    )[1])
    Private cTIPCONV  := (TamSX3( "B1_TIPCONV" )[1])
    Private cRASTRO   := (TamSX3( "B1_RASTRO"  )[1])
    Private cLOCREC   := (TamSX3( "B1_LOCREC"  )[1])
    Private cPOSIPI   := (TamSX3( "B1_POSIPI"  )[1])
    Private cGARANT   := (TamSX3( "B1_GARANT"  )[1])
    Private cORIGEM   := (TamSX3( "B1_ORIGEM"  )[1])
    Private cCONTA    := (TamSX3( "B1_CONTA"   )[1])
    Private cITEMCC   := (TamSX3( "B1_ITEMCC"  )[1]) 
    Private cCLVL     := (TamSX3( "B1_CLVL"    )[1])
    Private cCUSTD    := (TamSX3( "B1_CUSTD"   )[1])
    Private cPICM     := (TamSX3( "B1_PICM"    )[1])
    Private cEX_NCM   := (TamSX3( "B1_EX_NCM"  )[1])
    Private cIMPORT   := (TamSX3( "B1_IMPORT"  )[1])
    Private cGRTRIB   := (TamSX3( "B1_GRTRIB"  )[1])
    Private cIMPZFRC  := (TamSX3( "B1_IMPZFRC" )[1])
    Private cCEST     := (TamSX3( "B1_CEST"    )[1]) 
    Private cMCUSTD   := (TamSX3( "B1_MCUSTD " )[1])
    Private cQE       := (TamSX3( "B1_QE"      )[1])
    Private cPROC     := (TamSX3( "B1_PROC"    )[1])
    Private cLOJPROC  := (TamSX3( "B1_LOJPROC" )[1])
    Private cPESBRU   := (TamSX3( "B1_PESBRU"  )[1]) 
    Private cPESO     := (TamSX3( "B1_PESO"    )[1]) 
    Private cLOTVEN   := (TamSX3( "B1_LOTVEN"  )[1])
    Private cXNUMINM  := (TamSX3( "B1_XNUMINM" )[1])*/
   // Private cVM_I     := (TamSX3( "B1_VM_I"    )[1])
   // Private cVM_P     := (TamSX3( "B1_VM_P"    )[1])
    /*Private cXPRCFOB  := (TamSX3( "B1_XPRCFOB"  )[1])
    Private cXMOEFOB  := (TamSX3( "B1_XMOEFOB"  )[1])*/
    Private cMSBLQL   := (TamSX3( "B1_MSBLQL"   )[1])
    Private cXVLDINM  := Date()
    Private cXDTULT   := Date()
    Private cXAUDIT   := ""
    Private cTexto    := ""
    Private cCEME     := (TamSX3( "B5_CEME"    )[1]) 
    Private cMARPEC   := (TamSX3( "B5_MARPEC"  )[1])
    Private cPORTMS   := (TamSX3( "B5_PORTMS"  )[1])
    Private cCOMPR    := (TamSX3( "B5_COMPR"   )[1])
    Private cLARG     := (TamSX3( "B5_LARG"    )[1])
    Private cALTURA   := (TamSX3( "B5_ALTURA"  )[1])
    Private cCODLIN   := (TamSX3( "B5_CODLIN"  )[1])
    Private cCODFAM   := (TamSX3( "B5_CODFAM"  )[1])
    Private nQuant    := 0
    Private cFornece  := (TamSX3( "A5_FORNECE" )[1])
    Private cLolja    := (TamSX3( "A5_LOJA"    )[1])
    Private cCodprf   := (TamSX3( "A5_CODPRF"  )[1])
    Private cFabr     := (TamSX3( "A5_FABR"    )[1])
    Private cFaloja   := (TamSX3( "A5_FALOJA"  )[1])

    Private aPrdInt   := {}

    Private aRetP 	  := {}

    If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB

    aAdd( aPergs ,{6,"Diretorio do Arquivo ",cCaminho     ,"@!" ,     ,'.T.' ,80,.T.,"Arquivos .xls |*.xls " })
    aAdd( aPergs ,{4,"Somente FOB ?",.F.,"Marque p/atualizar apenas FOB.",90,"",.F.})
    
    If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.F.,.F.) //N�o salvar os dados por usu�rio

        DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Importa��o Cadastro de Produtos") PIXEL
        @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
        @ 29, 15 SAY OemToAnsi("Esta rotina realiza a importa��o de Planilha Excel para Gera��o de Cadastro de Produtos") SIZE 268, 8 OF oDlg PIXEL
        IF MV_PAR02 = .F.
            @ 38, 15 SAY OemToAnsi("Da Caoa Montadora conforme Lay-Out pr� definido.") SIZE 268, 8 OF oDlg PIXEL
        ELSE
            @ 38, 15 SAY OemToAnsi("Da Caoa Montadora conforme Lay-Out: C�digo, Val_FOB, MoedaFOB") SIZE 268, 8 OF oDlg PIXEL
        ENDIF
        @ 48, 15 SAY OemToAnsi("Confirma Gera��o da Documento?") SIZE 268, 8 OF oDlg PIXEL
        DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpcao:=1) ENABLE OF oDlg
        DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
        ACTIVATE MSDIALOG oDlg CENTER

        If nOpcao == 1 .AND. MV_PAR02 = .F.
            Processa ({|| FImpExcel()},"Aguarde! Efetuando Importa��o da Planilha "+"[ZPECF023]")
        ElseIf nOpcao == 1 .AND. MV_PAR02 = .T.
            Processa ({|| u_ZPECF037(oDlg,_nX,nOpcao,aPergs,cCaminho)},"Aguarde! Efetuando Importa��o da Planilha Custo FOB "+"[ZPECF037]")    //Chamar a fun��o que importa apenas o FOB
        ElseIf nOpcao == 0
            lRet := .F.
        Endif

    Endif

    IF  !MV_PAR02 .AND. lRet
        For _nX := 1 to Len(aPrdInt)
            SB1->(dbSetOrder(1))
            SB1->(dbGotop())
            SB1->(DBSeek(xFilial("SB1")+aPrdInt[_nX][1]))
            RecLock('SB1', .F.)
                SB1->B1_XINTEG := "S"
            SB1->(MsUnlock())
        NEXT

        U_ZWSR004(,.T.)
    ENDIF

    Ferase(cINTCSV)

    //LogExec()

    ENDIF

Return()


/*/{Protheus.doc} ZPECF023
Importacao de planilha de cadastro de Produtos
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	15/07/2022
@return  	NIL
@obs
@project
@history
/*/
Static Function FImpExcel()
    /*local _cTipo	   := "EX"
    Local _aArea       := GetArea()
    Local cTitulo1     := "Selecione o arquivo para Carga "
    Local cExtens      := "Arquivo CSV | *.CSV"
    Local cMainPath    := Alltrim(MV_PAR01)   //"C:\"
    */
    Local nHdl 		   := 0       //ExecInDLLOpen ('readexcel.dll')//('C:\TEMP\readexcel.dll')//('readexcel.dll')   //Esse arquivo precisa estar dentro da smartclient do usuario
    Local nBytes       := 0
    Local cBuffer	   := ''
    Local cFileOpen    := ""
    Local cDir         := Alltrim(MV_PAR01)  
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
    
// Elementos da Matriz _aCelulas
// 1o.-> Descri��o do Campo
// 2o.-> Coluna da Planilha
// 3o.-> Linha da Planilha
// 4o.-> Tipo do dado a ser Gravado( Caracter,Numerico,Data)
// 5o.-> Tamanho do Dado a Ser Gravado
// 6o.-> Casas decimais do dado a ser Gravado

// Montagem das Celulas do Cabe�alho

    AADD(_aCelulas,{'FILIAL'    ,"A",02,'C',10,0})  //1
    AADD(_aCelulas,{'COD'       ,"B",02,'C',23,0})  //2
    AADD(_aCelulas,{'DESC'      ,"C",02,'C',60,0})  //3
    AADD(_aCelulas,{'TIPO'      ,"D",02,'C',02,0})  //4
    AADD(_aCelulas,{'CODITE'    ,"E",02,'C',23,0})  //5    
    AADD(_aCelulas,{'UM'        ,"F",02,'C',02,7})  //6
    AADD(_aCelulas,{'LOCPAD'    ,"G",02,'C',02,0})  //7
    AADD(_aCelulas,{'GRUPO'     ,"H",02,'C',04,0})  //8 
    AADD(_aCelulas,{'SEGUM'     ,"I",02,'C',02,0})  //9
    AADD(_aCelulas,{'XINTEG'    ,"J",02,'C',01,0})  //10
    AADD(_aCelulas,{'CONV'      ,"L",02,'N',05,2})  //11
    AADD(_aCelulas,{'TIPCONV'   ,"M",02,'C',01,0})  //12
    AADD(_aCelulas,{'RASTRO'    ,"N",02,'C',01,0})  //13
    AADD(_aCelulas,{'LOCREC'    ,"O",02,'C',03,0})  //14
    AADD(_aCelulas,{'POSIPI'    ,"P",02,'C',10,0})  //15
    AADD(_aCelulas,{'GARANT'    ,"R",02,'C',01,0})  //16
    AADD(_aCelulas,{'ORIGEM'    ,"S",02,'C',01,0})  //17
    AADD(_aCelulas,{'CONTA'     ,"T",02,'C',20,0})  //18
    AADD(_aCelulas,{'ITEMCC'    ,"U",02,'C',11,0})  //19
    AADD(_aCelulas,{'CLVL'      ,"V",02,'C',11,0})  //20
    AADD(_aCelulas,{'CUSTD'     ,"W",02,'N',15,5})  //21
    AADD(_aCelulas,{'IMPORT'    ,"X",02,'N',01,0})  //22
    AADD(_aCelulas,{'EX_NCM'    ,"Y",02,'C',03,0})  //23
    //AADD(_aCelulas,{'IPI'       ,"Z",02,'N',05,2})  //24
    AADD(_aCelulas,{'GRTRIB'    ,"AA",02,'C',06,0})  //25
    AADD(_aCelulas,{'IMPZFRC'   ,"AB",2,'C',01,0})  //26
    AADD(_aCelulas,{'MCUSTD'    ,"AC",2,'C',01,0})  //27
    AADD(_aCelulas,{'CEST'      ,"AD",2,'C',09,0})  //28
    AADD(_aCelulas,{'QE'        ,"AE",2,'N',13,5})  //29
    AADD(_aCelulas,{'PROC'      ,"AF",2,'C',06,0})  //30
    AADD(_aCelulas,{'LOJPROC'   ,"AG",2,'C',02,0})  //31
    AADD(_aCelulas,{'PESBRU'    ,"AH",2,'N',11,4})  //32
    AADD(_aCelulas,{'PESO'      ,"AI",2,'N',11,4})  //33
    AADD(_aCelulas,{'LOTVEN'    ,"AJ",2,'N',13,3})  //34
    AADD(_aCelulas,{'XNUMINM'   ,"AK",2,'C',10,0})  //35
    AADD(_aCelulas,{'XVLDINM'   ,"AL",2,'D',08,0})  //36
    AADD(_aCelulas,{'XDTULT'    ,"AM",2,'D',08,0})  //37 
    AADD(_aCelulas,{'VM_I'      ,"AN",2,'M',36,0})  //38 
    AADD(_aCelulas,{'VM_P'      ,"AO",2,'M',36,0})  //39     
    AADD(_aCelulas,{'XPRCFOB'   ,"AP",2,'N',15,5})  //40
    AADD(_aCelulas,{'XMOEFOB'   ,"AQ",2,'C',01,0})  //41
    //AADD(_aCelulas,{'IMPORT'    ,"AR",2,'C',01,0})  //42
    AADD(_aCelulas,{'CEME'      ,"AR",2,'C',200,0})  //43
    AADD(_aCelulas,{'MARPEC'    ,"AS",2,'C',006,0})  //44
    AADD(_aCelulas,{'PORTMS'    ,"AT",2,'C',001,0})  //45
    AADD(_aCelulas,{'COMPR'     ,"AU",2,'N',009,2})  //46
    AADD(_aCelulas,{'LARG'      ,"AV",2,'N',009,2})  //47
    AADD(_aCelulas,{'ALTURA'    ,"AX",2,'N',009,2})  //48
    AADD(_aCelulas,{'CODLIN'    ,"AZ",2,'C',002,0})  //49
    AADD(_aCelulas,{'CODFAM'    ,"BA",2,'C',002,0})  //50
    AADD(_aCelulas,{'FORNECE'   ,"BB",2,'C',006,0})  //51
    AADD(_aCelulas,{'LOJA'      ,"BC",2,'C',002,0})  //52
    AADD(_aCelulas,{'CODPRF'    ,"BD",2,'C',060,0})  //53
    AADD(_aCelulas,{'FABR'      ,"BE",2,'C',006,0})  //54
    AADD(_aCelulas,{'FALOJA'    ,"BF",2,'C',002,0})  //55
    AADD(_aCelulas,{'MSBLQL'    ,"BG",2,'C',001,0})  //56

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
   	   MsgStop("[ZPECF023] - "+"Arquivo n�o existe! ")
	   lRet := .F.
       Return()
    Else
	   cExtAux := SubsTr(AllTrim(cDir),len(AllTrim(cDir))-4,5)     //cExt
       cFileOpen := cDir 
    Endif	

    //Nova integra��o ler o arquivo no formato XLSX nativo do Excel
    If UPPER(AllTrim(cExtAux)) == ".XLSX"
	   //cINTCSV := u_SV_XLS2CSV(AllTrim(cDiretorio), cExt)
	   cINTCSV := GeraVBS( cFileOpen )
	    While !File(cINTCSV)
		    MsgInfo("Falha na convers�o do Arquivo .xlsx"+ Chr(13) + Chr(10) + "Verifique se h� janelas abertas do MSExcel com mensagens. "+"[ZPECF023]")
		    If MsgYesNo("Deseja Tentar novamente ? "+"[ZPECF023]")
			   //cINTCSV := u_SV_XLS2CSV(AllTrim(cDiretorio), cExt)
			   cINTCSV := GeraVBS( cFileOpen )			
		    Else
			   MsgStop("Convers�o do arquivo mal sucedida! Abortando... "+"[ZPECF023]")
               lRet := .F.
			   Return .F.
		    Endif
	    End
    Endif

    // Verifica se Conseguiu efetuar a Abertura do Arquivo
    nHdl := Fopen(cINTCSV)
    If ( nHdl >= 0 )
        // Carrega o Excel e Abre o arquivo
        cBuffer := cINTCSV + Space(512)
        nBytes  := FSeek(nHdl, 0, 2)
        //nBytes  := ExeDLLRun2(nHdl, CMD_OPENWORKBOOK, @cBuffer)

        If ( nBytes < 0 )
            // Erro critico na abertura do arquivo sem msg de erro
            MsgInfo("N�o foi poss�vel abrir o arquivo :" + cINTCSV , " [ZPECF023]")
            lRet := .F.
            Return
        EndIf

        // Extrai os Dados 
        U_imppro(cINTCSV,_aCelulas,_lExtrai)
        
        IF lRet = .F.
            FCLOSE(nHdl)
            //Return()
        ENDIF

        dbSelectArea("TRB1")
        dbGotop()
        If TRB1->(!EOF())
            Processa({|| IMPEXC() },"Gerando Relatorio de Log... "+"[ZPECF023]")
        Else
            // Fecha o arquivo e remove o excel da memoria
            cBuffer := Space(512)
            ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
            ExecInDLLClose(nHdl)
        Endif
    Else
        MsgStop('Nao foi possivel abrir o arquivo. '+"[ZPECF023]")
    EndIf
    
    FCLOSE(nHdl)

Return()


/*/{Protheus.doc} ZPECF023
Importacao de planilha de Cadastro de Produtos
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	15/07/2022
@return  	NIL
@obs        Retorna o Conteudo de Uma planilha Excel para o Protheus
@project
@history
/*/
User Function imppro(_nAqr,_cMatriz,_lExtrai)
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
Local _nPos02    := 1
Local _nPos03    := 1
Local _lExist    := .F.
Local _cQuery    := ""
Local _cQAlias   := "QSB1"
Local _cQ        := ""
Local _cQSA5     := "QSA5"
Local oModel 
Local nLinTot    := 0
Local _nItem     := 0

    IncProc()
    FT_FUSE(_nAqr)
    FT_FGOTOP()
    nLinTot := FT_FLastRec()-1      //total de linhas do arquivo
    FT_FGOTOP()
    FT_FSKIP(1)  //Linhas a saltar

    //Begin Transaction
    
    While !FT_FEOF() .AND. lRet = .T.
        _nItem  ++

        IncProc("Processando registro " + cValToChar(_nItem) + " de " + cValToChar(nLinTot) + ", aguarde.")

        cLinha  := FT_FREADLN()
        _nPos01 := AT(Chr(09),cLinha)

        cSeparador := Substr(cLinha,_nPos01,1)
        If !(cSeparador $ (";,"+Chr(09)))
            MSGINFO("Separador do arquivo invalido! "+"[ZPECF023]")
	        fErase(_nAqr+GetDbExtension())
	        fErase(cSysPath+AllTrim(_nAqr))
            lRet := .F.
	        Return(.F.)
        Endif

        aDados  := Separa(cLinha,cSeparador)

        IF LEN(aDados) < 4
            MSGINFO("Lay-Out do arquivo invalido! Verifique o Fleg p/ somente FOB. "+"[ZPECF023]")
            lRet := .F.
            Exit 
        ENDIF

        cItens    :=    '0000'

        FOR _nY := 1 TO LEN(aDados)
            // Realiza tratamento do campo usado de acordo com o Tipo
            IF ((_nY < 5 .OR. _nY = 13) .OR. (_nY > 21 .and. _nY < 27) ) //R. _nY = 18 )
                _cRetorno := aDados[_nY]
                DO CASE
                   CASE _nY = 13
                      _nX = 5
                   CASE _nY = 22
                      _nX = 6
                   CASE _nY = 24
                      _nX = 7
                   CASE _nY = 23
                      _nX = 8
                   CASE _nY = 26
                      _nX = 9
                   CASE _nY = 25
                      _nX = 10
                   //CASE _nY = 18
                   //  _nX = 35  
                   Otherwise
                   _nX = _nY
                ENDCASE
                _cTipo    := _aCelulas[_nX][4]
                _cTamanho := _aCelulas[_nX][5]
                _cDecimal := _aCelulas[_nX][6]
                If _cTipo == 'N' // Numerico
                    _cString   := ' '
                    _cNewRet   := ' '
                    _cString   := STRTRAN(_cRetorno, '"', '')
                    _cString   := STRTRAN(_cString, ',', '')
                    _cString   := STRTRAN(_cString, '$', '')
                    _cNewRet   := Val(_cString)
                    _cRetorno  := Round(_cNewRet,_cDecimal)
                Endif

                If _cTipo == 'D' // Data 21/01/2006
                    _nPos02 := AT("/",_cRetorno)  //posi��o da primeira barra  at� aqui � o m�s  
                    _nPos03 := AT("/",_cRetorno,_nPos02+1)  //posi��o da segunda barra  at� aqui � o m�s    

                    IF _nPos02 <> 0 .AND.  _nPos03 <> 0
                    
                        _cMes := Substr(_cRetorno,1,_nPos02-1)
                        _cMes := PADL(_cMes,02,"0") 

                        _cDia := Substr(_cRetorno,_nPos02+1,2)
                        _cDia := PADL(_cDia,02,"0") 
                        
                        _cAno := Substr(_cRetorno,_nPos03+1,4)
                        _cAno := PADL(_cAno,04,"0")
                            
                        _cNewRet  := CtoD(_cDia+"/"+_cMes+"/"+_cAno)
                        _cRetorno := _cNewRet

                    ENDIF
                Endif

                If _cTipo == 'C'   // .AND. _lExtrai // Caracter e extra��o de caracteres
 
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
            ENDIF

        NEXT
        
        cCOD      := AllTrim( aDados[02] )
        cDESC     := AllTrim( aDados[04] )   //3
     /*   cFILIAL   := AllTrim( aDados[01] ) 
        cTIPO     := AllTrim( aDados[05] )   //4
        cCODITE   := AllTrim( aDados[03] )   //5
        cUM       := AllTrim( aDados[15] )   //6
        cLOCPAD   := AllTrim( aDados[21] )   //7
        cGRUPO    := AllTrim( aDados[06] )   //8
        cPICM     := Val(AllTrim( aDados[22] ) )  //9
        cPOSIPI   := AllTrim( aDados[23] )   //10
        cEX_NCM   := AllTrim( aDados[24] )   //11
        cIMPORT   := AllTrim( aDados[25] )   //11
        cGRTRIB   := AllTrim( aDados[26] )   //12
        cSEGUM    := AllTrim( aDados[30] )   //13
        cIMPZFRC  := AllTrim( aDados[27] )   //14
               
        IF !Empty(aDados[31])                //15
            cCONV := Val(AllTrim( aDados[31] ) )
        ELSE
            cCONV := 1
        ENDIF
        IF !Empty(aDados[32])                //16
            cTIPCONV := Val(AllTrim( aDados[32] ) )
        ELSE
            cTIPCONV := 'M'
        ENDIF
        cQE       := Val(AllTrim( aDados[07] ) )    //17
        cCUSTD    := Val(AllTrim( aDados[08] ) )    //18
        cMCUSTD   := AllTrim( aDados[09] )          //19
        cPESO     := Val(AllTrim( aDados[14] ) )    //20
        cCONTA    := AllTrim( aDados[35] )          //21
        cITEMCC   := AllTrim( aDados[36] )          //22
        cLOJPROC  := AllTrim( aDados[11] )          //23
        cPROC     := AllTrim( aDados[10] )          //24
        cGARANT   := AllTrim( aDados[32] )          //25
        cORIGEM   := AllTrim( aDados[12] )          //26
        cRASTRO   := AllTrim( aDados[34] )          //27
        cCLVL     := AllTrim( aDados[37] )          //28
        cPESBRU   := Val(AllTrim( aDados[13] ) )    //29
        cLOTVEN   := Val(AllTrim( aDados[16] ) )    //30
        cCEST     := AllTrim( aDados[28] )          //31
        cLOCREC   := AllTrim( aDados[29] )          //32
     */   cXNUMINM  := AllTrim( aDados[17] )          //33
        cXVLDINM  := STOD(AllTrim( aDados[18] ) )   //34
        cXDTULT   := STOD(AllTrim( aDados[38] ) )   //35
        //cXINTEG   := AllTrim( aDados[39] )          //36
        cCEME     := AllTrim( aDados[42] )          //39
        cMARPEC   := AllTrim( aDados[43] )          //40
        cPORTMS   := AllTrim( aDados[44] )          //41
        cCOMPR    := Val(AllTrim( aDados[45] ) )    //42
        cLARG     := Val(AllTrim( aDados[46] ) )    //43
        cALTURA   := Val(AllTrim( aDados[47] ) )    //44
        cCODLIN   := AllTrim( aDados[48] )          //45
        cCODFAM   := AllTrim( aDados[49] )          //46
        //cXPRCFOB  := Val(AllTrim( aDados[19] ) )    //39 
        //cXMOEFOB  := AllTrim( aDados[20] )          //40
        cFornece  := AllTrim( aDados[50] )
        cLolja    := AllTrim( aDados[51] )
        cCodprf   := AllTrim( aDados[52] )
        cFabr     := AllTrim( aDados[53] )
        cFaloja   := AllTrim( aDados[54] )
        cMSBLQL   := "2"   //N�o Bloqueado

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

		_cQuery := " SELECT B1_COD,B1_DESC,B1_TIPO,B1_UM,B1_LOCPAD,B1_GRUPO,B1_SEGUM,B1_XINTEG,B1_RASTRO,B1_LOCREC"
        _cQuery += "    ,B1_POSIPI,B1_GARANT,B1_ORIGEM,B1_CONTA,B1_ITEMCC,B1_CLVL,B1_CODITE,B1_PICM,B1_CUSTD,B1_MCUSTD"
        _cQuery += "    ,B1_QE,B1_PESBRU,B1_CONV,B1_TIPCONV,B1_EX_NCM,B1_IPI,B1_GRTRIB,B1_IMPZFRC,B1_CEST"
        _cQuery += "    ,B1_PROC,B1_LOJPROC,B1_PESBRU,B1_PESO,B1_LOTVEN,B1_XNUMINM,B1_XVLDINM,B1_IMPORT"
        _cQuery += "    ,R_E_C_N_O_ RECORD"
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
                aDados[02] := (_cQAlias)->B1_COD
            ENDIF
            IF Empty(aDados[04])           
                aDados[04] := (_cQAlias)->B1_DESC
            ENDIF
            IF Empty(aDados[05])                    
                aDados[05] := (_cQAlias)->B1_TIPO
            ENDIF
            IF Empty(aDados[15])        
                aDados[15] := (_cQAlias)->B1_UM
            ENDIF
            /*IF Empty(aDados[21])        
                aDados[21]  := (_cQAlias)->B1_LOCPAD
            ENDIF*/                                  //a pedido do Andre
            IF Empty(aDados[06])        
                aDados[06] := (_cQAlias)->B1_GRUPO
            ENDIF
            IF Empty(aDados[30])        
                aDados[30] := (_cQAlias)->B1_SEGUM
            ENDIF
            IF Empty(aDados[39])        
                aDados[39] := (_cQAlias)->B1_XINTEG
            ENDIF
            IF Empty(aDados[34])        
                aDados[34] := (_cQAlias)->B1_RASTRO
            ENDIF
            /*IF Empty(aDados[29])        
                aDados[29] := (_cQAlias)->B1_LOCREC  //a pedido do Andre
            ENDIF*/
            IF Empty(aDados[23])        
                aDados[23] := (_cQAlias)->B1_POSIPI
            ENDIF
            IF Empty(aDados[33])        
                aDados[33] := (_cQAlias)->B1_GARANT
            ENDIF
            IF Empty(aDados[12])        
                aDados[12] := (_cQAlias)->B1_ORIGEM
            ENDIF
            IF Empty(aDados[35])        
                aDados[35] := (_cQAlias)->B1_CONTA
            ENDIF
            IF Empty(aDados[36])        
                aDados[36] := (_cQAlias)->B1_ITEMCC
            ENDIF
            IF Empty(aDados[37])        
                aDados[37] := (_cQAlias)->B1_CLVL
            ENDIF
            IF Empty(aDados[03])        
                aDados[03] := (_cQAlias)->B1_CODITE
            ENDIF
            IF Empty(aDados[22]) 
                aDados[22] := (_cQAlias)->B1_PICM
            ENDIF
            IF Empty(aDados[08]) 
                aDados[08] := (_cQAlias)->B1_CUSTD
            ENDIF
            IF Empty(aDados[09]) 
                aDados[09] := (_cQAlias)->B1_MCUSTD
            ENDIF
            IF Empty( aDados[07]) 
                 aDados[07] := (_cQAlias)->B1_QE
            ENDIF
            IF Empty( aDados[13]) 
                 aDados[13] := (_cQAlias)->B1_PESBRU
            ENDIF
            IF Empty(aDados[31]) 
                aDados[31] := (_cQAlias)->B1_CONV
            ENDIF
            IF Empty(aDados[32])      
                aDados[32] := (_cQAlias)->B1_TIPCONV
            ENDIF
            IF Empty(aDados[24])      
                aDados[24] := (_cQAlias)->B1_EX_NCM
            ENDIF
            IF Empty(aDados[25])      
                aDados[25] := (_cQAlias)->B1_IMPORT
            ENDIF
            IF Empty(aDados[26] )      
                 aDados[26] := (_cQAlias)->B1_GRTRIB
            ENDIF
            IF Empty(aDados[27])      
                 aDados[27] := (_cQAlias)->B1_IMPZFRC
            ENDIF
            IF Empty(aDados[28])      
                aDados[28] := (_cQAlias)->B1_CEST
            ENDIF
            IF Empty(aDados[10])      
                aDados[10] := (_cQAlias)->B1_PROC
            ENDIF
            IF Empty(aDados[11])      
                aDados[11] := (_cQAlias)->B1_LOJPROC
            ENDIF
            IF Empty(aDados[13])      
                aDados[13] := (_cQAlias)->B1_PESBRU
            ENDIF
            IF Empty(aDados[14])      
                aDados[14] := (_cQAlias)->B1_PESO
            ENDIF
            IF Empty(aDados[16])      
                aDados[16] := (_cQAlias)->B1_LOTVEN
            ENDIF
            IF Empty(aDados[17])      
                aDados[17] := (_cQAlias)->B1_XNUMINM
            ENDIF
            IF Empty(aDados[18])      
                aDados[18] := (_cQAlias)->B1_XVLDINM
            ENDIF
        
            cXaudit := B1_XAUDIT   //(_cQAlias)->

            _cTexto := (" ZPECF023-" + cOperacao +  " Usu�rio: " +  _cUser + " Data: " + _dData + "-" + _cTime) 
           
            cXaudit += CHR(13) + CHR(10) + _cTexto

            aItens := { {"B5_FILIAL",xFilial("SB5")      ,Nil},;
                        {"B5_COD"   ,cCod                ,Nil},;
                        {"B5_CEME"  ,cCEME               ,NIL},; 
                        {"B5_MARPEC",cMARPEC             ,NIL},; 
                        {"B5_PORTMS",cPORTMS             ,NIL},; 
                        {"B5_COMPR" ,cCOMPR              ,NIL},; 
                        {"B5_LARG"  ,cLARG               ,NIL},; 
                        {"B5_ALTURA",cALTURA             ,NIL},; 
                        {"B5_CODLIN",cCODLIN             ,NIL},; 
                        {"B5_CODFAM",cCODFAM             ,NIL}}

            If Select( (_cQSA5) ) > 0
                (_cQSA5)->(DbCloseArea())
            EndIf

            _lExist := .F.
            _cQ := " "

            _cQ := " SELECT A5_FILIAL,A5_PRODUTO,A5_FORNECE,A5_LOJA,A5_CODPRF,A5_FABR,A5_FALOJA"
            _cQ += "  ,R_E_C_N_O_ RECORD"
            _cQ += "  FROM "+retsqlName('SA5')
            _cQ += "  WHERE A5_FILIAL  = '" + xFilial('SA5') +"'"
            _cQ += "    AND A5_FORNECE = '" + cFornece + "'"
            _cQ += "    AND A5_LOJA    = '" + cLolja + "'"
            _cQ += "    AND A5_PRODUTO = '" + Alltrim(cCod) + "'"
            _cQ += "    AND D_E_L_E_T_=' ' "

            dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQ ), _cQSA5, .F., .T. )

            IF !(_cQSA5)->( EOF() )
                SA5->( dbGoto( (_cQSA5)->RECORD ))     // posiciona o registro
                _lExist := .T.

                IF !EMPTY(aDados[52])           
                    cCodprf := AllTrim(aDados[52])
                ENDIF
                IF !EMPTY(aDados[53])           
                    cFabr := AllTrim(aDados[53])
                ENDIF
                IF !EMPTY(aDados[54])           
                    cFaloja := AllTrim(aDados[54])
                ENDIF
            ENDIF

            aAmar := { {"A5_FILIAL" ,xFilial("SA5")      ,Nil},;
                       {"A5_PRODUTO", cCod               ,NIL},;
                       {"A5_NOMPROD", cDesc              ,NIL},; 
                       {"A5_FORNECE", cFornece           ,NIL},; 
                       {"A5_LOJA"   , cLolja             ,NIL},; 
                       {"A5_CODPRF" , cCodprf            ,NIL},; 
                       {"A5_FABR"   , cFabr              ,NIL},; 
                       {"A5_FALOJA" , cFaloja            ,NIL}} 

            U_m010AltRa(aDados) //Altera��o Produto
            U_Z023Compl(cCod,nOpca,aItens) //Alterar Complemento de produto
            Z023Amar(nOpca,aAmar)

        ELSE
            nOpca := 3 
            cOperacao := "Inclusao"  
            _cTexto := (" ZPECF023-" + cOperacao +  " Usu�rio: " +  _cUser + " Data: " + _dData + "-" + _cTime)
            cXaudit +=  _cTexto    
        
            If Len(aCab) == 0

                aAdd(aCab,{"B1_FILIAL"	,xFilial("SB1") ,Nil})
                aAdd(aCab,{"B1_COD"  	,aDados[02]     ,Nil})
                aAdd(aCab,{"B1_DESC"	,aDados[04]     ,Nil})
                aAdd(aCab,{"B1_TIPO"	,aDados[05]     ,Nil})
                aAdd(aCab,{"B1_CODITE"	,aDados[03]     ,Nil})
                aAdd(aCab,{"B1_UM"	    ,aDados[15]     ,Nil})
                //aAdd(aCab,{"B1_LOCPAD"	,aDados[21]     ,Nil})  //a pedido do Andre
                aAdd(aCab,{"B1_GRUPO"	,aDados[06]		,Nil})
                aAdd(aCab,{"B1_SEGUM"	,aDados[30]     ,Nil})
                aAdd(aCab,{"B1_XINTEG"	,aDados[39]     ,Nil})
                aAdd(aCab,{"B1_CONV"	,aDados[31]     ,NIL})
                aAdd(aCab,{"B1_TIPCONV"	,aDados[32]     ,Nil})
                aAdd(aCab,{"B1_RASTRO"  ,aDados[34]     ,NIL})
                //aAdd(aCab,{"B1_LOCREC"	,aDados[29]     ,NIL})  //a pedido do Andre
                aAdd(aCab,{"B1_POSIPI"  ,aDados[23]     ,NIL})
                aAdd(aCab,{"B1_GARANT"  ,aDados[33]     ,NIL})    
                aAdd(aCab,{"B1_ORIGEM"  ,aDados[12]     ,NIL}) 
                aAdd(aCab,{"B1_CONTA"   ,aDados[35]     ,NIL})
                aAdd(aCab,{"B1_ITEMCC"  ,aDados[36]     ,NIL})
                aAdd(aCab,{"B1_CLVL"    ,aDados[37]     ,NIL})
                aAdd(aCab,{"B1_CUSTD"   ,aDados[08]     ,NIL})
                aAdd(aCab,{"B1_PICM"    ,aDados[22]     ,NIL})
                aAdd(aCab,{"B1_EX_NCM"  ,aDados[24]     ,NIL})
                aAdd(aCab,{"B1_IMPORT"  ,aDados[25]     ,NIL})
                aAdd(aCab,{"B1_GRTRIB"  ,aDados[26]     ,NIL})
                aAdd(aCab,{"B1_IMPZFRC" ,aDados[27]     ,NIL})
                aAdd(aCab,{"B1_CEST"    ,aDados[28]     ,NIL})
                aAdd(aCab,{"B1_MCUSTD"  ,aDados[09]     ,NIL})
                aAdd(aCab,{"B1_QE"      ,aDados[07]     ,NIL})
                aAdd(aCab,{"B1_PROC"    ,aDados[10]     ,NIL})
                aAdd(aCab,{"B1_LOJPROC" ,aDados[11]     ,NIL})
                aAdd(aCab,{"B1_PESBRU"  ,aDados[13]     ,NIL})
                aAdd(aCab,{"B1_PESO"    ,aDados[14]     ,NIL})
                aAdd(aCab,{"B1_LOTVEN"  ,aDados[16]     ,NIL})
                aAdd(aCab,{"B1_XNUMINM" ,aDados[17]     ,NIL})
                aAdd(aCab,{"B1_XVLDINM" ,aDados[18]     ,NIL})
                aAdd(aCab,{"B1_XDTULT"  ,aDados[38]     ,NIL}) 
                aAdd(aCab,{"B1_XPRCFOB" ,aDados[19]     ,NIL})
                aAdd(aCab,{"B1_XMOEFOB" ,aDados[20]     ,NIL})
                aAdd(aCab,{"B1_MSBLQL"  ,cMSBLQL        ,NIL})
                aAdd(aCab,{"B1_XAUDIT"  ,cXAUDIT        ,NIL})
            
        //        IF !EMPTY(aDados[40])      
        //            aAdd(aCab,{"B1_VM_I",cVM_I               ,NIL})
        //        ENDIF

        //        IF !EMPTY(aDados[41])
        //            aAdd(aCab,{"B1_VM_P",cVM_P               ,NIL})
        //        ENDIF

                aItens := { {"B5_FILIAL",xFilial("SB5")      ,Nil},;
                            {"B5_COD"   ,cCod                ,Nil},;
                            {"B5_CEME"  ,cCEME               ,NIL},; 
                            {"B5_MARPEC",cMARPEC             ,NIL},; 
                            {"B5_PORTMS",cPORTMS             ,NIL},; 
                            {"B5_COMPR" ,cCOMPR              ,NIL},; 
                            {"B5_LARG"  ,cLARG               ,NIL},; 
                            {"B5_ALTURA",cALTURA             ,NIL},; 
                            {"B5_CODLIN",cCODLIN             ,NIL},; 
                            {"B5_CODFAM",cCODFAM             ,NIL}} 

                aAmar := { {"A5_FILIAL" ,xFilial("SA5")      ,Nil},;
                        {"A5_PRODUTO", cCod               ,NIL},;
                        {"A5_NOMPROD", cDesc              ,NIL},;                        
                        {"A5_FORNECE", cFornece           ,NIL},; 
                        {"A5_LOJA"   , cLolja             ,NIL},; 
                        {"A5_CODPRF" , cCodprf            ,NIL},; 
                        {"A5_FABR"   , cFabr              ,NIL},; 
                        {"A5_FALOJA" , cFaloja            ,NIL}} 

            Endif

            cItens := Soma1(cItens,4)
            
            aTemp := {}

            //lMsErroAuto := .F.
    
            oModel  := FwLoadModel ("MATA010")
            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:Activate()
            //oModel:SetValue("SB1MASTER","B1_FILIAL"     ,cFilial)
            oModel:SetValue("SB1MASTER","B1_COD"        ,AllTrim( aDados[02] ))
            oModel:SetValue("SB1MASTER","B1_CODITE"     ,AllTrim( aDados[03] ))
            oModel:SetValue("SB1MASTER","B1_DESC"       ,AllTrim( aDados[04] ))
            oModel:SetValue("SB1MASTER","B1_TIPO"       ,AllTrim( aDados[05] ))
            oModel:SetValue("SB1MASTER","B1_GRUPO"      ,AllTrim( aDados[06] ))
            oModel:SetValue("SB1MASTER","B1_QE"         ,Val(AllTrim( aDados[07] ) ) )
            oModel:SetValue("SB1MASTER","B1_CUSTD"      ,Val(AllTrim( aDados[08] )))
            oModel:SetValue("SB1MASTER","B1_MCUSTD"     ,AllTrim( aDados[09] ))
            oModel:SetValue("SB1MASTER","B1_PROC"       ,AllTrim( aDados[10] ))
            oModel:SetValue("SB1MASTER","B1_LOJPROC"    ,AllTrim( aDados[11] ))
            oModel:SetValue("SB1MASTER","B1_ORIGEM"     ,AllTrim( aDados[12] ))
            oModel:SetValue("SB1MASTER","B1_PESBRU"     ,Val(AllTrim( aDados[13] ) ) )
            oModel:SetValue("SB1MASTER","B1_PESO"       ,Val(AllTrim( aDados[14] ) ))
            oModel:SetValue("SB1MASTER","B1_UM"         ,AllTrim( aDados[15] ))
            oModel:SetValue("SB1MASTER","B1_LOTVEN"     ,Val(AllTrim( aDados[16] ) ))
            oModel:SetValue("SB1MASTER","B1_XNUMINM"    ,AllTrim( aDados[17] )  )
            oModel:SetValue("SB1MASTER","B1_XVLDINM"    ,STOD(AllTrim( aDados[18] ) ) )
            oModel:SetValue("SB1MASTER","B1_XPRCFOB"    ,Val(AllTrim( aDados[19] ) )   )
            oModel:SetValue("SB1MASTER","B1_XMOEFOB"    ,AllTrim( aDados[20] ) )
            //oModel:SetValue("SB1MASTER","B1_LOCPAD"     ,AllTrim( aDados[21] ))  //a pedido do Andre
            oModel:SetValue("SB1MASTER","B1_PICM"       ,Val(AllTrim( aDados[22] ) ))
            oModel:SetValue("SB1MASTER","B1_POSIPI"     ,AllTrim( aDados[23] ))
            oModel:SetValue("SB1MASTER","B1_EX_NCM"     ,AllTrim( aDados[24] ) )
            oModel:SetValue("SB1MASTER","B1_IMPORT"     ,AllTrim( aDados[25] ) )
            oModel:SetValue("SB1MASTER","B1_GRTRIB"     ,AllTrim( aDados[26] ) )
            oModel:SetValue("SB1MASTER","B1_IMPZFRC"    ,AllTrim( aDados[27] ))
            oModel:SetValue("SB1MASTER","B1_CEST"       ,StrTran((AllTrim( aDados[28] ) ), '.'))  //a pedido do Andre
            //oModel:SetValue("SB1MASTER","B1_LOCREC"     ,AllTrim( aDados[29] ))
            oModel:SetValue("SB1MASTER","B1_SEGUM"      ,AllTrim( aDados[30] ))
            oModel:SetValue("SB1MASTER","B1_GARANT"     ,AllTrim( aDados[33] ) )
            oModel:SetValue("SB1MASTER","B1_RASTRO"     ,AllTrim( aDados[34] ))
            oModel:SetValue("SB1MASTER","B1_CONTA"      ,AllTrim( aDados[35] ))
            oModel:SetValue("SB1MASTER","B1_ITEMCC"     ,AllTrim( aDados[36] ))
            oModel:SetValue("SB1MASTER","B1_CLVL"       ,AllTrim( aDados[37] ))
            oModel:SetValue("SB1MASTER","B1_XDTULT"     ,STOD(AllTrim( aDados[38] ) ))
            oModel:SetValue("SB1MASTER","B1_XINTEG"     ,AllTrim( aDados[39] ))
            oModel:SetValue("SB1MASTER","B1_CONV"       ,AllTrim( aDados[31] ))
            oModel:SetValue("SB1MASTER","B1_TIPCONV"    ,AllTrim( aDados[32] ))
            oModel:SetValue("SB1MASTER","B1_XAUDIT"     ,cXAUDIT)
            oModel:SetValue("SB1MASTER","B1_MSBLQL"     ,cMSBLQL)
            oModel:SetValue("SB1MASTER","B1_VM_I"       ,AllTrim( aDados[40] ))   
            oModel:SetValue("SB1MASTER","B1_VM_P"       ,AllTrim( aDados[41] ))    

            If oModel:VldData()
                oModel:CommitData()
                U_Z023Compl(cCod,nOpca,aItens)
                U_z023GeraB2(cCod, nQuant)
                Z023Amar(nOpca,aAmar)
                //Inibido a pedido do Andre para n�o bloquear o Produto
                //RecLock('SB1', .F.)
                //    SB1->B1_MSBLQL := "1"
                //SB1->(MsUnlock())

                _cLog := "[ZPECF023] - Registro INCLUIDO! " + Alltrim(cCod) + "  Opcao: " + cOperacao
                GERLOG()
            
            Else
                aLog  := oModel:GetErrorMessage()
                _cLog := ""
            
                For _nI := 1 To Len(aLog)
                    If !Empty(aLog[_nI]) .AND. _nI = 6
                        _cLog += Alltrim(aLog[_nI]) + " Produto " + Alltrim(cCod) + CRLF
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
    
    //End Transaction

    FT_FUSE("TRB1")

Return()




/*/{Protheus.doc} Z023Compl
Fun��o que gera o complemento do produto (SB5) atrav�s do produto (SB1)
@author A.Carlos
@since 19/07/2022
@version 1.0
@type function
@obs 
/*/
User Function Z023Compl(cCod,nOpca,aItens)
    Processa({|| fProcessa(cCod,nOpca,aItens)}, "Processando...")
Return
 
/*----------------------------------------------------------*
 | Func.: fProcessa                                         |
 | Desc.: Fun��o de processamento para gravar o complemento |
 *----------------------------------------------------------*/
Static Function fProcessa(cCod,nOpca,aItens)
Local aArea    := GetArea()
//Local lPosUM   := ( SB5->(FieldPos('B5_UMIND')) != 0)
Local _lExist  := .F.
Local _cQuery  := ""
Local _cQAlias := "QSB5"
Local _nI      := 0
Local aLog     := {}	

If Select( (_cQAlias) ) > 0
    (_cQAlias)->(DbCloseArea())
EndIf

_lExist := .F.
_cQuery := " "

_cQuery := " SELECT B5_FILIAL,B5_COD,B5_CEME,B5_MARPEC,B5_PORTMS,B5_COMPR,B5_LARG,B5_ALTURA,B5_CODLIN,B5_CODFAM "
_cQuery += " ,R_E_C_N_O_ RECORD"
_cQuery += " FROM "+retsqlName('SB5')
_cQuery += " WHERE B5_FILIAL = '" + xFilial('SB5')+"'"
_cQuery += "   AND B5_COD    = '" + Alltrim(cCod) + "'"
_cQuery += "   AND D_E_L_E_T_=' ' "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cQAlias, .F., .T. )

If !(_cQAlias)->(Eof())
    SB5->( dbGoto( (_cQAlias)->RECORD ))     // posiciona o registro
    _lExist := .T.
    IF Empty(cCEME)      
        cCEME := (_cQAlias)->B5_CEME
    ENDIF
    IF Empty(cMARPEC)      

        VQS->(DbSetOrder(4))
    
        If VQS->(DbSeek(xFilial("VQS") + cFornece + cLojaFor ))
            cMarPec  := VQS->VQS_MARPEC
        else
            cMARPEC  := (_cQAlias)->B5_MARPEC
        EndIf

    ENDIF
    IF Empty(cPORTMS)      
        cPORTMS := (_cQAlias)->B5_PORTMS
    ENDIF
    IF Empty(cCOMPR)      
        cCOMPR := (_cQAlias)->B5_COMPR
    ENDIF
    IF Empty(cLARG)      
        cLARG := (_cQAlias)->B5_LARG
    ENDIF
    IF Empty(cALTURA)      
        cALTURA := (_cQAlias)->B5_ALTURA
    ENDIF
    IF Empty(cCODLIN)      
        cCODLIN := (_cQAlias)->B5_CODLIN
    ENDIF
    IF Empty(cCODFAM)      
        cCODFAM := (_cQAlias)->B5_CODFAM
    ENDIF
Endif

oModel := FwLoadModel("MATA180")
oModel:SetOperation(nOpca)
oModel:Activate()
oModel:LoadValue("SB5MASTER","B5_FILIAL"  ,xFilial('SB5') )
oModel:LoadValue("SB5MASTER","B5_COD"     ,cCOD )
oModel:LoadValue("SB5MASTER","B5_CEME"    ,cCEME )
oModel:LoadValue("SB5MASTER","B5_MARPEC"  ,cMARPEC )
oModel:LoadValue("SB5MASTER","B5_COMPR"   ,cCOMPR )
oModel:LoadValue("SB5MASTER","B5_LARG"    ,cLARG )
oModel:LoadValue("SB5MASTER","B5_ALTURA"  ,cALTURA )
oModel:LoadValue("SB5MASTER","B5_CODLIN"  ,cCODLIN )
oModel:LoadValue("SB5MASTER","B5_CODFAM"  ,cCODFAM )
oModel:LoadValue("SB5MASTER","B5_UMIND"   ,'1')

If oModel:VldData()
    oModel:CommitData()
    _cLog := ""
    _cLog += " Complemento Produto OK!"
    GERLOG()
Else
    aLog := oModel:GetErrorMessage()
    _cLog := ""

    For _nI := 1 To Len(aLog)
        If !Empty(aLog[_nI]) .AND. _nI = 6
            _cLog += Alltrim(aLog[_nI])  + " Complemento Produto: " + Alltrim(cCod) + CRLF
            GERLOG()
        EndIf
    Next
EndIf

oModel:DeActivate()
oModel:Destroy()
oModel := NIL


RestArea(aArea)

Return


/*/{Protheus.doc} Z023Compl
Fun��o que gera a amarra��o de Produto x Fornecedor
@author A.Carlos
@since 28/07/2022
@version 1.0
@type function
@obs 
/*/
Static Function Z023Amar(nOpca,aAmar)
Local oModel   := Nil
Local _nI      := 0
Local aLog     := {}
Local _cQSA5   := "QSB5"
Local _lExist  := .F.
Local _cQ      := " "

    If Select( (_cQSA5) ) > 0
        (_cQSA5)->(DbCloseArea())
    EndIf

    _lExist := .F.
    _cQ := " "

    _cQ := " SELECT A5_FILIAL,A5_PRODUTO,A5_FORNECE,A5_LOJA,A5_CODPRF,A5_FABR,A5_FALOJA"
    _cQ += "  ,R_E_C_N_O_ RECORD"
    _cQ += "  FROM "+retsqlName('SA5')
    _cQ += "  WHERE A5_FILIAL  = '" + xFilial('SA5') +"'"
    _cQ += "    AND A5_FORNECE = '" + aAmar[4][2] + "'"
    _cQ += "    AND A5_LOJA    = '" + aAmar[5][2] + "'"
    _cQ += "    AND A5_PRODUTO = '" + aAmar[2][2] + "'"
    _cQ += "    AND D_E_L_E_T_=' ' "

    dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQ ), _cQSA5, .F., .T. )

    IF !(_cQSA5)->( EOF() )   //Posicionar na SA5 no registro a ser alterado

        RecLock("SA5",.F.)
        SA5->A5_CODPRF := AllTrim(aAmar[6][2])
        SA5->A5_FABR   := AllTrim(aAmar[7][2])
        SA5->A5_FALOJA := AllTrim(aAmar[8][2])
        SA5->(MsUnlock())
    
        _cLog += " Amarra��o Produto x Fornecedor Alterada OK! " + aAmar[2][2]
        GERLOG() 

    Else

    /*    RecLock("SA5",.T.)
        SA5->A5_FILIAL := AllTrim(aAmar[1][2])   
        SA5->A5_PRODUTO:= AllTrim(aAmar[2][2])
        SA5->A5_NOMPROD:= AllTrim(aAmar[3][2])
        SA5->A5_FORNECE:= AllTrim(aAmar[4][2])
        SA5->A5_LOJA   := AllTrim(aAmar[5][2])        
        SA5->A5_CODPRF := AllTrim(aAmar[6][2])
        SA5->A5_FABR   := AllTrim(aAmar[7][2])
        SA5->A5_FALOJA := AllTrim(aAmar[8][2])
        SA5->(MsUnlock())
        _cLog += " Amarra��o Produto x Fornecedor OK! " + aAmar[2][2]
        GERLOG()*/

    oModel := FWLoadModel('MATA061')  
    
    oModel:SetOperation(nOpca)

    oModel:Activate()
    
    //Cabe�alho
    oModel:SetValue('MdFieldSA5','A5_PRODUTO',aAmar[2][2])
    //oModel:SetValue('MdFieldSA5','A5_NOMPROD',aAmar[3][2])
    
    //Grid
    oModel:SetValue('MdGridSA5','A5_FORNECE',aAmar[4][2])
    oModel:SetValue('MdGridSA5','A5_LOJA'   ,aAmar[5][2])
    oModel:SetValue('MdGridSA5','A5_CODPRF' ,aAmar[6][2])
    oModel:SetValue('MdGridSA5','A5_FABR'   ,aAmar[7][2])
    oModel:SetValue('MdGridSA5','A5_FALOJA' ,aAmar[8][2])
    
    If oModel:VldData()
        oModel:CommitData()
        _cLog := ""
        _cLog += " Amarra��o Produto x Fornecedor OK! " + aAmar[2][2]
        GERLOG()
    Else
        aLog := oModel:GetErrorMessage()
        _cLog := ""
    
        For _nI := 1 To Len(aLog) 
            If !Empty(aLog[_nI]) .AND. _nI = 6
                _cLog += " Amarra��o Produto x Fornecedor ERRO " + Alltrim(aLog[_nI]) + CRLF
                GERLOG()
            EndIf
        Next
    EndIf

    oModel:DeActivate()
    
    oModel:Destroy()

    Endif

Return


/*/{Protheus.doc} zGeraB2
Fun��o que gera saldo atual
@author A.Carlos
@since 19/07/2022
@version 1.0
@param cCodProd, Caracter, C�digo do Produto, cLocal, Local, C�digo do armaz�m, nQtAtu, Num�rico, Qtde_Atual
@example
u_zGeraB2("00000001", "01", 3000)
/*/

User Function z023GeraB2(cCod, nQuant)
Local aArea  := GetArea()
Local aLocal := {}   //{"01","61","65","80"}
Local I      := 0
Local _lExist    := .F.
Local _cQueArm   := ""
Local _cQA1      := "QNNR"
Local _cQuery    := ""
Local _cQAlias   := "QSB2"

If Select( (_cQA1) ) > 0
    (_cQA1)->(DbCloseArea())
EndIf

_cQueArm := " "

_cQueArm := " SELECT NNR_CODIGO, NNR_DESCRI "
_cQueArm += "   FROM "+retsqlName('NNR')
_cQueArm += "  WHERE NNR_FILIAL = '"+xFilial('NNR')+"' "
_cQueArm += "    AND D_E_L_E_T_=' ' "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQueArm ), _cQA1, .F., .T. )

If (_cQA1)->(!Eof())
    _lExist := .T.
Endif

DbSelectArea(_cQA1)
(_cQA1)->(dbGoTop())

While (_cQA1)->(!Eof())

    AADD(aLocal,{(_cQA1)->NNR_CODIGO}) 
    (_cQA1)->( dbSkip() )
    
End

FOR I = 1 TO Len(aLocal)

    If Select( (_cQAlias) ) > 0
        (_cQAlias)->(DbCloseArea())
    EndIf

    _lExist := .F.
    _cQuery := " "

    _cQuery := " SELECT *"
    _cQuery += "   FROM "+retsqlName('SB2')
    _cQuery += "  WHERE B2_FILIAL = '"+xFilial('SB2')+"'"
    _cQuery += "    AND B2_COD    = '" + Alltrim(cCod) + "'"
    _cQuery += "    AND B2_LOCAL  = '" + aLocal[I][1] + "'"
    _cQuery += "    AND D_E_L_E_T_=' ' "

    dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cQAlias, .F., .T. )

    If !(_cQAlias)->(Eof())
        _lExist := .T.
    Endif

    If _lExist = .F.    //If !SB2->(DbSeek(xFilial("SB2") + _cCod + aLocal[I]))
        RecLock('SB2', .T.)
            SB2->B2_FILIAL  := FWxFilial('SB2')
            SB2->B2_COD     := cCod
            SB2->B2_LOCAL   := aLocal[I][1]
        SB2->(MsUnlock())
    ENDIF

Next I

RestArea(aArea)

Return




/*/{Protheus.doc} m010AltRa
Fun��o que altera dados do produto (SB1)
@author A.Carlos
@since 19/07/2022
@version 1.0
@type function
@obs 
/*/
User Function m010AltRa(aDados)
Local oModel := Nil
Local aLog   := {}
Local _nI    := 0
Local cConv  := 1
Local cTipconv := ""
Local cVM_I  := ""
Local cVM_P  := ""
Private lMsErroAuto := .F.


        IF !Empty(aDados[31])                
            cCONV := Val(AllTrim( aDados[31] ) )
        ELSE
            cCONV := 1
        ENDIF
        IF !Empty(aDados[32])                
            cTIPCONV := Val(AllTrim( aDados[32] ) )
        ELSE
            cTIPCONV := 'M'
        ENDIF
        IF !EMPTY(aDados[40])           
            cVM_I := AllTrim(aDados[40])
        ENDIF
        IF !EMPTY(aDados[41])           
            cVM_P := AllTrim(aDados[41])
        ENDIF

oModel := FwLoadModel ("MATA010")
oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()
//oModel:SetValue("SB1MASTER","B1_FILIAL"     ,cFilial)
 
oModel:SetValue("SB1MASTER","B1_COD"        ,AllTrim( aDados[02] ))
oModel:SetValue("SB1MASTER","B1_CODITE"     ,AllTrim( aDados[03] ))
oModel:SetValue("SB1MASTER","B1_DESC"       ,AllTrim( aDados[04] ))
oModel:SetValue("SB1MASTER","B1_TIPO"       ,AllTrim( aDados[05] ))
oModel:SetValue("SB1MASTER","B1_GRUPO"      ,AllTrim( aDados[06] ))
oModel:SetValue("SB1MASTER","B1_QE"         ,Val(AllTrim( aDados[07] ) ) )
oModel:SetValue("SB1MASTER","B1_CUSTD"      ,Val(AllTrim( aDados[08] )))
oModel:SetValue("SB1MASTER","B1_MCUSTD"     ,AllTrim( aDados[09] ))
oModel:SetValue("SB1MASTER","B1_PROC"       ,AllTrim( aDados[10] ))
oModel:SetValue("SB1MASTER","B1_LOJPROC"    ,AllTrim( aDados[11] ))
oModel:SetValue("SB1MASTER","B1_ORIGEM"     ,AllTrim( aDados[12] ))
oModel:SetValue("SB1MASTER","B1_PESBRU"     ,Val(AllTrim( aDados[13] ) ) )
oModel:SetValue("SB1MASTER","B1_PESO"       ,Val(AllTrim( aDados[14] ) ))
oModel:SetValue("SB1MASTER","B1_UM"         ,AllTrim( aDados[15] ))
oModel:SetValue("SB1MASTER","B1_LOTVEN"     ,Val(AllTrim( aDados[16] ) ))
oModel:SetValue("SB1MASTER","B1_XNUMINM"    ,AllTrim( aDados[17] )  )
oModel:SetValue("SB1MASTER","B1_XVLDINM"    ,STOD(AllTrim( aDados[18] ) ) )
oModel:SetValue("SB1MASTER","B1_XPRCFOB"    ,Val(AllTrim( aDados[19] ) )   )
oModel:SetValue("SB1MASTER","B1_XMOEFOB"    ,AllTrim( aDados[20] ) )
//oModel:SetValue("SB1MASTER","B1_LOCPAD"     ,AllTrim( aDados[21] ))  //a pedido do Andre
oModel:SetValue("SB1MASTER","B1_PICM"       ,Val(AllTrim( aDados[22] ) ))
oModel:SetValue("SB1MASTER","B1_POSIPI"     ,AllTrim( aDados[23] ))
oModel:SetValue("SB1MASTER","B1_EX_NCM"     ,AllTrim( aDados[24] ) )
oModel:SetValue("SB1MASTER","B1_IMPORT"     ,AllTrim( aDados[25] ) )
oModel:SetValue("SB1MASTER","B1_GRTRIB"     ,AllTrim( aDados[26] ) )
oModel:SetValue("SB1MASTER","B1_IMPZFRC"    ,AllTrim( aDados[27] ))
oModel:SetValue("SB1MASTER","B1_CEST"       ,StrTran((AllTrim( aDados[28] ) ), '.'))  
//oModel:SetValue("SB1MASTER","B1_LOCREC"     ,AllTrim( aDados[29] ))  //a pedido do Andre
oModel:SetValue("SB1MASTER","B1_SEGUM"      ,AllTrim( aDados[30] ))
oModel:SetValue("SB1MASTER","B1_GARANT"     ,AllTrim( aDados[33] ) )
oModel:SetValue("SB1MASTER","B1_RASTRO"     ,AllTrim( aDados[34] ))
oModel:SetValue("SB1MASTER","B1_CONTA"      ,AllTrim( aDados[35] ))
oModel:SetValue("SB1MASTER","B1_ITEMCC"     ,AllTrim( aDados[36] ))
oModel:SetValue("SB1MASTER","B1_CLVL"       ,AllTrim( aDados[37] ))
oModel:SetValue("SB1MASTER","B1_XDTULT"     ,STOD(AllTrim( aDados[38] ) ))
oModel:SetValue("SB1MASTER","B1_XINTEG"     ,AllTrim( aDados[39] ))
oModel:SetValue("SB1MASTER","B1_CONV"       ,cCONV)
oModel:SetValue("SB1MASTER","B1_TIPCONV"    ,cTIPCONV)
oModel:SetValue("SB1MASTER","B1_XAUDIT"     ,cXAUDIT)
oModel:SetValue("SB1MASTER","B1_VM_I"       ,cVM_I)   
oModel:SetValue("SB1MASTER","B1_VM_P"       ,cVM_P)    

If oModel:VldData()
    oModel:CommitData()
    _cLog := "[ZPECF023] - Registro ALTERADO! " + Alltrim(cCod) + "  Opcao: " + cOperacao
    GERLOG()
Else
    aLog := oModel:GetErrorMessage()
    _cLog := ""
 
    For _nI := 1 To Len(aLog) 
        If !Empty(aLog[_nI]) .AND. _nI = 6
            _cLog += Alltrim(aLog[_nI]) + CRLF
            GERLOG()
        EndIf
    Next
EndIf
  
oModel:DeActivate()
oModel:Destroy()
oModel := NIL

Return Nil


/*/{Protheus.doc} ZPECF023
Log de execu��o da planilha cadastro de produtos
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	17/08/2022
@return  	NIL
@obs        Grava log das inconsistencias encontradas
@project
@history    , P.DT_PROCESSADO AS DT_RGLOG // _cQ += "   AND P.DT_PROCESSADO >= TO_DATE('2022-08-17','YYYY-MM-DD')"  removido p/ n�o acessar o WIS
/*/
Static Function LogExec()
Local _cQLOGE  := "LOGE"
Local _lExist  := .F.
Local _cQ      := " "
Local _nPasso  := 0

    If Select( (_cQLOGE) ) > 0
        (_cQLOGE)->(DbCloseArea())
    EndIf

    _lExist := .F.
    _cQ := " "

    _cQ := " SELECT B1.B1_COD CODIGO,B1.B1_DESC DESCRICAO,A5.A5_FORNECE FORNECEDOR,B5.B5_CODLIN LINHA,"
    _cQ += "  Substr(TO_CHAR(B1.B1_XDTULT),7,2)||'/'||Substr(TO_CHAR(B1.B1_XDTULT),5,2)||'/'||Substr(TO_CHAR(B1.B1_XDTULT),1,4) AS DT_ATUAL,"
    _cQ += "  COUNT(B2.B2_LOCAL) AS ARMAZEM "
    _cQ += "  FROM " + retsqlName('SB1') + ' B1'
    _cQ += "  LEFT JOIN " + retsqlName('SA5') + ' A5'
    _cQ += "   	  ON A5.D_E_L_E_T_  = ' '"
	_cQ += "      AND A5.A5_FILIAL  = B1.B1_FILIAL "
	_cQ += "      AND A5.A5_PRODUTO = B1.B1_COD    "
	_cQ += "      AND A5.A5_FORNECE = B1.B1_PROC   "
	_cQ += "      AND A5.A5_LOJA = B1.B1_LOJPROC   "
    _cQ += "  LEFT JOIN " + retsqlName('SB5') + ' B5'
    _cQ += "   	  ON B5.D_E_L_E_T_  = ' '"
	_cQ += "      AND B5.B5_FILIAL  = B1.B1_FILIAL "
	_cQ += "      AND B5.B5_COD     = B1.B1_COD    "
    _cQ += "  LEFT JOIN " + retsqlName('SB2') + ' B2'
    _cQ += "   	  ON B2.D_E_L_E_T_  = ' '"
	_cQ += "      AND B2.B2_FILIAL  = '" + xFilial("SB2") + "' "
	_cQ += "      AND B2.B2_COD     = B1.B1_COD    "
    _cQ += "  LEFT JOIN WIS.INT_E_PRODUTO@DBLINK_WISHML P" 
    _cQ += "   	  ON CAST(P.CD_PRODUTO AS CHAR(27)) = B1.B1_COD"
    _cQ += "  WHERE B1.D_E_L_E_T_ = ' ' AND B1.B1_XDTULT = Date()"
    _cQ += "  GROUP BY B1.B1_COD, B1.B1_DESC, B1.B1_XDTULT, A5.A5_FORNECE, B5.B5_CODLIN"

    dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQ ), _cQLOGE, .F., .T. )

    WHILE (_cQLOGE)->( !EOF() ) 
        IF _nPasso = 0
            _cLog := ""
            GERLOG()  
            _cLog += 'Produto    Descricao          DT_Atual        Fornecedor     Linha       Armazem ' 
            GERLOG()
            _nPasso := 1
        ENDIF
        _cLog := ""  
        _cLog += Alltrim((_cQLOGE)->CODIGO)+' '+Alltrim((_cQLOGE)->DESCRICAO)+' '+((_cQLOGE)->DT_ATUAL)+' '+(_cQLOGE)->FORNECEDOR+' '+(_cQLOGE)->LINHA+' '+Strzero((_cQLOGE)->ARMAZEM,02)
        GERLOG()
        (_cQLOGE)->( DBSKIP() )
    END 

    dbSelectArea("TRB1")
    dbGotop()
    If TRB1->(!EOF())
        Processa({|| IMPEXC() },"Gerando Relatorio de Log... "+"[ZPECF023]")
    ENDIF

Return()


/*/{Protheus.doc} ZPECF023
Importacao de planilha cadastro de produtos
@param  	Numero Origem e Munic�pio Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	15/07/2022
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
        /*TRB1->SERIE        := _cSerie
        TRB1->EMISSAO      := _dData   
        TRB1->CONTEINER    := _cCont
        TRB1->VLR.FRETE    := _nValTot
        TRB1->CHAVE        := _cChave
        TRB1->UF_ORIGEM    := _cUfOri
        TRB1->MUN_ORIGEM   := _cMunOri
        TRB1->UF_DESTINO   := _cUfDes
        TRB1->MUN_DESTINO  := _cMunDes
        TRB1->LOG          := _cLog*/
        TRB1->( msUnlock() )
    Endif

Return()


/*/{Protheus.doc} ZPECF023
Importacao de planilha cadastro de produtos
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	15/07/2022
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


/*/{Protheus.doc} ZPECF023
Importacao de planilha cadastro produtos
@param  	Numero Origem e Munic�pio Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	15/07/2022
@return  	NIL
@obs        Impress�o Log das Inconsistencias encontradas
@project
@history
/*/
Static Function ReportDef()
    Local oReport
    Local oSection1

    oReport := TReport():New("IMPEXC","Log",,{|oReport| PrintReport(oReport)},"Este relatorio ir� imprimir Log")

    oSection1 := TRSection():New(oReport,OemToAnsi("Log"),{"TRB"})

    TRCell():New(oSection1,"LOG","TRB1","LOG","@!",280)
    //TRCell():New(oSection1,"NOTA","TRB1","NOTA",PesqPict("LOG","NOTA"),TamSX3("F1_DOC")[1],/*lPixel,{|| (TRB1)->NOTA }*/)

    oSection1:Cell("LOG")  :SetHeaderAlign("RIGHT")
    //oSection1:Cell("NOTA") :SetHeaderAlign("RIGHT")

Return oReport


/*/{Protheus.doc} ZPECF023
Importacao de planilha produtos
@param  	Numero Origem e Munic�pio Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	15/07/2022
@return  	NIL
@obs        Processo de Impress�o Log das Inconsistencias encontradas
@project
@history
/*/
Static Function PrintReport(oReport)

    Local oSection1 := oReport:Section(1)
    oSection1:SetTotalInLine(.F.)
    oSection1:SetTotalText("Total Geral  ")  // Imprime Titulo antes do Totalizador da Se��o
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
@since      Out/2019
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

// Somente prosseguir se o arquivo ainda n�o estiver no formato TXT Tab Delimited:

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


/*/{Protheus.doc} ZPECF023
@param  	Numero Origem e Munic�pio Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	15/07/2022
@return  	NIL
@obs        Limpar OBJ
@project
@history
/*/
User Function FreeObj()
Local oSay01 := TSay():New( 010,005,{|| "UA:" },GetWndDefault(),,,.F.,.F.,.F.,.T.,,,550,008)
FreeObj( oSay01 )
Return( Nil )
