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
@history    Ponto de entrada ap�s inclus�o do produto 
*/
User Function MT010INC()
Local aArea := GetArea()
    //Grava o usu�rio que alterou
    RecLock('SB1', .F.)
        B1_XDTULT := DATE()
        B1_XHRULT := TIME()
    SB1->(MsUnlock())
     
    RestArea(aArea)
Return
