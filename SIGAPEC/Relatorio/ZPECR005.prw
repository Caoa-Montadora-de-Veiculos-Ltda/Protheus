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
#define CRLF chr(13) + chr(10)  

/*/{Protheus.doc} ZPECR005
Relatorio Picking 
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
User Function ZPECR005()
Local aAreaVS1      := VS1->( GetArea() )
Local nOpca         := 1
Local aPergs        := {}
Local cCodigo       := SPACE(03)
Private dDataI      := Date()
Private dDataF      := Date()
Private aRetP       := {}
Private cAliasQry	:= GetNextAlias()
Private oReport, oSection1          // objeto que contem o relatorio

aAdd( aPergs ,{1,"Marca..........: ",cCodigo ,"@!", , ""   ,'.T.',20,})
aadd( aPergs, {1,"Data Inicial...: ",dDataI  ,"@D", , ""   ,  "" ,60,})
aadd( aPergs, {1,"Data Final.....: ",dDataF  ,"@D", , ""   ,  "" ,60,})

If ParamBox(aPergs, "Par�metros p/ Relat�rio", aRetP, , , , , , , , ,.T.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Rela��o Picking  - Barueri") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza a impress�o de Confer�ncia da Rela��o Picking ") SIZE 268, 8 OF oDlg PIXEL
   @ 38, 15 SAY OemToAnsi("Da Caoa Pe�as.") SIZE 268, 8 OF oDlg PIXEL
   @ 48, 15 SAY OemToAnsi("Confirma Gera��o do Documento ? ") SIZE 268, 8 OF oDlg PIXEL
   DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpca:=1) ENABLE OF oDlg
   DEFINE SBUTTON FROM 80, 250 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
   ACTIVATE MSDIALOG oDlg CENTER

   If nOpca == 1
      oReport := ReportDef()
      oReport:PrintDialog()   
   Endif

Endif

RestArea( aAreaVS1 )

Return()


/*/{Protheus.doc} ZPECR005
Defini��o do Relatorio Picking 
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
Static Function ReportDef()

MV_PAR01 := aRetP[01]

oReport:= TReport():New("ZPECR005",' Rela��o Picking  ',"BARUERI", {|oReport| ReportPrint(oReport)},' Picking  ') 
oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.

//Verifica os par�metros selecionados via Pergunte
Pergunte(oReport:GetParam(),.F.)

