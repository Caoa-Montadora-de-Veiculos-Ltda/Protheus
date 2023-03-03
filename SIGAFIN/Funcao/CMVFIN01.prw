#include 'protheus.ch'
#include 'parmtype.ch'

// rotina chamada pelo ponto de entrada FA050FIN
// faz o tratamento dos titulos a pagar gerados pela rotina de processo aquisicao do siscoserv, 
// quando tem rateio das entidades contabeis, eh necessario alterar o comportamento do titulo, fazendo o 
// rateio contabil do titulo e contabilizando pelo LP de rateio
User function CMVFIN01()

Local aArea := {SE2->(GetArea()),EJX->(GetArea()),GetArea()}
Local cProcesso := ""
Local cTipo := ""
Local aEnt := {}
Local nPos := 0
Local nTotalEnt := 0
Local nCnt := 0
Local nCnt1 := 0
Local nPerc := 0
Local nPercEnt := 0
Local nValor := 0
Local nValorTitTot := 0
Local cArqRat := ""
Local aAltera := {}
Local nTotalTit := 0

Private aItensCTB := {} // usada no fina050
Private cPrograma := "FINA050" // usada no fina050
 
If FWIsInCallStack("IS400GRAVA") .and. Alltrim(SE2->E2_ORIGEM) == "SIGAESS" .and. SE2->E2_PREFIXO == "ESS"
	cTipo := Subs(SE2->E2_HIST,6,1)
	cProcesso := Subs(SE2->E2_HIST,7,6)
	EJX->(dbSetOrder(1))
	EJX->(dbSeek(xFilial("EJX")+cTipo+cProcesso))
	While EJX->(!Eof()) .and. xFilial("EJX")+cTipo+cProcesso == EJX->EJX_FILIAL+EJX->EJX_TPPROC+Alltrim(EJX->EJX_PROCES)
		If (nPos:=aScan(aEnt,{ |x| x[1]+x[2]+x[3]+x[4] == EJX->EJX_XCONTA+EJX->EJX_XCCUST+EJX->EJX_XITEM+EJX->EJX_XCLVL })) == 0
			aAdd(aEnt,{EJX->EJX_XCONTA,EJX->EJX_XCCUST,EJX->EJX_XITEM,EJX->EJX_XCLVL,EJX->EJX_VL_REA})
		Else
			aEnt[nPos][5] += EJX->EJX_VL_REA
		Endif
		EJX->(dbSkip())
	Enddo
	
	// somente faz rateio se houver mais de uma linha de combinacoes de entidades diferentes
	If Len(aEnt) > 1
		// carrega valor total dos itens
		aEval(aEnt,{|x| nTotalEnt+=x[5]}) 
		nTotalTit := SE2->E2_VALOR
		
		// carrega campos da tabela CTJ, igual a tela padrao de rateio, quando este eh feito pelo usuario
		aCampos := F050HeadCT("511"/*cPadrao*/,"FINA050"/*cProg*/,aAltera,1/*nTipo*/)
		
		// prepara array aitensctb, que serah usado na fina050, para popular a tabela CTJ
		For nCnt:=1 To Len(aEnt)
			aAdd(aItensCTB,{})
			For nCnt1:=1 To Len(aCampos)
				aAdd(aItensCTB[Len(aItensCTB)],{aCampos[nCnt1][1],Nil})
			Next
		Next
		
		// popula campos que serao gravados na CV4
		For nCnt:=1 To Len(aEnt)
			If (nPos:=aScan(aItensCTB[nCnt],{ |x| AllTrim(x[1]) == "CTJ_DEBITO"})) > 0
				aItensCTB[nCnt][nPos][2] := aEnt[nCnt][1]
			Endif
			If (nPos:=aScan(aItensCTB[nCnt],{ |x| AllTrim(x[1]) == "CTJ_CCD"})) > 0
				aItensCTB[nCnt][nPos][2] := aEnt[nCnt][2]
			Endif
			If (nPos:=aScan(aItensCTB[nCnt],{ |x| AllTrim(x[1]) == "CTJ_ITEMD"})) > 0
				aItensCTB[nCnt][nPos][2] := aEnt[nCnt][3]
			Endif
			If (nPos:=aScan(aItensCTB[nCnt],{ |x| AllTrim(x[1]) == "CTJ_CLVLDB"})) > 0
				aItensCTB[nCnt][nPos][2] := aEnt[nCnt][4]
			Endif
			If (nPos:=aScan(aItensCTB[nCnt],{ |x| AllTrim(x[1]) == "CTJ_HIST"})) > 0
				aItensCTB[nCnt][nPos][2] := "RATEIO CMVFIN01"
			Endif
			If (nPos:=aScan(aItensCTB[nCnt],{ |x| AllTrim(x[1]) == "CTJ_FLAG"})) > 0
				aItensCTB[nCnt][nPos][2] := .F. // indica que linha nao estah deletada
			Endif
			If (nPos:=aScan(aItensCTB[nCnt],{ |x| AllTrim(x[1]) == "CTJ_PERCEN"})) > 0
				nPerc := NoRound((aEnt[nCnt][5]/nTotalEnt)*100,2)
				nPercEnt += nPerc
				aItensCTB[nCnt][nPos][2] := nPerc
				
				// carrega diferenca no ultimo item
				If nCnt == Len(aEnt)
					If 100-nPercEnt > 0
						nPerc += 100-nPercEnt
						aItensCTB[nCnt][nPos][2] := nPerc
					Endif
				Endif
			Endif
			If (nPos:=aScan(aItensCTB[nCnt],{ |x| AllTrim(x[1]) == "CTJ_VALOR"})) > 0
				nPos1 := aScan(aItensCTB[nCnt],{ |x| AllTrim(x[1]) == "CTJ_PERCEN"})
				//nValor := NoRound((aItensCTB[nCnt][nPos1][2]/100)*nTotalEnt,2)
				nValor := NoRound((aItensCTB[nCnt][nPos1][2]/100)*nTotalTit,2)
				nValorTitTot += nValor
				aItensCTB[nCnt][nPos][2] := nValor
				
				// carrega diferenca no ultimo item
				If nCnt == Len(aEnt)
					//If nTotalEnt-nValorTitTot > 0
					If nTotalTit-nValorTitTot > 0
						//nValor += nTotalEnt-nValorTitTot
						nValor += nTotalTit-nValorTitTot
						aItensCTB[nCnt][nPos][2] := nValor
					Endif
				Endif
			Endif	
		Next
		
		// atribui conteudo vazio aos demais campos do array, para nao gerar erro na gravacao da CV4
		For nCnt:=1 To Len(aItensCTB)
			For nCnt1:=1 To Len(aItensCTB[nCnt])
				If aItensCTB[nCnt][nCnt1][2] == Nil
					aItensCTB[nCnt][nCnt1][2] := CriaVar(aItensCTB[nCnt][nCnt1][1])
				Endif
			Next
		Next			

		// chama rotina padrao para gerar o rateio ( CV4 ) e contabilizar
		If Len(aItensCTB) > 0 .and. Len(aEnt) > 0
			// forca campo de rateio para Sim, senao funcao CtbRatFin nao faz nada		
			SE2->(RecLock("SE2",.F.))		
			SE2->E2_RATEIO := "S"
			SE2->(MsUnlock())
			
			//Function CtbRatFin(cPadrao,cProg,cLote,nTipo,cCodRateio,nOpc,cDebito,cCredito,cHistorico,nHdlPrv,nTotal,aFlagCTB, cProcPCO, cItemPCO, cRecPag )
			cArqRat := CtbRatFin("511"/*cPadrao*/,"FINA050"/*cProg*/,"008850"/*cLote*/,1/*nTipo*/,/*cCodRateio*/,3/*nOpc*/)//,cDebito,cCredito,cHistorico,nHdlPrv,nTotal,aFlagCTB, cProcPCO, cItemPCO, cRecPag )
			
			// se retorno foi com sucesso, grava sequencia da CV4, caso contrato, retira rateio do titulo
			SE2->(RecLock("SE2",.F.))		
			If Len(Alltrim(cArqRat)) > TamSX3("CV4_FILIAL")[1]+TamSX3("CV4_DTSEQ")[1]
				SE2->E2_ARQRAT := cArqRat
			Else		
				SE2->E2_RATEIO := "N"
			Endif	
			SE2->(MsUnlock())
		Endif
	Elseif Len(aEnt) = 1 // gravacao das entidades sem rateio
		SE2->(RecLock("SE2",.F.))
		SE2->E2_CONTAD := aEnt[1][1]
		SE2->E2_CCUSTO := aEnt[1][2]
		SE2->E2_ITEMCTA := aEnt[1][3]
		SE2->E2_CLVL := aEnt[1][4]
		SE2->(MsUnlock())
	Endif	
Endif

aEval(aArea,{|x| RestArea(x)})

return()