#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} CMVFIS01
Facilitador Cadastro de TES Inteligente
@type Function

@author Joni Lima do Carmo
@since 24/07/2019
@version P12
/*/
User Function CMVFIS01()

    Local oBrowse

    oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SX5")
	oBrowse:SetFilterDefault("X5_TABELA == 'DJ'")
    //oBrowse:AddLegend( "FM_TIPO<>'99'", "YELLOW", "Operação " + SFM->FM_TIPO )
	oBrowse:SetDescription("Facilitador Cadastro Tes Inteligente")
    oBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Menu com as opções do browse
@type function

@return aRotina, array, Array com as rotinas de Menu

@author Joni Lima do Carmo
@since 04/09/2019
@version P12
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'VIEWDEF.CMVFIS01' OPERATION 1   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Manutenção' ACTION 'VIEWDEF.CMVFIS01' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 1
//    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zModel2' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
//    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zModel2' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
//    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zModel2' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRotina


/*/{Protheus.doc} ModelDef
Definições do Modelo de Dados
@type function

@return  	oModel, Objeto  do Tipo MPFORMMODEL, Modelo de Dados

@author Joni Lima do Carmo
@since 04/09/2019
@version P12
/*/
Static Function ModelDef()

	Local oModel   := Nil
	Local oStrSX5  := FWFormStruct(1, 'SX5')
	Local oStrSFM  := FWFormStruct(1, 'SFM')

	Local bCommit	:= {|oModel|xCommit(oModel)}
	Local aUniqLine := {}
   //Setando as propriedades na grid, o inicializador da Filial e Tipo, para não dar mensagem de coluna vazia
   //oStFilho:SetProperty('FM_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
   //oStFilho:SetProperty('FM_TIPO'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'SFM->FM_TIPO' ))

   oStrSX5:SetProperty('*' , MODEL_FIELD_WHEN	, {||.F.}   		)

   oStrSFM:SetProperty('FM_ID'   , MODEL_FIELD_INIT	    , {||""})
   oStrSFM:SetProperty('FM_ID'   , MODEL_FIELD_OBRIGAT	, .F.   )

   oStrSFM:SetProperty('FM_TIPO' , MODEL_FIELD_INIT	, {|oMdlSFM| xValSX5(oMdlSFM,"X5_CHAVE") })
   oStrSFM:SetProperty('FM_TIPO' , MODEL_FIELD_WHEN	, {||.F.}   		)

   oStrSFM:SetProperty('FM_DESCR', MODEL_FIELD_INIT	, {|oMdlSFM| xValSX5(oMdlSFM,"X5_DESCRI")})
   oStrSFM:SetProperty('FM_DESCR', MODEL_FIELD_WHEN	, {||.F.}   		)

   oStrSFM:SetProperty ( 'FM_CLIENTE' , MODEL_FIELD_VALID, { | oMdlSFM,cField,xValue,xOldValue | xValidCli( oMdlSFM,cField,xValue,xOldValue ) } )
   oStrSFM:SetProperty ( 'FM_LOJACLI' , MODEL_FIELD_VALID, { | oMdlSFM,cField,xValue,xOldValue | xValidCli( oMdlSFM,cField,xValue,xOldValue ) } )

   oStrSFM:SetProperty ( 'FM_FORNECE' , MODEL_FIELD_VALID, { | oMdlSFM,cField,xValue,xOldValue | xValidFor( oMdlSFM,cField,xValue,xOldValue ) } )
   oStrSFM:SetProperty ( 'FM_LOJAFOR' , MODEL_FIELD_VALID, { | oMdlSFM,cField,xValue,xOldValue | xValidFor( oMdlSFM,cField,xValue,xOldValue ) } )

   oStrSFM:SetProperty ( 'FM_POSIPI' , MODEL_FIELD_VALID, { | oMdlSFM,cField,xValue,xOldValue | xValidNCM( oMdlSFM,cField,xValue,xOldValue ) } )

   //Criando o FormModel, adicionando o Cabeçalho e Grid
   oModel := MPFormModel():New("XCMVFIS01",/*bPreValidacao*/,/*bPosValid*/,bCommit,/*bCancel*/)
   oModel:AddFields("SX5MASTER",/*cOwner*/,oStrSX5,/*bPreValid*/, /*bPosValid*/, /*bCarga*/)
   oModel:AddGrid('SFMDETAIL','SX5MASTER',oStrSFM,/*bLinePreValid*/,{|oMdlSFM|xPoslinVal(oMdlSFM)}/*bLinePosValid*/,/*bPreValid*/,/*bPosValid*/, /*bCarga*/)

   oModel:SetRelation("SFMDETAIL",{{"FM_FILIAL","xFilial('SFM')"},{"FM_TIPO", "X5_CHAVE"}},SFM->(IndexKey(1)))

   oModel:SetPrimaryKey({"X5_FILIAL","X5_TABELA","X5_CHAVE"})

   AADD(aUniqLine ,'FM_TIPO'   )
   AADD(aUniqLine ,'FM_EST'    )
   AADD(aUniqLine ,'FM_GRTRIB' )
   AADD(aUniqLine ,'FM_TIPOMOV')
   AADD(aUniqLine ,'FM_TIPOCLI')
   AADD(aUniqLine ,'FM_CLIENTE')
   AADD(aUniqLine ,'FM_LOJACLI')
   AADD(aUniqLine ,'FM_FORNECE')
   AADD(aUniqLine ,'FM_LOJAFOR')
   AADD(aUniqLine ,'FM_PRODUTO')
   AADD(aUniqLine ,'FM_GRPROD' )
   AADD(aUniqLine ,'FM_POSIPI' )
   AADD(aUniqLine ,'FM_REFGRD' )
   AADD(aUniqLine ,'FM_GRPTI'  )
   AADD(aUniqLine ,'FM_GRPCST' )
   AADD(aUniqLine ,'FM_TPCTO'  )
   AADD(aUniqLine ,'FM_TE'     )
   AADD(aUniqLine ,'FM_TS'     )
   AADD(aUniqLine ,'FM_XFOR1'  )
   AADD(aUniqLine ,'FM_XFOR2'  )
   AADD(aUniqLine ,'FM_XFOR3'  )
   AADD(aUniqLine ,'FM_XORIGEM')

   oModel:GetModel( 'SFMDETAIL' ):SetUniqueLine( aUniqLine )

   oModel:GetModel( 'SX5MASTER' ):SetOnlyQuery ( .T. )
   oModel:GetModel( 'SFMDETAIL' ):SetOnlyQuery ( .T. )
   oModel:GetModel( 'SFMDETAIL' ):SetOptional ( .T. )

