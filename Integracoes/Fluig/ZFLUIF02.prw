#INCLUDE 'PROTHEUS.CH'
#Include "Totvs.Ch"
#include 'parmtype.ch'
#include "TBICONN.CH"
#include 'TOPCONN.CH'

/*
{Protheus.doc} u_ZFLUIF02
Integracao Fluig WS CLIENT - pedido de compras.

@author  Sandro Gonçalves Ferreira
@version 1.0
@since   18/02/2022
@return  Nil  Sem retorno.
@sample
         u_ZFLUIF02()
*/

USER Function ZFLUIF02(_aParam)
Local _lJob := If( IsBlind(),.T.,.F.)
Local _lAbre		:= .F.
Local _lRet
Local _nPos   
Local _cEmpresa	
Local _cFilial 
 
Begin Sequence
    If _lJob
		ConOut("*************************************************************************************************************************"	+ CRLF)
		ConOut("----------- [ ZFLUIF02 ] - Inicio da funcionalidade "													                	+ CRLF)
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
	ConOut("----------- [ ZFLUIF02 ] - VERIFICANDO SE JA EXISTE PROCESSAMENTO DO JOB  "														+ CRLF)
	ConOut("*************************************************************************************************************************"	+ CRLF)

	If !LockByName("ZFLUIF02",.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 1000 ) // Para o processamento por 1 segundo
			If LockByName("ZFLUIF02",.T.,.T.)
				_lRet := .T.
			EndIf
		Next	

		If !_lRet
			If !_lJob
				MsgInfo("Já existe um processamento em execução rZFLUIF02UIG020, aguarde!")
			Else
				CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFLUIF02] Já existe um processamento em execução, aguarde!")
				ConOut("*************************************************************************************************************************"	+ CRLF)
				ConOut("----------- [ ZFLUIF02 ] - Já existe um processamento em execução rZFLUIF02UIG020 "														+ CRLF)
				ConOut("*************************************************************************************************************************"	+ CRLF)
			EndIf
			Break
		EndIf
	EndIf
    If !_lJob
		FWMsgRun(,{|| fProcessar(_lJob) },,"Realizando a exportações dos pedidos de compras do Protheus para o Fluig, aguarde...")
	Else
		CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFLUIF02] Iniciado processamento das exportações dos pedidos de compras do Protheus para o Fluig. ")
		fProcessar(_lJob)
	Endif
	UnLockByName("ZFLUIF02",.T.,.T.)
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFLUIF02] Finalizado processamento das exportações dos pedidos de compras do Protheus para o Fluig.")


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
	Local cNumFluig   := ""
	Local cMensagem   := ""
	Local aProblema   := {}
	Local cLoginFluig := ""
	Local aSC7        := {}
	Local cTipo       := "PC"
	Local cXFilial    := ""
	Local cNumPed     := ""

	//Obter somente as solicitação do Grupo de Aprovação com descrição que contém "FLUIG".
	cQuery := "SELECT C7_FILIAL, C7_NUM "
	cQuery += " FROM (SELECT C7_FILIAL, C7_NUM "
	cQuery += "       FROM " + RetSQLName("SC7")
	cQuery += "       WHERE  D_E_L_E_T_ <> '*' AND C7_CONAPRO = 'B' AND C7_XFLUIG1 <> 'S' "
	cQuery += "       GROUP BY C7_FILIAL, C7_NUM) SC7, " + RetSQLName("SCR") + " SCR, " + RetSQLName("SAL") + " SAL "
	cQuery += " WHERE SCR.D_E_L_E_T_ <> '*' AND SC7.C7_FILIAL=SCR.CR_FILIAL AND SC7.C7_NUM=SCR.CR_NUM "
	cQuery += "   AND (CR_TIPO='PC' OR CR_TIPO='IP') AND CR_STATUS = '02' "
	cQuery += "   AND SAL.D_E_L_E_T_ <> '*' AND CR_GRUPO=AL_COD "
    cQuery += "   AND AL_DESC LIKE '%FLUIG%' "
	cQuery += " GROUP BY C7_FILIAL, C7_NUM "
	cQuery += " ORDER BY C7_FILIAL, C7_NUM "

	cQuery := ChangeQuery( cQuery )

	MPSysOpenQuery( cQuery, "TRB", aSetField )

	Begin Sequence

		DbSelectArea("TRB")

		If  Eof()
			Break
		EndIf

		DBL->( DbSetOrder(1) ) //DBL_FILIAL+DBL_GRUPO+DBL_ITEM
		SC7->( DbSetOrder(1) ) //C7_FILIAL+C7_NUM+C7_ITEM+C7_ITEMGRD
		SCR->( DbSetOrder(1) ) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
		DBM->( DbSetOrder(3) ) //DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USAPRO+DBM_USAPOR

		DbSelectArea("TRB")

		Do  While TRB->(!EOF())

			cXFilial   := TRB->C7_FILIAL
			cNumPed    := ALLTRIM(TRB->C7_NUM)
			
			cFilAnt    := cXFilial //Para filiais diferentes preciso mudar para executar os pedidos

			If  !( SCR->(DbSeek(xFilial("SCR")+cTipo+PadR(cNumPed,Len(CR_NUM)))) )
				cTipo := "IP"
				If  !( SCR->(DbSeek(xFilial("SCR")+cTipo+PadR(cNumPed,Len(CR_NUM)))) )
					ConOut('ZFLUIF02: Alcada do pedido de compras nao encontrada! - Filial: '+cXFilial+' - Solicitacao: '+ cNumPed)
					TRB->(DbSkip())
					Loop
				EndIf
			EndIf

			If  (SCR->CR_STATUS <> "02")
				ConOut('ZFLUIF02: Alcada do pedido de compras nao esta pendente! - Filial: '+cXFilial+' - Solicitacao: '+ cNumPed)
				TRB->(DbSkip())
				Loop
			EndIf

			If  !( u_FLUIG021(cXFilial, cTipo, cNumPed, aProblema, 0, @cLoginFluig, @aSC7) )
				TRB->(DbSkip())
				Loop
			EndIf

			If  SC7->( DbRLock(Recno()) )

				cNumFluig := fIntegrar( aSC7, cLoginFluig, @aProblema  )

				Do  While SC7->( !Eof() .And. (C7_NUM == cNumPed) .And. !( Empty(cNumFluig) ))

					If  SC7->( DbRLock(Recno()) )
						SC7->C7_XFLUIG1 := "S"
						SC7->C7_XFLUIG2 := DtoS(Date())+"-"+Left(Time(),5)
						SC7->C7_XFLUIG3 := " "
						SC7->C7_XFLUIG4 := " "
						SC7->C7_XFLUIG5 := cNumFluig
						SC7->( MsUnLock() )
					EndIf

					SC7->( DbSkip() )
				EndDo

				ConOut("Numero Fluig: " + cNumFluig)
			Else
				SC7->( MsUnLock() )
			EndIf
			
			If  !( lOk )
				Break
			EndIf

			TRB->(DbSkip())
		EndDo

		TRB->( DbCloseArea() )

	End Sequence

	If  !( Empty(cMensagem) )
		If  lJob
			ConOut("ZFLUIF02: fProcessar: " + cMensagem)
		Else
			Alert(cMensagem)
		EndIf
	EndIf

