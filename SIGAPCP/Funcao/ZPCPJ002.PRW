#INCLUDE "PROTHEUS.CH"
#INCLUDE 'XMLXFUN.CH'
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH"
#DEFINE _CEOL CHR(13)+CHR(10)  //final de linha

//#DEFINE CRLF chr(13) + chr(10)  //final de linha


/*---------------------------------------------------------------------------------------
{Protheus.doc} ZPCPJ001
Rdmake 	JOB Processar Importação recebida do MES BackFlushu 
@class    	Nao Informado
@from       Nao Informado
@param      _lJob
@attrib    	Nao Informado
@protected  Nao Informado
@author     Evandro Mariano 
@single		04/05/2022
@version    Nao Informado
@since      Nao Informado  
@return    	Nil
@sample     Nao Informado
@obs         
@project    CAOA - Processo Backflush 4_0
@menu       Nao Informado
@history    

/*/

Static _lJob 	:= .T.

User Function ZPCPJ002() //u_ZPCPJ002()

	Local _lRet 		:= .T.
	Local _lZPCPJ002    := SuperGetMV( "CMV_PCP100"  ,,.T.)  //parametro para habilitar/desabilitar funcionalidade ZPCPF010
	Local _nPos
	Private _aMensErro := {}

	If !_lZPCPJ002
		If !IsBlind()  //interface com o usuário
			MSGInfo( "Não é possivel executar BackFlush, motivo PAUSADO -)","ATENCAO")
		EndIf
	Endif

	If ! IsBlind()  //interface com o usuário
		_lJob := .F.
	Endif

	//Garantir que o processamento seja unico
	If !LockByName("ZPCPJ002",.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 1000 ) // Para o processamento por 1 segundo
			If LockByName("ZPCPJ002",.T.,.T.)
				_lRet := .T.
			EndIf
		Next	

		If !_lRet
			If !_lJob
				MsgInfo("Já existe um processamento em execução rotina ZPCPJ002, aguarde!")
			Else
				ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ002] Já existe um processamento em execução, aguarde!")
				ConOut("*************************************************************************************************************************"	+ CRLF)
				ConOut("------------------------- [ ZPCPJ002 ] - Já existe um processamento em execução rotina ZPCPJ002 -------------------------"  + CRLF)
				ConOut("*************************************************************************************************************************"	+ CRLF)
			EndIf
			Break
		EndIf
	EndIf

	ConOut("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ002] Iniciado processamento Backflush")

	If _lJob
		_lRet := zProc001()
	Else
		Processa({|| _lRet := zProc001()}	,"Processando Backflush, aguarde...")
	Endif
	
	UnLockByName("ZPCPJ002",.T.,.T.)
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ002] Finalizado processamento Backflush")

Return

//-------------------------------------
/*/{Protheus.doc} zProc001
Processar os dados do arquivo Blackflush
@author 	Evandro Mariano
@since 		04/05/2022
@version 	1.0
@obs		Utilizara funcionalidade de recebimento do XML MES para a geração das OPs e outros         
/*/
//-------------------------------------
Static Function zProc001()

Local _lRet 		:= .T.
Local _lAgrupa		:= .F.
Local _cAliasSZE    := GetNextAlias()
Local _cQrySZE		:= ""
Local _cAliasSZZ    := GetNextAlias()
Local _cQrySZZ		:= ""
Local _dDataFechEst := GetMv("MV_ULMES")
Local _dDataBlqEst	:= GetMv("MV_DBLQMOV")
Local _aBackFlush	:= {}
Local _cProdPai		:= ""
Local _cOp			:= ""
Local _cEtapa		:= ""
Local lProcVei		:= .T.
Local lForce		:= .F.
Local _nQtdApont	:= 0
Local nTotReg		:= 0
Local nCont			:= 0
Local _cHoraIni		:= SuperGetMV( "CMV_PCP101"  ,,'06:00')
Local _cHoraFim		:= SuperGetMV( "CMV_PCP102"  ,,'20:00')
Local _cHoraProc	:= ""  //parametro para habilitar/desabilitar funcionalidade ZPCPF010
Local _lPagEmp    	:= SuperGetMV( "CMV_PCP104"  ,,.F.)  //Habilitar/desabilitar a funcionalidade de pagamento de emprestimo Backflush
Local _lManual		:= .F.
Local aRet 			:= {}
Local aParamBox 	:= {}


	//Se o Date() <= MV_ULMES e MV_DBLQMOV ele não executa nada, não executa o JOB e manda um e-mail de erro para os responsáveis.
	If Date() <= _dDataFechEst  
		Aadd(_aMensErro,"PARAMETRO DATA DE FECHAMENTO ESTOQUE MAIOR OU IGUAL A DATA ATUAL, NAO SERA PROCESSADO BACKFLUSH")
		_lRet := .F.
	EndIf

	If Date() <=  _dDataBlqEst	
		Aadd(_aMensErro,"PARAMETRO DATA DE BLOQUEIO FECHAMENTO ESTOQUE (VIRADA DE SALDO) MAIOR OU IGUAL A DATA ATUAL, NAO SERA PROCESSADO BACKFLUSH")
		_lRet := .F.
	EndIf

	_cHoraProc := Substring(Time(),1,5)
	If (_cHoraProc >= _cHoraIni .And. _cHoraProc <= _cHoraFim)
		lProcVei		:= .T.
	Else 
		lProcVei		:= .F.
	EndIf
	
	If _lPagEmp
		If _lJob
			If lProcVei == .F.
				zPagEmpres()
			EndIf
		Else
			If MsgYesNo( "Processar o Pagamento do Emprestimo ? " )
				Processa({|| zPagEmpres() }, "Processando Pgto do Emprestimo...", "Aguarde ...." ) 
			EndIf
		EndIf
	EndIf
	 	
	If _lRet 
		
		If !_lJob
			If MsgYesNo( "Deseja Processar uma OP especifica ? ")
				aAdd(aParamBox,	{1, "Ord.Produção:" , Space(14),"@!",""	,"SC2"	,""	 , 090, .T.}) // Tipo caractere
				If ParamBox(aParamBox,"Informe a OP que deseja Apontar.",@aRet)
    				_cOp 		:= aRet[01]
					_lManual 	:= .T.
					lProcVei 	:= .F.
					lForce 		:= .T.

					SZZ->(dbSetOrder(1))  //ZZ_FILIAL+ZZ_OP+ZZ_PRODUTO+ZZ_LOCAL
					If SZZ->(DbSeek(xFilial('SZZ')+_cOp))
						_cEtapa := SZZ->ZZ_ETAPAPD
					Else
						MsgInfo( "Essa Op não existe para Apontamento","ATENCAO")
						Return(.F.)
					EndIf                                                                                                                             

				EndIf
			Else
				If MsgYesNo( "Processar o Backflush completo? " + CRLF + CRLF + " - (Sim) Processamento completo" + CRLF +" - (Não) Processamento somente veiculos  " )
					lProcVei := .F.
					lForce := .T.
				Else
					lProcVei := .T.
					lForce := .T.
				EndIf
			EndIf
		EndIf
		
		If Select( (_cAliasSZE) ) > 0
			(_cAliasSZE)->(DbCloseArea())
		EndIf

		_cQrySZE := ""
		_cQrySZE += " SELECT * FROM " + RetSQLName('SZE') + " SZE "			+ CRLF
		_cQrySZE += " WHERE SZE.ZE_FILIAL = '" + FWxFilial('SZE') + "' "	+ CRLF
		_cQrySZE += " AND SZE.ZE_MSBLQL = '2' "								+ CRLF
		If lProcVei
			_cQrySZE += " AND SZE.ZE_CODIGO = '000004' "					+ CRLF
		ElseIf _lManual
			_cQrySZE += " AND SZE.ZE_CODIGO = '" + _cEtapa + "' "			+ CRLF
		EndIf
		_cQrySZE += " AND SZE.D_E_L_E_T_ = ' ' "							+ CRLF
		_cQrySZE += " ORDER BY SZE.ZE_SEQ "									+ CRLF

		// Executa a consulta.
		DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQrySZE), _cAliasSZE, .T., .T. )

		DbSelectArea((_cAliasSZE))
		(_cAliasSZE)->(DbGotop())
		If !(_cAliasSZE)->(EOF())
			
			While (_cAliasSZE)->(!EOF())

				If Select( (_cAliasSZZ) ) > 0
					(_cAliasSZZ)->(DbCloseArea())
				EndIf
				
				_cQrySZZ := " "
				_cQrySZZ += " SELECT SZZ.ZZ_OP, SZZ.ZZ_PRODUTO, SZZ.R_E_C_N_O_ AS RECSZZ, SZZ.ZZ_RECURSO, SZZ.ZZ_LOCAL, SZZ.ZZ_QTDEPRD, " 		+ CRLF 
				_cQrySZZ +=	" 		 SZZ.ZZ_IDMES, SZZ.ZZ_CHASSI, SZZ.ZZ_NUMMOT, SZZ.ZZ_FABMOD FROM " + RetSQLName('SZZ') + " SZZ "				+ CRLF
				_cQrySZZ += " WHERE SZZ.ZZ_FILIAL = '" + FWxFilial('SZZ') + "' "																+ CRLF
				_cQrySZZ += " AND SZZ.ZZ_ETAPAPD = '" + (_cAliasSZE)->ZE_CODIGO + "' "															+ CRLF
				If _lManual
					_cQrySZZ += " AND SZZ.ZZ_OP = '" + _cOp + "' "																			+ CRLF
				EndIf
				_cQrySZZ += " AND SZZ.ZZ_STATUS IN (' ','E') "																					+ CRLF
				_cQrySZZ += " AND SZZ.D_E_L_E_T_ = ' ' "																						+ CRLF
				_cQrySZZ += " ORDER BY SZZ.ZZ_OP, SZZ.ZZ_PRODUTO, SZZ.R_E_C_N_O_ "  															+ CRLF
		
				// Executa a consulta.
				DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQrySZZ), _cAliasSZZ, .T., .T. )
	
				If !_lJob
					nTotReg := Contar(_cAliasSZZ,"!Eof()")
					ProcRegua(nTotReg)
					nCont := 1
				EndIf

				DbSelectArea((_cAliasSZZ))
				(_cAliasSZZ)->(DbGotop())
				If !(_cAliasSZZ)->(EOF())
					
					//--Reinicializa variaveis
					_cOp		:= (_cAliasSZZ)->ZZ_OP
					_cProdPai 	:= (_cAliasSZZ)->ZZ_PRODUTO
					_nQtdApont	:= 0
					_lAgrupa	:= .F.
					_aBackFlush	:= {}

					While (_cAliasSZZ)->(!EOF())

						// Roda Bacluflush
						// Durante o dia e veiculos: (_cHoraProc >= _cHoraIni .And. _cHoraProc <= _cHoraFim) .And. lProcVei == .T.)
						// Depois do horario e todas as etapas: (!(_cHoraProc >= _cHoraIni .And. _cHoraProc <= _cHoraFim) .And. lProcVei == .F.)
						// Forcando o reprocessamento: lForce == .T.
						_cHoraProc := Substring(Time(),1,5)
						If ((_cHoraProc >= _cHoraIni .And. _cHoraProc <= _cHoraFim) .And. lProcVei == .T.) .Or. (!(_cHoraProc >= _cHoraIni .And. _cHoraProc <= _cHoraFim) .And. lProcVei == .F.) .Or. lForce == .T.	

							If !_lJob
								IncProc("Etapa: "+AllTrim((_cAliasSZE)->ZE_CODIGO)+" - OP: "+AllTrim(_cOp)+ CRLF +" Registro: " + cValToChar(nCont) + " de " + cValToChar(nTotReg) )
							EndIf

							_lRet := .T. //--Reinicializa variavel
													
							AADD(_aBackFlush,{	(_cAliasSZZ)->RECSZZ		,;
												(_cAliasSZE)->ZE_AGRUPA		,;
												(_cAliasSZZ)->ZZ_OP			,;
												(_cAliasSZZ)->ZZ_PRODUTO	,;
												(_cAliasSZZ)->ZZ_LOCAL		,;
												(_cAliasSZZ)->ZZ_CHASSI		,;
												(_cAliasSZZ)->ZZ_NUMMOT		,;
												(_cAliasSZZ)->ZZ_FABMOD		,;
												(_cAliasSZZ)->ZZ_QTDEPRD	,;
												(_cAliasSZZ)->ZZ_RECURSO	,;
												(_cAliasSZZ)->ZZ_IDMES	})

							_nQtdApont := ( _nQtdApont + (_cAliasSZZ)->ZZ_QTDEPRD )
							
							_cOp		:= (_cAliasSZZ)->ZZ_OP
							_cProdPai 	:= (_cAliasSZZ)->ZZ_PRODUTO
							_lAgrupa	:= IiF( (_cAliasSZE)->ZE_AGRUPA == "1",.F.,.T.)	

							(_cAliasSZZ)->(DbSkip())
							nCont++

							If ( _cOp <> (_cAliasSZZ)->ZZ_OP ) .Or. ( _cProdPai <> (_cAliasSZZ)->ZZ_PRODUTO ) .Or. ( _lAgrupa == .T.)

								_lRet 	:= .T. 
								If Len(_aBackFlush) > 0

									//Valida se a OP é valida antes de realizar o apontamento.
									_lRet := zValidOP(_aBackFlush[01][03], _aBackFlush[01][05], _aBackFlush[01][04], _nQtdApont)

									If _lRet
																					
										If _lRet

											_lRet := zProcEmpr(_aBackFlush[01][03],_nQtdApont, _aBackFlush[01][04])

											If _lRet
					
												If (_cAliasSZE)->ZE_CODIGO == '000004' //Quando veiculo, envia dados adicionais para apontamento.
													_lRet := zProcApont( _aBackFlush[01][03],_aBackFlush[01][04],_aBackFlush[01][10],_nQtdApont	, _aBackFlush[01][11], _aBackFlush[01][06], _aBackFlush[01][07], _aBackFlush[01][08], _aBackFlush)
												Else
													_lRet := zProcApont( _aBackFlush[01][03],_aBackFlush[01][04],_aBackFlush[01][10],_nQtdApont	, , , ,	,_aBackFlush )
												EndIf
												If !_lRet
													ZGRVSZZ(_aMensErro, "E", _aBackFlush, _nQtdApont)	//--Grava log na tabela SZZ
												EndIf
					
											EndIf

										EndIf
									Else

										ZGRVSZZ(_aMensErro, "E", _aBackFlush, _nQtdApont)	//--Grava log na tabela SZZ

									EndIf
										
								EndIf

								_nQtdApont	:= 0
								_lAgrupa	:= .F.
								_aBackFlush	:= {}
							EndIf
						EndIf
					EndDo
					(_cAliasSZZ)->(DbCloseArea())
					
				EndIf

				(_cAliasSZE)->(DbSkip())
			
			EndDo	

		Else
			If !(_lJob)
				MSGInfo( "Não existem dados para processar","ATENCAO")
			EndIf	
		EndIf
		(_cAliasSZE)->(DbCloseArea())

	EndIf

