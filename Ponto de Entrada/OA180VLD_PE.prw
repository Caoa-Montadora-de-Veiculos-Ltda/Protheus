#Include "Protheus.ch"

/*/{Protheus.doc} OA180VLD_PE
@author 	Evandro Mariano
@version  	P12.1.23
@since  	14/07/2023
@return  	NIL
@obs        Ponto de entrada do OFIOA180
@project
@history    
*/ 
 
User Function OA180VLD()

    Local _lRet     := .F.
    Local _aArea    := GetArea()
    Local lUserAut  := .F.
    Local _cEmp     := FWCodEmp()
     
    If _cEmp == "2010" //Executa o p.e. Anapolis.
        _lRet := .T.
    Else
        lUserAut := U_ZGENUSER( RetCodUsr() ,"OA180VLD",.F.)
        If lUserAut 
    		_lRet := .T.
        else
            _lRet := .F.
            ApMsgAlert( "Usuário não autorizado para Incluir/Alterar a Equipe Tecnica.","Aviso... [ OA180VLD ]" )
        EndIf
   EndIf
     	
    RestArea(_aArea)

Return(_lRet)
