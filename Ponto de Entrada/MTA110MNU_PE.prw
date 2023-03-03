#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
/* 
=====================================================================================
Programa.:              MTA110MNU
Autor....:              Deivys Joenck	
Data.....:              22/11/18 
Descricao / Objetivo:   utilizado para adicionar bot�es ao Menu Principal atrav�s 
						do array aRotina
Doc. Origem:            
Solicitante:            Compras
Uso......:              Caoa Montadora de Veiculos
Obs......:
=====================================================================================
Hist�rico de Altera��es:

** 28/02/2019 - Cristiam Rossi - TOTVS
As fun��es est�o no fonte DWCXCMP.PRW

** 18/07/2019 - CAOA - Evandro A Mariano dos Santos 
Adicionado Bot�o "Audit.Doc.CAOA", {|| U_ZCOMF001("SC")} 

** 04/01/2022 - CAOA - Sandro Ferreira 
Adicionado Bot�o "Importa��o SC Protheus"     , {|| U_ZCOMF43("SC" )}
Adicionado Bot�o "Recusa de SC"               , {|| U_ZCOMF32("SC" )}
Adicionado Bot�o "Estorno da Recusa"          , {|| U_ZCOMF33("SC" )}
Adicionado Bot�o "Consulta Recusa"            , {|| U_ZCOMF42("SC" )} 
=====================================================================================
*/
 
User Function MTA110MNU()
	aAdd(aRotina, {'Hist.Altera��es'       ,"U_HISTSC1"   , 0 , 2, 0, nil})	
	aAdd(aRotina, {'Gerar C.Parceria'      ,"U_GERCPAR"   , 0 , 2, 0, nil})	
	aAdd(aRotina, {'Importa��o CSV'        ,"U_IMPCSV"    , 0 , 3, 0, nil})
	aAdd(aRotina, {'Impress�o SC EIC'      ,"U_RELIMPSC"  , 0 , 2, 0, nil})
	aAdd(aRotina, {'Importa��o SC Protheus',"U_ZCOMF043"  , 0 , 3, 0, nil})
	aAdd(aRotina, {'Recusa  de SC'         ,"U_ZCOMF032"  , 0 , 3, 0, nil})
	aAdd(aRotina, {'Estorno da Recusa'     ,"U_ZCOMF033"  , 0 , 2, 0, nil})
    aAdd(aRotina, {'Consulta Recusa '      ,"U_ZCOMF042"  , 0 , 2, 0, nil})

	//18/07/2019 - CAOA - Evandro A Mariano dos Santos - Adicionado Bot�o
	If FindFunction("U_ZCOMF001")
	   Aadd( aRotina, { "Audit.Doc.CAOA", {|| U_ZCOMF001("SC")}, 0, 0 } )
	EndIf

Return nil
