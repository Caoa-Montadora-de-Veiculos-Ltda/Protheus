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
	Local	dDtEmiss	:= Ctod(Space(8)) 
    //Local	cNumNF		:= Space(TamSX3('F3_NFISCAL')[1]) 
    //Local	cSerieNF	:= Space(TamSX3('F3_SERIE')[1])
	//Local 	cFornece 	:= Space(TamSX3('A2_COD')[1])
	Local 	cPedido		:= Space(TamSX3('C6_NUM')[1])
    Local	cNumNF		:= Space(TamSX3('F1_DOC')[1]) 
    Local	cSerieNF	:= Space(TamSX3('F1_SERIE')[1])
	Local 	cFornece 	:= Space(TamSX3('F1_FORNECE')[1])
	//Local 	cPedido		:= Space(TamSX3('C6_NUM')[1])

    Private cTabela 	:= GetNextAlias()
    Private cAliasTMP   := GetNextAlias()

    aAdd(aPergs, {1,"Emissao De"		,dDtEmiss	,/*Pict*/	,/*Valid*/	,/*F3*/		,/*When*/,50,.F.})  //MV_PAR01
	aAdd(aPergs, {1,"Emissao Ate"		,dDtEmiss	,/*Pict*/,MV_PAR02 > MV_PAR01,/*F3*/,/*When*/,50,.F.})  //MV_PAR02
	aAdd(aPergs, {1,"Nota Fiscal De"	,cNumNF		,/*Pict*/	,/*Valid*/	,"SF2"   ,/*When*/,50,.F.})  //MV_PAR03
	aAdd(aPergs, {1,"Nota Fiscal Ate"	,cNumNF		,/*Pict*/	,/*Valid*/	,"SF2"		,/*When*/,50,.F.})  //MV_PAR04
    aAdd(aPergs, {1,"Serie"				,cSerieNF	,/*Pict*/	,/*Valid*/	,"_SF1SE"	    ,/*When*/,50,.F.})  //MV_PAR05
    aAdd(aPergs, {1,"Fornecedor De"		,cFornece	,/*Pict*/	,/*Valid*/	,"SA2"	    ,/*When*/,50,.F.})  //MV_PAR06
	aAdd(aPergs, {1,"Fornecedor Ate"	,cFornece	,/*Pict*/	,/*Valid*/	,"SA2"	    ,/*When*/,50,.F.})  //MV_PAR07
	aAdd(aPergs, {1,"Pedido De"			,cPedido	,/*Pict*/	,/*Valid*/	,"SC6"	    ,/*When*/,50,.F.}) 	//MV_PAR08
    aAdd(aPergs, {1,"Pedido Ate"		,cPedido	,/*Pict*/	,/*Valid*/	,"SC6"	    ,/*When*/,50,.F.}) 	//MV_PAR09

    aAdd(aPergs, {1,"Emissao De"		,dDtEmiss	,/*Pict*/	,/*Valid*/	        ,/*F3*/	  ,/*When*/,50,.F.})  //MV_PAR01
	aAdd(aPergs, {1,"Emissao Ate"		,dDtEmiss	,/*Pict*/,MV_PAR02 > MV_PAR01   ,/*F3*/,/*When*/,50,.F.})//MV_PAR02
	aAdd(aPergs, {1,"Nota Fiscal De"	,cNumNF		,/*Pict*/	,/*Valid*/	        ,"SF1"    ,/*When*/,50,.F.})  //MV_PAR03
	aAdd(aPergs, {1,"Nota Fiscal Ate"	,cNumNF		,/*Pict*/	,/*Valid*/	        ,"SF1"	  ,/*When*/,50,.F.})  //MV_PAR04
    aAdd(aPergs, {1,"Serie"				,cSerieNF	,/*Pict*/	,/*Valid*/	        ,"_SF1SE" ,/*When*/,50,.F.})  //MV_PAR05
    aAdd(aPergs, {1,"Fornecedor De"		,cFornece	,/*Pict*/	,/*Valid*/	        ,"SA2"	  ,/*When*/,50,.F.})  //MV_PAR06
	aAdd(aPergs, {1,"Fornecedor Ate"	,cFornece	,/*Pict*/	,/*Valid*/	        ,"SA2"	  ,/*When*/,50,.F.})  //MV_PAR07

	If ParamBox(aPergs, "Informe os parâmetros para Nota Fiscal de entrada", , , , , , , , , .F., .F.)
		oReport := fReportDef()
		oReport:PrintDialog()
