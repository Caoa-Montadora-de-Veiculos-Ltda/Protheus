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

Local lUserAut  := .F.
Local _nX       := 0
Local _lRet     := .F.
Local _cEmp     := FWCodEmp()
Private _nLocal

	If _cEmp == "2010" //Executa o p.e. Anapolis.
    	_lRet := .T.
	Else
		lUserAut := U_ZGENUSER( RetCodUsr() ,"ZESTF010",.T.)

		_cLocal   := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D3_LOCAL"}) 

		For _nX := 1 to Len(aCols)
		
			If !aCols[_nX][len(aHeader)+1]
			
				If aCols[_nX][_nLocal]$"32/33" 
			
				Alert("Saldo insuficiente no armazém "+Acols[_nX][_nLocal]+"!")
				_lRet     := .F.

				Else

					_lRet     := .F.

				EndIf
				
			EndIf
		Next
	EndIf
    	
Return(_lRet)
