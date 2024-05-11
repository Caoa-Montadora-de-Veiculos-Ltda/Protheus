#Include 'Protheus.ch'
/*
=======================================================================================================
Programa.:              MT094END
Autor....:              Sandro Ferreira
Data.....:              16/02/2022
Descricao / Objetivo:   Alteração de alçada para enviar a nova alçada para o fluig 
Doc. Origem:
Solicitante:            Compras
Uso......:              CAOA Montadora de Veiculos
Obs......: 
=======================================================================================================
*/
 
User Function MT094END()

   Local aArea	      := GetArea()
   Local cTipo       := PARAMIXB[2]
   Local nOpc        := PARAMIXB[3]
	Local lOk         := .T.
	Local cXML        := ""
	Local cWSRetorno  := ""
	Local cResposta   := ""
	Local oXML        := nil
	Local cErro       := ""
	Local cAviso      := ""
	Local oWsdl       := TWsdlManager():New()
	Local cURLFluig   := GetMV("ES_XFLUIG5",,"https://caoa-fluig.totvscloud.com.br/webdesk/ECMWorkflowEngineService?wsdl")
	Private cFUsuario := GetMV("ES_XFLUIG1",,"integrador")
	Private cFSenha   := GetMV("ES_XFLUIG2",,"integrador")
	Private cFEmpresa   := GetMV("ES_XFLUIG4",,"1")
	Private cFIdUsuario := GetMV("ES_XFLUIG3",,"integrador")
	Private cFNumFluig  := Alltrim(PARAMIXB[1])  //Determina o processo se pedido ou solicitacao.
	Private cFMensagem  := "Pedido cancelado pelo Usuario Protheus"

    If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
      If (alltrim(cTipo) = 'IP' .OR. alltrim(cTipo) = 'PC' .OR. alltrim(cTipo) = 'CP') .and. ( nOpc = 1 .or. nOpc = 5 .or. nOpc = 6 ) //Aprova, Rejeita ou bloqueia
         IF alltrim(cTipo) = 'CP'
            IF nOpc = 1
               SC3->(DbSeek(xFilial("SC3")+alltrim(PARAMIXB[1])))
            ENDIF
            cFNumFluig := ALLTRIM(SC3->C3_XFLUIG5)
         ENDIF

         IF alltrim(cTipo) = 'IP' .OR. alltrim(cTipo) = 'PC'
            IF nOpc = 1
               SC7->(DbSeek(xFilial("SC7")+alltrim(PARAMIXB[1])))
            ENDIF
            cFNumFluig := ALLTRIM(SC7->C7_XFLUIG5)
         ENDIF

         Begin Sequence

         //Linha nova
         oWsdl:lSSLInsecure := .T.


            If  Empty(cFNumFluig) 
               U_ZFLUIF02(cEmpAnt,cFilAnt)
               Break  //Ignora na inclusao
            EndIf

            cXML := H_PE_MT110TOK() //Reaproveita o XML em solicitaÃ§Ã£o.

            ConOut(" ==>> cXML: ")
            ConOut(cXML)

            If  !( oWsdl:ParseURL(cURLFluig) )
               ConOut("MT120GRV: Problema para fazer o parse do WSDL!")
               ConOut(oWsdl:cError)
               Alert("Fluig nao cancelou a aprovacao do pedido!")
               lOk := .F.
               Break
            EndIf

            If  !( oWsdl:SetOperation( "cancelInstance" ) )
               ConOut("MT120GRV: Problema para setar o metodo cancelInstance()!")
               ConOut(oWsdl:cError)
               Alert("Fluig nao cancelou a aprovacao do pedido!")
               lOk := .F.
               Break
            EndIf

            If  !( oWsdl:SendSoapMsg( cXML ) ) .And. !("Unknown element cancelInstanceResponse" $ oWsdl:cError)
               ConOut("MT120GRV: Problema na execucao do metodo cancelInstance()!")
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
               ConOut( "MT120GRV: Erro no XML de retorno: " + cErro )
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
                  
         End Sequence
      EndIf
   EndIf

   RestArea(aArea)

Return(lOk)
