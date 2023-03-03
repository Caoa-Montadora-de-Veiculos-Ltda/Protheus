#Include "PROTHEUS.CH"
#Include 'topconn.ch'
#INCLUDE "TOTVS.Ch"

/*
=====================================================================================
Programa.:              ZFLUI998
Autor....:              CAOA - Sandro Ferreira
Data.....:              07/04/2022
Descricao / Objetivo:   Realiza a reset dos Pedidos de Compras e Contratos de Parcerias
Doc. Origem:            Para reenvio para o Fluig
Solicitante:            Julia
=====================================================================================
*/
User Function ZFLUI998() 
	Local aArea   := GetArea()
	Local _cTitulo      := "Reseta os pedidos de compras ou Contratos de Parcerias Para reenvio para o Fluig" 
	Local aOpcoes       := {}
	Local _oDlg
	Local _nlin1
	Local _nlin2
	Local _nCol1
	Local _nCol2
	Local _oItens
	Local _cTipo
	Local _cNumero := SPACE(06)

	_nlin1 := 5
	_nCol1 := 16
    _nlin2 := 45
	_nCol2 := 305

	//Montando array com as opções
	aAdd(aOpcoes ,  "1=Pedido de Compras" )
	aAdd(aOpcoes ,  "2=Contrato de Parceria " )
	aAdd(aOpcoes ,  "3=Solicitação de Compras" )

	DEFINE MSDIALOG _oDlg FROM  00, 70 TO 130, 700 TITLE _cTitulo PIXEL
	@ _nlin1, _nCol1 TO _nlin2, _nCol2 OF _oDlg PIXEL
	@ _nlin1+5 	, _nCol1+30 SAY  "Escolha qual Processo você deseja Reenviar para o Fluig:" 	SIZE 140, 20 OF _oDlg PIXEL     	
	@ _nlin1+4	, _nCol1+175 MSCOMBOBOX _oItens VAR _cTipo ITEMS aOpcoes Valid !Empty(_cTipo) PIXEL SIZE 90, 013 Of _oDlg COLORS 0, 16777215 PIXEL
  
	@ _nlin1+20, _nCol1+030 	SAY  "Informe o Número do (Pedido, Contrato ou Solicitação):" 	SIZE 140, 20 OF _oDlg PIXEL     	
	@ _nlin1+20, _nCol1+175    MSGET _cNumero PICTURE "999999" Valid !Empty(_cNumero) .and. Len(AllTrim(_cNumero)) = 06 PIXEL SIZE 50, 013 Of _oDlg

    DEFINE SBUTTON FROM _nlin2+5, 050 TYPE 1 ENABLE ACTION (_nAcao:=1,ZCOM998(_cTipo, _cNumero)) OF _oDlg
	DEFINE SBUTTON FROM _nlin2+5, 230 TYPE 2 ENABLE ACTION (_oDlg:End()) OF _oDlg
	ACTIVATE MSDIALOG _oDlg CENTERED

Return

/*
=====================================================================================
Programa.:              ZCOM998
Autor....:              CAOA - Sandro Ferreira
Data.....:              26/05/2022
Descricao / Objetivo:   Reseta os pedidos de compras ou Contratos de Parcerias
Solicitante:            Julia
=====================================================================================
*/
Static Function ZCOM998(cTp, cNro)
Local cUpdate    := ""
Local cQuery     := ""
Local cFluig     := ""
Local aSetField  := {}
Local nA         := 0
Local lOk        := .T.
Local lProc      := .T.
Local cXML       := ""
Local cWSRetorno := ""
Local cResposta  := ""
Local oXML       := nil
Local cErro      := ""
Local cAviso     := ""
Local oWsdl      := TWsdlManager():New()
Local cURLFluig  := GetMV("ES_XFLUIG5",,"https://caoa-fluig.totvscloud.com.br/webdesk/ECMWorkflowEngineService?wsdl")

Private cFUsuario   := GetMV("ES_XFLUIG1",,"integrador")
Private cFSenha     := GetMV("ES_XFLUIG2",,"integrador")
Private cFEmpresa   := GetMV("ES_XFLUIG4",,"1")
Private cFIdUsuario := GetMV("ES_XFLUIG3",,"integrador")
Private cFNumFluig  := " "//Determina o processo se pedido ou solicitacao.
Private cFMensagem  := "Pedido cancelado pelo Usuario Protheus"


If     cTp  = '1'
   //Busca o numero do formulario no fluig
   cQuery := " SELECT C7_XFLUIG5 FROM " + RetSQLName("SC7")
   cQuery += "       WHERE  D_E_L_E_T_ <> '*' "
   cQuery += "    AND C7_FILIAL = '" + FWxFilial("SC7") + "' "  
   cQuery += "    AND C7_NUM    = '" + cNro             + "' "  
   cQuery := ChangeQuery( cQuery )
   MPSysOpenQuery( cQuery, "TRB", aSetField )
   DbSelectArea("TRB")
   If !Eof()
      cFNumFluig  := TRB->C7_XFLUIG5
      //Atualiza o Pedido de Compras
      cUpdate := " UPDATE " + RetSqlName("SC7")  + " SC7 "              + CRLF
      cUpdate += " SET SC7.C7_XFLUIG1    = ' ' , "                      + CRLF
      cUpdate += "     SC7.C7_XFLUIG2    = ' ' , "                      + CRLF
      cUpdate += "     SC7.C7_XFLUIG3    = ' ' , "                      + CRLF
      cUpdate += "     SC7.C7_XFLUIG4    = ' ' , "                      + CRLF
      cUpdate += "     SC7.C7_XFLUIG5    = ' '  "                       + CRLF          
      cUpdate += " WHERE SC7.D_E_L_E_T_  = ' ' "                        + CRLF
      cUpdate += "    AND SC7.C7_FILIAL = '" + FWxFilial("SC7") + "' "  + CRLF
      cUpdate += "    AND SC7.C7_NUM    = '" + cNro             + "' "  + CRLF
   else
      MsgInfo("Pedido de Compras não encontrada!", "CaoaTec") 
	  lProc      := .F.
   Endif
