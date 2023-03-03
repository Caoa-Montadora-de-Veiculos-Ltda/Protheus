#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT120GET
P.E. - Manipulação do cabeçalho do Pedido de Compras
@author     A. Carlos
@since 		21/10/2020
@version 	1.0
@type 		User function
@Obs		Alterado devido acrescentar dados do historico da cotação
/*/
user function MT120GET()
Local aPosObj		:= ParamIxb[1]
//Local nOpc			:= ParamIxb[2]
aPosObj[2][1]	+=	70 //Aumento o Espaçamento
aPosObj[1][3]	+=	70 //Aumento o Box
return aPosObj
