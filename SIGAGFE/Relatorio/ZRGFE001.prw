#Include "Protheus.Ch"
#Include "TOTVS.CH"
#Include "Report.Ch"
#include "Rwmake.ch"
#include "Ap5mail.ch"
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
/*/{Protheus.doc} ZRGFE001
Desenvolvimento de relatório GFE 
@obs    
@type function
@author Antonio Carlos
@since 11/01/2022
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
*/
User Function ZRGFE001()
Local oReport
Private _aNF        := {} 

If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Antonio Carlos        ³ Data ³11/01/2022³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relação de Controle de Fretes                              ³±±
±±³          ³ Relatório de Prazo de Entregas GFE                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatorio                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local cAliasQry  	:= GetNextAlias()
Local cPerg 		:= "ZGENF3"
Local oReport
Local oSection1

CriaSx1(cPerg)
Pergunte(cPerg,.F.) 

oReport := TReport():New("ZRGFE001","Relatório de Prazo de Entregas GFE",cPerg, {|oReport| ReportPrint(oReport,cAliasQry)},;
"Este programa tem como objetivo imprimir relatorio de acordo com os parametros informados pelo usuario. GFE")

oReport:SetLandScape(.T.)
oReport:SetTotalInLine(.F.) // Imprime o total em linhas

// Secao Principal
oSection1 	:= TRSection():New(oReport,,{cAliasQry},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oSection1,"CTE"               ,cAliasQry,"CTE"/*Alltrim(RetTitle("E1_VENCREA"))*/,PesqPict("GW4","GW4_NRDF")           ,TamSX3("GW4_NRDF")[1]   ,/*lPixel*/,{|| (cAliasQry)->CTE })
TRCell():New(oSection1,"DT_SAIDA"          ,cAliasQry,"DT_SAIDA"/*Alltrim(RetTitle("FT_PRODUTO"))*/,PesqPict("GW1","GW1_DTSAI")     ,TamSX3("GW1_DTSAI")[1]  ,/*lPixel*/,{|| (cAliasQry)->DT_SAIDA })
TRCell():New(oSection1,"NOTAS_FISCAIS"     ,cAliasQry,"NOTAS_FISCAIS"/*Alltrim(RetTitle("FT_PRODUTO"))*/,PesqPict("GW1","GW1_NRDC") ,TamSX3("GW1_NRDC")[1]   ,/*lPixel*/,{|| (cAliasQry)->NOTAS_FISCAIS })
TRCell():New(oSection1,"VOLUMES"           ,cAliasQry,"VOLUMES"/*Alltrim(RetTitle("FT_SERIE")) */,PesqPict("GWB","GWB_QTDE")        ,TamSX3("GWB_QTDE")[1]   ,/*lPixel*/,{|| (cAliasQry)->VOLUMES })
TRCell():New(oSection1,"REMETENTE"         ,cAliasQry,"REMETENTE"/*Alltrim(RetTitle("FT_CLIEFOR"))*/,PesqPict("GU3","GU3_NMEMIT")   ,TamSX3("GU3_NMEMIT")[1] ,/*lPixel*/,{|| (cAliasQry)->REMETENTE })
TRCell():New(oSection1,"DESTINTARIO"       ,cAliasQry,"DESTINTARIO"/*Alltrim(RetTitle("FT_LOJA")) */,PesqPict("GU3","GU3_NMEMIT")   ,TamSX3("GU3_NMEMIT")[1] ,/*lPixel*/,{|| (cAliasQry)->DESTINTARIO })
TRCell():New(oSection1,"CIDADE"            ,cAliasQry,"CIDADE"/*Alltrim(RetTitle("E1_NOMCLI"))*/,PesqPict("GU7","GU7_NMCID")        ,TamSX3("GU7_NMCID")[1]  ,/*lPixel*/,{|| (cAliasQry)->CIDADE })
TRCell():New(oSection1,"UF"                ,cAliasQry,"UF"/*Alltrim(RetTitle("FT_PRODUTO"))*/,PesqPict("GU7","GU7_CDUF")            ,TamSX3("GU7_CDUF")[1]   ,/*lPixel*/,{|| (cAliasQry)->UF })
TRCell():New(oSection1,"TP_FRETE"          ,cAliasQry,"TP_FRETE"/*Alltrim(RetTitle("FT_PRODUTO"))*/,PesqPict("GUB","GUB_DSCLFR")    ,TamSX3("GUB_DSCLFR")[1] ,/*lPixel*/,{|| (cAliasQry)->TP_FRETE })
TRCell():New(oSection1,"PREVISTA_ENT"      ,cAliasQry,"PREVISTA_ENT"/*Alltrim(RetTitle("FT_PRODUTO"))*/,PesqPict("GWU","GWU_DTPENT"),TamSX3("GWU_DTPENT")[1] ,/*lPixel*/,{|| (cAliasQry)->PREVISTA_ENT })
TRCell():New(oSection1,"DATA_ENTREGA"      ,cAliasQry,"DATA_ENTREGA"/*Alltrim(RetTitle("FT_PRODUTO"))*/,PesqPict("GWU","GWU_DTENT") ,TamSX3("GWU_DTENT")[1]  ,/*lPixel*/,{|| (cAliasQry)->DATA_ENTREGA })
TRCell():New(oSection1,"PRAZO_DE_ENTREGA"  ,cAliasQry,"PRAZO_DE_ENTREGA"/*Alltrim(RetTitle("FILIAL"))*/, "9,999,999,999" ,10        ,/*lPixel*/,{|| (cAliasQry)->PRAZO_DE_ENTREGA })
TRCell():New(oSection1,"DIAS_GASTOS_GFE"   ,cAliasQry,"DIAS_GASTOS_GFE"/*Alltrim(RetTitle("FT_NFISCAL"))*/,"9,999,999,999" ,10      ,/*lPixel*/,{|| (cAliasQry)->DIAS_GASTOS_GFE })
TRCell():New(oSection1,"DIFERENCA_GFE"     ,cAliasQry,"DIFERENCA_GFE"/*/Alltrim(RetTitle("FT_CFOP")) */,"9,999,999,999" ,10         ,/*lPixel*/,{|| (cAliasQry)->DIFERENCA_GFE })
TRCell():New(oSection1,"STATUS_GFE"        ,cAliasQry,"STATUS_GFE"/*Alltrim(RetTitle("FT_EMISSAO"))*/,"@!",20                       ,/*lPixel*/,{|| (cAliasQry)->STATUS_GFE })
TRCell():New(oSection1,"OCORRENCIAS"       ,cAliasQry,"OCORRENCIAS"/*Alltrim(RetTitle("FT_PRODUTO"))*/,"@!"       ,100 ,/*lPixel*/  ,{|| (cAliasQry)->OCORRENCIAS })
TRCell():New(oSection1,"DESCRICAO"	       ,cAliasQry,"DESCRICAO"/*Alltrim(RetTitle("FT_PRODUTO"))*/,"@!"         ,100 ,/*lPixel*/  ,{|| (cAliasQry)->DESCRICAO })
TRCell():New(oSection1,"MOTIVO_OCORRENCIAS",cAliasQry,"MOTIVO_OCORRENCIAS"/*Alltrim(RetTitle("FT_PRODUTO"))*/,"@!",100 ,/*lPixel*/  ,{|| (cAliasQry)->MOTIVO_OCORRENCIAS })
TRCell():New(oSection1,"TP_OPERACAO"       ,cAliasQry,"TP_OPERACAO"/*Alltrim(RetTitle("FT_VALCONT"))*/,PesqPict("GWU","GWU_CDTPOP") ,TamSX3("GWU_CDTPOP")[1] ,/*lPixel*/,{|| (cAliasQry)->TP_OPERACAO })

