#include "Protheus.ch"

// P.E. antes da contabilizacao 
User Function ANTCTBGRV()

    Local _cEmp     := FWCodEmp()
	Local _aArea    := GetArea()
    local nOpc      := PARAMIXB[1]

    If _cEmp == "2010" //Executa o p.e. Anapolis.
    	If Findfunction("U_CMVSAP09")
			U_CMVSAP09(nOpc)
		EndIf
   	Else
    	If Findfunction("U_ZSAPF009")
			U_ZSAPF009(nOpc)  //Grava SZ7
		EndIf
   	EndIf

	RestArea(_aArea)

Return() 		
