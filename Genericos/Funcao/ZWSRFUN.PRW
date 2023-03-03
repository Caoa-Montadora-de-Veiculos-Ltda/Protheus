#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} ZWSR005
Funcionalidades genéricar para o REST
@author 	   DAC 
@since 		25/04/2023
@version 	undefined
@param		Não utilizado
@return     Não utilizado
@type       Funções
@client   	CAOA 
@project 	Interfaces_PortalV3_v2 x Protheus v2
			   https://tdn.totvs.com/display/tec/DecodeUTF8
			   https://jsonformatter.curiousconcept.com/  VERIFICAR SE JSON ESTA CORRETO
			   https://jsonlint.com/?code=   //VALIDAR JSON
            https://jsoneditoronline.org/#left=local.sowavu  //estrutura do json
         
Z  -Customizado
WS - Modulo
R  - resT OU W WebServer
FUN- Funcionalidades genericas
/*/

/*/{Protheus.doc} ZPEC10Obri
//Verifica informações de campos obrigatórios nos arquivos Json 
@author DAC - Denilso
@since 12/11/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/

User Function ZVLDOBRJ(_oJson, _aRetMsg, _lItem, _lTodos)
Local _lRet 	:= .T.
Local _aMsgRet	:= {}
Local _xVar
Local _nPos
Local _cMsgRet
Local _nRet

Default _lItem 		:= .F.  //identifica se lera item ou cabeçalho
Default _lTodos		:= .F.	//determina se retornara todos os erros obrigatórios e ou somente o primeiro erro com obrigatório
Default _aRetMsg	:= {}

Begin Sequence
	If Len(_aRetMsg)  == 0
		Aadd(_aMsgRet, {999,"Não esta configurado validações de campos, verificar com o ADM Sistemas !"})
		Break
	Endif
	For _nPos := 1 To Len(_aRetMsg)
		//Caso seja obrigatório devo verificar se item ou cabeçalho  
		If _aRetMsg[_nPos,4] .And. ;
			((!_lItem .And. !_aRetMsg[_nPos,3]) .Or. (_lItem .And. _aRetMsg[_nPos,3]))  
			//armazeno em uma variavel para validar
			_xVar := _oJson:GetJsonText(_aRetMsg[_nPos,2])
			If ValType(_xVar) == "N" .and. _xVar == 0
				_lRet := .F.
			ElseIf ValType(_xVar) == "L" .and. Empty(_xVar) 
				_lRet := .F.
			ElseIf Empty(_xVar)
				_lRet := .F.
			EndIf
		EndIf
		If !_lRet
			_nRet := _aRetMsg[_nPos,1] 
			_cMsgRet := "Tag "+ _aRetMsg[_nPos,2]+" não esta preenchido" + If(_lItem, " nos itens !"," !") 	
			If Len(_aRetMsg[_nPos]) >= 5 .and. ValType(_aRetMsg[_nPos,5]) == "C" .and. !Empty(_aRetMsg[_nPos,5])
				_cMsgRet += " Ref. : "+_aRetMsg[_nPos,5]+" !" 
			EndIf
			Aadd(_aMsgRet, {_nRet,_cMsgRet})
			If !_lTodos  //verifica se lera todos os obrigatórios
				Break
			EndIF
		EndIf
	Next 			
End Sequence
Return _aMsgRet


