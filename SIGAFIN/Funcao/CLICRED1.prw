#Include "Protheus.Ch"
#Include "TOTVS.Ch"
#Include "TbiConn.Ch"

/*/{Protheus.doc} CLICRED1
Função Responsavel por analisar o credito dos clientes por grupo.
@author FSW - DWC Consult
@since 05/04/2019
@version 1.0
@param aParam, array, descricao
@type function
/*/
User Function CLICRED1(aParam)
	Local cCliEmp	:= aParam[1]
	Local cCliFil	:= aParam[2]
	Local aMv_Par	:= aParam[3]
	Local cUsrLog	:= aParam[4]

	Local cAliInsd	:= ""
	Local cQuery	:= ""
	Local nTotal	:= 0
	Local nMaxThred	:= 0
	Local aCliente	:= {}
	Local oThrd		:= Nil

	RpcClearEnv()
	RpcSetType(3)
	Prepare Environment Empresa cCliEmp Filial cCliFil Modulo "FIN"

	oThrd := CLASCRED():New()
	
	nMaxThred	:= SuperGetMv("CAOA_MXTHR",,50)
	cAliInsd	:= GetNextAlias()
	cStatus		:= FormatIn( StrTran( Left(aMv_Par[05],Len(AllTrim(aMv_Par[05]))-1) ,"'","") ,";")

	If Select(cAliInsd) > 0
		(cAliInsd)->(DbCloseArea())
	EndIf
	cQuery := "SELECT "
	cQuery += "SUBSTRING(A1_CGC,1,8) AS CGC_RAIZ "
	cQuery += "FROM " + RetSqlName("SA1") + " A "
	cQuery += "WHERE "
	cQuery += "A.D_E_L_E_T_ = '' "
	cQuery += "AND A.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += "AND A.A1_MSBLQL = '2' "
	cQuery += "AND A.A1_COD BETWEEN '" + aMv_Par[1] + "' AND '" + aMv_Par[3] + "' "
	cQuery += "AND A.A1_LOJA BETWEEN '" + aMv_Par[2] + "' AND '" + aMv_Par[4] + "' "
	cQuery += "AND A.A1_XSTATUS IN " + cStatus + " "
	cQuery += "AND A.A1_XDESGRP ='2' "
	cQuery += "AND A.A1_CGC <> '' "
	cQuery += "GROUP BY "
	cQuery += "SUBSTRING(A1_CGC,1,8) " 
	cQuery += "ORDER BY "
	cQuery += "1 "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliInsd,.F.,.T.)
	Count To nTotal

	If nTotal > 0

		(cAliInsd)->(DbGoTop())

		While !(cAliInsd)->(EOF())

			aCliente := {cCliEmp,cCliFil,(cAliInsd)->CGC_RAIZ,aMv_Par,cStatus,cUsrLog}

			//Função para controle de Threads.
			If oThrd:ThreadFunc(nMaxThred,"U_CLIINSID")
				
				ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Iniciando Analise de Credito para o Grupo: " + (cAliInsd)->CGC_RAIZ + " -- [CLICRED1]")
				
				FWMonitorMsg("JOB - Analise de Credito por Grupo - CAOA.")
				
				StartJob("U_CLIINSID",GetEnvServer(),.F.,aCliente)

				(cAliInsd)->(DbSkip())
			EndIf

		EndDo
	EndIf
	(cAliInsd)->(DbCloseArea())
	
	Reset Environment
Return

