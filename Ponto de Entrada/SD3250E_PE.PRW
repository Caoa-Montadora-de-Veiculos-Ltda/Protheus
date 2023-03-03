#Include "Protheus.ch"

/*
=====================================================================================
Programa.:              SD3250E
Autor....:              Atilio Amarilla
Data.....:              03/04/2019
Descricao / Objetivo:   PE no estorno de apontamento de produção (backflush)
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP ACD003
Obs......:              Objetivo: Usado para limpar flags de ZZD (apontamento barcode)
=====================================================================================
*/
User Function SD3250E()

	//MsgStop("SD3250E")

	If FindFunction("U_CMVPCP12")
		U_CMVPCP12()
	Endif		

Return
