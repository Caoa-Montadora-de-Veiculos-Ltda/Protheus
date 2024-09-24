#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "Totvs.ch"

/*
=====================================================================================
Programa.:              ZFISR018
Autor....:              CAOA - Sandro Ferreira
Data.....:              09/08/2024
Descricao / Objetivo:   Relatório de Cabeçalho NF de Entrada
Doc. Origem:            
Solicitante:            Micaellen Pereira Leal
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZFISR018()

    Local aArea    := FWGetArea()
    Local aPergs   := {}
	Local dDtEmiss := Ctod(Space(8))
    Local dDtDigit := Ctod(Space(8))
    Local cNumNF   := Space(TamSX3('F1_DOC')[1]) 
    Local cSerieNF := Space(TamSX3('F1_SERIE')[1])
	Local cFornece := Space(TamSX3('F1_FORNECE')[1])
     
    //Adicionando os parametros do ParamBox
    aAdd(aPergs, {1,"Emissao De"	  ,dDtEmiss	,/*Pict*/	,/*Valid*/	            ,/*F3*/     ,/*When*/   ,50 ,.F.})  //MV_PAR01
	aAdd(aPergs, {1,"Emissao Ate"	  ,dDtEmiss	,/*Pict*/   ,MV_PAR02 > MV_PAR01    ,/*F3*/     ,/*When*/   ,50 ,.F.})  //MV_PAR02

    aAdd(aPergs, {1,"Digitacao De"    ,dDtDigit ,/*Pict*/   ,/*Valid*/              ,/*F3*/     ,/*When*/   ,50 ,.F.})  //MV_PAR03
    aAdd(aPergs, {1,"Digitacao Ate"   ,dDtDigit ,/*Pict*/   ,MV_PAR04 > MV_PAR03    ,/*F3*/     ,/*When*/   ,50 ,.F.})  //MV_PAR04

	aAdd(aPergs, {1,"Nota Fiscal De"  ,cNumNF	,/*Pict*/	,/*Valid*/	            ,"SF1"      ,/*When*/   ,50 ,.F.})  //MV_PAR05
	aAdd(aPergs, {1,"Nota Fiscal Ate" ,cNumNF	,/*Pict*/	,/*Valid*/	            ,"SF1"      ,/*When*/   ,50 ,.F.})  //MV_PAR06
    aAdd(aPergs, {1,"Serie"			  ,cSerieNF	,/*Pict*/	,/*Valid*/	            ,"_SF1SE"   ,/*When*/   ,50 ,.F.})  //MV_PAR07
    aAdd(aPergs, {1,"Fornecedor De"	  ,cFornece	,/*Pict*/	,/*Valid*/	            ,"SA2"      ,/*When*/   ,50 ,.F.})  //MV_PAR08
	aAdd(aPergs, {1,"Fornecedor Ate"  ,cFornece	,/*Pict*/	,/*Valid*/	            ,"SA2"      ,/*When*/   ,50 ,.F.})  //MV_PAR09
//  aAdd(aPergs, {1, "Tipo Relat."    ,nTipoRel ,{"1=Excel XML", "2=Excel XLSX"}    ,80         ,".T."      ,.T.    })  //MV_PAR10
     
    //Se a pergunta for confirma, cria as definicoes do relatorio
    If ParamBox(aPergs, "Informe os parâmetros para Nota Fiscal de entrada", , , , , , , , , .F., .F.)
    //  MV_PAR08 := Val(cValToChar(MV_PAR08))
        Processa({|| fGeraExcel()})
    EndIf
     
    FWRestArea(aArea)
Return
 
/*/{Protheus.doc} fGeraExcel
Criacao do arquivo Excel na funcao ZFISR018
@author Sandro Ferreira
@since 12/08/2024
@version 1.0
@type function
/*/

