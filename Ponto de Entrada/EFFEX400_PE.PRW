#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} EFFEX400
PE para Manutenção de contrato de financiamento
https://tdn.totvs.com/pages/releaseview.action?pageId=499105909
@type Function

@author Joni Lima do Carmo
@since 10/09/2019
@version P12
/*/
User Function EFFEX400()

	Local cParamIXB
	Local aEntCTB := {"","","",""}

	Begin Sequence

	If ValType(ParamIXB) == "A"
		cParamIXB:= ParamIXB[1]
	Else
		cParamIXB:= ParamIXB
	EndIf

	Do Case

		Case cParamIXB == "ANTES_GRAVA_EF3"
		Case cParamIXB == "GRAVANDO_EF3"
			aEntCTB := xEnceC6(EF3->EF3_TP_EVE,EF3->EF3_CODEVE)
			EF3->EF3_CONTA := aEntCTB[1]
			EF3->EF3_CCUSTO := aEntCTB[2]
			EF3->EF3_ITEMCT := aEntCTB[3]
			EF3->EF3_CLVL := aEntCTB[4]
		Case cParamIXB == "INC_EF3"
		EndCase

	End Sequence

Return .T.

Static Function xEnceC6(cTpModu,cIdCam)

	Local aArea 	:= GetArea()
	Local aAreaEC6	:= EC6->(GetArea())
	Local cTipoModu := ""
	Local aRet   	:= {"","","",""}

	If cTpModu == "05"
		cTipoModu := "FIIM05"
	Else
		cTipoModu := "FIEX" + cTpModu
	EndIf

	dbSelectArea("EC6")
	EC6->(dbSetOrder(1))//EC6_FILIAL+EC6_TPMODU+EC6_ID_CAM+EC6_IDENTC

	If EC6->(dbSeek(xFilial("EC6") + cTipoModu + cIdCam ))
		aRet := {EC6->EC6_CONTA,EC6->EC6_XCCUST,EC6->EC6_ITEMCT,EC6->EC6_CLVL}
	EndIf

	RestArea(aAreaEC6)
	RestArea(aArea)

Return aRet
