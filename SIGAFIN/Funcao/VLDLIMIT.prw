#Include "Protheus.CH"
#Include "Totvs.CH"

/*/{Protheus.doc} VLDLIMIT
	Fun��o para validar se segue com o processo de emiss�o das NF de Sa�da, validando o status do cliente para as opera��es de cr�dito.
    @type       Function
    @author     TOTVS - FSW - DWC Consult; CAOA - denis.galvani - Denis A. Galvani
    @since 		24/02/2019
    @version 	2.0
	@param 		ParamIxb	, array
	@param 		ParamIxb[1]	, character	, *cMarkSC9* - Marca uso *Markbrowse*
	@param 		ParamIxb[2]	, logical	, *lInv* - Pedido marcado *(`.T.`)* ou n�o *(`.F.`)* no *Markbrowse*
	@param 		ParamIxb[3]	, numeric	, *nRecSC5* - N�mero do registro do *Pedido de Venda* *(`SC5` - cabe�alho ou `SC6` - itens)*
    @return     lFim		, logical	, Retorno l�gico *(`.T.` / `.F.`)* para disponibilidade de *Limite de Cr�dito*
    @example
        `U_VLDLIMIT(cMarkSC9,lInv,SC6->C6_NUM)`
    @see
    @history           		, denis.galvani, v.2.0 - Inclus�o de retorno pela avalia��o de *Limite de Cr�dito* dispon�vel
    @history 	22/08/2020	, denis.galvani, Inclus�o/padroniza��o de documenta��o de cabe�alho
    /*/
User Function VLDLIMIT()
	Local cTipoCred	:= GetMv('CAOA_TPLIM')
	Local cAliSC9	:= ""
	Local cMarkSC9	:= ParamIxb[1]
	Local nRecSC5	:= ParamIxb[3]
	Local lFim		:= .T.
	Local aAreaSA1	:= SA1->(GetArea())
	Local aAreaSC5	:= SC5->(GetArea())
	Local aAreaSC9	:= SC9->(GetArea())
	Local lInv 		:= ParamIxb[2]
	Local cWhere	:= ""
	Local aMv_Par	:= {}

	PRIVATE lVldLimit  := .F.  // RETORNA SITUACAO DO CREDITO - LIBERADO (.T.) OU BLOQUEADO (.F.)

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA

	// ------ CONDI��O VIA PE = M410PVNF_PE ------- //
	// Recebe o RECNO da SC5. Valida��o pela fun��o //
	// Prepara Doc, no menu do Pedido de Venda	    //
	// -------------------------------------------- //
	If nRecSC5 > 0
		DbSelectArea("SC5")

		SC5->(DbGoTo(nRecSC5))

		// Fun��o para valida��o dos tipos de opera��o de credito no Pedido de Venda
		If FRetAli(cTipoCred,SC5->C5_NUM )

			SA1->(DbSeek(xFilial("SA1") + SC5->(C5_CLIENTE+C5_LOJACLI)))

			// Atualiza status do cliente
			U_ProtPerg(@aMv_Par,.F.,SA1->A1_COD,SA1->A1_COD,SA1->A1_LOJA,SA1->A1_LOJA)
			FWMsgRun(, {|| U_LIBFUN01(aMv_Par,.F.,.T.,SC5->C5_NUM,@lVldLimit)},'Limite de Cr�dito','Avaliando limite de cr�dito, aguarde...')

			If SA1->A1_XSTATUS != '01' .OR. !lVldLimit
				lFim := .F.

				// Fun��o de Apresenta��o do Alerta de Bloqueio
				FAlert(SC5->C5_NUM)
			EndIf
		EndIf
	Else
		// ------ CONDI��O VIA PE = M460MARK_PE ------- //
		// Recebe o cMark da SC9. Utilizado via Fun��o  //
		// Documento de Sa�da, Chamado direto do Menu.  //
		// -------------------------------------------- //

		cWhere := IIf(lInv,"C.C9_OK <> '" + cMarkSC9 + "'","C.C9_OK = '" + cMarkSC9 + "'")
		cWhere := "%" + cWhere + "%"

		cAliSC9 := GetNextAlias()

		If Select(cAliSC9) > 0
			(cAliSC9)->(DbCloseArea())
		EndIf
		BeginSql Alias cAliSC9
			SELECT
				C9_OK,
				C9_PEDIDO,
				C9_CLIENTE,
				C9_LOJA,
				C9_BLEST
			FROM %Table:SC9% C
			WHERE
					C.%NotDel%
				AND C.C9_FILIAL = %xFilial:SC9%
				AND %Exp:cWhere%
				AND C.C9_NFISCAL = ' '
			GROUP BY
				C9_OK,C9_PEDIDO,C9_CLIENTE,C9_LOJA,C9_BLEST
		EndSql
		// AND C.C9_OK = %Exp:cMarkSC9%

		(cAliSC9)->(DbGoTop())

		While !(cAliSC9)->(EOF())

			// Fun��o para valida��o dos tipos de opera��o de credito no Pedido de Venda
			If FRetAli(cTipoCred,(cAliSC9)->C9_PEDIDO )

				SA1->(DbSeek(xFilial("SA1") + (cAliSC9)->(C9_CLIENTE + C9_LOJA)))

				// atualiza status do cliente
				U_ProtPerg(@aMv_Par,.F.,SA1->A1_COD,SA1->A1_COD,SA1->A1_LOJA,SA1->A1_LOJA)
				FWMsgRun(, {|| U_LIBFUN01(aMv_Par,.F.,.T.,(cAliSC9)->C9_PEDIDO,@lVldLimit)},'Limite Cr�dito','Avaliando limite de cr�dito, aguarde...')

				If SA1->A1_XSTATUS != '01' .OR. !lVldLimit
					lFim := .F.

					//Fun��o de Apresenta��o do Alerta de Bloqueio.
					FAlert((cAliSC9)->C9_PEDIDO)
				EndIf
			EndIf

			(cAliSC9)->(DbSkip())
		EndDo

		(cAliSC9)->( DbCloseArea() )
	EndIf

	RestArea(aAreaSA1)
	RestArea(aAreaSC5)
	RestArea(aAreaSC9)
