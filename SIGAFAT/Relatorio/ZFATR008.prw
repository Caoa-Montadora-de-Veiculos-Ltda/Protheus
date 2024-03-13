#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

#Define CRLF chr(13) + chr(10)  
/*
=====================================================================================
Programa.:              ZFATR008
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              13/03/24
Descricao / Objetivo:   Relatório de limite de crédito de clientess
Doc. Origem:            GAP141
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZFATR008()
    
	Local	aArea 		:= FwGetArea()
	Local	oReport
	Local	aPergs		:= {}

	Local 	cCod 		:= Space(TamSX3('A1_COD')[1]) 
	Local 	cLoja 		:= Space(TamSX3('A1_LOJA')[1])
	local   aTpCred   	:= {"Todos"	,"0 - Não Possui","1 - FloorPlan","2 - Caoa"} //0=Nao Possui;1=FloorPlan;2=Caoa   

	Private cTabela 	:= GetNextAlias()

	aAdd(aPergs, {1,"Código de"				,cCod		,/*Pict*/	,/*Valid*/	,"SA1"		,/*When*/,50,.F.})  //MV_PAR01
	aAdd(aPergs, {1,"Código até"			,"ZZZZZZ"		,/*Pict*/	,/*Valid*/	,"SA1"		,/*When*/,50,.T.})  //MV_PAR02
	aAdd(aPergs ,{2,"Tipo crédito"			, "T", aTpCred,50,"",.F.})											//MV_PAR03

	If ParamBox(aPergs, "Informe os parâmetros para pesquisa de limite de crédito", , , , , , , , , .F., .F.)
		oReport := fReportDef()
		oReport:PrintDialog()
	EndIf

	FWRestArea(aArea)
Return

