#INCLUDE 'Protheus.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} CLASCRED
	CAOA - Classe para Cálculo da Rotina de Crédito
	@type 		class
	@version 	2.0
	@author 	TOTVS - FSW - DWC Consult; denis.galvani - Denis A. Galvani
	@since 		26/02/2019
	@history 	04/02/2020	, denis.galvani, Novo atributo no método `LimiteVencido`
	@history 	04/02/2020	, denis.galvani, Novo método `ParamsCredito`
	@history 	16/07/2020	, denis.galvani, Atualização e padronização de toda documentação, formato <em>ProtheusDoc</em>
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
CLASS CLASCRED

	Data nValCred As Number
	Data nVlRaNCC As Number
	Data nSldTit  As Number
	Data lRetorno As Logical
	Data lTitOpen As Logical
	Data nValPed  As Number
	Data dVencLim As Date
	Data cXDesGrp As Character

	Method New() CONSTRUCTOR
	Method GravaZA2()		 // Método para efetuar a gravação das alterações dos campos da Aba Crédito no cadastro do Cliente.
	Method LimiteCredito()	 // Método para efetuar a consulta do Limite de Crédito do Cliente, por Código e Loja ou RAIZ do CNPJ.
	Method SaldoTitAberto()	 // Método para totalizar Títulos de débito em aberto para as operações de Crédito do Faturamento.
	Method SaldoTitRANCC()	 // Método para totalizar créditos. Devoluções Nota de Crédito ao Cliente (NCC), e, Recebimento Antecipado (RA).
	Method ThreadFunc()		 // Método para efetuar o controle de Threads.
	Method TitulosEmAtraso() // Método para efetuar a consulta para titulos em atraso.
	Method AlteraStatusCli() // Método para efetuar alteração do Status de Crédito no cadastro do Cliente.
	Method SaldoPedidoFat()  // Método para totalizar Pedido para faturamento.
	Method ParamsCredito()   // Método para busca de parâmetros gerais de Crédito, por Cliente (Código e Loja) ou Grupo (Raiz do CNPJ - Matriz)
	Method LimiteVencido()   // Método para consultar expiração da data de Limite de Crédito, Cliente ou Grupo (Raiz do CNPJ - Matriz)
	Method ValidarStatus()   // Método para validar conteúdo do campo "Status" na alteração do cadastro de Cliente

ENDCLASS

/*/{Protheus.doc} CLASCRED::New
	Método de Construção
	@type 		method
	@version 	1.0
	@author 	TOTVS - FSW - DWC Consult
	@since 		26/02/2019
	@return 	`NIL`, Nulo *(nenhum)*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Method New() Class CLASCRED

	::nValCred	:= 0
	::nVlRaNCC	:= 0
	::nSldTit	:= 0
	::lRetorno	:= .F.
	::lTitOpen	:= .F.
	::nValPed	:= 0
	::dVencLim  := CtoD("//")
	::cXDesGrp  := " "

Return

/*/{Protheus.doc} CLASCRED::GravaZA2
	Gravar log de alterações na aba Crédito no Cadastro do Cliente
	@type 		method
	@version 	1.0
	@author 	TOTVS - FSW - DWC Consult
	@since 		08/04/2019
	@param 		cCliente	, character, Código de Cliente [A1_COD]
	@param 		cLoja	, character, Loja de Cliente [A1_LOJA]
	@param 		cLogZA2	, character, Mensagem para log de dados alterados
	@param 		cUsrZA2	, character, Usuário responsável pela alteração
	@return 	`NIL`, Nulo *(nenhum)*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Method GravaZA2(cCliente,cLoja,cLogZA2,cUsrZA2) Class CLASCRED
	DEFAULT cUsrZA2 := cUserName

	RecLock("ZA2",.T.)
	ZA2->ZA2_FILIAL	:= xFilial("ZA2")
	ZA2->ZA2_CLIENT	:= cCliente
	ZA2->ZA2_LOJA	:= cLoja
	ZA2->ZA2_DATA	:= Date()
	ZA2->ZA2_HORA	:= Time()
	ZA2->ZA2_RESPON	:= cUsrZA2
	ZA2->ZA2_SOLICI	:= ""
	ZA2->ZA2_OBSERV	:= cLogZA2
	ZA2->(MsUnLock())

Return