Return oModel

/*/{Protheus.doc} ViewDef
Definições da View para tela
@type function

@return  	oView, Objeto  do Tipo FWFORMVIEW, View da tela

@author Joni Lima do Carmo
@since 04/09/2019
@version P12
/*/
Static Function ViewDef()

	Local oModel     := FWLoadModel("CMVFIS01")
	Local oStrSX5  := FWFormStruct(2, 'SX5',{|cCampo|(AllTrim(cCampo) $ "X5_CHAVE|X5_DESCRI")})
	Local oStrSFM  := FWFormStruct(2, 'SFM',{|cCampo|!(AllTrim(cCampo) $ "FM_TIPO|FM_DESCR")})
	Local oView      := Nil

	oStrSX5:SetProperty('X5_CHAVE' , MVC_VIEW_TITULO	, "Tp. Operação" )

	oStrSFM:SetProperty('FM_ID' 	 , MVC_VIEW_ORDEM	, "01" )
	oStrSFM:SetProperty('FM_EST' 	 , MVC_VIEW_ORDEM	, "02" )
	oStrSFM:SetProperty('FM_GRTRIB'  , MVC_VIEW_ORDEM	, "03" )
	oStrSFM:SetProperty('FM_GRPROD'  , MVC_VIEW_ORDEM	, "04" )
	oStrSFM:SetProperty('FM_POSIPI'  , MVC_VIEW_ORDEM	, "05" )
	oStrSFM:SetProperty('FM_XORIGEM' , MVC_VIEW_ORDEM	, "06" )
	oStrSFM:SetProperty('FM_TE' 	 , MVC_VIEW_ORDEM	, "07" )
	oStrSFM:SetProperty('FM_TS' 	 , MVC_VIEW_ORDEM	, "08" )
	oStrSFM:SetProperty('FM_GRPCST'  , MVC_VIEW_ORDEM	, "09" )
	oStrSFM:SetProperty('FM_TIPOCLI' , MVC_VIEW_ORDEM	, "10" )
	oStrSFM:SetProperty('FM_CLIENTE' , MVC_VIEW_ORDEM	, "11" )
	oStrSFM:SetProperty('FM_LOJACLI' , MVC_VIEW_ORDEM	, "12" )
	oStrSFM:SetProperty('FM_FORNECE' , MVC_VIEW_ORDEM	, "13" )
	oStrSFM:SetProperty('FM_LOJAFOR' , MVC_VIEW_ORDEM	, "14" )

    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_SX5" , oStrSX5 , "SX5MASTER")
    oView:AddGrid('VIEW_SFM'  , oStrSFM , "SFMDETAIL")

    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CIMA' ,20)
    oView:CreateHorizontalBox('BAIXO',80)

    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_SX5','CIMA')
    oView:SetOwnerView('VIEW_SFM','BAIXO')

    //Habilitando título
    oView:EnableTitleView('VIEW_SX5','Cabeçalho - TES Inteligente')
    oView:EnableTitleView('VIEW_SFM','Itens - TES Inteligente')

