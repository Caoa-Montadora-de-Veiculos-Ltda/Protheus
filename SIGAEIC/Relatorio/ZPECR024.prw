#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"
/*
=====================================================================================
Programa.:              ZEICR003
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              21/08/03
Descricao / Objetivo:   Relatorio de detalhamento de invoice
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZEICR003()
    
	Local	aArea 		:= FwGetArea()
	Local	oReport
	Local	aPergs		:= {}
	Local	cInvoice	:= Space(TamSX3('W9_INVOICE')[1]) //o que � [1] ?
	Local	dDtInvDe	:= Ctod(Space(8)) 
	Local	dDtInvAte	:= Ctod(Space(8)) 
	Local	nNumNF		:= Space(TamSX3('F1_DOC')[1]) //Consulta padr�o para NFs SD1
	Local	nSerieNF	:= Space(TamSX3('F1_SERIE')[1]) //Consulta padr�o para Serie - SX5 - X5_TABELA = '01'
	Local	dDtEmissDe	:= Ctod(Space(8)) //Isso precisa ser uma data
	Local	dDtEmissAte	:= Ctod(Space(8))    //Ajustar isso
	Local	cProduto	:= Space(TamSX3('W8_COD_I')[1]) //o que � [1] ?
	Local	cContainer	:= Space(TamSX3('ZM_CONT')[1]) //o que � [1] ?
	local   aCanal   	:= {"1 - Todos","2 - Vermelho","3 - Amarelo","4 - Verde","5 - Cinza"}
	Private cTabela 	:= GetNextAlias()

 	aAdd(aPergs, {1,"Invoice"				,cInvoice	,/*Pict*/	,".T."		,"SW9"		,".T."	 ,80,.F.}) 	//MV_PAR01
	aAdd(aPergs, {1,"Dt invoice de"			,dDtInvDe	,/*Pict*/	,/*Valid*/	,/*F3*/		,/*When*/,50,.F.})  //MV_PAR02
	aAdd(aPergs, {1,"Dt invoice ate"		,dDtInvAte	,/*Pict*/	,/*Valid*/	,/*F3*/		,/*When*/,50,.F.})  //MV_PAR03
	aAdd(aPergs, {1,"Numero NF"				,nNumNF		,/*Pict*/	,".T."		,"SF1"		,".T."	 ,80,.F.})  //MV_PAR04
	aAdd(aPergs, {1,"Serie"					,nSerieNF	,/*Pict*/	,".T."		,"_SF1SE"	,".T."	 ,80,.F.})  //MV_PAR05
	aAdd(aPergs, {1,"Dt emissao de"			,dDtEmissDe	,/*Pict*/	,/*Valid*/	,/*F3*/		,/*When*/,50,.F.})  //MV_PAR06
	aAdd(aPergs, {1,"Dt emissao ate"		,dDtEmissAte,/*Pict*/	,MV_PAR07 > MV_PAR06	,/*F3*/	,/*When*/,50,.F.})  //MV_PAR07
	aAdd(aPergs, {1,"Produto"				,cProduto	,/*Pict*/	,".T."		,"SB1"		,".T."	 ,80,.F.})  //MV_PAR08
	aAdd(aPergs, {1,"Container"				,cContainer	,/*Pict*/	,".T."		,"_SZM"		,".T."	 ,80,.F.}) 	//MV_PAR09
	aAdd(aPergs ,{9,"Status invoice"		,200/*Larg*/,40 /*Alt */,.T./*Font Verdana*/}) 						//MV_PAR10
	aAdd(aPergs ,{5,"Proximo embarque"		,.F./*Ini*/	,90 /*Size*/,/*Valid*/	,.F.}) 							//MV_PAR11
	aAdd(aPergs ,{5,"Material em transito"	,.F./*Ini*/	,90 /*Size*/,/*Valid*/	,.F.}) 							//MV_PAR12
	aAdd(aPergs ,{5,"Em rota de entrega"	,.F./*Ini*/	,90 /*Size*/,/*Valid*/	,.F.}) 							//MV_PAR13
	aAdd(aPergs ,{2,"Canal:",01,aCanal,50,"",.T.})																//MV_PAR14
	
	If ParamBox(aPergs, "Informe os par�metros", , , , , , , , , .F., .F.)
   
		oReport := fReportDef()
		oReport:PrintDialog()
	EndIf

	FWRestArea(aArea)
