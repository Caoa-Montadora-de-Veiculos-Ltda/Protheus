#INCLUDE 'PROTHEUS.CH'
#Include "Totvs.Ch"
#include 'parmtype.ch'
#include "TBICONN.CH"
#include 'TOPCONN.CH'

/*
{Protheus.doc} u_ZFLUIF01
Integracao Fluig WS CLIENT - solicitação de compras.

@author  Sandro Gonçalves Ferreira
@version 1.0
@since   18/02/2022
@return  Nil  Sem retorno.
@sample
         u_ZFLUIF01()
*/
 
USER Function ZFLUIF01(_aParam)
Local _lJob := If( IsBlind(),.T.,.F.)
Local _lAbre		:= .F.
Local _lRet
Local _nPos   
Local _cEmpresa	
Local _cFilial 

Begin Sequence
    If _lJob
		ConOut("*************************************************************************************************************************"	+ CRLF)
		ConOut("----------- [ ZFLUIF01 ] - Inicio da funcionalidade "													                	+ CRLF)
		ConOut("*************************************************************************************************************************"	+ CRLF)
	EndIf

	//sendo job testar parametros
	If _lJob
		If ValType(_aParam) == "A"
			_cEmpresa 	:=  _aParam[1]
			_cFilial 	:=  _aParam[2]
			CONOUT("INICIANDO EMPRESA " + _cEmpresa)
			CONOUT("INICIANDO FILIAL "  + _cFilial)
			RpcClearEnv()
			RpcSetType(3)
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "COM"
			_lAbre		:= .T.
		ElseIf Type("cFilAnt") <> "C"
			_cEmpresa	:=	"01"
			_cFilial	:=  "2010022001"
			CONOUT("INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("INICIANDO FILIAL "+_cFilial)
			RpcClearEnv()
			RpcSetType(3)
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "COM"
			_lAbre		:= .T.
		EndIf
	EndIF
	CONOUT("INICIADA EMPRESA " + cEmpAnt)
	CONOUT("INICIADA FILIAL "  + cFilAnt)

    ConOut("*************************************************************************************************************************"	+ CRLF)
	ConOut("----------- [ ZFLUIF01 ] - VERIFICANDO SE JA EXISTE PROCESSAMENTO DO JOB  "														+ CRLF)
	ConOut("*************************************************************************************************************************"	+ CRLF)

	If !LockByName("ZFLUIF01",.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 1000 ) // Para o processamento por 1 segundo
			If LockByName("ZFLUIF01",.T.,.T.)
				_lRet := .T.
			EndIf
		Next	

		If !_lRet
			If !_lJob
				MsgInfo("Já existe um processamento em execução rZFLUIF01UIG010, aguarde!")
			Else
				CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFLUIF01] Já existe um processamento em execução, aguarde!")
				ConOut("*************************************************************************************************************************"	+ CRLF)
				ConOut("----------- [ ZFLUIF01 ] - Já existe um processamento em execução rZFLUIF01UIG010 "														+ CRLF)
				ConOut("*************************************************************************************************************************"	+ CRLF)
			EndIf
			Break
		EndIf
	EndIf

    If !_lJob
		FWMsgRun(,{|| fProcessar(_lJob) },,"Realizando a exportações das SC do Protheus para o Fluig, aguarde...")
	Else
		CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFLUIF01] Iniciado processamento das exportações das SC do Protheus para o Fluig. ")
		fProcessar(_lJob)
	Endif

	UnLockByName("ZFLUIF01",.T.,.T.)
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFLUIF01] Finalizado processamento das exportações das SC do Protheus para o Fluig.")

End Sequence

//Caso abriu o processo empresa e filial tem que fechar
If  _lAbre	
	Reset Environment
Endif

Return Nil

