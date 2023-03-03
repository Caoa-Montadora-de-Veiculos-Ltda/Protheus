#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "REPORT.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
#include "totvs.ch"
#include "Fileio.ch"
#define F_BLOCK  512
#define KEY_ESC  27
/*/{Protheus.doc} ZESTF005
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	05/11/2020
@return  	NIL
@obs        Local cMainPath	:= GetMv("CMV_EST001")      
@project
@history    Importar itens do inventario via planilha 
/*/
User Function ZESTF005()  
Local cExtens   := "Arquivo CSV | *.CSV"
Local aPergs    := {}
Local nOpca     := 0
Local _dDtFim   := Date()                          //MV_PAR02 = DataProc
Local cPesq     := "_Importa\"
Local nInd      := 1
Local nPos      := 0 
Private cArq      := ""
Private aArea     := GetArea()
Private cMainPath := GetMv("CMV_EST001")         //"C:\Users\antonio.poliveira\Documents\Arquivos_Importa\"          //"C:\TEMP"  //"C:\Users\antonio.poliveira\Documents\Desenvolvimento\Tabelas"   //"C:\TEMP"   
Private lRes      := .F.
Private aRetP     := {}
Private _lRetorno := .T.
Private _dFecha   := GetMv("MV_ULMES")
Private _dFecha1  := GetMv("MV_DBLQMOV")
Private _nReco    := 0
Private cNF_SZM   := " "
Private cLogWrite := " " 
Private cLinha    := ""
Private cStatus   := ""
Private cFileOpen := ""
Private cArqLog	  := cMainPath+"\Importados\CRIAEIC_"+DTOS(Date())+StrTran(Time(),":")+".LOG"

////U_ZGENUSER( <ID User> , <"NOME DA FUNÇÃO"> , <.F.=Não Exibe Msg; .T.=Exibe Msg> )
IF U_ZGENUSER( RetCodUsr() ,"ZESTF005" ,.T.) = .F. 
   RETURN Nil
ENDIF

aAdd( aPergs ,{1,"Data de Procesamento ",_dDtFim     ,"   ","U_TestaDT5()","   " ,'.T.',80,.F.})
aAdd( aPergs ,{6,"Selecione arquivo "   ,cMainPath   ,"@!" ,              ,'.T.' ,80      ,.T.,cExtens })

If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("CRIA Itens do inventário - EIC") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina CRIA Itens do inventario - EIC") SIZE 268, 8 OF oDlg PIXEL
   @ 38, 15 SAY OemToAnsi("Conforme layout: CSV") SIZE 268, 8 OF oDlg PIXEL
   @ 48, 15 SAY OemToAnsi("Confirma Processo ? ") SIZE 268, 8 OF oDlg PIXEL
   DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
   DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
   ACTIVATE MSDIALOG oDlg CENTER

   If nOpca == 0
      Return()
   Endif

   cFileOpen := Alltrim(mv_par02)

   nPos := AT(cPesq,cMainPath,nInd)

   cArq := Alltrim(Substr(mv_par02,nPos+9,12))

   Processa({|| ZESTF005B(cFileOpen,@cArqLog) }, "[ZESTF005] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." )
		
   MSGINFO( "Final do processamento!" + CRLF +  "Para mais informações, verifique o arquivo de log: " + cArqLog )
	 
Endif

Return Nil 


User Function TestaDT5()
    IF _dFecha > MV_PAR01
    	MsgInfo("Data de Processmanto menor que o Fechamento! ","ZESTF005")
        _lRetorno := .T.
    Endif
    IF _dFecha1 > MV_PAR01
    	MsgInfo("Data de Processmanto menor que o Fechamento! ","ZESTF005")
        _lRetorno := .T.
    Endif
Return(_lRetorno)


