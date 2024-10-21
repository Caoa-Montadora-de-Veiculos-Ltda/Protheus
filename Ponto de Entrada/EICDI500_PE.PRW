#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"

/*
=====================================================================================
Programa.:              EICDI500
Autor....:              Atilio Amarilla
Data.....:              20/12/2018
Descricao / Objetivo:   PE na rotina de manutenção de Embarques
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP EIC004
Obs......:              - U_CMVEIC02() - Gravação de Lotes e informações adicionais
=====================================================================================
*/
User Function EICDI500()

Local cParam 	:= IIF(Type("PARAMIXB") == "A", PARAMIXB[1], IIF(Type("PARAMIXB") == "C", PARAMIXB, ""))
Local lRet 		:= .T.
Local aAreaWORK := ''
Local cIntFin   := ""


MV_PAR60 += TIME() + " " + cParam + " " + Char(13) + Char(10)

If cParam == "AROTINA"
    aAdd( aRotina, { '>>> CAOA - Integração ASIA', "U_ZEICF022()"   ,0 ,3 } )
	aAdd( aRotina, { '>>> CAOA - Integração ASIA-FOLLOWUP', "U_ZEICF025()"   ,0 ,3 } )

ElseIf cParam == "DI500LOTES_ALT_CPOSENC"
	//If FindFunction("U_CMVEIC02")
	//	lRet := U_CMVEIC02()
	//Endif		

ElseIf cParam == "FIM_GERA_ADICOES"

	If Findfunction("U_ZEICF013")
		FWMsgRun(, {|| U_ZEICF013() }, "", "Sincronizando adições..." )
	Endif	

ElseIf cParam == "GRV_WORK_INVOICE"	

	//MsgStop("GRV_WORK_INVOICE")
	If FindFunction("U_CMVEIC03")
		lRet := U_CMVEIC03()
	Endif		
ElseIf cParam == "POS_GRAVA_TUDO" 
	IF ExistBlock("GRVDI500")
		MsgRun("Atualizando Informações Específicas de Importação CAOA","TOTVS",{|| ExecBlock("GRVDI500", .F., .F.) })
	EndIF
	If FindFunction("U_CMVEIC02")
		lRet := U_CMVEIC02()
	Endif
ElseIf cParam == "VALID_OK_PEDIDO_PLI"
    	lValidPOPLI := .T.
ElseIf cParam == "BROWSE_SELECIONA"
    If isInCallStack("EICDI503") .And. (INCLUI .Or. ALTERA)
     	AADD(aBotaoItem,{"PROC"      ,{|| Proc_Chassi() },'Procura Chassi'}) 
     	aAreaWORK	:= WORK->( GetArea() )
		WORK->( dbGoTop() )
		While WORK->( !Eof() )
			WORK->W7_XCHASSI	:= Ret_Dados(1)
			WORK->W7_XMOTOR	:= Ret_Dados(2)			
			WORK->( dbSkip() )
		EndDo
		WORK->( RestArea( aAreaWORK ) )
    EndIF
ElseIF cParam == "ADD_TB_CAMPOS"
    If isInCallStack("EICDI503") .And. (INCLUI .Or. ALTERA)
		 AADD(aTB_Campos,{"W7_XCHASSI"  ,,AVSX3("EW5_XVIN",5)})
		 AADD(aTB_Campos,{"W7_XMOTOR"  ,,AVSX3("EW5_XMOTOR",5)})
			
	EndIF
ElseIF cParam == "CARGA_PO_PLI"
	If FunName() == "EICDI503"
		//MsgStop(cParam)
	
		lInvAnt	:= .F.

	EndIf
ElseIF cParam == "TELA_SELECAO"
	If FunName() == "EICDI503"
	/*	MsgStop(cParam)
	
        oDlgSelec:nRight += 150
        @ 1.5,21 SAY "Invoice Ent." OF oPanel//STR0621 
        @ 1.5,25 MSGET cInv F3 "EW4CMV" SIZE 55,8 Picture "@!" VALID ValidInv(cInv) OF oPanel
        @ 2.5,25 LISTBOX oLbxInv VAR cInv ITEMS aInv SIZE 50,80 OF oPanel UPDATE

        lInvAnt	:= .T.
        */
	EndIf
ElseIF .F. // cParam == "BROWSE_WORK_SW9"//"GRV_WORK_ITEM"//"CRIA_VAR_MEM"
	MsgStop(cParam)

	//If FindFunction("U_CMVEIC06")
	//	lRet := U_CMVEIC06()
	//Endif		

