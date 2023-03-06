#Include 'Protheus.Ch'
#Include 'RwMake.Ch'
#Include 'Font.Ch'
#Include 'Colors.Ch'
#Include "TopConn.Ch"
#Include "TbiConn.CH"

/*/{Protheus.doc} ZFATF021
//ValidaÁ„o e preenchimento de campos da tabela SC6
@author Leonardo Miranda
@since 16/02/2023
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, Alias da tabela corrente
@param nReg, numeric, recno do registro
@param nOpcx, numeric, opcao selecionada
@type function
/*/

************************
User Function NWFATDAD()
************************

Return(.T.)

************************
User Function ZFATF021()
************************

Local cQuery        As Character
Local cTrbAlias     As Character
Local cNumSeri      As Character

If Upper(Alltrim(FunName())) == "ZFATF019" .And. Upper(Alltrim(ProcName(11))) == "A410INCLUI"

    cNumSeri  := GDFieldGet("C6_NUMSERI",N,,aHeader,aCols)
    cTrbAlias := GetNextAlias()

    If !Empty(Alltrim(cNumSeri))
        cQuery := ""
        cQuery += " SELECT  VV1.VV1_FILIAL          AS FILIAL       ,                               "+(Chr(13)+Chr(10))
        cQuery += "         VV1.VV1_CHASSI          AS CHASSI       ,                               "+(Chr(13)+Chr(10))
        cQuery += "         VV1.VV1_CHAINT          AS CHASSIINT    ,                               "+(Chr(13)+Chr(10))
        cQuery += "         VV1.VV1_MODVEI          AS MODVEI       ,                               "+(Chr(13)+Chr(10))
        cQuery += "         TRIM(VV2.VV2_DESMOD)    AS DESCMOD      ,                               "+(Chr(13)+Chr(10))
        cQuery += "         VV1.VV1_CODMAR          AS MARCA        ,                               "+(Chr(13)+Chr(10))
        cQuery += "         TRIM(VE1.VE1_DESMAR)    AS DESCMAR      ,                               "+(Chr(13)+Chr(10))
        cQuery += "         VV1.VV1_SEGMOD          AS SEGMOD       ,                               "+(Chr(13)+Chr(10))
        cQuery += "         TRIM(VVX.VVX_DESSEG)    AS DESCSEG      ,                               "+(Chr(13)+Chr(10))
        cQuery += "         VV1.VV1_FABMOD          AS FABMOD       ,                               "+(Chr(13)+Chr(10))
        cQuery += "         VV2.VV2_COREXT          AS COREXT       ,                               "+(Chr(13)+Chr(10))
        cQuery += "         TRIM(VX1.VX5_DESCRI)    AS DESCEXT      ,                               "+(Chr(13)+Chr(10))
        cQuery += "         VV2.VV2_CORINT          AS CORINT       ,                               "+(Chr(13)+Chr(10))
        cQuery += "         TRIM(VX2.VX5_DESCRI)    AS DESCINT      ,                               "+(Chr(13)+Chr(10))
        cQuery += "         VVP.VVP_VALTAB          AS VALTAB       ,                               "+(Chr(13)+Chr(10))
        cQuery += "         VVP.VVP_BASEST          AS BASEST                                       "+(Chr(13)+Chr(10))
        cQuery += " FROM    "+RetSqlName("VV1")+" VV1                                               "+(Chr(13)+Chr(10))
        cQuery += "         INNER JOIN                                                              "+(Chr(13)+Chr(10))
        cQuery += "         "+RetSqlName("VV2")+" VV2  ON   '"+xFilial("VV2")+"' = VV2.VV2_FILIAL   "+(Chr(13)+Chr(10))
        cQuery += "                                     AND VV1.VV1_CODMAR       = VV2.VV2_CODMAR   "+(Chr(13)+Chr(10))
        cQuery += "                                     AND VV1.VV1_MODVEI       = VV2.VV2_MODVEI   "+(Chr(13)+Chr(10))
        cQuery += "                                     AND VV1.VV1_SEGMOD       = VV2.VV2_SEGMOD   "+(Chr(13)+Chr(10))
        cQuery += "                                     AND VV1.D_E_L_E_T_       = VV2.D_E_L_E_T_   "+(Chr(13)+Chr(10))
        cQuery += "         LEFT JOIN                                                               "+(Chr(13)+Chr(10))
        cQuery += "         "+RetSqlName("VX5")+" VX1 ON    '"+xFilial("VX5")+"' = VX1.VX5_FILIAL   "+(Chr(13)+Chr(10))
        cQuery += "                                     AND '067'                = VX1.VX5_CHAVE    "+(Chr(13)+Chr(10))
        cQuery += "                                     AND VV2.VV2_COREXT       = VX1.VX5_CODIGO   "+(Chr(13)+Chr(10))
        cQuery += "                                     AND VV1.D_E_L_E_T_       = VX1.D_E_L_E_T_   "+(Chr(13)+Chr(10))
        cQuery += "         LEFT JOIN                                                               "+(Chr(13)+Chr(10))
        cQuery += "         "+RetSqlName("VX5")+" VX2 ON    '"+xFilial("VX5")+"' = VX2.VX5_FILIAL   "+(Chr(13)+Chr(10))
        cQuery += "                                     AND '066'                = VX2.VX5_CHAVE    "+(Chr(13)+Chr(10))
        cQuery += "                                     AND VV2.VV2_CORINT       = VX2.VX5_CODIGO   "+(Chr(13)+Chr(10))
        cQuery += "                                     AND VV1.D_E_L_E_T_       = VX2.D_E_L_E_T_   "+(Chr(13)+Chr(10))
        cQuery += "         LEFT JOIN                                                               "+(Chr(13)+Chr(10))
        cQuery += "         "+RetSqlName("VE1")+" VE1  ON  '"+xFilial("VE1")+"'  = VE1.VE1_FILIAL   "+(Chr(13)+Chr(10))
        cQuery += "                                    AND VV1.VV1_CODMAR        = VE1.VE1_CODMAR   "+(Chr(13)+Chr(10))
        cQuery += "                                    AND VV1.D_E_L_E_T_        = VE1.D_E_L_E_T_   "+(Chr(13)+Chr(10))
        cQuery += "         LEFT JOIN                                                               "+(Chr(13)+Chr(10))
        cQuery += "         "+RetSqlName("VVX")+" VVX  ON  '"+xFilial("VVX")+"'  = VVX.VVX_FILIAL   "+(Chr(13)+Chr(10))
        cQuery += "                                    AND VV1.VV1_CODMAR        = VVX.VVX_CODMAR   "+(Chr(13)+Chr(10))
        cQuery += "                                    AND VV1_SEGMOD            = VVX.VVX_SEGMOD   "+(Chr(13)+Chr(10))
        cQuery += "                                    AND VV1.D_E_L_E_T_        = VVX.D_E_L_E_T_   "+(Chr(13)+Chr(10))
        cQuery += "         LEFT JOIN                                                               "+(Chr(13)+Chr(10))
        cQuery += "         "+RetSqlName("VVP")+" VVP  ON  '"+xFilial("VVP")+"'  = VVP.VVP_FILIAL   "+(Chr(13)+Chr(10))
        cQuery += "                                    AND VV1.VV1_CODMAR        = VVP.VVP_CODMAR   "+(Chr(13)+Chr(10))
        cQuery += "                                    AND VV1.VV1_MODVEI        = VVP.VVP_MODVEI   "+(Chr(13)+Chr(10))
        cQuery += "                                    AND VV1.VV1_SEGMOD        = VVP.VVP_SEGMOD   "+(Chr(13)+Chr(10))
        cQuery += "                                    AND VV1.VV1_FABMOD        = VVP.VVP_FABMOD   "+(Chr(13)+Chr(10))
        cQuery += "                                    AND VV1.D_E_L_E_T_        = VVP.D_E_L_E_T_   "+(Chr(13)+Chr(10))
        cQuery += " WHERE   VV1.VV1_FILIAL          = '"+xFilial("VV1")+"'                          "+(Chr(13)+Chr(10))
        cQuery += "     AND VV1.VV1_CHASSI          = '"+Alltrim(cNumSeri)+"'                       "+(Chr(13)+Chr(10))
        cQuery += "     AND VV1.D_E_L_E_T_          = ' '                                           "+(Chr(13)+Chr(10))
        If Select(cTrbAlias) <> 0 ; (cTrbAlias)->(DbCloseArea()) ; EndIf
        DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTrbAlias, .F., .T. )

        GDFieldPut("C6_XPRCTAB" , (cTrbAlias)->VALTAB  , N) ; GDFieldPut("C6_XVLRPRD" , (cTrbAlias)->VALTAB  , N)
        GDFieldPut("C6_XCODMAR"	, (cTrbAlias)->MARCA   , N) ; GDFieldPut("C6_XDESMAR" , (cTrbAlias)->DESCMAR , N)
        GDFieldPut("C6_XCORINT"	, (cTrbAlias)->CORINT  , N) ; GDFieldPut("C6_XCOREXT" , (cTrbAlias)->COREXT  , N)
        GDFieldPut("C6_XMODVEI" , (cTrbAlias)->MODVEI  , N) ; GDFieldPut("C6_XDESMOD" , (cTrbAlias)->DESCMOD , N)
        GDFieldPut("C6_XSEGMOD"	, (cTrbAlias)->SEGMOD  , N) ; GDFieldPut("C6_XDESSEG" , (cTrbAlias)->DESCSEG , N)
        GDFieldPut("C6_XFABMOD"	, (cTrbAlias)->FABMOD  , N) ; GDFieldPut("C6_XGRPMOD" , ""                   , N)
        GDFieldPut("C6_XDGRMOD" , ""                   , N) ; GDFieldPut("C6_XBASST"  , (cTrbAlias)->BASEST  , N)
        CalcRev((cTrbAlias)->VALTAB)
        If Select(cTrbAlias) <> 0 ; (cTrbAlias)->(DbCloseArea()) ; EndIf
    EndIf
