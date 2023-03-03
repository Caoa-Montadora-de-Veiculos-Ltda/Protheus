#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'TOPCONN.ch'

/*
Programa..: ZCOMR003.PRW
Objetivo..: Imprimi as solicitações de compras geradas com base em uma planilha no formato .CSV
Autor.....: Sandro Ferreira
Data/Hora.: 04/01/2022  
Obs.......:
*/

user function ZCOMR003() 

	Local lProcessa := .T.

	Private oReport
	
	If !(IsInCallStack("U_ZCOMR003"))
		If !(Pergunte("ZCOMR003",.T.))
			Return
		EndIf
	EndIf
	
	If !TRepInUse()
		Alert("A Impressão em TREPORT deverá estar habilitada. Favor verificar o parâmetro MV_TREPORT.")
		lProcessa := .F.
	EndIf

	If lProcessa
		oReport:= ReportDef()
		oReport:PrintDialog()
	EndIf
	
return

Static Function ReportDef()
	Local cPerg			:= "RELIMPSC"
	Local cTitulo		:= "Relatório de Acompanhamento de SC - CAOA"
	Local cDescrRel		:= "Este relatório apresentas as informações continas nas SC´s."
	Local oReport
	Local oSection1
	Local oSection2	
	
	Private oBreak

	//Carregas as variaveis MV_PAR.
	Pergunte(cPerg,.F.)
	
	oReport:= TReport():New("ZCOMR003", cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDescrRel)
	oReport:SetLandscape()			//Define orientação de pagina do relatório como paisagem.
	oReport:DisableOrientation()	//Desabilita a seleção da Orientação
	oReport:SetEnvironment(2) 		//Define o local de impressão 1- Servidor; 2-Local.

	oSection1:= TRSection():New(oReport, "SC",{"SC1"}) //"Solicitação de Compra
	oSection1:lHeaderVisible := .F.
	oSection1:SetReadOnly()

	TRCell():New(oSection1,"C1_NUM"		,"SC1"	,/*Descrição*/	,/*Picture*/,TamSx3("C1_NUM")[1]		,/*lPixel*/,/* {|| }*/)//"Numero da SC"
	TRCell():New(oSection1,"C1_SOLICIT" ,"SC1"	,/*Descrição*/	,/*Picture*/,TamSx3("C1_SOLICIT")[1]	,/*lPixel*/,/* {|| }*/)//"Solicitante"
	TRCell():New(oSection1,"C1_EMISSAO"	,"SC1"	,/*Descrição*/	,/*Picture*/,TamSx3("C1_EMISSAO")[1]	,/*lPixel*/,/* {|| }*/)//"Emissão"

	oSection2:= TRSection():New(oReport, "Itens da SC",{"SC1"}) //"Itens da Solicitação de Compra
	oSection2:lHeaderVisible := .F.
	oSection2:SetReadOnly()

	TRCell():New(oSection2,"C1_ITEM"	,"SC1"	,'Item SC'			,/*Picture*/,TamSx3("C1_ITEM")[1]		,/*lPixel*/,/* {|| }*/)//"Item da SC"
	TRCell():New(oSection2,"C1_PRODUTO"	,"SC1"	,/*Descrição*/		,/*Picture*/,TamSx3("C1_PRODUTO")[1] 	,/*lPixel*/,/* {|| }*/)//"Produto"
	TRCell():New(oSection2,"C1_DESCRI"  ,"SC1"	,/*Descrição*/		,/*Picture*/,TamSx3("C1_DESCRI")[1] 	,/*lPixel*/,/* {|| }*/)//"Descrição"
	TRCell():New(oSection2,"C1_QUANT"   ,"SC1"	,/*Descrição*/		,/*Picture*/,TamSx3("C1_QUANT")[1] 		,/*lPixel*/,/* {|| }*/)//"Quantidade"
	TRCell():New(oSection2,"C1_DATPRF"  ,"SC1"	,/*Descrição*/		,/*Picture*/,TamSx3("C1_DATPRF")[1] 	,/*lPixel*/,/* {|| }*/)//"Data da Necessidade"
	TRCell():New(oSection2,"C1_CC"      ,"SC1"	,/*Descrição*/		,/*Picture*/,TamSx3("C1_CC")[1] 		,/*lPixel*/,/* {|| }*/)//"Centro de Custos"
	TRCell():New(oSection2,"C1_XOBSITE" ,"SC1"	,/*Descrição*/		,/*Picture*/,TamSx3("C1_XOBSITE")[1]    ,/*lPixel*/,/* {|| }*/)//"Observação do Item da SC

 
	oBreak  := TRBreak():New(oSection1,{ || oSection1:Cell('C1_NUM'):uPrint },,.F.,,.T.)

	TRFunction():New(oSection2:CELL("C1_QUANT")   ,           ,   "SUM"   ,oBreak     ,"Quant Itens" , "@E 99,999,999"          ,         ,      .T.    ,     .F.    ,    .F.  ,          ,             ,          ,     , )

Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local cAliSC1 	:= GetNextAlias()
	Local cKey		:= ""
	Local nTotal	:= 0
	Local cSCDe		:= MV_PAR01
	Local cSCAte	:= MV_PAR02
	
	If IsInCallStack("U_ZCOMF043")
		 cSCDe := cxSCDe
		 cSCAte := cxSCAte
		 MV_PAR01 := cxSCDe
		 MV_PAR02 := cxSCAte
	EndIf
	
	If Select(cAliSC1) > 0
		(cAliSC1)->(DbCloseArea())
	EndIf	
	BeginSql Alias cAliSC1
		column C1_EMISSAO	as Date
		column C1_DATPRF    as Date
 
		SELECT
			SC1.C1_NUM,		
			SC1.C1_SOLICIT,
			SC1.C1_EMISSAO,
            SC1.C1_DATPRF,
			SC1.C1_ITEM,	
			SC1.C1_CC,
			UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C1_XOBSITE, 2000, 1)) AS C1_XOBSITE,
			SC1.C1_PRODUTO,
			SC1.C1_DESCRI,
			SC1.C1_QUANT, 
			SC1.C1_XVLUNIT,
			SC1.C1_FORNECE,
			SC1.C1_LOJA,  
			SC1.C1_FABR, 
			SC1.C1_FABRLOJ
		FROM %Table:SC1% SC1
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

		//Inicia a Impressão da 2ª Section.
		oSection2:Init()

		While !(cAliSC1)->(EOF()) .And. (cAliSC1)->C1_NUM == cKey
	
			oSection2:Cell("C1_ITEM"):SetValue((cAliSC1)->C1_ITEM)
			oSection2:Cell("C1_PRODUTO"):SetValue((cAliSC1)->C1_PRODUTO)
			oSection2:Cell("C1_DESCRI"):SetValue((cAliSC1)->C1_DESCRI)
			oSection2:Cell("C1_QUANT"):SetValue((cAliSC1)->C1_QUANT)
			oSection2:Cell("C1_DATPRF"):SetValue((cAliSC1)->C1_DATPRF)
			oSection2:Cell("C1_CC"):SetValue((cAliSC1)->C1_CC)
			oSection2:Cell("C1_XOBSITE"):SetValue((cAliSC1)->C1_XOBSITE)

			oSection2:Printline()

			(cAliSC1)->(DbSkip())
		EndDo
		oSection2:Finish()

	EndDo
	oSection1:Finish()

	(cAliSC1)->(DbCloseArea())
Return
  