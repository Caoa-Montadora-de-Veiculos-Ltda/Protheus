#Include "Protheus.ch"

/*/{Protheus.doc} MS520DEL
//TODO Descrição auto-gerada.
@author rafael.melo
@since 08/06/2017
@version undefined

@type function
/*/

User Function MS520DEL()

	Local _cEmp		:= FWCodEmp()
	Local aArea		:= GetArea()

	If _cEmp == "2010" //Executa o p.e. Anapolis.
		If Findfunction("U_CMVSAP14")
			U_CMVSAP14("0")
		EndIf
	Else
		If Findfunction("U_ZSAPF014")
			U_ZSAPF014("0")
		EndIf
	EndIf

	RestArea(aArea)

Return()
