#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

/*
=====================================================================================
Programa.:              GFEA042_PE.PRW
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              05/01/24
Descricao / Objetivo:   Ponto de entrada para Inclus�o de Nova Op��o no Menu (menudef)
Doc. Origem:            GAP032
Solicitante:            Micaellen Leal
Uso......:              Inserir op��ono menu de outras a��es.
Obs......:              https://tdn.totvs.com/pages/releaseview.action?pageId=239034846
=====================================================================================
*/


User Function GFEA0442()
 
    Local aRotina
    
    // Posi��es do Array
    // 1. Nome da op��o no menu   
    // 2. Nome da Rotina associada                                
    // 3. Usado pela rotina                                       
    // 4. Tipo de Opera��o a ser efetuada

    aRotina := { {"Itens", "U_zMsg()", 0, 4} }
 
 
Return aRotina


User Function zMsg(nRecGW1)
    Local aArea := FWGetArea()
    Local nRecGW1 := aArea[3] //Recno da posi��o atual.

        MsgInfo("Deu certo." + str(nRecGW1),"Aten��o")

    FwRestArea(aArea)
Return
