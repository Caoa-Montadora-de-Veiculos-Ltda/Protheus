#Include 'Protheus.Ch'
#Include 'FWMVCDef.Ch'

/*/{Protheus.doc} INCVEIC
Função Responsavel pela inclusão dos Movimentos e Cadastro de Veiculos - SIGAVEI.
@author FSW - DWC Consult
@since 02/04/2019
@version 1.0
@type function
/*/
User Function INCVEIC()

	Local lRetOk	:= .F.

	Private cChaint	:= ""  

	Processa( { |lEnd| lRetOk := CAOIntVei() }, "Aguarde...", "Incluindo veículo...",.T.)

	If lRetOk
		Processa( { |lEnd| lRetOk := CAOIntEst() }, "Aguarde...", "Gerando movimento de estoque no módulo de veículos...",.T.)
	EndIf

Return

/*/{Protheus.doc} CAOIntVei
Função Auxiliar, responsavel por incluir o Veiculo no Modulo SIGAVEI, a partir do PCP.
@author FSW - DWC Consult
@since 02/04/2019
@version 1.0
@type function
/*/
Static Function CAOIntVei()
	Local aCposCab	:= {}
	Local lRet		:= .F.
	Local aArea		:= GetArea()
	Local aAreaD3	:= SD3->( GetArea() )
	Local aAreaC2	:= SC2->( GetArea() )

	If Subs( SD3->D3_OP , 7 , 5 ) == "01001" .And. "1" == GetAdvFVal("SC2","C2_XTIPO",xFilial("SC2")+SD3->D3_OP,1,"")

		If SD3->D3_OP <> SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
			SC2->( dbSetOrder(1) ) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
			//SC2->( dbSeek( xFilial("SC2") + SD3->D3_OP ) )
			If !SC2->(dbSeek(xFilial("SC2")+SD3->D3_OP))
				//MsgInfo("ERRO: Verifique se a OP está cadastrada na tabela SC2 - Ordem de Produção.","CAOA")
				Aviso("ERRO: Verifique se a OP está cadastrada na tabela SC2 - Ordem de Produção.","CAOA")
				Return( .F. )
			EndIf
		EndIf

		If SD3->D3_COD <> SC2->C2_PRODUTO
			SD3->( dbSetOrder(2) ) // D3_FILIAL+D3_DOC+D3_COD
			SD3->( dbSeek( xFilial("SD3") + SD3->D3_DOC + SC2->C2_PRODUTO ) )
		EndIf

		SB1->(DbSetOrder(1)) 
		SB1->(DbSeek(xFilial("SB1") + SD3->D3_COD))
	
		VV2->(DbSetOrder(7)) //VV2_FILIAL+VV2_PRODUT
		If !VV2->(dbSeek(xFilial("VV2")+SD3->D3_COD))
			Aviso("ERRO: Verifique se o produto da OP consta no Cadastro de Modelos de Veículo.","CAOA")
			Return( .F. )
		EndIf
	
		If Empty(SD3->D3_XVIN)
			Aviso("ERRO: O campo D3_XVIN não está preenchido na OP.","CAOA")
			Return( .F. )
		EndIf
