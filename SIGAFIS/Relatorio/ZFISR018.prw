#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Totvs.ch"

/*
=====================================================================================
Programa.:              ZFISR018
Autor....:              CAOA - Nicolas C Lima Santos
Data.....:              07/05/2024
Descricao / Objetivo:   Relatório de Cabeçalho NF de Entrada
Doc. Origem:            
Solicitante:            Micaellen Pereira Leal
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZFISR018()
    
	Local	aArea 		:= FwGetArea()
	Local	oReport     := Nil
	Local	aPergs		:= {}
	Local	dDtEmiss	:= Ctod(Space(8)) //Data de emissao de NF
    //Local	_cFilial	:= Space(TamSX3('F3_FILIAL')[1]) 
    Local	cNumNF		:= Space(TamSX3('F3_NFISCAL')[1]) 
    Local	cSerieNF	:= Space(TamSX3('F3_SERIE')[1])
	Local 	cFornece 	:= Space(TamSX3('A2_COD')[1])
	Local 	cPedido		:= Space(TamSX3('C6_NUM')[1])
	
    Private cTabela 	:= GetNextAlias()
    Private cAliasTMP   := GetNextAlias()

    aAdd(aPergs, {1,"Entrada de?"			,dDtEmiss	,/*Pict*/	,/*Valid*/	,/*F3*/		,/*When*/,50,.F.})  //MV_PAR01
	aAdd(aPergs, {1,"Entrada ate?"		    ,dDtEmiss	,/*Pict*/,MV_PAR02 > MV_PAR01,/*F3*/,/*When*/,50,.F.})  //MV_PAR02
	aAdd(aPergs, {1,"Nota Fiscal De?"		,cNumNF		,/*Pict*/	,/*Valid*/	,/*F3*/		,/*When*/,50,.F.})  //MV_PAR03
	aAdd(aPergs, {1,"Nota Fiscal Ate?"		,cNumNF		,/*Pict*/	,/*Valid*/	,/*F3*/		,/*When*/,50,.F.})  //MV_PAR04
    aAdd(aPergs, {1,"Serie?"				,cSerieNF	,/*Pict*/	,/*Valid*/	,/*F3*/	    ,/*When*/,50,.F.})  //MV_PAR05
    aAdd(aPergs, {1,"Fornecedor De?"		,cFornece	,/*Pict*/	,/*Valid*/	,/*F3*/	    ,/*When*/,50,.F.})  //MV_PAR06
	aAdd(aPergs, {1,"Fornecedor Ate?"		,cFornece	,/*Pict*/	,/*Valid*/	,/*F3*/	    ,/*When*/,50,.F.})  //MV_PAR07
	aAdd(aPergs, {1,"Pedido De?"			,cPedido	,/*Pict*/	,/*Valid*/	,/*F3*/	    ,/*When*/,50,.F.}) 	//MV_PAR08
    aAdd(aPergs, {1,"Pedido Ate?"			,cPedido	,/*Pict*/	,/*Valid*/	,/*F3*/	    ,/*When*/,50,.F.}) 	//MV_PAR09

	If ParamBox(aPergs, "Informe os parâmetros para Nota Fiscal de entrada", , , , , , , , , .F., .F.)
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

	oReport:= TReport():New("ZFISR018",;    // --Nome da impressão
                            "Entradas",;    // --Título da tela de parâmetros
                            ,;              // --Grupo de perguntas na SX1, ao invés das pereguntas estou usando Parambox
                            {|oReport|  ReportPrint(oReport)},;
                            "Este relatorio apresenta o cabeçalho das NFs de Entradas") // --Descrição do relatório
   
    oReport:DisableOrientation() //--Desabilita a seleção da Orientação
    oReport:SetLandScape(.T.)    //--Orientação do relatório como paisagem.
	oReport:HideParamPage()      //--Desabilita a impressao da pagina de parametros.
    oReport:HideHeader()         //--Define que não será impresso o cabeçalho padrão da página
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
    TRCell():New( oSection1, "A2_CGC"	 , cAliasTMP, "CNPJ"	         , PesqPict("SA2","A2_CGC")     , TamSx3("A2_CGC")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "A2_INSCR"	 , cAliasTMP, "INS EST"          , PesqPict("SA2","A2_INSCR")   , TamSx3("A2_INSCR")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "A2_COD"	 , cAliasTMP, "COD FORNEC"       , PesqPict("SA2","A2_COD")     , TamSx3("A2_COD")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "A2_LOJA"	 , cAliasTMP, "LOJA"             , PesqPict("SA2","A2_LOJA")    , TamSx3("A2_LOJA")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "A2_NOME"	 , cAliasTMP, "FORNECEDOR"       , PesqPict("SA2","A2_NOME")    , TamSx3("A2_NOME")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "A2_EST"	 , cAliasTMP, "ESTADO"           , PesqPict("SA2","A2_EST")     , TamSx3("A2_EST")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "F3_NFISCAL", cAliasTMP, "NOTA FISCAL"      , PesqPict("SF3","F3_NFISCAL") , TamSx3("F3_NFISCAL")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "F3_SERIE"  , cAliasTMP, "SERIE"            , PesqPict("SF3","F3_SERIE")   , TamSx3("F3_SERIE")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "F3_ESPECIE", cAliasTMP, "ESPECIE"          , PesqPict("SF3","F3_ESPECIE") , TamSx3("F3_ESPECIE")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "F3_CFO"    , cAliasTMP, "CFOP"             , PesqPict("SF3","F3_CFO")     , TamSx3("F3_CFO")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "C6_NUM"    , cAliasTMP, "PEDIDO"           , PesqPict("SC6","C6_NUM")     , TamSx3("C6_NUM")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "DT_EMIS"   , cAliasTMP, "DT EMISSAO"       , PesqPict("SF3", "F3_EMISSAO"), TamSx3("F3_EMISSAO")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "DT_ENTR"   , cAliasTMP, "DT LANC"          , PesqPict("SF3", "F3_ENTRADA"), TamSx3("F3_ENTRADA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_VALCONT", cAliasTMP, "VALOR CONTABIL"   , PesqPict("SF3", "F3_VALCONT"), TamSx3("F3_VALCONT")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_BASEICM", cAliasTMP, "BASE ICMS"        , PesqPict("SF3", "F3_BASEICM"), TamSx3("F3_BASEICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_VALICM" , cAliasTMP, "VAL ICMS"         , PesqPict("SF3", "F3_VALICM") , TamSx3("F3_VALICM")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_ISENICM", cAliasTMP, "ICMS ISENTO"      , PesqPict("SF3", "F3_ISENICM"), TamSx3("F3_ISENICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_OUTRICM", cAliasTMP, "ICMS OUTROS"      , PesqPict("SF3", "F3_OUTRICM"), TamSx3("F3_OUTRICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_BASERET", cAliasTMP, "BASE SUBST"       , PesqPict("SF3", "F3_BASERET"), TamSx3("F3_BASERET")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_ICMSRET", cAliasTMP, "VALOR SUBST"      , PesqPict("SF3", "F3_ICMSRET"), TamSx3("F3_ICMSRET")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_BASEIPI", cAliasTMP, "BASE IPI"         , PesqPict("SF3", "F3_BASEIPI"), TamSx3("F3_BASEIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_VALIPI" , cAliasTMP, "VAL IPI"          , PesqPict("SF3", "F3_VALIPI") , TamSx3("F3_VALIPI")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_ISENIPI", cAliasTMP, "IPI ISENTO"       , PesqPict("SF3", "F3_ISENIPI"), TamSx3("F3_ISENIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_OUTRIPI", cAliasTMP, "IPI OUTROS"       , PesqPict("SF3", "F3_OUTRIPI"), TamSx3("F3_OUTRIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_DESPESA", cAliasTMP, "OUTRAS DESPESAS"  , PesqPict("SF3", "F3_DESPESA"), TamSx3("F3_DESPESA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_VALOBSE", cAliasTMP, "DESCONTO"         , PesqPict("SF3", "F3_VALOBSE"), TamSx3("F3_VALOBSE")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_BASIMP6", cAliasTMP, "BASE PIS"         , PesqPict("SF3", "F3_BASIMP6"), TamSx3("F3_BASIMP6")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_VALIMP6", cAliasTMP, "VAL PIS"          , PesqPict("SF3", "F3_VALIMP6"), TamSx3("F3_VALIMP6")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_BASIMP5", cAliasTMP, "BASE COF"         , PesqPict("SF3", "F3_BASIMP5"), TamSx3("F3_BASIMP5")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_VALIMP5", cAliasTMP, "VAL COF"          , PesqPict("SF3", "F3_VALIMP5"), TamSx3("F3_VALIMP5")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_CHVNFE" , cAliasTMP, "CHAVE"            , PesqPict("SF3", "F3_CHVNFE") , TamSx3("F3_CHVNFE")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_BASEPS3", cAliasTMP, "PIS ST ZFM"       , PesqPict("SF3", "F3_BASEPS3"), TamSx3("F3_BASEPS3")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_VALPS3" , cAliasTMP, "VAL PISST ZFM"    , PesqPict("SF3", "F3_VALPS3") , TamSx3("F3_VALPS3")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_BASECF3", cAliasTMP, "COF ST ZFM"       , PesqPict("SF3", "F3_BASECF3"), TamSx3("F3_BASECF3")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_VALCF3" , cAliasTMP, "VAL COFST ZFM"    , PesqPict("SF3", "F3_VALCF3") , TamSx3("F3_VALCF3")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_OBSERV" , cAliasTMP, "OBSERVACAO"       , PesqPict("SF3", "F3_OBSERV") , TamSx3("F3_OBSERV")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_DTCANC" , cAliasTMP, "DATA CANCEL"      , PesqPict("SF3", "F3_DTCANC") , TamSx3("F3_DTCANC")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)

    oSection2 := TRSection():New(oReport    ,"NF canceladas"    ,{cAliasTMP}) 
    
    //--Colunas do relatório
    TRCell():New( oSection2, "A2_CGC"	, cAliasTMP, "CNPJ"	            , PesqPict("SA2","A2_CGC")     , TamSx3("A2_CGC")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "A2_INSCR"	, cAliasTMP, "INS EST"          , PesqPict("SA2","A2_INSCR")   , TamSx3("A2_INSCR")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "A2_COD"	, cAliasTMP, "COD FORNEC"       , PesqPict("SA2","A2_COD")     , TamSx3("A2_COD")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "A2_LOJA"	, cAliasTMP, "LOJA"             , PesqPict("SA2","A2_LOJA")    , TamSx3("A2_LOJA")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "A2_NOME"	, cAliasTMP, "FORNECEDOR"       , PesqPict("SA2","A2_NOME")    , TamSx3("A2_NOME")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "A2_EST"	 , cAliasTMP, "ESTADO"          , PesqPict("SA2","A2_EST")     , TamSx3("A2_EST")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "F3_NFISCAL", cAliasTMP, "NOTA FISCAL"     , PesqPict("SF3","F3_NFISCAL") , TamSx3("F3_NFISCAL")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "F3_SERIE"  , cAliasTMP, "SERIE"           , PesqPict("SF3","F3_SERIE")   , TamSx3("F3_SERIE")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "F3_ESPECIE", cAliasTMP, "ESPECIE"         , PesqPict("SF3","F3_ESPECIE") , TamSx3("F3_ESPECIE")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "F3_CFO"    , cAliasTMP, "CFOP"            , PesqPict("SF3","F3_CFO")     , TamSx3("F3_CFO")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "C6_NUM"    , cAliasTMP, "PEDIDO"          , PesqPict("SC6","C6_NUM")     , TamSx3("C6_NUM")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "DT_EMIS"   , cAliasTMP, "DT EMISSAO"      , PesqPict("SF3", "F3_EMISSAO"), TamSx3("F3_EMISSAO")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "DT_ENTR"   , cAliasTMP, "DT LANC"         , PesqPict("SF3", "F3_ENTRADA"), TamSx3("F3_ENTRADA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_VALCONT", cAliasTMP, "VALOR CONTABIL"  , PesqPict("SF3", "F3_VALCONT"), TamSx3("F3_VALCONT")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_BASEICM", cAliasTMP, "BASE ICMS"       , PesqPict("SF3", "F3_BASEICM"), TamSx3("F3_BASEICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_VALICM" , cAliasTMP, "VAL ICMS"        , PesqPict("SF3", "F3_VALICM") , TamSx3("F3_VALICM")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_ISENICM", cAliasTMP, "ICMS ISENTO"     , PesqPict("SF3", "F3_ISENICM"), TamSx3("F3_ISENICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_OUTRICM", cAliasTMP, "ICMS OUTROS"     , PesqPict("SF3", "F3_OUTRICM"), TamSx3("F3_OUTRICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_BASERET", cAliasTMP, "BASE SUBST"      , PesqPict("SF3", "F3_BASERET"), TamSx3("F3_BASERET")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_ICMSRET", cAliasTMP, "VALOR SUBST"     , PesqPict("SF3", "F3_ICMSRET"), TamSx3("F3_ICMSRET")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_BASEIPI", cAliasTMP, "BASE IPI"        , PesqPict("SF3", "F3_BASEIPI"), TamSx3("F3_BASEIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_VALIPI" , cAliasTMP, "VAL IPI"         , PesqPict("SF3", "F3_VALIPI") , TamSx3("F3_VALIPI")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_ISENIPI", cAliasTMP, "IPI ISENTO"      , PesqPict("SF3", "F3_ISENIPI"), TamSx3("F3_ISENIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_OUTRIPI", cAliasTMP, "IPI OUTROS"      , PesqPict("SF3", "F3_OUTRIPI"), TamSx3("F3_OUTRIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_DESPESA", cAliasTMP, "OUTRAS DESPESAS" , PesqPict("SF3", "F3_DESPESA"), TamSx3("F3_DESPESA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_VALOBSE", cAliasTMP, "DESCONTO"        , PesqPict("SF3", "F3_VALOBSE"), TamSx3("F3_VALOBSE")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_BASIMP6", cAliasTMP, "BASE PIS"        , PesqPict("SF3", "F3_BASIMP6"), TamSx3("F3_BASIMP6")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_VALIMP6", cAliasTMP, "VAL PIS"         , PesqPict("SF3", "F3_VALIMP6"), TamSx3("F3_VALIMP6")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_BASIMP5", cAliasTMP, "BASE COF"        , PesqPict("SF3", "F3_BASIMP5"), TamSx3("F3_BASIMP5")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_VALIMP5", cAliasTMP, "VAL COF"         , PesqPict("SF3", "F3_VALIMP5"), TamSx3("F3_VALIMP5")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_CHVNFE" , cAliasTMP, "CHAVE"           , PesqPict("SF3", "F3_CHVNFE") , TamSx3("F3_CHVNFE")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_BASEPS3", cAliasTMP, "PIS ST ZFM"      , PesqPict("SF3", "F3_BASEPS3"), TamSx3("F3_BASEPS3")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_VALPS3" , cAliasTMP, "VAL PISST ZFM"   , PesqPict("SF3", "F3_VALPS3") , TamSx3("F3_VALPS3")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_BASECF3", cAliasTMP, "COF ST ZFM"      , PesqPict("SF3", "F3_BASECF3"), TamSx3("F3_BASECF3")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_VALCF3" , cAliasTMP, "VAL COFST ZFM"   , PesqPict("SF3", "F3_VALCF3") , TamSx3("F3_VALCF3")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_OBSERV" , cAliasTMP, "OBSERVACAO"      , PesqPict("SF3", "F3_OBSERV") , TamSx3("F3_OBSERV")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_DTCANC" , cAliasTMP, "DATA CANCEL"     , PesqPict("SF3", "F3_DTCANC") , TamSx3("F3_DTCANC")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)


    //oReport:PrintDialog()

Return(oReport)

//----------------------------------------------------------
//----------------------------------------------------------
Static Function  ReportPrint(oReport)

    Local aArea 	:= FWGetArea()
    Local oSection1  := Nil
    Local oSection2  := Nil
    Local cQuery    := ""
    
    oSection1  := oReport:Section(1)
    oSection2  := oReport:Section(2)

	If Select(cAliasTMP) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf

    cQuery := " "
    cQuery += " SELECT "	            + CRLF
	cQuery += "	    SA2.A2_CGC      , "	+ CRLF
	cQuery += "	    SA2.A2_INSCR    , "	+ CRLF
	cQuery += "	    SA2.A2_COD   	, "	+ CRLF
	cQuery += "	    SA2.A2_LOJA  	, "	+ CRLF
	cQuery += "	    SA2.A2_NOME    	, "	+ CRLF
	cQuery += "	    SA2.A2_EST     	, "	+ CRLF
	cQuery += "	    SF3.F3_NFISCAL 	, "	+ CRLF
	cQuery += "	    SF3.F3_SERIE 	, "	+ CRLF
	cQuery += "	    SF3.F3_ESPECIE 	, "	+ CRLF
	cQuery += "	    SF3.F3_CFO 		, "	+ CRLF
	cQuery += "	    SC6.C6_NUM 		, "	+ CRLF
	cQuery += "	    SF3.F3_EMISSAO AS DT_EMIS , "	+ CRLF
	cQuery += "	    SF3.F3_ENTRADA AS DT_ENTR , "	+ CRLF 
	cQuery += "	    SF3.F3_VALCONT 	, "	+ CRLF 
	cQuery += "	    SF3.F3_BASEICM 	, "	+ CRLF
	cQuery += "	    SF3.F3_VALICM 	, "	+ CRLF
	cQuery += "	    SF3.F3_ISENICM 	, "	+ CRLF
	cQuery += "	    SF3.F3_OUTRICM 	, "	+ CRLF
	cQuery += "	    SF3.F3_BASERET 	, "	+ CRLF
	cQuery += "	    SF3.F3_ICMSRET 	, "	+ CRLF
	cQuery += "	    SF3.F3_BASEIPI 	, "	+ CRLF
	cQuery += "	    SF3.F3_VALIPI 	, "	+ CRLF
	cQuery += "	    SF3.F3_ISENIPI 	, "	+ CRLF
	cQuery += "	    SF3.F3_OUTRIPI 	, "	+ CRLF
	cQuery += "	    SF3.F3_DESPESA 	, "	+ CRLF
	cQuery += "	    SF3.F3_VALOBSE  , "	+ CRLF
	cQuery += "	    SF3.F3_BASIMP6 	, "	+ CRLF
	cQuery += "	    SF3.F3_VALIMP6 	, "	+ CRLF
	cQuery += "	    SF3.F3_BASIMP5 	, "	+ CRLF
	cQuery += "	    SF3.F3_VALIMP5 	, "	+ CRLF
	cQuery += "	    SF3.F3_CHVNFE 	, "	+ CRLF
	cQuery += "	    SF3.F3_BASEPS3  , "	+ CRLF
	cQuery += "	    SF3.F3_VALPS3 	, "	+ CRLF
	cQuery += "	    SF3.F3_BASECF3 	, "	+ CRLF
	cQuery += "	    SF3.F3_VALCF3 	, "	+ CRLF
	cQuery += "	    SF3.F3_OBSERV 	, "	+ CRLF
	cQuery += "	    SF3.F3_DTCANC     "	+ CRLF
    cQuery += " FROM "       + RetSQLName( 'SF3' ) + " SF3 "            + CRLF //-- LIVROS FISCAIS
    cQuery += " INNER JOIN " + RetSQLName( 'SA2' ) + " SA2 "            + CRLF //-- FORNECEDORES
    cQuery += "     ON SA2.A2_FILIAL   = '" + FWxFilial('SA2') + "' "   + CRLF 
    cQuery += "     AND SF3.F3_CLIEFOR = SA2.A2_COD "	                + CRLF
    cQuery += "     AND SA2.D_E_L_E_T_ = ' ' "	                        + CRLF
    cQuery += " INNER JOIN " + RetSQLName( 'SC6' ) + " SC6 "            + CRLF //-- ITENS PEDIDO DE VENDA
    cQuery += "     ON SC6.C6_FILIAL   = '" + FWxFilial('SC6') + "' "   + CRLF
    cQuery += "     AND SF3.F3_NFISCAL = SC6.C6_NOTA  "	                + CRLF
    cQuery += "     AND SC6.D_E_L_E_T_ = ' ' "	                        + CRLF
    cQuery += " INNER JOIN " + RetSQLName( 'SFT' ) + " SFT "            + CRLF //-- LIVROS FISCAIS POR ITEM DE NF
    cQuery += "     ON SFT.FT_FILIAL   = '" + FWxFilial('SFT') + "' "   + CRLF
    cQuery += "     AND SF3.F3_NFISCAL  = SFT.FT_NFISCAL  "	            + CRLF
    cQuery += "     AND SF3.F3_CFO      = SFT.FT_CFOP  "	            + CRLF
    cQuery += "     AND SFT.D_E_L_E_T_ = ' ' "	                        + CRLF
    cQuery += " WHERE  "	                                            + CRLF 
    cQuery += "     SF3.F3_FILIAL = '" + FWxFilial('SF3') + "' "        + CRLF	
    cQuery += "     AND SFT.FT_TIPOMOV      = 'E' "                     + CRLF	
	
    If !Empty(DtoS(MV_PAR02)) //DATA ENTRADA ATE
		cQuery += " AND SF3.F3_ENTRADA BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'"   + CRLF //--DATA ENTRADA
	EndIf
    
    If !Empty(MV_PAR04) // NOTA FISCAL ATE
		cQuery += "	AND SF3.F3_NFISCAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"               + CRLF //--NOTA FISCAL
	EndIf

    If !Empty(MV_PAR05) // NUM SERIE NF
		cQry += "	AND SF3.F3_SERIE = '" + MV_PAR05 + "'"                                              + CRLF //--SERIE
	EndIf
	
    If !Empty(MV_PAR07) // FORNECEDOR ATE
		cQuery += "	AND SA2.A2_COD BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"                   + CRLF //--FORNECEDOR
	EndIf
	
    If !Empty(MV_PAR09) // PEDIDO ATE
		cQuery += "	AND SC6.C6_NUM BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "'"                   + CRLF //--PEDIDO
	EndIf
	
	cQuery += "	AND SF3.D_E_L_E_T_  = ' ' "   + CRLF

    // Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

	oReport:SetMeter( Contar(cAliasTMP,"!Eof()") )
	// Secção 1
	oSection1:Init()

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())
    While (cAliasTMP)->(!EoF()) .And. !oReport:Cancel()

        // Incrementa a mensagem na régua.
        oReport:IncMeter()

        oSection1:Cell("DT_EMIS"):SetValue(StoD((cAliasTMP)->DT_EMIS))
        oSection1:Cell("DT_ENTR"):SetValue(StoD((cAliasTMP)->DT_ENTR))
        
        //Imprimindo a linha atual
        oSection1:PrintLine()	
    
        If (cAliasTMP)->F3_DTCANC != ' '
            oSection2:Init()
            oSection2:PrintLine()	
            oSection2:Finish()	  
        EndIf
        
        (cAliasTMP)->(dbSkip() )
	EndDo               
	oSection1:Finish()	  

    (cAliasTMP)->(DbCloseArea())

	FwRestArea(aArea)         

Return