STATIC Function fProcessar(lJob)
	Local lOk         := .T.
	Local cQuery      := ""
	Local aSetField   := {}
	Local cMensagem   := ""
	Local cNumFluig   := ""
	Local aProblema   := {}
	Local cLoginFluig := ""
	Local aSC1        := {}

	//Obter somente as solicitação do Grupo de Aprovação com descrição que contém "FLUIG".
	cQuery := "SELECT C1_FILIAL, C1_NUM "
	cQuery += " FROM (SELECT C1_FILIAL, C1_NUM "
	cQuery += "       FROM " + RetSQLName("SC1")
	cQuery += "       WHERE  D_E_L_E_T_ <> '*' AND C1_APROV = 'B' AND C1_XFLUIG1 <> 'S' "
	cQuery += "       GROUP BY C1_FILIAL, C1_NUM) SC1, " + RetSQLName("SCR") + " SCR, " + RetSQLName("SAL") + " SAL "
	cQuery += " WHERE SCR.D_E_L_E_T_ <> '*' AND SC1.C1_FILIAL=SCR.CR_FILIAL AND SC1.C1_NUM=SCR.CR_NUM "
	cQuery += "   AND CR_TIPO='SC' AND CR_STATUS = '02' "
	cQuery += "   AND SAL.D_E_L_E_T_ <> '*' AND CR_GRUPO=AL_COD "
	cQuery += "   AND AL_DESC LIKE '%FLUIG%' "
	cQuery += " GROUP BY C1_FILIAL, C1_NUM "
	cQuery += " ORDER BY C1_FILIAL, C1_NUM "

	cQuery := ChangeQuery( cQuery )

	MPSysOpenQuery( cQuery, "TRB", aSetField )

	Begin Sequence
	
		DbSelectArea("TRB")

		If  Eof()
			//cMensagem := "Nenhum registro foi encontrado! - " + DtoC(Date())+" - "+Left(Time(),5)
			Break
		EndIf

		DBL->( DbSetOrder(1) ) //DBL_FILIAL+DBL_GRUPO+DBL_ITEM
		SC1->( DbSetOrder(1) ) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
		SCR->( DbSetOrder(1) ) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
		DBM->( DbSetOrder(3) ) //DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USAPRO+DBM_USAPOR

		DbSelectArea("TRB") 

		Do  While TRB->(!EOF())

			cXFilial := TRB->C1_FILIAL
			cNumSol  := ALLTRIM(TRB->C1_NUM)

			cFilAnt := cXFilial //Para filiais diferentes preciso mudar para executar as solicitacoes

			ConOut('ZFLUIF01: Solicitacao: '+ cNumSol)

			//Sempre posiciona na primeira alçada gerada.
			If  !( SCR->(DbSeek(xFilial("SCR")+"SC"+PadR(cNumSol,Len(CR_NUM)))) )
				ConOut('ZFLUIF01: Alcada da solicitacao nao encontrada! Solicitacao: '+ cNumSol)
				TRB->(DbSkip())
				Loop
			EndIf

			If  (SCR->CR_STATUS <> "02")
				ConOut('ZFLUIF01: Alcada da solicitacao nao esta pendente! Solicitacao: '+ cNumSol)
				TRB->(DbSkip())
				Loop
			EndIf

			If  !( u_FLUIG011(cXFilial, cNumSol, aProblema, 0, @cLoginFluig, @aSC1) )
				TRB->(DbSkip())
				Loop
			EndIf

			If  SC1->( DbRLock(Recno()) )

				cNumFluig := fIntegrar( aSC1, cLoginFluig, @aProblema )

				If  !( Empty(cNumFluig) )
					Do  While SC1->( !Eof() .And. (C1_NUM == cNumSol) .And. !( Empty(cNumFluig) ) )

						If  SC1->( DbRLock(Recno()) )
							SC1->C1_XFLUIG1 := "S"
							SC1->C1_XFLUIG2 := DtoS(Date())+"-"+Left(Time(),5)
							SC1->C1_XFLUIG3 := " "
							SC1->C1_XFLUIG4 := " "
							SC1->C1_XFLUIG5 := cNumFluig
							SC1->( MsUnLock() )
						EndIf

						SC1->( DbSkip() )
					EndDo

					ConOut("Numero Fluig: " + cNumFluig)
				Else
					SC1->( MsUnLock() )
				EndIf
				
			EndIf

			If  !( lOk )
				Break
			EndIf

			TRB->(DbSkip())

		EndDo

		TRB->( DbCloseArea() )

	End Sequence

	//Processa as solicitações excluidas, cancela no Fluig.
	cQuery := "SELECT C1_FILIAL, C1_NUM "
	cQuery += " FROM " + RetSQLName("SC1")
	cQuery += " WHERE  D_E_L_E_T_ = '*' AND C1_XFLUIG5 <> '' "
	cQuery += " GROUP BY C1_FILIAL, C1_NUM "

	cQuery := ChangeQuery( cQuery )

	MPSysOpenQuery( cQuery, "TRB", aSetField )

	Begin Sequence

		If  TRB->( Eof() )
			Break
		EndIf

		SET DELETE OFF

		DbSelectArea("TRB")

		Do  While TRB->(!EOF())

			cXFilial := TRB->C1_FILIAL
			cNumSol  := TRB->C1_NUM
  
			cFilAnt := cXFilial //Para filiais diferentes preciso mudar para executar as solicitacoes

			SC1->( DbSeek(cXFilial+cNumSol) )
 
			If  u_MT110TOK() //Cancelar no fluig pelo PE da solicitação de compras

				SC1->( DbSeek(cXFilial+cNumSol) )

				Do  While SC1->( !Eof() .And. (C1_FILIAL == cXFilial) .And. (C1_NUM == cNumSol) )

					If  SC1->( DbRLock(Recno()) )
						SC1->C1_XFLUIG5 := "    "
						SC1->( MsUnLock() )
					EndIf

					SC1->( DbSkip() )

				EndDo

			EndIf

			TRB->(DbSkip())
		EndDo

		TRB->( DbCloseArea() )

		SET DELETE ON

	End Sequence

	If  !( Empty(cMensagem) )
		If  lJob
			ConOut("ZFLUIF01: fProcessar: " + cMensagem)
		Else
			Alert(cMensagem)
		EndIf
	EndIf

