#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwbrowse.ch"
#include 'fwmvcdef.ch'

/*
=====================================================================================
Programa.:              ZCOMF045  
Autor....:              CAOA - Sandro Ferreira 
Data.....:              12/05/22
Descricao / Objetivo:   Amarração Tipo de documento X Documento de Compras
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
User function ZCOMF045()
    Local aArea   := GetArea()
	Local oBrowse

	//Instanciando o FWMBrowse - Somente com dicionário de dados
	oBrowse:= FWMBrowse():New()

	//Setando a tabela de cadastro de tipos de Documentos
	oBrowse:SetAlias('ZA4')

	//Setando a descrição da rotina
	oBrowse:SetDescription('Cadastro Amarração Tipo de documento X Documento de Compras')

	//Exibiando somente os campos referentes ao cadastro de SLA
    oBrowse:SetOnlyFields({'ZA4_DOCORI','ZA4_TPDOCO', 'ZA4_DOCDES' , 'ZA4_TPDOCD' })

	//Filtrando os registros dos tipos de documentos
	oBrowse:SetFilterDefault( "ZA4_PROCES == 'AT'" )

	//Legendas
	//oBrowse:AddLegend( "ZA4->ZA4_DOCCOM == 'SC'"	    , "GREEN"	    ,"Solicitação de Compras" )
	//oBrowse:AddLegend( "ZA4->ZA4_DOCCOM == 'PC'"	    , "RED"	        ,"Pedido de Compras"      )
	//oBrowse:AddLegend( "ZA4->ZA4_DOCCOM == 'CP'"	    , "BLUE"	    ,"Contrato de Parceria"   )
	//oBrowse:AddLegend( "ZA4->ZA4_DOCCOM == 'AE'"	    , "YELLOW"	    ,"Autorização de Entrega" )

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
Obs......:              Amarração Tipo de documento X Documento de Compras
=====================================================================================
*/
Static Function MenuDef()

	local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.ZCOMF045'   OPERATION MODEL_OPERATION_VIEW ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'  	ACTION 'VIEWDEF.ZCOMF045'	OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'  	ACTION 'VIEWDEF.ZCOMF045'	OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Deletar'  	ACTION 'VIEWDEF.ZCOMF045'	OPERATION 5 ACCESS 0
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
Obs......:              Amarração Tipo de documento X Documento de Compras
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
    oStruZA4:SetProperty("ZA4_DESCR"  ,MODEL_FIELD_OBRIGAT,.F.)
	oStruZA4:SetProperty("ZA4_SITUAC" ,MODEL_FIELD_OBRIGAT,.F.)
	oStruZA4:SetProperty("ZA4_PROCES" ,MODEL_FIELD_OBRIGAT,.F.)
    oStruZA4:SetProperty("ZA4_DOCCOM" ,MODEL_FIELD_OBRIGAT,.F.)
	oStruZA4:SetProperty("ZA4_TPDOC"  ,MODEL_FIELD_OBRIGAT,.F.)
    oStruZA4:SetProperty("ZA4_UTEIS"  ,MODEL_FIELD_OBRIGAT,.F.)
	oStruZA4:SetProperty("ZA4_CORRID" ,MODEL_FIELD_OBRIGAT,.F.)

	oStruZA4:SetProperty("ZA4_DOCDES"  ,MODEL_FIELD_OBRIGAT,.F.)
	oStruZA4:SetProperty("ZA4_TPDOCD"  ,MODEL_FIELD_OBRIGAT,.F.)

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Cadastro Amarração Tipo de documento X Documento de Compras' )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'ZA4MASTER' ):SetDescription( 'Cadastro Amarração Tipo de documento X Documento de Compras' )

	oModel:SetPrimaryKey({'ZA4_FILIAL','ZA4_DOCORI', 'ZA4_TPDOC', 'ZA4_DOCDES', 'ZA4_TPDOCD' })

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
Obs......:              Amarração Tipo de documento X Documento de Compras
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

	oStruZA4:RemoveField( 'ZA4_DOCCOM' )
	oStruZA4:RemoveField( 'ZA4_TPDOC' )
	oStruZA4:RemoveField( 'ZA4_UTEIS' )
	oStruZA4:RemoveField( 'ZA4_CORRID'  )
	oStruZA4:RemoveField( 'ZA4_CODIGO' )
	oStruZA4:RemoveField( 'ZA4_DESCR'  )
    oStruZA4:RemoveField( 'ZA4_SITUAC' )
	oStruZA4:RemoveField( 'ZA4_PROCES' )

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
Obs......:              Amarração Tipo de documento X Documento de Compras
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
Obs......:              Amarração Tipo de documento X Documento de Compras
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
    If FWFldGet('ZA4_DOCORI') <> FWFldGet('ZA4_DOCDES')
		If FWFldGet('ZA4_DOCORI')  + FWFldGet('ZA4_TPDOCO') <> FWFldGet('ZA4_DOCDES') + FWFldGet('ZA4_TPDOCD')
			ZA4->( dbSetOrder(3) )
			If !( ZA4->( dbSeek( FWxFilial("ZA4") + FWFldGet('ZA4_DOCORI') + FWFldGet('ZA4_TPDOC') + FWFldGet('ZA4_DOCDES') + FWFldGet('ZA4_TPDOCD')     )    )   )

				//Atribuindo o valor ao Modelo
				lRet := oModelZA4:SetValue("ZA4_PROCES","AT")

				//--Faz o commit do modelo 
				If lRet
				lRet := FWFormCommit( oModel )
				Endif
			Else
				oModel:SetErrorMessage("","","","","HELP",'Amarração Tipo de documento X Documento de Compras Já Cadastrado !',"Escolha outro.")
			Endif
		else
			oModel:SetErrorMessage("","","","","HELP",'Amarração Tipo de documento X Documento de Compras não pode ser iguais !',"Escolha outro.")
		endif
	else
		oModel:SetErrorMessage("","","","","HELP",'Documento de Origem igual ao Documento de Destino!',"Escolha outro.")
	endif
else
  lRet := FWFormCommit( oModel )
Endif
Return lRet
