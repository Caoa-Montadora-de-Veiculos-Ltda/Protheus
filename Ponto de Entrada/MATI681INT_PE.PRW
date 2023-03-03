#Include "Protheus.ch"
/*---------------------------------------------------------------------------------------
{Protheus.doc} ZPCPF009
Rdmake 	PE na integração de XML de apontamento
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
			Realizar validação para permitir ou não a importação do XML MES

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
	    aAdd(_aRet, .T.) // Irá executar a rotina padrão
	    aAdd(_aRet, .T.) // XML importado com sucesso
	    aAdd(_aRet, " ") // Como não houve erro, o terceiro parâmetro deve estar em branco.
	Endif		
End Sequence
Return _aRet
