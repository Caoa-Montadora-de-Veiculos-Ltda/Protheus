#Include "PROTHEUS.CH"
#Include "TOTVS.CH"

/*
===========================================================================================
Programa.:              ZGFEF001
Autor....:              CAOA - Fagner Barreto
Data.....:              25/03/2022
Descricao / Objetivo:   Prepara registros para envio a rotina de gravação dos pesos bruto 
                        e cubado na tabela GW8   
===========================================================================================
*/
User Function ZGFEF001( cDoc, cSerie, cCliente, cLoja )
    Local aAreaSF2  :=  SF2->( GetArea() )
    Local aAreaSD2  :=  SD2->( GetArea() )
    Local cAliasSD2 :=  ""
    Local cValNfGFE	:=  AllTrim( GetMV('MV_GFEVLIT') )
    Local aDadosRat :=  {}
    Local cChave    := ""

    Default cDoc        :=  ""
    Default cSerie      :=  ""
    Default cCliente    :=  ""
    Default cLoja       :=  ""

	SF2->( DbSetOrder(1) ) //-- F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA  
	SD2->( DbSetOrder(3) ) //-- D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM

    If Empty(cCliente) .Or. Empty(cLoja)
        cChave := Padr( cDoc      ,TamSX3("F2_DOC")[1]  ) + Padr( cSerie    ,TamSX3("F2_SERIE")[1]  )
    Else
        cChave  :=  Padr( cDoc      ,TamSX3("F2_DOC")[1]    ) + Padr( cSerie    ,TamSX3("F2_SERIE")[1]  ) +;
                    Padr( cCliente  ,TamSX3("F2_CLIENTE")[1]  ) + Padr( cLoja     ,TamSX3("F2_LOJA")[1]  )
    EndIf

    If SF2->( DbSeek( xFilial("SF2") +  cChave ) )

        //--Retorna valor total
        cAliasSD2 := GetNextAlias()
        BeginSql Alias cAliasSD2
            SELECT SUM( D2_VALBRUT) AS VLRBRUTO, SUM( D2_TOTAL ) AS VLRTOTAL
            FROM %Table:SD2% SD2
            WHERE SD2.D2_FILIAL = %xFilial:SD2%
            AND SD2.D2_DOC = %Exp:SF2->F2_DOC%
            AND SD2.D2_SERIE = %Exp:SF2->F2_SERIE%
            AND SD2.D2_CLIENTE = %Exp:SF2->F2_CLIENTE%
            AND SD2.D2_LOJA = %Exp:SF2->F2_LOJA%
            AND SD2.%NotDel%
        EndSql

        If (cAliasSD2)->( !Eof() )
            nVlrBruto := (cAliasSD2)->VLRBRUTO
            nVlrTotal := (cAliasSD2)->VLRTOTAL
        EndIf

        (cAliasSD2)->( DbCloseArea() )

        If SD2->( DbSeek( xFilial("SD2") + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) ) )
            While SD2->( !EOF() ) .And.;
                SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == xFilial("SD2") + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )

                AaDD( aDadosRat, { 	SD2->D2_DOC,;
                                    SD2->D2_SERIE,;
                                    SD2->D2_ITEM,;
                                    SD2->D2_COD,;
                                    SD2->D2_QUANT,;
                                    IIF( cValNfGFE == '1', SD2->D2_VALBRUT, SD2->D2_TOTAL),;
                                    SF2->F2_XPESOC,;
                                    SF2->F2_PBRUTO,;
                                    IIF( cValNfGFE == '1', nVlrBruto, nVlrTotal) } )

                SD2->( DbSkip() )
            EndDo

            U_zAtuPesGW8(	aDadosRat )

        EndIf

    EndIf

    RestArea( aAreaSD2 )
    RestArea( aAreaSF2 )

Return

/*
===========================================================================================
Programa.:              zAtuPesGW8
Autor....:              CAOA - Fagner Barreto
Data.....:              30/12/2021
Descricao / Objetivo:   Efetua a gravação dos pesos bruto e cubado na tabela GW8    
===========================================================================================
*/
/** */

