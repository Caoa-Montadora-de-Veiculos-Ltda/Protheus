#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DIALOG.CH"
#INCLUDE "FONT.CH" 
#INCLUDE "TOPCONN.CH"

/*
=====================================================================================
Programa.:              ZFATF014
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              28/07/2022
Descricao / Objetivo:   Ajusta os limites de Crédito
Doc. Origem:            
Solicitante:            Faturamento/Pecas
Uso......:              
Obs......:
=====================================================================================
*/
User Function ZFATF014(_cCliFat,_cTpCred)

	Local _aArea      	:= GetArea()
	Local _nValAtr 		:= 0
	Local _nValAbe 		:= 0
	Local _nValBo 		:= 0
	Local _nValPed 		:= 0
	Local _cRet			:= ""
	Private _cPgNAval	:= SuperGetMV( "MV_CPNCLC" ,,"'003','011','025'") //condição de pagamento não será avaliado LC
	Private _cPgFP 		:= AllTrim( GetMV('CMV_PEC018') ) //condição de pagamento Forplan = 005 	

	_nValAtr := ZProc001(_cCliFat, _cTpCred) //Verifica os Titulos Em Atraso a mais de 3 dias.
	_nValAbe := ZProc010(_cCliFat, _cTpCred) //Verifica os Titulos Em Aberto
	_nValBo  := ZProc020(_cCliFat, _cTpCred) //Verifica os Pedidos Em Bo
	_nValPed := ZProc030(_cCliFat, _cTpCred) //Verifica os Pedidos Em Reserva/Em Faturamento/Em Separação
	
	_cRet := ZGrvSA1(_cCliFat, _cTpCred, _nValAtr, _nValAbe, _nValBo, _nValPed) //Grava os Dados na SA1
	
	RestArea(_aArea)

Return({_cRet, _nValAtr, _nValAbe, _nValBo, _nValPed})

