/*
=====================================================================================
Programa.:              A680MOD (MATA680/1)
Autor....:              Atilio Amarilla
Data.....:              04/02/2020
Descricao / Objetivo:   Permite alterar qtde de MOD calculada/gerada pelo roteiro
Doc. Origem:            
Solicitante:            CAOA
Uso......:              Apontamento MATA681. Zerar MOD no apontamento.
Obs......:				
=====================================================================================
*/
User Function A680MOD()

	Local nRet	:= PARAMIXB
	Local lMod	:= GetMv("CMV_MODROT",,.F.)
	
	// ConOut("PARAMIXB: "+AllTrim(Str(PARAMIXB)))
	
	If !lMod
		nRet := 0
	EndIf

Return nRet