#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'parmtype.ch'
/*/{Protheus.doc} U_ZFATF008  
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	23/07/20
@return  	SX1 pergunta "ZFATF008  "
@obs       
@project
@history    carrega dados do CSV para o PV - Ativo guardando no SX1
/*/
User Function ZFATF008()
Local _aArea      := GetArea()
Local aPergs      := {}
Local cTitulo1    := "Selecione o arquivo para Carga "
Local cExtens     := "Arquivo CSV | *.CSV"
Local cFileOpen   := ""
Private aTxtLog   := {}
Private cMainPath := "C:\IMPORT"
Private cArqLog   := cMainPath+"\IMPPVA_"+DTOS(Date())+StrTran(Time(),":")+".LOG"
Private nOpc      := 3
Private lRes	   := .T. 
Private aRetP     := {}
Private MDatFat   := dDataBase
Private cCliente  := space(06)
Private cLoja     := space(02)
Private cCondPag  := space(03)
Private cTipocli  := space(01)
Private cTrans    := space(06)
Private cLocal    := space(03)
Private cSolicit  := space(25)
Private cAtivo    := space(25)
Private cChassi   := space(25)
Private cXMENSER  := space(250)
Private _cFilial  := cFilAnt
Private _cTipo    := "N"
Private _cTes     := space(03)
Private _cOperac  := space(02)
Private _cCusto   := space(11)
Private cCLVL     := space(11)
Private cLocaliz  := space(20)
Private aFrete    := {"C=CIF","F=FOB","T=Por conta terceiros","R=Por conta remetente","D=Por conta destinat·rio","S=Sem frete"}
Private nFrete    := 1
Private cTpFrete  := Space(01)
Private cConta    := space(20)
Private cItemCta  := space(11)
Private cDescri   := ""
Private cUm       := ""
Private CFOP      := ""
Private cProduto	:= space(23)
Private nQtdven 	:= 0
Private _nPunit 	:= 0
Private _cPerg    := "ZFATF008  "

