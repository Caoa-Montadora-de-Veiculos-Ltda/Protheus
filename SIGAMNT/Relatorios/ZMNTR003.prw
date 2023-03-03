#include 'protheus.CH'
#include "TOTVS.CH"
#include 'TOPCONN.CH'
#include "REPORT.CH"


/*===================================================================================
Programa.:              ZMNTR003
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Relatorio de minimo Max montagem, 19 - Manutenção de Ativo\MNT103 - Relatório Follow Up ANALITICO
Solicitante:            Julia Alcantara
===================================================================================== */
User Function ZMNTR003(aParams) // u_ZMNTR003()   //u_ZGENEXCEL
    Local aPergs    := {}
    Local cForI     := Space(TamSx3("A2_COD")[1])   
    Local cForF     := Space(TamSx3("A2_COD")[1]) := "ZZZZZZ"
    Local cC1I      := Space(TamSx3("C1_NUM")[1]) //:= "000011"
    Local cC1F      := Space(TamSx3("C1_NUM")[1]) //:= "000011" 
    Local cC7I      := Space(TamSx3("C7_NUM")[1])
    Local cC7F      := Space(TamSx3("C7_NUM")[1]) := "999999"
    Local cTpI      := Space(TamSx3("B1_TIPO")[1]) 
    Local cTpF      := Space(TamSx3("B1_TIPO")[1]) := "ZZ"
    Local cCod      := Space(TamSx3("B1_COD")[1])
    Local cDesc     := Space(TamSx3("B1_DESC")[1])
    Private oRep    := Nil
    Private oTb     := Nil
    Private cTb     := Nil
    Private aRt     := {}

    If Empty(aParams) = .T.


        Aadd(aPergs, {1, AllTrim(GetSx3Cache("C7_FORNECE", "X3_TITULO")) + " De : " , cForI , "@!"  , ""    , "SA2" , ""    , 30    , .F.   })
        Aadd(aPergs, {1, AllTrim(GetSx3Cache("C7_FORNECE", "X3_TITULO")) + " Até: " , cForF , "@!"  , ""    , "SA2" , ""    , 30    , .T.   })
        Aadd(aPergs, {1, AllTrim(GetSx3Cache("C1_NUM", "X3_TITULO"))     + " De : " , cC1I  , "@!"  , ""    , "SC1" , ""    , 50    , .F.   })
        Aadd(aPergs, {1, AllTrim(GetSx3Cache("C1_NUM", "X3_TITULO"))     + " Até: " , cC1F  , "@!"  , ""    , "SC1" , ""    , 50    , .T.   })
        Aadd(aPergs, {1, AllTrim(GetSx3Cache("C7_NUM", "X3_TITULO"))     + " De : " , cC7I  , "@!"  , ""    , "SC7" , ""    , 50    , .F.   })
        Aadd(aPergs, {1, AllTrim(GetSx3Cache("C7_NUM", "X3_TITULO"))     + " Até: " , cC7F  , "@!"  , ""    , "SC7" , ""    , 50    , .T.   })
        Aadd(aPergs, {1, AllTrim(GetSx3Cache("B1_TIPO", "X3_TITULO"))    + " Ate:"  , cTpI  , "@!"  , ""    , "02"  , ""    , 50    , .F.   })
        Aadd(aPergs, {1, AllTrim(GetSx3Cache("B1_TIPO", "X3_TITULO"))    + " Ate:"  , cTpF  , "@!"  , ""    , "02"  , ""    , 50    , .T.   })
        Aadd(aPergs, {1, "Codigo Prod contém:   "                                   , cCod  , "@!"  , ""    , "SB1" , ""    , 070   , .F.	})
        Aadd(aPergs, {1, "Descrição prod contém:"                                   , cDesc , "@!"  , ""    , ""    , ""    , 100   , .F.	})
        Aadd(aPergs, {5, "Apenas produtos com sol. de compra em aberto ?"           , .F.   , 150   , ""    , .F.}) //8
        Aadd(aPergs, {3, "Destino"                                                  , 1     , {"Exporta Excel", "Impressão"}, 90    , "" , .F.})

        If ParamBox(aPergs, "Relatório análitico de compras (Follow up) manutenção", aRt) = .T.
            zRelfup()
        Endif
    Else

        XSetParm(aParams)
        zRelfup()

    EndIf

