#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "TOTVS.CH"

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZCRMFLLC
Rdmake 	Visualização Log de Alteração Limite de Crédito
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC - Denilso 
@single		11/04/2023
@version    Nao Informado
@since      Nao Informado  
@return    	Nil
@sample     Nao Informado
@obs         
@project	GRUPO CAOA GAP FIN108 - Revitalização Credito [ Montadora ]
@menu       Nao Informado
@history    

/*/


User Function ZCRMFLLC()
//Local _cFunNameBkp 	:= SetFunName()
Local _aArea 	    := GetArea()
Local _cTitulo		:= "Log de Alteração Cliente"
Local _lRet			:= .T.
Local _aRotAnt		:= aRotina
Local _oBrw

Private aRotina    := MenuDef() 

Begin Sequence
	_lRet := U_ZGENUSER( RetCodUsr() ,"ZCRMFLLC" ,.T.)
	If !_lRet
		Break
	Endif 
	_cCliente := SA1->A1_COD
	SetFunName('ZCRMFLLC')
  	DBSELECTAREA('SZ2')	// Cadastro monitor
	_oBrw := FWMBrowse():New()
    _oBrw:SetAlias("ZA2")
	_oBrw:SetMenuDef("ZCRMFLLC")
	_oBrw:SetDescription(_cTitulo) 
	_oBrw:SetUseFilter(.T.)
	_oBrw:SetLocate()
	_oBrw:DisableDetails()
	_oBrw:SetAmbiente(.F.)
	_oBrw:SetWalkThru(.F.)	
	_oBrw:SetFilterDefault( "ZA2_CLIENT == '" +_cCliente+"'" ) 
   	_oBrw:Activate()
End Sequence
aRotina := _aRotAnt		 
//SetFunName(_cFunNameBkp)
RestArea(_aArea)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author DAC- Denilso
@since 05/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local _oView
Local _oModel := ModelDef()
Local _oStr1:= FWFormStruct(2, 'ZA2')
Begin Sequence	
	// Cria o objeto de View
	_oView := FWFormView():New()
	// Define qual o Modelo de dados será utilizado
	_oView:SetModel(_oModel)
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	_oView:AddField('Formulario' , _oStr1,'CamposZA2' )
    //Remove os campos que não irão aparecer	
	//_oStr1:RemoveField( 'SZ2_' )	
	// Criar um "box" horizontal para receber algum elemento da view
	_oView:CreateHorizontalBox( 'PAI', 80)
	// Relaciona o ID da View com o "box" para exibicao
	_oView:SetOwnerView('Formulario','PAI')
	_oView:EnableTitleView('Formulario' , 'Log Alteração Cliente' )	
	//Força o fechamento da janela na confirmação
	_oView:SetCloseOnOk({||.T.})
End Begin	
Return _oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author DAC- Denilso
@since 11/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local _oModel
Local _oStr1:= FWFormStruct( 1, 'ZA2', /*bAvalCampo*/,/*lViewUsado*/ ) // Construção de uma estrutura de dados
Begin Sequence	
	//Cria o objeto do Modelo de Dados
    //Irie usar uma função QCP1VLD que será acionada quando eu clicar no botão "Confirmar"
	_oModel := MPFormModel():New('Log Alteração Cliente', /*bPreValidacao*/ , /*{ | _oModel | QCP1VLD( _oModel ) } */, { | _oModel | FGrava( _oModel ) } ,, /*bCancel*/ )
	_oModel:SetDescription('Log Alteração Cliente')
	//oStr1:RemoveField( 'ZA2_FILIAL' )
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	_oModel:addFields('CamposZA2',,_oStr1,{|_oModel|ZCRMFLLCVC(_oModel)},,)
	//Define a chave primaria utilizada pelo modelo
	_oModel:SetPrimaryKey({'R_E_C_N_O_' })
	// Adiciona a descricao do Componente do Modelo de Dados
	_oModel:getModel('CamposZA2'):SetDescription('Cadastro Integração')
End Begin	
Return _oModel

//Esta função será executada no inicio do carregamento da tela, neste exemplo irei
//apenas armazenar numa variável o conteudo de um campo
Static Function ZCRMFLLCVC( _oModel )
Local _lRet      := .T.
//Local _oModelSZ2 := _oModel:GetModel( 'CamposSZ2' )
Return(_lRet)


//-------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef
@author DAC - Denilso
@since 11/04/2023
@version 1.0
/*/
Static Function MenuDef()
Local _aRotina := {}
Begin Sequence
	ADD OPTION _aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ZCRMFLLC" 	OPERATION 2 ACCESS 0
	ADD OPTION _aRotina TITLE "Imprimir" 	ACTION "VIEWDEF.ZCRMFLLC" 	OPERATION 8 ACCESS 0
End Sequence	
Return _aRotina




