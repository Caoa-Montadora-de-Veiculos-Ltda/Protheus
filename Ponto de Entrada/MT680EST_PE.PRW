#INCLUDE 'PROTHEUS.CH'

/*---------------------------------------------------------------------------------------
{Protheus.doc} MT680EST
Rdmake 	Ponto de Entrada após estorno de op, para geracao de VV1 E exclusao de apontamento CPS                                 |
@class    	Nao Informado
@from       Nao Informado
@param      
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC Denilso 
@single		19/06/2020
@version    Nao Informado
@since      Nao Informado  
@return    	Logico
@sample     Nao Informado
@obs        
@project    CAOA - Automatizar o processo de apontamento
@menu       Nao Informado
@history    

/*/

User Function MT680EST
Local _aArea := GetArea()
Local _lRet  := .T.
Begin Sequence
	//Ponto de Entrada com chamas de funções não executar as mesmas no PE para possibilitar novas influsões sem maiores danos
	If _lRet .and. FindFunction("U_ZPCPF008")
		_lRet := U_ZPCPF008()   //Realizar o estorno dos saldos movimentações e excluzão de Veiculo ref. importação MES
	Endif
	
End Sequence
RestArea(_aArea)

Return _lRet

