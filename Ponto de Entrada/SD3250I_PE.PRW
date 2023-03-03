#INCLUDE 'PROTHEUS.CH'

/*---------------------------------------------------------------------------------------
Rdmake 	Ponto de Entrada após Gravação SD3                                 |
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

User Function SD3250I()
Local _aArea    := GetArea()
Local _lRet		:= .T.
Begin Sequence
	//Ponto de Entrada com chamas de funções não executar as mesmas no PE para possibilitar novas influsões sem maiores danos
	If _lRet .and. FindFunction("U_ZPCPF007")
		ConOut("SD3250I - U_ZPCPF007 - "+DTOC(Date()) + " - " + Time())
		_lRet := U_ZPCPF007()
	Endif
End Sequence
RestArea(_aArea)
Return _lRet

