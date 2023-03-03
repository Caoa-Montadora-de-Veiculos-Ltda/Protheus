#INCLUDE 'PROTHEUS.CH'

/*
=====================================================================================
Programa.:              MNTA9906
Autor....:              CAOA - Valter Carvalho
Data.....:              18/02/2020
Descricao / Objetivo:   Efetua o preenchimento dos campos adicionados, tela de programação O.S, na grid das O.S programadas (lado direito)
                        ao ver/editar                        
Doc. Origem:
Solicitante:            Julia Alcantara
Uso......:              
=====================================================================================
*/
User Function MNTA9906()
    
    Local cTRB2 As Character
    Local aRet As Array

    aRet  := {}
    cTRB2 := c990TRB2

    If FindFunction("U_ZMNTF003")
        aRet := U_ZMNTF003(cTRB2)
    Endif

Return(aRet)