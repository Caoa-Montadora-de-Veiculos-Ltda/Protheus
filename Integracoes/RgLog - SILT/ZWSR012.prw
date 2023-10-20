#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

/*
===================================================================================================
Programa.:              ZWSR012
Autor....:              CAOA - Evandro Mariano
Data.....:              29/06/2022
Descricao / Objetivo:   Rotina responsavel por receber a confirmação da conferencia do recebimento
						realizada pela RGLOG e transferir os itens conferidos entre armazens
						- Revitalização feita em 29/06/2022.
Historico: 				DAC -Denilso 16/05/2023
						PEC042.-.Controle.de.saldo.e.e-mail.apos.integracao.de.armazenagem, implementado LOCALIZAÇÃO D3 POR NextNumero, envio de e-nail com divergência, e tratamento parcial quando Qde Conf maior que saldo
====================================================================================================
*/
WSRESTFUL ZWSR012 DESCRIPTION "Integração RGLOG Confirmacao de mercadorias recebidas" FORMAT APPLICATION_JSON 
    WSDATA empresa 			As String
	WSDATA filial 			As String
	WSDATA usuario 			As String
	WSDATA senha 			As String
	WSDATA nota_fiscal 		As String
	WSDATA serie_nf			As String
	WSDATA cod_fornecedor 	As String
	WSDATA id  				As String
	WSDATA cd_produto		As String
	WSDATA qt_conf			As Integer
	WSDATA debug 			As String OPTIONAL //Para poder pegar o erro completo
	WSMETHOD PUT ; 
	        DESCRIPTION "Receber a Confirmacao de mercadorias recebidas da RGLOG";
	        WSSYNTAX "/ZWSR012"
END WSRESTFUL

WSMETHOD PUT;
WSRECEIVE empresa, filial, usuario, senha, nota_fiscal, serie_nf, cod_fornecedor, cd_produto, qt_conf,debug;
WSSERVICE ZWSR012
Local cJSON 		:= Self:GetContent() // –> Pega a string do JSON
Local oParseJSON 	:= Nil
Local oJsonRet 		:= JsonObject():New()
Local _lTransf		:= .F.
Local _cLog			:= ""
Local oJsonLog		:= JsonObject():New()
Local _cTab			:= "ZD1"
Local _cDoc			:= ""
Local _dDataIni 	:= Date()
Local _cHsIni		:= Time()
Local _aDivergencia	:= {}
Local _nRetJson		:= 0

Private _aItens		:= {}
Private _cErro		:= ""
Private _cNfFor 	:= ""
Private _cSerFor 	:= ""
Private _cFornec	:= ""
Private _cLoja		:= ""
//Private _cTpNf		:= ""
Private lDebug 		:= .F.
Private _aJson		:= {}

//-- Cabeçalho a incluir
//Private aAuto		:= {}
//Private _aItem		:= {}
//Private _atotitem	:= {} 

	Conout("ZWSR012 - Integracao Confirmacao de mercadorias recebidas RGLOG PUT - Inicio "+DtoC(date())+" "+Time())

	::SetContentType("application/json")
	// –> Deserializa a string JSON
	FWJsonDeserialize(cJson, @oParseJSON)

	_cDoc := ""
	If ValType(cJson) == "J"
		If _oJson:GetJsonText("nota_fiscal") <> Nil
			_cDoc 	:= AllTrim(_oJson:GetJsonText("nota_fiscal")) 
		Endif
		If _oJson:GetJsonText("serie_nf") <> Nil
			_cDoc 	+= ";"
			_cDoc 	+= AllTrim(_oJson:GetJsonText("serie_nf"))
		EndIf	
	Else
		_cDoc := oParseJSON:nota_fiscal+";"+oParseJSON:serie_nf
	EndIf

	If Empty(oParseJSON:empresa) .Or. Empty(oParseJSON:filial)
 		_cErro := "Necessario informar os parametros empresa e filial, por favor, verifique!"
		ZWSR012Monitor("2",_cTab, _cDoc, _cErro, _dDataIni, _cHsIni, cJson, 400 /*_nErro*/ )	
		SetRestFault(400, _cErro)
		Return(.T.)
	EndIf
	//-- Verificar se tem a tag de debug no Json
	IF at('debug',cJson) > 0 
		if UPPER(oParseJSON:debug) == "S" //verifica se é para e executar em modo debug
			lDebug := .T.
		ENDIF
	ENDIF
	
	//-- Tratar abertura da empresa conforme enviado no parametro
    If cEmpAnt <> AllTrim(oParseJSON:empresa) .or. cFilAnt <> AllTrim(oParseJSON:filial)
    	RpcClearEnv() 
    	RPCSetType(3) 
    	RpcSetEnv(AllTrim(oParseJSON:empresa),AllTrim(oParseJSON:filial),,,,GetEnvServer(),{})
    EndIf

    If Empty ( oParseJSON:usuario ) .or. AllTrim(oParseJSON:usuario) <> "RGLOG.REST"
 		_cErro := "Usuario nao esta autorizado a acessar os servicos Protheus!"
		ZWSR012Monitor("2",_cTab, _cDoc, _cErro, _dDataIni, _cHsIni, cJson, 400 /*_nErro*/ )	
		SetRestFault(400, _cErro)
		Return(.T.)
 	EndIf

    If Empty ( oParseJSON:senha ) .or. AllTrim(oParseJSON:senha) <> "CaOa!RgLogRest@2021"
 		_cErro := "Senha invalida!"
		ZWSR012Monitor("2",_cTab, _cDoc, _cErro, _dDataIni, _cHsIni, cJson, 400 /*_nErro*/ )	
		SetRestFault(400, _cErro)
		Return(.T.)
 	EndIf

	_cNfFor 	:= AllTrim(StrZero(Val(oParseJSON:nota_fiscal),9))
	_cSerFor 	:= AllTrim(oParseJSON:serie_nf)
	_cFornec	:= SubStr(AllTrim(oParseJSON:cod_fornecedor), 2, 6)
	_cLoja		:= SubStr(AllTrim(oParseJSON:cod_fornecedor), 8, 2)
		
	/*If Len(AllTrim(oParseJSON:cod_fornecedor)) == 9  .And. Substr(AllTrim(oParseJSON:cod_fornecedor),1,1) == "9"
		_cNfFor 	:= AllTrim(StrZero(Val(oParseJSON:nota_fiscal),9))
		//_cNfFor 	:= AllTrim(oParseJSON:nota_fiscal)
		_cSerFor 	:= AllTrim(oParseJSON:serie_nf)
		_cFornec	:= SubStr(AllTrim(oParseJSON:cod_fornecedor), 2, 6)
		_cLoja		:= SubStr(AllTrim(oParseJSON:cod_fornecedor), 8, 2)
		_cTpNf		:= "T"
	Else
		_cNfFor 	:= AllTrim(oParseJSON:nota_fiscal)
		_cSerFor 	:= AllTrim(oParseJSON:serie_nf)
		_cFornec	:= AllTrim(oParseJSON:cod_fornecedor) 
		_cLoja		:= ""
		_cTpNf 		:= "S"		
	EndIf*/

	_cLog := chr(10)
	_cLog += "Nf ........: " + _cNfFor      + chr(10)
	_cLog += "Serie......: " + _cSerFor     + chr(10)
	_cLog += "Fornecedor.: " + _cFornec     + chr(10)
	_cLog += "Loja.......: " + _cLoja       + chr(10)
	//_cLog += "Tipo.......: " + _cTpNf       + chr(10)
	_cLog += "Data.......: " + DtoC(Date()) + chr(10)
	_cLog += "Time.......: " + Time()       + chr(10)
	_cLog += "JSON.......: " + cJson	    + chr(10)

	If Empty( _cNfFor )
 		_cErro := "Nota Fiscal nao informada"
		ZWSR012Monitor("2",_cTab, _cDoc, _cErro, _dDataIni, _cHsIni, cJson, 400 /*_nErro*/ )	
		SetRestFault(400, _cErro)
		Return(.T.)
 	EndIf

	If Empty( _cFornec )
 		_cErro := "Fornecedor nao informada"
		ZWSR012Monitor("2",_cTab, _cDoc, _cErro, _dDataIni, _cHsIni, cJson, 400 /*_nErro*/ )	
		SetRestFault(400, _cErro)
		Return(.T.)
 	EndIf

	//-- Array de itens dentro de uma propriedade
	_aItens := oParseJSON:Itens
	//Alterado forma de chamada das funções DAC 09/06/2023
	If _aItens == Nil  .Or. Len(_aItens) == 0
 		_cErro := "Nao informado itens"
		ZWSR012Monitor("2",_cTab, _cDoc, _cErro, _dDataIni, _cHsIni, cJson, 400 /*_nErro*/ )	
		SetRestFault(400, _cErro)
		Return(.T.)
	Endif
	//Para Transferência
	_cErro	 := ""
	_nRetJson:= 0
	_lTransf := zGeraTransf(@_aDivergencia, @_nRetJson)
	
	/*If _cTpNf == "T"
		_lTransf := zGeraTransf(@_aDivergencia, @_nRetJson)
	ElseIf _cTpNf == "S"
		_lTransf := zGeraEntrada()
 	EndIf*/
	
	_cLog += "Message....: " + _cErro
	if Len(_aJson) > 0
		ojsonLog:set(_aJson)
		_cLog += chr(10) + "Array Auto.: " + ojsonLog:toJSON()
	endif
	If _lTransf
		If !Empty(_cErro)  //pode vir preenchida nos casos de parciais por exemplo
			_cLog := _cErro
		Else
			_cLog := "Confirmacao de mercadorias recebida com sucesso"
		Endif
		oJsonRet['errorCode']		:= If(_nRetJson == 0, 100, _nRetJson)  //necessário pois parcial tem que voltar para 400
		oJsonRet['Message'] 		:= _cLog	//"Confirmacao de mercadorias recebida com sucesso"
		oJsonRet['nota_fiscal']		:= Val(_cNfFor)
		oJsonRet['cod_fornecedor']	:= oParseJSON:cod_fornecedor
		::SetResponse( oJsonRet:ToJson() )
		//implementado para gravar o erro que retorna caso tenha
		ZWSR012Monitor("1",_cTab, _cDoc, _cLog, _dDataIni, _cHsIni, cJson, 100 /*_nErro*/ )	
	Else
		oJsonRet['errorCode'] 		:= 400
		oJsonRet['errorMessage']	:= AllTrim(_cErro)
		//_cErro ja foi informado em caso de problemas
		::SetResponse( oJsonRet:ToJson() )
		ZWSR012Monitor("2",_cTab, _cDoc, _cErro, _dDataIni, _cHsIni, cJson, 400 /*_nErro*/ )	
	EndIf
	Conout(_cLog)//Logs de Monitoramento
	Conout("ZWSR012 - Integracao Confirmacao de mercadorias recebidas RGLOG PUT - Final "+DtoC(date())+" "+Time())
	//Caso tenha divergencia ESPFUN.-.PEC042.
	If Len(_aDivergencia) > 0					
		NotificaDiv(_aDivergencia)
	Endif	