Return

Static Function XSetParm(aParm)
    Local i := 1
    Local cAux := ""

    For i:=1 to Len(aParm)
        cAux := "MV_PAR" + PadL(i, 2,"0") + " := " + aParm[i,2]

        &(cAux)
    Next
Return aParm



/*===================================================================================
Programa.:              zRelfup
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Efetua a montagem do relatório
===================================================================================== */
Static Function zRelfup()
    Local nQtIt := 0
    Local cAux  := ""

    // Obter os itens da consulta
    FWMsgRun(, {|oSay| zGetItens(oSay) },"", "Obtendo os itens e saldos..." )
    
    // testar se tem itens
    (cTb)->(DbGoTop())
    (cTb)->(DbEval({|| nQtIt+= 1 }, {|| .T.}))
    If nQtIt = 0
        ApMsgInfo("Nenhum produto com esses parametros", "ZMNTR002")
        Return
    Endif

    // obtebdo os aprovadores
    FWMsgRun(, {|| zLstAprov() },"", "Obtendo os aprovadores..." )
    
    FWMsgRun(, {|| zLstLocal() },"", "Obtendo localizacoes..." )

    //remove os espacos dos codigos    
    FWMsgRun(, {|| zAjCodProd() },"", "Formatando códigos..." )
  
    //If aRt[12] = 1
    If MV_PAR12 = 1
        zExpXlsx()
    ElseIf MV_PAR12 = 2
        oRep := RptDef()
        oRep:PrintDialog()
    Else
        cAux := u_zGENjSON(cTb)
    Endif

    oTb:Delete()

Return cAux

/* // Obtem os aprovadores
Static function zAjAprov()
    Local cAprC1 := ""
    Local dAprC1 := ""
    Local cAprC7 := ""
    Local dAprC7 := ""

   (cTb)->(DbGoTop())

    DbSelectArea("SCR")
    SCR->(DbSetOrder(1)) // CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL  

    While (cTb)->(Eof()) = .F.

        // Pegue o aprovador de maior nivel do pedido
        If SCR->(DbSeek( Xfilial("SCR") + "PC" + (cTb)->C7_NUM  )) = .T.
            While Xfilial("SCR") + "PC" + (cTb)->C7_NUM ==  SCR->( CR_FILIAL + CR_TIPO + CR_NUM )
                SCR->(DbSkip())
            EndDo

                


        EndIf




        RecLock(cTb,  .F.)
    EndDo

Return */

/*===================================================================================
Programa.:              zAjCodProd
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   remove os espacos em branco dos codigos do relatorio
===================================================================================== */
Static function zAjCodProd()

   (cTb)->(DbGoTop())

    While (cTb)->(Eof()) = .F.

        RecLock(cTb,  .F.)
        (cTb)->B1_COD := Alltrim((cTb)->B1_COD)

        (cTb)->(DbSkip())
    EndDo
   (cTb)->(DbGoTop())
Return

/*
    function para pegar a BF_LOCALIZ, que pode ter mais de uma ocoreencia
*/
Static Function zLstLocal()
    Local cLoc

   (cTb)->(DbGoTop())

    DbSelectArea("SBF")
    SBF->(DbSetOrder(2))  //  BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI  
    
    While (cTb)->(Eof()) = .F.
        cLoc := ""
        If SBF->(DbSeek(Xfilial("SBF") + (cTb)->B1_COD)) = .T.
            While SBF->(BF_FILIAL + BF_PRODUTO) = Xfilial("SBF") + (cTb)->B1_COD
                cLoc += AllTrim(SBF->BF_LOCALIZ) + " , "
                SBF->(DbSkip())
            EndDo

            cLoc := Substr(cLoc, 1, Len(cLoc)- 3)

            RecLock(cTb,  .F.)
            (cTb)->BF_LOCALIZ := cLoc
        EndIf
        (cTb)->(DbSkip())
    EndDo
   (cTb)->(DbGoTop())
Return




