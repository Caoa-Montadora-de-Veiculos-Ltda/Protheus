#include 'protheus.ch'
#include 'parmtype.ch'
/*
=====================================================================================
Programa.:              CMVVEI01
Autor....:              TOTVS
Data.....:              12/08/2019
Descricao / Objetivo:   Programa para o Calculo Reverso para venda de veiculos
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/

User Function CMVVEI01()

Local nVlrRet	:= nValorPre      //Valor Total vindo da tabela de preço
Local nAlqIPI	:= 0
Local nAlqIcmSt	:= 0
Local nAlqOpIcm	:= 0
Local nBaseSt	:= 0 
Local nAlqBIcms	:= 0
Local cTes		:= ""    
Local nVlIcmDev	:= 0
Local nAliqStPi	:= 0
Local nAliqStCo	:= 0
Local nRedBPist	:= 0
Local nRedBCoSt	:= 0
Local nAux1		:= 0
Local nAux2		:= 0
Local nAux3		:= 0
Local lSuframa	:= .F.
Local nPercZFre	:= 0.01 // Tratar Parâmetro
Local nVlrDesFr	:= 0
Local nVlrUnit	:= 0
Local aArea		:= {SA1->(GetArea()),GetArea()}	
Local aAreaSF4	:= {}
Local nPerComs	:= 0
Local nValComs	:= 0
Local cTESTSD	:= SuperGetMV("CMV_TESTSD",.F.,"")
Local aExcecao	:= {}
Local cGrupo1	:= GetMv("MV_XVEI011",,"000003"	) // grupo que nao pode ter a variavel nAux3 calculada no calculo reverso. OBS: se precisar incluir mais grupos, criar outros parametros, não inserir o grupo neste mesmo parametro, para evitar cruzamento de logicas entre grupos X marcas, deixando o cruzamento exponencial e errado
Local cMarca1	:= GetMv("MV_XVEI012",,"HYU"	) // marca que nao pode ter a variavel nAux3 calculada no calculo reverso. OBS: se precisar incluir mais marcas, criar outros parametros, não inserir a marca neste mesmo parametro, para evitar cruzamento de logicas entre grupos X marcas, deixando o cruzamento exponencial e errado
Local cGrupo2	:= GetMv("MV_XVEI014",,"000003"	) // venda de caminhao HD80, base icms st deve estar zerada
Local cMarca2	:= GetMv("MV_XVEI015",,"HYU"	) // venda de caminhao HD80, base icms st deve estar zerada
Local lPassa	:= .T.
Local oModel	:= FWModelActive()
Local nY		:= 1

//Variáveis para cálculo do Zona Franca
Local nVlrNormal	:= 0	//Preço de venda normal
Local nBSICMSST		:= 0	//Base do ICMS ST - conferir com a tabela
Local nAlqIcms		:= 0	//Aliquota de ICMS OP
Local nAlqIcmsST	:= 0	//Aliquota de ICMS ST
Local nVlrIcms		:= 0	//Valor ICMS
Local nAlqPCC		:= 0	//Aliquota de Pis+Cofins ST
Local nRedPCC		:= 0	//Redução Pis / Cofins
Local nRedIcms		:= 0	//Redução base ICMS
Local nAlqIpiZF		:= 0	//Aliquota de IPI Zona Franca
Local nVlrDescFr	:= 0	//Desconto frete 1% ZF 	
Local nVlrFator1	:= 0	//Calculo do Fator 1
Local nVlrFator2	:= 0	//Calculo do Fator 2
Local nvlrFator3	:= 0	//Calculo do Fator 3 
Local nDIcmsZF		:= 0	//Desconto do ICMS Normal Zona Franca
Local nDIpiZF		:= 0 	//Desconto do IPI Zona Franca
Local nDPccZF		:= 0	//Desconto do PIS / COFINS Zona Franca
Local nVlrAbtTrb	:= 0	//Abatimentos tributos ZF
Local nVlrPCCST		:= 0	//PIS/COFINS ST
Local nPrecoZF		:= 0	//Preço de venda Zona Franca

// venda para consumidor final dentro do mesmo estado, não tem ST
If FWFldGet("VRJ_TIPVEN") $ "04"
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+FWFldGet("VRJ_CODCLI")+FWFldGet("VRJ_LOJA")))
		If Alltrim(GetMv("MV_ESTADO")) == Alltrim(SA1->A1_EST) .and. Alltrim(GetMv("MV_ESTADO")) == "GO" .and. SA1->A1_TIPO == "F" .and. Alltrim(SA1->A1_GRPTRIB) == "VDD"
			lPassa := .F.
		Endif
	Endif		
Endif

// Tratativa Venda Direta
If FWFldGet("VRJ_TIPVEN") $ "02/03/04/06"
	If !(Alltrim(FWFldGet("VRK_CODMAR")) $ Alltrim(cMarca2) .and. Alltrim(FWFldGet("VRK_GRUMOD")) $ Alltrim(cGrupo2))
		If lPassa
			FWFldPut("VRK_XBASST", FWFldGet("VRK_VALPRE"))
			ConOut("            Recalculando item fiscal - " + cValToChar(FWFldGet("ITEMFISCAL") ) )
			MaFisRecal("",FWFldGet("ITEMFISCAL"))
		Endif	
	Endif	
EndIf

//Venda PCD/Taxi não tem reverso.
If FWFldGet("VRJ_TIPVEN") $ "02/03/05"
	aEval(aArea,{|x| RestArea(x)})
	Return nVlrRet
Endif 

//Venda Direta convênio 51/00
If FWFldGet("VRJ_TIPVEN") $ "04"
	Default cCodMar := FWFldGet("VRK_CODMAR")
	Default cModVei := FWFldGet("VRK_MODVEI")
	Default cSegMod := FWFldGet("VRK_SEGMOD")
	Default nValTab := FWFldGet("VRK_VALTAB")
	Default nValPre := FWFldGet("VRK_VALPRE")

	nAlqIPI   := MaFisRet(N,"IT_ALIQIPI")/100  				//Aliquota de IPI ja em Percentual  
	nAlqOpIcm := MaFisRet(N,"IT_ALIQICM")/100  				//Aliquota de ICMS OP em Percentual
	nPerComs  := Vei01Comis(MaFisRet(N,"IT_PRODUTO"))/100	//Percentual de comissao conforme modelo do veículo
	
	If !(MaFisRet(N,"IT_TES") $ cTESTSD)	//-- TES de faturamento p/ veículo test drive (não tem comissão)
		nValComs := ROUND(nVlrRet * nPerComs,2)
		oModel:SetValue('MODEL_VRK','VRK_XVLCOM',nValComs)			//Força atualização da tela
		oModel:SetValue('MODEL_VRK','VRK_XPECOM',nPerComs*100)		//Força atualização da tela
	EndIf
	
	oModel:SetValue('MODEL_VRK','VRK_VALVDA',nVlrRet)		//Força atualização da tela
	nVlrUnit  := ROUND((nVlrRet - nValComs)/(1+nAlqIPI),2) 
	
	oModel:SetValue('MODEL_VRK','VRK_XBASIP',nVlrUnit)		//Força atualização da tela
	nVlrUnit  +=  nValComs
	
	oModel:SetValue('MODEL_VRK','VRK_VALMOV',nVlrUnit) 		//Força atualização da tela
	nVlrRet   := nVlrUnit 
	
	Conout(" CMVVEI01 - Pedido SigaVei: "+FWFldGet("VRK_PEDIDO")+" Veiculo: "+MaFisRet(N,"IT_PRODUTO")+" Item: "+cValToChar(N)+;
			" - nAlqIPI: "+ cValToChar(nAlqIPI)+;
			" nAlqOpIcm:"+ cValToChar(nAlqOpIcm)+" nPerComs:"+ cValToChar(nPerComs)+" nValComs: "+ cValToChar(nValComs)+;
			" nVlrUnit: "+ cValToChar(nVlrUnit))	
	MaFisRecal("",FWFldGet("ITEMFISCAL"))  //Recalcula tudo com a tela atualizada
	
	aEval(aArea,{|x| RestArea(x)})
	
	Return nVlrRet
Endif

lSuframa := MaFisRet(N,"NF_SUFRAMA")

If !lSuframa 
	/******************************************************************
	**Venda Atacado não Suframa Planilha de Referencia para       *****
	**chegar no calculo Unitário - Calculadora Concessionaria.xls *****
	*******************************************************************/

	cTes := MaFisRet(N,"IT_TES") 
    If Upper(Alltrim(FunName())) == "RPC" .And. Alltrim(ProcName(0)) == "U_CMVVEI01"  .And. Len(aItens) <> 0
			N := oModel:GetValue("MODEL_VRK","ITEMFISCAL")

			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+cTes))

			MaFisClear()
			For nY := 1 To N
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+Alltrim(aItens[nY][4][2])+Alltrim(aItens[nY][5][2])))

				MaFisIniLoad(nY								,;
							{ SB1->B1_COD					,; // IT_PRODUTO
					 		cTes							,; // IT_TES
					 		Space(TamSX3("D1_CODISS")[1])	,; // IT_VALISS - Valor do ISS do item sem aplicar o arredondamento
					 		1								,; // IT_QUANT - Quantidade do Item
					 		""								,; // IT_NFORI - Numero da NF Original
					 		""								,; // IT_SERORI - Serie da NF Original
					 		SB1->(RecNo()) 					,; // IT_RECNOSB1
					 		SF4->(RecNo()) 					,; // IT_RECNOSF4
					 		0 })        					   //IT_RECORI

				MaFisTes(cTes,SF4->(RecNo()),nY)
				MaFisLoad("IT_PRODUTO"  , SB1->B1_COD , nY) ; MaFisLoad("IT_QUANT"    , 1           , nY)
				MaFisLoad("IT_TES"      , cTes	      , nY) ; MaFisLoad("IT_PRCUNI"   , nValorPre   , nY)
				MaFisLoad("IT_VALMERC"  , nValorPre   , nY) ; MaFisEndLoad(nY,1)
				MaFisRecal("",nY)
				aExcecao := MaExcecao(N)
			Next
	EndIf
	nAlqIPI  := MaFisRet(N,"IT_ALIQIPI")/100  		//Aliquota de IPI ja em Percentual  
	nAlqIcmSt:= MaFisRet(N,"IT_ALIQSOL")/100  		//Aliquota de ICMS ST ja em Percentual
	nAlqOpIcm:= MaFisRet(N,"IT_ALIQICM")/100  		//Aliquota de ICMS OP em Percentual 
	nBaseSt  := MaFisRet(N,"IT_BASESOL")      		// Base de ST Fixa, que está no produto. (Usado o Conceito de ICMS Pauta)

	cTes     := MaFisRet(N,"IT_TES")          		// Tes para buscar a redução de Base de ICMS Pois não encontrei na MaFisRet
	nAliqStPi:= MaFisRet(N,"IT_ALIQPS3")/100  		// Aliquota de Pis    ST em Percentual
	nAliqStCo:= MaFisRet(N,"IT_ALIQCF3")/100  		// Aliquota de Cofins ST em Percentual
    nAlqBIcms:= MaFisRet(N,"IT_PREDIC")      		// Redução de Base de ICMS
    
	nVlIcmDev := nBaseSt*nAlqIcmSt					// Valor do ICMS devido (Necessário para o calculo Reverso)
	nVlrDesFr := 0									// Valor de Desconto de Frete, somente ZF e fixo de 1% sobre preço total de Venda
	nAux1     := nVlrRet-nVlrDesfr - nVlIcmDev		// Variavel Auxiliar para calculo do Valor Unitário             
	nAux2     := 1+nAlqIPI							// Variavel Auxiliar para calculo do Valor Unitário 
	nAux3     := ((nAlqBIcms/100)*nAlqOpIcm)		// Variavel Auxiliar para calculo do Valor Unitário
	
	// grupo e marca de produtos que nao devem ter esta variavel incrementada ao calculo
	If Vei01NAux3(MaFisRet(N,"IT_PRODUTO"),cGrupo1,cMarca1)
		nAux3 := 0
	Endif	
	
	nVlrUnit  := nAux1/(nAux2-nAux3)
	nVlrRet   := nVlrUnit 

	Conout(" CMVVEI01 - Pedido SigaVei: "+FWFldGet("VRK_PEDIDO")+" Veiculo: "+MaFisRet(N,"IT_PRODUTO")+" Item: "+cValToChar(N)+;
	" - nAlqIPI: "+ cValToChar(nAlqIPI)+;
	" nAlqIcmSt:"+ cValToChar(nAlqIcmSt)+" nAlqOpIcm:"+ cValToChar(nAlqOpIcm)+" nBaseSt: "+ cValToChar(nBaseSt)+;
	" cTes: "+ cValToChar(cTes)+" nAliqStPi: "+ cValToChar(nAliqStPi)+" nAliqStCo: "+ cValToChar(nAliqStCo)+;
	" nAlqBIcms: "+ cValToChar(nAlqBIcms)+" nVlIcmDev: "+ cValToChar(nVlIcmDev)+" nAux1: "+ cValToChar(nAux1)+;
	" nAux2: "+ cValToChar(nAux2)+" nAux3: "+ cValToChar(nAux3)+" nVlrUnit: "+ cValToChar(nVlrUnit))	
	
