#Include "Totvs.CH"
#include "parmtype.ch"

/*/{Protheus.doc} CRMA980
Ponto de Entrada para Cadastro de cliente MVC
@author CAOA
@since 
@version 2.0
@project
@history    DAC Denilso - 24/02/2023 
            GRUPO CAOA - GAP FIN100 - Campo Matriz Clientes (Revitalização Limite de Crédito)
            Revitalição processo limite de crédito, anteriormente iniciariam o processo com um campo Matriz, após analise
            não passou a utilizar este campo utilizando o campo XTPPED para o processo
@Obs   
/*/

User Function CRMA980()
   Local _cEmp    := FWCodEmp()
   Local _lRet	  := .T.
   Local _aArea	  := GetArea()

   If _cEmp == "2010" //Executa o p.e. Anapolis.
      _lRet := zMontadora(_cEmp)
   Else
      _lRet := zCaoaSp(_cEmp) //Executa o p.e. CaoaSp
   EndIf
   RestArea(_aArea)
Return(_lRet)

/*
==============================================================================================
Programa.:              zMontadora
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada Montadora
===============================================================================================
*/
Static Function zMontadora(_cEmp)
Local _aParam    := PARAMIXB
Local _lRet     := .T.
Local _oObj      := ""
Local _cIdPonto  := ""
Local _cIdModel  := ""
Local _nOpcx
Local _cCodCli
Local _cLoja
Local _cTpCred

    If _aParam == NIL
        Return(_lRet)
    EndIf

    //If (aParam <> NIL)
    _oObj        := _aParam[1]
    _cIdPonto    := _aParam[2]
    _cIdModel    := _aParam[3]

    _nOpcx      := _oObj:GetOperation() // PEGA A OPERAÇÃO
    _cCodCli	:= If(Type("M->A1_COD") 	== "C",M->A1_COD	,SA1->A1_COD)
    _cLoja		:= If(Type("M->A1_LOJA") 	== "C",M->A1_LOJA	,SA1->A1_LOJA)
    _cTpCred    := If(Type("M->A1_LOJA") 	== "C",M->A1_XTPCRED	,SA1->A1_XTPCRED)
    If (_cIdPonto =="MODELCOMMITNTTS")
        If _nOpcx == 3 .or. _nOpcx == 4 .or. nOpcx == 5   //Inclusão ou Alteração ou Excluir
           //U_ZF10GENSAP("SA1",SA1->A1_COD+SA1->A1_LOJA,"A1_XCDSAP", _nOpc)
           U_ZF10GENSAP("SA1", _cCodCli+_cLoja, "A1_XCDSAP", _nOpcx)    //gravar tabela SZ7 para envio SAP
        EndIf
        //quando exclusão zero a loja para atualizar todos  DAC 03/04/2023
        If _nOpcx == 5
            _cLoja := ""
        EndIf
        MsgRun("Atualizando Limite de Crédito Caoa","Aguarde...",{|| U_ZFATF014(_cCodCli, _cTpCred, _cLoja, .T.) })
    EndIf
Return(_lRet)


/*
==============================================================================================
Programa.:              zCaoaSp
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada CaoaSp
===============================================================================================
*/
Static Function zCaoaSp(_cEmp)
Local _aParam    := PARAMIXB
Local _lRet      := .T.
Local _oObj      := ""
Local _cIdPonto  := ""
Local _cIdModel  := ""
Local _nOpcx 
Local _cCodCli
Local _cLoja
Local _cTpCred
    
    If _aParam == NIL
        Return(_lRet)
    EndIf

    _oObj           := _aParam[1]
    _cIdPonto       := _aParam[2]
    _cIdModel       := _aParam[3]

    _nOpcx          := _oObj:GetOperation() // PEGA A OPERAÇÃO
    _cCodCli	    := If(Type("M->A1_COD") 	== "C",M->A1_COD	,SA1->A1_COD)
    _cLoja		    := If(Type("M->A1_LOJA") 	== "C",M->A1_LOJA	,SA1->A1_LOJA)
    _cTpCred    := If(Type("M->A1_LOJA") 	== "C",M->A1_XTPCRED	,SA1->A1_XTPCRED)

    Private nOpcx   := _nOpcx   //necessário pois a funcionalidade ZWSR005 espera como private  DAC 03/04/2023  

    If (_cIdPonto =="MODELCOMMITNTTS")
        //IF FWCodEmp() = '2020' .AND. FWFilial() = '2001'
        If _nOpcx == 3 .or. _nOpcx == 4 //.or. _nOpcx == 5 //Inclusão ou Alteração ou Excluir
			U_ZWSR006("C", _cCodCli , _cLoja )
            U_ZF10GENSAP("SA1", _cCodCli+_cLoja, "A1_XCDSAP", _nOpcx)
        EndIf
        //quando exclusão zero a loja para atualizar todos  DAC 03/04/2023
        If _nOpcx == 5
            _cLoja := ""
        EndIf
        MsgRun("Atualizando Limite de Crédito Caoa","Aguarde...",{|| U_ZFATF014(_cCodCli, _cTpCred, _cLoja, .T.) })
    //ElseIf  _cIdPonto == 'MODELPOS'
    //ElseIf (_cIdPonto =="MODELCOMMITNTTS")
    EndIf
Return(_lRet)
