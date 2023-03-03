#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*
=====================================================================================
Programa.:              MTA125MNU
Autor....:              FSW - DWC Consult	
Data.....:              21/03/2019 
Descricao / Objetivo:   Adiciona botões no Browse dos Contratos de Parceria
Doc. Origem:            
Solicitante:            Compras
Uso......:              Caoa Montadora de Veiculos
Obs......:
=====================================================================================
Histórico de Alterações:

** 18/07/2019 - CAOA - Evandro A Mariano dos Santos 
Adicionado Botão "Audit.Doc.CAOA", {|| U_ZCOMF001("CP")} 
=====================================================================================
*/

User Function MTA125MNU()
	
	aAdd(aRotina, {'Hist. Alterações' ,"U_HISTSC3" , 0 , 2, 0, Nil})	

	//18/07/2019 - CAOA - Evandro A Mariano dos Santos - Adicionado Botão
	If FindFunction("U_ZCOMF001")
	   Aadd( aRotina, { "Audit.Doc.CAOA", {|| U_ZCOMF001("CP")}, 0, 0 } )
	EndIf

Return