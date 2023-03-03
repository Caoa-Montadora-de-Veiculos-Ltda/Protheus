#include "Protheus.ch"

// P.E. depois da inclusao do titulo a pagar, logo apos a gravacao do SE2 e antes da contabilizacao 
User Function F050INC()

If Findfunction("U_CMVFIN01")
	U_CMVFIN01()
EndIf

return() 
		
		