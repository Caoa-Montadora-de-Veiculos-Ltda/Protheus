#INCLUDE "TOTVS.CH"
/*
=====================================================================================
Programa.:              MT250SAL
Autor....:              Atilio Amarilla
Data.....:              05/09/2019
Descricao / Objetivo:   PE na rotina de apontamento simples (MATA250)
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP ACD003 Apontamento BarCode
Obs......:              - U_CMVPCP13 - Verifica saldo WMS. Recalcula se negativo.
=====================================================================================
*/
User Function MT250SAL()

	Local _aSalWMS	:= PARAMIXB[1]
	
	//MsgStop("MT250SAL")
	
	//MsgStop("FunName() " + FunName() )
	
	If FunName() == "CMVPCP05" .And. IntWms() .And. SuperGetMv("MV_WMSNEW",.F.,.F.)
		//MsgStop("MT250SAL CMVPCP05")
		
		If FindFunction("U_CMVPCP13")
			//MsgStop("MT250SAL CMVPCP05 CMVPCP13")
		
			_aSalWMS	:= U_CMVPCP13( _aSalWMS )

		EndIf
	EndIf

Return _aSalWMS