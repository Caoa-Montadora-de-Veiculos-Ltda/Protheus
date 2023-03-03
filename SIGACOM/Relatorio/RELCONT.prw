#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} RELCONT
Relatório Contratos de Parcerias - CAOA
@author FSW - DWC Consult
@since 25/11/2018
@version All
@type function
/*/
User Function RELCONT()
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
Função Auxiliar para impressão do Relatório Contratos de Parcerias - CAOA.
@author FSW - DWC Consult
@since 25/11/2018
@version All
@type function
/*/
Static Function ReportDef()
	Local cPerg		:= "RELCONT"
	Local cTitulo	:= "Relatório de Contratos de Parceria - CAOA"
	Local cDescrRel	:= "Este relatório listará os itens dos contratos de parceria."
	Local oReport
	Local oSection1
	Local oSection2	
	
	Private oBreak

	//Carregas as variaveis MV_PAR.
	Pergunte(cPerg,.F.)

	oReport:= TReport():New("RELCONT", cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDescrRel)
	oReport:SetLandscape()			//Define orientação de pagina do relatório como paisagem.
	oReport:DisableOrientation()	//Desabilita a seleção da Orientação
	oReport:SetEnvironment(2) 		//Define o local de impressão 1- Servidor; 2-Local.

	oSection1:= TRSection():New(oReport, "Contrato de Parceria",{"SC3"}) //"Cabeçalho do Contrato de Parceria.
	oSection1:lHeaderVisible := .F.
	oSection1:SetReadOnly()

	TRCell():New(oSection1,"C3_NUM"		 ,"SC3"	,'Num. Contrato'		,/*Picture*/				,TamSx3("C3_NUM")[1] 		,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"C3_EMISSAO"	 ,"SC3"	,'Data de Criação'		,/*Picture*/				,TamSx3("C3_EMISSAO")[1]	,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"C3_USER"	 ,"SC3"	,'Criado Por'			,/*Picture*/				,TamSx3("C3_USER")[1] + 10	,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"C3_FORNECE"	 ,"SC3"	,'Fornecedor'			,/*Picture*/				,TamSx3("C3_FORNECE")[1]	,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"C3_LOJA"	 ,"SC3"	,'Loja Forn.'			,/*Picture*/				,TamSx3("C3_FORNECE")[1]	,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"A2_NOME"  	 ,"SA2"	,'Razão Social'			,/*Picture*/				,TamSx3("A2_NOME")[1] 		,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"VLRCONTRATO" ,""	,'Vlr Contrato'			,PesqPict("SC3","C3_TOTAL")	,TamSx3("C3_TOTAL")[1] 		,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"VLRCONSUMID" ,""	,'Vlr Consumido'		,PesqPict("SC3","C3_TOTAL")	,TamSx3("C3_TOTAL")[1] 		,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"SALDO" 		 ,""	,'Sld Contrato'			,PesqPict("SC3","C3_TOTAL")	,TamSx3("C3_TOTAL")[1]		,/*lPixel*/,/* {|| }*/)
	
	oSection2:= TRSection():New(oReport, "Itens do Contrato",{"SC3","SC7","SB1","SA2"}) //"Itens do Contrato de Parceria.
	oSection2:lHeaderVisible := .F.
	oSection2:SetReadOnly()

	TRCell():New(oSection2,"C3_ITEM"	,"SC3"	,'Item'				,/*Picture*/,TamSx3("C3_ITEM")[1]			,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection2,"C3_PRODUTO" ,"SC3"	,'Produto'			,/*Picture*/,TamSx3("C3_PRODUTO")[1] + 05	,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection2,"B1_DESC" 	,"SB1"	,'Descrição'		,/*Picture*/,TamSx3("B1_DESC")[1]			,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection2,"C3_DATPRI"	,"SC3"	,'Inicio Ctrto'		,/*Picture*/,TamSx3("C3_DATPRI")[1]			,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection2,"C3_DATPRF"	,"SC3"	,'Término Ctrto'	,/*Picture*/,TamSx3("C3_DATPRF")[1]			,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection2,"C3_QUANT"   ,"SC3"	,'Quantidade'		,/*Picture*/,TamSx3("C3_QUANT")[1] 			,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection2,"C3_PRECO" 	,"SC3"	,'Vlr Unitário'		,/*Picture*/,TamSx3("C3_PRECO")[1]			,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection2,"C3_TOTAL" 	,"SC3"	,'Vlr Total'		,/*Picture*/,TamSx3("C3_TOTAL")[1] 			,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection2,"C7_NUM"		,"SC7"	,'Ped. Comp'		,/*Picture*/,TamSx3("C7_NUM")[1]			,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection2,"C7_ITEM"	,"SC7"	,'Item PC'			,/*Picture*/,TamSx3("C7_ITEM")[1]			,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection2,"C7_QUANT"   ,"SC7"	,'Qtdade PC'		,/*Picture*/,TamSx3("C7_QUANT")[1] 			,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection2,"AUTORIZ"	,""		,'Autorização'		,/*Picture*/,TamSx3("C7_NUM")[1]			,/*lPixel*/,/* {|| }*/)
	
	oBreak  := TRBreak():New(oSection1,{ || oSection1:Cell('C3_NUM'):uPrint },,.F.,,.T.)

