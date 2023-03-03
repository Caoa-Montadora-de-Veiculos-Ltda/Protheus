#INCLUDE "PROTHEUS.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
#include "totvs.ch"
#include "Fileio.ch"
#define F_BLOCK  512

/*/{Protheus.doc} ZFATF007
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	14/05/2020
@return  	NIL
@obs        Local cMainPath	:= GetMv("CMV_EST001")      
@project
@history    Escrituração Notas Fiscais do SINC
/*/
User Function ZFATF007()  
Local cExtens     := "Arquivo CSV | *.CSV"
Local cMainPath   := "C:\Users\antonio.poliveira\Documents\Desenvolvimento\Tabelas"   //"C:\TEMP"   
Local aPergs      := {}
Local cArq        := ""
Local _dDtFim     := Date()    //Data do parametro
Private _cTipo    := "N"       //Tipo da NF N = Normal
Private _cEspec   := "SPED"    //Especie da NF = Sped
Private _cEspec1  := "VEICULO" //Especie da NF = Veículo
Private _cTES     := "   "     //MV_PAR03   = TES a ser usada na NF 
Private _cFormul  := "S"       //Formulário Proprio = S
Private _cCond    := "   "     //Condição de Pagamento
Private _nItem    := 1
Private aRetP     := {}
Private cLogWrite := " " 
Private cFileOpen := ""
Private cArqLog	  := cMainPath+"\Escrit_"+DTOS(Date())+StrTran(Time(),":")+".LOG"

////U_ZGENUSER( <ID User> , <"NOME DA FUNÇÃO"> , <.F.=Não Exibe Msg; .T.=Exibe Msg> )
IF U_ZGENUSER( RetCodUsr() ,"ZFATF007" ,.T.) = .F. 
   RETURN Nil
ENDIF

aAdd( aPergs ,{1,"Data de Procesamento ",_dDtFim      ,"   ",'.T.',"   " ,'.T.',80,.F.})
aAdd( aPergs ,{6,"Selecione arquivo "   ,cMainPath    ,"@!" ,     ,'.T.' ,80,.T.,cExtens })
aAdd( aPergs ,{1,"Informe a TES "       ,_cTES        ,"@!" ,'.T.',"SF4" ,'.T.',40,.T.})
aAdd( aPergs ,{1,"Cond. Pagamento "     ,_cCond       ,"@!" ,'.T.',"SE4" ,'.T.',40,.F.})

If ParamBox(aPergs, "Parametros ", aRetP, , , , , , , , ,.T.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Importação NF SINC") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza a Importação NF SINC") SIZE 268, 8 OF oDlg PIXEL
   @ 38, 15 SAY OemToAnsi("Da Caoa Montadora.") SIZE 268, 8 OF oDlg PIXEL
   @ 48, 15 SAY OemToAnsi("Confirma Processo ? ") SIZE 268, 8 OF oDlg PIXEL
   DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
   DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
   ACTIVATE MSDIALOG oDlg CENTER

   If nOpca == 0
      Return()
   Endif

   cArq   := ALLTRIM(MV_PAR02)
   _cTES  := ALLTRIM(MV_PAR03)
   _cCond := ALLTRIM(MV_PAR04)
   //cFileOpen := RIGHT(cArq, LEN(cArq) - (RAT(".", cArq)-8) )
   cFileOpen := cArq

   Processa({|| ZFATF007B(cFileOpen,@cArqLog) }, "[ZFATF007] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." )
		
   //MSGINFO( cArqLog,"Final do processamento!" + CRLF+  "Para mais informações, verifique o arquivo de log: " + cArqLog )
	 
Endif

Return Nil 



