#Include "PROTHEUS.CH"
#Include "TOTVS.ch"

/*
===========================================================================================
Programa.: ZPECF016
Autor....: CAOA - Fagner Barreto
Data.....: 07/03/2022
Descricao / Objetivo: Atualiza preços de peça por UF
===========================================================================================
*/
User Function ZPECF016()
    Local aParamBox     := {}
    Local aRet          := {}
    Local cAviso        := ""
    Private aErr        := {}
    Private cEstadoDe   := Space(TamSX3("F7_EST")[1]) 
    Private cEstadoAte  := Space(TamSX3("F7_EST")[1]) 
    Private nIcmsImpor  := 0
    Private nIcmsInter  := 0
    Private nIcmsNorte  := 0

    aadd(aParamBox, {1, "Tabela de Preço"      , Space(TamSX3( 'DA0_CODTAB' )[1])   , ""                            , ""            , "DA0" , ""    , 020 , .T.})
    aadd(aParamBox, {1, "Produto De?"          , Space(TamSX3("B1_COD")[1])         , ""                            , ""            , ""    , ""    , 060, .F.})
    aadd(aParamBox, {1, "Produto Até?"         , Space(TamSX3("B1_COD")[1])         , ""                            , ""            , "ZZZZZZZZZ", "" , 060, .T.})
    aadd(aParamBox, {1, "Estado De?"           , cEstadoDe                          , ""                            , ""            , "12"  , ""    , 020, .F.})
    aadd(aParamBox, {1, "Estado Até?"          , cEstadoAte                         , ""                            , ""            , "12"  , ""    , 020, .T.})
    aadd(aParamBox, {1, "Icms Norte:"          , nIcmsNorte                         , PesqPict("SF7","F7_ALIQINT")  , "Positivo()"  , ""    , ""    , 040, .T.})
    aadd(aParamBox, {1, "Icms Importado:"      , nIcmsImpor                         , PesqPict("SF7","F7_ALIQINT")  , "Positivo()"  , ""    , ""    , 040, .T.})
    aadd(aParamBox, {1, "Icms Interestadual:"  , nIcmsInter                         , PesqPict("SF7","F7_ALIQINT")  , "Positivo()"  , ""    , ""    , 040, .T.})
    
    If ParamBox(aParamBox,"Preencha os Parametros para Atualização...",@aRet, , , , , , , , ,.T.,.T.)
    
        cEstadoDe  := aRet[4]
        cEstadoAte := aRet[5]
        nIcmsNorte := aRet[6]
        nIcmsImpor := aRet[7]
        nIcmsInter := aRet[8]

        If Empty( aRet[2] )
            If MsgYesNo("Parametro Produto De? não foi informado, desta forma todos os produtos serão considerados, deseja continuar?")
                /*  Tratamento necessario porque o banco não consegue tratar produto de branco a outro produto
                    e acaba retornando mais registros do que o esperado  */
                aRet[3] := "ZZZ"
            Else
                Return
            EndIf
        EndIf

        Processa({|| zProcPreco(aRet[2], aRet[3], aRet[1]) }    ,"Processando a atualização dos precos por UF..."	)

        If Len(aErr) > 0
            Aeval(aErr, {|x| cAviso += x + CHAR(13) + CHAR(10) } )
            
            EecView(cAviso, "Problemas encontrados na rotina:")
        Else
            MsgInfo("Tabela de preços atualizada com sucesso!")
        EndIf

    EndIf

Return

