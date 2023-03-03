#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TopConn.ch"
/*
=====================================================================================
Programa.:              CMVETQ01
Autor....:              Marcelo Carneiro
Data.....:              04/01/2020
Descricao / Objetivo:   Lê o arquivo e grava na D0Y
Doc. Origem:            Projeto
Solicitante:            Projeto
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/

User Function CMVETQ01()

Local oDLg
Local bGetDir := {|| cDiretorio := cGetFile ( , "Selecione o arquivo:", 1,, .F., GETF_LOCALHARD )}


Private cDir	    := 'C:\TEMP\'
Private cDiretorio	:= 'C:\TEMP\'
Private cFilInv		:= "Campos.txt"
Private cArquivo   := Space(50)
Private cExt	   := ""
Private cTitulo    := "Altera Campos"
Private nTam       := 15
Private nDec       := 5
Private cPict      := '@E 999,999,999.99999'

cDiretorio := cDiretorio + Space(100-Len(cDiretorio))

Define MSDialog oDlg Title cTitulo From 0,0 TO 10,80 Of oMainWnd
	@ 0.2,1	 Say "Arquivo:"
	@ 0.2,7	 MSGet cDiretorio SIZE 200,8 Picture "@!"  Valid (Vazio() .OR. IIF(!File(AllTrim(cDiretorio)),(MsgStop("Arquivo Inválido!"),.F.),.T.)) When .F. Of oDlg
	@ 2,250   BUTTON "..."              SIZE 12,12 ACTION (Eval(bGetDir))                  Pixel OF oDlg
	@ 50,155  BUTTON "Etiqueta"         SIZE 60,12 ACTION (Atu_dados())                      Pixel OF oDlg
    @ 50,055  BUTTON "Atualiza SB5"     SIZE 60,12 ACTION (Atu_SB5())                      Pixel OF oDlg
	@ 50,230 BUTTON "Sair"             SIZE 60,12 ACTION (oDlg:End())    				  Pixel OF oDlg

Activate MSDialog oDlg Centered
	
Return
************************************************************************************************************
Static Function Atu_dados
Local cLinha       := ''
Local cArqRet      := ''
Local aDados	   := {} 
Local nCont1       := 0 
Local nCont2       := 0 

cDiretorio := Alltrim(cDiretorio)

D0Y->(dbSetOrder(1))
Ft_FUse(cDiretorio)
While !FT_FEof() 
	cLinha := FT_FReadLn()
	IF Empty(cLinha)
	     FT_FSkip()
	     Loop
	EndIf
	aDados	:= Separa(cLinha,";",.T.)
	nCont1++
	If !D0Y->( dbSeek( '2010022001'+PADR(Alltrim(aDados[01]),40,' ')) ) 
		nCont2++
		RecLock("D0Y",.T.)
		D0Y->D0Y_FILIAL	:= '2010022001'
		D0Y->D0Y_IDUNIT	:= Alltrim(aDados[01])
		D0Y->D0Y_DATGER	:= Date()		// Data Geração  *
		D0Y->D0Y_HORGER	:= Time()		// Hora Geração *
		D0Y->D0Y_USUARI	:=	'000048'
		D0Y->D0Y_TIPGER	:= '1' 			// valor padrão *
		D0Y->D0Y_USADO	:= '2'  		// valor padrão *
		D0Y->D0Y_IMPRES	:= '2'  		// valor padrão *
		D0Y->D0Y_TIPUNI	:= Alltrim(aDados[02])
		D0Y->( msUnlock() )
	EndIF
	FT_FSkip()
End
msgAlert('alteração finalizada, Incluídos :'+Alltrim(STR(nCont2))+' de '+Alltrim(STR(nCont1)))

Return
************************************************************************************************************
Static Function Atu_SB5
Local cLinha       := ''
Local cArqRet      := ''
Local aDados	   := {} 
Local nCont        := 0 

cDiretorio := Alltrim(cDiretorio)
//B5_FILIAL	B5_COD	B5_XSEQABA

SB5->(dbSetOrder(1))
Ft_FUse(cDiretorio)
While !FT_FEof() 
	cLinha := FT_FReadLn()
	aDados	:= Separa(cLinha,";",.T.)
	If SB5->( dbSeek( PADR(aDados[01],10, ' ')+Alltrim(aDados[02])) ) 
		nCont++
		RecLock("SB5",.F.)
		SB5->B5_XSEQABA	:= Alltrim(aDados[03])
		SB5->( msUnlock() )
	EndIF
	FT_FSkip()
End
msgAlert('alteração finalizada, Atualizados :'+Alltrim(STR(nCont)))

Return
************************************************************************************************************


