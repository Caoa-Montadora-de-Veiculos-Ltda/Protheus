#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} RELACOMP
Relatório de Acompanhamento das SC´s - CAOA.
@author FSW - DWC Consult
@since 25/11/2018
@version All
@type function
/*/
User Function RELACOMP()
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
Função Auxiliar para impressão do Relatório de Acompanhamento das SC´s - CAOA.
@author FSW - DWC Consult
@since 25/11/2018
@version All
@type function
/*/
Static Function ReportDef()
	Local cPerg			:= "RELACOMP"
	Local cTitulo		:= "Relatório de Acompanhamento de SC - CAOA"
	Local cDescrRel		:= "Este relatório apresentas as informações continas nas SC´s."
	Local oReport
	Local oSection1
	Local oSection2	
	
	Private oBreak

	//Carregas as variaveis MV_PAR.
	Pergunte(cPerg,.F.)
	
	oReport:= TReport():New("RELACOMP", cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDescrRel)
	oReport:SetLandscape()			//Define orientação de pagina do relatório como paisagem.
	oReport:DisableOrientation()	//Desabilita a seleção da Orientação
	oReport:SetEnvironment(2) 		//Define o local de impressão 1- Servidor; 2-Local.

	oSection1:= TRSection():New(oReport, "Acompanhamento de SC",{"SC1"}) //"Solicitação de Compra
	oSection1:lHeaderVisible := .F.
	oSection1:SetReadOnly()

	TRCell():New(oSection1,"C1_NUM"		,"SC1"	,/*Descrição*/	,/*Picture*/,TamSx3("C1_NUM")[1]		,/*lPixel*/,/* {|| }*/)//"Numero da SC"
	TRCell():New(oSection1,"C1_SOLICIT" ,"SC1"	,/*Descrição*/	,/*Picture*/,TamSx3("C1_SOLICIT")[1]	,/*lPixel*/,/* {|| }*/)//"Solicitante"
	TRCell():New(oSection1,"C1_EMISSAO"	,"SC1"	,/*Descrição*/	,/*Picture*/,TamSx3("C1_EMISSAO")[1]	,/*lPixel*/,/* {|| }*/)//"Emissão"

	oSection2:= TRSection():New(oReport, "Itens da SC",{"SC1","SCR","CTT"}) //"Itens da Solicitação de Compra
	oSection2:lHeaderVisible := .F.
	oSection2:SetReadOnly()

	TRCell():New(oSection2,"CR_DATALIB"	,"SCR"	,'Data Aprov SC'	,/*Picture*/,TamSx3("CR_DATALIB")[1] 	,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection2,"C1_ITEM"	,"SC1"	,'Item SC'			,/*Picture*/,TamSx3("C1_ITEM")[1]		,/*lPixel*/,/* {|| }*/)//"Item da SC"
	TRCell():New(oSection2,"C1_PRODUTO"	,"SC1"	,/*Descrição*/		,/*Picture*/,TamSx3("C1_PRODUTO")[1] 	,/*lPixel*/,/* {|| }*/)//"Produto"
	TRCell():New(oSection2,"C1_DESCRI"  ,"SC1"	,/*Descrição*/		,/*Picture*/,TamSx3("C1_DESCRI")[1] 	,/*lPixel*/,/* {|| }*/)//"Descrição"
	TRCell():New(oSection2,"C1_TPSC"	,"SC1"	,'Tipo SC'			,/*Picture*/,TamSx3("C1_TPSC")[1]		,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection2,"C1_GRUPCOM"	,"SC1"	,/*Descrição*/		,/*Picture*/,TamSx3("C1_GRUPCOM")[1]	,/*lPixel*/,/* {|| }*/)//"Grupo de Compras"
	TRCell():New(oSection2,"C1_CC"   	,"SC1"	,/*Descrição*/		,/*Picture*/,TamSx3("C1_CC")[1] 		,/*lPixel*/,/* {|| }*/)//"Centro de Custo"
	TRCell():New(oSection2,"CTT_DESC01" ,"CTT"	,'Descrição CC'		,/*Picture*/,TamSx3("CTT_DESC01")[1]	,/*lPixel*/,/* {|| }*/)//"Descrição do CC"
	TRCell():New(oSection2,"C1_APROV" 	,"SC1"	,/*Descrição*/		,/*Picture*/,TamSx3("C1_APROV")[1]		,/*lPixel*/,/* {|| }*/)//"Aprovado"
	TRCell():New(oSection2,"C1_RESIDUO" ,"SC1"	,/*Descrição*/		,/*Picture*/,TamSx3("C1_RESIDUO")[1] 	,/*lPixel*/,/* {|| }*/)//"Residuo"
	TRCell():New(oSection2,"C1_PEDIDO"  ,"SC1"	,/*Descrição*/		,/*Picture*/,TamSx3("C1_PEDIDO")[1] 	,/*lPixel*/,/* {|| }*/)//"Numero do Pedido de Compras"
	TRCell():New(oSection2,"C1_ITEMPED" ,"SC1"	,/*Descrição*/		,/*Picture*/,TamSx3("C1_ITEMPED")[1]	,/*lPixel*/,/* {|| }*/)//"Item do Pedido de Compras"
	TRCell():New(oSection2,"SALDODIAS"	,""		,'Saldo de Dias'	,/*Picture*/,10		  			 		,/*lPixel*/,/* {|| }*/)//"Saldo de Dias "

	oBreak  := TRBreak():New(oSection1,{ || oSection1:Cell('C1_NUM'):uPrint },,.F.,,.T.)

