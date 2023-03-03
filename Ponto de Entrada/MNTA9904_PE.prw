#INCLUDE 'PROTHEUS.CH'

/*
=====================================================================================
Programa.:              MNTA9904
Autor....:              CAOA - Valter Carvalho
Data.....:              22/07/2020
Descricao / Objetivo:   Efetua o preenchimento dos campos adicionados, tela de programa��o O.S, na grid das O.S sem programa��o (lado esquerdo)
                        No momento da  inclus�o das O.S a programar.
Doc. Origem:
Solicitante:            Julia Alcantara
Uso......:              
===================================================================================== */
User Function MNTA9904()

    If FindFunction("U_ZMNTF001")
        U_ZMNTF001()
    Endif

Return


