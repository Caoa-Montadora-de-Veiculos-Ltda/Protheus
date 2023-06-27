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

/*/{Protheus.doc} ZPECR006
Relatorio BO 
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
User Function ZPECR006()
    Local aAreaVS3      := VS3->( GetArea() )
    Local nOpca         := 1
    Local aPergs        := {}
    Local cCNPJ         := SPACE(14)
    Local cPeca         := SPACE(23)
    Local cPortal       := SPACE(08)
    Local _aCombo    	:= {"CHE", "HYU", "SBR","   "}
    Private dDataI      := Date()
    Private dDataF      := Date()
    Private aRetP       := {}
    Private cAliasTRB	:= GetNextAlias()
    Private oReport, oSection1          // objeto que contem o relatorio

    aAdd( aPergs, {2 ,"Marca.........:" ,"Marca" ,_aCombo ,30 ,"" ,.F. })
    //aAdd( aPergs ,{1,"Marca..........: ",cCodigo ,"PERTENCE('CHE|HYN|SUB')",,,'.T.',20,.F.})
    aAdd( aPergs ,{1,"CNPJ...........: ",cCNPJ   ,"@!", , ""      ,'.T.',60,.F.})
    aAdd( aPergs ,{1,"Código da Peça.: ",cPeca   ,"@!", , "VS3IT" ,'.T.',60,.F.})
    aAdd( aPergs ,{1,"Pedido Portal..: ",cPortal ,"@!", , "VS1AW" ,'.T.',60,.F.})
    aadd( aPergs, {1,"Data Inicial...: ",dDataI  ,"@D", , ""      ,  "" ,60,.T.})
    aadd( aPergs, {1,"Data Final.....: ",dDataF  ,"@D", , ""      ,  "" ,60,.T.})

    If ParamBox(aPergs, "Parâmetros p/ Relatório", aRetP, , , , , , , , ,.T.) 

        DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi("Relação BO  - Barueri") PIXEL
            @ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL
            @ 29, 15 SAY OemToAnsi("Esta rotina realiza a impressão de Conferência da Relação BO ") SIZE 268, 8 OF oDlg PIXEL
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


/*/{Protheus.doc} ZPECR006
Definição do Relatorio BO 
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
Static Function ReportDef()

    oReport:= TReport():New("ZPECR006",' Relação BO  ',"BARUERI", {|oReport| ReportPrint(oReport)},' BO  ') 
    oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.

    //Verifica os parâmetros selecionados via Pergunte
    Pergunte(oReport:GetParam(),.F.)

    oSection1 := TRSection():New(oReport,"BO  - Barueri",{cAliasTRB},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

    TRCell():New(oSection1,"DATA_IMPORTACAO"	  ,"cAliasTRB"	,'Dt entrada Ped WEB'         ,PesqPict("VS1","VS1_XDTIMP") ,TamSx3("VS1_XDTIMP")[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"MARCA"	              ,"cAliasTRB"	,'Marca'	                  ,PesqPict("VS1","VS1_XMARCA") ,TamSx3("VS1_XMARCA")[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"NUM_ORC"              ,"cAliasTRB"	,'Orçamento'                  ,PesqPict("VS1","VS1_NUMORC") ,TamSx3("VS1_NUMORC")[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"PED_AW"               ,"cAliasTRB"	,'Pedido Web'                 ,PesqPict("VS1","VS1_XPVAW" ) ,TamSx3("VS1_XPVAW" )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"ORC_DESM"             ,"cAliasTRB"	,'Orc. Desmembrado'           ,PesqPict("VS1","VS1_XDESMB") ,TamSx3("VS1_XDESMB")[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"COND_PGTO"            ,"cAliasTRB"	,'Cond. Pgto'                 ,PesqPict("VS1","VS1_FORPAG") ,TamSx3("VS1_FORPAG")[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"DESC_COND_PGTO"       ,"cAliasTRB"	,'Descr. Cond. Pgto'          ,PesqPict("SE4","E4_DESCRI" ) ,TamSx3("E4_DESCRI" )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"CNPJ"                 ,"cAliasTRB"	,'CNPJ'                       ,PesqPict("SA1","A1_CGC"    ) ,TamSx3("A1_CGC"    )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"COD_CLIENTE"          ,"cAliasTRB"	,'Cod. Cliente'               ,PesqPict("SA1","A1_COD"    ) ,TamSx3("A1_COD"    )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"LOJA"                 ,"cAliasTRB"	,'Loja'                       ,PesqPict("SA1","A1_LOJA"   ) ,TamSx3("A1_LOJA"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"CLIENTE"              ,"cAliasTRB"	,'Razão Social'               ,PesqPict("SA1","A1_NREDUZ" ) ,TamSx3("A1_NREDUZ" )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"ESTADO"               ,"cAliasTRB"	,'Estado'                     ,PesqPict("SA1","A1_EST"    ) ,TamSx3("A1_EST"    )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"TIPO_PEDIDO"          ,"cAliasTRB"	,'Tipo Pedido'                ,PesqPict("VX5","VX5_DESCRI") ,20                      ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"PROD_SOLIC"           ,"cAliasTRB"	,'Produto Solicitado'         ,PesqPict("VS3","VS3_XITSUB") ,TamSx3("VS3_XITSUB")[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"DESC_SOLIC"           ,"cAliasTRB"	,'Descr. Prod. Solicitado'    ,PesqPict("SB1","B1_DESC"   ) ,TamSx3("B1_DESC"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"ESTSOL01"      ,"cAliasTRB"	,'Estoque Solic. 01'          ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"ESTSOL11"      ,"cAliasTRB"	,'Estoque Solic. 11'          ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"ESTSOL02"      ,"cAliasTRB"	,'Estoque Solic. 02'          ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"ESTSOL65"      ,"cAliasTRB"	,'Estoque Solic. 65'          ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"ESTSOL80"      ,"cAliasTRB"	,'Estoque Solic. 80'          ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"ESTSOL90"      ,"cAliasTRB"	,'Estoque Solic. 90'          ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"ESTSOLOU"      ,"cAliasTRB"	,'Estoque Solic. Outros'      ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/) 
    TRCell():New(oSection1,"ESTSOLWIS"     ,"cAliasTRB"	,'Estoque Solic. Wis'         ,PesqPict("SB2","B2_COD"   ) ,TamSx3("B2_COD"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"PROD_ATEND"    ,"cAliasTRB"	,'Produto Atendido'           ,PesqPict("VS3","VS3_CODITE") ,TamSx3("VS3_CODITE")[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"DESC_ATEND"    ,"cAliasTRB"	,'Descr. Prod. Atendido'      ,PesqPict("SB1","B1_DESC"   ) ,TamSx3("B1_DESC"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"ESTATE01"      ,"cAliasTRB"	,'Estoque Atendido 01'        ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"ESTATE11"      ,"cAliasTRB"	,'Estoque Atendido 11'        ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)    
    TRCell():New(oSection1,"ESTATE02"      ,"cAliasTRB"	,'Estoque Atendido 02'        ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"ESTATE65"      ,"cAliasTRB"	,'Estoque Atendido 65'        ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"ESTATE80"      ,"cAliasTRB"	,'Estoque Atendido 80'        ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"ESTATE90"      ,"cAliasTRB"	,'Estoque Atendido 90'        ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)    
    TRCell():New(oSection1,"ESTATEOU"      ,"cAliasTRB"	,'Estoque Atendido Outros'    ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)    
    TRCell():New(oSection1,"ESTATEWIS"     ,"cAliasTRB"	,'Estoque Atendido Wis'       ,PesqPict("SB2","B2_COD"   ) ,TamSx3("B2_COD"   )[1] ,/*lPixel*/,/* {|| }*/)    
    TRCell():New(oSection1,"QTDE_SOLICITADA"      ,"cAliasTRB"	,'Qtde Solicitada Pedido'     ,PesqPict("VS3","VS3_QTDINI") ,TamSx3("VS3_QTDINI")[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"QTDE_ATENDIDA"        ,"cAliasTRB"	,'Qtde Atendida'              ,PesqPict("VS3","VS3_QTDITE") ,TamSx3("VS3_QTDITE")[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"QTDE_ATENDER"         ,"cAliasTRB"	,'Qtde Atender'               ,PesqPict("VS3","VS3_QTDITE") ,TamSx3("VS3_QTDITE")[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"QTDE_PEDIDO_SOLIC"    ,"cAliasTRB"	,'Qtde Ped.Compras'           ,PesqPict("SC7","C7_QUANT"  ) ,TamSx3("C7_QUANT"  )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"BO_GERAL"             ,"cAliasTRB"	,'BO Geral'                   ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"CHASSIS"              ,"cAliasTRB"	,'Chassis'                    ,PesqPict("VS1","VS1_XCHASS") ,TamSx3("VS1_XCHASS")[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"COD_LINHA"            ,"cAliasTRB"	,'Linha'                      ,PesqPict("SB5","B5_CODLIN" ) ,TamSx3("B5_CODLIN" )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"DESC_LINHA"           ,"cAliasTRB"	,'Descrição Linha'            ,PesqPict("SB1","B1_DESC"   ) ,TamSx3("B1_DESC"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"INVOICE"              ,"cAliasTRB"	,'Invoice'                    ,PesqPict("SW8","W8_INVOICE") ,TamSx3("W8_INVOICE")[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"DT_INVOICE_FORN"      ,"cAliasTRB"	,'Data Invoice Forn'          ,PesqPict("SW9","W9_DT_EMIS") ,TamSx3("W9_DT_EMIS")[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"DT_PREV_PORTO"        ,"cAliasTRB"	,'Data Previsão Porto'        ,PesqPict("SW6","W6_DT_ETA" ) ,TamSx3("W6_DT_ETA" )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"NF_INV_BARUERI"       ,"cAliasTRB"	,'NF Invoice'                 ,PesqPict("SD1","D1_DOC"    ) ,TamSx3("D1_DOC"    )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"NF_SERIE_INV"         ,"cAliasTRB"	,'Serie Invoice'              ,PesqPict("SD1","D1_SERIE"  ) ,TamSx3("D1_SERIE"  )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"QTD_INV"              ,"cAliasTRB"	,'Quantidade Invoice'         ,PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"SALDO_ARMZ_INV"       ,"cAliasTRB"	,'Sld a Conferir Armz Invoice',PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"NF_COMPRA_DEV"        ,"cAliasTRB"	,'NF Compra Devolução'        ,PesqPict("SD1","D1_DOC"    ) ,TamSx3("D1_DOC"    )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"NF_SERIE_COMPRA"      ,"cAliasTRB"	,'NF Serie Compra Devol'      ,PesqPict("SD1","D1_SERIE"  ) ,TamSx3("D1_SERIE"  )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"COD_FORN_COMPRA_TOTVS","cAliasTRB"	,'Cod.Fornecedor Compra Totvs',PesqPict("SD1","D1_FORNECE") ,TamSx3("D1_FORNECE")[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"LOJA_COMPRA"          ,"cAliasTRB"	,'Cod.Loja Compra Totvs'      ,PesqPict("SD1","D1_LOJA"   ) ,TamSx3("D1_LOJA"   )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"FORNECEDOR"           ,"cAliasTRB"	,'Nome Fornecedor  '          ,PesqPict("SA2","A2_NREDUZ" ) ,TamSx3("A2_NREDUZ" )[1] ,/*lPixel*/,/* {|| }*/)
    TRCell():New(oSection1,"SALDO_ARMAZ_COMPRA"   ,"cAliasTRB"	,'Sld a Conferir Compra Devol',PesqPict("SB2","B2_QATU"   ) ,TamSx3("B2_QATU"   )[1] ,/*lPixel*/,/* {|| }*/)

Return(oReport) 


/*/{Protheus.doc} ZPECR006
Impressão do relatório BO 
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
Static Function ReportPrint(oReport)

    Local cQuery		:= ""
    Local _cConectWis  := AllTrim(SuperGetMV( "CMV_PEC031"  ,,"WIS.V_ENDERECO_ESTOQUE@DBLINK_WISPROD")) 

    If Select( (cAliasTRB) ) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf

    cQuery := CRLF + "SELECT DISTINCT "
    cQuery += CRLF + "		VS1.VS1_XDTIMP					AS	DATA_IMPORTACAO, "
    cQuery += CRLF + "		VS1.VS1_XMARCA					AS	MARCA, "
    cQuery += CRLF + "		VS1.VS1_NUMORC					AS	NUM_ORC, "
    cQuery += CRLF + "		VS1.VS1_XPVAW					AS	PED_AW, "
    cQuery += CRLF + "		VS1.VS1_XDESMB					AS	ORC_DESM, "
    cQuery += CRLF + "		VS1.VS1_FORPAG					AS	COND_PGTO, "
    cQuery += CRLF + "		SE4.E4_DESCRI					AS	DESC_COND_PGTO, "
    cQuery += CRLF + "		SA1.A1_CGC						AS	CNPJ, "
    cQuery += CRLF + "		SA1.A1_COD						AS	COD_CLIENTE, "
    cQuery += CRLF + "		SA1.A1_LOJA						AS	LOJA, "
    cQuery += CRLF + "		SA1.A1_NREDUZ					AS	CLIENTE, "
    cQuery += CRLF + "		SA1.A1_EST						AS	ESTADO, "
    cQuery += CRLF + "		RTRIM(VX5_DESCRI)				AS	TIPO_PEDIDO, "
    cQuery += CRLF + "		VS3.VS3_XITSUB					AS	PROD_SOLIC, "
    cQuery += CRLF + "		SB1SOL.B1_DESC					AS	DESC_SOLIC, "
    cQuery += CRLF + "		NVL(SB2SOL01.B2_QATU-SB2SOL01.B2_RESERVA,0)			AS	ESTSOL01, "
    cQuery += CRLF + "		NVL(SB2SOL11.B2_QATU-SB2SOL11.B2_RESERVA,0)			AS	ESTSOL11, "
    cQuery += CRLF + "		NVL(SB2SOL02.B2_QATU,0)			AS	ESTSOL02, "
    cQuery += CRLF + "		NVL(SB2SOL65.B2_QATU,0)			AS	ESTSOL65, "
    cQuery += CRLF + "		NVL(SB2SOL80.B2_QATU,0)			AS	ESTSOL80, "
    cQuery += CRLF + "		NVL(SB2SOL90.B2_QATU,0)			AS	ESTSOL90, "
    cQuery += CRLF + "		NVL(TMPSB2SOLOU.TOT,0)			AS  ESTSOLOU, "    
    cQuery += CRLF + "		NVL(TMPWISSOL.QTDEWIS,0)||' '||TMPWISSOL.ARMAZEM		AS	ESTSOLWIS, "
    cQuery += CRLF + "		VS3.VS3_CODITE					AS	PROD_ATEND, "
    cQuery += CRLF + "		SB1ATEN.B1_DESC					AS	DESC_ATEND, "
    cQuery += CRLF + "		NVL(SB2ATEN01.B2_QATU-SB2ATEN01.B2_RESERVA,0)		AS	ESTATE01, "
    cQuery += CRLF + "		NVL(SB2ATEN11.B2_QATU-SB2ATEN11.B2_RESERVA,0)		AS	ESTATE11, "    
    cQuery += CRLF + "		NVL(SB2ATEN02.B2_QATU,0)		AS	ESTATE02, "
    cQuery += CRLF + "		NVL(SB2ATEN65.B2_QATU,0)		AS	ESTATE65, "
    cQuery += CRLF + "		NVL(SB2ATEN80.B2_QATU,0)		AS	ESTATE80, "
    cQuery += CRLF + "		NVL(SB2ATEN90.B2_QATU,0)		AS	ESTATE90, "
    cQuery += CRLF + "		NVL(TMPSB2ATEOU.TOT,0)			AS  ESTATEOU, "     
    cQuery += CRLF + "		NVL(TMPWISATEN.QTDEWIS,0)||' '||TMPWISATEN.ARMAZEM		AS	ESTATEWIS, "
    cQuery += CRLF + "		VS3.VS3_QTDINI					AS	QTDE_SOLICITADA, "
    cQuery += CRLF + "		NVL(TMPATE.VS3_QTDITE,0) 		AS 	QTDE_ATENDIDA, "
    cQuery += CRLF + "		NVL(VS3.VS3_QTDINI-NVL(TMPATE.VS3_QTDITE,0),0) AS QTDE_ATENDER, "
    cQuery += CRLF + "		NVL(TMPPED.SALDO,0)				AS	QTDE_PEDIDO_SOLIC, "
    cQuery += CRLF + "		NVL(TMPXBO.TOT_BO,0)			AS  BO_GERAL, "
    cQuery += CRLF + "		VS1.VS1_XCHASS 					AS  CHASSIS, "
    cQuery += CRLF + "		NVL(SB5SOL.B5_CODLIN,'-')		AS  COD_LINHA, "
    cQuery += CRLF + "		NVL((SELECT X5_DESCRI FROM " + RetSQLName( 'SX5' ) + " SX5 "
    cQuery += CRLF + "					WHERE SX5.D_E_L_E_T_ = ' ' AND SX5.X5_TABELA = '0A' "
    cQuery += CRLF + "						AND SX5.X5_CHAVE = SB5SOL.B5_CODLIN),'-') AS DESC_LINHA, "
    cQuery += CRLF + "		NVL(TMPW8.NF,'-')  				AS NF_INV_BARUERI, "
    cQuery += CRLF + "		NVL(TMPW8.SERIE,'-')  			AS NF_SERIE_INV, "
    cQuery += CRLF + "		NVL(TO_CHAR(TMPW8.SLDIT),'ND')	AS SALDO_ARMZ_INV, "
    cQuery += CRLF + "		NVL(TMPW8.QTD_INV,'0') 			AS QTD_INV, "
    cQuery += CRLF + "		NVL(TMPW8.INVOICE,'SEM INVOICE')AS INVOICE, "
    cQuery += CRLF + "		NVL(TMPW8.DT_INV,'-') 			AS DT_INVOICE_FORN, "
    cQuery += CRLF + "		NVL(TMPW8.DT_PREV,'-')			AS DT_PREV_PORTO, "
    cQuery += CRLF + "		NVL(TMPZD1B.NF, '-') 			AS NF_COMPRA_DEV, "
    cQuery += CRLF + "		NVL(TMPZD1B.SERIE,'-')			AS NF_SERIE_COMPRA, "
    cQuery += CRLF + "		NVL(TMPZD1B.FORN,'-') 			AS COD_FORN_COMPRA_TOTVS, "
    cQuery += CRLF + "		NVL(TMPZD1B.LOJA, '-')			AS LOJA_COMPRA, "
    cQuery += CRLF + "		NVL(SA2COMPRA.A2_NREDUZ, '-' )	AS FORNECEDOR, "
    cQuery += CRLF + "		NVL(TO_CHAR(TMPZD1B.SLDIT),'ND')AS SALDO_ARMAZ_COMPRA "
    cQuery += CRLF + "FROM " + RetSQLName( 'VS1' ) + " VS1 "
    cQuery += CRLF + "		INNER JOIN " + RetSQLName( 'VS3' ) + " VS3 "
    cQuery += CRLF + "			ON VS3.VS3_FILIAL = VS1.VS1_FILIAL "
    cQuery += CRLF + "			AND VS3.VS3_NUMORC = VS1.VS1_NUMORC "
    If !Empty(aRetP[03]) "
        cQuery += CRLF + "				AND VS3.VS3_CODITE = '" + aRetP[03] + "' "
    EndIf
    cQuery += CRLF + "			AND VS3.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		INNER JOIN " + RetSQLName( 'SB1' ) + " SB1SOL "
    cQuery += CRLF + "			ON SB1SOL.B1_FILIAL = '" + FWxFilial('SB1') + "' "
    cQuery += CRLF + "			AND SB1SOL.B1_COD = VS3.VS3_XITSUB "
    cQuery += CRLF + "			AND SB1SOL.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SB5' ) + " SB5SOL "
    cQuery += CRLF + "			ON SB5SOL.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "			AND SB5SOL.B5_FILIAL = SB1SOL.B1_FILIAL "
    cQuery += CRLF + "			AND SB5SOL.B5_COD = SB1SOL.B1_COD "
    cQuery += CRLF + "		INNER JOIN " + RetSQLName( 'SB1' ) + " SB1ATEN "
    cQuery += CRLF + "			ON SB1ATEN.B1_FILIAL = '" + FWxFilial('SB1') + "' "
    cQuery += CRLF + "			AND SB1ATEN.B1_COD = VS3.VS3_CODITE "
    cQuery += CRLF + "			AND SB1ATEN.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		INNER JOIN " + RetSQLName( 'SA1' ) + " SA1 "
    cQuery += CRLF + "			ON SA1.A1_FILIAL = '" + FWxFilial('SA1') + "' "
    cQuery += CRLF + "			AND SA1.A1_COD = VS1.VS1_CLIFAT "
    cQuery += CRLF + "			AND SA1.A1_LOJA = VS1.VS1_LOJA "
    If !Empty(aRetP[02]) 
        cQuery := CRLF + "				AND SA1.A1_CGC = '" + aRetP[02] + "' "
    EndIf
    cQuery += CRLF + "			AND SA1.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SB2' ) + " SB2SOL01 "
    cQuery += CRLF + "			ON  SB2SOL01.B2_FILIAL = VS3.VS3_FILIAL "
    cQuery += CRLF + "			AND SB2SOL01.B2_COD = VS3.VS3_XITSUB "
    cQuery += CRLF + "			AND SB2SOL01.B2_LOCAL = '01' "
    cQuery += CRLF + "			AND SB2SOL01.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SB2' ) + " SB2SOL11 "
    cQuery += CRLF + "			ON  SB2SOL11.B2_FILIAL = VS3.VS3_FILIAL "
    cQuery += CRLF + "			AND SB2SOL11.B2_COD = VS3.VS3_XITSUB "
    cQuery += CRLF + "			AND SB2SOL11.B2_LOCAL = '11' "
    cQuery += CRLF + "			AND SB2SOL11.D_E_L_E_T_ = ' ' "    
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SB2' ) + " SB2SOL02 "
    cQuery += CRLF + "			ON  SB2SOL02.B2_FILIAL = VS3.VS3_FILIAL "
    cQuery += CRLF + "			AND SB2SOL02.B2_COD = VS3.VS3_XITSUB "
    cQuery += CRLF + "			AND SB2SOL02.B2_LOCAL = '02' "
    cQuery += CRLF + "			AND SB2SOL02.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SB2' ) + " SB2SOL65 "
    cQuery += CRLF + "			ON  SB2SOL65.B2_FILIAL = VS3.VS3_FILIAL "
    cQuery += CRLF + "			AND SB2SOL65.B2_COD = VS3.VS3_XITSUB "
    cQuery += CRLF + "			AND SB2SOL65.B2_LOCAL = '65' "
    cQuery += CRLF + "			AND SB2SOL65.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SB2' ) + " SB2SOL80 "
    cQuery += CRLF + "			ON  SB2SOL80.B2_FILIAL = VS3.VS3_FILIAL "
    cQuery += CRLF + "			AND SB2SOL80.B2_COD = VS3.VS3_XITSUB "
    cQuery += CRLF + "			AND SB2SOL80.B2_LOCAL = '80' "
    cQuery += CRLF + "			AND SB2SOL80.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SB2' ) + " SB2SOL90 "
    cQuery += CRLF + "			ON  SB2SOL90.B2_FILIAL = VS3.VS3_FILIAL "
    cQuery += CRLF + "			AND SB2SOL90.B2_COD = VS3.VS3_XITSUB "
    cQuery += CRLF + "			AND SB2SOL90.B2_LOCAL = '90' "
    cQuery += CRLF + "			AND SB2SOL90.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		LEFT JOIN ( "
    cQuery += CRLF + "			SELECT SB2OU.B2_FILIAL FIL, SB2OU.B2_COD COD, SUM(SB2OU.B2_QATU) TOT " 
    cQuery += CRLF + "			FROM " + RetSQLName( 'SB2' ) + " SB2OU "                                                             
 	cQuery += CRLF + "			WHERE SB2OU.D_E_L_E_T_ = ' ' "
 	cQuery += CRLF + "			AND SB2OU.B2_LOCAL NOT IN ('01','11','02','61','65','80','90') "
 	cQuery += CRLF + "			GROUP BY B2_FILIAL, B2_COD "
    cQuery += CRLF + "			      ) TMPSB2SOLOU "
 	cQuery += CRLF + "			ON TMPSB2SOLOU.FIL = VS3.VS3_FILIAL "
 	cQuery += CRLF + "			AND TMPSB2SOLOU.COD = VS3.VS3_XITSUB "   
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SB2' ) + " SB2ATEN01 "
    cQuery += CRLF + "			ON SB2ATEN01.B2_FILIAL = VS3.VS3_FILIAL "
    cQuery += CRLF + "			AND SB2ATEN01.B2_COD = VS3.VS3_CODITE "
    cQuery += CRLF + "			AND SB2ATEN01.B2_LOCAL = '01' "
    cQuery += CRLF + "			AND SB2ATEN01.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SB2' ) + " SB2ATEN11 "
    cQuery += CRLF + "			ON SB2ATEN11.B2_FILIAL = VS3.VS3_FILIAL "
    cQuery += CRLF + "			AND SB2ATEN11.B2_COD = VS3.VS3_CODITE "
    cQuery += CRLF + "			AND SB2ATEN11.B2_LOCAL = '11' "
    cQuery += CRLF + "			AND SB2ATEN11.D_E_L_E_T_ = ' ' "    
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SB2' ) + " SB2ATEN02 "
    cQuery += CRLF + "			ON SB2ATEN02.B2_FILIAL = VS3.VS3_FILIAL "
    cQuery += CRLF + "			AND SB2ATEN02.B2_COD = VS3.VS3_CODITE "
    cQuery += CRLF + "			AND SB2ATEN02.B2_LOCAL = '02' "
    cQuery += CRLF + "			AND SB2ATEN02.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SB2' ) + " SB2ATEN65 "
    cQuery += CRLF + "			ON SB2ATEN65.B2_FILIAL = VS3.VS3_FILIAL "
    cQuery += CRLF + "			AND SB2ATEN65.B2_COD = VS3.VS3_CODITE "
    cQuery += CRLF + "			AND SB2ATEN65.B2_LOCAL = '65' "
    cQuery += CRLF + "			AND SB2ATEN65.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SB2' ) + " SB2ATEN80 "
    cQuery += CRLF + "			ON SB2ATEN80.B2_FILIAL = VS3.VS3_FILIAL "
    cQuery += CRLF + "			AND SB2ATEN80.B2_COD = VS3.VS3_CODITE "
    cQuery += CRLF + "			AND SB2ATEN80.B2_LOCAL = '80' "
    cQuery += CRLF + "			AND SB2ATEN80.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SB2' ) + " SB2ATEN90 "
    cQuery += CRLF + "			ON SB2ATEN90.B2_FILIAL = VS3.VS3_FILIAL "
    cQuery += CRLF + "			AND SB2ATEN90.B2_COD = VS3.VS3_CODITE "
    cQuery += CRLF + "			AND SB2ATEN90.B2_LOCAL = '90' "
    cQuery += CRLF + "			AND SB2ATEN90.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		LEFT JOIN ( "
    cQuery += CRLF + "			SELECT SB2OU.B2_FILIAL FIL, SB2OU.B2_COD COD, SUM(SB2OU.B2_QATU) TOT " 
    cQuery += CRLF + "			FROM " + RetSQLName( 'SB2' ) + " SB2OU "                                                             
 	cQuery += CRLF + "			WHERE SB2OU.D_E_L_E_T_ = ' ' "
 	cQuery += CRLF + "			AND SB2OU.B2_LOCAL NOT IN ('01','11','02','61','65','80','90') "
 	cQuery += CRLF + "			GROUP BY B2_FILIAL, B2_COD "
    cQuery += CRLF + "			      ) TMPSB2ATEOU "
 	cQuery += CRLF + "			ON TMPSB2ATEOU.FIL = VS3.VS3_FILIAL "
 	cQuery += CRLF + "			AND TMPSB2ATEOU.COD = VS3.VS3_CODITE "       
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'VX5' ) + " VX5 "
    cQuery += CRLF + "			ON VX5.VX5_FILIAL = '" + FWxFilial('VX5') + "' "
    cQuery += CRLF + "			AND VX5.VX5_CHAVE = 'Z00' "
    cQuery += CRLF + "			AND VX5.VX5_CODIGO =  VS1.VS1_XTPPED "
    cQuery += CRLF + "			AND VX5.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SE4' ) + " SE4 "
    cQuery += CRLF + "			ON SE4.E4_FILIAL = '" + FWxFilial('SE4') + "' "
    cQuery += CRLF + "			AND SE4.E4_CODIGO = VS1.VS1_FORPAG "
    cQuery += CRLF + "			AND	SE4.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "		LEFT JOIN 	( "
    cQuery += CRLF + "					SELECT  VS3B.VS3_XDESMB, "
    cQuery += CRLF + "							VS3B.VS3_NUMORC, "
    cQuery += CRLF + "							VS3B.VS3_XITSUB, "
    cQuery += CRLF + "							SUM(VS3B.VS3_QTDITE) AS VS3_QTDITE "
    cQuery += CRLF + "						FROM " + RetSQLName( 'VS3' ) + " VS3B "
    cQuery += CRLF + "							INNER JOIN " + RetSQLName( 'VS1' ) + " VS1B "
    cQuery += CRLF + "								ON VS1B.VS1_FILIAL = VS3B.VS3_FILIAL "
    cQuery += CRLF + "								AND VS1B.VS1_NUMORC = VS3B.VS3_NUMORC "
    cQuery += CRLF + "								AND VS1B.VS1_STATUS NOT IN ('0','2','3','C') "
    cQuery += CRLF + "								AND VS1B.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "						WHERE VS3B.VS3_FILIAL = '" + FWxFilial('VS3') + "' "
    cQuery += CRLF + "							AND VS3B.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "						GROUP BY VS3B.VS3_XDESMB, VS3B.VS3_NUMORC, VS3B.VS3_XITSUB "
    cQuery += CRLF + "					) TMPATE "
    cQuery += CRLF + "			ON TMPATE.VS3_XDESMB = VS1.VS1_XDESMB "
    cQuery += CRLF + "			AND TMPATE.VS3_XITSUB = VS3.VS3_XITSUB "
    cQuery += CRLF + "		LEFT JOIN	( "
    cQuery += CRLF + "					SELECT  SC7.C7_PRODUTO, "
    cQuery += CRLF + "						SUM(SC7.C7_QUANT - SC7.C7_QUJE)  AS SALDO "
    cQuery += CRLF + "					FROM " + RetSQLName( 'SC7' ) + " SC7 "
    cQuery += CRLF + "					WHERE SC7.C7_FILIAL = '" + FWxFilial('SC7') + "' "
    cQuery += CRLF + "						AND SC7.C7_ENCER = ' ' "
    cQuery += CRLF + "						AND SC7.C7_RESIDUO = ' ' "
    cQuery += CRLF + "						AND ( SC7.C7_QUANT - SC7.C7_QUJE ) <> 0 "
    cQuery += CRLF + "						AND SC7.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "						GROUP BY SC7.C7_PRODUTO "
    cQuery += CRLF + "						) TMPPED "
    cQuery += CRLF + "			ON TMPPED.C7_PRODUTO = VS3.VS3_XITSUB "
    cQuery += CRLF + "		LEFT JOIN 	( "
    cQuery += CRLF + "					SELECT 	RTRIM(LTRIM(ESTWIS.CD_PRODUTO)) 							AS PROD, "
    cQuery += CRLF + "							NVL(SUM(ESTWIS.QT_ESTOQUE - ESTWIS.QT_RESERVA_SAIDA - ESTWIS.QT_TRANSITO_SAIDA), 0) 	AS QTDEWIS, "
    cQuery += CRLF + "	                ESTWIS.ARMAZEM "
    cQuery += CRLF + "					FROM " + _cConectWis + " ESTWIS "
    cQuery += CRLF + "					GROUP BY RTRIM(LTRIM(ESTWIS.CD_PRODUTO)), ESTWIS.ARMAZEM "
    cQuery += CRLF + "					) TMPWISSOL "
    cQuery += CRLF + "				ON LTRIM(RTRIM(TMPWISSOL.PROD)) = LTRIM(RTRIM(VS3.VS3_XITSUB)) "
    cQuery += CRLF + "		LEFT JOIN 	( "
    cQuery += CRLF + "					SELECT 	RTRIM(LTRIM(ESTWIS.CD_PRODUTO)) 							AS PROD, "
    cQuery += CRLF + "					NVL(SUM(ESTWIS.QT_ESTOQUE - ESTWIS.QT_RESERVA_SAIDA - ESTWIS.QT_TRANSITO_SAIDA), 0) 	AS QTDEWIS, "
    cQuery += CRLF + "	                ESTWIS.ARMAZEM "
    cQuery += CRLF + "					FROM " + _cConectWis + " ESTWIS "
    cQuery += CRLF + "					GROUP BY RTRIM(LTRIM(ESTWIS.CD_PRODUTO)), ESTWIS.ARMAZEM "
    cQuery += CRLF + "					) TMPWISATEN "
    cQuery += CRLF + "				ON LTRIM(RTRIM(TMPWISATEN.PROD)) = LTRIM(RTRIM(VS3.VS3_CODITE)) "
    cQuery += CRLF + "		LEFT JOIN ( "
    cQuery += CRLF + "					SELECT VS3BO.VS3_CODITE AS COD, SUM(VS3BO.VS3_QTDITE) AS TOT_BO "
    cQuery += CRLF + "					FROM " + RetSQLName( 'VS3' ) + " VS3BO "
    cQuery += CRLF + "					INNER JOIN " + RetSQLName( 'VS1' ) + " VS1BO "
    cQuery += CRLF + "						ON VS1BO.VS1_FILIAL = VS3BO.VS3_FILIAL "
    cQuery += CRLF + "						AND VS1BO.VS1_NUMORC = VS3BO.VS3_NUMORC "
    cQuery += CRLF + "						AND VS1BO.VS1_STATUS IN ('0','3') "
    cQuery += CRLF + "						AND VS1BO.VS1_XBO = 'S' "
    cQuery += CRLF + "						AND VS1BO.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "					WHERE VS3BO.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "					GROUP BY VS3BO.VS3_CODITE "
    cQuery += CRLF + "					) TMPXBO "
    cQuery += CRLF + "			ON TMPXBO.COD = VS3.VS3_CODITE "
    cQuery += CRLF + "		LEFT JOIN ( "        //" // --PROCESSOS DE IMPORTAÇÃO " // -- COM CONFIRMAÇÃO DE ARMAZENAGEM PENDENTE OU A DATA DE PREVISÃO MAIS PRÓXIMA "
    cQuery += CRLF + "					SELECT * FROM "
    cQuery += CRLF + "						(SELECT W8.W8_FILIAL FILIAL, W6.W6_HAWB HAWB, W9.W9_INVOICE INVOICE "
    cQuery += CRLF + "							, W9_DT_EMIS DT_INV, (W6_DT_ETA) DT_PREV, W8.W8_COD_I COD, SUM(W8.W8_QTDE) QTD_INV "
    cQuery += CRLF + "							, TMPZD1.NF, TMPZD1.SERIE, TMPZD1.SLDIT SLDIT "
    cQuery += CRLF + "						, RANK() OVER (PARTITION BY W8.W8_COD_I "
    cQuery += CRLF + "						ORDER BY TMPZD1.SLDIT,W6_DT_ETA, W6.W6_HAWB) AS RANKING "
    cQuery += CRLF + "						FROM " + RetSQLName( 'SW8' ) + " W8 "
    cQuery += CRLF + "		INNER JOIN " + RetSQLName( 'SW6' ) + " W6 "
    cQuery += CRLF + "				ON W6.D_E_L_E_T_ =' ' "
    cQuery += CRLF + "				AND W6.W6_FILIAL = W8.W8_FILIAL "
    cQuery += CRLF + "				AND W6.W6_HAWB = W8.W8_HAWB "
    cQuery += CRLF + "		LEFT JOIN " + RetSQLName( 'SW9' ) + " W9 "
    cQuery += CRLF + "				ON W9.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "				AND W9.W9_FILIAL = W6_FILIAL "
    cQuery += CRLF + "				AND W9.W9_HAWB = W6.W6_HAWB "
    cQuery += CRLF + "		INNER JOIN ( "
    cQuery += CRLF + "					SELECT F1.F1_FILIAL FILIAL, F1.F1_XHAWB F1HAWB, D1.D1_XCONHEC D1HAWB "
    cQuery += CRLF + "							, D1.D1_DOC NF, D1.D1_SERIE SERIE, D1.D1_COD COD, (ZD1.ZD1_SLDIT) AS SLDIT "
    cQuery += CRLF + "					FROM " + RetSQLName( 'SF1' ) + " F1 "
    cQuery += CRLF + "						INNER JOIN " + RetSQLName( 'SD1' ) + " D1 " // " // -- NF COM MOV ESTOQUE CLASSIFICADAS "
    cQuery += CRLF + "							ON D1.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "							AND D1.D1_FILIAL = F1.F1_FILIAL "
    cQuery += CRLF + "							AND D1.D1_DOC = F1.F1_DOC "
    cQuery += CRLF + "							AND D1.D1_SERIE = F1.F1_SERIE "
    cQuery += CRLF + "							AND D1.D1_FORNECE = F1.F1_FORNECE "
    cQuery += CRLF + "							AND D1.D1_LOJA = F1.F1_LOJA "
    cQuery += CRLF + "							AND D1.D1_QUANT != '0' "
    cQuery += CRLF + "							AND D1.D1_TESACLA <> ' ' "
    cQuery += CRLF + "							AND D1.D1_TES <> ' ' "
    cQuery += CRLF + "						LEFT JOIN " + RetSQLName( 'SF4' ) + " F4 " // " // --TES COM ESTOQUE "
    cQuery += CRLF + "							ON F4.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "							AND F4.F4_CODIGO = D1.D1_TESACLA "
    cQuery += CRLF + "							AND F4.F4_ESTOQUE = 'S' "
    cQuery += CRLF + "						INNER JOIN " + RetSQLName( 'ZD1' ) + " ZD1 " // --COM SALDO A INTEGRAR WIS "
    cQuery += CRLF + "							ON ZD1.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "							AND ZD1.ZD1_FILIAL = D1.D1_FILIAL "
    cQuery += CRLF + "							AND ZD1.ZD1_DOC = D1.D1_DOC "
    cQuery += CRLF + "							AND ZD1.ZD1_SERIE = D1.D1_SERIE "
    cQuery += CRLF + "							AND ZD1.ZD1_FORNEC = D1.D1_FORNECE "
    cQuery += CRLF + "							AND ZD1.ZD1_COD = D1.D1_COD "
    cQuery += CRLF + "							AND	ZD1.ZD1_SLDIT > '0' " // -- RESTRINGE PROCESSOS JÁ FINALIZADOS "
    cQuery += CRLF + "					WHERE F1.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "						AND (F1.F1_XHAWB != ' ' OR F1.F1_HAWB != ' ' OR D1.D1_XCONHEC != ' ') "
    cQuery += CRLF + "					) TMPZD1 "
    cQuery += CRLF + "					ON TMPZD1.FILIAL = W6.W6_FILIAL "
    cQuery += CRLF + "					AND (TMPZD1.D1HAWB = W8.W8_HAWB OR TMPZD1.F1HAWB = W8.W8_HAWB) "
    cQuery += CRLF + "					AND TMPZD1.COD = W8.W8_COD_I "
    cQuery += CRLF + "				WHERE W8.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "			GROUP BY W8.W8_FILIAL, W6.W6_HAWB, W9.W9_INVOICE, W9_DT_EMIS, W6_DT_ETA "
    cQuery += CRLF + "					, TMPZD1.NF, TMPZD1.SERIE, W8.W8_COD_I, TMPZD1.SLDIT "
    cQuery += CRLF + "			) "
    cQuery += CRLF + "			WHERE RANKING = 1 "
    cQuery += CRLF + "		) TMPW8 "
    cQuery += CRLF + "			ON TMPW8.FILIAL = VS3.VS3_FILIAL "
    cQuery += CRLF + "			AND TMPW8.COD = VS3.VS3_CODITE "
    cQuery += CRLF + "		LEFT JOIN ( " //  --VERIFICA DE EXISTE CONFIRMAÇÃO DE ARMAZENAGEM PENDENTE COMPRAS OU DEVOLUÇÕES "
    cQuery += CRLF + "					SELECT * FROM "
    cQuery += CRLF + "						(SELECT DISTINCT F1B.F1_FILIAL FILIAL, D1B.D1_COD COD, D1B.D1_DOC NF, D1B.D1_SERIE SERIE "
    cQuery += CRLF + "						, D1B.D1_FORNECE FORN, D1B.D1_LOJA LOJA, (ZD1B.ZD1_SLDIT) AS SLDIT "
    cQuery += CRLF + "						, RANK() OVER (PARTITION BY D1B.D1_COD "
    cQuery += CRLF + "						ORDER BY ZD1B.ZD1_SLDIT DESC, F1B.F1_DOC) AS RANKING "
    cQuery += CRLF + "					FROM " + RetSQLName( 'SF1' ) + " F1B "
    cQuery += CRLF + "					INNER JOIN " + RetSQLName( 'SD1' ) + " D1B " //" // -- NF COM MOV ESTOQUE CLASSIFICADAS "
    cQuery += CRLF + "						ON D1B.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "						AND D1B.D1_FILIAL = F1B.F1_FILIAL "
    cQuery += CRLF + "						AND D1B.D1_DOC = F1B.F1_DOC "
    cQuery += CRLF + "						AND D1B.D1_SERIE = F1B.F1_SERIE "
    cQuery += CRLF + "						AND D1B.D1_FORNECE = F1B.F1_FORNECE "
    cQuery += CRLF + "						AND D1B.D1_LOJA = F1B.F1_LOJA "
    cQuery += CRLF + "						AND D1B.D1_QUANT != '0' "
    cQuery += CRLF + "						AND D1B.D1_TESACLA <> ' ' "
    cQuery += CRLF + "						AND D1B.D1_TES <> ' ' "
    cQuery += CRLF + "					LEFT JOIN " + RetSQLName( 'SF4' ) + " F4B " // --TES COM ESTOQUE "
    cQuery += CRLF + "						ON  F4B.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "						AND F4B.F4_CODIGO = D1B.D1_TESACLA "
    cQuery += CRLF + "						AND F4B.F4_ESTOQUE = 'S' "
    cQuery += CRLF + "					INNER JOIN " + RetSQLName( 'ZD1' ) + " ZD1B " // --COM SALDO A INTEGRAR WIS "
    cQuery += CRLF + "						ON ZD1B.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "						AND ZD1B.ZD1_FILIAL = D1B.D1_FILIAL "
    cQuery += CRLF + "						AND ZD1B.ZD1_DOC = D1B.D1_DOC "
    cQuery += CRLF + "						AND ZD1B.ZD1_SERIE = D1B.D1_SERIE "
    cQuery += CRLF + "						AND ZD1B.ZD1_FORNEC = D1B.D1_FORNECE "
    cQuery += CRLF + "						AND ZD1B.ZD1_COD = D1B.D1_COD "
    cQuery += CRLF + "						AND ZD1B.ZD1_SLDIT > '0'" // -- RESTRINGE PROCESSOS JÁ FINALIZADOS "
    cQuery += CRLF + "					WHERE F1B.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "						AND F1B.F1_XHAWB = ' ' "
    cQuery += CRLF + "						AND F1B.F1_HAWB = ' ' "
    cQuery += CRLF + "						AND D1B.D1_XCONHEC = ' ' "
    cQuery += CRLF + "						ORDER BY COD, RANKING) "
    cQuery += CRLF + "						WHERE RANKING = 1 "
    cQuery += CRLF + "			) TMPZD1B "
    cQuery += CRLF + "				ON TMPZD1B.FILIAL = VS3.VS3_FILIAL "
    cQuery += CRLF + "				AND TMPZD1B.COD = VS3.VS3_CODITE "
    cQuery += CRLF + "			LEFT JOIN " + RetSQLName( 'SA2' ) + " SA2COMPRA "
    cQuery += CRLF + "				ON SA2COMPRA.A2_FILIAL = '          ' "
    cQuery += CRLF + "				AND SA2COMPRA.A2_COD = TMPZD1B.FORN "
    cQuery += CRLF + "				AND SA2COMPRA.A2_LOJA = TMPZD1B.LOJA "
    cQuery += CRLF + "				AND	SA2COMPRA.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "			WHERE VS1.D_E_L_E_T_ = ' ' "
    cQuery += CRLF + "				AND VS1.VS1_FILIAL = '" + FWxFilial('VS1') + "' "
    cQuery += CRLF + "				AND VS1.VS1_STATUS IN ('0','3') "
    If !Empty(aRetP[01] ) "
        cQuery += CRLF + "					AND VS1.VS1_XMARCA = '" + aRetP[01] + "' "
    EndIf
    If !Empty(aRetP[04]) "
        cQuery += CRLF + "					AND VS1.VS1_XPVAW = '" + aRetP[04] + "' "
    ENDIF
        cQuery += CRLF + "				 AND VS1.VS1_XDTIMP BETWEEN '" + DTOS(aRetP[05]) + "' AND '" + DTOS(aRetP[06]) + "' "
    cQuery += CRLF + "ORDER BY VS1.VS1_XDTIMP, VS1.VS1_NUMORC, VS3.VS3_CODITE "
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )
    //oSection1:EndQuery()
    PQuery(cAliasTRB,oReport) //Imprime
    oReport:IncMeter()
    oSection1:Finish() 

Return


/*/{Protheus.doc} ZPECR006
Imprimir a Query	
@author Antonio Oliveira
@since 30/05/2022
@version 2.0
/*/
Static Function PQuery(cAliasTRB,oReport)
	Local _nAtual   := 0
	Local _nTotal   := 0     
    dbSelectArea(cAliasTRB)
    Count to _nTotal
    (cAliasTRB)->(dBGotop())

    oReport:SetMeter(_nTotal)
    oSection1:Init()

    Do While !(cAliasTRB)->( Eof() )
     oReport:IncMeter()

        oSection1:Cell("DATA_IMPORTACAO"      ):SetValue(StoD((cAliasTRB)->DATA_IMPORTACAO))
        oSection1:Cell("MARCA"                ):SetValue((cAliasTRB)->MARCA)
        oSection1:Cell("NUM_ORC"              ):SetValue((cAliasTRB)->NUM_ORC)
        oSection1:Cell("PED_AW"               ):SetValue((cAliasTRB)->PED_AW)
        oSection1:Cell("ORC_DESM"             ):SetValue((cAliasTRB)->ORC_DESM)
        oSection1:Cell("COND_PGTO"            ):SetValue((cAliasTRB)->COND_PGTO)
        oSection1:Cell("DESC_COND_PGTO"       ):SetValue((cAliasTRB)->DESC_COND_PGTO)
        oSection1:Cell("CNPJ"                 ):SetValue((cAliasTRB)->CNPJ)
        oSection1:Cell("COD_CLIENTE"          ):SetValue((cAliasTRB)->COD_CLIENTE)
        oSection1:Cell("LOJA"                 ):SetValue((cAliasTRB)->LOJA)
        oSection1:Cell("CLIENTE"              ):SetValue((cAliasTRB)->CLIENTE)
        oSection1:Cell("ESTADO"               ):SetValue((cAliasTRB)->ESTADO)
        oSection1:Cell("TIPO_PEDIDO"          ):SetValue((cAliasTRB)->TIPO_PEDIDO)
        oSection1:Cell("PROD_SOLIC"           ):SetValue((cAliasTRB)->PROD_SOLIC)
        oSection1:Cell("DESC_SOLIC"           ):SetValue((cAliasTRB)->DESC_SOLIC)
        oSection1:Cell("ESTSOL01"             ):SetValue((cAliasTRB)->ESTSOL01)
        oSection1:Cell("ESTSOL11"             ):SetValue((cAliasTRB)->ESTSOL11)        
        oSection1:Cell("ESTSOL02"             ):SetValue((cAliasTRB)->ESTSOL02)
        oSection1:Cell("ESTSOL65"             ):SetValue((cAliasTRB)->ESTSOL65)
        oSection1:Cell("ESTSOL80"             ):SetValue((cAliasTRB)->ESTSOL80)
        oSection1:Cell("ESTSOL90"             ):SetValue((cAliasTRB)->ESTSOL90)
        oSection1:Cell("ESTSOLOU"             ):SetValue((cAliasTRB)->ESTSOLOU)                
        oSection1:Cell("PROD_ATEND"           ):SetValue((cAliasTRB)->PROD_ATEND)
        oSection1:Cell("DESC_ATEND"           ):SetValue((cAliasTRB)->DESC_ATEND)
        oSection1:Cell("ESTATE01"             ):SetValue((cAliasTRB)->ESTATE01)
        oSection1:Cell("ESTATE11"             ):SetValue((cAliasTRB)->ESTATE11)        
        oSection1:Cell("ESTATE02"             ):SetValue((cAliasTRB)->ESTATE02)
        oSection1:Cell("ESTATE65"             ):SetValue((cAliasTRB)->ESTATE65)
        oSection1:Cell("ESTATE80"             ):SetValue((cAliasTRB)->ESTATE80)
        oSection1:Cell("ESTATE90"             ):SetValue((cAliasTRB)->ESTATE90)
        oSection1:Cell("ESTATEOU"             ):SetValue((cAliasTRB)->ESTATEOU)                 
        oSection1:Cell("ESTATEWIS"            ):SetValue((cAliasTRB)->ESTATEWIS)
        oSection1:Cell("QTDE_SOLICITADA"      ):SetValue((cAliasTRB)->QTDE_SOLICITADA)
        oSection1:Cell("QTDE_ATENDIDA"        ):SetValue((cAliasTRB)->QTDE_ATENDIDA)
        oSection1:Cell("QTDE_ATENDER"        ):SetValue((cAliasTRB)->QTDE_ATENDER)        
        oSection1:Cell("QTDE_PEDIDO_SOLIC"    ):SetValue((cAliasTRB)->QTDE_PEDIDO_SOLIC)
        oSection1:Cell("ESTSOLWIS"            ):SetValue((cAliasTRB)->ESTSOLWIS)
        oSection1:Cell("BO_GERAL"             ):SetValue((cAliasTRB)->BO_GERAL)
        oSection1:Cell("CHASSIS"              ):SetValue((cAliasTRB)->CHASSIS)
        oSection1:Cell("COD_LINHA"            ):SetValue((cAliasTRB)->COD_LINHA)
        oSection1:Cell("DESC_LINHA"           ):SetValue((cAliasTRB)->DESC_LINHA)                
        oSection1:Cell("NF_INV_BARUERI"       ):SetValue((cAliasTRB)->NF_INV_BARUERI)
        oSection1:Cell("NF_SERIE_INV"         ):SetValue((cAliasTRB)->NF_SERIE_INV)
        oSection1:Cell("SALDO_ARMZ_INV"       ):SetValue((cAliasTRB)->SALDO_ARMZ_INV)            
        oSection1:Cell("QTD_INV"              ):SetValue((cAliasTRB)->QTD_INV)
        oSection1:Cell("INVOICE"              ):SetValue((cAliasTRB)->INVOICE)
        oSection1:Cell("DT_INVOICE_FORN"      ):SetValue((cAliasTRB)->DT_INVOICE_FORN)
        oSection1:Cell("DT_PREV_PORTO"        ):SetValue((cAliasTRB)->DT_PREV_PORTO)
        oSection1:Cell("NF_COMPRA_DEV"        ):SetValue((cAliasTRB)->NF_COMPRA_DEV)
        oSection1:Cell("NF_SERIE_COMPRA"      ):SetValue((cAliasTRB)->NF_SERIE_COMPRA)
        oSection1:Cell("COD_FORN_COMPRA_TOTVS"):SetValue((cAliasTRB)->COD_FORN_COMPRA_TOTVS)
        oSection1:Cell("LOJA_COMPRA"          ):SetValue((cAliasTRB)->LOJA_COMPRA)
        oSection1:Cell("FORNECEDOR"           ):SetValue((cAliasTRB)->FORNECEDOR)
        oSection1:Cell("SALDO_ARMAZ_COMPRA"   ):SetValue((cAliasTRB)->SALDO_ARMAZ_COMPRA)                                

        oSection1:PrintLine()
        TReport():Print() 

        (cAliasTRB)->( DbSkip() )
        //Incrementando a régua
		_nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(_nAtual)+" de "+cValToChar(_nTotal)+"...")
        
    EndDo
	(cAliasTRB)->(DbCloseArea())

Return()