EndIf

Return(.T.)

**********************************
Static Function CalcRev(nValorPre)
**********************************

Local nVlrRet	:= nValorPre      //Valor Total vindo da tabela de preùo
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
Local nPercZFre	:= 0.01 // Tratar Parùmetro
Local nVlrDesFr	:= 0
Local nVlrUnit	:= 0
Local aArea		:= {SA1->(GetArea()),GetArea()}	
Local aAreaSF4	:= {}
Local nPerComs	:= 0
Local nValComs	:= 0
Local cTESTSD	:= SuperGetMV("CMV_TESTSD",.F.,"")
Local aExcecao	:= {}
Local cGrupo1	:= GetMv("MV_XVEI011",,"000003"	) // grupo que nao pode ter a variavel nAux3 calculada no calculo reverso. OBS: se precisar incluir mais grupos, criar outros parametros, nùo inserir o grupo neste mesmo parametro, para evitar cruzamento de logicas entre grupos X marcas, deixando o cruzamento exponencial e errado
Local cMarca1	:= GetMv("MV_XVEI012",,"HYU"	) // marca que nao pode ter a variavel nAux3 calculada no calculo reverso. OBS: se precisar incluir mais marcas, criar outros parametros, nùo inserir a marca neste mesmo parametro, para evitar cruzamento de logicas entre grupos X marcas, deixando o cruzamento exponencial e errado
Local oModel	:= FWModelActive()
Local nY		:= 1

