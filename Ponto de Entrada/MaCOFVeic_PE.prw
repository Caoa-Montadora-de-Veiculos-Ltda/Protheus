#Include "Protheus.ch"

/*
=====================================================================================
Programa.: MaCOFVeic
Autor....:
Data.....: Nov/2019
Descricao / Objetivo: PE para alterar o COFINS da MATXFIS - Calculo Reverso
Doc. Origem: GAP
Solicitante: Cliente
Uso......: CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/
User Function MaCOFVeic()

    Local _aRet := {}
    Local _cEmp := FWCodEmp()

    //ParamIxb[2] - Base do imposto
    //ParamIxb[3] - Alíquota do imposto
    //ParamIxb[4] - Valor do Imposto

    If _cEmp == "2010" //Executa o p.e. somente para Anapolis.
        _aRet       := U_CMVVEI02(ProcName())
    Else
        //Retorna os valores padrões quando Barueri
        _aRet       :={ParamIxb[2], ParamIxb[3], ParamIxb[4]}
    EndIf

Return(_aRet)

