#Include "Protheus.ch"                                                                                                                                     

/*/{Protheus.doc} MS520DEL
//TODO Descrição auto-gerada.
@author rafael.melo
@since 08/06/2017
@version undefined

@type function
/*/

User Function MS520DEL() 

	If Findfunction("U_CMVSAP14")
		//lRet := U_CMVSAP11(6)
		U_CMVSAP14("0")
	EndIf

Return 

