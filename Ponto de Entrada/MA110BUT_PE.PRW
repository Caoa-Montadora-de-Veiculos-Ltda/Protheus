#INCLUDE "TOTVS.CH" 
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} MA110BUT_PE
P.E. - Adiciona botões no Pedido de Compras e Autorização de Entrega.
@author CAOA - Denis Amaral Galvani
@since 26/06/2019
@version 1.0
@type function
/*/
USER FUNCTION MA110BUT

	
	LOCAL nOpcX		  := IIF(INCLUI,3,IIF(ALTERA,4,2))
	LOCAL aBotao      := PARAMIXB[2] //Ajuste referente ao GAP097
	//LOCAL aBotao      := {}

	//Local nOpc:= PARAMIXB[1]
    //Local aBut:= PARAMIXB[2]
    //LOCAL bButZCOMF3

	// ** ***************************************************************** ** //
    // **  BOTAO PARA GERAR SOLICITAÇÃO DE COMPRAS CAOA (MODELO CONF. SAP)  ** //
    // ** ***************************************************************** ** //
	//If _lRet  .and. FindFunction("U_ZCOMF015") .and. nOpcX == 5 .and. nOpcX == 1
	//	_lRet := U_ZCOMF015( "PC" /*DoC*/, nOpcX /*Novo Registro inclusao*/, /*indica se devve mostrar somente a tela*/,/*indica que esta sendo copiado*/)
	//Endif
    
    Aadd( aBotao,{"BTNPRTPC", {|| U_ZCOMF015("SC" /*DoC*/, nOpcX /*Novo Registro inclusao*/, .T./*indica se devve mostrar somente a tela*/,/*indica que esta sendo copiado*/)}, "Trilha Segurança"} )
	aAdd(aBotao, {'BTNPRTP1'     ,{|| U_ZCOMF032()},  'Recusa de SC'   } )
	aAdd(aBotao, {'BTNPRTP2'     ,{|| U_ZCOMF033()},  'Estorno da Recusa'  } )
	aAdd(aBotao, {'BTNPRTP3'     ,{|| U_ZCOMF042()},  'Consulta Recusa'   } )

    //Aadd( aBotao, { "BTNPRTPC", {|| U_ZCOMF022()}, "Trilha Segurança"} )

RETURN(aBotao)