/*
==============================================================================================
Funcao.........:	ZESTF005B
Descricao......:	Faz a leitura do arquivo CSV e a gravação da tabela 
Autor..........:	A. Oliveira
Criação........:	05/11/2020
Alterações.....:    //4110108106  caso precise fixar conta contábil
===============================================================================================
*/
Static Function ZESTF005B(cFileOpen,cArqLog)
Local aDados 		:= {}						// Array dos dados da linha do laco
Local aDadosLi      := {}
Local nLoop         := 0
Local nTotal        := 0
Local cSepar        := ""
Local lErro         := .F.
Private nAtual      := 0
Private cFILIAL     := ""  
Private cINVOICE    := ""
Private cNAVIO      := ""
Private cBL         := ""
Private cCONT       := ""
Private cLOTE       := ""
Private cCASE       := ""
Private cPROD       := ""
Private cDESCR      := ""
Private cQTDE       := 0
Private cEMISS      := ""
Private cUNIT       := ""
Private cDOC        := ""
Private cSERIE      := ""
Private cITEM       := ""
Private cFORNEC     := ""
Private cLOJA       := ""
Private cWMS        := ""
Private _cBlq       := ""
Private _cUser      := Substr(cUserName,1,20)
Private _cMesProc   := Month(_dFecha)
Private _aStruLog   := {}
Private _cArqTRB    := ""
Private _cIndice    := ""
Private _cChaveInd  := ""
Private lAutoErrNoFile := .T.
private lMsErroAuto := .F.

AADD(_aStruLog,{"LINHA"  ,"C",006,0})
AADD(_aStruLog,{"STATUS" ,"C",010,0})
AADD(_aStruLog,{"LOG"    ,"C",280,0})
AADD(_aStruLog,{"FILIAL" ,"C",010,0})
AADD(_aStruLog,{"INVOICE","C",020,0})
AADD(_aStruLog,{"NAVIO"  ,"C",040,0})
AADD(_aStruLog,{"BL"     ,"C",020,0})
AADD(_aStruLog,{"CONT"   ,"C",020,0})
AADD(_aStruLog,{"LOTE"   ,"C",020,0})
AADD(_aStruLog,{"CASE"   ,"C",006,0})
AADD(_aStruLog,{"PROD"   ,"C",023,0})
AADD(_aStruLog,{"DESCR"  ,"C",060,0})
AADD(_aStruLog,{"QTDE"   ,"N",012,2})
AADD(_aStruLog,{"EMIS"   ,"D",008,0})
AADD(_aStruLog,{"UNIT"   ,"C",040,0})
AADD(_aStruLog,{"DOC"    ,"C",009,0})
AADD(_aStruLog,{"SERIE"  ,"C",003,0})
AADD(_aStruLog,{"ITEM"   ,"C",003,0})
AADD(_aStruLog,{"FORNEC" ,"C",006,0})
AADD(_aStruLog,{"LOJA"   ,"C",002,0})

_cArqTRB   := Criatrab(_aStruLog,.T.)
_cIndice   := CriaTrab(Nil,.F.)
_cChaveInd := "INVOICE"

If Select("TRB5") > 0
    dbSelectArea("TRB5")
    dbCloseArea()
    TCDelFile(_cArqTRB)
EndIf

dbCreate( _cArqTRB , _aStruLog , "TOPCONN" )
dbUseArea( .T., __LocalDriver, _cArqTRB , "TRB5", .F., .F. )
dbCreateIndex( _cArqTRB ,_cChaveInd )

dbSelectArea( "TRB5" )
dbSetOrder(1)

FT_FUSE(cFileOpen)
FT_FGOTOP()
cLinha := FT_FREADLN()
cSepar := Substr(cLinha,08,1)
If !(cSepar $ (";,"))
    MsgInfo("Separador do arquivo invalido!!! " + cSepar)
    cLogWrite += ("Erro Separador do arquivo invalido! ")
    cStatus := " Erro "
    GERLOG()
    FT_FUSE()
    Return
ENDIF

FT_FSKIP()

While !FT_FEOF()
    nTotal++
    cLinha := FT_FREADLN()	
    aDados := Separa(cLinha,cSepar)
    aAdd(aDadosLi, aClone(aDados))
	FT_FSKIP()
END

FT_FUSE()
ProcRegua(nTotal)

//--Ativação da tabela de etiquetas
D0Y->( DbSetOrder(1) )

