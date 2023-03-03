#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT110GET
P.E. - Manipulação do cabeçalho da Solicitação de Compras
@author
@since 		08/08/2019
@version 	1.0
@type 		User function
@Obs		20/08/2020 DAC - Denilso -> Alterado devido acrescentar dados do historico da cotação
/*/
user function MT110GET()
Local aPosObj		:= ParamIxb[1]
//Local nOpc			:= ParamIxb[2]
aPosObj[2][1]	+=	70 //Aumento o Espaçamento
aPosObj[1][3]	+=	70 //Aumento o Box
return aPosObj
