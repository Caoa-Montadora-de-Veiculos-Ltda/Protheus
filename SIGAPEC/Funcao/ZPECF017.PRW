#include "Protheus.ch"
#include "totvs.ch"
#include "parmtype.ch"
#include "fwmvcdef.ch"
#INCLUDE "RESTFUL.CH"
/*/{Protheus.doc} ZPECF017
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	20/04/2022
@return  	NIL
@obs        Ponto de entrada 
@project
@history    Uso da fun��o MATESINT p/ replicar a opera��o e TES aos registros do or�amento
*/
User Function ZPECF017()
Local _cTes         := Space(TamSx3("F4_CODIGO")[1])
Local _cTipoOper    := AllTrim(GetMV("CMV_WSR006"))  		//Tipo opera��o
Local _nPosCodPro   := Ascan(aHeader,{|x| Alltrim(x[2]) == 'VS3_CODITE'})
Local _lRet         := .T.
Local _cTipo        := 2
Local i             := 1

If !ALTERA  .or. Len(oGetPecas:ACOLS) <= 1   
    Return _lRet
EndIf

_cTipoOper := M->VS3_OPER

IF MSGYESNO("Deseja replicar a opera��o para todos os itens ? ","Aten��o!!!")

    For i := 1 to Len(oGetPecas:ACOLS)

        oGetPecas:nAt := i
        n := oGetPecas:nAt
        //A TES muda de acordo com o c�digo do produto DAC 25/04/2022
        _cTes := MaTesInt(_cTipo,_cTipoOper,VS1->VS1_CLIFAT,VS1->VS1_LOJA,"C",Alltrim(oGetPecas:ACOLS[i][_nPosCodPro]),)

        __READVAR	:= "VS3_OPER"
        &("M->"+__READVAR)	:= _cTipoOper
        oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_OPER","aHeaderP")] := _cTipoOper

        __READVAR	:= "VS3_CODTES"
        &("M->"+__READVAR)	:= _cTes
        oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODTES","aHeaderP")] := _cTes

        //--Fun��o padr�o do SIGAPEC para valida��o das altera��es na grid
        OX001FPOK(,,.f.,.f.)

    Next  

ELSE

    _cTes := MaTesInt(_cTipo,_cTipoOper,VS1->VS1_CLIFAT,VS1->VS1_LOJA,"C",Alltrim(oGetPecas:ACOLS[n][_nPosCodPro]),)
    
    __READVAR	:= "VS3_OPER"
    &("M->"+__READVAR)	:= _cTipoOper
    oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_OPER","aHeaderP")] := _cTipoOper

    __READVAR	:= "VS3_CODTES"
    &("M->"+__READVAR)	:= _cTes
    oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VS3_CODTES","aHeaderP")] := _cTes

    //--Fun��o padr�o do SIGAPEC para valida��o das altera��es na grid
    OX001FPOK(,,.f.,.f.)

ENDIF

oGetPecas:oBrowse:refresh()

Return(_lRet)


