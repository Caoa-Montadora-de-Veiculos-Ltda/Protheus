#Include "TOTVS.CH"
/*
=====================================================================================
Programa.:              CMVEIC02
Autor....:              Atilio Amarilla
Data.....:              11/01/2019
Descricao / Objetivo:   Gravação adicional em arquivos de trabalho
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP EIC004
Obs......:              Chamado pelo PE_EICDI500
=====================================================================================
*/
User Function CMVEIC02()
Local aAreaSWV := SWV->(GetArea())
Local aAreaSW6 := SW6->(GetArea())
Local aAreaSW7 := SW7->(GetArea())
Local aAreaSW8 := SW8->(GetArea())
Local aAreaSW9 := SW9->(GetArea())
Local aAreaSW3 := SW3->(GetArea())
Local aAreaEW5 := EW5->(GetArea())
Local aAreaEW4 := EW4->(GetArea())
Local cLote    := ""
Local cTpUnit  := GetMV("CMV_WMS01B",.T.,"000001")


D0Y->(dbSetOrder(1))
SW7->(dbSetOrder(1))
EW5->( dbSetOrder(2))  //EW5_FILIAL+EW5_PO_NUM+EW5_POSICA+EW5_INVOIC+EW5_FORN+EW5_FORLOJ
EW4->( dbSetOrder(2))  //EW4_FILIAL+EW4_HAWB+EW4_INVOIC+EW4_FORN+EW4_FORLOJ
//Exclui todo o cadastro que houver dos lotes
SWV->(dbSetOrder(1))
SWV->(dbSeek(SW6->W6_FILIAL+SW6->W6_HAWB))
While !SWV->(Eof()) .And. SW6->(W6_FILIAL+W6_HAWB)  == SWV->(WV_FILIAL+WV_HAWB)
	Reclock("SWV",.F.)
	SWV->(dbDelete())
	SWV->(MsUnlock())
	SWV->(dbSeek(SW6->W6_FILIAL+SW6->W6_HAWB))
EndDo
If isInCallStack("EICDI503")
	SW7->(dbSetOrder(4))
	SW3->(dbSetOrder(1)) //W3_FILIAL+W3_PO_NUM+W3_CC+W3_SI_NUM+W3_COD_I+STR(W3_REG, 4, 0)+STR(W3_SEQ, 2, 0)
	SW8->(DbSetOrder(6)) //W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
	SW9->(DbSetOrder(3)) //W9_FILIAL+W9_HAWB
	If SW9->(DbSeek(xFilial("SW9") + SW6->W6_HAWB))
		While !Sw9->(Eof()) .And. Sw9->W9_Hawb=Sw6->W6_Hawb
			   SW8->(DbSeek(xFilial("SW8") + SW9->W9_HAWB + Sw9->W9_Invoice )) 
			   While !Sw8->(Eof()) .And. SW8->W8_HAWB == Sw9->W9_Hawb .AND. SW8->W8_INVOICE == Sw9->W9_Invoice
				   If SW7->(DbSeek(xFilial("SW7") + SW6->W6_HAWB + SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM )) 
				        RecLock("SWV", .T.)
				        SWV->WV_FILIAL		:= SW8->W8_FILIAL
						SWV->WV_PGI_NUM		:= SW8->W8_PGI_NUM
						SWV->WV_LOTE		:= SW7->W7_XCHASSI    
						SWV->WV_FORN		:= SW8->W8_FORN   
						SWV->WV_FORLOJ		:= SW8->W8_FORLOJ 
						SWV->WV_QTDE		:= SW8->W8_QTDE   
						SWV->WV_DT_VALID	:= CtoD("31/12/2049")
						SWV->WV_INVOICE		:= SW8->W8_INVOICE
						SWV->WV_PO_NUM		:= SW8->W8_PO_NUM
						SWV->WV_CC			:= SW8->W8_CC
						SWV->WV_SI_NUM		:= SW8->W8_SI_NUM
						SWV->WV_COD_I		:= SW8->W8_COD_I
						SWV->WV_POSICAO		:= SW8->W8_POSICAO
						SWV->WV_REG			:= SW8->W8_REG
						SWV->WV_HAWB		:= SW8->W8_HAWB   
					    SWV->WV_XCORIN		:= SW7->W7_CORINT
						SWV->WV_XCOREX		:= SW7->W7_COREXT
						SWV->WV_XOPC		:= SW7->W7_OPCION
						SWV->WV_XANOFB		:= SW7->W7_ANOFAB
						SWV->WV_XANOMD		:= SW7->W7_ANOMOD
						SWV->WV_XCONT		:= SW8->W8_XCONT
						//W3_FILIAL+W3_PO_NUM+W3_CC+W3_SI_NUM+W3_COD_I+STR(W3_REG, 4, 0)+STR(W3_SEQ, 2, 0)
						IF SW3->(DbSeek(xFilial("SW3") + SW8->W8_PO_NUM + SW8->W8_CC  + SW8->W8_SI_NUM + SW8->W8_COD_I+STR(SW8->W8_REG, 4, 0)))
							SWV->WV_XMOTOR		:= SW3->W3_XMOTOR
						EndIF
						SWV->WV_XSERMO      := RIGHT(Alltrim(SW7->W7_XCHASSI),8)
						SWV->WV_XVIN		:= SW7->W7_XCHASSI  
						SWV->(MsUnLock())
				  EndIF
				  SW8->(DbSkip())
			End
			Sw9->(DbSkip())
		EndDo
    EndIF
