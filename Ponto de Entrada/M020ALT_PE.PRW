#Include 'Protheus.ch'
/*
=====================================================================================
Programa.:              M020ALT
Autor....:              Julio Sousa
Data.....:              27/08/18
Descricao / Objetivo:   PE para adicionar customiza��es, ap�s a grava��o do Fornecedor.
Doc. Origem:            
Solicitante:            CAOA
Uso......:              
Obs......:				Gera XML de envio ao SAP, com os dados do fornecedor.
=====================================================================================
*/
**************************************************************************************************************************************************
User Function M020ALT()
**************************************************************************************************************************************************

U_ZF10GENSAP("SA2",SA2->A2_COD+SA2->A2_LOJA,"A2_XCDSAP",4)

// Integra��o como o SILT
IF SA2->A2_TIPO == 'J'
	RecLock("SA2", .F.)
	//SA2->A2_XSILST  := 'N'
	SA2->(MsUnlock())
EndIF

Return .T.

