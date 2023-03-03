#include "protheus.ch"

User Function UserACS()

Local cUser     := ParamIXB[1]
Local cUserLog  := RetCodUsr()
Local cAction	:= PARAMIXB[4]

Local cMailDestino  := "evandro.mariano@caoa.com.br"
Local cMailCopia    := ""
Local cAssunto	    := "UserACS - Usuários"
Local cHtml         := ""
Local aAttach       := ""
Local lMsgErro      := .F.
Local lMsgOK        := .F.
Local cRotina       := "UserACS"
Local cObservação   := ""
lOCAL cReplyTo	    := "evandro.mariano@caoa.com.br"
Local lRet          := .F.

If cAction == "INCLUI"	

    cHtml := " "
    cHtml +=        " <h4>  Houve uma INCLUSÃO de Usuário no Protheus. </h4> "                                              + CRLF
    cHtml +=            " <h4> "                                                                                            + CRLF
    cHtml +=                "  Ambiente: " + AllTrim(GetEnvServer()) + " <br/> "                                            + CRLF
    cHtml +=                "  Tipo: ALTERAÇÃO <br/> "                                                                      + CRLF
    cHtml +=                "  Usuário Incluído: " + cUser + " - " + AllTrim ( UsrFullName ( cUser ) )  + " <br/><br/> "    + CRLF
    cHtml +=                "  Quem Incluiu: " + cUserLog + " - " + AllTrim ( UsrFullName ( cUserLog ) )  + " <br/><br/> "  + CRLF
    cHtml +=                "  Data da execução: " + dtoc(date())  + " " + time() + "               <br/><br/> "            + CRLF
    cHtml +=            " </h4> "                                                                                           + CRLF
    cHtml +=    " <h5> Esse email foi gerado pela rotina UserACS_PE </h5> "
    
    lRet := u_ZGENMAIL(cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,cRotina,	cObservação	, cReplyTo	)

ElseIf cAction == "ALTERA"	
    
    cHtml := " "
    cHtml +=        " <h4>  Houve uma ALTERAÇÃO de Usuário no Protheus. </h4> "                                             + CRLF
    cHtml +=            " <h4> "                                                                                            + CRLF
    cHtml +=                "  Ambiente: " + AllTrim(GetEnvServer()) + " <br/> "                                            + CRLF
    cHtml +=                "  Tipo: ALTERAÇÃO <br/> "                                                                      + CRLF
    cHtml +=                "  Usuário Alterado: " + cUser + " <br/><br/> "                                                 + CRLF
    cHtml +=                "  Quem Alterou: " + cUserLog + " - " + AllTrim ( UsrFullName ( cUserLog ) )  + " <br/><br/> "  + CRLF
    cHtml +=                "  Data da execução: " + dtoc(date())  + " " + time() + "               <br/><br/> "            + CRLF
    cHtml +=            " </h4> "                                                                                           + CRLF
    cHtml +=    " <h5> Esse email foi gerado pela rotina UserACS_PE </h5> "

    lRet := u_ZGENMAIL(cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,cRotina,	cObservação	, cReplyTo	)

EndIf

Return Space(10)
