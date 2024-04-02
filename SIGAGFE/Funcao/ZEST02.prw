//Bibliotecas
#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "FWMVCDEF.ch"

//Variáveis estatisticas
Static cTitulo      := "Notas Fiscas"
Static cTabPai      := "SF2" //Cabeçalho de NF
//Static cTabFilho    := "SD2" //Itens de NF

User function zEST02()

	Local aArea     := GetArea()
	//Local cFunBkp   := FunName() //Guarda o nome da função atual.
	Local oBrowse

	Private aRotina := {}

	//Definição do menu
	aRotina := MenuDef()

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cTabPai)
	//Define os campos que aparecem no Browse
	oBrowse:SetOnlyFields({'F2_DOC','F2_SERIE','F2_LOJA','F2_EMISSAO'})
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()
	//Ativa o Browse
	oBrowse:Activate()

	RestArea(aArea)

Return Nil

Static Function MenuDef()

	Local aRotina := {}

	//Adicionando opções de menu
	ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.zEst02" OPERATION 1 ACCESS 0
	//ADD OPTION aRotina TITLE "Incluir"      ACTION "VIEWDEF.zEst02" OPERATION 3 ACCESS 0
	//ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.zEst02" OPERATION 4 ACCESS 0 //Operação de alteração.
	//ADD OPTION aRotina TITLE "Excluir"      ACTION "VIEWDEF.zEst02" OPERATION 5 ACCESS 0

Return aRotina

//Cria o modelo de dados para cadastro
Static Function ModelDef()

	Local oStruPai      := FWFormStruct(1, cTabPai,   { |x| Alltrim(x) $ 'F2_DOC,F2_SERIE,F2_LOJA,F2_COND,F2_DUPL'}) //Opção 2 monta de forma a ser visualizada no formulário.
	//Local oStruFilho    := FWFormStruct(1, cTabFilho, { |x| Alltrim(x) $ 'D2_ITEM,D2_COD,D2_QUANT,D2_UM,D2_PRCVEN,D2_TOTAL'  })
    Local oModel

	//Local aRelation := {}
	
	//Blocos de código para criar validações
	Local bPre      := Nil //Antes de abrir o formulário.
	Local bPos      := Nil //Ao clicar no confirmar, antes de salvar.
	Local bCommit   := Nil //Após fechar o formulário quando for salvar.
	Local bCancel   := Nil //Quando o usuário cancelar o formulário

	//Bloqueia alteração no campo (deixa cinza).
	oStruPai:SetProperty('F2_DOC' , MODEL_FIELD_WHEN,{|| .F. })

	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("zEst02M", bPre, bPos, bCommit, bCancel)
	
	oModel:AddFields("SF2MASTER", /*cOwner*/, oStruPai)
	//oModel:AddGrid("SD2DETAIL","SF2MASTER", oStruFilho, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/, /*bPos Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)
    oModel:SetDescription("Modelo de dados - " + cTitulo) //SF2MASTER -> Nome da estrutrua de campos.
	oModel:GetModel("SF2MASTER"):SetDescription("Dados de - " + cTitulo)
	//oModel:GetModel("SD2DETAIL"):SetDescription("Grid de - " + cTitulo)
    
    //Define a chave primária utilizada pelo modelo
	oModel:SetPrimaryKey({})

	//Fazendo o relacionamento (similar ao left join do sql)
	//aAdd(aRelation, {"D2_FILIAL", "FWxFilial('SD2')"}) //A filial "não preisa" ser relacionada. //Na esquerda é o filho e na direitra é o Pai.
	//aAdd(aRelation, {"D2_DOC","F2_DOC"})
	//oModel:SetRelation("SD2DETAIL", aRelation, SD2->(IndexKey(1)))

Return oModel

Static Function ViewDef()

	Local oModel        := FWLoadModel("zEst02")
	
    Local oStruPai      := FWFormStruct(2, cTabPai,   { |x| Alltrim(x) $ 'F2_DOC,F2_SERIE,F2_LOJA,F2_COND,F2_DUPL'}) //Opção 2 monta de forma a ser visualizada no formulário.
	//Local oStruFilho    := FWFormStruct(2, cTabFilho, { |x| Alltrim(x) $ 'D2_ITEM,D2_COD,D2_QUANT,D2_UM,D2_PRCVEN,D2_TOTAL'  })

	Local oView

	//Cria a visualizacao de cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Isso precisa ser amarrado ao ModelDef através da ZK0MASTER
	oView:AddField("VIEW_SF2", oStruPai, "SF2MASTER") //Sessão de campos
	//oView:AddGrid("VIEW_SD2" , oStruFilho, "SD2DETAIL")

	//Distribuição da tela
	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID", 70)
	oView:SetOwnerView("VIEW_SF2", "CABEC")
	//oView:SetOwnerView("VIEW_SD2", "GRID")

	//Título
	oView:EnableTitleView("VIEW_SF2","Cabeçalho - SF2")
	//oView:EnableTitleView("VIEW_SD2","Itens - SD2")

Return oView