Return .T.

/*
============================================================================================
Programa.:              zGeraTransf
Autor....:              CAOA - Evandro Ap. Mariano dos Santos
Data.....:              29/06/2022
Descricao / Objetivo:   Realiza a conferencia e faz a transferencia do 80 para 01
Historico: 				DAC -Denilso 16/05/2023
						PEC042.-.Controle.de.saldo.e.e-mail.apos.integracao.de.armazenagem
============================================================================================
*/
Static Function zGeraTransf(_aDivergencia, _nRetJson)
Local _cDocumento     	:= ""
Local _cProduto			:= ""
Local _cIdJson			:= ""
Local _aAuto  			:= {}
Local _aLinha 			:= {}
Local _aSaldoDest		:= {}
Local _aError			:= {}
Local _nOpcAuto     	:= 3
Local _nPos				:= 0
Local _nQtdeConf		:= 0
Local _nSaldoSB2		:= 0
Local _nSaldoTec		:= 0
Local _nQtdeTec			:= 0
Local _cArmOrig			:= AllTrim( GetNewPar( "CMV_PEC019", "80" ) )
Local _cArmDes			:= AllTrim( GetNewPar( "CMV_PEC020", "01" ) )
Local _cArmTec			:= AllTrim( GetNewPar( "CMV_PEC028", "02" ) )
Local _aArmDes			:=	{_cArmTec,_cArmDes}
//Local cTmpAlias			:= GetNextAlias()
Local cAliasZD1			:= GetNextAlias()
Local cQryZD1			:= ""
//Local aLog 				:= {}
//Local cStartPath 		:= GetSrvProfString("Startpath","")
Local _lRet 			:= .T.
Local _nRegZD1
Local _cMsg
Local _nCount

Default _nRetJson		:= 0