/*===================================================================================
Programa.:              zCriaTb
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Retorna os campos da tabela
===================================================================================== */
Static Function zGetCps()
    Local aFields := {}
    
    Aadd(aFields,{"C1_NUM",  TamSx3("C1_NUM")[3],   TamSx3("C1_NUM")[1], TamSx3("C1_NUM")[2], "Num Sol" , 20 })
    Aadd(aFields,{"C1_ITEM",  TamSx3("C1_ITEM")[3],   TamSx3("C1_ITEM")[1], TamSx3("C1_ITEM")[2], "Item Sol" , 20 })
    Aadd(aFields,{"C7_NUM",  TamSx3("C7_NUM")[3],   TamSx3("C7_NUM")[1], TamSx3("C7_NUM")[2], "Num Ped" , 20 })
    Aadd(aFields,{"C7_ITEM",  TamSx3("C7_ITEM")[3],   TamSx3("C7_ITEM")[1], TamSx3("C7_ITEM")[2], "Item Ped" , 20 })
    Aadd(aFields,{"PED_EMISS", "C",   20, 0, "Emissor Ped" , 20 })    
    Aadd(aFields,{"B1_COD",  TamSx3("B1_COD")[3],   TamSx3("B1_COD")[1], TamSx3("B1_COD")[2], "Codigo"  , 40 })
    Aadd(aFields,{"B1_DESC",  TamSx3("B1_DESC")[3],   TamSx3("B1_DESC")[1], TamSx3("B1_DESC")[2], "Descrição"  ,60})
    Aadd(aFields,{"C1_EMISSAO",  TamSx3("C1_EMISSAO")[3],   TamSx3("C1_EMISSAO")[1], TamSx3("C1_EMISSAO")[2], "Dt emiss Sol"  ,30})
    Aadd(aFields,{"C7_EMISSAO",  TamSx3("C7_EMISSAO")[3],   TamSx3("C7_EMISSAO")[1], TamSx3("C7_EMISSAO")[2], "Dt emiss Ped" ,30})
    Aadd(aFields,{"C7_DATPRF",   TamSx3("C7_DATPRF")[3],   TamSx3("C7_DATPRF")[1], TamSx3("C7_DATPRF")[2], "Dt Entr Ped"  ,30})
    Aadd(aFields,{"A2_NOME",  TamSx3("A2_NOME")[3],   TamSx3("A2_NOME")[1], TamSx3("A2_NOME")[2], "Nome forn" ,40})
    Aadd(aFields,{"STATUS_C1",  "C", 50, 0, "Status Sol" , 75})
    Aadd(aFields,{"DT_AP_C1",  "D", 8, 0, "Data Aprv Sol" ,40})
    Aadd(aFields,{"DT_AP_C7",  "D", 8, 0, "Data Aprv Ped" ,40})
    Aadd(aFields,{"C1_USR",  "C", 20, 0, "Aprov Sol" ,40})
    Aadd(aFields,{"C7_USR",  "C", 20, 0, "Aprov Ped",40})
    Aadd(aFields,{"C7_PRECO",  TamSx3("C7_PRECO")[3],   TamSx3("C7_PRECO")[1], TamSx3("C7_PRECO")[2], "Vl unit", 15})
    Aadd(aFields,{"C7_IPI",  TamSx3("C7_IPI")[3],   TamSx3("C7_IPI")[1], TamSx3("C7_IPI")[2], "Aliq IPI", 15})
    Aadd(aFields,{"C7_VALIPI",  TamSx3("C7_VALIPI")[3],   TamSx3("C7_VALIPI")[1], TamSx3("C7_VALIPI")[2], "Vl IPI", 15})
    Aadd(aFields,{"C7_PICM",  TamSx3("C7_PICM")[3],   TamSx3("C7_PICM")[1], TamSx3("C7_PICM")[2], "ALiqu ICM", 15})
    Aadd(aFields,{"C7_VALICM",  TamSx3("C7_VALICM")[3],   TamSx3("C7_VALICM")[1], TamSx3("C7_VALICM")[2], "Vl ICM", 15})
    Aadd(aFields,{"C7_ALIQISS",  TamSx3("C7_ALIQISS")[3],   TamSx3("C7_ALIQISS")[1], TamSx3("C7_ALIQISS")[2], "Aliq ISS" ,30})
    Aadd(aFields,{"C7_VALISS",  TamSx3("C7_VALISS")[3],   TamSx3("C7_VALISS")[1], TamSx3("C7_VALISS")[2], "Vl ISS" ,30})
    Aadd(aFields,{"C1_QUANT",  TamSx3("C1_QUANT")[3],   TamSx3("C1_QUANT")[1], TamSx3("C1_QUANT")[2], "Qt sol" ,30})
    Aadd(aFields,{"C7_QUANT",  TamSx3("C7_QUANT")[3],   TamSx3("C7_QUANT")[1], TamSx3("C7_QUANT")[2], "Qt Ped" ,30})
    Aadd(aFields,{"C7_QUJE",  TamSx3("C7_QUJE")[3],   TamSx3("C7_QUJE")[1], TamSx3("C7_QUJE")[2], "Qt Entr" ,25})
    Aadd(aFields,{"STATUS_C7",  "C",    006, 0, "Status Ped" , 25})    
    Aadd(aFields,{"D1_DOC",  "C",    13, 0, "Doc fiscal" , 25})    
    Aadd(aFields,{"D1_SERIE",  "C",    3, 0, "Sr doc fiscal" , 6})    
    Aadd(aFields,{"BF_LOCALIZ",  "C",   100, 0, "Localização", 100})
    Aadd(aFields,{"C1_XOBSITE",  "C",   250, 0, "Observação Item" , 250})
	Aadd(aFields,{"C1_XOBSREQ",  "C",   250, 0, "Observação Geral" , 250})
    Aadd(aFields,{"C1_XMOTR",  "C",   250, 0, "Motivo Recusa" , 250})
