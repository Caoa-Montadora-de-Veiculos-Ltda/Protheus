#Include "Protheus.ch"

/*
=====================================================================================
Programa.:              MACSOLICMS_PE
Autor....:              
Data.....:              01/07/2019
Descricao / Objetivo:   PE para alterar o ICMS ST da MATFIS - Calculo Reverso
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/
User Function MACSOLICMS()

	Local _cEmp  	:= FWCodEmp()
	Local _aRet 	:= {}
	
//ParamIxb[3] //Base de retencao ICMS Solidario
//ParamIxb[4] //Alíquota Solidário
//ParamIxb[5]  //Valor do ICMS Solidario

	If _cEmp == "2010" //Executa o p.e. somente para Anapolis.
		_aRet := zFMontadora()
    Else
        //Retorna os valores padrões quando Barueri
        _aRet := {ParamIxb[3],ParamIxb[4],ParamIxb[5]}
    EndIf

Return(_aRet)

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

Local aArea 		:= {GetArea()}
Local cOperacao 	:= ParamIxb[1] //Tipo de operação Entrada ou Saída
Local nItem     	:= ParamIxb[2] //Item
Local nBaseSol  	:= ParamIxb[3] //Base de retencao ICMS Solidario
Local nAliqSol  	:= ParamIxb[4] //Alíquota Solidário
Local nValsol   	:= ParamIxb[5]  //Valor do ICMS Solidario
Local nValIC    	:= 0
Local lLog 			:= .F.
Local nRedBase		:= 0
Local aExcecao		:= {}
//Local nBaseSolAnt := 0
Local lVerRed 		:= .F.
Local nValBaseTab 	:= 0
Local lVeia060 		:= .F.
Local lMata410 		:= .F.
Local lDev 			:= .F.
Local aDev 			:= {}
Local _F4MKPSOL		:= ""
Do Case
Case FWIsInCallStack("MAPVLNFS") // rotina de documento de saida
	//Conout(" MACSOLICMS - MAPVLNFS - C6_XBASST - " + SC6->C6_NUM + "-" + SC6->C6_ITEM + "-" + SC6->C6_PRODUTO + " - " +  cValToChar(SC6->C6_VALOR) + "-" + cValToChar(SC6->C6_XBASST))
	If (isInCallStack("VEIA060") .or. isInCallStack("VEIXX002") .Or. Upper(Alltrim(FunName())) == "ZFATF019") .And. ;
		cOperacao == 'S' .And.;
		nItem > 0  
			nValIC   := MaFisRet(nItem,"IT_VALICM" )
			//nBaseSol := SC6->C6_XBASST
			If (isInCallStack("VEIA060") .or. isInCallStack("VEIXX002"))
				_F4MKPSOL:= Posicione("SF4",1,xFilial("SF4")+M->VVA_CODTES,"F4_MKPSOL")
				nBaseSol := If(_F4MKPSOL == "1",0,M->VVA_XBASST)      //FWFldGet("VRK_XBASST")
			Else
				_F4MKPSOL:= Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_MKPSOL")
				nBaseSol := If(_F4MKPSOL == "1",0,SC6->C6_XBASST)
			EndIf
			//nBaseSolAnt := nBaseSol
			/*
			If nBaseSol > 0 .and. nAliqSol > 0 .and. ((nBaseSol*(nAliqSol/100)) - nValIC) > 0
				nValSol := (nBaseSol*(nAliqSol/100)) - nValIC
			Endif	
			Return {nBaseSol,nAliqSol,nValsol}
			*/
	Endif

Case FWIsInCallStack("VEIXX002") // rotina de atendimento sigavei
	//Conout(" MACSOLICMS - VEIXX002 - VVA_XBASST - " + cValToChar(M->VVA_XBASST))
	If (isInCallStack("VEIA060") .or. isInCallStack("VEIXX002")) .And. ;
		cOperacao == 'S' .And.;
		nItem > 0  
			nValIC   := MaFisRet(nItem,"IT_VALICM" )
			nBaseSol := M->VVA_XBASST      //FWFldGet("VRK_XBASST")
			//nBaseSolAnt := nBaseSol
			/*
			If nBaseSol > 0 .and. nAliqSol > 0 .and. ((nBaseSol*(nAliqSol/100)) - nValIC) > 0
				nValSol := (nBaseSol*(nAliqSol/100)) - nValIC
			Endif	
			Return {nBaseSol,nAliqSol,nValsol}
			*/
	Endif

