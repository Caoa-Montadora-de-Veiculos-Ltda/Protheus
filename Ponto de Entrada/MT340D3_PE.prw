#Include "Protheus.Ch"
#Include "Totvs.Ch"

/*/{Protheus.doc} MT340D3
P.E. - Grava as informações do inventário na SD3.
@author FSW - DWC Consult
@since 07/02/2019
@version 1.0
@type function
/*/
User Function MT340D3()
	Local aArea	:= GetArea()
	
	//Abre a tabela para gravação dos movimentos de inventário.
	//Essas informações são armazenadas para posteriormente gerar:
	// - Nota Fiscal de Entrada para Ganhos.
	// - Pedido de Venda para posterior NF de Saida para as Perdas.
	DbSelectArea("ZA0")
	ZA0->(DbSetOrder(1)) //ZA0_FILIAL+ZA0_TM+ZA0_LOCAL+ZA0_COD

	RecLock("ZA0",.T.)
	ZA0->ZA0_FILIAL	:= SD3->D3_FILIAL
	ZA0->ZA0_TM		:= Iif(AllTrim(SD3->D3_TM) == '999','S','E')
	ZA0->ZA0_COD	:= SD3->D3_COD
	ZA0->ZA0_UM		:= SD3->D3_UM
	ZA0->ZA0_QUANT	:= SD3->D3_QUANT
	ZA0->ZA0_LOCAL	:= SD3->D3_LOCAL
	ZA0->ZA0_DOC	:= SD3->D3_DOC
	ZA0->ZA0_DOCB7	:= SB7->B7_DOC
	ZA0->ZA0_EMISSA	:= SD3->D3_EMISSAO
	ZA0->ZA0_CUSTO1	:= SD3->D3_CUSTO1
	ZA0->ZA0_CC		:= SD3->D3_CC
	ZA0->ZA0_NUMSEQ	:= SD3->D3_NUMSEQ
	ZA0->ZA0_TIPO	:= SD3->D3_TIPO
	ZA0->ZA0_LOTE	:= SD3->D3_LOTECTL
	ZA0->ZA0_SBLOTE	:= SD3->D3_NUMLOTE
	ZA0->ZA0_DTVALI	:= SD3->D3_DTVALID
	ZA0->ZA0_ENDERE	:= SD3->D3_LOCALIZ
	ZA0->ZA0_NUMSER	:= SD3->D3_NUMSERI
	ZA0->ZA0_STATUS	:= '1'	//Não Processado.
	ZA0->(MsUnlock())

	RestArea(aArea)
Return