#INCLUDE 'PROTHEUS.CH'
#Include "Totvs.Ch"
#include 'parmtype.ch'
#include "TBICONN.CH"
#include 'TOPCONN.CH'

/*
{Protheus.doc} u_ZFLUIF03
Integracao Fluig WS CLIENT - Contratos de Parcerias.

@author  Sandro Gonçalves Ferreira
@version 1.0
@since   18/03/2022
@return  Nil  Sem retorno.
@sample
         u_ZFLUIF03()
*/

USER Function ZFLUIF03(_aParam, _aParam2, _aParam3, _aParam4 )
Local _lJob := If( IsBlind(),.T.,.F.)
Local _lAbre		:= .F.
Local _lRet
Local _nPos   
Local _cEmpresa	
Local _cFilial 
Private _opcx       := _aParam3
Private _Contrato   := _aParam4

Begin Sequence
    If _lJob
		ConOut("*************************************************************************************************************************"	+ CRLF)
		ConOut("----------- [ ZFLUIF03 ] - Inicio da funcionalidade "													                	+ CRLF)
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
	ConOut("----------- [ ZFLUIF03 ] - VERIFICANDO SE JA EXISTE PROCESSAMENTO DO JOB  "														+ CRLF)
	ConOut("*************************************************************************************************************************"	+ CRLF)

	If !LockByName("ZFLUIF03",.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 1000 ) // Para o processamento por 1 segundo
			If LockByName("ZFLUIF03",.T.,.T.)
				_lRet := .T.
			EndIf
		Next	

		If !_lRet
			If !_lJob
				MsgInfo("Já existe um processamento em execução ZFLUIF03, aguarde!")
			Else
				CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFLUIF03] Já existe um processamento em execução, aguarde!")
				ConOut("*************************************************************************************************************************"	+ CRLF)
				ConOut("----------- [ ZFLUIF03 ] - Já existe um processamento em execução ZFLUIF03 "														+ CRLF)
				ConOut("*************************************************************************************************************************"	+ CRLF)
			EndIf
			Break
		EndIf
	EndIf
    If !_lJob
		FWMsgRun(,{|| fProcessar(_lJob) },,"Realizando a exportações dos contratos de parcerias do Protheus para o Fluig, aguarde...")
	Else
		CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFLUIF03] Iniciado processamento das exportações dos contratos de parcerias do Protheus para o Fluig. ")
		fProcessar(_lJob)
	Endif
	UnLockByName("ZFLUIF03",.T.,.T.)
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFLUIF03] Finalizado processamento das exportações dos contratos de parcerias do Protheus para o Fluig.")


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
	Local aSC3        := {}
	Local cTipo       := "CP"
	Local cXFilial    := ""
	Local cNumPed     := ""
	Local cUpdate     := ""

    
	If _opcx == 4 //Alteração
		cQuery := "SELECT C3_FILIAL, C3_NUM "
		cQuery += " FROM (SELECT C3_FILIAL, C3_NUM "
		cQuery += "       FROM " + RetSQLName("SC3")
		cQuery += "       WHERE  D_E_L_E_T_ <> '*'  AND ( C3_CONAPRO = 'B' AND C3_XFLUIG5 = '"+ _Contrato + "' )  "
		cQuery += "       GROUP BY C3_FILIAL, C3_NUM) SC3, " + RetSQLName("SCR") + " SCR, " + RetSQLName("SAL") + " SAL "
		cQuery += " WHERE SCR.D_E_L_E_T_ <> '*' AND SC3.C3_FILIAL=SCR.CR_FILIAL AND SC3.C3_NUM=SCR.CR_NUM "
		cQuery += "   AND (CR_TIPO='CP') AND CR_STATUS = '02' "
		cQuery += "   AND SAL.D_E_L_E_T_ <> '*' AND CR_GRUPO=AL_COD "
		cQuery += "   AND AL_DESC LIKE '%FLUIG%' "
	else  
		//Obter somente as solicitação do Grupo de Aprovação com descrição que contém "FLUIG".
		cQuery := "SELECT C3_FILIAL, C3_NUM "
		cQuery += " FROM (SELECT C3_FILIAL, C3_NUM "
		cQuery += "       FROM " + RetSQLName("SC3")
		cQuery += "       WHERE  D_E_L_E_T_ <> '*' AND C3_CONAPRO = 'B' AND C3_XFLUIG1 <> 'S' "
		cQuery += "       GROUP BY C3_FILIAL, C3_NUM) SC3, " + RetSQLName("SCR") + " SCR, " + RetSQLName("SAL") + " SAL "
		cQuery += " WHERE SCR.D_E_L_E_T_ <> '*' AND SC3.C3_FILIAL=SCR.CR_FILIAL AND SC3.C3_NUM=SCR.CR_NUM "
		cQuery += "   AND (CR_TIPO='CP') AND CR_STATUS = '02' "
		cQuery += "   AND SAL.D_E_L_E_T_ <> '*' AND CR_GRUPO=AL_COD "
		cQuery += "   AND AL_DESC LIKE '%FLUIG%' "
    Endif


	cQuery += " GROUP BY C3_FILIAL, C3_NUM "
	cQuery += " ORDER BY C3_FILIAL, C3_NUM "

	cQuery := ChangeQuery( cQuery )

	MPSysOpenQuery( cQuery, "TRB", aSetField )

	Begin Sequence

		DbSelectArea("TRB")

		If  Eof()
			cMensagem := "Nenhum registro foi encontrado! - " + DtoC(Date())+" - "+Left(Time(),5)
			Break
		EndIf

		DBL->( DbSetOrder(1) ) //DBL_FILIAL+DBL_GRUPO+DBL_ITEM
		SC3->( DbSetOrder(1) ) //C3_FILIAL+C3_NUM+C3_ITEM
		SCR->( DbSetOrder(1) ) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
		DBM->( DbSetOrder(3) ) //DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USAPRO+DBM_USAPOR

		DbSelectArea("TRB")

		Do  While TRB->(!EOF())

			cXFilial   := TRB->C3_FILIAL
			cNumPed    := ALLTRIM(TRB->C3_NUM)
			
			cFilAnt    := cXFilial //Para filiais diferentes preciso mudar para executar os pedidos

			If  !( SCR->(DbSeek(xFilial("SCR")+cTipo+PadR(cNumPed,Len(CR_NUM)))) )
				ConOut('ZFLUIF03: Alcada do contrato de parceria nao encontrada! - Filial: '+cXFilial+' - Contrato de Parceria : '+ cNumPed)
				TRB->(DbSkip())
				Loop
			EndIf

			If  (SCR->CR_STATUS <> "02")
				ConOut('ZFLUIF03: Alcada do pedido de compras nao esta pendente! - Filial: '+cXFilial+' - Contrato de Parceria : '+ cNumPed)
				TRB->(DbSkip())
				Loop
			EndIf

			If  !( u_FLUIG034(cXFilial, cTipo, cNumPed, aProblema, 0, @cLoginFluig, @aSC3) )
				TRB->(DbSkip())
				Loop
			EndIf

			cNumFluig := fIntegrar( aSC3, cLoginFluig, @aProblema  )
       
			If  !( Empty(cNumFluig) )


			    cUpdate := " UPDATE " + RetSqlName("SC3")  + " SC3 "              + CRLF
				cUpdate += " SET SC3.C3_XFLUIG1    = 'S' , "                      + CRLF
				cUpdate += "     SC3.C3_XFLUIG2    =  '" + DtoS(Date())+"-"+Left(Time(),5) + "', "                      + CRLF
				cUpdate += "     SC3.C3_XFLUIG3    = ' ' , "                      + CRLF
				cUpdate += "     SC3.C3_XFLUIG4    = ' ' , "                      + CRLF
				cUpdate += "     SC3.C3_XFLUIG5    = '"  + cNumFluig + "'"        + CRLF          
				cUpdate += " WHERE SC3.D_E_L_E_T_  = ' ' "                        + CRLF
				cUpdate += "    AND SC3.C3_FILIAL = '" + FWxFilial("SC3") + "' "  + CRLF
				cUpdate += "    AND SC3.C3_NUM    = '" + cNumPed          + "' "  + CRLF
                TcSqlExec(cUpdate)

                  
				ConOut("Numero Fluig: " + cNumFluig)
			Endif	
		
			If  !( lOk )
				Break
			EndIf

			TRB->(DbSkip())
		EndDo

		TRB->( DbCloseArea() )
 
	End Sequence

	If  !( Empty(cMensagem) )
		If  lJob
			ConOut("ZFLUIF03: fProcessar: " + cMensagem)
		Else
			Alert(cMensagem)
		EndIf
	EndIf
     
