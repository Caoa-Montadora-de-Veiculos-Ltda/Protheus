#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*
=========================================================================================================
Programa.................: CMVSAP21
Autor:...................: Totvs
Data.....................: Jun/19
Descrição / Objetivo.....: Integração SAP
Doc. Origem..............: 
Solicitante..............: Cliente
Uso......................: Caoa
Obs......................: 
=========================================================================================================
*/
User Function CMVSAP21()

Local oMBrowse := nil
Local aAux := {}
oMBrowse := FWmBrowse():New()

oMBrowse:SetAlias("SZF")
oMBrowse:SetDescription("Cadastro de Catálogo de Erros - Integração SAP")
oMBrowse:SetMenudef("CMVSAP21")
	
oMBrowse:Activate()
	
Return


Static Function MenuDef()
	
Local aRotina := {}
	
ADD OPTION aRotina TITLE "Pesquisar"  	  ACTION "PesqBrw"         OPERATION 1                       ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" 	  ACTION "VIEWDEF.CMVSAP21" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    	  ACTION "VIEWDEF.CMVSAP21" OPERATION MODEL_OPERATION_INSERT ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    	  ACTION "VIEWDEF.CMVSAP21" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    	  ACTION "VIEWDEF.CMVSAP21" OPERATION MODEL_OPERATION_DELETE ACCESS 0
	
Return aRotina


Static Function ModelDef()

Local oStruSZF := FWFormStruct( 1, 'SZF', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
Local cHora := TIME()

oModel := FWModelActive()
oModel := MPFormModel():New('XCMVSAP21', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields( 'SZFMASTER', /*cOwner*/, oStruSZF, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:SetDescription( 'Cadastro de Catálogo de Erros - Integração SAP' )

oModel:SetPrimaryKey({'ZF_FILIAL'})

oModel:GetModel( 'SZFMASTER' ):SetDescription( 'Cadastro de Catálogo de Erros - Integração SAP' )

Return oModel


Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado

Local oModel := FWLoadModel( 'CMVSAP21' )
Local oStruSZF := FWFormStruct( 2, 'SZF' )
Local oView
Local cCampos := {}
			
oView := FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_SZF', oStruSZF, 'SZFMASTER' )

oView:CreateHorizontalBox( 'TELA' , 100 )

oView:SetOwnerView( 'VIEW_SZF', 'TELA' )

Return oView	