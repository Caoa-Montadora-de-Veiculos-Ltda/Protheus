#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"


/*
=====================================================================================
Programa.:              ZMSBLQUSR
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              06/05/2020
Descricao / Objetivo:   Bloqueia usuário do Protheus
Doc. Origem:            
Solicitante:            
Uso......:              Configurador
Obs......:
=====================================================================================
*/
User Function ZMSBLQUSR(_lJob, _nDias)

Local lUserAut      := .F.
Default _lJob       := .F.
Default _nDias      := 60
			//  U_ZGENUSER( <ID User> , <"NOME DA FUNÇÃO"> , <.F.=Não Exibe Msg; .T.=Exibe Msg> )

If (_lJob)
    zProcessa(_lJob, _nDias)
Else

    lUserAut := U_ZGENUSER( RetCodUsr() ,"ZMSBLQUSR"	,.T.)

    If lUserAut

        Processa({|| zProcessa() }, "[ZMSBLQUSR] - Realizando o bloqueio dos usuários", "Aguarde ...." )
        ApMsgAlert( "Bloqueio realizados com Sucesso.","[ ZMSBLQUSR ] - Aviso" )
    EndIf
EndIf

Return()

/*
=====================================================================================
Programa.:              zProcessa
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              21/07/2022
Descricao / Objetivo:   Processa o bloqueio dos usuários do Protheus
Doc. Origem:            
Solicitante:            
Uso......:              Configurador
Obs......:
=====================================================================================
*/
Static Function zProcessa(_lJob, _nDias)

Local cQuery		:= ""
Local cAliasTRB		:= GetNextAlias()
Local cNameUser     := ""
Local nTotReg       := 0
Local _dDataProc    := Date()

Default _lJob       := .F.
Default _nDias      := 60

    If Select( (cAliasTRB) ) > 0
        (cAliasTRB)->(DbCloseArea())
    EndIf

    _dDataProc := _dDataProc - _nDias

    cQuery := " "

    cQuery += " SELECT USR_ID,USR_CODIGO,USR_MSBLQL,USR_DTINC, USR_DTLOGON FROM ABDHDU_PROT.SYS_USR "                                                       + CRLF
    cQuery += " WHERE  D_E_L_E_T_ = ' ' "                                                                                                                   + CRLF 
    cQuery += " AND USR_ID <> '000000' "                                                                                                                    + CRLF 
    cQuery += " AND ( ( USR_DTINC < '"+DToS(_dDataProc)+"'  AND USR_DTLOGON = ' ' ) OR ( USR_DTLOGON < '"+DToS(_dDataProc)+"'  AND USR_DTLOGON <> ' ') ) "  + CRLF
    cQuery += " AND USR_MSBLQL = '2' "                                                                                                                      + CRLF
    cQuery += " ORDER BY USR_ID "                                                                                                                           + CRLF

    // Executa a consulta.
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

    DbSelectArea((cAliasTRB))
    
    If !(_lJob)
        nTotReg := Contar(cAliasTRB,"!Eof()")

        // Conta quantos registros existem, e seta no tamanho da régua.
        ProcRegua( nTotReg )
    Else
        zEnviaMail(cAliasTRB, _nDias)
    EndIf

    //Ordena por UserId
    PswOrder(1)

    (cAliasTRB)->(dbGoTop())
    While (cAliasTRB)->(!Eof())

        If !(_lJob)
            // Incrementa a mensagem na régua.
            IncProc( "Bloqueando Usuário: " + Alltrim((cAliasTRB)->USR_ID) + " | " + Alltrim((cAliasTRB)->USR_CODIGO) )
        Else
            ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZGENJ001] Bloqueando Usuario: " + Alltrim((cAliasTRB)->USR_ID) + " | " + Alltrim((cAliasTRB)->USR_CODIGO))
        EndIf
        
        //Pesquisa no UserId                     
        If PswSeek((cAliasTRB)->USR_ID)
            //Se encontrou grava o Username na variavel xNameUser                  
            cNameUser := PswRet(1)[1][2]
            //Bloqueia usuário no configurador
            _lBloq := PswBlock(cNameUser)
        EndIf
        (cAliasTRB)->(DbSkip())
    End

    (cAliasTRB)->(DbCloseArea())

Return()


