#Include "Protheus.ch"
 
/*/{Protheus.doc} zTeste
Função de Teste
@type function
@author Terminal de Informação
@since 13/11/2016
@version 1.0
    @example
    u_zTeste()
/*/
 
User Function CADZA6()
    Local aArea    := GetArea()
    Local aAreaZA6  := ZA6->(GetArea())
    Local cDelOk   := "u_za6del()"
    Local cFunTOk  := "u_za6val()" //Pode ser colocado como "u_zVldTst()"
 
    //Chamando a tela de cadastros
    AxCadastro('ZA6', 'Cadastro de Diretores', cDelOk, cFunTOk)
 
    RestArea(aAreaZA6)
    RestArea(aArea)
Return


User function za6del()

    local lRet := MsgNoYes("Tem certeza que deseja excluir o registro","Confirma��o")

return lRet

user function za6val()
local lRet
local cMsg

    if INCLUI
        cMsg := "Confirma a Inclus�o do Registro?"

    else 
        cMsg := "Confirma a Altera��o do Registro"

    endif

    lRet := MsgNoYes(cMsg,"Confirma��o")

RETURN lRet
