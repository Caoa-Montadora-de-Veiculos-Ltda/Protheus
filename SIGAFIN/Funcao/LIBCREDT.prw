#Include "Protheus.CH"
#Include "TOTVS.CH"
#Include "TBIConn.CH"

/*/{Protheus.doc} LIBCREDT
	Rotina para Cálculo do Crédito dos Cliente CAOA
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		05/04/2019
	@version 	1.0
	@param 		cSchEmp		, character , Empresa de execução por JOB
	@param 		cSchFil		, character , Filial de execução por JOB
	@return 	NIL, Nulo *(nenhum)*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
User Function LIBCREDT(cSchEmp,cSchFil)
	Local lJob		:= Iif(Empty(cSchEmp),.F.,.T.)

	Local nOpca		:= 0
	Local aMv_Par	:= {}
	Local aArea		:= {}
	Local oDlg		:= Nil

	PRIVATE lUpdSA1 := .F. // ATUALIZAR CADASTRO DE CLIENTE [SA1] VIA JOB OU CHAMADA PELO NO MENU DO USUÁRIO

	ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Iniciando Analise de Credito \ Liberacao -- [LIBCREDT]")

	FWMonitorMsg("Rotina de Analise de Crédito - CAOA.")

	If !lJob
		aArea := GetArea()

		ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Rotina executada via Sistema -- [LIBCREDT]")

		DEFINE MSDIALOG oDlg FROM  096,004 TO 355,625 TITLE OemToAnsi("Liberação de Crédito - CAOA") PIXEL
		@ 018, 009 TO 099,300 LABEL "" OF oDlg  PIXEL
		@ 029, 015 Say OemToAnsi("Este programa irá efetuar as análises necessárias para bloquear \ liberar o crédito dos clientes CAOA.") SIZE 275, 10 OF oDlg PIXEL
		@ 038, 015 Say OemToAnsi("Rotina de Cálculo específica da CAOA.") 	 SIZE 275, 10 OF oDlg PIXEL

		DEFINE SBUTTON FROM 108,209 TYPE 5 ACTION U_ProtPerg(@aMv_Par,lJob)  ENABLE OF oDlg
		DEFINE SBUTTON FROM 108,238 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 108,267 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg

		If nOpca == 1
			If  !Empty(aMv_Par)
				lUpdSA1 := .T. // EXECUÇÃO PELA ROTINA DE MENU DO USUÁRIO - ATUALIZAR CADASTRO

				MsgRun("Processando Rotina de Credito via Thread... Aguarde...","CAOA",{|| U_LIBFUN01(aMv_Par,lUpdSA1,.F.,"")})

				MsgInfo("Processamento Efetuado com Sucesso!!!","TOTVS")
			Else
				MsgAlert("Os Parâmetros não foram informados." + CRLF + CRLF + "Rotina não executada.","Parâmentros não informados !!!")
			EndIf
		EndIf

		RestArea(aArea)
	Else
		RpcClearEnv()
		RpcSetType(3)
		Prepare Environment Empresa cSchEmp Filial cSchFil Modulo "FIN"

		ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Rotina executada via Job -- [LIBCREDT]")

		// Função para carregar os parametros
		U_ProtPerg(@aMv_Par,lJob)

		lUpdSA1 := .T. // EXECUCAO VIA JOB - ATUALIZAR CADASTRO

		// Função de Processamento
		U_LIBFUN01(aMv_Par,lUpdSA1,.F.,"")

		Reset Environment
	EndIf

Return

/*/{Protheus.doc} LIBFUN01
	Função Auxiliar - Executar Threads Pai
	@type 		function
	@author 	TOTVS - FSW - DWC Consult; CAOA - denis.galvani - Denis A. Galvani
	@since 		05/04/2019
	@version 	2.0
	@param 		aMv_Par		, array		, Vetor de parâmetros preenchidos por função estática `ProtPerg` ou *`Pergunte`*
	@param 		lJobUpd		, logical	, Chamada via JOB ou por usuário para atualizar cadastro de Cliente - tabela `SA1`
	@param 		lWait		, logical	, Indica se, verdadeiro *(`.T.`)*, o processo será finalizado; senão, falso (`.F.`)
	@param 		cPedido		, character	, Número do Pedido de Faturamento - campo `SC5->C5_NUM`
	@param 		lLibCredt	, logical	, Controle - Liberar crédito existente - passagem por referência
	@return 	NIL, Nulo *(nenhum)*
	@obs 		- Parâmetros *(`SC6`)*: `CAOA_MXTHR` - *Default 50*; 
				- Pergunte *(`SX1`)* - *"LIBCRDT"*
	@see		TDN - https://tdn.totvs.com/x/64Vc
	@history 	            , denis.galvani, v.2.0 - Tratamento para atualizar cadastro de Cliente
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	@history 	29/08/2020	, denis.galvani, Mudança no padrão do parâmetro/variável "cStatus" de '01';'02' para 01;02
	/*/
User Function LIBFUN01(aMv_Par,lJobUpd,lWait,cPedido,lLibCredt)
	Local nMaxThred	:= SuperGetMv("CAOA_MXTHR",,50)
	// Local cStatus	:= FormatIn( StrTran( Left(aMv_Par[05],Len(AllTrim(aMv_Par[05]))-1) ,"'","") ,";")
	Local cStatus	:= aMv_Par[05]
	Local cAliJbs	:= ""
	Local aDados	:= {}
	Local aJobs		:= {}
	Local oThrd		:= CLASCRED():New()

	DEFAULT lLibCredt  := .F. // RETORNA SITUACAO DO CREDITO - LIBERADO (.T.) OU BLOQUEADO (.F.)

	// Função para Consultar os CNPJ's \ Codigos e Lojas dos clientes
	aJobs := FQrSa1(aMv_Par,cStatus)

	// Carrega o Alias da Query
	cAliJbs := aJobs[1]

	// Verifica o total de registros
	If aJobs[2] > 0

		(cAliJbs)->(DbGoTop())

		While !(cAliJbs)->(EOF())

			/**
			 * ============================================================================
			 * -- GRUPO ECONOMICO ---------------------------------------------------------
			 * ---- * CLIENTES MESMA RAIZ CNPJ --------------------------------------------
			 * ---- * NAO EXCLUSIVO (A1_XDSGRP == '1') --------------------------------------
			 */    // ANALISE por raiz CNPJ
			If (cAliJbs)->ID == 1 
				aDados := {cEmpAnt,cFilAnt,AllTrim((cAliJbs)->CGC_RAIZ),aMv_Par,cStatus,cUserName,cPedido}

				// Função para controle de Threads
				If oThrd:ThreadFunc(nMaxThred,"U_CLIINSID")

					ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Iniciando Analise de Credito para o Grupo: " + (cAliJbs)->CGC_RAIZ + " -- [LIBCREDT\LIBFUN01]")

					FWMonitorMsg("JOB - Analise de Credito por Grupo - CAOA.")

					If !lWait
						StartJob("U_CLIINSID",GetEnvServer(),lWait,aDados,lJobUpd,@lLibCredt)
					Else // chamada sem ser via startjob, pois o recurso de multithread nao poderah ser ativado nesta execucao
						// uma vez, que o sistema precisa aguardar o final do processamento, para gravacao do campo A1_XSTATUS,
						// alem do mais, existe o risco da nova thread ficar em lock, principalmente com a tabela SA1/SB2 e o usuário
						// nao irah visualizar este lock uma vez que o lock eh na nova thread, desta forma, para evitar este problema,
						// a rotina eh chamada de forma normal
						U_CLIINSID(aDados,lJobUpd,@lLibCredt)
					Endif

					(cAliJbs)->(DbSkip())
				EndIf
			Else // Efetua a Analise pelo Codigo e Loja do Cliente
				aDados := {cEmpAnt,cFilAnt,(cAliJbs)->CLIENTE,(cAliJbs)->LOJA,(cAliJbs)->BLQ_VENCID,aMv_Par,cUserName,cPedido}

				// Função para controle de Threads
				If oThrd:ThreadFunc(nMaxThred,"U_CLIIOUT")

					ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Iniciando Analise de Credito para o Cliente: " + (cAliJbs)->CLIENTE + "\" + (cAliJbs)->LOJA + " -- [LIBCREDT\LIBFUN01]")

					FWMonitorMsg("JOB - Analise de Credito por Cliente \ Loja - CAOA.")

					If !lWait
						StartJob("U_CLIIOUT",GetEnvServer(),lWait,aDados,lJobUpd,@lLibCredt)
					Else
						U_CLIIOUT(aDados,lJobUpd,@lLibCredt)
					Endif

					(cAliJbs)->(DbSkip())
				EndIf
			EndIf
		EndDo
	EndIf

	If !lJobUpd
		// Monitora enquanto tiver threads no ar, para deixar a tela do user em processamento
		While !oThrd:ThreadFunc(0,"U_CLI")
		EndDo
	EndIf

	If !Empty(cAliJbs) .AND. Select(cAliJbs) > 0
		(cAliJbs)->( DbCloseArea() )
	EndIf
