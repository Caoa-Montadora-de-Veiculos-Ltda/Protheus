//Bibliotecas
#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "FWMVCDEF.ch"

//Variáveis estatisticas
Static cTitulo      := "Notas Fiscas"
Static cTabPai      := "SF2" //Cabeçalho de NF
Static cTabFilho    := "SD2" //Itens de NF
Static cTab 		:= "TPC" //Tabela temporária criada.

User function ZGFEF008()

	Local aArea     := GetArea()
	Local oBrowse
	Local lRet 		:= .F.
	Local cNumDoc 	:= "000000039"
	Local cFunBkp   := FunName()

	Private aRotina := {}
	Private cTabela := "" //Usada em fPopula

	SetFunName("ZGFEF008")

	//Begin Sequence
		//Popular Tabela Temporária
		lRet := fPopula(cNumDoc)

		(cTabela)->(DbCloseArea())
		TPC->(DbGoTop())

		If TPC->(!Eof()) .and. lRet
			//Cria a tabela utilizada no processo
			ChkFile(cTab)

			//Força posicionamento na tabela no arquivo SX2
			//PosSx2(cTabela)

			//Define o título da tabela baseado no arquivo SX2
			//cTitulo:= Capital(FwSX2Util():GetX2Name(cTab, .T.))

			//Definição do menu
			aRotina := MenuDef()

			//Instânciando FWMBrowse - Somente com dicionário de dados
			oBrowse:= FWMBrowse():New()

			//Setando a tabela de cadastro de Autor/Interprete
			oBrowse:SetAlias(cTab)

			//Setando a descrição da rotina
			oBrowse:SetDescription(cTitulo)
			oBrowse:DisableDetails()
		
			//Ativa a Browse
			oBrowse:Activate()
		Else
			Return
			//Break
		EndIf
	
		/*
		//Instanciando o browse
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias(cTabPai)
		//Define os campos que aparecem no Browse
		oBrowse:SetOnlyFields({'F2_DOC','F2_SERIE','F2_LOJA','F2_EMISSAO'})
		oBrowse:SetDescription(cTitulo)
		oBrowse:DisableDetails()
		//Ativa o Browse
		oBrowse:Activate()
		*/
	//End Sequence
	
	SetFunName(cFunBkp)
	RestArea(aArea)

Return Nil

Static Function MenuDef()

	Local aRotina := {}

	//Adicionando opções de menu
	ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.ZGEF008" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"      ACTION "VIEWDEF.ZGEF008" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.ZGEF008" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"      ACTION "VIEWDEF.ZGEF008" OPERATION 5 ACCESS 0

Return aRotina

