#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*
=========================================================================================================
Programa.................: CMVSAP22
Autor:...................: Totvs
Data.....................: Jun/19
Descrição / Objetivo.....: Integração SAP
Doc. Origem..............: 
Solicitante..............: Cliente
Uso......................: Caoa
Obs......................: 
=========================================================================================================
*/
User Function CMVSAP22()

Local oMBrowse := nil
Local aAux := {}
oMBrowse := FWmBrowse():New()

oMBrowse:SetAlias("SZG")
oMBrowse:SetDescription("Cadastro de Responsáveis - Integração SAP")
oMBrowse:SetMenudef("CMVSAP22")
	
oMBrowse:Activate()
	
Return


Static Function MenuDef()
	
Local aRotina := {}
	
ADD OPTION aRotina TITLE "Pesquisar"  	  ACTION "PesqBrw"         OPERATION 1                       ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" 	  ACTION "VIEWDEF.CMVSAP22" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    	  ACTION "VIEWDEF.CMVSAP22" OPERATION MODEL_OPERATION_INSERT ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    	  ACTION "VIEWDEF.CMVSAP22" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    	  ACTION "VIEWDEF.CMVSAP22" OPERATION MODEL_OPERATION_DELETE ACCESS 0
	
Return aRotina


Static Function ModelDef()

Local oStruSZG := FWFormStruct( 1, 'SZG', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
Local cHora := TIME()

oModel := FWModelActive()
oModel := MPFormModel():New('XCMVSAP22', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields( 'SZGMASTER', /*cOwner*/, oStruSZG, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:SetDescription( 'Cadastro de Responsáveis - Integração SAP' )

oModel:SetPrimaryKey({'ZF_FILIAL'})

oModel:GetModel( 'SZGMASTER' ):SetDescription( 'Cadastro de Responsáveis - Integração SAP' )

Return oModel


Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado

Local oModel := FWLoadModel( 'CMVSAP22' )
Local oStruSZG := FWFormStruct( 2, 'SZG' )
Local oView
Local cCampos := {}
			
oView := FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_SZG', oStruSZG, 'SZGMASTER' )

oView:CreateHorizontalBox( 'TELA' , 100 )

oView:SetOwnerView( 'VIEW_SZG', 'TELA' )

Return oView	