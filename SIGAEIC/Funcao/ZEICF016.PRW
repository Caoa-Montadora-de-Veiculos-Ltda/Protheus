#Include "TopConn.ch"

#DEFINE CRLF  Char(13) + Char(10)

/* =====================================================================================
Programa.:              ZEICF016
Autor....:              CAOA - Valter Carvalho
Data.....:              15/12/2020
Descricao / Objetivo:   Valida notas emitidas de container
Doc. Origem:            
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              ZEICF015, PE_EICDI154
===================================================================================== */

User Function ZEICF016(cHawb, cTpNotas)
     Local aRes := {}

     If cTpNotas == "MAE"
     	FWMsgRun(, {|| aRes := getDocMae(cHawb) },"", "Listando as notas do processo: " + AllTrim(cHawb) )          
     Else
     	FWMsgRun(, {|| aRes := getDocFilha(cHawb) },"", "Listando as notas container do processo: " + AllTrim(cHawb) )          
     EndIf

Return aRes


/* retorna as notas do processo se for de mae*/
Static Function getDocMae(cHawb)
     Local cQr  := GetNextAlias()
     Local cmd  := ""
     Local aRes := {}

     cmd := " SELECT F1_DOC, F1_SERIE, F1_STATUS, F1_FORNECE, F1_LOJA" 
     cmd += " FROM " + RetSqlName("SF1") 
     cmd += " WHERE D_E_L_E_T_ = ' ' "
     cmd += " AND F1_FILIAL = '" + FwXfilial("SF1") + "' "
     cmd += " AND F1_HAWB   = '" + cHawb + "' "
     cmd += " ORDER BY F1_DOC "

     TcQuery cmd new alias (cQr)

     While (cQr)->(Eof()) = .F.

          Aadd( aRes, {(cQr)->F1_DOC, (cQr)->F1_SERIE, (cQr)->F1_STATUS, (cQr)->F1_FORNECE, (cQr)->F1_LOJA})

          (cQr)->(DbSkip())
     EndDo
     (cQr)->(DbCloseArea())

Return aRes


/* retorna as notas do processo se for de notas filhas*/
static function getDocFilha(cHawb)
     Local aSf1 := SF1->(GetArea()) 
     Local aSw2 := SW2->(GetArea()) 
     Local aSw6 := SW6->(GetArea()) 

     Local aDoc   := {}
     Local aRes := {}
     Local aNf  := {}
     Local i    := 1

     DbSelectArea("SW6")
     DbSetOrder(1)
     SW6->(DbSeek(FwxFilial("SW6") + cHawb ))     

     DbSelectArea("SW2")
     DbSetOrder(1)
     SW2->(DbSeek(FwxFilial("SW2") + SW6->W6_PO_NUM ))     
     
     aNf := Strtokarr(Alltrim(SW6->W6_XDOCFIL), Char(13) + Char(10))

     DbSelectArea("SF1")
     DbSetOrder(1)

     For i:=1 to Len(aNf)
          aDoc     := Separa(aNf[i], "/")
          aDoc[1]  := PadR(aDoc[1], TamSx3("F1_SERIE")[1], " ")

          If SF1->(DbSeek(FwxFilial("SF1") + aDoc[2] + aDoc[1] + SW2->W2_FORN + SW2->W2_FORLOJ)) = .T.
               Aadd(aRes, {SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_STATUS, SF1->F1_FORNECE, SF1->F1_LOJA})
          Endif
     Next

     RestArea(aSf1)
     RestArea(aSw6)
     RestArea(aSw2)
Return aRes