Case FWIsInCallStack("U_tstZonaFranca")
	If cOperacao == 'S' .And. nItem > 0

		nValIC   := MaFisRet(nItem,"IT_VALICM" )
		nBaseSol := U_BASSTCAOA("HYU", "000015", "HEH76B857", "DA12AESWAS", "20202021", "01")
		lLog := .f.
		lVeia060 := .T.
		nValBaseTab := U_BASSTCAOA("HYU", "000015", "HEH76B857", "DA12AESWAS", "20202021", "01")

		// compara base do icms st gravada no campo com valor retornado pela tabela de preco, se forem iguais eh porque a reducao de base ainda nao foi avaliada,
		// ou nao existe reducao, 
		// se valores forem diferentes, pode ser devido a base jah ter sido reduzida, neste caso, nao submete novamente a analise da reducao,
		// para nao reduzir a base novamente e ficar em cascata esta reducao.
		If nBaseSol == nValBaseTab .and. !Empty(nBaseSol)
			lVerRed := .T.
		Endif	
	EndIf

Case (FWIsInCallStack("VEIA060") .or. FWIsInCallStack("U_CMVAUT01") .or. FWIsInCallStack("WSCAOA_INCLUSAO_PEDIDO_ATACADO")) // rotina de pedido de veiculo do sigavei ou inclusao de pedido de veiculo do autoware
	//Conout(" MACSOLICMS - VRK_XBASST - " + cValToChar(FWFldGet("VRK_XBASST")))
	If (isInCallStack("VEIA060") .or. FWIsInCallStack("U_CMVAUT01") .or. FWIsInCallStack("WSCAOA_INCLUSAO_PEDIDO_ATACADO")) .And.;
		cOperacao == 'S' .And.;
		nItem > 0  
			nValIC   := MaFisRet(nItem,"IT_VALICM" )
			nBaseSol := FWFldGet("VRK_XBASST")
			//nBaseSolAnt := nBaseSol
			lLog := .T.
			lVeia060 := .T.
			nValBaseTab := U_BASSTCAOA()
			// compara base do icms st gravada no campo com valor retornado pela tabela de preco, se forem iguais eh porque a reducao de base ainda nao foi avaliada,
			// ou nao existe reducao, 
			// se valores forem diferentes, pode ser devido a base jah ter sido reduzida, neste caso, nao submete novamente a analise da reducao,
			// para nao reduzir a base novamente e ficar em cascata esta reducao.
			If nBaseSol == nValBaseTab .and. !Empty(nBaseSol)
				lVerRed := .T.
			Endif	
			/*
			If nBaseSol > 0 .and. nAliqSol > 0 .and. ((nBaseSol*(nAliqSol/100)) - nValIC) > 0
				nValSol := (nBaseSol*(nAliqSol/100)) - nValIC
			Endif	
			Conout(" MACSOLICMS - Pedido SigaVei: "+FWFldGet("VRK_PEDIDO")+" Veiculo: "+MaFisRet(nItem,"IT_PRODUTO")+" Item: "+cValToChar(nItem)+;
			" - nBaseSol: "+cValToChar(nBaseSol)+" nAliqSol: "+cValToChar(nAliqSol)+" nValsol: "+cValToChar(nValsol))
			Return {nBaseSol,nAliqSol,nValsol}
			*/
	Endif

