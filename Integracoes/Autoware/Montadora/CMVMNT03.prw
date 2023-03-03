#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*
=====================================================================================
Programa............: CMVMNT03
Autor...............: Marcelo Carneiro
Data................: 11/10/2018 
Descricao / Objetivo: Monitor de Integração
Doc. Origem.........: Contrato 
Solicitante ........: Cliente
Uso.................: CAOA
Obs.................: Cadastro de Tipos de  Integrações
=====================================================================================
*/

User Function CMVMNT03()

Local cVldAlt := ".T." // Operacao: ALTERACAO
Local cVldExc := ".T." // Operacao: EXCLUSAO
Local cAlias  := "SZ3"

chkFile(cAlias)
dbSelectArea(cAlias)

dbSetOrder(1)
axCadastro(cAlias, "Cadastro de Tipo de Integrações", cVldExc, cVldAlt)

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
		MsgAlert('Combinação de tipo de integração já cadastrada!!!')
		bRet := .F.
	EndIF          
Else
	dbSelectArea('SZ2')
	SZ2->(dbSetOrder(1))
	IF SZ2->(dbSeek(xFilial('SZ2')+M->Z3_CODINTG))
		MsgAlert('Integração não Cadastrada !!!')
		bRet := .F.
	EndIF          
EndIF
Return bRet
