#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "ParmType.ch"

#Define Enter Chr(13)+Chr(10)

//==================================================================================================
//Programa.:              CVMSER01
//Autor....:              Alex Lima
//Data.....:              29/09/2018
//Descricao / Objetivo:   Comunicação dos arquivos de veículos com o sistema SERPRO
//Doc. Origem:            MIT044 - Especificação de Personalização: Integração com o SERPRO
//Solicitante:            CAOA
//Uso......:              CAOA
//Obs......:              Rotina de geração de dados para envio e recepção com leiaute pré-definido
//==================================================================================================
/*/{Protheus.doc} CVMSER01
//TODO Integração com o SERPRO

@author 	Alex Lima
@since 		29/10/2018
@version 	P12
@type 		function
@history 	29/10/2018, Alex Lima, Desenvolvimento inicial.
/*/
User Function CVMSER01()

	Local aArea   		:= {}
	Local cKey    		:= ""
	Local cArq    		:= ""
	Local nIndex  		:= 0
	Local nI      		:= 0
	Local nOpcao  		:= 0
	Local cDesc1  		:= "Este programa tem por objetivo efetuar o envio dos arquivos referentes aos "
	Local cDesc2  		:= "veículos, de acordo com as informações passadas pelo filtro da rotina, para"
	Local cDesc3  		:= "a integração com o SERPRO."
	Local aCpos   		:= {}
	Local aCampos 		:= {}
	Local aSay    		:= {}
	Local aButton 		:= {}
	
	Private cMarca      := "OK"
	Private cCadastro   := OemToAnsi("Integração com o SERPRO")
	Private cPerg       := "CVMSER01"
	Private cFiltro 	:= " "
	Private cArquivo    := " "
	Private nTotal      := 0
	Private aRotina     := {}
	Private aColors     := {}
	
	// Monta tela de interação
	aAdd(aSay,cDesc1)
	aAdd(aSay,cDesc2)
	aAdd(aSay,cDesc3)
	
	aAdd(aButton, { 1,.T.,{|| nOpcao := 1, FechaBatch() }})
	aAdd(aButton, { 2,.T.,{|| FechaBatch()              }})
	
	FormBatch(cCadastro,aSay,aButton)
	
	// Se cancelar
	If nOpcao <> 1
	   Return
	Endif
	
	// Cria as perguntas em SX1
	CriaSX1()
	
	// Monta tela de paramentos para usuario, se cancelar sair
	If !Pergunte(cPerg,.T.)
	   Return
	Endif
	
	// Popula SZ4
	U_CVMSER1P()
	
	// Atribui as variaveis de funcionalidades
	aAdd( aRotina ,{"Pesquisar", 		"AxPesqui()",0,1})
	aAdd( aRotina ,{"Gera arquivo", 	"U_CVMSER1G()",0,3})
	aAdd( aRotina ,{"Retorna arquivo", 	"U_CVMSER1R()",0,3})
	aAdd( aRotina ,{"Legenda", 			"U_CVMSER1L()",0,4})
	
	aAdd( aColors, {" AllTrim(Z4_CODRET)==''   .And. AllTrim(Z4_ARQENV)=='' ", 	"BR_BRANCO"})
	aAdd( aColors, {" AllTrim(Z4_CODRET)==''   .And. AllTrim(Z4_ARQENV)<>'' ", 	"BR_AZUL"})
	aAdd( aColors, {" AllTrim(Z4_CODRET)=='OK' .And. AllTrim(Z4_ARQRET)<>'' ", 	"BR_VERDE"})
	aAdd( aColors, {" AllTrim(Z4_CODRET)<>'OK' .And. AllTrim(Z4_ARQRET)<>'' ", 	"BR_VERMELHO"})
	             
	// Campos do MarkBrowse
	aCpos := {"Z4_MARKBR","Z4_LOTE","Z4_OPEMOV","Z4_VEIC","Z4_CHASSI","Z4_MODELO","Z4_DESCRI","Z4_ANOFAB","Z4_ANOMOD","Z4_ARQENV","Z4_DTAENV","Z4_ARQRET","Z4_DTARET","Z4_CODRET","Z4_DESCRET"}
	dbSelectArea("SX3")
	dbSetOrder(2)
	For nI := 1 To Len(aCpos)
	   SX3->(dbSeek(aCpos[nI]))
	   aAdd(aCampos,{X3_CAMPO,"",Iif(nI==1,"",Trim(X3_TITULO)),Trim(X3_PICTURE)})
	Next

    cFiltro := " "
    If !Empty(MV_PAR03) 
       //cFiltro := "SUBS(SZ4->Z4_VEIC,1,3)=SUBS(MV_PAR03,1,3)"   
	   cFiltro := "SUBS(SZ4->Z4_CODMAR,1,3)=SUBS(MV_PAR03,1,3)"   
    Endif
    
    /*If !Empty(MV_PAR05)    
       cFiltro += SZ4->Z4_MODELO=AllTrim(MV_PAR05)
    Endif
	If !Empty(MV_PAR04) 
	   cFiltro += SZ4->Z4_CHASSI = AllTrim(mv_par04) 
	EndIf 
	If !Empty(MV_PAR06) 
		cFiltro += SZ4->Z4_ANOFAB=SUBS(MV_PAR06,1,4)
		cFiltro += SZ4->Z4_ANOMOD=SUBS(MV_PAR06,5,4)
	EndIf*/

	DbSelectArea("SZ4")
	aArea := GetArea()
	cKey  := IndexKey()
	cArq := CriaTrab( Nil, .F. )
	IndRegua("SZ4", cArq, cKey,, cFiltro)
	nIndex := RetIndex("SZ4")
	nIndex := nIndex + 1
	DbSelectArea("SZ4")
	SZ4->(DbSetOrder(nIndex))
	SZ4->(DbGoTop())
	
	// Apresenta o MarkBrowse
	MarkBrow("SZ4","Z4_MARKBR","SZ4->Z4_CODRET",aCampos,/*lInverte*/,cMarca,/*marcatodos*/,,,,"U_CVMSER1M()",,,,aColors,)
	
	// Desfaz o indice e filtro temporario
	DbSelectArea("SZ4")
	RetIndex("SZ4")
	Set Filter To 
	cArq += OrdBagExt()
	FErase( cArq )
	RestArea( aArea )

Return Nil


/*/{Protheus.doc} CVMSER1M
//TODO Marca ou desmarca o registro para processamento 

@author 	Alex Lima
@since 		28/10/2018
@version 	P12
/*/
User Function CVMSER1M()

	If IsMark("Z4_MARKBR", cMarca )
		RecLock("SZ4",.F.)
		SZ4->Z4_MARKBR := Space(2)
		MsUnLock()
	Else
		If SZ4->Z4_CODRET <> "OK"
			RecLock("SZ4",.F.)
			SZ4->Z4_MARKBR := cMarca
			MsUnLock()
		EndIf
	EndIf

