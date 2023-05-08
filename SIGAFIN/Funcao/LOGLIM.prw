#Include "TOTVS.CH"

/*/{Protheus.doc} LOGLIM
	Apresentar tela com LOG de alteração nos dados de *Limite de Crédito* no cadastro Cliente
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		17/02/2019
	@version 	1.0
	// @param 		param_name, param_type, param_description
	@return 	NIL, Nulo *(nenhum)*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
User Function LOGLIM()
	Local cAliTmp	:= 'ZA2'
	Local cAliZA2	:= GetNextAlias()
	Local cTitulo	:= 'Alteração de Crédito'
	Local cLinOk 	:= "AllwaysTrue"
	Local cTudoOk 	:= "AllwaysTrue"
	Local cIniCpos 	:= ""
	Local cFieldOk 	:= "U_ZA2CmpVld()" // "AllwaysTrue"
	Local xConteudo	:= ""
	Local nFreeze 	:= 000
	Local nMax 		:= 999
	Local nUsado	:= 0
	Local Nx		:= 0
	Local nReg		:= 0
	Local nOpcClick	:= 0
	Local aButtons	:= {}
	Local aArea		:= GetArea()
	Local oDlg		:= Nil

	Local aSx3		:= {}
	Local nPosTit	:= 0
	Local nPosCpo 	:= 0
	Local nPosPic	:= 0
	Local nPosTam 	:= 0
	Local nPosDec 	:= 0
	Local nPosVal 	:= 0
	Local nPosUsa	:= 0
	Local nPosTip	:= 0
	Local nPosF3	:= 0
	Local nPosCont	:= 0
	Local nPosBox	:= 0
	Local nPosRel	:= 0
	Local _nX		:= 0

	Private aHeader	:= {}
	Private aCols	:= {}
	Private nItens 	:= 0
	Private oLimite	:= Nil

	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(DbSeek(cAliTmp))

	aSX3 := U_GetSx3(cAliTmp)

	// Procuro a posição dos campos que serão usados
	nPosTit 	:= AScan( aSX3[1] , {|x| x ==  "X3_TITULO"	})
	nPosCpo 	:= AScan( aSX3[1] , {|x| x ==  "X3_CAMPO"	})
	nPosPic 	:= AScan( aSX3[1] , {|x| x ==  "X3_PICTURE"	})
	nPosTam 	:= AScan( aSX3[1] , {|x| x ==  "X3_TAMANHO"	})
	nPosDec 	:= AScan( aSX3[1] , {|x| x ==  "X3_DECIMAL"	})
	nPosVal	 	:= AScan( aSX3[1] , {|x| x ==  "X3_VALID"	})
	nPosUsa 	:= AScan( aSX3[1] , {|x| x ==  "X3_USADO"	})
	nPosTip 	:= AScan( aSX3[1] , {|x| x ==  "X3_TIPO"	})
	nPosF3		:= AScan( aSX3[1] , {|x| x ==  "X3_F3"		})
	nPosCont	:= AScan( aSX3[1] , {|x| x ==  "X3_CONTEXT" })
	nPosBox		:= AScan( aSX3[1] , {|x| x ==  "X3_CBOX" 	})
	nPosRel		:= AScan( aSX3[1] , {|x| x ==  "X3_RELACAO" })

	For _nX := 1 TO Len(aSX3[2])
		If X3USO(aSX3[2][_nX][nPosUsa])
			nUsado := nUsado + 1
			Aadd(aHeader,{	AllTrim(aSX3[2][_nX][nPosTit]),;
				aSX3[2][_nX][nPosCpo] ,;
				aSX3[2][_nX][nPosPic] ,;
				aSX3[2][_nX][nPosTam] ,;
				aSX3[2][_nX][nPosDec] ,;
				aSX3[2][_nX][nPosVal] ,;
				aSX3[2][_nX][nPosUsa] ,;
				aSX3[2][_nX][nPosTip] ,;
				aSX3[2][_nX][nPosF3]  ,;
				aSX3[2][_nX][nPosCont],;
				aSX3[2][_nX][nPosBox] ,;
				aSX3[2][_nX][nPosRel]  } )
		EndIf
	Next _nX

	//	Column ZA2_DATA  AS Date

	BeginSql Alias cAliZA2
		SELECT
			ZA2_DATA,
			ZA2_HORA,
			ZA2_RESPON,
			ZA2_SOLICI,
			ZA2_OBSERV
		FROM %Table:ZA2% Z
	EndSql
	Count To nReg

/*
		WHERE
				Z.%NotDel%
			AND Z.ZA2_FILIAL = %xFilial:ZA2%
			AND Z.ZA2_CLIENT = %Exp:M->A1_COD%
			AND Z.ZA2_LOJA = %Exp:M->A1_LOJA%
		ORDER BY
		ZA2_DATA, ZA2_HORA

*/
	If nReg > 0
		(cAliZA2)->(DbGoTop())

		While !(cAliZA2)->(EOF())
			nItens++
			aAdd( aCols, Array( nUsado+1 ) )
			For Nx := 1 to nUsado
				xConteudo := &("(cAliZA2)->" + aHeader[Nx,2] )

				aCols[Len(aCols),Nx ] := xConteudo
			Next Nx
			aCols[Len(aCols),nUsado+1] := .F.

			(cAliZA2)->(DbSkip())
		EndDo

		Define MsDialog oDlg Title cTitulo FROM 000,000 TO 420,1150 Of oDlg Pixel

		oLimite := MsNewGetDados():New(0,0,0,0,Iif(Altera,GD_INSERT + GD_UPDATE,0),cLinOk,cTudoOk,cIniCpos,,nFreeze,nMax,cFieldOk,,,oDlg,aHeader,aCols)
		oLimite:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oLimite:Refresh()

		oDlg:bInit := {|| EnchoiceBar(oDlg, { ||nOpcClick := 1,oDlg:End() },{ ||oDlg:End() },,aButtons) }
		oDlg:lCentered := .T.
		oDlg:Activate()

		If nOpcClick == 1
			Begin Transaction

				MsgRun("Atualizando LOG de Limite de Crédito... Aguarde...","CAOA",{|| GrvDados(oLimite:aCols) })

			End Transaction
		EndIf
	Else
		MsgInfo("Não há dados.","TOTVS")
	EndIf

	RestArea(aArea)
