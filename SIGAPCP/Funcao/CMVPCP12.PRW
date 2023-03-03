#include 'protheus.ch'
#include 'parmtype.ch'
/*
=====================================================================================
Programa.:              CMVPCP12
Autor....:              Atilio Amarilla
Data.....:              03/04/2019
Descricao / Objetivo:   Apontamento BarCode. Estorno de apontamento de produção (backflush)
Doc. Origem:            Contrato - GAP PCP004
Solicitante:            Cliente CAOA
Uso......:              Marfrig
Obs......:              Objetivo: limpar flags de ZZD (apontamento barcode). PE MATI681INT
=====================================================================================
*/
User Function CMVPCP12()

	Local aArea	:= GetArea()

	//MsgStop("SC2 "+SC2->(C2_NUM+C2_SEQUEN))
	//MsgStop("SD3 "+SD3->D3_OP)
	
	If SC2->C2_XTIPO = '1'
		dbSelectArea("ZZD")
		dbSetOrder(1) // ZZD_FILIAL+ZZD_BARCOD+ZZD_OP+ZZD_ROTEIR+ZZD_OPERAC+ZZD_RECURS+ZZD_FERRAM
		dbSeek( xFilial("ZZD") + SC2->( C2_XBARCOD + C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD ) )
		While !ZZD->(eof()) .And. ZZD->(ZZD_FILIAL+ZZD_BARCOD+ZZD_OP) == xFilial("ZZD") + SC2->( C2_XBARCOD + C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD )
			If ZZD->ZZD_BACKFL == "1" .And. ZZD->ZZD_INTEGR == "1"
				RecLock("ZZD",.F.)
				ZZD->ZZD_INTEGR := " "
				ZZD->( msUnlock() )
			EndIf
			ZZD->( dbSkip() )
		EndDo
		RestArea( aArea )
	EndIf

Return