/*/{Protheus.doc} CLASCRED::LimiteCredito
	CAOA - Método para consultar Limite de Crédito para Cliente definido (Código e Loja) ou Grupo econômico (Raiz CNPJ - Matriz).
	@type 		method
	@version 	2.0
	@author 	TOTVS - FSW - DWC Consult; denis.galvani - Denis A. Galvani
	@since 		15/04/2019
	@param 		lCliLoj		, logical	, Consultar por Raiz CNPJ ou Cliente específico (Código e Loja)
	@param 		cRaizCNPJ	, character	, Raiz CNPJ do Grupo econômico - oito primeiros caracteres - campo `A1_CGC`
	@param 		cCliente	, character	, Código de Cliente - campo `A1_COD`
	@param 		cLoja		, character	, Loja de Cliente - campo `A1_LOJA`
	@return 	numeric		, `SELF:nValCred` - Valor de Limite de Crédito
	@history 	15/04/2019	, denis.galvani, Correção na consulta. Busca pelo LC do Cliente ou Grupo indicado e data não expirada
	@history 	16/07/2020	, denis.galvani, Consulta - Incluída Filial na condição e Índice respectivo na pesquisa por Cliente (Índice 1 - Cliente+Loja) ou Grupo (Índice 3 - CNPJ Raiz).
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	@history 	26/08/2020	, denis.galvani, Ajustes no recebimento de parâmetros, ordem
	/*/
Method LimiteCredito(lCliLoj,cRaizCNPJ,cCliente,cLoja) Class CLASCRED
	Local cAliCrd	 := GetNextAlias()
	Local cQuery	 := ""
	LOCAL nIndexSA1  := 1 // A1_FILIAL+A1_COD+A1_LOJA

	DEFAULT lCliLoj  := .F.

	If .NOT. lCliLoj
		nIndexSA1 := 3 // A1_FILIAL+A1_CGC
		cRaizCNPJ := PadR(cRaizCNPJ,08)
	EndIf

	// Select para o Limite de Credito
	If Select(cAliCrd) > 0
		(cAliCrd)->(DbCloseArea())
	EndIf

	cQuery := "SELECT "
	cQuery += "  SUM(A1_LC) AS LIMCRED "
	cQuery += "FROM " + RetSqlName("SA1") + " A "
	cQuery += "WHERE "
	cQuery += "  A.D_E_L_E_T_ = ' ' "
	cQuery += "  AND A.A1_FILIAL = '" + XFilial("SA1") + "' "
	
	If lCliLoj
		cQuery += "  AND A.A1_COD = '" + cCliente + "' "
		cQuery += "  AND A.A1_LOJA = '" +cLoja + "' "
	Else
		cQuery += "  AND SUBSTRING(A.A1_CGC,1,8) = '" + cRaizCNPJ + "' "
		cQuery += "  AND A.A1_XDESGRP <> '1' " //+ = '2' " // 1=Sim;2=Nao
		cQuery += "  AND ROWNUM = 1 "
	EndIf
	
	cQuery += "  AND (A.A1_VENCLC >= '" + DToS(dDataBase) +"' OR A.A1_VENCLC = ' ') "
	// RETORNAR PRIMEIRO CADASTRO DE CLIENTE, MENOR CÓDIGO NA ORDENAÇÃO
	cQuery += "ORDER BY" + SqlOrder(SA1->(IndexKey(nIndexSA1)))
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliCrd,.F.,.T.)

	::nValCred := (cAliCrd)->LIMCRED

	(cAliCrd)->(DbCloseArea())
Return( ::nValCred )

/*/{Protheus.doc} CLASCRED::SaldoTitAberto
	Totaliza Títulos em aberto.
	Filtra por Pedidos de Venda com "Tipo Operação" (`C6_XOPER`) de crédito indicados - parâmetro *cTipoCred*.
	@type 		method
	@version 	2.0
	@author 	TOTVS - FSW - DWC Consult; denis.galvani - Denis A. Galvani
	@since 		09/03/2019
	@param 		cTipoCred	, character	, Lista de valores separados por ponto e vírgula (;)
	@param 		lCliLoj		, logical	, Consultar por Raiz CNPJ ou Cliente específico (Código e Loja)
	@param 		cRaizCNPJ	, character	, Raiz CNPJ do Grupo econômico - oito primeiros caracteres - campo `A1_CGC`
	@param 		cCliente	, character	, Código de Cliente [A1_COD]
	@param 		cLoja		, character	, Loja de Cliente - campo `A1_LOJA`
	@return 	`NIL`, Nulo *(nenhum)*
	@see 		Parâmetro *SX6* `CAOA_TPLIM`
	@history 	09/03/2019	, denis.galvani, Consulta - Tratamento do campo "Desconsidera Grupo" _(1 - Sim; 2 - Não; Vazio - Não)_
	@history 	16/07/2020	, denis.galvani, Consulta - Correção - Totalização não resomar valor do Título do PV a cada item com "Tp.Oper."
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	@history 	26/08/2020	, denis.galvani, Ajustes no recebimento de parâmetros, ordem
	/*/
