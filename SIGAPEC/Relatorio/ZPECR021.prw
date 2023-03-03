#INCLUDE "protheus.ch"
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
#define CRLF chr(13) + chr(10)  

/*/{Protheus.doc} ZPECR021
Relatorio KPI - Linhas Liberadas 

/*/
User Function ZPECR021()
Local aAreaVS3      := VS3->( GetArea() )
Local nOpca         := 1
Local aPergs        := {}
Private MV_PAR01    := ""
Private dDataI      := Date()
Private dDataF      := Date()
Private cMarca      := SPACE(08)
Private aRetP       := {}
Private cAliasQry	:= GetNextAlias()
Private oReport, oSection1          // objeto que contem o relatorio

aadd( aPergs, {1,"Data Inicial...: "  ,dDataI  ,"@D", , ""   ,  "" ,120,.F.})
aadd( aPergs, {1,"Data Final.....: "  ,dDataF  ,"@D", , ""   ,  "" ,120,.T.})
aAdd( aPergs ,{9,"Marca.....:",200, 40,.T.})
aAdd( aPergs ,{5,"HYU - Hyundai",.T.,90 ,"",.F.})
aAdd( aPergs ,{5,"CHE - Chery"  ,.T.,90 ,"",.F.})
aAdd( aPergs ,{5,"SBR - Subaru" ,.T.,90 ,"",.F.})
      
If ParamBox(aPergs, "Parâmetros p/ Relatório", aRetP, , , , , , , , ,.F.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Relação KPI  - Barueri") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza a impressão da Relação KPI ") SIZE 268, 8 OF oDlg PIXEL
   @ 38, 15 SAY OemToAnsi("Da Caoa Peças.") SIZE 268, 8 OF oDlg PIXEL
   @ 48, 15 SAY OemToAnsi("Confirma Geração do Documento ? ") SIZE 268, 8 OF oDlg PIXEL
   DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
   DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
   ACTIVATE MSDIALOG oDlg CENTER

   If nOpca == 1
      oReport := ReportDef()
      oReport:PrintDialog()   
   Endif

Endif

RestArea( aAreaVS3 )

Return()


/*/{Protheus.doc} ZPECR021
Relatorio KPI - Linhas Liberadas

/*/
Static Function ReportDef()

MV_PAR01 := aRetP[01]

oReport:= TReport():New("ZPECR021",' Relação KPI  ',"BARUERI", {|oReport| ReportPrint(oReport)},' KPI  ') 
oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.

//Verifica os parâmetros selecionados via Pergunte
Pergunte(oReport:GetParam(),.F.)

oSection1 := TRSection():New(oReport,"KPI  - Barueri",{cAliasQry},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oSection1,"MARCA"          ,"cAliasQry","MARCA"    ,"@!",12,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"REVENDA"        ,"cAliasQry","REVENDA"  ,"@!",30,/*lPixel*/,/*{||cAliasQry->CNPJ}*/)
TRCell():New(oSection1,"UF"             ,"cAliasQry","UF"       ,"@!",02,/*lPixel*/,/*{||cAliasQry->TIPO_FRETE}*/)
TRCell():New(oSection1,"CODIGO"         ,"cAliasQry","CODIGO"   ,    ,10,/*lPixel*/,/*{||cAliasQry->LOJA}*/)
TRCell():New(oSection1,"DESCRICAO"      ,"cAliasQry","DESCRICAO",    ,10,/*lPixel*/,/*{||cAliasQry->LOJA}*/)
TRCell():New(oSection1,"PICKING"        ,"cAliasQry","PICKING"  ,"@!",12,/*lPixel*/,/*{||cAliasQry->ORCAMENTO}*/)
TRCell():New(oSection1,"DATA_PICK"      ,"cAliasQry","DATA_PICK",    ,10,/*lPixel*/,/*{||cAliasQry->LOJA}*/)
TRCell():New(oSection1,"TIPO_PEDIDO"    ,"cAliasQry","TP_PEDIDO","@!",20,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"PED_QTD"        ,"cAliasQry","QTD_ATEND",    ,10,/*lPixel*/,/*{||cAliasQry->LOJA}*/)

Return(oReport) 

/*/{Protheus.doc} ZPECR021
Relatorio KPI - Linhas Liberadas

/*/
Static Function ReportPrint(oReport)
Local _cQ       := " "
Local cInQry := ""

//oSection1:BeginQuery()
If aRetP[04]
    if !Empty(cInQry)
        cInQry += ","
    EndIf
    cInQry += "'HYU'"  
EndIf
If aRetP[05]
    if !Empty(cInQry)
        cInQry += ","
    EndIf
    cInQry += "'CHE'"  