/*
===========================================================================================
Programa.: zProcPreco
Autor....: CAOA - Fagner Barreto
Data.....: 04/04/2022
Descricao / Objetivo: Processamento dos produtos que serão atualizados
===========================================================================================
*/
Static Function zProcPreco( cProdutDe, cProdutAte, cCodTab)
    Local cAliasDA0 := GetNextAlias()
    //-- Altera De/Ate para sempre respeitar ordem alfabetica
    Local cProdDe   := IIF( cProdutDe > cProdutAte, cProdutAte, cProdutDe)
    Local cProdAte  := IIF( cProdutAte > cProdutDe, cProdutAte, cProdutDe)

    BeginSql Alias cAliasDA0
        SELECT B1_COD, B1_IPI, B1_GRTRIB, B1_ORIGEM, B1_POSIPI, DA1_PRCVEN, B1_PICM, DA1.R_E_C_N_O_ as DA1REC
        FROM %Table:DA0% DA0
        INNER JOIN %Table:DA1% DA1
            ON DA1.DA1_FILIAL = %xFilial:DA1%
            AND DA1.DA1_CODTAB = DA0_CODTAB
            AND DA1.DA1_CODPRO BETWEEN %Exp:cProdDe% AND %Exp:cProdAte%
            AND DA1.%NotDel%
        INNER JOIN %Table:SB1% SB1
            ON SB1.B1_FILIAL = %xFilial:SB1%
            AND SB1.B1_COD = DA1_CODPRO
            //AND SB1.B1_GRTRIB IN( '100' , '200' ) //--Definido por Arlindo --> Criar parametro???
            AND SB1.%NotDel%
        WHERE DA0.DA0_FILIAL = %xFilial:DA0%
            AND DA0.DA0_CODTAB = %Exp:cCodTab%
            AND DA0.%NotDel%
    EndSql

    ProcRegua( (cAliasDA0)->( RecCount() ) )

    If (cAliasDA0)->( !Eof() )

        While (cAliasDA0)->( !Eof() )

            IncProc("Atualizado preco por UF. Produto: " + (cAliasDA0)->B1_COD )

            AtuPrcVend( (cAliasDA0)->B1_COD, (cAliasDA0)->B1_IPI, (cAliasDA0)->B1_GRTRIB, (cAliasDA0)->B1_ORIGEM,;
                        (cAliasDA0)->DA1_PRCVEN, (cAliasDA0)->DA1REC, (cAliasDA0)->B1_POSIPI, (cAliasDA0)->B1_PICM )

            (cAliasDA0)->( DbSkip() )

        EndDo

    Else
        Alert("Tabela de preço não localizada, por favor, verifique os parametros informados!")

        If Select( cAliasDA0 ) > 0
            (cAliasDA0)->( dbCloseArea() )
        EndIf

        Return

    EndIf

    If Select( cAliasDA0 ) > 0
        (cAliasDA0)->( dbCloseArea() )
    EndIf

Return

