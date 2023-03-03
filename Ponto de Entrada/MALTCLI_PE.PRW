#Include "Protheus.CH"
#Include "Parmtype.CH"

/*/{Protheus.doc} MALTCLI
    Ponto de Entrada após gravação na alteração do cadastro de Cliente, `MATA030`.
    @type       Function
    @author     TOTVS; CAOA - denis.galvani - Denis A. Galvani
    @since 
    @version 
    // @param      param_name, param_type, param_descr
    @return     NIL, , Retorno nulo
    @example
        `U_MALTCLI()`
    @see TDN - https://tdn.totvs.com/x/L4Vn
    @history    22/08/2020  , denis.galvani, Inclusão de documentação de cabeçalho
    @history    22/08/2020  , denis.galvani, Padronização CAOA para chamada de funções
    @history                ,              , Verificar programa/função existente - `ExistBlock` ou `FindFunction`
    /*/
User function MALTCLI()

	Local _cEmp		:= FWCodEmp()
	Local aArea		:= GetArea()
	Local _lRet		:= .T.

	If _cEmp == "2010" //Executa o p.e. Anapolis.
		If ExistBlock("CMVSAP01")
			U_ZF10GENSAP("SA1",SA1->A1_COD+SA1->A1_LOJA,"A1_XCDSAP",4)
		EndIf
	Else
		If ExistBlock("ZSAPF001")
			U_ZF10GENSAP("SA1",SA1->A1_COD+SA1->A1_LOJA,"A1_XCDSAP",4)
		EndIf
	EndIf

    If FindFunction("U_CMVFIN02")
		U_CMVFIN02()
	EndIf

	RestArea(aArea)

Return(_lRet)
