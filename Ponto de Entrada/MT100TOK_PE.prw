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

	Local _lRet	  := .T.
	Local aArea	  := GetArea()

	If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB

		Begin Sequence

			//Verificar validade Inmetro
			If FunName() = "MATA103"
				_lRet := U_ZPECF005()
			Endif

		End Sequence
	EndIf

	RestArea(aArea)

Return(_lRet)
