#include "Protheus.ch"

/* 
=====================================================================================
Programa.:              IPO400MNU
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              24/06/2019 
Descricao / Objetivo:   Ponto de Entrada para adicionar função no menu da rotina de
                        Manutenção de P.o.
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
User Function IPO400MNU()

	Local aRetorno := {}

	If FindFunction("U_ZEICF012")
		aAdd(aRetorno, {"(CAOA) Alt.Fabricante", "U_ZEICF012" , 0, 4})
	EndIf

	If FindFunction("U_ZCOMR004")
		aAdd(aRetorno, {"(CAOA) Imp. Pedido"   , "U_ZCOMR004" , 0, 4})
	EndIf

	If FindFunction("U_ZEICR002")
		aAdd(aRetorno, {"(CAOA) Relatorio Pedido para Fornecedor"   , "U_ZEICR002" , 0, 2})
	EndIf

Return(aRetorno)

