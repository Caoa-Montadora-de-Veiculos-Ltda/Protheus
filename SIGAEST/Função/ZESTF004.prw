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
/*/{Protheus.doc} ZESTF004
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	23/11/2020
@return  	NIL
@obs        Local cMainPath	:= GetMv("CMV_EST001")      
@project
@history    Importar MOVIMENTOS DE INVENTARIO via planilha 
/*/
User Function ZESTF004()  
Local cExtens   := "Arquivo CSV | *.CSV"
Local aPergs    := {}
Local cArq      := ""
Local nOpca     := 0
Local _dDtFim   := Date()                      //MV_PAR02 = DataProc
Private aArea     := GetArea()
Private cMainPath := GetMv("CMV_EST001")       //"C:\TEMP"  //"C:\Users\antonio.poliveira\Documents\Desenvolvimento\Tabelas"   //"C:\TEMP"   
Private lRes      := .F.
Private aRetP     := {}
Private _lRetorno := .T.
Private _dFecha   := GetMv("MV_ULMES")
Private _dFecha1  := GetMv("MV_DBLQMOV")
Private _nReco    := 0
Private nAtual    := 0
Private cUM       := " "
Private cLogWrite := " " 
Private cSTATUSL  := ""
Private cFileOpen := ""
Private cArqLog	  := cMainPath+"\CRIAZA0_"+DTOS(Date())+StrTran(Time(),":")+".LOG"
Private cProc     := .T.

////U_ZGENUSER( <ID User> , <"NOME DA FUNÇÃO"> , <.F.=Não Exibe Msg; .T.=Exibe Msg> )
IF U_ZGENUSER( RetCodUsr() ,"ZESTF004" ,.T.) = .F. 
   RETURN Nil
ENDIF

aAdd( aPergs ,{1,"Data de Procesamento ",_dDtFim      ,"   ","U_TestaDT3()","   " ,'.T.',80,.F.})
aAdd( aPergs ,{6,"Selecione arquivo "   ,cMainPath    ,"@!" ,     ,'.T.' ,80,.T.,cExtens })

If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 
 
   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("CRIA Itens do inventário") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza e CRIA Movimentos do inventario") SIZE 268, 8 OF oDlg PIXEL
   @ 38, 15 SAY OemToAnsi("Conforme layout: ") SIZE 268, 8 OF oDlg PIXEL
   @ 48, 15 SAY OemToAnsi("Confirma Processo ? ") SIZE 268, 8 OF oDlg PIXEL
   DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
   DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
   ACTIVATE MSDIALOG oDlg CENTER

   If nOpca == 0
      Return()
   Endif

   cArq := ALLTRIM(MV_PAR02)

   cFileOpen := cArq

   Processa({|| ZESTF004B(cFileOpen,@cArqLog) }, "[ZESTF004] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." )
   If cProc  
      MSGINFO( "Final do processamento!" + CRLF +  "Para mais informações, verifique o arquivo de log: " + cArqLog )
   Else
      MSGINFO( "Processamento interronpido!" + CRLF +  "Para mais informações, verifique o arquivo de log: " + cArqLog )
   ENDIF
	 
Endif

Return Nil 


User Function TestaDT3()
    IF _dFecha > MV_PAR01
    	MsgInfo("Data de Processmanto menor que o Fechamento! ","ZESTF004")
        _lRetorno := .T.
    Endif
    IF _dFecha1 > MV_PAR01
    	MsgInfo("Data de Processmanto menor que o Fechamento! ","ZESTF004")
        _lRetorno := .T.
    Endif
Return(_lRetorno)


