#Include "Totvs.ch"

/*
=====================================================================================
Programa.:              ZFATF024
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              10/01/24
Descricao / Objetivo:   Tela para par�metro de ajuste de peso cubado e/ou bruto.
Doc. Origem:            GAP032
Solicitante:            
Uso......:              
Obs......:              
=====================================================================================
*/

User Function ZFATF024()

    Local aArea         := FwGetArea()
    
    //Defini��es da tela principal
    Local nCorFundo     := RGB(238, 238, 238)
    Local nJanAltura    := 120
    Local nJanLargur    := 320
    Local cJanTitulo    := 'Ajuste de peso cubado e/ou peso bruto.'
    Local lDimPixels    := .T.
    Local lCentraliz    := .T.
    
    Local nObjLinha     := 0
    Local nObjLargu     := 0
    Local nObjAltur     := 0

    //Fonte
    Private cFontNome := 'Tahoma'
    Private oFontPadrao := TFont():New(cFontNome, , -12)

    //Bot�es - Posic��o
    Private nBotPosCol0   := 0  //Posi��o coluna Bot�o PROCESSAR
    Private nBotPosCol1   := 0  //Posi��o coluna Bot�o CANCELAR
    Private nBotPosCol2   := 0  //Posi��o coluna Bot�o SIMULAR
    Private nBotLargu     := 50 //Largura dos bot�es
    
    //Janela e componentes
    Private oDialog  //Objeto da tela
    Private oPanGrid //Objeto da Grid
    Private oBrowse  //Objeto da tela
    Private cAliasTmp := GetNextAlias() //Alias da tabela tempor�ria
    Private bBlocoIni := {|| MsgInfo("TESTE","TESTE") } //Aqui voce pode adicionar funcoes customizadas que irao ser adicionadas ao abrir a dialog. //Preciso tester isso

    //objeto0 Classe TSay
    Private oSayObj0 
    Private cSayObj0    := 'N�mero da NF:'  

    /*
    //Objeto Radio
    Private oRadCores
    Private nRadOpc := 1 //Op��es permitidas para selecionar ? Testar isso
    Private aRadItens := {"Relat�rio de Notas Fiscais de entrada", "Relat�rio de Notas Fiscais de sa�da"}
    */
    
    //Objeto0 Bot�o Confirmar
    Private oBtnObj0                        //Objeto do bot�o
    Private cBtnObj0 := 'Gerar relat�rio'   //T�tulo do bot�o
    Private bBtnObj0 := {|| zOpc(nRadOpc), oDialog:End()} //Funcionalidade do bot�o
        
    //Objeto1 Bot�o Cancelar
    Private oBtnObj1
    Private cBtnObj1 := 'Cancelar'
    Private bBtnObj1 := {|| oDialog:End() }  //Funcionalidade do bot�o - Encerra tela

    //Criar a Dialog
    oDialog := TDialog():New(0 , 0, nJanAltura, nJanLargur, cJanTitulo,/*[ uParam6 ]*/,/*[ uParam7 ]*/,/*[ uParam8 ]*/,/* [ uParam9 ]*/,/*[ nClrText ]*/, nCorFundo,/*[ uParam12 ]*/,/*[ oWnd ]*/, lDimPixels )   
        /*
        //Menu com op��es do Radio
        nObjLinha   := 10
        nObjColun2  := 14
        nObjLargu   := 140
        nObjAltur   := 0 //Ir� atualizar o lAutoHeight
        oRadCores   := TRadMenu():New (nObjLInha, nObjColun2, aRadItens, {|u|Iif (Pcount()==0,nRadOpc,nRadOpc:=u)}, oDialog,  /*uParam6/, /*bChange/, /*nClrText/, /*nClrPane/, /*cMsg/, /*uParam11/, /*bWhen/, nObjLargu, nObjAltur, /*bValid/, /*uParam16/, lDimPixels, .T.)
        //oRadCores:oFont := oFontPadrao
        //*/

        //Objeto 00 Bot�o PROCESSAR Classe TButton
        nObjLargu   := 50
        nObjAltur   := 15
        nObjLinha   := ((nJanAltura/2) - (nObjAltur + 6))
        nObjColun0  := ((nJanLargur/2) - (nObjLargu + 2)) //nJanLargur -> (160 - 52) = 107
        oBtnObj0    := TButton():New(nObjLinha, nObjColun0, cBtnObj0, oDialog, bBtnObj0, nObjLargu, nObjAltur, , oFontPadrao, , lDimPixels)
        oBtnObj0:SetCSS("TButton {  font: bold; background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #0D9CBF);    color: #FFFFFF;     border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:focus {    padding:0px; outline-width:1px; outline-style:solid; outline-color: #51DAFC; outline-radius:3px; border-color:#369CB5;}TButton:hover {    color: #FFFFFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #1188A6);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:pressed {    color: #FFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #1188A6, stop: 1 #3DAFCC);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:disabled {    color: #FFFFFF;     background-color: #4CA0B5; }")

        //Objeto 01 Bot�o CANCELAR Classe TButton
        nObjLargu   := 50
        nObjAltur   := 15
        nObjLinha   := ((nJanAltura/2) - (nObjAltur + 6))
        nObjColun1  := ((nObjColun0-4) - (nObjLargu+2)) //nJanLargur ->  = 43
        oBtnObj1    := TButton():New(nObjLinha, nObjColun1, cBtnObj1, oDialog, bBtnObj1, nObjLargu, nObjAltur, , oFontPadrao, , lDimPixels)

        //Objeto 02 Bot�o SIMULAR Classe TButton
        nObjLargu   := 50
        nObjAltur   := 15
        nObjLinha   := ((nJanAltura/2) - (nObjAltur + 6))
        nObjColun1  := ((nObjColun0-4) - (nObjLargu+2)) //nJanLargur ->  = 43
        oBtnObj1    := TButton():New(nObjLinha, nObjColun1, cBtnObj1, oDialog, bBtnObj1, nObjLargu, nObjAltur, , oFontPadrao, , lDimPixels)

        //Objeto 04 TSay NUMERO DA NF classe TSay
        nObjLargu := 40
        nObjAltur := 6
        nObjLinha := 4
        nObjColun := 4
        oSayObj0  := TSay():New(nObjLinha, nObjColun, {|| cSayObj0}, oDialog, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)

    oDialog:Activate(, , , lCentraliz, , , bBlocoIni)

    FWRestarea(aArea)
Return     

/*
=====================================================================================
Programa.:              ZFISF008
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              26/12/23
Descricao / Objetivo:   Chamar relat�rios NFs entrada e sa�da
Doc. Origem:            GAP105
Solicitante:            
Uso......:              
Obs......:              https://tdn.totvs.com/display/tec/Construtor+TDialog%3ANew
=====================================================================================
*/

Static Function zOpc(nRadOpc)
 
   Do Case
        Case nRadOpc == 1 //--Nfs de ENTRADA
            FWMsgRun( ,{|| U_ZFISR016() } ,"Carregando relat�rio de NFs de entrada!" ,"Por favor aguarde...")
        Case nRadOpc == 2 //--Nfs de SA�DA
            FWMsgRun( ,{|| U_ZFISR017() } ,"Carregando relat�rio de NFs de sa�da!" ,"Por favor aguarde...")
    EndCase

Return
