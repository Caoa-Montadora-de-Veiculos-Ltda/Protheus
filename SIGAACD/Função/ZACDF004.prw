#include "apvt100.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TOPCONN.CH'

#DEFINE CRLF  	CHAR(13) + CHAR(10)

Class TrfUnit

    Data cUnitz
    Data cDstLoc
    Data cDstEnd
    Data cOriLoc
    
    Data cOriEnd
    Data cAlias
    Data aErr

    Method New(cUnitz, cOriLoc, cOriEnd, cDstLoc, cDstEnd) Constructor	    // construtor da classe

    Method SetLocEndOri()
    Method GetLocEndDst()
    Method SetUnitz()
    Method Chk_Tudo()
    Method Chk_D0R()
    Method Chk_DCF()
    Method Chk_SZJ()
    Method Chk_D12()
    Method Chk_Ori()
    Method Chk_OriDst() 
    Method Chk_BlEndDst()
    Method Chk_DC3()
    Method Chk_CapDst(nQtUniz)
    Method GetErros()
    Method IsArmazInv(cArmazem)

EndClass

Method New(cUnitz, cOriLoc, cOriEnd, cDstLoc, cDstEnd) class TrfUnit
    ::cUnitz  := cUnitz
    ::cDstLoc := cDstLoc
    ::cDstEnd := cDstEnd
    ::cOriLoc := Iif(Empty(cOriLoc) = .F., cOriLoc, "" )
    ::cOriEnd := Iif(Empty(cOriEnd) = .F., cOriEnd, "" )
    ::cAlias  := GetNextAlias()
    ::aErr    := {}

    If Empty(::cOriEnd) .AND. Empty(::cOriLoc)
        ::SetLocEndOri()
    EndIf

Return Self


Method GetErros()  class TrfUnit
Return ::aErr


Method Chk_Ori(lRetSeErr) class TrfUnit
    Local lOk := .T.
    ::aErr := {}

    If lRetSeErr = .F.
        ::Chk_D0R()
        ::Chk_DCF()
        ::Chk_D12()
        ::Chk_SZJ()
    Else
        lOk :=                  ::Chk_D0R()
        Iif( lOk = .T., lOk := ::Chk_DCF(), "")
        Iif( lOk = .T., lOk := ::Chk_D12(), "")
        Iif( lOk = .T., lOk := ::Chk_SZJ(), "")
    EndIf

Return lOk


Method SetUnitz(cUnitz) class TrfUnit
    ::cUnitz := cUnitz
Return


Method GetLocEndDst() class TrfUnit

    If IsInCallStack("SIGAACD") = .T.
        VtClear()
        @ 0,00 VTSAY "- Transf CAOA (2) -"

        @ 1,00 VTSAY "Armz.Destino:"	VTGet ::cDstLoc Pict PesqPict("NNR", "NNR_CODIGO") Valid ValidaInf("NNR", 1, Xfilial("NNR") + ::cDstLoc, "NNR_CODIGO")

        @ 2,00 VTSAY "Endereco Destino:"
        @ 3,00 VTSAY "" 				VTGet ::cDstEnd Pict PesqPict("SBE", "BE_LOCALIZ") Valid ValidaInf("SBE", 1, Xfilial("SBE") + ::cDstLoc + ::cDstEnd, "BE_LOCALIZ")
        VTRead()
        If VtLastKey() = KEY_ESC
            Return .F.
        EndIf
    EndIf
Return .T.

Method SetLocEndOri() class TrfUnit
    Local cmd	:= ""

    cmd += CRLF + " SELECT * FROM "
    cmd += CRLF + RetSQLName("D14") + " D14 "
    cmd += CRLF + " WHERE "
    cmd += CRLF + " 	D_E_L_E_T_ <> '*' "
    cmd += CRLF + "	AND D14_FILIAL = '" + cFilAnt + "' "
    cmd += CRLF + " AND D14_IDUNIT = '" + cOriUnitz  + "' "

    TcQuery cmd new Alias (::cAlias)

    ::cOriEnd := (::cAlias)->D14_ENDER
    ::cOriLoc := (::cAlias)->D14_LOCAL

    (::cAlias)->(DbCloseArea())

    If Empty(::cOriEnd) .OR. Empty(::cOriLoc)
        Aadd(::aErr, "Unitizador não existe na tabela de saldo por endereço no WMS")
        Return .F.
    EndIf

Return .T.