Return(_lRet)

//-------------------------------------
/*/{Protheus.doc} zValidOP
Valida se a op é valida para apontamento.
@author 	Evandro Mariano
@since 		04/05/2022
@version 	1.0
@obs		         
/*/
Static Function zValidOP(_cOp, _cLocal, _cCodProd, _nQtdeOP )

Local _lRet := .T.

//Posiciono a OP referencia
	SC2->(dbSetOrder(1))  //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
	If !SC2->(DbSeek(xFilial('SC2')+_cOp))
		Aadd(_aMensErro,"Ordem de Producao nao encontrada")
		_lRet := .F.
	Else
		//Esta encerrada
		If !Empty(SC2->C2_DATRF)
			Aadd(_aMensErro,"OP esta Encerrada")
			_lRet := .F.
		Else
			//Caso não seja Firme não validar
			If SC2->C2_TPOP <> "F"
				Aadd(_aMensErro,"OP nao esta firmada")
				_lRet := .F.
			Else
				//Local OP
    			If SC2->C2_LOCAL <> _cLocal 
					Aadd(_aMensErro,"OP divergente do local de apontamento")
					_lRet := .F.
				EndIf
				
				//Produto na OP
				If AllTrim(SC2->C2_PRODUTO) <> AllTrim(_cCodProd)
					Aadd(_aMensErro,"Produto apontado diverente do produto da OP.")
					_lRet := .F.
				EndIf

				//Validar a quantidade
				If SC2->C2_QUJE >= SC2->C2_QUANT 
					Aadd(_aMensErro,"Quantidade apontada da OP " +AllTrim(STR(SC2->C2_QUJE))+;
									" Quantidade Original da OP "+AllTrim(STR(SC2->C2_QUANT))+;
									" Saldo da OP "+AllTrim(STR(SC2->C2_QUANT-SC2->C2_QUJE)))
					_lRet := .F.											
				EndIf
				
				//Validar na quantidade acumulada verificar se tem saldo	
				If (SC2->C2_QUJE + _nQtdeOP ) > SC2->C2_QUANT
					Aadd(_aMensErro,"Quantidade apontada da OP " +AllTrim(STR(SC2->C2_QUJE))+;
									" Quantidade pendente BackFlush " +AllTrim(STR(_nQtdeOP))+;
									" Quantidade Original da OP "+AllTrim(STR(SC2->C2_QUANT))+;
									" Saldo da OP "+AllTrim(STR((SC2->C2_QUJE+_nQtdeOP+SZZ->ZZ_QTDEPRD)-SC2->C2_QUANT)))
					_lRet := .F.
				EndIf
			Endif
		Endif
	EndIf

Return(_lRet)

