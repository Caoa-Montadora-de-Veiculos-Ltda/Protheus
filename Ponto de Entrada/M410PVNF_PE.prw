#Include "Totvs.Ch"

/*/{Protheus.doc} M410PVNF
	Ponto de Entrada - Geração de notas fiscais. Validação antes da execução para geração de NF's.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		17/04/2019
	@version 	1.0
	@param 		ParamIxb, number, *nRecSC5* - Número de *Pedido de Venda* *(`SC5->C5_NUM`)*
	@return 	logical, *Item* ou *Pedido de Venda* válido para regra CAOA de *Liberação de Crédito*
	@see 		TDN - https://tdn.totvs.com/x/mIRn
	@obs		Este PE também é chamado pelo PE M460MARK
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
	@history 	04/04/2023	, DAC, Revitalização Limite de Crédito
							  GRUPO CAOA GAP FIN108 - Revitalização Credito [ Montadora ]  
	/*/

User Function M410PVNF()
//Local _nRecSC5	:= ParamIxb
Local _lRet			:= .T.
Local _aArea		:= GetArea()
Local _lJob			:= IsBlind()
Local _oSay

	Conout( "Início PE M410PVNF" )
	If !_lJob
		FwMsgRun(,{ |_oSay| _lRet := M410PVNFLC(@_oSay) }, 'Limite Crédito','Avaliando limite de crédito, aguarde...')  //Separação Orçamentos / Aguarde
	Else
		_lRet	:= M410PVNFLC()	//Função responsavel pelo Limite de Crédito
	Endif
	RestArea(_aArea)
Return _lRet


/*/{Protheus.doc} M410PVNFLC
	Função responsável pelo Limite de Crédito na emissão da Nota para Anapolis.
	@type 		function
	@author 	CAOA - DAC Denilso
	@since 		04/04/2023
	@version 	1.0
	@param 		
	@return 	logical, *Item* ou *Pedido de Venda* válido para regra CAOA de *Liberação de Crédito*
	@project	GRUPO CAOA GAP FIN108 - Revitalização Credito [ Montadora ]
	@see 		TDN - https://tdn.totvs.com/x/mIRn
	@obs		Tem que estar posicionado SC5
	@history 	04/04/2023	, DAC, Revitalização Limite de Crédito  

	/*/

Static Function M410PVNFLC(_oSay)
//Local _nRecSC5	:= ParamIxb
Local _lRet			:= .T.
Local _aMsg			:= {}
Local _nLimAvalia	:= 0   //Residuo do limite de crédito caso não tenha aprovação
Local _cTpOper      := AllTrim(SuperGetMV( "CAOA_TPLIM" ,, ""))  //Tipos de Operação para analise do crédito - CAOA   54;91;90;67;82;93
Local _cTpPgtoEsp	:= AllTrim(SuperGetMV( "CMV_PEC039" ,, "" ) ) 	//Condição de Pagamento a qual liberará sem avaliação do Limite de Crédito
Local _lJob			:= IsBlind()
Local _cFaseRet
Local _cMens
Local _nPos
Local __cCliLiCred  := AllTrim(SuperGetMV( "CMV_FAT014" ,, "" ) ) //"00057601"

