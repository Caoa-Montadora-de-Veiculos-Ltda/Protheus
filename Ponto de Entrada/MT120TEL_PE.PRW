#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} MT120TEL
P.E. - Manipulação do cabeçalho da Solicitação de Compras
@author
@since 21/10/2020

@version 1.0
@type function
/*/
user function MT120TEL()
    Local _lRet
	//local bXTPIMPGWhen := { || nOpcx == 3 .Or. nOpcx == 4 }
    Local oNewDialog   := PARAMIXB[1]
	Local aPosGet      := PARAMIXB[2]
	Local nOpcx        := PARAMIXB[4]
	Local nReg         := PARAMIXB[4]

	// ** ************************************************************ ** //
    // **  DIALOG INFORMACOES ADICIONAIS (Enchoise / MsmGet)           ** //
    // ** ************************************************************ ** //
	If FindFunction("U_ZCOMF029")

		Begin Sequence
		    _lRet := U_ZCOMF029({oNewDialog,aPosGet,nOpcx,nReg})
		End Sequence

	EndIf

Return (_lRet)
