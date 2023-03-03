
#include "protheus.ch"

/*
=====================================================================================
Programa.:              CFG10EGR
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              18/05/2020
Descricao / Objetivo:   Ponto de Entrada que permite verificar as alteração dos
                        Paramentros no Protheus
Doc. Origem:            
Solicitante:            CAOA - Montadora - Anápolis
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
Local cObservação   := ""
lOCAL cReplyTo	    := "evandro.mariano@caoa.com.br"
Local lRet          := .F.

If "_PRD" $ AllTrim(GetEnvServer()) .OR. AllTrim(GetEnvServer()) == "PRIME"
    If cOperacao == "3"
        cNomeOper := "INCLUSÃO"
    ElseIf cOperacao == "4"
        cNomeOper := "ALTERAÇÃO"
    ElseIf cOperacao == "5"
        cNomeOper := "EXCLUSÃO"
    Else
        cNomeOper := "MODIFICAÇÃO NÃO IDENTIFICADA"
    EndIf

    If cOperacao == "4"
        cContOld    := AllTrim(aAlt[1][2])
        cContNovo   := AllTrim(aAlt[1][3])
    EndIf

    cHtml := ""
    cHtml +=        "<h4>  Houve uma " + cNomeOper + " nos parâmetros do Protheus. </h4> "                      + CRLF
    cHtml +=            "<h4>"                                                                                  + CRLF
    cHtml +=                "  Ambiente: " + AllTrim(GetEnvServer()) + "                            <br/>"      + CRLF
    cHtml +=                "  Tipo: " + cNomeOper + "                                              <br/>"      + CRLF
    cHtml +=                "  Usuário: " + cCodUser + " - " + cNomeUser + "                        <br/><br/>" + CRLF
    cHtml +=                "  Parâmetro: " + cParametro + "                                        <br/>"      + CRLF
    If cOperacao == "4"
        cHtml +=            "  Conteúdo Antigo: " + cContOld + "                                    <br/>"      + CRLF
        cHtml +=            "  Conteúdo Novo: " + cContNovo + "                                     <br/>"      + CRLF
    EndIf
    cHtml +=                "  Data da execução: " + dtoc(date())  + " " + time() + "               <br/><br/>" + CRLF
    cHtml +=            "</h4>"                                                                                 + CRLF
    cHtml +=    " <h5>Esse email foi gerado pela rotina CFG10EGR </h5>"

    lRet := u_ZGENMAIL(cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,cRotina,	cObservação	, cReplyTo	)

EndIf

Return Nil