/*
=====================================================================================
Programa.:              I650EMP (MATI650)
Autor....:              Atilio Amarilla
Data.....:              04/06/2019
Descricao / Objetivo:   Desabilitar envio de empenho (SD4) na Integra��o PCP x MES
Doc. Origem:            MATI650
Solicitante:            CAOA
Uso......:              Integra��o PCP x Totvs MES
Obs......:		
=====================================================================================
*/
#Include 'Protheus.ch'

User Function I650EMP()

	//Local cNumOP := PARAMIXB[1] //N�mero da ordem de produ��o (C2_NUM+C2_ITEM+C2_SEQUEN) 
	Local lEnvEmpe := .T.

Return lEnvEmpe
