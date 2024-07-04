#Include "Totvs.Ch"

/*/{Protheus.doc} M410PVNF
	Ponto de Entrada - Gera��o de notas fiscais. Valida��o antes da execu��o para gera��o de NF's.
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		17/04/2019
	@version 	1.0
	@param 		ParamIxb, number, *nRecSC5* - N�mero de *Pedido de Venda* *(`SC5->C5_NUM`)*
	@return 	logical, *Item* ou *Pedido de Venda* v�lido para regra CAOA de *Libera��o de Cr�dito*
	@see 		TDN - https://tdn.totvs.com/x/mIRn
	@obs		Este PE tamb�m � chamado pelo PE M460MARK
	@history 	22/08/2020	, denis.galvani, Inclus�o/padroniza��o de documenta��o de cabe�alho
	@history 	04/04/2023	, DAC, Revitaliza��o Limite de Cr�dito
							  GRUPO CAOA GAP FIN108 - Revitaliza��o Credito [ Montadora ]  
	/*/

User Function M410PVNF()
//Local _nRecSC5	:= ParamIxb
Local _lRet			:= .T.
Local _aArea		:= GetArea()
Local _lJob			:= IsBlind()
Local _oSay

	Conout( "In�cio PE M410PVNF" )
	If !_lJob
		FwMsgRun(,{ |_oSay| _lRet := M410PVNFLC(@_oSay) }, 'Limite Cr�dito','Avaliando limite de cr�dito, aguarde...')  //Separa��o Or�amentos / Aguarde
	Else
		_lRet	:= M410PVNFLC()	//Fun��o responsavel pelo Limite de Cr�dito
	Endif
	RestArea(_aArea)
Return _lRet


/*/{Protheus.doc} M410PVNFLC
	Fun��o respons�vel pelo Limite de Cr�dito na emiss�o da Nota para Anapolis.
	@type 		function
	@author 	CAOA - DAC Denilso
	@since 		04/04/2023
	@version 	1.0
	@param 		
	@return 	logical, *Item* ou *Pedido de Venda* v�lido para regra CAOA de *Libera��o de Cr�dito*
	@project	GRUPO CAOA GAP FIN108 - Revitaliza��o Credito [ Montadora ]
	@see 		TDN - https://tdn.totvs.com/x/mIRn
	@obs		Tem que estar posicionado SC5
	@history 	04/04/2023	, DAC, Revitaliza��o Limite de Cr�dito  

	/*/

Static Function M410PVNFLC(_oSay)
//Local _nRecSC5	:= ParamIxb
Local _lRet			:= .T.
Local _aMsg			:= {}
Local _nLimAvalia	:= 0   //Residuo do limite de cr�dito caso n�o tenha aprova��o
Local _cTpOper      := AllTrim(SuperGetMV( "CAOA_TPLIM" ,, ""))  //Tipos de Opera��o para analise do cr�dito - CAOA   54;91;90;67;82;93
Local _cTpPgtoEsp	:= AllTrim(SuperGetMV( "CMV_PEC039" ,, "" ) ) 	//Condi��o de Pagamento a qual liberar� sem avalia��o do Limite de Cr�dito
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
	//Encontrar Tipo de Opera��o para avaliar
	_cTpOperPed := XLOCTPOPPE("SC6",SC5->C5_NUM)  	
	If Empty(_cTpOperPed)
		AAdd(_aMsg, "Par�metro tipo de Opera��o, n�o cont�m informa��es !")
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
    //Se estiver cadastrado par�metro para condi��o especial de pgto liberar� o limite de cr�dito automaticamente
    If !Empty(_cTpPgtoEsp) .And. SC5->C5_CONDPAG $ _cTpPgtoEsp
        _cMens := "Pedido "+SC5->C5_NUM+ " liberado conforme condi��o de pgto especial ! "
        AAdd(_aMsg, _cMens )
		U_ZGENLZA2(SC5->C5_CONDPAG, _cTpPgtoEsp, "C5_CONDPAG", "LIBERACAO ESPECIAL", _cMens ,/*_cUserSol*/)
        _lRet := .T.
        Break
    EndIf
	if SC5->C5_CLIENTE + SC5->C5_LOJACLI $ __cCliLiCred    //Byapass da valida��o de credito
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
		FWAlertWarning(_cMens, "[M410PVNFLC] - Aten��o")
	EndIf	
	
EndIf
Return _lRet 


/*/{Protheus.doc} ZFATF14TPF
Verifica os Pedidos Em Reserva/Em Faturamento/Em Separa��o Pe�as
@param     	_cCliFat	,c�digo cliente
			_cTpCred	,tipo de cr�dito utilizado 
			_cTpOper	,tipo de opera��o a ser utilizada
			_cPgNAval	,condi��o de pgto a vista 	
			_cPgFP		,condi��o de pagamento Forplan  
			_cPgCAOA,	,condi��o de pagamento CAO
@return		_nValBO		,Pedidos em aberto
@author     CAOA - Evandro A Mariano dos Santos 
@version    12.1.17 / Superior
@project	GRUPO CAOA 
@since      28/07/2022
@history 	28/03/2023	,GAP FIN108 - Revitaliza��o Credito [ Montadora ]
						 Ajustando funcionalidade para utilizar LC na Montadora como em Barueri
/*/

Static Function M410PVNFTNF(_cPedido)
Local _cAliasPesq  	:= GetNextAlias()
Local _nTotPedido  	:= 0
Begin Sequence
	BeginSql Alias _cAliasPesq //Define o nome do alias tempor�rio 
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

//Localizar o tipo de opera��o do pedido
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




