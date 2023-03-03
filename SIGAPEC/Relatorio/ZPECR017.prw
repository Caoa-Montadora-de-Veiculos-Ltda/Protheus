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
Private cAliasQry	:= GetNextAlias()
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

oSection1 := TRSection():New(oReport,cDescricao + " - Barueri",{cAliasQry},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oSection1,"FILIAL"   ,"cAliasQry","FILIAL",PesqPict("SB1","B1_FILIAL"),TamSX3("B1_FILIAL")[1],/*lPixel*/,{||cAliasQry->FILIAL})
TRCell():New(oSection1,"CODIGO"   ,"cAliasQry","CODIGO","@!",18,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"DESCRICAO","cAliasQry","DESCRICAO","@!",40,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"ARMAZ"    ,"cAliasQry","ARMAZ","@!",05,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"CONTAB"   ,"cAliasQry","CONTAB","@!",15,/*lPixel*/,/*{||cAliasQry->TOTAL_PEDIDO}*/)
TRCell():New(oSection1,"LINHA"    ,"cAliasQry","LINHA","@!",05,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"SUBLINHA" ,"cAliasQry","SUBLINHA","@!",05,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"MARCA"    ,"cAliasQry","MARCA","@!",05,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"CUSTO"    ,"cAliasQry","CUSTO",PesqPict("SB1","B1_PRV1"),TamSX3("B1_PRV1")[1],/*lPixel*/,{||cAliasQry->CUSTO})
TRCell():New(oSection1,"EX_NCM"   ,"cAliasQry","EX_NCM","@!",10,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"NCM"      ,"cAliasQry","NCM","@!",10,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"Aliq_II"  ,"cAliasQry","Aliq_II" ,PesqPict("SB1","B1_IPI"),TamSX3("B1_IPI")[1],/*lPixel*/,{||cAliasQry->PII})
TRCell():New(oSection1,"Aliq_IPI" ,"cAliasQry","Aliq_IPI",PesqPict("SB1","B1_IPI"),TamSX3("B1_IPI")[1],/*lPixel*/,{||cAliasQry->PIPI})
TRCell():New(oSection1,"Aliq_PIS" ,"cAliasQry","Aliq_PIS",PesqPict("SB1","B1_IPI"),TamSX3("B1_IPI")[1],/*lPixel*/,{||cTXPIS})
TRCell():New(oSection1,"Aliq_COF" ,"cAliasQry","Aliq_COF",PesqPict("SB1","B1_IPI"),TamSX3("B1_IPI")[1],/*lPixel*/,{||cTXCOFIN})
TRCell():New(oSection1,"DTCAD"    ,"cAliasQry","DTCAD",PesqPict("SB1","B1_DATREF"),TamSX3("B1_DATREF")[1],/*lPixel*/,{||cAliasQry->DTCAD})
TRCell():New(oSection1,"DTCOM"    ,"cAliasQry","DTCOM",PesqPict("SB1","B1_DATREF"),TamSX3("B1_DATREF")[1],/*lPixel*/,{||PQry02()})
TRCell():New(oSection1,"DTVEN"    ,"cAliasQry","DTVEN",PesqPict("SB1","B1_DATREF"),TamSX3("B1_DATREF")[1],/*lPixel*/,{||PQry03()})
TRCell():New(oSection1,"ULTCOM"   ,"cAliasQry","ULTCOM",PesqPict("SB1","B1_DATREF"),TamSX3("B1_DATREF")[1],/*lPixel*/,{||cAliasQry->ULTCOM})
TRCell():New(oSection1,"DTULTS"   ,"cAliasQry","DTULTS",PesqPict("SB1","B1_DATREF"),TamSX3("B1_DATREF")[1],/*lPixel*/,{||cAliasQry->DTULTS})
TRCell():New(oSection1,"FOBUS"    ,"cAliasQry","FOBUS",PesqPict("SB1","B1_PRV1"),TamSX3("B1_PRV1")[1],/*lPixel*/,{||cAliasQry->CUSTO})
TRCell():New(oSection1,"PESOL"    ,"cAliasQry","PESOL",PesqPict("SB1","B1_PESO"),TamSX3("B1_PESO")[1],/*lPixel*/,{||cAliasQry->PESOL})
TRCell():New(oSection1,"COMPRI"   ,"cAliasQry","COMPRI",PesqPict("SB1","B1_PESO"),TamSX3("B1_PESO")[1],/*lPixel*/,{||cAliasQry->COMPRI})
TRCell():New(oSection1,"LARGURA"  ,"cAliasQry","LARGURA",PesqPict("SB1","B1_PESO"),TamSX3("B1_PESO")[1],/*lPixel*/,{||cAliasQry->LARGURA})
TRCell():New(oSection1,"ALTU"     ,"cAliasQry","ALTU",PesqPict("SB1","B1_PESO"),TamSX3("B1_PESO")[1],/*lPixel*/,{||cAliasQry->ALTU})
TRCell():New(oSection1,"EMBAL"    ,"cAliasQry","EMBAL",PesqPict("SB1","B1_PICM"),TamSX3("B1_PICM")[1],/*lPixel*/,{||cAliasQry->EMBAL})
TRCell():New(oSection1,"ORIG"     ,"cAliasQry","ORIG","@!",03,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"DS_ORIG"  ,"cAliasQry","DS_ORIG","@!",40,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"FORNECEDOR","cAliasQry","FORNECEDOR","@!",40,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"CNPJ"     ,"cAliasQry","CNPJ","@!",40,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"GRUPO"    ,"cAliasQry","GRUPO","@!",05,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)
TRCell():New(oSection1,"DS_GRUPO" ,"cAliasQry","DS_GRUPO","@!",30,/*lPixel*/,/*{||cAliasQry->DATA_Carga}*/)

