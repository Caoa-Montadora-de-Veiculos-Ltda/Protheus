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

/*/{Protheus.doc} ZPECR017
Relatorio  Cadastro Produtos (4 na planilha)
@author Antonio Oliveira
@since 22/06/2022
@version 2.0
/*/
User Function ZPECR017()
Local aAreaSF2      := SB1->( GetArea() )
Local nOpca         := 1
Local aPergs        := {}
Local cCodI         := SPACE(23)
Local cCodF         := SPACE(23)
Local cGupo         := SPACE(04)
Local cNCM          := SPACE(09)
//Local _aCombo    	:= {"CHE", "HYN", "SUB","   "}
Private cDescricao  := "Relação Cadastro Produtos"
Private dDataI      := Date()
Private dDataF      := Date()
Private aRetP       := {}
Private cTXPIS      := GETMV("MV_TXPIS")
Private cTXCOFIN    := GETMV("MV_TXCOFIN")
Private _cAlias	:= GetNextAlias()
Private oReport, oSection1          // objeto que contem o relatorio

aAdd( aPergs ,{1,"Código Inicial.: ",cCodI ,"@!", , "SB1",'.T.',60,.F.})  //1
aAdd( aPergs ,{1,"Código Final...: ",cCodF ,"@!", , "SB1",'.T.',60,.T.})  //2
aadd( aPergs, {1,"Data Inicial...: ",dDataI,"@D", , ""   ,  "" ,60,.F.})  //3
aadd( aPergs, {1,"Data Final.....: ",dDataF,"@D", , ""   ,  "" ,60,.F.})  //4
aAdd( aPergs ,{1,"Grupo..........:" ,cGupo ,"@!", , "SBM",'.T.',20,.F.})  //5
aAdd( aPergs ,{1,"NCM............:" ,cNCM  ,"@!", , "SYD",'.T.',20,.F.})  //6
//aAdd( aPergs ,{2 ,"Marca.........:" ,"Marca" ,_aCombo , 30 ,  "" ,.F.   })  //7

If ParamBox(aPergs, "Parâmetros p/ Relatório", aRetP, , , , , , , , ,.T.) 

   DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi(cDescricao + " - Barueri") PIXEL
   @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
   @ 29, 15 SAY OemToAnsi("Esta rotina realiza a impressão de Relação Cadastro Produtos ") SIZE 268, 8 OF oDlg PIXEL
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

RestArea( aAreaSF2 )

Return()


/*/{Protheus.doc} ZPECR017
Relatorio  Cadastro Produtos (2 na planilha)
@author Antonio Oliveira
@since 22/06/2022
@version 2.0
/*/
Static Function ReportDef()

oReport:= TReport():New("ZPECR017",cDescricao,"BARUERI", {|oReport| ReportPrint(oReport)},' Cadastro Produtos ') 
oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.

//Verifica os parâmetros selecionados via Pergunte
Pergunte(oReport:GetParam(),.F.)