//Variùveis para cùlculo do Zona Franca
Local nVlrNormal	:= 0	//Preùo de venda normal
Local nBSICMSST		:= 0	//Base do ICMS ST - conferir com a tabela
Local nAlqIcms		:= 0	//Aliquota de ICMS OP
Local nAlqIcmsST	:= 0	//Aliquota de ICMS ST
Local nVlrIcms		:= 0	//Valor ICMS
Local nAlqPCC		:= 0	//Aliquota de Pis+Cofins ST
Local nRedPCC		:= 0	//Reduùùo Pis / Cofins
Local nRedIcms		:= 0	//Reduùùo base ICMS
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
Local nPrecoZF		:= 0	//Preùo de venda Zona Franca
Local cProduto      := GDFieldGet("C6_PRODUTO",N,,aHeader,aCols)
Local cTes          := GDFieldGet("C6_TES"    ,N,,aHeader,aCols)
Local cCodMar       := GDFieldGet("C6_XCODMAR",N,,aHeader,aCols)
Local cModVei       := GDFieldGet("C6_XMODVEI",N,,aHeader,aCols)
Local cSegMod       := GDFieldGet("C6_XSEGMOD",N,,aHeader,aCols)
Local cFabMod       := GDFieldGet("C6_XFABMOD",N,,aHeader,aCols)