/*
===========================================================================================
Programa.: AtuPrcVend
Autor....: CAOA - Fagner Barreto
Data.....: 04/04/2022  
Descricao / Objetivo: Realiza a atualização dos preços por UF
===========================================================================================
*/
Static Function AtuPrcVend( cCodProd, nIPI, cGrpTrib, cOrigem, nPrcBase, nRecDA1, cCodNCM, nIcms)
    Local cAliasSF7     := GetNextAlias()
    Local cEstProtoc    := AllTrim( Posicione('SYD' ,1 ,xFilial('SYD') + cCodNCM ,'YD_XUFPROT' ) )
    Local nPrcIcms      := ( nPrcBase - ( ( nIcms * nPrcBase) / 100 ) )
    Local nPrcEst       := 0
    //-- Altera De/Ate para sempre respeitar ordem alfabetica
    Local cEstDe        := IIF( MV_PAR04 > MV_PAR05, MV_PAR05, MV_PAR04)
    Local cEstAte       := IIF( MV_PAR05 > MV_PAR04, MV_PAR05, MV_PAR04)
    Local nI            := 0
    Local cEstZF        := "AM|RO|AP|RO|AC"
    Local nOriIPI       := nIpi
    Local nTxPis        := SuperGetMV("MV_TXPIS"  )
    Local nTxCof        := SuperGetMV("MV_TXCOFIN")
    Local nAliqPis      := 0
    Local nAliqCof      := 0
    Local aEstados      :=  {   {"AC", .F.},;
                                {"AL", .F.},;
                                {"AM", .F.},;
                                {"AP", .F.},;                  
                                {"BA", .F.},;                  
                                {"CE", .F.},;                  
                                {"DF", .F.},;                  
                                {"ES", .F.},;                  
                                {"GO", .F.},;                  
                                {"MA", .F.},;                  
                                {"MG", .F.},;                  
                                {"MS", .F.},;                  
                                {"MT", .F.},;                  
                                {"PA", .F.},;                  
                                {"PB", .F.},;                  
                                {"PE", .F.},;                  
                                {"PI", .F.},;                  
                                {"PR", .F.},;                  
                                {"RJ", .F.},;                  
                                {"RN", .F.},;                  
                                {"RO", .F.},;                  
                                {"RR", .F.},;                  
                                {"RS", .F.},;                  
                                {"SC", .F.},;                  
                                {"SE", .F.},;                  
                                {"SP", .F.},;                  
                                {"TO", .F.} }
    
    Begin Transaction

        DA1->( DbGoTo(nRecDA1) )
        RecLock("DA1", .F.)

            //Gravar a data de alteração
            DA1->DA1_XDTALT := dDataBase
            
            DA1->DA1_XAC := Round( IIf( ( "AC" >= cEstadoDe .And. "AC" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XAC ), 2 )
            DA1->DA1_XAL := Round( IIf( ( "AL" >= cEstadoDe .And. "AL" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XAL ), 2 )
            DA1->DA1_XAM := Round( IIf( ( "AM" >= cEstadoDe .And. "AM" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XAM ), 2 )
            DA1->DA1_XAP := Round( IIf( ( "AP" >= cEstadoDe .And. "AP" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XAP ), 2 )
            DA1->DA1_XBA := Round( IIf( ( "BA" >= cEstadoDe .And. "BA" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XBA ), 2 )
            DA1->DA1_XCE := Round( IIf( ( "CE" >= cEstadoDe .And. "CE" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XCE ), 2 )
            DA1->DA1_XDF := Round( IIf( ( "DF" >= cEstadoDe .And. "DF" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XDF ), 2 )
            DA1->DA1_XES := Round( IIf( ( "ES" >= cEstadoDe .And. "ES" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XES ), 2 )
            DA1->DA1_XGO := Round( IIf( ( "GO" >= cEstadoDe .And. "GO" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XGO ), 2 )
            DA1->DA1_XMA := Round( IIf( ( "MA" >= cEstadoDe .And. "MA" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XMA ), 2 )
            DA1->DA1_XMG := Round( IIf( ( "MG" >= cEstadoDe .And. "MG" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsInter ) / 100 ) ) , DA1->DA1_XMG ), 2 )
            DA1->DA1_XMS := Round( IIf( ( "MS" >= cEstadoDe .And. "MS" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XMS ), 2 )
            DA1->DA1_XMT := Round( IIf( ( "MT" >= cEstadoDe .And. "MT" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XMT ), 2 )
            DA1->DA1_XPA := Round( IIf( ( "PA" >= cEstadoDe .And. "PA" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XPA ), 2 )
            DA1->DA1_XPB := Round( IIf( ( "PB" >= cEstadoDe .And. "PB" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XPB ), 2 )
            DA1->DA1_XPE := Round( IIf( ( "PE" >= cEstadoDe .And. "PE" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XPE ), 2 )
            DA1->DA1_XPI := Round( IIf( ( "PI" >= cEstadoDe .And. "PI" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XPI ), 2 )
            DA1->DA1_XPR := Round( IIf( ( "PR" >= cEstadoDe .And. "PR" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsInter ) / 100 ) ) , DA1->DA1_XPR ), 2 )
            DA1->DA1_XRJ := Round( IIf( ( "RJ" >= cEstadoDe .And. "RJ" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsInter ) / 100 ) ) , DA1->DA1_XRJ ), 2 )
            DA1->DA1_XRN := Round( IIf( ( "RN" >= cEstadoDe .And. "RN" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XRN ), 2 )
            DA1->DA1_XRO := Round( IIf( ( "RO" >= cEstadoDe .And. "RO" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XRO ), 2 )
            DA1->DA1_XRR := Round( IIf( ( "RR" >= cEstadoDe .And. "RR" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XRR ), 2 )
            DA1->DA1_XRS := Round( IIf( ( "RS" >= cEstadoDe .And. "RS" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsInter ) / 100 ) ) , DA1->DA1_XRS ), 2 )
            DA1->DA1_XSC := Round( IIf( ( "SC" >= cEstadoDe .And. "SC" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsInter ) / 100 ) ) , DA1->DA1_XSC ), 2 )
            DA1->DA1_XSE := Round( IIf( ( "SE" >= cEstadoDe .And. "SE" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XSE ), 2 )
            DA1->DA1_XSP := nPrcBase
            DA1->DA1_XTO := Round( IIf( ( "TO" >= cEstadoDe .And. "TO" <= cEstadoAte ) ,( nPrcIcms / ( 1 - IIf( cOrigem == "1", nIcmsImpor, nIcmsNorte ) / 100 ) ) , DA1->DA1_XTO ), 2 )

            BeginSql Alias cAliasSF7
                SELECT F7_MARGEM, F7_ALIQEXT, F7_ALIQINT, F7_EST, F7_GRTRIB, F7_ALIQPIS, F7_ALIQCOF
                FROM %Table:SF7% SF7
                WHERE SF7.F7_FILIAL = %xFilial:SF7%
                AND SF7.F7_GRTRIB = %Exp:cGrpTrib%
                AND SF7.F7_GRPCLI = 'FID' //-- Definido por Wandre
                AND SF7.F7_ORIGEM = %Exp:cOrigem%
                AND SF7.F7_EST BETWEEN %Exp:cEstDe% AND %Exp:cEstAte%
                AND SF7.%NotDel%
            EndSql

            If (cAliasSF7)->( !Eof() )

                While (cAliasSF7)->( !Eof() )


                    //Quando não tiver margem agregada na Exceção Fiscal não calcular Aliq interna e extena - SOMENTE RORAIMA
                    If AllTrim( (cAliasSF7)->F7_EST ) $ "RO" .And. (cAliasSF7)->F7_MARGEM == 0
                        nAliqInt      := 0
                        nAliqExt      := 0
                    Else
                        nAliqInt      := (cAliasSF7)->F7_ALIQINT
                        nAliqExt      := (cAliasSF7)->F7_ALIQEXT
                    EndIf

                    If AllTrim( (cAliasSF7)->F7_EST ) $ cEstZF
                        nIpi     := 0
                        nAliqPis := If(Alltrim((cAliasSF7)->F7_GRTRIB) == "100" , nTxPis , (cAliasSF7)->F7_ALIQPIS)
                        nAliqCof := If(Alltrim((cAliasSF7)->F7_GRTRIB) == "100" , nTxCof , (cAliasSF7)->F7_ALIQCOF)
                    Else
                        nIpi     := nOriIPI
                        nAliqPis := 0
                        nAliqCof := 0
                    EndIf


                    nPrcEst := &("DA1->DA1_X" + AllTrim( (cAliasSF7)->F7_EST ))

                    //--Se houver protocolo cadastrado para o estado a regra é somente Preço * IPI
                    If (cAliasSF7)->F7_EST $ cEstProtoc
                        //Nova regra definida pelo Wandre - 27/04/2022
                        //&("DA1->DA1_X" + AllTrim( (cAliasSF7)->F7_EST ) + "IMP" ) := Round( nPrcBase * ( 1 + nIPI / 100 ), 2 ) 
                        &("DA1->DA1_X" + AllTrim( (cAliasSF7)->F7_EST ) + "IMP" ) := Round( nPrcEst * ( 1 + nIPI / 100 ), 2 )
                    Else
                        If (cAliasSF7)->F7_MARGEM > 0 .Or. (AllTrim( (cAliasSF7)->F7_EST ) $ "RO" .And. (cAliasSF7)->F7_MARGEM == 0)

                            /*Nova regra definida pelo Wandre - 27/04/2022
                            &("DA1->DA1_X" + AllTrim( (cAliasSF7)->F7_EST ) + "IMP" )      := Round( ( ( nPrcBase * (1 + nIPI / 100 ) * ( 1 + (cAliasSF7)->F7_MARGEM / 100 ) );
                                                                                * ( (cAliasSF7)->F7_ALIQINT / 100 ) );
                                                                                - ( nPrcBase * (cAliasSF7)->F7_ALIQEXT / 100 ) + ( nPrcBase * ( 1 + nIPI / 100 ) ), 2 )*/
                            &("DA1->DA1_X" + AllTrim( (cAliasSF7)->F7_EST ) + "IMP" )      := Round( ( ( nPrcEst * (1 + nIPI / 100 ) * ( 1 + (cAliasSF7)->F7_MARGEM / 100 ) );
                                                                                * ( nAliqInt / 100 ) );
                                                                                - ( nPrcEst * nAliqExt / 100 ) + ( nPrcEst * ( 1 + nIPI / 100 ) );
                                                                                + ( nPrcEst * ((nAliqPis+nAliqCof) /100)) , 2 )
                        Else
                            //--Se não houver MVA(F7_MARGEM) a regra é somente Preço * IPI
                            //Nova regra definida pelo Wandre - 27/04/2022
                            //&("DA1->DA1_X" + AllTrim( (cAliasSF7)->F7_EST ) + "IMP")      := Round( nPrcBase * ( 1 + nIPI / 100 ), 2 )
                            &("DA1->DA1_X" + AllTrim( (cAliasSF7)->F7_EST ) + "IMP")      := Round( nPrcEst * ( 1 + nIPI / 100 ), 2 )
                        EndIf
                    EndIf
                    
                    //--Seta os estados que foram encontrados na tabela SF7
                    nPos := aScan( aEstados, { |x| AllTrim( x[1] ) == AllTrim( (cAliasSF7)->F7_EST ) } )
                    aEstados[nPos][2] := .T.

                    (cAliasSF7)->( DbSkip() )

                EndDo
                
                For nI := 1 To Len(aEstados)
                    //--Grava o preço base para os estados que não foram encontrados na tabela SF7
                    If !(aEstados[nI][2])
                        nPrcEst := &("DA1->DA1_X" + AllTrim( aEstados[nI][1] ))
                        &("DA1->DA1_X" + AllTrim( aEstados[nI][1] ) + "IMP" ) := Round( IIf( ( aEstados[nI][1] >= cEstadoDe .And. aEstados[nI][1] <= cEstadoAte ) ,;
                                                                                    Round( nPrcEst * ( 1 + nIPI / 100 ), 2 ) ,;
                                                                                    &("DA1->DA1_X" + AllTrim( aEstados[nI][1] ) + "IMP" ) ), 2 )
                    EndIf 
                Next

            Else
                
                //--Grava o preço base para os estados que não foram encontrados na tabela SF7
                For nI := 1 To Len(aEstados)
                    nPrcEst := &("DA1->DA1_X" + AllTrim( aEstados[nI][1] ))
                    &("DA1->DA1_X" + AllTrim( aEstados[nI][1] ) + "IMP" ) := Round( IIf( ( aEstados[nI][1] >= cEstadoDe .And. aEstados[nI][1] <= cEstadoAte ) ,;
                                                                                Round( nPrcEst * ( 1 + nIPI / 100 ), 2 ) ,;
                                                                                &("DA1->DA1_X" + AllTrim( aEstados[nI][1] ) + "IMP" ) ), 2 )
                Next

                //--Informa produtos que não foram localizados na tabela SF7 para que se possa avaliar se devem ser cadastrados
                aadd(aErr  , "(Produto: " + AllTrim( cCodProd) + " | Grupo Trib.: " + AllTrim(cGrpTrib) + " | Origem: " + AllTrim(cOrigem) + " | Excessao Fiscal nao cadastrada para a condicao acima.)" )
            EndIf

            (cAliasSF7)->( DbCloseArea() )

        DA1->( MsUnlock() )

    End Transaction

Return