/*
=====================================================================================
Programa.:              ZProc001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              28/07/2022
Descricao / Objetivo:   Verifica os Titulos Em Atraso a mais de 3 dias.
Doc. Origem:            
Solicitante:            Faturamento/Pecas
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZProc001(_cCliFat,_cTpCred)

	Local _cQrySE1    	:= " "
	Local _cAls01SE1  	:= GetNextAlias()
	Local _nValAtr	  	:= 0
	Local _nDiasAtrFp	:= SuperGetMV( "CMV_PEC027"  ,,3 ) 
	Local _DtAtraso		:= Date()

	_DtAtraso := ( _DtAtraso - _nDiasAtrFp )
	
	If Select(_cAls01SE1) > 0
		(_cAls01SE1)->(DbCloseArea())
	EndIf

	//Procura os titulos em aberto no financeiro.
	_cQrySE1 := ""
	_cQrySE1 += " SELECT SE1.E1_CLIENTE, SUM(SE1.E1_SALDO) AS TIT_VENC FROM " + RetSqlName("SE1") + " SE1 "	+ CRLF
	_cQrySE1 += " 	INNER JOIN " + RetSqlName("SF2") + " SF2"												+ CRLF
	_cQrySE1 += " 		ON SF2.F2_FILIAL = '" + FwXFilial("SF2") + "' "										+ CRLF
	_cQrySE1 += " 		AND SF2.F2_DOC = SE1.E1_NUM "														+ CRLF
	_cQrySE1 += " 		AND SF2.F2_SERIE = SE1.E1_PREFIXO "													+ CRLF
	_cQrySE1 += " 		AND SF2.F2_CLIENTE = SE1.E1_CLIENTE "												+ CRLF
	_cQrySE1 += " 		AND SF2.F2_LOJA = SE1.E1_LOJA "														+ CRLF
	_cQrySE1 += " 		AND SF2.F2_EMISSAO = SE1.E1_EMISSAO "												+ CRLF
	If _cTpCred == '1' //FloorPlan
		_cQrySE1 += " 	AND SF2.F2_COND IN "+ FormatIn(_cPgFP,";") + " "									+ CRLF
	//Else
	//	_cQrySE1 += " AND SF2.F2_COND NOT IN  "+ FormatIn(_cPgNAval,";") + " " 								+ CRLF
	EndIf
	_cQrySE1 += " 		AND SF2.D_E_L_E_T_ = ' ' "															+ CRLF
	_cQrySE1 += " WHERE SE1.D_E_L_E_T_ = ' '  "																+ CRLF
	_cQrySE1 += " AND SE1.E1_FILIAL 	= '" + FwXFilial("SE1") + "' "										+ CRLF
	_cQrySE1 += " AND SE1.E1_CLIENTE = '" +_cCliFat+"' " 													+ CRLF
	_cQrySE1 += " AND SE1.E1_VENCREA < '" +Dtos(_DtAtraso)+"' "												+ CRLF
	_cQrySE1 += " AND SE1.E1_SALDO > 0 "																	+ CRLF
	_cQrySE1 += " AND SE1.E1_TIPO NOT IN ('NCC') "															+ CRLF
	_cQrySE1 += " GROUP BY SE1.E1_CLIENTE "																	+ CRLF
	_cQrySE1 += " ORDER BY SE1.E1_CLIENTE "																	+ CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQrySE1 ), _cAls01SE1, .F., .T. )

	_nValAtr := 0
	
	DbSelectArea((_cAls01SE1)) 
	(_cAls01SE1)->(dbGoTop())
	If (_cAls01SE1)->(!Eof())

		_nValAtr := (_cAls01SE1)->TIT_VENC

	EndIf

	(_cAls01SE1)->(DbCloseArea())

Return(_nValAtr)

/*
=====================================================================================
Programa.:              ZProc010
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              28/07/2022
Descricao / Objetivo:   Verifica os Titulos Em Aberto
Doc. Origem:            
Solicitante:            Faturamento/Pecas
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZProc010(_cCliFat,_cTpCred)
	
	Local _cQrySE1    	:= " "
	Local _cAls02SE1   	:= GetNextAlias()
	Local _nValAbe  	:= 0
	
	If Select(_cAls02SE1) > 0
		(_cAls02SE1)->(DbCloseArea())
	EndIf

	_cQrySE1 := " "
	_cQrySE1 += " SELECT NVL(SUM(SE1.E1_SALDO),0) AS VAL_SE1 " 				+ CRLF
	_cQrySE1 += " FROM " + RetSqlName("SE1") + " SE1 " 						+ CRLF
	_cQrySE1 += " 	JOIN " + RetSqlName("SF2") + " SF2 "					+ CRLF
	_cQrySE1 += " 		ON SF2.F2_FILIAL = '" + FwXFilial("SF2") + "' "		+ CRLF
	_cQrySE1 += " 		AND SF2.F2_DOC = SE1.E1_NUM "						+ CRLF
	_cQrySE1 += " 		AND SF2.F2_SERIE = SE1.E1_PREFIXO "					+ CRLF
	_cQrySE1 += " 		AND SF2.F2_CLIENTE = SE1.E1_CLIENTE "				+ CRLF
	_cQrySE1 += " 		AND SF2.F2_LOJA = SE1.E1_LOJA "						+ CRLF
	_cQrySE1 += " 		AND SF2.F2_EMISSAO = SE1.E1_EMISSAO "				+ CRLF
	_cQrySE1 += " 		AND SF2.F2_PREFORI = SE1.E1_PREFORI "				+ CRLF
	If _cTpCred == '1' //FloorPlan
		_cQrySE1 += " 	AND SF2.F2_COND IN "+ FormatIn(_cPgFP,";") + " "		+ CRLF
	//Else
	//	_cQrySE1 += " AND SF2.F2_COND NOT IN  "+ FormatIn(_cPgNAval,";") + " "			+ CRLF
	EndIf
	_cQrySE1 += " 		AND SF2.D_E_L_E_T_ = ' ' "							+ CRLF 
	_cQrySE1 += " WHERE SE1.D_E_L_E_T_ = ' ' "								+ CRLF  
	_cQrySE1 += " AND SE1.E1_FILIAL 	= '" + FwXFilial("SE1") + "' "		+ CRLF
	_cQrySE1 += " AND SE1.E1_CLIENTE = '" +_cCliFat+"' "					+ CRLF
	_cQrySE1 += " AND SE1.E1_SALDO > 0 "									+ CRLF
	_cQrySE1 += " AND SE1.E1_TIPO NOT IN ('NCC') "							+ CRLF
	_cQrySE1 += " GROUP BY SE1.E1_CLIENTE "									+ CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQrySE1 ), _cAls02SE1, .F., .T. )

	_nValAbe  	:= 0

	dbSelectArea((_cAls02SE1)) 
	(_cAls02SE1)->(dbGoTop())
	If (_cAls02SE1)->(!Eof())

		_nValAbe := (_cAls02SE1)->VAL_SE1

	EndIf

	(_cAls02SE1)->(DbCloseArea())
	
Return(_nValAbe)

/*
=====================================================================================
Programa.:              ZProc020
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              28/07/2022
Descricao / Objetivo:   Verifica os Pedidos Em Bo
Doc. Origem:            
Solicitante:            Faturamento/Pecas
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZProc020(_cCliFat,_cTpCred)
	
	Local _cQryVS1    	:= " "
	Local _cAls01VS1  	:= GetNextAlias()
	Local _nValBO		:= 0
	Local _nRedBO       := SuperGetMV("CMV_PEC035",,100)

	If _nRedBO > 100
		_nRedBO := 100
	endif

	If Select(_cAls01VS1) > 0
		(_cAls01VS1)->(DbCloseArea())
	EndIf

	_cQryVS1 := " "
	_cQryVS1 += " SELECT NVL(SUM(VS1.VS1_VTOTNF),0) AS VAL_VS1 "			+ CRLF
	_cQryVS1 += " FROM " + RetSqlName("VS1") + " VS1 "						+ CRLF
	_cQryVS1 += " WHERE VS1.VS1_FILIAL  = '" + xFilial("VS1") + "' "		+ CRLF
	_cQryVS1 += " AND VS1.VS1_CLIFAT = '" +_cCliFat+"' "					+ CRLF
	_cQryVS1 += " AND VS1.VS1_STATUS IN ('0','3') "							+ CRLF
	//_cQryVS1 += " AND VS1.VS1_XBO = 'S' "									+ CRLF //Solicitado Caoa - Somar todos Orc integrados não enviados St 4 12/2022
	If _cTpCred = '1' //FloorPlan
		_cQryVS1 += " AND VS1.VS1_FORPAG IN "+ FormatIn(_cPgFP,";") + "  "	+ CRLF
	//Else
	//	_cQryVS1 += " AND VS1.VS1_FORPAG NOT IN  "+ FormatIn(_cPgNAval,";") + " "		+ CRLF
	EndIf
	_cQryVS1 += " AND VS1.D_E_L_E_T_ = ' ' "								+ CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQryVS1 ), _cAls01VS1, .F., .T. )
	
	_nValBO		:= 0

	DbSelectArea((_cAls01VS1)) 
	(_cAls01VS1)->(dbGoTop())
	If (_cAls01VS1)->(!Eof())

		_nValBO := (_cAls01VS1)->VAL_VS1 * (_nRedBO / 100)

	EndIf
	(_cAls01VS1)->(DbCloseArea())

Return(_nValBO)

/*
=====================================================================================
Programa.:              ZProc030
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              28/07/2022
Descricao / Objetivo:   Verifica os Pedidos Em Reserva/Em Faturamento/Em Separação
Doc. Origem:            
Solicitante:            Faturamento/Pecas
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZProc030(_cCliFat,_cTpCred)
	
	Local _cQryVS1    	:= " "
	Local _cAls02VS1  	:= GetNextAlias()
	Local _nValPed		:= 0
	
	//Verifica os orçamentos que já consumiram saldo do LimCredito FP
	If Select(_cAls02VS1) > 0
		(_cAls02VS1)->(DbCloseArea())
	EndIf

	/*VS1_STATUS 
	- R Momento da reserva
	- F Pronto para faturar
	- 4 Em separação */

	_cQryVS1 := " "
	_cQryVS1 += " SELECT NVL(SUM(VS1.VS1_VTOTNF),0) AS VAL_VS1 "			+ CRLF
	_cQryVS1 += " FROM " + RetSqlName("VS1") + " VS1 "						+ CRLF
	_cQryVS1 += " WHERE VS1.VS1_FILIAL  = '" + xFilial("VS1") + "' "		+ CRLF
	_cQryVS1 += " AND VS1.VS1_CLIFAT = '" +_cCliFat+"' "					+ CRLF
	_cQryVS1 += " AND VS1.VS1_STATUS IN ('R','F','4') "						+ CRLF
	If _cTpCred = '1' //FloorPlan
		_cQryVS1 += " AND VS1.VS1_FORPAG IN "+ FormatIn(_cPgFP,";") + "  "	+ CRLF
	//Else
	//	_cQryVS1 += " AND VS1.VS1_FORPAG NOT IN  "+ FormatIn(_cPgNAval,";") + " "		+ CRLF
	EndIf
	_cQryVS1 += " AND VS1.D_E_L_E_T_ = ' ' "								+ CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQryVS1 ), _cAls02VS1, .F., .T. )
	
	_nValPed		:= 0
	
	DbSelectArea((_cAls02VS1)) 
	(_cAls02VS1)->(dbGoTop())
	If (_cAls02VS1)->(!Eof())

		_nValPed := (_cAls02VS1)->VAL_VS1

	EndIf

	(_cAls02VS1)->(DbCloseArea())

