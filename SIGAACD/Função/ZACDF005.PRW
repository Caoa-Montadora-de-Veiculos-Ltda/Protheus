#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZACDF005
Rdmake 	Log de movimentação de Veiculo produção para Gabardo
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC - Denilso 
@single		15/09/2020
@version    Nao Informado
@since      Nao Informado  
@return    	Nil
@sample     Nao Informado
@obs        
@project    CAOA - Automatizar o processo de movimentação veiculo para Gabardo
@menu       Nao Informado
@history    

/*/


User Function ZACDF005()
Local _aPergs   	:= {}
Local _aComboOrigem := {}
Local _aComboStatus	:= {}
Local _aRet 		:= {}
Local _aArea 	    := GetArea()
Local _lZACDF005    := SuperGetMV( "CMV_ACD002"  ,,.T.)  //parametro para habilitar/desabilitar funcionalidade
Begin Sequence

    //Caso esteja desabilitado parametro
    If !_lZACDF005
        Break
    Endif
	DbSelectArea("SZW")
    SetFunName('ZACDF005')
	_aComboOrigem	:= ZACDF005CB("ZW_ORIGEM")
	If Len(_aComboOrigem) == 0
        Msgalert("Problemas encontrado, verificar com Adminstrador do Sistema formataçao do combo para o campo ZW_ORIGEM")
		Break
	EndIf
	_aComboStatus 	:= ZACDF005CB("ZW_STATUS")
	If Len(_aComboStatus) == 0
        Msgalert("Problemas encontrado, verificar com Adminstrador do Sistema formataçao do combo para o campo ZW_STATUS")
		Break
	EndIf

	//aguardar versão 2
	//aAdd(_aPergs, {2 ,"Selecione Origem" ,"Origem Movimento" 	,_aComboOrigem ,70 ,"" ,.F. })
	aAdd(_aPergs, {2 ,"Selecione Status" ,"Entrada de Veículos ACD" ,_aComboStatus ,70 ,"" ,.F. })
	If !ParamBox( _aPergs ,"Parametros" ,@_aRet )
       	Break
   	EndIf
	If Len(_aRet) < 1  //Não foi preenchido todos os campos
        Msgalert("Necessário informar todas as opções")
		Break
	EndIf
	//ZACDF005TE(_aRet[1],_aRet[2])
	ZACDF005TE(/*ORIGEM*/ ,_aRet[1])

End Sequence
RestArea(_aArea)
Return Nil


//Retornar o combom box para seleção
Static Function ZACDF005CB(_cCampo)
Local _aRet 		:= {}
Local _nOrderSX3	:= SX3->(DbSetOrder())
Begin Sequence
	SX3->(DbSetOrder(2))
	SX3->(DbSeek(_cCampo))
	_aRet := StrTokArr(AllTrim(SX3->X3_CBOX),";")
	//Adiciono opção para todos
	Aadd(_aRet,"T=Todos")
End Sequence
SX3->(DbSetOrder(_nOrderSX3))
Return _aRet


Static Function ZACDF005TE(_cComboOrigem,_cComboStatus)
Local _cFunNameBkp 	:= SetFunName()
Local _oBrw 		
//Local _lConboOrigem	:= _cComboOrigem == "T"   //o ultimo regeistro deve ser todos
Local _lComboStatus	:= _cComboStatus == "T"	 //o ultimo regeistro deve ser todos
Local _cCab			:= "Entrada de Veículos ACD"

SetFunName('ZACDF005')
Begin Sequence
	_oBrw := FWMBrowse():New()
    _oBrw:SetAlias("SZW")
  	_oBrw:SetMenuDef('ZACDF005') 
	_oBrw:SetUseFilter(.T.)
	_oBrw:DisableDetails() 
// Aguardar fase 2
//	_oBrw:AddLegend("ZW_ORIGEM =='P'","BLUE"  ,"Produção"	 	,/*ID*/, If(_lConboOrigem,.T.,.F.)/*Utiliza filtro*/) 
//	_oBrw:AddLegend("ZW_ORIGEM =='C'","RED"   ,"Carga"		 	,/*ID*/, If(_lConboOrigem,.T.,.F.)/*Utiliza filtro*/) 
	_oBrw:AddLegend("ZW_STATUS =='P'"	,"BLUE"  	,"Pendente"	 	,/*ID*/, If(_lComboStatus,.T.,.F.)/*Utiliza filtro*/) 
	_oBrw:AddLegend("ZW_STATUS =='L'"	,"GREEN"   	,"Liberado"	 	,/*ID*/, If(_lComboStatus,.T.,.F.)/*Utiliza filtro*/) 
	_oBrw:AddLegend("ZW_STATUS =='D'"   ,"RED"    	,"Divergente"	,/*ID*/, If(_lComboStatus,.T.,.F.)/*Utiliza filtro*/) 
	If _cComboStatus == "P"  //Pendente
		_oBrw:SetFilterDefault("AllTrim(SZW->ZW_STATUS) == 'P'")
		_cCab += " Liberado"
	ElseIf _cComboStatus == "L" //Liberado
		_oBrw:SetFilterDefault("AllTrim(SZW->ZW_STATUS) == 'L'")
		_cCab += " Liberados"
	ElseIf _cComboStatus == "D" //Divergente
		_oBrw:SetFilterDefault("AllTrim(SZW->ZW_STATUS) == 'D'")
		_cCab += " Divergente"
	Else
		//nao tem filtros para todos
		_cCab += " Todos"
	Endif
	_oBrw:SetDescription(_cCab) // Trilha de Segurança
	//_oBrw:SetFilterDefault( "@ ZW_ORIGEM == "+_cTipo ) 
   	_oBrw:Activate()
