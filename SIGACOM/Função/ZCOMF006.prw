#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH"
#include "rwmake.ch"
#include "TOTVS.ch"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "Eicsi400.ch"
#INCLUDE "AvPrint.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWFILTER.CH"
#INCLUDE "FWMVCDEF.CH"

#define CMD_OPENWORKBOOK			1
#define CMD_CLOSEWORKBOOK			2
#define CMD_ACTIVEWORKSHEET			3
#define CMD_READCELL				4
/*/{Protheus.doc} ZCOMF006
Importacao de planilha e geracao de CTE
@param  	Numero Origem e Município Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	30/01/2020
@return  	NIL
@obs
@project
@history
/*/
User Function ZCOMF006()

    LOCAL oDlg
    LOCAL nOpca       := 0
    Local aPergs 	  := {}
    Local cCaminho    := Space(60)
    Private cINTCSV   := ""          
    Private cExt      := ".XLSX"
    Private _cLocal   := ""
    Private _cEmp  	  := FWCodEmp()
    Private lRet      := .T.
    Public aRetP 	  := {}
    Public cCusto     := Space(15)
    Public cTes       := Space(03)
    Public cCondP     := Space(03)
    Public cProd      := Space(25)
    Public cFor       := Space(06)
    Public cLoja      := Space(02)
    //Public cNome      := Space(40)
    Public cFatura    := Space(40)
    Public _cMunOri   := GetMv("MV_XMUNORI",.F.,"48500")
    Public _cMunDes   := GetMv("MV_XMUNDES",.F.,"01108")
    Public _cSerie    := GetMv("CMV_SERCTE",.F.,"1  "  )

    If _cEmp == "2010" //Executa o p.e. somente para Anapolis.
        _cLocal := "PRD"
    else
        _cLocal := "55"
    EndIf

    aAdd( aPergs ,{6,"Diretorio do Arquivo ",cCaminho     ,"@!" ,     ,'.T.' ,80,.T.,"Arquivos .xls |*.xls " })
    aAdd( aPergs ,{1,"Fornecedor           ",cFor	      ,"@!"	,'.T.',"SA2A",'.T.',03,.T.})
    aAdd( aPergs ,{1,"Loja                 ",cLoja	      ,"@!"	,'.T.'," "   ,'.T.',03,.T.})
    //aAdd( aPergs ,{1,"Nome                 ",cNome	      ,"@!"	,'.T.'," "   ,'.T.',80,.F.})
    aAdd( aPergs ,{1,"Tes                  ",cTes	      ,"@!"	,'.T.',"SF4" ,'.T.',03,.T.})
    aAdd( aPergs ,{1,"Cond.Pgto            ",cCondP	      ,"@!"	,'.T.',"SE4" ,'.T.',03,.T.})
    aAdd( aPergs ,{1,"Produto              ",cProd	      ,"@!"	,'.T.',"SB1" ,'.T.',80,.T.})
    aAdd( aPergs ,{1,"Centro de Custo      ",cCusto	      ,"@!"	,'.T.',"CTT" ,'.T.',80,.T.})
    aAdd( aPergs ,{1,"Fatura               ",cFatura      ,"@!"	,'.T.'," "   ,'.T.',80,.T.})

    If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 

        DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Importação Documento Entrada") PIXEL
        @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
        @ 29, 15 SAY OemToAnsi("Esta rotina realiza a importação de Planilha Excel para Geração de CTE") SIZE 268, 8 OF oDlg PIXEL
        @ 38, 15 SAY OemToAnsi("Da Caoa Montadora.") SIZE 268, 8 OF oDlg PIXEL
        @ 48, 15 SAY OemToAnsi("Confirma Geração da Documento?") SIZE 268, 8 OF oDlg PIXEL
        DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
        DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
        ACTIVATE MSDIALOG oDlg CENTER

        If nOpca == 1
            Processa ({|| FImpExcel()},"Aguarde! Efetuando Importação da Planilha "+"[ZCOMF006]")
        Endif

    Endif

Ferase(cINTCSV)

Return()


