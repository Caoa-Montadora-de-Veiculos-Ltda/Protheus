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
	
	Private _aItens		:= {}
	Private _cErro		:= ""
	Private _cNfFor 	:= ""
	Private _cSerFor 	:= ""
	Private _cFornec	:= ""
	Private _cLoja		:= ""
	Private _cTpNf		:= ""
	Private lDebug 		:= .F.
	Private _aJson		:= {}
	
	//-- Cabeçalho a incluir
	Private aAuto		:= {}
	Private _aItem		:= {}
	Private _atotitem	:= {} 

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
	
	If Len(AllTrim(oParseJSON:cod_fornecedor)) == 9  .And. Substr(AllTrim(oParseJSON:cod_fornecedor),1,1) == "9"
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
	EndIf
	_cLog := chr(10)
	_cLog += "Nf ........: " + _cNfFor      + chr(10)
	_cLog += "Serie......: " + _cSerFor     + chr(10)
	_cLog += "Fornecedor.: " + _cFornec     + chr(10)
	_cLog += "Loja.......: " + _cLoja       + chr(10)
	_cLog += "Tipo.......: " + _cTpNf       + chr(10)
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
	_lTransf := .F.
	If _cTpNf == "T"
		If Len(_aItens) > 0
			_lTransf := zGeraTransf()
		EndIf
	Else
		If Len(_aItens) > 0
			_lTransf := zGeraEntrada()
		EndIf		
	EndIf
	_cLog += "Message....: " + _cErro
	if Len(_aJson) > 0
		ojsonLog:set(_aJson)
		_cLog += chr(10) + "Array Auto.: " + ojsonLog:toJSON()
	endif

	If _lTransf
		oJsonRet['errorCode']		:= 100
		oJsonRet['Message'] 		:= "Confirmacao de mercadorias recebida com sucesso"
		oJsonRet['nota_fiscal']		:= Val(_cNfFor)
		oJsonRet['cod_fornecedor']	:= oParseJSON:cod_fornecedor
		_cErro := "Confirmacao de mercadorias recebida com sucesso"
		ZWSR012Monitor("1",_cTab, _cDoc, _cErro, _dDataIni, _cHsIni, cJson, 100 /*_nErro*/ )	
		::SetResponse( oJsonRet:ToJson() )
	Else
		oJsonRet['errorCode'] 		:= 400
		oJsonRet['errorMessage']	:= AllTrim(_cErro)
		//_cErro ja foi informado em caso de problemas
		ZWSR012Monitor("2",_cTab, _cDoc, _cErro, _dDataIni, _cHsIni, cJson, 400 /*_nErro*/ )	
		::SetResponse( oJsonRet:ToJson() )

	EndIf
	Conout(_cLog)//Logs de Monitoramento
 
	Conout("ZWSR012 - Integracao Confirmacao de mercadorias recebidas RGLOG PUT - Final "+DtoC(date())+" "+Time())

Return .T.

