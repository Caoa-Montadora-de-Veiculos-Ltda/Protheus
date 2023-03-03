#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwbrowse.ch"
#include 'fwmvcdef.ch'

/*
=====================================================================================
Programa.:              CMVPCP08
Autor....:              Atilio Amarilla
Data.....:              06/12/2018
Descricao / Objetivo:   Cadastro de Integração Protheus PCP x MES - Tabela Intermediária
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP PCP004
Obs......:              
=====================================================================================
*/
User function CMVPCP08()
	local oBrowse       

	//Cria um Browse Simples instanciando o FWMBrowse
	oBrowse := FWMBrowse():New()
	//Define um alias para o Browse
	oBrowse:SetAlias('ZZG')
	//Adiciona uma descrição para o Browse
	oBrowse:SetDescription('Integração Protheus - PCP x MES')

	// Definição da legenda
	oBrowse:AddLegend( "ZZG_STATUS==' '"	, "BLUE"	, "Pendente de Integração"	)
	oBrowse:AddLegend( "ZZG_STATUS=='1'"	, "GREEN"	, "Integrado com Sucesso"	)
	oBrowse:AddLegend( "ZZG_STATUS=='2'"	, "RED"		, "Integrado com Erro"		)

	//oBrowse:disableReport()

	//Ativa o Browse
	oBrowse:Activate()

return nil

//-------------------------------------------------------------------
static function MenuDef()

	local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.CMVPCP08'	OPERATION 2 ACCESS 0
	//ADD OPTION aRotina TITLE 'Incluir'		ACTION 'VIEWDEF.CMVPCP08'	OPERATION 3 ACCESS 0
	//ADD OPTION aRotina TITLE 'Alterar'    	ACTION 'VIEWDEF.CMVPCP08'	OPERATION 4 ACCESS 0
	//ADD OPTION aRotina TITLE 'Excluir'    	ACTION 'VIEWDEF.CMVPCP08'	OPERATION 5 ACCESS 0

return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZZG := FWFormStruct( 1, 'ZZG', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('PCP08MDL',  /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'ZZGMASTER', /*cOwner*/, oStruZZG, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Integração Protheus - PCP x MES' )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'ZZGMASTER' ):SetDescription( 'Integração Protheus - PCP x MES' )

	oModel:SetPrimaryKey({})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'CMVPCP08' )
	// Cria a estrutura a ser usada na View
	Local oStruZZG := FWFormStruct( 2, 'ZZG' )
	Local oView  

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados serÃ¡ utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZZG', oStruZZG, 'ZZGMASTER' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZZG', 'TELA' )

Return oView
//-------------------------------------------------------------------
