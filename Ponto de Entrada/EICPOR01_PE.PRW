#INCLUDE 'PROTHEUS.CH'

/*
=====================================================================================
Programa.:              EICOR100
Autor....:              CAOA - Valter Carvalho
Data.....:              17/03/2020
Descricao / Objetivo:   Efetua ajustes no conteúdo do arquivo Envio de P.O.
Doc. Origem:
Solicitante:            Evandro Mariano
Uso......:              EICPOR01          
=====================================================================================
*/
User Function EICPOR01()

    If FindFunction("U_ZEICF005")
        U_ZEICF005()
    Endif
Return
