//Bibliotecas
#Include "Protheus.ch"
#Include "Rwmake.ch"
 
/*/{Protheus.doc} zMsgLog
Função que mostra uma mensagem de Log com a opção de salvar em txt
@type function
@author Atilio
@since 14/04/2017
@version 1.0
@param cMsg, character, Mensagem de Log
@param cTitulo, character, Título da Janela
@param nTipo, numérico, Tipo da Janela (1 = Ok; 2 = Confirmar e Cancelar)
@param lEdit, lógico, Define se o Log pode ser editado pelo usuário
@return lRetMens, Define se a janela foi confirmada
@example
    u_zMsgLog("Daniel Teste 123", "Título", 1, .T.)
    u_zMsgLog("Daniel Teste 123", "Título", 2, .F.)
/*/
 
User Function zGenMsg(cMsg, cTitulo)
    Local lRetMens      := .F.
    Local oDlgMens
    Local oBtnOk
    Local oBtnSlv
    Local oFntTxt       := TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)
    Local oMsg
    Default cMsg        := ""
    Default cTitulo     := "zGenMsg"
    Default nTipo       := 1 // 1=Ok; 2= Confirmar e Cancelar
    Default lEdit       := .F.
 
    //Criando a janela centralizada com os botões
    DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 500, 800 COLORS 0, 16777215 PIXEL
        //Get com o Log
        @ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 395,220 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
         
        @ 226, 275 BUTTON oBtnOk  PROMPT "Sair"   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
            
        //Botão de Salvar em Txt
        @ 226, 335 BUTTON oBtnSlv PROMPT "Salvar em .txt" SIZE 051, 019 ACTION (fSalvArq(cMsg, cTitulo)) OF oDlgMens PIXEL
    ACTIVATE MSDIALOG oDlgMens CENTERED
 
Return()
 
/*-----------------------------------------------*
 | Função: fSalvArq                              |
 | Descr.: Função para gerar um arquivo texto    |
 *-----------------------------------------------*/
 
Static Function fSalvArq(cMsg, cTitulo)
    
    Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
    Local lOk      := .T.
    Local cTexto   := ""

    Local _cDirIni   := "C:/"//GetTempPath()
    Local _cTipArq   := "Arquivo TXT (*.txt)"
    Local _cTitulo   := "Selecione o Local para Salvar"
    Local _lSalvar   := .T.
    
  
    //Chama a função para buscar arquivos
    cFileNom := tFileDialog(;
                            _cTipArq,;  // Filtragem de tipos de arquivos que serão selecionados
                            _cTitulo,;  // Título da Janela para seleção dos arquivos
                            ,;          // Compatibilidade
                            _cDirIni,;  // Diretório inicial da busca de arquivos
                            _lSalvar,;  // Se for .T., será uma Save Dialog, senão será Open Dialog
                            ;           // Se não passar parâmetro, irá pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT será possível pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY será possível selecionar o diretório
                            )

    //Se o nome não estiver em branco    
    If !Empty(cFileNom)
        //Teste de existência do diretório
        If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
            Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
            Return
        EndIf
         
        //Montando a mensagem
        cTexto := "Função   - "+ FunName()       + CRLF
        cTexto += "Usuário  - "+ cUserName       + CRLF
        cTexto += "Data     - "+ dToC(dDataBase) + CRLF
        cTexto += "Hora     - "+ Time()          + CRLF
        cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg + cQuebra
         
        //Testando se o arquivo já existe
        If File(cFileNom)
            lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
        EndIf
         
        If lOk
            MemoWrite(cFileNom, cTexto)
            MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
        EndIf
    EndIf

Return
