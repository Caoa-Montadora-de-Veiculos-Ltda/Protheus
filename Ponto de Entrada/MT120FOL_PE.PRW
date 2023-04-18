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
Local aCombo    := {"S-Sim","N-Nao"}
Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  9, .T., .F.) //Somente será editável, na Inclusão, Alteração e Cópia
Local oXFCA

    //Define aposição para os novos campos na enchoice
    aadd(aPosGet[3],6)  
    aPosGet[3,6]:=185.322
    aadd(aPosGet[3],7)  
    aPosGet[3,7]:=215.322

    IF Substr(cC7_XFCA,1,1) = 'N'
        cC7_XFCA := aCombo[2]
    ELSE
        cC7_XFCA := aCombo[1]
    ENDIF

    @ 009,aPosGet[3,6] SAY Alltrim(RetTitle("C7_XFCA")) OF oFolder:aDialogs[3] PIXEL SIZE 030,006 
    //@ 008,aPosGet[3,7] MSCOMBOBOX   oXFCA  VAR  cC7_XFCA  ITEMS  aCombo  ON CHANGE A120VldXFCA(cC7_XFCA) SIZE  030,006 OF oFolder:aDialogs[3] PIXEL
 	@ 008,aPosGet[3,7] Combobox cC7_XFCA ITEMS aCombo When .T. SIZE  030,006 OF oFolder:aDialogs[3] PIXEL
   
    //oXFCA:bHelp := {|| ShowHelpCpo( "C7_XFCA", {GetHlpSoluc("C7_XFCA")[1]}, 5 )}
 
    //Se não houver edição, desabilita os gets
    If !lEdit
        oXFCA:lActive := .F.
    EndIf
  
    RestArea(aArea)
 
Return Nil 
