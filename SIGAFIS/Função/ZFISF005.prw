#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "totvs.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
#Include "MSMGADD.CH"
/*/{Protheus.doc} ZFISF005
//Alteração Grupo de Tributação - SB1
//Funcionalidade ZFISF005
@author A. Carlos
@since 16/09/20
@version  
@type function
/*/
User function ZFISF005()
Local aSeek        := {}
Private cChave     := "  "
Private aParamBox  := {}
Private aRetPer    := ""
Private aRotina    := MenuDef()
Private oBrowse	   := Nil
Private aColunas   := {}
Private aFieFilter := {}
Private lSuces     := .T.
Private lMarcar    := .F.
Private aArea      := SB1->(GetArea())
Private cAlias     := "SB1"
Private aOldRot    := iif(Type("aRotina")<>"U",aRotina,{})
Public cTabpesq    := "21"
Public cIdiom      := "pt-br"

If U_ZGENUSER( RetCodUsr() ,"ZFISF005" ,.T.)

	aAdd(aParamBox,{ 1, "Informar N.C.M. ", SPACE(10), "@!", "", "SYD","", 50	,.T.})

	If !ParamBox(aParamBox, "Parâmetros", @aRetPer )
		Return Nil
	EndIf
	
	dbSelectArea(cAlias)
	dbSetOrder(1)
    (cAlias)->(dbGoTop())

		oBrowse:=FWMarkBrowse():New()
		oBrowse:SetDescription('Alteração Grupo Tributação')
		oBrowse:SetAlias(cAlias) //Indica o alias da tabela que será utilizada no Browse
		
		oBrowse:SetOnlyFields({'B1_COD','B1_DESC','B1_GRTRIB','B1_POSIPI'})

		oBrowse:AddMarkColumns({|| If(Empty((cAlias)->B1_XMARB), 'LBNO', 'LBOK') }, {|| ZDupColClick() } , {||ZFISF005B(oBrowse:Mark(),lMarcar := !lMarcar )})
		
		oBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
		oBrowse:SetTemporary(.F.) //Indica que o Browse utiliza tabela temporária
		oBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
		oBrowse:oBrowse:SetFilterDefault("B1_POSIPI = aRetper[1]") //Indica o filtro padrão do Browse
		oBrowse:DisableReport() //Desabilita a impressão das informações disponíveis no Browse
		oBrowse:DisableDetails() //Desabilita os detalhes na tela

		oBrowse:SetFields(aColunas) 

		//Ativa o Browse
		oBrowse:Activate()
		oBrowse:oBrowse:Setfocus() //Seta o foco na grade

		(cAlias)->(DbSkip())

    (cAlias)->(DbCloseArea())
	SB1->(RestArea(aArea))

	if Type("aRotina")<>"U"
		aRotina := aOldRot
	EndIf

ENDIF

Return nil



/*/{Protheus.doc} ZFISF005
//Definição do menu - aRotina
@author A. Carlos
@since 16/09/20
@version  
@type function
/*/
Static Function MenuDef()
Local aRotina := {}

	aAdd(aRotina,{'Confirma'  ,'Confirma()' ,0,4,0,NIL})
	aAdd(aRotina,{'Sair'      ,'Encerrar()' ,0,4,0,NIL})
	//AAdd(aRotina,{"&Pesquisar", "U_JAxPesqui()", 0, 3})
	//aAdd(aRotina,{'Desmarcar','U_Desmarc' ,0,4,0,NIL})
   
Return aRotina