oSection1:Cell("CTE")                :SetHeaderAlign("CENTER")
oSection1:Cell("DT_SAIDA")           :SetHeaderAlign("CENTER")
oSection1:Cell("NOTAS_FISCAIS")      :SetHeaderAlign("CENTER")
oSection1:Cell("VOLUMES")            :SetHeaderAlign("CENTER")
oSection1:Cell("REMETENTE")          :SetHeaderAlign("CENTER")
oSection1:Cell("DESTINTARIO")        :SetHeaderAlign("CENTER")
oSection1:Cell("CIDADE")             :SetHeaderAlign("CENTER")
oSection1:Cell("UF")                 :SetHeaderAlign("CENTER")
oSection1:Cell("TP_FRETE")           :SetHeaderAlign("CENTER")
oSection1:Cell("PREVISTA_ENT")       :SetHeaderAlign("CENTER")
oSection1:Cell("DATA_ENTREGA")       :SetHeaderAlign("CENTER")
oSection1:Cell("PRAZO_DE_ENTREGA")   :SetHeaderAlign("CENTER")       
oSection1:Cell("DIAS_GASTOS_GFE")    :SetHeaderAlign("CENTER")
oSection1:Cell("DIFERENCA_GFE")      :SetHeaderAlign("CENTER")
oSection1:Cell("STATUS_GFE")         :SetHeaderAlign("CENTER")
oSection1:Cell("OCORRENCIAS")        :SetHeaderAlign("CENTER")
oSection1:Cell("DESCRICAO")          :SetHeaderAlign("CENTER")
oSection1:Cell("MOTIVO_OCORRENCIAS") :SetHeaderAlign("CENTER") 
oSection1:Cell("TP_OPERACAO")        :SetHeaderAlign("CENTER")
                                                           
Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint ³ Autor ³ Antonio Carlos        ³ Data ³11/01/2022³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que imprime as linhas detalhes do relatorio            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,cAliasQry)
Local _cQuery 	:= ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oReport:Section(1):BeginQuery()

