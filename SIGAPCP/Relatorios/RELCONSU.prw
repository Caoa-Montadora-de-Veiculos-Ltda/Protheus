#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} RELCONSU
Relatório de Consumo por Período - CAOS
@author FSW - DWC Consult
@since 03/12/2018
@version All
@type function
/*/
User Function RELCONSU()
	Local lProcessa := .T.

	Private oReport

	If !TRepInUse()
		Alert("A Impressão em TREPORT deverá estar habilitada. Favor verificar o parâmetro MV_TREPORT.")
		lProcessa := .F.
	EndIf

	If lProcessa
		oReport:= ReportDef()
		oReport:PrintDialog()
	EndIf

Return

/*/{Protheus.doc} ReportDef
Função do TReport para impressão do relatório de Consumo por Periodo.
@author FSW - DWC Consult
@since 03/12/2018
@version All
@type function
/*/
Static Function ReportDef()
	Local cPerg			:= "RELCONSU"
	Local cTitulo		:= "Relatório de Consumo por Periodo - CAOA"
	Local cDescrRel		:= "Este relatório apresentas as informações referentes aos consumos por periodos."
	Local oReport
	Local oSection1	
	
	Private oBreak

	//Carregas as variaveis MV_PAR.
	Pergunte(cPerg,.F.)
	
	oReport:= TReport():New("RELCONSU", cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDescrRel)
	oReport:SetLandscape()			//Define orientação de pagina do relatório como paisagem.
	oReport:DisableOrientation()	//Desabilita a seleção da Orientação
	oReport:SetEnvironment(2) 		//Define o local de impressão 1- Servidor; 2-Local.

	oSection1:= TRSection():New(oReport, "Consumo por Periodo",{"SD3","SB1","SG1"}) //"Consumo por Periodo.
	oSection1:lHeaderVisible := .F.
	oSection1:SetReadOnly()

	TRCell():New(oSection1,"D3_NUMSERI"	,"SD3"	,"Part Number"			,/*Picture*/,TamSx3("D3_NUMSERI")[1]	,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"D3_COD"		,"SD3"	,"Veiculo"				,/*Picture*/,TamSx3("D3_COD")[1]		,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"B1_DESC"	,"SB1"	,"Descrição"			,/*Picture*/,TamSx3("B1_DESC")[1]		,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"D3_EMISSAO"	,"SD3"	,"Data Consumo"			,/*Picture*/,TamSx3("D3_EMISSAO")[1]	,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"D3_QUANT"	,"SD3"	,"Qtd. Consumida"		,/*Picture*/,TamSx3("D3_QUANT")[1]		,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"D3_CUSTO1"	,"SD3"	,"Valor Unitário"		,/*Picture*/,TamSx3("D3_CUSTO1")[1]		,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"VLRQTDCON"	,"SD3"	,"Vlr Qtd. Consumida"	,/*Picture*/,TamSx3("D3_CUSTO1")[1]		,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"G1_QUANT"	,"SG1"	,"Consumo Estrutura"	,/*Picture*/,TamSx3("G1_QUANT")[1]		,/*lPixel*/,/* {|| }*/)

	oBreak  := TRBreak():New(oSection1,{ || oSection1:Cell('D3_COD'):uPrint },,.F.,,.T.)

Return(oReport)

/*/{Protheus.doc} ReportPrint
Função Auxiliar para impressão do Relatório de Consumo por Periodo.
@author FSW - DWC Consult
@since 03/12/2018
@version All
@param oReport, object, descricao
@type function
/*/
Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local cAliSD3 	:= GetNextAlias()
	Local nTotal	:= 0
	Local nQuantG1	:= 0

	If Select(cAliSD3) > 0
		(cAliSD3)->(DbCloseArea())
	EndIf	
	BeginSql Alias cAliSD3
		column D3_EMISSAO	as Date
		column D3_QUANT		as Numeric(14,2)
		column D3_CUSTO1	as Numeric(14,2)
		column VLRQTDCON	as Numeric(14,2)
		column G1_QUANT		as Numeric(14,2)

		SELECT
			D3_NUMSERI,
			D3_COD,
			B1_DESC,
			D3_EMISSAO,
			D3_QUANT,
			D3_CUSTO1,
			D3_QUANT * D3_CUSTO1 AS VLRQTDCON
		FROM %Table:SD3% D
		LEFT JOIN %Table:SB1% B ON B.%NotDel% AND B.B1_FILIAL = %xFilial:SB1%
											  AND B.B1_COD = D.D3_COD
		WHERE
				D.%NotDel%
			AND D.D3_FILIAL = %xFilial:SD3%
			AND D.D3_NUMSERI BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND D.D3_EMISSAO BETWEEN %Exp:DToS(MV_PAR03)% AND %Exp:DToS(MV_PAR04)%
		ORDER BY
			D3_FILIAL,D3_EMISSAO,D3_COD
	EndSql
	Count To nTotal
	
	DbSelectArea(cAliSD3)
	(cAliSD3)->(DbGoTop())
	
	oReport:SetMeter(nTotal)
	
	oSection1:Init()
	
	While !(cAliSD3)->(EOF())
		
		oReport:IncMeter()
		
		oSection1:Cell("D3_NUMSERI"):SetValue((cAliSD3)->D3_NUMSERI)
		oSection1:Cell("D3_COD"):SetValue((cAliSD3)->D3_COD)
		oSection1:Cell("B1_DESC"):SetValue((cAliSD3)->B1_DESC)
		oSection1:Cell("D3_EMISSAO"):SetValue((cAliSD3)->D3_EMISSAO)
		oSection1:Cell("D3_QUANT"):SetValue((cAliSD3)->D3_QUANT)
		oSection1:Cell("D3_CUSTO1"):SetValue((cAliSD3)->D3_CUSTO1)
		oSection1:Cell("VLRQTDCON"):SetValue((cAliSD3)->VLRQTDCON)
		
		nQuantG1 := RelAux01((cAliSD3)->D3_COD)
		
		oSection1:Cell("G1_QUANT"):SetValue(nQuantG1)
		
		oSection1:Printline()

		(cAliSD3)->(DbSkip())
	EndDo
	oSection1:Finish()

	(cAliSD3)->(DbCloseArea())
Return

/*/{Protheus.doc} RelAux01
Função Auxiliar para somar a quantidade de itens da estrutura.
@author FSW - DWC Consult
@since 03/12/2018
@version All
@param cProduto, characters, descricao
@type function
/*/
Static Function RelAux01(cProduto)
	Local cAliSG1	:= GetNextAlias()
	Local nTotal	:= 0
	
	If Select(cAliSG1) > 0
		(cAliSG1)->(DbCloseArea())
	EndIf	
	BeginSql Alias cAliSG1
		column TOTAL_ESTRUTURA	as Numeric(14,2)
		
		SELECT
			SUM(G1_QUANT) AS TOTAL_ESTRUTURA
		FROM %Table:SG1% G
		WHERE
				G.%NotDel%
			AND G.G1_FILIAL = %xFilial:SG1%
			AND G.G1_COD = %Exp:cProduto%
	EndSql	
	
	DbSelectArea(cAliSG1)
	
	nTotal := (cAliSG1)->TOTAL_ESTRUTURA

	(cAliSG1)->(DbCloseArea())
Return(nTotal)