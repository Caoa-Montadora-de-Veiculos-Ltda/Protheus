#Include 'parmtype.ch'
#Include "PROTHEUS.CH"
#Include "FWMBROWSE.CH"
#Include "FWMVCDEF.CH"
 
/*Iniciando sua função*/
User Function ZPECF014(cTabela, cTitRot)

/*Declarando as variáveis que serão utilizadas*/
Local aArea         := SX5->(GetArea())
Private oBrowse
Private cChaveAux   := ""
//Private aRotina	 	:= Menudef()

//Iniciamos a construção básica de um Browse.
oBrowse := FWMBrowse():New()
 
//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
oBrowse:SetAlias("SX5")
 
//Definimos o título que será exibido como método SetDescription
oBrowse:SetDescription("Grupo Tributário")
oBrowse:SetMenudef("ZPECF014") 	
//Adiciona um filtro ao browse
oBrowse:SetFilterDefault( "X5_TABELA == '0A'" )
	
//Desliga a exibição dos detalhes
//oBrowse:DisableDetails()
	
//Ativamos a classe
oBrowse:Activate()
RestArea(aArea)

Return

//-------------------------------------------------------------------
// Montar o menu Funcional
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"  	ACTION 'PesqBrw' 		OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ZPECF014" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    	ACTION "VIEWDEF.ZPECF014" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    	ACTION "VIEWDEF.ZPECF014" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    	ACTION "VIEWDEF.ZPECF014" OPERATION 5 ACCESS 0

Return aRotina

Static Function ViewDef()

Local oView
Local oModel := ModelDef()
Local oStr1  := FWFormStruct(2, 'SX5')
	
// Cria o objeto de View
oView := FWFormView():New()
	
// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)
	
//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('Formulario' , oStr1,'CamposSX5' )
 
//Remove os campos que não irão aparecer	
//oStr1:RemoveField( 'X5_DESCENG' )
//oStr1:RemoveField( 'X5_DESCSPA' )
	
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'PAI', 100)
	
// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('Formulario','PAI')

//oView:EnableTitleView('Formulario' , 'Grupo Tributário' )	
If Alltrim(SX5->X5_TABELA) == '0A'
	oView:EnableTitleView('Formulario' , 'Linha Peças' )	
ElseIf Alltrim(SX5->X5_TABELA) == '0B'
	oView:EnableTitleView('Formulario' , 'Familia Peças' )	
ElseIf Alltrim(SX5->X5_TABELA) == '02'
	oView:EnableTitleView('Formulario' , 'Tipo Peças' )	
EndIf
oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})
	
//Força o fechamento da janela na confirmação
oView:SetCloseOnOk({||.T.})
	
Return oView

Static Function ModelDef()

Local oModel
Local oStr1:= FWFormStruct( 1, 'SX5', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados
	
//Cria o objeto do Modelo de Dados
//Irie usar uma função ZPECF014V que será acionada quando eu clicar no botão "Confirmar"
oModel := MPFormModel():New('GrupoTributario', /*bPreValidacao*/, { | oModel | ZPECF014V(oModel) } , /*{ | oMdl | ZPECF014C( oMdl ) }*/ ,, /*bCancel*/ )

//oModel:SetDescription('Grupo Tributário')
If Alltrim(SX5->X5_TABELA) == '0A'
	oModel:SetDescription('Linha Peças' )	
ElseIf Alltrim(SX5->X5_TABELA) == '0B'
	oModel:SetDescription('Familia Peças' )	
ElseIf Alltrim(SX5->X5_TABELA) == '02'
	oModel:SetDescription('Tipo Peças' )	
EndIf

//Abaixo irei iniciar o campo X5_TABELA com o conteudo da sub-tabela
oStr1:SetProperty('X5_TABELA' , MODEL_FIELD_INIT, {|| SX5->X5_TABELA } )  //{||'21'} )
 
//Abaixo irei bloquear/liberar os campos para edição
oStr1:SetProperty('X5_TABELA' , MODEL_FIELD_WHEN,{|| .F. })
 
//Podemos usar as funções INCLUI ou ALTERA
//oStr1:SetProperty('X5_CHAVE'  , MODEL_FIELD_WHEN,{|| INCLUI })
 
//Ou usar a propriedade GetOperation que captura a operação que está sendo executada
oStr1:SetProperty("X5_CHAVE"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })
	
//oStr1:RemoveField( 'X5_DESCENG' )
//oStr1:RemoveField( 'X5_DESCSPA' )
oStr1:RemoveField( 'X5_FILIAL' )
	
// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:addFields('CamposSX5',,oStr1,{|oModel|ZPECF014T(oModel)},,)
	
//Define a chave primaria utilizada pelo modelo
oModel:SetPrimaryKey({'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE' })
	
// Adiciona a descricao do Componente do Modelo de Dados
oModel:getModel('CamposSX5'):SetDescription('TabelaSX5')
	
