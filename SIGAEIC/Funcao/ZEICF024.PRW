#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TopConn.Ch"

/*/{Protheus.doc} ZEICF024
@type		Function
@version	1.0
@author     Nicolas Lima
@since      25/09/2023
@project    GRUPO CAOA GAP082 - Excluir SZM na exclusão da Invoice Antecipada.
@Obs        Objetivo: Apagar itens da SZM que deveriam ter sido estornados porém não foram, são itens que já estão excluídos na EW4 e EW5
/*/


//----------------------------------------------------------------------------------

User Function ZEICF024()
	//Private _lRet := .F.
	//Perguntar se o usuário deseja continuar.
	If MsgYesNo("Esta rotina limpa todos os resquícios de estorno de Invoice que ficaram ativos na tavbela SZM " + CRLF ;
				+ "Deseja continuar?" )
		FwMsgRun(,{ |_oSay| zUpdate(_oSay ) }, "Processando", "Limpando tabela SZM, por favor aguarde...")  
	Else
		MsgStop("Operação cancelada pelo usuário.")
	EndIf	

Return

//----------------------------------------------------------------------------------

Static Function zUpdate(_oSay)

    Local aArea 	:= GetArea()
	Local cQry      := " "
	Local _nStatus 	:= 0
		
	oSay:SetText("Iniciando processamento...")

	Begin Transaction	

		//Pesquisar itens que devem ser limpos através da query
		cQry += " 	UPDATE " + RetSqlName("SZM") + " SZM" 		 				+ CRLF
		cQry += " 	SET D_E_L_E_T_ 	= '*' "										+ CRLF
		cQry += "	, SZM.R_E_C_D_E_L_ = SZM.R_E_C_N_O_ "						+ CRLF 
		cQry += "		SZM.R_E_C_N_O_ AS SZM_RECNO " 							+ CRLF 
		cQry += "		WHERE "													+ CRLF
		cQry += "		SZM.ZM_FILIAL 	= '" + FWxFilial("SZM") + "'" 			+ CRLF //--FILIAL CORRENTE 
		cQry += "		AND SZM.ZM_INVOICE  IN ( "								+ CRLF
		cQry += "		SELECT TMP_SZM.ZM_INVOICE FROM "						+ CRLF 
		cQry += "		(SELECT DISTINCT "										+ CRLF
		cQry += "			SZM.ZM_INVOICE "									+ CRLF
		cQry += "		FROM "													+ CRLF
		cQry +=	" 		" + RetSqlName("SZM") + " SZM"   						+ CRLF //--TABELA INTEGRAÇÃO XML (CAPA)
		cQry += "		WHERE "													+ CRLF
		cQry += "		   		SZM.ZM_FILIAL 	= '" + FWxFilial("SZM") + "'" 	+ CRLF //--FILIAL CORRENTE 
		cQry += "			AND SZM.ZM_INVOICE 	<> ' ' " 						+ CRLF
		cQry += "			AND SZM.ZM_INVOICE 	= '23QR18891015-1' " 			+ CRLF
		cQry +=	"			AND SZM.D_E_L_E_T_ 	= ' ' " 						+ CRLF
		cQry +=	"		ORDER BY SZM.ZM_INVOICE " 								+ CRLF
		cQry +=	" 		) TMP_SZM " 											+ CRLF
		cQry +=	" 		LEFT JOIN (	SELECT	EW4.EW4_INVOIC " 					+ CRLF
		cQry += "		FROM "													+ CRLF
		cQry +=	" 		" + RetSqlName("EW4") + " EW4"   						+ CRLF //--TABELA INVOICE ANTECIPADA (CAPA)
		cQry += "		WHERE "													+ CRLF
		cQry +=	"				EW4.EW4_FILIAL = '" + FWxFilial("EW4") + "'"    + CRLF //--FILIAL CORRENTE
		cQry +=	"			AND EW4.D_E_L_E_T_  = ' ' "							+ CRLF 
		cQry +=	"		) TMP_EW4 " 											+ CRLF 
		cQry +=	"		ON TMP_EW4.EW4_INVOIC = TMP_SZM.ZM_INVOICE "			+ CRLF 
		cQry +=	" 		WHERE TMP_EW4.EW4_INVOIC IS NULL " 						+ CRLF //--SE EW4_INVOIC ESTIVER VAZIO ENTÃO ELE PODE SER DELETADO.
		cQry +=	"		)  " 													+ CRLF 
		
		_nStatus := TcSqlExec(cQry)
		If (_nStatus < 0)
			Conout("Falha na execução do update da tabela SZM, erro :" + TcSqlError() )
			_lRet := .T.
		Else
			_lRet := .F.
		EndIf

	End Transaction

	//Retornar área origianl.
	FwRestArea(aArea)

