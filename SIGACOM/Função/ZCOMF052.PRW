#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "TOTVS.CH"

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZCOMF052
Rdmake 	Visualiza��o do Log de Altera��o do Cadastro de Produto
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     Sandro Ferreira
@single		21/09/2023
@version    Nao Informado
@since      Nao Informado  
@return    	Nil
@sample     Nao Informado
@obs         
@project	GRUPO CAOA GAP Work Flow do Cadastro de Produtos -  [ Barueri ]
@menu       Nao Informado
@history    

/*/


User Function ZCOMF052()
//Local _cFunNameBkp 	:= SetFunName()
Local _aArea2 	    := GetArea()
Local _cTitulo		:= "Log de Altera��o de Produtos"
Local _lRet			:= .T.
//Local _aRotAnt		:= aRotina
Local _oBrw

Private aRotina    := MenuDef() 

Begin Sequence

		_lRet := U_ZGENUSER( RetCodUsr() ,"ZCOMF052" ,.T.)
		If !_lRet
			Break
		Endif 
		//_cProduto := SB1->B1_COD
		SetFunName('ZCOMF052')
		DBSELECTAREA('ZZ4')	// Cadastro monitor
		_oBrw := FWMBrowse():New()
		_oBrw:SetAlias("ZZ4")
		_oBrw:SetMenuDef("ZCOMF052")
		_oBrw:SetDescription(_cTitulo) 
		_oBrw:SetUseFilter(.T.)
		_oBrw:SetLocate()
		_oBrw:DisableDetails()
		_oBrw:SetAmbiente(.F.)
		_oBrw:SetWalkThru(.F.)	
		//_oBrw:SetFilterDefault( "ZZ4_COD == '" +_cProduto+"'" ) 
		_oBrw:Activate()

End Sequence 
//aRotina := _aRotAnt		 
//SetFunName(_cFunNameBkp)
RestArea(_aArea2)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Sandro Ferreira
@since 21/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local _oView
Local _oModel := ModelDef()
Local _oStr1:= FWFormStruct(2, 'ZZ4')
Begin Sequence	
	// Cria o objeto de View
	_oView := FWFormView():New()
	// Define qual o Modelo de dados será utilizado
	_oView:SetModel(_oModel)
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	_oView:AddField('Formulario' , _oStr1,'CamposZZ4' )
    //Remove os campos que não irão aparecer	
	//_oStr1:RemoveField( 'SZ2_' )	
	// Criar um "box" horizontal para receber algum elemento da view
	_oView:CreateHorizontalBox( 'PAI', 80)
	// Relaciona o ID da View com o "box" para exibicao
	_oView:SetOwnerView('Formulario','PAI')
	_oView:EnableTitleView('Formulario' , 'Log Altera��o Produtos' )	
	//Força o fechamento da janela na confirmação
	_oView:SetCloseOnOk({||.T.})
End Begin	
Return _oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Sandro Ferreira
@since 21/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local _oModel
Local _oStr1:= FWFormStruct( 1, 'ZZ4', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados
Begin Sequence	
	//Cria o objeto do Modelo de Dados
    //Irie usar uma função QCP1VLD que será acionada quando eu clicar no botão "Confirmar"
	_oModel := MPFormModel():New('Log Altera��o Produtos', /*bPreValidacao*/ , /*{ | _oModel | QCP1VLD( _oModel ) } */, { | _oModel | FGrava( _oModel ) } ,, /*bCancel*/ )
	_oModel:SetDescription('Log Altera��o Produto')
	//oStr1:RemoveField( 'ZA2_FILIAL' )
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	_oModel:addFields('CamposZZ4',,_oStr1,{|_oModel|ZCOMF052(_oModel)},,)
	//Define a chave primaria utilizada pelo modelo
	_oModel:SetPrimaryKey({'R_E_C_N_O_' })
	// Adiciona a descricao do Componente do Modelo de Dados
	_oModel:getModel('CamposZZ4'):SetDescription('Cadastro Integra��o/Atera��o')
End Begin	
Return _oModel

//Esta função será executada no inicio do carregamento da tela, neste exemplo irei
//apenas armazenar numa variável o conteudo de um campo
Static Function ZCOMF052( _oModel )
Local _lRet      := .T.
//Local _oModelSZ2 := _oModel:GetModel( 'CamposSZ2' )
Return(_lRet)


//-------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef
@author Sandro Ferreira
@since 21/09/2023
@version 1.0
/*/
Static Function MenuDef()
Local _aRotina := {}
Begin Sequence
	ADD OPTION _aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ZCOMF052" 	OPERATION 2 ACCESS 0
	ADD OPTION _aRotina TITLE "Imprimir" 	ACTION "VIEWDEF.ZCOMF052" 	OPERATION 8 ACCESS 0
End Sequence	
Return _aRotina
