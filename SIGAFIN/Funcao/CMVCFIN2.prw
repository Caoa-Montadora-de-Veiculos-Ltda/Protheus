#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'

user function CMVCFIN2()
	
	Local aButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	FWExecView('Titulos Financeiros','CMVCFIN2', MODEL_OPERATION_VIEW, , { || .T. }, ,50,aButtons )

return

Static function MenuDef()

	Local	aRotina	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "PesqBrw"          OPERATION 1                      ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.CMVCFIN2" OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.CMVCFIN2" OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.CMVCFIN2" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.CMVCFIN2" OPERATION MODEL_OPERATION_DELETE ACCESS 0

Return(aRotina)

Static function ModelDef()

	Local oModel := nil
	
	Local oStrSE1 := FWFormStruct(1,"SE1")
	
	oModel := MPFormModel():New("XCMVCFIN2",/*bPreValidacao*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/ )
	oModel:AddFields("CABMASTER",/*cOwner*/,oStrSE1, /*bPreValid*/, /*bPosValid*/, /*bCarga*/ )
	oModel:SetDescription("Titulo Financeiro")
	
return oModel

Static function ViewDef()

	Local oView
	Local oModel  	:= FWLoadModel('CMVCFIN2')
	Local oStrSE1 	:= FWFormStruct(2,"SE1")

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField( 'VIEW_CAB' , oStrSE1, 'CABMASTER' )
	
	oView:CreateHorizontalBox( 'TELA' , 100 )
	
	oView:SetOwnerView( 'VIEW_CAB', 'TELA' )

Return oView