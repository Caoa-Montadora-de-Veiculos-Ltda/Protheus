#Include "TOTVS.CH"
#Include "TopConn.CH"
#Include "RESTFUL.CH"
#Include "RWMAKE.Ch"
#Include "TBICONN.CH"
#Include "Parmtype.ch"
#Include "PROTHEUS.CH"
#Include "FWMBROWSE.CH"
#INCLUDE "APWEBSRV.CH"

/*/{Protheus.doc} ZEICF025
Integra��o  Asia Shipping - Followup-House  recebimento de mercadorias 
@author 	A.Carlos
@since 		21/12/2023
@version 	undefined
@param		_lJob
@type 		User Function
@client   	CAOA 
@return   	_aMsg - Array com retorno Json c�digo e ocorrencia
@project 	Interfaces_PortalV3_v2 x Protheus v2
            https://api.asiashipping.com.br/followup/House
Z	-Customizado
EIC	- Modulo
F 	- Fun��o
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
Chamado pela fun��o ZEICF025 integra��o  Asia Shipping - Followup-House  busca de Token para autentica��o 
@author 	A.Carlos
@since 		21/12/2023
@version 	undefined
@param		_cUrl, _cChave, _lToken, _lJob
@type 		User Function
@client   	CAOA 
@return   	Token para autentica��o
*/
Static Function ZEICF025AP(_cUrl, _cChave, _lToken, _lJob)
Local _aMsg		:= {}
Local _lRet 	:= .T.

Private cUserName   := SuperGetMV("CMV_EIC004",,"Caoa")     // type here user name     "Caoa"         
Private cPassword   := SuperGetMV("CMV_EIC005",,"bRTxqzUyJwN5BnT")     // type here user password    "bRTxqzUyJwN5BnT" 

Default _cChave := " "                    ///"SHA23090924"          //informa��es como numero da House

Default _cUrlFH	:= "https://api.asiashipping.com.br"      // GETMV("CMV_EIC001")   ///"https://api.asiashipping.com.br/followup/House"
//apihomolog.asiashipping.com.br base homologa��o
//Default _cUrlFS	:= "https://api.asiashipping.com.br/followup/Shipment"
//Default _cUrlOR	:= "https://api.asiashipping.com.br/bot/OrderRef"
//esses 03 �ltimos URL necessitam de Token

Conout("INICIANDO FUNCIONALIDADE ZEICF025 - Asia Shipping em "+DtoC(Date())+" as "+Time())
_lRet := ZEICF025PR( _cUrl, _cChave, _lToken, _aMsg, _lJob )

IF Len(_aMsg) > 0 		
	//Tratar erros aqui
    SetMsgRet(_aMsg)	
EndIf

Conout("TERMINO FUNCIONALIDADE ZEICF025 - Asia Shipping em "+DtoC(Date())+" as "+Time())
Return Nil


