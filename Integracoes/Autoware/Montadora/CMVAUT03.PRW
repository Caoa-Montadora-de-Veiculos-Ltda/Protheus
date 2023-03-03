#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} CMVAUT03
//TODO WS de envio dos dados do carro para autware (nro Chassi).
@author marcos cavalaro
@since 22/10/2018
@version 1.0
@type function
/*/

User Function CMVAUT03()

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
//Local oXml    := '' 
Local cError   := ''
Local cWarning := ''
Local cDtFab   := ''

cError   := ''
cWarning := ''


Private _aMatriz := {"01","2010022001"}
Private lIsBlind := IsBlind() .OR. Type("__LocalDriver") == "U"
Private oWsdl


IF lIsBlind

	RpcSetType(3)
	RpcSetEnv(_aMatriz[1],_aMatriz[2])
	
	If !LockByName("CMVAUT03")
		Conout("JOB já em Execução : CMVAUT03 " + DTOC(dDATABASE) + " - " + TIME() )
		RpcClearEnv()
		Return
	EndIf
	
EndIF
cUser := SuperGetMV("CAOA_AW01",.T.,"")
cPass := SuperGetMV("CAOA_AW02",.T.,"")


dbSelectArea('VVR') // Grupo de modelo
VVR->(dbSetorder(2))


cQuery  := "SELECT BF.*, V1.*,V2.*,B1.*,BF.R_E_C_N_O_ RECNOBF"
cQuery  += "FROM "+RetSQLname("SBF") +" BF,"+RetSQLname("VV1") +" V1,"+RetSQLname("VV2") + " V2, "+RetSQLname("SB1") + " B1"
cQuery  += "WHERE BF_NUMSERI    = VV1_CHASSI "
cQuery  += "  AND BF_XDTATU     = ' ' "         
cQuery  += "  AND VV1_CODMAR    = VV2_CODMAR "
cQuery  += "  AND VV1_MODVEI    = VV2_MODVEI "
cQuery  += "  AND VV1_SEGMOD    = VV2_SEGMOD "
cQuery  += "  AND B1_FILIAL     = '"+xFilial('SB1')+"'"
cQuery  += "  AND B1.B1_COD     = BF.BF_PRODUTO "
cQuery  += "  AND BF_NUMSERI    <> ' ' "
//cQuery  += "  AND BF.D_E_L_E_T_ <> '*' " 
cQuery  += "  AND V1.D_E_L_E_T_ <> '*' AND V2.D_E_L_E_T_ <> '*' AND B1.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QVEIC",.T.,.T.)
dbSelectArea("QVEIC")

cWsURL:= ALLTRIM(SuperGetMV("CAOA_WS001",.T.,"https://treinamento.caoamontadora.com.br/servicos/v2/chassi.asmx?WSDL"))  // 

VVF->(dbSetOrder(1))
QVEIC->(dbGoTop())
IF QVEIC->(!EOF())
	oWsdl := TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.
	If !oWsdl:ParseURL( cWsURL )
		cRet  := '2'
		cErro := 'Não foi possivel Acessar o WSDL '+oWsdl:cError
		U_CAOA_MONITOR( cFilant,cRet,'001','001',cErro,'','0',cSoap ,0)
		freeObj(oWsdl)
		oWsdl := nil
		QVEIC->(dbCloseArea())
		Return
	EndIF
	If !oWsdl:SetOperation('Enviar')
		cRet  := '2'
		cErro := 'Não foi possivel setar a Operação Enviar '+oWsdl:cError
		U_CAOA_MONITOR( cFilant  ,cRet,'001','001',cErro,'','0',cSoap ,0)
		freeObj(oWsdl)
		oWsdl := nil
		QVEIC->(dbCloseArea())
		Return
	EndIF
	aCBox := RetSX3Box(Posicione("SX3",2,"VV1_COMVEI","X3CBox()"),,,1)
	While QVEIC->(!EOF())
		cSoap := "<?xml version='1.0' encoding='UTF-8' standalone='no' ?>                         "
		cSoap += "<SOAP-ENV:Envelope                                                              "
		cSoap += '    xmlns:SOAP-ENV="http://www.w3.org/2003/05/soap-envelope"                    '
		cSoap += '    xmlns:SOAP-ENC="http://www.w3.org/2003/05/soap-encoding"                    '
		cSoap += '    xmlns:xsd="http://www.w3.org/2001/XMLSchema"                                '
		cSoap += '    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"                       '
		cSoap += '    xmlns:ns1="http://tempuri.org/">                                            '
		cSoap += "    <SOAP-ENV:Body>                                                             "
		cSoap += "        <Enviar                                                                "
		cSoap += '            xmlns="http://tempuri.org/">                                        '
		cSoap += "            <ListaChassi>                                                       "
		cSoap += "                <DadosChassi>                                                   "
		cSoap += putTag('Chassi',           Alltrim(QVEIC->BF_NUMSERI))
		cSoap += putTag('CdCorExterna',     Alltrim(QVEIC->VV2_COREXT))
		cSoap += putTag('DsCorExterna',     AllTrim(GetAdvFVal("VX5","VX5_DESCRI",xFilial('VX5')+'067'+QVEIC->VV2_COREXT,1,'')))
		cSoap += putTag('CdCorInterna',     Alltrim(QVEIC->VV2_CORINT))
		cSoap += putTag('DsCorInterna',     AllTrim(GetAdvFVal("VX5","VX5_DESCRI",xFilial('VX5')+'066'+QVEIC->VV2_CORINT,1,'')))
		cSoap += putTag('CdLinha',          Alltrim(QVEIC->VV2_GRUMOD))
		cSoap += putTag('DsLinha',          AllTrim(GetAdvFVal("VVR","VVR_DESCRI",xFilial('VVR')+QVEIC->VV2_CODMAR+QVEIC->VV2_GRUMOD,2,'')))
		cSoap += putTag('CdModeloComercial',Alltrim(QVEIC->VV2_SEGMOD) 			)
		cSoap += putTag('DsModeloComercial',AllTrim(GetAdvFVal("VVX","VVX_DESSEG",xFilial('VVX')+QVEIC->VV2_CODMAR+QVEIC->VV2_SEGMOD,1,'')))
		cSoap += putTag('CdModelo',         Alltrim(QVEIC->VV2_MODVEI)  )
		cSoap += putTag('DsModelo',         Alltrim(QVEIC->VV2_DESMOD))
		cSoap += putTag('NuMotor',          Alltrim(QVEIC->VV1_NUMMOT )         )
		cSoap += putTag('CdCombustivel',    Alltrim(QVEIC->VV1_COMVEI))
		cSoap += putTag('DsCombustivel',    IIf((nPos:=aScan(aCBox,{|x| Subs(x[1],1,1)==Alltrim(QVEIC->VV1_COMVEI)})) > 0,Upper(Alltrim(aCBox[nPos][3])),""))
		cSoap += putTag('Origem',           QVEIC->VV1_PROVEI)
		
		IF VVF->(dbSeek(xFilial("VVF")+QVEIC->VV1_TRACPA))
			cDtFab := DToS(VVF->VVF_DATFAB)
		Else
			cDtFab := DToS(dDataBase)
		EndIF
		cDtFab := SUBSTR(cDtFab,1,4)+"-"+SUBSTR(cDtFab,5,2)+"-"+SUBSTR(cDtFab,7,2)
		cSoap += putTag('DtProducao', cDtFab	  ) // Procurar na SD5 o numero de serie e pegar a data de emissão do doc.
		cSoap += putTag('DtEmbarque', cDtFab	  ) // Procurar na SD1 pelo CHASSI onde o tipo da nota é importação.
		cSoap += putTag('NuAnoModelo',      RIGHT(QVEIC->VV1_FABMOD,4))
		cSoap += putTag('NuAnoFabricacao',  LEFT(QVEIC->VV1_FABMOD,4)  )
		cSoap += putTag('CdCarroceria',     Alltrim(QVEIC->VV2_CATVEI) )
		cSoap += putTag('DsCarroceria',     AllTrim(GetAdvFVal("VV7","VV7_DESCRI",xFilial('VV7')+QVEIC->VV1_CARROC,1,'')))
		cSoap += putTag('DsProduto',        Alltrim(QVEIC->B1_DESC)    )
		cSoap += putTag('CdMarca',          Alltrim(QVEIC->VV1_CODMAR))
		cSoap += putTag('Marca',            AllTrim(GetAdvFVal("VE1","VE1_DESMAR",xFilial('VE1')+QVEIC->VV1_CODMAR,1,'')))
		cSoap += putTag('CdNCM',            QVEIC->VV1_POSIPI)
		cSoap += putTag('NuTransmissao',    QVEIC->VV1_CAMBIO)
		cSoap += "                </DadosChassi>                                                  "
		cSoap += "            </ListaChassi>                                                      "
		cSoap += "        </Enviar>                                                               "
		cSoap += "    </SOAP-ENV:Body>                                                            "
		cSoap += "</SOAP-ENV:Envelope>                                                            "
		
		lRet := oWsdl:SendSoapMsg(cSoap)
		IF !lRet
			cRet  := '2'
			cErro := 'Não foi enviar o XML '+oWsdl:cError
		Else
			cRetMsg := oWsdl:GetSoapResponse()
			cRetMsg := GetSimples( cRetMsg , "<ListaRetornoWSChassiDados>", "</ListaRetornoWSChassiDados>" )
			cCdRet  := GetSimples( cRetMsg , "<CdRetorno>", "</CdRetorno>" )
			cDsRet  := GetSimples( cRetMsg , "<DsRetorno>", "</DsRetorno>" )
			IF Empty(cRetMsg)
				cRet  := '2'
				cErro := 'Não encontrado mensagem de retorno'
			Else
				If Alltrim(cCdRet) == "1" .OR. Alltrim(cCdRet) == "0"
					cRet  := '1'
					cErro := 'Integrado com sucesso'
					dbSelectArea("SBF")
					dbGoto(QVEIC->RECNOBF)
					RecLock("SBF",.F.)
					SBF->BF_XDTATU:= dDataBase
					SBF->(MsUnlock())
				Else
					cRet  := '2'
					cErro := Alltrim(cCdRet)+'-'+Alltrim(cDsRet)
				EndIF
			EndIF
		Endif
		U_CAOA_MONITOR( cFilant  ,cRet,'001','001',cErro, Alltrim(QVEIC->BF_NUMSERI) ,'0',cSoap ,QVEIC->RECNOBF)
		QVEIC->(dbSkip())
	EndDo
EndIF
 
freeObj(oWsdl)               
oWsdl := nil

QVEIC->(dbCloseArea())

Return
*********************************************************************************************************
Static Function putTag(cTag,cValor) 
Local cRet := ''

cRet := '<'+cTag+'>'+cValor+'</'+cTag+'>'

Return cRet
 