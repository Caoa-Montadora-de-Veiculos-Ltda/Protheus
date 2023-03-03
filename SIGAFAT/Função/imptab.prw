#INCLUDE "TOTVS.CH"
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

#DEFINE _POS_CHAVE_PESQUISA 01
#DEFINE _POS_ANO_FAB_MOD    02
#DEFINE _POS_DATA_FINAL     03
#DEFINE _POS_PRECO_VENDA    04
#DEFINE _POS_PRECO_INICIAL  05
#DEFINE _POS_PRECO_FINAL    06
#DEFINE _POS_PRECO_BASEICMS 07

User Function IMPTAB()

	Local oTProces

	Private oVisualLog := OFVisualizaDados():New(, "Log de Importação")


	oTProces := tNewProcess():New(;
		"IMPTAB" ,; // < cFunction>
		"Importação Tabela Preço - CAOA" ,; // <cTitle>
		{ |oSelf| Processa(oSelf) } ,; // <bProcess>
		"Esta rotina é responsável por importar tabela de preço por modelo + segmento." ,; // <cDescription>
		"IMPTAB" ,; // [ cPerg]
		,; // [ aInfoCustom]
		,; // [ lPanelAux]
		,; // [ nSizePanelAux]
		,; // [ cDescriAux]
		,; // [ lViewExecute]
		) // [ lOneMeter] 

	If oVisualLog:HasData()
		oVisualLog:Activate()
	EndIf


Return .T.

