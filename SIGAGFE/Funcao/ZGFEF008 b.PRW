//Bibliotecas
#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "FWMVCDEF.ch"

//Variáveis estatisticas
Static cTitulo      := "Notas Fiscas"
Static cTabPai      := "SF2" //Cabeçalho de NF
Static cTabFilho    := "SD2" //Itens de NF
Static cTabela 		:= "TPC" //Tabela temporária CABEC.
Static cTabGrid		:= "TGD" //Tabela temporária GRID.

User function ZGFEF008()

	Local aArea     := GetArea()
	Local oBrowse
	Local oTmpTabFd //Tabela temporária do CABEC
	Local oTmpTabGd //Tabela temporária da GRID
	Local lRet 		:= .F.
	Local cNumDoc 	:= "000000039"
	Local cFunBkp   := FunName()
	Local aColunas 	:= {}
	Local aPesquisa := {}

	Private aRotina := {}
	Private cTab := "" //Usada em fPopula

	SetFunName("ZGFEF008")

	//Begin Sequence
	//Popular Tabela Temporária
	lRet := fPopula(cNumDoc)

	(cTab)->(DbCloseArea())
	DbSelectArea("TPC")
	TPC->(DbGoTop())

	If TPC->(!Eof()) .and. lRet

		//Definição do menu
		aRotina := MenuDef()

		//Definindo as colunas que serão usadas no browse
		aAdd(aColunas, {"Nome",    "TPC_NOME"	, "C", 20, 0, "@!"})
		aAdd(aColunas, {"Cliente", "TPC_CLIENT" , "C", 10, 0, "@!"})
		aAdd(aColunas, {"Loja",    "TPC_LOJA"	, "N", 05, 0, "@!"})
		aAdd(aColunas, {"Emissao", "TPC_EMISSA" , "C", 10, 0, "@!"})

		//Adiciona os indices para pesquisar
			/*
				[n,1] Título da pesquisa
				[n,2,n,1] LookUp
				[n,2,n,2] Tipo de dados
				[n,2,n,3] Tamanho
				[n,2,n,4] Decimal
				[n,2,n,5] Título do campo
				[n,2,n,6] Máscara
				[n,2,n,7] Nome Físico do campo - Opcional - é ajustado no programa
				[n,3] Ordem da pesquisa
				[n,4] Exibe na pesquisa
			*/
		aAdd(aPesquisa, {"Código", {{"", "C", 6, 0, "Codigo", "@!", "TPC_DOC"}} } )

		//Instânciando - Somente com dicionário de dados
		oBrowse := FWMBrowse():New()

		//Setando a tabela de cadastro de Autor/Interprete
		oBrowse:SetAlias(cTabela)

		//Indica que é usado uma tabela temporária
		oBrowse:SetTemporary(.T.)
		oBrowse:SetFields(aColunas) //Campos que devem aparecer no Browse
		oBrowse:DisableDetails()
		//Setando a descrição da rotina
		oBrowse:SetDescription(cTitulo)
		oBrowse:SetSeek(.T., aPesquisa)
		oBrowse:Activate() //Ativa a Browse
	Else
		Return
		//Break
	EndIf

	//End Sequence
	oTmpTabFd:Delet()
	oTmpTabGd:Delet()
	SetFunName(cFunBkp)
	RestArea(aArea)

Return Nil

Static Function MenuDef()

	Local aRotina := {}

	//Adicionando opções de menu
	ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.ZGFEF008" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"      ACTION "VIEWDEF.ZGFEF008" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.ZGFEF008" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"      ACTION "VIEWDEF.ZGFEF008" OPERATION 5 ACCESS 0

Return aRotina