//-------------------------------------
/*/{Protheus.doc} zProcEmpr
Verifica a necessidade do emprestimo para aquela ordem de produção
@author 	Evandro Mariano
@since 		04/05/2022
@version 	1.0
@obs		         
/*/
Static Function zProcEmpr(_cOp, _nQtdApont, _cProdPai)

	Local _lRet			:= .T.
	Local _cAlias   	:= GetNextAlias()
	Local _cQry			:= ""
	Local _cServWMS		:= "205"
	Local _cDocSD3		:= " "
	Local _aCab			:= {}
	Local _aItem 		:= {}
	Local _atotitem		:= {}
	Local _cTexto		:= ""
	Local _lCtrlWMS 	:= .F.
	Local _dDtValid		:= CTOD("  /  /  ")
	Local _aError
	Local _nPos
	
	Private __cTm			:= "007"
	Private lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
	//Private lMsHelpAuto 	:= .T.  // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
	Private lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog
	
	If Select( (_cAlias) ) > 0
		(_cAlias)->(DbCloseArea())
	EndIf

	SB1->(DbSetOrder(1))

	_cQry := ""
	_cQry += " SELECT 	TMP.OP, " + CRLF
	_cQry += "			TMP.FILHO_PRODUTO, " + CRLF
	_cQry += " 			TMP.FILHO_WMS, " + CRLF
	_cQry += " 			TMP.FILHO_UM, " + CRLF
	_cQry += " 			TMP.FILHO_LOCAL, " + CRLF
	_cQry += "			TMP.FILHO_LOTE,  " + CRLF
	_cQry += " 		CASE  " + CRLF
	_cQry += " 			WHEN RTRIM(TMP.FILHO_WMS) = '1' THEN ( NVL((NVL(( TMP.FILHO_QTDE_OP / TMP.PAI_QTDE_OP ),0) * " + AllTrim(Str(_nQtdApont)) + "),0) ) - ( NVL(( TMP.FILHO_SALDO_D14 ),0) )  " + CRLF
	_cQry += " 		    WHEN RTRIM(TMP.FILHO_WMS) = '2' THEN ( NVL((NVL(( TMP.FILHO_QTDE_OP / TMP.PAI_QTDE_OP ),0) * " + AllTrim(Str(_nQtdApont)) + "),0) ) - ( NVL(( TMP.FILHO_SALDO_SB2 ),0) ) " + CRLF
	_cQry += " 		ELSE " + CRLF
	_cQry += " 			0 " + CRLF
	_cQry += " 		END 																AS FILHO_AJUSTE  " + CRLF
	_cQry += " FROM ( " + CRLF
	_cQry += " 	    SELECT 	SD4.D4_OP															AS OP, " + CRLF
	_cQry += " 				SC2.C2_PRODUTO 														AS PAI_PRODUTO, " + CRLF
	_cQry += " 				NVL(SC2.C2_QUANT,0)                                                 AS PAI_QTDE_OP, " + CRLF
	_cQry += " 		        NVL(( SC2.C2_QUANT - SC2.C2_QUJE ),0)                               AS PAI_SALDO_OP, " + CRLF
	_cQry += " 		        SD4.D4_COD                                                          AS FILHO_PRODUTO, " + CRLF
	_cQry += " 		        SB1.B1_TIPO 														AS FILHO_TIPO, " + CRLF
	_cQry += " 		        SB1.B1_RASTRO 														AS FILHO_LOTE, " + CRLF
	_cQry += " 		        SB1.B1_UM 															AS FILHO_UM, " + CRLF
	_cQry += " 		        RTRIM(LTRIM(NVL(SB5.B5_CTRWMS,'2')))								AS FILHO_WMS, " + CRLF
	_cQry += " 		        SD4.D4_LOCAL                                                        AS FILHO_LOCAL, " + CRLF
	_cQry += " 		        SD4.D4_QTDEORI														AS FILHO_QTDE_OP, " + CRLF
	_cQry += " 		        NVL(( SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QACLASS ),0)            AS FILHO_SALDO_SB2, " + CRLF
	_cQry += " 		        CASE  " + CRLF
	_cQry += " 	        		WHEN SB5.B5_CTRWMS = '1' THEN NVL(( SELECT SUM(D14_QTDEST) FROM " + RetSQLName('D14') + " D14 WHERE D14.D14_FILIAL = '" + FWxFilial('D14') + "' AND D14.D14_LOCAL = 'PRD' AND D14.D14_PRODUT = SD4.D4_COD AND D14_ENDER IN (	SELECT SBE.BE_LOCALIZ FROM " + RetSQLName('SBE') + " SBE WHERE SBE.BE_FILIAL = D14.D14_FILIAL AND SBE.BE_ESTFIS IN ( SELECT DC8.DC8_CODEST FROM " + RetSQLName('DC8') + " DC8	WHERE DC8.DC8_FILIAL = SBE.BE_FILIAL AND DC8.DC8_TPESTR = '7') AND SBE.BE_LOCAL = D14.D14_LOCAL	AND SBE.D_E_L_E_T_ = ' '	) AND D14.D_E_L_E_T_ = ' '  ),0) " + CRLF
	_cQry += " 		            WHEN SB5.B5_CTRWMS = '2' THEN 0 " + CRLF
	_cQry += " 		        ELSE " + CRLF
	_cQry += " 					0 " + CRLF
	_cQry += " 		        END 																AS FILHO_SALDO_D14,             " + CRLF
	_cQry += " 		        NVL((NVL(( SD4.D4_QTDEORI / SC2.C2_QUANT ),0) * " + AllTrim(Str(_nQtdApont)) + " ),0)    		AS FILHO_NECESSIDADE  " + CRLF
	_cQry += " 	    FROM " + RetSQLName('SC2') + " SC2 " + CRLF
	_cQry += " 	    	LEFT JOIN " + RetSQLName('SD4') + " SD4  " + CRLF
	_cQry += " 			    ON SD4.D4_FILIAL 	= SC2.C2_FILIAL " + CRLF
	_cQry += " 			    AND SD4.D4_OP 		= SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN " + CRLF
	_cQry += " 			    AND SD4.D4_PRODUTO 	= SC2.C2_PRODUTO " + CRLF
	_cQry += " 				AND SD4.D_E_L_E_T_	= ' ' " + CRLF
	_cQry += " 			INNER JOIN " + RetSQLName('SB1') + " SB1  " + CRLF
	_cQry += " 			    ON SB1.B1_FILIAL 	= '" + FWxFilial('SB1') + "' " + CRLF
	_cQry += " 			    AND SB1.B1_COD		= SD4.D4_COD " + CRLF
	_cQry += " 				AND SB1.B1_MSBLQL 	= '2' " + CRLF
	_cQry += " 			    AND SB1.B1_TIPO IN ('MP','PI') " + CRLF
	_cQry += " 				AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " 			LEFT JOIN " + RetSQLName('SB5') + " SB5  " + CRLF
	_cQry += " 				ON SB5.B5_FILIAL 	= SB1.B1_FILIAL  " + CRLF
	_cQry += " 			    AND SB5.B5_COD		= SB1.B1_COD  " + CRLF
	_cQry += " 				AND SB5.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " 			LEFT JOIN " + RetSQLName('SB2') + " SB2  " + CRLF
	_cQry += " 			    ON SB2.B2_FILIAL 	= SD4.D4_FILIAL " + CRLF
	_cQry += " 				AND SB2.B2_COD		= SD4.D4_COD " + CRLF
	_cQry += " 			    AND SB2.B2_LOCAL	= SD4.D4_LOCAL " + CRLF
	_cQry += " 			    AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " 	    WHERE SC2.C2_FILIAL = '" + FWxFilial('SC2') + "' " + CRLF
	_cQry += " 	    AND SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN = '" + _cOp + "' " + CRLF
	_cQry += " 		AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " 	    ORDER BY SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_PRODUTO " + CRLF
	_cQry += " 	) TMP " + CRLF
	_cQry += " WHERE ( TMP.FILHO_WMS = '1' AND TMP.FILHO_SALDO_D14 < FILHO_NECESSIDADE ) OR ( TMP.FILHO_WMS = '2' AND TMP.FILHO_SALDO_SB2 < FILHO_NECESSIDADE ) " + CRLF
	_cQry += " ORDER BY TMP.FILHO_PRODUTO " + CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQry), _cAlias, .T., .T. )

	DbSelectArea((_cAlias))
	(_cAlias)->(DbGotop())
	If !(_cAlias)->(EOF())

		Begin Transaction

			DbSelectArea("SD3")

			_cDocSD3 	:= NextNumero("SD3",2,"D3_DOC",.T.)
			_cOp		:= (_cAlias)->OP 		

			_aCab	:= {}
			_aCab 	:= {	{ "D3_DOC" 		, _cDocSD3		, NIL},;
        					{ "D3_TM" 		, __cTm			, NIL},;
        					{ "D3_EMISSAO" 	, dDataBase		, NIL}}

			While (_cAlias)->(!EOF())

				If SB1->(DbSeek(XFilial("SB1")+(_cAlias)->FILHO_PRODUTO))  //posicionar o SB1

					If AllTrim((_cAlias)->FILHO_WMS) == "1"
						_cServWMS := "205"
						_lCtrlWMS := .T.
					Else 
						_cServWMS := ""
					EndIf

					If AllTrim((_cAlias)->FILHO_LOTE) == "L"
						_dDtValid := DDatabase + 365
					Else 
						_dDtValid := CTOD("  /  /  ")
					EndIf

					_aItem	:= {}
					_aItem	:= {	{ "D3_COD" 		, (_cAlias)->FILHO_PRODUTO 				,NIL},;
									{ "D3_UM" 		, (_cAlias)->FILHO_UM 					,NIL},; 
									{ "D3_QUANT" 	, Ceiling((_cAlias)->FILHO_AJUSTE)		,NIL},;
									{ "D3_CONTA" 	, SB1->B1_CONTA 						,NIL},;
									{ "D3_LOCAL" 	, (_cAlias)->FILHO_LOCAL 				,NIL},;
									{ "D3_GRUPO" 	, SB1->B1_GRUPO 						,NIL},;
									{ "D3_LOTECTL" 	, CriaVar("D3_LOTECTL")					,NIL},;
									{ "D3_DTVALID" 	, _dDtValid								,NIL},;
									{ "D3_LOCALIZ" 	, CriaVar("D3_LOCALIZ")					,NIL},;
									{ "D3_SERVIC" 	, _cServWMS								,NIL}}

					aAdd(_atotitem,_aitem)
					
				EndIf
		
				(_cAlias)->(DbSkip())
			EndDo

			//Realiza a requisicao do material perdido ou utilizado a mais que a estrutura para a Ordem de Producao
			If _lJob
				MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab,_atotitem,3)
			Else
				MsAguarde({|| MSExecAuto({|x,y,z| mata241(x,y,z)},_aCab,_atotitem,3) },"Incluindo...") //Inclusao
			EndIf
			

			If lMsErroAuto
				_aError := GetAutoGRLog()
				For _nPos := 1 To Len(_aError)
					If !Empty((AllTrim(_aError[_nPos])))  	
						_cTexto	+= 	Upper(AllTrim(_aError[_nPos])) + CRLF
						Aadd(_aMensErro,_cTexto)
					EndIf		
				Next _nPos		
				_lRet := .F.	
				DisarmTransaction()			 	
			EndIf	

		End Transaction	

		If _lRet 

			// Adiciona o emprestimo no controle de emprestimo.
			// Altera o Endereço de Destino para itens que controlam WMS na DCF.
			_lRet := zGrvSZI(_cOp, _cDocSD3, _cProdPai,_lCtrlWMS )

		EndIf


	EndIf
	(_cAlias)->(DbCloseArea())

