#INCLUDE "PROTHEUS.CH"

/*
=====================================================================================
Programa.:              ZVEIF003
Autor....:              Evandro Mariano
Data.....:              02/12/2020
Descricao / Objetivo:   Envio do Pedido Manual AutoWare
Doc. Origem:
Solicitante:            
Uso......:              CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/
User Function ZVEIF003()

If Empty(VRJ->VRJ_PEDCOM)
    MsgInfo( "Esse Pedido não permite envio." + CRLF + CRLF +  "Permitido somente pedidos integrados pelos AutoWare", "ZVEIF003" )
Else
    U_CMVAUT04(VRJ->VRJ_PEDIDO)
EndIf

Return()

