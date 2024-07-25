#include "Protheus.ch"

// P.E. antes da contabilizacao 
User Function ANTCTBGRV()

	Local _aArea    := GetArea()
    local nOpc      := PARAMIXB[1]

    If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
    	If Findfunction("U_CMVSAP09")
			U_CMVSAP09(nOpc)
		EndIf
   	ElseIf ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) ) //Empresa 02-Franco da Rocha
    	If Findfunction("U_ZSAPF009")
			U_ZSAPF009(nOpc)  //Grava SZ7
		EndIf
   	EndIf

	RestArea(_aArea)

Return() 		
