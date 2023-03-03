#include "Protheus.ch"
/*/{Protheus.doc} OX011CLONE
@param  	
@author 	DAC
@version  	P12.1.23
@since  	27/04/2022
@return  	NIL
@obs        Ponto de entrada 
@project
@history    Este exemplo serve para um caso onde o Cliente queira barrar a Clonagem de Or�amentos com STATUS diferente de AbertO
*/
User Function OX011CLONE()

IF U_ZGENUSER( RetCodUsr() ,"OX011CLONE",.T.) = .F. 
	   RETURN .F. 
ENDIF

If VS1->VS1_STATUS <> "0"

    MsgInfo("N�o � permitida a clonagem de Or�amentos com Status diferente de Aberto!","Aten��o")

    Return .f.

Endif

Return .t.