Else
	******************************************************************
	** Programa de Calculo Reverso Baseado na Planilha de Calculo    *
	** Preços de Venda CAOA x Revenda  - Zona Franca  de Manaus      *
	******************************************************************

    If Upper(Alltrim(FunName())) == "RPC" .And. Alltrim(ProcName(0)) == "U_CMVVEI01"  .And. Len(aItens) <> 0
		cTes := MaFisRet(N,"IT_TES") 
		N := oModel:GetValue("MODEL_VRK","ITEMFISCAL")

		SF4->(DbSetOrder(1))
		SF4->(DbSeek(xFilial("SF4")+cTes))

		MaFisClear()
		For nY := 1 To N
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+Alltrim(aItens[nY][4][2])+Alltrim(aItens[nY][5][2])))
			MaFisIniLoad(nY								,;
						{ SB1->B1_COD					,; // IT_PRODUTO
				 		cTes							,; // IT_TES
				 		Space(TamSX3("D1_CODISS")[1])	,; // IT_VALISS - Valor do ISS do item sem aplicar o arredondamento
				 		1								,; // IT_QUANT - Quantidade do Item
				 		""								,; // IT_NFORI - Numero da NF Original
				 		""								,; // IT_SERORI - Serie da NF Original
				 		SB1->(RecNo()) 					,; // IT_RECNOSB1
				 		SF4->(RecNo()) 					,; // IT_RECNOSF4
				 		0 })        					   //IT_RECORI

			MaFisTes(cTes,SF4->(RecNo()),nY)
			MaFisLoad("IT_PRODUTO"  , SB1->B1_COD , nY) ; MaFisLoad("IT_QUANT"    , 1           , nY)
			MaFisLoad("IT_TES"      , cTes	      , nY) ; MaFisLoad("IT_PRCUNI"   , nValorPre   , nY)
			MaFisLoad("IT_VALMERC"  , nValorPre   , nY) 
			MaFisEndLoad(nY,1) ; MaFisRecal("",nY)
			aExcecao := MaExcecao(N)
		Next
	EndIf

	aAreaSF4 := GetArea()
	SF4->(DbSetOrder(1))
	If SF4->(DbSeek( xFilial("SF4")+cTes))		
		nRedBPist := SF4->F4_BASEPIS						// Redução da Base de Pis
		nRedBCoSt := SF4->F4_BASECOF						// Redução da Base de Cofins 
		// verifica se tem excecao fiscal e pega de lah quando tiver
		If Len(MaFisRet(N,"IT_EXCECAO")) > 0
			aExcecao := MaFisRet(N,"IT_EXCECAO")
			If !Empty(aExcecao[18])
				nRedBPist := aExcecao[18]					// Redução da Base de Pis
			Endif	
			If !Empty(aExcecao[19])
				nRedBCoSt := aExcecao[19]					// Redução da Base de Cofins 
			Endif	
		Endif	
	Endif
	RestArea(aAreaSF4)

	VVPLastSeq(FWFldGet("VRK_CODMAR"),FWFldGet("VRK_MODVEI"),FWFldGet("VRK_SEGMOD"),FWFldGet("VRK_FABMOD"))
	nVlrNormal	:= VVP->VVP_VALTAB
	nBSICMSST	:= VVP->VVP_BASEST
	nAlqIcms	:= MaFisRet(N,"IT_ALIQICM")											//Aliquota de ICMS OP
	nAlqIcmsST	:= MaFisRet(N,"IT_ALIQSOL")											//Aliquota de ICMS ST
	nVlrIcms	:= (VVP->VVP_BASEST * (nAlqIcmsST/100))								//Valor ICMS
	If MaFisRet(N,"IT_ALIQPS3") <> 0 .And. MaFisRet(N,"IT_ALIQCF3") <> 0
		nAlqPCC	:= (MaFisRet(N,"IT_ALIQPS3") + MaFisRet(N,"IT_ALIQCF3"))			//Aliquota de Pis+Cofins ST
	Else
		nAlqPCC	:= (aExcecao[12]+aExcecao[13])										//Aliquota de Pis+Cofins ST
	EndIf
	nRedPCC		:= 0																//Redução Pis / Cofins
	nRedIcms	:= MaFisRet(N,"IT_PREDIC")											//Redução base ICMS
	nAlqIpi		:= MaFisRet(N,"IT_ALIQIPI")											//Aliquota de IPI
	nAlqIpiZF	:= 0																//Aliquota de IPI Zona Franca
	nVlrDescFr	:= Round((nVlrNormal * nPercZFre),0)								//Desconto frete 1% ZF 
	
	nVlrFator1	:= ((1+(nAlqIpi /100))/100)											//Calculo do Fator 1
	nVlrFator2	:= (   (nRedIcms/100 )/100) /*((1-(nRedIcms/100))/100)*/			//Calculo do Fator 2
	nvlrFator3  := (nVlrFator1 -nVlrFator2 * ((nAlqIcms /100)))/100					//Calculo do Fator 3 

	nVlrUnit	:= ((((nVlrNormal - nVlrDescFr)-nVlrIcms) / nVlrFator3)/10000)		//Valor unitário normal
	nDIcmsZF	:= 0																//Desconto do ICMS Normal Zona Franca
	nDIpiZF		:= (nVlrUnit * nAlqIpiZF)											//Desconto do IPI Zona Franca

	nVlrFator1	:= (nVlrUnit * (1 - (nRedPCC/100)))									//Calculo do Fator 1
	nVlrFator2  := (nVlrUnit * (nRedIcms/100)) * (nAlqIcms/100)						//Calculo do Fator 2
	nVlrFator3  := (nVlrFator1 - nVlrFator2) 										//Calculo do Fator 3
	nDPccZF		:= (nVlrFator3 * (nAlqPCC /100))									//Desconto do PIS / COFINS Zona Franca
	nVlrAbtTrb	:= (nDIcmsZF + nDIpiZF + nDPccZF)									//Abatimentos tributos ZF

	nVlrPCCST	:= 0																//PIS/COFINS ST
	nPrecoZF	:= (nVlrNormal - nVlrDescFr - nVlrAbtTrb + nVlrPCCST)				//Preço de venda Zona Franca
	nVlrRet		:= Round((nPrecoZF- (nBSICMSST*(nAlqIcmsST/100))) / ;
	                     (((100+nAlqIpi)-((nRedIcms/100)*nAlqIcms))/100),2)			//Valor unitário final Zona Franca
