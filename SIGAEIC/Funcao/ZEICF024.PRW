#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TopConn.Ch"

/*/{Protheus.doc} ZEICF024
@type		Function
@version	1.0
@author     Nicolas Lima
@since      26/09/2023
@project    GRUPO CAOA GAP082 - Excluir SZM na exclusão da Invoice Antecipada.
@Obs        Objetivo: Apagar itens da SZM que deveriam ter sido estornados porém não foram, são itens que já estão excluídos na EW4 e EW5
/*/

//----------------------------------------------------------------------------------

User Function ZEICF024()
	Private _lRet := .F.
	
	//Perguntar se o usuário deseja continuar.
	If MsgYesNo("Esta rotina limpa todos os resquícios de estorno de Invoice que ficaram ativos na tabela SZM. " + CRLF ;
				+ CRLF + "Deseja continuar?" )
		FwMsgRun(,{ |_oSay| zUpdate(_oSay) }, "Processando", "Limpando tabela SZM, por favor aguarde...")  
	Else
		MsgStop("Operação cancelada pelo usuário.")
	EndIf	

	If _lRet
		MsgInfo("Alteração realizada com sucesso!")
	Else
		MsgStop("Erro! " + CRLF + "Alteração não concluída.")
	EndIf

Return

//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------

Static Function zUpdate(_oSay)

    Local aArea 	:= GetArea()
	Local cQry      := " "
	Local cQry1     := " "
	Local cQry2     := " "
	Local cUpdt     := " "
	Local _nStatus 	:= 0
	Local cTabela	:= GetNextAlias()

	Begin Transaction	

		//Pesquisar itens que devem ser limpos através da query
		cQry += " 	UPDATE " + RetSqlName("SZM") + " SZM" 		 				+ CRLF
		cQry += " 	SET D_E_L_E_T_ 	= '*' "										+ CRLF
		cQry += "	, SZM.R_E_C_D_E_L_ = SZM.R_E_C_N_O_ "						+ CRLF 
		cQry += "		WHERE "													+ CRLF
		cQry += "		SZM.ZM_FILIAL 	= '" + FWxFilial("SZM") + "'" 			+ CRLF //--FILIAL CORRENTE 
		cQry += "		AND SZM.ZM_INVOICE  IN ( "								+ CRLF
		cQry1 += "		SELECT TMP_SZM.ZM_INVOICE FROM "						+ CRLF 
		cQry1 += "		(SELECT DISTINCT "										+ CRLF
		cQry1 += "			SZM.ZM_INVOICE "									+ CRLF
		cQry1 += "		FROM "													+ CRLF
		cQry1 +=	" 		" + RetSqlName("SZM") + " SZM"   						+ CRLF //--TABELA INTEGRAÇÃO XML (CAPA)
		cQry1 += "		WHERE "													+ CRLF
		cQry1 += "		   		SZM.ZM_FILIAL 	= '" + FWxFilial("SZM") + "'" 	+ CRLF //--FILIAL CORRENTE 
		cQry1 += "			AND SZM.ZM_INVOICE 	<> ' ' " 						+ CRLF
		cQry1 +=	"			AND SZM.D_E_L_E_T_ 	= ' ' " 						+ CRLF
		cQry1 +=	"		ORDER BY SZM.ZM_INVOICE " 								+ CRLF
		cQry1 +=	" 		) TMP_SZM " 											+ CRLF
		cQry1 +=	" 		LEFT JOIN (	SELECT	EW4.EW4_INVOIC " 					+ CRLF
		cQry1 += "		FROM "													+ CRLF
		cQry1 +=	" 		" + RetSqlName("EW4") + " EW4"   						+ CRLF //--TABELA INVOICE ANTECIPADA (CAPA)
		cQry1 += "		WHERE "													+ CRLF
		cQry1 +=	"				EW4.EW4_FILIAL = '" + FWxFilial("EW4") + "'"    + CRLF //--FILIAL CORRENTE
		cQry1 +=	"			AND EW4.D_E_L_E_T_  = ' ' "							+ CRLF 
		cQry1 +=	"		) TMP_EW4 " 											+ CRLF 
		cQry1 +=	"		ON TMP_EW4.EW4_INVOIC = TMP_SZM.ZM_INVOICE "			+ CRLF 
		cQry1 +=	" 		WHERE TMP_EW4.EW4_INVOIC IS NULL " 						+ CRLF //--SE EW4_INVOIC ESTIVER VAZIO ENTÃO ELE PODE SER DELETADO.
		cQry2 +=	"		)  " 													+ CRLF 
		cUpdt := cQry + cQry1 + cQry2 

		DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry1), cTabela, .T., .T. )
		Count To nTotal
		(cTabela)->(DbCloseArea())

		_nStatus := TcSqlExec(cUpdt)
		If (_nStatus < 0)
			Conout("Falha na execução do update da tabela SZM, erro :" + TcSqlError() )
			_lRet := .F.
			DisarmTransaction()
		Else
			_lRet := .T.
			MsgInfo("Total de invoices alterados: " + AllTrim(cValToChar(nTotal)) + ".")
		EndIf

	End Transaction

	//Retornar área original.
	FwRestArea(aArea)

Return _lRet

//----------------------------------------------------------------------------------
