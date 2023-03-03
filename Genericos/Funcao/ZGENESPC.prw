#Include 'Protheus.ch'
#Include "TOTVS.CH"

/*
=====================================================================================
Programa.:              ZGENESPC
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              11/03/2022
Descricao / Objetivo:   Fun��o para remo��o e substitui��o de caracteres especiais
=====================================================================================
*/
User Function ZGENESPC(cRet)
	Local cCaracEsp := "-!@#$%�&*()+{}^~�`][;.>,<=/�����'?*|"+'"'
	Local nI        := 0

	//--Removendo caracteres
	For nI := 1 To Len(cCaracEsp)
		cRet := StrTran(cRet, SubStr(cCaracEsp, nI, 1), "")
	Next nI
    
    //--Substituindo caracteres
    cRet := strtran (cRet, "�", "a")
    cRet := strtran (cRet, "�", "e")
    cRet := strtran (cRet, "�", "i")
    cRet := strtran (cRet, "�", "o")
    cRet := strtran (cRet, "�", "u")
    cRet := STRTRAN (cRet, "�", "A")
    cRet := STRTRAN (cRet, "�", "E")
    cRet := STRTRAN (cRet, "�", "I")
    cRet := STRTRAN (cRet, "�", "O")
    cRet := STRTRAN (cRet, "�", "U")
    cRet := strtran (cRet, "�", "a")
    cRet := strtran (cRet, "�", "o")
    cRet := STRTRAN (cRet, "�", "A")
    cRet := STRTRAN (cRet, "�", "O")
    cRet := strtran (cRet, "�", "a")
    cRet := strtran (cRet, "�", "e")
    cRet := strtran (cRet, "�", "i")
    cRet := strtran (cRet, "�", "o")
    cRet := strtran (cRet, "�", "u")
    cRet := STRTRAN (cRet, "�", "A")
    cRet := STRTRAN (cRet, "�", "E")
    cRet := STRTRAN (cRet, "�", "I")
    cRet := STRTRAN (cRet, "�", "O")
    cRet := STRTRAN (cRet, "�", "U")
    cRet := strtran (cRet, "�", "c")
    cRet := strtran (cRet, "�", "C")
    cRet := strtran (cRet, "�", "a")
    cRet := strtran (cRet, "�", "A")
    cRet := strtran (cRet, "�", ".")
    cRet := strtran (cRet, "�", ".")
    //cRet := strtran (cRet, chr (9), " ") // TAB

Return cRet
