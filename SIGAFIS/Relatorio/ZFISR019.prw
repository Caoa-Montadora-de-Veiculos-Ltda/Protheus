#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Totvs.ch"

/*
=====================================================================================
Programa.:              ZFISR019
Autor....:              CAOA - Nicolas C Lima Santos
Data.....:              10/05/2024
Descricao / Objetivo:   Relatório de Cabeçalho NF de Saída
Doc. Origem:            
Solicitante:            Micaellen Pereira Leal.
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZFISR019()
    
	Local	aArea 		:= FwGetArea()
	Local	oReport     := Nil
	Local	aPergs		:= {}
	Local	dDtEmiss	:= Ctod(Space(8)) 
    Local	cNumNF		:= Space(TamSX3('F3_NFISCAL')[1]) 
    Local	cSerieNF	:= Space(TamSX3('F3_SERIE')[1])
	Local 	cCli 	:= Space(TamSX3('A1_COD')[1])
	//Local 	cPedido		:= Space(TamSX3('C6_NUM')[1])
	
    Private cTabela 	:= GetNextAlias()
    Private cAliasTMP   := GetNextAlias()

    aAdd(aPergs, {1,"Emissao De"		,dDtEmiss	,/*Pict*/	,/*Valid*/	,/*F3*/		,/*When*/,50,.F.})  //MV_PAR01
	aAdd(aPergs, {1,"Emissao Ate"		,dDtEmiss	,/*Pict*/,MV_PAR02 > MV_PAR01,/*F3*/,/*When*/,50,.F.})  //MV_PAR02
	aAdd(aPergs, {1,"Nota Fiscal De"	,cNumNF		,/*Pict*/	,/*Valid*/	,"SF2"		,/*When*/,50,.F.})  //MV_PAR03
	aAdd(aPergs, {1,"Nota Fiscal Ate"	,cNumNF		,/*Pict*/	,/*Valid*/	,"SF2"		,/*When*/,50,.F.})  //MV_PAR04
    aAdd(aPergs, {1,"Serie"				,cSerieNF	,/*Pict*/	,/*Valid*/	,"_SF1SE"	    ,/*When*/,50,.F.})  //MV_PAR05
    aAdd(aPergs, {1,"Cliente De"		,cCli	    ,/*Pict*/	,/*Valid*/	,"SA1"	    ,/*When*/,50,.F.})  //MV_PAR06
	aAdd(aPergs, {1,"Cliente Ate"	    ,cCli	    ,/*Pict*/	,/*Valid*/	,"SA1"	    ,/*When*/,50,.F.})  //MV_PAR07
	//aAdd(aPergs, {1,"Pedido De"			,cPedido	,/*Pict*/	,/*Valid*/	,"SC6"	    ,/*When*/,50,.F.}) 	//MV_PAR08
    //aAdd(aPergs, {1,"Pedido Ate"		,cPedido	,/*Pict*/	,/*Valid*/	,"SC6"	    ,/*When*/,50,.F.}) 	//MV_PAR09

	If ParamBox(aPergs, "Informe os parâmetros para Nota Fiscal de saída", , , , , , , , , .F., .F.)
		oReport := fReportDef()
		oReport:PrintDialog()
	EndIf

	FWRestArea(aArea)
Return

//----------------------------------------------------------
//----------------------------------------------------------

