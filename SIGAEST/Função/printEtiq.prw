#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#INCLUDE "FWEDITPANEL.CH"

/*/{Protheus.doc} printEtiq
//TODO Descrição auto-gerada.
@author Daniel Braga
@since 09/05/2016
@version 1.0
@return nil, ""
@example
(examples)
@see (links_or_references)
/*/

User Function printEtiq()
	
	Local oBrowse := FWMBrowse():New() 

	oBrowse:SetAlias('ZA1') // Definição da tabela do Browse
	oBrowse:SetDescription('Cadastro de Etiqueta') // Titulo da Browse
	oBrowse:Activate() // Ativação da Classe

Return

Static Function MenuDef()
	private aRotina := {}

	ADD OPTION aRotina Title 'Visualizar'	Action 'VIEWDEF.printEtiq' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'		Action 'VIEWDEF.printEtiq' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'		Action 'VIEWDEF.printEtiq' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'		Action 'VIEWDEF.printEtiq' OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title 'Simular'      Action 'U_SimulPrint()'    OPERATION 6 ACCESS 0

Return aRotina

Static Function ModelDef()
	
	Local oStruZA1 := FWFormStruct(1, 'ZA1')
	Local oModel // Modelo de dados que será construído

	oModel := MPFormModel():New('PRTETI_MVC',,,)// Cria o objeto do Modelo de Dados
	oStruZA1:SetProperty('ZA1_CODIGO' , MODEL_FIELD_INIT,{||  IIF(!INCLUI,M->ZA1_CODIGO, getSXENum("ZA1","ZA1_CODIGO")   )} )
	oStruZA1:SetProperty('ZA1_CODIGO' , MODEL_FIELD_WHEN,{||  .F. } )
	oStruZA1:setProperty("ZA1_PORTA"  ,MODEL_FIELD_WHEN, {|oModel| blqFldChange()  } )  
	oStruZA1:setProperty("ZA1_MODELO" ,MODEL_FIELD_WHEN, {|oModel| blqFldChange()  } )  
	
	oModel:AddFields('ZA1MASTER', /*cOwner*/, oStruZA1)// Adiciona ao modelo um componente de formulário
	
	oModel:GetModel('ZA1MASTER' ):SetDescription('ZA1MASTER')
	oModel:SetDescription('Modelo de dados MVC')// Adiciona a descrição do Modelo de Dados
	
	oModel:SetPrimaryKey({})

Return oModel

Static Function ViewDef()
	Local oModel  := FWLoadModel('printEtiq')// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStrZA1 := FWFormStruct(2, 'ZA1',{|cCampo| !AllTrim(cCampo) $ "|ZA1_ETIQUE|ZA1_QUERY|"})
	Local oStrEti := FWFormStruct(2, 'ZA1',{|cCampo| AllTrim(cCampo) $ "|ZA1_ETIQUE|"})
	Local oStrQry := FWFormStruct(2, 'ZA1',{|cCampo| AllTrim(cCampo) $ "|ZA1_QUERY|"})

	Local oView // Interface de visualização construída

	oStrZA1:setProperty("ZA1_FILA",MVC_VIEW_LOOKUP   , {||"CB5" })
    
	oView := FWFormView():New() // Cria o objeto de View
	oView:SetModel( oModel ) // Define qual o Modelo de dados será utilizado na View
	
	oView:AddField( 'VIEW_ZA1', oStrZA1, 'ZA1MASTER' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddField( 'VIEW_ETI', oStrEti, 'ZA1MASTER' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddField( 'VIEW_QRY', oStrQry, 'ZA1MASTER' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	
	oView:CreateHorizontalBox( 'Box4', 100)
	oView:CreateFolder( 'FOLDER', 'Box4')
	
	oView:AddSheet('FOLDER','SHEET1','Impressão')
	oView:AddSheet('FOLDER','SHEET2','Etiqueta')
	oView:AddSheet('FOLDER','SHEET3','Query')
    
    oView:CreateHorizontalBox( 'Box1', 100, , , 'FOLDER', 'SHEET1')
    oView:CreateHorizontalBox( 'Box2', 100, , , 'FOLDER', 'SHEET2')
    oView:CreateHorizontalBox( 'Box3', 100, , , 'FOLDER', 'SHEET3')
	
	oView:SetViewProperty("VIEW_ETI","SETLAYOUT", {FF_LAYOUT_VERT_DESCR_TOP, 3})
	oView:SetViewProperty("VIEW_QRY","SETLAYOUT", {FF_LAYOUT_VERT_DESCR_TOP, 3})
	
	
	oView:SetOwnerView( 'VIEW_ZA1' , 'Box1' )// Relaciona o identificador (ID) da View com o 'box' para exibição
	oView:SetOwnerView( 'VIEW_ETI' , 'Box2' )// Relaciona o identificador (ID) da View com o 'box' para exibição
	oView:SetOwnerView( 'VIEW_QRY' , 'Box3' )// Relaciona o identificador (ID) da View com o 'box' para exibição
    
Return oView

user Function SimulPrint()

    local cCodigo :=  ZA1->ZA1_CODIGO
    
    U_PrtTmpl(cCodigo)

return 

static Function blqFldChange(oModel)


	local cZA1_TPIMP := ""
	
	
	cZA1_TPIMP := FWFldGet("ZA1_TPIMP")
	
	if cZA1_TPIMP == "2" 
		return .f.
	endIf
return .t.