oSection1 := TRSection():New(oReport,cDescricao + " - Barueri",{_cAlias},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oSection1,"FILIAL"   ,"_cAlias","FILIAL",PesqPict("SB1","B1_FILIAL"),TamSX3("B1_FILIAL")[1],/*lPixel*/,{||_cAlias->FILIAL})
TRCell():New(oSection1,"CODIGO"   ,"_cAlias","CODIGO","@!",18,/*lPixel*/,/*{||_cAlias->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"DESCRICAO","_cAlias","DESCRICAO","@!",40,/*lPixel*/,/*{||_cAlias->TOTAL_PEDIDO}*/)
//TRCell():New(oSection1,"ARMAZ"    ,"_cAlias","ARMAZ","@!",05,/*lPixel*/,/*{||_cAlias->DATA_Carga}*/)
TRCell():New(oSection1,"CONTAB"   ,"_cAlias","CONTAB","@!",15,/*lPixel*/,/*{||PQry04()}*/)
TRCell():New(oSection1,"LINHA"    ,"_cAlias","LINHA","@!",05,/*lPixel*/,/*{||_cAlias->DATA_Carga}*/)
TRCell():New(oSection1,"SUBLINHA" ,"_cAlias","SUBLINHA","@!",05,/*lPixel*/,/*{||_cAlias->DATA_Carga}*/)
TRCell():New(oSection1,"MARCA"    ,"_cAlias","MARCA","@!",05,/*lPixel*/,/*{||_cAlias->DATA_Carga}*/)
TRCell():New(oSection1,"CUSTO"    ,"_cAlias","CUSTO",PesqPict("SB1","B1_PRV1"),TamSX3("B1_PRV1")[1],/*lPixel*/,/*{||PQry05()}*/)
TRCell():New(oSection1,"EX_NCM"   ,"_cAlias","EX_NCM","@!",10,/*lPixel*/,/*{||_cAlias->DATA_Carga}*/)
TRCell():New(oSection1,"NCM"      ,"_cAlias","NCM","@!",10,/*lPixel*/,/*{||_cAlias->DATA_Carga}*/)
TRCell():New(oSection1,"Aliq_II"  ,"_cAlias","Aliq_II" ,PesqPict("SB1","B1_IPI"),TamSX3("B1_IPI")[1],/*lPixel*/,{||_cAlias->PII})
TRCell():New(oSection1,"Aliq_IPI" ,"_cAlias","Aliq_IPI",PesqPict("SB1","B1_IPI"),TamSX3("B1_IPI")[1],/*lPixel*/,{||_cAlias->PIPI})
TRCell():New(oSection1,"Aliq_PIS" ,"_cAlias","Aliq_PIS",PesqPict("SB1","B1_IPI"),TamSX3("B1_IPI")[1],/*lPixel*/,{||cTXPIS})
TRCell():New(oSection1,"Aliq_COF" ,"_cAlias","Aliq_COF",PesqPict("SB1","B1_IPI"),TamSX3("B1_IPI")[1],/*lPixel*/,{||cTXCOFIN})
TRCell():New(oSection1,"DTCAD"    ,"_cAlias","DTCAD",PesqPict("SB1","B1_DATREF"),TamSX3("B1_DATREF")[1],/*lPixel*/,{||_cAlias->DTCAD})
TRCell():New(oSection1,"DTCOM"    ,"_cAlias","DTCOM",PesqPict("SB1","B1_DATREF"),TamSX3("B1_DATREF")[1],/*lPixel*/,{||PQry02()})
TRCell():New(oSection1,"DTVEN"    ,"_cAlias","DTVEN",PesqPict("SB1","B1_DATREF"),TamSX3("B1_DATREF")[1],/*lPixel*/,{||PQry03()})
TRCell():New(oSection1,"ULTCOM"   ,"_cAlias","ULTCOM",PesqPict("SB1","B1_DATREF"),TamSX3("B1_DATREF")[1],/*lPixel*/,{||_cAlias->ULTCOM})
TRCell():New(oSection1,"FOBUS"    ,"_cAlias","FOBUS",PesqPict("SB1","B1_PRV1"),TamSX3("B1_PRV1")[1],/*lPixel*/,{||_cAlias->FOBUS})
TRCell():New(oSection1,"PESOL"    ,"_cAlias","PESOL",PesqPict("SB1","B1_PESO"),TamSX3("B1_PESO")[1],/*lPixel*/,{||_cAlias->PESOL})
TRCell():New(oSection1,"COMPRI"   ,"_cAlias","COMPRI",PesqPict("SB1","B1_PESO"),TamSX3("B1_PESO")[1],/*lPixel*/,{||_cAlias->COMPRI})
TRCell():New(oSection1,"LARGURA"  ,"_cAlias","LARGURA",PesqPict("SB1","B1_PESO"),TamSX3("B1_PESO")[1],/*lPixel*/,{||_cAlias->LARGURA})
TRCell():New(oSection1,"ALTU"     ,"_cAlias","ALTU",PesqPict("SB1","B1_PESO"),TamSX3("B1_PESO")[1],/*lPixel*/,{||_cAlias->ALTU})
TRCell():New(oSection1,"EMBAL"    ,"_cAlias","EMBAL",PesqPict("SB1","B1_PICM"),TamSX3("B1_PICM")[1],/*lPixel*/,{||_cAlias->EMBAL})
TRCell():New(oSection1,"ORIG"     ,"_cAlias","ORIG","@!",03,/*lPixel*/,/*{||_cAlias->DATA_Carga}*/)
TRCell():New(oSection1,"DS_ORIG"  ,"_cAlias","DS_ORIG","@!",40,/*lPixel*/,/*{||_cAlias->DATA_Carga}*/)
TRCell():New(oSection1,"FORNECEDOR","_cAlias","FORNECEDOR","@!",40,/*lPixel*/,/*{||_cAlias->DATA_Carga}*/)
TRCell():New(oSection1,"CNPJ"     ,"_cAlias","CNPJ","@!",40,/*lPixel*/,/*{||_cAlias->DATA_Carga}*/)
TRCell():New(oSection1,"GRUPO"    ,"_cAlias","GRUPO","@!",05,/*lPixel*/,/*{||_cAlias->DATA_Carga}*/)
TRCell():New(oSection1,"DS_GRUPO" ,"_cAlias","DS_GRUPO","@!",30,/*lPixel*/,/*{||_cAlias->DATA_Carga}*/)

