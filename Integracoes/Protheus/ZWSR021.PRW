#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} ZWSR021
Serviço de integração Autoware - Consulta Valor do Modelo
@author 	Victor Gisoldi Matos
@since 		01/10/2024
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
021- Sequencial
/*/

WSRESTFUL ZWSR021 DESCRIPTION "Integração Autoware - Consulta Valor do Modelo!" FORMAT APPLICATION_JSON 
	WSMETHOD GET ; 
	        DESCRIPTION "Consulta Valor do Modelo";
	        WSSYNTAX "/ZWSR021"
END WSRESTFUL

WSMETHOD GET WSSERVICE ZWSR021
//WSMETHOD GET WSSERVICE ZWSR021
Local _aRet				:= {}
Local _oJsonRet 		:= Nil
Local _oJson
Local _cAuthorization 
Local _cEmpFil 		
Local _cResp	
Local _cUser 	
Local _cPass 	
Local _nPos

Begin Sequence
    Conout("ZWSR021 - Integração Autoware - Consulta Valor do Modelo - Inicio "+DtoC(date())+" "+Time())
    ::SetContentType('application/json')
	_cAuthorization := Self:GetHeader('Authorization')
	_cEmpFil 		:= Self:GetHeader("tenantid", .F.)
	_cResp			:= Self:GetHeader("Responsavel", .F.)
	_cUser 			:= AllTrim( superGetMv( "CAOA_RES01"	, , "USER_TOTVS"	) )		// Usuario para autenticacao no WS 
	_cPass 			:= AllTrim( superGetMv( "CAOA_RES02"	, , "@IntcaoaSA1!2024!"	) )	// Senha para autenticao no WS 
	
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
			_aRet := U_ZRESTVLR(@_oJson, _cEmpFil, _cResp)
			//Erro no programa
  		Else 
			_aRet := {302,"Nao Autorizado"}
		Endif
	Endif

	If ValType(_aRet) <> "A" .Or. Len(_aRet) == 0 
		_oJsonRet := JsonObject():new()
		_oJsonRet['Code'] 		:= 999
		_oJsonRet['Message']	:= "Problemas em relacao ao retorno Rest, verificar com administrador !"
		::SetResponse( _oJsonRet:ToJson() )
		Break
	EndIf

	If Len(_aRet) > 2
		_oJsonRet := JsonObject():new()
		For _nPos := 1 to len(_aRet)
			_oJsonRet[_aRet[_nPos,2]]	:= _aRet[_nPos,3] // cria o retorno com as chaves e os resultados
		Next
		::SetResponse( _oJsonRet:ToJson() )
	Else
		_oJsonRet := JsonObject():new()
		_oJsonRet['Code'] 		:= _aRet[1]
		_oJsonRet['Message']	:= _aRet[2]
		::SetResponse( _oJsonRet:ToJson() )
	Endif

End Sequence
FreeObj(_oJson)
FreeObj(_oJsonRet)
Conout("ZWSR021 - integração Autoware - Consulta Valor do Modelo - Final "+DtoC(date())+" "+Time())

Return .T.
