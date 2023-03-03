#Include "Protheus.ch"
/*
=====================================================================================
Programa.:              CMVEIC04
Autor....:              Atilio Amarilla
Data.....:              18/03/2019
Descricao / Objetivo:   Gravação adicional em arquivo de trabalho (WORK)
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP EIC004
Obs......:              Chamado pelo PE EIVEV100
Obs......:              - Gravação de campos customizadas
=====================================================================================
*/
User Function CMVEIC04()

	//COPY TO WORKEW5X
	
	WORK->W8_XLOTE		:=	EW5->EW5_XLOTE
	WORK->W8_XCASE		:=	EW5->EW5_XCASE
	WORK->W8_XCONT		:=	EW5->EW5_XCONT
	WORK->W8_XVIN		:=	EW5->EW5_XVIN
	WORK->W8_XMOTOR		:=	EW5->EW5_XMOTOR
	WORK->W8_XCHAVE		:=	EW5->EW5_XCHAVE
	WORK->W8_OPCION		:=	EW5->EW5_XOPC
	WORK->W8_ANOFAB		:=	EW5->EW5_XANOFB
	WORK->W8_ANOMOD		:=	EW5->EW5_XANOMD
	WORK->W8_CORINT		:= 	EW5->EW5_XCORIN
	WORK->W8_COREXT		:= 	EW5->EW5_XCOREX
	WORK->W8_XSERMO 	:=  EW5->EW5_XSERMO
	WORK->W8_XCHAVE 	:=  EW5->EW5_XCHAVE
	WORK->W8_XFLUXO 	:=  IIf(EW5->EW5_XFLUXO=="1","Sim","Nao")
	WORK->W8_XITEEW5	:=  EW5->EW5_XITEW5	
Return 
//-------------------------------------------------------------------
