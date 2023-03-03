#include "topconn.ch"
#include "protheus.ch"
#include "apvt100.ch"

#DEFINE  KEY_ESC       27
#DEFINE  KEY_0         48
#DEFINE  KEY_1         49
#DEFINE  KEY_2         50

/*
==============================================================================================
Funcao.........:	ZACDF001
Descricao......:	Gravar a movimentação de armazém em tabela auxiliar para posterior processamento
Autor..........:	Valter Carvalho
Criação........:	13/03/2020
==============================================================================================
*/

User Function ZACDF002()   // vtdebug
	Local nKey      := 0
	Local lLoop     := .T.
	Local cUnitz    := ""
	Local cAux	    := " "
	Local cPic      := PesqPict("D0R", "D14_IDUNIT")
	Local nY		:= 3
	Local i			:= 1
	Private nRows   := 12
	Private nCols   := 24


	While .T.
		nY		:= 3
		cUnitz	:= Space(TamSx3("D14_IDUNIT")[1])								// codigo unitizador origem

		VTClear()
		VtSetSize(nRows , nCols)

		if RetCodUsr() == "000358"  // em testes
			VTKeyBoard("0000000030908")
		EndIf

		@ 00, 00 VTSAY "Cons Unitizador CAOA:"
		@ 01, 00 VTSAY "Unitizador:"
		@ 02, 00 VTSAY "" VTGet cUnitz Pict cPic Valid !Empty(cUnitz)

		VTRead()

		If VtLastKey() = KEY_ESC .OR. VtLastKey() = KEY_0
			Return
		EndIf

		aRes := LocEnd(cUnitz) // verifica o endereco e o armazem

		if Len(aRes) = 0
			VtAlert( "Unitizador não existe na tabela de saldo por endereço no WMS,", "Erro", .T.)
			Loop
		EndIf

		aRes := GeraPainel({"Loc ", "Endereco", "DCF"}, aRes)

		For i:= 1 to len(aRes)
			@ nY, 00 VTSAY aRes[i]
			nY := nY + 1
		Next

		lLoop := .T.
		While lLoop = .T.

			@ 03, 00 VTSAY "0:Voltar 1:Transf 2:Det  "

			@ 02, 23 VTSAY "" VTGet cAux Pict "" Valid .T.

			VtRead()

			nKey := VtLastKey()

			Do Case

			Case  nKey = KEY_1

				VtSetSize(nRows , nCols)
				U_ZACDF001(cUnitz)
				lLoop := .F.

			Case nKey =  KEY_2

				MostraDetalhes(cUnitz)
				lLoop := .F.

			Case nKey = KEY_ESC .OR. nKey = KEY_0

				lLoop := .F.
				Loop

			End
		EndDo
	EndDo
Return


Static Function MostraDetalhes(cUnitz)
	Local aCab		:= {"Prod", "Descr", "Est", "Lote", "Validade"}
	Local aItens	:= GetDetItem(cUnitz)
	Local i			:= 1
	Local aSize   	:= { 1, 1, 1, 1, 1}

	VtClear()

	// array de larguras das colunas
	For i:=1 to Len(aSize)
		Aeval(aItens, {|aIt|  Iif(Len(aIt[i]) > aSize[i], aSize[i] := Len(aIt[i]), "" )    })
	Next

	@ 0,0 VTSAY "ESC:Voltar" 

	VTaBrowse(1, 0, 7, 24, aCab, aItens, aSize, {||FValBrw()}, 0)

Return


/*
==============================================================================================
Funcao.........:	FValBrw
Descricao......:	Função que controla os eventos de tecla no browse de detalhes. 
Autor..........:	Valter Carvalho
Criação........:	08/05/2020
==============================================================================================
*/
Static Function FValBrw()
	Local nRes := 2

	If VtLastKey() =  KEY_ESC
		nRes :=  0
	EndIf
return nRes


