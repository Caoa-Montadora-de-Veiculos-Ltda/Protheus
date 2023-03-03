#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RESTFUL.CH"

 
/*
{Protheus.doc} u_ZWSR002
Método WS REST de aprovação da alçada de solicitação e pedido de compras.

@author  Sandro Gonçalves Ferreira
@version 1.0
@since   18/02/2022
@return  Nil  Sem retorno.
@sample
         (POS) https://abdhdu-prd-protheus.totvscloud.com.br:34022/rest/01/mtaprovacaocompras
         (HEADER)	Content-Type: "application/json"
         			Autorization: "Basic Rmx1aWdAUHJvdGhldXM6UHJvdGhldXNAMDFGbHVpZw=="
		(CORPO)
			{
				"empresa"         : "10",
				"filial"          : "0101",
				"tipo"            : "solicitacao",
				"fluig"           : "123",
				"numero"          : "000001",
				"centrocusto"     : "023",
				"contacontabil"   : "",
				"itemcontabil"    : "",
				"classevalor"     : "",
				"loginaprovador"  : "user2",
				"codigoaprovador" : "000002",
				"grupoaprovacao"  : "000001",
				"itemaprovacao"   : "03",
				"dataaprovacao"   : "30/05/2019",
				"decisao"         : "A"
			}

         (RETORNO)
			{
				"filial": "01",
				"nomefilial"        : "TESTE",
				"numero" 			: "000002",
				"status"            : "Bloqueado",
				"centrocusto"       : "023",
				"desccentrocusto"   : "DESPESAS COOPERATIVA",
				"contacontabil"     : "",
				"desccontacontabil" : "",
				"itemcontabil"      : "",
				"descitemcontabil"  : "",
				"classevalor"       : "",
				"descclassevalor"   : "",
				"proximoaprovador"  : "user2",
				"codigoaprovador"   : "000002",
				"nomeaprovador"     : "APROV 2",
				"grupoaprovacao"    : "000001",
				"itemaprovacao"     : "03",
				"destaque"          : "0001|0009",
				"valoraprovacao"    : 2000
			}
*/

WSRESTFUL mtaprovacaocompras DESCRIPTION "Servico REST"

WSMETHOD POST DESCRIPTION "Aprovacao de compras" WSSYNTAX "/mtaprovacaocompras"

END WSRESTFUL
 
