#include "protheus.ch"
#include "parmtype.ch"
#include 'Fwmvcdef.CH'
/*/{Protheus.doc} MT010INC_PE
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	13/10/2020
@return  	NIL
@obs        Ponto de entrada do MATA110
@project
@history    Ponto de entrada após inclusão do produto 
*/ 
User Function MT010INC()
//Local aArea := GetArea()
    //Grava o usuário que incluiu
    IF FWCodEmp() <> "2010" 
       RecLock('SB1', .F.)
       SB1->B1_MSBLQL := "1"
       SB1->(MsUnlock())
    Endif
    RecLock('SB1', .F.)
        B1_XDTULT := DATE()
        B1_XHRULT := TIME()
    SB1->(MsUnlock())
    //Atualiza a tabela de log de alteração/inclusão de produtos
    IF FWCodEmp() <> "2010"
        RecLock('ZZ4', .T.)
        ZZ4_FILIAL := xFILIAL("ZZ4")
        ZZ4_COD    := SB1->B1_COD
        ZZ4_DESCR  := SB1->B1_DESC
        ZZ4_DATA   := DATE()
        ZZ4_HORA   := TIME()
        ZZ4_INIC   := "*"
        ZZ4_FINAL  := "*"
        ZZ4_USUR   := __cUserID + " - " + cUserName
        ZZ4_CAMPO  := "TODOS CAMPOS"
        IF FWIsInCallStack("FIMPEXCEL")
           ZZ4_MOVTO  := "CARGA EM MASSA DE PRODUTO"
        ELSE
           ZZ4_MOVTO  := "INCLUSAO/COPIA MANUAL DE PRODUTO"
        ENDIF
        ZZ4->(MsUnlock())
    ENDIF
  
Return .t.
