#include "TOTVS.ch"

/*
=======================================================================================
Programa.:              MT097APR
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              06/07/2020
Descricao / Objetivo:   PE acionado após a aprovação total do pedido de compra          
=======================================================================================
*/
User Function MT097APR()
  
    //--Realiza o envio do PC por e-mail
    If (FindFunction("U_ZCOMF029") .and. !FWIsInCallStack("POST")) .or. FWIsInCallStack("POST")
       U_ZCF029EMAI()
    EndIf

Return
