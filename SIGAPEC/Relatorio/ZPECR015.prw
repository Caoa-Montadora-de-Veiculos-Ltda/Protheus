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

/*/{Protheus.doc} ZPECR015
Relatorio Resumido de Saidas (1 na planilha)
@author Antonio Oliveira
@since 20/06/2022
@version 2.0
Na query o campo Total é o D2_VALBRUT conf. solicitação do Andre de 13/07 às 17:43
/*/
User Function ZPECR015()
Local aAreaSC7      := SF2->( GetArea() )
Local nOpca         := 1
Local aPergs        := {}
Local _cFil         := SPACE(10)
Local _cCFOP        := SPACE(05)
Local _cTES         := SPACE(03)
Local _cGrupo       := SPACE(04)
Local _cCNPJ        := SPACE(14)
Local _cUF          := SPACE(02)
Local _cCódigo      := SPACE(23)
Local cNota         := SPACE(09)
Local _aCombo    	:= {"CHE", "HYU", "SUB","   "}
Private cDescricao  := "Relação Resumida de Saidas"
Private MV_PAR01    := ""
Private nResulte    := 0
Private dDataI      := Date()
Private dDataF      := Date()
Private aRetP       := {}
Private cAliasQry	:= GetNextAlias()
Private oReport, oSection1          // objeto que contem o relatorio

aAdd( aPergs ,{1,"Nota Fiscal....: ",cNota   ,"@!", , "SF2",'.T.',15,.F.})
aadd( aPergs, {1,"Data Inicial...: ",dDataI  ,"@D", , ""   ,  "" ,60,.T.})
aadd( aPergs, {1,"Data Final.....: ",dDataF  ,"@D", , ""   ,  "" ,60,.T.})
aAdd( aPergs ,{1,"Filial.........: ",_cFil   ,"@!", , ""   ,'.T.',50,.T.})
aAdd( aPergs ,{1,"CFPO...........: ",_cCFOP  ,"@!", , "13" ,'.T.',15,.F.})
aAdd( aPergs ,{1,"TES............: ",_cTES   ,"@!", , "SF4",'.T.',10,.F.})
aAdd( aPergs, {2 ,"Marca.........:" ,"Marca" ,_aCombo ,30 ,"" ,.F. })
aAdd( aPergs ,{1,"Grupo..........: ",_cGrupo ,"@!", , "SBM",'.T.',10,.F.})
aAdd( aPergs ,{1,"CNPJ...........: ",_cCNPJ  ,"@!", , "CLICGC",'.T.',60,.F.})
aAdd( aPergs ,{1,"UF.............: ",_cUF    ,"@!", , "CLIUF",'.T.',10,.F.})
aAdd( aPergs ,{1,"Código.........: ",_cCódigo,"@!", , "SB1",'.T.',80,.F.})

