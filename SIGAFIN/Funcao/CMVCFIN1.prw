#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'

user function CMVCFIN1()
	
	Local aButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	FWExecView('Titulos Financeiros','CMVCFIN1', MODEL_OPERATION_VIEW, , { || .T. }, ,50,aButtons )

return

Static function MenuDef()

	Local	aRotina	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"          OPERATION 1                      ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.CMVCFIN1" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.CMVCFIN1" OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.CMVCFIN1" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.CMVCFIN1" OPERATION MODEL_OPERATION_DELETE ACCESS 0

Return(aRotina)

Static function ModelDef()

	Local oModel := nil
	
	Local oStrSE2 := FWFormStruct(1,"SE2")
	
	oModel := MPFormModel():New("XCMVCFIN1",/*bPreValidacao*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/ )
	oModel:AddFields("CABMASTER",/*cOwner*/,oStrSE2, /*bPreValid*/, /*bPosValid*/, /*bCarga*/ )
	oModel:SetDescription("Titulo Financeiro")
	
return oModel

Static function ViewDef()

	Local oView
	Local oModel  	:= FWLoadModel('CMVCFIN1')
	Local oStrSE2 	:= FWFormStruct(2,"SE2")

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField( 'VIEW_CAB' , oStrSE2, 'CABMASTER' )
	
	oView:CreateHorizontalBox( 'TELA' , 100 )
	
	oView:SetOwnerView( 'VIEW_CAB', 'TELA' )

Return oView