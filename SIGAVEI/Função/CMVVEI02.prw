#include 'protheus.ch'
#include 'parmtype.ch'
/*
=====================================================================================
Programa.:              CMVVEI02
Autor....:              TOTVS
Data.....:              Nov/2019
Descricao / Objetivo:   Programa chamado pelos PE´s MaCOFVeic / MaIPIVeic / MaPISVeic
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/
User Function CMVVEI02(cFunc)

Local nItem     	:= ParamIxb[1] //Item
Local nBaseImp  	:= ParamIxb[2] //Base do imposto
Local nAliqImp  	:= ParamIxb[3] //Alíquota do imposto
Local nValImp   	:= ParamIxb[4] //Valor do Imposto
Local cCmpSC6 		:= ""
Local cCmpVVA 		:= ""
Local cCmpVRK 		:= ""
Local cAlias 		:= ""
Local nBaseNovoImp 	:= nBaseImp
Local nValNovoImp 	:= nValImp
Local nPercComis 	:= 0
//Local nValVDA 		:= 0
Local cOper 		:= ""
Local cOperNCalc 	:= GetMv("MV_XVEI021",,"01")
Local oModelVRJ 	:= Nil
Local aArea 		:= {GetArea()}	
Local cNextAlias 	:= GetNextAlias()
Local cFilSC5 		:= ""
Local nRecSC5 		:= 0

Local nVRK_ValVDA := 0

If Empty(cOperNCalc)
	Return({nBaseNovoImp,nAliqImp,nValNovoImp})	
Endif

if Alltrim(Upper(cFunc)) == "U_MACOFVEIC"
	cCmpSC6	:= "C6_XBASCOF"
	cCmpVVA	:= "VVA_XBASCO"
	cCmpVRK	:= "VRK_XBASCO"			
Elseif Alltrim(Upper(cFunc)) == "U_MAIPIVEIC"
	cCmpSC6	:= "C6_XBASIPI"
	cCmpVVA	:= "VVA_XBASIP"
	cCmpVRK	:= "VRK_XBASIP"			
Elseif Alltrim(Upper(cFunc)) == "U_MAPISVEIC"
	cCmpSC6	:= "C6_XBASPIS"
	cCmpVVA	:= "VVA_XBASPI"
	cCmpVRK	:= "VRK_XBASPI"			
Endif

If FWIsInCallStack("MAPVLNFS") //-- Faturamento
	If (isInCallStack("VEIA060") .or. isInCallStack("VEIXX002")) .And. nItem > 0 .and. !Empty(nBaseNovoImp)  
		//If !FWFldGet("VRJ_TIPVEN") $ cOperNCalc
		//cOper := Vei02Oper()
		//If !cOper $ cOperNCalc .and. !Empty(cOper)
		If isInCallStack("VEIA060") .and. Type("oModel") == "O"
			oModelVRJ := OMODEL:GetModel("MODEL_VRJ")
			cOper := oModelVRJ:GetValue("VRJ_TIPVEN",nItem)
		Else
			//cOper := FWFldGet("VRJ_TIPVEN",nItem)
			//cOper := VRJ->VRJ_TIPVEN
			If !Empty(M->VVA_VRKNUM)
				cOper := Vei02Oper(M->VVA_VRKNUM)
			EndIf
		Endif	
		nVRK_ValVDA := Vei02ValVda(M->VVA_VRKNUM, M->VVA_VRKITE)
		nVrkPre		:= Vei02Pre(M->VVA_VRKNUM, M->VVA_VRKITE)
		If !Empty(cOper) .and. !(cOper $ cOperNCalc)		
			cAlias := "SC6"
			//Vei02Calc(@nPercComis,@nBaseNovoImp,@nValNovoImp,cFunc,SC6->C6_XVEIVDA)
			Vei02Calc(@nPercComis,@nBaseNovoImp,@nValNovoImp,cFunc,nVRK_ValVDA,cOper,nVrkPre)
			If !Empty(nPercComis)
				&(cAlias+"->"+cCmpSC6) := nBaseNovoImp
			Endif	
		Endif	
	Endif
Elseif FWIsInCallStack("VEIXX002") //-- Geração do atendimento
	If /*isInCallStack("VEIA060") .And.*/ nItem > 0 .and. !Empty(nBaseNovoImp)   
		//If !FWFldGet("VRJ_TIPVEN") $ cOperNCalc
		//cOper := Vei02Oper()
		//If !cOper $ cOperNCalc .and. !Empty(cOper)
		If isInCallStack("VEIA060") .and. Type("oModel") == "O"
			oModelVRJ := OMODEL:GetModel("MODEL_VRJ")
			cOper := oModelVRJ:GetValue("VRJ_TIPVEN",nItem)
		Else
			//cOper := FWFldGet("VRJ_TIPVEN",nItem)
			//cOper := VRJ->VRJ_TIPVEN
			If !Empty(M->VVA_VRKNUM)
				cOper := Vei02Oper(M->VVA_VRKNUM)
			EndIf
		Endif	
		nVRK_ValVDA := Vei02ValVda(M->VVA_VRKNUM, M->VVA_VRKITE)
		nVrkPre		:= Vei02Pre(M->VVA_VRKNUM, M->VVA_VRKITE)
		If !Empty(cOper) .and. !(cOper $ cOperNCalc)
			//cAlias := "VVA"
			Vei02Calc(@nPercComis,@nBaseNovoImp,@nValNovoImp,cFunc,nVRK_ValVDA,cOper,nVrkPre)
		Endif	
	Endif
