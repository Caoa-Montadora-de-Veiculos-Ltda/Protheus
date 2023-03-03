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
Local _nOpc		:= ParamIxb[2]
Local _lCopia	:= ParamIxb[3]
Local _lRet	    := .T.
Local aArea		:= GetArea()
	
	If _lCopia //Verifico se é cópia
		_nOpc := 5
	endif
		
	If FindFunction("U_ZCOMF015")   //_nOpc == 5  .and.
		_lRet := U_ZCOMF015( "SC" /*Doc*/,_nOpc, /*indica se devve mostrar somente a tela*/)
	Endif
		
	RestArea(aArea)
Return _lRet
