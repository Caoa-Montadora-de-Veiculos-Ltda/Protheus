#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} MT690LOP
P.E. - Permite alterar o Texto da Legenda da OP na Carga Maquina.
@author FSW - DWC Consult
@since 02/12/2018
@version All
@type function
/*/
User Function MT690LOP()
	Local cLabel	:= AllTrim(ParamIxb[1])
	Local aArea		:= GetArea()
	Local aAreaC2	:= SC2->(GetArea())

	DbSelectArea("SC2")
	SC2->(DbSetOrder(1)) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

	SC2->(DbSeek(xFilial("SC2") + SubsTr(cLabel,1,8)))
	
	//Verifica se o Campo Barcode esta criado.
	If FieldPos("C2_XBARCOD") > 0
		cLabel += Replicate("",20) + " - " + SC2->C2_XBARCOD
	EndIf

	RestArea(aArea)
	RestArea(aAreaC2)
Return(cLabel)