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

/*/{Protheus.doc} ZPECR010
Relatorio Pedido Compra  (4 na planilha)
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
User Function ZPECR010()
Local aAreaSC7      := SC7->( GetArea() )
Local nOpca         := 1
Local aPergs        := {}
Local cPedido       := SPACE(06)
Local cCNPJ         := SPACE(14)
Local _aCombo    	:= {"CHE", "HYU", "SBR","   "}
Private MV_PAR01    := ""
Private dDataI      := Date()
Private dDataF      := Date()
Private aRetP       := {}
Private cAliasQry	:= GetNextAlias()
Private oReport, oSection1          // objeto que contem o relatorio

aAdd( aPergs, {2 ,"Marca.........:" ,"Marca" ,_aCombo ,30 ,"" ,.F. })
aAdd( aPergs ,{1,"N. Pedido .....: ",cPedido ,"@!", , "SC7",'.T.',20,.F.})
aAdd( aPergs ,{1,"N. CNPJ .......: ",cCNPJ   ,"@!", , "SA2",'.T.',70,.F.})
aadd( aPergs, {1,"Data Inicial...: ",dDataI  ,"@D", , ""   ,  "" ,60,.T.})
aadd( aPergs, {1,"Data Final.....: ",dDataF  ,"@D", , ""   ,  "" ,60,.T.})

If ParamBox(aPergs, "Parâmetros p/ Relatório", aRetP, , , , , , , , ,.T.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Relação Pedido Compra  - Barueri") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza a impressão de Conferência da Relação Pedido Compra ") SIZE 268, 8 OF oDlg PIXEL
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


/*/{Protheus.doc} ZPECR010
Definição do Relatorio Pedido Compra
@author Antonio Oliveira
@since 17/06/2022
@version 2.0
/*/
Static Function ReportDef()

MV_PAR01 := aRetP[01]

oReport:= TReport():New("ZPECR010",' Relação Pedido Compra  ',"BARUERI", {|oReport| ReportPrint(oReport)},' Pedido Compra  ') 
oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.

//Verifica os parâmetros selecionados via Pergunte
Pergunte(oReport:GetParam(),.F.)

oSection1 := TRSection():New(oReport,"Pedido Compra  - Barueri",{cAliasQry},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oSection1,"FILIAL"     ,"cAliasQry","FILIAL",PesqPict("SC7","C7_FILIAL"),TamSX3("C7_FILIAL")[1],/*lPixel*/,{||cAliasQry->FILIAL})
TRCell():New(oSection1,"NUMERO"     ,"cAliasQry","NUMERO",PesqPict("SC7","C7_NUM"),TamSX3("C7_NUM")[1],/*lPixel*/,{||cAliasQry->NUMERO})
TRCell():New(oSection1,"EMISSAO"    ,"cAliasQry","EMISSAO",PesqPict("SC7","C7_EMISSAO"),TamSX3("C7_EMISSAO")[1],/*lPixel*/,{||cAliasQry->EMISSAO})
TRCell():New(oSection1,"PRODUTO"    ,"cAliasQry","PRODUTO",PesqPict("SC7","C7_PRODUTO"),TamSX3("C7_PRODUTO")[1],/*lPixel*/,{||cAliasQry->PRODUTO})
TRCell():New(oSection1,"DESCRICAO"  ,"cAliasQry","DESCRICAO",PesqPict("SC7","C7_DESCRI"),TamSX3("C7_DESCRI")[1],/*lPixel*/,{||cAliasQry->DESCRICAO})
TRCell():New(oSection1,"CNPJ"       ,"cAliasQry","CNPJ","@!",12,/*lPixel*/,/*{||cAliasQry->CNPJ}*/)
TRCell():New(oSection1,"NOME"       ,"cAliasQry","NOME",PesqPict("SC7","C7_FORNECE"),TamSX3("C7_FORNECE")[1],/*lPixel*/,{||cAliasQry->FORNECE})
TRCell():New(oSection1,"FORNECEDOR" ,"cAliasQry","FORNECE",PesqPict("SC7","C7_FORNECE"),TamSX3("C7_FORNECE")[1],/*lPixel*/,{||cAliasQry->FORNECE})
TRCell():New(oSection1,"LOJA"       ,"cAliasQry","LOJA",PesqPict("SC7","C7_LOJA"),TamSX3("C7_LOJA")[1],/*lPixel*/,{||cAliasQry->LOJA})
TRCell():New(oSection1,"LINHA"      ,"cAliasQry","MARCA","@!",08,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"PEDIDA"     ,"cAliasQry","PEDIDA",PesqPict("SC7","C7_QUANT"),TamSX3("C7_QUANT")[1],/*lPixel*/,{||cAliasQry->PEDIDA})
TRCell():New(oSection1,"ATENDIDA"   ,"cAliasQry","ATENDIDA",PesqPict("SC7","C7_QUANT"),TamSX3("C7_QUANT")[1],/*lPixel*/,{||cAliasQry->ATENDIDA})
TRCell():New(oSection1,"PENDENTE"   ,"cAliasQry","PENDENTE",PesqPict("SC7","C7_QUANT"),TamSX3("C7_QUANT")[1],/*lPixel*/,{||cAliasQry->PENDENTE})
TRCell():New(oSection1,"FOB"        ,"cAliasQry","FOB",PesqPict("SC7","C7_PRECO"),TamSX3("C7_PRECO")[1],/*lPixel*/,{||cAliasQry->PRECO})
TRCell():New(oSection1,"TOTAL"      ,"cAliasQry","TOTAL",PesqPict("SC7","C7_TOTAL"),TamSX3("C7_TOTAL")[1],/*lPixel*/,{||cAliasQry->TOTAL})
TRCell():New(oSection1,"TPFRETE"    ,"cAliasQry","TPFRETE","@!",20,/*lPixel*/,,/*{||cAliasQry->TOTAL_PEDIDO}*/)