Case FWIsInCallStack("Ma410Impos") // rotina de planilha financeira do pedido de venda
	//Conout(" MACSOLICMS - Ma410Impos - C6_XBASST - " + SC6->C6_NUM + "-" + SC6->C6_ITEM + "-" + SC6->C6_PRODUTO + " - " +  cValToChar(SC6->C6_VALOR) + "-" + cValToChar(SC6->C6_XBASST))
	If Type("Inclui") != "U" .and. !Inclui .and. SC5->(!Eof()) .and. SC5->(!Bof()) .and. ;
		cOperacao == 'S' .And.;
		nItem > 0  
			nValIC   := MaFisRet(nItem,"IT_VALICM" )
			nBaseSol := SC6->C6_XBASST
			//nBaseSolAnt := nBaseSol
			lLog := .T.
			lMata410 := .T.
			/*
			If nBaseSol > 0 .and. nAliqSol > 0 .and. ((nBaseSol*(nAliqSol/100)) - nValIC) > 0
				nValSol := (nBaseSol*(nAliqSol/100)) - nValIC
			Endif	
			Return {nBaseSol,nAliqSol,nValsol}
			*/
	Endif

Case FWIsInCallStack("VEIXA002") // rotina de inclusao de nota de entrada de devolucao de venda do sigavei
	//Conout(" MACSOLICMS - VEIXX002 - VVA_XBASST - " + cValToChar(M->VVA_XBASST))
	If isInCallStack("VXA002DEV") .And. isInCallStack("VA002BVV0") .and. ;
		cOperacao == 'E' .And.;
		nItem > 0  
			lDev := .T.
			If VV1->(Found()) .and. !IsInCallStack("MATA103")
				aDev := MacSolSD2Dev(cChassi)
				If Len(aDev) > 0
					//nBaseSol := GetAdvfVal("SD2","D2_BRICMS",xFilial("SD2")+MaFisRet(nItem,"IT_NFORI")+MaFisRet(nItem,"IT_SERORI")+MaFisRet(,"NF_CODCLIFOR")+MaFisRet(,"NF_LOJA")+MaFisRet(nItem,"IT_PRODUTO"),3,0)
					nBaseSol := GetAdvfVal("SD2","D2_BRICMS",xFilial("SD2")+aDev[1]+aDev[2]+aDev[3]+aDev[4]+aDev[5],3,0)
					nAliqSol := GetAdvfVal("SD2","D2_ALIQSOL",xFilial("SD2")+aDev[1]+aDev[2]+aDev[3]+aDev[4]+aDev[5],3,0)
					nValSol := GetAdvfVal("SD2","D2_ICMSRET",xFilial("SD2")+aDev[1]+aDev[2]+aDev[3]+aDev[4]+aDev[5],3,0)
				Endif
			Elseif IsInCallStack("MATA103")	
				If !Empty(MaFisRet(nItem,"IT_NFORI")) .and. !Empty(MaFisRet(nItem,"IT_SERORI")) .and. !Empty(MaFisRet(,"NF_CODCLIFOR")) .and. !Empty(MaFisRet(,"NF_LOJA")) .and. !Empty(MaFisRet(nItem,"IT_PRODUTO"))
					nBaseSol := GetAdvfVal("SD2","D2_BRICMS",xFilial("SD2")+MaFisRet(nItem,"IT_NFORI")+MaFisRet(nItem,"IT_SERORI")+MaFisRet(,"NF_CODCLIFOR")+MaFisRet(,"NF_LOJA")+MaFisRet(nItem,"IT_PRODUTO"),3,0)
					nAliqSol := GetAdvfVal("SD2","D2_ALIQSOL",xFilial("SD2")+MaFisRet(nItem,"IT_NFORI")+MaFisRet(nItem,"IT_SERORI")+MaFisRet(,"NF_CODCLIFOR")+MaFisRet(,"NF_LOJA")+MaFisRet(nItem,"IT_PRODUTO"),3,0)
					nValSol := GetAdvfVal("SD2","D2_ICMSRET",xFilial("SD2")+MaFisRet(nItem,"IT_NFORI")+MaFisRet(nItem,"IT_SERORI")+MaFisRet(,"NF_CODCLIFOR")+MaFisRet(,"NF_LOJA")+MaFisRet(nItem,"IT_PRODUTO"),3,0)
				Endif	
			Endif
	Endif
	
