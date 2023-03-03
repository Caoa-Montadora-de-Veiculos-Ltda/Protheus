#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*
=====================================================================================
Programa.:              MT120BRW
Autor....:              FSW - DWC Consult	
Data.....:              21/03/2019 
Descricao / Objetivo:   Adiciona botões no Browse do Pedido de Compras e 
						Autorização de Entrega.
Doc. Origem:            
Solicitante:            Compras
Uso......:              Caoa Montadora de Veiculos
Obs......:
=====================================================================================
Histórico de Alterações:

** 18/07/2019 - CAOA - Evandro A Mariano dos Santos 
Adicionado Botão "Audit.Doc.CAOA", {|| U_ZCOMF001("CP")} 
Adicionado Botão "Impr.PC.CAOA", "U_ZCOMR001()"
=====================================================================================
*/

User Function MT120BRW()

	If FindFunction("U_HISTSC7")
		aAdd(aRotina, {'Hist. Alterações' ,"U_HISTSC7" , 0 , 2, 0, Nil})
	EndIf

	//18/07/2019 - CAOA - Evandro A Mariano dos Santos - Adicionado Botão
	If FindFunction("U_ZCOMF001")
		If AllTrim(FunName()) == "MATA121"
			Aadd( aRotina, { "Audit.Doc.CAOA", {|| U_ZCOMF001( "PC")}, 0, 0 } )
		ElseIf AllTrim(FunName()) == "MATA122"
			Aadd( aRotina, { "Audit.Doc.CAOA", {|| U_ZCOMF001( "AE")}, 0, 0 } )
		EndIf
	EndIf

	//18/07/2019 - CAOA - Evandro A Mariano dos Santos - Adicionado Botão
	If FindFunction("U_ZCOMR001")
		Aadd( aRotina, { "Impr.PC.CAOA", "U_ZCOMR001()", 0, 0 } )
	EndIf
		
Return( aRotina )