//Cria o modelo de dados para cadastro
Static Function ModelDef()
	Local oModel
	Local oCabecTPC := FWFormModelStruct():New()
	Local oGridTGD 	:= FWFormModelStruct():New()
	//Blocos de código para criar validações
	Local bPre      := Nil //Antes de abrir o formulário.
	Local bPos      := Nil //Ao clicar no confirmar, antes de salvar.
	Local bCommit   := Nil //Após fechar o formulário quando for salvar.
	Local bCancel   := Nil //Quando o usuário cancelar o formulário
	Local aRelation := {}

	//Na estrutura, define os campos e a temporária.
	oCabecTPC:AddTable(cTabela, {'TPC_DOC', 'TPC_NOME', 'TPC_CLIENT', 'TPC_LOJA'  , 'TPC_EMISSA', 'TPC_VALBRU',  'TPC_SERIE', 'TPC_CHVNFE'}, "TPC")
	oGridTGD:AddTable(cTabGrid, {'TGD_DOC', 'TGD_SEQ' , 'TGD_PBRUTO', 'TGD_XPESOC', 'TGD_PESOR' , 'TGD_PESOC'}, "TGD")

	//Adiciona os campos da estrutura do CABEC
	oCabecTPC:AddField(; //Numero Documento
		"NumDoc",; 		// Título do campo
		"NumDoc",; 		// TootlTip do Campo
		"TPC_DOC",;	// Id do Field
		"C",;			// Tipo do campo
		09,; 			// Tamanho do campo
		0,;				// Decimal do campo
		Nil,;           // CodeBlock de validação do campo
		Nil,;			// CodeBlock de validação When do campo
		{},;			// Lista de valores permitidos do campo
		.T.,;			// Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, " + cTabela + "->TPC_DOC,'')" ),; //CodeBlock da inicialização do campo
		.T.,;			// Indica se trata-se de um campo chave
		.F.,;			// Indica se o campo pode receber valor em uma operação de update
		.F.)			// Indica se o campo é virtual
	oCabecTPC:AddField(; //Nome
		"Nome",; 		// Título do campo
		"Nome",; 		// TootlTip do Campo
		"TPC_NOME",;	// Id do Field
		"C",;			// Tipo do campo
		40,; 			// Tamanho do campo
		0,;				// Decimal do campo
		Nil,;           // CodeBlock de validação do campo
		Nil,;			// CodeBlock de validação When do campo
		{},;			// Lista de valores permitidos do campo
		.T.,;			// Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, " + cTabela + "->TPC_NOME,'')" ),; //CodeBlock da inicialização do campo
		.T.,;			// Indica se trata-se de um campo chave
		.F.,;			// Indica se o campo pode receber valor em uma operação de update
		.F.)			// Indica se o campo é virtual
	oCabecTPC:AddField(; //Cliente
		"Cliente",; 		// Título do campo
		"Cliente",; 		// TootlTip do Campo
		"TPC_CLIENT",;	// Id do Field
		"C",;			// Tipo do campo
		06,; 			// Tamanho do campo
		0,;				// Decimal do campo
		Nil,;           // CodeBlock de validação do campo
		Nil,;			// CodeBlock de validação When do campo
		{},;			// Lista de valores permitidos do campo
		.T.,;			// Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, " + cTabela + "->TPC_CLIENT,'')" ),; //CodeBlock da inicialização do campo
		.T.,;			// Indica se trata-se de um campo chave
		.F.,;			// Indica se o campo pode receber valor em uma operação de update
		.F.)			// Indica se o campo é virtual
	oCabecTPC:AddField(; //Loja
		"Loja",; 		// Título do campo
		"Loja",; 		// TootlTip do Campo
		"TPC_LOJA",;	// Id do Field
		"C",;			// Tipo do campo
		02,; 			// Tamanho do campo
		0,;				// Decimal do campo
		Nil,;           // CodeBlock de validação do campo
		Nil,;			// CodeBlock de validação When do campo
		{},;			// Lista de valores permitidos do campo
		.T.,;			// Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, " + cTabela + "->TPC_LOJA,'')" ),; //CodeBlock da inicialização do campo
		.T.,;			// Indica se trata-se de um campo chave
		.F.,;			// Indica se o campo pode receber valor em uma operação de update
		.F.)			// Indica se o campo é virtual
	oCabecTPC:AddField(; //Emissao
		"Emissao",; 		// Título do campo
		"Emissao",; 		// TootlTip do Campo
		"TPC_EMISSA",;	// Id do Field
		"C",;			// Tipo do campo
		08,; 			// Tamanho do campo
		0,;				// Decimal do campo
		Nil,;           // CodeBlock de validação do campo
		Nil,;			// CodeBlock de validação When do campo
		{},;			// Lista de valores permitidos do campo
		.T.,;			// Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, " + cTabela + "->TPC_EMISSA,'')" ),; //CodeBlock da inicialização do campo
		.T.,;			// Indica se trata-se de um campo chave
		.F.,;			// Indica se o campo pode receber valor em uma operação de update
		.F.)			// Indica se o campo é virtual
	oCabecTPC:AddField(; //Valor Bruto
		"ValBrt",; 		// Título do campo
		"ValBrt",; 		// TootlTip do Campo
		"TPC_VALBRU",;	// Id do Field
		"N",;			// Tipo do campo
		14,; 			// Tamanho do campo
		0,;				// Decimal do campo
		Nil,;           // CodeBlock de validação do campo
		Nil,;			// CodeBlock de validação When do campo
		{},;			// Lista de valores permitidos do campo
		.T.,;			// Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, " + cTabela + "->TPC_EMISSA,'')" ),; //CodeBlock da inicialização do campo
		.T.,;			// Indica se trata-se de um campo chave
		.F.,;			// Indica se o campo pode receber valor em uma operação de update
		.F.)			// Indica se o campo é virtual
	oCabecTPC:AddField(; //Serie
		"Serie",; 		// Título do campo
		"Serie",; 		// TootlTip do Campo
		"TPC_SERIE",;	// Id do Field
		"C",;			// Tipo do campo
		03,; 			// Tamanho do campo
		0,;				// Decimal do campo
		Nil,;           // CodeBlock de validação do campo
		Nil,;			// CodeBlock de validação When do campo
		{},;			// Lista de valores permitidos do campo
		.T.,;			// Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, " + cTabela + "->TPC_SERIE,'')" ),; //CodeBlock da inicialização do campo
		.T.,;			// Indica se trata-se de um campo chave
		.F.,;			// Indica se o campo pode receber valor em uma operação de update
		.F.)			// Indica se o campo é virtual
	oCabecTPC:AddField(; //Chave
		"Chave",; 		// Título do campo
		"Chave",; 		// TootlTip do Campo
		"TPC_CHVNFE",;	// Id do Field
		"C",;			// Tipo do campo
		44,; 			// Tamanho do campo
		0,;				// Decimal do campo
		Nil,;           // CodeBlock de validação do campo
		Nil,;			// CodeBlock de validação When do campo
		{},;			// Lista de valores permitidos do campo
		.T.,;			// Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, " + cTabela + "->TPC_CHVNFE,'')" ),; //CodeBlock da inicialização do campo
		.T.,;			// Indica se trata-se de um campo chave
		.F.,;			// Indica se o campo pode receber valor em uma operação de update
		.F.;			// Indica se o campo é virtual
	)			

	//Adiciona os campos da estrutura da GRID
	oGridTGD:AddField(; //Numero Documento
		"NumDoc",; 		// Título do campo
		"NumDoc",; 		// TootlTip do Campo
		"TGD_DOC",;		// Id do Field
		"C",;			// Tipo do campo
		09,; 			// Tamanho do campo
		0,;				// Decimal do campo
		Nil,;           // CodeBlock de validação do campo
		Nil,;			// CodeBlock de validação When do campo
		{},;			// Lista de valores permitidos do campo
		.T.,;			// Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, " + cTabGrid + "->TGD_DOC,'')" ),; //CodeBlock da inicialização do campo
		.T.,;			// Indica se trata-se de um campo chave
		.F.,;			// Indica se o campo pode receber valor em uma operação de update
		.F.)			// Indica se o campo é virtual
		// Indica se o campo é virtual
	oGridTGD:AddField(; //Sequencia
		"Sequen",; 		// Título do campo
		"Sequen",; 		// TootlTip do Campo
		"TGD_SEQ",;	// Id do Field
		"C",;			// Tipo do campo
		05,; 			// Tamanho do campo
		0,;				// Decimal do campo
		Nil,;           // CodeBlock de validação do campo
		Nil,;			// CodeBlock de validação When do campo
		{},;			// Lista de valores permitidos do campo
		.T.,;			// Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, " + cTabGrid + "->TGD_SEQ,'')" ),; //CodeBlock da inicialização do campo
		.T.,;			// Indica se trata-se de um campo chave
		.F.,;			// Indica se o campo pode receber valor em uma operação de update
		.F.	)			// Indica se o campo é virtual
	oGridTGD:AddField(; //Peso Bruto
		"PesBrt",; 		// Título do campo
		"PesBrt",; 		// TootlTip do Campo
		"TGD_PBRUTO",;	// Id do Field
		"N",;			// Tipo do campo
		11,; 			// Tamanho do campo
		4,;				// Decimal do campo
		Nil,;           // CodeBlock de validação do campo
		Nil,;			// CodeBlock de validação When do campo
		{},;			// Lista de valores permitidos do campo
		.T.,;			// Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, " + cTabGrid + "->TGD_PBRUTO,'')" ),; //CodeBlock da inicialização do campo
		.T.,;			// Indica se trata-se de um campo chave
		.F.,;			// Indica se o campo pode receber valor em uma operação de update
		.F.)			// Indica se o campo é virtual
	oGridTGD:AddField(; //Peso Cubado
		"PesCub",; 		// Título do campo
		"PesCub",; 		// TootlTip do Campo
		"TGD_XPESOC",;	// Id do Field
		"N",;			// Tipo do campo
		13,; 			// Tamanho do campo
		5,;				// Decimal do campo
		Nil,;           // CodeBlock de validação do campo
		Nil,;			// CodeBlock de validação When do campo
		{},;			// Lista de valores permitidos do campo
		.T.,;			// Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, " + cTabGrid + "->TGD_XPESOC,'')" ),; //CodeBlock da inicialização do campo
		.T.,;			// Indica se trata-se de um campo chave
		.F.,;			// Indica se o campo pode receber valor em uma operação de update
		.F.)			// Indica se o campo é virtual
	oGridTGD:AddField(; //PesoR
		"PesOr",; 		// Título do campo
		"PesOr",; 		// TootlTip do Campo
		"TGD_PESOR",;	// Id do Field
		"N",;			// Tipo do campo
		13,; 			// Tamanho do campo
		5,;				// Decimal do campo
		Nil,;           // CodeBlock de validação do campo
		Nil,;			// CodeBlock de validação When do campo
		{},;			// Lista de valores permitidos do campo
		.T.,;			// Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, " + cTabGrid + "->TGD_PESOR,'')" ),; //CodeBlock da inicialização do campo
		.T.,;			// Indica se trata-se de um campo chave
		.F.,;			// Indica se o campo pode receber valor em uma operação de update
		.F.)			// Indica se o campo é virtual
	oGridTGD:AddField(; //PesoC
		"PesC",; 		// Título do campo
		"PesC",; 		// TootlTip do Campo
		"TGD_PESOC",;	// Id do Field
		"N",;			// Tipo do campo
		13,; 			// Tamanho do campo
		5,;				// Decimal do campo
		Nil,;           // CodeBlock de validação do campo
		Nil,;			// CodeBlock de validação When do campo
		{},;			// Lista de valores permitidos do campo
		.T.,;			// Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI, " + cTabela + "->TGD_PESOC,'')" ),; //CodeBlock da inicialização do campo
		.T.,;			// Indica se trata-se de um campo chave
		.F.,;			// Indica se o campo pode receber valor em uma operação de update
		.F.;
	)			// Indica se o campo é virtual

	//Bloqueia alteração no campo (deixa cinza).
	//oStruPai:SetProperty('F2_DOC' , MODEL_FIELD_WHEN,{|| .F. })

	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New('ZGFEF08M', bPre, bPos, bCommit, bCancel)

	oModel:AddFields('TPCMASTER', /*cOwner*/, oCabecTPC)

	oModel:AddGrid("TGDGRID","TPCMASTER", oGridTGD)

	//Fazendo o relacionamento (similar ao left join do sql)
	aAdd(aRelation, {"TGD_DOC", "TPC_DOC"}) //Na esquerda é o filho e na direitra é o Pai.
	oModel:SetRelation("TGDGRID", aRelation, (cTabGrid)->(IndexKey(1)))

	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel( "TPCMASTER" ):SetDescription("Dados de - " + cTitulo)
	oModel:GetModel( "TGDGRID"   ):SetDescription("Grid de - "  + cTitulo)

	//Define a chave primária utilizada pelo modelo
	oModel:SetPrimaryKey({})

