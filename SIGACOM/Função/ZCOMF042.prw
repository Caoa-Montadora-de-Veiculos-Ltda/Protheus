#INCLUDE "PROTHEUS.CH" 
#include "MSGRAPHI.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "totvs.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
#Include "MSMGADD.CH"
/*/{Protheus.doc} ZCOMF042
@author Sandro Ferreira
@since 	16/12/2021
@version 1.0
@return  
@obs	
@history    Gera browse p/ recusa da SC1
@type function
/*/
User Function ZCOMF042()
Local nJanAltu := 430      //180
Local nJanLarg := 800 //650
Local aColumns  As Array
Local nContFlds As Numeric
Local oListBox
Local aArqArq     := {}
Private aCampos     := {}
Private cArqTrb
Private cIndice1    := ""
Private lMarcar  	:= .F.
Private aSeek       := {}
Private aFieFilter  := {}
Private cQuery		:= ""
Private cAliasSQL	:= GetNextAlias()
Private oBrowse 	:= Nil
Private cCadastro 	:= "Consulta Recusa de Solicitação de Compras"
Private aParamBox   := {}
Private aRetPer     := ""
Private cAliasSC    := 'TRB'
Private oDlg
Private nPasso      := 0
Private lRet        := .T.
Private _cNomeUs    := cUserName
Private _cCodUs     := __cUserId
Private _DesMot  := ""
Private _cMail      := ""
Private _cAssu      := "Consulta Recusa de Solicitação de Compras " 
Private _cRot       := "ZCOMF042" 
Private nLista := 0
Private aLista := {}

If Select( (cAliasSQL) ) > 0
   (cAliasSQL)->(DbCloseArea())
EndIf

cQuery := " SELECT C1_NUM SC, C1_SOLICIT SOLICIT, C1_EMISSAO EMISSAO,"       + CRLF 
CqUERY += " C1_CODCOMP COMPRADOR, C1_ITEM ITEM, C1_PRODUTO PRODUTO, C1_DESCRI DESCR,"  + CRLF 
cQuery += " UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(C1_XOBSMRE, 2000, 1)) AS OBSERVA, "  + CRLF
cQuery += " C1_XMOTR MOTIVO  "                                               + CRLF
cQuery += " FROM " + RetSQLName('SC1') + " C1"                               + CRLF
cQuery += " WHERE C1.C1_FILIAL = '" + FWxFilial('SC1') + "' "                + CRLF
cQuery += " AND C1.C1_NUM = '"+ SC1->C1_NUM +"'"                               + CRLF
cQuery += " AND C1.C1_APROV = 'R' "                                          + CRLF
cQuery += " AND C1.D_E_L_E_T_  = ' ' "                                       + CRLF
cQuery += " ORDER BY 1, 2 "                                                  + CRLF
cQuery := ChangeQuery(cQuery)

DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSQL, .T., .T. )

DbSelectArea((cAliasSQL))
(cAliasSQL)->(dbGoTop())

If !(cAliasSQL)->(Eof())
    
    cNum     := (cAliasSQL)->SC
    cSolic   := (cAliasSQL)->SOLICIT
    dEmis    := STOD((cAliasSQL)->EMISSAO)
    cComp    := (cAliasSQL)->COMPRADOR
    nLinha   := 1

    While !(cAliasSQL)->(EOF())

        aadd( aLista, {(cAliasSQL)->ITEM, (cAliasSQL)->PRODUTO, (cAliasSQL)->DESCR, (cAliasSQL)->MOTIVO, (cAliasSQL)->OBSERVA})
        
        (cAliasSQL)->(DbSkip()) 

    End

    //Busca Comprador
    SY1->(DBSETORDER(1))
	IF SY1->(DBSEEK(XFILIAL("SY1")+cComp))
	   cNOMECOM := SY1->Y1_NOME
    ELSE
       cNOMECOM := ""
	ENDIF

    //Criando a janela
    DEFINE MSDIALOG oDlgSCt TITLE "Consulta Recusa da Solicitação" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
            
    @ 016,007 SAY "N.Solitação" OF oDlgSCt PIXEL SIZE 031,006
    @ 013,050 MSGET cNum PICTURE PesqPict('SC1','C1_NUM') When .F. OF oDlgSCt PIXEL SIZE 031,006

    @ 016,107 SAY "Solicitante" OF oDlgSCt PIXEL SIZE 036,006
    @ 013,150 MSGET cSolic PICTURE PesqPict('SC1','C1_SOLICIT') When .F. OF oDlgSCt PIXEL SIZE 120,006
        
    @ 036,007 SAY "Emissão" OF oDlgSCt PIXEL SIZE 050,006
    @ 033,050 MSGET dEmis PICTURE PesqPict('SC1','C1_EMISSAO') When .F. OF oDlgSCt PIXEL SIZE 040,006

    @ 036,107 SAY "Comprador" OF oDlgSCt PIXEL SIZE 036,006
    @ 033,150 MSGET cComp    PICTURE PesqPict('SC1','C1_SOLICIT') When .F. OF oDlgSCt PIXEL SIZE 015,006
    @ 033,170 MSGET cNOMECOM PICTURE PesqPict('SC1','C1_SOLICIT') When .F. OF oDlgSCt PIXEL SIZE 100,006


    @ 60,05 LISTBOX oList FIELDS HEADER "Item" ,"Produto", "Descrição", "Motivo Recusa", "Observação" PIXEL SIZE 400,150 OF oDlgSCt
    //@ 60,05 LISTBOX oList FIELDS HEADER "Item" ,"Produto", "Descrição", "Motivo Recusa", "Observação" PIXEL SIZE 500,200 OF oDlgSCt
    oList:SetArray( aLista )
    oList:bLine := {|| { aLista[oList:nAt,1],;
    aLista[oList:nAt,2],;
    aLista[oList:nAt,3],;
    aLista[oList:nAt,4],;
    aLista[oList:nAt,5]}}


    @ 180, 300  BUTTON oBtnSair PROMPT "Sair"      SIZE 60, 014 OF oDlgSCt ACTION (lOk := .F. ,oDlgSCt:End()) PIXEL

    ACTIVATE MSDIALOG oDlgSCt CENTERED

Else
    Alert("Não existe recusa para essa solicitação!.")
EndIf

Return(.T.)    