Elseif FWIsInCallStack("VEIA060")	//-- Geração de pedido (VEI)
	If isInCallStack("VEIA060") .And. nItem > 0 .and. !Empty(nBaseNovoImp)  
		//If !FWFldGet("VRJ_TIPVEN") $ cOperNCalc
		//cOper := Vei02Oper()
		//If !cOper $ cOperNCalc .and. !Empty(cOper)
		If Type("oModel") == "O"
			oModelVRJ := OMODEL:GetModel("MODEL_VRJ")
			cOper := oModelVRJ:GetValue("VRJ_TIPVEN",nItem)
		Else
			//cOper := FWFldGet("VRJ_TIPVEN",nItem)
			cOper := M->VRJ_TIPVEN
		Endif	
		If !Empty(cOper) .and. !(cOper $ cOperNCalc)		
			cAlias := "VRK"
			Vei02Calc(@nPercComis,@nBaseNovoImp,@nValNovoImp,cFunc,FWFldGet("VRK_VALVDA"),cOper,FWFldGet("VRK_VALPRE"))
			If !Empty(nPercComis)
				FWFldPut(cCmpVRK,nBaseNovoImp)
			Endif	
		Endif
	Endif	
Elseif FWIsInCallStack("Ma410Impos")	//-- Visualização de pedido (FAT)
	If nItem > 0 .and. !Empty(nBaseNovoImp) .and. Type("Inclui") != "U" .and. !Inclui .and. SC5->(!Eof()) .and. SC5->(!Bof())
		cFilSC5 := xFilial("SC5")
		nRecSC5 := SC5->(Recno())
		
		If Select(cNextAlias) > 0
			(cNextAlias)->(DbClosearea())
		Endif
		
		BeginSql Alias cNextAlias
			SELECT DISTINCT VRJ_TIPVEN,VVA_VRKNUM,VVA_VRKITE
			FROM %Table:VRJ% VRJ, %Table:VRK% VRK, %Table:VV0% VV0, %Table:SC5% SC5, %Table:VVA% VVA
			WHERE
			VRJ.%NotDel%
			AND VRK.%NotDel%
			AND VV0.%NotDel%
			AND SC5.%NotDel%
			AND VVA.%NotDel%
			AND C5_FILIAL = %Exp:cFilSC5%
			AND C5_FILIAL = VRJ_FILIAL
			AND C5_FILIAL = VRK_FILIAL
			AND C5_FILIAL = VV0_FILIAL
			AND C5_FILIAL = VVA_FILIAL
			AND C5_NOTA = VV0_NUMNFI
			AND VV0_NUMTRA = VRK_NUMTRA
			AND VRK_PEDIDO = VRJ_PEDIDO
			AND VV0_NUMTRA = VVA_NUMTRA
			AND SC5.R_E_C_N_O_ = %Exp:nRecSC5%
		EndSql
		
		While (cNextAlias)->(!Eof())
			cOper := (cNextAlias)->VRJ_TIPVEN
			nVRK_ValVDA := Vei02ValVda((cNextAlias)->VVA_VRKNUM, (cNextAlias)->VVA_VRKITE)
			nVrkPre		:= Vei02Pre(M->VVA_VRKNUM, M->VVA_VRKITE)
			Exit
		EndDo
		
		(cNextAlias)->(DbClosearea())
		
		If !Empty(cOper) .and. !(cOper $ cOperNCalc)			
			Vei02Calc(@nPercComis,@nBaseNovoImp,@nValNovoImp,cFunc,nVRK_ValVDA,cOper,nVrkPre)
		Endif	
	Endif	
Endif

aEval(aArea,{|x| RestArea(x)})