Case FWIsInCallStack("MATA103") .and. !FWIsInCallStack("VEIXA002") // rotina de documento de entrada sem ser pelo sigavei
	If cOperacao == 'E' .And.;
	nItem > 0  
		lDev := .T.
		If !Empty(MaFisRet(nItem,"IT_NFORI")) .and. !Empty(MaFisRet(nItem,"IT_SERORI")) .and. !Empty(MaFisRet(,"NF_CODCLIFOR")) .and. !Empty(MaFisRet(,"NF_LOJA")) .and. !Empty(MaFisRet(nItem,"IT_PRODUTO"))
			nBaseSol := GetAdvfVal("SD2","D2_BRICMS",xFilial("SD2")+MaFisRet(nItem,"IT_NFORI")+MaFisRet(nItem,"IT_SERORI")+MaFisRet(,"NF_CODCLIFOR")+MaFisRet(,"NF_LOJA")+MaFisRet(nItem,"IT_PRODUTO"),3,0)
			nAliqSol := GetAdvfVal("SD2","D2_ALIQSOL",xFilial("SD2")+MaFisRet(nItem,"IT_NFORI")+MaFisRet(nItem,"IT_SERORI")+MaFisRet(,"NF_CODCLIFOR")+MaFisRet(,"NF_LOJA")+MaFisRet(nItem,"IT_PRODUTO"),3,0)
			nValSol := GetAdvfVal("SD2","D2_ICMSRET",xFilial("SD2")+MaFisRet(nItem,"IT_NFORI")+MaFisRet(nItem,"IT_SERORI")+MaFisRet(,"NF_CODCLIFOR")+MaFisRet(,"NF_LOJA")+MaFisRet(nItem,"IT_PRODUTO"),3,0)
		Endif
	Endif

EndCase

If !Empty(nBaseSol)
	// verifica se tem reducao na base
	If lVerRed
		nRedBase := MaFisRet(nItem,"IT_PREDST") // percentual de reducao do icms st
		If Len(MaFisRet(nItem,"IT_EXCECAO")) > 0
			aExcecao := MaFisRet(nItem,"IT_EXCECAO")
			If !Empty(aExcecao[26])
				nRedBase := aExcecao[26] // Redução da Base de Icms ST - FP_F7_BSICMST
			Endif	
		Endif	
		If !Empty(nRedBase)
			nBaseSol := nBaseSol*(nRedBase/100)
			FWFldPut("VRK_XBASST",nBaseSol)
		Endif
	Endif

	If !lDev
		If nBaseSol > 0 .and. nAliqSol > 0 .and. ((nBaseSol*(nAliqSol/100)) - nValIC) > 0
			nValSol := (nBaseSol*(nAliqSol/100)) - nValIC
		Endif	
	Endif	

	If lLog
		Conout(" MACSOLICMS - "+IIf(lVeia060,"Pedido SigaVei: "+FWFldGet("VRK_PEDIDO"),IIf(lMata410,"Pedido SigaFat: "+M->C5_NUM,""))+;
		" Veiculo: "+MaFisRet(nItem,"IT_PRODUTO")+" Item: "+cValToChar(nItem)+;
		" - nBaseSol: "+cValToChar(nBaseSol)+" nAliqSol: "+cValToChar(nAliqSol)+" nValsol: "+cValToChar(nValsol))
	Endif	
Endif

aEval(aArea,{|x| RestArea(x)})

Return ({nBaseSol,nAliqSol,nValSol})


Static Function MacSolSD2Dev(cChassi)

Local aArea := {GetArea()}
Local cAliasTrb := GetNextAlias()
Local cQ := ""
Local aRet := {}

cQ := "SELECT MAX(R_E_C_N_O_) SD2_RECNO "
cQ += "FROM "+retSQLName("SD2")+" SD2 "
cQ += "WHERE "
cQ += "D2_FILIAL = '"+xFilial("SD2")+"' "
cQ += "AND TRIM(D2_NUMSERI) = '"+Alltrim(cChassi)+"' "
cQ += "AND SD2.D_E_L_E_T_ = ' ' "
					
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
					
If (cAliasTrb)->(!Eof()) .and. !Empty((cAliasTrb)->SD2_RECNO)
	SD2->(dbGoto((cAliasTrb)->SD2_RECNO))
	If SD2->(Recno()) == (cAliasTrb)->SD2_RECNO
		aRet := {SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA,SD2->D2_COD}
	Endif	
Endif
					
(cAliasTrb)->(dbCloseArea())

aEval(aArea,{|x| RestArea(x)})

return(aRet)
