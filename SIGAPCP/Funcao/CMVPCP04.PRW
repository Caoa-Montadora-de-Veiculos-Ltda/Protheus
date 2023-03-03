#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*
=====================================================================================
Programa.:              CMVPCP04
Autor....:              Atilio Amarilla
Data.....:              06/12/2018
Descricao / Objetivo:   Cadastro de Amarração Produto x Linha / Sublinha
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP PCP006
Obs......:              
=====================================================================================
*/

User Function CMVPCP04()
	
	Local oBrowse

	// Abertura de tabelas
	dbSelectArea("ZZA")
	dbSelectArea("ZZB")
	dbSelectArea("ZZC")


	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()
	
	// Definição da tabela do Browse
	oBrowse:SetAlias('ZZB')
	
	// Titulo da Browse
	oBrowse:SetDescription("Amarração Produto x Linha / Sublinha")
	
	// Opcionalmente pode ser desligado a exibição dos detalhes
	//oBrowse:DisableDetails()
	
	// Ativação da Classe
	oBrowse:Activate()
	
Return NIL

Return
//-------------------------------------------------------------------
Static function MenuDef()
	local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Pesquisar'		ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar'		ACTION 'VIEWDEF.CMVPCP04'	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'			ACTION 'VIEWDEF.CMVPCP04'	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'			ACTION 'VIEWDEF.CMVPCP04'	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'			ACTION 'VIEWDEF.CMVPCP04'	OPERATION 5 ACCESS 0
	
Return aRotina
//-------------------------------------------------------------------

Static Function ModelDef()
	Local oModel
	
	Local oStr1:= FWFormStruct(1,'ZZB')
	Local oStr2:= FWFormStruct(1,'ZZC')
	
	oModel := MPFormModel():New('ModelZZB')//,,,/*{|oModel| fGrava(oModel)}*/,{|oModel| fSair(oModel)})
	oModel:SetDescription('Amarração Produto x Linha / Sublinha')
	
	oModel:addFields('ZZBMASTER',,oStr1)
	
	oModel:SetPrimaryKey({ 'ZZB_FILIAL', 'ZZB_PRODUT' })
	
	
	oModel:addGrid('ZZCGRID','ZZBMASTER',oStr2,/*blinePre*/,{ | oMdlG | PCP04LPOS( oMdlG ) }/*bLineOk*/,/*bPre*/,/*bTudoOk*/)
	oModel:SetRelation('ZZCGRID', { { 'ZZC_FILIAL', 'xFilial("ZZC")' }, { 'ZZC_PRODUT', 'ZZB_PRODUT' } }, ZZC->(IndexKey(1)) )
	oModel:GetModel('ZZCGRID'):SetUniqueLine({"ZZC_FILIAL","ZZC_PRODUT","ZZC_LINHA","ZZC_SUBLIN"})
	
	oStr2:SetProperty ( 'ZZC_SUBLIN', MODEL_FIELD_VALID, { | oMdlG | PCP04SUBL( oMdlG ) } )
	//oStr2:AddTrigger( 	'ZZC_SUBLIN'	, ;       // [01] Id do campo de origem
	//					'ZZC_DESC'		, ;       // [02] Id do campo de destino
	//					{ || .T. } , ;       // [03] Bloco de codigo de validação da execução do gatilho
	//					{ | oMdlG | PCP04SUBL( oMdlG ) } )       // [04] Bloco de codigo de execução do gatilho
	
	oModel:GetModel('ZZBMASTER'):SetDescription('Referencia Produto')
	oModel:GetModel('ZZCGRID'):SetDescription('Detalhes Linha / Sublinha')
	
Return oModel
//-------------------------------------------------------------------

Static Function ViewDef()
	Local oView
	Local oModel := ModelDef()
	
	Local oStr1:= FWFormStruct(2,'ZZB')
	
	Local cFldZZC   := "ZZC_FILIAL/ZZC_PRODUT/"
	Local oStr2:= FWFormStruct(2,'ZZC',{|cCampo|!(AllTrim(cCampo) $ cFldZZC)})
	
	//FwStruTrigger( 'ZZC_SUBLIN' , 'ZZC_DESC' , 'ZZA->ZZA_DESC' , .T. , "ZZA" , 1 , "xFilial('ZZA') + FwFldGet( 'ZZC_LINHA' ) + M->ZZC_SUBLIN )" , /*cCondic*/ )
	//FWFORMMODELSTRUCT():AddTrigger('ZZC_SUBLIN'/*cIdField8*/, 'ZZA->ZZA_DESC'/*<cTargetIdField >*/, /*[ bPre ]*/, { | oMdlG | PCP04TRGG( oMdlG ) }/*<bSetValue >*/) 
	
	oView := FWFormView():New()
	
	oView:SetModel(oModel)
	oView:SetDescription("Amarração Produto x Linha / Sublinha")
	
	oView:AddField('ZZBMASTER' , oStr1 )
	oView:AddGrid('ZZCGRID' , oStr2)
	
	oView:CreateHorizontalBox( 'BOXFORM1', 10)
	oView:CreateHorizontalBox( 'BOXFORM2', 90)
	oView:SetOwnerView('ZZCGRID','BOXFORM2')
	oView:SetOwnerView('ZZBMASTER','BOXFORM1')
	
Return oView

//-----------------------------------------------------------------------------
Static Function PCP04LPOS( oModelGrid )
Local lRet       := .T.
Local oModel     := oModelGrid:GetModel()
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

	If !ZZA->( dbSeek( xFilial("ZZA") + FwFldGet( 'ZZC_LINHA' ) + FwFldGet( 'ZZC_SUBLIN' ) ) )
		Help( ,, 'Help',, 'Não existe registro relacionado a este código', 1, 0 )
		lRet := .F.
	EndIf

EndIf

Return lRet
//-----------------------------------------------------------------------------
Static Function PCP04SUBL( oModelGrid )
Local lRet       := .T.
Local cRet       := ""
Local oModel     := oModelGrid:GetModel()
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

	If !ZZA->( dbSeek( xFilial("ZZA") + FwFldGet( 'ZZC_LINHA' ) + FwFldGet( 'ZZC_SUBLIN' ) ) )
	//	Help( ,, 'Help',, 'Não existe registro relacionado a este código', 1, 0 )
		lRet := .F.
	Else
		//cRet := GetAdvFVal("ZZA","ZZA_DESC",xFilial("ZZA") + FwFldGet( 'ZZC_LINHA' ) + FwFldGet( 'ZZC_SUBLIN' ),1,"")
		//oModel:SetValue( 'ZZC_DESC', ZZA->ZZA_DESC )
		FWFldPut( 'ZZC_DESC', ZZA->ZZA_DESC )
	EndIf

EndIf

Return lRet
//-----------------------------------------------------------------------------
Static Function PCP04TRGG( oModelGrid )
Local cRet       := ""
Local oModel     := oModelGrid:GetModel()
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

	cRet := GetAdvFVal("ZZA","ZZA_DESC", xFilial("ZZA") + FwFldGet( 'ZZC_LINHA' ) + FwFldGet( 'ZZC_SUBLIN' ) , 1  , "" )
	oModel:SetValue( 'ZZC_DESC', cRet )
	
EndIf

Return cRet
//-----------------------------------------------------------------------------