oSection1 := TRSection():New(oReport,"Picking  - Barueri",{cAliasQry},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oSection1,"PICKING"      ,"cAliasQry","PICKING","@!",14,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"MARCA"        ,"cAliasQry","MARCA","@!",07,,)
TRCell():New(oSection1,"TIPO_PEDIDO"  ,"cAliasQry","TIPO_PEDIDO","@!",30,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CNPJ"         ,"cAliasQry","CNPJ","@!",20,,{||cAliasQry->CNPJ})
TRCell():New(oSection1,"NOME"         ,"cAliasQry","NOME","@!",40,/*lPixel*/,{||cAliasQry->NOME})
TRCell():New(oSection1,"DT_PICKING"   ,"cAliasQry","DT_PICKING",PesqPict("VS1","VS1_XDTEPI"),20,/*lPixel*/,{||cAliasQry->DATA_PICKING})
TRCell():New(oSection1,"UF"           ,"cAliasQry","UF","@!",05,/*lPxel*/,{||cAliasQry->UF})
TRCell():New(oSection1,"DIAS"         ,"cAliasQry","DIAS","@!",05,/*lPixel*/,{||STR(cAliasQry->DIAS)})
TRCell():New(oSection1,"TIPO_FRETE"   ,"cAliasQry","TIPO_FRETE","@!",10,/*lPixel*/,{||cAliasQry->TIPO_FRETE})
TRCell():New(oSection1,"TOTAL_PEDIDO" ,"cAliasQry","TOTAL_PEDIDO","@E 999,999,999,999.99",15,/*lPixel*/,{||cAliasQry->TOTAL_PEDIDO})
TRCell():New(oSection1,"QTDE_PECAS"   ,"cAliasQry","QTDE_PECAS","@E 999,999,999,999.99",15,/*lPixel*/,{||cAliasQry->QTDE_PECAS})
TRCell():New(oSection1,"QTDE_LINHAS"  ,"cAliasQry","QTDE_LINHAS","@E 999,999,999,999.99",15,/*lPixel*/,{||cAliasQry->QTDE_LINHAS})
TRCell():New(oSection1,"STATUS"       ,"cAliasQry","STATUS","@!",20,/*lPixel*/,{||cAliasQry->STATUS})

Return(oReport) 


/*/{Protheus.doc} ZPECR005
Impress�o do relat�rio Picking 
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
Static Function ReportPrint(oReport)
Local _cQ       := " "

//oSection1:BeginQuery()

_cQ := " "
_cQ += " SELECT VS1.VS1_XPICKI AS PICKING,   " 
_cQ += "   VS1.VS1_XMARCA AS MARCA,     "
_cQ += "   (SELECT SUBSTR(VX5_DESCRI,1,20) FROM " + RetSQLname("VX5") + " VX5A  "
_cQ += " 		WHERE VX5_CHAVE = 'Z00'                                  "
_cQ += "     		and VX5A.VX5_CODIGO = VS1.VS1_XTPPED                 "
_cQ += "     		and VX5A.d_e_l_e_t_ = ' ' ) AS TIPO_PEDIDO,          "
_cQ += "	A1.A1_CGC AS CNPJ,                               "
_cQ += "    A1.A1_NREDUZ AS NOME,                               "
_cQ += "    TO_DATE(VS1_XDTEPI ,'yyyymmdd') AS DT_PICKING,             "
_cQ += "    A1.A1_EST            AS UF,                                 "
_cQ += "    (ROUND(SYSDATE)-TO_DATE(VS1_XDTEPI,'yyyymmdd')) AS DIAS,     "
_cQ += "    (SELECT SUBSTR(VX5_DESCRI,1,20) FROM " + RetSQLname("VX5") + " VX5B  "
_cQ += "     	WHERE VX5_CHAVE = 'Z01'                         "
_cQ += "     	    AND VX5B.VX5_CODIGO =  VS1.VS1_XTPTRA           "
_cQ += "     	    AND VX5B.D_E_L_E_T_ = ' ') AS TIPO_FRETE,       "
_cQ += "    SUM(VS1_VTOTNF)   AS TOTAL_PEDIDO,                      "
_cQ += "    (SELECT SUM(VS3_QTDITE) FROM " + RetSQLname("VS3") + "  VS3QTD WHERE VS3QTD.D_E_L_E_T_ = ' ' AND VS3QTD.VS3_XPICKI = VS1.VS1_XPICKI) AS QTDE_PECAS,                        "
_cQ += "    (SELECT COUNT(VS3_CODITE) FROM " + RetSQLname("VS3") + " VS3QTD WHERE VS3QTD.D_E_L_E_T_ = ' ' AND VS3QTD.VS3_XPICKI = VS1.VS1_XPICKI) AS QTDE_LINHAS,                        "
_cQ += "    CASE                                                    "
_cQ += "     	WHEN VS1_STATUS = '4' THEN 'EM SEPARA��O'          "
_cQ += "     	WHEN VS1_STATUS = 'F' THEN 'A FATURAR'             "
_cQ += "        END AS STATUS                                       "
_cQ += "FROM "+ RetSQLname("VS1") +" VS1  "
_cQ += "    LEFT JOIN " + RetSQLname("SA1") + " A1 ON /*A1_FILIAL = VS1_FILIAL AND*/ A1_COD = VS1_CLIFAT AND A1_LOJA = VS1_LOJA AND A1.D_E_L_E_T_ = ' '  
_cQ += "        WHERE VS1.D_E_L_E_T_ = ' '                          "
_cQ += "        AND VS1_STATUS IN ('4','F')                         "
_cQ += "        AND VS1.VS1_XPICKI != ' '                      "
_cQ += "        AND VS1.VS1_XDTEPI != ' '                            "
//_cQ += "        AND VS1.VS1_XMARCA IN ('HYU') --PARAMETRO MARCA, "   

If !Empty(aRetP[01])
    _cQ += "    AND VS1.VS1_XMARCA = '" + aRetP[01] + "'"
EndIf
If !Empty(aRetP[02]) .Or. !Empty(aRetP[03])
    _cQ += "    AND VS1.VS1_XDTEPI BETWEEN '" + DTOS(aRetP[02]) + "' AND '" + DTOS(aRetP[03]) + "'"
EndIf
_cQ += " GROUP BY VS1_XPICKI, VS1.VS1_XMARCA, VS1_XTPPED, A1_CGC, A1_NREDUZ, VS1_XDTEPI, A1_EST, VS1_XTPTRA, VS1_STATUS"
_cQ += " ORDER BY DIAS DESC,  VS1_XTPPED " 
 
 dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQ),cAliasQry, .T., .T. ) 

//oSection1:EndQuery()
PQuery(cAliasQry,oReport) //Imprime
oReport:IncMeter()
oSection1:Finish() 

Return


/*/{Protheus.doc} ZPECR005
Imprimir a Query	
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
Static Function PQuery(cAliasQry,oReport)
Local cMens   := " "

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

    oSection1:Cell("PICKING"):SetValue((cAliasQry)->PICKING)
    oSection1:Cell("MARCA"):SetValue((cAliasQry)->MARCA)   
    oSection1:Cell("TIPO_PEDIDO"):SetValue((cAliasQry)->TIPO_PEDIDO)
    oSection1:Cell("CNPJ"):SetValue((cAliasQry)->CNPJ)
    oSection1:Cell("NOME"):SetValue((cAliasQry)->NOME)
    oSection1:Cell("DT_PICKING"):SetValue((cAliasQry)->DT_PICKING)
    oSection1:Cell("UF"):SetValue((cAliasQry)->UF)
    oSection1:Cell("DIAS"):SetValue((cAliasQry)->DIAS)
    oSection1:Cell("TIPO_FRETE"):SetValue((cAliasQry)->TIPO_FRETE)
    oSection1:Cell("TOTAL_PEDIDO"):SetValue((cAliasQry)->TOTAL_PEDIDO)
    oSection1:Cell("QTDE_PECAS"):SetValue((cAliasQry)->QTDE_PECAS)
    oSection1:Cell("QTDE_LINHAS"):SetValue((cAliasQry)->QTDE_LINHAS)
    oSection1:Cell("STATUS"):SetValue((cAliasQry)->STATUS)

	oSection1:PrintLine()
    TReport():Print() 
    cMens := " "
	(cAliasQry)->( DbSkip() )
	
EndDo

Return()
