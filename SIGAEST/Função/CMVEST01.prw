#include 'protheus.ch'
#include 'parmtype.ch'

// rotina chamada pelo ponto de entrada MTAB2D3
User function CMVEST01()

Local aArea := {SB1->(GetArea()),GetArea()}
Local nCusUnit := 0
Local lExecuta := GetMv("CAOAEST011",,.T.)

If lExecuta
	If Empty(SD3->D3_CUSRP1)
		nCusUnit := GetAdvFVal("SB1","B1_CUSTD",xFilial("SB1")+SD3->D3_COD,1,0)
		If !Empty(nCusUnit)
			SD3->(RecLock("SD3",.F.))
			SD3->D3_CUSRP1 := nCusUnit*SD3->D3_QUANT
			SD3->(MsUnLock())
		Endif	
	Endif
Endif

// campos que o padrao deveria estar gravando e nao estah, foi aberto chamado para verificar esta situacao
SD3->(RecLock("SD3",.F.))
SD3->D3_CLVL := GetAdvFVal("SB1","B1_CLVL",xFilial("SB1")+SD3->D3_COD,1,"")
SD3->D3_ITEMCTA := GetAdvFVal("SB1","B1_ITEMCC",xFilial("SB1")+SD3->D3_COD,1,"")
SD3->(MsUnLock())

aEval(aArea,{|x| RestArea(x)})
 
return()