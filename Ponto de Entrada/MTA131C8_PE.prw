#INCLUDE "PROTHEUS.CH"
#Include "Rwmake.ch"
#Include "TopConn.ch"
/*/{Protheus.doc} MTA131C8_PE
//PE p/ adicionar dados a Cotação  
@author A.Carlos
@since 	09/10/2020
@version 1.0
@return 
@obs	
@history    Obs geral da SC1
@type function
/*/
User Function MTA131C8()
Local oModFor := PARAMIXB[1]
Local _lRet   := .T.

	If FindFunction("U_ZCOMF025")
		_lRet := U_ZCOMF025(oModFor, _lRet)
	Endif

Return(_lRet)
