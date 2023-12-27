#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

#define CRLF chr(13) + chr(10)  
/*
=====================================================================================
Programa.:              ZFISR016
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              18/12/23
Descricao / Objetivo:   Relatório de Notas Fiscais de ENTRADA com chave
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZFISR016()
    
	Local	aArea 		:= FwGetArea()
	Local	oReport
	Local	aPergs		:= {}
	Local	nNumNF		:= Space(TamSX3('F1_DOC')[1]) 
	Local	nSerieNF	:= Space(TamSX3('F1_SERIE')[1])
	Local	dDtEmiss	:= Ctod(Space(8)) //Data de emissao de NF
	Local	cCodSAP		:= Space(TamSX3('F1_XCODSAP')[1])
	Local 	cFornecedor := Space(TamSX3('F1_FORNECE')[1])
	Local 	cLoja 		:= Space(TamSX3('F1_LOJA')[1])
	local   aTipoNF   	:= {"Todas"	,"N - Normal","D - Devolução","B - Beneficiamento","I = Compl. ICMS", "P = Compl. ICMS", "C = Compl. Preço"}

	Private cTabela 	:= GetNextAlias()

	aAdd(aPergs, {1,"Dt emissao de"			,dDtEmiss	,/*Pict*/	,/*Valid*/	,/*F3*/		,/*When*/,50,.F.})  //MV_PAR01
	aAdd(aPergs, {1,"Dt emissao ate"		,dDtEmiss	,/*Pict*/,MV_PAR02 > MV_PAR01,/*F3*/,/*When*/,50,.F.})  //MV_PAR02
	aAdd(aPergs, {1,"Numero NF"				,nNumNF		,/*Pict*/	,/*Valid*/	,"SF1"		,/*When*/,50,.F.})  //MV_PAR03
	aAdd(aPergs, {1,"Serie NF"				,nSerieNF	,/*Pict*/	,/*Valid*/	,"_SF1SE"	,/*When*/,50,.F.})  //MV_PAR04
	aAdd(aPergs, {1,"Código SAP"			,cCodSAP	,/*Pict*/	,/*Valid*/	,"_F1SAP"	,/*When*/,50,.F.})  //MV_PAR05
	aAdd(aPergs, {1,"Fornecedor"			,cFornecedor,/*Pict*/	,/*Valid*/	,"A2A"		,/*When*/,50,.F.}) 	//MV_PAR06
	aAdd(aPergs, {1,"Loja"					,cLoja		,/*Pict*/	,/*Valid*/	,"A2L"		,/*When*/,50,.F.}) 	//MV_PAR07
	aAdd(aPergs ,{2,"Tipo de NF"			, "T", aTipoNF,50,"",.F.})											//MV_PAR08
											


	If ParamBox(aPergs, "Informe os parâmetros para Nota Fiscal de entrada", , , , , , , , , .F., .F.)
		oReport := fReportDef()
		oReport:PrintDialog()
	EndIf

	FWRestArea(aArea)
Return