@@ -81,86 +79,82 @@ Static Function fReportDef()
	oSection1 := TRSection():New(oReport    ,"NF ativas"    ,{cAliasTMP}) 

    //--Colunas do relatório
    TRCell():New( oSection1, "A2_CGC"	 , cAliasTMP, "CNPJ"	         , PesqPict("SA2","A2_CGC")     , TamSx3("A2_CGC")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "A2_INSCR"	 , cAliasTMP, "INS EST"          , PesqPict("SA2","A2_INSCR")   , TamSx3("A2_INSCR")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "A2_COD"	 , cAliasTMP, "CODIGO"           , PesqPict("SA2","A2_COD")     , TamSx3("A2_COD")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "A2_LOJA"	 , cAliasTMP, "LJ"               , PesqPict("SA2","A2_LOJA")    , TamSx3("A2_LOJA")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "A2_NOME"	 , cAliasTMP, "FORNECEDOR"       , PesqPict("SA2","A2_NOME")    , TamSx3("A2_NOME")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "A2_EST"	 , cAliasTMP, "UF"               , PesqPict("SA2","A2_EST")     , TamSx3("A2_EST")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "F3_NFISCAL", cAliasTMP, "NF"               , PesqPict("SF3","F3_NFISCAL") , TamSx3("F3_NFISCAL")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "F3_SERIE"  , cAliasTMP, "SERIE"            , PesqPict("SF3","F3_SERIE")   , TamSx3("F3_SERIE")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "F3_ESPECIE", cAliasTMP, "ESPECIE"          , PesqPict("SF3","F3_ESPECIE") , TamSx3("F3_ESPECIE")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "F3_CFO"    , cAliasTMP, "CFOP"             , PesqPict("SF3","F3_CFO")     , TamSx3("F3_CFO")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "C6_NUM"    , cAliasTMP, "PEDIDO"           , PesqPict("SC6","C6_NUM")     , TamSx3("C6_NUM")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "DT_EMIS"   , cAliasTMP, "EMISSAO"          , PesqPict("SF3", "F3_EMISSAO"), TamSx3("F3_EMISSAO")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "DT_ENTR"   , cAliasTMP, "DT LANC"          , PesqPict("SF3", "F3_ENTRADA"), TamSx3("F3_ENTRADA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "F3_VALCONT", cAliasTMP, "VALOR"            , PesqPict("SF3", "F3_VALCONT"), TamSx3("F3_VALCONT")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
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
    //TRCell():New( oSection1, "F3_DTCANC" , cAliasTMP, "DATA CANCEL"      , PesqPict("SF3", "F3_DTCANC") , TamSx3("F3_DTCANC")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)

    TRCell():New( oSection1, "CNPJ"	            , cAliasTMP, "CNPJ"	              , PesqPict("SA2","A2_CGC")     , TamSx3("A2_CGC")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "INS_EST"	        , cAliasTMP, "INS EST"            , PesqPict("SA2","A2_INSCR")   , TamSx3("A2_INSCR")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "CODIGO"	        , cAliasTMP, "CODIGO"             , PesqPict("SA2","A2_COD")     , TamSx3("A2_COD")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "LOJA"	            , cAliasTMP, "LJ"                 , PesqPict("SA2","A2_LOJA")    , TamSx3("A2_LOJA")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "FORNECEDOR"	    , cAliasTMP, "FORNECEDOR"         , PesqPict("SA2","A2_NOME")    , TamSx3("A2_NOME")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "ESTADO"	        , cAliasTMP, "UF"                 , PesqPict("SA2","A2_EST")     , TamSx3("A2_EST")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "NOTA_FISCAL"      , cAliasTMP, "NF"                 , PesqPict("SF1","F1_DOC")     , TamSx3("F1_DOC")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "SERIE"            , cAliasTMP, "SERIE"              , PesqPict("SF1","F1_SERIE")   , TamSx3("F1_SERIE")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "ESPECIE"          , cAliasTMP, "ESPECIE"            , PesqPict("SF3","F3_ESPECIE") , TamSx3("F3_ESPECIE")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "CFOP"             , cAliasTMP, "CFOP"               , PesqPict("SF3","F3_CFO")     , TamSx3("F3_CFO")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection1, "DT_EMISSAO"       , cAliasTMP, "EMISSAO"            , PesqPict("SF3", "F3_EMISSAO"), TamSx3("F3_EMISSAO")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "DT_LANC"          , cAliasTMP, "DT LANC"            , PesqPict("SF3", "F3_ENTRADA"), TamSx3("F3_ENTRADA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VALOR_CONTABIL"   , cAliasTMP, "VALOR"              , PesqPict("SF3", "F3_VALCONT"), TamSx3("F3_VALCONT")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "BASE_ICMS"        , cAliasTMP, "BASE ICMS"          , PesqPict("SF3", "F3_BASEICM"), TamSx3("F3_BASEICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VAL_ICMS"         , cAliasTMP, "VAL ICMS"           , PesqPict("SF3", "F3_VALICM") , TamSx3("F3_VALICM")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "ICMS_ISENTO"      , cAliasTMP, "ICMS ISENTO"        , PesqPict("SF3", "F3_ISENICM"), TamSx3("F3_ISENICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "CMS_OUTROS"       , cAliasTMP, "ICMS OUTROS"        , PesqPict("SF3", "F3_OUTRICM"), TamSx3("F3_OUTRICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "BASE_SUBST"       , cAliasTMP, "BASE SUBST"         , PesqPict("SF3", "F3_BASERET"), TamSx3("F3_BASERET")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VALOR_SUBST"      , cAliasTMP, "VALOR SUBST"        , PesqPict("SF3", "F3_ICMSRET"), TamSx3("F3_ICMSRET")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "BASE_IPI"         , cAliasTMP, "BASE IPI"           , PesqPict("SF3", "F3_BASEIPI"), TamSx3("F3_BASEIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VAL_IPI"          , cAliasTMP, "VAL IPI"            , PesqPict("SF3", "F3_VALIPI") , TamSx3("F3_VALIPI")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "IPI_ISENTO"       , cAliasTMP, "IPI ISENTO"         , PesqPict("SF3", "F3_ISENIPI"), TamSx3("F3_ISENIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "IPI_OUTROS"       , cAliasTMP, "IPI OUTROS"         , PesqPict("SF3", "F3_OUTRIPI"), TamSx3("F3_OUTRIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "OUTRAS_DESPESAS"  , cAliasTMP, "OUTRAS DESPESAS"    , PesqPict("SF3", "F3_DESPESA"), TamSx3("F3_DESPESA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "DESCONTO"         , cAliasTMP, "DESCONTO"           , PesqPict("SF3", "F3_VALOBSE"), TamSx3("F3_VALOBSE")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "BASE_PIS"         , cAliasTMP, "BASE PIS"           , PesqPict("SF3", "F3_BASIMP6"), TamSx3("F3_BASIMP6")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VALOR_PIS"        , cAliasTMP, "VAL PIS"            , PesqPict("SF3", "F3_VALIMP6"), TamSx3("F3_VALIMP6")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "BASE_COF"         , cAliasTMP, "BASE COF"           , PesqPict("SF3", "F3_BASIMP5"), TamSx3("F3_BASIMP5")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VALOR_COF"        , cAliasTMP, "VAL COF"            , PesqPict("SF3", "F3_VALIMP5"), TamSx3("F3_VALIMP5")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "CHAVE"            , cAliasTMP, "CHAVE"              , PesqPict("SF1", "F1_CHVNFE") , TamSx3("F1_CHVNFE")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "PIS_ST_ZFM"       , cAliasTMP, "PIS ST ZFM"         , PesqPict("SF3", "F3_BASEPS3"), TamSx3("F3_BASEPS3")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VAL_PISSTZFM"     , cAliasTMP, "VAL PISST ZFM"      , PesqPict("SF3", "F3_VALPS3") , TamSx3("F3_VALPS3")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "COF_ST_ZFM"       , cAliasTMP, "COF ST ZFM"         , PesqPict("SF3", "F3_BASECF3"), TamSx3("F3_BASECF3")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "VAL_COFST_ZFM"    , cAliasTMP, "VAL COFST ZFM"      , PesqPict("SF3", "F3_VALCF3") , TamSx3("F3_VALCF3")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection1, "OBSERVACAO"       , cAliasTMP, "OBSERVACAO"         , PesqPict("SF3", "F3_OBSERV") , TamSx3("F3_OBSERV")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)

    oSection2 := TRSection():New(oReport    ,"NF canceladas"    ,{cAliasTMP}) 


    //--Colunas do relatório
    TRCell():New( oSection2, "A2_CGC"	, cAliasTMP, "CNPJ"	            , PesqPict("SA2","A2_CGC")     , TamSx3("A2_CGC")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "A2_INSCR"	, cAliasTMP, "INS EST"          , PesqPict("SA2","A2_INSCR")   , TamSx3("A2_INSCR")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "A2_COD"	, cAliasTMP, "CODIGO"       , PesqPict("SA2","A2_COD")     , TamSx3("A2_COD")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "A2_LOJA"	, cAliasTMP, "LJ"             , PesqPict("SA2","A2_LOJA")    , TamSx3("A2_LOJA")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "A2_NOME"	, cAliasTMP, "FORNECEDOR"       , PesqPict("SA2","A2_NOME")    , TamSx3("A2_NOME")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "A2_EST"	 , cAliasTMP, "UF"          , PesqPict("SA2","A2_EST")     , TamSx3("A2_EST")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "F3_NFISCAL", cAliasTMP, "NF"     , PesqPict("SF3","F3_NFISCAL") , TamSx3("F3_NFISCAL")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "F3_SERIE"  , cAliasTMP, "SERIE"           , PesqPict("SF3","F3_SERIE")   , TamSx3("F3_SERIE")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "F3_ESPECIE", cAliasTMP, "ESPECIE"         , PesqPict("SF3","F3_ESPECIE") , TamSx3("F3_ESPECIE")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "F3_CFO"    , cAliasTMP, "CFOP"            , PesqPict("SF3","F3_CFO")     , TamSx3("F3_CFO")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "C6_NUM"    , cAliasTMP, "PEDIDO"          , PesqPict("SC6","C6_NUM")     , TamSx3("C6_NUM")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "DT_EMIS"   , cAliasTMP, "EMISSAO"      , PesqPict("SF3", "F3_EMISSAO"), TamSx3("F3_EMISSAO")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "DT_ENTR"   , cAliasTMP, "DT LANC"         , PesqPict("SF3", "F3_ENTRADA"), TamSx3("F3_ENTRADA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "F3_VALCONT", cAliasTMP, "VALOR"  , PesqPict("SF3", "F3_VALCONT"), TamSx3("F3_VALCONT")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
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
    //TRCell():New( oSection2, "F3_DTCANC" , cAliasTMP, "DATA CANCEL"     , PesqPict("SF3", "F3_DTCANC") , TamSx3("F3_DTCANC")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)

    TRCell():New( oSection2, "CNPJ"	            , cAliasTMP, "CNPJ"	              , PesqPict("SA2","A2_CGC")     , TamSx3("A2_CGC")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "INS_EST"	        , cAliasTMP, "INS EST"            , PesqPict("SA2","A2_INSCR")   , TamSx3("A2_INSCR")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "CODIGO"	        , cAliasTMP, "CODIGO"             , PesqPict("SA2","A2_COD")     , TamSx3("A2_COD")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "LOJA"	            , cAliasTMP, "LJ"                 , PesqPict("SA2","A2_LOJA")    , TamSx3("A2_LOJA")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "FORNECEDOR"	    , cAliasTMP, "FORNECEDOR"         , PesqPict("SA2","A2_NOME")    , TamSx3("A2_NOME")[1]    , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "ESTADO"	        , cAliasTMP, "UF"                 , PesqPict("SA2","A2_EST")     , TamSx3("A2_EST")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "NOTA_FISCAL"      , cAliasTMP, "NF"                 , PesqPict("SF1","F1_DOC")     , TamSx3("F1_DOC")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "SERIE"            , cAliasTMP, "SERIE"              , PesqPict("SF1","F1_SERIE")   , TamSx3("F1_SERIE")[1]   , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "ESPECIE"          , cAliasTMP, "ESPECIE"            , PesqPict("SF3","F3_ESPECIE") , TamSx3("F3_ESPECIE")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "CFOP"             , cAliasTMP, "CFOP"               , PesqPict("SF3","F3_CFO")     , TamSx3("F3_CFO")[1]     , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection2, "DT_EMISSAO"       , cAliasTMP, "EMISSAO"            , PesqPict("SF3", "F3_EMISSAO"), TamSx3("F3_EMISSAO")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "DT_LANC"          , cAliasTMP, "DT LANC"            , PesqPict("SF3", "F3_ENTRADA"), TamSx3("F3_ENTRADA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VALOR_CONTABIL"   , cAliasTMP, "VALOR"              , PesqPict("SF3", "F3_VALCONT"), TamSx3("F3_VALCONT")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "BASE_ICMS"        , cAliasTMP, "BASE ICMS"          , PesqPict("SF3", "F3_BASEICM"), TamSx3("F3_BASEICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VAL_ICMS"         , cAliasTMP, "VAL ICMS"           , PesqPict("SF3", "F3_VALICM") , TamSx3("F3_VALICM")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "ICMS_ISENTO"      , cAliasTMP, "ICMS ISENTO"        , PesqPict("SF3", "F3_ISENICM"), TamSx3("F3_ISENICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "CMS_OUTROS"       , cAliasTMP, "ICMS OUTROS"        , PesqPict("SF3", "F3_OUTRICM"), TamSx3("F3_OUTRICM")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "BASE_SUBST"       , cAliasTMP, "BASE SUBST"         , PesqPict("SF3", "F3_BASERET"), TamSx3("F3_BASERET")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VALOR_SUBST"      , cAliasTMP, "VALOR SUBST"        , PesqPict("SF3", "F3_ICMSRET"), TamSx3("F3_ICMSRET")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "BASE_IPI"         , cAliasTMP, "BASE IPI"           , PesqPict("SF3", "F3_BASEIPI"), TamSx3("F3_BASEIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VAL_IPI"          , cAliasTMP, "VAL IPI"            , PesqPict("SF3", "F3_VALIPI") , TamSx3("F3_VALIPI")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "IPI_ISENTO"       , cAliasTMP, "IPI ISENTO"         , PesqPict("SF3", "F3_ISENIPI"), TamSx3("F3_ISENIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "IPI_OUTROS"       , cAliasTMP, "IPI OUTROS"         , PesqPict("SF3", "F3_OUTRIPI"), TamSx3("F3_OUTRIPI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "OUTRAS_DESPESAS"  , cAliasTMP, "OUTRAS DESPESAS"    , PesqPict("SF3", "F3_DESPESA"), TamSx3("F3_DESPESA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "DESCONTO"         , cAliasTMP, "DESCONTO"           , PesqPict("SF3", "F3_VALOBSE"), TamSx3("F3_VALOBSE")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "BASE_PIS"         , cAliasTMP, "BASE PIS"           , PesqPict("SF3", "F3_BASIMP6"), TamSx3("F3_BASIMP6")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VALOR_PIS"        , cAliasTMP, "VAL PIS"            , PesqPict("SF3", "F3_VALIMP6"), TamSx3("F3_VALIMP6")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "BASE_COF"         , cAliasTMP, "BASE COF"           , PesqPict("SF3", "F3_BASIMP5"), TamSx3("F3_BASIMP5")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VALOR_COF"        , cAliasTMP, "VAL COF"            , PesqPict("SF3", "F3_VALIMP5"), TamSx3("F3_VALIMP5")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "CHAVE"            , cAliasTMP, "CHAVE"              , PesqPict("SF1", "F1_CHVNFE") , TamSx3("F1_CHVNFE")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "PIS_ST_ZFM"       , cAliasTMP, "PIS ST ZFM"         , PesqPict("SF3", "F3_BASEPS3"), TamSx3("F3_BASEPS3")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VAL_PISSTZFM"     , cAliasTMP, "VAL PISST ZFM"      , PesqPict("SF3", "F3_VALPS3") , TamSx3("F3_VALPS3")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "COF_ST_ZFM"       , cAliasTMP, "COF ST ZFM"         , PesqPict("SF3", "F3_BASECF3"), TamSx3("F3_BASECF3")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "VAL_COFST_ZFM"    , cAliasTMP, "VAL COFST ZFM"      , PesqPict("SF3", "F3_VALCF3") , TamSx3("F3_VALCF3")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection2, "OBSERVACAO"       , cAliasTMP, "OBSERVACAO"         , PesqPict("SF3", "F3_OBSERV") , TamSx3("F3_OBSERV")[1]  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)


    //oReport:PrintDialog()

@@ -184,84 +178,115 @@ Static Function  ReportPrint(oReport)
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
    cQuery := " "                                                       + CRLF
    cQuery += " WITH NOTA AS ( "                                        + CRLF
    cQuery += "     SELECT "                                            + CRLF
    cQuery += "         SF1.F1_FILIAL    AS FILIAL "                    + CRLF
    cQuery += "         , SA2.A2_CGC   	 AS CNPJ "                      + CRLF
    cQuery += "         , SA2.A2_INSCR 	 AS INS_EST "                   + CRLF
    cQuery += "         , SA2.A2_COD   	 AS CODIGO "                + CRLF  
    cQuery += "         , SA2.A2_LOJA  	 AS LOJA "                      + CRLF       
    cQuery += "         , SA2.A2_NOME    AS FORNECEDOR "                + CRLF
    cQuery += "         , SA2.A2_EST     AS ESTADO "                    + CRLF
    cQuery += "         , SF1.F1_DOC     AS NOTA_FISCAL "               + CRLF 
    cQuery += "         , SF1.F1_SERIE   AS SERIE "                     + CRLF
    cQuery += "         , SF1.F1_EMISSAO AS DT_EMISSAO "                + CRLF
    cQuery += "         , SF1.F1_CHVNFE  AS CHAVE "                     + CRLF
    cQuery += "         , SD1.D1_CF      AS CFOP "                      + CRLF
    cQuery += "         , SUM(FT_VALPIS) AS VALOR_PIS "                 + CRLF
    cQuery += "         , SUM(FT_VALCOF) AS VALOR_COF "                 + CRLF
    cQuery += " FROM "       + RetSQLName( 'SF1' ) + " SF1 "            + CRLF //-- CAB. NOTA FISCAL DE ENTRADA
    cQuery += " LEFT JOIN "  + RetSQLName( 'SA2' ) + " SA2 "            + CRLF //-- FORNECEDORES
    cQuery += "     ON SA2.A2_FILIAL  = '" + FWxFilial('SA2') + "' "    + CRLF 
    cQuery += "    AND SA2.A2_COD     = SF1.F1_FORNECE"                 + CRLF 
    cQuery += "    AND SA2.A2_LOJA    = SF1.F1_LOJA "                   + CRLF 
    cQuery += "    AND SA2.D_E_L_E_T_ = ' ' "	                        + CRLF
	cQuery += " LEFT JOIN "  + RetSQLName( 'SD1' ) + " SD1 "            + CRLF //-- ITENS DOCUMENTO DE ENTRADA
    cQuery += "     ON SD1.D1_FILIAL  = '" + FWxFilial('SD1') + "' "    + CRLF
    cQuery += "    AND SD1.D1_DOC     = SF1.F1_DOC"                     + CRLF
    cQuery += "    AND SD1.D1_SERIE   = SF1.F1_SERIE"                   + CRLF
    cQuery += "    AND SD1.D1_FORNECE = SF1.F1_FORNECE"                    + CRLF
    cQuery += "    AND SD1.D1_LOJA    = SF1.F1_LOJA"                    + CRLF
    cQuery += "    AND SD1.D1_EMISSAO = SF1.F1_EMISSAO"                 + CRLF
    cQuery += "    AND SD1.D_E_L_E_T_ = ' ' "	                        + CRLF
    cQuery += " LEFT JOIN "  + RetSQLName( 'SFT' ) + " SFT "            + CRLF //-- ITENS LIVROS FISCAIS
	cQuery += "     ON SFT.FT_FILIAL  = '" + FWxFilial('SFT') + "' "    + CRLF 
    cQuery += "    AND SFT.FT_NFISCAL = SF1.F1_DOC"                     + CRLF
    cQuery += "    AND SFT.FT_SERIE   = SF1.F1_SERIE"                   + CRLF
    cQuery += "    AND SFT.FT_CLIEFOR = SF1.F1_FORNECE"                 + CRLF
    cQuery += "    AND SFT.FT_LOJA	  = SF1.F1_LOJA"                    + CRLF
    cQuery += "    AND SFT.FT_PRODUTO = SD1.D1_COD"                     + CRLF
    cQuery += "    AND SFT.D_E_L_E_T_ = ' ' "	                        + CRLF
    cQuery += " WHERE  "	                                            + CRLF         
    cQuery += "    SF1.F1_FILIAL 		= '" + FWxFilial('SF1') + "' "  + CRLF

    If !Empty(DtoS(MV_PAR02)) //DATA ENTRADA ATE
		cQuery += " AND SF3.F3_ENTRADA BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'"   + CRLF //--DATA ENTRADA
	EndIf

    If !Empty(MV_PAR04) // NOTA FISCAL ATE
		cQuery += "	AND SF3.F3_NFISCAL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"               + CRLF //--NOTA FISCAL
    If !Empty(DtoS(MV_PAR02)) //DATA EMISSAO ATE
		cQuery += " AND SF1.F1_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'"   + CRLF //--DATA DE EMISSAO
	EndIf

    If !Empty(MV_PAR05) // NUM SERIE NF
		cQry += "	AND SF3.F3_SERIE = '" + MV_PAR05 + "'"                                              + CRLF //--SERIE
    If !Empty(MV_PAR04) //NOTA FISCAL
		cQuery += " AND SF1.F1_DOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"                   + CRLF //--NOTA FISCAL
	EndIf
	
    If !Empty(MV_PAR07) // FORNECEDOR ATE
		cQuery += "	AND SA2.A2_COD BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"                   + CRLF //--FORNECEDOR
    
    If !Empty(MV_PAR05) // NUM SERIE NF
		cQuery += "	AND SF1.F1_SERIE = '" + MV_PAR05 + "'"                                              + CRLF //--SERIE
	EndIf
	
    If !Empty(MV_PAR09) // PEDIDO ATE
		cQuery += "	AND SC6.C6_NUM BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "'"                   + CRLF //--PEDIDO

    If !Empty(MV_PAR07) //FORNECEDOR
		cQuery += " AND SF1.F1_FORNECE BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"               + CRLF //--FORNECEDOR
	EndIf

	cQuery += "	AND SF3.D_E_L_E_T_  = ' ' "   + CRLF

    cQuery += "    AND SF1.D_E_L_E_T_ 	= ' ' "                         + CRLF
    cQuery += " GROUP BY  "	                                            + CRLF 
    cQuery += "         SF1.F1_FILIAL "                                 + CRLF    
    cQuery += "         , SD1.D1_CF "                                   + CRLF  
    cQuery += "         , SA2.A2_CGC "                                  + CRLF     
	cQuery += "         , SA2.A2_INSCR "                                + CRLF  	   
    cQuery += "         , SA2.A2_COD "                                  + CRLF 
    cQuery += "         , SA2.A2_LOJA "                                 + CRLF
    cQuery += "         , SA2.A2_NOME "                                 + CRLF  
    cQuery += "         , SA2.A2_EST "                                  + CRLF  	   
    cQuery += "         , SF1.F1_DOC "                                  + CRLF 
    cQuery += "         , SF1.F1_SERIE  "                               + CRLF
    cQuery += "         , SF1.F1_EMISSAO "                              + CRLF     
    cQuery += "         , SF1.F1_CHVNFE )"                              + CRLF      
    cQuery += " SELECT "                                                + CRLF     
    cQuery += "     FILIAL, CNPJ, INS_EST, CODIGO "                 + CRLF 
    cQuery += "     , LOJA, FORNECEDOR, ESTADO "                        + CRLF 
	cQuery += "  	, NOTA_FISCAL, SERIE, CHAVE, DT_EMISSAO "                  + CRLF
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
    cQuery += "		, SF3.F3_ICMSRET 	AS VALOR_SUBST   "               + CRLF 
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
    cQuery += "    AND SF3.F3_EMISSAO = NOTA.DT_EMISSAO "               + CRLF
    cQuery += "    AND SF3.F3_CFO     = NOTA.CFOP "                     + CRLF
    cQuery += "    AND SF3.D_E_L_E_T_ = ' ' "	                        + CRLF

    // Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )
@@ -282,8 +307,8 @@ Static Function  ReportPrint(oReport)
        oReport:SetMsgPrint("Imprimindo registo " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + " ...")
        oReport:IncMeter()

        oSection1:Cell("DT_EMIS"):SetValue(StoD((cAliasTMP)->DT_EMIS))
        oSection1:Cell("DT_ENTR"):SetValue(StoD((cAliasTMP)->DT_ENTR))
        oSection1:Cell("EMISSAO"):SetValue(StoD((cAliasTMP)->DT_EMISSAO))
        oSection1:Cell("DT_LANC"):SetValue(StoD((cAliasTMP)->DT_LANC))
        //oSection1:Cell("F3_DTCANC"):SetValue(StoD((cAliasTMP)->F3_DTCANC))

        //Imprimindo a linha atual
@@ -292,7 +317,8 @@ Static Function  ReportPrint(oReport)
        If (cAliasTMP)->F3_DTCANC != ' '
            oSection2:Init()

            //oSection2:Cell("F3_DTCANC"):SetValue(StoD((cAliasTMP)->F3_DTCANC))
            oSection2:Cell("EMISSAO"):SetValue(StoD((cAliasTMP)->DT_EMISSAO))
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