Return(_lRet)

//-------------------------------------
/*/{Protheus.doc} zProcApont
Realiza o apontamento de Produção.
@author 	Evandro Mariano
@since 		04/05/2022
@version 	1.0
@obs		         
/*/
Static Function zProcApont(_cOP, _cProduto, _cRecurso, _nQtdeOP, cIDMes, cChassi, cNumMotor, cFabMod, _aBackFlush)

	Local _lRet			:= .T.
	Local _aMata681		:= {}
	Local _aError		:= {}
	Local _cOperac		:= "01"
	Local _cTipoPRD		:= ""
	Local _cTexto		:= ""	
	Local _nPos
	Local cUpdate 		:= ""

	Default	cIDMes		:= ""
	Default	cChassi		:= ""
	Default	cNumMotor	:= ""
	Default	cFabMod		:= ""

	Private lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
	//Private lMsHelpAuto 	:= .T.  // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
	Private lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog

	//limpa a reserva e qaclass.
	cUpdate :=  " "
	cUpdate +=  " UPDATE " + RetSqlName("SB2")              						+ CRLF
	cUpdate	+=  " SET B2_QACLASS = 0, B2_RESERVA = 0, B2_QEMP = 0 "					+ CRLF
	cUpdate +=  " WHERE B2_FILIAL = '" + FWxFilial("SB2") + "'"						+ CRLF    
	cUpdate +=  " AND B2_LOCAL = 'PRD' "				     						+ CRLF
	cUpdate +=  " AND ( B2_QACLASS <> 0  OR B2_RESERVA <> 0  OR B2_QEMP <> 0 ) "	+ CRLF
	cUpdate +=  " AND D_E_L_E_T_ = ' ' "                        					+ CRLF

	TcSqlExec(cUpdate)

	//limpa a reserva e qaclass.
	cUpdate :=  " "
	cUpdate +=  " UPDATE " + RetSqlName("SB8")              						+ CRLF
	cUpdate	+=  " SET B8_QACLASS = 0, B8_EMPENHO = 0 "								+ CRLF
	cUpdate +=  " WHERE B8_FILIAL = '" + FWxFilial("SB8") + "'"						+ CRLF    
	cUpdate +=  " AND B8_LOCAL = 'PRD' "				     						+ CRLF
	cUpdate +=  " AND ( B8_QACLASS <> 0 OR B8_EMPENHO <> 0 ) "						+ CRLF
	cUpdate +=  " AND D_E_L_E_T_ = ' ' "                        					+ CRLF

	TcSqlExec(cUpdate)
		
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ002] Trace001 - Inicio - Apontamento Producao - MATA681 - OP: "+Alltrim(_cOP)+".")

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+_cProduto))  //posicionar o SB1

		Begin Transaction

			_cTipoPRD := SB1->B1_TIPO

			SZZ->(DbGoto(_aBackFlush[01][01]))
			//Verificar se ja envia chassi, motor, ano, idmes
			Aadd(_aMata681 ,	{"H6_OP"	  	,_cOP  				,NIL})
			Aadd(_aMata681 ,	{"H6_PRODUTO" 	,_cProduto			,NIL})
			Aadd(_aMata681 ,	{"H6_OPERAC" 	,_cOperac			,NIL})
			Aadd(_aMata681 ,	{"H6_RECURSO" 	,_cRecurso			,NIL})
			Aadd(_aMata681 ,	{"H6_DTAPONT"  	,Date()				,NIL})  //SZZ->ZZ_DTINTEG
			Aadd(_aMata681 ,	{"H6_DATAINI"  	,Date() 			,NIL})  //SZZ->ZZ_HRINTEG
			Aadd(_aMata681 ,	{"H6_DATAFIN"	,Date() 			,NIL})
			Aadd(_aMata681 ,	{"H6_PT"     	,SZZ->ZZ_TP			,NIL})
			Aadd(_aMata681 ,	{"H6_LOCAL"  	,SZZ->ZZ_LOCAL		,NIL})
			Aadd(_aMata681 ,	{"H6_QTDPROD"	,_nQtdeOP  			,NIL})

			If !Empty(cChassi) //--Veiculo
				Aadd(_aMata681 ,	{"H6_XIDMES"    ,cIDMes		,NIL})
				Aadd(_aMata681 ,	{"H6_XCHASSI"  	,cChassi	,NIL})
				Aadd(_aMata681 ,	{"H6_XMOTOR"	,cNumMotor	,NIL})      
				Aadd(_aMata681 ,	{"H6_XANOMOD"	,cFabMod	,NIL}) 
			EndIf

			Aadd(_aMata681 ,	{"H6_OBSERVA"	,"TOTVSMES"  		,NIL})      
		
			MSExecAuto({|x| Mata681(x)},_aMata681)  // inclusão

			If lMsErroAuto
				_aError := GetAutoGRLog()
				For _nPos := 1 To Len(_aError)
					If !Empty((AllTrim(_aError[_nPos])))  	
						_cTexto	+= 	AllTrim(_aError[_nPos]) + CRLF
						Aadd(_aMensErro,_cTexto)
					EndIf		
				Next _nPos	
				_lRet := .F.	
				DisarmTransaction()			
			Else
				CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ002] Trace001 - FIM - Apontamento Producao - MATA681 - OP: "+Alltrim(_cOP)+".")
			EndIf	
		End Transaction
		
	EndIf

	If _lRet
		ZGRVSZZ( , "A", _aBackFlush, _nQtdeOP, SD3->D3_NUMSEQ )	//--Grava log na tabela SZZ
	EndIf

Return _lRet

//-------------------------------------
/*/{Protheus.doc} zProcApont
Grava os emprestimos.
@author 	Evandro Mariano
@since 		04/05/2022
@version 	1.0
@obs		         
/*/
Static Function	zGrvSZI(_cOp, _cDocSD3, _cProdPai,_lCtrlWMS)
	Local _lRet 	:= .T.
	Local _cQry		:= .F.
	Local _cAlias	:= GetNextAlias()
	Local _cQrySZI	:= .F.
	Local _cAlsSZI	:= GetNextAlias()

	If Select( (_cAlias) ) > 0
		(_cAlias)->(DbCloseArea())
	EndIf

	If _lCtrlWMS
		_lRet := zUpdDCF(_cDocSD3, "205") 
		_lRet := zFinOSWms( _cDocSD3, "205" )
	EndIf

	If _lRet
		_cQry := ""
		_cQry += " SELECT D3_COD, D3_LOCAL, D3_QUANT  FROM " + RetSQLName('SD3') + " SD3  " + CRLF
		_cQry += " WHERE SD3.D3_FILIAL = '" + FWxFilial('SD3') + "' " + CRLF
		_cQry += " AND SD3.D3_DOC = '" + _cDocSD3 + "' " + CRLF
		_cQry += " AND SD3.D3_EMISSAO = '" + DToS(dDataBase) + "' " + CRLF
		_cQry += " AND SD3.D3_TM = '" + __cTm + "' " + CRLF
		_cQry += " AND SD3.D_E_L_E_T_ = ' ' " + CRLF
		_cQry += " ORDER BY SD3.D3_DOC, SD3.D3_COD " + CRLF

		DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQry), _cAlias, .T., .T. )

		DbSelectArea((_cAlias))
		(_cAlias)->(DbGotop())
		While (_cAlias)->(!EOF())

			If Select( (_cAlsSZI) ) > 0
				(_cAlsSZI)->(DbCloseArea())
			EndIf

			_cQrySZI := ""
			_cQrySZI += " SELECT SZI.R_E_C_N_O_ AS RECSZI FROM " + RetSQLName('SZI') + " SZI  		" + CRLF
			_cQrySZI += " WHERE SZI.ZI_FILIAL = '" + FWxFilial('SZI') + "' 							" + CRLF
			_cQrySZI += " AND SZI.ZI_CODPRD = '" + (_cAlias)->D3_COD + "' 							" + CRLF
			_cQrySZI += " AND SZI.ZI_LOCAL = '" + (_cAlias)->D3_LOCAL + "' 							" + CRLF
			_cQrySZI += " AND SZI.D_E_L_E_T_ = ' ' 													" + CRLF

			DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQrySZI), _cAlsSZI, .T., .T. )

			DbSelectArea((_cAlsSZI))
			(_cAlsSZI)->(DbGotop())
			If (_cAlsSZI)->(!EOF())
						
				SZI->( DbGoTo( (_cAlsSZI)->RECSZI ) )
				SZI->(RecLock('SZI', .F. ))
					SZI->ZI_QTDEMPR	:= ( SZI->ZI_QTDEMPR + (_cAlias)->D3_QUANT )
				SZI->(MsUnlock())

			Else
				
				SZI->(RecLock('SZI', .T. ))
					SZI->ZI_FILIAL 		:= 	XFilial("SZI")
					SZI->ZI_CODPRD 		:= (_cAlias)->D3_COD
					SZI->ZI_LOCAL  		:= (_cAlias)->D3_LOCAL
					SZI->ZI_QTDEMPR		:= (_cAlias)->D3_QUANT
				SZI->(MsUnlock())

			EndIf
			(_cAlias)->(DbSkip())
		EndDo
		(_cAlias)->(DbCloseArea())
	EndIf

Return _lRet

