#Include "Protheus.ch"
#Include "TOTVS.ch"
#Include "TBIConn.ch"

/*/{Protheus.doc} CLIINSID
	Fun��o Auxiliar - No c�lculo do Cr�dito por ***Grupo econ�mico***, via *Thread*.
	Efetua a An�lise de Cr�dito pela raiz do CNPJ, para Grupo de Cliente.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		05/04/2019
	@version 	2.0
	@param 		aParam		, array		, descricao
	@param 		lUpdSA1		, logical	, Realizar atualiza��o de *"Status"* do cadastro de Cliente �SA1`
	@param 		lValid		, logical	, Controle - Cr�dito v�lido, liberar cr�dito existente - passagem por refer�ncia
	@return 	logical		, Retorna situa��o geral final do cr�dito - LIBERADO (.T.) ou BLOQUEADO (.F.). Igual par�metro
	@return 	       		, > Igual par�metro *`lValid`* passado por refer�ncia.
	@history 	          	, denis.galvani, v.2.0 - Tratamento para atualizar cadastro de Cliente
	@history 	22/08/2020	, denis.galvani, Inclus�o/padroniza��o de documenta��o de cabe�alho
	@history 	26/08/2020	, denis.galvani, Ajustes na passagem de par�metros (ordem) aos m�todos da classe
	@history 	29/08/2020	, denis.galvani, Mudan�a no padr�o do par�metro/vari�vel "cStatus" *(aParam[5])* de '01';'02' para 01;02
	@history 	29/08/2020	, denis.galvani, Ajuste para bloqueio por T�tulo vencido, campo `A1_XBLQBEN`, do *Grupo econ�mico* a partir da empresa Matriz
	@obs 		TODO feature 26/08/2020	, denis.galvani, Atualiza��o autom�tica de *"Status"* de Cliente quando saldo igual a zero (somente) - campo `A1_XSTATUS`
	/*/
