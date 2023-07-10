#include "Protheus.ch"

/* 
=====================================================================================
Programa.:              EICPPO01
Autor....:              CAOA - DAC 
Data.....:              23/06/2023 
Descricao / Objetivo:   Ponto de Entrada para filtrar P.O.
                        Manutenção de P.o.
Doc. Origem:            PEC044
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
User Function EICPPO01()
Local cFiltro
	//DAC 23/06/2023 PEC044
	//PE utilizado para funcionar como consulta de PO pois somente a chamada da função de consulta PO400Visua não funciona deve ser utilizado com filtro no PE EICPPO01
	//cAliasTmp é private e vem do ZPECF027
	If FWIsInCallStack("U_ZPECF030")
	    cFiltro := "W2_FILIAL='"+xFilial("SW2")+"' .And.  AllTrim(W2_PO_NUM) = '"+AllTrim((cAliasTmp)->PEDIDO)+"'"
   	 	SET FILTER TO &cFiltro        
	Endif 
Return Nil
