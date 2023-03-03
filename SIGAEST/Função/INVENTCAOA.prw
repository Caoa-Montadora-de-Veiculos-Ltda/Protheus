#Include "Protheus.Ch"
#Include "Totvs.Ch"
#Include "ApWizard.Ch"

/*/{Protheus.doc} INVENTCA
Rotina de importação de Inventário via CSV - CAOA.
@author FSW - DWC Consult
@since 05/02/2019
@version 1.0
@type function
/*/
User Function INVENTCA()
	Local cCamArq	:= ""
	Local cTipo 	:= OemToAnsi("Arquivo CSV")+"(*.csv) |*.csv|"
	Local nOpc		:= GETF_LOCALHARD+GETF_NETWORKDRIVE
	Local lOk	  	:= .F.
	Local oCamArq	:= Nil
	Local oWizard	:= Nil

	Private nPosPrd	  := 0	//Posição do Codigo do Produto.
	Private nPosLoc	  := 0	//Posição do Armazem.
	Private nPosDoc	  := 0	//Posição do Número do Documento.
	Private nPosData  := 0	//Posição da Data do Inventário.
	Private nPosQtd1  := 0	//Posição da Quantidade 1 unidade de medida.
	Private nPosQtd2  := 0	//Posição da Quantidade 2 unidade de medida.
	Private nPosLote  := 0	//Posição do Codigo do Lote.
	Private nPosSbLt  := 0	//Posição do Codigo do Sub-Lote.
	Private nPosDtLt  := 0	//Posição da Data do Lote.
	Private nPosEnd	  := 0	//Posição do Codigo do Endereço.
	Private nPosNum	  := 0	//Posição do Codigo do Número de Série.
	Private nPosEst	  := 0	//Posição da Estrutura Fisica.
	Private nPosCont  := 0	//Posição da Contagem do inventário.
	Private nPosCUni  := 0	//Posição do Código do Unitizadir
	Private nPosIUni  := 0	//Posição do Id Unitizadir
	Private lEnd   	  := .F.
	Private oProcess  := Nil

	DEFINE WIZARD oWizard TITLE "Importação de Inventário - CAOA" HEADER "Wizard utilizado para Importar a digitação de inventário via CSV.";                                                                                                                                                                                                                                                                                                                                                                                                                                                   
	MESSAGE "";
	TEXT "Esta rotina tem por objetivo importar um arquivo CSV contendo os itens inventáriados para digitação automática."; 
	PANEL NEXT {|| .T. } FINISH {|| .T. };

	// Painel da selecao do arquivo
	CREATE PANEL oWizard HEADER "Parametros para Importação";
	MESSAGE "Informe os parametros abaixo.";
	PANEL BACK {|| .T. } NEXT {|| VldPar(cCamArq)  } FINISH {|| .T. } EXEC {|| .T. }	

	@ 006,003 Say "Arquivo"	Size 051,008 COLOR CLR_BLUE PIXEL OF oWizard:oMPanel[2]
	@ 005,024 MsGet oCamArq Var cCamArq Size 238,009 COLOR CLR_BLACK PIXEL OF oWizard:oMPanel[2] When .F.
	@ 005,262 Button "Selecione" Size 035,011 Action cCamArq := Upper(Alltrim(cGetFile(cTipo,"Selecione o Arquivo",,,.T.,nOpc,.F.,)))  PIXEL OF oWizard:oMPanel[2]

	// Painel da importacao do arquivo e finalizacao do processo
	CREATE PANEL oWizard HEADER "Importação de Inventário - CAOA";
	MESSAGE "";
	PANEL BACK {|| .T. } FINISH {|| lOk := .T. } EXEC {|| .T.}

	@ 005,005 Say "Clique em Finalizar para iniciar o processamento." Size 250,008 COLOR CLR_BLUE PIXEL OF oWizard:oMPanel[3]
	@ 120,005 Say "Desenvolvido por: TOTVS S.A." Size 150,008 COLOR CLR_BLUE PIXEL OF oWizard:oMPanel[3]

	ACTIVATE WIZARD oWizard CENTERED

	If lOk
		oProcess := MsNewProcess():New( { |lEnd| CursorWait(),FValLayout( @lEnd,cCamArq ),CursorArrow() },"Importação de Inventário - CAOA",'Iniciando Processamento...', .F. )
		oProcess:Activate()
	EndIf
Return