Return

/*/{Protheus.doc} FQrSa1
	Função Auxiliar para pegar os Grupos de Cliente e Clientes \ Lojas para analise.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		22/04/2019
	@version 	1.0
	@param 		aMv_Par		, array		, Parâmetros de pesquisa, *`Pergunte`*
	@param 		cStatus		, character	, Valor para campo *"Status"* Cliente *(`A1_XSTATUS`)*, opções tabela `SZB`
	@return 	array		, Vetor com alias da consulta e quantidade de registros - `{ cAlias, (cAlias)->(RecCount()) }`
	@See 		- Pergunte *(`SX1`)*: *"LIBCRDT"*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	@history 	29/08/2020	, denis.galvani, Mudança no padrão do parâmetro/variável "cStatus" de '01';'02' para 01;02
	@history 	29/08/2020	, denis.galvani, Consulta convertida para *Embedded SQL*
	/*/
Static Function FQrSa1(aMv_Par,cStatus)
	Local cAliJob	:= GetNextAlias()
	Local nRegJob	:= 0
	Local aRetJob	:= {}

	If Select(cAliJob) > 0
		(cAliJob)->(DbCloseArea())
	EndIf

	// SELECT
	cStatus := FormatIn(cStatus,";")
	// cStatus := SubStr(cStatus,3,LEN(cStatus)-4)
	cStatus := Left(cStatus,LEN(cStatus)-2)
	cStatus := Right(cStatus,LEN(cStatus)-2)
	BeginSQL Alias cAliJob
		SELECT 
		  1 AS ID, 
		  '' AS CLIENTE, 
		  '' AS LOJA, 
		  SUBSTRING(A.A1_CGC,1,8) AS CGC_RAIZ, 
		  CASE A.A1_XBLQVEN WHEN ' ' THEN '1' ELSE A.A1_XBLQVEN END AS BLQ_VENCID, 
		  CASE A.A1_XDESGRP WHEN ' ' THEN '2' ELSE A.A1_XDESGRP END AS DES_GRUPO /* LIMITE [A1_LC] EXCLUSIVO (DESCONSIDERA GRUPO ECONOMICO) - VAZIO OU '2' */
		FROM %table:SA1% A 
		WHERE 
		  A.D_E_L_E_T_ = '' 
		  AND A.A1_FILIAL = %xFilial:SA1%
		  AND A.A1_MSBLQL = '2' 
		  AND A.A1_COD BETWEEN %exp:aMv_Par[1]% AND %exp:aMv_Par[3]%
		  AND A.A1_LOJA BETWEEN %exp:aMv_Par[2]% AND %exp:aMv_Par[4]%
		  AND A.A1_XSTATUS IN ( %exp:cStatus% )
		  AND A.A1_XDESGRP <> '1' "
		  AND A.A1_CGC <> %exp:Space(TamSx3("A1_CGC")[1])%
		GROUP BY 
		  SUBSTRING(A.A1_CGC,1,8) , 
		  CASE A.A1_XBLQVEN WHEN ' ' THEN '1' ELSE A.A1_XBLQVEN END, 
		  CASE A.A1_XDESGRP WHEN ' ' THEN '2' ELSE A.A1_XDESGRP END  /* DESCONSIDERA GRUPO ECONOMICO - VAZIO OU '2' */
		
		UNION ALL 
		
		SELECT 
		  2 AS ID, 
		  A.A1_COD AS CLIENTE, 
		  A.A1_LOJA AS LOJA, 
		  '' AS CGC_RAIZ, 
		  CASE A.A1_XBLQVEN WHEN ' ' THEN '1' ELSE A.A1_XBLQVEN END AS BLQ_VENCID, 
		  A.A1_XDESGRP AS DES_GRUPO 
		FROM %table:SA1% A 
		WHERE "
		  A.%notDel% 
		  AND A.A1_FILIAL = %xFilial:SA1%
		  AND A.A1_MSBLQL = '2' 
		  AND A.A1_COD  BETWEEN %exp:aMv_Par[1]% AND %exp:aMv_Par[3]% 
		  AND A.A1_LOJA BETWEEN %exp:aMv_Par[2]% AND %exp:aMv_Par[4]% 
		  AND A.A1_XSTATUS IN ( %exp:cStatus% )
		  AND A.A1_XDESGRP = '1' 
		ORDER BY 
		  1,2,3 
	EndSql

	Count To nRegJob

	If nRegJob > 0
		aRetJob := {cAliJob,nRegJob}
	Else
		MsgInfo("Não há dados a ser processado.","TOTVS")
		aRetJob := {'',nRegJob}
	Endif