Return .T.


/*/{Protheus.doc} CVMSER1P
//TODO Popula o arquivo de dados SZ4, de acordo com as informações do pergunte

@author 	Alex Lima
@since 		29/10/2018
@version 	P12
/*/
User Function CVMSER1P()
Local aArea 	:= GetArea()
Local cSql001 	:= ""
Local cAliasZ4 	:= ""
Local _lNovo 	:= .T.
//Local cSql002 			:= ""
//Local cAlD1D2 			:= ""
	
	//alert(mv_par03)
	// Consulta principal
	cAliasZ4 := GetNextAlias()
	cSql001 := " "
	cSql001 += "  SELECT  SD2.D2_DOC, "
    cSql001 += "      	  SD2.D2_SERIE, "
    cSql001 += "      	  NVL(VV0.VV0_NUMPED,SD2.D2_PEDIDO) AS VV0_NUMPED, "
    cSql001 += "      	  VV1.VV1_MODVEI AS VV0_MODVEI, "
    cSql001 += "      	  VV1.VV1_FILIAL AS VV0_FILIAL, "
    cSql001 += "      	  NVL(VV0.VV0_OPEMOV,'0')AS VV0_OPEMOV, "
    cSql001 += "      	  VV1.VV1_NUMTRA AS VVA_NUMTRA, "
    cSql001 += "      	  VV1.VV1_CODMAR AS VVA_CODMAR, "
    cSql001 += "      	  NVL(VVA.VVA_CHASSI,SD2.D2_NUMSERI) AS VVA_CHASSI, "
    cSql001 += "      	  VV1.VV1_FABMOD, "
    cSql001 += "      	  VV1.VV1_FABMOD, "
    cSql001 += "      	  VE1.VE1_DESMAR, "
    cSql001 += "      	  VV2.VV2_DESMOD, "
    cSql001 += "      	  SA1.A1_NOME "
	cSql001 += "  FROM " + RetSqlName( "SD2" ) + " SD2  "
	cSql001 += "  JOIN " + RetSqlName( "VV1" ) + " VV1  "
    cSql001 += "      ON  VV1.VV1_FILIAL = '"+FwXFilial("VV1")+"' "
    cSql001 += "      AND VV1.VV1_CHASSI = SD2.D2_NUMSERI "
    cSql001 += "      AND VV1.D_E_L_E_T_ = ' ' "
	cSql001 += "  JOIN " + RetSqlName( "VE1" ) + " VE1  "
    cSql001 += "      ON  VE1.VE1_FILIAL = '"+FwXFilial("VE1")+"' "
    cSql001 += "      AND VE1.VE1_CODMAR = VV1.VV1_CODMAR  "
    cSql001 += "      AND VE1.D_E_L_E_T_ = ' ' "
	cSql001 += "  JOIN " + RetSqlName( "VV2" ) + " VV2  "
    cSql001 += "      ON  VV2.VV2_FILIAL = '"+FwXFilial("VV2")+"' "
    cSql001 += "      AND VV2.VV2_CODMAR = VV1.VV1_CODMAR  "
    cSql001 += "      AND VV2.VV2_MODVEI = VV1.VV1_MODVEI  "
    cSql001 += "      AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD  "
    cSql001 += "      AND VV2.D_E_L_E_T_ = ' ' "
	cSql001 += "  JOIN " + RetSqlName( "SA1" ) + " SA1  "
    cSql001 += "      ON  SA1.A1_FILIAL  = '"+FwXFilial("SA1")+"' "
    cSql001 += "      AND SA1.A1_COD     = SD2.D2_CLIENTE  "
    cSql001 += "      AND SA1.A1_LOJA    = SD2.D2_LOJA  "
    cSql001 += "      AND SA1.D_E_L_E_T_ = ' ' "
	cSql001 += "  LEFT JOIN " + RetSqlName( "VV0" ) + " VV0  "
    cSql001 += "      ON  VV0.VV0_FILIAL = '"+FwXFilial("VV0")+"' "
    cSql001 += "      AND VV0.VV0_NUMPED = SD2.D2_PEDIDO "
    cSql001 += "      AND VV0.D_E_L_E_T_ = ' ' "
	cSql001 += "  LEFT JOIN " + RetSqlName( "VVA" ) + " VVA  "
    cSql001 += "      ON  VVA.VVA_FILIAL  = '"+FwXFilial("VVA")+"' "
    cSql001 += "      AND VVA.VVA_NUMTRA  = VV0.VV0_NUMTRA  "
    cSql001 += "      AND VVA.D_E_L_E_T_ = ' ' "
	cSql001 += "  WHERE SD2.D_E_L_E_T_ 	= ' '  "
    cSql001 += "      AND  SD2.D2_FILIAL = '"+FwXFilial("SD2")+"' "
    cSql001 += "      AND SD2.D2_GRUPO 	= 'VEIA'   "
    cSql001 += "      AND SD2.D2_EMISSAO BETWEEN '" + DToS( MV_PAR01 ) + "' AND '" + DToS( MV_PAR02 ) + "'   "
	If !Empty(MV_PAR03)     
        cSql001 += "      AND VV1.VV1_CODMAR = '" + AllTrim( MV_PAR03 ) + "' "
	EndIf
	memowrite('C:\temp\consulta.sql',cSql001)

    //cSql001 := ChangeQuery(cSql001)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql001),cAliasZ4,.F.,.T.)

	//FwMsgRun(,{|| DbUseArea( .T., "TOPCONN", TcGenQry(, , cSql001), cAliasZ4, .T., .T.)},,"Executando consulta na base de dados.")
	
	If (cAliasZ4)->(EoF())
		MsgInfo("Não foram encontradas informações com os filtros informados. Por favor, revise os filtros.", "Sem novas informações")
		Return nIL
	EndIf
	
	DbSelectArea("SZ4")
	SZ4->(dbSetOrder(2)) // Z4_FILIAL + Z4_CHASSI + Z4_LOTE + Z4_ANOLOTE
	DbSelectArea(cAliasZ4)
	(cAliasZ4)->(DbGoTop())

	While (cAliasZ4)->(!Eof())
		cChassi := " "
		cChassi := PadR( (cAliasZ4)->VVA_CHASSI, TamSx3("Z4_CHASSI")[1] )
		If	AllTrim( cChassi ) == " "
			(cAliasZ4)->( DbSkip() )
			Loop
		EndIf
		If SZ4->( DbSeek( xFilial("SZ4") + cChassi ) ) .And. SZ4->Z4_CODRET == "OK"
			(cAliasZ4)->( DbSkip() )
			Loop
		EndIf
		_lNovo := SZ4->( !DbSeek( xFilial("SZ4") + cChassi ) )
		//para alteração validar se esta com referencia OK
		If If(!_lNovo,AllTrim(SZ4->Z4_CODRET) <> "OK",.T.)
			RecLock("SZ4", _lNovo)
			SZ4->Z4_FILIAL := xFilial("SZ4")
			SZ4->Z4_CHASSI := (cAliasZ4)->VVA_CHASSI
			SZ4->Z4_OPEMOV := Iif( (cAliasZ4)->VV0_OPEMOV == "2", "4", "0" )
			SZ4->Z4_VEIC   := (cAliasZ4)->VE1_DESMAR    //(cAliasZ4)->VV0_DESMAR
			SZ4->Z4_MODELO := (cAliasZ4)->VV0_MODVEI
			SZ4->Z4_DESCRI := (cAliasZ4)->VV2_DESMOD    //(cAliasZ4)->VV0_DESMOD
			SZ4->Z4_CODMAR := (cAliasZ4)->VVA_CODMAR
			SZ4->Z4_ANOFAB := SubStr( (cAliasZ4)->VV1_FABMOD, 1, 4)   //SubStr( (cAliasZ4)->VV0_FABMOD, 1, 4) 
			SZ4->Z4_ANOMOD := SubStr( (cAliasZ4)->VV1_FABMOD, 1, 4)   //SubStr( (cAliasZ4)->VV0_FABMOD, 5, 4)
			SZ4->(MsUnlock())
		EndIf
	    (cAliasZ4)->(DbSkip())
	EndDo
	
	(cAliasZ4)->( DbCloseArea() )
	DbSelectArea("SZ4")
	SZ4->(DbCloseArea())
	RestArea(aArea)

