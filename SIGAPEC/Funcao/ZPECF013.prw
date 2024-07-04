#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "TBICONN.CH"
#include "rwmake.ch"
#include "TOTVS.ch"
#INCLUDE "DIALOG.CH"
#INCLUDE "FONT.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "AvPrint.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWFILTER.CH"

#define CRLF chr(13) + chr(10)

/*/{Protheus.doc} ZPECF013
@param  	
@author 	CAOA - A.Carlos
@version  	V.03 
@since  	28/12/2021
@return  	NIL
@obs         
@project
@history    Seleciona Picking para faturamento.   
/*/
User Function ZPECF013(_cFilPicking, _cPicking)
Local _lConsultaExt := FWIsInCallStack("U_ZPECF030")  //PEC044

Default _cFilPicking := ""
Default _cPicking	 := ""

    If !_lConsultaExt  //PEC044 DAC 28/06/2023 somnte para consulta
		//colocado controle de usuários DAC 23/05/2022
		_lRet := U_ZGENUSER( RetCodUsr() ,"ZPECF013" ,.T.)	
		If !_lRet
			Return Nil
		EndIf
		//Início - OneGate001 - nova empresa 90 | HMB
		IF !( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
		    RETURN Nil
		ENDIF
		//Fim - OneGate001 - nova empresa 90 | HMB
	Endif
	FWMsgRun( ,{|| TelaUnit(_cFilPicking, _cPicking, _lConsultaExt) } ,"Carregando dados..." ,"Por favor aguarde...")
Return

/*/{Protheus.doc} ZPECF013 - TelaUnit
@param  	
@author 	CAOA - CAOA - A.Carlos
@version  	P12.1.23
@since  	04/01/2022
@return  	NIL
@obs         
@project
@history    Tela de visualização e processamento da montagem de unitizadores    
/*/
Static Function TelaUnit(_cFilPicking, _cPicking, _lConsultaExt)
	Local aCoors 		:= FWGetDialogSize( oMainWnd )
	Local oPanelUp, oFWLayer, oPanelLeft, oRelacVS3 //,oPanelRight , oBrowseLeft, oBrowseRight, oRelacZA5
	//Local _cUsuario		:= AllTrim(SuperGetMV( "CMV_WSR015"  ,,"RG LOG" )) 
    LOCAL nIDBlq := GETMV("CMV_PEC017")
	
	Private cUserMov    := __cUserId
	Private aDadosUp    := {}
	Private aDadosLf    := {}
	Private aColsUnit 	:= {}
	Private _aMensAglu	:= {}
	Private lEditar	    := .T.
	Private cPerg       := "ZPEC013"
    Private _oDlg, oBrowseUp
	Private aFilBrw     := {}
	/*If (cTmpInv)->OBSCON = ' ' .And. nOpc == 3    //PEDIDO SEPARADO
		MsgAlert("Este registro esta finalizado, selecione um registro pendente para geração de Picking!")
		Return
	EndIf 	

	If lJobAtivo .And. nOpc == 3
		MsgAlert("Este botão esta desabilitado porque o processamento via Job esta ativo, " + CRLF +;
				 "solicite ao administrador do sistema a parada do Job para habilitar o processamento" )
		Return
	EndIf*/

	DbSelectArea("SZK")

	Define MsDialog oDlg Title 'Picking e Itens ' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	//-- Cria o conteiner onde serão colocados os browses	
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg, .F., .T. )

	//-- Define Painel Superior
	oFWLayer:AddLine( 'UP', 50, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )
	
	//-- Define Painel inferior
	oFWLayer:AddLine( 'DOWN', 50, .F. )
	oFWLayer:AddCollumn( 'ALL' , 100, .T., 'DOWN' )
	//oFWLayer:AddCollumn( 'RIGHT', 50, .T., 'DOWN' )
	oPanelLeft	:= oFWLayer:GetColPanel( 'ALL' , 'DOWN' )
	//oPanelRight := oFWLayer:GetColPanel( 'RIGHT', 'DOWN' )

	//Criação da pesquisa apresentada no browse
	/*aAdd(aSeek  ,{"Picking"	,{{ ""  ,"C"    ,TamSX3("ZK_XPICKI")[1] ,0  ,"Picking" 	,"@!"   }},1 } )
	aAdd(aSeek  ,{"Nota" 	,{{ ""  ,"C"    ,TamSX3("ZK_NF")[1]     ,0  ,"Nota" 	,"@!"   }},2 } )
	
	aAdd(aFieFilter    ,{"Filial"	,"Filial"	,"C"  ,TamSX3("ZK_FILIAL")[1] ,0 ,"@!" })
	aAdd(aFieFilter    ,{"Picking"  ,"Picking"	,"C"  ,TamSX3("ZK_XPICKI")[1] ,0 ,"@!" })
	aAdd(aFieFilter    ,{"Nota"     ,"Nota"     ,"C"  ,TamSX3("ZK_NF")[1]     ,0 ,"@!" })
	aAdd(aFieFilter    ,{"Serie"  	,"Serie"    ,"C"  ,TamSX3("ZK_SERIE")[1]  ,0 ,"@!" })*/

	oBrowseUp := FWMBrowse():New()
	oBrowseUp:SetOwner( oPanelUp )
	oBrowseUp:SetAlias("SZK")
	oBrowseUp:SetMenuDef("")
	oBrowseUp:SetDescription("Cabeçalho Picking")
	//oBrowseUp:SetFixedBrowse(.T.)
	//Acrescentado status e bloqueio DAC 04/07/2022 conforme solicitação JC

	If SZK->(FieldPos("ZK_STATUS")) > 0 
 		oBrowseUp:AddLegend("SZK->ZK_STATUS=='C'"          												,"RED"    ,"Cancelado")
		oBrowseUp:AddLegend("SZK->ZK_STATUS=='B'"         												,"WHITE"  ,"Bloqueado")
		//GAP002 DAC 28/07/2023
		oBrowseUp:AddLegend("SZK->ZK_STATUS=='D'"         												,"ORANGE" ,"Divergência WIS")
	EndIf
	oBrowseUp:AddLegend("Empty(SZK->ZK_XPICKI)"   	                        							,"GREEN"  ,"Sem Picking")
	oBrowseUp:AddLegend("!Empty(SZK->ZK_NF) .OR. SZK->ZK_STATUS =='F'"   		                     	,"BLACK"  ,"Faturado")
	//GAP002 DAC 28/07/2023
	//oBrowseUp:AddLegend("Empty(SZK->ZK_NF) .AND. !SZK->ZK_STATUS $ 'B_C_F' .AND. !Empty(SZK->ZK_STREG)"	,"YELLOW" ,"A Faturar") 	
	//oBrowseUp:AddLegend("Empty(SZK->ZK_NF) .AND. !SZK->ZK_STATUS $ 'B_C_F' .AND.  Empty(SZK->ZK_STREG)" 	,"BLUE"   ,"Em Separacao") 	
	oBrowseUp:AddLegend("Empty(SZK->ZK_NF) .AND. !SZK->ZK_STATUS $ 'B_C_F_D' .AND. !Empty(SZK->ZK_STREG)"	,"YELLOW" ,"A Faturar") 	
	oBrowseUp:AddLegend("Empty(SZK->ZK_NF) .AND. !SZK->ZK_STATUS $ 'B_C_F_D' .AND.  Empty(SZK->ZK_STREG)" 	,"BLUE"   ,"Em Separacao") 	

	//oBrowseUp:AddLegend("SZK->ZK_OBSCON = 'PEDIDO SEPARADO' .AND. Empty(SZK->ZK_NF) ","YELLOW" ,"A Faturar") 	
	//DAC USUARIO DO RECEBIMENTO RG LOG
	//oBrowseUp:AddLegend("Empty(SZK->ZK_NF) .AND. ALLTRIM(SZK->ZK_USURECP) = '"+_cUsuario+"' ","YELLOW" ,"A Faturar") 	

    If !_lConsultaExt  //PEC044 DAC 28/06/2023 somnte para consulta
		oBrowseUp:AddButton("Faturar"		      , {||EmitDoc(SZK->ZK_XPICKI)})
		//oBrowseUp:AddButton("Pergunte"	          , {||Pergunte(cPerg,.T.)    })
		//oBrowseUp:AddButton("Cancelar"	          , {||Pergunte(cPerg,.T.)    })

		IF !(cUserMov $ nIDBlq)
	   	 	oBrowseUp:AddButton("Danfe"               , {||ZPECF13K()})
			oBrowseUp:AddButton("Manut.Cabecalho"     , {||ZPECF13A(SZK->ZK_XPICKI)})
	    	oBrowseUp:AddButton("Manut. Itens"        , {||ZPECF13C(SZK->ZK_XPICKI)})
	    	oBrowseUp:AddButton("Cancelar Picking"    , {||ZPECF13H()})
	    	oBrowseUp:AddButton("Bloquear Picking" 	  , {||ZPECF13I()})
	    	oBrowseUp:AddButton("Desbloquear Picking" , {||ZPECF13J()})
		Endif
	Endif

	//Caso tenha sido fornecido o numero do picking filtar PEC044 DAC 30/05/2023
	//Adiciona um filtro ao browse
	If _lConsultaExt .and. !Empty(_cPicking)
		oBrowseUp:SetFilterDefault("@"+ZPECF13FIT(_cFilPicking, _cPicking) ) //Exemplo de como inserir um filtro padrão >>> "TR_ST == 'A'"
	Endif

	//oBrowseUp:AddButton("Conferir Orca/tos"   , {||ZPECF13E(SZK->ZK_XPICKI)})  //Divergência
	
	oBrowseUp:AddButton("Fechar"			, { || oDlg:End() })
	//oBrowseUp:SetAmbiente(.T.)
	//oBrowseUp:SetTemporary()
	//oBrowseUp:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
	//oBrowseUp:SetFilterDefault("") //Indica o filtro padrão do Browse
	//oBrowseUp:SetFieldFilter(aFieFilter)
	oBrowseUp:SetProfileID( '1' )
	//oBrowseUp:DisableReport()
	oBrowseUp:DisableDetails()

	/*aAdd(afields    ,{"Filial"    		,"Filial"	     ,"C"  ,010	,0 ,"@!" })
	aAdd(afields    ,{"Picking"    		,"Picking"	     ,"C"  ,010	,0 ,"@!" })
	aAdd(afields    ,{"Sequencia"  		,"Sequencia"	 ,"C"  ,010	,0 ,"@!" })
	aAdd(afields    ,{"Grupo"		    ,"Grupo"	     ,"C"  ,010	,0 ,"@!" })
	aAdd(afields    ,{"Codigo"  		,"Codigo"        ,"C"  ,010	,0 ,"@!" })
	aAdd(afields    ,{"Orcamento"  		,"Orcamento"	 ,"C"  ,010	,0 ,"@!" })
	aAdd(afields    ,{"Quantidde"  		,"Quantidde"	 ,"N"  ,015	,5 ,"@E 9,999,999.99999" })
	aAdd(afields    ,{"Valor_Peca"  	,"Valor_Peca"	 ,"N"  ,015	,5 ,"@E 9,999,999.99999" })
	aAdd(afields    ,{"Valor_Tota"		,"Valor_Tota"	 ,"N"  ,040	,5 ,"@E 9,999,999.99999" })*/

	//oBrowseUp:SetFields(afields)
	
	oBrowseUp:Activate()

	//-- Lado Esquerdo
	oBrowseLeft:= FWMBrowse():New()
	oBrowseLeft:SetOwner( oPanelLeft )
	oBrowseLeft:SetDescription("Itens")
	oBrowseLeft:SetMenuDef( '' )
	If !_lConsultaExt //pec044
		oBrowseLeft:DisableReport()
	Endif	
	oBrowseLeft:DisableDetails()
	oBrowseLeft:SetAlias('VS3')       
	oBrowseLeft:SetProfileID( '2' )
	oBrowseLeft:Activate()
	
	//oBrowseLeft:acolumns[13]:ledit:= lEditar //Habilita a coluna Percentual Desconto como editável
	//oBrowseLeft:acolumns[14]:ledit:= lEditar //Habilita a coluna Desconto como editável
    //oBrowseLeft:acolumns[22]:ledit:= lEditar //Habilita a coluna TES como editável

	//-- Relacionamento entre os Paineis
	oRelacVS3:= FWBrwRelation():New()
	oRelacVS3:AddRelation( oBrowseUp , oBrowseLeft , 	{;
														{"VS3_FILIAL", 'xFilial("VS3")'},;
														{"VS3_XPICKI","ZK_XPICKI"};
														}	)
	oRelacVS3:Activate()

	/*oRelacZA5:= FWBrwRelation():New()
	oRelacZA5:AddRelation( oBrowseLeft, oBrowseRight, 	{;
														{"D0S_FILIAL",'xFilial("D0S")'},;
														{"D0S_IDUNIT","D0R_IDUNIT"};
														}	)
	oRelacZA5:Activate()*/

//oTimer := TTimer():New(8000, {|| aPedidos := MontaQ(2) }, oDlgPeds )
//oTimer:Activate()
	Activate MsDialog oDlg Center
Return

/*/{Protheus.doc} ZPECF13FIT
Retorna Filtro para fwmbrowse  PEC044
@author DAC - Denilso 
@since 30/05/2023 
@version 2.0
/*/
Static Function ZPECF13FIT(_cFilPicking, _cPicking)
Local _cFiltro := ""
	_cFiltro  +=  " ZK_FILIAL = '"+_cFilPicking+"'"			+ CRLF
	_cFiltro  +=  "	AND ZK_XPICKI = '" + _cPicking + "' " 	+ CRLF 
 	_cFiltro  +=  "	AND D_E_L_E_T_ = ' ' " 					+ CRLF
Return _cFiltro


**************************
Static Function ZPECF13K()
**************************

Local aArea		As Array
Local aSF2Area	As Array

aArea		:= GetArea()
aSF2Area	:= SF2->(GetArea())

If !ExistDir("C:\Temp")
   nRet := MakeDir( "C:\Temp" )
   If nRet != 0
      MsgStop( "Não foi possível criar o diretório 'C:\Temp'. Erro: " + cValToChar( FError() ) )
   EndIf
EndIf

If !Empty(Alltrim(SZK->ZK_SERIE)) .And. !Empty(Alltrim(SZK->ZK_NF))
	SF2->(DbSetOrder(1))
	SF2->(DbSeek(xFilial("SF2")+SZK->ZK_NF+SZK->ZK_SERIE))
	Pergunte("NFSIGW",.F.)
	SpedDanfe()
