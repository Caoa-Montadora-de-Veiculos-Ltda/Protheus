#INCLUDE 'PROTHEUS.CH'

/*
{Protheus.doc} WFW120P
Ponto de entrada para zerar os campos do fluig na copia dos pedidos de compras.

@author  Sandro Ferreira
@version 1.0
@since   30/07/2021
@return  Nil  Sem retorno.
@sample
*/

User Function WFW120P()
	Local cPedido  :=  PARAMIXB
	Local aArea	   := GetArea()
	Local oWsdl      := TWsdlManager():New()
	Local _cEmp    := FWCodEmp()
	Private cFUsuario   := GetMV("ES_XFLUIG1",,"integrador")
	Private cFSenha     := GetMV("ES_XFLUIG2",,"integrador")
	Private cFEmpresa   := GetMV("ES_XFLUIG4",,"1")
	Private cFIdUsuario := GetMV("ES_XFLUIG3",,"integrador")
	Private cFNumFluig  := Alltrim(SC7->C7_XFLUIG5)  //Determina o processo se pedido ou solicitacao.
	Private cFMensagem  := "Pedido cancelado pelo Usuario Protheus"

	If _cEmp == "2010" //Executa o p.e. Anapolis.
		If INCLUI //.or. ALTERA
			Begin Sequence

				//Linha nova
				oWsdl:lSSLInsecure := .T.

				U_ZFLUIF02(cEmpAnt,cFilAnt)

			End Sequence
		Endif



		IF cCPY .and. !INCLUI
			dBselectArea('SC7')
			dbSetOrder(1)
			dbSeek(cPedido)
			If cPedido == (SC7->C7_FILIAL + SC7->C7_NUM)
				While !SC7->(Eof()) .and. cPedido == (SC7->C7_FILIAL + SC7->C7_NUM)
					If  SC7->( DbRLock(Recno()) )
						SC7->C7_XFLUIG1 := "N"
						SC7->( MsUnLock() )
					EndIf
					SC7->(DbSkip())
				End
			ENDIF

			Begin Sequence

				oWsdl:lSSLInsecure := .T.

				U_ZFLUIF02(cEmpAnt,cFilAnt)

			End Sequence

		Endif
	EndIF
	RestArea(aArea)
Return .T.
