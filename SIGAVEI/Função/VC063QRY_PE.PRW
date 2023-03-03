#include "totvs.ch"

User Function VC063QRY()

	Local cQuery := ParamIXB[1]

	Local aParamBox := {}
	Local aRetParambox := {}

	aAdd(aParamBox,{1,RetTitle("A1_XTIPO"),Space(TamSX3("A1_XTIPO")[1]),"@!","","SZA","",0,.F.})
	If ! ParamBox(aParamBox,"",@aRetParambox,,,,,,,,.f.) 
		Return cQuery
	EndIf

	If Empty(aRetParambox[1])
		Return cQuery
	EndIf

	cQuery += " AND A1_XTIPO = '" + aRetParambox[1] + "'"

Return cQuery