Return aFields


/*===================================================================================
Programa.:              zGetQtB1
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Obtem a listagem dos produtos
===================================================================================== */
Static Function zGetItens(oSay)
    Local aStruct   := {}   
    Local cQr       := GetNextAlias()
    Local cmd       := ""


    cmd += CRLF + " SELECT "    
    cmd += CRLF + "   C1_NUM "
    cmd += CRLF + " , C1_ITEM "
    cmd += CRLF + " , C7_NUM "
    cmd += CRLF + " , C7_ITEM "
    cmd += CRLF + " , CASE WHEN PED_USR.USR_ID IS NOT NULL THEN PED_USR.USR_ID || '-' || PED_USR.USR_CODIGO ELSE '' END AS PED_EMISS "
    cmd += CRLF + " , B1_COD "
    cmd += CRLF + " , B1_DESC "
    cmd += CRLF + " , C1_EMISSAO "
    cmd += CRLF + " , C7_EMISSAO "
    cmd += CRLF + " , C7_DATPRF "
    cmd += CRLF + " , A2_CGC "
    cmd += CRLF + " , A2_NOME "

    cmd += CRLF + " , CASE WHEN C1_RESIDUO = 'S' AND C1_COMPRAC = '1' THEN 'SC em Compra Centralizada' "
    cmd += CRLF + "        WHEN C1_FLAGGCT = '1' AND C1_QUJE < C1_QUANT THEN 'Sc Totalmente Atendida pelo SIGAGCT'"
    cmd += CRLF + "        WHEN C1_TIPO = '2' THEN 'Solicitação de Importação' "
    cmd += CRLF + "        WHEN C1_RESIDUO = 'S' THEN 'SC Eliminada por Resíduo' "
    cmd += CRLF + "        WHEN C1_QUJE >= C1_QUANT AND  C1_RESIDUO = ' ' THEN 'Solicitação Totalmente Atendida' "
    cmd += CRLF + "        WHEN C1_TPSC = '2' AND C1_QUJE = 0 AND C1_CODED = ' ' THEN 'Solicitação em Processo de Edital' "
    cmd += CRLF + "        WHEN C1_TPSC <> '2' AND C1_QUJE > 0 AND C1_COTACAO <> ' ' AND C1_IMPORT <> 'S' THEN 'Solicitação Parcialmente Atendida' "
    cmd += CRLF + "        WHEN C1_QUJE = 0 AND C1_APROV = 'L' AND (( C1_COTACAO = ' ' AND C1_TPSC = '2') OR (C1_COTACAO = 'ANALIS')) THEN 'Solicitação para Licitação' "
    cmd += CRLF + "        WHEN C1_QUJE = 0 AND C1_COTACAO = ' ' AND (C1_APROV = 'L' OR C1_APROV = ' ') THEN 'Solicitação Pendente' "
    cmd += CRLF + "        WHEN C1_QUJE = 0 AND C1_COTACAO = ' ' AND C1_APROV = 'R' THEN 'SC Rejeitada'  "
    cmd += CRLF + "        WHEN C1_QUJE = 0 AND( C1_COTACAO = ' ' OR C1_COTACAO = 'IMPORT') AND C1_APROV = 'B' THEN 'SC Bloqueada'  "
    cmd += CRLF + "        WHEN C1_QUJE > 0 AND C1_QUJE < C1_QUANT THEN 'SC com Pedido Colocado Parcial' "
    cmd += CRLF + "        WHEN C1_TPSC <> '2' AND C1_QUJE = 0 AND C1_COTACAO <> ' ' AND C1_IMPORT <> 'S' THEN 'SC em Processo de Cotação' "
    cmd += CRLF + "        WHEN C1_QUJE = 0 AND C1_COTACAO <> ' ' AND C1_IMPORT = 'S' THEN 'SC com Produto Importado' "
    cmd += CRLF + "        ELSE 'Status Não Encontrado'  "
    cmd += CRLF + "END as STATUS_C1 "

