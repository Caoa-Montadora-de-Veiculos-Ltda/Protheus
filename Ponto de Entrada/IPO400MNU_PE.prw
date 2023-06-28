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
Obs......:	DAC - 23/06/2023 PEC044			
			Alterado para FWIsInCallStack com FindFunction estava trazendo todos os itens para o menu independente da funcionalidade
=====================================================================================
*/
User Function IPO400MNU()

	Local aRetorno := {}

	If FWIsInCallStack("U_ZEICF012")   //FindFunction("U_ZEICF012")
		aAdd(aRetorno, {"(CAOA) Alt.Fabricante", "U_ZEICF012" , 0, 4})
	EndIf

	If FWIsInCallStack("U_ZCOMR004")  //FindFunction("U_ZCOMR004")
		aAdd(aRetorno, {"(CAOA) Imp. Pedido"   , "U_ZCOMR004" , 0, 4})
	EndIf

	If FWIsInCallStack("U_ZEICR002")  //FindFunction("U_ZEICR002")
		aAdd(aRetorno, {"(CAOA) Relatorio Pedido para Fornecedor"   , "U_ZEICR002" , 0, 2})
	EndIf
	//DAC 23/06/2023 PEC044
	//PE utilizado para funcionar como consulta de PO pois somente a chamada da função de consulta PO400Visua não funciona deve ser utilizado com filtro no PE EICPPO01
	If FWIsInCallStack("U_ZPECF027")  
		aRotina 	:= {}  //ZERO A ROTINA
		aRetorno 	:= {}
		aRetorno 	:=  { 	{"Vizualizar","PO400Visua", 0 , 2} } //"Visual"
	Endif
Return(aRetorno)