/*	
		SC2->(DbSetOrder(1))
		If !SC2->(dbSeek(xFilial("SC2")+SD3->D3_OP))
			//MsgInfo("ERRO: Verifique se a OP está cadastrada na tabela SC2 - Ordem de Produção.","CAOA")
			Aviso("ERRO: Verifique se a OP está cadastrada na tabela SC2 - Ordem de Produção.","CAOA")
			Return( .F. )
		EndIf
*/	
		ZZ1->(DbSetOrder(1)) 
		ZZ1->(DbSeek(xFilial("ZZ1") + SD3->D3_XVIN))
	
		aAdd( aCposCab , { 'VV1_CODMAR' , VV2->VV2_CODMAR    } )
		aAdd( aCposCab , { 'VV1_CHASSI' , SD3->D3_XVIN    	 } )
		aAdd( aCposCab , { 'VV1_MODVEI' , VV2->VV2_MODVEI    } )
		aAdd( aCposCab , { 'VV1_SEGMOD' , VV2->VV2_SEGMOD    } )
		aAdd( aCposCab , { 'VV1_FABMOD' , SC2->C2_XFABMOD    } )
		aAdd( aCposCab , { 'VV1_CORVEI' , VV2->VV2_COREXT    } )
		//aAdd( aCposCab , { 'VV1_COMVEI' , SC2->C2_XCOMBU     } )
		aAdd( aCposCab , { 'VV1_COMVEI' , VV2->VV2_COMVEI    } )
		aAdd( aCposCab , { 'VV1_ESTVEI' , '0'                } )
		aAdd( aCposCab , { 'VV1_LOCPAD' , SB1->B1_LOCPAD     } )
		aAdd( aCposCab , { 'VV1_CODORI' , '0'                } )
		aAdd( aCposCab , { 'VV1_PROVEI' , SB1->B1_ORIGEM     } )
		aAdd( aCposCab , { 'VV1_ESTVEI' , '0'                } )
		aAdd( aCposCab , { 'VV1_VEIACO' , '0'                } )
		aAdd( aCposCab , { 'VV1_INDCAL' , '0'                } )
		aAdd( aCposCab , { 'VV1_NUMMOT' , ALLTRIM(ZZ1->ZZ1_MOTOR)          })
		aAdd( aCposCab , { 'VV1_SERMOT' , ALLTRIM(ZZ1->ZZ1_SERMOT)         })
	
		If !AxIncVei(aCposCab)
			lRet := .F.
		Else
			lRet := .T.
		EndIf

	EndIf
	
Return( lRet )

