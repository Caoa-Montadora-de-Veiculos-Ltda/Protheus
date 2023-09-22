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
        RecLock('ZZN', .T.)
        ZZN_FILIAL := xFILIAL("ZZN")
        ZZN_COD    := SB1->B1_COD
        ZZN_DESCR  := SB1->B1_DESC
        ZZN_DATA   := DATE()
        ZZN_HORA   := TIME()
        ZZN_INIC   := "*"
        ZZN_FINAL  := "*"
        ZZN_USUR   := __cUserID + " - " + cUserName
        ZZN_CAMPO  := "TODOS CAMPOS"
        ZZN_MOVTO  := "INCLUSAO/COPIA MANUAL DE PRODUTO"
        ZZN->(MsUnlock())
    ENDIF
  
Return .t.