Method SaldoTitAberto(cTipoCred,lCliLoj,cRaizCNPJ,cCliente,cLoja) Class CLASCRED
	Local cAliSE1	:= ""
	Local cQuery	:= ""

	DEFAULT cTipoCred  := Space( GetSx3Cache("C6_XOPER","X3_TAMANHO") )

	// Efetua o Cálculo somente quando for passado Tipos de Operação via parâmetro
	If !Empty(cTipoCred)

		cAliSE1 := GetNextAlias()

		If Select(cAliSE1) > 0
			(cAliSE1)->(DbCloseArea())
		EndIf

		cQuery += "SELECT SUM(E.E1_SALDO) AS SALDO "
		cQuery += "FROM " + RetSqlName("SE1") + " E "
		cQuery += "INNER JOIN " + RetSqlName("SA1") + " A ON A.D_E_L_E_T_ = ' ' "
		cQuery += "  AND A.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery += "  AND A.A1_COD = E.E1_CLIENTE "
		cQuery += "  AND A.A1_LOJA = E.E1_LOJA "
		If lCliLoj // CAD. CLIENTE - DESCONSIDERA GRUPO DE EMPRESAS - APENAS REGISTRO DE CLIENTE INDICADO (CLIENTE+LOJA)
			cQuery += "  AND A.A1_XDESGRP = '1' /* 1 - SIM == DESCONSIDERA GRUPO DE EMPRESA */ " // A1_XDESGRP == 1 - DESCONSIDERA GRUPO DE EMPRESAS
		Else
			cQuery += "  AND SUBSTR(A.A1_CGC,1,8) = '" + cRaizCNPJ + "' /* RAIZ CNPJ - GRUPO DE EMPRESA */ "
			cQuery += "  AND A.A1_XDESGRP <> '1' /* 2 - NAO == CONSIDERA GRUPO DE EMPRESA */ " // A1_XDESGRP == NAO PREENCHIDO OU 2 - NAO (CONSIDERA GRUPO)
		EndIf
		cQuery += "WHERE E.D_E_L_E_T_ = ' ' "
		cQuery += "  AND E.E1_FILIAL = '" + xFilial("SE1") + "' "
		If lCliLoj // APENAS TITULOS DO CLIENTE, DESCONSIDERA GRUPO DE EMPRESAS
			cQuery += "  AND E.E1_CLIENTE = '" + cCliente + "' "
			cQuery += "  AND E.E1_LOJA = '" + cLoja + "' "
		EndIf
		cQuery += "  AND E.E1_PEDIDO IN ( "
		cQuery += "    SELECT "
		cQuery += "           C.C6_NUM "
		cQuery += "    FROM " + RetSqlName("SC6") + " C "
		cQuery += "    WHERE C.D_E_L_E_T_ = ' ' "
		cQuery += "      AND C.C6_FILIAL = '" + xFilial("SC6") + "' "
		cQuery += "      AND C.C6_NUM = E.E1_PEDIDO "
		cQuery += "      AND C.C6_XOPER IN " + FormatIn( cTipoCred ,";") + " " // Tip Oper IN ('54','91') - PARAM. CAOA_TPLIM
		cQuery += "    GROUP BY "
		cQuery += "             C.C6_NUM "
		cQuery += "  ) "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliSE1,.F.,.T.)

		::nSldTit += (cAliSE1)->SALDO

		(cAliSE1)->(DbCloseArea())
	Else
		::nSldTit := 0
	EndIf
Return( ::nSldTit )

