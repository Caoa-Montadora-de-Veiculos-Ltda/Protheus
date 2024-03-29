#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APWEBEX.CH"                                     
/*
=====================================================================================
Programa.:              CMVPCP06
Autor....:              Atilio Amarilla
Data.....:              16/01/2019
Descricao / Objetivo:   Integra��o PROTHEUS - PCP x MES
Doc. Origem:            Contrato - GAP PCP004
Solicitante:            Cliente CAOA
Uso......:              Marfrig
Obs......:              WS Server para Integra��o de informa��es de produ��o (MES)
=====================================================================================
*/
User Function CMVPCP06()

Return

// Informa��es de Produ��o - Estrutura de dados. Montagem do Array de dados.
WSSTRUCT ReqIntegraTotvsMES

	WSDATA FILIAL  		AS string
	WSDATA BARCODE  	AS string
	WSDATA TIPOINFORM	AS string
	WSDATA PRODUTO  	AS string OPTIONAL
	WSDATA INFORMACAO	AS string

ENDWSSTRUCT

// Movimentos de Produ��o - Estrutura de dados. Montagem do Array de retorno. Apontamento de Produ��o/Consumo de Insumos
WSSTRUCT RetIntegraTotvsMES
	WSDATA STATUS	AS String
	WSDATA MSG		AS String
ENDWSSTRUCT

/***************************************************************************
* Definicao do Web Service. Integra��o PCP x MES.				                       *
***************************************************************************/
WSSERVICE CMVPCP06 DESCRIPTION "Integra��o CAOA - PCP x MES" NameSpace "http://totvs.com.br/CMVPCP06.apw"

	// Produ��o - Passagem dos par�metros de entrada
	WSDATA RequisTotvsMES AS ReqIntegraTotvsMES
	// Produ��o - Retorno (array)
	WSDATA RetornoTotvsMES AS RetIntegraTotvsMES

	WSMETHOD IntegracaoTotvsMES DESCRIPTION "Integra��o CAOA - PCP x MES"

ENDWSSERVICE

/************************************************************************************
** Metodo IntegracaoTotvsMES
** Grava dados de processos produtivos - apontamentos / requisi��es referentes a OPs
************************************************************************************/
WSMETHOD IntegracaoTotvsMES WSRECEIVE	RequisTotvsMES WSSEND RetornoTotvsMES WSSERVICE CMVPCP06

	Local aRetFuncao := {}
	Local StructTemp
	Local lReturn	:= .T.
	Local oRetProd
	Local cTime :=  'Antes: '+Time()                     

	//FwLogProfiler(,.T.) 
	aRetFuncao	:= CMVPCP06(	{	::RequisTotvsMES:FILIAL											,;
									::RequisTotvsMES:BARCODE										,;
									::RequisTotvsMES:TIPOINFORM										,;
									IIF(::RequisTotvsMES:PRODUTO<>NIL,::RequisTotvsMES:PRODUTO,"")	,;
									::RequisTotvsMES:INFORMACAO										} )	// Passagem de par�metros para rotina

	// Cria e alimenta uma nova instancia de retorno do cliente
	::RetornoTotvsMES :=  WSClassNew( "RetIntegraTotvsMES" )
	::RetornoTotvsMES:STATUS	:= aRetFuncao[1][1]
	::RetornoTotvsMES:MSG		:= aRetFuncao[1][2]

	::RequisTotvsMES := Nil
	DelClassINTF()


Return lReturn

Static Function CMVPCP06( aInform )

	Local aRetorno := {}
	Local cCodPro

	aSM0 := FWLoadSM0()

	nPos      := ASCAN(aSM0,{|x| Alltrim(x[01])+Alltrim(x[02]) == "01"+Alltrim(aInform[01])})

	IF nPos > 0
		cBarCod	:= Stuff( Space(TamSX3("ZZ3_BARCOD")[1]) , 1 , Len(aInform[02]) , aInform[02] )
		If aInform[03] $ "24" // Item de Seguran�a / Motor
			cCodPro	:= Stuff( Space(TamSX3("B1_COD")[1]) , 1 , Len(aInform[04]) , aInform[04] )
		Else
			cCodPro	:= ""
		EndIf

		cFilAnt := aInform[01]

		dbSelectArea("ZZ3")
		dbSelectArea("SB1")
		dbSelectArea("ZZG")
		If ZZ3->( dbSeek( xFilial("ZZ3")+cBarCod ) )
			If SB1->( dbSeek( xFilial("SB1")+cCodPro ) )
	
				If RecLock("ZZG",.T.)
	
					ZZG->ZZG_FILIAL	:=	aInform[01]
					ZZG->ZZG_DOC	:=	GetSXENum("ZZG","ZZG_DOC")
					ConfirmSX8()
					ZZG->ZZG_BARCOD	:=	aInform[02]
					ZZG->ZZG_TPINFO	:=	aInform[03]
					ZZG->ZZG_PRODUT	:=	aInform[04]
					If aInform[03] == "3" // Posi��o PBS
						ZZG->ZZG_INFORM	:=	StrZero(Val(aInform[05]),3)
					Else
						ZZG->ZZG_INFORM	:=	aInform[05]
					EndIf
					ZZG->ZZG_TSINCL	:=	FWTimeStamp(1)
					
	
					ZZG->( msUnlock() )
					aAdd( aRetorno , {"1","[ZZG] Grava��o Efetuada"} )
	
				Else
					aAdd( aRetorno , {"2","[ZZG] Erro de Grava��o"} )
				EndIf
			Else
				aAdd( aRetorno , {"2","[ZZG] Produto n�o cadastrado: "+cCodPro} )
			EndIf
		Else
			aAdd( aRetorno , {"2","[ZZG] BarCode n�o cadastrado: "+cBarCod} )
		EndIf
	Else
		aAdd( aRetorno , {"2","[ZZG] Filial inv�lida: "+aInform[01]} )
	EndIf

Return( aRetorno )