aAdd( aPergs ,{1,"Cliente         ",cCliente   ,"@!",'.T.',"SA1"   ,'.T.',40,.T., ,.F.})
aAdd( aPergs ,{1,"Loja            ",cLoja      ,"@!",'.T.',"SA1G4A",'.T.',25,.T., ,.F.})
aAdd( aPergs ,{1,"Cond Pag        ",cCondpag   ,"@!",'.T.',"SE4"   ,'.T.',40,.T., ,.F.})
aAdd( aPergs ,{1,"TES             ",_cTes      ,"@!",'.T.',"SF4"   ,'.T.',25,.T., ,.F.})
aAdd( aPergs ,{1,"Tipo Operaùùo   ",_cOperac   ,"@!",'.T.'," "     ,'.T.',25,.T., ,.F.})
aAdd( aPergs ,{1,"Centro de Custo ",_cCusto    ,"@!",'.T.',"CTT"   ,'.T.',80,.T., ,.F.})
aAdd( aPergs ,{1,"Conta Contabil  ",cConta     ,"@!",'.T.',"CT1"   ,'.T.',40,.T., ,.F.})
aAdd( aPergs ,{1,"Classe Valor    ",cCLVL      ,"@!",'.T.',"CTH"   ,'.T.',40,.T., ,.F.})
aAdd( aPergs ,{1,"Endereùo        ",cLocaliz   ,"@!",'.T.'," "     ,'.T.',80,.T., ,.F.})
aAdd( aPergs ,{2,"Tipo Frete      ",nFrete     ,aFrete                   ,90,".T.",.F.})

   If ParamBox(aPergs, "Parametros ", @aRetP) = .T.     //, , , , , , , ,.F.,.F.)  

      DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Importaùùo dados para o PV") PIXEL
      @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
      @ 29, 15 SAY OemToAnsi("Conforme layout:") SIZE 268, 8 OF oDlg PIXEL
      @ 38, 15 SAY OemToAnsi("C6_PRODUTO,C6_QTDE,C6_VALUNIT,ATIVO,SOLICITANTE,C6_CHASSI") SIZE 268, 8 OF oDlg PIXEL
      @ 48, 15 SAY OemToAnsi("Confirma Geraùùo do Documento ? ") SIZE 268, 8 OF oDlg PIXEL
      DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
      DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
      ACTIVATE MSDIALOG oDlg CENTER

      If nOpca == 0
         Return()
      Endif

      cCliente  := PadL( AllTrim( aRetP[1] ) , TamSX3( "C5_CLIENTE")[1]," ")
      cLoja     := PadL( AllTrim( aRetP[2] ) , TamSX3( "C5_LOJACLI")[1]," ")
      cCondpag  := PadL( AllTrim( aRetP[3] ) , TamSX3( "C5_CONDPAG")[1]," ")
      _cTes     := PadL( AllTrim( aRetP[4] ) , TamSX3( "C6_TES"    )[1]," ")
      _cOperac  := PadL( AllTrim( aRetP[5] ) , TamSX3( "C6_OPER"   )[1]," ")
      _cCusto   := PadR( AllTrim( aRetP[6] ) , TamSX3( "C6_CC"     )[1]," ")
      cConta    := PadR( AllTrim( aRetP[7] ) , TamSX3( "C6_CONTA"  )[1]," ")
      cCLVL     := PadR( AllTrim( aRetP[8] ) , TamSX3( "C6_CLVL"   )[1]," ")
      cLocaliz  := PadR( AllTrim( aRetP[9] ) , TamSX3( "C6_LOCALIZ")[1]," ")
      cTpFrete  := aRetP[10] 
      If ValType(aRetP[10]) == "N"
         If aRetP[10] == 1
            cTpFrete  := "C"
         EndIf
      EndIf
      /*
      ElseIf nFrete == 2
         cTpFrete  := "F"
      ElseIf nFrete == 3
         cTpFrete  := "T"
      ElseIf nFrete == 4
         cTpFrete  := "R"
      ElseIf nFrete == 5
         cTpFrete  := "D"
      ElseIf nFrete == 6
         cTpFrete  := "S"
      EndIf
      */
      cTrans  := If(cTpFrete == "C" .Or. cTpFrete == "F" , "000005","")
   ELSE
      Return()
   EndIf

   IF U_ZGENUSER( RetCodUsr() ,"ZFATF008"	,.T.) = .F. 
	   RETURN Nil
   ENDIF
    
   cFileOpen := cGetFile(cExtens,cTitulo1,,cMainPath,.T.)
   If !File(cFileOpen)
      MsgAlert("Arquivo CSV: " + cFileOpen + " nùo localizado","[ZFATF008] - Atenùùo")
   Else 

      Processa({|| ZFAT008B(cFileOpen,@cArqLog) }, "[ZFATF008] - Carga de Dados.", "Aguarde .... Realizando a carga dos registros...." )
         
      MSGINFO( "Final do processamento !!!" + CRLF +  "Para mais informaùùes, verifique o arquivo de log: " + cArqLog )
      
   Endif

   // Zera os Vetores
   aPergs := {}
	aRetP  := {}

RestArea(_aArea)
Return()


/*
==============================================================================================
Funcao.........:	ZFAT008B
Descricao......:	Faz a leitura do arquivo CSV e a gravaùùo da tabela 
Autor..........:	A. Oliveira
Criaùùo........:	24/07/2020
Alteraùùes.....:
===============================================================================================
*/
Static Function ZFAT008B(cFileOpen,cArqLog)
Local aDados 		     := {}						// Array dos dados da linha do txt
Local aDadosLi         := {}                 // Array dos dados da linha do laco
Local aCab             := {}                 // Array do cabeùalho do PV
Local aReg             := {}                 // Array do itens do PV
Local aItens		     := {}                 // Array para clonar o aReg
Local aErroAuto        := {}                 // Array de erros
Local cSepar    	     := ""						// Separador do arquivo 
Local cItem 		     := "00"
Local nLoop            := 0
Local nTotal           := 0
Local nCount           := 0
//Local nPosarray      := 0
//Local cLocliz        := ""
Local _aArea           := GetArea()
Private _cLogWrite     := ""
Private _aStruLog      := {}
Private _cStatus       := ""
Private _cArqTRB       := ""
Private _cIndice       := ""
Private _cChaveInd     := ""
Private lAutoErrNoFile := .T.
Private lMsErroAuto    := .F.
Private nAtual         := 0

