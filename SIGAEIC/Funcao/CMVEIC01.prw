#Include "Protheus.ch"
#Include "TopConn.ch"
#Include 'FWEditPanel.ch'

/*
=====================================================================================
Programa.:              CMVEIC01
Autor....:              Atilio Amarilla / Marcelo Haro Sanches / Marcelo Carneiro
Data.....:              20/12/2018 / 10/04/2019
Descricao / Objetivo:   Inclusão de botôes adicionais na rotina EIVEV100
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP EIC004
Obs......:              Chamado pelo PE EIVEV100
Obs......:              - U_CMVEI01A() - Importação de Invoice
===================================================================================== */
Static nNumInte
Static cFilExec := "2020"

User Function CMVEIC01()

	aAdd(aRotina,{"Importar Invoice",	"U_CMVEI01A",	0, 3 })
	aAdd(aRotina,{"Invoice x Caixas",	"U_CMVEI01B",	0, 5 })
	//	aAdd(aRotina,{"Invoice x Caixas MVC",	"U_CMVEI01D",	0, 5 })

	if (1=2)
		ViewDef()
	EndIf

Return
//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------
User Function CMVEI01A()

	Local oDLg
	Local nCo1      := 1
	Local nCo2      := 5
	Local nPos      := 0
	Local lConfirma := .T.
	Local bGetDir   := Nil 
	
	Private cArqFalta
	Private cFalta		:= ""
	Private cTipPreco   := ""
	Private cArqEW5		:= ""
	Private cArqEW5_1  	:= ""
	Private cArqEW5_2  	:= ""
	Private cInvNum		:= ""
	Private cSINUM		:= ""
	Private cCC     	:= ""
	Private cExt	   	:= ""
	Private cIncoterm	:= ""
	Private cFreInc		:= ""
	Private cSegInc		:= ""
	Private cRateado	:= ""
	Private cFornecedor := ""
	Private cForLoj 	:= ""
	Private cNcm		:= ""
	Private cExNcm		:= ""
	Private cContainer  := ""
	Private cFORN   	:= ""
	Private cInvoice	:= ""

	Private nVlrFre		:= 0
	Private nVlrSeg		:= 0
	Private nVlrInland	:= 0
	Private nVlrPack	:= 0
	Private nVlrDesc	:= 0
	Private nVlOutD		:= 0
	Private nRecW2		:= 0
	Private nPesoL		:= 0
	Private nLayout		:= 0
	Private nTipPreco   := 0
	Private nTotalFOB 	:= 0
	Private nRecZZE  	:= 0  	//usada no função CMVEIC0101
	Private lPrcInv		:= .F.
	Private lSelPrc		:= .F.
	Private lCapaLog	:= .F.	//usada na função CMVEIC0101
	Private lAnuente 	:= .F.
	Private lErroGer 	:= .F.

	Private dAgt_Ok		:= dDataBase
	Private dOk_Shp		:= dDataBase
	Private dDtInvoice	:= dDataBase //CTOD("  /  /  ")

	Private aInvoice 	:= {}
	Private aSZD     	:= {}
	Private aSINUM		:= {}

	Private aLayout		:= {"CKD (CSV)","CBU - Hyundai (TXT)","CBU - Subaru (CSV)","CBU - Chery (CSV)", "Peças (CSV)"}
	Private aTipPreco   := {"Considerar o preço da Invoice","Considerar o preço da P.O."}

	Private cArquivo	:= Space(50)
	Private cPoNUM		:= Space(100)
	Private cTitulo		:= "Integração de Invoice Antecipada"
	Private cWKEW5		:= "WKEW5"

	Private cDiretorio	:= GetMV("CMV_EIC01A",.T.,Space(100))
	Private cDirInicial	:= GetMV("CMV_EIC01A",.T.,Space(100))
	Private cFilInv	    := Getmv("CMV_EIC01B",.T.,"2010022001|2020012001")

	Private cAnoFab		:= Str(Year(dDataBase), 4)
	Private cAnoMod		:= Str(Year(dDataBase), 4)

	Private cLayout		:= Iif( FWCodEmp() == "2020", aLayout[5], aLayout[1] )
	Private cPicVlr 	:= "@E 999,999,999.99"
	Private lAgt_Ok		:= "1"
	Private lOk_Shp		:= "1"

	If (nPos:=RAt("\",cDirInicial)) > 0
		cDirInicial := Subs(cDirInicial,1,nPos)
	EndIf

	bGetDir := {|| cDiretorio := cGetFile ( , "Selecione o arquivo:", 1,cDirInicial, .F., GETF_LOCALHARD + GETF_MULTISELECT ),.F.}

	//Não permite entrar na rotina caso a filial não esteja habilitada.
	if !cFilAnt $ cFilInv
		alert("Rotina não permite acesso nesta filial logada.")
		return nil
	EndIf

	If Type("cDiretorio") <> "C"
		cDiretorio := Space(100)

	Else
		cDiretorio := cDiretorio + Space(100-Len(cDiretorio))

	EndIf

	CHKFILE('SZD')
	SZD->(dbSetOrder(1))
	

		Define MSDialog oDlg Title cTitulo From 0,0 TO 12,80 Of oMainWnd
			@ 0.3,nCo1	Say "Arquivo:"
			@ 0.2,nCo2	MSGet cDiretorio SIZE 200,8 Picture "@!"  Valid (Vazio() .OR. IIF(!File(AllTrim(cDiretorio)),(MsgStop("Arquivo Inválido!"),.F.),.T.)) When .F. Of oDlg
			@ 2,240 BUTTON "..." SIZE 12,12 ACTION (Eval(bGetDir)) Pixel OF oDlg
			@ 1.5,nCo1	Say "Layout:" SIZE 4,2 Of oDlg
			if FWCodEmp() == cFilExec
				@ 1.4,nCo2	Combobox cLayout ITEMS aLayout When .F. SIZE 80,12 Of oDlg
			else
				@ 1.4,nCo2	Combobox cLayout ITEMS aLayout When .T. SIZE 80,12 Of oDlg
			EndIF
			@ 1.5,nCo1+15	Say "Ano Fab:"
			@ 1.4,nCo2+14	MSGet cAnoFab Picture "9999" When .F. /*aScan( aLayout , cLayout )=3*/ Of oDlg
			@ 1.5,nCo1+22	Say "Ano Mod:"
			@ 1.4,nCo2+21	MSGet cAnoMod Picture "9999" When .F. /*aScan( aLayout , cLayout )=3*/ Of oDlg
			@ 2.7,nCo1 SAY "Proforma" Of oDlg
			if FWCodEmp() == cFilExec
				@ 2.6,nCo2 MsGet cPoNum F3 "SW2" Picture "@!" When .F./*aScan( aLayout , cLayout )<> 1*/ SIZE 60,08 Of oDlg
			else
				@ 2.6,nCo2 MsGet cPoNum F3 "SW2" Picture "@!" When aScan( aLayout , cLayout )<> 1 SIZE 60,08 Of oDlg
			EndIf
			@ 3.9,nCo1 Say "Preço:"
			@ 3.8,nCo2	Combobox cTipPreco ITEMS aTipPreco When aScan( aLayout , cLayout )== 1  SIZE 100,12 Of oDlg

			@ 64,10   BUTTON "Integração" SIZE 50,24 ACTION (IIF(ValidTela(),IntegraInv(),)) Pixel OF oDlg

			@ 70,65   BUTTON "Log"        SIZE 50,12 ACTION (CMVEIC0102()               ) Pixel OF oDlg
			@ 70,120  BUTTON "Relatorio"  SIZE 50,12 ACTION (CMVEIC0103()               ) Pixel OF oDlg
			@ 70,262  BUTTON "Layouts"    SIZE 50,12 ACTION (zLayouts()                 ) Pixel OF oDlg
			@ 02,262  BUTTON "Sair"       SIZE 50,12 ACTION (oDlg:End(),lConfirma := .F.) Pixel OF oDlg

		Activate MSDialog oDlg Centered

	//Enddo

	If !Empty(cDiretorio)
		PutMV("CMV_EIC01A",AllTrim(cDiretorio))
	EndIf

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function ValidTela()
	Local lRet := .T.
	Local cExtAux := ""

	If !File(AllTrim(cDiretorio))
		MsgStop("Arquivo não existe!")
		lRet := .F.

	ElseIf Empty(cLayout)
		MsgStop("Selecionar Layout!")
		lRet := .F.

	Else
		nLayout   := aScan( aLayout , cLayout )

		If (FWCodEmp() == cFilExec .AND. nLayout < 5) .OR. (FWCodEmp() <> cFilExec .AND. nLayout = 5)
			FWAlertError("O layout " + Alltrim(aLayout[nLayout]) + " não pode ser usado nessa filial", "CMVEIC01")
			Return
		EndIf

		nTipPreco := aScan( aTipPreco , cTipPreco )
		cExtAux   := SubsTr(AllTrim(cDiretorio),len(AllTrim(cDiretorio))-3,4)

		If !Upper(cExtAux) $ ".CSV/.TXT/"
			MsgStop("Extensão do arquivo está inválida!")
			lRet := .F.

		Else
			cExt  	  := cExtAux
			cArquivo  := RetFileName(cDiretorio) + cExt
			cArqFalta := Upper(cDiretorio)
			cArqFalta := StrTran(cArqFalta,".CSV")
			cArqFalta := StrTran(cArqFalta,".TXT")
			cArqFalta += "-FALTA-"+DTOS(Date())+StrTran(Time(),":")+".CSV"
			cFalta	  := ""

		EndIf

	EndIf

	If lRet

		cInvNum	 := ""
		cRateado   := ""
		cFornecedor:= ""
		cForLoj    := ""
		cFORN      := ""
		cSINUM	   := ""
		cCC        := ""
		cIncoterm  := ""
		cFreInc	   := ""
		cSegInc	   := ""
		nVlrFre	   := 0
		nVlrSeg	   := 0
		nVlrInland := 0
		nVlrPack   := 0
		nVlrDesc   := 0
		nVlOutD	   := 0
		nRecW2	   := 0
		nTotalFOB  := 0
		nRecZZE    := 0  	//usada no função CMVEIC0101
		lCapaLog   := .F.	//usada na função CMVEIC0101
		aSINUM	   := {}

	EndIf

Return lRet

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function IntegraInv()
	
	Local cINTCSV   := AllTrim(cDiretorio)
	
	Private cItAcerto	:= ""
	Private cMoedaP		:= ""
	Private cArqFalta	:= Upper(AllTrim(cDiretorio))
	Private lOk 		:= .T.
	Private lCapaOK 	:= .F.
	lErroGer	:= .F.
	cArqFalta	:= StrTran(cArqFalta,".CSV")
	cArqFalta	:= StrTran(cArqFalta,".TXT")
	cArqFalta	+= "-FALTA-"+DTOS(Date())+StrTran(Time(),":")+".CSV"
	cFalta		:= ""

	MontaWork1()
	if nLayout == 5
		Processa( {|| lErroGer := !(U_ZEICF021(cINTCSV,cPoNum))}, "Lendo Arquivo de Integração...", OemToAnsi("Lendo dados do arquivo..."),.F.)
	Else
		Processa( {|| LerDados(cINTCSV)  }, "Lendo Arquivo de Integração...", OemToAnsi("Lendo dados do arquivo..."),.F.)
	EndIf

	If lErroGer
		If !Empty(cFalta)
			MemoWrite( cArqFalta , cFalta )
		EndIf

		MsgStop("Integração não pode ser concluída! Verifique relatório de Erros"+IIF(Empty(cFalta),"",+CRLF+" "+CRLF+"Itens sem pedidos listados em arquivo: "+cArqFalta))

	Elseif nLayout <> 5 

		CMV01Capa()
		If lCapaOk
			Processa( {|| CMV01GravaInv()},"Gravando Dados da Invoice...", OemToAnsi("Gravando dados..."),.F.)

			If nLayout = 1 .OR. nLayout = 5  // gravar na szm se é layout ckd
				FWMsgRun(, {|| zGrvArq() }, "", "Gravando SZM...")
			EndIf

			// renomeia arquivo .csv
			if lOk
				fRename(cINTCSV,Subs(cINTCSV,1,At(".CSV",Upper(cINTCSV))-1)+".OK")
			EndIf
			MsgInfo("Integração concluida com sucesso!" + CRLF +  "Para ver um log do resultado clique no botão 'Log' ")
		EndIf

	EndIf

	If Select(cWKEW5) > 0
		(cWKEW5)->(dbCloseArea())
		fErase(cArqEW5+GetDbExtension())

	EndIf

	cPoNUM		:= Space(Len(Sw2->W2_Po_Num))
	cInvoice	:= ""

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function MontaWork1()
	Local aStrut1 := {}
	Local nArea	  := Select()

	If Select(cWKEW5) > 0
		(cWKEW5)->(dbCloseArea())
	EndIf

	dbselectArea("SX3")
	dbsetOrder(1)
	dbSeek("EW5")

	While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "EW5"
		If !(SX3->X3_CAMPO $ "EW5_FILIAL")// .And. X3Uso(SX3->X3_USADO)
			AADD(aStrut1, {X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL})
		EndIf
		SX3->(DbSkip())
	EndDo

	// NCM e Ex para o layout de pecas
	AADD(aStrut1, {"EW5_NCM"   , "C", TamSx3("B1_POSIPI" )[1], 0})
	AADD(aStrut1, {"EW5_EXNCM" , "C", TamSx3("B1_EX_NCM" )[1], 0})
	AADD(aStrut1, {"EW5_XNAVIO", "C", TamSx3("EW4_XNAVIO")[1], 0})
	AADD(aStrut1, {"EW5_XHOUSE", "C", TamSx3("EW4_XHOUSE")[1], 0})
	AADD(aStrut1, {"EW5_XCHAV2", "C", 100, 0})

	cArqEW5 := CriaTrab(aStrut1, .T.)
	if FWCodEmp() <> cFilExec
		If File(cArqEW5_2+OrdBagExt())
			fErase(cArqEW5_2+OrdBagExt())
		EndIf
	
		cArqEW5_2 := CriaTrab(Nil, .F.)
		dbUseArea(.t.,,cArqEW5,cWKEW5,.f.,.f.)
		IndRegua(cWKEW5,cArqEW5+OrdBagExt(),"EW5_INVOIC+EW5_CC+EW5_SI_NUM+EW5_PO_NUM+EW5_POSICA+EW5_COD_I+EW5_XCASE")
	// ordena WKEW5 igual a tela padrao de invoice antecipada, para poder enumerar os itens corretamente
		IndRegua(cWKEW5,cArqEW5_2+OrdBagExt(),"EW5_INVOIC+EW5_PO_NUM+EW5_COD_I+EW5_SI_NUM+EW5_POSICA")
		SET INDEX TO (cArqEW5),(cArqEW5_2)
	else
		If File(cArqEW5_1+OrdBagExt())
			fErase(cArqEW5_1+OrdBagExt())
		EndIf
	
		If File(cArqEW5_2+OrdBagExt())
			fErase(cArqEW5_2+OrdBagExt())
		EndIf
		cArqEW5_1 := CriaTrab(Nil, .F.)
		cArqEW5_2 := CriaTrab(Nil, .F.)
		dbUseArea(.t.,,cArqEW5,cWKEW5,.T.,.F.)

		(cWKEW5)->(DBClearIndex() )
		DBCreateIndex(cWKEW5+'1', "EW5_INVOIC+EW5_CC+EW5_SI_NUM+EW5_PO_NUM+EW5_POSICA+EW5_COD_I+EW5_XCASE", {|| EW5_INVOIC+EW5_CC+EW5_SI_NUM+EW5_PO_NUM+EW5_POSICA+EW5_COD_I+EW5_XCASE})
  		DBCreateIndex(cWKEW5+'2', "EW5_INVOIC+EW5_PO_NUM+EW5_COD_I+EW5_SI_NUM+EW5_POSICA" , {|| EW5_INVOIC+EW5_PO_NUM+EW5_COD_I+EW5_SI_NUM+EW5_POSICA })
	EndIf


	(cWKEW5)->(dbSetOrder(1))

	dbSelectArea(nArea)

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function LerDados(cINTCSV)
	
	Local cLinhaIT   := ""
	Local cChaveSZD  := ''
	Local cMOD       := ''
	Local cFAB       := ''
	Local cNavio     := ''
	Local cHouse     := ''
	Local cSerMo     := ''
	Local cCodProd    := ''
	Local cCodTxt     := ''
	Local cSeparador  := ";"	
	Local i           := 0
	Local nQTDE       := 0
	Local nPreco      := 0
	Local nPos        := 0
	Local nCnt        := 0
	Local nQtdEW5     := 0
	Local nQtdSW3     := 0
	Local nI          := 0
	Local nPsLiq      := 0
	Local nPreUni 	  := 0
	Local nQuantTotSW3 := 0
	Local nLinha       := 1
	Local lErro        := .F.
	Local aCampos      := {}
	Local aPO          := {}
	Local aReg         := {}
	Local aAux         := {}
	Local aQuantPOInv  := {}
	Public aQuantTot   := {}

	dbSelectArea("EW4")
	EW4->(dbSetOrder(1))

	dbSelectArea("SA5")
	SA5->(dbSetOrder(2))

	If Empty(cINTCSV)

		lErroGer := .T.
		MsgStop("Caminho do arquivo em Branco!")
		CMVEIC0101("Caminho do arquivo em Branco!",,,,"R",,,)
		Return

	EndIf
	
	aSZD     := {}
	aInvoice := {}
	cInvoice := ''

	Ft_FUse(cINTCSV)

	_aLinha	:={}
	SW3->( DbOrderNickName("CAOAOPC") )
	lAnuente := .F.

	// agrupa para encontrar quantidade total
	If nLayOut == 1  /* CKD */ .OR. (nLayOut == 5 .And. FWCodEmp() == cFilExec)

		While !FT_FEof() .and. !(lErro .or. lErroGer)
			i++
			cLinhaIT := FT_FReadLn()
			lErro := .F.
		
			If Empty(cLinhaIT) .Or. cLinhaIT==";" .Or. SubStr(cLinhaIT,1,10)=="Engine No." .Or. cLinhaIT=="CASE;MODEL;VIN-CODE;ENGINE;COLOR;SPECOP;KEYNO;T/MNO;"
				FT_FSkip()
				Loop
			EndIf

			aCampos := SEPARA(cLinhaIT,cSeparador)
			IF nLayOut == 1 .And. Len(aCampos) <> 11
				lErro := .T.
				Exit
			Else
				aCampos[7]:=StrTran(aCampos[7], ",",".")

				if nLayOut == 5
					aCampos[5] := aCampos[5]
				Else
					aCampos[5] := StrTran(aCampos[5], "-","")
				EndIf

				If Len(aCampos) > 0
					For nI := 1 to Len(aCampos)
						aCampos[nI]	:= AllTrim(aCampos[nI])
					Next nI
				EndIf

				cInvoice   := AllTrim(aCampos[2])
				aCampos[4] := StrZero(Val(aCampos[4]),3)
				cPoNUM 	   := aCampos[11]
				cCodProd   := aCampos[5]
			EndIf

			nPos := aScan(aQuantTot, { |x| x[1]+x[2]+x[3] == cInvoice+cPoNUM+cCodProd } )
			
			If nPos == 0
				aAdd(aQuantTot,{cInvoice,cPoNUM,cCodProd,Val(aCampos[6]),.F.,{{Val(aCampos[6]),val(aCampos[7])}}})
			Else
				aQuantTot[nPos][4] += Val(aCampos[6])
				aadd(aQuantTot[nPos][6],{Val(aCampos[6]),Val(aCampos[7])})
			EndIf

			If !lErro // se lErro ,pulo de linha jah foi feito
				FT_FSkip()
			EndIf
		EndDo
	EndIf

	FT_FGotop()
	i := 0

	While !FT_FEof() //.and. !(lErro .or. lErroGer)
		i++
		cLinhaIT := FT_FReadLn()
		lErro := .F.
		
		If Empty(cLinhaIT) .Or. cLinhaIT == ";" .Or. SubStr(cLinhaIT,1,10) == "Engine No." .Or. cLinhaIT == "CASE;MODEL;VIN-CODE;ENGINE;COLOR;SPECOP;KEYNO;T/MNO;"
			FT_FSkip()
			Loop
		EndIf

		If .F. /* nLayOut==3*/
			IF Empty(cInvoice)
				IF SubStr(cLinhaIT,1,11) == "Invoice No."
					cInvoice := SubStr(cLinhaIT,13,At(";",SubStr(cLinhaIT,13))-1)
					FT_FSkip()
					Loop
				Else
					FT_FSkip()
					Loop
				EndIf
			EndIf
		EndIf

		/*	nLayout
			1 - "CKD (CSV)"
			2 - "CBU - Hyundai (TXT)"
			3 - "CBU - Subaru (CSV)"
		4 - "Peças de Reposição (CSV)"*/

		nLinha++
		If nLayOut == 1 // CKD
			/*  CKD
			LAYOUT NOVO - Definido dia 25/04/2019 - Carneiro
			[01] LOTE
			[02] INVOICE
			[03] CONHECIMENTO EMBARQUE SW6
			[04] SEQ
			[05] CODIGO PRODUTO
			[06] QUANTIDADE
			[07] VALOR UNITARIO
			[08] NAVIO SW6
			[09] CONTAINER
			[10] CAIXAS
			[11] PO
			[12] unitizador		 */
			aCampos := SEPARA(cLinhaIT,cSeparador)
			//			IF Len(aCampos) <> 11
			IF Len(aCampos) < 12
				lErro := .T.
			Else

				aCampos[6]:=StrTran(aCampos[6], ".", "")
				aCampos[7]:=StrTran(aCampos[7], ",",".")
				aCampos[5]:=StrTran(aCampos[5], "-","")

				If Len(aCampos) > 0

					For nI := 1 to Len(aCampos)
						aCampos[nI]	:= AllTrim(aCampos[nI])
					Next nI

				EndIf

				cInvoice   := AllTrim(aCampos[2])
				cSerMo 	   := ''
				aCampos[4] := StrZero(Val(aCampos[4]),3)
				cPoNUM 	   := aCampos[11]
				cCodProd   := aCampos[5]
				cHouse     := Alltrim(aCampos[3])
				cNavio     := Alltrim(aCampos[8])

			EndIf

		ElseIF nLayout == 2

			IF Len(cLinhaIT) < 260
				lErro := .T.
			Else
				/* CBU HYUNDAI
				POSIÇÃO
				1 A 5 - NRO PROFORMA
				46 A 52 - NOME DO NAVIO
				54 A 69 - NRO DA INVOICE
				70 A 82 - CODIGO DO MODELO (RETIRAR ESPACOS EM BRANCO)
				83 A 86 - CODIGO DO OPICIONAL
				87 A 89 - CODIGO DA COR EXTERNA
				90 A 92 - CODIGO DA COR INTERNA
				101 A 116 - NUMERDO DO BL
				128 A 144 - NUMERO DO CHASSI
				145 A 156 - NUMERO DO MOTOR
				160 A 164 - NUMERO DA CHAVE
				206 A 210 - ANO MODELO
				210 A 213 - ANO FABRICACAO
				*/
				aCampos	:= Array(13)
				aCampos[01]	:= AllTrim(Subs(cLinhaIT,001,005)) // 001 a 005 - nro proforma <<< CONFIRMAR LAYOUT MIT044 COM 4 POSIÇÔES
				aCampos[02]	:= AllTrim(Subs(cLinhaIT,046,007)) // 046 a 052 - nome do navio
				aCampos[03]	:= AllTrim(Subs(cLinhaIT,054,016)) // 054 a 069 - nro da invoice
				cInvoice    := AllTrim(aCampos[3])
				aCampos[04]	:= AllTrim(Subs(cLinhaIT,070,013)) //AllTrim(Subs(cLinhaIT,070,013)) // 070 a 082 - codigo do modelo (retirar espacos em branco)
				aCampos[05]	:= AllTrim(Subs(cLinhaIT,083,004)) // 083 a 086 - codigo do opcional
				aCampos[06]	:= AllTrim(Subs(cLinhaIT,087,003)) // 087 a 089 - codigo da cor externa
				aCampos[07]	:= AllTrim(Subs(cLinhaIT,090,003)) // 090 a 092 - codigo da cor interna
				aCampos[08]	:= AllTrim(Subs(cLinhaIT,101,016)) // 101 a 116 - numerdo do bl
				aCampos[09]	:= AllTrim(Subs(cLinhaIT,128,017)) // 128 a 144 - numero do chassi
				aCampos[10]	:= AllTrim(Subs(cLinhaIT,145,012)) // 145 a 156 - numero do motor
				aCampos[11]	:= AllTrim(Subs(cLinhaIT,160,005)) // 160 a 164 - numero da chave
				aCampos[12]	:= AllTrim(Subs(cLinhaIT,206,004)) // 206 a 209 - ano modelo
				aCampos[13]	:= AllTrim(Subs(cLinhaIT,210,004)) // 210 a 213 - ano fabricacao

				cMOD       := aCampos[12]
				cFAB       := aCampos[13]
				cSerMo     := RIGHT(Alltrim(aCampos[09]),8)
				aCampos[4] := StrTran(aCampos[4],Chr(32),"")
				cCodProd   := aCampos[4]
				cHouse     := Alltrim(aCampos[8])
				cNavio     := Alltrim(aCampos[2])

			EndIf

		ElseIf nLayout == 3 // 	3 - "CBU - Subaru (CSV)"
			/*
			CBU Subaru
			[01] Case
			[02] Model
			[03] VIN-CODE (Chassi)
			[04] Engine / Motor
			[05] Color / EEII - EE-Cor Externa / II-Cor Interna
			[06] Opcional
			[07] Chave / KeyNo
			[08] T/MNO - Valor Total
			// 10/10/2019 - Alteração de layout. Inclusão de colunas Invoice, Ano Fab e Ano Mod
			[09] Invoice
			[10] Ano Fab
			[11] Ano Mod    */

			cMOD      := cAnoMod
			cFAB      := cAnoFab

			aCampos := SEPARA(cLinhaIT,cSeparador)
			IF  Len(aCampos) < 11 //08
				lErro := .T.
			Else
				If Len(aCampos) > 0
					For nI := 1 to Len(aCampos)
						aCampos[nI]	:= AllTrim(aCampos[nI])
					Next nI
				EndIf

				cSerMo		:= RIGHT(Alltrim(aCampos[03]),8)
				cInvoice	:= aCampos[09]
				cFAB      	:= aCampos[10]
				cMOD      	:= aCampos[11]
			
			EndIf

			cCodProd  := aCampos[2]
			cHouse    := ''
			cNavio    := ''

			IF Empty(cCodProd)
				FT_FSkip()
				Loop
			EndIf

		ElseIf nLayout == 4 // 	4 - "CBU - Chery (CSV)"
			/*
			CBU Chery
			[01] Case
			[02] Model
			[03] VIN-CODE (Chassi)
			[04] Engine / Motor
			[05] Cor Externa
			[06] Cor Interna
			[07] Opcional
			[08] BL
			[09] Valor Total
			[10] Invoice
			[11] Ano Fab
			[12] Ano Mod */

			cMOD      := cAnoMod
			cFAB      := cAnoFab

			aCampos := SEPARA(cLinhaIT,cSeparador)
			IF  Len(aCampos) < 12 //08
				lErro := .T.
			Else
				
				If Len(aCampos) > 0
					For nI := 1 to Len(aCampos)
						aCampos[nI]	:= AllTrim(aCampos[nI])
					Next nI
				EndIf

				cSerMo		:= RIGHT(Alltrim(aCampos[03]),8)
				cInvoice	:= aCampos[10]
				cFAB      	:= aCampos[11]
				cMOD      	:= aCampos[12]
			EndIf

			cCodProd	:= aCampos[2]
			cHouse     	:= Alltrim(aCampos[8])
			cNavio     	:= ''

			IF Empty(cCodProd)
				FT_FSkip()
				Loop
			EndIf

		ElseIf nLayout == 5 // 4 - "PECAS REPOSICAO "
			/*
			[01] SEQUENCIA DO ITEM
			[02] NUMERO DA INVOICE
			[03] NCM
			[04] EX
			[05] CODIGO PRODUTO
			[06] QUANTIDADE
			[07] VALOR UNITÁRIO
			[08] CONTAINER
			[09] CAIXA
			[10] PESO LIQUIDO
			[11] NUMERO DA PURCHASE ORDER
			[12] CONHECIMENTO EMBARQUE
			[13] NAVIO   */

			aCampos := SEPARA(cLinhaIT, cSeparador)
			IF  Len(aCampos) < 13
				lErro := .T.
			Else
				For nI := 1 to Len(aCampos)
					aCampos[nI] := AllTrim(aCampos[nI])
				Next nI

				cInvoice  := aCampos[02]
				cNcm	  := PadR(aCampos[03], TamSx3("YD_TEC"   )[1], " ")
				cExNcm    := PadR(aCampos[04], TamSx3("W3_EX_NCM")[1], " ")
				cCodProd  := aCampos[05]
				nQuantArq := Val(aCampos[06])
				//nQTDE   := Val(aCampos[06])
				nPreco    := Val(StrTran(aCampos[07], ",", "."))
				cContainer:= aCampos[08]
				cPoNUM    := aCampos[11]
				cHouse    := aCampos[12]
				cNavio	  := aCampos[13]
				nPreUni   := nPreco / nQuantArq
				IF Empty(cCodProd)
					FT_FSkip()
					Loop
				EndIf
			EndIf

		EndIf

		If lErro
			lErroGer := .T.
			CMVEIC0101("Layout da linha inválido!",nLinha,,cFornecedor,cForloj,"R",,,cInvoice)
			Exit
		EndIf

		//Inicia Validacoes
		//INVOICE
		If Empty(cInvoice)
			//ERRO INVOICE EM BRANCO
			CMVEIC0101("Número da Invoice em branco!",nLinha,,cFornecedor,cForloj,"R",AllTrim(aCampos[1]),,)
			lErro := .T.
		EndIf

		If lErro
			lErroGer := .T.
			Exit
		EndIf

		cInvoice := Stuff( Space(TamSX3("EW4_INVOIC")[1]) ,1 , Len(cInvoice) , cInvoice )
		If EW4->( dbSeek( xFilial("EW4") + cInvoice ) )
			//ERRO INVOICE JÁ EXISTE
			CMVEIC0101("Número da Invoice já existe!",nLinha,,EW4->EW4_FORN,EW4->EW4_FORLOJ,"R",AllTrim(aCampos[1]),,cInvoice)
			lErro := .T.
		EndIf

		If lErro
			lErroGer := .T.
			Exit
		EndIf

		//PO
		If Empty(cPoNum)
			//ERRO PO EM BRANCO
			CMVEIC0101("Número do PO em branco!",nLinha,,,,"R",,,cInvoice)
			lErro := .T.
		Else
			If !SW2->(dbSeek(xFilial("SW2")+cPONUM))
				CMVEIC0101("PO de número:" + AllTrim(cPoNum) +" não encontrado no sistema!",nLinha,			,		 ,		,"R"	 ,cPoNum,			,cInvoice)
				lErro := .T.
			Else
				cIncoterm	:= SW2->W2_INCOTER
				cMoedaP		:= SW2->W2_MOEDA
				nRecW2		:= SW2->(Recno())
			EndIf
		EndIf

		If lErro
			lErroGer := .T.
			Exit
		EndIf

		cFornecedor	:= SW2->W2_FORN//Posicione("SA2",1,xFilial("SA2")+SW2->W2_FORN+SW2->W2_FORLOJ,"A2_NREDUZ")
		cForloj		:= SW2->W2_FORLOJ

		//INVOICE
		If EW4->(dbSeek(xFilial("EW4")+AVKEY(cInvoice,"EW4_INVOICE")+SW2->W2_FORN+SW2->W2_FORLOJ))
			//ERRO INVOICE JÁ EXISTE NO SISTEMA
			MsgStop("Invoice número:" + AllTrim(cInvoice) +" já existe no sistema!")
			lErro := .T.
		EndIf

		If lErro
			lErroGer := .T.
			Exit
		EndIf

		If nLayout == 2
			cCodOpc := AVKEY(StrTran(aCampos[5],Chr(32),""),"W3_OPCION")
			cCorInt	:= AVKEY(aCampos[7],"W3_CORINT")
			cCorExt := AVKEY(aCampos[6],"W3_COREXT")

		ElseIf nLayout == 3 //CASE;MODEL;VIN-CODE;ENGINE;COLOR;SPECOP;KEYNO;T/MNO;
			cCodOpc := AVKEY(aCampos[6],"W3_OPCION")
			cCorInt	:= AVKEY(SubStr(aCampos[5],3,2),"W3_CORINT")
			cCorExt := AVKEY(SubStr(aCampos[5],1,2),"W3_COREXT")

		ElseIf nLayout == 4
			cCodOpc := AVKEY(aCampos[7],"W3_OPCION")
			cCorInt	:= AVKEY(aCampos[6],"W3_CORINT")
			cCorExt := AVKEY(aCampos[5],"W3_COREXT")

		Else
			cCodOpc := AVKEY(" ","W3_OPCION")
			cCorInt	:= AVKEY(" ","W3_CORINT")
			cCorExt := AVKEY(" ","W3_COREXT")
		EndIf

		cCodTxt  := AllTrim(cCodProd)
		cCodProd := AllTrim(cCodProd)+AllTrim(cCodOpc)+AllTrim(cCorInt)+AllTrim(cCorExt)
		cCodProd := PADR(cCodProd,TamSX3("W3_COD_I")[1])
		
		IF nLayout==1
			nQuantArq := Val(aCampos[6])
		ElseIF nLayout == 2 .OR. nLayout == 3 .OR. nLayout == 4
			nQuantArq := 1
		EndIf

		If Select("SYD") == 0
			DbSelectArea("SYD")
		EndIf

		If Empty(AllTrim(cCodProd))
			//ERRO PRODUTO EM BRANCO
			CMVEIC0101("Código de produto em branco!",nLinha,,cFornecedor,cForloj,"R",AllTrim(cPoNum),,cInvoice)
			lErro := .T.
		Else
			lSeekSW3	:= .F.
			IF aScan( aPO , { |x| x[1] ==  SW2->W2_PO_NUM+cCodProd } ) == 0
				If SW3->(dbSeek(xFilial("SW3")+SW2->W2_PO_NUM))

					While !SW3->( Eof() ) .And. SW3->(W3_FILIAL+W3_PO_NUM) == SW2->(W2_FILIAL+W2_PO_NUM)
					
						IF SW3->W3_SEQ == 0
					
							nQtdEW5 := QtdEW5(SW3->W3_PO_NUM,SW3->W3_COD_I,SW3->W3_SI_NUM,SW3->W3_POSICAO)
							nQtdSW3 := SW3->W3_QTDE-nQtdEW5
					
							If nQtdSW3 > 0
								nPos := aScan( aPO , { |x| x[1] ==  SW2->W2_PO_NUM+SW3->W3_COD_I } )
					
								IF nPos == 0
									AAdd( aPO , { SW2->W2_PO_NUM+SW3->W3_COD_I,{{SW3->(Recno()),nQtdSW3,SW3->(W3_PO_NUM+W3_CC+W3_SI_NUM+W3_COD_I+W3_POSICAO) }}} )
								Else
									aAux  := aPO[nPos,02]
									IF aScan( aAux, { |x| x[03] ==  SW3->(W3_PO_NUM+W3_CC+W3_SI_NUM+W3_COD_I+W3_POSICAO)  } ) == 0
					
										AAdd(aAux,{SW3->(Recno()),nQtdSW3,SW3->(W3_PO_NUM+W3_CC+W3_SI_NUM+W3_COD_I+W3_POSICAO)})
										aPO[nPos,02] := aAux
					
									EndIf
								EndIf
							EndIf
					
						EndIf
					
						SW3->( dbSkip() )
					
					EndDo
					
					IF aScan( aPO , { |x| x[1] ==  SW2->W2_PO_NUM+cCodProd } ) == 0
						lSeekSW3	:= .F.
					Else
						lSeekSW3	:= .T.
					EndIf
				
				EndIf
			Else
				lSeekSW3	:= .T.
			EndIf

			If !lSeekSW3
				//ERRO PRODUTO NÃO ENCONTRADO NO PEDIDO
				CMVEIC0101("Item " + AllTrim(cCodProd) + " não existe no pedido " + SW2->W2_PO_NUM ,nLinha,AllTrim(cCodProd) ,cFornecedor,cForloj,"R",AllTrim(SW2->W2_PO_NUM), , cInvoice)

				lErro := .T.

				IF nLayOut == 1 // CKD

					nPosTot := aScan(aQuantTot, { |x| Alltrim(x[1])+Alltrim(x[2])+alltrim(x[3]) ==  Alltrim(cInvoice)+Alltrim(SW2->W2_PO_NUM)+Alltrim(cCodProd) } )
				
					If nPosTot > 0 .and. aQuantTot[nPosTot][5]
					Else
						cFalta += AllTrim(cCodProd) + ";" + AllTrim(STR(nQuantArq)) + ";" + AllTrim(aCampos[7]) + ";" + cPoNUM + CRLF
					EndIf
				
				Else
					//codigo, ano mod, ano fab, opcional, cor int, cor ext, qtde, prec unit
					cFalta += AllTrim(cCodTxt)+ ";" +AllTrim(cFAB)+ ";" +AllTrim(cMOD)+ ";" +AllTrim(cCodOpc)+ ";" +AllTrim(cCorInt)+ ";" +AllTrim(cCorExt)+';1;0'+ ";" + cPoNUM + CRLF
				EndIf

			EndIf

		EndIf

		If lErro
			lErroGer := .T.
			FT_FSkip()
			Loop
		EndIf

		IF nLayout == 1 .and. Getmv("CMV_EIC01C",,.T.)
			
			nPos := aScan(aQuantPOInv, { |x| x[1]+x[2]+x[3] ==  cInvoice+SW2->W2_PO_NUM+cCodProd } )
			If nPos == 0
				aAdd(aQuantPOInv,{cInvoice,SW2->W2_PO_NUM,cCodProd,nQuantArq,0,cFornecedor,cForLoj,aCampos[7]})
			Else
				aQuantPOInv[nPos][4] += nQuantArq
			EndIf

		EndIf

		If nLayout == 5 .AND. Empty(GetAdvFVal("SYD", "YD_TEC", FwXFilial("SYD") + cNcm + cExNCM, 1, " ")) == .T.
			CMVEIC0101("NCM + Ex não cadastrado: " + cNcm + cExNCM + " não encontrado no sistema!", i,AllTrim(cCodProd),cFornecedor,cForloj, "R"	 ,cPoNum,			,cInvoice)
			lErro := .T.
		EndIf

		nPos := aScan( aPO , { |x| x[1] ==  SW2->W2_PO_NUM+cCodProd } )
		aAux := aPO[nPos,02]
		aReg := {}
		nQuantTotSW3 := 0

		nTotPro := 0
		If nLayout == 5
			For nI := 1 To Len(aAux)
					
				nTotPro += aAux[nI][2]
				nQuantTotSW3 += aAux[nI][2]
			Next nI

			if nTotPro >= nQuantArq

				For nI := 1 To Len(aAux)
				
					IF nQuantArq > 0 .AND. nTotPro > 0
						
						If (nQuantArq - aAux[nI][2]) == 0 	// 2 - 2 
							AAdd(aReg,{aAux[nI][1],nQuantArq})	// 2
							aAux[nI][2] := 0
							nQuantArq   := 0
						elseif (nQuantArq - aAux[nI][2]) > 0 		//	4-1 == 3
							AAdd(aReg,{aAux[nI][1],aAux[nI][2]})	// 1
							nQuantArq   := nQuantArq - aAux[nI][2]	// 4-1 == 3
							aAux[nI][2] := 0						//0 
						else
							nQuantArq := nQuantArq - aAux[nI][2]
							AAdd(aReg,{aAux[nI][1],nQuantArq})      // 1-4 == -3
							aAux[nI][2] := nQuantArq
							nQuantArq   := 0
							
						EndIf
									
					EndIf
				
				Next nI
			
			EndIf
		Else 
		
			For nI := 1 To Len(aAux)

				nQuantTotSW3 += aAux[nI][2]

				IF nQuantArq > 0 .AND. aAux[nI][2] > 0
			
					IF aAux[nI,2] >= nQuantArq
						AAdd(aReg,{aAux[nI][1],nQuantArq})
						aAux[nI][2] := aAux[nI][2] - nQuantArq
						nQuantArq := 0
					Else
						AAdd(aReg,{aAux[nI][1],aAux[nI][2]})
						nQuantArq := nQuantArq - aAux[nI][2]
						aAux[nI][2] := 0
					EndIf
			
				EndIf
			
			Next nI
		EndIf
		aPO[nPos,02] := aAux

		// valida quantidades totais
		If nLayOut == 1

			nPosTot := aScan(aQuantTot, { |x| Alltrim(x[1])+Alltrim(x[2])+alltrim(x[3]) ==  Alltrim(cInvoice)+Alltrim(SW2->W2_PO_NUM)+Alltrim(cCodProd) } )

			If nPosTot > 0 .and. !aQuantTot[nPosTot][5]

				If aQuantTot[nPosTot][4] > nQuantTotSW3
					aQuantTot[nPosTot][5] := .T. // marca que jah usou este agrupamento
					lErro := .T.
					lErroGer := .T.
					cFalta += AllTrim(cCodProd) + ";" + AllTrim(STR(aQuantTot[nPosTot][4]-nQuantTotSW3)) + ";" + AllTrim(aCampos[7]) + ";" + cPoNUM + CRLF
					FT_FSkip()
					Loop
				EndIf
		
			EndIf
		
			If nPosTot > 0
				aQuantTot[nPosTot][5] := .T. // marca que jah usou este agrupamento
			EndIf
		
		EndIf

		IF Len(aReg) == 0
			//ERRO PRODUTO NÃO ENCONTRADO NO PEDIDO
			CMVEIC0101("Não há saldo para o Item " + AllTrim(cCodProd) + "   pedido : " + SW2->W2_PO_NUM ,nLinha,AllTrim(cCodProd) ,cFornecedor,cForloj,"R",AllTrim(SW2->W2_PO_NUM), , cInvoice)
			lErro := .T.
		
			IF nLayOut == 1 // CKD
		
				nPosTot := aScan(aQuantTot, { |x| Alltrim(x[1])+Alltrim(x[2])+alltrim(x[3]) ==  Alltrim(cInvoice)+Alltrim(SW2->W2_PO_NUM)+Alltrim(cCodProd) } )
					
			Else
				//codigo, ano mod, ano fab, opcional, cor int, cor ext, qtde, prec unit
				cFalta += AllTrim(cCodTxt)+ ";" +AllTrim(cFAB)+ ";" +AllTrim(cMOD)+ ";" +AllTrim(cCodOpc)+ ";" +AllTrim(cCorInt)+ ";" +AllTrim(cCorExt)+';1;0' + ";" + cPoNUM + CRLF
			EndIf

			If nLayout == 5
				lErroGer := .T.
				FT_FSkip()
				Loop
			EndIf
		EndIf

		If lErro
			lErroGer := .T.
			FT_FSkip()
			Loop
		EndIf

		For nI := 1 To Len(aReg)

			IF aReg[nI,2] <= 0  .OR. VALTYPE(aReg[nI,1]) <> 'N'
				if nI > 1
					CMVEIC0101("Item " + AllTrim(cCodProd) + " saldo só atende o Item anterior " + SW2->W2_PO_NUM ,nLinha,AllTrim(cCodProd) ,cFornecedor,cForloj,"R",AllTrim(SW2->W2_PO_NUM), , cInvoice)
				else 
					CMVEIC0101("Item " + AllTrim(cCodProd) + " não existe saldo no pedido " + SW2->W2_PO_NUM ,nLinha,AllTrim(cCodProd) ,cFornecedor,cForloj,"R",AllTrim(SW2->W2_PO_NUM), , cInvoice)
				EndIf
				lErro := .T.
		
				IF nLayOut == 1 // CKD
					nPosTot := aScan(aQuantTot, { |x| Alltrim(x[1])+Alltrim(x[2])+alltrim(x[3]) ==  Alltrim(cInvoice)+Alltrim(SW2->W2_PO_NUM)+Alltrim(cCodProd) } )
				Else
					//codigo, ano mod, ano fab, opcional, cor int, cor ext, qtde, prec unit
					cFalta += AllTrim(cCodTxt)+ ";" +AllTrim(cFAB)+ ";" +AllTrim(cMOD)+ ";" +AllTrim(cCodOpc)+ ";" +AllTrim(cCorInt)+ ";" +AllTrim(cCorExt)+';1;0' + ";" + cPoNUM + CRLF
				EndIf
		
			EndIf

			If lErro
				lErroGer := .T.
				FT_FSkip()
				Loop
				//Exit
			EndIf
		
			SW3->( dbGoTo(aReg[nI,1]) )

			// ANOFAB / ANOMOD
			If nLayout == 2
		
				If Empty(aCampos[13]) .Or. Empty(aCampos[12])
					CMVEIC0101("Ano Fab. e/ou Ano Mod. em branco!",nLinha,AllTrim(cCodProd),cFornecedor,cForloj,"R",AllTrim(SW2->W2_PO_NUM),SW3->W3_POSICAO,cInvoice)
					lErro := .T.
				Else
		
					If AllTrim(aCampos[12]) <> SW3->W3_ANOMOD
						//ANO MODELO DIVERGENTE
						CMVEIC0101("Ano Modelo divergente! ARQUIVO:"+AllTrim(aCampos[12])+' Pedido :'+SW3->W3_ANOMOD ,nLinha,AllTrim(cCodProd),cFornecedor,cForloj,"R",AllTrim(SW2->W2_PO_NUM),SW3->W3_POSICAO,cInvoice)
						lErro := .T.
					EndIf
		
					If AllTrim(aCampos[13]) <> SW3->W3_ANOFAB
						//ANO FABRICAÇÃO DIVERGENTE
						CMVEIC0101("Ano Fabricação divergente!"+AllTrim(aCampos[12])+' Pedido :'+SW3->W3_ANOMOD ,nLinha,AllTrim(cCodProd),cFornecedor,cForloj,"R",AllTrim(SW2->W2_PO_NUM),SW3->W3_POSICAO,cInvoice)
						lErro := .T.
					EndIf
		
				EndIf
		
			EndIf

			If lErro
				lErroGer := .T.
				FT_FSkip()
				//Exit
				loop
			Else
		
				IF aScan( aInvoice, { |x| x[1] ==  cInvoice } ) == 0
					AAdd(aInvoice, {cInvoice,cHouse,cNavio})
				EndIf

				nPsLiq := SW3->W3_PESOL
				
				IF nLayout == 1
					cChaveSZD := SUBSTR(cInvoice,1,TamSX3("EW4_INVOIC")[1])+SW3->(W3_CC+W3_Si_Num+W3_Po_Num+SW3->W3_POSICAO+W3_COD_I)+Alltrim(aCampos[01])+aCampos[10]
					nPos := aScan( aSZD, { |x| x[1] ==  cChaveSZD } )
		
					IF nPos == 0
						AAdd(aSZD, {cChaveSZD,SUBSTR(cInvoice,1,TamSX3("EW4_INVOIC")[1])+SW3->(W3_CC+W3_Si_Num+W3_Po_Num+SW3->W3_POSICAO+W3_COD_I),Alltrim(aCampos[01]), aCampos[10], aReg[nI,2]})
					Else
						aSZD[nPos,5] += aReg[nI,2]
					EndIf
							
					If WKEW5->(dbSeek(SUBSTR(cInvoice,1,TamSX3("EW4_INVOIC")[1])+SW3->(W3_CC+W3_Si_Num+W3_Po_Num+SW3->W3_POSICAO+W3_COD_I)))

						WKEW5->(RecLock("WKEW5",.F.))
						WKEW5->EW5_QTDE		:=  WKEW5->EW5_QTDE + aReg[nI,2]
						WKEW5->(MSUnlock())
						Loop
					EndIf
		
					nQTDE     := aReg[nI,2]
		
					IF nTipPreco == 1
						nPreco    := Val(aCampos[7])
					Else
						nPreco    := SW3->W3_PRECO
					EndIf
		
				ELSEIF nLayout == 3 .OR. nLayout == 2 .OR. nLayout == 4
					nQTDE     := 1
					nPreco    := SW3->W3_PRECO
				ELSEIF nLayout == 5
					nQTDE   := Val(aCampos[06])
					nPsLiq 	:= Val(StrTran(aCampos[10], ",", "."))
					nPreco  := nPreUni * nQTDE
				EndIf

				WKEW5->(RecLock("WKEW5",.T.))
				WKEW5->EW5_INVOIC	:=	cInvoice
				WKEW5->EW5_COD_I	:=	SW3->W3_COD_I
				WKEW5->EW5_QTDE		:=  nQTDE
				WKEW5->EW5_PRECO	:=	nPreco
				WKEW5->EW5_FORN		:=	SW2->W2_FORN
				WKEW5->EW5_FORLOJ	:=	SW2->W2_FORLOJ
				WKEW5->EW5_CC		:=	SW3->W3_CC
				WKEW5->EW5_SI_NUM	:=	SW3->W3_SI_NUM
				WKEW5->EW5_PO_NUM	:=	SW3->W3_PO_NUM
				WKEW5->EW5_POSICA	:=	SW3->W3_POSICAO
				WKEW5->EW5_PGI_NU	:=	SW3->W3_PGI_NUM
				WKEW5->EW5_FABLOJ	:=	SW3->W3_FABLOJ
				WKEW5->EW5_SEQ		:=	SW3->W3_SEQ
				WKEW5->EW5_REG		:=	SW3->W3_REG
				WKEW5->EW5_PESOL	:=	nPsLiq
				WKEW5->EW5_PESOB	:=	SW3->W3_PESO_BR
				WKEW5->EW5_FABR		:=	SW3->W3_FABR

				If nLayout == 1

					WKEW5->EW5_XLOTE	:=	Alltrim(aCampos[01])+aCampos[10]
					WKEW5->EW5_XCASE	:=	aCampos[10]
					WKEW5->EW5_XCONT	:=	aCampos[09]

				ElseIf nLayOut == 2

					WKEW5->EW5_XVIN		:=	aCampos[9]
					WKEW5->EW5_XMOTOR	:=	aCampos[10]
					WKEW5->EW5_XCORIN	:=	aCampos[7]
					WKEW5->EW5_XCOREX	:=	aCampos[6]
					WKEW5->EW5_XOPC		:=	aCampos[5]
					WKEW5->EW5_XANOFB	:=	aCampos[13]
					WKEW5->EW5_XANOMD	:=	aCampos[12]
					WKEW5->EW5_XCHAVE	:=	aCampos[11]
					WKEW5->EW5_XLOTE	:=  aCampos[9]

				ElseIf nLayout == 3

					WKEW5->EW5_XVIN		:=	aCampos[3]
					WKEW5->EW5_XMOTOR	:=	aCampos[4]
					WKEW5->EW5_XCORIN	:=	cCorInt
					WKEW5->EW5_XCOREX	:=	cCorExt
					WKEW5->EW5_XOPC		:=	cCodOpc
					WKEW5->EW5_XANOFB	:=	cFab /*cAnoFab*/
					WKEW5->EW5_XANOMD	:=	cMod /*cAnoMod*/
					WKEW5->EW5_XCHAVE	:=	aCampos[7]
					WKEW5->EW5_XLOTE	:=  aCampos[3]

				ElseIf nLayout == 4

					WKEW5->EW5_XVIN		:=	aCampos[3]
					WKEW5->EW5_XMOTOR	:=	aCampos[4]
					WKEW5->EW5_XCORIN	:=	cCorInt
					WKEW5->EW5_XCOREX	:=	cCorExt
					WKEW5->EW5_XOPC		:=	cCodOpc
					WKEW5->EW5_XANOFB	:=	cFab /*cAnoFab*/
					WKEW5->EW5_XANOMD	:=	cMod /*cAnoMod*/
					WKEW5->EW5_XLOTE	:=  aCampos[3]

				ElseIf nLayout == 5

					WKEW5->EW5_NCM		:=  cNcm
					WKEW5->EW5_EXNCM    :=  cExNcm

				EndIf

				WKEW5->EW5_XSERMO       := cSerMo

				If SW3->W3_FLUXO == "1"
					lAnuente := .T.
					WKEW5->EW5_XFLUXO := "1"
				Else
					WKEW5->EW5_XFLUXO := "2"
				EndIf

				WKEW5->(MSUnlock())

			EndIf
		
		Next nI

		FT_FSkip()
	
	EndDo

	Ft_FUse()

	If nLayout == 1 .and. Getmv("CMV_EIC01C",,.T.) .and. !lErro
		// valida quantidades totais por invoice+PO+produto
		WKEW5->(dbGotop())

		While WKEW5->(!Eof())
			nPos := aScan(aQuantPOInv, { |x| x[1]+x[2]+x[3] == WKEW5->EW5_INVOIC+WKEW5->EW5_PO_NUM+WKEW5->EW5_COD_I} )
			If nPos > 0
				aQuantPOInv[nPos][5] += WKEW5->EW5_QTDE
			EndIf
			WKEW5->(dbSkip())
		Enddo

		WKEW5->(dbGotop())

		For nCnt:=1 To Len(aQuantPOInv)

			If aQuantPOInv[nCnt][4] > aQuantPOInv[nCnt][5]
				CMVEIC0101("Item " + AllTrim(aQuantPOInv[nCnt][3]) + " não existe saldo no pedido " + aQuantPOInv[nCnt][2] ,1/*nLinha*/,AllTrim(aQuantPOInv[nCnt][3]) ,aQuantPOInv[nCnt][6],aQuantPOInv[nCnt][7],"R",AllTrim(aQuantPOInv[nCnt][2]), , aQuantPOInv[nCnt][1])
				lErro := .T.
				lErroGer := .T.
				nPosTot := aScan(aQuantTot, { |x| Alltrim(x[1])+Alltrim(x[2])+alltrim(x[3]) ==  Alltrim(cInvoice)+Alltrim(SW2->W2_PO_NUM)+Alltrim(cCodProd) } )
				
			EndIf
		
		Next
	EndIf

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function CMV01Capa()
	Local oDlg2
	Local cDados  := cInvoice
	Local nCo1    := 1
	Local nCo2    := 6
	Local nCo3    := 20
	Local nCo4    := 26
	Local nOffP12 := 3
	Local nLarg := 100
	Local nAlt  := 2

	If Empty(cIncoterm)
		cIncoterm := Space(03)
	EndIf
	
	IF Len(aInvoice) > 1
		cDados := 'VARIAS'
	EndIf

	Define MSDialog oDlg2 Title "Informar dados da " + cTitulo From 0,0 TO 25,70 Of oMainWnd
		@ 0.2 + nOffP12,nCo1	Say "Invoice:"
		@ 0.2 + nOffP12,nCo2	MSGet cDados Picture "@!" SIZE nLarg,nAlt When .F. Of oDlg2
		@ 0.2 + nOffP12,nCo3	Say "Incoterm:"
		@ 0.2 + nOffP12,nCo4	MSGet cIncoterm F3 "SYJ" Picture "@!" VALID (ExistCPO("SYJ")) Of oDlg2
		@ 1.4 + nOffP12,nCo1	Say "Frete Incl S/N?" SIZE 4,2 Of oDlg2
		@ 1.4 + nOffP12,nCo2	Combobox cFreInc ITEMS {"Sim","Não"} When .T. SIZE 40,12 Of oDlg2
		@ 1.4 + nOffP12,nCo3	Say "Seg Incl S/N?" SIZE 4,2 Of oDlg2
		@ 1.4 + nOffP12,nCo4	Combobox cSegInc ITEMS {"Sim","Não"} When .T. SIZE 40,12 Of oDlg2
		@ 2.6 + nOffP12,nCo1	Say "Vlr Frete:"
		@ 2.6 + nOffP12,nCo2	MSGet nVlrFre Picture cPicVlr VALID (nVlrFre >= 0) Of oDlg2
		@ 2.6 + nOffP12,nCo3	Say "Vlr Seguro:"
		@ 2.6 + nOffP12,nCo4	MSGet nVlrSeg Picture cPicVlr VALID (nVlrSeg >= 0) of oDlg2
		@ 3.8 + nOffP12,nCo1	Say "Inland:"
		@ 3.8 + nOffP12,nCo2	MSGet nVlrInland Picture cPicVlr VALID (nVlrInland >= 0) Of oDlg2
		@ 3.8 + nOffP12,nCo3	Say "Packing:"
		@ 3.8 + nOffP12,nCo4	MSGet nVlrPack Picture cPicVlr VALID (nVlrPack >= 0) Of oDlg2
		@ 5.0 + nOffP12,nCo1	Say "Desconto:"
		@ 5.0 + nOffP12,nCo2	MSGet nVlrDesc Picture cPicVlr VALID (nVlrDesc >= 0) Of oDlg2
		@ 5.0 + nOffP12,nCo3	Say "Outras Desp:"
		@ 5.0 + nOffP12,nCo4	MSGet nVlOutD Picture cPicVlr VALID (nVlOutD >= 0) of oDlg2
		@ 6.2 + nOffP12,nCo1	Say "Rateado por:" SIZE 4,2 Of oDlg2
		@ 6.2 + nOffP12,nCo2	Combobox cRateado ITEMS {"Peso","Preço","Quantidade"} When .T. SIZE 80,12 Of oDlg2
		@ 6.2 + nOffP12,nCo3	Say "Data Invoice:"
		@ 6.2 + nOffP12,nCo4	MSGet dDtInvoice VALID !Empty(dDtInvoice) SIZE 50,08 of oDlg2
		@ 7.4 + nOffP12,nCo1	Say "Ok Agente:" SIZE 4,2 Of oDlg2
		@ 7.4 + nOffP12,nCo2	Combobox lAgt_Ok ITEMS {"1-Sim", "2-Não"} When .T. SIZE 40,12 Of oDlg2
		@ 7.4 + nOffP12,nCo1 + nOffP12+15	Say "Data Liberação:"
		@ 7.4 + nOffP12,nCo2 + nOffP12+15	MsGet dAgt_Ok Picture "@E" When lAgt_Ok="1" SIZE 80,12 Of oDlg2
		@ 8.6 + nOffP12,nCo1	Say "Ok Ship:" SIZE 4,2 Of oDlg2
		@ 8.6 + nOffP12,nCo2	Combobox lOk_Shp ITEMS {"1-Sim", "2-Não"} When .T. SIZE 40,12 Of oDlg2
		@ 8.6 + nOffP12,nCo1 + nOffP12+15	Say "Ok Ship:"
		@ 8.6 + nOffP12,nCo2 + nOffP12+15	MsGet	dOk_Shp Picture "@E" When lOk_Shp="1"  SIZE 80,12 Of oDlg2

	Activate MSDialog oDlg2 ON INIT EnchoiceBar(oDlg2,{|| IIF(CMV01ValCapa(),(lCapaOK := .T.,oDlg2:End()),)},{|| oDlg2:End() },) Centered

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function CMV01ValCapa()
	Local lRet := .T.

	If Empty(cIncoterm)
		MsgStop("Incoterm em Branco!")
		lRet := .F.

	Else
		If !ExistCPO("SYJ",cIncoterm)
			lRet := .F.
		EndIf

	EndIf

	If nVlrFre < 0
		MsgStop("Frete não pode ser negativo!")
		lRet := .F.

	EndIf

	If nVlrSeg < 0
		MsgStop("Seguro não pode ser negativo!")
		lRet := .F.

	EndIf

	If nVlrInland < 0
		MsgStop("InLand não pode ser negativo!")
		lRet := .F.

	EndIf

	If nVlrPack < 0
		MsgStop("Packing não pode ser negativo!")
		lRet := .F.

	EndIf

	If nVlrDesc  < 0
		MsgStop("Desconto não pode ser negativo!")
		lRet := .F.

	EndIf

	If nVlOutD < 0
		MsgStop("Valor de Outras Despesas não pode ser negativo!")
		lRet := .F.

	EndIf

	If Empty(cFreInc)
		MsgStop("Informe se frete é incluso!")
		lRet := .F.

	EndIf

	If Empty(cSegInc)
		MsgStop("Informe se seguro é incluso!")
		lRet := .F.

	EndIf

	If Empty(cRateado)
		MsgStop("Informe a forma de rateio!")
		lRet := .F.

	EndIf

	If Empty(dDtInvoice)
		MsgStop("Informe a data da Invoice!")
		lRet := .F.

	EndIf

Return lRet

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function CMV01GravaInv()
	
	Local cQuery	:= ""
	Local nTotInv	:= 0
	Local nI        := 0
	Local lProcEW5	:= .F.
	Local aBind     as array
	Local nPosTot	As Numeric
	Local cSeqEW5	:= StrZero(1,TamSX3("EW5_XITEW5")[1])
	Local cTmpAlias	:= GetNextAlias()
	
	aBind := {}
	
	WKEW5->(dbSetOrder(2))

	dbSelectAre('SW2')
	SW2->(dbSetOrder(1))

	dbSelectArea("EW4")
	dbSelectArea("EW5")

	Begin Transaction

		For nI := 1 To Len(aInvoice)

			cInvoice  := SUBSTR(aInvoice[nI][01],1,TamSX3("EW4_INVOIC")[1])
			nTotInv	  := 0
			nTotalFOB := 0

			WKEW5->(dbSeek(cInvoice))
		
			While !WKEW5->(EOF()) .AND. WKEW5->EW5_INVOIC == cInvoice
		
				IF SW2->(dbSeek(xFilial("SW2")+WKEW5->EW5_PO_NUM))

					lProcEW5	:= .F.
					
					If nLayOut == 5 .And. FWCodEmp() == cFilExec
						cQuery := ""
						cQuery += " SELECT SW3.W3_QTDE,EW5.* 						"+(Chr(13)+Chr(10))
						cQuery += " FROM "+RetSqlName("EW5")+" EW5 					"+(Chr(13)+Chr(10))
						cQuery += " INNER JOIN 										"+(Chr(13)+Chr(10))
						cQuery += "		 "+RetSqlName("SW3")+" SW3 ON				"+(Chr(13)+Chr(10))
						cQuery += " 		SW3.W3_FILIAL		= ? 				"+(Chr(13)+Chr(10))
						cQuery += " 	AND	EW5_PO_NUM			= SW3.W3_PO_NUM		"+(Chr(13)+Chr(10))
						cQuery += " 	AND	EW5.EW5_SI_NUM		= SW3.W3_SI_NUM		"+(Chr(13)+Chr(10))
						cQuery += " 	AND	EW5.EW5_FORN		= SW3.W3_FORN		"+(Chr(13)+Chr(10))
						cQuery += " 	AND	EW5.EW5_FORLOJ		= SW3.W3_FORLOJ		"+(Chr(13)+Chr(10))
						cQuery += " 	AND	EW5.EW5_COD_I		= SW3.W3_COD_I		"+(Chr(13)+Chr(10))
						cQuery += " 	AND	EW5.EW5_POSICA		= SW3.W3_POSICAO	"+(Chr(13)+Chr(10))
						cQuery += " 	AND	SW3.W3_SEQ			= 0					"+(Chr(13)+Chr(10))
						cQuery += " 	AND	EW5.D_E_L_E_T_		= SW3.D_E_L_E_T_	"+(Chr(13)+Chr(10))
						cQuery += " WHERE	EW5.EW5_FILIAL		= ? 				"+(Chr(13)+Chr(10))
						cQuery += " 	AND	EW5.EW5_INVOIC		= ? 				"+(Chr(13)+Chr(10))
						cQuery += "		AND	EW5.EW5_FORN		= ? 				"+(Chr(13)+Chr(10))
						cQuery += " 	AND	EW5.EW5_FORLOJ		= ? 				"+(Chr(13)+Chr(10))
						cQuery += " 	AND	EW5.EW5_SI_NUM		= ? 				"+(Chr(13)+Chr(10))
						cQuery += " 	AND	EW5.EW5_PO_NUM		= ? 				"+(Chr(13)+Chr(10))
						cQuery += " 	AND	EW5.EW5_COD_I		= ? 				"+(Chr(13)+Chr(10))
						cQuery += " 	AND	EW5.EW5_POSICA		= ? 				"+(Chr(13)+Chr(10))
						cQuery += " 	AND	EW5.D_E_L_E_T_		= ? 				"+(Chr(13)+Chr(10))
						cQuery += " ORDER BY EW5.EW5_FILIAL,EW5.EW5_INVOIC,EW5.EW5_FORN,EW5.EW5_FORLOJ,EW5.EW5_SI_NUM,EW5_PO_NUM,EW5.EW5_COD_I"

						If Select(cTmpAlias) <> 0 ; (cTmpAlias)->(DbCloseArea()) ; EndIf
						
						aBind :={}
						
						Aadd(aBind,xFilial("SW3")	)	
						Aadd(aBind,xFilial("EW5")	)	
						Aadd(aBind,WKEW5->EW5_INVOIC)
						Aadd(aBind,SW2->W2_FORN		)
						Aadd(aBind,SW2->W2_FORLOJ	)
						Aadd(aBind,WKEW5->EW5_SI_NUM)
						Aadd(aBind,WKEW5->EW5_PO_NUM)	
						Aadd(aBind,WKEW5->EW5_COD_I	)
						Aadd(aBind,WKEW5->EW5_POSICA)
						Aadd(aBind,Space(01)		)
						
						DbUseArea(.T., "TOPCONN", TCGenQry2(Nil, Nil, cQuery, aBind), cTmpAlias, .F., .T.)
						
						nPosTot := aScan(aQuantTot, { |x| Alltrim(x[1])+Alltrim(x[2])+alltrim(x[3]) ==  Alltrim(WKEW5->EW5_INVOIC)+Alltrim(WKEW5->EW5_PO_NUM)+Alltrim(WKEW5->EW5_COD_I) } )
						
						If (cTmpAlias)->(!Eof()) 
							EW5->(DbGoto((cTmpAlias)->R_E_C_N_O_))
							lProcEW5	:= .T.
						EndIf
					
					EndIf
					
					If lProcEW5
						WKEW5->(DbSkip())
						Loop
					EndIf

					cQuery := ""
					cQuery += " SELECT * "						+(Chr(13)+Chr(10))
					cQuery += " FROM "+RetSqlName("SW3")+" SW3 "+(Chr(13)+Chr(10))
					cQuery += " WHERE	SW3.W3_FILIAL		= ? "+(Chr(13)+Chr(10))
					cQuery += " 	AND	SW3.W3_PO_NUM		= ? "+(Chr(13)+Chr(10))
					cQuery += " 	AND	SW3.W3_SI_NUM		= ? "+(Chr(13)+Chr(10))
					cQuery += "		AND	SW3.W3_FORN			= ? "+(Chr(13)+Chr(10))
					cQuery += " 	AND	SW3.W3_FORLOJ		= ? "+(Chr(13)+Chr(10))
					cQuery += " 	AND	SW3.W3_COD_I		= ? "+(Chr(13)+Chr(10))
					cQuery += " 	AND	SW3.W3_POSICAO		= ? "+(Chr(13)+Chr(10))
					cQuery += " 	AND	SW3.W3_SEQ 			= 0 "+(Chr(13)+Chr(10))
					cQuery += " 	AND	SW3.D_E_L_E_T_		= ? "+(Chr(13)+Chr(10))
					cQuery += " ORDER BY SW3.W3_FILIAL,SW3.W3_PO_NUM,SW3.W3_SI_NUM,SW3.W3_FORN,SW3.W3_FORLOJ,SW3.W3_COD_I,SW3.W3_POSICAO,SW3.W3_SEQ"+(Chr(13)+Chr(10))

					If Select(cTmpAlias) <> 0 ; (cTmpAlias)->(DbCloseArea()) ; EndIf
					
					aBind :={}
					Aadd(aBind , xFilial("SW3")	  )
					Aadd(aBind , WKEW5->EW5_PO_NUM)
					Aadd(aBind , WKEW5->EW5_SI_NUM)
					Aadd(aBind , SW2->W2_FORN	  )
					Aadd(aBind , SW2->W2_FORLOJ	  )
					Aadd(aBind , WKEW5->EW5_COD_I )
					Aadd(aBind , WKEW5->EW5_POSICA)
					Aadd(aBind , Space(01)		  )
					
					DbUseArea(.T., "TOPCONN", TCGenQry2(Nil, Nil, cQuery, aBind), cTmpAlias, .F., .T.)

					nPosTot := aScan(aQuantTot, { |x| Alltrim(x[1])+Alltrim(x[2])+alltrim(x[3]) ==  Alltrim(WKEW5->EW5_INVOIC)+Alltrim(WKEW5->EW5_PO_NUM)+Alltrim(WKEW5->EW5_COD_I) } )
					
					EW5->(RecLock("EW5",.T.))
						EW5->EW5_FILIAL	:= xFilial("EW5")
						EW5->EW5_INVOIC	:= WKEW5->EW5_INVOIC //cInvoice
						EW5->EW5_FORN	:= SW2->W2_FORN
						EW5->EW5_FORLOJ	:= SW2->W2_FORLOJ
						EW5->EW5_CC		:= WKEW5->EW5_CC
						EW5->EW5_SI_NUM	:= WKEW5->EW5_SI_NUM
						EW5->EW5_PO_NUM	:= WKEW5->EW5_PO_NUM
						EW5->EW5_POSICA	:= WKEW5->EW5_POSICA
						EW5->EW5_PGI_NU	:= WKEW5->EW5_PGI_NU
						EW5->EW5_COD_I	:= WKEW5->EW5_COD_I
						EW5->EW5_QTDE 	:= fValTotal(nPosTot , (cTmpAlias)->W3_QTDE , .T.) //If(nPosTot <> 0 , aQuantTot[nPosTot][4] , (cTmpAlias)->W3_QTDE) //(EW5->EW5_QTDE + WKEW5->EW5_QTDE)
						EW5->EW5_PRECO	:= WKEW5->EW5_PRECO
						EW5->EW5_FABLOJ	:= WKEW5->EW5_FABLOJ
						EW5->EW5_SEQ	:= WKEW5->EW5_SEQ
						EW5->EW5_REG	:= WKEW5->EW5_REG
						EW5->EW5_PESOL	:= WKEW5->EW5_PESOL
						EW5->EW5_PESOB	:= WKEW5->EW5_PESOB
						EW5->EW5_FABR	:= WKEW5->EW5_FABR

						If !Empty(WKEW5->(EW5_XLOTE+EW5_XCASE))
							EW5->EW5_XLOTE	:=	If(nLayOut=3, WkEW5->EW5_XMOTOR, WKEW5->EW5_XLOTE)
							EW5->EW5_XCASE	:=	WKEW5->EW5_XCASE
						EndIf

						EW5->EW5_XCONT	:=	WKEW5->EW5_XCONT
						EW5->EW5_XVIN	:=	WKEW5->EW5_XVIN
						EW5->EW5_XMOTOR	:=	WKEW5->EW5_XMOTOR
						EW5->EW5_XCHAVE	:=	WKEW5->EW5_XCHAVE
						EW5->EW5_XOPC	:=	WKEW5->EW5_XOPC
						EW5->EW5_XANOFB	:=	WKEW5->EW5_XANOFB
						EW5->EW5_XANOMD	:=	WKEW5->EW5_XANOMD
						EW5->EW5_XCORIN	:= 	WKEW5->EW5_XCORIN
						EW5->EW5_XCOREX	:= 	WKEW5->EW5_XCOREX
						EW5->EW5_XSERMO	:=  WKEW5->EW5_XSERMO

						If lAnuente .and. WKEW5->EW5_XFLUXO == "1"
							EW5->EW5_XFLUXO := "1"
						Else
							EW5->EW5_XFLUXO := "2"
						EndIf
						EW5->EW5_XITEW5 := cSeqEW5

					EW5->(MSUnlock())

					cSeqEW5 := Soma1(cSeqEW5)
					// valter 02/08/2021
					// inserido arredondamento para tero mesmo comportamento do padrao
					If nLayout <> 5
						nTotalFOB	+=	Round(WKEW5->EW5_QTDE * WKEW5->EW5_PRECO, 2)
				  	Else
						nTotalFOB	+=  Round(If(nPosTot <> 0 .And. aQuantTot[nPosTot][4] <> 0, aQuantTot[nPosTot][4] , (cTmpAlias)->W3_QTDE) * WKEW5->EW5_PRECO, 2)
					EndIf
					If !((EW5->EW5_COD_I + WKEW5->EW5_PO_NUM) $ cItAcerto)
						CMVEIC0101("Item OK!",,WKEW5->EW5_COD_I,WKEW5->EW5_FORN,WKEW5->EW5_FORLOJ,"S",WKEW5->EW5_PO_NUM,WKEW5->EW5_POSICA,cInvoice)
					EndIf

					If nLayout == 5
						if zAtuNcmW3() = .T.
							CMVEIC0101("Atualizado NCM + ExNCM na W3",, WKEW5->EW5_COD_I, WKEW5->EW5_FORN, WKEW5->EW5_FORLOJ, "A", WKEW5->EW5_PO_NUM, WKEW5->EW5_POSICA, cInvoice)
						EndIf
					EndIf

					//atualiza a PLI
					CMV01AtulizaPLI()
				EndIf

				WKEW5->(dbSkip())

			EndDo

			nTotInv	:= nTotalFOB + IIF(cFreInc == "Sim",0,nVlrFre) + IIF(cSegInc == "Sim",0,nVlrSeg) + nVlrInland - nVlrDesc + nVlOutD + nVlrPack
			EW4->(RecLock("EW4",.T.))
				EW4->EW4_FILIAL	:=	xFilial("EW4")
				EW4->EW4_INVOIC	:=	cInvoice
				EW4->EW4_DT_EMI	:=	dDtInvoice
				EW4->EW4_FORN	:=	SW2->W2_FORN
				EW4->EW4_FORLOJ	:=	SW2->W2_FORLOJ
				EW4->EW4_MOEDA	:=	SW2->W2_MOEDA
				EW4->EW4_INCOTE	:=	cIncoterm
				EW4->EW4_COND_P	:=	SW2->W2_COND_PA
				EW4->EW4_DIAS_P	:=	SW2->W2_DIAS_PA
				EW4->EW4_FREINC	:=	IIF(cFreInc == "Sim","1","2")
				EW4->EW4_SEGINC	:=	IIF(cSegInc == "Sim","1","2")
				EW4->EW4_RATPOR	:=	IIF(cRateado == "Peso","1",IIF(cRateado == "Preço","2","3"))
				EW4->EW4_FOBTOT	:=	nTotalFOB
				EW4->EW4_FRETEI	:=	nVlrFre
				EW4->EW4_SEGURO	:=	nVlrSeg
				EW4->EW4_INLAND	:=	nVlrInland
				EW4->EW4_PACKIN	:=	nVlrPack
				EW4->EW4_DESCON	:=	nVlrDesc
				EW4->EW4_TOTINV	:=	nTotInv
				EW4->EW4_OK_SHP	:= 	lOk_SHP
				EW4->EW4_AGENTE	:= 	Sw2->W2_Agente
				EW4->EW4_Usr_AU	:=	SubStr(cUsuario, 7, 15)
				EW4->EW4_U_Ok_A	:=	SubStr(cUsuario, 7, 15)
				EW4->EW4_Agt_OK	:= 	lAgt_Ok
				If lOk_Shp == "1"
					EW4->EW4_DT_Lib	:=	dDataBase
					EW4->EW4_D_Ok_A	:=	dDataBase
				EndIf

				IF EW4->(FieldPos("EW4_XHOUSE")) > 0
					EW4->EW4_XHOUSE :=  aInvoice[nI][02]
				EndIf

				IF EW4->(FieldPos("EW4_XNAVIO")) > 0
					EW4->EW4_XNAVIO :=  aInvoice[nI][03]
				EndIf

				If lAnuente
					EW4->EW4_XFLUXO := "1"
				Else
					EW4->EW4_XFLUXO := "2"
				EndIf
				
			EW4->(MSUnlock())

			//Apagando a SZD
			SZD->(dbSeek(xFilial("SZD")+cInvoice))

			While SZD->(!EOF())
				Reclock("SZD",.F.)
				SZD->(dbDelete())
				SZD->(MsUnlock())
				SZD->(dbSeek(xFilial("SZD")+cInvoice))
			EndDo
		Next nI
		//Gravando a SZD
		For nI := 1 To Len(aSZD)
			SZD->(RecLock("SZD",.T.))
			SZD->ZD_FILIAL	:= xFilial("SZD")
			SZD->ZD_CHAVE   := aSZD[nI,02]
			SZD->ZD_LOTE    := aSZD[nI,03]
			SZD->ZD_CAIXA   := aSZD[nI,04]
			SZD->ZD_QTDE    := aSZD[nI,05]
			SZD->(MSUnlock())
		Next

		lOk := .T.
		
		if !lOk
			MsgAlert("Existe inconsistencia de valores verifique o Logs", "Atenção")
		EndIf
		
	End Transaction

	WKEW5->(dbSetOrder(1))

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function zAtuNcmW3()
	Local lOk := .T.
	Local cmd := ""

	cmd := CRLF + " UPDATE " + RetSqlName("SW3") + " SET "
	cmd += CRLF + "	W3_TEC    = '" + WKEW5->EW5_NCM   + "', "
	cmd += CRLF + "	W3_EX_NCM = '" + WKEW5->EW5_EXNCM + "' "
	cmd += CRLF + " WHERE D_E_L_E_T_ = ' ' "
	cmd += CRLF + " AND W3_FILIAL = '" + FwXfilial("SW3") + "' "
	cmd += CRLF + " AND W3_PO_NUM = '" + WKEW5->EW5_PO_NUM + "' "
	cmd += CRLF + " AND W3_COD_I  = '" + WKEW5->EW5_COD_I + "' "

	If TcSQLExec(cmd) < 0
		FWAlertError("Erro na rotina zAtuNcmW3(): " + TcSqlError(), "CMVEIC01" )
		lOk := .F.
	EndIf

Return lOk

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function CMV01AtulizaPLI()
	LOCAL cOrdSw3  := SW3->(IndexOrd())
	LOCAL nSw3Recno:= SW3->(Recno())
	LOCAL bSw3Valid:= {|| 	SW3->(!EOF())	.And.;
							SW3->W3_FILIAL  == xFilial("SW3")  .AND.;
							SW3->W3_PO_NUM	== EW5->EW5_PO_NUM .AND.;
							SW3->W3_FORN	== EW5->EW5_FORN  .AND. ;
							IIF(EICLoja() , SW3->W3_FORLOJ == EW5->EW5_FORLOJ,.T.) .And. ;
							SW3->W3_POSICAO == EW5->EW5_POSICA}

	SW3->(dbSetOrder(8))
	
	If SW3->(dbSeek(xFilial("SW3")+EW5->EW5_PO_NUM+EW5->EW5_POSICA))

		cPli := ""
		
		While eval(bSw3Valid)
		
			If SW3->W3_SEQ <> 1
				SW3->(dbSkip())
				Loop

			EndIf

			SW5->(dbSetOrder(8))
			If SW5->(dbSeek(xFilial("SW5")+EW5->EW5_PGI_NU+EW5->EW5_PO_NUM+EW5->EW5_POSICA))
				SW5->(RecLock("SW5"),.F.)
				SW5->W5_INVANT := EW5->EW5_INVOIC
				SW5->(MSUnlock())

			EndIf

			Exit

		EndDo

	EndIf

	SW3->(dbSetOrder(cOrdSw3))
	SW3->(dbGoTo(nSw3Recno))

Return(.T.)

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

User Function FCMVEIC0101(cTexto, nLinha, cProduto, cFornec, cLoja, cStatus, cPO, cPosicao, cInvoice)
	CMVEIC0101(cTexto, nLinha, cProduto, cFornec, cLoja, cStatus, cPO, cPosicao, cInvoice)
RETURN

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function CMVEIC0101(cTexto, nLinha, cProduto, cFornec, cLoja, cStatus, cPO, cPosicao, cInvoice)
	
	Default nLinha   := 0
	Default cProduto := ""
	Default cFornec  := ""
	Default cStatus  := ""
	Default cPO      := ""
	Default cPosicao := ""
	Default cInvoice := ""

	//Não permite entrar na rotina caso a filial não esteja habilitada.
	if !cFilAnt $ cFilInv

		alert("Rotina não permite acesso nesta filial logada.")
		return nil

	EndIf

	dbSelectArea("ZZE")
	dbSelectArea("ZZF")

	If Type("lCapaLog") != "L"
		Return

	EndIf

	If !lCapaLog
		CMVEIC0104(cProduto, cFornec, cLoja, cStatus, cPO, cPosicao, cInvoice)

	EndIf

	ZZF->(RecLock("ZZF",.T.))
		ZZF->ZZF_FILIAL	:=	xFilial("ZZF")
		ZZF->ZZF_INVOIC	:=	cInvoice
		ZZF->ZZF_FORN	:=	cFornec
		ZZF->ZZF_LOJA	:=	cLoja
		ZZF->ZZF_NRINTE	:=	nNumInte
		ZZF->ZZF_STATUS	:=	cStatus
		ZZF->ZZF_PO_NUM	:=	cPO
		ZZF->ZZF_COD_I	:=	cProduto
		ZZF->ZZF_POSICA	:=	cPosicao
		ZZF->ZZF_MOTIVO	:=	cTexto

	ZZF->(MSUnlock())

	If cStatus == "R" .AND. ZZE->ZZE_STATUS == "I"

		ZZE->(RecLock("ZZE",.F.))
			ZZE->ZZE_STATUS	:=	"R"

		ZZE->(MSUnlock())

	EndIf

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function CMVEIC0102()
	Local oDlg3
	Local oBrw
	Local cInvoice := ""
	Local cFornec  := ""
	Local cStats   := ""
	Local cNumInt  := ""
	Local cTit     := "Log de Erros"
	Local nCo1     := 1
	Local nCo2     := 5
	Local nCo3     := 20 
	local nCo4     := 24
	Local nCo5     := 40
	Local nCo6     := 44
	Local dDtProc  := CTOD("  /  /  ")
	
	Private cArqLog := ""
	Private cWork2	:= "WKLOG"
	Private lRejeic := .T.
	Private lSucess := .T.
	Private lMensag := .T.
	Private lAjust  := .T.
	Private aStrut2	:= {}
	Private aHeader := {}

	Private aRotina := { { "Pesquisar"   ,"AxPesqui"   ,0,1},;
						 { "Visualizar"  ,"AxVisual"   ,0,2},;
						 { "Incluir"     ,"u_SVMANZC2" ,0,3},;
						 { "Alterar"     ,"u_SVMANZC2" ,0,4},;
						 { "Excluir"     ,"AxDeleta"   ,0,5}}

	If Select("ZZE") == 0
	
		dbSelectArea("ZZE")
		dbSelectArea("ZZF")
		ZZE->(dbSetOrder(0))
		ZZE->(dbGoBottom())
		
		While !ZZE->(BOF()).AND. ZZE->ZZE_FILIAL != xFilial("ZZE")
			ZZE->(dbSkip(-1))
		EndDo

		ZZE->(dbSetOrder(1))

	EndIf

	cInvoice := ZZE->ZZE_INVOIC
	cFornec  := Posicione("SA2",1,xFilial("SA2")+ZZE->ZZE_FORN+ZZE->ZZE_LOJA,"A2_NREDUZ")
	dDtProc  := ZZE->ZZE_DTINTE
	cStats   := IIF(ZZE->ZZE_STATUS == "I","Integrada","Rejeitada")
	cNumInt  := ZZE->ZZE_NRINTE
	MontaWork(.T.)

	Define MSDialog oDlg3 Title cTit From 0,0 TO 40,160 Of oMainWnd
		@ 0.2 , nCo1 Say "Invoice:"           Of oDlg3
		@ 0.2 , nCo2 Msget cInvoice When .F.  Of oDlg3
		@ 0.2 , nCo3 Say "Fornecedor:"        Of oDlg3
		@ 0.2 , nCo4 MsGet cFornec When .F.   Of oDlg3
		@ 0.2 , nCo5 Say "Data:"              Of oDlg3
		@ 0.2 , nCo6 MsGet dDtProc When .F.   Of oDlg3
		@ 1.4 , nCo1 Say "Num. Tentativa:"    Of oDlg3
		@ 1.4 , nCo2 Msget cNumInt When .F.   Of oDlg3
		@ 1.4 , nCo3 Say "Status"             Of oDlg3
		@ 1.4 , nCo4 MsGet cStats When .F.    Of oDlg3
		@ 15 , 260 BUTTON "Sair" SIZE 40,12 ACTION (oDlg3:End()) Pixel OF oDlg3
		@ 35 , 10 Say "Itens:" Pixel          Of oDlg3
		@ 35,40  CHECKBOX lRejeic  PROMPT "Rejeitados" Size 60,5 OF oDlg3
		@ 35,100 CHECKBOX lSucess  PROMPT "Sucessos"   Size 60,5 OF oDlg3
		@ 35,160 CHECKBOX lMensag  PROMPT "Mensagens"  Size 60,5 OF oDlg3
		@ 35,220 CHECKBOX lAjust   PROMPT "Ajustes"    Size 60,5 OF oDlg3

		@ 35,280 BUTTON "Atualizar" SIZE 40,12 ACTION (MontaWork(.t.), oBrw:oBrowse:Refresh()) Pixel OF oDlg3
		oBrw := (cWork2)->(MsGetDB():New(60,10,(oDlg3:nClientHeight-25)/2,(oDlg3:nClientWidth-8)/2, 2, , , , .F.,{},, .F.,,cWork2,/*"u_SVDWFIOK"*/,,.T., oDlg3, .T.,, "",""))

	Activate MSDialog oDlg3 Centered

	WKLOG->(dbCloseArea())
	fErase(cArqLOG+GetDbExtension())

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function CMVEIC0104(cProduto, cFornec, cLoja, cStatus, cPO, cPosicao, cInvoice)

	nNumInte := 1
	If ZZE->(dbSeek(xFilial("ZZE")+AVKEY(cInvoice,"ZZE_INVOIC")+AVKEY(cFornec,"ZZE_FORN")))
		ZZE->(dbSeek(xFilial("ZZE")+AVKEY(cInvoice,"ZZE_INVOIC")+AVKEY(cFornec,"ZZE_FORN")+"9999999999",.T.))
		ZZE->(dbSkip(-1))
		nNumInte += ZZE->ZZE_NRINTE

	EndIf

	ZZE->(RecLock("ZZE",.T.))
		ZZE->ZZE_FILIAL	:=	xFilial("ZZE")
		ZZE->ZZE_INVOIC	:=	cInvoice
		ZZE->ZZE_FORN	:=	cFornec
		ZZE->ZZE_LOJA	:=	cLoja
		ZZE->ZZE_DTINTE	:=	dDataBase
		ZZE->ZZE_HRINTE	:=	Time()
		ZZE->ZZE_NRINTE	:=	nNumInte
		ZZE->ZZE_USER	:=	cUsername
		ZZE->ZZE_STATUS	:=	"I"
	ZZE->(MSUnlock())

	lCapaLog := .T.
	nRecZZE  := ZZE->(Recno())

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function MontaWork(lUmaInte)
	Local nArea := Select()

	If Select("WKLOG") == 0
		
		AADD(aStrut2, {"STATS"     , "C", 1, 0})
		AADD(aStrut2, {"PEDIDO"    , "C", AVSX3("W2_PO_NUM"  ,3), 0})
		AADD(aStrut2, {"INVOICE"   , "C", AVSX3("EW4_INVOICE",3), 0})
		AADD(aStrut2, {"COD_I"     , "C", AVSX3("B1_COD"     ,3), 0})
		AADD(aStrut2, {"DESC_I"    , "C", AVSX3("B1_DESC"    ,3), 0})
		AADD(aStrut2, {"MOTIVO"    , "C", AVSX3("ZZF_MOTIVO" ,3), 0})
		
		AADD(aHeader, {"Status"		,"STATS"  , "@!", 01                    , 0,"", , "C", , })
		AADD(aHeader, {"Pedido"		,"PEDIDO" , "@!", AVSX3("W2_PO_NUM"  ,3), 0,"", , "C", , })
		AADD(aHeader, {"Invoice"    ,"Invoice", "@!", AVSX3("EW4_INVOICE",3), 0,"", , "C", , })
		AADD(aHeader, {"Produto"	,"COD_I"  , "@!", AVSX3("B1_COD"     ,3), 0,"", , "C", , })
		AADD(aHeader, {"Descricao"  ,"DESC_I" , "@!", AVSX3("B1_DESC"    ,3), 0,"", , "C", , })
		AADD(aHeader, {"Motivo"		,"MOTIVO" , "@!", AVSX3("ZZF_MOTIVO" ,3), 0,"", , "C", , })
		
		cArqLOG := CriaTrab(aStrut2, .T.)
		dbUseArea(.t.,,cArqLOG,cWork2,.f.,.f.)

	Else
		If lUmaInte
			WKLOG->(__dbZap())

		EndIf

	EndIf

	dbSelectArea("ZZF")
	ZZF->(DbSeek(xFilial("ZZF")+ZZE->ZZE_INVOIC+ZZE->ZZE_FORN+ZZE->ZZE_LOJA+AllTrim(STR(ZZE->ZZE_NRINTE))))
	
	While !ZZF->(EOF()) .AND.ZZF_FILIAL == xFilial("ZZF") .AND. ZZE->ZZE_INVOIC == ZZF_INVOIC .AND. ZZF->ZZF_FORN == ZZE->ZZE_FORN .AND. ZZF->ZZF_LOJA == ZZE->ZZE_LOJA .AND. ZZF->ZZF_NRINTE == ZZE->ZZE_NRINTE
		
		If (ZZF->ZZF_STATUS == "R" .AND. lRejeic) .OR. (ZZF->ZZF_STATUS == "M" .AND. lMensag) .OR. (ZZF->ZZF_STATUS == "S" .AND. lSucess) .OR. (ZZF->ZZF_STATUS == "A" .AND. lAjust)
			
			RecLock(cWork2,.T.)
				WKLOG->STATS	:= ZZF->ZZF_STATUS
				WKLOG->PEDIDO	:= ZZF->ZZF_PO_NUM
				WKLOG->INVOICE  := ZZF->ZZF_INVOIC
				WKLOG->COD_I	:= ZZF->ZZF_COD_I
				WKLOG->DESC_I	:= Posicione("SB1",1,xFilial("SB1")+ZZF->ZZF_COD_I,"B1_DESC")
				WKLOG->MOTIVO	:= ZZF->ZZF_MOTIVO
			WKLOG->(MSUnlock())

		EndIf

		ZZF->(dbSkip())

	EndDo

	dbSelectArea(nArea)

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function CMVEIC0103()
	Local oDlg3
	Local cTit       := "Relatório de Erros"
	Local nCo1       := 1
	Local nCo2       := 5
	Local nCo3       := 20
	Local nCo4       := 24
	Local nCo5       := 40
	Local nCo6       := 44
	Local lConfirma3 := .F.

	Private cArqLog  := ""
	Private cWork2	 := "WKLOG"
	Private cStatus  := "Todas"
	Private cFornec	 := Space(06)
	Private cLoja    := SpacE(02)
	Private cInvoice := Space(15)
	Private dDtIni   := CTOD("  /  /  ")
	Private dDtFim   := CTOD("  /  /  ")
	Private lRejeic  := .T.
	Private lSucess  := .T.
	Private lMensag  := .T.
	Private lAjust   := .T.
	Private aHeader  := {}
	Private aStrut2	 := {}
	Private aRotina  := { { "Pesquisar"   ,"AxPesqui"   ,0,1},;
						  { "Visualizar"  ,"AxVisual"   ,0,2},;
						  { "Incluir"     ,"u_SVMANZC2" ,0,3},;
						  { "Alterar"     ,"u_SVMANZC2" ,0,4},;
						  { "Excluir"     ,"AxDeleta"   ,0,5}}
	
	If Select("ZZE") == 0
		dbSelectArea("ZZE")
		dbSelectArea("ZZF")
		ZZE->(dbSetOrder(0))
		ZZE->(dbGoBottom())

		While !ZZE->(BOF()).AND. ZZE->ZZE_FILIAL != xFilial("ZZE")
			ZZE->(dbSkip(-1))
		EndDo

		If !ZZE->(EOF())
			cFornec := ZZE->ZZE_FORN
			cLoja	:= ZZE->ZZE_LOJA
			cInvoic := ZZE->ZZE_INVOIC
		EndIf

		ZZE->(dbSetOrder(1))

	EndIf

	Define MSDialog oDlg3 Title cTit From 0,0 TO 10,100 Of oMainWnd
		@ 0.2 ,nCo1 Say "Invoice:"            Of oDlg3
		@ 0.2 ,nCo2 Msget cInvoice F3 "ZZE"   Of oDlg3
		@ 0.2 ,nCo3 Say "Data Inicial:"       Of oDlg3
		@ 0.2 ,nCo4 MsGet dDtIni              Of oDlg3
		@ 0.2 ,nCo5 Say "Data Final:"         Of oDlg3
		@ 0.2 ,nCo6 MsGet dDtFim              Of oDlg3
		@ 1.4 ,nCo1 Say "Fornecedor:"         Of oDlg3
		@ 1.4 ,nCo2 MsGet cFornec F3 "SA2"    Of oDlg3
		@ 1.4 ,nCo3 Say "Loja:"               Of oDlg3
		@ 1.4 ,nCo4 MsGet cLoja               Of oDlg3
		@ 1.4 ,nCo5 Say "Status:" Of SIZE 4,2 Of oDlg3
		@ 1.4 ,nCo6 Combobox cStatus ITEMS {"Todas","Rejeitadas","Integradas"} When .T. SIZE 80,12 Of oDlg3
		@ 35  ,  10 Say "Itens:" Pixel Of oDlg3

		@ 35 ,  40 CHECKBOX lRejeic PROMPT "Rejeitados" Size 60,5 OF oDlg3
		@ 35 , 100 CHECKBOX lSucess PROMPT "Aceitos"    Size 60,5 OF oDlg3
		@ 35 , 160 CHECKBOX lMensag PROMPT "Mensagens"  Size 60,5 OF oDlg3
		@ 35 , 220 CHECKBOX lAjust  PROMPT "Ajustes"    Size 60,5 OF oDlg3
		
		@ 50 , 10 BUTTON "Imprimir" SIZE 40,12 ACTION (lConfirma3 := .T.,oDlg3:End()) Pixel OF oDlg3
		@ 50 , 60 BUTTON "Sair" SIZE 40,12 ACTION (lConfirma3 := .F.,oDlg3:End()) Pixel OF oDlg3

	Activate MSDialog oDlg3 Centered

	If lConfirma3
		Processa( {|| GeraRelatorio()},"Gerando Relatório de Integração...",OemToAnsi("Gerando Relatório..."),.F.)
	EndIf

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function GeraRelatorio()
	Local cQuery  := ""
	Local aAux    := {}
	Local aHead   := {}
	Local cTitulo := "Relatório de Integrações de Invoices"
	Local i
	Local oExcel
	Local oExcel2
	Local lInvSel  := .F.
	Local cNome    := criatrab(,.F.)+".xml"
	Local cPath    := AllTrim(GetTempPath())

	cQuery += " SELECT * " + CRLF
	cQuery += " FROM " + RetSqlName("ZZF") + " ZZF " + CRLF
	cQuery += " INNER JOIN " + RetSqlName("ZZE") + " ZZE ON ZZE.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += " AND ZZF_FILIAL = ZZE_FILIAL "  + CRLF
	cQuery += " AND ZZF_INVOIC = ZZE_INVOIC " + CRLF
	cQuery += " AND ZZF_FORN = ZZE_FORN " + CRLF
	cQuery += " AND ZZF_LOJA = ZZE_LOJA " + CRLF
	cQuery += " AND ZZF_NRINTE = ZZE_NRINTE " + CRLF
	cQuery += " WHERE ZZF.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += " AND ZZF_FILIAL = '" + xFilial("ZZF") + "' " + CRLF
	cQuery += " AND ZZE.ZZE_NRINTE = " + CRLF
	cQuery += " ( " + CRLF
	cQuery += 	" SELECT MAX(ZZE_NRINTE) " + CRLF
	cQuery += 	" FROM "+ RetSqlName("ZZE") + " " + CRLF
	cQuery += 	" WHERE D_E_L_E_T_ <> '*' " + CRLF
	cQuery += 		" AND ZZE_FILIAL = '" + xFilial("ZZE") +"' " + CRLF
	cQuery += 		" AND ZZE_INVOIC = '" + AllTrim(cInvoice) + "' " + CRLF
	cQuery += " ) " + CRLF
	cQuery += MontaWhere()
	cQuery += " ORDER BY ZZF_INVOIC, ZZF_PO_NUM, ZZF_COD_I, ZZF_STATUS" + CRLF

	//MemoWrite("C:\TEMP\"+FunName()+".SQL",cQuery)
	cQuery := ChangeQuery(cQuery)

	TCQUERY cQuery NEW ALIAS "TMP1"

	If TMP1->(EOF())
		TMP1->(dbCloseArea())
		MsgStop("Dados não encontrados!")
		Return

	EndIf

	oExcel := FWMSEXCEL():New()
	oExcel:AddworkSheet(cTitulo)
	oExcel:AddTable (cTitulo,cTitulo)

	If Empty(cInvoice)
		aHead  := { "Invoice","Status Invoice","Status Item","Pedido","Posição","Cod. Item","Descrição Item","Motivo"}
	Else
		aHead  := { "Status Item","Pedido","Posição","Cod. Item","Descrição Item","Motivo"}
		lInvSel := .T.
	EndIf

	For i:= 1 To Len(aHead)
		oExcel:AddColumn(cTitulo,cTitulo,"",1, 1, .F.)
	Next

	//Cabeçalho
	aAux := {}
	AADD(aAux,"Invoices integradas no período de " + DTOC(dDtIni) + " até " + DTOC(dDtFim) )

	For i:=2 to Len(aHead)
		AADD(aAux,"")
	Next

	oExcel:AddRow(cTitulo,cTitulo, aAux)

	If !Empty(cInvoice) .OR. !Empty(cFornec)

		aAux := {}
		AADD(aAux,"Invoice: " + AllTrim(cInvoice) + " Fornecedor " + AllTrim(cFornec)  )

		For i:=2 to Len(aHead)
			AADD(aAux,"")
		Next

		oExcel:AddRow(cTitulo,cTitulo, aAux)

	EndIf

	aAux := {}

	If !Empty(cInvoice)
		AADD(aAux,"Status: " + IIF(TMP1->ZZE_STATUS == "R", "Rejeitada","Integrada"))
	Else
		AADD(aAux,"Status: " + cStatus)
	EndIf

	For i:=2 to Len(aHead)
		AADD(aAux,"")
	Next

	oExcel:AddRow(cTitulo,cTitulo, aAux)
	aAux := {}
	AADD(aAux,"Data: " + DTOC(dDataBase))

	For i:=2 to Len(aHead)
		AADD(aAux,"")
	Next

	oExcel:AddRow(cTitulo,cTitulo, aAux)
	aAux := {}

	For i:=1 to Len(aHead)
		AADD(aAux,"")
	Next

	oExcel:AddRow(cTitulo,cTitulo, aAux)
	//titulos das colunas
	oExcel:AddRow(cTitulo,cTitulo, aHead)

	While !TMP1->(EOF())
		aAux := {}

		If !lInvSel
			AADD(aAux, TMP1->ZZF_INVOIC)
			AADD(aAux, IIF(TMP1->ZZE_STATUS == "R", "Rejeitada","Integrada"))
		EndIf

		AADD(aAux, TMP1->ZZF_STATUS)
		AADD(aAux, TMP1->ZZF_PO_NUM)
		AADD(aAux, TMP1->ZZF_POSICA)
		AADD(aAux, TMP1->ZZF_COD_I )
		AADD(aAux, Posicione("SB1",1,xFilial("SB1")+TMP1->ZZF_COD_I,"B1_DESC"))
		AADD(aAux, TMP1->ZZF_MOTIVO)
		oExcel:AddRow(cTitulo,cTitulo, aAux)
		TMP1->(dbSkip())

	End

	oExcel:Activate()
	oExcel:GetXMLFile(cPath+cNome)
	MsgInfo("Arquivo Gerado Com Sucesso, para ver os detalhes clique no botão de Log !")

	If !ApOleClient("MSExcel")
		MsgAlert("Microsoft Excel não instalado!")
		MsgAlert("O Relatório se encontra na pasta:"+Chr(13)+Chr(10)+cPath+cNome)
		TMP1->(dbCloseArea())
		Return
	EndIf

	//Abre o Excel
	oExcel2:= MsExcel():New()
	oExcel2:WorkBooks:Open(cPath+cNome)
	oExcel2:SetVisible(.T.)
	oExcel2:Destroy()

	TMP1->(dbCloseArea())

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function MontaWhere()
	Local cWhere  := ""
	Local cStsIts := " AND ZZF_STATUS IN ("

	cWhere += " AND ZZF_INVOIC = '" + AllTrim(cInvoice) + "' "

	If Empty(cInvoice)

		If !Empty(DTOS(dDtIni))
			cWhere += " AND ZZE_DTINTE >= '" + DTOS(dDtIni) + "' "
		EndIf

		If !Empty(DTOS(dDtFim))
			cWhere += " AND ZZE_DTINTE <= '" + DTOS(dDtFim) + "' "
		EndIf

		If !Empty(cFornec)
			cWhere += " AND ZZF_FORN = '" + AllTrim(cFornec) + "' "
		EndIf

		If !Empty(cLoja)
			cWhere += " AND ZZF_LOJA = '" + AllTrim(cLoja) + "' "
		EndIf

	EndIf

	If lRejeic
		cStsIts += "'R',"
	EndIf

	If lSucess
		cStsIts += "'S',"
	EndIf

	If lMensag
		cStsIts += "'M',"
	EndIf

	If lAjust
		cStsIts += "'A',"
	EndIf

	cStsIts := Substr(cStsIts,1, Len(cStsIts) -1)
	cWhere += cStsIts + ") "
	
	If Upper(cStatus) == "REJEITADAS"
		cWhere += " AND ZZE_STATUS = 'R' "
	Elseif Upper(cStatus) == "INTEGRADAS"
		cWhere += " AND ZZE_STATUS = 'I' "
	EndIf

Return cWhere

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

User Function CMVEI01B

	Local cArqTrb
	Local abkRotina   := aRotina
	Local cbkCadastro := cCadastro
	
	Private oBrowse
	Private cCadastro  := 'Caixas da Invoice : '+Alltrim(EW4->EW4_INVOIC)
	Private aRotina    := {}
	Private aCampos	   := {}
	Private aSeek      := {}
	Private aDados     := {}
	Private aValores   := {}
	Private aFieFilter := {}

	AADD(aRotina, {"Visualizar" , "U_CMVEI01C"  , 0, 2, 0, .T. })

	//Array contendo os campos da tabela temporária
	AAdd(aCampos,{"TR_FILIAL","C" ,TamSx3('EW5_FILIAL')[01], 0})
	AAdd(aCampos,{"TR_PO"  	 ,"C" ,TamSx3('EW5_PO_NUM')[01], 0})
	AAdd(aCampos,{"TR_POS" 	 ,"C" ,TamSx3('EW5_POSICA')[01], 0})
	//AAdd(aCampos,{"TR_SI"   ,"C" ,TamSx3('EW5_SI_NUM')[01], 0})
	AAdd(aCampos,{"TR_COD"   ,"C" ,TamSx3('EW5_COD_I ')[01], 0})
	AAdd(aCampos,{"TR_QTD"   ,"N" ,11, 3})
	AAdd(aCampos,{"TR_LOTE"  ,"C" ,TamSx3('ZD_LOTE')[01], 0})
	AAdd(aCampos,{"TR_CAIXA" ,"C" ,TamSx3('ZD_CAIXA')[01], 0})
	AAdd(aCampos,{"TR_QTDE"  ,"N" ,11, 3})

	//Antes de criar a tabela, verificar se a mesma já foi aberta
	If (Select("TRB") <> 0)
		dbSelectArea("TRB")
		TRB->(dbCloseArea ())
	EndIf

	//Criar tabela temporária
	cArqTrb   := CriaTrab(aCampos,.T.)

	//Criar e abrir a tabela
	dbUseArea(.T.,,cArqTrb,"TRB",Nil,.F.)

	SZD->(dbSetOrder(1))
	EW5->(dbSetOrder(1))
	EW5->(dbSeek(EW4->EW4_FILIAL+EW4->EW4_INVOIC))

	While !EW5->(Eof()) .And. EW4->EW4_FILIAL  ==  EW5->EW5_FILIAL .AND. EW4->EW4_INVOIC == EW5->EW5_INVOIC
		SZD->(dbSeek(EW5->EW5_FILIAL+EW5->(EW5_INVOIC+EW5_CC+EW5_SI_NUM+EW5_PO_NUM+EW5_POSICA+EW5_COD_I)))

		While !SZD->(Eof()) .And. SZD->ZD_FILIAL  ==  EW5->EW5_FILIAL .AND.;
				Alltrim(SZD->ZD_CHAVE) == Alltrim(EW5->(EW5_INVOIC+EW5_CC+EW5_SI_NUM+EW5_PO_NUM+EW5_POSICA+EW5_COD_I))

			RecLock('TRB',.T.)
				TRB->TR_FILIAL := EW5->EW5_FILIAL
				TRB->TR_PO     := EW5->EW5_PO_NUM
				TRB->TR_POS    := EW5->EW5_POSICA
				TRB->TR_COD    := EW5->EW5_COD_I
				TRB->TR_QTD    := EW5->EW5_QTDE
				TRB->TR_LOTE   := SZD->ZD_LOTE
				TRB->TR_CAIXA  := SZD->ZD_CAIXA
				TRB->TR_QTDE   := SZD->ZD_QTDE
			TRB->(MsUnLock())

			SZD->(dbSkip())
		End
		EW5->(dbSkip())
	End
	dbSelectArea("TRB")

	TRB->(DbGoTop())

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( "TRB" )
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetTemporary(.T.)
	oBrowse:SetUseFilter(.F.)
	oBrowse:SetFilterDefault( "" )
	oBrowse:DisableDetails()

	oBrowse:SetColumns(MontaColunas("TR_PO"   ,"No. do P.O."  ,01,"@!",0,015,0))
	oBrowse:SetColumns(MontaColunas("TR_POS"  ,"Posicao     " ,02,"@!",1,010,0))
	oBrowse:SetColumns(MontaColunas("TR_COD"  ,"Codigo Item " ,04,"@!",1,020,0))
	oBrowse:SetColumns(MontaColunas("TR_QTD"  ,"Qtde        " ,05,"@E 99999999.999",1,010,0))
	oBrowse:SetColumns(MontaColunas("TR_LOTE" ,"Lote"	      ,06,"",1,010,0))
	oBrowse:SetColumns(MontaColunas("TR_CAIXA","Caixa"        ,07,"@!",1,010,0))
	oBrowse:SetColumns(MontaColunas("TR_QTDE" ,"Qtd Caixas"	  ,08,"@E 99999999.999",2,10,0))
	oBrowse:Activate()

	If !Empty(cArqTrb)
		Ferase(cArqTrb+GetDBExtension())
		Ferase(cArqTrb+OrdBagExt())
		cArqTrb := ""
		TRB->(DbCloseArea())
		delTabTmp('TRB')
		dbClearAll()
	EndIf

	aRotina   := abkRotina
	cCadastro := cbkCadastro

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColumn
	Local bData 	 := {||}
	Default nAlign 	 := 1
	Default nSize 	 := 20
	Default nDecimal := 0
	Default nArrData := 0

	If nArrData > 0
		bData := &("{||" + cCampo +"}")
	EndIf

	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return {aColumn}

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

User Function CMVEI01C

	Private nOpcx     := 2
	Private cAlias    := 'TRB'
	Private nReg      := TRB->(Recno())
	Private bkaRot    := aRotina
	Private aRotina   := {{"","", 0 , 3},{"","", 0 , 3}}

	AxVisual(cAlias,nReg,nOpcx)

	aRotina := bkaRot

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function QtdEW5(cPO,cProduto,cSI,cPosicao)

	Local cQ        := ""
	Local aArea     := {GetArea()}
	Local cAliasTrb := GetNextAlias()
	Local nRet      := 0

	cQ := " SELECT SUM(EW5_QTDE) EW5_QTDE "
	cQ += " FROM "+retSQLName("EW5")+" EW5 "
	cQ += " WHERE "
	cQ += " EW5_FILIAL = '"+xFilial("EW5")+"' "
	cQ += " AND EW5_PO_NUM = '"+cPO+"' "
	cQ += " AND EW5_COD_I = '"+cProduto+"' "
	cQ += " AND EW5_SI_NUM = '"+cSI+"' "
	cQ += " AND EW5_POSICA = '"+cPosicao+"' "
	cQ += " AND EW5.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)

	While (cAliasTrb)->(!Eof())
		nRet := (cAliasTrb)->EW5_QTDE
		Exit
	Enddo

	(cAliasTrb)->(dbCloseArea())

	aEval(aArea,{|x| RestArea(x)})

Return(nRet)

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CMVEI01D
Exemplo de programa MVC sem uso de dicionario de dados
@author Juliane Venteu
@since 04/04/2017
/*/
//----------------------------------------------------------------------------------

User Function CMVEI01D

	Local aCampos	:= {}

	//Array contendo os campos da tabela temporária
	AAdd(aCampos,{"TR_FILIAL","C" ,TamSx3('EW5_FILIAL')[01], 0})
	AAdd(aCampos,{"TR_PO"  	 ,"C" ,TamSx3('EW5_PO_NUM')[01], 0})
	AAdd(aCampos,{"TR_POS" 	 ,"C" ,TamSx3('EW5_POSICA')[01], 0})
	AAdd(aCampos,{"TR_COD"   ,"C" ,TamSx3('EW5_COD_I ')[01], 0})
	AAdd(aCampos,{"TR_QTD"   ,"N" ,11, 3})
	AAdd(aCampos,{"TR_LOTE"  ,"C" ,TamSx3('ZD_LOTE')[01], 0})
	AAdd(aCampos,{"TR_CAIXA" ,"C" ,TamSx3('ZD_CAIXA')[01], 0})
	AAdd(aCampos,{"TR_QTDE"  ,"N" ,11, 3})

	//Antes de criar a tabela, verificar se a mesma já foi aberta
	If (Select("TRB") <> 0)
		dbSelectArea("TRB")
		TRB->(dbCloseArea ())
	EndIf

	//Criar tabela temporária
	cArqTrb   := CriaTrab(aCampos,.T.)

	//Criar e abrir a tabela
	dbUseArea(.T.,,cArqTrb,"TRB",Nil,.F.)

	SZD->(dbSetOrder(1))
	EW5->(dbSetOrder(1))
	EW5->(dbSeek(EW4->EW4_FILIAL+EW4->EW4_INVOIC))
	
	While !EW5->(Eof()) .And. EW4->EW4_FILIAL  ==  EW5->EW5_FILIAL .AND. EW4->EW4_INVOIC == EW5->EW5_INVOIC
		SZD->(dbSeek(EW5->EW5_FILIAL+EW5->(EW5_INVOIC+EW5_CC+EW5_SI_NUM+EW5_PO_NUM+EW5_POSICA+EW5_COD_I)))
	
		While !SZD->(Eof()) .And. SZD->ZD_FILIAL  ==  EW5->EW5_FILIAL .AND.;
			Alltrim(SZD->ZD_CHAVE)   ==  Alltrim(EW5->(EW5_INVOIC+EW5_CC+EW5_SI_NUM+EW5_PO_NUM+EW5_POSICA+EW5_COD_I))

			RecLock('TRB',.T.)
				TRB->TR_FILIAL := EW5->EW5_FILIAL
				TRB->TR_PO     := EW5->EW5_PO_NUM
				TRB->TR_POS    := EW5->EW5_POSICA
				TRB->TR_COD    := EW5->EW5_COD_I
				TRB->TR_QTD    := EW5->EW5_QTDE
				TRB->TR_LOTE   := SZD->ZD_LOTE
				TRB->TR_CAIXA  := SZD->ZD_CAIXA
				TRB->TR_QTDE   := SZD->ZD_QTDE
			TRB->(MsUnLock())

			SZD->(dbSkip())
		End
		EW5->(dbSkip())
	End

	dbSelectArea("TRB")

	TRB->(DbGoTop())

	FWExecView("Titulo","CMVEI01D",4,,{|| .T.})

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStr := getModelStruct()

	oModel := MPFormModel():New('MLDNOSXS',,,{|oModel| Commit(oModel) })
	oModel:SetDescription('Exemplo Modelo sem SXs')

	oModel:AddFields("MASTER",,oStr,,,{|| Load() })
	oModel:getModel("MASTER"):SetDescription("DADOS")
	oModel:SetPrimaryKey({})

Return oModel

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

static function getModelStruct()
	Local oStruct := FWFormModelStruct():New()

	oStruct:AddField('Arquivo Origem'    ,'Arquivo Origem'     , 'ARQ'  , 'C' , 50, 0,                             , , {}, .T., , .F., .F., .F., , )
	oStruct:AddField('Carregar'          ,'Carregar'           , 'LOAD' , 'BT',  1, 0, { |oMdl| getArq(oMdl), .T. }, , {}, .F., , .F., .F., .F., , )
	oStruct:AddField('Caminho de Destino','Caminho de Destino' , 'DEST' , 'C' , 50, 0,                             , , {}, .T., , .F., .F., .F., , )
	oStruct:AddField('Selecionar'        ,'Selecionar'         , 'LOAD2', 'BT',  1, 0, { |oMdl| getDir(oMdl), .T. }, , {}, .F., , .F., .F., .F., , )

return oStruct

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function ViewDef()
	Local oView
	Local oModel := ModelDef()
	Local oStr   := getViewStruct()
	
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('FORM1' , oStr,'MASTER' )
	oView:CreateHorizontalBox( 'BOXFORM1', 100)
	
	oView:SetOwnerView('FORM1','BOXFORM1')
	oView:SetViewProperty('FORM1' , 'SETLAYOUT' , {FF_LAYOUT_VERT_DESCR_TOP,3} )
	oView:EnableTitleView('FORM1' , 'Movimentação de Arquivo' )

Return oView

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

static function getViewStruct()
	Local oStruct := FWFormViewStruct():New()

	oStruct:AddField( 'ARQ'  ,'1','Arquivo Origem','Arquivo Origem',, 'Get' ,,,,.F.,,,,,,,, )
	oStruct:AddField( 'LOAD' ,'2','Carregar'      ,'Carregar'      ,, 'BT'  ,,,,   ,,,,,,,, )
	oStruct:AddField( 'DEST' ,'3','Destino'       ,'Destino'       ,, 'Get' ,,,,.F.,,,,,,,, )
	oStruct:AddField( 'LOAD2','4','Selecionar'    ,'Selecionar'    ,, 'BT'  ,,,,   ,,,,,,,, )

return oStruct

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function getArq(oField)
	Local cArq := cGetFile( '*.txt' , 'Textos (TXT)', 1, 'C:\', .T.,,.T., .T. )

	If !Empty(cArq)
		oField:SetValue("ARQ",cArq)
	EndIf

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function getDir(oField)
	Local cDir := cGetFile( '*' , 'Diretorio Destino', 1, 'C:\', .T.,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ) ,.T., .T. )

	If !Empty(cDir)
		oField:SetValue("DEST",cDir)
	EndIf

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function Commit(oModel)
	Local cFile
	Local cExt
	Local cDrive
	Local cDir
	Local cArq  := oModel:GetValue("MASTER", "ARQ")
	Local cDest := oModel:GetValue("MASTER", "DEST")
	Local nError
	Local lRet := .T.

	SplitPath( cArq, @cDrive, @cDir, @cFile, @cExt )
	nError := fRename(AllTrim(cArq), AllTrim(cDest) + AllTrim(cFile) + AllTrim(cExt))

	If nError > 0
		lRet := .F.
		Help( ,, 'Help',, 'Erro ao copiar arquivo. FError() = ' + cValToChar(fError()), 1, 0 )
	EndIf

Return lRet

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function Load()
	Local aLoad := {}
	aAdd(aLoad, {"C:\teste.txt","","D:\",""}) //dados
	aAdd(aLoad, 0) //recno

Return aLoad

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function zGrvArq()
	
	Local cErr	     := ""
	Local cZM_BL     := ""
	Local cZM_INVOIC := ""
	Local cZM_FORNEC := ""
	Local cZM_LOJA   := ""
	Local cZM_ITEM   := ""
	Local cZM_NAVIO  := ""
	Local cZM_DESCR  := ""
	Local cZM_UNIT   := ""
	Local nZM_QTDE   := ""
	Local cZM_CASE   := ""
	Local cZM_LOTE   := ""
	Local cZM_CONT   := ""
	Local oArq	     := FWFileReader():New(cDiretorio)
	Local nLn        := 0
	Local lLimpaAnt  := .F.
	Local aLn        := {}
	
	
	if (oArq:Open())

		while (oArq:hasLine())
			nLn ++
			aLn := Separa(oArq:GetLine(), ";")

			If Len(aLn) < 12
				cErr += Char(13) + Char(10) + " Linha " + Str(nLn) + " num de colunas:" + Str(Len(aLn))
				Loop
			EndIf

			If nLayOut == 1
	
				cZM_BL		:= Padr(aLn[3], TamSx3("ZM_BL")[1], " ")
				cZM_INVOIC	:= Padr(aLn[2], TamSx3("ZM_INVOICE")[1], " ")
				cZM_FORNEC	:= EW4->EW4_FORN
				cZM_LOJA	:= EW4->EW4_FORLOJ
				cZM_ITEM	:= Alltrim(Padl(aLn[4], TamSx3("ZM_ITEM")[1], "0"))
				cZM_DOC		:= Padr("", TAMSX3("ZM_DOC")[1], " ")
				cZM_SERIE	:= Padr("", TAMSX3("ZM_SERIE")[1], " ")
				cZM_NAVIO	:= Padr(aLn[8], TamSx3("ZM_NAVIO")[1], " ")
				cZM_CONT	:= Alltrim(aLn[09])
				cZM_LOTE	:= Alltrim(aLn[1])
				cZM_CASE	:= Alltrim(aLn[10])
				cZM_PROD	:= Alltrim(StrTran(AllTrim(aLn[05]), "-", ""))
				nZM_QTDE	:= Val(aLn[06])
				cZM_UNIT	:= Alltrim(aLn[12]) + Alltrim(aLn[10]) // alterado para Lote + case
				cZM_DESCR   := Posicione("SB1", 1, FwxFilial("SB1") + Alltrim(aLn[05]), "B1_DESC")
	
			Else
	
				cZM_BL		:= Padr(aLn[12], TamSx3("ZM_BL")[1], " ")
				cZM_INVOIC	:= Padr(aLn[2], TamSx3("ZM_INVOICE")[1], " ")
				cZM_FORNEC	:= EW4->EW4_FORN
				cZM_LOJA	:= EW4->EW4_FORLOJ
				cZM_ITEM	:= Alltrim(Padl(aLn[1], TamSx3("ZM_ITEM")[1], "0"))
				cZM_DOC		:= Padr("", TAMSX3("ZM_DOC")[1], " ")
				cZM_SERIE	:= Padr("", TAMSX3("ZM_SERIE")[1], " ")
				cZM_NAVIO	:= Padr(aLn[13], TamSx3("ZM_NAVIO")[1], " ")
				cZM_CONT	:= Alltrim(aLn[08])
				cZM_LOTE	:= ""
				cZM_CASE	:= Alltrim(aLn[09])
				cZM_PROD	:= AllTrim(aLn[05])
				nZM_QTDE	:= Val(aLn[06])
				cZM_UNIT	:= ""
				cZM_DESCR   := Posicione("SB1", 1, FwxFilial("SB1") + Alltrim(aLn[05]), "B1_DESC")
	
			EndIf

			aLn[06] := StrTran(aLn[6], ".", "" )

			If lLimpaAnt = .F.
				TcSqlExec("DELETE FROM " + RetSqlName("SZM") + " WHERE D_E_L_E_T_ = '*' AND ZM_INVOICE = '" + cZM_INVOIC + "' "   )
				TcSqlExec("UPDATE " + RetSqlName("SZM") + " SET D_E_L_E_T_ = '*' WHERE ZM_FILIAL = '" + FwXfilial("SZM") + "' AND ZM_INVOICE = '" + cZM_INVOIC + "' ")
				lLimpaAnt = .T.
			EndIf

			RecLock("SZM", .T.)
				SZM->ZM_FILIAL 	:= FwXfilial("SZM")
				SZM->ZM_INVOICE	:= Alltrim(cZM_INVOIC)
				SZM->ZM_NAVIO	:= Alltrim(cZM_NAVIO)
				SZM->ZM_BL		:= Alltrim(cZM_BL)
				SZM->ZM_CONT	:= cZM_CONT
				SZM->ZM_LOTE	:= cZM_LOTE
				SZM->ZM_CASE	:= cZM_CASE
				SZM->ZM_PROD	:= cZM_PROD
				SZM->ZM_QTDE	:= nZM_QTDE
				SZM->ZM_UNIT	:= zRetCarUni(cZM_UNIT)
				SZM->ZM_DOC		:= ""
				SZM->ZM_SERIE	:= ""
				SZM->ZM_FORNEC	:= EW4->EW4_FORN
				SZM->ZM_LOJA	:= EW4->EW4_FORLOJ
				SZM->ZM_ITEM	:= cZM_ITEM
				SZM->ZM_DESCR   := cZM_DESCR
			SZM->(MsUnlock())

		EndDo
		oArq:Close()
	EndIf

	If cErr <> ""
		ApMsgStop("Erros encontrados: " + cErr, "CMVEIC01")
	EndIf
Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static function zLayouts()
	Local cmd := ""
	Local cDivi := CRLF + "------------------------------------------------" + CRLF

	cmd += CRLF + "Layout 01: CKD (CSV)"
	cmd += CRLF + "	[01] LOTE"
	cmd += CRLF + "	[02] INVOICE"
	cmd += CRLF + "	[03] CONHECIMENTO EMBARQUE SW6"
	cmd += CRLF + "	[04] SEQ"
	cmd += CRLF + "	[05] CODIGO PRODUTO"
	cmd += CRLF + "	[06] QUANTIDADE"
	cmd += CRLF + "	[07] VALOR UNITARIO"
	cmd += CRLF + "	[08] NAVIO SW6"
	cmd += CRLF + "	[09] CONTAINER"
	cmd += CRLF + "	[10] CAIXAS"
	cmd += CRLF + "	[11] PO"
	cmd += CRLF + "	[12] unitizador " + cDivi

	cmd += CRLF + "Layout 02: CBU - Hyundai (TXT)"
	cmd += CRLF + "	1 A 5 - NRO PROFORMA"
	cmd += CRLF + "	46 A 52 - NOME DO NAVIO"
	cmd += CRLF + "	54 A 69 - NRO DA INVOICE"
	cmd += CRLF + "	70 A 82 - CODIGO DO MODELO (RETIRAR ESPACOS EM BRANCO)"
	cmd += CRLF + "	83 A 86 - CODIGO DO OPICIONAL"
	cmd += CRLF + "	87 A 89 - CODIGO DA COR EXTERNA"
	cmd += CRLF + "	90 A 92 - CODIGO DA COR INTERNA"
	cmd += CRLF + "	101 A 116 - NUMERDO DO BL"
	cmd += CRLF + "	128 A 144 - NUMERO DO CHASSI"
	cmd += CRLF + "	145 A 156 - NUMERO DO MOTOR"
	cmd += CRLF + "	160 A 164 - NUMERO DA CHAVE"
	cmd += CRLF + "	206 A 210 - ANO MODELO"
	cmd += CRLF + "	210 A 213 - ANO FABRICACAO"  + cDivi

	cmd += CRLF + "Layout 03: CBU - Subaru (CSV)""
	cmd += CRLF + "	[01] Case"
	cmd += CRLF + "	[02] Model"
	cmd += CRLF + "	[03] VIN-CODE (Chassi)"
	cmd += CRLF + "	[04] Engine / Motor"
	cmd += CRLF + "	[05] Cor Externa"
	cmd += CRLF + "	[06] Cor Interna"
	cmd += CRLF + "	[07] Opcional"
	cmd += CRLF + "	[08] BL"
	cmd += CRLF + "	[09] Valor Total"
	cmd += CRLF + "	[10] Invoice"
	cmd += CRLF + "	[11] Ano Fab"
	cmd += CRLF + "	[12] Ano Mod"  + cDivi

	cmd += CRLF + "Layout 04: CBU - Chery (CSV)""
	cmd += CRLF + "	[01] Case"
	cmd += CRLF + "	[02] Model"
	cmd += CRLF + "	[03] VIN-CODE (Chassi)"
	cmd += CRLF + "	[04] Engine / Motor"
	cmd += CRLF + "	[05] Cor Externa"
	cmd += CRLF + "	[06] Cor Interna"
	cmd += CRLF + "	[07] Opcional"
	cmd += CRLF + "	[08] BL"
	cmd += CRLF + "	[09] Valor Total"
	cmd += CRLF + "	[10] Invoice"
	cmd += CRLF + "	[11] Ano Fab"
	cmd += CRLF + "	[12] Ano Mod " + cDivi

	cmd += CRLF + "Layout 05:  Peças (CSV)"
	cmd += CRLF + "	[01] SEQUENCIA DO ITEM"
	cmd += CRLF + "	[02] NUMERO DA INVOICE"
	cmd += CRLF + "	[03] NCM"
	cmd += CRLF + "	[04] EX"
	cmd += CRLF + "	[05] CODIGO PRODUTO"
	cmd += CRLF + "	[06] QUANTIDADE"
	cmd += CRLF + "	[07] VALOR UNITÁRIO"
	cmd += CRLF + "	[08] CONTAINER"
	cmd += CRLF + "	[09] CAIXA"
	cmd += CRLF + "	[10] PESO LIQUIDO"
	cmd += CRLF + "	[11] NUMERO DA PURCHASE ORDER"
	cmd += CRLF + "	[12] CONHECIMENTO EMBARQUE"
	cmd += CRLF + "	[13] NAVIO " + cDivi

	EecView(cmd, "Layouts dos arquivos")


Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} fValTotal(nPosTot,nVal,lTipo)
	Função para validar a quantidade de cada item encontrada no arquivo com a 
	quantidade cadastrada no Protheus.

	@type  Static Function
	@author Reinaldo Rabelo
	@since 06/06/2022
	@version 1.0
/*/
//----------------------------------------------------------------------------------

Static Function fValTotal(nPosTot,nVal,lTipo)
Local nRet := 0
Local n    := 0 
Local y    := 1
Local aAux := {}

Default lTipo = .T.
	
	if nLayOut == 5
		if len(aQuantTot[nPosTot]) <> 6
			if lTipo 
				nRet := aQuantTot[nPosTot,4]
			EndIf	
		Else
			if lTipo
				y := 1
			else
				y := 2
			EndIf
			
			aAux := aClone(aQuantTot[nPosTot,6])
			nRet := 0
			
			For n := 1 to len(aAux)
				nRet += aAux[n,y]
				if nRet >= nVal
					aQuantTot[nPosTot,6,n,y] := iif(nRet > nVal , nRet-nVal , 0 )
					nRet := nVal
					Exit
				else
					aQuantTot[nPosTot,6,n,y] := 0
				EndIf
			Next n 

			aQuantTot[nPosTot,4] -= nRet

		EndIf
	else
		nRet := nVal
	EndIf

Return nRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CMV01ValAr()
	Função para validar a quantidade de cada item encontrada no arquivo com a 
	quantidade cadastrada no Protheus.

	@type  Static Function
	@author Reinaldo Rabelo
	@since 06/06/2022
	@version 1.0
/*/
//----------------------------------------------------------------------------------

Static Function CMV01ValAr()
  	Local cQuery	:= ""
	Local cPosicao  := ""
	Local cTmpAlias	:= GetNextAlias()
	Local nTotInv	:= 0
	Local nI        := 0
	Local nPosTot	As Numeric
	Local aBind     as array
  	
	aBind := {}

	WKEW5->(dbSetOrder(2))
	
	dbSelectAre('SW2')
	SW2->(dbSetOrder(1))
	
	dbSelectArea("EW4")
	dbSelectArea("EW5")
	
	For nI := 1 To Len(aInvoice)
		
		cInvoice  := SUBSTR(aInvoice[nI][01],1,TamSX3("EW4_INVOIC")[1])
		nTotInv	  := 0
		nTotalFOB := 0

		WKEW5->(dbSeek(cInvoice))
		cPosicao := ""

		While !WKEW5->(EOF()) .AND. WKEW5->EW5_INVOIC == cInvoice
			IF SW2->(dbSeek(xFilial("SW2")+WKEW5->EW5_PO_NUM))
			
				If nLayOut == 5 .And. FWCodEmp() == "2020"
					
					cQuery := " "
					cQuery += " SELECT SW3.W3_POSICAO ,W3_SEQ, SW3.W3_QTDE ,NVL(EW5_QTDE,0) AS QUANT, (SW3.W3_QTDE-NVL(EW5_QTDE,0) ) AS SALDO,W3_PRECO"+(Chr(13)+Chr(10))
					cQuery += " FROM " + RetSqlName("SW3") + " SW3 "		+(Chr(13)+Chr(10))
					cQuery += " LEFT  OUTER JOIN " + RetSqlName("EW5") + " EW5 "+(Chr(13)+Chr(10))
					cQuery += " 	ON	EW5.EW5_FILIAL	= ?          		" +(Chr(13)+Chr(10))
					cQuery += " 	AND	EW5.EW5_PO_NUM	= SW3.W3_PO_NUM		" +(Chr(13)+Chr(10))
					cQuery += " 	AND	EW5.EW5_SI_NUM	= SW3.W3_SI_NUM		" +(Chr(13)+Chr(10))
					cQuery += " 	AND	EW5.EW5_FORN	= SW3.W3_FORN		" +(Chr(13)+Chr(10))
					cQuery += " 	AND	EW5.EW5_FORLOJ	= SW3.W3_FORLOJ		" +(Chr(13)+Chr(10))
					cQuery += " 	AND	EW5.EW5_COD_I	= SW3.W3_COD_I		" +(Chr(13)+Chr(10))
					cQuery += " 	AND	EW5.EW5_POSICA	= SW3.W3_POSICAO	" +(Chr(13)+Chr(10))
					cQuery += " 	AND	EW5.EW5_INVOIC	= ?                 " +(Chr(13)+Chr(10))
					cQuery += " 	AND	EW5.D_E_L_E_T_	= ' '				" +(Chr(13)+Chr(10))
					cQuery += " 	AND	EW5.EW5_SEQ		= 0			        " +(Chr(13)+Chr(10))
					cQuery += " WHERE	SW3.W3_FILIAL	= ? 		        " +(Chr(13)+Chr(10))
					cQuery += " 	AND	SW3.W3_FORN		= ? 			    " +(Chr(13)+Chr(10))
					cQuery += " 	AND	SW3.W3_FORLOJ	= ? 				" +(Chr(13)+Chr(10))
					cQuery += " 	AND	SW3.W3_SI_NUM	= ? 			    " +(Chr(13)+Chr(10))
					cQuery += " 	AND	SW3.W3_PO_NUM	= ?                 " +(Chr(13)+Chr(10))
					cQuery += " 	AND SW3.W3_SEQ 		= 0					" +(Chr(13)+Chr(10))
					cQuery += " 	AND	SW3.D_E_L_E_T_	= ' ' 		        " +(Chr(13)+Chr(10))		
					cQuery += " 	AND	SW3.W3_COD_I    = ?                 " +(Chr(13)+Chr(10))		
					cQuery += " 	AND	SW3.W3_POSICAO  = ?                 " +(Chr(13)+Chr(10))		
					
					cQuery += " ORDER BY SW3.W3_POSICAO "
					
					If Select(cTmpAlias) <> 0 ; (cTmpAlias)->(DbCloseArea()) ; EndIf
	
					aBind :={}
	
					Aadd(aBind,xFilial("EW5")	)	
					Aadd(aBind,WKEW5->EW5_INVOIC)
					Aadd(aBind,xFilial("SW3")	)	
					Aadd(aBind,SW2->W2_FORN		)
					Aadd(aBind,SW2->W2_FORLOJ	)
					Aadd(aBind,WKEW5->EW5_SI_NUM)
					Aadd(aBind,WKEW5->EW5_PO_NUM)	
					Aadd(aBind,WKEW5->EW5_COD_I	)
					Aadd(aBind,WKEW5->EW5_POSICA)
						
					DbUseArea(.T., "TOPCONN", TCGenQry2(Nil, Nil, cQuery, aBind), cTmpAlias, .F., .T.)
						
					nPosTot := aScan(aQuantTot, { |x| Alltrim(x[1])+Alltrim(x[2])+alltrim(x[3]) ==  Alltrim(WKEW5->EW5_INVOIC)+Alltrim(WKEW5->EW5_PO_NUM)+Alltrim(WKEW5->EW5_COD_I) } )
	
					If (cTmpAlias)->(!Eof()) 
						if (cTmpAlias)->W3_POSICAO == cPosicao
							WKEW5->(dbSkip())
							Loop
						else
							cPosicao := (cTmpAlias)->W3_POSICAO
						EndIf
					EndIf
				EndIf
					
				nPosTot := aScan(aQuantTot, { |x| Alltrim(x[1])+Alltrim(x[2])+alltrim(x[3]) ==  Alltrim(WKEW5->EW5_INVOIC)+Alltrim(WKEW5->EW5_PO_NUM)+Alltrim(WKEW5->EW5_COD_I) } )

				if (cTmpAlias)->(!eof())
					QTDE:= fValTotal(nPosTot , (cTmpAlias)->W3_QTDE , .T.) 
				EndIf
					
				If nLayout == 5
					if zAtuNcmW3() = .T.
						CMVEIC0101("Atualizado NCM + ExNCM na W3",, WKEW5->EW5_COD_I, WKEW5->EW5_FORN, WKEW5->EW5_FORLOJ, "A", WKEW5->EW5_PO_NUM, WKEW5->EW5_POSICA, cInvoice)
					EndIf
				EndIf

			EndIf
			
			WKEW5->(dbSkip())
		EndDo
		
		lOk := .T.
		
		if !lOk
			MsgAlert("Existe inconsistencia de valores verifique o Logs", "Atenção")
		EndIf
	Next
	
Return lOk

/*
=====================================================================================
Programa.:              zRetCarUni
Autor....:              CAOA - Sandro Ferreira
Data.....:              04/03/2022
Descricao / Objetivo:   Função para remoção de caracteres especiais do unitizador, 
os caracteres removidos são baseados nos criterios da função padrão WmsVlStr 
=====================================================================================
*/
Static Function zRetCarUni(cConteudo)
	Local cCarEsp		:= "!@#$%¨&()+{}^~´`][;.>,<=/¢¬§ªº'?|"+'"'
	Local nI			:= 0

	//Retirando caracteres
	For nI := 1 To Len(cCarEsp)
		cConteudo := StrTran(cConteudo, SubStr(cCarEsp, nI, 1), "")
	Next nI

Return cConteudo
