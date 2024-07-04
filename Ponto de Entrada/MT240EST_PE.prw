#Include "Protheus.ch"

/*/{Protheus.doc} MT240EST_PE
@author 	Evandro Mariano
@version  	P12.1.23
@since  	14/07/2023
@return  	NIL
@obs        Ponto de entrada do MATA241 localizado apos a confirmação do estorno.
@project
@history    
*/ 
 
User Function MT240EST()

    Local _lRet     := .F.
    Local _aArea    := GetArea()
    Local lUserAut  := .F.
     
    If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
        _lRet := .T.
    Else
        lUserAut := U_ZGENUSER( RetCodUsr() ,"MT240EST",.F.)
        If lUserAut 
    		_lRet := .T.
        else
            _lRet := .F.
            ApMsgAlert( "Usuário não autorizado a estornar movimentação multipla.","Aviso... [ MT240EST ] " )
        EndIf
   EndIf
     	
    RestArea(_aArea)

Return(_lRet)
