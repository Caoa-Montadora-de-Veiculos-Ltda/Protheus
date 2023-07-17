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
    Local _cEmp     := FWCodEmp()
     
    If _cEmp == "2010" //Executa o p.e. Anapolis.
        _lRet := .T.
    Else
        lUserAut := U_ZGENUSER( RetCodUsr() ,"MA261EST_PE",.F.)
        If lUserAut 
    		_lRet := .T.
        Else
            _lRet := .F.
            ApMsgAlert( "Usuário não autorizado a estornar transferencia multipla.","Aviso... [ MT261EST ] " )
        EndIf
   EndIf
     	
    RestArea(_aArea)

Return(_lRet)
