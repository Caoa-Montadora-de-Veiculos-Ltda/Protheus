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

/*/{Protheus.doc} ZPECR011
Relatorio Resumido de Entradas (2 na planilha)
@author Antonio Oliveira
@since 20/06/2022
@version 2.0
/*/
User Function ZPECR011()
Local aAreaSF1      := SF1->( GetArea() )
Local nOpca         := 1
Local aPergs        := {}
Local cNota         := SPACE(09)
Local _cFil         := SPACE(10)
Local _cCFOP        := SPACE(05)
Local _cTES         := SPACE(03)
Local _cGrupo       := SPACE(04)
Local _cCNPJ        := SPACE(14)
Local _cUF          := SPACE(02)
Local _cCódigo      := SPACE(23)
Local _aCombo    	:= {"CHE", "HYU", "SUB","   "}
Private cDescricao  := "Relação Resumida de Entradas"
Private MV_PAR01    := ""
Private dDataI      := Date()
Private dDataF      := Date()
Private aRetP       := {}
Private cAliasQry	:= GetNextAlias()
Private oReport, oSection1          // objeto que contem o relatorio


aAdd( aPergs ,{1,"Nota Fiscal....: ",cNota   ,"@!", , "SF1",'.T.',15,.F.})
aadd( aPergs, {1,"Data Inicial...: ",dDataI  ,"@D", , ""   ,  "" ,60,.T.})
aadd( aPergs, {1,"Data Final.....: ",dDataF  ,"@D", , ""   ,  "" ,60,.T.})
aAdd( aPergs ,{1,"Filial.........: ",_cFil   ,"@!", , ""   ,'.T.',50,.T.})
aAdd( aPergs ,{1,"CFOP...........: ",_cCFOP  ,"@!", , "13" ,'.T.',15,.F.})
aAdd( aPergs ,{1,"TES............: ",_cTES   ,"@!", , "SF4",'.T.',10,.F.})
aAdd( aPergs, {2 ,"Marca.........:" ,"Marca" ,_aCombo ,30 ,"" ,.F. })
aAdd( aPergs ,{1,"Grupo..........: ",_cGrupo ,"@!", , "SBM",'.T.',10,.F.})
aAdd( aPergs ,{1,"CNPJ...........: ",_cCNPJ  ,"@!", , "CLICGC",'.T.',60,.F.})
aAdd( aPergs ,{1,"UF.............: ",_cUF    ,"@!", , "CLIUF",'.T.',10,.F.})
aAdd( aPergs ,{1,"Código.........: ",_cCódigo,"@!", , "SB1",'.T.',80,.F.})

