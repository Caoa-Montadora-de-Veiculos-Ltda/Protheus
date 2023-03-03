#Include "Protheus.Ch"
#Include "Totvs.Ch"

/*/{Protheus.doc} M410PVNF
	Ponto de Entrada - Geração de notas fiscais. Validação antes da execução para geração de NF's.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		17/04/2019
	@version 	1.0
	@param 		ParamIxb, number, *nRecSC5* - Número de *Pedido de Venda* *(`SC5->C5_NUM`)*
	@return 	logical, *Item* ou *Pedido de Venda* válido para regra CAOA de *Liberação de Crédito*
	@see 		TDN - https://tdn.totvs.com/x/mIRn
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
User Function M410PVNF()
	Local nRecSC5	:= ParamIxb
	Local lRet		:= .T.
	Local aArea		:= GetArea()

	If ExistBlock("VLDLIMIT")
		lRet := ExecBlock("VLDLIMIT", .F., .F.,{'',.F.,nRecSC5})
	EndIf

	RestArea(aArea)
Return( lRet )