/*
=====================================================================================
Programa.:              zPagEmpres
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              22/08/22
Descricao / Objetivo:   Verifica se tem saldo para pagamento de emprestimo backflush          
=====================================================================================
*/
Static Function zPagEmpres()
	Local _lRet 		:= .T.
	Local _cAlias   	:= GetNextAlias()
	Local _cQry			:= ""
	Local _cServWMS		:= "207"
	Local _cDocSD3		:= " "
	Local _aCab			:= {}
	Local _aItem 		:= {}
	Local _atotitem		:= {}
	Local _lCtrlWMS 	:= .F.
	Local _nQtdPgto		:= 0
	Local nTotReg 		:= 0
	Local nCont			:= 0
	Local cUpdate		:= ""
		
	Private __cTm			:= "556"

	SB1->( DbSetOrder(1) )

	_cQry += " SELECT 	ZI_FILIAL, " + CRLF
	_cQry += " 		ZI_CODPRD, " + CRLF
	_cQry += " 		ZI_LOCAL, " + CRLF
	_cQry += " 		B1_RASTRO, " + CRLF
	_cQry += " 		CASE  											" + CRLF
	_cQry += " 			WHEN SB5.B5_CTRWMS = '1' THEN SB5.B5_CTRWMS " + CRLF
	_cQry += " 		ELSE 											" + CRLF
	_cQry += " 			'2' 										" + CRLF
	_cQry += " 		END	AS WMS, 									" + CRLF
	_cQry += " 		ZI_QTDEMPR, " + CRLF
	_cQry += " 		ZI_QTDPGEM, " + CRLF
	_cQry += " 		( ZI_QTDEMPR - ZI_QTDPGEM ) AS SALDO_PAGAR," + CRLF
	_cQry += " 		( SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QACLASS ) AS SALDO_SB2," + CRLF
	_cQry += " 		CASE  " + CRLF
	_cQry += " 			WHEN SB5.B5_CTRWMS = '1' THEN NVL( ( SELECT SUM(D14_QTDEST) " + CRLF
	_cQry += " 								 FROM " + RetSQLName('D14') + " D14 " + CRLF
	_cQry += " 								 WHERE D14.D14_FILIAL = '" + FWxFilial('D14') + "'" + CRLF
	_cQry += " 	 								AND D14.D14_LOCAL = SZI.ZI_LOCAL" + CRLF
	_cQry += " 	 								AND D14.D14_PRODUT = SZI.ZI_CODPRD " + CRLF
	_cQry += " 	 								AND D14_ENDER IN ( 	SELECT SBE.BE_LOCALIZ " + CRLF
	_cQry += " 													   	FROM " + RetSQLName('SBE') + " SBE " + CRLF
	_cQry += " 														WHERE SBE.BE_FILIAL = D14.D14_FILIAL 	" + CRLF
	_cQry += " 															AND SBE.BE_ESTFIS IN (	SELECT DC8.DC8_CODEST 	" + CRLF
	_cQry += " 																					FROM " + RetSQLName('DC8') + " DC8 		" + CRLF
	_cQry += " 																					WHERE DC8.DC8_FILIAL = SBE.BE_FILIAL 	" + CRLF
	_cQry += " 																						AND DC8.DC8_TPESTR = '7') 	" + CRLF
	_cQry += " 																						AND SBE.BE_LOCAL = D14.D14_LOCAL 		" + CRLF
	_cQry += " 																						AND SBE.D_E_L_E_T_ = ' '	) 	" + CRLF
	_cQry += " 									AND D14.D_E_L_E_T_ = ' '  ),0) 		" + CRLF
	_cQry += " 			WHEN SB5.B5_CTRWMS = '2' THEN 0 " + CRLF
	_cQry += " 		ELSE " + CRLF
	_cQry += " 			0 " + CRLF
	_cQry += " 		END	AS SALDO_D14," + CRLF
	_cQry += " 		CASE  " + CRLF
	_cQry += " 			WHEN SB1.B1_RASTRO = 'L' THEN NVL( ( SELECT (SUM(B8_SALDO) - SUM(B8_EMPENHO))  FROM " + RetSQLName('SB8') + " SB8" + CRLF
	_cQry += " 													WHERE SB8.D_E_L_E_T_ = ' '" + CRLF
	_cQry += " 													AND SB8.B8_PRODUTO = SZI.ZI_CODPRD" + CRLF
	_cQry += " 													AND SB8.B8_SALDO > 0" + CRLF
	_cQry += " 													AND (SB8.B8_LOCAL, SB8.B8_LOTECTL) IN (	SELECT D14_LOCAL, D14_LOTECT FROM " + RetSQLName('D14') + " D14 " + CRLF
	_cQry += " 																					 WHERE D14.D14_FILIAL = '" + FWxFilial('D14') + "' " + CRLF
	_cQry += " 																						AND D14.D14_LOCAL = SZI.ZI_LOCAL " + CRLF
	_cQry += " 																						AND D14.D14_PRODUT = SZI.ZI_CODPRD" + CRLF
	_cQry += " 																						AND D14_ENDER IN ( 	SELECT SBE.BE_LOCALIZ " + CRLF
	_cQry += " 																										   	FROM " + RetSQLName('SBE') + " SBE " + CRLF
	_cQry += " 																											WHERE SBE.BE_FILIAL = D14.D14_FILIAL 	" + CRLF
	_cQry += " 																												AND SBE.BE_ESTFIS IN (	SELECT DC8.DC8_CODEST 	" + CRLF
	_cQry += " 																																		FROM " + RetSQLName('DC8') + " DC8 		" + CRLF
	_cQry += " 																																		WHERE DC8.DC8_FILIAL = SBE.BE_FILIAL 	" + CRLF
	_cQry += " 																																			AND DC8.DC8_TPESTR = '7') 	" + CRLF
	_cQry += " 																																			AND SBE.BE_LOCAL = D14.D14_LOCAL 		" + CRLF
	_cQry += " 																																			AND SBE.D_E_L_E_T_ = ' ') )  ),0) 		" + CRLF
	_cQry += " 			WHEN SB1.B1_RASTRO <> 'L' THEN 0 " + CRLF
	_cQry += " 		ELSE " + CRLF
	_cQry += " 			0 " + CRLF
	_cQry += " 		END	AS SALDO_SB8" + CRLF
	_cQry += " FROM " + RetSQLName('SZI') + " SZI" + CRLF
	_cQry += " 	INNER JOIN ABDHDU_PROT.SB1010 SB1 " + CRLF
	_cQry += " 		ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' " + CRLF
	_cQry += " 		AND SB1.B1_COD = SZI.ZI_CODPRD	" + CRLF
	_cQry += " 		AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " 	INNER JOIN " + RetSQLName('SB2') + " SB2 " + CRLF
	_cQry += " 		ON SB2.B2_FILIAL = '" + FWxFilial('SB2') + "'" + CRLF
	_cQry += " 		AND SB2.B2_COD = SB1.B1_COD" + CRLF
	_cQry += " 		AND SB2.B2_LOCAL = SZI.ZI_LOCAL	" + CRLF
	_cQry += " 		AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " 	LEFT JOIN " + RetSQLName('SB5') + " SB5 " + CRLF
	_cQry += " 		ON SB5.B5_FILIAL = SB1.B1_FILIAL " + CRLF
	_cQry += " 		AND SB5.B5_COD = SB1.B1_COD " + CRLF
	_cQry += " 		AND SB5.D_E_L_E_T_ = ' ' " + CRLF
	_cQry += " WHERE SZI.D_E_L_E_T_ = ' '" + CRLF
	//_cQry += " AND SZI.ZI_CODPRD IN ('201000276AA','B501004F635','B880024F043') " + CRLF
	_cQry += " AND ( SZI.ZI_QTDEMPR - SZI.ZI_QTDPGEM ) > 0" + CRLF
	_cQry += " ORDER BY SB1.B1_RASTRO DESC, SZI.ZI_CODPRD" + CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQry), _cAlias, .T., .T. )

	DbSelectArea((_cAlias))
	
	nTotReg := Contar(_cAlias,"!Eof()")
	If !_lJob
		ProcRegua( nTotReg )
	EndIf

	(_cAlias)->(DbGotop())
	If !(_cAlias)->(EOF())
		
		If _lRet

			While (_cAlias)->(!EOF())

				//limpa a reserva e qaclass.
				cUpdate :=  " "
				cUpdate +=  " UPDATE " + RetSqlName("SB2")              						+ CRLF
				cUpdate	+=  " SET B2_QACLASS = 0, B2_RESERVA = 0, B2_QEMP = 0 "					+ CRLF
				cUpdate +=  " WHERE B2_FILIAL = '" + FWxFilial("SB2") + "'"						+ CRLF    
				cUpdate +=  " AND B2_LOCAL = 'PRD' "				     						+ CRLF
				cUpdate +=  " AND B2_COD = '" + (_cAlias)->ZI_CODPRD + "' "						+ CRLF
				cUpdate +=  " AND ( B2_QACLASS <> 0  OR B2_RESERVA <> 0  OR B2_QEMP <> 0 ) "	+ CRLF
				cUpdate +=  " AND D_E_L_E_T_ = ' ' "                        					+ CRLF

				TcSqlExec(cUpdate)

				//limpa a reserva e qaclass.
				cUpdate :=  " "
				cUpdate +=  " UPDATE " + RetSqlName("SB8")              						+ CRLF
				cUpdate	+=  " SET B8_QACLASS = 0, B8_EMPENHO = 0 "								+ CRLF
				cUpdate +=  " WHERE B8_FILIAL = '" + FWxFilial("SB8") + "'"						+ CRLF    
				cUpdate +=  " AND B8_LOCAL = 'PRD' "				     						+ CRLF
				cUpdate +=  " AND B8_PRODUTO = '" + (_cAlias)->ZI_CODPRD + "' "					+ CRLF
				cUpdate +=  " AND ( B8_QACLASS <> 0 OR B8_EMPENHO <> 0 ) "						+ CRLF
				cUpdate +=  " AND D_E_L_E_T_ = ' ' "                        					+ CRLF

				TcSqlExec(cUpdate)

				_lRet 		:= .T.	
				_cServWMS 	:= "207"
				_lCtrlWMS	:= .T.
				_nQtdPgto	:= 0
				nCont++

				// Incrementa a mensagem na régua.
				If !_lJob
					IncProc("Proc Produto: "+AllTrim((_cAlias)->ZI_CODPRD)+"- Item " + cValToChar(nCont) + " de " + cValToChar(nTotReg) + "...")
				EndIf
				
				DbSelectArea("SD3")

				If SB1->(DbSeek(XFilial("SB1")+(_cAlias)->ZI_CODPRD ))  //posicionar o SB1

					If (_cAlias)->WMS == "1"
						_cServWMS 	:= "207"
						_lCtrlWMS	:= .T.
					Else 
						_lCtrlWMS	:= .F.	
						_cServWMS := ""
					EndIf


					If (_cAlias)->B1_RASTRO <> "L"
						If (_cAlias)->WMS == "1"
							_nQtdPgto := MIN((_cAlias)->SALDO_SB2,(_cAlias)->SALDO_D14)
						Else
							_nQtdPgto := (_cAlias)->SALDO_SB2
						EndIf

					Else

						_nQtdPgto := MIN((_cAlias)->SALDO_D14,(_cAlias)->SALDO_SB8 )

						If (_cAlias)->SALDO_SB2 < _nQtdPgto
							_nQtdPgto := (_cAlias)->SALDO_SB2
						EndIf

						If (_cAlias)->SALDO_PAGAR <= _nQtdPgto
							_nQtdPgto := (_cAlias)->SALDO_PAGAR
						EndIf

						_nQtdPgto := Int(_nQtdPgto)

						If _nQtdPgto <= 0
							(_cAlias)->(DbSkip())
							Loop
						EndIf

						zBaixaLote( (_cAlias)->ZI_CODPRD, (_cAlias)->ZI_LOCAL, _nQtdPgto )
						
						(_cAlias)->(DbSkip())
						Loop
					EndIf

					If (_cAlias)->SALDO_PAGAR <= _nQtdPgto
						_nQtdPgto := (_cAlias)->SALDO_PAGAR
					EndIf

					_nQtdPgto := Int(_nQtdPgto)

					If _nQtdPgto <= 0
						(_cAlias)->(DbSkip())
						Loop
					EndIf

					//_cDocSD3 	:= NextNumero("SD3",2,"D3_DOC",.T.)
					_cDocSD3 := GetSxeNum("SD3","D3_DOC")
					//_cOp		:= (_cAlias)->OP 		

					_aCab	:= {}
					_aCab 	:= {	{ "D3_DOC" 		, _cDocSD3		, NIL},;
									{ "D3_TM" 		, __cTm			, NIL},;
									{ "D3_EMISSAO" 	, dDataBase		, NIL}}	

					//--Limpa para o proximo processamento
					_atotitem	:= {}

					_aItem	:= {	{ "D3_COD" 		, (_cAlias)->ZI_CODPRD		,NIL},;
									{ "D3_UM" 		, SB1->B1_UM				,NIL},; 
									{ "D3_QUANT" 	, Round(_nQtdPgto, 0)		,NIL},;
									{ "D3_CONTA" 	, SB1->B1_CONTA 			,NIL},;
									{ "D3_LOCAL" 	, (_cAlias)->ZI_LOCAL 		,NIL},;
									{ "D3_GRUPO" 	, SB1->B1_GRUPO 			,NIL},;
									{ "D3_LOTECTL" 	, CriaVar("D3_LOTECTL")		,NIL},;
									{ "D3_LOCALIZ" 	, CriaVar("D3_LOCALIZ")		,NIL},;
									{ "D3_SERVIC" 	, _cServWMS					,NIL}}
									//{ "D3_SERVIC" 	, CriaVar("D3_SERVIC")			,NIL}}

					aAdd(_atotitem,_aitem)
					
				EndIf

				If _lRet
					_lRet := zGeraMov(_aCab, _atotitem, 3 ) //--Gera requisição para baixa do emprestimo BackFlush
				EndIf

				If _lRet 
					If !( zPagSZI(_cDocSD3, _lCtrlWMS,_nQtdPgto, (_cAlias)->ZI_CODPRD, (_cAlias)->ZI_LOCAL) )
						SD3->( RollBackSX8() )
						//zGeraMov(_aCab, _atotitem, 6 ) //--Estorna requisição de baixa do emprestimo BackFlush
					EndIf
				EndIf

				SD3->( DbCloseArea() )

				(_cAlias)->(DbSkip())
			EndDo

		EndIf

	EndIf
	(_cAlias)->(DbCloseArea())

