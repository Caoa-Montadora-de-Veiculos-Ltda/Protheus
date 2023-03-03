#include "totvs.ch"
#include "protheus.ch"

User Function FISVALNFE()
	Local lRes := .T.

	If Findfunction("U_ZFATF011")
		lRes := U_ZFATF011()
	Endif
	
Return lRes

