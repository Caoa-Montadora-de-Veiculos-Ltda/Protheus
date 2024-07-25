
#include "protheus.ch"

User Function MT116AGR()

	Local aArea		:= GetArea()
	
	If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB

        If IsInCallStack("GFEA065IN")
            RecLock("SF1",.F.)
                SF1->F1_ORIGEM := "GFEA065"
            SF1->(MsUnLock())
        EndIf

    EndIf

    RestArea(aArea)

Return()