User Function zAtuPesGW8( aDadosRat )
    Local aAreaSB1  := SB1->( GetArea() )
    Local aAreaSB5  := SB5->( GetArea() )
    Local cCriRat   := GetMv("MV_CRIRAT")
    Local cAliasQry := Nil
    Local nQtdItens := 0
    Local nPesBruB1 := 0
    Local nAltura   := 0
    Local nCompri   := 0
    Local nLargura  := 0
    Local nVolumTot := 0
    Local nVolumItem:= 0
    Local nPesTotal := 0
    Local nPesItem  := 0
    Local nPesCub   := 0
    Local nPesReal  := 0 
    Local nRecGW8   := 0
    Local nSobCub   := 0
    Local nSobBru   := 0
    Local nTotPesCub:= 0
    Local nTotPesBru:= 0
    Local nY        := 0
    Local aRecno    := {}    
    Local aRatCub   := {}
    Local aRatBru   := {}
    Local NOTA      := 1
    Local SERIE     := 2
    Local ITEM      := 3
    Local CODPROD   := 4
    Local QTDITEM   := 5
    Local TOTITEM   := 6
    Local PESCUB    := 7
    Local PESBRUT   := 8
    Local VALBRUT   := 9
    Local RECNOGW8  := 2

    Default aDadosRat := {}

    //--Ativa mais de uma area de trabalho
    SB1->( DbSetOrder(1) )
    SB5->( DbSetOrder(1) )

    For nY := 1 To Len( aDadosRat )

        cAliasQry := GetNextAlias()
        BeginSql Alias cAliasQry
            SELECT GW8.R_E_C_N_O_ AS RECGW8
            FROM %Table:GW8% GW8
            WHERE GW8.GW8_FILIAL = %xFilial:GW8%
            AND GW8.GW8_NRDC = %Exp:aDadosRat[nY][NOTA]%
            AND GW8.GW8_SERDC = %Exp:aDadosRat[nY][SERIE]%
            AND GW8.GW8_ITEM = %Exp:aDadosRat[nY][CODPROD]%
            AND GW8.GW8_SEQ = %Exp:aDadosRat[nY][ITEM]%
            AND GW8.%NotDel%
        EndSql

        If (cAliasQry)->( !Eof() )
            nRecGW8  := (cAliasQry)->RECGW8
        EndIf

        (cAliasQry)->( DbCloseArea() )
        
        If cCriRat == '1'

            //--Retorna quantidade total de todos os itens da NF
            cAliasQry := GetNextAlias()
            BeginSql Alias cAliasQry
                SELECT SUM(SD2.D2_QUANT) QTDTOTAL
                FROM %Table:SD2% SD2
                WHERE SD2.D2_FILIAL = %xFilial:SD2%
                AND SD2.D2_DOC = %Exp:aDadosRat[nY][NOTA]%
                AND SD2.D2_SERIE = %Exp:aDadosRat[nY][SERIE]%
                AND SD2.%NotDel%
            EndSql

            If (cAliasQry)->( !Eof() )
                nQtdItens := (cAliasQry)->QTDTOTAL
            EndIf

            (cAliasQry)->( DbCloseArea() )

            If SB1->( DbSeek( FWxFilial("SB1") + aDadosRat[nY][CODPROD] ) )
                nPesBruB1  := SB1->B1_PESBRU 
            EndIf

            If SB5->( DbSeek( FWxFilial("SB5") + aDadosRat[nY][CODPROD] ) )
                nAltura  := SB5->B5_ALTURA
                nCompri  := SB5->B5_COMPR
                nLargura := SB5->B5_LARG
            EndIf                
            
            nVolumTot   := ( nCompri * nAltura * nLargura ) * nQtdItens
            nVolumItem  := ( nCompri * nAltura * nLargura ) * aDadosRat[nY][QTDITEM]

            nPesTotal   := nPesBruB1 * nQtdItens
            nPesItem    := nPesBruB1 * aDadosRat[nY][QTDITEM]

            nPesCub     := ( aDadosRat[nY][PESCUB] / nVolumTot ) * nVolumItem
            nPesReal    := ( aDadosRat[nY][PESBRUT] / nPesTotal ) * nPesItem
            
            if nPesCub <= 0.01
                nPesCub := 0.01
            endif
            
            if nPesReal <= 0.01
                nPesReal := 0.01
            endif
            
            //--Guarda valor e recno GW8 para calculo de sobra no rateio    
            AaDD( aRatCub, {Round( nPesCub, TamSX3("F2_XPESOC")[2] )    , nRecGW8} )
            AaDD( aRatBru, {Round( nPesReal, TamSX3("F2_PBRUTO")[2] )   , nRecGW8} )
            
            if nRecGW8 > 0
                GW8->( DbGoTo(nRecGW8) )
                IF GW8->(!eof()) .and. GW8->(!bof())
                    RecLock("GW8", .F.)
                        GW8->GW8_PESOC := Round( nPesCub, TamSX3("F2_XPESOC")[2] )
                        GW8->GW8_PESOR := Round( nPesReal, TamSX3("F2_PBRUTO")[2] )
                    GW8->( MsUnLock() )
                EndIf
            EndIf
        
        ElseIf cCriRat == '2'

            nPesCub     := ( aDadosRat[nY][PESCUB] / aDadosRat[nY][VALBRUT] ) * aDadosRat[nY][TOTITEM] 
            nPesReal    := ( aDadosRat[nY][PESBRUT] / aDadosRat[nY][VALBRUT] ) * aDadosRat[nY][TOTITEM]
            
            if nPesCub <= 0.01
                nPesCub := 0.01
            endif
            
            if nPesReal <= 0.01
                nPesReal := 0.01
            endif
            
            //--Guarda valor e recno GW8 para calculo de sobra no rateio    
            AaDD( aRatCub, {Round( nPesCub, TamSX3("F2_XPESOC")[2] )    , nRecGW8} )
            AaDD( aRatBru, {Round( nPesReal, TamSX3("F2_PBRUTO")[2] )   , nRecGW8} )

            If nRecGW8 > 0
                GW8->( DbGoTo(nRecGW8) )
                IF GW8->(!eof()) .and. GW8->(!bof())
                    RecLock("GW8", .F.)
                    GW8->GW8_PESOC := Round( nPesCub, TamSX3("F2_XPESOC")[2] )
                    GW8->GW8_PESOR := Round( nPesReal, TamSX3("F2_PBRUTO")[2] )
                    GW8->( MsUnLock() )
                EndIf
            EndIf

        EndIf

    Next

    //--Verifica sobra no rateio de Peso Cubado
    For nY := 1 To Len(aRatCub)
        nTotPesCub := nTotPesCub + aRatCub[nY][1]
    Next

    nSobCub := aDadosRat[1][PESCUB]  - nTotPesCub 
  
    //--Verifica sobra no rateio de Peso Bruto
    For nY := 1 To Len(aRatBru)
        nTotPesBru := nTotPesBru + aRatBru[nY][1]
    Next

    nSobBru := aDadosRat[1][PESBRUT] - nTotPesBru 

    //--Pega o recno do ultimo registro da GW8
    aRecno := aTail(aRatCub) 

    //--Realiza o acerto no ultimo registro da GW8 se houver sobra
    If (nSobCub <> 0 .Or. nSobBru <> 0 ) .and. aRecno[RECNOGW8] > 0
        
        GW8->( DbGoTo(aRecno[RECNOGW8]) )
        IF GW8->(!eof()) .and. GW8->(!BOF())
            RecLock("GW8", .F.)
            
                If nSobCub <> 0
                    GW8->GW8_PESOC := iif(( GW8->GW8_PESOC + nSobCub ) >= 0.01 , GW8->GW8_PESOC + nSobCub , 0.01)
                EndIf

                If nSobBru <> 0
                    GW8->GW8_PESOR := iif(( GW8->GW8_PESOR + nSobBru ) >= 0.01 , GW8->GW8_PESOR + nSobBru , 0.01) 
                EndIf

            GW8->( MsUnLock() )
        EndIf

    EndIf

    RestArea(aAreaSB1)
    RestArea(aAreaSB5)

Return
