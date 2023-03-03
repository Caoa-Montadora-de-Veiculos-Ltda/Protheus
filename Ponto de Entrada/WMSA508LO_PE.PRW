#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"

/*
=====================================================================================
Programa.:              WMSA508LO
Autor....:              Atilio Amarilla
Data.....:              07/05/2019
Descricao / Objetivo:   PE na rotina de geração automática de requisições WMSA508
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP WMS003
Obs......:              Objetivo: Retorno de armazem de origem
=====================================================================================
*/
User Function WMSA508LO()

	Local cRet	:= ""

	//ConOut("WMSA508LO")

	If FindFunction("U_CMVWMS03")
		cRet := U_CMVWMS03()
	Endif		

Return cRet