//    cmd += CRLF + " , '                    ' AS STATUS_C1 "
    cmd += CRLF + " , ' ' /* SCR_SOL_APR.CR_DATALIB */ AS DT_AP_C1 "
    cmd += CRLF + " , ' ' /* CASE WHEN USR_SOL_APR.USR_ID IS NOT NULL THEN USR_SOL_APR.USR_ID || '-' || USR_SOL_APR.USR_CODIGO ELSE '' END */ AS C1_USR "
    
    cmd += CRLF + " , ' ' /* SCR_PED_APR.CR_DATALIB */ AS DT_AP_C7 "
    cmd += CRLF + " , ' ' /* CASE WHEN USR_PED_APR.USR_ID IS NOT NULL THEN USR_PED_APR.USR_ID || '-' || USR_PED_APR.USR_CODIGO ELSE '' END */ AS C7_USR "
    
    cmd += CRLF + " , C7_PRECO "
    cmd += CRLF + " , C7_IPI "
    cmd += CRLF + " , C7_VALIPI "
    cmd += CRLF + " , C7_PICM "
    cmd += CRLF + " , C7_VALICM "
    cmd += CRLF + " , C7_ALIQISS "
    cmd += CRLF + " , C7_VALISS "
    cmd += CRLF + " , C1_QUANT "
    cmd += CRLF + " , C7_QUANT "
    cmd += CRLF + " , C7_QUJE "
    cmd += CRLF + " , CASE WHEN (C7_QUJE = 0) THEN 'PEND' WHEN (C7_QUJE > 0 AND C7_QUJE < C7_QUANT) THEN 'REC PARC' WHEN (C7_QUJE = C7_QUANT) THEN 'RECEB' END AS STATUS_C7 "
    cmd += CRLF + " , ' ' as BF_LOCALIZ "

    cmd += CRLF + " , SD1.D1_SERIE"
    cmd += CRLF + " , SD1.D1_DOC"

    cmd += CRLF + " , UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C1_XOBSITE, 250, 1)) AS C1_XOBSITE "
	cmd += CRLF + " , UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C1_XOBSREQ, 250, 1)) AS C1_XOBSREQ "
    cmd += CRLF + " , C1_XMOTR "
   
    cmd += CRLF + " FROM " + RetSqlName("SC1") + " C1 "

    cmd += CRLF + " INNER JOIN " + RetSqlName("SB1") + " B1 ON B1.D_E_L_E_T_ = ' ' AND B1_COD = C1_PRODUTO "
    cmd += CRLF + "           AND B1_TIPO >= '" + MV_PAR07 + "' AND B1_TIPO <= '" + MV_PAR08 + "' " 
    
    If Empty(MV_PAR09) = .F.
        cmd += CRLF + "           AND B1_COD LIKE '" + AllTrim(MV_PAR09) + "%'  "
    Endif

    If Empty(MV_PAR10) = .F.
        cmd += CRLF + "           AND B1_DESC LIKE '" + AllTrim(MV_PAR10) + "%' "
    Endif

    cmd += CRLF + " LEFT JOIN " + RetSqlName("SC7") + " C7 ON C7.D_E_L_E_T_ = ' ' AND C7_FILIAL = C1_FILIAL AND C7_NUM = C1_PEDIDO "
    cmd += CRLF + "            AND C7_ITEM = C1_ITEMPED AND C7_NUM >= '" + MV_PAR05 + "' AND C7_NUM <= '" + MV_PAR06 + "' "
                               
    cmd += CRLF + " LEFT JOIN " + RetSqlName("SA2") + " A2 ON A2.D_E_L_E_T_ = ' ' AND A2_COD = C1_FORNECE AND A2_LOJA = C1_LOJA "
    
    // JOIN PARA MOSTRAR USUARIO DO PEDIDO
    cmd += CRLF + " LEFT JOIN SYS_USR PED_USR ON PED_USR.usr_id = C7.C7_USER "

    cmd += CRLF + " LEFT JOIN SD1010 SD1 on SD1.D_E_L_E_T_  = ' ' AND D1_FILIAL = C7_FILIAL AND D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM "
  
    cmd += CRLF + " WHERE "
    cmd += CRLF + "     C1.D_E_L_E_T_ = ' ' "
    cmd += CRLF + "     AND C1_FILIAL = '" + cFilAnt + "' " 
    cmd += CRLF + "     AND C1_FORNECE >= '" + MV_PAR01 + "' AND C1_FORNECE <= '" + MV_PAR02 + "' "  
    cmd += CRLF + "     AND C1_NUM >= '" + MV_PAR03 + "' AND C1_NUM <= '" + MV_PAR04 + "' "  

    IF MV_PAR11 = .T.
        cmd += CRLF + "     AND C1_QUJE <> C1_QUANT "
    Endif

    TcQuery cmd new Alias (cQr)

    aStruct :=  zGetCps()

    oSay:SetText("Obtendo itens") // ALTERA O TEXTO CORRETO
    ProcessMessage() // FORÇA O DESCONGELAMENTO DO SMARTCLIENT

    // cria a tabela
    oTb := FWTemporaryTable():New( GetNextAlias() )
    oTb:SetFields( aStruct )
    oTb:AddIndex("indice1", {"B1_COD"} )
    oTb:AddIndex("indice2", {"B1_DESC"} )
    oTb:Create()
    cTb := oTb:oStruct:cAlias

    While (cQr)->(Eof()) = .F.
        RecLock( (cTb), .T. )

        Aeval( aStruct, {|aCp| iif( aCp[2] == "D", (cTb)->&(aCp[1]) := Stod((cQr)->&(aCp[1])),  (cTb)->&(aCp[1]) := (cQr)->&(aCp[1])) })

        (cTb)->(MsUnlock())

        (cQr)->(DbSkip())
    EndDo

    (cQr)->(DbCloseArea())
