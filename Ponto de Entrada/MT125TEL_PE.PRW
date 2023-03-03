#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} MT125TEL
P.E. - Manipulação do cabeçalho do Contrato de Parceria
@author
@since 21/10/2020
@version 1.0
@type function
/*/
user function MT125TEL()
    Local _lRet
	//local bXTPIMPGWhen := { || nOpcx == 3 .Or. nOpcx == 4 }
    Local oNewDialog   := PARAMIXB[1]
	Local aPosGet      := PARAMIXB[2]
	Local nOpcx        := PARAMIXB[4]
	Local nReg         := PARAMIXB[4]
	Public cC3_SCOP    := Space(10)
    //Public cC7_SCOM 	:= Space(10)
    //Public cC7_SFOR 	:= Space(10)
	// ** ************************************************************ ** //
    // **  DIALOG INFORMACOES ADICIONAIS (Enchoise / MsmGet)           ** //
    // ** ************************************************************ ** //
	//If FindFunction("U_ZCOMF026")

		Begin Sequence
		    _lRet := U_ZCOMF026({oNewDialog,aPosGet,nOpcx,nReg})
		End Sequence

	//EndIf

Return (_lRet)