Return(oReport) 


/*/{Protheus.doc} ZPECR017
Relatorio  Cadastro Produtos (2 na planilha)
@author Antonio Oliveira
@since 22/06/2022
@version 2.0
Local _dDataDe  := aRetP[03]
/*/
Static Function ReportPrint(oReport)

Local _cAlias 	:= GetNextAlias()
Local _cQry     := ""
Local _dDataAte := aRetP[04]

If Select( (_cAlias) ) > 0
    (_cAlias)->(DbCloseArea())
EndIf

_cQry := " "
_cQry += " SELECT SB1.B1_FILIAL  					AS FILIAL "
_cQry += "         , SB1.B1_COD     				AS CODIGO "
_cQry += "         , SB1.B1_DESC    				AS DESCRICAO "
_cQry += " 	       , NVL(SB2SQL.QTDE,0)         	AS CONTAB     "
_cQry += " 	       , NVL(SB2SQL.CUSTO,0)         	AS CUSTO "
_cQry += "         , SB1.B1_TIPO    				AS LINHA "
_cQry += "         , SB5.B5_CODLIN  				AS SUBLINHA "
_cQry += "         , SBM.BM_CODMAR  				AS MARCA "
_cQry += "         , SBM.BM_GRUPO   				AS GRUPO "
_cQry += "         , SUBSTR(SBM.BM_DESC,1,20)   	AS DS_GRUPO "
_cQry += "         , SB5.B5_LARG    				AS LARGURA "
_cQry += "         , SB5.B5_ALTURA  				AS ALTU "
_cQry += "         , SB5.B5_COMPR   				AS COMPRI "
_cQry += "         , SB1.B1_LOTVEN  				AS EMBAL      "
_cQry += "         , SB1.B1_ORIGEM  				AS ORIG "
_cQry += "         , SUBSTR(SX5.X5_DESCRI,1,20) 	AS DS_ORIG "
_cQry += "         , Substr(TO_CHAR(SB1.B1_XDTULT),7,2)||'/'||Substr(TO_CHAR(SB1.B1_XDTULT),5,2)||'/'||Substr(TO_CHAR(SB1.B1_XDTULT),1,4) AS DTCAD       "
_cQry += "         , SB1.B1_POSIPI  				AS NCM "
_cQry += "         , SYD.YD_EX_NCM  				AS EX_NCM      "
_cQry += "         , SYD.YD_PER_II  				AS PII "
_cQry += "         , SYD.YD_PER_IPI 				AS PIPI "
_cQry += "         , SB1.B1_XPRCFOB 				AS FOBUS "
_cQry += "         , Substr(TO_CHAR(SB1.B1_UCOM),7,2)||'/'||Substr(TO_CHAR(SB1.B1_UCOM),5,2)||'/'||Substr(TO_CHAR(SB1.B1_UCOM),1,4) AS ULTCOM       "
_cQry += "         , SB1.B1_PESO    				AS PESOL  "
_cQry += "         , SA2.A2_CGC     				AS CNPJ "
_cQry += "         , SA2.A2_NREDUZ  				AS FORNE  "
_cQry += " FROM "+RetSqlName("SB1") + " SB1 "
_cQry += "     LEFT JOIN "+RetSqlName("SB5") + " SB5   "
_cQry += "         ON Substr(SB5.B5_FILIAL,1,6) = Substr(SB1.B1_FILIAL,1,6)      "
_cQry += "         AND SB5.B5_COD = SB1.B1_COD            "
_cQry += "         AND SB5.D_E_L_E_T_ = ' ' "
_cQry += "     LEFT JOIN "+RetSqlName("SA2") + " SA2  "
_cQry += "         ON SA2.A2_FILIAL = '" + xFilial("SA2") +"' "
_cQry += "         AND SA2.A2_COD  = SB1.B1_PROC  "
_cQry += "         AND SA2.A2_LOJA = SB1.B1_LOJPROC "
_cQry += "         AND SA2.D_E_L_E_T_ = ' ' "
_cQry += "     LEFT JOIN "+RetSqlName("SYD") + " SYD  "
_cQry += "         ON Substr(SYD.YD_FILIAL,1,6) = Substr(SB1.B1_FILIAL,1,6)  "
_cQry += "         AND SYD.YD_TEC     = SB1.B1_POSIPI  "
_cQry += "         AND SYD.YD_EX_NCM  = SB1.B1_EX_NCM  "
_cQry += "         AND SYD.D_E_L_E_T_ = ' ' "
_cQry += "     LEFT JOIN "+RetSqlName("SX5") + " SX5 "
_cQry += "         ON SX5.X5_FILIAL 	=  '" + xFilial("SX5") +"' "
_cQry += "         AND SX5.X5_TABELA 	=  'S0' "
_cQry += "         AND SX5.X5_CHAVE	=  SB1.B1_ORIGEM "
_cQry += "         AND SX5.D_E_L_E_T_ = ' ' "
_cQry += "     LEFT JOIN "+RetSqlName("SBM") + " SBM  "
_cQry += "         ON Substr(SBM.BM_FILIAL,1,6) = Substr(SB1.B1_FILIAL,1,6)  "
_cQry += "         AND SBM.BM_GRUPO = SB1.B1_GRUPO       "
_cQry += "         AND SBM.D_E_L_E_T_ = ' ' "
_cQry += " 	LEFT JOIN ( "
_cQry += " 				SELECT B2_COD,  CAST(SUM(NVL(B2_QATU,0)) AS NUMBER (8, 2)) AS QTDE, DECODE(SUM(NVL(B2_QATU,0)),0,0,((SUM(NVL(B2_VATU1,0))/SUM(NVL(B2_QATU,0)))*1)) AS CUSTO FROM "+RetSqlName("SB2") + " "
_cQry += " 				WHERE B2_FILIAL = '" + xFilial("SB2") +"'  "
_cQry += " 				AND D_E_L_E_T_ = ' ' "
_cQry += " 				GROUP BY B2_COD "
_cQry += " 			) SB2SQL "
_cQry += " 		ON SB1.B1_COD = SB2SQL.B2_COD "
_cQry += "  WHERE SB1.B1_FILIAL = '" + xFilial("SB1") +"' "
_cQry += "  AND SB1.B1_MSBLQL = '2'  "

