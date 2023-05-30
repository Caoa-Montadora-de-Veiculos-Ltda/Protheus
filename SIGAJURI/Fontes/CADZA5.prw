
#Include "Protheus.ch"
 

 
User Function CADZA5()
    Local aArea    := GetArea()
    Local aAreaZA5  := ZA5->(GetArea())
    Local cDelOk   := "u_za5del()"
    Local cFunTOk  := "u_za5val()" //Pode ser colocado como "u_zVldTst()"
 
    //Chamando a tela de cadastros
    AxCadastro('ZA5', 'Cadastro de Diretorias', cDelOk, cFunTOk)
 
    RestArea(aAreaZA5)
    RestArea(aArea)
Return


User function za5del()

    local lRet := MsgNoYes("Tem certeza que deseja excluir o registro","Confirmação")

return lRet

user function za5val()
local lRet
local cMsg

    if INCLUI
        cMsg := "Confirma a Inclusão do Registro?"

    else 
        cMsg := "Confirma a Alteração do Registro"

    endif

    lRet := MsgNoYes(cMsg,"Confirmação")

RETURN lRet
