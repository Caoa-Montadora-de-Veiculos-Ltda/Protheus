#Include 'Rwmake.ch'
#Include 'TopConn.ch'

#DEFINE cFONT   '<b><font size="3" color="blue"><b>'
#DEFINE cALERT  '<b><font size="3" color="red"><b>'
#DEFINE cNOFONT '</b></font></b></u>'

/*/{Protheus.doc} MT100TOK
@author A.Carlos
@since 	01/10/2021
@version 1.0
@return ${return}, ${return_description}
@obs	
@history    Validar certificado Inmetro
@type function
/*/

User Function MT100TOK()

	Local _cEmp    := FWCodEmp()
	Local _lRet	  := .T.
	Local aArea	  := GetArea()

	If _cEmp == "2020" //Executa o p.e. Anapolis.

		Begin Sequence

			IF FWFilial() = '2001'

				//Verificar validade Inmetro
				If FunName() = "MATA103"
					_lRet := U_ZPECF005()
				Endif

			ENDIF

		End Sequence
	EndIf

	RestArea(aArea)

Return(_lRet)
