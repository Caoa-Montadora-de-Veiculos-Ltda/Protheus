#include "Protheus.ch"

/*
=====================================================================================
Programa.:              ZCOMF020
Autor....:              CAOA - Valter Carvalho
Data.....:              28/04/2020
Descricao / Objetivo:   Validacoes no preenchimento do cadastro de fornecedor
Doc. Origem:
Solicitante:            Antonio Marcio
Uso......:              
=====================================================================================
*/


User Function ZCOMF020()
    Local cErr      := ""
    Local aCampos   := {"A2_COD", "A2_LOJA"}
    Local cNmCp     := PARAMIXB[5]
    Local cVlCp     := PARAMIXB[6]

    If ASCAN(aCampos, cNmCp) > 0
        if isNumber(CVlCp) = .F.
            cErr += " - Campo " + GetSx3Cache(cNmCp, "X3_TITULO") + " deve conter caracteres numéricos apenas." + CRLF
        endif

        if Len(Alltrim(cVlCp)) <>  GetSx3Cache(cNmCp, "X3_TAMANHO")
            cErr += " - Campo " + GetSx3Cache(cNmCp, "X3_TITULO") + " deve conter " + CvalToChar(GetSx3Cache(cNmCp, "X3_TAMANHO")) + " caracteres. " + CRLF
        EndIf
    EndIf

    If cErr <> ""
        Help("ZCOMF020", 1,   "ZCOMF020",, CRLF + cErr, 1, 22, NIL, NIL, NIL, NIL, NIL, {"O campo " + GetSx3Cache(cNmCp, "X3_TITULO") + " só deve ter caraceres numéricos e sem espaços em branco."})
    EndIf

Return (cErr = "")



/*
=====================================================================================
Programa.:              isNumber
Autor....:              CAOA - Valter Carvalho
Data.....:              28/04/2020
Descricao / Objetivo:   Testa se a String contem somente caracteres numericos
Doc. Origem:
Solicitante:            Antonio Marcio
Uso......:              
=====================================================================================
*/

Static Function isNumber(cStr)
    Local lRes  := .T.
    Local i     := 1
    Local cAux  := "0123456789"

    For i:= 1 to Len(cStr)
        If (Substr(cStr, i, 1) $ cAux) = .F.
            lRes := .F.
        EndIf
    Next

Return lRes