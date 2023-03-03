#include "topconn.ch"
#include "protheus.ch"
#include "apvt100.ch"

#DEFINE  KEY_ESC     27
#DEFINE  NROWS       12
#DEFINE  NCOLS       24

/*
==============================================================================================
Funcao.........:	ZACDF001
Descricao......:	Gravar a movimentação de armazém em tabela auxiliar para posterior processamento
Autor..........:	Valter Carvalho
Criação........:	13/03/2020
============================================================================================== */
User Function ZACDF001( cOriUnitz )   // vtdebug
	Local xValor    := ""
	Local cErr      := ""
	Local lLoop		:= .T.
	Local nRecno    := 0
	Local cDoc		:= ""
	Local nQTDupli  := 0
    Local cTb		:= GetNextAlias()
	Local cOriLoc  	:= Space(TamSx3("NNR_CODIGO")[1])   		//aramzem orige
	Local cOriEnd  	:= Space(TamSx3("BE_LOCALIZ")[1])   		// endereco origem
	Local cOriLocUn	:= "" 										// verifica se armazem  origem usa unitizacao
	Local cOriEndUn	:= ""										// verifica se endereco origem usa unitizacao
	Local cTpTransf := " "										// tipo de transf 1- total 2 - parcial
	Local cDstLoc 	:= Space(TamSx3("NNR_CODIGO")[1])           //  armazem destino
	Local cDstEnd	:= Space(TamSx3("BE_LOCALIZ")[1])			//  endereco destino
	Local aUMvUntiz := {}
	VtSetSize(NROWS , NCOLS)
	
	While lLoop
	
		aUMvUntiz   := {}
		cErr		:= ""
		nRecno      := 0
		nQTDupli    := 0
		cDoc		:= ""
		cOriLoc  	:= Space(TamSx3("NNR_CODIGO")[1])   		//aramzem orige
		cOriEnd  	:= Space(TamSx3("BE_LOCALIZ")[1])   		// endereco origem
		cOriLocUn	:= "" 										// verifica se armazem  origem usa unitizacao
		cOriEndUn	:= ""										// verifica se endereco origem usa unitizacao
		cTpTransf 	:= " "										// tipo de transf 1- total 2 - parcial
		cDstLoc 	:= Space(TamSx3("NNR_CODIGO")[1])           //  armazem destino
		cDstEnd		:= Space(TamSx3("BE_LOCALIZ")[1])				//  endereco destino

		VtClear()

		If FunName() == "U_ZACDF002"
			lLoop := .F.
		Else							// codigo unitizador origem
			cOriUnitz := Space(TamSx3("D14_IDUNIT")[1])
			If (RetCodUsr() $ '000358|000429') //== .T.
				cOriUnitz := "XTIS19F001L03                          "
			EndIf
		EndIf
		@ 0,00 VTSAY "- Transf CAOA (1) - "

		@ 2,00 VTSAY "Unitizador:"
		@ 3,00 VTSAY "" VTGet cOriUnitz Pict PesqPict("D0R", "D0R_IDUNIT") Valid !Empty(cOriUnitz)

		VTRead()
		If VtLastKey() == KEY_ESC
			Return
		EndIf

		// verifica o endereco e o aemazem
		LocEnd(@cOriLoc, @cOriEnd, cOriUnitz) 
		If Empty(cOriLoc) .Or. Empty(cOriEnd)
			VTAlert( "Unitizador não existe na tabela de saldo por endereço no WMS,", "Erro", .T.)
			Loop
		EndIf

		//Verificar o status da montagem do unitizador
		xValor := Posicione("D0R", 1, cFilAnt + cOriLoc + cOriEnd + cOriUnitz, "D0R_STATUS") 
		
		If (xValor <> "4") .AND. !Empty(xValor)

			If xValor == "2"
				xValor := "Unitizador Aguardando geracao de O.S. "
			ElseIf xValor == "3"
				xValor := "Unitizador aguardando endereçamento"
			Else
				xValor := "Montagem do unitizador com status: " + RetSX3Box(GetSX3Cache("D0R_STATUS", "X3_CBOX"),,,1)[Val(xValor),3]
			EndIf

			VTAlert( xValor, "Erro", .T.)
			Loop
		EndIf

		// verificar se tem bloqueio no end origem
		xValor := Posicione("SBE", 1, Xfilial("SBE") + cOriLoc + cOriEnd, "BE_STATUS")
		If (xValor $ "3|4|6")
			VTAlert( "Endereço origem bloqueado, com status de " +  RetSX3Box(GetSX3Cache("BE_STATUS", "X3_CBOX"),,,1)[Val(xValor),3]            , "Erro", .T.)
			Loop
		EndIf

		// verificar Status da ordem de serviço endereço origem DCF
		xValor := OkDcf(cOriLoc, cOriEnd, cOriUnitz)
		If !Empty(xValor)
			VTAlert( "Ordem de serv. pendente na tabela de ordem de serviço:" + xValor, "Erro", .T.)
			Loop
		EndIf

		// verificar Status da ordem de serviço endereço origem D12
		xValor :=  OkD12(cOriUnitz)
		If !Empty(xValor)
			VTAlert( "Movimentos WMS pendente na tabela Mov. servico WMS:" + xValor, "Erro", .T.)
			Loop
		EndIf

		// pegue o status do unitizador na fila.... ....
		aUMvUntiz := {}		
		aUMvUntiz := aMovPend(cOriUnitz)

		// Verificar se o processo  está na fila
		if  aUMvUntiz[1] > 0 //--.AND. Empty(aUMvUntiz[2]) = .T.
			VTAlert( "O Unitizador: " + AllTrim(cOriUnitz) + " não pode ser transferido, já esta em fila!", "Erro", .T.)
			Loop
		EndIf

		VtClear()
		@ 0,00 VTSAY "- Transf CAOA (2) -"
		@ 1,00 VTSAY "Armz.Destino:"	VTGet cDstLoc Pict PesqPict("NNR", "NNR_CODIGO") Valid ValidaInf("NNR", 1, Xfilial("NNR") + cDstLoc, "NNR_CODIGO")

		@ 2,00 VTSAY "Endereco Destino:"
		@ 3,00 VTSAY "" 				VTGet cDstEnd Pict PesqPict("SBE", "BE_LOCALIZ") Valid ValidaInf("SBE", 1, Xfilial("SBE") + cDstLoc + cDstEnd, "BE_LOCALIZ")
		
		VTRead()
		If VtLastKey() == KEY_ESC
			Return
		EndIf

		// Verificar se o destino informado não é o mesmo da origem
		If (cDstLoc == cOriLoc) .AND. (cDstEnd == cOriEnd)
			VTAlert( "Origem igual ao destino, gravação não efetuada" , "Erro", .T.)
			Loop
		EndIf

		// verificar se a origem ou o destino 
		If !OkEndInvent(cOriLoc, cOriEnd, cDstLoc, cDstEnd, { cOriUnitz }) 
			VTAlert( "Consta data inventario na origem e/ou destino na SB2", "Erro", .T.)
			Loop
		EndIf

		// Verificar se o peso excede a capacidade do destino
