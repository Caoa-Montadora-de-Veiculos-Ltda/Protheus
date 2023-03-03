#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZCOMF022 
Rdmake 	Menu Trilha de Segurança
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC Denilso 
@version    Nao Informado
@since      05/08/2019  
@return    	Logico
@sample     Nao Informado
@obs        Chamada via menu
@project    CAOA
@menu       Nao Informado
@history    
--------------------------------------------------------------------------------------*/

/*Iniciando sua função*/
User Function ZCOMF022()
Local _aArea 	    := GetArea()
Local _lZCONF022    := SuperGetMV( "CMV_COM005"  ,,.T.)  //parametro para habilitar/desabilitar funcionalidade
Local _aPergs   	:= {}
Local _aCombo    	:= {"Pedido de Compra", "Solicitação de Compra", "Autorização de Entrega", "Contrato de Parceria"}
Local _aRet      	:= {}
//Local _oBrw 		:= FwLoadBrw("ZCOMF022") 
Local _cFunNameBkp 	:= SetFunName()
Local _oBrw 		
Local _cTipo

Begin Sequence
	//U_ZACDF005()
    //Caso esteja desabilitado parametro
    If !_lZCONF022
        Break
    Endif

	DbSelectArea("SZH")
    SetFunName('ZCOMF022')
	aAdd(_aPergs, {2 ,"Seleção do tipo documento" ,"Tipo de Documentos" ,_aCombo ,70 ,"" ,.F. })
	If !ParamBox( _aPergs ,"Parametros" ,@_aRet )
       	Break
   	EndIf

	//ZCOMF022FB(_aRet,_aCombo)
	_oBrw := FWMBrowse():New()
    _oBrw:SetAlias("SZH")
	_oBrw:SetDescription("Trilha de Segurança") // Trilha de Segurança
	_oBrw:AddLegend("ZH_ORIGEM=='PC'","BLUE"  ,"Pedido de Venda"		 	,/*ID*/, .F./*Utiliza filtro*/) // Pedido de Venda
	_oBrw:AddLegend("ZH_ORIGEM=='SC'","GREEN" ,"Solicitação de Compras"	,/*ID*/, .F. /*Utiliza filtro*/) // Solicitação de Compras
	_oBrw:AddLegend("ZH_ORIGEM=='AE'","RED"   ,"Autorização de Entrega"	,/*ID*/, .F. /*Utiliza filtro*/) // Autorização de Entrega
	_oBrw:AddLegend("ZH_ORIGEM=='CP'","GRAY"  ,"Contrato Parceria"		,/*ID*/, .F. /*Utiliza filtro*/) //Contrato Parceria
  	_oBrw:SetMenuDef('ZCOMF022') 
	_oBrw:SetUseFilter(.T.)
	_oBrw:DisableDetails() 
		
	If _aRet[1] == _aCombo[1] //--Com erro
		_oBrw:SetFilterDefault("AllTrim(SZH->ZH_ORIGEM) == 'PC'")
		_cTipo := "Pedido de Compras"
	ElseIf _aRet[1] == _aCombo[2] //--Não executada
		_oBrw:SetFilterDefault("AllTrim(SZH->ZH_ORIGEM) == 'SC'")	
		_cTipo := "Solicitação de Compras"
	ElseIf _aRet[1] == _aCombo[3] //--Finalizada
		_oBrw:SetFilterDefault("AllTrim(SZH->ZH_ORIGEM) == 'AE'")
		_cTipo := "Autorização Entrega"
	ElseIf _aRet[1] == _aCombo[4] //--O.S. Erro Não Catalogado
		_oBrw:SetFilterDefault("AllTrim(SZH->ZH_ORIGEM) == 'CP'")
		_cTipo := "Contrato Parceria"
	EndIf
	_oBrw:SetDescription("Trilha de Segurança "+_cTipo) // Trilha de Segurança

	//_oBrw:SetFilterDefault( "@ ZH_ORIGEM == "+_cTipo ) 
   	_oBrw:Activate()

End Sequence
RestArea(_aArea)
SetFunName(_cFunNameBkp)
Return Nil

// BROWSEDEF() SERÁ ÚTIL PARA FUTURAS HERANÇAS: FWLOADBRW()



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
//Local _aRotina := FWMVCMenu("ZCOMF022")
Begin Sequence	
	ADD OPTION _aRotina TITLE "Visualizar Hist"	ACTION "U_ZCF022ZH"   		OPERATION 2 ACCESS 0
	ADD OPTION _aRotina TITLE "Visualizar Dcto"	ACTION "U_ZCF022VD"   		OPERATION 2 ACCESS 0
	ADD OPTION _aRotina TITLE "Pesquisar"  		ACTION 'PesqBrw' 			OPERATION 1 ACCESS 0

	/*
    ADD OPTION _aRotina TITLE "Incluir"    	ACTION "VIEWDEF.ZCOMF022" OPERATION 3 ACCESS 0
	ADD OPTION _aRotina TITLE "Alterar"    	ACTION "VIEWDEF.ZCOMF022" OPERATION 4 ACCESS 0
	ADD OPTION _aRotina TITLE "Excluir"    	ACTION "VIEWDEF.ZCOMF022" OPERATION 5 ACCESS 0
    */
	ADD OPTION _aRotina TITLE "Imprimir" 	ACTION "VIEWDEF.ZCOMF022" 	OPERATION 8 ACCESS 0

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

