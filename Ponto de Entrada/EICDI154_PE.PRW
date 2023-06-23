#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*
=====================================================================================
Programa.:              EICDI154
Autor....:              Rafael Garcia
Data.....:              07/02/2019
Descricao / Objetivo:   PE para quebra de nota.
Doc. Origem:            EIC010
Solicitante:            CAOA
Uso......:              EIC010 - Quebra NF CHASSI-CONTAINER
Obs......:				Quebra nota por Container ou chassi
=====================================================================================
*/

user function EICDI154
	Local lRet 	:= .T.

	Local aArea	:= GetArea()
	Local aAreaSWV	:= SWV->(GetArea())
	Local aAreaSD1	:= SD1->(GetArea())
	Local aAreaSW8	:= SW8->(GetArea())
	Local aAreaZZ8  := ZZ8->(GetArea())

	Local cParam 	:= IIF(Type("PARAMIXB") == "A", Upper(PARAMIXB[1]), IIF(Type("PARAMIXB") == "C", Upper(PARAMIXB), ""))
	Local aDoc 	   := {}
	Local cErr     := ""
	Local cChave	:= ""
	Local _cEmp		:= FwCodEmp()
	Local nTamLote  := TAMSX3('W8_XLOTE')[1] +1
	Local nTamCase  := TAMSX3('W8_XCASE')[1]

	static lQuebra:=.f.
	Static aContainers
	Static cCONT := ""
	STATIC cVin	 := ""
	Static cQuebr:="N"

	Do Case

		Case cParam == "ESTORNO"

			If Vazio(SW6->W6_XDOCFIL) = .F. .AND. Findfunction("U_ZEICF016") = .T.
				aDoc := U_ZEICF016(SW6->W6_HAWB, "FILHA")
				If Len(aDoc) > 0
					Aeval(aDoc, {|x| cErr += Alltrim(x[2]) + "/" + Alltrim(x[1])  + CRLF  })
					FWAlertError("Consta geração de notas de container para esse processo: " + CRLF + cErr, "PE_EICDI154")
					lRet := .F.
				EndIf
			Endif

		Case cParam == "GRAVA_WN"

			SW8->(dbSetOrder(6))//W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM

			SWN->WN_XCONT := WORK1->WN_XCONT
			SWN->WN_XVIN  := WORK1->WN_XVIN
			SWN->WN_XLOTE := zRetEspUni( WORK1->WN_XLOTE )

			If SW8->(dbSeek(xFilial("SW8") + SW6->W6_HAWB + WORK1->WKINVOICE + SUBSTR(Work1->WKPO_NUM + SPACE(AVSX3("WN_PO_EIC",3)),1,AVSX3("WN_PO_EIC",3)) + Work1->WKPOSICAO + Work1->WKPGI_NUM) )
				cChave := SW8->W8_XCHAVE
			EndIf

			//SWV->(dbSetOrder(2))//WV_FILIAL+WV_HAWB+WV_INVOICE+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO
			SWV->(DbOrderNickName("CMVSWV01"))
			IF SWV->(dbSeek(xFilial("SWV") + SW6->W6_HAWB + WORK1->WKINVOICE + Work1->WKPGI_NUM + SUBSTR(Work1->WKPO_NUM + SPACE(AVSX3("WN_PO_EIC",3)),1,AVSX3("WN_PO_EIC",3)) + Work1->(WKPOSICAO+WKCOD_I+WK_LOTE)      ))

				//SWN->WN_XCONT  := SWV->WV_XCONT
				//SWN->WN_XVIN   := SWV->WV_XVIN
				SWN->WN_CORINT := SWV->WV_XCORIN
				SWN->WN_COREXT := SWV->WV_XCOREX
				SWN->WN_OPCION := SWV->WV_XOPC
				SWN->WN_ANOFAB := SWV->WV_XANOFB
				SWN->WN_ANOMOD := SWV->WV_XANOMD
				SWN->WN_XMOTOR := SWV->WV_XMOTOR
				SWN->WN_XCHAVE := cChave
				SWN->WN_XSERMO := SWV->WV_XSERMO
				//SWN->WN_XLOTE  := Alltrim(SWV->WV_LOTE)+SWV->WV_XCASE

			EndIf

		Case cParam == "GRAVA_SWN_EI2"
			nRecSD1 := SD1->(Recno())
			aOrd := SaveOrd("SD1")
			SD1->(DbSetOrder(1))
			If SD1->(dbSeek(xFilial("SD1")+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA+SWN->WN_PRODUTO+STRZERO(SWN->WN_LINHA,4)))
				nValUni := NOROUND(SD1->D1_TOTAL/SD1->D1_QUANT,5)
				nTotal  := noround(SD1->D1_QUANT * nValUni,2)
				If _cEmp == "2010" //Executa Anapolis.
					RECLOCK("SD1",.F.)
						SD1->D1_XCONT 	:= WORK1->WN_XCONT	
						SD1->D1_CHASSI	:= WORK1->WN_XVIN
						SD1->D1_CORINT	:= SWN->WN_CORINT
						SD1->D1_COREXT	:= SWN->WN_COREXT
						SD1->D1_OPCION	:= SWN->WN_OPCION
						SD1->D1_ANOFAB	:= RIGHT(SWN->WN_ANOFAB,2)
						SD1->D1_XANOFAB	:= SWN->WN_ANOFAB
						SD1->D1_ANOMOD	:= SWN->WN_ANOMOD
						SD1->D1_XCASE   := SUBSTR(SWN->WN_XLOTE,nTamLote,nTamCase)
					MSUNLOCK()
				Else
					RECLOCK("SD1",.F.)
						SD1->D1_VUNIT  := nValUni
						SD1->D1_TOTAL  := nTotal
						SD1->D1_XCONT  := WORK1->WN_XCONT	
						SD1->D1_CHASSI := WORK1->WN_XVIN
					MSUNLOCK()
				EndIf
			endif
			SD1->(dbGoTo(nRecSD1))
			RestOrd(aOrd)

		Case cParam == 'WORK_BROWSES'
			aAdd(TB_Campos2,{ "WN_XCONT" ,"",AvSx3("WN_XCONT", 5),AvSx3("WN_XCONT", 6) })
			aAdd(TB_Campos2,{ "WN_XVIN"  ,"",AvSx3("WN_XVIN" , 5),AvSx3("WN_XVIN" , 6) })
			aAdd(TB_Campos2,{ "WN_XLOTE" ,"",AvSx3("WN_XLOTE", 5),AvSx3("WN_XLOTE", 6) })

		Case cParam == "ADD_ESTRU_WORK1"
			AAdd( aDBF_Stru, {"WV_XCONT", "C", AvSx3("WV_XCONT", 3), 0} )
			AAdd( aDBF_Stru, {"WV_XVIN", "C", AvSx3("WV_XVIN", 3), 0} )

			AAdd( aDBF_Stru, {"WN_XCONT", "C", AvSx3("WN_XCONT", 3), 0} )
			AAdd( aDBF_Stru, {"WN_XVIN"	, "C", AvSx3("WN_XVIN" , 3), 0} )
			AAdd( aDBF_Stru, {"WN_XLOTE", "C", AvSx3("WN_XLOTE", 3), 0} )

		Case cParam == 'LER_SF1_SWN'
			WORK1->WN_XCONT := SWV->WV_XCONT
			WORK1->WN_XVIN  := SWV->WV_XVIN
			WORK1->WN_XLOTE := zRetEspUni( Alltrim(SWV->WV_LOTE)+Alltrim(SWV->WV_XCASE) )

		Case cParam == "GRV_WORK1"
			WORK1->WV_XCONT := SWV->WV_XCONT
			WORK1->WV_XVIN  := SWV->WV_XVIN

			WORK1->WN_XCONT := SWV->WV_XCONT
			WORK1->WN_XVIN  := SWV->WV_XVIN
			WORK1->WN_XLOTE := zRetEspUni( Alltrim(SWV->WV_LOTE)+Alltrim(SWV->WV_XCASE) )

		Case cParam == "PESONEW"

			RecLock("WORK1",.F.)
			WORK1->WN_XCONT := SW8->W8_XCONT
			WORK1->WN_XVIN  := SW8->W8_XVIN
			WORK1->WV_XCONT := SW8->W8_XCONT
			WORK1->WV_XVIN  := SW8->W8_XVIN
			WORK1->WN_XLOTE := zRetEspUni( SW8->(W8_XLOTE+W8_XCASE) )
			WORK1->(MsUnLock())

		Case cParam == "CRIA_INDICE"

			lQuebra:= .F.

			dbSelectArea("ZZ8")
			ZZ8->(dbSetOrder(1))//ZZ8_FILIAL+Z88_CODIGO

			If ZZ8->(dbSeek(xFilial("ZZ8") + SW6->W6_XTIPIMP ))
				If ZZ8->ZZ8_QBNF <> '4'
					lQuebra:= .T.
					cCpoind:= 	"WKFORN" + If(EICLoja(), "+WKLOJA", "") + "+WK_CFO+WKACMODAL+WK_OPERACA+WV_XCONT+WV_XVIN"
				EndIf
			EndIf

		Case cParam == "ALTERA_INDICE"
			if lQuebra
				Work1->(DBSETORDER(7))
			endif
		Case cParam == 'VALNFE'
			//if MsgYesNo("Deseja quebrar as nots por Chassi/Container?") Passou aqui primeiro
			cQuebr:="S"
			nWK1Ordem := 7
			//ENDIF
		Case cParam == 'QUEBRA_NF'
			cCONT := Work1->WV_XCONT
			cVin  := Work1->WV_XVIN

		Case cParam == "TEM_OUTRA_QUEBRA"
			if lQuebra
				lquebra_espe:= .t.
			endif
		Case cParam == "QUEBROU_NF"

			WORK1->(dbSetOrder(7))

			IF nItem >= GetMV("MV_NUMITEN") .OR.;
					cForn # Work1->WKFORN .OR.;
					nItem == 0 .OR.;
					cCFO # Work1->WK_CFO .OR.;
					(lIntDraw .AND. Work1->WKACMODAL # cACModal) .OR.;
					(lQuebraOperacao .AND. cOperacao # Work1->WK_OPERACA) .OR.;
					Work1->WV_XCONT # cCONT .OR.;
					Work1->WV_XVIN # cVin

				cCONT := Work1->WV_XCONT
				cVin  := Work1->WV_XVIN
				IF !EMPTY(CNUMERO)
					cNumero:= NxtSx5Nota(cSerie, .T., GetNewPar("MV_TPNRNFS","1"))
					WORK1->WK_NFE:=CNUMERO
					WORK1->WK_SE_NFE:=CSERIE
				endif
				lQuebrou_NF := .T.
			ELSE
				lQuebrou_NF := .F.
			ENDIF

		Case cParam == "ANTES_GRAVA_SD1"
			IF Type("aItens") == "A" .AND. Len(aItens) > 0
				SC7->(dbSetOrder(1))
				nPosPed   := AScan(aItens[1],{|x| x[1] == "D1_PEDIDO"})
				nPosItem  := AScan(aItens[1],{|x| x[1] == "D1_ITEMPC"})
				nPosLocal := AScan(aItens[1],{|x| x[1] == "D1_LOCAL"})
				If nPosPed <> 0 .AND.  nPosItem <> 0  .AND. nPosLocal <> 0
					If SC7->(DbSeek(xFilial('SC7')+aItens[01,nPosPed,2]+aItens[01,nPosItem,2]))
						IF Empty(SC7->C7_NUMSC)
							aItens[01,nPosPed,3] := GetAdvFVal( "SB1", "B1_LOCREC", xFilial('SB1')+SC7->C7_PRODUTO, 1, "" )
						EndIf
					EndIF
				EndIF
			EndIF

			IF  Type("aItem") <> "U" .AND. cQuebr=="S"
				nRecSD1 := SD1->(Recno())
				aOrd := SaveOrd("SD1")
				SD1->(DbSetOrder(1))
				lAchou := .F.
				lAchou := ValVeic()

				//*******************************************************************************************************************************************************************
				/*
				While !lAchou .AND. !SWN->(EOF()) .AND. SWN->WN_FILIAL == xFilial("SWN") .AND. SWN->WN_HAWB == SW6->W6_HAWB
					If SWN->WN_INVOICE == WORK1->WKINVOICE .AND. SWN->WN_PO_EIC == WORK1->WKPO_NUM .AND. SWN->WN_PGI_NUM == WORK1->WKPGI_NUM .AND. SWN->WN_ITEM == WORK1->WKPOSICAO;
					.AND. iif(lLote, AllTrim(SWN->WN_LOTECTL) == AllTrim(WORK1->WK_LOTE),.T.) .AND. (SWN->WN_TIPO_NF $ "1,3,5")
						If SD1->(dbSeek(xFilial("SD1")+SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA+SWN->WN_PRODUTO+STRZERO(SWN->WN_LINHA,4)))
							If SD1->D1_XCONT == Work1->WV_XCONT .OR. SD1->D1_CHASSI == Work1->WV_XVIN
								lAchou := .T.
							Endif
						Endif
					Endif
					lAchou := ValVeic()

					If !lAchou
						SWV->(dbSkip())
					Endif
				End
				*/

				SD1->(dbGoTo(nRecSD1))
				RestOrd(aOrd)
			Endif

		Otherwise

	End Case

	If cParam == "FINAL_GRAVA_NF" .And. ExistBlock("GRVDI154")
		ExecBlock("GRVDI154", .F., .F.)
	EndIf

	If cParam == "ANTES_ESTORNO_NOTA"
		xEstNFVei()
	EndIf

	RestArea(aAreaZZ8)
	RestArea(aAreaSW8)
	RestArea(aAreaSD1)
	RestArea(aAreaSWV)
	RestArea(aArea)

Return lRet

Static Function xEstNFVei()

	Local aArea 	:= GetArea()
	Local aAreaSWN	:= SWN->(GetArea())

	dbSelectArea("SWN")
	SWN->(dbSetOrder(3))//WN_FILIAL+WN_HAWB+WN_TIPO_NF

	If SWN->(dbSeek(SW6->(W6_FILIAL + W6_HAWB)))
		While SWN->(!Eof()) .and. SWN->(WN_FILIAL + WN_HAWB) == SW6->(W6_FILIAL + W6_HAWB)
			xExecVEI()
			SWN->(dbSkip())
		EndDo
	EndIf


	RestArea(aAreaSWN)
	RestArea(aArea)

Return

Static Function xExecVEI()

	Local aArea 	:= GetArea()
	Local aAreaSF1	:= SF1->(GetArea())
	Local aAreaVVF	:= VVF->(GetArea())

	Local xAutoCab := {} // Campos Cabecalho

	Local cBkpFunName := FunName()
	Local nBkpModulo  := nModulo

	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.

	dbSelectArea("SF1")
	dbSelectArea("VVF")

	SF1->(dbSetOrder(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	VVF->(dbSetOrder(6))//VVF_FILIAL+VVF_NUMNFI+VVF_SERNFI+VVF_CODFOR+VVF_LOJA

	If SF1->(dbSeek(SWN->(WN_FILIAL + WN_DOC + WN_SERIE + WN_FORNECE + WN_LOJA )))
		If VVF->(dbSeek(SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA )))

			SetFunName('VEIXA001')
			nModulo := 11

			aAdd(xAutoCab, { 'VVF_CODFOR' , SF1->F1_FORNECE , NIL } )
			aAdd(xAutoCab, { 'VVF_LOJA'   , SF1->F1_LOJA    , NIL } )
			aAdd(xAutoCab, { 'VVF_NUMNFI' , SF1->F1_DOC     , NIL } )
			aAdd(xAutoCab, { 'VVF_SERNFI' , SF1->F1_SERIE   , NIL } )

			MSExecAuto(;
				{ |a,b,c,d,e,f,g,h,i| ;
				VEIXX000(a       ,b         ,c      ,d   ,e      ,f       ,g         ,h          ,i      ) },;
				xAutoCab,{}        ,{}     ,5   ,"0"    ,        ,.f.       ,           ,       )

			SetFunName(cBkpFunName)
			nModulo := nBkpModulo

			If lMsErroAuto
				MostraErro()
			Else
				MsgInfo("Movimento cancelado com sucesso.")
			EndIf

		EndIf
	EndIF

	RestArea(aAreaVVF)
	RestArea(aAreaSF1)
	RestArea(aArea)

Return

/*
=====================================================================================
Programa.:              zRetEspUni
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              13/07/2021
Descricao / Objetivo:   Função para remoção de caracteres especiais do unitizador,
os caracteres removidos são baseados nos criterios da função padrão WmsVlStr
=====================================================================================
*/
Static Function zRetEspUni(cConteudo)
	Local cCarEsp		:= "!@#$%¨&*()+{}^~´`][;.>,<=/¢¬§ªº'?*|"+'"'
	Local nI			:= 0

	//Retirando caracteres
	For nI := 1 To Len(cCarEsp)
		cConteudo := StrTran(cConteudo, SubStr(cCarEsp, nI, 1), "")
	Next nI

Return cConteudo


/*
=====================================================================================
Programa.:              ValVeic
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              11/03/2022
Descricao / Objetivo:
=====================================================================================
*/
Static Function ValVeic()
	Local cAlias := Alias()
	Local lRet   := .T.
	Local aBind   := {}
	Static _cQry := ''

	If _cQry == Nil

		_cQry += "SELECT COUNT(SWN.WN_FILIAL) QUANT  "
		_cQry += "	FROM " + RetSqlName("SWN") + " SWN "
		_cQry += "	INNER JOIN "
		_cQry += "	     " + RetSqlName("SD1") + " SD1 ON  SD1.D1_FILIAL  =  ?"
		_cQry += "										AND SD1.D1_DOC     = SWN.WN_DOC "
		_cQry += "										AND SD1.D1_SERIE   = SWN.WN_SERIE "
		_cQry += "										AND SD1.D1_FORNECE = SWN.WN_FORNECE "
		_cQry += "										AND SD1.D1_LOJA    = SWN.WN_LOJA "
		_cQry += "										AND SD1.D1_COD     = SWN.WN_PRODUTO "
		_cQry += "										AND SD1.D1_ITEM    = SWN.WN_LINHA "
		_cQry += "										AND (SD1.D1_XCONT  = ?"
		_cQry += "										 OR  SD1.D1_CHASSI = ?"
		_cQry += "										AND SD1.D_E_L_E_T_ = ?"
		_cQry += "	WHERE   SWN.WN_FILIAL  = ?"
		_cQry += "		AND SWN.WN_TIPO_NF IN ('1','3','5') "
		_cQry += "		AND SWN.WN_INVOICE = ?"
		_cQry += "		AND SWN.WN_PO_EIC  = ?"
		_cQry += "		AND SWN.WN_PGI_NUM = ?"
		_cQry += "		AND SWN.WN_ITEM    = ?"
		_cQry += "		AND SWN->WN_HAWB   = ?"
		_cQry += "		AND SWN.D_E_L_E_T_ = ?"

		If lLote
			_cQry += "	AND Trim(SWN->WN_LOTECTL) = ?"
		ENDIF
	Endif

	Aadd(aBind,xFilial("SD1")  )
	Aadd(aBind,WORK1->WV_XCONT )
	Aadd(aBind,WORK1->WV_XVIN  )
	Aadd(aBind,Space(1)		   )
	Aadd(aBind,xFilial('SWN')  )
	Aadd(aBind,WORK1->WKINVOICE)
	Aadd(aBind,WORK1->WKPO_NUM )
	Aadd(aBind,WORK1->WKPGI_NUM)
	Aadd(aBind,WORK1->WKPOSICAO)
	Aadd(aBind,SW6->W6_HAWB    )
	Aadd(aBind,Space(1)        )
	If lLote
		Aadd(aBind,AllTrim(WORK1->WK_LOTE))
	ENDIF

	DbUseArea(.T., "TOPCONN", TCGenQry2(,, _cQry, aBind), 'QSWN', .F., .T.)
	lRet := QSWN->QUANT > 0
	QSWN->(DbCloseArea())
	aSize(aBind,0)
	aBind := Nil
	If !Empty(cAlias)
		dbSelectArea(cAlias)
	EndIf
	
Return lRet
