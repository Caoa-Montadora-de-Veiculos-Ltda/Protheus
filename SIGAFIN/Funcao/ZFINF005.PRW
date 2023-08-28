#include "Protheus.ch"
#include 'parmtype.ch'
#include 'TOPCONN.CH'
#include "TBICONN.CH"
/*/{Protheus.doc} ZFINF005
Função para validar o valor das parcelas com o total do título de RA 

@type       Function
@author     CAOA - A.Carlos
@since 		04/07/2023
@version 	1.0
/*/
User Function ZFINF005()
Local _lRet   := .T.
Local _aArea  := GetArea()
Local _cEmp   := FWCodEmp()
Local _nTtlC5 := 0
Local _nTtlC6 := 0

IF _cEmp == "2010" 
    IF SC5->C5_XPREFIX = 'PVF'
	    _nTtlC5 := SC5->C5_PARC1 + SC5->C5_PARC2 
        SC6->(DbSetOrder(1))
	    If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))	
			While !SC6->(Eof()) .AND. SC6->C6_NUM = SC5->C5_NUM     
                _nTtlC6 := _nTtlC6 + SC6->C6_VALOR
			    SC6->(dbskip())
            End
		    
            IF _nTtlC5 >= _nTtlC6
                _lRet := .F.
			ENDIF 
        EndIf
	ENDIF
ENDIF
		
RestArea(_aArea)

return(_lRet) 