/* 		If OkPeso(cDstLoc, cDstEnd, {cOriUnitz}) = .f.
    		VTAlert("Divergencia de peso nos itens, excede capacidade destino.", "Erro", .T.)
			Loop
	EndIf
 */
	// Verifica se os produtos têm seq abastecimento
	If !OkSeqDc3(cOriLoc, cOriEnd, cDstLoc, cDstEnd, { cOriUnitz })
		Loop
	EndIf

	// verificar se tem bloqueio no end destino
	xValor := Posicione("SBE", 1, cFilAnt + cDstLoc + cDstEnd, "BE_STATUS")
	If (xValor $ "3|4|6") //= .T.
		VTAlert( "Endereço destino bloqueado, com status de " +  RetSX3Box(GetSX3Cache("BE_STATUS", "X3_CBOX"),,,1)[Val(xValor),3]            , "Erro", .T.)
		Loop
	EndIf

	// verifica se tem espaço no Endereco destino
	cMsg := OkCapDst(cDstLoc, cDstEnd)
	If !Empty(cMsg) //= .F.
		VTAlert( cMsg, "Erro", .T.)
		Loop
	EndIf

	// ACD107 - Bloqueio de transferencia de Unitizador
	VtClear()
	@ 02,00 VtSay "Verificando Duplicidades..."

    cmd := ""
	cmd += CRLF + " SELECT COUNT(*) as QUANTIDADE "
	cmd += CRLF + " FROM " + RetSqlName("SZJ") "
	cmd += CRLF + " WHERE  "
	cmd += CRLF + "     D_E_L_E_T_ = ' ' "
	cmd += CRLF + " AND ZJ_FILIAL  = '" + Xfilial("SZJ") + "'   "
	cmd += CRLF + " AND ZJ_IDUNIT  = '" + cOriUnitz      + "'   "
	cmd += CRLF + " AND ZJ_LOCORI  = '" + cOriLoc        + "'   "
	cmd += CRLF + " AND ZJ_ENDORI  = '" + cOriEnd        + "'   "
	cmd += CRLF + " AND ZJ_STATUS  <> 'F'                       "

	TcQuery cmd new alias (cTb)

    nQTDupli := (cTb)->QUANTIDADE

	(cTb)->(DbCloseArea())

	If nQTDupli = 0

		// Inserir os dados na fila de transferencia.
		VtClear()
		@ 02,00 VtSay "Registrando transferência..."

		DbSelectArea("SZJ")
		DbSetOrder(1)
		cDoc := Space(tamsx3("ZJ_DOCTO")[1])

		RecLock("SZJ", .T.)
			SZJ->ZJ_FILIAL	:= cFilAnt
			SZJ->ZJ_DOCTO	:= cDoc
			SZJ->ZJ_TIPO    := "T"
			SZJ->ZJ_TIPOUNI := ""
			SZJ->ZJ_STATUS  := ""
			SZJ->ZJ_PRODUTO	:= Space(TamSx3("B1_COD")[1])
			SZJ->ZJ_QTDE	:= 0

			SZJ->ZJ_LOCORI	:= cOriLoc
			SZJ->ZJ_ENDORI	:= cOriEnd
			SZJ->ZJ_IDUNIT	:= cOriUnitz
			SZJ->ZJ_LOCDEST	:= cDstLoc
			SZJ->ZJ_ENDDEST := cDstEnd
			SZJ->ZJ_IDUDEST	:= cOriUnitz
			SZJ->ZJ_HRLEITU := Time()
			SZJ->ZJ_USR     := RetCodUsr()
			SZJ->ZJ_DATA    := Date()

		SZJ->(Msunlock())

		VTBeep()
		VtClear()
		VTAlert("Registrado com sucesso" , "", .T., 1500)

	Else
        
		VtClear()
		VTAlert( "Unitizador já esta en fila de Transferência Com a mesma Origem." , "Erro", .T.)
	
	Endif

