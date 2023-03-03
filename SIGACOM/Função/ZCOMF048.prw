#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MA120BUT
P.E. - Incluir Bot�o Pesquisa Item F3
@author
@since 21/10/2020

@version 1.0
@type function
/*/
User Function ZCOMF048()
Private _cPC_NUM := SC7->C7_NUM
Private _CPC_COD :='C7_PRODUTO'

    IF FWCodEmp() <> '2020' .OR. FWFilial() <> '2001' //Verificar Empresa/Filial Barueri
        RETURN Nil
    ENDIF

    U_zFindProd(Alltrim(_CPC_COD))

Return(.T.)


/*/{Protheus.doc} zFindProd
Fun��o feita para agilizar a procura de produtos na grid de rotinas padr�es
@author Atilio
@since 31/10/2018
@version undefined
@type function
@example Inserir em um ponto de entrada no carregamento do sistema, por exemplo:
 
    User Function AfterLogin()
        SetKey(K_CTRL_Y, { || u_zFindProd() })  //Ctrl + Y
    Return
 
@obs Essa rotina foi feita usando o padr�o de grids que usam aCols e aHeader, se for em MVC, para posicionar na linha seria algo +- assim:
 
    ...
    oModelPad  := FWModelActive()
    oModelGrid := oModelPad:GetModel('XXXDETAIL')
    oModelGrid:GoLine(nLinhaNew)
    ...
/*/
 
User Function zFindProd(cCampo)
    Private nPosProd   := 0
    Private oPai       := GetWndDefault()
    Private aControles := oPai:aControls
 
    //Se for chamada pela tela de pedido de vendas, o campo ser� o C6_PRODUTO
    If IsInCallStack("MATA410")
        cCampo := "C6_PRODUTO"
 
    //Sen�o, se for chamada pela tela de pedido de compras, o campo ser� o C7_PRODUTO
    ElseIf IsInCallStack("MATA121")
        cCampo := "C7_PRODUTO"
    EndIf
 
    //Se houver campo, ser� carregado a tela
    If !Empty(cCampo)
        //Pega a posi��o do aCols
        nPosProd := GDFieldPos(cCampo,aHeader)

        //Chama a fun��o de procura
        fProcura(cCampo)
 
    Else
        MsgStop("Procura de Produtos n�o pode ser chamada!", "Aten��o")
    EndIf
 
Return
 
/*---------------------------------------*
 | Func.: fProcura                       |
 | Desc.: Fun��o que procura o registro  |
 *---------------------------------------*/
 
Static Function fProcura(cCampo)
    //Vari�veis da tela
    Private oDlgPesq
    Private oGrpPesq
    Private oGetPesq
    Private cGetPesq := Space(TamSX3('B1_COD')[01])
    Private oBtnExec
    //Tamanho da Janela
    Private nJanLarg := 500
    Private nJanAltu := 065
 
    cGetPesq := cCampo
 
    //Criando a janela
    DEFINE MSDIALOG oDlgPesq TITLE "zFindProd - Pesquisa de Produtos" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Grupo F�rmula com o Get
        @ 003, 003  GROUP oGrpPesq TO (nJanAltu/2)-3, (nJanLarg/2)-1        PROMPT "Produto: " OF oDlgPesq COLOR 0, 16777215 PIXEL
            @ 010, 006  MSGET oGetPesq VAR cGetPesq SIZE (nJanLarg/2)-29, 013 OF oDlgPesq COLORS 0, 16777215 VALID (fConfirma()) PIXEL
            oGetPesq:cPlaceHold := "Insira o c�digo do Produto ou um trecho do c�digo..."
 
            @ 010, (nJanLarg/2)-21 BUTTON oBtnExec PROMPT "OK" SIZE 016, 015 OF oDlgPesq ACTION(fConfirma()) PIXEL
 
    //Ativando a janela
    ACTIVATE MSDIALOG oDlgPesq CENTERED
 
Return
 
/*---------------------------------------*
 | Func.: fConfirma                      |
 | Desc.: Efetua a busca na grid         |
 *---------------------------------------*/
 
Static Function fConfirma()
    Local nLinNov   := 0
    Local cPesquisa := Alltrim(cGetPesq)
 
    //Primeiro tenta encontrar exatamente igual
    nLinNov := aScan(aCols, {|x| AllTrim(x[nPosProd]) == cPesquisa})
 
    //Se n�o encontrou, busca pelo trecho
    If nLinNov == 0
        nLinNov := aScan(aCols, {|x| cPesquisa $ AllTrim(x[nPosProd])})
    Endif
 
    //Se mesmo assim n�o encontrou, mostra mensagem
    If nLinNov == 0
        MsgStop("Trecho '" + cPesquisa + "' n�o foi encontrado!", "Aten��o")
 
    //Do contr�rio, posiciona na linha correta e encerra a tela
    Else
        fPosiciona(nLinNov)
        oDlgPesq:End()
    EndIf
Return
 
/*---------------------------------------*
 | Func.: fPosiciona                     |
 | Desc.: Posiciona na linha correta     |
 *---------------------------------------*/
 
Static Function fPosiciona(nLinhaNew)
    Local nAtual     := 0
    Local oGrid
 
    //Percorrendo os objetos criados da tela
    For nAtual := 1 To Len(aControles)
 
        //Se tiver Colunas, � uma grid
        If Type("aControles[" + cValToChar(nAtual) + "]:aColumns") != "U"
 
            //Se tiver o mesmo n�mero de colunas que o aHeader
            If Len(aControles[nAtual]:aColumns) == Len(aHeader)
 
                //Pega a Grid
                oGrid := aControles[nAtual]
 
                //Muda a Linha atual
                n := nLinhaNew
                oGrid:nAt := n
 
                //Atualiza a grid
                oGrid:Refresh()
                oGrid:SetFocus()
            EndIf
        EndIf
    Next
Return
