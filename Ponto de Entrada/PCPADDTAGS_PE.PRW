#Include "Protheus.ch"

/*
=====================================================================================
Programa.:              PCPADDTAGS
Autor....:              Atilio Amarilla
Data.....:              01/03/2019
Descricao / Objetivo:   PE na rotina de separação de requisições
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP TOTVS-MES
Obs......:              Objetivo: Retorno de regra e armazem de origem
=====================================================================================
*/
User Function PCPADDTAGS()

	Local cRet	:= ""

	//MsgStop(PCPADDTAGS")

	If FindFunction("U_CMVPCP09")
		cRet := U_CMVPCP09()
	Endif		

Return cRet
