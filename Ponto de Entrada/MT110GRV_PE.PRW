#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT110GRV
P.E. - No laco de grava��o dos itens da SC na fun��o A110GRAVA, executado ap�s gravar o item da SC, a cada item gravado da SC o ponto � executado.
Eventos
@author
@since 08/08/2019
@version 1.0
@type function
/*/
User Function MT110GRV()

	Local aArea		:= GetArea()
	Local _lRet		:= .T.
	Local _lCopia   := Paramixb[1]

	If FindFunction("U_ZCOMF003")
		Begin Sequence
			_lRet := U_ZCF3SCGR(_lCopia)
		End Sequence
	Endif

	RestArea(aArea)

Return(_lRet)
