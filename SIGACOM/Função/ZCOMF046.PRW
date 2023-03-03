#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwbrowse.ch"
#include 'fwmvcdef.ch'

/*
=====================================================================================
Programa.:              ZCOMF046   
Autor....:              CAOA - Sandro Ferreira 
Data.....:              12/05/22
Descricao / Objetivo:   Cadastra de SLA
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
User function ZCOMF046()
    Local aArea   := GetArea()
	Local oBrowse

	//Instanciando o FWMBrowse - Somente com dicionário de dados
	oBrowse:= FWMBrowse():New()

	//Setando a tabela de cadastro de tipos de Documentos
	oBrowse:SetAlias('ZA4')

	//Setando a descrição da rotina
	oBrowse:SetDescription('Cadastro de SLA')

	//Exibiando somente os campos referentes ao cadastro de SLA
    oBrowse:SetOnlyFields({'ZA4_DOCCOM','ZA4_TPDOC', 'ZA4_UTEIS' , 'ZA4_CORRID' })

	//Filtrando os registros dos tipos de documentos
	oBrowse:SetFilterDefault( "ZA4_PROCES == 'CS'" )

	//Legendas
	oBrowse:AddLegend( "ZA4->ZA4_DOCCOM == 'SC'"	    , "GREEN"	    ,"Solicitação de Compras" )
	oBrowse:AddLegend( "ZA4->ZA4_DOCCOM == 'PC'"	    , "RED"	        ,"Pedido de Compras"      )
	oBrowse:AddLegend( "ZA4->ZA4_DOCCOM == 'CP'"	    , "BLUE"	    ,"Contrato de Parceria"   )
	oBrowse:AddLegend( "ZA4->ZA4_DOCCOM == 'AE'"	    , "YELLOW"	    ,"Autorização de Entrega" )

	//Ativa o Browse
	oBrowse:Activate()
	RestArea(aArea)

Return nil

/*
=====================================================================================
Programa.:              MenuDef
Autor....:              CAOA - Sandro Ferreira 
Data.....:              10/05/2022
Descricao / Objetivo:   Monta botões da Tela Tipo de Documentos
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static Function MenuDef()

	local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.ZCOMF046'   OPERATION MODEL_OPERATION_VIEW ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'  	ACTION 'VIEWDEF.ZCOMF046'	OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'  	ACTION 'VIEWDEF.ZCOMF046'	OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Deletar'  	ACTION 'VIEWDEF.ZCOMF046'	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Legenda'    	ACTION 'zBrwLeg()'			OPERATION 6 ACCESS 0

Return aRotina

/*
=====================================================================================
Programa.:              ModelDef
Autor....:              CAOA - Sandro Ferreira 
Data.....:              10/05/22
Descricao / Objetivo:   Monta botões
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oModel := Nil

	//Criação da estrutura de dados utilizada na interface
	Local oStruZA4 := FWFormStruct( 1, 'ZA4', /*bAvalCampo*/,/*lViewUsado*/ )

	// Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New('COMF044MDL',  /*bPreValidacao*/, /*bPosValidacao*/, {|oModel| zcomcomit(oModel) }, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'ZA4MASTER', /*cOwner*/, oStruZA4, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
    
	//Informa que nenhum desses campos da estrutura obedecereção as regreas do SX3
    //oStruZA4:SetProperty("*" ,MODEL_FIELD_OBRIGAT,.F.)

	oStruZA4:SetProperty("ZA4_CODIGO" ,MODEL_FIELD_OBRIGAT,.F.)
    oStruZA4:SetProperty("ZA4_DESCR" ,MODEL_FIELD_OBRIGAT,.F.)
	oStruZA4:SetProperty("ZA4_SITUAC" ,MODEL_FIELD_OBRIGAT,.F.)
	oStruZA4:SetProperty("ZA4_PROCES" ,MODEL_FIELD_OBRIGAT,.F.)
    oStruZA4:SetProperty("ZA4_DOCORI" ,MODEL_FIELD_OBRIGAT,.F.)
	oStruZA4:SetProperty("ZA4_TPDOCO" ,MODEL_FIELD_OBRIGAT,.F.)
    oStruZA4:SetProperty("ZA4_DOCDES" ,MODEL_FIELD_OBRIGAT,.F.)
	oStruZA4:SetProperty("ZA4_TPDOCD" ,MODEL_FIELD_OBRIGAT,.F.)

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Cadastro de SLA' )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'ZA4MASTER' ):SetDescription( 'Cadastro de SLA' )

	oModel:SetPrimaryKey({'ZA4_FILIAL','ZA4_DOCCOM', 'ZA4_TPDOC'})

