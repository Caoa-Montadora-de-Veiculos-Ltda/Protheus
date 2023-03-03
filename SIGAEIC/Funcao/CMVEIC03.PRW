#Include "TOTVS.CH"
/*
=====================================================================================
Programa.:              CMVEIC03
Autor....:              Atilio Amarilla
Data.....:              11/01/2019
Descricao / Objetivo:   Seleção de Campos de Usuário
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP EIC004
Obs......:              Chamado pelo PE_AVGERAL
=====================================================================================
*/
User Function CMVEIC03()

	//MsgStop("CMVEIC03")
	// CONFIRMAR CAMPOS DE SW8 //
	Work_SW8->W8_CORINT	:= EW5->EW5_XCORIN
	Work_SW8->W8_COREXT	:= EW5->EW5_XCOREX
	Work_SW8->W8_OPCION	:= EW5->EW5_XOPC
	Work_SW8->W8_ANOFAB	:= EW5->EW5_XANOFB
	Work_SW8->W8_ANOMOD	:= EW5->EW5_XANOMD
	Work_SW8->W8_XVIN	:= EW5->EW5_XVIN
	Work_SW8->W8_XLOTE	:= EW5->EW5_XLOTE
	Work_SW8->W8_XCASE	:= EW5->EW5_XCASE
	Work_SW8->W8_XCONT	:= EW5->EW5_XCONT
	Work_SW8->W8_XMOTOR	:= EW5->EW5_XMOTOR
	Work_SW8->W8_XSERMO := EW5->EW5_XSERMO
	Work_SW8->W8_XCHAVE := EW5->EW5_XCHAVE
	
RETURN( .T. )