/*/{Protheus.doc} CLASCRED::SaldoTitRANCC
	CAOA - Calcular saldo em Títulos de Crédito (tipo *RA*) e Devolução (Tipo *NCC*) para o Cliente/Loja ou Grupo econômico
	@type 		method
	@version 	2.0
	@author 	TOTVS - FSW - DWC Consult; denis.galvani - Denis A. Galvani
	@since 		26/02/2019
	@param 		cRaizCNPJ	, character	, Raiz CNPJ do Grupo econômico - oito primeiros caracteres - campo `A1_CGC`
	@param 		lCliLoj		, logical	, Consultar por Raiz CNPJ ou Cliente específico (Código e Loja)
	@param 		cCliente	, character	, Código de Cliente - campo `A1_COD`
	@param 		cLoja		, character	, Loja de Cliente - campo `A1_LOJA`
	@return 	numeric		, Saldo total em Títulos *RA* e *NCC*
	@history 	09/03/2019	, denis.galvani, Consulta - Tratamento do campo "Desconsidera Grupo" (1 - Sim; 2 - Não; Vazio - Não)
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Method SaldoTitRANCC(cRaizCNPJ,lCliLoj,cCliente,cLoja) Class CLASCRED
	Local cAliRA	:= GetNextAlias()
	Local cQuery	:= ""

	If Select(cAliRA) > 0
		(cAliRA)->(DbCloseArea())
	EndIf
	cQuery := "SELECT "
	cQuery += "  SUM(E.E1_SALDO) AS VALOR "
	cQuery += "FROM " + RetSqlName("SE1") + " E "
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " J ON J.D_E_L_E_T_ = ' ' AND J.A1_COD = E.E1_CLIENTE AND J.A1_LOJA = E.E1_LOJA "
	cQuery += "WHERE "
	cQuery += "  E.D_E_L_E_T_=' ' "
	cQuery += "  AND E.E1_TIPO IN ('RA','NCC') "
	cQuery += "  AND E.E1_SALDO > 0 "
	If !lCliLoj
		cQuery += "  AND SUBSTRING(J.A1_CGC,1,8) = '" + cRaizCNPJ + "' "
		cQuery += "  AND J.A1_XDESGRP <> '1' " //= '2' " // 1=Sim;2=Nao
	Else
		cQuery += "  AND J.A1_COD = '" + cCliente + "' "
		cQuery += "  AND J.A1_LOJA = '" + cLoja + "' "
	EndIf
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliRA,.F.,.T.)

	While !(cAliRA)->(EOF())

		::nVlRaNCC += (cAliRA)->VALOR

		(cAliRA)->(DbSkip())
	EndDo

	(cAliRA)->(DbCloseArea())
Return( ::nVlRaNCC )

/*/{Protheus.doc} CLASCRED::ThreadFunc
	Método para controle do máximo de Threads
	@type 		method
	@version 	1.0
	@author 	TOTVS - FSW - DWC Consult
	@since 		03/04/2019
	@param 		nQtdThr	, numeric	, Quantidade máxima de threads para execução da rotina
	@param 		cRotina	, character	, Nome da função (rotina) para limitação
	@return 	logical, `SELF:lRetorno` - Número de treads menor ou igual máximo indicado
	@see		Parâmetro <em>(SX6)</em> `CAOA_MXTHR`
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Method ThreadFunc(nQtdThr,cRotina) Class CLASCRED
	Local cEnvSrv	:= GetEnvServer()
	Local cCpName	:= GetComputerName()
	Local nThreads	:= 0
	Local nMaxThre	:= nQtdThr
	Local aThrArray	:= GetUserInfoArray()

	aEval( aThrArray,{|aThread| IIF(aThread[2] == cCpName .And. AllTrim(cRotina) $ AllTrim(aThread[5]) .And. aThread[6] == cEnvSrv , ++nThreads , Nil)} )

	::lRetorno := Iif(nThreads <= nMaxThre,.T.,.F.)

Return( ::lRetorno )