Return .T.


//nRegSCR = Define se ira partir de um registro na SCR

USER Function FLUIG021(cXFilial, cTipo, cNumPed, aProblema, nRegSCR, cXLoginFluig, aSC7)

	Local lOk         := .F.
	Local nPos        := 0
	Local cMatriz1    := ""
	Local cMatriz2    := ""
	Local cMatriz3    := ""
	Local nAprov      := 0
	Local lTemDBM     := .F.
	Local cChaveDBM   := ""
	Local aAux        := {}
	Local aRegSCR     := {} 
	Local nA          := 0
	Local cSZH        := .F.
	Local cObs        := ""
	Private bPegaLogin     := {|| fPegaLogin() }
	Private cAprovs        := ""
	Private cCodAprovs     := ""
	Private cNivel         := ""
	Private cLoginFluig    := ""
	Private cCodAprovador  := ""
	Private cGrupoAprov    := ""
	Private cItemAprov     := ""
	Private cItensAprov    := ""
	Private cCentroCusto   := ""
	Private cContaContabil := ""
	Private cItemContabil  := ""
	Private cClasseValor   := ""
	Private nTotalItem     := 0
	Private ParamIXB       := {.T.}
	Private INCLUI         := .F.
	Private nTotalDesc     := 0
	Private nTotalDesp     := 0
	Private nTotalSegu     := 0
	Private nTotalFret     := 0

	Posicione("SC7", 1, cXFilial+cNumPed, "C7_NUM")
	//Matriz 1 - Cabecalho
	cMatriz1 := ' {"tipoProcesso"     	 , "pedido"}'
	cMatriz1 += ',{"numERP"           	 , SC7->C7_NUM}'
	cMatriz1 += ',{"dataAbertura"     	 , Left(DtoC(SC7->C7_EMISSAO),6)+CValToChar(Year(SC7->C7_EMISSAO))}'
	cMatriz1 += ',{"codSolicitante"   	 , Eval(bPegaLogin)}'
	//cMatriz1 += ',{"codSolicitante"   	 , SC7->C7_USER}'
	cMatriz1 += ',{"nomeSolicitante"  	 , Alltrim(UsrRetName(SC7->C7_USER))}'
	cMatriz1 += ',{"codEmpresa"       	 , cEmpAnt}'
	cMatriz1 += ',{"descEmpresa"      	 , Alltrim(FWEmpName(cEmpAnt))}'
	cMatriz1 += ',{"codFilial"        	 , SC7->C7_FILIAL}'
	cMatriz1 += ',{"descFilial"       	 , Alltrim(FWFilName(cEmpAnt, Alltrim(SC7->C7_FILIAL)))}'
	cMatriz1 += ',{"codFornecedor"    	 , SC7->C7_FORNECE}'
	cMatriz1 += ',{"descFornecedor"   	 , Alltrim(Posicione("SA2",1,xFilial("SA2")+SC7->(C7_FORNECE+C7_LOJA),"A2_NOME"))}'
	cMatriz1 += ',{"codCondPagamento" 	 , Alltrim(SC7->C7_COND)}'
	cMatriz1 += ',{"descCondPagamento"	 , Alltrim(Posicione("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI"))}'
	cMatriz1 += ',{"observacoesCab"   	 , Alltrim(SC7->C7_XOBSCOM)}'
	cMatriz1 += ',{"observacoesComp"   	 , Alltrim(SC7->C7_XOBSTST)}'
	//Busca informações da trilha de segurança
    If SZH->( dbseek ( xFilial("SZH") + "PC" + SC7->C7_NUM ) )
		While !SZH->(EOF()) .and. (SZH->ZH_ORIGEM = "PC" .AND. SZH->ZH_DOCTO = SC7->C7_NUM)
	 	   IF SZH->ZH_OPER <> "I"

			  cMatriz1 += ',{"trilhaseguranca"   	 , Alltrim(SZH->ZH_MOTIVO)}'
			  cSZH := .T.
		   ENDIF
		   SZH->(DbSkip())
		END
		IF cSZH
		   SZH->(DbSkip(-1))
		ENDIF
	ENDIF

	IF SC7->C7_ORIGEM = 'EICPO400'
	   //Busca IMPORTADORES / CONSIGNATARIOS
	   SW2->(DBSeek(xFilial("SW2") + SC7->C7_PO_EIC))
   	   SYF->(DBSeek(xFilial("SYF") + SW2->W2_MOEDA))
	   cMatriz1 += ',{"moeda"   	         , SYF->YF_DESC_SI }'
	ELSE
    	//cMatriz1 += ',{"moeda"   	         , CValToChar(SC7->C7_MOEDA)}'
		cMatriz1 += ',{"moeda"   	         , "Real"}'
	ENDIF
	cMatriz1 += ',{"txtCentroCusto"      , Alltrim(cCentroCusto)}'
	cMatriz1 += ',{"txtDescCentroCusto"  , If(Empty(cCentroCusto),"",Alltrim(Posicione("CTT",1,xFilial("CTT")+cCentroCusto,"CTT_DESC01")))}'
	cMatriz1 += ',{"txtContaContabil"    , Alltrim(cContaContabil)}'
	cMatriz1 += ',{"txtDescContaContabil", If(Empty(cContaContabil),"",Alltrim(Posicione("CT1",1,xFilial("CT1")+cContaContabil,"CT1_DESC01")))}'
	cMatriz1 += ',{"txtItemContabil"     , Alltrim(cItemContabil)}'
	cMatriz1 += ',{"txtDescItemContabil" , If(Empty(cItemContabil),"",Alltrim(Posicione("CTD",1,xFilial("CTD")+cItemContabil,"CTD_DESC01")))}'
	cMatriz1 += ',{"txtClasseValor"      , Alltrim(cClasseValor)}'
	cMatriz1 += ',{"txtDescClasseValor"  , If(Empty(cClasseValor),"",Alltrim(Posicione("CTH",1,xFilial("CTH")+cClasseValor,"CTH_DESC01")))}'
	cMatriz1 += ',{"proximoAprovador" 	 , Alltrim(cAprovs)}'
	cMatriz1 += ',{"codigoAprovador"     , Alltrim(cCodAprovs)}'
	cMatriz1 += ',{"grupoaprovacao"      , Alltrim(cGrupoAprov)}'
	cMatriz1 += ',{"itemaprovacao"       , Alltrim(cItemAprov)}'
	IF SC7->C7_ORIGEM = "EICPO400"
       cMatriz1 += ',{"valAprovacao"        , Alltrim(Str((SCR->CR_TOTAL * SCR->CR_TXMOEDA),18,2))}'
	ELSE
	   cMatriz1 += ',{"valAprovacao"        , Alltrim(Str(SCR->CR_TOTAL,18,2))}'
	ENDIF
	cMatriz1 += ',{"txtLinhaDestaque"    , Alltrim(cItensAprov)}'

	//Matriz 2 - Itens
	cMatriz2 := ' {"sequencia___XXX"    , SC7->C7_ITEM}'
	cMatriz2 += ',{"codProduto___XXX"   , Alltrim(SC7->C7_PRODUTO)}'
	cMatriz2 += ',{"descProduto___XXX"  , Alltrim(SC7->C7_DESCRI)}'
	cMatriz2 += ',{"unidadeMedida___XXX", SC7->C7_UM}'
	cMatriz2 += ',{"quantidade___XXX"   , CValToChar(SC7->C7_QUANT)}'
	cMatriz2 += ',{"valorUnitario___XXX", Alltrim(Str(SC7->C7_PRECO,18,2))}'
	cMatriz2 += ',{"valorTotal___XXX"   , Alltrim(Str(SC7->C7_TOTAL,18,2))}'
	cMatriz2 += ',{"dataEntrega___XXX"  , Left(DtoC(SC7->C7_DATPRF),6)+CValToChar(Year(SC7->C7_DATPRF))}'
	cMatriz2 += ',{"observacao___XXX"   , Alltrim(SC7->C7_OBS)}'

	//Matriz 3 - Cabecalho
	cMatriz3 := ' {"desconto"    , Alltrim(Str(nTotalDesc,18,2))}'
	cMatriz3 += ',{"despesa"     , Alltrim(Str(nTotalDesp,18,2))}'
	cMatriz3 += ',{"seguro"      , Alltrim(Str(nTotalSegu,18,2))}'
	cMatriz3 += ',{"frete"       , Alltrim(Str(nTotalFret,18,2))}'
	cMatriz3 += ',{"totalItem"   , Alltrim(Str(nTotalItem,18,2))}'
	cMatriz3 += ',{"totalGeral"  , Alltrim(Str(nTotalItem-nTotalDesc,18,2))}'

	Begin Sequence

		If  Empty( Posicione("SC7", 1, cXFilial+cNumPed, "C7_NUM") )
			ConOut('ZFLUIF02: Pedido de Compras não encontrado! - Filial: '+cXFilial+' - Pedido: '+ cNumPed)
			Break
		EndIf

		If  !( u_FLUIG022(cNumPed, cTipo, @aRegSCR) )
			ConOut('ZFLUIF02: Alcada do pedido de compras nao encontrada pela Query de registros! - Filial: '+cXFilial+' - Pedido: '+ cNumPed)
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
				ConOut('ZFLUIF02: Registro em parametro nao encontrado na lista de registros selecionados! - Filial: '+cXFilial+' - Pedido: '+ cNumPed)
				Break
			EndIf
		EndIf
		
		SCR->( DbGoto(aRegSCR[nPos]) ) 

		cLoginFluig  := Alltrim(Posicione("SAK",2,xFilial("SAK")+SCR->CR_USER,"AK_LOGIN"))
		cXLoginFluig := cLoginFluig

		nA := Ascan(aProblema, {|x| x[1]==cLoginFluig})
		If  (nA > 0)
			ConOut( "ZFLUIF02: Retorno de erro do fluig: " + aProblema[nA][2] + " - Filial: "+cXFilial+" -  Pedido: "+ cNumPed )
			Break
		EndIf

		//Se a solicitação tem DBM
		lTemDBM := DBM->( DbSeek(xFilial("DBM")+cTipo+SCR->CR_NUM) )

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
		
			If SCR->( !Eof() .And. (CR_FILIAL == cXFilial) .And. (Alltrim(CR_NUM) == Alltrim(cNumPed)) .And.;
			                 (CR_NIVEL == cNivel) .And. (CR_GRUPO == cGrupoAprov) .And. (Alltrim(CR_ITGRP) == Alltrim(cItemAprov)) )

			    ++nAprov
			    
			    cAprovs    += If(Empty(cAprovs),"",",")    + Alltrim(Posicione("SAK",2,xFilial("SAK")+SCR->CR_USER,"AK_LOGIN"))
				cCodAprovs += If(Empty(cCodAprovs),"",",") + Alltrim(Posicione("SAL",4,xFilial("SAL")+cGrupoAprov+SCR->CR_USER,"AL_USER"))
			    
			    If  (SAL->AL_TPLIBER == "U")

			    	If  (nAprov > 1)
			    		ConOut( "ZFLUIF02: Alcada esta configurada errada: Tipo Aprovacao por Usuario mesmo nivel que por Nivel ou por Documento! - Filial: "+cXFilial+" -  Pedido: "+ cNumPed )
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
			cChaveDBM := xFilial("DBM")+cTipo+SCR->(CR_NUM+CR_GRUPO+CR_ITGRP+CR_APROV)
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

		IF SC7->C7_ORIGEM = "EICPO400"
			cMatriz1 += ',{"observacoesComp"   	 , Alltrim(SC7->C7_XOBSTST)}'
	        cMatriz1 += ',{"moeda"   	         , SYF->YF_DESC_SI }'
		ENDIF

		aSC7 := &("{" + cMatriz1 + "}")

		nA         := 0
		nTotalItem := 0
		nTotalDesc := 0
		nTotalDesp := 0
		nTotalSegu := 0
		nTotalFret := 0

		Do  While SC7->( !Eof() .And. (C7_NUM == cNumPed) )

			aAux := &("{" + StrTran(cMatriz2, "XXX", CValToChar(++nA)) + "}")

			AEval(aAux, {|x| AAdd(aSC7, {x[1],x[2]}) })

			nTotalItem += SC7->C7_TOTAL
			nTotalDesc += SC7->C7_VLDESC
			nTotalDesp += SC7->C7_DESPESA
			nTotalSegu += SC7->C7_SEGURO
			nTotalFret += SC7->C7_FRETE

			SC7->( DbSkip() )
		EndDo

		SC7->( DbSeek(cXFilial+cNumPed) )  //Reposiciona

		aAux := &("{" + cMatriz3 + "}")

		AEval(aAux, {|x| AAdd(aSC7, {x[1],x[2]})})
		
		lOk  := .T.
	
	End Sequence

