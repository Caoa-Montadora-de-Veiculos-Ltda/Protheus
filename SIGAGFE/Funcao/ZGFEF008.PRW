//Bibliotecas
#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "FWMVCDEF.ch"

//Variáveis estatisticas
Static cTitulo      := "Ajuste de Peso - Notas Fiscas"
Static cTabPai      := "SF2" //Cabeçalho de NF.
Static cTabFilho    := "GW8" //Itens do documento de carga.

/*
=====================================================================================
Programa.:              ZGFEF008.PRW
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              05/01/24
Descricao / Objetivo:   Tela para alterar peso cubado e peso bruto de NF emitida.
Doc. Origem:            GAP032
Solicitante:            Micaellen Leal
Uso......:              
Obs......:              
=====================================================================================
*/
User function ZGFEF008()

	Local aArea     := GetArea()
	Local cFunBkp   := FunName()

	Private aRotina := {}

	SetFunName("ZGFEF008")

	SetFunName(cFunBkp)
	RestArea(aArea)

Return Nil

Static Function MenuDef()

	Local aRotina := {}

	//Adicionando opções de menu

	ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.ZGFEF008" OPERATION 4 ACCESS 0

Return aRotina

//Cria o modelo de dados para cadastro
Static Function ModelDef()
	
	Local oModel
	Local oStruPai 	 := FWFormStruct(1, cTabPai)
	Local oStruFilho := FWFormStruct(1, cTabFilho)
	Local aRelation  := {}
	Local bPre       := Nil //Antes de abrir o formulário.
	Local bPos       := {|| u_fCommit() } //Ao clicar no confirmar, antes de salvar.
	Local bCommit    := Nil //Após fechar o formulário quando for salvar.
	Local bCancel    := Nil //Quando o usuário cancelar o formulário
	
	//Bloqueia alteração no campo (deixa cinza).
	oStruPai:SetProperty('F2_DOC'     , MODEL_FIELD_WHEN,{|| .F. })
	oStruPai:SetProperty('F2_SERIE'   , MODEL_FIELD_WHEN,{|| .F. })
	oStruPai:SetProperty('F2_CLIENTE' , MODEL_FIELD_WHEN,{|| .F. })
	oStruPai:SetProperty('F2_LOJA'    , MODEL_FIELD_WHEN,{|| .F. })
	oStruPai:SetProperty('F2_EMISSAO' , MODEL_FIELD_WHEN,{|| .F. })
	oStruPai:SetProperty('F2_VALBRUT' , MODEL_FIELD_WHEN,{|| .F. })
	oStruPai:SetProperty('F2_CHVNFE'  , MODEL_FIELD_WHEN,{|| .F. })

	//Bloqueia alteração no campo (deixa cinza).
	oStruFilho:SetProperty('GW8_SEQ'  , MODEL_FIELD_WHEN,{|| .F. })
	oStruFilho:SetProperty('GW8_ITEM' , MODEL_FIELD_WHEN,{|| .F. })
	oStruFilho:SetProperty('GW8_DSITEM'  , MODEL_FIELD_WHEN,{|| .F. })
	oStruFilho:SetProperty('GW8_PESOR' , MODEL_FIELD_WHEN,{|| .F. })
	oStruFilho:SetProperty('GW8_PESOC'  , MODEL_FIELD_WHEN,{|| .F. })
	oStruFilho:SetProperty('GW8_VALOR' , MODEL_FIELD_WHEN,{|| .F. })

	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New('ZGFEF08M', bPre, bPos, bCommit, bCancel)
	oModel:AddFields("SF2MASTER", /*cOwner*/, oStruPai)
	oModel:AddGrid("GW8GRID","SF2MASTER", oStruFilho)
	oModel:SetDescription(" " + cTitulo)
	oModel:GetModel("SF2MASTER"):SetDescription("Dados de - " + cTitulo)
	oModel:GetModel("GW8GRID"  ):SetDescription("Grid de - "  + cTitulo)

	//Fazendo o relacionamento (similar ao left join do sql)
	aAdd(aRelation, {"GW8_FILIAL", "FWxFilial('GW8')"}) //Na esquerda é o filho e na direitra é o Pai.
	aAdd(aRelation, {"GW8_NRDC", "F2_DOC"}) //Na esquerda é o filho e na direitra é o Pai.
	oModel:SetRelation("GW8GRID", aRelation, GW8->(IndexKey(1)))
	oModel:SetPrimaryKey({})

Return oModel