Return(oReport) 


/*/{Protheus.doc} ZPECR010
Impressão do relatório Carga 
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
Static Function ReportPrint(oReport)
Local _cQ       := " "

//oSection1:BeginQuery()
_cQ := " SELECT "
_cQ += "      C7_FILIAL     FILIAL     " 
_cQ += " 	, C7_PRODUTO    PRODUTO    "
_cQ += "    , C7_DESCRI     DESCRICAO  "
_cQ += "    , A2_CGC        CNPJ       "
_cQ += "    , C7_FORNECE    FORNECE    "
_cQ += "    , A2_NOME       NOME       "       
_cQ += "    , C7_LOJA       LOJA       "
_cQ += "    , SBM.BM_CODMAR MARCA      "
_cQ += "    , C7_QUANT      PEDIDA     "
_cQ += "    , YQ_DESCR      TPFRETE    "
_cQ += "    , C7_NUM        NUMERO     "
_cQ += " , Substr(TO_CHAR(SC7.C7_EMISSAO),7,2)||'/'||Substr(TO_CHAR(SC7.C7_EMISSAO),5,2)||'/'||Substr(TO_CHAR(SC7.C7_EMISSAO),1,4)  AS  EMISSAO"
_cQ += "    , C7_PRECO      PRECO      "
_cQ += "    , C7_TOTAL      TOTAL      "
_cQ += "    , C7_QUJE       ATENDIDA   "
_cQ += "    , C7_QUANT-C7_QUJE PENDENTE" 
_cQ += "      FROM " + RetSQLname("SC7") + " SC7 " 
_cQ += "      LEFT JOIN " + RetSQLname("SB1") + " SB1 "
_cQ += "          ON Substr(SB1.B1_FILIAL,1,6) = Substr(SC7.C7_FILIAL,1,6) "
_cQ += "          AND SB1.B1_COD = SC7.C7_PRODUTO      "
_cQ += "          AND SB1.D_E_L_E_T_ = ' '            "
_cQ += "      LEFT JOIN " + RetSQLname("SBM") + " SBM "
_cQ += "          ON Substr(SBM.BM_FILIAL,1,6) = Substr(SC7.C7_FILIAL,1,6) "
_cQ += "         AND SBM.BM_GRUPO = SB1.B1_GRUPO      "
_cQ += "         AND SBM.D_E_L_E_T_ = ' '             "
_cQ += "      LEFT JOIN " + RetSQLname("SA2") + " SA2 "
_cQ += "          ON SA2.A2_FILIAL= '" + xFilial('SA2') + "' " 
_cQ += "         AND SA2.A2_COD = SC7.C7_FORNECE      "
_cQ += "         AND SA2.A2_LOJA = SC7.C7_LOJA        "
_cQ += "         AND SA2.D_E_L_E_T_ = ' '             "
_cQ += "      LEFT JOIN " + RetSQLname("SW2") + " SW2 "
_cQ += "          ON SW2.W2_FILIAL = SC7.C7_FILIAL   " 
_cQ += "         AND SW2.W2_PO_NUM = SC7.C7_PO_EIC    "
_cQ += "         AND SW2.D_E_L_E_T_ = ' '             "
_cQ += "      LEFT JOIN " + RetSQLname("SYQ") + " SYQ "
_cQ += "          ON SYQ.YQ_FILIAL = '" + xFilial('SYQ') + "' " 
_cQ += "         AND SYQ.YQ_VIA    = SW2.W2_TIPO_EM   "
_cQ += "         AND SYQ.D_E_L_E_T_ = ' '             "
_cQ += " WHERE                                        "
_cQ += "     SC7.D_E_L_E_T_ = ' '       AND           "
If aRetP[01] <> "   "
    _cQ += "     SBM.BM_CODMAR = '" + aRetP[01] + "' AND "
endif
If aRetP[02] <> Space(06)
    _cQ += "         SC7.C7_NUM = '" + aRetP[02] + "' AND "
endif
If aRetP[03] <> Space(06)
    _cQ += "         SA2.A2_CGC = '" + aRetP[03] + "' AND "
endif
_cQ += "             SC7.C7_EMISSAO BETWEEN '" + DTOS(aRetP[04]) + "' AND '" + DTOS(aRetP[05]) + "'"
_cQ += "  ORDER BY 9 "

dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQ),cAliasQry, .T., .T. ) 

//oSection1:EndQuery()
PQuery(cAliasQry,oReport) //Imprime
oReport:IncMeter()
oSection1:Finish() 

Return


/*/{Protheus.doc} ZPECR010
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

    /*IF (cAliasQry)->CODIGO_CLIENTE <> aRetP[01] 
        (cAliasQry)->( DbSkip() )
        LOOP
    ENDIF*/

    oReport:IncMeter()

    oSection1:Cell("FILIAL"):SetValue((cAliasQry)->FILIAL)
    oSection1:Cell("NUMERO"):SetValue((cAliasQry)->NUMERO)
    oSection1:Cell("EMISSAO"):SetValue((cAliasQry)->EMISSAO)
    oSection1:Cell("PRODUTO"):SetValue((cAliasQry)->PRODUTO)
    oSection1:Cell("DESCRICAO"):SetValue((cAliasQry)->DESCRICAO)
    oSection1:Cell("CNPJ"):SetValue((cAliasQry)->CNPJ) 
    oSection1:Cell("NOME"):SetValue((cAliasQry)->NOME)   
    oSection1:Cell("FORNECE"):SetValue((cAliasQry)->FORNECE)
    oSection1:Cell("LOJA"):SetValue((cAliasQry)->LOJA)
    oSection1:Cell("MARCA"):SetValue((cAliasQry)->MARCA)
    oSection1:Cell("PEDIDA"):SetValue((cAliasQry)->PEDIDA)
    oSection1:Cell("ATENDIDA"):SetValue((cAliasQry)->ATENDIDA)
    oSection1:Cell("PENDENTE"):SetValue((cAliasQry)->PENDENTE)
    oSection1:Cell("FOB"):SetValue((cAliasQry)->PRECO)
    oSection1:Cell("TOTAL"):SetValue((cAliasQry)->TOTAL)
    oSection1:Cell("TPFRETE"):SetValue((cAliasQry)->TPFRETE)

	oSection1:PrintLine()
    TReport():Print() 

	(cAliasQry)->( DbSkip() )
	
EndDo

Return()
