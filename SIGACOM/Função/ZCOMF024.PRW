#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} ZCOMF024
@param  	
@author   	Antonio Oliveira
@version  	P12.1.23
@since  	   28/04/2020
@return  	NIL
@obs        Salvar dados complementares em PC e Autorização de Entrega
@project
@history    Chamado pelo PE MT120GOK_PE
/*/
//Verificar se passa por item 
User Function ZCOMF024(cPedido,lInclui)
Local _lRet	 := .T.

/*IF !Empty(SC7->C7_NUMCOT)
    SC8->(DBSetOrder(1))
    IF DBSeek(xFilial("SC8")+SC7->C7_NUMCOT)
        SC7->(RecLock("SC7",.F.))
        SC7->C7_XOBSCOT := SC8->C8_XOBSCTO
        SC7->(MSUnlock())
	ENDIF  
ENDIF*/

IF lInclui

	IF IsInCallStack("MATA121")   
			
		SC7->(RecLock("SC7",.F.))
		SC7->C7_XOBSREQ := SC1->C1_NUM + " " + SC1->C1_XOBSREQ
		SC7->C7_XOBSITE := SC1->C1_XOBSITE
		SC7->(MSUnlock())  

	ELSEIF IsInCallStack("MATA122") 	  

		SC7->(RecLock("SC7",.F.))
		SC7->C7_XOBSREQ := SC3->C3_XOBSREQ
		SC7->C7_XOBSITE := SC3->C3_XOBSITE
	    SC7->C7_XOBSCOT := SC3->C3_XOBSCOP
	 	SC7->(MSUnlock()) 
      
	ENDIF

ENDIF
    
Return _lRet 
