#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} EFFEX102
PE para Utilizado para etornar os dados para fluxo de caixa no financeiro na integração SIGAEFF X SIGAFIN
https://tdn.totvs.com/display/public/PROT/EFFEX102+-+Fluxo+de+caixa+no+financeiro
@type Function

@author Joni Lima do Carmo
@since 10/09/2019
@version P12
/*/
User Function EFFEX102()

	Local cParam := If(Type("ParamIxb") = "A",ParamIxb[1],If(Type("ParamIxb") = "C",ParamIxb,""))

	If cParam == "INT_SE2"
		aAdd(oTit:aSE2, {"E2_CONTAD" 	, EF3->EF3_CONTA	, Nil})
		aAdd(oTit:aSE2, {"E2_CCUSTO" 	, EF3->EF3_CCUSTO	, Nil})
		aAdd(oTit:aSE2, {"E2_ITEMCTA" 	, EF3->EF3_ITEMCT	, Nil})
		aAdd(oTit:aSE2, {"E2_CLVL"    	, EF3->EF3_CLVL  	, Nil})
	EndIf

Return .T.