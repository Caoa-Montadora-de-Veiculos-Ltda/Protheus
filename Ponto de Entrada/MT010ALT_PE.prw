#include "protheus.ch"
#include "parmtype.ch"
#include 'Fwmvcdef.CH'
/*/{Protheus.doc} MT010ALT_PE
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	13/10/2020
@return  	NIL
@obs        Ponto de entrada do MATA110
@project
@history    Ponto de entrada após alteração do produto 
*/
User Function MT010ALT()

    IF FWCodEmp() <> "2010" .AND. cBloqProd
       RecLock('SB1', .F.)
       SB1->B1_MSBLQL := "1"
       SB1->(MsUnlock())
    Endif
   
    RecLock('SB1', .F.)
        B1_XDTULT := DATE()
        B1_XHRULT := TIME()
    SB1->(MsUnlock())
     
 
Return
