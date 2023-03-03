#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} MT125GRV
P.E. - Salvar campo no contrato de parceria
10/03/2020 - Incluida nova funcionalidade para gerar histórico auditoria
@author
@since 21/10/2020
@version 1.0
@type function
/*/
User Function MT125GRV( )
Local _lRet := .T.
//Local _nOpc := If(INCLUI,3, IF(ALTERA,4, 5) )

Begin Sequence

	If FindFunction("U_ZCOMF027")

		_lRet := U_ZCOMF027()

	EndIf
		
End Sequence

Return _lRet
