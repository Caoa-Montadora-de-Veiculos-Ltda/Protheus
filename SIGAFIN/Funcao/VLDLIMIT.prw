#Include "Protheus.CH"
#Include "Totvs.CH"

/*/{Protheus.doc} VLDLIMIT
	Função para validar se segue com o processo de emissão das NF de Saída, validando o status do cliente para as operações de crédito.
    @type       Function
    @author     TOTVS - FSW - DWC Consult; CAOA - denis.galvani - Denis A. Galvani
    @since 		24/02/2019
    @version 	2.0
	@param 		ParamIxb	, array
	@param 		ParamIxb[1]	, character	, *cMarkSC9* - Marca uso *Markbrowse*
	@param 		ParamIxb[2]	, logical	, *lInv* - Pedido marcado *(`.T.`)* ou não *(`.F.`)* no *Markbrowse*
	@param 		ParamIxb[3]	, numeric	, *nRecSC5* - Número do registro do *Pedido de Venda* *(`SC5` - cabeçalho ou `SC6` - itens)*
    @return     lFim		, logical	, Retorno lógico *(`.T.` / `.F.`)* para disponibilidade de *Limite de Crédito*
    @example
        `U_VLDLIMIT(cMarkSC9,lInv,SC6->C6_NUM)`
    @see
    @history           		, denis.galvani, v.2.0 - Inclusão de retorno pela avaliação de *Limite de Crédito* disponível
    @history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
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

	// ------ CONDIÇÃO VIA PE = M410PVNF_PE ------- //
	// Recebe o RECNO da SC5. Validação pela função //
	// Prepara Doc, no menu do Pedido de Venda	    //
	// -------------------------------------------- //
	If nRecSC5 > 0
		DbSelectArea("SC5")

		SC5->(DbGoTo(nRecSC5))

		// Função para validação dos tipos de operação de credito no Pedido de Venda
		If FRetAli(cTipoCred,SC5->C5_NUM )

			SA1->(DbSeek(xFilial("SA1") + SC5->(C5_CLIENTE+C5_LOJACLI)))

			// Atualiza status do cliente
			U_ProtPerg(@aMv_Par,.F.,SA1->A1_COD,SA1->A1_COD,SA1->A1_LOJA,SA1->A1_LOJA)
			FWMsgRun(, {|| U_LIBFUN01(aMv_Par,.F.,.T.,SC5->C5_NUM,@lVldLimit)},'Limite de Crédito','Avaliando limite de crédito, aguarde...')

			If SA1->A1_XSTATUS != '01' .OR. !lVldLimit
				lFim := .F.

				// Função de Apresentação do Alerta de Bloqueio
				FAlert(SC5->C5_NUM)
			EndIf
		EndIf
	Else
		// ------ CONDIÇÃO VIA PE = M460MARK_PE ------- //
		// Recebe o cMark da SC9. Utilizado via Função  //
		// Documento de Saída, Chamado direto do Menu.  //
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

			// Função para validação dos tipos de operação de credito no Pedido de Venda
			If FRetAli(cTipoCred,(cAliSC9)->C9_PEDIDO )

				SA1->(DbSeek(xFilial("SA1") + (cAliSC9)->(C9_CLIENTE + C9_LOJA)))

				// atualiza status do cliente
				U_ProtPerg(@aMv_Par,.F.,SA1->A1_COD,SA1->A1_COD,SA1->A1_LOJA,SA1->A1_LOJA)
				FWMsgRun(, {|| U_LIBFUN01(aMv_Par,.F.,.T.,(cAliSC9)->C9_PEDIDO,@lVldLimit)},'Limite Crédito','Avaliando limite de crédito, aguarde...')

				If SA1->A1_XSTATUS != '01' .OR. !lVldLimit
					lFim := .F.

					//Função de Apresentação do Alerta de Bloqueio.
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
	Função Auxiliar. Retornar se Pedido em faturamento possui itens com *Tipo de Operação* de Crédito *(`C6_XOPER`)* parametrizados.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult; CAOA - denis.galvani - Denis A. Galvani
	@since 		18/04/2019
	@version 	2.0
	@param 		cOperCrd	, character	, Lista de valores separados por ponto e vírgula *(;)*.
	@param 		cOperCrd	, 			, *Tipo de Operação* - CAOA: *Tabela genérica* *(`SX5`)* - ***DJ - TIPO DE MOVIMENTACAO DE MATERIAL***
	@param 		cPedido		, character	, Código do *Pedido de Venda* *(`SC5` - cabeçalho ou `SC9` - pedido/item de liberação)*
	@return		lVld		, logical	, *Pedido de Venda* possui *Tipo de Operação* elegível
	@example
		`lOpCredito := FRetAli(GetMv('CAOA_TPLIM'),SC5->C5_NUM)`
		`lOpCredito := FRetAli("54;91;",(cAliSC9)->C9_PEDIDO)`
	@see 		Parâmetro *(`SX6`)* - ***CAOA_TPLIM***
    @history           		, denis.galvani, Tratamento - não incluir valor vazio *('')* na lista de *Tipos de Operação*
    @history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
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
	Função Auxiliar. Apresentar mensagem de alerta de bloqueio por Pedido.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		18/04/2019
	@version 	1.0
	@param 		cPedido		, character	, Código do *Pedido de Venda* *(`SC5` - cabeçalho ou `SC9` - pedido/item de liberação)*
	@return 	`NIL`		, Nenhum *(vazio / nulo)*
	@example	
		`FAlert(SC5->C5_NUM)`
		`FAlert((cAliSC9)->C9_PEDIDO)`
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
/*/
Static Function FAlert(cPedido)
	Local cMen := ""

	cMen := "Pedido: " + cPedido + " - BLOQUEADO PARA FATURAMENTO !!!"
	cMen += Replicate("-",100) + CRLF
	cMen += "Pedido Bloqueado devido ao Crédito do Cliente. A Nota não será emitida." + CRLF
	cMen += "Consultar a área responsável."

	Aviso("Bloqueio de Faturamento",cMen,{"Ok"},2)
Return