/*/{Protheus.doc} ZRETMsgJson
//Retorna Numero do Erro 
@author DAC
@since 12/11/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/
User Function ZRETMsgJson(_cRefMsg, _cMsgRet)
Local _nRet := 999
Local _nPos

Default _cMsgRet := ""

Begin Sequence
	If Type("_aRetMsg") <> "A"
		Private _aRetMsg := {}
	EndIf
	If Type("_aMsgRet") <> "A"
		Private _aMsgRet := {}
	EndIf

  	_nPos := Ascan(_aRetMsg,{|x| x[2] == _cRefMsg})
	If _nPos > 0 
		_nRet := _aRetMsg[_nPos,1]
	EndIf	
	If Empty(_cMsgRet) .and. Len(_aRetMsg[_nPos]) >= 5 .and. ValType(_aRetMsg[_nPos,5]) == "C"
		_cMsgRet := _aRetMsg[_nPos,5]+" !"
	Endif	
	Aadd(_aMsgRet, {_nRet,_cMsgRet})
End Sequence
Return _nRet

/*/{Protheus.doc} SetMsgRet
Seta mensagem retorno de msg do rest
@author DAC
@since 01/05/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/
User function ZSetMsgJson() 
Local _nMsg  := 999
Local _cMsg  := ""
Local _nPos

Begin Sequence
	If Type("_aMsgRet") <> "A"
		Private _aMsgRet := {}
	EndIf

	If Len(_aMsgRet) == 0  //caso não venha com nenhuma msg
		_nMsg	:= 999
		_cMsg	:= "problemas na identificaçao do erro, não processado entrar em contato com ADM Sistemas !"
	ElseIf	Len(_aMsgRet) > 1 //caso seja mais de uma msg enviar os erros aglupados nas msgs
		_nMsg	:= 999
		_cMsg	:= ""
		For _nPos := 1 To Len(_aMsgRet)
			_cMsg += StrZero(_aMsgRet[_nPos,1],3)+ " " +_aMsgRet[_nPos,2]
			_cMsg +=  " - " //CRLF
		Next	
	Else
		_nMsg  := _aMsgRet[1,1]
		_cMsg  := _aMsgRet[1,2]
	Endif
End Sequence
Return {_nMsg,EncodeUtf8(_cMsg)}
//Return {"Code":_nMsg,"detailedMessage": "","message":EncodeUtf8(_cMsg)}


/*
=====================================================================================
Programa.:              ZPCPF007EM
@param 					_aMens   	= Mensagens de erro 
						_aChave		= Campos relativos a pesquisa com seu conteudo se vazio pesquisara baseado na tabela posicionada
						_cAssunto   = Assunto do e-mail 
						_cEmails    = Destinatário do e-mail 
						_cEMailCopia= Destinatarios em cópia 
						_aAnexos 	= Localização e nome do arquivo anexo 
						_cRotina    = Rotina que chamou o processo
						lSchedule	= Esta rodando em job se verdadeiro não emitira msg em tela
Autor....:              CAOA - DAC Denilso 
Data.....:              10/07/2020
Descricao / Objetivo:   Funcao para processar o envio das notificacoes
Doc. Origem:            GAP COM027
Solicitante:            Compras
Uso......:              ZCOLF001
Obs......:
=====================================================================================
*/
User Function ZWSRFEMA(_aMens, _aChave, _cAssunto, _cEmails, _cEMailCopia, _aAnexos , _cRotina, lSchedule)
Local _cTexto   		:= ""
Local _cEmailDest 		:= ""
Local _lMsgOK			:= .T.
Local _lMsgErro			:= .F.
Local _cObsMail			:= ""
Local _cReplyTo			:= ""
Local _cCorItem			:= "FFFFFF"
Local _lEnvia			:= .T.
Local _cLogo  			:= "lg_caoa.png"
//Local _cNomeUsu 		:= Upper(FwGetUserName(RetCodUsr())) //Retorna o nome completo do usuário  __cUserId
//Local _cCodUsu			:= RetCodUsr()
Local _cDescProd		:= ""
Local _cCodProd			:= SD3->D3_COD
Local _cNumOP			:= SD3->D3_OP
Local _cIDEnt			:= SD3->D3_IDENT
Local _nPos

Default _lSchedule   	:= .T.
Default _cAssunto		:= "Envio de e-mail"
Default _cEmails 		:= AllTrim(SuperGetMV("CMV_ZEWSRF",.F.,"denilso.carvalho@caoa.com.br"))  //E-mail para envio problemas integração TOTVS x MES 
Default _aAnexos		:= {}
Default _aChave			:= {}
Default _cEMailCopia	:= ""
Default _cRotina		:= "ZWSRFEMA"

