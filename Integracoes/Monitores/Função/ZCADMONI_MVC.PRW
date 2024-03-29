/*Importar as bibliotecas*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*---------------------------------------------------------------------------------------
{Protheus.doc} ZCADMONI_MVC
Rdmake 	responsavel pelo cadastro das integra��es
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC Denilso 
@single		23/11/2022
@version    Nao Informado
@since      Nao Informado  
@return    	Logico
@sample     Nao Informado
@obs        
@project    CAOA
@menu       Nao Informado
@history    
--------------------------------------------------------------------------------------*/

/*Iniciando sua fun��o*/
User Function ZCADMONI_MVC()
Local _aArea 		:= GetArea()
Local _cFunNameBkp 	:= SetFunName()
Local _aSeek		:= {}
//Local _aFieFilter	:= {}
Local _oBrowse

Begin Sequence
	SetFunName('ZCADMONI_MVC')
  	DBSELECTAREA('SZ2')	// Cadastro monitor
 	Aadd(_aSeek,{"Codigo"      , {{"","C",Len(SZ2->Z2_CODIGO),0, "Z2_CODIGO"   ,"@!"}}, 1, .T. } )
     //Campos que ir�o compor a tela de filtro
    //Aadd(_aFieFilter,{"Z2_CODIGO"    , "Codigo"      , "C", Len(SZ2->Z2_CODIGO)	, 0,"@!"})
    //Aadd(_aFieFilter,{"Z2_NOME  "    , "Nome"      	 , "C", Len(SZ2->Z2_NOME)	, 0,"@!"})

 	_oBrowse := FWMBrowse():New()
	_oBrowse:SetMenuDef("ZCADMONI_MVC")
	/*
	_oBrowse:SetOnlyFields( {"ZDE_CODPRO"	,;//C�d Produto
							"ZDE_DESCPR"	,;//Descri��o Produto
							"ZDE_EMBPR"	,;//Embalagem Prim�ria
							"ZDE_DESCEP"	,;//Descri��o Emb Prim�ria
							"ZDE_SEQPRO"	,;//Sequ�ncia do produto
							"ZDE_EMBAL"	,;//Embalagem
							"ZDE_DESCEM"	,;//Descri��o da Embalagem
							"ZDE_SEQUE"	,;//Sequ�ncia de c�lculo
							"ZDE_QUANT"		;//Quantidade
							 } )
    */
	//Definimos o t�tulo que ser� exibido como m�todo SetDescription
	_oBrowse:SetDescription("Cadastro de Integra��es")
    //Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
	_oBrowse:SetAlias("SZ2")
//	//Legenda da grade, � obrigat�rio carregar antes de montar as colunas
	_oBrowse:AddLegend("SZ2->Z2_TPINTEG=='1'","BLUE" 	   	,"Envio")
	_oBrowse:AddLegend("SZ2->Z2_TPINTEG<>'1'","GREEN"   	,"Recebimento")
	_oBrowse:SetSeek(.T.,_aSeek)
  	_oBrowse:SetUseFilter(.T.)
    //_oBrowse:SetDBFFilter(.T.)
    //_oBrowse:SetFilterDefault( "" ) //Exemplo de como inserir um filtro padr�o >>> "TR_ST == �A�"
    //_oBrowse:SetFieldFilter(_aFieFilter)
	_oBrowse:SetLocate()
	_oBrowse:DisableDetails()
	_oBrowse:SetAmbiente(.F.)
	_oBrowse:SetWalkThru(.F.)	
	//Adiciona um filtro ao browse
//	_oBrowse:SetFilterDefault( "ZDE_DTCOM = '"+Space(8)+"' " ) //Exemplo de como inserir um filtro padr�o >>> "TR_ST == 'A'"
	//Desliga a exibi��o dos detalhes
	_oBrowse:DisableDetails()
    //Ativamos a classe
	_oBrowse:Activate()
End Sequence
SetFunName(_cFunNameBkp)
RestArea(_aArea)
Return Nil


