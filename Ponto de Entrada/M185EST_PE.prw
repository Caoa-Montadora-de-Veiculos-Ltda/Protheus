#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} M185GRV
//TODO Descri��o PE na baixa da requisi��o
@author marcelo.moraes
@since 02/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function M185EST()

	local cLancPadrao :=  SuperGetMv("CMV_M185GE",,"66E") 
	local cContabil   :=  SuperGetMv("MV_CUSMED",,"M")

	If FindFunction("U_CMVEST05") .and. AllTrim(cContabil) <> "M"  //So contabiliza se for on line 	
		//Contabiliza estorno da requisi��o
		U_CMVEST05(cLancPadrao)	
	endif	

Return()
