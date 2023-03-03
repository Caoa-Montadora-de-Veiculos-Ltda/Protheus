

/*=====================================================================================
Programa.:              ZCOMF039
Autor....:              CAOA - Valter Carvalho
Data.....:              17/08/2020
Descricao / Objetivo:   Preenche o acols do campo de TES de todos os itens de um doc de entrada
Solicitante:            Barbara
Uso......:              
===================================================================================== */
user function ZCOMF039()
     Local aPerg    := {}
     Local aRt      := {}
     Local cD1_TES  := Ascan(aHeader, {|x| Alltrim(x[2]) == "D1_TES"})
     Local cTes     := Space(TamSx3("F4_CODIGO")[1])
     
     Local i        := 1
     Private n      := 1
     If (INCLUI = .F. .AND. ALTERA = .F.)
          Return
     EndIf

     Aadd(aPerg, {1, AllTrim(aHeader[cD1_TES, 1]), cTes, "@!", "", "SF4", "", 30, .T.})
     If (ParamBox(aPerg, "Tipo de entrada", aRt) = .F.)
          Return
     EndIf

     For i:= 1 to Len(aCols)
          n:= i;
          
          aCols[n][cD1_TES]	:= aRt[1]
		__READVAR	:= PADR("D1_TES",10)
		&("M->"+__READVAR)	:=  aRt[1]
		&(GetSx3Cache(__READVAR,"X3_VALID"))
		RunTrigger(2, n, nil,,__READVAR)
     Next     
     MsgInfo("TES Alterada.", "ZCOMF039()")
Return