Return .T.


//nRegSCR = Define se ira partir de um registro na SCR

USER Function FLUIG011(cXFilial, cNumSol, aProblema, nRegSCR, cXLoginFluig, aSC1)

	Local nA          := 0
	Local nPos        := 0
	Local lOk         := .F.
	Local nReg        := 0
	Local cMatriz1    := ""
	Local cMatriz2    := ""
	Local cMatriz3    := ""
	Local lTemDBM     := .F.
	Local nAprov      := 0
	Local cChaveDBM   := ""
	Local aAux        := {}
	Local aRegSCR     := {}

	Private cAprovs        := ""
	Private cCodAprovs     := ""
	Private cCodAprovador  := ""
	//Private aAprovador     := {{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""}}
	Private cGrupoAprov    := ""
	Private cItemAprov     := ""
	Private cNivel         := ""
	Private cItensAprov    := ""
	Private cCentroCusto   := ""
	Private cContaContabil := ""
	Private cItemContabil  := ""
	Private cClasseValor   := ""
	Private cLoginFluig    := ""
	Private nTotalItem     := 0
	Private ParamIXB       := {.T.}
	Private INCLUI         := .F.

	//Matriz 1 - Cabecalho
	cMatriz1 := ' {"tipoProcesso"        , "solicitacao"}'
	cMatriz1 += ',{"numERP"              , SC1->C1_NUM}'
	cMatriz1 += ',{"dataAbertura"        , Left(DtoC(SC1->C1_EMISSAO),6)+CValToChar(Year(SC1->C1_EMISSAO))}'
	cMatriz1 += ',{"codSolicitante"      , Alltrim(SC1->C1_USER)}'
	cMatriz1 += ',{"nomeSolicitante"     , Alltrim(SC1->C1_SOLICIT)}'
	cMatriz1 += ',{"codEmpresa"          , cEmpAnt}'
	cMatriz1 += ',{"descEmpresa"         , Alltrim(FWEmpName(cEmpAnt))}'
	cMatriz1 += ',{"codFilial"           , SC1->C1_FILIAL}'
	cMatriz1 += ',{"descFilial"          , Alltrim(FWFilName(cEmpAnt, Alltrim(SC1->C1_FILIAL)))}'
	cMatriz1 += ',{"codFornecedor"       , Alltrim(SC1->C1_FORNECE)}'
	cMatriz1 += ',{"descFornecedor"      , Alltrim(Posicione("SA2",1,xFilial("SA2")+SC1->(C1_FORNECE+C1_LOJA),"A2_NOME"))}'
	cMatriz1 += ',{"codCondPagamento"    , Alltrim(SC1->C1_CONDPAG)}'
	cMatriz1 += ',{"descCondPagamento"   , Alltrim(Posicione("SE4",1,xFilial("SE4")+SC1->C1_CONDPAG,"E4_DESCRI"))}'
	cMatriz1 += ',{"observacoesCab"      , Alltrim(SC1->C1_XOBSREQ)}'
	cMatriz1 += ',{"txtCentroCusto"      , Alltrim(cCentroCusto)}'
	cMatriz1 += ',{"txtDescCentroCusto"  , If(Empty(cCentroCusto),"",Alltrim(Posicione("CTT",1,xFilial("CTT")+cCentroCusto,"CTT_DESC01")))}'
	cMatriz1 += ',{"txtContaContabil"    , Alltrim(cContaContabil)}'
	cMatriz1 += ',{"txtDescContaContabil", If(Empty(cContaContabil),"",Alltrim(Posicione("CT1",1,xFilial("CT1")+cContaContabil,"CT1_DESC01")))}'
	cMatriz1 += ',{"txtItemContabil"     , Alltrim(cItemContabil)}'
	cMatriz1 += ',{"txtDescItemContabil" , If(Empty(cItemContabil),"",Alltrim(Posicione("CTD",1,xFilial("CTD")+cItemContabil,"CTD_DESC01")))}'
	cMatriz1 += ',{"txtClasseValor"      , Alltrim(cClasseValor)}'
	cMatriz1 += ',{"txtDescClasseValor"  , If(Empty(cClasseValor),"",Alltrim(Posicione("CTH",1,xFilial("CTH")+cClasseValor,"CTH_DESC01")))}'
	cMatriz1 += ',{"proximoAprovador"    , Alltrim(cAprovs)}'
	cMatriz1 += ',{"codigoAprovador"     , Alltrim(cCodAprovs)}'

	cMatriz1 += ',{"grupoaprovacao"      , Alltrim(cGrupoAprov)}'
	cMatriz1 += ',{"itemaprovacao"       , Alltrim(cItemAprov)}'
	cMatriz1 += ',{"valAprovacao"        , Alltrim(Str(SCR->CR_TOTAL,18,2))}'
	cMatriz1 += ',{"txtLinhaDestaque"    , Alltrim(cItensAprov)}'
	
	//Matriz 2 - Itens
	cMatriz2 := ' {"sequencia___XXX"    , SC1->C1_ITEM}'
	cMatriz2 += ',{"codProduto___XXX"   , Alltrim(SC1->C1_PRODUTO)}'
	cMatriz2 += ',{"descProduto___XXX"  , Alltrim(SC1->C1_DESCRI)}'
	cMatriz2 += ',{"unidadeMedida___XXX", SC1->C1_UM}'
	cMatriz2 += ',{"quantidade___XXX"   , CValToChar(SC1->C1_QUANT)}'
	cMatriz2 += ',{"valorUnitario___XXX", Alltrim(Str(SC1->C1_VUNIT,18,2))}'
	cMatriz2 += ',{"valorTotal___XXX"   , Alltrim(Str(SC1->(C1_QUANT*C1_VUNIT),18,2))}'
	cMatriz2 += ',{"dataEntrega___XXX"  , Left(DtoC(SC1->C1_DATPRF),6)+CValToChar(Year(SC1->C1_DATPRF))}'
	cMatriz2 += ',{"observacao___XXX"   , Alltrim(SC1->C1_OBS)}'

	//Matriz 3 - Cabecalho
	cMatriz3 := ' {"desconto"    , "0.00"}'
	cMatriz3 += ',{"despesa"     , "0.00"}'
	cMatriz3 += ',{"seguro"      , "0.00"}'
	cMatriz3 += ',{"frete"       , "0.00"}'
	cMatriz3 += ',{"totalItem"   , Alltrim(Str(nTotalItem,18,2))}'
	cMatriz3 += ',{"totalGeral"  , Alltrim(Str(nTotalItem,18,2))}'


	Begin Sequence

		If  Empty( Posicione("SC1", 1, xFilial("SC1")+cNumSol, "C1_NUM") )
			ConOut('ZFLUIF01: Solicitacao não encontrada! - Filial: '+cXFilial+' - Solicitacao: '+ cNumSol)
			Break
		EndIf

		//Obter a alçada na ordem natural pois os indices não antendem.
		If  !( u_FLUIG022(cNumSol, "SC", @aRegSCR) )
			ConOut('ZFLUIF01: Alcada da solicitacao de compras nao encontrada pela Query de registros! - Filial: '+cXFilial+' - Solicitacao: '+ cNumSol)
			Break
		EndIf
		
		nPos := 1
		
		//Processa a partir do registro passado em parametro
		//Usado para reenviar para o fluig os dados processados da alçada enviada antes
		If  (nRegSCR > 0)
			For nPos := 1 to Len(aRegSCR)
				If  (aRegSCR[nPos] == nRegSCR)
					Exit
				EndIf
			Next nPos
			
			If  (nPos > Len(aRegSCR))
				ConOut('ZFLUIF01: Registro em parametro nao encontrado na lista de registros selecionados! - Filial: '+cXFilial+' - Solicitacao: '+ cNumSol)
				Break
			EndIf
		EndIf
		
		SCR->( DbGoto(aRegSCR[nPos]) ) 

		cLoginFluig  := Alltrim(Posicione("SAK",2,xFilial("SAK")+SCR->CR_USER,"AK_LOGIN"))
		cXLoginFluig := cLoginFluig

		nA := Ascan(aProblema, {|x| x[1]==cLoginFluig})
		If  (nA > 0)
			ConOut( "ZFLUIF01: Retorno de erro do fluig: " + aProblema[nA][2] + " - Filial: "+cXFilial+" -  Solicitacao: "+ cNumSol )
			Break
		EndIf

		//Se a solicitação tem DBM
		lTemDBM := DBM->( DbSeek(xFilial("DBM")+"SC"+SCR->CR_NUM) )
		
		cGrupoAprov   := SCR->CR_GRUPO
		cItemAprov    := SCR->CR_ITGRP
		cNivel        := SCR->CR_NIVEL
		cCodAprovador := Alltrim(Posicione("SAL",4,xFilial("SAL")+cGrupoAprov+SCR->CR_USER,"AL_APROV"))

		cAprovs    := ""
		cCodAprovs := ""
		