Local oStr1 := FWFormStruct( 1, 'SZH', /*bAvalCampo*/, /*lViewUsado*/,  /*lVirtual*/ , /*lFilOnView*/,/*cProgram*/) // Construção de uma estrutura de dados
Begin Sequence	
	//Cria o objeto do Modelo de Dados
    //Irie usar uma função QCP1VLD que será acionada quando eu clicar no botão "Confirmar"
	oModel := MPFormModel():New('ZCOMF022MOD', /*bPreValidacao*/ , /*{ | oModel | QCP1VLD( oModel ) } */, /*{ | oMdl | MVC001C( oMdl ) }*/ ,, /*bCancel*/ )
	oModel:SetDescription('Trilha de Segurança')
	
	oStr1:setProperty("ZH_ORIGEM",MODEL_FIELD_WHEN,{||INCLUI})		

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
	oModel:SetPrimaryKey({'ZH_FILIAL', 'ZH_ORIGEM', "ZH_DOCTO", "ZH_ITEM", "ZH_REVISAO", "ZH_OPER", "ZH_CAMPO", "ZH_DOCTO" })
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('SZHMASTER'):SetDescription('Trilha de Segurança')
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
//Local oModel 	:= FWLoadView( 'ZCOMF022' )
Local oModel 	:= ModelDef()
Local oStr1		:= FWFormStruct(2, 'SZH')
Local oView 	

Begin Sequence
	oView 	:= FWFormView():New()
	oView:SetModel(oModel)
//	oStr1:AddField( ;
//						"BT_CARREGA"         , ;             // [01] Campo
//						"ZZ"             , ;             // [02] Ordem
//						"Carregar"  , ;             // [03] Titulo
//						"Carregar Previsões" , ;      // [04] Descricao
//						, ;                              // [05] Help
//						"BT"              , ;             // [06] Tipo do campo   COMBO, Get ou CHECK
//						Nil             , ;             // [07] Picture
//						Nil, ;                              // [08] PictVar
//						Nil          )                   // [09] F3


	oView:AddField("VIEW_SZH" , oStr1,"SZHMASTER" )
	oView:CreateHorizontalBox( "BOXFORM1", 100)
	oView:SetOwnerView("VIEW_SZH","BOXFORM1")
	oView:SetDescription('Trilha de Segurança')
	//oView:EnableTitleView('VIEW_SZH' , 'Trilha de Segurança' )	
	//oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

/*
	oView:AddField('VMASTER_SZH' , oStr1,'SZH_PARAMETROS' )
	oView:AddGrid('VGRID_SZH' , oStr3,'SHH_GRID')  
	oView:CreateHorizontalBox( 'BOXFORM1', 14)
	oView:CreateHorizontalBox( 'BOXFORM3', 86)
	oView:SetOwnerView('VMASTER_SZH','BOXFORM1')
	oView:SetOwnerView('VGRID_SZH','BOXFORM3')
*/
End Sequence
Return oView

//Visualizar Trilha de Segurança
User Function ZCF022ZH()
Private  cCadastro := "Trilha de Segurança"
AxVisual("SZH",SZH->( RecNo() ),2)
Return Nil


//Visualizar documentos
User Function ZCF022VD()
Local _nReg		:= 0
Local _aArea    := GetArea()
Begin Sequence
	If SZH->ZH_NUMREG > 0
		_nReg	:= SZH->ZH_NUMREG
	Endif	
	If SZH->ZH_ORIGEM == 'PC' 
		ZCF022VAPC(_nReg,1)
	ElseIf SZH->ZH_ORIGEM == 'SC'
		ZCF022VSCO(_nReg)
	ElseIf SZH->ZH_ORIGEM == 'AE' 
		ZCF022VAPC(_nReg,2)
	ElseIf SZH->ZH_ORIGEM == 'CP' 
       	Msgalert("Não Implementado")
	Endif
End Sequence
RestArea(_aArea)
Return Nil	

//Visualizar Solicitação de Compras
Static Function ZCF022VSCO(_nReg)
Local _cChave 
Default _nReg := 0

Begin Sequence
	If _nReg == 0
		_cChave := AllTrim(SZH->ZH_DOCTO)
		SC1->(DbSetOrder(1))  //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
		If !SC1->(DbSeek(XFilial("SC1")+_cChave))
        	Msgalert("Não localizado Solicitação de Compras "+XFilial("SC1")+" "+_cChave)
			Break
		Endif	
		_nReg := SC1->(RecNo())
	EndIf	
	SC1->(A110Visual("SC1",_nReg ,2))
End Sequence
Return Nil

//Visualizar Pedido de Compras ou autorização de entrega
Static Function ZCF022VAPC(_nReg,_nTipo)
Local _nOpc		:= 2
Local _cChave 

Default _nReg 	:= 0

Begin Sequence
	If _nReg == 0
		_cChave := AllTrim(SZH->ZH_DOCTO)
		SC7->(DbSetOrder(1))
		If !SC7->(DbSeek(XFilial("SC7")+_cChave))
        	Msgalert("Não localizado "+If(SZH->ZH_ORIGEM == "PC","Pedido de Compra ","Autorização Entrega ")+XFilial("SC7")+" "+_cChave)
			Break
		Endif	
		_nReg := SC7->(RecNo())
	EndIf	
    //Mata120(ExpN1,ExpA1,ExpA2,ExpN2,ExpA1)
    /*
    ExpN1 = 1-Pedido de compras ou 2-Autorizacao de entrega
    ExpA1 = Array Cabecalho para Rotina Automatica 
    ExpA2 = Array Itens para Rotina Automatica 
    ExpN2 = Opcao do aRotina para Rotina Automatica 
    ExpA1 = Apresenta a Dialog da Rotina em Rotina Automatica (.T. ou .F.)
    */
    SC7->(Mata120(_nTipo,/*aCabec*/,/*aItens*/,_nOpc,.T.)) 

End Sequence
Return Nil

