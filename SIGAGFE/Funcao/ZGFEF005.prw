#Include "PROTHEUS.CH"
#Include "TOTVS.CH"

/*
================================================================
Programa...:    ZGFEF005
Autor......:    CAOA - Fagner Barreto
Data.......:    12/05/2022
Descricao..:    Seleciona centro de custo por marca
Obs........:    Substituiu o PE GFEA0658 feito por Juarez AMS
================================================================
*/
User Function ZGFEF005()
    Local aArea		:= GetArea()
    Local aAreaGW4  := GW4->( GetArea() )
    Local aAreaVS1  := VS1->( GetArea() )
    Local aAreaGW1  := GW1->( GetArea() )
    Local aAreaSF1  := SF1->( GetArea() )
    Local aAreaSD1  := SD1->( GetArea() )
    Local aAreaSB1  := SB1->( GetArea() )
    Local aAreaSBM  := SBM->( GetArea() )
    Local aAreaGW8  := GW8->( GetArea() )
    Local cCusto    := ""
    Local cEmissDF  := GW3->GW3_EMISDF
    Local cNumDF    := GW3->GW3_NRDF
    Local cSerDF    := GW3->GW3_SERDF
    Local cCDESP    := GW3->GW3_CDESP
    Local cDtEmis   := DTOS(GW3->GW3_DTEMIS)
    Local cChvDC    := ""
    Local lAchou    := .F.
    Local cCodProd  := ""
    Local cPritDf   := ""
    Local lRet      := .F.
    Local cTpDoc    := ""

    GW4->( DbSetOrder( 1 ) ) //--GW4_FILIAL + GW4_EMISDF + GW4_CDESP + GW4_SERDF + GW4_NRDF + DTOS(GW4_DTEMIS) + GW4_EMISDC + GW4_SERDC + GW4_NRDC + GW4_TPDC
    VS1->( DbSetOrder( 3 ) ) //--VS1_FILIAL + VS1_NUMNFI + VS1_SERNFI
    GW1->( DbSetOrder( 1 ) ) //--GW1_FILIAL + GW1_CDTPDC + GW1_EMISDC + GW1_SERDC + GW1_NRDC
    SF1->( DbSetOrder( 8 ) ) //--F1_FILIAL + F1_CHVNFE
    SD1->( DbSetOrder( 1 ) ) //--D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM
    SB1->( DbSetOrder( 1 ) ) //--B1_FILIAL + B1_COD
    SBM->( DbSetOrder( 1 ) ) //--BM_FILIAL + BM_GRUPO
    GW8->( DbSetOrder( 2 ) ) //--GW8_FILIAL + GW8_CDTPDC + GW8_EMISDC + GW8_SERDC + GW8_NRDC + GW8_SEQ
    
    If GW4->( MsSeek( FWxFilial("GW4") + cEmissDF + cCDESP + cSerDF + cNumDF + cDtEmis ) )
        
        cTpDoc := AllTrim( GW4->GW4_TPDC )
        
        //--Faz a gravação automatica do custo somente se não estiver preenchido
        If Empty( GW3->GW3_CC )

            While GW4->( !Eof() ) .And. GW4->( GW4_FILIAL + GW4_EMISDF + GW4_CDESP + GW4_SERDF + GW4_NRDF + DTOS(GW4_DTEMIS) ) == ( FWxFilial("GW4") + cEmissDF + cCDESP + cSerDF + cNumDF + cDtEmis )
                
                cChvDC := Alltrim(GW4->GW4_NRDC) + GW4->GW4_SERDC
                
                //--GW4_TPDC --> NFS
                If VS1->( MsSeek( FWxFilial("VS1") + cChvDC ) )
                    
                    cPritDf := "FR002"

                    If VS1->VS1_XMARCA = "HYU"
                        cCusto := "53020509MA"
                        Exit
                    EndIf
                    
                    If VS1->VS1_XMARCA = "SBR"
                        cCusto := "53110509MA"
                    EndIf
                    
                    If VS1->VS1_XMARCA = "CHE"
                        cCusto := "53290509MA"    
                        Exit        
                    EndIf

                ElseIf cTpDoc = "NFD"

                    cPritDf := "FR003"

                    If GW1->( MsSeek( FWxFilial("GW1") + GW4->( GW4_TPDC + GW4_EMISDC + GW4_SERDC + GW4_NRDC ) ) )

                        While GW1->( !Eof() ) .And.;
                            GW4->( GW4_FILIAL + GW4_TPDC + GW4_EMISDC + GW4_SERDC + GW4_NRDC ) == GW1->( GW1_FILIAL + GW1_CDTPDC + GW1_EMISDC + GW1_SERDC + GW1_NRDC )

                            If SF1->( MsSeek( FWxFilial("SF1") + GW1->GW1_DANFE ) )

                                If SD1->( MsSeek( FWxFilial("SD1") + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) ) )

                                    cChvDC := Alltrim(SD1->D1_NFORI) + SD1->D1_SERIORI
                                
                                    If VS1->( MsSeek( FWxFilial("VS1") + cChvDC ) )
                                        //--Se encontrou Hyundai pode sair, pois pode ter Subaru junto, mas vai para o Centro de custo Hyundai
                                        If VS1->VS1_XMARCA = "HYU"
                                            lAchou  := .T.
                                            cCusto    := "53020509MA"
                                            Exit
                                        EndIf
                                        If VS1->VS1_XMARCA = "SBR"
                                            //--Se encontrou Subaru continua procurando para ver se não tem Hyundai no mesmo doc frete
                                            cCusto := "53110509MA"
                                        EndIf
                                        If VS1->VS1_XMARCA = "CHE"
                                            //--Se encontrou Chery pode sair, pois Chery não sai com outras marcas
                                            lAchou  := .T.
                                            cCusto    := "53290509MA"    
                                            Exit        
                                        EndIf

                                    EndIf
                                    
                                EndIf

                            EndIf

                            GW1->( DbSkip() )
                        EndDo

                    EndIf    

                    //--Se achou VS1 faz a saida do while
                    If lAchou
                        Exit
                    EndIf

                ElseIf cTpDoc $ "NFE|NFI"
                    
                    cPritDf := "FR003"

                    If GW3->GW3_CDREM = '000005999'
                        lAchou  := .T.
                        cCusto := "53110509MA"    
                    ElseIf GW3->GW3_CDREM = '000006001' 
                        lAchou  := .T.                  
                        cCusto := "53110509MA"    
                    ElseIf GW3->GW3_CDREM = '000005973'
                        lAchou  := .T.
                        cCusto := "53020509MA"    
                    ElseIf GW3->GW3_CDREM = '000006000'
                        lAchou  := .T.
                        cCusto := "53290509MA"    
                    EndIf 

                    //--Se não preencher, busca através dos produtos da nota
                    If !lAchou

                        If GW1->( MsSeek( FWxFilial("GW1") + GW4->( GW4_TPDC + GW4_EMISDC + GW4_SERDC + GW4_NRDC ) ) )

                            While GW1->( !Eof() ) .And.;
                                GW1->( GW1_FILIAL + GW1_CDTPDC + GW1_EMISDC + GW1_SERDC + GW1_NRDC ) == GW4->( GW4_FILIAL + GW4_TPDC + GW4_EMISDC + GW4_SERDC + GW4_NRDC )

                                If GW8->( MsSeek( FWxFilial("GW8") + GW1->( GW1_CDTPDC + GW1_EMISDC + GW1_SERDC + GW1_NRDC ) ) )

                                    While GW8->( !Eof() ) .And.;
                                        GW8->( GW8_FILIAL + GW8_CDTPDC + GW8_EMISDC + GW8_SERDC + GW8_NRDC ) == GW1->( GW1_FILIAL + GW1_CDTPDC + GW1_EMISDC + GW1_SERDC + GW1_NRDC )               
                                        
                                        cCodProd := GW8->GW8_ITEM

                                        //--AcCustocenta o "R-" no inicio, se não houver, para realizar a busca do produto na SB1
                                        //--Foi definido que todos os produtos de Barueri serão cadastrados dessa forma
                                        If SubStr( cCodProd, 1, 2 ) <> "R-"
                                            cCodProd := "R-" + cCodProd  
                                        EndIf

                                        If SB1->( MsSeek( FWxFilial("SB1") + cCodProd ) )

                                            If SBM->( MsSeek( FWxFilial("SBM") + SB1->B1_GRUPO ) )

                                                If SBM->BM_CODMAR  = "HYU"
                                                    //--Se encontrou Hyundai pode sair, pois pode ter Subaru junto, mas vai para o Centro de custo Hyundai
                                                    lAchou  := .T.
                                                    cCusto    := "53020509MA"
                                                    Exit

                                                ElseIf SBM->BM_CODMAR = "SBR"
                                                    //--Se encontrou Subaru continua procurando para ver se não tem Hyundai no mesmo doc frete
                                                    cCusto := "53110509MA"

                                                ElseIf SBM->BM_CODMAR = "CHE"
                                                    //--Se encontrou Chery pode sair, pois Chery não sai com outras marcas
                                                    lAchou  := .T.
                                                    cCusto    := "53290509MA"    
                                                    Exit

                                                EndIf
                                            
                                            EndIf

                                        EndIf

                                        GW8->( DbSkip() )
                                    EndDo

                                EndIf

                                //--Se achou custo faz a saida do while
                                If lAchou
                                    Exit
                                EndIf

                                GW1->( DbSkip() )
                            EndDo

                        EndIf

                    EndIf
                    
                    //--Se achou custo faz a saida do while
                    If lAchou
                        Exit
                    EndIf

                ElseIf cTpDoc = "TRG"
                    
                    cPritDf := "FR002"

                    If GW1->( MsSeek( FWxFilial("GW1") + GW4->( GW4_TPDC + GW4_EMISDC + GW4_SERDC + GW4_NRDC ) ) )

                        While GW1->( !Eof() ) .And.;
                            GW1->( GW1_FILIAL + GW1_CDTPDC + GW1_EMISDC + GW1_SERDC + GW1_NRDC ) == GW4->( GW4_FILIAL + GW4_TPDC + GW4_EMISDC + GW4_SERDC + GW4_NRDC )

                            If GW8->( MsSeek( FWxFilial("GW8") + GW1->( GW1_CDTPDC + GW1_EMISDC + GW1_SERDC + GW1_NRDC )  ) )

                                While GW8->( !Eof() ) .And.;
                                    GW8->( GW8_FILIAL + GW8_CDTPDC + GW8_EMISDC + GW8_SERDC + GW8_NRDC ) == GW1->( GW1_FILIAL + GW1_CDTPDC + GW1_EMISDC + GW1_SERDC + GW1_NRDC )               
                                    
                                    cCodProd := GW8->GW8_ITEM

                                    //--AcCustocenta o "R-" no inicio, se não houver, para realizar a busca do produto na SB1
                                    //--Foi definido que todos os produtos de Barueri serão cadastrados dessa forma
                                    If SubStr( cCodProd, 1, 2 ) <> "R-"
                                        cCodProd := "R-" + cCodProd  
                                    EndIf

                                    If SB1->( MsSeek( FWxFilial("SB1") + cCodProd ) )

                                        If SBM->( MsSeek( FWxFilial("SBM") + SB1->B1_GRUPO ) )

                                            If SBM->BM_CODMAR  = "HYU"
                                                //--Se encontrou Hyundai pode sair, pois pode ter Subaru junto, mas vai para o Centro de custo Hyundai
                                                lAchou  := .T.
                                                cCusto    := "53020509MA"
                                                Exit

                                            ElseIf SBM->BM_CODMAR = "SBR"
                                                //--Se encontrou Subaru continua procurando para ver se não tem Hyundai no mesmo doc frete
                                                cCusto := "53110509MA"

                                            ElseIf SBM->BM_CODMAR = "CHE"
                                                //--Se encontrou Chery pode sair, pois Chery não sai com outras marcas
                                                lAchou  := .T.
                                                cCusto    := "53290509MA"    
                                                Exit

                                            EndIf
                                        
                                        EndIf

                                    EndIf

                                    GW8->( DbSkip() )
                                EndDo

                            EndIf

                            //--Se achou custo faz a saida do while
                            If lAchou
                                Exit
                            EndIf

                            GW1->( DbSkip() )
                        EndDo

                    EndIf
                    
                    //--Se achou custo faz a saida do while
                    If lAchou
                        Exit
                    EndIf

                EndIf

                GW4->( DbSkip() )
            EndDo

            lRet := !Empty(cCusto)

            If lRet
                RecLock("GW3", .F.)
                GW3->GW3_CC     := cCusto 
                GW3->GW3_PRITDF := cPritDf
                If cPritDf == "FR003"
                    GW3->GW3_CONTA  := "5111101025" 
                    GW3->GW3_ITEMCT := "MT"
                EndIf
                GW3->(MsUnlock())
            EndIf

        Else

            If cTpDoc $ "TRG|NFS"
                cPritDf := "FR002"
            ElseIf cTpDoc $ "NFE|NFI|NFD"
                cPritDf := "FR003"
            EndIf

            //--Se o custo foi preenchido manualmente, preenche somente o produto do CTE
            lRet := !Empty(cPritDf)
            
            If lRet
                RecLock("GW3", .F.)
                GW3->GW3_PRITDF := cPritDf
                If cPritDf == "FR003"
                    GW3->GW3_CONTA  := "5111101025" 
                    GW3->GW3_ITEMCT := "MT"
                EndIf
                GW3->(MsUnlock())
            EndIf

        EndIf

    EndIf

    /* Quando a chamada for da rotina GFEA067 - Integrar doc frete, valida se o custo esta preenchido,
     se não estiver, grava INVALIDO para forçar a rejeição na geração do CTE */
    If FWIsInCallStack("GFEA067")
        If !lRet
            RecLock("GW3", .F.)
            GW3->GW3_CC := 'INVALIDO'
            GW3->(MsUnlock())  
        EndIf  
    EndIf

    RestArea(aAreaGW4)
    RestArea(aAreaVS1)
    RestArea(aAreaGW1)
    RestArea(aAreaSF1)
    RestArea(aAreaSD1)
    RestArea(aAreaSB1)
    RestArea(aAreaSBM)
    RestArea(aAreaGW8)
    RestArea(aArea)

Return lRet