/*/{Protheus.doc} ZEICF025PR
Chamado pela fun��o ZEICF025AP gera Token 
@author 	A.Carlos
@since 		21/12/2023
@version 	undefined
@param 		_cUrl, _cChave, _lToken, _aMsg, _lJob
@type 		function
@ Obs		Os paremetros de token, usu�rio e senha ser�o enviados no cabe�alho 
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
	_cChave := SW6->W6_HOUSE     //"SHA23090924"  //informa��es como numero da House

	Aadd(_aHeader,"Authorization: Basic " + Encode64(_cUserAut + ":" + _cPassAut))
	Aadd(_aHeader,'Content-Type: application/json; charset=utf-8')
	Aadd(_aHeader,'Accept: application/json')

	If _lToken
	    
		_cToken := U_getToke1()
		
		if Valtype(_cToken) = "U"
			Aadd(_aMsg,"N�o existe retorno do Host Token, excedido o numero de tentativas de conex�o ")
			Return .F.
		else
			Aadd(_aHeader,'Authorization:' + _cToken )
		EndIf

		//Montar o token e acrescentar no cabe�alho _aHeader para acessar as APIs protegidas
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
Local _jBody  := ' '     

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
       Conout("ZEICF025 - Integra�ao ASIA SHIPPING - JOB Inicio "+DtoC(date())+" "+Time())

		While (_cAliasJ)->(!Eof()) 

		    _cUrl   := _sUrl
	 	    _cChave := Alltrim((_cAliasJ)->cBL)

			If !Empty(_cChave)
				_cUrl += "/"+_cChave
			Endif

			_cRet := Httpget(_cUrl, ' ', _nTime , _aHeaFH)

			if ValType(_cRet) = "U" .OR. Empty(_oJSRet) 
			    Conout("ZEICF025 - N�o existe retorno do Host, excedido o numero de tentativa de conex�o ")
				(_cAliasJ)->(DbSkip())
				LOOP
			EndIf

			_oJSRet:FromJSON(_cRet)
			
			If ValType(_oJSRet) <> "J"
				Conout("ZEICF025 - N�o retornado Json da conex�o "+_cUrl)
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

	Conout("ZEICF025 - Integra�ao ASIA SHIPPING - Fim "+DtoC(date())+" "+Time())

Return _lRet


/*/{Protheus.doc} SetMsgRet
Seta mensagem retorno de msg do rest
@author A.Carlos
@since 21/12/23
@version undefined
@param _aMsg, array, descri��o
@type function
/*/
Static function SetMsgRet(_aMsg) 
Local _nMsg  := 500
Local _cMsg  := ""
Local _nPos

//Begin Sequence
	If Len(_aMsg) == 0  //caso n�o venha com nenhuma msg
		_nMsg	:= 500
		_cMsg	:= "problemas na identifica�ao do erro, n�o processado !"
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
Chamado pela fun��o ZEICF025PR posicionar na SW6 para gravar os dados
@author A.Carlos
@since 21/12/2023
@version undefined
@param House, NREGSW6
@type function
/*/
Static function ZEIC025GRV(_cHouse,NREGSW6) 
Local _Ret     := ' '
Local _nContai := ' '
Local _CodArm  := ' '
Local _nX      := 0
Local _nY      := 0
Local _nTleg   := 0
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
Local dAutoE   := CTOD("  /  /    ")   // W6_XAUTOE    //Data de autoriza��o de envio
Local dETE     := CTOD("  /  /    ")   //W6_DT_ETD    //ETD - Origem (Estimativa de Saida)
Local cATD     := CTOD("  /  /    ")   //W6_XATD      //ATD - Origem (Data real Disponivel para Entrega)
Local dETA     := CTOD("  /  /    ")   //W6_DT_ETA    //ETA - Destino (Estimado de Chegada)
Local dXATA    := CTOD("  /  /    ")   //W6_XATA      //ATA - Destino (Atraca��o)
Local dXCVAZ   := CTOD("  /  /    ")   //W6_XATA      //EmptyToShipper - Data Containner vazio
Local dXPRONT  := CTOD("  /  /    ")   //W6_XDTPRONT  //CargoReadyActual - Data prontidao da carga
Local cPortOri := ' '                  //W6_ORIGEM    //Porto Origem
Local cPortDes := ' '                  //W6_DEST      //Porto Destino
Local cXCARRIE := ' '                  //W6_XCARRIE   //Nome do armador
Local cIDENTVE := ' '                  //W6_IDENTVE   //Navio
Local cVIAGEM  := ' '                  //W6_VIAGEM    //Viagem
Local cXREFARM := ' '                  //W6_XREFARM   //Refer�ncia do armador
Local cHOUSE   := ' '                  //W6_HOUSE     //Conhecimento de House
Local mVM_COMP := ' '                  //W6_VM_COMP   //Descri��o detalhada dos bens
Local nPESO_BR := 0                    //W6_PESO_BR   //Peso bruto
Local cModCon  := ' '                  //W6_XMODCON   //Modalida de Container
Local cXMCONT  := ' '                  //W6_XMCONT    //Modo de cont�iner
Local cXTIPOL  := ' '                  //W6_XTIPOL    //Tipo de libera��o
Local cXCONSC  := ' '                  //W6_XCONSC    //N�mero de consolida��o da carga
Local cXCEMERC := ' '                  //W6_XCEMERC   //CE Mercante
Local cXTLDEM  := ' '                  //W6_XTLDEM    //Tempo livre de demurrage
Local mXANOTA  := ' '                  //W6_XANOTA    //Anota��es do Agente
Local cXCSTAT  := ' '                  //W6_XCSTAT    //Status da carga
Local cXCHOUSE := ' '                  //W6_XCHOUSE   //Conhecimento de House recebido (Sim/N�o)
Local cXEUROPA := ' '                  //W6_XEUROPA   //Se carga � Via Europa
Local cCONEVE1 := ' '                  //LegVessel
Local cXLV1	   := ' '                  //LegVoyage
Local cXLTM1   := ' '                  //LegTransportMode	
Local cXLED1   := CTOD("  /  /    ")   //LegEstimateDeparture	
Local cXLAD1   := CTOD("  /  /    ")   //LegActualDeparture	
Local cXLEA1   := CTOD("  /  /    ")   //LegEstimateArrival
Local cXLAA1   := CTOD("  /  /    ")   //LegEstimateArrival	
Local cXLLP1   := ' '                  //LegActualArrival	
Local cXLDP1   := ' '                  //LegLoadPort	
Local cCONEVE2 := ' '                  //
Local cXLV2    := ' '                  //	
Local cXLTM2   := ' '                  //	
Local cXLED2   := CTOD("  /  /    ")   //LegEstimateArrival                  //	
Local cXLAD2   := CTOD("  /  /    ")   //LegEstimateArrival                  //	
Local cXLEA2   := CTOD("  /  /    ")   //LegEstimateArrival                  //	
Local cXLAA2   := CTOD("  /  /    ")   //LegEstimateArrival                  //	
Local cXLLP2   := ' '                  //	
Local cXLDP2   := ' '                  //	

    SW6->(dbGoto(NREGSW6))  //Posicionar no registro da SW6

    cXSHIPME   := _oJSRet:GetJsonText("ShipmentNum")
	nEIHQTD    := _oJSRet:GetJsonText("PacksQTD")
	cXPTYPE    := _oJSRet:GetJsonText("PacksType")
	nMT3       := _oJSRet:GetJsonText("VolQTD")
	dCargo     := CTOD(_oJSRet:GetJsonText("CargoReadyEstimate"))
	dCargoP    := CTOD(_oJSRet:GetJsonText("CargoReadyActual"))
	dAutoE     := CTOD(_oJSRet:GetJsonText("ShipAuthorizationDate"))
	dETE       := CTOD(_oJSRet:GetJsonText("EstimateDeparture"))
	dETA       := CTOD(_oJSRet:GetJsonText("EstimateArrival"))
	dXATA      := CTOD(_oJSRet:GetJsonText("ActualArrival"))
	cATD       := CTOD(_oJSRet:GetJsonText("ActualDeparture"))
	dXPRONT    := CTOD(_oJSRet:GetJsonText("CargoReadyActual"))
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
		SJF->JF_XPTYPE := cXPTYPE         //c Criar o campo 
		SJF->(MsUnLock())
    Endif 

    SY5->(DbSetOrder(2))      //Y5_FILIAL+Y5_NOME                                                                                                                                                                                                                                                                               
    If SY5->(DbSeek(xFilial("SY5")+cXCARRIE))
        _CodArm := SY5->Y5_COD
    Else
        _CodArm := Space(06)
    Endif 

    If !Empty(_oJSRet['Containers'])
      
		_nContai := Len(_oJSRet['Containers'])

		cConType := ''
		nQtdeTtl := 0
		nOUTCTN  := 0
		nQtd40HC := 0
		nQtd40   := 0
		nQtd20   := 0

		FOR _nX := 1 TO _nContai   //Loop de Containner
			nQtde    := Val(_oJSRet["Containers"][_nX]["ContainerQTD"])
			cConType := Alltrim(_oJSRet["Containers"][_nX]["ContainerType"])

            IF _nX = 1
                dXCVAZ := CTOD(SUBSTR(_oJSRet["Containers"][_nX]["EmptyToShipper"],1,10))
            ENDIF

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
				SJD->JD_ARMADOR := Substr(_CodArm,3,3)  //Ainda n�o tem o De x Para
				SJD->JD_CADEADO := '000'  //Ainda n�o tem
				SJD->JD_DEVOLUC := CTOD(SUBSTR(_oJSRet["Containers"][_nX]["DevContVazio"],1,10)) 
				SJD->JD_LACRE   := Alltrim(_oJSRet["Containers"][_nX]["ContainerSelo"])												    
				SJD->JD_TIPO_CT := cTipoCT	
				SJD->JD_QTD_REC := nQtdeTtl
				SJD->(MsUnLock())
			ENDIF

		NEXT _nX

    Endif

    If !Empty(_oJSRet['TransportLegs'])
      
		_nTleg := Len(_oJSRet['TransportLegs'])

		FOR _nY := 1 TO _nTleg   //Loop de Leg de Transporte

			IF _nY = 1

				cCONEVE1 := _oJSRet["TransportLegs"][_nY]["LegVessel"]
				cXLV1	 := _oJSRet["TransportLegs"][_nY]["LegVoyage"]
				cXLTM1	 := _oJSRet["TransportLegs"][_nY]["LegTransportMode"]
				cXLED1	 := CTOD(_oJSRet["TransportLegs"][_nY]["LegEstimateDeparture"])
				cXLAD1	 := CTOD(_oJSRet["TransportLegs"][_nY]["LegActualDeparture"])
				cXLEA1	 := CTOD(_oJSRet["TransportLegs"][_nY]["LegEstimateArrival"])
				cXLAA1	 := CTOD(_oJSRet["TransportLegs"][_nY]["LegActualArrival"])
				cXLLP1	 := _oJSRet["TransportLegs"][_nY]["LegLoadPort"]
				cXLDP1	 := _oJSRet["TransportLegs"][_nY]["LegDischargePort"]
			
			ENDIF

			IF _nY = 2

				cCONEVE2 := _oJSRet["TransportLegs"][_nY]["LegVessel"]
				cXLV2	 := _oJSRet["TransportLegs"][_nY]["LegVoyage"]
				cXLTM2	 := _oJSRet["TransportLegs"][_nY]["LegTransportMode"]
				cXLED2	 := CTOD(_oJSRet["TransportLegs"][_nY]["LegEstimateDeparture"])
				cXLAD2	 := CTOD(_oJSRet["TransportLegs"][_nY]["LegActualDeparture"])
				cXLEA2	 := CTOD(_oJSRet["TransportLegs"][_nY]["LegEstimateArrival"])
				cXLAA2	 := CTOD(_oJSRet["TransportLegs"][_nY]["LegActualArrival"])
				cXLLP2	 := _oJSRet["TransportLegs"][_nY]["LegLoadPort"]
				cXLDP2	 := _oJSRet["TransportLegs"][_nY]["LegDischargePort"]
			
			ENDIF

		NEXT _nY		

    EndIf

	SW6->(RecLock("SW6",.F.))
	SW6->W6_MT3     := Val(nMT3)       //n 8,2
	SW6->W6_XSHIPME := cXSHIPME        //c 10
	SW6->W6_XCARGOR := dCargo          //D 8
	SW6->W6_XCARGOP := dCargoP         //D 8
	SW6->W6_XAUTOE  := dAutoE  
	SW6->W6_XATD    := cATD
	SW6->W6_XATA    := dXATA
	SW6->W6_ARMADOR := cXCARRIE        //_CodArm
	//SW6->W6_DT_ETD  := dETE
	//SW6->W6_DT_ETA  := dETA
	//SW6->W6_XCARRIE := cXCARRIE
	//SW6->W6_HOUSE   := cHOUSE
	//SW6->W6_XCEMERC := cXCEMERC
	//SW6->W6_XTLDEM  := cXTLDEM
	SW6->W6_IDENTVE := cIDENTVE
	SW6->W6_VIAGEM  := cVIAGEM
	SW6->W6_XREFARM := cXREFARM
	SW6->W6_ORIGEM  := cPortOri
	SW6->W6_DEST    := cPortDes
	SW6->W6_XMODCON := cModCon                //Modelo Containner 
	SW6->W6_XMCONT  := cXMCONT                //Descri��o Containner
	SW6->W6_XTIPOL  := cXTIPOL                //Tipo Lan�amento
	SW6->W6_XCONSC  := cXCONSC                //Consolidacao
	SW6->W6_XANOTA  := U_ZREMXML(mXANOTA)     // mXANOTA   
	SW6->W6_XCSTAT  := cXCSTAT                //Status Carga Transportado
	SW6->W6_XCHOUSE := cXCHOUSE
	SW6->W6_XEUROPA := cXEUROPA
	SW6->W6_CONTA20 := nQtd20
	SW6->W6_CONTA40 := nQtd40
	SW6->W6_CON40HC := nQtd40HC
	SW6->W6_XDTCVAZ := dXCVAZ
	SW6->W6_XDTPRONT:= dXPRONT
	SW6->W6_PESO_BR := Val(nPESO_BR)
	SW6->W6_OUT_CTN := Str(Int(nOUTCTN))
	SW6->W6_CONEVE1 := cCONEVE1 
	SW6->W6_XLV1    := cXLV1	 
	SW6->W6_XLTM1   := cXLTM1
	SW6->W6_CONEET1 := cXLED1	
	SW6->W6_XLED1   := cXLED1	 
	SW6->W6_XLAD1   := cXLAD1	 
	SW6->W6_XLEA1   := cXLEA1	 
	SW6->W6_XLAA1   := cXLAA1	 
	SW6->W6_XLLP1   := cXLLP1
	SW6->W6_CONEPO1 := cXLLP1 	 
	SW6->W6_XLDP1   := cXLDP1	 
	SW6->W6_CONEVE2 := cCONEVE2 
	SW6->W6_XLV2	:= cXLV2	 
	SW6->W6_XLTM2   := cXLTM2	 
	SW6->W6_CONEET2 := cXLED2
	SW6->W6_XLED2	:= cXLED2	 
	SW6->W6_XLAD2   := cXLAD2	 
	SW6->W6_XLEA2   := cXLEA2	 
	SW6->W6_XLAA2   := cXLAA2	
	SW6->W6_CONEPO2 := cXLLP2 	 
	SW6->W6_XLLP2   := cXLLP2	 
	SW6->W6_XLDP2   := cXLDP2

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

    cBaseURL   := SuperGetMV("CMV_EIC002",,"https://apihomolog.asiashipping.com.br/" )  //"https://api.asiashipping.com.br/account/token/"       //"https://api.asiashipping.com.br/account/token/"   // type here your base URL
    cGrantType := SuperGetMV("CMV_EIC003",,"password" )     //type here grant type to request "password"   
    
	//cPath      := "token?grant_type=" + cGrantType + "&username=" + cUserName + "&password=" + cPassword // type here token endpoint

    cPath := "account/token/??grant_type%3D=" + cGrantType   
	   
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
Carrega os dados do Json e solicita a grava��o na SW6
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
Local _jBody  := ' '      

