#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} MT160GRPC 
@param  	 
@author 	A. Oliveira
@version  	P12.1.25
@since  	25/02/2021
@return  	NIL
@obs        Ponto de Entrada para gravar o item da cotação no pedido de compras
@project
@history
/*/
User Function MT160GRPC()

    RecLock("SC7", .F.)
    SC7->C7_XITEMCO := SC8->C8_ITEM
    MsUnLock()

Return