Return

/*
=====================================================================================
Programa.:              fReportDef
Autor....:              CAOA - Nicolas C Lima Santos
Data.....:              21/08/23
Descricao / Objetivo:   Gera rlatorio
Doc. Origem:            
Solicitante:           
Uso......:              ZEICR003
Obs......:
=====================================================================================
*/
Static Function fReportDef() //Defini��es do relat�rio

	Local oReport
	Local oSection	:= Nil
    
	oReport:= TReport():New("ZEICR003",;				// --Nome da impress�o
                            "Status Invoice",;  // --T�tulo da tela de par�metros
                            ,;      		// --Grupo de perguntas na SX1
                            {|oReport|  ReportPrint(oReport),};
                            ) // --Descri��o do relat�rio
	
	oReport:SetLandScape(.T.)	       //--Orienta��o do relat�rio como paisagem.
	oReport:ShowParamPage()			
	Report:HideParamPage(.T.)    	//--Desabilita a impressao da pagina de parametros.
    oReport:HideHeader()        	//--Define que n�o ser� impresso o cabe�alho padr�o da p�gina
    oReport:HideFooter()        	//--Define que n�o ser� impresso o rodap� padr�o da p�gina
    oReport:SetDevice(4)        	//--Define o tipo de impress�o selecionado. Op��es: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    //oReport:SetPreview(.T.)   	//--Define se ser� apresentada a visualiza��o do relat�rio antes da impress�o f�sica
    oReport:SetEnvironment(2)   	//--Define o ambiente para impress�o 	Ambiente: 1-Server e 2-Client
	oReport:oPage:SetPaperSize(9)	//--Define impress�o no papel A4
	oReport:SetLineHeight(50) 		//--Espa�amento entre linhas
	oReport:nFontBody := 12			//--Tamanho da fonte
	//oReport:SetEdit(.T.) 
	//Pergunte(oReport:GetParam(),.F.) 		//--Adicionar as perguntas na SX1

	oSection := TRSection():New(oReport,; 	//--Criando a se��o de dados
		OEMToAnsi("Detalhamento de Invoices"),;
		{cTabela}) 
	oReport:SetTotalInLine(.F.) 			//--Desabilita o total de linhas
	//TRCell():New(oSection2,"CR_DATALIB"	,"SCR"	,'Data Aprov SC'	,/*Picture*/,TamSx3("CR_DATALIB")[1] 	,/*lPixel*/,/* {|| }*/)
	//--Colunas do relat�rio
	TRCell():New( oSection  ,"W9_FILIAL"       	,cTabela ,"Filial"			,/*cPicture*/,TamSx3("W9_FILIAL")[1] 	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection  ,"W9_INVOICE"       ,cTabela ,"Invoice"			,/*cPicture*/,TamSx3("W9_INVOICE")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"DT_EMISSAO"     	,cTabela ,"Dt Emiss Inv"	,/*cPicture*/,TamSx3("W9_DT_EMIS")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"W6_IDENTVE"      	,cTabela ,"Navio/Aviao"		,/*cPicture*/,TamSx3("W6_IDENTVE")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"W6_VIA_TRA"      	,cTabela ,"Modal"			,/*cPicture*/,TamSx3("W6_VIA_TRA")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"CANAL"      		,cTabela ,"Canal"			,/*cPicture*/,TamSx3("W6_CANAL")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"W9_NOM_FOR"      	,cTabela ,"Fornecedor"		,/*cPicture*/,TamSx3("W9_NOM_FOR")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"W8_PO_NUM"      	,cTabela ,"Num PO"			,/*cPicture*/,TamSx3("W8_PO_NUM")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"W8_COD_I"      	,cTabela ,"Codigo"			,/*cPicture*/,TamSx3("W8_COD_I")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"QTDE"      		,cTabela ,"Qtde"			,/*cPicture*/,TamSx3("ZM_QTDE")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"PESO_NET"      	,cTabela ,"Peso Net"		,/*cPicture*/,TamSx3("W7_PESO")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"PESO_BRT"      	,cTabela ,"Peso Brt"		,/*cPicture*/,TamSx3("W8_PESO_BR")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"ZM_CASE"      	,cTabela ,"Case"			,/*cPicture*/,TamSx3("ZM_CASE")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"ZM_CONT"      	,cTabela ,"Container"		,/*cPicture*/,TamSx3("ZM_CONT")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"STATUS"     	 	,cTabela ,"Status"			,/*cPicture*/,30						, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"DOLAR_DIA"      	,cTabela ,"Dolar dia"		,/*cPicture*/,TamSx3("W9_TX_FOB")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"TIPO_NF"      	,cTabela ,"Tipo de NF"		,/*cPicture*/,20						, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"F1_DOC"      		,cTabela ,"Numero NF"		,/*cPicture*/,TamSx3("F1_DOC")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"F1_SERIE"      	,cTabela ,"Serie NF"		,/*cPicture*/,TamSx3("F1_SERIE")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"DT_EMIS_NF"      	,cTabela ,"Dt Emiss NF"		,/*cPicture*/,TamSx3("F1_EMISSAO")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"PRC_TOT_FOB"      ,cTabela ,"Prc Total FOB"	,/*cPicture*/,TamSx3("W8_PRECO")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"W8_FRETEIN"      	,cTabela ,"Valor frete"	 	,/*cPicture*/,TamSx3("W8_FRETEIN")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"W8_SEGURO"      	,cTabela ,"Valor seguro"	,/*cPicture*/,TamSx3("W8_SEGURO")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	
Return oReport

Static Function ReportPrint(oReport)

	Local aArea 	:= FWGetArea()
	Local cQry		:= ""
	Local oSectDad  := Nil
	Local nAtual	:= 0
	Local nTotal	:= 0

	//Pegando as secoes do relat�rio
	oSectDad := oReport:Section(1) //Primeira se��o dispon�vel

	//Montando a Query
	cQry += " 	SELECT DISTINCT" 								+ CRLF
	cQry += "		SW9.W9_FILIAL" 								+ CRLF
	cQry += "		, SW9.W9_INVOICE" 							+ CRLF
	cQry += "		, SUBSTR(SW9.W9_DT_EMIS,7,2)||'/'||SUBSTR(SW9.W9_DT_EMIS,5,2)||'/'||SUBSTR(SW9.W9_DT_EMIS,1,4) AS DT_EMISSAO " + CRLF 
	cQry += "		, SW6.W6_IDENTVE"	 						+ CRLF
	cQry += "		, SW6.W6_VIA_TRA"	 						+ CRLF
	cQry += "		, SW9.W9_NOM_FOR"   						+ CRLF
	cQry += "		, SW8.W8_PO_NUM" 							+ CRLF
	cQry += "		, SW8.W8_COD_I" 							+ CRLF
    cQry += "		, NVL(SZM.ZM_QTDE,0) AS QTDE "		 		+ CRLF
	cQry += "		, NVL(SW7.W7_PESO,0) AS PESO_NET "		 	+ CRLF
	cQry += "		, NVL(SW8.W8_PESO_BR,0) AS PESO_BRT "	 	+ CRLF
	cQry += "		, SZM.ZM_CASE " 							+ CRLF
	cQry += "		, SZM.ZM_CONT "								+ CRLF
	If (MV_PAR11 .OR. MV_PAR12 .OR. MV_PAR13)
		cQry += "	, CASE "								    + CRLF
		If MV_PAR11 = .T.
			cQry += " WHEN SW6.W6_DT_EMB   = ' '  							THEN 'PROXIMO EMBARQUE' " 		+ CRLF
		EndIf
		If MV_PAR12 = .T.
			cQry += " WHEN SW6.W6_DT_EMB  != ' ' AND SW6.W6_CHEG = ' '  THEN 'MATERIAL EM TRANSITO' " 	+ CRLF
		EndIf
		If MV_PAR13 = .T.
			cQry += " WHEN SW6.W6_DT_DESE != ' ' "														+ CRLF
			cQry += "	AND SD1.D1_TESACLA != ' ' " 													+ CRLF
			cQry += "	AND ((SD1.D1_XCONHEC != ' ') OR (SD1.D1_CONHEC != ' ')) " 						+ CRLF
			cQry += "	AND SF4.F4_ESTOQUE = 'S'    					THEN 'EM ROTA DE ENTREGA' " 	+ CRLF
		EndIf
		cQry += " END AS STATUS "									+ CRLF		 
	EndIf
	cQry += "		, CASE	"										+ CRLF
	cQry += "			WHEN SW6.W6_CANAL = '1' THEN 'VERMELHO' " 	+ CRLF
	cQry += "			WHEN SW6.W6_CANAL = '2' THEN 'AMARELO' " 	+ CRLF
	cQry += "			WHEN SW6.W6_CANAL = '3' THEN 'VERDE' " 		+ CRLF
	cQry += "			WHEN SW6.W6_CANAL = '4' THEN 'CINZA' " 		+ CRLF
	cQry += "		END 					AS CANAL "				+ CRLF		
	cQry += "		, SW6.W6_DI_NUM " 								+ CRLF			
	cQry += "		, SW6.W6_DTREG_D " 								+ CRLF		
	cQry += "		, NVL(SW9.W9_TX_FOB,0)	AS DOLAR_DIA "			+ CRLF
	cQry += "		, CASE	"										+ CRLF
	cQry += "			WHEN SF1.F1_HAWB != ' ' THEN 'NF MAE' " 	+ CRLF
	cQry += "			WHEN SF1.F1_HAWB =' ' 	THEN 'NF FILHA' " 	+ CRLF
	cQry += "		END 					AS TIPO_NF "			+ CRLF					
	cQry += "		, SF1.F1_DOC "									+ CRLF	
	cQry += "		, SF1.F1_SERIE " 								+ CRLF
	cQry += "		, SUBSTR(SF1.F1_EMISSAO,7,2)||'/'||SUBSTR(SF1.F1_EMISSAO,5,2)||'/'||SUBSTR(SF1.F1_EMISSAO,1,4) AS DT_EMIS_NF " + CRLF
	cQry += "		, NVL((SW8.W8_QTDE * SW8.W8_PRECO),0) AS PRC_TOT_FOB "  		+ CRLF
	cQry += "		, SW8.W8_FRETEIN "  											+ CRLF		
	cQry += "		, SW8.W8_SEGURO "  												+ CRLF
	cQry += "		, (SELECT MAX(SD1TMP.D1_DOC) FROM ABDHDU_PROT.SD1020 SD1TMP"	+ CRLF
	cQry += "			WHERE SD1TMP.D1_FILIAL 	= '" + FWxFilial("SD1TMP") + "'" 	+ CRLF
	cQry += "			AND SD1TMP.D1_CONHEC   	= SW8.W8_HAWB " 					+ CRLF
	cQry += "			AND SD1TMP.D1_FORNECE  	= SF1.F1_FORNECE " 					+ CRLF
	cQry += "			AND SD1TMP.D1_LOJA 		= SF1.F1_LOJA " 					+ CRLF
	cQry += "			AND SD1TMP.D1_COD 		= SW8.W8_COD_I " 					+ CRLF 
	cQry += "			AND SD1TMP.D_E_L_E_T_ 	= ' ' " 							+ CRLF
	cQry += "		) AS DOC_MAE " 													+ CRLF
	cQry += "	FROM "																+ CRLF
	cQry +=	" 	" + RetSqlName("SW9") + " SW9"   									+ CRLF
	cQry += "	LEFT JOIN "															+ CRLF
	cQry += "	" + RetSqlName("SW8") + " SW8"										+ CRLF
	cQry += "	 	ON SW8.W8_FILIAL 	= '" + FWxFilial("SW9") + "'"				+ CRLF
	cQry += "		AND SW8.W8_HAWB    	= SW9.W9_HAWB "								+ CRLF
	cQry += "		AND SW8.W8_INVOICE 	= SW9.W9_INVOICE "							+ CRLF
	cQry += "		AND SW8.D_E_L_E_T_ 	= ' ' "										+ CRLF
	cQry += "	LEFT JOIN "															+ CRLF
	cQry += "	" + RetSqlName("SF1") + " SF1"										+ CRLF
	cQry += "	 	ON SF1.F1_FILIAL 	= '" + FWxFilial("SW9") + "'"				+ CRLF
	cQry += "		AND ((SF1.F1_HAWB 	= SW9.W9_HAWB) "							+ CRLF
	cQry += "		 OR (SF1.F1_XHAWB 	= SW9.W9_HAWB)) "							+ CRLF
	cQry += "		AND SF1.D_E_L_E_T_ 	= ' ' "										+ CRLF
	cQry += "	LEFT JOIN "															+ CRLF
	cQry += "	" + RetSqlName("SD1") + " SD1"										+ CRLF
	cQry += "	 	ON SD1.D1_FILIAL 	= '" + FWxFilial("SW8") + "'"				+ CRLF
	cQry += "		AND ((SD1.D1_CONHEC = SW8.W8_HAWB) "							+ CRLF
	cQry += "		 OR (SD1.D1_XCONHEC = SW8.W8_HAWB)) "							+ CRLF
	cQry += "		AND SD1.D1_FORNECE 	= SW8.W8_FORN "								+ CRLF
	cQry += "	    AND SD1.D1_LOJA 	= SW8.W8_FORLOJ "							+ CRLF
	cQry += "	    AND SD1.D1_COD 		= SW8.W8_COD_I "							+ CRLF
	cQry += "	    AND SD1.D1_DOC 		= SF1.F1_DOC "								+ CRLF
	cQry += "	    AND SD1.D1_SERIE 	= SF1.F1_SERIE "							+ CRLF
	cQry += "		AND SD1.D_E_L_E_T_ 	= ' '"										+ CRLF
	cQry += "	LEFT JOIN "															+ CRLF
	cQry += "	" + RetSqlName("SW6") + " SW6"										+ CRLF
	cQry += "	 	ON SW6.W6_FILIAL 	= '" + FWxFilial("SW9") + "'"				+ CRLF
	cQry += " 		AND SW6.W6_HAWB 	= SW9.W9_HAWB " 							+ CRLF
	cQry += "		AND SW6.D_E_L_E_T_ 	= ' '"										+ CRLF
	cQry += "	LEFT JOIN "															+ CRLF
	cQry += "	" + RetSqlName("SW7") + " SW7"										+ CRLF
	cQry += "	 	ON SW7.W7_FILIAL 	= '" + FWxFilial("SW8") + "'"				+ CRLF
	cQry += " 		AND SW7.W7_HAWB 	= SW8.W8_HAWB " 							+ CRLF
	cQry += "		AND SW7.W7_COD_I 	= SW8.W8_COD_I "							+ CRLF
	cQry += "		AND SW7.W7_PO_NUM 	= SW8.W8_PO_NUM "							+ CRLF
	cQry += "		AND SW7.W7_INVOICE 	= SW8.W8_INVOICE " 							+ CRLF
	cQry += "		AND SW7.W7_REG 		= 				" 							+ CRLF
	cQry += "				(SELECT MIN(SW7.W7_REG) " 									+ CRLF
	cQry += "					FROM "  											+ CRLF
	cQry += "    "				+ RetSqlName("SW7") + " SW7"			 			+ CRLF
	cQry += "			        WHERE SW7.W7_FILIAL = '" + FWxFilial("SW7") + "'"	+ CRLF
	cQry += "			        AND SW7.W7_HAWB 	= SW7.W7_HAWB "				 	+ CRLF
	cQry += "			        AND SW7.W7_COD_I 	= SW7.W7_COD_I "			 	+ CRLF
	cQry += "			        AND SW7.W7_PO_NUM 	= SW7.W7_PO_NUM "			 	+ CRLF
	cQry += "			        AND SW7.W7_INVOICE 	= SW7.W7_INVOICE "	 			+ CRLF
	cQry += "			        AND D_E_L_E_T_ 		= ' ' "					 		+ CRLF
	cQry += "			     ) "										 			+ CRLF
	cQry += "		AND SW7.D_E_L_E_T_ 	= ' '"										+ CRLF
	cQry += "	LEFT JOIN "															+ CRLF
	cQry += "	" + RetSqlName("SF4") + " SF4"										+ CRLF
	cQry += "	 	ON SF4.F4_FILIAL 	= '" + FWxFilial("SF4") + "'"				+ CRLF
	cQry += " 		AND SF4.F4_CODIGO 	= SD1.D1_TES " 								+ CRLF
	cQry += "		AND SF4.D_E_L_E_T_ 	= ' '"										+ CRLF
	cQry += "	LEFT JOIN "															+ CRLF
	cQry += "	" + RetSqlName("SZM") + " SZM"										+ CRLF
	cQry += "	 	ON SZM.ZM_FILIAL 	= '" + FWxFilial("SW8") + "'"				+ CRLF
	cQry += "		AND SZM.ZM_INVOICE 	= SW8.W8_INVOICE "							+ CRLF
	cQry += "		AND SZM.ZM_PROD    	= SW8.W8_COD_I "							+ CRLF
	cQry += "		AND SZM.ZM_PO_NUM  	= SW8.W8_PO_NUM "							+ CRLF
	cQry += "		AND SZM.ZM_POSICAO  = SW8.W8_POSICAO "							+ CRLF
	cQry += "	    AND SZM.ZM_CASE     = SD1.D1_XCASE "							+ CRLF
	cQry += "	    AND SZM.ZM_CONT     = SD1.D1_XCONT "							+ CRLF
	cQry += "	    AND SZM.ZM_QTDE     = SD1.D1_QUANT "							+ CRLF
	cQry += "		AND SZM.D_E_L_E_T_ 	= ' '"										+ CRLF
	cQry += "	WHERE "																+ CRLF
	cQry += "		SW9.W9_FILIAL 		= '" + FWxFilial("SW9") + "'"				+ CRLF
	cQry += "		AND SF1.F1_DOC 		= D1_DOC "									+ CRLF
	cQry += "		AND SF1.F1_DOC 		!= ' ' "									+ CRLF
	cQry += "		AND SF1.F1_SERIE	= D1_SERIE "								+ CRLF
	cQry += "		AND SF4.F4_ESTOQUE 	= 'S' "										+ CRLF
	
	If !Empty(MV_PAR01) // NUM INVOICE
		cQry += "	AND SW9.W9_INVOICE 	= '" + MV_PAR01 + "'" + CRLF
	EndIf
	
	If !Empty(DtoS(MV_PAR03)) //DT INVOICE ATE
		cQry += " 	AND SW9.W9_DT_EMIS BETWEEN '" 	+ DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "'" + CRLF
	EndIf
	
	If !Empty(MV_PAR04) //NUM NF
		cQry += "	AND SF1.F1_DOC 		= '" + MV_PAR04 + "'" + CRLF
	EndIf
	
	If !Empty(MV_PAR05) //SERIE NF
		cQry += "	AND SF1.F1_SERIE 	= '" + MV_PAR05 + "'" + CRLF
	EndIf
	
	If !Empty(DtoS(MV_PAR07)) //DT EMISSAO NF ATE
		cQry += " 	AND SF1.F1_EMISSAO BETWEEN '" 	+ DtoS(MV_PAR06) + "' AND '" + DtoS(MV_PAR07) + "'" + CRLF
	EndIf
	
	If !Empty(MV_PAR08) //COD PRODUTO
		cQry += "	AND SD1.D1_COD 		= '" + MV_PAR08 + "'" 	+ CRLF
	EndIf
	
	If !Empty(MV_PAR09) //COD CONTAINER
		cQry += "	AND SZM.ZM_CONT 	= '" + MV_PAR09 + "'" 	+ CRLF
	EndIf
	
	Do case //COD CANAL
		case MV_PAR14 = 2 
			cQry += "	AND SW6.W6_CANAL 		= '1'" 			+ CRLF //Vermelho
       	case MV_PAR14 = 3 
           cQry += "	AND SW6.W6_CANAL 		= '2'" 			+ CRLF //Verde
       	case MV_PAR14 = 4 
           cQry += "	AND SW6.W6_CANAL 		= '3'" 			+ CRLF //Amarelo
		case MV_PAR14 = 5 
           cQry += "	AND SW6.W6_CANAL 		= '4'" 			+ CRLF //Cinza
 	EndCase

	cQry += "		AND SW9.D_E_L_E_T_ 	= ' '"					+ CRLF

	//Executando a conulta e setando o total da r�gua.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTabela, .T., .T. )

	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init() 
	
	DbSelectArea(cTabela)
		(cTabela)->(DbGotop())
		While (cTabela)->(!EoF())
			
			//Incrementando a regua
			nAtual++

			oReport:SetMsgPrint("Imprimindo registo " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + " ...")
			oReport:IncMeter()

			//Imprimindo a linha atual
			
			oSectDad:PrintLine()

			(cTabela)->(DbSkip())
		EndDo
	oSectDad:Finish()
	
	(cTabela)->(DbCloseArea())

	FwRestArea(aArea)
Return