/*/{Protheus.doc} CLASCRED::TitulosEmAtraso
	Consultar Títulos a Receber em atraso do Cliente ou Grupo econômico (mesma Raiz CNPJ).
	Títulos a Receber de Pedidos de Venda com "Tipo Operação" (`C6_XOPER`) de crédito indicados - parâmetro <em>cOperC6</em>.
	@type 		method
	@version 	2.0
	@author 	TOTVS - FSW - DWC Consult; denis.galvani - Denis A. Galvani
	@since 		03/04/2019
	@param 		lCliLoj		, logical	, Consultar por Raiz CNPJ ou Cliente específico (Código e Loja)
	@param 		cCodCli		, character	, Código de Cliente - campos `A1_COD` e `E1_COD` relacionados
	@param 		cLojCli		, character	, Loja de Cliente - campos `A1_LOJA` e `E1_LOJA` relacionados
	@param 		cRaizCNPJ	, character	, Raiz CNPJ do Grupo econômico - oito primeiros caracteres - campo `A1_CGC`
	@param 		dDtAtraso	, date		, Data Vencimento Real do Título a Receber - campo `E1_VENCREA`
	@param 		cOperC6		, character	, "Tipo Operação" do item no Pedido de Venda (`C6_XOPER`) - Lista de valores separados por ponto e vírgula (;)
	@return 	logical		, `SELF:lTitOpen` - Existem Títulos a Receber em Aberto
	@see 		Parâmetro <em>(SX6)</em> `CAOA_TPLIM`
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Method TitulosEmAtraso(lCliLoj,cCodCli,cLojCli,cRaizCNPJ,dDtAtraso,cOperC6) Class CLASCRED
	Local cAliSE1	:= GetNextAlias()
	Local cQuery	:= ""
	LOCAL nQtdTit   := 0

	If Select(cAliSE1) > 0
		(cAliSE1)->(DbCloseArea())
	EndIf
	cQuery := "SELECT "
	cQuery += "  E.E1_FILIAL,E.E1_PREFIXO,E.E1_NUM,E.E1_PARCELA,E.E1_TIPO,E.E1_PEDIDO "
	cQuery += "FROM " + RetSqlName("SE1") + " E "
	cQuery += "INNER JOIN "+ RetSqlName("SC6") + " C ON C.D_E_L_E_T_=' ' "
	cQuery += "								   AND C.C6_FILIAL = E.E1_FILIAL "
	cQuery += "								   AND C.C6_NUM = E.E1_PEDIDO "
	cQuery += "								   AND C.C6_CLI = E.E1_CLIENTE "
	cQuery += "								   AND C.C6_LOJA = E.E1_LOJA "
	cQuery += "  							   AND C.C6_XOPER IN "
	cQuery += FormatIn( StrTran( Left(cOperC6,Len(AllTrim(cOperC6))-1) ,"'","") ,";")
	cQuery += " "
	cQuery += "INNER JOIN "+ RetSqlName("SA1") + " A ON A.D_E_L_E_T_=' ' "
	cQuery += "								   AND A.A1_COD = E.E1_CLIENTE "
	cQuery += "								   AND A.A1_LOJA = E.E1_LOJA "
	cQuery += "WHERE "
	cQuery += "  E.D_E_L_E_T_=' ' "
	cQuery += "  AND E.E1_SALDO > 0 "
	If lCliLoj
		cQuery += "  AND A.A1_COD = '" + cCodCli + "' "
		cQuery += "  AND A.A1_LOJA = '" + cLojCli + "' "
	Else
		cQuery += "  AND SUBSTRING(A.A1_CGC,1,8) = '" + cRaizCNPJ + "' "
		cQuery += "  AND A.A1_XDESGRP <> '1' " //= '2' " // 1=Sim;2=Nao
	EndIf
	cQuery += "  AND E.E1_VENCREA < '" + DToS( dDtAtraso ) + "' "
	cQuery += "GROUP BY " + CRLF
	cQuery += "  E.E1_FILIAL,E.E1_PREFIXO,E.E1_NUM,E.E1_PARCELA,E.E1_TIPO,E.E1_PEDIDO "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliSE1,.F.,.T.)

	nQtdTit := (cAliSE1)->( RecCount() )

	::lTitOpen := Iif(nQtdTit == 0,.F.,.T.)

	(cAliSE1)->(DbCloseArea())
Return( ::lTitOpen )

/*/{Protheus.doc} CLASCRED::AlteraStatusCli
	Método para atualizar campo "Status" de crédito (`A1_XSTATUS`) no Cadastro de Cliente.
	@type 		method
	@version 	1.0
	@author 	TOTVS - FSW - DWC Consult
	@since 		05/04/2019
	@param 		cWhere		, character	, Condição `WHERE` para atualização - Cliente/Loja ou Raiz CNPJ
	@param 		cNewStat	, character	, Novo valor de "Status" - campo `A1_XSTATUS`
	@param 		cUsrLog		, character	, Usuário responsável pela mudança - para registro de log pelo método <em>CLASCRED:GravaZA2()</em> por ocorrência
	@return 	`NIL`		, Nulo *(nenhum)*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Method AlteraStatusCli(cWhere,cNewStat,cUsrLog) Class CLASCRED
	Local cAliSA1	:= GetNextAlias()
	Local cQuery	:= ""
	Local cStaOld	:= ""
	Local cMenLog	:= ""
	Local cTabSX5	:= "ZA"
	Local nRegSA1	:= 0
	Local oGrvZA2	:= Nil
	Local aAreaSA1	:= SA1->(GetArea())
	Local aAreaSX5	:= SX5->(GetArea())
	Local aSX5		:= {}

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

	If Select(cAliSA1) > 0
		(cAliSA1)->(DbCloseArea())
	EndIf
	cQuery := "SELECT "
	cQuery += "  A1_COD, "
	cQuery += "  A1_LOJA "
	cQuery += "FROM " + RetSqlName("SA1") + " A "
	cQuery += "WHERE "
	cQuery += "  A.D_E_L_E_T_=' ' "
	cQuery += "  AND A.A1_MSBLQL ='2' "
	cQuery += cWhere
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliSA1,.F.,.T.)
	Count To nRegSA1

	If nRegSA1 > 0
		(cAliSA1)->(DbGoTop())

		While !(cAliSA1)->(EOF())

			If SA1->(DbSeek(xFilial("SA1") + (cAliSA1)->(A1_COD+A1_LOJA) ))

				// Atualiza somente "Status" quando diferente na SA1
				If SA1->A1_XSTATUS == cNewStat
					(cAliSA1)->(DbSkip())
					Loop
				EndIf

				cStaOld := SA1->A1_XSTATUS

				If SX5->(DbSeek(xFilial("SX5") + cTabSX5 + cStaOld))
					aSX5 := FWGetSX5(cTabSX5, cStaOld)
					cMenLog := "CAMPO: Status, ALTERADO DE: " + cStaOld + " - " + AllTrim(aSX5[1][4]) + " PARA: "
				EndIf

				If SX5->(DbSeek(xFilial("SX5") + cTabSX5 + cNewStat))
					aSX5 := FWGetSX5(cTabSX5, cNewStat)
					cMenLog += cNewStat + " - " + AllTrim(aSX5[1][4]) + " - STATUS ALTERADO VIA ROTINA DE CREDITO"
				EndIf

				RecLock("SA1",.F.)
				SA1->A1_XSTATUS := cNewStat
				SA1->(MsUnLock())

				oGrvZA2 := CLASCRED():New()
				oGrvZA2:GravaZA2( SA1->A1_COD,SA1->A1_LOJA,cMenLog,cUsrLog )
			EndIf

			(cAliSA1)->(DbSkip())
		EndDo
	EndIf
	(cAliSA1)->(DbCloseArea())

	RestArea(aAreaSA1)
	RestArea(aAreaSX5)
