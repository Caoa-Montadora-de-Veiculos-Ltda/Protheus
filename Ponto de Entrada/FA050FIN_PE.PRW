#include "Protheus.ch"

// P.E. depois da inclusao do titulo a pagar 
User Function FA050FIN()

	Local aArea		:= GetArea()

	If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
		If Findfunction("U_CMVSAP19")
			U_CMVSAP19(3)
		EndIf
	ElseIf ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Franco da Rocha | Caoa
		If Findfunction("U_ZSAPF019")
			U_ZSAPF019(3)
		EndIf
	EndIf

	RestArea(aArea)

Return()