/*
=====================================================================================
Programa.:              fReportDef
Autor....:              CAOA - Nicolas C Lima Santos
Data.....:              13/03/2024
Descricao / Objetivo:   Gera relatorio
Doc. Origem:            
Solicitante:           
Uso......:              ZFATR008
Obs......:
=====================================================================================
*/
Static Function fReportDef() //Definições do relatório

	Local oReport
	Local oSection	:= Nil
	
	oReport:= TReport():New("ZFATR008",;				// --Nome da impressão
                            "Relatório de limite de crédito - CAOA",;  // --Título da tela de parâmetros
                            ,;      		// --Grupo de perguntas na SX1, ao invés das pereguntas estou usando Parambox
                            {|oReport|  ReportPrint(oReport),};
                            ) // --Descrição do relatório
	
	oReport:SetLandScape(.T.)			//--Orientação do relatório como paisagem.
	//oReport:HideParamPage(.T.)    		//--Desabilita a impressao da pagina de parametros.
    //oReport:HideHeader()        		//--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter()        		//--Define que não será impresso o rodapé padrão da página
	oReport:SetPreview(.T.)   			//--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2)   		//--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
	
	oReport:SetRightAlignPrinter(.T.)   //--Parametriza o TReport para alinhamento a direita
	
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
		OEMToAnsi("Relatório de limite de crédito - CAOA"),;
		{cTabela})
	oReport:SetTotalInLine(.F.) 			//--Desabilita o total de linhas
	
	//--Define Colunas do relatório
	TRCell():New( oSection  ,"A1_COD"  		,cTabela ,"Código"			,/*cPicture*/,10 	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT" , /*lLineBreak*/, "LEFT" , /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"A1_LOJA"  	,cTabela ,"Loja"			,/*cPicture*/,06 	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT" , /*lLineBreak*/, "LEFT" , /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection  ,"A1_NOME"      ,cTabela ,"Nome"			,/*cPicture*/,50	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT" , /*lLineBreak*/, "LEFT" , /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"PESSOA"    	,cTabela ,"Pessoa"			,/*cPicture*/,11	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT" , /*lLineBreak*/, "LEFT" , /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"CGC"       	,cTabela ,"CPF/CNPF"		,/*cPicture*/,26	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT" , /*lLineBreak*/, "LEFT" , /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A1_XTPCRED"	,cTabela ,"Tipo crédito"	,/*cPicture*/,20	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT" , /*lLineBreak*/, "LEFT" , /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A1_XDTLC"   	,cTabela ,"Validade"		,/*cPicture*/,12	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT" , /*lLineBreak*/, "LEFT" , /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A1_XLC"      	,cTabela ,"Limite"			,/*cPicture*/,14	, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A1_XFPSAL"    ,cTabela ,"Saldo"			,/*cPicture*/,14	, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	
Return oReport

Static Function ReportPrint(oReport) //Query e impressão do relatório 

	Local aArea 	:= FWGetArea()
	Local cQry		:= ""
	Local oSectDad  := Nil
	local nAtual	:= 0 //Linha atual do relatório indicado na régua.
	Local nTotal	:= 0 //Total de linhas do relatório indicado na régua.
	
	local cCgc 		:= "" //CPF / CNPJ
	Local cTpCred	:= "" //Tipo de crédito

	//Tratando combobox do tipo de crédito.
	If!(empty(MV_PAR03)) .and. (MV_PAR03 == 'T')	
		cTpCred	:= MV_PAR03	
	Else
		cTpCred	:= Substr(MV_PAR03,1,1) //Tipo de crédito do cliente.
	EndIF

	//Pegando as secoes do relatório
	oSectDad := oReport:Section(1) //Primeira seção disponível

	cQry += " 	SELECT DISTINCT " 		 								+ CRLF
	cQry += "		 SA1.A1_COD "	 									+ CRLF
	cQry += "		, SA1.A1_LOJA "	 									+ CRLF
	cQry += "		, SA1.A1_NOME "										+ CRLF
	cQry += "		, CASE "											+ CRLF
	cQry += "			WHEN SA1.A1_PESSOA = 'F' THEN 'FÍSICA' "		+ CRLF
	cQry += "			WHEN SA1.A1_PESSOA = 'J' THEN 'JURÍDICA' "		+ CRLF
	cQry += "		END AS PESSOA " 									+ CRLF
	cQry += "		, SA1.A1_CGC "										+ CRLF
	cQry += "		, SA1.A1_XTPCRED "									+ CRLF
	cQry += "		, SA1.A1_XDTLC "									+ CRLF
	cQry += "		, SA1.A1_XLC "										+ CRLF
	cQry += "		, SA1.A1_XFPSAL "									+ CRLF
	cQry += "	FROM "													+ CRLF
	cQry +=	" 	" + RetSqlName("SA1") + " SA1 "   						+ CRLF								
	cQry += "	WHERE "													+ CRLF
	cQry += "		SA1.D_E_L_E_T_ 	= ' '"								+ CRLF
	
	If !Empty(MV_PAR02) //CÓDIGO DE / ATE
		cQry += " 	AND SA1.A1_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" + CRLF
	EndIf

	If !Empty(cTpCred) 
		Do case //Tipo de crédito -> 0=Nao Possui;1=FloorPlan;2=Caoa   
			case cTpCred = 'T' //Todos
				cQry += "	AND SA1.A1_XTPCRED    	!= ' '" 		+ CRLF 
			case cTpCred = '0' 
				cQry += "	AND SA1.A1_XTPCRED 		= '0'" 			+ CRLF 
			case cTpCred = '1'
				cQry += "	AND SA1.A1_XTPCRED 		= '1'" 			+ CRLF 
			case cTpCred = '2'
				cQry += "	AND SA1.A1_XTPCRED 		= '2'" 			+ CRLF 
		EndCase
	EndIF

	cQry += "		ORDER BY "					+ CRLF
	cQry += "		SA1.A1_COD "					+ CRLF

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

			//Converte formato CPF / CNPJ
			cCgc := ""
			cCgc := Alltrim((cTabela)->A1_CGC )
			If Len(cCgc) > 12 
				cCgc := Alltrim(Transform(cCgc,"@R 99.999.999/9999-99")) //CNPJ
			Else
				cCgc := Alltrim(Transform(cCgc,"@R 999.999.999-99")) //CPF
			Endif
			
			oSectDad:Cell("CGC"):SetValue(cCgc) //CPF / CNPJ
			oSectDad:Cell("A1_XDTLC"):SetValue(StoD((cTabela)->A1_XDTLC))
	
			//Imprimindo a linha atual
			oSectDad:PrintLine()

			(cTabela)->(DbSkip())
		EndDo
	oSectDad:Finish()
	
	(cTabela)->(DbCloseArea())

	FwRestArea(aArea)
Return