Return


/*/{Protheus.doc} CLASCRED::SaldoPedidoFat
	Método para calcular total dos itens no Pedido de Venda em faturamento conforme "Tipo Operação" de crédito.
	@type 		method
	@version 	1.0
	@author 	TOTVS - FSW - DWC Consult
	@since 		05/04/2019
	@param 		cTipoCred	, character	, "Tipo Operação" do item no Pedido de Venda (`C6_XOPER`) - Listagem separada por ponto e vírgula (;)
	@param 		cPedido		, character	, Código do Pedido de Venda - campos `C5_NUM` e `C6_NUM` relacionados
	@return 	numeric		, `SELF:nValPed` - Valor total dos itens no Pedido de Venda com "Tipo Operação" indicados
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Method SaldoPedidoFat(cTipoCred,cPedido) Class CLASCRED
	Local cAliSC6	:= ""
	Local cQuery	:= ""

	// Calcular valor do Pedido para listagem de "Tipo Operação" indicada - cTipoCred
	If !Empty(cTipoCred)

		cAliSC6 := GetNextAlias()

		If Select(cAliSC6) > 0
			(cAliSC6)->(DbCloseArea())
		EndIf
		cQuery := "SELECT SUM(C.C6_VALOR) C6_VALOR "
		cQuery += "FROM " + RetSqlName("SC6") + " C "
		cQuery += "WHERE "
		cQuery += "  C.D_E_L_E_T_= ' ' "
		cQuery += "  AND C.C6_FILIAL = '" + xFilial("SC6") + "' "
		cQuery += "  AND C.C6_NUM = '" + cPedido + "' "
		cQuery += "  AND C.C6_XOPER IN " + FormatIn( StrTran( Left(cTipoCred,Len(AllTrim(cTipoCred))-1) ,"'","") ,";") + " "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliSC6,.F.,.T.)

		While !(cAliSC6)->(EOF())

			::nValPed += (cAliSC6)->C6_VALOR

			(cAliSC6)->(DbSkip())
		EndDo

		(cAliSC6)->(DbCloseArea())
	Else
		::nValPed := 0
	EndIf
Return( ::nValPed )


/*/{Protheus.doc} CLASCRED::ParamsCredito
	Carregar parâmetros de Crédito do cadastro de Cliente/Loja ou Grupo econômico
	@type 		method
	@version 	2.0
	@author 	CAOA - denis.galvani - Denis A. Galvani
	@since 		04/02/2020
	@param 		cCodCli		, character	, Código do Cliente - campo `A1_COD`
	@param 		cLojCli		, character	, Loja do Cliente - campo `A1_LOJA`
	@return 	array		, `aDados` - Vetor de dados do Cliente/Loja atual ou primeiro do Grupo econômico.
	@return 				, `aDados` - Itens do vetor: <ol> <li>A1_COD</li> <li>A1_LOJA</li> <li>A1_CGC</li> <li>A1_LC</li> <li>A1_VENCLC</li> <li>A1_XDESGRP</li> </ol>
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Method ParamsCredito(cCodCli,cLojCli) Class CLASCRED
	Local aFields     := {"A1_COD","A1_LOJA","A1_CGC","A1_LC","A1_VENCLC","A1_XDESGRP"}
	Local aDados      := {}
	Local cQryGrpA1   := ""
	Local _cAliSA1    := GetNextAlias()
	Local cRaizCNPJ	  := Space(TamSX3("A1_CGC")[1])

	DEFAULT cCodCli   := Space(TamSX3("A1_COD")[1])
	DEFAULT cLojCli   := Space(TamSX3("A1_LOJA")[1])
	DEFAULT lVencLim  := .F.

	If !Empty(cCodCli) .AND. !Empty(cLojCli)
		aDados := GetAdvFval("SA1",aFields,xFilial("SA1")+cCodCli+cLojCli,1)
		// CADASTRO ENCONTRADO - CODIGO [A1_COD] NAO PODE SER VAZIO
		If !Empty(aDados[01])
			If aDados[06] != "1" // NAO DESCONSIDERA GRUPO - "2" OU VAZIO
				If Select(_cAliSA1) > 0
					(_cAliSA1)->(DbCloseArea())
				EndIf

				cRaizCNPJ := SubStr(aDados[03],1,8)
				// CONSULTA PRIMEIRO CLIENTE DO GRUPO ECONÔMICO
				cQryGrpA1 := "SELECT "
				cQryGrpA1 += "  A1_FILIAL, A1_COD, A1_LOJA "
				cQryGrpA1 += "FROM " + RetSqlName("SA1") + Space(1)
				cQryGrpA1 += "WHERE "
				cQryGrpA1 += "  D_E_L_E_T_ = ' ' "
				cQryGrpA1 += "  AND SUBSTRING(A1_CGC,1,8) = '" + cRaizCNPJ + "'"
				cQryGrpA1 += "  AND A1_XDESGRP <> '1' "
				cQryGrpA1 += "ORDER BY " + SqlOrder(SA1->(IndexKey(1))) // INDEX 1 // A1_FILIAL+A1_COD+A1_LOJA

				cQryGrpA1 := ChangeQuery(cQryGrpA1)
				DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryGrpA1),_cAliSA1,.F.,.T.)

				// OBTER DADOS DO CLIENTE PRIMARIO DO GRUPO ECONÔMICO
				aDados := GetAdvFval("SA1",aFields,(_cAliSA1)->(A1_FILIAL+A1_COD+A1_LOJA),1)

				// FECHAR CONSULTA REALIZADA
				If Select(_cAliSA1) > 0
					(_cAliSA1)->(DbCloseArea())
				EndIf
			EndIf
			::nValCred := aDados[04]
			::dVencLim := aDados[05]
			::cXDesGrp := aDados[06] // "1" - Sim; "2" - Não
		EndIf
	EndIf

