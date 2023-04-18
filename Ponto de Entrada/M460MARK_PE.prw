#Include "Protheus.Ch"
#Include "Totvs.Ch"

/*/{Protheus.doc} M460MARK
Ponto de Entrada - Validação de pedidos marcados na geração de notas Faturamento
@type  		Function
@author 	TOTVS - FSW - DWC Consult; CAOA - denis.galvani - Denis A. Galvani
@since      24/02/2019
@version    2.0
@param 		ParamIxb    , array		, Informações da Markbrowse e série para geração da Nota Fiscal
            | Parâmetro   | Tipo      | Descrição                                                                                        |
            |-------------|-----------|--------------------------------------------------------------------------------------------------|
            | ParamIxb[0] | character | *cMark* - Marca em uso pela Markbrowse                                                           |
            | ParamIxb[1] | logical	  | *lInvert* - Se o Pedido está marcado ou não no *MarkBrowse* *(`.T.` marcado; `.F.` não marcado)* |
            | ParamIxb[2] | character | *cSerie* - Série selecionada na geração da Nota Fiscal                                           |
@return 	aButton		, array		, Vetor com definições dos botões - `{"character",codeBlock,"character"}`
@example
	Retorno: `aButton := { {"POSCLI",{|| a450F4Con()},STR0017} }`
@see        TDN - https://tdn.totvs.com/x/vYRn
@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
@history    22/08/2020  , denis.galvani, Padronização CAOA para chamada de funções
@history                ,              , Verificar programa/função existente - `ExistBlock` ou `FindFunction`
@history    DAC Denilso - 06/04/2023	        
            GRUPO CAOA GAP FIN108 - Revitalização Credito [ Montadora ]
            Unificação Peças com Montadora
    /*/
User Function M460MARK()
Local _cMarkSC9	    := ParamIxb[1]
Local _lInverte	    := ParamIxb[2]
Local _aArea	    := GetArea()
Local _lRet		    := .T.
    _lRet   := M460MARKLC(_cMarkSC9, _lInverte)
    RestArea(_aArea)
Return _lRet


//Liberação de Crédito
/*/{Protheus.doc} M410PVNFLC
	Função responsável pelo Limite de Crédito na emissão da Nota para Anapolis Preparação Dcto.
	@type 		function
	@author 	CAOA - DAC Denilso
	@since 		06/04/2023
	@version 	1.0
	@param 		
	@return 	logical, *Item* ou *Pedido de Venda* válido para regra CAOA de *Liberação de Crédito*
	@see 		TDN - https://tdn.totvs.com/x/mIRn
	@obs		Tem que estar posicionado SC5
	@history 	06/04/2023	, DAC, Revitalização Limite de Crédito  
	/*/

Static Function M460MARKLC(_cMarkSC9, _lInverte)
Local _cWhere       := ""
Local _cAliasPesq  	:= GetNextAlias()
Local _lJob			:= IsBlind()
Local _lRet         := .T.
Local _aMsg         := {}
Local _cTpPgtoEsp	:= AllTrim( SuperGetMV( "CMV_PEC039" ,, "" ) ) 	//Condição de Pagamento a qual liberará sem avaliação do Limite de Crédito
Local _cMens
Local _nPos

Begin Sequence
	_cWhere := " AND "+IIf(_lInverte,"SC9.C9_OK <> '" + _cMarkSC9 + "'","SC9.C9_OK = '" + _cMarkSC9 + "'")
	_cWhere := "%" + _cWhere + "%"
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
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
        AAdd(_aMsg, "Não localizado pedidos marcados para faturamento ! " )
        _lRet := .F.
		Break
	EndIf	
    SC5->(DbSetOrder(1))  //posiciono ordem de pedido para procura
    While (_cAliasPesq)->(!Eof())
        //posicionar o pedido a validação do valor será pelo total
        If !SC5->(DbSeek(XFilial("SC5")+(_cAliasPesq)->C9_PEDIDO))
            AAdd(_aMsg, "Não localizado Pedido "+(_cAliasPesq)->C9_PEDIDO+ " ! " )
            _lRet := .F.
            Break
        EndIf
        //Se estiver cadastrado parâmetro para condição especial de pgto liberará o limite de crédito automaticamente
        If !Empty(_cTpPgtoEsp) .And. SC5->C5_CONDPAG $ _cTpPgtoEsp
            _cMens := "Pedido "+(_cAliasPesq)->C9_PEDIDO+ " liberado conforme condição de pgto especial ! "
            AAdd(_aMsg, _cMens )
			U_ZGENLZA2(SC5->C5_CONDPAG, _cTpPgtoEsp, "C5_CONDPAG", "LIBERACAO ESPECIAL", _cMens ,/*_cUserSol*/)
            _lRet := .T.
            Break
        EndIf    
        //Chamo o Ponto de entrada que faz a validação do LC quando posicionado SC5
        _lRet   := U_M410PVNF()
        If !_lRet 
            //Não gravo msg pois a função M410PVNF ja emite msg
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
		MSGINFO( _cMens , "[M460MARKLC] - Atenção" )
	EndIf	
EndIf
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet 