ElseIF .F. //cParam == "VALIDA_MANUT_INV"
	MsgStop(cParam)

	MsgStop("WORK_CWV")
	dbSelectArea("WORK_CWV")
	COPY TO WORKCWV1

	MsgStop("WORK_SWV")
	dbSelectArea("WORK_SWV")
	COPY TO WORKSWV1

	MsgStop("WORK_SW8")
	dbSelectArea("WORK_SW8")
	COPY TO WORKSW81

	MsgStop("WORK_SW9")
	dbSelectArea("WORK_SW9"	)
	MsgStop(LastRec())
	MsgStop(bof())
	MsgStop(eof())
	COPY TO WORKSW91

ElseIF cParam == "VISUAL_CAMPOS"
	If isInCallStack("EICDI503")
		aAdd(aSemSX3,{"W7_XCHASSI" ,"C",AVSX3("EW5_XVIN" ,3),0}) 
		aAdd(aSemSX3,{"W7_XMOTOR" ,"C",AVSX3("EW5_XMOTOR" ,3),0}) 
	Endif
ElseIF cParam == "STRU_WORKS"
	If isInCallStack("EICDI503") .And. (INCLUI .Or. ALTERA)
		aAdd(aSemSX3SW7,{"W7_XCHASSI" ,"C",AVSX3("EW5_XVIN" ,3),0}) 
		aAdd(aSemSX3SW8,{"W7_XCHASSI" ,"C",AVSX3("EW5_XVIN" ,3),0})
		aAdd(aSemSX3SW7,{"W7_XMOTOR" ,"C",AVSX3("EW5_XMOTOR" ,3),0}) 
		aAdd(aSemSX3SW8,{"W7_XMOTOR" ,"C",AVSX3("EW5_XMOTOR" ,3),0})
		
	Endif
	
ElseIf cParam == "AADD_BROWSE_ITEM"
    If isInCallStack("EICDI503")
     	AADD(aCamposItem,{"W7_XCHASSI"  ,,AVSX3("EW5_XVIN",5)})
     	AADD(aCamposItem,{"W7_XMOTOR"  ,,AVSX3("EW5_XMOTOR",5)})
    EndIF


/* =====================================================================================
Autor....:              CAOA - Valter Carvalho
Data.....:              07/12/2020
Descricao / Objetivo:   inclusão do menu de remover todas
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              ANTES_TELA_DESP
Obs......:				ponto de entrada usado ao montar a tela de despesas.	
						fonte do padrão eicdi501.prw
===================================================================================== */
ElseIf cParam == "ANTES_TELA_DESP"

	Aadd(aBotoesDesp, {"", {|| zRemoveDesp()}, " >> CAOA - Excluir Todas", " >> CAOA - Excluir Todas" }    )

/* =====================================================================================
Autor....:              CAOA - Valter Carvalho
Data.....:              07/12/2020
Descricao / Objetivo:   Efetua ajuste do campo integra financeiro para respeitar o campo  YB_XINTFIN
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              ANTES_TELA_DESP
Obs......:				ponto de entrada usado ao montar a tela de despesas.	
						fonte do padrão eicdi501.prw
===================================================================================== */
ElseIf cParam == "TELA_TOTAIS_DESP"

	TRB->(DbGoTop())

	While TRB->(Eof()) = .F.
		cIntFin := Posicione("SYB", 1, XFilial("SYB") + WD_DESPESA, "YB_XINTFIN")	
		
		If Empty(cIntFin) = .T. // se não for preenchido, então não faço nada
			TRB->(DbSkip())
			Loop
		End		

		RecLock("TRB", .F.)
		TRB->WD_GERFIN := cIntFin
		TRB->(MsUnlock())
		TRB->(DbSkip())
	EndDo

	TRB->(DbGoTop())

ElseIf cParam == "INV_CARREGA_SW8
	Work_SW8->W8_XCASE:= SW8->W8_XCASE
	Work_SW8->W8_XLOTE:= SW8->W8_XLOTE
	Work_SW8->W8_XCONT:= SW8->W8_XCONT
EndIf

Return lRet


Static Function Ret_Dados(nTipo)

Local cRet := ''
Local aAreaSW3	:= SW3->( GetArea() )

SW3->(DbSetOrder(8))
IF SW3->(DbSeek(xFilial("SW3")+PADR(Work->WKPO_NUM,TAMSX3('W3_PO_NUM')[1])+Work->WKPOSICAO))              
   	IF nTipo == 1
     	cRet := SW3->W3_XVIN
    ElseIf nTipo == 2
     	cRet := SW3->W3_XMOTOR
    EndIF
EndIF
SW3->( RestArea( aAreaSW3 ) )

Return cRet
********************************************************************************************************************8
Static Function Proc_Chassi
Local aParambox	  := {}                 
Local aRet        := {}                                                                                    
Local nRecWork    := WORK->(Recno())
 