Return(_nValPed)

/*
=====================================================================================
Programa.:              ZGrvSA1
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              28/07/2022
Descricao / Objetivo:   Grava os Dados do Limite de Crédito na SA1
Doc. Origem:            
Solicitante:            Faturamento/Pecas
Uso......:              
Obs......:
=====================================================================================
*/
Static Function ZGrvSA1(_cCliFat, _cTpCred, _nValAtr, _nValAbe, _nValBo, _nValPed)

	Local _cRet		:= ""
	Local _nSaldo	:= 0
	
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(FwXFilial("SA1") + _cCliFat + "01") )
		If RecLock("SA1",.F.)

			If SA1->A1_XBLQLC == "1" //1 - Bloqueio Manual

				SA1->A1_XSTAFP	:= "5"	
				
				_cRet := "5"

			ElseIf SA1->A1_XBLQLC == "2" //2-Descredenciado. 

				SA1->A1_XTPCRED	:= "0"
				SA1->A1_XLC		:= 0
				SA1->A1_XFPATR	:= 0
				SA1->A1_XLMUSA	:= 0
				SA1->A1_XVALBO	:= 0
				SA1->A1_XPEDFP	:= 0
				SA1->A1_XFPSAL	:= 0
				SA1->A1_XBLQVEN := ""
				SA1->A1_XDTLC	:= CToD("//")
				SA1->A1_XSTAFP	:= "5"	
				
				_cRet := "5"

			ElseIf SA1->A1_XTPCRED == "0" //0-Nao Possui.
			
				SA1->A1_XLC		:= 0
				SA1->A1_XFPSAL	:= 0
				SA1->A1_XDTLC	:= CToD("//")
				SA1->A1_XBLQVEN := ""
				SA1->A1_XSTAFP	:= " "

				_cRet := "2"

			Else
				_nSaldo := ( SA1->A1_XLC - ( _nValAbe + _nValBo + _nValPed ) )
			
				SA1->A1_XFPATR	:= IiF(_nValAtr >= 0, _nValAtr	, 0)
				SA1->A1_XLMUSA	:= IiF(_nValAbe >= 0, _nValAbe	, 0)
				SA1->A1_XVALBO	:= IiF(_nValBo  >= 0, _nValBo	, 0)
				SA1->A1_XPEDFP	:= IiF(_nValPed >= 0, _nValPed	, 0)
				SA1->A1_XFPSAL	:= IiF(_nSaldo  >= 0, _nSaldo	, 0)
				If _nSaldo <= 0
					SA1->A1_XSTAFP := "2" //FALTA DE SALDO
				ElseIf SA1->A1_XDTLC < Date()
					SA1->A1_XSTAFP := "4" //CREDITO VENCIDO
				ElseIf SA1->A1_XFPATR > 0
					If SA1->A1_XBLQVEN == "1" // BLOQUEIA POR ATRASO SOMENTE SE O Bloq.Vencido = "1-SIM"
						SA1->A1_XSTAFP := "3" //TITULOS EM ATRASO
					Else
						SA1->A1_XSTAFP := "1" //CREDITO DISPONIVEL
					EndIf
				Else
					SA1->A1_XSTAFP := "1" //CREDITO DISPONIVEL
				EndIf

				_cRet := SA1->A1_XSTAFP
			EndIf
			SA1->(MsUnlock())
		EndIf
	EndIf

Return(_cRet)