Method Chk_D0R() class TrfUnit
    Local  xValor := Posicione("D0R", 1, cFilAnt +  ::cOriLoc + ::cOriEnd + ::cUnitz, "D0R_STATUS")

    If (xValor <> "4") .AND. Empty(xValor) = .F.
        If xValor == "2"
            Aadd(::aErr, "Unitizador " + Alltrim(::cUnitz) + " aguardando geracao de O.S. ")
        ElseIf xValor == "3"
            Aadd(::aErr, "Unitizador " + Alltrim(::cUnitz) + " aguardando endereçamento")
        Else
            Aadd(::aErr, "Montagem do unitizador " + Alltrim(::cUnitz) + " com status: " + RetSX3Box(GetSX3Cache("D0R_STATUS", "X3_CBOX"),,,1)[Val(xValor),3])
        EndIf

        Return .F.

    EndIf

Return .T.


Method Chk_DCF() class TrfUnit
    Local cRes := ""
    Local cmd  := ""

    cmd += CRLF + " SELECT DCF_DOCTO, DCF_CODPRO, DCF_ORIGEM, DCF_ENDER"
    cmd += CRLF + " FROM " + RetSqlName("DCF")
    cmd += CRLF + " WHERE"
    cmd += CRLF + "     D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND DCF_FILIAL = '" + cFilAnt + "' "
    cmd += CRLF + " AND DCF_LOCAL = '"  + ::cOriLoc + "' "
    cmd += CRLF + " AND DCF_ENDER  = '" + ::cOriEnd + "' "
    cmd += CRLF + " AND DCF_UNITIZ = '" + ::cUnitz  + "' "
    cmd += CRLF + " AND DCF_STSERV NOT IN ('0','3')

    TcQuery cmd new Alias (::cAlias)

    (::cAlias)->(DbEval({||  cRes := (::cAlias)->DCF_DOCTO }, {|| Empty((::cAlias)->DCF_CODPRO) = .F. }))
    (::cAlias)->(DbCloseArea())

    If Empty(cRes) = .F.
        Aadd(::aErr, "Ordem de serv. pendente na tabela de ordem de serviço:" + cRes)
        Return.F.
    EndIf

Return .T.


Method Chk_D12() class TrfUnit
    Local cRes := ""
    Local cmd  := ""

    cmd += CRLF + " SELECT D12_DOC, D12_PRODUT, D12_IDUNIT"
    cmd += CRLF + " FROM " + RetSqlName("D12")
    cmd += CRLF + " WHERE"
    cmd += CRLF + "     D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND D12_FILIAL = '" + cFilAnt   + "' "
    cmd += CRLF + " AND D12_IDUNIT = '" + ::cUnitz  + "' "
    cmd += CRLF + " AND D12_LOCORI <> ' ' "
    cmd += CRLF + " AND D12_ENDORI <> ' ' "
    cmd += CRLF + " AND D12_STATUS <> '1' "

    TcQuery cmd new Alias (::cAlias)

    (::cAlias)->(DbEval({|| cRes := (::cAlias)->D12_DOC  }, {|| Empty((::cAlias)->D12_PRODUT) = .F. }))
    (::cAlias)->(DbCloseArea())

    If Empty(cRes) = .F.
        Aadd(::aErr, "Movimentos WMS pendente na tabela Mov. servico WMS:" + cRes)
        Return .F.
    EndIf

Return .T.

Method Chk_SZJ() class TrfUnit
    Local cmd	:= ""
    Local nRes  := ""

    cmd += CRLF + " SELECT ZJ_LOCORI, ZJ_ENDORI, ZJ_STATUS, R_E_C_N_O_ AS RECNO"
    cmd += CRLF + "  FROM " + RetSQLName("SZJ") + " SZJ"
    cmd += CRLF + " WHERE"
    cmd += CRLF + " 	D_E_L_E_T_ <> '*' "
    cmd += CRLF + " AND ZJ_FILIAL = '" + cFilAnt + "'   "
    cmd += CRLF + " AND ZJ_IDUNIT = '" + ::cUnitz + "' "
    cmd += CRLF + " AND ZJ_STATUS in (' ', 'E', 'X') "
    cmd += CRLF + " AND ROWNUM = 1 "
    cmd += CRLF + " ORDER BY R_E_C_N_O_ DESC"

    TcQuery cmd new Alias (::cAlias)

    nRes := (::cAlias)->RECNO

    (::cAlias)->(DbCloseArea())

    If nRes <> 0
        Aadd(::aErr, "O Unitizador: " + AllTrim(::cUnitz) + " não pode ser transferido, já esta em fila!")
        Return .F.
    EndIf

