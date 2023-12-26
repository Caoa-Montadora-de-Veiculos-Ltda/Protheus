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
Local   _cNUM    := " "
Local   _cNUMBCO := " "

_cNUM    := (SE1)->E1_NUM
_cNUMBCO := (SE1)->E1_NUMBCO

(SE1)->(DbSetOrder(1)) //Filial + Prefixo + Num + Parcela + Tipo
(SE1)->(DbGotop())

WHILE SE1->(!Eof())  

    IF SE1->E1_PREFIXO = 'PVF' .AND. SE1->E1_PARCELA = '1 ' .AND. SE1->E1_PEDIDO = _cNUM .AND. SE1->E1_TIPO = 'RA ' 	
        If SE1->(RecLock("SE1",.F.))
            SE1->E1_TITPAI := _cNUM
            SE1->E1_NUMBCO := _cNUMBCO
           SE1->(MsUnLock())			
		    EndIf
        //ELSEIF (SE1)->E1_PREFIXO = '5  ' .AND. (SE1)->E1_PARCELA = '1 ' .AND. (SE1)->E1_NUM = _cNUM		
        //    If SE1->(RecLock("SE1",.F.))
        //	    SE1->E1_NUMBCO := " "
        //        SE1->(MsUnLock())			
        //EndIf	
    EndIf 

    SE1->(dbSkip())	

End

RestArea(_aArea)
Return(.T.)
