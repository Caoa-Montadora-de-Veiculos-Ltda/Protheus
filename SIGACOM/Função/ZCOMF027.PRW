#Include "Protheus.Ch"
#Include "TopConn.Ch"
#Include "RwMake.Ch"

/*/{Protheus.doc} ZCOMF027
@author     A.Carlos
@since 		21/10/2020
@param     	 
@return    	Logico
@project    CAOA
@version 	1.0
@obs        Chamado pelo PE MTA125GRV salvar campo no contrato de parceria
@history    
/*/
User Function ZCOMF027()

Local aArea := GetArea()

If IsInCallStack("U_GERCPAR")
    SC3->C3_XOBSCOP := cObsCP
Else
    SC3->C3_XOBSCOP := UPPER(cC3_SCOP)
EndIf

RestArea( aArea )
     
Return
