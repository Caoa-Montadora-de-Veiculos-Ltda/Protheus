#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "fwbrowse.ch"
#include 'fwmvcdef.ch'


/*
=====================================================================================
Programa.:              ZGENF001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              12/07/19
Descricao / Objetivo:   Consulta Log´s dos e-mails enviados.
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
User function ZGENF001()
	local oBrowse

	//Cria um Browse Simples instanciando o FWMBrowse
	oBrowse := FWMBrowse():New()
	//Define um alias para o Browse
	oBrowse:SetAlias('SZU')
	//Adiciona uma descrição para o Browse
	oBrowse:SetDescription('Log de Envio de E-mails')

	// Definição da legenda
	oBrowse:AddLegend( "SZU->ZU_STATUS == '2'"	    , "RED"		,"Erro de Envio" )
	oBrowse:AddLegend( "SZU->ZU_STATUS == '1'"	    , "GREEN"	,"Enviado com Sucesso" )
	oBrowse:AddLegend( "!SZU->ZU_STATUS $ '1*2' "	, "GRAY"	,"Não identificado" )

	//oBrowse:disableReport()

	//Ativa o Browse
	oBrowse:Activate()

Return nil

/*
=====================================================================================
Programa.:              MenuDef
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              12/07/19
Descricao / Objetivo:   Monta botões
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static Function MenuDef()

	local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.ZGENF001'	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Legenda'    	ACTION 'zBrwLeg()'			OPERATION 6 ACCESS 0


Return aRotina

/*
=====================================================================================
Programa.:              ModelDef
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              12/07/19
Descricao / Objetivo:   Monta botões
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruSZU := FWFormStruct( 1, 'SZU', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('GENF001MDL',  /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'SZUMASTER', /*cOwner*/, oStruSZU, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Log de Envio de E-mails' )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'SZUMASTER' ):SetDescription( 'Log de Envio de E-mails' )

	oModel:SetPrimaryKey({})

Return oModel

/*
=====================================================================================
Programa.:              ViewDef
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              12/07/19
Descricao / Objetivo:   Monta botões
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'ZGENF001' )

	// Cria a estrutura a ser usada na View
	Local oStruSZU := FWFormStruct( 2, 'SZU' )
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados serÃ¡ utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_SZU', oStruSZU, 'SZUMASTER' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_SZU', 'TELA' )

Return oView
/*
=====================================================================================
Programa.:              zBrwLeg
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              12/07/19
Descricao / Objetivo:   Monta botões
Doc. Origem:
Solicitante:            Geral
Uso......:              Geral
Obs......:
=====================================================================================
*/  

Static Function zBrwLeg()

	Local aLegenda := {}

	//Monta as cores
	AADD(aLegenda,{"BR_VERMELHO"	,"Erro de Envio"		})
	AADD(aLegenda,{"BR_VERDE"		,"Enviado com Sucesso"	})
	AADD(aLegenda,{"BR_CINZA"		,"Não identificado"	    })

	BrwLegenda("Status", "Pendências", aLegenda)

Return