/*
==============================================================================================
Funcao.........:	ZESTF004B
Descricao......:	Faz a leitura do arquivo CSV e a gravação da tabela 
Autor..........:	A. Oliveira
Criação........:	23/11/2020
Alterações.....:    //4110108106  caso precise fixar conta contábil
===============================================================================================
*/
Static Function ZESTF004B(cFileOpen,cArqLog)
Local aDados 		:= {}						// Array dos dados da linha do laco
Local aDadosLi      := {}
Local nLoop         := 0
Local nTotal        := 0
Local cSepar        := ""
Private cFILIAL     := "" 
Private cTM         := ""     
Private cCOD        := ""
Private nQUANT      := 0
Private cLOCAL      := ""
Private cDOC        := ""
Private cDOCB7      := ""
Private dEMISSA     := ""
Private nCUSTO1     := 0
Private cCC         := ""
Private cNUMSEQ     := ""
Private cTIPO       := ""
Private cLOTE       := ""
Private cSBLOTE     := ""
Private dDTVALI     := ""
Private cENDERE     := ""
Private cNUMSER     := ""
Private dDATA       := ""
Private cPEDIDO     := ""
Private cNOTA       := ""
Private cSERIE      := ""
Private cSTATUS     := ""
Private _cBlq       := ""
Private _cUser      := Substr(cUserName,1,20)
Private _cMesProc   := Month(_dFecha)
Private _aStruLog   := {}
Private _cArqTRB    := ""
Private _cIndice    := ""
Private _cChaveInd  := ""
Private lAutoErrNoFile := .T.
private lMsErroAuto := .F.
   
AADD(_aStruLog,{"LINHA"      ,"C",006,0})
AADD(_aStruLog,{"STATUSL"    ,"C",010,0})
AADD(_aStruLog,{"LOG"        ,"C",280,0})
AADD(_aStruLog,{"FILIAL"     ,"C",010,0})
AADD(_aStruLog,{"TM"         ,"C",003,0})
AADD(_aStruLog,{"COD"        ,"C",023,0})
AADD(_aStruLog,{"UM"         ,"C",002,0})
AADD(_aStruLog,{"QUANT"      ,"N",012,2})
AADD(_aStruLog,{"LOCALI"     ,"C",003,0})
AADD(_aStruLog,{"DOC"        ,"C",009,0})
AADD(_aStruLog,{"DOCB7"      ,"C",009,0})
AADD(_aStruLog,{"EMISSA"     ,"D",008,0})
AADD(_aStruLog,{"CUSTO1"     ,"N",014,2})
AADD(_aStruLog,{"CC"         ,"C",011,0})
AADD(_aStruLog,{"NUMSEQ"     ,"C",006,0})
AADD(_aStruLog,{"TIPO"       ,"C",002,0})
AADD(_aStruLog,{"LOTE"       ,"C",010,0})
AADD(_aStruLog,{"SBLOTE"     ,"C",006,0})
AADD(_aStruLog,{"DTVALI"     ,"D",008,3})
AADD(_aStruLog,{"ENDERE"     ,"C",015,0})
AADD(_aStruLog,{"NUMSER"     ,"C",020,0})
AADD(_aStruLog,{"PEDIDO"     ,"C",006,0})
AADD(_aStruLog,{"NOTA"       ,"C",009,0})
AADD(_aStruLog,{"SERIE"      ,"C",003,0})
AADD(_aStruLog,{"STATUS"     ,"C",001,0})

//AADD(_aStruLog,{"DATA"       ,"D",008,0})

dEMISSA  := PadL(dEMISSA,TamSX3("ZA0_EMISSA")[1]," ")
dDTVALI  := PadL(dDTVALI,TamSX3("ZA0_DTVALI")[1]," ")
dDATA    := PadL(dDATA,TamSX3("ZA0_DTVALI")[1]," ")

_cArqTRB   := Criatrab(_aStruLog,.T.)
_cIndice   := CriaTrab(Nil,.F.)
_cChaveInd := "COD"

If Select("TRB4") > 0
    dbSelectArea("TRB4")
    dbCloseArea()
    TCDelFile(_cArqTRB)
EndIf


dbCreate( _cArqTRB , _aStruLog , "TOPCONN" )
dbUseArea( .T., __LocalDriver, _cArqTRB , "TRB4", .F., .F. )
dbCreateIndex( _cArqTRB ,_cChaveInd )

dbSelectArea( "TRB4" )
dbSetOrder(1)