Static Function fGeraExcel()
    Local cQryDad  := ""
    Local oFWMsExcel
    Local oExcel
    Local cArquivo   := GetTempPath() + "ZFISR018.xml"
    Local cWorkSheet := "Notas Fiscais de Entrada"
    Local cWorkSh    := "Notas Fiscais de Entrada Canceladas"
    Local cTitulo    := "Notas Fiscais de Entrada"
    Local cTitul     := "Notas Fiscais de Entrada Canceladas"
    Local nAtual     := 0
    Local nTotal     := 0
    Local cCGC  	 := ''  
    Local cCodigo	 := ''    
    Local cLoja 	 := ''
    Local cCliFor	 := ''
    Local cInsc 	 := ''    
    Local cLogInc    := ''
    Local cLogAlt    := ''
    Local aLog       := {}
    Local cKey       := ''

    Private QRY_DAD  := GetNextAlias()

    If Select(QRY_DAD) > 0
		(QRY_DAD)->(DbCloseArea())
	EndIf
     
    //Montando consulta de dados

    cQryDad := " "                                                              + CRLF
    cQryDad += " SELECT "                                                       + CRLF
    cQryDad += "        SF1.F1_FILIAL     AS FILIAL "                           + CRLF
    cQryDad += "        , SA2.A2_CGC      AS CNPJ "                             + CRLF
    cQryDad += "        , SA2.A2_INSCR    AS INS_EST "                          + CRLF
    cQryDad += "        , SA2.A2_COD      AS CODIGO "                           + CRLF  
    cQryDad += "        , SA2.A2_LOJA     AS LOJA "                             + CRLF       
    cQryDad += "        , SA2.A2_NOME     AS FORNECEDOR "                       + CRLF
    cQryDad += "        , SA2.A2_EST      AS ESTADO "                           + CRLF
    cQryDad += "        , SF1.F1_DOC      AS NOTA_FISCAL "                      + CRLF 
    cQryDad += "        , SF1.F1_SERIE    AS SERIE "                            + CRLF
    cQryDad += "        , SF1.F1_TIPO     AS TIPO "                             + CRLF 
    cQryDad += "        , SF1.F1_FORMUL   AS FORMULARIO "                       + CRLF 
    cQryDad += "        , TO_DATE(SF1.F1_DTDIGIT, 'YYYYMMDD')  AS DT_ENTRADA "  + CRLF 
    cQryDad += "        , SF1.F1_CHVNFE   AS CHAVE "                            + CRLF
    cQryDad += "        , SF1.F1_USERLGI  AS UINCLUI" 		                    + CRLF
    cQryDad += "        , SF1.F1_USERLGA  AS UALTERA" 		                    + CRLF
    cQryDad += "        , SD1.D1_CF       AS CFOP "                             + CRLF
    cQryDad += "        , SUM(FT_VALPIS)  AS VALOR_PIS "                        + CRLF
    cQryDad += "        , SUM(FT_VALCOF)  AS VALOR_COF "                        + CRLF
	cQryDad += "	    , SF3.F3_ESPECIE  AS ESPECIE "                          + CRLF 
	cQryDad += "		, SF3.F3_CFO 	  AS CFOP "                             + CRLF 
	cQryDad += "		, TO_DATE(SF3.F3_ENTRADA, 'YYYYMMDD')  AS DT_LANC "     + CRLF
    cQryDad += "        , SF1.F1_VALMERC  AS VALOR_ITENS "                      + CRLF
	cQryDad += "		, SF3.F3_VALCONT  AS VALOR_CONTABIL "                   + CRLF 
	cQryDad += "		, SF3.F3_BASEICM  AS BASE_ICMS "                        + CRLF
	cQryDad += "		, SF3.F3_VALICM   AS VAL_ICMS "                         + CRLF 
	cQryDad += "		, SF3.F3_ISENICM  AS ICMS_ISENTO "                      + CRLF 
	cQryDad += "		, SF3.F3_OUTRICM  AS ICMS_OUTROS  "                     + CRLF
    cQryDad += "        , SF3.F3_ICMSDIF  AS ICMS_DIFAL "                       + CRLF
    cQryDad += "		, SF3.F3_BASERET  AS BASE_SUBST  "                      + CRLF 
    cQryDad += "		, SF3.F3_ICMSRET  AS VALOR_SUBST   "                    + CRLF 
    cQryDad += "		, SF3.F3_BASEIPI  AS BASE_IPI  "                        + CRLF 
    cQryDad += "		, SF3.F3_VALIPI   AS VAL_IPI  "                         + CRLF 
    cQryDad += "		, SF3.F3_ISENIPI  AS IPI_ISENTO  "                      + CRLF 
    cQryDad += "		, SF3.F3_OUTRIPI  AS IPI_OUTROS  "                      + CRLF 
    cQryDad += "		, SF3.F3_DESPESA  AS OUTRAS_DESPESAS  "                 + CRLF 
    cQryDad += "		, SF3.F3_VALOBSE  AS DESCONTO  "                        + CRLF 
    cQryDad += "		, SF3.F3_BASIMP6  AS BASE_PIS  "                        + CRLF 
    cQryDad += "		, SF3.F3_BASIMP5  AS BASE_COF  "                        + CRLF 
    cQryDad += "		, SF3.F3_BASEPS3  AS PIS_ST_ZFM  "                      + CRLF 
    cQryDad += "		, SF3.F3_VALPS3   AS VAL_PISSTZFM  "                    + CRLF     
    cQryDad += "		, SF3.F3_BASECF3  AS COF_ST_ZFM  "                      + CRLF 
    cQryDad += "		, SF3.F3_VALCF3   AS VAL_COFST_ZFM  "                   + CRLF 
    cQryDad += "		, SF3.F3_OBSERV   AS OBSERVACAO  "                      + CRLF
    cQryDad += "		, SF3.F3_DTCANC "                                       + CRLF
    cQryDad += "FROM "       + RetSQLName( 'SF1' ) + " SF1 "                    + CRLF //-- CAB. NOTA FISCAL DE ENTRADA
    cQryDad += "LEFT JOIN "  + RetSQLName( 'SA2' ) + " SA2 "                    + CRLF //-- FORNECEDORES
    cQryDad += "    ON SA2.A2_FILIAL  = '" + FWxFilial('SA2') + "' "            + CRLF 
    cQryDad += "    AND SA2.A2_COD     = SF1.F1_FORNECE"                        + CRLF 
    cQryDad += "    AND SA2.A2_LOJA    = SF1.F1_LOJA "                          + CRLF 
 // cQryDad += "    AND SA2.D_E_L_E_T_ = ' ' "	                                + CRLF
	cQryDad += "LEFT JOIN "  + RetSQLName( 'SD1' ) + " SD1 "                    + CRLF //-- ITENS DOCUMENTO DE ENTRADA
    cQryDad += "    ON SD1.D1_FILIAL  = '" + FWxFilial('SD1') + "' "            + CRLF
    cQryDad += "    AND SD1.D1_DOC     = SF1.F1_DOC"                            + CRLF
    cQryDad += "    AND SD1.D1_SERIE   = SF1.F1_SERIE"                          + CRLF
    cQryDad += "    AND SD1.D1_FORNECE = SF1.F1_FORNECE"                        + CRLF
    cQryDad += "    AND SD1.D1_LOJA    = SF1.F1_LOJA"                           + CRLF
    cQryDad += "    AND SD1.D1_EMISSAO = SF1.F1_EMISSAO"                        + CRLF
    cQryDad += "LEFT JOIN "  + RetSQLName( 'SFT' ) + " SFT "                    + CRLF //-- ITENS LIVROS FISCAIS
	cQryDad += "    ON SFT.FT_FILIAL  = '" + FWxFilial('SFT') + "' "            + CRLF 
    cQryDad += "    AND SFT.FT_NFISCAL = SF1.F1_DOC"                            + CRLF
    cQryDad += "    AND SFT.FT_SERIE   = SF1.F1_SERIE"                          + CRLF
    cQryDad += "    AND SFT.FT_CLIEFOR = SF1.F1_FORNECE"                        + CRLF
    cQryDad += "    AND SFT.FT_LOJA	  = SF1.F1_LOJA"                            + CRLF
    cQryDad += "    AND SFT.FT_PRODUTO = SD1.D1_COD"                            + CRLF
