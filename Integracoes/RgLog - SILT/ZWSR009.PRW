#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} ZWSR009
Servi�o de integra��o  Autoware recebimento separa��o de mercadorias or�amento
@author 	   DAC 
@since 		17/12/2021
@version 	undefined
@param		N�o utilizado
@return     lRet			, caracter, JSON com tabelas.
@type       class
@client   	CAOA BARUERI
@project 	Interfaces_PortalV3_v2 x Protheus v2
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

WSRESTFUL ZWSR009 DESCRIPTION "Integra��o RG LOG Separa��o" FORMAT APPLICATION_JSON 
	WSMETHOD PUT ; 
	        DESCRIPTION "Receber a separa��o da RG LOG";
	        WSSYNTAX "/ZWSR009"
END WSRESTFUL


WSMETHOD PUT WSSERVICE ZWSR009
Local _oJson
//Local _cJson
Local _aRet		:= {}
Local oJsonRet := Nil

Begin Sequence
    Conout("ZWSR009 - Integra�ao Recebimento Separa��o RG LOG PUT - Inicio "+DtoC(date())+" "+Time())
    ::SetContentType('application/json')
    _oJson := JsonObject():new()
    _oJson:fromJson(DecodeUTF8(Self:GetContent(,.T.)))  //Correto
//    _cJson       := Self:GetContent(,.T.)
	_aRet := U_ZPECF011(@_oJson)
	//Erro no programa
  	If ValType(_aRet) <> "A" .Or. Len(_aRet) == 0 
		//SetRestFault(999,"Problemas em rela��o ao retorno Rest, verificar com administrador !")
		oJsonRet := JsonObject():new()
		oJsonRet['errorCode'] 		:= 999
		oJsonRet['errorMessage']	:= "Problemas em relacao ao retorno Rest, verificar com administrador !"

		::SetResponse( oJsonRet:ToJson() )
		Break
	EndIf
	If _aRet[1] == 100
		//SetRestFault(_aRet[1],_aRet[2])
		//_cJSONRet := '{"Or�amento":"' + VS1->VS1_NUMORC + '"'+'}'
		//::SetResponse( cJSONRet )

		oJsonRet := JsonObject():new()
		oJsonRet['errorCode'] 		:= _aRet[1]
		oJsonRet['errorMessage']	:= _aRet[2]

		::SetResponse( oJsonRet:ToJson() )
	Else
		//SetRestFault(_aRet[1],_aRet[2])
		oJsonRet := JsonObject():new()
		oJsonRet['errorCode'] 		:= _aRet[1]
		oJsonRet['errorMessage']	:= _aRet[2]

		::SetResponse( oJsonRet:ToJson() )
	Endif
	/*
	oJsonRet := Nil
	oJsonRet := JsonObject():new()
   	oJsonRet['Propriedade1'] := EncodeUTF8("Retorno 1", "cp1252") 
   	oJsonRet['Propriedade2'] := 10 
   	oJsonRet['Propriedade3'] := .T.
	::SetResponse(oJsonRet:toJSON())
	*/
End Sequence
FreeObj(_oJson)
Conout("ZWSR009 - Integra�ao Recebimento Separa��o RG LOG PUT - Final "+DtoC(date())+" "+Time())
Return .T.