/*/{Protheus.doc} CLIINSID
Função Auxiliar, utilizada no calculo do credito por grupo, via Thread.
@author FSW - DWC Consult
@since 05/04/2019
@version 1.0
@param aParam, array, descricao
@type function
/*/
//User Function CLIINSID(aParam)
User Function _CLIINSID(aParam)
	// ***OBS: esta funcao foi renomeada em 09/08/19, pois a funcao U_CLIINSID existe no fonte CLIINSID.PRW e aparentemento estah mais atualizada que a deste fonte,
	// desta forma, foi acrescentado o "_" antes do nome da funcao, com isso a funcao ainda consegue ser compilada, mas nao eh chamada em lugar nenhum.

	Local cEmpShd	:= aParam[1]
	Local cFilShd	:= aParam[2]
	Local cCNPJ		:= aParam[3]
	Local aMv_Par	:= aParam[4]
	Local cStatus	:= aParam[5]
	Local cUsrLog	:= aParam[6]

	Local cAliCli	:= ""
	Local cQuery	:= ""
	Local cWhere	:= ""
	Local cStaLib	:= ""
	Local cStaBlq	:= ""
	Local nValOpen	:= 0
	Local nLImCred	:= 0
	Local lTitVenc	:= .F.
	Local dDtProces	:= Nil
	Local dDtAtraso	:= Nil
	Local oClassLm	:= Nil

	RpcClearEnv()
	RpcSetType(3)
	Prepare Environment Empresa cEmpShd Filial cFilShd Modulo "FIN"

	cStaLib	:= SuperGetMv("CAOA_STLIB",,"01")
	cStaBlq	:= SuperGetMv("CAOA_STBLQ",,"02")
	cAliCli := GetNextAlias()
	
	If Select(cAliCli) > 0
		(cAliCli)->(DbCloseArea())
	EndIf
	cQuery := "SELECT "
	cQuery += "A1_XBLQVEN AS BLOQ_VENCIDOS "
	cQuery += "FROM " + RetSqlName("SA1") + " A "
	cQuery += "WHERE "
	cQuery += "A.D_E_L_E_T_='' "
	cQuery += "AND A.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += "AND A.A1_MSBLQL = '2' "
	cQuery += "AND SUBSTRING(A.A1_CGC,1,8) = '" + cCNPJ + "' "
	cQuery += "AND A.A1_XSTATUS IN " + cStatus + " "
	cQuery += "AND A.A1_XDESGRP ='2' "
	cQuery += "GROUP BY "
	cQuery += "A1_XBLQVEN "
	cQuery += "ORDER BY "
	cQuery += "1 "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliCli,.F.,.T.)

	(cAliCli)->(DbGoTop())

	//Monta o Where, para as atualizações que deverão ser efetuadas no cadastro de cliente.
	cWhere := "AND A.A1_XSTATUS IN " + cStatus + " "
	cWhere += "AND A.A1_XDESGRP ='2' "
	cWhere += "AND SUBSTRING(A.A1_CGC,1,8) = '" + cCNPJ + "' "

	While !(cAliCli)->(EOF())

		//Estancia a Classe da Rotina de Analise de Crédito - CAOA.
		oClassLm := CLASCRED():New()
		
		lTitVenc	:= .F.

		//Bloqueia por titulos vencidos ? 1=Sim | 2=Não
		If (cAliCli)->BLOQ_VENCIDOS == '1'
			//Trata a data minima para titulos em atraso - Data do Processamento - Periodo = Data limite para atraso.
			dDtProces := Iif(Empty(aMv_Par[08]),dDataBase,aMv_Par[08])
			dDtAtraso := dDtProces - Val(aMv_Par[07])
			
			ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Verificando Titulos em Aberto para o Grupo: " + cCNPJ + " -- [CLICRED1\CLIINSID]")
			
			lTitVenc := oClassLm:TitulosEmAtraso( .F.,"","",cCNPJ,dDtAtraso,aMv_Par[6] )

			If lTitVenc
				oClassLm:AlteraStatusCli(cWhere,cStaBlq,cUsrLog)	//Bloqueia por titulos em aberto
			EndIf
		EndIf

		//Efetua a analise de Credito.
		If !lTitVenc
			nValOpen := oClassLm:SaldoTitAberto( cCNPJ,,.F.,"","" )
			nLImCred := oClassLm:LimiteCredito( cCNPJ,.F.,"","" )
			
			ConOut("["+ DToS(Date()) + "-" + Time() + "] -- Analisando as variaveis de credito para o Grupo: " + cCNPJ + " -- [CLICRED1\CLIINSID]")
			
			If nLimCred - nValOpen <= 0
				oClassLm:AlteraStatusCli(cWhere,cStaBlq,cUsrLog)	//Bloqueia devido ao valor dos titulos em aberto serem maiores que o limite de crédito.
			Else
				oClassLm:AlteraStatusCli(cWhere,cStaLib,cUsrLog)	//Aprovado devido ao valor dos titulos serem menores que o limite de crédito.
			EndIf
		EndIf

		(cAliCli)->(DbSkip())
	EndDo
	(cAliCli)->(DbCloseArea())

	Reset Environment
Return
