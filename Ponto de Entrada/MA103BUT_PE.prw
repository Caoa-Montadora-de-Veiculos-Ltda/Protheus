
/*=====================================================================================
Programa.:              MA103BUT
Autor....:              CAOA - Valter Carvalho
Data.....:              21/02/2021
Descricao / Objetivo:   Cria um menu na tela doc entrada,
                        feito uma vez para corrigir os cadastros  do eic    
Solicitante:            Barbara
Uso......:              EIC
===================================================================================== */
User Function MA103BUT()
     Local aButtons := {}

     If FindFunction("U_ZCOMF039")
          Aadd(aButtons, {'', {|| FWMsgRun(, {|| U_ZCOMF039() }, "", "Alterando TES..." ) }, '>>> CAOA - Informar TES itens'})
     Endif

Return (aButtons)
