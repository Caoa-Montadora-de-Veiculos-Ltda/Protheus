#Include "PROTHEUS.CH"
#Include "TOTVS.CH"

/*
===========================================================================================
Programa.:              WMSA320M
Autor....:              CAOA - Fagner Barreto
Data.....:              25/03/2021
Descricao / Objetivo:   PE usado ap�s a defini��o do aRotina e antes da montagem do Browse      
===========================================================================================
*/
User Function WMSA320M()

    If FindFunction("U_ZWMSF018")
        //--Efetua a substitui��o da chamada do Relat�rio CHECK-OUT por um customizado
        U_ZWMSF018()
    Endif

Return 