/*/{Protheus.doc} VldPar
Valida se o arquivo foi informado e se existe.
@author FSW - DWC Consult
@since 04/02/2019
@version 1.0
@param cCamArq, characters, descricao
@type function
/*/
Static Function VldPar(cCamArq)
	Local lRet := .T.

	//Valida o Arquivo Selecionado.
	If Empty(cCamArq)
		MsgAlert("Para continuar é necessario a pesquisa do arquivo","TOTVS")
		lRet := .F.
	ElseIf ! File(cCamArq)
		MsgAlert("Arquivo " + cCamArq + ", não encontrado!","TOTVS")
		lRet := .F.
	EndIf
Return(lRet)

/*/{Protheus.doc} FValLayout
Função de Validação do Layout e Criação\Popular Tabela Temporaria.
@author FSW - DWC Consult
@since 05/02/2019
@version 1.0
@param lEnd, logical, descricao
@param cArquivo, characters, descricao
@type function
/*/
Static Function FValLayout(lEnd,cArquivo)
	Local cLinha  	:= ""
	Local cProduto	:= ""
	Local cArmazem	:= ""
	Local cLocal	:= ""
	Local cLoteImp	:= ""
	Local cSbLoteI	:= ""
	Local cMen		:= ""
	Local cRastro	:= ""
	Local cContEnd	:= ""
	Local cDocInvt	:= ""
	Local nRegImp 	:= 0
	Local lLay 		:= .F.
	Local lInv		:= .T.
	Local dDtVldLt	:= Nil
	Local aCSV	 	:= Nil
	Local oFile		:= Nil
	Local oTemptable:= Nil

	Private cAliasMt:= GetNextAlias()
	Private aTabSB7 := {}

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD

	DbSelectArea("SBE")
	SBE->(DbSetOrder(1)) //BE_FILIAL+BE_LOCAL+BE_LOCALIZ

	DbSelectArea("NNR")
	NNR->(DbSetOrder(1)) //NNR_FILIAL+NNR_CODIGO

	If Select(cAliasMt) > 0
		(cAliasMt)->(DbCloseArea())
	EndIf
	///////////////////////////////////////////
	//     Estrutura da Tabela Temporária    //
	//---------------------------------------//
	// NOME , TIPO_CAMPO , TAMANHO , DECIMAL //
	///////////////////////////////////////////
	AAdd(aTabSB7,{"TMP_B7FIL",	TamSx3("B7_FILIAL") [3],	TamSx3("B7_FILIAL") [1],	TamSx3("B7_FILIAL") [2]} )
	AAdd(aTabSB7,{"TMP_B7COD",	TamSx3("B7_COD")	[3],	TamSx3("B7_COD")	[1],	TamSx3("B7_COD")	[2]} )
	AAdd(aTabSB7,{"TMP_B7ARM",	TamSx3("B7_LOCAL")	[3],	TamSx3("B7_LOCAL")	[1],	TamSx3("B7_LOCAL")	[2]} )
	AAdd(aTabSB7,{"TMP_B7DOC",	TamSx3("B7_DOC")	[3],	TamSx3("B7_DOC")	[1],	TamSx3("B7_DOC")	[2]} )
	AAdd(aTabSB7,{"TMP_B7DAT",	TamSx3("B7_DATA")   [3],	TamSx3("B7_DATA")	[1],	TamSx3("B7_DATA")	[2]} )
	AAdd(aTabSB7,{"TMP_B7QT1",	TamSx3("B7_QUANT")  [3],	TamSx3("B7_QUANT")	[1],	TamSx3("B7_QUANT")	[2]} )
	AAdd(aTabSB7,{"TMP_B7QT2",	TamSx3("B7_QTSEGUM")[3],	TamSx3("B7_QTSEGUM")[1],	TamSx3("B7_QTSEGUM")[2]} )
	AAdd(aTabSB7,{"TMP_B7LOT",	TamSx3("B7_LOTECTL")[3],	TamSx3("B7_LOTECTL")[1],	TamSx3("B7_LOTECTL")[2]} )
	AAdd(aTabSB7,{"TMP_B7SBL",	TamSx3("B7_NUMLOTE")[3],	TamSx3("B7_NUMLOTE")[1],	TamSx3("B7_NUMLOTE")[2]} )
	AAdd(aTabSB7,{"TMP_B7DTL",	TamSx3("B7_DTVALID")[3],	TamSx3("B7_DTVALID")[1],	TamSx3("B7_DTVALID")[2]} )
	AAdd(aTabSB7,{"TMP_B7LOC",	TamSx3("B7_LOCALIZ")[3],	TamSx3("B7_LOCALIZ")[1],	TamSx3("B7_LOCALIZ")[2]} )
	AAdd(aTabSB7,{"TMP_B7NUM",	TamSx3("B7_NUMSERI")[3],	TamSx3("B7_NUMSERI")[1],	TamSx3("B7_NUMSERI")[2]} )
	AAdd(aTabSB7,{"TMP_B7EST",	TamSx3("B7_TPESTR") [3],	TamSx3("B7_TPESTR") [1],	TamSx3("B7_TPESTR") [2]} )	
	AAdd(aTabSB7,{"TMP_B7CON",	TamSx3("B7_CONTAGE")[3],	TamSx3("B7_CONTAGE")[1],	TamSx3("B7_CONTAGE")[2]} )
	AAdd(aTabSB7,{"TMP_B7CUN",	TamSx3("B7_CODUNI")[3] ,	TamSx3("B7_CODUNI")[1] ,	TamSx3("B7_CODUNI")[2] } )
	AAdd(aTabSB7,{"TMP_B7IUN",	TamSx3("B7_IDUNIT")[3] ,	TamSx3("B7_IDUNIT")[1]  ,	TamSx3("B7_IDUNIT")[2] } )

	//Cria a Tabela Temporaria no BD.
	oTemptable := FwTemporaryTable():New( cAliasMt )
	oTemptable:SetFields( aTabSB7 )
	oTempTable:AddIndex("IndSB7", {"TMP_B7FIL","TMP_B7DAT","TMP_B7COD","TMP_B7ARM","TMP_B7LOC"} )
	oTempTable:Create()

	//Inicia a Leitura do Arquivo CSV.
	oProcess:SetRegua1(1)
	oProcess:IncRegua1('Lendo Planilha CSV')

	oFile := FWFileReader():New(cArquivo)
	oFile:nBufferSize := 65536
	oFile:Open()

	oProcess:SetRegua2(oFile:nFileSize)

	While oFile:HasLine()
		nRegImp++
		oProcess:IncRegua2('Criando Tabela Temporaria - Importado: ' + Transform(nRegImp,"@R 999,999,999") )

		cLinha := oFile:GetLine()
		If Substr(cLinha,1,1) == ";"
			Loop
		EndIf

		//O Primeiro registro sempre terá que ser o cabeçalho.
		If aCSV == Nil
			aCSV := StrTokArr2(Upper(cLinha),";",.T.)

			//Determina as posições do layout, e verifica se o layout minimo é existente.
			lLay := PosArq(StrTokArr2(Upper(cLinha),";",.T.))

			//Caso o layout não estaja ok, aborta a rotina.
			If !lLay
				Return
			Else //Se a rotina estiver Ok, pula o registro para o proximo.
				Loop
			EndIf
		Else
			aCSV := StrTokArr2(Upper(cLinha),";",.T.)
		EndIf

		cProduto := Padr(aCSV[nPosPrd],TamSx3('B7_COD')[1])
		cArmazem := Padr(aCSV[nPosLoc],TamSx3('B7_LOCAL')[1])
		cDocInvt := Padr(aCSV[nPosDoc],TamSx3('B7_DOC')[1])
		cLocal	 := Iif(nPosEnd == 0,"",Padr(aCSV[nPosEnd],TamSx3('B7_LOCALIZ')[1]))
		cLoteImp := Iif(nPosLote == 0,"",Padr(aCSV[nPosLote],TamSx3('B7_LOTECTL')[1]))
		cSbLoteI := Iif(nPosSbLt == 0,"",Padr(aCSV[nPosSbLt],TamSx3('B7_NUMLOTE')[1]))
		dDtVldLt := Iif(nPosDtLt == 0,"",CToD(aCSV[nPosDtLt]))
		cCodUni  := Iif(nPosCUni == 0,"",CToD(aCSV[nPosCUni]))
		cIdUni   := Iif(nPosIUni == 0,"",CToD(aCSV[nPosIUni]))
		
		If !SB1->(DbSeek(xFilial("SB1")+Padr(aCSV[nPosPrd],TamSx3('B7_COD')[1])))
			cMen += "Produto: " + cProduto + " - Não Cadastrado." + CRLF
			lInv := .F.
		Else
			cRastro	 := SB1->B1_RASTRO 	//Controla Lote ou Sub-Lote.
			cContEnd := SB1->B1_LOCALIZ	//Controla Endereço.
		EndIf

		If !NNR->(DbSeek(xFilial("NNR")+Padr(aCSV[nPosLoc],TamSx3('B7_LOCAL')[1])))
			cMen += "Armazém: " + AllTrim(cArmazem) + " - Não Cadastrado." + CRLF
			lInv := .F.
		EndIf

		If cContEnd == 'S' .And. !SBE->(DbSeek(xFilial("SBE") + cArmazem + cLocal))
			cMen += "Endereço: " + AllTrim(cLocal) + " - Não Cadastrado - Produto: " + cProduto + CRLF
			lInv := .F.
		EndIf

		If cRastro == 'L' .And. Empty(cLoteImp)
			cMen += "Lote não informado - Produto: " + AllTrim(cProduto) + CRLF
			lInv := .F.
		EndIf

		If cRastro == 'S' .And. Empty(cSbLoteI)
			cMen += "Sub-Lote não Informado - Produto: " + AllTrim(cProduto) + CRLF
			lInv := .F.
		EndIf

		RecLock(cAliasMt,.T.)
		(cAliasMt)->TMP_B7FIL	:= xFilial('SB7')
		(cAliasMt)->TMP_B7COD	:= cProduto
		(cAliasMt)->TMP_B7ARM	:= cArmazem
		(cAliasMt)->TMP_B7DOC	:= cDocInvt
		(cAliasMt)->TMP_B7DAT	:= Iif(nPosData == 0,dDataBase,CToD(aCSV[nPosData]))
		(cAliasMt)->TMP_B7QT1	:= Val(StrTran(StrTran(StrTran(aCSV[nPosQtd1],".",""),",","."),"R$",""))
		(cAliasMt)->TMP_B7QT2	:= Iif(nPosQtd2 == 0,0,Val(StrTran(StrTran(StrTran(aCSV[nPosQtd2],".",""),",","."),"R$","")))
		(cAliasMt)->TMP_B7LOT	:= Iif(cRastro $ 'L\S',cLoteImp,'')	//Somente para produtos que controlam Lote \ SubLote.
		(cAliasMt)->TMP_B7SBL	:= Iif(cRastro == 'S',cSbLoteI,'')	//Somente para produtos que controlam Lote \ SubLote.
		(cAliasMt)->TMP_B7DTL	:= Iif(cRastro $ 'L\S',dDtVldLt,CToD("  /  /    "))	//Somente para produtos que controlam Lote \ SubLote.
		(cAliasMt)->TMP_B7LOC	:= Iif(cContEnd == 'S',cLocal,'')
		(cAliasMt)->TMP_B7NUM	:= Iif(nPosNum == 0,"",Padr(aCSV[nPosNum],TamSx3('B7_NUMSERI')[1]))
		(cAliasMt)->TMP_B7EST	:= Iif(nPosEst == 0,"",Padr(aCSV[nPosEst],TamSx3('B7_TPESTR')[1]))
		(cAliasMt)->TMP_B7CON	:= Iif(nPosCont == 0,'001',Padr(aCSV[nPosCont],TamSx3('B7_CONTAGE')[1]))
		(cAliasMt)->TMP_B7CUN	:= Iif(nPosCUni == 0,'',Padr(aCSV[nPosCUni],TamSx3('B7_CODUNI')[1]))
		(cAliasMt)->TMP_B7IUN	:= Iif(nPosIUni == 0,'',Padr(aCSV[nPosIUni],TamSx3('B7_IDUNIT')[1]))
		(cAliasMt)->(MsUnLock())
	EndDo
	oFile:Close()

	If !lInv
		MOSTRA_LOG(cMen)
	Else
		Begin Transaction
			oProcess := MsNewProcess():New( { |lEnd| CursorWait(),U_PROCINVT( @lEnd,oTempTable:GetRealName() ),CursorArrow() },"Importação de Inventário - CAOA",'Iniciando MsExecAuto...', .F. )
			oProcess:Activate()
		End Transaction
	EndIf

	//Exclui tabela Temporaria.
	oTempTable:Delete() 
