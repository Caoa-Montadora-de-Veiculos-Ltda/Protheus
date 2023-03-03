#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APWEBEX.CH"                                     
/*
=====================================================================================
Programa.:              CMVPCP06
Autor....:              Atilio Amarilla
Data.....:              16/01/2019
Descricao / Objetivo:   Integração PROTHEUS - PCP x MES
Doc. Origem:            Contrato - GAP PCP004
Solicitante:            Cliente CAOA
Uso......:              Marfrig
Obs......:              WS Server para Integração de informações de produção (MES)
=====================================================================================
*/
User Function CMVPCP06()

Return

// Informações de Produção - Estrutura de dados. Montagem do Array de dados.
WSSTRUCT ReqIntegraTotvsMES

	WSDATA FILIAL  		AS string
	WSDATA BARCODE  	AS string
	WSDATA TIPOINFORM	AS string
	WSDATA PRODUTO  	AS string OPTIONAL
	WSDATA INFORMACAO	AS string

ENDWSSTRUCT

// Movimentos de Produção - Estrutura de dados. Montagem do Array de retorno. Apontamento de Produção/Consumo de Insumos
WSSTRUCT RetIntegraTotvsMES
	WSDATA STATUS	AS String
	WSDATA MSG		AS String
ENDWSSTRUCT

/***************************************************************************
* Definicao do Web Service. Integração PCP x MES.				                       *
***************************************************************************/
WSSERVICE CMVPCP06 DESCRIPTION "Integração CAOA - PCP x MES" NameSpace "http://totvs.com.br/CMVPCP06.apw"

	// Produção - Passagem dos parâmetros de entrada
	WSDATA RequisTotvsMES AS ReqIntegraTotvsMES
	// Produção - Retorno (array)
	WSDATA RetornoTotvsMES AS RetIntegraTotvsMES

	WSMETHOD IntegracaoTotvsMES DESCRIPTION "Integração CAOA - PCP x MES"

ENDWSSERVICE

/************************************************************************************
** Metodo IntegracaoTotvsMES
** Grava dados de processos produtivos - apontamentos / requisições referentes a OPs
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
									::RequisTotvsMES:INFORMACAO										} )	// Passagem de parâmetros para rotina

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
		If aInform[03] $ "24" // Item de Segurança / Motor
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
					If aInform[03] == "3" // Posição PBS
						ZZG->ZZG_INFORM	:=	StrZero(Val(aInform[05]),3)
					Else
						ZZG->ZZG_INFORM	:=	aInform[05]
					EndIf
					ZZG->ZZG_TSINCL	:=	FWTimeStamp(1)
					
	
					ZZG->( msUnlock() )
					aAdd( aRetorno , {"1","[ZZG] Gravação Efetuada"} )
	
				Else
					aAdd( aRetorno , {"2","[ZZG] Erro de Gravação"} )
				EndIf
			Else
				aAdd( aRetorno , {"2","[ZZG] Produto não cadastrado: "+cCodPro} )
			EndIf
		Else
			aAdd( aRetorno , {"2","[ZZG] BarCode não cadastrado: "+cBarCod} )
		EndIf
	Else
		aAdd( aRetorno , {"2","[ZZG] Filial inválida: "+aInform[01]} )
	EndIf

Return( aRetorno )

