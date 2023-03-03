User Function A100DEL()

   Local _cEmp      := FWCodEmp()
   Local _lRet      := .T.
   Local aArea	    := GetArea()

    If _cEmp == "2020" //Executa o p.e. Anapolis.
        If !IsInCallStack("GFEA065") .And. AllTrim(SF1->F1_ORIGEM) == "GFEA065"
            lRet := .F.
            Help( ,, 'Help',,"Documento gerado pela rotina do GFE e só pode ser excluido por aquela rotina.", 1, 0 )
        EndIf
    EndIf

   RestArea(aArea)

Return(_lRet)