/*/{Protheus.doc} ZFISF005
@author A. Carlos
@since 16/09/20
@version 
@type function
/*/
Static Function Confirma()
Local lRet     := .T.
Local lOk      := .F.
Local nConta   := 0
Local PULA     := chr(10)
Local aContent := {}
Local oDlg, cNovncm := space(03)
Local cDescri   := space(30)
Local oButton,oButton2
Local cAliasBRW	:= oBrowse:Alias()
Local _cUser    := Substr(cUserName,1,20)

	DEFINE DIALOG oDlg TITLE "Buscar Grupo de Tributação" FROM 180,180 TO 550,700 PIXEL

	@ 045,045 Say "Grupo: " Font oFont Color CLR_BLUE  Pixel
	@ 045,075 Get cNovncm F3 ('SX521') size 057,010 Object oGet VALID VerGr(cNovncm,@cDescri)
	@ 060,045 Get cDescri size 095,020 Object oGet WHEN .F.

    oGet:bHelp := {||    ShowHelpCpo(    "Grupo de Tributação",;
                {"Grupo de Tributação"+PULA+"Preenchimento obrigatório"},2,;
                {"Busca na Tabela 021 da SX5"},2)}

	cChave   := cNovncm
	aContent := FWGetSX5 ( cTabpesq, cChave, cIdiom )
    
	@ 120,050  BUTTON oButton PROMPT "Confirmar" SIZE 40,15 ; 
	ACTION (lOk := .T. , oDlg:End()) OF oDlg PIXEL 

	@ 120,100  BUTTON oButton2 PROMPT "Voltar" SIZE 40,15 ; 
	ACTION (oDlg:End()) OF oDlg PIXEL 

	ACTIVATE DIALOG oDlg CENTERED

	IF lOk

		IF !Empty(aContent[1,4])
			(cAliasBRW)->(dbGoTop())
			While (cAliasBRW)->(!Eof())
				If (cAliasBRW)->(B1_XMARB) <> "  "
		            nConta++
				Endif
				(cAliasBRW)->(DbSkip())
			EndDo
		
		    If MsgYesNo("[ZFISF005] Deseja mesmo alterar os " + ALLTRIM(STR(nConta)) + " regs. ? ")
				IF nConta > 0
					(cAliasBRW)->(dbGoTop())
					While (cAliasBRW)->(!Eof())
						If (cAliasBRW)->(B1_XMARB) <> "  "
							DbSelectArea("SB1")
							SB1->(DbSetOrder(1))
							If SB1->(dbSeek(xFilial("SB1")+(cAlias)->B1_COD))
								RecLock("SB1",.F.)
								SB1->B1_XLOG := ' conteúdo era: ' + SB1->B1_GRTRIB + ' passa para: ' + cNovncm + ' por ' + _cUser + ' - ' + Dtos(Date()) + ' - ' + Time()
								SB1->B1_GRTRIB := cNovncm
								SB1->B1_XMARB  := '  '
								SB1->(MsUnlock())
							EndIf
						Endif
						(cAliasBRW)->(DbSkip())
					EndDo
				Endif
            else
				(cAliasBRW)->(dbGoTop())
				While (cAliasBRW)->(!Eof())
					If (cAliasBRW)->(B1_XMARB) <> "  "
						DbSelectArea("SB1")
						SB1->(DbSetOrder(1))
						If SB1->(dbSeek(xFilial("SB1")+(cAlias)->B1_COD))
							RecLock("SB1",.F.)
							SB1->B1_XMARB  := '  '
							SB1->(MsUnlock())
						EndIf
					Endif
					(cAliasBRW)->(DbSkip())
				EndDo
		    Endif

		ENDIF
	
	ELSE

	   /*(cAliasBRW)->(dbGoTop())
		While (cAliasBRW)->(!Eof())
			If (cAliasBRW)->(B1_XMARB) <> "  "
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				If SB1->(dbSeek(xFilial("SB1")+(cAlias)->B1_COD))
					RecLock("SB1",.F.)
					SB1->B1_XMARB := '  '
					SB1->(MsUnlock())
				EndIf
			Endif
			(cAliasBRW)->(DbSkip())
		EndDo*/

		//Encerrar()
        lSuces := .F.  
	ENDIF
	
IF lSuces
    MsgInfo("[ ZFISF005 ] Processo realizado com sucesso. ")
EndIF

oBrowse:Refresh(.T.) 

IF lSuces
   Encerrar()
ENDIF

Return(lRet)



/*/{Protheus.doc} Existe
//Verificar grupo de tributação
@author A. Carlos
@since 16/09/20
@version  
@type function
/*/
Static Function VerGr(cNovncm,cDescri)
Local aArea  :=  GetArea()  
Private lResultado := .T.
cChave   := cNovncm

IF Empty(cChave)
   cChave := '035'
ENDIF

aContent := FWGetSX5 ( cTabpesq, cChave, cIdiom )

IF LEN(aContent) > 0
   lResultado := .T.
   cDescri := aContent[1,4]
ELSE
   lResultado := .F.
   //cDescri := 'Informe um Grupo Cadastrado.'
   //@ 060,045 Say cDescri size 095,020 Object oGet 
ENDIF

RestArea( aArea )

Return(lResultado)


/*/{Protheus.doc} ZFISF005
//Desmarcar todas as linhas marcadas
@author A. Carlos
@since 16/09/20
@version  
@type function
/*/
Static Function ZFISF005B(cMarca,lMarcar)
Local aArea  :=  GetArea() 
Local cAliasBRW	:= oBrowse:Alias()

    dbSelectArea(cAliasBRW)
    (cAliasBRW)->( dbGoTop() )
    While !(cAliasBRW)->( Eof() )
        RecLock( cAliasBRW, .F. )
        (cAliasBRW)->B1_XMARB := IIf( lMarcar, cMarca, '  ' )
        MsUnlock()
        (cAliasBRW)->( dbSkip() )
    EndDo
    RestArea( aArea )
    oBrowse:Refresh(.T.)

Return(.T.)



/*/{Protheus.doc} ZDupColClick
//Ação de duplo clique na coluna de marcação
@author A. Carlos
@since 18/09/20
@version  
@type function
/*/
Static Function ZDupColClick()
	Local cAliasBRW	:= oBrowse:Alias()
	Local aAliasBRW	:= (cAliasBRW)->(GetArea())
	DEFAULT lAll	:= .F.

	RecLock( cAliasBRW , .F. )
	(cAliasBRW)->(B1_XMARB)	:= iIf( (cAliasBRW)->(B1_XMARB)="  " , oBrowse:Mark() , "  ")
	(cAliasBRW)->(MsUnlock())

	If !( lAll )
		oBrowse:Refresh()
	EndIf

	RestArea(aAliasBRW)

Return(.T.)



/*/{Protheus.doc} ZFISF005
//Encerramento do Browse
@author A. Carlos
@since 16/09/20
@version  
@type function
/*/
Static Function Encerrar()

	if Type("aRotina")<>"U"
		aRotina := aOldRot
	EndIf

    CloseBrowse()

	SB1->(RestArea(aArea))

Return(Nil)

