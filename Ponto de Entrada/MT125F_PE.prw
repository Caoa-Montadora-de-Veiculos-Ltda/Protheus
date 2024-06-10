#INCLUDE 'PROTHEUS.CH'

/*
{Protheus.doc} u_MT125GRV
Ponto de entrada para confirmar a gravação do contrato de parceria.
O Fluig será solicitado a cancelar a aprovacao caso retorne negativo os dados nao serao gravados.

@author  Sandro Ferreira
@version 1.0
@since   18/03/2022
@return  Nil  Sem retorno.
@sample
         lMt125GRV := Execblock("MT125GRV",.F.,.F.,{cA120Num,l120Inclui,l120Altera,l120Deleta,aRecnoSE2RA})
*/

USER Function MT125F()
	Local nA         := 0
    Local _nOpc      := If(INCLUI,3, IF(ALTERA,4, 5) )
	Local lOk        := .T.
	Local cXML       := ""
	Local cWSRetorno := ""
	Local cResposta  := ""
	Local oXML       := nil
	Local cErro      := ""
	Local cAviso     := ""
	Local oWsdl      := TWsdlManager():New()
	Local cURLFluig  := GetMV("ES_XFLUIG5",,"https://caoa-fluig.totvscloud.com.br/webdesk/ECMWorkflowEngineService?wsdl")
    Local aArea	   	 := GetArea()

	Private cFUsuario   := GetMV("ES_XFLUIG1",,"integrador")
	Private cFSenha     := GetMV("ES_XFLUIG2",,"integrador")
	Private cFEmpresa   := GetMV("ES_XFLUIG4",,"1")
	Private cFIdUsuario := GetMV("ES_XFLUIG3",,"integrador")
	Private cFNumFluig  := Alltrim(SC3->C3_XFLUIG5)  //Determina o processo se pedido ou solicitacao.
	Private cFMensagem  := "Pedido cancelado pelo Usuario Protheus"
    Public  cCPY     
	Public  cINC  

	If  (Type("INCLUI") == "U")
		INCLUI := .F.
		cINC   := .T.
	EndIf
	 
	If  (Type("LCOPIA") == "U")
		LCOPIA := .F.
		cCPY   := .T.
	EndIf

	If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
		Begin Sequence

			//Linha nova
			oWsdl:lSSLInsecure := .T.

			If  (_nOpc = 3 .or. _nOpc = 4  .Or. Empty(cFNumFluig) )
				U_ZFLUIF03(cEmpAnt,cFilAnt,_nOpc, cFNumFluig )
			EndIf

			If  (_nOpc = 3)
			Break  //Ignora na inclusao
			Endif

			If  (_nOpc = 4 .and.  Empty(cFNumFluig))
			Break  //Ignora na inclusao
			Endif

			cXML := H_PE_MT110TOK() //Reaproveita o XML em solicitação.
			ConOut(" ==>> cXML: ")
			ConOut(cXML)

			If  !( oWsdl:ParseURL(cURLFluig) )   
				ConOut("MT125GRV: Problema para fazer o parse do WSDL!")
				ConOut(oWsdl:cError)
				Alert("Fluig nao cancelou a aprovacao do pedido!")
				lOk := .F.
				Break
			EndIf

			If  !( oWsdl:SetOperation( "cancelInstance" ) ) 
				ConOut("MT125GRV: Problema para setar o metodo cancelInstance()!")
				ConOut(oWsdl:cError)
				Alert("Fluig nao cancelou a aprovacao do pedido!")
				lOk := .F.
				Break
			EndIf

			If  !( oWsdl:SendSoapMsg( cXML ) ) .And. !("Unknown element cancelInstanceResponse" $ oWsdl:cError) 
				ConOut("MT125GRV: Problema na execucao do metodo cancelInstance()!")
				ConOut(oWsdl:cError)
				Alert("Fluig nao cancelou a aprovacao do pedido!")
				lOk := .F.
				Break
			EndIf

			// Pega a mensagem de resposta
			
			cWSRetorno := oWsdl:GetSoapResponse()

			ConOut("cWSRetorno")
			ConOut(cWSRetorno)

			oXML := XMLParser(cWSRetorno,"_",@cErro,@cAviso)

			If  !( Empty(cErro) )
				ConOut( "MT125GRV: Erro no XML de retorno: " + cErro )
				Alert("Fluig nao cancelou a aprovacao do pedido!")
				lOk := .F.
				Break
			EndIf

			cResposta := oXML:_Soap_Envelope:_Soap_Body:_ns1_cancelInstanceResponse:_Result:Text

			If  (cResposta <> "OK") .And. !(("invalida" $ cResposta) .And. ("inativa" $ cResposta))
			Alert("Fluig nao cancelou a aprovacao do pedido!")
			lOk := .F.
			Break
			EndIf
			
			For nA := 1 to Len(aCols)
					GDFieldPut("C3_XFLUIG1", "N"      , nA)
					GDFieldPut("C3_XFLUIG3", "N"      , nA)
					GDFieldPut("C3_XFLUIG5", "       ", nA)
			Next nA


		End Sequence
	EndIf

	RestArea(aArea)

Return lOk