If aRetP[01] <> " "
    _cQry += " AND SB1.B1_COD >= '" + aRetP[01] + "' "
Endif

If aRetP[02] <> " "
    _cQry += " AND SB1.B1_COD <= '" + aRetP[02] + "' "       
endif

If !Empty(_dDataAte) 
    _cQry += " AND SB1.B1_XDTULT >= '" + DTOS(aRetP[03]) + "' "  
    _cQry += " AND SB1.B1_XDTULT <= '" + DTOS(aRetP[04]) + "' "  
Endif

If !Empty(aRetP[05])
    _cQry += " AND SB1.B1_GRUPO = '" + aRetP[05] + "' "       
Endif

If !Empty(aRetP[06]) 
    _cQry += " AND SB1.B1_NCM = '" + aRetP[06] + "' "     
Endif

_cQry += "  AND SB1.D_E_L_E_T_ = ' ' "

DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQry), _cAlias, .T., .T. )

DbSelectArea((_cAlias))
(_cAlias)->(dbGoTop())
   
If (_cAlias)->(Eof())  
    MsgInfo("Não há dados a serem consultados.","CAOA")
    Return
Endif

//oSection1:EndQuery()
PQuery(_cAlias,oReport) //Imprime
oReport:IncMeter()
oSection1:Finish() 