//  cQryDad += "    AND SFT.D_E_L_E_T_ = ' ' "	                                + CRLF

    cQryDad += "LEFT JOIN "  + RetSQLName( 'SF3' ) + " SF3 "                    + CRLF //-- LIVROS FISCAIS CABEÇALHO
    cQryDad += "    ON SF3.F3_FILIAL  = '" + FWxFilial('SF3') + "' "            + CRLF 
    cQryDad += "    AND SF3.F3_NFISCAL = SF1.F1_DOC"                            + CRLF
    cQryDad += "    AND SF3.F3_SERIE   = SF1.F1_SERIE "                         + CRLF
    cQryDad += "    AND SF3.F3_EMISSAO = SF1.F1_EMISSAO"                        + CRLF
    cQryDad += "    AND SF3.F3_CFO     = SD1.D1_CF  "                           + CRLF
    cQryDad += "    AND SF3.D_E_L_E_T_ = ' ' "	                                + CRLF




    cQryDad += "WHERE  "	                                            + CRLF         
    cQryDad += "    SF1.F1_FILIAL 		= '" + FWxFilial('SF1') + "' "  + CRLF
	
    If !Empty(DtoS(MV_PAR02)) //DATA EMISSAO ATE
		cQryDad += " AND (SF1.F1_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "')"    + CRLF //--DATA DE EMISSAO
		cQryDad += " OR (SF3.F3_DTCANC BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "')"      + CRLF //--DATA DE EMISSAO

	EndIf

    If !Empty(DtoS(MV_PAR04)) //DATA DIGITACAO ATE
	
    	cQryDad += " AND (SF1.F1_DTDIGIT BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + DtoS(MV_PAR04) + "')"    + CRLF //--DATA DE DIGITACAO

	EndIf

    If !Empty(MV_PAR06) //NOTA FISCAL
		cQryDad += " AND SF1.F1_DOC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'"  + CRLF //--NOTA FISCAL
	EndIf
    
    If !Empty(MV_PAR07) // NUM SERIE NF
		cQryDad += "	AND SF1.F1_SERIE = '" + MV_PAR07 + "'"  + CRLF //--SERIE
	EndIf

    If !Empty(MV_PAR09) //FORNECEDOR
		cQryDad += " AND SF1.F1_FORNECE BETWEEN '" + MV_PAR08 + "' AND '" + MV_PAR09 + "'"  + CRLF //--FORNECEDOR
	EndIf

    cQryDad += "    AND SF1.D_E_L_E_T_ 	= ' ' " + CRLF
    cQryDad += "GROUP BY "                      + CRLF 
    cQryDad += "    SF1.F1_FILIAL "             + CRLF    
    cQryDad += "    , SD1.D1_CF "               + CRLF  
    cQryDad += "    , SA2.A2_CGC "              + CRLF     
	cQryDad += "    , SA2.A2_INSCR "            + CRLF  	   
    cQryDad += "    , SA2.A2_COD "              + CRLF 
    cQryDad += "    , SA2.A2_LOJA "             + CRLF
    cQryDad += "    , SA2.A2_NOME "             + CRLF  
    cQryDad += "    , SA2.A2_EST "              + CRLF  	   
    cQryDad += "    , SF1.F1_DOC "              + CRLF 
    cQryDad += "    , SF1.F1_SERIE "            + CRLF
    cQryDad += "    , SF1.F1_TIPO "             + CRLF
    cQryDad += "    , SF1.F1_FORMUL "           + CRLF
    cQryDad += "    , SF1.F1_DTDIGIT "          + CRLF 
    cQryDad += "    , SF1.F1_CHVNFE "           + CRLF        
    cQryDad += "    , SF1.F1_USERLGI "          + CRLF
    cQryDad += "    , SF1.F1_USERLGA "          + CRLF     
    cQryDad += "    , SF3.F3_ESPECIE "          + CRLF 
	cQryDad += " 	, SF3.F3_CFO "              + CRLF 
	cQryDad += " 	, SF3.F3_ENTRADA "          + CRLF
    cQryDad += "    , SF1.F1_VALMERC "          + CRLF
	cQryDad += " 	, SF3.F3_VALCONT "          + CRLF 
	cQryDad += " 	, SF3.F3_BASEICM "          + CRLF 
	cQryDad += " 	, SF3.F3_VALICM  "          + CRLF 
	cQryDad += " 	, SF3.F3_ISENICM "          + CRLF 
	cQryDad += " 	, SF3.F3_OUTRICM "          + CRLF
    cQryDad += "    , SF3.F3_ICMSDIF "          + CRLF
	cQryDad += " 	, SF3.F3_BASERET "          + CRLF 
	cQryDad += " 	, SF3.F3_ICMSRET "          + CRLF 	  
	cQryDad += " 	, SF3.F3_BASEIPI "          + CRLF 	 
	cQryDad += " 	, SF3.F3_VALIPI  "          + CRLF 	
	cQryDad += " 	, SF3.F3_ISENIPI "          + CRLF 
	cQryDad += " 	, SF3.F3_OUTRIPI "          + CRLF 	
	cQryDad += " 	, SF3.F3_DESPESA "          + CRLF 
	cQryDad += " 	, SF3.F3_VALOBSE "          + CRLF 	 
	cQryDad += " 	, SF3.F3_BASIMP6 "          + CRLF 	
	cQryDad += " 	, SF3.F3_BASIMP5 "          + CRLF 
	cQryDad += " 	, SF3.F3_BASEPS3 "          + CRLF 	
	cQryDad += " 	, SF3.F3_VALPS3  "          + CRLF 	 
	cQryDad += " 	, SF3.F3_BASECF3 "          + CRLF 	
	cQryDad += " 	, SF3.F3_VALCF3  "          + CRLF    
	cQryDad += " 	, SF3.F3_OBSERV  "          + CRLF 	
	cQryDad += " 	, SF3.F3_DTCANC  "          + CRLF  

    //Executando consulta e setando o total da regua
    //PlsQuery(cQryDad, "QRY_DAD")
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryDad), QRY_DAD, .T., .T. )
    DbSelectArea(QRY_DAD)
     
    //Cria a planilha do excel
   // If MV_PAR08 == 1
        oFWMsExcel := FWMSExcel():New()
    //ElseIf MV_PAR06 == 2
    //    oFWMsExcel := FWMSExcelXLSX():New()
    //EndIf
     
    //Criando a aba da planilha
    oFWMsExcel:AddworkSheet(cWorkSheet)
     
    //Criando a Tabela e as colunas
    oFWMsExcel:AddTable(cWorkSheet, cTitulo)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "CNPJ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "INS_EST", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "CODIGO", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "LOJA", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "FORNECEDOR", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "ESTADO", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "NOTA_FISCAL", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "SERIE", 1, 1, .F.)
    oFWMSExcel:AddColumn(cWorkSheet, cTitulo, "TIPO", 1, 1, .F.)
    oFWMSExcel:AddColumn(cWorksheet, cTitulo, "FORMULARIO", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "ESPECIE", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "CFOP", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "DT_ENTRADA", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "DATA LANCAMENTO", 1, 1, .F.)
    oFWMSExcel:AddColumn(cWorkSheet, cTitulo, "VALOR_ITENS", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "VALOR_CONTABIL", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "BASE_ICMS", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "VAL_ICMS", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "ICMS_ISENTO", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "ICMS_OUTROS", 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "ICMS_DIFAL", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "BASE_SUBST ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, " VALOR_SUBST", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "BASE_IPI ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "VAL_IPI ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "IPI_ISENTO ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "IPI_OUTROS ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, " OUTRAS_DESPESAS", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, " DESCONTO", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "BASE_PIS ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "VALOR_PIS ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "BASE_COF ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "VALOR_COF ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "CHAVE ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "PIS_ST_ZFM ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "VAL_PISSTZFM ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, " COF_ST_ZFM", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "VAL_COFST_ZFM ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, " OBSERVACAO", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "USERINC ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSheet, cTitulo, "USERALT ", 1, 1, .F.) 
     
    //Definindo o tamanho da regua
    Count To nTotal
    ProcRegua(nTotal)
    (QRY_DAD)->(DbGoTop())
     
    SA1->( DbSetOrder(1) ) // A1_FILIAL+A1_COD+A1_LOJA
    
    //Percorrendo os dados da query
    While !(QRY_DAD)->(EoF())
         
        //Incrementando a regua
   
        IncProc("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        IF Empty((QRY_DAD)->F3_DTCANC) 
         nAtual++

         	// TRATAMENTO PARA BUSCAR O LOG DO USUÁRIO.
            cKey := (QRY_DAD)->FILIAL + (QRY_DAD)->NOTA_FISCAL + (QRY_DAD)->SERIE + (QRY_DAD)->CODIGO + (QRY_DAD)->LOJA + (QRY_DAD)->TIPO
            aLog := ConvUsr( cKey )
            cLogInc := aLog[1]
            cLogAlt := aLog[2]

            If (QRY_DAD)->TIPO $ "B|D" // Benefeciamento ou devolução
				If SA1->(DbSeek( xFilial("SA1") + (QRY_DAD)->CODIGO + (QRY_DAD)->LOJA ))
					cCliFor	:= SA1->A1_NOME
					cCGC	:= SA1->A1_CGC 
                    cCodigo := SA1->A1_COD  
                    cLoja   := SA1->A1_LOJA                                      
				    cInsc   := SA1->A1_INSCR
                EndIf
            Else
 					cCliFor	:= (QRY_DAD)->FORNECEDOR
                    cCGC	:= (QRY_DAD)->CNPJ
                    cCodigo := (QRY_DAD)->CODIGO  
                    cLoja   := (QRY_DAD)->LOJA
				    cInsc   := (QRY_DAD)->INS_EST                    
            EndIf 

         //Adicionando uma nova linha
         oFWMsExcel:AddRow(cWorkSheet, cTitulo, {;
                     cCGC     ,;
                     cInsc    ,;
                     cCodigo  ,;
                     cLoja    ,;
                     cCliFor  ,;
                     (QRY_DAD)->ESTADO  ,;
                     (QRY_DAD)->NOTA_FISCAL  ,;
                     (QRY_DAD)->SERIE  ,;
                     (QRY_DAD)->TIPO   ,;
                     (QRY_DAD)->FORMULARIO   ,;
                     (QRY_DAD)->ESPECIE  ,;
                     (QRY_DAD)->CFOP   ,;
                     (QRY_DAD)->DT_ENTRADA  ,;
                     (QRY_DAD)->DT_LANC  ,;
                     (QRY_DAD)->VALOR_ITENS  ,;
                     (QRY_DAD)->VALOR_CONTABIL  ,;
                     (QRY_DAD)->BASE_ICMS  ,;
                     (QRY_DAD)->VAL_ICMS  ,;					
                     (QRY_DAD)->ICMS_ISENTO  ,;
                     (QRY_DAD)->ICMS_OUTROS  ,;
                     (QRY_DAD)->ICMS_DIFAL   ,;
                     (QRY_DAD)->BASE_SUBST  ,;
                     (QRY_DAD)->VALOR_SUBST  ,;
                     (QRY_DAD)->BASE_IPI  ,;
                     (QRY_DAD)->VAL_IPI  ,;
                     (QRY_DAD)->IPI_ISENTO  ,;					
                     (QRY_DAD)->IPI_OUTROS  ,;
                     (QRY_DAD)->OUTRAS_DESPESAS  ,;
                     (QRY_DAD)->DESCONTO  ,;
                     (QRY_DAD)->BASE_PIS  ,;					
                     (QRY_DAD)->VALOR_PIS  ,;
                     (QRY_DAD)->BASE_COF  ,;
                     (QRY_DAD)->VALOR_COF  ,;
                     (QRY_DAD)->CHAVE  ,;					
                     (QRY_DAD)->PIS_ST_ZFM  ,;
                     (QRY_DAD)->VAL_PISSTZFM  ,;
                     (QRY_DAD)->COF_ST_ZFM  ,;
                     (QRY_DAD)->VAL_COFST_ZFM  ,;					
                     (QRY_DAD)->OBSERVACAO  ,;
                     cLogInc  ,;
                     cLogAlt   })
        ENDIF
        (QRY_DAD)->(DbSkip())
    EndDo
    //nf canceladas
     //Criando a aba da planilha
    oFWMsExcel:AddworkSheet(cWorkSh)
     
    //Criando a Tabela e as colunas
   oFWMsExcel:AddTable(cWorkSh, cTitul)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "CNPJ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "INS_EST", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "CODIGO", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "LOJA", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "FORNECEDOR", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "ESTADO", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "NOTA_FISCAL", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "SERIE", 1, 1, .F.)
    oFWMSExcel:AddColumn(cWorkSh, cTitul, "TIPO", 1, 1, .F.)
    oFWMSExcel:AddColumn(cWorksh, cTitul, "FORMULARIO", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "ESPECIE", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "CFOP", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "DT_ENTRADA", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "DATA CANCELAMENTO", 1, 1, .F.)
    oFWMSExcel:AddColumn(cWorkSh, cTitul, "VALOR_ITENS", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "VALOR_CONTABIL", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "BASE_ICMS", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "VAL_ICMS", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "ICMS_ISENTO", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "ICMS_OUTROS", 1, 1, .F.)
    oFWMsExcel:AddColumn(cWorkSh, cTitul, "ICMS_DIFAL", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "BASE_SUBST ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, " VALOR_SUBST", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "BASE_IPI ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "VAL_IPI ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "IPI_ISENTO ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "IPI_OUTROS ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, " OUTRAS_DESPESAS", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, " DESCONTO", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "BASE_PIS ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "VALOR_PIS ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "BASE_COF ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "VALOR_COF ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "CHAVE ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "PIS_ST_ZFM ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "VAL_PISSTZFM ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, " COF_ST_ZFM", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "VAL_COFST_ZFM ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, " OBSERVACAO", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "USERINC ", 1, 1, .F.)
	oFWMsExcel:AddColumn(cWorkSh, cTitul, "USERALT ", 1, 1, .F.) 
     
    //Definindo o tamanho da regua
    //Count To nTotal
    //ProcRegua(nTotal)
    (QRY_DAD)->(DbGoTop())
     
    //Percorrendo os dados da query
    While !(QRY_DAD)->(EoF())
         
        //Incrementando a regua
             IncProc("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
        IF !Empty((QRY_DAD)->F3_DTCANC) 
         nAtual++

         	// TRATAMENTO PARA BUSCAR O LOG DO USUÁRIO.
            cKey := (QRY_DAD)->FILIAL + (QRY_DAD)->NOTA_FISCAL + (QRY_DAD)->SERIE + (QRY_DAD)->CODIGO + (QRY_DAD)->LOJA + (QRY_DAD)->TIPO
            aLog := ConvUsr( cKey )
            cLogInc := aLog[1]
            cLogAlt := aLog[2]

        //Adicionando uma nova linha
       oFWMsExcel:AddRow(cWorkSh, cTitul, {;
                     (QRY_DAD)->CNPJ  ,;
                     (QRY_DAD)->INS_EST  ,;
                     (QRY_DAD)->CODIGO  ,;
                     (QRY_DAD)->LOJA  ,;
                     (QRY_DAD)->FORNECEDOR  ,;
                     (QRY_DAD)->ESTADO  ,;
                     (QRY_DAD)->NOTA_FISCAL  ,;
                     (QRY_DAD)->SERIE  ,;
                     (QRY_DAD)->TIPO ,;
                     (QRY_DAD)->FORMULARIO   ,;
                     (QRY_DAD)->ESPECIE  ,;
                     (QRY_DAD)->CFOP  ,;
                     (QRY_DAD)->DT_ENTRADA  ,;
                     (QRY_DAD)->DT_LANC  ,;
                     (QRY_DAD)->VALOR_ITENS  ,;
                     (QRY_DAD)->VALOR_CONTABIL  ,;
                     (QRY_DAD)->BASE_ICMS  ,;
                     (QRY_DAD)->VAL_ICMS  ,;					
                     (QRY_DAD)->ICMS_ISENTO  ,;
                     (QRY_DAD)->ICMS_OUTROS  ,;
                     (QRY_DAD)->ICMS_DIFAL   ,;
                     (QRY_DAD)->BASE_SUBST  ,;
                     (QRY_DAD)->VALOR_SUBST  ,;
                     (QRY_DAD)->BASE_IPI  ,;
                     (QRY_DAD)->VAL_IPI  ,;
                     (QRY_DAD)->IPI_ISENTO  ,;					
                     (QRY_DAD)->IPI_OUTROS  ,;
                     (QRY_DAD)->OUTRAS_DESPESAS  ,;
                     (QRY_DAD)->DESCONTO  ,;
                     (QRY_DAD)->BASE_PIS  ,;					
                     (QRY_DAD)->VALOR_PIS  ,;
                     (QRY_DAD)->BASE_COF  ,;
                     (QRY_DAD)->VALOR_COF  ,;
                     (QRY_DAD)->CHAVE  ,;					
                     (QRY_DAD)->PIS_ST_ZFM  ,;
                     (QRY_DAD)->VAL_PISSTZFM  ,;
                     (QRY_DAD)->COF_ST_ZFM  ,;
                     (QRY_DAD)->VAL_COFST_ZFM  ,;					
                     (QRY_DAD)->OBSERVACAO  ,;
                     cLogInc  ,;
                     cLogAlt   })
        ENDIF
        (QRY_DAD)->(DbSkip())
    EndDo
   
    (QRY_DAD)->(DbCloseArea())




    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
     
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cArquivo)
    oExcel:SetVisible(.T.)
    oExcel:Destroy()
     
Return

/*/{Protheus.doc} ConvUsr
    Função para conversão dos campos F1_USERLGI e F1_USERLGA
    @type  Function
    @author Victor G. Matos
    @since 05/09/2024
    @version 1.0
    @param cUser, Caractere, Usuário
    @param cTipo, Caractere, Tipo 'I' (inclusão), ou 'A' (Alteração)
    @return cRet, Caractere, Nome do usuário registrado
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function ConvUsr( cKey )
    
Local aRet := {}

    DbSelectArea('SF1')
    SF1->( DbSetOrder(1) ) // F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO

        If SF1->(dbSeek( cKey ))
            
            aAdd(aRet, FWLeUserlg( "F1_USERLGI" ) )
            aAdd(aRet, FWLeUserlg( "F1_USERLGA" ) )
        
        Else

            aRet := { '' , '' }

        EndIf
    
    SF1->(DbCloseArea())

Return aRet