Return(oReport) 


/*/{Protheus.doc} ZPECR017
Relatorio  Cadastro Produtos (2 na planilha)
@author Antonio Oliveira
@since 22/06/2022
@version 2.0
Local _dDataDe  := aRetP[03]
/*/
Static Function ReportPrint(oReport)
Local _cWhere   := ""
//Local _cCodIni  := aRetP[01]
//Local _cCodFim  := aRetP[02]
Local _dDataAte := aRetP[04]
Local _cChave   := 'S0'

If aRetP[01] <> " "
    _cWhere += " AND SB1.B1_COD >= '" + aRetP[01] + "' "
endif
If aRetP[02] <> " "
    _cWhere += " AND SB1.B1_COD <= '" + aRetP[02] + "' "       
endif

If !Empty(_dDataAte) 
    //_dDataDe   := CTOD("01/01/2022")
    //_dDataAte  := aRetP[04]
    _cWhere += " AND SB1.B1_XDTULT >= '" + DTOS(aRetP[03]) + "' "  
    _cWhere += " AND SB1.B1_XDTULT <= '" + DTOS(aRetP[04]) + "' "  
endif
If !Empty(aRetP[05])
    _cWhere += " AND SB1.B1_GRUPO = '" + aRetP[05] + "' "       
endif
If !Empty(aRetP[06]) 
    _cWhere += " AND SB1.B1_NCM = '" + aRetP[06] + "' "     
endif
//If aRetP[07] <> " "
//    _cWhere += " AND VS1.VS1_XMARCA = '" + aRetP[07] + "' "       
//endif

_cWhere := "%"+_cWhere+"%"