Return .T.


Method Chk_OriDst() class TrfUnit

    If (::cDstLoc = ::cOriLoc) .AND. (::cDstEnd = ::cOriEnd)
        Aadd(::aErr, "Origem igual ao destino, gravação não efetuada")
        Return .F.
    EndIf

Return .T.


Method Chk_DC3() class TrfUnit
    Local cBeEstFis := Posicione("SBE", 1, Xfilial("SBE") + ::cDstLoc + ::cDstEnd, "BE_ESTFIS")
    Local lRes      := .T.
    Local cmd       := ""
    Local bMsg      := Nil
    Local bCmd      := Nil

    cmd += CRLF + " SELECT  D14_FILIAL, DC3_LOCAL, D14_IDUNIT, D14_PRODUT, COUNT(DC3_FILIAL) AS QT_REG_DC3 "
    cmd += CRLF + " FROM ("
    cmd += CRLF + "     SELECT DISTINCT D14_FILIAL, D14_IDUNIT, D14_PRODUT "
    cmd += CRLF + "        FROM " + RetSqlName("D14") + " D14"
    cmd += CRLF + "     WHERE  D14.D_E_L_E_T_ = ' '  "
    cmd += CRLF + "        AND D14_FILIAL = '" + cFilAnt   + "' "
    cmd += CRLF + "        AND D14_LOCAL  = '" + ::cOriLoc + "' "
    cmd += CRLF + "        AND D14_ENDER  = '" + ::cOriEnd + "' "
    cmd += CRLF + "        AND D14_IDUNIT = '" + ::cUnitz  + "' "
    cmd += CRLF + "      ) D14  "
    cmd += CRLF + " LEFT JOIN " + RetSqlName("DC3") + " DC3 ON "
    cmd += CRLF + "     DC3.D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND DC3_FILIAL = D14_FILIAL "
    cmd += CRLF + " AND DC3_CODPRO = D14_PRODUT"
    cmd += CRLF + " AND DC3_LOCAL = '" + ::cDstLoc + "' "
    cmd += CRLF + " GROUP BY D14_FILIAL, DC3_LOCAL, D14_IDUNIT, D14_PRODUT"

    Tcquery cmd new alias (::cAlias)

    bCmd   := {|| lRes:= .F., Aadd(::aErr, "Seq abastec (1)Unitz:" + Alltrim((::cAlias)->D14_IDUNIT) + " Prd:" + Alltrim((::cAlias)->D14_PRODUT)) }
    bCond  := {|| (::cAlias)->QT_REG_DC3 = 0 }

    (::cAlias)->(DbEval(bCmd, bCond))

    (::cAlias)->(DbCloseArea())

    // Valida se na sequencia de abastecimento do item tem uma estrutura do tipo do endereço destino
    cmd := ""
    cmd += CRLF + " SELECT  D14_FILIAL, D14_IDUNIT, D14_PRODUT,  DC3_TPESTR"
    cmd += CRLF + " FROM ("
    cmd += CRLF + "     SELECT DISTINCT D14_FILIAL, D14_IDUNIT, D14_PRODUT "
    cmd += CRLF + "        FROM " + RetSqlName("D14") + " D14"
    cmd += CRLF + "     WHERE  D14.D_E_L_E_T_ = ' '  "
    cmd += CRLF + "        AND D14_FILIAL = '" + cFilAnt   + "' "
    cmd += CRLF + "        AND D14_LOCAL  = '" + ::cOriLoc + "' "
    cmd += CRLF + "        AND D14_ENDER  = '" + ::cOriEnd + "' "
    cmd += CRLF + "        AND D14_IDUNIT = '" + ::cUnitz  + "' "
    cmd += CRLF + "      ) D14  "
    cmd += CRLF + " LEFT JOIN " + RetSqlName("DC3") + " DC3 ON "
    cmd += CRLF + "     DC3.D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND DC3_FILIAL = D14_FILIAL "
    cmd += CRLF + " AND DC3_CODPRO = D14_PRODUT"
    cmd += CRLF + " AND DC3_LOCAL = '" 		+ ::cDstLoc + "'"
    cmd += CRLF + " AND DC3.DC3_TPESTR = '" + cBeEstFis + "'"

    bMsg      := {|| lRes:= .F., Aadd(::aErr, "Seq abastec (2) Unitz:" + Alltrim((::cAlias)->D14_IDUNIT) + " Prd:" + Alltrim((::cAlias)->D14_PRODUT)) }
    bCond     := {|| Empty((::cAlias)->DC3_TPESTR) }

    Tcquery cmd new alias (::cAlias)

    (::cAlias)->(DbEval(bMsg, bCond))

    (::cAlias)->(DbCloseArea())

