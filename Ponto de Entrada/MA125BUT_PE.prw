#INCLUDE "TOTVS.CH"
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} MA125BUT_PE
P.E. - Adiciona botões no Contrato de Parceria.
@author CAOA - A.Carlos
@since 17/11/2020
@version 1.0
@type function
/*/
USER FUNCTION MA125BUT

	LOCAL aBotao      := {}
	LOCAL nOpcX		  := IIF(INCLUI,3,IIF(ALTERA,4,2))
    //LOCAL bButZCOMF3

	// ** *************************************************************** ** //
    // **  BOTAO PARA GERAR Contrato de Parceria CAOA (MODELO CONF. SAP)  ** //
    // ** *************************************************************** ** //

    //Aadd( aBotao, { "BTNPRTPC", {|| U_ZCOMF022()}, "Trilha Segurança"} )

    Aadd( aBotao, { "BTNPRTPC", {|| U_ZCOMF015("CP" /*DoC*/, nOpcX /*Novo Registro inclusao*/, .T./*indica se devve mostrar somente a tela*/,/*indica que esta sendo copiado*/)}, "Trilha Segurança"} )

RETURN(aBotao)