Static Function ViewDef()

	Local oModel     := FWLoadModel("ZGFEF008")
	Local oStruPai   := FWFormStruct(2, cTabPai  , { |x| Alltrim(x) $ 'F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_CHVNFE, F2_VALBRUT, F2_XPESOC , F2_PBRUTO'})
	Local oStruFilho := FWFormStruct(2, cTabFilho, { |x| Alltrim(x) $ 'GW8_SEQ, GW8_ITEM, GW8_DSITEM, GW8_PESOR, GW8_PESOC, GW8_VALOR'})
	Local oView 	 := Nil

	//Cria a visualizacao de cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB",oStruPai  ,"SF2MASTER") 
	oView:AddGrid("VIEW_GRID",oStruFilho  ,"GW8GRID")

	//Distribuição da tela
	oView:CreateHorizontalBox("CABEC", 60)
	oView:CreateHorizontalBox("GRID" , 40)

	oView:SetOwnerView("VIEW_CAB", "CABEC")
	oView:SetOwnerView("VIEW_GRID", "GRID")

	//Título
	oView:EnableTitleView("VIEW_CAB","Cabeçalho da Nota Fiscal")
	oView:EnableTitleView("VIEW_GRID","Itens da Nota Fiscal")
	
	oStruPai:RemoveField( 'F2_CLIENT' )

	oStruPai:SetProperty('F2_DOC'  	    , MVC_VIEW_ORDEM , '01')
	oStruPai:SetProperty('F2_SERIE' 	, MVC_VIEW_ORDEM , '02')
	oStruPai:SetProperty('F2_CLIENTE'   , MVC_VIEW_ORDEM , '03')
	oStruPai:SetProperty('F2_LOJA' 		, MVC_VIEW_ORDEM , '04')
	oStruPai:SetProperty('F2_EMISSAO' 	, MVC_VIEW_ORDEM , '05')
	oStruPai:SetProperty('F2_CHVNFE' 	, MVC_VIEW_ORDEM , '06')
	oStruPai:SetProperty('F2_VALBRUT' 	, MVC_VIEW_ORDEM , '07')
	oStruPai:SetProperty('F2_XPESOC' 	, MVC_VIEW_ORDEM , '08')
	oStruPai:SetProperty('F2_PBRUTO' 	, MVC_VIEW_ORDEM , '09')
	
	//Definindo que não irá usar o botão "Salvar e Criar Novo"
    oView:SetCloseOnOk({|| .T.})	

Return oView

//PE executado ao clicar no botão confirmar. 
//Valida as informações inseridas e chama rotina de rateiro de peso bruto e cubado. 
User Function fCommit()
	Local aArea := GetArea()

	//Pegando o modelo de dados MVC e pegando os campos
	Local oModelAtiv := FWModelActive()
	Local oModelCad  := oModelAtiv:GetModel('SF2MASTER')
	Local oModelGrid := oModelAtiv:GetModel('GW8GRID')
	Local cPBOrig 	 := SF2->F2_PBRUTO 	//Peso Bruto Original
	Local cPCOrig 	 := SF2->F2_XPESOC 	//Peso Cubado Original
	Local nVlrTot 	 := SF2->F2_VALBRUT	//Valor Bruto Original 
	Local nPBNovo 	 := oModelCad:GetValue('F2_PBRUTO')  //Peso Bruto Novo
	Local nPCNovo 	 := oModelCad:GetValue('F2_XPESOC')  //Peso Cubado Novo
	Local lRet 	  	 := .F.
	Local cMsg    	 := " "
	Local nLin  	 := 0
	Local aPesoCub   := {}
	Local aPesoBrt   := {}
	Local nRec 		 := 0
	Local cTpDoc 	 := " "
	Local cDtEmiss 	 := " "
	Local cSerDc 	 := " "
	Local cNrDc 	 := " "
	Local cSeq 		 := ""

	cMsg += "Alterações: " + CRLF
	cMsg += CRLF + "Peso Cubado Total de: " + Alltrim(cValToChar(cPCOrig))  + " para: " + Alltrim(cValtoChar(nPCNovo)) + " " + CRLF
	cMsg += "Peso Bruto Total de: " + Alltrim(cValToChar(cPBOrig))  + " para: " + Alltrim(cValToChar(nPBNovo)) + " " + CRLF 

	If MsgYesNo(cMsg,"Deseja continuar?")
		//Tratanto cada linha da grid.			
		For nLin := 1 To oModelGrid:Length()
			
			//Posicionando na linha
			oModelGrid:GoLine(nLin)

			//Se a linha não estiver deletada
			If ! oModelGrid:IsDeleted()
				
				cTpDoc 		:= oModelGrid:GetValue("GW8_CDTPDC")
				cDtEmiss 	:= oModelGrid:GetValue("GW8_EMISDC")
				cSerDc 		:= oModelGrid:GetValue("GW8_SERDC")
				cNrDc 		:= oModelGrid:GetValue("GW8_NRDC")
				cSeq 		:= oModelGrid:GetValue("GW8_SEQ")

				DbSelectArea("GW8")
				GW8->(DbSetOrder(2))  //GW8_FILIAL+GW8_CDTPDC+GW8_EMISDC+GW8_SERDC+GW8_NRDC+GW8_SEQ                                                                                                     
				GW8->(DbSeek(FWxFilial("GW8") + cTpDoc + cDtEmiss + cSerDc + cNrDc + cSeq))                                                                         
				nRec := GW8->( Recno() )

				//aPesoCub ou aPesoBrt [1] == Nome do item
				//aPesoCub ou aPesoBrt [2] == Peso CUBADO do item | Peso BRUTO do item
				//aPesoCub ou aPesoBrt [3] == Valor do item GW8
				//aPesoCub ou aPesoBrt [4] == nRec := GW8->( Recno() )
				AAdd(aPesoCub, {oModelGrid:GetValue("GW8_ITEM") ,oModelGrid:GetValue("GW8_PESOC"), oModelGrid:GetValue("GW8_VALOR"), nRec })
				AAdd(aPesoBrt, {oModelGrid:GetValue("GW8_ITEM") ,oModelGrid:GetValue("GW8_PESOR"), oModelGrid:GetValue("GW8_VALOR"), nRec })
			EndIf
			
		Next

		//Faz rateio do peso CUBADO.
		If !(empty(aPesoCub))
			//Distribui os valos de Peso Cubado na Grid e grava na GW8
			lRet := fRateioPC(aPesoCub, nPCNovo, nVlrTot)
			If lRet
				cMsg += CRLF + "Rateio de peso cubado gravado com sucesso." + CRLF
			else
				cMsg += CRLF + "Rateio de peso cubado falhou, verifique com ADM sistemas." + CRLF
			EndIf
		EndIf
		
		//Faz rateiro do peso BRUTO
		If !(empty(aPesoBrt))
			//Distribui os valos de Peso Cubado na Grid e grava na GW8
			lRet := fRateioPB(aPesoBrt, nPBNovo, nVlrTot)
			If lRet
				cMsg += CRLF + "Rateio de peso bruto gravado com sucesso." + CRLF
			else
				cMsg += CRLF + "Rateio de peso bruto falhou, verifique com ADM sistemas." + CRLF
			EndIf
		EndIf
		FWAlertInfo(cMsg, "Informações gravadas.")
	Else
		lRet := .F.
		Help("",1,"ZGFEF008",,"Dados não alterados.",1) // "Preencher o campo Loja do Prospect." 
	EndIf
	
	RestArea(aArea)
