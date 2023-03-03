#INCLUDE "PROTHEUS.CH"

/*
================================================================================
Programa.:              zGENIBGEUF
Autor....:              CAOA - Evandro Mariano
Data.....:              19/05/2022
Descricao / Objetivo:   Busca o Código o IBGE do Estado
Parametros:             cMsgLock - Grava mensagem de erro em caso de lock
						cAlias - Alias da tabela que sera avaliada
                        aRecnos - Array contendo os recnos que serão avaliados
Doc. Origem:            
Solicitante:            
================================================================================
*/

User Function zGENIBGEUF(_cUF)

Local _cRet := ""

DO CASE
	CASE _cUF == "RO"
	    _cRet := "11" 
    CASE _cUF == "AC"
        _cRet := "12" 
    CASE _cUF == "AM"
        _cRet := "13"
    CASE _cUF == "RR"
        _cRet := "14" 
    CASE _cUF == "PA"
        _cRet := "15" 
    CASE _cUF == "AP"
        _cRet := "16" 
    CASE _cUF == "TO"
        _cRet := "17" 
    CASE _cUF == "MA"
        _cRet := "21"
    CASE _cUF == "PI"
        _cRet := "22"
    CASE _cUF == "CE"
        _cRet := "23"
    CASE _cUF == "RN"
        _cRet := "24" 
    CASE _cUF == "PB"
        _cRet := "25" 
    CASE _cUF == "PE"
        _cRet := "26" 
    CASE _cUF == "AL"
        _cRet := "27" 
    CASE _cUF == "SE"
        _cRet := "28"
    CASE _cUF == "BA"
        _cRet := "29"
    CASE _cUF == "MG"
        _cRet := "31"
    CASE _cUF == "ES"
        _cRet := "32"
    CASE _cUF == "RJ"
        _cRet := "33"
    CASE _cUF == "SP"
        _cRet := "35"
    CASE _cUF == "PR"
        _cRet := "41"
    CASE _cUF == "SC"
        _cRet := "42"
    CASE _cUF == "RS"
        _cRet := "43"
    CASE _cUF == "MS"
        _cRet := "50"
    CASE _cUF == "MT"
        _cRet := "51"
    CASE _cUF == "GO"
        _cRet := "52"
    CASE _cUF == "DF"
        _cRet := "53"
	ENDCASE	
    
Return(_cRet)
