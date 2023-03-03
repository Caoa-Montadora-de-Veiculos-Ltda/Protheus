#include 'protheus.ch'
#include 'parmtype.ch'

// rotina chamada pelo ponto de entrada SD1100I
User function CMVEST03()

Local aArea := {SB1->(GetArea()),GetArea()}
Local nCusUnit := 0
Local lExecuta := GetMv("CAOAEST011",,.T.)

If lExecuta
	If Empty(SD1->D1_CUSRP1) .and. !Empty(SD1->D1_QUANT)
		nCusUnit := GetAdvFVal("SB1","B1_CUSTD",xFilial("SB1")+SD1->D1_COD,1,0)
		If !Empty(nCusUnit)
			SD1->(RecLock("SD1",.F.))
			SD1->D1_CUSRP1 := nCusUnit*SD1->D1_QUANT
			SD1->(MsUnLock())
		Endif	
	Endif
Endif		

aEval(aArea,{|x| RestArea(x)})
 
return()