Else
	ApMsgStop("<b>Registro não faturado.</b>", "Impressão Danfe")
EndIf

RestArea(aArea	 )
RestArea(aSF2Area)

Return(.T.)
/*/{Protheus.doc} ZPECF013 - ZPECF13A
@param  	
@author 	CAOA - CAOA - A.Carlos
@version  	P12.1.23
@since  	06/01/2022
@return  	NIL
@obs         
@project
@history    Manutenção de Campos de Cabeçalho de Picking   
/*/
Static Function ZPECF13A(cXPICKI)
Local _oCourierNw	:= TFont():New("Courier New",,,,.F.,,,,.F.,.F.)
Local _bXTPIMPGWhen 
Local _nLin     := 13
Local _nOpcx    := 3 
Local lRet	    := .T.
Local _nRegSZK  := SZK->(Recno())

VS1->(dbSetOrder(11))
VS1->(dbSeek(xFilial("VS1")+cXPICKI))

Begin Sequence
	If !Empty(SZK->ZK_NF)
    	MSGINFO( "Já possui nota fiscal, não pode ser alterado !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		Break
	Endif	

	Private aCombo := {"C=CIF","F=FOB","T=Por Conta Terceiro","R=Por Conta Remetente","D=Por Conta Destinatario","S=Sem Frete"}
	Private cFORPAG  := VS1->VS1_FORPAG//SPACE(03)
	Private cDesFP   := Posicione("SE4",1,xFilial("SE4")+AllTrim(cFORPAG),"E4_DESCRI")
	Private oDesFP
	Private cXTPTRA  := VS1->VS1_XTPTRA//SPACE(03)
	Private cDesTP   := Posicione("VX5",1,xFilial("VX5")+"Z01"+AllTrim(cXTPTRA),"VX5_DESCRI")
	Private oDesTP 
	Private cXTPPAG  := aCombo[aScan(aCombo,{|x| Left(x,1)==VS1->VS1_PGTFRE})] //SPACE(25)
	Private cDesPg   := ""
	Private oDesPg
	Private oCombo
	Private cXPERDES := 0.00
	Private cXMENNOT := SPACE(60)

    dbSelectArea("VS1")
	VS1->(dbSetOrder(11))
	//VS1->(dbSeek(xFilial("VS1")+VS3->VS3_NUMORC))
	If !VS1->(dbSeek(xFilial("VS1")+SZK->ZK_XPICKI))  //procurar direto pelo numero do picking //DAC 24/02/2022
    	MSGINFO( "Não localizado orçamentos para este picking !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		Break
	Endif
	//Verifica se esta na fase para alterações
	If !ZPECF13FAS(VS1->VS1_NUMORC)
		Break
	EndIf

	//NAÕ PRECISA DE WHILE POIS O PICKING É GERADO EM CHAVE COM FORMA DE PGTO TIPO TRANSP DAC  24/02/2024
	//While ( !Eof() .And. VS1->VS1_NUMORC == VS3->VS3_NUMORC )
	cFORPAG  := VS1->VS1_FORPAG 
	cXTPTRA  := VS1->VS1_XTPTRA 
	cXPERDES := VS1->VS1_PERDES 
	cXMENNOT := SZK->ZK_MENNOT	//AllTrim(cXMENNOT)	+" "+AllTrim(VS1->VS1_MENNOT)  // SOMENTE ATUALIZAR AS MSGS DO SZK DAC 24/02/2022
	//VS1->(DbSkip())
	//End 
	//cXMENNOT := SZK->ZK_MENNOT	//AllTrim(cXMENNOT)	+" "+AllTrim(VS1->VS1_MENNOT)  // SOMENTE ATUALIZAR AS MSGS DO SZK DAC 24/02/2022

	//As mensagens das notas serão gravadas na geração do SZK e no registro sequencia 1 DAC 24/02/2022
	//If Len(cXMENNOT) < Len(SZK->ZK_MENNOT)
	//	cXMENNOT += Space(Len(SZK->ZK_MENNOT) - Len(cXMENNOT))
	//Endif

	_bXTPIMPGWhen := { || _nOpcx == 2 .Or. _nOpcx == 3 .Or. _nOpcx == 4 }
    bOK    := {|| nBTOP  := 1,IF(FVAL("bOK"),_oDlg:END(),nBTOP = 0)}
    bSair  := {|| nBTOP  := 0,_oDlg:END()}

    DEFINE MSDIALOG _oDlg TITLE "Manutenção Cabeçalho Picking ---> " + cXPICKI FROM 180,180 TO 490,800 OF oMainWnd PIXEL

	@ _nLin, 13 SAY 'Forma de Pagamento' PIXEL Of _oDlg  
	//@ _nLin, 70 MSGET cFORPAG PICTURE PesqPict("SE4","E4_CODIGO") VALID (cFORPAG) F3 "SE4" WHEN .T. SIZE 35, 08 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
	@ _nLin, 70  MSGET cFORPAG PICTURE PesqPict("SE4","E4_CODIGO") VALID !Empty(cFORPAG).And.xValDesc(cFORPAG,@cDesFP,@oDesFP,1) F3 "SE4" WHEN .T. SIZE 35, 08 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
	@ _nLin, 170 SAY oDesFP VAr cDesFP SIZE 75, 08  Of _oDlg PIXEL FONT _oCourierNw

	_nLin += 20
	@ _nLin, 13 SAY 'Modal' PIXEL Of _oDlg  
	//@ _nLin, 70 MSGET cXTPTRA PICTURE PesqPict("VX5_M5","VX5_CHAVE") VALID (cXTPTRA) F3 "VX5" WHEN .T. SIZE 35, 08 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
	@ _nLin, 70 MSGET cXTPTRA PICTURE PesqPict("VX5_M5","VX5_CHAVE") VALID !Empty(cXTPTRA).And.xValDesc(cXTPTRA,@cDesTP,@oDesTP,2) F3 "VX5_M5" WHEN .T. SIZE 35, 08 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
	@ _nLin, 170 SAY oDesTP VAr cDesTP SIZE 75, 08  Of _oDlg PIXEL FONT _oCourierNw

	_nLin += 20
	@ _nLin, 13 SAY 'Tipo Frete' PIXEL Of _oDlg  

	@ _nLin, 70 MsComboBOX oCombo Var cXTPPAG ITEMS aCombo VALID !Empty(cXTPPAG) SIZE 75, 08 Of _oDlg PIXEL FONT _oCourierNw
	//@ _nLin, 170 SAY oDesTP VAr cDesTP SIZE 75, 08  Of _oDlg PIXEL FONT _oCourierNw

	_nLin += 20
	@ _nLin, 13 SAY 'Perc.Desconto' PIXEL SIZE 40,10 Of _oDlg  
	@ _nLin, 70 MSGET cXPERDES PICTURE PesqPict("VS1","VS1_PERDES") VALID (cXPERDES) SIZE 35, 08 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
	_nLin += 20
	@ _nLin, 13 SAY 'Mens. P/ Nota' PIXEL SIZE 40,10 Of _oDlg  
	@ _nLin, 70 MSGET cXMENNOT PICTURE PesqPict("VS1","VS1_MENNOT") WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw 
	_nLin += 20
	@ _nLin, 70 BMPBUTTON TYPE 1 ACTION (ZPECF13B(cXPICKI), _oDlg:End()) OBJECT oButtOK
    //@ _nLin,140 BMPBUTTON TYPE 2 ACTION TsClsObs(cXPICKI) OBJECT oButtCc
    @ _nLin,140 BMPBUTTON TYPE 2 ACTION _oDlg:End() OBJECT oButtCc
     
    ACTIVATE DIALOG _oDlg CENTERED

End Sequence
SZK->(DbGoto(_nRegSZK))
oBrowseUp:Refresh()
oBrowseLeft:Refresh()
//oDlg:Refresh()
Return(lRet)


/*/{Protheus.doc} ZPECF013 - TsClsObs
@param  	
@author 	CAOA - CAOA - A.Carlos
@version  	P12.1.23
@since  	06/01/2022
@return  	NIL
@obs         
@project
@history    Fechar a Tela de Manutenção de Picking   
/*/
Static Function TsClsObs(cXPICKI)
	_lOpcao := .T.
	Close(_oDlg)
Return Nil


/*/{Protheus.doc} ZPECF013 
@author 	CAOA - CAOA - A.Carlos
@version  	P12.1.23
@since  	06/01/2022
@return  	NIL
@obs         
@project
@history    Gravar campo editável na Manutenção de Picking   
/*/
Static Function ZPECF13B(cXPICKI)
Local lRet 		:= .T.
Local _nPerDesc	:= 0
Local _aArea 		:= GetArea()
Begin Sequence
	dbSelectArea("VS1")
	VS1->(dbSetOrder(11))
	//VS1->(dbSeek(xFilial("VS1")+VS3->VS3_NUMORC))
	//DAC 24/02/2022
	If !VS1->(dbSeek(xFilial("VS1")+SZK->ZK_XPICKI))  //procurar direto pelo numero do picking //DAC 24/02/2022
    	MSGINFO( "Não localizado orçamentos para gravar dados neste picking !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		lRet := .F.
		Break
	Endif
	If Empty(cFORPAG)
    	MSGINFO( "Forma de Pagamento não informada !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		lRet := .F.
		Break
	Endif
	If Empty(cXTPTRA)
    	MSGINFO( "Tipo de Transportes !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		lRet := .F.
		Break
	Endif
	If Empty(cXTPPAG)
    	MSGINFO( "Tipo de Frete !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		lRet := .F.
		Break
	Endif

	//While ( !Eof() .And. VS1->VS1_NUMORC == VS3->VS3_NUMORC )
	While ( !Eof() .And. VS1->VS1_XPICKI == SZK->ZK_XPICKI )
		RecLock("VS1",.f.)
		VS1->VS1_FORPAG  := cFORPAG
		VS1->VS1_XTPTRA  := cXTPTRA
		VS1->VS1_PGTFRE  := cXTPPAG

		//somente executar alteração caso tenha sido informados valores diferentes do ja gravado DAC 03/03/2022
		If VS1->VS1_PERDES <> cXPERDES

			_nPerDesc := VS1->VS1_PERDES
			If !GRVCABITEM(VS1->VS1_NUMORC, cXPERDES)
				RecLock("VS1",.f.)		//não retirar necessário DAC
				VS1->VS1_PERDES := _nPerDesc
				VS1->(MsUnlock())
    			MSGINFO( "Valor de Desconto não aplicato, não foi possivel atualizar itens !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
				lRet := .F.
				Break
			else
				RecLock("VS1",.f.)		//não retirar necessário DAC
				VS1->VS1_PERDES := cXPERDES
				VS1->VS1_DESCON := (VS1->VS1_VTOTNF * cXPERDES) / 100
				VS1->VS1_VTOTNF := VS1->VS1_VTOTNF - ((VS1->VS1_VTOTNF * cXPERDES) / 100)
				VS1->(MsUnlock())
				U_ORCCALFIS(VS1->VS1_NUMORC,.F.)
			Endif
		EndIf
		//não atualiza a msg do SZ1
		//VS1->VS1_MENNOT := AllTrim(VS1->VS1_MENNOT) + " " + AllTrim(cXMENNOT)
		VS1->(MsUnLock())
		VS1->(DbSkip())
	EndDo
/* não atualizar todas as sequencias do szk DAC 23/02/2022
		dbSelectArea("SZK")
		dbSetorder(1)
		SZK->(dbGotop())
        SZK->(dbSeek(xFilial("SZK")+cXPICKI))
		While !Eof() .AND. SZK->ZK_XPICKI = cXPICKI
		    SZK->(RecLock("SZK",.f.))
	    	SZK->ZK_MENNOT := cXMENNOT
		    SZK->(MsUnLock())    
			SZK->(DbSkip())
        End
		VS1->(DbSkip())
	End
*/
	//Atualizar somente szk posicionado DAC 23/02/2022
    SZK->(RecLock("SZK",.f.))
   	SZK->ZK_MENNOT := cXMENNOT
    SZK->(MsUnLock())    
    MSGINFO( "Operação realizada com sucesso!!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
End Sequence	
RestArea(_aArea)
Return ( lRet )


/*/{Protheus.doc} ZPECF013 - GRVCABITEM
@param  	
@author 	CAOA - CAOA - DAC
@version  	P12.1.23
@since  	03/03/2022
@return  	NIL
@obs         
@project
@history   Gravar Item Picking do Cabeçalho   
/*/
Static Function GRVCABITEM(_cNumOrc, _nPDesc)
Local _lRet 		:= .T. 
Local _nTotBruto	:= 0
Local _nValDesc		:= 0

Begin Sequence
	VS3->(DbSetOrder(1))
	If !VS3->(DbSeek(XFilial("VS3")+_cNumOrc))
    	MSGINFO( "Não localizado items para aplicar valores de descontos orçamento "+_cNumOrc+" !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		_lRet := .F.
		Break
	Endif
	Begin Transaction
		While VS3->(!Eof()) .and. VS3->VS3_FILIAL == XFilial("VS3") .and. VS3->VS3_NUMORC == _cNumOrc
			If VS3->VS3_PERDES <> _nPDesc
				If !VS3->(RecLock("VS3",.f.))
    				MSGINFO( "Não foi possivel bloquear item com código "+VS3->VS3_CODITE+" para aplicar valores de descontos orçamento "+_cNumOrc+" não serão atualizados os valores de descontos neste orçamento !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
           			Disarmtransaction()
					_lRet := .F.
					Exit
				EndIf
				//VS3->VS3_PERDES  := _nPDesc
				If _nPDesc == 0
					_nTotBruto 		:= (VS3->VS3_VALPEC * VS3->VS3_QTDITE) 
					_nValDesc		:= 0
					VS3->VS3_VALDES := 0
					VS3->VS3_PERDES := 0
				Else
					_nTotBruto 		:= (VS3->VS3_VALPEC * VS3->VS3_QTDITE) 
					_nValDesc		:= (_nTotBruto * _nPDesc) / 100
					VS3->VS3_PERDES := _nPDesc
					VS3->VS3_VALDES := _nValDesc
				Endif	
				VS3->VS3_VALTOT := _nTotBruto - _nValDesc
				VS3->(MsUnLock())
			EndIf
			VS3->(DbSkip())
		EndDo	
	End Transaction
End Sequence
Return _lRet


/*/{Protheus.doc} ZPECF013 - ZPECF13C
@param  	
@author 	CAOA - CAOA - A.Carlos
@version  	P12.1.23
@since  	06/01/2022
@return  	NIL
@obs         
@project
@history    Manutenção de Itens de Picking   
/*/
Static Function ZPECF13C(cXPICKI)
Local _oCourierNw	:= TFont():New("Courier New",,,,.F.,,,,.F.,.F.)
Local _nLin     	:= 13
Local _nOpcx    	:= 3
//Local _cTipo        := 2
Local lRet	    	:= .T.
Local _lEditQtde	:= .T.
//Local _cCodOper
Local _bXTPIMPGWhen 

Begin Sequence
	If !Empty(SZK->ZK_NF)
    	MSGINFO( "Já possui nota fiscal, não pode ser alterado!!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		Break
	Endif	
	//PEC027 - Ajuste Manutenção de Itens caso a operação não esteja preenchida chamar a funcionalidade para tentar calcular DAC 25/07/2022
	//Reposicionar VS1
	If VS3->VS3_NUMORC <> VS1->VS1_NUMORC
		VS1->(DbSetOrder(1))	
		If !VS1->(DbSeek(XFILIAL("VS1")+VS3->VS3_NUMORC))
  			MSGINFO( "Não localizado Orçamento para este Item !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
			Break
		Endif
	EndIf	

	//liberado sem a quantidade pois ja esta no faturamento
	If Empty(SZK->ZK_NF) .AND. !Empty(SZK->ZK_XPICKI) .AND. !Empty(SZK->ZK_STREG)  
		_lEditQtde := .F.
	Endif
	//Controlar permissão para alterar quantidade
	//DAC 24/05/2022 controlar a alteração da quantidade a mesma se possivel alterar será realizada divergência
	If !U_ZGENUSER( RetCodUsr() ,"ZPECF13CQT" ,.T.)
		_lEditQtde := .F.
	EndIf
	//neste caso solicitado por JC para uma liberação especial
	If !_lEditQtde .and. U_ZGENUSER( RetCodUsr() ,"ZPECF13CPK" ,.T.)
		_lEditQtde := .T.
	EndIf

	//Verifica se esta na fase para alterações
	If !ZPECF13FAS(VS3->VS3_NUMORC)
		Break
	EndIf
	Private cCodIte := SPACE(23)
    Private cDesc   := SPACE(40)
	Private cTES    := SPACE(03)
	Private cSeq    := SPACE(04)
	Private cCODOPE := SPACE(02)
	Private cRegFis := SPACE(01)
	Private nOrig   := 0.00
	Private cPERDES := 0.00
	Private cDESCON := 0.00
	//Private _cApaga	:= "N"

    cCodIte := VS3->VS3_CODITEM
	cDesc   := Posicione( "SB1", 1, xFilial("SB1") + cCodIte, "B1_DESC" )
	cSeq    := VS3->VS3_SEQUEN
	cTES    := VS3->VS3_CODTES 
	cPERDES := VS3->VS3_PERDES
	cDESCON := VS3->VS3_VALDES 
	nOrig   := 0 //VS3->VS3_QTDITE passara a ser a quantidade de divergencia DAC 09/05/2022 
	cCODOPE	:= VS3->VS3_OPER
	cRegFis := VS3->VS3_XREGFI

	//PEC027 - Ajuste Manutenção de Itens caso a operação não esteja preenchida chamar a funcionalidade para tentar calcular DAC 25/07/2022
	//Localizar a Operação
	/* Conforme Zé quer que retorne o que contém no VS3 o usuário irá alterar o tipo da operação DAC 26/08/2022 
	_cCodOper := U_zTpOper( VS1->VS1_CLIFAT, VS1->VS1_LOJA, VS1->VS1_XTPPED )	
	//Validar se a mesma esta igual a operação no VS3
	If AllTrim(cCODOPE) <> AllTrim(_cCodOper)
		cCODOPE	:= _cCodOper
	EndIF
	*/
	_bXTPIMPGWhen := { || _nOpcx == 2 .Or. _nOpcx == 3 .Or. _nOpcx == 4 }
    bOK    := {|| nBTOP  := 1,IF(FVAL("bOK"),_oDlg:END(),nBTOP = 0)}
    bSair  := {|| nBTOP  := 0,_oDlg:END()}

    DEFINE MSDIALOG _oDlg TITLE "Manutenção Itens Picking ---> " + cXPICKI FROM 180,180 TO 450,800 OF oMainWnd PIXEL
    @ _nLin, 13 SAY 'Cod. Operacao' PIXEL Of _oDlg
	@ _nLin, 110 SAY 'Regra Fiscal' PIXEL Of _oDlg
	@ _nLin, 190 SAY 'Código TES'    PIXEL Of _oDlg  
	//@ _nLin, 70 MSGET cFORPAG PICTURE PesqPict("SE4","E4_CODIGO") VALID (cFORPAG) F3 "SE4" WHEN .T. SIZE 35, 08 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
	@ _nLin, 70 MSGET cCODOPE PICTURE PesqPict("VS3","VS3_OPER") VALID (VerTES(.T.))  SIZE 35, 08 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw Valid ExistCpo("SX5", + "DJ" + cCODOPE) F3 "DJ"
	//_nLin += 20	
	//@ _nLin, 40 SAY 'Código TES' PIXEL Of _oDlg 
    //A TES muda de acordo com o código do produto DAC 25/04/2022
    //cTes := MaTesInt(_cTipo,cCODOPE,VS1->VS1_CLIFAT,VS1->VS1_LOJA,"C",cCodIte,)
	@ _nLin, 150 MSGET cRegFis PICTURE PesqPict("VS3","VS3_XREGFI") VALID !Empty(Upper(cRegFis)) .and. (Len(X3Combo("VS3_XREGFI",Upper(cRegFis))) > 0)  F3 "VX5_RF" WHEN .T. SIZE 35, 08 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
 	@ _nLin, 230 MSGET cTES PICTURE PesqPict("SF4","F4_CODIGO") VALID (Empty(cTES) .or. VerTES()) F3 "SF4" WHEN .T. SIZE 35, 08 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
	_nLin += 20
	@ _nLin, 13 SAY 'Pec.Desconto' PIXEL Of _oDlg  
	//@ _nLin, 70 MSGET cPERDES PICTURE PesqPict("VS3","VS3_PERDES") VALID (cPERDES)  WHEN .T. SIZE 35, 08 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
	@ _nLin, 70 MSGET cPERDES PICTURE PesqPict("VS3","VS3_PERDES") VALID VerDesc()  WHEN .T. SIZE 50, 08 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
	_nLin += 20
	@ _nLin, 13 SAY 'Val. Desconto' PIXEL SIZE 40,10 Of _oDlg  
	//@ _nLin, 70 MSGET cDESCON PICTURE PesqPict("VS3","VS3_VALDES") VALID (cDESCON) SIZE 35, 08 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
	@ _nLin, 70 MSGET cDESCON PICTURE PesqPict("VS3","VS3_VALDES") VALID VerDesc( .F.) SIZE 70, 10 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
	_nLin += 20
	@ _nLin, 13 SAY 'Cód. Item' PIXEL Of _oDlg  
	@ _nLin, 70 SAY cCodIte PIXEL FONT _oCourierNw
	@ _nLin, 140 SAY cDesc  PIXEL FONT _oCourierNw 
	_nLin += 20
	If _lEditQtde
		//JC pediu para retirar e voltar como o anterior pois estava correto a diferença é que ira gravar a quantidade total e não o residuo após retirar DAC 04/05/2022
		//@ _nLin, 13 SAY 'Retirar item Orc. S/N ?' PIXEL Of _oDlg  
		//@ _nLin, 70 MSGET _cApaga PICTURE "@!"  Valid _cApaga $ "S_N" SIZE 20, 10  Of _oDlg PIXEL FONT _oCourierNw
		// Conforme JC deverá apagar o item e não mais alterar a quantidade DAC 03/05/2022
		@ _nLin, 13 SAY 'Qtde Divergente' PIXEL Of _oDlg  
		//Não permitir valor zerado quando esta na gravação esta validado diferente de zero DAC 18/03/2022
		//@ _nLin, 70 MSGET nOrig PICTURE PesqPict("VS3","VS3_QTDITE")   SIZE 70, 10 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
		@ _nLin, 70 MSGET nOrig PICTURE PesqPict("VS3","VS3_QTDITE")  Valid nOrig >= 0 SIZE 70, 10 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
		_nLin += 20
	EndIf		
    @ _nLin, 70 BMPBUTTON TYPE 1 ACTION (ZPECF13D(cXPICKI, _lEditQtde), _oDlg:End()) OBJECT oButtOK
    @ _nLin,140 BMPBUTTON TYPE 2 ACTION (_oDlg:End()) OBJECT oButtCc
   //@ _nLin, 100 BUTTON oBtn1 PROMPT 'Sair' ACTION ( _oDlg:End() ) SIZE 40, 013 OF oDlg PIXEL
    ACTIVATE DIALOG _oDlg CENTERED

End Sequence
oDlg:Refresh()
oBrowseLeft:Refresh()
Return(lRet)

//DAC 18/03/2022
//Verificar se existe a TES
Static Function VerTES(_lOper) 
Local _lRet		:= .T.

Default _lOper 	:= .F.

Begin Sequence
	If _lOper  //localizar a TES pela operação
		cTES := MaTesInt(2,cCODOPE, VS1->VS1_CLIFAT, VS1->VS1_LOJA,"C", VS3->VS3_CODITE,/*"VS3_CODTES"*/)
		Break
	Endif
	SF4->(DbSetOrder(1))
	If !SF4->(DbSeek(XFilial("SF4")+cTES))
    	MSGINFO( "TES não cadastrada !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		_lRet := .F.
		Break
	EndIf
End Sequence
Return _lRet

//achar valor de desconto
Static Function VerDesc( _lPerc )
Local _lRet     := .T.
Local _nValDesc := 0  
Local _nValPerc := 0

Default _lPerc	:= .T.

Begin Sequence
	//Validações para não permitir descontos maiores DAC 18/03/2022
	If cPERDES >= 100
    	MSGINFO( "Percentual não pode ser igual ou superior a 100 % !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		_lRet := .F.
		Break	
	EndIf
	If cDESCON >= (VS3->VS3_VALPEC * VS3->VS3_QTDITE)
    	MSGINFO( "Valor de desconto não pode ser igual ou superior ao valor total liquido da peça !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		_lRet := .F.
		Break
	EndIf

	//If 	cDESCON == 0 
	//	Break
	//EndIf	
	_nValDesc := Round((VS3->VS3_VALPEC * VS3->VS3_QTDITE) * (cPERDES/100),2)  //M->VS3_VALDES
	//caso seja informado o percentual retornar o valor
	If _lPerc  
		cDESCON := _nValDesc
		Break
	Endif
	If _nValDesc <> cDESCON
		If !MsgYesNo( "Valor de Desconto "+AllTrim(STR(_nValDesc))+" em desacordo com o percentual "+AllTrim(STR(cPERDES))+" deseja alterar percentual ? " )
			_lRet := .F.
			Break
		Endif
		_nValPerc := round( cDESCON / (VS3->VS3_VALPEC * VS3->VS3_QTDITE) *100,2)
		cPERDES		:= _nValPerc	
	Endif
End Sequence
Return _lRet

/*/{Protheus.doc} ZPECF013 - ZPECF13D
@param  	
@author 	CAOA - CAOA - A.Carlos
@version  	P12.1.23
@since  	04/01/2022
@return  	NIL
@obs         
@project
@history   Gravar Item Picking    
/*/
Static Function ZPECF13D(cZK_XPICKI, _lEditQtde)
Local _lRet       		:= .T.
Local _lProcessaDiverg 	:= .F.
Local _nQtdeDif			:= 0
Local _nQtdeItem		:= 0	
Local _nRegVS1 			:= 0
Local _cNumOrc			:= VS3->VS3_NUMORC
Local _nRegSZK			:= SZK->(Recno())
Local _aArea			:= GetArea()
Local _aVS3Reg			:= {}
Local _aMens			:= {}
Local _aResDel			:= {}
Local _cObs				:= ""
Local _nRegvs3			
Local _cCodProd
Local _cDocto
Local _nPos

Default _lEditQtde 		:= .T.

Begin Sequence
	//Verifica se existiu alteração
	_cCodProd := VS3->VS3_CODITE
	_nRegvs3  := VS3->(Recno())
	If VS3->VS3_PERDES  == cPERDES .and. VS3->VS3_CODTES  == cTES .and. VS3->VS3_VALDES  == cDESCON .and. ;
		VS3->VS3_OPER 	== cCODOPE .and. VS3->VS3_XREGFI == Upper(cRegFis) .and. nOrig == 0
		Aadd(_aMens, "Não ocorrerão alterações ! ")
		//VS3->VS3_QTDITE == nOrig   
		Break
	Endif

	If nOrig > VS3->VS3_QTDITE
		Aadd(_aMens, "Operação não realizada. Qtde a maior !!! ")
		_lRet := .F.
		Break
	EndIf

	If AllTrim(_cNumOrc) <> AllTrim(VS1->VS1_NUMORC)
		VS1->(DbSetOrder(1))	
		If !VS1->(DbSeek(XFILIAL("VS1"+_cNumOrc)))
			Aadd(_aMens, "Não localizado o orçamento "+AllTrim(_cNumOrc)+", não será atualizado divergencia comunicar o ADM do Sistema !!! ")
			_lRet := .F.
			Break
		Endif
	EndIf	
	_nRegVS1 := VS1->(Recno())
	//caso alterou quantidade devo também confirmar para divergência
	If _lEditQtde .And. nOrig > 0  //.and. nOrig <> VS3->VS3_QTDITE  não utilizar mais diferente pois norig agora é divergencia DAC 13/05/2022
	//If _lEditQtde .And. _cApaga == "S"  //nOrig <> VS3->VS3_QTDITE
	    //If !MsgYesNo("Será gerado uma divergência por alteração na quantidade, Deseja continuar com a alteração ? ")
	    If !MsgYesNo("Será gerado uma divergência por alteração na quantidade, Deseja continuar com a exclusão deste item ? ")
			Aadd(_aMens, "Não confirmado processamento ! ")
			Break
		Endif
		//ira apagar deixar a quantidade igual		
		// alterado conforme JC ira deletar linha não alterar quantidade DAC 03/05/2022
		//_nQtdeDif 	:= VS3->VS3_QTDITE

		//verificar o valor que tera que ser movimentado no SD3
		//Conforme alinhamento com JC imputar a quantidade divergente direto DAC 06/05/2022
		_nQtdeDif 			:= nOrig
		/*
		If nOrig <= 0  //Caso tenha zerado a quantidade é que retirou todos as quantidades
			_nQtdeDif 		:= VS3->VS3_QTDITE
		Else
			_nQtdeDif		:= VS3->VS3_QTDITE - nOrig 
		EndIf 
		*/
		_nQtdeItem			:= VS3->VS3_QTDITE
		_lProcessaDiverg 	:= .T.
	Endif		
	//Inicia processo de gravação das alterações
	Begin Transaction
		VS3->(RecLock("VS3",.f.))
		//Incluído Sittrib conforme observado por Zé não esta alterando DAC 26/08/2022
		If VS3->VS3_OPER <> cCODOPE .Or. VS3->VS3_CODTES  <> cTES  
			_cSitTrib := U_XFUNSITT(cTES, VS3->VS3_CODITE, VS3->VS3_GRUITE)
		Else
			_cSitTrib := VS3->VS3_SITTRI 
		EndIF
		//atualiza 
		VS3->VS3_OPER		:= cCODOPE
		VS3->VS3_CODTES  	:= cTES
		VS3->VS3_SITTRI  	:= _cSitTrib
		VS3->VS3_PERDES  	:= cPERDES
		VS3->VS3_XREGFI		:= Upper(cRegFis)
		If cPERDES == 0
			VS3->VS3_VALDES := 0
		Else	
			VS3->VS3_VALDES := cDESCON
		EndIf	
   	 	//Alterara a quantidade e processara uma divergencia
		//Deixar este trecho pois pode ser somente alteação sem divergencia, pois com divergencia ira clonar e apagar registro total DAC 05/05/2022
		If _lProcessaDiverg .and. _lRet	
			//If nOrig <> 0 .and. nOrig <> VS3->VS3_QTDITE
			//caso divergencia retirar a reserva do mesmo
			//If VS3->VS3_RESERV == "1"
			
			//DAC - 06/05/2022
			//Tenho que testar se esta reservado caso nã não posso retirar a reserva
			//Necessário fazer esta consistencia devido problemas no Sistema não esta atualizando campo VS3_RESERV = 1 falado com JC sobre o problema 
			//para abrir chamado pois mesmo no padrão não esta atualizando campo VS3_RESERV
			If  !Empty(VS3->VS3_DOCSDB) 
				_aResDel 	:= Aclone({})
				_aVS3Reg	:= Aclone({})
				_cDocto		:= ""
				Private aHeaderP    := {} // Variavel ultilizada na OX001RESITE
				aAdd(_aResDel,VS3->VS3_SEQUEN)
				AAdd(_aVS3Reg,VS3->(Recno()))
				if Len(_aResDel) > 0
					//retira as reservas dos itens
					//Alterado para utilizar reserva CAOA - DAC 16/08/2022
 					Private _aReservaCAOA 	:= {_cNumOrc,.F.,_aVS3Reg}	// Variavel utilizada no PE OX001RES
					_cDocto := OX001RESITE(_cNumOrc,.F.,_aResDel )
					//_cDocto := U_XRESCAOAPEC(_cNumOrc, .F., _aResDel)
					if Empty(_cDocto) .or. _cDocto == "NA"
						Aadd(_aMens, "Não foi possivel retirar a reserva do item alterado !!!")
						DisarmTransaction()
						_lRet := .F.
					Endif
					//Garanto que o documento tenha sido retirado da reserva
					If _lRet .and. !Empty(VS3->VS3_DOCSDB)
						VS3->(RecLock("VS3",.F.))
						VS3->VS3_DOCSDB	:= ""
						VS3->VS3_RESERV := "0"
						VS3->(MsUnlock())
					Endif
				EndIf
				Aadd(_aMens, "Retirada reserva "+_cDocto+" do item "+AllTrim(_cCodProd)+" orçamento "+_cNumOrc+" devido a Divergencia na qtde de "+AllTrim(STR(_nQtdeDif))+" qtde total do item "+AllTrim(STR(_nQtdeItem)))
			Else
				Aadd(_aMens, "Não existe reserva do item "+AllTrim(_cCodProd)+" orçamento "+_cNumOrc+" para o processo de Divergencia na qtde de "+AllTrim(STR(_nQtdeDif))+" qtde total do item "+AllTrim(STR(_nQtdeItem)+" não retirada reserva !"))
			Endif	
			/* não gravar o residuo deverá gravar divergencia com q quantidade total conforme informado por JC DAC 04/05/2022 
			//Gravo direto a quantidade original
			If _lRet //.and. VS3->(RecLock("VS3",.F.))
				VS3->VS3_QTDITE := nOrig
				VS3->VS3_QTDPED := nOrig
				VS3->VS3_QTDINI := nOrig
			EndIf
			*/
		EndIf
		//quando coloca percentual de desconto tem que aplicar nos valores dos demais campos do VS3 DAC 24/022022
		If _lRet .and. VS3->VS3_QTDITE > 0  //somente  totalizar quando for maior que zero
			VS3->VS3_VALTOT := (VS3->VS3_VALPEC * VS3->VS3_QTDITE) - VS3->VS3_VALDES //VS3->VS3_VALPEC * VS3->VS3_QTDITE
		ElseIf _lRet
			VS3->VS3_VALTOT := 0
		EndIf
		VS3->(MsUnlock()) 

		//Executar o processo de divergencia caso exista
		If _lRet .and. _lProcessaDiverg
			_lRet := ZPECF13G(_cNumOrc, _nQtdeItem, _nQtdeDif, _nRegVS1, _nRegvs3, cZK_XPICKI, @_aMens)
			If !_lRet
				Aadd(_aMens, "Problemas na clonagem e ou transferencias  do item "+AllTrim(_cCodProd)+" devido a Divergencia ! ")
				Disarmtransaction()
			Else
				Aadd(_aMens, "Realizada clonagem e transferencias  do item "+AllTrim(_cCodProd)+" devido a Divergencia ! ")
			EndIf	
		EndIf
		//Calcular impostos pois foi alterado DAC 18/03/2022
	End Transaction	
	If _lRet
		//AJUSTAR NUMERAÇÃO DOS ITENS DAC 05/05/2022
		If _lProcessaDiverg
			AtuSeqVS3(_cNumOrc)
			//Verificar se existe orçamento ainda para o picking
			ZPECF13GCancela(@_aMens, cZK_XPICKI)
		EndIf	
		U_ORCCALFIS(_cNumOrc,.F.)
		MSGINFO( "Operação realizada com sucesso!!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
	EndIf
End Sequence
//Gravar dados da observação
_cObs := ""
_cObs += "[ZPECF013_MANUTENCAO ITENS DIVERGENCIA "+DtoC(Date())+" as "+SubsTr(Time(),1,5)+"]"+ CRLF
_cObs += "Ocorrencias Processo divergência "+If(_lRet,"realizado com sucesso","com inconsistencia no processamento")+" !" + CRLF
For _nPos := 1 To Len(_aMens)
	_cObs += " - "+_aMens[_nPos]+ CRLF
Next

If _nRegVS1 > 0
	VS1->(DbGoto(_nRegVS1))
	//Caso tenha gerado BackOrder gravo dados no orçamento do back 
	VS1->(RecLock("VS1",.F.))
	VS1->VS1_OBSAGL		:= Upper(_cObs) + CRLF  + AllTrim(VS1->VS1_OBSAGL)
	VS1->(MsUnlock())
Endif
If !Empty(_cObs) 
	MSGINFO( Upper(_cObs), "[ZPECF013_MANUTENCAO] - Atenção" )
Endif
Conout("ZPECF13D - "+_cObs)
SZK->(DbGotop())
SZK->(DbGoto(_nRegSZK))
RestArea(_aArea)
Return _lRet

//Responsavel por ajustar a sequencia do orçamento que passou por divergencia
Static Function AtuSeqVS3(_cNumOrc)
Local _lRet 	:= .T.
Local _cNumSeq

Begin Sequence
	_cNumSeq := StrZero(0,Len(VS3->VS3_SEQUEN))
	VS3->(DbGoTop())
	If !VS3->(MsSeek(XFilial("VS3")+_cNumOrc))
		_lRet := .F.
		Break
	Endif		
	While VS3->(!Eof()) .and. VS3->VS3_FILIAL == XFilial("VS3") .and. VS3->VS3_NUMORC == _cNumOrc
		_cNumSeq 	:= Soma1(_cNumSeq)
		If ! RecLock("VS3",.F.)
			_lRet := .F.
			Aadd(_aMensAglu,"Não foi possivel ajustar a sequencia dos itens, não conseguiu bloquear registro !")
			Exit
		Endif
		VS3->VS3_SEQUEN := _cNumSeq
		VS3->(MsUnlock())
		VS3->(DbSkip())
	EndDo
End Sequence
Return _lRet


/*/{Protheus.doc} ZPECF013 - ZPECF13E
@param  	
@author 	CAOA - CAOA - A.Carlos
@version  	P12.1.23
@since  	06/01/2022
@return  	NIL
@obs        Esta funcionalidade não sera utilizada a mesma ja é tratada quando da alteração de quantidade na alteração de itens DAC 24/05/2022 
@project
@history    Manutenção de Itens de Picking (Divergência)   
/*/
/*
Static Function ZPECF13E(cXPICKI)
Local _oCourierNw	:= TFont():New("Courier New",,,,.F.,,,,.F.,.F.)
Local _bXTPIMPGWhen 
Local _nLin     := 13
Local _nOpcx    := 3 
Local lRet	    := .T.

Begin Sequence
	If !Empty(SZK->ZK_NF)
    	MSGINFO( "Já possui nota fiscal, não pode ser alterado!!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		Break
	Endif	

	Private cCodIte := SPACE(23)
    Private cDesc   := SPACE(40)
	Private cGrupo  := SPACE(04)
	Private nConf   := 0.00
	Private nOrig   := 0.00

    cCodIte := VS3->VS3_CODITEM
	cDesc   := Posicione( "SB1", 1, xFilial("SB1") + cCodIte, "B1_DESC" )
	cGrupo  := VS3->VS3_GRUITE
	nConf   := VS3->VS3_QTDITE
	nOrig   := VS3->VS3_QTDITE 
	
	_bXTPIMPGWhen := { || _nOpcx == 2 .Or. _nOpcx == 3 .Or. _nOpcx == 4 }
    bOK    := {|| nBTOP  := 1,IF(FVAL("bOK"),_oDlg:END(),nBTOP = 0)}
    bSair  := {|| nBTOP  := 0,_oDlg:END()}

    DEFINE MSDIALOG _oDlg TITLE "Conferência Peças Picking ---> " + cXPICKI FROM 180,180 TO 450,800 OF oMainWnd PIXEL

	@ _nLin, 13 SAY 'Grupo' PIXEL Of _oDlg  
	@ _nLin, 70 SAY cGrupo  PIXEL FONT _oCourierNw
	_nLin += 20
	@ _nLin, 13 SAY 'Cód. Item' PIXEL Of _oDlg  
	@ _nLin, 70 SAY cCodIte PIXEL FONT _oCourierNw
	_nLin += 20
	@ _nLin, 13 SAY 'Descrição' PIXEL Of _oDlg 
	@ _nLin, 70 SAY cDesc PIXEL FONT _oCourierNw 
	_nLin += 20
	@ _nLin, 13 SAY 'Qtde Conferida' PIXEL Of _oDlg  
	@ _nLin, 70 MSGET nConf PICTURE PesqPict("VS3","VS3_QTDITE") VALID (nConf) WHEN .T. SIZE 35, 08 WHEN Eval( _bXTPIMPGWhen ) Of _oDlg PIXEL FONT _oCourierNw
	_nLin += 20
	@ _nLin, 13 SAY 'Qtde Original' PIXEL Of _oDlg  
	@ _nLin, 70 SAY nOrig PIXEL FONT _oCourierNw
	_nLin += 20	
    @ _nLin, 70 BMPBUTTON TYPE 1 ACTION (ZPECF13F(cXPICKI), _oDlg:End()) OBJECT oButtOK
    @ _nLin,140 BMPBUTTON TYPE 2 ACTION (_oDlg:End()) OBJECT oButtCc
   //@ _nLin, 100 BUTTON oBtn1 PROMPT 'Sair' ACTION ( _oDlg:End() ) SIZE 40, 013 OF oDlg PIXEL
    ACTIVATE DIALOG _oDlg CENTERED

End Sequence
oDlg:Refresh()
oBrowseLeft:Refresh()
Return(lRet)
*/

/*/{Protheus.doc} ZPECF013 - ZPECF13G
@param  	
@author 	CAOA - CAOA - A.Carlos
@version  	P12.1.23
@since  	06/01/2022
@return  	NIL
@obs        aAdd(_aSeqVS3,VS3->VS3_SEQUEN)     
@project
@history    Buscar dados na VM6 (Divergência)   
/*/
Static Function ZPECF13G(_cNumOrc, _nQtdeItem, _nQtdeDif, _nRegVS1, _nRegvs3, cZK_XPICKI, _aMens)
Local _lRet 	  	:= .T.
Local _lZera      	:= .T.
Local _aBackOrder 	:= {} 
//Local _cArmReseSite	:= AllTrim(GETMV("MV_RESITE"))    //'61'
Local _cArmDiverg  	:= AllTrim(GETMV("MV_DIVITE"))    //'65'
Local _cArmaPad		:= "01"
Local _cNumOrcNovo	:= ""
Local _cGrupo		
Local _cCodItem 
Local _cObs	


/*inicialmente deixar ir pelo padrão da função
Local _aCpoVazio	:= {"VS1_XAGLU",;
						"VS1_XDTAGL",;
						"VS1_XHSAGL",;
						"VS1_XUSUGL",;
						"VS1_OBSAGL",;
						"VS1_XPICKI",;
						"VS1_XUSUPI",;
						"VS1_XINTEG",;
						"VS1_XDTEPI",;
						"VS3_XITSUB",;
						"VS3_XTPSUB",;
						"VS3_XDTSUB",;
						"VS3_XHRSUB",;
						"VS3_XAGLU",;
						"VS3_XDTAGL",;
						"VS3_XHSAGL",;
						"VS3_XUSUGL",;
						"VS3_XPICKI",;
						"VS3_XQTDIT",;
						"VS1_VTOTNF";
						}	
*/
Begin Sequence
	//Montar BackOrder 
	/* RETIRADO CONFORME PASSADO POR JC SERÁ RETIRADO A LINHA INTEIRA DO ITEM ESTE CASO ERA COMO PARCIAL DAC 03/04/2022

	If _nQtdeItem == 0
		_lZera := .T.  //Apagara o VS3
	Else
		_lZera := .F.		
	Endif
	_aMensAglu	:= Aclone({})
	_aBackOrder	:= Aclone({})
    Aadd(_aMensAglu,"BO originario do orçamento "+_cNumOrc+", gerado por alteração de quantidade "+AllTrim(Str(_nQtdeDif))+" ref. Produto "+AllTrim(_cCodItem)+" <ZPECF13G>")
    Aadd(_aBackOrder,{_nRegvs3 , _cCodItem, _nQtdeDif, _aMensAglu[Len(_aMensAglu)], })
	_lRet := U_XOFUNCLO(_cNumOrc, _cGrupo , _cCodItem, _nQtdeDif, _lZera, , _aBackOrder[1])  //Criar BO
	If !_lRet
    	MSGINFO( "Não foi possivel clonar orçamento BackOrder para a divergengia !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		Break
	EndIf
	*/
	//Montar novo orçamento com o item que gerou divergencia atualizando o reziduoconforme alinhado com Zé
	//caso a quantidade foi atingida não é necessário
	VS3->(DbGoto(_nRegvs3))
	VS1->(DbGoto(_nRegVS1))
 	_cGrupo		:= VS3->VS3_GRUITE
 	_cCodItem 	:= VS3->VS3_CODITE
	_cArmaPad   := VS3->VS3_LOCAL  //Devido a utilização do armazem de Franco da Rocha DAC 02/02/2023
 	//Alterado DAC 21/06/2022 movimentação para o armazém 61 tem que acontecer antes da clonagem pois não existira registro quando da clonagem
	If _nQtdeDif > 0 
		_lRet := U_XMOVA261(_cNumOrc, _cCodItem, _cArmaPad, _cArmDiverg, _nQtdeDif ,_nRegvs3,"ZPECF13G")//****************************************
	EndIf
	If !_lRet
		_cObs := "Não foi possivel transfererir orçamento para armazem "+_cArmDiverg+" ref. item : "+_cCodItem+" qtde "+AllTrim(STR(_nQtdeDif))+" !!! "
   		MSGINFO( _cObs, "[ZPECF013_MANUTENCAO] - Atenção" )
		Break
	Endif
	_cObs := "Realizada transferência para armazém "+_cArmDiverg+" ref. item : "+AllTrim(_cCodItem)+" qtde "+AllTrim(STR(_nQtdeDif))
	Aadd(_aMens, _cObs  )
	VS3->(DbGoto(_nRegvs3))
	VS1->(DbGoto(_nRegVS1))
	//Verificar se é o ultimo registro do VS1, caso seja não será preciso gerar Backorder ---DAC
	If  ZPECF013Ultimo(_cNumOrc, _cCodItem) 
		//deixo a quantidade total é esta que será atualizada a divergência tera que ser atualizada a qual foi transferida para o armazem de divergencia
		VS1->(RecLock("VS1",.F.))
		VS1->VS1_XBO	:= "S"
		VS1->VS1_XPICKI	:= ""
		VS1->VS1_XDTEPI	:= CtoD(Space(08))
		VS1->VS1_STATUS := "0"
		_cObs := "Orcamento "+_cNumOrc+" alterado para BO devido possuir somente um item, no processo de divergengia ZPECF013, Picking "+cZK_XPICKI+" foi retirado do orçamento !"
		Aadd(_aMens, _cObs )
		VS1->(MsUnlock())
		//Atualizar VS3
		//Apagar Carregamento
		If !U_XAPAVM5VM6Carregamento(_cNumOrc)	
			_cObs := "Não foi possivel atualizar carregamento no Protheus (VM5), ref. ao Picking "+cZK_XPICKI+" conforme processo Divergência!"
			Aadd(_aMens, _cObs )
		Else
			_cObs := "Carregamento no Protheus (VM5) apagado, ref. ao Picking "+cZK_XPICKI+" conforme processo Divergência"
			Aadd(_aMens, _cObs )
		EndIf	
		VS3->(RecLock("VS3",.F.))
		VS3->VS3_XPICKI		:= " "  
		VS3->(MsUnlock())
		_cObs := "Retirado numeração Picking "+cZK_XPICKI+" conforme processo Divergência"
		Aadd(_aMens, _cObs )

	//caso possua outros itens criar Backorder 
	ElseIf _nQtdeItem > 0
		_lZera 		:= .T.  //Apagara o VS3
		_aMensAglu	:= Aclone({})
		_aBackOrder	:= Aclone({})
    	Aadd(_aMensAglu,"BO originário do orcamento "+_cNumOrc+", gerado por alteração de quantidade "+AllTrim(Str(_nQtdeItem))+ " ref. ao item ,"+AllTrim(_cCodItem)+" criação novo orçamento  devido a divergencia. <ZPECF13G>")
    	Aadd(_aBackOrder,{	_nRegvs3 ,;
		 					_cCodItem,;
							_nQtdeItem,;
							_aMensAglu[Len(_aMensAglu)],;
							.T. ,;			//lXbo
							_lZera })		//apaga o registro original
		_lRet := U_XOFUNCLO(_cNumOrc, _cGrupo , _cCodItem, _nQtdeItem , _lZera, /*_aCpoVazio*/, _aBackOrder, @_cNumOrcNovo)  //Criar BO
		If !_lRet
			_cObs := "Não foi possivel clonar orçamento BackOrder para a divergencia !!! "
    		MSGINFO( _cObs, "[ZPECF013_MANUTENCAO] - Atenção" )
			Break
		Else 
			_cObs := "Gerado orçamento BackOrder "+_cNumOrcNovo+" devido processo de Divergencia"
		EndIf
		Aadd(_aMens, _cObs )
		VS1->(DbGoto(_nRegVS1))
	Endif 
	//VS3->(DbGoto(_nRegvs3))  não reposicionar este item ja foi apagado
	//retornar para o armazem principal a quantidade total
	//Validar pois quando esta tirando a reserva automaticamente voltaria para o 01 DAC 09/05/2022
	//If _lRet 
	//	_lRet := U_XMOVA261(_cNumOrc, _cCodItem, _cArmReseSite, _cArmaPad, _nQtdeItem , _nRegvs3)
	//EndIf
	//incluir movimento da divergencia no armazem de divergencia
	
	/* Movimentação acontecer antes da clonagem DAC 21/06/2022
	If _lRet .and. _nQtdeDif > 0 
		_lRet := U_XMOVA261(_cNumOrcNoco, _cCodItem, _cArmaPad, _cArmDiverg, _nQtdeDif , _nRegvs3)
	EndIf
	*/
End Sequence		
Return _lRet



//Reaponsável por cancelar o picking, pois ja não existem iten no orçamento referente ao picking
Static Function ZPECF13GCancela(_aMens, cZK_XPICKI)
Local _lRet 		:= .T.
Local _nRegSZK		:= SZK->(Recno())
Local _cAliasPesq 	:= GetNextAlias()
Local _lBloqueia	:= .F.
Begin Sequence
	BeginSql Alias _cAliasPesq
		SELECT 	ISNULL(SZK.R_E_C_N_O_,0) NREGSZK		
				, (	SELECT 	COUNT(VS1.VS1_XPICKI)
					FROM %table:VS1% VS1
					WHERE 	VS1.VS1_FILIAL  	= %XFilial:VS1%
						AND VS1.VS1_XPICKI  	= %Exp:cZK_XPICKI%
		  				AND VS1.%notDel% ) AS NCOUNTVS1	
		FROM %table:SZK% SZK			
		WHERE 	SZK.ZK_FILIAL  	= %XFilial:SZK%
			AND SZK.ZK_XPICKI  	= %Exp:cZK_XPICKI%
  			AND SZK.%notDel% 	
	EndSql      
	//Caso não localize picking e ou
	If (_cAliasPesq)->(Eof()) 
		_cObs := "Não loclizado Picking "+cZK_XPICKI+" conforme movimentações divergência, Verificar com ADM Sistemas ! "
		Aadd(_aMens, _cObs )
		Break
	Endif	
	//caso enconttrou o orçamento com picking não cancelar o picking
	If (_cAliasPesq)->NCOUNTVS1 > 0
		_lBloqueia := .T.
	Endif	
	//tenho que colocar no while pois pode ter mais de um SZK
	While (_cAliasPesq)->(!Eof()) 
		SZK->(DbGoto((_cAliasPesq)->NREGSZK))
		SZK->(RecLock("SZK",.F.))
		//Caso o picking ainda possua itens devo bloquear para posterior verificação
		If _lBloqueia
			/* Não utilizar bloqueio conforme informações passada pelo JC 06/07/2022
			//Bloqueia devido divergência
			If SZK->(FieldPos("ZK_STATUS")) > 0
				SZK->ZK_STATUS := "B"
				_cObs := "Picking "+cZK_XPICKI+" bloqueado devido a manutenção Divergência"
				Aadd(_aMens, _cObs )
			Endif
			*/
		Else
			//Caso não tenha mais orçamentos
			If !SZK->(FieldPos("ZK_STATUS")) > 0
				_cObs := "Campo de Status ainda não criado, não será informado Cancelamento Pickint,  ref picking "+cZK_XPICKI+" conforme movimentações divergência ! "
				Aadd(_aMens, _cObs )
			Else
				SZK->ZK_STATUS 	:= "C"
				_cObs := "Atualizado o Status para cancelamento, ref picking "+cZK_XPICKI+" conforme movimentações divergência !"
				Aadd(_aMens, _cObs )
			EndIf	
		EndIf
		SZK->(MsUnlock())
		(_cAliasPesq)->(DbSkip())
	EndDo
End Sequence
SZK->(DbGoto(_nRegSZK))
Return _lRet

//Verificar se é o ultimo registro do SZ3
Static Function ZPECF013Ultimo(_cNumOrc, _cCodProd)
Local _cAliasPesq 	:= GetNextAlias()
Local _lRet 		:= .F.
BeginSql Alias _cAliasPesq
	SELECT 	VS3.VS3_NUMORC
	FROM %table:VS3% VS3
	WHERE 	VS3.VS3_FILIAL  	= %XFilial:VS3%
		AND VS3.VS3_NUMORC  	= %Exp:_cNumOrc%
		AND VS3.VS3_CODITE 	   <> %Exp:_cCodProd% 
	  	AND VS3.%notDel%		  
EndSql      
//Caso tenha outros itens 
If (_cAliasPesq)->(Eof()) 
	_lRet := .T.
EndIf
Return _lRet


/* exemplo de retorno
If lContinua

    conout("Exemplo de estorno de movimentação multipla baseado na inclusão do movimentação multipla anterior")

    lMsErroAuto := .F.
    for _nPos := 1 to len(aLista) step 2
    
        //-- Preenchimento dos campos
        aAuto := {}
        aadd(aAuto,{"D3_DOC", cDocumen, Nil})
        aadd(aAuto,{"D3_COD", aLista[_nPos], Nil})
        
        DbSelectArea("SD3")
        DbSetOrder(2)
        DbSeek(xFilial("SD3")+cDocumen+aLista[_nPos])
    
        //-- Teste de Estorno
        nOpcAuto := 6 // Estornar
        MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)
        
        If lMsErroAuto
            MostraErro()
        Else
            conout("Estorno de movimentação multipla efetuada com sucesso")
        EndIf

    Next nX
    conout("Finalizado a estorno de movimentação multipla")
EndIf

*/

/*/{Protheus.doc} ZPECF013 - EmitDoc
@param  	
@author 	CAOA - CAOA - A.Carlos
@version  	P12.1.23
@since  	04/01/2022
@return  	NIL
@obs         
@project
@history   	Emissão de NF agrupada    
/*/
Static Function EmitDoc(cZK_XPICKI)
Local _cCliente 	:= " "
Local _cLoja    	:= " "
//Local _cQuery   	:= " "
Local _cQuerup  	:= " "
//Local _cQuerp   	:= " "
Local _cDoc     	:= " "
Local _cSerie   	:= " "
Local _cTipPag		:= " "
Local _cPedido		:= " "

//Local cSeqSZK   := " "
Local _aIntCab  	:= {}
Local _aIntIte  	:= {}
Local _aTotais  	:= {}
Local _aPesos   	:= {}
//Local aOrcs     := {}
Local nCntFor   	:= 0 
Local nValpec   	:= 0
Local nPesol    	:= 0
Local nPesob    	:= 0
Local nPesos    	:= 0
Local cAliasVEC 	:= GetNextAlias()
Local cAliasVS3 	:= GetNextAlias()
Local _cAliasPesq 	:= GetNextAlias()
Local _cAliasNF		:= GetNextAlias()

Local _cStatus		:= "F"
Local _nRegSZK		:= SZK->(Recno())
Local _cUsuario		:= AllTrim(SuperGetMV( "CMV_WSR015"  ,,"RG LOG" )) 
Local _cChave   	:= "ZPEC013FAT"
Local _lControla	:= SuperGetMV( "CMV_PEC023"  ,,.T. )   //Parâmetro para indicar se controlara o bloqueio de faturamento por outro usuario
Local _cMarca   	:= ""
Local _aRegVS1
Local _nPos
Local _nTentativas
Local _cMens
Local _cLike		:= "PEDIDO: "+cZK_XPICKI
Local _cDtEpi		:= " "


//Private TRBNF   //:= GetNextAlias()
Private aHeaderP  		:= {}
Private nImprRoman 		:= 0
Private _aVarVS3		:= {}
Private aOrcs			:= {}
Private _lPrcZPECF013 	:= .F.   //indica que processaraa fatura caso de um cancelamento na tela inicial não tem como saber a informação de processado sera colocada no PE OX004APV
/*
//Verifica se existe o paramentro 2 da pergunta 
If ( SX1->( DbSeek( PadR(cPerg , Len(SX1->X1_GRUPO) ) + "02" ) ) )
	Pergunte(cPerg,.f.)
	nImprRoman := MV_PAR02
EndIf

//
CriaSX1()
//

Pergunte(cPerg,.T.) 
*/
Begin Sequence

	If SZK->ZK_STATUS == "C"
   		MSGINFO( "Picking Cancelado !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		_lControla := .F.  //para não retirar controle ainda não acessou o mesmo
		Break
	Endif	

	If SZK->ZK_STATUS == "F"
   		MSGINFO( "Já possui indicação de nota fiscal, não pode ser alterado !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		_lControla := .F.  //para não retirar controle ainda não acessou o mesmo
		Break
	Endif	

	If SZK->ZK_STATUS == "B"
   		MSGINFO( "Picking Bloqueado !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		_lControla := .F.  //para não retirar controle ainda não acessou o mesmo
		Break
	Endif	
	//GAP002 DAC 28/03/2023
	If SZK->ZK_STATUS == "D"
   		MSGINFO( "Picking com Divergência WIS !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		_lControla := .F.  //para não retirar controle ainda não acessou o mesmo
		Break
	Endif	

	If !Empty(SZK->ZK_NF)
   		MSGINFO( "Já possui nota fiscal, não pode ser alterado !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		_lControla := .F.  //para não retirar controle ainda não acessou o mesmo
		Break
	Endif	

	If !Empty(SZK->ZK_NF) 
   		MSGINFO( "Picking ja possui Nota Fical !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		_lControla := .F.  //para não retirar controle ainda não acessou o mesmo
		Break
	Endif	

	If Empty(SZK->ZK_STREG) .or. AllTrim(SZK->ZK_USURECP) <> _cUsuario
   		MSGINFO( "Ainda não foi realizada a Separação pela Logistica, não podendo ser faturado !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		_lControla := .F.  //para não retirar controle ainda não acessou o mesmo
		Break
	Endif

	aAdd(_aIntCab, 	{"NUMERO"        , "C" , 60 , "@!"               }) // Número  ORÇAMENTO
	aAdd(_aIntCab, 	{"TIPO"          , "C" , 60 , "@!"               }) // Tipo          "
	aAdd(_aIntCab, 	{"DATA ABERTURA" , "D" , 50 , "@D"               }) // Data Abertura
	aAdd(_aIntCab, 	{"VALOR TOTAL"   , "N" , 55 , "@E 999,999,999.99"}) // Valor Total
	aAdd(_aTotais,	{"TOTAL GERAL",0,0})       // TOTAL GERAL
	aAdd(_aTotais,	{"TOTAL SELECIONADO",0,0}) // TOTAL SELECIONADO

	/* Alterado para não ocorrer erros quando mais de um usuário DAC 01/06/2022
		
		If (Select("TRBNF") <> 0 )
			dbSelectArea("TRBNF")
			dbCloseArea()
		Endif

		//Mostrar marca DAC 01/06/2022
		_cQuery := " SELECT VS1_CLIFAT,VS1_LOJA,VS1_NCLIFT,VS1_NUMORC,VS1_TIPORC,VS1_DATORC"
		_cQuery += " FROM "+RetSQLName("VS1")+" VS1 "
		_cQuery += "    WHERE VS1.VS1_FILIAL='"+xFilial("VS1")+"' "
		_cQuery += "          AND VS1.VS1_XPICKI = '" + cZK_XPICKI + "'"
		_cQuery += "          AND VS1.VS1_TIPORC = '1'  "
		//_cQuery += "          AND VS1.VS1_STATUS = 'F'  "
		_cQuery += "          AND VS1.D_E_L_E_T_ <> '*' "
		//_cQuery += "          AND VS1.VS1_CLIFAT = '" + MV_PAR01 + "'"
		//_cQuery += "          AND VS1.VS1_LOJA   = '" + MV_PAR02 + "'"
		_cQuery += "          AND VS1.VS1_STATUS = '" + _cStatus + "'"  //eXite status para faturamento DAC 17/02/2022  
		_cQuery += "          AND VS1.VS1_NUMNFI = ' '  "

		_cQuery := ChangeQuery(_cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"TRBNF",.T.,.T.)
		//DAC 19/12/2022 se não encontrou nada
		If TRBNF->(Eof())
			MsgInfo("Não localizado orçamentos com Picking "+cZK_XPICKI+" com status para faturar !","Atenção") 
			return Nil
		EndIf

		aAdd(_aPesos,{"PESO LIQUIDO",0,0})                     
		aAdd(_aPesos,{"PESO BRUTO  ",0,0})                     
		aAdd(_aPesos,{"PESO CUBADO ",0,0})

		DBSelectArea("TRBNF")
		DBGoTop()

		while !(TRBNF->(eof()))
			nValpec := 0
			//cSequen := Val(VS3->VS3_SEQUEN)      //STRZERO(SZK->(SZK_SEQREG),3)
			//cSeqSZK := STR(cSequen)+".00"
			VS3->(dbSetOrder(1))
			If VS3->(dbSeek(xFilial("VS3")+TRBNF->(VS1_NUMORC)))   //+cSequen
				Do While (VS3->(!EOF()) .AND. VS3->VS3_NUMORC = TRBNF->(VS1_NUMORC)) 
					nValpec += VS3->VS3_VALPEC
					//SKZ->(dbSetOrder(1))     //Filial+Sequencia registro
					//SKZ->(dbGotop())
					//If SKZ->(dbSeek(xFilial("SKZ")+VS3->VS3_XPICKI+cSeqSZK))   
					//nPesol := SKZ->SKZ_PLIQUI
					//nPesob := SKZ->SKZ_PBRUTO
					//nPesos := SKZ->SKZ_PESOC
					//SKZ->(dbSkip())
					//ENDIF
					VS3->(dbSkip())
				ENDDO
			ENDIF

			aAdd(	_aIntIte,{;
					TRBNF->(VS1_NUMORC),;
					TRBNF->(VS1_TIPORC),;
					stod(TRBNF->(VS1_DATORC)),;
					STR(nValpec) })      //TRBNF->(VS1_VTOTNF)
			_aTotais[1,2] ++
			_aTotais[1,3] = STR(nValpec)
			_aPesos[1,3] += nPesol
			_aPesos[2,3] +=	nPesob
			_aPesos[3,3] +=	nPesos

			//implementado marca para controlar faturamento caso esteja faturando esta marca não permitir que outro usuário fature DAC 01/06/2022
			If !Empty(TRBNF->VS1_XMARCA)
				_cMarca := TRBNF->VS1_XMARCA
			EndIF	
			TRBNF->(dbSkip())
		END
	*/
	BeginSql Alias _cAliasPesq
		SELECT 	VS1_CLIFAT,VS1_LOJA,VS1_NCLIFT,VS1_NUMORC,VS1_TIPORC,VS1_DATORC, VS1_XMARCA
  		FROM %table:VS1% VS1
   		WHERE 	VS1.VS1_FILIAL  	= %XFilial:VS1%
			AND VS1.VS1_XPICKI  	= %Exp:cZK_XPICKI%
			AND VS1.VS1_TIPORC 		= '1' 
			AND VS1.VS1_STATUS  	= %Exp:_cStatus%
			AND VS1.VS1_NUMNFI		= ' '
		  	AND VS1.%notDel%		  
	EndSql      
	If (_cAliasPesq)->(Eof()) 
		MsgInfo("Não localizado orçamentos com Picking "+cZK_XPICKI+" com status para faturar !","Atenção") 
		_lControla := .F.  //para não retirar controle ainda não acessou o mesmo
		Break
	EndIf	
	aAdd(_aPesos,{"PESO LIQUIDO",0,0})                     
	aAdd(_aPesos,{"PESO BRUTO  ",0,0})                     
	aAdd(_aPesos,{"PESO CUBADO ",0,0})

	While (_cAliasPesq)->(!Eof())
    	nValpec 	:= 0
		VS3->(dbSetOrder(1))
		If VS3->(dbSeek(xFilial("VS3")+(_cAliasPesq)->VS1_NUMORC))   //+cSequen
       	 	Do While (VS3->(!EOF()) .AND. VS3->VS3_NUMORC == (_cAliasPesq)->VS1_NUMORC)
	        	nValpec += VS3->VS3_VALPEC

	        	VS3->(dbSkip())
			EndDo
		EndIf

		aAdd(	_aIntIte,{;
	         	(_cAliasPesq)->VS1_NUMORC,;
	         	(_cAliasPesq)->VS1_TIPORC,;
	            StoD((_cAliasPesq)->VS1_DATORC),;
	            STR(nValpec) })      

 		_aTotais[1,2] 	++
		_aTotais[1,3] 	:= STR(nValpec)
    	_aPesos[1,3] 	+= nPesol
		_aPesos[2,3] 	+=	nPesob
		_aPesos[3,3] 	+=	nPesos

		//implementado marca para controlar faturamento caso esteja faturando esta marca não permitir que outro usuário fature DAC 01/06/2022
		If !Empty((_cAliasPesq)->VS1_XMARCA)
			_cMarca := (_cAliasPesq)->VS1_XMARCA
		EndIF	
   		(_cAliasPesq)->(dbSkip())
	EnDDo

	//implementado marca para controlar faturamento caso esteja faturando esta marca não permitir que outro usuário fature DAC 01/06/2022
	//Garantir que o processamento seja unico
	If _lControla

		If !LockByName(_cChave+_cMarca,.T.,.T.)  

			_lControla := .F.
			
			For _nTentativas := 1 To 10000
				
				MsAguarde({|| Sleep(3000) }, "Faturamento.", "Aguarde... Seu faturamento em breve será concluido.")	
				
				If LockByName(_cChave+_cMarca,.T.,.T.)
					_lControla := .T.
					Exit
				EndIf
			Next

			If !_lControla 
				MsgInfo("Não foi possivel realizar o faturamento. Inicie o processo de faturamento novamente ! Faturamente em uso por outro usuário.","Atenção") 
				Break
			EndIf

		EndIf

	EndIf	
		
	For nCntFor := 1 to Len(_aIntIte)
		aAdd(aOrcs,_aIntIte[nCntFor,1])
	Next

	if Len(aOrcs) <= 0
		MsgInfo("Nenhum orçamentos selecionado para agrupar","Atenção") 
		Break
	EndIf 

	_aVarVS3 := Aclone(aOrcs)  //guardando dados esta processando somente um orçamento apesar de mandar mais de um DAC 17/02/2022
	nVerParFat := 2
	
	//Atualiza TES Inteligente
	if !(U_ZPECREGFI(cZK_XPICKI)) //cZK_XPICKI _cPedido
		if !MsgYesNo("Erro na atualização da TES INTELIGENTE no Picking: "+cZK_XPICKI+" Deseja Faturar assim mesmo?")
			lRet = .F.
			Break
		EndIf
	EndIf

	//Bloqueio de Faturamento duplicado
	_cDtEpi := VS1->VS1_XDTEPI
	BeginSql Alias _cAliasNF
		SELECT DISTINCT	F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, D2_PEDIDO 
  		FROM %table:SD2% SD2
		INNER JOIN %table:SF2% SF2
			ON SF2.%notDel%
			AND SF2.F2_FILIAL = SD2.D2_FILIAL
			AND SF2.F2_EMISSAO >= %exp:_cDtEpi%
			AND SF2.F2_MENNOTA LIKE %exp:_cLike%
		WHERE SD2.%notDel%	
			AND SD2.D2_FILIAL  	= %XFilial:SD2%
		  	AND SD2.D2_DOC = SF2.F2_DOC
			AND SD2.D2_SERIE = SF2.F2_SERIE	  
	EndSql

	If !Empty((_cAliasNF)->F2_DOC)
		MsgInfo("Já existe NF "+(_cAliasNF)->F2_DOC+" Serie: "+(_cAliasNF)->F2_SERIE+" emitida para o Picking "+cZK_XPICKI+" !","Atenção") 
		_cDoc     	:= (_cAliasNF)->F2_DOC
        _cSerie   	:= (_cAliasNF)->F2_SERIE
		_cCliente 	:= (_cAliasNF)->F2_CLIENTE
        _cLoja    	:= (_cAliasNF)->F2_LOJA
		_cTipPag	:= VS1->VS1_FORPAG
		_cPedido	:= (_cAliasNF)->D2_PEDIDO
		_lTransf	:= .T.
		_lReserva   := .T.

		//For Next da desreserva 
		For nCntFor := 1 to Len(aOrcs)
			//retirar reserva 
			If _lReserva
				aResDel		:= {}
				_aVS3Reg	:= {}
				VS3->(DbsetOrder(1))
				If VS3->(MsSeek(XFilial("VS3")+aOrcs[nCntFor]))
					While VS3->(!Eof()) .and.  VS3->VS3_FILIAL == XFilial("VS3") .and. VS3->VS3_NUMORC == aOrcs[nCntFor]
						If !Empty(VS3->VS3_DOCSDB) //VS3->VS3_RESERV == "1"
							aAdd(aResDel,VS3->VS3_SEQUEN)
							AAdd(_aVS3Reg, VS3->(Recno()))
						EndIf	
						VS3->(DbSkip())
					EndDo
				Endif	
				//retirar a reserva
				If Len(aResDel) > 0
					Private _aReservaCAOA := {aOrcs[nCntFor],.F.,_aVS3Reg}	// Variavel utilizada no PE OX001RES
					_cDocto := OX001RESITE(aOrcs[nCntFor], .F., aResDel)
					//Alterado para utilizar reserva CAOA - DAC 16/08/2022
					//_cDocto := U_XRESCAOAPEC(_cNumOrc, .F., aResDel)
					If Empty(_cDocto) .or. _cDocto == "NA"
						Msginfo("Não foi localizado reservas para retirar !")
						_lRet := .F. 
						Break
					Else
						//Msginfo("Reserva retirada com o numero do docto "+_cDocto+" !")
						//Fazer transferencia Padrão
						If _lTransf
							//Reverte Fase do Orçamento
							If !VS1->(OXI001REVF(aOrcs[nCntFor], "X" ))
								Msginfo( "Não foi possivel reverter Status do orçamento !")
								_lRet := .F.
								Break
							Else
								//Msginfo("Realizado Transferência para reversão do orçamento !")
							EndIf
						EndIf	
					EndIf
				Else
					Msginfo("Não existe reservas para retirar de acordo com VS3_DOCSDB !")
				EndIf
			Endif
		Next
		_lPrcZPECF013 := .T.
	Else
		OFIXX004("VS1",3,aOrcs) 
	Endif
	//indica que processaraa fatura caso de um cancelamento na tela inicial não tem como saber a informação de processado sera colocada no PE OX004APV
	//DAC 20/02/2022
	If !_lPrcZPECF013
		MsgInfo("Processo Cancelado !","Atenção") 
		Break
	EndIf
	lAchou := .f.
	//DAC 16/02/2022
	//Verifico se por algum problema não alterou os orçamentos enviados estava 
	//faturando somente um orçamento os demais não faturava e retornava aorcs somente com o faturado

	If Len(aOrcs) <> Len(_aVarVS3)
		aOrcs := Aclone(_aVarVS3)
	Endif	
	_aRegVS1 := {}
	For nCntFor := 1 to Len(aOrcs)
		dbSelectArea("VS1")
		VS1->(dbSetOrder(1))
		VS1->(dbSeek(xFilial("VS1")+aOrcs[nCntFor]))
		If VS1->VS1_STATUS == "X" .and. Empty(_cDoc)  // Orcamento Faturado, como as informações se repetem somente pego uma vez    
			//Gravacao do Doc de Saida       
   	     	_cDoc     	:= VS1->VS1_NUMNFI
        	_cSerie   	:= VS1->VS1_SERNFI
			_cCliente 	:= VS1->VS1_CLIFAT
        	_cLoja    	:= VS1->VS1_LOJA
			_cTipPag	:= VS1->VS1_FORPAG
			_cPedido	:= VS1->VS1_NUMPED
		EndIf
		Aadd(_aRegVS1,VS1->(Recno()))
	Next  //interrompendo aqui pois como esta com problema de não processar multiplos orçamentos não ira ver todos somente achara em um orçamento DAC 17/02/2022
	//Caso o nr do documento esteja em branco não conseguiu faturar por algum erro
	If Empty(_cDoc)
		MsgInfo("Não existe numero de documento gerado para o(s) Orçamento(s) !","Atenção") 
		Break
	EndIf

	For _nPos := 1 To Len(_aRegVS1)
		VS1->(DbGoto(_aRegVS1[_nPos])) //_nPos	
		_cNumOrc	:= VS1->VS1_NUMORC
		_cMens		:= ""
			//dbSelectArea("SM0")
		VS1->(RecLock("VS1",.F.))
		VS1->VS1_OBSAGL		:= Upper(_cMens) + CRLF + AllTrim(VS1->VS1_OBSAGL)
		SM0->(dbSetOrder(1))

		If SM0->(dbSeek(cEmpAnt + VS1->VS1_FILIAL))  //FWSM0Util():setSM0PositionBycFilAnt()
			VS1->VS1_XCGCEM := AllTrim(SM0->M0_CGC)
			VS1->VS1_DATALT := Date()
			VS1->VS1_XHRALT := Time()
		EndIf
		//VS1->VS1_STATUS := "X"
		//VS1->VS1_FORPAG := _cTipPag // Gravar o VS1_FORPAG em todos os Orcamentos
		VS1->VS1_NUMPED := _cPedido
		VS1->VS1_NUMNFI := _cDoc
		VS1->VS1_SERNFI := _cSerie
		if VS1->(FieldPos("VS1_STARES")) > 0 
			VS1->VS1_STARES := "3"
		Endif
		_cMens := "Orçamento Faturado com fatura nr. " +_cDoc+ " Serie " +_cSerie+ " em " +DtoC(date()) + " as " + Time() + CRLF
		VS1->VS1_OBSAGL		:= Upper(_cMens) + CRLF + AllTrim(VS1->VS1_OBSAGL)
		//VS1->VS1_STARES 	:= U_XRCAOVS3(_cNumOrc)  //Retorna o Status
		VS1->(MsUnLock()) 

		if !lAchou
			If Select(cAliasVEC) <> 0
				(cAliasVEC)->(DbCloseArea())
			Endif  
			cQuery := "SELECT VEC.R_E_C_N_O_ VECRECNO "
			cQuery += "FROM "
			cQuery += RetSqlName( "VEC" ) + " VEC "
			cQuery += "WHERE "
			cQuery += "VEC.VEC_FILIAL='"+ xFilial("VEC")+ "' AND VEC.VEC_NUMNFI = '"+_cDoc+"' AND VEC.VEC_SERNFI = '"+VS1->VS1_SERNFI+"' AND "
			cQuery += "VEC.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVEC, .T., .T. )
			Do While ( cAliasVEC )->( !Eof() )
				VEC->(DBGoto(( cAliasVEC )->(VECRECNO)))
				VEC->(RecLock("VEC",.T.))
				VEC->VEC_NUMORC := " "
				VEC->(MsUnLock())
				lAchou := .t.
				( cAliasVEC )->(dbSkip())
			Enddo
		Endif

		If Select(cAliasVS3) <> 0
			(cAliasVS3)->(DbCloseArea())
		Endif  

		cQuery := "SELECT VS3.VS3_GRUITE , VS3.VS3_CODITE , VS3.VS3_QTDITE , VS3.VS3_VALTOT, VS3.R_E_C_N_O_ NREGVS3 "
		cQuery += "FROM "
		cQuery += RetSqlName( "VS3" ) + " VS3 "
		cQuery += "WHERE "
		cQuery += "VS3.VS3_FILIAL='"+ xFilial("VS3")+ "' AND VS3.VS3_NUMORC = '"+_cNumOrc+"' AND "
		cQuery += "VS3.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVS3, .T., .T. )
		Do While ( cAliasVS3 )->( !Eof() )
			cQuery := "SELECT VEC.R_E_C_N_O_ VECRECNO "
			cQuery += "FROM "
			cQuery += RetSqlName( "VEC" ) + " VEC "
			cQuery += "WHERE "
			cQuery += "VEC.VEC_FILIAL='"+ xFilial("VEC")+ "' AND VEC.VEC_NUMNFI = '"+VS1->VS1_NUMNFI+"' AND VEC.VEC_SERNFI = '"+VS1->VS1_SERNFI+"' AND "
			cQuery += "VEC.VEC_GRUITE = '"+( cAliasVS3 )->VS3_GRUITE+"' AND VEC.VEC_CODITE = '"+( cAliasVS3 )->VS3_CODITE+"' AND VEC.VEC_QTDITE = "+Alltrim(str(( cAliasVS3 )->VS3_QTDITE))+" AND "
			cQuery += "VEC.VEC_VALVDA = "+Alltrim(str(( cAliasVS3 )->VS3_VALTOT))+" AND VEC.VEC_NUMORC = ' ' AND "
			cQuery += "VEC.D_E_L_E_T_=' '"
			nRecno := FM_SQL(cQuery)
		
			If nRecno > 0
				VEC->(DBGoto(nRecno))     
				VEC->(RecLock("VEC",.T.))
				VEC->VEC_NUMORC := VS1->VS1_NUMORC
				VEC->(MsUnLock())
			Endif
			//implementado para gravar informações sobre reservas DAC 23/08/2022
			VS3->(DbGoto(( cAliasVS3 )->NREGVS3))
			VS3->(RecLock("VS3",.F.))
			VS3->VS3_RESERV := "0"
			VS3->VS3_QTDRES	:= 0
			//não limpar
			//VS3->VS3_DOCSDB
			VS3->(MsUnlock())
			( cAliasVS3 )->(dbSkip())
		Enddo

		dbSelectArea("VS1")
		OX001CEV("F",VS1->VS1_NUMORC,VS1->VS1_TIPORC) // Gerar CEV na Finalizacao do Orcamento ( Pos-Venda )
		UnlockByName( 'OFIXX001_' + VS1->VS1_NUMORC , .T., .F. ) // Destravar os ORCAMENTOS
	Next
	nPesol 	:= 0
	nPesob  := 0
	nPesos 	:= 0
	_cQuerup :=" "
	//Implementado status DAC 05/07/2022
	If SZK->(FieldPos("ZK_STATUS")) > 0   //N=Nao Envidado;E=Enviado;F=Faturado;C=Cancelado
		_cQuerup := " UPDATE " + RetSqlName("SZK") + " SZK " + " SET SZK.ZK_NF='" + _cDoc + "' , SZK.ZK_SERIE='" + _cSerie +"' , SZK.ZK_STATUS='F' "
	Else
		_cQuerup := " UPDATE " + RetSqlName("SZK") + " SZK " + " SET SZK.ZK_NF='" + _cDoc + "' , SZK.ZK_SERIE='" + _cSerie +"'"
	EndIf
	_cQuerup += " WHERE ZK_XPICKI = '"+cZK_XPICKI+"' AND ZK_FILIAL='" + xfilial("SZK") + "'"
	TcSqlExec(_cQuerup)
	//Fecho pois esta aberto
	(_cAliasPesq)->(DbCloseArea())
	BeginSql Alias _cAliasPesq
		SELECT SUM(ZK_PLIQUI) PLIQUI, SUM(ZK_PBRUTO) PBRUTO, SUM(ZK_XPESOC) XPESOC 
       		FROM %table:SZK% SZK
       		WHERE 	SZK.ZK_FILIAL  	= %XFilial:SZK%
				AND SZK.ZK_XPICKI  	= %Exp:cZK_XPICKI%
			  	AND SZK.%notDel%		  
	EndSql      
	If (_cAliasPesq)->(!Eof()) 	
		nPesol += (_cAliasPesq)->PLIQUI 
		nPesob += (_cAliasPesq)->PBRUTO
		nPesos += (_cAliasPesq)->XPESOC
	EndIf

/*
	_cQuerp := " SELECT ZK_PLIQUI,ZK_PBRUTO,ZK_XPESOC "
	_cQuerp += " FROM "+RetSQLName("SZK")+" SZK "
	_cQuerp += "    WHERE SZK.ZK_FILIAL='"+xFilial("SZK")+"' "
	_cQuerp += "          AND SZK.ZK_XPICKI = '" + cZK_XPICKI + "'"

	_cQuerp := ChangeQuery(_cQuerp)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuerp),"TRBNFP",.T.,.T.)

	DBSelectArea("TRBNFP")
	DBGoTop()

	while !(TRBNFP->(eof()))

		nPesol += TRBNFP->ZK_PLIQUI 
		nPesob += TRBNFP->ZK_PBRUTO
		nPesos += TRBNFP->ZK_XPESOC

	   	TRBNFP->(dbSkip())

	enddo
*/

/*SZK->(dbsetorder(1)) //Filial+xpicki+Str(ZK_SEQREG,10,2)
SZK->(dbGotop())
SZK->(dbSeek(xFilial("SZK")+cZK_XPICKI))
While SZK->(!Eof() .AND. SZK->ZK_XPICKI = cZK_XPICKI)
    SZK->(RecLock("SZK",.F.))
   	SZK->ZK_NF    	:= _cDoc
    SZK->ZK_SERIE 	:= _cSerie
	SZK->(MsUnLock())    
	nPesol 			+= SZK->ZK_PLIQUI 
	nPesob 			+= SZK->ZK_PBRUTO
	nPesos 			+= SZK->ZK_XPESOC
	SZK->(DbSkip())
EndDo*/

	//--Ativa mais de uma area de trabalho
	If !Empty(_cDoc)  //pode não ter farurado
		SF2->( DbSetOrder(1) ) // F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA  
		SD2->( DbSetOrder(3) ) // D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
		If SF2->( DbSeek( xFilial("SF2") + _cDoc + _cSerie + _cCliente + _cLoja ) )
			RecLock("SF2",.F.)
        	SF2->F2_PLIQUI := nPesol
        	SF2->F2_PBRUTO := nPesob
			SF2->F2_XPESOC := nPesos
			SF2->(MsUnlock())
		EndIf

		//--Efetua a gravação dos pesos bruto e cubado na tabela GW8 - GFE
		U_ZGFEF001(	_cDoc, _cSerie, _cCliente, _cLoja )
		//--Efetua a gravação do campo GW1_XTPTRA - GFE
		U_ZGFEF003()
	Endif
End Sequence
If _lControla 
	UnLockByName(_cChave+_cMarca,.T.,.T.)
Endif	
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif  
If Select(cAliasVEC) <> 0
	(cAliasVEC)->(DbCloseArea())
	Ferase(cAliasVEC+GetDBExtension())
Endif  
If Select(cAliasVS3) <> 0
	(cAliasVS3)->(DbCloseArea())
	Ferase(cAliasVS3+GetDBExtension())
Endif  

SZK->(DbGoto(_nRegSZK))
oBrowseUp:Refresh()
oBrowseLeft:Refresh()
//oDlg:Refresh()

Return()


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Função    | CriaSX1    | Autor |  Luis Delorme         | Data | 30/05/11 |##
##+----------+------------+-------+-----------------------+------+----------+##
###############################################################################
===============================================================================
*/
Static Function CriaSX1()
Local aSX1    := {}
Local aEstrut := {}
Local i       := 0
Local j       := 0
Local lSX1	  := .F.


dbSelectArea("SX1")
dbSetOrder(1)
cSX1 := left("OFIXA021"+space(10),len(SX1->X1_GRUPO))
if dbSeek(cSX1+"02")
	if SX1->X1_TAMANHO <> TamSX3("A1_LOJA")[1]
        RecLock("SX1",.F.,.T.)
   	    dbdelete()   
   		MsUnlock()
   	Endif
Endif   		

aEstrut:= { "X1_GRUPO"  ,"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL"	,;
"X1_GSC"    ,"X1_VALID","X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02"  ,"X1_DEF02"  ,"X1_DEFSPA2"	,;
"X1_DEFENG2","X1_CNT02","X1_VAR03"  ,"X1_DEF03" ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04"  ,"X1_DEF04"  ,"X1_DEFSPA4"	,;
"X1_DEFENG4","X1_CNT04","X1_VAR05"  ,"X1_DEF05" ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3"     ,"X1_GRPSXG" ,"X1_PYME"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aAdd a Pergunta                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aAdd(aSX1,{cPerg,"01","Cliente","","","MV_CH1","C",TamSX3("A1_COD")[1],0,0,"G","","mv_par01",    ; // Cliente
	"","","","","","","","","","","","","","","","","","","","","","","","","SA1","","S"})
aAdd(aSX1,{cPerg,"02","Loja","","","MV_CH2","C",TamSX3("A1_LOJA")[1],0,0,"G","","mv_par02",   ; // Loja
	"","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
//aAdd(aSX1,{cPerg,"03",STR0011,"","","MV_CH3","D",TamSX3("VS1_DATORC")[1],0,0,"G","","mv_par03",; // De
//	"","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
//aAdd(aSX1,{cPerg,"04",STR0012,"","","MV_CH4","D",TamSX3("VS1_DATORC")[1],0,0,"G","","mv_par04",; // Até
//	"","","","","","","","","","","","","","","","","","","","","","","","","","","S"})
//aAdd(aSX1,{cPerg,"05",STR0024,"","","MV_CH5","C",TamSX3("VS1_CODVEN")[1],0,0,"G","","mv_par05",; // Vendedor
//	"","","","","","","","","","","","","","","","","","","","","","","","","SA3","","S"})

ProcRegua(Len(aSX1))

dbSelectArea("SX1")
dbSetOrder(1)
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(Left(Alltrim(aSX1[i,1])+SPACE(100),Len(SX1->X1_GRUPO))+aSX1[i,2])
			lSX1 := .T.
			RecLock("SX1",.T.)
			
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			
			dbCommit()
			MsUnLock()
			IncProc()
		EndIf
	EndIf
Next i

return



/*/{Protheus.doc} ZPECF013H - Verificar o Status para poder fazer os ajustes, localizar fases até a fase de conferencia
@param  	
@author 	CAOA - DAC 
@version  	P12.1.23
@since  	18/03/2022
@return  	NIL
@obs		
@project
@history   	    
/*/
Static Function ZPECF13FAS(_cNumOrc)
Local _lRet			:= .F.
Local _cFaseConf 	:= Alltrim(GetNewPar("MV_MIL0095","4"))  //indica fase de conferencia
Local _cFaseOrc 	:= AllTrim(GetNewPar("MV_FASEORC","023R45F"))
Local _cFase
Local _nPos

Default _cNumOrc 	:= ""

Begin Sequence
	/* Conforme JC o bloqueio funcionara somnte para os casos de faturamento na opção EmitDoc DAC 21/07/2022
	If SZK->(FieldPos("ZK_STATUS")) > 0 .and. SZK->ZK_STATUS == "B"
   		MSGINFO( "Picking Bloqueado, desbloquear para poder fazer manutenção !!! ", "[ZPECF013_ZPECF13FAS] - Atenção" )
		Break
	EndIf				
	*/
	If SZK->(FieldPos("ZK_STATUS")) > 0 .and. SZK->ZK_STATUS == "C"
   		MSGINFO( "Picking Cancelado, não será possível fazer manutenção !!! ", "[ZPECF013_ZPECF13FAS] - Atenção" )
		Break
	EndIf				
	//GAP002 DAC 28/03/2023
	If SZK->ZK_STATUS == "D"
   		MSGINFO( "Picking com Divergência WIS, não será possível fazer manutenção !!! ", "[ZPECF013_ZPECF13FAS] - Atenção" )
		Break
	Endif
	If Empty(_cNumOrc)
   		MSGINFO( "Problemas com parametros de numero orçamento  !!! ", "[ZPECF013_ZPECF13FAS] - Atenção" )
		Break
	Endif
	_nPos := AT(_cFaseConf, _cFaseOrc) 
	If _nPos <= 0
   		MSGINFO( "Parametro fases de orçamento não esta definido parametro de fase conferencia  !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
		Break
	EndIf 		
	_cFase	:= SubsTr(_cFaseOrc,1,_nPos)
	//verifico se esta posicionado no cabeçalho VS1
	If VS1->VS1_NUMORC <> _cNumOrc
		VS1->(DbSetOrder(1))
		If !VS1->( DbSeek(XFilial("VS1")+_cNumOrc ))
    		MSGINFO( "Não localizado o Orçamento "+_cNumOrc+" !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
			Break
		EndIf
	EndIf	
	//valida se o processo esta dentro da fase permitida
	//If !(VS1->VS1_STATUS $ _cFase)  
	//DAC 22/03/2022
	//alterado conforme solicitação Jose Carlos possibilidade de alterar itens a faturar que não foram emitidas notas
	//Verifica e acrescenta fase faturamento, não pode estar com nota
	If Empty(SZK->ZK_NF) .And. AT("F",_cFase) == 0    	
		_cFase += "F"
	Endif		
	If !(VS1->VS1_STATUS $ _cFase)  
   		MSGINFO( "Processo permitido somente para orçamentos em fase de conferência e ou anteriores a esta !!! "+;
		   		 "Fase ["+VS1->VS1_STATUS+"] atual do orçamento "+_cNumOrc+" , [ZPECF013_MANUTENCAO] - Atenção" )
		Break
	EndIf 
	_lRet := .T.
End Sequence
Return 	_lRet



/*/{Protheus.doc} ZPECF013H - Chamar funcionalidade para retirar o numero do picking dos orçamentos DAC 27/04/2022
@param  	
@author 	CAOA - DAC 
@version  	P12.1.23
@since  	27/04/2022
@return  	NIL
@obs		
@project
@history   	    
/*/

Static Function ZPECF13H()
Local _nRegSZK 	:= SZK->(Recno())
Local _lRet
//MSGINFO( "Processo em desenvolvimento !!! ", "[ZPECF013_MANUTENCAO] - Atenção" )
//Return Nil
_lRet := U_ZGENUSER( RetCodUsr() ,"ZPECF13H" ,.T.)
If !_lRet
	Return Nil
EndIf
U_XAPAGAPicking(SZK->ZK_XPICKI, "0")
SZK->(DbGotop())
SZK->(DbGoto(_nRegSZK))
oBrowseUp:Refresh()
oBrowseLeft:Refresh()
Return Nil


/*/{Protheus.doc} ZPECF013I - Funcionalidade  responsavel por Bloquear picking 
@param  	
@author 	CAOA - DAC 
@version  	P12.1.23
@since  	06/07/2022
@return  	NIL
@obs		ZK_STATUS => A=Aberto;E=Enviado;F=Faturado;B=Bloqueado;C=Cancelado;D-Divergencia WIS
@project
@history   	    
/*/
Static Function ZPECF13I()
Local _cPicking	:= SZK->ZK_XPICKI
Local _cStatus	:= "B"
Local _cQuery
Local _cObs
Local _nStatus
Local _lRet		

Begin Sequence
	_lRet := !U_ZGENUSER( RetCodUsr() ,"ZPECF13H" ,.T.)
	If !_lRet
		Break	
	EndIf

	If SZK->ZK_STATUS == "B" //Bloqueado
   		MSGINFO( "Picking ja esta bloqueado  !!! ", "[ZPECF013I] - Atenção" )
		_lRet := .f.
		Break
	EndIf
	If SZK->ZK_STATUS == "C" //Cancelado
   		MSGINFO( "Picking esta Cancelado  !!! ", "[ZPECF013I] - Atenção" )
		_lRet := .f.
		Break
	EndIf
	If SZK->ZK_STATUS == "F" .or. !Empty(SZK->ZK_NF) //Faturado
   		MSGINFO( "Picking esta Faturado  !!! ", "[ZPECF013I] - Atenção" )
		_lRet := .f.
		Break
	EndIf

	//GAP002 DAC 28/03/2023
	If SZK->ZK_STATUS == "D"
   		MSGINFO( "Picking esta com Divergência Wis  !!! ", "[ZPECF013I] - Atenção" )
		_lRet := .f.
		Break
	Endif

    If !MsgYesNo("Este Picking será bloqueado , confirma o bloqueio do Picking ? ")
		Break
	EndIf

	_cQuery := 	" UPDATE " + RetSqlName("SZK") + " SZK " + ;
				" SET 	SZK.ZK_STATUS = '"+_cStatus+"' "
	_cQuery +=  " WHERE SZK.ZK_FILIAL = '" +XFilial("SZK")+ "' AND  SZK.ZK_XPICKI = '"+_cPicking + "'"
	_cQuery +=  "   AND SZK.ZK_NF = ' ' AND SZK.ZK_STATUS NOT IN ('F','C','B','D') " 	
  	_nStatus := TcSqlExec(_cQuery)
  	if (_nStatus < 0)
    	MSGINFO("Erro ao gravar Status na tabela SZK "+ TCSQLError() , "[ZPECF013I] - Atenção" )
		Break
  	endif

	_cObs 	:= "Picking "+_cPicking+" Bloqueado em "+DtoC(Date())+" as "+SubsTr(Time(),1,5)+" Usuário "+Upper(FwGetUserName(RetCodUsr()))+CRLF
	ZPECATVS1O( _cObs, _cPicking)  //Atualiza obs referente ao picking
End Sequence
If _lRet
	SZK->(DbSkip())
EndIf	
oBrowseUp:Refresh()
oBrowseLeft:Refresh()
Return Nil


/*/{Protheus.doc} ZPECF013I - Funcionalidade  responsavel por desbloquear picking quando bloqueado na divergência
@param  	
@author 	CAOA - DAC 
@version  	P12.1.23
@since  	06/07/2022
@return  	NIL
@obs		ZK_STATUS => A=Aberto;E=Enviado;F=Faturado;B=Bloqueado;C=Cancelado;D=Divergência Wis
@project
@history   	    
/*/
Static Function ZPECF13J()
Local _cPicking	:= SZK->ZK_XPICKI
Local _cStatus	:= ""
Local _cQuery
Local _cObs
Local _nStatus
Local _lRet

Begin Sequence
	_lRet := U_ZGENUSER( RetCodUsr() ,"ZPECF13H" ,.T.)
	If !_lRet
		Break	
	EndIf
	
	If SZK->ZK_STATUS <> "B" //Bloqueado
   		MSGINFO( "Picking não esta bloqueado  !!! ", "[ZPECF013I] - Atenção" )
		Break
	EndIf
    If !MsgYesNo("Este Picking será Desbloqueado , confirma o desbloqueio do Picking ? ")
		_lRet := .f.
		Break
	EndIf

	//Avaliar Status
	_cStatus	:= ""	
	If !Empty(SZK->ZK_NF)
		_cStatus := "F"
	ElseIf Empty(SZK->ZK_NF) .AND. !Empty(SZK->ZK_STREG)
		_cStatus := "E"
	ElseIf Empty(SZK->ZK_NF) .AND.  Empty(SZK->ZK_STREG)
		_cStatus := "A"
	EndIf

	_cQuery := 	" UPDATE " + RetSqlName("SZK") + " SZK " + ;
				" SET 	SZK.ZK_STATUS = '"+_cStatus+"' "
	_cQuery += 	" WHERE SZK.ZK_FILIAL = '" +XFilial("SZK")+ "' AND  SZK.ZK_XPICKI = '"+_cPicking + "'"
	_cQuery +=  "  AND  SZK.ZK_STATUS = 'B' " 	

  	_nStatus := TcSqlExec(_cQuery)
  	if (_nStatus < 0)
    	MSGINFO("Erro ao gravar Status na tabela SZK "+ TCSQLError() , "[ZPECF013I] - Atenção" )
		Break
  	endif
	_cObs 	:= "Picking "+_cPicking+" Desbloqueado em "+DtoC(Date())+" as "+SubsTr(Time(),1,5)+" Usuário "+Upper(FwGetUserName(RetCodUsr()))+CRLF
	ZPECATVS1O( _cObs, _cPicking)  //Atualiza obs referente ao picking
End Sequence
If _lRet
	SZK->(DbSkip())
EndIf	
oBrowseUp:Refresh()
oBrowseLeft:Refresh()
Return Nil


/*/{Protheus.doc} ZPECATVS1O - Funcionalidade responsavel por atualizar VS1 referente ao picking
@param  	
@author 	CAOA - DAC 
@version  	P12.1.23
@since  	07/07/2022
@return  	NIL
@obs		ZK_STATUS => A=Aberto;E=Enviado;F=Faturado;B=Bloqueado;C=Cancelado;D=Divergência WIS
@project
@history   	    
/*/
Static Function ZPECATVS1O( _cObs, _cPicking)
Local _cAliasPesq	:= GetNextAlias()   
Local _lRet			:= .T.
Begin Sequence
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT 	VS1.R_E_C_N_O_ AS NREGVS1
		FROM  %Table:VS1% VS1			
		WHERE 	VS1.VS1_FILIAL  = %xFilial:VS1%
			AND VS1.VS1_XPICKI	= %Exp:_cPicking% 
           	AND VS1.%notDel%
	EndSQL	
	If (_cAliasPesq)->(Eof())
		_lRet := .F.
		Break
	EndIf
	While (_cAliasPesq)->(!Eof())
		VS1->(DbGoto((_cAliasPesq)->NREGVS1))
		VS1->(RecLock("VS1",.F.))
		VS1->VS1_OBSAGL		:= Upper(_cObs) + CRLF  + AllTrim(VS1->VS1_OBSAGL)
		VS1->(MsUnlock())
		(_cAliasPesq)->(DbSkip())
	EndDo
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet

Static Function xValDesc(cVar1,cVar2,oVar,nOpt)

If nOpt == 1
	cVar2 := Posicione("SE4",1,xFilial("SE4")+AllTrim(cVar1),"E4_DESCRI")
ElseIf nOpt == 2
	cVar2 := Posicione("VX5",1,xFilial("VX5")+"Z01"+AllTrim(cVar1),"VX5_DESCRI")
ENDIF

oVar:Refresh()

Return(.T.)

User Function zCmbDesc(cChave, cCampo, cConteudo)
    Local aArea       := GetArea()
    Local aCombo      := {}
    Local nAtual      := 1
    Local cDescri     := ""
    Default cChave    := ""
    Default cCampo    := ""
    Default cConteudo := ""
     
    //Se o campo e o conteúdo estiverem em branco, ou a chave estiver em branco, não há descrição a retornar
    If (Empty(cCampo) .And. Empty(cConteudo)) .Or. Empty(cChave)
        cDescri := ""
    Else
        //Se tiver campo
        If !Empty(cCampo)
            aCombo := RetSX3Box(GetSX3Cache(cCampo, "X3_CBOX"),,,1)
             
            //Percorre as posições do combo
            For nAtual := 1 To Len(aCombo)
                //Se for a mesma chave, seta a descrição
                If cChave == aCombo[nAtual][2]
                    cDescri := aCombo[nAtual][3]
                EndIf
            Next
             
        //Se tiver conteúdo
        ElseIf !Empty(cConteudo)
            aCombo := StrTokArr(cConteudo, ';')
             
            //Percorre as posições do combo
            For nAtual := 1 To Len(aCombo)
                //Se for a mesma chave, seta a descrição
                If cChave == SubStr(aCombo[nAtual], 1, At('=', aCombo[nAtual])-1)
                    cDescri := SubStr(aCombo[nAtual], At('=', aCombo[nAtual])+1, Len(aCombo[nAtual]))
                EndIf
            Next
        EndIf
    EndIf
     
    RestArea(aArea)
Return cDescri


