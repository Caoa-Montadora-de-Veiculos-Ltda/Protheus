#INCLUDE 'PROTHEUS.CH'
#Include 'TopConn.ch'


/*
=====================================================================================
Programa.:              MNTF001
Autor....:              CAOA - Valter Carvalho
Data.....:              22/07/2020
Descricao / Objetivo:   Efetua o preenchimento dos campos adicionados, tela de programação O.S, na grid das O.S sem programação (lado esquerdo)  a partie de MNTA9904
Doc. Origem:
Solicitante:            Julia Alcantara
Uso......:              mnta990.prx
===================================================================================== */

User function ZMNTF001()
    Local nPos := 0

    Local cTB1 := ParamIXB[1]

    // parte da descrição da O.S
    If (Type("aDscOrd") = "U") .Or. (Type("aDscOrd") == "A" .And. Len(aDscOrd) = 0 )
        FWMsgRun(, {||  InfDscOrd()  }, "", "Obtendo descrição O.S." )
    EndIf

    nPos := Ascan( aDscOrd, {|aIt| aIt[1] == (cTB1)->ORDEM} )
    If nPos > 0
        (cTb1)->COMPDESC := aDscOrd[ nPos, 2]
    EndIf

    // parte da descrição dos manutenedores
    If (Type("aMntOrd") = "U") .Or. (Type("aMntOrd") == "A" .And. Len(aMntOrd) = 0)
        FWMsgRun(, {||  InfMantOrd()  }, "", "Obtendo mantenedor O.S." )
    EndIf

    nPos := Ascan( aMntOrd, {|aIt| aIt[1] == (cTB1)->ORDEM} )
    If nPos > 0
        (cTb1)->COMPMANU := aMntOrd[ nPos, 2]
    EndIf
Return


/*
=====================================================================================
Programa.:              GetInfOrd
Autor....:              CAOA - Valter Carvalho
Data.....:              14/02/2020
Descricao / Objetivo:   Obter os dados dos mantenedores, para ser usados nos pontos de entrada ZMNTF001 e ZMNTF003
Doc. Origem:
Solicitante:            Julia Alcantara
Uso......:              
===================================================================================== */
Static Function InfMantOrd()
    Local cAliasTbt := ""
    Local oTable    := nil
    Local cAliasQr  := GetNextAlias()
    Local aOrdens   := {}
    Local cCmd      := ""

    Public aMntOrd  := {{"",""}}

    // obter os mantenedores
    If INCLUI = .T.
        // pega as ordens que estão em memoria e prepara uma table temporaria para fazer join com as

        oTable := FWTemporaryTable():New()
        oTable:SetFields({ {"ORDEM", "C", 6, 0} })
        oTable:Create()
        cAliasTbT := oTable:GetAlias()

        (c990STJTMP)->(Dbeval({|| Iif(Ascan(aOrdens, (c990STJTMP)->TJ_ORDEM) = 0, Aadd(aOrdens, (c990STJTMP)->TJ_ORDEM), "")}, {||.T.}))
        Aeval(aOrdens, {|cIt| (cAliasTbT)->(DBAppend()), (cAliasTbT)->ORDEM := cIt, (cAliasTbt)->(DBCommit()) })

        cCmd += "   SELECT DISTINCT ORDEM AS ORDEM" + CRLF
        cCmd += " , CASE WHEN T0_NOME IS NOT NULL THEN SUBSTR(T0_NOME,1,25) ELSE SUBSTR(T1_NOME,1,25) END AS COMPMANU" + CRLF
        cCmd += " FROM " + oTable:GetRealName() + CRLF
        cCmd += " LEFT JOIN " + RetSqlName("STL") + " ON TL_FILIAL = " + Xfilial("STL") + " AND TL_ORDEM = ORDEM AND STL010.D_E_L_E_T_ = ' ' AND TL_TIPOREG IN ( 'M','E')" + CRLF
        cCmd += " LEFT JOIN " + RetSqlName("ST1") + " ON TL_TIPOREG = 'M' AND T1_FILIAL = TL_FILIAL AND T1_CODFUNC = TL_CODIGO AND ST1010.D_E_L_E_T_ = ' '" + CRLF
        cCmd += " LEFT JOIN " + RetSqlName("ST0") + " ON TL_TIPOREG = 'E' AND TL_FILIAL = T0_FILIAL AND TL_CODIGO = T0_ESPECIA " + CRLF
        cCmd += " ORDER BY ORDEM"

        // terminei de pegar as ordens, volto a qry da ordem para o inicio
        (c990STJTMP)->(DbgoTop())
    else

        cCmd += "   SELECT DISTINCT TT2_ORDEM AS ORDEM "
        cCmd += " , CASE WHEN T0_NOME IS NOT NULL THEN SUBSTR(T0_NOME,1,25) ELSE SUBSTR(T1_NOME,1,25) END AS COMPMANU "
        cCmd += " FROM " + RetSqlName("TT2")
        cCmd += " LEFT JOIN " + RetSqlName("STL") + " ON TL_FILIAL = TT2_FILIAL AND TT2_ORDEM = TL_ORDEM AND STL010.D_E_L_E_T_ = ' ' AND TL_TIPOREG IN ( 'M','E')  "
        cCmd += " LEFT JOIN " + RetSqlName("ST1") + " ON TL_TIPOREG = 'M' AND T1_FILIAL = TL_FILIAL AND T1_CODFUNC = TL_CODIGO AND ST1010.D_E_L_E_T_ = ' '  "
        cCmd += " LEFT JOIN " + RetSqlName("ST0") + " ON TL_TIPOREG = 'E' AND TL_FILIAL = T0_FILIAL AND TL_CODIGO = T0_ESPECIA "
        cCmd += " WHERE  "
        cCmd += "     TT2_CODIGO = '" + TT1->TT1_CODIGO + "'  "
        cCmd += " AND TT2010.D_E_L_E_T_ = ' '  "
        cCmd += " ORDER BY TT2_ORDEM "
    EndIf


    TcQuery cCmd new Alias (cAliasQr)

    While (cAliasQr)->(Eof()) = .F.

        if (cAliasQr)->ORDEM <> aMntOrd[ len(aMntOrd), 1 ]
            Aadd(aMntOrd, {(cAliasQr)->ORDEM, " -" + (cAliasQr)->COMPMANU })
        else
            aMntOrd[ len(aMntOrd), 2] := Alltrim (aMntOrd[ len(aMntOrd), 2 ]) + " -" + (cAliasQr)->COMPMANU
        EndIf

        (cAliasQr)->(DbSkip())
    EndDo

    (cAliasQr)->(DbCloseArea())

    If oTable <> nil
        oTable:Delete()
    EndIf

