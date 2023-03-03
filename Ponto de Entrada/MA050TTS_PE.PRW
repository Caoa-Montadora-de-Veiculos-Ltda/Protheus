#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

#define CRLF chr(13) + chr(10)

/*
=====================================================================================
Programa............: MA050TTS
Autor...............: Marcelo Carneiro
Data................: 18/06/2019
Descricao / Objetivo: Ponto de entrada para o cadastro de Transportadora SIlt
Doc. Origem.........: Integra��o SILT para marcar o campo como Integra.
Solicitante.........: Cliente
Uso.................: CAOA
Obs.................: 
=====================================================================================
*/

User Function MA050TTS(nOpc)

If ALTERA .OR. INCLUI
	RecLock("SA4", .F.)
	//SA4->A4_XSILST  := 'N'
	SA4->(MsUnlock())
EndIF         

Return .T.