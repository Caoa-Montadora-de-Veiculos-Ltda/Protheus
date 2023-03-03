#Include "Protheus.Ch"
#Include "Totvs.Ch"

/*/{Protheus.doc} M410PVNF
	Ponto de Entrada - Gera��o de notas fiscais. Valida��o antes da execu��o para gera��o de NF's.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		17/04/2019
	@version 	1.0
	@param 		ParamIxb, number, *nRecSC5* - N�mero de *Pedido de Venda* *(`SC5->C5_NUM`)*
	@return 	logical, *Item* ou *Pedido de Venda* v�lido para regra CAOA de *Libera��o de Cr�dito*
	@see 		TDN - https://tdn.totvs.com/x/mIRn
	@history 	22/08/2020	, denis.galvani, Inclus�o/padroniza��o de documenta��o de cabe�alho
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