//---------------- Obtem os aprovadores a serem enviados neste nivel da alçada --------------------
		
		nReg := SCR->( Recno() )
		
		For nA := 1 to Len(aRegSCR)
		
			SCR->( DbGoto(aRegSCR[nA]) ) //Usa a ordem natural pelo Recno e não pelo indice da SCR
		
			If  SCR->( !Eof() .And. (CR_FILIAL == cXFilial) .And. (Alltrim(CR_NUM) == Alltrim(cNumSol)) .And.;
			                 (CR_NIVEL == cNivel) .And. (CR_GRUPO == cGrupoAprov) .And. (Alltrim(CR_ITGRP) == Alltrim(cItemAprov)) )

			    ++nAprov
			    
			    cAprovs    += If(Empty(cAprovs),"",",")    + Alltrim(Posicione("SAK",2,xFilial("SAK")+SCR->CR_USER,"AK_LOGIN"))

			    //cCodAprovs += If(Empty(cCodAprovs),"",",") + Alltrim(Posicione("SAL",4,xFilial("SAL")+cGrupoAprov+SCR->CR_USER,"AL_APROV"))
				cCodAprovs += If(Empty(cCodAprovs),"",",") + Alltrim(Posicione("SAL",4,xFilial("SAL")+cGrupoAprov+SCR->CR_USER,"AL_USER"))
			    
			    If  (SAL->AL_TPLIBER == "U")
 
			    	If  (nAprov > 1)
			    		ConOut( "ZFLUIF01: Alcada esta configurada errada: Tipo Aprovacao por Usuario mesmo nivel que por Nivel ou por Documento! - Filial: "+cXFilial+" -  Solicitacao: "+ cNumSol )
			    		Break
			    	EndIf

			    	Exit  //Aprovação por usuario, envia ele sozinho
			    EndIf
			    
			EndIf
			
		Next nA
		
		SCR->( DbGoto(nReg) )