Begin Sequence
	_lMsgErro			:= IF( _lSchedule == .F., .T. , .F. )
	If Empty(_cEmails)
		_cTexto := "**** Erros referente ao processo de importação MES função ZPCP007 não possui e-mail cadastrado no parâmetro CMV_PCP002****"
		_cTexto += "     Os mesmos serão gravados no log do Sistema conforme informações abaixo" 
		Break
	EndIf	

    //Caso as informações não dependam do posicionamento das tabelas deverá ser enviado as mesmas dentro desta variavel
	If Len(_aChave) > 0
		_cCodProd 	:= ZPCPF007EL(_aChave,"D3_COD")
 		_cNumOP		:= ZPCPF007EL(_aChave,"D3_OP")
 		_cChassi	:= ZPCPF007EL(_aChave,"H6_XCHASSI")		
 		_cIDEnt		:= ZPCPF007EL(_aChave,"D3_IDENT")	
 		_cIDMES		:= ZPCPF007EL(_aChave,"H6_XIDMES")
	EndIf

	//localizar o produto
	If !Empty(_cCodProd)
		SB1->(DbSetOrder(1))  //B1_FILIAL+B1_COD
		If SB1->(DbSeek(XFilial("SB1") + _cCodProd))
			_cDescProd := AllTrim(SB1->B1_DESC)
		EndIf
	Endif
	_cEmailDest := _cEmails
	_cHtml := ""
	_cHtml += "<html>"+ CRLF
	_cHtml += "	<head>"+ CRLF
	_cHtml += "		<title>Processo de envio de e-mails Informações/Erros</title>"+ CRLF
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
	_cHtml += "										<td width='67%' align='center' valign='middle' scope='col'><font face='Arial' size='+1'><b>WF Importação MES Informações</b></font></td>"+ CRLF
	_cHtml += "									</tr>"+ CRLF
	_cHtml += "								</table>"+ CRLF
	_cHtml += "							</th>"+ CRLF
	_cHtml += "						</tr>"+ CRLF
	_cHtml += "						<tr >"+ CRLF
	_cHtml += "							<td height='25' style='padding-top:1em;'>"+ CRLF
	_cHtml += "								<table width='100%' height='100%' border='2' cellpadding='2' cellspacing='0' >"+ CRLF
	_cHtml += "									<tr bgcolor='#4682B4'>"+ CRLF
	_cHtml += "										<th width='10%' height='100%' align='center' valign='middle' scope='col'><font face='Arial' size='2'><b>Descrição		</b></font></th>"+ CRLF
	_cHtml += "									</tr>"+ CRLF


	ConOut(_cAssunto)
	For _nPos := 1 To Len(_aMens)
		_cHtml += "									<tr> <!--while advpl-->"+ CRLF
		_cMsgErro := _aMens[_nPos,1]+" - "+_aMens[_nPos,2]
		_cHtml += "										<td width='10%' height='16' align='left'	valign='middle' bgcolor='#"+_cCorItem+"' scope='col'><font size='1' face='Arial'>"+_cMsgErro+"</font></td>"+ CRLF
		_cHtml += "									</tr>"+ CRLF
		ConOut(_aMens[_nPos,1]+" - "+_aMens[_nPos,2])
	Next
	
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
	If _lSchedule
		_lEnvia := U_ZGENMAIL(_cEmailDest,_cEMailCopia,_cAssunto,_cHtml,_aAnexos,_lMsgErro,_lMsgOK,_cRotina,_cObsMail,_cReplyTo)
	Else
		MsgRun("Enviando e-mail de notificação. Aguarde!!!","CAOA",{|| _lEnvia := U_ZGENMAIL(_cEmailDest,_cEMailCopia,_cAssunto,_cHtml,_aAnexos,_lMsgErro,_lMsgOK,_cRotina,_cObsMail,_cReplyTo) })
	EndIf
	If !_lEnvia
		If lSchedule
			ConOut("**** [ ZWSRFEMA ] - E-mail não cadastrado para envio - Solicitar apoio do administrador! (Totvs Integração MES) ****"+ CRLF)
		Else
			ApMsgInfo("E-mail não cadastrado para envio - Solicitar apoio do administrador!! (Totvs Integração MES)","Cadastro")
		EndIf
	EndIf
