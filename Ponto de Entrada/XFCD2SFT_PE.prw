#Include "Protheus.ch"

/*
=====================================================================================
Programa.:              PE_XFCD2SFT
Autor....:              TOTVS
Data.....:              25/08/2019
Descricao / Objetivo:   PE para alterar o CD2_MODBC = 0 -  Preço de Maximo
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/
User Function XFCD2SFT()

	If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
		zFMontadora()
	EndIf

Return()

/*
=====================================================================================
Programa.:              ZExecMont
Autor....:              TOTVS
Data.....:              03/02/2022
Descricao / Objetivo:   Executa o P.e. empresa Montadora
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/
Static Function zFMontadora()

	Local aAreaAtu  := GetArea()
	Local aAreaSD2  := {} 
	Local cDoc      := CD2->CD2_DOC
	Local cSerie    := CD2->CD2_SERIE
	Local cCli      := CD2->CD2_CODCLI
	Local cLoja     := CD2->CD2_LOJCLI
	Local aAreaSD1  := {}
	Local aAreaCD2  := CD2->(GetArea())

	//CD2_FILIAL+CD2_TPMOV+CD2_SERIE+CD2_DOC+CD2_CODCLI+CD2_LOJCLI+CD2_ITEM+CD2_CODPRO+CD2_IMP 
	dbSelectArea("CD2")
	dbSetOrder(1)
	dbGotop()
	If dbSeek(xFilial("CD2")+"S"+cSerie+cDoc+cCli+cLoja)
		While !Eof() .And. CD2->(CD2_FILIAL+CD2_TPMOV+CD2_SERIE+CD2_DOC+CD2_CODCLI+CD2_LOJCLI)==;
			xFilial("CD2")+"S"+cSerie+cDoc+cCli+cLoja
			If CD2->CD2_TPMOV =="S" .And. Alltrim(CD2->CD2_IMP) == "SOL"
				If Posicione("SB1",1,xFilial("SB1")+CD2->CD2_CODPRO,"B1_GRUPO") == "VEIA"
					SD2->(dbSetOrder(3))
					aAreaSD2 := GetArea()
					If SD2->(dbSeek(xFilial("SD2")+CD2->(CD2_DOC+CD2_SERIE+CD2_CODCLI+CD2_LOJCLI+CD2_CODPRO+SUBSTR(CD2_ITEM,1,2))))
						If Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_DUPLIC") == "S"
							RecLock("CD2",.F.)
							CD2->CD2_MODBC := "0"
							MsUnlock()
						Endif
					Endif
					RestArea(aAreaSD2)
				Endif
			Endif
			CD2->(dbSkip())
		Enddo
	ElseIf !Empty(cCli)
		If CD2->(dbSeek(xFilial("CD2")+"E"+cSerie+cDoc+cCli+cLoja))
			While CD2->(!Eof()) .And. CD2->(CD2_FILIAL+CD2_TPMOV+CD2_SERIE+CD2_DOC+CD2_CODCLI+CD2_LOJCLI) == ;
				xFilial("CD2")+"E"+cSerie+cDoc+cCli+cLoja
				If CD2->CD2_TPMOV == "E" .And. Alltrim(CD2->CD2_IMP) == "SOL"
					If Posicione("SB1",1,xFilial("SB1")+CD2->CD2_CODPRO,"B1_GRUPO") == "VEIA"
						SD1->(dbSetOrder(1))
						aAreaSD1 := GetArea()
						If SD1->(dbSeek(xFilial("SD1")+CD2->(CD2_DOC+CD2_SERIE+CD2_CODCLI+CD2_LOJCLI+CD2_CODPRO+CD2_ITEM)))
							If !Empty(SD1->D1_NFORI) // soh faz para devolucao de vendas
								If Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_DUPLIC") == "S"
									CD2->(RecLock("CD2",.F.))
									CD2->CD2_MODBC := "0"
									CD2->(MsUnlock())
								Endif
							Endif	
						Endif
						RestArea(aAreaSD1)
					Endif
				Endif
				CD2->(dbSkip())
			Enddo
		Endif	
	Endif

	CD2->(RestArea(aAreaCD2))
	RestArea(aAreaAtu)

Return()
