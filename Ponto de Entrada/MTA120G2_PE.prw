User Function MTA120G2( )

//Salvar dados no PC
//IF IsInCallStack("U_MTA120G2")
	If FindFunction("U_ZCOMF028")

		Begin Sequence
		    _lRet := U_ZCOMF028()
		End Sequence

	EndIf
//EndIf
Return Nil
