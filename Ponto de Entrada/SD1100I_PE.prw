#Include "Totvs.ch"
#Include "Protheus.ch"

//Este Ponto de entrada � executado durante a inclus�o do Documento de Entrada, ap�s a inclus�o do item na tabela SD1. O registro no SD1 j� se encontra travado (Lock). Ser� executado uma vez para cada item do Documento de Entrada que est� sendo inclu�da.

User Function SD1100I()
//ExecBlock("SD1100I",.F.,.F.,{lConFrete,lConImp,nOper})

If Findfunction("U_CMVEST03")
	U_CMVEST03()
EndIf

Return()