Return aDados


/*/{Protheus.doc} CLASCRED::LimiteVencido
	Retorna se data de Limite de Crédito para Cliente indicado (Código e Loja) está expirada. Dado vazio no cadastro retorna parâmetro <em>dDtProces</em>
	@type 		method
	@version 	1.0
	@author 	CAOA - denis.galvani - Denis A. Galvani
	@since 		04/02/2020
	@param 		cCodCli		, character	, Código do Cliente - `A1_COD`
	@param 		cLojCli		, character	, Loja do Cliente - `A1_LOJA`
	@param 		dDtProces	, date		, Data atual de processamento para validação do Limite de Crédito
	@return 	logical		, Data de Limite de Crédito expirado - `A1_VENCLIM` <strong>maior</strong> que <em>database</em>
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Method LimiteVencido(cCodCli,cLojCli,dDtProces) Class CLASCRED
	Local aFields     := {"A1_COD","A1_LOJA","A1_CGC","A1_LC","A1_VENCLC","A1_XDESGRP"}
	Local aDados      := Array(Len(aFields))
	LOCAL nPosVencLC  := AScan(aFields,{|cField|cField=="A1_VENCLC"})
	LOCAL dVencLC     := CtoD("//")

	DEFAULT cCodCli   := Space(TamSX3("A1_COD")[1])
	DEFAULT cLojCli   := Space(TamSX3("A1_LOJA")[1])
	DEFAULT dDtProces := dDataBase
	DEFAULT lVencLim  := .F.

	// PARAMETROS CLIENTE [A1_COD] E LOJA [A1_LOJA] INFORMADOS BUSCA E ATUALIZA OBJETO DA CLASSE
	If !Empty(cCodCli) .AND. !Empty(cLojCli)
		// aDados := GetAdvFval("SA1",aFields,xFilial("SA1")+cCodCli+cLojCli,1)
		aDados := Self:ParamsCredito(cCodCli,cLojCli)
	EndIf

	// DATA DE EXPIRACAO DO LIMITE DE CREDITO DO CLIENTE/GRUPO (CLIENTE PRIMARIO)
	dVencLC    := aDados[nPosVencLC]
	// DATA VAZIA NO CADASTRO UTILIZAR PARAMETRO DE DATA DE PROCESSAMENTO/DATABASE
	dVencLC    := Iif(Empty(dVencLC),dDtProces,dVencLC)
	// DATA DE EXPIRACAO NA SEXTA AJUSTA PARA SEGUNDA
	// dVencLC    += Iif(DoW(dVencLC)==6,3,0)
	// VALIDA DATA SENAO MOVE PARA PROXIMO DIA UTIL
	// dVencLC    := DataValida(dVencLC,.T.) // POSTERGA PARA PROXIMO DIA UTIL

	// VALIDA DATA DE LIMITE DE CREDITO
	lVencLim := Iif((dVencLC < dDtProces),.T.,.F.)

Return lVencLim


/*/{Protheus.doc} ValidarStatus
	Cadastro de Cliente, campo "Status" - Valida conteúdo e usuário atual
	@type 		method
	@author 	CAOA - denis.galvani - Denis A. Galvani
	@since 		10/08/2020
	@version 	2.0
	@param 		cA1XStatus	, character	, Conteúdo do campo para validação [`A1_XSTATUS`]
	@return 	lValido		, logical	, Conteúdo válido para campo "Status" [`A1_XSTATUS`]
	@obs 		Campo, Permitido valor vazio ou cadastrados - tabela `SZB`
	@see 		Parâmetros *(`SX6`)*: 
				- `CAOA_STUSR` - Lista Usuários (IDs) permitidos para qualquer valor existente
				- `CAOA_STALM` - Tipo de Status que são avaliados na rotina de Limite de Crédito CAOA - Utilizado somente via JOB
	@history 	          	, denis.galvani, Permite usuário parametrizado selecionar qualquer valor para campo *"Status"*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Method ValidarStatus(cA1XStatus) Class CLASCRED
	LOCAL lValido    := .F.
	// ID PARA USÁRIOS NÃO RESTRITOS - alinne.fideles;ana.caldas;juliana.pardini;denis.galvani
	LOCAL cUsrSenior := GetMV("CAOA_STUSR",NIL,"000034;000154;000157;000126" )
	LOCAL lUsrSenior := Iif( RetCodUsr() $ cUsrSenior ,.T.,.F.) // USUÁRIO PERMITIDO SELECIONAR QUALQUER VALOR
	// VALORES RESTRITOS - JOB - Rotina para Cálculo de Crédito dp Cliente / Grupo Econômico
	LOCAL cMvJobStat := GetMV("CAOA_STALM",NIL,"01;02") // 01 - LIB. AUTOM. ; 02 - BLOQ. AUTOM.

	DEFAULT cA1XStatus := M->A1_XSTATUS

	/* VALIDAÇÃO DE CAMPO (PROJETO INICIAL) */
	/* // X3_VLDUSER -> 128 CARACTERES */
	/* IIF(M->A1_XSTATUS $ '01\02',.F.,.T.) .AND. (Vazio() .or. EXISTCPO("SZB",M->A1_XSTATUS)) */
	
	/* PRINCIPAIS VALORES VALIDOS PARA CAMPO A1_XSTATUS - Vazio OU Cadastrado tabela SZB */
	If Empty(cA1XStatus) .OR. EXISTCPO("SZB", cA1XStatus)
		
		lValido := .T.
		
		/* VALORES NAO PERMITIDOS - USO PELO JOB */
		If (cA1XStatus $ cMvJobStat)
		
			/* USUÁRIOS NÃO RESTRITOS - PERMITIDO UTILIZAR VALORES DE JOB */
			lValido := lUsrSenior
		
		EndIf
	
	EndIf

Return lValido