Static Function fReportDef()
    
    Local oReport  := Nil
    Local oSection1 := Nil
    Local oSection2 := Nil

	oReport:= TReport():New("ZFISR019",;    // --Nome da impressão
                            "Saída",;    // --Título da tela de parâmetros
                            ,;              // --Grupo de perguntas na SX1, ao invés das pereguntas estou usando Parambox
                            {|oReport|  ReportPrint(oReport)},;
                            "Este relatório apresenta o cabeçalho das NFs de Saída") // --Descrição do relatório
   
    oReport:DisableOrientation() //--Desabilita a seleção da Orientação
    oReport:SetLandScape(.T.)    //--Orientação do relatório como paisagem.
	oReport:HideParamPage()      //--Desabilita a impressao da pagina de parametros.
    oReport:HideHeader()      //--Define que não será impresso o cabeçalho padrão da página
    oReport:lHeaderVisible := .T. //--Oculta o cabeçalho e as quebras de página
    oReport:HideFooter()         //--Define que não será impresso o rodapé padrão da página
    oReport:SetPreview(.T.)      //--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2)    //--Ambiente: 1-Server e 2-Client
    oReport:SetDevice(4)         //--Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    oReport:SetTpPlanilha({.T., .T., .T., .T.}) //Formato Tabela {Normal, Suprimir linhas brancas e totais, Formato de Tabela, Formato de Tabela xlsx}
	oReport:SetLineHeight(50) 			//--Espaçamento entre linhas
	oReport:cFontBody := 'Courier New' 	//--Tipo da fonte
	oReport:nFontBody := 12				//--Tamanho da fonte
	
	oSection1 := TRSection():New(oReport    ,"NF ativas"    ,{cAliasTMP}) 
    
    //--Colunas do relatório
    TRCell():New( oSection1, "CNPJ"	 , cAliasTMP, "CNPJ"	         , PesqPict("SA1","A1_CGC")     , TamSx3("A1_CGC")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "INS_EST"	 , cAliasTMP, "INS EST"          , PesqPict("SA1","A1_INSCR")   , TamSx3("A1_INSCR")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "CODIGO"	 , cAliasTMP, "CODIGO"           , PesqPict("SA1","A1_COD")     , TamSx3("A1_COD")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "LOJA"	 , cAliasTMP, "LJ"               , PesqPict("SA1","A1_LOJA")    , TamSx3("A1_LOJA")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "CLIENTE"	 , cAliasTMP, "CLIENTE"          , PesqPict("SA1","A1_NOME")    , TamSx3("A1_NOME")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "ESTADO"	 , cAliasTMP, "UF"               , PesqPict("SA1","A1_EST")     , TamSx3("A1_EST")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "NOTA_FISCAL", cAliasTMP, "NF"               , PesqPict("SF3","F3_NFISCAL") , TamSx3("F3_NFISCAL")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "SERIE"  , cAliasTMP, "SERIE"            , PesqPict("SF3","F3_SERIE")   , TamSx3("F3_SERIE")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "FORMUL"  , cAliasTMP, "FORMUL"            , PesqPict("SF3","F3_FORMUL")   , TamSx3("F3_FORMUL")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "ESPECIE", cAliasTMP, "ESPECIE"          , PesqPict("SF3","F3_ESPECIE") , TamSx3("F3_ESPECIE")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "CFOP"    , cAliasTMP, "CFOP"             , PesqPict("SF3","F3_CFO")     , TamSx3("F3_CFO")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "DT_ENTR"   , cAliasTMP, "DATA DE ENTRADA" , PesqPict("SF3", "F3_ENTRADA"), TamSx3("F3_ENTRADA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VALOR_CONTABIL", cAliasTMP, "VALOR"            , PesqPict("SF3", "F3_VALCONT"), TamSx3("F3_VALCONT")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "BASE_ICMS", cAliasTMP, "BASE ICMS"        , PesqPict("SF3", "F3_BASEICM"), TamSx3("F3_BASEICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VAL_ICMS" , cAliasTMP, "VAL ICMS"         , PesqPict("SF3", "F3_VALICM") , TamSx3("F3_VALICM")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "ICMS_ISENTO", cAliasTMP, "ICMS ISENTO"      , PesqPict("SF3", "F3_ISENICM"), TamSx3("F3_ISENICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "ICMS_OUTROS", cAliasTMP, "ICMS OUTROS"      , PesqPict("SF3", "F3_OUTRICM"), TamSx3("F3_OUTRICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "BASE_SUBST", cAliasTMP, "BASE SUBST"       , PesqPict("SF3", "F3_BASERET"), TamSx3("F3_BASERET")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VALOR_SUBST", cAliasTMP, "VALOR SUBST"      , PesqPict("SF3", "F3_ICMSRET"), TamSx3("F3_ICMSRET")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "BASE_IPI", cAliasTMP, "BASE IPI"         , PesqPict("SF3", "F3_BASEIPI"), TamSx3("F3_BASEIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VAL_IPI" , cAliasTMP, "VAL IPI"          , PesqPict("SF3", "F3_VALIPI") , TamSx3("F3_VALIPI")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "IPI_ISENTO", cAliasTMP, "IPI ISENTO"       , PesqPict("SF3", "F3_ISENIPI"), TamSx3("F3_ISENIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "IPI_OUTROS", cAliasTMP, "IPI OUTROS"       , PesqPict("SF3", "F3_OUTRIPI"), TamSx3("F3_OUTRIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "OUTRAS_DESPESAS", cAliasTMP, "OUTRAS DESPESAS"  , PesqPict("SF3", "F3_DESPESA"), TamSx3("F3_DESPESA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "DESCONTO", cAliasTMP, "DESCONTO"         , PesqPict("SF3", "F3_VALOBSE"), TamSx3("F3_VALOBSE")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "BASE_PIS", cAliasTMP, "BASE PIS"         , PesqPict("SF3", "F3_BASIMP6"), TamSx3("F3_BASIMP6")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VALOR_PIS" , cAliasTMP, "VAL PIS"          , PesqPict("SF3", "F3_VALIMP6"), TamSx3("F3_VALIMP6")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "BASE_COF", cAliasTMP, "BASE COF"         , PesqPict("SF3", "F3_BASIMP5"), TamSx3("F3_BASIMP5")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VALOR_COF" , cAliasTMP, "VAL COF"          , PesqPict("SF3", "F3_VALIMP5"), TamSx3("F3_VALIMP5")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "CHAVE"     , cAliasTMP, "CHAVE"            , PesqPict("SF2", "F2_CHVNFE") , TamSx3("F2_CHVNFE")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "PIS_ST_ZFM", cAliasTMP, "PIS ST ZFM"       , PesqPict("SF3", "F3_BASEPS3"), TamSx3("F3_BASEPS3")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VAL_PISSTZFM" , cAliasTMP, "VAL PISST ZFM"    , PesqPict("SF3", "F3_VALPS3") , TamSx3("F3_VALPS3")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "COF_ST_ZFM", cAliasTMP, "COF ST ZFM"       , PesqPict("SF3", "F3_BASECF3"), TamSx3("F3_BASECF3")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VAL_COFST_ZFM" , cAliasTMP, "VAL COFST ZFM"    , PesqPict("SF3", "F3_VALCF3") , TamSx3("F3_VALCF3")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "OBSERVACAO" , cAliasTMP, "OBSERVACAO"       , PesqPict("SF3", "F3_OBSERV") , TamSx3("F3_OBSERV")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "INCLUSAO"   , cAliasTMP, "ALTERACAO"       , PesqPict("SF2", "F2_USERLGI") , TamSx3("F2_USERLGI")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "ALTERACAO"   , cAliasTMP, "ALTERACAO"       , PesqPict("SF2", "F2_USERLGA") , TamSx3("F2_USERLGA")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    oSection2 := TRSection():New(oReport    ,"NF canceladas"    ,{cAliasTMP}) 
    
    //--Colunas do relatório
    TRCell():New( oSection2, "CNPJ"	        , cAliasTMP, "CNPJ"	         , PesqPict("SA1","A1_CGC")     , TamSx3("A1_CGC")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "INS_EST"	    , cAliasTMP, "INS EST"          , PesqPict("SA1","A1_INSCR")   , TamSx3("A1_INSCR")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "CODIGO"	    , cAliasTMP, "CODIGO"           , PesqPict("SA1","A1_COD")     , TamSx3("A1_COD")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "LOJA"	        , cAliasTMP, "LJ"               , PesqPict("SA1","A1_LOJA")    , TamSx3("A1_LOJA")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "CLIENTE"	    , cAliasTMP, "CLIENTE"          , PesqPict("SA1","A1_NOME")    , TamSx3("A1_NOME")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "ESTADO"	    , cAliasTMP, "UF"               , PesqPict("SA1","A1_EST")     , TamSx3("A1_EST")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "NOTA_FISCAL"  , cAliasTMP, "NF"               , PesqPict("SF3","F3_NFISCAL") , TamSx3("F3_NFISCAL")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "SERIE"        , cAliasTMP, "SERIE"            , PesqPict("SF3","F3_SERIE")   , TamSx3("F3_SERIE")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "FORMUL"  , cAliasTMP, "FORMUL"            , PesqPict("SF3","F3_FORMUL")   , TamSx3("F3_FORMUL")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "ESPECIE"      , cAliasTMP, "ESPECIE"          , PesqPict("SF3","F3_ESPECIE") , TamSx3("F3_ESPECIE")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "CFOP"         , cAliasTMP, "CFOP"             , PesqPict("SF3","F3_CFO")     , TamSx3("F3_CFO")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "DT_EMIS"      , cAliasTMP, "DATA DE ENTRADA"  , PesqPict("SF3", "F3_ENTRADA"), TamSx3("F3_ENTRADA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VALOR_CONTABIL", cAliasTMP, "VALOR"            , PesqPict("SF3", "F3_VALCONT"), TamSx3("F3_VALCONT")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "BASE_ICMS"    , cAliasTMP, "BASE ICMS"        , PesqPict("SF3", "F3_BASEICM"), TamSx3("F3_BASEICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VAL_ICMS"     , cAliasTMP, "VAL ICMS"         , PesqPict("SF3", "F3_VALICM") , TamSx3("F3_VALICM")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "ICMS_ISENTO"  , cAliasTMP, "ICMS ISENTO"      , PesqPict("SF3", "F3_ISENICM"), TamSx3("F3_ISENICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "ICMS_OUTROS"  , cAliasTMP, "ICMS OUTROS"      , PesqPict("SF3", "F3_OUTRICM"), TamSx3("F3_OUTRICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "BASE_SUBST"   , cAliasTMP, "BASE SUBST"       , PesqPict("SF3", "F3_BASERET"), TamSx3("F3_BASERET")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VALOR_SUBST"  , cAliasTMP, "VALOR SUBST"      , PesqPict("SF3", "F3_ICMSRET"), TamSx3("F3_ICMSRET")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "BASE_IPI"     , cAliasTMP, "BASE IPI"         , PesqPict("SF3", "F3_BASEIPI"), TamSx3("F3_BASEIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VAL_IPI"      , cAliasTMP, "VAL IPI"          , PesqPict("SF3", "F3_VALIPI") , TamSx3("F3_VALIPI")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "IPI_ISENTO"   , cAliasTMP, "IPI ISENTO"       , PesqPict("SF3", "F3_ISENIPI"), TamSx3("F3_ISENIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "IPI_OUTROS"   , cAliasTMP, "IPI OUTROS"       , PesqPict("SF3", "F3_OUTRIPI"), TamSx3("F3_OUTRIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "OUTRAS_DESPESAS", cAliasTMP, "OUTRAS DESPESAS"  , PesqPict("SF3", "F3_DESPESA"), TamSx3("F3_DESPESA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "DESCONTO"     , cAliasTMP, "DESCONTO"         , PesqPict("SF3", "F3_VALOBSE"), TamSx3("F3_VALOBSE")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "BASE_PIS"     , cAliasTMP, "BASE PIS"         , PesqPict("SF3", "F3_BASIMP6"), TamSx3("F3_BASIMP6")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VALOR_PIS"    , cAliasTMP, "VAL PIS"          , PesqPict("SF3", "F3_VALIMP6"), TamSx3("F3_VALIMP6")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "BASE_COF"     , cAliasTMP, "BASE COF"         , PesqPict("SF3", "F3_BASIMP5"), TamSx3("F3_BASIMP5")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VALOR_COF"    , cAliasTMP, "VAL COF"          , PesqPict("SF3", "F3_VALIMP5"), TamSx3("F3_VALIMP5")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "CHAVE"        , cAliasTMP, "CHAVE"            , PesqPict("SF2", "F2_CHVNFE") , TamSx3("F2_CHVNFE")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "PIS_ST_ZFM"   , cAliasTMP, "PIS ST ZFM"       , PesqPict("SF3", "F3_BASEPS3"), TamSx3("F3_BASEPS3")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VAL_PISSTZFM" , cAliasTMP, "VAL PISST ZFM"    , PesqPict("SF3", "F3_VALPS3") , TamSx3("F3_VALPS3")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "COF_ST_ZFM"   , cAliasTMP, "COF ST ZFM"       , PesqPict("SF3", "F3_BASECF3"), TamSx3("F3_BASECF3")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VAL_COFST_ZFM", cAliasTMP, "VAL COFST ZFM"    , PesqPict("SF3", "F3_VALCF3") , TamSx3("F3_VALCF3")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "OBSERVACAO"   , cAliasTMP, "OBSERVACAO"       , PesqPict("SF3", "F3_OBSERV") , TamSx3("F3_OBSERV")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "INCLUSAO"   , cAliasTMP, "ALTERACAO"       , PesqPict("SF1", "F1_USERLGI") , TamSx3("F1_USERLGI")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "ALTERACAO"   , cAliasTMP, "ALTERACAO"       , PesqPict("SF1", "F1_USERLGA") , TamSx3("F1_USERLGA")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    //oReport:PrintDialog()

Return(oReport)

//----------------------------------------------------------
//----------------------------------------------------------
Static Function  ReportPrint(oReport)

    Local aArea 	:= FWGetArea()
    Local oSection1  := Nil
    Local oSection2  := Nil
    Local cQuery    := ""
    Local nAtual	:= 0
	Local nTotal	:= 0
    
    oSection1  := oReport:Section(1)
    oSection2  := oReport:Section(2)

	If Select(cAliasTMP) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf

    cQuery := " "                                                       + CRLF
    cQuery += " WITH NOTA AS ( "                                        + CRLF
    cQuery += "     SELECT "                                            + CRLF
    cQuery += "         SF2.F2_FILIAL    AS FILIAL "                    + CRLF
    cQuery += "         , SA1.A1_CGC   	 AS CNPJ "                      + CRLF
    cQuery += "         , SA1.A1_INSCR 	 AS INS_EST "                   + CRLF
    cQuery += "         , SA1.A1_COD   	 AS CODIGO "                    + CRLF  
    cQuery += "         , SA1.A1_LOJA  	 AS LOJA "                      + CRLF       
    cQuery += "         , SA1.A1_NOME    AS CLIENTE "                   + CRLF
    cQuery += "         , SA1.A1_EST     AS ESTADO "                    + CRLF
    cQuery += "         , SF2.F2_DOC     AS NOTA_FISCAL "               + CRLF 
    cQuery += "         , SF2.F2_SERIE   AS SERIE "                     + CRLF
    cQuery += "         , SF2.F2_EMISSAO AS DT_ENTR"                + CRLF
    cQuery += "         , SF2.F2_CHVNFE  AS CHAVE "                     + CRLF
    cQuery += "         , SF2.F2_USERLGI AS UINCLUI" 		            + CRLF
    cQuery += "         , SF2.F2_USERLGA AS UALTERA" 		            + CRLF
    cQuery += "         , SD2.D2_CF      AS CFOP "                      + CRLF
    cQuery += "         , SUM(FT_VALPIS) AS VALOR_PIS "                 + CRLF
    cQuery += "         , SUM(FT_VALCOF) AS VALOR_COF "                 + CRLF
    cQuery += " FROM "       + RetSQLName( 'SF2' ) + " SF2 "            + CRLF //-- CAB. NOTA FISCAL DE SAÍDA
    cQuery += " LEFT JOIN "  + RetSQLName( 'SA1' ) + " SA1 "            + CRLF //-- CLIENTES
    cQuery += "     ON SA1.A1_FILIAL  = '" + FWxFilial('SA1') + "' "    + CRLF 
    cQuery += "    AND SA1.A1_COD     = SF2.F2_CLIENTE"                 + CRLF 
    cQuery += "    AND SA1.A1_LOJA    = SF2.F2_LOJA "                   + CRLF 
    cQuery += "    AND SA1.D_E_L_E_T_ = ' ' "	                        + CRLF
	cQuery += " LEFT JOIN "  + RetSQLName( 'SD2' ) + " SD2 "            + CRLF //-- ITENS DE VENDA DE NF
    cQuery += "     ON SD2.D2_FILIAL  = '" + FWxFilial('SD2') + "' "    + CRLF
    cQuery += "    AND SD2.D2_DOC     = SF2.F2_DOC"                     + CRLF
    cQuery += "    AND SD2.D2_SERIE   = SF2.F2_SERIE"                   + CRLF
    cQuery += "    AND SD2.D2_CLIENTE = SF2.F2_CLIENTE"                 + CRLF
    cQuery += "    AND SD2.D2_LOJA    = SF2.F2_LOJA"                    + CRLF
    cQuery += "    AND SD2.D2_EMISSAO = SF2.F2_EMISSAO"                 + CRLF
    cQuery += "    AND SD2.D_E_L_E_T_ = ' ' "	                        + CRLF
    cQuery += " LEFT JOIN "  + RetSQLName( 'SFT' ) + " SFT "            + CRLF //-- ITENS LIVROS FISCAIS
	cQuery += "     ON SFT.FT_FILIAL  = '" + FWxFilial('SFT') + "' "    + CRLF 
    cQuery += "    AND SFT.FT_NFISCAL = SF2.F2_DOC"                     + CRLF
    cQuery += "    AND SFT.FT_SERIE   = SF2.F2_SERIE"                   + CRLF
    cQuery += "    AND SFT.FT_CLIEFOR = SF2.F2_CLIENTE"                 + CRLF
    cQuery += "    AND SFT.FT_LOJA	  = SF2.F2_LOJA"                    + CRLF
    cQuery += "    AND SFT.FT_PRODUTO = SD2.D2_COD"                     + CRLF
    cQuery += "    AND SFT.D_E_L_E_T_ = ' ' "	                        + CRLF
    cQuery += " WHERE  "	                                            + CRLF         
    cQuery += "    SF2.F2_FILIAL 		= '" + FWxFilial('SF2') + "' "  + CRLF
	
    If !Empty(DtoS(MV_PAR02)) //DATA EMISSAO ATE
		cQuery += " AND SF2.F2_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'"   + CRLF //--DATA DE EMISSAO
	EndIf

    If !Empty(MV_PAR04) //NOTA FISCAL
		cQuery += " AND SF2.F2_DOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"                   + CRLF //--NOTA FISCAL
	EndIf
    
    If !Empty(MV_PAR05) // NUM SERIE NF
		cQuery += "	AND SF2.F2_SERIE = '" + MV_PAR05 + "'"                                              + CRLF //--SERIE
	EndIf

    If !Empty(MV_PAR07) //FORNECEDOR
		cQuery += " AND SF2.F2_CLIENTE BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"               + CRLF //--FORNECEDOR
	EndIf

    cQuery += "    AND SF2.D_E_L_E_T_ 	= ' ' "                         + CRLF
    cQuery += " GROUP BY  "	                                            + CRLF 
    cQuery += "         SF2.F2_FILIAL "                                 + CRLF    
    cQuery += "         , SD2.D2_CF "                                   + CRLF  
    cQuery += "         , SA1.A1_CGC "                                  + CRLF     
	cQuery += "         , SA1.A1_INSCR "                                + CRLF  	   
    cQuery += "         , SA1.A1_COD "                                  + CRLF 
    cQuery += "         , SA1.A1_LOJA "                                 + CRLF
    cQuery += "         , SA1.A1_NOME "                                 + CRLF  
    cQuery += "         , SA1.A1_EST "                                  + CRLF  	   
    cQuery += "         , SF2.F2_DOC "                                  + CRLF 
    cQuery += "         , SF2.F2_SERIE  "                               + CRLF
    cQuery += "         , SF2.F2_EMISSAO "                               + CRLF
    cQuery += "         , SF2.F2_CHVNFE "                               + CRLF        
    cQuery += "         , SF2.F2_USERLGI "                              + CRLF
    cQuery += "         , SF2.F2_USERLGA )"                             + CRLF        
    cQuery += " SELECT "                                                + CRLF     
    cQuery += "     FILIAL, CNPJ, INS_EST, CODIGO "                     + CRLF 
    cQuery += "     , LOJA, CLIENTE, ESTADO, CHAVE "                    + CRLF 
	cQuery += "  	, NOTA_FISCAL, SERIE, CHAVE, DT_ENTR  "                  + CRLF
    cQuery += "     , CFOP, VALOR_PIS, VALOR_COF "                      + CRLF 
	cQuery += "	    , SF3.F3_ESPECIE    AS ESPECIE "                    + CRLF 
	cQuery += "		, SF3.F3_CFO 		AS CFOP "                       + CRLF 
	cQuery += "		, SF3.F3_ENTRADA    AS DT_LANC "                    + CRLF 
	cQuery += "		, SF3.F3_VALCONT 	AS VALOR_CONTABIL "             + CRLF 
	cQuery += "		, SF3.F3_BASEICM 	AS BASE_ICMS "                  + CRLF 
	cQuery += "		, SF3.F3_VALICM 	AS VAL_ICMS "                   + CRLF 
	cQuery += "		, SF3.F3_ISENICM 	AS ICMS_ISENTO "                + CRLF 
	cQuery += "		, SF3.F3_OUTRICM 	AS ICMS_OUTROS  "               + CRLF 
    cQuery += "		, SF3.F3_BASERET 	AS BASE_SUBST  "                + CRLF 
    cQuery += "		, SF3.F3_ICMSRET 	AS VALOR_SUBST  "               + CRLF 
    cQuery += "		, SF3.F3_BASEIPI 	AS BASE_IPI  "                  + CRLF 
    cQuery += "		, SF3.F3_VALIPI 	AS VAL_IPI  "                   + CRLF 
    cQuery += "		, SF3.F3_ISENIPI 	AS IPI_ISENTO  "                + CRLF 
    cQuery += "		, SF3.F3_OUTRIPI 	AS IPI_OUTROS  "                + CRLF 
    cQuery += "		, SF3.F3_DESPESA 	AS OUTRAS_DESPESAS  "           + CRLF 
    cQuery += "		, SF3.F3_VALOBSE 	AS DESCONTO  "                  + CRLF 
    cQuery += "		, SF3.F3_BASIMP6	AS BASE_PIS  "                  + CRLF 
    cQuery += "		, SF3.F3_BASIMP5	AS BASE_COF  "                  + CRLF 
    cQuery += "		, SF3.F3_BASEPS3 	AS PIS_ST_ZFM  "                + CRLF 
    cQuery += "		, SF3.F3_VALPS3 	AS VAL_PISSTZFM  "              + CRLF     
    cQuery += "		, SF3.F3_BASECF3 	AS COF_ST_ZFM  "                + CRLF 
    cQuery += "		, SF3.F3_VALCF3     AS VAL_COFST_ZFM  "             + CRLF 
    cQuery += "		, SF3.F3_OBSERV 	AS OBSERVACAO  "                + CRLF
    cQuery += "		, SF3.F3_DTCANC "                                   + CRLF
    cQuery += " FROM ABDHDU_PROT.NOTA "                                 + CRLF //-- TEMP NOTA
    cQuery += " LEFT JOIN "  + RetSQLName( 'SF3' ) + " SF3 "            + CRLF //-- LIVROS FISCAIS CABEÇALHO
    cQuery += "     ON SF3.F3_FILIAL  = '" + FWxFilial('SF3') + "' "    + CRLF 
    cQuery += "    AND SF3.F3_NFISCAL = NOTA.NOTA_FISCAL"               + CRLF
    cQuery += "    AND SF3.F3_SERIE   = NOTA.SERIE "                    + CRLF
    cQuery += "    AND SF3.F3_EMISSAO = NOTA.DT_ENTR "               + CRLF
    cQuery += "    AND SF3.F3_CFO     = NOTA.CFOP "                     + CRLF
    cQuery += "    AND SF3.D_E_L_E_T_ = ' ' "	                        + CRLF

    // Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

    //Setando o total da régua.
	Count to nTotal
	oReport:SetMeter( nTotal )
	// Secção 1
	oSection1:Init()
    oSection2:Init()

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())
    While (cAliasTMP)->(!EoF()) .And. !oReport:Cancel()
        //Incrementando a regua
		nAtual++

        oReport:SetMsgPrint("Imprimindo registo " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + " ...")
        oReport:IncMeter()
        
        oSection2:Cell("EMISSAO"):SetValue(StoD((cAliasTMP)->DT_ENTR))
        oSection2:Cell("DT_LANC"):SetValue(StoD((cAliasTMP)->DT_LANC))
        
        //Imprimindo a linha atual
        oSection1:PrintLine()	
    
        If (cAliasTMP)->F3_DTCANC != ' '
            oSection2:Init()

            oSection2:Cell("EMISSAO"):SetValue(StoD((cAliasTMP)->DT_ENTR))
            oSection2:Cell("DT_LANC"):SetValue(StoD((cAliasTMP)->DT_LANC))

            oSection2:PrintLine()	
            oSection2:Finish()	  
        EndIf
        
        (cAliasTMP)->(dbSkip() )
	EndDo               
	oSection1:Finish()	  

    (cAliasTMP)->(DbCloseArea())

	FwRestArea(aArea)         

Return