/*
=====================================================================================
Programa.:              zEnviaMail
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              01/08/2023
Descricao / Objetivo:   Envia e-mail com os usuários que serão bloqueados e os que foram bloqueados.
Doc. Origem:            
Solicitante:            
Uso......:              Configurador
Obs......:
=====================================================================================
*/
Static Function zEnviaMail(cAliasTRB, _nDias)
Local _cEmailDest 		:= ""
Local _lMsgOK			:= .T.
Local _lMsgErro			:= .F.
Local _cObsMail			:= ""
Local _cReplyTo			:= ""
Local _cCorItem			:= "FFFFFF"
Local _lEnvia			:= .T.
Local _cLogo  			:= "lg_caoa.png"
Local _cAssunto		    := "Bloqueio de Usuarios Protheus"
Local _cEmails 		    := AllTrim(SuperGetMV("CMV_GEN007", .F., "evandro.mariano@caoa.com.br"))
Local _aAnexos		    := {}
Local _cEMailCopia	    := ""
Local _cRotina		    := "ZMSBLQUSR"

_cEmailDest := _cEmails
_cHtml := ""
_cHtml += "<html>"+ CRLF
_cHtml += "	<head>"+ CRLF
_cHtml += "		<title>Relacao de usuarios</title>"+ CRLF
_cHtml += "	</head>"+ CRLF
_cHtml += "	<body leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>"+ CRLF
_cHtml += "		<table width='100%' height='100%' border='0' cellpadding='0' cellspacing='0'>"+ CRLF
_cHtml += "			<tr>"+ CRLF
_cHtml += "				<th width='1200' height='100%' align='center' valign='top' scope='col'>"+ CRLF
_cHtml += "					<table width='90%' height='50%' border='0' cellpadding='0' cellspacing='0'>"+ CRLF
_cHtml += "						<tr>"+ CRLF
_cHtml += "							<th width='100%' height='100' scope='col'>"+ CRLF
_cHtml += "								<table width='100%' height='60%' border='3' cellpadding='0' cellspacing='0' >"+ CRLF
_cHtml += "									<tr>"+ CRLF
_cHtml += "										<th width='12%' height='0' scope='col'><img src='" + _cLogo + "' width='118' height='40'></th>"+ CRLF
_cHtml += "										<td width='67%' align='center' valign='middle' scope='col'><font face='Arial' size='+1'><b>Usuarios sem acessar o sistema a "+AllTrim(cValToChar(_nDias))+" dias | Corte: " + DToc(Date() - _nDias) +" </b></font></td>"+ CRLF
_cHtml += "									</tr>"+ CRLF
_cHtml += "								</table>"+ CRLF
_cHtml += "							</th>"+ CRLF
_cHtml += "						<tr >"+ CRLF
_cHtml += "							<td height='25' style='padding-top:1em;'>"+ CRLF
_cHtml += "								<table width='100%' height='100%' border='2' cellpadding='2' cellspacing='0' >"+ CRLF
_cHtml += "									<tr bgcolor='#4682B4'>"+ CRLF
_cHtml += "										<th width='10%' height='100%' align='center' valign='middle' scope='col'><font face='Arial' size='2'><b>Usuários</b></font></th>"+ CRLF
_cHtml += "									</tr>"+ CRLF

(cAliasTRB)->(dbGoTop())
While (cAliasTRB)->(!Eof())
	_cHtml += "									<tr> <!--while advpl-->"+ CRLF
	_cMsgErro := "Id: " + (cAliasTRB)->USR_ID +" | Codigo: "+Upper(AllTrim((cAliasTRB)->USR_CODIGO)) +" | Inclusao: "+AllTrim(DToC(SToD((cAliasTRB)->USR_DTINC))) +" | Ult. Logon: "+AllTrim(DToC(SToD((cAliasTRB)->USR_DTLOGON)))
	_cHtml += "										<td width='10%' height='16' align='left'	valign='middle' bgcolor='#"+_cCorItem+"' scope='col'><font size='1' face='Arial'>"+_cMsgErro+"</font></td>"+ CRLF
	_cHtml += "									</tr>"+ CRLF
    (cAliasTRB)->(DbSkip())
End
_cHtml += "								</table>"+ CRLF
_cHtml += "						<tr > </tr>"+ CRLF
_cHtml += "						<tr > </tr>"+ CRLF
	
/*
cMailDestino	- E-mail de Destino
cMailCopia		- E-mail de cópia
cAssunto		- Assunto do E-mail
cHtml			- Corpo do E-mail
aAnexos			- Anexos que será enviado
lMsgErro		- .T. Exige msgn na tela - .F. Exibe somente por Conout
cReplyTo		- Responder para outra pessoa.
cRotina			- Rotina que está sendo executada.
cObsMail		- Observação para Gravação do Log.
*/
_lEnvia := U_ZGENMAIL(_cEmailDest,_cEMailCopia,_cAssunto,_cHtml,_aAnexos,_lMsgErro,_lMsgOK,_cRotina,_cObsMail,_cReplyTo)

If !_lEnvia
	ConOut("**** [ ZMSBLQUSR ] - Erro no envio do e-mail, favor verificar ****"+ CRLF)
EndIf

Return()
