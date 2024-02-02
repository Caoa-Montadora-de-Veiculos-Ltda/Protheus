//Bibliotecas
#Include 'Totvs.ch'
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

//Defines
#Define CRLF chr(13) + chr(10)

//Variáveis estáticas
Static cTitulo := "Chamados"
Static cAliasMVC := "ZK0"

/*
=====================================================================================
Programa.:              ZMOD01
Autor....:              Nicolas C Lima Santos 
Data.....:              31/01/24
Descricao / Objetivo:   
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:              
=====================================================================================
*/

User Function zMOD01()
    Local aArea := GetArea()
    Local oBrowse

    Private aRotina := {}

    //Definicao do menu
    aRotina := MenuDef()

    //Instanciando o browse
    oBrowse := FWBrowse():New()
    oBrowse:SetAlias(cAliasMVC)
    oBrowse:SetDescription(cTitulo)
    //oBrowse:DisableDetails()

    //Ativa a Browse
    oBrowse:Activate()

    RestArea(aArea)

Return Nil

//Opções de menu
Static Function MenuDef()

    Local aRotina := {}

    //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.zMOD01" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.zMOD01" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.zMOD01" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.zMOD01" OPERATION 5 ACCESS 0

Return aRotina

//Cria o modelo de dados para cadastro
Static Function ModelDef()

    Local oStruct := FWFormStruct(1, cAliasMVC)
    Local oModel
    Local bPre      := Nil //Antes de abrir o formulário.
    Local bPos      := Nil //Ao clicar no confirmar, antes de salvar.
    Local bCommit   := Nil //Após fechar o formulário quando for salvar.
    Local bCancel   := Nil //Quando o usuário cancelar o formulário.

    //Cria o modelo de dados para cadastro
    oModel := MPFormModel():New("zMOD01M", bPre, bPos, bCommit, bCancel)
    oModel:AddFields("ZK0MASTER",/*cOwner*/,oStruct)
    oModel:SetDescription("Modelo de dados - " + cTitulo) //ZK0MASTER -> Nome da estrutura de campos.
    oModel:GetModel("ZK0MASTER"):SetDescription("Dados de - " + cTitulo)
    oModel:SetPrimaryKey({})

Return oModel

//View Def
Static Function ViewDef()

    Local oModel := FWLoadModel("zMOD01")
    Local oStruct := FWFormStruct(2, cAliasMVC)
    Local oView

    //Cria a visualização cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)
    //Isso precisa ser amarrado ao ModelDef através da ZK0MASTER
    oView:AddField("VIEW_ZK0", oStruct, "ZK0MASTER") //VIEW_ZK0 -> Sessão de campos
    oVIew:CreateHorizontalBox("TELA", 50) //Nome do contâiner e % de tela
    oView:SetOwnerView("VIEW_ZK0", "TELA") //Atrela os campos a tela.

    //Título
    oView:EnableTitleView("VIEW_ZK0", "TESTE DE TELA ZK0")

    //Removendo campos não desejados
    //oStruct:RemoveField("NOME_CAMPO")

Return oView


User Function zIndex()

    Local aArea := GetArea()

    Local cTabela := 


    DbSelectArea("ZK0")
    DBCreateIndex(cTabela +'1', "EW5_INVOIC+EW5_PO_NUM" , {|| EW5_INVOIC+EW5_PO_NUM+EW5_COD_I+EW5_SI_NUM+EW5_POSICA }, .F.)
		

    MsgInfo("Teste","Teste")

    RestArea(aArea)
Return
