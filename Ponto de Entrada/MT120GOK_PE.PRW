#include "protheus.ch"
#include "parmtype.ch"
#include 'Fwmvcdef.CH'
/*/{Protheus.doc} MT120GOK_PE
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	13/10/2020
@return  	NIL
@obs        Ponto de entrada do MATA120
@project
@history    Salvar dados adicionais em PC
*/
USER Function MT120GOK()
Local cPedido := PARAMIXB[1]
Local lInclui := PARAMIXB[2]

	U_ZCOMF024(cPedido,lInclui)

Return(.T.)