Return

/*
=====================================================================================
Programa.:              InfDscOrd
Autor....:              CAOA - Valter Carvalho
Data.....:              14/02/2020
Descricao / Objetivo:   Obter os dados das descrições das O.S., para ser usados nos pontos de entrada ZMNTF001 e ZMNTF003
Doc. Origem:
Solicitante:            Julia Alcantara
Uso......:              
===================================================================================== */
Static Function InfDscOrd()
    Local oTable      := Nil
    Local cAliasQr    := GetNextAlias()
    Local cCmd        := ""
    Local aOrdens     := {}
    Local cAliasTbT   := ""

    Public aDscOrd    := {{"",""}}

    If INCLUI = .T.
        oTable := FWTemporaryTable():New()
        oTable:SetFields({ {"ORDEM", "C", 6, 0} })
        oTable:Create()
        cAliasTbT := oTable:GetAlias()

        (c990STJTMP)->(Dbeval({|| Iif(Ascan(aOrdens, (c990STJTMP)->TJ_ORDEM) = 0, Aadd(aOrdens, (c990STJTMP)->TJ_ORDEM), "")}, {||.T.}))
        Aeval(aOrdens, {|cIt| (cAliasTbT)->(DBAppend()), (cAliasTbT)->ORDEM := cIt, (cAliasTbt)->(DBCommit()) })

        cCmd += " SELECT DISTINCT TJ_ORDEM AS ORDEM " + CRLF
        cCmd += " , CASE WHEN TJ_TIPO = '001' THEN TF_NOMEMAN ELSE utl_raw.cast_to_varchar2(dbms_lob.substr(TJ_OBSERVA,100,1)) END AS MANUTENC "  + CRLF
        cCmd += " , STJ010.TJ_CODBEM  " + CRLF
        cCmd += " FROM " + oTable:GetRealName() + CRLF
        cCmd += " LEFT JOIN " + RetSqlName("STJ") + " ON TJ_FILIAL = " + Xfilial("STJ") + " AND TJ_ORDEM = ORDEM AND STJ010.D_E_L_E_T_ = ' ' " + CRLF
        cCmd += " LEFT JOIN " + RetSqlName("STF") + " ON TF_FILIAL = TJ_FILIAL AND TF_CODBEM = TJ_CODBEM AND TF_SERVICO = TJ_SERVICO AND  TF_SEQRELA = TJ_SEQRELA AND STF010.D_E_L_E_T_ =  ' ' " + CRLF
        cCmd += " ORDER BY ORDEM  " + CRLF

        // terminei de pegar as ordens, volto a qry da ordem para o inicio
        (c990STJTMP)->(DbgoTop())
    else
        cCmd += " SELECT DISTINCT TT2_ORDEM AS ORDEM "
        cCmd += " , CASE WHEN TJ_TIPO = '001' THEN TF_NOMEMAN ELSE utl_raw.cast_to_varchar2(dbms_lob.substr(TJ_OBSERVA,100,1)) END AS MANUTENC "
        cCmd += " , STJ010.TJ_CODBEM  "
        cCmd += " FROM " + RetSqlName("TT2")
        cCmd += " LEFT JOIN " + RetSqlName("STJ") + " ON TJ_FILIAL = TT2_FILIAL AND TJ_ORDEM = TT2_ORDEM AND STJ010.D_E_L_E_T_ = ' ' "
        cCmd += " LEFT JOIN " + RetSqlName("STF") + " ON TF_FILIAL = TJ_FILIAL AND TF_CODBEM = TJ_CODBEM AND TF_SERVICO = TJ_SERVICO AND  TF_SEQRELA = TJ_SEQRELA   AND   STF010.D_E_L_E_T_ =  ' ' "
        cCmd += " WHERE  "
        cCmd += "     TT2_CODIGO = '" + TT1->TT1_CODIGO + "'  "
        cCmd += " AND TT2010.D_E_L_E_T_ = ' '  "
        cCmd += " ORDER BY TT2_ORDEM  "
    EndIf


    TcQuery cCmd new Alias (cAliasQr)

    While (cAliasQr)->(Eof()) = .F.

        if (cAliasQr)->ORDEM <> aDscOrd[ len(aDscOrd), 1 ]
            Aadd(aDscOrd, {(cAliasQr)->ORDEM, " -" + (cAliasQr)->MANUTENC })
        else
            aDscOrd[ len(aDscOrd), 2] := Alltrim (aDscOrd[ len(aDscOrd), 2 ]) + " -" + (cAliasQr)->MANUTENC
        EndIf

        (cAliasQr)->(DbSkip())
    EndDo

    (cAliasQr)->(DbCloseArea())

Return
