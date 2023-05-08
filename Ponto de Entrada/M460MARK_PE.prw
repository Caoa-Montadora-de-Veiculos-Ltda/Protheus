#Include "Protheus.Ch"
#Include "Totvs.Ch"

/*/{Protheus.doc} M460MARK
Ponto de Entrada - Valida��o de pedidos marcados na gera��o de notas Faturamento
@type  		Function
@author 	TOTVS - FSW - DWC Consult; CAOA - denis.galvani - Denis A. Galvani
@since      24/02/2019
@version    2.0
@param 		ParamIxb    , array		, Informa��es da Markbrowse e s�rie para gera��o da Nota Fiscal
            | Par�metro   | Tipo      | Descri��o                                                                                        |
            |-------------|-----------|--------------------------------------------------------------------------------------------------|
            | ParamIxb[0] | character | *cMark* - Marca em uso pela Markbrowse                                                           |
            | ParamIxb[1] | logical	  | *lInvert* - Se o Pedido est� marcado ou n�o no *MarkBrowse* *(`.T.` marcado; `.F.` n�o marcado)* |
            | ParamIxb[2] | character | *cSerie* - S�rie selecionada na gera��o da Nota Fiscal                                           |
@return 	aButton		, array		, Vetor com defini��es dos bot�es - `{"character",codeBlock,"character"}`
@example
	Retorno: `aButton := { {"POSCLI",{|| a450F4Con()},STR0017} }`
@see        TDN - https://tdn.totvs.com/x/vYRn
@history 	22/08/2020	, denis.galvani, Inclus�o/padroniza��o de documenta��o de cabe�alho
@history    22/08/2020  , denis.galvani, Padroniza��o CAOA para chamada de fun��es
@history                ,              , Verificar programa/fun��o existente - `ExistBlock` ou `FindFunction`
@history    DAC Denilso - 06/04/2023	        
            GRUPO CAOA GAP FIN108 - Revitaliza��o Credito [ Montadora ]
            Unifica��o Pe�as com Montadora
    /*/
User Function M460MARK()
Local _cMarkSC9	    := ParamIxb[1]
Local _lInverte	    := ParamIxb[2]
Local _aArea	    := GetArea()
Local _lRet		    := .T.
    _lRet   := M460MARKLC(_cMarkSC9, _lInverte)
    RestArea(_aArea)
Return _lRet


//Libera��o de Cr�dito
/*/{Protheus.doc} M410PVNFLC
	Fun��o respons�vel pelo Limite de Cr�dito na emiss�o da Nota para Anapolis Prepara��o Dcto.
	@type 		function
	@author 	CAOA - DAC Denilso
	@since 		06/04/2023
	@version 	1.0
	@param 		
	@return 	logical, *Item* ou *Pedido de Venda* v�lido para regra CAOA de *Libera��o de Cr�dito*
	@see 		TDN - https://tdn.totvs.com/x/mIRn
	@obs		Tem que estar posicionado SC5
	@history 	06/04/2023	, DAC, Revitaliza��o Limite de Cr�dito  
	/*/

Static Function M460MARKLC(_cMarkSC9, _lInverte)
Local _cWhere       := ""
Local _cAliasPesq  	:= GetNextAlias()
Local _lJob			:= IsBlind()
Local _lRet         := .T.
Local _aMsg         := {}
Local _cTpPgtoEsp	:= AllTrim( SuperGetMV( "CMV_PEC039" ,, "" ) ) 	//Condi��o de Pagamento a qual liberar� sem avalia��o do Limite de Cr�dito
Local _cMens
Local _nPos

Begin Sequence
	_cWhere := " AND "+IIf(_lInverte,"SC9.C9_OK <> '" + _cMarkSC9 + "'","SC9.C9_OK = '" + _cMarkSC9 + "'")
	_cWhere := "%" + _cWhere + "%"
	BeginSql Alias _cAliasPesq //Define o nome do alias tempor�rio 
        SELECT SC9.C9_OK
            , SC9.C9_PEDIDO
            , SC9.C9_CLIENTE
            , SC9.C9_LOJA
            , SC9.C9_BLEST 
        FROM %Table:SC9% SC9  
        WHERE SC9.%NotDel% 
            AND SC9.C9_FILIAL   =  %xFilial:SC9%
            AND SC9.C9_NFISCAL  = ' ' 
            %Exp:_cWhere%
        GROUP BY C9_OK,C9_PEDIDO,C9_CLIENTE,C9_LOJA,C9_BLEST
	EndSql
	If (_cAliasPesq)->(Eof()) 
        AAdd(_aMsg, "N�o localizado pedidos marcados para faturamento ! " )
        _lRet := .F.
		Break
	EndIf	
    SC5->(DbSetOrder(1))  //posiciono ordem de pedido para procura
    While (_cAliasPesq)->(!Eof())
        //posicionar o pedido a valida��o do valor ser� pelo total
        If !SC5->(DbSeek(XFilial("SC5")+(_cAliasPesq)->C9_PEDIDO))
            AAdd(_aMsg, "N�o localizado Pedido "+(_cAliasPesq)->C9_PEDIDO+ " ! " )
            _lRet := .F.
            Break
        EndIf
        //Se estiver cadastrado par�metro para condi��o especial de pgto liberar� o limite de cr�dito automaticamente
        If !Empty(_cTpPgtoEsp) .And. SC5->C5_CONDPAG $ _cTpPgtoEsp
            _cMens := "Pedido "+(_cAliasPesq)->C9_PEDIDO+ " liberado conforme condi��o de pgto especial ! "
            AAdd(_aMsg, _cMens )
			U_ZGENLZA2(SC5->C5_CONDPAG, _cTpPgtoEsp, "C5_CONDPAG", "LIBERACAO ESPECIAL", _cMens ,/*_cUserSol*/)
            _lRet := .T.
            Break
        EndIf    
        //Chamo o Ponto de entrada que faz a valida��o do LC quando posicionado SC5
        _lRet   := U_M410PVNF()
        If !_lRet 
            //N�o gravo msg pois a fun��o M410PVNF ja emite msg
            Break
        Endif    
        (_cAliasPesq)->(DbSkip())
    EndDo
End Sequence
If Len(_aMsg) > 0
	_cMens := "M460MARK"+ CRLF
	For _nPos := 1 To Len(_aMsg)
		_cMens += Upper(_aMsg[_nPos]) + CRLF
	Next _nPos
	Conout(_cMens)
	If !_lJob
		MSGINFO( _cMens , "[M460MARKLC] - Aten��o" )
	EndIf	
EndIf
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet 