/*/{Protheus.doc} CAOIntEst
Funcao responsavel por atualiza estoque no módulo SIGAVEI (VVF e VVG) 
@author FSW - DWC Consult
@since 10/02/2019
@version 1.0
@type function
/*/
Static Function CAOIntEst()
	Local cEstVei    := ''
	Local cCODORI	 := ''
	Local cChassi	 := ''
	Local cValidaSB2 := SuperGetMV("MV_XVLDSB2",.F.,"0")  //1=Valida B2_VATU1,2=Alerta B2_VATU1
	Local xAutoCab   := {} // Campos Cabecalho
	Local xAutoItens := {} // Campos Itens
	Local xAutoIt    := {}

	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F. 

	cSQL := "SELECT R_E_C_N_O_ "
	cSQL += "FROM " + RetSQLName("SD3") + " D3 "
	cSQL += "WHERE D3.D3_FILIAL = '" + xFilial("SD3") + "' "
	cSQL += "AND D3.D3_OP = '" + SD3->D3_OP + "' "
	cSQL += "AND D3.D3_CF LIKE 'PR%' "
	cSQL += "AND D3.D3_ESTORNO = ' ' " 
	cSQL += "AND D3.D_E_L_E_T_ = ' ' "
	nRecSD3 := FM_SQL(cSQL)

	If nRecSD3 == 0
		MsgInfo("Movimentacao nao encontrada.","CAOA")
		Return
	EndIf

	SD3->(DbGoTo(nRecSD3))

	SB1->(DbSetOrder(1)) 
	SB1->(DbSeek(xFilial("SB1") + SD3->D3_COD))

	// -- Posiciona no cadastro de veiculo criado acima
	VV1->(DbSetOrder(1)) // -- VV1_FILIAL+VV1_CHAINT
	If ! VV1->(dbSeek( xFilial("VV1") + cChaint ))
		Return( .F. )
	EndIf

	cChassi := VV1->VV1_CHASSI
	cEstVei := VV1->VV1_ESTVEI
	cCODORI := VV1->VV1_CODORI

	aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt)
	SA2->(DbSetOrder(3))
	If SA2->(DbSeek(xFilial("SA2")+aSM0[SM0_CGC])) .or. SA2->(DbSeek(xFilial("SA2")+left(aSM0[SM0_CGC],8)))
		cCodFor := SA2->A2_COD
		cLojFor := SA2->A2_LOJA
	EndIf

	SD3->(DbGoTo(nRecSD3))
	cD3_DOC := SD3->D3_DOC
	cD3_OP  := SD3->D3_OP

	nCusFut := 1 //SD3->D3_CUSTO1

	If nCusFut<=0
		If cValidaSB2=="1" .or. cValidaSB2=="2"  //1=Valida B2_VATU1,2=Alerta B2_VATU1
			While .T.
				nCusFut := SD3->(fGetCusto(D3_DOC,D3_OP,D3_COD,nCusFut))  //Solicita o Custo Médio
				If nCusFut<=0
					If MsgYesNo("Custo médio não informado. A movimentação do veículo não será incluída. Deseja informar o custo médio ??","CAOA")
						Loop
					EndIf
				EndIf
				Exit
			End
		EndIf
	EndIf

	If nCusFut<=0
		MsgAlert("Custo médio não informado. A movimentação do veículo não será incluída.")
		Return .F.
	EndIf

	cFORPAG := Alltrim(SUPERGETMV("MV_XFORPAG", .T., "001"))
	cCODTES := Alltrim(SUPERGETMV("MV_XCODTES", .T., "100"))

	aAdd(xAutoCab,{"VVF_FORPRO"  ,"0"   		 ,Nil})
	aAdd(xAutoCab,{"VVF_CLIFOR"  ,"F"   		 ,Nil})
	aAdd(xAutoCab,{"VVF_CODFOR"  ,cCodFor		 ,Nil})
	aAdd(xAutoCab,{"VVF_LOJA "   ,cLojFor		 ,Nil})
	aAdd(xAutoCab,{"VVF_DATEMI"  ,dDataBase		 ,Nil})
	aAdd(xAutoCab,{"VVF_NUMOP"   ,cD3_OP		 ,Nil})
	aAdd(xAutoCab,{"VVF_DOCSD3"  ,cD3_DOC		 ,Nil})
	aAdd(xAutoCab,{"VVF_FORPAG"  ,cFORPAG		 ,Nil})
	aAdd(xAutoCab,{"VVF_NUMFI"   ,SD3->D3_DOC	 ,Nil})
	aAdd(xAutoCab,{"VVF_SERIE"   ,SD3->D3_CF	 ,Nil})

	xAutoIt := {}
	xAutoItens:= {} // Campos Itens
	aAdd(xAutoIt,{"VVG_CHASSI"  ,VV1->VV1_CHASSI ,Nil})
	aAdd(xAutoIt,{"VVG_CHAINT"  ,VV1->VV1_CHAINT ,Nil})
	aAdd(xAutoIt,{"VVG_ESTVEI"  ,cEstVei		 ,Nil})
	aAdd(xAutoIt,{"VVG_CODORI"  ,cCODORI		 ,Nil})
	aAdd(xAutoIt,{"VVG_CODTES"  ,cCODTES		 ,Nil})
	aAdd(xAutoIt,{"VVG_SITTRI"  ,'0'			 ,Nil})
	aAdd(xAutoIt,{"VVG_VALUNI"  ,nCusFut		 ,Nil})
	aAdd(xAutoItens,aClone(xAutoIt))

	FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT)

	lMsHelpAuto := .T.
	lMsErroAuto := .F.

	cBkpFunName := FunName()
	nBkpModulo  := nModulo
	SetFunName('VEIXA001')
	nModulo := 11

	MsExecAuto(	{|a,b,c,d,e,f,g,h,i| VEIXX000(a,b,c,d,e,f,g,h,i) },xAutoCab,xAutoItens,{},3,"0",,.F.,,"4")

	SetFunName(cBkpFunName)
	nModulo := nBkpModulo
	If lMsErroAuto
		If FunName() <> "CMVPCP05"
			If (!IsBlind()) // COM INTERFACE GRÁFICA
				MostraErro() //TELA
			EndIf
		EndIf
	Else

		MsgInfo("Movimento criado com sucesso","CAOA")
		RecLock("VB0",.T.)
		VB0->VB0_FILIAL := xFilial("VB0")
		VB0->VB0_CHAINT := VV1->VV1_CHAINT
		VB0->VB0_DATBLO := dDataBase
		VB0->VB0_HORBLO := VAL(LEFT(TIME(),2)+SUBSTR(TIME(),4,2))
		VB0->VB0_USUBLO := Alltrim(__CUSERID)
		VB0->VB0_MOTBLO := "PRODUCAO"
		VB0->VB0_DATVAL := CTOD("01/12/2050")
		VB0->VB0_HORVAL := 2359
		MsUnlock()

	EndIf

