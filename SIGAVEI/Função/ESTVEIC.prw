#Include 'Protheus.Ch'
#Include 'FWMVCDef.Ch'

/*/{Protheus.doc} ESTVEIC
Função para estornar os Movimentos de Estoque e Cadastro de Veiculos.
@author FSW - DWC Consult
@since 02/04/2019
@version 1.0
@type function
/*/
User Function ESTVEIC()
	Local lRetOk	:= .F.
	Local aAreaVV1	:= VV1->(GetArea())
	Local aAreaVB0  := VB0->(GetArea())
	Local cChaInt   := ""

	If Subs( SD3->D3_OP , 7 , 5 ) == "01001" .And. "1" == GetAdvFVal("SC2","C2_XTIPO",xFilial("SC2")+SD3->D3_OP,1,"")
	
		DbSelectArea("VV1")
		VV1->(DbSetOrder(2))
	
		If Empty(SD3->D3_XVIN)
			MsgInfo("ERRO: O campo D3_XVIN não está preenchido na OP.","CAOA")
			Return( .F. )
		EndIf
	
		If !VV1->(DbSeek(xFilial("VV1") + SD3->D3_XVIN))
			FMX_HELP("DELVEIC","Chassi não encontrado")
			Return( .F. )
		EndIf
		
		cChaInt := VV1->VV1_CHAINT
		
		//So pode estornar o veiculo caso a situacao do veiculo seja = a 0 
		If VV1->VV1_SITVEI == '0'
	
			Processa( { |lEnd| lRetOk := AxEstVei(VV1->VV1_CHASSI) }, "Aguarde...", "Estornando veículo...",.T.)
	
			If lRetOk
				Processa( { |lEnd| lRetOk := AxEstPCP() }, "Aguarde...", "Estornando movimento de estoque do veículo...",.T.)
			EndIf
			
			//Caso Estornado a Produção, retira o Bloqueio do Veiculo
			If lRetOk
				DbSelectArea("VB0")
				VB0->(DbSetOrder(1))
				If VB0->(DbSeek(xFilial("VB0") + cChaInt))
					RecLock("VB0",.F.)
					VB0->(DbDelete())
					MsUnlock()
				Endif
				RestArea(aAreaVB0)
			Endif
		
		EndIf
		
		RestArea(aAreaVV1)
	
	EndIf
		
Return( lRetOk )

/*/{Protheus.doc} AxEstPCP
Função Auxiliar, responsavel por excluir os movimentos de estoque de veiculos.
@author FSW - DWC Consult
@since 02/04/2019
@version 1.0
@type function
/*/
Static Function AxEstPCP()
	Local xAutoCab		:= {} // Campos Cabecalho
	Local xAutoItens	:= {} // Campos Itens
	Local xAutoIt		:= {}

	Local cBkpFunName   := ""
	Local nBkpModulo    := 0

	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.

	cSQL := "SELECT R_E_C_N_O_ "
	cSQL += "FROM " + RetSQLName("SD3") + " D3 "
	cSQL += "WHERE D3.D3_FILIAL = '" + xFilial("SD3") + "' "
	cSQL += "AND D3.D3_OP = '" + SD3->D3_OP + "' "
	cSQL += "AND D3.D3_CF LIKE 'PR%' "
	//cSQL += "AND D3.D3_ESTORNO = ' ' " 
	cSQL += "AND D3.D_E_L_E_T_ = ' ' "
	nRecSD3 := FM_SQL(cSQL)

	If nRecSD3 == 0
		MsgInfo("Movimentacao nao encontrada.","CAOA")
		Return( .F. )
	EndIf

	SD3->(DbGoTo(nRecSD3))
	If ! MsgYesNo("Confirma Cancelamento da Entrada por Produção","CAOA")
		Return( .F. )
	EndIf

	aAdd(xAutoCab, { 'VVF_NUMOP' , SD3->D3_OP , NIL } )

	lMsHelpAuto := .t.
	lMsErroAuto := .f.

	cBkpFunName := FunName()
	nBkpModulo  := nModulo
	SetFunName('VEIXA001')
	nModulo := 11
	MsExecAuto(	{|a,b,c,d,e,f,g,h,i,j| VEIXX000(a,b,c,d,e,f,g,h,i)},xAutoCab,{},{},5,"0",,.F.,,)
	SetFunName(cBkpFunName)
	nModulo := nBkpModulo

	If lMsErroAuto
		If (!IsBlind()) // COM INTERFACE GRÁFICA
			MostraErro() //TELA
		EndIf
	Else
		MsgInfo("Movimento cancelado com sucesso.","CAOA")
	EndIf

Return( lMsErroAuto )

/*/{Protheus.doc} AxEstVei
Função Auxiliar, responsavel por excluir os veiculos produzidos - SIGAVEI.
@author FSW - DWC Consult
@since 02/04/2019
@version 1.0
@param cChassi, characters, descricao
@type function
/*/
Static Function AxEstVei(cChassi)
	Local aErro		:= {}
	Local lRet		:= .T.
	Local oModel	:= Nil

	If Empty(cChassi)
		Return( .F. )
	EndIf

	oModel := FWLoadModel("VEIA070")
	oModel:SetOperation(MODEL_OPERATION_DELETE)
	If !oModel:Activate()
		Return( .F. )
	EndIf

	If !oModel:VldData()
	Else
		If !oModel:CommitData()
			FMX_HELP("DELVEIC","Erro ao excluir veiculo.")

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

			If (!IsBlind()) // COM INTERFACE GRÁFICA
				MostraErro() //TELA
			EndIf
			lRet := .F. 
		EndIf
	EndIf

Return( lRet )
//-----------------------------------------------------------------------------