Return()


/*/{Protheus.doc} ZPECR017
Imprimir a Query	
@author Antonio Oliveira
@since 22/06/2022
@version 2.0
/*/
Static Function PQuery(_cAlias,oReport)

dbSelectArea(_cAlias)
dBGotop()

oReport:SetMeter((_cAlias)->(LastRec()))
oSection1:Init()

Do While !(_cAlias)->( Eof() )

    oReport:IncMeter()
     
    oSection1:Cell("FILIAL"):SetValue((_cAlias)->FILIAL)
    oSection1:Cell("CODIGO"):SetValue((_cAlias)->CODIGO)
    oSection1:Cell("DESCRICAO"):SetValue((_cAlias)->DESCRICAO)
    oSection1:Cell("CONTAB"):SetValue((_cAlias)->CONTAB)
    oSection1:Cell("LINHA"):SetValue((_cAlias)->LINHA)
    oSection1:Cell("SUBLINHA"):SetValue((_cAlias)->SUBLINHA)
    oSection1:Cell("MARCA"):SetValue((_cAlias)->MARCA)
    oSection1:Cell("CUSTO"):SetValue((_cAlias)->CUSTO)
    oSection1:Cell("EX_NCM"):SetValue((_cAlias)->EX_NCM)
    oSection1:Cell("NCM"):SetValue((_cAlias)->NCM)
    oSection1:Cell("Aliq_II"):SetValue((_cAlias)->PII)
    oSection1:Cell("Aliq_IPI"):SetValue((_cAlias)->PIPI)
    oSection1:Cell("Aliq_PIS"):SetValue(cTXPIS)
    oSection1:Cell("Aliq_COF"):SetValue(cTXCOFIN)
    oSection1:Cell("DTCAD"):SetValue((_cAlias)->DTCAD)
    oSection1:Cell("DTCOM"):SetValue(PQry02((_cAlias)->CODIGO))
    oSection1:Cell("DTVEN"):SetValue(PQry03((_cAlias)->CODIGO))
    oSection1:Cell("ULTCOM"):SetValue((_cAlias)->ULTCOM)
    oSection1:Cell("FOBUS"):SetValue((_cAlias)->FOBUS)
    oSection1:Cell("PESOL"):SetValue((_cAlias)->PESOL)
    oSection1:Cell("COMPRI"):SetValue((_cAlias)->COMPRI)
    oSection1:Cell("LARGURA"):SetValue((_cAlias)->LARGURA)
    oSection1:Cell("ALTU"):SetValue((_cAlias)->ALTU)
    oSection1:Cell("EMBAL"):SetValue((_cAlias)->EMBAL)
    oSection1:Cell("ORIG"):SetValue((_cAlias)->ORIG)
    oSection1:Cell("DS_ORIG"):SetValue((_cAlias)->DS_ORIG)
    oSection1:Cell("CNPJ"):SetValue((_cAlias)->CNPJ)
    oSection1:Cell("FORNECEDOR"):SetValue((_cAlias)->FORNE) 
    oSection1:Cell("GRUPO"):SetValue((_cAlias)->GRUPO)
    oSection1:Cell("DS_GRUPO"):SetValue((_cAlias)->DS_GRUPO) 

	oSection1:PrintLine()
    TReport():Print() 

	(_cAlias)->( DbSkip() )
	
EndDo

Return()