ProcRegua(311)
IncProc()

AADD(_aStruLog,{"LINHA"      ,"C",006,0})
AADD(_aStruLog,{"STATUS"     ,"C",010,0})
AADD(_aStruLog,{"LOG"        ,"C",280,0})
AADD(_aStruLog,{"FILIAL"     ,"C",010,0})
AADD(_aStruLog,{"TIPO"       ,"C",001,0})
AADD(_aStruLog,{"CLIENTE"    ,"C",006,0})
AADD(_aStruLog,{"LOJA"       ,"C",002,0})
AADD(_aStruLog,{"CONDPAG"    ,"C",003,0})
AADD(_aStruLog,{"PRODUTO"    ,"C",023,0})
AADD(_aStruLog,{"QTDE"       ,"N",014,2})    
AADD(_aStruLog,{"VALUNIT"    ,"N",014,2})
AADD(_aStruLog,{"CHASSI"     ,"C",025,0}) 
AADD(_aStruLog,{"NUMSERI"    ,"C",025,0})  
AADD(_aStruLog,{"ATIVO"      ,"C",025,0})  
AADD(_aStruLog,{"SOLICIT"    ,"C",025,0})      
AADD(_aStruLog,{"EMISSAO"    ,"D",008,0}) 


If Select("TRB1") > 0
    dbSelectArea("TRB1")
    dbCloseArea()
EndIf

/*
///TCDelFile(_cArqTRB)

_cArqTRB   := Criatrab(_aStruLog,.T.)
_cIndice   := CriaTrab(Nil,.F.)
_cChaveInd := "LINHA"

dbCreate( _cArqTRB , _aStruLog , "TOPCONN" )
dbUseArea( .T., __LocalDriver, _cArqTRB , "TRB1", .F., .F. )
dbCreateIndex( _cArqTRB ,_cChaveInd )
*/

oTempTable := FWTemporaryTable():New( "TRB1" )
oTemptable:SetFields( _aStruLog )
oTempTable:AddIndex("01", {"LINHA"} )
oTempTable:Create()
dbSelectArea( "TRB1" )
dbSetOrder(1)

FT_FUSE(cFileOpen)
FT_FGOTOP()

cLinha := FT_FREADLN()
cSepar := Substr(cLinha,11,1)

If !(cSepar $ (";,"))
   MsgInfo("Separador do arquivo invalido!!! " + cSepar)
   _cLogWrite := ("Erro Separador do arquivo invalido! ")
   _cStatus   := " Erro "
   GERLOG()
   FT_FUSE()
   Return
ENDIF

VerCli(cCliente,cLoja)

IF lRes = .F.
   FT_FUSE()
   Return
ENDIF

VerCond(cCondpag)

IF lRes = .F.
   FT_FUSE()
   Return
ENDIF

FT_FSKIP()
	 
While !FT_FEOF()
   nTotal++ 

   IF nTotal > 299
      MsgInfo("O limite permitido para inserùùo de itens em um PV ù de 300." , " [ZFATF008]")
      EXIT
	ENDIF 

   cLinha := FT_FREADLN()
					
   aDados := Separa(cLinha,cSepar)
   aAdd(aDadosLi, aClone(aDados))

	FT_FSKIP(1)
END

FT_FUSE()
ProcRegua(nTotal)

//Begin Transaction

