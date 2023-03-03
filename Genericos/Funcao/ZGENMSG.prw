//Bibliotecas
#Include "Protheus.ch"
#Include "Rwmake.ch"
 
/*/{Protheus.doc} zMsgLog
Fun��o que mostra uma mensagem de Log com a op��o de salvar em txt
@type function
@author Atilio
@since 14/04/2017
@version 1.0
@param cMsg, character, Mensagem de Log
@param cTitulo, character, T�tulo da Janela
@param nTipo, num�rico, Tipo da Janela (1 = Ok; 2 = Confirmar e Cancelar)
@param lEdit, l�gico, Define se o Log pode ser editado pelo usu�rio
@return lRetMens, Define se a janela foi confirmada
@example
    u_zMsgLog("Daniel Teste 123", "T�tulo", 1, .T.)
    u_zMsgLog("Daniel Teste 123", "T�tulo", 2, .F.)
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
 
    //Criando a janela centralizada com os bot�es
    DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 500, 800 COLORS 0, 16777215 PIXEL
        //Get com o Log
        @ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 395,220 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
         
        @ 226, 275 BUTTON oBtnOk  PROMPT "Sair"   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
            
        //Bot�o de Salvar em Txt
        @ 226, 335 BUTTON oBtnSlv PROMPT "Salvar em .txt" SIZE 051, 019 ACTION (fSalvArq(cMsg, cTitulo)) OF oDlgMens PIXEL
    ACTIVATE MSDIALOG oDlgMens CENTERED
 
Return()
 
/*-----------------------------------------------*
 | Fun��o: fSalvArq                              |
 | Descr.: Fun��o para gerar um arquivo texto    |
 *-----------------------------------------------*/
 
Static Function fSalvArq(cMsg, cTitulo)
    
    Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
    Local lOk      := .T.
    Local cTexto   := ""

    Local _cDirIni   := "C:/"//GetTempPath()
    Local _cTipArq   := "Arquivo TXT (*.txt)"
    Local _cTitulo   := "Selecione o Local para Salvar"
    Local _lSalvar   := .T.
    
  
    //Chama a fun��o para buscar arquivos
    cFileNom := tFileDialog(;
                            _cTipArq,;  // Filtragem de tipos de arquivos que ser�o selecionados
                            _cTitulo,;  // T�tulo da Janela para sele��o dos arquivos
                            ,;          // Compatibilidade
                            _cDirIni,;  // Diret�rio inicial da busca de arquivos
                            _lSalvar,;  // Se for .T., ser� uma Save Dialog, sen�o ser� Open Dialog
                            ;           // Se n�o passar par�metro, ir� pegar apenas 1 arquivo; Se for informado GETF_MULTISELECT ser� poss�vel pegar mais de 1 arquivo; Se for informado GETF_RETDIRECTORY ser� poss�vel selecionar o diret�rio
                            )

    //Se o nome n�o estiver em branco    
    If !Empty(cFileNom)
        //Teste de exist�ncia do diret�rio
        If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
            Alert("Diret�rio n�o existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
            Return
        EndIf
         
        //Montando a mensagem
        cTexto := "Fun��o   - "+ FunName()       + CRLF
        cTexto += "Usu�rio  - "+ cUserName       + CRLF
        cTexto += "Data     - "+ dToC(dDataBase) + CRLF
        cTexto += "Hora     - "+ Time()          + CRLF
        cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg + cQuebra
         
        //Testando se o arquivo j� existe
        If File(cFileNom)
            lOk := MsgYesNo("Arquivo j� existe, deseja substituir?", "Aten��o")
        EndIf
         
        If lOk
            MemoWrite(cFileNom, cTexto)
            MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Aten��o")
        EndIf
    EndIf

Return
