#include "Protheus.ch"

// P.E. depois da alteracao do titulo a receber
User Function F040ALTR()

	Local _cEmp    := FWCodEmp()
	Local aArea	   := GetArea()

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

Return()

