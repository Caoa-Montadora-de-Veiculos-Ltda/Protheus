#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#include "rwmake.ch"
/*/{Protheus.doc} ZCOMF031
@author     A.Carlos
@since 		21/10/2020
@param     	 
@return    	Logico
@project    CAOA
@version 	1.0
@obs        Chamado pelo PE MTA150GRV salvar campo na cotação
@history    
/*/
User Function ZCOMF031()
Local aArea := GetArea()

    SC8->C8_XOBSCTO := UPPER(cC8_SCOT)
     
    RestArea( aArea )
     
Return
