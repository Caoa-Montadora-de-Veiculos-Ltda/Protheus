#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} MT150ROT
P.E. - Adiciona botões no Browse da Cotação.
@author FSW - DWC Consult
@since 21/03/2019
@version 1.0
@type function
/*/
User Function MT150ROT()
	
	aAdd(aRotina, {'Hist. Alterações' ,"U_HISTSC8" , 0 , 2, 0, Nil})
		
Return( aRotina )