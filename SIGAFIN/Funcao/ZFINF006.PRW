#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'parmtype.ch'
/*/{Protheus.doc} U_ZFINF006
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	20/12/23
@return  	
@obs       
@project 
@history    grava o E1_NUMBCO para o título de RA e não o da Parela1 quando PVF (efeito SAP)
/*/
User Function ZFINF006()
Local   _aArea   := GetArea()
Local   _cNum    := " "
Local   _cNumbco := " "
Local   _cPedido := SPACE(TamSX3("E1_NUM")[1])  

IF SE4->E4_CTRADT <> '1' 

    _cNum    := SE1->E1_NUM
    _cNumbco := SE1->E1_NUMBCO
    _cPedido := PADR(SE1->E1_PEDIDO,09) 

    If SE1->(RecLock("SE1",.F.))
        SE1->E1_NUMBCO := ' '
        SE1->(MsUnLock())			
    EndIf

    SE1->(DbSetOrder(1)) //Filial + Prefixo + Num + Parcela + Tipo
    SE1->(DbGotop())

    If SE1->(dbSeek(xFilial("SE1")+'PVF'+_cPedido+'1 '+'RA '))
                                                                                                                    
        If SE1->(RecLock("SE1",.F.))
            SE1->E1_TITPAI := _cNum
            SE1->E1_NUMBCO := _cNumbco
            SE1->(MsUnLock())			
        EndIf

        SE1->(dbSkip())	

    Endif

Endif

RestArea(_aArea)
Return(.T.)
