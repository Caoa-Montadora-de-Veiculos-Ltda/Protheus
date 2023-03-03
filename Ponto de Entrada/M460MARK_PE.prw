#Include "Protheus.Ch"
#Include "Totvs.Ch"

/*/{Protheus.doc} M460MARK
    Ponto de Entrada - Valida��o de pedidos marcados
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
    /*/
User Function M460MARK()
	Local cMarkSC9	:= ParamIxb[1]
	Local lInverte	:= ParamIxb[2]
	Local lExec		:= .T.
	Local aArea		:= GetArea()

	If ExistBlock("VLDLIMIT")
		lExec := ExecBlock("VLDLIMIT", .F., .F.,{cMarkSC9,lInverte,0})
	EndIf

	RestArea(aArea)
Return( lExec )