Else
	IF EW4->(dbSeek(SW6->W6_FILIAL+SW6->W6_HAWB))
        RecLock("SW6", .F.)
		SW6->W6_HOUSE   := EW4->EW4_XHOUSE
		SW6->W6_IDENTVE := EW4->EW4_XNAVIO
		SW6->(MsUnLock())
	EndIF
	SZD->(dbSetOrder(1))
	SW7->(dbSeek(SW6->W6_FILIAL+SW6->W6_HAWB))
	While !SW7->(Eof()) .And. SW6->(W6_FILIAL+W6_HAWB)  == SW7->(W7_FILIAL+W7_HAWB)
			EW5->(dbSeek(xFilial("EW5")+SW7->W7_PO_NUM+SW7->W7_POSICAO+SW7->W7_INVOICE+SW7->W7_FORN+SW7->W7_FORLOJ ))
			While !Ew5->(Eof()) .And. SW7->W7_FILIAL  ==  EW5->EW5_FILIAL .AND.;
									  SW7->W7_PO_NUM  ==  EW5->EW5_PO_NUM .AND.;
			                          SW7->W7_POSICAO ==  EW5->EW5_POSICA .AND.;
			                          SW7->W7_INVOICE ==  EW5->EW5_INVOIC .AND.;
			                          SW7->W7_FORN    ==  EW5->EW5_FORN   .AND.;
			                          SW7->W7_FORLOJ  ==  EW5->EW5_FORLOJ
			        //CKD
			        IF Empty(EW5->EW5_XVIN)
			        
			            SZD->(dbSeek(EW5->EW5_FILIAL+EW5->(EW5_INVOIC+EW5_CC+EW5_SI_NUM+EW5_PO_NUM+EW5_POSICA+EW5_COD_I)))
	                    While !SZD->(Eof()) .And. SZD->ZD_FILIAL  ==  EW5->EW5_FILIAL .AND.;
												  Alltrim(SZD->ZD_CHAVE)   ==  Alltrim(EW5->(EW5_INVOIC+EW5_CC+EW5_SI_NUM+EW5_PO_NUM+EW5_POSICAO+EW5_COD_I))		        
	
						        RecLock("SWV", .T.)
						        SWV->WV_FILIAL		:= SW7->W7_FILIAL
								SWV->WV_PGI_NUM		:= SW7->W7_PGI_NUM
								SWV->WV_LOTE		:= SZD->ZD_LOTE
								//SWV->WV_XLOTE		:= SZD->ZD_LOTE
								SWV->WV_FORN		:= EW5->EW5_FORN
								SWV->WV_FORLOJ		:= EW5->EW5_FORLOJ
								SWV->WV_QTDE		:= SZD->ZD_QTDE
								SWV->WV_DT_VALID	:= CtoD("31/12/2049")
								SWV->WV_INVOICE		:= EW5->EW5_INVOICE
								SWV->WV_PO_NUM		:= EW5->EW5_PO_NUM
								SWV->WV_CC			:= EW5->EW5_CC
								SWV->WV_SI_NUM		:= EW5->EW5_SI_NUM
								SWV->WV_COD_I		:= EW5->EW5_COD_I
								SWV->WV_POSICAO		:= EW5->EW5_POSICAO
								SWV->WV_REG			:= EW5->EW5_REG
								SWV->WV_HAWB		:= SW7->W7_HAWB
							    SWV->WV_XCORIN		:= EW5->EW5_XCORIN
								SWV->WV_XCOREX		:= EW5->EW5_XCOREX
								SWV->WV_XOPC		:= EW5->EW5_XOPC
								SWV->WV_XANOFB		:= EW5->EW5_XANOFB
								SWV->WV_XANOMD		:= EW5->EW5_XANOMD
								SWV->WV_XVIN		:= EW5->EW5_XVIN
								SWV->WV_XCASE		:= SZD->ZD_CAIXA
								SWV->WV_XCONT		:= EW5->EW5_XCONT
								SWV->WV_XMOTOR		:= EW5->EW5_XMOTOR
								SWV->WV_XSERMO      := EW5->EW5_XSERMO
								SWV->(MsUnLock())
								cLote := Alltrim(SZD->ZD_LOTE)+SWV->WV_XCASE
								If !D0Y->( dbSeek( SZD->ZD_FILIAL+cLote) ) 
									RecLock("D0Y",.T.)
									D0Y->D0Y_FILIAL	:= SZD->ZD_FILIAL
									D0Y->D0Y_IDUNIT	:= cLote // Etiqueta do case vindo da importação(EIC) *
									D0Y->D0Y_DATGER	:= Date()		// Data Geração  *
									D0Y->D0Y_HORGER	:= Time()		// Hora Geração *
									D0Y->D0Y_USUARI	:=	__cUserId	// Codigo Usuario Geração *
									//D0Y->D0Y_NOMUSR	:=	cUserName	// Nome do Usuario Geração *(Campo Virtual)
									D0Y->D0Y_TIPGER	:= '1' 			// valor padrão *
									D0Y->D0Y_USADO	:= '2'  		// valor padrão *
									D0Y->D0Y_IMPRES	:= '2'  		// valor padrão *
									D0Y->D0Y_TIPUNI	:= cTpUnit		// codigo do unitizador (verificar possibilidade de vinculo na importação do arquivo EIC
									D0Y->( msUnlock() )
				
								EndIf
								
								SZD->(dbSKIP()) 
			            End
			        Else
				        RecLock("SWV", .T.)
				        SWV->WV_FILIAL		:= SW7->W7_FILIAL
						SWV->WV_PGI_NUM		:= SW7->W7_PGI_NUM
						SWV->WV_LOTE		:= EW5->EW5_XLOTE 
						SWV->WV_FORN		:= EW5->EW5_FORN
						SWV->WV_FORLOJ		:= EW5->EW5_FORLOJ
						SWV->WV_QTDE		:= IIF(!Empty(EW5->EW5_XVIN),1,EW5->EW5_QTDE)
						SWV->WV_DT_VALID	:= CtoD("31/12/2049")
						SWV->WV_INVOICE		:= EW5->EW5_INVOICE
						SWV->WV_PO_NUM		:= EW5->EW5_PO_NUM
						SWV->WV_CC			:= EW5->EW5_CC
						SWV->WV_SI_NUM		:= EW5->EW5_SI_NUM
						SWV->WV_COD_I		:= EW5->EW5_COD_I
						SWV->WV_POSICAO		:= EW5->EW5_POSICAO
						SWV->WV_REG			:= EW5->EW5_REG
						SWV->WV_HAWB		:= SW7->W7_HAWB
					    SWV->WV_XCORIN		:= EW5->EW5_XCORIN
						SWV->WV_XCOREX		:= EW5->EW5_XCOREX
						SWV->WV_XOPC		:= EW5->EW5_XOPC
						SWV->WV_XANOFB		:= EW5->EW5_XANOFB
						SWV->WV_XANOMD		:= EW5->EW5_XANOMD
						SWV->WV_XVIN		:= EW5->EW5_XVIN
						SWV->WV_XCASE		:= EW5->EW5_XCASE
						SWV->WV_XCONT		:= EW5->EW5_XCONT
						SWV->WV_XMOTOR		:= EW5->EW5_XMOTOR
						SWV->WV_XSERMO      := EW5->EW5_XSERMO
						SWV->(MsUnLock())
					EndIF
				Ew5->(DbSkip())
			EndDo
		SW7->(DbSkip())
	EndDo