User Function CLIINSID(aParam,lUpdSA1,lValid)
	Local cEmpShd	 := aParam[1]
	Local cFilShd	 := aParam[2]
	Local cCNPJ		 := aParam[3]
	Local aMv_Par	 := aParam[4]
	Local cStatus	 := aParam[5]
	Local cUsrLog	 := aParam[6]
	Local cPedido 	 := aParam[7]

	Local cAliCli	 := ""
	Local cQuery	 := ""
	Local cWhere	 := ""
	Local cStaLib	 := ""
	Local cStaBlq	 := ""
	Local nPendente	 := 0
	Local nLimCred	 := 0
	// Local nVlRANCC	 := 0
	Local lTitVenc	 := .F.
	Local lCliLoja	 := .F.
	Local dDtProces	 := Iif( Empty(aMv_Par[08]), dDataBase, aMv_Par[08] )
	Local dDtAtraso	 := Nil
	Local oClassLm	 := Nil
	Local nRequerido := 0
	Local lLimExpir  := .F.
	Local nSaldoNovo := 0
	// Local cCgcMatriz := ""
	Local cBlqVencto := " "

	LOCAL lRet       := .T. // RETORNA SITUACAO GERAL FINAL DO CREDITO - LIBERADO (.T.) OU BLOQUEADO (.F.)

	DEFAULT lUpdSA1    := .T. // ATUALIZA STATUS DO CLIENTE AO EXECUTAR ROTINA VIA JOB, E MENU DE USU�RIO
	DEFAULT lValid     := .F. // RETORNA SITUACAO DO CREDITO - LIBERADO (.T.) OU BLOQUEADO (.F.)

	If IsBlind()
		RpcClearEnv()
		RpcSetType(3)
		Prepare Environment Empresa cEmpShd Filial cFilShd Modulo "FIN"
	Endif

	cStaLib	:= SuperGetMv("CAOA_STLIB",,"01")
	cStaBlq	:= SuperGetMv("CAOA_STBLQ",,"02")
	cAliCli := GetNextAlias()

	ConOut("CLIINSID 01")
	If Select(cAliCli) > 0
		ConOut("CLIINSID 02")
		(cAliCli)->(DbCloseArea())
	EndIf

	// SELECT - Bloqueio por T�tulo vencido
	cStatus := FormatIn(cStatus,";")
	// cStatus := SubStr(cStatus,3,LEN(cStatus)-4)
	cStatus := Left(cStatus,LEN(cStatus)-2)
	cStatus := Right(cStatus,LEN(cStatus)-2)
	BeginSQL Alias cAliCli
		SELECT
			A1_XBLQVEN AS BLQ_VENCTO
		FROM %table:SA1% A
		WHERE
			A.%notDel%
			AND A.A1_FILIAL = %xFilial:SA1%
			AND A.A1_MSBLQL = %exp:"2"%
			AND SUBSTRING(A.A1_CGC,1,8) = %exp:PadR(cCNPJ,8)%
			AND A.A1_XSTATUS IN ( %exp:cStatus% )
			AND A.A1_XDESGRP <> %exp:"1"%
			AND ROWNUM = 1
		ORDER BY %order:SA1,1%
	EndSQL
		// GROUP BY A1_XBLQVEN

	cQuery := GetLastQuery()[2] // QUERY EXECUTADA
	ConOut(cQuery)

	(cAliCli)->(DbGoTop())

	// BLOQUEIO POR T�TULO VENCIDO :::: BUSCA CONFIGURACAO NO CADASTRO DO CLIENTE MATRIZ
	// cCgcMatriz := Posicione("SA1",3,Xfilial("SA1")+PadR(cCNPJ,8)+"0001","A1_CGC")	// A1_FILIAL+A1_CGC
	// If !Empty(cCgcMatriz)
	// 	cBlqVencto := Posicione("SA1",3,xFilial("SA1")+cCgcMatriz,"A1_XBLQVEN")
	// Else
		cBlqVencto := (cAliCli)->BLQ_VENCTO
	// EndIf

	// Monta o Where, para as atualiza��es que dever�o ser efetuadas no cadastro de cliente
	cWhere := " AND A.A1_XSTATUS IN " + cStatus + " "
	cWhere += " AND A.A1_XDESGRP IN (' ','2') " //='2' " // 1=Sim;2=Nao
	cWhere += " AND SUBSTRING(A.A1_CGC,1,8) = '" + cCNPJ + "' "

	ConOut("CLIINSID 03")
	ConOut(IIF(!(cAliCli)->(EOF()),"TRUE","FALSE"))

	While !(cAliCli)->(EOF())
		ConOut("CLIINSID 04")

		// Estancia a Classe da Rotina de Analise de Cr�dito - CAOA
		oClassLm := CLASCRED():New()

		// VERIFICA LIMITE DE CREDITO EXPIRADO [A1_VENCLC]
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
			If cBlqVencto == '1' // (cAliCli)->BLQ_VENCTO == '1'
				ConOut("CLIINSID 05")
				// Trata a data minima para titulos em atraso - Data do Processamento - Periodo = Data limite para atraso
				// dDtProces := Iif(Empty(aMv_Par[08]),dDataBase,aMv_Par[08]) // DUPLICADO // ANTES DE:: lLimExpir := oClassLm:LimiteVencido(...)
				// dDtAtraso := dDtProces - Val(aMv_Par[07])
				dDtAtraso := dDtProces - aMv_Par[07] // aMv_Par[07] == PARAMETRO "CAOA_DIATR" TIPO "N"

				ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Verificando Titulos em Aberto para o Grupo: " + cCNPJ + " -- [CLICRED\CLIINSID]")

				// lTitVenc := oClassLm:TitulosEmAtraso( .F.,"","",cCNPJ,dDtAtraso,aMv_Par[6] )
				lTitVenc := oClassLm:TitulosEmAtraso( .F.,Nil,Nil,cCNPJ,dDtAtraso,aMv_Par[6] )

				If lTitVenc
					lValid := .F.
					If lUpdSA1
						oClassLm:AlteraStatusCli(cWhere,cStaBlq,cUsrLog)	// Bloqueia por titulos em aberto
					EndIf
				EndIf
			EndIf

			// Efetua a analise de Credito // Bloqueia por T�tulos vencidos ? 2=N�o | VAZIO // SEM TITULO VENCIDO
			If !lTitVenc
				// VALOR CONSUMIDO :::: TOTAL EM TITULOS A RECEBER
				// nPendente := oClassLm:SaldoTitAberto( cCNPJ,aMv_Par[6],lCliLoja,"","" )
				nPendente := oClassLm:SaldoTitAberto( aMv_Par[6],lCliLoja,cCNPJ ) // VERSAO 2.0
				
				
				
				// nLimCred := oClassLm:LimiteCredito( cCNPJ,lCliLoja,"","",aMv_Par[9],aMv_Par[10] )
				nLimCred := oClassLm:LimiteCredito( lCliLoja,cCNPJ )
								
				// VALOR CONSUMIDO :::: N�O DEDUZIR DEVOLU��O (T�tulo Tipo NCC) E ANTECIPA��O (T�tulo Tipo RA)
				// nVlRANCC := oClassLm:SaldoTitRANCC( cCNPJ,lCliLoja,"","")
				
				// PEDIDO DE VENDA :::: TOTAL PARA FATURAMENTO
				If !Empty(cPedido)
					 // FIXME: Retornar apenas total de itens liberados para faturamento. Atual retorna total geral lan�ado
					nRequerido := oClassLm:SaldoPedidoFat( aMv_Par[06],cPedido )
				Endif

				ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Analisando as variaveis de credito para o Grupo: " + cCNPJ + " -- [CLICRED\CLIINSID]")

				// SALDO :::: CALCULAR NOVO SALDO (Limite de Cr�dito - Recebimento Pendente - Total para Faturamento)
				nSaldoNovo := nLimCred - ( nPendente + nRequerido )// FIXME: VALIDAR REGRA DE NEG�CIO - nRequerido total apenas de itens liberados
				
				// NOVO SALDO REMANESCENTE :::: Positivo
				If nSaldoNovo >= 0
					lValid := .T.    // ATENDE OPERA��O DE LIBERA��O DE CR�DITO
			
					ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Aprovacao - Total de Titulos e Pedido dentro do limite de credito: " + cCNPJ + " -- [CLICRED\CLIINSID]")

					//-- JOB :: LIBERAR ::: CLIENTE/LOJA :::: T�TULOS PENDENTES E EM FATURAMENTO IGUAL OU SUPERIOR AO LIMITE DE CR�DITO
					If lUpdSA1
						oClassLm:AlteraStatusCli(cWhere,cStaLib,cUsrLog)
						ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Status - Aprovado via JOB: " + cCNPJ + " -- [CLICRED\CLIINSID]")
					EndIf

				Else // NOVO SALDO REMANECENTE :::: Negativo
					lValid := .F.    // N�O ATENDE OPERA��O DE LIBERA��O DE CR�DITO

					ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Bloqueio - Titulos em aberto maior que limite de credito: " + cCNPJ + " -- [CLICRED\CLIINSID]")
					
					//-- JOB :: BLOQUEAR ::: CLIENTE/LOJA :::: VALOR PENDENTE DE RECEBIMENTO SUPERIOR AO SALDO
					If lUpdSA1
						oClassLm:AlteraStatusCli(cWhere,cStaBlq,cUsrLog)
						ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Status - Bloqueado via JOB: " + cCNPJ + " -- [CLICRED\CLIINSID]")
					EndIf

				EndIf

			EndIf

		EndIf

		(cAliCli)->(DbSkip())

		lRet := Iif((lRet .AND. lValid), .T. , .F.)

	EndDo
	(cAliCli)->(DbCloseArea())

	If IsBlind()
		Reset Environment
	Endif

	lValid := lRet // ATUALIZAR PARAMETROS PASSADO POR REFERENCIA

Return( lRet )
