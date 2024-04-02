#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'   
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CMVMSF01        �Autor  �Jose Roberto   � Data �  27/10/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro tipo Modelo 3 - MVC  - tabelas SZQ / SZR          ���   
���          � Manuten��o nas estruturas de Exportacao Mastersaf	      ��� 
�������������������������������������������������������������������������͹��
���Parametros� 													          ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico - CAOA - Interface Mastersaf                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CMVMSF01()          

Local oBrowse  

//verifica se as tabelas foram criadas corretamente
chkfile("SZQ")   
chkfile("SZR") 

oBrowse := FWMBrowse():New() 

oBrowse:SetAlias('SZQ')

oBrowse:SetDescription( 'Cadastro de Tabelas/Estruturas Mastersaf' )
oBrowse:AddLegend( "ZQ_MSBLQL=='1'", "BLACK", "Bloqueado" )
oBrowse:AddLegend( "ZQ_MSBLQL<>'1'", "GREEN" , "Liberado" ) 
// desabilita o detalhe do registro
oBrowse:DisableDetails()
oBrowse:Activate()  

Return NIL

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef   � Autor � JRoberto          � Data �  27/10/18   ���
�������������������������������������������������������������������������͹��
���Descricao � Manuten��o do Cadastro de Estruturas Mastersaf             ���
���          � Cria Menu para Browse                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico - CAOA                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Pesquisar' 	ACTION 'VIEWDEF.CMVMSF01' OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.CMVMSF01' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir' 		ACTION 'VIEWDEF.CMVMSF01' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar' 		ACTION 'VIEWDEF.CMVMSF01' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir' 		ACTION 'VIEWDEF.CMVMSF01' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Legenda'    	ACTION 'FLEGE()'		  OPERATION 6 ACCESS 0  
ADD OPTION aRotina TITLE 'Imprimir' 	ACTION 'VIEWDEF.CMVMSF01' OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE 'Copiar' 		ACTION 'VIEWDEF.CMVMSF01' OPERATION 9 ACCESS 0

Return aRotina

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ModelDef  � Autor � JRoberto Proativa  � Data �  27/10/18  ���
�������������������������������������������������������������������������͹��
���Descricao � Manuten��o do Cadastro de Estruturas MasterSaf             ���
���          � Cria objeto Model - MVC                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico CAOA                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ModelDef()

	// Cria a estrutura a ser acrescentada no Modelo de Dados
	Local oStruSZQ		:= FWFormStruct( 1, 'SZQ', { |x| ALLTRIM(x) $ 'ZQ_TABELA,ZQ_DESCTB,ZQ_NMVW01,ZQ_NMVW02,ZQ_NMVW03,ZQ_NMVW04,ZQ_MSBLQL' },/*lViewUsado*/ )   
	Local oStruSZR   	:= FWFormStruct( 1, 'SZR', { |x| ALLTRIM(x) $ 'ZR_ORDEM,ZR_CAMPO,ZR_TIPO,ZR_TAMAN,ZR_DECIMAL,ZR_ORDEM' },/*lViewUsado*/ )   
	Local oModel 

	//SINTAXE MPFORMMODEL():New(< cID >, < bPre >, < bPost >, < bCommit >, < bCancel >)-> NIL
	oModel := MPFormModel():New('VIEWSZR_MVC',/*LinOk*/,/*TudoOk*/, , )
	oModel:SetDescription('Cadastro de Tabelas/Estruturas Mastersaf')

	// Adiciona a nova FORMFIELD
	oModel:AddFields( 'SZQMASTER',, oStruSZQ )
	oModel:AddGrid( 'SZRDETAIL', 'SZQMASTER', oStruSZR , , )


	//Define valida��o para chave unica no grid
	oModel:GetModel( 'SZRDETAIL' ):SetUniqueLine( { 'ZR_ORDEM' } )
	oModel:GetModel( 'SZRDETAIL' ):SetUniqueLine( { 'ZR_ORDEM' } )


	// Faz relacionamento entre os compomentes do model
	oModel:SetRelation( 'SZRDETAIL', { { 'ZR_FILIAL', 'xFilial( "SZQ" )' }, { 'ZR_TABELA', 'ZQ_TABELA' } }, SZR->( IndexKey( 1 ) ) )

	// Adiciona a descricao do novo componente
	oModel:GetModel( 'SZQMASTER' ):SetDescription( 'Tabela' )
	oModel:GetModel( 'SZRDETAIL' ):SetDescription( 'Estrutura' )

	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'ZQ_FILIAL', 'ZQ_TABELA' })

