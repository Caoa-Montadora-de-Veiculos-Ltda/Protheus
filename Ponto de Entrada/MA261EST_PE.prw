#Include "Protheus.ch"

/*/{Protheus.doc} MA261EST_PE
@author 	Evandro Mariano
@version  	P12.1.23
@since  	14/07/2023
@return  	NIL
@obs        Ponto de entrada do MATA241 localizado apos a confirmação do estorno.
@project
@history    
*/ 
 
User Function MA261EST()

    Local _lRet     := .F.
    Local _aArea    := GetArea()
    Local lUserAut  := .F.
         
    If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
        _lRet := .T.
    ElseIf ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
        lUserAut := U_ZGENUSER( RetCodUsr() ,"MA261EST",.F.)
        If lUserAut 
    		_lRet := .T.
        Else
            _lRet := .F.
            ApMsgAlert( "Usuário não autorizado a estornar transferencia multipla.","Aviso... [ MT261EST ] " )
        EndIf
   EndIf
     	
    RestArea(_aArea)

Return(_lRet)