/*
=====================================================================================
Programa.:              fReportDef
Autor....:              CAOA - Nicolas C Lima Santos
Data.....:              18/12/23
Descricao / Objetivo:   Gera relatorio
Doc. Origem:            
Solicitante:           
Uso......:              ZFISR016
Obs......:
=====================================================================================
*/
Static Function fReportDef() //Definições do relatório

	Local oReport
	Local oSection	:= Nil
	
	oReport:= TReport():New("ZFISR016",;				// --Nome da impressão
                            "Relatório de NF entrada com chave",;  // --Título da tela de parâmetros
                            ,;      		// --Grupo de perguntas na SX1, ao invés das pereguntas estou usando Parambox
                            {|oReport|  ReportPrint(oReport),};
                            ) // --Descrição do relatório
	
	oReport:SetLandScape(.T.)			//--Orientação do relatório como paisagem.
	//oReport:HideParamPage(.T.)    		//--Desabilita a impressao da pagina de parametros.
    oReport:HideHeader()        		//--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter()        		//--Define que não será impresso o rodapé padrão da página
	oReport:SetPreview(.T.)   			//--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2)   		//--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
	oReport:oPage:SetPaperSize(9)		//--Define impressão no papel A4

	oReport:lParamPage := .T. //Página de parâmetros?
	
	//Impressão por planilhas
	oReport:SetDevice(4)        		//--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
	oReport:SetTpPlanilha({.T., .T., .T., .T.}) //Formato Tabela {Normal, Suprimir linhas brancas e totais, Formato de Tabela, Formato de Tabela xlsx}
 
	//Definições de fonte:
	oReport:SetLineHeight(50) 			//--Espaçamento entre linhas
	oReport:cFontBody := 'Courier New' 	//--Tipo da fonte
	oReport:nFontBody := 12				//--Tamanho da fonte
	//oReport:SetEdit(.T.) 
	//Pergunte(oReport:GetParam(),.F.) 		//--Adicionar as perguntas na SX1

	oSection := TRSection():New(oReport,; 	//--Criando a seção de dados
		OEMToAnsi("Relatório de NF entrada com chave"),;
		{cTabela})
	oReport:SetTotalInLine(.F.) 			//--Desabilita o total de linhas
		
	
	//TRCell():New(oSection2,"CR_DATALIB"	,"SCR"	,'Data Aprov SC'	,/*Picture*/,TamSx3("CR_DATALIB")[1] 	,/*lPixel*/,/* {|| }*/)
	//--Colunas do relatório
	TRCell():New( oSection  ,"F1_FILIAL"  	,cTabela ,"Filial"			,/*cPicture*/,TamSx3("F1_FILIAL")[1] 	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"F1_XCODSAP"  	,cTabela ,"Código SAP"		,/*cPicture*/,TamSx3("F1_XCODSAP")[1] 	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection  ,"F1_DOC"       ,cTabela ,"Num. Documento"	,/*cPicture*/,TamSx3("F1_DOC")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"F1_SERIE"     ,cTabela ,"Série"			,/*cPicture*/,TamSx3("F1_SERIE")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"DT_EMIS"      ,cTabela ,"Data de emissão"	,/*cPicture*/,08						, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"F1_FORNECE"   ,cTabela ,"Fornecedor"		,/*cPicture*/,TamSx3("F1_FORNECE")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"F1_LOJA"      ,cTabela ,"Loja"			,/*cPicture*/,TamSx3("F1_LOJA")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A2_NOME"      ,cTabela ,"Desc. Fornec"	,/*cPicture*/,TamSx3("F1_FORNECE")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A2_CGC"      	,cTabela ,"CNPJ"			,/*cPicture*/,TamSx3("A2_CGC")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"F1_VALMERC"   ,cTabela ,"Valor líquido"	,/*cPicture*/,TamSx3("F1_VALMERC")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"F1_VALBRUT"  	,cTabela ,"Valor bruto"		,/*cPicture*/,TamSx3("F1_VALBRUT")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"F1_COND"      ,cTabela ,"Cond pagamento"	,/*cPicture*/,TamSx3("F1_COND")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"E4_DESCRI"    ,cTabela ,"Desc Cond pag."	,/*cPicture*/,TamSx3("E4_DESCRI")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"F1_CHVNFE"    ,cTabela ,"Chave"			,/*cPicture*/,TamSx3("F1_CHVNFE")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"TIPO_NF"      ,cTabela ,"Tipo de NF"		,/*cPicture*/,TamSx3("F1_TIPO")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)

Return oReport

