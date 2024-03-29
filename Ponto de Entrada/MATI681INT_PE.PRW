#Include "Protheus.ch"
/*---------------------------------------------------------------------------------------
{Protheus.doc} ZPCPF009
Rdmake 	PE na integra��o de XML de apontamento
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC - Denilso 
@single		15/07/2020
@version    Nao Informado
@since      Nao Informado  
@return    	aRet
@sample     Nao Informado
@obs        
@project    CAOA Montadora de Veiculos - GAP TOTVS-MES
@menu       Nao Informado
@history    DAC Denilso - 15/07/2020 
			Realizar valida��o para permitir ou n�o a importa��o do XML MES

/*/

User Function MATI681INT()
Local _aRet	:= {}
Begin Sequence
    //Private oXML      := ParamIXB 
    ConOut("MATI681INT")
	If FindFunction("U_ZPCPF009")
		ConOut("MATI681INT - U_ZPCPF009 - "+DTOC(Date()) + " - " + Time())
		_aRet := U_ZPCPF009()
	Else
		ConOut("MATI681INT - SEM U_ZPCPF009")
	    aAdd(_aRet, .T.) // Ir� executar a rotina padr�o
	    aAdd(_aRet, .T.) // XML importado com sucesso
	    aAdd(_aRet, " ") // Como n�o houve erro, o terceiro par�metro deve estar em branco.
	Endif		
End Sequence
Return _aRet