/*
==============================================================================================
Funcao.........:	ZFATF007B
Descricao......:	Faz a leitura do arquivo CSV e a gravação da tabela 
Autor..........:	A. Oliveira
Criação........:	28/04/2020
Alterações.....:
===============================================================================================
*/
Static Function ZFATF007B(cFileOpen,cArqLog)
Local Primeiro      := .T. 	
Local cSeparador	:= ";"						// Separador do arquivo 	
Local aDados 		:= {}						// Array dos dados da linha do laco
Local aErro         := {} 
Local aDadosLi      := {}
Local _lRetorno     := .T.
Local nRegs         := 0
Local nAtual        := 0
Local nLoop         := 0
Local nX            := 0
Private aArea       := GetArea()
Private _cUser      := Substr(cUserName,1,20)
Private aCabec      := {}
Private aItens      := {}
Private _aStruLog   := {}
Private _cArqTRB    := ""
Private _cIndice    := ""
Private _cChaveInd  := ""
Private _cDoc       := ""
Private cCliente    := ""
Private cLoja       := ""
Private cSerie  	:= ""
Private cCNPJ       := ""
Private cItem       := "" 
Private cProduto    := ""
Private cChave      := "" 
Private cCusto      := "" 
Private cItemCC     := "" 
Private cLocaliz    := "" 
Private nQtde       := 0 
Private nPrceven    := 0 
Private nDesc       := 0
Private nFrete      := 0
Private nSeguro     := 0
Private nDesp       := 0
Private nICMSRET    := 0
Private lAutoErrNoFile := .T.
private lMsErroAuto := .F.

//cArqLog := SubStr(AllTrim(cFileOpen),1,At(".csv",cFileOpen))+"_log_"+StrTran(AllTrim(Time()),":","")+"_.csv"

If Select("TRB1") > 0
    dbSelectArea("TRB1")
    dbCloseArea()
EndIf

AADD(_aStruLog,{"LOG","C",280,0})
AADD(_aStruLog,{"COD","C",023,0}) 

oTempTable := FWTemporaryTable():New( "TRB1" )
oTemptable:SetFields( _aStruLog )
oTempTable:AddIndex("01", {"COD"} )
oTempTable:Create()

dbSelectArea( "TRB1" )
dbSetOrder(1)

FT_FUSE(cFileOpen)
FT_FGOTOP()
FT_FSKIP()

While !FT_FEOF()
    nRegs++   
    cLinha := FT_FREADLN()	
					
    aDados := Separa(cLinha,cSeparador)
    aAdd(aDadosLi, aClone(aDados))

	FT_FSKIP()
END

cEmissao := MV_PAR01
FT_FUSE()

