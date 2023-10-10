#include "Protheus.ch"

// P.E. depois da gravacao do titulo a receber antes da contabilização
User Function F040GRV()

	Local _cEmp    := FWCodEmp()
	Local aArea	   := GetArea()

	If _cEmp == "2010" //Executa o p.e. Anapolis.
		If Findfunction("U_ZFINF006")
			U_ZFINF006()
		EndIf
	EndIf

	RestArea(aArea)

Return()