Return oView

/*/{Protheus.doc} xValSX5
Pega Valor do cabeçalho para incluir na Grid
@type function

@param 		oMdlSFM  , objeto FWFORMGRIDMODEL  , Modelo de Dados da GRID tabela SFM
			cField   , String                  , Campo

@return  	cRet, Caractere, Conteudo solicitado do cabeçalho

@author Joni Lima do Carmo
@since 04/09/2019
@version P12
/*/
Static Function xValSX5(oMdlSFM,cField)

   Local aArea 		:= GetArea()
   Local aSaveLines	:= FWSaveRows()
   Local oModel		:= oMdlSFM:GetModel()
   Local cRet		:= oModel:GetValue("SX5MASTER",cField)

   FWRestRows( aSaveLines )
   RestArea(aArea)

Return cRet

/*/{Protheus.doc} xValidCli
Realiza Validação de Cliente
@type function

@param 		oMdlSFM  , objeto FWFORMGRIDMODEL  , Modelo de Dados da GRID tabela SFM
			cField   , String                  , Campo recebido na validação
			xValue   , Dinamico				   ,  Valor do campo
			xOldValue, Dinamico				   ,  Valor Anterior do Campo

@return  	lRet, Lógico, (.T. = Existe, .F. Não Existe)

@author Joni Lima do Carmo
@since 04/09/2019
@version P12
/*/
Static Function xValidCli(oMdlSFM,cField,xValue,xOldValue)

	Local aArea 	:= GetArea()
	Local aAreaSA1	:= SA1->(GetArea())

	Local lRet 		:= .T.
	Local cCliente	:= IIF(cField =="FM_CLIENTE", xValue , oMdlSFM:GetValue("FM_CLIENTE") )
	Local cLoja		:= IIF(cField =="FM_LOJACLI", xValue , oMdlSFM:GetValue("FM_LOJACLI") )

	If !Empty(cCliente) .and. !Empty(cLoja)
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
		If !SA1->(dbSeek(xFilial("SA1") + cCliente + cLoja ))

			oMdlSFM:GetModel():SetErrorMessage(oMdlSFM:GetId(),cField,oMdlSFM:GetModel():GetId(),cField,cField,;
											   "Cliente Não Encontrado",;
											   "O Cliente com a Loja ( " + cCliente + " - " + cLoja + " ) Não foi Encontrado, Favor Selecione um Cliente com uma Loja valida" )
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaSA1)
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} xValidFor
Realiza Validação de Cliente
@type function