Return


/*/{Protheus.doc} CVMSER1G
//TODO Geração do arquivo para envio.

@author 	Alex Lima
@since 		28/10/2018
@version 	P12
/*/
User Function CVMSER1G()
Local aArea 	:= GetArea()
Local lRet 		:= .F.

Private aRegs 	:= {}
	
	DbSelectArea("SZ4")
	SZ4->(DbSetOrder(2))
	SZ4->(DbGoTop())
	While SZ4->(!Eof())
	   If SZ4->Z4_MARKBR <> cMarca .Or. SZ4->Z4_CODRET == "OK"
	      SZ4->(dbSkip())
	      Loop
	   Endif
	   aAdd( aRegs, {SZ4->Z4_FILIAL, SZ4->Z4_CHASSI, SZ4->Z4_LOTE, SZ4->Z4_OPEMOV} )
	   SZ4->(dbSkip())
	EndDo
	
	If Len(aRegs) == 0
		MsgInfo("Não existem itens selecionados para gerar o arquivo. Por favor selecione algum item.", "Selecionar itens")
		Return
	EndIf
	
	If MsgYesNo("Confirma a geração do arquivo?", "Confirma geração")
		lRet := fGeraAux( aRegs )
	Endif
	
	If lRet
		MsgInfo("Arquivo de envio gerado com sucesso.","Geração do arquivo")
	Else
		MsgInfo("Falha na geração do arquivo de envio.","Geração do arquivo")
	EndIf
	RestArea(aArea)
Return Nil


