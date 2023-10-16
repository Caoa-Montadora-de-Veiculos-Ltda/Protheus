//Bibliotecas
#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "FWMVCDEF.ch"
#Include "Topconn.ch"
 
Static _cCLIENTE As Character 
  
/*/{Protheus.doc} User Function ZCOMF056
  (Função responasvel por consulta padrão específica dos códigos de compradores )
  @type  Function
  @author Nicolas Lima
  @since 13/10/23
  @version P12
  @return return_var, return_type, return_description
/*/

User Function ZCOMF056()
    Local aArea := FWGetArea()
    Local lRet  := .F.

        Begin sequence
            
            cCLIENTE := ""

            lRet := fMontaTela()

        End Sequence

    FWRestArea(aArea)
Return lRet

//Retorna a variável para a tela, é chamado no campo de retorno da consulta padrão.
User Function zCOMF56A()

Return _cCLIENTE

Static Function fMontaTela()
    
    Local lRet          := .F.
    Local lDimPixels    := .T.   //Dimensões dos botões em pixels

    Local aCampos       := {} //Array com campos que vão nas colunas da grid.
    Local aColunas      := {} //Colunas da Grid.
    Local oTempTable    := Nil //Objeto da tabela temporaria

    //Tamanho da Janela
    Private nJanLarg    := 700
    Private nJanAltu    := 320//320
    //Tamanho e tipo de fonte
    Private cFontNome   := 'Tahoma'
    Private oFontPadrao := TFont():New(cFontNome, , -12) 
    //Obj1 - Botão SELECIONAR
    Private oBtnObj1 
    Private cBtnObj1    := "Selecionar" //Label botão 
    Private bBtnObj1    := {|| lRet := .T., oDlg:End(), fSelecionar() }  //Bloco de código
    //Obj2 - Botão CANCELAR
    Private oBtnObj2
    Private cBtnObj2    := "Cancelar" //Label botão 
    Private bBtnObj2    := {|| lRet := .F., oDlg:End() }  //Bloco de código
    
    //Tamanho dos botões
    Private nBotLarg    := 0
    Private nBotAltu    := 0
    //Posição dos botões
    Private nBotLinha   := 0
    Private nBotColun   := 0
    //Janela e componentes
    Private oDlg     //Objeto da Dialog
    Private oPanGrid //Objeto da Grid
    Private oBrowse  //Objeto da tela
    Private cAliasTmp := GetNextAlias() //Alias da tabela temporária

    //Adiciona as colunas que serão criadas na temporária
    aAdd(aCampos, { 'ID_COMPR' , 'C', 15, 0}) //Código
    aAdd(aCampos, { 'NOME'     , 'C', 50, 0}) //Descrição

    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:AddIndex("1", {"ID_COMPR"})
    oTempTable:AddIndex("2", {"NOME"})
    oTempTable:Create()  

    //Popula a tabela temporária
    fPopula()

    //Adiciona as colunas que serão exibidas no FWBrowse
    aColunas := fCriaCols()
  
    //Criando a janela
    DEFINE MSDIALOG oDlg TITLE "Cadastro de Compradores" FROM 000, 000 TO nJanAltu,nJanLarg COLORS 0, 16777215 PIXEL
        
        //Dados
        oPanGrid := tPanel():New(002, 002, '', oDlg, , , , RGB(000,000,000), RGB(254,254,254), ((nJanLarg/2)-1),133/*110*/) //((nJanLarg/2)-1),((nJanAltu/2) - 1))
        oBrowse  := FWBrowse():New()
        oBrowse:SetAlias(cAliasTmp)
        oBrowse:DisableFilter()
        oBrowse:DisableReport()
        oBrowse:SetFontBrowse(oFontPadrao)
        oBrowse:SetDoubleClick( {|| lRet := .T., oDlg:End(), fSelecionar()} ) 
        oBrowse:SetDataTable()
        oBrowse:SetInsert(.F.)
        oBrowse:SetDelete(.F., { || .F. })
        oBrowse:lHeaderClick := .T. //Teste
        oBrowse:SetColumns(aColunas)
        oBrowse:SetOwner(oPanGrid)
        oBrowse:Activate()
        
        //Obj1 - Botão SELECIONAR
        nBotLarg    := 45
        nBotAltu    := 15
        nBotLinha   := 140
        nBotColun   := 305 
        oBtnObj1    := TButton():New(nBotLinha, nBotColun, cBtnObj1, oDlg, bBtnObj1, nBotLarg, nBotAltu, , oFontPadrao, , lDimPixels)
        oBtnObj1:SetCSS("TButton { font: bold;     background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #0D9CBF);    color: #FFFFFF;     border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:focus {    padding:0px; outline-width:1px; outline-style:solid; outline-color: #51DAFC; outline-radius:3px; border-color:#369CB5;}TButton:hover {    color: #FFFFFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #1188A6);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:pressed {    color: #FFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #1188A6, stop: 1 #3DAFCC);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:disabled {    color: #FFFFFF;     background-color: #4CA0B5; }")

        //Obj2 - Botão CANCELAR
        nBotLarg    := 40
        nBotAltu    := 15
        nBotLinha   := 140
        nBotColun   := 260   
        oBtnObj2    := TButton():New(nBotLinha, nBotColun, cBtnObj2, oDlg, bBtnObj2, nBotLarg, nBotAltu, , oFontPadrao, , lDimPixels)
        
    ACTIVATE MSDIALOG oDlg CENTER
 
