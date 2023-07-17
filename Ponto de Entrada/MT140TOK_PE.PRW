#Include 'Rwmake.ch'
#Include 'TopConn.ch'

#DEFINE cFONT   '<b><font size="3" color="blue"><b>'
#DEFINE cALERT  '<b><font size="3" color="red"><b>'
#DEFINE cNOFONT '</b></font></b></u>'

/*/{Protheus.doc} MT140TOK
@author A.Carlos
@since 	27/04/2023
@version 1.0
@return ${return}, ${return_description}
@obs	
@history    Chamar a criação da SZM
@type function
/*/
User Function MT140TOK()
	Local lRet     := .T.

	IF FWCodEmp() = '2010' .AND. FWFilial() = '2001' .AND. cSerie == "CKD" //.AND. FWIsInCallStack("U_ZCOMF051")

		_lRet := U_INC_SZM()

	ENDIF

Return lRet

