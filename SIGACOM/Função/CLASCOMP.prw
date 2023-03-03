#Include 'Protheus.Ch'
#Include 'Totvs.Ch'

/*/{Protheus.doc} CLASCOMP
Classe de Funções - CAOA
@author FSW - DWC Consult
@since 21/03/2019
@version 1.0
@type class
/*/
CLASS CLASCOMP

Data lConfirma	As Logical

Method New() CONSTRUCTOR

Method HistAlteracao()		//Methodo para apresentar o historico de alteração configurado via tabela SXP.

ENDCLASS

/*/{Protheus.doc} New
Declaração do New do Method CLASCOMP
@author FSW - DWC Consult
@since 21/03/2019
@version 1.0
@type function
/*/
Method New() Class CLASCOMP

	::lConfirma := .F.

Return

/*/{Protheus.doc} HistAlteracao
Method para consultar \ apresentar as alterações efetuadas nas tabelas, conforme parametrização da tabela SXP.
@author FSW - DWC Consult
@since 21/03/2019
@version 1.0
@param cChave, characters, descricao
@param cTitulo, characters, descricao
@param lInclui, logical, descricao
@param lAltera, logical, descricao
@param lExclui, logical, descricao
@type function
/*/
Method HistAlteracao(cChave,cTitulo,lInclui,lAltera,lExclui) Class CLASCOMP
	Local cAliSXP	:= GetNextAlias()
	Local cQuery	:= ""
	Local cTipo		:= ""
	Local nOpcXP	:= 0
	Local nRegXP	:= 0
	Local aDadosSXP	:= {}
	Local oSXP		:= Nil
	Local oDlg		:= Nil

	Default cTitulo := "Histórico de Atualização"
	Default lInclui := .F.
	Default lAltera := .F.
	Default lExclui := .F.
	Default lAmbos  := .T.

	If Empty(cChave)
		MsgAlert("Chave de busca não informada.","Falha na Consulta")
		Return
	EndIf

	//Tratamento para as possibilidades de monitoramento dos campos.
	If lInclui .And. !lAltera .And. !lExclui
		nOpcXP := 64
	ElseIf !lInclui .And. lAltera .And. !lExclui
		nOpcXP := 128
	ElseIf !lInclui .And. !lAltera .And. lExclui
		nOpcXP := 256
	ElseIf lInclui .And. lAltera .And. !lExclui
		nOpcXP := 192
	ElseIf lInclui .And. !lAltera .And. lExclui
		nOpcXP := 320
	ElseIf !lInclui .And. lAltera .And. lExclui
		nOpcXP := 384
	Else
		nOpcXP := 448
	EndIf

	//----- CONSULTA SXP -----//
	If Select(cAliSXP) > 0
		(cAliSXP)->(DbCloseArea())
	Endif
	cQuery := "SELECT * FROM " + RetSqlName("SXP") + " X "
	cQuery += "WHERE "
	cQuery += "X.D_E_L_E_T_='' "
	cQuery += "AND X.XP_UNICO LIKE '" + cChave + "%' "
	cQuery += "AND X.XP_OPER = " + CValToChar(nOpcXP) + " "
	cQuery += "ORDER BY "
	cQuery += "XP_DATA DESC "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliSXP,.F.,.T.)
	Count To nRegXP

	If nRegXP > 0
		(cAliSXP)->(DbGoTop())

		While !(cAliSXP)->(EOF())
			
			If Empty((cAliSXP)->XP_ANTVAL)
				cTipo := "Inclusão"
			Else
				cTipo := "Alteração"
			EndIf
		
			aAdd(aDadosSXP,{cTipo,SToD((cAliSXP)->XP_DATA), (cAliSXP)->XP_USER, (cAliSXP)->XP_CAMPO, (cAliSXP)->XP_ANTVAL, (cAliSXP)->XP_NOVVAL})

			(cAliSXP)->(DbSkip())
		Enddo
		(cAliSXP)->(DbCloseArea())

		DEFINE MSDIALOG oDLG TITLE cTitulo FROM 0,0 TO 400,1010 OF oMainWnd PIXEL 

		oSXP := TWBrowse():New(000,000,000,000,,{'Tipo','Data','Usuário','Campo Alt.',"Vl.Anterior","Vl. Atual"},{30,50,50,50,50,50},oDlg,,,,,,,,,,,,,,.T.,,,,,)
		oSXP:Align := CONTROL_ALIGN_ALLCLIENT
		oSXP:SetArray(aDadosSXP)
		oSXP:bLine := {|| { aDadosSXP[oSXP:nAt][1],;
							aDadosSXP[oSXP:nAt][2],; 
							aDadosSXP[oSXP:nAt][3],;
							aDadosSXP[oSXP:nAt][4],;
							aDadosSXP[oSXP:nAt][5],;
							aDadosSXP[oSXP:nAt][6]}}

		ACTIVATE MSDIALOG oDLG CENTERED
	Else
		MsgInfo("Histórico inexistente para este registro.","Atenção!")
	Endif

Return