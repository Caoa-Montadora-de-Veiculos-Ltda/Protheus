#Include "Protheus.ch"
 
/*/{Protheus.doc} zTeste
FunÃ§Ã£o de Teste
@type function
@author Terminal de InformaÃ§Ã£o
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

    local lRet := MsgNoYes("Tem certeza que deseja excluir o registro","Confirmação")

return lRet

user function za6val()
local lRet
local cMsg

    if INCLUI
        cMsg := "Confirma a Inclusão do Registro?"

    else 
        cMsg := "Confirma a Alteração do Registro"

    endif

    lRet := MsgNoYes(cMsg,"Confirmação")

RETURN lRet
