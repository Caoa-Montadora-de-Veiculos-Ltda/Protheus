#include "Protheus.ch"
#include 'parmtype.ch'
#include 'TOPCONN.CH'
#include "TBICONN.CH"
/*/{Protheus.doc} ZFINF004
Função para gravar a forma de pagamento no título de RA usada para integração com o SAP.
@type       Function chamada pelo PE F040GRV
@author     CAOA - A.Carlos
@since 		04/07/2023
@version 	1.0
/*/
User Function ZFINF004()
Local _lRet  := .T.
Local _aArea := GetArea()
Local _cEmp  := FWCodEmp()

IF _cEmp == "2010" .AND. SE1->E1_TIPO = 'RA ' .AND. SE1->E1_PARCELA = '1 ' 

	SE4->(DbSetOrder(1))
	If SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
        GrvDBSe1()
	Endif

ELSEIF _cEmp == "2010" .AND. SE1->E1_TIPO = 'RA ' .AND. SE1->E1_PARCELA = '2 ' .AND. !Empty(SC5->C5_XNPG)

	SE4->(DbSetOrder(1))
	If SE4->(DbSeek(xFilial("SE4")+SC5->C5_XNPG))
        GrvDBSe1()
	Endif

ELSEIF _cEmp == "2010" .AND. SE1->E1_TIPO = 'RA ' .AND. SE1->E1_PARCELA = '3 ' .AND. !Empty(SC5->C5_XNPG1)

	SE4->(DbSetOrder(1))
	If SE4->(DbSeek(xFilial("SE4")+SC5->C5_XNPG1))
        GrvDBSe1()
	Endif

ENDIF

RestArea(_aArea)

return(_lRet) 


/*/{Protheus.doc} ZFINF004
	Função para gravar a forma de pagamento no título de RA usada para integração com o SAP.
    @type       Function
    @author     CAOA - A.Carlos
    @since 		04/07/2023
    @version 	1.0
/*/
Static Function GrvDBSe1()
	RecLock("SE1",.F.)
	SE1->E1_XFORMA  := SE4->E4_XFORMA
	SE1->E1_PORTADO := SA6->A6_COD 
	SE1->E1_AGEDEP  := SA6->A6_AGENCIA
	SE1->E1_CONTA   := SA6->A6_NUMCON
	MsUnlock()
Return()
