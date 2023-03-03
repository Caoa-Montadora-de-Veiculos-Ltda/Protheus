#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} CMVAUT02
//TODO WS de envio dos dados do carro para autware (Xml Nota Fiscal).
@author marcos cavalaro
@since 25/10/2018
@version 1.0
@type function
/*/

User Function CMVAUT02()
Local cQuery  := ''
Local cRet    := ''
Local cErro   := ''
Local cWsURL  := ''
Local cSoap   := ''
Local lRet    := .F.
Local cRetMsg := ''
Local cXmlNf   := ''


Private _aMatriz := {"01","2010022001"}
Private lIsBlind := IsBlind() .OR. Type("__LocalDriver") == "U"
Private oWsdl


IF lIsBlind

	RpcSetType(3)
	RpcSetEnv(_aMatriz[1],_aMatriz[2])
		
	If !LockByName("CMVAUT02")
		Conout("JOB já em Execução : CMVAUT02 " + DTOC(dDATABASE) + " - " + TIME() )
		RpcClearEnv()
		Return
	EndIf
	
EndIF


cQuery := "SELECT F2.*, F2.R_E_C_N_O_ RECNOF2, A1.A1_CGC, VRJ_PEDCOM, VRJ_TIPVEN, VRK_FILIAL, VRK_PEDIDO"
cQuery += "FROM "+ RetSQLname("SF2") +" F2,"+ RetSQLname("SA1") +" A1 ,"+ RetSQLname("VV0") +" VV0 ,"+ RetSQLname("VRK") +" VRK ,"+ RetSQLname("VRJ") +" VRJ "      
cQuery += "WHERE F2.D_E_L_E_T_ = ' '  "
cQuery += "  AND A1.D_E_L_E_T_ = ' ' "
cQuery += "  AND VV0.D_E_L_E_T_=' ' "
cQuery += "  AND VRK.D_E_L_E_T_=' ' "
cQuery += "  AND VRJ.D_E_L_E_T_=' ' "
cQuery += "  AND A1.A1_FILIAL  = '"+xFilial('SA1')+"' "
cQuery += "  AND F2.F2_CLIENTE = A1.A1_COD "
cQuery += "  AND F2.F2_LOJA    = A1.A1_LOJA "
cQuery += "  AND VV0_FILIAL    = F2_FILIAL  "
cQuery += "  AND VV0_CODCLI    = F2_CLIENTE "
cQuery += "  AND VV0_LOJA      = F2_LOJA "
cQuery += "  AND VV0_NUMNFI    = F2_DOC "
cQuery += "  AND VV0_SERNFI    = F2_SERIE "
cQuery += "  AND VRK_FILIAL    = VV0_FILIAL "
cQuery += "  AND VRK_NUMTRA    = VV0_NUMTRA "
cQuery += "  AND VRJ_FILIAL    = VRK_FILIAL "
cQuery += "  AND VRJ_PEDIDO    = VRK_PEDIDO "
cQuery += "  AND F2.F2_XINTEG  = ' '  "
cQuery += "  AND F2_CHVNFE     <> ' ' " 
cQuery += "  AND F2_FIMP       = 'S'  "
//cQuery += "  AND F2_DOC        = '000323550' "
cQuery += "  ORDER BY F2_EMISSAO desc  "


cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"qryNF",.T.,.T.)
dbSelectArea("qryNF")

cWsURL:= ALLTRIM(SuperGetMV("CAOA_WS004",.T.,'https://treinamento.caoamontadora.com.br/servicos/v2/NotaFiscal.asmx?wsdl'))
qryNF->(dbGoTop())

IF qryNF->(!EOF())
	oWsdl := TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.
	If !oWsdl:ParseURL( cWsURL )
		cRet  := '2'
		cErro := 'Não foi possivel acessar o WSDL '+oWsdl:cError
		U_CAOA_MONITOR( cFilant,cRet,'001','004',cErro,'','0',cSoap ,0)
		freeObj(oWsdl)
		oWsdl := nil
		qryNF->(dbCloseArea())
		Return
	EndIF
	aOps := oWsdl:ListOperations()
	If !oWsdl:SetOperation('Enviar')
		cRet  := '2'
		cErro := 'Não foi possivel setar a Operação Enviar '+oWsdl:cError
		U_CAOA_MONITOR( cFilant  ,cRet,'001','004',cErro,'','0',cSoap ,0)
		freeObj(oWsdl)
		oWsdl := nil
		qryNF->(dbCloseArea())
		Return
	EndIF
	While qryNF->(!EOF())
	    cFilAnt := qryNF->F2_FILIAL
	    IF UsaColaboracao("1" )
	    	cXmlNf:= XML_COL()
	    Else
	        cXmlNf:= fConsXml(qryNF->F2_DOC, qryNF->F2_SERIE, qryNF->F2_EMISSAO, qryNF->A1_CGC)
	    EndIF
		cSoap := ''
		IF !Empty(cXmlNf)
		    cXMLnf := Encode64(cXmlNf)
			cSoap := " "
			cSoap := "<?xml version='1.0' encoding='UTF-8' standalone='no' ?>                         "
			//cSoap += '<x:Envelope xmlns:x="http://schemas.xmlsoap.org/soap/envelope/" xmlns="http://tempuri.org/">'
			cSoap += '<x:Envelope xmlns:x="http://www.w3.org/2003/05/soap-envelope"  xmlns="http://tempuri.org/">'
			cSoap += "    <x:Body>                                                             "
			cSoap += "        <Enviar                                                                "
			cSoap += '            xmlns="http://tempuri.org/">                                        '
			cSoap += "            <ListaNotaFiscal>                                                       "
			cSoap += "                <DadosNotaFiscal>                                                   "
			cSoap += putTag('xmlDANFE',cXMLnf)
			cSoap += putTag('tipo',           Alltrim(qryNF->VRJ_TIPVEN))
			//cSoap += putTag('tipo', 'vendaVeiculoVarejo')
		    //cSoap += putTag('Pedido',VRJ->VRJ_PEDCOM)
		    cSoap += "                </DadosNotaFiscal>                                                  "
			cSoap += "            </ListaNotaFiscal>                                                      "
			cSoap += "        </Enviar>                                                               "
			cSoap += "    </x:Body>                                                            "
			cSoap += "</x:Envelope>                                                            "
			
			lRet := oWsdl:SendSoapMsg(cSoap)
			IF !lRet
				cRet  := '2'
				cErro := 'Não foi possivel enviar o XML '+oWsdl:cError
			Else
				cRetMsg := Upper( oWsdl:GetSoapResponse() )
				cRetMsg := GetSimples( cRetMsg , "<RETORNOWSNOTAFISCALDADOS>", "</RETORNOWSNOTAFISCALDADOS>" )
				cCdRet  := GetSimples( cRetMsg , "<CDRETORNO>", "</CDRETORNO>" )
				cDsRet  := GetSimples( cRetMsg , "<DSRETORNO>", "</DSRETORNO>" )
				IF Empty(cRetMsg)
					cRet  := '2'
					cErro := 'Não encontrado mensagem de retorno'
				Else
					If Alltrim(cCdRet) == "1" .OR. Alltrim(cCdRet) == "0"
						cRet  := '1'
						cErro := 'Integrado com sucesso'
						dbSelectArea("SF2")
						SF2->(dbGoto(qryNF->RECNOF2))
						RecLock("SF2",.F.)
						SF2->F2_XINTEG := 'I'
						SF2->(MsUnlock())
					Else
						cRet  := '2'
						cErro := Alltrim(cCdRet)+'-'+Alltrim(cDsRet)
					EndIF
				EndIF
			Endif
		Else
			cRet  := '2'
			cErro := 'Não foi possivel gerar o  XML !'
		EndIF
		U_CAOA_MONITOR( cFilant  ,cRet,'001','004',cErro, Alltrim(qryNF->F2_DOC+qryNF->F2_SERIE) ,'0',cSoap ,qryNF->RECNOF2)
		qryNF->(dbSkip())
	EndDo
EndIF
 
freeObj(oWsdl)               
oWsdl := nil

qryNF->(dbCloseArea())

Return
*********************************************************************************************************
Static Function putTag(cTag,cValor) 
Local cRet := ''

cRet := '<'+cTag+'>'+cValor+'</'+cTag+'>'

Return cRet

**********************************************************************************************************
Static Function fConsXml(cNroDoc, cSerie, dEmissao, cCNPJ )

Local cIdEnt := GetIdEnt()
Local cURLTss:= PADR("http://187.94.53.132:11381/tss_prd",250)//PadR(GetNewPar("MV_SPEDURL","http://"),250) 
Local cCab1
Local cRodap
Local cXml         := ''
Local cDocumento := PadR(cNroDoc, TamSX3('F2_DOC')[1])

cSerie     := PadR(cSerie,  TamSX3('F2_SERIE')[1])


oWS:= WSNFeSBRA():New() 
oWS:cUSERTOKEN        := "TOTVS" 
oWS:cID_ENT           := cIdEnt 
oWS:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw" 
oWS:oWSNFEID          := NFESBRA_NFES2():New()
oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
aAdd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
aTail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
oWS:dDataDe           := StoD(dEmissao) // dDataDe 
oWS:nDiasparaExclusao := 0 

//lOk := oWS:RETORNAFX() 

//oRetorno := oWS:oWsRetornaFxResult 

If oWS:RetornaNotas()
 
   if Len(oWS:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0 
   
      oXml := oWS:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                
      cCab1 := '<?xml version="1.0" encoding="UTF-8"?>'
      cCab1 += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
      cRodap:= '</nfeProc>' 
      cXml := AllTrim(cCab1) 
      cXml += AllTrim(oXml:oWSNFe:cXML) 
      cXml += AllTrim(oXml:oWSNFe:cXMLPROT) 
      cXml += AllTrim(cRodap) 
    EndIf   

Else
   ConOut(IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"...")
EndIf 
 

Return(cXml)
**********************************************************************************************************
Static Function XML_COL()

Local cXml       := ''
Local aInfXml    := {}

SF2->(dbGoto(qryNF->RECNOF2))					

cXML := ""						
aInfXml	:= {}
aInfXml := ColExpDoc(qryNF->F2_SERIE,qryNF->F2_DOC,"NFE",@cXml) 

If aInfXMl[1]
    cXML := aInfXMl[3]
EndIF

Return(cXml)

Static Function GetIdEnt(lUsaColab)

local cIdEnt := ""
local cError := ""

Default lUsaColab := .F.

If !lUsaColab
	cIdEnt := getCfgEntidade(@cError)
	If(empty(cIdEnt))
		Aviso("SPED", cError, {"Ok"}, 3)
	EndIf
Else
	If !( ColCheckUpd() )
		Aviso("SPED", "UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0",{"Ok"},3)
	Else
		cIdEnt := "000000"
	EndIf
endIf

Return(cIdEnt)
