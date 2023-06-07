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

/*/{Protheus.doc} ZPECR007
Relatorio Carga 
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
User Function ZPECR007(_aOndaRel)
Local aAreaVS3      := VS3->( GetArea() )
Local nOpca         := 1
Local aPergs        := {}
Local cCodigo       := SPACE(08)

Private MV_PAR01    := ""
Private dDataI      := Date()
Private dDataF      := Date()
Private cMarca      := SPACE(08)
Private cPickI      := SPACE(08)
Private cPickF      := SPACE(08)
Private aRetP       := {}
Private cAliasQry	:= GetNextAlias()
Private oReport, oSection1          // objeto que contem o relatorio

Default _aOndaRel   := {}

//Chamado por ZPECF008 DAC 19/05/2023
If Len(_aOndaRel) > 0
    aRetP := _aOndaRel
    If nOpca == 1
 	    //If FindFunction("TRepInUse") .And. TRepInUse() // teste padrão 
   
        oReport := ReportDef(.T.)
        oReport:PrintDialog()   
    Endif
    Return Nil
Endif
aAdd( aPergs ,{1,"Onda  .....: "      ,cCodigo ,"@!", , ""   ,'.T.',120,.F.})
aadd( aPergs, {1,"Data Inicial...: "  ,dDataI  ,"@D", , ""   ,  "" ,120,.F.})
aadd( aPergs, {1,"Data Final.....: "  ,dDataF  ,"@D", , ""   ,  "" ,120,.T.})
aAdd( aPergs ,{9,"Marca.....:",200, 40,.T.})
aAdd( aPergs ,{5,"HYU - Hyundai",.T.,90 ,"",.F.})
aAdd( aPergs ,{5,"CHE - Chery"  ,.T.,90 ,"",.F.})
aAdd( aPergs ,{5,"SBR - Subaru" ,.T.,90 ,"",.F.})
aadd( aPergs, {1,"Pick Inicial.....: ",cPickI  ,"@!", , ""   ,  "" ,120,.F.})
aadd( aPergs, {1,"Pick Final.....: "  ,cPickF  ,"@!", , ""   ,  "" ,120,.T.})

If ParamBox(aPergs, "Parâmetros p/ Relatório", aRetP, , , , , , , , ,.F.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Relação Carga  - Barueri") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza a impressão de Conferência da Relação Carga ") SIZE 268, 8 OF oDlg PIXEL
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


/*/{Protheus.doc} ZPECR007
Definição do Relatorio Carga 
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
Static Function ReportDef(_lPlanilha)

Default _lPlanilha  := .F.

MV_PAR01 := aRetP[01]

oReport:= TReport():New("ZPECR007",' Relação Carga  ',"BARUERI", {|oReport| ReportPrint(oReport)},' Carga  ') 
oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
//Impressão em planilha
If _lPlanilha

	oReport:NDEVICE         := 4  //PLANILHA
	oReport:NEXCELPRINTTYPE := 3 	
	oReport:lPrtParamPage  := .f.      
	oReport:ParamReadOnly(.T.) //Define se o usuário terá acesso aos parâmetros do relatório. ParamReadOnly .T. – Não permite acesso aos parâmetros.F. – Permite acesso aos parâmetros	
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
  	//Pergunte(oReport:uParam,.F.)          
Else
    //Verifica os parâmetros selecionados via Pergunte
    //Pergunte(oReport:GetParam(),.F.)
