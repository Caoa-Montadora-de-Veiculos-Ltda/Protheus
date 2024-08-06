#Include "Totvs.ch"

/*
=====================================================================================
Programa.:              ZFISF010
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              10/05/24
Descricao / Objetivo:   Tela com opção para escolher qual relatório será impresso.
Doc. Origem:            GAP173
Solicitante:            
Uso......:              
Obs......:              
=====================================================================================
*/

User Function ZFISF010()

    Local aArea         := FwGetArea()
    Local nCorFundo     := RGB(238, 238, 238)
    Local nJanAltura    := 120
    Local nJanLargur    := 320
    Local cJanTitulo    := 'Relatório de Nota Fiscal por cabeçalho.'
    Local lDimPixels    := .T.
    Local lCentraliz    := .T.
    Local nObjLinha     := 0
    Local nObjColun0    := 0 //Posição coluna Botão Gerar relatório
    Local nObjColun1    := 0 //Posição coluna Botão Cancelar
    Local nObjColun2    := 0 //Posição coluna Radio
    Local nObjLargu     := 0
    
    Private cFontNome := 'Tahoma'
    Private oFontPadrao := TFont():New(cFontNome, , -12)
    Private oDialogPvt //Objeto da tela
    Private bBlocoIni := {|| /*SuaFuncaoAqui*/ } //Aqui voce pode adicionar funcoes customizadas que irao ser adicionadas ao abrir a dialog. //Preciso tester isso

    //Objeto Radio
    Private oRadCores
    Private nRadOpc := 1 //Opções permitidas para selecionar ? Testar isso
    Private aRadItens := {"Relatório de Notas Fiscais de entrada", "Relatório de Notas Fiscais de saída"}
    
    //Objeto0 Botão Confirmar
    Private oBtnObj0
    Private cBtnObj0 := 'Gerar relatório'
    Private bBtnObj0 := {|| zOpc(nRadOpc), oDialogPvt:End()}
        
    //Objeto1 Botão Cancelar
    Private oBtnObj1
    Private cBtnObj1 := 'Cancelar'
    Private bBtnObj1 := {|| oDialogPvt:End() }  //Encerra tela

    //Criar a Dialog
    oDialogPvt := TDialog():New(0 , 0, nJanAltura, nJanLargur, cJanTitulo,/*[ uParam6 ]*/,/*[ uParam7 ]*/,/*[ uParam8 ]*/,/* [ uParam9 ]*/,/*[ nClrText ]*/, nCorFundo,/*[ uParam12 ]*/,/*[ oWnd ]*/, lDimPixels )

        //Menu com opções do Radio
        nObjLinha   := 10
        nObjColun2  := 14
        nObjLargu   := 140
        nObjAltur   := 0 //Irá atualizar o lAutoHeight
        oRadCores   := TRadMenu():New (nObjLInha, nObjColun2, aRadItens, {|u|Iif (Pcount()==0,nRadOpc,nRadOpc:=u)}, oDialogPvt,  /*uParam6*/, /*bChange*/, /*nClrText*/, /*nClrPane*/, /*cMsg*/, /*uParam11*/, /*bWhen*/, nObjLargu, nObjAltur, /*bValid*/, /*uParam16*/, lDimPixels, .T.)
        oRadCores:oFont := oFontPadrao

        //Criando botão GERAR RELATÓRIO com Classe TButton
        nObjLargu   := 50
        nObjAltur   := 15
        nObjLinha   := ((nJanAltura/2) - (nObjAltur + 6))
        nObjColun0  := ((nJanLargur/2) - (nObjLargu + 2)) //nJanLargur -> (160 - 52) = 107
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
=====================================================================================
Programa.:              ZFISF010
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              10/05/24
Descricao / Objetivo:   Chamar os relatórios de entrada e saída
Doc. Origem:            GAP173
Solicitante:            
Uso......:              
Obs......:              
=====================================================================================
*/

Static Function zOpc(nRadOpc)
 
   Do Case
        Case nRadOpc == 1 //--Nfs de ENTRADA
            FWMsgRun( ,{|| U_ZFISR018() } ,"Carregando relatório de NFs de entrada!" ,"Por favor aguarde...")
        Case nRadOpc == 2 //--Nfs de SAÍDA
            FWMsgRun( ,{|| U_ZFISR019() } ,"Carregando relatório de NFs de saída!" ,"Por favor aguarde...")
    EndCase

Return