EndIF
RestArea( aAreaSWV )
RestArea( aAreaSW6 )
RestArea( aAreaSW7 )
RestArea( aAreaSW8 )
RestArea( aAreaSW9 )
RestArea( aAreaSW3 )
RestArea( aAreaEW4 )
RestArea( aAreaEW5 )

RETURN .T.
**************************************************************************************************************************************
User Function CMVEICWK()
Local aAreaEW5 := EW5->(GetArea())
Local nQuant   := 0 
Local nI       := 0 
Local aCampos  := {}

EW5->( dbSetOrder(2))  
EW5->(dbSeek(xFilial("EW5")+PADR(WORK_SW8->WKPO_NUM,TamSX3("EW5_PO_NUM")[1])+WORK_SW8->WKPOSICAO+WORK_SW8->WKINVOICE+WORK_SW8->WKFORN))
While !Ew5->(Eof()) .And. EW5->EW5_FILIAL      ==  xFilial("EW5") .AND.;
						  Alltrim(WORK_SW8->WKPO_NUM)  ==  Alltrim(EW5->EW5_PO_NUM) .AND.;
                          WORK_SW8->WKPOSICAO ==  EW5->EW5_POSICA .AND.;
                          WORK_SW8->WKINVOICE ==  EW5->EW5_INVOIC .AND.;
                          WORK_SW8->WKFORN    ==  EW5->EW5_FORN   
        nQuant++
        IF Empty(EW5->EW5_XCASE)
            Exit
        EndIF
        IF nQuant == 1
            Work_SW8->WKQTDE := EW5->EW5_QTDE
            aCampos 		 := {}
            For nI := 1 To Work_SW8->(FCount())
			   AADD(aCampos,{AllTrim(Work_SW8->(FIELDNAME(nI))),Work_SW8->(FieldGet(nI))})
			Next i
        Else
            RecLock("Work_SW8", .T.)
            For nI := 1 To Len(aCampos)
			   &("Work_SW8->"+aCampos[nI,01]) := aCampos[nI,02]
			Next i			            
            Work_SW8->WKQTDE    := EW5->EW5_QTDE
            Work_SW8->W8_XCASE  := EW5->EW5_XCASE
            WORK_SW8->(MsUnLock())
        EndIF
	Ew5->(DbSkip())