AAdd(aParamBox, {1, "Chassi:"      ,Space(TamSx3('W3_XVIN')[01]) , "@!","" ,"","", 070, .T.	})
IF ParamBox(aParambox, "Procura Chassi"	, @aRet, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .T. /*lUserSave*/)
    WORK->(dbGoTop())
    While WORK->(!EOF())
        IF Alltrim(MV_PAR01) $ WORK->W7_XCHASSI
            nRecWork  := WORK->(Recno())
            Exit
        EndIF
        WORK->(dbSkip())
    End
    WORK->(dbGoto(nRecWork))
    oMark:oBrowse:Refresh()
EndIF
Return


/* =====================================================================================
Programa.:              zRemoveDesp
Autor....:              CAOA - Valter Carvalho
Data.....:              05/11/2020
Descricao / Objetivo:   Efetua o preenchimento dos titulos das despesas do embarque
Uso......:              
===================================================================================== */
Static Function zRemoveDesp()
	Local cErr  := ""

	//Verifica nota
	DbSelectArea("SF1")
	SF1->(DbSetOrder(5))
	IF SF1->(DBSEEK(xFilial() + SW6->W6_HAWB))
		cErr += ' Existe nota fiscal para esse embarque: <font color="RED">' + Alltrim(SF1->F1_SERIE) + '-' + SF1->F1_DOC + '</font>' + CRLF 
	ENDIF
	SF1->(DbCloseArea())

	SE2->(DbSetOrder(1))

	// Verificar se ha titulo de despesa ja baixado
	TRB->(DbGoTop())
	While TRB->(Eof()) = .F.

		// Despesas que não são removiveis
		If TRB->WD_DESPESA $ "101|102"
			TRB->(DbSkip())
			Loop
		EndIf	

		// verifica se tem titulo baixado
		If Empty(TRB->(TRB->WD_DOCTO)) = .F.
			If Empty(Posicione("SE2", 1, Xfilial("SE2") + TRB->WD_PREFIXO + TRB->WD_DOCTO, "E2_BAIXA")) = .F.
				cErr += 'Despesa <font color="RED">' + TRB->WD_DESPESA + " " + TRB->WD_DESCDES + "</font> tem titulo baixado." + CRLF	
			EndIf
		EndIf

        IF AvFlags("EIC_EAI") 
        	IF !EMPTY(TRB->WD_CODINT) .AND. TRB->WD_BASEADI == '1' .AND. TRB->WD_PAGOPOR == '1'

				IF !EMPTY(TRB->WD_CTRFIN1) .AND.  !EMPTY(TRB->WD_CTRFIN2)
					cErr += 'Despesa ' + TRB->WD_DESPESA + " " + TRB->WD_DESCDES + " Esta despesa foi compensada com adiantamento ao despachante. Para excluí-la é necessário cancelar a Prestação de Contas." + CRLF
				ENDIF

				IF (EMPTY(TRB->WD_CTRFIN1) .AND.  EMPTY(TRB->WD_CTRFIN2)) .OR.  (!EMPTY(TRB->WD_CTRFIN1) .AND.  EMPTY(TRB->WD_CTRFIN2))
					If MsgYesNo("Esta é uma despesa base de adiantamento e sua exclusão, possivelmente, deixará saldo do adiantamento realizado ao despachante. Deseja prosseguir?.") = .F.
						cErr += 'Despesa <font color="RED">' + TRB->WD_DESPESA + " " + TRB->WD_DESCDES + "</font> Esta despesa foi compensada com adiantamento ao despachante. Para excluí-la é necessário cancelar a Prestação de Contas." + CRLF
					ENDIF
				ENDIF
	        ENDIF
    	ENDIF
		TRB->(DbSkip())
	EndDo

	If Empty(cErr) = .F.
		ApMsgInfo("Inconsistência na remoção das despesas:" + CRLF + cErr, "PE_EICDI500")	
		TRB->(DbGoTop())		
		Return	
	EndIf

	If MsgYesNo("Deseja remover as despesas do embarque?","PE_EICDI500") = .F.
		TRB->(DbGoTop())		
		Return	
	EndIf

	// Se não deu erro de validação
	TRB->(DbGoTop())
	While TRB->(Eof()) = .F.
		// Despesas que não são removiveis
		If TRB->WD_DESPESA $ "101|102"
			TRB->(DbSkip())
			Loop
		EndIf	

		// Eetue a remoção do registro da swd
		SWD->(dbGoto(TRB->Recno))
		RecLock("SWD", .F. )
		SWD->(DbDelete())
		MsUnlock()

		// Remova da se2
		If Empty(TRB->(TRB->WD_DOCTO)) = .F.
			If SE2->(DbSeek(Xfilial("SE2") + TRB->WD_PREFIXO + TRB->WD_DOCTO)) = .T.
				RecLock("SE2", .F.)
				SE2->(DbDelete())
				MsUnlock()
			EndIf	
		EndIf

		// Remover a TRB
		RecLock("TRB", .F.)
		TRB->(DbDelete())
		MsUnlock()

		TRB->(DbSkip())
	EndDo

	TRB->(DbGoTop())
Return
