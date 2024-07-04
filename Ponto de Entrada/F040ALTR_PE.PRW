#include "Protheus.ch"

// P.E. depois da alteracao do titulo a receber
User Function F040ALTR()

	Local aArea	   := GetArea()

	If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
		If Findfunction("U_CMVSAP15")
			U_CMVSAP15(4)
		EndIf
	ElseIf ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Franco da Rocha | Caoa
		If Findfunction("U_ZSAPF015")
			U_ZSAPF015(4)
		EndIf
	EndIf

	RestArea(aArea)

Return()