Return _lRet

//----------------------------------------------------------------------------------

/*

	
			//Excluir linha usando UPDATE.
			cUpdate := " UPDATE " + RetSqlName("SZM") + " " 						+ CRLF 
			cUpdate += " SET D_E_L_E_T_ 	= '*' " 								+ CRLF 
			cUpdate += " , SZM.R_E_C_D_E_L_ = SZM.R_E_C_N_O_ " 						+ CRLF
			cUpdate += " WHERE ZM_FILIAL = '" + FWxfilial("SZM") + " '" 			+ CRLF
			cUpdate += " AND SZM.R_E_C_N_O_ = '" + Alltrim(Str(nSzmRecno)) + "'" 	+ CRLF

	
			//Abrir tabela SZM.
			//DbSelectArea("SZM")
			//SZM->(DbSetOrder(1))

			//Posicion no RECNO da SZM.
			SZM->(DbGoto(nSzmRecno))


	While (cTabela)->(!EoF())
	EndDo

	//Levantar quantos itens tem para serem apagados.
	Count to nTotal
	
	

	oSay:SetText("Iniciando processamento...")
     
    //Contando o total de registros da tabela
    DbSelectArea("SBM")
    SBM-&gt;(DbGoTop())
    Count To nTotal

		
		//Enquanto houver dados na SBM, muda a mensagem de processamento
			nAtual++
        	oSay:SetText("Analisando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
         


	//Ativar a query
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTabela, .T., .T. )
	
	
	DbSelectArea(cTabela)
	//Criar loop para avaliar cada linha da query.
	(cTabela)->(DbGotop())

		
			//Grava RECNO SZM da cTabela.
			nSzmRecno := (cTabela)->SZM_RECNO
				

				
			//Passar para próxima linha
			(cTabela)->(DbSkip())
	
	//Fechar cTabela
	(cTabela)->(DbCloseArea())

			cQry += " 	SELECT * FROM " 		 									+ CRLF
		cQry += " 	( "															+ CRLF
		cQry += "		SELECT DISTINCT " 										+ CRLF 
		cQry += "		SZM.R_E_C_N_O_ AS SZM_RECNO " 							+ CRLF 
		cQry += "		, SZM.ZM_INVOICE " 										+ CRLF 
		cQry += "		FROM "													+ CRLF
		cQry +=	" 		" + RetSqlName("SZM") + " SZM"   						+ CRLF //--TABELA INTEGRAÇÃO XML (CAPA)
		cQry += "		WHERE "													+ CRLF
		cQry += "		   		SZM.ZM_FILIAL 	= '" + FWxFilial("SZM") + "'" 	+ CRLF //--FILIAL CORRENTE 
		cQry += "			AND SZM.ZM_INVOICE 	<> ' ' " 						+ CRLF
		cQry +=	"			AND SZM.D_E_L_E_T_ 	= ' ' " 						+ CRLF
		cQry +=	"	ORDER BY SZM.ZM_INVOICE " 									+ CRLF
		cQry +=	" 	) TMP_SZM " 												+ CRLF
		cQry +=	" 		LEFT JOIN (	SELECT	EW4.EW4_INVOIC " 					+ CRLF
		cQry += "		FROM "													+ CRLF
		cQry +=	" 		" + RetSqlName("EW4") + " EW4"   						+ CRLF //--TABELA INVOICE ANTECIPADA (CAPA)
		cQry += "		WHERE "													+ CRLF
		cQry +=	"				EW4.EW4_FILIAL = '" + FWxFilial("SZM") + "'"    + CRLF //--FILIAL CORRENTE
		cQry +=	"			AND EW4.D_E_L_E_T_  = ' ' "							+ CRLF 
		cQry +=	"	) TMP_EW4 " 												+ CRLF 
		cQry +=	"			ON TMP_EW4.EW4_INVOIC = TMP_SZM.ZM_INVOICE "		+ CRLF 
		cQry +=	" 		WHERE TMP_EW4.EW4_INVOIC IS NULL " 						+ CRLF //--SE EW4_INVOIC ESTIVER VAZIO ENTÃO ELE PODE SER DELETADO.
 */