SB1->(DbSetOrder(1)) ; SB1->(DbSeek(xFilial("SB1")+(cCabAlias)->C6_PRODUTO))
SF4->(DbSetOrder(1)) ; SF4->(DbSeek(xFilial("SF4")+(cCabAlias)->C6_TES    ))

// venda para consumidor final dentro do mesmo estado, nùo tem ST
If M->C5_XTIPVEN $ "04"
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
		If Alltrim(GetMv("MV_ESTADO"))  == Alltrim(SA1->A1_EST) .And. ;
           Alltrim(GetMv("MV_ESTADO"))  == "GO"                 .And. ;
           SA1->A1_TIPO                 == "F"                  .And. ;
           Alltrim(SA1->A1_GRPTRIB)     == "VDD"
		Endif
	Endif		
Endif

//Venda PCD/Taxi nùo tem reverso.
If M->C5_XTIPVEN  $ "02/03/05"
	aEval(aArea,{|x| RestArea(x)})
	Return nVlrRet
Endif

SA1->(DbSetOrder(1)) ; SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
SB1->(DbSetOrder(1)) ; SB1->(DbSeek(xFilial("SB1")+cProduto                   ))
SF4->(DbSetOrder(1)) ; SF4->(DbSeek(xFilial("SF4")+cTes                       ))
MaFisIni(M->C5_CLIENTE, M->C5_LOJACLI, 'C', 'N', SA1->A1_TIPO, MaFisRelImp("VA060", {"VRJ","VRK"}) )
MaFisClear()

MaFisIniLoad(nY								,;
			{ SB1->B1_COD					,; // IT_PRODUTO
 	 		cTes	            			,; // IT_TES
	 		Space(TamSX3("D1_CODISS")[1])	,; // IT_VALISS - Valor do ISS do item sem aplicar o arredondamento
	 		1								,; // IT_QUANT - Quantidade do Item
	 		""								,; // IT_NFORI - Numero da NF Original
	 		""								,; // IT_SERORI - Serie da NF Original
	 		SB1->(RecNo()) 					,; // IT_RECNOSB1
	 		SF4->(RecNo()) 					,; // IT_RECNOSF4
	 		0 })        					   //IT_RECORI
MaFisTes(cTes,SF4->(RecNo()),nY)

