#Include "Protheus.ch"

/*
=====================================================================================
Programa.:              EICSI400
Autor....:              Atilio Amarilla
Data.....:              23/12/2018
Descricao / Objetivo:   PE SIGAEIC
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos - GAP PCP006
Obs......:              Rotina criada para inibir mensagens de erro quando compilado
Obs......:              o PE EICEV100
=====================================================================================
*/
User Function EICSI400()

	Local _cEmp    := FWCodEmp()
	Local _lRet	   := .T.
	Local aArea	   := GetArea()

	If _cEmp == "2010" //Executa o p.e. Anapolis.
		_lRet := .T.
	Else
		_lRet := zCaoaSp() //Executa o p.e. CaoaSp
	EndIf

	RestArea(aArea)

Return(_lRet)

/*
==============================================================================================
Programa.:              zCaoaSp
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada CaoaSp
===============================================================================================
*/
Static Function zCaoaSp()

	Local cParamIXB := Iif(ValType(ParamIXB) == "A", cParamIXB:= ParamIXB[1], cParamIXB:= ParamIXB)
//Local _cPosicao := Space(04)

	If (cParamIXB = "INCLUI_BOTAO" .AND. ALTERA = .T.) .OR. (cParamIXB = "INCLUI_BOTAO".AND. nOpcSI = 2)
		IF FWCodEmp() <> '2020' .OR. FWFilial() <> '2001' //Verificar Empresa/Filial Barueri
			RETURN Nil
		ENDIF

		SetKey (VK_F4,{||RetPosicao()})

		//_cPosicao := RetPosicao()

	EndIf

Return(.T.)


/*/{Protheus.doc} EICSI400
@author A.Carlos
@since 18/08/2022
@version 1.0
    @return Nil, Retorno da posição do item na Grid da SI
    @example
/*/
Static Function RetPosicao()
	Local nLin       := 0
	Local nCol       := 0
	Local _cItem     := Space(23)
	Local aParamBox  := {}
	Private aRetPer  := {}
	Private _cSI_NUM := SW1->W1_SI_NUM
	Private _cCC     := SW1->W1_CC

	aAdd(aParamBox,{ 1, "Item ", _cItem, "@!", "", "SW1A","", 60,.T.})

	If !ParamBox(aParamBox, " " + SW1->W1_SI_NUM, @aRetPer, , , , , , , , ,.T.)
		Return Nil
	EndIf

	TRB->(dbGoTop())

	While TRB->(!EOF())

		nLin++

		IF Alltrim(aRetPer[1]) = Alltrim(TRB->W1_COD_I)

			nCol := 02

			Return {nLin, nCol}    // Retorna a primeira ocorrência, se comentado retornará a última ocorrência.

		EndIF

		TRB->(DbSkip())

	End

// Se não encontrou retorna {0, 0}
Return {nLin, nCol}

