#Include "PROTHEUS.CH"
#Include "TOTVS.CH"
/*/{Protheus.doc} GFEXFB18
PE p/ chamada da função
@author A.Carlos
@since 12/06/2023
@version 1.0
/*/
User Function GFEXFB18()

	If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB

      If Findfunction("U_ZGFEF007")
			nValor := U_ZGFEF007()
		EndIf

   EndIf

Return(nValor)