@param 		oMdlSFM  , objeto FWFORMGRIDMODEL  , Modelo de Dados da GRID tabela SFM
			cField   , String                  , Campo recebido na validação
			xValue   , Dinamico				   ,  Valor do campo
			xOldValue, Dinamico				   ,  Valor Anterior do Campo

@return  	lRet, Lógico, (.T. = Existe, .F. Não Existe)

@author Joni Lima do Carmo
@since 04/09/2019
@version P12
/*/
Static Function xValidFor(oMdlSFM,cField,xValue,xOldValue)

	Local aArea 	:= GetArea()
	Local aAreaSA2	:= SA2->(GetArea())

	Local lRet 		:= .T.
	Local cFornece	:= IIF(cField =="FM_FORNECE", xValue , oMdlSFM:GetValue("FM_FORNECE") )
	Local cLoja		:= IIF(cField =="FM_LOJAFOR", xValue , oMdlSFM:GetValue("FM_LOJAFOR") )

	If !Empty(cFornece) .and. !Empty(cLoja)
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1))//A2_FILIAL+A2_COD+A2_LOJA
		If !SA2->(dbSeek(xFilial("SA2") + cFornece + cLoja ))

			oMdlSFM:GetModel():SetErrorMessage(oMdlSFM:GetId(),cField,oMdlSFM:GetModel():GetId(),cField,cField,;
											   "Fornecedor Não Encontrado",;
											   "O Fornecedor com a Loja ( " + cFornece + " - " + cLoja + " ) Não foi Encontrado, Favor Selecione um Fornecedor com uma Loja valida" )
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaSA2)
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} xValidNCM
Realiza Validação do NCM
@type function

@param 		oMdlSFM  , objeto FWFORMGRIDMODEL  , Modelo de Dados da GRID tabela SFM
			cField   , String                  , Campo recebido na validação
			xValue   , Dinamico				   ,  Valor do campo
			xOldValue, Dinamico				   ,  Valor Anterior do Campo

@return  	lRet, Lógico, (.T. = Existe, .F. Não Existe)

@author Joni Lima do Carmo
@since 04/09/2019
@version P12
/*/
Static Function xValidNCM(oMdlSFM,cField,xValue,xOldValue)

	Local aArea 	:= GetArea()
	Local aAreaSYD	:= SYD->(GetArea())

	Local lRet 		:= .T.
	Local cNCM		:= xValue

	If !Empty(cNCM)
		dbSelectArea("SYD")
		SYD->(dbSetOrder(1))//YD_FILIAL+YD_TEC+YD_EX_NCM+YD_EX_NBM+YD_DESTAQU
		If !SYD->(dbSeek(xFilial("SYD") + cNCM ))

			oMdlSFM:GetModel():SetErrorMessage(oMdlSFM:GetId(),cField,oMdlSFM:GetModel():GetId(),cField,cField,;
											   "NCM Não Encontrado",;
											   "O NCM ( " + cNCM + " ) Não foi Encontrado, Favor Selecione um NCM valido" )
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaSYD)
	RestArea(aArea)

Return lRet

Static Function xPoslinVal(oMdlSFM)

	Local lRet := .T.

	If !Empty(oMdlSFM:GetValue("FM_CLIENTE")) .or. !Empty(oMdlSFM:GetValue("FM_LOJACLI"))
		If Empty(oMdlSFM:GetValue("FM_CLIENTE")) .or. Empty(oMdlSFM:GetValue("FM_LOJACLI"))
			Help( ,, 'Help',, 'Caso Informe um Cliente é obrigatorio o preenchimento do Cliente e Loja  ', 1, 0 )
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If !Empty(oMdlSFM:GetValue("FM_FORNECE")) .or. !Empty(oMdlSFM:GetValue("FM_LOJAFOR"))
			If Empty(oMdlSFM:GetValue("FM_FORNECE")) .or. Empty(oMdlSFM:GetValue("FM_LOJAFOR"))
				Help( ,, 'Help',, 'Caso Informe um Fornecedor é obrigatorio o preenchimento do Fornecedor e Loja  ', 1, 0 )
				lRet := .F.
			EndIf
		EndIf
	EndIf

