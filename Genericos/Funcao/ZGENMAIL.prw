#INCLUDE "Protheus.ch"
#INCLUDE "Totvs.Ch"

/*
=====================================================================================
Programa.:              ZGENMAIL
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              28/06/19
Descricao / Objetivo:   Função para enviar e-mail
Doc. Origem:
Solicitante:            TI
Uso......:
Obs......:
=====================================================================================
*/
User Function ZGENMAIL(	Param01		,Param02	,Param03	,Param04	,Param05	,Param06	,Param07	,Param08, 	Param09		, Param10	)
	//		  		  (cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,Rotina,	Observação	, cReplyTo	)

	Local oMailServer 	:= Nil
	Local cRotina		:= Param08
	Local nSMTPPort   	:= IIF(cRotina == "CFG10EGR", 0, GetMV("MV_PORSMTP"))   			// Porta SMTP.
	Local cSMTPAddr   	:= IIF(cRotina == "CFG10EGR", "smtp.caoa.com.br:587", AllTrim( GetMV("MV_RELSERV") ))  	// Endereco SMTP.
	Local cUserAut     	:= IIF(cRotina == "CFG10EGR", "caoa_totvs_prd@caoa.com.br", AllTrim( GetMV("MV_RELACNT") )) 	// Conta a ser utilizada no envio de E-Mail para os relatorios.
	Local cPassAut     	:= IIF(cRotina == "CFG10EGR", "C@0AT0tvs*!", GetMV("MV_RELPSW"))  				// Senha da Conta de E-Mail para envio de relatorios.
	Local lAutentica  	:= IIF(cRotina == "CFG10EGR", .T., GetMV("MV_RELAUTH")) 				// Servidor de EMAIL necessita de Autenticacao?
	Local nSMTPTime	  	:= IIF(cRotina == "CFG10EGR", 120, GetMV("MV_RELTIME")) 				// Timeout no Envio de EMAIL.
	Local lSSL        	:= IIF(cRotina == "CFG10EGR", .F., GetMV("MV_RELSSL"))  				// Define se o envio e recebimento de e-mails na rotina SPED utilizara conexao segura (SSL).
	Local lTLS        	:= IIF(cRotina == "CFG10EGR", .F., GetMV("MV_RELTLS"))  				// Informe se o servidor de SMTP possui conexao do tipo segura ( SSL/TLS ).
	Local nError      	:= 0  								// Controle de Erro.
	Local nPortAddSrv 	:= 0
	Local nX          	:= 0
	Local lRetorno    	:= .F.
	Local xRet			:= .T.
	Local lMsgErro		:= Param06
	Local lMsgOk		:= Param07
	Local cAnexos		:= ""
	Local cObsMail		:= Param09
	Local cSendError	:= ""

	Default	aAttach		:= {}
	Default cFrom     	:= IIF(cRotina == "CFG10EGR", "caoa_totvs_prd@caoa.com.br", AllTrim( GetMV("MV_RELACNT",.F.,"") ))  	// E-mail utilizado no campo FROM no envio de relatorios por e-mail
	Default cTo       	:= Param01
	Default cCc       	:= Param02
	Default cBcc      	:= ""
	Default cSubject  	:= Param03
	Default cBody     	:= Param04
	Default cReplyTo  	:= Param10
	Default cCodEnt   	:= ""
	Default lAuto     	:= .F.

	If ValType(Param05) == "C"
		aAttach := STRTOKARR( Param05, "," )
	ElseIf ValType(Param05) == "A"
		aAttach := Param05
	EndIf

	oMailServer := TMailManager():New()

// Usa SSL, TLS ou nenhum na inicializacao
	If lSSL
		oMailServer:SetUseSSL(lSSL)
	ElseIf lTLS
		oMailServer:SetUseTLS(lTLS)
	Endif

// Inicializacao do objeto de Email
	If nError == 0
		//Prioriza se a porta está no endereço correto
		nPortAddSrv := AT(":",cSMTPAddr)

		If nPortAddSrv > 0
			nSMTPPort := Val(Substr(cSMTPAddr, nPortAddSrv + 1,Len(cSMTPAddr)))
			cSMTPAddr := Substr(cSMTPAddr, 0, nPortAddSrv - 1)
		EndIf

		nError := oMailServer:Init("",cSMTPAddr,cUserAut,cPassAut,,nSMTPPort)
		If nError <> 0
			cSendError := "[ZGENMAIL] Falha ao conectar:"+ oMailServer:GetErrorString(nError)
			If lMsgErro
				Aviso("Erro de Conexão",cSendError,{"&Ok"},, )
			Else
				Conout(cSendError)
			EndIf
		EndIf
	Endif

