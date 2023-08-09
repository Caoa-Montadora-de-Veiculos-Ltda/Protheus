
/*=====================================================================================
Programa.:              EIC500MNU
Autor....:              CAOA - A.Carlos
Data.....:              08/08/2023
Descricao / Objetivo:   Cria um menu na tela desembaraço
Solicitante:            Taka
Uso......:              EIC
===================================================================================== */
User Function EIC500MNU()
     Local aButtons := {}

     If FindFunction("U_ZEICF022")
          Aadd(aButtons, {'', {|| FWMsgRun(, {|| U_ZEICF022() }, "", "Integração ASIA..." ) }, '>>> CAOA - Integração ASIA'})
     Endif

Return (aButtons)
