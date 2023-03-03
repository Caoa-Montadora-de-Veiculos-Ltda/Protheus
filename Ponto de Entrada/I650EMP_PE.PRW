/*
=====================================================================================
Programa.:              I650EMP (MATI650)
Autor....:              Atilio Amarilla
Data.....:              04/06/2019
Descricao / Objetivo:   Desabilitar envio de empenho (SD4) na Integração PCP x MES
Doc. Origem:            MATI650
Solicitante:            CAOA
Uso......:              Integração PCP x Totvs MES
Obs......:		
=====================================================================================
*/
#Include 'Protheus.ch'

User Function I650EMP()

	//Local cNumOP := PARAMIXB[1] //Número da ordem de produção (C2_NUM+C2_ITEM+C2_SEQUEN) 
	Local lEnvEmpe := .T.

Return lEnvEmpe