Endif
oSection1 := TRSection():New(oReport,"Carga  - Barueri",{cAliasQry},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oSection1,"MARCA"                ,"cAliasQry","MARCA"          ,"@!",03,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"ONDA"                 ,"cAliasQry","ONDA"           ,"@!",08,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"PICKING"              ,"cAliasQry","PICKING"        ,"@!",08,/*lPixel*/,/*{||cAliasQry->ORCAMENTO}*/)
TRCell():New(oSection1,"NOME_FANTASIA"        ,"cAliasQry","NOME_FANTASIA"  ,"@!",20,/*lPixel*/,/*{||cAliasQry->CNPJ}*/)
TRCell():New(oSection1,"CNPJ"                 ,"cAliasQry","CNPJ"           ,"@!",14,/*lPixel*/,/*{||cAliasQry->NOME}*/)
TRCell():New(oSection1,"CLI_COD"              ,"cAliasQry","CLI_COD"        ,"@!",08,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"LOJA"                 ,"cAliasQry","LOJA"           ,"@!",02,/*lPixel*/,/*{||cAliasQry->UF}*/)
TRCell():New(oSection1,"CIDADE"               ,"cAliasQry","CIDADE"         ,"@!",10,/*lPixel*/,/*{||cAliasQry->DIAS}*/)
TRCell():New(oSection1,"UF"                   ,"cAliasQry","UF"             ,"@!",02,/*lPixel*/,/*{||cAliasQry->TIPO_FRETE}*/)
TRCell():New(oSection1,"TP_PEDIDO"            ,"cAliasQry","TP_PEDIDO"      ,"@!",15,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"MOD_TRANS"            ,"cAliasQry","MOD_TRANS"      ,"@!",10,/*lPixel*/,/*{||cAliasQry->DATAIMP}*/)
TRCell():New(oSection1,"COND_PAG"             ,"cAliasQry","COND_PAG"       ,"@!",10,/*lPixel*/,/*{||cAliasQry->HORAIMP}*/)
TRCell():New(oSection1,"ORCAMENTO"            ,"cAliasQry","ORCAMENTO"      ,"@!",08,/*lPixel*/,/*{||cAliasQry->N_FANTASIA}*/)
TRCell():New(oSection1,"DATA_IMP"             ,"cAliasQry","DATA_IMP"       ,"@!",09,/*lPixel*/,/*{||cAliasQry->CODIGO}*/)
TRCell():New(oSection1,"H_IMP"                ,"cAliasQry","H_IMP"          ,"@!",05,/*lPixel*/,/*{||cAliasQry->LOJA}*/)
TRCell():New(oSection1,"DATA_PICK"            ,"cAliasQry","DATA_PICK"      ,"@!",09,/*lPixel*/,/*{||cAliasQry->LOJA}*/)
TRCell():New(oSection1,"H_PICK"               ,"cAliasQry","H_PICK"         ,"@!",05,/*lPixel*/,/*{||cAliasQry->LOJA}*/)
TRCell():New(oSection1,"PRD_SOLICITADO"       ,"cAliasQry","PRD_SOLICITADO" ,"@!",20,/*lPixel*/,/*{||cAliasQry->LOJA}*/)
TRCell():New(oSection1,"QTD_SOL"              ,"cAliasQry","QTD_SOL"        ,"@!",4,/*lPixel*/,/*{||cAliasQry->LOJA}*/)
TRCell():New(oSection1,"QTD_ATEND"            ,"cAliasQry","QTD_ATEND"      ,"@!",4,/*lPixel*/,/*{||cAliasQry->LOJA}*/)
TRCell():New(oSection1,"PRD_ATENDIDO"         ,"cAliasQry","PRD_ATENDIDO"   ,"@!",20,/*lPixel*/,/*{||cAliasQry->LOJA}*/)
TRCell():New(oSection1,"DESCRI"               ,"cAliasQry","DESCRI"         ,"@!",20,/*lPixel*/,/*{||cAliasQry->LOJA}*/)
TRCell():New(oSection1,"TOT_SEM_IPI"          ,"cAliasQry","TOT_SEM_IPI"    ,"@E 99,999,999,999.99",6,/*lPixel*/,/*{||cAliasQry->LOJA}*/)
TRCell():New(oSection1,"STATUS_ITEM"          ,"cAliasQry","STATUS_ITEM"    ,"@!",10,/*lPixel*/,/*{||cAliasQry->LOJA}*/)
//PesqPict("SA1","A1_LOJA"),TamSX3("A1_LOJA")[1]