Return({nBaseNovoImp,nAliqImp,nValNovoImp})


Static Function Vei02Comis(cProd)

Local aArea := {VV2->(GetArea()),GetArea()}	
Local nRet := 0

VV2->(dbSetOrder(7))
If VV2->(dbSeek(xFilial("VV2")+cProd))
	nRet := VV2->VV2_XCOMIS
Endif

aEval(aArea,{|x| RestArea(x)})

Return(nRet)


Static Function Vei02Calc(nPercComis,nBaseNovoImp,nValNovoImp,cFunc,nValVDA,cOper,nValPret)

Local nItem     	:= ParamIxb[1] //Item
Local nBaseImp  	:= ParamIxb[2] //Base do imposto
Local nAliqImp  	:= ParamIxb[3] //Alíquota do imposto
Local nValImp   	:= ParamIxb[4] //Valor do Imposto
Local nValComis		:= 0
Local lArredCof 	:= GetMv("MV_RNDCF2") 
Local lArredPis 	:= GetMv("MV_RNDPS2")
Local lArredIpi 	:= GetMv("MV_RNDIPI")
Local cTesHD80 		:= AllTrim( GetMv("CMV_VEI013") )
Local nCasasArred 	:= GetMv("MV_RNDPREC")
Local bFormBas    	:= Nil
Local bFormImp    	:= Nil
Local lArred      	:= .F.
Local lTiraST     	:= .F.
//Local lPisCof		:= Nil
//Local nVlPrete		:= VRK->VRK_VALPRE
Local cTESTSD 	  	:= SuperGetMV("CMV_TESTSD",.F.,"")
Local lTESTSD 	  	:= (MaFisRet(nItem,"IT_TES") $ cTESTSD)

Local lPisCof	  := .F.
Local nIcms		  := 0
Local nDeduCom	  := 0
Local nAliqDed	  := 0
Local nValDed	  := 0
Local nVlPrete    := nValPret	
Local aExcecao	  := {}

nBaseImp  		:= ParamIxb[2] //Base do imposto
nAliqImp  		:= ParamIxb[3] //AlÃ­quota do imposto
nValImp   		:= ParamIxb[4] //Valor do Imposto
nCasasArred 	:= GetMv("MV_RNDPREC")
nPercComis 		:= Vei02Comis(MaFisRet(nItem,"IT_PRODUTO")) / 100

If !lTESTSD	//-- TES de faturamento p/ veículo test drive (não tem comissão)
	nValComis := nPercComis * nValVDA
EndIf

//If !Empty(nPercComis) .or. lTESTSD
	If Alltrim(Upper(cFunc)) == "U_MACOFVEIC"	
		lArred := lArredCof
		lTiraST := .T.
		lPisCof := .T.
	Endif	

	If Alltrim(Upper(cFunc)) == "U_MAPISVEIC"	
		lArred := lArredPis
		lTiraST := .T.
		lPisCof := .T.
	Endif	

	If Alltrim(Upper(cFunc)) == "U_MAIPIVEIC"	
		lArred := lArredIpi
	Endif

	If !Empty(nPercComis) .or. (lTESTSD .and. lTiraST) .or. (cOper == "04" .and. lTiraST)

		//FATURAMENTO VENDA DIRETA HD80 e HR COM COMISSAO
		aExcecao := MaFisRet(nItem,"IT_EXCECAO") // Executa somente se existe uma excecao fiscal. Evandro/Montilha/Silvana - 06.11.2020
		If MaFisRet(nItem,"IT_TES") $ cTesHD80 .And. cOper == "04" .And. Len(aExcecao) > 0
			If lPisCof

				nIcms 			:= MaFisRet(nItem,"IT_VALICM" )
				If !Empty(aExcecao[18])
					nAliqDed := aExcecao[18] // DEDUÃ‡ÃƒO
				Else 
					nAliqDed := 1 //caso não encontre aliq de dedução, multiplica por 01. Evandro/Montilha/Silvana - 06.11.2020
				Endif	
				nValComis		:= nPercComis * nVlPrete
				nDeduCom 		:= ( nVlPrete - nIcms - nValComis - MAFISRET(nItem,"IT_VALSOL") )
				nValDed			:= nDeduCom * ( nAliqDed / 100 )
				
				nBaseNovoImp	:= nDeduCom - nValDed
				bFormImp 		:= "{|| IIf(lArred,Round(nBaseNovoImp*(nAliqImp/100),nCasasArred),NoRound(nBaseNovoImp*(nAliqImp/100),nCasasArred))}"	
				nValNovoImp 	:= Eval(&bFormImp)
			Else
				bFormBas := "{|| IIf(lArred,Round(nBaseImp-nValComis,nCasasArred),NoRound(nBaseImp-nValComis,nCasasArred))}"
				bFormImp := "{|| IIf(lArred,Round(nBaseNovoImp*(nAliqImp/100),nCasasArred),NoRound(nBaseNovoImp*(nAliqImp/100),nCasasArred))}"		

				nBaseNovoImp := Eval(&bFormBas) - IIF((lTiraST .and. !Empty(MAFISRET(nItem,"IT_BASESOL")) .and. MAFISRET(nItem,"IT_VALSOL") > 0),MAFISRET(nItem,"IT_VALSOL"),0)
				nValNovoImp := Eval(&bFormImp)
			EndIf
		Else
			bFormBas := "{|| IIf(lArred,Round(nBaseImp-nValComis,nCasasArred),NoRound(nBaseImp-nValComis,nCasasArred))}"
			bFormImp := "{|| IIf(lArred,Round(nBaseNovoImp*(nAliqImp/100),nCasasArred),NoRound(nBaseNovoImp*(nAliqImp/100),nCasasArred))}"		

			nBaseNovoImp := Eval(&bFormBas) - IIF((lTiraST .and. !Empty(MAFISRET(nItem,"IT_BASESOL")) .and. MAFISRET(nItem,"IT_VALSOL") > 0),MAFISRET(nItem,"IT_VALSOL"),0)
			nValNovoImp := Eval(&bFormImp)
		EndIf	
	Endif