Return

/*
=====================================================================================
Programa.:              zBaixaLote
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              24/08/22
Descricao / Objetivo:   Gera requisição para baixa de saldo do emprestimo BackFlush         
=====================================================================================
*/
Static Function zBaixaLote( cCodProd, cLocal, nSaldoPg)
	Local _lRet			:= .T.
	Local nQuantPg 		:= 0
	Local _cAlias   	:= GetNextAlias()
	Local _cQry			:= ""
	Local _cServWMS		:= "207"
	Local _cDocSD3		:= ""
	Local _aCab			:= {}
	Local _aItem 		:= {}
	Local _atotitem		:= {}

	SB1->( DbSetOrder(1) )

	_cQry += "	SELECT SUM(B8_SALDO - B8_EMPENHO) QTD, B8_LOTECTL, B8_DTVALID, B8_PRODUTO, B8_LOCAL " + CRLF
	_cQry += "	FROM " + RetSQLName('SB8') + " SB8 " + CRLF
	_cQry += "	WHERE D_E_L_E_T_ = ' ' " + CRLF
	_cQry += "		AND B8_PRODUTO = '" + cCodProd + "'" + CRLF
	_cQry += "		AND B8_LOCAL = '" + cLocal + "'" + CRLF
	_cQry += "		AND ( B8_SALDO - B8_EMPENHO ) > 0 " + CRLF
	_cQry += "		AND B8_DTVALID >= '" + DToS( dDataBase ) + "'" + CRLF
	_cQry += "		AND (B8_LOCAL, B8_LOTECTL) IN (	 SELECT D14_LOCAL, D14_LOTECT " + CRLF
	_cQry += "										 FROM " + RetSQLName('D14') + " D14 " + CRLF
	_cQry += "										 WHERE D14.D14_FILIAL = '" + FWxFilial('D14') + "'" + CRLF
	_cQry += "											AND D14.D14_LOCAL = SB8.B8_LOCAL " + CRLF
	_cQry += "											AND D14.D14_PRODUT = SB8.B8_PRODUTO " + CRLF
	_cQry += "											AND D14_ENDER IN ( 	SELECT SBE.BE_LOCALIZ " + CRLF
	_cQry += "																FROM " + RetSQLName('SBE') + " SBE " + CRLF
	_cQry += "																WHERE SBE.BE_FILIAL = '" + FWxFilial('SBE') + "'" + CRLF
	_cQry += "																	AND SBE.BE_ESTFIS IN (	SELECT DC8.DC8_CODEST " + CRLF
	_cQry += "																							FROM " + RetSQLName('DC8') + " DC8 " + CRLF	
	_cQry += "																							WHERE DC8.DC8_FILIAL = '" + FWxFilial('DC8') + "'" + CRLF	
	_cQry += "																								AND DC8.DC8_TPESTR = '7') " + CRLF
	_cQry += "																								AND SBE.BE_LOCAL = D14.D14_LOCAL " + CRLF	
	_cQry += "																								AND SBE.D_E_L_E_T_ = ' ') ) " + CRLF
	_cQry += "	GROUP BY B8_LOTECTL, B8_DTVALID, B8_PRODUTO, B8_LOCAL " + CRLF
	_cQry += "	ORDER BY B8_DTVALID ASC, B8_LOTECTL " + CRLF

	DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQry), _cAlias, .T., .T. )

	DbSelectArea((_cAlias))
	(_cAlias)->(DbGotop())
	If !(_cAlias)->(EOF())

		While (_cAlias)->(!EOF())	
			
			DbSelectArea("SD3")

			If nQuantPg == nSaldoPg //--Se o valor a pagar for maior ou igual ao saldo disponivel, faz saida do while
				Exit
			EndIf

			nQtdEmp	 := (_cAlias)->QTD
			nQuantPg := nQuantPg + nQtdEmp

			If nQuantPg > nSaldoPg
				nQtdEmp := nQtdEmp - (nQuantPg - nSaldoPg)
				nQuantPg := nSaldoPg
			EndIf

			//_cDocSD3 	:= NextNumero("SD3",2,"D3_DOC",.T.)
			_cDocSD3 := GetSxeNum("SD3","D3_DOC")
			//_cOp		:= (_cAlias)->OP 		

			_aCab	:= {}
			_aCab 	:= {	{ "D3_DOC" 		, _cDocSD3		, NIL},;
							{ "D3_TM" 		, __cTm			, NIL},;
							{ "D3_EMISSAO" 	, dDataBase		, NIL}}			

			If SB1->(DbSeek(XFilial("SB1")+(_cAlias)->B8_PRODUTO ))  //posicionar o SB1

				//--Limpa para o proximo processamento
				_atotitem	:= {}

				_aItem	:= {	{ "D3_COD" 		, (_cAlias)->B8_PRODUTO		,NIL},;
								{ "D3_UM" 		, SB1->B1_UM				,NIL},; 
								{ "D3_QUANT" 	, Round(nQtdEmp, 0)			,NIL},;
								{ "D3_CONTA" 	, SB1->B1_CONTA 			,NIL},;
								{ "D3_LOCAL" 	, (_cAlias)->B8_LOCAL 		,NIL},;
								{ "D3_GRUPO" 	, SB1->B1_GRUPO 			,NIL},;
								{ "D3_LOTECTL" 	, (_cAlias)->B8_LOTECTL		,NIL},;
								{ "D3_LOCALIZ" 	, CriaVar("D3_LOCALIZ")		,NIL},;
								{ "D3_SERVIC" 	, _cServWMS					,NIL}}
								//{ "D3_SERVIC" 	, CriaVar("D3_SERVIC")			,NIL}}

				aAdd(_atotitem,_aitem)
				
			EndIf

			_lRet := zGeraMov(_aCab, _atotitem, 3 ) //--Gera requisição para baixa do emprestimo BackFlush

			If _lRet 
				_lRet := zPagSZI(_cDocSD3, .T.,nQtdEmp, (_cAlias)->B8_PRODUTO, (_cAlias)->B8_LOCAL)

				If !_lRet
					SD3->( RollBackSX8() )
					//zGeraMov(_aCab, _atotitem, 6 ) //--Estorna requisição de baixa do emprestimo BackFlush
					nQuantPg := nQuantPg - nQtdEmp
				EndIf
			Else
				nQuantPg := nQuantPg - nQtdEmp
			EndIf

			SD3->( DbCloseArea() )

			(_cAlias)->( DbSkip() )

		EndDo

	EndIf

	(_cAlias)->( DbCloseArea() )

