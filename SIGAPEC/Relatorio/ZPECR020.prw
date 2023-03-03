#INCLUDE "prtopdef.ch"
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

/*/{Protheus.doc} ZPECR020
Relatorio Resumido de Saidas Cabeçalho (1 na planilha)
@author Antonio Oliveira
@since 20/06/2022
@version 2.0
/*/
User Function ZPECR020()
Local aAreaSC7      := SF2->( GetArea() )
Local nOpca         := 1
Local aPergs        := {}
//Local _cFil         := SPACE(10)
Local cNotaI         := SPACE(09)
Local cNotaF         := SPACE(09)
//Local _aCombo    	:= {"CHE", "HYN", "SUB","   "}

Private cDescricao  := "Relação Resumida de Saidas Cabeçalho"
Private MV_PAR01    := ""
Private nResulte    := 0
Private cMarca      := SPACE(10)
Private dDataI      := Date()
Private dDataF      := Date()
Private aRetP       := {}
Private cAliasQry	:= GetNextAlias()
Private oReport, oSection1          // objeto que contem o relatorio

aAdd( aPergs ,{1,"Nota Fiscal De.: ",cNotaI   ,"@!", , "SF2",'.T.',15,.F.})
aAdd( aPergs ,{1,"Nota Fiscal Ate: ",cNotaf   ,"@!", , "SF2",'.T.',15,.T.})
aadd( aPergs, {1,"Data Inicial...: ",dDataI  ,"@D", , ""   ,  "" ,60,.F.})
aadd( aPergs, {1,"Data Final.....: ",dDataF  ,"@D", , ""   ,  "" ,60,.T.})
aAdd( aPergs ,{9,"Marca.....:"     ,200, 40,.T.})
aAdd( aPergs ,{9," *Para devolução não selecionar Marca" ,200, 40,.F.})
aAdd( aPergs ,{5,"HYU - Hyundai",.T.,90 ,"",.F.})
aAdd( aPergs ,{5,"CHE - Chery"  ,.T.,90 ,"",.F.})
aAdd( aPergs ,{5,"SBR - Subaru" ,.T.,90 ,"",.F.})