Return oModel

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ViewDef  � Autor � JRoberto Proativa  � Data �  27/10/18   ���
�������������������������������������������������������������������������͹��
���Descricao � Manuten��o do Cadastro de Estruturas MasterSaf             ���
���          � Cria objeto View - MVC                                     ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico CAOA                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel := ModelDef()

	// Cria a estrutura a ser acrescentada na View
	Local oStruSZQ		:= FWFormStruct( 2, 'SZQ', { |x| ALLTRIM(x) $ 'ZQ_TABELA,ZQ_DESCTB,ZQ_NMVW01,ZQ_NMVW02,ZQ_NMVW03,ZQ_NMVW04,ZQ_MSBLQL' },/*lViewUsado*/ )   
	Local oStruSZR   	:= FWFormStruct( 2, 'SZR', { |x| ALLTRIM(x) $ 'ZR_ORDEM,ZR_CAMPO,ZR_TIPO,ZR_TAMAN,ZR_DECIMAL,ZR_ORDEM' },/*lViewUsado*/ )   

	Local oView := FWFormView():New() 

	// Altera o Modelo de dados quer ser� utilizado
	oView:SetModel( oModel )

	// Adiciona na View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_SZQ', oStruSZQ, 'SZQMASTER' ) 
	oView:AddGrid ( 'VIEW_SZR', oStruSZR, 'SZRDETAIL' )

	//CRIA CAMPO INCREMENTARL - SEQ
	oView:AddIncrementField( 'VIEW_SZR', 'ZR_ORDEM' )

	// � preciso criar sempre um box vertical dentro de um horizontal e vice-versa
	// como na VIEWSZ2_MVC o box � horizontal, cria-se um vertical primeiro
	// Box existente na interface original
	oView:CreateVerticallBox( 'TELANOVA' , 100) 

	// Novos Boxes - define a �rea de ocupacao de cada box na tela
	oView:CreateHorizontalBox( 'CABEC' , 30, 'TELANOVA' )
	oView:CreateHorizontalBox( 'GRID1' , 70, 'TELANOVA' ) 

	//Habilitando t�tulo
	oView:EnableTitleView('VIEW_SZQ','Tabela' )
	oView:EnableTitleView('VIEW_SZR','Estrutura' )

	// Relaciona o identificador (ID) da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_SZQ' , 'CABEC' )
	oView:SetOwnerView( 'VIEW_SZR' , 'GRID1' )

Return oView                                       


/***************************************************************
	Funcao:		LinOk 
	Autor:		Jose ROberto Carvalho
	Descricao:	Exemplo de fun��o para valida��o da Linha GetDados
	Uso:		Valida Linha no Grid 
/**************************************************************/
Static Function LinOk ( oModelGrid, nLinha )

//FWFORMGRIDMODEL()
Local lRet := .T.
Local oModel := oModelGrid:GetModel()
Local nOperation := oModel:GetOperation()

//Verifica se a linha esta deletada
IF !oModelGrid:IsDeleted( nLinha )
	If !empty(oModelGrid:GetValue('ZR_CAMPO')) 
		If empty(oModelGrid:GetValue('ZR_ORDEM')) 
			oModelGrid:SetValue( 'ZR_ORDEM', STRZERO(nLinha,2) )	
		Endif
	Endif
Endif

//Exemplo de valida��o adicional com HELP
// Valida se pode ou n�o apagar uma linha do Grid
//If cAcao == 'DELETE' .AND. nOperation == MODEL_OPERATION_UPDATE
//	lRet := .F.
//	Help( ,, 'Help',, 'N�o permitido apagar linhas na altera��o.' +;
//	CRLF + 'Voc� esta na linha ' + Alltrim( Str( nLinha ) ), 1, 0 )
//EndIf

Return lRet 

/***************************************************************
	Funcao:		FLEGE
	Autor:		Jose ROberto Carvalho
	Descricao:	Mostra Legenda conforme Parametros
	Uso:		Generico
/**************************************************************/
Static Function FLEGE()

Local cCadastro := "Tabelas MasterSaf"

BrwLegenda(cCadastro,"Legenda", ;
		   {{"BR_VERDE"		,"N�o Bloqueado"	},;
			{"BR_PRETO"		,"Bloqueado"		}}) 

Return 



