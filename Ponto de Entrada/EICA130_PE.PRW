/* =====================================================================================
Programa.:              ZEICF002
Autor....:              CAOA - Valter Carvalho
Data.....:              07/12/2020
Descricao / Objetivo:   Altera��o no cadastro de N.C.M refletindo no cadastro de Produtos
Doc. Origem:            FIS016
Solicitante:            CAOA - Montadora - An�polis
Uso......:              ZEICF006
Obs......:
===================================================================================== */
User Function EICA130()

    If ParamIxb = 'GRV_CPOS'
        If FindFunction("U_ZEICF006")
            U_ZEICF006() // ataliza campos na SB1
        Endif
    EndIf 

Return