Return(oReport) 

/*/{Protheus.doc} ZPECR007
Impressão do relatório Carga 
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
Static Function ReportPrint(oReport)
Local _cQ       := " "
Local cInQry := ""

//oSection1:BeginQuery()
If aRetP[05]
    if !Empty(cInQry)
        cInQry += ","
    EndIf
    cInQry += "'HYU'"  
EndIf
If aRetP[06]
    if !Empty(cInQry)
        cInQry += ","
    EndIf
    cInQry += "'CHE'"  
EndIf
If aRetP[07]
    if !Empty(cInQry)
        cInQry += ","
    EndIf
    cInQry += "'SBR'"  
EndIf

_cQ += "SELECT"
_cQ += "		  VS1LEG.VS1_XMARCA      AS MARCA " 
_cQ += "        , VS1LEG.VS1_XAGLU       AS ONDA"
_cQ += "        , VS1LEG.VS1_XPICKI      AS PICKING "       		 
_cQ += "        , SA1.A1_NREDUZ   		 AS NOME_FANTASIA  	"	 
_cQ += "        , SA1.A1_CGC      		 AS CNPJ"
_cQ += "        , SA1.A1_COD			 AS CLI_COD"
_cQ += "        , SA1.A1_LOJA			 AS LOJA"
_cQ += "        , SA1.A1_MUN	       	 AS CIDADE"
_cQ += "        , SA1.A1_EST       		 AS UF"
_cQ += "        , NVL(RTRIM(VX5A.VX5_DESCRI),'-') AS TP_PEDIDO"     
_cQ += "        , NVL(RTRIM(VX5B.VX5_DESCRI),'-') AS MOD_TRANS"
_cQ += "        , SE4.E4_DESCRI			AS COND_PAG"
_cQ += "        , VS1LEG.VS1_NUMORC      AS ORCAMENTO  "       
_cQ += "        , Substr(TO_CHAR(VS1LEG.VS1_XDTIMP),7,2)||'/'||Substr(TO_CHAR(VS1LEG.VS1_XDTIMP),5,2)||'/'||Substr(TO_CHAR(VS1LEG.VS1_XDTIMP),1,4) AS DATA_IMP"
_cQ += "        , VS1LEG.VS1_XHSIMP AS H_IMP"
_cQ += "        , Substr(TO_CHAR(VS1LEG.VS1_XDTEPI),7,2)||'/'||Substr(TO_CHAR(VS1LEG.VS1_XDTEPI),5,2)||'/'||Substr(TO_CHAR(VS1LEG.VS1_XDTEPI),1,4) AS DATA_PICK"
_cQ += "        , VS1LEG.VS1_XHSPIC AS H_PICK"   
_cQ += "        , VS3LEG.VS3_XITSUB AS PRD_SOLICITADO"
_cQ += "        , VS3LEG.VS3_QTDINI AS QTD_SOL"
_cQ += "        , NVL(VS3LEG.VS3_QTDITE,0) AS QTD_ATEND"
_cQ += "        , VS3LEG.VS3_CODITE  AS PRD_ATENDIDO"
_cQ += "        , SB1.B1_DESC     AS DESCRI"
_cQ += "		, NVL(ROUND(VS3LEG.VS3_VALTOT,2),0) AS TOT_SEM_IPI "
_cQ += "       , CASE "
_cQ += "		WHEN (VS1LEG.VS1_STATUS = '0' AND VS1LEG.VS1_XBO = ' ') THEN 'EM ANALISE'"
_cQ += "		WHEN (VS1LEG.VS1_STATUS = '3')							THEN 'BLOQUEADO POR CRÉDITO'"
_cQ += "		WHEN (VS1LEG.VS1_STATUS = '0' AND VS1LEG.VS1_XBO = 'S')	THEN 'B.O.'"
_cQ += "		WHEN (VS1LEG.VS1_STATUS IN ('X'))						THEN 'FATURADO'"	
_cQ += "		WHEN (VS1LEG.VS1_STATUS IN ('4','F'))					THEN 'SEPARAÇÃO'"
_cQ += "		WHEN (VS1LEG.VS1_STATUS = 'C')							THEN 'CANCELADO'"
_cQ += "END AS STATUS_ITEM "
_cQ += " FROM " + RetSQLname("VS1") + " VS1LEG"
_cQ += "	INNER JOIN " + RetSQLname("VS3") + " VS3LEG"
_cQ += "		ON VS3LEG.D_E_L_E_T_ = ' '"
_cQ += "		AND VS3LEG.VS3_FILIAL = VS1LEG.VS1_FILIAL"
_cQ += "		AND VS3LEG.VS3_NUMORC = VS1LEG.VS1_NUMORC"
_cQ += "	LEFT JOIN " + RetSQLname("SF2") + " SF2"
_cQ += "		ON SF2.D_E_L_E_T_ = ' '"
_cQ += "		AND SF2.F2_FILIAL = VS1LEG.VS1_FILIAL"
_cQ += "		AND SF2.F2_DOC = VS1LEG.VS1_NUMNFI"
_cQ += "		AND SF2.F2_SERIE = VS1LEG.VS1_SERNFI"
_cQ += "	LEFT JOIN " + RetSQLname("SB1") + " SB1"
_cQ += "        ON SB1.D_E_L_E_T_ = ' '"
_cQ += "        AND Substr(SB1.B1_FILIAL,1,6) = Substr(VS3LEG.VS3_FILIAL,1,6)" 
_cQ += " 	    AND SB1.B1_COD = VS3LEG.VS3_CODITE"
_cQ += "    LEFT JOIN " + RetSQLname("SA1") + " SA1"
_cQ += "        ON SA1.D_E_L_E_T_ = ' '"
_cQ += "       AND SA1.A1_FILIAL = SA1.A1_FILIAL  "
_cQ += " 	    AND SA1.A1_COD = VS1LEG.VS1_CLIFAT  "          
_cQ += " 	    AND SA1.A1_LOJA = VS1LEG.VS1_LOJA  "       
_cQ += " 	LEFT JOIN " + RetSQLname("VX5") + " VX5A"
_cQ += " 	    ON VX5A.D_E_L_E_T_ = ' '"
_cQ += "	    AND VX5A.VX5_FILIAL = '          '"
_cQ += " 	    AND VX5A.VX5_CHAVE = 'Z00'"
_cQ += " 	    AND VX5A.VX5_CODIGO = VS1LEG.VS1_XTPPED"
_cQ += "	LEFT JOIN " + RetSQLname("VX5") + " VX5B"
_cQ += " 	    ON VX5B.VX5_FILIAL = '          '"
_cQ += " 	    AND VX5B.VX5_CHAVE = 'Z01'"
_cQ += " 	    AND VX5B.VX5_CODIGO = VS1LEG.VS1_XTPTRA"
_cQ += " 	    AND VX5B.D_E_L_E_T_ = ' '"	
_cQ += " 	LEFT JOIN " + RetSQLname("SE4") + " SE4"
_cQ += " 	    ON SE4.D_E_L_E_T_ = ' '"
_cQ += " 	    AND SE4.E4_FILIAL = ' '"
_cQ += " 	    AND SE4.E4_CODIGO = VS1LEG.VS1_FORPAG "
_cQ += "WHERE VS1LEG.D_E_L_E_T_ = ' '"
If aRetP[01] <> Space(08)
    //_cQ += "         AND VS3LEG.VS3_XAGLU = '" + aRetP[01] + "'"
    _cQ += "         AND VS3LEG.VS3_XAGLU IN "+ FormatIn(aRetP[01],";")  

endif
_cQ += "	AND VS1LEG.VS1_XDTAGL BETWEEN '" + DTOS(aRetP[02]) + "' AND '" + DTOS(aRetP[03]) + "'" 
_cQ += "	AND (VS1LEG.VS1_XPICKI != ' ' 
_cQ += "    AND VS1LEG.VS1_XPICKI BETWEEN '" + aRetP[08] + "' AND '" + aRetP[09] + "'"
_cQ += "	)
If !Empty(cInQry)
    _cQ += "	AND VS1LEG.VS1_XMARCA IN (" + cInQry + ") "
EndIf
_cQ += " ORDER BY ONDA, PICKING, ORCAMENTO"

//XDTAGL ->VS1

dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQ),cAliasQry, .T., .T. ) 

//oSection1:EndQuery()
PQuery(cAliasQry,oReport) //Imprime
oReport:IncMeter()
oSection1:Finish() 

Return


/*/{Protheus.doc} ZPECR007
Imprimir a Query	
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
Static Function PQuery(cAliasQry,oReport)