End Sequence
SetFunName(_cFunNameBkp)
Return Nil


//-------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef
@author DAC - Denilso
@since 01/09/2020
@version 1.0
/*/
//-------------------------------------
Static Function MenuDef()
Local _aRotina 	:= {}
Local _lZACDJ005    := SuperGetMV( "CMV_ACD005"  ,,.T.)  //Responsável por mostrar o botão para processamento pelo JOB de atualização da movimentação status 
//Local _aRotina := FWMVCMenu("ZCOMF022")
Begin Sequence	
	ADD OPTION _aRotina TITLE "Visualizar"		ACTION "U_ZACD005VI"	OPERATION 2 ACCESS 0
	If _lZACDJ005
		ADD OPTION _aRotina TITLE "Processar"	ACTION "U_ZACDJ005"		OPERATION 2 ACCESS 0
	EndIf
	ADD OPTION _aRotina TITLE "Pesquisar"  		ACTION 'PesqBrw' 		OPERATION 1 ACCESS 0
	//ADD OPTION _aRotina TITLE "Imprimir" 	ACTION "VIEWDEF.ZCOMF022" 	OPERATION 8 ACCESS 0
End Sequence
Return _aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author DAC- Denilso
@since 01/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
//bAvalCampo Bloco de Código de avaliação do dicionário de dados. O bloco recebe como parâmetro o ID do campo e deve retornar um lógico. Se retornar verdadeiro o campo é incluído na estrutura.
//lViewUsado indica que deverá considerar os campos que não estão marcados como usado no dicionário de dados. Utilizado somente para o tipo 2-Browse.
//lVirtual Indica que deverá considerar os campos virtuais no dicionário de dados. Utilizado somente para o tipo 2-Browse.
//lFilOnView Indica que deverá considerar o campo de filial na view.
//cProgram Nome do programa executado, quando for para abrir um browse, determina se deveremos considerar os campos localizados.

Local oStr1 := FWFormStruct( 1, 'SZW', /*bAvalCampo*/, /*lViewUsado*/,  /*lVirtual*/ , /*lFilOnView*/,/*cProgram*/) // Construção de uma estrutura de dados
Begin Sequence	
	//Cria o objeto do Modelo de Dados
    //Irie usar uma função QCP1VLD que será acionada quando eu clicar no botão "Confirmar"
	oModel := MPFormModel():New('ZACDF005MOD', /*bPreValidacao*/ , /*{ | oModel | QCP1VLD( oModel ) } */, /*{ | oMdl | MVC001C( oMdl ) }*/ ,, /*bCancel*/ )
	oModel:SetDescription('Entrada de Veículos ACD')
	
	//oStr1:setProperty("ZW_STATUS",MODEL_FIELD_WHEN,{||INCLUI})		

	//iniciar o campo X5_TABELA com o conteudo da sub-tabela
    //oStr1:SetProperty('ZH_ORIGEM' , MODEL_FIELD_INIT,{||dDataBase} )
    //bloquear/liberar os campos para edição
	//oStr1:SetProperty('*' , MODEL_FIELD_WHEN,{|| QCP1VLD(oModel) })
    //usar a propriedade GetOperation que captura a operação que está sendo executada
	//oStr1:SetProperty("ZH_ORIGEM"  , MODEL_FIELD_OBRIGAT,If(INCLUI .and. Empty(M->ZH_ORIGEM),.T.,.F.))

    //usar as funções INCLUI ou ALTERA
	//oStr1:SetProperty('ZH_ORIGEM'  , MODEL_FIELD_WHEN,{|| INCLUI })
    //Ou usar a propriedade GetOperation que captura a operação que está sendo executada
	//oStr1:SetProperty("ZH_ORIGEM"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })
	//Remover Campos
	//oStr1:RemoveField( 'ZH_ORIGEM' )
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	//oModel:addFields('SZHMASTER',,oStr1,{|oModel|QCP1MODE(oModel)},,)
	
	oModel:addFields('SZHMASTER',,oStr1)
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:addFields('SZHMASTER',,oStr1,/*{|oModel|MntModel(oModel)}*/,,)
	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'ZW_FILIAL', 'ZW_ORIGEM', "ZW_STATUS" })
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('SZHMASTER'):SetDescription('Entrada de Veículos ACD')
End Begin	
Return oModel

/*
//Esta função será executada no inicio do carregamento da tela, neste exemplo irei
//apenas armazenar numa variável o conteudo de um campo
Static Function MntModel( oModel )
	Local lRet      := .T.
	Local oModelSZH := oModel:GetModel( 'SZHMASTER' )
Return(lRet)
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author denilso.almeida
@since 05/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
// Inicia a View com uma View ja existente
//Local oStr1		:= FWFormStruct(2, 'SZW')
Local oModel 	:= ModelDef()
Local oStr1		:= FWFormStruct(2,'SZW',{|cCampo| AllTrim(cCampo) $ "ZW_FILIAL|ZW_CHASSI|ZW_CODPROD|ZW_DESCPRD|ZW_STATUS|ZW_MOMUSU|ZW_CODUSU|ZW_DATALEI|ZW_HORALEI|ZW_DTMOVIM|ZW_HRMOVIM"})
Local oView 	

Begin Sequence
	oView 	:= FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_SZW" , oStr1,"SZHMASTER" )
	oView:CreateHorizontalBox( "BOXFORM1", 100)
	oView:SetOwnerView("VIEW_SZW","BOXFORM1")
	oView:SetDescription('Movimentação de Veículos')
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
End Sequence
Return oView

//Entrada de Veículos ACD
User Function ZACD005VI()

Private  cCadastro := "Entrada de Veículos ACD"
AxVisual("SZW",SZW->( RecNo() ),2)
Return Nil


