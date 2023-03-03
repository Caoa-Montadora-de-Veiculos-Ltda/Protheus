#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
/*/{Protheus.doc} ZWSR005
Serviço de integração  Autoware recebimento de Orçamento
Inclusão de Orçamentos enviados pela Autoware
@author 	   DAC 
@since 		23/07/2021
@version 	undefined
@param		Não utilizado
@return     lRet			, caracter, JSON com tabelas.
@type       class
@client   	CAOA BARUERI
@project 	Interfaces_PortalV3_v2 x Protheus v2
			   https://tdn.totvs.com/display/tec/DecodeUTF8
			   https://jsonformatter.curiousconcept.com/  VERIFICAR SE JSON ESTA CORRETO
			   https://jsonlint.com/?code=   //VALIDAR JSON
            https://jsoneditoronline.org/#left=local.sowavu  //estrutura do json
			   http://abdhdu-des-protheus.totvscloud.com.br:45487/rest_des02/ZWSR005
			   https://abdhdu-des-protheus.totvscloud.com.br:45022/rest/ZWSR005
			   https://abdhdu-des-protheus.totvscloud.com.br:45022/rest/ZWSR005
            http://172.28.35.154:45487/rest_des02/ZWSR005
            http://172.28.35.154:45486/rest_des01/ZWSR005
         
Z  -Customizado
WS - Modulo
R  - resT OU W WebServer
010- Sequencial
/*/

WSRESTFUL ZWSR005 DESCRIPTION "Integração Autoware Orçamento" FORMAT APPLICATION_JSON 
	WSMETHOD POST ; 
	        DESCRIPTION "Incluir Orçamento de Peças enviado por Autoware";
	        WSSYNTAX "/ZWSR005"
END WSRESTFUL


WSMETHOD POST WSSERVICE ZWSR005
Local _oJson
Local _aRet		:= {}
Local oJsonRet := Nil

Begin Sequence
    Conout("ZWSR005 - integraçao Orçamento Autoware POST - Inicio "+DtoC(date())+" "+Time())
    ::SetContentType('application/json')
    _oJson := JsonObject():new()
    _oJson:fromJson(DecodeUTF8(Self:GetContent(,.T.)))  //Correto
//    _cJson       := Self:GetContent(,.T.)
	_aRet := U_ZPECF010(@_oJson)
	//Erro no programa
  	If ValType(_aRet) <> "A" .Or. Len(_aRet) == 0 
		//SetRestFault(999,"Problemas em relação ao retorno Rest, verificar com administrador !")
      
      oJsonRet := JsonObject():new()
      oJsonRet['errorCode']      := 999
      oJsonRet['errorMessage']   := "Problemas em relacao ao retorno Rest, verificar com administrador !"

      ::SetResponse( oJsonRet:ToJson() )
		
      Break
	EndIf
	If _aRet[1] == 100

      /******************************************************************************************************
      |  SetRestFault foi comentado porque o pedido é incluido mas a resposta apresenta a mensagem abaixo   |
      |  "message": "The request has been fulfilled and resulted in a new resource being created."          |
      |  //SetRestFault(_aRet[1],_aRet[2])                                                                  |
      |  A causa ainda não foi identificada.                                                                |
      ******************************************************************************************************/

      oJsonRet := JsonObject():new()
      oJsonRet['errorCode']      := _aRet[1]
      oJsonRet['errorMessage']   := _aRet[2]

      ::SetResponse( oJsonRet:ToJson() )
	Else
		//SetRestFault(_aRet[1],_aRet[2])
      oJsonRet := JsonObject():new()
      oJsonRet['errorCode']      := _aRet[1]
      oJsonRet['errorMessage']   := _aRet[2]

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
Conout("ZWSR005 - integraçao Orçamento Autoware POST - Final "+DtoC(date())+" "+Time())
Return .T.


/*
{
   "cEmpresa":"02",
   "cFilAtu":"2020012001",
   "cToken":"AUTOWAREXTOTVS",
   "cdPedido":"697816",
   "cnpj":"11208302000176",
   "chassi":"AUTJU81BABU168052",
   "os":5896,
   "dtAberturaOS":"2018-05-02T10:06:00-03:00",
   "dtPedido":"2018-07-20T10:06:00-03:00",
   "cdTipoPedido":"001",
   "dsTipoPedido":"SAC",
   "cdTransportadora":"102",
   "dsTransportadora":"RG LOG",
   "cdFrete":"C",
   "dsFrete":"PAGO",
   "cdCondicaoPagamento":"003",
   "dsCondicaoPagamento":"Pagamento para 30 dias",
   "cdTipoTransporte":"002",
   "dsTipoTransporte":"Rodoviário",
   "comentario":"SAC",
   "cdMarca":"HYU",
   "vlTotal":2286.44,
   "itens":[
      {
         "cdPeca":"VJ98",
         "quantidade":3,
         "vlPeca":846.98,
         "perDes":10
         "vlTotal":2286.44
      }
   ]
}
*/