Static Function Processa(oTProces)

	Local oFTabPreco
	Local oFBaseICMS

	Local nTamOpcion := VV2->(TamSX3("VV2_OPCION"))[1]
	Local nTamCorExt := VV2->(TamSX3("VV2_COREXT"))[1]
	Local nTamCorInt := VV2->(TamSX3("VV2_CORINT"))[1]

	Local oModel030

	Local nPosMod
	Local nPosVV2Prod

	Local nTamCodModelo := 9

	Local cCodMar := AllTrim(MV_PAR01)
	Local cArqPrecoPublico := AllTrim(MV_PAR02)
	Local cArqBaseICMS := AllTrim(MV_PAR03)

	Private aModelos := {}

	If ! MsgYesNo("Confirma processamento")
		Return
	EndIf


	oVisualLog:AddColumn( { { "TITULO" , "Modelo"  } , { "TAMANHO" , GetSX3Cache( "VV2_PRODUT","X3_TAMANHO") } } ) 
	oVisualLog:AddColumn( { { "TITULO" , "Ano Fab./Modelo"  } , { "TAMANHO" , 8 } , {"PICTURE","@R 9999/9999"}} ) 
	oVisualLog:AddColumn( { { "TITULO" , "Observação"  } , { "TAMANHO" , 100 } } ) 

	oTProces:SetRegua1(4)
	oTProces:IncRegua1("Carregando arquivo de Base ST")

	oModel030 := FWLoadModel("VEIA030")
	oModel030:SetOperation( MODEL_OPERATION_UPDATE )

	// | 1      | 2          | 3               | 4              | 5              | 6              | 7             | 8              | 9          | 10            |
	// | Modelo | Ano Modelo | Ano Fabricação | Início Vigência | Final Vigência | Preço Inicial  |  Preço Final  |  Base ICMS ST  |  Base CAOA | Cód. Item Nfe |
	// Modelo;Ano Modelo;Ano Fabricação;Início Vigência;Final Vigência;Preço Inicial ; Preço Final ; Base ICMS ST ; Base CAOA ;Cód. Item Nfe
	// T17W5L4FFC701BLP;2019;2018;03/05/2019;06/06/2019;79.312,85;80.030,80;86.990,00;86.990,00;T17W5L4FFC701BLPC701
	oFBaseICMS := FWFileReader():New( cArqBaseICMS ) 
	If !oFBaseICMS:Open()
		Return .f.
	EndIf

	While oFBaseICMS:HasLine()
		cAuxLine := AllTrim(oFBaseICMS:GetLine())
		ConOut( "Base ICMS - " + cAuxLine )
		If Empty(cAuxLine)
			Loop
		EndIf

		aAuxCol := StrTokArr2(cAuxLine, ";", .t.)
		If "MODELO" $ AllTrim(Upper(aAuxCol[1]))
			Loop
		EndIf

		cVV2PRODUT := AllTrim(aAuxCol[1])
		AddVV2Prod( cVV2PRODUT , aAuxCol[3] + aAuxCol[2] , CtoD(aAuxCol[4]) , @nPosVV2Prod)

		aModelos[ nPosVV2Prod, _POS_PRECO_BASEICMS ] := TransVal( aAuxCol[8] ) // Base ICMS ST
		aModelos[ nPosVV2Prod, _POS_PRECO_INICIAL  ] := TransVal( aAuxCol[6] ) // Preco Inicial
		aModelos[ nPosVV2Prod, _POS_PRECO_FINAL    ] := TransVal( aAuxCol[7] ) // Preco FInal
		
	End
	oFBaseICMS:Close()

	ConOut( " " )
	ConOut( " " )
	ConOut( " " )

	oTProces:IncRegua1("Carregando arquivo de Tabela de Preço")

	// | 1      |  2   |  3   | 4         | 5        |  6      |  7       | 8                  |
	// | Modelo | Fáb. | Mod. | Descrição | Opcional | Cor ex. | Cor Int. | Preço Venda SGV257 |
	// Modelo;Fab.;Mod.;Descrigco;Opcional;Cor ex.;Cor Int.;Prego Venda SGV257;
	// BNFALDC;2015;2015;LEGACY SD AWD 3.6R-S AUT;K4YT;;;1292,16;
	oFTabPreco := FWFileReader():New( cArqPrecoPublico ) 
	If !oFTabPreco:Open()
		Return .f.
	EndIf

	While oFTabPreco:HasLine()
		cAuxLine := AllTrim(oFTabPreco:GetLine())
		ConOut( "Tab Preco - " + cAuxLine )
		If Empty(cAuxLine)
			Loop
		EndIf

		aAuxCol := StrTokArr2(cAuxLine, ";", .t.)
		If "MODELO" $ AllTrim(Upper(aAuxCol[1]))
			Loop
		EndIf

		cVV2PRODUT := AllTrim(aAuxCol[1])
		nPosVV2Prod := 0

		If ! AddVV2Prod( cVV2PRODUT , aAuxCol[2] + aAuxCol[3] , CtoD(" ") , @nPosVV2Prod, .f.)
			Loop
		EndIf

		aModelos[ nPosVV2Prod, _POS_PRECO_VENDA ] := TransVal( aAuxCol[8] )

	End
	oFTabPreco:Close()

	oTProces:IncRegua1("Ordenando arquivo para processamento")
	aSort( aModelos ,,, { |x,y| x[1] > y[1] } )


	oTProces:IncRegua1("Atualizando arquivo de modelos")
	oTProces:SetRegua2(Len(aModelos))
	For nPosMod := 1 to Len(aModelos)

		oTProces:IncRegua2(aModelos[nPosMod, _POS_CHAVE_PESQUISA ])

		dbSelectArea("VV2")
		If ! PosVV2( aModelos[nPosMod, _POS_CHAVE_PESQUISA ] )
			oVisualLog:AddDataRow({ aModelos[nPosMod, _POS_CHAVE_PESQUISA ] , aModelos[nPosMod, _POS_ANO_FAB_MOD ] , "Modelo não encontrado" })
			Loop
		EndIf

		INCLUI := .f.
		ALTERA := .t.
		If !oModel030:Activate()
			aErro := oModel030:GetErrorMessage(.T.)
			CursorArrow()
			MsgInfo(aErro[6])
			Loop
		EndIf

		oModelVV2 := oModel030:GetModel('MODEL_VV2')
		oModelVVP := oModel030:GetModel('MODEL_VVP')

		If aModelos[ nPosMod , _POS_PRECO_VENDA ] == 0
			oVisualLog:AddDataRow({ aModelos[nPosMod, _POS_CHAVE_PESQUISA ] , aModelos[nPosMod, _POS_ANO_FAB_MOD ] , "Modelo sem valor de tabela informado" })
			Loop
		EndIf

		aChave := { ;
			{ "VVP_FABMOD" , aModelos[ nPosMod , _POS_ANO_FAB_MOD ] } ,;
			{ "VVP_DATPRC" , aModelos[ nPosMod , _POS_DATA_FINAL  ] } ;
		}

		If ! oModelVVP:SeekLine( aChave , .f. , .t. )
			oModelVVP:AddLine()
			oModelVVP:SetValue( "VVP_FABMOD" , aModelos[ nPosMod , _POS_ANO_FAB_MOD ] )
			oModelVVP:SetValue( "VVP_DATPRC" , aModelos[ nPosMod , _POS_DATA_FINAL  ] )
		EndIf

		oModelVVP:SetValue( "VVP_CUSTAB" , aModelos[ nPosMod , _POS_PRECO_INICIAL  ] )
		oModelVVP:SetValue( "VVP_VALTAB" , aModelos[ nPosMod , _POS_PRECO_VENDA    ] )
		oModelVVP:SetValue( "VVP_MINVEN" , aModelos[ nPosMod , _POS_PRECO_INICIAL  ] )
		oModelVVP:SetValue( "VVP_MAXVEN" , aModelos[ nPosMod , _POS_PRECO_FINAL    ] )
		oModelVVP:SetValue( "VVP_BASEST" , aModelos[ nPosMod , _POS_PRECO_BASEICMS ] )

		If oModel030:VldData()
			oModel030:CommitData()

		Else
			
			aErro   := oModel030:GetErrorMessage()
			AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
			AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
			AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
			AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
			AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
			AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
			AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
			AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
			AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )

			If (!IsBlind()) // COM INTERFACE GRÁFICA
				MostraErro() //TELA
			EndIf

		EndIf

		oModel030:DeActivate()

	Next nPosMod