Return lOk


/*
{Protheus.doc} u_FLUIG022
Obtem os registros da alçada na ordem natural.

@author  Antonio Carlos Ferreira
@version 1.0
@since   01/07/2019
@return  Nil  Sem retorno.
@sample
         u_FLUIG022(cNumPed, cTipo, @aRegSCR)
*/

USER Function FLUIG022(cNumPed, cTipo, aRegSCR)

	Local cQuery    := ""
	Local aSetField := {}
	Local lOk       := .F.
	
	Begin Sequence

		//Obter a alçada na ordem natural pois os indices não antendem.
		cQuery := "SELECT R_E_C_N_O_ AS REG "
		cQuery += "       FROM " + RetSQLName("SCR")
		cQuery += "       WHERE D_E_L_E_T_ <> '*' AND CR_FILIAL="+ ValToSQL(xFilial("SCR")) +" AND CR_TIPO="+ ValToSQL(cTipo) +" AND CR_NUM="+ ValToSQL(cNumPed)
		cQuery += "       ORDER BY CR_NIVEL, CR_GRUPO, CR_ITGRP "  //R_E_C_N_O_
	
		cQuery := ChangeQuery( cQuery )
	
		MPSysOpenQuery( cQuery, "TRBSCR", aSetField )
		
		If  TRBSCR->( Eof() )
			Break
		EndIf
		
		aRegSCR := {}
		
		Do  While TRBSCR->( !Eof() )
			AAdd(aRegSCR, TRBSCR->REG)
		
			TRBSCR->(DbSkip())
		EndDo
		
		lOk := .T.

	End Sequence
	
	TRBSCR->( DbCloseArea() )