If ParamBox(aPergs, "Parâmetros p/ Relatório", aRetP, , , , , , , , ,.F.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi(cDescricao + " - Barueri") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza a impressão de Relação Resumida de Saidas Cabeçalho ") SIZE 268, 8 OF oDlg PIXEL
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

RestArea( aAreaSC7 )

Return()


/*/{Protheus.doc} ZPECR020
Relatorio Resumido de Saidas (2 na planilha)
@author Antonio Oliveira
@since 20/06/2022
@version 2.0
/*/
Static Function ReportDef()

MV_PAR01 := aRetP[01]

oReport:= TReport():New("ZPECR020",cDescricao,"BARUERI", {|oReport| ReportPrint(oReport)},' Resumo Saidas Cabeçalho ') 
oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.

//Verifica os parâmetros selecionados via Pergunte
Pergunte(oReport:GetParam(),.F.)
oSection1 := TRSection():New(oReport,cDescricao + " - Barueri",{cAliasQry},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oSection1,"MARCA"           ,"cAliasQry","MARCA"           ,"@!",10,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"TP_PEDIDO"       ,"cAliasQry","TP_PEDIDO"       ,"@!",40,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"MOD_TRANS"       ,"cAliasQry","MOD_TRANS"       ,"@!",40,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"PICKING"         ,"cAliasQry","PICKING"         ,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DATA_PICK"       ,"cAliasQry","DATA_PICK"       ,"@D",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CNPJ"            ,"cAliasQry","CNPJ"            ,"@!",40,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CLIFORN_COD"     ,"cAliasQry","CLIFORN_COD"     ,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CLIFORN_LOJA"    ,"cAliasQry","CLIFORN_LOJA"    ,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"NOME_FANTASIA"   ,"cAliasQry","NOME_FANTASIA"   ,"@!",05,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CIDADE"          ,"cAliasQry","CIDADE"          ,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"UF"              ,"cAliasQry","UF"              ,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"TIPO"            ,"cAliasQry","TIPO"            ,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"NOTA"            ,"cAliasQry","NOTA"            ,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"SERIE"           ,"cAliasQry","SERIE"           ,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DATA_NOTA"       ,"cAliasQry","DATA_NOTA"       ,"@D",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"VALOR_NOTA"      ,"cAliasQry","VALOR_NOTA"      ,"@E 99,999,999,999.99",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"VALOR_DESC"      ,"cAliasQry","VALOR_DESC"      ,"@E 99,999,999,999.99",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"TP_OPER"         ,"cAliasQry","TP_OPER"         ,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DESC_OPER"       ,"cAliasQry","DESC_OPER"       ,"@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport) 


/*/{Protheus.doc} ZPECR020
Relatorio Resumido de Saidas (2 na planilha)
@author Antonio Oliveira
@since 20/06/2022
@version 2.0
/*/
Static Function ReportPrint(oReport)
Local _cQ           := " "
Local cInQry := ""
If aRetP[07]
    if !Empty(cInQry)
        cInQry += ","
    EndIf
    cInQry += "'HYU'"  
EndIf
If aRetP[08]
    if !Empty(cInQry)
        cInQry += ","
    EndIf
    cInQry += "'CHE'"  
EndIf
If aRetP[09]
    if !Empty(cInQry)
        cInQry += ","
    EndIf
    cInQry += "'SBR'"  
EndIf

_cQ := "SELECT DISTINCT"
_cQ += "    NVL(VS1LEG.VS1_XMARCA,'-')      AS MARCA,"
_cQ += "    NVL(RTRIM(VX5A.VX5_DESCRI),'-') AS TP_PEDIDO,"
_cQ += "    NVL(RTRIM(VX5B.VX5_DESCRI),'-') AS MOD_TRANS,"
_cQ += "    NVL(VS1LEG.VS1_XPICKI,'-')      AS PICKING,"
_cQ += "    Substr(TO_CHAR(VS1LEG.VS1_XDTEPI),7,2)||'/'||Substr(TO_CHAR(VS1LEG.VS1_XDTEPI),5,2)||'/'||Substr(TO_CHAR(VS1LEG.VS1_XDTEPI),1,4) AS DATA_PICK,"
_cQ += "    CASE WHEN (SF2.F2_TIPO = 'D') THEN SA2.A2_CGC ELSE SA1.A1_CGC END AS CNPJ,"
_cQ += "    CASE WHEN (SF2.F2_TIPO = 'D') THEN SA2.A2_COD ELSE SA1.A1_COD END AS CLIFORN_COD,"
_cQ += "    CASE WHEN (SF2.F2_TIPO = 'D') THEN SA2.A2_LOJA ELSE SA1.A1_LOJA END AS CLIFORN_LOJA,"
_cQ += "    CASE WHEN (SF2.F2_TIPO = 'D') THEN SA2.A2_NREDUZ ELSE SA1.A1_NREDUZ END AS NOME_FANTASIA,"
_cQ += "    CASE WHEN (SF2.F2_TIPO = 'D') THEN SA2.A2_MUN ELSE SA1.A1_MUN END AS CIDADE,"
_cQ += "    CASE WHEN (SF2.F2_TIPO = 'D') THEN SA2.A2_EST ELSE SA1.A1_EST END AS UF,"
_cQ += "    SF2.F2_TIPO			 AS TIPO,"
_cQ += "    SF2.F2_DOC			 AS NOTA,"
_cQ += "    SF2.F2_SERIE	     AS SERIE,"
_cQ += "    SF2.F2_EMISSAO		 AS DATA_NOTA,"
_cQ += "    SF2.F2_VALBRUT 		 AS VALOR_NOTA,"
_cQ += "    SF2.F2_DESCONT 		 AS VALOR_DESC,"
_cQ += "    NVL((SELECT VS3.VS3_OPER FROM " + RetSQLname("VS3") + " VS3 WHERE VS3.D_E_L_E_T_ = ' ' AND ROWNUM = 1 AND VS3.VS3_NUMORC = VS1LEG.VS1_NUMORC),(SELECT C6.C6_OPER FROM " + RetSQLname("SC6") + " C6 WHERE C6.D_E_L_E_T_ = ' ' AND ROWNUM = 1 AND C6.C6_NOTA = SF2.F2_DOC AND C6.C6_SERIE = SF2.F2_SERIE)) AS TP_OPER,"
_cQ += "    NVL((SELECT X5.X5_DESCRI FROM " + RetSQLname("VS3") + " VS3 INNER JOIN " + RetSQLname("SX5") + " X5 ON X5.D_E_L_E_T_ =' ' AND X5.X5_TABELA = 'DJ' AND X5.X5_CHAVE = VS3.VS3_OPER WHERE VS3.D_E_L_E_T_ = ' ' AND VS3.VS3_FILIAL = SF2.F2_FILIAL AND VS3.VS3_NUMORC =  VS1LEG.VS1_NUMORC AND ROWNUM = 1),
_cQ += "    (SELECT X5.X5_DESCRI FROM " + RetSQLname("SC6") + " C6 INNER JOIN " + RetSQLname("SX5") + " X5 ON X5.D_E_L_E_T_ =' ' AND X5.X5_TABELA = 'DJ' AND X5.X5_CHAVE = C6.C6_OPER WHERE C6.D_E_L_E_T_ = ' ' AND C6.C6_FILIAL = SF2.F2_FILIAL AND C6.C6_NOTA =  SF2.F2_DOC AND C6.C6_SERIE =  SF2.F2_SERIE AND ROWNUM = 1)) AS DESC_OPER "
_cQ += " FROM " + RetSQLname("SF2") + " SF2 "
_cQ += "    LEFT JOIN " + RetSQLname("VS1") + " VS1LEG "
_cQ += "    ON VS1LEG.D_E_L_E_T_ = ' ' "
_cQ += "        AND SF2.F2_FILIAL = VS1LEG.VS1_FILIAL "
_cQ += "        AND SF2.F2_DOC = VS1LEG.VS1_NUMNFI "
_cQ += "        AND SF2.F2_SERIE = VS1LEG.VS1_SERNFI "
_cQ += "    LEFT JOIN " + RetSQLname("SA1") + " SA1 "
_cQ += "    ON SA1.D_E_L_E_T_ = ' ' "
_cQ += "        AND SA1.A1_FILIAL = ' ' "
_cQ += "        AND SA1.A1_COD = SF2.F2_CLIENTE "
_cQ += "        AND SA1.A1_LOJA = SF2.F2_LOJA "
_cQ += "    LEFT JOIN " + RetSQLname("SA2") + " SA2 "
_cQ += "    ON SA2.D_E_L_E_T_ = ' ' "
_cQ += "        AND SA2.A2_FILIAL = ' ' "
_cQ += "        AND SA2.A2_COD = SF2.F2_CLIENTE "
_cQ += "        AND SA2.A2_LOJA = SF2.F2_LOJA "
_cQ += "    LEFT JOIN " + RetSQLname("VX5") + " VX5A "
_cQ += "    ON VX5A.D_E_L_E_T_ = ' ' "
_cQ += "        AND VX5A.VX5_FILIAL = '          ' " 
_cQ += "        AND VX5A.VX5_CHAVE = 'Z00' "
_cQ += "        AND VX5A.VX5_CODIGO = VS1LEG.VS1_XTPPED "
_cQ += "    LEFT JOIN " + RetSQLname("VX5") + " VX5B "
_cQ += "        ON VX5B.VX5_FILIAL = '          ' "
_cQ += "            AND VX5B.VX5_CHAVE = 'Z01' "
_cQ += "            AND VX5B.VX5_CODIGO = VS1LEG.VS1_XTPTRA "
_cQ += "            AND VX5B.D_E_L_E_T_ = ' '	"
_cQ += "WHERE SF2.D_E_L_E_T_ = ' ' "
_cQ += "    AND (SF2.F2_DOC != ' ' "
_cQ += "    AND SF2.F2_DOC BETWEEN '" + aRetP[01] + "' AND '" + aRetP[02] + "'"
_cQ += ")"
_cQ += "      AND SF2.F2_EMISSAO BETWEEN '" + DTOS(aRetP[03]) + "' AND '" + DTOS(aRetP[04]) + "'"

If !Empty(cInQry)
    _cQ += "	AND VS1LEG.VS1_XMARCA IN (" + cInQry + ") " 
EndIf

_cQ += " ORDER BY NOTA "

dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQ),cAliasQry, .T., .T. ) 
//oSection1:EndQuery()
PQuery(cAliasQry,oReport) //Imprime
oReport:IncMeter()
oSection1:Finish() 

