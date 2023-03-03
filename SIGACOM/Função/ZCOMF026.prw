#Include "Protheus.Ch"
#Include "TopConn.Ch"
#Include "TBICONN.Ch"
#Include "rwmake.Ch"
#Include "TOTVS.Ch"
#Include "DbStruct.Ch"
#Include "MSGraphi.Ch"
#Include "Eicsi400.Ch"
#Include "AvPrint.Ch"
#Include "FWBrowse.Ch"
#Include "FWFilter.Ch"
#Include "FWMVCDEF.Ch"

#DEFINE _cEol CHR(13)+CHR(10)  //final de linha
//-------------------------------------------------------------------
/*/{Protheus.doc} ZCOMF026
@author     A.Carlos
@since 		21/10/2020
@param     	_aParam - Com informações paramb do MT125TEL
@return    	Logico
@project    CAOA
@menu       Nao Informado
@version 	1.0
@obs        Chamado pelo Ponto de Entrada MT125TEL
@history    
/*/
//-------------------------------------------------------------------
User Function ZCOMF026(_aParam)

Local _oCourierNw	:= TFont():New("Courier New",,,,.F.,,,,.F.,.F.)
Local _oNewDialog   
Local _aPosGet      
Local _nOpcx        
Local _nSalta 		
Local _nCont  		
Local _nCol  		
Local _nLin
Local _nPos
Local _oMemo := " "
Local _bXTPIMPGWhen 

Begin Sequence
	
	If _aParam == Nil .or. LEN(_aParam) < 4
		Break
	Endif

 	_oNewDialog   := _aParam[1]
	_aPosGet      := _aParam[2]
	_nOpcx        := _aParam[4]
	//_nReg         := _aParam[4]
	_bXTPIMPGWhen := { || _nOpcx == 2  .Or.  _nOpcx == 4 }   //_nOpcx == 3 .Or.

	//PARA EVITAR ERROS NA TELA NECESSARIO
	If Eval( _bXTPIMPGWhen )  //INCLUSAO/ALTERAÇÃO
    	If SC3->(FieldPos("C3_XOBSCOP")) > 0
        	cC3_SCOP := SC3->C3_XOBSCOP  
		Endif
	Endif

	_nCol  := Len(_aPosGet[1])+1  //pega o tamanho definido pelo padrão acrescentar a proxia
	_nCont := 1   				  //Primeira coluna de impressão a linha

	For _nPos := 1 To 8
		//forço quebrar para a primeira linha neste ponto ex xreqemai
		If _nPos >= 7
			_nCont := 1
		EndIf
		Aadd(_aPosGet[1],_aPosGet[1,_nCont])
		Aadd(_aPosGet[1],_aPosGet[1,_nCont+1])
		_nCont += 2
	Next

	_nSalta := 15
	_nLin	:= 63
	_nLin 	+= _nSalta
	
    @ _nLin, 13 SAY 'Obs. Geral C.P.' PIXEL SIZE 40,10 Of _oNewDialog  
	@ _nLin, _aPosGet[1,_nCol+=1] Get _oMemo VAR cC3_SCOP  MEMO SIZE 540, 23 WHEN .T. Of _oNewDialog PIXEL FONT _oCourierNw 
	
End Sequence

Return .T.