_cQuery := "SELECT "      +Chr(10)
_cQuery += "     CASE WHEN GWU_DTPENT <> '        ' AND GW1_DTSAI <> '        ' "              +Chr(10)
_cQuery += "    THEN ( (to_date(GWU_DTPENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD')) "      +Chr(10)
_cQuery += "          - ( SELECT COUNT(*) FROM " + RetSqlName("GUW") + " I1 "                  +Chr(10)
_cQuery += "              WHERE "                      +Chr(10)
_cQuery += "              I1.GUW_DATA BETWEEN GW1.GW1_DTSAI AND GWU.GWU_DTPENT AND I1.GUW_TPDIA = '2') ) "  +Chr(10)
_cQuery += "    ELSE 0 END AS PRAZO_DE_ENTREGA,"       +Chr(10)
_cQuery += " 	CASE WHEN GWU_DTENT  <> '        ' AND GW1_DTSAI <> '        ' "               +Chr(10)
_cQuery += "    THEN ( (to_date(GWU_DTENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD')) "       +Chr(10) 
_cQuery += "         - ( SELECT COUNT(*) FROM " + RetSqlName("GUW") + " I1 "                   +Chr(10)
_cQuery += "             WHERE "                       +Chr(10)
_cQuery += "             I1.GUW_DATA BETWEEN GW1.GW1_DTSAI AND GWU.GWU_DTENT AND I1.GUW_TPDIA = '2') ) "     +Chr(10)
_cQuery += "    ELSE 0 END AS DIAS_GASTOS_GFE,"        +Chr(10)
_cQuery += "    CASE WHEN GWU_DTENT  <> '        ' AND GW1_DTSAI <> '        ' AND GWU_DTPENT <> '        '" +Chr(10)
_cQuery += "	THEN ( ( (to_date(GWU_DTENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD'))"         +Chr(10)
_cQuery += "            - ( SELECT COUNT(*) FROM " + RetSqlName("GUW") + " I1 "                   +Chr(10)
_cQuery += "                WHERE "                    +Chr(10)
_cQuery += "                I1.GUW_DATA BETWEEN GW1.GW1_DTSAI AND GWU.GWU_DTENT AND I1.GUW_TPDIA = '2') ) "   +Chr(10)
_cQuery += "            - ( (to_date(GWU_DTPENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD'))"      +Chr(10)
_cQuery += "                - ( SELECT COUNT(*) FROM " + RetSqlName("GUW") + " I1 "                +Chr(10)
_cQuery += "                    WHERE "               +Chr(10)
_cQuery += "                    I1.GUW_DATA BETWEEN GW1.GW1_DTSAI AND GWU.GWU_DTPENT AND I1.GUW_TPDIA = '2') ) )" +Chr(10)
_cQuery += "       ELSE 0 END AS DIFERENCA_GFE,"      +Chr(10)
_cQuery += " 	CASE "                                +Chr(10)
_cQuery += "		WHEN GWU_DTENT  <> '        ' AND GW1_DTSAI <> '        ' AND GWU_DTPENT <> '        ' AND GW1_DTSAI <> '        ' "      +Chr(10)
_cQuery += " 	          AND (to_date(GWU_DTPENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD')) - (to_date(GWU_DTENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD')) < 0 THEN 'Atraso na entrega'  " +Chr(10)
_cQuery += "		WHEN GWU_DTENT  <> '        ' AND GW1_DTSAI <> '        ' AND GWU_DTPENT <> '        ' AND GW1_DTSAI <> '        ' "      +Chr(10)
_cQuery += " 	          AND (to_date(GWU_DTPENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD')) - (to_date(GWU_DTENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD')) >= 0 THEN 'Normal'  "           +Chr(10)
_cQuery += "		WHEN GWU_DTENT  <> '        ' AND to_date(GWU_DTENT,'YYYYMMDD') >= sysdate THEN  'Em transito normal'"        +Chr(10)
_cQuery += "		WHEN GWU_DTENT  <> '        ' AND to_date(GWU_DTENT,'YYYYMMDD') < sysdate  THEN  'Em transito atrasado'"      +Chr(10)
_cQuery += "		ELSE ' ' END AS STATUS_GFE,"      +Chr(10)
_cQuery += "	GW4_NRDF CTE, "                       +Chr(10)
_cQuery += "    GWB_QTDE VOLUMES, GU3R.GU3_NMEMIT REMETENTE,"  +Chr(10)
_cQuery += "	GU3D.GU3_NMEMIT DESTINTARIO, GU7D.GU7_NMCID CIDADE, GU7D.GU7_CDUF UF, GUB_DSCLFR TP_FRETE,"      +Chr(10)
_cQuery += "	GWU_CDTPOP TP_OPERACAO, "             +Chr(10)
_cQuery += "    CASE"                                 +Chr(10)
_cQuery += "        WHEN GW1.GW1_DTSAI <> '        '" +Chr(10)
_cQuery += "        THEN TO_CHAR(To_date(GW1.GW1_DTSAI,  'yyyy/mm/dd'), 'dd/mm/yyyy') "      +Chr(10)
_cQuery += "        ELSE ' ' END AS DT_SAIDA,"        +Chr(10)
_cQuery += "    CASE"                                 +Chr(10)
_cQuery += "        WHEN GWU.GWU_DTPENT <> '        '    "      +Chr(10)
_cQuery += "        THEN TO_CHAR(To_date(GWU.GWU_DTPENT, 'yyyy/mm/dd'), 'dd/mm/yyyy') "      +Chr(10)
_cQuery += "        ELSE ' ' END AS PREVISTA_ENT,"              +Chr(10)
_cQuery += "    CASE    "                             +Chr(10)
_cQuery += "        WHEN GWU.GWU_DTENT <> '        '    "       +Chr(10)
_cQuery += "        THEN TO_CHAR(To_date(GWU.GWU_DTENT,  'yyyy/mm/dd'), 'dd/mm/yyyy') "      +Chr(10)
_cQuery += "        ELSE ' ' END AS DATA_ENTREGA,"    +Chr(10)
_cQuery += "    GW1.GW1_NRDC NOTAS_FISCAIS,"          +Chr(10)
_cQuery += "    LISTAGG(Trim(GWL.GWL_NROCO), '; ') WITHIN GROUP (ORDER BY GWL.GWL_NROCO) AS OCORRENCIAS,"       +Chr(10)
_cQuery += "    LISTAGG(Trim(GU5.GU5_DESC),  '; ') WITHIN GROUP (ORDER BY GU5.GU5_DESC)  AS DESCRICAO,"         +Chr(10)
_cQuery += "    LISTAGG(Trim(GU6.GU6_DESC),  ';') WITHIN GROUP (ORDER BY GU6.GU6_DESC)  AS MOTIVO_OCORRENCIAS" +Chr(10)
_cQuery += "	FROM  " + RetSqlName("GW1")  + " GW1 "+Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GW4") + " GW4  ON GW4_FILIAL = GW1_FILIAL AND GW4_EMISDC = GW1_EMISDC AND GW4_SERDC = GW1_SERDC AND GW4_NRDC = GW1_NRDC AND GW4_TPDC = GW1_CDTPDC AND GW4.D_E_L_E_T_= ' '"      +Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GWB") + " GWB  ON GWB_FILIAL = GW1_FILIAL AND GWB_CDTPDC = GW1_CDTPDC AND GWB_EMISDC = GW1_EMISDC AND GWB_SERDC = GW1_SERDC AND GWB_NRDC = GW1_NRDC AND GWB.D_E_L_E_T_ = ' '"   +Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GWU") + " GWU  ON GWU_FILIAL = GW1_FILIAL AND GWU_CDTPDC = GW1_CDTPDC AND GWU_EMISDC = GW1_EMISDC AND GWU_SERDC = GW1_SERDC AND GWU_NRDC = GW1_NRDC AND GWU.D_E_L_E_T_ = ' '"   +Chr(10)
_cQuery += "	INNER JOIN " + RetSqlName("GU3")+ " GU3R ON GU3R.GU3_CDEMIT = GW1.GW1_CDREM AND GU3R.D_E_L_E_T_ = ' '"  +Chr(10)
_cQuery += "	INNER JOIN " + RetSqlName("GU3")+ " GU3D ON GU3D.GU3_CDEMIT = GW1.GW1_CDDEST AND GU3D.D_E_L_E_T_ = ' '" +Chr(10)
_cQuery += "	INNER JOIN " + RetSqlName("GU7")+ " GU7D ON GU7D.GU7_NRCID = GWU.GWU_NRCIDD AND GU7D.D_E_L_E_T_ = ' '"  +Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GUB") + " GUB  ON GUB.GUB_CDCLFR = GWU.GWU_CDCLFR AND GUB.D_E_L_E_T_ = ' '"   +Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GWL") + " GWL  ON GWL.GWL_FILDC = GW1_FILIAL AND GWL_EMITDC = GW1_EMISDC AND GWL_TPDC = GW1_CDTPDC AND GWL_SERDC = GW1_SERDC AND GWL_NRDC = GW1_NRDC AND GWL.D_E_L_E_T_ = ' '"      +Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GWD") + " GWD  ON GWD.GWD_FILIAL = GWL.GWL_FILIAL AND GWD.GWD_NROCO = GWL.GWL_NROCO AND GWD.D_E_L_E_T_ = ' '"      +Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GU5") + " GU5  ON GU5.GU5_CDTIPO = GWD.GWD_CDTIPO AND GU5.D_E_L_E_T_ = ' '"   +Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GU6") + " GU6  ON GU6.GU6_CDMOT = GWD.GWD_CDMOT AND GU6.D_E_L_E_T_ = ' '"    +Chr(10)
_cQuery += "WHERE GW1.D_E_L_E_T_ = ' '"             + Chr(10)
_cQuery += "AND GW4_NRDF IS NULL "                  + Chr(10)
_cQuery += "AND GW1_FILIAL >= '"  + MV_PAR01 + "' " + Chr(10)
_cQuery += "AND GW1_FILIAL <= '"  + MV_PAR02 + "' " + Chr(10)
_cQuery += "AND GW1_DTEMIS >= '"  + DtoS(MV_PAR03)  + "' " + Chr(10)
_cQuery += "AND GW1_DTEMIS <= '"  + DtoS(MV_PAR04)  + "' " + Chr(10)
IF MV_PAR05 <> ' ' 
    _cQuery += "AND GW1_CDTPDC =  '"  + MV_PAR05 + "' " + Chr(10)
