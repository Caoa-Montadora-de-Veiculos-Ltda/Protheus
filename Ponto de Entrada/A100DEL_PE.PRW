User Function A100DEL()

   Local _lRet      := .T.
   Local aArea	    := GetArea()

    If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
        If !IsInCallStack("GFEA065") .And. AllTrim(SF1->F1_ORIGEM) == "GFEA065"
            lRet := .F.
            Help( ,, 'Help',,"Documento gerado pela rotina do GFE e só pode ser excluido por aquela rotina.", 1, 0 )
        EndIf
    EndIf

   RestArea(aArea)

Return(_lRet)
