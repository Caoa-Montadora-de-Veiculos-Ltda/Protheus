#INCLUDE "TOTVS.CH"

// Classe Filha, herda a classe pai 
CLASS ZWMSF009 FROM WMSDTCOrdemServicoExecute
    METHOD NEW() CONSTRUCTOR
    METHOD zExecDCF()
    METHOD zUpdDCF(lMsUnLock)
ENDCLASS

// Construtor da filha chama construtor da classe pai
METHOD NEW() CLASS ZWMSF009
    _Super:New()
Return self

METHOD zExecDCF() CLASS ZWMSF009
Local lRet       := .T.
Local nCont      := 0
Local cMessError := ""
Local nRecnoAnt  := Self:GetRecno()
Local lHasTransf := .F.
Local oEtiqUnit  := Nil
Local oBlqSaldo  := Nil 
	// Desconsidera ordens de servi�o j� executadas, n�o retorna o erro devido os casos de aglutina��o de documento
	// Desconsidera ordens de servi�o que est�o marcadas como executadas durante um mesmo processamento - aglutina��o
	If Self:cStServ == '3' .Or. !Empty(Self:cStRadi)
		Return .T.
	EndIf
	If lRet .And. Self:LockDCF()
		If Self:cStServ == '3' .Or. !Empty(Self:cStRadi)
			Return .T.
		EndIf

		// Verifica servico com conferencia de entrada
		If Self:oServico:HasOperac({'6'})
			If !Self:oServico:ChkConfOrd(1)
				Self:cErro := "Tarefa de confer�ncia de entrada deve ser configurada antes das tarefas WMS Padr�o!"
				lRet := .F.
			EndIf
		EndIf
		// Verifica servico com conferencia de sa�da
		If lRet .And. Self:oServico:HasOperac({'7'})
			If !Self:oServico:ChkConfOrd(2)
				Self:cErro := "Tarefa de confer�ncia de sa�da deve ser configurada depois das tarefas WMS Padr�o de expedi��o!"
				lRet := .F.
			EndIf
		EndIf
		// Valida bloqueio produto (B1_MSBLQL) somente se n�o for endere�amento ou transfer�ncia unitizada
		If lRet .And. (Self:oServico:ChkRecebi() .Or. Self:oServico:ChkTransf()) .And. !Self:IsMovUnit() .And. !WmsSB1Blq(Self:oProdLote:GetProduto(),@cMessError)
			Self:cErro := cMessError
			lRet := .F.
		EndIf
		If lRet .And. !(Self:cStServ $ '1|2')
			lRet := .F.
			Self:cErro := "Situa��o " + Self:cStServ + " da ordem de servi�o n�o permite que seja executada! "
		EndIf
		// Verifica endere�o
		If lRet .And. !Self:VldOrdEnd()
			Self:cErro := "Endere�o " + IIf(Self:oServico:HasOperac({'3','4'}),"destino","origem") + " n�o informado!"
			lRet := .F.
		EndIf
		// Verifica parametro prioridade
		If lRet .And. !Self:ChecaPrior()
			lRet := .F.
		EndIf
		// Verifica se h� documentos originados desse documento que ainda estejam pendentes
		If lRet .And. Self:ChkDepPend()
			lRet := .F.
		EndIf
		//Valida se o tipo do unitizador est� preenchido na tabela de etiqueta
		lHasTransf := Self:oServico:HasOperac({'8'})
		If WmsX212118("D0Y")
			If lRet .And. lHasTransf .And. !Empty(Self:cUniDes)
				oEtiqUnit := WMSDTCEtiquetaUnitizador():New()
				oEtiqUnit:SetIdUnit(Self:cUniDes)
				If oEtiqUnit:LoadData() 
					If Empty(oEtiqUnit:GetTipUni())
						Self:cErro := "Unitizador destino da OS " + Self:cUniDes + " n�o possui tipo definido."
						lRet := .F.
					EndIf
				Else
					Self:cErro := "Etiqueta do unitizador " + Self:cUniDes + " n�o gerada!"
					lRet := .F.
				EndIf
				oEtiqUnit:Destroy()
			EndIf
		EndIf
		If lRet
			// Se for endere�amento unitizado sem informar endere�o destino, deve aglutinar as ordens de servi�o selecionadas para execu��o
			If Self:IsMovUnit() .And. Empty(Self:oOrdEndDes:GetEnder())
				lRet := Self:AgluOSEnd()
			// Se for uma transfer�ncia com unitizador destino, por�m n�o possui endere�o definido
			// Deve executar como se fosse um endere�amento unitizado, mesmo possuindo o produto informado
			ElseIf lHasTransf .And. !Empty(Self:cUniDes) .And. Empty(Self:oOrdEndDes:GetEnder())
				lRet := Self:AgluOSTrf()
			Else
				// Se for um servi�o de expedi��o, verifica se est� parametrizado para gerar ordens de servi�o aglutinadas na expedi��o
				If (Self:oServico:GetTipo() == '2' .And. SuperGetMv("MV_WMSACEX",.F.,"0") <> '0' .And. WmsCarga(Self:GetCarga())) .Or. !Empty(Self:GetCodPln())
					lRet := Self:AgluOSExp()
				EndIf
			EndIf
			If lRet
				// Atualiza status do servi�o quando n�o est� aglutinado
				If Empty(Self:aRecDCF)
					Self:SetStServ('2')
					Self:SetOk("")
					Self:zUpdDCF(.F.) // Para n�o liberar o lock
					Self:UpdStatus()
				EndIf
			EndIf

            // Carrega os produtos a serem geradas as movimentacoes
            If (Self:oServico:ChkRecebi() .Or. Self:oServico:ChkTransf()) .And. Self:IsMovUnit() .Or. (lHasTransf .And. !Empty(Self:cUniDes) .And. Empty(Self:oOrdEndDes:GetEnder()))
                lRet := Self:ExecuteUni()
            ElseIf Self:oServico:ChkRecebi() .And. Self:ChkDistr()
                lRet := Self:ExeDistPrd()
            Else
                lRet := Self:ExecutePrd()
            EndIf
            //Gera D0U, SDD e SDC para bloqueio de saldo
            If lRet .And. Self:oServico:ChkRecebi() .And. Self:oServico:ChkBlqSld()
                oBlqSaldo := WMSDTCBloqueioSaldoItens():New()
                oBlqSaldo:SetOrdServ(Self)
                lRet := oBlqSaldo:AssignSDD()
            EndIf
            If lRet
                // Carrega os movimentos criados
                For nCont := 1 To Len(Self:aRecD12)
                    AAdd(Self:aLibD12,Self:aRecD12[nCont])
                Next
                Self:aRecD12:= {}
                // Quando documentos aglutinados
                If Len(Self:aRecDCF) > 0
                    For nCont := 1 to Len(Self:aRecDCF)
                        If Self:aRecDCF[nCont][2]
                            Self:GoToDCF(Self:aRecDCF[nCont][1])
                            // Atualiza status
                            Self:SetStServ('3')
                            Self:cStRadi := ' '
                            Self:zUpdDCF()
                            Self:UpdStatus()
                        EndIf
                    Next nCont
                    Self:aRecDCF  := {}
                    Self:aLstUnit := {}
                    Self:aOrdAglu := {}
                    Self:GoToDCF(nRecnoAnt)
                Else
                    // Atualiza status
                    Self:SetStServ('3')
                    Self:cStRadi := ' '
                    Self:zUpdDCF()
                    Self:UpdStatus()
                EndIf

            EndIf

		EndIf
        
		If !lRet
			If Self:IsMovUnit()
				AADD(Self:aWmsAviso, "SIGAWMS - OS " + Self:GetDocto()+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),'') + " - Unitizador: " + Self:cIdUnitiz + CRLF + Self:GetErro())
			Else
				AADD(Self:aWmsAviso, "SIGAWMS - OS " + Self:GetDocto()+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),'') + " - Produto: " + Self:oProdLote:GetProduto() + CRLF + Self:GetErro())
			EndIf
		EndIf
		Self:UnLockDCF()
	Else
		lRet := .F.
	EndIf
