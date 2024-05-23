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
    RecLock('ZZ4', .T.)
    ZZ4_FILIAL := xFILIAL("ZZ4")
    ZZ4_COD    := SB1->B1_COD
    ZZ4_DESCR  := SB1->B1_DESC
    ZZ4_DATA   := DATE()
    ZZ4_HORA   := TIME()
    ZZ4_INIC   := SB1->B1_IMPORT
    ZZ4_FINAL  := M->B1_IMPORT
    ZZ4_USUR   := __cUserID + " - " + cUserName
    ZZ4_CAMPO  := "B1_IMPORT"
    ZZ4_MOVTO  := "ALTERACAO DO CAMPO B1_IMPORT"
    ZZ4->(MsUnlock())
    IF SX5->X5_TABELA <> "SE"
       cBloqProd   := .T.
    ENDIF
ENDIF
 
IF M->B1_ORIGEM <> SB1->B1_ORIGEM .and. cEmp <> "2010" 
    RecLock('ZZ4', .T.)
    ZZ4_FILIAL := xFILIAL("ZZ4")
    ZZ4_COD    := SB1->B1_COD
    ZZ4_DESCR  := SB1->B1_DESC
    ZZ4_DATA   := DATE()
    ZZ4_HORA   := TIME()
    ZZ4_INIC   := SB1->B1_ORIGEM
    ZZ4_FINAL  := M->B1_ORIGEM
    ZZ4_USUR   := __cUserID + " - " + cUserName
    ZZ4_CAMPO  := "B1_ORIGEM"
    ZZ4_MOVTO := "ALTERACAO DO CAMPOB1_ORIGEM"
    ZZ4->(MsUnlock())
    cBloqProd   := .T.
ENDIF

Return (lExecuta)
