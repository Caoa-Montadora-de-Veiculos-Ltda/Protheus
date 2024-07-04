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
     
    If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
        _lRet := .T.
    ElseIf ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
         If lAutoma261 == .F. //executa somente quando não é execauto.
   		    _lRet := U_ZESTF010()
        Else
            _lRet     := .T.
        EndIf
   EndIf
     	
    RestArea(_aArea)

Return(_lRet)