For nLoop := 1 to Len(aDadosLi)
    //Incrementa a mensagem na régua
    nAtual++
    IncProc("Registro " + cValToChar(nAtual) + " de " + cValToChar(nRegs) + "...")

    IF _cDoc = aDadosLi[nLoop][01] .AND. !Primeiro
       _nItem++
    ENDIF

    Primeiro := .F.
    _cDoc       := aDadosLi[nLoop][01]
    cSerie  	:= aDadosLi[nLoop][02]
    cCNPJ       := aDadosLi[nLoop][03]
    cCliente    := aDadosLi[nLoop][04]
    cLoja	    := aDadosLi[nLoop][05]
    cProduto    := aDadosLi[nLoop][06]
    nQtde       := aDadosLi[nLoop][07]
    nPrceven    := aDadosLi[nLoop][08]
    nTotal      := aDadosLi[nLoop][09]
    cChave      := aDadosLi[nLoop][10]
    nDesc       := aDadosLi[nLoop][11]
    nICMSRET    := aDadosLi[nLoop][15]
    //nSeguro     := aDadosLi[nLoop][10]
    //nDesp       := aDadosLi[nLoop][11]
    //nFrete      := aDadosLi[nLoop][12]
   
    nQtde    := VAL(StrTran(nQtde,",","."))
    nPrceven := VAL(StrTran(nPrceven,",","."))
    nTotal   := VAL(StrTran(nTotal,",","."))
    nDesc    := VAL(StrTran(nDesc,",","."))
    nICMSRET := VAL(StrTran(nICMSRET,",","."))  
    cChave   := StrTran(cChave,"="," ")
    cChave   := StrTran(cChave,'"',' ')
    cChave   := Rtrim(cChave)
    cTipo	    := PadR(cTipo,TamSX3("F2_TIPO")[1]," ")  
    cFormul		:= PadR(cFormul,TamSX3("F2_FORMUL")[1]," ")
    _cDoc       := PadL(_cDoc,TamSX3("F2_DOC")[1],"0")
    cSerie  	:= PadR(cSerie,TamSX3("F2_SERIE")[1]," ")
    cCliente   	:= PadR(cCliente,TamSX3("F2_CLIENTE")[1]," ")
    cCNPJ       := PadR(cCNPJ,TamSX3("A1_CGC")[1]," ")
    cLoja	    := PadR(cLoja,TamSX3("F2_LOJA")[1]," ")
    _cEspec     := PadR(_cEspec,TamSX3("F2_ESPECIE")[1]," ")
    _cEspec1    := PadR(_cEspec1,TamSX3("F2_ESPECI1")[1]," ")
    _cCond      := PadR(_cCond,TamSX3("F2_COND")[1]," ") 
    cChave      := PadL(cChave,TamSX3("F1_CHVNFE")[1]," ")
    cProduto    := PadR(cProduto,TamSX3("D2_COD")[1]," ")
    _cTES       := PadR(_cTES,TamSX3("D2_TES")[1]," ")
    cCusto      := PadR(cCusto,TamSX3("D2_CCUSTO")[1]," ") 
    cItemCC     := PadR(cItemCC,TamSX3("D2_ITEMCC")[1]," ") 

    //nDesc       := PadL(nDesc,TamSX3("F2_DESCONT")[1],"0")
    //nFrete      := PadL(nFrete,TamSX3("F2_FRETE")[1],"0")
    //nSeguro     := PadL(nSeguro,TamSX3("F2_SEGURO")[1],"0")
    //nDesp       := PadL(nDesp,TamSX3("F2_DESPESA")[1],"0")
    //nQtde       := PadL(nQtde,TamSX3("D2_QUANT")[1],"0")
    //nPrceven    := PadL(nPrceven,TamSX3("D2_PRCVEN")[1],"0")
    //nTotal      := PadL(nTotal,TamSX3("D2_TOTAL")[1],"0")
    
    cProduto    := Alltrim(cProduto)

    VerProd(cProduto)
    VerTES(_cTES)
    //VerCond(_cCond)
    //VerCli(cCNPJ)

    //IF _lRetorno = .F.
    //   LOOP
    //ENDIF


    If _lRetorno := .T.
        Begin Transaction
        //--*/ Verifica o ultimo documento válido para um fornecedor
        /*dbSelectArea("SF2")
        dbSetOrder(2)
        MsSeek(xFilial("SF2")+Padr("CL0001",Len(SA1->A1_COD))+"01z",.T.)
        dbSkip(-1)  
        cDoc := SF2->F2_DOC
        //For nY := 1 To 10
   
        If Empty(cDoc)
           cDoc := StrZero(1,Len(SD2->D2_DOC))
        Else
           cDoc := Soma1(cDoc)
        EndIf*/

        aCabec := {}
        aItens := {}
        aadd(aCabec,{"F2_TIPO"    ,"N"})
        aadd(aCabec,{"F2_FORMUL"  ,"S"})
        aadd(aCabec,{"F2_DOC"     ,_cDoc})
        aadd(aCabec,{"F2_SERIE"   ,cSerie})
        aadd(aCabec,{"F2_EMISSAO" ,cEmissao})
        aadd(aCabec,{"F2_CLIENTE" ,cCliente})
        aadd(aCabec,{"F2_LOJA"    ,cLoja})
        aadd(aCabec,{"F2_CLIENT"  ,cCliente})
        aadd(aCabec,{"F2_LOJENT"  ,cLoja})
        aadd(aCabec,{"F2_CHVNFE"  ,cChave})
        aadd(aCabec,{"F2_ESPECIE" ,_cEspec})
        aadd(aCabec,{"F2_ESPECI1" ,_cEspec1})
        aadd(aCabec,{"F2_COND"    ,_cCond})
        aadd(aCabec,{"F2_DESCONT" ,nDesc})
        aadd(aCabec,{"F2_FRETE"   ,nFrete})
        aadd(aCabec,{"F2_SEGURO"  ,nSeguro})
        aadd(aCabec,{"F2_DESPESA" ,nDesp})

        For nX := 1 To _nItem
            cItem  := Alltrim(Str(nX))
            cItem  := PadL(cItem,TamSX3("D2_ITEM")[1],"0")
            aLinha := {}
            aadd(aLinha,{"D2_COD"    ,cProduto  ,Nil})
            aadd(aLinha,{"D2_ITEM"   ,cItem     ,Nil})
            aadd(aLinha,{"D2_QUANT"  ,nQtde     ,Nil})
            aadd(aLinha,{"D2_PRCVEN" ,nPrceven  ,Nil})
            aadd(aLinha,{"D2_TOTAL"  ,nTotal    ,Nil})
            aadd(aLinha,{"D2_TES"    ,_cTES     ,Nil})
            aadd(aLinha,{"D2_CCUSTO" ,cCusto    ,Nil})
            aadd(aLinha,{"D2_ITEMCC" ,cItemCC   ,Nil})
            aadd(aLinha,{"D2_LOCALIZ",cLocaliz  ,Nil})
            aadd(aLinha,{"D2_ICMSRET",nICMSRET  ,Nil})
            aadd(aItens,aLinha)
        Next nX
        
        //-- Teste de Inclusao
        //MATA920(aCabec,aItens)
        //Chamando a inclusão automática
		MSExecAuto({|x, y, z| Mata920(x, y, z)}, aCabec, aItens, 3)


        If !lMsErroAuto
            cLogWrite += ("Incluido com sucesso! "+_cDoc) + CRLF
            _lRetorno := .F. 
        Else
            aErro := GetAutoGRLog()
            cLogWrite += " " + Alltrim(AllToChar( aErro[1] )) + " " + _cDoc
        EndIf
        //Next nY

        GERLOG()

	    End Transaction

    EndIf

