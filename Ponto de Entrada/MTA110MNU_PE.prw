#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
/* 
=====================================================================================
Programa.:              MTA110MNU
Autor....:              Deivys Joenck	
Data.....:              22/11/18 
Descricao / Objetivo:   utilizado para adicionar botões ao Menu Principal através 
						do array aRotina
Doc. Origem:            
Solicitante:            Compras
Uso......:              Caoa Montadora de Veiculos
Obs......:
=====================================================================================
Histórico de Alterações:

** 28/02/2019 - Cristiam Rossi - TOTVS
As funções estão no fonte DWCXCMP.PRW

** 18/07/2019 - CAOA - Evandro A Mariano dos Santos 
Adicionado Botão "Audit.Doc.CAOA", {|| U_ZCOMF001("SC")} 

** 04/01/2022 - CAOA - Sandro Ferreira 
Adicionado Botão "Importação SC Protheus"     , {|| U_ZCOMF43("SC" )}
Adicionado Botão "Recusa de SC"               , {|| U_ZCOMF32("SC" )}
Adicionado Botão "Estorno da Recusa"          , {|| U_ZCOMF33("SC" )}
Adicionado Botão "Consulta Recusa"            , {|| U_ZCOMF42("SC" )} 
=====================================================================================
*/
 
User Function MTA110MNU()
	aAdd(aRotina, {'Hist.Alterações'       ,"U_HISTSC1"   , 0 , 2, 0, nil})	
	aAdd(aRotina, {'Gerar C.Parceria'      ,"U_GERCPAR"   , 0 , 2, 0, nil})	
	aAdd(aRotina, {'Importação CSV'        ,"U_IMPCSV"    , 0 , 3, 0, nil})
	aAdd(aRotina, {'Impressão SC EIC'      ,"U_RELIMPSC"  , 0 , 2, 0, nil})
	aAdd(aRotina, {'Importação SC Protheus',"U_ZCOMF043"  , 0 , 3, 0, nil})
	aAdd(aRotina, {'Recusa  de SC'         ,"U_ZCOMF032"  , 0 , 3, 0, nil})
	aAdd(aRotina, {'Estorno da Recusa'     ,"U_ZCOMF033"  , 0 , 2, 0, nil})
    aAdd(aRotina, {'Consulta Recusa '      ,"U_ZCOMF042"  , 0 , 2, 0, nil})

	//18/07/2019 - CAOA - Evandro A Mariano dos Santos - Adicionado Botão
	If FindFunction("U_ZCOMF001")
	   Aadd( aRotina, { "Audit.Doc.CAOA", {|| U_ZCOMF001("SC")}, 0, 0 } )
	EndIf

Return nil