Return lOk



STATIC Function fIntegrar(aSC7, cLoginFluig, aProblema)

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
	Private cFEmpresa   := Alltrim(GetMV("ES_XFLUIG4",,"1"))
	Private cFIdUsuario := Alltrim(GetMV("ES_XFLUIG3",,"admin"))
	Private aCardData   := AClone(aSC7)


    cXML := h_ZFLUIF01() //Reutilizar o da solicitacao

	Begin Sequence

		//cXML := h_ZFLUIF01() //Reutilizar o da solicitacao

		cXML := StrTran(cXML, "&", "&amp;")

		cXML := ftAcento(cXML)
		cXML := u_FAcento(cXML)
		
		ConOut(" ==>> cXML: ")
		ConOut(cXML)

		//Define se fará a conexão SSL com o servidor de forma anônima, ou seja, sem verificação de certificados ou chaves.
		oWsdl:lSSLInsecure := .T.
		
		If  !( oWsdl:ParseURL(cURLFluig) )
			ConOut("ZFLUIF02: Problema para fazer o parse do WSDL!")
			ConOut(oWsdl:cError)
			Break
		EndIf

		If  !( oWsdl:SetOperation( "startProcess" ) )
			ConOut("ZFLUIF02: Problema para setar o metodo startProcess()!")
			ConOut(oWsdl:cError)
			Break
		EndIf

		If  !( oWsdl:SendSoapMsg( cXML ) ) .And. !("Unknown element startProcessResponse" $ oWsdl:cError)
			ConOut("ZFLUIF02: Problema na execucao do metodo startProcess()!")
			ConOut(oWsdl:cError)
			Break
		EndIf

		// Pega a mensagem de resposta
		cWSRetorno := oWsdl:GetSoapResponse()

		//ConOut("cWSRetorno")
		//ConOut(cWSRetorno)

		oXML := XMLParser(cWSRetorno,"_",@cErro,@cAviso)

		If  !( Empty(cErro) )
			ConOut( "ZFLUIF02: Erro no XML de retorno: " + cErro )
			Break
		EndIf

		If  (ValType(oXML:_Soap_Envelope:_Soap_Body:_Ns1_startProcessResponse:_Result:_Item) <> "A")
			aItens := {oXML:_Soap_Envelope:_Soap_Body:_Ns1_startProcessResponse:_Result:_Item}
		Else
			aItens := oXML:_Soap_Envelope:_Soap_Body:_Ns1_startProcessResponse:_Result:_Item
		EndIf

		If  ("ERROR" $ aItens[1]:_Item[1]:Text)
			ConOut( "ZFLUIF02: Retorno de erro do fluig: " + aItens[1]:_Item[2]:Text )

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
			ConOut( "ZFLUIF02: Numero do fluig nao retornado! " )
			Break
		EndIf

	End Sequence

Return cNumFluig


STATIC Function fPegaLogin()

	Local cCodigo := ""
	Local aRetUsu := {}

	PswOrder(1)   // Ordem por Identificacao do Usuario no Sistema

	If  PswSeek(SC7->C7_USER)
		aRetUsu := PswRet()  // Retorna todos os dados do usuário.
		cCodigo := aRetUsu[1][2]
	EndIf

Return cCodigo
