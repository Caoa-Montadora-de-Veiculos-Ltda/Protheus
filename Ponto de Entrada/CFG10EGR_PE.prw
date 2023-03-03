
#include "protheus.ch"

/*
=====================================================================================
Programa.:              CFG10EGR
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              18/05/2020
Descricao / Objetivo:   Ponto de Entrada que permite verificar as altera��o dos
                        Paramentros no Protheus
Doc. Origem:            
Solicitante:            CAOA - Montadora - An�polis
Uso......:              SIGACFG
Obs......:
=====================================================================================
*/

User Function CFG10EGR()

Local cCodUser      := ParamIXB[1] //Codigo do Usuario
Local cNomeUser     := ParamIXB[2] //Nome do Usuario
Local cOperacao     := ParamIXB[3] //Operacao ("3"=Inclusao; "4"=Alteracao; "5"=Exclusao)
Local cParametro    := ParamIXB[4] //Parametro
Local aAlt          := ParamIXB[5] //Parametro
Local cNomeOper     := ""   
Local cContOld      := ""
Local cContNovo     := ""

Local cMailDestino  := "evandro.mariano@caoa.com.br"
Local cMailCopia    := ""
Local cAssunto	    := "CFG10EGR - Parametros Protheus"
Local cHtml         := ""
Local aAttach       := ""
Local lMsgErro      := .F.
Local lMsgOK        := .F.
Local cRotina       := "CFG10EGR"
Local cObserva��o   := ""
lOCAL cReplyTo	    := "evandro.mariano@caoa.com.br"
Local lRet          := .F.

If "_PRD" $ AllTrim(GetEnvServer()) .OR. AllTrim(GetEnvServer()) == "PRIME"
    If cOperacao == "3"
        cNomeOper := "INCLUS�O"
    ElseIf cOperacao == "4"
        cNomeOper := "ALTERA��O"
    ElseIf cOperacao == "5"
        cNomeOper := "EXCLUS�O"
    Else
        cNomeOper := "MODIFICA��O N�O IDENTIFICADA"
    EndIf

    If cOperacao == "4"
        cContOld    := AllTrim(aAlt[1][2])
        cContNovo   := AllTrim(aAlt[1][3])
    EndIf

    cHtml := ""
    cHtml +=        "<h4>  Houve uma " + cNomeOper + " nos par�metros do Protheus. </h4> "                      + CRLF
    cHtml +=            "<h4>"                                                                                  + CRLF
    cHtml +=                "  Ambiente: " + AllTrim(GetEnvServer()) + "                            <br/>"      + CRLF
    cHtml +=                "  Tipo: " + cNomeOper + "                                              <br/>"      + CRLF
    cHtml +=                "  Usu�rio: " + cCodUser + " - " + cNomeUser + "                        <br/><br/>" + CRLF
    cHtml +=                "  Par�metro: " + cParametro + "                                        <br/>"      + CRLF
    If cOperacao == "4"
        cHtml +=            "  Conte�do Antigo: " + cContOld + "                                    <br/>"      + CRLF
        cHtml +=            "  Conte�do Novo: " + cContNovo + "                                     <br/>"      + CRLF
    EndIf
    cHtml +=                "  Data da execu��o: " + dtoc(date())  + " " + time() + "               <br/><br/>" + CRLF
    cHtml +=            "</h4>"                                                                                 + CRLF
    cHtml +=    " <h5>Esse email foi gerado pela rotina CFG10EGR </h5>"

    lRet := u_ZGENMAIL(cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,cRotina,	cObserva��o	, cReplyTo	)

EndIf

Return Nil