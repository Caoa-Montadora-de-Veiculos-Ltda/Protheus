#Include "Protheus.CH"
#Include "TOTVS.CH"
#Include "TBIConn.CH"

/*/{Protheus.doc} CLIIOUT
	Fun��o Auxiliar, utilizada no c�lculo do Cr�dito por C� digo e Loja, via Thread.
	Efetua a An�lise de Cr�dito pelo C�digo e Loja do Cliente, individual, fora de Grupo de Cliente.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult; denis.galvani - Denis A. Galvani
	@since 		05/04/2019
	@version 	2.0
	@param 		aParam		, array		, Par�metros de execu��o: 
							,			, - 1 - Grupo de Empresa; 
							,			, - 2 - Filial; 
							,			, - 3 - C�digo do Cliente (`A1_COD`);
							,			, - 4 - Loja do Cliente (`A1_LOJA`);
							,			, - 5 - Bloqueia por T�tulo vencido *(1 - Sim; 2 - N�o)*;
							,			, - 6 - Vetor de par�metro *(Pergunte)*:
							,			, - 6.1 - C�digo Cliente inicial *(`A1_COD`)*;
							,			, - 6.2 - Loja inicial *(`A1_LOJA`)*;
							,			, - 6.3 - C�digo Cliente final *(`A1_COD`)*;
							,			, - 6.4 - Loja final *(`A1_LOJA`)*;
							,			, - 6.5 - Status *(`A1_XSTATUS`)*;
							,			, - 6.6 - Lista de Tipos de Opera��o *(`C6_XOPER`)* separada por ponto e v�rgula (;);
							,			, - 6.7 - N�mero de dias em atraso para considerar campo de cadastro Bloqueia Vencido *(`A1_XBLQVEN`)*;
							,			, - 6.8 - Data do Processamento, *Data base*;
							,			, - 7. - C�digo de usu�rio *(UserId)* para registro log de mudan�as;
							,			, - 8. - C�digo do Pedido de Venda *(`C5_NUM`, `C6_NUM`)* para por Libera��o de Cr�dito
	@param 		lUpdSA1		, logical	, Realizar atualiza��o de "Status" *(campo `A1_XSTATUS`)* do cadastro de Cliente `SA1`
	@param 		lValid		, logical	, Controle - Cr�dito v�lido, liberar Cr�dito existente - passagem por refer�ncia
	@return 	logical		, Retorna situa��o geral final do Cr�dito - LIBERADO (`.T.`) ou BLOQUEADO (`.F.`)
	@history 	22/10/2019	, denis.galvani, Corre��o - Total de a receber do Cliente/Loja e respectivo Limite de Cr�dito.
	@history 	14/08/2020	, denis.galvani, Corre��o - Atualizar cadastro de Cliente.
	@history 	14/08/2020	, denis.galvani, Corre��o - C�lculo de Saldo de *Limite de Cr�dito*.
	@history 	          	,              , > N�o debitar do saldo *T�tulos* de natureza *de cr�dito* ou por *antecipa��o*, Tipos *NCC* e *RA* respectivamente.
	@history 	22/08/2020	, denis.galvani, Inclus�o/padroniza��o de documenta��o de cabe�alho
	@history 	26/08/2020	, denis.galvani, Ajustes na passagem de par�metros (ordem) aos m�todos da classe
	@obs 		TODO feature 26/08/2020	, denis.galvani, Atualiza��o autom�tica de *"Status"* de Cliente quando saldo igual a zero (somente) - campo `A1_XSTATUS`
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

	DEFAULT lUpdSA1    := .T. // ATUALIZA STATUS DO CLIENTE AO EXECUTAR ROTINA VIA JOB, E MENU DE USU�RIO
	DEFAULT lValid     := .F. // RETORNA SITUACAO DO CREDITO - LIBERADO (.T.) OU BLOQUEADO (.F.)

	If IsBlind()
		RpcClearEnv()
		RpcSetType(3)
		Prepare Environment Empresa cEmpShd Filial cFilShd Modulo "FIN"
	Endif

	cStaLib	:= SuperGetMv("CAOA_STLIB",,"01")
	cStaBlq	:= SuperGetMv("CAOA_STBLQ",,"02")

	// Monta o Where, para as atualiza��es que dever�o ser efetuadas no cadastro de cliente
	cWhere += "AND A.A1_COD = '" + cCodiCli + "' "
	cWhere += "AND A.A1_LOJA = '" + cLojaCli + "' "

	// Estancia a Classe da Rotina de Analise de Cr�dito - CAOA
	oClassLm := CLASCRED():New()

	// VALIDA LIMITE DE CREDITO EXPIRADO [A1_VENCLC]
	// dDtProces := Iif(Empty(aMv_Par[08]),dDataBase,aMv_Par[08])
	lLimExpir := oClassLm:LimiteVencido(aMv_Par[01],aMv_Par[02],dDtProces)

	If lLimExpir
		lValid := .F.
		If lUpdSA1
			oClassLm:AlteraStatusCli(cWhere,cStaBlq,cUsrLog)	// Bloqueia por limite de cr�dito expirado
		EndIf

	Else
		lTitVenc	:= .F.

		// Bloqueia por titulos vencidos ? 1=Sim | 2=N�o
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

		// Efetua a analise de Credito // Bloqueia por T�tulos vencidos ? 2=N�o | VAZIO
		If !lTitVenc
			// VALOR CONSUMIDO :::: TOTAL EM TITULOS A RECEBER
			// nPendente := oClassLm:SaldoTitAberto( "",aMv_Par[6],lCliLoja,cCodiCli,cLojaCli )
			nPendente := oClassLm:SaldoTitAberto( aMv_Par[6],lCliLoja,Nil,cCodiCli,cLojaCli ) // VERSAO 2.0

			// nLImCred := oClassLm:LimiteCredito( "",lCliLoja,cCodiCli,cLojaCli,aMv_Par[9],aMv_Par[10] )
			// nLimCred := oClassLm:LimiteCredito( "",lCliLoja,cCodiCli,cLojaCli)
			// nLimCred := oClassLm:LimiteCredito( lCliLoja,Nil,cCodiCli,cLojaCli) // VERSAO 2.0
			nLimCred := oClassLm:nValCred // VERSAO 2.0
			
			// VALOR CONSUMIDO :::: N�O DEDUZIR DEVOLU��O (T�tulo Tipo NCC) E ANTECIPA��O (T�tulo Tipo RA)
			// nVlRANCC := oClassLm:SaldoTitRANCC( "",lCliLoja,cCodiCli,cLojaCli)
			
			// PEDIDO DE VENDA :::: TOTAL PARA FATURAMENTO
			If !Empty(cPedido)
				 // FIXME: Retornar apenas total de itens liberados para faturamento. Atual retorna total geral lan�ado
				nRequerido := oClassLm:SaldoPedidoFat( aMv_Par[06],cPedido )
			Endif

			ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Analisando as variaveis de credito para o Cliente: " + cCodiCli + "\" + cLojaCli + " -- [CLICRED{ID:2}\CLIIOUT]")

			// SALDO :::: CALCULAR NOVO SALDO (Limite de Cr�dito - Recebimento Pendente - Total para Faturamento)
			nSaldoNovo := nLimCred - ( nPendente + nRequerido ) // FIXME: VALIDAR REGRA DE NEG�CIO - nRequerido total apenas de itens liberados
			
			// NOVO SALDO REMANESCENTE :::: Positivo
			If nSaldoNovo >= 0
				lValid := .T.    // ATENDE OPERA��O DE LIBERA��O DE CR�DITO

				ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Aprovacao - Total de Titulos e Pedido dentro do limite de credito: " + cCodiCli + "\" + cLojaCli + " -- [CLICRED{ID:2}\CLIIOUT]")

				//-- JOB :: LIBERAR ::: CLIENTE/LOJA :::: T�TULOS PENDENTES E EM FATURAMENTO IGUAL OU SUPERIOR AO LIMITE DE CR�DITO
				If lUpdSA1
					oClassLm:AlteraStatusCli(cWhere,cStaLib,cUsrLog)
					ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Status - Aprovado via JOB: " + cCodiCli + "\" + cLojaCli + " -- [CLICRED{ID:2}\CLIIOUT]")
				Endif

			Else // NOVO SALDO REMANECENTE :::: Negativo
				lValid := .F.    // N�O ATENDE OPERA��O DE LIBERA��O DE CR�DITO

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
