#Include "PROTHEUS.CH"
#Include "TOTVS.CH"
/*/{Protheus.doc} GFEXFB18
PE p/ chamada da fun��o
@author A.Carlos
@since 12/06/2023
@version 1.0
/*/
User Function GFEXFB18()
	Local _cEmp	   := FWCodEmp()

	If _cEmp == "2020" //Executa o p.e. Barueri

      If Findfunction("U_ZGFEF007")
			nValor := U_ZGFEF007()
		EndIf

   EndIf

Return(nValor)
