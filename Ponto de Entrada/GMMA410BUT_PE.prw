/*/{Protheus.doc} GMMA410BUT 
@param  	
@author 	
@version  	P12.1.23
@since  	
@return  	NIL
@obs
@project
@history    Ponto de entrada no menu do Pedido de Vendas para incluir bot�o
/*/
User Function GMMA410BUT_PE()
Local nOpcao := PARAMIXB[1]  //3-Inclus�o
Public aRet  := {}

IF nOpcao = 3
   aRet := U_ZFATF002()
ENDIF

Return(aRet)


