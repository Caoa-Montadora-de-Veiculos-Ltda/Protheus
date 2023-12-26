#Include "Totvs.ch"

/*/{Protheus.doc} User Function ZFISF008
Funcao com tela customizada usando a classe TDialog para escolher o relatório que será impresso
@type  Function
@author Nicolas Lima
@since 26/12/2023
@see https://tdn.totvs.com/display/tec/Construtor+TDialog%3ANew
@obs 
/*/

User Function ZFISF008()

    Local aArea         := FwGetArea()
    Local nCorFundo     := RGB(238, 238, 238)
    Local nJanAltura    := 120
    Local nJanLargur    := 320
    Local cJanTitulo    := 'Relatório de Nota Fiscal entrada / saída.'
    Local lDimPixels    := .T.
    Local lCentraliz    := .T.
    Local nObjLinha     := 0
    Local nObjColun0    := 0 //Bot Confirmar
    Local nObjColun1    := 0 //Bot Cancelar
    Local nObjLargu     := 0
    
    Private cFontNome := 'Tahoma'
    Private oFontPadrao := TFont():New(cFontNome, , -12)
    Private oDialogPvt //Objeto da tela
    Private bBlocoIni := {|| /*SuaFuncaoAqui*/ } //Aqui voce pode adicionar funcoes customizadas que irao ser adicionadas ao abrir a dialog. //Preciso tester isso

    //Radio
    Private nRadOpc := 1 //Opções permitidas para selecionar ? Testar isso
    Private aRadItens := {"Relatório de Notas Fiscais de entrada", "Relatório de Notas Fiscais de saída"}
    Private oRadCores
    //Objeto0 Botão Confirmar
    Private oBtnObj0
    Private cBtnObj0 := 'Gerar relatório'
    Private bBtnObj0 := {|| MsgInfo('botão confirmar: ' + ' nObjColun0: ' + str(nObjColun0) + ' nJanLargur/2:  ' + str(nJanLargur/2) + ' nObjLargu+2: ' + str(nObjLargu+2), 'Atenção')}
    //Objeto0 Botão Cancelar
    Private oBtnObj1
    Private cBtnObj1 := 'Cancelar'
    Private bBtnObj1 := {|| oDialogPvt:End() }  //Encerra tela

    //Criar a Dialog
    //TDialog():New( [ nTop ], [ nLeft ], [ nBottom ], [ nRight ], [ cCaption ], [ uParam6 ], [ uParam7 ], [ uParam8 ], [ uParam9 ], [ nClrText ], [ nClrBack ], [ uParam12 ], [ oWnd ], [ lPixel ], [ uParam15 ], [ uParam16 ], [ uParam17 ], [ nWidth ], [ nHeight ], [ lTransparent ] )
    oDialogPvt := TDialog():New(0 , 0, nJanAltura, nJanLargur, cJanTitulo,/*[ uParam6 ]*/,/*[ uParam7 ]*/,/*[ uParam8 ]*/,/* [ uParam9 ]*/,/*[ nClrText ]*/, nCorFundo,/*[ uParam12 ]*/,/*[ oWnd ]*/, lDimPixels )

        //Menu com opções do Radio
        nObjLinha := 10
        nObjColun := 14
        nObjLargu := 140
        nObjAltur := 0 //Irá atualizar o lAutoHeight
        oRadCores := TRadMenu():New (nObjLInha, nObjColun, aRadItens, {|u|Iif (Pcount()==0,nRadOpc,nRadOpc:=u)}, oDialogPvt,  /*uParam6*/, /*bChange*/, /*nClrText*/, /*nClrPane*/, /*cMsg*/, /*uParam11*/, /*bWhen*/, nObjLargu, nObjAltur, /*bValid*/, /*uParam16*/, lDimPixels, .T.)
        oRadCores:oFont := oFontPadrao

        //Criando botão CONFIRMAR com Classe TButton
        nObjLargu   := 50
        nObjAltur   := 15
        nObjLinha   := ((nJanAltura/2) - (nObjAltur + 6))
        nObjColun0  := ((nJanLargur/2) - (nObjLargu+2)) //nJanLargur -> (160 - 52) = 107
        oBtnObj0    := TButton():New(nObjLinha, nObjColun0, cBtnObj0, oDialogPvt, bBtnObj0, nObjLargu, nObjAltur, , oFontPadrao, , lDimPixels)
        oBtnObj0:SetCSS("TButton {  font: bold; background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #0D9CBF);    color: #FFFFFF;     border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:focus {    padding:0px; outline-width:1px; outline-style:solid; outline-color: #51DAFC; outline-radius:3px; border-color:#369CB5;}TButton:hover {    color: #FFFFFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #1188A6);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:pressed {    color: #FFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #1188A6, stop: 1 #3DAFCC);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:disabled {    color: #FFFFFF;     background-color: #4CA0B5; }")

        //Criando botão CANCELAR com Classe TButton
        nObjLargu   := 50
        nObjAltur   := 15
        nObjLinha   := ((nJanAltura/2) - (nObjAltur + 6))
        nObjColun1  := ((nObjColun0-4) - (nObjLargu+2)) //nJanLargur ->  = 43
        oBtnObj1    := TButton():New(nObjLinha, nObjColun1, cBtnObj1, oDialogPvt, bBtnObj1, nObjLargu, nObjAltur, , oFontPadrao, , lDimPixels)

    oDialogPvt:Activate(, , , lCentraliz, , , bBlocoIni)

    FWRestarea(aArea)
Return     

/*
Static Function zOpc(nRadio)

    Local _cEmp    := FWCodEmp()
   
   Do Case
        Case nRadio == 1 //--Nfs de entrada
            If _cEmp == "2010" //Executa o p.e. Anapolis.
                FWMsgRun( ,{|| U_ZFISR003() } ,"Carregando tela de impressão Treport de Nfs de entrada!" ,"Por favor aguarde...")
            Else
                FWMsgRun( ,{|| U_ZFISR010() } ,"Carregando tela de impressão Treport de Nfs de entrada!" ,"Por favor aguarde...")
            EndIf
        Case nRadio == 2 //--Nfs de entrada canceladas
            If _cEmp == "2010" //Executa o p.e. Anapolis.
                FWMsgRun( ,{|| U_ZFISR004() } ,"Carregando tela de impressão Treport de Nfs de entrada canceladas!" ,"Por favor aguarde...")
            Else
                FWMsgRun( ,{|| U_ZFISR013() } ,"Carregando tela de impressão Treport de Nfs de entrada canceladas!" ,"Por favor aguarde...")
            EndIf
        Case nRadio == 3 //--Nfs de saida
            If _cEmp == "2010" //Executa o p.e. Anapolis.
                FWMsgRun( ,{|| U_ZFISR005() } ,"Carregando tela de impressão Treport de Nfs de saida!" ,"Por favor aguarde...")
            Else
                FWMsgRun( ,{|| U_ZFISR011() } ,"Carregando tela de impressão Treport de Nfs de saida!" ,"Por favor aguarde...")
            EndIF
        Case nRadio == 4 //--Nfs de saida canceladas
            If _cEmp == "2010" //Executa o p.e. Anapolis.
                FWMsgRun( ,{|| U_ZFISR006() } ,"Carregando tela de impressão Treport de Nfs de saida canceladas!" ,"Por favor aguarde...")
            Else
                FWMsgRun( ,{|| U_ZFISR014() } ,"Carregando tela de impressão Treport de Nfs de saida canceladas!" ,"Por favor aguarde...")
            EndIf
    EndCase

Return
*/