Return


/*/{Protheus.doc} ZPECR020
Imprimir a Query	
@author Antonio Oliveira
@since 20/06/2022
@version 2.0
/*/
Static Function PQuery(cAliasQry,oReport)

dbSelectArea(cAliasQry)
dBGotop()

oReport:SetMeter((cAliasQry)->(LastRec()))
oSection1:Init()

Do While !(cAliasQry)->( Eof() )

    /*IF (cAliasQry)->CODIGO_CLIENTE <> aRetP[01] 
        (cAliasQry)->( DbSkip() )
        LOOP
    ENDIF*/

    oReport:IncMeter()

    oSection1:Cell("MARCA"):SetValue((cAliasQry)->MARCA)
    oSection1:Cell("TP_PEDIDO"):SetValue((cAliasQry)->TP_PEDIDO)
    oSection1:Cell("MOD_TRANS"):SetValue((cAliasQry)->MOD_TRANS)
    oSection1:Cell("PICKING"):SetValue((cAliasQry)->PICKING)
    oSection1:Cell("DATA_PICK"):SetValue((cAliasQry)->DATA_PICK)
    oSection1:Cell("CNPJ"):SetValue((cAliasQry)->CNPJ)
    oSection1:Cell("CLIFORN_COD"):SetValue((cAliasQry)->CLIFORN_COD)
    oSection1:Cell("CLIFORN_LOJA"):SetValue((cAliasQry)->CLIFORN_LOJA)
    oSection1:Cell("NOME_FANTASIA"):SetValue((cAliasQry)->NOME_FANTASIA) 
    oSection1:Cell("CIDADE"):SetValue((cAliasQry)->CIDADE)    
    oSection1:Cell("UF"):SetValue((cAliasQry)->UF) 
    oSection1:Cell("TIPO"):SetValue((cAliasQry)->TIPO) 
    oSection1:Cell("NOTA"):SetValue((cAliasQry)->NOTA) 
    oSection1:Cell("SERIE"):SetValue((cAliasQry)->SERIE) 
    oSection1:Cell("DATA_NOTA"):SetValue((cAliasQry)->DATA_NOTA) 
    oSection1:Cell("VALOR_NOTA"):SetValue((cAliasQry)->VALOR_NOTA) 
    oSection1:Cell("VALOR_DESC"):SetValue((cAliasQry)->VALOR_DESC) 
    oSection1:Cell("TP_OPER"):SetValue((cAliasQry)->TP_OPER) 
    oSection1:Cell("DESC_OPER"):SetValue((cAliasQry)->DESC_OPER) 
  
	oSection1:PrintLine()
    TReport():Print() 

	(cAliasQry)->( DbSkip() )
	
EndDo

Return()