Return oModel

//Esta função será executada no inicio do carregamento da tela, neste exemplo irei
//apenas armazenar numa variável o conteudo de um campo
Static Function ZPECF014T( oModel )

Local lRet      := .T.
Local oModelSX5 := oModel:GetModel( 'CamposSX5' )
	
cChaveAux := SX5->X5_CHAVE
 
Return(lRet)

//-------------------------------------------------------------------
// Validações ao salvar registro
// Input: Model
// Retorno: Se erros foram gerados ou não
//-------------------------------------------------------------------
Static Function ZPECF014V( oModel )

Local lRet      := .T.
Local oModelSX5 := oModel:GetModel( 'CamposSX5' )
Local nOpc      := oModel:GetOperation()
Local aArea     := GetArea()
 
//Capturar o conteudo dos campos
Local cChave	:= oModelSX5:GetValue('X5_CHAVE'  )
Local cTabela	:= oModelSX5:GetValue('X5_TABELA' )
Local cDescri	:= oModelSX5:GetValue('X5_DESCRI' )
Local cDescrEng	:= oModelSX5:GetValue('X5_DESCENG')
Local cDescrSpa	:= oModelSX5:GetValue('X5_DESCSPA')

Begin Transaction
		
	If nOpc == 3 .or. nOpc == 4
		If Empty(cTabela)
			oModelSX5:SetValue('X5_TABELA',SX5->X5_TABELA) //'21')
		EndIf
			
		DbSelectArea("SX5")
		SX5->(DbSetOrder(1))
		SX5->(DbGoTop())
		If (SX5->(DbSeek(xFilial("SX5")+cTabela+cChave)))
			if cChaveAux != cChave
				SFCMsgErro("A chave "+Alltrim(cChave)+" ja foi informada!","ZPECF014")
				lRet := .F.
			EndIf
		EndIf
 
		If Empty(cChave)
			SFCMsgErro("O campo chave é obrigatório!","ZPECF014")
			lRet := .F.
		EndIf
			
		If Empty(cDescri)
			SFCMsgErro("O campo descrição é obrigatório!","ZPECF014")
			lRet := .F.
		EndIf			

		If Empty(cDescrEng)
			SFCMsgErro("O campo Desc. English é obrigatório!","ZPECF014")
			lRet := .F.
		EndIf			

		If Empty(cDescrSpa)
			SFCMsgErro("O campo Desc. Spanish é obrigatório!","ZPECF014")
			lRet := .F.
		EndIf
	EndIf
		
	If !lRet
		DisarmTransaction()
	EndIf
		
End Transaction
	
RestArea(aArea)
	
FwModelActive( oModel, .T. )
	
Return lRet

//Chamar a função pelo menu com os parâmetros 
User Function ZSX5LIN()

Local aArea         := SX5->(GetArea())
Private oBrowse
Private cChaveAux   := ""

//Iniciamos a construção básica de um Browse.
oBrowse := FWMBrowse():New()
 
//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
oBrowse:SetAlias("SX5")
 
//Definimos o título que será exibido como método SetDescription
oBrowse:SetDescription("Linha Peças")
oBrowse:SetMenudef("ZPECF014") 	
//Adiciona um filtro ao browse
oBrowse:SetFilterDefault( "X5_TABELA == '0A'" )
	
//Desliga a exibição dos detalhes
//oBrowse:DisableDetails()
	
//Ativamos a classe
oBrowse:Activate()
RestArea(aArea)

Return

User Function ZSX5FAM()

Local aArea         := SX5->(GetArea())
Private oBrowse
Private cChaveAux   := ""

//Iniciamos a construção básica de um Browse.
oBrowse := FWMBrowse():New()
 
//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
oBrowse:SetAlias("SX5")
 
//Definimos o título que será exibido como método SetDescription
oBrowse:SetDescription("Familia Peças")
oBrowse:SetMenudef("ZPECF014") 	
//Adiciona um filtro ao browse
oBrowse:SetFilterDefault( "X5_TABELA == '0B'" )
	
//Desliga a exibição dos detalhes
//oBrowse:DisableDetails()
	
//Ativamos a classe
oBrowse:Activate()
RestArea(aArea)

Return

User Function ZSX5TIP()

Local aArea         := SX5->(GetArea())
Private oBrowse
Private cChaveAux   := ""

//Iniciamos a construção básica de um Browse.
oBrowse := FWMBrowse():New()
 
//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
oBrowse:SetAlias("SX5")
 
//Definimos o título que será exibido como método SetDescription
oBrowse:SetDescription("Tipo Peças")
oBrowse:SetMenudef("ZPECF014") 	
//Adiciona um filtro ao browse
oBrowse:SetFilterDefault( "X5_TABELA == '02'" )
	
//Desliga a exibição dos detalhes
//oBrowse:DisableDetails()
	
//Ativamos a classe
oBrowse:Activate()
RestArea(aArea)

Return
