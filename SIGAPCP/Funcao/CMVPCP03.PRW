#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwbrowse.ch"
#include 'fwmvcdef.ch'

/*
=====================================================================================
Programa.:              CMVPCP03
Autor....:              Atilio Amarilla
Data.....:              06/12/2018
Descricao / Objetivo:   Cadastro de Linha / Sublinha
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP PCP006
Obs......:              
=====================================================================================
*/
User function CMVPCP03()
	local oBrowse       

	//Cria um Browse Simples instanciando o FWMBrowse
	oBrowse := FWMBrowse():New()
	//Define um alias para o Browse
	oBrowse:SetAlias('ZZA')
	//Adiciona uma descrição para o Browse
	oBrowse:SetDescription('Cadastro de Linha / Sublinha')

	//oBrowse:disableReport()

	//Ativa o Browse
	oBrowse:Activate()

return nil

//-------------------------------------------------------------------
static function MenuDef()

	local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.CMVPCP03'	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'		ACTION 'VIEWDEF.CMVPCP03'	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    	ACTION 'VIEWDEF.CMVPCP03'	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    	ACTION 'VIEWDEF.CMVPCP03'	OPERATION 5 ACCESS 0

return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZZA := FWFormStruct( 1, 'ZZA', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('PCP03MDL',  { |oMdl| PCP03PRE( oMdl ) }  /*bPreValidacao*/, { |oMdl| PCP03POS( oMdl ) } /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'ZZAMASTER', /*cOwner*/, oStruZZA, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Cadastro de Linha / Sublinha' )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'ZZAMASTER' ):SetDescription( 'Cadastro de Linha / Sublinha' )

	oModel:SetPrimaryKey({})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'CMVPCP03' )
	// Cria a estrutura a ser usada na View
	Local oStruZZA := FWFormStruct( 2, 'ZZA' )
	Local oView  

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados serÃ¡ utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZZA', oStruZZA, 'ZZAMASTER' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZZA', 'TELA' )

Return oView
//-------------------------------------------------------------------
Static Function PCP03POS( oModel )
Local nOperation := oModel:GetOperation()
Local lRet       := .T.

If nOperation == MODEL_OPERATION_INSERT
	If ZZA->( dbSeek( xFilial("ZZA") + oModel:GetValue( 'ZZAMASTER', 'ZZA_LINHA' ) + oModel:GetValue( 'ZZAMASTER', 'ZZA_SUBLIN' )  ) ) // ExistChav( "ZZA" , oModel:GetValue( 'ZZAMASTER', 'ZZA_LINHA' ) + oModel:GetValue( 'ZZAMASTER', 'ZZA_SUBLIN' ) , 1 )
		//Help( ,, 'HELP',, 'Já existe registro gravado com essas informações!' , 1 , 0 )
		Help( ,, 'JAGRAVADO',, , 1 , 0 )
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
Static Function PCP03PRE( oModel )
Local nOperation := oModel:GetOperation()
Local lRet       := .T.
Local aArea		:= GetArea()

If nOperation == MODEL_OPERATION_DELETE
	If Select("ZZC") == 0
		dbSelectArea("ZZC")
	EndIf
	ZZC->(dbSetOrder(2))
	If ZZC->( dbSeek( xFilial("ZZC") + oModel:GetValue( 'ZZAMASTER', 'ZZA_LINHA' ) + oModel:GetValue( 'ZZAMASTER', 'ZZA_SUBLIN' )  ) ) // ExistChav( "ZZA" , oModel:GetValue( 'ZZAMASTER', 'ZZA_LINHA' ) + oModel:GetValue( 'ZZAMASTER', 'ZZA_SUBLIN' ) , 1 )
		Help( ,, 'EMUSO',, , 1 , 0 )
		lRet := .F.
	EndIf
	RestArea( aArea )
EndIf

Return lRet

//-------------------------------------------------------------------
