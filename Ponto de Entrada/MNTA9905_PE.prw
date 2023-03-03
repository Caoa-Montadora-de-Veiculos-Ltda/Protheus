#INCLUDE 'PROTHEUS.CH'

/*
=====================================================================================
Programa.:              MNTA9905
Autor....:              CAOA - Valter Carvalho
Data.....:              18/02/2020
Descricao / Objetivo:   Efetua o preenchimento dos campos adicionados, tela de programa��o O.S, na grid das O.S sem programa��o (lado esquerdo)
                        ao Abrir a programa��o O.S para ver/alterar/editar
Doc. Origem:
Solicitante:            Julia Alcantara
Uso......:              
=====================================================================================
*/
User Function MNTA9905()

    If FindFunction("U_ZMNTF001")
        U_ZMNTF001()
    Endif
Return


