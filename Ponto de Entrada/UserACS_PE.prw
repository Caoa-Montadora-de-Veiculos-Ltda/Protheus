#include "protheus.ch"

User Function UserACS()

Local cUser     := ParamIXB[1]
Local cUserLog  := RetCodUsr()
Local cAction	:= PARAMIXB[4]

Local cMailDestino  := "evandro.mariano@caoa.com.br"
Local cMailCopia    := ""
Local cAssunto	    := "UserACS - Usu�rios"
Local cHtml         := ""
Local aAttach       := ""
Local lMsgErro      := .F.
Local lMsgOK        := .F.
Local cRotina       := "UserACS"
Local cObserva��o   := ""
lOCAL cReplyTo	    := "evandro.mariano@caoa.com.br"
Local lRet          := .F.

If cAction == "INCLUI"	

    cHtml := " "
    cHtml +=        " <h4>  Houve uma INCLUS�O de Usu�rio no Protheus. </h4> "                                              + CRLF
    cHtml +=            " <h4> "                                                                                            + CRLF
    cHtml +=                "  Ambiente: " + AllTrim(GetEnvServer()) + " <br/> "                                            + CRLF
    cHtml +=                "  Tipo: ALTERA��O <br/> "                                                                      + CRLF
    cHtml +=                "  Usu�rio Inclu�do: " + cUser + " - " + AllTrim ( UsrFullName ( cUser ) )  + " <br/><br/> "    + CRLF
    cHtml +=                "  Quem Incluiu: " + cUserLog + " - " + AllTrim ( UsrFullName ( cUserLog ) )  + " <br/><br/> "  + CRLF
    cHtml +=                "  Data da execu��o: " + dtoc(date())  + " " + time() + "               <br/><br/> "            + CRLF
    cHtml +=            " </h4> "                                                                                           + CRLF
    cHtml +=    " <h5> Esse email foi gerado pela rotina UserACS_PE </h5> "
    
    lRet := u_ZGENMAIL(cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,cRotina,	cObserva��o	, cReplyTo	)

ElseIf cAction == "ALTERA"	
    
    cHtml := " "
    cHtml +=        " <h4>  Houve uma ALTERA��O de Usu�rio no Protheus. </h4> "                                             + CRLF
    cHtml +=            " <h4> "                                                                                            + CRLF
    cHtml +=                "  Ambiente: " + AllTrim(GetEnvServer()) + " <br/> "                                            + CRLF
    cHtml +=                "  Tipo: ALTERA��O <br/> "                                                                      + CRLF
    cHtml +=                "  Usu�rio Alterado: " + cUser + " <br/><br/> "                                                 + CRLF
    cHtml +=                "  Quem Alterou: " + cUserLog + " - " + AllTrim ( UsrFullName ( cUserLog ) )  + " <br/><br/> "  + CRLF
    cHtml +=                "  Data da execu��o: " + dtoc(date())  + " " + time() + "               <br/><br/> "            + CRLF
    cHtml +=            " </h4> "                                                                                           + CRLF
    cHtml +=    " <h5> Esse email foi gerado pela rotina UserACS_PE </h5> "

    lRet := u_ZGENMAIL(cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,cRotina,	cObserva��o	, cReplyTo	)

EndIf

Return Space(10)
