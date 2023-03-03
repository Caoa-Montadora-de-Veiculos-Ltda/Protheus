#Include "Totvs.ch"
#Include "Protheus.ch"

// P.E. antes da contabilizacao
User Function ANCTB102GR()

	Local _cEmp    := FWCodEmp()
	Local _lRet	   := .T.
	Local _aArea   := GetArea()
	local nOpc     := PARAMIXB[1]
	//Local aParam    := ParamIxb
	//local dDatalanc := PARAMIXB[2]
	//local cLote     := PARAMIXB[3]
	//Local cSubLote  := PARAMIXB[4]
	//Local cDoc      := PARAMIXB[5]

 	If _cEmp == "2010" //Executa o p.e. Anapolis.
    	If Findfunction("U_CMVSAP09")
			_lRet := U_CMVSAP09(nOpc)
		EndIf
   	Else
    	If Findfunction("U_ZSAPF009")
			_lRet := U_ZSAPF009(nOpc)   //Grava SZ7
		EndIf
   	EndIf

	RestArea(_aArea)

Return(_lRet)