End Sequence

Return nil




/*
=====================================================================================
Programa.:              CAOA_GRVMONITOR - Função para gravar registros no monitor de integração
@param 					cFil   		= Filial do Documento 
						cStatus     = Status 0 = Aguardando Integração; 1=Sucesso; 2=Erro
						cCodint		= Código da Indegração SZ2
						cCodtpint   = Tipo de integração 
						cErro    	= Retorno 
						cDocori		= Documento 
						cTempo		= Tempo gasto no envio
						cJSON 		= Json ou HTML Recebido/Enviado 
						nRecnoDoc	= Numero do registro enviado/recebido
						cHTTP		= Código retorno HTTP
Autor....:              CAOA - DAC Denilso 
Data.....:              18/10/2022
Descricao / Objetivo:   Funcao para processar o envio das notificacoes
Doc. Origem:            
Solicitante:            CAOA
Uso......:              
Obs......:				Esta funcionalidade Substitui a funcionalidade CAOA_MONITOR
=====================================================================================
*/
User Function CAOA_GRVMONITOR(_cFil, _cStatus, _cCodint, _cCodtpint, _cErro, _cDocori, _dDataIni, _cHoraIni, _cJSON, _nRecnoDoc, _cUserName, _xHTTP, _aCampos)
Local _aArea    := GetArea()
Local _cTempo		:= ""
Local _cEmail		:= ""
Local _cNomeInt 	:= ""
Local _cTipoInt		:= ""
Local _cChave  		:= "" 
Local _cIDCad  	 	:= ""   
Local _dData		:= Date() //dDatabase
Local _cSeparador	:= ";"

Local _cID
Local _nPos
Local _nPosCpo
Local _xValor
Local _cDoc
Local _cSerie

//Local _cUser	:= RetCodUsr()
	
Default	_cFil		:= ""
Default _cStatus	:= ""
Default _cCodint	:= "" 
Default _cCodtpint	:= ""
Default _cErro		:= ""
Default _cDocori	:= ""
Default _cTempo		:= ""
Default _cJSON 		:= ""
Default _nRecnoDoc 	:= RetCodUsr()                                                                   
Default _dDataIni	:= CtoD(Space(08))
Default _cHoraIni	:= ""
Default _cUserName	:= UsrRetName(RetCodUsr())
Default _xHTTP     	:= ""
Default _aCampos	:= {}