Next nLoop

cLogWrite += Chr(13) + Chr(10) + (" Doc gerado! " + _cUser + " " + DTOC(DATE()) + " " + Time())
GERLOG()

//Chamada do relatório
dbSelectArea("TRB1")
dbGotop()
If TRB1->(!EOF())
    Processa({|| IMPEXC() },"Gerando Relatorio de Log... "+"[ZFATF007]")
Else
    cBuffer := Space(512)
Endif
RestArea(aArea)

MsgInfo( "Ajuste cadastrado! [ZFATF007] " )

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
    If !dbSeek(cLogWrite)
        RecLock("TRB1",.T.)
        TRB1->COD := cProduto
        TRB1->LOG := cLogWrite
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

Return

/*/{Protheus.doc} ZFATF007
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
        oReport:SetTotalInLine(.F.)
        oReport:PrintDialog()
    EndIf

Return()


/*/{Protheus.doc} ZFATF007
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

    oReport := TReport():New("IMP","Log",,{|oReport| PrintReport(oReport)},"Este relatorio irá imprimir Log")

    oSection1 := TRSection():New(oReport,OemToAnsi("Log"),{"TRB"})

    TRCell():New(oSection1,"LOG","TRB1","LOG","@!",280)
    TRCell():New(oSection1,"COD","TRB1","COD",PesqPict("LOG","COD"),TamSX3("B1_COD")[1],/*lPixel,{|| (TRB1)->NOTA }*/)

    oSection1:Cell("LOG")  :SetHeaderAlign("RIGHT")
    oSection1:Cell("COD")  :SetHeaderAlign("RIGHT")

Return oReport