ENDIF
_cQuery += "AND GWU_CDTPOP >= '"  + MV_PAR06 + "' " + Chr(10)
_cQuery += "AND GWU_CDTPOP <= '"  + MV_PAR07 + "' " + Chr(10)
_cQuery += "AND GW1_TPFRET =  '"  + MV_PAR08 + "' " + Chr(10)
_cQuery += "GROUP BY GW1.GW1_NRDC,GW1_DTSAI,GWU_DTENT,GWU_DTPENT,GW4_NRDF,GWU_CDTPOP,GWB_QTDE,GU3R.GU3_NMEMIT,GU3D.GU3_NMEMIT,GU7D.GU7_NMCID,GU7D.GU7_CDUF,GUB_DSCLFR" +Chr(10)
_cQuery += " UNION ALL "      +Chr(10)
_cQuery += "    SELECT "      +Chr(10)
_cQuery += "     CASE WHEN GWU_DTPENT <> '        ' AND GW1_DTSAI <> '        ' "              +Chr(10)
_cQuery += "    THEN ( (to_date(GWU_DTPENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD')) "      +Chr(10)
_cQuery += "          - ( SELECT COUNT(*) FROM " + RetSqlName("GUW") + " I1 "                  +Chr(10)
_cQuery += "              WHERE "                      +Chr(10)
_cQuery += "              I1.GUW_DATA BETWEEN GW1.GW1_DTSAI AND GWU.GWU_DTPENT AND I1.GUW_TPDIA = '2') ) "  +Chr(10)
_cQuery += "    ELSE 0 END AS PRAZO_DE_ENTREGA,"       +Chr(10)
_cQuery += " 	CASE WHEN GWU_DTENT  <> '        ' AND GW1_DTSAI <> '        ' "               +Chr(10)
_cQuery += "    THEN ( (to_date(GWU_DTENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD')) "       +Chr(10) 
_cQuery += "         - ( SELECT COUNT(*) FROM " + RetSqlName("GUW") + " I1 "                   +Chr(10)
_cQuery += "             WHERE "                       +Chr(10)
_cQuery += "             I1.GUW_DATA BETWEEN GW1.GW1_DTSAI AND GWU.GWU_DTENT AND I1.GUW_TPDIA = '2') ) "     +Chr(10)
_cQuery += "    ELSE 0 END AS DIAS_GASTOS_GFE,"        +Chr(10)
_cQuery += "    CASE WHEN GWU_DTENT  <> '        ' AND GW1_DTSAI <> '        ' AND GWU_DTPENT <> '        '" +Chr(10)
_cQuery += "	THEN ( ( (to_date(GWU_DTENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD'))"         +Chr(10)
_cQuery += "            - ( SELECT COUNT(*) FROM " + RetSqlName("GUW") + " I1 "                   +Chr(10)
_cQuery += "                WHERE "                    +Chr(10)
_cQuery += "                I1.GUW_DATA BETWEEN GW1.GW1_DTSAI AND GWU.GWU_DTENT AND I1.GUW_TPDIA = '2') ) "   +Chr(10)
_cQuery += "            - ( (to_date(GWU_DTPENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD'))"      +Chr(10)
_cQuery += "                - ( SELECT COUNT(*) FROM " + RetSqlName("GUW") + " I1 "                +Chr(10)
_cQuery += "                    WHERE "               +Chr(10)
_cQuery += "                    I1.GUW_DATA BETWEEN GW1.GW1_DTSAI AND GWU.GWU_DTPENT AND I1.GUW_TPDIA = '2') ) )" +Chr(10)
_cQuery += "       ELSE 0 END AS DIFERENCA_GFE,"      +Chr(10)
_cQuery += " 	CASE "                                +Chr(10)
_cQuery += "		WHEN GWU_DTENT  <> '        ' AND GW1_DTSAI <> '        ' AND GWU_DTPENT <> '        ' AND GW1_DTSAI <> '        ' "      +Chr(10)
_cQuery += " 	          AND (to_date(GWU_DTPENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD')) - (to_date(GWU_DTENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD')) < 0 THEN 'Atraso na entrega'  " +Chr(10)
_cQuery += "		WHEN GWU_DTENT  <> '        ' AND GW1_DTSAI <> '        ' AND GWU_DTPENT <> '        ' AND GW1_DTSAI <> '        ' "      +Chr(10)
_cQuery += " 	          AND (to_date(GWU_DTPENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD')) - (to_date(GWU_DTENT,'YYYYMMDD') - to_date(GW1_DTSAI,'YYYYMMDD')) >= 0 THEN 'Normal'  "           +Chr(10)
_cQuery += "		WHEN GWU_DTENT  <> '        ' AND to_date(GWU_DTENT,'YYYYMMDD') >= sysdate THEN  'Em transito normal'"        +Chr(10)
_cQuery += "		WHEN GWU_DTENT  <> '        ' AND to_date(GWU_DTENT,'YYYYMMDD') < sysdate  THEN  'Em transito atrasado'"      +Chr(10)
_cQuery += "		ELSE ' ' END AS STATUS_GFE,"      +Chr(10)
_cQuery += "	GW4_NRDF CTE, "                       +Chr(10)
_cQuery += "    GWB_QTDE VOLUMES, GU3R.GU3_NMEMIT REMETENTE,"  +Chr(10)
_cQuery += "	GU3D.GU3_NMEMIT DESTINTARIO, GU7D.GU7_NMCID CIDADE, GU7D.GU7_CDUF UF, GUB_DSCLFR TP_FRETE,"      +Chr(10)
_cQuery += "	GWU_CDTPOP TP_OPERACAO, "             +Chr(10)
_cQuery += "    CASE"                                 +Chr(10)
_cQuery += "        WHEN GW1.GW1_DTSAI <> '        '" +Chr(10)
_cQuery += "        THEN TO_CHAR(To_date(GW1.GW1_DTSAI,  'yyyy/mm/dd'), 'dd/mm/yyyy') "      +Chr(10)
_cQuery += "        ELSE ' ' END AS DT_SAIDA,"        +Chr(10)
_cQuery += "    CASE"                                 +Chr(10)
_cQuery += "        WHEN GWU.GWU_DTPENT <> '        '    "      +Chr(10)
_cQuery += "        THEN TO_CHAR(To_date(GWU.GWU_DTPENT, 'yyyy/mm/dd'), 'dd/mm/yyyy') "      +Chr(10)
_cQuery += "        ELSE ' ' END AS PREVISTA_ENT,"              +Chr(10)
_cQuery += "    CASE    "                             +Chr(10)
_cQuery += "        WHEN GWU.GWU_DTENT <> '        '    "       +Chr(10)
_cQuery += "        THEN TO_CHAR(To_date(GWU.GWU_DTENT,  'yyyy/mm/dd'), 'dd/mm/yyyy') "      +Chr(10)
_cQuery += "        ELSE ' ' END AS DATA_ENTREGA,"    +Chr(10)
_cQuery += " CASE  "                                  +Chr(10)
_cQuery += "     WHEN GW4.GW4_NRDF <> '                '    "   +Chr(10)
_cQuery += "     THEN LISTAGG(Trim(GW1.GW1_NRDC), '; ') WITHIN GROUP (ORDER BY GW4.GW4_NRDF)      " +Chr(10)
_cQuery += "      ELSE ' ' END AS NOTAS_FISCAIS,     "          +Chr(10)
_cQuery += "    LISTAGG(Trim(GWL.GWL_NROCO), '; ') WITHIN GROUP (ORDER BY GWL.GWL_NROCO) AS OCORRENCIAS,"       +Chr(10)
_cQuery += "    LISTAGG(Trim(GU5.GU5_DESC),  '; ') WITHIN GROUP (ORDER BY GU5.GU5_DESC)  AS DESCRICAO,"         +Chr(10)
_cQuery += "    LISTAGG(Trim(GU6.GU6_DESC),  '; ') WITHIN GROUP (ORDER BY GU6.GU6_DESC)  AS MOTIVO_OCORRENCIAS" +Chr(10)
_cQuery += "	FROM  " + RetSqlName("GW1")  + " GW1 "+Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GW4") + " GW4  ON GW4_FILIAL = GW1_FILIAL AND GW4_EMISDC = GW1_EMISDC AND GW4_SERDC = GW1_SERDC AND GW4_NRDC = GW1_NRDC AND GW4_TPDC = GW1_CDTPDC AND GW4.D_E_L_E_T_= ' '"      +Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GWB") + " GWB  ON GWB_FILIAL = GW1_FILIAL AND GWB_CDTPDC = GW1_CDTPDC AND GWB_EMISDC = GW1_EMISDC AND GWB_SERDC = GW1_SERDC AND GWB_NRDC = GW1_NRDC AND GWB.D_E_L_E_T_ = ' '"   +Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GWU") + " GWU  ON GWU_FILIAL = GW1_FILIAL AND GWU_CDTPDC = GW1_CDTPDC AND GWU_EMISDC = GW1_EMISDC AND GWU_SERDC = GW1_SERDC AND GWU_NRDC = GW1_NRDC AND GWU.D_E_L_E_T_ = ' '"   +Chr(10)
_cQuery += "	INNER JOIN " + RetSqlName("GU3")+ " GU3R ON GU3R.GU3_CDEMIT = GW1.GW1_CDREM AND GU3R.D_E_L_E_T_ = ' '"  +Chr(10)
_cQuery += "	INNER JOIN " + RetSqlName("GU3")+ " GU3D ON GU3D.GU3_CDEMIT = GW1.GW1_CDDEST AND GU3D.D_E_L_E_T_ = ' '" +Chr(10)
_cQuery += "	INNER JOIN " + RetSqlName("GU7")+ " GU7D ON GU7D.GU7_NRCID = GWU.GWU_NRCIDD AND GU7D.D_E_L_E_T_ = ' '"  +Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GUB") + " GUB  ON GUB.GUB_CDCLFR = GWU.GWU_CDCLFR AND GUB.D_E_L_E_T_ = ' '"   +Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GWL") + " GWL  ON GWL.GWL_FILDC = GW1_FILIAL AND GWL_EMITDC = GW1_EMISDC AND GWL_TPDC = GW1_CDTPDC AND GWL_SERDC = GW1_SERDC AND GWL_NRDC = GW1_NRDC AND GWL.D_E_L_E_T_ = ' '"      +Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GWD") + " GWD  ON GWD.GWD_FILIAL = GWL.GWL_FILIAL AND GWD.GWD_NROCO = GWL.GWL_NROCO AND GWD.D_E_L_E_T_ = ' '"      +Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GU5") + " GU5  ON GU5.GU5_CDTIPO = GWD.GWD_CDTIPO AND GU5.D_E_L_E_T_ = ' '"   +Chr(10)
_cQuery += "	LEFT JOIN " + RetSqlName("GU6") + " GU6  ON GU6.GU6_CDMOT = GWD.GWD_CDMOT AND GU6.D_E_L_E_T_ = ' '"    +Chr(10)
_cQuery += "WHERE GW1.D_E_L_E_T_ = ' '"             + Chr(10)
_cQuery += "AND GW4_NRDF <>  '                '"    + Chr(10)
_cQuery += "AND GW1_FILIAL >= '"  + MV_PAR01 + "' " + Chr(10)
_cQuery += "AND GW1_FILIAL <= '"  + MV_PAR02 + "' " + Chr(10)
_cQuery += "AND GW1_DTEMIS >= '"  + DtoS(MV_PAR03)  + "' " + Chr(10)
_cQuery += "AND GW1_DTEMIS <= '"  + DtoS(MV_PAR04)  + "' " + Chr(10)
IF MV_PAR05 <> ' ' 
    _cQuery += "AND GW1_CDTPDC =  '"  + MV_PAR05 + "' " + Chr(10)
