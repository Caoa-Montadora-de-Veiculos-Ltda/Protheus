
#include "protheus.ch"

User Function MT116AGR()

    Local _cEmp		:= FWCodEmp()
	Local aArea		:= GetArea()
	
	If _cEmp == "2020" //Executa CaoaSp

        If IsInCallStack("GFEA065IN")
            RecLock("SF1",.F.)
                SF1->F1_ORIGEM := "GFEA065"
            SF1->(MsUnLock())
        EndIf

    EndIf

    RestArea(aArea)

Return()
