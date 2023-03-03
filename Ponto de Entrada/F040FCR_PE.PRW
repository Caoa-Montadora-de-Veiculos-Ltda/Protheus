#include "Protheus.ch"

// P.E. depois da inclusao do titulo a receber 
User Function F040FCR()

	Local _cEmp    := FWCodEmp()
	Local aArea	   := GetArea()

	If _cEmp == "2010" //Executa o p.e. Anapolis.
		If Findfunction("U_CMVSAP15")
			U_CMVSAP15(3)
		EndIf
	Else
		If Findfunction("U_ZSAPF015")
			U_ZSAPF015(3)
		EndIf
	EndIf

	RestArea(aArea)

Return()

