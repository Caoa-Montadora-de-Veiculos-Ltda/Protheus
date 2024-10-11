#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} ZWSR019
Serviço de integração Autoware - Consulta Saldo em Estoque
@author 	Victor Gisoldi Matos
@since 		18/09/2024
@version 	1.0
@param		Não utilizado
@return     lRet			, caracter, JSON com tabelas.
@type       class
@client   	CAOA 
@project 	API Saldo em Estoque
			https://tdn.totvs.com/display/tec/DecodeUTF8
			https://jsonformatter.curiousconcept.com/  VERIFICAR SE JSON ESTA CORRETO
			https://jsonlint.com/?code=   //VALIDAR JSON
            https://jsoneditoronline.org/#left=local.sowavu  //estrutura do json
            http://172.28.35.154:45487/rest_des02/ZWSR009
            http://172.28.35.154:45486/rest_des01/ZWSR009
         
Z  -Customizado
WS - Modulo
R  - resT OU W WebServer
019- Sequencial
/*/

WSRESTFUL ZWSR019 DESCRIPTION "Integração Autoware - Consulta saldo em estoque!" FORMAT APPLICATION_JSON 
	WSMETHOD GET ; 
	        DESCRIPTION "Consulta saldo em estoque";
	        WSSYNTAX "/ZWSR019"
END WSRESTFUL

WSMETHOD GET WSSERVICE ZWSR019
//WSMETHOD GET WSSERVICE ZWSR019
Local _aRet				:= {}
Local _oJsonRet 		:= Nil
Local _oJson
Local _cAuthorization 
Local _cEmpFil 		
Local _cResp	
Local _cUser 	
Local _cPass 	

Begin Sequence

    Conout("ZWSR019 - Integração Autoware - Consulta Saldo em Estoque - Inicio "+DtoC(date())+" "+Time())
    ::SetContentType('application/json')
	_cAuthorization := Self:GetHeader('Authorization')
	_cEmpFil 		:= Self:GetHeader("tenantid", .F.)
	_cResp			:= Self:GetHeader("Responsavel", .F.)

	//_cUser 	:= AllTrim( superGetMv( "CAOA_RES01"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS 
	//_cPass 	:= AllTrim( superGetMv( "CAOA_RES02"	, , "@IntcaoaSA1!2024!"	) )	// Senha para autenticao no WS 
	//_cChave := encode64( allTrim( _cUser ) + ":" + allTrim( _cPass ) )    
	_cUser 	:= AllTrim( superGetMv( "CAOA_RES01"	, , "USER_TOTVS"	) )	// Usuario para autenticacao no WS 
	_cPass 	:= AllTrim( superGetMv( "CAOA_RES02"	, , "@IntcaoaSA1!2024!"	) )	// Senha para autenticao no WS 
	
	If Valtype(_cUser) <> "C"  .Or.  ValType(_cPass) <> "C"  .Or. Valtype(_cAuthorization) <> "C"
		_aRet := {302,"Nao Autorizado [Parametros]"}
	ElseIf Empty(_cUser) .Or. Empty(_cPass) 
		_aRet := {302,"Nao Autorizado [Parametros]"}
	Else
		_cChave := _cUser+":"+_cPass
		If  _cChave == Decode64(_cAuthorization)
			_oJson := JsonObject():new()
   	 		_oJson:fromJson(DecodeUTF8(Self:GetContent(,.T.)))  //Correto
			//    _cJson       := Self:GetContent(,.T.)
			_aRet := U_ZRESTESL(@_oJson, _cEmpFil, _cResp) // _aRet := U_ZRESTSA1(@_oJson, _cEmpFil, _cResp)
			//Erro no programa
  		Else 
			_aRet := {302,"Nao Autorizado"}
		Endif
	Endif
	
	If ValType(_aRet) <> "A" .Or. Len(_aRet) == 0 
		//SetRestFault(999,"Problemas em relação ao retorno Rest, verificar com administrador !")
		_oJsonRet := JsonObject():new()
		_oJsonRet['Code'] 		:= 999
		_oJsonRet['Message']	:= "Problemas em relacao ao retorno Rest, verificar com administrador !"
		::SetResponse( _oJsonRet:ToJson() )
		Break

	EndIf

	If _aRet[1] == 100
		//SetRestFault(_aRet[1],_aRet[2])
		If Len(_aRet) < 3
			_oJsonRet := JsonObject():new()
			_oJsonRet['Code'] 		:= 999
			_oJsonRet['Message']	:= "Problemas com retorno, montagem de campos retorno"
			::SetResponse( _oJsonRet:ToJson() )
			Break
		Endif 
		_oJsonRet := JsonObject():new()
		_oJsonRet := _aRet[3]
		::SetResponse( _oJsonRet )
	Else

		//SetRestFault(_aRet[1],_aRet[2])
		_oJsonRet := JsonObject():new()
		_oJsonRet['Code'] 		:= _aRet[1]
		_oJsonRet['Message']	:= _aRet[2]
		::SetResponse( _oJsonRet:ToJson() )

	Endif

End Sequence
FreeObj(_oJson)
FreeObj(_oJsonRet)
Conout("ZWSR019 - integração Autoware - Consulta Saldo em Estoque - Final "+DtoC(date())+" "+Time())

Return .T.
