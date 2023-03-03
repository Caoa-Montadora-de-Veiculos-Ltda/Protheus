#include "Protheus.ch"

// P.E. depois da inclusao do titulo a pagar 
User Function FA050FIN()

	Local _cEmp		:= FWCodEmp()
	Local aArea		:= GetArea()

	If _cEmp == "2010" //Executa o p.e. Anapolis.
		If Findfunction("U_CMVSAP19")
			U_CMVSAP19(3)
		EndIf
	Else
		If Findfunction("U_ZSAPF019")
			U_ZSAPF019(3)
		EndIf
	EndIf

	RestArea(aArea)

Return()