/*/{Protheus.doc} fGeraAux
//TODO Executa a leitura dos itens selecionados e faz a geração do arquivo

@author 	Alex Lima
@since 		28/10/2018
@version 	P12
@param 		aRegs, array, Array com os itens a serem gerados
@type 		function
/*/
Static Function fGeraAux( aRegs )
Local aArea 			:= GetArea()
Local cRegITP 			:= " "
Local cRegVF1 			:= " "
Local cRegVF2 			:= " "
Local cRegFTP 			:= " "
Local cNumLot 			:= " "
//Local cMesFab 			:= " "	
Local cModVei           := " "
Local cArqDir 			:= cGetFile("Documentos LS|*.LS|LE|*.LE",OemToAnsi("Selecionar o diretório para geração..."),0,"C:\",.T.,GETF_LOCALHARD+GETF_RETDIRECTORY, .F.)
Local cArqName 			:= ""
Local cArqAmb 			:= SuperGetMv("CAOA_VEI01", .F., "HO", "")
Local nXi 				:= 0
Local nContReg 			:= 0
Local nHandle 			:= 0
Local lRet 				:= .F.
//Local lBuild 			:= .F.
Local cQuery 			:=	""
Local cTmpAlias			:= GetNextAlias()
Local aOriArea			:= {}
Local lVV0 				:= .T.
Local lVVA 				:= .T.
Local _cTpVeiculo     	:= AllTrim(SuperGetMV( "CAOA_VEI02" , ,"23" ))   //Tipo de Veículos que são conjugados    GAP131  Tratamento no arquivo SERPRO para caminhões HR e HD    
Local _cTipoCarroc     	:= AllTrim(SuperGetMV( "CAOA_VEI03" , ,"194" ))   //Tipo de carrocerias     GAP131  Tratamento no arquivo SERPRO para caminhões HR e HD    
Local _cTipoMontgem		:= ""
	/*
	// Verifica a Build
	lBuild := GetBuild( .T. ) >= "7.00.131227A-20141119"
	If lBuild
		OpenSm0( cEmpAnt, .T.)
	Else
		DbSelectArea("SM0")
	EndIf
	*/

	OpenSm0( cEmpAnt, .T.)
	cNumLot := GetSxeNum("SZ4", "Z4_LOTE", "Z4_LOTE" + Str( Year(dDataBase) ), 3 )
	cArqName += "K3244.K29822" 		// K3244.K29822 = Constante indicando DSN de entrada
	cArqName += cArqAmb 			// aa = ambiente de processamento: PR (produção) ou HO (homologação)
	cArqName += "."+"M" 			// M = Fixo identificação do Código Cliente da Montadora
	cArqName += "AN31" 				// cccc = código de cliente (valor tabelado*)
	cArqName += "."+"L" 			// L = Fixo identificação de Lote
	cArqName += cValToChar(cNumLot) // lllll = numero de lote (5 posições)
	cArqName += "."+"LE" 			// LE = constante indicando lote de entrada.
	
	nHandle := FCreate(cArqDir + cArqName)
	If nHandle < 0
		MsgAlert("Não foi possível criar o arquivo!")
		lRet := .F.
		Return lRet
	EndIf
	
	// ITP - CABEÇALHO DO ARQUIVO (COM O LOTE)
	cRegITP := ""
	cRegITP += "ITP" 										// 001 a 003: IDENTIFICAÇÃO DO REGISTRO <ITP>
	/* falta definição de onde vem este campo*/
	cRegITP += "000" 										// 004 a 006: NÚMERO DA TRASAÇÃO DE COMUNICAÇÃO <não definido>
	cRegITP += "02" 										// 007 a 008: NÚMERO DA VERSÃO DO LAY-OUT <02 (Obrigatório)>
	cRegITP += cNumLot 										// 009 a 013: NÚMERO DO LOTE <SZ4->Z4_LOTE> 
	cRegITP += DToS(dDataBase) +""+ StrTran(Time(),":","") 	// 014 a 027: IDENTIFICAÇÃO DA GERAÇÃO DO MOVIMENTO <AAAAMMDDHHNNSS>
	cRegITP += SM0->M0_CGC 									// 028 a 041: IDENTIFICAÇÃO DO TRANSMISSOR NA COMUNICAÇÃO
	cRegITP += "33683111000107" 							// 042 a 055: IDENTIFICAÇÃO DO RECEPTOR NA COMUNICAÇÃO
	/* falta definição de onde vem este campo*/
	cRegITP += PadR("95P",06) 								// 056 a 061: CÓDIGO INTERNO DO TRANSMISSOR <Código da Montadora conforme tabela do DENATRAN >
	/* falta definição de onde vem este campo*/
	cRegITP += Space(08) 									// 062 a 069: CÓDIGO INTERNO DO RECEPTOR (código do SERPRO no cliente)
	/* falta definição de onde vem este campo*/
	cRegITP += PadR("AN31",04) 								// 070 a 073: CÓDIGO INTERNO DO CLIENTE < Código Cliente da Montadora, conforme tabela do DENATRAN (Obs. As Montadoras deverão solicitar este código ao DENATRAN) >
	cRegITP += Space(80) 									// 074 a 153: ESPAÇO (FILLER) <Brancos>
	cRegITP += Enter
	nContReg += 1
	FWrite(nHandle, cRegITP )
	
	SF2->(dbSetOrder(1))
	DbSelectArea("SZ4")
	SZ4->(DbSetOrder(2)) // Z4_FILIAL + Z4_CHASSI + Z4_LOTE + Z4_ANOLOTE
	
	DbSelectArea("VVA")
	VVA->(DbSetOrder(2)) // VVA_FILIAL + VVA_CHASSI + VVA_NUMTRA
	
	DbSelectArea("VV0")
	VV0->(DbSetOrder(1)) // VV0_FILIAL + VV0_NUMTRA

	DbSelectArea("VV1")
	VV1->(DbSetOrder(2)) // VV1_FILIAL + VV1_CHASSI
	
	DbSelectArea("VV2")
	VV2->(DbSetOrder(1)) // VV2_FILIAL + VV2_CODMAR + VV2_MODVEI + VV2_SEGMOD

	DbSelectArea("VVC")
	VVC->(DbSetOrder(1)) // VVC_FILIAL + VVC_CODMAR + VVC_CORVEI

	DbSelectArea("VVE")
	VVE->(DbSetOrder(1)) // VVE_FILIAL + VVE_ESPVEI

	DbSelectArea("VE1")
	VE1->(DbSetOrder(1)) // VE1_FILIAL + VE1_CODMAR
	
	DbSelectArea("VVF")
	VVF->(DbSetOrder(1)) // VVF_FILIAL + VVF_TRACPA

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA

	DbSelectArea("SD1")
	SD1->(DbSetOrder(1)) // D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA
		
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1)) // A2_FILIAL + A2_COD + A2_LOJA

	DbSelectArea("SW6")
	SW6->(DbSetOrder(1)) // W2_FILIAL + W6_HAWB   
	
	// VF1 - DETALHES DO VEÍCULO (PARTE 1)
	For nXi := 1 To Len(aRegs)
		cQuery :=  " SELECT * FROM " + RetSqlName("SD2") 
        cQuery +=  " WHERE D_E_L_E_T_ = ' '
        cQuery +=  "   AND D2_FILIAL = '" 	+ xFilial("SD2") + "' "
        cQuery +=  "   AND D2_NUMSERI = '" 	+ aRegs[nXi][02] + "' "
		If Select( cTmpAlias ) <> 0 ; ( cTmpAlias )->( DbCloseArea() ) ; EndIf
		DbUseArea(.T. , "TOPCONN" , TcGenQry( ,,cQuery ) , cTmpAlias , .F. , .T. )
		If ( cTmpAlias )->(Eof())
			Loop
		EndIf
		If !VVA->( DbSeek( xFilial("VVA") + aRegs[nXi][02] ) )
			//Loop
			lVVA := .F.
		else
			lVVA := .T.
		EndIf
		If !VV1->( DbSeek( xFilial("VV1") + aRegs[nXi][02] ) )
			Loop
		EndIf
		If !VV0->( DbSeek( xFilial("VV0") + VV1->VV1_NUMTRA ) )
			lVV0 := .F.
			//Loop
		else
			lVV0 := .T.
		EndIf
		If !VV2->( DbSeek( xFilial("VV2") + VV1->( VV1_CODMAR + VV1_MODVEI + VV1_SEGMOD) ) )
			Loop
		EndIf                                   
		//If VVF->( DbSeek( xFilial("VVF") + VV1->VV1_TRACPA ) ) 
			//cMesFab := SUBSTR(DTOS(VVF->VVF_DATFAB),5,2)
		//EndIf                                   
		if lVV0
			cCliente := VV0->(VV0_CODCLI + VV0_LOJA)
			cFornece := VV0->(VV0_CODCLI + VV0_LOJA)
			cNf := VV0->VV0_NUMNFI + VV0->VV0_SERNFI + VV0->VV0_CODCLI + VV0->VV0_LOJA
		else
			cCliente := (cTmpAlias )->( D2_CLIENTE + D2_LOJA ) 
			cFornece := (cTmpAlias )->( D2_CLIENTE + D2_LOJA ) 
			cNf := (cTmpAlias )->( D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) 
		Endif                                                                 
		SD1->( DbSeek( xFilial("SD1") + VVF->VVF_NUMNFI + VVF->VVF_SERNFI + VVF->VVF_CODFOR + VVF->VVF_LOJA ) ) 
		SW6->( DbSeek( xFilial("SW6") + SD1->D1_CONHEC ) )   //VVF->(VVF_CODCLI + VV0_LOJA) ) )
		SA1->( DbSeek( xFilial("SA1") + cCliente ) )
		SA2->( DbSeek( xFilial("SA2") + cCliente ) )
		VVC->( DbSeek( xFilial("VVC") + VV1->(VV1_CODMAR + VV1_CORVEI) ) )
		VVE->( DbSeek( xFilial("VVE") + VV2->VV2_ESPVEI ) )
		VE1->( DbSeek( xFilial("VV1") + VV2->VV2_CODMAR ) )
		SF2->(dbSeek(xFilial("SF2")+cNF ))
		cRegVF1 := ""
		cRegVF1 += "VF1" 										// 001 a 003: IDENTIFICAÇÃO DO REGISTRO <VF1>
		cRegVF1 += PadR(VV1->VV1_CHASSI,17) 					// 004 a 020: IDENTIFICAÇÃO DO VEÍCULO <VIN (Número do Chassi)>
		/*Quando é remarcado?*/
		cRegVF1 += "N" 											// 021 a 021: CÓDIGO DE SITUAÇÃO DO VIN <N – Normal/ R – Remarcado>
		/*Quando é exclusão?*/
		cAltera := IIf( AllTrim(SZ4->Z4_ARQRET) == "", "1", "2") 
		/*Quando é alteração ou exclusão*/
		cRegVF1 += PadR(cAltera,01)								// 022 a 022: CÓDIGO DE ATUALIZAÇÃO <1 – Inclusão/ 2 – Alteração/ 3 – Exclusão>
		/*O que seria?*/
		//GAP131  Tratamento no arquivo SERPRO para caminhões HR e HD
		If !Empty(VV2->VV2_TIPVEI)  .And. AllTrim(VV2->VV2_TIPVEI) $ _cTpVeiculo 
			_cTipoMontgem := "2"
		Else
			_cTipoMontgem := "1"
		Endif	
		//cRegVF1 += "1" 											// 023 a 023: TIPO DE MONTAGEM <1 – Completa/ 2 – Incompleta>
		cRegVF1 += _cTipoMontgem 								// 023 a 023: TIPO DE MONTAGEM <1 – Completa/ 2 – Incompleta>
		cRegVF1 += PadR(VVC->VVC_GRUCOR,02) 					// 024 a 025: CÓDIGO DA COR PREDOMINANTE <Código de Cor conforme Tabela DENATRAN>
		cRegVF1 += PadR(VV2->VV2_TIPVEI,02) 					// 026 a 027: CÓDIGO DO TIPO DE VEÍCULO <Código de Tipo de Veículo conforme Tabela DENATRAN>
		cRegVF1 += StrZero(Val(VVE->VVE_ESPREN),02) 			// 028 a 029: CÓDIGO DA ESPECIE DO VEÍCULO <Código da Espécie de Veículo conforme Tabela DENATRAN>
		cModVei := " "
		cModVei := VV2->VV2_MODFAB
		//cModVei := Str( Val(VV2->VV2_TIPREN))
		//cModVei += Str( Val(VE1->VE1_MAREDI))
		//cModVei += Str( Val(VVE->VVE_ESPREN))
		//cModVei += PadR(VV2->VV2_CARREN,03)'
		cRegVF1 += PadR(cModVei,06)//PadR(VV2_MODFAB,06) 		// 030 a 035: CÓDIGO DA MARCA/MODELO <Código da Marca /Modelo do Veículo conforme Tabela DENATRAN>  PadR(cModVei,06)
		cRegVF1 += PadR(VV1->VV1_NUMMOT,21) 					// 036 a 056: NÚMERO DO MOTOR DO VEÍCULO <Número gravado no Motor do veículo>
		//Campo COMVEI = 0=Gasolina;1=Alcohol;2=Diesel;3=Gas Natural;4=Alcool/Gasolina;5=Alcool/Gasolina/GNV;9=Sin Combustible                           
		//cRegVF1 += PadR(VV1->VV1_COMVEI,02) 					// 057 a 058: CÓDIGO DO TIPO DE COMBUSTIVEL <Código do Combustível do veículo, conforme Tabela DENATRAN>
		DO CASE 
		    Case VV1->VV1_COMVEI == '0'
		        cRegVF1 += '02'
		    Case VV1->VV1_COMVEI == '1'
		        cRegVF1 += '01'
		    Case VV1->VV1_COMVEI == '2'
		        cRegVF1 += '03'
		    Case VV1->VV1_COMVEI == '3'
		        cRegVF1 += '15'
		    Case VV1->VV1_COMVEI == '4'
		        cRegVF1 += '16'
		    Case VV1->VV1_COMVEI == '5'
		        cRegVF1 += '17'
		    Case VV1->VV1_COMVEI == '9'
		        cRegVF1 += 'XX'
			Case VV1->VV1_COMVEI == 'K'
				cRegVF1 += '18'
			Case VV1->VV1_COMVEI == 'L'
				cRegVF1 += '19'
		EndCase
		cRegVF1 += PadR(SA1->A1_EST,02) 						// 059 a 060: CÓDIGO DO ESTADO DE DESTINO <Sigla da Unidade da Federação do faturado>
		cCliTip := Iif( SA1->A1_PESSOA == "F", "1", "2" )
		cRegVF1 += PadR(cCliTip,01) 							// 061 a 051: CÓDIGO DO TIPO DE CADASTRO DO FATURADO <1 – CPF/ 2 – CGC>
		cRegVF1 += PadR(SA1->A1_CGC,14) 						// 062 a 075: NÚMERO DE CADASTRO DO FATURADO <Número do CPF ou CGC do Faturado>
		cRegVF1 += StrZero(0,2) 								// 076 a 077: CÓDIGO RESTRIÇÃO SOBRE O VEÍCULO <Código de Restrição do veículo, conforme Tabela DENATRAN> "00" sem restrição 
		cRegVF1 += PadR(SubStr(SUBSTR(DTOS(SF2->F2_EMISSAO),5,2),1,2),02) // VVF->VVF_DATFAB078 a 079: MÊS DE FABRICAÇÃO DO VEICULO <Mês de Fabricação do veículo>  VV1->VV1_FABMES
		cRegVF1 += PadR(SubStr(VV1->VV1_FABMOD,1,4),04) 		// 080 a 083: ANO DE FABRICAÇÃO DO VEÍCULO <Ano de Fabricação do veículo>
		cRegVF1 += PadR(SubStr(VV1->VV1_FABMOD,5,4),04) 		// 084 a 087: ANO/MODELO DO VEÍCULO <Ano/Modelo do veículo>
		cRegVF1 += StrZero(VV2->VV2_POTMOT,03) 					// 088 a 090: QUANTIDADE DE POTÊNCIA <Potência do Motor>
		cRegVF1 += PadR("C",01) 								// 091 a 091: UNIDADE DE POTÊNCIA <Unidade em que potência do veículo foi expressa (Hp/Cv)>
		//cRegVF1 += StrZero(VV1->VV1_CILMOT,04) 					// 092 a 095: NÚMERO DE CILINDRADAS DO VEÍCULO <Número de Cilindradas de Ciclomotores, Motonetas, Motocicletas, Triciclos e Quadriciclos (Tipos de Veículo = 02, 03, 04, 05 e 21)
		cRegVF1 += StrZero(VV2->VV2_CILMOT,04) 					// 092 a 095: NÚMERO DE CILINDRADAS DO VEÍCULO <Número de Cilindradas de Ciclomotores, Motonetas, Motocicletas, Triciclos e Quadriciclos (Tipos de Veículo = 02, 03, 04, 05 e 21)
		aOriArea := GetArea()
		cQuery := ""
		cQuery += " SELECT	VV1_CHASSI	,														"+(Chr(13)+Chr(10))
		cQuery += " 		W6_DI_NUM	,														"+(Chr(13)+Chr(10))
		cQuery += " 		W6_DTREG_D															"+(Chr(13)+Chr(10))
		cQuery += " FROM "+RetSqlName("VV1")+" VV1 												"+(Chr(13)+Chr(10))
		cQuery += " 	LEFT JOIN																"+(Chr(13)+Chr(10))
		cQuery += " 	"+RetSqlName("SWN")+" SWN ON '"+xFilial("SWN")+"' = SWN.WN_FILIAL		"+(Chr(13)+Chr(10))
		cQuery += " 								AND	VV1_CHASSI		  = SWN.WN_XVIN			"+(Chr(13)+Chr(10))
		cQuery += " 								AND VV1.D_E_L_E_T_	  = SWN.D_E_L_E_T_		"+(Chr(13)+Chr(10))
		cQuery += " 	LEFT JOIN																"+(Chr(13)+Chr(10))
		cQuery += " 	"+RetSqlName("SW6")+" SW6 ON '"+xFilial("SW6")+"' = SW6.W6_FILIAL		"+(Chr(13)+Chr(10))
		cQuery += " 								AND SWN.WN_HAWB		  = SW6.W6_HAWB			"+(Chr(13)+Chr(10))
		cQuery += " 								AND SWN.D_E_L_E_T_	  = SW6.D_E_L_E_T_		"+(Chr(13)+Chr(10))
		cQuery += " WHERE	VV1_FILIAL		= '"+xFilial("VV1")+"'								"+(Chr(13)+Chr(10))
		cQuery += " 	AND VV1_CHASSI		= '"+VV1->VV1_CHASSI+"'								"+(Chr(13)+Chr(10))
		cQuery += " 	AND VV1.D_E_L_E_T_	= ' '												"+(Chr(13)+Chr(10))

		If Select(cTmpAlias) <> 0 ; (cTmpAlias)->(DbCloseArea()) ; EndIf
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpAlias,.F.,.T.)
        //IF !Empty(VV1->VV1_DI)
		IF (cTmpAlias)->(!Eof()) .And. !Empty(Alltrim((cTmpAlias)->W6_DI_NUM))
			//cRegVF1 += StrZero(VAL(VV1->VV1_DI),10)				// 096 a 105: NÚMERO DA DI <Número da Declaração de Importação>
			/*
			cRegVF1 += VV1->VV1_DI                  				// 096 a 105: NÚMERO DA DI <Número da Declaração de Importação>
			cRegVF1 += SUBSTR(DTOS(VV1->VV1_DTDI),7,2)+SUBSTR(DTOS(VV1->VV1_DTDI),5,2)+SUBSTR(DTOS(VV1->VV1_DTDI),1,4)// 106 a 113: DATA DE DESEMBARAÇO DA DI <Data de Desembaraço da DI, no formato DDMMAAAA, onde: DD = dia, MM = mês, AAAA = ano.>
			*/
			cRegVF1 += Substr((cTmpAlias)->W6_DI_NUM  ,1,10)        				// 096 a 105: NÚMERO DA DI <Número da Declaração de Importação>
			cRegVF1 += SUBSTR((cTmpAlias)->W6_DTREG_D,7,2)+SUBSTR((cTmpAlias)->W6_DTREG_D,5,2)+SUBSTR((cTmpAlias)->W6_DTREG_D,1,4)// 106 a 113: DATA DE DESEMBARAÇO DA DI <Data de Desembaraço da DI, no formato DDMMAAAA, onde: DD = dia, MM = mês, AAAA = ano.>
			//cRegVF1 += StrZero(VAL(SW6->W6_DI_NUM),10)				// 096 a 105: NÚMERO DA DI <Número da Declaração de Importação>
			//cRegVF1 += SUBSTR(DTOS(SW6->W6_DTREG_D),7,2)+SUBSTR(DTOS(SW6->W6_DTREG_D),5,2)+SUBSTR(DTOS(SW6->W6_DTREG_D),1,4)// 106 a 113: DATA DE DESEMBARAÇO DA DI <Data de Desembaraço da DI, no formato DDMMAAAA, onde: DD = dia, MM = mês, AAAA = ano.>
        Else
			cRegVF1 += '000000000000000000'
        EndIF
		If Select(cTmpAlias) <> 0 ; (cTmpAlias)->(DbCloseArea()) ; EndIf
		RestArea(aOriArea)
		cRegVF1 += '7276001'// Fixo conforme orientação CAOA Substr(W6_LOCALN,1,7)// 114 a 120: CÓDIGO DA UNIDADE LOCAL DA SRF <Código da Unidade Local do Desembaraço Aduaneiro>
		cRegVF1 += IIF(VV1->VV1_DISCAT=='0','N','S')             // 121 a 121: DISPENSA DE CAT <Indica se o veículo tem dispensa de Certificação de Adequação à Legislação de Trânsito. Em caso de dispensa, preencher com ‘S’. Caso contrario, preencher ‘ N’. > 
		cRegVF1 += SPACE(20) //VV1->VV1_SIMRAV								// 122 a 141: SIMRAV ID <Código de Identificação SIMRAV> 
		cRegVF1 += StrZero(VV2->VV2_LCVM,05)					// 142 a 146: LCVM <Número da Licença para Uso da Configuração de Veículo ou Motor. Campo não obrigatório.>
		cRegVF1 += Space(12) 									// 147 a 153: ESPAÇO (FILLER) <Brancos>
		cRegVF1 += Enter
		nContReg += 1
		FWrite(nHandle, cRegVF1 )
	
		// VF2 - DETALHES DO VEÍCULO (PARTE 2)
		cRegVF2 := ""
		cRegVF2 += "VF2"										// 001 a 003: IDENTIFICAÇÃO DO REGISTRO <VF2>
		//cRegVF2 += PadL(StrTran(Alltrim(STR(Round(VV2->VV2_CAPTRA/1000,2))),".",""),5,"0")					// 004 a 008: CAPACIDADE MAXIMA DE TRAÇÃO <Quantidade máxima de tração expressa em toneladas. Duas casas decimais: NNN,NN toneladas>
		//cRegVF2 += PadL(StrTran(Alltrim(STR(Round(VV2->VV2_CAPTRA * 0.001,2))),".",""),5,"0")					// 004 a 008: CAPACIDADE MAXIMA DE TRAÇÃO <Quantidade máxima de tração expressa em toneladas. Duas casas decimais: NNN,NN toneladas>
		cRegVF2 += PadL(StrTran(Alltrim(Transform(VV2->VV2_CAPTRA * 0.001, "@E 999.99")), ",", "" ), 5, "0")
		/* falta definição de onde vem este campo*/
		cRegVF2 += PadR(VV1->VV1_NUMCMO,21)						// 009 a 029: NÚMERO DA CARROCERIA/CABINE <Número gravado na Caixa de Carroceria ou Cabine do Veículo.>
		//GAP131  Tratamento no arquivo SERPRO para caminhões HR e HD
		//cRegVF2 += PadR(VV2->VV2_CARREN,03) 					// 030 a 032: CÓDIGO DO TIPO DE CARROCERIA <Código de tipo de Carroceria conforme Tabela DENATRAN>
		If !Empty(VV2->VV2_TIPVEI)  .And. AllTrim(VV2->VV2_TIPVEI) $ _cTpVeiculo 
			cRegVF2 += _cTipoCarroc 								// 030 a 032: CÓDIGO DO TIPO DE CARROCERIA <Código de tipo de Carroceria conforme Tabela DENATRAN>
		Else 
			cRegVF2 += PadR(VV2->VV2_CARREN,03) 								// 030 a 032: CÓDIGO DO TIPO DE CARROCERIA <Código de tipo de Carroceria conforme Tabela DENATRAN>
		Endif
		
		cRegVF2 += PadR(VV1->VV1_CAMBIO,21)						// 033 a 053: NÚMERO DA CAIXA DE CAMBIO <Número gravado na Caixa de Câmbio do veículo>
		cRegVF2 += PadR(VV1->VV1_NUMDIF,21)						// 054 a 074: NÚMERO DO EIXO TRASEIRO/DIFERENCIAL <Número gravado no Eixo Traseiro/Diferencial do veículo>
		cRegVF2 += PadR(VV1->VV1_3EIXO,21)						// 075 a 095: NÚMERO DO TERCEIRO EIXO <Número gravado no Terceiro Eixo do veículo>
		//cRegVF2 += PadL(StrTran(Alltrim(STR(Round(VV2->VV2_CAPTRA/1000,2))),".",""),5,"0") 	// 096 a 100: CAPACIDADE MAXIMA DE CARGA <Quantidade máxima de carga expressa em toneladas. Duas casas decimais: NNN,NN toneladas>
		//cRegVF2 += PadL(StrTran(Alltrim(STR(Round(VV2->VV2_CAPCAR * 0.001,2))),".",""),5,"0") 	// 096 a 100: CAPACIDADE MAXIMA DE CARGA <Quantidade máxima de carga expressa em toneladas. Duas casas decimais: NNN,NN toneladas>
		cRegVF2 += PadL(StrTran(Alltrim(Transform(VV2->VV2_CAPCAR * 0.001, "@E 999.99")), ",", "" ), 5, "0")
		//cRegVF2 += PadL(StrTran(Alltrim(STR(Round(VV2->VV2_PESBRU/1000,2))),".",""),5,"0") 	// 101 a 105: PESO BRUTO TOTAL <Peso Bruto Total do veículo expresso em toneladas. Duas casas decimais: NNN,NN toneladas>
		//cRegVF2 += PadL(StrTran(Alltrim(STR(Round(VV2->VV2_PESBRU * 0.001,2))),".",""),5,"0") 	// 101 a 105: PESO BRUTO TOTAL <Peso Bruto Total do veículo expresso em toneladas. Duas casas decimais: NNN,NN toneladas>
		cRegVF2 += PadL(StrTran(Alltrim(Transform(VV2->VV2_PESBRU * 0.001, "@E 999.99")), ",", "" ), 5, "0")
		cRegVF2 += StrZero(VV2->VV2_QTDEIX,02) 					// 106 a 107: NÚMERO DE EIXOS <Quantidade de Eixos do veículo>
		cRegVF2 += StrZero(VV2->VV2_QTDPAS,03) 					// 108 a 110: CAPACIDADE MÁXIMA DE LOTAÇÃO <Quantidade máxima permitida de passageiros sentados>
		cRegVF2 += Space(43)									// 111 a 153: ESPAÇO (FILLER) <Brancos>
		cRegVF2 += Enter
		nContReg += 1
		FWrite(nHandle, cRegVF2 )
	
		If SZ4->( DbSeek( xFilial("SZ4") + aRegs[nXi][02] ) )
			RecLock("SZ4", .F.)
				Replace Z4_ANOLOTE 	With cValToChar( Year(dDataBase) )
				Replace Z4_LOTE 	With cNumLot
				Replace Z4_ARQENV 	With cArqName
				Replace Z4_DTAENV 	With dDataBase
				Replace Z4_MARKBR 	With "  "
			MsUnLock()
			
		EndIf
	
	Next nXi
	
	// FTP - RODAPÉ DO ARQUIVO (COM O TOTAL DE REGISTROS)
	If nContReg > 1
		nContReg += 1
		cRegFTP := ""
		cRegFTP += "FTP"										// 001 a 003: IDENTIFICAÇÃO DO REGISTRO <FTP>
		cRegFTP += cNumLot										// 004 a 008: NÚMERO DO LOTE <Número do Lote conforme informado no registro de Identificação>
		cRegFTP += StrZero(nContReg,9)							// 009 a 017: QUANTIDADE DE REGISTROS <Somatório dos Registros tipo ITP + VF1 + VF2 + FTP >
		cRegFTP += SPACE(136)										// 018 a 153: ESPAÇO (FILLER) <Brancos>
		FWrite(nHandle, cRegFTP )
		lRet := FClose(nHandle)
		If lRet
			ConfirmSX8()
		EndIf
	Else
		lRet := FClose(nHandle)
		RollbackSx8()
		lRet := .F.
	EndIf

	/*
	DbSelectArea("SZ4")
	SZ4->(DbCloseArea())
	DbSelectArea("VVA")
	VVA->(DbCloseArea())
	DbSelectArea("VV0")
	VV0->(DbCloseArea())
	DbSelectArea("VV1")
	VV1->(DbCloseArea())
	DbSelectArea("VV2")
	VV2->(DbCloseArea())
	DbSelectArea("VVC")
	VVC->(DbCloseArea())
	DbSelectArea("VVE")
	VVE->(DbCloseArea())
	DbSelectArea("VE1")
	VE1->(DbCloseArea())
	DbSelectArea("SA1")
	SA1->(DbCloseArea())
	DbSelectArea("SA2")
	SA2->(DbCloseArea())
	*/
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} CVMSER1R
//TODO Leitura do arquivo de retorno.