//-------------------------------------------

		cItensAprov := ""
		
		If  lTemDBM
			//Itens a serem destacados no Fluig
			cChaveDBM := xFilial("DBM")+"SC"+SCR->(CR_NUM+CR_GRUPO+CR_ITGRP+CR_APROV)
			DBM->( DbSeek(cChaveDBM) )
			
			Do  While DBM->( !( Eof() ) .And. (DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USAPRO == cChaveDBM) )
			
				cItensAprov += If(Empty(cItensAprov),"","|") + DBM->DBM_ITEM
			
				DBM->( DbSkip() )
			EndDo

			//Entidades contabeis da aprovacao
			If  DBL->( DbSeek(xFilial("DBL")+SCR->(CR_GRUPO+CR_ITGRP)) )
				cCentroCusto   := DBL->DBL_CC
				cContaContabil := DBL->DBL_CONTA
				cItemContabil  := DBL->DBL_ITEMCT
				cClasseValor   := DBL->DBL_CLVL
			EndIf
		EndIf

		aSC1 := &("{" + cMatriz1 + "}")

		nA         := 0
		nTotalItem := 0
		
		Do  While SC1->( !Eof() .And. (C1_FILIAL == xFilial("SC1")) .And. (C1_NUM == cNumSol) )

			aAux := &("{" + StrTran(cMatriz2, "XXX", CValToChar(++nA)) + "}")

			AEval(aAux, {|x| AAdd(aSC1, {x[1],x[2]}) })

			nTotalItem += SC1->(C1_QUANT*C1_VUNIT)

			SC1->( DbSkip() )
		EndDo

		SC1->( DbSeek(cXFilial+cNumSol) )  //Reposiciona

		aAux := &("{" + cMatriz3 + "}")

		AEval(aAux, {|x| AAdd(aSC1, {x[1],x[2]})})
		
		lOk := .T.
			
	End Sequence

