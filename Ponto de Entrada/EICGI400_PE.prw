#Include "TOTVS.Ch"
#Include "Protheus.Ch"

/*/{Protheus.doc} EICGI400
P.E. - Gravar campos espec�ficos do SW5 - EICGI400
@author Jo�o Carlos da Silva
@since 12/03/2019
@version 1.0
@type function
/*/
User Function EICGI400()
	Local cCorInt	:= ""
	Local cCorExt	:= ""
	Local cOpcion	:= ""
	Local cAnoFab	:= ""
	Local cAnoMod	:= ""
	Local cParam	:= If(Type("ParamIxb") = "A",ParamIxb[1],If(Type("ParamIxb") = "C",ParamIxb,""))
	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local aAreaSW1	:= Nil
	
	//If IsInCallStack("GI400SELINV")
	//	MsgStop(cParam)
	//EndIf
	
	If cParam == "VAL_ITEM_WORK"
		If SW3->W3_FLUXO <> '1'
			lW3Skip := .T.
		EndIf
	EndIf
	
	/*If cParam == Upper("GRV_WORK_COM_SW1")
		RecLock("WORK",.F.)
		WORK->W3_CORINT := SW1->W1_CORINT
		WORK->W3_COREXT := SW1->W1_COREXT
		WORK->W3_OPCION := SW1->W1_OPCION
		WORK->W3_ANOFAB := SW1->W1_ANOFAB
		WORK->W3_ANOMOD := SW1->W1_ANOMOD
		WORK->(MsUnLock())
	EndIf*/	
	//Grava as Informa��es adicionais de Importa��o.
	If cParam == "GI_GRAVA"
		//U_xGRVG400()
	EndIf


	If cParam == Upper("GRAVA_DESPESAS")
		aAreaSW1 := SW1->(GetArea())
		SW1->(dbSetOrder(1))  //W1_FILIAL+W1_CC+W1_SI_NUM+W1_COD_I
		SW1->(dbSeek(xFilial("SW1") + WORK->(WKCC+WKSI_NUM+WKCOD_I+Str(Work->WkReg,4) )))
//		While SW1->(!Eof() .and. W1_FILIAL+W1_CC+W1_SI_NUM == xFilial("SW1") + WORK->WKCC + WORK->WKSI_NUM)
		While !SW1->(Eof()) .and. Sw1->(W1_FILIAL+W1_CC+W1_SI_NUM+W1_Cod_I+Str(Sw1->W1_Reg,4)) == xFilial("SW1") + WORK->(WKCC+WKSI_NUM+WkCod_I+Str(Work->WkReg,4))
			If SW1->(W1_SEQ == 0)
				cCorInt := SW1->W1_CORINT
				cCorExt := SW1->W1_COREXT
				cOpcion := SW1->W1_OPCION
				cAnoFab := SW1->W1_ANOFAB
				cAnoMod := SW1->W1_ANOMOD
				Exit

			EndIf

			SW1->(dbSkip())

		End

		RestArea(aAreaSW1)
		WORK->W5_CORINT := cCorInt
		WORK->W5_COREXT := cCorExt
		WORK->W5_OPCION := cOpcion
		WORK->W5_ANOFAB := cAnoFab
		WORK->W5_ANOMOD := cAnoMod

	EndIf
	
	RestArea(aArea)
Return(lRet)