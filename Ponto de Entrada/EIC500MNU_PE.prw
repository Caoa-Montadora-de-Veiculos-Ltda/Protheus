
/*=====================================================================================
Programa.:              EIC500MNU
Autor....:              CAOA - A.Carlos
Data.....:              08/08/2023
Descricao / Objetivo:   Cria um bot�o em Outras A��es na tela desembara�o
Solicitante:            Taka
Uso......:              EIC
===================================================================================== */
User Function EIC500MNU()
     Local aButtons := {}

     If FindFunction("U_ZEICF022")
          Aadd(aButtons, {'', {|| FWMsgRun(, {|| U_ZEICF022() }, "", "Integra��o ASIA..." ) }, '>>> CAOA - Integra��o ASIA'})
     Endif

Return (aButtons)
