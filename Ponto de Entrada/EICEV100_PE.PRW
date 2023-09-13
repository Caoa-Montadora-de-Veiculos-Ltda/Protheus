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

//Nova variáveis
//Private cTabela := GetNextAlias()
//Local aArea 

If cParam == "AJUSTA_BROWSE"
	MsgInfo("Entrou no ponto de entrada 'AJUSTA_BROWSE'.")
EndIf

If cParam == "ANTES_GRAVA_EW4"
	MsgInfo("Entrou no ponto de entrada 'ANTES_GRAVA_EW4'.")
EndIf

If cParam == "DEPOIS_GRAVA_EW4"
	MsgInfo("Entrou no ponto de entrada 'DEPOIS_GRAVA_EW4'.")
EndIf

If cParam == "GRVWORK"
	MsgInfo("Entrou no ponto de entrada 'GRVWORK'.")
EndIf
	If cParam == "ANTES_GRAVA_EW5"
	MsgInfo("Entrou no ponto de entrada 'ANTES_GRAVA_EW5'.")
EndIf

If cParam == "DEPOIS_GRAVA_EW5"
	MsgInfo("Entrou no ponto de entrada 'DEPOIS_GRAVA_EW5'.")
EndIf

If cParam == "VALIDA_CAMPOS"
	MsgInfo("Entrou no ponto de entrada 'VALIDA_CAMPOS'.")
	lSair := .F.
EndIf

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




/*
//	Criar um IF utilizando o nOPC == 5 -
// Ao clicar em excluir é ativo o ponto de entrada GRVWORK
//	Posicionar o RECNO atual
//	Colocar ele como parâmetro de pesquisa na query
//	Rodar a query pesquuisando o RECNO atual e salvar ela em uma tabela GetNextAlias
	cQry := CRLF + " "
	cQry += CRLF + "		SELECT "
	cQry += CRLF + "			EW4.R_E_C_N_O_ AS EW4_RECNO "
	cQry += CRLF + "			, SZM.R_E_C_N_O_ AS SZM_RECNO "
	cQry += CRLF + "			, EW4.D_E_L_E_T_ AS EW4_DELET "
	cQry += CRLF + "			, SZM.D_E_L_E_T_ AS SZM_DELET "	
	cQry += CRLF + "			, EW4_FILIAL, EW4_INVOIC, EW4_XNAVIO, EW4_XHOUSE "
	cQry += CRLF + "			, SZM.ZM_FILIAL, SZM.ZM_INVOICE, SZM.ZM_NAVIO, SZM.ZM_BL " 
	cQry += CRLF + "		FROM "	
	cQry += CRLF + "			" + RetSqlName("EW4") + " EW4 "	//-- TABELA CAPA DE INVOICES ANTECIPADAS
	cQry += CRLF + "		LEFT JOIN ABDHDU_PROT.SZM020 SZM "	//-- TABELA DE INTEGRAÇÃO XML
	cQry += CRLF + "			 ON EW4_FILIAL = '" + xFilial('EW4') + "'" //-- USAR FILIAL CORRENTE
	cQry += CRLF + "			AND EW4_INVOIC = SZM.ZM_INVOICE " 
	cQry += CRLF + "			AND EW4_XNAVIO = SZM.ZM_NAVIO "
	cQry += CRLF + "			AND EW4_XHOUSE = SZM.ZM_BL "
	cQry += CRLF + "		WHERE " 
	cQry += CRLF + "			EW4.D_E_L_E_T_  != ' ' "
	cQry += CRLF + "			EW4_FILIAL 		= '" + xFilial('EW4') + "'"
	cQry += CRLF + "		AND EW4.R_E_C_N_O_  = '" + MV_PAR01 + "' "
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ), cTabela, .T., .T. )

//	Criar um LOOP para rodar todas as linhas da tabelas
	aArea := FWGetArea()
	DbSelectArea(cTabela)
		(cTabela)->(DbGotop())
		While (cTabela)->(!EoF())
			
			// Obter RECNO atual cTabela
			// atrelar RECNO SZM A variável publica MV_PAR02
			// Abrir area da tabela SZM
			// Posicionar MV_PAR02 na tabela SZM
			// Travar tabela com recLock
			// Deletar linha por linha da tabela SZM
			// DesTravar tabela com UnLock
			// Fechar area da tabela SZM
			(cTabela)->(DbSkip())
		EndDo
	
	(cTabela)->(DbCloseArea())

	FwRestArea(aArea)

// -------------- FIM DA NOVA ALTERAÇÃO GAP082 NICOLAS
*/