//Venda Direta convùnio 51/00
If M->C5_XTIPVEN  $ "04"
	MaFisLoad("IT_PRODUTO" ,SB1->B1_COD ,nY) ;MaFisLoad("IT_QUANT"  ,1         ,nY)
	MaFisLoad("IT_TES"     ,cTes        ,nY) ;MaFisLoad("IT_PRCUNI" ,nValorPre ,nY)
	MaFisLoad("IT_VALMERC" ,nValorPre   ,nY) ;MaFisEndLoad(nY,1)
	MaFisRecal("",nY)
	aExcecao := MaExcecao(nY)

	nAlqIPI   := MaFisRet(nY,"IT_ALIQIPI")/100  			//Aliquota de IPI ja em Percentual  
	nAlqOpIcm := MaFisRet(nY,"IT_ALIQICM")/100  			//Aliquota de ICMS OP em Percentual
	nPerComs  := FatComis(MaFisRet(nY,"IT_PRODUTO"))/100	//Percentual de comissao conforme modelo do veùculo
    
	If !(MaFisRet(nY,"IT_TES") $ cTESTSD)	//-- TES de faturamento p/ veùculo test drive (nùo tem comissùo)
		nValComs := ROUND(nVlrRet * nPerComs,2)
		//oModel:SetValue('MODEL_VRK','VRK_XVLCOM',nValComs)			//Forùa atualizaùùo da tela
		//oModel:SetValue('MODEL_VRK','VRK_XPECOM',nPerComs*100)		//Forùa atualizaùùo da tela
	EndIf
	
	//oModel:SetValue('MODEL_VRK','VRK_VALVDA',nVlrRet)		//Forùa atualizaùùo da tela
	nVlrUnit  := ROUND((nVlrRet - nValComs)/(1+nAlqIPI),2) 
	
	//oModel:SetValue('MODEL_VRK','VRK_XBASIP',nVlrUnit)		//Forùa atualizaùùo da tela
	nVlrUnit  +=  nValComs
	
	//oModel:SetValue('MODEL_VRK','VRK_VALMOV',nVlrUnit) 		//Forùa atualizaùùo da tela
	nVlrRet   := nVlrUnit 
	
	MaFisRecal("",nY)  //Recalcula tudo com a tela atualizada
	
	aEval(aArea,{|x| RestArea(x)})
	
	Return nVlrRet
EndIf

lSuframa := MaFisRet(N,"NF_SUFRAMA")

