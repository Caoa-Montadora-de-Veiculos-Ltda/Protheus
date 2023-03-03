#Include "Totvs.ch"
#Include "Protheus.ch"

//Este Ponto de entrada é executado durante a inclusão do Documento de Entrada, após a inclusão do item na tabela SD1. O registro no SD1 já se encontra travado (Lock). Será executado uma vez para cada item do Documento de Entrada que está sendo incluída.

User Function SD1100I()
//ExecBlock("SD1100I",.F.,.F.,{lConFrete,lConImp,nOper})

If Findfunction("U_CMVEST03")
	U_CMVEST03()
EndIf

Return()