Return( aRetJob )

/*/{Protheus.doc} ProtPerg
	Função para controlar a execução de multi-usuários.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		05/04/2019
	@version 	2.0
	@param 		aMv_Par		, array		, Parâmetros de pesquisa, via *`Pergunte`* ou valores passados
	@param 		lJob		, logical	, Execução via JOB ou rotina de reprocessamento (por usuário)
	@return 	array		, Valores de parâmetros de *Pergunta* de acordo com tipo de execução *(JOB ou usuário)*
	@see 		- Parâmetros *(`SC6`)*: `CAOA_STALM`, `CAOA_TPLIM`, `CAOA_DIATR`; 
				- Pergunte *(`SX1`)* - *"LIBCRDT"*
	@history 	denis.galvani, 			 , v.2.0 - Limpar parâmetro *`aMv_Par`* de valores antigos
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
User Function ProtPerg(aMv_Par,lJob,cCliDe,cCliAte,cLojaDe,cLojaAte)
	Local cStatus	:= GetMv("CAOA_STALM")
	Local cTipLim	:= GetMv("CAOA_TPLIM")
	Local nDiasAtz	:= GetMv("CAOA_DIATR")
	Local nTamCli	:= TamSx3("A1_COD")[1]
	Local nTamLoj	:= TamSx3("A1_LOJA")[1]
	// Local aDtVenCr	:= & (GetMv("CAOA_DTCRD"))

	Default cCliDe 	   := ""
	Default cCliAte    := ""
	Default cLojaDe    := ""
	Default cLojaAte   := ""

	// VARIAVEL DE PARAMETROS
	aMv_Par := {}

	If !lJob .and. FWIsInCallStack("U_LIBCREDT")
		Pergunte("LIBCREDT",.T.)
		Aadd(aMv_Par,MV_PAR01)						//Do Cliente ?
		Aadd(aMv_Par,MV_PAR02)						//Da Loja ?
		Aadd(aMv_Par,MV_PAR03)						//Até o Cliente ?
		Aadd(aMv_Par,MV_PAR04)						//Até a Loja ?
		// Aadd(aMv_Par,MV_PAR05)					//Status ?
		// Aadd(aMv_Par,MV_PAR06)					//Tipos de Operação ?
		// Aadd(aMv_Par,MV_PAR07)					//Dias de Atraso p/ Bloqueio ?
		// Aadd(aMv_Par,MV_PAR08)					//Data do Processamento ?
		// Aadd(aMv_Par,MV_PAR09)					//Venc. Credito De?
		// Aadd(aMv_Par,MV_PAR10)					//Venc. Credito Ate?
		Aadd(aMv_Par,cStatus)						//Status ?
		Aadd(aMv_Par,cTipLim)						//Tipos de Operação ?
		Aadd(aMv_Par,nDiasAtz)						//Dias de Atraso p/ Bloqueio ?
		Aadd(aMv_Par,dDataBase)						//Data do Processamento ?
		// Aadd(aMv_Par,CToD(aDtVenCr[1]))			//Venc. Credito De?
		// Aadd(aMv_Par,CToD(aDtVenCr[2]))			//Venc. Credito Ate?
	Elseif lJob
		Aadd(aMv_Par,Space(nTamCli))				//Do Cliente ?
		Aadd(aMv_Par,Space(nTamLoj))				//Da Loja ?
		Aadd(aMv_Par,Replicate('Z',nTamCli))		//Até o Cliente ?
		Aadd(aMv_Par,Replicate('Z',nTamLoj))		//Até a Loja ?
		Aadd(aMv_Par,cStatus)						//Status ?
		Aadd(aMv_Par,cTipLim)						//Tipos de Operação ?
		Aadd(aMv_Par,nDiasAtz)						//Dias de Atraso p/ Bloqueio ?
		Aadd(aMv_Par,dDataBase)						//Data do Processamento ?
		// Aadd(aMv_Par,CToD(aDtVenCr[1]))			//Venc. Credito De?
		// Aadd(aMv_Par,CToD(aDtVenCr[2]))			//Venc. Credito Ate?
	Else
		// EXECUCAO PE M460MARK - DOCUMENTOS DE SAIDA MATA460 - PREPARACAO DOS DOCUMENTOS DE SAIDA
		Aadd(aMv_Par,cCliDe)						//Do Cliente ?
		Aadd(aMv_Par,cLojaDe)						//Da Loja ?
		Aadd(aMv_Par,cCliAte)						//Até o Cliente ?
		Aadd(aMv_Par,cLojaAte)						//Até a Loja ?
		// Aadd(aMv_Par,MV_PAR05)					//Status ?
		// Aadd(aMv_Par,MV_PAR06)					//Tipos de Operação ?
		// Aadd(aMv_Par,MV_PAR07)					//Dias de Atraso p/ Bloqueio ?
		// Aadd(aMv_Par,MV_PAR08)					//Data do Processamento ?
		// Aadd(aMv_Par,MV_PAR09)					//Venc. Credito De?
		// Aadd(aMv_Par,MV_PAR10)					//Venc. Credito Ate?
		Aadd(aMv_Par,cStatus)						//Status ?
		Aadd(aMv_Par,cTipLim)						//Tipos de Operação ?
		Aadd(aMv_Par,nDiasAtz)						//Dias de Atraso p/ Bloqueio ?
		Aadd(aMv_Par,dDataBase)						//Data do Processamento ?
		// Aadd(aMv_Par,CToD(aDtVenCr[1]))			//Venc. Credito De?
		// Aadd(aMv_Par,CToD(aDtVenCr[2]))			//Venc. Credito Ate?
	EndIf

	ConOut("----------------------------------------------------------------------------")
	ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Parâmetros de Execução - Rotina de Análise de Crédito CAOA -- [LIBCREDT\PROTPERG]")
	ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Cliente de: " + aMv_Par[1])
	ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Loja de: " + aMv_Par[2])
	ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Cliente Até: " + aMv_Par[3])
	ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Loja Até: " + aMv_Par[4])
	ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Status: " + aMv_Par[5])
	ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Tipos de Operação: " + aMv_Par[6])
	ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Dias de Atraso p/ Bloqueio: " + CValToChar(aMv_Par[7]))
	ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Data do Processamento: " + DToC(aMv_Par[8]))
	// ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Venc. Credito De? " + DToC(aMv_Par[9]))
	// ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Venc. Credito Ate? " + DToC(aMv_Par[10]))
	ConOut("----------------------------------------------------------------------------")

Return( aMv_Par )