Return



Static Function TransVal(cAuxValor)
	Local nValor

	cMsg := cAuxValor

	cAuxValor := alltrim(strtran(cAuxValor,chr(160) ,""))
	cAuxValor := StrTran(cAuxValor, "." , "")
	cAuxValor := StrTran(cAuxValor, "," , ".")
	nValor := Val(cAuxValor)

Return nValor

Static Function AddModelo( cCodMod , nPosMod , lAddMod )

	Default lAddMod := .t.

	nPosMod := aScan(aModelos, { |x| x[1] == cCodMod } )
	If nPosMod == 0
		If lAddMod
			AADD( aModelos , { cCodMod , {} } )
			nPosMod := Len(aModelos)
		Else
			Return .f.
		EndIf
	EndIf

Return .t.

Static Function AddVV2Prod( cVV2PRODUT , cAnoFabMod , dDataAte , nPosVV2Prod , lAddProd)

	Default lAddProd := .t.

	If Empty(dDataAte)
		nPosVV2Prod := aScan(aModelos , { |x| x[1] == cVV2PRODUT .and. x[2] == cAnoFabMod } )
	Else
		nPosVV2Prod := aScan(aModelos , { |x| x[1] == cVV2PRODUT .and. x[2] == cAnoFabMod .and. x[3] == dDataAte } )
	EndIf

	If nPosVV2Prod == 0
		If lAddProd
			AADD( aModelos , { ;
					cVV2PRODUT ,;	// Chave de Pesquisa
					cAnoFabMod ,;	// Ano Fabricacao / Modelo
					dDataAte ,;		// Data Final de Vigencia
					0 ,; 				// Preco de Venda
					0 ,; 				// Preço Inicial 
					0 ,; 				// Preço Final 
					0 } )				// Base ICMS ST
			nPosVV2Prod := Len(aModelos)
		Else
			Return .f.
		EndIf
	EndIf

Return .t.

Static Function PosVV2(cVV2PRODUT)

	Local cAliasVV2 := "TVV2"

	BeginSQL Alias cAliasVV2
		
		COLUMN VV2RECNO AS NUMERIC(10,0)

		SELECT VV2.R_E_C_N_O_ VV2RECNO
		FROM 
			%table:VV2% VV2
		WHERE
			VV2.VV2_FILIAL = %xFilial:VV2%
			AND VV2.VV2_PRODUT = %exp:cVV2PRODUT%
			AND VV2.%notDel% 
	EndSql

	If ! TVV2->(Eof()) .and. TVV2->VV2RECNO <> 0

		VV2->(dbGoTo( TVV2->VV2RECNO ))
		TVV2->(dbCloseArea())
		Return .t. 

	EndIf

	TVV2->(dbCloseArea())


Return .f.