dbSelectArea(cAliasQry)
dBGotop()

oReport:SetMeter((cAliasQry)->(LastRec()))
oSection1:Init()

Do While !(cAliasQry)->( Eof() )

    oReport:IncMeter()

    oSection1:Cell("MARCA"):SetValue((cAliasQry)->MARCA)
    oSection1:Cell("ONDA"):SetValue((cAliasQry)->ONDA)
    oSection1:Cell("PICKING"):SetValue((cAliasQry)->PICKING)
    oSection1:Cell("NOME_FANTASIA"):SetValue((cAliasQry)->NOME_FANTASIA)
    oSection1:Cell("CNPJ"):SetValue((cAliasQry)->CNPJ)
    oSection1:Cell("CLI_COD"):SetValue((cAliasQry)->CLI_COD)
    oSection1:Cell("LOJA"):SetValue((cAliasQry)->LOJA)
    oSection1:Cell("CIDADE"):SetValue((cAliasQry)->CIDADE)
    oSection1:Cell("UF"):SetValue((cAliasQry)->UF)
    oSection1:Cell("TP_PEDIDO"):SetValue((cAliasQry)->TP_PEDIDO)
    oSection1:Cell("MOD_TRANS"):SetValue((cAliasQry)->MOD_TRANS)
    oSection1:Cell("COND_PAG"):SetValue((cAliasQry)->COND_PAG)
    oSection1:Cell("ORCAMENTO"):SetValue((cAliasQry)->ORCAMENTO)
    oSection1:Cell("DATA_IMP"):SetValue((cAliasQry)->DATA_IMP)
    oSection1:Cell("H_IMP"):SetValue((cAliasQry)->H_IMP)
    oSection1:Cell("DATA_PICK"):SetValue((cAliasQry)->DATA_PICK)
    oSection1:Cell("H_PICK"):SetValue((cAliasQry)->H_PICK)
    oSection1:Cell("PRD_SOLICITADO"):SetValue((cAliasQry)->PRD_SOLICITADO)
    oSection1:Cell("QTD_SOL"):SetValue((cAliasQry)->QTD_SOL)
    oSection1:Cell("QTD_ATEND"):SetValue((cAliasQry)->QTD_ATEND)
    oSection1:Cell("PRD_ATENDIDO"):SetValue((cAliasQry)->PRD_ATENDIDO)
    oSection1:Cell("DESCRI"):SetValue((cAliasQry)->DESCRI)
    oSection1:Cell("TOT_SEM_IPI"):SetValue((cAliasQry)->TOT_SEM_IPI)
    oSection1:Cell("STATUS_ITEM"):SetValue((cAliasQry)->STATUS_ITEM)

	oSection1:PrintLine()    
    TReport():Print() 

	(cAliasQry)->( DbSkip() )
	
EndDo

Return()