If !lSuframa 
	/******************************************************************
	**Venda Atacado nùo Suframa Planilha de Referencia para       *****
	**chegar no calculo Unitùrio - Calculadora Concessionaria.xls *****
	*******************************************************************/

	SB1->(DbSetOrder(1)) ; SB1->(DbSeek(xFilial("SB1")+cProduto ))
    SF4->(DbSetOrder(1)) ; SF4->(DbSeek(xFilial("SF4")+cTes     ))
	
    MaFisClear()
	MaFisIniLoad(nY								,;
				{ SB1->B1_COD					,; // IT_PRODUTO
		 		cTes                   			,; // IT_TES
		 		Space(TamSX3("D1_CODISS")[1])	,; // IT_VALISS - Valor do ISS do item sem aplicar o arredondamento
		 		1								,; // IT_QUANT - Quantidade do Item
		 		""								,; // IT_NFORI - Numero da NF Original
		 		""								,; // IT_SERORI - Serie da NF Original
		 		SB1->(RecNo()) 					,; // IT_RECNOSB1
		 		SF4->(RecNo()) 					,; // IT_RECNOSF4
		 		0 })        					   //IT_RECORI

	MaFisTes(cTES ,SF4->(RecNo()),nY)
	MaFisLoad("IT_PRODUTO"  ,SB1->B1_COD ,nY) ; MaFisLoad("IT_QUANT"  ,1         ,nY)
	MaFisLoad("IT_TES"      ,cTes        ,nY) ; MaFisLoad("IT_PRCUNI" ,nValorPre ,nY)
	MaFisLoad("IT_VALMERC"  ,nValorPre   ,nY) ; MaFisEndLoad(nY,1)
	MaFisRecal("",nY)
	aExcecao := MaExcecao(nY)

	nAlqIPI  := MaFisRet(nY,"IT_ALIQIPI")/100  		     //Aliquota de IPI ja em Percentual  
	nAlqIcmSt:= MaFisRet(nY,"IT_ALIQSOL")/100  	         //Aliquota de ICMS ST ja em Percentual
	nAlqOpIcm:= MaFisRet(nY,"IT_ALIQICM")/100  		     //Aliquota de ICMS OP em Percentual 
    nBaseSt  := GDFieldGet("C6_XBASST",N,,aHeader,aCols) //Base de ST Fixa, que estù no produto. (Usado o Conceito de ICMS Pauta)
    
	cTes     := MaFisRet(nY,"IT_TES")          		     //Tes para buscar a reduùùo de Base de ICMS Pois nùo encontrei na MaFisRet
	nAliqStPi:= MaFisRet(nY,"IT_ALIQPS3")/100  		     //Aliquota de Pis    ST em Percentual
	nAliqStCo:= MaFisRet(nY,"IT_ALIQCF3")/100  		     //Aliquota de Cofins ST em Percentual
    nAlqBIcms:= MaFisRet(nY,"IT_PREDIC")      		     //Reduùùo de Base de ICMS
    
	nVlIcmDev := nBaseSt*nAlqIcmSt					     //Valor do ICMS devido (Necessùrio para o calculo Reverso)
	nVlrDesFr := 0									     //Valor de Desconto de Frete, somente ZF e fixo de 1% sobre preùo total de Venda
	nAux1     := nVlrRet-nVlrDesfr - nVlIcmDev		     //Variavel Auxiliar para calculo do Valor Unitùrio             
	nAux2     := 1+nAlqIPI							     //Variavel Auxiliar para calculo do Valor Unitùrio 
	nAux3     := ((nAlqBIcms/100)*nAlqOpIcm)		     //Variavel Auxiliar para calculo do Valor Unitùrio
	
	// grupo e marca de produtos que nao devem ter esta variavel incrementada ao calculo
	If FatNAux3(MaFisRet(nY,"IT_PRODUTO"),cGrupo1,cMarca1)
		nAux3 := 0
	Endif	
	
	nVlrUnit  := nAux1/(nAux2-nAux3)
	nVlrRet   := nVlrUnit

    GDFieldPut("C6_XVLRPRD" , nValorPre                                                        ,N) 
    GDFieldPut("C6_XVLRMVT" , Round(nVlrRet,2)                                                 ,N) 
  //GDFieldPut("C6_XVLRVDA" , nValorPre                                                        ,N)
    GDFieldPut("C6_XVLRVDA" , nValorPre - ((MaFisRet(nY,"IT_ALIQICM")/100) * Round(nVlrRet,2)) ,N) 
    GDFieldPut("C6_PRCVEN"  , Round(nVlrRet,2)                                                 ,N)
    GDFieldPut("C6_PRUNIT"  , Round(nVlrRet,2)                                                 ,N)    
    GDFieldPut("C6_VALOR"   , Round(nVlrRet,2)                                                 ,N)
    GDFieldPut("C6_QTDVEN"  , 1                                                                ,N)
