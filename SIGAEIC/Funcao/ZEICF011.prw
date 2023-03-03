/*=====================================================================================
Programa.:              ZEICF011
Autor....:              CAOA - Valter Carvalho
Data.....:              17/03/2020
Descricao / Objetivo:   Efetua o preenchimento de dados financeiros das despesas que são inseridas
                        manualmente na tela EIC
Doc. Origem:
Solicitante:            Evandro Mariano
Uso......:              Gatilhado na E2_VENCTO          
=====================================================================================*/

User Function ZEICF011()

     FWMsgRun(, {|| xPreenche(), Sleep(500) }, "", "Dados financeiros despesa...")  // Ajuste SWN a psrtir da SWN

Return M->E2_VENCTO

Static Function xPreenche()

     DbSelectArea("SYB")
     SYB->(DbSetOrder(1))

     If SYB->(DbSeek( FwXfilial("SYB") + WD_DESPESA)) = .T.
          
          M->E2_TIPO        := SYB->YB_XFINTIP
          M->E2_NATUREZ     := SYB->YB_XFINAT
          M->E2_FORNECE     := SYB->YB_XFINFOR
          M->E2_LOJA        := SYB->YB_XFINLOJ
          M->E2_PARCELA     := SYB->YB_XFINPAR

     EndIf

Return