Return .T.
  
   
//nRegSCR = Define se ira partir de um registro na SCR

USER Function FLUIG034(cXFilial, cTipo, cNumPed, aProblema, nRegSCR, cXLoginFluig, aSC3)

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
	Local cVLIBER    
	Local cQry        := " "
	Local nVLR        := 0
	Local cSZH        := .F.
		
	Private bPegaLogin     := {|| fPegaLogin() }
	//Private aAprovador     := {{"",""},{"",""},{"",""},{"",""},{"",""},{"",""},{"",""}}
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

	//Private bPegaLogin := {|| fPegaLogin() }
	//Private nTotalItem := 0
	Private nTotalDesc := 0
	Private nTotalDesp := 0
	Private nTotalSegu := 0
	Private nTotalFret := 0

    Posicione("SC3", 1, cXFilial+cNumPed, "C3_NUM")
	//Busca o valor pendentes do contrato de parceria
	cVLIBER   := GetNextAlias()
    cQry :=  " SELECT SUM(C3_TOTAL) AS nTOTAL FROM " + RetSQLName("SC3")       + " SC3B "    + CRLF
    cQry +=  " WHERE SC3B.D_E_L_E_T_  = ' ' AND SC3B.C3_DATPRF >= '" + DTOS(dDataBase) + "'" + CRLF
    cQry +=  " AND   SC3B.C3_FILIAL   =  '" +   SC3->C3_FILIAL                 + "'"         + CRLF
    cQry +=  " AND   SC3B.C3_NUM      =  '" +   SC3->C3_NUM                    + "'"         + CRLF
    cQry := ChangeQuery(cQry)
    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"cVLIBER",.T.,.T.)
         
    nVLR := cVLIBER->nTOTAL
    cVLIBER->(DbCloseArea())

  
	//Matriz 1 - Cabecalho
	cMatriz1 := ' {"tipoProcesso"     	 , "contrato"}'
	cMatriz1 += ',{"numERP"           	 , SC3->C3_NUM}'
	cMatriz1 += ',{"dataAbertura"     	 , Left(DtoC(SC3->C3_EMISSAO),6)+CValToChar(Year(SC3->C3_EMISSAO))}'
	cMatriz1 += ',{"codSolicitante"   	 , Eval(bPegaLogin)}'
	cMatriz1 += ',{"nomeSolicitante"  	 , Alltrim(UsrRetName(SC3->C3_USER))}'
	cMatriz1 += ',{"codEmpresa"       	 , cEmpAnt}'
	cMatriz1 += ',{"descEmpresa"      	 , Alltrim(FWEmpName(cEmpAnt))}'
	cMatriz1 += ',{"codFilial"        	 , SC3->C3_FILIAL}'
	cMatriz1 += ',{"descFilial"       	 , Alltrim(FWFilName(cEmpAnt, Alltrim(SC3->C3_FILIAL)))}'
	cMatriz1 += ',{"codFornecedor"    	 , SC3->C3_FORNECE}'
	cMatriz1 += ',{"descFornecedor"   	 , Alltrim(Posicione("SA2",1,xFilial("SA2")+SC3->(C3_FORNECE+C3_LOJA),"A2_NOME"))}'
	cMatriz1 += ',{"codCondPagamento" 	 , Alltrim(SC3->C3_COND)}'
	cMatriz1 += ',{"descCondPagamento"	 , Alltrim(Posicione("SE4",1,xFilial("SE4")+SC3->C3_COND,"E4_DESCRI"))}'
	//cMatriz1 += ',{"observacoesCab"   	 , Alltrim(SC7->C7_OBS)}'
	cMatriz1 += ',{"observacoesCab"   	 , Alltrim(SC3->C3_XOBSCOP)}'
	cMatriz1 += ',{"observacoesComp"   	 , Alltrim(SC3->C3_XOBSREQ)}'


    If SZH->( dbseek ( xFilial("SZH") + "CP" + SC3->C3_NUM ) )
		While !SZH->(EOF()) .and. (SZH->ZH_ORIGEM = "CP" .AND. SZH->ZH_DOCTO = SC3->C3_NUM)
	 	   IF SZH->ZH_OPER <> "I"
			  cMatriz1 += ',{"observacoesComp"   	 , Alltrim(SZH->ZH_MOTIVO)}'
			  cSZH := .T.
		   ENDIF
		   SZH->(DbSkip())
		END
		IF cSZH
		   SZH->(DbSkip(-1))
		ENDIF
	ENDIF


	//cMatriz1 += ',{"moeda"   	         , CValToChar(SC3->C3_MOEDA)}'
    cMatriz1 += ',{"moeda"   	         , "Real"}'
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
	//cMatriz1 += ',{"valAprovacao"        , Alltrim(Str(SCR->CR_TOTAL,18,2))}'
	cMatriz1 += ',{"valAprovacao"        , Alltrim(Str(nVLR,18,2))}'
	cMatriz1 += ',{"txtLinhaDestaque"    , Alltrim(cItensAprov)}'

	//Matriz 2 - Itens
	cMatriz2 := ' {"sequencia___XXX"    , SC3->C3_ITEM}'
	cMatriz2 += ',{"codProduto___XXX"   , Alltrim(SC3->C3_PRODUTO)}'
	cMatriz2 += ',{"descProduto___XXX"  , Alltrim(SC3->C3_XDESC)}'
	cMatriz2 += ',{"unidadeMedida___XXX", SC3->C3_UM}'
	cMatriz2 += ',{"quantidade___XXX"   , CValToChar(SC3->C3_QUANT)}'
	cMatriz2 += ',{"valorUnitario___XXX", Alltrim(Str(SC3->C3_PRECO,18,2))}'
	cMatriz2 += ',{"valorTotal___XXX"   , Alltrim(Str(SC3->C3_TOTAL,18,2))}'
	cMatriz2 += ',{"dataEntrega___XXX"  , Left(DtoC(SC3->C3_DATPRF),6)+CValToChar(Year(SC3->C3_DATPRF))}'
	cMatriz2 += ',{"observacao___XXX"   , Alltrim(SC3->C3_OBS)}'

	//Matriz 3 - Cabecalho
	cMatriz3 := ' {"desconto"    , Alltrim(Str(nTotalDesc,18,2))}'
	cMatriz3 += ',{"despesa"     , Alltrim(Str(nTotalDesp,18,2))}'
	cMatriz3 += ',{"seguro"      , Alltrim(Str(nTotalSegu,18,2))}'
	cMatriz3 += ',{"frete"       , Alltrim(Str(nTotalFret,18,2))}'
	cMatriz3 += ',{"totalItem"   , Alltrim(Str(nTotalItem,18,2))}'
	cMatriz3 += ',{"totalGeral"  , Alltrim(Str(nTotalItem-nTotalDesc,18,2))}'

	Begin Sequence

		If  Empty( Posicione("SC3", 1, cXFilial+cNumPed, "C3_NUM") )
			ConOut('ZFLUIF03: contrato de parceria não encontrado! - Filial: '+cXFilial+' - Contrato de Parceria: '+ cNumPed)
			Break
		EndIf

		If  !( u_FLUIG033(cNumPed, cTipo, @aRegSCR) )
			ConOut('ZFLUIF03: Alcada do contrato de parceria nao encontrada pela Query de registros! - Filial: '+cXFilial+' - Contrato de Parceria: '+ cNumPed)
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
				ConOut('ZFLUIF03: Registro em parametro nao encontrado na lista de registros selecionados! - Filial: '+cXFilial+' - Contrato de Parceria: '+ cNumPed)
				Break
			EndIf
		EndIf
		
		SCR->( DbGoto(aRegSCR[nPos]) ) 

		cLoginFluig  := Alltrim(Posicione("SAK",2,xFilial("SAK")+SCR->CR_USER,"AK_LOGIN"))
		cXLoginFluig := cLoginFluig

		nA := Ascan(aProblema, {|x| x[1]==cLoginFluig})
		If  (nA > 0)
			ConOut( "ZFLUIF03: Retorno de erro do fluig: " + aProblema[nA][2] + " - Filial: "+cXFilial+" -  Contrato de Parceria: "+ cNumPed )
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
			    //cCodAprovs += If(Empty(cCodAprovs),"",",") + Alltrim(Posicione("SAL",4,xFilial("SAL")+cGrupoAprov+SCR->CR_USER,"AL_APROV"))
				cCodAprovs += If(Empty(cCodAprovs),"",",") + Alltrim(Posicione("SAL",4,xFilial("SAL")+cGrupoAprov+SCR->CR_USER,"AL_USER"))
			    
			    If  (SAL->AL_TPLIBER == "U")

			    	If  (nAprov > 1)
			    		ConOut( "ZFLUIF03: Alcada esta configurada errada: Tipo Aprovacao por Usuario mesmo nivel que por Nivel ou por Documento! - Filial: "+cXFilial+" -  Contrato de Parceria: "+ cNumPed )
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

		aSC3 := &("{" + cMatriz1 + "}")

		nA         := 0
		nTotalItem := 0
		nTotalDesc := 0
		nTotalDesp := 0
		nTotalSegu := 0
		nTotalFret := 0

		Do  While SC3->( !Eof() .And. (C3_NUM == cNumPed) )

			aAux := &("{" + StrTran(cMatriz2, "XXX", CValToChar(++nA)) + "}")

			AEval(aAux, {|x| AAdd(aSC3, {x[1],x[2]}) })

			nTotalItem += SC3->C3_TOTAL
			nTotalDesc += 0  //SC7->C7_VLDESC
			nTotalDesp += 0  //SC7->C7_DESPESA
			nTotalSegu += 0  //SC7->C7_SEGURO
			nTotalFret += SC3->C3_FRETE

			SC3->( DbSkip() )
		EndDo

		SC3->( DbSeek(cXFilial+cNumPed) )  //Reposiciona

		aAux := &("{" + cMatriz3 + "}")

		AEval(aAux, {|x| AAdd(aSC3, {x[1],x[2]})})
		
		lOk  := .T.
	
	End Sequence

