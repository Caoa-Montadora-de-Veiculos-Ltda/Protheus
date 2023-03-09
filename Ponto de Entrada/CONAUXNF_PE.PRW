#Include 'Protheus.Ch'
#Include 'RwMake.Ch'
#Include 'Font.Ch'
#Include 'Colors.Ch'
#Include "TopConn.Ch"
#Include "TbiConn.CH"

/*/{Protheus.doc} CONAUXNF
Ponto de entrada para endereçamento automático da 
nota fiscal de devolução e geração de reserva e 
bloqueio  (VB0) do numero de série

@author Leonardo Miranda
@since 03/03/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

************************
User Function CONAUXNF()
************************

Local aArea      As Array
Local aSB1Area   As Array
Local aSC5Area   As Array
Local aSC6Area   As Array
Local aSF1Area   As Array
Local aSD1Area   As Array
Local aSF2Area   As Array
Local aSDAArea   As Array
Local aSDCArea   As Array
Local aSD2Area   As Array
Local cPedGer    As Character
Local cIteGer    As Character
Local aCampos    As Array
Local nY         As Numeric
Local aConteudo  As Array
Local aItens     As Array
Local aCab       As Array    
Local axItem     As Array
Local n_RecnoSc6 As Numeric
Local nQtdLib    As Numeric
Local lReservOk  As Logical
Local cNum       As Character

Private lMsHelpAuto As Logical
Private lMsErroAuto As Logical

Private lLiber   As Logical
Private lParcial As Logical
Private lTrans   As Logical
Private lCredito As Logical
Private lEstoque As Logical
Private lAvCred  As Logical
Private lAvEst   As Logical
Private lItLib   As Logical
Private oSay     As Object

aArea    := GetArea()        ; aSC5Area := SC5->(GetArea()) ; aSC6Area := SC6->(GetArea()) ; aSF1Area := SF1->(GetArea()) ; aSB1Area := SB1->(GetArea())
aSD1Area := SD1->(GetArea()) ; aSF2Area := SF2->(GetArea()) ; aSD2Area := SD2->(GetArea()) ; aSDAArea := SDA->(GetArea()) ; aSDCArea := SDC->(GetArea())

If Upper(Alltrim(FunName())) == "ZFATF019"
    aConteudo := {}
    aCampos   := {"C6_LOCALIZ","C6_CHASSI" ,"C6_NUMSERI","C6_XCODMAR","C6_XDESMAR","C6_XGRPMOD","C6_XDGRMOD","C6_XMODVEI","C6_XDESMOD",;
                  "C6_XSEGMOD","C6_XDESSEG","C6_XFABMOD","C6_XCORINT","C6_XCOREXT","C6_XPRCTAB","C6_XVLRPRD","C6_XVLRMVT","C6_XVLRVDA"}

    SD1->(DbSetOrder(1))
    SF2->(DbSetOrder(1))

    SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
    While SD1->(!Eof()) .And. SD1->D1_DOC     == SF1->F1_DOC     ;
                        .And. SD1->D1_SERIE   == SF1->F1_SERIE   ;
                        .And. SD1->D1_FORNECE == SF1->F1_FORNECE ;
                        .And. SD1->D1_LOJA    == SF1->F1_LOJA

        cPedGer := SD1->D1_NUMPV
        cIteGer := SD1->D1_ITEMPV

        SD2->(DbSetOrder(3))
        If SD2->(DbSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI))
            SC6->(DbSetOrder(1))
            If SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
                For nY := 1 To Len(aCampos)
                    Aadd(aConteudo,{aCampos[nY],&("SC6->"+aCampos[nY])})
                Next

                If SC6->(DbSeek(xFilial("SC6")+cPedGer+cIteGer))
                    SC6->(RecLock("SC6",.F.))
                    For nY := 1 To Len(aConteudo)
                       SC6->(FieldPut(FieldPos(aConteudo[nY,01]),aConteudo[nY,02]))
                    Next
                    SC6->(MsUnLock())
                EndIf
            EndIf

            SB1->(DbSetOrder(1))
            SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))

            SDA->(DbSetOrder(1))
            If SDA->(DbSeek(xFilial("SDA")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)) .And. SDA->DA_SALDO > 0

                aItens := {}
                aCab   := {{"DA_PRODUTO" ,SD1->D1_COD    ,Nil},;
                           {"DA_NUMSEQ"  ,SD1->D1_NUMSEQ ,Nil}}
        
                axItem := {{"DB_ITEM"    ,"0001"         ,Nil},;
                           {"DB_ESTORNO" ," "            ,Nil},;
                           {"DB_LOCALIZ" ,SD2->D2_LOCALIZ,Nil},;
                           {"DB_DATA"    ,dDataBase      ,Nil},;
                           {"DB_NUMSERI" ,SD2->D2_NUMSERI,Nil},;
                           {"DB_QUANT"   ,1              ,Nil}}
                Aadd(aItens,axItem)
        
                lMsErroAuto := .F.
                FWMsgRun(, {|oSay|  MATA265( aCab, aItens, 3) }, "Devolver Notas Fiscais", "Endereçando")
                If lMsErroAuto ; MostraErro() ; EndIf
            EndIf

            SDB->(DbSetOrder(1))
            If SDB->(DbSeek(xFilial("SDB")+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ))
                VV1->(DbSetOrder(2))
                If VV1->(DbSeek(xFilial("VV1")+SDB->DB_NUMSERI))
                    VV1->(RecLock("VV1",.F.))
                    VV1->VV1_SITVEI := "0"
                    VV1->VV1_ULTMOV := "E"
                    VV1->(MsUnLock())
                EndIf
            EndIf

            SDA->(DbSeek(xFilial("SDA")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
            If SDA->(Found()) .And. !lMsErroAutoVal .And. ValType(lGerPVDev) <> "U" .And. lGerPVDev .And. SDA->DA_SALDO == 0
                /*/
                ****************************************
                * Define Variaveis usados pelo MATA440 *
                ****************************************
                /*/
                lLiber   := .T. ; lParcial := .T. ; lTrans   := .F. ; lCredito := .T.
                lEstoque := .T. ; lAvCred  := .T. ; lAvEst   := .T. ; lItLib   := .T.
                lLibPed  := .F.

                SC6->(RecLock("SC6",.F.))
                SC6->C6_QTDLIB  := 1
                SC6->(MsUnLock())
                n_RecnoSc6 := SC6->(Recno())

                /*/
                *******************************
                * Efetua a Liberacao por item *
                *******************************
                /*/
                nQtdLib   := SC6->C6_QTDLIB
                nQtdLib   := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,lAvCred,lAvEst,lLiber,lTrans)

                SDC->(DbSetOrder(1))
                SDC->(DbGoTop())
                If SDC->(DbSeek(xFilial("SDC")+SC6->C6_PRODUTO      ;
                                              +SC6->C6_LOCAL        ;
                                              +"SC6"                ;
                                              +SC6->C6_NUM          ;
                                              +SC6->C6_ITEM         ;
                                              +SC9->C9_SEQUEN       ;
                                              +CriaVar("DC_LOTECTL");
                                              +CriaVar("DC_NUMLOTE");
                                              +SD2->D2_LOCALIZ      ;
                                              +SD2->D2_NUMSERI))

                    SC9->(RecLock("SC9",.F.))
                    SC9->C9_XCODMAR := SC6->C6_XCODMAR	; SC9->C9_XMODVEI := SC6->C6_XMODVEI ; SC9->C9_XSEGMOD := SC6->C6_XSEGMOD
                    SC9->C9_XFABMOD := SC6->C6_XFABMOD  ; SC9->C9_XCORINT := SC6->C6_XCORINT ; SC9->C9_XCOREXT := SC6->C6_XCOREXT
                    SC9->C9_XGRPMOD := ""
                    SC6->(MsUnLock())
                EndIf
            ElseIf SDA->(Found()) .And. !lMsErroAutoVal .And. ValType(lBlqNSer) <> "U" .And. lBlqNSer .And. SDA->DA_SALDO == 0
                cNum := GetSx8Num("SC0","C0_QUANT")
                SC8->(DbSetOrder(1))
                SC0->(MsSeek(xFilial("SC0")+cNum))
                While SC0->(Found())
                    lShowHelp := .T.
                    If ( __lSx8 )
                        ConfirmSx8()
                    EndIf
                    cNum := GetSx8Num("SC0","C0_QUANT")
                    SC0->(MsSeek(xFilial("SC0")+cNum))
                End
                aOperacao:= {1              ,; //[1] -> [Operacao : 1 Inclui,2 Altera,3 Exclui]
                             "NF"           ,; //[2] -> [Tipo da Reserva]
                             ""             ,; //[3] -> [Documento que originou a Reserva]
                             ""             ,; //[4] -> [Solicitante]
                             xFilial("SC0")}   //[5] -> [Filial da Reserva]
                lReservOk := a430Reserv(aOperacao,cNum,SD1->D1_COD,SD1->D1_LOCAL,1,{CriaVar("DC_LOTECTL"),CriaVar("DC_NUMLOTE"),SD2->D2_LOCALIZ,SD2->D2_NUMSERI})
                IF lReservOk
                    VV1->(DbSetOrder(2))
                    If VV1->(DbSeek(xFilial("VV1")+SD2->D2_NUMSERI))
                        RecLock("VB0", .t.)
                        VB0->VB0_FILIAL := xFilial("VB0")
                        VB0->VB0_CHAINT := VV1->VV1_CHAINT
                        VB0->VB0_DATBLO := Date()
                        VB0->VB0_HORBLO := Val(Left(Time(), 2) + Substr(Time(), 4, 2))
                        VB0->VB0_USUBLO := RetCodUsr()
                        VB0->VB0_MOTBLO := "DEVOLUCAO DE NOTA FISCAL"
                        VB0->VB0_DATVAL := Stod("20501231")
                        VB0->VB0_HORVAL := Val(Left(Time(), 2) + Substr(Time(), 4, 2))
                        VB0->(MsUnlock())
                    EndIf              
                EndIf
            EndIf
        EndIf
        SD1->(DbSkip())
    End
EndIf

RestArea(aSC5Area) ; RestArea(aSC6Area) ; RestArea(aSF1Area) ; RestArea(aSD1Area) ; RestArea(aSDCArea)
RestArea(aSF2Area) ; RestArea(aSD2Area) ; RestArea(aSDAArea) ; RestArea(aSB1Area) ; RestArea(aArea   )

Return(.T.)
