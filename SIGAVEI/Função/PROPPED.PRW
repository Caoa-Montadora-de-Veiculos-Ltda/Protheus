#INCLUDE "TOTVS.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"

#define lDebug .f.

User Function PROPPED()
	Local oModelImp := ParamIXB[1] // Model contendo os registros selecionados para impressao

	U_PROPOSTA("PROPPED", , , oModelImp)
Return