EndDo

Return

/*
==============================================================================================
Funcao.........:	OkCapDst()
Descricao......:	Define se a quantidade de unitizadores na fila de processo mais a de unizadores 
					no destino excede a capacidade de unizadores do endereço destino
Autor..........:	Valter Carvalho
Criação........:	03/06/2020
============================================================================================== */
Static Function OkCapDst(cDstLoc, cDstEnd)
	Local cRes		:= ""
	Local cTb		:= GetNextAlias()
	Local cmd		:= ""
	Local nQtCapDst := Posicione("SBE", 1, Xfilial("SBE") + cDstLoc + cDstEnd, "BE_NRUNIT")
	Local nQtEmFila := 0
	Local nQtLocDst := 0

	VtClear()
    @ 02,00 VtSay "Verif. cap Unitz destino..."

	//Obter a Quantidade na fila de processamento
	cmd := CRLF + ""
	cmd += CRLF + " SELECT COUNT(*) as QUANTIDADE "
	cmd += CRLF + " FROM " + RetSqlName("SZJ") "
	cmd += CRLF + " WHERE  "
	cmd += CRLF + "     D_E_L_E_T_ = ' ' "
	cmd += CRLF + " AND ZJ_FILIAL  = '" + Xfilial("SZJ") + "' "
	cmd += CRLF + " AND ZJ_LOCDEST = '" + cDstLoc + "'   "
	cmd += CRLF + " AND ZJ_ENDDEST = '" + cDstEnd + "'   "
	cmd += CRLF + " AND ZJ_STATUS  = ' ' "

	TcQuery cmd new alias (cTb)

	nQtEmFila := (cTb)->QUANTIDADE

	(cTb)->(DbCloseArea())

	//Obter a Quantidade de unitizadores no endereço
	cmd := CRLF + ""
	cmd += CRLF + " SELECT COUNT(*) as QUANTIDADE FROM  "
	cmd += CRLF + "    (SELECT  DISTINCT D14_IDUNIT "
	cmd += CRLF + "     FROM " + RetSqlName("D14") "
	cmd += CRLF + "     WHERE  "
	cmd += CRLF + "     D14_LOCAL = '" + cDstLoc + "'
	cmd += CRLF + "     AND D14_ENDER = '" + cDstEnd + "'
	cmd += CRLF + "     AND D_E_L_E_T_ =  ' ' )

	TcQuery cmd new alias (cTb)

	nQtLocDst := (cTb)->QUANTIDADE

	(cTb)->(DbCloseArea())

	if (nQtLocDst + nQtEmFila) >= nQtCapDst
		cRes:=;
		"Unitz End Destino:" + cValToChar(nQtLocDst) + CRLF +;
		" +                " + CRLF +;
		"Unitz fila Transf:" + cValToChar(nQtEmFila) + CRLF +;
		"Excede capacidade:" + cValToChar(nQtCapDst)
	EndIf

