/*Importar as bibliotecas*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZPCPF011
Rdmake 	responsavel ETAPAS DE PRODUCAO  SZE
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC Denilso 
@single		05/08/2019
@version    Nao Informado
@since      Nao Informado  
@return    	Logico
@sample     Nao Informado
@obs        
@project    CAOA - Processo Backflush 3_0 DEV01 - Especifica��o Funcional Correto_V2
@menu       Nao Informado
@history    
--------------------------------------------------------------------------------------*/

/*Iniciando sua fun��o*/
User Function ZPCPF011()
Local _aArea 		:= SX5->(GetArea())
Local _cFunNameBkp 	:= SetFunName()
Local oBrowse
Begin Sequence
	SetFunName('ZPCPF011')
  	DBSELECTAREA('SZE') //ETAPA DE PRODU��O
  	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZE")
	oBrowse:SetOnlyFields( {"ZE_FILIAL"	,;
							"ZE_CODIGO"		,;
							"ZE_DESC"		,;
							"ZE_SEQ"		,;
							"ZE_AGRUPA"		,;
							"ZE_LOTEMIN"	;
							 } )
    //Definimos o t�tulo que ser� exibido como m�todo SetDescription
	oBrowse:SetDescription("Etapa de Produ��o")
    //Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
	oBrowse:SetAlias("SZE")
	//Legenda da grade, � obrigat�rio carregar antes de montar as colunas
	//oBrowse:AddLegend("SZE->SZE_=='2'","RED" 	   ,"Previs�o Finalizada")

//	Adiciona um filtro ao browse
//   oBrowse:SetFilterDefault( "SZE_ = '"+Space(8)+"' " ) //Exemplo de como inserir um filtro padr�o >>> "TR_ST == 'A'"
//	Desliga a exibi��o dos detalhes
//	oBrowse:DisableDetails()
//    Ativamos a classe
	oBrowse:Activate()
End Sequence
SetFunName(_cFunNameBkp)
RestArea(_aArea)
Return Nil


//-------------------------------------------------------------------
// Montar o menu Funcional
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Begin Sequence
	ADD OPTION aRotina TITLE "Pesquisar"  	ACTION 'PesqBrw' 		  OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ZPCPF011" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    	ACTION "VIEWDEF.ZPCPF011" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    	ACTION "VIEWDEF.ZPCPF011" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    	ACTION "VIEWDEF.ZPCPF011" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir" 	ACTION "VIEWDEF.ZPCPF011" OPERATION 8 ACCESS 0
	//ADD OPTION aRotina TITLE "Copiar" 		ACTION "VIEWDEF.QACOMAP1" OPERATION 9 ACCESS 0
	//ADD OPTION aRotina TITLE "Legenda" 	    ACTION "U_QCP1LEG" 		  OPERATION 6 ACCESS 0
End Sequence	
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface
@author DAC- Denilso
@since 05/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'SZE')
Begin Sequence	
	// Cria o objeto de View
	oView := FWFormView():New()
	// Define qual o Modelo de dados ser� utilizado
	oView:SetModel(oModel)
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('Formulario' , oStr1,'CamposSZE' )
    //Remove os campos que n�o ir�o aparecer	
	//oStr1:RemoveField( 'SZE_' )	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'PAI', 100)
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('Formulario','PAI')
	oView:EnableTitleView('Formulario' , 'Sequencia de Produ��o' )	
	oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})
	//oView:SetViewCanActivate( MODEVLDCPO(oModel))
	//For�a o fechamento da janela na confirma��o
	oView:SetCloseOnOk({||.T.})
End Begin	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados
@author DAC- Denilso
@since 01/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStr1:= FWFormStruct( 1, 'SZE', /*bAvalCampo*/,/*lViewUsado*/ ) // Constru��o de uma estrutura de dados
Begin Sequence	
	//Cria o objeto do Modelo de Dados
    //Irie usar uma fun��o MODEVLDCPO que ser� acionada quando eu clicar no bot�o "Confirmar"
	oModel := MPFormModel():New('Sequencia de Produ��o', /*bPreValidacao*/ , { | oModel | MODEVLDCPO( oModel ) } , /*{ | oMdl | MVC001C( oMdl ) }*/ ,, /*bCancel*/ )
	oModel:SetDescription('Etapa de Produ��o')
    //bloquear/liberar os campos para edi��o
	//oStr1:SetProperty ( 'ZE_CODIGO', MODEL_FIELD_INIT , NIL )
	oStr1:SetProperty('*' , MODEL_FIELD_WHEN,{|| MODEVLDCPO(oModel) })
	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:addFields('CamposSZE',,oStr1,{|oModel|MODECARCPO(oModel)},,)
	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'ZE_FILIAL', 'ZE_CODIGO' })
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('CamposSZE'):SetDescription('Etapa de Produ��o')
End Begin	
Return oModel

//============================================================================================
//Esta fun��o ser� executada no inicio do carregamento da tela, neste exemplo irei
//apenas armazenar numa vari�vel o conteudo de um campo
//============================================================================================
Static Function MODECARCPO( oModel )
Local lRet      := .T.
Local oModelSZE 
oModelSZE := oModel:GetModel( 'CamposSZE' )
Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} MODEVLDCPO
Valida��es ao salvar registro
@author denilso.almeida
@since 05/06/2017
@version 1.0
@Obs Retorno: Se erros foram gerados ou n�o
/*/
//-------------------------------------------------------------------

Static Function MODEVLDCPO( oModel )
Local lRet      := .T.
//Local oModelSZE := oModel:GetModel( 'CamposSZE' )
//Local nOpc      := oModel:GetOperation()
//Capturar o conteudo dos campos
Begin Sequence
	//If nOpc == 4 .AND. SZE->SZE_ == "2"
		//Help( ,,"Aten��o", , "Campo n�o pode ser alterado!!",1,0)
	//	lRet := .F.
	//EndIf 
		
End Begin	
FwModelActive( oModel, .T. )
Return(lRet)




//inicializar SZE quando inclus�o
Static Function INITZECOD()
Local _cAliasTRB    := GetNextAlias()
Local _cCodRet		:= ""      
Local _cZero		:= StrZero(0,Len(SZE->ZE_CODIGO))
Begin Sequence
	If !Inclui
		_cCodRet := SZE->ZE_COD
		Break
	EndIf	
	BeginSql Alias _cAliasTRB //Define o nome do alias tempor�rio 
		SELECT  ISNULL(MAX(SZE.ZE_CODIGO),%Exp:_cZero%) CCODIGO
		FROM 	%Table:SZE% SZE
        WHERE	SZE.ZE_FILIAL	    =  %xFilial:SZE%  					
				AND SZE.%notDel% 
  	EndSql //Gera a consulta no alias informado anteriormente 
	_cCodRet :=  Soma1(AllTrim((_cAliasTRB)->CCODIGO))
End Sequence
If Select((_cAliasTRB)) <> 0
	(_cAliasTRB)->(DbCloseArea())
	Ferase(_cAliasTRB+GetDBExtension())
Endif      
Return _cCodRet