EndDo

RestArea( aAreaEW5 )
RETURN .T.







/* Antigo fonte que alterava o cadastro
Local aArea, cAliasTWV, cAliasSWV, nX
aArea	:= GetArea()
aAreaSWV:= Work_SWV->(GetArea())
aAreaTWV:= Work_TWV->(GetArea())
Work_TWV->(DbGoTop())
While !Work_TWV->(Eof())
	Work_TWV->(DbDelete())
	Work_TWV->(DbSkip())

EndDo

Work_SWV->(DbGoTop())
While !Work_SWV->(Eof())
	Work_SWV->(DbDelete())
	Work_TWV->(DbSkip())

EndDo

For nX:=1 To Len(aInv)
	If !Empty(aInv[nX])
		EW5->( dbSetOrder(1))  // Indice 1 - EW5_FILIAL+EW5_INVOIC+EW5_FORN+EW5_FORLOJ
		Ew5->(DbSeek(xFilial("EW5")+aInv[nX]))
		nTTT:=0
		//M->WV_LOTE := Ew5->Ew5_XLote
		While !Ew5->(Eof()) .And. Ew5->Ew5_Invoic=aInv[nX]
			RecLock("WORK_TWV", .t.)
				Work_TWV->Wv_Pgi_Num	:=	Ew5->Ew5_Pgi_Nu
				Work_TWV->Wv_Lote		:=	Ew5->Ew5_XLote // Right(Ew5->Ew5_XVin,8) alterado Carneiro dia 02/05/19
				Work_TWV->Wv_Forn		:=	Ew5->Ew5_Forn
				Work_TWV->Wv_ForLoj		:=	Ew5->Ew5_ForLoj
				Work_TWV->Wv_Qtde		:=	1 //Ew5->Ew5_Qtde
				Work_TWV->Wv_Dt_Valid	:=	CtoD("31/12/2049")
				Work_TWV->Wv_Invoice	:=	Ew5->Ew5_Invoice
				Work_TWV->Wv_Po_Num		:=	Ew5->Ew5_Po_Num
				Work_TWV->Wv_CC			:=	Ew5->Ew5_CC
				Work_TWV->Wv_Si_Num		:=	Ew5->Ew5_Si_Num
				Work_TWV->Wv_Cod_I		:=	Ew5->Ew5_Cod_I
				Work_TWV->Wv_Posicao	:=	Ew5->Ew5_Posicao
				Work_TWV->Wv_Reg		:=	Ew5->Ew5_Reg
				Work_TWV->WV_XCORIN		:= EW5->EW5_XCORIN
				Work_TWV->WV_XCOREX		:= EW5->EW5_XCOREX
				Work_TWV->WV_XOPC		:= EW5->EW5_XOPC
				Work_TWV->WV_XANOFB		:= EW5->EW5_XANOFB
				Work_TWV->WV_XANOMD		:= EW5->EW5_XANOMD
				Work_TWV->WV_XVIN		:= EW5->EW5_XVIN
				Work_TWV->WV_XCASE		:= EW5->EW5_XCASE
				Work_TWV->WV_XCONT		:= EW5->EW5_XCONT
				Work_TWV->WV_XMOTOR		:= EW5->EW5_XMOTOR
				Work_TWV->WV_XSERMO     := EW5->EW5_XSERMO
				Work_TWV->WKFLAGLOT		:= cMarca

			MsUnLock()

			RecLock("WORK_SWV", .t.)
				Work_SWV->Wv_Pgi_Num	:=	Ew5->Ew5_Pgi_Nu
				Work_SWV->Wv_Lote		:=	Ew5->Ew5_XLote // Right(Ew5->Ew5_XVin,8) alterado Carneiro dia 02/05/19
				Work_SWV->Wv_Forn		:=	Ew5->Ew5_Forn
				Work_SWV->Wv_ForLoj		:=	Ew5->Ew5_ForLoj
				Work_SWV->Wv_Qtde		:=	1 // Ew5->Ew5_Qtde
				Work_SWV->Wv_Dt_Valid	:=	CtoD("31/12/2049")
				Work_SWV->Wv_Invoice	:=	Ew5->Ew5_Invoice
				Work_SWV->Wv_Po_Num		:=	Ew5->Ew5_Po_Num
				Work_SWV->Wv_CC			:=	Ew5->Ew5_CC
				Work_SWV->Wv_Si_Num		:=	Ew5->Ew5_Si_Num
				Work_SWV->Wv_Cod_I		:=	Ew5->Ew5_Cod_I
				Work_SWV->Wv_Posicao	:=	Ew5->Ew5_Posicao
				Work_SWV->Wv_Reg		:=	Ew5->Ew5_Reg
//					Work_SWV->Wv_Hawb		:=	M->W6_Hawb
				Work_SWV->WV_XCORIN		:= EW5->EW5_XCORIN
				Work_SWV->WV_XCOREX		:= EW5->EW5_XCOREX
				Work_SWV->WV_XOPC		:= EW5->EW5_XOPC
				Work_SWV->WV_XANOFB		:= EW5->EW5_XANOFB
				Work_SWV->WV_XANOMD		:= EW5->EW5_XANOMD
				Work_SWV->WV_XVIN		:= EW5->EW5_XVIN
				Work_SWV->WV_XCASE		:= EW5->EW5_XCASE
				Work_SWV->WV_XCONT		:= EW5->EW5_XCONT
				Work_SWV->WV_XMOTOR		:= EW5->EW5_XMOTOR
				Work_SWV->WV_XSERMO     := EW5->EW5_XSERMO
//				Work_SWV->WKFLAGLOT		:= cMarca

			MsUnLock()

			Ew5->(DbSkip())

		EndDo
	
	EndIf

Next

RestArea( aAreaSWV )
RestArea( aAreaTWV )
RestArea( aArea )
*/



