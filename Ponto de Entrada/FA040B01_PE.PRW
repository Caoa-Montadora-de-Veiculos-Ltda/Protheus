#include "Protheus.ch"

// P.E. antes de deletar o titulo a receber, para validacao 
User Function FA040B01()

	Local aArea		:= GetArea()
	Local _lRet		:= .T.

	If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
		If Findfunction("U_CMVSAP16")
			_lRet := U_CMVSAP16()
		EndIf
	ElseIf ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Franco da Rocha | Caoa
		If Findfunction("U_ZSAPF016")
			_lRet := U_ZSAPF016()
		EndIf
	EndIf

	RestArea(aArea)

Return(_lRet)
