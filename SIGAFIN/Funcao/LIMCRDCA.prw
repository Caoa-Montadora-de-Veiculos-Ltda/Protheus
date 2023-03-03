#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} LIMCRDCA
	Relatório de Limite de Crédito - CAOA
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		17/02/2019
	@version 	1.0
	// @param 		param_name, param_type, param_description
	@return 	NIL, Nulo *(nenhum)*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
User Function LIMCRDCA()
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
	Função Auxiliar para Impressão do Relatório - CAOA
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		17/02/2019
	@version 	1.0
	// @param 		param_name, param_type, param_description
	@return 	NIL, Nulo *(nenhum)*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Static Function ReportDef()
	Local cPerg		:= "RELCRD"
	Local cTitulo	:= "Relatório de Limite de Crédito - CAOA"
	Local cDescrRel	:= "Relatório com os limites de crédito dos clientes."
	Local oReport
	Local oSection1

	//Carregas as variaveis MV_PAR.
	Pergunte(cPerg,.F.)

	oReport:= TReport():New("RELCRD", cTitulo, cPerg, {|oReport| RepPrint(oReport)}, cDescrRel)
	oReport:SetLandscape()			//Define orientação de pagina do relatório como paisagem.
	oReport:DisableOrientation()	//Desabilita a seleção da Orientação
	oReport:SetEnvironment(2) 		//Define o local de impressão 1- Servidor; 2-Local.

	oSection1:= TRSection():New(oReport, "Limite de Crédito",{"SA1"})
	oSection1:lHeaderVisible := .F.
	oSection1:SetReadOnly()

	TRCell():New(oSection1,"A1_IDENT"	 ,""	,'Identificação'		,/*Picture*/				,TamSx3("A1_CGC")[1] + 10	,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"A1_NOME"	 ,"SA1"	,'Razão Social'			,/*Picture*/				,TamSx3("A1_NOME")[1]		,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"STATCLI"	 ,""	,'Status do Cliente'	,/*Picture*/				,TamSx3("A1_NOME")[1]		,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"CREDITO"	 ,""	,'Limite de Crédito'	,PesqPict("SA1","A1_LC")	,TamSx3("A1_LC")[1]			,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"A1_VENCLC"	 ,"SA1"	,'Vencimento Limite'	,/*Picture*/				,TamSx3("A1_VENCLC")[1]		,/*lPixel*/,/* {|| }*/)
	TRCell():New(oSection1,"SALDO" 		 ,""	,'Saldo do Crédito'		,PesqPict("SA1","A1_LC")	,TamSx3("A1_LC")[1]			,/*lPixel*/,/* {|| }*/)

Return(oReport)

/*/{Protheus.doc} RepPrint
	Função Auxiliar 2 para impressão do Relatório - CAOA.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult; CAOA - denis.galvani - Denis A. Galvani
	@since 		17/02/2019
	@version 	2.0
	@param 		oReport		, object	, Objeto TReport
	@return 	NIL, Nulo *(nenhum)*
	@history 	            , denis.galvani, Desconsiderar *Títulos de Crédito* - Tipos *RA* *(Antecipação)* e *NCC* *(Devolução)*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	@history 	26/08/2020	, denis.galvani, Ajustes na passagem de parâmetros (ordem) aos métodos da classe
	/*/
