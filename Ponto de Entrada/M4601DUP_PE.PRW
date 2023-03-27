#Include "Protheus.ch"

/*/{Protheus.doc} M4601DUP_PE
Ponto de entrada ara ajustar o campo E1_PARCELA na geração da nota fiscal de saida

@author Leonardo Miranda
@since 24/03/2021
@version 1.0
@return ${return}

@type function
/*/

************************
User Function M4601DUP()
************************

Local cRetorno As Varchar

cRetorno := ParamIxb[01]
If Empty(Alltrim(cRetorno))
    cRetorno := "1"
EndIf

Return(cRetorno)
