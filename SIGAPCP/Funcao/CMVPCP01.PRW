#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*
=====================================================================================
Programa.:              CMVPCP01
Autor....:              Atilio Amarilla
Data.....:              06/12/2018
Descricao / Objetivo:   Cadastro de VIN
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP PCP004
Obs......:              
=====================================================================================
*/

User Function CMVPCP01()
	
	Local oBrowse

	// Abertura de tabelas
	dbSelectArea("SB1")
	dbSelectArea("ZZ1")
	dbSelectArea("ZZ2")


	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()
	
	// Definição da tabela do Browse
	oBrowse:SetAlias('ZZ1')
	
	// Titulo da Browse
	oBrowse:SetDescription("VIN")
	
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
	ADD OPTION aRotina TITLE 'Visualizar'		ACTION 'VIEWDEF.CMVPCP01'	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'			ACTION 'VIEWDEF.CMVPCP01'	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'			ACTION 'VIEWDEF.CMVPCP01'	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'			ACTION 'VIEWDEF.CMVPCP01'	OPERATION 5 ACCESS 0
	
Return aRotina
//-------------------------------------------------------------------

Static Function ModelDef()
	Local oModel
	
	Local oStr1:= FWFormStruct(1,'ZZ1')
	Local oStr2:= FWFormStruct(1,'ZZ2')
	
	oModel := MPFormModel():New('ModelZZ1')//,,,/*{|oModel| fGrava(oModel)}*/,{|oModel| fSair(oModel)})
	oModel:SetDescription('VIN')
	
	oModel:addFields('ZZ1MASTER',,oStr1)
	
	oModel:SetPrimaryKey({ 'ZZ1_FILIAL', 'ZZ1_VIN' })
	
	
	oModel:addGrid('ZZ2DETAIL','ZZ1MASTER',oStr2,/*blinePre*/,/*bLineOk*/,/*bPre*/,/*bTudoOk*/)
	oModel:SetRelation('ZZ2DETAIL', { { 'ZZ2_FILIAL', 'xFilial("ZZ2")' }, { 'ZZ2_VIN', 'ZZ1_VIN' } }, ZZ2->(IndexKey(1)) )
	oModel:GetModel('ZZ2DETAIL'):SetUniqueLine({"ZZ2_FILIAL","ZZ2_VIN","ZZ2_ITSEG"})
	// Indica que é opcional ter dados informados na Grid
	oModel:GetModel( 'ZZ2DETAIL' ):SetOptional(.T.)	
	
	oModel:GetModel('ZZ1MASTER'):SetDescription('VIN')
	oModel:GetModel('ZZ2DETAIL'):SetDescription('Item de Segurança')
	
Return oModel
//-------------------------------------------------------------------

Static Function ViewDef()
	Local oView
	Local oModel := ModelDef()
	
	Local oStr1:= FWFormStruct(2,'ZZ1')
	
	Local cFldZZ2   := "ZZ2_FILIAL/ZZ2_VIN/"
	Local oStr2:= FWFormStruct(2,'ZZ2',{|cCampo|!(AllTrim(cCampo) $ cFldZZ2)})
	
	oView := FWFormView():New()
	
	oView:SetModel(oModel)
	oView:SetDescription("VIN")
	
	oView:AddField('ZZ1MASTER' , oStr1 )
	oView:AddGrid('ZZ2DETAIL' , oStr2)
	
	oView:CreateHorizontalBox( 'BOXFORM1', 35)
	oView:CreateHorizontalBox( 'BOXFORM2', 65)
	oView:SetOwnerView('ZZ2DETAIL','BOXFORM2')
	oView:SetOwnerView('ZZ1MASTER','BOXFORM1')
	
Return oView

//-------------------------------------------------------------------
