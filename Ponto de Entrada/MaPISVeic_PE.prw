#Include "Protheus.ch"

/*
=====================================================================================
Programa.:              MaPISVeic
Autor....:              
Data.....:              Nov/2019
Descricao / Objetivo:   PE para alterar o PIS da MATXFIS - Calculo Reverso
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/
User Function MaPISVeic()

    Local _aRet  := {}
   
//ParamIxb[2] - Base do imposto
//ParamIxb[3] - Alíquota do imposto
//ParamIxb[4] - Valor do Imposto

    If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
        _aRet := U_CMVVEI02(ProcName())
    Else
        //Retorna os valores padrões quando Barueri
        _aRet := {ParamIxb[2],ParamIxb[3],ParamIxb[4]}
    EndIf

Return(_aRet)
