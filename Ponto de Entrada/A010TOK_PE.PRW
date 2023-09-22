#include "protheus.ch"
#include "parmtype.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "Totvs.Ch"

/*
=====================================================================================
Programa............: A010TOK
Autor...............: Sandro Ferreira
Data................: 21/09/2023
Descricao / Objetivo: Ponto de entrada para Validação na inclusão ou alteração do produto
Doc. Origem.........: workflow do cadastro de produtos
Solicitante.........: Andre Batista
Uso.................: CAOA
Obs.................: 
=====================================================================================
*/

User Function A010TOK()
Local lExecuta     := .T.// Validações do usuário para inclusão ou alteração do produto
Local cEmp         := FWCodEmp()
Public cBloqProd   := .F.

IF M->B1_IMPORT <> SB1->B1_IMPORT .and. cEmp <> "2010" 
    RecLock('ZZN', .T.)
    ZZN_FILIAL := xFILIAL("ZZN")
    ZZN_COD    := SB1->B1_COD
    ZZN_DESCR  := SB1->B1_DESC
    ZZN_DATA   := DATE()
    ZZN_HORA   := TIME()
    ZZN_INIC   := SB1->B1_IMPORT
    ZZN_FINAL  := M->B1_IMPORT
    ZZN_USUR   := __cUserID + " - " + cUserName
    ZZN_CAMPO  := "B1_IMPORT"
    ZZN_MOVTO  := "ALTERACAO DO CAMPO B1_IMPORT"
    ZZN->(MsUnlock())
    cBloqProd   := .T.
ENDIF

IF M->B1_ORIGEM <> SB1->B1_ORIGEM .and. cEmp <> "2010" 
    RecLock('ZZN', .T.)
    ZZN_FILIAL := xFILIAL("ZZN")
    ZZN_COD    := SB1->B1_COD
    ZZN_DESCR  := SB1->B1_DESC
    ZZN_DATA   := DATE()
    ZZN_HORA   := TIME()
    ZZN_INIC   := SB1->B1_ORIGEM
    ZZN_FINAL  := M->B1_ORIGEM
    ZZN_USUR   := __cUserID + " - " + cUserName
    ZZN_CAMPO  := "B1_ORIGEM"
    ZZN_MOVTO := "ALTERACAO DO CAMPOB1_ORIGEM"
    ZZN->(MsUnlock())
    cBloqProd   := .T.
ENDIF

Return (lExecuta)
