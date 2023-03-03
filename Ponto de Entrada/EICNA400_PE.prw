#Include "Protheus.ch"

/*
=====================================================================================
Programa.:              EICNA400
Autor....:              Marcelo Carneiro
Data.....:              31/05/2019
Descricao / Objetivo:   PE na rotina para criar PO de Entreposto
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP EIC004
Obs......:              
=====================================================================================
*/
User Function EICNA400

Local cParam	:= IIF(Type("PARAMIXB") == "A", PARAMIXB[1], IIF(Type("PARAMIXB") == "C", PARAMIXB, ""))
Local lRet		:= .T.
Local aAreaSW8


// Criação de botôes adicionais no browse
If cParam == "GRAVA_SW3"
	aAreaSW8	:= SW8->( GetArea() )
    SW8->(DbSetOrder(6))
    IF SW8->(DbSeek(SW3->W3_FILIAL+SW6->W6_HAWB+SW7->W7_INVOICE+PADR(SW3->W3_PO_DA,tamsx3('W3_PO_NUM')[01])+SW3->W3_POSI_DA))
    	SW3->W3_XVIN :=  SW8->W8_XVIN	
    	IF SW3->(FieldPos("W3_XMOTOR")) > 0
    	    SW3->W3_XMOTOR :=  SW8->W8_XMOTOR
    	EndIF	
    EndIF
    SW8->( RestArea( aAreaSW8 ) )
EndIf

Return lRet
