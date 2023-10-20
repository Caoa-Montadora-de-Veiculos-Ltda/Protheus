#Include "Protheus.Ch"

/*/{Protheus.doc} GRVPO400
Função para Atualizar os Dados Especificos de Importação da CAOA
@author FSW - DWC Consult
@since 20/03/2019
@version 1.0
@type function
/*/
User Function GRVPO400()
	Local cNumSI	:= ""
	Local cNumPGI	:= ""
	Local cTpImp	:= ""
	Local cCliImp	:= ""

	Local aAreaSW0	:= SW0->(GetArea())
	Local aAreaSW2	:= SW2->(GetArea())
	Local aAreaSW3	:= SW3->(GetArea())
	Local aAreaSW4	:= SW4->(GetArea())
	Local aAreaSW5	:= SW5->(GetArea())
	Local aAreaSC1	:= SC1->(GetArea())
	Local aAreaSC7	:= SC7->(GetArea())

	Local cChvSC7 := xFilial("SC7") + SW2->W2_FORN + SW2->W2_FORLOJ + SW2->W2_PO_SIGA

	SW0->(DbSetOrder(1)) //W0_FILIAL+W0__CC+W0__NUM
	SW3->(dbSetOrder(1)) //W3_FILIAL+W3_PO_NUM+W3_CC+W3_SI_NUM+W3_COD_I
	SW4->(DbSetOrder(1)) //W4_FILIAL+W4_PGI_NUM
	SW5->(DbSetOrder(8)) //W5_FILIAL+W5_PGI_NUM+W5_PO_NUM+W5_POSICAO
	SC1->(DbSetOrder(1)) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
	SC7->(dbSetOrder(3)) //C7_FILIAL+C7_FORNECE+C7_LOJA+C7_NUM
	EW5->(dbSetOrder(2)) //EW5_FILIAL+EW5_PO_NUM+EW5_POSICA+EW5_INVOIC+EW5_FORN+EW5_FORLOJ

	If SW3->(DbSeek(xFilial("SW3") + SW2->W2_PO_NUM))

		While !SW3->(Eof()) .And. xFilial("SW3") + SW3->W3_PO_NUM == SW2->(W2_FILIAL + W2_PO_NUM)

			//Descarta o SEQ <> 0, devido a não ter as informações do veiculo.
			If (SW3->W3_SEQ == 0 .and. SW3->W3_FLUXO == "7" ) .or. (SW3->W3_SEQ == 1 .and. SW3->W3_FLUXO == "1" )
				SW3->(DbSkip())
				Loop
			EndIf

			//----- SW2 - CAPA DA SOLICIAÇÃO DE IMPORTAÇÃO -----//
			//Atualiza 1X por numero de SI.						//
			If SW3->W3_SI_NUM != cNumSI
				SW0->(DbSeek(xFilial("SW0") + SW3->W3_CC + SW3->W3_SI_NUM ) )
				cTpImp := SW0->W0_TIPIMP
				cCliImp:= SW0->W0_XCLAIMP
				
				M->W2_XTIPIMP:= cTpImp
				M->W2_XCLAIMP := cCliImp
				
				if Empty(SW2->W2_XTIPIMP) .and. !Empty(cTpImp)
					RecLock("SW2",.F.)
						SW2->W2_XTIPIMP := cTpImp
						SW2->W2_XCLAIMP := cCliImp
					SW2->( MsUnlock() )
				EndIf

				cNumSI := SW3->W3_SI_NUM
			EndIf

			//----- SW4 CAPA DA LI e SW5 ITENS DA LI -----//
			//Atualiza caso o Produto NAO SEJA ANUENTE.	  //
			If SW3->W3_FLUXO == "7"
				//Atualiza a informação na Capa Preparação de Licença Imp. Atualiza 1X por numero de PGI.
				If Alltrim(SW3->W3_PGI_NUM) != Alltrim(cNumPGI)
					If SW4->(DbSeek(xFilial("SW4") + SW3->W3_PGI_NUM))
						RecLock("SW4",.F.)
						SW4->W4_XTIPIMP := cTpImp
						SW4->W4_XCLAIMP := cCliImp
						SW4->( MsUnlock() )
					EndIf
					cNumPGI := SW3->W3_PGI_NUM
				EndIf

				//Atualiza os campos dos Itens da PGI.
				If SW5->(DbSeek(xFilial("SW5") + SW3->(W3_PGI_NUM+W3_PO_NUM+W3_POSICAO)))
					RecLock("SW5",.F.)
					SW5->W5_CORINT := SW3->W3_CORINT
					SW5->W5_COREXT := SW3->W3_COREXT
					SW5->W5_OPCION := SW3->W3_OPCION
					SW5->W5_ANOFAB := SW3->W3_ANOFAB
					SW5->W5_ANOMOD := SW3->W3_ANOMOD
					SW5->W5_XVIN   := SW3->W3_XVIN
					SW5->( MsUnlock() )
				EndIf
			EndIf

			If SW3->W3_FLUXO == "1"

				If Alltrim(SW3->W3_PGI_NUM) != Alltrim(cNumPGI)
					If SW4->(DbSeek(xFilial("SW4") + SW3->W3_PGI_NUM))
						RecLock("SW4",.F.)
						SW4->W4_XTIPIMP := cTpImp
						SW4->W4_XCLAIMP := cCliImp
						SW4->( MsUnlock() )
					EndIf
					cNumPGI := SW3->W3_PGI_NUM
				EndIf

				//Atualiza os campos dos Itens da PGI.
				If SW5->(DbSeek(xFilial("SW5") + SW3->(W3_PGI_NUM+W3_PO_NUM+W3_POSICAO)))
					If EW5->(DbSeek(xFilial("EW5") + SW3->(W3_FILIAL+W3_PGI_NUM+W3_POSICAO)))
						RecLock("SW5",.F.)
						SW5->W5_CORINT := SW3->W3_CORINT
						SW5->W5_COREXT := SW3->W3_COREXT
						SW5->W5_OPCION := SW3->W3_OPCION
						SW5->W5_ANOFAB := SW3->W3_ANOFAB
						SW5->W5_ANOMOD := SW3->W3_ANOMOD
						SW5->W5_XVIN   := SW3->W3_XVIN
						SW5->W5_XLOTE  := EW5->EW5_XLOTE
						SW5->W5_XMOTOR := EW5->EW5_XMOTOR
						SW5->W5_XSERMO := EW5->EW5_XSERMO
						SW5->W5_XCHAVE := EW5->EW5_XCHAVE
						SW5->( MsUnlock() )
					EndIf
				EndIf
			EndIf


			SW3->(DbSkip())
		EndDo
	EndIf

	//------ SC7 - PEDIDO DE COMPRAS -----//
	//Atualiza as informações no PC.	  //


	If SC7->(Dbseek(cChvSC7))
		While SC7->(!Eof()) .And. SC7->(C7_FILIAL+C7_FORNECE+C7_LOJA+C7_NUM) == cChvSC7

			//Posiciona na Solicitacao de Compras para buscar campos customizados
			If SC1->(DbSeek(xFilial("SC1") + SC7->(C7_NUMSC+C7_ITEMSC)))
				Reclock("SC7",.F.)
				SC7->C7_TIPIMP := SC1->C1_XTPIMP
				SC7->C7_XCLAIMP:= SC1->C1_XCLAIMP
				SC7->C7_CORINT := SC1->C1_CORINT
				SC7->C7_COREXT := SC1->C1_COREXT
				SC7->C7_OPCION := SC1->C1_OPCION
				SC7->C7_ANOFAB := SC1->C1_ANOFAB
				SC7->C7_ANOMOD := SC1->C1_ANOMOD
				SC7->( MsUnlock() )
			EndIf

			SC7->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaSW0)
	RestArea(aAreaSW2)
	RestArea(aAreaSW3)
	RestArea(aAreaSW4)
	RestArea(aAreaSW5)
	RestArea(aAreaSC1)
	RestArea(aAreaSC7)
