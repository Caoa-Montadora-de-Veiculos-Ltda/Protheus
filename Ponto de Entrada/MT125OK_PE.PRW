#include "protheus.ch"
#include "parmtype.ch"
#include 'Fwmvcdef.CH'
/*/{Protheus.doc} MT125OK_PE
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	13/10/2020
@return  	NIL
@obs        Ponto de entrada do MATA125
@project
@history    Salvar dados adicionais em CP
*/
User Function MT125OK
Local _lRet       := .T.
Local  _nOpc      := If(INCLUI,3, ;
					 IF(ALTERA,4, ;
					 5) )
Local _aEmpFil   := {cEmpAnt,cFilAnt}
Local _cFun      := Alltrim(Funname())
Local _aHeadAux  := aClone(aHeader)
Local _aColsAux  := aClone(aColsAlt)
Local _lJobStart := .T.
Local _cNum      := cA125Num
Local _cUsuario  := RETCODUSR()
Local _cMotivo 	 := space(255)

Begin Sequence
	// ** ************************************************************ ** //
    // **  VALIDAR CAMPOS, INFORMACOES ADICIONAIS (Enchoise / MsmGet)  ** //
    // ** ************************************************************ ** //
	If FindFunction("U_ZCOMF015")

		//_lRet := U_ZCOMF015( "CP" /*Doc*/,_nOpc, /*indica se devve mostrar somente a tela*/)
		If INCLUI
			_cMotivo := "Inclusão"
		else
			U_TelMotivo(@_cMotivo)
		Endif
		StartJob("U_ZCOMF015",GetEnvServer(),.F.,"CP",_nOpc,,_cNum,_aHeadAux,_aColsAux,_lJobStart,_aEmpFil,_cFun,INCLUI,ALTERA,_cUsuario,_cMotivo )
	EndIf
	
End Sequence
Return _lRet