BeginSql Alias cAliasQry //Define o nome do alias temporário 

    SELECT SB1.B1_FILIAL  AS FILIAL
        , SB1.B1_COD     AS CODIGO
        , SB1.B1_DESC    AS DESCRICAO
        , SB2.B2_LOCAL   AS ARMAZ     
        , SB2.B2_QATU    AS CONTAB
        , Substr(TO_CHAR(SB2.B2_USAI),7,2)||'/'||Substr(TO_CHAR(SB2.B2_USAI),5,2)||'/'||Substr(TO_CHAR(SB2.B2_USAI),1,4) AS DTULTS      
        , SB1.B1_TIPO    AS LINHA
        , SB5.B5_CODLIN  AS SUBLINHA
        , SBM.BM_CODMAR  AS MARCA
        , SBM.BM_GRUPO   AS GRUPO
        , SUBSTR(SBM.BM_DESC,1,20)   AS DS_GRUPO
        , SB5.B5_LARG    AS LARGURA
        , SB5.B5_ALTURA  AS ALTU
        , SB5.B5_COMPR   AS COMPRI
        , SB1.B1_LOTVEN  AS EMBAL     
        , SB1.B1_ORIGEM  AS ORIG
        , SUBSTR(SX5.X5_DESCRI,1,20) AS DS_ORIG
        , Substr(TO_CHAR(SB1.B1_XDTULT),7,2)||'/'||Substr(TO_CHAR(SB1.B1_XDTULT),5,2)||'/'||Substr(TO_CHAR(SB1.B1_XDTULT),1,4) AS DTCAD      
        , SB2.B2_CM1     AS CUSTO
        , SB1.B1_POSIPI  AS NCM
        , SYD.YD_EX_NCM  AS EX_NCM     
        , SYD.YD_PER_II  AS PII
        , SYD.YD_PER_IPI AS PIPI
        , SB1.B1_VLREFUS AS FOBUS
        , Substr(TO_CHAR(SB1.B1_UCOM),7,2)||'/'||Substr(TO_CHAR(SB1.B1_UCOM),5,2)||'/'||Substr(TO_CHAR(SB1.B1_UCOM),1,4) AS ULTCOM      
        , SB1.B1_PESO    AS PESOL 
        , SA2.A2_CGC     AS CNPJ
        , SA2.A2_NREDUZ  AS FORNE 
    FROM  %Table:SB1% SB1
    LEFT JOIN %Table:SB2% SB2 
        ON Substr(SB2.B2_FILIAL,1,6) = Substr(%xFilial:SB1%,1,6) 
 	    AND SB2.B2_COD   = SB1.B1_COD
 	    AND SB2.B2_LOCAL = '01'    
 	    AND SB2.%notDel% 
    LEFT JOIN %Table:SB5% SB5  
        ON Substr(SB5.B5_FILIAL,1,6) = Substr(%xFilial:SB1%,1,6)     
        AND SB5.B5_COD = SB1.B1_COD           
        AND SB5.%notDel%  
    LEFT JOIN  %Table:SA2% SA2 
        ON SA2.A2_FILIAL = %xFilial:SA2% 
        AND SA2.A2_COD  = SB1.B1_PROC 
        AND SA2.A2_LOJA = SB1.B1_LOJPROC
        AND SA2.%notDel%  
    LEFT JOIN %Table:SYD%  SYD 
        ON Substr(SYD.YD_FILIAL,1,6) = Substr(%xFilial:SB1%,1,6) 
        AND SYD.YD_TEC     = SB1.B1_POSIPI 
        AND SYD.YD_EX_NCM  = SB1.B1_EX_NCM 
        AND SYD.%notDel%  
    LEFT JOIN %Table:SX5% SX5
        ON 	SX5.X5_FILIAL 	=  %xFilial:SX5% 
        AND SX5.X5_TABELA 	=  %Exp:_cChave%
        AND SX5.X5_CHAVE	=  SB1.B1_ORIGEM
        AND SX5.%notDel% 
    LEFT JOIN %Table:SBM% SBM 
        ON Substr(SBM.BM_FILIAL,1,6) = Substr(%xFilial:SB1%,1,6) 
        AND SBM.BM_GRUPO = SB1.B1_GRUPO      
        AND SBM.%notDel%         
    WHERE  
        SB1.%notDel%
        AND SB1.B1_MSBLQL = '2' 
        %Exp:_cWhere%
EndSql

If (cAliasQry)->(Eof())  
    MsgInfo("Não há dados a serem consultados.","CAOA")
    Return
Endif

//        --AND SB1.B1_MSBLQL = '2' 
//SB1.B1_COD BETWEEN  %Exp:_cCodIni%  AND %Exp:_cCodFim%
//    LEFT JOIN  %Table:SA5% SA5 
//        ON Substr(SA5.A5_FILIAL,1,6) = Substr(%xFilial:SB1%,1,6) 
//        AND SA5.A5_PRODUTO = SB1.B1_COD           
//        AND SA5.%notDel%  
//, Substr(TO_CHAR(SA5.A5_DTCOM01),7,2)||'/'||Substr(TO_CHAR(SA5.A5_DTCOM01),5,2)||'/'||Substr(TO_CHAR(SA5.A5_DTCOM01),1,4) AS DTCOM      
      