Static Function ReportPrint(oReport)

	Local aArea 	:= FWGetArea()
	Local cQry		:= ""
	Local oSectDad  := Nil
	Local nAtual	:= 0
	Local nTotal	:= 0
	Local cMV_PAR08 := "" //Tipo de NF

	If!(empty(MV_PAR08)) .and. (MV_PAR08 == 'T')	
		//MV_PAR08 := str(MV_PAR08)
		cMV_PAR08 := MV_PAR08		
	Else
		cMV_PAR08 	:= Substr(MV_PAR08,1,1) //Tipo de NF
	EndIF

	//Pegando as secoes do relatório
	oSectDad := oReport:Section(1) //Primeira seção disponível

	cQry += " 	SELECT DISTINCT " 		 			+ CRLF
	cQry += "		 SF1.F1_FILIAL "	 			+ CRLF
	cQry += "		, SF1.F1_XCODSAP "	 			+ CRLF
	cQry += "		, SF1.F1_DOC "					+ CRLF
	cQry += "		, SF1.F1_SERIE "				+ CRLF
	cQry += "		, SF1.F1_EMISSAO AS DT_EMIS "	+ CRLF
	cQry += "		, SF1.F1_FORNECE "				+ CRLF
	cQry += "		, SF1.F1_LOJA "					+ CRLF
	cQry += "		, SA2.A2_NOME "					+ CRLF
	cQry += "		, SA2.A2_CGC "					+ CRLF
	cQry += "		, SF1.F1_VALMERC "				+ CRLF
	cQry += "		, SF1.F1_VALBRUT "				+ CRLF
	cQry += "		, SF1.F1_COND "					+ CRLF
	cQry += "		, SE4.E4_DESCRI "				+ CRLF
	cQry += "		, SF1.F1_CHVNFE "				+ CRLF
	cQry += "		, CASE "						+ CRLF
	cQry += "			WHEN F1_TIPO = 'N' THEN 'NORMAL' " 				+ CRLF
	cQry += "			WHEN F1_TIPO = 'D' THEN 'DEVOLUÇÃO' "			+ CRLF
	cQry += "			WHEN F1_TIPO = 'B' THEN 'BENEFICIAMENTO' "  	+ CRLF
	cQry += "			WHEN F1_TIPO = 'C' THEN 'COMPL. PREÇO' "		+ CRLF
	cQry += "			WHEN F1_TIPO = 'I' THEN 'NF COMPL. ICMS' "  	+ CRLF
	cQry += "			WHEN F1_TIPO = 'P' THEN 'NF COMPL. IPI' " 		+ CRLF
	cQry += "		END AS TIPO_NF " 									+ CRLF
	cQry += "	FROM "													+ CRLF
	cQry +=	" 	" + RetSqlName("SF1") + " SF1 "   						+ CRLF
	cQry += "	LEFT JOIN "												+ CRLF
	cQry += "	" + RetSqlName("SA2") + " SA2 "							+ CRLF
	cQry += "	 	ON SA2.A2_FILIAL 	= '" + FWxFilial("SA2") + "'"	+ CRLF
	cQry += "		AND SF1.F1_FORNECE 	= SA2.A2_COD "					+ CRLF
	cQry += "		AND SF1.F1_LOJA 	= SA2.A2_LOJA "					+ CRLF
	cQry += "		AND SA2.D_E_L_E_T_ 	= ' ' "							+ CRLF									
	cQry += "	LEFT JOIN "												+ CRLF
	cQry += "	" + RetSqlName("SE4") + " SE4 "							+ CRLF
	cQry += "	 	ON SE4.E4_FILIAL 	= '" + FWxFilial("SE4") + "'"	+ CRLF
	cQry += "		AND SE4.E4_CODIGO 	= SF1.F1_COND "					+ CRLF
	cQry += "		AND SE4.D_E_L_E_T_ 	= ' ' "							+ CRLF									
	cQry += "	WHERE "													+ CRLF
	cQry += "		SF1.F1_FILIAL 		= '" + FWxFilial("SF1") + "'"	+ CRLF	
	cQry += "		AND SF1.F1_CHVNFE	!= ' ' "						+ CRLF	
		
	If !Empty(DtoS(MV_PAR02)) //DT INVOICE ATE
		cQry += " 	AND SF1.F1_EMISSAO BETWEEN '" 	+ DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'" + CRLF
	EndIf

	If !Empty(MV_PAR03) // NUM DOCUMENTO NF
		cQry += "	AND SF1.F1_DOC 	 = '" + MV_PAR03 + "'" + CRLF
	EndIf
		
	If !Empty(MV_PAR04) // NUM SERIE NF
		cQry += "	AND SF1.F1_SERIE = '" + MV_PAR04 + "'" + CRLF
	EndIf

	If !Empty(MV_PAR05) // CODIGO DE INTEGRAÇÃO COM SAP
		cQry += "	AND SF1.F1_XCODSAP = '" + MV_PAR05 + "'" + CRLF
	EndIf

	If !Empty(MV_PAR06) // CODIGO DO FORNECEDOR
		cQry += "	AND SF1.F1_FORNECE = '" + MV_PAR06 + "'" + CRLF
	EndIf
	
	If !Empty(MV_PAR07) // CODIGO DA LOJA
		cQry += "	AND SF1.F1_LOJA = '" 	+ MV_PAR07 + "'" + CRLF
	EndIf

	If !Empty(cMV_PAR08)
		Do case //TIPO DE NF
			case cMV_PAR08 = 'T'
				cQry += "	AND SF1.F1_TIPO 		!= ' '" 		+ CRLF //TODAS
			case nMV_PAR08 = 'N' 
				cQry += "	AND SF1.F1_TIPO 		= 'N'" 			+ CRLF //NORMAL
			case cMV_PAR08 = 'D'
				cQry += "	AND SF1.F1_TIPO 		= 'D'" 			+ CRLF //DEVOLUÇÃO
			case cMV_PAR08 = 'B'
				cQry += "	AND SF1.F1_TIPO 		= 'B'" 			+ CRLF //BENEFICIAMENTO
			case cMV_PAR08 = 'I'
				cQry += "	AND SF1.F1_TIPO 		= 'I'" 			+ CRLF //COPML. PREÇO
			case cMV_PAR08 = 'P'
				cQry += "	AND SF1.F1_TIPO 		= 'P'" 			+ CRLF //NF COMPL. ICMS
			case cMV_PAR08 = 'C'
				cQry += "	AND SF1.F1_TIPO 		= 'C'" 			+ CRLF //NF COMPL. IPI
		EndCase
	EndIF

	cQry += "		AND SF1.D_E_L_E_T_ 	= ' '"						+ CRLF

	//Executando a conulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTabela, .T., .T. )

	//Setando o total da régua.
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

			oSectDad:Cell("DT_EMIS"):SetValue(StoD((cTabela)->DT_EMIS))
	
			//Imprimindo a linha atual
			oSectDad:PrintLine()

			(cTabela)->(DbSkip())
		EndDo
	oSectDad:Finish()
	
	(cTabela)->(DbCloseArea())

	FwRestArea(aArea)
