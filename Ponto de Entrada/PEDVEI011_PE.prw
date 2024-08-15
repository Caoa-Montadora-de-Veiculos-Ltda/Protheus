#include "totvs.ch"

/*/{Protheus.doc} PEDVEI011
@param  	
@author 	Evandro Mariano
@version  	P12.1.23
@since  	29/08/2022
@return  	NIL
@obs        Ponto de entrada PEDVEI011 chamado pelo Faturamento do SIGAVEI
@project
@history    Gravar dados na SC5 e SC6
*/

User Function PEDVEI011()
  
	Local nPosTES
 
	//alert("PEDVEI011")
	Conout("PEDVEI011")
	Conout("PEDVEI011 - C6_XBASST " + cValToChar(VVA->VVA_XBASST))
	
	aAdd(aCabPV,  {"C5_XMENSER" ,E_MSMM(VV0->VV0_OBSMNF)   ,Nil}) 
	aAdd(aCabPV,  {"C5_CLIREM"  , VV0->VV0_CLIRET 		   ,Nil}) 
	aAdd(aCabPV,  {"C5_LOJAREM" , VV0->VV0_LOJRET 		   ,Nil}) 
	aAdd(aCabPV,  {"C5_TIPOCLI" , VRJ->VRJ_TIPOCL 		   ,Nil}) // Adicionado Por Cintia Araujo - 08/2024 para trazer informação do Pedido Montadora e considerar a Exceçao Fiscal conforme Tipo de Pedido

	AADD(aIteTPv, {"C6_NUMSERI" , VVA->VVA_CHASSI          ,NIL})
	AADD(aIteTPv, {"C6_XBASST"  , VVA->VVA_XBASST          ,NIL})
	AADD(aIteTPv, {"C6_QTDLIB"  , 1                        ,NIL}) // Para correca de Erro do Padrao Protheus
	AADD(aIteTPv, {"C6_XBASPI"  , VVA->VVA_XBASPI          ,NIL})
	AADD(aIteTPv, {"C6_XBASCO"  , VVA->VVA_XBASCO          ,NIL})
	AADD(aIteTPv, {"C6_XBASIP"  , VVA->VVA_XBASIP          ,NIL})
	If ! Empty(VVA->VVA_VRKNUM)
		VRK->(dbSetOrder(1))
		If VRK->(dbSeek(xFilial("VRK") + Left(VVA->VVA_VRKNUM, TamSX3("VRK_PEDIDO")[1]) + VVA->VVA_VRKITE))


			AADD(aIteTPv, {"C6_XPECOM"  , VRK->VRK_XPECOM ,NIL})
			AADD(aIteTPv, {"C6_XVLCOM"  , VRK->VRK_XVLCOM ,NIL})

			nPosTES := aScan( aIteTPv , { |x| x[1] == "C6_TES"})
			AADD( aIteTPv , { NIL, NIL, NIL} ) 
			AIns( aIteTPv , nPosTES)
			aIteTPv[nPosTES] := {"C6_OPER" , VRK->VRK_OPER, NIL}
		endif
	endif
	
Return