Return lRet
 

//Popula tabela temporária com informaç~eos que vão aparecer na grid.
Static Function fPopula()

    Local cQuery := ""

    //Query que busca ID user, ID Comprador e Status Bloqueio nas tabelas SYS_USR e SY1
    cQuery += "   SELECT "                                      + CRLF
    cQuery += " Y1_COD --AS 'COD_COMPRADOR' "                   + CRLF
	cQuery += " , USR_ID --AS 'COD_USUARIO' "                   + CRLF
	cQuery += " , Y1_NOME "                                     + CRLF  
    cQuery += "   FROM  "                                       + CRLF
    cQuery += "            (	SELECT USRTMP.USR_ID "          + CRLF
    cQuery += "                , USRTMP.USR_NOME  "             + CRLF
    cQuery += "                , USRTMP.USR_MSBLQL  "           + CRLF
    cQuery += "                FROM  "                          + CRLF //--TABELA DE USUÁRIOS
    cQuery += "                SYS_USR USRTMP "                 + CRLF //--TABELA DE USUÁRIOS
    cQuery += "                WHERE  "                         + CRLF
    cQuery += "                USRTMP.D_E_L_E_T_ = ' '  "       + CRLF 
    cQuery += "                ORDER BY USRTMP.USR_ID  "        + CRLF
    cQuery += "            ) TMP_USR  "                         + CRLF
    cQuery += "        LEFT JOIN  "                             + CRLF
    cQuery += "            ( 	SELECT SY1TMP.Y1_COD  "         + CRLF
    cQuery += "                , SY1TMP.Y1_NOME  "              + CRLF
    cQuery += "                , SY1TMP.Y1_USER  "              + CRLF
    cQuery += "                FROM  "                          + CRLF
    cQuery += " " 		       + RetSqlName("SY1") + " SY1TMP "	+ CRLF //--TABELA DE COMPRADORES
    cQuery += "                WHERE  "                         + CRLF
    cQuery += "                SY1TMP.Y1_FILIAL = '" + FWxFilial("SY1") + "' "  + CRLF
    cQuery += "                AND SY1TMP.D_E_L_E_T_ = ' '  "   + CRLF
    cQuery += "                ORDER BY SY1TMP.Y1_USER  "       + CRLF
    cQuery += "            ) TMP_SY1  "                         + CRLF
    cQuery += "        ON TMP_USR.USR_ID = TMP_SY1.Y1_USER  "   + CRLF
    cQuery += "        WHERE  "                                 + CRLF
    cQuery += "        TMP_SY1.Y1_COD IS NOT NULL  "            + CRLF
    cQuery += "         AND TMP_USR.USR_MSBLQL = '2' "          + CRLF //USR_MSBLQL = '2' -- DESBLOQUEADO
    cQuery += "        ORDER BY TMP_SY1.Y1_NOME "               + CRLF
    //Monta a consulta
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'QRYDADTMP',.T.,.T.)
    DbSelectArea('QRYDADTMP')
    QRYDADTMP->(DbGoTop())

    //Enquanto houver registros, adiciona na temporária
    While ! QRYDADTMP->(EoF())

        RecLock(cAliasTmp, .T.)
            (cAliasTmp)->ID_COMPR   := QRYDADTMP->Y1_COD
            (cAliasTmp)->NOME       := Upper(Alltrim(QRYDADTMP->Y1_NOME))
        (cAliasTmp)->(MsUnlock())

        QRYDADTMP->(DbSkip())
    EndDo
    QRYDADTMP->(DbCloseArea())
    (cAliasTmp)->(DbGoTop())
Return

//Cria colunas na Grid.
Static Function fCriaCols()
    Local nAtual   := 0 
    Local aColunas := {}
    Local aEstrut  := {}
    Local oColumn
    
    //Adicionando campos que serão mostrados na tela
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara
    aAdd(aEstrut, { 'ID_COMPR'  , 'ID Comprador', 'C', 005, 0, ''})
    //aAdd(aEstrut, { 'ID_USR'    , 'ID Usuario'  , 'C', 005, 0, ''}) 
    aAdd(aEstrut, { 'NOME'      , 'Nome'        , 'C', 040, 0, ''}) 

    //Percorrendo todos os campos da estrutura
    For nAtual := 1 To Len(aEstrut)
        //Cria a coluna
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}')) //Campo
        oColumn:SetTitle(aEstrut[nAtual][2])   //Título do campo
        oColumn:SetType(aEstrut[nAtual][3])    //Tipo de cadactere
        oColumn:SetSize(aEstrut[nAtual][4])    //Definição do tamanho
        oColumn:SetDecimal(aEstrut[nAtual][5]) //Decimais
        oColumn:SetPicture(aEstrut[nAtual][6]) //Máscara

        //Adiciona a coluna
        aAdd(aColunas, oColumn)
    Next
Return aColunas

Static Function fSelecionar() //Ação dos botões Duplo clique, Selecionar ou Cancelar
    Local aArea     := FWGetArea()
    Local cIDCompr  := AllTrim((cAliasTmp)->ID_COMPR)

    If !Empty(cIDCompr) //.And. lRet
        _cCLIENTE := cIDCompr //_cCliente é a variável de retorno
    EndIf

    FWRestArea(aArea)
Return 
