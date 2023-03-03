#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Define CRLF  CHAR(13) + CHAR(10)

/*/{Protheus.doc} ZWSR015
Serviço de integração  Autoware 
Envio do XML da NF para Autoware
@author 	   DAC 
@since 		13/05/2022
@version 	undefined
@param		Não utilizado
@return     lRet			, caracter, JSON com tabelas.
@type       class
@client   	CAOA BARUERI
@project 	Interfaces_PortalV3_v2 x Protheus v2
Z  -Customizado
WS - Modulo
R  - resT OU W WebServer
010- Sequencial
/*/
WSRESTFUL ZWSR015 DESCRIPTION "Integração Autoware XML - NF" FORMAT APPLICATION_JSON 
   WSDATA empresa 		As String
	WSDATA filial 		As String
	WSDATA token    	As String
	WSDATA cnpj 		As String
	WSDATA doc        	As String
	WSDATA serie   		As String

	WSMETHOD POST ; 
	        DESCRIPTION "XML de NF enviada por Autoware";
	        WSSYNTAX "/ZWSR015"
END WSRESTFUL

WSMETHOD POST;
WSRECEIVE empresa, filial, token, cnpj, doc, serie;
WSSERVICE ZWSR015

Local oJsonRet 	  := JsonObject():New()
Local cJSON 	  := Self:GetContent()     // –> Pega a string do JSON
Local oParseJSON  := Nil
Local _cUsuario   := ""
Local _cSenha     := ""

Private aAuto	  := {}
Private _aRet	  := {}
Private _cDoc     := ""
Private _cSerie   := ""
Private _cCNPJ    := ""
Private _cToken   := ""
Private cXmlNf    := ""

    Conout("ZWSR015 - integraçao XML de NF Autoware POST - Inicio "+DtoC(date())+" "+Time())
    ::SetContentType('application/json')

    // –> Deserializa a string JSON
	FWJsonDeserialize(cJson, @oParseJSON)
    If Empty(oParseJSON:cdEmpresa) .Or. Empty(oParseJSON:cdFilial)
 		cErro := "Necessario informar os parametros empresa e filial, por favor, verifique!"
		SetRestFault(400, cErro)
		Return .T.
	EndIf

	//-- Tratar abertura da empresa conforme enviado no parametro
	If cEmpAnt <> AllTrim(oParseJSON:cdEmpresa) .or. cFilAnt <> AllTrim(oParseJSON:cdFilial)
    	RpcClearEnv() 
    	RPCSetType(3) 
        //RpcSetEnv(_cEmpresa, cxFilial,,,,GetEnvServer(),{ })
    	RpcSetEnv(AllTrim(oParseJSON:cdEmpresa),AllTrim(oParseJSON:cdFilial),,,,GetEnvServer(),{ })
	EndIf

    _cDoc     := oParseJSON:cdDocumento
    _cSerie   := oParseJSON:cdSerie
    _cCNPJ    := oParseJSON:cdCNPJ
    _cToken   := oParseJSON:Token
    _cUsuario := oParseJSON:usuario
    _cSenha   := oParseJSON:senha

	If Empty(_cUsuario) .or. AllTrim(_cUsuario) <> "caoa.totvs"
        oJsonRet['errorCode']	:= 400
        oJsonRet['errors']		:= 'Usuario não está autorizado a acessar os serviços Protheus!'
        ::SetResponse( oJsonRet:ToJson() )
        Break
	EndIf

    If Empty(_cSenha) .or. AllTrim(_cSenha) <> "CAgka2694X*"
        oJsonRet['errorCode']	:= 400
        oJsonRet['errors']		:= 'Senha invalida!'
        ::SetResponse( oJsonRet:ToJson() )
        Break
 	EndIf

    If Empty(_cToken) .or. AllTrim(_cToken) <> "AUTOWAREXTOTVS"
        oJsonRet['errorCode']	:= 400
        oJsonRet['errors']		:= 'Aplicação Web não está autorizada a acessar os serviços Protheus (Token Failed) !'
        ::SetResponse( oJsonRet:ToJson() )
        Break
 	EndIf

    If Empty(_cDoc) .or. Empty(_cSerie) 
        oJsonRet['errorCode']	:= 400
        oJsonRet['errors']		:= 'Documento ou Série não preenchidos !'
        ::SetResponse( oJsonRet:ToJson() )
        Break
 	EndIf

    If Empty(_cCNPJ) 
        oJsonRet['errorCode']	:= 400
        oJsonRet['errors']		:= 'CNPJ não preenchido !'
        ::SetResponse( oJsonRet:ToJson() )
        Break
 	EndIf

    If _cCNPJ <> '03471344000509' //CD BARUERI - CAOA MONTADORA DE VEICULOS LTDA
        oJsonRet['errorCode']	:= 400
        oJsonRet['errors']		:= 'CNPJ não pertencente a Barueri !'
        ::SetResponse( oJsonRet:ToJson() )
        Break
 	EndIf

    _aRet := ValidOJson(cJson, _cDoc, _cSerie)     

    IF !Empty(cXmlNf)

        oJsonRet['xml']	:= cXmlNf
        oJsonRet['errorCode']	:= 200
        oJsonRet['Message'] 	:= "XML de NF recebida com sucesso!"

        ::SetResponse( oJsonRet:ToJson() )
    Else
        oJsonRet['errorCode']	:= 400
        oJsonRet['errors']		:= 'Não foi possivel gerar o  XML !'
        ::SetResponse( oJsonRet:ToJson() )
    EndIF

	//Erro no programa
  	/*If Len(_aRet) == 0 
		//SetRestFault(999,"Problemas em relação ao retorno Rest, verificar com administrador !")
      
        oJsonRet := JsonObject():new()
        oJsonRet['errorCode']      := 999
        oJsonRet['errorMessage']   := "Problemas em relação ao retorno Rest, verificar com administrador !"

        ::SetResponse( oJsonRet:ToJson() )
            
        Break
	EndIf*/

    Conout("ZWSR015 - integraçao XML de NF Autoware POST - Final "+DtoC(date())+" "+Time())

