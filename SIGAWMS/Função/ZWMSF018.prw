#Include "PROTHEUS.CH"
#Include "TOTVS.CH"

/*
===================================================================================================
Programa.:              ZWMSF018
Autor....:              CAOA - Fagner Barreto
Data.....:              25/03/2021
Descricao / Objetivo:   Efetua a substitui��o da chamada do Relat�rio CHECK-OUT por um customizado                           
===================================================================================================
*/
User Function ZWMSF018()
    Local nI := 0

    If IsInCallStack("WMSA320")
        For nI := 1 To Len(aRotina)
            If ValType(aRotina[nI]) == "A"
                If aRotina[nI][1] == "Relat�rio CHECK-OUT"
                    aRotina[nI] := {"Relat�rio CHECK-OUT", "U_ZWMSR325", 0, 10 }
                EndIf
            EndIf 
        Next nI
    EndIf

Return
