#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} ZWSR016
Servi�o de integra��o  Cadastro de Clientes
@author 	DAC - Denilso 
@since 		20/03/2024
@version 	undefined
@param		N�o utilizado
@return     lRet			, caracter, JSON com tabelas.
@type       class
@client   	CAOA 
@project 	GAP136  API Cadastro de Cliente
			   https://tdn.totvs.com/display/tec/DecodeUTF8
			   https://jsonformatter.curiousconcept.com/  VERIFICAR SE JSON ESTA CORRETO
			   https://jsonlint.com/?code=   //VALIDAR JSON
            https://jsoneditoronline.org/#left=local.sowavu  //estrutura do json
            http://172.28.35.154:45487/rest_des02/ZWSR009
            http://172.28.35.154:45486/rest_des01/ZWSR009
         
Z  -Customizado
WS - Modulo
R  - resT OU W WebServer
010- Sequencial
/*/

WSRESTFUL ZWSR016 DESCRIPTION "Integra��o Cadastro de Clientes !" FORMAT APPLICATION_JSON 
	WSMETHOD POST ; 
	        DESCRIPTION "Incluir Cadastro de Clientes";
	        WSSYNTAX "/ZWSR016"
END WSRESTFUL


WSMETHOD POST WSSERVICE ZWSR016
//WSMETHOD GET WSSERVICE ZWSR016
Local _aRet				:= {}
Local _oJsonRet 		:= Nil
Local _oJson
Local _cAuthorization 
Local _cEmpFil 		
Local _cResp	
Local _cUser 	
Local _cPass 	

Begin Sequence
    Conout("ZWSR016 - Integra�ao Recebimento Cadastro de Clientes GET REST - Inicio "+DtoC(date())+" "+Time())
    ::SetContentType('application/json')
	_cAuthorization := Self:GetHeader('Authorization')
	_cEmpFil 		:= Self:GetHeader("tenantid", .F.)
	_cResp			:= Self:GetHeader("Responsavel", .F.)

	//_cUser 	:= AllTrim( superGetMv( "CAOA_RES01"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS 
	//_cPass 	:= AllTrim( superGetMv( "CAOA_RES02"	, , "@IntcaoaSA1!2024!"	) )	// Senha para autenticao no WS 
	//_cChave := encode64( allTrim( _cUser ) + ":" + allTrim( _cPass ) )    
	_cUser 	:= AllTrim( superGetMv( "CAOA_RES01"	, , ""	) )	// Usuario para autenticacao no WS 
	_cPass 	:= AllTrim( superGetMv( "CAOA_RES02"	, , ""	) )	// Senha para autenticao no WS 
	If Empty(_cUser) .Or. Empty(_cPass)
		_aRet := {302,"Nao Autorizado [Parametros]"}
	Else
		 _cChave := _cUser+":"+_cPass
		If _cChave == Decode64(_cAuthorization)
			_oJson := JsonObject():new()
   	 		_oJson:fromJson(DecodeUTF8(Self:GetContent(,.T.)))  //Correto
			//    _cJson       := Self:GetContent(,.T.)
			_aRet := U_ZRESTSA1(@_oJson, _cEmpFil, _cResp)
			//Erro no programa
  		Else 
			_aRet := {302,"Nao Autorizado"}
		Endif
	Endif
	
	If ValType(_aRet) <> "A" .Or. Len(_aRet) == 0 
		//SetRestFault(999,"Problemas em rela��o ao retorno Rest, verificar com administrador !")
		_oJsonRet := JsonObject():new()
		_oJsonRet['Code'] 		:= 999
		_oJsonRet['Message']	:= "Problemas em relacao ao retorno Rest, verificar com administrador !"
		::SetResponse( _oJsonRet:ToJson() )
		Break
	EndIf
	If _aRet[1] == 100
		//SetRestFault(_aRet[1],_aRet[2])
		//_cJSONRet := '{"Or�amento":"' + VS1->VS1_NUMORC + '"'+'}'
		//::SetResponse( cJSONRet )

		_oJsonRet := JsonObject():new()
		_oJsonRet['Code'] 		:= _aRet[1]
		_oJsonRet['Message']	:= _aRet[2]

		::SetResponse( _oJsonRet:ToJson() )
	Else
		//SetRestFault(_aRet[1],_aRet[2])
		_oJsonRet := JsonObject():new()
		_oJsonRet['Code'] 		:= _aRet[1]
		_oJsonRet['Message']	:= _aRet[2]
		::SetResponse( _oJsonRet:ToJson() )
	Endif
	/*
	_oJsonRet := Nil
	_oJsonRet := JsonObject():new()
   	_oJsonRet['Propriedade1'] := EncodeUTF8("Retorno 1", "cp1252") 
   	_oJsonRet['Propriedade2'] := 10 
   	_oJsonRet['Propriedade3'] := .T.
	::SetResponse(_oJsonRet:toJSON())
	*/
End Sequence
FreeObj(_oJson)
FreeObj(_oJsonRet)
Conout("ZWSR016 - Integra�ao Recebimento Cadastro de Clientes GET REST - Final "+DtoC(date())+" "+Time())
Return .T.


