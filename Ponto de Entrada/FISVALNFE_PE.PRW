#include "totvs.ch"
#include "protheus.ch"

User Function FISVALNFE()
	Local lRes := .T.

	If Findfunction("U_ZFATF011") .And. Upper(Alltrim(FunName())) <> "ZFATF019"
		lRes := U_ZFATF011()
	Endif
	
Return lRes