Return lRes


Method Chk_BlEndDst() class TrfUnit
    Local xValor := Posicione("SBE", 1, cFilAnt + ::cDstLoc + ::cDstEnd, "BE_STATUS")

    If (xValor $ "3|4|6") = .T.
        Aadd(::aErr, "Endereço destino bloqueado, status " + RetSX3Box(GetSX3Cache("BE_STATUS", "X3_CBOX"),,,1)[Val(xValor), 3])
        Return .F.
    EndIf

Return .T.

Method Chk_CapDst(nQtUniz) class TrfUnit
    Local lRes		:= .T.
    Local cmd		:= ""
    Local nQtCapDst := Posicione("SBE", 1, Xfilial("SBE") + ::cDstLoc + ::cDstEnd, "BE_NRUNIT")
    Local nQtEmFila := 0
    Local nQtLocDst := 0

    //Obter a Quantidade na fila de processamento
    cmd := ""
    cmd += " SELECT COUNT(*) as QUANTIDADE "
    cmd += " FROM " + RetSqlName("SZJ") "
    cmd += " WHERE  "
    cmd += "     D_E_L_E_T_ = ' ' "
    cmd += " AND ZJ_FILIAL  = '" + Xfilial("SZJ") + "' "
    cmd += " AND ZJ_LOCDEST = '" + ::cDstLoc + "'   "
    cmd += " AND ZJ_ENDDEST = '" + ::cDstEnd + "'   "
    cmd += " AND ZJ_STATUS  = ' ' "

    TcQuery cmd new alias (::cAlias)

    nQtEmFila := (::cAlias)->QUANTIDADE

    (::cAlias)->(DbCloseArea())

    //Obter a Quantidade de unitizadores no endereço
    cmd := ""
    cmd += " SELECT COUNT(*) as QUANTIDADE FROM  "
    cmd += "    (SELECT  DISTINCT D14_IDUNIT "
    cmd += "     FROM " + RetSqlName("D14") "
    cmd += "     WHERE  "
    cmd += "     D14_LOCAL = '" + ::cDstLoc + "'
    cmd += "     AND D14_ENDER = '" + ::cDstEnd + "'
    cmd += "     AND D_E_L_E_T_ =  ' ' )

    TcQuery cmd new alias (::cAlias)

    nQtLocDst := (::cAlias)->QUANTIDADE

    (::cAlias)->(DbCloseArea())

    If (nQtLocDst + nQtEmFila + nQtUniz) >= nQtCapDst
        cRes := " - A Qt Unitz no Destino:" + CvalToChar(nQtLocDst) 
        cRes += " + Unitz fila Transf:" + CvalToChar(nQtEmFila) 
        cRes += " + Qt a Transferir:" + CvalToChar(nQtUniz) 
        cRes += " Excede capacidade:" + CvalToChar(nQtCapDst)
        Aadd(::aErr, cRes)
        lRes := .F.
    EndIf

Return lRes


Method IsArmazInv(cArmazem) class TrfUnit
	Local cQy3	  := " "
	Local cAlias  := GetNextAlias()
    Local lRes    := .T.

	// verificar na SB2
	cQy3 += Char(13) + Char(10) + " SELECT B2_COD, B2_LOCAL, B2_DTINV FROM " + RetSqlName("SB2") + " SB2 "
	cQy3 += Char(13) + Char(10) + " WHERE D_E_L_E_T_ = ' '
	cQy3 += Char(13) + Char(10) + " AND B2_LOCAL = '" + cArmazem + "' "
	cQy3 += Char(13) + Char(10) + " AND B2_DTINV <> ' '    "

	TcQuery cQy3 new alias (cAlias)

	If !Empty( (cAlias)->B2_DTINV)
        Aadd(::aErr, "Armazem " + cArmazem + " bloqueado por inventário (B2_DTINV > 0)")
        lRes := .F.
	EndIf

	(cAlias)->(DbCloseArea())

Return  lRes