FT_FUSE(cFileOpen)
FT_FGOTOP()
cLinha := FT_FREADLN()
cSepar := Substr(cLinha,11,1)
If !(cSepar $ (";,"))
    MsgInfo("Separador do arquivo invalido!!! " + cSepar)
    cLogWrite += ("Erro Separador do arquivo invalido! ")
    cSTATUSL := " Erro "
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
For nLoop := 1 to Len(aDadosLi)

    If VAL(aDadosLi[nLoop][10]) <= 0 .or. empty((aDadosLi[nLoop][10]))
       cLogWrite := ("Erro Produto sem o preço de custo ou custo negativo. Produto:  " + Alltrim(aDadosLi[nLoop][03])  )
       cSTATUSL := " Erro "
       GERLOG()  
       MSGINFO( "Erro no processamento, o Produto: " + Alltrim(aDadosLi[nLoop][03]) + CRLF +  "Custo invalido ou negativo, nehum registro da planilha será importado. ")
       cProc := .F.
       RestArea(aArea)
       Return()
    Endif

    If AT("," , aDadosLi[nLoop][10]) 
       cLogWrite := ("Erro Produto favor utilizar o ponto ao invés da virgula. Produto:  " + Alltrim(aDadosLi[nLoop][03])  )
       cSTATUSL := " Erro "
       GERLOG()  
       MSGINFO( "Erro no processamento, o Produto: " + Alltrim(aDadosLi[nLoop][03]) + CRLF +  "favor utilizar o ponto ao invés da virgula no campo Custo unitário, nehum registro da planilha será importado. ")
       cProc := .F.
       RestArea(aArea)
       Return()
    Endif

Next nLoop
 
FT_FUSE()
ProcRegua(nTotal)

