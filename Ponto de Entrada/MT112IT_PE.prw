#Include 'Rwmake.ch'
#Include 'TopConn.ch'

/*/{Protheus.doc} MT112IT
P.E. - executado ap�s a grava��o de cada �tem depois da a Solicita��o de Importa��o.
@author FSW - DWC Consult
@since 20/03/2019
@version 1.0
@type function
/*/
User Function MT112IT() 
	Local aArea	:= GetArea()

	If ExistBlock("GRVMT112")
		ExecBlock("GRVMT112", .F., .F.)
	EndIf

	RestArea(aArea)
Return 