Begin Sequence

	Conout("[CAOA_GRVMONITOR] Inicio "+DtoC(Date())+" "+Time())
	//Pode vir numerico codigo erro json
	If ValType(_xHTTP) == "N"
		_xHTTP := Str(_xHTTP)
	Endif	
	//Buscando nomes de integra
	SZ2->(DbSetOrder(1)) // Z2_CODIGO
	If SZ2->(dbSeek(xFilial("SZ2")+_cCodint))
		_cNomeInt := SZ2->Z2_NOME   
	EndIf

	//Buscando tipo de integr e email da SZ3
	SZ3->(DbSetOrder(1)) // Z3_CODINTG+Z3_CODTINT
	If SZ3->(dbSeek(xFilial("SZ3")+_cCodint+_cCodtpint))
		_cTipoInt := SZ3->Z3_TPINTEG
		_cEmail   := alltrim(lower(SZ3->Z3_EMAIL))
	EndIf          

	SZ1->(DbSetOrder(1)) //FILIAL + ID 
	_cID 	:= GetSxeNum("SZ1","Z1_ID")
	_cIDCad := U_XVERNUMeracao("SZ1", "Z1_ID", _cID )
	If _cID <> _cIDCad
		 _cID := _cIDCad
	Endif
	ConfirmSX8()

	If _nRecnoDoc > 0
		_cChave := XMontaChPesq( SZ2->Z2_TABPRNM, SZ2->Z2_CHAVPES, _nRecnoDoc )
	EndIf	

	If !Empty(_dDataIni)
		//regra para calcular Tempo
		_cTempo 	:= CAOA_TIME( _dDataIni, _cHoraIni )
	Endif
	If Valtype(_cJSON) == "J"
		_cJson 		:= _cJson:toJSON()
	Endif
	//Abrindo a tabela de produtos e setando o para insert
	_nPosCpo 	:= AT(_cSeparador, _cDocori)
	If _nPosCpo > 0
		_cDoc	:= SubsTr(_cDocori, 1, _nPosCpo)
 		_cSerie	:= SubsTr(_cDocori, _nPosCpo+1)
	Else
		_cDoc	:= _cDocori
 		_cSerie	:= ""
	Endif
	RecLock("SZ1", .T.)
	SZ1->Z1_FILIAL   := xFilial("SZ1")
	SZ1->Z1_ID       := _cID
	SZ1->Z1_STATUS   := _cStatus
	SZ1->Z1_INTEGRA  := _cCodint
	SZ1->Z1_NOMEITG  := _cNomeInt
	SZ1->Z1_TPINTEG  := _cCodtpint
	SZ1->Z1_NTPINTG  := _cTipoInt
	SZ1->Z1_ERRO     := Upper(_cErro)
	SZ1->Z1_DTEXEC   := _dDataIni
	SZ1->Z1_HREXEC   := _cHoraIni
	SZ1->Z1_DTRET    := _dData
	SZ1->Z1_HSRET  	 := Time()
	SZ1->Z1_DOCORI   := Alltrim(_cDoc)
	If SZK->(FieldPos("Z1_SERORI")) > 0
		SZ1->Z1_SERORI   := Alltrim(_cSerie)
	EndIf	
	SZ1->Z1_TMPPRO   := _cTempo
	SZ1->Z1_USUARIO  := _cUserName                                                  
	SZ1->Z1_JSON     := _cJSON
	SZ1->Z1_DOCRECN  := _nRecnoDoc
	SZ1->Z1_HTTP     := AllTrim(_xHTTP)
	SZ1->Z1_CHAVPES  := _cChave
	//Adição de campos pré definidos para gravação SZ1 DAC 15/02/2023
	If Len(_aCampos) > 0
		For _nPos := 1 To Len(_aCampos)
			_cCampo := AllTrim(_aCampos[_nPos,1])
			_nPosCpo :=  SZ1->(FieldPos(_cCampo))
			If _nPosCpo == 0 .Or. Empty(_cCampo)
				Loop
			EndIf
			If Len(_aCampos) > 1
				_xValor := _aCampos[_nPos,2]
				SZ1->(FieldPut(_nPosCpo, _xValor))
			Endif	
		Next _nPos
	Endif	
	SZ1->(MsUnlock())
    
	/* NÃO ESTA ENVIANDO EMAIL
	If cStatus == "2"  .AND. .F. // Erro
		//EnvMail()
	Endif
	*/
End Sequence	
RestArea(_aArea)
Conout("[CAOA_GRVMONITOR] Final "+DtoC(Date())+" "+Time())

Return SZ1->( Recno() )


//Retornar a chave de Pesquisa conforme a tabela de dados DAC 17/10/2022
Static Function XMontaChPesq( _cTab, _cChavePesq, _nReg )
Local _cRet 	:= ""
Local _cSepara 	:= "+"
Local _cCampo
Local _nPos		
Local _xValor

Default _cTab 		:= ""
Default _cChavePesq	:= ""
Default _nReg		:= 0

