#Include 'Protheus.ch'
#Include 'TopConn.ch'
#include "rwmake.ch"
#include "TOTVS.ch"
/*/{Protheus.doc} ZPECF013
@param  	
@author 	CAOA - A.Carlos
@version  	P12.1.23
@since  	06/05/2022
@return  	NIL
@obs         
@project
@history    Alterar a query da analise de crédito.   
/*/	
User Function VFATECLI()

If FindFunction("U_ZPECF019")

    U_ZPECF019()

EndIf

Return()
