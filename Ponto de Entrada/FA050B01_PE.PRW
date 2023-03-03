#include "Protheus.ch"

// P.E. antes de deletar o titulo a pagar, para validacao 
User Function FA050B01()

	Local _cEmp		:= FWCodEmp()
	Local aArea		:= GetArea()
	Local _lRet		:= .T.

	If _cEmp == "2010" //Executa o p.e. Anapolis.
		If Findfunction("U_CMVSAP20")
			_lRet := U_CMVSAP20()
		EndIf
	Else
		If Findfunction("U_ZSAPF020")
			_lRet := U_ZSAPF020()
		EndIf
	EndIf

	RestArea(aArea)

Return(_lRet)