//oSection1:EndQuery()
PQuery(cAliasQry,oReport) //Imprime
oReport:IncMeter()
oSection1:Finish() 

Return()


/*/{Protheus.doc} ZPECR017
Imprimir a Query	
@author Antonio Oliveira
@since 22/06/2022
@version 2.0
/*/
Static Function PQuery(cAliasQry,oReport)

dbSelectArea(cAliasQry)
dBGotop()

oReport:SetMeter((cAliasQry)->(LastRec()))
oSection1:Init()

Do While !(cAliasQry)->( Eof() )

    oReport:IncMeter()
     
    oSection1:Cell("FILIAL"):SetValue((cAliasQry)->FILIAL)
    oSection1:Cell("CODIGO"):SetValue((cAliasQry)->CODIGO)
    oSection1:Cell("DESCRICAO"):SetValue((cAliasQry)->DESCRICAO)
    oSection1:Cell("ARMAZ"):SetValue((cAliasQry)->ARMAZ)
    oSection1:Cell("CONTAB"):SetValue((cAliasQry)->CONTAB)
    oSection1:Cell("LINHA"):SetValue((cAliasQry)->LINHA)
    oSection1:Cell("SUBLINHA"):SetValue((cAliasQry)->SUBLINHA)
    oSection1:Cell("MARCA"):SetValue((cAliasQry)->MARCA)
    oSection1:Cell("CUSTO"):SetValue((cAliasQry)->CUSTO)
    oSection1:Cell("EX_NCM"):SetValue((cAliasQry)->EX_NCM)
    oSection1:Cell("NCM"):SetValue((cAliasQry)->NCM)
    oSection1:Cell("Aliq_II"):SetValue((cAliasQry)->PII)
    oSection1:Cell("Aliq_IPI"):SetValue((cAliasQry)->PIPI)
    oSection1:Cell("Aliq_PIS"):SetValue(cTXPIS)
    oSection1:Cell("Aliq_COF"):SetValue(cTXCOFIN)
    oSection1:Cell("DTCAD"):SetValue((cAliasQry)->DTCAD)
    oSection1:Cell("DTCOM"):SetValue(PQry02((cAliasQry)->CODIGO))
    oSection1:Cell("DTVEN"):SetValue(PQry03((cAliasQry)->CODIGO))
    oSection1:Cell("ULTCOM"):SetValue((cAliasQry)->ULTCOM)
    oSection1:Cell("DTULTS"):SetValue((cAliasQry)->DTULTS)
    oSection1:Cell("FOBUS"):SetValue((cAliasQry)->FOBUS)
    oSection1:Cell("PESOL"):SetValue((cAliasQry)->PESOL)
    oSection1:Cell("COMPRI"):SetValue((cAliasQry)->COMPRI)
    oSection1:Cell("LARGURA"):SetValue((cAliasQry)->LARGURA)
    oSection1:Cell("ALTU"):SetValue((cAliasQry)->ALTU)
    oSection1:Cell("EMBAL"):SetValue((cAliasQry)->EMBAL)
    oSection1:Cell("ORIG"):SetValue((cAliasQry)->ORIG)
    oSection1:Cell("DS_ORIG"):SetValue((cAliasQry)->DS_ORIG)
    oSection1:Cell("CNPJ"):SetValue((cAliasQry)->CNPJ)
    oSection1:Cell("FORNECEDOR"):SetValue((cAliasQry)->FORNE) 
    oSection1:Cell("GRUPO"):SetValue((cAliasQry)->GRUPO)
    oSection1:Cell("DS_GRUPO"):SetValue((cAliasQry)->DS_GRUPO) 

	oSection1:PrintLine()
    TReport():Print() 

	(cAliasQry)->( DbSkip() )
	
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
_cQuery += " AND SD1.D_E_L_E_T_ = ' ' " 
_cQuery += " AND ROWNUM = 1 "

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
_cQuery += " AND SD2.D_E_L_E_T_ = ' ' " 
_cQuery += " AND ROWNUM = 1 "

DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,_cQuery), (_cAQry) , .F., .T. )

_cRet := (_cAQry)->DTCOM

If Select(_cAQry) <> 0
	(_cAQry)->(DbCloseArea())
	Ferase(_cAQry+GetDBExtension())
Endif  

Return _cRet