If ParamBox(aPergs, "Parâmetros p/ Relatório", aRetP, , , , , , , , ,.T.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi(cDescricao + " - Barueri") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza a impressão de Relação Resumida de Entradas ") SIZE 268, 8 OF oDlg PIXEL
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

RestArea( aAreaSF1 )

Return()


/*/{Protheus.doc} ZPECR011
Relatorio Resumido de Entradas (2 na planilha)
@author Antonio Oliveira
@since 20/06/2022
@version 2.0
/*/
Static Function ReportDef()

MV_PAR01 := aRetP[01]

oReport:= TReport():New("ZPECR011",cDescricao,"BARUERI", {|oReport| ReportPrint(oReport)},' Resumo Entradas ') 
oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.

//Verifica os parâmetros selecionados via Pergunte
Pergunte(oReport:GetParam(),.F.)

oSection1 := TRSection():New(oReport,cDescricao + " - Barueri",{cAliasQry},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oSection1,"FILIAL"   ,"cAliasQry","FILIAL",PesqPict("SF1","F1_FILIAL"),TamSX3("F1_FILIAL")[1],/*lPixel*/,{||cAliasQry->FILIAL})
TRCell():New(oSection1,"NOTA"     ,"cAliasQry","NOTA",PesqPict("SF1","F1_DOC"),TamSX3("F1_DOC")[1],/*lPixel*/,{||cAliasQry->NOTA})
TRCell():New(oSection1,"SERIE"    ,"cAliasQry","SERIE",PesqPict("SF1","F1_SERIE"),TamSX3("F1_SERIE")[1],/*lPixel*/,{||cAliasQry->SERIE})
TRCell():New(oSection1,"TIPO_NF"  ,"cAliasQry","TIPO_NF",PesqPict("SF1","F1_ESPECIE"),TamSX3("F1_ESPECIE")[1],/*lPixel*/,{||cAliasQry->TIPO_NF})
TRCell():New(oSection1,"EMISSAO"  ,"cAliasQry","EMISSAO",PesqPict("SF1","F1_EMISSAO"),TamSX3("F1_EMISSAO")[1],/*lPixel*/,{||cAliasQry->EMISSAO})
TRCell():New(oSection1,"DIGITACAO","cAliasQry","DIGITACAO",PesqPict("SF1","F1_EMISSAO"),TamSX3("F1_EMISSAO")[1],/*lPixel*/,{||cAliasQry->DIGITACAO})
TRCell():New(oSection1,"CFOP"     ,"cAliasQry","CFOP","@!",10,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"TEXTO_TES","cAliasQry","TEXTO_TES","@!",40,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"NOME"     ,"cAliasQry","NOME","@!",40,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"CNPJ"     ,"cAliasQry","CNPJ","@!",20,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"UF"       ,"cAliasQry","UF","@!",08,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"PRODUTO"  ,"cAliasQry","PRODUTO","@!",30,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"DESCRI"   ,"cAliasQry","DESCRI","@!",60,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"LINHA"    ,"cAliasQry","LINHA","@!",06,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"SUBLINHA" ,"cAliasQry","SUBLINHA","@!",06,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"MARCA"    ,"cAliasQry","MARCA","@!",06,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"QUANT"    ,"cAliasQry","QUANT",PesqPict("SF1","F1_VALMERC"),TamSX3("F1_VALMERC")[1],/*lPixel*/,{||cAliasQry->QUANT})
TRCell():New(oSection1,"UNIT"     ,"cAliasQry","UNIT",PesqPict("SF1","F1_VALMERC"),TamSX3("F1_VALMERC")[1],/*lPixel*/,{||cAliasQry->UNIT})
TRCell():New(oSection1,"TOTAL"    ,"cAliasQry","TOTAL",PesqPict("SF1","F1_VALBRUT"),TamSX3("F1_VALBRUT")[1],/*lPixel*/,{||cAliasQry->TOTAL})
TRCell():New(oSection1,"CUSTO"    ,"cAliasQry","CUSTO",PesqPict("SF1","F1_VALMERC"),TamSX3("F1_VALMERC")[1],/*lPixel*/,{||cAliasQry->CUSTO})
TRCell():New(oSection1,"NCM"      ,"cAliasQry","NCM","@!",12,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"ICMS"     ,"cAliasQry","ICMS",PesqPict("SF1","F1_VALMERC"),TamSX3("F1_VALMERC")[1],/*lPixel*/,{||cAliasQry->ICMS})
TRCell():New(oSection1,"IPI"      ,"cAliasQry","IPI",PesqPict("SF1","F1_VALMERC"),TamSX3("F1_VALMERC")[1],/*lPixel*/,{||cAliasQry->IPI})
TRCell():New(oSection1,"VAL_SUBS" ,"cAliasQry","VAL_SUBS",PesqPict("SF1","F1_VALMERC"),TamSX3("F1_VALMERC")[1],/*lPixel*/,{||cAliasQry->VAL_SUBS})
TRCell():New(oSection1,"PIS"      ,"cAliasQry","PIS",PesqPict("SF1","F1_VALMERC"),TamSX3("F1_VALMERC")[1],/*lPixel*/,{||cAliasQry->PIS})
TRCell():New(oSection1,"COFINS"   ,"cAliasQry","COFINS",PesqPict("SF1","F1_VALMERC"),TamSX3("F1_VALMERC")[1],/*lPixel*/,{||cAliasQry->COFINS})
TRCell():New(oSection1,"VAL_II"   ,"cAliasQry","VAL_II",PesqPict("SF1","F1_VALMERC"),TamSX3("F1_VALMERC")[1],/*lPixel*/,{||cAliasQry->VAL_II})
TRCell():New(oSection1,"FRETE"    ,"cAliasQry","FRETE",PesqPict("SF1","F1_VALMERC"),TamSX3("F1_VALMERC")[1],/*lPixel*/,{||cAliasQry->FRETE})
TRCell():New(oSection1,"SEGURO"   ,"cAliasQry","SEGURO",PesqPict("SF1","F1_VALMERC"),TamSX3("F1_VALMERC")[1],/*lPixel*/,{||cAliasQry->SEGURO})
TRCell():New(oSection1,"DESPESA"  ,"cAliasQry","DESPESA",PesqPict("SF1","F1_VALMERC"),TamSX3("F1_VALMERC")[1],/*lPixel*/,{||cAliasQry->DESPESA})
TRCell():New(oSection1,"ACRESC"   ,"cAliasQry","ACRESC",PesqPict("SF1","F1_VALMERC"),TamSX3("F1_VALMERC")[1],/*lPixel*/,{||cAliasQry->ACRESC})

Return(oReport) 


/*/{Protheus.doc} ZPECR011
Relatorio Resumido de Entradas (2 na planilha)
@author Antonio Oliveira
@since 20/06/2022
@version 2.0
/*/
Static Function ReportPrint(oReport)
Local _cQ       := " "

//oSection1:BeginQuery()
_cQ := " SELECT "
_cQ += "    SF1.F1_FILIAL     FILIAL     " 
_cQ += " 	, SF1.F1_DOC        NOTA     "
_cQ += "    , SF1.F1_SERIE      SERIE    "
_cQ += "    , SF1.F1_ESPECIE    TIPO_NF  "
_cQ += "    , Substr(TO_CHAR(SF1.F1_EMISSAO),7,2)||'/'||Substr(TO_CHAR(SF1.F1_EMISSAO),5,2)||'/'||Substr(TO_CHAR(SF1.F1_EMISSAO),1,4)  AS  EMISSAO  "
_cQ += "    , Substr(TO_CHAR(SD1.D1_DTDIGIT),7,2)||'/'||Substr(TO_CHAR(SD1.D1_DTDIGIT),5,2)||'/'||Substr(TO_CHAR(SD1.D1_DTDIGIT),1,4)  AS  DIGITACAO"
_cQ += "    , SD1.D1_CF         CFOP     "
_cQ += "    , SF4.F4_TEXTO      TEXTO_TES,   "
_cQ += " CASE    "   
_cQ += "	WHEN SF1.F1_TIPO = 'D'  OR SF1.F1_TIPO = 'B'    " 
_cQ += "	THEN SA1.A1_NOME    " 
_cQ += "	ELSE SA2.A2_NOME    " 
_cQ += "	END AS NOME,    " 
_cQ += " CASE    "   
_cQ += "	WHEN SF1.F1_TIPO = 'D'  OR SF1.F1_TIPO = 'B'    " 
_cQ += "	THEN SA1.A1_CGC    " 
_cQ += "	ELSE SA2.A2_CGC    "
_cQ += "	END AS CNPJ,    " 
_cQ += " CASE    "  
_cQ += "	WHEN SF1.F1_TIPO = 'D'  OR SF1.F1_TIPO = 'B'    " 
_cQ += "	THEN SA1.A1_EST    "  
_cQ += "	ELSE SA2.A2_EST    " 
_cQ += "	END AS UF    " 
_cQ += "    , SD1.D1_COD        PRODUTO  "
_cQ += "    , SB1.B1_DESC       DESCRI   "
_cQ += "    , SB1.B1_TIPO       LINHA    "
_cQ += "    , SB5.B5_CODLIN     SUBLINHA "
_cQ += "    , SBM.BM_CODMAR     MARCA    "
_cQ += "    , SD1.D1_QUANT      QUANT    "
_cQ += "    , SD1.D1_VUNIT      UNIT     "
_cQ += "    , SD1.D1_TOTAL      TOTAL    "
_cQ += "    , SD1.D1_CUSTO      CUSTO    "
_cQ += "    , SB1.B1_POSIPI     NCM      "
_cQ += "    , SD1.D1_VALICM     ICMS     "
_cQ += "    , SD1.D1_VALIPI     IPI      "
_cQ += "    , SD1.D1_BRICMS     VAL_SUBS "
_cQ += "    , SD1.D1_VALIMP5    PIS      "
_cQ += "    , SD1.D1_VALIMP6    COFINS   "
_cQ += "    , SD1.D1_II         VAL_II   "
_cQ += "    , SD1.D1_VALFRE     FRETE    "
_cQ += "    , SD1.D1_SEGURO     SEGURO   "
_cQ += "    , SD1.D1_DESPESA    DESPESA  "
_cQ += "    , SD1.D1_VALACRS    ACRESC   "
_cQ += "      FROM " + RetSQLname("SF1") + " SF1 " 
_cQ += "          LEFT JOIN " + RetSQLname("SD1") + " SD1 " 
_cQ += "              ON SD1.D1_FILIAL   = SF1.F1_FILIAL  "
_cQ += "              AND SD1.D1_DOC     = SF1.F1_DOC     "
_cQ += "              AND SD1.D1_SERIE   = SF1.F1_SERIE   "
_cQ += "              AND SD1.D1_FORNECE = SF1.F1_FORNECE "
_cQ += "              AND SD1.D1_LOJA    = SF1.F1_LOJA    "
_cQ += "              AND SD1.D_E_L_E_T_ = ' '            "
_cQ += "          LEFT JOIN " + RetSQLname("SB1") + " SB1 "
_cQ += "              ON Substr(SB1.B1_FILIAL,1,6) = Substr(SF1.F1_FILIAL,1,6) "
_cQ += "              AND SB1.B1_COD = SD1.D1_COD         "
_cQ += "              AND SB1.D_E_L_E_T_ = ' '            "
_cQ += "          LEFT JOIN " + RetSQLname("SBM") + " SBM "
_cQ += "              ON Substr(SBM.BM_FILIAL,1,6) = Substr(SF1.F1_FILIAL,1,6) "  
_cQ += "              AND SBM.BM_GRUPO = SB1.B1_GRUPO     "
_cQ += "              AND SBM.D_E_L_E_T_ = ' '            "
_cQ += "          LEFT JOIN " + RetSQLname("SB5") + " SB5 "  
_cQ += "              ON Substr(SB5.B5_FILIAL,1,6) = Substr(SD1.D1_FILIAL,1,6) "             
_cQ += "              AND SB5.B5_COD = SD1.D1_COD         "
_cQ += "              AND SB5.D_E_L_E_T_ = ' '            "
_cQ += "          LEFT JOIN " + RetSQLname("SF4") + " SF4 " 
_cQ += "              ON Substr(SF4.F4_FILIAL,1,6) = Substr(SD1.D1_FILIAL,1,6) "           
_cQ += "              AND SF4.F4_CODIGO = SD1.D1_TES      " 
_cQ += "              AND SF4.D_E_L_E_T_ = ' '            "  
_cQ += "          LEFT JOIN " + RetSQLname("SA2") + " SA2 " 
_cQ += "              ON SA2.A2_FILIAL= '" + xFilial('SA2') + "' " 
_cQ += "              AND SA2.A2_COD = SF1.F1_FORNECE     "
_cQ += "              AND SA2.A2_LOJA= SF1.F1_LOJA        "
_cQ += "              AND SA2.D_E_L_E_T_ = ' '            "
_cQ += "          LEFT JOIN " + RetSQLname("SA1") + " SA1 "           
_cQ += "              ON SA1.A1_FILIAL= '" + xFilial('SA1') + "' "             
_cQ += "              AND SA1.A1_COD = SF1.F1_FORNECE     "                 
_cQ += "              AND SA1.A1_LOJA= SF1.F1_LOJA        "              
_cQ += "              AND SA1.D_E_L_E_T_ = ' '            "
_cQ += "    WHERE                                         "
If aRetP[01] <> Space(09)
    _cQ += "     SF1.F1_DOC = '" + aRetP[01] + "' AND "
endif
If !Empty(aRetP[04])
    _cQ += "     SF1.F1_FILIAL = '" + aRetP[04] + "' AND "
endif
If !Empty(aRetP[05])
    _cQ += "     SD1.D1_CF = '" + aRetP[05] + "' AND "
endif
If !Empty(aRetP[06])
    _cQ += "     SD1.D1_TES = '" + aRetP[06] + "' AND "
endif
If !Empty(aRetP[07])
    _cQ += "     SBM.BM_CODMAR = '" + aRetP[07] + "' AND "
endif
If !Empty(aRetP[08])
    _cQ += "     SB1.B1_GRUPO = '" + aRetP[08] + "' AND "
endif
If !Empty(aRetP[09])
    _cQ += " ( CASE    "  
    _cQ += "	WHEN SF1.F1_TIPO = 'D'  OR SF1.F1_TIPO = 'B'    " 
    _cQ += "	THEN SA1.A1_CGC    "  
    _cQ += "	ELSE SA2.A2_CGC    " 
    _cQ += "	END = '" + aRetP[09] + "' ) AND "
endif
If !Empty(aRetP[10])
    _cQ += " ( CASE    "  
    _cQ += "	WHEN SF1.F1_TIPO = 'D'  OR SF1.F1_TIPO = 'B'    " 
    _cQ += "	THEN SA1.A1_EST    "  
    _cQ += "	ELSE SA2.A2_EST    " 
    _cQ += "	END = '" + aRetP[10] + "' ) AND "
endif
If !Empty(aRetP[11])
    _cQ += "     SD1.D1_COD = '" + aRetP[11] + "' AND "
endif
_cQ += "         SF1.F1_EMISSAO BETWEEN '" + DTOS(aRetP[02]) + "' AND '" + DTOS(aRetP[03]) + "'"
_cQ += "  AND SF1.D_E_L_E_T_ = ' ' "
_cQ += "  ORDER BY 2 "

dbUseArea( .T., "TOPCONN", TcGenQry(,,_cQ),cAliasQry, .T., .T. ) 

//oSection1:EndQuery()
PQuery(cAliasQry,oReport) //Imprime
oReport:IncMeter()
oSection1:Finish() 

Return


/*/{Protheus.doc} ZPECR011
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
    oSection1:Cell("NOTA"):SetValue((cAliasQry)->NOTA)
    oSection1:Cell("SERIE"):SetValue((cAliasQry)->SERIE)
    oSection1:Cell("TIPO_NF"):SetValue((cAliasQry)->TIPO_NF)
    oSection1:Cell("EMISSAO"):SetValue((cAliasQry)->EMISSAO)
    oSection1:Cell("DIGITACAO"):SetValue((cAliasQry)->DIGITACAO)
    oSection1:Cell("CFOP"):SetValue((cAliasQry)->CFOP)
    oSection1:Cell("TEXTO_TES"):SetValue((cAliasQry)->TEXTO_TES)
    oSection1:Cell("NOME"):SetValue((cAliasQry)->NOME)
    oSection1:Cell("CNPJ"):SetValue((cAliasQry)->CNPJ)
    oSection1:Cell("UF"):SetValue((cAliasQry)->UF)
    oSection1:Cell("PRODUTO"):SetValue((cAliasQry)->PRODUTO)
    oSection1:Cell("DESCRI"):SetValue((cAliasQry)->DESCRI)
    oSection1:Cell("LINHA"):SetValue((cAliasQry)->LINHA)
    oSection1:Cell("SUBLINHA"):SetValue((cAliasQry)->SUBLINHA)
    oSection1:Cell("MARCA"):SetValue((cAliasQry)->MARCA)    
    oSection1:Cell("QUANT"):SetValue((cAliasQry)->QUANT)
    oSection1:Cell("UNIT"):SetValue((cAliasQry)->UNIT)
    oSection1:Cell("TOTAL"):SetValue((cAliasQry)->TOTAL)
    oSection1:Cell("CUSTO"):SetValue((cAliasQry)->CUSTO)
    oSection1:Cell("NCM"):SetValue((cAliasQry)->NCM)   
    oSection1:Cell("ICMS"):SetValue((cAliasQry)->ICMS)
    oSection1:Cell("IPI"):SetValue((cAliasQry)->IPI)
    oSection1:Cell("VAL_SUBS"):SetValue((cAliasQry)->VAL_SUBS)
    oSection1:Cell("PIS"):SetValue((cAliasQry)->PIS)
    oSection1:Cell("COFINS"):SetValue((cAliasQry)->COFINS)
    oSection1:Cell("VAL_II"):SetValue((cAliasQry)->VAL_II)
    oSection1:Cell("FRETE"):SetValue((cAliasQry)->FRETE)
    oSection1:Cell("SEGURO"):SetValue((cAliasQry)->SEGURO)
    oSection1:Cell("DESPESA"):SetValue((cAliasQry)->DESPESA)
    oSection1:Cell("ACRESC"):SetValue((cAliasQry)->ACRESC)   

	oSection1:PrintLine()
    TReport():Print() 

	(cAliasQry)->( DbSkip() )
	
EndDo

Return()