Private lMsErroAuto 	:= .F.
Private lMsHelpAuto		:= .T.    
Private lAutoErrNoFile 	:= .T. 
	
	_aDivergencia 	:= {}
	_aErro			:= {}
	_aSaldoDest		:= {}
	_cErro			:= ""
	_lRet := .T.

	For _nPos := 1 To Len(_aItens)
		_cIdJson		:= AllTrim(_aItens[_nPos]["id"])
		_cProduto		:= AllTrim(_aItens[_nPos]["cd_produto"])
		_nQtdeConf		:= _aItens[_nPos]["qt_conf"]
		_nQtdeDiverge	:= 0
		
		if fSZ1Val( _cIdJson )
			_cErro := "ID " + _cIdJson + " conferencia recebida anteriormente, referente ao produto "+AllTrim(_cProduto) 
			Aadd(_aErro, _cErro)
			_lRet := .F.
			Loop
		Endif

		//Verifica a quantidade enviada
		If _nQtdeConf == 0
			_cErro := "Qtde conferida nao informada para o produto "+AllTrim(_cProduto) 
			_lRet := .F.
			Aadd(_aErro, _cErro)
			Loop
		Endif
		//Produto
		If Empty(_cProduto)
			_cErro := "Codigo do produto "+AllTrim(_cProduto)+" esta em branco." 
			Aadd(_aErro, _cErro)
			_lRet := .F.
			Loop
		Endif	
		SB1->(DbSetOrder(1))
		If !SB1->(DbSeek(FWxFilial("SB1")+PadR(_cProduto, TamSx3('B1_COD') [1])))
			_cErro := "Produto "+AllTrim(_cProduto)+"  nao cadastrado no Totvs." 
			_lRet := .F.
			Aadd(_aErro, _cErro)
			Loop
		Endif
		If SB1->B1_MSBLQL == "1"
			_cErro := "Produto "+AllTrim(_cProduto)+"  bloqueado no cadastrado Totvs." 
			Aadd(_aErro, _cErro)
			_lRet := .F.
			Loop
		EndIf

		//arquivo recebimento
		If Select(cAliasZD1) <> 0
			(cAliasZD1)->(DbCloseArea())
		EndIf
		
		cQryZD1:= ""
		cQryZD1 += " SELECT ZD1.R_E_C_N_O_ AS NREGZD1													"+(Chr(13)+Chr(10))
		cQryZD1 += " FROM "+RetSqlName("ZD1")+" ZD1											"+(Chr(13)+Chr(10))
		cQryZD1 += " WHERE	ZD1.ZD1_FILIAL 	= '"	+FWxFilial("ZD1")+"' 					"+(Chr(13)+Chr(10))
		cQryZD1 += " 	AND ZD1.ZD1_DOC		LIKE '%"+Alltrim(Str(Val(Alltrim(_cNfFor))))+"%'"+(Chr(13)+Chr(10))
		cQryZD1 += " 	AND ZD1.ZD1_SERIE 	= '"	+Alltrim(_cSerFor )					+"' "+(Chr(13)+Chr(10))
		cQryZD1 += " 	AND ZD1.ZD1_FORNEC	= '"	+Alltrim(_cFornec )					+"' "+(Chr(13)+Chr(10))
		cQryZD1 += " 	AND ZD1.ZD1_LOJA	= '"	+Alltrim(_cLoja   )					+"' "+(Chr(13)+Chr(10))
		cQryZD1 += " 	AND ZD1.ZD1_COD		= '"	+Alltrim(_cProduto)					+"' "+(Chr(13)+Chr(10))
		cQryZD1 += " 	AND ZD1.D_E_L_E_T_	= ' '			        						"+(Chr(13)+Chr(10))

		DbUseArea( .T., "TOPCONN", TcGenQry(,, cQryZD1), cAliasZD1, .F., .T. )
		(cAliasZD1)->(DbGoTop())
		If (cAliasZD1)->(Eof()) .Or. (cAliasZD1)->NREGZD1 == 0 
			_cErro := "Nota Fiscal nao encontrada para conferencia. referente ao produto "+AllTrim(_cProduto) 
			Aadd(_aErro, _cErro)
			_lRet := .F.
			Loop
		Endif
		//Não vou fazer o while pois conforme alinhamento é somente um registro para a chave DAC 09/06/2023
		ZD1->(DbGoto((cAliasZD1)->NREGZD1))
		//Se não tiver saldo no titulo não passar DAC 10/06/2023
		If	ZD1->ZD1_SLDIT <= 0
		    _cErro := "Produto "+AllTrim(_cProduto)+"  nao possui Saldo para movimentacao na tabela de Conferencia de Recebimento no Totvs." 
			Aadd(_aErro, _cErro)
			Aadd(_aDivergencia, {	_cProduto,;
									Alltrim(_cFornec),;
									Alltrim(_cLoja ),; 
									Alltrim(_cSerFor),; 
									Alltrim(_cNfFor),; 
									_cArmOrig,;
									,;
									,;
									,;
									_cErro} )
			_lRet := .F.
			Loop
		Endif 
		If AllTrim(ZD1->ZD1_LOCAL) == "90"
			_cArmOrig	:= "90"
			_cArmDes	:= "11"
			_cArmTec	:= AllTrim( GetNewPar( "CMV_PEC028", "02" ) )
			_aArmDes	:=	{_cArmTec,_cArmDes}
		Else
			_cArmOrig	:= "80"
			_cArmDes	:= "01"
			_cArmTec	:= AllTrim( GetNewPar( "CMV_PEC028", "02" ) )
			_aArmDes	:=	{_cArmTec,_cArmDes}
		EndIf


		//Criação dos armazens
		NNR->(DbSetOrder(1))
		NNR->(DbSeek(FWxFilial("SB2")))
		While NNR->(!Eof()) .And. NNR->NNR_FILIAL == FWxFilial("SB2")
			SB2->(DbSetOrder(1))
			If !SB2->(DbSeek(FWxFilial("SB2")+PadR(_cProduto, TamSx3('B2_COD') [1])+PadR(NNR->NNR_CODIGO,TamSx3('B2_LOCAL') [1])))
				CriaSB2(Alltrim(_cProduto),Alltrim(NNR->NNR_CODIGO))
			EndIf
			NNR->(DbSkip())
		EndDo
		
		_nQtdeTec 	:= SB1->B1_XRESTEC
		_nSaldoSB2	:= 0
		SB2->(DbSetOrder(1))
		If !SB2->(DbSeek(FWxFilial("SB2")+PadR(_cProduto, TamSx3('B2_COD') [1])+PadR(_cArmOrig, TamSx3('B2_LOCAL') [1])))
			//Se teve que criar SB2 deve retornar Falso pois o saldo ficara zerado
			CriaSB2(AllTrim(_cProduto),AllTrim(_cArmOrig))
		    _cErro := "Produto "+AllTrim(_cProduto)+"  nao cadastrado no Estoque "+AllTrim(_cArmOrig)+" do Totvs." 
			Aadd(_aDivergencia, {	_cProduto,;
									Alltrim(_cFornec),;
									Alltrim(_cLoja ),; 
									Alltrim(_cSerFor),; 
									Alltrim(_cNfFor),; 
									_cArmOrig,;
									,;
									,;
									,;
									_cErro} )
		Endif	

		_nSaldoSB2 := SB2->(SaldoSb2())
		//Não permitir saldo zerado DAC 16/05/2023
		If _nSaldoSB2 == 0
			_cErro := "Produto "+AllTrim(_cProduto)+" com Armazem "+_cArmOrig+" de Recebimento sem Saldo no Totvs. " 
			Aadd(_aErro, _cErro)
			Aadd(_aDivergencia, {	_cProduto,;
									Alltrim(_cFornec),;
									Alltrim(_cLoja ),; 
									Alltrim(_cSerFor),; 
									Alltrim(_cNfFor),;
									_cArmOrig,; 
									,;
									,;
									,;
									_cErro} )
			_lRet := .F.
			Loop
		Endif
		//neste caso não é erro receberá parcial quando saldo do armazém esta menor que a quantidade enviada			
		If _nSaldoSB2 < _nQtdeConf
			//ESPFUN.-.PEC042. deixo continuar com o Saldo do SB2 conforme alinhado com José 16/05/2023
			_nQtdeDiverge := _nQtdeConf
			_nQtdeConf	  := _nSaldoSB2	
			_cMsg := "Qtde conferida "+AllTrim(Str(_nQtdeDiverge))+" maior que Saldo do Totvs "+AllTrim(Str(_nSaldoSB2))+". Sera utilizado Saldo Totvs" 
			_cErro:= "Recebimento parcial do produto "+_cProduto+" na qtde " +AllTrim(Str(_nQtdeConf))+ " por falta de saldo no armazem "+_cArmOrig+" divergencia do Saldo Estoque, da Serie/NF "+_cSerFor+"/"+_cNfFor
			//igualar qtde conferida a saldo B2
			//Devo enviar e-mail mesmo deixando continuar
			Aadd(_aErro, _cErro)
			Aadd(_aDivergencia, {	_cProduto,;
									Alltrim(_cFornec),;
									Alltrim(_cLoja ),; 
									Alltrim(_cSerFor),; 
									Alltrim(_cNfFor),; 
									_cArmOrig,;
									_nQtdeDiverge,;
									_nQtdeConf,;
									_nSaldoSB2,;
									_cMsg} )
			_nRetJson := 400						
		EndIf
		// Valida se o Produto tem Quantidade minima para saldo no armazem tecnico	
		//Caso não tenha o armazém técino continuo 
		if _nQtdeTec > 0
			SB2->(DbSetOrder(1))
			If SB2->(DbSeek(FWxFilial("SB2")+PadR(_cProduto, TamSx3('B2_COD') [1])+PadR(_cArmTec, TamSx3('B2_LOCAL') [1])))				
				_nSaldoTec := SB2->(SaldoSb2())
				If _nSaldoTec >= _nQtdeTec
					_nSaldoTec := 0
				Else
					_nSaldoTec := _nQtdeTec - _nSaldoTec
				Endif
			Else
				CriaSB2(AllTrim(_cProduto),AllTrim(_cArmTec))
				_cErro := "Produto "+AllTrim(_cProduto)+" nao cadastrado no Estoque "+AllTrim(_cArmTec)+" do Totvs, referente Qtde Tecnico "+AllTrim(Str(_nQtdeTec)) 
				Aadd(_aDivergencia, {	_cProduto,;
										Alltrim(_cFornec),;
										Alltrim(_cLoja ),; 
										Alltrim(_cSerFor),; 
										Alltrim(_cNfFor),;
										_cArmOrig,; 
										,;
										,;
										,;
										_cErro} )
			EndIf
		Endif	
		
		//Pode criar	
		If !SB2->(DbSeek(FWxFilial("SB2")+PadR(_cProduto, TamSx3('B2_COD') [1])+PadR(_cArmDes, TamSx3('B2_LOCAL') [1])))
			CriaSB2(AllTrim(_cProduto),AllTrim(_cArmDes))
			_cErro := "Produto "+AllTrim(_cProduto)+" nao cadastrado no Estoque "+AllTrim(_cArmDes)+" do Totvs." 
			Aadd(_aDivergencia, {	_cProduto,;
									Alltrim(_cFornec),;
									Alltrim(_cLoja ),; 
									Alltrim(_cSerFor),; 
									Alltrim(_cNfFor),;
									_cArmOrig,; 
									,;
									,;
									,;
									_cErro} )
		EndIf
				
		If _nQtdeConf > ZD1->ZD1_SLDIT
			//ESPFUN.-.PEC042.-.Controle.de.saldo.e.e-mail.apos.integracao.de.armazenagem
			//igualar qtde conferida a saldo b2
			_nQtdeDiverge := _nQtdeConf
			_nQtdeConf	  := ZD1->ZD1_SLDIT	
			_cMsg := "Qtde conferida "+AllTrim(Str(_nQtdeDiverge))+" maior que o saldo a conferir - ZD1 "+AllTrim(Str(_nQtdeConf))+", sera substituido pelo saldo ZD1 ." 
			_cErro:= "Recebimento parcial da qtde " +AllTrim(Str(_nQtdeConf))+ " por falta de Saldo a Receber na NF, Armazem "+_cArmOrig+", da Serie/NF "+_cSerFor+"/"+_cNfFor
			Aadd(_aErro, _cErro)
			If _nQtdeDiverge > 0					
				Aadd(_aDivergencia, {	_cProduto,;
										Alltrim(_cFornec),;
										Alltrim(_cLoja ),; 
										Alltrim(_cSerFor),; 
										Alltrim(_cNfFor),; 
										_cArmOrig,;
										_nQtdeDiverge,;
										_nQtdeConf,;
										_nSaldoSB2,;
										_cMsg} )
				_nRetJson := 400									
			Endif	
		EndIf
		If _lRet
			If _nQtdeConf <= _nSaldoTec
				 Aadd(_aSaldoDest,{(cAliasZD1)->NREGZD1, _cProduto, _cArmOrig, _aArmDes, _nQtdeDiverge, _nSaldoSB2, _nQtdeConf, {_nQtdeConf} })
			Else
				 Aadd(_aSaldoDest,{(cAliasZD1)->NREGZD1, _cProduto, _cArmOrig, _aArmDes, _nQtdeDiverge, _nSaldoSB2, _nQtdeConf, {_nSaldoTec, _nQtdeConf - _nSaldoTec}})
			Endif 
		Endif
	Next
	//significa que pelo menos u registro ocorreu erro, preencher _cErro para retorno
	_cErro := ""
	If Len(_aErro) > 0
		For _nPos := 1 To Len(_aErro)
			_cErro += AllTrim(_aErro[_nPos])+ "  "
		Next
	Endif 	
	//Retornando falso ja aborto a processo
	If ! _lRet
		_cErro := "Problemas na importacao:"+' - ' + _cErro
		Return .F.
	Endif	

	//Caso ocorra erro na gravação não efetuar retornar erro total
	Begin Transaction
		For _nPos := 1 To Len(_aSaldoDest)
			_nRegZD1 		:= _aSaldoDest[_nPos,1]
			_cProduto		:= _aSaldoDest[_nPos,2]	 
			_cArmOrig		:= _aSaldoDest[_nPos,3]	 
			_aArmDes		:= _aSaldoDest[_nPos,4]	 
			_nQtdeDiverge	:= _aSaldoDest[_nPos,5]
			_nSaldoSB2		:= _aSaldoDest[_nPos,6]
			_nSaldoSB2		:= _aSaldoDest[_nPos,6]
			_nQtdeConf		:= _aSaldoDest[_nPos,7]
			_aSaldoMov		:= _aSaldoDest[_nPos,8]
			_aAuto			:= {}
			_lRet 			:= .F.
			//_cDocumento := SD3->(NextNumero("SD3",2,"D3_DOC",.T.))  //esta dando erro no processamento
			//Implementado pois em alguns casos não esta conseguindo localizar numeração DAC 07/06/2023 PEC042
			_cDocumento := ""
			For _nCount := 1 To 10
				_cDocumento  := Criavar("D3_DOC")
				_cDocumento	:= IIf(Empty(_cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),_cDocumento)
				If !Empty(_cDocumento)
					Exit
				Endif 
			Next 	
			If Empty(_cDocumento)
				_cErro := "Nao foi possivel criar numeracao no TOTVS, nao foi gravada a movimentacao"
				Aadd(_aDivergencia, {	_cProduto,;
										Alltrim(_cFornec),;
										Alltrim(_cLoja ),; 
										Alltrim(_cSerFor),; 
										Alltrim(_cNfFor),;
										_cArmOrig,; 
										_nQtdeDiverge,;
										_nQtdeConf,;
										_nSaldoSB2,;
										_cErro} )
				Exit
			Endif
			_cDocumento	:= A261RetINV(_cDocumento)
			aadd(_aAuto,{_cDocumento , dDataBase})    //Cabecalho
			//ZD1->(DbGoto(_nRegZD1))  //posiciono ZD1
			SB1->(DbSetOrder(1))
			If !SB1->(DbSeek(FWxFilial("SB1")+PadR(_cProduto, TamSx3('B1_COD') [1])))
				_cErro := "Nao localizado Produto "+_cProduto+" para execucao gravacao da movimentaao por ExecAuto"
				Aadd(_aDivergencia, {	_cProduto,;
										Alltrim(_cFornec),;
										Alltrim(_cLoja ),; 
										Alltrim(_cSerFor),; 
										Alltrim(_cNfFor),;
										_cArmOrig,; 
										_nQtdeDiverge,;
										_nQtdeConf,;
										_nSaldoSB2,;
										_cErro} )
				Exit
			Endif	
			For _nCount := 1 To Len(_aSaldoMov)
				_aLinha := {}
				If _aSaldoMov[_nCount] <= 0
					Loop
				Endif 
				//Origem
				aadd(_aLinha,{"D3_COD"    	, SB1->B1_COD 																						, Nil} ) //Cod Produto origem
				aadd(_aLinha,{"D3_DESCRI" 	, SB1->B1_DESC 																						, Nil} ) //descr produto origem
				aadd(_aLinha,{"D3_UM"     	, SB1->B1_UM																						, Nil} ) //unidade medida origem
				aadd(_aLinha,{"D3_LOCAL"  	, AllTrim(_cArmOrig)																				, Nil} ) //armazem origem
				aadd(_aLinha,{"D3_LOCALIZ"	, IIf(Localiza(SB1->B1_COD),FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ"),Space(15))					, Nil} ) //Informar endereço origem
				//Destino			
				aadd(_aLinha,{"D3_COD"		, SB1->B1_COD																						, Nil}) //cod produto destino
				aadd(_aLinha,{"D3_DESCRI"	, SB1->B1_DESC																						, Nil}) //descr produto destino
				aadd(_aLinha,{"D3_UM"		, SB1->B1_UM																						, Nil}) //unidade medida destino					
				aadd(_aLinha,{"D3_LOCAL"	, AllTrim( _aArmDes[_nCount] )																			, Nil}) //armazem destino  era  SB1->B1_LOCPAD
				aadd(_aLinha,{"D3_LOCALIZ"	, IIf(Localiza(SB1->B1_COD),FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ"),Space(15))					, Nil}) //Informar endereço destino
				aadd(_aLinha,{"D3_NUMSERI"	, CriaVar('D3_NUMSERI')																				, Nil}) //Numero serie
				aadd(_aLinha,{"D3_LOTECTL"	, CriaVar('D3_LOTECTL')																				, Nil}) //Lote Origem
				aadd(_aLinha,{"D3_NUMLOTE"	, CriaVar("D3_NUMLOTE")																				, Nil}) //sublote Origem
				aadd(_aLinha,{"D3_DTVALID"	, CriaVar("D3_DTVALID")																				, Nil}) //data validade
				aadd(_aLinha,{"D3_POTENCI"	, CriaVar('D3_POTENCI')																				, Nil}) // Potencia
				aadd(_aLinha,{"D3_QUANT"	, _aSaldoMov[_nCount]																						, Nil}) //Quantidade
				aadd(_aLinha,{"D3_QTSEGUM"	, CriaVar("D3_QTSEGUM") 																			, Nil}) //Seg unidade medida
				aadd(_aLinha,{"D3_ESTORNO"	, CriaVar("D3_ESTORNO")																				, Nil}) //Estorno
				aadd(_aLinha,{"D3_LOTECTL"	, CriaVar('D3_LOTECTL')	 																			, Nil}) //Lote destino
				aadd(_aLinha,{"D3_DTVALID"	, CriaVar("D3_DTVALID")																				, Nil}) //data validade Destino
				aadd(_aLinha,{"D3_ITEMGRD"	, CriaVar("D3_ITEMGRD")																				, Nil})	//Item Grade 
				aadd(_aLinha,{"D3_OBSERVA"	, "NF.TOTVS:"+AllTrim(_cNfFor)+"|"+AllTrim(_cSerFor)+"|"+AllTrim(_cFornec)+"|"+AllTrim(_cLoja) 		, Nil})	//Observacao
				aAdd(_aAuto, _aLinha)
			Next _nCount

			If Len(_aAuto) == 0 .Or. Len(_aLinha) == 0
				_cErro := "Nao foi possivel fazer a movimentacao interna, nao carregou os dados da movimentacao, verificar com ADM Sistemas TOTVS ." 
				//ESPFUN.-.PEC042.-.Controle.de.saldo.e.e-mail.apos.integracao.de.armazenagem
				//igualar qtde conferida a saldo b2
				add(_aDivergencia, {_cProduto,;
									Alltrim(_cFornec),;
									Alltrim(_cLoja ),; 
									Alltrim(_cSerFor),; 
									Alltrim(_cNfFor),; 
									_cArmOrig,;
									_nQtdeDiverge,;
									_nQtdeConf,;
									_nSaldoSB2,;
									_cErro} )
				Exit
			Endif	
			lMsErroAuto 	:= .F.
			lMsHelpAuto		:= .T.
			lAutoErrNoFile 	:= .t.
			MSExecAuto({|x,y| mata261(x,y)}, _aAuto, _nOpcAuto)
			_aJson := aClone(_aAuto)
			If lMsErroAuto
				_cErro := "Problemas no execauto MATA261, Nota Fiscal TOTVS!" 
				_aError := GetAutoGRLog()
				_cMsg 	:= "Problemas no execauto MATA261, Nota Fiscal TOTVS!" +CRLF
				For _nCount := 1 To Len(_aError)
					If !Empty((AllTrim(_aError[_nCount])))  	
						_cMsg	+= 	AllTrim(_aError[_nCount]) + CRLF
					EndIf		
				Next _nCount			
				Aadd(_aDivergencia, {	_cProduto,;
										Alltrim(_cFornec),;
										Alltrim(_cLoja ),; 
										Alltrim(_cSerFor),; 
										Alltrim(_cNfFor),;
										_cArmOrig,; 
										_nQtdeDiverge,;
										_nQtdeConf,;
										_nSaldoSB2,;
										_cMsg} )
				Exit
			Endif 
		    // se estiver em debug, pega o log inteiro do erro para uma analise mais detalhada
			/*
		    if lDebug 
				aLog   := GetAutoGRLog()
				_cErro += mostraerro(cStartPath+'ZWSR012.log')
				For _nX := 1 To Len(aLog)
					If !Empty(_cErro)
						_cErro += CRLF
					EndIf
					_cErro += aLog[_nX]
				Next _nX
			Endif		
			*/
			ZD1->(DbGoto(_nRegZD1))  //posiciono ZD1
			For _nCount := 1 To Len(_aSaldoMov)
				RecLock("ZD1", .F.)
				ZD1->ZD1_QTCONF += _aSaldoMov[_nCount]
				ZD1->ZD1_SLDIT	-= _aSaldoMov[_nCount]
				ZD1->( MsUnLock() )
			Next _nCount
			_lRet := .T.
		Next _nPos
		If !_lRet
			Disarmtransaction()
		Endif			

	End Transaction		
Return _lRet

/*
=====================================================================================
Programa.:              zGeraEntrada
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              29/06/2022
Descricao / Objetivo:   Gera Entrada das Notas Feitas pelo SINC
=====================================================================================
*/
Static function zGeraEntrada()
Local _lRet 			:= .T.
Local _aCabec  			:= {}
Local _aItem			:= {}
//Local _cDocumento     	:= ""
Local _nPos				:= 0
Local _cIdJson			:= ""
Local _cProduto			:= ""
Local _nQtdeConf		:= 0
Local _cArmEntr			:= AllTrim( GetNewPar( "CMV_PEC020", "01" ) )
Local aLog  			:= {}
Local _nX 				:= 0
Local cStartPath		:= GetSrvProfString("Startpath","")
Private lMsErroAuto 	:= .F.
Private lMsHelpAuto		:= .T.    
Private lAutoErrNoFile 	:= .T. 
	
//Begin Sequence
	For _nPos := 1 To Len(_aItens)
		_cIdJson	:= AllTrim(_aItens[_nPos]["id"])
		_cProduto	:= AllTrim(_aItens[_nPos]["cd_produto"])
		_nQtdeConf	:= _aItens[_nPos]["qt_conf"]
		If Empty(_cProduto)
			_cErro := "Codigo do produto esta em branco." 
			_lRet := .F.
			//Break
			Return .F.
		Endif	
		
		if fSZ1Val( _cIdJson )
			_cErro := "ID " + _cIdJson + " conferencia recebida anteriormente" 
			_lRet := .F.
			Return .F.
		endif
		
		SB1->(DbSetOrder(1))
		If !SB1->(DbSeek(FWxFilial("SB1")+PadR(_cProduto, TamSx3('B1_COD') [1])))
			_cErro := "Produto "+AllTrim(_cProduto)+" nao cadastrado no Totvs." 
			_lRet := .F.
			//Break
			Return .F.
		Else
			If SB1->B1_MSBLQL == "1"
				_cErro := "Produto "+AllTrim(_cProduto)+"  bloqueado no cadastrado Totvs." 
				_lRet := .F.
				//Break
				Return .F.
			EndIf
		Endif	
		If _nQtdeConf == 0
			_cErro := "Qtde conferida nao informada." 
			_lRet := .F.
			//Break
			Return .F.
		Endif
		SB2->(DbSetOrder(1))
		If !SB2->(DbSeek(FWxFilial("SB2")+PadR(_cProduto, TamSx3('B2_COD') [1])+PadR(_cArmEntr, TamSx3('B2_LOCAL') [1])))
			CriaSB2(AllTrim(_cProduto),AllTrim(_cArmEntr))
			//Ajustado tem que criar armazém para dar continuidade conforme alinhado com Zé DAC 17/02/2023
			//_cErro := "Produto "+AllTrim(_cProduto)+"  nao cadastrado no Estoque "+AllTrim(_cArmEntr)+" do Totvs." 
			//_lRet := .F.
			//Break
			//Return .F.
		EndIf
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(FWxFilial("SB1")+PadR(_cProduto , TamSx3('B1_COD') [1])))
			
			//_cDocumento := NextNumero("SD3",2,"D3_DOC",.T.)
		
		    _aCabec	:= {}
			_aItem	:= {}

			aadd(_aCabec, 	{ "D3_FILIAL"		, FWxFilial("SD3")															, NIL}) //01-FILIAL
			aadd(_aCabec, 	{ "D3_TM"			, "010"																		, NIL}) //02-TM
			aadd(_aCabec, 	{ "D3_EMISSAO"		, dDatabase																	, NIL}) //03-EMISSAO
			aAdd(_aItem,	{ { "D3_COD"		, SB1->B1_COD  																, NIL},;
							  { "D3_UM"			, SB1->B1_UM 																, NIL},;
							  { "D3_LOCAL"		, _cArmEntr																	, NIL},;
							  { "D3_QUANT"		, _nQtdeConf																, NIL},;
							  { "D3_OBSERVA"	, "NF.SINC:"+AllTrim(_cNfFor)+"|"+AllTrim(_cSerFor)+"|"+AllTrim(_cFornec) 	, NIL}})
			lMsErroAuto 	:= .F.
			lMsHelpAuto		:= .T.
			
			MSExecAuto({|x,y,z| MATA241(x,y,z)}, _aCabec,_aItem,3)
			_aJson := aClone(_aItem)
			If lMsErroAuto
				_cErro := "Problemas no execauto MATA241, Nota Fiscal SINC! " 
				
				// se estiver em debug, pega o log inteiro do erro para uma analise mais detalhada
				if lDebug 
					aLog   := GetAutoGRLog()
					_cErro += mostraerro(cStartPath+'ZWSR012.log')
					For _nX := 1 To Len(aLog)
						If !Empty(_cErro)
							_cErro += CRLF
						EndIf
						_cErro += aLog[_nX]
					Next _nX
				endif		
								
				_lRet  := .F.
				//Break
				Return .F.
			Else
				ZD1->(DbSetOrder(1))
				If !( ZD1->(DbSeek(FWxFilial("ZD1") + PadR(_cNfFor, TamSx3('ZD1_DOC') [1]) + PadR(_cSerFor, TamSx3('ZD1_SERIE') [1]) + PadR(_cFornec, TamSx3('ZD1_FORNEC') [1]) + PadR(_cLoja, TamSx3('ZD1_LOJA') [1]) + PadR(_cProduto , TamSx3('B2_COD') [1]) )))
					RecLock("ZD1", .T.)
						ZD1->ZD1_FILIAL := FWxFilial("ZD1")
						ZD1->ZD1_DOC	:= AllTrim(_cNfFor)
						ZD1->ZD1_SERIE 	:= AllTrim(_cSerFor)
						ZD1->ZD1_FORNEC	:= AllTrim(_cFornec)
						ZD1->ZD1_LOJA	:= Alltrim(_cLoja)
						ZD1->ZD1_COD	:= _cProduto
						ZD1->ZD1_QUANT	:= _nQtdeConf
						ZD1->ZD1_QTCONF	:= _nQtdeConf
					ZD1->( MsUnLock() )
				Else
					RecLock("ZD1", .F.)
						ZD1->ZD1_QUANT	:= ZD1->ZD1_QUANT  + _nQtdeConf
						ZD1->ZD1_QTCONF	:= ZD1->ZD1_QTCONF + _nQtdeConf
					ZD1->( MsUnLock() )
		
				EndIf
			EndIf	
		EndIf
	Next

//End Sequence

Return(_lRet)

//-------------------------------------------------------------------------

//-------------------------------------------------------------------------
Static Function fSZ1Val(cId)
Local lRet := .t.
Local _cAliasPesq	:= GetNextAlias()   

//DBSELECTAREA( "SZ1" )
//SZ1->(DbSetOrder(3))
cId := Padr( cId , 100 )
	/*
	If DbSeek( FwXFilial("SZ1") + cId )
		lRet := .F.
	Else
		lRet := .T.		
	Endif
	*/
//Implementado validando status pois pode gravar outros registros que o status não é recebido = 1 DAC 16/03/2023
BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
	SELECT 	SZ1.R_E_C_N_O_ AS NREGSZ1
	FROM  %Table:SZ1% SZ1			
	WHERE 	SZ1.Z1_FILIAL  	= %xFilial:SZ1%
		AND SZ1.Z1_IDJSON	= %Exp:cId%
		AND SZ1.Z1_STATUS	= '1' 
		AND SZ1.%notDel%
EndSQL	
If (_cAliasPesq)->(Eof()) .Or. (_cAliasPesq)->NREGSZ1 == 0
	lRet := .F.
Endif
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return lRet

/*
=====================================================================================
Programa.:              ZWSR012Monitor
@param 					_cStatus   	= Status que será gerado no SZ1 1-OK 2-Divergência 
						_cTab		= Tabela principal que esta sendo gravada na integração
						_cDoc   	= Numero do Cocumento a ser gravado, ja contém a série 
						_cErro    	= mensagem a ser gravada podendo ser de erro e ou exito 
						_dDataIni	= data inicial da importação 
						_cHsIni 	= hora inicial da importação 
						_cJson    	= Json para importação
						_nErro		= numero de retorno que ocasionou erro e ou exito
Autor....:              CAOA - DAC Denilso 
Data		            14/11/2022
Descricao / Objetivo	Funcionalidade que efetuara a gravação de dados no monitor 
Doc. Origem            	PEC020 - Monitor de Integrações WIS
Solicitante            	CAOA
Uso              		ZWSR012
Obs
@menu       			Nao Informado
@return					_lRet 		- Verdadeiro ou falso
@history 				DAC - 	15/02/2023 
								Implementação de envio de campos a serem gravados para SZ1	
=====================================================================================
*/
Static Function	ZWSR012Monitor(_cStatus, _cTab, _cDoc, _cErro, _dDataIni, _cHsIni, _cJson, _nErro )	
Local _lJob      := IsBlind()
Local _cUserName := If( _lJob,"CONF.MERC.RGLOG", Nil)   
Local _aCampos	 := {}  //Adicionar campos a serem gravador na tabela DAC  15/02/2023 
Local _cIdJson	 := ""
Local _cProduto	 := ""
Local _nQtdeConf := 0
Local _nPos


//tenho que verificar nos itens se veio o ID, gravara item a item para o monitor
If Len(_aItens) > 0
	For _nPos := 1 To Len(_aItens)
		_aCampos    := {}
		_cIdJson	:= AllTrim(_aItens[_nPos]["id"])
		_cProduto	:= AllTrim(_aItens[_nPos]["cd_produto"])
		_nQtdeConf	:= _aItens[_nPos]["qt_conf"]
		AAdd(_aCampos,{"Z1_IDJSON"	, _cIdJson 	, "id"   		})
		AAdd(_aCampos,{"Z1_COD"		, _cProduto , "cd_produto" 	})
		AAdd(_aCampos,{"Z1_QTCONF"	, _nQtdeConf, "qt_conf" 	})
		U_CAOA_GRVMONITOR(XFilial(_cTab),;		//Filail
						_cStatus,;				//Status
						"011",;					//Código do Processo
						/*cCodtpint*/,;			//Código do tipo
						_cErro,;				//Mensagem de retorno
						_cDoc,;					//Documento
						_dDataIni,;				//Data Inicio
						_cHsIni,;				//Hora Final
						_cJson,;				//Json
						If(_cStatus=="1", (_cTab)->(Recno()),0),; //Numero do Registro
						_cUserName,;			//Nome do Usuário na inclusão
						_nErro,;				//Retorno código
						_aCampos)				//Campos pré definidos para gravar no SZ1 
	Next _nPos					
Else
	U_CAOA_GRVMONITOR(XFilial(_cTab),;		//Filail
				_cStatus,;				//Status
				"011",;					//Código do Processo
				/*cCodtpint*/,;			//Código do tipo
				_cErro,;				//Mensagem de retorno
				_cDoc,;					//Documento
				_dDataIni,;				//Data Inicio
				_cHsIni,;				//Hora Final
				_cJson,;				//Json
				If(_cStatus=="1", (_cTab)->(Recno()),0),; //Numero do Registro
				_cUserName,;			//Nome do Usuário na inclusão
				_nErro,;				//Retorno código
				_aCampos)				//Campos pré definidos para gravar no SZ1 
Endif
Return Nil



/*
=====================================================================================
Programa.:              NotificaDiv -Função para envio de E-mail 
@param 					_aDivergencia  	= Matriz com dados dos erros no processo 
Autor....:              CAOA - DAC Denilso 
Data		            16/05/2023
Descricao / Objetivo	Funcionalidade responsável por enviar e-mail aos responsaveis (cadastro SX5 e-mail) referente a problemas com a integração de transferência 
Doc. Origem            	ESPFUN.-.PEC042.-.Controle.de.saldo.e.e-mail.apos.integracao.de.armazenagem
Solicitante            	CAOA
Uso              		ZwSR012
Obs
@menu       			Nao Informado
@return					_lRet 		- Verdadeiro ou falso
@history 					
=====================================================================================
*/
//******************************************
//Função para envio de E-mail  
Static Function NotificaDiv(_aDivergencia)  	// (cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,Rotina,	Observação	, cReplyTo	)Local aMailDest     := StrTokArr( Alltrim(Getmv("CMV_WMS024")),  ";" )
//******************************************
Local _cEmailDest   := ""  
Local _cMailCopia   := ""
Local _cAssunto	    := "Falha no envio do arquivo de confirmação Armazenagem WIS sigapec"
Local _cHtml        := ""
Local _cAttach      := ""
Local _lMsgErro     := .F.
Local _lMsgOK       := .F.
Local _cObservacao  := ""
Local _cReplyTo	    := ""
Local _cRotina      := "ZWSR012"
Local _cAliasPesq	:= GetNextAlias()
Local _cCodProd 	:= ""	
Local _cCodFornec 	:= ""
Local _cLojaFornec	:= ""
Local _cSerieNF		:= ""
Local _cNfFor		:= ""	
Local _nQtProtheus	:= ""
Local _nQtRgLog		:= ""	
Local _cNome		:= ""
Local _cDescrPrd	:= ""
Local _cMens        := ""
Local _lRet			:= .T.
Local _cChaveSX5	:= "1B"
Local _nDif
Local _nPos
Local _cArmazem
Local _nSaldoSB2

Default _aDivergencia	:= {}

Begin Sequence

	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT 	SX5.X5_DESCRI 
		FROM  	%Table:SX5% SX5
		WHERE 		SX5.X5_FILIAL 	= %xFilial:SX5%
				AND SX5.X5_TABELA 	= %Exp:_cChaveSX5%
				AND SX5.%notDel%
	EndSql
	If (_cAliasPesq)->(Eof())
		Conout("ZWSR012 - Não informado e-mail na tabela SX5, referentes a inconsistencias para envio de e-mail ! Verificar com ADM Sistemas")
		_lRet := .F.
		Break
	EndIf
	(_cAliasPesq)->(DbGotop())
	_cEmailDest	:= ""
	While (_cAliasPesq)->(!Eof())
		If !Empty((_cAliasPesq)->X5_DESCRI)
			_cEmailDest	+= AllTrim((_cAliasPesq)->X5_DESCRI)+","
		EndIf	
		(_cAliasPesq)->(DbSkip())
	EndDo
	If Empty(_cEmailDest)
		Conout("ZWSR012 - Não informado e-mail na tabela SX5, referentes a inconsistencias para envio de e-mail ! Verificar com ADM Sistemas")
		_lRet := .F.
		Break
	EndIf
	_cEmailDest := SubsTr(_cEmailDest,1,Len(_cEmailDest)-1)  //retirar a virgula do final
	//Fechar arquivo temporario para novo select
	(_cAliasPesq)->(DbCloseArea())

	If Len(_aDivergencia) == 0
		Conout("ZWSR012 - Não foi recebido dados referentes a inconsistencias para envio de e-mail ! Verificar com ADM Sistemas")
		_lRet := .F.
		Break
	EndIf
	_cCodProd 		:=  AllTrim(_aDivergencia[1,1])
	_cCodFornec 	:=  AllTrim(_aDivergencia[1,2])
	_cLojaFornec	:=  AllTrim(_aDivergencia[1,3])
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT 	ISNULL(SA2.R_E_C_N_O_,0) NREGSA2, 
				ISNULL(SB1.R_E_C_N_O_,0) NREGSB1
		FROM  	%Table:SA2% SA2
		LEFT JOIN %Table:SB1% SB1
				ON 	SB1.B1_FILIAL 	= %xFilial:SB1%
				AND	SB1.B1_COD		= %Exp:_cCodProd%
				AND SB1.%notDel%
		WHERE 		SA2.A2_FILIAL 	= %xFilial:SA2%
				AND SA2.A2_COD 		= %Exp:_cCodFornec%
				AND SA2.A2_LOJA		= %Exp:_cLojaFornec%
				AND SA2.%notDel%
	EndSql
	If (_cAliasPesq)->(!Eof())
		If (_cAliasPesq)->NREGSA2 > 0
			SA2->(DbGoto((_cAliasPesq)->NREGSA2))
			_cNome 		:= AllTrim(SA2->A2_NOME)
		EndIf	
		If (_cAliasPesq)->NREGSB1 > 0
			SB1->(DbGoto((_cAliasPesq)->NREGSB1))
			_cDescrPrd 	:= AllTrim(SB1->B1_DESC)
		EndIf	
	EndIf 

	_cHtml := "<h3>"                                                                       
    _cHtml +=    "  Ocorreram divergências no recebimento integração WIS em Transferência. 	<br/>" 
    _cHtml +=    "  As quantidades não estão divergentes com os dados de armazenagem, verificar. <br/>" 
    _cHtml +=    "  Data do processament: " + dtoc(date())  + " " + time() + "      		<br/><br/>" 
    _cHtml +=    "  Detalhe do erro:                                                   		<br/>" 
    _cHtml +=    "</h4>"     

	/*		add(_aDivergencia, {_cProduto,;				//1
								Alltrim(_cFornec),;		//2
								Alltrim(_cLoja ),; 		//3
								Alltrim(_cSerFor),; 	//4
								Alltrim(_cNfFor),; 		//5
								_cArmOrig,;				//6
								_nQtdeDiverge,;			//7
								_nQtdeConf,;			//8
								_nSaldoSB2,;			//9
								_cErro} )				//10
	*/
	For _nPos := 1 To Len(_aDivergencia)
		_cCodProd 		:=  AllTrim(_aDivergencia[_nPos,1])
		_cCodFornec 	:=  AllTrim(_aDivergencia[_nPos,2])
		_cLojaFornec	:=  AllTrim(_aDivergencia[_nPos,3])
		_cSerieNF		:=  AllTrim(_aDivergencia[_nPos,4])
		_cNfFor			:=  AllTrim(_aDivergencia[_nPos,5])
		_cArmazem		:=  AllTrim(_aDivergencia[_nPos,6])
		_nQtRgLog		:=  If(_aDivergencia[_nPos,7]==Nil,"",AllTrim(Str(_aDivergencia[_nPos,7])))
		_nQtProtheus	:=  If(_aDivergencia[_nPos,8]==Nil,"",AllTrim(Str(_aDivergencia[_nPos,8])))
		_nSaldoSB2		:=  If(_aDivergencia[_nPos,9]==Nil,"",AllTrim(Str(_aDivergencia[_nPos,9])))
		_nDif			:=  If(_aDivergencia[_nPos,8]==Nil,"",AllTrim(Str(_aDivergencia[_nPos,7] - _aDivergencia[_nPos,8])))  
		_cMens			:=  AllTrim(_aDivergencia[_nPos,10])

		_cHtml += "Fornecedor codigo....: "			+ _cCodFornec+"-"+_cLojaFornec+" "+_cNome+"<br/>"
		_cHtml += "Nota Fiscal................: "	+ _cSerieNF+"-"+_cNfFor+"<br/>"
		_cHtml += "Cod Produto..............: "		+ _cCodProd+" "+_cDescrPrd+"<br/>"
		_cHtml += "Armazem...................: "	+_cArmazem+"<br/>"
    	_cHtml += "<br/>"
		If !Empty(_nQtRgLog)
			_cHtml += "Qtde enviada RgLog......................: "+_nQtRgLog+"<br/>"
		EndIf
		If !Empty(_nQtProtheus)
			_cHtml += "Qtde disponível para recebimento.: "				+_nQtProtheus+"<br/>"
			_cHtml += "Qtde recebida.................................: "+_nQtProtheus+"<br/>"
			_cHtml += "Qtde divergente sem recebimento..: "+ _nDif+"<br/>"	
		Endif
    	_cHtml += "<br/>"
    	_cHtml += "Erro....: "+ _cMens+"<br/>"
    	_cHtml += "<br/>"
	Next	 
   	_cHtml += "<br/><br/>"
    _cHtml +=    " <h5>Esse email foi gerado pela rotina " + _cRotina + " </h5>"       
   	_cHtml += "<br/><br/>"
    _lRet := U_ZGENMAIL(_cEmailDest,;
						_cMailCopia,; 
						_cAssunto,;
						_cHtml,;
						_cAttach,;
						_lMsgErro,;
						_lMsgOK,;
						_cRotina,;	
						_cObservacao,; 
						_cReplyTo	)

	If !_lRet
		Conout("ZWSR012 - Problemas com Envio de Email "+cHtml)
	Endif
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet




/*
entrada

{
    "empresa" : "02", 
    "filial" : "2020012001", 
    "usuario" : "RGLOG.REST", 
    "senha" : "CaOa!RgLogRest@2021", 
    "nota_fiscal" : "82400", 
    "serie_nf" : "1", 
    "cod_fornecedor" : "3518732002886", 
    "Itens" : [
        {
            "id" : "20220321101544.0025725840.0220327923.0000082400.01.3518732002886.0000000000000R-873712E500", 
            "cd_produto" : "R-873712E500", 
            "qt_conf" : 1.0
        }
    ]
}


transferencia

{
	"empresa":"02",
	"filial":"2020012001",
	"usuario":"RGLOG.REST",
	"senha":"CaOa!RgLogRest@2021",
   	"nota_fiscal":"565384",
	"serie_nf":"7",
   	"cod_fornecedor":"900307401",
	"Itens":[
    	{
            "id" : "20230210145035.0025746481.023023297.000565384.07.0000900307401.0000000000R-865172S300",
			"cd_produto":"R-865172S300",
			"qt_conf":20
		}
	]
}

*/


/*Estrutura da string Json

//recebida em 15/02/2023 
{
    "empresa" : "02", 
    "filial" : "2020012001", 
    "usuario" : "RGLOG.REST", 
    "senha" : "CaOa!RgLogRest@2021", 
    "nota_fiscal" : "48205", 
    "serie_nf" : "6", 
    "cod_fornecedor" : "3471344000410", 
    "Itens" : [
        {
            "id" : "20171116161527.0004349995.0171118111.0000048205.06.3471344000410.0000000000R-553112S400-BI", 
            "cd_produto" : "R-553112S400-BI", 
            "qt_conf" : 2.0
        }
    ]
}

{
	"empresa":"02",
	"filial":"2020012001",
	"usuario":"RGLOG.REST",
	"senha":"CaOa!RgLogRest@2021",
   	"nota_fiscal":"000352748",
	"serie_nf":"5",
   	"cod_fornecedor":"6293",
	"Itens":[
    	{
			"cd_produto":"R-254853J000",
			"qt_conf":2
		},
    	{
			"cd_produto":"R-052034F520",
			"qt_conf":2
		}
	]
}

{
    "empresa" : "02", 
    "filial" : "2020012001", 
    "usuario" : "RGLOG.REST", 
    "senha" : "CaOa!RgLogRest@2021", 
    "nota_fiscal" : "48205", 
    "serie_nf" : "6", 
    "cod_fornecedor" : "3471344000410", 
    "Itens" : [
        {
            "id" : "20171116161527.0004349995.0171118111.0000048205.06.3471344000410.0000000000R-553112S400-BI", 
            "cd_produto" : "R-553112S400-BI", 
            "qt_conf" : 2.0
        }
    ]
}
*/