Return lOk


STATIC Function fIntegrar(aSC1, cLoginFluig, aProblema)

	Local nA         := 0
	Local oWsdl      := TWsdlManager():New()
	Local cXML       := ""
	Local cWSRetorno := ""
	Local aItens     := {}
	Local cNumFluig  := ""
	Local cErro      := ""
	Local cAviso     := ""
	Local oXML       := nil
	Local cURLFluig  := Alltrim(GetMV("ES_XFLUIG5",,"https://caoa-fluig.totvscloud.com.br/webdesk/ECMWorkflowEngineService?wsdl"))
	Private cFUsuario   := Alltrim(GetMV("ES_XFLUIG1",,"admin"))
	Private cFSenha     := Alltrim(GetMV("ES_XFLUIG2",,"adm"))
	Private cFIdUsuario := Alltrim(GetMV("ES_XFLUIG3",,"admin"))
	Private cFEmpresa   := Alltrim(GetMV("ES_XFLUIG4",,"1"))
	Private aCardData   := AClone(aSC1)

	Begin Sequence

		cXML := h_ZFLUIF01()

		cXML := ftAcento(cXML)
		cXML := u_FAcento(cXML)

		ConOut(" ==>> cXML: ")
		ConOut(cXML)

		//Define se fará a conexão SSL com o servidor de forma anônima, ou seja, sem verificação de certificados ou chaves.
		oWsdl:lSSLInsecure := .T.
		
		If  !( oWsdl:ParseURL(cURLFluig) )
			ConOut("ZFLUIF01: Problema para fazer o parse do WSDL!")
			ConOut(oWsdl:cError)
			Break
		EndIf

		If  !( oWsdl:SetOperation( "startProcess" ) )
			ConOut("ZFLUIF01: Problema para setar o metodo startProcess()!")
			ConOut(oWsdl:cError)
			Break
		EndIf

		If  !( oWsdl:SendSoapMsg( cXML ) ) .And. !("Unknown element startProcessResponse" $ oWsdl:cError)
			ConOut("ZFLUIF01: Problema na execucao do metodo startProcess()!")
			ConOut(oWsdl:cError)
			Break
		EndIf

		// Pega a mensagem de resposta
		cWSRetorno := oWsdl:GetSoapResponse()

		oXML := XMLParser(cWSRetorno,"_",@cErro,@cAviso)

		If  !( Empty(cErro) )
			ConOut( "ZFLUIF01: Erro no XML de retorno: " + cErro )
			Break
		EndIf

		If  (ValType(oXML:_Soap_Envelope:_Soap_Body:_Ns1_startProcessResponse:_Result:_Item) <> "A")
			aItens := {oXML:_Soap_Envelope:_Soap_Body:_Ns1_startProcessResponse:_Result:_Item}
		Else
			aItens := oXML:_Soap_Envelope:_Soap_Body:_Ns1_startProcessResponse:_Result:_Item
		EndIf

		If  (aItens[1]:_Item[1]:Text == "ERROR")
			ConOut( "ZFLUIF01: Retorno de erro do fluig: " + aItens[1]:_Item[2]:Text )

			If  (Alltrim(aItens[1]:_Item[2]:Text) == "Usuário destino não foi informado!") .Or. ("Falha de login" $ aItens[1]:_Item[2]:Text)
				AAdd(aProblema, {cLoginFluig, aItens[1]:_Item[2]:Text})
			EndIf

			Break
		EndIf

		For nA := 1 to Len(aItens)
			If  (Upper(aItens[nA]:_Item[1]:Text) == "IPROCESS")
				cNumFluig := Alltrim(aItens[nA]:_Item[2]:Text)
				Exit
			EndIf
		Next nA

		If  Empty(cNumFluig)
			ConOut( "ZFLUIF01: Numero do fluig nao retornado! " )
			Break
		EndIf

	End Sequence