Else
	******************************************************************
	** Programa de Calculo Reverso Baseado na Planilha de Calculo    *
	** Preùos de Venda CAOA x Revenda  - Zona Franca  de Manaus      *
	******************************************************************

	cTes := MaFisRet(nY,"IT_TES") 
	SF4->(DbSetOrder(1))
    SF4->(DbSeek(xFilial("SF4")+cTes))

	MaFisClear()
	SB1->(DbSetOrder(1)) ; SB1->(DbSeek(xFilial("SB1")+cProduto  ))
    SF4->(DbSetOrder(1)) ; SF4->(DbSeek(xFilial("SF4")+cTES      ))

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
	aExcecao := MaExcecao(nY)
	
	aAreaSF4 := GetArea()
	SF4->(DbSetOrder(1))
	If SF4->(DbSeek( xFilial("SF4")+cTes))		
		nRedBPist := SF4->F4_BASEPIS						// Reduùùo da Base de Pis
		nRedBCoSt := SF4->F4_BASECOF						// Reduùùo da Base de Cofins 
		// verifica se tem excecao fiscal e pega de lah quando tiver
		If Len(MaFisRet(nY,"IT_EXCECAO")) > 0
			aExcecao := MaFisRet(nY,"IT_EXCECAO")
			If !Empty(aExcecao[18])
				nRedBPist := aExcecao[18]					// Reduùùo da Base de Pis
			Endif	
			If !Empty(aExcecao[19])
				nRedBCoSt := aExcecao[19]					// Reduùùo da Base de Cofins 
			Endif	
		Endif	
	Endif
	RestArea(aAreaSF4)

	VVPLastSeq(cCodMar,cModVei,cSegMod,cFabMod)
	nVlrNormal	:= VVP->VVP_VALTAB
	nBSICMSST	:= VVP->VVP_BASEST
	nAlqIcms	:= MaFisRet(N,"IT_ALIQICM")											//Aliquota de ICMS OP
	nAlqIcmsST	:= MaFisRet(N,"IT_ALIQSOL")											//Aliquota de ICMS ST
	nVlrIcms	:= (VVP->VVP_BASEST * (nAlqIcmsST/100))								//Valor ICMS
	If MaFisRet(nY,"IT_ALIQPS3") <> 0 .And. MaFisRet(nY,"IT_ALIQCF3") <> 0
		nAlqPCC	:= (MaFisRet(nY,"IT_ALIQPS3") + MaFisRet(nY,"IT_ALIQCF3"))			//Aliquota de Pis+Cofins ST
	Else
		nAlqPCC	:= (aExcecao[12]+aExcecao[13])										//Aliquota de Pis+Cofins ST
	EndIf
	nRedPCC		:= 0																//Reduùùo Pis / Cofins
	nRedIcms	:= MaFisRet(nY,"IT_PREDIC")											//Reduùùo base ICMS
	nAlqIpi		:= MaFisRet(nY,"IT_ALIQIPI")											//Aliquota de IPI
	nAlqIpiZF	:= 0																//Aliquota de IPI Zona Franca
	nVlrDescFr	:= Round((nVlrNormal * nPercZFre),0)								//Desconto frete 1% ZF 
	
	nVlrFator1	:= ((1+(nAlqIpi /100))/100)											//Calculo do Fator 1
	nVlrFator2	:= (   (nRedIcms/100 )/100) /*((1-(nRedIcms/100))/100)*/			//Calculo do Fator 2
	nvlrFator3  := (nVlrFator1 -nVlrFator2 * ((nAlqIcms /100)))/100					//Calculo do Fator 3 

	nVlrUnit	:= ((((nVlrNormal - nVlrDescFr)-nVlrIcms) / nVlrFator3)/10000)		//Valor unitùrio normal
	nDIcmsZF	:= 0																//Desconto do ICMS Normal Zona Franca
	nDIpiZF		:= (nVlrUnit * nAlqIpiZF)											//Desconto do IPI Zona Franca

	nVlrFator1	:= (nVlrUnit * (1 - (nRedPCC/100)))									//Calculo do Fator 1
	nVlrFator2  := (nVlrUnit * (nRedIcms/100)) * (nAlqIcms/100)						//Calculo do Fator 2
	nVlrFator3  := (nVlrFator1 - nVlrFator2) 										//Calculo do Fator 3
	nDPccZF		:= (nVlrFator3 * (nAlqPCC /100))									//Desconto do PIS / COFINS Zona Franca
	nVlrAbtTrb	:= (nDIcmsZF + nDIpiZF + nDPccZF)									//Abatimentos tributos ZF

	nVlrPCCST	:= 0																//PIS/COFINS ST
	nPrecoZF	:= (nVlrNormal - nVlrDescFr - nVlrAbtTrb + nVlrPCCST)				//Preùo de venda Zona Franca
	nVlrRet		:= Round((nPrecoZF- (nBSICMSST*(nAlqIcmsST/100))) / ;
	                     (((100+nAlqIpi)-((nRedIcms/100)*nAlqIcms))/100),2)			//Valor unitùrio final Zona Franca

    GDFieldPut("C6_XVLRPRD" , nValorPre                                                        ,N)
    GDFieldPut("C6_XVLRMVT" , Round(nVlrRet,2)                                                 ,N)
  //GDFieldPut("C6_XVLRVDA" , nValorPre                                                        ,N)
    GDFieldPut("C6_XVLRVDA" , nValorPre - ((MaFisRet(nY,"IT_ALIQICM")/100) * Round(nVlrRet,2)) ,N)
    GDFieldPut("C6_PRCVEN"  , Round(nVlrRet,2)                                                 ,N)
    GDFieldPut("C6_PRUNIT"  , Round(nVlrRet,2)                                                 ,N)
    GDFieldPut("C6_VALOR"   , Round(nVlrRet,2)                                                 ,N)
    GDFieldPut("C6_QTDVEN"  , 1                                                                ,N)
