#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*
=====================================================================================
Programa............: CMVMNT03
Autor...............: Marcelo Carneiro
Data................: 11/10/2018 
Descricao / Objetivo: Monitor de Integra��o
Doc. Origem.........: Contrato 
Solicitante ........: Cliente
Uso.................: CAOA
Obs.................: Cadastro de Tipos de  Integra��es
=====================================================================================
*/

User Function CMVMNT03()

Local cVldAlt := ".T." // Operacao: ALTERACAO
Local cVldExc := ".T." // Operacao: EXCLUSAO
Local cAlias  := "SZ3"

chkFile(cAlias)
dbSelectArea(cAlias)

dbSetOrder(1)
axCadastro(cAlias, "Cadastro de Tipo de Integra��es", cVldExc, cVldAlt)

Return

/*
========================================================
Valida codigo da SZ3
========================================================
*/
User Function VLD_SZ3COD(nTipo)  

Local bRet := .T.

IF nTipo == 1 
	IF SZ3->(dbSeek(xFilial('SZ3')+M->Z3_CODINTG+M->Z3_CODTINT))
		MsgAlert('Combina��o de tipo de integra��o j� cadastrada!!!')
		bRet := .F.
	EndIF          
Else
	dbSelectArea('SZ2')
	SZ2->(dbSetOrder(1))
	IF SZ2->(dbSeek(xFilial('SZ2')+M->Z3_CODINTG))
		MsgAlert('Integra��o n�o Cadastrada !!!')
		bRet := .F.
	EndIF          
EndIF
Return bRet
