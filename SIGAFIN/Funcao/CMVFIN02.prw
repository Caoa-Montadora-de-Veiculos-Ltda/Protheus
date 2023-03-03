#include 'protheus.ch'
#include 'parmtype.ch'

Static aCred := {}

/*/{Protheus.doc} CMVFIN02
	CAOA - Gerar LOG de campos alterados na aba *"Crédito"* do cadastro de Cliente. LOG gerado na Tabela `ZA2`.
	Rotina executada pelos pontos de entrada ***M030ALT*** e ***MALTCLI***.
	@type 		function
	@version 	1.0
	@author 	TOTVS - mauricio.gresele - Mauricio Gresele
	@since 		
	// @since 		17/02/2019
	// @since 		22/10/2019
	@return 	NIL			, Nulo *(nenhum)*
	@see 		TDN - Pontos de Entrada:
				- M030ALT - https://tdn.totvs.com/x/hYRn
				- MALTCLI - https://tdn.totvs.com/x/L4Vn
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
User function CMVFIN02()

	Local cMenLog	:= ""
	Local cCampo	:= ""
	Local cTitulo	:= ""
	Local cTable	:= "SA1"
	Local cAliSX3	:= GetNextAlias()
	Local xContMem	:= ""
	Local xContTab	:= ""
	Local oGrvZA2	:= Nil
	Local nCnt		:= 0

	If Len(aCred) == 0
		If Select(cAliSX3) > 0
			(cAliSX3)->(DbCloseArea())
		EndIf
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

		While !(cAliSX3)->(EOF())

			cCampo	:= AllTrim( (cAliSX3)->CAMPO )
			cTitulo := AllTrim( (cAliSX3)->TITULO )

			//Efetua Macro-Substituição.
			//xContMem := &("M->" + cCampo )
			xContTab := &(cTable + "->" + cCampo )

			aAdd(aCred,{cCampo,cTitulo,xContTab})

			(cAliSX3)->(DbSkip())
		EndDo

		(cAliSX3)->(DbCloseArea())
	Else
		For nCnt:=1 To Len(aCred)
			cCampo := aCred[nCnt][1]
			xContMem := aCred[nCnt][3]
			xContTab := &(cTable + "->" + cCampo )
			If xContMem != xContTab

				//Verifica o tipo do dado, e trata tudo para caracter.
				xContMem := AjstCont(cCampo,xContMem,cTable)
				xContTab := AjstCont(cCampo,xContTab,cTable)

				cMenLog := "CAMPO: " + aCred[nCnt][2] + ", ALTERADO DE: " + xContMem + " PARA: " + xContTab

				oGrvZA2 := CLASCRED():New()
				oGrvZA2:GravaZA2(SA1->A1_COD,SA1->A1_LOJA,cMenLog)
			EndIf
		Next
		aCred := {} // zera variavel static
	Endif

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
	@see		Função estática também ***existente no fonte GRVLOGCA.PRW***
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Static Function AjstCont(cCampo,xConteudo,cTable)

	If TamSx3(cCampo)[3] == "C"	//Trata os dados para os campos tipo CARACTER.
		xConteudo := FwNoAccent(xConteudo)
		xConteudo := StrTran(xConteudo,"'","")
	ElseIf TamSx3(cCampo)[3] == "D"	//Trata os dados para os campos tipo DATA.
		xConteudo := DToC(xConteudo)
	ElseIf TamSx3(cCampo)[3] == "N"	//Trata os dados para os campos tipo NUMERICO.
		//xConteudo := CValToChar(xConteudo)
		xConteudo := Alltrim(Transform(&(cTable+"->"+cCampo) , PesqPict( cTable , cCampo)))
	EndIf

Return(xConteudo)