//-------------------------------------------------------------------
// Montar o menu Funcional
//-------------------------------------------------------------------
Static Function MenuDef()
Local _aRotina := {}
Begin Sequence
	//ADD OPTION _aRotina TITLE "Pesquisar"  	ACTION 'AxPesqui' 		  		OPERATION 1 ACCESS 0
	ADD OPTION _aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ZCADMONI_MVC" 	OPERATION 2 ACCESS 0
	ADD OPTION _aRotina TITLE "Incluir"    	ACTION "VIEWDEF.ZCADMONI_MVC" 	OPERATION 3 ACCESS 0
	ADD OPTION _aRotina TITLE "Alterar"    	ACTION "VIEWDEF.ZCADMONI_MVC" 	OPERATION 4 ACCESS 0
	ADD OPTION _aRotina TITLE "Excluir"    	ACTION "VIEWDEF.ZCADMONI_MVC" 	OPERATION 5 ACCESS 0
	ADD OPTION _aRotina TITLE "Imprimir" 	ACTION "VIEWDEF.ZCADMONI_MVC" 	OPERATION 8 ACCESS 0
	ADD OPTION _aRotina TITLE "Copiar" 		ACTION "VIEWDEF.ZCADMONI_MVC" 	OPERATION 9 ACCESS 0

//	//ADD OPTION aRotina TITLE "Copiar" 		ACTION "VIEWDEF.QACEEMB1" OPERATION 9 ACCESS 0
//	ADD OPTION aRotina TITLE "Legenda" 	    ACTION "U_QCB1LEG" 		  OPERATION 6 ACCESS 0
End Sequence	
Return _aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface
@author DAC- Denilso
@since 05/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local _oView
Local _oModel := ModelDef()
Local _oStr1:= FWFormStruct(2, 'SZ2')
Begin Sequence	
	// Cria o objeto de View
	_oView := FWFormView():New()
	// Define qual o Modelo de dados ser� utilizado
	_oView:SetModel(_oModel)
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	_oView:AddField('Formulario' , _oStr1,'CamposSZ2' )
    //Remove os campos que n�o ir�o aparecer	
	//_oStr1:RemoveField( 'SZ2_' )	
	// Criar um "box" horizontal para receber algum elemento da view
	_oView:CreateHorizontalBox( 'PAI', 100)
	// Relaciona o ID da View com o "box" para exibicao
	_oView:SetOwnerView('Formulario','PAI')
	_oView:EnableTitleView('Formulario' , 'Cadastro Integra��o' )	
	_oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})
	//oView:SetViewCanActivate( QCP1VLD(oModel))
	//For�a o fechamento da janela na confirma��o
	_oView:SetCloseOnOk({||.T.})
End Begin	
Return _oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados
@author DAC- Denilso
@since 01/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local _oModel
Local _oStr1:= FWFormStruct( 1, 'SZ2', /*bAvalCampo*/,/*lViewUsado*/ ) // Constru��o de uma estrutura de dados
Begin Sequence	
	//Cria o objeto do Modelo de Dados
    //Irie usar uma fun��o QCP1VLD que ser� acionada quando eu clicar no bot�o "Confirmar"
	_oModel := MPFormModel():New('Cadastro Integra��es', /*bPreValidacao*/ , /*{ | _oModel | QCP1VLD( _oModel ) } */, { | _oModel | FGrava( _oModel ) } ,, /*bCancel*/ )
	_oModel:SetDescription('Cadastro Integra��es')
	//iniciar o campo X5_TABELA com o conteudo da sub-tabela
	_oStr1:SetProperty('Z2_CODIGO',MODEL_FIELD_INIT,{|| ZCADMOCOD(_oModel)})

	_oStr1:SetProperty("Z2_DTUALT",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"dDataBase"))
	_oStr1:SetProperty("Z2_HSUALT",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"Time()"))
	_oStr1:SetProperty("Z2_USUALT",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"RetCodUsr()"))
    //bloquear/liberar os campos para edi��o
	_oStr1:SetProperty('Z2_CODIGO' , MODEL_FIELD_WHEN,{|| .F. })
    //usar a propriedade GetOperation que captura a opera��o que est� sendo executada
	//oStr1:SetProperty("ZDE_FAMILIA"  , MODEL_FIELD_OBRIGAT,If(INCLUI .and. Empty(M->ZDE_DTINC),.T.,.F.))


    //usar as fun��es INCLUI ou ALTERA
	//oStr1:SetProperty('ZDE_FAMILIA'  , MODEL_FIELD_WHEN,{|| INCLUI })
    //Ou usar a propriedade GetOperation que captura a opera��o que est� sendo executada
	//oStr1:SetProperty("ZDE_FAMILIA"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })
	//Remover Campos
	//oStr1:RemoveField( 'ZDE_FAMILIA' )
	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	_oModel:addFields('CamposSZ2',,_oStr1,{|_oModel|QCP1MODE(_oModel)},,)
	//Define a chave primaria utilizada pelo modelo
	_oModel:SetPrimaryKey({'Z2_FILIAL', 'Z2_CODIGO' })
	// Adiciona a descricao do Componente do Modelo de Dados
	_oModel:getModel('CamposSZ2'):SetDescription('Cadastro Integra��o')
