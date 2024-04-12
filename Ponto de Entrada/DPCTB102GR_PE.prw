#Include "Totvs.ch"
#Include "Protheus.ch"


//==================================================================================================
//Programa.:              DPCTB102GR
//Autor....:              Alex Lima
//Data.....:              27/11/2018
//Descricao / Objetivo:   Comunica��o cont�bil com o SAP
//Doc. Origem:            MIT044 - R03PT - Especifica��o de Personaliza��o - SAP - 05 - Cont�bil.pdf
//Solicitante:            CAOA
//Uso......:              CAOA
//Obs......:              Ponto de entrada depois da contabilizacao
//==================================================================================================
User Function DPCTB102GR()

	Local _lRet	   	:= .T.
	Local aArea	   	:= GetArea()
	Local aPar      := {}
	local nOpc 		:= PARAMIXB[1]

	If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
		If Findfunction("U_CMVSAP09")
			FwMsgRun(, { || _lRet := U_CMVSAP09(nOpc) },,"Aguarde... Grava Lan�amento Cont�bil para ser enviado ao SAP...")
		EndIf
		If FindFunction("U_CMVSAP08") .and. FunName() <> "CMVCTBROF" //Ignorar o envio Para o SAP quando for rateio, ser� enviado peloo JOB posteriormente
			FwMsgRun(, { || U_CMVSAP08( aPar ) },,"Aguarde... Executando a Integra��o Cont�bil com SAP...")
		EndIf
	ElseIf ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Franco da Rocha | Caoa
		If Findfunction("U_ZSAPF009")
			FwMsgRun(, { || _lRet := U_ZSAPF009(nOpc) },,"Aguarde... Grava Lan�amento Cont�bil para ser enviado ao SAP...")
		EndIf
		If FindFunction("U_ZSAPF008")
			FwMsgRun(, { || U_ZSAPF008( aPar ) },,"Aguarde... Executando a Integra��o Cont�bil com SAP...")
		EndIf
	EndIf

	RestArea(aArea)

Return(_lRet)
