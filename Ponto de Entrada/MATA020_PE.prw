#include "Protheus.ch"

/*
=====================================================================================
Programa.:              CUSTOMERVENDOR
Autor....:              CAOA - Valter Carvalho
Data.....:              28/04/2020
Descricao / Objetivo:   Ponto de entrada do cadastro de fornecedor
Doc. Origem:
Solicitante:            Antonio Marcio
Uso......:              
=====================================================================================
*/
User Function CUSTOMERVENDOR()

	Local _lRet	  := .T.
	Local aArea	  := GetArea()

	If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
		_lRet := zMontadora()
	Else
		_lRet := zCaoaSp() //Executa o p.e. CaoaSp
	EndIf

	RestArea(aArea)

Return(_lRet)

/*
==============================================================================================
Programa.:              zMontadora
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada Montadora
===============================================================================================
*/
Static Function zMontadora()
	Local lRet 		:= .T.

	If PARAMIXB[2] == "FORMPRE" .AND. PARAMIXB[4] == "SETVALUE"

		If lRet
			If FindFunction("U_ZCOMF020")
				lRet :=  U_ZCOMF020()
			Endif
		Endif
	Endif


Return(lRet)

/*
==============================================================================================
Programa.:              zCaoaSp
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada CaoaSp
===============================================================================================
*/
Static Function zCaoaSp()

    Local lRet 	   := .T.
    Local aParam   := PARAMIXB
    Local oObj     := ""
    //Local oModel   := FWModelActive()
    Local cIdPonto := ""
    Local cIdModel := ""
    
    oObj     := aParam[1]
    cIdPonto := aParam[2]
    cIdModel := aParam[3]
    nOpcx := oObj:GetOperation()
    
    If cIdPonto == "FORMPRE" .AND. PARAMIXB[4] == "SETVALUE"

        If lRet
            If FindFunction("U_ZCOMF020")
                lRet :=  U_ZCOMF020()
            Endif
        Endif

    Endif                   

    If cIdPonto == 'FORMCOMMITTTSPOS'
		If nOpcx == 3  .or. nOpcx == 4 .or. nOpcx == 5   //Inclusão ou Alteração Exclusão
           	
        	IF ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
			    U_ZF10GENSAP("SA2",M->A2_COD+M->A2_LOJA,"A2_XCDSAP",nOpcx)
		        U_ZWSR014( M->A2_COD, M->A2_LOJA )
			EndIf

		ENDIF
	EndIF

Return(lRet)

