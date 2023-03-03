#Include "Protheus.ch"

/*
=====================================================================================
Programa.:              IDI410MNU
Autor....:              Marcelo Carneiro
Data.....:              27/05/2019
Descricao / Objetivo:   PE cria botã na rotina de Containers
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP EIC
Obs......:              
=====================================================================================
*/
User Function IDI410MNU()

Local aRet  := {}

If FindFunction("U_CMVEIC05")
	aAdd(aRet,{"Incluir Containers","U_CMVEIC05",	0, 4 })
EndIF

Return aRet
