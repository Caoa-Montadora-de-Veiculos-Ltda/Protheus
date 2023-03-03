/*
=====================================================================================
Programa.:              MNTA9902
Autor....:              CAOA - Valter Carvalho
Data.....:              22/07/2020
Descricao / Objetivo:   Criar as coluns personalizadas da tela de programação de o.s.
Doc. Origem:
Solicitante:            Julia 
Uso......:              
=====================================================================================*/
User Function MNTA9902()
    Local aRet := ParamIXB

    If FindFunction("U_ZMNTF002")
        aRet := U_ZMNTF002(aRet)
    Endif

return aRet