EndIf
If aRetP[06]
    if !Empty(cInQry)
        cInQry += ","
    EndIf
    cInQry += "'SBR'"  
EndIf

_cQ := " SELECT "
_cQ += " 	VS1_XMARCA AS MARCA, "
_cQ += " 	A1_NREDUZ AS REVENDA, "
_cQ += " 	A1_EST AS UF, "
_cQ += " 	VS3_CODITE AS CODIGO, "
_cQ += " 	B1_DESC AS DESCRICAO, "
_cQ += " 	VS1_XPICKI AS PICKING, "
_cQ += " 	VS1_XDTEPI AS DATA_PICK, "
_cQ += " 	VX5Z00.VX5_DESCRI AS TIPO_PEDIDO, "
_cQ += " 	VS3_QTDITE AS PED_QTD "
_cQ += " FROM "+RetSqlName("VS3")+" VS3 "
_cQ += " INNER JOIN "+RetSqlName("VS1")+" VS1  "
_cQ += "    ON VS1.D_E_L_E_T_ = ' ' "
_cQ += " 	AND VS1_FILIAL = VS3_FILIAL  "
_cQ += " 	AND VS1_NUMORC = VS3_NUMORC  " 
_cQ += " INNER JOIN "+RetSqlName("SA1")+" A1 "
_cQ += "    ON A1.D_E_L_E_T_ = ' '  "
_cQ += "    AND A1.A1_COD = VS1.VS1_CLIFAT " 
_cQ += "    AND A1.A1_LOJA = VS1.VS1_LOJA "
_cQ += " LEFT JOIN "+RetSqlName("SB1")+" B1 " 
_cQ += "    ON B1.D_E_L_E_T_ = ' ' "
_cQ += "    AND SUBSTR(B1.B1_FILIAL,1,6) = SUBSTR(VS3.VS3_FILIAL,1,6) "
_cQ += "    AND B1.B1_COD = VS3.VS3_CODITE "
_cQ += " INNER JOIN "+RetSqlName("VX5")+" VX5Z00 "
_cQ += " 	ON VX5Z00.D_E_L_E_T_ = ' ' "
_cQ += " 	AND VX5Z00.VX5_FILIAL = ' ' "
_cQ += " 	AND VX5Z00.VX5_CHAVE = 'Z00' "
_cQ += " 	AND VX5Z00.VX5_CODIGO = VS1.VS1_XTPPED	 "
_cQ += " WHERE VS3.D_E_L_E_T_ = ' ' "
If aRetP[01] != STOD("")
    _cQ += " 	AND VS1.VS1_XDTEPI >= '"+DTOS(aRetP[01])+"' "
EndIf
_cQ += " 	AND VS1.VS1_XDTEPI <= '"+DTOS(aRetP[02])+"' " //PARAMETRO OBRIGATORIO
If !Empty(cInQry)
    _cQ += " 	AND VS1.VS1_XMARCA IN ("+cInQry+")  " //PARAMETRO  NÃO OBRIGATÓRIO (EM BRANCO TODAS OU PREENCHE UMA)
EndIf
_cQ += " 	ORDER BY VS1.VS1_XMARCA, VS1.VS1_XPICKI "

dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQ),cAliasQry, .T., .T. ) 

//oSection1:EndQuery()
PQuery(cAliasQry,oReport) //Imprime
oReport:IncMeter()
oSection1:Finish() 

Return

/*/{Protheus.doc} ZPECR021
Imprimir a Query	

/*/
Static Function PQuery(cAliasQry,oReport)

dbSelectArea(cAliasQry)
dBGotop()

oReport:SetMeter((cAliasQry)->(LastRec()))
oSection1:Init()

Do While !(cAliasQry)->( Eof() )

    oReport:IncMeter()

    oSection1:Cell("MARCA"):SetValue((cAliasQry)->MARCA)
    oSection1:Cell("REVENDA"):SetValue((cAliasQry)->REVENDA)
    oSection1:Cell("UF"):SetValue((cAliasQry)->UF)
    oSection1:Cell("CODIGO"):SetValue((cAliasQry)->CODIGO)
    oSection1:Cell("DESCRICAO"):SetValue((cAliasQry)->DESCRICAO)
    oSection1:Cell("PICKING"):SetValue((cAliasQry)->PICKING)
    oSection1:Cell("DATA_PICK"):SetValue((cAliasQry)->DATA_PICK)
    oSection1:Cell("TIPO_PEDIDO"):SetValue((cAliasQry)->TIPO_PEDIDO)
    oSection1:Cell("PED_QTD"):SetValue((cAliasQry)->PED_QTD)

	oSection1:PrintLine()
    TReport():Print() 

	(cAliasQry)->( DbSkip() )
	
EndDo

Return()