/*
============================================================================================
Programa.:              zGeraTransf
Autor....:              CAOA - Evandro Ap. Mariano dos Santos
Data.....:              29/06/2022
Descricao / Objetivo:   Realiza a conferencia e faz a transferencia do 80 para 01
============================================================================================
*/
Static Function zGeraTransf()
	Local _lRet 			:= .T.
	Local _cDocumen     	:= ""
	Local _cProduto			:= ""
	Local _cIdJson			:= ""
	Local _aAuto  			:= {}
	Local _aLinha 			:= {}
	Local _aTransf			:= {}
	Local _nOpcAuto     	:= 3
	Local _nPos				:= 0
	Local _nX				:= 1
	Local _nQtdeConf		:= 0
	Local _nSaldoSB2		:= 0
	Local _nSaldoTec		:= 0
	Local _nQtdeTec			:= 0
	Local _cArmOrig			:= AllTrim( GetNewPar( "CMV_PEC019", "80" ) )
	Local _cArmDes			:= AllTrim( GetNewPar( "CMV_PEC020", "01" ) )
	Local _cArmTec			:= AllTrim( GetNewPar( "CMV_PEC028", "02" ) )
	Local _aArmDes			:=	{_cArmTec,_cArmDes}
	Local cTmpAlias			:= GetNextAlias()
	Local cQuery			:= ""
	Local aArea				:= {}
	Local cAliasZD1			:= GetNextAlias()
	Local cQryZD1			:= ""
	Local aArea2			:= {}
	Local aLog 				:= {}
	Local cStartPath 		:= GetSrvProfString("Startpath","")

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto		:= .T.    
	Private lAutoErrNoFile 	:= .T. 
	
	//Begin Sequence

		For _nPos := 1 To Len(_aItens)
			
			_cIdJson	:= AllTrim(_aItens[_nPos]["id"])
			_cProduto	:= AllTrim(_aItens[_nPos]["cd_produto"])
			_nQtdeConf	:= _aItens[_nPos]["qt_conf"]

			If Select(cTmpAlias) <> 0
				(cTmpAlias)->(DbCloseArea())
			EndIf
			
			if fSZ1Val( _cIdJson )
				_cErro := "ID " + _cIdJson + " conferencia recebida anteriormente" 
				_lRet := .F.
				Return .F.
			endif
			
			aArea2  := GetArea()

			cQryZD1:= ""
			cQryZD1 += " SELECT ZD1.ZD1_LOCAL													"+(Chr(13)+Chr(10))
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
			If (cAliasZD1)->(Eof())
				_cErro := "Nota Fiscal não encontrada para conferencia." 
				_lRet := .F.
				//Break
				Return .F.
			Else
				If AllTrim((cAliasZD1)->ZD1_LOCAL) == "90"
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
			EndIf
			(cAliasZD1)->(DbCloseArea())
			RestArea(aArea2)

			If Empty(_cProduto)
				_cErro := "Codigo do produto esta em branco." 
				_lRet := .F.
				//Break
				Return .F.
			Endif	

			SB1->(DbSetOrder(1))
			If !SB1->(DbSeek(FWxFilial("SB1")+PadR(_cProduto, TamSx3('B1_COD') [1])))
				_cErro := "Produto "+AllTrim(_cProduto)+"  nao cadastrado no Totvs." 
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

			NNR->(DbSetOrder(1))
			NNR->(DbSeek(FWxFilial("SB2")))
			While NNR->(!Eof()) .And. NNR->NNR_FILIAL == FWxFilial("SB2")

				SB2->(DbSetOrder(1))
				If !SB2->(DbSeek(FWxFilial("SB2")+PadR(_cProduto, TamSx3('B2_COD') [1])+PadR(NNR->NNR_CODIGO,TamSx3('B2_LOCAL') [1])))
					CriaSB2(Alltrim(_cProduto),Alltrim(NNR->NNR_CODIGO))
				EndIf
				NNR->(DbSkip())
			End

			If _nQtdeConf == 0
				_cErro := "Qtde conferida nao informada." 
				_lRet := .F.
				//Break
				Return .F.
			Endif
			
			_nQtdeTec := SB1->B1_XRESTEC

			SB2->(DbSetOrder(1))
			If SB2->(DbSeek(FWxFilial("SB2")+PadR(_cProduto, TamSx3('B2_COD') [1])+PadR(_cArmOrig, TamSx3('B2_LOCAL') [1])))

				_nSaldoSB2 := SB2->(SaldoSb2())
				
				If _nSaldoSB2 < _nQtdeConf
					_cErro := "Qtde conferida maior que Saldo do Totvs." 
					_lRet := .F.
					//Break
					Return .F.
				EndIf

			Else
				CriaSB2(AllTrim(_cProduto),AllTrim(_cArmOrig))
			    //_cErro := "Produto "+AllTrim(_cProduto)+"  nao cadastrado no Estoque "+AllTrim(_cArmOrig)+" do Totvs." 
				//_lRet := .F.
				//Break
			EndIf
			// Valida se o Produto tem Quantidade minima para saldo no armazem tecnico	
			if _nQtdeTec > 0
				SB2->(DbSetOrder(1))
				If SB2->(DbSeek(FWxFilial("SB2")+PadR(_cProduto, TamSx3('B2_COD') [1])+PadR(_cArmTec, TamSx3('B2_LOCAL') [1])))				
					_nSaldoTec := SB2->(SaldoSb2())
					_nSaldoTec := _nQtdeTec - _nSaldoTec
				else
					CriaSB2(AllTrim(_cProduto),AllTrim(_cArmTec))
					//_cErro := "Produto "+AllTrim(_cProduto)+" nao cadastrado no Estoque "+AllTrim(_cArmTec)+" do Totvs." 
					//_lRet := .F.
					//Break
				EndIf
			endif	
			
			If !SB2->(DbSeek(FWxFilial("SB2")+PadR(_cProduto, TamSx3('B2_COD') [1])+PadR(_cArmDes, TamSx3('B2_LOCAL') [1])))
				CriaSB2(AllTrim(_cProduto),AllTrim(_cArmDes))
				//_cErro := "Produto "+AllTrim(_cProduto)+" nao cadastrado no Estoque "+AllTrim(_cArmDes)+" do Totvs." 
				//_lRet := .F.
				//Break
			EndIf
						
			/*
			ZD1->(DbSetOrder(1))
			If !ZD1->(DbSeek(FWxFilial("ZD1")+ PadR(_cNfFor, TamSx3('ZD1_DOC') [1]) + PadR(_cSerFor, TamSx3('ZD1_SERIE') [1]) + PadR(_cFornec, TamSx3('ZD1_FORNEC') [1]) + PadR(_cLoja, TamSx3('ZD1_LOJA') [1]) + PadR(_cProduto, TamSx3('B2_COD') [1]) ))	
			*/
			aArea  := GetArea()
			cQuery := ""
			cQuery += " SELECT * 																"+(Chr(13)+Chr(10))
			cQuery += " FROM "+RetSqlName("ZD1")+" ZD1											"+(Chr(13)+Chr(10))
			cQuery += " WHERE	ZD1.ZD1_FILIAL 	= '"	+FWxFilial("ZD1")+"' 					"+(Chr(13)+Chr(10))
			cQuery += " 	AND ZD1.ZD1_DOC		LIKE '%"+Alltrim(Str(Val(Alltrim(_cNfFor))))+"%'"+(Chr(13)+Chr(10))
			cQuery += " 	AND ZD1.ZD1_SERIE 	= '"	+Alltrim(_cSerFor )					+"' "+(Chr(13)+Chr(10))
			cQuery += " 	AND ZD1.ZD1_FORNEC	= '"	+Alltrim(_cFornec )					+"' "+(Chr(13)+Chr(10))
			cQuery += " 	AND ZD1.ZD1_LOJA	= '"	+Alltrim(_cLoja   )					+"' "+(Chr(13)+Chr(10))
			cQuery += " 	AND ZD1.ZD1_COD		= '"	+Alltrim(_cProduto)					+"' "+(Chr(13)+Chr(10))
			cQuery += " 	AND ZD1.D_E_L_E_T_	= ' '			        						"+(Chr(13)+Chr(10))
			If Select(cTmpAlias) <> 0 ; (cTmpAlias)->(DbCloseArea()) ; EndIf
			DbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cTmpAlias, .F., .T. )

			(cTmpAlias)->(DbGoTop())
			If (cTmpAlias)->(Eof())
				_cErro := "Nao existe controle de conferencia para esse item - ZD1." 
				_lRet := .F.
				//Break
				Return .F.
			Else
				If _nQtdeConf > (cTmpAlias)->ZD1_SLDIT
					_cErro := "Qtde conferida maior que o saldo a conferir - ZD1." 
					_lRet := .F.
					//Break
					Return .F.
				EndIf
			EndIf
			If Select(cTmpAlias) <> 0 ; (cTmpAlias)->(DbCloseArea()) ; EndIf
			RestArea(aArea)

			_cDocumen := NextNumero("SD3",2,"D3_DOC",.T.)
			aadd(_aAuto,{_cDocumen , dDataBase})    //Cabecalho

			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(FWxFilial("SB1")+PadR(_cProduto , TamSx3('B1_COD') [1])))
				IF _nQtdeConf <= _nSaldoTec
					_aSaldoDest := {_nQtdeConf}
					
				ELSE
					_aSaldoDest := {_nSaldoTec, _nQtdeConf - _nSaldoTec}
				ENDIF
				
				For _nX := 1 To Len(_aSaldoDest)
					_aLinha := {}
					if _aSaldoDest[_nX] <= 0
						//_nX++
						loop
					endif 
					
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
					aadd(_aLinha,{"D3_LOCAL"	, AllTrim( _aArmDes[_nX] )																			, Nil}) //armazem destino  era  SB1->B1_LOCPAD
					aadd(_aLinha,{"D3_LOCALIZ"	, IIf(Localiza(SB1->B1_COD),FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ"),Space(15))					, Nil}) //Informar endereço destino

					aadd(_aLinha,{"D3_NUMSERI"	, CriaVar('D3_NUMSERI')																				, Nil}) //Numero serie
					aadd(_aLinha,{"D3_LOTECTL"	, CriaVar('D3_LOTECTL')																				, Nil}) //Lote Origem
					aadd(_aLinha,{"D3_NUMLOTE"	, CriaVar("D3_NUMLOTE")																				, Nil}) //sublote Origem
					aadd(_aLinha,{"D3_DTVALID"	, CriaVar("D3_DTVALID")																				, Nil}) //data validade
					aadd(_aLinha,{"D3_POTENCI"	, CriaVar('D3_POTENCI')																				, Nil}) // Potencia
					aadd(_aLinha,{"D3_QUANT"	, _aSaldoDest[_nX]																						, Nil}) //Quantidade
					aadd(_aLinha,{"D3_QTSEGUM"	, CriaVar("D3_QTSEGUM") 																			, Nil}) //Seg unidade medida
					aadd(_aLinha,{"D3_ESTORNO"	, CriaVar("D3_ESTORNO")																				, Nil}) //Estorno
					aadd(_aLinha,{"D3_LOTECTL"	, CriaVar('D3_LOTECTL')	 																			, Nil}) //Lote destino
					aadd(_aLinha,{"D3_DTVALID"	, CriaVar("D3_DTVALID")																				, Nil}) //data validade Destino
					aadd(_aLinha,{"D3_ITEMGRD"	, CriaVar("D3_ITEMGRD")																				, Nil})	//Item Grade 
					aadd(_aLinha,{"D3_OBSERVA"	, "NF.TOTVS:"+AllTrim(_cNfFor)+"|"+AllTrim(_cSerFor)+"|"+AllTrim(_cFornec)+"|"+AllTrim(_cLoja) 		, Nil})	//Observacao

					aAdd(_aAuto, _aLinha)
					aAdd(_aTransf,{_cProduto,_aSaldoDest[_nX]})
					
				Next _nX
			EndIf					
		Next

		If Len(_aTransf) > 0
			
			lMsErroAuto 	:= .F.
			lMsHelpAuto		:= .T.
			lAutoErrNoFile 	:= .t.

			MSExecAuto({|x,y| mata261(x,y)}, _aAuto, _nOpcAuto)
			_aJson := aClone(_aAuto)
			If lMsErroAuto
				_cErro := "Problemas no execauto MATA261, Nota Fiscal TOTVS!" 
				
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
				
				_lRet := .F.
    			//Break
			Else
				For _nPos := 1 To Len(_aTransf)
					/*
					ZD1->(DbSetOrder(1))
					If ZD1->(DbSeek(FWxFilial("ZD1")+ PadR(_cNfFor, TamSx3('ZD1_DOC') [1]) + PadR(_cSerFor, TamSx3('ZD1_SERIE') [1]) + PadR(_cFornec, TamSx3('ZD1_FORNEC') [1]) + PadR(_cLoja, TamSx3('ZD1_LOJA') [1]) + PadR(_aTransf[_nPos][01] , TamSx3('B2_COD') [1]) ))
					*/
					aArea  := GetArea()
					cQuery := ""
					cQuery += " SELECT * 																"+(Chr(13)+Chr(10))
					cQuery += " FROM "+RetSqlName("ZD1")+" ZD1											"+(Chr(13)+Chr(10))
					cQuery += " WHERE	ZD1.ZD1_FILIAL 	= '"	+FWxFilial("ZD1")+"' 					"+(Chr(13)+Chr(10))
					cQuery += " 	AND ZD1.ZD1_DOC		LIKE '%"+Alltrim(Str(Val(Alltrim(_cNfFor))))+"%'"+(Chr(13)+Chr(10))
					cQuery += " 	AND ZD1.ZD1_SERIE 	= '"	+Alltrim(_cSerFor 			)		+"' "+(Chr(13)+Chr(10))
					cQuery += " 	AND ZD1.ZD1_FORNEC	= '"	+Alltrim(_cFornec 			)		+"' "+(Chr(13)+Chr(10))
					cQuery += " 	AND ZD1.ZD1_LOJA	= '"	+Alltrim(_cLoja   			)		+"' "+(Chr(13)+Chr(10))
					cQuery += " 	AND ZD1.ZD1_COD		= '"	+Alltrim(_aTransf[_nPos][01])		+"' "+(Chr(13)+Chr(10))
					cQuery += " 	AND ZD1.D_E_L_E_T_	= ' '			        						"+(Chr(13)+Chr(10))
					If Select(cTmpAlias) <> 0 ; (cTmpAlias)->(DbCloseArea()) ; EndIf
					DbUseArea( .T., "TOPCONN", TcGenQry(,, cQuery), cTmpAlias, .F., .T. )

					(cTmpAlias)->(DbGoTop())
					If (cTmpAlias)->(!Eof())
						ZD1->(DbGoTo((cTmpAlias)->R_E_C_N_O_))
						RecLock("ZD1", .F.)
							ZD1->ZD1_QTCONF := ZD1->ZD1_QTCONF + _aTransf[_nPos][02]
							ZD1->ZD1_SLDIT	:= ZD1->ZD1_SLDIT  - _aTransf[_nPos][02]
						ZD1->( MsUnLock() )
					EndIf
					If Select(cTmpAlias) <> 0 ; (cTmpAlias)->(DbCloseArea()) ; EndIf
					RestArea(aArea)
				Next	
			EndIf
		EndIf
		
	//End Sequence

Return(_lRet)

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
	//Local _cDocumen     	:= ""
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
				
				//_cDocumen := NextNumero("SD3",2,"D3_DOC",.T.)
 			
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