Return .T.


/*/{Protheus.doc} ValidOJson
Valida os dados do oJson
@author DAC - Denilso
@since 
@version undefined
@param _cDoc, _cSerie, _cCNPJ 
@param cMsg, characters, descricao
@type function
/*/
Static Function ValidOJson(cJson, _cDoc, _cSerie)
Local _cQuery := ' '
Local qryNF   := ' '

    qryNF := GetNextAlias()

    //While ( Select(qryNF) <> 0 )
    //    dbSelectArea(qryNF)
    //    (qryNF)->(dbCloseArea())
    //    qryNF := GetNextAlias()
    //EndDo

	_cQuery := "SELECT F2.*, F2.R_E_C_N_O_ RECF2, VS1_FILIAL, VS1_NUMNFI, VS1_SERNFI, VS1_CLIFAT, VS1_LOJA, VS1_XTPPED, VS1_NUMPED,A1_CGC" + CRLF
	_cQuery += "FROM "+ RetSQLname("SF2") +" F2," + RetSQLname("VS1") +" VS1 " + CRLF    
	_cQuery += "INNER JOIN "+ RetSQLname("SA1") +" A1 "
    _cQuery += " ON VS1.VS1_CLIFAT  = A1.A1_COD "
    _cQuery += " AND VS1.VS1_LOJA   = A1.A1_LOJA"
    _cQuery += " AND A1.D_E_L_E_T_  =   ' '     "
	_cQuery += "WHERE VS1.D_E_L_E_T_  = ' '     "                  + CRLF
    _cQuery += "   AND VS1.VS1_FILIAL = '" + xfilial("VS1") + "'"  + CRLF
	_cQuery += "   AND VS1.VS1_NUMNFI = '" + _cDoc          + "'"  + CRLF
	_cQuery += "   AND VS1.VS1_SERNFI = '" + _cSerie        + "'"  + CRLF
	_cQuery += "   AND F2.F2_CLIENTE  = VS1.VS1_CLIFAT   "         + CRLF
	_cQuery += "   AND F2.F2_LOJA     = VS1.VS1_LOJA     "         + CRLF
    _cQuery += "   AND F2.F2_DOC      = VS1.VS1_NUMNFI   "         + CRLF
    _cQuery += "   AND F2.F2_SERIE    = VS1.VS1_SERNFI   "         + CRLF
	_cQuery += "   AND F2_CHVNFE      <> ' '       "               + CRLF
	_cQuery += "   AND F2_FIMP        = 'S'        "               + CRLF
 	_cQuery += "   AND F2.D_E_L_E_T_ = ' '         "               + CRLF 
	_cQuery += "  ORDER BY F2.F2_EMISSAO desc      "               + CRLF
	_cQuery := ChangeQuery(_cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),qryNF,.T.,.T.)

    While (qryNF)->(!EOF())

		cFilAnt := (qryNF)->F2_FILIAL
 
        IF UsaColaboracao("1")
            cXmlNf:= XML_COL((qryNF)->RECF2)
        Else
            cXmlNf:= fConsXml((qryNF)->F2_DOC, (qryNF)->F2_SERIE, (qryNF)->F2_EMISSAO, (qryNF)->A1_CGC)
        EndIF

        //U_CAOA_MONITOR( cFilant  ,cRet,'001','004',cErro, Alltrim(qryNF->F2_DOC+qryNF->F2_SERIE) ,'0',cSoap ,qryNF->RECF2)
        (qryNF)->(dbSkip())

	EndDo

    If Select(qryNF) <> 0
	    (qryNF)->(DbCloseArea())
	    Ferase(qryNF+GetDBExtension())
    Endif 

