#Include "Protheus.CH"
#Include 'Totvs.CH'

//------------------------------------------------------------------------------------------
/* 
{Protheus.doc} VM010DNF
Ponto de Entrada Depois da Gravacao da Nota Fiscal
@author    Leonardo Miranda
@version   12.1.27
@since     27/05/2022
*/
//------------------------------------------------------------------------------------------
User Function VM010DNF()

Local aArea     As Array
Local aVV0Area  As Array
Local aVV9Area  As Array

aAreas    := GetArea()
aVV0Area  := VV0->(GetArea())
aVV9Area  := VV9->(GetArea())

DbSelectArea("VV0")
VV0->(DbSetOrder(4))
If VV0->(Dbseek(xfilial("VV0")+SF2->F2_DOC+SF2->F2_SERIE))
    VV9->(DbSetOrder(1))
    If VV9->(Dbseek(xfilial("VV0")+VV0->VV0_NUMTRA))
        VV9->(RecLock("VV9",.F.))
        VV9->VV9_VV9_XUMNFI := VV0->VV0_NUMNFI
        VV9->(MsUnLock())
    EndIf
EndIf

RestArea(aArea   )
RestArea(aVV0Area)
RestArea(aVV9Area)

Return(Nil)