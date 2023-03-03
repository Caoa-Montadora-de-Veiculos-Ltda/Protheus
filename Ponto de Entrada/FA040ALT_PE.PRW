#include "Protheus.ch"

// P.E. antes de alterar o titulo a receber, para validacao  
User Function FA040ALT()

	Local _cEmp		:= FWCodEmp()
	Local aArea		:= GetArea()
	Local _lRet		:= .T.

	If _cEmp == "2010" //Executa o p.e. Anapolis.
		If Findfunction("U_CMVSAP15")
			U_CMVSAP15(4)
		EndIf
	Else
		If Findfunction("U_ZSAPF015")
			U_ZSAPF015(4)
		EndIf
	EndIf

	RestArea(aArea)

Return(_lRet)

