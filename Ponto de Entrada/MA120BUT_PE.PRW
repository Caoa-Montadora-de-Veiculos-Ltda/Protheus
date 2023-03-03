#INCLUDE "TOTVS.CH"
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} MA120BUT_PE
P.E. - Adiciona botões no Pedido de Compras e Autorização de Entrega.
@author CAOA - Denis Amaral Galvani
@since 26/06/2019
@version 1.0
@type function
/*/
USER FUNCTION MA120BUT

	LOCAL aBotao      := {}
	LOCAL nOpcX		  := IIF(INCLUI,3,IIF(ALTERA,4,2))
    LOCAL bButZCOMF3
    //LOCAL bButZCOMF4

    // ** ************************************************************ ** //
    // **  BOTAO PARA TELA PARA CAMPOS ADICIONAIS (Enchoise / MsmGet)  ** //
    // ** ************************************************************ ** //
    If FindFunction("U_ZCOMF003")
        // ** DIALOG ** "INFORMACOES COMPLEMENTARES"
		// ** DIALOG ** TABELA AUXILIAR (SZV) - INICIALIZAR VARIAVEIS

        bButZCOMF3 := {|| U_ZCOMF003(nOpcX)}
        Aadd(aBotao,{'ZCOMF_3',bButZCOMF3,'Inform. Complement. (F10)','Inf.Complem.(F10)'})
        
        SetKey(VK_F10,bButZCOMF3)
	Endif

	// ** ************************************************************ ** //
    // **  BOTAO PARA GERAR PEDIDO DE COMPRAS CAOA (MODELO CONF. SAP)  ** //
    // ** ************************************************************ ** //
    // ** GERACAO APENAS MODO VISUALIZACAO
	If FindFunction("U_ZCOMR001") .AND. ("VISUALIZAR" $ Upper(cCadastro))
		Aadd( aBotao, { "BTNPRTPC", {|| U_ZCOMR001()}, "Impr.PC.CAOA"} )
	EndIf
    //Aadd( aBotao, { "BTNPRTPC", {|| U_ZCOMF022()}, "Trilha Segurança"} )
    Aadd( aBotao, { "BTNPRTPC", {|| U_ZCOMF015("PC" /*DoC*/, nOpcX /*Novo Registro inclusao*/, .T./*indica se devve mostrar somente a tela*/,/*indica que esta sendo copiado*/)}, "Trilha Segurança"} )


RETURN(aBotao)
