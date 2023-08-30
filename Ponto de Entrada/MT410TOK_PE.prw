#Include 'Rwmake.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE cFONT   '<b><font size="3" color="blue"><b>'
#DEFINE cALERT  '<b><font size="3" color="red"><b>'
#DEFINE cNOFONT '</b></font></b></u>'

/*
Validacao dos campos customizados no TudoOk do PEDIDO DE VENDA
@author VALTER CARVALHO
@since 27/01/2020
@version 1.0
@type function
*/

User Function MT410TOK()
    local lRet    := .T.
    /*
		Verifica se CENTO DE CUSTO, ITEM CONTÁBIL CLASSE DE VALOR estão preenchidos, ou há rateio do item
        dentro da tela PEDIDO DE VENDA MATA410
	*/
	If lRet
		//If FindFunction("U_ZCOMF012")
		//	lRet := U_ZCOMF012()
		//Endif
        If FindFunction("U_ZFATF003")
			lRet := U_ZFATF003()
		Endif
		If FindFunction("U_ZFINF004")
			lRet := U_ZFINF004()
		Endif	
	Endif	

	Return lRet   // agg_perc  abkpagg
