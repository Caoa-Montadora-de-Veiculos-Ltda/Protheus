#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} CMVAUT07
//TODO WS de envio dos dados de condição de pagamento
@author marcos cavalaro
@since 22/10/2018
@version 1.0
@type function
/*/

User Function CMVAUT07()

Local cQuery  := ''
Local cUser   := ''
Local cPass   := ''
Local cRet    := ''
Local cErro   := ''
Local cWsURL  := ''
Local cSoap   := ''
Local aCBox   := {}            
Local nPos    := 0 
Local lRet    := .F.
Local cRetMsg := ''
Local oXml    := '' 
Local cError   := ''
Local cWarning := ''



Private _aMatriz := {"01","2010022001"}
Private lIsBlind := IsBlind() .OR. Type("__LocalDriver") == "U"
Private oWsdl


IF lIsBlind

	RpcSetType(3)
	RpcSetEnv(_aMatriz[1],_aMatriz[2])
	
	If !LockByName("CMVAUT07")
		Conout("JOB já em Execução : CMVAUT07 " + DTOC(dDATABASE) + " - " + TIME() )
		RpcClearEnv()
		Return
	EndIf
	
EndIF
cUser := SuperGetMV("CAOA_AW01",.T.,"")
cPass := SuperGetMV("CAOA_AW02",.T.,"")


dbSelectArea('VVR') // Grupo de modelo
VVR->(dbSetorder(2))


cQuery  := " SELECT A.*, R_E_C_N_O_ RECNOBF"
cQuery  += " FROM "+RetSQLname("SE4")+' A' 
cQuery  += " Where D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"qryCP",.T.,.T.)
dbSelectArea("qryCP")

cWsURL:= ALLTRIM(SuperGetMV("CAOA_WS003",.T.,''))


qryCP->(dbGoTop())
IF qryCP->(!EOF())
	oWsdl := TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.
	If !oWsdl:ParseURL( cWsURL )
		cRet  := '2'
		cErro := 'Não foi possivel Acessar o WSDL '+oWsdl:cError
		U_CAOA_MONITOR( cFilant,cRet,'001','006',cErro,'','0',cSoap ,0)
		freeObj(oWsdl)
		oWsdl := nil
		qryCP->(dbCloseArea())
		Return
	EndIF
	If !oWsdl:SetOperation('TipoPagamento')
		cRet  := '2'
		cErro := 'Não foi possivel setar a Operação TipoPagamento'+oWsdl:cError
		U_CAOA_MONITOR( cFilant  ,cRet,'001','006',cErro,'','0',cSoap ,0)
		freeObj(oWsdl)
		oWsdl := nil
		qryCP->(dbCloseArea())
		Return
	EndIF
	While qryCP->(!EOF())
		cSoap := '<x:Envelope xmlns:x="http://www.w3.org/2003/05/soap-envelope"  xmlns="http://tempuri.org/">'
		cSoap += "<x:Body>                                                                                    "
		cSoap += "        <TipoPagamento                                                          "
		cSoap += '            xmlns="http://tempuri.org/">                                        '
		cSoap += "            <ListaTipoPagamento>                                                       "
		cSoap += "                <DadosTipoPagamento>                                                   "
		cSoap += putTag('cdTipoPagamento',     Alltrim(qryCP->E4_CODIGO))
		cSoap += putTag('dsTipoPagamento',     Alltrim(qryCP->E4_DESCRI))
		cSoap += "                </DadosTipoPagamento>                                                  "
		cSoap += "            </ListaTipoPagamento>                                                      "
		cSoap += "        </TipoPagamento>                                                               "
		cSoap += "    </x:Body>                                                            "
		cSoap += "</x:Envelope>                                                            "		
		lRet := oWsdl:SendSoapMsg(cSoap)
		IF !lRet
			cRet  := '2'
			cErro := 'Não foi possivel enviar o XML '+oWsdl:cError
		Else
			cRetMsg := oWsdl:GetSoapResponse()
			cRetMsg := GetSimples( cRetMsg , "<RetornoTipoPagamento>", "</RetornoTipoPagamento>" )
			cCdRet  := GetSimples( cRetMsg , "<CdRetorno>", "</CdRetorno>" )
			cDsRet  := GetSimples( cRetMsg , "<DsRetorno>", "</DsRetorno>" )
			IF Empty(cRetMsg)
				cRet  := '2'
				cErro := 'Não encontrado mensagem de retorno'
			Else
				If Alltrim(cCdRet) == "1" .OR. Alltrim(cCdRet) == "0"
					cRet  := '1'
					cErro := 'Integrado com sucesso'
				Else
					cRet  := '2'
					cErro := Alltrim(cCdRet)+'-'+Alltrim(cDsRet)
				EndIF
			EndIF
		Endif
		U_CAOA_MONITOR( cFilant  ,cRet,'001','006',cErro, Alltrim(qryCP->E4_CODIGO) ,'0',cSoap ,qryCP->RECNOBF)
		qryCP->(dbSkip())
	EndDo
EndIF
 
freeObj(oWsdl)               
oWsdl := nil

qryCP->(dbCloseArea())

Return
*********************************************************************************************************
Static Function putTag(cTag,cValor) 
Local cRet := ''

cRet := '<'+cTag+'>'+cValor+'</'+cTag+'>'

Return cRet
 