@author 	Alex Lima
@since 		28/10/2018
@version 	P12

@history 	08/11/2018, Alex Lima, Desenvolvimento inicial efetuado sem o documento de leiaute, apenas com a regra passada pelo analista TOTVS.
/*/
User Function CVMSER1R()
Local aArea 			:= GetArea()
Local cLine 			:= ""
Local cChassi 			:= ""
Local cMsgRet 			:= ""
Local cCodRet 			:= ""
Local cArq 				:= cGetFile("Documentos LS|*.LS|",OemToAnsi("Selecionar o arquivo de retorno..."),0,"C:\",.T.,GETF_LOCALHARD, .F.)
Local nHandle 			:= 0
Local nCountOk 			:= 0
Local nCountEr 			:= 0
	
	nHandle := FT_FUse(cArq)
	If nHandle = -1
		MsgInfo("Falha na leitura do arquivo.","Leitura do arquivo")
		Return
	EndIf
	
	DbSelectArea("SZ4")
	SZ4->(DbSetOrder(2)) // Z4_FILIAL + Z4_CHASSI + Z4_LOTE + Z4_ANOLOTE
	FT_FGoTop()
	While !FT_FEOF()
		cLine := ""
		cLine := FT_FReadLn()
	
		cChassi := SubString(cLine,1,17)
		If SZ4->( !DbSeek( xFilial("SZ4") + cChassi ) )
			FT_FSKIP()
			Loop
		EndIf
		
		If SZ4->Z4_CODRET == "OK"
			FT_FSKIP()
			Loop
		EndIf
		
		cMsgRet := ""
		cMsgRet := SubString(cLine,22,50)
		cCodRet := ""
		cCodRet := Iif( AllTrim(cMsgRet) == "INCLUIDO", "OK", "ER")
		
		RecLock("SZ4", .F.)
		SZ4->Z4_ARQRET 	:= Right(AllTrim(cArq), 30)
		SZ4->Z4_DTARET 	:= dDataBase
		SZ4->Z4_CODRET 	:= cCodRet
		SZ4->Z4_DESCRET := SubString(cMsgRet, 1, 100)
		SZ4->(MsUnLock())

		If cCodRet == "OK"
			nCountOK++
		ElseIf cCodRet == "ER"
			nCountEr++
		EndIf
		FT_FSKIP()
	EndDo
	
	FT_FUSE()
	DbSelectArea("SZ4")
	SZ4->(DbCloseArea())
	
	MsgInfo("Leitura efetuada com sucesso."+Enter+Enter+;
			"Foram processados "+ cValToChar(nCountEr) +" com <font color='red'><b>erro</b></font>."+Enter+;
			"Foram processados "+ cValToChar(nCountOk) +" com <font color='blue'><b>sucesso</b></font>." ,"Processamento de retorno do arquivo")
	
	RestArea(aArea)
Return Nil 
 
 
 /*/{Protheus.doc} CVMSER1L
