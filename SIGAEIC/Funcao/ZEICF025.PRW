#Include "TOTVS.CH"
#Include "TopConn.CH"
#Include "RESTFUL.CH"
#Include "RWMAKE.Ch"
#Include "TBICONN.CH"
#Include "Parmtype.ch"
#Include "PROTHEUS.CH"
#Include "FWMBROWSE.CH"

/*/{Protheus.doc} ZEICF025
Integração  Asia Shipping - Followup-House  recebimento de mercadorias 
@author 	A.Carlos
@since 		21/12/2023
@version 	undefined
@param		_lJob
@type 		User Function
@client   	CAOA 
@return   	_aMsg - Array com retorno Json código e ocorrencia
@project 	Interfaces_PortalV3_v2 x Protheus v2
            https://api.asiashipping.com.br/followup/House
Z	-Customizado
EIC	- Modulo
F 	- Função
025 - Sequencial
/*/
User Function ZEICF025(_aParam)
Local _lJob   := IsBlind()
Local _lToken := .T.  

	If _lJob
		ConOut("*************************************************************************************************************************"	+ CRLF)
		ConOut("----------- [ ZEICF025 ] - Inicio da funcionalidade "+DtoC(Date())+" as "+Time()														+ CRLF)
		ConOut("*************************************************************************************************************************"	+ CRLF)
	EndIf

	//sendo job testar parametros
	If _lJob
		If ValType(_aParam) == "A"
			//VarInfo("Valores dos parametros recebidos pela rotina ZPCPJV01:",_aParam)
			_cEmpresa 	:=  _aParam[1]
			_cFilial 	:=  _aParam[2]
			CONOUT("INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("INICIANDO FILIAL  "+_cFilial)
			RpcClearEnv()
			RpcSetType(3)
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "EIC"
			_lAbre		:= .T.
		ElseIf Type("cFilAnt") <> "C"
			_cEmpresa	:=	"01"
			_cFilial	:=  "2010022001"
			CONOUT("INICIANDO EMPRESA "+_cEmpresa)
			CONOUT("INICIANDO FILIAL  "+_cFilial)
			RpcClearEnv()
			RpcSetType(3)
			Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "EIC"
			_lAbre		:= .T.
		EndIf
	EndIF
	ZEICF025AP(, , _lToken,_lJob)
Return()


/*/{Protheus.doc} ZEICF025AP
Chamado pela função ZEICF025 integração  Asia Shipping - Followup-House  busca de Token para autenticação 
@author 	A.Carlos
@since 		21/12/2023
@version 	undefined
@param		_cUrl, _cChave, _lToken, _lJob
@type 		User Function
@client   	CAOA 
@return   	Token para autenticação
*/
Static Function ZEICF025AP(_cUrl, _cChave, _lToken, _lJob)
Local _aMsg		:= {}
Local _lRet 	:= .T.

Private cUserName   := SuperGetMV("CMV_EIC004",,"Caoa")     // type here user name     "Caoa"         
Private cPassword   := SuperGetMV("CMV_EIC005",,"bRTxqzUyJwN5BnT")     // type here user password    "bRTxqzUyJwN5BnT" 

Default _cChave := " "                    ///"SHA23090924"          //informações como numero da House
Default _cUrlFH	:= "https://api.asiashipping.com.br/followup/House"    // GETMV("CMV_EIC001")   ///"https://api.asiashipping.com.br/followup/House"

//Default _cUrlFS	:= "https://api.asiashipping.com.br/followup/Shipment"
//Default _cUrlOR	:= "https://api.asiashipping.com.br/bot/OrderRef"
//esses 03 últimos URL necessitam de Token

Conout("INICIANDO FUNCIONALIDADE ZEICF025 - Asia Shipping em "+DtoC(Date())+" as "+Time())
_lRet := ZEICF025PR( _cUrl, _cChave, _lToken, _aMsg, _lJob )

IF Len(_aMsg) > 0 		
	//Tratar erros aqui
    SetMsgRet(_aMsg)	
EndIf

Conout("TERMINO FUNCIONALIDADE ZEICF025 - Asia Shipping em "+DtoC(Date())+" as "+Time())
Return Nil


/*/{Protheus.doc} ZEICF025PR
Chamado pela função ZEICF025AP gera Token 
@author 	A.Carlos
@since 		21/12/2023
@version 	undefined
@param 		_cUrl, _cChave, _lToken, _aMsg, _lJob
@type 		function
@ Obs		Os paremetros de token, usuário e senha serão enviados no cabeçalho 
/*/
Static Function ZEICF025PR( _cUrl, _cChave, _lToken, _aMsg, _lJob )
Local _cUserAut     := SuperGetMV("CMV_EIC006",,"Authorization")    //"Authorization"
Local _cPassAut     := SuperGetMV("CMV_EIC007",,"Bearer eyJhbGciOiJlUzl1Nils")    //"Bearer eyJhbGciOiJlUzl1Nils"  
Local _lRet			:= .T.
Local _cAlias 		:= GetNextAlias()
Local _cAliasJ 		:= GetNextAlias()
Local _Import       := '013' 
Local _Encer        := ' '     //DTOS('  /  /    ')

Private _cToken
Private _cProc      := SPACE(TamSX3("W6_HAWB")[1])        
Private _cHouse     := SPACE(TamSX3("W6_HOUSE")[1])
Private _oJSRet     := JsonObject():New()
Private _nTime		:= 120
Private _aHeader    := {}  

    _cChave := SPACE(TamSX3("W6_HOUSE")[1])
	_cChave := SW6->W6_HOUSE     //"SHA23090924"  //informações como numero da House

	Aadd(_aHeader,"Authorization: Basic " + Encode64(_cUserAut + ":" + _cPassAut))
	Aadd(_aHeader,'Content-Type: application/json; charset=utf-8')
	Aadd(_aHeader,'Accept: application/json')

	If _lToken
	    
		_cToken := U_getToke1()
		
		if Valtype(_cToken) = "U"
			Aadd(_aMsg,"Não existe retorno do Host Token, excedido o numero de tentativas de conexão ")
			Return .F.
		else
			Aadd(_aHeader,'Authorization:' + _cToken )
		EndIf

		//Montar o token e acrescentar no cabeçalho _aHeader para acessar as APIs protegidas
        ZEIC25FH(_cUrlFH,_nTime,_aHeader,_Import,_Encer,_cChave)

	Endif

	IF _lJob

	    ZEIC25job(_cUrlFH,_lJob,_cAliasJ,_Encer,_Import,_nTime,_aHeader,_cChave)

	ENDIF

If Select(_cAlias) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif  

Return _lRet


/*/{Protheus.doc} ZEIC25job
//Carrega House de todos os processo em aberto para atualizar
@author A.Carlos
@since 31/07/2023
@version undefined
@param _lJob
@type function  
/*/                     
Static Function ZEIC25job(_cURL,_lJob,_cAliasJ,_Encer,_Import,_nTime,_aHeader,_cChave)
Local _lRet   := .F.
Local _sUrl   := _cURL
Local _aHeaFH := {}  
Local _jBody  := ' '      // corpo

_jBody := JsonObject():New()
_jBody["username"] := cUserName
_jBody["password"] := cPassword

Aadd(_aHeaFH,"Authorization: Bearer " + _cToken )
Aadd(_aHeaFH,'Content-Type: application/json')
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
        Conout("ZEICF025 - Somente processos da ASIA podem ser integrados. ")
		_lRet :=  .F.
	Else
	   ConOut("*************************************************************************************************************************"	+ CRLF)
       Conout("ZEICF025 - Integraçao ASIA SHIPPING - JOB Inicio "+DtoC(date())+" "+Time())

		While (_cAliasJ)->(!Eof()) 

		    _cUrl   := _sUrl
	 	    _cChave := Alltrim((_cAliasJ)->cBL)

			If !Empty(_cChave)
				_cUrl += "/"+_cChave
			Endif

			_cRet := Httpget(_cUrl, ' ', _nTime , _aHeaFH)

			if ValType(_cRet) = "U"
			    Conout("ZEICF025 - Não existe retorno do Host, excedido o numero de tentativa de conexão ")
				(_cAliasJ)->(DbSkip())
				LOOP
			EndIf

			_oJSRet:FromJSON(_cRet)
			
			If ValType(_oJSRet) <> "J"
				Conout("ZEICF025 - Não retornado Json da conexão "+_cUrl)
				(_cAliasJ)->(DbSkip())
				LOOP
			Endif

			_cHouse := AllTrim(_oJSRet:GetJsonText("HouseBill"))

			If  valtype(_cHouse) == 'C' .AND. !Empty(_cHouse) 
				//Posicionar na SW6 para gravar os dados
				ZEIC022GRV(_cHouse,(_cAliasJ)->NREGSW6) 
				_lRet :=  .T.
			ENDIF

			(_cAliasJ)->(DbSkip())
		Enddo

	Endif

	Conout("ZEICF025 - Integraçao ASIA SHIPPING - Fim "+DtoC(date())+" "+Time())

Return _lRet


/*/{Protheus.doc} SetMsgRet
Seta mensagem retorno de msg do rest
@author A.Carlos
@since 21/12/23
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

MSGINFO( _cMsg, "[ZEICF025]" )
Return {_nMsg,EncodeUtf8(_cMsg)}
//Return {"Code":_nMsg,"detailedMessage": "","message":EncodeUtf8(_cMsg)}



/*/{Protheus.doc} ZEIC025GRV
Chamado pela função ZEICF025PR posicionar na SW6 para gravar os dados
@author A.Carlos
@since 21/12/2023
@version undefined
@param House, NREGSW6
@type function
/*/
Static function ZEIC025GRV(_cHouse,NREGSW6) 
Local _Ret     := ' '
Local _names   := ' '
Local _CodArm  := ' '
Local _nX      := 0
Local nQtdeTtl := 0
Local nQtde    := 0
Local nOUTCTN  := 0
Local nQtd40HC := 0
Local nQtd40   := 0
Local nQtd20   := 0
Local cConType := ' '
Local cTipoCT  := ' '
Local cXSHIPME := ' '                  //W6_XSHIPME   //ShipmentNum
Local nEIHQTD  := 0                    //EIH_QTDADE   //Quantidade de packs
Local cXPTYPE  := ' '                  //SJF_XPTYPE   //Tipo de pack
Local nMT3     := 0                    //W6_MT3       //Volume
Local dCargo   := CTOD("  /  /    ")   //W6_XCARGOR   //Estimativa de carga pronta
Local dCargoP  := CTOD("  /  /    ")   //W6_XCARGOP   //Carga pronta
Local dAutoE   := CTOD("  /  /    ")   // W6_XAUTOE    //Data de autorização de envio
Local dETE     := CTOD("  /  /    ")   //W6_DT_ETD    //ETD - Origem (Estimativa de Saida)
Local cATD     := " "                  //W6_XATD      //ATD - Origem (Data real Disponivel para Entrega)
Local dETA     := CTOD("  /  /    ")   //W6_DT_ETA    //ETA - Destino (Estimado de Chegada)
Local dXATA    := CTOD("  /  /    ")   //W6_XATA      //ATA - Destino (Atracação)
Local cPortOri := ' '                  //W6_ORIGEM    //Porto Origem
Local cPortDes := ' '                  //W6_DEST      //Porto Destino
Local cXCARRIE := ' '                  //W6_XCARRIE   //Nome do armador
Local cIDENTVE := ' '                  //W6_IDENTVE   //Navio
Local cVIAGEM  := ' '                  //W6_VIAGEM    //Viagem
Local cXREFARM := ' '                  //W6_XREFARM   //Referência do armador
Local cHOUSE   := ' '                  //W6_HOUSE     //Conhecimento de House
Local mVM_COMP := ' '                  //W6_VM_COMP   //Descrição detalhada dos bens
Local nPESO_BR := 0                    //W6_PESO_BR   //Peso bruto
Local cModCon  := ' '                  //W6_XMODCON   //Modalida de Container
Local cXMCONT  := ' '                  //W6_XMCONT    //Modo de contêiner
Local cXTIPOL  := ' '                  //W6_XTIPOL    //Tipo de liberação
Local cXCONSC  := ' '                  //W6_XCONSC    //Número de consolidação da carga
Local cXCEMERC := ' '                  //W6_XCEMERC   //CE Mercante
Local cXTLDEM  := ' '                  //W6_XTLDEM    //Tempo livre de demurrage
Local mXANOTA  := ' '                  //W6_XANOTA    //Anotações do Agente
Local cXCSTAT  := ' '                  //W6_XCSTAT    //Status da carga
Local cXCHOUSE := ' '                  //W6_XCHOUSE   //Conhecimento de House recebido (Sim/Não)
Local cXEUROPA := ' '                  //W6_XEUROPA   //Se carga é Via Europa
Local cLegVes  := ' '                  //             //LegVessel do navio
    SW6->(dbGoto(NREGSW6))

    cXSHIPME   := _oJSRet:GetJsonText("ShipmentNum")
	nEIHQTD    := _oJSRet:GetJsonText("PacksQTD")
	cXPTYPE    := _oJSRet:GetJsonText("PacksType")
	nMT3       := _oJSRet:GetJsonText("VolQTD")
	dCargo     := CTOD(SUBSTR(_oJSRet:GetJsonText("CargoReadyEstimate"),1,10))
	dCargoP    := CTOD(SUBSTR(_oJSRet:GetJsonText("CargoReadyActual"),1,10))
	dAutoE     := CTOD(SUBSTR(_oJSRet:GetJsonText("ShipAuthorizationDate"),1,10))
	dETE       := CTOD(SUBSTR(_oJSRet:GetJsonText("EstimateDeparture"),1,10))
	dETA       := CTOD(SUBSTR(_oJSRet:GetJsonText("EstimateArrival"),1,10))
	dXATA      := CTOD(SUBSTR(_oJSRet:GetJsonText("ActualArrival"),1,10))
	cATD       := SUBSTR(_oJSRet:GetJsonText("ActualDeparture"),1,10)
	cVIAGEM    := Alltrim(_oJSRet:GetJsonText("Voyage"))
	cXCARRIE   := _oJSRet:GetJsonText("CarrierName")
	cIDENTVE   := _oJSRet:GetJsonText("Vessel")
	cXREFARM   := _oJSRet:GetJsonText("BookingRef")
	cHOUSE     := _oJSRet:GetJsonText("HouseBill")
	mVM_COMP   := _oJSRet:GetJsonText("DetailedGoodsDescription")
	nPESO_BR   := _oJSRet:GetJsonText("GrossWeight")
	cModCon    := _oJSRet:GetJsonText("HouseBillDLVMode")
	cXMCONT    := _oJSRet:GetJsonText("ContainerMode")
	cXTIPOL    := _oJSRet:GetJsonText("ReleaseType")
	cXCONSC    := _oJSRet:GetJsonText("ConsolidationNum")
	cXCEMERC   := _oJSRet:GetJsonText("CEMercante")
	cXTLDEM    := _oJSRet:GetJsonText("DemurrageFreeTime")
	mXANOTA    := _oJSRet:GetJsonText("ClientVisibleJobNotes")
	cXCSTAT    := _oJSRet:GetJsonText("CargoStatus")
	cXCHOUSE   := _oJSRet:GetJsonText("IsHBLReceived")
	cXEUROPA   := _oJSRet:GetJsonText("IsEuropeRoute")
	cLegVes    := _oJSRet:GetJsonText("LegVessel")
		
	cPortOri  := Posicione("SY9",4,xFilial("SY9")+AllTrim(_oJSRet:GetJsonText("PortofLoading")),"Y9_SIGLA")
	cPortDes  := Posicione("SY9",4,xFilial("SY9")+AllTrim(_oJSRet:GetJsonText("PortofDischarge")),"Y9_SIGLA")
	
	IF cIDENTVE = 'NULL'	
		cIDENTVE := ' '
	ENDIF

    EIH->(DbSetOrder(1))      //EIH_FILIAL+EIH_HAWB+EIH_CODIGO                                                                                                                                  
    If EIH->(DbSeek(xFilial("EIH")+SW6->W6_HAWB))
		EIH->(RecLock("EIH",.F.))
		EIH->EIH_QTDADE := Val(nEIHQTD)    //n 5 
		EIH->(MsUnLock())
    Endif 

    SJF->(DbSetOrder(1))      //JF_FILIAL+JF_CODIGO  da embalagem                                                                                                                                                                                                                                                                               
    If SJF->(DbSeek(xFilial("SJF")+EIH->EIH_CODIGO))	
		SJF->(RecLock("SJF",.F.))
		SJF->JF_XPTYPE := cXPTYPE         //c  
		SJF->(MsUnLock())
    Endif 

    SY5->(DbSetOrder(2))      //Y5_FILIAL+Y5_NOME                                                                                                                                                                                                                                                                               
    If SY5->(DbSeek(xFilial("SY5")+cXCARRIE))
        _CodArm := SY5->Y5_COD
    Else
        _CodArm := Space(06)
    Endif 

    _names := Len(_oJSRet['Containers'])

    cConType := ''
	nQtdeTtl := 0
	nOUTCTN  := 0
    nQtd40HC := 0
    nQtd40   := 0
    nQtd20   := 0

    FOR _nX := 1 TO _names
        nQtde    := Val(_oJSRet["Containers"][_nX]["ContainerQTD"])
        cConType := Alltrim(_oJSRet["Containers"][_nX]["ContainerType"])
		IF cConType = "40HC" 
			nQtd40HC := nQtd40HC + nQtde
			cTipoCT  := "3"
		ELSEIF cConType = "20"  		
			nQtd20   := nQtd20 + nQtde
			cTipoCT  := "1"		    
		ELSEIF cConType = "40"  
			nQtd40   := nQtd40 + nQtde
			cTipoCT  := "2"	
		ELSE 
			nOUTCTN  := nOUTCTN + nQtde 
			cTipoCT  := "4"	
		ENDIF

		nQtdeTtl := nQtdeTtl + nQtde

		cContainer := Alltrim(_oJSRet["Containers"][_nX]["ContainerNum"])

		SJD->(DbSetOrder(1))//FILIAL+HAWB+Cont
		SJD->(DbGotop())
		IF SJD->(dbSeek(xFilial("SJD") + SW6->W6_HAWB + cContainer ))
			SJD->(RecLock("SJD",.F.))		    
			SJD->JD_LACRE   := Alltrim(_oJSRet["Containers"][_nX]["ContainerSelo"])	
			SJD->JD_DEVOLUC := CTOD(SUBSTR(_oJSRet["Containers"][_nX]["DevContVazio"],1,10))
			SJD->JD_TIPO_CT := cTipoCT			
			SJD->JD_QTD_REC := nQtde
	        SJD->(MsUnLock())
		ELSE
			SJD->(RecLock("SJD",.T.))
			SJD->JD_FILIAL  := xFilial("SJD")			
			SJD->JD_HAWB    := Alltrim(SW6->W6_HAWB)
			SJD->JD_CONTAIN := cContainer
			SJD->JD_ARMADOR := Substr(_CodArm,3,3)  //Ainda não tem o De x Para
			SJD->JD_CADEADO := '000'  //Ainda não tem
			SJD->JD_DEVOLUC := CTOD(SUBSTR(_oJSRet["Containers"][_nX]["DevContVazio"],1,10)) 
			SJD->JD_LACRE   := Alltrim(_oJSRet["Containers"][_nX]["ContainerSelo"])												    
			SJD->JD_TIPO_CT := cTipoCT	
			SJD->JD_QTD_REC := nQtdeTtl
	        SJD->(MsUnLock())
        ENDIF

    NEXT _nX

	SW6->(RecLock("SW6",.F.))
	SW6->W6_MT3     := Val(nMT3)       //n 8,2
	SW6->W6_XSHIPME := cXSHIPME        //c 10
	SW6->W6_XCARGOR := dCargo          //D 8
	SW6->W6_XCARGOP := dCargoP         //D 8
	SW6->W6_XAUTOE  := dAutoE  
	SW6->W6_DT_ETD  := dETE
	SW6->W6_XATD    := cATD
	SW6->W6_DT_ETA  := dETA
	SW6->W6_XATA    := dXATA
	SW6->W6_ARMADOR := _CodArm
	SW6->W6_XCARRIE := cXCARRIE
	SW6->W6_IDENTVE := cIDENTVE
	SW6->W6_VIAGEM  := cVIAGEM
	SW6->W6_XREFARM := cXREFARM
	SW6->W6_HOUSE   := cHOUSE
	SW6->W6_ORIGEM  := cPortOri
	SW6->W6_DEST    := cPortDes
	SW6->W6_XMODCON := cModCon
	SW6->W6_XMCONT  := cXMCONT
	SW6->W6_XTIPOL  := cXTIPOL
	SW6->W6_XCONSC  := cXCONSC
	SW6->W6_XCEMERC := cXCEMERC
	SW6->W6_XTLDEM  := cXTLDEM
	SW6->W6_XANOTA  := mXANOTA
	SW6->W6_XCSTAT  := cXCSTAT
	SW6->W6_XCHOUSE := cXCHOUSE
	SW6->W6_XEUROPA := cXEUROPA
	SW6->W6_CONTA20 := nQtd20
	SW6->W6_CONTA40 := nQtd40
	SW6->W6_CON40HC := nQtd40HC
	SW6->W6_PESO_BR := Val(nPESO_BR)
	SW6->W6_OUT_CTN := Str(Int(nOUTCTN))

	SW6->(MsUnLock())

	MSMM(,58,,mVM_COMP,1,,,"SW6","W6_COMPLEM")

Return(_Ret)



/*/{Protheus.doc}   getToke1
    get Bearer Token using /token endpoint
    @type  Function
    @author A.Carlos
    @since Dez|2023
    @version 1.0
    @return cToken, character, Bearer Token
/*/
User Function getToke1()
    Local _cToken    As Character // Bearer Token
    Local cBaseURL   As Character // Base URL
    Local cPath      As Character // endpoint path
    Local cGrantType As Character // grant type
    Local cResponse  As Character // response
    Local cStatus    As Character // status code
    Local cError     As Character // error message
    Local oRest      As Object    // FWRest() object
    Local jResponse  As Json      // response JsonObject
    Local aHeader    As Array     // request header
    Local jBody      As Character // corpo

    cBaseURL   := SuperGetMV("CMV_EIC002",,"https://api.asiashipping.com.br/account/token/" )     //"https://api.asiashipping.com.br/account/token/"   // type here your base URL
    cGrantType := SuperGetMV("CMV_EIC003",,"password" )     //type here grant type to request "password"   

    cPath      := "?grant_type=" + cGrantType + "&username=" + cUserName + "&password=" + cPassword // type here token endpoint
    aHeader    := {} 
	jBody      := ''

	jBody := JsonObject():New()
	jBody["username"] := cUserName
	jBody["password"] := cPassword

	ConOut("corpo:")
	ConOut(jBody)
	ConOut("...")
    
	Aadd(aHeader, "Authorization: Basic " + cUserName + ":" + cPassword)
    Aadd(aHeader, "Content-Type: application/json")

    // FWRest() object
    oRest := FWRest():New(cBaseURL)
    oRest:setPath(cPath)
 
	oRest:SetPostParams(jBody:toJson())
    If (oRest:Post(aHeader))
        cResponse := oRest:GetResult()
        jResponse := JsonObject():New()
        If (ValType(jResponse:fromJson(cResponse)) == 'U')
            _cToken := jResponse['token']
        EndIf
    Else
        cError  := oRest:GetLastError()
        cStatus := oRest:GetHTTPCode()
    EndIf
Return _cToken

 
/*/{Protheus.doc} ZEIC25FH
Carrega os dados do Json e solicita a gravação na SW6
@type  Static Function
@author A.Carlos
@since 21/12/2023
@version version
@param param_name, _cUrlFH,_nTime,_aHeader
@return return_var, _lRet
@example
/*/
Static Function ZEIC25FH(_cUrlFH,_nTime,_aHeader,_Import,_Encer,_cChave)
Local _cAlias := GetNextAlias()
Local _aMsg	  := {}
Local _aHeaFH := {}  
Local _jBody  := ' '      // corpo

_jBody := JsonObject():New()
_jBody["username"] := cUsername
_jBody["password"] := cPassword

Aadd(_aHeaFH, "Authorization: Bearer " + _cToken )
Aadd(_aHeaFH,'Content-Type: application/json')
//Aadd(_aHeaFH,'Accept: application/json')

//_cProc  := Alltrim(SW6->W6_HAWB)
//_cChave := _Teste  //Alltrim(SW6->W6_HOUSE)

_cUrlFH += "?HouseBill="+_cChave
_cRet := Httpget(_cUrlFH, '', _nTime , _aHeaFH)

if Valtype(_cRet) = "U" .OR. Empty(_cRet)
	Aadd(_aMsg,"Não existe retorno do Host, excedido o numero de tentativa de conexão "+_cChave)
	Return .F.
EndIf

_oJSRet:FromJSON(_cRet)

If ValType(_oJSRet) <> "J"
	Aadd(_aMsg,"Não retornado Json da conexão "+_cUrlFH)
	Return .F.
Endif

If _oJSRet:GetJsonText("status") == "404"  //caso não venha com nenhuma msg
	_nMsg	:= 404
	_cMsg	:= "Processo não encontrado."
EndIf

_cHouse := AllTrim(_oJSRet:GetJsonText("HouseBill"))
BeginSql Alias _cAlias
	SELECT 	SW6.R_E_C_N_O_ NREGSW6
	FROM %table:SW6% SW6
	WHERE SW6.W6_FILIAL    = %XFilial:SW6%
		//AND SW6.W6_HOUSE   = %Exp:_cHouse%
		AND SW6.W6_DT_ENCE = %Exp:_Encer%
		AND SW6.W6_AGENTE  = %Exp:_Import% 
		AND SW6.W6_HOUSE   = %Exp:_cChave%
		AND SW6.%notDel%		  
EndSql 

If (_cAlias)->(Eof()) .Or. (_cAlias)->NREGSW6 == 0
	Aadd(_aMsg,"Somente processos da ASIA podem ser integrados. "+_cChave)
	_lRet :=  .F.
Else 
	//Posicionar na SW6 para gravar os dados
	ZEIC025GRV(_cHouse,(_cAlias)->NREGSW6) 

	_cMsg := "Integração realizada com sucesso !"
	MSGINFO( _cMsg, "[ZEICF025]" )
	_lRet :=  .T.
Endif 

If Select(_cAlias) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif  

Return _lRet
