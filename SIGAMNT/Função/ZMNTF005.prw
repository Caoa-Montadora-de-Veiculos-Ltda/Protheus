/*===================================================================================
Programa.:              ZMNTF005
Autor....:              Valter Carvalho
Data.....:              16/10/2020
Descricao / Objetivo:   Campo Observação - Retorno OS Mod2 (427803)
Doc. Origem:            MNT105 - Campo Observação - Retorno OS Mod2 (427803)						
Solicitante:            Julia Alcantara
=====================================================================================*/
User Function ZMNTF005()

    If STJ->TJ_TIPO = "002"
        Aadd(aChoice, "TJ_XLAUDO")
    EndIf

Return