Return

//Não utilizado
Static Function zSerie()
	Local aArea 	:= FWGetArea()
	Local cQry2		:= ""
	Local cTab2 	:= GetNextAlias()
	Local aSerie 	:= {"Todos"}

	cQry2 += " 	SELECT " 												+ CRLF	
	cQry2 += " SX5.X5_TABELA " 											+ CRLF 
	cQry2 += " , SX5.X5_CHAVE " 										+ CRLF
	cQry2 += " , SX5.X5_DESCRI " 										+ CRLF
	cQry2 += "	FROM "													+ CRLF
	cQry2 += " 	" + RetSqlName("SX5") + " SX5 "						+ CRLF
	cQry2 += "	WHERE "													+ CRLF
	cQry2 += "		SX5.X5_FILIAL 		= '" + FWxFilial("SX5") + "'"	+ CRLF	
	cQry2 += "		AND SX5.X5_TABELA = '01' "							+ CRLF	
	cQry2 += "		AND SX5.D_E_L_E_T_ = ' ' "							+ CRLF	

	//Executando a conulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry2), cTab2, .T., .T. )

	DbSelectArea(cTab2)
		(cTab2)->(DbGotop())
		While (cTab2)->(!EoF())

			aAdd( aSerie, (Alltrim((cTab2)->(X5_CHAVE)))) 
		
			(cTab2)->(DbSkip())
		EndDo
	
	(cTab2)->(DbCloseArea())

	FwRestArea(aArea)
Return aSerie
