#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} VX000AIN()
Ponto de entrada no processo de devolução de nota fiscal do SIGAVEI para acerto de valores.
Somente para o processsamento de devolução em lote

@author Leonardo Miranda
@since 04/08/2022
@version 1.0
@return NIL
/*/

User Function VX000AIN()

Local nPos          As Numeric
Local nVlrIcmsRet   As Numeric
Local nItem         As Numeric
Local nAtu          As Numeric
Local lImpLote      As Logical
Local lDevolve      As Logical
Local aArea         As Array
Local aSD2Area      As Array

aArea    := GetArea()
aSD2Area := SD2->(GetArea())
lImpLote := .F.
lDevolve := .F.
nAtu     := 0 
While ! Empty(ProcName(nAtu))
  If (Upper(Alltrim(ProcName(nAtu))) == "U_CMVVEIXX"    .Or. Upper(Alltrim(ProcName(nAtu))) == "CMVVEIXX"    ) ; lImpLote := .T. ; EndIf
  If (Upper(Alltrim(ProcName(nAtu))) == "U_DEVOLVEDOCS" .Or. Upper(Alltrim(ProcName(nAtu))) == "DEVOLVEDOCS" ) ; lDevolve := .T. ; EndIf
  nAtu ++
End

If Upper(Alltrim(FunName())) == "VEIXA002" .And. ;
   lImpLote                                .And. ;
   lDevolve                                .And. ;
   Paramixb[01]              == 3          .And. ;
   Paramixb[02]              == "5"        .And. ;
   ValType(aTemp)            == "A"

    nVlrIcmsRet := 0
    nItem       := 1
    SD2->(DbSetOrder(3))
    SD2->(DbSeek(xFilial("SD2")+(cCabAlias)->F2_DOC+(cCabAlias)->F2_SERIE+(cCabAlias)->F2_CLIENTE+(cCabAlias)->F2_LOJA))
    While SD2->(!Eof()) .And. SD2->D2_DOC     == (cCabAlias)->F2_DOC    ;
                        .And. SD2->D2_SERIE   == (cCabAlias)->F2_SERIE  ;
                        .And. SD2->D2_CLIENTE == (cCabAlias)->F2_CLIENTE;
                        .And. SD2->D2_LOJA    == (cCabAlias)->F2_LOJA

        nVlrIcmsRet += SD2->D2_ICMSRET
        
        nPos := aScan(aTemp , {|x,y| x[1] == "D1_ICMSRET"})
        If nPos <> 0 ; aTemp[nPos,02]         := SD2->D2_ICMSRET ; EndIf
        
        nPos := aScan(aIteNFE[nItem] , {|x,y| x[1] == "D1_ICMSRET"})
        If nPos <> 0 ; aIteNFE[nItem,nPos,02] := SD2->D2_ICMSRET ; EndIf

        nPos := aScan(aHeader , {|x,y| x[2] == "VVG_ICMRET"})
        If nPos <> 0 ; aCols[nItem,23]        := SD2->D2_ICMSRET ; EndIf

        nPos := aScan(aIteNFE[nItem] , {|x,y| x[1] == "D1_NFORI"})
        If nPos == 0 ; Aadd(aIteNFE[nItem],{"D1_NFORI"   ,SD2->D2_DOC   ,Nil}) ; EndIf

        nPos := aScan(aIteNFE[nItem] , {|x,y| x[1] == "D1_SERIORI"})
        If nPos == 0 ; Aadd(aIteNFE[nItem],{"D1_SERIORI" ,SD2->D2_SERIE ,Nil}) ; EndIf

        nPos := aScan(aIteNFE[nItem] , {|x,y| x[1] == "D1_ITEMORI"})
        If nPos == 0 ; Aadd(aIteNFE[nItem],{"D1_ITEMORI" ,SD2->D2_ITEM  ,Nil}) ; EndIf

        SD2->(DbSkip())
        nItem ++
    End

    nPos := aScan(aCabNFE , {|x,y| x[1] == "F1_ICMSRET"})
    If nPos                   <> 0   ; aCabNFE[nPos,02] := nVlrIcmsRet ; EndIf
    If ValType(M->VVF_ICMRET) == "N" ; M->VVF_ICMRET    := nVlrIcmsRet ; EndIf
    If ValType(M->VVG_ICMRET) == "N" ; M->VVG_ICMRET    := nVlrIcmsRet ; EndIf

EndIf

RestArea(aSD2Area)
RestArea(aArea   )

Return(.T.)