Static Function RepPrint(oReport)
	Local oSection1  := oReport:Section(1)
	Local cAliSA1 	 := ""
	Local cAliFim	 := GetNextAlias()
	Local cAliTmp	 := GetNextAlias()
	Local cCNPJ		 := ""
	Local cCliente	 := ""
	Local cLoja		 := ""
	Local cTipoCli	 := ""
	Local cStatCli	 := ""
	Local cTabSX5	 := "ZA"
	Local nTotal	 := 0
	Local nValCred	 := 0
	Local nTitOpen	 := 0
	Local nSaldo	 := 0
	// Local nVlRANCC	 := 0 // TÍTULOS DE CRÉDITO - DESCONSIDERADOS
	Local aConSql	 := {}
	Local lCliLoj	 := .F.
	Local oTemptable := Nil
	Local oClasCrd	 := Nil

	Local aSX5		 := {}

	Private aTabSA1  := {}

	If Select(cAliTmp) > 0
		(cAliTmp)->(DbCloseArea())
	EndIf
	///////////////////////////////////////////
	//     Estrutura da Tabela Temporária    //
	//---------------------------------------//
	// NOME , TIPO_CAMPO , TAMANHO , DECIMAL //
	///////////////////////////////////////////
	AAdd(aTabSA1,{"TMP_A1FIL",	TamSx3("A1_FILIAL") [3],	TamSx3("A1_FILIAL") [1],	TamSx3("A1_FILIAL") [2]} )
	AAdd(aTabSA1,{"TMP_A1_ID",	'N'					   ,	1					   ,	0					   } )
	AAdd(aTabSA1,{"TMP_A1COD",	TamSx3("A1_COD")	[3],	TamSx3("A1_COD")	[1],	TamSx3("A1_COD")	[2]} )
	AAdd(aTabSA1,{"TMP_A1LOJ",	TamSx3("A1_LOJA")	[3],	TamSx3("A1_LOJA")	[1],	TamSx3("A1_LOJA")	[2]} )
	AAdd(aTabSA1,{"TMP_A1RAZ",	'C'					   ,	8					   ,	0					   } )
	AAdd(aTabSA1,{"TMP_A1STA",	TamSx3("A1_XSTATUS")[3],	TamSx3("A1_XSTATUS")[1],	TamSx3("A1_XSTATUS")[2]} )
	AAdd(aTabSA1,{"TMP_A1DTL",	TamSx3("A1_VENCLC") [3],	TamSx3("A1_VENCLC")	[1],	TamSx3("A1_VENCLC")	[2]} )
	AAdd(aTabSA1,{"TMP_A1GRP",	TamSx3("A1_XDESGRP")[3],	TamSx3("A1_XDESGRP")[1],	TamSx3("A1_XDESGRP")[2]} )

	//Cria a Tabela Temporaria no BD.
	oTemptable := FwTemporaryTable():New( cAliTmp )
	oTemptable:SetFields( aTabSA1 )
	oTempTable:AddIndex("IndSA1", {"TMP_A1FIL","TMP_A1_ID"} )
	oTempTable:Create()

	//Tratamento para informar os Tipos de Cliente em branco.
	If !Empty(MV_PAR01)
		cTipoCli := FormatIn( StrTran( Left(MV_PAR01,Len(AllTrim(MV_PAR01))-1) ,"'","") ,";")
	EndIf

	//Tratamento para informar os Status de Cliente em branco.
	If !Empty(MV_PAR02)
		cStatCli := FormatIn( StrTran( Left(MV_PAR02,Len(AllTrim(MV_PAR02))-1) ,"'","") ,";")
	EndIf

	//Monta a Regua.
	oReport:IncMeter()

	//Efetua a consulta dos Registros.
	aConSql := FSqlRel(cStatCli,cTipoCli)

	If Len(aConSql) > 0
		cAliSA1 := aConSql[1]
		nTotal	:= aConSql[2]
	Else
		Return
	EndIf

	oReport:SetMeter(nTotal)

	(cAliSA1)->(DbGoTop())

	While !(cAliSA1)->(EOF())

		oReport:IncMeter()

		RecLock(cAliTmp,.T.)
		(cAliTmp)->TMP_A1FIL := xFilial("SA1")
		(cAliTmp)->TMP_A1_ID := (cAliSA1)->ID
		(cAliTmp)->TMP_A1COD := (cAliSA1)->A1_COD
		(cAliTmp)->TMP_A1LOJ := (cAliSA1)->A1_LOJA
		(cAliTmp)->TMP_A1RAZ := (cAliSA1)->A1_RAIZ
		(cAliTmp)->TMP_A1STA := (cAliSA1)->A1_XSTATUS
		(cAliTmp)->TMP_A1DTL := SToD((cAliSA1)->A1_VENCLC)
		(cAliTmp)->TMP_A1GRP := (cAliSA1)->A1_XDESGRP
		(cAliTmp)->(MsUnLock())

		(cAliSA1)->(DbSkip())
	EndDo
	(cAliSA1)->(DbCloseArea())

	DbSelectArea("SX5")
	SX5->(DbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE

	//Impressão do relatório.
	cQry1 := "SELECT * FROM " + oTempTable:GetRealName()
	MPSysOpenQuery( cQry1, cAliFim )

	oReport:SetMeter(0)

	(cAliFim)->(DbGoTop())

	oSection1:Init()

	While !(cAliFim)->(EOF())

		If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()

		//Tratamento para Cliente em Grupo e Sem Grupo.
		cCNPJ	 := (cAliFim)->TMP_A1RAZ
		cCliente := (cAliFim)->TMP_A1COD
		cLoja	 := (cAliFim)->TMP_A1LOJ

		If (cAliFim)->TMP_A1_ID == 1
			lCliLoj := .F.
			oSection1:Cell("A1_IDENT"):SetValue( Transform((cAliFim)->TMP_A1RAZ,"@R 99.999.999") )
		Else
			oSection1:Cell("A1_IDENT"):SetValue( (cAliFim)->TMP_A1COD + "\" + (cAliFim)->TMP_A1LOJ )
			lCliLoj := .T.
		EndIf

		oClasCrd := CLASCRED():New()
		
		//nValCred := oClasCrd:LimiteCredito( cCNPJ,lCliLoj,cCliente,cLoja,MV_PAR07,MV_PAR08 )
		// nValCred := oClasCrd:LimiteCredito( cCNPJ,lCliLoj,cCliente,cLoja )
		nValCred := oClasCrd:LimiteCredito( lCliLoj,cCNPJ,cCliente,cLoja ) // VERSA0 2.0
		
		// nTitOpen := oClasCrd:SaldoTitAberto( cCNPJ,MV_PAR09,lCliLoj,cCliente,cLoja )
		nTitOpen := oClasCrd:SaldoTitAberto( MV_PAR09,cCNPJ,lCliLoj,cCliente,cLoja ) // VERSAO 2.0
		
		// TÍTULOS DE CRÉDITO - DESCONSIDERADOS - CONSULTA DESNECESSÁRIA (OTIMIZAÇÃO)
		// nVlRANCC := oClasCrd:SaldoTitRANCC( cCNPJ,lCliLoj,cCliente,cLoja )

		//Condicional para calculo.
		If nTitOpen > 0
			// VALOR CONSUMIDO - NÃO AMORTIZADO. NÃO DEBITAR TOTAL EM DEVOLUÇÃO (NCC) E ANTECIPAÇÃO (RA)
			// nSaldo := Round(nValCred - ( nTitOpen - nVlRaNcc ),2)
			nSaldo := Round((nValCred - nTitOpen), 2)
		Else
			nSaldo := nValCred
		EndIf

		SX5->(DbSeek(xFilial("SX5") + cTabSX5 + (cAliFim)->TMP_A1STA))

		aSX5 := FWGetSX5(cTabSX5, (cAliFim)->TMP_A1STA)

		oSection1:Cell("STATCLI"):SetValue( (cAliFim)->TMP_A1STA + " - " + AllTrim(aSX5[1][4]) )
		oSection1:Cell("CREDITO"):SetValue( nValCred )
		oSection1:Cell("A1_VENCLC"):SetValue( SToD((cAliFim)->TMP_A1DTL) )
		oSection1:Cell("A1_NOME"):SetValue( FRetName(lCliLoj,cCNPJ,cCliente,cLoja) )
		oSection1:Cell("SALDO"):SetValue( nSaldo )
		oSection1:Printline()

		(cAliFim)->(DbSkip())
	EndDo
	oSection1:Finish()

	(cAliFim)->(DbCloseArea())

	//Exclui tabela Temporaria.
	oTempTable:Delete()
Return

/*/{Protheus.doc} FSqlRel
	Função Auxiliar - Retornar de consulta de Clientes *(Código/Loja)* e *Grupo econômico* (raiz CNPJ).
	Retorno de consulta temporária e quantidade de registros.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		18/04/2019
	@version 	1.0
	@param 		cStatCli	, character , *"Status"* *(`A1_XSTATUS`)* do Cliente (no cadastro)
	@param 		cTipoCli	, character , *"Tipo"* *(`A1_XTIPO`)* do Cliente (no cadastro)
	@return 	array		, Vetor com alias da consulta e quantidade de registros - `{ cAlias, (cAlias)->(RecCount()) }`
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Static Function FSqlRel(cStatCli,cTipoCli)
	Local cAliRet	:= GetNextAlias()
	Local cQry1		:= ""
	Local cWhere	:= ""
	Local nTotal	:= 0
	Local lVencLib	:= .T.
	Local aRetSql	:= {}

	// Tratamento para os cliente que tem o campo A1_VENCLC em branco
	If Empty(MV_PAR07) .Or. Empty(MV_PAR08)
		lVencLib := .F.
	EndIf

	// Where Unico, utilizado nos select´s UNION ALL
		cWhere := "WHERE "
		cWhere += "      A.D_E_L_E_T_=' ' "
		cWhere += "  AND A.A1_FILIAL ='" + xFilial("SA1") + "' "
		cWhere += "  AND A.A1_COD BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR05 + "' "
		cWhere += "  AND A.A1_LOJA BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "' "
	
	// Tratamento para Não considerar o vencimento no Where
	If lVencLib
		cWhere += "  AND A.A1_VENCLC BETWEEN '" + DToS(MV_PAR07) + "' AND '" + DToS(MV_PAR08) + "' "
	EndIf
	// Tratamento para Não considerar os Status no Where
	If !Empty(cStatCli)
		cWhere += "  AND A.A1_XSTATUS IN " + cStatCli + " "
	EndIf
	// Tratamento para Não considerar os Tipos no Where
	If !Empty(cTipoCli)
		cWhere += "  AND A.A1_XTIPO IN " + cTipoCli + " "
	EndIf

	If Select(cAliRet) > 0
		(cAliRet)->(DbCloseArea())
	EndIf

	// Consulta SQL
		cQry1 := "SELECT "
		cQry1 += "  1 AS ID, ""
		cQry1 += "  '' AS A1_COD, "
		cQry1 += "  '' AS A1_LOJA, "
		cQry1 += "  SUBSTRING(A1_CGC,1,8) AS A1_RAIZ,"
		cQry1 += "  A1_XSTATUS, "
		cQry1 += "  A1_VENCLC, "
		cQry1 += "  A1_XDESGRP "
		cQry1 += "FROM " + RetSqlName("SA1") + " A "
		cQry1 += cWhere
		cQry1 += "  AND A.A1_XDESGRP = '2' "
		cQry1 += "  AND A.A1_CGC <> '' "
		cQry1 += "GROUP BY "
		cQry1 += "  SUBSTRING(A1_CGC,1,8),A1_XSTATUS,A1_VENCLC,A1_XDESGRP "
		cQry1 += " "
		cQry1 += "UNION ALL "
		cQry1 += " "
		cQry1 += "SELECT "
		cQry1 += "  2 AS ID, "
		cQry1 += "  A1_COD, "
		cQry1 += "  A1_LOJA, "
		cQry1 += "  '' AS A1_RAIZ, "
		cQry1 += "  A1_XSTATUS, "
		cQry1 += "  A1_VENCLC, "
		cQry1 += "  A1_XDESGRP "
		cQry1 += "FROM " + RetSqlName("SA1") + " A "
		cQry1 += cWhere
		cQry1 += "  AND A.A1_XDESGRP <> '2' "
		cQry1 += "GROUP BY "
		cQry1 += "  A1_COD,A1_LOJA,A1_XSTATUS,A1_VENCLC,A1_XDESGRP "
		cQry1 += "ORDER BY "
		cQry1 += "  1,2 "

	cQry1 := ChangeQuery(cQry1)

	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry1),cAliRet,.F.,.T.)
	
	Count To nTotal

	If nTotal > 0
		aRetSql := {cAliRet,nTotal}
	EndIf

Return( aRetSql )

/*/{Protheus.doc} FRetName
	Função Auxiliar - Nome do Cliente *(`A1_NOME`)* para impressão do *Grupo econômico* *(raiz CNPJ)* ou Cliente específico *(Código/Loja)*.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult; CAOA - denis.galvani - Denis A. Galvani
	@since 		18/04/2019
	@version 	1.0
	@param 		lCliLoj		, logical	, Consultar por *Grupo* ou Cliente específico
	@param 		cCNPJ		, character , Raiz CNPJ para retorno do *Grupo* - campo `A1_CGC`
	@param 		cCliente	, character , Código de Cliente - campo `A1_COD`
	@param 		cLoja		, character , Loja de Cliente - campo `A1_LOJA`
	@return 	character	, Nome para identificação do Cliente / *Grupo*
	@obs 		Segundo parâmetro, *cCNPJ*, considerado até oito (8) caracteres
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	@history 	22/08/2020	, denis.galvani, Correção (parâmetro *cCNPJ*) limitar até 8 caracteres
	/*/
Static Function FRetName(lCliLoj,cCNPJ,cCliente,cLoja)
	Local cName		:= ""
	Local cAliName	:= GetNextAlias()
	Local cQuery	:= ""

	If Select(cAliName) > 0
		(cAliName)->(DbCloseArea())
	EndIf
	
	// SELECT
		cQuery := "SELECT "
		cQuery += "  A1_NOME "
		cQuery += "FROM " + RetSqlName("SA1") + " A "
		cQuery += "WHERE "
		cQuery += "  A.D_E_L_E_T_='' "
		cQuery += "  AND A.A1_FILIAL ='" + xFilial("SA1") + "' "
		
		If !lCliLoj
			cQuery += "  AND SUBSTRING(A.A1_CGC,1,8) = '" + PadR(cCNPJ,8) + "' "
		Else
			cQuery += "  AND A.A1_COD = '" + cCliente + "' "
			cQuery += "  AND A.A1_LOJA = '" + cLoja + "' "
		EndIf
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliName,.F.,.T.)

	cName := (cAliName)->A1_NOME

	(cAliName)->(DbCloseArea())
Return( cName )
