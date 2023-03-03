#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
=====================================================================================
Programa.:              ZCFGF001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              04/09/2019
Descricao / Objetivo:   Atualização da Base de Dados a Quente
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
User Function ZCFGF001()

Local lUserAut      := .F.
Private cTabela	:= Space(3)
Private oDlg		// Dialog Principal
Private oTabela

Default cTab		:= ""

			//  U_ZGENUSER( <ID User> , <"NOME DA FUNÇÃO"> , <.F.=Não Exibe Msg; .T.=Exibe Msg> )
lUserAut := U_ZGENUSER( RetCodUsr() ,"ZCFGF001"	,.T.)

If lUserAut
	If Empty(cTab)
		
		DEFINE MSDIALOG oDlg TITLE "[ ZCFGF001 ] - Digite a tabela que deseja atualizar" FROM C(178),C(160) TO C(329),C(450) PIXEL
		
		@ C(005),C(006) TO C(061),C(140) LABEL "Digite a tabela" PIXEL OF oDlg
		
		@ C(022),C(020) Say "Tabela:" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(030),C(020) MsGet oTabela VAR cTabela SIZE C(050), C(010) Picture "@!" COLOR CLR_BLACK Valid fValid() Pixel Of oDlg
		
		DEFINE SBUTTON FROM C(065),C(068) TYPE 1 ENABLE OF oDlg ACTION ( Processa( { || fAtualiz() }	,"[ ZCFGF001 ] - Atualizando Base de Dados..." )	,oDlg:End() )
		DEFINE SBUTTON FROM C(065),C(098) TYPE 2 ENABLE OF oDlg ACTION ( oDlg:End() )
		
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		cTabela := cTab
		fAtualiz(.T.)
	EndIf
EndIf

Return()

/*
=====================================================================================
Programa.:              fAtualiz
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              04/09/2019
Descricao / Objetivo:   Atualização da Base de Dados a Quente
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function fAtualiz(lAuto)

Local cComand2 := ""
Local cChkFile	:= ""
Local lRet		:= .T.

Default lAuto	:= .F.

cComand2 := "X31UpdTable( '"+cTabela+"' )"
cChkFile := "ChkFile( '"+cTabela+"' )"

If lAuto

	__setx31mode(.F.)
	&cComand2               
	
	//Caso o comando anterior tenha encontrado a tabela em uso a funcao abaixo ira retornar o erro
	If __GetX31Error()
		Conout( "[ ZCFGF001 ] - TABELA: " + cTabela + " - "  + __GetX31Trace() )
		lRet := .F.
	Endif
	
	__setx31mode(.T.)

	If lRet
		//Executa o CHKFILE em caso de criacao de novo indice eh necessario
		If !(&cChkFile)
			Conout( "[ ZCFGF001 ] - CHKFILE: " + cTabela + " - "  + "Falha na execução do CHKFILE, verifique se a atualização ocorreu." )
		EndIf
	EndIf
Else
	//Verifica se deseja realmente atualizar o dicionario de dados a quente
	If ApMsgYesNo( "Deseja realmente atualizar o dicionário de dados da tabela " + cTabela + " ?","[ ZCFGF001 ] - Confirma a operação?" )
		
		ApMsgAlert( "Atenção este processo será executado com êxito somente se a tabela digitada não estiver em uso.","[ ZCFGF001 ] - Aviso" )
		
		__setx31mode(.F.)
		&cComand2
		
		//Caso o comando anterior tenha encontrado a tabela em uso a funcao abaixo ira retornar o erro
		If __GetX31Error()
			ApMsgStop( __GetX31Trace()	,"Retorno da execução" )
			lRet := .F.
		Else
			ApMsgInfo( "Processo executado com sucesso"	,"[ ZCFGF001 ] - Finalizado" )
		Endif
		
		__SetX31Mode(.T.)
		
		If lRet
			//Executa o CHKFILE em caso de criacao de novo indice eh necessario
			If !(&cChkFile)
				ApMsgAlert( "Falha na execução do CHKFILE, verifique se a atualização ocorreu.","[ ZCFGF001 ] - Atenção" )
			EndIf
		EndIf
		
	EndIf
EndIf

Return()

/*
=====================================================================================
Programa.:              fValid
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              04/09/2019
Descricao / Objetivo:   Valida se a tabela existe na SX2
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function fValid()

Local _aArea	:= GetArea()
Local _aAreaX2	:= SX2->(GetArea())
Local lRet		:= .T.

DbSelectArea("SX2")
SX2->(dbSetOrder(1))	//X2_CHAVE
If !SX2->(DbSeek(cTabela))
	ApMsgStop( "Tabela "+cTabela+" não encontrada, favor verificar.","[ ZCFGF001 ] - Tabela inconsistente" )
	lRet := .F.
EndIf

RestArea(_aAreaX2)
RestArea(_aArea)

Return()

/*
=====================================================================================
Programa.:              C
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              04/09/2019
Descricao / Objetivo:   Monta tamanho da Tela
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
Static Function C(nTam)

Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

Return Int(nTam)