Return oModel

Static Function ViewDef()

	Local oModel     := FWLoadModel("ZGFEF008")
	Local oCabecTPC  := FWFormViewStruct():New()
	Local oGridTGD 	 := FWFormViewStruct():New()
	Local oView 	 := Nil

	//Adicionando campos da estrutura.
	oCabecTPC:AddField(; //01 Nome
	"TPC_NOME",;			//[01]  C  Nome do campo
	"01",;					//[02]  C  Ordem
	"Nome",; 				//[03]  C  Titulo do campo
	"Nome",; 				//[04]  C  Descicao do campo
	Nil,; 					//[05]  A  Array com Help
	"C",;					//[06]  C  Tipo do campo
	"@!",;					//[07]  C  Picture
	Nil,;					//[08]  B  Bloco de PicTree Var
	Nil,;					//[09]  C  Consulta F3
	Iif(INCLUI, .T., .F.),; //[10]  L  Indica se o campo é alterável.
	Nil,;   				//[11]  C  Pasta do campo
	Nil,;					//[12]  C  Agrupamento do campo
	Nil,;					//[13]  A  Lista de valores permitido no campo (combo)
	Nil,;					//[14]  N  Tamanho máximo da maior opção do combo.
	Nil,; 					//[15]  C  Inicialiazdor de browse
	Nil,; 					//[16]  L  Indica se o campo é virtual
	Nil,; 					//[17]  C  Picture variável
	Nil)					//[18]  L  Indica pulo de linha após o campo
	oCabecTPC:AddField(; //02 Cliente
	"TPC_CLIENT",;			//[01]  C  Nome do campo
	"02",;					//[02]  C  Ordem
	"Cliente",; 			//[03]  C  Titulo do campo
	"Cliente",; 			//[04]  C  Descicao do campo
	Nil,; 					//[05]  A  Array com Help
	"C",;					//[06]  C  Tipo do campo
	"@!",;					//[07]  C  Picture
	Nil,;					//[08]  B  Bloco de PicTree Var
	Nil,;					//[09]  C  Consulta F3
	Iif(INCLUI, .T., .F.),; //[10]  L  Indica se o campo é alterável.
	Nil,;   				//[11]  C  Pasta do campo
	Nil,;					//[12]  C  Agrupamento do campo
	Nil,;					//[13]  A  Lista de valores permitido no campo (combo)
	Nil,;					//[14]  N  Tamanho máximo da maior opção do combo.
	Nil,; 					//[15]  C  Inicialiazdor de browse
	Nil,; 					//[16]  L  Indica se o campo é virtual
	Nil,; 					//[17]  C  Picture variável
	Nil)					//[18]  L  Indica pulo de linha após o campo
	oCabecTPC:AddField(; //03 Loja
	"TPC_LOJA",;			//[01]  C  Nome do campo
	"03",;					//[02]  C  Ordem
	"Loja",; 				//[03]  C  Titulo do campo
	"loja",; 				//[04]  C  Descicao do campo
	Nil,; 					//[05]  A  Array com Help
	"C",;					//[06]  C  Tipo do campo
	"@!",;					//[07]  C  Picture
	Nil,;					//[08]  B  Bloco de PicTree Var
	Nil,;					//[09]  C  Consulta F3
	Iif(INCLUI, .T., .F.),; //[10]  L  Indica se o campo é alterável.
	Nil,;   				//[11]  C  Pasta do campo
	Nil,;					//[12]  C  Agrupamento do campo
	Nil,;					//[13]  A  Lista de valores permitido no campo (combo)
	Nil,;					//[14]  N  Tamanho máximo da maior opção do combo.
	Nil,; 					//[15]  C  Inicialiazdor de browse
	Nil,; 					//[16]  L  Indica se o campo é virtual
	Nil,; 					//[17]  C  Picture variável
	Nil)					//[18]  L  Indica pulo de linha após o campo
	oCabecTPC:AddField(; //04 Emissão
	"TPC_EMISSA",;			//[01]  C  Nome do campo
	"04",;					//[02]  C  Ordem
	"Emissao",; 				//[03]  C  Titulo do campo
	"Emissao",; 				//[04]  C  Descicao do campo
	Nil,; 					//[05]  A  Array com Help
	"C",;					//[06]  C  Tipo do campo
	"D",;					//[07]  C  Picture
	Nil,;					//[08]  B  Bloco de PicTree Var
	Nil,;					//[09]  C  Consulta F3
	Iif(INCLUI, .T., .F.),; //[10]  L  Indica se o campo é alterável.
	Nil,;   				//[11]  C  Pasta do campo
	Nil,;					//[12]  C  Agrupamento do campo
	Nil,;					//[13]  A  Lista de valores permitido no campo (combo)
	Nil,;					//[14]  N  Tamanho máximo da maior opção do combo.
	Nil,; 					//[15]  C  Inicialiazdor de browse
	Nil,; 					//[16]  L  Indica se o campo é virtual
	Nil,; 					//[17]  C  Picture variável
	Nil)					//[18]  L  Indica pulo de linha após o campo
	oCabecTPC:AddField(; //05 Valor Bruto
	"TPC_VALBRU",;			//[01]  C  Nome do campo
	"05",;					//[02]  C  Ordem
	"VlrBrt",; 			//[03]  C  Titulo do campo
	"VlrBrt",; 			//[04]  C  Descicao do campo
	Nil,; 					//[05]  A  Array com Help
	"N",;					//[06]  C  Tipo do campo
	Nil,;					//[07]  C  Picture
	Nil,;					//[08]  B  Bloco de PicTree Var
	Nil,;					//[09]  C  Consulta F3
	Iif(INCLUI, .T., .F.),; //[10]  L  Indica se o campo é alterável.
	Nil,;   				//[11]  C  Pasta do campo
	Nil,;					//[12]  C  Agrupamento do campo
	Nil,;					//[13]  A  Lista de valores permitido no campo (combo)
	Nil,;					//[14]  N  Tamanho máximo da maior opção do combo.
	Nil,; 					//[15]  C  Inicialiazdor de browse
	Nil,; 					//[16]  L  Indica se o campo é virtual
	Nil,; 					//[17]  C  Picture variável
	Nil)					//[18]  L  Indica pulo de linha após o campo

	oCabecTPC:AddField(; //06 Numero Documento
	"TPC_DOC",;				//[01]  C  Nome do campo
	"06",;					//[02]  C  Ordem
	"NumDoc",; 				//[03]  C  Titulo do campo
	"NumDoc",; 				//[04]  C  Descicao do campo
	Nil,; 					//[05]  A  Array com Help
	"C",;					//[06]  C  Tipo do campo
	"@!",;					//[07]  C  Picture
	Nil,;					//[08]  B  Bloco de PicTree Var
	Nil,;					//[09]  C  Consulta F3
	Iif(INCLUI, .T., .F.),; //[10]  L  Indica se o campo é alterável.
	Nil,;   				//[11]  C  Pasta do campo
	Nil,;					//[12]  C  Agrupamento do campo
	Nil,;					//[13]  A  Lista de valores permitido no campo (combo)
	Nil,;					//[14]  N  Tamanho máximo da maior opção do combo.
	Nil,; 					//[15]  C  Inicialiazdor de browse
	Nil,; 					//[16]  L  Indica se o campo é virtual
	Nil,; 					//[17]  C  Picture variável
	Nil)					//[18]  L  Indica pulo de linha após o campo
	oCabecTPC:AddField(; //07 Serie
	"TPC_SERIE",;				//[01]  C  Nome do campo
	"07",;					//[02]  C  Ordem
	"Serie",; 				//[03]  C  Titulo do campo
	"Serie",; 				//[04]  C  Descicao do campo
	Nil,; 					//[05]  A  Array com Help
	"C",;					//[06]  C  Tipo do campo
	"@!",;					//[07]  C  Picture
	Nil,;					//[08]  B  Bloco de PicTree Var
	Nil,;					//[09]  C  Consulta F3
	Iif(INCLUI, .T., .F.),; //[10]  L  Indica se o campo é alterável.
	Nil,;   				//[11]  C  Pasta do campo
	Nil,;					//[12]  C  Agrupamento do campo
	Nil,;					//[13]  A  Lista de valores permitido no campo (combo)
	Nil,;					//[14]  N  Tamanho máximo da maior opção do combo.
	Nil,; 					//[15]  C  Inicialiazdor de browse
	Nil,; 					//[16]  L  Indica se o campo é virtual
	Nil,; 					//[17]  C  Picture variável
	Nil)					//[18]  L  Indica pulo de linha após o campo
	oCabecTPC:AddField(; //08 Chave
	"TPC_CHVNFE",;			//[01]  C  Nome do campo
	"08",;					//[02]  C  Ordem
	"Chave",; 				//[03]  C  Titulo do campo
	"Chave",; 				//[04]  C  Descicao do campo
	Nil,; 					//[05]  A  Array com Help
	"C",;					//[06]  C  Tipo do campo
	"@!",;					//[07]  C  Picture
	Nil,;					//[08]  B  Bloco de PicTree Var
	Nil,;					//[09]  C  Consulta F3
	Iif(INCLUI, .T., .F.),; //[10]  L  Indica se o campo é alterável.
	Nil,;   				//[11]  C  Pasta do campo
	Nil,;					//[12]  C  Agrupamento do campo
	Nil,;					//[13]  A  Lista de valores permitido no campo (combo)
	Nil,;					//[14]  N  Tamanho máximo da maior opção do combo.
	Nil,; 					//[15]  C  Inicialiazdor de browse
	Nil,; 					//[16]  L  Indica se o campo é virtual
	Nil,; 					//[17]  C  Picture variável
	Nil;					//[18]  L  Indica pulo de linha após o campo
	)			//Campos do CABEC declarados

	oGridTGD:AddField(; //01 Numero Documento
	"TGD_DOC",;				//[01]  C  Nome do campo
	"01",;					//[02]  C  Ordem
	"NumDoc",; 				//[03]  C  Titulo do campo
	"NumDoc",; 				//[04]  C  Descicao do campo
	Nil,; 					//[05]  A  Array com Help
	"C",;					//[06]  C  Tipo do campo
	"@!",;					//[07]  C  Picture
	Nil,;					//[08]  B  Bloco de PicTree Var
	Nil,;					//[09]  C  Consulta F3
	Iif(INCLUI, .T., .F.),; //[10]  L  Indica se o campo é alterável.
	Nil,;   				//[11]  C  Pasta do campo
	Nil,;					//[12]  C  Agrupamento do campo
	Nil,;					//[13]  A  Lista de valores permitido no campo (combo)
	Nil,;					//[14]  N  Tamanho máximo da maior opção do combo.
	Nil,; 					//[15]  C  Inicialiazdor de browse
	Nil,; 					//[16]  L  Indica se o campo é virtual
	Nil,; 					//[17]  C  Picture variável
	Nil)					//[18]  L  Indica pulo de linha após o campo

	oGridTGD:AddField(; //02 Sequencia
	"TGD_SEQ",;			//[01]  C  Nome do campo
	"02",;					//[02]  C  Ordem
	"Sequencia",; 			//[03]  C  Titulo do campo
	"Sequencia",; 			//[04]  C  Descicao do campo
	Nil,; 					//[05]  A  Array com Help
	"C",;					//[06]  C  Tipo do campo
	"@!",;					//[07]  C  Picture
	Nil,;					//[08]  B  Bloco de PicTree Var
	Nil,;					//[09]  C  Consulta F3
	Iif(INCLUI, .T., .F.),; //[10]  L  Indica se o campo é alterável.
	Nil,;   				//[11]  C  Pasta do campo
	Nil,;					//[12]  C  Agrupamento do campo
	Nil,;					//[13]  A  Lista de valores permitido no campo (combo)
	Nil,;					//[14]  N  Tamanho máximo da maior opção do combo.
	Nil,; 					//[15]  C  Inicialiazdor de browse
	Nil,; 					//[16]  L  Indica se o campo é virtual
	Nil,; 					//[17]  C  Picture variável
	Nil)					//[18]  L  Indica pulo de linha após o campo
	oGridTGD:AddField(; //03 Peso bruto
	"TGD_PBRUTO",;			//[01]  C  Nome do campo
	"03",;					//[02]  C  Ordem
	"PesoBrt",; 				//[03]  C  Titulo do campo
	"PesoBrt",; 				//[04]  C  Descicao do campo
	Nil,; 					//[05]  A  Array com Help
	"N",;					//[06]  C  Tipo do campo
	"@!",;					//[07]  C  Picture
	Nil,;					//[08]  B  Bloco de PicTree Var
	Nil,;					//[09]  C  Consulta F3
	Iif(INCLUI, .T., .F.),; //[10]  L  Indica se o campo é alterável.
	Nil,;   				//[11]  C  Pasta do campo
	Nil,;					//[12]  C  Agrupamento do campo
	Nil,;					//[13]  A  Lista de valores permitido no campo (combo)
	Nil,;					//[14]  N  Tamanho máximo da maior opção do combo.
	Nil,; 					//[15]  C  Inicialiazdor de browse
	Nil,; 					//[16]  L  Indica se o campo é virtual
	Nil,; 					//[17]  C  Picture variável
	Nil)					//[18]  L  Indica pulo de linha após o campo
	oGridTGD:AddField(; //04 Peso Cubado
	"TGD_XPESOC",;			//[01]  C  Nome do campo
	"04",;					//[02]  C  Ordem
	"PesCub",; 				//[03]  C  Titulo do campo
	"PesCub",; 				//[04]  C  Descicao do campo
	Nil,; 					//[05]  A  Array com Help
	"N",;					//[06]  C  Tipo do campo
	"@!",;					//[07]  C  Picture
	Nil,;					//[08]  B  Bloco de PicTree Var
	Nil,;					//[09]  C  Consulta F3
	Iif(INCLUI, .T., .F.),; //[10]  L  Indica se o campo é alterável.
	Nil,;   				//[11]  C  Pasta do campo
	Nil,;					//[12]  C  Agrupamento do campo
	Nil,;					//[13]  A  Lista de valores permitido no campo (combo)
	Nil,;					//[14]  N  Tamanho máximo da maior opção do combo.
	Nil,; 					//[15]  C  Inicialiazdor de browse
	Nil,; 					//[16]  L  Indica se o campo é virtual
	Nil,; 					//[17]  C  Picture variável
	Nil)					//[18]  L  Indica pulo de linha após o campo
	oGridTGD:AddField(; //05 PesoR
	"TGD_PESOR",;			//[01]  C  Nome do campo
	"05",;					//[02]  C  Ordem
	"PesoR",; 				//[03]  C  Titulo do campo
	"PesoR",; 				//[04]  C  Descicao do campo
	Nil,; 					//[05]  A  Array com Help
	"N",;					//[06]  C  Tipo do campo
	"@!",;					//[07]  C  Picture
	Nil,;					//[08]  B  Bloco de PicTree Var
	Nil,;					//[09]  C  Consulta F3
	Iif(INCLUI, .T., .F.),; //[10]  L  Indica se o campo é alterável.
	Nil,;   				//[11]  C  Pasta do campo
	Nil,;					//[12]  C  Agrupamento do campo
	Nil,;					//[13]  A  Lista de valores permitido no campo (combo)
	Nil,;					//[14]  N  Tamanho máximo da maior opção do combo.
	Nil,; 					//[15]  C  Inicialiazdor de browse
	Nil,; 					//[16]  L  Indica se o campo é virtual
	Nil,; 					//[17]  C  Picture variável
	Nil)					//[18]  L  Indica pulo de linha após o campo
	oGridTGD:AddField(; //06 PesoC
	"TGD_PESOC",;			//[01]  C  Nome do campo
	"06",;					//[02]  C  Ordem
	"PesoC",; 				//[03]  C  Titulo do campo
	"PesoC",; 				//[04]  C  Descicao do campo
	Nil,; 					//[05]  A  Array com Help
	"N",;					//[06]  C  Tipo do campo
	"@!",;					//[07]  C  Picture
	Nil,;					//[08]  B  Bloco de PicTree Var
	Nil,;					//[09]  C  Consulta F3
	Iif(INCLUI, .T., .F.),; //[10]  L  Indica se o campo é alterável.
	Nil,;   				//[11]  C  Pasta do campo
	Nil,;					//[12]  C  Agrupamento do campo
	Nil,;					//[13]  A  Lista de valores permitido no campo (combo)
	Nil,;					//[14]  N  Tamanho máximo da maior opção do combo.
	Nil,; 					//[15]  C  Inicialiazdor de browse
	Nil,; 					//[16]  L  Indica se o campo é virtual
	Nil,; 					//[17]  C  Picture variável
	Nil;					//[18]  L  Indica pulo de linha após o campo
	)			//Campo da grid declarados.

	//Cria a visualizacao de cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Isso precisa ser amarrado ao ModelDef
	oView:AddField("VIEW_TPC", oCabecTPC  ,"TPCMASTER") //Sessão de campos
	oView:AddGrid("VIEW_GRID",oGridTGD  ,"TGDGRID")

	//Distribuição da tela
	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID" , 70)
	oView:SetOwnerView("VIEW_TPC", "CABEC")
	oView:SetOwnerView("VIEW_GRID", "GRID")
	oView:SetCloseOnOk({||.T.})

	//Título
	oView:EnableTitleView("VIEW_TPC","Cabeçalho - TPC")
	oView:EnableTitleView("VIEW_GRID","Itens - TGD")

