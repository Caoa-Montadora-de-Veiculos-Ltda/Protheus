#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} GRVDI500
Função para atualização das informações na DI e Invoice - CAOA.
@author FSW - DWC Consult
@since 20/03/2019
@version 1.0
@type function
/*/
User Function GRVDI500()
	Local aAreaSW2	:= SW2->(GetArea())
	Local aAreaSW3	:= SW3->(GetArea())
	Local aAreaSW7	:= SW7->(GetArea())
	Local aAreaSW8	:= SW8->(GetArea())
	Local aAreaSW9	:= SW9->(GetArea())
	Local aAreaSWV	:= SWV->(GetArea())
	Local aAreaEW5	:= EW5->(GetArea())
	
	Local cTipImp	:= ""
	Local cClaImp	:= ""
	
	SW2->(DbSetOrder(1)) //W2_FILIAL+W2_PO_NUM
	SW3->(DbSetOrder(1)) //W3_FILIAL+W3_PO_NUM+W3_CC+W3_SI_NUM+W3_COD_I
	SW7->(DbSetOrder(1)) //W7_FILIAL+W7_HAWB+W7_PO_NUM+W7_POSICAO+W7_PGI_NUM
	SW8->(DbSetOrder(6)) //W8_FILIAL+W8_HAWB+W8_PGI_NUM+W8_PO_NUM+W8_SI_NUM+W8_CC+W8_COD_I+STR(W8_REG,4,0)
	SW9->(DbSetOrder(3)) //W9_FILIAL+W9_HAWB
	SWV->(dbSetOrder(2)) //WV_FILIAL+WV_HAWB+WV_INVOICE+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO
	EW5->(dbSetOrder(2)) //EW5_FILIAL+EW5_PO_NUM+EW5_POSICA+EW5_INVOIC+EW5_FORN+EW5_FORLOJ
	
	//----- SW6 CAPA DA DI -----//
	//Atualiza com os dados SW2.//
	If SW2->(DbSeek(xFilial("SW2") + SW6->W6_PO_NUM))
		
		cTipImp := SW2->W2_XTIPIMP
		cClaImp := SW2->W2_XCLAIMP
		
		RecLock("SW6",.F.)
			SW6->W6_XTIPIMP := cTipImp
			SW6->W6_XCLAIMP := cClaImp
		SW6->(MsUnLock())

	EndIf

	//----- SW9 CAPA DA INVOICE -----//
	//Atualiza com os dados da SW2.	 //
	If SW9->(DbSeek(xFilial("SW9") + SW6->W6_HAWB))
		While !Sw9->(Eof()) .And. Sw9->W9_Hawb=Sw6->W6_Hawb
			RecLock("SW9",.F.)
				SW9->W9_XTIPIMP := cTipImp
				SW9->W9_XCLAIMP := cClaImp
			SW9->(MsUnlock())

			//----- SW8 ITENS DA INVOICE -----//W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM                                                                                                    
			If SW8->(DbSeek(xFilial("SW8") + SW9->W9_HAWB + Sw9->W9_Invoice )) //+ Sw7->W7_Po_Num+Sw7->W7_Posicao )) //SW9->(W3_PGI_NUM+W3_PO_NUM+W3_SI_NUM+W3_CC+W3_COD_I) + STR(SW3->W3_REG,4,0) ))
				While !Sw8->(Eof()) .And. Sw8->(W8_Filial+W8_Hawb+W8_Invoice)=xFilial("SW8") + SW9->W9_HAWB + Sw9->W9_Invoice 
					If SW3->(DbSeek(xFilial("SW3") + SW8->(W8_PO_NUM+W8_CC+W8_Si_Num+W8_Cod_I+Str(Sw8->W8_Reg,4,0))))
						While !SW3->(EOF()) .And. Sw3->(W3_Filial+W3_PO_NUM+W3_CC+W3_Si_Num+W3_Cod_I+Str(W3_Reg,4,0)) == SW8->(W8_Filial+W8_PO_NUM+W8_CC+W8_Si_Num+W8_Cod_I+Str(Sw8->W8_Reg,4,0))
							If SW3->W3_SEQ == 0 .AND. !isInCallStack("EICDI503")
								SW3->(DbSkip())
								Loop
							EndIf	
							
							/*If SWV->(DbSeek(xFilial("SWV") + SW8->(W8_HAWB + W8_INVOICE + W8_PGI_NUM + W8_PO_NUM + W8_POSICAO)))  
								RecLock("SW8",.F.)
									SW8->W8_CORINT := SW3->W3_CORINT
									SW8->W8_COREXT := SW3->W3_COREXT
									SW8->W8_OPCION := SW3->W3_OPCION
									SW8->W8_ANOFAB := SW3->W3_ANOFAB
									SW8->W8_ANOMOD := SW3->W3_ANOMOD
									SW8->W8_XVIN   := SW3->W3_XVIN
									SW8->W8_XSERMO := SWV->WV_XSERMO 
										
								SW8->(MsUnlock())
							EndIf*/
							If isInCallStack("EICDI503")
							    RecLock("SW8",.F.)
								SW8->W8_CORINT	:= SW3->W3_CORINT
								SW8->W8_COREXT	:= SW3->W3_COREXT
								SW8->W8_OPCION	:= SW3->W3_OPCION
								SW8->W8_ANOFAB	:= SW3->W3_ANOFAB
								SW8->W8_ANOMOD	:= SW3->W3_ANOMOD
								SW8->W8_XVIN	:= SW3->W3_XVIN
								SW8->(MsUnlock())
						    EndIF
							
							
							If EW5->(DbSeek(xFilial("EW5") + SW8->(W8_PO_NUM + W8_POSICAO + W8_INVOICE + W8_FORN + W8_FORLOJ)))
								RecLock("SW8",.F.)
									SW8->W8_CORINT	:= EW5->EW5_XCORIN
									SW8->W8_COREXT	:= EW5->EW5_XCOREX
									SW8->W8_OPCION	:= EW5->EW5_XOPC
									SW8->W8_ANOFAB	:= EW5->EW5_XANOFB
									SW8->W8_ANOMOD	:= EW5->EW5_XANOMD
									SW8->W8_XVIN	:= EW5->EW5_XVIN
									SW8->W8_XLOTE	:= EW5->EW5_XLOTE
									SW8->W8_XCASE	:= EW5->EW5_XCASE
									SW8->W8_XCONT	:= EW5->EW5_XCONT
									SW8->W8_XMOTOR	:= EW5->EW5_XMOTOR
									SW8->W8_XSERMO  := EW5->EW5_XSERMO
									SW8->W8_XCHAVE  := EW5->EW5_XCHAVE
								SW8->(MsUnlock())
							EndIf
							
							Sw3->(DbSkip())
							
						EndDo

					EndIf

					Sw8->(DbSkip())

				EndDo

			EndIf

			Sw9->(DbSkip())

		EndDo

	EndIf

	If Sw7->(DbSeek(xFilial("SW7")+Sw6->W6_Hawb))
		While !Sw7->(Eof()) .And. Sw7->W7_Hawb=Sw6->W6_Hawb
			If SW3->(DbSeek(xFilial("SW3") + SW7->(W7_PO_NUM+W7_CC+W7_Si_Num+W7_Cod_I+Str(Sw7->W7_Reg,4,0))))
				While !SW3->(EOF()) .And. Sw3->(W3_Filial+W3_PO_NUM+W3_CC+W3_Si_Num+W3_Cod_I+Str(W3_Reg,4,0)) == SW7->(W7_Filial+W7_PO_NUM+W7_CC+W7_Si_Num+W7_Cod_I+Str(Sw7->W7_Reg,4,0))
					//Descarta o SEQ <> 0, devido a não ter as informações de PGI.
					If SW3->W3_SEQ <> 0
						SW3->(DbSkip())
						Loop

					EndIf
					
					//----- SW7 ITENS DA DI -----//
					//Atualiza com as Inf. da SW3//
					RecLock("SW7",.F.)
						SW7->W7_CORINT	:= SW3->W3_CORINT
						SW7->W7_COREXT	:= SW3->W3_COREXT
						SW7->W7_OPCION	:= SW3->W3_OPCION
						SW7->W7_ANOFAB	:= SW3->W3_ANOFAB
						SW7->W7_ANOMOD	:= SW3->W3_ANOMOD
						SW7->W7_XCHASSI	:= SW3->W3_XVIN

					SW7->(MsUnLock())

		
					SW3->(DbSkip())

				EndDo

			EndIf
	
			Sw7->(DbSkip())
		
		EndDo
	
	EndIf
	
	RestArea(aAreaEW5)
	RestArea(aAreaSWV)
	RestArea(aAreaSW2)
	RestArea(aAreaSW3)
	RestArea(aAreaSW7)
	RestArea(aAreaSW8)
	RestArea(aAreaSW9)	
Return