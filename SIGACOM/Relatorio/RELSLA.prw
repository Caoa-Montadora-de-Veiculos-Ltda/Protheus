#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} RELSLA
Relatório de SLA de Atendimento CAOA
@author FSW - DWC Consult
@since 01/12/2018
@version All
@type function
/*/
User Function RELSLA()
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
Função Auxiliar para Impressão do Relatório de SLA de Atendimento - CAOA
@author FSW - DWC Consult
@since 01/12/2018
@version All
@type function
/*/
Static Function ReportDef()
	Local cPerg		:= "RELSLA"
	Local cTitulo	:= "Relatório de SLA de Atendimento - CAOA"
	Local cDescrRel	:= "Este relatório apresentas as informações continas nas SC´s."
	Local oReport
	Local oSection1	

	//Carregas as variaveis MV_PAR.
	Pergunte(cPerg,.F.)

	oReport:= TReport():New("RELSLA", cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDescrRel)
	oReport:SetLandscape()			//Define orientação de pagina do relatório como paisagem.
	oReport:DisableOrientation()	//Desabilita a seleção da Orientação
	oReport:SetEnvironment(2) 		//Define o local de impressão 1- Servidor; 2-Local.

	oSection1:= TRSection():New(oReport, "SLA de Atendimento",{"SC1","SC7","SCR"}) //"SLA de Atendimento.
	oSection1:lHeaderVisible := .F.
	oSection1:SetReadOnly()

	TRCell():New(oSection1,"C1_GRUPCOM"	,"SC1"	,/*Descrição*/	 ,/*Picture*/,TamSx3("C1_GRUPCOM")[1]	,/*lPixel*/,/* {|| }*/)//"Grupo de Compras"
	TRCell():New(oSection1,"C1_NUM"		,"SC1"	,/*Descrição*/	 ,/*Picture*/,TamSx3("C1_NUM")[1]		,/*lPixel*/,/* {|| }*/)//"Numero da SC"
	TRCell():New(oSection1,"C1_ITEM"	,"SC1"	,/*Descrição*/	 ,/*Picture*/,TamSx3("C1_ITEM")[1]		,/*lPixel*/,/* {|| }*/)//"Item da SC"
	TRCell():New(oSection1,"C1_PRODUTO"	,"SC1"	,/*Descrição*/	 ,/*Picture*/,TamSx3("C1_PRODUTO")[1] 	,/*lPixel*/,/* {|| }*/)//"Produto"
	TRCell():New(oSection1,"C1_DESCRI"  ,"SC1"	,/*Descrição*/	 ,/*Picture*/,TamSx3("C1_DESCRI")[1] 	,/*lPixel*/,/* {|| }*/)//"Descrição"
	TRCell():New(oSection1,"CR_DATALIB"	,"SCR"	,'Data Aprov. SC',/*Picture*/,TamSx3("CR_DATALIB")[1] 	,/*lPixel*/,/* {|| }*/)//"Data de Aprovação SC"
	TRCell():New(oSection1,"C1_PEDIDO"  ,"SC1"	,/*Descrição*/	 ,/*Picture*/,TamSx3("C1_PEDIDO")[1] 	,/*lPixel*/,/* {|| }*/)//"Numero do Pedido de Compras"
	TRCell():New(oSection1,"C1_ITEMPED" ,"SC1"	,/*Descrição*/	 ,/*Picture*/,TamSx3("C1_ITEMPED")[1]	,/*lPixel*/,/* {|| }*/)//"Item do Pedido de Compras"
	TRCell():New(oSection1,"DTAPROVPC"	,""		,'Data Aprov. PC',/*Picture*/,TamSx3("CR_DATALIB")[1] 	,/*lPixel*/,/* {|| }*/)//"Data de Aprovação PC"
	TRCell():New(oSection1,"VENCSC"		,""		,'Vencimento SC' ,/*Picture*/,10		  			 	,/*lPixel*/,/* {|| }*/)//"Vencimento da SC "
	TRCell():New(oSection1,"STATUS"		,""		,'Status'		 ,/*Picture*/,15		  			 	,/*lPixel*/,/* {|| }*/)//"Status do SLA "

Return(oReport)

