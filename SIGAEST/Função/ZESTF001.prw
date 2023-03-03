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
/*/{Protheus.doc} ZESTF001
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	28/04/2020
@return  	NIL
@obs        Local cMainPath	:= GetMv("CMV_EST001")      
@project
@history    Importar ajustes de CM por Produto da planilha excel (gatilhado preco unit)
/*/
User Function ZESTF001()  
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
Private cLogWrite := " " 
Private cStatus   := ""
Private cFileOpen := ""
Private cArqLog	  := cMainPath+"\AJUSCM_"+DTOS(Date())+StrTran(Time(),":")+".LOG"

////U_ZGENUSER( <ID User> , <"NOME DA FUNÇÃO"> , <.F.=Não Exibe Msg; .T.=Exibe Msg> )
IF U_ZGENUSER( RetCodUsr() ,"ZESTF001" ,.T.) = .F. 
   RETURN Nil
ENDIF

aAdd( aPergs ,{1,"Data de Procesamento ",_dDtFim      ,"   ","U_TestaDT()","   " ,'.T.',80,.F.})
aAdd( aPergs ,{6,"Selecione arquivo "   ,cMainPath    ,"@!" ,     ,'.T.' ,80,.T.,cExtens })

If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Importação Ajustes Custos") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza a Importação Ajustes Custos") SIZE 268, 8 OF oDlg PIXEL
   @ 38, 15 SAY OemToAnsi("Conforme layout:  D3_PRODUTO,D3_LOCAL,D3_CUSTO1,D3_VALUNIT") SIZE 268, 8 OF oDlg PIXEL
   @ 48, 15 SAY OemToAnsi("Confirma Processo ? ") SIZE 268, 8 OF oDlg PIXEL
   DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
   DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
   ACTIVATE MSDIALOG oDlg CENTER

   If nOpca == 0
      Return()
   Endif

   cArq := ALLTRIM(MV_PAR02)

   cFileOpen := cArq

   Processa({|| ZESTF001B(cFileOpen,@cArqLog) }, "[ZESTF001] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." )
		
   MSGINFO( "Final do processamento!" + CRLF +  "Para mais informações, verifique o arquivo de log: " + cArqLog )
	 
Endif

Return Nil 


User Function TestaDT()
    IF _dFecha > MV_PAR01
    	MsgInfo("Data de Processmanto menor que o Fechamento! ","ZESTF001")
        _lRetorno := .T.
    Endif
    IF _dFecha1 > MV_PAR01
    	MsgInfo("Data de Processmanto menor que o Fechamento! ","ZESTF001")
        _lRetorno := .T.
    Endif
Return(_lRetorno)


/*
==============================================================================================
Funcao.........:	ZESTF001B
Descricao......:	Faz a leitura do arquivo CSV e a gravação da tabela 
Autor..........:	A. Oliveira
Criação........:	28/04/2020
Alterações.....:    //4110108106  caso precise fixar conta contábil
===============================================================================================
*/
Static Function ZESTF001B(cFileOpen,cArqLog)
Local aDados 		:= {}						// Array dos dados da linha do laco
Local aDadosLi      := {}
Local nPasso        := 0
Local nLoop         := 0
Local nTotal        := 0
Local cSepar        := ""
//Local lMovitou      := .F.
Private nAtual      := 0
Private nValUn      := 0
Private cProduto	:= ""
Private cLocal    	:= ""
Private cCCC      	:= ""
Private cConta		:= ""
Private cUM         := ""
Private cDoc  		:= ""
Private nQuant 		:= 0
Private nCusto 		:= 0
Private nCusto1		:= 0
Private dDtRet      := 0
Private cTM    		:= ""
Private cNumSeq     := ""
Private cObserva    := "" 
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
AADD(_aStruLog,{"STATUS"     ,"C",010,0})
AADD(_aStruLog,{"LOG"        ,"C",280,0})
AADD(_aStruLog,{"FILIAL"     ,"C",010,0})
AADD(_aStruLog,{"COD"        ,"C",023,0})
AADD(_aStruLog,{"DOC"        ,"C",009,0})
AADD(_aStruLog,{"UM"         ,"C",002,0})
AADD(_aStruLog,{"QUANT"      ,"N",013,3})
AADD(_aStruLog,{"CUSTO"      ,"N",014,2})
AADD(_aStruLog,{"CUSTO1"     ,"N",014,2})    
AADD(_aStruLog,{"ARMAZEM"    ,"C",003,0})
AADD(_aStruLog,{"TM"         ,"C",003,0})  
AADD(_aStruLog,{"CONTA"      ,"C",020,0})      
AADD(_aStruLog,{"CC"         ,"C",011,0})
AADD(_aStruLog,{"NUMSEQ"     ,"C",006,0})    
AADD(_aStruLog,{"EMISSAO"    ,"D",008,0})           
AADD(_aStruLog,{"OBSERVA"    ,"C",240,0})              
	      
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