Return

/*/{Protheus.doc} GrvDados
	Função Auxiliar - Gravar dados na Tabela `ZA2`.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		02/05/2019
	@version 	1.0
	@param 		aItens		, array		, Matriz de dados para registro em LOG
				| Item			| Campo		 | Tipo e Descrição 																						|
				|---------------|------------|----------------------------------------------------------------------------------------------------------|
				| aItens[N][1] 	| ZA2_DATA 	 | Tipo *date* - Data da alteração do dado 																	|
				| aItens[N][2] 	| ZA2_HORA 	 | Tipo *time* - Hora da alteração do dado 																	|
				| aItens[N][3] 	| ZA2_RESPON | Tipo *character* - Usuário responsável pela alteração *(login)* 											|
				| aItens[N][4] 	| ZA2_SOLICI | Tipo *character* - Solicitante da alteração do dado de cadastro *(nome ou login)* 						|
				| aItens[N][5] 	| ZA2_OBSERV | Tipo *character* - LOG de dado alterado - *CAMPO: Título, ALTERADO DE: Valor anterior PARA: Novo Valor* 	|
	@return 	NIL, Nulo *(nenhum)*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
Static Function GrvDados(aItens)
	Local Dw		:= 0
	Local aAreaZA2	:= ZA2->(GetArea())

	DbSelectArea("ZA2")
	ZA2->(DbSetOrder(1)) //ZA2_FILIAL+ZA2_CLIENT+ZA2_LOJA+ZA2_DATA

	For Dw := 1 To Len(aItens)
		// soh comeca a gravar a partir das linhas novas
		If Dw <= nItens
			Loop
		Endif
		/*	
		If ZA2->(DbSeek(xFilial("ZA2") + SA1->(A1_COD+A1_LOJA) + DToS(aItens[Dw,1])))
			RecLock("ZA2",.F.)
			If GdDeleted(Dw,,aItens)
				ZA2->(DbDelete())
			Else
				ZA2->ZA2_SOLICI	:= aItens[Dw,4]
				ZA2->ZA2_OBSERV	:= aItens[Dw,5]
			EndIf
		Else
		*/
			RecLock("ZA2",.T.)
			ZA2->ZA2_FILIAL	:= xFilial("ZA2")
			ZA2->ZA2_CLIENT	:= SA1->A1_COD
			ZA2->ZA2_LOJA	:= SA1->A1_LOJA
			ZA2->ZA2_DATA	:= aItens[Dw,1]
			ZA2->ZA2_HORA	:= aItens[Dw,2]
			ZA2->ZA2_RESPON	:= aItens[Dw,3]
			ZA2->ZA2_SOLICI	:= aItens[Dw,4]
			ZA2->ZA2_OBSERV	:= aItens[Dw,5]
			ZA2->(MsUnlock())
		//EndIf
	Next Dw

	RestArea(aAreaZA2)
Return

/*/{Protheus.doc} ZA2CmpVld
	Apresentar mensagem *(Help)* para alteração não permitida na tela com LOG de alteração nos dados de *Limite de Crédito* no cadastro Cliente
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		17/02/2019
	@version 	1.0
	// @param 		param_name, param_type, param_description
	@return 	logical, Sempre verdadeiro *(`.T.`)*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	/*/
User Function ZA2CmpVld()

	Local lRet := .T.

	If nItens > 0 .and. oLimite:nAt <= nItens
		lRet := .F.
		Help( ,, 'Help',, 'Não é permitida alteração de linhas já gravadas anteriormente.', 1, 0 )
	Endif

Return(lRet)