return lRet

Static Function xCommit(oModel)

	Local aArea		:= GetArea()
	Local aAreaSFM	:= SFM->(GetArea())

	Local lRet 		:= .T.
	Local nI		:= 1
	Local oMdlSFM	:= oModel:GetModel("SFMDETAIL")
	Local lInsert	:= .F.
	Local lDelete	:= .F.
	Local cId 		:= ""

	dbSelectArea("SFM")
	SFM->(dbSetOrder(3))//FM_FILIAL+FM_ID

	If oModel:VldData()

        //Percorre as linhas da grid
		For nI := 1 To (oMdlSFM:Length())

			lInsert	:= .F.
			lDelete := .F.

			oMdlSFM:GoLine(nI)
			cId := oMdlSFM:GetValue("FM_ID")

			If !oMdlSFM:IsDeleted()//Linha Não deletada pode incluir ou alterar resgistro

				If Empty(cId)
					lInsert	:= .T. //Se o Id estiver em branco Inclui o Registros
				Else
					lInsert	:= .F. //Se o Id estiver preenchido altera o Registro
					SFM->(dbSeek(xFilial("SFM") + cId))
				EndIf

			Else //Deletado
				If !Empty(cId)
					SFM->(dbSeek(xFilial("SFM") + cId))
					lDelete	:= .T.
				EndIf
			EndIf

			xExecMT089(oMdlSFM,lInsert,lDelete,cId)

        Next nI

		FwFormCommit(oModel)
		oModel:DeActivate()
	Else
		JurShowErro( oModel:GetModel():GetErrormessage() )
		lRet := .F.
	EndIf

	RestArea(aAreaSFM)
	RestArea(aArea)

Return lRet

Static Function xExecMT089(oMdlTelaSFM,lInsert,lDelete,cId)

	Local aArea		:= GetArea()
	Local aAreaSFM	:= SFM->(GetArea())
	Local nz		:= 0

	Local lRet 		:= .T.
	Local oModel 	:= FWLoadModel( 'MATA089' )
	Local oMdlSFM   := oModel:GetModel("SFMMASTER")

	Local oStrSFM	:= oMdlTelaSFM:GetStruct()
	Local aField 	:= oStrSFM:GetFields()

	Private lMsHelpAuto := .t.
	Private lMsErroAuto := .f.

	If lInsert
		oModel:SetOperation( MODEL_OPERATION_INSERT )
	ElseIf !lInsert .and. !lDelete
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
	Else
		oModel:SetOperation( MODEL_OPERATION_DELETE )
	EndIf

	If oModel:Activate()

		/*If !Empty(cId)
			oMdlSFM:SetValue("FM_ID",cId)
		EndIf*/

		If !lDelete
			For nz:= 1 to Len(aField)
				If !(aField[nz,14])//Campo Virtual
					cConteudo := oMdlTelaSFM:GetValue(aField[nz,3])
					If !Empty(cConteudo)
						If lInsert
							If !(aField[nz,3] $ "FM_ID")
								oMdlSFM:SetValue(aField[nz,3],cConteudo)
							EndIf
						Else
							If !(aField[nz,3] $ "FM_FILIAL|FM_ID|FM_TIPO")
								oMdlSFM:SetValue(aField[nz,3],cConteudo)
							EndIf
						EndIf
					EndIf
				EndIf
			Next nz

			If lInsert
				oMdlSFM:SetValue("FM_ID",GetSxeNum("SFM","FM_ID"))
			EndIf
		EndIf

		If ( lRet := oModel:VldData() )
			lRet := oModel:CommitData()
			If lInsert
				If lRet
					ConfirmSX8()
				else
					RollBackSx8()
				EndIf
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

			/*If nItErro > 0
				AutoGrLog( "Erro no Item:              " + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' )
			EndIf*/

			If (!IsBlind()) // COM INTERFACE GRÁFICA
				MostraErro() //TELA
			EndIf

		EndIf

		// Desativamos o Model
		oModel:DeActivate()

	EndIf

	RestArea(aAreaSFM)
	RestArea(aArea)

Return
