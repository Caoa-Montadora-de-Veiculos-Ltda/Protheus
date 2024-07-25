#INCLUDE "PROTHEUS.CH"

/*
=====================================================================================
Programa.:              M110STTS
Autor....:              Evandro Mariano
Data.....:              25/07/19
Descricao / Objetivo:   Inclusão de interface após gravar a solicitação
Doc. Origem:
Solicitante:            Compras
Uso......:              CAOA Montadora de Veiculos
Obs......:
@history.:              DAC - 12/03/2020 	
                        Utilizado quando da Exclusão para gravar historico funcionalidade ZCOMF015
=====================================================================================
*/
User Function M110STTS()
//Local _cNumSc	:= ParamIxb[1]
Local _nOpc		 := ParamIxb[2]
Local _lCopia	 := ParamIxb[3]
Local _lRet	     := .T.
Local aArea		 := GetArea()
Local _aEmpFil   := {cEmpAnt,cFilAnt}
Local _cFun      := Alltrim(Funname())
Local _aHeadAux  := aClone(aHeader)
Local _aColsAux  := aClone(aCols)
Local _lJobStart := .T.
Local _cNum      := cA110Num
Local _cUsuario  := RETCODUSR()
Local _cMotivo 	 := space(255)
	
	If _lCopia //Verifico se é cópia
		_nOpc := 5
	endif
		
	If FindFunction("U_ZCOMF015")   //_nOpc == 5  .and.
		//_lRet := U_ZCOMF015( "SC" /*Doc*/,_nOpc, /*indica se devve mostrar somente a tela*/)
		If INCLUI
			_cMotivo := "Inclusão"
		else
			U_TelMotivo(@_cMotivo)
		Endif

		StartJob("U_ZCOMF015",GetEnvServer(),.F.,"SC",_nOpc,,_cNum,_aHeadAux,_aColsAux,_lJobStart,_aEmpFil,_cFun,INCLUI,ALTERA,_cUsuario,_cMotivo )
	Endif
		
	RestArea(aArea)
Return _lRet
