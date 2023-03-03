#include "Protheus.ch"

// P.E. para validacao da exclusao e estorno de lancamento por lote
User Function FLTESTLT()
//lRet := ExecBlock("FLTESTLT",.F.,.F.)

Local lRet := .T.

If Findfunction("U_CMVSAP18")
	lRet := U_CMVSAP18()
EndIf

return(lRet) 
		
		