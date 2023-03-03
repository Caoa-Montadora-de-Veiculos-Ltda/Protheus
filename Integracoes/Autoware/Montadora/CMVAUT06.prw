#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"                            

#include "apwebsrv.ch"
#include "apwebex.ch"


//Constantes
#define CRLF chr(13) + chr(10)                               

/*
============================================================================================
Programa.:              CMVAUT06
Autor....:              Marcelo Carneiro         
Data.....:              28/02/2019
Descricao / Objetivo:   Integração Autoware - Recebimento do Emplacamento
Doc. Origem:            não tem.
Solicitante:            Cliente
Obs......:              WS Server.
===============================================================================================
*/

WSSTRUCT AUT06_PLACA
	WSDATA CHASSI       as String
	WSDATA PLACA        as String
	WSDATA CIDADE       as String
	WSDATA UF           as String
ENDWSSTRUCT

WSSTRUCT AUT06_RETORNO
	WSDATA CHASSI  as String
	WSDATA STATUS  as String
	WSDATA MSG	   as String
ENDWSSTRUCT

WSSTRUCT AUT06_RETORNO_ARRAY
	WSDATA RET_CHASSI AS ARRAY OF AUT06_RETORNO
ENDWSSTRUCT

WSSTRUCT AUT06_PLACA_ARRAY
	WSDATA REC_CHASSI AS ARRAY OF AUT06_PLACA
ENDWSSTRUCT


WSSERVICE CMVAUT06 DESCRIPTION "Dados do Emplacamento" 
	WSDATA WSPLACA    AS AUT06_PLACA_ARRAY
	WSDATA WSRETORNO  AS AUT06_RETORNO_ARRAY

	WSMETHOD GerarPlaca DESCRIPTION "Gerar informações da Placa"	
ENDWSSERVICE

WSMETHOD GerarPlaca WSRECEIVE WSPLACA WSSEND WSRETORNO WSSERVICE CMVAUT06

Local cMsg    := ''
Local cStatus := '1'
Local nI      := 0 
Local cChassi := ''
Local cPlaca  := ''
Local cCidade := ''
Local cUF     := ''

dbSelectArea('VV1')
VV1->(dbSetOrder(2))

::WSRETORNO := WSClassNew( "AUT06_RETORNO_ARRAY")
::WSRETORNO:RET_CHASSI := {}

For nI := 1 To Len(::WSPLACA:REC_CHASSI)
	cChassi := Alltrim(::WSPLACA:REC_CHASSI[nI]:CHASSI ) 
	cPlaca  := Alltrim(::WSPLACA:REC_CHASSI[nI]:PLACA  )
	cCidade := Alltrim(::WSPLACA:REC_CHASSI[nI]:CIDADE )
	cUF     := Alltrim(::WSPLACA:REC_CHASSI[nI]:UF     )
	cMsg    := ''
	cStatus := '1'
	

	IF VV1->(dbSeek(xFilial('VV1')+cChassi))
		 RecLock("VV1",.F.)
		 VV1->VV1_XCIDAD := cCidade
		 VV1->VV1_XUFPL  := cUF
		 VV1->VV1_PLAVEI := cPlaca
		 VV1->VV1_XINTEG := 'S'
		 VV1->(MsUnlock())
	     cMsg:= 'Integrado com Sucesso'
	Else
		cMsg    := 'Não Encontrado o CHASSI'
		cStatus := '2'
	EndIF

	aAdd(::WSRETORNO:RET_CHASSI,WSClassNew( "AUT06_RETORNO"))
	::WSRETORNO:RET_CHASSI[nI]:CHASSI    := cChassi
	::WSRETORNO:RET_CHASSI[nI]:STATUS    := cStatus
	::WSRETORNO:RET_CHASSI[nI]:MSG       := cMsg

Next NI



Return .T.     