Return oView

//Popula tabela temporária
Static Function fPopula(cNumDoc)

	Default cNumDoc := "000000039" //Número da NF a ser pesquisado na query,
	Default cTabela 	:= "TPC" //Temporaria Peso Cubado
	Default cTabGrid 	:= "TGD" //Temporaria Peso Cubado

	Local cQry		:= ""
	Local aCampoFd	:= {}
	Local aCampoGd 	:= {}
	Local lRet 		:= .F.
	Local oTmpTabFd
	Local oTmpTabGd

	Private cArqTPC

	cTab 	:= GetNextAlias()

	cQry := " SELECT " 						+ CRLF
	cQry += " 		SA2.A2_NOME " 			+ CRLF
	cQry += " 		, SF2.F2_CLIENTE " 		+ CRLF
	cQry += " 		, SF2.F2_LOJA " 		+ CRLF
	cQry += " 		, SF2.F2_EMISSAO "		+ CRLF
	cQry += " 		, SF2.F2_VALBRUT " 		+ CRLF
	cQry += " 		, GW8.GW8_SEQ " 		+ CRLF
	cQry += " 		, SF2.F2_DOC " 			+ CRLF
	cQry += " 		, SF2.F2_SERIE " 		+ CRLF
	cQry += " 		, SF2.F2_CHVNFE " 		+ CRLF
	cQry += " 		, SF2.F2_PBRUTO " 		+ CRLF
	cQry += " 		, SF2.F2_XPESOC " 		+ CRLF  //--PESO CUBADO TOTAL
	cQry += " 		, GW8.GW8_PESOR " 		+ CRLF  //--PESO BRUTO
	cQry += " 		, GW8.GW8_PESOC " 		+ CRLF  //--PESO CUBADO
	cQry += " FROM " 	  +  RetSQLName("SF2") + " SF2 " 			+ CRLF	//--CABEÇALHO DE NOTA FISCAL SAÍDA
	cQry += " LEFT JOIN " +  RetSQLName("GW8") + " GW8 " 			+ CRLF	//--ITENS DO DOCUMENTO DE CARGA
	cQry += " 		ON GW8.GW8_FILIAL 	= '" + xFilial("GW8") + "'" + CRLF
	cQry += " 		AND GW8.GW8_NRDC	= SF2.F2_DOC " 				+ CRLF
	cQry += " 		AND GW8.GW8_SERDC 	= SF2.F2_SERIE " 			+ CRLF
	cQry += " 		AND GW8.D_E_L_E_T_	= ' ' " 					+ CRLF
	cQry += " LEFT JOIN " +  RetSQLName("SA2") + " SA2 " 			+ CRLF	//--CADASTRO DE FORNECEDORES
	cQry += "		ON SA2.A2_FILIAL 	= '" + xFilial("SA2") + "'" + CRLF
	cQry += "		AND SA2.A2_COD 		= SF2.F2_CLIENTE " 			+ CRLF
	cQry += "		AND SA2.A2_LOJA 	= SF2.F2_LOJA " 			+ CRLF
	cQry += "		AND SA2.D_E_L_E_T_ 	= ' ' " 					+ CRLF
	cQry += " WHERE GW8_CDTPDC = 'NFS' " 							+ CRLF
	cQry += "		AND SF2.F2_CHVNFE  != ' ' " 					+ CRLF
	cQry += "		AND SF2.F2_DOC != ' ' " 						+ CRLF
	cQry += "		AND SF2.F2_DOC = '" + cNumDoc + "' " 			+ CRLF
	cQry += " 		AND SF2.D_E_L_E_T_ 	= ' ' " 					+ CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTab, .T., .T. )

	DbSelectArea((cTab))
	(cTab)->(dbGoTop())

	//Criar tabela temporária com indíce do CABEC
	If !(cTab)->(Eof())

		//Início - Grava temporaria das informações do CABEC (cabeçalho).
			//Adicionar ao array as informações dos campos da tabela temporária
			AAdd(aCampoFd,{"TPC_DOC"      ,"C",009,0}) // [01]
			AAdd(aCampoFd,{"TPC_NOME"     ,"C",040,0}) // [02]
			AAdd(aCampoFd,{"TPC_CLIENT"   ,"C",006,0}) // [03]
			AAdd(aCampoFd,{"TPC_LOJA"     ,"C",002,0}) // [04]
			AAdd(aCampoFd,{"TPC_EMISSA"   ,"C",008,0}) // [05]
			AAdd(aCampoFd,{"TPC_VALBRU"   ,"N",014,0}) // [06]
			AAdd(aCampoFd,{"TPC_SERIE"    ,"C",003,0}) // [07]
			AAdd(aCampoFd,{"TPC_CHVNFE"   ,"C",044,0}) // [08]

			//Se o alias estiver aberto, fechar para evitar erros com alias aberto
			If (Select("TPC") <> 0)
				dbSelectArea("TPC")
				TPC->(dbCloseArea())
			Endif

			//Cria a temporária
			oTmpTabFd := FWTemporaryTable():New(cTabela)
			oTmpTabFd:SetFields(aCampoFd)
			oTmpTabFd:AddIndex("1", {"TPC_DOC"})
			oTmpTabFd:Create()

			(cTab)->(dbGoTop())
			While (cTab)->(!Eof())
				If RecLock("TPC",.T.)
					TPC->TPC_DOC 		:= (cTab)->F2_DOC
					TPC->TPC_NOME 		:= (cTab)->A2_NOME
					TPC->TPC_CLIENT		:= (cTab)->F2_CLIENTE
					TPC->TPC_LOJA 		:= (cTab)->F2_LOJA
					TPC->TPC_EMISSA    	:= (cTab)->F2_EMISSAO
					TPC->TPC_VALBRU 	:= (cTab)->F2_VALBRUT
					TPC->TPC_SERIE    	:= (cTab)->F2_SERIE
					TPC->TPC_CHVNFE 	:= (cTab)->F2_CHVNFE
					TPC->(MsUnLock())
				Endif
				(cTab)->(DbSkip())
			EndDo

		//Fim - Grava temporaria das informações do CABEC (cabeçalho).

		//Início - Grava temporaria das informações da GRID.
			//Adicionar ao array as informações dos campos da tabela temporária
			AAdd(aCampoGd,{"TGD_DOC"      ,"C",009,0}) // [01]
			AAdd(aCampoGd,{"TGD_SEQ"      ,"C",005,0}) // [02]
			AAdd(aCampoGd,{"TGD_PBRUTO"   ,"N",011,4}) // [03]
			AAdd(aCampoGd,{"TGD_XPESOC"   ,"N",013,5}) // [04]
			AAdd(aCampoGd,{"TGD_PESOR"    ,"N",013,5}) // [05]
			AAdd(aCampoGd,{"TGD_PESOC"    ,"N",013,5}) // [06]

			//Se o alias estiver aberto, fechar para evitar erros com alias aberto
			If (Select("TGD") <> 0)
				dbSelectArea("TGD")
				TGD->(dbCloseArea())
			Endif

			//Cria a temporária
			oTmpTabGd := FWTemporaryTable():New(cTabGrid)
			oTmpTabGd:SetFields(aCampoGd)
			oTmpTabGd:AddIndex("1", {"TGD_DOC"})
			oTmpTabGd:Create()
			
			(cTab)->(dbGoTop())
			While (cTab)->(!Eof())
				If RecLock("TGD",.T.)
					TGD->TGD_DOC 		:= (cTab)->F2_DOC
					TGD->TGD_SEQ	 	:= (cTab)->GW8_SEQ
					TGD->TGD_PBRUTO	 	:= (cTab)->F2_PBRUTO
					TGD->TGD_XPESOC 	:= (cTab)->F2_XPESOC
					TGD->TGD_PESOR    	:= (cTab)->GW8_PESOR
					TGD->TGD_PESOC 		:= (cTab)->GW8_PESOC
					TPC->(MsUnLock())
				Endif
				(cTab)->(DbSkip())
			EndDo
		//Fim - Grava temporaria das informações da GRID.

		lRet := .T.
	Endif

Return lRet
