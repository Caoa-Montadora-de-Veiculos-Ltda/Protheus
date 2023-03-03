#Include "Protheus.CH"
#Include "TOTVS.CH"
#Include "TBIConn.CH"

/*/{Protheus.doc} CLIIOUT
	Função Auxiliar, utilizada no cálculo do Crédito por Có digo e Loja, via Thread.
	Efetua a Análise de Crédito pelo Código e Loja do Cliente, individual, fora de Grupo de Cliente.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult; denis.galvani - Denis A. Galvani
	@since 		05/04/2019
	@version 	2.0
	@param 		aParam		, array		, Parâmetros de execução: 
							,			, - 1 - Grupo de Empresa; 
							,			, - 2 - Filial; 
							,			, - 3 - Código do Cliente (`A1_COD`);
							,			, - 4 - Loja do Cliente (`A1_LOJA`);
							,			, - 5 - Bloqueia por Título vencido *(1 - Sim; 2 - Não)*;
							,			, - 6 - Vetor de parãmetro *(Pergunte)*:
							,			, - 6.1 - Código Cliente inicial *(`A1_COD`)*;
							,			, - 6.2 - Loja inicial *(`A1_LOJA`)*;
							,			, - 6.3 - Código Cliente final *(`A1_COD`)*;
							,			, - 6.4 - Loja final *(`A1_LOJA`)*;
							,			, - 6.5 - Status *(`A1_XSTATUS`)*;
							,			, - 6.6 - Lista de Tipos de Operação *(`C6_XOPER`)* separada por ponto e vírgula (;);
							,			, - 6.7 - Número de dias em atraso para considerar campo de cadastro Bloqueia Vencido *(`A1_XBLQVEN`)*;
							,			, - 6.8 - Data do Processamento, *Data base*;
							,			, - 7. - Código de usuário *(UserId)* para registro log de mudanças;
							,			, - 8. - Código do Pedido de Venda *(`C5_NUM`, `C6_NUM`)* para por Liberação de Crédito
	@param 		lUpdSA1		, logical	, Realizar atualização de "Status" *(campo `A1_XSTATUS`)* do cadastro de Cliente `SA1`
	@param 		lValid		, logical	, Controle - Crédito válido, liberar Crédito existente - passagem por referência
	@return 	logical		, Retorna situação geral final do Crédito - LIBERADO (`.T.`) ou BLOQUEADO (`.F.`)
	@history 	22/10/2019	, denis.galvani, Correção - Total de a receber do Cliente/Loja e respectivo Limite de Crédito.
	@history 	14/08/2020	, denis.galvani, Correção - Atualizar cadastro de Cliente.
	@history 	14/08/2020	, denis.galvani, Correção - Cálculo de Saldo de *Limite de Crédito*.
	@history 	          	,              , > Não debitar do saldo *Títulos* de natureza *de crédito* ou por *antecipação*, Tipos *NCC* e *RA* respectivamente.
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	@history 	26/08/2020	, denis.galvani, Ajustes na passagem de parâmetros (ordem) aos métodos da classe
	@obs 		TODO feature 26/08/2020	, denis.galvani, Atualização automática de *"Status"* de Cliente quando saldo igual a zero (somente) - campo `A1_XSTATUS`
	/*/
