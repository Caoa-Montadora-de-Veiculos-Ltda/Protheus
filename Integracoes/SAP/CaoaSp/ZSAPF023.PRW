#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*
=========================================================================================================
Programa.................: ZSAPF023
Autor:...................: Totvs
Data.....................: Jul/19
Descrição / Objetivo.....: Gravacao de campos de entidades contabeis
Doc. Origem..............: 
Solicitante..............: Cliente
Uso......................: Caoa
Obs......................: Rotina chamada pelo ponto de entrada MT103FIM
=========================================================================================================
*/
User Function ZSAPF023()

Local aArea := {SD1->(GetArea()),SE2->(GetArea()),GetArea()}
Local cTipo := SF1->F1_TIPO 
Local cDoc := SF1->F1_DOC
Local cSerie := SF1->F1_SERIE
Local cFornece := SF1->F1_FORNECE
Local cLoja := SF1->F1_LOJA
Local cDupl := SF1->F1_DUPL

If !Empty(cDupl)
	If !cTipo $ "B/D"
	
		SD1->(dbSetOrder(1))
		If SD1->(dbSeek(xFilial("SD1")+cDoc+cSerie+cFornece+cLoja))
			SE2->(dbSetOrder(6))
			If SE2->(dbSeek(xFilial("SE2")+cFornece+cLoja+cSerie+cDupl))
				While SE2->(!Eof()) .and. SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == ;
				xFilial("SE2")+cFornece+cLoja+cSerie+cDupl
					If SE2->E2_TIPO == MVNOTAFIS			
						SE2->(RecLock("SE2",.F.))
						If Empty(SE2->E2_CONTAD) .and. !Empty(SD1->D1_CONTA)
							SE2->E2_CONTAD = SD1->D1_CONTA
						Endif
						If Empty(SE2->E2_CCUSTO) .and. !Empty(SD1->D1_CC)	
							SE2->E2_CCUSTO = SD1->D1_CC
						Endif
						If Empty(SE2->E2_CLVL) .and. !Empty(SD1->D1_CLVL)	
							SE2->E2_CLVL = SD1->D1_CLVL
						Endif
						If Empty(SE2->E2_ITEMCTA) .and. !Empty(SD1->D1_ITEMCTA)	
							SE2->E2_ITEMCTA = SD1->D1_ITEMCTA
						Endif	
						SE2->(MsUnlock())	
					Endif
					SE2->(dbSkip())
				Enddo
			Endif
		Endif			
	Endif
Endif

aEval(aArea,{|x| RestArea(x)})
	
Return()
