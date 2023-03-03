#Include 'Protheus.ch'
#Include "TOTVS.CH"

/*
=====================================================================================
Programa.:              ZGENESPC
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              11/03/2022
Descricao / Objetivo:   Função para remoção e substituição de caracteres especiais
=====================================================================================
*/
User Function ZGENESPC(cRet)
	Local cCaracEsp := "-!@#$%¨&*()+{}^~´`][;.>,<=/¢¬§ªº'?*|"+'"'
	Local nI        := 0

	//--Removendo caracteres
	For nI := 1 To Len(cCaracEsp)
		cRet := StrTran(cRet, SubStr(cCaracEsp, nI, 1), "")
	Next nI
    
    //--Substituindo caracteres
    cRet := strtran (cRet, "á", "a")
    cRet := strtran (cRet, "é", "e")
    cRet := strtran (cRet, "í", "i")
    cRet := strtran (cRet, "ó", "o")
    cRet := strtran (cRet, "ú", "u")
    cRet := STRTRAN (cRet, "Á", "A")
    cRet := STRTRAN (cRet, "É", "E")
    cRet := STRTRAN (cRet, "Í", "I")
    cRet := STRTRAN (cRet, "Ó", "O")
    cRet := STRTRAN (cRet, "Ú", "U")
    cRet := strtran (cRet, "ã", "a")
    cRet := strtran (cRet, "õ", "o")
    cRet := STRTRAN (cRet, "Ã", "A")
    cRet := STRTRAN (cRet, "Õ", "O")
    cRet := strtran (cRet, "â", "a")
    cRet := strtran (cRet, "ê", "e")
    cRet := strtran (cRet, "î", "i")
    cRet := strtran (cRet, "ô", "o")
    cRet := strtran (cRet, "û", "u")
    cRet := STRTRAN (cRet, "Â", "A")
    cRet := STRTRAN (cRet, "Ê", "E")
    cRet := STRTRAN (cRet, "Î", "I")
    cRet := STRTRAN (cRet, "Ô", "O")
    cRet := STRTRAN (cRet, "Û", "U")
    cRet := strtran (cRet, "ç", "c")
    cRet := strtran (cRet, "Ç", "C")
    cRet := strtran (cRet, "à", "a")
    cRet := strtran (cRet, "À", "A")
    cRet := strtran (cRet, "º", ".")
    cRet := strtran (cRet, "ª", ".")
    //cRet := strtran (cRet, chr (9), " ") // TAB

Return cRet