Return cRes


/*
==============================================================================================
Funcao.........:	validaInf(cTabela, nIndice, xVlPesq, cCampo)
Descricao......:	Pesquisa de um armazem ou endereço existe
Autor..........:	Valter Carvalho
Criação........:	13/03/2020
============================================================================================== */
Static Function validaInf(cTabela, nIndice, xVlPesq, cCampo)
	Local lRes := .T.

	if Empty(Posicione(cTabela, nIndice, xVlPesq, cCampo))
		lRes := .F.
		VTBeep()
		VTAlert( Alltrim(GetSx3Cache(cCampo, "X3_DESCRIC")) + " nao cadastrado" , "Erro",.T.)
	EndIf

Return lRes


/*
==============================================================================================
Funcao.........:	aMovPend(cLoc=ARAMZEM, cEnd=ENDERECO, cOriUnitz=codunitizador)
Descricao......:	Verifica o ultimo movimento do unitizador na fila para processo.
Autor..........:	Valter Carvalho
Criação........:	13/03/2020
============================================================================================== */
Static Function aMovPend(cOriUnitz)
	Local aRes	:= {}
	Local cmd	:= ""
	Local cTb   := GetNextAlias()

	cmd += CRLF + " SELECT ZJ_LOCORI, ZJ_ENDORI, ZJ_STATUS, R_E_C_N_O_ AS RECNO"
	cmd += CRLF + "  FROM " + RetSQLName("SZJ") + " SZJ" 
	cmd += CRLF + " WHERE"
	cmd += CRLF + " 	D_E_L_E_T_ <> '*' "
	cmd += CRLF + " AND ZJ_FILIAL = '" + cFilAnt + "'   "
	cmd += CRLF + " AND ZJ_IDUNIT = '" + cOriUnitz + "' "
	cmd += CRLF + " AND ZJ_STATUS in (' ', 'E', 'X') "
	cmd += CRLF + " AND ROWNUM = 1 " 
	cmd += CRLF + " ORDER BY R_E_C_N_O_ DESC"

	TcQuery cmd new Alias (cTb)

	If  (cTb)->RECNO <> 0
		Aadd(aRes, (cTb)->RECNO)
		Aadd(aRes, (cTb)->ZJ_STATUS)
		Aadd(aRes, (cTb)->ZJ_LOCORI)
		Aadd(aRes, (cTb)->ZJ_ENDORI)
	Else
		aRes := { 0, "", "", ""}
	EndIf

	(cTb)->(DbCloseArea())

Return aRes


/*
==============================================================================================
Funcao.........:	LocEnd(cLoc=ARAMZEM, cEnd=ENDERECO, cOriUnitz=codunitizador)
Descricao......:	Pesquisa local e endereco do unitizador
Autor..........:	Valter Carvalho
Criação........:	13/03/2020
============================================================================================== */
Static Function LocEnd(cLoc, cEnd, cOriUnitz)
	Local cmd	:= ""
	Local cTb   := GetNextAlias()

	cmd += CRLF + " SELECT * FROM "
	cmd += CRLF + RetSQLName("D14") + " D14 "
	cmd += CRLF + " WHERE "
	cmd += CRLF + " 	D_E_L_E_T_ <> '*' "
	cmd += CRLF + "	AND D14_FILIAL = '" + cFilAnt + "' "
	cmd += CRLF + " AND D14_IDUNIT = '" + cOriUnitz  + "' "

	TcQuery cmd new Alias (cTb)

	cLoc := (cTb)->D14_LOCAL
	cEnd := (cTb)->D14_ENDER

	(cTb)->(DbCloseArea())