Return

/*
=====================================================================================
Programa.:              zGeraMov
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              24/08/22
Descricao / Objetivo:   Gera requisição para baixa de saldo do emprestimo BackFlush         
=====================================================================================
*/
Static Function zGeraMov(aCab, aItens, nOpc)
	Local _lRet 		:= .T.
	Local _cTexto		:= ""
	Local _aError
	Local _nPos

	Private lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
	//Private lMsHelpAuto 	:= .T.  // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
	Private lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog

	Begin Transaction	

		//Realiza a requisicao do material perdido ou utilizado a mais que a estrutura para a Ordem de Producao
		If _lJob
			MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,nOpc)
		Else
			MsAguarde({|| MSExecAuto({|x,y,z| mata241(x,y,z)},aCab,aItens,3) },"Incluindo...") //Inclusao
		EndIf

		If lMsErroAuto
			_aError := GetAutoGRLog()
			For _nPos := 1 To Len(_aError)
				If !Empty((AllTrim(_aError[_nPos])))  	
					_cTexto	+= 	Upper(AllTrim(_aError[_nPos])) + CRLF
				EndIf		
			Next _nPos		
			_lRet := .F.	
			DisarmTransaction()			 	
		EndIf	

	End Transaction	

Return _lRet

/*
=====================================================================================
Programa.:              zPagSZI
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              22/08/22
Descricao / Objetivo:   Conclui e realiza o preenchimento dos dados de pagamento 
						do emprestimo         
=====================================================================================
*/
Static Function	zPagSZI(_cDocSD3, _lCtrlWMS, _nQtdPgto, _cProduto, _cLocal)

	Local _lRet 	:= .T.
	Local cAliasQry	:= ""

	//_lRet := zUpdDCF(_cDocSD3, "207") Utilizado somente na criação do emprestimo para usar o endereço BACKFLUSH na baixa via apontamento de produção

	If _lCtrlWMS
		_lRet := zFinOSWms( _cDocSD3, "207" ) //--No mov de requisição a SD3 só é gerada após a finalização da OS
	EndIf

	If _lRet

		Begin Transaction

			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT SZI.R_E_C_N_O_ AS RECSZI
				FROM %Table:SZI% SZI
				WHERE SZI.ZI_FILIAL = %xFilial:SZI%
				AND SZI.ZI_CODPRD = %Exp:_cProduto%
				AND SZI.ZI_LOCAL = %Exp:_cLocal%
				AND SZI.%NotDel%
			EndSql
				
			If (cAliasQry)->( !EOF() )
		
				SZI->( DbGoTo( (cAliasQry)->RECSZI ) )
				SZI->(RecLock('SZI', .F. ))
					SZI->ZI_QTDPGEM	:= ( SZI->ZI_QTDPGEM + _nQtdPgto )
				SZI->(MsUnlock())

			EndIf

			(cAliasQry)->( DbCloseArea() )

			
		End Transaction

	EndIf

Return _lRet

/*
=====================================================================================
Programa.:              zUpdDCF
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              22/08/22
Descricao / Objetivo:   Altera o endereço de destino da Tabela DCF para liberação 
						do saldo no endereço BACKFLUSH
=====================================================================================
*/
Static Function zUpdDCF(_cDocSD3, _cServWMS)
	Local _lRet		:= .T.
	Local _cEndDes	:= SuperGetMV( "CMV_PCP103",,"BACKFLUSH") 
	Local cUpdate 	:= ""

	//Altera o endereço de destino da Tabela DCF
	cUpdate :=  " "
	cUpdate +=  " UPDATE " + RetSqlName("DCF")              			+ CRLF
	cUpdate	+=  " SET DCF_ENDDES = '" + _cEndDes + "' "         		+ CRLF
	cUpdate +=  " WHERE DCF_FILIAL = '" + FWxFilial("DCF") + "'"		+ CRLF    
	cUpdate +=  " AND DCF_SERVIC = '" + _cServWMS + "'"     			+ CRLF
	cUpdate +=  " AND DCF_DOCTO = '" + _cDocSD3 + "'"     				+ CRLF
	cUpdate +=  " AND DCF_STSERV = '1'"    								+ CRLF
	cUpdate +=  " AND D_E_L_E_T_ = ' ' "                        		+ CRLF

	If TcSqlExec(cUpdate) < 0
		If _lJob
			Aadd(_aMensErro,"Erro ao gravar o Endereco de Destino na DCF")
			_lRet := .F.
		Else
			Help( ,, "Caoa",, TcSqlError() , 1, 0)
		EndIf
	EndIf
	
Return _lRet

/*
=====================================================================================
Programa.:              zFinOSWms
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              22/08/22
Descricao / Objetivo:   Finaliza ordem de serviço WMS
=====================================================================================
*/
Static Function zFinOSWms( _cDocSD3, _cServWMS )
	Local _lRet		:= .T.
	Local cAliasQry	:= ""
	Local aIDDcf	:= {}
	Local nI		:= 0
	
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DCF.DCF_ID
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_SERVIC = %Exp:_cServWMS%
		AND DCF.DCF_DOCTO = %Exp:_cDocSD3%
		AND DCF.DCF_STSERV IN ('1','2') 
		AND DCF.%NotDel%
	EndSql

	While (cAliasQry)->( !Eof() )

		//--Guarda IDDCF para execução do serviço
		Aadd( aIDDcf, (cAliasQry)->DCF_ID)

		(cAliasQry)->( DbSkip() )

	EndDo

	(cAliasQry)->( DbCloseArea() )

	_lRet := Len( aIDDcf ) > 0

	If _lRet

		WMSCTPENDU() // Cria as temporárias - FORA DA TRANSAÇÃO
		WMSCTPRGCV() // Cria tabela temporária - Convocação 

		If Len( aIDDcf ) > 1
			
			For nI := 1 To Len( aIDDcf )

				//--Utilizado pela função zProcEmpr, nela a requisição tem mais de 1 item e gera mais de uma DCF
				//--Como cada IDDCF é processado individualmente, não estamos controlando erros na finalização da OS neste ponto
				FinOrdSer(aIDDcf[nI] ) // Executa e finaliza serviço WMS

			Next nI

		Else

			_lRet := FinOrdSer(aIDDcf[1] ) // Executa e finaliza serviço WMS

		EndIf

		WMSDTPRGCV() // Destroy tabela temporária - convocação
		WMSDTPENDU() // Destroy as temporárias - FORA DA TRANSAÇÃO

	EndIf

	If _lRet 
		zUpdD14(_cDocSD3) //--Verificar se devo incluir tratamento em caso de erro
	EndIf

Return _lRet

/*
=====================================================================================
Programa.:              zUpdD14
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              22/08/22
Descricao / Objetivo:   Zera o saldo negativo de entrega prevista causada nos cenarios
						de requisição do emprestimo
=====================================================================================
*/
Static Function zUpdD14(_cDocSD3)
	Local _lRet 	:= .T.
	Local _cEndDes	:= 	SuperGetMV( "CMV_PCP103",,"BACKFLUSH") 

	cUpdate :=  " "
	cUpdate +=  " UPDATE " + RetSqlName("D14") + " D14 "											+ CRLF
	cUpdate	+=  " SET D14_QTDEPR = '0' "															+ CRLF
	cUpdate +=  " WHERE D14_FILIAL = '" + FWxFilial("D14") + "'"									+ CRLF    
	cUpdate +=  " AND D14_ENDER = '" + _cEndDes + "'"												+ CRLF
	cUpdate +=  " AND D14_QTDEPR <> 0 "																+ CRLF
	cUpdate +=  " AND D14.D_E_L_E_T_ = ' '"    														+ CRLF
	cUpdate +=  " AND ( D14_PRODUT, D14_LOCAL ) IN ( SELECT DCF_CODPRO, DCF_LOCAL " 				+ CRLF
	cUpdate +=  " 									 FROM " + RetSQLName('DCF') + " DCF  " 			+ CRLF
	cUpdate +=  " 									 WHERE DCF_FILIAL = '" + FWxFilial("DCF") + "'"	+ CRLF  
	cUpdate +=  " 									 	AND DCF_DOCTO = '" + _cDocSD3 + "'"    		+ CRLF
	cUpdate +=  " 									 	AND DCF.D_E_L_E_T_ = ' ' ) "               	+ CRLF

	If TcSqlExec(cUpdate) < 0
		If _lJob
			Aadd(_aMensErro,"Erro ao zerar o campo D14_QTDEPR")
			_lRet := .F.
		Else
			Help( ,, "Caoa",, TcSqlError() , 1, 0)
		EndIf
	EndIf

