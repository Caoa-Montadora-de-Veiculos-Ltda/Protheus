#include "TOTVS.CH"

/*
=====================================================================================
Programa.:              IMP675OS
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              20/08/19
Descricao / Objetivo:   Ponto de Entrada para adicionar relatorio personalizado.
                        da Ordem de Servi�o.
Doc. Origem:            
Solicitante:            Compras
Uso......:              Caoa Montadora de Veiculos
Obs......:
=====================================================================================
*/
User Function IMP675OS()

Local aArea := GetArea()
Local aOpcRot := {}
 
If FindFunction("U_ZMNTR001")
    // Adiciona Op��es de impress�o
    aAdd(aOpcRot, { "Completa (CAOA)"      ,"U_ZMNTR001"    } )
EndIf

RestArea(aArea)

Return(aOpcRot)
