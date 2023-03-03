#Include "TOTVS.CH"
#Include "Protheus.CH"
#Include "TopConn.CH"
#Include "TbiConn.CH"

#Define CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} M030ALT
	Ponto de Entrada - Valida��o de altera��es nos dados do cadastro de Cliente *(MATA030)*.
	> Projeto - Doc. Origem: Integra��o SILT para marcar o campo como Integra.
	@type 		function
	@author 	TOTVS - Marcelo Carneiro; CAOA - denis.galvani - Denis A. Galvani
	@since 		18/06/2019
	@version 	2.0
	@param 		ParamIxb, number, *nRecSC5* - N�mero de *Pedido de Venda* *(`SC5->C5_NUM`)*
	@return 	logical, *lRet* - Inclus�o/Altera��o de campos v�lida
	@see 		TDN - https://tdn.totvs.com/x/hYRn
	@obs 		Campo para controle *"Integra"* **SILT** - `SA1->A1_XSILST` - **n�o existe no** ***Dicion�rio de Dados***
	@history 	22/08/2020	, denis.galvani, Inclus�o/padroniza��o de documenta��o de cabe�alho
    @history 	22/08/2020	, denis.galvani, Padroniza��o CAOA para chamada de fun��es
    @history              	,              , Verificar programa/fun��o existente - `ExistBlock` ou `FindFunction`
	/*/
User Function M030ALT()
	Local lRet := .T.

	// Se Pessoa Jur�dica ser� enviado para o SILT
    //	IF SA1->A1_TIPO == 'J' .AND. SA1->A1_XTIPO $ 'ZR'
	//	RecLock("SA1", .F.)
	           	// SA1->A1_XSILST  := 'N'
	//	SA1->(MsUnlock())
	//EndIF


	// Log de altera��o de campos do limite de cr�dito
	If ExistBlock("CMVFIN02")
		U_CMVFIN02()
	EndIF

Return(lRet)
