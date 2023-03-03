#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} MT150GRV
P.E. - Gravar dados na cotação
@author
@since 21/10/2020

@version 1.0
@type function
/*/
User Function MT150GRV()

	If FindFunction("U_ZCOMF031")

		Begin Sequence
		    _lRet := U_ZCOMF030()
		    _lRet := U_ZCOMF031()
		End Sequence

	EndIf

Return Nil
