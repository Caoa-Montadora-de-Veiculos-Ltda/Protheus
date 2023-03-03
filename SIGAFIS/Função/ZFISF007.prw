#include 'totvs.ch'
/*/{Protheus.doc} ZFISF007 
@param  	C6_PRODUTO   S. 012
@author 	Arlindo Alves de Freitas Sobrinho
@version  	P12.1.23
@since  	13/01/2022
@return  	NIL
@obs         
@project
@history   	Gatilho para código de Operação Pedido de Venda  
/*/
User Function ZFISF007()
Local cRet:="T8"

If SB1->B1_PICMRET >0
	If SA1->A1_EST = "SP" .or. SA1->A1_EST = "MG"
		If POSICIONE('SYD',1,xFILIAL('SYD')+SB1->B1_POSIPI,'YD_XUFPROT')=="1"
			cRet:="T8"
		Else
			cRet:="T3"
		EndIf
	Else
		cRet:="T8"
	EndIf
Else
	cRet:="T8"
EndIf

Return(cRet)