Return

Static Function ExeAutServ( cIDdcf )
	Local lRet       := .T.
	Local lContinua  := .T.
	Local oOrdSerRev := Nil
	Local oOrdSerExe := Nil
	Local oRegraConv := Nil
	Local cListIdDcf := ""
	//Local nX         := 0
	Local lExAuSpCp  := SuperGetMV("MV_WMSEASC",.F.,.F.)

	// Integração com o WMS
	// Verifica as Ordens de servico geradas para execução automatica
	oOrdSerExe := ZWMSF009():New()
	oRegraConv := ZWMSF010():New()
	oOrdSerExe:SetArrLib(oRegraConv:GetArrLib())
	cListIdDcf := ""
	//For nX := 1 To Len(aLibDCF)
	oOrdSerExe:SetIdDCF(cIDdcf) //aLibDCF[nX]
	If oOrdSerExe:LoadData()
		If (lContinua := oOrdSerExe:zExecDCF()) .And. oOrdSerExe:oServico:ChkSepara() .And. oOrdSerExe:GetOrigem() == "SC9"
			// Monta lista de ordem de serviço executada
			cListIdDcf += "'" + cIDdcf + "'," //aLibDCF[nX]
		EndIf
	EndIf
	If !lContinua
		lRet := .F.
		//Exit
	EndIf
	//Next nX

	If lRet
		If !Empty(oRegraConv:GetArrLib())
			oRegraConv:zLawExec()
		EndIf
	EndIf

	// Verifica se há mensagem de inconsistência e o parâmetro de execução automática de separação completa
	If !Empty(oOrdSerExe:aWmsAviso) .And. lExAuSpCp .And. !Empty(cListIdDcf)
		// Ajusta lista de ordem de serviço executada
		cListIdDcf := SubsTr(cListIdDcf,1,Len(cListIdDcf)-1)
		oOrdSerRev := WMSDTCOrdemServicoReverse():New()
		oOrdSerRev:RevPedAut(cListIdDcf)
	EndIf

	//-- Grava Erro
	If !lRet
		__cErro	:=	oOrdSerExe:GetErro()
	EndIf

Return lRet

//--Grava SZZ
Static Function ZGRVSZZ(aMsgErro, _cStatus, _aBackFlush, nQtdOP, _cSeqSD3)

	Local _cErro		:= ""
	Local nY			:= 0
	Local _nX 			:= 0

	Default aMsgErro	:= {}
	Default _cSeqSD3	:= ""

	SB1->(DbSetOrder(1))

	If Len(aMsgErro) > 0
		For nY	:= 1 To Len(aMsgErro)
			_cErro += aMsgErro[nY]
		Next nY
	EndIf

	For _nX := 1 To Len(_aBackFlush)

		SZZ->(DbGoTop())
		SZZ->(DbGoTo(_aBackFlush[_nX][01]))
		If RecLock('SZZ', .F. )
		
			SZZ->ZZ_STATUS	:= _cStatus
			If _cStatus == "A"
				SZZ->ZZ_DTAPONT	:= Date()
				SZZ->ZZ_HRAPONT	:= Time()
				SZZ->ZZ_USUAPON	:= iif( _lJob , "JOB" , RetCodUsr() )
				SZZ->ZZ_NSEQD3 	:= _cSeqSD3
			ElseIf _cStatus == "E"
				SZZ->ZZ_OBSPRC := _cErro
			EndIf
			SZZ->(MsUnlock())

		EndIf

	Next _nX

Return()

//-------------------------------------
/*/{Protheus.doc} ZPJ1VLVEI
Valida Veiculos
@author 	DAC - Denilso
@since 		20/10/2020
@version 	1.0
@obs		Vverificar se veiculo ja esta cadastrado		         
/*/
//-------------------------------------
Static Function ZPJ1VLVEI(_cProduto, _cChassi, _cNumMotor, _cFabMod )
	Local _nTamChassi	:= SuperGetMV( "CMV_PCP008"  ,,17)
	Local _cAnoFab
	Local _cAnoMod
	Local _nValData

	If Empty(_cChassi)
		Aadd(_aMensErro, "Numero de Chassi não informado")
		Return .F.
	EndIf
	
	If Len(AllTrim(_cChassi)) <> _nTamChassi
		Aadd(_aMensErro, "Numero de Chassi com tamanho divergente, verificar")
		Return .F.
	EndIf
	
	If Empty(_cNumMotor)
		Aadd(_aMensErro, "Numero do motor não informado")
		Return .F.
	EndIf
	
	_cAnoFab 	:= SubsTr(_cFabMod,1,4)
	_cAnoMod 	:= SubsTr(_cFabMod,5,4)
	_nValData 	:= Val(_cAnoMod) - Val(_cAnoFab)
	If _nValData > 1  .or. _nValData < 0
		Aadd(_aMensErro,"Ano de Fabricação e Modelo não é permitido") 
		Return .F.
	EndIf

	//Quando for emprestimo o veiculo existira e não podera retornar erro
	/*If SZZ->ZZ_STATUS <> "L"  
		VV1->(DbSetOrder(2))	//VV1_FILIAL+VV1_CHASSI
		If VV1->(DbSeek(xFilial('VV1')+_cChassi))
			Aadd(_aMensErro,{"VEICULO JA CADASTRADO","V"})
			Break
		EndIf
	Endif*/

 	//localizar a Marca
	VV2->(DbSetOrder(7))  //VV2_FILIAL+VV2_PRODUT
	If !VV2->(DbSeek(xFilial('VV2')+_cProduto))
		Aadd(_aMensErro, "MARCA DE VEÍCULO NÃO CADASTRADA PARA O VEÍCULO")
		Return .F.
	Endif

Return .T.

//-------------------------------------
/*/{Protheus.doc} ZPCPJV01
Chamada do Job de Processamento
Monta a empresa e chama o ZPCPJ002
@author 	Evandro Mariano
@since 		18/07/2022
@version 	1.0
@obs		
/*/
//-------------------------------------
User Function ZPCPJB002()

Local _lAbre	:= .F.
Local _cEmpresa 		
Local _cFilial 	

Begin Sequence
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ002] Iniciado processamento Backflush 3.0 ")
	
	_cEmpresa	:=	"01"
	_cFilial	:=  "2010022001"
	CONOUT("INICIANDO EMPRESA "+_cEmpresa)
	CONOUT("INICIANDO FILIAL "+_cFilial)
	RpcClearEnv()
	RpcSetType(3)
	Prepare Environment Empresa _cEmpresa Filial _cFilial Modulo "PCP"
	_lAbre		:= .T.
	
	CONOUT("INICIADA EMPRESA "+cEmpAnt)
	CONOUT("INICIADA FILIAL "+cFilAnt)
	U_ZPCPJ002()
	CONOUT("["+Left(DtoC(Date()),5)+"]["+Left(Time(),5)+"][ZPCPJ002] Finalizado processamento Backflush 3.0")
	If 	_lAbre	
		Reset Environment
	EndIf
End Sequence
Return Nil

/*
=====================================================================================
Programa.:              FinOrdSer
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              15/01/2021
Descricao / Objetivo:   Finaliza ordem de serviço           
=====================================================================================
*/
Static Function FinOrdSer( cIDdcf )
	Local aAreaSB1	:= SB1->( GetArea() )
	Local lRet      := .T.
	Local cAliasD12 := Nil
	Local oMoviServ	:= WMSBCCMovimentoServico():New()
	
	// Efetua a execução automática do serviço
	lRet := ExeAutServ(cIDdcf)

	If lRet
		cAliasD12 := GetNextAlias()
		BeginSql Alias cAliasD12
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = %Exp:cIDdcf%	//oOrdServ:GetIdDCF()
			AND D12.%NotDel%
		EndSql
		Do While lRet .And. (cAliasD12)->(!Eof())
			oMoviServ:GoToD12((cAliasD12)->RECNOD12)
			// Finaliza movimento
			oMoviServ:SetQtdLid(oMoviServ:nQtdMovto)
			oMoviServ:dDtGeracao := dDataBase	//oOrdServ:GetData()
			oMoviServ:cHrGeracao := Time() 		//oOrdServ:GetHora()
			oMoviServ:dDtInicio  := dDataBase 	//oOrdServ:GetData()
			oMoviServ:cHrInicio  := Time() 		//oOrdServ:GetHora()
			// Atualiza o D12 para finalizado
			oMoviServ:SetStatus("1")
			oMoviServ:SetDataFim(dDataBase)
			oMoviServ:SetHoraFim(Time())
			oMoviServ:SetRecHum(IIF(Type("__cCodUser") == "C", __cCodUser, RetCodUsr()))
			If oMoviServ:GetAtuEst()== "1"

				If oMoviServ:oMovServic:ChkRecebi(); // Endereçamento, Cross Docking
					.Or. oMoviServ:oMovServic:ChkTransf() // Transferencia // Desfragmentação(Transferencia)
					lRet := oMoviServ:RecEnter()
				ElseIf oMoviServ:oMovServic:ChkSepara(); // Apanhe
					.Or. oMoviServ:oMovServic:ChkReabast() // (Re)Abastecimento
					lRet := oMoviServ:RecExit()
				EndIf
			
			EndIf
			If lRet
				oMoviServ:UpdateD12()
			EndIf
			(cAliasD12)->(dbSkip())
		EndDo
		(cAliasD12)->(dbCloseArea())
		
		If !lRet
			__cErro := oMoviServ:GetErro()
		EndIf

	EndIf

	RestArea(aAreaSB1)
	oMoviServ:Destroy()
Return lRet
