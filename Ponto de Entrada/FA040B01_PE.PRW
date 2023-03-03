#include "Protheus.ch"

// P.E. antes de deletar o titulo a receber, para validacao 
User Function FA040B01()

	Local _cEmp		:= FWCodEmp()
	Local aArea		:= GetArea()
	Local _lRet		:= .T.

	If _cEmp == "2010" //Executa o p.e. Anapolis.
		If Findfunction("U_CMVSAP16")
			_lRet := U_CMVSAP16()
		EndIf
	Else
		If Findfunction("U_ZSAPF016")
			_lRet := U_ZSAPF016()
		EndIf
	EndIf

	RestArea(aArea)

Return(_lRet)
