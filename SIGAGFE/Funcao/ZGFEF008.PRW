//Bibliotecas
#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "FWMVCDEF.ch"

//Variáveis estatisticas
Static cTitulo      := "Ajuste de Peso - Notas Fiscas"
Static cTabPai      := "SF2" //Cabeçalho de NF.
Static cTabFilho    := "GW8" //Itens do documento de carga.

User function ZGFEF008()

	Local aArea     := GetArea()
	Local oBrowse
	
	//Local lRet 		:= .F.
	//Local cNumDoc 	:= "000000039"
	Local cFunBkp   := FunName()

	Private aRotina := {}

	SetFunName("ZGFEF008")

	//Begin Sequence
	/*
		//Definição do menu
		aRotina := MenuDef()

		//Instânciando - Somente com dicionário de dados
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias(cTabPai)
		oBrowse:SetDescription(cTitulo)
		oBrowse:DisableDetails()
		
		oBrowse:SetOnlyFields({'F2_DOC','F2_SERIE','F2_LOJA','F2_EMISSAO'})
		//oBrowse:SetFields(aColunas) //Campos que devem aparecer no Browse
		
		oBrowse:Activate() //Ativa a Browse
	*/
	SetFunName(cFunBkp)
	RestArea(aArea)

Return Nil

Static Function MenuDef()

	Local aRotina := {}

	//Adicionando opções de menu
	ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.ZGFEF008" OPERATION 1 ACCESS 0
	//ADD OPTION aRotina TITLE "Incluir"      ACTION "VIEWDEF.ZGFEF008" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.ZGFEF008" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"      ACTION "VIEWDEF.ZGFEF008" OPERATION 5 ACCESS 0

Return aRotina

//Cria o modelo de dados para cadastro
Static Function ModelDef()
	
	Local oModel
	Local oStruPai 	 := FWFormStruct(1, cTabPai)
	Local oStruFilho := FWFormStruct(1, cTabFilho)
	Local aRelation  := {}
	Local bPre       := Nil //Antes de abrir o formulário.
	Local bPos       := {|| u_fCommit() } //Ao clicar no confirmar, antes de salvar.
	Local bCommit    := Nil //Após fechar o formulário quando for salvar.
	Local bCancel    := Nil //Quando o usuário cancelar o formulário
	
	//Bloqueia alteração no campo (deixa cinza).
	oStruPai:SetProperty('F2_DOC'     , MODEL_FIELD_WHEN,{|| .F. })
	oStruPai:SetProperty('F2_SERIE'   , MODEL_FIELD_WHEN,{|| .F. })
	oStruPai:SetProperty('F2_CLIENTE' , MODEL_FIELD_WHEN,{|| .F. })
	oStruPai:SetProperty('F2_LOJA'    , MODEL_FIELD_WHEN,{|| .F. })
	oStruPai:SetProperty('F2_EMISSAO' , MODEL_FIELD_WHEN,{|| .F. })
	oStruPai:SetProperty('F2_VALBRUT' , MODEL_FIELD_WHEN,{|| .F. })
	oStruPai:SetProperty('F2_CHVNFE'  , MODEL_FIELD_WHEN,{|| .F. })

	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New('ZGFEF08M', bPre, bPos, bCommit, bCancel)
	oModel:AddFields("SF2MASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("GW8GRID","SF2MASTER", oStruFilho)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("SF2MASTER"):SetDescription("Dados de - " + cTitulo)
	oModel:GetModel("GW8GRID"  ):SetDescription("Grid de - "  + cTitulo)

	//Fazendo o relacionamento (similar ao left join do sql)
	aAdd(aRelation, {"GW8_FILIAL", "FWxFilial('GW8')"}) //Na esquerda é o filho e na direitra é o Pai.
	aAdd(aRelation, {"GW8_NRDC", "F2_DOC"}) //Na esquerda é o filho e na direitra é o Pai.
	oModel:SetRelation("GW8GRID", aRelation, GW8->(IndexKey(1)))
	oModel:SetPrimaryKey({})

Return oModel

Static Function ViewDef()

	Local oModel     := FWLoadModel("ZGFEF008")
	Local oStruPai   := FWFormStruct(2, cTabPai  , { |x| Alltrim(x) $ 'F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALBRUT, F2_CHVNFE, F2_PBRUTO, F2_XPESOC'})
	Local oStruFilho := FWFormStruct(2, cTabFilho, { |x| Alltrim(x) $ 'GW8_NRDC, GW8_SEQ, GW8_DSITEM, GW8_PESOR, GW8_PESOC'})
	Local oView 	 := Nil
	
	//Cria a visualizacao de cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB",oStruPai  ,"SF2MASTER") 
	oView:AddGrid("VIEW_GRID",oStruFilho  ,"GW8GRID")
	//oView:AddOtherObject("VIEW_BOTAO", {|oPanel| fCustom(oPanel)})

	//Distribuição da tela
	oView:CreateHorizontalBox("CABEC", 60)
		//oView:CreateVerticalBox("CABEC_ESQ",60,"CABEC")
		//oView:CreateVerticalBox("CABEC_DIR",40,"CABEC")
	oView:CreateHorizontalBox("GRID" , 40)

	oView:SetOwnerView("VIEW_CAB", "CABEC")
	//oView:SetOwnerView("VIEW_CAB", "CABEC_ESQ")
	//oView:SetOwnerView("VIEW_BOTAO", "CABEC_DIR")
	oView:SetOwnerView("VIEW_GRID", "GRID")
	//oView:SetCloseOnOk({||.T.})

	//Título
	oView:EnableTitleView("VIEW_CAB","Cabeçalho NF")
	//oView:EnableTitleView("VIEW_BOTAO","Novos valores de peso")
	oView:EnableTitleView("VIEW_GRID","Itens NF")
	
	oStruPai:RemoveField( 'F2_CLIENT' )
	//Definindo que não irá usar o botão "Salvar e Criar Novo"
    oView:SetCloseOnOk({|| .T.})	

Return oView

User Function fCommit()
	Local aArea := GetArea()

	//Pegando o modelo de dados MVC e pegando os campos
	Local oModelAtiv := FWModelActive()
	Local oModelCad  := oModelAtiv:GetModel('SF2MASTER')
	//Local aCampos    := SF2->(DbStruct())

	Local cPBOrig := SF2->F2_PBRUTO //Peso Bruto Original
	Local cPBNovo := oModelCad:GetValue('F2_PBRUTO') //Peso Bruto Novo
	Local cPCOrig := SF2->F2_XPESOC //Peso cubado Original
	Local cPCNovo := oModelCad:GetValue('F2_XPESOC') //Peso Cubado Novo
	Local lRet := .F.
	
	If MsgYesNo("Deseja continuar?","Atenção")
	//MsgYesNo("Confirma as alterações: " + CRLF + "Peso bruto de: "  + cPBOrig + " para: " + cPBNovo + " " + CRLF	+ "Peso cubado de: " + cPCOrig + " para: " + cPCNovo + " ","Atenção")
		
		lRet := .T.
	Else
		lRet := .F.
		Help("",1,"ZGFEF008",,"Dados não alterados.",1) // "Preencher o campo Loja do Prospect." 
	EndIf
	
	RestArea(aArea)
Return lRet