Return(oReport)

/*/{Protheus.doc} ReportPrint
Função Auxiliar para impressão do Relatório Contratos de Parceria - CAOA.
@author FSW - DWC Consult
@since 25/11/2018
@version All
@param oReport, object, descricao
@type function
/*/
Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2	:= oReport:Section(2)
	Local cAliSC3 	:= GetNextAlias()
	Local cAliDado	:= GetNextAlias()
	Local nTotal	:= 0
	
	If Select(cAliSC3) > 0
		(cAliSC3)->(DbCloseArea())
	EndIf
	BeginSql Alias cAliSC3
		column C3_EMISSAO	As Date
		column VLRCONTRATO	As Numeric(14,2)
		column VLRCONSUMID	As Numeric(14,2)
		column SALDO		As Numeric(14,2)
		
		SELECT
			C3_NUM,
			C3_EMISSAO,
			C3_USER,
			C3_FORNECE,
			C3_LOJA,
			A2_NOME,
			SUM(C3_TOTAL) AS VLRCONTRATO,
			SUM(C3_QUJE * C3_PRECO) AS VLRCONSUMID,
			SUM(C3_TOTAL) - SUM(C3_QUJE * C3_PRECO) AS SALDO
		FROM %Table:SC3% C
		LEFT JOIN %Table:SA2% E ON E.%NotDel% AND E.A2_COD = C.C3_FORNECE
									  		  AND E.A2_LOJA = C.C3_LOJA
									  		  AND E.A2_FILIAL = %xFilial:SA2%
		WHERE
				C.%NotDel%
			AND C.C3_FILIAL = %xFilial:SC3%	
			AND C.C3_NUM BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND C.C3_EMISSAO BETWEEN %Exp:DToS(MV_PAR03)% AND %Exp:DToS(MV_PAR04)%
			AND C.C3_DATPRI >= %Exp:DToS(MV_PAR05)% 
			AND C.C3_DATPRF <= %Exp:DToS(MV_PAR06)%
			AND C.C3_FORNECE BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR09%
			AND C.C3_LOJA BETWEEN %Exp:MV_PAR08% AND %Exp:MV_PAR10%
			AND C.C3_PRODUTO BETWEEN %Exp:MV_PAR11% AND %Exp:MV_PAR12%
		GROUP BY
			C3_NUM,C3_EMISSAO,C3_USER,C3_FORNECE,C3_LOJA,A2_NOME
		ORDER BY
			C3_NUM,C3_FORNECE,C3_LOJA
	EndSql
	Count To nTotal
	
	DbSelectArea(cAliSC3)
	(cAliSC3)->(DbGoTop())
	
	oReport:SetMeter(nTotal)
	
	oSection1:Init()
	
	While !(cAliSC3)->(EOF())
	
		oReport:IncMeter()
	
		oSection1:Cell("C3_NUM"):SetValue((cAliSC3)->C3_NUM)
		oSection1:Cell("C3_EMISSAO"):SetValue((cAliSC3)->C3_EMISSAO)
		oSection1:Cell("C3_USER"):SetValue(AllTrim(UsrFullName((cAliSC3)->C3_USER)))
		oSection1:Cell("C3_FORNECE"):SetValue((cAliSC3)->C3_FORNECE)
		oSection1:Cell("C3_LOJA"):SetValue((cAliSC3)->C3_LOJA)
		oSection1:Cell("A2_NOME"):SetValue(AllTrim((cAliSC3)->A2_NOME))
		oSection1:Cell("VLRCONTRATO"):SetValue((cAliSC3)->VLRCONTRATO)
		oSection1:Cell("VLRCONSUMID"):SetValue((cAliSC3)->VLRCONSUMID)
		oSection1:Cell("SALDO"):SetValue((cAliSC3)->SALDO)
		oSection1:Printline()
		
		
		If Select(cAliDado) > 0
			(cAliDado)->(DbCloseArea())
		EndIf
		BeginSql Alias cAliDado
			column C3_DATPRI	As Date
			column C3_DATPRF	As Date
			column C3_QUANT		As Numeric(14,2)
			column C3_PRECO		As Numeric(14,2)
			column C3_TOTAL		As Numeric(14,2)
			column C7_QUANT		As Numeric(14,2)
		
			SELECT
				C3_ITEM,
				C3_PRODUTO,
				B1_DESC,
				C3_DATPRI,
				C3_DATPRF,
				C3_QUANT,
				C3_PRECO,
				C3_TOTAL,
				C7_NUM,
				C7_ITEM,
				C7_QUANT,
				C7_NUM AS AUTORIZ
			FROM %Table:SC3% C
			LEFT JOIN %Table:SB1% B ON B.%NotDel% AND B.B1_COD = C.C3_PRODUTO
												  AND B.B1_FILIAL = %xFilial:SB1%
			LEFT JOIN %Table:SC7% D ON D.%NotDel% AND D.C7_FILIAL = %xFilial:SC7%
									  		  	  AND D.C7_NUMSC = %Exp:(cAliSC3)->C3_NUM%
									  		  	  AND D.C7_FORNECE = %Exp:(cAliSC3)->C3_FORNECE%
									  		  	  AND D.C7_LOJA = %Exp:(cAliSC3)->C3_LOJA%
									  		  	  AND D.C7_TIPO = %Exp:'2'%
									  		  	  AND D.C7_NUM BETWEEN %Exp:MV_PAR13% AND %Exp:MV_PAR14%
			WHERE
					C.%NotDel%
				AND C.C3_FILIAL = %xFilial:SC3%
				AND C.C3_NUM = %Exp:(cAliSC3)->C3_NUM%
				AND C.C3_FORNECE = %Exp:(cAliSC3)->C3_FORNECE%
				AND C.C3_LOJA = %Exp:(cAliSC3)->C3_LOJA%
			ORDER BY
				C3_NUM,C3_ITEM,C3_FORNECE,C3_LOJA
		EndSql
		
		DbSelectArea(cAliDado)
		(cAliDado)->(DbGoTop())
				
		oSection2:Init()
		
		While !(cAliDado)->(EOF())
				
			oSection2:Cell("C3_ITEM"):SetValue((cAliDado)->C3_ITEM)
			oSection2:Cell("C3_PRODUTO"):SetValue((cAliDado)->C3_PRODUTO)
			oSection2:Cell("B1_DESC"):SetValue(AllTrim((cAliDado)->B1_DESC))
			oSection2:Cell("C3_DATPRI"):SetValue((cAliDado)->C3_DATPRI)
			oSection2:Cell("C3_DATPRF"):SetValue((cAliDado)->C3_DATPRF)
			oSection2:Cell("C3_QUANT"):SetValue((cAliDado)->C3_QUANT)
			oSection2:Cell("C3_PRECO"):SetValue((cAliDado)->C3_PRECO)
			oSection2:Cell("C3_TOTAL"):SetValue((cAliDado)->C3_TOTAL)
			oSection2:Cell("C7_NUM"):SetValue((cAliDado)->C7_NUM)
			oSection2:Cell("C7_ITEM"):SetValue((cAliDado)->C7_ITEM)
			oSection2:Cell("C7_QUANT"):SetValue((cAliDado)->C7_QUANT)
			oSection2:Cell("AUTORIZ"):SetValue((cAliDado)->AUTORIZ)
				
			oSection2:Printline()
	
			(cAliDado)->(DbSkip())
		EndDo
		oSection2:Finish()
		(cAliDado)->(DbCloseArea())
		
		(cAliSC3)->(DbSkip())
	EndDo
	oSection1:Finish()
	
	(cAliSC3)->(DbCloseArea())
Return