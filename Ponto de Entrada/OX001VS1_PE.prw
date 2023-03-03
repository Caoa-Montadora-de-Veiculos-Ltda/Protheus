#INCLUDE "PROTHEUS.CH"

#define CRLF chr(13) + chr(10)
 
/*/{Protheus.doc} OX001VS1 Ponto de Entrada após gravação do VS1 
@param  	
@author 	DAC - Denilso
@version P12.1.23
@since  	30/05/22
@return 	Lógico
@obs     Grava no VS1 dados referente aos campos  VS1_XDESMB
         Verifica registros deletados no acols   
@project CAOA BARUERI
@history DAC - 27/05/2022
               Implementado gravação do campo VS1_XDESMB pois no caso de inclusão manual não gravara este campo 
               o mesmo somente é gravado na importação da Autoware
               Implementado verificação de acols para deleção quando alteração gravar no VS1_OBSAGL         
/*/

User Function OX001VS1()
Local _lRet 		:= .T.

Begin Sequence

   //Atualizar VS1 para campo somente se for inclusão 
   If INCLUI
      XOX001VS1AT()
   //Caso seja alteração verificar os itens deletados no acols   
   ElseIf ALTERA
      XOX001VS3EX()
   EndIf
End Sequence
Return _lRet

//Atualizar campos VS1 e VS3
Static Function XOX001VS1AT()  
Local _lRet 		:= .T.
Begin Sequence	
   If Empty(VS1->VS1_XDESMB)
      If !VS1->(RecLock("VS1",.f.))
   		_lRet := .F.
   		Break
   	EndIf
      VS1->VS1_XDESMB := VS1->VS1_NUMORC
      VS1->(MsUnlock())
   EndIf   
End Sequence
Return _lRet


//Verificar se foi excluído algum item  no acols
Static Function XOX001VS3EX()
Local _lAchou     := .F.
Local _nPos
Local _lDeleted
Local _nReg
Local _cObs
Local _cCodProd
Local _nQtde
Local _cSequen
Local _cUsuario

Begin Sequence
   _cObs       := "*** ITEM ORÇAMENTO APAGADO ***"+CRLF
	for _nPos := 1 to Len(oGetPecas:aCols)
		_lDeleted   := oGetPecas:aCols[_nPos,len(oGetPecas:aCols[_nPos])]
      _nReg       := oGetPecas:aCols[_nPos,len(oGetPecas:aCols[_nPos])-1]
      If _lDeleted .and. _nReg > 0
         _cCodProd   := AllTrim(oGetPecas:aCols[_nPos,FG_POSVAR("VS3_CODITE","aHeaderP")]) 
         _nQtde      := oGetPecas:aCols[_nPos,FG_POSVAR("VS3_QTDITE","aHeaderP")] 
         _cSequen    := oGetPecas:aCols[_nPos,FG_POSVAR("VS3_SEQUEN","aHeaderP")] 
         _cUsuario   := Upper(AllTrim(Upper(FwGetUserName(RetCodUsr())))) 
         _lAchou     := .T.
         _cObs       += "Registro "+StrZero(_nReg,7)+" excluído dos itens, Produto, "+_cCodProd+" Quantidade "+;
                        AllTrim(Str(_nQtde))+" sequencia "+_cSequen+", pelo Usuário "+_cUsuario+" em "+;
                        DtoC(Date())+" as "+SubsTr(Time(),1,5) 
         _cObs       += CRLF               
      Endif
   Next
   If !_lAchou
      Break
   EndIf
   //GRAVAR NA OBSERVAÇÃO AGLUTINAÇÃO VS1
   If !VS1->(RecLock("VS1",.f.))
  		_lRet := .F.
  		Break
  	EndIf
   VS1->VS1_OBSAGL   := Upper(_cObs)+CRLF+VS1->VS1_OBSAGL
   VS1->(MsUnlock())
End Sequence
Return Nil