//Cria o modelo de dados para cadastro
Static Function ModelDef()

	//Local oStruPai   := FWFormStruct(1, cTabPai  , { |x| Alltrim(x) $ 'F2_DOC,F2_SERIE,F2_LOJA,F2_COND,F2_DUPL'}) 
	//Local oStruFilho := FWFormStruct(1, cTabFilho, { |x| Alltrim(x) $ 'D2_ITEM,D2_COD,D2_QUANT,D2_UM,D2_PRCVEN,D2_TOTAL'  })
	Local oStruTab 	 := FWFormStruct(1, cTab) //Opção 1 -> ModelDef || Opção 2 -> ViewDef.
	Local oStruGrid  := FWFormStruct(1, cTab) //Opção 1 -> ModelDef || Opção 2 -> ViewDef.
	Local oModel

	Local aRelation := {}

	//Blocos de código para criar validações
	Local bPre      := Nil //Antes de abrir o formulário.
	Local bPos      := Nil //Ao clicar no confirmar, antes de salvar.
	Local bCommit   := Nil //Após fechar o formulário quando for salvar.
	Local bCancel   := Nil //Quando o usuário cancelar o formulário

	//Bloqueia alteração no campo (deixa cinza).
	//oStruPai:SetProperty('F2_DOC' , MODEL_FIELD_WHEN,{|| .F. })

	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("ZGFEF08M", bPre, bPos, bCommit, bCancel)

	oModel:AddFields("TPCMASTER", /*cOwner*/, oStruTab)
	oModel:AddGrid("TPCGRID","TPCMASTER", oStruGrid, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/, /*bPos Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)
	oModel:SetDescription("Modelo de dados - " + cTitulo) //SF2MASTER -> Nome da estrutrua de campos.
	oModel:GetModel("TPCMASTER"):SetDescription("Dados de - " + cTitulo)
	oModel:GetModel("TPCGRID"):SetDescription("Grid de - " + cTitulo)

	//Define a chave primária utilizada pelo modelo
	oModel:SetPrimaryKey({})

	//Fazendo o relacionamento (similar ao left join do sql)
	aAdd(aRelation, {"TPC_DOC", "TPC_DOC"}) //A filial "não preisa" ser relacionada. //Na esquerda é o filho e na direitra é o Pai.
	aAdd(aRelation, {"TPC_SERIE","TPC_SERIE"})
	oModel:SetRelation("TPCGRID", aRelation, TCP->(IndexKey(1)))

Return oModel

Static Function ViewDef()

	Local oView 	 := Nil
	Local oModel     := FWLoadModel("ZGFEF008")
	Local oStruTab   := FWFormStruct(2, cTab) //Opção 1 -> ModelDef || Opção 2 -> ViewDef.
	Local oStruGrid  := FWFormStruct(2, cTab) //Opção 1 -> ModelDef || Opção 2 -> ViewDef.
	//Local oStruPai   := FWFormStruct(2, cTabPai,   { |x| Alltrim(x) $ 'F2_DOC,F2_SERIE,F2_LOJA,F2_COND,F2_DUPL'}) //Opção 2 monta de forma a ser visualizada no formulário.
	//Local oStruFilho := FWFormStruct(2, cTabFilho, { |x| Alltrim(x) $ 'D2_ITEM,D2_COD,D2_QUANT,D2_UM,D2_PRCVEN,D2_TOTAL'})

	//Cria a visualizacao de cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Isso precisa ser amarrado ao ModelDef
	oView:AddField("VIEW_TPC", oStruTab  ,"TPCMASTER") //Sessão de campos
	oView:AddGrid("VIEW_GRID",oStruGrid  ,"TPCGRID")

	//Distribuição da tela
	oView:CreateHorizontalBox("CABEC", 30)
	oView:CreateHorizontalBox("GRID" , 70)
	oView:SetOwnerView("VIEW_TPC", "CABEC")
	oView:SetOwnerView("VIEW_GRID", "GRID")

	//Título
	oView:EnableTitleView("VIEW_TPC","Cabeçalho - TPC")
	oView:EnableTitleView("VIEW_TPC","Itens - TPC")

Return oView

//Popula tabela temporária
Static Function fPopula(cNumDoc)

	Default cNumDoc = "000000039" //Número da NF a ser pesquisado na query,
	Default cTab 	:= "TPC" //Temporaria Peso Cubado

	Local cQry		:= ""
	Local cIndice1  := ""
	Local aCampos 	:= {}
	Local lRet 		:= .F.
		
	Private cArqTPC
	
	cTabela 	:= GetNextAlias()

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

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTabela, .T., .T. )

	DbSelectArea((cTabela))
	(cTabela)->(dbGoTop())

	//Criar tabela temporária com indíce
	If !(cTabela)->(Eof())

		//Adicionar ao array as informações dos campos
		AAdd(aCampos,{"TPC_NOME"     ,"C",040,0})
		AAdd(aCampos,{"TPC_CLIENT"  ,"C",006,0})
		AAdd(aCampos,{"TPC_LOJA"     ,"C",002,0})
		AAdd(aCampos,{"TPC_EMISSA"  ,"D",008,0})
		AAdd(aCampos,{"TPC_VALBRU"  ,"N",014,0})
		AAdd(aCampos,{"TPC_SEQ"      ,"C",005,0})
		AAdd(aCampos,{"TPC_DOC"      ,"C",009,0})
		AAdd(aCampos,{"TPC_SERIE"    ,"C",003,0})
		AAdd(aCampos,{"TPC_CHVNFE"   ,"C",044,0})
		AAdd(aCampos,{"TPC_PBRUTO"   ,"N",011,4})
		AAdd(aCampos,{"TPC_XPESOC"   ,"N",013,5})
		AAdd(aCampos,{"TPC_PESOR"    ,"N",013,5})
		AAdd(aCampos,{"TPC_PESOC"    ,"N",013,5})

		//Se o alias estiver aberto, fechar para evitar erros com alias aberto
		If (Select("TPC") <> 0)
			dbSelectArea("TPC")
			TPC->(dbCloseArea())
		Endif

		//Cria trabalho 
		cArqTPC  := CriaTrab(aCampos,.T.) //Verificar se posso trocar isso pelo FWTemporaryTable ?!
		cIndice1 := Alltrim(CriaTrab(,.F.))
		cIndice1 := Left(cIndice1,5) + Right(cIndice1,2) + "A"

		//Verifica se o indíce existe e deleta ele.
		If File(cIndice1 + OrdBagExt())
			FErase(cIndice1 + OrdBagExt())
		EndIf
		
		dbUseArea(.T.,,cArqTPC,"TPC",Nil,.F.)
		IndRegua("TPC", cIndice1, "TPC_DOC" ,,, "Indice Produto...")

		//Fecha todos os índices da área de trabalho corrente.
		dbClearIndex()

		//Acrescenta uma ou mais ordens de determinado índice de ordens ativas da área de trabalho.
		dbSetIndex(cIndice1+OrdBagExt())

		(cTabela)->(dbGoTop())
		While (cTabela)->(!Eof())
			If RecLock("TPC",.T.)
				TPC->TPC_NOME 		:= (cTabela)->A2_NOME
				TPC->TPC_CLIENT	:= (cTabela)->F2_CLIENTE
				TPC->TPC_LOJA 		:= (cTabela)->F2_LOJA
				TPC->TPC_EMISSA    := (cTabela)->F2_EMISSAO
				TPC->TPC_VALBRU 	:= (cTabela)->F2_VALBRUT
				TPC->TPC_SEQ	 	:= (cTabela)->GW8_SEQ
				TPC->TPC_DOC 		:= (cTabela)->F2_DOC
				TPC->TPC_SERIE    	:= (cTabela)->F2_SERIE
				TPC->TPC_CHVNFE 	:= (cTabela)->F2_CHVNFE
				TPC->TPC_PBRUTO	 	:= (cTabela)->F2_PBRUTO
				TPC->TPC_XPESOC 	:= (cTabela)->F2_XPESOC
				TPC->TPC_PESOR    	:= (cTabela)->GW8_PESOR
				TPC->TPC_PESOC 		:= (cTabela)->GW8_PESOC
				TPC->(MsUnLock())
			Endif
			(cTabela)->(DbSkip())
		EndDo
		lRet := .T.
		
	Endif

	//Apaga indíce e tabela atrelados a variável cArqTPC e fecha a área TPC.
	If !Empty(cArqTPC)
		Ferase(cArqTPC+GetDBExtension())
		Ferase(cArqTPC+OrdBagExt())
		cArqTPC := " "
		TPC->(DbCloseArea())
	Endif

Return lRet
