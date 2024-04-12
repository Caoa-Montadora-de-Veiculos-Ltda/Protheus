#include "Protheus.ch"

// P.E. depois da inclusao do titulo a receber 
User Function F040FCR()

	Local aArea	   := GetArea()

	If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
		If Findfunction("U_CMVSAP15")
			U_CMVSAP15(3)
		EndIf
	ElseIf ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Franco da Rocha | Caoa
		If Findfunction("U_ZSAPF015")
			U_ZSAPF015(3)
		EndIf
	EndIf

	RestArea(aArea)

Return()