If ParamBox(aPergs, "Parâmetros p/ Relatório", aRetP, , , , , , , , ,.T.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi(cDescricao + " - Barueri") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza a impressão de Relação Resumida de Saidas ") SIZE 268, 8 OF oDlg PIXEL
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

If Select(cAliasQry) <> 0
	(cAliasQry)->(DbCloseArea())
	Ferase(cAliasQry+GetDBExtension())
Endif

RestArea( aAreaSC7 )

Return()


/*/{Protheus.doc} ZPECR015
Relatorio Resumido de Saidas (2 na planilha)
@author Antonio Oliveira
@since 20/06/2022
@version 2.0
/*/
Static Function ReportDef()

MV_PAR01 := aRetP[01]

oReport:= TReport():New("ZPECR015",cDescricao,"BARUERI", {|oReport| ReportPrint(oReport)},' Resumo Saidas ') 
oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.

//Verifica os parâmetros selecionados via Pergunte
Pergunte(oReport:GetParam(),.F.)
oSection1 := TRSection():New(oReport,cDescricao + " - Barueri",{cAliasQry},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oSection1,"FILIAL"   ,"cAliasQry","FILIAL",PesqPict("SF2","F2_FILIAL"),TamSX3("F2_FILIAL")[1],/*lPixel*/,{||cAliasQry->FILIAL})
//TRCell():New(oSection1,"PED_WEB"  ,"cAliasQry","PED_WEB","@!",40,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
//TRCell():New(oSection1,"TIPO_PEDIDO","cAliasQry","TIPO_PEDIDO","@!",40,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
//TRCell():New(oSection1,"DATA_ORC" ,"cAliasQry","DATA_ORC",PesqPict("SF1","F1_EMISSAO"),TamSX3("F1_EMISSAO")[1],/*lPixel*/,{||cAliasQry->DATA_ORC})
//TRCell():New(oSection1,"HORA_ORC" ,"cAliasQry","HORA_ORC",PesqPict("SF1","F1_EMISSAO"),TamSX3("F1_EMISSAO")[1],/*lPixel*/,{||cAliasQry->HORA_ORC})
//TRCell():New(oSection1,"ORCAMENTO","cAliasQry","ORCAMENTO","@!",40,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"FANTASIA" ,"cAliasQry","FANTASIA","@!",40,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"NOTA"     ,"cAliasQry","NOTA",PesqPict("SF2","F2_DOC"),TamSX3("F2_DOC")[1],/*lPixel*/,{||cAliasQry->NOTA})
TRCell():New(oSection1,"SERIE"    ,"cAliasQry","SERIE",PesqPict("SF2","F2_SERIE"),TamSX3("F2_SERIE")[1],/*lPixel*/,{||cAliasQry->SERIE})
TRCell():New(oSection1,"MARCA"    ,"cAliasQry","MARCA","@!",05,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"EMISSAO"  ,"cAliasQry","EMISSAO",PesqPict("SF2","F2_EMISSAO"),TamSX3("F2_EMISSAO")[1],/*lPixel*/,{||cAliasQry->EMISSAO})
TRCell():New(oSection1,"NOME"     ,"cAliasQry","NOME","@!",40,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"CNPJ"     ,"cAliasQry","CNPJ","@!",20,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"UF"       ,"cAliasQry","UF","@!",08,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"PRODUTO"  ,"cAliasQry","PRODUTO","@!",30,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"DESCRI"   ,"cAliasQry","DESCRI","@!",60,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"LINHA"    ,"cAliasQry","LINHA","@!",06,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"QUANT"    ,"cAliasQry","QUANT",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->QUANT})
TRCell():New(oSection1,"UNIT"     ,"cAliasQry","UNIT",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->UNIT})
TRCell():New(oSection1,"VALOR_CONTABIL","cAliasQry","VALOR_CONTABIL",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->VALOR_CONTABIL})
TRCell():New(oSection1,"CUSTO"    ,"cAliasQry","CUSTO",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->CUSTO})
TRCell():New(oSection1,"ICMS"     ,"cAliasQry","ICMS",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->ICMS})
TRCell():New(oSection1,"IPI"      ,"cAliasQry","IPI",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->IPI})
TRCell():New(oSection1,"PIS"      ,"cAliasQry","PIS",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->COFINS})
TRCell():New(oSection1,"COFINS"   ,"cAliasQry","COFINS",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->PIS})
TRCell():New(oSection1,"VAL_SUBS" ,"cAliasQry","VAL_SUBS",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->VAL_SUBS})
TRCell():New(oSection1,"PIS_ZMA"  ,"cAliasQry","PIS_ZMA",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->PISZMA})
TRCell():New(oSection1,"COFINS_ZMA","cAliasQry","COFINS_ZMA",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->COFINSZMA})
TRCell():New(oSection1,"VLR_LIQUIDO","cAliasQry","VLR_LIQUIDO",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->VALOR_CONTABIL-cAliasQry->TTL_IMP})
TRCell():New(oSection1,"VLR_TOTAL_IMPOSTOS","cAliasQry","VLR_TOTAL_IMPOSTOS",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->TTL_IMP})
TRCell():New(oSection1,"DESCON"   ,"cAliasQry","DESCON",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->DESCON})
TRCell():New(oSection1,"DESPESA"  ,"cAliasQry","DESPESA",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->DESPESA})
TRCell():New(oSection1,"GM_DIA_VLR","cAliasQry","GM_DIA_VLR",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->VALOR_CONTABIL-cAliasQry->TTL_IMP-cAliasQry->CUSTO})
TRCell():New(oSection1,"GM_DIA_%" ,"cAliasQry","GM_DIA_%",PesqPict("SF2","F2_VALBRUT"),TamSX3("F2_VALBRUT")[1],/*lPixel*/,{||cAliasQry->GM_DIA_VLR/cAliasQry->FAT_LIQ})
TRCell():New(oSection1,"TEXTO_TES"    ,"cAliasQry","TEXTO_TES","@!",40,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)

