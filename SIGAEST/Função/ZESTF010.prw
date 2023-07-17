#Include "Protheus.ch"

/*/{Protheus.doc} ZESTF010
@author 	Evandro Mariano
@version  	P12.1.23
@since  	14/07/2023
@return  	NIL
@obs        Ponto de entrada do MATA241
@project
@history    Função chamada no P.E MT241TOK_PE
*/ 

User Function ZESTF010()

Local _nX       	:= 0
Local _lRet     	:= .T.
Local _cMsgnErro	:= ""
Local _cIdUser		:= RetCodUsr()
Local _aAreaVAI    	:= VAI->(GetArea())
Local _nPrdOrig		:= aScan( aHeader, {|x| AllTrim(x[02]) 			== "D3_COD"				} ) 
Local _nLocOrig		:= aScan( aHeader, {|x| AllTrim(Upper(x[01])) 	== 'ARMAZEM ORIG.' 		} ) 
Local _nLocDest 	:= aScan( aHeader, {|x| AllTrim(Upper(x[01])) 	== 'ARMAZEM DESTINO' 	} ) 

	VAI->(DbSetOrder(4)) 
	If VAI->(DbSeek(xFilial("VAI")+_cIdUser ))

		If VAI->VAI_XBLQES == "1"
			_lRet := .T.
		ElseIf VAI->VAI_XBLQES == "2"

			For _nX := 1 to Len( aCols )
				_cMsgnErro := ""
				If !aCols[_nX][len(aHeader)+1] //Linha deletada
					If AllTrim((aCols[_nX][_nLocOrig])) $ AllTrim(VAI->VAI_XESTOR)
						_cMsgnErro += "Armazem Origem: "+Alltrim((aCols[_nX][_nLocOrig]) ) + CRLF            
					EndIf 
					If AllTrim((aCols[_nX][_nLocDest])) $ AllTrim(VAI->VAI_XESTDE)
						_cMsgnErro += "Armazem Destino: "+Alltrim((aCols[_nX][_nLocDest]) ) + CRLF 
					EndIf		
					If !Empty(_cMsgnErro)
						_lRet := .F.
						ApMsgStop( "Usuário não pode realizar transferencia para:"+ CRLF + CRLF + "Linha: "+ Alltrim(Str(_nX)) + CRLF + "Produto: "+AllTrim((aCols[_nX][_nPrdOrig])) + CRLF + _cMsgnErro ,"Aviso... [ A261TOK ]" )
						Exit
					EndIf
				EndIf
			Next
		Else
			_lRet := .F.
			ApMsgAlert( "Informe o tipo de Bloqueio no Cad. de Equipe Tecnica.","Aviso... [ A261TOK ]" )
		EndIf
	Else	
		_lRet := .F.
		ApMsgAlert( "Usuário não cadastrado na Equipe Tecnica.","Aviso... [ A261TOK ]" )
	EndIf
	
	RestArea(_aAreaVAI)

Return(_lRet)
