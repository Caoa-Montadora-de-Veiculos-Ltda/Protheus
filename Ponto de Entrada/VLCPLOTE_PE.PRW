#include "Protheus.ch"

// P.E. para validacao da capa do lancamnto contabil
User Function VLCPLOTE()
//lRet := ExecBlock("VLCPLOTE",.F.,.F.,{dDataLanc,cLote,cSubLote,cDoc,nOpc})

Local lRet := .T.

If Findfunction("U_CMVSAP18")
	lRet := U_CMVSAP18()
EndIf

return(lRet) 
		
		