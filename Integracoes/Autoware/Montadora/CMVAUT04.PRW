#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} CMVAUT04
//TODO WS de envio dos dados do status do atendimento
@author marcos cavalaro
@since 25/10/2018
@version 1.0
@type function
@Obs 		GAP228 -  GAP228 -Integração Faturamento Autoware
						lteração trocar tabela VRK Por SC6 - DAC AGO/2024

/*/

User Function CMVAUT04(aParam01)

Local cQryVRJ 		:= ''
Local cAlsVRJ		:= GetNextAlias()
Local cRet    		:= ''
Local cErro   		:= ''
Local cWsURL  		:= ''
Local cSoap   		:= ''
Local lRet    		:= .F.
Local cRetMsg 		:= ''
Local cRetStatus    := ""
Local cRetComp      := ""
Local cPedVRJ		:= ""
Local lMsg			:= .F.

Private _aMatriz := {"01","2010022001"}
Private lIsBlind := IsBlind() .OR. Type("__LocalDriver") == "U"
Private oWsdl

// Só executa quando é realizado pelas Rotinas 
// - ZVEIF003 - Botão na Tela de Pedido de Venda Montadora.
// - VX002FIN - Ponto de Entrada que dispara a integração individual para cada pedido.
// Dispara a integração somente do pedido selecionado.
If FWIsInCallStack("U_ZVEIF003") .Or. FWIsInCallStack("U_VX002FIN") .or. FWIsInCallStack("U_ZFATF019") 

	cPedVRJ := aParam01
	lMsg	:= .T.

ElseIf lIsBlind

		RpcSetType(3)
		RpcSetEnv(_aMatriz[1],_aMatriz[2])
	
		If !LockByName("CMVAUT04")
			Conout("JOB em Execucao : CMVAUT04 " + DTOC(dDATABASE) + " - " + TIME() )
			RpcClearEnv()
			Return()
		EndIf

		cPedVRJ := ""
EndIf

cQryVRJ  := " "
cQryVRJ  += " SELECT * FROM "+RetSQLname("SC6") +" SC6 "							+ CRLF
cQryVRJ  += " WHERE SC6.C6_FILIAL =  '"+xFilial('SC6')+"' "							+ CRLF
If !Empty(cPedVRJ)
	cQryVRJ  += " AND SC6.C6_PEDCLI  =  '" + cPedVRJ + "' "							+ CRLF
Else
//tem que verificar SC6 com status para defiinir envio  possibilidade de utilização de Case
	cQryVRJ  += " AND SC6.C6_DOC NOT IN ('P','O','L') "							+ CRLF //P=Pend.Aprovacao; O=Pre-Aprovado; L=Aprovado
	cQryVRJ  += " AND SC6.C6_XINTEG NOT IN ('E','X') "								+ CRLF //E=Envio com Erro; X=ProcessamentoAutomatico
	cQryVRJ  += " AND VRJ.VRJ_XINTEG <> VRJ.VRJ_STATUS "							+ CRLF
	cQryVRJ  += " AND VRJ.VRJ_TIPVEN  = '01' "										+ CRLF
	cQryVRJ  += " AND VRJ.VRJ_PEDCOM  <> ' ' "										+ CRLF
EndIf
cQryVRJ  += " AND VRJ.D_E_L_E_T_ = ' ' "											+ CRLF
cQryVRJ  += " ORDER BY VRJ.VRJ_PEDIDO "												+ CRLF						

cQryVRJ := ChangeQuery(cQryVRJ)

// Executa a consulta.
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryVRJ), cAlsVRJ, .T., .T. )

cWsURL:= ALLTRIM(SuperGetMV("CAOA_WS003",.T.,'https://treinamento.caoamontadora.com.br/servicos/v2/PedidoVeiculo.asmx?WSDL'))

DbSelectArea((cAlsVRJ))
(cAlsVRJ)->(dbGoTop())
If (cAlsVRJ)->(!EOF())
   
	oWsdl := TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.

	If !oWsdl:ParseURL( cWsURL )

		If lMsg
			MsgInfo( "Erro de conexão com Autoware" + CRLF + CRLF +  "Não foi possivel realizar a conexão com o WS Autoware - Entre em contato com o adm do sistema IMEDIATAMENTE."+ CRLF + CRLF + "URL: "+ALLTRIM(cWsURL)+ CRLF + CRLF + "ERRO: "+ AllTrim(oWsdl:cError) , "CMVAUT04" )
		EndIf

		cRet  := '2'
		cErro := 'NÃ£o foi possivel Acessar o WSDL '+oWsdl:cError

		U_CAOA_MONITOR( cFilant,cRet,'001','003',cErro,'','0',cSoap ,0)
		
		freeObj(oWsdl)
		oWsdl := nil
		
		(cAlsVRJ)->(dbCloseArea())
		Return()

	EndIf

	If !oWsdl:SetOperation('Status')

		cRet  := '2'
		cErro := 'NÃ£o foi possivel setar a OperaÃ§Ã£o Status '+oWsdl:cError
		U_CAOA_MONITOR( cFilant  ,cRet,'001','003',cErro,'','0',cSoap ,0)

		freeObj(oWsdl)
		oWsdl := nil

		(cAlsVRJ)->(dbCloseArea())
		Return()

	EndIf

	While (cAlsVRJ)->(!EOF())
		
		cCodStatus	:= " "
		cDescStatus	:= " "

		//A=Em Aberto;P=Pend.Aprovacao;O=Pre-Aprovado;L=Aprovado;R=Reprovado;F=Finalizado;C=Cancelado      
		
		IF (cAlsVRJ)->VRJ_STATUS == "A"                               
			cCodStatus	:= "PVAA"
			cDescStatus	:= "ALTERACAO STATUS - ABERTO"
		ElseIf (cAlsVRJ)->VRJ_STATUS == "P" 
			cCodStatus	:= "PVAP"
			cDescStatus	:= "ALTERACAO STATUS - PENDENTE APROVACAO"
		ElseIf (cAlsVRJ)->VRJ_STATUS == "O" 
			cCodStatus	:= "PVAO"
			cDescStatus	:= "ALTERACAO STATUS - PRE APROVADO"
		ElseIf (cAlsVRJ)->VRJ_STATUS == "L" 
			cCodStatus	:= "PVAL"
			cDescStatus	:= "ALTERACAO STATUS - APROVADO"
		ElseIf (cAlsVRJ)->VRJ_STATUS == "R" 
			cCodStatus	:= "PVAR"
			cDescStatus	:= "ALTERACAO STATUS - REPROVADO"
		ElseIf (cAlsVRJ)->VRJ_STATUS == "F" 
			cCodStatus	:= "PVAF"
			cDescStatus	:= "ALTERACAO STATUS - FINALIZADO"
		ElseIf (cAlsVRJ)->VRJ_STATUS == "C" 
			cCodStatus	:= "PVAC"
			cDescStatus	:= "ALTERACAO STATUS - CANCELADO"
		EndIf

		cSoap := '<x:Envelope xmlns:x="http://www.w3.org/2003/05/soap-envelope"  xmlns="http://tempuri.org/">'
		cSoap += "<x:Header/>"
		cSoap += "<x:Body>"
		cSoap += "    <Status>"
		cSoap += "        <ListaPedidosVeiculos>"
		cSoap += "            <DadosStatusPedidoVeiculo>"
		cSoap += putTag('CdPedido',          Alltrim((cAlsVRJ)->VRJ_PEDCOM))
		cSoap += putTag('CdPedidoERP',       Alltrim((cAlsVRJ)->VRJ_PEDIDO))
		cSoap += putTag('DtAtualizacao',     Substr(DtoS(dDataBase),1,4) + '-' + Substr(DtoS(dDataBase),5,2) + '-' + Substr(DtoS(dDataBase),7,2) )
		cSoap += putTag('CdStatus',          cCodStatus)
		cSoap += putTag('DsStatus',          cDescStatus )
		cSoap += "                <PedidoVeiculoItens>"  
		If VRK->( DbSeek( (cAlsVRJ)->VRJ_FILIAL + (cAlsVRJ)->VRJ_PEDIDO ) )
			While  VRK->(!Eof()) .And.  (cAlsVRJ)->VRJ_FILIAL == VRK->VRK_FILIAL  .And. (cAlsVRJ)->VRJ_PEDIDO == VRK->VRK_PEDIDO 
			 	cSoap += "               <StatusPedidoVeiculoItem>"
				cSoap += putTag('idItem',            Alltrim(STR(VRK->VRK_XID)))
				cSoap += putTag('CdLinha',          Alltrim(VRK->VRK_GRUMOD ))
				cSoap += putTag('DsLinha',          AllTrim(GetAdvFVal("VVR","VVR_DESCRI",xFilial('VVR')+VRK->VRK_CODMAR+VRK->VRK_GRUMOD,2,'')))
				cSoap += putTag('CdModeloComercial',Alltrim(VRK->VRK_SEGMOD) 			)
				cSoap += putTag('DsModeloComercial',AllTrim(GetAdvFVal("VVX","VVX_DESSEG",xFilial('VVX')+VRK->VRK_CODMAR+VRK->VRK_SEGMOD,1,'')))
				cSoap += putTag('CdModelo',         Alltrim(VRK->VRK_MODVEI)  )
				//cSoap += putTag('DsModelo',         Alltrim(QryStatus->VV2_DESMOD))
				cSoap += putTag('NuAnoModelo',      RIGHT(VRK->VRK_FABMOD,4))
				cSoap += putTag('NuAnoFabricacao',  LEFT(Alltrim(VRK->VRK_FABMOD),4)  )
				cSoap += putTag('Quantidade',       '1')
				cSoap += putTag('CdCorExterna',     Alltrim(VRK->VRK_COREXT))
				cSoap += putTag('DsCorExterna',     AllTrim(GetAdvFVal("VX5","VX5_DESCRI",xFilial('VX5')+'067'+VRK->VRK_COREXT,1,'')))
				cSoap += putTag('CdCorInterna',     Alltrim(VRK->VRK_CORINT))
				cSoap += putTag('DsCorInterna',     AllTrim(GetAdvFVal("VX5","VX5_DESCRI",xFilial('VX5')+'066'+VRK->VRK_CORINT,1,'')))
				cSoap += putTag('DsChassi',     AllTrim(VRK->VRK_CHASSI))
				If AllTrim( VRK->VRK_CANCEL ) == '1'
					
					cSoap += putTag('CdStatus',     '999')
					cSoap += putTag('DsStatus',     'Excluido')
					
				ElseIf Alltrim( (cAlsVRJ)->VRJ_STATUS ) $ "A|P|O|L|R|C" //A=Em Aberto;P=Pend.Aprovacao;O=Pre-Aprovado;L=Aprovado;R=Reprovado;C=Cancelado

					cSoap += putTag('CdStatus',    cCodStatus)
					cSoap += putTag('DsStatus',    cDescStatus )

				ElseIf Alltrim( (cAlsVRJ)->VRJ_STATUS ) == "F" //F=Finalizado

					If Empty( VRK->VRK_NUMTRA )

						cSoap += putTag('CdStatus',     'PVAA')
						cSoap += putTag('DsStatus',     'ALTERACAO STATUS - ABERTO')

					ElseIf !Empty( VRK->VRK_NUMTRA ) 

						cSoap += putTag('CdStatus',     'PVAT')
						cSoap += putTag('DsStatus',     'ALTERACAO STATUS - ATENDIDO')

					EndIf

				Else
					cSoap += putTag('CdStatus',     '0')
					cSoap += putTag('DsStatus',     'STATUS NAO ENCONTRADO')
				EndIf
				
				cSoap += "                </StatusPedidoVeiculoItem>"
			
				VRK->(dbSkip())
			EndDo
		
			cSoap += "                </PedidoVeiculoItens>"
			cSoap += "                </DadosStatusPedidoVeiculo>"
			cSoap += "            </ListaPedidosVeiculos>"
			cSoap += "        </Status>"
			cSoap += "    </x:Body>"
			cSoap += "</x:Envelope>"
		
			lRet := oWsdl:SendSoapMsg(cSoap)
		
			IF !lRet

				cRet  := '2'
				cErro := 'Nãoo foi possivel enviar o XML '+oWsdl:cError

			Else

				cRetMsg 	:= oWsdl:GetSoapResponse()
				cRetStatus 	:= GetSimples( cRetMsg , "<RetornoStatusPedidoVeiculoDados>", "</RetornoStatusPedidoVeiculoDados>" )
				cRetComp	:= GetSimples( cRetMsg , "<ComprovanteEntrega>","<ComprovanteEntrega>")
				cCdRet  	:= GetSimples( cRetMsg , "<CdRetorno>", "</CdRetorno>" )
				cDsRet  	:= GetSimples( cRetMsg , "<DsRetorno>", "</DsRetorno>" )
				
				If Empty(cRetMsg)

					cRet  := '2'
					cErro := 'NÃ£o encontrado mensagem de retorno'

				Else

					If Alltrim(cCdRet) == "1" .OR. Alltrim(cCdRet) == "0"
						
						cRet  := '1'
						cErro := 'Integrado com sucesso'
					
						DbSelectArea("VRJ")
						DbGoto((cAlsVRJ)->R_E_C_N_O_)
						RecLock("VRJ",.F.)
							VRJ->VRJ_XINTEG := Alltrim((cAlsVRJ)->VRJ_STATUS)
						VRJ->(MsUnlock())
					Else

						cRet  := '2'
						cErro := Alltrim(cCdRet)+'-'+Alltrim(cDsRet)

					EndIf
				EndIF
			Endif

			U_CAOA_MONITOR( cFilant  ,cRet,'001','003',cErro, Alltrim((cAlsVRJ)->VRJ_PEDIDO) ,'0',cSoap ,(cAlsVRJ)->R_E_C_N_O_)

			If cRet == "2"
				DbSelectArea("VRJ")
				DbGoto((cAlsVRJ)->R_E_C_N_O_)
				RecLock("VRJ",.F.)
					VRJ->VRJ_XINTEG := "E"
				VRJ->(MsUnlock())
			EndIf
		
			If ( FWIsInCallStack("U_ZVEIF003") .Or. FWIsInCallStack("U_VX002FIN") ) .And. !Empty(cPedVRJ)
				If cRet == "1"
					MsgInfo("Integração enviada com Sucesso ao Autoware !","CMVAUT04")
				Else
					MsgInfo( "Integração com erro! Pedido não Integrado" + CRLF + CRLF +  "Por favor verificar o Monitor de Integração AutoWare", "CMVAUT04" )
				Endif
			EndIf

		EndIf
		(cAlsVRJ)->(dbSkip())
	EndDo
EndIF
(cAlsVRJ)->(dbCloseArea())


freeObj(oWsdl)               
oWsdl := nil

Return()

*********************************************************************************************************
Static Function putTag(cTag,cValor) 
Local cRet := ''

cRet := '<'+cTag+'>'+cValor+'</'+cTag+'>'

Return cRet
 





 /*
User Function CMVAUT04(aParam01)

Local cQryVRJ 		:= ''
Local cAlsVRJ		:= GetNextAlias()
Local cRet    		:= ''
Local cErro   		:= ''
Local cWsURL  		:= ''
Local cSoap   		:= ''
Local lRet    		:= .F.
Local cRetMsg 		:= ''
Local cRetStatus    := ""
Local cRetComp      := ""
Local cPedVRJ		:= ""
Local lMsg			:= .F.

Private _aMatriz := {"01","2010022001"}
Private lIsBlind := IsBlind() .OR. Type("__LocalDriver") == "U"
Private oWsdl

// Só executa quando é realizado pelas Rotinas 
// - ZVEIF003 - Botão na Tela de Pedido de Venda Montadora.
// - VX002FIN - Ponto de Entrada que dispara a integração individual para cada pedido.
// Dispara a integração somente do pedido selecionado.
If FWIsInCallStack("U_ZVEIF003") .Or. FWIsInCallStack("U_VX002FIN") .or. FWIsInCallStack("U_ZFATF019") 

	cPedVRJ := aParam01
	lMsg	:= .T.

ElseIf lIsBlind

		RpcSetType(3)
		RpcSetEnv(_aMatriz[1],_aMatriz[2])
	
		If !LockByName("CMVAUT04")
			Conout("JOB em Execucao : CMVAUT04 " + DTOC(dDATABASE) + " - " + TIME() )
			RpcClearEnv()
			Return()
		EndIf

		cPedVRJ := ""
EndIf

dbSelectArea('VRK') 
VRK->(dbSetorder(1))

cQryVRJ  := " "
cQryVRJ  += " SELECT * FROM "+RetSQLname("VRJ") +" VRJ "							+ CRLF
cQryVRJ  += " WHERE VRJ.VRJ_FILIAL =  '"+xFilial('VRJ')+"' "						+ CRLF
If !Empty(cPedVRJ)
	cQryVRJ  += " AND VRJ.VRJ_PEDIDO  =  '" + cPedVRJ + "' "						+ CRLF
Else
	cQryVRJ  += " AND VRJ.VRJ_STATUS NOT IN ('P','O','L') "							+ CRLF //P=Pend.Aprovacao; O=Pre-Aprovado; L=Aprovado
	cQryVRJ  += " AND VRJ.VRJ_XINTEG NOT IN ('E','X') "								+ CRLF //E=Envio com Erro; X=ProcessamentoAutomatico
	cQryVRJ  += " AND VRJ.VRJ_XINTEG <> VRJ.VRJ_STATUS "							+ CRLF
	cQryVRJ  += " AND VRJ.VRJ_TIPVEN  = '01' "										+ CRLF
	cQryVRJ  += " AND VRJ.VRJ_PEDCOM  <> ' ' "										+ CRLF
EndIf
cQryVRJ  += " AND VRJ.D_E_L_E_T_ = ' ' "											+ CRLF
cQryVRJ  += " ORDER BY VRJ.VRJ_PEDIDO "												+ CRLF						

cQryVRJ := ChangeQuery(cQryVRJ)

// Executa a consulta.
DbUseArea( .T., "TOPCONN", TcGenQry(,,cQryVRJ), cAlsVRJ, .T., .T. )

cWsURL:= ALLTRIM(SuperGetMV("CAOA_WS003",.T.,'https://treinamento.caoamontadora.com.br/servicos/v2/PedidoVeiculo.asmx?WSDL'))

DbSelectArea((cAlsVRJ))
(cAlsVRJ)->(dbGoTop())
If (cAlsVRJ)->(!EOF())
   
	oWsdl := TWsdlManager():New()
	oWsdl:lSSLInsecure := .T.

	If !oWsdl:ParseURL( cWsURL )

		If lMsg
			MsgInfo( "Erro de conexão com Autoware" + CRLF + CRLF +  "Não foi possivel realizar a conexão com o WS Autoware - Entre em contato com o adm do sistema IMEDIATAMENTE."+ CRLF + CRLF + "URL: "+ALLTRIM(cWsURL)+ CRLF + CRLF + "ERRO: "+ AllTrim(oWsdl:cError) , "CMVAUT04" )
		EndIf

		cRet  := '2'
		cErro := 'NÃ£o foi possivel Acessar o WSDL '+oWsdl:cError

		U_CAOA_MONITOR( cFilant,cRet,'001','003',cErro,'','0',cSoap ,0)
		
		freeObj(oWsdl)
		oWsdl := nil
		
		(cAlsVRJ)->(dbCloseArea())
		Return()

	EndIf

	If !oWsdl:SetOperation('Status')

		cRet  := '2'
		cErro := 'NÃ£o foi possivel setar a OperaÃ§Ã£o Status '+oWsdl:cError
		U_CAOA_MONITOR( cFilant  ,cRet,'001','003',cErro,'','0',cSoap ,0)

		freeObj(oWsdl)
		oWsdl := nil

		(cAlsVRJ)->(dbCloseArea())
		Return()

	EndIf

	While (cAlsVRJ)->(!EOF())
		
		cCodStatus	:= " "
		cDescStatus	:= " "

		//A=Em Aberto;P=Pend.Aprovacao;O=Pre-Aprovado;L=Aprovado;R=Reprovado;F=Finalizado;C=Cancelado      
		
		IF (cAlsVRJ)->VRJ_STATUS == "A"                               
			cCodStatus	:= "PVAA"
			cDescStatus	:= "ALTERACAO STATUS - ABERTO"
		ElseIf (cAlsVRJ)->VRJ_STATUS == "P" 
			cCodStatus	:= "PVAP"
			cDescStatus	:= "ALTERACAO STATUS - PENDENTE APROVACAO"
		ElseIf (cAlsVRJ)->VRJ_STATUS == "O" 
			cCodStatus	:= "PVAO"
			cDescStatus	:= "ALTERACAO STATUS - PRE APROVADO"
		ElseIf (cAlsVRJ)->VRJ_STATUS == "L" 
			cCodStatus	:= "PVAL"
			cDescStatus	:= "ALTERACAO STATUS - APROVADO"
		ElseIf (cAlsVRJ)->VRJ_STATUS == "R" 
			cCodStatus	:= "PVAR"
			cDescStatus	:= "ALTERACAO STATUS - REPROVADO"
		ElseIf (cAlsVRJ)->VRJ_STATUS == "F" 
			cCodStatus	:= "PVAF"
			cDescStatus	:= "ALTERACAO STATUS - FINALIZADO"
		ElseIf (cAlsVRJ)->VRJ_STATUS == "C" 
			cCodStatus	:= "PVAC"
			cDescStatus	:= "ALTERACAO STATUS - CANCELADO"
		EndIf

		cSoap := '<x:Envelope xmlns:x="http://www.w3.org/2003/05/soap-envelope"  xmlns="http://tempuri.org/">'
		cSoap += "<x:Header/>"
		cSoap += "<x:Body>"
		cSoap += "    <Status>"
		cSoap += "        <ListaPedidosVeiculos>"
		cSoap += "            <DadosStatusPedidoVeiculo>"
		cSoap += putTag('CdPedido',          Alltrim((cAlsVRJ)->VRJ_PEDCOM))
		cSoap += putTag('CdPedidoERP',       Alltrim((cAlsVRJ)->VRJ_PEDIDO))
		cSoap += putTag('DtAtualizacao',     Substr(DtoS(dDataBase),1,4) + '-' + Substr(DtoS(dDataBase),5,2) + '-' + Substr(DtoS(dDataBase),7,2) )
		cSoap += putTag('CdStatus',          cCodStatus)
		cSoap += putTag('DsStatus',          cDescStatus )
		cSoap += "                <PedidoVeiculoItens>"  
		If VRK->( DbSeek( (cAlsVRJ)->VRJ_FILIAL + (cAlsVRJ)->VRJ_PEDIDO ) )
			While  VRK->(!Eof()) .And.  (cAlsVRJ)->VRJ_FILIAL == VRK->VRK_FILIAL  .And. (cAlsVRJ)->VRJ_PEDIDO == VRK->VRK_PEDIDO 
			 	cSoap += "               <StatusPedidoVeiculoItem>"
				cSoap += putTag('idItem',            Alltrim(STR(VRK->VRK_XID)))
				cSoap += putTag('CdLinha',          Alltrim(VRK->VRK_GRUMOD ))
				cSoap += putTag('DsLinha',          AllTrim(GetAdvFVal("VVR","VVR_DESCRI",xFilial('VVR')+VRK->VRK_CODMAR+VRK->VRK_GRUMOD,2,'')))
				cSoap += putTag('CdModeloComercial',Alltrim(VRK->VRK_SEGMOD) 			)
				cSoap += putTag('DsModeloComercial',AllTrim(GetAdvFVal("VVX","VVX_DESSEG",xFilial('VVX')+VRK->VRK_CODMAR+VRK->VRK_SEGMOD,1,'')))
				cSoap += putTag('CdModelo',         Alltrim(VRK->VRK_MODVEI)  )
				//cSoap += putTag('DsModelo',         Alltrim(QryStatus->VV2_DESMOD))
				cSoap += putTag('NuAnoModelo',      RIGHT(VRK->VRK_FABMOD,4))
				cSoap += putTag('NuAnoFabricacao',  LEFT(Alltrim(VRK->VRK_FABMOD),4)  )
				cSoap += putTag('Quantidade',       '1')
				cSoap += putTag('CdCorExterna',     Alltrim(VRK->VRK_COREXT))
				cSoap += putTag('DsCorExterna',     AllTrim(GetAdvFVal("VX5","VX5_DESCRI",xFilial('VX5')+'067'+VRK->VRK_COREXT,1,'')))
				cSoap += putTag('CdCorInterna',     Alltrim(VRK->VRK_CORINT))
				cSoap += putTag('DsCorInterna',     AllTrim(GetAdvFVal("VX5","VX5_DESCRI",xFilial('VX5')+'066'+VRK->VRK_CORINT,1,'')))
				cSoap += putTag('DsChassi',     AllTrim(VRK->VRK_CHASSI))
				If AllTrim( VRK->VRK_CANCEL ) == '1'
					
					cSoap += putTag('CdStatus',     '999')
					cSoap += putTag('DsStatus',     'Excluido')
					
				ElseIf Alltrim( (cAlsVRJ)->VRJ_STATUS ) $ "A|P|O|L|R|C" //A=Em Aberto;P=Pend.Aprovacao;O=Pre-Aprovado;L=Aprovado;R=Reprovado;C=Cancelado

					cSoap += putTag('CdStatus',    cCodStatus)
					cSoap += putTag('DsStatus',    cDescStatus )

				ElseIf Alltrim( (cAlsVRJ)->VRJ_STATUS ) == "F" //F=Finalizado

					If Empty( VRK->VRK_NUMTRA )

						cSoap += putTag('CdStatus',     'PVAA')
						cSoap += putTag('DsStatus',     'ALTERACAO STATUS - ABERTO')

					ElseIf !Empty( VRK->VRK_NUMTRA ) 

						cSoap += putTag('CdStatus',     'PVAT')
						cSoap += putTag('DsStatus',     'ALTERACAO STATUS - ATENDIDO')

					EndIf

				Else
					cSoap += putTag('CdStatus',     '0')
					cSoap += putTag('DsStatus',     'STATUS NAO ENCONTRADO')
				EndIf
				
				cSoap += "                </StatusPedidoVeiculoItem>"
			
				VRK->(dbSkip())
			EndDo
		
			cSoap += "                </PedidoVeiculoItens>"
			cSoap += "                </DadosStatusPedidoVeiculo>"
			cSoap += "            </ListaPedidosVeiculos>"
			cSoap += "        </Status>"
			cSoap += "    </x:Body>"
			cSoap += "</x:Envelope>"
		
			lRet := oWsdl:SendSoapMsg(cSoap)
		
			IF !lRet

				cRet  := '2'
				cErro := 'Nãoo foi possivel enviar o XML '+oWsdl:cError

			Else

				cRetMsg 	:= oWsdl:GetSoapResponse()
				cRetStatus 	:= GetSimples( cRetMsg , "<RetornoStatusPedidoVeiculoDados>", "</RetornoStatusPedidoVeiculoDados>" )
				cRetComp	:= GetSimples( cRetMsg , "<ComprovanteEntrega>","<ComprovanteEntrega>")
				cCdRet  	:= GetSimples( cRetMsg , "<CdRetorno>", "</CdRetorno>" )
				cDsRet  	:= GetSimples( cRetMsg , "<DsRetorno>", "</DsRetorno>" )
				
				If Empty(cRetMsg)

					cRet  := '2'
					cErro := 'NÃ£o encontrado mensagem de retorno'

				Else

					If Alltrim(cCdRet) == "1" .OR. Alltrim(cCdRet) == "0"
						
						cRet  := '1'
						cErro := 'Integrado com sucesso'
					
						DbSelectArea("VRJ")
						DbGoto((cAlsVRJ)->R_E_C_N_O_)
						RecLock("VRJ",.F.)
							VRJ->VRJ_XINTEG := Alltrim((cAlsVRJ)->VRJ_STATUS)
						VRJ->(MsUnlock())
					Else

						cRet  := '2'
						cErro := Alltrim(cCdRet)+'-'+Alltrim(cDsRet)

					EndIf
				EndIF
			Endif

			U_CAOA_MONITOR( cFilant  ,cRet,'001','003',cErro, Alltrim((cAlsVRJ)->VRJ_PEDIDO) ,'0',cSoap ,(cAlsVRJ)->R_E_C_N_O_)

			If cRet == "2"
				DbSelectArea("VRJ")
				DbGoto((cAlsVRJ)->R_E_C_N_O_)
				RecLock("VRJ",.F.)
					VRJ->VRJ_XINTEG := "E"
				VRJ->(MsUnlock())
			EndIf
		
			If ( FWIsInCallStack("U_ZVEIF003") .Or. FWIsInCallStack("U_VX002FIN") ) .And. !Empty(cPedVRJ)
				If cRet == "1"
					MsgInfo("Integração enviada com Sucesso ao Autoware !","CMVAUT04")
				Else
					MsgInfo( "Integração com erro! Pedido não Integrado" + CRLF + CRLF +  "Por favor verificar o Monitor de Integração AutoWare", "CMVAUT04" )
				Endif
			EndIf

		EndIf
		(cAlsVRJ)->(dbSkip())
	EndDo
EndIF
(cAlsVRJ)->(dbCloseArea())


freeObj(oWsdl)               
oWsdl := nil

Return()

*********************************************************************************************************
Static Function putTag(cTag,cValor) 
Local cRet := ''

cRet := '<'+cTag+'>'+cValor+'</'+cTag+'>'

Return cRet
 
 */
