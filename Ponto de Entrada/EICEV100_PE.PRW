#Include "Protheus.ch"
#Include 'TOPCONN.CH'

/*
=====================================================================================
Programa.:              EICEV100
Autor....:              Atilio Amarilla
Data.....:              20/12/2018
Descricao / Objetivo:   PE na rotina de manutenção de L.I./P.L.I.
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP PCP006
Obs......:              
=====================================================================================
*/
User Function EICEV100()

Local cParam := IIF(Type("PARAMIXB") == "A", PARAMIXB[1], IIF(Type("PARAMIXB") == "C", PARAMIXB, ""))
Local lRet   := .T.
//Local nI     := 0 

// Criação de botôes adicionais no browse
If FunName() == "EICEV100" .And. cParam == "CRIA_BOTAO"
	If FindFunction("U_CMVEIC01")
		lRet := U_CMVEIC01()
		
		//RETIRADO VALIDAÇÃO
		//SOLICITAÇÃO TAKAHASI - TREINAMENTO MARCELA.
		//12/04/2021
		/*For nI := 1 To Len(aRotina)
		   IF aRotina[nI,02]== 'EV100MANUT' .AND. aRotina[nI,04]== 4
			     aRotina[nI,02]:="MsgAlert('Função desativada, não é possivel alterar uma Invoice, Exclua e Importe novamente!!')"
		   EndIF
		Next nI*/   
	Endif		
ElseIf FunName() == "EICEV100" .And. cParam == "ALTERA_WORK"
	If FindFunction("U_CMVEIC04")
		U_CMVEIC04()
	Endif		
ElseIF FunName() == "EICEV100" .And. cParam == "GRVWORK"		
	IF !ALTERA .AND. !INCLUI
	   IF !('VISUALIZAR' $ cCadastro )
	    EW4_AGT_OK := '2'
	    EW4_D_OK_A := CTOD('  /  /  ')
	    EW4_OK_SHP:= '2'
	    EW4_DT_LIB := CTOD('  /  /  ')
	   EndIF
	EndIF

/*
	Valter Carvalho 20/07/2021
	Atualiza informacoes da PO
	GAP EIC 110
*/
ElseIF FunName() == "EICEV100" .And. cParam == "DEPOIS_GRAVA_EW4"
	
     FWMsgRun(, {|| zAtW2(), Sleep(300) }, "", "PE_EICEV100 - zAtW2() -  Atualizando PO...")

EndIf


Return lRet


/*
	Valter Carvalho 20/07/2021
	Atualiza informacoes da PO ao salvar a invoice antecipada
	GAP EIC 110
*/

Static Function zAtW2()
	Local cmd := ""
	Local cQr := getNextAlias()

	cmd += Char(13) + Char(10) + " SELECT" 
	cmd += Char(13) + Char(10) + " SUM(EW4_FRETEI)  AS FRETEI, "
	cmd += Char(13) + Char(10) + " SUM(EW4_INLAND + EW4_PACKIN) AS OUT_DES "
	cmd += Char(13) + Char(10) + " FROM " + RetSQLName("EW4") 
	cmd += Char(13) + Char(10) + "  WHERE " 
	cmd += Char(13) + Char(10) + "    D_E_L_E_T_ = ' '" 
	cmd += Char(13) + Char(10) + "  AND EW4_FILIAL = '" + FwXFilial("EW4") + "' " 
	cmd += Char(13) + Char(10) + "  AND EW4_INVOIC IN (  " 
	cmd += Char(13) + Char(10) + "     SELECT DISTINCT EW5_INVOIC FROM " + RetSQLName("EW5") 
	cmd += Char(13) + Char(10) + "     WHERE   " 
	cmd += Char(13) + Char(10) + "         D_E_L_E_T_ = ' '  " 
	cmd += Char(13) + Char(10) + "     AND EW5_FILIAL = '" + FwXFilial("EW4") + "' " 
	cmd += Char(13) + Char(10) + "     AND EW5_PO_NUM = '" + SW2->W2_PO_NUM + "' " 
	cmd += Char(13) + Char(10) + " )  " 

	TcQuery cmd new alias (cQr)

	RecLock("SW2", .F.)
	SW2->W2_INCOTER := EW4->EW4_INCOTE
	SW2->W2_FRETEIN := (cQr)->FRETEI
	SW2->W2_OUT_DES := (cQr)->OUT_DES
	SW2->(MsUnlock())

	(cQr)->(DbCloseArea())

Return 