Return(oReport) 


/*/{Protheus.doc} ZPECR015
Relatorio Resumido de Saidas (2 na planilha)
@author Antonio Oliveira
@since 20/06/2022
@version 2.0
/*/
Static Function ReportPrint(oReport)
Local _cQ           := " "

//oSection1:BeginQuery()
_cQ := " SELECT DISTINCT"
_cQ += "        SF2.F2_FILIAL    AS FILIAL      "
//_cQ += "        , VS1_XPVAW      AS PED_WEB     "
//_cQ += " , Substr(TO_CHAR(VS1.VS1_XDTIMP),7,2)||'/'||Substr(TO_CHAR(VS1.VS1_XDTIMP),5,2)||'/'||Substr(TO_CHAR(VS1.VS1_XDTIMP),1,4)  AS  DATA_ORC"
//_cQ += "        , VS1_XHSIMP     AS HORA_ORC    " 
//_cQ += "        , VS1_NUMORC     AS ORCAMENTO   "
//_cQ += "        , SUBSTR(VX5.VX5_DESCRI,1,20) AS TIPO_PEDIDO  " 
_cQ += "        , SA1.A1_NREDUZ  AS FANTASIA    "     
_cQ += "        , SF2.F2_DOC     AS NOTA        "
_cQ += "        , SF2.F2_SERIE   AS SERIE       "
_cQ += "        , SBM.BM_CODMAR  AS MARCA       "
_cQ += " , Substr(TO_CHAR(SF2.F2_EMISSAO),7,2)||'/'||Substr(TO_CHAR(SF2.F2_EMISSAO),5,2)||'/'||Substr(TO_CHAR(SF2.F2_EMISSAO),1,4)  AS  EMISSAO"
_cQ += "        , SA1.A1_NOME    AS NOME        "
_cQ += "        , SA1.A1_CGC     AS CNPJ        "
_cQ += "        , SA1.A1_EST     AS UF          "
_cQ += " 	    , SD2.D2_COD     AS PRODUTO     "
_cQ += " 	    , SB1.B1_DESC    AS DESCRI      "
_cQ += " 	    , SB1.B1_TIPO    AS LINHA	    "  
_cQ += " 	    , SD2.D2_QUANT   AS QUANT       "
_cQ += " 	    , SD2.D2_PRCVEN  AS UNIT        "
//_cQ += " 	    , SD2.D2_TOTAL+SD2.D2_VALIPI+SD2.D2_ICMSRET+SD2.D2_DESPESA+SD2.D2_VALPS3+SD2.D2_VALCF3 AS VALOR_CONTABIL "
//_cQ += " 	    , SD2.D2_TOTAL+SD2.D2_VALIPI+SD2.D2_ICMSRET AS TOTAL "
_cQ += " 	    , SD2.D2_VALBRUT AS VALOR_CONTABIL       "
_cQ += " 	    , SD2.D2_CUSTO1  AS CUSTO       "
_cQ += " 	    , SD2.D2_VALICM  AS ICMS        "
_cQ += " 	    , SD2.D2_VALIPI  AS IPI         "
_cQ += " 	    , SD2.D2_VALIMP5 AS PIS         "
_cQ += " 	    , SD2.D2_VALIMP6 AS COFINS      "
_cQ += " 	    , SD2.D2_ICMSRET AS VAL_SUBS    "
_cQ += " 	    , SD2.D2_VALPS3  AS PISZMA      "
_cQ += " 	    , SD2.D2_VALCF3  AS COFINSZMA   "
_cQ += " 	    , SD2.D2_VALFRE  AS FRETE       "
_cQ += " 	    , SD2.D2_SEGURO  AS SEGURO      "
_cQ += " 	    , SD2.D2_DESPESA AS DESPESA     "
_cQ += " 	    , SD2.D2_VALACRS AS ACRESC      "
//_cQ += " 	    , SD2.D2_VALACRS AS ACRESC      "
_cQ += " 	    , SD2.D2_DESCON  AS DESCON      "
_cQ += "        , SF4.F4_TEXTO   AS TEXTO_TES	    "
_cQ += "        , SD2.D2_VALICM+SD2.D2_VALIPI+SD2.D2_VALIMP5+SD2.D2_VALIMP6+SD2.D2_ICMSRET+SD2.D2_VALPS3+SD2.D2_VALCF3  AS  TTL_IMP "
//_cQ += "        , SD2.D2_TOTAL - (SD2.D2_VALICM+SD2.D2_VALIPI+SD2.D2_VALIMP5+SD2.D2_VALIMP6+SD2.D2_ICMSRET+SD2.D2_VALPS3+SD2.D2_VALCF3) AS FAT_LIQ" 
//_cQ += "        , SD2.D2_TOTAL - (SD2.D2_VALICM+SD2.D2_VALIPI+SD2.D2_VALIMP5+SD2.D2_VALIMP6+SD2.D2_ICMSRET+SD2.D2_VALPS3+SD2.D2_VALCF3)-SD2.D2_CUSTO1 AS GM_DIA_VLR" 
_cQ += "        FROM " + RetSQLname("SD2") + " SD2 " 
_cQ += "           INNER JOIN " + RetSQLname("SF2") + " SF2  " 
_cQ += "              ON SF2.F2_FILIAL   = SD2.D2_FILIAL     "
_cQ += "              AND SF2.F2_DOC     = SD2.D2_DOC        "
_cQ += "              AND SF2.F2_SERIE   = SD2.D2_SERIE      "
_cQ += "              AND SF2.F2_CLIENTE = SD2.D2_CLIENTE    "
_cQ += "              AND SF2.F2_LOJA    = SD2.D2_LOJA       "
_cQ += "              AND SF2.D_E_L_E_T_ = ' '               "
_cQ += "           INNER JOIN " + RetSQLname("SB1") + " SB1  " 
_cQ += "              ON Substr(SB1.B1_FILIAL,1,6) = Substr(SF2.F2_FILIAL,1,6) "
_cQ += "              AND SB1.B1_COD = SD2.D2_COD            "
_cQ += "              AND SB1.D_E_L_E_T_ = ' '               "
_cQ += "           INNER JOIN " + RetSQLname("SF4") + " SF4  "  
_cQ += "              ON Substr(SF4.F4_FILIAL,1,6) = Substr(SD2.D2_FILIAL,1,6) "          
_cQ += "              AND SF4.F4_CODIGO = SD2.D2_TES         "
_cQ += "              AND SF4.D_E_L_E_T_ = ' '               "
_cQ += "           INNER JOIN " + RetSQLname("SA1") + " SA1  " 
_cQ += "              ON  SA1.A1_FILIAL = '" + xFilial('SA1') + "' "
_cQ += "              AND SA1.A1_COD    = SD2.D2_CLIENTE     "
_cQ += "              AND SA1.A1_LOJA   = SD2.D2_LOJA        "
_cQ += "              AND SA1.D_E_L_E_T_ = ' '               " 
_cQ += "           INNER JOIN " + RetSQLname("VS1") + " VS1  " 
_cQ += "              ON VS1.VS1_FILIAL  = SD2.D2_FILIAL     "
_cQ += "              AND VS1.VS1_NUMNFI = SD2.D2_DOC        "
_cQ += "              AND VS1.VS1_SERNFI = SD2.D2_SERIE      "
_cQ += "              AND VS1.VS1_NUMPED = SD2.D2_PEDIDO     "
_cQ += "              AND VS1.VS1_CLIFAT = SD2.D2_CLIENTE    "
_cQ += "              AND VS1.VS1_LOJA   = SD2.D2_LOJA       "
_cQ += "              AND VS1.D_E_L_E_T_ = ' '               "
_cQ += "           INNER JOIN " + RetSQLname("VS3") + " VS3  "               
_cQ += "              ON  VS3.VS3_FILIAL = VS1.VS1_FILIAL    "                   
_cQ += "              AND VS3.VS3_NUMORC = VS1.VS1_NUMORC    "                     
_cQ += "              AND VS3.VS3_CODITE = SD2.D2_COD        "
_cQ += "              AND VS3.D_E_L_E_T_ = ' '               "   
_cQ += "           LEFT JOIN " + RetSQLname("SBM") + " SBM   " 
_cQ += "              ON Substr(SBM.BM_FILIAL,1,6) = Substr(SF2.F2_FILIAL,1,6) "        
_cQ += "             AND SBM.BM_GRUPO = SB1.B1_GRUPO         "
_cQ += "             AND SBM.D_E_L_E_T_ = ' '                "  
//_cQ += "         LEFT JOIN " + RetSQLname("VX5") + " VX5   " 
//_cQ += "              ON VX5.VX5_FILIAL= '" + xFilial('VX5') + "' "
//_cQ += "              AND VX5.VX5_CHAVE = 'Z00'            "
//_cQ += "              AND VX5.VX5_CODIGO = VS1.VS1_XTPPED  "
_cQ += " WHERE                                               "  
If !Empty(aRetP[01])
    _cQ += "     SF2.F2_DOC = '" + aRetP[01] + "' AND "
