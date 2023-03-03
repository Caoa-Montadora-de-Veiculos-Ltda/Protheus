#Include "Protheus.Ch"
#Include "Totvs.Ch"

/*/{Protheus.doc} M460MARK
    Ponto de Entrada - Validação de pedidos marcados
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