Return

/*/{Protheus.doc} PosArq
Função para localizar as colunas dos layout´s.
@author FSW - DWC Consult
@since 04/02/2019
@version 1.0
@param aArray, array, descricao
@type function
/*/
Static Function PosArq(aArray)
	Local cCol01	:= 'B7_COD'
	Local cCol02	:= 'B7_LOCAL'
	Local cCol03	:= 'B7_QUANT'
	Local cCol04	:= 'B7_QTSEGUM'
	Local cCol05	:= 'B7_DOC'
	Local cCol06	:= 'B7_DATA'
	Local cCol07	:= 'B7_LOTECTL'
	Local cCol08	:= 'B7_NUMLOTE'
	Local cCol09	:= 'B7_LOCALIZ'
	Local cCol10	:= 'B7_NUMSERI'
	Local cCol11	:= 'B7_TPESTR'
	Local cCol12	:= 'B7_CONTAGE'
	Local cCol13	:= 'B7_DTVALID'
	Local cCol14	:= 'B7_CODUNI'
	Local cCol15	:= 'B7_IDUNIT'
	Local cMen		:= ''		
	Local Est		:= 0
	Local lRet		:= .T.

	For Est:=1 To Len(aArray)
		If aScan(aArray,{|x| AllTrim(x) == cCol01}) > 0 .And. nPosPrd == 0
			nPosPrd := aScan(aArray,{|x| AllTrim(x) == cCol01})
		ElseIf aScan(aArray,{|x| AllTrim(x) == cCol02}) > 0 .And. nPosLoc == 0
			nPosLoc := aScan(aArray,{|x| AllTrim(x) == cCol02})
		ElseIf aScan(aArray,{|x| AllTrim(x) == cCol03}) > 0 .And. nPosQtd1 == 0
			nPosQtd1 := aScan(aArray,{|x| AllTrim(x) == cCol03})
		ElseIf aScan(aArray,{|x| AllTrim(x) == cCol04}) > 0 .And. nPosQtd2 == 0
			nPosQtd2 := aScan(aArray,{|x| AllTrim(x) == cCol04})
		ElseIf aScan(aArray,{|x| AllTrim(x) == cCol05}) > 0 .And. nPosDoc == 0
			nPosDoc := aScan(aArray,{|x| AllTrim(x) == cCol05})
		ElseIf aScan(aArray,{|x| AllTrim(x) == cCol06}) > 0 .And. nPosData == 0
			nPosData := aScan(aArray,{|x| AllTrim(x) == cCol06})
		ElseIf aScan(aArray,{|x| AllTrim(x) == cCol07}) > 0 .And. nPosLote == 0
			nPosLote := aScan(aArray,{|x| AllTrim(x) == cCol07})
		ElseIf aScan(aArray,{|x| AllTrim(x) == cCol08}) > 0 .And. nPosSbLt == 0
			nPosSbLt := aScan(aArray,{|x| AllTrim(x) == cCol08})
		ElseIf aScan(aArray,{|x| AllTrim(x) == cCol09}) > 0 .And. nPosEnd == 0
			nPosEnd := aScan(aArray,{|x| AllTrim(x) == cCol09})
		ElseIf aScan(aArray,{|x| AllTrim(x) == cCol10}) > 0 .And. nPosNum == 0
			nPosNum := aScan(aArray,{|x| AllTrim(x) == cCol10})
		ElseIf aScan(aArray,{|x| AllTrim(x) == cCol11}) > 0 .And. nPosEst == 0
			nPosEst := aScan(aArray,{|x| AllTrim(x) == cCol11})
		ElseIf aScan(aArray,{|x| AllTrim(x) == cCol12}) > 0 .And. nPosCont == 0
			nPosCont := aScan(aArray,{|x| AllTrim(x) == cCol12})			
		ElseIf aScan(aArray,{|x| AllTrim(x) == cCol13}) > 0 .And. nPosDtLt == 0
			nPosDtLt := aScan(aArray,{|x| AllTrim(x) == cCol13})			
		ElseIf aScan(aArray,{|x| AllTrim(x) == cCol14}) > 0 .And. nPosCUni == 0
			nPosCUni := aScan(aArray,{|x| AllTrim(x) == cCol14})			
		ElseIf aScan(aArray,{|x| AllTrim(x) == cCol15}) > 0 .And. nPosIUni == 0
			nPosIUni := aScan(aArray,{|x| AllTrim(x) == cCol15})			
		EndIf
	Next Ar

	//Validacao minima para importacao. Caso nao tenha esses dados nao sera importado.
	If nPosPrd == 0 .Or. nPosLoc == 0 .Or. nPosQtd1 == 0 .Or. nPosDoc == 0 .Or. nPosData == 0
		lRet := .F.
		cMen := "PRODUTO, ARMAZEM, DOCUMENTO, QUANTIDADE e DATA INVENT. não informado no layout." + CRLF
	EndIf	

	If !Empty(cMen)
		MOSTRA_LOG(cMen)
	EndIf
Return(lRet)

/*/{Protheus.doc} MOSTRA_LOG
Mostra caixa texto com as mensagens de interação.
@author FSW - DWC Consult
@since 04/02/2019
@version 1.0
@param cTexto, characters, descricao
@type function
/*/
Static Function MOSTRA_LOG(cTexto)
	Define Font oFont Name 'Mono AS' Size 7, 15

	Define MsDialog oDlg Title 'Falha na Importação' From 3, 0 to 340, 417 Pixel
	@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
	oMemo:oFont := oFont
	Define SButton From 153, 177 Type 1 Action oDlg:End() Enable Of oDlg Pixel
	Activate MsDialog oDlg Center
Return