Return lOk


/*
{Protheus.doc} u_FLUIG033
Obtem os registros da alçada na ordem natural.

@author  Sandro Ferreira
@version 1.0
@since   18/03/2022
@return  Nil  Sem retorno.
@sample
         u_FLUIG033(cNumPed, cTipo, @aRegSCR)
*/

USER Function FLUIG033(cNumPed, cTipo, aRegSCR)

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



STATIC Function fIntegrar(aSC3, cLoginFluig, aProblema)

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
	Private aCardData   := AClone(aSC3)


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
			ConOut("ZFLUIF03: Problema para fazer o parse do WSDL!")
			ConOut(oWsdl:cError)
			Break
		EndIf

		If  !( oWsdl:SetOperation( "startProcess" ) )
			ConOut("ZFLUIF03: Problema para setar o metodo startProcess()!")
			ConOut(oWsdl:cError)
			Break
		EndIf

		If  !( oWsdl:SendSoapMsg( cXML ) ) .And. !("Unknown element startProcessResponse" $ oWsdl:cError)
			ConOut("ZFLUIF03: Problema na execucao do metodo startProcess()!")
			ConOut(oWsdl:cError)
			Break
		EndIf

		// Pega a mensagem de resposta
		cWSRetorno := oWsdl:GetSoapResponse()

		//ConOut("cWSRetorno")
		//ConOut(cWSRetorno)

		oXML := XMLParser(cWSRetorno,"_",@cErro,@cAviso)

		If  !( Empty(cErro) )
			ConOut( "ZFLUIF03: Erro no XML de retorno: " + cErro )
			Break
		EndIf

		If  (ValType(oXML:_Soap_Envelope:_Soap_Body:_Ns1_startProcessResponse:_Result:_Item) <> "A")
			aItens := {oXML:_Soap_Envelope:_Soap_Body:_Ns1_startProcessResponse:_Result:_Item}
		Else
			aItens := oXML:_Soap_Envelope:_Soap_Body:_Ns1_startProcessResponse:_Result:_Item
		EndIf

		If  ("ERROR" $ aItens[1]:_Item[1]:Text)
			ConOut( "ZFLUIF03: Retorno de erro do fluig: " + aItens[1]:_Item[2]:Text )

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
			ConOut( "ZFLUIF03: Numero do fluig nao retornado! " )
			Break
		EndIf

	End Sequence

Return cNumFluig


STATIC Function fPegaLogin()

	Local cCodigo := ""
	Local aRetUsu := {}

	PswOrder(1)   // Ordem por Identificacao do Usuario no Sistema

	If  PswSeek(SC3->C3_USER)
		aRetUsu := PswRet()  // Retorna todos os dados do usuário.
		cCodigo := aRetUsu[1][2]
	EndIf

Return cCodigo