ENDIF
//_cQuery += "AND GW1_CDTPDC =  '"  + MV_PAR05 + "' " + Chr(10)
_cQuery += "AND GWU_CDTPOP >= '"  + MV_PAR06 + "' " + Chr(10)
_cQuery += "AND GWU_CDTPOP <= '"  + MV_PAR07 + "' " + Chr(10)
_cQuery += "AND GW1_TPFRET =  '"  + MV_PAR08 + "' " + Chr(10)
_cQuery += "GROUP BY GW1_DTSAI,GWU_DTENT,GWU_DTPENT,GW4_NRDF,GWU_CDTPOP,GWB_QTDE,GU3R.GU3_NMEMIT,GU3D.GU3_NMEMIT,GU7D.GU7_NMCID,GU7D.GU7_CDUF,GUB_DSCLFR" +Chr(10)
_cQuery += "ORDER BY 5"    + Chr(10)

//MemoWrit("ZRGFE001.SQL",_cQuery) //Gravei a Query em TXT p/Testes
dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQuery),cAliasQry, .T., .T. ) 

oReport:Section(1):EndQuery()
oReport:Section(1):Init()
PQuery(cAliasQry,oReport) //Imprime
oReport:Section(1):Finish() 
 
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PQuery	³ Autor ³ Antonio Carlos        ³ Data ³11/01/2022³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para imprimir a Query				 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PQuery(cAliasQry,oReport)