Return lRet

//Distribui os valores de peso CUBADO na grid e grava na tabela GW8 via RecLock
Static Function fRateioPC(aPesoCub, nPCNovo, nVlrTot)
	Local nLin 		:= 0
	Local nResult 	:= 0
	Local nSomaPC	:= 0
	Local lRet 		:= .F.
	Local aPCItem	:= {}
	Local nRec 		:= 0
	
	Default nVlrTot := 0
	Default nPCNovo := 0

	For nLin := 1 To Len(aPesoCub)		
		nResult :=  (nPCNovo / nVlrTot) * (aPesoCub[nLin][3])
		Aadd(aPCItem, nResult)
		nSomaPC := nSomaPC + nResult
		nResult := 0
	Next
	
	//Verificar o total dos novos valores da Grid
	If (nSomaPC == nPCNovo) .and. ! empty(aPCItem)

		//Grava as informações na tabela GW8 (grid)
		For nLin := 1 To Len(aPesoCub)
			nRec := aPesoCub[nLin][4]
			DbSelectArea("GW8")
			GW8->(DbGoTo(nRec))
			
			IF RecLock("GW8", .F.) // .T. ou .F. - Indica se é inclusão.
				GW8->GW8_PESOC := aPCItem[nLin]
				GW8->(MsUnLock())
				lRet := .T.
			EndIf
		Next
		
	Else 
		FWAlertError("Houve um problema ao calcular o novo peso, consulta ADM sistemas.", "Atenção")
		lRet := .F.
		//Break
	EndIf	

Return lRet


//Distribui os valores de peso BRUTO na grid e grava na tabela GW8 via RecLock
Static Function fRateioPB(aPesoBrt, nPBNovo, nVlrTot)
	Local nLin 		:= 0
	Local nResult 	:= 0
	Local nSomaPB	:= 0
	Local lRet 		:= .F.
	Local aPBItem	:= {}
	Local nRec 		:= 0
	
	Default nVlrTot := 0
	Default nPBNovo := 0

	For nLin := 1 To Len(aPesoBrt)		
		nResult :=  (nPBNovo / nVlrTot) * (aPesoBrt[nLin][3])
		Aadd(aPBItem, nResult)
		nSomaPB := nSomaPB + nResult
		nResult := 0
	Next
	
	//Verificar o total dos novos valores da Grid
	If (nSomaPB == nPBNovo) .and. ! empty(aPBItem)

		//Grava as informações na tabela GW8 (grid)
		For nLin := 1 To Len(aPesoBrt)
			nRec := aPesoBrt[nLin][4]
			DbSelectArea("GW8")
			GW8->(DbGoTo(nRec))
			
			IF RecLock("GW8", .F.) // .T. ou .F. - Indica se é inclusão.
				GW8->GW8_PESOR := aPBItem[nLin]
				GW8->(MsUnLock())
				lRet := .T.
			EndIf
		Next
		
	Else 
		FWAlertError("Houve um problema ao calcular o novo peso, consulta ADM sistemas.", "Atenção")
		lRet := .F.
		//Break
	EndIf	

Return lRet
