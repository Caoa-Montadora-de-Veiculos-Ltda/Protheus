#Include "Protheus.Ch"
#Include "TopConn.Ch"
/*/{Protheus.doc} MT103OK_PE    (MATA122 - AE Chamando a Trilha de segurança)
@param  	
@author 	Nicolas Lima
@version  	P12.1.2210
@since  	13/10/2020
@return  	NIL
@obs        Ponto de entrada do MATA103OK - Altera o resultado da validação padrão para inclusão
            alteração de registros de entrada, por customizações do cliente
@project
@history    Salvar dados adicionais em PC

*/
User function MTA103OK() 
    Local _lRet := .F.     //Customizações do usuário.
    Local _cEmp    := FWCodEmp()
    
    //Início dos ajustes referentes ao GAP009
    If _cEmp == "2020" .and. FindFunction("U_zPedComp()")//Empresa Barueri
		_lret := U_zPedComp()
    EndIf
    //Fim dos ajustes referentes ao GAP009

Return (_lRet)