Return

User Function xGRVP400()

	Local cNumPGI	:= ""
	Local cTpImp	:= ""
	Local cCliImp	:= ""

	Local aArea		:= GetArea()
	Local aBind  	:= {}
	Local cQuery  As character

	Static _cQrySC7
	Static _cQrySW3

	//SW0 - Capa de Solicitação Importação
	//SW1 - Itens Solicitação Importação
	//SW2 - Capa de Purchase Order
	//SW3 - Itens de Purchase Order
	//SW4 - Capa Preparação de Licença Imp
	//SW5 - Itens Preparação Licença Imp

	IF _cQrySW3 == NIl
		_cQrySW3 := ""
		_cQrySW3 += " SELECT SW3.W3_CORINT													 ,	"
		_cQrySW3 += " 		 SW3.W3_COREXT													 ,	"
		_cQrySW3 += " 		 SW3.W3_OPCION													 ,	"
		_cQrySW3 += " 		 SW3.W3_ANOFAB													 ,	"
		_cQrySW3 += " 		 SW3.W3_ANOMOD													 ,	"
		_cQrySW3 += " 		 SW3.W3_XVIN													 ,	"
		_cQrySW3 += " 		 SW3.W3_PGI_NUM													 ,	"
		_cQrySW3 += " 		 NVL(SW0.W0_TIPIMP ,'"+Space(Len(SW0->W0_TIPIMP ))+"')	W0_TIPIMP,	"
		_cQrySW3 += " 		 NVL(SW0.W0_XCLAIMP,'"+Space(Len(SW0->W0_XCLAIMP))+"')	W0_XCLAIMP,	"
		_cQrySW3 += " 		 NVL(SW4.R_E_C_N_O_,0)									SW4RECNO  ,	"
		_cQrySW3 += " 		 NVL(SW5.R_E_C_N_O_,0)									SW5RECNO	"
		_cQrySW3 += " FROM "+RetSqlName("SW3")+" SW3											"
		_cQrySW3 += " LEFT JOIN 																"
		_cQrySW3 += " "+RetSqlName("SW0")+" SW0 ON 	? 				 = SW0.W0_FILIAL			"
		_cQrySW3 += "							AND SW3.W3_CC 	  	 = SW0.W0__CC				"
		_cQrySW3 += "							AND SW3.W3_SI_NUM	 = SW0.W0__NUM				"
		_cQrySW3 += "							AND ?				 = SW0.D_E_L_E_T_			"
		_cQrySW3 += " LEFT JOIN 																"
		_cQrySW3 += " "+RetSqlName("SW4")+" SW4 ON 	?				 = SW4.W4_FILIAL			"
		_cQrySW3 += "							AND	SW3.W3_PGI_NUM	 = SW4.W4_PGI_NUM			"
		_cQrySW3 += "							AND ?				 = SW4.D_E_L_E_T_			"
		_cQrySW3 += " LEFT JOIN 																"
		_cQrySW3 += " "+RetSqlName("SW5")+" SW5 ON 	? 				 = SW5.W5_FILIAL			"
		_cQrySW3 += "							AND	SW3.W3_PGI_NUM	 = SW5.W5_PGI_NUM			"
		_cQrySW3 += "							AND SW3.W3_PO_NUM 	 = SW5.W5_PO_NUM 			"
		_cQrySW3 += "							AND	SW3.W3_POSICAO	 = SW5.W5_POSICAO			"
		_cQrySW3 += "							AND ?				 = SW5.D_E_L_E_T_			"
		_cQrySW3 += " WHERE	SW3.W3_FILIAL		= ?												"
		_cQrySW3 += " 	AND	SW3.W3_PO_NUM		= ?												"
		//_cQrySW3 += " 	AND	SW3.W3_FLUXO 		= ?												"
		//_cQrySW3 += " 	AND SW3.W3_SEQ	 		= ?												"
		_cQrySW3 += "	AND SW3.D_E_L_E_T_		= ?												"
	EndIf

	aBind	:= {}
	Aadd(aBind,xFilial("SW0")	)
	Aadd(aBind,Space(01)		)
	Aadd(aBind,xFilial("SW4")	)
	Aadd(aBind,Space(01)		)
	Aadd(aBind,xFilial("SW5")	)
	Aadd(aBind,Space(01)		)
	Aadd(aBind,xFilial("SW3")	)
	Aadd(aBind,SW2->W2_PO_NUM	)
	//Aadd(aBind,'7'				)
	//Aadd(aBind,'1'				)
	Aadd(aBind,Space(01)		)

	DbUseArea(.T., "TOPCONN", TCGenQry2(,, _cQrySW3, aBind), 'QSW3', .F., .T.)
	If QSW3->(!Eof())
		cTpImp := SW0->W0_TIPIMP
		cCliImp:= SW0->W0_XCLAIMP
		
		M->W2_XTIPIMP:= cTpImp
		M->W2_XCLAIMP := cCliImp
		
		if Empty(SW2->W2_XTIPIMP) .and. !empty(cTpImp)
			SW2->(RecLock("SW2",.F.))
				SW2->W2_XTIPIMP := cTpImp
				SW2->W2_XCLAIMP := cCliImp
			SW2->(MsUnlock())
		EndIf

		While QSW3->(!Eof())

			If Alltrim(QSW3->W3_PGI_NUM) != Alltrim(cNumPGI) .And. QSW3->SW4RECNO > 0
				SW4->(DbGoto(QSW3->SW4RECNO))
				RecLock("SW4",.F.)
				SW4->W4_XTIPIMP := cTpImp
				SW4->W4_XCLAIMP := cCliImp
				SW4->( MsUnlock() )
				cNumPGI := QSW3->W3_PGI_NUM
			EndIf

			//Atualiza os campos dos Itens da PGI.
			If QSW3->SW5RECNO > 0
				SW5->(DbGoto(QSW3->SW5RECNO))
				RecLock("SW5",.F.)
				SW5->W5_CORINT := QSW3->W3_CORINT
				SW5->W5_COREXT := QSW3->W3_COREXT
				SW5->W5_OPCION := QSW3->W3_OPCION
				SW5->W5_ANOFAB := QSW3->W3_ANOFAB
				SW5->W5_ANOMOD := QSW3->W3_ANOMOD
				SW5->W5_XVIN   := QSW3->W3_XVIN
				SW5->( MsUnlock() )
			EndIf

			QSW3->(DbSkip())
		End
	EndIf
	QSW3->(DbCloseArea())

	//------ SC7 - PEDIDO DE COMPRAS -----//
	//Atualiza as informações no PC.	  //

	If _cQrySC7 == Nil
		_cQrySC7 := ""
		_cQrySC7 += " SELECT	SC1.C1_XTPIMP		,										"
		_cQrySC7 += " 			SC1.C1_XCLAIMP		,										"
		_cQrySC7 += " 			SC1.C1_CORINT		,										"
		_cQrySC7 += " 			SC1.C1_COREXT		,										"
		_cQrySC7 += " 			SC1.C1_OPCION		,										"
		_cQrySC7 += " 			SC1.C1_ANOFAB		,										"
		_cQrySC7 += " 			SC1.C1_ANOMOD		,										"
		_cQrySC7 += " 			SC7.R_E_C_N_O_	RECNO										"
		_cQrySC7 += " FROM "+RetSqlName("SC7") +" SC7 										"
		_cQrySC7 += " INNER JOIN															"
		_cQrySC7 += " 	 	"+RetSqlName("SC1")+" SC1 ON SC1.C1_FILIAL 	= ?					"
		_cQrySC7 += " 		 						 AND SC1.C1_NUM		= SC7.C7_NUMSC		"
		_cQrySC7 += " 								 AND SC1.C1_ITEM	= SC7.C7_ITEMSC		"
		_cQrySC7 += " 								 AND SC1.D_E_L_E_T_	= ?					"
		_cQrySC7 += " WHERE		SC7.C7_FILIAL 	= ?											"
		_cQrySC7 += " 		AND	SC7.C7_FORNECE	= ?											"
		_cQrySC7 += " 		AND	SC7.C7_LOJA		= ?											"
		_cQrySC7 += " 		AND SC7.C7_NUM 		= ?											"
		_cQrySC7 += " 		AND SC7.D_E_L_E_T_	= ?											"
	EndIf

	aBind := {}
	Aadd(aBind,xFilial("SC1")	)
	Aadd(aBind,Space(01)		)
	Aadd(aBind,xFilial("SC7")	)
	Aadd(aBind,SW2->W2_FORN		)
	Aadd(aBind,SW2->W2_FORLOJ	)
	Aadd(aBind,SW2->W2_PO_SIGA	)
	Aadd(aBind,Space(01)		)
	DbUseArea(.T., "TOPCONN", TCGenQry2(,, _cQrySC7, aBind), 'QSC7', .F., .T.)

	While QSC7->(!Eof())

		cQuery := ""
		cQuery += " UPDATE "+RetSqlName("SC7")
		cQuery += " 	SET	C7_TIPIMP 	= '"+QSC7->C1_XTPIMP	+"', "
		cQuery += " 		C7_XCLAIMP	= '"+QSC7->C1_XCLAIMP	+"', "
		cQuery += " 		C7_CORINT	= '"+QSC7->C1_CORINT	+"', "
		cQuery += " 		C7_COREXT	= '"+QSC7->C1_COREXT	+"', "
		cQuery += " 		C7_OPCION	= '"+QSC7->C1_OPCION	+"', "
		cQuery += " 		C7_ANOFAB	= '"+QSC7->C1_ANOFAB	+"', "
		cQuery += " 		C7_ANOMOD	= '"+QSC7->C1_ANOMOD	+"'  "
		cQuery += " WHERE R_E_C_N_O_ = "+cValToChar(QSC7->RECNO)
		If TCSqlExec(cQuery) != 0
			UserException(TcSqlError())
		EndIf
		QSC7->(DbSkip())
	EndDo
	QSC7->(DbCloseArea())

	RestArea(aArea)
	aSize(aBind,0)	
	aSize(aArea,0)	
	aBind 	:= Nil
	aArea	:= Nil

