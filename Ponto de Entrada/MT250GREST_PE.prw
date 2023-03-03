#Include 'Protheus.Ch'
#Include 'TOTVS.Ch'

/*/{Protheus.doc} MT250GREST
P.E. - Responsavel pelos estornos dos apontamentos de produção.
@author FSW - DWC Consult
@since 02/04/2019
@version 1.0
@type function
/*/
User Function MT250GREST()
	Local lRetOk	:= .F.
	Local aArea		:= GetArea()

	If ExistBlock("ESTVEIC")
		lRetOk := ExecBlock("ESTVEIC", .F., .F.)
	EndIf

	RestArea(aArea)
Return( lRetOk )