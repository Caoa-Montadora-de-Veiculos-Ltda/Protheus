#Include "Protheus.Ch" 
#Include "TopConn.Ch" 
/* 
{Protheus.doc} MT120FOL
Ponto de Entrada que monta a dialog do pedido de compras após  a criação do objeto
@author    A.Carlos
@version   12.1.27
@since     13/04/2023
@param 
*/
User Function MT120FOL()
Local aArea     := GetArea()
Local nOpcx     := PARAMIXB[1]
Local aPosGet   := PARAMIXB[2]
Local nCombo    := {"S-Sim","N-Nao"}
Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  9, .T., .F.) //Somente será editável, na Inclusão, Alteração e Cópia
Local oXFCA
Public cXFCA    := Space(1)

    //Define aposição para os novos campos na enchoice
    aadd(aPosGet[3],6)  
    aPosGet[3,6]:=185.322
    aadd(aPosGet[3],7)  
    aPosGet[3,7]:=215.322

    cXFCA := SC7->C7_XFCA
    oXFCA := cXFCA

    @ 009,aPosGet[3,6] SAY Alltrim(RetTitle("C7_XFCA")) OF oFolder:aDialogs[3] PIXEL SIZE 030,006 
    @ 008,aPosGet[3,7] MSCOMBOBOX  oXFCA  VAR  cXFCA   ITEMS  nCombo SIZE  030,006 OF oFolder:aDialogs[3] PIXEL
    
    cXFCA := nCombo
    
    oXFCA:bHelp := {|| ShowHelpCpo( "C7_XFCA", {GetHlpSoluc("C7_XFCA")[1]}, 5 )}
 
    //Se não houver edição, desabilita os gets
    If !lEdit
        oXFCA:lActive := .F.
    EndIf
  
    RestArea(aArea)
 
Return Nil 