WSMETHOD POST WSSERVICE mtaprovacaocompras
	Local nA              := 0
	Local cBody           := ""
	Local oObj            := nil
	Local cMensagem       := ""
	Local aRetSaldo       := {}
	Local nTotal          := 0
	Local dRefer          := nil
	Local cNumero         := ""
	Local nDescicao       := 0
	Local cDescicao       := ""
	Local cChaveSCR       := ""
	Local cTipo           := ""
	Local lOk             := .T.
	Local cGrupoAprov     := ""
	Local lAchou          := .F.
	Local cMensAlc01      := ""
	Local cMensAlc02      := ""
	Local cMensAlc03      := ""
	Local lGrupoAprov     := .F.
	Local cItensAprov     := ""
	Local lPularAprovacao := .F.  //Irá pular quando já estiver aprovado no Protheus e o Fluig mandar aprovar e reprovado no Protheus e o Fluig mandar reprovar.
	Local lReprovacao     := GetMV("FS_REPALCA",,.F.) //Se usa a reprovacao parcial por entidade
	Local cAprovador      := ""
	Local cAprovs         := ""
	Local cCodAprovs      := ""
	Local aAprovador      := {}
	Local cItemAprov      := ""
	Local cNivel          := ""
	Local cCentroCusto    := ""
	Local cContaContabil  := ""
	Local cItemContabil   := "" 
	Local cClasseValor    := ""
	Local aRegSCR         := {}
	Local _cMail          := "sandro.ferreira@caoa.com.br" 
	Local cMailCC         := ""
	//Local _cAssu          := "Posição de Estoque referente ao dia:   " +  dtoc(date())
	Local _cAssu          := " Sua solicitação foi movimentada " 
	Local cHtml           := ""
	Local aAnexos         := {}
	Local lMsgErro    	  := .T.
	Local lMsgOK          := .F.
	Local _cRot           := "ZWSR002"
	Local cObsMail        := ""
	Local cResultado      := ""
	Local cReplyTo        := ""
	Local cCompra         := ""
	Private cObs            := ""



	self:SetContentType("application/json")

	ConOut("WSREST: mtaprovacaocompras: iniciando - " + DtoC(Date()) + " - " + Time())

	Begin Sequence

        //- Alterado por Sandro, devendo voltar apos testes
		/*
		cContent := self:GetHeader("Authorization")

		If  !( Empty(cContent) )
			cContent := StrTran(cContent, "Basic ", "")
			cContent := Decode64(cContent)

			ConOut("autorization:")
			ConOut(cContent)
			ConOut("...")

			If  (cContent <> cUsFluig+":"+cSnFluig)
				cMensagem := '{"erro" : "03001", "mensagem": "usuario e senha de autenticacao nao conferem"}'
				Break
			EndIf
		EndIf
        */
		// Obtem o JSon de entrada 
		
		cBody := self:GetContent()
		ConOut("corpo:")
		ConOut(cBody)
		ConOut("...")

		If		Empty(cBody) .Or.;
				!('empresa' $ cBody) .Or. !('filial' $ cBody) .Or. !('tipo' $ cBody) .Or. !('fluig' $ cBody)  .Or. !('numero' $ cBody) .Or. !('decisao' $ cBody) .Or.;
				 !('centrocusto' $ cBody) .Or.  !('contacontabil' $ cBody) .Or. !('itemcontabil' $ cBody) .Or. !('classevalor' $ cBody) .Or.;
				 !('codigoaprovador' $ cBody) .Or.  !('dataaprovacao' $ cBody)  .Or.  !('grupoaprovacao' $ cBody) .Or. !('itemaprovacao' $ cBody) .Or.;
				!( FWJsonDeserialize(cBody, @oObj) ) .Or.;
				Empty(oObj:empresa) .Or. Empty(oObj:filial) .Or. Empty(oObj:numero) .Or. !(Alltrim(oObj:decisao)$"A|R")
			cMensagem := '{"erro" : "03002", "mensagem": "json invalido!"}'
			Break
		EndIf
        ConOut(".a.")
		cObs := oObj:observacao
		ConOut(cObs)
		ConOut(".b.")
		ConOut(oObj:observacao)
	    ConOut(".x.")

        If  (oObj:empresa <> cEmpAnt)
		   //cEmpAnt := "02"
		   RpcClearEnv()
		   RpcSetType(3)
		   RpcSetEnv(AllTrim(oObj:empresa),AllTrim(oObj:filial),,,,GetEnvServer(),{ })
		Endif   

    	If  (oObj:empresa <> cEmpAnt)
			cMensagem := '{"erro" : "03009", "mensagem": "Empresa nao corresponde com a empresa do WS Rest! empresa: '+oObj:empresa+' - empresa REST: '+cEmpAnt+'"}'
			Break
		EndIf

		If  (cFilant <> oObj:filial)
			cFilant := oObj:filial  //Troca a filial do ambiente
		EndIf

		//Verifica se existe 
		If  (oObj:tipo == "solicitacao")

			cTipo      := "SC"
			cMensAlc01 := "Alcada da solicitacao nao encontrada! Solicitacao"
			cMensAlc02 := "Solicitacao reprovada"
			cMensAlc03 := "da solicitacao de compras"

			SC1->( DbSetOrder(1) ) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD

			If  !( SC1->(DbSeek(xFilial("SC1")+oObj:numero)) )
				cMensagem := '{"erro" : "03003", "mensagem": "Numero da solicitacao nao encontrado - tes! Numero: '+oObj:numero+'"}'
				Break
			EndIf

			If  (Alltrim(SC1->C1_XFLUIG5) <> oObj:fluig)
				cMensagem := '{"erro" : "03008", "mensagem": "Numero fluig nao corresponde com a solicitacao Protheus! Numero: '+oObj:numero+'"}'
				Break
			EndIf

		Elseif (oObj:tipo == "pedido")

			cTipo      := "PC"
			cMensAlc01 := "Alcada do pedido nao encontrado! Pedido"
			cMensAlc02 := "Pedido reprovado"
			cMensAlc03 := "do pedido de compras"

			SC7->( DbSetOrder(1) ) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN

			If  !( SC7->(DbSeek(xFilial("SC7")+oObj:numero)) )
				cMensagem := '{"erro" : "03014", "mensagem": "Numero do pedido nao encontrado! Numero: '+oObj:numero+'"}'
				Break
			EndIf

			If  (Alltrim(SC7->C7_XFLUIG5) <> oObj:fluig)
				cMensagem := '{"erro" : "03015", "mensagem": "Numero fluig nao corresponde com o pedido Protheus! Numero: '+oObj:numero+'"}'
				Break
			EndIf

        ElseIF (oObj:tipo == "contrato")

			cTipo      := "CP"
			cMensAlc01 := "Alcada do contrato de parceria nao encontrado! Contrato"
			cMensAlc02 := "Contrato reprovado"
			cMensAlc03 := "do Contrato de Parceria"

			SC3->( DbSetOrder(1) ) //C3_FILIAL+C3_NUM+C3_ITEM

			If  !( SC3->(DbSeek(xFilial("SC3")+oObj:numero)) )
				cMensagem := '{"erro" : "03094", "mensagem": "Numero do contrato de parceria nao encontrado! Numero: '+oObj:numero+'"}'
				Break
			EndIf

			If  (Alltrim(SC3->C3_XFLUIG5) <> oObj:fluig)
				cMensagem := '{"erro" : "03095", "mensagem": "Numero fluig nao corresponde com o contrato de parceria! Numero: '+oObj:numero+'"}'
				Break
			EndIf
		EndIf

		DBL->( DbSetOrder(1) ) //DBL_FILIAL+DBL_GRUPO+DBL_ITEM
		SC1->( DbSetOrder(1) ) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
		SCR->( DbSetOrder(1) ) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
		DBM->( DbSetOrder(3) ) //DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USAPRO+DBM_USAPOR

		For nA := 1 to 2

			cChaveSCR := xFilial("SCR")+cTipo+PadR(oObj:numero,Len(SCR->CR_NUM))

			If  !( lAchou := SCR->(DbSeek(cChaveSCR)) ) .And. (cTipo == "PC")
				cTipo := "IP"  //Pedido de Compra tem alçada por Pedido de Compra (PC) e por Item de Pedido (IP). Ver cadastro de Grupo de Aprovadores
				Loop
			EndIf

			Exit  //Se for solicitação irá executar somente uma vez
		Next nA

		If  !( lAchou )
			cMensagem := '{"erro" : "03004", "mensagem": "'+ cMensAlc01 +': '+PadR(oObj:numero,Len(SCR->CR_NUM))+'"}'
			Break
		EndIf
		
		cNumero := Alltrim(SCR->CR_NUM)

		If  !( u_FLUIG022(cNumero, cTipo, @aRegSCR) )
			cMensagem := '{"erro" : "03020", "mensagem": "Alcada '+ cMensAlc03 +' nao encontrada pela Query de registros! - Filial: '+cXFilial+' - Pedido: '+ cNumero+'"}'
			Break
		EndIf
		
		//Se for aprovação por entidade contábil tem DBM
		lTemDBM := DBM->( DbSeek(xFilial("DBM")+cTipo+SCR->CR_NUM) )

		For nA := 1 to Len(aRegSCR)
		 
			SCR->( DbGoto(aRegSCR[nA]) )
             //incluido pelo Sandro -       .and. oOBJ:decisao <> "A"
			//If  (SCR->CR_STATUS == "04" .and. oOBJ:decisao <> "A" .and. SCR->CR_APROV == oobj:codigoaprovador) .and. SCR->CR_GRUPO == oobj:grupoaprovacao  .And. (!( lReprovacao ) .Or. !( lTemDBM ) )
			If  (SCR->CR_STATUS == "04" .and. oOBJ:decisao <> "A" ) .and. SCR->CR_GRUPO == oobj:grupoaprovacao  .And. (!( lReprovacao ) .Or. !( lTemDBM ) )
				cMensagem := '{"erro" : "03011", "mensagem": "'+cMensAlc02+'! Aprovador: '+Alltrim(Posicione("SAK",1,xFilial("SAK")+SCR->CR_APROV,"AK_LOGIN"))+'"}'
				Break
			EndIf
			 
			//cAprovador := Alltrim(Posicione("SAL",4,xFilial("SAL")+SCR->(CR_GRUPO+CR_USER),"AL_APROV"))
			cAprovador := Alltrim(Posicione("SAL",4,xFilial("SAL")+SCR->(CR_GRUPO+CR_USER),"AL_USER"))

			If  (SCR->CR_STATUS == "02") 

				If  SCR->( (CR_GRUPO == oObj:grupoaprovacao) .And. (Alltrim(CR_ITGRP) == Alltrim(oObj:itemaprovacao)) .And. (cAprovador == oObj:codigoaprovador) )  
					lGrupoAprov := .T.
					Exit
				ElseIf  (SAL->AL_TPLIBER == "U")
					cMensagem := '{"erro" : "03010", "mensagem": "Aprovador anterior a este, esta pendente aprovacao! Aprovador: '+Alltrim(Posicione("SAK",1,xFilial("SAK")+SCR->CR_APROV,"AK_LOGIN"))+'"}'
					Break
				EndIf

			ElseIf  SCR->( (CR_GRUPO == oObj:grupoaprovacao) .And. (Alltrim(CR_ITGRP) == Alltrim(oObj:itemaprovacao)) .And. (cAprovador == oObj:codigoaprovador) )

				If  ((Alltrim(oObj:decisao) == "A") .And. (SCR->CR_STATUS $ "03|05|")) .Or.;
				 	((Alltrim(oObj:decisao) == "R") .And. (SCR->CR_STATUS $ "04|05|06")) //01=Aguardando nivel anterior;02=Pendente;03=Liberado;04=Bloqueado;05=Liberado outro usuario;06=Rejeitado
				 	lGrupoAprov     := .T.
					lPularAprovacao := .T.
					Exit
				Else
					If  (SCR->CR_STATUS == "03")
						cMensagem := '{"erro" : "03012", "mensagem": "Alcada deste aprovador ja foi aprovada! Aprovador: '+Alltrim(Posicione("SAK",1,xFilial("SAK")+SCR->CR_APROV,"AK_LOGIN"))+'"}'
					ElseIf  (SCR->CR_STATUS == "04")
						cMensagem := '{"erro" : "03012", "mensagem": "Alcada deste aprovador ja foi reprovada! Aprovador: '+Alltrim(Posicione("SAK",1,xFilial("SAK")+SCR->CR_APROV,"AK_LOGIN"))+'"}'
					Else
						cMensagem := '{"erro" : "03012", "mensagem": "Alcada deste aprovador nao esta pendente! Aprovador: '+Alltrim(Posicione("SAK",1,xFilial("SAK")+SCR->CR_APROV,"AK_LOGIN"))+'"}'
					EndIf
					Break
				EndIf

			EndIf

		Next nA

		If  !( lGrupoAprov )
			cMensagem := '{"erro" : "03013", "mensagem": "Grupo de aprovacao nao encontrado! Tipo: '+cTipo+' - Chave: |'+cChaveSCR+'|"}'
			Break
		EndIf
		
		//Itens a serem destacados no Fluig
		cChaveDBM := xFilial("DBM")+cTipo+SCR->(CR_NUM+CR_GRUPO+CR_ITGRP+CR_APROV)
			
		cItem := ""
			
		If  DBM->( DbSeek(cChaveDBM) )
			cItem := DBM->DBM_ITEM
		EndIf
		
		If  lTemDBM .And. Empty(cItem)
			cMensagem := '{"erro" : "03016", "mensagem": "Nao encontrado o item da Entidade Contabil! Numero: '+oObj:numero+'"}'
			Break
		EndIf

		//Verifica se o item da alçada já está Liberado.
		If  (oObj:tipo == "solicitacao")

			SC1->( DbSetOrder(1) ) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD

			If  !( SC1->(DbSeek(xFilial("SC1")+oObj:numero+cItem)) )
				cMensagem := '{"erro" : "03003", "mensagem": "Numero da solicitacao nao encontrado! Numero: '+oObj:numero+'"}'
				Break
			EndIf

			If  !( lPularAprovacao ) .And. (SC1->C1_APROV == "L")
				If  (Alltrim(oObj:decisao) == "A")
					lPularAprovacao := .T.
				Else
					cMensagem := '{"erro" : "03007", "mensagem": "Solicitacao ja liberada! Numero: '+oObj:numero+'"}'
					Break
				EndIf
			EndIf

		Elseif (oObj:tipo == "pedido")

			SC7->( DbSetOrder(1) ) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN

			If  !( SC7->(DbSeek(xFilial("SC7")+oObj:numero+cItem)) )
				cMensagem := '{"erro" : "03017", "mensagem": "Numero do pedido nao encontrado! Numero: '+oObj:numero+'"}'
				Break
			EndIf

			If  !( lPularAprovacao ) .And. (SC7->C7_CONAPRO == "L")
				If  (Alltrim(oObj:decisao) == "A")
					lPularAprovacao := .T.
				Else
					cMensagem := '{"erro" : "03018", "mensagem": "Pedido ja liberado! Numero: '+oObj:numero+'"}'
					Break
				EndIf
			EndIf
        ElseIF (oObj:tipo == "contrato")

			SC3->( DbSetOrder(1) ) //C3_FILIAL+C3_NUM+C3_ITEM

			If  !( SC3->(DbSeek(xFilial("SC3")+oObj:numero)) )
				cMensagem := '{"erro" : "03017", "mensagem": "Numero do contrato de parceria nao encontrado! Numero: '+oObj:numero+'"}'
				Break
			EndIf

			If  !( lPularAprovacao ) .And. (SC3->C3_CONAPRO == "L")
				If  (Alltrim(oObj:decisao) == "A")
					lPularAprovacao := .T.
				Else
					cMensagem := '{"erro" : "03018", "mensagem": "Contrato de parceria ja liberado! Numero: '+oObj:numero+'"}'
					Break
				EndIf
			EndIf


		EndIf

		//Irá pular quando já estiver aprovado no Protheus e o Fluig mandar aprovar e reprovado no Protheus e o Fluig mandar reprovar.
		If  !( lPularAprovacao )

			//Na reprovação e com entidade contábil, a reprovação será tratada fora do padrão, pois o padrão não funciona devidamente
			If  lReprovacao .And. (Alltrim(oObj:decisao) # "A") .And. lTemDBM
			
				If  !( fReprovar(oObj:codigoaprovador, oObj:loginaprovador, @cMensagem) )
					cMensagem := '{"erro" : "03019", "mensagem": "' + cMensagem + ' Numero: '+oObj:numero+'"}'
					Break
				EndIf
				
			Else
	
				//Processa a liberação.
				dRefer    := CtoD(oObj:dataaprovacao)
				aRetSaldo := MaSalAlc(SCR->CR_APROV, dRefer)
				nTotal    := xMoeda(SCR->CR_TOTAL, SCR->CR_MOEDA, aRetSaldo[2], SCR->CR_EMISSAO,, SCR->CR_TXMOEDA)
				nDescicao := If(Alltrim(oObj:decisao) == "A", 2, 3)
				//cDescicao := If(Alltrim(oObj:decisao) == "A", "Aprovacao", "Reprovacao") + " via fluig - metodo mtaprovacaocompras"
				cDescicao := If(Alltrim(oObj:decisao) == "A", "Aprovacao ", "Reprovacao ") + oOBJ:observacao
		
				A097ProcLib(SCR->(Recno()), nDescicao, nTotal, SCR->CR_APROV, SCR->CR_GRUPO, cDescicao, dRefer)
                
				IF Alltrim(oObj:decisao) = "R" .and.  oObj:tipo <> "solicitacao" .and. SC7->C7_CONAPRO = "B" .AND. oObj:CENTROCUSTO = ALLTRIM(SC7->C7_CC) .AND. oObj:CONTACONTABIL = ALLTRIM(SC7->C7_CONTA)
					If  SC7->( DbRLock(Recno()) )
						SC7->C7_CONAPRO := "R"
						SC7->( MsUnLock() )
					EndIf
				ENDIF

				//IF Alltrim(oObj:decisao) = "R" .and. oObj:tipo <> "pedido" .and.  oObj:tipo <> "solicitacao" .and. SC3->C3_CONAPRO = "B" .AND. oObj:CENTROCUSTO = ALLTRIM(SC3->C3_CC) .AND. oObj:CONTACONTABIL = ALLTRIM(SC3->C3_CONTA)
				//	If  SC3->( DbRLock(Recno()) )
				//		SC3->C3_CONAPRO := "R"
				//		SC3->( MsUnLock() )
				//	EndIf
				//ENDIF


				IF Alltrim(oObj:decisao) = "R" .and. oObj:tipo = "solicitacao" .and. SCR->CR_STATUS = "04" 
					If  SCR->( DbRLock(Recno()) )
						SCR->CR_STATUS := "06"
						If Empty(SCR->CR_OBS)
						   SCR->CR_OBS    := cObs
						ENDIF   
						SCR->( MsUnLock() )
					EndIf
				ENDIF

				IF Alltrim(oObj:decisao) = "R" .and. oObj:tipo = "contrato" .and. SCR->CR_STATUS = "04" 
					If  SCR->( DbRLock(Recno()) )
						SCR->CR_STATUS := "06"
						If Empty(SCR->CR_OBS)
						   SCR->CR_OBS    := cObs
						ENDIF   
						SCR->( MsUnLock() )
					EndIf
				ENDIF

			EndIf
	
			If  (Alltrim(oObj:decisao) == "A")
				If  !(SCR->CR_STATUS $ "03|05") //01=Aguardando nivel anterior;02=Pendente;03=Liberado;04=Bloqueado;05=Liberado outro usuario;06=Rejeitado
					cMensagem := '{"erro" : "03005", "mensagem": "Alcada do aprovador nao foi possivel aprovar! Aprovador: '+oObj:codigoaprovador+'"}'
					Break
				EndIf
			Else
				If  !(SCR->CR_STATUS $ "04|05|06")
					cMensagem := '{"erro" : "03006", "mensagem": "Alcada do aprovador nao foi possivel reprovar! Aprovador: '+oObj:codigoaprovador+'"}'
					Break
				EndIf
			EndIf

		EndIf

		If  SCR->( DbRLock(Recno()) )
			SCR->CR_FLUIG := "xxxxxxxxxx" //marca para sabermos que foi processado pelo fluig
            If  EMPTY(SCR->CR_OBS) 
			    SCR->CR_OBS   := cOBS
			EndIf	
			SCR->( MsUnLock() )
		EndIf

		//If  Alltrim(cDescicao) = "Aprovacao" .and. cTipo = "PC"
		//    ConOut("Sandro1-sim")
		//	//Envia e-mail para o fornecedor se não tiver mais aprovadores
        //    ZFLUIMAIL( cTipo, cNumero )
		//else
		//	ConOut("Sandro2-nao")
		//Endif

		//Proximo aprovador
		If  !( u_FLUIG031(aRegSCR, cNumero, cTipo, @cItem, @aAprovador, @cGrupoAprov, @cItemAprov, @cNivel, @cCentroCusto,;
		                  @cContaContabil, @cItemContabil, @cClasseValor, @cMensagem) )

			Break
					
		EndIf
		
		cJSon := '{'
		cJSon += '  "empresa"           : "xxx1", '
		cJSon += '  "nomeempresa"       : "xxx2", '
		cJSon += '  "filial"            : "xxx3", '
		cJSon += '  "nomefilial"        : "xxx4", '
		cJSon += '  "numero"            : "xxx5", '
		cJSon += '  "status"            : "xxx6", '
		cJSon += '  "centrocusto"       : "xxx7", '
		cJSon += '  "desccentrocusto"   : "xxx8", '
		cJSon += '  "contacontabil"     : "xxx9", '
		cJSon += '  "desccontacontabil" : "xxxA", '
		cJSon += '  "itemcontabil"      : "xxxB", '
		cJSon += '  "descitemcontabil"  : "xxxC", '
		cJSon += '  "classevalor"       : "xxxD", '
		cJSon += '  "descclassevalor"   : "xxxE", '
		cJSon += '  "grupoaprovacao"    : "xxxF", '
		cJSon += '  "itemaprovacao"     : "xxxG", '
		cJSon += '  "destaque"     		: "xxxH", '
		cJSon += '  "valoraprovacao"    : "xxxI", '
		cJSon += '  "proximoaprovador"  : "xxxJ", '
		cJSon += '  "codigoaprovador"   : "xxxK"  '
		cJSon += '}'

		For nA := 1 to Len(aAprovador)

			cAprovs    := If(Empty(cAprovs),"",",")    + aAprovador[nA][1]
			cCodAprovs := If(Empty(cCodAprovs),"",",") + aAprovador[nA][2]

		Next nA

		If  (oObj:tipo == "solicitacao")

			//Refresh na SC1
			SC1->( DbSetOrder(2) )
			SC1->( DbSetOrder(1) )
			SC1->(DbSeek(xFilial("SC1")+oObj:numero+cItem)) //Reposiciona no primeiro bloqueado do proximo aprovador

			cJSon := StrTran(cJSon, 'xxx1', cEmpAnt)
			cJSon := StrTran(cJSon, 'xxx2', Alltrim(FWEmpName(cEmpAnt)))
			cJSon := StrTran(cJSon, 'xxx3', cFilAnt)
			cJSon := StrTran(cJSon, 'xxx4', Alltrim(FWFilName(cEmpAnt, cFilAnt)))
			cJSon := StrTran(cJSon, 'xxx5', oObj:numero)
			cJSon := StrTran(cJSon, 'xxx6', If(SC1->C1_APROV=="L","Liberado","Bloqueado"))
			cJSon := StrTran(cJSon, 'xxx7', Alltrim(cCentroCusto))
			cJSon := StrTran(cJSon, 'xxx8', Alltrim(Posicione("CTT",1,xFilial("CTT")+cCentroCusto,"CTT_DESC01")))
			cJSon := StrTran(cJSon, 'xxx9', Alltrim(cContaContabil))
			cJSon := StrTran(cJSon, 'xxxA', Alltrim(Posicione("CT1",1,xFilial("CT1")+cContaContabil,"CT1_DESC01")))
			cJSon := StrTran(cJSon, 'xxxB', Alltrim(cItemContabil))
			cJSon := StrTran(cJSon, 'xxxC', Alltrim(Posicione("CTD",1,xFilial("CTD")+cItemContabil,"CTD_DESC01")))
			cJSon := StrTran(cJSon, 'xxxD', Alltrim(cClasseValor))
			cJSon := StrTran(cJSon, 'xxxE', Alltrim(Posicione("CTH",1,xFilial("CTH")+cClasseValor,"CTH_DESC01")))
			cJSon := StrTran(cJSon, 'xxxF', Alltrim(SCR->CR_GRUPO))
			cJSon := StrTran(cJSon, 'xxxG', Alltrim(SCR->CR_ITGRP))
			cJSon := StrTran(cJSon, 'xxxH', Alltrim(cItensAprov))
			cJSon := StrTran(cJSon, 'xxxI', Alltrim(Str(SCR->CR_TOTAL,18,2)))
			cJSon := StrTran(cJSon, 'xxxJ', cAprovs)
			cJSon := StrTran(cJSon, 'xxxK', cCodAprovs)

			ConOut("cJSon: ")
			ConOut(cJSon)

			self:SetResponse( cJSon )

			Do  While SC1->( !Eof() .And. (C1_FILIAL+C1_NUM == xFilial("SC1")+oObj:numero) )

				If  SC1->( (C1_APROV=="L") .And. DbRLock(Recno()) )
					SC1->C1_XFLUIG3 := 'S'
					SC1->C1_XFLUIG4 := DtoS(Date())+"-"+Left(Time(),5)
					SC1->( MsUnLock() )
				ElseIf  (Alltrim(oObj:decisao) <> "A")
					If  SC1->( DbRLock(Recno()) )
						SC1->C1_APROV := "R"
						SC1->( MsUnLock() )
					EndIf
				EndIf

				SC1->( DbSkip() )
			EndDo

		ElseIF (oObj:tipo == "pedido")

	
			//Refresh na SC7
			SC7->( DbSetOrder(2) )
			SC7->( DbSetOrder(1) )
			SC7->(DbSeek(xFilial("SC7")+oObj:numero+cItem)) //Reposiciona
			
			ConOut("...")
			ConOut("... cChave SC7: " + xFilial("SC7")+oObj:numero+cItem)
			ConOut("...")

			cJSon := StrTran(cJSon, 'xxx1', cEmpAnt)
			cJSon := StrTran(cJSon, 'xxx2', Alltrim(FWEmpName(cEmpAnt)))
			cJSon := StrTran(cJSon, 'xxx3', cFilAnt)
			cJSon := StrTran(cJSon, 'xxx4', Alltrim(FWFilName(cEmpAnt, cFilAnt)))
			cJSon := StrTran(cJSon, 'xxx5', oObj:numero)
			cJSon := StrTran(cJSon, 'xxx6', If(SC7->C7_CONAPRO=="L","Liberado","Bloqueado"))
			cJSon := StrTran(cJSon, 'xxx7', Alltrim(cCentroCusto))
			cJSon := StrTran(cJSon, 'xxx8', Alltrim(Posicione("CTT",1,xFilial("CTT")+cCentroCusto,"CTT_DESC01")))
			cJSon := StrTran(cJSon, 'xxx9', Alltrim(cContaContabil))
			cJSon := StrTran(cJSon, 'xxxA', Alltrim(Posicione("CT1",1,xFilial("CT1")+cContaContabil,"CT1_DESC01")))
			cJSon := StrTran(cJSon, 'xxxB', Alltrim(cItemContabil))
			cJSon := StrTran(cJSon, 'xxxC', Alltrim(Posicione("CTD",1,xFilial("CTD")+cItemContabil,"CTD_DESC01")))
			cJSon := StrTran(cJSon, 'xxxD', Alltrim(cClasseValor))
			cJSon := StrTran(cJSon, 'xxxE', Alltrim(Posicione("CTH",1,xFilial("CTH")+cClasseValor,"CTH_DESC01")))
			cJSon := StrTran(cJSon, 'xxxF', Alltrim(SCR->CR_GRUPO))
			cJSon := StrTran(cJSon, 'xxxG', Alltrim(SCR->CR_ITGRP))
			cJSon := StrTran(cJSon, 'xxxH', Alltrim(cItensAprov))
			cJSon := StrTran(cJSon, 'xxxI', Alltrim(Str(SCR->CR_TOTAL,18,2)))
			cJSon := StrTran(cJSon, 'xxxJ', cAprovs)
			cJSon := StrTran(cJSon, 'xxxK', cCodAprovs)

			ConOut("cJSon: ")
			ConOut(cJSon)

			self:SetResponse( cJSon )

			Do  While SC7->( !Eof() .And. (C7_FILIAL+C7_NUM == xFilial("SC7")+oObj:numero) )

				If  SC7->( (C7_CONAPRO=="L") .And. DbRLock(Recno()) )
					SC7->C7_XFLUIG3 := 'S'
					SC7->C7_XFLUIG4 := DtoS(Date())+"-"+Left(Time(),5)
					SC7->( MsUnLock() )
				ElseIf  (Alltrim(oObj:decisao) <> "A")
					If  SC7->( DbRLock(Recno()) )
						SC7->C7_CONAPRO := "R"
						SC7->( MsUnLock() )
					EndIf
				EndIf

				SC7->( DbSkip() )
			EndDo

			If  (Alltrim(oObj:decisao) = "A")
                Conout("Sandro, chamar o envio de e-mail aqui...")
				If  Alltrim(cDescicao) = "Aprovacao" .and. cTipo = "PC"
				    ConOut("Sandro1-sim")
					//Envia e-mail para o fornecedor se não tiver mais aprovadores
				    //ZFLUIMAIL( cTipo, cNumero )
				else
					ConOut("Sandro2-nao")
				Endif
			Endif

		ElseIF (oObj:tipo == "contrato")

		
			//Refresh na SC3
			SC3->( DbSetOrder(2) )
			SC3->( DbSetOrder(1) )
			SC3->(DbSeek(xFilial("SC3")+oObj:numero)) //Reposiciona
			
			ConOut("...")
			ConOut("... cChave SC3: " + xFilial("SC3")+oObj:numero)
			ConOut("...")

			cJSon := StrTran(cJSon, 'xxx1', cEmpAnt)
			cJSon := StrTran(cJSon, 'xxx2', Alltrim(FWEmpName(cEmpAnt)))
			cJSon := StrTran(cJSon, 'xxx3', cFilAnt)
			cJSon := StrTran(cJSon, 'xxx4', Alltrim(FWFilName(cEmpAnt, cFilAnt)))
			cJSon := StrTran(cJSon, 'xxx5', oObj:numero)
			cJSon := StrTran(cJSon, 'xxx6', If(SC3->C3_CONAPRO=="L","Liberado","Bloqueado"))
			cJSon := StrTran(cJSon, 'xxx7', Alltrim(cCentroCusto))
			cJSon := StrTran(cJSon, 'xxx8', Alltrim(Posicione("CTT",1,xFilial("CTT")+cCentroCusto,"CTT_DESC01")))
			cJSon := StrTran(cJSon, 'xxx9', Alltrim(cContaContabil))
			cJSon := StrTran(cJSon, 'xxxA', Alltrim(Posicione("CT1",1,xFilial("CT1")+cContaContabil,"CT1_DESC01")))
			cJSon := StrTran(cJSon, 'xxxB', Alltrim(cItemContabil))
			cJSon := StrTran(cJSon, 'xxxC', Alltrim(Posicione("CTD",1,xFilial("CTD")+cItemContabil,"CTD_DESC01")))
			cJSon := StrTran(cJSon, 'xxxD', Alltrim(cClasseValor))
			cJSon := StrTran(cJSon, 'xxxE', Alltrim(Posicione("CTH",1,xFilial("CTH")+cClasseValor,"CTH_DESC01")))
			cJSon := StrTran(cJSon, 'xxxF', Alltrim(SCR->CR_GRUPO))
			cJSon := StrTran(cJSon, 'xxxG', Alltrim(SCR->CR_ITGRP))
			cJSon := StrTran(cJSon, 'xxxH', Alltrim(cItensAprov))
			cJSon := StrTran(cJSon, 'xxxI', Alltrim(Str(SCR->CR_TOTAL,18,2)))
			cJSon := StrTran(cJSon, 'xxxJ', cAprovs)
			cJSon := StrTran(cJSon, 'xxxK', cCodAprovs)

			ConOut("cJSon: ")
			ConOut(cJSon)

			self:SetResponse( cJSon )
            cCompra := SC3->C3_USER
			Do  While SC3->( !Eof() .And. (C3_FILIAL+C3_NUM == xFilial("SC3")+oObj:numero) )
                
				If  SC3->( (C3_CONAPRO=="L") .And. DbRLock(Recno()) )
					SC3->C3_XFLUIG3 := 'S'
					SC3->C3_XFLUIG4 := DtoS(Date())+"-"+Left(Time(),5)
					SC3->( MsUnLock() )
				ElseIf  (Alltrim(oObj:decisao) <> "A")
					If  SC3->( DbRLock(Recno()) )
						SC3->C3_CONAPRO := "B"
						SC3->C3_XFLUIG3 := 'S'
					    SC3->C3_XFLUIG4 := DtoS(Date())+"-"+Left(Time(),5)
						SC3->( MsUnLock() )
					EndIf
				EndIf

				SC3->( DbSkip() )
			EndDo

		EndIf
        //Deve entrar aqui a rotina de envio de e-mail de aprovado e recusado para o solicitante

        //   	  (cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,Rotina ,	Observação	, cReplyTo	)


        IF cTipo = "PC"
			If !Empty( SC1->C1_CODCOMP )
				cResultado := "Aprovado"
				If (Alltrim(oObj:decisao) <> "A")
					cResultado := "Reprovado"
				Endif
				If SY1->( DbSeek( FWxFilial("SY1") + SC1->C1_CODCOMP ) )
					_cMail := SY1->Y1_EMAIL 
					_cAssu := "Seu Pedido de Compras:  " + cNumero +  "  Foi " + cResultado + "."

					cHtml := "Prezado(a) Comprador: " + SY1->Y1_NOME +  " <br>"
					cHtml += "<br>"
					cHtml  += "Seu Pedido de Compras:  " + cNumero +  "  foi " + cResultado + "<br>"
					cHtml += "<br>"	
					cHtml += "Observação: " + cNumero  + " Foi " + cResultado + " - " + cObs + "<br>"
					cHtml += "<br>"	

					U_ZGENMAIL(	_cMail      ,cMailCC    , _cAssu    ,cHtml      ,aAnexos    ,lMsgErro  ,lMsgOK	    , _cRot ,     cObsMail  , cReplyTo )    
				EndIf
			EndIf
        ELSEIF cTipo = "CP"
			cResultado := "Aprovado"
			If (Alltrim(oObj:decisao) <> "A")
				cResultado := "Reprovado"
			Endif
			SY1->( DbSetOrder(3) )
			If SY1->( DbSeek( FWxFilial("SY1") + cCompra ) )
				_cMail := SY1->Y1_EMAIL 
		       _cAssu := "Seu Contrato de Parceria foi:  " + cNumero + "  Foi " + cResultado + "."

				cHtml := "Prezado(a) Comprador: " + SY1->Y1_NOME +  " <br>"
				cHtml += "<br>"
				cHtml += "Seu Contrato de Parceria:  "     + cNumero + "  foi " + cResultado + "<br>"
				cHtml += "<br>"	
				cHtml += "Observação: " + cNumero  + " Foi " + cResultado + " - " + cObs + "<br>"
				cHtml += "<br>"	

				U_ZGENMAIL(	_cMail      ,cMailCC    , _cAssu    ,cHtml      ,aAnexos    ,lMsgErro  ,lMsgOK	    , _cRot ,     cObsMail  , cReplyTo )    
			EndIf
		ENDIF            

	End Sequence


	ConOut("WSREST: mtaprovacaocompras: finalizando ")

	If  !( Empty(cMensagem) )
		ConOut("...")
		ConOut(cMensagem)
		ConOut("...")

		SetRestFault(401, cMensagem)
		lOk := .F.
	EndIf

Return lOk



/*
{Protheus.doc} FLUIG031()
Função para verificar os dados do proximo aprovador.

@author  Antonio Carlos Ferreira
@version 1.0
@since   28/06/2019
@return  Nil  Sem retorno.
@sample

		u_FLUIG031()

*/

USER Function FLUIG031(aRegSCR, cNumero, cTipo, cItem, aAprovador, cGrupoAprov, cItemAprov, cNivel, cCentroCusto,;
 						cContaContabil, cItemContabil, cClasseValor, cMensagem)

    Local nA     := 0
    Local nB     := 0
	Local nReg   := 0
	Local nAprov := 0

	Begin Sequence
	
		cGrupoAprov    := ""
		cItemAprov     := ""
		cNivel         := ""
		cCentroCusto   := ""
		cContaContabil := ""
		cItemContabil  := ""
		cClasseValor   := ""
		cItensAprov    := ""

		aAprovador     := {}

		For nA := 1 to Len(aRegSCR)
		
			SCR->( DbGoto(aRegSCR[nA]) )
			
			If  SCR->( !Eof() .And. (CR_STATUS == "02") /*Pendente*/)
	
				cGrupoAprov   := SCR->CR_GRUPO
				cItemAprov    := SCR->CR_ITGRP
				cNivel        := SCR->CR_NIVEL
	
				nReg := SCR->( Recno() )
	
				nAprov := 0
				
				For nB := nA to Len(aRegSCR)
				
					SCR->( DbGoto(aRegSCR[nB]) )
	
					If SCR->( !Eof() .And. (CR_FILIAL == cFilAnt) .And. (Alltrim(CR_NUM) == Alltrim(cNumero)) .And.;
				                 (CR_NIVEL == cNivel) .And. (CR_GRUPO == cGrupoAprov) .And. (Alltrim(CR_ITGRP) == Alltrim(cItemAprov)) )
	
					    ++nAprov
					    
					    AAdd(aAprovador, {"",""})
					    
					    aAprovador[nAprov][1] := Alltrim(Posicione("SAK",2,xFilial("SAK")+SCR->CR_USER,"AK_LOGIN"))
					    aAprovador[nAprov][2] := Alltrim(Posicione("SAL",4,xFilial("SAL")+cGrupoAprov+SCR->CR_USER,"AL_APROV"))
					    
					    If  (SAL->AL_TPLIBER == "U")
		
					    	If  (nAprov > 1)
					    		cMensagem := '{"erro" : "03006", "mensagem": "Alcada esta configurada errada: Tipo Aprovacao por Usuario mesmo nivel que por Nivel ou por Documento! - Filial: '+cXFilial+' -  Solicitacao: '+cNumSol+'"}'
					    		Break
					    	EndIf
		
					    	Exit  //Aprovação por usuario, envia ele sozinho
					    EndIf
				    
				    EndIf

				Next nB
				
				SCR->( DbGoto(nReg) )
				
				Exit
	
			EndIf
		
		Next nA
		
		If  Empty(cGrupoAprov)
			Break
		EndIf

		DBM->( DbSetOrder(3) ) //DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USAPRO+DBM_USAPOR

		//Itens a serem destacados no Fluig
		cChaveDBM := xFilial("DBM")+cTipo+SCR->(CR_NUM+CR_GRUPO+CR_ITGRP+CR_APROV)
		
		cItem := ""
		
		If  DBM->( DbSeek(cChaveDBM) )
			cItem := DBM->DBM_ITEM
		EndIf
		
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
	
	End Sequence

Return Empty(cMensagem)



/*
{Protheus.doc} fReprovar()
Função para reprovação de alçada de compras por entidade contábil, para substituir o padrão.

@author  Antonio Carlos Ferreira
@version 1.0
@since   13/06/2019
@return  Nil  Sem retorno.
@sample

		fReprovar()

*/

STATIC Function fReprovar(cCodAprov, cLogAprov, cMensagem)

	Local nA		:= 0
	Local cXFilial  := DBM->DBM_FILIAL 
	Local cGrupo    := DBM->DBM_GRUPO 
	Local cItGrupo  := DBM->DBM_ITGRP
	Local cTipo     := DBM->DBM_TIPO 
	Local cNumero   := Alltrim(DBM->DBM_NUM)
	Local nRegSCR   := SCR->( Recno() )
	Local nRegDBM   := DBM->( Recno() )
	Local aItens    := {}

	cMensagem := "" 

	Begin Sequence

		If  SCR->( !DbRLock() )
			cMensagem := "Problema para travar o registro da alçada 1"
			Break
		EndIf

		Do  While DBM->( !Eof() .And. (DBM_FILIAL == cXFilial) .And. (DBM_TIPO == cTipo) .And. (DBM_NUM == cNumero) .And. (DBM_GRUPO == cGrupo) .And. (DBM_ITGRP == cItGrupo) )
	
			If  (DBM->DBM_APROV # 1)
				DBM->( DbSkip() )
			EndIf
	
			If  DBM->( !DbRLock(Recno()) )
				cMensagem := "Problema para travar o registro da alçada 2"
				Break
			EndIf
		
			DBM->( DbSkip() )
		EndDo
		
		DBM->( DbGoto(nRegDBM) ) //Retorna ao primeiro

		Do  While DBM->( !Eof() .And. (DBM_FILIAL == cXFilial) .And. (DBM_TIPO == cTipo) .And. (Alltrim(DBM_NUM) == cNumero) .And. (DBM_GRUPO == cGrupo) .And. (DBM_ITGRP == cItGrupo) )
	
			If  (DBM->DBM_APROV # "2")
				cONOUT('DBM->DBM_APROV # "2"')
				DBM->( DbSkip() )
			EndIf
	
			If  DBM->( DbRLock(Recno()) )
				DBM->DBM_APROV := "3"
				DBM->( MsUnLock() )
			EndIf
			
			nRegDBM   := DBM->( Recno() )  //Registra o ultimo DBM
			
			If  (Ascan(aItens, DBM->DBM_ITEM) <= 0)
				AAdd(aItens, DBM->DBM_ITEM)
			EndIf
		
			DBM->( DbSkip() )
		EndDo
		
		DBM->( DbGoto(nRegDBM) ) //Retorna ao ultimo

		Do  While SCR->( !Eof() .And. (CR_FILIAL == cXFilial) .And. (CR_TIPO == cTipo) .And. (Alltrim(CR_NUM) == cNumero) .And. (CR_GRUPO == cGrupo) .And. (CR_ITGRP == cItGrupo) )
	
			If  SCR->( DbRLock(Recno()) )
                SCR->CR_STATUS  := "04"
				SCR->CR_DATALIB := Date()
				SCR->CR_USERLIB := cCodAprov
				SCR->CR_LIBAPRO := cCodAprov
				SCR->CR_TIPOLIM := "D"
				If EMPTY(SCR->CR_OBS)
				   SCR->CR_OBS     := cObs
				EndIf
				SCR->( MsUnLock() )
			EndIf
		
			nRegSCR   := SCR->( Recno() )  //Registra o ultimo SCR
		
			SCR->( DbSkip() )
		EndDo
		
		SCR->( DbGoto(nRegSCR) ) //Retorna ao ultimo

		If  (SCR->CR_TIPO == "SC")
			For nA := 1 to Len(aItens)
				SC1->( DbSetOrder(1) ) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD

				If  SC1->( DbSeek(SCR->(CR_FILIAL+Alltrim(CR_NUM)+aItens[nA])) .And. DbRLock(Recno()) )
					SC1->C1_NOMAPRO := cLogAprov
					SC1->( MsUnLock() )
				EndIf
			Next nA
		EndIf
		
	End Sequence
	
	DBM->( MsUnLockAll() )

Return Empty(cMensagem)





/*
===========================================================================================
Programa.:              ZFLUIMAIL
Autor....:              CAOA - Sandro Ferreira
Data.....:              17/05/2022
Descricao / Objetivo:   Envia o pedido de compras por e-mail após aprovação          
===========================================================================================
*/
Static Function ZFLUIMAIL(cTp, cNro)
    Local aAreaSY1  := SY1->( GetArea() )
    Local aAreaSC1  := SC1->( GetArea() )
    Local aEmails   := {}
    Local aDest     := {}
    Local nI        := 1

    SY1->( DbSetOrder(1) )
    SC1->( DbSetOrder(6) )
	SC7->( DbSetOrder(1) )

	SC7->( DbSeek( FWxFilial("SC7") + cNro + "0001" ) )

    /* Validação necessaria para evitar o envio indevido de pedidos por e-mail,
    isso porque o PE é chamado a cada item da SC7*/
    If AllTrim( SCR->CR_NUM ) == AllTrim( SC7->C7_NUM ) //.And. SC7->C7_ITEM == "0001"

        If SCR->CR_TIPO == "PC"

            If SC1->( DbSeek( FWxFilial("SC1") + SC7->C7_NUM ) )
                
                //--e-mails informados na solicitação de compras
                If !Empty( SC1->C1_XREQMAI )
                    aEmails := StrTokArr(SC1->C1_XREQMAI, ";")
                    For nI := 1 To Len(aEmails)                                                                 
                        Aadd(aDest,aEmails[nI])
                    Next nI
                EndIf

                //--e-mail do comprador
                If !Empty( SC1->C1_CODCOMP )
                    If SY1->( DbSeek( FWxFilial("SY1") + SC1->C1_CODCOMP ) )
                        AADD( aDest, SY1->Y1_EMAIL )
                    EndIf
                EndIf

                //--e-mail do usuário que gerou a solicitação
                If !Empty( SC1->C1_USER )
                    AADD( aDest, zEmailU(SC1->C1_USER) )
                EndIf

            EndIf
             
            //--e-mails informados no pedido de compras
            If !Empty( SC7->C7_XFORMAI )
                aEmails := StrTokArr( SC7->C7_XFORMAI, ";" )
                For nI := 1 To Len(aEmails)                                                                 
                    Aadd(aDest,aEmails[nI])
                Next nI
            EndIf

            //--Chamada da rotina de envio de pedido por e-mail
        
            If !Empty(aDest)
               IF SC7->C7_ORIGEM = "EICPO400"
                 // U_ZCOMR004(,,,,,,,aDest)
               ELSE
                 // U_ZCOMR001(,,,,,,,aDest)
                ENDIF
            EndIf

        EndIf
    EndIf

    RestArea(aAreaSC1)
    RestArea(aAreaSY1)

Return

/*
=======================================================================================
Programa.:              zEmailUsr
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              06/07/2020
Descricao / Objetivo:   Retorna e-mail do usuario          
=======================================================================================
*/
Static Function zEmailU(cUserId)
    Local cQuery		:= ""
    Local cAliasTRB		:= GetNextAlias()
    Local cEmailUser    := ""

    Default cUserId     := ""

    cQuery += " SELECT USR_EMAIL FROM SYS_USR "   + CRLF
    cQuery += " WHERE D_E_L_E_T_ = ' '  "   + CRLF
    cQuery += " AND USR_ID = '" + cUserId + "' "    + CRLF
    cQuery += " ORDER BY USR_ID "   + CRLF

    cQuery := ChangeQuery(cQuery)

    // Executa a consulta.
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

    DbSelectArea((cAliasTRB))
    (cAliasTRB)->(dbGoTop())
    If (cAliasTRB)->(!EOF())
        cEmailUser := AllTrim( (cAliasTRB)->USR_EMAIL )
    EndIf
    (cAliasTRB)->(DbCloseArea())

Return cEmailUser