For nLoop := 1 to Len(aDadosLi)

   cProduto:= PadR( AllTrim( aDadosLi[nLoop][01] ) , TamSX3( "C6_PRODUTO" )[1]," ") //Posiùùo 01 do lay-out
   
   VerProd(cProduto)

   IF lRes = .F.
      FT_FUSE()
      LOOP
   ENDIF

   VerTES(_cTES)

   IF lRes = .F.
      FT_FUSE()
      LOOP
   ENDIF
   
   nAtual++

   cItem := Soma1(cItem)
   //_nLinAc := nI           //Itens p/ PV

   IncProc("Registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

  	cItem    := PadL( AllTrim( cItem ) , TamSX3( "C6_ITEM"    )[1],"0")
   nQtdven  := VAL(STRTRAN(aDadosLi[nLoop][02], ',', '.'))            //Posiùùo 02 do lay-out
   _nPunit  := VAL(STRTRAN(aDadosLi[nLoop][03], ',', '.'))            //Posiùùo 03 do lay-out
   cAtivo   := ALLTRIM(aDadosLi[nLoop][04])
   cSolicit := ALLTRIM(aDadosLi[nLoop][05])
   cChassi  := ALLTRIM(aDadosLi[nLoop][06])
   cXMENSER := "TRANSFERENCIA PARA ATIVO IMOBILIZADO " + Chr(13) + Chr(10) + cAtivo + " " + cSolicit

  	AAdd(aCab,{"C5_FILIAL"  , _cFilial          ,NIL})
	AAdd(aCab,{"C5_TIPO"    , "N"               ,NIL})
	AAdd(aCab,{"C5_CLIENTE" , cCliente          ,NIL})
	AAdd(aCab,{"C5_LOJACLI" , cLoja             ,NIL})
   AAdd(aCab,{"C5_CLIENT"  , cCliente          ,NIL})
   AAdd(aCab,{"C5_LOJAENT" , cLoja             ,NIL})
	
   //AAdd(aCab,{"C5_TIPOCLI" , cTipocli          ,NIL})
	AAdd(aCab,{"C5_CONDPAG" , cCondPag          ,NIL})
   //AAdd(aCab,{"C5_DESC1"   , 0                 ,NIL})
	//AAdd(aCab,{"C5_EMISSAO" , MDatFat           ,NIL})
	//AAdd(aCab,{"C5_LIBEROK" , "S"               ,NIL})
	//AAdd(aCab,{"C5_MOEDA"   , 1              ,NIL})
	//AAdd(aCab,{"C5_TXMOEDA" , 1.00              ,NIL})
	//AAdd(aCab,{"C5_TIPLIB"  , "1"               ,NIL})
	//AAdd(aCab,{"C5_TPCARGA" , "2"               ,NIL})
	AAdd(aCab,{"C5_TPFRETE" , cTpFrete          ,NIL})
	AAdd(aCab,{"C5_VOLUME1" , 1                 ,NIL})
	AAdd(aCab,{"C5_ESPECI1" , "VEICULO"         ,NIL})	
   AAdd(aCab,{"C5_TRANSP"  , cTrans            ,NIL})
   AAdd(aCab,{"C5_XMENSER" , cXMENSER          ,NIL})

	AAdd(aReg,{"C6_ITEM"    , cItem             ,NIL})
   //AAdd(aReg,{"C6_FILIAL"  , _cFilial          ,NIL})
	//AAdd(aReg,{"C6_CLIENTE" , cCliente          ,NIL})
	//AAdd(aReg,{"C6_LOJACLI" , cLoja             ,NIL})
	AAdd(aReg,{"C6_PRODUTO" , cProduto          ,NIL})
	//AAdd(aReg,{"C6_DESCRI"  , cDescri           ,NIL})
	//AAdd(aReg,{"C6_UM"      , cUM               ,NIL})

	AAdd(aReg,{"C6_QTDVEN"  , nQtdven           ,NIL})
	AAdd(aReg,{"C6_PRCVEN"  , _nPunit           ,NIL})  
	AAdd(aReg,{"C6_VALOR"   , (nQtdven*_nPunit) ,NIL})
	AAdd(aReg,{"C6_PRUNIT"  , _nPunit           ,NIL})
   AAdd(aReg,{"C6_OPER"    , _cOperac          ,NIL})  
   AAdd(aReg,{"C6_TES"     , _cTes             ,NIL}) 
     
	//AAdd(aReg,{"C6_CF"      , CFOP              ,NIL})
   AAdd(aReg,{"C6_CHASSI"  , cChassi           ,NIL})
   AAdd(aReg,{"C6_NUMSERI" , cChassi          ,NIL})
  	//AAdd(aReg,{"C6_ENTREG"  , MDatFat           ,NIL})
	//AAdd(aReg,{"C6_QTDLIB"  , 0                 ,NIL})
	//AAdd(aReg,{"C6_CLI"     , cCliente          ,NIL})
	//AAdd(aReg,{"C6_LOJA"    , cLoja             ,NIL})
	AAdd(aReg,{"C6_LOCAL"   , cLocal            ,NIL})
	AAdd(aReg,{"C6_CC"      , _cCusto           ,NIL})
	AAdd(aReg,{"C6_CONTA"   , cConta            ,NIL})
	AAdd(aReg,{"C6_ITEMCTA" , cItemcta          ,NIL})
   AAdd(aReg,{"C6_CLVL"    , cCLVL             ,NIL})
	//AAdd(aReg,{"C6_QTDENT"  , 0                 ,NIL})  
	//AAdd(aReg,{"C6_TPOP"    , "F"               ,NIL})
	//AAdd(aReg,{"C6_QTDEMP"  , 0                 ,NIL})
	AAdd(aItens,aReg)

	lMsErroAuto:= .F.
	MSExecAuto({|x,y,z|Mata410(x,y,z)},aCab,aItens,nOpc,.F.)

	IF lMsErroAuto = .T.
      aErroAuto := GetAutoGRLog()
      For nCount := 1 To Len(aErroAuto)
         cLinErro:= aErroAuto[nCount]
         If '<' $ cLinErro
            _cLogWrite := aErroAuto[nCount]
            _cStatus   := " Erro "
            GERLOG()
         endif
         //nPosarray := AScan( aErroAuto , "<" , 1 )
         //IF nPosarray > 0 
            //_cLogWrite := StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "
         //ENDIF
      Next nCount
      RollbackSX8()
		LOOP
   ELSE
      SC6->(dbSetOrder(1))
      SC6->(dbseek(xfilial("SC6")+SC5->C5_NUM))
      while SC6->(!EOF()) .and. xfilial("SC6")+SC5->C5_NUM == SC6->(C6_FILIAL+C6_NUM)
         
         SC6->(RecLock("SC6",.F.))
         SC6->C6_LOCALIZ := cLocaliz
         SC6->( MsUnLock() )

         SC6->(dbSkip())
      EndDo
      
      _cLogWrite := ("Pedido gerado ! "+SC5->C5_NUM)
      _cStatus   := " OK "
      GERLOG()      
	ENDIF

	// Zera os Vetores
	aItens := {}
	aReg   := {}

Next nLoop

//End Transaction

//*********************************************************************
//Chamada do relatùrio
//*********************************************************************
dbSelectArea("TRB1")
dbGotop()
If TRB1->(!EOF())
    Processa({|| IMPEXC() },"Gerando Relatorio de Log... "+"[ZESTF008]")
Else
    cBuffer := Space(512)
Endif
RestArea(_aArea)
FT_FUSE()
Return()


//==============================================================================================
//Funcao.........:	VerCli(cCliente,cLoja)
//Descricao......:	Verificar se o Cliente estù cadastrado
//Autor..........:	A.Oliveira
//Criaùùo........:	25/07/2020
//==============================================================================================
Static Function VerCli(cCliente,cLoja)
	Local cQy	:= " "
	Local cAlias:= "CLI"

	cQy := " SELECT A1_TIPO,A1_TRANSP " + CRLF 
	cQy += "  FROM " + RetSQLName("SA1") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND A1_FILIAL = '" + xfilial('SA1') + "' " + CRLF 
	cQy += " AND A1_COD = '"    + cCliente + "' " + CRLF
   cQy += " AND A1_LOJA = '"    + cLoja + "' " + CRLF  

	TcQuery cQy new Alias (cAlias)

   IF !EOF()
      cTipocli := (cAlias)->A1_TIPO
      //cTrans   := (cAlias)->A1_TRANSP   
      lRes	:= .T.
   ELSE
      MsgInfo("Cliente nùo cadastrado : " + cCliente , " [ZFATF008]")
      _cLogWrite := ("Erro Cliente nùo cadastrado! ")
      _cStatus   := " Erro "
      GERLOG()
      lRes	:= .F. 
   ENDIF

	(cAlias)->(DbCloseArea())
Return(lRes)


//==============================================================================================
//Funcao.........:	VerCond(cCondpag)
//Descricao......:	Verificar se o Condiùùo de Pagamento
//Autor..........:	A.Oliveira
//Criaùùo........:	25/07/2020
//==============================================================================================
Static Function VerCond(cCondpag)
	Local cQy	:= " "
	Local cAlias:= "CON"

	cQy := " SELECT E4_CODIGO " + CRLF 
	cQy += "  FROM " + RetSQLName("SE4") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND E4_FILIAL = '" + xfilial('SE4') + "' " + CRLF 
	cQy += " AND E4_CODIGO = '" + cCondpag + "' " + CRLF
   
	TcQuery cQy new Alias (cAlias)

   IF !EOF()
      
      lRes	:= .T.
   ELSE
      MsgInfo("Condiùùo nùo cadastrada : " + cCliente , " [ZFATF008]")
      _cLogWrite := ("Erro Condiùùo nùo cadastrada! ")
      _cStatus   := " Erro "
      GERLOG()
      lRes	:= .F. 
   ENDIF

	(cAlias)->(DbCloseArea())
Return(lRes)



//==============================================================================================
//Funcao.........:	VerProd(cProduto)
//Descricao......:	Verificar se o Produto estù cadastrado
//Autor..........:	A.Oliveira
//Criaùùo........:	25/07/2020
//==============================================================================================
Static Function VerProd(cProduto)
	Local cQy	:= " "
	Local cAlias:= "PRO"
   Local cGrupo:= " "

	cQy := " SELECT B1_COD,B1_DESC,B1_GRUPO,B1_LOCPAD,B1_UM,B1_CONTA,B1_CLVL,B1_ITEMCC " + CRLF 
	cQy += "  FROM " + RetSQLName("SB1") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND B1_FILIAL = '" + xfilial('SB1') + "' " + CRLF 
	cQy += " AND B1_COD = '"    + cProduto + "' " + CRLF  

	TcQuery cQy new Alias (cAlias)

   IF !EOF()
      cDescri := (cAlias)->B1_DESC
      cLocal  := (cAlias)->B1_LOCPAD
      cUm     := (cAlias)->B1_UM
      cGrupo  := (cAlias)->B1_GRUPO
      cConta  := (cAlias)->B1_CONTA
      cCLVL   := (cAlias)->B1_CLVL
      cItemcta:= (cAlias)->B1_ITEMCC
      lRes	:= .T.
   ELSE
      MsgInfo("Produto nùo cadastrado : " + cProduto , " [ZFATF008]")
      _cLogWrite := ("Erro Produto nùo cadastrado! ")
      _cStatus   := " Erro "
      GERLOG()
      lRes	:= .F. 
   ENDIF

   IF cGrupo <> "VEIA"
      lRes	:= .F. 
   ENDIF

	(cAlias)->(DbCloseArea())

Return(lRes)


//==============================================================================================
//Funcao.........:	VerTES(cTES)
//Descricao......:	Verificar se a TES estù cadastrada
//Autor..........:	A.Oliveira
//Criaùùo........:	25/07/2020
//==============================================================================================
Static Function VerTES(cTES)
	Local cQy	:= " "
	Local cAlias:= "IMP"

	cQy := " SELECT F4_CODIGO,F4_CF " + CRLF 
	cQy += "  FROM " + RetSQLName("SF4") + CRLF 
	cQy += " WHERE " + CRLF 
	cQy += " 	D_E_L_E_T_ <> '*' " + CRLF 
	cQy += " AND F4_FILIAL = '" + xfilial('SF4') + "' " + CRLF 
	cQy += " AND F4_CODIGO = '" + cTES + "' " + CRLF

	TcQuery cQy new Alias (cAlias)

   IF !EOF()
      CFOP := (cAlias)->F4_CF
      lRes	:= .T.
   ELSE
      MsgInfo("TES nùo cadastrada : " + cTES , " [ZFATF008]")
      _cLogWrite := ("Erro TES nùo cadastrada! ")
      _cStatus   := " Erro "
      GERLOG()
      lRes	:= .F. 
   ENDIF

	(cAlias)->(DbCloseArea())
Return(lRes)


/*/{Protheus.doc} ZCOMF008
@param  	 
@author 	   A. Oliveira
@version  	P12.1.25
@since  	   24/07/2020
@return  	NIL
@obs        Grava log das inconsistùncias encontradas
@project
@history
/*/
Static Function GERLOG()
    dbSelectArea("TRB1")
    IF _cStatus = " Erro "
         RecLock("TRB1",.T.)
         TRB1->Linha       := StrZero(nAtual,6) 
         TRB1->PRODUTO     := cProduto 
         TRB1->CHASSI      := cChassi
         TRB1->NUMSERI     := cChassi         
	      TRB1->FILIAL      := _cFilial
         TRB1->TIPO        := "N"
         TRB1->CLIENTE     := cCliente
         TRB1->LOJA        := cLoja
         TRB1->CONDPAG     := cCondPag
         TRB1->QTDE        := nQtdven
         TRB1->VALUNIT     := _nPunit
         TRB1->ATIVO       := cAtivo
         TRB1->SOLICIT     := cSolicit
         TRB1->STATUS      := _cStatus
         TRB1->LOG         := _cLogWrite
         TRB1->( msUnlock() )
    ELSE
         RecLock("TRB1",.T.)
         TRB1->Linha       := StrZero(nAtual,6) 
         TRB1->PRODUTO     := cProduto 
         TRB1->CHASSI      := cChassi
         TRB1->NUMSERI     := cChassi         
	      TRB1->FILIAL      := _cFilial
         TRB1->TIPO        := "N"
         TRB1->CLIENTE     := cCliente
         TRB1->LOJA        := cLoja
         TRB1->CONDPAG     := cCondPag
         TRB1->QTDE        := nQtdven
         TRB1->VALUNIT     := _nPunit
         TRB1->ATIVO       := cAtivo
         TRB1->SOLICIT     := cSolicit
         TRB1->STATUS      := _cStatus
         TRB1->LOG         := _cLogWrite    
		   TRB1->EMISSAO     := MDatFat        
		   TRB1->( msUnlock() )
    Endif
    
    GravaPen(_cLogWrite)
    
Return()


Static Function GravaPen(_cLogWrite)
Local cCab := "LOG"
If !File(cArqLog)
	nH := FCreate(cArqLog)
	FWrite(nH,cCab+Chr(13)+Chr(10),Len(cCab)+2)
Else
	nH := FOpen(cArqLog,1)
EndIf

FSeek(nH,0,2)
FWrite(nH,_cLogWrite+Chr(13)+Chr(10),Len(_cLogWrite)+2)
FClose(nH)
_cLogWrite := " "
_cStatus   := " "

Return


/*/{Protheus.doc} ZESTF008
@param  	
@author 	   A. Oliveira
@version  	P12.1.25
@since    	25/07/2020
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


/*/{Protheus.doc} ZESTF008
@param  	
@author 	   A. Oliveira
@version  	P12.1.25
@since  	   25/07/2020
@return  	NIL
@obs        Impressùo Log das Inconsistencias encontradas
@project
@history
/*/
Static Function ReportDef()
    Local oReport
    Local oSection1
    Local cAlias := 'SC6'
    
    oReport := TReport():New("IMP","Log",,{|oReport| PrintReport(oReport)},"Este relatorio irù imprimir Log")
    oSection1 := TRSection():New(oReport,OemToAnsi("Log"),{"TRB"})

    TRCell():New(oSection1,"LINHA","TRB1","LINHA","@!",015)
    TRCell():New(oSection1,"PRODUTO","TRB1","PRODUTO",PesqPict(cAlias,"C6_PRODUTO"),TamSX3("C6_PRODUTO")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"CLIENTE","TRB1","CLIENTE",PesqPict("SC5","C5_CLIENTE"),TamSX3("C5_CLIENTE")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"LOJA","TRB1","LOJA",PesqPict("SC5","C5_LOJACLI"),TamSX3("C5_LOJACLI")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"QTDE","TRB1","QTDE",PesqPict(cAlias,"C6_QTDVEN"),TamSX3("C6_QTDVEN")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"CONDPAG","TRB1","CONDPAG",PesqPict(cAlias,"C5_CONDPAG"),TamSX3("C5_CONDPAG")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"VALUNIT","TRB1","VALUNIT",PesqPict(cAlias,"C6_PRUNIT"),TamSX3("C6_PRUNIT")[1],)
    TRCell():New(oSection1,"CHASSI","TRB1","CHASSI",PesqPict(cAlias,"C6_CHASSI"),TamSX3("C6_CHASSI")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"NUMSERI","TRB1","NUMSERI",PesqPict(cAlias,"C6_NUMSERI"),TamSX3("C6_NUMSERI")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    TRCell():New(oSection1,"STATUS","TRB1","STATUS","@!",020)
    TRCell():New(oSection1,"LOG","TRB1","LOG","@!",280)
    TRCell():New(oSection1,"FILIAL","TRB1","FILIAL","@!",030)
    TRCell():New(oSection1,"ATIVO","TRB1","ATIVO","@!",080)
    TRCell():New(oSection1,"SOLICIT","TRB1","SOLICIT","@!",080)
    TRCell():New(oSection1,"EMISSAO","TRB1","EMISSAO",PesqPict("SC5","C5_EMISSAO"),TamSX3("C5_EMISSAO")[1],/*lPixel,{|| (TRB1)->NOTA }*/)
    
    oSection1:Cell("LINHA")       :SetHeaderAlign("RIGHT")
    oSection1:Cell("PRODUTO")     :SetHeaderAlign("RIGHT")
    oSection1:Cell("CHASSI")      :SetHeaderAlign("RIGHT")
    oSection1:Cell("NUMSERI")     :SetHeaderAlign("RIGHT")
    oSection1:Cell("CLIENTE")     :SetHeaderAlign("RIGHT")
    oSection1:Cell("LOJA")        :SetHeaderAlign("RIGHT")
    oSection1:Cell("CONDPAG")     :SetHeaderAlign("RIGHT")
    oSection1:Cell("STATUS")      :SetHeaderAlign("RIGHT")
    oSection1:Cell("LOG")         :SetHeaderAlign("RIGHT")
    oSection1:Cell("FILIAL")      :SetHeaderAlign("RIGHT")
    oSection1:Cell("QTDE")        :SetHeaderAlign("RIGHT")
    oSection1:Cell("VALUNIT")     :SetHeaderAlign("RIGHT")
    oSection1:Cell("ATIVO")       :SetHeaderAlign("RIGHT")
    oSection1:Cell("SOLICIT")     :SetHeaderAlign("RIGHT")
    oSection1:Cell("EMISSAO")     :SetHeaderAlign("RIGHT")
    
Return oReport


/*/{Protheus.doc} ZESTF008
@param  	
@author 	   A. Oliveira
@version  	P12.1.25
@since  	   25/07/2020
@return  	NIL
@obs        Processo de Impressùo Log das Inconsistencias encontradas
@project
@history
/*/
Static Function PrintReport(oReport)

    Local oSection1 := oReport:Section(1)
    oSection1:SetTotalInLine(.F.)
    oSection1:SetTotalText("Total Geral  ")  // Imprime Titulo antes do Totalizador da Seùùo
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
