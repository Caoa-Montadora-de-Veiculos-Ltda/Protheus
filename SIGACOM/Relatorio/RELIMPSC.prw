#include 'protheus.ch'
#include 'parmtype.ch'

user function RELIMPSC()

	Local lProcessa := .T.

	Private oReport
	
	If !(IsInCallStack("U_IMPCSV"))
		If !(Pergunte("RELIMPSC",.T.))
			Return
		EndIf
	EndIf
	
	If !TRepInUse()
		Alert("A Impress�o em TREPORT dever� estar habilitada. Favor verificar o par�metro MV_TREPORT.")
		lProcessa := .F.
	EndIf

	If lProcessa
		oReport:= ReportDef()
		oReport:PrintDialog()
	EndIf
	
return

Static Function ReportDef()
	Local cPerg			:= "RELIMPSC"
	Local cTitulo		:= "Relat�rio de Acompanhamento de SC - CAOA"
	Local cDescrRel		:= "Este relat�rio apresentas as informa��es continas nas SC�s."
	Local oReport
	Local oSection1
	Local oSection2	
	
	Private oBreak

	//Carregas as variaveis MV_PAR.
	Pergunte(cPerg,.F.)
	
	oReport:= TReport():New("RELIMPSC", cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDescrRel)
	oReport:SetLandscape()			//Define orienta��o de pagina do relat�rio como paisagem.
	oReport:DisableOrientation()	//Desabilita a sele��o da Orienta��o
	oReport:SetEnvironment(2) 		//Define o local de impress�o 1- Servidor; 2-Local.

	oSection1:= TRSection():New(oReport, "SC",{"SC1"}) //"Solicita��o de Compra
	oSection1:lHeaderVisible := .F.
	oSection1:SetReadOnly()

	TRCell():New(oSection1,"C1_NUM"		,"SC1"	,/*Descri��o*/	,/*Picture*/,TamSx3("C1_NUM")[1]		,/*lPixel*/,/* {|| }*/)//"Numero da SC"
	TRCell():New(oSection1,"C1_SOLICIT" ,"SC1"	,/*Descri��o*/	,/*Picture*/,TamSx3("C1_SOLICIT")[1]	,/*lPixel*/,/* {|| }*/)//"Solicitante"
	TRCell():New(oSection1,"C1_EMISSAO"	,"SC1"	,/*Descri��o*/	,/*Picture*/,TamSx3("C1_EMISSAO")[1]	,/*lPixel*/,/* {|| }*/)//"Emiss�o"

	oSection2:= TRSection():New(oReport, "Itens da SC",{"SC1","SA2","SA5"}) //"Itens da Solicita��o de Compra
	oSection2:lHeaderVisible := .F.
	oSection2:SetReadOnly()

	TRCell():New(oSection2,"C1_ITEM"	,"SC1"	,'Item SC'			,/*Picture*/,TamSx3("C1_ITEM")[1]		,/*lPixel*/,/* {|| }*/)//"Item da SC"
	TRCell():New(oSection2,"C1_PRODUTO"	,"SC1"	,/*Descri��o*/		,/*Picture*/,TamSx3("C1_PRODUTO")[1] 	,/*lPixel*/,/* {|| }*/)//"Produto"
	TRCell():New(oSection2,"C1_DESCRI"  ,"SC1"	,/*Descri��o*/		,/*Picture*/,TamSx3("C1_DESCRI")[1] 	,/*lPixel*/,/* {|| }*/)//"Descri��o"
	TRCell():New(oSection2,"C1_QUANT"   ,"SC1"	,/*Descri��o*/		,/*Picture*/,TamSx3("C1_QUANT")[1] 		,/*lPixel*/,/* {|| }*/)//"Quantidade"
	TRCell():New(oSection2,"C1_XVLUNIT" ,"SC1"	,/*Descri��o*/		,/*Picture*/,TamSx3("C1_XVLUNIT")[1] 	,/*lPixel*/,/* {|| }*/)//"Valor Unitario"
	TRCell():New(oSection2,"C1_TOTAL"   ,"SC1"	,/*Descri��o*/		,/*Picture*/,TamSx3("C1_TOTAL")[1] 	    ,/*lPixel*/,/* {|| }*/)//"Total"	
	TRCell():New(oSection2,"C1_FORNECE" ,"SC1"	,/*Descri��o*/		,/*Picture*/,TamSx3("C1_FORNECE")[1] 	,/*lPixel*/,/* {|| }*/)//"Fornecedor"
	TRCell():New(oSection2,"C1_LOJA"  	,"SC1"	,/*Descri��o*/		,/*Picture*/,TamSx3("C1_LOJA")[1] 		,/*lPixel*/,/* {|| }*/)//"Loja Fornecedor"
	TRCell():New(oSection2,"A2_NREDUZ"  ,"SA2"	,/*Descri��o*/		,/*Picture*/,TamSx3("A2_NREDUZ")[1] 	,/*lPixel*/,/* {|| }*/)//"Nome Reduzido Fornecedor"
	TRCell():New(oSection2,"C1_FABR"  	,"SC1"	,/*Descri��o*/		,/*Picture*/,TamSx3("C1_FABR")[1] 		,/*lPixel*/,/* {|| }*/)//"Fabricante"
	TRCell():New(oSection2,"C1_FABRLOJ" ,"SC1"	,/*Descri��o*/		,/*Picture*/,TamSx3("C1_FABRLOJ")[1] 	,/*lPixel*/,/* {|| }*/)//"Loja Fabricante"
	TRCell():New(oSection2,"A5_FABRRED" ,"SA5"	,/*Descri��o*/		,/*Picture*/,TamSx3("A5_FABRRED")[1] 	,/*lPixel*/,/* {|| }*/)//"Nome Reduzido Fabricante"

	oBreak  := TRBreak():New(oSection1,{ || oSection1:Cell('C1_NUM'):uPrint },,.F.,,.T.)

	TRFunction():New(oSection2:CELL("C1_QUANT")   ,           ,   "SUM"   ,oBreak     ,"Quant Itens" , "@E 99,999,999"          ,         ,      .T.    ,     .F.    ,    .F.  ,          ,             ,          ,     , )
	TRFunction():New(oSection2:CELL("C1_TOTAL")   ,           ,   "SUM"   ,oBreak     ,"Total SC"    , "@E 999,999,999,999.99"  ,         ,      .T.    ,     .F.    ,         ,          ,             ,          ,     , )

Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cAliSC1 	:= GetNextAlias()
	Local cSldDia	:= ""
	Local cKey		:= ""
	Local nTotal	:= 0
	Local cNomFabr  := ""
	
	Local cSCDe		:= MV_PAR01
	Local cSCAte	:= MV_PAR02
	
	If IsInCallStack("U_IMPCSV")
		 cSCDe := cxSCDe
		 cSCAte := cxSCAte
	EndIf
	
	If Select(cAliSC1) > 0
		(cAliSC1)->(DbCloseArea())
	EndIf	
	BeginSql Alias cAliSC1
		column C1_EMISSAO	as Date

		SELECT
			SC1.C1_NUM,		
			SC1.C1_SOLICIT,
			SC1.C1_EMISSAO,
			SC1.C1_ITEM,	
			SC1.C1_PRODUTO,
			SC1.C1_DESCRI,
			SC1.C1_QUANT, 
			SC1.C1_XVLUNIT,
			SC1.C1_FORNECE,
			SC1.C1_LOJA,  
			SA2.A2_NREDUZ,
			SC1.C1_FABR, 
			SC1.C1_FABRLOJ
		FROM %Table:SC1% SC1
		INNER JOIN %Table:SA2% SA2 
			 ON	SA2.A2_FILIAL = %xFilial:SA2%
			AND SA2.A2_COD    = SC1.C1_FORNECE
			AND SA2.A2_LOJA   = SC1.C1_LOJA
			AND SA2.%NotDel%
		WHERE
				SC1.%NotDel%
			AND SC1.C1_FILIAL = %xFilial:SC1%
			AND SC1.C1_NUM BETWEEN %Exp:cSCDe% AND %Exp:cSCAte%
			
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

		//Inicia a Impress�o da 2� Section.
		oSection2:Init()

		While !(cAliSC1)->(EOF()) .And. (cAliSC1)->C1_NUM == cKey
			
			cNomFabr := Posicione("SA2",1,xFilial("SA2") + (cAliSC1)->C1_FABR + (cAliSC1)->C1_FABRLOJ, "A2_NREDUZ" )
			
			oSection2:Cell("C1_ITEM"):SetValue((cAliSC1)->C1_ITEM)
			oSection2:Cell("C1_PRODUTO"):SetValue((cAliSC1)->C1_PRODUTO)
			oSection2:Cell("C1_DESCRI"):SetValue((cAliSC1)->C1_DESCRI)
			oSection2:Cell("C1_QUANT"):SetValue((cAliSC1)->C1_QUANT)
			oSection2:Cell("C1_XVLUNIT"):SetValue((cAliSC1)->C1_XVLUNIT)
			oSection2:Cell("C1_FORNECE"):SetValue((cAliSC1)->C1_FORNECE)
			oSection2:Cell("C1_LOJA"):SetValue((cAliSC1)->C1_LOJA)
			oSection2:Cell("A2_NREDUZ"):SetValue((cAliSC1)->A2_NREDUZ)
			oSection2:Cell("C1_FABR"):SetValue((cAliSC1)->C1_FABR)
			oSection2:Cell("C1_FABRLOJ"):SetValue((cAliSC1)->C1_FABRLOJ)
			oSection2:Cell("A5_FABRRED"):SetValue(cNomFabr)
			oSection2:Cell("C1_TOTAL"):SetValue((cAliSC1)->C1_QUANT * (cAliSC1)->C1_XVLUNIT )

			oSection2:Printline()

			(cAliSC1)->(DbSkip())
		EndDo
		oSection2:Finish()

	EndDo
	oSection1:Finish()

	(cAliSC1)->(DbCloseArea())
Return