User Function CLIIOUT(aParam,lUpdSA1,lValid)
	Local cEmpShd	 := aParam[1]
	Local cFilShd	 := aParam[2]
	Local cCodiCli	 := aParam[3]
	Local cLojaCli	 := aParam[4]
	Local cBloqTit	 := aParam[5]
	Local aMv_Par	 := aParam[6]
	Local cUsrLog	 := aParam[7]
	Local cPedido 	 := aParam[8]

	Local cWhere	 := ""
	Local cStaLib	 := ""
	Local cStaBlq	 := ""
	Local nPendente	 := 0
	Local nLImCred	 := 0
	// Local nVlRANCC	 := 0
	Local lTitVenc	 := .F.
	Local lCliLoja	 := .T.
	Local dDtProces	 := Iif( Empty(aMv_Par[08]), dDataBase, aMv_Par[08] )
	Local dDtAtraso	 := Nil
	Local oClassLm	 := Nil
	Local nRequerido := 0
	Local lLimExpir	 := .F.
	Local nSaldoNovo := 0

	DEFAULT lUpdSA1    := .T. // ATUALIZA STATUS DO CLIENTE AO EXECUTAR ROTINA VIA JOB, E MENU DE USUÁRIO
	DEFAULT lValid     := .F. // RETORNA SITUACAO DO CREDITO - LIBERADO (.T.) OU BLOQUEADO (.F.)

	If IsBlind()
		RpcClearEnv()
		RpcSetType(3)
		Prepare Environment Empresa cEmpShd Filial cFilShd Modulo "FIN"
	Endif

	cStaLib	:= SuperGetMv("CAOA_STLIB",,"01")
	cStaBlq	:= SuperGetMv("CAOA_STBLQ",,"02")

	// Monta o Where, para as atualizações que deverão ser efetuadas no cadastro de cliente
	cWhere += "AND A.A1_COD = '" + cCodiCli + "' "
	cWhere += "AND A.A1_LOJA = '" + cLojaCli + "' "

	// Estancia a Classe da Rotina de Analise de Crédito - CAOA
	oClassLm := CLASCRED():New()

	// VALIDA LIMITE DE CREDITO EXPIRADO [A1_VENCLC]
	// dDtProces := Iif(Empty(aMv_Par[08]),dDataBase,aMv_Par[08])
	lLimExpir := oClassLm:LimiteVencido(aMv_Par[01],aMv_Par[02],dDtProces)

	If lLimExpir
		lValid := .F.
		If lUpdSA1
			oClassLm:AlteraStatusCli(cWhere,cStaBlq,cUsrLog)	// Bloqueia por limite de crédito expirado
		EndIf

	Else
		lTitVenc	:= .F.

		// Bloqueia por titulos vencidos ? 1=Sim | 2=Não
		If cBloqTit == '1'
			// Trata a data minima para titulos em atraso - Data do Processamento - Periodo = Data limite para atraso
			// dDtProces := Iif(Empty(aMv_Par[08]),dDataBase,aMv_Par[08]) // DUPLICADO // ANTES DE:: lLimExpir := oClassLm:LimiteVencido(...)
			// dDtAtraso := dDtProces - Val(aMv_Par[07])
			dDtAtraso := dDtProces - aMv_Par[07] // aMv_Par[07] == PARAMETRO "CAOA_DIATR" TIPO "N"

			ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Verificando Titulos em Aberto para o Cliente: " + cCodiCli + "\" + cLojaCli + " -- [CLICRED{ID:2}\CLIIOUT]")

			// lTitVenc := oClassLm:TitulosEmAtraso( .T.,cCodiCli,cLojaCli,"",dDtAtraso,aMv_Par[6] )
			lTitVenc := oClassLm:TitulosEmAtraso( .T.,cCodiCli,cLojaCli,Nil,dDtAtraso,aMv_Par[6] )

			If lTitVenc
				lValid := .F.
				If lUpdSA1
					oClassLm:AlteraStatusCli(cWhere,cStaBlq,cUsrLog)	// Bloqueia por titulos em aberto
				EndIf
			EndIf
		EndIf

		// Efetua a analise de Credito // Bloqueia por Títulos vencidos ? 2=Não | VAZIO
		If !lTitVenc
			// VALOR CONSUMIDO :::: TOTAL EM TITULOS A RECEBER
			// nPendente := oClassLm:SaldoTitAberto( "",aMv_Par[6],lCliLoja,cCodiCli,cLojaCli )
			nPendente := oClassLm:SaldoTitAberto( aMv_Par[6],lCliLoja,Nil,cCodiCli,cLojaCli ) // VERSAO 2.0

			// nLImCred := oClassLm:LimiteCredito( "",lCliLoja,cCodiCli,cLojaCli,aMv_Par[9],aMv_Par[10] )
			// nLimCred := oClassLm:LimiteCredito( "",lCliLoja,cCodiCli,cLojaCli)
			// nLimCred := oClassLm:LimiteCredito( lCliLoja,Nil,cCodiCli,cLojaCli) // VERSAO 2.0
			nLimCred := oClassLm:nValCred // VERSAO 2.0
			
			// VALOR CONSUMIDO :::: NÃO DEDUZIR DEVOLUÇÃO (Título Tipo NCC) E ANTECIPAÇÃO (Título Tipo RA)
			// nVlRANCC := oClassLm:SaldoTitRANCC( "",lCliLoja,cCodiCli,cLojaCli)
			
			// PEDIDO DE VENDA :::: TOTAL PARA FATURAMENTO
			If !Empty(cPedido)
				 // FIXME: Retornar apenas total de itens liberados para faturamento. Atual retorna total geral lançado
				nRequerido := oClassLm:SaldoPedidoFat( aMv_Par[06],cPedido )
			Endif

			ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Analisando as variaveis de credito para o Cliente: " + cCodiCli + "\" + cLojaCli + " -- [CLICRED{ID:2}\CLIIOUT]")

			// SALDO :::: CALCULAR NOVO SALDO (Limite de Crédito - Recebimento Pendente - Total para Faturamento)
			nSaldoNovo := nLimCred - ( nPendente + nRequerido ) // FIXME: VALIDAR REGRA DE NEGÓCIO - nRequerido total apenas de itens liberados
			
			// NOVO SALDO REMANESCENTE :::: Positivo
			If nSaldoNovo >= 0
				lValid := .T.    // ATENDE OPERAÇÃO DE LIBERAÇÃO DE CRÉDITO

				ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Aprovacao - Total de Titulos e Pedido dentro do limite de credito: " + cCodiCli + "\" + cLojaCli + " -- [CLICRED{ID:2}\CLIIOUT]")

				//-- JOB :: LIBERAR ::: CLIENTE/LOJA :::: TÍTULOS PENDENTES E EM FATURAMENTO IGUAL OU SUPERIOR AO LIMITE DE CRÉDITO
				If lUpdSA1
					oClassLm:AlteraStatusCli(cWhere,cStaLib,cUsrLog)
					ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Status - Aprovado via JOB: " + cCodiCli + "\" + cLojaCli + " -- [CLICRED{ID:2}\CLIIOUT]")
				Endif

			Else // NOVO SALDO REMANECENTE :::: Negativo
				lValid := .F.    // NÃO ATENDE OPERAÇÃO DE LIBERAÇÃO DE CRÉDITO

				ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Bloqueio - Titulos em aberto maior que limite de credito: " + cCodiCli + "\" + cLojaCli + " -- [CLICRED{ID:2}\CLIIOUT]")
				
				//-- JOB :: BLOQUEAR ::: CLIENTE/LOJA :::: VALOR PENDENTE DE RECEBIMENTO SUPERIOR AO SALDO
				If lUpdSA1
					oClassLm:AlteraStatusCli(cWhere,cStaBlq,cUsrLog)
					ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Status - Bloqueado via JOB: " + cCodiCli + "\" + cLojaCli + " -- [CLICRED{ID:2}\CLIIOUT]")
				Endif

			EndIf

		EndIf

	EndIf

	If IsBlind()
		Reset Environment
	Endif

Return( lValid )
