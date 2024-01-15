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
    Local nJanAltura    := 320
    Local nJanLargur    := 720
    Local cJanTitulo    := 'Ajuste de peso cubado e/ou peso bruto.'
    Local lDimPixels    := .T.
    Local lCentraliz    := .T.
    
    Local nObjLinha     := 0
    Local nObjLargu     := 0
    Local nObjAltur     := 0

    //Fonte
    Private cFontNome := 'Tahoma'
    Private oFontPadrao := TFont():New(cFontNome, , -12)

    //Janela e componentes
    Private oDialog  //Objeto da tela
    Private oPanGrid //Objeto da Grid
    Private oBrowse  //Objeto da tela
    Private cAliasTmp := GetNextAlias() //Alias da tabela tempor�ria
    //Private bBlocoIni := {|| MsgInfo("TESTE","TESTE") } //Aqui voce pode adicionar funcoes customizadas que irao ser adicionadas ao abrir a dialog. //Preciso tester isso

    //Bot�es - Posi��o
    Private nBotPosCol0   := 0  //Posi��o coluna Bot�o PROCESSAR
    Private nBotPosCol1   := 0  //Posi��o coluna Bot�o CANCELAR
    Private nBotPosCol2   := 0  //Posi��o coluna Bot�o SIMULAR
    Private nBotLargu     := 0  //Largura dos bot�es
    
    //Objeto 00 Bot�o PROCESSAR
    Private oBtnObj0                  //Objeto do bot�o
    Private cBtnObj0    := 'Processar'   //T�tulo do bot�o
    Private bBtnObj0 := {|| MsgInfo("Gerar relat�rio","Gerar relat�rio")/*zOpc(nRadOpc), oDialog:End()*/} //Funcionalidade do bot�o
    /*oBtnObj0:SetCSS("TButton            { font: bold;       background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #0D9CBF);    color: #FFFFFF;     border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }" + CRLF +;
                    "TButton:focus      { padding:0px;      outline-width:1px; outline-style:solid; outline-color: #51DAFC; outline-radius:3px; border-color:#369CB5;}" + CRLF +;
                    "TButton:hover      { color: #FFFFFF;   background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #1188A6);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }" + CRLF +;
                    "TButton:pressed    { color: #FFF;      background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #1188A6, stop: 1 #3DAFCC);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:disabled {    color: #FFFFFF;     background-color: #4CA0B5; }")
    */
    //Objeto 01 Bot�o CANCELAR
    Private oBtnObj1 //Objeto do bot�o
    Private cBtnObj1    := 'Cancelar' //T�tulo do bot�o
    Private bBtnObj1 := {|| oDialog:End() }  //Funcionalidade do bot�o - Encerrar tela

    //Objeto 02 Bot�o SIMULAR
    Private oBtnObj2                  //Objeto do bot�o
    Private cBtnObj2    := 'Simular'   //T�tulo do bot�o
    Private bBtnObj2 := {|| MsgInfo("Simular","Simular")/*zOpc(nRadOpc), oDialog:End()*/} //Funcionalidade do bot�o
        
    //Objeto 03 N�mero da NF
    Private oSayObj3 
    Private cSayObj3    := 'N�mero da NF:'

    //Objeto 04 GET Numero da NF -> F2_DOC
    Private oGetObj4 
    Private xGetObj4    := '000528171'//TamSX3("F2_DOC")

    //Objeto 05 Pedido
    Private oSayObj5 
    Private cSayObj5    := 'Pedido:'

    //Objeto 06 GET Pedido -> C7_DOC
    Private oGetObj6 
    Private xGetObj6    := '000208'//TamSX3("C7_NUM")

    //Objeto 07 Chave
    Private oSayObj7 
    Private cSayObj7    := 'Chave:'

    //Objeto 08 GET Chave -> F2_CHVNFE
    Private oGetObj8 
    Private xGetObj8    := '35220503471344000509550070005281711175765402' //TamSX3("F2_CHVNFE")

    //Objeto 09 Cliente
    Private oSayObj9 
    Private cSayObj9    := 'Cliente:'

    //Objeto 10 GET Cliente -> A1_COD
    Private oGetObj10 
    Private xGetObj10   := '000134' //TamSX3("A1_COD")

    //Objeto 11 Nome Cliente
    Private oSayObj11 
    Private cSayObj11   := 'Nome Cliente:'

    //Objeto 12 GET Nome Cliente -> A1_NOME
    Private oGetObj12 
    Private xGetObj12   := 'YELLOW MOUNTAIN DISTRIBUIDORA DE VEICULO' //TamSX3("A1_NOME")

    //Objeto 13 Peso cubado atual
    Private oSayObj13 
    Private cSayObj13   := 'Peso cubado atual:'

    //Objeto 14 GET Peso Cubado atual -> F2_XPESOC
    Private oGetObj14 
    Private xGetObj14   := '2,5 Kg' //TamSX3("F2_XPESOC")

    //Objeto 15 Peso bruto atual
    Private oSayObj15 
    Private cSayObj15   := 'Peso bruto atual:'

    //Objeto 16 GET Peso bruto atual -> F2_PBRUTO
    Private oGetObj16 
    Private xGetObj16   := '5,0 Kg' //TamSX3("F2_PBRUTO")

    //Objeto 17 Peso cubado NOVO
    Private oSayObj17 
    Private cSayObj17   := 'Peso cubado novo:'

    //Objeto 18 GET Peso Cubado NOVO -> F2_XPESOC
    Private oGetObj18 
    Private xGetObj18   := TamSX3("F2_XPESOC")

    //Objeto 19 Peso bruto NOVO
    Private oSayObj19 
    Private cSayObj19   := 'Peso bruto novo:'

    //Objeto 20 GET Peso bruto NOVO -> F2_PBRUTO
    Private oGetObj20 
    Private xGetObj20   := TamSX3("F2_PBRUTO")

    //Adiciona as colunas que ser�o criadas na tempor�ria
    aAdd(aCampos, { 'ID_COMPR' , 'C', 15, 0}) //C�digo
    aAdd(aCampos, { 'NOME'     , 'C', 50, 0}) //Descri��o

    //Cria a tabela tempor�ria
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:AddIndex("1", {"ID_COMPR"})
    oTempTable:AddIndex("2", {"NOME"})
    oTempTable:Create()  

    //Popula a tabela tempor�ria
    fPopula()

    //Adiciona as colunas que ser�o exibidas no FWBrowse
    aColunas := fCriaCols()


    //Criar a Dialog
    oDialog := TDialog():New(0 , 0, nJanAltura, nJanLargur, cJanTitulo,/*[ uParam6 ]*/,/*[ uParam7 ]*/,/*[ uParam8 ]*/,/* [ uParam9 ]*/,/*[ nClrText ]*/, nCorFundo,/*[ uParam12 ]*/,/*[ oWnd ]*/, lDimPixels )   
      
        //Dados da Grid
        oPanGrid := tPanel():New(002, 002, '', oDlg, , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-1),133/*110*/) //((nJanLarg/2)-1),((nJanAltu/2) - 1))
        oBrowse  := FWBrowse():New()
        oBrowse:SetAlias(cAliasTmp)
        oBrowse:DisableFilter()
        oBrowse:DisableReport()
        oBrowse:SetFontBrowse(oFontPadrao)
        //oBrowse:SetDoubleClick( {|| lRet := .T., oDlg:End(), fSelecionar()} ) 
        oBrowse:SetDataTable()
        oBrowse:SetInsert(.F.)
        oBrowse:SetDelete(.F., { || .F. })
        oBrowse:lHeaderClick := .T. //Teste
        oBrowse:SetColumns(aColunas)
        oBrowse:SetOwner(oPanGrid)
        oBrowse:Activate()

        //Objeto 00 Bot�o PROCESSAR Classe TButton
        nObjLargu   := 40
        nObjAltur   := 15
        nObjLinha   := 140 //((nJanAltura/2) - (nObjAltur + 6))
        nObjColun0  := 315 //((nJanLargur/2) - (nObjLargu + 2)) //nJanLargur -> (160 - 52) = 107
        oBtnObj0    := TButton():New(nObjLinha, nObjColun0, cBtnObj0, oDialog, bBtnObj0, nObjLargu, nObjAltur, , oFontPadrao, , lDimPixels)
        oBtnObj0:SetCSS("TButton {  font: bold; background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #0D9CBF);    color: #FFFFFF;     border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:focus {    padding:0px; outline-width:1px; outline-style:solid; outline-color: #51DAFC; outline-radius:3px; border-color:#369CB5;}TButton:hover {    color: #FFFFFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #1188A6);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:pressed {    color: #FFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #1188A6, stop: 1 #3DAFCC);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:disabled {    color: #FFFFFF;     background-color: #4CA0B5; }")

        //Objeto 01 Bot�o CANCELAR Classe TButton
        nObjLargu   := 40
        nObjAltur   := 15
        nObjLinha   := 140 //((nJanAltura/2) - (nObjAltur + 6))
        nObjColun1  := 270 //((nObjColun0-4) - (nObjLargu+2)) //nJanLargur ->  = 43
        oBtnObj1    := TButton():New(nObjLinha, nObjColun1, cBtnObj1, oDialog, bBtnObj1, nObjLargu, nObjAltur, , oFontPadrao, , lDimPixels)

        //Objeto 02 Bot�o SIMULAR Classe TButton
        nObjLargu   := 40
        nObjAltur   := 15
        nObjLinha   := 120 //((nJanAltura/2) - (nObjAltur + 6))
        nObjColun2  := 315 //((nObjColun0-4) - (nObjLargu+2)) //nJanLargur ->  = 43
        oBtnObj2    := TButton():New(nObjLinha, nObjColun2, cBtnObj2, oDialog, bBtnObj2, nObjLargu, nObjAltur, , oFontPadrao, , lDimPixels)

        //Objeto 03 TSay N�MERO DE NF Classe TSay
        nObjLargu   := 80
        nObjAltur   := 10
        nObjLinha   := 5
        nObjColun   := 5
        oSayObj3    := TSay():New(nObjLinha, nObjColun, {|| cSayObj3}, oDialog, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)
            
        //Objeto 04 TGet N�MERO DE NF Classe TGet
        nObjLargu   := 50
        nObjAltur   := 10
        nObjLinha   := 4
        nObjColun   := 50
        oGetObj4    := TGet():New(nObjLinha, nObjColun, {|u| Iif(PCount() > 0 , xGetObj4 := u, xGetObj4)}, oDialog, nObjLargu, nObjAltur, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels)
        //oGetObj4:cPlaceHold := 'Digite aqui um texto...'   //Texto que sera exibido no campo antes de ter conteudo
        //oGetObj4:cF3        := 'Codigo da consulta padrao' //Codigo da consulta padrao / F3 que sera habilitada
        //oGetObj4:bValid     := {|| fFuncaoVld()}           //Funcao para validar o que foi digitado
        oGetObj4:lReadOnly  := .T.                           //Para permitir o usuario clicar mas nao editar o campo
        //oGetObj4:lActive  := .F.                           //Para deixar o campo inativo e o usuario nao conseguir nem clicar
        //oGetObj4:Picture      := '@!'                      //Mascara / Picture do campo

        //Objeto 05 TSay PEDIDO Classe TSay
        nObjLargu   := 80
        nObjAltur   := 10
        nObjLinha   := 5
        nObjColun   := 105
        oSayObj5    := TSay():New(nObjLinha, nObjColun, {|| cSayObj5}, oDialog, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)
            
        //Objeto 06 TGet PEDIDO Classe TGet
        nObjLargu   := 50
        nObjAltur   := 10
        nObjLinha   := 4
        nObjColun   := 130
        oGetObj6    := TGet():New(nObjLinha, nObjColun, {|u| Iif(PCount() > 0 , xGetObj6 := u, xGetObj6)}, oDialog, nObjLargu, nObjAltur, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels)
        oGetObj6:lReadOnly  := .T.                           //Para permitir o usuario clicar mas nao editar o campo
       
        //Objeto 07 TSay CHAVE Classe TSay
        nObjLargu   := 80
        nObjAltur   := 10
        nObjLinha   := 20
        nObjColun   := 5
        oSayObj7    := TSay():New(nObjLinha, nObjColun, {|| cSayObj7}, oDialog, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)

        //Objeto 08 TGet CHAVE Classe TGet
        nObjLargu   := 180
        nObjAltur   := 10
        nObjLinha   := 19
        nObjColun   := 50
        oGetObj8    := TGet():New(nObjLinha, nObjColun, {|u| Iif(PCount() > 0 , xGetObj8 := u, xGetObj8)}, oDialog, nObjLargu, nObjAltur, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels)
        oGetObj8:lReadOnly  := .T.                           //Para permitir o usuario clicar mas nao editar o campo
      
        //Objeto 09 TSay CLIENTE Classe TSay
        nObjLargu   := 80
        nObjAltur   := 10
        nObjLinha   := 5
        nObjColun   := 190
        oSayObj9   := TSay():New(nObjLinha, nObjColun, {|| cSayObj9}, oDialog, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)

        //Objeto 10 TGet CLIENTE Classe TGet
        nObjLargu   := 50
        nObjAltur   := 10
        nObjLinha   := 4
        nObjColun   := 220
        oGetObj10   := TGet():New(nObjLinha, nObjColun, {|u| Iif(PCount() > 0 , xGetObj10 := u, xGetObj10)}, oDialog, nObjLargu, nObjAltur, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels)
        oGetObj10:lReadOnly  := .T.                           //Para permitir o usuario clicar mas nao editar o campo

        //Objeto 11 TSay NOME CLIENTE Classe TSay
        nObjLargu   := 80
        nObjAltur   := 10
        nObjLinha   := 35
        nObjColun   := 5
        oSayObj11    := TSay():New(nObjLinha, nObjColun, {|| cSayObj11}, oDialog, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)

        //Objeto 12 TGet NOME CLIENTE Classe TGet
        nObjLargu   := 180
        nObjAltur   := 10
        nObjLinha   := 34
        nObjColun   := 50
        oGetObj12   := TGet():New(nObjLinha, nObjColun, {|u| Iif(PCount() > 0 , xGetObj12 := u, xGetObj12)}, oDialog, nObjLargu, nObjAltur, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels)
        oGetObj12:lReadOnly  := .T.                           //Para permitir o usuario clicar mas nao editar o campo

        //Objeto 13 TSay PESO CUBADO ATUAL Classe TSay
        nObjLargu   := 80
        nObjAltur   := 10
        nObjLinha   := 50
        nObjColun   := 5
        oSayObj13    := TSay():New(nObjLinha, nObjColun, {|| cSayObj13}, oDialog, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)

        //Objeto 14 TGet PESO CUBADO ATUAL Classe TGet
        nObjLargu   := 30
        nObjAltur   := 10
        nObjLinha   := 49
        nObjColun   := 60
        oGetObj14   := TGet():New(nObjLinha, nObjColun, {|u| Iif(PCount() > 0 , xGetObj14 := u, xGetObj14)}, oDialog, nObjLargu, nObjAltur, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels)
        oGetObj14:lReadOnly  := .T.                           //Para permitir o usuario clicar mas nao editar o campo
        
        //Objeto 15 TSay PESO BRUTO ATUAL Classe TSay
        nObjLargu   := 80
        nObjAltur   := 10
        nObjLinha   := 50
        nObjColun   := 105
        oSayObj15   := TSay():New(nObjLinha, nObjColun, {|| cSayObj15}, oDialog, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)

        //Objeto 16 TGet PESO BRUTO ATUAL Classe TGet
        nObjLargu   := 30
        nObjAltur   := 10
        nObjLinha   := 49
        nObjColun   := 140
        oGetObj16   := TGet():New(nObjLinha, nObjColun, {|u| Iif(PCount() > 0 , xGetObj16 := u, xGetObj16)}, oDialog, nObjLargu, nObjAltur, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels)
        oGetObj16:lReadOnly  := .T.                           //Para permitir o usuario clicar mas nao editar o campo

        //Objeto 17 TSay PESO CUBADO NOVO Classe TSay
        nObjLargu   := 80
        nObjAltur   := 10
        nObjLinha   := 65
        nObjColun   := 5
        oSayObj17    := TSay():New(nObjLinha, nObjColun, {|| cSayObj17}, oDialog, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)

        //Objeto 18 TGet PESO CUBADO NOVO Classe TGet
        nObjLargu   := 30
        nObjAltur   := 10
        nObjLinha   := 64
        nObjColun   := 70
        oGetObj18   := TGet():New(nObjLinha, nObjColun, {|u| Iif(PCount() > 0 , xGetObj18 := u, xGetObj18)}, oDialog, nObjLargu, nObjAltur, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels)
        oGetObj18:lReadOnly  := .T.                           //Para permitir o usuario clicar mas nao editar o campo
        
        //Objeto 19 TSay PESO BRUTO NOVO Classe TSay
        nObjLargu   := 80
        nObjAltur   := 10
        nObjLinha   := 65
        nObjColun   := 105
        oSayObj19   := TSay():New(nObjLinha, nObjColun, {|| cSayObj19}, oDialog, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)

        //Objeto 20 TGet PESO BRUTO NOVO Classe TGet
        nObjLargu   := 30
        nObjAltur   := 10
        nObjLinha   := 64
        nObjColun   := 150
        oGetObj20   := TGet():New(nObjLinha, nObjColun, {|u| Iif(PCount() > 0 , xGetObj20 := u, xGetObj20)}, oDialog, nObjLargu, nObjAltur, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels)
        oGetObj20:lReadOnly  := .T.                           //Para permitir o usuario clicar mas nao editar o campo

    oDialog:Activate(, , , lCentraliz, , , bBlocoIni)

    FWRestarea(aArea)
Return     