//TODO Cria legenda para usuario identificar os registros

@author 	Alex Lima
@since 		28/10/2018
@version 	P12
@type 		function
/*/
User Function CVMSER1L()
Local aCor := {}
	
	aAdd(aCor,{"BR_BRANCO", 	"Nenhuma ação tomada"})
	aAdd(aCor,{"BR_AZUL", 		"Arquivos Gerados"})
	aAdd(aCor,{"BR_VERDE", 		"Retorno com sucesso"})
	aAdd(aCor,{"BR_VERMELHO", 	"Retorno com Falha"})
	
	BrwLegenda(cCadastro,OemToAnsi("Registros de processamentos"),aCor)
Return Nil 


/*/{Protheus.doc} CriaSx1
//TODO Cria grupo de perguntas, caso não exista.

@author 	Alex Lima
@since 		28/10/2018
@version 	P12
@type 		function
/*/
Static Function CriaSx1()
Local aAreaAnt 	:= GetArea()
Local aAreaSX1 	:= SX1->(GetArea())
Local nY 		:= 0
Local nJ 		:= 0
Local aReg 		:= {}
	
	aAdd(aReg,{cPerg,"01","Data Inicial  ","mv_ch1","D", 08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aReg,{cPerg,"02","Data Final    ","mv_ch2","D", 08,0,0,"G","(mv_par02>=mv_par01)","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aReg,{cPerg,"03","Marca         ","mv_ch3","C", 03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","VE1_A"})
	//aAdd(aReg,{cPerg,"04","Chassi      ","mv_ch4","C", 17,0,0,"G","","mv_par04","","","","","","","","","","","","","","","V11"})
	//aAdd(aReg,{cPerg,"05","Modelo      ","mv_ch5","C", 03,0,0,"G","","mv_par05","","","","","","","","","","","","","","","VV2"})
	//aAdd(aReg,{cPerg,"06","Ano Fab/Modelo","mv_ch6","C", 09,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","@R 9999-9999"})
	aAdd(aReg,{"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_CNT01","X1_VAR02","X1_DEF02","X1_CNT02","X1_VAR03","X1_DEF03","X1_CNT03","X1_VAR04","X1_DEF04","X1_CNT04","X1_VAR05","X1_DEF05","X1_CNT05","X1_F3","X1_PYME","X1_GRPSXG","X1_HELP","X1_PICTURE"})
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	For ny := 1 To Len(aReg) - 1
		If !DbSeek( PadR( aReg[ny,1], 10) + aReg[ny,2])
			RecLock("SX1", .T.)
			For nJ := 1 To Len(aReg[ny])
				FieldPut( FieldPos( aReg[Len( aReg)][nJ] ), aReg[ny,nJ] )
			Next nJ
			MsUnlock()
		EndIf
	Next ny	
	
	RestArea(aAreaSX1)
	RestArea(aAreaAnt)

Return Nil
