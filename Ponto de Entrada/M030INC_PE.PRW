#include 'protheus.ch'
#include 'parmtype.ch'

User function M030Inc()

	Local _cEmp		:= FWCodEmp()
	Local aArea		:= GetArea()
	Local _lRet		:= .T.

	If ParamIxb == 3
		If _cEmp == "2010" //Executa o p.e. Anapolis.
			U_ZF10GENSAP("SA1",SA1->A1_COD+SA1->A1_LOJA,"A1_XCDSAP",3)
		Else
			U_ZF10GENSAP(ZSAPF001,IncSZ7Cad,"SA1",SA1->A1_COD+SA1->A1_LOJA,"A1_XCDSAP",3)
		EndIf
	
		IF SA1->A1_TIPO == 'J' .AND. SA1->A1_XTIPO $ 'ZR' 
			RecLock("SA1", .F.)
				//SA1->A1_XSILST  := 'N'
			SA1->(MsUnlock())
		EndIF
	EndIf

	RestArea(aArea)
	
Return(_lRet)
