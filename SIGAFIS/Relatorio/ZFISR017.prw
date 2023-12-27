#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

#define CRLF chr(13) + chr(10)  
/*
=====================================================================================
Programa.:              ZFISR017
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              18/12/23
Descricao / Objetivo:   Relatório de Notas Fiscais de SAÍDA com chave
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZFISR017()
    
	Local	aArea 		:= FwGetArea()
	Local	oReport
	Local	aPergs		:= {}
	Local	nNumNF		:= Space(TamSX3('F2_DOC')[1]) 
	Local	nSerieNF	:= Space(TamSX3('F2_SERIE')[1])
	Local	dDtEmiss	:= Ctod(Space(8)) //Data de emissao de NF
	Local	cCodSAP		:= Space(TamSX3('F2_XCODSAP')[1])
	Local 	cCliente 	:= Space(TamSX3('F2_CLIENTE')[1])
	Local 	cLoja 		:= Space(TamSX3('F2_LOJA')[1])
	local   aTipoNF   	:= {"Todas"	,"N - Normal","D - Devolução","I = Compl. ICMS", "P = Compl. ICMS", "C = Compl. Preço"}
	
	Private cTabela 	:= GetNextAlias()

 	aAdd(aPergs, {1,"Dt emissao de"			,dDtEmiss	,/*Pict*/	,/*Valid*/	,/*F3*/		,/*When*/,50,.F.})  //MV_PAR01
	aAdd(aPergs, {1,"Dt emissao ate"		,dDtEmiss	,/*Pict*/,MV_PAR02 > MV_PAR01,/*F3*/,/*When*/,50,.F.})  //MV_PAR02
	aAdd(aPergs, {1,"Numero NF"				,nNumNF		,/*Pict*/	,/*Valid*/	,"SF2"		,/*When*/,50,.F.})  //MV_PAR03
	aAdd(aPergs, {1,"Serie NF"				,nSerieNF	,/*Pict*/	,/*Valid*/	,"_SF1SE"	,/*When*/,50,.F.})  //MV_PAR04
	aAdd(aPergs, {1,"Código SAP"			,cCodSAP	,/*Pict*/	,/*Valid*/	,"_F2SAP"	,/*When*/,50,.F.})  //MV_PAR05
	aAdd(aPergs, {1,"Cliente"				,cCliente	,/*Pict*/	,/*Valid*/	,"SA1"		,/*When*/,50,.F.}) 	//MV_PAR06
	aAdd(aPergs, {1,"Loja"					,cLoja		,/*Pict*/	,/*Valid*/	,"SA1LJ"	,/*When*/,50,.F.}) 	//MV_PAR07
	aAdd(aPergs ,{2,"Tipo de NF"			, "T", aTipoNF,50,"",.F.})											//MV_PAR08

	If ParamBox(aPergs, "Informe os parâmetros para Nota Fiscal de saída", , , , , , , , , .F., .F.)
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
Uso......:              ZFISR017
Obs......:
=====================================================================================
*/
Static Function fReportDef() //Definições do relatório

	Local oReport
	Local oSection	:= Nil
	
	oReport:= TReport():New("ZFISR017",;				// --Nome da impressão
                            "Relatório de NF saída com chave",;  // --Título da tela de parâmetros
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
		OEMToAnsi("Relatório de NF saída com chave"),;
		{cTabela})
	oReport:SetTotalInLine(.F.) 			//--Desabilita o total de linhas
		
	
	//TRCell():New(oSection2,"CR_DATALIB"	,"SCR"	,'Data Aprov SC'	,/*Picture*/,TamSx3("CR_DATALIB")[1] 	,/*lPixel*/,/* {|| }*/)
	//--Colunas do relatório
	TRCell():New( oSection  ,"F2_FILIAL"  	,cTabela ,"Filial"			,/*cPicture*/,TamSx3("F2_FILIAL")[1] 	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"F2_XCODSAP"  	,cTabela ,"Código SAP"		,/*cPicture*/,TamSx3("F2_XCODSAP")[1] 	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection  ,"F2_DOC"       ,cTabela ,"Num. Documento"	,/*cPicture*/,TamSx3("F2_DOC")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"F2_SERIE"     ,cTabela ,"Série"			,/*cPicture*/,TamSx3("F2_SERIE")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"DT_EMIS"      ,cTabela ,"Data de emissão"	,/*cPicture*/,08						, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"F2_CLIENTE"   ,cTabela ,"Cliente"			,/*cPicture*/,TamSx3("F2_CLIENTE")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"F2_LOJA"      ,cTabela ,"Loja"			,/*cPicture*/,TamSx3("F2_LOJA")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A1_NOME"      ,cTabela ,"Desc. Cliente"	,/*cPicture*/,TamSx3("F2_CLIENTE")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A1_CGC"      	,cTabela ,"CNPJ"			,/*cPicture*/,TamSx3("A1_CGC")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"F2_VALMERC"   ,cTabela ,"Valor líquido"	,/*cPicture*/,TamSx3("F2_VALMERC")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"F2_VALBRUT"  	,cTabela ,"Valor bruto"		,/*cPicture*/,TamSx3("F2_VALBRUT")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"F2_COND"      ,cTabela ,"Cond pagamento"	,/*cPicture*/,TamSx3("F2_COND")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"E4_DESCRI"    ,cTabela ,"Desc Cond pag."	,/*cPicture*/,TamSx3("E4_DESCRI")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"F2_CHVNFE"    ,cTabela ,"Chave"			,/*cPicture*/,TamSx3("F2_CHVNFE")[1]	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"TIPO_NF"      ,cTabela ,"Tipo de NF"		,/*cPicture*/,TamSx3("F2_TIPO")[1]		, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)

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
	cQry += "		 SF2.F2_FILIAL "	 			+ CRLF
	cQry += "		, SF2.F2_XCODSAP "	 			+ CRLF
	cQry += "		, SF2.F2_DOC "					+ CRLF
	cQry += "		, SF2.F2_SERIE "				+ CRLF
	cQry += "		, SF2.F2_EMISSAO AS DT_EMIS "	+ CRLF
	cQry += "		, SF2.F2_CLIENTE "				+ CRLF
	cQry += "		, SF2.F2_LOJA "					+ CRLF
	cQry += "		, SA1.A1_NOME "					+ CRLF
	cQry += "		, SA1.A1_CGC "					+ CRLF
	cQry += "		, SF2.F2_VALMERC "				+ CRLF
	cQry += "		, SF2.F2_VALBRUT "				+ CRLF
	cQry += "		, SF2.F2_COND "					+ CRLF
	cQry += "		, SE4.E4_DESCRI "				+ CRLF
	cQry += "		, SF2.F2_CHVNFE "				+ CRLF
	cQry += "		, CASE "						+ CRLF
	cQry += "			WHEN SF2.F2_TIPO = 'N' THEN 'NORMAL' " 				+ CRLF
	cQry += "			WHEN SF2.F2_TIPO = 'D' THEN 'DEVOLUÇÃO' "			+ CRLF
	cQry += "			WHEN SF2.F2_TIPO = 'C' THEN 'COMPL. PREÇO' "		+ CRLF
	cQry += "			WHEN SF2.F2_TIPO = 'I' THEN 'NF COMPL. ICMS' "  	+ CRLF
	cQry += "			WHEN SF2.F2_TIPO = 'P' THEN 'NF COMPL. IPI' " 		+ CRLF
	cQry += "		END AS TIPO_NF " 									+ CRLF
	cQry += "	FROM "													+ CRLF
	cQry +=	" 	" + RetSqlName("SF2") + " SF2 "   						+ CRLF
	cQry += "	LEFT JOIN "												+ CRLF
	cQry += "	" + RetSqlName("SA1") + " SA1 "							+ CRLF
	cQry += "	 	ON SA1.A1_FILIAL 	= '" + FWxFilial("SA1") + "'"	+ CRLF
	cQry += "		AND SF2.F2_CLIENTE 	= SA1.A1_COD "					+ CRLF
	cQry += "		AND SF2.F2_LOJA 	= SA1.A1_LOJA "					+ CRLF
	cQry += "		AND SA1.D_E_L_E_T_ 	= ' ' "							+ CRLF									
	cQry += "	LEFT JOIN "												+ CRLF
	cQry += "	" + RetSqlName("SE4") + " SE4 "							+ CRLF
	cQry += "	 	ON SE4.E4_FILIAL 	= '" + FWxFilial("SE4") + "'"	+ CRLF
	cQry += "		AND SE4.E4_CODIGO 	= SF2.F2_COND "					+ CRLF
	cQry += "		AND SE4.D_E_L_E_T_ 	= ' ' "							+ CRLF									
	cQry += "	WHERE "													+ CRLF
	cQry += "		SF2.F2_FILIAL 		= '" + FWxFilial("SF2") + "'"	+ CRLF	
	cQry += "		AND SF2.F2_CHVNFE	!= ' ' "						+ CRLF	
		
	If !Empty(DtoS(MV_PAR02)) //DT INVOICE ATE
		cQry += " 	AND SF2.F2_EMISSAO BETWEEN '" 	+ DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'" + CRLF
	EndIf

	If !Empty(MV_PAR03) // NUM DOCUMENTO NF
		cQry += "	AND SF2.F2_DOC 	 = '" + MV_PAR03 + "'" + CRLF
	EndIf
		
	If !Empty(MV_PAR04) // NUM SERIE NF
		cQry += "	AND SF2.F2_SERIE = '" + MV_PAR04 + "'" + CRLF
	EndIf

	If !Empty(MV_PAR05) // CODIGO DE INTEGRAÇÃO COM SAP
		cQry += "	AND SF2.F2_XCODSAP = '" + MV_PAR05 + "'" + CRLF
	EndIf

	If !Empty(MV_PAR06) // CODIGO DO FORNECEDOR
		cQry += "	AND SF2.F2_FORNECE = '" + MV_PAR06 + "'" + CRLF
	EndIf
	
	If !Empty(MV_PAR07) // CODIGO DA LOJA
		cQry += "	AND SF2.F2_LOJA = '" 	+ MV_PAR07 + "'" + CRLF
	EndIf

	If !Empty(cMV_PAR08)
		Do case //TIPO DE NF
			case cMV_PAR08 = 'T'
				cQry += "	AND SF2.F2_TIPO 		!= ' '" 		+ CRLF //TODAS
			case nMV_PAR08 = 'N' 
				cQry += "	AND SF2.F2_TIPO 		= 'N'" 			+ CRLF //NORMAL
			case cMV_PAR08 = 'D'
				cQry += "	AND SF2.F2_TIPO 		= 'D'" 			+ CRLF //DEVOLUÇÃO
			case cMV_PAR08 = 'I'
				cQry += "	AND SF2.F2_TIPO 		= 'I'" 			+ CRLF //COPML. PREÇO
			case cMV_PAR08 = 'P'
				cQry += "	AND SF2.F2_TIPO 		= 'P'" 			+ CRLF //NF COMPL. ICMS
			case cMV_PAR08 = 'C'
				cQry += "	AND SF2.F2_TIPO 		= 'C'" 			+ CRLF //NF COMPL. IPI
		EndCase
	EndIF

	cQry += "		AND SF2.D_E_L_E_T_ 	= ' '"						+ CRLF

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


