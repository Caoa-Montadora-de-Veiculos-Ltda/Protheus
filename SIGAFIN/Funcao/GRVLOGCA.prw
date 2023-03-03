#Include "Protheus.CH"
#Include "Totvs.CH"

/*/{Protheus.doc} GRVLOGCA
	Função para verificar se houve alteração nos campos da aba *"Crédito"*.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		17/02/2019
	@version 	1.0
	// @param 	param_name	, param_type, param_description
	@return 	NIL, Nulo *(nenhum)*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
User Function GRVLOGCA()
	Local cMenLog	:= ""
	Local cCampo	:= ""
	Local cTitulo	:= ""
	Local cTable	:= "SA1"
	Local cAliSX3	:= GetNextAlias()
	Local xContMem	:= ""
	Local xContTab	:= ""
	Local oGrvZA2	:= Nil

	If Select(cAliSX3) > 0
		(cAliSX3)->(DbCloseArea())
	EndIf

	// SELECT campos na aba "Credito" tela de cadastro de Cliente (MATA030)
		BeginSql Alias cAliSX3
			SELECT 
				X3_CAMPO AS CAMPO, 
				X3_TITULO AS TITULO 
			FROM %Table:SX3% X
			WHERE
					X.%NotDel%
				AND X.X3_ARQUIVO = %Exp:cTable%
				AND X.X3_FOLDER = (	SELECT 
										XA_ORDEM 
									FROM SXA010 A
									WHERE
											A.%NotDel%
										AND A.XA_ALIAS = %Exp:cTable%
										AND A.XA_DESCRIC LIKE 'Cr%'
										AND A.XA_PROPRI = 'U' )
		EndSql

	(cAliSX3)->(DbGoTop())

	// GRAVAR LOG de campos na aba "Credito" e valores (anterior e novo/atual)
	While !(cAliSX3)->(EOF())

		cCampo	:= AllTrim( (cAliSX3)->CAMPO )
		cTitulo := AllTrim( (cAliSX3)->TITULO )

		// Efetua Macro-Substituição
		xContMem := &("M->" + cCampo )
		xContTab := &(cTable + "->" + cCampo )

		If xContMem != xContTab

			// Verifica o tipo do dado, e trata tudo para caracter
			xContMem := AjstCont(cCampo,xContMem,cTable)
			xContTab := AjstCont(cCampo,xContTab,cTable)

			cMenLog := "CAMPO: " + cTitulo + ", ALTERADO DE: " + xContTab + " PARA: " + xContMem

			oGrvZA2 := CLASCRED():New()
			oGrvZA2:GravaZA2(M->A1_COD,M->A1_LOJA,cMenLog)
		EndIf

		(cAliSX3)->(DbSkip())
	EndDo

Return

/*/{Protheus.doc} AjstCont
	Função para converter o conteúdo para texto (caracter).
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		17/02/2019
	@version 	1.0
	@param 		cCampo		, character	, Campo da tabela que está sendo logado
	@param 		xConteudo	, undefined	, Conteúdo para conversão em texto e retorno
	@param 		cTable		, character	, Alias da tabela que está sendo logada
	@return 	character	, Valor do campo convertido em texto
	@see		Função estática também ***existente no fonte CMVFIN02.PRW***
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Static Function AjstCont(cCampo,xConteudo,cTable)

	If TamSx3(cCampo)[3] == "C"	// Trata os dados para os campos tipo CARACTER
		xConteudo := FwNoAccent(xConteudo)
		xConteudo := StrTran(xConteudo,"'","")
	ElseIf TamSx3(cCampo)[3] == "D"	// Trata os dados para os campos tipo DATA
		xConteudo := DToC(xConteudo)
	ElseIf TamSx3(cCampo)[3] == "N"	// Trata os dados para os campos tipo NUMERICO
		//xConteudo := CValToChar(xConteudo)
		xConteudo := Alltrim(Transform( &(cTable+"->"+cCampo) , PesqPict( cTable , cCampo)))
	EndIf

Return(xConteudo)
