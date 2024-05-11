#include 'parmtype.ch'
#include 'TOPCONN.CH'
#include 'protheus.ch'
#include "TBICONN.CH"


/*
=====================================================================================
Programa.:              ZFISF001
Autor....:              Valter Carvalho
Data.....:              29/01/2019
Descricao / Objetivo:   interface para a chamada do fonte ZFISF002
Doc. Origem:
Solicitante:            Fabio Giacomozzi <fabio@caoa.com.br>
Uso......:              
Obs......:              
=====================================================================================
*/

User function ZFISF001()
	Local cRes		:= ""
	Local oProcess
	Local dDt		:= iif(Empty(getmv("MV_ULMES")), ctod("01/01/20") , getmv("MV_ULMES")+1 )

	If !Empty(RetCodUsr())
		If ! U_ZGENUSER( RetCodUsr(),"ZFISF002", .T.)
			Return "User sem acesso"
		EndIf
	EndIf		

	cMsg := ;
		" Essa rotina irá gerar arquivos para Auditto das notas fiscais não" + CRLF +;
		" exportadas a partir da data do último fechamento de movimento,"	 + CRLF +;
		" defindo em MV_ULMES: " + Dtoc(dDt)	                             + CRLF +;
		" Deseja continuar ?"

	if MsgYesNo(cMsg, "ZFISF001")
		oProcess := MsNewProcess():New({|lEnd| cRes := u_ZFISF002({AllTrim(FWCodEmp()), cFilAnt, dTos(dDt)}, @oProcess )},"","Geração de arquivos", .F.)
		oProcess:Activate()
	EndIf

	MsgAlert(cRes) // mostra mensagem de execução

Return cRes