For nLoop := 1 to Len(aDadosLi)
    cLogWrite := ''
    lRes  := .F. //Inicializa a validação do produto

    //IF cCod == aDadosLi[nLoop][01] .AND. cLocal == aDadosLi[nLoop][03]
    //    cLogWrite := ("Erro Produto em Duplicidade na Planilha! Só será importado 01. " )
    //    cSTATUSL := " Erro "
    //    GERLOG()  
    //   LOOP
    //ENDIF
 
    nAtual++

    IncProc("Registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
    cFilial := Alltrim(aDadosLi[nLoop][01])
    cTM    := Alltrim(aDadosLi[nLoop][02])  
    cCOD   := Alltrim(aDadosLi[nLoop][03])   
    cUM    := Alltrim(aDadosLi[nLoop][04])    

    if VAL(aDadosLi[nLoop][05]) == 0
       nQUANT := Val(StrTran(aDadosLi[nLoop][05],",","."))  
    Else
       nQUANT := VAL(aDadosLi[nLoop][05])  
    Endif
  
    cLOCAL := Alltrim(aDadosLi[nLoop][06]) 
    cDOC   := Alltrim(aDadosLi[nLoop][07])   
    cDOCB7 := Right( Alltrim(aDadosLi[nLoop][08]), TamSX3("ZA0_DOCB7")[1] )
    dEMISSA:= STOD(aDadosLi[nLoop][09])

    nCUSTO1:= VAL(aDadosLi[nLoop][10])
    cCC    := Alltrim(aDadosLi[nLoop][11])   
    cNUMSEQ:= Alltrim(aDadosLi[nLoop][12])
    cTIPO  := Alltrim(aDadosLi[nLoop][13])  
    cLOTE  := Alltrim(aDadosLi[nLoop][14])  
    cSBLOTE:= Alltrim(aDadosLi[nLoop][15])
    dDTVALI:= STOD(aDadosLi[nLoop][16])
    cENDERE:= Alltrim(aDadosLi[nLoop][17])
    cNUMSER:= Alltrim(aDadosLi[nLoop][18])
    dDATA  := STOD(aDadosLi[nLoop][19])  
    cPEDIDO:= Alltrim(aDadosLi[nLoop][20])
    cNOTA  := Alltrim(aDadosLi[nLoop][21])  
    cSERIE := Alltrim(aDadosLi[nLoop][22])
    cSTATUS:= Alltrim(aDadosLi[nLoop][23])

  // alert((aDadosLi[nLoop][05]))
   //alert(VAL(aDadosLi[nLoop][05]))
   //alert(nQuant)


    //cNum	:= PadR(cNum,TamSX3("CBC_NUM")[1]," ")    

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica se existe  Produto ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    IF !EMPTY(cCod)

        /*VerProd(cCod)   //SB1

        IF lRes = .F.   
            cLogWrite := " Produto não cadastrado. " + cCod 
            cSTATUSL := " Erro "
            GERLOG()
            Loop 
        ENDIF*/

        GrvProd()  //Se T OK Grava o registro
        //cLogWrite := " Item entrou no SINC no Protheus inventario." 
        cSTATUSL := " OK "
        GERLOG()

        Loop 

    ENDIF

Next nLoop



//*********************************************************************
//      Chamada do relatório
//*********************************************************************
    dbSelectArea("TRB4")
    dbGotop()
    If TRB4->(!EOF())
        Processa({|| IMPEXC() },"Gerando Relatorio de Log... "+"[ZESTF004]")
    Else
        cBuffer := Space(512)
    Endif
    RestArea(aArea) 
    FT_FUSE()

Return()


//==============================================================================================
//Funcao.........:	GrvProd()
//Descricao......:	Gravar o registro da CBC   13068560
//Autor..........:	A.Oliveira
//Criação........:	23/11/2020
//==============================================================================================
Static Function GrvProd()

    Begin Transaction

    DBSELECTAREA("ZA0")
    RecLock("ZA0",.T.)
    ZA0->ZA0_FILIAL := '2010022001'  
    ZA0->ZA0_TM     := cTM
    ZA0->ZA0_COD    := AllTrim(cCOD)
    ZA0->ZA0_UM     := cUM
    //if type("nQUANT") != "N"


        
      //  alert(val(SubStr(nQUANT,1,1) + '.' + SubStr(nQUANT,3,2)))
      //  alert(val(transform(nQUANT, "@E 9.99" )))

     //   ZA0->ZA0_QUANT  := transform(nQUANT, "@E 9.99" )
        
     
    //Else
       ZA0->ZA0_QUANT  := nQUANT
    //Endif
    ZA0->ZA0_LOCAL  := cLOCAL
    ZA0->ZA0_UM     := cUM
    ZA0->ZA0_DOC    := cDOC
    ZA0->ZA0_DOCB7  := cDOCB7
    ZA0->ZA0_EMISSA := dEMISSA 
    ZA0->ZA0_CUSTO1 := nCUSTO1
    ZA0->ZA0_CC     := cCC
    ZA0->ZA0_NUMSEQ := cNUMSEQ
    ZA0->ZA0_TIPO   := cTIPO
    ZA0->ZA0_LOTE   := cLOTE
    ZA0->ZA0_SBLOTE := cSBLOTE
    ZA0->ZA0_DTVALI := dDTVALI
    ZA0->ZA0_ENDERE := cENDERE
    ZA0->ZA0_NUMSER := cNUMSER
    ZA0->ZA0_PEDIDO := cPEDIDO
    ZA0->ZA0_NOTA   := cNOTA
    ZA0->ZA0_SERIE  := cSERIE
    ZA0->ZA0_STATUS := cSTATUS
	ZA0->( msUnlock() )

//ZA0->ZA0_DATA   := cDATA
	End Transaction

Return()


/*/{Protheus.doc} ZCOMF006
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	23/11/2020
@return  	NIL
@obs        Grava log das inconsistencias encontradas
@project
@history
/*/
Static Function GERLOG()
    dbSelectArea("TRB4")
    IF cSTATUSL = " Erro "
        RecLock("TRB4",.T.)
        TRB4->Linha     := StrZero(nAtual,6) 
        TRB4->COD       := cCod        
	    TRB4->LOCALI    := cLocal
        TRB4->STATUSL   := cSTATUSL
        TRB4->LOG       := cLogWrite
        TRB4->( msUnlock() )
    ELSE
        RecLock("TRB4",.T.)
        TRB4->Linha     := StrZero(nAtual,6) 
        TRB4->COD       := cCod        
	    TRB4->LOCALI    := cLocal
        TRB4->UM        := cUM
        TRB4->QUANT     := nQuant  
        TRB4->STATUSL   := cSTATUSL
        TRB4->LOG       := cLogWrite
        TRB4->FILIAL    := xFilial("ZA0")
    	TRB4->DOC       := cDoc            
		TRB4->DOCB7     := cDOCB7     
		TRB4->EMISSA    := dEMISSA  
        TRB4->CUSTO1    := nCUSTO1 
        TRB4->CC        := cCC
        TRB4->NUMSEQ    := cNUMSEQ
        TRB4->TIPO      := cTIPO
        TRB4->LOTE      := cLOTE
        TRB4->SBLOTE    := cSBLOTE
        TRB4->DTVALI    := dDTVALI
        TRB4->ENDERE    := cENDERE
        TRB4->NUMSER    := cNUMSER
        TRB4->PEDIDO    := cPEDIDO
        TRB4->NOTA      := cNOTA
        TRB4->SERIE     := cSERIE
        TRB4->STATUS    := cSTATUS
        TRB4->( msUnlock() ) 
    EndIf
//TRB4->DATA      := cDATA
    GravaPen(cLogWrite)
    
Return()


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
cSTATUSL   := " "

Return 


//==============================================================================================
//Funcao.........:	VerProd(cProduto)
//Descricao......:	Verificar se o Produto está cadastrado
//Autor..........:	A.Oliveira
//Criação........:	23/11/2020
//==============================================================================================
Static Function VerProd(cCod)
    Local cB1cod:= " "
	Local cQy	:= " "
	Local cAlias:= "PRO"

	cQy := " SELECT B1_COD,B1_UM " + CRLF 
	cQy += "  FROM " + RetSQLName("SB1") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND B1_FILIAL = '" + xfilial('SB1') + "' " + CRLF 
	cQy += " AND B1_COD = '"    + cCod + "' " + CRLF  

	TcQuery cQy new Alias (cAlias)

    cB1cod := (cAlias)->B1_COD
    cUM    := (cAlias)->B1_UM
    IF !Empty(cB1cod)
        lRes := .T. 
    ENDIF
	(cAlias)->(DbCloseArea())
Return(lRes)


//==============================================================================================
//Funcao.........:	VldLock()
//Descricao......:	Verificar se o registro na SB2 está liberado.
//Autor..........:	A.Oliveira
//Criação........:	23/11/2020
//==============================================================================================
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



/*/{Protheus.doc} ZESTF004
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	23/11/2020
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


/*/{Protheus.doc} ZESTF004
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	23/11/2020
@return  	NIL
@obs        Impressão Log das Inconsistencias encontradas
@project
@history    
/*/
Static Function ReportDef()
    Local oReport
    Local oSection1
    Local cAlias := 'ZA0'
    
    oReport := TReport():New("IMP","Log",,{|oReport| PrintReport(oReport)},"Este relatorio irá imprimir Log")
    oSection1 := TRSection():New(oReport,OemToAnsi("Log"),{"TRB4"})
 
    TRCell():New(oSection1,"LINHA","TRB4","LINHA","@!",040)
    TRCell():New(oSection1,"STATUSL","TRB4","STATUSL","@!",040)
    TRCell():New(oSection1,"LOG","TRB4","LOG","@!",280)
    TRCell():New(oSection1,"FILIAL","TRB4","FILIAL","@!",040)
    TRCell():New(oSection1,"TM","TRB4","TM",PesqPict(cAlias,"ZA0_TM"),TamSX3("ZA0_TM")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"COD","TRB4","COD",PesqPict(cAlias,"ZA0_COD"),TamSX3("ZA0_COD")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"LOCALI","TRB4","LOCALI",PesqPict(cAlias,"ZA0_LOCAL"),TamSX3("ZA0_LOCAL")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"UM","TRB4","UM",PesqPict(cAlias,"ZA0_UM"),TamSX3("ZA0_UM")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"QUANT","TRB4","QUANT",PesqPict(cAlias,"ZA0_QUANT"),TamSX3("ZA0_QUANT")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"DOC","TRB4","DOC",PesqPict(cAlias,"ZA0_DOC"),TamSX3("ZA0_DOC")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"DOCB7","TRB4","DOCB7",PesqPict(cAlias,"ZA0_DOCB7"),TamSX3("ZA0_DOCB7")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"EMISSA","TRB4","EMISSA",PesqPict(cAlias,"ZA0_EMISSA"),TamSX3("ZA0_EMISSA")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"CUSTO1","TRB4","CUSTO1",PesqPict(cAlias,"ZA0_CUSTO1"),TamSX3("ZA0_CUSTO1")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"CC","TRB4","CC",PesqPict(cAlias,"ZA0_CC"),TamSX3("ZA0_CC")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"NUMSEQ","TRB4","NUMSEQ",PesqPict(cAlias,"ZA0_NUMSEQ"),TamSX3("ZA0_NUMSEQ")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"TIPO","TRB4","TIPO",PesqPict(cAlias,"ZA0_TIPO"),TamSX3("ZA0_TIPO")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"LOTE","TRB4","LOTE",PesqPict(cAlias,"ZA0_LOTE"),TamSX3("ZA0_LOTE")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"SBLOTE","TRB4","SBLOTE",PesqPict(cAlias,"ZA0_SBLOTE"),TamSX3("ZA0_SBLOTE")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"DTVALI","TRB4","DTVALI",PesqPict(cAlias,"ZA0_DTVALI"),TamSX3("ZA0_DTVALI")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"ENDERE","TRB4","ENDERE",PesqPict(cAlias,"ZA0_ENDERE"),TamSX3("ZA0_ENDERE")[1],/*lPixel,{|| (TRB4)->NOTA }*/)    
    TRCell():New(oSection1,"NUMSER","TRB4","NUMSER",PesqPict(cAlias,"ZA0_NUMSER"),TamSX3("ZA0_NUMSER")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
   // TRCell():New(oSection1,"DATA","TRB4","DATA",PesqPict(cAlias,"ZA0_DATA"),TamSX3("ZA0_DATA")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"PEDIDO","TRB4","PEDIDO",PesqPict(cAlias,"ZA0_PEDIDO"),TamSX3("ZA0_PEDIDO")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"NOTA","TRB4","NOTA",PesqPict(cAlias,"ZA0_NOTA"),TamSX3("ZA0_NOTA")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"SERIE","TRB4","SERIE",PesqPict(cAlias,"ZA0_SERIE"),TamSX3("ZA0_SERIE")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"STATUS","TRB4","STATUS",PesqPict(cAlias,"ZA0_STATUS"),TamSX3("ZA0_STATUS")[1],/*lPixel,{|| (TRB4)->NOTA }*/)

    TRCell():New(oSection1,"LINHA","TRB4","LINHA","@!",040)
    TRCell():New(oSection1,"STATUSL","TRB4","STATUSL","@!",040)
    TRCell():New(oSection1,"LOG","TRB4","LOG","@!",280)
    TRCell():New(oSection1,"FILIAL","TRB4","FILIAL","@!",040)
    TRCell():New(oSection1,"TM","TRB4","TM",PesqPict(cAlias,"ZA0_TM"),TamSX3("ZA0_TM")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"COD","TRB4","COD",PesqPict(cAlias,"ZA0_COD"),TamSX3("ZA0_COD")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"LOCALI","TRB4","LOCALI",PesqPict(cAlias,"ZA0_LOCAL"),TamSX3("ZA0_LOCAL")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"UM","TRB4","UM",PesqPict(cAlias,"ZA0_UM"),TamSX3("ZA0_UM")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"QUANT","TRB4","QUANT",PesqPict(cAlias,"ZA0_QUANT"),TamSX3("ZA0_QUANT")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"DOC","TRB4","DOC",PesqPict(cAlias,"ZA0_DOC"),TamSX3("ZA0_DOC")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"DOCB7","TRB4","DOCB7",PesqPict(cAlias,"ZA0_DOCB7"),TamSX3("ZA0_DOCB7")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"EMISSA","TRB4","EMISSA",PesqPict(cAlias,"ZA0_EMISSA"),TamSX3("ZA0_EMISSA")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"CUSTO1","TRB4","CUSTO1",PesqPict(cAlias,"ZA0_CUSTO1"),TamSX3("ZA0_CUSTO1")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"CC","TRB4","CC",PesqPict(cAlias,"ZA0_CC"),TamSX3("ZA0_CC")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"NUMSEQ","TRB4","NUMSEQ",PesqPict(cAlias,"ZA0_NUMSEQ"),TamSX3("ZA0_NUMSEQ")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"TIPO","TRB4","TIPO",PesqPict(cAlias,"ZA0_TIPO"),TamSX3("ZA0_TIPO")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"LOTE","TRB4","LOTE",PesqPict(cAlias,"ZA0_LOTE"),TamSX3("ZA0_LOTE")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"SBLOTE","TRB4","SBLOTE",PesqPict(cAlias,"ZA0_SBLOTE"),TamSX3("ZA0_SBLOTE")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"DTVALI","TRB4","DTVALI",PesqPict(cAlias,"ZA0_DTVALI"),TamSX3("ZA0_DTVALI")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"ENDERE","TRB4","ENDERE",PesqPict(cAlias,"ZA0_ENDERE"),TamSX3("ZA0_ENDERE")[1],/*lPixel,{|| (TRB4)->NOTA }*/)    
    TRCell():New(oSection1,"NUMSER","TRB4","NUMSER",PesqPict(cAlias,"ZA0_NUMSER"),TamSX3("ZA0_NUMSER")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    //TRCell():New(oSection1,"DATA","TRB4","DATA",PesqPict(cAlias,"ZA0_DATA"),TamSX3("ZA0_DATA")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"PEDIDO","TRB4","PEDIDO",PesqPict(cAlias,"ZA0_PEDIDO"),TamSX3("ZA0_PEDIDO")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"NOTA","TRB4","NOTA",PesqPict(cAlias,"ZA0_NOTA"),TamSX3("ZA0_NOTA")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"SERIE","TRB4","SERIE",PesqPict(cAlias,"ZA0_SERIE"),TamSX3("ZA0_SERIE")[1],/*lPixel,{|| (TRB4)->NOTA }*/)
    TRCell():New(oSection1,"STATUS","TRB4","STATUS",PesqPict(cAlias,"ZA0_STATUS"),TamSX3("ZA0_STATUS")[1],/*lPixel,{|| (TRB4)->NOTA }*/)

    oSection1:Cell("LINHA")    :SetHeaderAlign("RIGHT")
    oSection1:Cell("STATUSL")  :SetHeaderAlign("RIGHT")
    oSection1:Cell("LOG")      :SetHeaderAlign("RIGHT")
    oSection1:Cell("FILIAL")   :SetHeaderAlign("RIGHT")        
    oSection1:Cell("TM")       :SetHeaderAlign("RIGHT")
    oSection1:Cell("COD")      :SetHeaderAlign("RIGHT")
    oSection1:Cell("LOCALI")   :SetHeaderAlign("RIGHT")
    oSection1:Cell("UM")       :SetHeaderAlign("RIGHT")
    oSection1:Cell("QUANT")    :SetHeaderAlign("RIGHT")
    oSection1:Cell("DOC")      :SetHeaderAlign("RIGHT")
    oSection1:Cell("DOCB7")    :SetHeaderAlign("RIGHT")
    oSection1:Cell("EMISSA")   :SetHeaderAlign("RIGHT")
    oSection1:Cell("CUSTO1")   :SetHeaderAlign("RIGHT")
    oSection1:Cell("CC")       :SetHeaderAlign("RIGHT")
    oSection1:Cell("NUMSEQ")   :SetHeaderAlign("RIGHT")
    oSection1:Cell("TIPO")     :SetHeaderAlign("RIGHT")
    oSection1:Cell("LOTE")     :SetHeaderAlign("RIGHT")
    oSection1:Cell("SBLOTE")   :SetHeaderAlign("RIGHT")
    oSection1:Cell("DTVALI")   :SetHeaderAlign("RIGHT")
    oSection1:Cell("ENDERE")   :SetHeaderAlign("RIGHT")
    oSection1:Cell("NUMSER")   :SetHeaderAlign("RIGHT")
    //oSection1:Cell("DATA")     :SetHeaderAlign("RIGHT")
    oSection1:Cell("PEDIDO")   :SetHeaderAlign("RIGHT")
    oSection1:Cell("NOTA")     :SetHeaderAlign("RIGHT")
    oSection1:Cell("SERIE")    :SetHeaderAlign("RIGHT")
    oSection1:Cell("STATUS")   :SetHeaderAlign("RIGHT")

Return oReport


/*/{Protheus.doc} ZESTF004
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	23/11/2020
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

    DbSelectArea("TRB4")
    DbGoTop()

    oReport:SetMeter(RecCount())
    oSection1:Init()
    While  !Eof()
        If oReport:Cancel()
            Exit
        EndIf
        oSection1:PrintLine()

        DbSelectArea("TRB4")
        DbSkip()
        oReport:IncMeter()
    EndDo
    oSection1:Finish()

Return
