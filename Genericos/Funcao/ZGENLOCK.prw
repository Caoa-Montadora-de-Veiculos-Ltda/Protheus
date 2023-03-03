#INCLUDE "PROTHEUS.CH"

/*
================================================================================
Programa.:              ZGENLOCK
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              11/08/2020
Descricao / Objetivo:   Avalia lock de registro
Parametros:             cMsgLock - Grava mensagem de erro em caso de lock
						cAlias - Alias da tabela que sera avaliada
                        aRecnos - Array contendo os recnos que serão avaliados
Doc. Origem:            
Solicitante:            
================================================================================
*/
User Function ZGENLOCK(cMsgLock ,cAlias ,aRecnos)
	Local nI		:= 0
	Local lLock		:= .F.

    Default cMsgLock := ""
    Default cAlias   := ""
    Default aRecnos  := {}

	For nI := 1 To Len(aRecnos)
		(cAlias)->( DbGoTo( aRecnos[nI] ) )
		If (cAlias)->( DBRLock( aRecnos[nI] ) )
			(cAlias)->( DBRUnlock( aRecnos[nI] ) )
		Else
			Conout("VldLock | Encontrou lock na tabela " + cAlias + " | Recno: " + cValToChar(aRecnos[nI]) + Time() )
			lLock := .T.
			cMsgLock := "Lock na tabela " + cAlias + " | Recno: " + cValToChar(aRecnos[nI])
			Exit
		EndIf
	Next

Return lLock