Return


/*===================================================================================
Programa.:              zLstAprov
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Obtem os aprovadores
=====================================================================================  */
Static Function zLstAprov()
    Local cC1   := ""
    Local cDtc1 := ""
    Local cC7   := ""
    Local cDtc7 := ""

    DbSelectArea("SCR")
    DbSetorder(1)
    
    (cTb)->(DbGoTop())
    while (cTb)->(Eof()) = .F.
        cC1 := ""
        cC7 := ""
        If SCR->(DbSeek(Xfilial("SCR") + "SC" + Padr((cTb)->C1_NUM, TamSx3("CR_NUM")[1], " "))) = .T.
            While SCR->(CR_FILIAL + CR_TIPO + CR_NUM) == Xfilial("SCR") + "SC" + Padr((cTb)->C1_NUM, TamSx3("CR_NUM")[1], " ")
                cC1     := SCR->CR_APROV
                cDtc1   := SCR->CR_DATALIB
                SCR->(DbSkip())
            EndDo
        Endif
        
        If SCR->(DbSeek(Xfilial("SCR") + "PC" + (cTb)->C7_NUM)) = .T.
            While SCR->(CR_FILIAL + CR_TIPO + CR_NUM) == Xfilial("SCR") + "PC" + Padr((cTb)->C7_NUM, TamSx3("CR_NUM")[1], " ")
                cC7     := SCR->CR_APROV
                cDtc7   := SCR->CR_DATALIB
                SCR->(DbSkip())
            EndDo
        Endif

        RecLock((cTb), .F.)
        
        If Empty(cC1) = .F.
            (cTb)->DT_AP_C1 := cDtc1
            (cTb)->C1_USR := UsrRetName(cC1)
        Endif

        If Empty(cC7) = .F.
            (cTb)->DT_AP_C7 := cDtc7
            (cTb)->C7_USR := UsrRetName(cC7)
        Endif

        (cTb)->(MsUnlock())
        
        (cTb)->(DbSkip())
    EndDo
