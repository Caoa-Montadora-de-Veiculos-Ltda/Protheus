#Include "Protheus.ch"

/*/{Protheus.doc} MT120OK_PE
@author 	Evandro Mariano
@version  	P12.1.23
@since  	14/07/2023
@return  	NIL
@obs        Ponto de entrada do MATA241 localizado apos a confirmação da inclusao
@project
@history    
*/ 
 
User Function MT241TOK()

    Local _lRet     := .F.
    Local _aArea    := GetArea()
    Local lUserAut  := .F.
     
    If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
        _lRet := .T.
    Else
        lUserAut := U_ZGENUSER( RetCodUsr() ,"MT241TOK",.F.)
        If lUserAut 
    		_lRet := .T.
        else
            _lRet := .F.
            ApMsgAlert( "Usuário não autorizado para realizar movimentação multipla.","Aviso... [ MT241TOK ]" )
        EndIf
   EndIf
     	
    RestArea(_aArea)

Return(_lRet)
