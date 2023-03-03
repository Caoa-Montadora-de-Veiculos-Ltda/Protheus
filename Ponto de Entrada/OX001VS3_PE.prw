#INCLUDE "PROTHEUS.CH"
 
/*/{Protheus.doc} OX001VS3 Ponto de Entrada ap�s grava��o do VS3
@param  	
@author 	Sandro Ferreira
@version P12.1.23
@since  	15/10/21
@return 	L�gico
@obs     Ponto de Entrada OX001VS3 � para alterar o status da variavel lBo
         Grava no VS3 dados referente aos campos  VS3_XITSUB   
@project CAOA BARUERI
@history DAC - 27/05/2022
               Implementado grava��o do campo VS3_XITSUB pois no caso de inclus�o manual n�o gravara este campo 
               o mesmo somente � gravado na importa��o da Autoware         
/*/

User Function OX001VS3()
Local _lRet 		:= .T.
Begin Sequence

   //Feito anteriormente pelo Sandro necess�rio analisar impactos neste momento ja gravou VS3 DAC 30/05/2022
   If lBo
      lBo := .F.
   Endif
   //Atualizar VS3 para campo somente se for inclus�o
   If INCLUI .OR. ALTERA
      XOX001VS3AT()
   EndIf
End Sequence
Return _lRet


//Atualizar campos VS3 ja esta posicionado
Static Function XOX001VS3AT()  
Local _lRet 		:= .T.
Begin Sequence	
   If Empty(VS3->VS3_XITSUB)
      If !VS3->(RecLock("VS3",.f.))
	      _lRet := .F.
	      Break
      EndIf
      VS3->VS3_XITSUB := VS3->VS3_CODITE 
      VS3->(MsUnlock())
   EndIf      
End Sequence
Return _lRet


