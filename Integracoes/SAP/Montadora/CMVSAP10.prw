#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

#define CRLF chr( 13 ) + chr( 10  )

/*
	Grava Contas a Pagar para ser enviado ao SAP
	Chamado pelo PE MT103FIM
*/
user function CMVSAP10( nOpc )
	local aAreaX	:= getArea()
	local aAreaSF1	:= SF1->( getArea() )
	local aAreaSD1	:= SD1->( getArea() )
	Local lContinua := .T.
	
	if nOpc == 3 .or. nOpc == 4 // inclusao ou classificacao da nota
	 	/*
	 	SD1->(dbSetOrder(1))
	 	If SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	 		While SD1->(!Eof()) .and. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == ;
	 		SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
	 			If Subs(SD1->D1_CF,1,1) == "3" // importacao
	 				lContinua := .F.
	 				Exit
	 			Endif
	 			SD1->(dbSkip())
	 		Enddo
	 	Endif
	 	*/	
	 				
	 	If lContinua
	 		incSZ7()
	 	Endif	

	 	recLock("SF1" , .F.)
			SF1->F1_XUSR := usrFullName( retCodUsr() )
		SF1->(msUnlock())
	endif

	restArea( aAreaSD1 )
	restArea( aAreaSF1 )
	restArea( aAreaX )
return

