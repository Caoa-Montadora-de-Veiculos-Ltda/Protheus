//Bibliotecas
#Include "Protheus.ch"
 
/*
=====================================================================================
Programa.:              ZCFGF002
Autor....:              Evandro Mariano
Data.....:              08/01/2020
Descricao / Objetivo:   Formula Customizada
Doc. Origem:            
Solicitante:            
Uso......:              CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/
User Function ZCFGF002()

    Local aArea := GetArea()
    //Variáveis da tela
    Private oDlgForm
    Private oGrpForm
    Private oGetForm
    Private cGetForm := Space(250)
    Private oGrpAco
    Private oBtnExec
    //Tamanho da Janela
    Private nJanLarg := 500
    Private nJanAltu := 120
    Private nJanMeio := ((nJanLarg)/2)/2
    Private nTamBtn  := 048
     
    //Criando a janela
    DEFINE MSDIALOG oDlgForm TITLE "[ZCFGF002] - CAOA - Execução de Fórmulas" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Grupo Fórmula com o Get
        @ 003, 003  GROUP oGrpForm TO 30, (nJanLarg/2)-1        PROMPT "Fórmula: " OF oDlgForm COLOR 0, 16777215 PIXEL
            @ 010, 006  MSGET oGetForm VAR cGetForm SIZE (nJanLarg/2)-9, 013 OF oDlgForm COLORS 0, 16777215 PIXEL
         
        //Grupo Ações com o Botão
        @ (nJanAltu/2)-30, 003 GROUP oGrpAco TO (nJanAltu/2)-3, (nJanLarg/2)-1 PROMPT "Ações: " OF oDlgForm COLOR 0, 16777215 PIXEL
            @ (nJanAltu/2)-24, nJanMeio - (nTamBtn/2) BUTTON oBtnExec PROMPT "Executar" SIZE nTamBtn, 018 OF oDlgForm ACTION(fExecuta()) PIXEL
         
    //Ativando a janela
    ACTIVATE MSDIALOG oDlgForm CENTERED
     
    RestArea(aArea)
Return
 
/*---------------------------------------*
 | Func.: fExecuta                       |
 | Desc.: Executa a fórmula digitada     |
 *---------------------------------------*/
 
Static Function fExecuta()
    Local aArea    := GetArea()
    Local cFormula := Alltrim(cGetForm)
    Local cError   := ""
    Local bError   := ErrorBlock({ |oError| cError := oError:Description})
     
    //Se tiver conteúdo digitado
    If ! Empty(cFormula)
        //Inicio a utilização da tentativa
        Begin Sequence
            &(cFormula)
        End Sequence
         
        //Restaurando bloco de erro do sistema
        ErrorBlock(bError)
         
        //Se houve erro, será mostrado ao usuário
        If ! Empty(cError)
            MsgStop("Houve um erro na fórmula digitada: "+CRLF+CRLF+cError, "Atenção")
        EndIf
    EndIf
     
    RestArea(aArea)
Return