Return oModel

/*
=====================================================================================
Programa.:              ViewDef
Autor....:              CAOA - Sandro Ferreira
Data.....:              10/05/2022
Descricao / Objetivo:   Monta botões
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    Local oModel  := ModelDef()
	Local oView   := Nil
	Local oStruZA4:= FWFormStruct( 2, "ZA4" )

	// Cria o objeto de View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	//oView:AddField( "ZCOMF044" , oStruZA4 )
    
	// Define qual o Modelo de dados serÃ¡ utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZA4', oStruZA4, 'ZA4MASTER' )

    //Remove os campos que não irão aparecer	

	oStruZA4:RemoveField( 'ZA4_DOCORI' )
	oStruZA4:RemoveField( 'ZA4_TPDOCO' )
	oStruZA4:RemoveField( 'ZA4_DOCDES' )
	oStruZA4:RemoveField( 'ZA4_PROCES' )
	oStruZA4:RemoveField( 'ZA4_TPDOD'  )
	oStruZA4:RemoveField( 'ZA4_TPDOCD' )
	oStruZA4:RemoveField( 'ZA4_CODIGO' )
	oStruZA4:RemoveField( 'ZA4_DESCR'  )
    oStruZA4:RemoveField( 'ZA4_SITUAC' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZA4', 'TELA' )

Return oView

/*
=====================================================================================
Programa.:              zBrwLeg
Autor....:              CAOA - Sandro Ferreira
Data.....:              10/05/2022
Descricao / Objetivo:   Monta Legenda
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/  
Static Function zBrwLeg()

	Local aLegenda := {}

	//Monta as cores

    AADD(aLegenda,{"BR_VERDE"		,"Solicitação de Compras"	})
	AADD(aLegenda,{"BR_VERMELHO"	,"Pedido de Compras"		})
    AADD(aLegenda,{"BR_AZUL"		,"Contrato de Parceria"  	})
	AADD(aLegenda,{"BR_AMARELO"    	,"Autorização de Entrega"	})

	BrwLegenda("Status", "Pendências", aLegenda)

Return



/*
=====================================================================================
Programa.:              zcomcomit
Autor....:              CAOA - Sandro Ferreira
Data.....:              10/05/2022
Descricao / Objetivo:   Chumba valor no campo ZA4_PROCES
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/  
Static Function zcomcomit(oModel)
//ZA4MASTER  = ID DO MODELO
//COMF044MDL = NOME DO MODELO
//oStruZA4   = eSTRUTURA DE DADOS (PASSA NO MODELO COM NA VIEW)
Local lret      := .F.
Local nOpc      := oModel:GetOperation()
Local oModelZA4 := oModel:GetModel("ZA4MASTER")
If nOpc <> 5 //Exclusão
	ZA4->( dbSetOrder(2) )
	If !( ZA4->( dbSeek( FWxFilial("ZA4") + FWFldGet('ZA4_DOCCOM') + FWFldGet('ZA4_TPDOC')     )    )   )

		//Atribuindo o valor ao Modelo
		lRet := oModelZA4:SetValue("ZA4_PROCES","CS")

		//--Faz o commit do modelo 
		If lRet
		lRet := FWFormCommit( oModel )
		Endif
	Else
		oModel:SetErrorMessage("","","","","HELP",'Código da SLA Já Cadastrado !',"Escolha outro código")
	Endif
else
  lRet := FWFormCommit( oModel )
  // lRet := .T.
Endif
Return lRet