Return


/*===================================================================================
Programa.:              RptDef
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Prepara o relatorio
===================================================================================== */
Static Function RptDef()
    Local cAlign    := ""
    Local i         := 1
    Local lUmaLinha := .F.
	Local oSection 	:= Nil
    Local cTitulo   := "Analitico de estoque/compras (Min/Máx)" 
    Local cDescricao:= "Analitico de estoque/compras (Min/Máx)"
    Local aStru     := zGetCps()

	oRep := TReport():New(cTitulo, cDescricao , "", {|oRep| ReportPrint() }, cDescricao)
	oRep:nFontbody := 8
    oRep:oPage:setPaperSize(10)
	oRep:SetLandscape()
	oRep:SetTotalInLine(.F.)
    oRep:SetDevice(2) // 2 impressora
    oRep:SetEnvironment( 2 ) // 2 client
    oRep:setPreview(.T.)
	oRep:HideParamPage() 
	oRep:SetTotalInLine(.F.)
//                           oParent,   cTitle, uTable,                  aOrder, lLoadCells,lLoadOrder, uTotalText, lTotalInLine, lHeaderPage, lHeaderBreak, lPageBreak, lLineBreak, nLeftMargin, lLineStyle, nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage
    oSection:= TRSection():New( oRep, "CABECA",  {cTb}, {"Codigo", "Descricao"},        .F.,       .T.,         "",          .F.,         .F.,          .T.,        .T.,           ,           0,        .F.,         0,      .T.)

    For i:=1 to Len(aStru)
        cAlign := Iif(aStru[i,2] == "N", "RIGHT", "LEFT")
        
        TRCell():New(oSection, aStru[i ,1], cTb, aStru[i ,5], GetSx3Cache(aStru[i,1], "X3_PICTURE"),  aStru[i, 6] , , , cAlign, lUmaLinha)
    Next
Return oRep    


/*===================================================================================
Programa.:              RptDef
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Monta o relatorio
===================================================================================== */
Static Function ReportPrint(aItens)
	Local i         := 0
    Local oSection  := oRep:Section(1)
    Local aStru     :=  zGetCps() //  (cTb)->(DbStruct())

    oSection:Init()

    oRep:SetMeter( (cTb)->( LastRec() ) )

    (cTb)->(DbSetorder(oSection:GetOrder()))
    (cTb)->(DbGoTop())

    While (cTb)->(Eof()) = .F.
        For i:=1 to Len(aStru)
            oSection:Cell(aStru[i,1]):SetValue((cTb)->&(aStru[i,1]))
        Next

        oSection:Printline()
        (cTb)->(DbSkip())
        oRep:IncMeter()
    EndDo

	oRep:SkipLine()
    oRep:ThinLine()
    oSection:Finish()

    oRep:EndPage()
    
Return .T.

/*===================================================================================
Programa.:              zExpXlsx
Autor....:              CAOA - Valter Carvalho
Data.....:              11/09/2020
Descricao / Objetivo:   Monta os array para exportação para Excel
===================================================================================== */
Static Function zExpXlsx()
    Local i       := 1
    Local aTitles := {}
    Local acols   := {}
    Local aIt     := {}
    Local aStru   := zGetCps()

    Aeval(aStru, {|aCp| Aadd(aTitles, aCp[5] )})

    (cTb)->(DbGoTop())

    While (cTb)->(Eof()) = .F.
        aIt := {}
        For i:=1 to Len(aStru)

            If aStru[i,2] == "D"
                Aadd(aIt,  Iif(Empty((cTb)->&(aStru[i,1])) = .T., "",  Dtoc((cTb)->&(aStru[i,1])) ) )
            Else
                Aadd(aIt, (cTb)->&(aStru[i,1])  )
            Endif
        Next

        Aadd(aCols, aIt)
        (cTb)->(DbSkip())
    Enddo

    u_ZGENEXCEL(aTitles, aCols, "Planilha", "Relatório analitico de estoque/compras (Min/Máx)")
Return

