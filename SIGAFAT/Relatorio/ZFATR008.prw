#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

#Define CRLF chr(13) + chr(10)  
/*
=====================================================================================
Programa.:              ZFATR008
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              13/03/24
Descricao / Objetivo:   Relat�rio de limite de cr�dito de clientess
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
	local   aTpCred   	:= {"Todos"	,"0 - N�o Possui","1 - FloorPlan","2 - Caoa"} //0=Nao Possui;1=FloorPlan;2=Caoa   

	Private cTabela 	:= GetNextAlias()

	aAdd(aPergs, {1,"C�digo de"				,cCod		,/*Pict*/	,/*Valid*/	,"SA1"		,/*When*/,50,.F.})  //MV_PAR01
	aAdd(aPergs, {1,"C�digo at�"			,"ZZZZZZ"		,/*Pict*/	,/*Valid*/	,"SA1"		,/*When*/,50,.T.})  //MV_PAR02
	aAdd(aPergs ,{2,"Tipo cr�dito"			, "T", aTpCred,50,"",.F.})											//MV_PAR03

	If ParamBox(aPergs, "Informe os par�metros para pesquisa de limite de cr�dito", , , , , , , , , .F., .F.)
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
Static Function fReportDef() //Defini��es do relat�rio

	Local oReport
	Local oSection	:= Nil
	
	oReport:= TReport():New("ZFATR008",;				// --Nome da impress�o
                            "Relat�rio de limite de cr�dito - CAOA",;  // --T�tulo da tela de par�metros
                            ,;      		// --Grupo de perguntas na SX1, ao inv�s das pereguntas estou usando Parambox
                            {|oReport|  ReportPrint(oReport),};
                            ) // --Descri��o do relat�rio
	
	oReport:SetLandScape(.T.)			//--Orienta��o do relat�rio como paisagem.
	//oReport:HideParamPage(.T.)    		//--Desabilita a impressao da pagina de parametros.
    //oReport:HideHeader()        		//--Define que n�o ser� impresso o cabe�alho padr�o da p�gina
    oReport:HideFooter()        		//--Define que n�o ser� impresso o rodap� padr�o da p�gina
	oReport:SetPreview(.T.)   			//--Define se ser� apresentada a visualiza��o do relat�rio antes da impress�o f�sica
    oReport:SetEnvironment(2)   		//--Define o ambiente para impress�o 	Ambiente: 1-Server e 2-Client
	
	oReport:SetRightAlignPrinter(.T.)   //--Parametriza o TReport para alinhamento a direita
	
	oReport:oPage:SetPaperSize(9)		//--Define impress�o no papel A4

	oReport:lParamPage := .T. //P�gina de par�metros?
	
	//Impress�o por planilhas
	oReport:SetDevice(4)        		//--Define o tipo de impress�o selecionado. Op��es: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
	oReport:SetTpPlanilha({.T., .T., .T., .T.}) //Formato Tabela {Normal, Suprimir linhas brancas e totais, Formato de Tabela, Formato de Tabela xlsx}
 
	//Defini��es de fonte:
	oReport:SetLineHeight(50) 			//--Espa�amento entre linhas
	oReport:cFontBody := 'Courier New' 	//--Tipo da fonte
	oReport:nFontBody := 12				//--Tamanho da fonte
	//oReport:SetEdit(.T.) 
	//Pergunte(oReport:GetParam(),.F.) 		//--Adicionar as perguntas na SX1

	oSection := TRSection():New(oReport,; 	//--Criando a se��o de dados
		OEMToAnsi("Relat�rio de limite de cr�dito - CAOA"),;
		{cTabela})
	oReport:SetTotalInLine(.F.) 			//--Desabilita o total de linhas
	
	//--Define Colunas do relat�rio
	TRCell():New( oSection  ,"A1_COD"  		,cTabela ,"C�digo"			,/*cPicture*/,10 	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT" , /*lLineBreak*/, "LEFT" , /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"A1_LOJA"  	,cTabela ,"Loja"			,/*cPicture*/,06 	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT" , /*lLineBreak*/, "LEFT" , /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection  ,"A1_NOME"      ,cTabela ,"Nome"			,/*cPicture*/,50	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT" , /*lLineBreak*/, "LEFT" , /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"PESSOA"    	,cTabela ,"Pessoa"			,/*cPicture*/,11	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT" , /*lLineBreak*/, "LEFT" , /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"CGC"       	,cTabela ,"CPF/CNPF"		,/*cPicture*/,26	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT" , /*lLineBreak*/, "LEFT" , /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A1_XTPCRED"	,cTabela ,"Tipo cr�dito"	,/*cPicture*/,20	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT" , /*lLineBreak*/, "LEFT" , /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A1_XDTLC"   	,cTabela ,"Validade"		,/*cPicture*/,12	, /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT" , /*lLineBreak*/, "LEFT" , /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A1_XLC"      	,cTabela ,"Limite"			,/*cPicture*/,14	, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"A1_XFPSAL"    ,cTabela ,"Saldo"			,/*cPicture*/,14	, /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	
Return oReport

Static Function ReportPrint(oReport) //Query e impress�o do relat�rio 

	Local aArea 	:= FWGetArea()
	Local cQry		:= ""
	Local oSectDad  := Nil
	local nAtual	:= 0 //Linha atual do relat�rio indicado na r�gua.
	Local nTotal	:= 0 //Total de linhas do relat�rio indicado na r�gua.
	
	local cCgc 		:= "" //CPF / CNPJ
	Local cTpCred	:= "" //Tipo de cr�dito

	//Tratando combobox do tipo de cr�dito.
	If!(empty(MV_PAR03)) .and. (MV_PAR03 == 'T')	
		cTpCred	:= MV_PAR03	
	Else
		cTpCred	:= Substr(MV_PAR03,1,1) //Tipo de cr�dito do cliente.
	EndIF

	//Pegando as secoes do relat�rio
	oSectDad := oReport:Section(1) //Primeira se��o dispon�vel

	cQry += " 	SELECT DISTINCT " 		 								+ CRLF
	cQry += "		 SA1.A1_COD "	 									+ CRLF
	cQry += "		, SA1.A1_LOJA "	 									+ CRLF
	cQry += "		, SA1.A1_NOME "										+ CRLF
	cQry += "		, CASE "											+ CRLF
	cQry += "			WHEN SA1.A1_PESSOA = 'F' THEN 'F�SICA' "		+ CRLF
	cQry += "			WHEN SA1.A1_PESSOA = 'J' THEN 'JUR�DICA' "		+ CRLF
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
	
	If !Empty(MV_PAR02) //C�DIGO DE / ATE
		cQry += " 	AND SA1.A1_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" + CRLF
	EndIf

	If !Empty(cTpCred) 
		Do case //Tipo de cr�dito -> 0=Nao Possui;1=FloorPlan;2=Caoa   
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

	//Setando o total da r�gua.
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