Return

User Function xGRVG400()

	//Local cNumSI	:= ""
	Local cNumPGI	:= ""
	Local cTpImp	:= ""
	Local cCliImp	:= ""

	Local aAreaSW0	:= SW0->(GetArea())
	Local aAreaSW2	:= SW2->(GetArea())
	Local aAreaSW3	:= SW3->(GetArea())
	Local aAreaSW4	:= SW4->(GetArea())
	Local aAreaSW5	:= SW5->(GetArea())
	Local aAreaSC1	:= SC1->(GetArea())
	Local aAreaSC7	:= SC7->(GetArea())

	Local cChvSC7 := xFilial("SC7") + SW2->W2_FORN + SW2->W2_FORLOJ + SW2->W2_PO_SIGA

	SW0->(DbSetOrder(1)) //W0_FILIAL+W0__CC+W0__NUM
	SW3->(dbSetOrder(1)) //W3_FILIAL+W3_PO_NUM+W3_CC+W3_SI_NUM+W3_COD_I
	SW4->(DbSetOrder(1)) //W4_FILIAL+W4_PGI_NUM
	SW5->(DbSetOrder(8)) //W5_FILIAL+W5_PGI_NUM+W5_PO_NUM+W5_POSICAO
	SC1->(DbSetOrder(1)) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
	EW5->(dbSetOrder(2)) //EW5_FILIAL+EW5_PO_NUM+EW5_POSICA+EW5_INVOIC+EW5_FORN+EW5_FORLOJ
	SC7->(dbSetOrder(3)) //C7_FILIAL+C7_FORNECE+C7_LOJA+C7_NUM

	If SW3->(DbSeek(xFilial("SW3") + SW2->W2_PO_NUM))
		//----- SW2 - CAPA DA SOLICIAÇÃO DE IMPORTAÇÃO -----//
		//Atualiza 1X por numero de SI.						//
		If SW0->(DbSeek(xFilial("SW0") + SW3->W3_CC + SW3->W3_SI_NUM ) )
			cTpImp := SW0->W0_TIPIMP
			cCliImp:= SW0->W0_XCLAIMP
			
			M->W2_XTIPIMP:= cTpImp
			M->W2_XCLAIMP := cCliImp

			if Empty(SW2->W2_XTIPIMP) .and. !empty(cTpImp)
				RecLock("SW2",.F.)
					SW2->W2_XTIPIMP := cTpImp
					SW2->W2_XCLAIMP := cCliImp
				SW2->( MsUnlock() )
			EndIf
		EndIf

		While !SW3->(Eof()) .And. xFilial("SW3") + SW3->W3_PO_NUM == SW2->(W2_FILIAL + W2_PO_NUM)
			If Alltrim(cNumPGI) <> Alltrim(SW3->W3_PGI_NUM)
				If SW4->(DbSeek(xFilial("SW4") + SW3->W3_PGI_NUM))
					RecLock("SW4",.F.)
					SW4->W4_XTIPIMP := cTpImp
					SW4->W4_XCLAIMP := cCliImp
					SW4->( MsUnlock() )
				EndIf
				cNumPGI := SW3->W3_PGI_NUM
			EndIf
			SW3->(dbSkip())
		EndDo

	EndIf

	//------ SC7 - PEDIDO DE COMPRAS -----//
	//Atualiza as informações no PC.	  //
	If SC7->(Dbseek(cChvSC7))
		While SC7->(!Eof()) .And. SC7->(C7_FILIAL+C7_FORNECE+C7_LOJA+C7_NUM) == cChvSC7

			//Posiciona na Solicitacao de Compras para buscar campos customizados
			If SC1->(DbSeek(xFilial("SC1") + SC7->(C7_NUMSC+C7_ITEMSC)))
				Reclock("SC7",.F.)
				SC7->C7_TIPIMP := SC1->C1_XTPIMP
				SC7->C7_XCLAIMP:= SC1->C1_XCLAIMP
				SC7->C7_CORINT := SC1->C1_CORINT
				SC7->C7_COREXT := SC1->C1_COREXT
				SC7->C7_OPCION := SC1->C1_OPCION
				SC7->C7_ANOFAB := SC1->C1_ANOFAB
				SC7->C7_ANOMOD := SC1->C1_ANOMOD
				SC7->( MsUnlock() )
			EndIf

			SC7->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaSW0)
	RestArea(aAreaSW2)
	RestArea(aAreaSW3)
	RestArea(aAreaSW4)
	RestArea(aAreaSW5)
	RestArea(aAreaSC1)
	RestArea(aAreaSC7)

Return