/*/{Protheus.doc} ZCOMF006
Importacao de planilha e geracao de CTE
@param  	Numero Origem e Município Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	30/01/2020
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
    Private _lExtrai   := .F.
    Private _aStruLog  := {}
    Private _aErro     := {}
    Private _nPos      := 0
    Private _cLog 	   := ""
    Private _aCelulas  := {}
    Private aCab       := {}
    Private nItDoc     := 0

    lAutoErrNoFile:= .t.

// Elementos da Matriz _aCelulas
// 1o.-> Descrição do Campo
// 2o.-> Coluna da Planilha
// 3o.-> Linha da Planilha
// 4o.-> Tipo do dado a ser Gravado( Caracter,Numerico,Data)
// 5o.-> Tamanho do Dado a Ser Gravado
// 6o.-> Casas decimais do dado a ser Gravado

// Montagem das Celulas do Cabeçalho
    AADD(_aCelulas,{'NOTA'             ,"A",04,'C',09,0})  //1
    AADD(_aCelulas,{'SERIE'            ,"B",04,'C',03,0})  //2
    AADD(_aCelulas,{'EMISSAO'          ,"C",04,'D',08,0})  //3
    AADD(_aCelulas,{'CONTEINER'        ,"D",04,'C',20,0})  //4
    AADD(_aCelulas,{'VLR.FRETE'        ,"M",04,'N',14,7})  //5
    AADD(_aCelulas,{'CHAVE'            ,"V",04,'C',44,0})  //6
    AADD(_aCelulas,{'UF_ORIGEM'        ,"X",04,'C',02,0})  //7
    AADD(_aCelulas,{'MUN_ORIGEM'       ,"W",04,'C',44,0})  //8
    AADD(_aCelulas,{'UF_DESTINO'       ,"Z",04,'C',02,0})  //9
    AADD(_aCelulas,{'MUN_DESTINO'      ,"Y",04,'C',44,0})  //10

    AADD(_aStruLog,{"LOG","C",280,0})
    AADD(_aStruLog,{"NOTA","C",009,0}) 

    _cArqTRB   := Criatrab(_aStruLog,.T.)
	_cIndice   := CriaTrab(Nil,.F.)
    _cChaveInd := "NOTA"

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
   	   MsgStop("[ZCOMF006] - "+"Arquivo não existe! ")
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
		    MsgInfo("Falha na conversão do Arquivo .xlsx"+ Chr(13) + Chr(10) + "Verifique se há janelas abertas do MSExcel com mensagens. "+"[ZCOMF006]")
		    If MsgYesNo("Deseja Tentar novamente ? "+"[ZCOMF006]")
			   //cINTCSV := u_SV_XLS2CSV(AllTrim(cDiretorio), cExt)
			   cINTCSV := GeraVBS( cFileOpen )			
		    Else
			   MsgStop("Conversão do arquivo mal sucedida! Abortando... "+"[ZCOMF006]")
               lRet := .F.
			   Return .F.
		    Endif
	    End
    Endif

    dbSelectArea("SA2")
    dbSetOrder(1)
    If !dbSeek(xFilial("SA2") + aRetP[2] + aRetP[3])
	   MsgStop("Fornecedor ou loja não cadastrado!   Abortando...   "+"[ZCOMF006]")
       lRet := .F.
	   Return .F.
    EndIf

    // Verifica se Conseguiu efetuar a Abertura do Arquivo
    nHdl := Fopen(cINTCSV)
    If ( nHdl >= 0 )
        // Carrega o Excel e Abre o arquivo
        cBuffer := cINTCSV + Space(512)
        nBytes  := FSeek(nHdl, 0, 2)
        //nBytes  := ExeDLLRun2(nHdl, CMD_OPENWORKBOOK, @cBuffer)

        If ( nBytes < 0 )
            // Erro critico na abertura do arquivo sem msg de erro
            MsgInfo("Não foi possível abrir o arquivo :" + cINTCSV , " [ZCOMF006]")
            lRet := .F.
            Return
        EndIf

        // Extrai os Dados 
        U_IMPPLAN(cINTCSV,_aCelulas,_lExtrai)
        
        IF lRet = .F.
            FCLOSE(nHdl)
            Return()
        ENDIF

        dbSelectArea("TRB1")
        dbGotop()
        If TRB1->(!EOF())
            Processa({|| IMPEXC() },"Gerando Relatorio de Log... "+"[ZCOMF006]")
        Else
            // Fecha o arquivo e remove o excel da memoria
            cBuffer := Space(512)
            ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
            ExecInDLLClose(nHdl)
        Endif
    Else
        MsgStop('Nao foi possivel abrir o arquivo. '+"[ZCOMF006]")
    EndIf
    
    FCLOSE(nHdl)

Return()


/*/{Protheus.doc} ZCOMF006
Importacao de planilha e geracao de CTE
@param  	Numero Origem e Município Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	30/01/2020
@return  	NIL
@obs        Retorna o Conteudo de Uma planilha Excel para o Protheus
@project
@history
/*/
User Function IMPPLAN(_nAqr,_cMatriz,_lExtrai)
Local _cNota     := "000000000"
Local _cRetorno	 := ''
Local _cNewRet   := ''
Local _cTipo	 := ''
Local _cTamanho	 := ''
Local _cDecimal	 := ''
Local _cString	 := ''
Local cSeparador := ""						// Separador do arquivo
Local cLinha     := ""                      // Linha importar do arquivo
Local aDados 	 := {}						// Array dos dados da linha do laco
Local aItenfe    := {}
Local _dData     := ""
Local _cCont	 := ""
Local _nValTot   := 0
Local _cChave	 := ""
Local _cUfOri	 := ""
Local _cMunOri   := ""
Local _cUfDes	 := ""
Local _cMunDes   := ""
Local _nY        := 0
Local _nX        := 0
Local _nElem     := 0
Local _nPos01    := 1
Local _nPos02    := 1
Local _nPos03    := 1

    IncProc()
    FT_FUSE(_nAqr)
    FT_FGOTOP()
    FT_FSKIP(1)  //Linhas a saltar

    Begin Transaction
    
    While !FT_FEOF() .AND. lRet = .T.
        cLinha  := FT_FREADLN()
        _nPos01 := AT(Chr(09),cLinha)

        cSeparador := Substr(cLinha,_nPos01,1)
        If !(cSeparador $ (";,"+Chr(09)))
            MSGINFO("Separador do arquivo invalido! "+"[ZCOMF006]")
	        fErase(_nAqr+GetDbExtension())
	        fErase(cSysPath+AllTrim(_nAqr))
            lRet := .F.
	        Return(.F.)
        Endif

        aDados  := Separa(cLinha,cSeparador)

        cFor      := 	aRetP[2]
        cLoja     :=	aRetP[3]
        cTes      := 	aRetP[4]
        cCondP    := 	aRetP[5]
        cProd     := 	aRetP[6]
        cCusto    := 	aRetP[7]
        cFatura   := 	aRetP[8]
        cItens    :=    '0000'

        AADD(_aCelulas,{'NOTA'             ,"A",04,'C',09,0})  //1
        AADD(_aCelulas,{'SERIE'            ,"B",04,'C',03,0})  //2
        AADD(_aCelulas,{'EMISSAO'          ,"C",04,'D',08,0})  //3
        AADD(_aCelulas,{'CONTEINER'        ,"D",04,'C',20,0})  //4
        AADD(_aCelulas,{'VLR.FRETE'        ,"M",04,'N',14,7})  //5
        AADD(_aCelulas,{'CHAVE'            ,"V",04,'C',44,0})  //6
        AADD(_aCelulas,{'UF_ORIGEM'        ,"X",04,'C',02,0})  //7
        AADD(_aCelulas,{'MUN_ORIGEM'       ,"W",04,'C',44,0})  //8
        AADD(_aCelulas,{'UF_DESTINO'       ,"Z",04,'C',02,0})  //9
        AADD(_aCelulas,{'MUN_DESTINO'      ,"Y",04,'C',44,0})  //10

        FOR _nY := 1 TO LEN(aDados)
            // Realiza tratamento do campo usado de acordo com o Tipo
            IF ((_nY < 5 .OR. _nY = 13) .OR. (_nY > 21 .and. _nY < 27))
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
                    _nPos02 := AT("/",_cRetorno)  //posição da primeira barra  até aqui é o mês  
                    _nPos03 := AT("/",_cRetorno,_nPos02+1)  //posição da segunda barra  até aqui é o mês    

                    _cMes := Substr(_cRetorno,1,_nPos02-1)
                    _cMes := PADL(_cMes,02,"0") 

                    _cDia := Substr(_cRetorno,_nPos02+1,2)
                    _cDia := PADL(_cDia,02,"0") 
                    
                    _cAno := Substr(_cRetorno,_nPos03+1,4)
                    _cAno := PADL(_cAno,04,"0")
                          
                    _cNewRet  := CtoD(_cDia+"/"+_cMes+"/"+_cAno)
                    _cRetorno := _cNewRet
                Endif

                If _cTipo == 'C' .AND. _lExtrai // Caracter e extrão de caracteres
                    _cString := ' '
                    _cNewRet := ' '
                    For _nElem	 := 1 To Len(_cRetorno)
                        _cString := SubStr(_cRetorno,_nElem,1)
                        If _cString $ '#/#,#.#-'
                            Loop
                        Endif
                        _cNewRet :=Alltrim(_cNewRet)+_cString
                    Next _nElem
                    _cRetorno    := _cNewRet
                Endif

                If _cTipo == 'C'   // Ajusta O Tamanho da variavel
                    _cRetorno := Alltrim(_cRetorno)
                    _cRetorno := _cRetorno+Space(_cTamanho-Len(_cRetorno))
                Endif
                aDados[_nY] := _cRetorno
            ENDIF

        NEXT

        _cNota   := PadL( AllTrim( aDados[01] ) , TamSX3( "F1_DOC"     )[1],"0")
        _cSerie  := PadR( AllTrim( aDados[02] ) , TamSX3( "F1_SERIE"   )[1],"")
        _dData   := aDados[03]
        _cCont   := PadR( AllTrim( aDados[04] ) , TamSX3( "D1_XCONT"   )[1],"")
        _nValTot := aDados[13]
        _cChave  := PadR( AllTrim( aDados[22] ) , TamSX3( "F1_CHVNFE"  )[1],"")
        _cMunOri := PadR( AllTrim( aDados[23] ) , TamSX3( "F1_MUORITR" )[1],"")
        _cUfOri  := PadR( AllTrim( aDados[24] ) , TamSX3( "F1_UFORITR" )[1],"")
        _cMunDes := PadR( AllTrim( aDados[25] ) , TamSX3( "F1_MUDESTR" )[1],"")
        _cUfDes  := PadR( AllTrim( aDados[26] ) , TamSX3( "F1_UFDESTR" )[1],"")
        
        IncProc("Montando dados de entrada...")
        //MsProcTxt("Proc.Registro: "+StrZero(_nElemPro,6))
        //_nSomaLin++
        If Empty(_cNota) .OR. _cNota = "000000000"
           //lRet := .F.
           Exit
        Endif

        If Len(aCab) == 0
            dbSelectArea("SA2")
            dbSetOrder(1)
            If dbSeek(xFilial("SA2") + cFor + cLoja)
                aAdd(aCab,{"F1_FILIAL"	,xFilial("SF1")          ,Nil})
                aAdd(aCab,{"F1_TIPO"	,"N"	                 ,Nil})
                aAdd(aCab,{"F1_FORMUL"	,"N"                     ,Nil})
                aAdd(aCab,{"F1_DOC"		,_cNota                  ,Nil})//_cNota
                aAdd(aCab,{"F1_SERIE"	,_cSerie                 ,Nil})// coloca no layout
                aAdd(aCab,{"F1_EMISSAO"	,_dData                  ,Nil})
                aAdd(aCab,{"F1_DTDIGIT"	,dDataBase		   	     ,Nil})
                aAdd(aCab,{"F1_FORNECE"	,cFor                    ,Nil})//cFor
                aAdd(aCab,{"F1_LOJA"	,cLoja   	             ,Nil})//cLoja
                aAdd(aCab,{"F1_ESPECIE"	,"CTE"                   ,NIL})
                aAdd(aCab,{"F1_COND"	,cCondP			         ,Nil})//cCondP
                aAdd(aCab,{"E2_NATUREZ"  ,"2101"                 ,NIL})
                aAdd(aCab,{"F1_CHVNFE"	,_cChave                 ,NIL})
                aAdd(aCab,{"F1_TPCTE"   ,"N"                     ,NIL})
                aAdd(aCab,{"F1_XFATURA" ,cFatura                 ,NIL})
                aAdd(aCab,{"F1_UFORITR" ,_cUfOri                 ,NIL})
                aAdd(aCab,{"F1_MUORITR" ,_cMunOri                ,NIL})//_cMunOri
                aAdd(aCab,{"F1_UFDESTR" ,_cUfDes                 ,NIL})
                aAdd(aCab,{"F1_MUDESTR" ,_cMunDes                ,NIL})//_cMunDes
            Endif
        Endif

        cItens := Soma1(cItens,4)
        DBSelectArea("SB1")
        DBSetOrder(1)
        DBSeek(xFilial("SB1")+cProd)

        aTemp := {}
        aAdd(aTemp,{"D1_FILIAL"   ,xFilial("SF1")    			            ,Nil})
        aAdd(aTemp,{"D1_TIPO"     ,"N"						                ,Nil})
        aAdd(aTemp,{"D1_COD"      ,cProd      				            	,Nil})
        aAdd(aTemp,{"D1_ITEM"     ,cItens						            ,Nil})
        aAdd(aTemp,{"D1_UM"       ,SB1->B1_UM   			                ,Nil})
        aAdd(aTemp,{"D1_CC"       ,cCusto					                ,Nil})
        aAdd(aTemp,{"D1_LOCAL"    ,_cLocal 						            ,Nil})
        aAdd(aTemp,{"D1_QUANT"    , 1									    ,Nil})
        aAdd(aTemp,{"D1_VUNIT"    ,_nValTot                            		,Nil})
        aAdd(aTemp,{"D1_TOTAL"    ,_nValTot                            		,Nil})
        aAdd(aTemp,{"D1_TES"      ,cTes                     				,Nil})
        aAdd(aTemp,{"D1_DOC"      ,_cNota					                ,Nil})
        aAdd(aTemp,{"D1_SERIE"    ,_cSerie   	         		    		,Nil})
        aAdd(aTemp,{"D1_FORNECE"  ,cFor		         			            ,Nil})
        aAdd(aTemp,{"D1_LOJA"     ,cLoja			         	     	    ,Nil})
        aAdd(aTemp,{"D1_EMISSAO"  ,_dData   						        ,Nil})
        aAdd(aTemp,{"D1_DTDIGIT"  ,dDataBase						        ,Nil})
        aAdd(aTemp,{"D1_XCONT"    ,_cCont						            ,Nil})

        aAdd(aIteNFE,aclone(aTemp))

        lMsErroAuto := .F.

        If !Empty(aCab) .And. !Empty(aIteNFE)
            msExecAuto({|x,Y,Z|mata103(x,Y,Z)},aCab,aIteNFE,3)
            If lMsErroAuto
               aErro := GetAutoGRLog() //Retorna erro em array
               _cLog := Alltrim(AllToChar( aErro[1] )) + Alltrim(_cNota)
               GERLOG()
            Else
               _cLog := "[ZCOMF006] - Documento Gerado Num.: " + Alltrim(_cNota)
               GERLOG()
            Endif
        Else
            MsgInfo( "Não foi possivel gerar as notas, realizar novo processamento.", "[ ZCOMF006 ] - Aviso" )
        EndIf
        

        aIteNFE := {}
        aCab    := {}
        FT_FSKIP()

    END
    
    End Transaction

    FT_FUSE("TRB1")

Return()


/*/{Protheus.doc} ZCOMF006
Importacao de planilha e geracao de CTE
@param  	Numero Origem e Município Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	30/01/2020
@return  	NIL
@obs        Grava log das inconsistencias encontradas
@project
@history
/*/
Static Function GERLOG()
    dbSelectArea("TRB1")
    If !dbSeek(_cLog)
        RecLock("TRB1",.T.)
        TRB1->NOTA         := _cNota
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


/*/{Protheus.doc} ZCOMF006
Importacao de planilha e geracao de CTE
@param  	Numero Origem e Município Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	30/01/2020
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


/*/{Protheus.doc} ZCOMF006
Importacao de planilha e geracao de CTE
@param  	Numero Origem e Município Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	30/01/2020
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


/*/{Protheus.doc} ZCOMF006
Importacao de planilha e geracao de CTE
@param  	Numero Origem e Município Destino
@author 	A. Oliveira
@version  	P12.1.25
@since  	30/01/2020
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