//Loc l oBreak
//Local Section1  := oReport:Section(1) 

//oBreak := TRBreak():New(Section1, {||  (cAliasQry)->(CR_FORNECE)    }/*Quebra*/,;
//	 {|| "Total Contabil... "  })

//TRFunction():New(Section1:Cell("CR_TOTAL"),"","SUM",oBreak,,,,.F.,.F.)

dbSelectArea(cAliasQry)
dBGotop()

oReport:SetMeter((cAliasQry)->(LastRec()))
//oReport:Section(1):PrintLine()
//oReport:IncMeter()

Do While !(cAliasQry)->( Eof() )
	oReport:Section(1):PrintLine()
	(cAliasQry)->( DbSkip() )
	oReport:IncMeter()
EndDo

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaSx1   ºAutor  ³   	    		 º Data ³ 11/01/2022  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para criaçao do grupo de perguntas	  		          º±±
±±º                  .				                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                            	              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CriaSx1(cPerg)
Local aArea    := GetArea()    				// Salva ambiente atual para posterior restauracao
Local _sAlias  := Alias()
Local aRegs    := {}
Local i,j

dbSelectArea("SX1")
dbgotop()
dbSetOrder(1)  

cPerg := PADR(cPerg,10)

AAdd(aRegs,{cPerg,"01","Filial inicial","","","mv_ch1","C",10,0,0,"G","","MV_PAR01","","","","2020012001","","","","","","","","","","","","","","","","","","","","","","","","Filial inicial"})
AAdd(aRegs,{cPerg,"02","Filial final","","","mv_ch2","C",10,0,0,"G","","MV_PAR02","","","","2020012001","","","","","","","","","","","","","","","","","","","","","","",""})
AAdd(aRegs,{cPerg,"03","Emissao de","","","mv_ch3","D",08,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","Data Emissão"})
AAdd(aRegs,{cPerg,"04","Emissao ate","","","mv_ch4","D",08,0,0,"G","","MV_PAR04","","","",DATE(),"","","","","","","","","","","","","","","","","","","","","","",""})
AAdd(aRegs,{cPerg,"05","Tipo Docto","","","mv_ch5","C",60,0,0,"G","","MV_PAR05", "","","","NFS","","","","","","","","","","","","","","","","","","","","","","","","Tipo Documento"})
AAdd(aRegs,{cPerg,"06","Cod.Oper. de","","","mv_ch6","C",50,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","Código Operação"})
AAdd(aRegs,{cPerg,"07","Cod.Oper. ate","","","mv_ch7","C",50,0,0,"G","","MV_PAR07","","","","ZZZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","","",""})
AAdd(aRegs,{cPerg,"08","TpFrete","","","mv_ch8","C",06,0,0,"G","","MV_PAR08","","","","1","","","","","","","","","","","","","","","","","","","","","","","","Tipo Frete"})

For i := 1 to Len(aRegs)
	If !dbSeek(cPerg + aRegs[i, 2])
		RecLock("SX1", .T.)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j, aRegs[i, j])
			Endif
		Next
		MsUnlock()
	Endif
Next
DbSelectArea(_sAlias)

RestArea(aArea)
Return 