Return( lMsErroAuto )

/*/{Protheus.doc} CAOIntEst
Funcao responsavel por cadastrar o veiculo 
@author FSW - DWC Consult
@since 10/02/2019
@version 1.0
@type function
/*/
Static Function AxIncVei(aCpoCAB)
	Local cModelVV1 := 'MODEL_VV1'
	Local nI        := 0
	Local nPos      := 0
	Local lRet      := .T.
	Local aAux	    := {}
	Local aErro		:= {}
	Local oModel	:= Nil
	Local oAux		:= Nil
	Local oStruct	:= Nil

	oModel := FWLoadModel( 'VEIA070' )
	oModel:SetOperation( MODEL_OPERATION_INSERT )
	lRet := oModel:Activate()

	If lRet
		oAux    := oModel:GetModel( cModelVV1 )
		oStruct := oAux:GetStruct()
		aAux	:= oStruct:GetFields()
		For nI := 1 To Len( aCpoCAB )
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoCAB[nI][1] ) } ) ) > 0
				If !oModel:SetValue( cModelVV1, aCpoCAB[nI][1], aCpoCAB[nI][2] )
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf

	If lRet
		If ( lRet := oModel:VldData() )
			lRet := oModel:CommitData()
		EndIf
	EndIf

	If !lRet
		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		aErro   := oModel:GetErrorMessage()

		// A estrutura do vetor com erro é:
		//  [1] Id do formulário de origem
		//  [2] Id do campo de origem
		//  [3] Id do formulário de erro
		//  [4] Id do campo de erro
		//  [5] Id do erro
		//  [6] mensagem do erro
		//  [7] mensagem da solução
		//  [8] Valor atribuido
		//  [9] Valor anterior

		AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
		AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
		AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
		AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
		AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
		AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
		AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
		AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
		AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
		If FunName() <> "CMVPCP05"
			If (!IsBlind()) // COM INTERFACE GRÁFICA
				MostraErro() //TELA
			EndIf
		EndIf
	Else
		cChaint := oModel:GetValue(cModelVV1,"VV1_CHAINT")
	EndIf

	// Desativamos o Model
	oModel:DeActivate()

Return( lRet )

/*/{Protheus.doc} fGetCusto
Função Auxiliar, para pedir as informações de Custo Médio.
@author FSW - DWC Consult
@since 02/04/2019
@version 1.0
@param cDoc, characters, descricao
@param cOp, characters, descricao
@param cCod, characters, descricao
@param nCusto1, numeric, descricao
@type function
/*/
Static Function fGetCusto(cDoc,cOp,cCod,nCusto1)
	Local aPergs:= {}
	Local aRet	:= {}
	Local nRet	:= nCusto1
	Local cMV_PAR01 := MV_PAR01

	AAdd(aPergs,{1,"Informe o Custo Médio: ",nRet,"@E 999,999,999.99999",'.T.',,'.T.',80,.F.})   

	If ParamBox(aPergs ,"Doc: " + AllTrim(cDoc) + " OP: " + AllTrim(cOp) + " Prod: " + AllTrim(cCod),@aRet)      
		nRet := aRet[01]      
	EndIf

	MV_PAR01 := cMV_PAR01
Return(nRet)
