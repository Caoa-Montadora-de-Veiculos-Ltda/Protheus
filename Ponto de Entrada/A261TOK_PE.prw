#Include "Protheus.ch"

/*/{Protheus.doc} A261TOK_PE
@author 	Evandro Mariano
@version  	P12.1.23
@since  	14/07/2023
@return  	NIL
@obs        Ponto de entrada do MATA261
@project
@history    
*/ 
 
User Function A261TOK()

    Local _lRet     := .F.
    Local _aArea    := GetArea()
     
    If _cEmp == "2010" //Executa o p.e. Anapolis.
        _lRet := .T.
    Else
   		_lRet := U_ZESTF010()
   EndIf
     	
    RestArea(_aArea)

Return(_lRet)