Return


/*
==============================================================================================
Funcao.........:	OkSeqDc3(cLoc=ARAMZEM, cEnd=ENDERECO, cXlote=codunitizador)
Descricao......:	Efetua a verificação de todos os produtos dos unitizadores e verifica se têm seqeuncia de abastecimento. 
Autor..........:	Valter Carvalho
Criação........:	13/03/2020
============================================================================================== */
Static Function OkSeqDc3(cOriLoc, cOriEnd, cDstLoc, cDstEnd, aUnitz)
	Local cBeEstFis := Posicione("SBE", 1, Xfilial("SBE") + cDstLoc + cDstEnd, "BE_ESTFIS")
	Local lRes      := .T.
    Local cmd       := ""
    Local cErr      := "" 
    Local cTb    	:= GetNextAlias() 
    Local cLstUni   := ""
    Local bMsg      := {|| cErr += "Unitz:" + Alltrim((cTb)->D14_IDUNIT) + " Prd:" + Alltrim((cTb)->D14_PRODUT + CRLF) }   
    Local bCond     := {|| (cTb)->QT_REG_DC3 == 0 }
        
    VtClear()
    @ 02,00 VtSay "Verif. seq abastecimento, estrutura..."

    Aeval(aUnitz, {|cIt| cLstUni += " '" + cIt + "'," + CRLF})
    cLstUni := Substr(cLstUni, 1, Len(cLstUni)-3)

    cmd += CRLF + " SELECT  D14_FILIAL, DC3_LOCAL, D14_IDUNIT, D14_PRODUT, COUNT(DC3_FILIAL) AS QT_REG_DC3 "
    cmd += CRLF + " FROM ("
    cmd += CRLF + "     SELECT DISTINCT D14_FILIAL, D14_IDUNIT, D14_PRODUT "
    cmd += CRLF + "        FROM " + RetSqlName("D14") + " D14" 
    cmd += CRLF + "     WHERE  D14.D_E_L_E_T_ = ' '  "
    cmd += CRLF + "        AND D14_FILIAL = '" + cFilAnt + "' "
    cmd += CRLF + "        AND D14_LOCAL  = '" + cOriLoc + "' "
    cmd += CRLF + "        AND D14_ENDER  = '" + cOriEnd + "' "
    cmd += CRLF + "        AND D14_IDUNIT IN ( " + cLstUni + ") " "
    cmd += CRLF + "      ) D14  "
    cmd += CRLF + " LEFT JOIN " + RetSqlName("DC3") + " DC3 ON "
    cmd += CRLF + "     DC3.D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND DC3_FILIAL = D14_FILIAL "
    cmd += CRLF + " AND DC3_CODPRO = D14_PRODUT"
    cmd += CRLF + " AND DC3_LOCAL = '" + cDstLoc + "' "
    cmd += CRLF + " GROUP BY D14_FILIAL, DC3_LOCAL, D14_IDUNIT, D14_PRODUT"

    Tcquery cmd new alias (cTb)

    (cTb)->(DbEval(bMsg, bCond))

    (cTb)->(DbCloseArea())

	If cErr <> ""
		lRes := .F.
        VTAlert( cErr, "Erro Seq abastec (1)", .T.)
		Return  lRes
	EndIf

    VtClear()
    @ 02,00 VtSay "Verif. seq abastecimento, Tipo..."

	// Valida se na sequencia de abastecimento do item tem uma estrutura do tipo do endereço destino
	cmd := ""
    cmd += CRLF + " SELECT  D14_FILIAL, D14_IDUNIT, D14_PRODUT,  DC3_TPESTR"
    cmd += CRLF + " FROM ("
    cmd += CRLF + "     SELECT DISTINCT D14_FILIAL, D14_IDUNIT, D14_PRODUT "
    cmd += CRLF + "        FROM " + RetSqlName("D14") + " D14" 
    cmd += CRLF + "     WHERE  D14.D_E_L_E_T_ = ' '  "
    cmd += CRLF + "        AND D14_FILIAL = '" + cFilAnt + "' "
    cmd += CRLF + "        AND D14_LOCAL  = '" + cOriLoc + "' "
    cmd += CRLF + "        AND D14_ENDER  = '" + cOriEnd + "' "
    cmd += CRLF + "        AND D14_IDUNIT IN ( " + cLstUni + ") " "
    cmd += CRLF + "      ) D14  "
    cmd += CRLF + " LEFT JOIN " + RetSqlName("DC3") + " DC3 ON "
    cmd += CRLF + "     DC3.D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND DC3_FILIAL = D14_FILIAL "
    cmd += CRLF + " AND DC3_CODPRO = D14_PRODUT"
    cmd += CRLF + " AND DC3_LOCAL = '" 		+ cDstLoc 	+ "' "
    cmd += CRLF + " AND DC3.DC3_TPESTR = '" + cBeEstFis + "'"

    bMsg      := {|| cErr += "Unitz:" + Alltrim((cTb)->D14_IDUNIT) + " Prd:" + Alltrim((cTb)->D14_PRODUT + CRLF) }   
    bCond     := {|| Empty((cTb)->DC3_TPESTR) }

    Tcquery cmd new alias (cTb)

    (cTb)->(DbEval(bMsg, bCond))
    
	(cTb)->(DbCloseArea())

	If cErr <> ""
		lRes := .F.
        VTAlert( cErr, "Erro Seq abastec (2)", .T.)
		Return  lRes
	EndIf