/*
	Inclui na tabela SZ7 de integração
*/
static function incSZ7()
	local cQrySF1 := ""

	cQrySF1 := " SELECT" 																									+ CRLF
	cQrySF1 += " A2_COD			,	A2_LOJA			,	A2_NOME			,"													+ CRLF
	cQrySF1 += " F1_DTLANC		,	F1_FORMUL		,	F1_FILIAL		,"													+ CRLF
	cQrySF1 += " F1_LOJA		,	F1_FORNECE		,	F1_SERIE		,	F1_DOC	,"										+ CRLF
	cQrySF1 += " E2_LOJA		,	E2_FORNECE		,	E2_PREFIXO		,	E2_NUM	,"										+ CRLF
	cQrySF1 += " CV3_RECORI		,	CV3.CV3_TABORI	,	CV3.CV3_RECDES	,"													+ CRLF
	cQrySF1 += " CT2.CT2_FILIAL	,	CT2_DATA		,	CT2_LOTE		,	CT2_SBLOTE	,	CT2_DOC	,	CT2_LINHA"			+ CRLF
	cQrySF1 += " FROM		" + retSQLName("SF1") + " SF1"																	+ CRLF
	cQrySF1 += " INNER JOIN	" + retSQLName("SD1") + " SD1"																	+ CRLF
	cQrySF1 += " ON"																										+ CRLF
	cQrySF1 += " 		SF1.F1_LOJA		=	SD1.D1_LOJA"																	+ CRLF
	cQrySF1 += " 	AND	SF1.F1_FORNECE	=	SD1.D1_FORNECE"																	+ CRLF
	cQrySF1 += " 	AND	SF1.F1_SERIE	=	SD1.D1_SERIE"																	+ CRLF
	cQrySF1 += " 	AND	SF1.F1_DOC		=	SD1.D1_DOC"																		+ CRLF
	cQrySF1 += " 	AND	SD1.D1_FILIAL	=	'" + xFilial('SD1') + "'"														+ CRLF
	cQrySF1 += " 	AND	SD1.D_E_L_E_T_	<>	'*'"																			+ CRLF
	cQrySF1 += " INNER JOIN	" + retSQLName("SE2") + " SE2"																	+ CRLF
	cQrySF1 += " ON"																										+ CRLF
	cQrySF1 += " 		SE2.E2_LOJA		=	SF1.F1_LOJA"																	+ CRLF
	cQrySF1 += " 	AND	SE2.E2_FORNECE	=	SF1.F1_FORNECE"																	+ CRLF
	cQrySF1 += " 	AND	SE2.E2_PREFIXO	=	SF1.F1_SERIE"																	+ CRLF
	cQrySF1 += " 	AND	SE2.E2_NUM		=	SF1.F1_DOC"																		+ CRLF
	cQrySF1 += " 	AND	SE2.E2_FILIAL	=	'" + xFilial('SE2') + "'"														+ CRLF
	cQrySF1 += " 	AND	SE2.D_E_L_E_T_	<>	'*'"																			+ CRLF
	cQrySF1 += " INNER JOIN"																								+ CRLF
	cQrySF1 += " 	("																										+ CRLF
	cQrySF1 += " 		SELECT MAX(SUBCV3.R_E_C_N_O_), SUBCV3.CV3_RECORI, SUBCV3.CV3_TABORI, SUBCV3.CV3_FILIAL, CV3_RECDES"	+ CRLF
	cQrySF1 += " 		FROM " + retSQLName("CV3") + " SUBCV3"																+ CRLF
	cQrySF1 += " 		WHERE"																								+ CRLF
	cQrySF1 += " 			SUBCV3.CV3_TABORI	=	'SD1'"																	+ CRLF
	cQrySF1 += " 		AND	SUBCV3.CV3_FILIAL	=	'" + xFilial("CV3") + "'"												+ CRLF
	cQrySF1 += " 		AND	SUBCV3.D_E_L_E_T_	<>	'*'"																	+ CRLF
	cQrySF1 += " 		GROUP BY SUBCV3.CV3_RECORI, SUBCV3.CV3_TABORI, SUBCV3.CV3_FILIAL, CV3_RECDES"						+ CRLF
	cQrySF1 += " 	) CV3"																									+ CRLF
	cQrySF1 += " ON"																										+ CRLF
	cQrySF1 += " 		CV3.CV3_RECORI	=	SD1.R_E_C_N_O_"																	+ CRLF
	cQrySF1 += " 	AND	CV3.CV3_TABORI	=	'SD1'"																			+ CRLF
	cQrySF1 += " 	AND	CV3.CV3_FILIAL	=	'" + xFilial("CV3") + "'"														+ CRLF
	cQrySF1 += " INNER JOIN	" + retSQLName("CT2") + " CT2"																	+ CRLF
	cQrySF1 += " ON"																										+ CRLF
	cQrySF1 += " 		CT2.R_E_C_N_O_	=	CV3.CV3_RECDES"																	+ CRLF
	cQrySF1 += " 	AND	CT2.CT2_FILIAL	=	'" + xFilial('CT2') + "'"														+ CRLF
	cQrySF1 += " 	AND	CT2.D_E_L_E_T_	<>	'*'"																			+ CRLF
	cQrySF1 += " INNER JOIN	" + retSQLName("SA2") + " SA2"																	+ CRLF
	cQrySF1 += " ON"																										+ CRLF
	cQrySF1 += " 		SA2.A2_LOJA		=	F1_LOJA"																		+ CRLF
	cQrySF1 += " 	AND	SA2.A2_COD		=	F1_FORNECE"																		+ CRLF
	cQrySF1 += " 	AND	SA2.A2_FILIAL	=	'" + xFilial('SA2') + "'"														+ CRLF
	cQrySF1 += " 	AND	SA2.D_E_L_E_T_	<>	'*'"																			+ CRLF
	cQrySF1 += " WHERE"																										+ CRLF
	cQrySF1 += " 		SF1.R_E_C_N_O_	=	'" + allTrim( str( SF1->( RECNO() ) ) ) + "'"									+ CRLF
	cQrySF1 += " 	AND	SF1.F1_DTLANC	<>	' '"																			+ CRLF
	cQrySF1 += " 	AND SF1.F1_FILIAL	=	'" + xFilial('SF1') + "'"														+ CRLF
	cQrySF1 += " 	AND	SF1.D_E_L_E_T_	<>	'*'"																			+ CRLF
	cQrySF1 += " ORDER BY CT2.R_E_C_N_O_"																					+ CRLF

	tcQuery cQrySF1 new Alias "QRYSF1"

	if !QRYSF1->(EOF())
		cChvSZ7 := QRYSF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_FORMUL )

		U_ZF11GENSAP(	QRYSF1->F1_FILIAL	,;	// Filial
					"SF1"				 ,;	// Tabela
					"1"					 ,;	// Indice Utilizado
					cChvSZ7				 ,;	// Chave
					1					 ,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
					1					)	// Operação SAP 1=Inclusao;2=cancelamento

		QRYSF1->(DBSkip())
	endif

	QRYSF1->(DBCloseArea())
return
