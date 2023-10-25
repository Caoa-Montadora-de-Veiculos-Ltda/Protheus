#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "RESTFUL.CH"
#Include "RWMAKE.Ch"
#Include "TBICONN.CH"
#Include "PROTHEUS.CH"
#Include "FWMBROWSE.CH"
#define CRLF chr(13) + chr(10)

/*/{Protheus.doc} ZEICF022
Serviço de ZEIC11AMsg integração  Asia Shipping  recebimento de mercadorias 
@author 	A.Carlos
@since 		24/07/2023
@version 	undefined
@param		Não utilizado
@type 		User Function
@client   	CAOA 
@return   	_aMsg - Array com retorno Json código e ocorrencia
@project 	Interfaces_PortalV3_v2 x Protheus v2
               https://api.asiashipping.com.br
Z	-Customizado
EIC	- Modulo
F 	- Função
022 - Sequencial
/*/
User Function ZEICF022(_aParam)
Local _lJob := IsBlind()

	If _lJob
		ConOut("*************************************************************************************************************************"	+ CRLF)
		ConOut("----------- [ ZEICF022 ] - Inicio da funcionalidade "+DtoC(Date())+" as "+Time()														+ CRLF)
		ConOut("*************************************************************************************************************************"	+ CRLF)
	EndIf

	//sendo job testar parametros
	If _lJob
		If ValType(_aParam) == "A"
			//VarInfo("Valores dos parametros recebidos pela rotina ZPCPJV01:",_aParam)
			_cEmpresa 	:=  _aParam[1]
			_cFilial 	:=  _aParam[2]
			CONOUT("INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("INICIANDO FILIAL "+_cFilial)
			RpcClearEnv()
			RpcSetType(3)
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "EIC"
			_lAbre		:= .T.
		ElseIf Type("cFilAnt") <> "C"
			_cEmpresa	:=	"01"
			_cFilial	:=  "2010022001"
			CONOUT("INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("INICIANDO FILIAL "+_cFilial)
			RpcClearEnv()
			RpcSetType(3)
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "EIC"
			_lAbre		:= .T.
		EndIf
	EndIF
	ZEICF022AP(, , ,_lJob)
Return()


Static Function ZEICF022AP(_cUrl, _cChave, _lToken, _lJob)

Local _aMsg		:= {}
Local _lRet 	:= .T.

//após validações pde deixar os retornos em branco e validar se estiver em branco é erro
Default _cUrl 	:= "https://api.asiashipping.com.br/bot/house"
Default _cChave := ""    //"ASP20100044"  //informações como numero da House
Default _lToken := .F. 

Conout("INICIANDO FUNCIONALIDADE ZEICF022 - Asia Shipping em "+DtoC(Date())+" as "+Time())
_lRet := ZEICF022PR( _cUrl, _cChave, _lToken, _aMsg, _lJob )

IF Len(_aMsg) > 0 		
	//Tratar erros aqui
    SetMsgRet(_aMsg)	
EndIf

Conout("TERMINO FUNCIONALIDADE ZEICF022 - Asia Shipping em "+DtoC(Date())+" as "+Time())
Return Nil


/*/{Protheus.doc} ZEICF022PR
Recebe 		Json 
@author 	A.Carlos
@since 		24/07/2023
@version 	undefined
@param 		oJson
@type 		function
@ Obs		Os paremetros de token, usuário e senha serão enviados no cabeçalho reader Json
/*/
Static Function ZEICF022PR( _cUrl, _cChave, _lToken, _aMsg, _lJob )
Local _cUserName    := "Authorization"  
Local _cPassword    := "Barer eyJhbGciOiJlUzl1Nils"
Local _cUrlToken 	:= "https://api.asiashipping.com.br/account/token"
Local _lRet			:= .T.
Local _cAlias 		:= GetNextAlias()
Local _cAliasJ 		:= GetNextAlias()
Local _Import       := '013' 
Local _Encer        := ' '     //DTOS('  /  /    ')
Local _cProc        := ' '
Private _cRet         
Private _cHouse     := SPACE(TamSX3("W6_HOUSE")[1])
Private _oJSRet     := JsonObject():New()
Private _nTime		:= 120
Private _aHeader    := {}  

	//Obter o Token
    // PREENCHE CABEÇALHO DA REQUISIÇÃO
	Aadd(_aHeader, "Authorization: Basic " + Encode64(_cUserName + ":" + _cPassword))
	Aadd(_aHeader,'Content-Type: application/json; charset=utf-8')
	Aadd(_aHeader,'Accept: application/json')
	//"CompanyClients": "string"
	//caso a URL necessite de Token
	If _lToken
		_cRet := Httpget(_cUrlToken, '', _nTime , _aHeader)
		//Montar o token e acrescentar no cabeçalho _aHeader para acessar
		if Valtype(_cRet) = "U"
			Aadd(_aMsg,"Não existe retorno do Host Token, excedido o numero de tentativas de conexão "+_cUrlToken)
			Return .F.
		EndIf
	Endif

    _cProc  := SPACE(TamSX3("W6_HAWB")[1])
    _cChave := SPACE(TamSX3("W6_HOUSE")[1])

	IF _lJob

	    ZEIC22job(_cURL,_lJob,_cAliasJ,_Encer,_Import)

    ELSE

		_cProc  := Alltrim(SW6->W6_HAWB)
		_cChave := Alltrim(SW6->W6_HOUSE)

		_cUrl += "/"+_cChave
		_cRet := Httpget(_cUrl, '', _nTime , _aHeader)

		if Valtype(_cRet) = "U"
			Aadd(_aMsg,"Não existe retorno do Host, excedido o numero de tentativa de conexão "+_cChave)
			Return .F.
		EndIf

		_oJSRet:FromJSON(_cRet)
		
		If ValType(_oJSRet) <> "J"
			Aadd(_aMsg,"Não retornado Json da conexão "+_cUrl)
			Return .F.
		Endif

		//Havia um endif antes desta linha Ativação de workareas
		_cHouse := AllTrim(_oJSRet:GetJsonText("jS_HouseBill"))
		BeginSql Alias _cAlias
			SELECT 	SW6.R_E_C_N_O_ NREGSW6
			FROM %table:SW6% SW6
			WHERE SW6.W6_FILIAL    = %XFilial:SW6%
				AND SW6.W6_HOUSE   = %Exp:_cHouse%
				AND SW6.W6_DT_ENCE = %Exp:_Encer%
				AND SW6.W6_AGENTE  = %Exp:_Import% 
				AND SW6.%notDel%		  
		EndSql 

		If (_cAlias)->(Eof()) .Or. (_cAlias)->NREGSW6  == 0
			Aadd(_aMsg,"Somente processos da ASIA podem ser integrados. "+_cChave)
			_lRet :=  .F.
		Else 
			//Posicionar na SW6 para gravar os dados
			ZEIC022GRV(_cHouse,(_cAlias)->NREGSW6) 

			_cMsg := "Integração realizada com sucesso !"
			MSGINFO( _cMsg, "[ZEICF022]" )
			_lRet :=  .T.
		Endif 

    ENDIF  //removido lá de cima

If Select(_cAlias) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif  

Return _lRet


/*/{Protheus.doc} ZEIC22job
//Carrega House de todos os processo em aberto para atualizar
@author A.Carlos
@since 31/07/2023
@version undefined
@param _lJob
@type function  AND SW6.W6_NF_ENT <> ' '
/*/
Static Function ZEIC22job(_cURL,_lJob,_cAliasJ,_Encer,_Import)
Local _lRet := .F.
Local _sUrl := _cURL
//Local _Teste:= 'SHA23090924'
//			AND SW6.W6_HOUSE   = %Exp:_Teste%

	BeginSql Alias _cAliasJ
		SELECT SW6.W6_HOUSE cBL, SW6.R_E_C_N_O_ NREGSW6
		FROM %table:SW6% SW6
		WHERE SW6.W6_FILIAL    = %XFilial:SW6%
			AND SW6.W6_DT_ENCE = %Exp:_Encer%
			AND SW6.W6_AGENTE  = %Exp:_Import%
			AND SW6.%notDel%		  
	EndSql

	If (_cAliasJ)->(Eof()) .Or. (_cAliasJ)->NREGSW6  == 0
        Conout("ZEICF022 - Somente processos da ASIA podem ser integrados. ")
		_lRet :=  .F.
	Else
	   ConOut("*************************************************************************************************************************"	+ CRLF)
       Conout("ZEICF022 - Integraçao ASIA SHIPPING - JOB Inicio "+DtoC(date())+" "+Time())

		While (_cAliasJ)->(!Eof()) 

		    _cUrl := _sUrl
	 	    _cChave := Alltrim((_cAliasJ)->cBL)

			If !Empty(_cChave)
				_cUrl += "/"+_cChave
			Endif

			_cRet := Httpget(_cUrl, '', _nTime , _aHeader)

			if ValType(_cRet) = "U"
			    Conout("ZEICF022 - Não existe retorno do Host, excedido o numero de tentativa de conexão ")
				(_cAliasJ)->(DbSkip())
				LOOP
			EndIf

			_oJSRet:FromJSON(_cRet)
			
			If ValType(_oJSRet) <> "J"
				Conout("ZEICF022 - Não retornado Json da conexão "+_cUrl)
				(_cAliasJ)->(DbSkip())
				LOOP
			Endif

			_cHouse := AllTrim(_oJSRet:GetJsonText("jS_HouseBill"))

			If  valtype(_cHouse) == 'C' .AND. !Empty(_cHouse) 
				//Posicionar na SW6 para gravar os dados
				ZEIC022GRV(_cHouse,(_cAliasJ)->NREGSW6) 
				_lRet :=  .T.
			ENDIF

			(_cAliasJ)->(DbSkip())
		Enddo

	Endif

	Conout("ZEICF022 - Integraçao ASIA SHIPPING - Fim "+DtoC(date())+" "+Time())

Return _lRet


/*/{Protheus.doc} SetMsgRet
Seta mensagem retorno de msg do rest
@author A.Carlos
@since 01/05/2021
@version undefined
@param _aMsg, array, descrição
@type function
/*/
Static function SetMsgRet(_aMsg) 
Local _nMsg  := 500
Local _cMsg  := ""
Local _nPos

//Begin Sequence
	If Len(_aMsg) == 0  //caso não venha com nenhuma msg
		_nMsg	:= 500
		_cMsg	:= "problemas na identificaçao do erro, não processado !"
	ElseIf	Len(_aMsg) > 1 //caso seja mais de uma msg enviar os erros aglupados nas msgs
		_nMsg	:= 500
		_cMsg	:= ""
		For _nPos := 1 To Len(_aMsg)
			_cMsg += StrZero(_aMsg[_nPos,1],3)+ " " +_aMsg[_nPos,2]
			_cMsg +=  " - " //CRLF
		Next	
	Else
		_nMsg  := 001
		_cMsg  := _aMsg[1]
	Endif
//End Sequence

MSGINFO( _cMsg, "[ZEICF022]" )
Return {_nMsg,EncodeUtf8(_cMsg)}
//Return {"Code":_nMsg,"detailedMessage": "","message":EncodeUtf8(_cMsg)}



/*/{Protheus.doc} ZEIC022GRV
Posicionar na SW6 para gravar os dados
@author A.Carlos
@since 01/05/2021
@version undefined
@param House
@type function
/*/
Static function ZEIC022GRV(_cHouse,NREGSW6) 
Local _Ret  := ''
Local _dETD := CTOD("  /  /    ")
Local _dATA := CTOD("  /  /    ")
Local _dETA := CTOD("  /  /    ")
Local _dEMB := CTOD("  /  /    ") 
Local _cVtrans := ' '
Local _cIdet   := ' '
Local _cCemerc := ' '
Local _cOrig   := ' '
Local _cDest   := ' '
Local _cVes    := ' '
Local _cCem    := ' '

    SW6->(dbGoto(NREGSW6))

	_dETD := CTOD(SUBSTR(_oJSRet:GetJsonText("jW_ETD"),1,10))
	_dEMB := CTOD(SUBSTR(_oJSRet:GetJsonText("jW_ATD"),1,10))
	_dATA := CTOD(SUBSTR(_oJSRet:GetJsonText("jW_ATA"),1,10))			
	_dETA := CTOD(SUBSTR(_oJSRet:GetJsonText("jW_ETA"),1,10))
		
	IF (AllTrim(_oJSRet:GetJsonText("jW_TransportMode")) = 'SEA' .OR. AllTrim(_oJSRet:GetJsonText("jW_TransportMode")) = 'FSA')
		_cVtrans := 'M'       
	ELSEIF (AllTrim(_oJSRet:GetJsonText("jW_TransportMode")) = 'AIR' .OR. AllTrim(_oJSRet:GetJsonText("jW_TransportMode")) = 'FAS')
		_cVtrans := 'A' 
	ELSEIF AllTrim(_oJSRet:GetJsonText("jW_TransportMode")) = 'ROA'
		_cVtrans := 'R' 
	ELSE
		_cVtrans := ' '  			
	ENDIF
	_cVes := AllTrim(_oJSRet:GetJsonText("jW_Vessel"))
	IF RAT('Dispon',_cVes) > 0	
		_cIdet := ' '
	ELSE
		_cIdet := AllTrim(_oJSRet:GetJsonText("jW_Vessel"))			
	ENDIF
	_cCem := AllTrim(_oJSRet:GetJsonText("jS_CEMercante"))
	IF RAT('Dispon',_cCem) > 0	
		_cCemerc := ' '
	ELSE
		_cCemerc := AllTrim(_oJSRet:GetJsonText("jS_CEMercante"))			
	ENDIF

	_cOrig  := Posicione("SY9",4,xFilial("SY9")+AllTrim(_oJSRet:GetJsonText("jS_RL_NKOrigin")),"Y9_SIGLA")
	_cDest  := Posicione("SY9",4,xFilial("SY9")+AllTrim(_oJSRet:GetJsonText("jS_RL_NKDestination")),"Y9_SIGLA")
	//_cHouse := AllTrim(_oJSRet:GetJsonText("jS_HouseBill"))

	SW6->(RecLock("SW6",.F.))
	SW6->W6_ORIGEM  := _cOrig
	SW6->W6_DEST    := _cDest
	SW6->W6_IDENTVE := _cIdet	
	SW6->W6_VIA_TRA := _cVtrans 
	SW6->W6_XCEMERC := _cCemerc 
	SW6->W6_DT_ETD  := _dETD
	SW6->W6_DT_EMB  := _dEMB
	SW6->W6_DT_ETA  := _dETA
	SW6->W6_CHEG    := _dATA
	SW6->W6_XCSTAT  := AllTrim(_oJSRet:GetJsonText("cargaStatus")) 
	SW6->W6_XCMSG   := AllTrim(_oJSRet:GetJsonText("cargaMensagem")) 
	SW6->(MsUnLock())

Return(_Ret)