endif
If !Empty(aRetP[04])
    _cQ += "     SF2.F2_FILIAL = '" + aRetP[04] + "' AND "
endif
If !Empty(aRetP[05])
    _cQ += "     SD2.D2_CF = '" + aRetP[05] + "' AND "
endif
If !Empty(aRetP[06])
    _cQ += "     SD2.D2_TES = '" + aRetP[06] + "' AND "
endif
If !Empty(aRetP[07])
    _cQ += "     VS1.VS1_XMARCA = '" + aRetP[07] + "' AND "
endif
If !Empty(aRetP[08])
    _cQ += "     SB1.B1_GRUPO = '" + aRetP[08] + "' AND "
endif
If !Empty(aRetP[09])
    _cQ += "     SA1.A1_CGC = '" + aRetP[09] + "' AND "
endif
If !Empty(aRetP[10])
    _cQ += "     SA1.A1_EST = '" + aRetP[10] + "' AND "
endif
If !Empty(aRetP[11])
    _cQ += "     SD2.D2_COD = '" + aRetP[11] + "' AND "
endif
_cQ += "         SD2.D2_EMISSAO BETWEEN '" + DTOS(aRetP[02]) + "' AND '" + DTOS(aRetP[03]) + "'"
_cQ += "  AND SD2.D_E_L_E_T_ = ' ' "
_cQ += "  ORDER BY 3 "

dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQ),cAliasQry, .T., .T. ) 
//oSection1:EndQuery()
PQuery(cAliasQry,oReport) //Imprime
oReport:IncMeter()
oSection1:Finish() 

Return


/*/{Protheus.doc} ZPECR015
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

    oSection1:Cell("FILIAL"):SetValue((cAliasQry)->FILIAL)
    //oSection1:Cell("PED_WEB"):SetValue((cAliasQry)->PED_WEB)
    //oSection1:Cell("TIPO_PEDIDO"):SetValue((cAliasQry)->TIPO_PEDIDO)
    //oSection1:Cell("DATA_ORC"):SetValue((cAliasQry)->DATA_ORC)
    //oSection1:Cell("HORA_ORC"):SetValue((cAliasQry)->HORA_ORC)
    //oSection1:Cell("ORCAMENTO"):SetValue((cAliasQry)->ORCAMENTO)
    oSection1:Cell("FANTASIA"):SetValue((cAliasQry)->FANTASIA)
    oSection1:Cell("NOTA"):SetValue((cAliasQry)->NOTA)
    oSection1:Cell("SERIE"):SetValue((cAliasQry)->SERIE)
    oSection1:Cell("MARCA"):SetValue((cAliasQry)->MARCA)    
    oSection1:Cell("EMISSAO"):SetValue((cAliasQry)->EMISSAO)
    oSection1:Cell("NOME"):SetValue((cAliasQry)->NOME)
    oSection1:Cell("CNPJ"):SetValue((cAliasQry)->CNPJ)
    oSection1:Cell("UF"):SetValue((cAliasQry)->UF)
    oSection1:Cell("PRODUTO"):SetValue((cAliasQry)->PRODUTO)
    oSection1:Cell("DESCRI"):SetValue((cAliasQry)->DESCRI)
    oSection1:Cell("LINHA"):SetValue((cAliasQry)->LINHA)
    oSection1:Cell("QUANT"):SetValue((cAliasQry)->QUANT)
    oSection1:Cell("UNIT"):SetValue((cAliasQry)->UNIT)
    oSection1:Cell("VALOR_CONTABIL"):SetValue((cAliasQry)->VALOR_CONTABIL)
    oSection1:Cell("CUSTO"):SetValue((cAliasQry)->CUSTO)
    oSection1:Cell("ICMS"):SetValue((cAliasQry)->ICMS)
    oSection1:Cell("IPI"):SetValue((cAliasQry)->IPI)
    oSection1:Cell("PIS"):SetValue((cAliasQry)->COFINS)
    oSection1:Cell("COFINS"):SetValue((cAliasQry)->PIS)   
    oSection1:Cell("VAL_SUBS"):SetValue((cAliasQry)->VAL_SUBS)
    oSection1:Cell("PIS_ZMA"):SetValue((cAliasQry)->PISZMA)
    oSection1:Cell("COFINS_ZMA"):SetValue((cAliasQry)->COFINSZMA)
    oSection1:Cell("TEXTO_TES"):SetValue((cAliasQry)->TEXTO_TES)
    oSection1:Cell("VLR_LIQUIDO"):SetValue((cAliasQry)->VALOR_CONTABIL-(cAliasQry)->TTL_IMP)
    oSection1:Cell("VLR_TOTAL_IMPOSTOS"):SetValue((cAliasQry)->TTL_IMP)
    oSection1:Cell("GM_DIA_VLR"):SetValue((cAliasQry)->VALOR_CONTABIL-(cAliasQry)->TTL_IMP-(cAliasQry)->CUSTO)
    oSection1:Cell("GM_DIA_%"):SetValue((((cAliasQry)->VALOR_CONTABIL-(cAliasQry)->TTL_IMP-(cAliasQry)->CUSTO))/((cAliasQry)->VALOR_CONTABIL-(cAliasQry)->TTL_IMP))
    oSection1:Cell("DESCON"):SetValue((cAliasQry)->DESCON)
    oSection1:Cell("DESPESA"):SetValue((cAliasQry)->DESPESA)
   
	oSection1:PrintLine()
    TReport():Print() 

	(cAliasQry)->( DbSkip() )
	
EndDo

Return()