Return(cXmlNf)


**********************************************************************************************************
Static Function XML_COL(RECF2)
Local _cQCol := ' '
Local cqxml  := GetNextAlias()
   
    SF2->(dbGoto(RECF2))					

    _cQCol := "SELECT CKOCOL.R_E_C_N_O_ RECCKO " + CRLF 
    _cQCol += "FROM "+ RetSQLname("CKOCOL") + " CKOCOL " + CRLF 
    _cQCol += "    INNER JOIN " + RetSQLname("CKQ") + " CKQ "         + CRLF 
    _cQCol += "        ON CKQ.CKQ_FILIAL  = '" + SF2->F2_FILIAL + "'" + CRLF   
    _cQCol += "		   AND CKQ.CKQ_NUMERO = '" + SF2->F2_DOC    + "'" + CRLF          
    _cQCol += "		   AND RTRIM(LTRIM(CKQ.CKQ_SERIE,'0')) = '" + RTRIM(LTRIM(SF2->F2_SERIE)) + "'"  + CRLF
    _cQCol += "		   AND CKQ.CKQ_TP_MOV = '1'   "    + CRLF
    _cQCol += "		   AND CKQ.CKQ_CODEDI = '170' "    + CRLF
    _cQCol += "		   AND CKQ.CKQ_STATUS = '2'   "    + CRLF 
    _cQCol += "		   AND CKQ.D_E_L_E_T_ = ' '   "    + CRLF
    _cQCol += "WHERE "  + CRLF
    _cQCol += "		CKOCOL.CKO_FILIAL = '" + xFilial("CKOCOL")  + "'" + CRLF
    _cQCol += "		AND CKOCOL.CKO_ARQUIV = CKQ.CKQ_ARQUIV "    + CRLF
    _cQCol += "		AND CKOCOL.CKO_STATUS = CKQ.CKQ_STATUS "    + CRLF 
    _cQCol += "		AND CKOCOL.D_E_L_E_T_ = ' ' "               + CRLF

    _cQCol := ChangeQuery(_cQCol)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQCol),cqxml,.T.,.T.)
    dbSelectArea(cqxml)

    CKO->(dbSetOrder(1))
    CKO->(dbGoTo((cqxml)->RECCKO))         //ir p/ o registro da CKQ  27

    cXMLnf := AllTrim(CKO->CKO_XMLRET)   //Carregar XML

    If Empty(cXMLnf)
        cXMLnf := AllTrim(CKO->CKO_XMLENV)   //Carregar XML
    EndIf

    If Select(cqxml) <> 0
        (cqxml)->(DbCloseArea())
        Ferase(cqxml+GetDBExtension())
    Endif 

Return(cXMLnf)


//Modelo do JSon
/*
{
"usuario": "caoa.totvs",/
"senha": "CAgka2694X*",
"Token":"AUTOWAREXTOTVS",
"cdEmpresa":"02",
"cdCNPJ":"13007583000124",
"cdDocumento":"000000001",
"cdSerie":"7  "
}
*/
