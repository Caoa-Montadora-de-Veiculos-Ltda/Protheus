#Include "Protheus.ch"
#Include "TOTVS.ch"

/*/{Protheus.doc} ZGENEXCEL
	CAOA - Relat�rio Excel da Consulta de Clientes, formato *XML*
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		24/02/2019
	@version 	2.0
	@param 		aTitles		, array		, Vetor de t�tulos
	@param 		aCols		, array		, Matriz de dados
	@return 	NIL			, Nulo *(nenhum)*
	@history 	            , denis.galvani, v.2.0 - Corre��es:
	@history 	            , denis.galvani, v.2.0 - Utiliza��o dos par�metros passados *(1 - T�tulos, 2 - Vetor de itens)*
	@history 	            , denis.galvani, v.2.0 - Mudan�as com redu��o de vari�veis e mem�ria.
	@history 	            , denis.galvani, v.2.0 - M�todo de gera��o alterado, da Classe ~*FWMsExcel*~ para **FWMsExcelEx**
	@history 	            , denis.galvani, v.2.0 - *FWMsExcelEx* - escrita direta em arquivo, mais extensos, menor uso de mem�ria
	@history 	22/08/2020	, denis.galvani, Inclus�o/padroniza��o de documenta��o de cabe�alho
	@history 	16/09/2020	, Valter.carvalho, definicao de  cNmPlan, cNmTb  como parametro de entrada

/*/

User Function ZGENEXCEL(aTitles, aCols, cNmPlan, cNmTb )

	Processa({|| zProcessa(aTitles, aCols, cNmPlan, cNmTb ) }, "[ZGENEXCEL]", "Montando a planilha" )
		
Return

Static Function zProcessa(aTitles, aCols, cNmPlan, cNmTb )
	Local cDestino	 := ""
	Local cFile		 := cNmPlan + ".xml"
	Local oExcelApp  := NIL
	Local oFWMsExcel := NIL
	Local i          := 1

	cFile := cNmPlan
	cFile += " - " + StrTran(Dtoc(Date()),'/','_', 1)
	cFile += " - " + StrTran(Time(),':','_', 1)
	cFile += ".xml"

	cDestino := GetTempPath()

	If Empty(aTitles[1])
		aTitles[1] := "LEGENDA"
	EndIf

	oFWMsExcel := FWMsExcelEx():New()

	oFWMsExcel:AddWorkSheet(cNmPlan)
	oFWMsExcel:AddTable(cNmPlan,cNmTb)

	// TITULOS DAS COLUNAS, FORMATACAO E TIPO DE CAMPO
	For i := 1 To Len(aTitles)
		nAlign  := 1 // 1 - LEFT
		nFormat := 1 // 1 - GENERAL
		If ValType(aCols[01][i]) == "D"
			nAlign  := 2 // 2 - CENTER
			nFormat := 4 // 4 - DATE
			// TRANSFORMA DATA PARA TEXTO DATA
			// AEval(aCols,{|aItem| aItem[i] := DtoC(aItem[i]) })
			AEval(aCols,{|aItem| aItem[i] := Iif(Empty(aItem[i]),"",DtoC(aItem[i])) })
			// CRIAR FORMULA EXCEL DATA COM VALORES DE ANO, MES, DIA A PARTIR DO VALOR
			// AEval(aCols,{|aItem| Iif(Empty(aItem[i]),"",(;
				// 	nYear := Year(aItem[i]) ,;
				// 	nMonth := Month(aItem[i]) ,;
				// 	nDay := Day(aItem[i]) ,;
				// 	aItem[i] := "=DATE("+cValToChar(nYear)+";"+cValToChar(nMonth)+";"+cValToChar(nDay)+")" )) })
		ElseIf ValType(aCols[01][i]) == "N"
			nAlign  := 3 // 3 - RIGHT
			nFormat := 2 // 2 - NUMBER // 3 - MONEY
		EndIf
		oFWMsExcel:AddColumn(cNmPlan,cNmTb,aTitles[i],nAlign,nFormat,.F.)
	Next i

	ProcRegua(Len(aCols) +1)

	For i := 1 To Len(aCols)
		IncProc('Gerando Relat�rio da Consulta... linha: ' + StrZero(i,5) + " de " + StrZero(Len(aCols),5) )

		If (i % 2) = 0
			oFWMsExcel:Set2LineBgColor("#FFFEEE")
		EndIf

		oFWMsExcel:AddRow(cNmPlan,cNmTb,aCols[i])
	Next

	IncProc("Abrindo arquivo gerado...")

	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cDestino + cFile)
	oFWMsExcel:DeActivate()
	FreeObj(oFWMsExcel)

	// ABRIR ARQUIVO GERADO
	If ApOleClient("MsExcel")
		// Abre o Arquivo direto no Excel
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cDestino + cFile )
		oExcelApp:SetVisible(.T.)
		oExcelApp:Destroy()
	Else
		MsgInfo("N�o foi possivel abrir o relat�rio automaticamente. Abra diretamente o arquivo salvo no diret�rio indicado.","CAOA")
	EndIf

Return