Return()

Static Function Vei02Oper( cNumPedidoVRJ )

	Local cRetOper := ""
	Local cAliasVRJ := "TTMPVRJ"

	BeginSql Alias cAliasVRJ
		SELECT VRJ_TIPVEN
		  FROM %Table:VRJ% VRJ
		 WHERE
			VRJ.VRJ_FILIAL = %xFilial:VRJ%
			AND VRJ.VRJ_PEDIDO = %exp:cNumPedidoVRJ%
			AND VRJ.%NotDel%
	EndSql
	If (cAliasVRJ)->(!Eof())
		cRetOper := (cAliasVRJ)->VRJ_TIPVEN
	EndIf

	(cAliasVRJ)->(dbCloseArea())

Return cRetOper


Static Function Vei02ValVda( cNumPedidoVRJ, cItemPedidoVRK )

	Local nRetValVda := 0
	Local cAliasVRK := "TTMPVRK"

	Local nTamValor1 := TamSx3("VRK_VALVDA")[1]
	Local nDecValor1 := TamSx3("VRK_VALVDA")[2]

	If Empty(cNumPedidoVRJ)
		Return 0
	EndIf

	BeginSql Alias cAliasVRK

		COLUMN VRK_VALVDA AS NUMERIC(nTamValor1,nDecValor1)

		SELECT VRK_VALVDA
		  FROM %Table:VRK% VRK
		 WHERE
			VRK.VRK_FILIAL = %xFilial:VRK%
			AND VRK.VRK_PEDIDO = %exp:cNumPedidoVRJ%
			AND VRK.VRK_ITEPED = %exp:cItemPedidoVRK%
			AND VRK.%NotDel%
	EndSql
	If (cAliasVRK)->(!Eof())
		nRetValVda := (cAliasVRK)->VRK_VALVDA
	EndIf

	(cAliasVRK)->(dbCloseArea())

Return nRetValVda

Static Function Vei02Pre( cNumPedidoVRJ, cItemPedidoVRK )

	Local nRetValpre := 0
	Local cAliasVRK := "TTMPVRK2"

	Local nTamValor1 := TamSx3("VRK_VALPRE")[1]
	Local nDecValor1 := TamSx3("VRK_VALPRE")[2]

	If Empty(cNumPedidoVRJ)
		Return 0
	EndIf

	BeginSql Alias cAliasVRK

		COLUMN VRK_VALPRE AS NUMERIC(nTamValor1,nDecValor1)

		SELECT VRK_VALPRE
		  FROM %Table:VRK% VRK
		 WHERE
			VRK.VRK_FILIAL = %xFilial:VRK%
			AND VRK.VRK_PEDIDO = %exp:cNumPedidoVRJ%
			AND VRK.VRK_ITEPED = %exp:cItemPedidoVRK%
			AND VRK.%NotDel%
	EndSql
	If (cAliasVRK)->(!Eof())
		nRetValpre := (cAliasVRK)->VRK_VALPRE
	EndIf

	(cAliasVRK)->(dbCloseArea())

Return nRetValpre
