#Include 'parmtype.ch'
#Include "PROTHEUS.CH"
#Include "FWMBROWSE.CH"
#Include "FWMVCDEF.CH"
 
/*Iniciando sua fun��o*/
User Function ZPECF014(cTabela, cTitRot)

/*Declarando as vari�veis que ser�o utilizadas*/
Local aArea         := SX5->(GetArea())
Private oBrowse
Private cChaveAux   := ""
//Private aRotina	 	:= Menudef()

//Iniciamos a constru��o b�sica de um Browse.
oBrowse := FWMBrowse():New()
 
//Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
oBrowse:SetAlias("SX5")
 
//Definimos o t�tulo que ser� exibido como m�todo SetDescription
oBrowse:SetDescription("Grupo Tribut�rio")
oBrowse:SetMenudef("ZPECF014") 	
//Adiciona um filtro ao browse
oBrowse:SetFilterDefault( "X5_TABELA == '0A'" )
	
//Desliga a exibi��o dos detalhes
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
	
// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)
	
//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('Formulario' , oStr1,'CamposSX5' )
 
//Remove os campos que n�o ir�o aparecer	
//oStr1:RemoveField( 'X5_DESCENG' )
//oStr1:RemoveField( 'X5_DESCSPA' )
	
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'PAI', 100)
	
// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('Formulario','PAI')

//oView:EnableTitleView('Formulario' , 'Grupo Tribut�rio' )	
If Alltrim(SX5->X5_TABELA) == '0A'
	oView:EnableTitleView('Formulario' , 'Linha Pe�as' )	
ElseIf Alltrim(SX5->X5_TABELA) == '0B'
	oView:EnableTitleView('Formulario' , 'Familia Pe�as' )	
ElseIf Alltrim(SX5->X5_TABELA) == '02'
	oView:EnableTitleView('Formulario' , 'Tipo Pe�as' )	
EndIf
oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})
	
//For�a o fechamento da janela na confirma��o
oView:SetCloseOnOk({||.T.})
	
Return oView

Static Function ModelDef()

Local oModel
Local oStr1:= FWFormStruct( 1, 'SX5', /*bAvalCampo*/,/*lViewUsado*/ ) // Constru��o de uma estrutura de dados
	
//Cria o objeto do Modelo de Dados
//Irie usar uma fun��o ZPECF014V que ser� acionada quando eu clicar no bot�o "Confirmar"
oModel := MPFormModel():New('GrupoTributario', /*bPreValidacao*/, { | oModel | ZPECF014V(oModel) } , /*{ | oMdl | ZPECF014C( oMdl ) }*/ ,, /*bCancel*/ )

//oModel:SetDescription('Grupo Tribut�rio')
If Alltrim(SX5->X5_TABELA) == '0A'
	oModel:SetDescription('Linha Pe�as' )	
ElseIf Alltrim(SX5->X5_TABELA) == '0B'
	oModel:SetDescription('Familia Pe�as' )	
ElseIf Alltrim(SX5->X5_TABELA) == '02'
	oModel:SetDescription('Tipo Pe�as' )	
EndIf

//Abaixo irei iniciar o campo X5_TABELA com o conteudo da sub-tabela
oStr1:SetProperty('X5_TABELA' , MODEL_FIELD_INIT, {|| SX5->X5_TABELA } )  //{||'21'} )
 
//Abaixo irei bloquear/liberar os campos para edi��o
oStr1:SetProperty('X5_TABELA' , MODEL_FIELD_WHEN,{|| .F. })
 
//Podemos usar as fun��es INCLUI ou ALTERA
//oStr1:SetProperty('X5_CHAVE'  , MODEL_FIELD_WHEN,{|| INCLUI })
 
//Ou usar a propriedade GetOperation que captura a opera��o que est� sendo executada
oStr1:SetProperty("X5_CHAVE"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })
	
//oStr1:RemoveField( 'X5_DESCENG' )
//oStr1:RemoveField( 'X5_DESCSPA' )
oStr1:RemoveField( 'X5_FILIAL' )
	
// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:addFields('CamposSX5',,oStr1,{|oModel|ZPECF014T(oModel)},,)
	
//Define a chave primaria utilizada pelo modelo
oModel:SetPrimaryKey({'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE' })
	
// Adiciona a descricao do Componente do Modelo de Dados
oModel:getModel('CamposSX5'):SetDescription('TabelaSX5')
	
Return oModel

//Esta fun��o ser� executada no inicio do carregamento da tela, neste exemplo irei
//apenas armazenar numa vari�vel o conteudo de um campo
Static Function ZPECF014T( oModel )

Local lRet      := .T.
Local oModelSX5 := oModel:GetModel( 'CamposSX5' )
	
cChaveAux := SX5->X5_CHAVE
 
Return(lRet)

//-------------------------------------------------------------------
// Valida��es ao salvar registro
// Input: Model
// Retorno: Se erros foram gerados ou n�o
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
			SFCMsgErro("O campo chave � obrigat�rio!","ZPECF014")
			lRet := .F.
		EndIf
			
		If Empty(cDescri)
			SFCMsgErro("O campo descri��o � obrigat�rio!","ZPECF014")
			lRet := .F.
		EndIf			

		If Empty(cDescrEng)
			SFCMsgErro("O campo Desc. English � obrigat�rio!","ZPECF014")
			lRet := .F.
		EndIf			

		If Empty(cDescrSpa)
			SFCMsgErro("O campo Desc. Spanish � obrigat�rio!","ZPECF014")
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

//Chamar a fun��o pelo menu com os par�metros 
User Function ZSX5LIN()

Local aArea         := SX5->(GetArea())
Private oBrowse
Private cChaveAux   := ""

//Iniciamos a constru��o b�sica de um Browse.
oBrowse := FWMBrowse():New()
 
//Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
oBrowse:SetAlias("SX5")
 
//Definimos o t�tulo que ser� exibido como m�todo SetDescription
oBrowse:SetDescription("Linha Pe�as")
oBrowse:SetMenudef("ZPECF014") 	
//Adiciona um filtro ao browse
oBrowse:SetFilterDefault( "X5_TABELA == '0A'" )
	
//Desliga a exibi��o dos detalhes
//oBrowse:DisableDetails()
	
//Ativamos a classe
oBrowse:Activate()
RestArea(aArea)

Return

User Function ZSX5FAM()

Local aArea         := SX5->(GetArea())
Private oBrowse
Private cChaveAux   := ""

//Iniciamos a constru��o b�sica de um Browse.
oBrowse := FWMBrowse():New()
 
//Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
oBrowse:SetAlias("SX5")
 
//Definimos o t�tulo que ser� exibido como m�todo SetDescription
oBrowse:SetDescription("Familia Pe�as")
oBrowse:SetMenudef("ZPECF014") 	
//Adiciona um filtro ao browse
oBrowse:SetFilterDefault( "X5_TABELA == '0B'" )
	
//Desliga a exibi��o dos detalhes
//oBrowse:DisableDetails()
	
//Ativamos a classe
oBrowse:Activate()
RestArea(aArea)

Return

User Function ZSX5TIP()

Local aArea         := SX5->(GetArea())
Private oBrowse
Private cChaveAux   := ""

//Iniciamos a constru��o b�sica de um Browse.
oBrowse := FWMBrowse():New()
 
//Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
oBrowse:SetAlias("SX5")
 
//Definimos o t�tulo que ser� exibido como m�todo SetDescription
oBrowse:SetDescription("Tipo Pe�as")
oBrowse:SetMenudef("ZPECF014") 	
//Adiciona um filtro ao browse
oBrowse:SetFilterDefault( "X5_TABELA == '02'" )
	
//Desliga a exibi��o dos detalhes
//oBrowse:DisableDetails()
	
//Ativamos a classe
oBrowse:Activate()
RestArea(aArea)

Return