/*
==============================================================================================
Funcao.........:	GetDetItem
Descricao......:	Efetua a consulta aos itens do unitizador.
Autor..........:	Valter Carvalho
Criação........:	08/05/2020
==============================================================================================
*/
Static Function GetDetItem(cUnitz)
	Local cMask  	:= "@E 999999.99"
	Local nLenCod	:= 1
	Local cmd 		:= ""
	Local cTb		:= "ZZZ"
	Local aRes		:= {}
	Local aIt		:= {}

	cmd += "  SELECT D14_PRODUT "
	cmd += ", Substr(B1_DESC, 1, 10) as B1_DESC "
	cmd += ", D14_QTDEST "
	cmd += ", D14_LOTECT "
	cmd += ", D14_DTVALD "
	cmd += ", D14_QTDSPR "
	cmd += ", D14_QTDEPR "
	cmd += " FROM " + RetSQLName("D14") "
	cmd += " INNER JOIN " + RetSQLName("SB1") + " ON B1_COD = D14_PRODUT  AND SB1010.D_E_L_E_T_ <> '*' "
	cmd += " WHERE D14_IDUNIT = '" + Alltrim(cUnitz) + "' "
	cmd += " AND D14010.D_E_L_E_T_ <> '*' "
	cmd += " AND D14_QTDEST <> 0 "


	TcQuery cmd new Alias (cTb)

	While (cTb)->(eof()) = .F.
		aIt := {}

		// definir o tamanho maximo campo  do produto
		If Len( Alltrim( (cTb)->D14_PRODUT) ) > nLenCod
			nLenCod := Len( Alltrim( (cTb)->D14_PRODUT))
		EndIf

		Aadd( aIt, (cTb)->D14_PRODUT )
		Aadd( aIt, Substr((cTb)->B1_DESC, 1, 10) )
		Aadd( aIt, Transform((cTb)->D14_QTDEST, cMask))
		Aadd( aIt, (cTb)->D14_LOTECT )
		Aadd( aIt, Dtoc(stod((cTb)->D14_DTVALD)) )

		Aadd(aRes, aIt )

		(cTb)->(DbSkip())
	EndDo

	(cTb)->(DbCloseArea())

	// tratamento para truncar a coluna codigo pelo maior comprimento achado
	Aeval( aRes, {|aIt| aIt[1] :=  PadR(aIt[1], nLenCod, " ")})


	If Len(aRes) = 0
		aRes := {{"", "", "", "", "" }}
	EndIf

Return aRes


/*
==============================================================================================
Funcao.........:	GeraPainel
Descricao......:	Gera painel com o resultado da consulta do unitizador
Autor..........:	Valter Carvalho
Criação........:	08/05/2020
==============================================================================================
*/
Static Function GeraPainel(aCab, aDado)
	Local i		:= 1
	Local nAux	:= 1
	Local cAux  := ""
	Local aRes	:= {}

	Aeval(aDado[1], {|cIt| nAux +=  len(cIt) + 2}) //conte quantos caracteres precisa na horizontal

	// linha acima do cabecalho
	cAux:= ""
	cAux := Padr(cAux, nAux, "-" )
	Aadd(aRes, cAux )

	///cabecalho
	cAux:= ""
	For i:= 1 to len(aCab)
		cAux += "|" + Padr(aCab[i],  len(aDado[1,i]),  " ")
	Next
	Aadd(aRes, cAux + " |")

	// linha abaixo do cabecalho
	cAux:= ""
	cAux := Padr(cAux, nAux, "-" )
	Aadd(aRes, cAux )

	// linha com os dados
	For i:=1 to Len(aDado)
		cAux := ""
		Aeval(aDado[i], {|cIt|  cAux +=  "|" + cIt})
		Aadd(aRes, cAux + " |" + CRLF )
	Next

Return aRes



/*
==============================================================================================
Funcao.........:	LocEnd(cLoc=ARAMZEM, cEnd=ENDERECO, cOriUnitz=codunitizador)
Descricao......:	Pesquisa local e endereco do unitizador
Autor..........:	Valter Carvalho
Criação........:	08/05/2020
==============================================================================================
*/
Static Function LocEnd(cOriUnitz)
	Local aRes  := {}
	Local cmd	:= ""
	Local cAlias:= "ZZZ"

	cmd += CRLF + "  SELECT D14_LOCAL"
	cmd += CRLF + ", D14_ENDER "
	cmd += CRLF + ", CASE WHEN D14_QTDSPR <> D14_QTDEPR  THEN 'SIM' ELSE 'NAO' END AS DCF "
	cmd += CRLF + " FROM " + RetSQLName("D14") + " D14 "
	cmd += CRLF + " WHERE "
	cmd += CRLF + " 	D_E_L_E_T_ <> '*' "
	cmd += CRLF + "	AND D14_FILIAL = '" + cFilAnt + "' "
	cmd += CRLF + " AND D14_IDUNIT = '" + cOriUnitz  + "' "

	TcQuery cmd new Alias (cAlias)

	If Empty((cAlias)->D14_LOCAL) = .F. .AND. Empty((cAlias)->D14_ENDER) = .F.
		aRes  := {{"", "", ""}}
		aRes[1,1] := (cAlias)->D14_LOCAL
		aRes[1,2] := (cAlias)->D14_ENDER
		aRes[1,3] := "NAO"

		Dbeval({|| aRes[1,3] := "SIM"},  {||(cAlias)->DCF == "SIM"})
	EndIf

	(cAlias)->(DbCloseArea())
Return aRes