_jBody := JsonObject():New()
_jBody["username"] := cUsername
_jBody["password"] := cPassword

Aadd(_aHeaFH, "Authorization: Bearer " + _cToken )
Aadd(_aHeaFH,'Content-Type: application/json')

//_cProc  := Alltrim(SW6->W6_HAWB)
//_cChave := _Teste  //Alltrim(SW6->W6_HOUSE)

_cUrlFH += "/followup/House?HouseBill="+_cChave  //Acessar o House ap�s autoriza��o

_cRet := Httpget(_cUrlFH, '', _nTime , _aHeaFH)

if Valtype(_cRet) = "U" .OR. Empty(_cRet)
	Aadd(_aMsg,"N�o existe retorno do Host, excedido o numero de tentativa de conex�o "+_cChave)
	Return .F.
EndIf

_oJSRet:FromJSON(_cRet)

If ValType(_oJSRet) <> "J"
	Aadd(_aMsg,"N�o retornado Json da conex�o "+_cUrlFH)
	Return .F.
Endif

If _oJSRet:GetJsonText("status") == "404"  //caso n�o venha com nenhuma msg
	_nMsg	:= 404
	_cMsg	:= "Processo n�o encontrado."
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

	_cMsg := "Integra��o realizada com sucesso !"
	MSGINFO( _cMsg, "[ZEICF025]" )
	_lRet :=  .T.
Endif 

If Select(_cAlias) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif  

Return _lRet
