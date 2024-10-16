#Include "Protheus.ch"

/*
=====================================================================================
Programa.:              MaIPIVeic
Autor....:              
Data.....:              Nov/2019
Descricao / Objetivo:   PE para alterar o IPI MATXFIS - Calculo Reverso
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/
User Function MaIPIVeic()

    Local _aRet := {}

//ParamIxb[2] - Base do imposto
//ParamIxb[3] - Al�quota do imposto
//ParamIxb[4] - Valor do Imposto

    //Executa o p.e. somente para Anapolis.
    If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
        _aRet := U_CMVVEI02(ProcName())
    Else
        //Retorna os valores padr�es quando Barueri
        _aRet := {ParamIxb[2],ParamIxb[3] ,ParamIxb[4]}
    EndIf

Return(_aRet)