Begin Sequence
	If Empty(_cTab) .or. Empty(_cChavePesq)
		Break
	Endif 
	DbSelectArea(_cTab)
	//Posiciona o numero do registro
	If _nReg > 0
		(_cTab)->(DbGoto(_nReg))
	Endif
	_cCampo		:= ""
	_cChavePesq := AllTrim(_cChavePesq)
	For _nPos := 1 To Len(_cChavePesq)
		If SubsTr(_cChavePesq,_nPos,1) == _cSepara .Or. _nPos == Len(_cChavePesq)
		    //por ser o ultimo registro incluo no nome do campo se não for ;
			If _nPos == Len(_cChavePesq) .and. SubsTr(_cChavePesq,_nPos,1) <> _cSepara 
				_cCampo +=  SuBsTr(_cChavePesq,_nPos,1)
			EndIf
			_nPosCmp := (_cTab)->(FieldPos(AllTrim(_cCampo))) 
			If _nPosCmp > 0
				_xValor := (_cTab)->(FieldGet(_nPosCmp))
				If ValType(_xValor) == "D"
					_xValor := DtoC(_xValor)
				ElseIf ValType(_xValor) == "N"
					_xValor := AllTrim(Str(_xValor))
				ElseIf ValType(_xValor) == "L"
					If _xValor
						_xValor := ".T."
					Else
						_xValor := ".F."
					Endif	
				Endif
	   			_cRet 	+= _xValor  + If(_nPos == Len(_cChavePesq),"","+")
			Endif
			_cCampo	:= ""
		Else
			_cCampo +=  SuBsTr(_cChavePesq,_nPos,1)
		Endif	
	Next	
End Sequence
Return _cRet



//função para calcular tempo de acordo com a data inicial enviada
Static function CAOA_TIME( _dDataIni, _cHoraIni )
Local _dData	:= DATE()
Local _cHoraAtu := Time()
Local _cTempo	:= ""
Local _nTempo 	:= 0
Local _nDias	:= 0
Local _nPos
Local _cHoras

Begin Sequence
	//Se a data é a mesma calcular a hora
	If _dDataIni == _dData
		_cTempo := 	ElapTime(_cHoraIni,_cHoraAtu)   
		Break
	Endif
	//If (DateDiffDay(_dDataIni , _dData) == 1)
		//nTempo	:=  (VAL(LEFT(ElapTime(ZC5->ZC5_HORINI,"00:00:00"),2)) + VAL(LEFT(ElapTime("00:00:01",Time()),2)))
	//	_nTempo	:=  Val(ElapTime(_dDataIni,"00:00:00")) + Val(ElapTime("00:00:01",Time()))
	//	_cTempo	:=  Min2Hrs(nTempo) 
	//Endif	
	_nDias 	:= DateDiffDay(_dDataIni , _dData)
	If _nDias <= 0
		Break
	Endif
	_nTempo := 0
	For _nPos := 1 To _nDias 
		If _nPos == 1
			_cHoras := 	SubsTr(ElapTime(_cHoraIni,"00:00:00"),1,2)+SubsTr(ElapTime(_cHoraIni,"00:00:00"),4,2)   
			_nTempo	:=   (Val(SubsTr(_cHoras,1,2))+Val(SubsTr(_cHoras,4,2)))*60
		ElseIf _nPos <> _nDias
			_nTempo += 2400 * 60  //quantidade de horas dia
		//Pegar quantidade de horas da data inicial	
		Else
			_cHoras := 	SubsTr(ElapTime("00:00:01",_cHoraAtu),1,2)+SubsTr(ElapTime("00:00:01",_cHoraAtu),4,2)   
			_nTempo	:=  (Val(SubsTr(_cHoras,1,2))+Val(SubsTr(_cHoras,4,2)))*60
		Endif	
	Next
	If _nTempo > 0
		Min2Hrs(_nTempo) //converte minutos em horas
	Endif
End Sequence
Return _cTempo