/*/{Protheus.doc} ZFATF007
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


//==============================================================================================
//Funcao.........:	VerProd(cProduto)
//Descricao......:	Verificar se o Produto está cadastrado
//Autor..........:	A.Oliveira
//Criação........:	13/05/2020
//==============================================================================================
Static Function VerProd(cProduto)
	Local cQy	:= " "
	Local cAlias:= "PRO"

	cQy := " SELECT B1_COD,B1_CC,B1_ITEMCC " + CRLF 
	cQy += "  FROM " + RetSQLName("SB1") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND B1_FILIAL = '" + xFilial("SB1")  + "' " + CRLF 
	cQy += " AND B1_COD    = '" + cProduto + "' " + CRLF 
	TcQuery cQy new Alias (cAlias)

    IF (cAlias)->(EOF())
        cLogWrite += ("Produto " + cProduto + " não cadastrado! ") + CRLF
        GERLOG()
        _lRetorno := .F.   
    ELSE 
        cCusto := (cAlias)->B1_CC
        cItemCC:= (cAlias)->B1_ITEMCC
    ENDIF

	(cAlias)->(DbCloseArea())

Return()

//==============================================================================================
//Funcao.........:	VerTES(MV_PAR03)
//Descricao......:	Verificar se a TES está cadastrado
//Autor..........:	A.Oliveira
//Criação........:	13/05/2020
//==============================================================================================
Static Function VerTES(_cTES)
	Local cQy	:= " "
	Local cAlias:= "TES"

	cQy := " SELECT F4_CODIGO " + CRLF 
	cQy += "  FROM " + RetSQLName("SF4") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND F4_FILIAL = '" + xFilial("SF4")  + "' " + CRLF 
	cQy += " AND F4_CODIGO = '" + _cTES + "' " + CRLF 
	TcQuery cQy new Alias (cAlias)

    IF (cAlias)->(EOF())
        cLogWrite += ("TES " + _cTES + " não cadastrado! ") + CRLF
        GERLOG()
        _lRetorno := .F.    
    ENDIF

	(cAlias)->(DbCloseArea())

Return()


//==============================================================================================
//Funcao.........:	VerCond(cCond)
//Descricao......:	Verificar se a Condição de Pagamento está cadastrado
//Autor..........:	A.Oliveira
//Criação........:	13/05/2020
//==============================================================================================
/*Static Function VerCond(_cCond)
	Local cQy	:= " "
	Local cAlias:= "PGT"

	cQy := " SELECT E4_CODIGO " + CRLF 
	cQy += "  FROM " + RetSQLName("SE4") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND E4_FILIAL = '" + xFilial("SE4")  + "' " + CRLF 
	cQy += " AND E4_CODIGO = '" + _cCond    + "' " + CRLF 
	TcQuery cQy new Alias (cAlias)

    IF (cAlias)->(EOF())
        cLogWrite += ("Condição " + _cCond + " não cadastrada! ") + CRLF
        GERLOG()
        _lRetorno := .F.    
    ENDIF

	(cAlias)->(DbCloseArea())

Return()*/


//==============================================================================================
//Funcao.........:	VerCli(cCliente)
//Descricao......:	Verificar se 0 Cliente está cadastrado
//Autor..........:	A.Oliveira
//Criação........:	13/05/2020
//==============================================================================================
/*Static Function VerCli(cCNPJ)
	Local cQy	:= " "
	Local cAlias:= "LLI"

	cQy := " SELECT A1_COD,A1_LOJA " + CRLF 
	cQy += "  FROM " + RetSQLName("SA1") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND A1_FILIAL = '" + xFilial("SA1")  + "' " + CRLF 
	cQy += " AND A1_CGC    = '" + cCNPJ + "' " + CRLF 
	TcQuery cQy new Alias (cAlias)

    IF (cAlias)->(EOF())
        cLogWrite += ("Cliente " + cCliente + " não cadastrado! ") + CRLF
        GERLOG()
        _lRetorno := .F.    
    ELSE
        cCliente  := (cAlias)->A1_COD
        cLoja	  := (cAlias)->A1_LOJA  
    ENDIF

	(cAlias)->(DbCloseArea())

Return()*/