// Define o Timeout SMTP
	If ( nError == 0 .And. oMailServer:SetSMTPTimeout(nSMTPTime) <> 0 )
		cSendError := "[ZGENMAIL] Falha ao definir timeout"
		nError := 1
		If lMsgErro
			Aviso("Erro de Conexão",cSendError,{"&Ok"},,)
		Else
			Conout(cSendError)
		EndIf
	EndIf

// Conecta ao servidor
	If nError == 0
		nError := oMailServer:SmtpConnect()
		If nError <> 0
			cSendError := "[ZGENMAIL] Falha ao conectar: " + oMailServer:GetErrorString(nError)
			If lMsgErro
				Aviso("Erro de Conexão",cSendError,{"&Ok"},,)
			Else
				Conout(cSendError)
			EndIf
			oMailServer:SMTPDisconnect()
		EndIf
	EndIf

// Realiza autenticacao no servidor
	If nError == 0 .And. lAutentica
		nError	:= oMailServer:SmtpAuth(cUserAut,cPassAut)
		If nError <> 0
			cSendError := "[ZGENMAIL] Falha ao autenticar "+ oMailServer:GetErrorString(nError)
			If lMsgErro
				Aviso("Erro de Conexão",cSendError,{"&Ok"},, )
			Else
				Conout(cSendError)
			EndIf
			oMailServer:SMTPDisconnect()
		EndIf
	EndIf

	If nError == 0

		oMessage := TMailMessage():New()
		oMessage:Clear()

		oMessage:cFrom    := cFrom
		oMessage:cTo      := cTo
		oMessage:cCc      := cCc
		oMessage:cBcc     := cBcc
		oMessage:cSubject := cSubject
		oMessage:cBody    := cBody
		If !Empty(cReplyTo)
			oMessage:cReplyTo := cReplyTo
		EndIf

		If Len(aAttach) > 0
			For nX := 1 To Len(aAttach)
				xRet := oMessage:AttachFile(aAttach[nX])
				If xRet < 0
					If lMsgErro
						Aviso("[ZGENMAIL] Enviar email - Anexos",;
								"O arquivo " + ATail(StrTokArr(aAttach[nX],"\")) + " não foi anexado!",;
								{"&Ok"},2)
					Else
						Conout("[ZGENMAIL] O arquivo " + aAttach[nX] + " não foi anexado!")
					EndIf
					Return .F. 
				EndIf
					//Grava nome do arquivo para salvar no Log.
				cAnexos	+= aAttach[nX] +CRLF
			Next nX
		EndIf

		nError := oMessage:Send( oMailServer )

		If nError <> 0 // nError = 67 EMAIL DESTINO @CAOAMONTADORA | @CAOA INEXISTENTE ; 12 FROM DIFERENTE DA CONTA EMAIL AUTENTICADA
			cSendError := "[ZGENMAIL] Falha no envio do Email - " + "{" + CVALTOCHAR( nError ) + "} " + oMailServer:GetErrorString(nError)
			If lMsgErro
				Aviso("Erro de Envio",cSendError,{"&Ok"},,)
			Else
				Conout(cSendError)
			EndIf
		Else
			lRetorno := .T.
			If lMsgErro
				If lMsgOk
					Aviso("Finalizado.","[ZGENMAIL] Email enviado com sucesso...",{"&Ok"},,)
				EndIf
			Else
				Conout("[ZGENMAIL] Email enviado com sucesso.")
			EndIf
		EndIf

		oMailServer:SmtpDisconnect()

		
		//Grava Tabela de Log, envio de e-mail
		RecLock("SZU",.T.)
			SZU->ZU_FILIAL	:= xFilial("SZU")
			SZU->ZU_DATA	:= DDataBase
			SZU->ZU_HORA	:= Time()
			SZU->ZU_STATUS	:= If(lRetorno , "1",	"2")
			SZU->ZU_ROTINA	:= cRotina
			SZU->ZU_USER	:= If(Empty(LogUserName()),"JOB-SCHEDULE",LogUserName())
			SZU->ZU_FROM	:= cFrom
			SZU->ZU_TO		:= cTo
			SZU->ZU_CC		:= cCc
			SZU->ZU_BCC		:= cBCc
			SZU->ZU_REPLYTO	:= cReplyTo
			SZU->ZU_SUBJECT	:= cSubject
			SZU->ZU_BODY	:= cBody
			SZU->ZU_ATTACH	:= cAnexos
			SZU->ZU_OBSERV	:= If(lRetorno , cObsMail, cObsMail +" - "+ cSendError) 
		SZU->(MsUnlock())
		
		
	EndIf
Return(lRetorno)