End Begin	
Return _oModel


//Esta fun��o ser� executada no inicio do carregamento da tela, neste exemplo irei
//apenas armazenar numa vari�vel o conteudo de um campo
Static Function QCP1MODE( _oModel )
Local _lRet      := .T.
//Local _oModelSZ2 := _oModel:GetModel( 'CamposSZ2' )
//cChaveAux := ZDE->ZDE_FAMILI
Return(_lRet)



//Implementar c�digo de integra��o
Static Function ZCADMOCOD(_oModel)
Local _nOpc     	:= _oModel:GetOperation()
Local _cAliasPesq  	:= GetNextAlias()      
//Capturar o conteudo dos campos
Local _cCodigo		:= SZ2->Z2_CODIGO
//Caso seja inclus�o
Begin Sequence
	//Atualizar somente para inclus�o
	If _nOpc <> 3  
		Break
	Endif
	BeginSql Alias _cAliasPesq //Define o nome do alias tempor�rio 
		SELECT 	MAX(SZ2.Z2_CODIGO) SZ2CODIGO
		FROM  %Table:SZ2% SZ2 
		WHERE 	SZ2.Z2_FILIAL 	=  %xFilial:SZ2% 
           	AND SZ2.%notDel%
	EndSql
	If (_cAliasPesq)->(Eof()) .or.  Empty((_cAliasPesq)->SZ2CODIGO)
		_cCodigo := StrZero(1,Len(SZ2->Z2_CODIGO))
	Else
		_cCodigo := StrZero(Val((_cAliasPesq)->SZ2CODIGO)+1,Len(SZ2->Z2_CODIGO))
	Endif

End Sequence
Return _cCodigo





//-------------------------------------------------------------------
/*/{Protheus.doc} FGrava
Gravar informa��es adicionais como usuario data

@author denilso.almeida

@since 05/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function FGrava(_oModel)
Local _lRet := .T.
Begin Transaction 
	If FwFormCommit(_oMODEL)	
		If _oMODEL:GetOperation() == MODEL_OPERATION_INSERT
			RecLock("SZ2",.F.)
			SZ2->Z2_DTINC   := Date()
			SZ2->Z2_HSINC  	:= Time()	
			SZ2->Z2_USUINC  := RetCodUsr() 
			SZ2->(MsUnlock())	
		Else  //N�o sendo Inser�ao gravar o usuario que executou a altera��o
			RecLock("SZ2",.F.)
			SZ2->Z2_DTUALT  := Date()
			SZ2->Z2_HSUALT  := Time()
			SZ2->Z2_USUALT	:= RetCodUsr() 
			SZ2->(MsUnlock())	
		EndIf
	Else
		DisarmTransaction()
		Help( ,,"Aten��o", , "Problema na grava��o dados Integra��o !!",1,0)
		_lRet := .F.		
	Endif
End Transaction
Return _lRet 


//User Function QCB1LEG()
//Local _aLegenda := {}
//Begin Sequence
//	Aadd(_aLegenda,{"BR_VERDE"   ,"Previs�o em Aberto"})
//	Aadd(_aLegenda,{"BR_VERMELHO","Previs�o Finalizada"})
//	BrwLegenda("Previs�o de Vendas","Status",_aLegenda)
//End Begin
//Return Nil	

	//oBrowse:AddLegend("ZDE_STATUS=='1'","GREEN" ,"Previs�o Finalizada")
	//oBrowse:AddLegend("ZDE_STATUS<>'1'","RED"  	,"Previs�o Aberta")

	
	
	
	