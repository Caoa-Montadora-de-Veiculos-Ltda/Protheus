#Include "PROTHEUS.CH"
#Include "TOTVS.ch"

/*
===========================================================================================
Programa.:              
Autor....:              CAOA - Fagner Barreto
Data.....:              07/03/2022
Descricao / Objetivo:      
===========================================================================================
*/
User Function OM010MNU()

    aAdd(aRotina,{ "Caoa - Importar Tabela de Preços"  ,"U_ZPECF001()"  ,0 ,3 ,0 ,NIL })
    aAdd(aRotina,{ "Caoa - Atualizar Preços por UF"    ,"U_ZPECF016()"  ,0 ,3 ,0 ,NIL })

Return