Begin Sequence
  	If !Empty(SC5->C5_NOTA)
		AAdd(_aMsg, "Pedido "+SC5-C5_NUM+" possui nota fiscal "+SC5->C5_NOTA+" !")
        _lRet := .F.
		Break
    EndIf
	//Encontrar Tipo de Operação para avaliar
	_cTpOperPed := XLOCTPOPPE("SC6",SC5->C5_NUM)  	
	If Empty(_cTpOperPed)
		AAdd(_aMsg, "Parâmetro tipo de Operação, não contém informações !")
        _lRet := .F.
		Break
	Endif
	If !_cTpOperPed $ _cTpOper
		Break
	EndIf
	//somar itens do pedido	
	_nTotPedido	:= M410PVNFTNF(SC5->C5_NUM)
	If _nTotPedido == 0
		AAdd(_aMsg, "Total dos itens zerados !")
        _lRet := .F.
		Break
	Endif
    //Se estiver cadastrado parâmetro para condição especial de pgto liberará o limite de crédito automaticamente
    If !Empty(_cTpPgtoEsp) .And. SC5->C5_CONDPAG $ _cTpPgtoEsp
        _cMens := "Pedido "+SC5->C5_NUM+ " liberado conforme condição de pgto especial ! "
        AAdd(_aMsg, _cMens )
		U_ZGENLZA2(SC5->C5_CONDPAG, _cTpPgtoEsp, "C5_CONDPAG", "LIBERACAO ESPECIAL", _cMens ,/*_cUserSol*/)
        _lRet := .T.
        Break
    EndIf
	if SC5->C5_CLIENTE + SC5->C5_LOJACLI $ __cCliLiCred    //Byapass da validação de credito
		_cFaseRet := "0"
		Sleep(5000)
	Else
		_cFaseRet := U_XFASLIMCRE( "SC5", SC5->C5_CLIENTE, SC5->C5_NUM, _nTotPedido, _cTpOperPed, SC5->C5_CONDPAG, "0", @_nLimAvalia, @_aMsg)  //ZPECFUNA
	EndIf

	If _cFaseRet <> "0"
		_lRet		:= .F.
		Break
	EndIf
End Sequence
If Len(_aMsg) > 0
	_cMens := "M410PVNF"+ CRLF
	For _nPos := 1 To Len(_aMsg)
		_cMens += Upper(_aMsg[_nPos]) + CRLF
	Next _nPos
	Conout(_cMens)
	
	If !_lJob .and. !_lRet
		FWAlertWarning(_cMens, "[M410PVNFLC] - Atenção")
	EndIf	
	
EndIf
Return _lRet 


/*/{Protheus.doc} ZFATF14TPF
Verifica os Pedidos Em Reserva/Em Faturamento/Em Separação Peças
@param     	_cCliFat	,código cliente
			_cTpCred	,tipo de crédito utilizado 
			_cTpOper	,tipo de operação a ser utilizada
			_cPgNAval	,condição de pgto a vista 	
			_cPgFP		,condição de pagamento Forplan  
			_cPgCAOA,	,condição de pagamento CAO
@return		_nValBO		,Pedidos em aberto
@author     CAOA - Evandro A Mariano dos Santos 
@version    12.1.17 / Superior
@project	GRUPO CAOA 
@since      28/07/2022
@history 	28/03/2023	,GAP FIN108 - Revitalização Credito [ Montadora ]
						 Ajustando funcionalidade para utilizar LC na Montadora como em Barueri
/*/

Static Function M410PVNFTNF(_cPedido)
Local _cAliasPesq  	:= GetNextAlias()
Local _nTotPedido  	:= 0
Begin Sequence
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT NVL(SUM(SC6.C6_VALOR),0) AS TIT_PEDIDO  
		FROM %Table:SC6% SC6  		
		WHERE SC6.C6_FILIAL 	= %XFilial:SC6%
			AND SC6.C6_NUM     	= %Exp:_cPedido%	
			AND SC6.%notDel%
	EndSql

	If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->TIT_PEDIDO == 0
		Break
	EndIf	
	_nTotPedido := (_cAliasPesq)->TIT_PEDIDO 
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return(_nTotPedido)

//Localizar o tipo de operação do pedido
Static Function XLOCTPOPPE(_cAlias, _cNumPed) 
Local _cRet	:= ""
Local _nReg := (_cAlias)->(RECNO())

Default _cAlias	:= ""
Default _cNumPed	:= ""

Begin Sequence
	If Empty(_cAlias) .Or. Empty(_cNumPed)
		Break
	EndIf
	_nReg := (_cAlias)->(RECNO())
	(_cAlias)->(DbSetOrder(1))
	(_cAlias)->(DbGotop())
	If (_cAlias)->(DbSeek(XFilial(_cAlias)+_cNumPed))
		_cRet	:= If(_cAlias=="VS3" ,VS3->VS3_OPER, ;
					If(_cAlias=="SC6",SC6->C6_OPER,;
					"")) 
	EndIf				
End Sequence
(_cAlias)->(DbGoto(_nReg))
Return _cRet




