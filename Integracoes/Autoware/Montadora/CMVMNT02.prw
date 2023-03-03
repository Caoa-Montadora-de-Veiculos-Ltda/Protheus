#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*
=====================================================================================
Programa............: CMVMNT02
Autor...............: Marcelo Carneiro
Data................: 11/10/2018 
Descricao / Objetivo: Monitor de Integra��o
Doc. Origem.........: Contrato 
Solicitante ........: Cliente
Uso.................: CAOA
Obs.................: Cadastro das Integra��es
=====================================================================================
*/

User Function CMVMNT02()
	
Local cVldAlt := ".T." // Operacao: ALTERACAO
Local cVldExc := ".T." // Operacao: EXCLUSAO
Local cAlias

chkFile('SZ1')
chkFile('SZ2')
chkFile('SZ3')

cAlias := "SZ2"
chkFile(cAlias)
dbSelectArea(cAlias)

dbSetOrder(1)
axCadastro(cAlias, "Cadastro de Integra��es", cVldExc, cVldAlt)

Return

/*
========================================================
Valida codigo da SZ2
========================================================
*/
User Function VLD_SZ2COD()  
	
Local bRet := .T.


IF SZ2->(dbSeek(xFilial('SZ2')+M->Z2_CODIGO))
	MsgAlert('C�digo de integra��o j� cadastrado!!!')
	bRet := .F.
EndIF          

return bRet