Return( lFim )

/*/{Protheus.doc} FRetAli
	Fun��o Auxiliar. Retornar se Pedido em faturamento possui itens com *Tipo de Opera��o* de Cr�dito *(`C6_XOPER`)* parametrizados.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult; CAOA - denis.galvani - Denis A. Galvani
	@since 		18/04/2019
	@version 	2.0
	@param 		cOperCrd	, character	, Lista de valores separados por ponto e v�rgula *(;)*.
	@param 		cOperCrd	, 			, *Tipo de Opera��o* - CAOA: *Tabela gen�rica* *(`SX5`)* - ***DJ - TIPO DE MOVIMENTACAO DE MATERIAL***
	@param 		cPedido		, character	, C�digo do *Pedido de Venda* *(`SC5` - cabe�alho ou `SC9` - pedido/item de libera��o)*
	@return		lVld		, logical	, *Pedido de Venda* possui *Tipo de Opera��o* eleg�vel
	@example
		`lOpCredito := FRetAli(GetMv('CAOA_TPLIM'),SC5->C5_NUM)`
		`lOpCredito := FRetAli("54;91;",(cAliSC9)->C9_PEDIDO)`
	@see 		Par�metro *(`SX6`)* - ***CAOA_TPLIM***
    @history           		, denis.galvani, Tratamento - n�o incluir valor vazio *('')* na lista de *Tipos de Opera��o*
    @history 	22/08/2020	, denis.galvani, Inclus�o/padroniza��o de documenta��o de cabe�alho
	/*/
Static Function FRetAli(cOperCrd,cPedido)
	Local cQuery	:= ""
	Local cAliPed	:= GetNextAlias()

	If Select(cAliPed) > 0
		(cAliPed)->(DbCloseArea())
	EndIf
	cQuery := "SELECT "
	cQuery += "  COUNT(*) AS ITXOPER "
	cQuery += "FROM " + RetSqlName("SC6") + " C "
	cQuery += "WHERE "
	cQuery += "      C.D_E_L_E_T_=' ' "
	cQuery += "  AND C.C6_FILIAL = '" + xFilial("SC6") + "' "
	cQuery += "  AND C.C6_NUM = '" + cPedido + "' "
	cQuery += "  AND C.C6_XOPER IN " + FormatIn( StrTran( Left(cOperCrd,Len(AllTrim(cOperCrd))-1) ,"'","") ,";") + " "
	//cQuery += "  AND C.C6_XOPER IN " + FormatIn( StrTran( cOperCrd ,"'","") ,";") + " "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliPed,.F.,.T.)

	lVld := Iif((cAliPed)->ITXOPER > 0,.T.,.F.)

	(cAliPed)->(DbCloseArea())
Return( lVld )

/*/{Protheus.doc} FAlert
	Fun��o Auxiliar. Apresentar mensagem de alerta de bloqueio por Pedido.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		18/04/2019
	@version 	1.0
	@param 		cPedido		, character	, C�digo do *Pedido de Venda* *(`SC5` - cabe�alho ou `SC9` - pedido/item de libera��o)*
	@return 	`NIL`		, Nenhum *(vazio / nulo)*
	@example	
		`FAlert(SC5->C5_NUM)`
		`FAlert((cAliSC9)->C9_PEDIDO)`
	@history 	22/08/2020	, denis.galvani, Inclus�o/padroniza��o de documenta��o de cabe�alho
/*/
Static Function FAlert(cPedido)
	Local cMen := ""

	cMen := "Pedido: " + cPedido + " - BLOQUEADO PARA FATURAMENTO !!!"
	cMen += Replicate("-",100) + CRLF
	cMen += "Pedido Bloqueado devido ao Cr�dito do Cliente. A Nota n�o ser� emitida." + CRLF
	cMen += "Consultar a �rea respons�vel."

	Aviso("Bloqueio de Faturamento",cMen,{"Ok"},2)
Return
