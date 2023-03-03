#Include "Protheus.ch"

/*
=====================================================================================
Programa.:              MT103TRV
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              21/07/2021
Descricao / Objetivo:   Ponto de entrada implementado na função A103TRAVA para melhorar
                        o tempo de LOCK de registros das tabelas SA1/SA2/SB2 na inclusão 
                        do documento de entrada.
Doc. Origem:            https://tdn.totvs.com/pages/releaseview.action?pageId=45220976           
Solicitante:            Compras
Uso......:              Caoa Montadora de Veiculos
Obs......:
=====================================================================================
*/
 
User Function MT103TRV()

//Local cFornece  := PARAMIXB1 // Codigo do Fornecedor/Cliente
//Local cLoja     := PARAMIXB2 // Codigo da Loja
//Local cTipo     := PARAMIXB3 // C = Cliente (SA1) / F = Fornecedor (SA2)
Local aRet      := ARRAY(4)

aRet[1] := .F. //Desliga trava da tabela SA1
aRet[2] := .F. //Desliga trava da tabela SA2
aRet[3] := .F. //Desliga trava da SB2
aRet[4] := .T. //Atualiza os Acumulados somente no final da gravação dos itens da NFE

Return(aRet)
