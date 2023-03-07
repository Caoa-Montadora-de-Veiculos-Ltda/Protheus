#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
=====================================================================================
Programa.:              ZFATF017
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              28/07/2022
Descricao / Objetivo:   Ajusta os limites de Crédito
Doc. Origem:            
Solicitante:            Faturamento/Pecas
Uso......:              
Obs......:              TESTE DE COMMIT
=====================================================================================
*/

Static _lJob 	:= .T.

User Function ZFATF017( _cCodCli )

	Local _cAlsTmp01 	  	:= GetNextAlias()
	Local _cQryTmp01     	:= " "
	Local _aArea	   		:= GetArea()
	Local _lAbre			:= .F.
	Local _cEmpresa 		
	Local _cFilial 	

	Default _cCodCli		:= ""

	If ! IsBlind()  //interface com o usuário
		_lJob := .F.
	Endif

	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFATF017] Iniciado: Ajuste de Credito")

	//Avaliar tera que rodar Anapolis e Franco da Rocha  DAC 06/08/2023
	If _lJob
		_cEmpresa	:=	"02"
		_cFilial	:=  "2020012001"

		CONOUT("INICIANDO EMPRESA "+_cEmpresa)
		CONOUT("INICIANDO FILIAL "+_cFilial)
		RpcClearEnv()
		RpcSetType(3)

		Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "PCP"
		_lAbre		:= .T.

		CONOUT("INICIADA EMPRESA "+cEmpAnt)
		CONOUT("INICIADA FILIAL "+cFilAnt)
	
	EndIf

	If Select(_cAlsTmp01) > 0
		(_cAlsTmp01)->(DbCloseArea())
	EndIf

	// Verifica os clientes que possuem limite de crédito habilidado.
	// A1_XTPCRED = 1 // FloorPlan
	// A1_XTPCRED = 2 // Caoa
	_cQryTmp01 := ""
	_cQryTmp01 += " SELECT A1_COD, A1_LOJA, A1_XTPCRED FROM " + RetSqlName("SA1") + " SA1 "	+ CRLF
	_cQryTmp01 += " WHERE SA1.D_E_L_E_T_ = ' ' "									+ CRLF
	//Implementado possibilidade de informar somente o cliente e não todos DAC 27/02/2023	
	If !Empty(_cCodCli)
		_cQryTmp01 += " AND  SA1.A1_COD = '"+_cCodCli +"' "							+ CRLF
	Endif
	_cQryTmp01 += " AND ( 	SA1.A1_XTPCRED IN ('1','2') "							+ CRLF
	_cQryTmp01 += " 		OR (SA1.A1_XTPCRED = '0' AND A1_XLC > 0) ) "			+ CRLF
	_cQryTmp01 += " ORDER BY A1_COD "												+ CRLF
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQryTmp01 ), _cAlsTmp01, .F., .T. )
	DbSelectArea((_cAlsTmp01)) 
	(_cAlsTmp01)->(dbGoTop())
	While (_cAlsTmp01)->(!Eof())
		U_ZFATF014((_cAlsTmp01)->A1_COD, (_cAlsTmp01)->A1_XTPCRED, (_cAlsTmp01)->A1_LOJA)
		(_cAlsTmp01)->(DbSkip())
	EndDo

	//(_cAlsTmp01)->(DbCloseArea())

	RestArea(_aArea)

	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZFATF017] Finalizado: Ajuste Credito")
	
	If 	_lAbre	
		Reset Environment
	EndIf

If Select(_cAlsTmp01) <> 0
	(_cAlsTmp01)->(DbCloseArea())
	Ferase(_cAlsTmp01+GetDBExtension())
Endif  

Return()
