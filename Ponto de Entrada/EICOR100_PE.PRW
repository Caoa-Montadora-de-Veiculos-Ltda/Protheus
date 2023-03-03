#INCLUDE 'PROTHEUS.CH'

/*
=====================================================================================
Programa.:              EICOR100
Autor....:              CAOA - Valter Carvalho
Data.....:              17/03/2020
Descricao / Objetivo:   Efetua ajustes no conteúdo do arquivo Envio de P.O.
Doc. Origem:
Solicitante:            Evandro Mariano
Uso......:              EICOR100          
=====================================================================================
*/
User Function EICOR100()

    If FindFunction("U_ZEICF001")
        U_ZEICF001()
    Endif

Return

