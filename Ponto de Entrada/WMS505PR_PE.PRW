#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"

/*
=====================================================================================
Programa.:              WMS505PR
Autor....:              Atilio Amarilla
Data.....:              28/02/2019
Descricao / Objetivo:   PE na rotina de separação de requisições
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP WMS003
Obs......:              Objetivo: Retorno de regra e armazem de origem
=====================================================================================
*/
User Function WMS505PR()

	Local aRet	:= PARAMIXB[1]

	// MsgStop("WMS505PR")

	If FindFunction("U_CMVWMS02")
		aRet := U_CMVWMS02(aRet)
	Endif		

Return aRet