Return cNumFluig


//===========================================================================================
/*/{Protheus.doc} FAcento
Função para retirar a acentuação e caracteres especiais.

@param		cExpressao	Expressao para conversao
@param		cTexto		Texto convertido.

@author		Antonio C Ferreira
@since		31/03/2017
/*/
//===========================================================================================
USER Function FAcento( cExpressao )

	Local nA         := 0
	Local cAcento    := "ÇçÃãÕõÁÉÍÓÚáéíóúÂâÊêÔôÜüÛûÀàÈèÌìÒòÙùº°²Ø"
	Local cSemAcento := "CcAaOoAEIOUaeiouAaEeOoUuUuAaEeIiOoUuoo20"
	Local aAcento    := {"Ã‡","Ã§","Ãƒ","Ã£","Ã•","Ãµ","Ã" + chr(129),"Ã‰","Ã" + chr(141),"Ã“","Ãš","Ã¡","Ã©","Ã­","Ã³","Ãº","Ã‚","Ã¢","ÃŠ","Ãª","Ã”","Ã´","Ãœ","Ã¼","Ã›","Ã»","Ã€","Ã ","Ãˆ","Ã¨","ÃŒ","Ã¬","Ã’","Ã²","Ã™","Ã¹"}
	Local cChar      := ""
	Local cTexto     := ""

	For nA := 1 to Len(aAcento)
		cExpressao := StrTran(cExpressao, aAcento[nA], SubStr(cSemAcento,nA,1))
	Next nA

	For nA := 1 to Len(cExpressao)
	    cChar  := SubStr(cExpressao,nA,1)
	    nP     := At(cChar, cAcento)
	    cTexto += If(nP <= 0, cChar, SubStr(cSemAcento,nA,1))
	Next nA

Return ( cTexto )
