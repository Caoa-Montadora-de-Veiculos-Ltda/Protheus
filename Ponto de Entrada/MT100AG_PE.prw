#Include 'Rwmake.ch'
#Include 'TopConn.ch'

#DEFINE cFONT   '<b><font size="3" color="blue"><b>'
#DEFINE cALERT  '<b><font size="3" color="red"><b>'
#DEFINE cNOFONT '</b></font></b></u>'
/*/{Protheus.doc} MT100AG
@author A.Carlos
@since 	27/04/2023
@version 1.0
@return ${return}, ${return_description}
@obs	
@history    Chamar após a criação da pré-nota
@type function
/*/
User Function MT100AG()

    If FindFunction("U_ZCOMF052") 
       U_ZCOMF052()
    EndIf

Return()