Endif

aEval(aArea,{|x| RestArea(x)})

Return() // Round(nVlrRet,2)

***********************************************
Static Function FatNAux3(cProd,cGrupo1,cMarca1)
***********************************************

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

***********************************************************
Static Function VVPLastSeq(cCodMar,cModVei,cSegMod,cFabMod)
***********************************************************

Local cQuery    As Character
Local cSeq      As Character
Local cAlias    As Character

//Guarda a workarea corrente
cAlias := Alias()

//Gera um alias aleatùrio somente para abrir a query
cQuery := GetNextAlias()

//Cria a query
BeginSql Alias cQuery
    SELECT VVP_BASEST,VVP_DATPRC
    FROM %Table:VVP% VVP
    WHERE   VVP.%NotDel%
        AND VVP_FILIAL      = %Exp:xFilial("VVP")%
	    AND VVP.VVP_CODMA   = %exp:cCodMar%
	    AND VVP.VVP_MODVEI  = %exp:cModVei%
	    AND VVP.VVP_SEGMOD  =  %exp:cSegMod%
	    AND VVP_DATPRC      = 
	(SELECT MAX(VVP_DATPRC) VVP_DATPRC
	 FROM %Table:VVP% VVP1
	 WHERE  VVP1.%NotDel%
		AND VVP1.VVP_FILIAL = VVP.VVP_FILIAL
		AND VVP1.VVP_CODMAR = VVP.VVP_CODMAR
		AND VVP1.VVP_MODVEI = VVP.VVP_MODVEI
		AND VVP1.VVP_SEGMOD = VVP.VVP_SEGMOD
		AND VVP1.VVP_FABMOD = %exp:cFabMod%)
    GROUP BY VVP_BASEST,VVP_DATPRC
	ORDER BY VVP_BASEST,VVP_DATPRC
EndSql

//Se existir registro, retorna o mesmo
If !(cQuery)->(Eof())
    cSeq := (cQuery)->VVP_BASEST
Else
    cSeq := ""
EndIf

DbSelectArea("VVP")
VVP->(DbSetOrder(1))
VVP->(DbSeek(xFilial("VVP")+VV2->VV2_CODMAR+VV2->VV2_MODVEI+VV2->VV2_SEGMOD+(cQuery)->VVP_DATPRC))

//Fecha a query, boa prùtica, tudo que vocù abriu, vocù fecha... E tambùm existem limites de workareas abertas no Protheus
(cQuery)->(DBCloseArea())

//Retorna a workarea corrente, protegido, pois um dbselectarea com valor vazio gera exceùùo
If !Empty(cAlias)
    DBSelectArea(cAlias)
EndIf

Return(cSeq)