Return lRes


/*
==============================================================================================
Funcao.........:	OkPeso
Descricao......:	Verifica se o peso da origem e do destino somados excede a capacidade
Autor..........:	Valter Carvalho
Criação........:	13/03/2020
============================================================================================== 
Static Function OkPeso(cDstLoc, cDstEnd, aUnitz)
	Local cLstUni  := ""
	Local lRes     := .T.
	Local cTb      := GetNextAlias()
	Local cmd 	   := ""
	Local nBeCap   := Posicione("SBE", 1, Xfilial("SBE") + cDstLoc + cDstEnd, "BE_CAPACID")
	Local nPesEnds := 0

	VtClear()
    @ 02,00 VtSay "Verif. cap Unitz destino..."

	Aeval(aUnitz, {|cIt| cLstUni += " '" + cIt + "', "})
	cLstUni := Substr(cLstUni, 1, len(cLstUni)-2)

	
	cmd += CRLF + " SELECT DISTINCT D14_IDUNIT, D14_ESTFIS, D0T_CODUNI, D0T_CAPMAX"
	cmd += CRLF + " FROM d14010 D14"
	cmd += CRLF + " LEFT JOIN D0T010 D0T ON D0T.D_E_L_E_T_ = ' ' AND D0T_FILIAL = D14_FILIAL AND D0T_CODUNI = D14_CODUNI"
	cmd += CRLF + " WHERE"
	cmd += CRLF + "     D14.D_E_L_E_T_ = ' '"
	cmd += CRLF + " AND D14_FILIAL = '" + cFilAnt + "' "
	cmd += CRLF + " AND ("
	cmd += CRLF + "       ( D14_IDUNIT IN (" + cLstUni + ")) OR"
	cmd += CRLF + "       ( D14_LOCAL = '" + cDstLoc + "' AND D14_ENDER= '" + cDstEnd + "' ) "   
	cmd += CRLF + "    ) "


    Tcquery cmd new alias (cTb)	

	(cTb)->(DbEval({|| nPesEnds += (cTb)->D0T_CAPMAX}, {|| .T.} ))
	
	(cTb)->(DbCloseArea())

	If nPesEnds >  nBeCap
		lRes := .F.
	EndIf

Return  lRes
*/


/* Static Function getOpc(cMsg)
	Local nPos
	Local aIt := {"- Informe outro endereço", "- Reprocessar"}
	Local aOp := {.T., .T.}

	VtClear()
	@ 0,00 VTSAY Substr(cMsg,01,24)
	@ 1,00 VTSAY Substr(cMsg,25,24)

    nPos  := VTACHOICE(4, 0, 7, 19, aIt, aOp, nil )
Return nPos
 */

