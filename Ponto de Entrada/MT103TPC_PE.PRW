#include 'protheus.ch'

User Function MT103TPC()

Local aArea		:= GetArea()

//cRetTes := ExecBlock("MT103TPC",.F.,.F.,{cTesPcNf})

Local cTes := PARAMIXB[1] // TES QUE NÃO PRECISAM DE PEDIDOS

If Findfunction("U_CMVEST02")
	cTes := U_CMVEST02()
EndIf

RestArea(aArea)

Return cTes