Endif

aEval(aArea,{|x| RestArea(x)})

Return Round(nVlrRet,2)

Static Function Vei01Comis(cProd)

Local aArea := {VV2->(GetArea()),GetArea()}	
Local nRet := 0

VV2->(dbSetOrder(7))
If VV2->(dbSeek(xFilial("VV2")+cProd))
	nRet := VV2->&('VV2_XCOM'+StrZero(Val(FWFldGet("VRJ_TIPVEN")),1))

	If nRet <= 0
		nRet := VV2->VV2_XCOMIS
	EndIf
Endif

aEval(aArea,{|x| RestArea(x)})

Return(nRet)


Static Function Vei01NAux3(cProd,cGrupo1,cMarca1)

Local aArea := {VV2->(GetArea()),GetArea()}	
Local lRet := .F.

VV2->(dbSetOrder(7))
If VV2->(dbSeek(xFilial("VV2")+cProd))
	If Alltrim(VV2->VV2_GRUMOD) $ Alltrim(cGrupo1) .and. Alltrim(VV2->VV2_CODMAR) $ Alltrim(cMarca1)
		lRet := .T.
	Endif	
Endif

aEval(aArea,{|x| RestArea(x)})

Return(lRet)


Static Function Vei01IcmZF(cProd,cGrupo,cMarca)