/*/{Protheus.doc} ZPECR017
//Rodar query para buscar a Data de Primeira Compra do Produto	
@author Antonio Oliveira
@since 05/07/2022
@version 2.0
/*/
Static Function PQry02(cProduto)
Local _cAQry 	:= GetNextAlias()
Local _cRet     := ""
Local _cQuery   := ""

If Empty(cProduto)
    Return(_cRet)   
endif

_cQuery += " SELECT * FROM ( "
_cQuery += " SELECT "
_cQuery += " Substr(TO_CHAR(SD1.D1_DTDIGIT),7,2)||'/'||Substr(TO_CHAR(SD1.D1_DTDIGIT),5,2)||'/'||Substr(TO_CHAR(SD1.D1_DTDIGIT),1,4) AS DTCOM "      
_cQuery += " FROM "+RetSqlName("SD1") + " SD1 "
_cQuery += " LEFT JOIN "+RetSqlName("SF4") + " SF4 " 
_cQuery += "    ON Substr(SF4.F4_FILIAL,1,6) = Substr(SD1.D1_FILIAL,1,6) "
_cQuery += "    AND SF4.F4_ESTOQUE = 'S' "
_cQuery += "    AND SF4.D_E_L_E_T_ = ' ' " 
_cQuery += " WHERE " 
_cQuery += " SD1.D1_FILIAL = '" + xFilial("SD1") +"' " 
_cQuery += " AND SD1.D1_COD = '" + cProduto +"' " 
_cQuery += " AND SD1.D1_CF IN ('1102','2102','3102') " 
_cQuery += " AND SD1.D_E_L_E_T_ = ' ' " 
_cQuery += " ORDER BY SD1.D1_DTDIGIT DESC "
_cQuery += " ) SD1SQL "
_cQuery += " WHERE ROWNUM = 1"

DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,_cQuery), (_cAQry) , .F., .T. )

_cRet := (_cAQry)->DTCOM

If Select(_cAQry) <> 0
	(_cAQry)->(DbCloseArea())
	Ferase(_cAQry+GetDBExtension())
Endif  

Return _cRet


/*/{Protheus.doc} ZPECR017
//Rodar query para buscar a Data de Primeira Compra do Produto	
@author Antonio Oliveira
@since 05/07/2022
@version 2.0
/*/
Static Function PQry03(cProduto)
Local _cAQry 	:= GetNextAlias()
Local _cRet     := ""
Local _cQuery   := ""

If Empty(cProduto)
    Return(_cRet)   
endif

_cQuery += " SELECT * FROM ("
_cQuery += " SELECT "
_cQuery += " Substr(TO_CHAR(SD2.D2_EMISSAO),7,2)||'/'||Substr(TO_CHAR(SD2.D2_EMISSAO),5,2)||'/'||Substr(TO_CHAR(SD2.D2_EMISSAO),1,4) AS DTCOM "      
_cQuery += " FROM "+RetSqlName("SD2") + " SD2 "
_cQuery += " LEFT JOIN "+RetSqlName("SF4") + " SF4 " 
_cQuery += "    ON Substr(SF4.F4_FILIAL,1,6) = Substr(SD2.D2_FILIAL,1,6) "
_cQuery += "    AND SF4.F4_ESTOQUE = 'S' "
_cQuery += "    AND SF4.D_E_L_E_T_ = ' ' " 
_cQuery += " WHERE " 
_cQuery += " SD2.D2_FILIAL = '" + xFilial("SD2") +"' " 
_cQuery += " AND SD2.D2_COD = '" + cProduto +"' " 
_cQuery += " AND SD2.D2_CF IN ('5102','5152','5403','6102','6110','6403') " 
_cQuery += " AND SD2.D_E_L_E_T_ = ' ' " 
_cQuery += " ORDER BY SD2.D2_EMISSAO DESC "
_cQuery += " )SD2SQL "
_cQuery += " WHERE ROWNUM = 1"

DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,_cQuery), (_cAQry) , .F., .T. )

_cRet := (_cAQry)->DTCOM

If Select(_cAQry) <> 0
	(_cAQry)->(DbCloseArea())
	Ferase(_cAQry+GetDBExtension())
Endif  

Return _cRet
