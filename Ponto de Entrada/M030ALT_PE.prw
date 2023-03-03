#Include "TOTVS.CH"
#Include "Protheus.CH"
#Include "TopConn.CH"
#Include "TbiConn.CH"

#Define CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} M030ALT
	Ponto de Entrada - Validação de alterações nos dados do cadastro de Cliente *(MATA030)*.
	> Projeto - Doc. Origem: Integração SILT para marcar o campo como Integra.
	@type 		function
	@author 	TOTVS - Marcelo Carneiro; CAOA - denis.galvani - Denis A. Galvani
	@since 		18/06/2019
	@version 	2.0
	@param 		ParamIxb, number, *nRecSC5* - Número de *Pedido de Venda* *(`SC5->C5_NUM`)*
	@return 	logical, *lRet* - Inclusão/Alteração de campos válida
	@see 		TDN - https://tdn.totvs.com/x/hYRn
	@obs 		Campo para controle *"Integra"* **SILT** - `SA1->A1_XSILST` - **não existe no** ***Dicionário de Dados***
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
    @history 	22/08/2020	, denis.galvani, Padronização CAOA para chamada de funções
    @history              	,              , Verificar programa/função existente - `ExistBlock` ou `FindFunction`
	/*/
User Function M030ALT()
	Local lRet := .T.

	// Se Pessoa Jurídica será enviado para o SILT
    //	IF SA1->A1_TIPO == 'J' .AND. SA1->A1_XTIPO $ 'ZR'
	//	RecLock("SA1", .F.)
	           	// SA1->A1_XSILST  := 'N'
	//	SA1->(MsUnlock())
	//EndIF


	// Log de alteração de campos do limite de crédito
	If ExistBlock("CMVFIN02")
		U_CMVFIN02()
	EndIF

Return(lRet)
