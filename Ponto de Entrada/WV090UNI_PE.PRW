#INCLUDE "TOTVS.CH"
/*
=====================================================================================
Programa.:              WV090UNI
Autor....:              Atilio Amarilla
Data.....:              15/01/2019
Descricao / Objetivo:   PE na rotina de conferência do recebimento
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP WMS001
Obs......:              Objetivo: Gravação de Lotes e informações adicionais
=====================================================================================
*/

User Function WV090UNI()

	Local cEmbarque := PARAMIXB[1]
	//Local cTipUni   := PARAMIXB[2]
	Local cIdUnit   := PARAMIXB[3]
	//Local cArmazem  := PARAMIXB[4]
	//Local cEndereco := PARAMIXB[5]
	Local aRet	:= {}

	If FindFunction("U_CMVWMS01")
		aRet := U_CMVWMS01(cEmbarque,cIdUnit)
	Endif		


Return aRet
