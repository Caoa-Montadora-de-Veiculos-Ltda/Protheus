#Include "PROTHEUS.CH"
#Include "TOTVS.CH"

/*
===========================================================================================
Programa.:              ZGFEF006
Autor....:              CAOA - Reinaldo Rabelo
Data.....:              17/05/2022
Descricao / Objetivo:   Prepara registros para envio a rotina de gravação dos valores 
                        bruto na tabela GW8   
===========================================================================================
*/
User Function ZGFEF006( cDoc, cSerie,cTipo cFornece, cLoja )
    Local aAreaSF1  :=  SF1->( GetArea() )
    Local aAreaSD1  :=  SD1->( GetArea() )
    Local cAliasSD1 :=  ""
    Local aDadosRat :=  {}
    Local cChave    := ""
    Local nTotal    := 0

    Default cDoc        :=  ""
    Default cSerie      :=  ""
    Default cFornece    :=  ""
    Default cLoja       :=  ""
    Default cTipo       :=  ""

	SF1->( DbSetOrder(1) ) //-- F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA  
	SD1->( DbSetOrder(3) ) //-- D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM

    If Empty(cFornece) .Or. Empty(cLoja)
        cChave := Padr( cDoc      ,TamSX3("F1_DOC")[1]  ) + Padr( cSerie    ,TamSX3("F1_SERIE")[1]  )
    Else
        cChave  :=  Padr( cDoc      ,TamSX3("F1_DOC")[1]    ) + Padr( cSerie    ,TamSX3("F1_SERIE")[1]  ) +;
                    Padr( cFornece  ,TamSX3("F1_FORNECE")[1]) + Padr( cLoja     ,TamSX3("F1_LOJA")[1]  )
    EndIf

    If SF1->( DbSeek( xFilial("SF1") +  cChave ) )

        //--Retorna valor total
        cAliasSD1 := GetNextAlias()
        BeginSql Alias cAliasSD1
            SELECT D1_COD,D1_ITEM,D1_TOTAL, D1_II,D1_DESPESA, D1_VALIMP5,D1_VALIMP6,D1_VALIPI,D1_VALICM,D1_ICMSRET
            FROM %Table:SD1% SD1
            WHERE SD1.D1_FILIAL = %xFilial:SD1%
            AND SD1.D1_DOC = %Exp:SF1->F1_DOC%
            AND SD1.D1_SERIE = %Exp:SF1->F1_SERIE%
            AND SD1.D1_FORNECE = %Exp:SF1->F1_FORNECE%
            AND SD1.D1_LOJA = %Exp:SF1->F1_LOJA%
            AND SD1.%NotDel%
        EndSql
        
        nValBruto := SF1->F1_VALBRUT
        
        While (cAliasSD1)->( !EOF() )
                nTotal := (cAliasSD1)->D1_TOTAL 
                nTotal += (cAliasSD1)->D1_II
                nTotal += (cAliasSD1)->D1_DESPESA 
                nTotal += (cAliasSD1)->D1_VALIMP5 
                nTotal += (cAliasSD1)->D1_VALIMP6 
                nTotal += (cAliasSD1)->D1_VALIPI 
                nTotal += (cAliasSD1)->D1_VALICM
                nTotal += (cAliasSD1)->D1_ICMSRET
                nValBruto := nValBruto - nTotal

                AaDD( aDadosRat, { 	SF1->F1_DOC,;
                                    SF1->F1_SERIE,;
                                    (cAliasSD1)->D1_ITEM,;
                                    (cAliasSD1)->D1_COD,;
                                    nTotal,;
                                    nValBruto } )

            (cAliasSD1)->( DbSkip() )
        EndDo
          zAtuPesGW8(	aDadosRat )

    EndIf

    RestArea( aAreaSD1 )
    RestArea( aAreaSF1 )

Return

/*
===========================================================================================
Programa.:              zAtuPesGW8
Autor....:              CAOA - Reinaldo Rabelo
Data.....:              17/05/2022
Descricao / Objetivo:   Efetua a gravação dos valor bruto GW8    
===========================================================================================
*/
Static Function zAtuPesGW8( aDadosRat )
    Local aAreaSB1  := SB1->( GetArea() )
    Local aAreaSB5  := SB5->( GetArea() )
    Local cAliasQry := Nil
    Local nRecGW8   := 0
    Local nY        := 0
    Local NOTA      := 1
    Local SERIE     := 2
    Local ITEM      := 3
    Local CODPROD   := 4
 

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
        
        if nRecGW8 > 0
            GW8->( DbGoTo(nRecGW8) )
            RecLock("GW8", .F.)
            IF nY >= Len( aDadosRat )
                GW8->GW8_VALOR := aDadosRat[nY,5] +aDadosRat[nY,6]
            ELSE
                GW8->GW8_VALOR := aDadosRat[nY,5]
            ENDIF
            GW8->( MsUnLock() )                
        ENDIF
    Next

    RestArea(aAreaSB1)
    RestArea(aAreaSB5)

Return
