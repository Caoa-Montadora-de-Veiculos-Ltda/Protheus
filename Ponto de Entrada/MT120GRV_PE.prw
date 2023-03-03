#INCLUDE 'PROTHEUS.CH'

/*
{Protheus.doc} u_MT120GRV
Ponto de entrada para confirmar a gravação do pedido de compras.
O Fluig será solicitado a cancelar a aprovacao caso retorne negativo os dados nao serao gravados.

@author  Sandro Gonçalves Ferreira
@version 1.0
@since   09/06/2022
@return  Nil  Sem retorno.
@sample
*/

USER Function MT120GRV()

	Local nA         := 0
	Local l120Inclui := ParamIXB[2]
	Local lOk        := .T.
	Local cXML       := ""
	Local cWSRetorno := ""
	Local cResposta  := ""
	Local oXML       := nil
	Local cErro      := ""
	Local cAviso     := ""
	Local oWsdl      := TWsdlManager():New()
	Local cURLFluig  := GetMV("ES_XFLUIG5",,"https://caoa-fluig.totvscloud.com.br/webdesk/ECMWorkflowEngineService?wsdl")
	Local _cEmp		:= FWCodEmp()
	Local aArea		:= GetArea()
	
	Private cFUsuario   := GetMV("ES_XFLUIG1",,"integrador")
	Private cFSenha     := GetMV("ES_XFLUIG2",,"integrador")
	Private cFEmpresa   := GetMV("ES_XFLUIG4",,"1")
	Private cFIdUsuario := GetMV("ES_XFLUIG3",,"integrador")
	Private cFNumFluig  := Alltrim(SC7->C7_XFLUIG5)  //Determina o processo se pedido ou solicitacao.
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

	If INCLUI
		Return lOk  //Ignora na inclusao
	Endif

	If _cEmp == "2010" //Executa o p.e. Anapolis. 
	
		Begin Sequence

			//Linha nova
			oWsdl:lSSLInsecure := .T.
			If  (l120Inclui  .Or. Empty(cFNumFluig) )
				U_ZFLUIF02(cEmpAnt,cFilAnt)
				Break  //Ignora na inclusao
			EndIf

			cXML := H_PE_MT110TOK() //Reaproveita o XML em solicitação.
			ConOut(" ==>> cXML: ")
			ConOut(cXML)

			If  !( oWsdl:ParseURL(cURLFluig) )   
				ConOut("MT120GRV: Problema para fazer o parse do WSDL!")
				ConOut(oWsdl:cError)
				//Alert("Fluig nao cancelou a aprovacao do pedido!")
				lOk := .F.
				Break
			EndIf

			If  !( oWsdl:SetOperation( "cancelInstance" ) ) 
				ConOut("MT120GRV: Problema para setar o metodo cancelInstance()!")
				ConOut(oWsdl:cError)
				//Alert("Fluig nao cancelou a aprovacao do pedido!")
				lOk := .F.
				Break
			EndIf

			If  !( oWsdl:SendSoapMsg( cXML ) ) .And. !("Unknown element cancelInstanceResponse" $ oWsdl:cError) 
				ConOut("MT120GRV: Problema na execucao do metodo cancelInstance()!")
				ConOut(oWsdl:cError)
				//Alert("Fluig nao cancelou a aprovacao do pedido!")
				lOk := .F.
				Break
			EndIf

			// Pega a mensagem de resposta
			cWSRetorno := oWsdl:GetSoapResponse()

			ConOut("cWSRetorno")
			ConOut(cWSRetorno)

			oXML := XMLParser(cWSRetorno,"_",@cErro,@cAviso)

			If  !( Empty(cErro) )
				ConOut( "MT120GRV: Erro no XML de retorno: " + cErro )
				//Alert("Fluig nao cancelou a aprovacao do pedido!")
				lOk := .F.
				Break
			EndIf

			cResposta := oXML:_Soap_Envelope:_Soap_Body:_ns1_cancelInstanceResponse:_Result:Text

			If  (cResposta <> "OK") .And. !(("invalida" $ cResposta) .And. ("inativa" $ cResposta))
			//Alert("Fluig nao cancelou a aprovacao do pedido!")
			lOk := .F.
			Break
			EndIf
			
			For nA := 1 to Len(aCols)
					GDFieldPut("C7_XFLUIG1", "N"      , nA)
					GDFieldPut("C7_XFLUIG3", "N"      , nA)
					GDFieldPut("C7_XFLUIG5", "       ", nA)
			Next nA


		End Sequence
	EndIf

	RestArea(aArea)

Return(.T.) //lOk