For nLoop := 1 to Len(aDadosLi)
    cLogWrite := ''
    lRes  := .F. //Inicializa a validação do produto
    lFor  := .F. //Inicializa a validação do fornecedor
    lWMS  := .F. //Inicializa a validação do wms
    nAtual++

    IncProc("Registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
    
    cInvoice := Alltrim(aDadosLi[nLoop][01])
    cNavio   := Alltrim(aDadosLi[nLoop][02])
    cBL      := Alltrim(aDadosLi[nLoop][03])     
    cCont    := Alltrim(aDadosLi[nLoop][04])               
    cLote    := Alltrim(aDadosLi[nLoop][05])   //VAL(aDadosLi[nLoop][05])         
    cCase    := Alltrim(aDadosLi[nLoop][06])
    cCodSap  := Alltrim(aDadosLi[nLoop][08])
    cDoc     := Alltrim(aDadosLi[nLoop][09])  
    cSerie   := Alltrim(aDadosLi[nLoop][10])
    //cItem    := Alltrim(aDadosLi[nLoop][11])
    cProd    := Alltrim(aDadosLi[nLoop][12])
    cDescr   := Alltrim(aDadosLi[nLoop][13])
    cQtde    := VAL(aDadosLi[nLoop][14])
    cEmis    := CTOD(aDadosLi[nLoop][15])
    cUnit    := cLote+cCase
    
    VerFor(cCodSap)  //retorna lFor

    IF lFor = .F.   
        cLogWrite := " Fornecedor não cadastrado. " + cCodSap 
        cStatus := " Erro "
        GERLOG()
    ENDIF

    IF !EMPTY(cProd)

        VerProd(cProd)   //SB1

        IF lRes = .F.   
            cLogWrite := " Produto não cadastrado. " + cProd 
            cStatus := " Erro "
            GERLOG()
        ENDIF

        VerWMS(cProd)  //SB5

        IF lWMS = .F.   
            cLogWrite := " Produto sem controle de WMS. " + cProd 
            cStatus := " Erro "
            GERLOG()
            lWMS := .F. 
        ENDIF

        //--Valida se unitizador ja existe no sistema
        If D0Y->( DbSeek( FWxFilial("D0Y") + cUnit ) )
            cLogWrite := "Unitizador: " + cUnit + " utilizado por outro processo."
            cStatus := " Erro "
            GERLOG()
            lWMS := .F.
        EndIf

    ENDIF

    //--Impede a continuidade se apresentou erro em alguma validação
    If lFor == .F. .OR. lRes == .F. .OR. lWMS == .F.
        lErro := .T.
    EndIf

Next nLoop 

IF lErro     //lFor = .F. .OR. lRes = .F. .OR. lWMS = .F.
    dbSelectArea("TRB5")
    dbGotop()
    If TRB5->(!EOF())
        Processa({|| IMPEXC() },"Gerando Relatorio de Log... "+"[ZESTF005]")
    Else
        cBuffer := Space(512)
    Endif
    RestArea(aArea) 
    FT_FUSE()

    __CopyFile( cFileOpen, cMainPath+"Erro\"+cArq )
    FErase(cFileOpen)
    Return()
ENDIF

//Next nLoop          era aqui

nAtual := 0

//IF lFor = .T. .AND. lRes = .T. .AND. lWMS = .T.  
Begin Transaction

    For nLoop := 1 to Len(aDadosLi)

        nAtual++

        IncProc("Registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        
        cInvoice := Alltrim(aDadosLi[nLoop][01])
        cNavio   := Alltrim(aDadosLi[nLoop][02])
        cBL      := Alltrim(aDadosLi[nLoop][03])     
        cCont    := Alltrim(aDadosLi[nLoop][04])               
        cLote    := Alltrim(aDadosLi[nLoop][05])   //VAL(aDadosLi[nLoop][05])         
        cCase    := Alltrim(aDadosLi[nLoop][06])
        cCodSap  := Alltrim(aDadosLi[nLoop][08])
        cDoc     := Alltrim(aDadosLi[nLoop][09])  
        cSerie   := Alltrim(aDadosLi[nLoop][10])
        //cItem    := Alltrim(aDadosLi[nLoop][11])
        cProd    := Alltrim(aDadosLi[nLoop][12])
        cDescr   := Alltrim(aDadosLi[nLoop][13])
        cQtde    := VAL(aDadosLi[nLoop][14])
        cEmis    := CTOD(aDadosLi[nLoop][15])
        cUnit    := cLote+cCase
        cDoc     := PadL(cDoc,TamSX3("ZM_DOC")[1],"0")
        cSerie   := PadR(cSerie,TamSX3("ZM_SERIE")[1]," ")
        cItem    := PadL(cItem,TamSX3("ZM_ITEM")[1],"0")

        GrvProd()  //Se T OK Grava o registro na Tabela Auxiliar SZM
        cStatus := " OK "
        GERLOG()

    Next nLoop 

End Transaction
//ENDIF


//*********************************************************************
//      Chamada do relatório
//*********************************************************************
    dbSelectArea("TRB5")
    dbGotop()
    If TRB5->(!EOF())
        Processa({|| IMPEXC() },"Gerando Relatorio de Log... "+"[ZESTF005]")
    Else
        cBuffer := Space(512)
    Endif
    RestArea(aArea) 
    FT_FUSE()

    __CopyFile( cFileOpen, cMainPath+"Importados\"+cArq )
    FErase(cFileOpen)

Return()



//==============================================================================================
//Funcao.........:	GrvProd()
//Descricao......:	Gravar o registro da CBC   13068560
//Autor..........:	A.Oliveira
//Criação........:	05/11/2020
//==============================================================================================
Static Function GrvProd()
    Local cAliasQry := GetNextAlias()

    If Select( cAliasQry ) > 0
		( cAliasQry )->( DbCloseArea() )
	EndIf

    IF cNF_SZM <> cDOC
       cNF_SZM := cDOC
       cItem   := '0000'
    ENDIF
    
    cItem := Soma1(cItem)

    //Begin Transaction

    //DBSELECTAREA("SZM")
    //SZM->(DbSetOrder(1))

    //Evita registros duplicados na tabela SZM
    //If !( SZM->( DbSeek( FWxFilial("SZM") + cBL + cINVOICE + cFORNEC + cLOJA + cDOC + cSERIE + cITEM ) ) )

	BeginSql Alias cAliasQry
		SELECT SZM.ZM_BL
		FROM %Table:SZM% SZM
		WHERE SZM.ZM_FILIAL = %xFilial:SZM%
		AND SZM.ZM_BL = %Exp:cBL%
        AND SZM.ZM_INVOICE = %Exp:cINVOICE%
        AND SZM.ZM_FORNEC = %Exp:cFORNEC%
        AND SZM.ZM_LOJA = %Exp:cLOJA%
        AND SZM.ZM_DOC = %Exp:cDOC%
        AND SZM.ZM_SERIE = %Exp:cSERIE%
        AND SZM.ZM_PROD = %Exp:cPROD%
        AND SZM.ZM_ITEM = %Exp:cITEM%
		AND SZM.%NotDel%
	EndSql

    //--Se não encontrou, efetua gravação
    If (cAliasQry)->( Eof() )

        RecLock("SZM",.T.)
        SZM->ZM_FILIAL := '2010022001'      //'2010022001'  
        SZM->ZM_INVOICE := cINVOICE
        SZM->ZM_NAVIO   := cNAVIO
        SZM->ZM_BL      := cBL        
        SZM->ZM_CONT    := cCONT  
        SZM->ZM_LOTE    := cLOTE       
        SZM->ZM_CASE    := cCASE 
        SZM->ZM_DOC     := cDOC
        SZM->ZM_SERIE   := cSERIE
        SZM->ZM_ITEM    := cITEM      
        SZM->ZM_PROD    := cPROD  
        SZM->ZM_DESCR   := cDESCR
        SZM->ZM_QTDE    := cQTDE
        SZM->ZM_EMIS    := cEmis
        SZM->ZM_UNIT    := cUNIT    
        SZM->ZM_FORNEC  := cFORNEC
        SZM->ZM_LOJA    := cLOJA
        SZM->ZM_CNPJ    := cCodSap
    
        SZM->( msUnlock() )
    
    EndIf

    ( cAliasQry )->( DbCloseArea() )
	//End Transaction

Return()


/*/{Protheus.doc} ZCOMF006
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        Grava log das inconsistencias encontradas
@project
@history
/*/
Static Function GERLOG()
    dbSelectArea("TRB5")
    IF cStatus = " Erro "
        RecLock("TRB5",.T.)
        TRB5->Linha     := StrZero(nAtual,6) 
        TRB5->PROD      := cPROD 
        TRB5->BL        := cBL     
        TRB5->INVOICE   := cINVOICE
        TRB5->STATUS    := cStatus
        TRB5->LOG       := cLogWrite
        TRB5->FILIAL    := xFilial("SZM")
        TRB5->( msUnlock() )
    ELSE
        RecLock("TRB5",.T.)
        TRB5->Linha     := StrZero(nAtual,6) 
        TRB5->PROD      := cPROD    
        TRB5->BL        := cBL       
        TRB5->INVOICE   := cINVOICE
        TRB5->STATUS    := cStatus
        TRB5->LOG       := cLogWrite
        TRB5->FILIAL    := xFilial("SZM")
        TRB5->( msUnlock() )
    Endif
    
    GravaPen(cLogWrite)
    
Return()

/*
  LOG
*/
Static Function GravaPen(cLogWrite)
Local cCab := "LOG"
If !File(cArqLog)
	nH := FCreate(cArqLog)
	FWrite(nH,cCab+Chr(13)+Chr(10),Len(cCab)+2)
Else
	nH := FOpen(cArqLog,1)
EndIf

FSeek(nH,0,2)
FWrite(nH,cLogWrite+Chr(13)+Chr(10),Len(cLogWrite)+2)
FClose(nH)
cLogWrite := " "
cStatus   := " "

Return 


/*/{Protheus.doc} ZESTF005
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        Verifica a existência do Produto no Protheus
@project
@history
/*/
Static Function VerProd(cProd)
    Local cB1cod:= " "
	Local cQy	:= " "
	Local cAlias:= "PRO"

	cQy := " SELECT B1_COD,B1_UM " + CRLF 
	cQy += "  FROM " + RetSQLName("SB1") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND B1_FILIAL = '" + xfilial('SB1') + "' " + CRLF 
	cQy += " AND B1_COD = '"    + cProd + "' " + CRLF  

	TcQuery cQy new Alias (cAlias)

    cB1cod := (cAlias)->B1_COD

    IF !Empty(cB1cod)
        lRes := .T. 
    ENDIF
	(cAlias)->(DbCloseArea())
Return(lRes)


/*/{Protheus.doc}  
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        Verifica o fornecedor
@project
@history
/*/
Static Function VerFor(cCodSap)
	Local cQyF	:= " "
	Local cAlias:= "FOR"

	cQyF := " SELECT A2_COD,A2_LOJA,A2_NOME,A2_XCDSAP,A2_END " + CRLF 
	cQyF += "  FROM " + RetSQLName("SA2") + CRLF 
	cQyF += " WHERE " + CRLF 
	cQyF += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQyF += " AND A2_FILIAL = '" + xfilial('SA2') + "' " + CRLF 
	cQyF += " AND A2_XCdSap = '" + cCodSap + "' " + CRLF  

	TcQuery cQyF new Alias (cAlias)

    cFornec:= (cAlias)->A2_COD
    cLoja  := (cAlias)->A2_LOJA

    IF !Empty(cFornec)
        lFor := .T. 
    ENDIF
	(cAlias)->(DbCloseArea())
Return(lFor)


/*/{Protheus.doc} ZESTF005
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/01/2021
@return  	NIL
@obs        Verifica a existência do Fornecedor no Protheus
@project
@history
/*/
Static Function VerWMS(cProd)
	Local cQyW	  := " "
	Local cAlias  := "WMA"
    
    cWMS := " "

	cQyW := " SELECT B5_COD,B5_CTRWMS " + CRLF 
	cQyW += "  FROM " + RetSQLName("SB5") + CRLF 
	cQyW += " WHERE " + CRLF 
	cQyW += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQyW += " AND B5_FILIAL = '" + xfilial('SB5') + "' " + CRLF 
	cQyW += " AND B5_COD = '" + cProd + "' " + CRLF  

	TcQuery cQyW new Alias (cAlias)

    cWMS  := (cAlias)->B5_CTRWMS

    IF cWMS = '1'
        lWMS := .T.
    ELSE
        lWMS := .F.
    ENDIF
	(cAlias)->(DbCloseArea())
Return(lWMS)


/*/{Protheus.doc} ZESTF005
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        VldLock()
@project
@history    Verificar se o registro na SB2 está liberado.
/*/
Static Function VldLock(_nReco)
	//Local nI		:= 0
	Local lLockSB2	:= .F.

	aLockSB2 := SB2->( DBRLockList() )
	//For nI := 1 To Len(aRecSB2)
		If AScan(aLockSB2, _nReco)
			lLockSB2 := .T.
			//Exit
		EndIf
	//Next

Return lLockSB2



/*/{Protheus.doc} ZESTF005
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
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
        oReport:nDevice := 4 //-- Gera arquivo em Planilha
        oReport:nEnvironment := 2 //-- Ambiente Local
        oReport:SetTotalInLine(.F.)
        oReport:PrintDialog()
    EndIf

Return()


/*/{Protheus.doc} ZESTF005
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
@return  	NIL
@obs        Impressão Log das Inconsistencias encontradas
@project
@history    
/*/
Static Function ReportDef()
    Local oReport
    Local oSection1
    Local cAlias := 'SZM'
    
    oReport := TReport():New("IMP","Log",,{|oReport| PrintReport(oReport)},"Este relatorio irá imprimir Log")
    oSection1 := TRSection():New(oReport,OemToAnsi("Log"),{"TRB"})
 
    TRCell():New(oSection1,"LINHA","TRB5","LINHA","@!",040)
    TRCell():New(oSection1,"PROD","TRB5","PROD",PesqPict(cAlias,"ZM_PROD"),TamSX3("ZM_PROD")[1],/*lPixel,{|| (TRB5)->NOTA }*/)
    //TRCell():New(oSection1,"CASE","TRB5","CASE",PesqPict(cAlias,"ZM_CASE"),TamSX3("ZM_CASE")[1],/*lPixel,{|| (TRB5)->NOTA }*/)
    TRCell():New(oSection1,"BL","TRB5","BL",PesqPict(cAlias,"ZM_BL"),TamSX3("ZM_BL")[1],/*lPixel,{|| (TRB5)->NOTA }*/)
    TRCell():New(oSection1,"CONT","TRB5","CONT",PesqPict(cAlias,"ZM_CONT"),TamSX3("ZM_CONT")[1],/*lPixel,{|| (TRB5)->NOTA }*/)
    TRCell():New(oSection1,"NAVIO","TRB5","NAVIO",PesqPict(cAlias,"ZM_NAVIO"),TamSX3("ZM_NAVIO")[1],/*lPixel,{|| (TRB5)->NOTA }*/)
    TRCell():New(oSection1,"QTDE","TRB5","QTDE",PesqPict(cAlias,"ZM_QTDE"),TamSX3("ZM_QTDE")[1],/*lPixel,{|| (TRB5)->NOTA }*/)
    TRCell():New(oSection1,"STATUS","TRB5","STATUS","@!",040)
    TRCell():New(oSection1,"LOG","TRB5","LOG","@!",280)
    TRCell():New(oSection1,"FILIAL","TRB5","FILIAL","@!",040)
    
    oSection1:Cell("LINHA")  :SetHeaderAlign("RIGHT")
    oSection1:Cell("PROD")   :SetHeaderAlign("RIGHT")
    oSection1:Cell("BL")     :SetHeaderAlign("RIGHT")
    oSection1:Cell("CONT")   :SetHeaderAlign("RIGHT")
    oSection1:Cell("NAVIO")  :SetHeaderAlign("RIGHT")
    oSection1:Cell("QTDE")   :SetHeaderAlign("RIGHT")
    oSection1:Cell("STATUS") :SetHeaderAlign("RIGHT")
    oSection1:Cell("LOG")    :SetHeaderAlign("RIGHT")
    oSection1:Cell("FILIAL") :SetHeaderAlign("RIGHT")
        
Return oReport


/*/{Protheus.doc} ZESTF005
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/11/2020
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

    DbSelectArea("TRB5")
    DbGoTop()

    oReport:SetMeter(RecCount())
    oSection1:Init()
    While  !Eof()
        If oReport:Cancel()
            Exit
        EndIf
        oSection1:PrintLine()

        DbSelectArea("TRB5")
        DbSkip()
        oReport:IncMeter()
    EndDo
    oSection1:Finish()

Return