Return(oReport)

/*/{Protheus.doc} ReportPrint
Função Auxiliar para impressão do Relatório de Acompanhamento das SC´s - CAOA.
@author FSW - DWC Consult
@since 25/11/2018
@version All
@param oReport, object, descricao
@type function
/*/
Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cAliSC1 	:= GetNextAlias()
	Local cSldDia	:= ""
	Local cKey		:= ""
	Local nTotal	:= 0

	If Select(cAliSC1) > 0
		(cAliSC1)->(DbCloseArea())
	EndIf	
	BeginSql Alias cAliSC1
		column CR_DATALIB	as Date
		column C1_EMISSAO	as Date

		SELECT
			CR_DATALIB,
			C1_EMISSAO,
			C1_NUM,
			C1_ITEM,
			C1_TPSC,
			C1_GRUPCOM,
			C1_PRODUTO,
			C1_DESCRI,
			C1_CC,
			CTT_DESC01,
			C1_SOLICIT,
			C1_APROV,
			C1_RESIDUO,
			C1_PEDIDO,
			C1_ITEMPED
		FROM %Table:SC1% C
		LEFT JOIN %Table:SCR% R ON R.%NotDel% AND R.CR_FILIAL = C.C1_FILIAL
											  AND R.CR_NUM = C.C1_NUM
											  AND R.CR_TIPO = 'SC'
											  AND R.CR_DATALIB BETWEEN %Exp:DToS(MV_PAR05)% AND %ExP:DToS(MV_PAR06)%
		LEFT JOIN %Table:CTT% T ON T.%NotDel% AND T.CTT_FILIAL = %xFilial:CTT%
											  AND T.CTT_CUSTO = C.C1_CC 
		WHERE
				C.%NotDel%
			AND C.C1_FILIAL = %xFilial:SC1%
			AND C.C1_NUM 	 BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND C.C1_GRUPCOM BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND C.C1_PEDIDO  BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
		ORDER BY
			C1_NUM,C1_ITEM
	EndSql
	Count To nTotal
	
	DbSelectArea(cAliSC1)
	(cAliSC1)->(DbGoTop())
	
	oReport:SetMeter(nTotal)
	
	oSection1:Init()
	
	While !(cAliSC1)->(EOF())
		
		oReport:IncMeter()
		
		cKey := (cAliSC1)->C1_NUM
		
		oSection1:Cell("C1_NUM"):SetValue((cAliSC1)->C1_NUM)
		oSection1:Cell("C1_SOLICIT"):SetValue((cAliSC1)->C1_SOLICIT)
		oSection1:Cell("C1_EMISSAO"):SetValue((cAliSC1)->C1_EMISSAO)
		oSection1:Printline()

		//Inicia a Impressão da 2ª Section.
		oSection2:Init()

		While !(cAliSC1)->(EOF()) .And. (cAliSC1)->C1_NUM == cKey

			oSection2:Cell("CR_DATALIB"):SetValue((cAliSC1)->CR_DATALIB)
			oSection2:Cell("C1_ITEM"):SetValue((cAliSC1)->C1_ITEM)
			oSection2:Cell("C1_PRODUTO"):SetValue((cAliSC1)->C1_PRODUTO)
			oSection2:Cell("C1_DESCRI"):SetValue((cAliSC1)->C1_DESCRI)
			oSection2:Cell("C1_TPSC"):SetValue((cAliSC1)->C1_TPSC)
			oSection2:Cell("C1_GRUPCOM"):SetValue((cAliSC1)->C1_GRUPCOM)
			oSection2:Cell("C1_CC"):SetValue((cAliSC1)->C1_CC)
			oSection2:Cell("CTT_DESC01"):SetValue((cAliSC1)->CTT_DESC01)
			oSection2:Cell("C1_APROV"):SetValue((cAliSC1)->C1_APROV)
			oSection2:Cell("C1_RESIDUO"):SetValue((cAliSC1)->C1_RESIDUO)
			oSection2:Cell("C1_PEDIDO"):SetValue((cAliSC1)->C1_PEDIDO)
			oSection2:Cell("C1_ITEMPED"):SetValue((cAliSC1)->C1_ITEMPED)

			//Calcula o Saldo de dias.
			If ! Empty((cAliSC1)->CR_DATALIB)
				cSldDia := (cAliSC1)->CR_DATALIB + Val(MV_PAR09) - Date()
			Else
				cSldDia := 0
			EndIf

			oSection2:Cell("SALDODIAS"):SetValue(cSldDia)

			oSection2:Printline()

			(cAliSC1)->(DbSkip())
		EndDo
		oSection2:Finish()

	EndDo
	oSection1:Finish()

	(cAliSC1)->(DbCloseArea())
Return