/*
==============================================================================================
Funcao.........:	OkDcf
Descricao......:	Verifica se o existe ordem de serviço pendente
Autor..........:	Valter Carvalho
Criação........:	13/03/2020
============================================================================================== */
Static Function OkDcf(cOriLoc, cOriEnd, cOriUnitz)
	Local cRes := ""
	Local cmd  := ""
	Local cTb  := GetNextAlias()

	VtClear()
	@ 02,00 VtSay "Verif. Ord de Servico..."

	cmd += CRLF + " SELECT DCF_DOCTO, DCF_CODPRO, DCF_ORIGEM, DCF_ENDER"
	cmd += CRLF + " FROM " + RetSqlName("DCF")
	cmd += CRLF + " WHERE"
	cmd += CRLF + "     D_E_L_E_T_ = ' ' "
	cmd += CRLF + " AND DCF_FILIAL = '" + cFilAnt + "' "
	cmd += CRLF + " AND DCF_LOCAL = '"  + cOriLoc + "' "
	cmd += CRLF + " AND DCF_ENDER  = '" + cOriEnd + "' "
	cmd += CRLF + " AND DCF_UNITIZ = '" + cOriUnitz + "' "
	cmd += CRLF + " AND DCF_STSERV NOT IN ('0','3')

	TcQuery cmd new Alias (cTb)

	(cTb)->(DbEval({||  cRes := (cTb)->DCF_DOCTO }, {|| !Empty((cTb)->DCF_CODPRO) }))
	(cTb)->(DbCloseArea())

Return cRes


/*
==============================================================================================
Funcao.........:	OkD12
Descricao......:	Verifica se o existe pendencia na D12
Autor..........:	Valter Carvalho
Criação........:	13/03/2020
============================================================================================== */
Static Function OkD12(cOriUnitz)
	Local cRes := ""
	Local cmd  := ""
	Local cTb  := GetNextAlias()

	VtClear()
	@ 02,00 VtSay "Verif. Mov. Servico..."

	cmd += CRLF + " SELECT D12_DOC, D12_PRODUT, D12_IDUNIT"
	cmd += CRLF + " FROM " + RetSqlName("D12")
	cmd += CRLF + " WHERE"
	cmd += CRLF + "     D_E_L_E_T_ = ' ' "
	cmd += CRLF + " AND D12_FILIAL = '" + cFilAnt   + "' "
	cmd += CRLF + " AND D12_IDUNIT = '" + cOriUnitz + "' "
	cmd += CRLF + " AND D12_LOCORI <> ' ' "
	cmd += CRLF + " AND D12_ENDORI <> ' ' "
	cmd += CRLF + " AND D12_STATUS <> '1' "

	TcQuery cmd new Alias (cTb)

	(cTb)->(DbEval({|| cRes := (cTb)->D12_DOC  }, {|| !Empty((cTb)->D12_PRODUT) }))
	(cTb)->(DbCloseArea())

Return cRes


/* ===========================================================================================
Funcao.........:	OkEndInvent
Descricao......:	Verifica se o endereco origem e destino está com inventario
Autor..........:	Valter Carvalho
Criação........:	13/03/2020
============================================================================================== */
Static Function OkEndInvent(cOriLoc, cOriEnd, cDstLoc, cDstEnd,  aUnitz )
	Local lRes 	 := .T.
	Local cmd 	 := ""
	Local cAlias := GetNextAlias()

	// verificar na SB2
	cmd += CRLF + " SELECT /* B2_COD, B2_LOCAL, */ B2_DTINV FROM " + RetSqlName("SB2") + " SB2 "
	cmd += CRLF + " WHERE D_E_L_E_T_ = ' '
	cmd += CRLF + " AND B2_COD IN ( SELECT D14_PRODUT FROM " + RetSqlName("D14") + " D14 "
	cmd += CRLF + "                 WHERE D_E_L_E_T_ = ' '
	cmd += CRLF + "                 AND D14_IDUNIT = '" + aUnitz[1] + "' )"   // 18891-CT1720200806C13C4
	cmd += CRLF + " AND B2_LOCAL IN ('" + cOriLoc + "','" + cDstLoc + "') "
	cmd += CRLF + " AND B2_DTINV <> ' '    "

	TcQuery cmd new alias (cAlias)

    (cAlias)->(DbEval({|| lRes := .F.}, {|| !Empty( (cAlias)->B2_DTINV) }))

	(cAlias)->(DbCloseArea())

	If lRes = .F.
		Return .F.
	EndIf

Return lRes