FT_FUSE(cFileOpen)
FT_FGOTOP()
cLinha := FT_FREADLN()
cSepar := Substr(cLinha,11,1)
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

For nLoop := 1 to Len(aDadosLi)
    
    lRes  := .F. //Inicializa a validação do produto

    IF Alltrim(cProduto) == Alltrim(aDadosLi[nLoop][01])
        cLogWrite += ("Erro Produto em Duplicidade na Planilha! Só será importado 01. " )
        cStatus := " Erro "
        GERLOG()  
       LOOP
    ENDIF

    nAtual++

    IncProc("Registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

    cProduto	:= Alltrim(aDadosLi[nLoop][01])     //Posição 01 Produto
    cLocal		:= aDadosLi[nLoop][02]              //Posição 02 Armazém
    nCusto      := VAL(aDadosLi[nLoop][03])         //Posição 03 Valor Total
    nValUn      := VAL(aDadosLi[nLoop][04])         //Posição 04 Valor Unitário
    nCusto1     := nCusto
    cTM    	    := PadR(cTM,TamSX3("D3_TM")[1]," ")
    cCCC        := PadR(cCCC,TamSX3("D3_CC")[1]," ")
    cConta	    := PadR(cConta,TamSX3("D3_CONTA")[1]," ")
    cProduto    := PadR(cProduto,TamSX3("B1_COD")[1]," ")

    IF nCusto = 0 .OR. nValUn = 0 
        cLogWrite := ("Erro Produto com ajuste zerado não será importado. " )
        cStatus := " Erro "
        GERLOG()  
       LOOP
    ENDIF

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica se existe  Produto ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    IF !EMPTY(cProduto)

        VerProd(cProduto)
        VerCCus(cCCC)
        VerArm(cProduto)  //SB9  

        IF cCCC = Space(11) .OR. CTT->CTT_BLOQ = "1"
            cCCC := '33530177MA' 
        ENDIF

        IF nCusto1 < 0
            nCusto1 := nCusto1 * (-1)
            cTM := '555'
        ELSE
            cTM := '444'
        Endif

        cObserva := "ZESTF001 " + _cUser + " " + Dtoc(Date()) + " " + Time()
        cLocal	 := PadR(cLocal,TamSX3("D3_LOCAL")[1]," ")
        cNumSeq  := PadL(cNumSeq,TamSX3("D3_NUMSEQ ")[1]," ")
        nPasso   := 0

        IF lRes = .T.
            cObserva += " R.SB9"
            GrvProd()  //Se T OK Grava o registro
            Loop 
        ELSE
            VerEnt(cProduto)  //SD1 
            IF lRes = .T.
                cObserva += " R.SD1"
                GrvProd()  //Se T OK Grava o registro
                Loop 
            ELSE
                //cLogWrite := ("Erro Produto sem Saldo Inicial e Nota Fiscal! Executar a rotina: Reavaliação de custos. " )
                //cStatus := " Erro "
                //GERLOG()
            Endif

            VerInv(cProduto)

            IF lRes = .T.
                nCusto1  := (nValUn * nQuant)          //Posição 04 Valor Unitário * a quantidade inventariada
                nCusto   := nValUn
                cObserva += " R.SD3"
                GrvProd()  //Se T OK Grava o registro
                //cLogWrite := " Item entrou no SINC no Protheus inventario." 
                cStatus := " OK "
                GERLOG()
                Loop 
            //ELSE
            //    cLogWrite := " Item entrou no SINC c/ estoque e no Protheus sem (TM '499/599')." 
            //    cStatus := " Erro "
            //    GERLOG()
            Endif

        EndIf

    ENDIF

Next nLoop



//*********************************************************************
//      Chamada do relatório
//*********************************************************************
    dbSelectArea("TRB1")
    dbGotop()
    If TRB1->(!EOF())
        Processa({|| IMPEXC() },"Gerando Relatorio de Log... "+"[ZESTF001]")
    Else
        cBuffer := Space(512)
    Endif
    RestArea(aArea) 
    FT_FUSE()

Return()


//==============================================================================================
//Funcao.........:	GrvProd()
//Descricao......:	Gravar o registro da SD3   13068560
//Autor..........:	A.Oliveira
//Criação........:	13/05/2020
//==============================================================================================
Static Function GrvProd()
Local aErro     := {} 
Local aVetor    := {}
Local nOpc      := 3
Local cNtEr     := 0
    Begin Transaction

		aVetor := {}
        cDoc := NextNumero("SD3",2,"D3_DOC",.T.)  //BUSCA NUMERACAO DO SD3

        aadd( aVetor, { "D3_FILIAL" , '2010022001'  , Nil } )
		aadd( aVetor, { "D3_DOC"    , cDoc          , Nil } )
		aadd( aVetor, { "D3_COD"    , cProduto      , Nil } )   //cProduto
		aadd( aVetor, { "D3_UM"     , cUM           , Nil } )   //cUM
		aadd( aVetor, { "D3_QUANT"  , 0             , Nil } )
        aadd( aVetor, { "D3_CUSTO1" , nCusto1       , Nil } )
		aadd( aVetor, { "D3_LOCAL"  , cLocal        , Nil } )   //cLocal
		aadd( aVetor, { "D3_TM"     , cTM           , Nil } )   //cTM
        aadd( aVetor, { "D3_CONTA"  , cConta        , Nil } ) 
        aadd( aVetor, { "D3_CC"     , cCCC          , Nil } )
        aadd( aVetor, { "D3_NUMSEQ ", cNumSeq       , Nil } ) 
		aadd( aVetor, { "D3_EMISSAO", aRetp[1]      , Nil } )
		aadd( aVetor, { "D3_OBSERVA", cObserva      , Nil } )
        //aadd( aVetor, { "D3_SERVIC" , '101'         , Nil } )
		MSExecAuto( { |x,y| MATA240( x , y ) }, aVetor, nOpc )
		
		If lMsErroAuto
            aErro := GetAutoGRLog()
            cStatus := " Erro "

			For cNtEr := 1 To Len(aErro)
				cLogWrite += AllTrim(aErro[cNtEr]) + chr(13) + chr(10)
			Next
			//cLogWrite += "-----------------------------------------------" + chr(13) + chr(10)
		Else
            cLogWrite := ( " Cadastrado! " )
            cStatus := " OK "
            cNumSeq := SD3->D3_NUMSEQ 
            //_lRetorno := .T.
        Endif
        GERLOG()
	End Transaction

Return()




/*/{Protheus.doc} ZCOMF006
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/05/2020
@return  	NIL
@obs        Grava log das inconsistencias encontradas
@project
@history
/*/
Static Function GERLOG()
    dbSelectArea("TRB1")
    IF cStatus = " Erro "
        RecLock("TRB1",.T.)
        TRB1->Linha     := StrZero(nAtual,6) 
        TRB1->COD       := cProduto        
	    TRB1->ARMAZEM   := cLocal
        TRB1->CUSTO1    := nCusto1
        TRB1->STATUS    := cStatus
        TRB1->LOG       := cLogWrite
        TRB1->( msUnlock() )
    ELSE
        RecLock("TRB1",.T.)
        TRB1->Linha     := StrZero(nAtual,6) 
        TRB1->COD       := cProduto
        TRB1->ARMAZEM   := cLocal
        TRB1->CUSTO     := nCusto
        TRB1->CUSTO1    := nCusto1
        TRB1->STATUS    := cStatus
        TRB1->LOG       := cLogWrite
        TRB1->FILIAL    := xFilial("SD3")
        TRB1->DOC       := cDoc
        TRB1->UM        := cUM       
		TRB1->QUANT     := nQuant            
        TRB1->TM        := cTM           
        TRB1->CONTA     := cConta        
        TRB1->CC        := cCCC    
        TRB1->NUMSEQ    := cNUMSEQ     
		TRB1->EMISSAO   := aRetp[1]        
		TRB1->OBSERVA   := cObserva      
        TRB1->( msUnlock() )
    Endif
    
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
cStatus   := " "

Return 


//==============================================================================================
//Funcao.........:	VerProd(cProduto)
//Descricao......:	Verificar se o Produto está cadastrado
//Autor..........:	A.Oliveira
//Criação........:	13/05/2020
//==============================================================================================
Static Function VerProd(cProduto)
	Local nRes	:= .T. 
	Local cQy	:= " "
	Local cAlias:= "PRO"

	cQy := " SELECT B1_COD,B1_CONTA,B1_CC,B1_UM " + CRLF 
	cQy += "  FROM " + RetSQLName("SB1") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND B1_FILIAL = '" + xfilial('SB1') + "' " + CRLF 
	cQy += " AND B1_COD = '"    + cProduto + "' " + CRLF  

	TcQuery cQy new Alias (cAlias)

    cConta  := (cAlias)->B1_CONTA
    cCCC    := (cAlias)->B1_CC
    cUM     := (cAlias)->B1_UM

	(cAlias)->(DbCloseArea())
Return(nRes)


//==============================================================================================
//Funcao.........:	VerCCus(cCCC)
//Descricao......:	Verificar se o Centro de Custo está cadastrado
//Autor..........:	A.Oliveira
//Criação........:	13/05/2020
//==============================================================================================
Static Function VerCCus(cCCC)
	Local nRes	:= .T. 
	Local cQy	:= " "
	Local cAlias:= "CCC"

	cQy := " SELECT CTT_CUSTO,CTT_BLOQ " + CRLF 
	cQy += "  FROM " + RetSQLName("CTT") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND CTT_FILIAL = '" + xfilial('CTT') + "' " + CRLF 
	cQy += " AND CTT_CUSTO = '" + cCCC    + "' " + CRLF  

	TcQuery cQy new Alias (cAlias)

    cCCC   := (cAlias)->CTT_CUSTO
    _cBlq  := (cAlias)->CTT_BLOQ

	(cAlias)->(DbCloseArea())
Return(nRes)


//==============================================================================================
//Funcao.........:	VldLock()
//Descricao......:	Verificar se o registro na SB2 está liberado.
//Autor..........:	A.Oliveira
//Criação........:	13/05/2020
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


//==============================================================================================
//Funcao.........:	VerArm(cProduto)
//Descricao......:	Verificar se o Produto está no armazém SB9
//Autor..........:	A.Oliveira
//Criação........:	13/05/2020
//==============================================================================================
Static Function VerArm(cProduto)
    Local cLocB9:= ""
	Local cQy	:= " "
	Local cAlias:= "ARM"

	cQy := " SELECT B9_FILIAL,B9_COD,B9_LOCAL,B9_DATA,B9_QINI " + CRLF 
	cQy += "  FROM " + RetSQLName("SB9") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND B9_FILIAL = '" + xfilial('SB9') + "' " + CRLF 
	cQy += " AND B9_COD    = '" + cProduto + "' " + CRLF  

	TcQuery cQy new Alias (cAlias)

    cLocB9 := (cAlias)->B9_LOCAL

    IF !Empty(cLocB9)
        lRes := .T.        
    ENDIF

	(cAlias)->(DbCloseArea())
Return(lRes)


//==============================================================================================
//Funcao.........:	VerEnt(cProduto)
//Descricao......:	Verificar se o Produto entrou via NF
//Autor..........:	A.Oliveira
//Criação........:	13/05/2020
//==============================================================================================
Static Function VerEnt(cProduto)
	Local cQy	:= " "
	Local cAlias:= "ENT"

	cQy := " SELECT D1_COD,D1_TES,D1_EMISSAO,D1_DOC,F4_CODIGO " + CRLF 
	cQy += "  FROM " + RetSQLName("SD1") + " D1" + CRLF 
	cQy += "  INNER JOIN " + CRLF    
    cQy += RetSqlName("SF4") + " F4 " + CRLF
    cQy += "  ON D1.D1_TES = F4.F4_CODIGO " + CRLF 
    cQy += "  AND F4.F4_ESTOQUE = 'S' " + CRLF    
    cQy += "  AND F4.D_E_L_E_T_ <> '*' " + CRLF   
	cQy += " WHERE " + CRLF 
	cQy += " 	D1.D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND D1.D1_FILIAL  = '" + xFilial('SD1') + "' " + CRLF 
    cQy += " AND D1.D1_EMISSAO = '" + Dtos(aRetp[1]) + "' " + CRLF 
	cQy += " AND D1.D1_COD = '" + cProduto + "' " + CRLF  

	TcQuery cQy new Alias (cAlias)

    IF !Empty((cAlias)->D1_COD)
        lRes := .T. 
    EndIf

	(cAlias)->(DbCloseArea())
Return(lRes)


//==============================================================================================
//Funcao.........:	VeriNV(cProduto)
//Descricao......:	Verificar se o Produto entrou via Inventário
//Autor..........:	A.Oliveira
//Criação........:	13/05/2020
//==============================================================================================
Static Function VerInv(cProduto)
	Local cQy	:= " "
	Local cAlias:= "INV"
    nQuant := 00
	cQy := " SELECT D3_COD,D3_QUANT,D3_TM,D3_LOCAL,D3_EMISSAO " + CRLF 
    cQy += "          FROM " + RetSQLName("SD3") + " D3" + CRLF 
    cQy += "  WHERE D3.D_E_L_E_T_ = ' ' " + CRLF 
    cQy += "          AND D3.D3_TM IN ('499','599') " + CRLF 
    cQy += "          AND D3.D3_EMISSAO BETWEEN '" + DTOS(aRetp[1]) + "' AND '" + DTOS(LastDay(aRetp[1])) + "'" + CRLF 
    cQy += "          AND D3.D3_COD = '" + cProduto + "' " + CRLF 
    cQy += "          AND D3_ESTORNO = ' ' " + CRLF
    cQy += "          AND ROWNUM = 1 " + CRLF 
    cQy += "          ORDER BY D3.D3_NUMSEQ ASC " + CRLF 

	TcQuery cQy new Alias (cAlias)

    IF !Empty((cAlias)->D3_QUANT)
        nQuant := (cAlias)->D3_QUANT
        lRes := .T. 
    EndIf

	(cAlias)->(DbCloseArea())
Return(lRes)



/*/{Protheus.doc} ZESTF001
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/05/2020
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


/*/{Protheus.doc} ZESTF001
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/05/2020
@return  	NIL
@obs        Impressão Log das Inconsistencias encontradas
@project
@history
/*/
Static Function ReportDef()
    Local oReport
    Local oSection1
    Local cAlias := 'SD3'
    
    oReport := TReport():New("IMP","Log",,{|oReport| PrintReport(oReport)},"Este relatorio irá imprimir Log")
    oSection1 := TRSection():New(oReport,OemToAnsi("Log"),{"TRB"})

    TRCell():New(oSection1,"LINHA","TRB1","LINHA","@!",040)
    TRCell():New(oSection1,"COD","TRB1","COD",PesqPict(cAlias,"D3_COD"),TamSX3("D3_COD")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"ARMAZEM","TRB1","ARMAZEM",PesqPict(cAlias,"D3_LOCAL"),TamSX3("D3_LOCAL")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"CUSTO","TRB1","CUSTO",PesqPict(cAlias,"D3_CUSTO1"),TamSX3("D3_CUSTO1")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"CUSTO1","TRB1","CUSTO1",PesqPict(cAlias,"D3_CUSTO1"),TamSX3("D3_CUSTO1")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"STATUS","TRB1","STATUS","@!",040)
    TRCell():New(oSection1,"LOG","TRB1","LOG","@!",280)
    TRCell():New(oSection1,"FILIAL","TRB1","FILIAL","@!",040)
    TRCell():New(oSection1,"DOC","TRB1","DOC",PesqPict(cAlias,"D3_DOC"),TamSX3("D3_DOC")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"UM","TRB1","UM",PesqPict(cAlias,"D3_UM"),TamSX3("D3_UM")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"QUANT","TRB1","QUANT",PesqPict(cAlias,"D3_QUANT"),TamSX3("D3_QUANT")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"TM","TRB1","TM",PesqPict(cAlias,"D3_TM"),TamSX3("D3_TM")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"CONTA","TRB1","CONTA",PesqPict(cAlias,"D3_CONTA"),TamSX3("D3_CONTA")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"CC","TRB1","CC",PesqPict(cAlias,"D3_CC"),TamSX3("D3_CC")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"NUMSEQ","TRB1","NUMSEQ",PesqPict(cAlias,"D3_NUMSEQ"),TamSX3("D3_NUMSEQ")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"EMISSAO","TRB1","EMISSAO",PesqPict(cAlias,"D3_EMISSAO"),TamSX3("D3_EMISSAO")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"OBSERVA","TRB1","OBSERVA",PesqPict(cAlias,"D3_OBSERVA"),TamSX3("D3_OBSERVA")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    
    oSection1:Cell("LINHA")    :SetHeaderAlign("RIGHT")
    oSection1:Cell("COD")      :SetHeaderAlign("RIGHT")
    oSection1:Cell("ARMAZEM")  :SetHeaderAlign("RIGHT")
    oSection1:Cell("CUSTO")    :SetHeaderAlign("RIGHT")
    oSection1:Cell("CUSTO1") :SetHeaderAlign("RIGHT")
    oSection1:Cell("STATUS")   :SetHeaderAlign("RIGHT")
    oSection1:Cell("LOG")      :SetHeaderAlign("RIGHT")
    oSection1:Cell("FILIAL")   :SetHeaderAlign("RIGHT")
    oSection1:Cell("DOC")      :SetHeaderAlign("RIGHT")
    oSection1:Cell("UM")       :SetHeaderAlign("RIGHT")
    oSection1:Cell("QUANT")    :SetHeaderAlign("RIGHT")
    oSection1:Cell("TM")       :SetHeaderAlign("RIGHT")
    oSection1:Cell("CONTA")    :SetHeaderAlign("RIGHT")
    oSection1:Cell("CC")       :SetHeaderAlign("RIGHT")
    oSection1:Cell("NUMSEQ")   :SetHeaderAlign("RIGHT")
    oSection1:Cell("EMISSAO")  :SetHeaderAlign("RIGHT")
    oSection1:Cell("OBSERVA")  :SetHeaderAlign("RIGHT")
    
Return oReport


/*/{Protheus.doc} ZESTF001
@param  	
@author 	A. Oliveira
@version  	P12.1.25
@since  	05/05/2020
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
