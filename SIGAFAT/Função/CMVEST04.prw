#include 'protheus.ch'
#include 'parmtype.ch'

// rotina chamada pelo ponto de entrada MSD2460
User function CMVEST04()

Local aArea := {SB1->(GetArea()),GetArea()}
Local nCusUnit := 0
Local lExecuta := GetMv("CAOAEST011",,.T.)

If lExecuta
	If Empty(SD2->D2_CUSRP1) .and. !Empty(SD2->D2_QUANT)
		nCusUnit := GetAdvFVal("SB1","B1_CUSTD",xFilial("SB1")+SD2->D2_COD,1,0)
		If !Empty(nCusUnit)
			SD2->(RecLock("SD2",.F.))
			SD2->D2_CUSRP1 := nCusUnit*SD2->D2_QUANT
			SD2->(MsUnLock())
		Endif	
	Endif
Endif		

aEval(aArea,{|x| RestArea(x)})
 
return()