/*/{Protheus.doc} ReportPrint
Função para Auxiliar na Impressão do Relatório SLA de Atendimento - CAOA
@author FSW - DWC Consult
@since 01/12/2018
@version All
@param oReport, object, descricao
@type function
/*/
Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local cAliSC1 	:= GetNextAlias()
	Local cStatus	:= ""
	Local nTotal	:= 0
	Local dAprvPC	:= Nil

	If Select(cAliSC1) > 0
		(cAliSC1)->(DbCloseArea())
	EndIf		
	BeginSql Alias cAliSC1
		column CR_DATALIB	as Date
		column C1_EMISSAO	as Date
		
		SELECT
			CR_DATALIB,
			C1_EMISSAO,
			C1_GRUPCOM,
			C1_NUM,
			C1_ITEM,
			C1_PRODUTO,
			C1_DESCRI,
			C1_PEDIDO,
			C1_ITEMPED
		FROM %Table:SC1% C
		LEFT JOIN %Table:SCR% R ON R.%NotDel% AND R.CR_FILIAL = C.C1_FILIAL
											  AND R.CR_NUM = C.C1_NUM
											  AND R.CR_TIPO = 'SC'
		WHERE
				C.%NotDel%
			AND C.C1_FILIAL = %xFilial:SC1%
			AND C.C1_NUM 	 BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND C.C1_GRUPCOM BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND C.C1_PEDIDO <> ' '
			AND R.CR_DATALIB BETWEEN %Exp:DToS(MV_PAR05)% AND %ExP:DToS(MV_PAR06)%
		ORDER BY
			C1_GRUPCOM,C1_NUM,C1_ITEM
	EndSql
	Count To nTotal
	
	DbSelectArea(cAliSC1)
	(cAliSC1)->(DbGoTop())
	
	oReport:SetMeter(nTotal)
	
	oSection1:Init()
	
	While !(cAliSC1)->(EOF())
		
		oReport:IncMeter()
		
		oSection1:Cell("C1_GRUPCOM"):SetValue((cAliSC1)->C1_GRUPCOM)
		oSection1:Cell("C1_NUM"):SetValue((cAliSC1)->C1_NUM)
		oSection1:Cell("C1_ITEM"):SetValue((cAliSC1)->C1_ITEM)
		oSection1:Cell("C1_PRODUTO"):SetValue((cAliSC1)->C1_PRODUTO)
		oSection1:Cell("C1_DESCRI"):SetValue((cAliSC1)->C1_DESCRI)
		oSection1:Cell("CR_DATALIB"):SetValue((cAliSC1)->CR_DATALIB)
		oSection1:Cell("C1_PEDIDO"):SetValue((cAliSC1)->C1_PEDIDO)
		oSection1:Cell("C1_ITEMPED"):SetValue((cAliSC1)->C1_ITEMPED)
		
		//Função para retornar a data de aprovação do PC.
		dAprvPC := FunAux01((cAliSC1)->C1_PEDIDO)
		
		//Calcula o Vencimento da SC. Data da Aprovação da SC + Prazo
		dVencSC := (cAliSC1)->CR_DATALIB + Val(MV_PAR07)
		
		oSection1:Cell("DTAPROVPC"):SetValue(dAprvPC)
		oSection1:Cell("VENCSC"):SetValue(dVencSC)
		
		//Checa se está dentro ou fora do SLA.
		If dAprvPC > dVencSC
			cStatus := "Fora do SLA"
		Else
			cStatus := "Dentro do SLA"
		EndIf
		
		oSection1:Cell("STATUS"):SetValue(cStatus)
		
		oSection1:Printline()

		(cAliSC1)->(DbSkip())
	EndDo
	oSection1:Finish()

	(cAliSC1)->(DbCloseArea())
Return

/*/{Protheus.doc} FunAux01
Função Auxiliar 01 - Utilizada para retornar a Data de Aprovação do Pedido de Compras.
@author FSW - DWC Consult
@since 01/12/2018
@version All
@param cPedCom, characters, descricao
@type function
/*/
Static Function FunAux01(cPedCom)
	Local cDtLibPc	:= "" 
	Local cAliSCR	:= GetNextAlias()

	If Select(cAliSCR) > 0
		(cAliSCR)->(DbCloseArea())
	EndIf		
	BeginSql Alias cAliSCR
		column DTLIBPC	as Date
		
		SELECT
			CR_DATALIB AS DTLIBPC
		FROM %Table:SCR% C
		WHERE
				C.%NotDel%
			AND C.CR_FILIAL = %xFilial:SCR%
			AND C.CR_NUM = %Exp:cPedCom%
			AND C.CR_TIPO IN ('PC','IP')
		GROUP BY
			CR_DATALIB
	EndSql
	
	cDtLibPc := (cAliSCR)->DTLIBPC

	(cAliSCR)->(DbCloseArea())
Return(cDtLibPc)