Local aArea := {VV2->(GetArea()),GetArea()}	
Local lRet := .F.

VV2->(dbSetOrder(7))
If VV2->(dbSeek(xFilial("VV2")+cProd))
	If Alltrim(VV2->VV2_GRUMOD) $ Alltrim(cGrupo) .and. Alltrim(VV2->VV2_CODMAR) == Alltrim(cMarca)
		lRet := .T.
	Endif	
Endif

aEval(aArea,{|x| RestArea(x)})

Return(lRet)

//-------------------------------------------------------------------
static function VVPLastSeq(cCodMar,cModVei,cSegMod,cFabMod)
local cQuery as char
local cSeq as char
local cAlias as char

//Guarda a workarea corrente
cAlias := Alias()

//Gera um alias aleatório somente para abrir a query
cQuery := GetNextAlias()

//Cria a query
BeginSql Alias cQuery
    SELECT VVP_BASEST,VVP_DATPRC
    FROM %Table:VVP% VVP
    WHERE
    VVP.%NotDel%
    AND VVP_FILIAL = %Exp:xFilial("VVP")%
	AND VVP.VVP_CODMAR = %exp:cCodMar%
	AND VVP.VVP_MODVEI = %exp:cModVei%
	AND VVP.VVP_SEGMOD =  %exp:cSegMod%
	AND VVP_DATPRC = 
	(
		SELECT MAX(VVP_DATPRC) VVP_DATPRC
		FROM %Table:VVP% VVP1
		WHERE
		VVP1.%NotDel%
		AND VVP1.VVP_FILIAL = VVP.VVP_FILIAL
		AND VVP1.VVP_CODMAR = VVP.VVP_CODMAR
		AND VVP1.VVP_MODVEI = VVP.VVP_MODVEI
		AND VVP1.VVP_SEGMOD = VVP.VVP_SEGMOD
		AND VVP1.VVP_FABMOD = %exp:cFabMod%
		
	)
    GROUP BY VVP_BASEST,VVP_DATPRC
	ORDER BY VVP_BASEST,VVP_DATPRC
    EndSql

//Se existir registro, retorna o mesmo
if !(cQuery)->(Eof())
    cSeq := (cQuery)->VVP_BASEST
else
    cSeq := ""
endif

dbSelectArea("VVP")
VVP->(dbSetOrder(1))
VVP->(dbSeek(xFilial("VVP")+VV2->VV2_CODMAR+VV2->VV2_MODVEI+VV2->VV2_SEGMOD+(cQuery)->VVP_DATPRC))

//Fecha a query, boa prática, tudo que você abriu, você fecha... E também existem limites de workareas abertas no Protheus
(cQuery)->(DBCloseArea())

//Retorna a workarea corrente, protegido, pois um dbselectarea com valor vazio gera exceção
if !Empty(cAlias)
    DBSelectArea(cAlias)
endif

return cSeq