Return lRet


//----------------------------------------
METHOD zUpdDCF(lMsUnLock) CLASS ZWMSF009
Local lRet := .T.

Default lMsUnLock := .T.

	If !Empty(Self:GetRecno())
		DCF->(dbGoTo( Self:GetRecno() ))
		Self:nQuant2 := ConvUm(Self:oProdLote:GetProduto(),Self:nQuant,0,2)
		// Grava DCF
		RecLock('DCF', .F.)
		DCF->DCF_SERVIC := Self:oServico:GetServico()
		DCF->DCF_DOCTO  := Self:cDocumento
		DCF->DCF_SERIE  := Self:cSerie
		// DCF->DCF_SDOC  := Self:cSerieDoc
		DCF->DCF_CLIFOR := Self:cCliFor
		DCF->DCF_LOJA   := Self:cLoja
		DCF->DCF_CODPRO := Self:oProdLote:GetProduto()
		DCF->DCF_DATA   := Self:dData
		If Self:lHasHora
			DCF->DCF_HORA   := Self:cHora
		EndIf
		DCF->DCF_STSERV := Self:cStServ
		DCF->DCF_QTDORI := Self:nQtdOri
		DCF->DCF_QUANT  := Self:nQuant
		DCF->DCF_QTSEUM := Self:nQuant2
		DCF->DCF_ORIGEM := Self:cOrigem
		DCF->DCF_NUMSEQ := Self:cNumseq
		DCF->DCF_LOCAL  := Self:oProdLote:GetArmazem()
		DCF->DCF_ENDER  := Self:oOrdEndOri:GetEnder()
		DCF->DCF_ESTFIS := Self:oOrdEndOri:GetEstFis()
		DCF->DCF_LOCDES := Self:oOrdEndDes:GetArmazem()
		DCF->DCF_ENDDES := Self:oOrdEndDes:GetEnder()
		DCF->DCF_LOTECT := Self:oProdLote:GetLoteCtl()
		DCF->DCF_NUMLOT := Self:oProdLote:GetNumLote()
		DCF->DCF_PRDORI := Self:oProdLote:GetPrdOri()
		DCF->DCF_REGRA  := Self:cRegra
		DCF->DCF_PRIORI := Self:cPriori
		DCF->DCF_CODFUN := Self:cCodFun
		DCF->DCF_CARGA  := Self:cCarga
		DCF->DCF_UNITIZ := Self:cIdUnitiz
		If Self:lHasUniDes
			DCF->DCF_UNIDES := Self:cUniDes
		EndIf
		If Self:lHasIdMvOr
			DCF->DCF_IDMVOR := Self:cIdMovOrig
		EndIf
		DCF->DCF_CODNOR := Self:cCodNorma
		DCF->DCF_STRADI := Self:cStradi
		DCF->DCF_SEQUEN := Self:cSequen
		DCF->DCF_IDORI  := Self:cIdOrigem
		DCF->DCF_OK     := Self:cOk
		DCF->DCF_CODREC := Self:cCodRec
		DCF->DCF_DOCPEN := Self:cDocPen
		DCF->DCF_CODPLN := Self:cCodPln
		DCF->(dbCommit()) // Para for�ar atualiza��o do banco
		If lMsUnLock
			DCF->(MsUnLock())
		EndIf
	Else
		lRet := .F.
		Self:cErro := "Recno inv�lido!"
	EndIf
Return lRet
