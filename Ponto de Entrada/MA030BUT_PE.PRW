/*/{Protheus.doc} MA030BUT
    Ponto de Entrada - Adicionar botões no cadastro de clientes, botão *"Outras Ações"*.
    @type       Function
    @author     TOTVS; CAOA - denis.galvani - Denis A. Galvani
    @since 
    @version 
    @param      nOpc    , numeric   , Indica operação: Visualização (2); Inclusão (3); Alteração (4); Exclusão (5)
    @return     aButton , array     , Vetor com definições dos botões - `{"character",codeBlock,"character"}`
    @example
        Retorno: `aButton := { {"POSCLI",{|| a450F4Con()},STR0017} }
    @see TDN - https://tdn.totvs.com/x/9oRn
    @history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
    @history    22/08/2020  , denis.galvani, Padronização CAOA para chamada de funções
    @history                ,              , Verificar programa/função existente - `ExistBlock` ou `FindFunction`
    /*/
User Function MA030BUT()

    Local aButUser := {}

    If FindFunction("U_LOGLIM")
        aAdd(aButUser, {"FINIMG32",{|| U_LOGLIM()},"Log Limite Credito","Log Limite Credito"})
    EndIf

Return aButUser