ElseIF cTp  = '2'
   //Busca o numero do formulario no fluig
   cQuery := " SELECT C3_XFLUIG5 FROM " + RetSQLName("SC3")
   cQuery += "       WHERE  D_E_L_E_T_ <> '*' "
   cQuery += "    AND C3_FILIAL = '" + FWxFilial("SC3") + "' "  
   cQuery += "    AND C3_NUM    = '" + cNro             + "' "  
   cQuery := ChangeQuery( cQuery )
   MPSysOpenQuery( cQuery, "TRB", aSetField )
   DbSelectArea("TRB")
   If !Eof()
      cFNumFluig  := TRB->C3_XFLUIG5
      //Atualiza o Pedido de Compras
      cUpdate := " UPDATE " + RetSqlName("SC3")  + " SC3 "              + CRLF
      cUpdate += " SET SC3.C3_XFLUIG1    = ' ' , "                      + CRLF
      cUpdate += "     SC3.C3_XFLUIG2    = ' ' , "                      + CRLF
      cUpdate += "     SC3.C3_XFLUIG3    = ' ' , "                      + CRLF
      cUpdate += "     SC3.C3_XFLUIG4    = ' ' , "                      + CRLF
      cUpdate += "     SC3.C3_XFLUIG5    = ' '  "                       + CRLF          
      cUpdate += " WHERE SC3.D_E_L_E_T_  = ' ' "                        + CRLF
      cUpdate += "    AND SC3.C3_FILIAL = '" + FWxFilial("SC3") + "' "  + CRLF
      cUpdate += "    AND SC3.C3_NUM    = '" + cNro             + "' "  + CRLF
   Else
	  MsgInfo("Contrato de Parceria não encontrada!", "CaoaTec") 
	  lProc      := .F.
   Endif   
ElseIf cTp  = '3'
   //Busca o numero do formulario no fluig
   cQuery := " SELECT C1_XFLUIG5 FROM " + RetSQLName("SC1")
   cQuery += "       WHERE  D_E_L_E_T_ <> '*' "
   cQuery += "    AND C1_FILIAL = '" + FWxFilial("SC1") + "' "  
   cQuery += "    AND C1_NUM    = '" + cNro             + "' "  
   cQuery := ChangeQuery( cQuery )
   MPSysOpenQuery( cQuery, "TRB", aSetField )
   DbSelectArea("TRB")
   If !Eof()
      cFNumFluig  := TRB->C1_XFLUIG5
      //Atualiza o Pedido de Compras
      cUpdate := " UPDATE " + RetSqlName("SC1")  + " SC1 "              + CRLF
      cUpdate += " SET SC1.C1_XFLUIG1    = ' ' , "                      + CRLF
      cUpdate += "     SC1.C1_XFLUIG2    = ' ' , "                      + CRLF
      cUpdate += "     SC1.C1_XFLUIG3    = ' ' , "                      + CRLF
      cUpdate += "     SC1.C1_XFLUIG4    = ' ' , "                      + CRLF
      cUpdate += "     SC1.C1_XFLUIG5    = ' '  "                       + CRLF          
      cUpdate += " WHERE SC1.D_E_L_E_T_  = ' ' "                        + CRLF
      cUpdate += "    AND SC1.C1_FILIAL = '" + FWxFilial("SC1") + "' "  + CRLF
      cUpdate += "    AND SC1.C1_NUM    = '" + cNro             + "' "  + CRLF
   else
	  MsgInfo("Solicitação de Compras não encontrada!", "CaoaTec") 
	  lProc      := .F.
   EndIF
Endif

If TcSqlExec(cUpdate) < 0
   Help( ,, "CaoaTec",, TcSqlError() , 1, 0)
Else
    If lProc
		Begin Sequence

			//Linha nova
			oWsdl:lSSLInsecure := .T.
			//Cancela formulario no Fluig
			cXML := H_PE_MT110TOK() //Reaproveita o XML em solicitação.
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
			If     cTp  = '1'
					MsgInfo("Atualização do pedido de compras realizada com sucesso!", "CaoaTec")
			Elseif cTp  = '2'
					MsgInfo("Atualização do contrato de parceria realizada com sucesso!", "CaoaTec")
			ElseIf cTp  = '3'
					MsgInfo("Atualização da solicitação de compras realizada com sucesso!", "CaoaTec")
			Endif
		End Sequence
    else
        Return .f.
    Endif
EndIf

Return .T.
