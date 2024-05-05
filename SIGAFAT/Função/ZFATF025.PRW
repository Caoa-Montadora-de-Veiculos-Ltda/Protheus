#include "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE 'TOPCONN.CH'
#Include "TbiConn.CH"

// identificadores de layout
#define LAYOUT_AR "layout_ar"

// identificadores de coluna
#define COL_RIGHT  			"column_right"
#define COL_CENTER 			"column_center"
#define COL_LEFT   			"column_left"

/// identificadores de painel
#define PANEL_SEARCH    	"panel_search"
#define PANEL_BROWSE    	"panel_browse"
#define PANEL_VISUAL    	"panel_visual"
#define PANEL_FAVORITES 	"panel_favorites"
#define PANEL_CHART     	"panel_chart"
#define PANEL_REPORTS   	"panel_report"
#define PANEL_OPERATIONS 	"panel_operations"
#define PANEL_FILIAIS 		"panel_filiais"

// exclusivos para SE5
#define PANEL_BANK       	"panel_bank"
#define PANEL_ACC        	"panel_acc"

// identificadores de janela
#define WND_FAVORITES 		"wnd_favorites"
#define WND_UNKNOWN   		"wnd_unknown"
#define WND_BROWSE    		"wnd_browse"
#define WND_SEARCH    		"wnd_search"
#define WND_TOOLS  			"wnd_toos"
#define WND_OPERATIONS 		"wnd_operations"
#define WND_CHART  			"wnd_chart"
#define WND_VIS 			"wnd_visual"
#define WND_FILIAIS 		"wnd_filiais"
#define WND_RESUMO 			"wnd_resumo"

// bot√µes
#define IMG_CREATE 	"BMPINCLUIR"
#define IMG_READ   	""
#define IMG_UPDATE 	"NOTE"
#define IMG_DELETE 	"EXCLUIR"

#define IMG_OK     	"OK"
#define IMG_CANCEL 	"CANCEL"

#define IMG_SEARCH 	"PESQUISA"

#define IMG_COPY 	"S4WB005N"
#define IMG_CUT  	"s4wb006n"
#define IMG_PASTE 	"S4WB007N"
#define IMG_REFRESH "RELOAD"

//Browse Relacionados
#define DATA_CLIENTE  	1
#define DATA_LOJA  	2
#define DATA_CNPJCPF  	3
#define DATA_NOMCLI  	4
#define DATA_TOTCLI 	5
#define DATA_TOTFAT 	6

#define DATA_PRODUTO 	1
#define DATA_DESCPRD	2
#define DATA_QTDEPRD    3
#define DATA_QTDEPREV	4
#define DATA_SALDOPRD	5


//Static cSayUltCMP	:= ""
//Static cSayUltVND   := ""

//====================================

User Function ZFATF025(_oSay)
Private TelWindow 	:= TelAcWindow():New("SB1")	
Private oArea    
Private oPanelVis
Private	_aCliRel  	:= {}

Begin Sequence
	TelWindow:Init()
	TelWindow:Show()
End Sequence
Return .T.

Class TelAcWindow
	Data oArea 			As Object
	// largura x altura
	Data nWidth 		As Object
	Data nHeight 		As Object
	// objetos auxiliares de interface
	Data oLayout 		As Object
	Data oSidebar 		As Object
	// pain√©is esquerdos
	Data oPanelSearch 	As Object
	Data oPanelChart 	As Object
	Data oPanelDados 	As Object 
	Data _oBrowseZZN	As Object

	// pain√©is centrais
	Data oPanelBrowse 	As Object
	Data oPanelVis 		As Object
	Data _oBrowseZZP	As Object
	Data _oBrwTotCli	As Object
	// pain√©is direitos	
	Data oPanelEVenda 	As Object
	Data oPanelDetalhe 	As Object


	// objetos necess√°rios para a interface	
	Data oGetData 		As Object

	Data oDlg 			As Object
	Data oTreeAccounts 	As Object

	Data oChart 		As Array

	//Data oSayDescPrd 	As Object
	Data oSayUltCMP 	As Object
	Data oSayUltVND 	As Object

	//Data cSayDescPrd 	As String
	//Data cSayUltCMP		As String
	//Data cSayUltVND 	As String

	// alias de trabalho	
	Data cAliasFile 	As String
	// construtor
	Method New() Constructor
	// constru√ß√£o de tela	
	Method CreateLeftColumn()
	Method CreateRightColumn()
	Method CreateCenterColumn()
	//Method FilterFile()
	// atualiza√ß√£o
	Method RefreshPrev()	

	Method SetBrowseTitle()

	Method SetDadosTitle()
	Method GetDadosTitle()

	Method SetChartTitle()
	
	Method GetVisPanel()
		
	Method GetAlias()
	Method SetAlias()

	// outros
	Method Init()
	Method Show()
	Method ShowViewPanel()
	Method DimObj()
	Method MenuPrev(_nOpc)
	Method ZFT25Change()
EndClass

/* ----------------------------------------------------------------------------

TelAcWindow:New()

Cria uma nova inst√¢ncia da classe TelAcWindow. 

Restri√ß√£o: New() apenas inicializa os atributos. Para a constru√ß√£o de
interfaces √© necess√°rio a chamada do m√©todo Init().

---------------------------------------------------------------------------- */
Method New(cAliasFile) Class TelAcWindow
Begin Sequence
	Self:oDlg 			:= Nil
	Self:oArea 			:= Nil

	Self:nWidth  		:= GetScreenRes()[1] - 40
	Self:nHeight 		:= GetScreenRes()[2] - 200
	
	Self:oLayout 		:= Nil
	Self:oSidebar		:= Nil
		
	Self:cAliasFile 	:= cAliasFile

	Self:oPanelSearch 	:= Nil
	Self:oPanelChart 	:= Nil
	Self:oPanelDados 	:= Nil // Ferramentas
	Self:_oBrowseZZN	:= Nil

	// pain√©is centrais
	Self:oPanelBrowse	:= Nil
	Self:oPanelVis 		:= Nil
	Self:_oBrowseZZP	:= Nil
	Self:_oBrwTotCli	:= Nil

	// pain√©is direitos	
	Self:oPanelEVenda 	:= Nil
	Self:oPanelDetalhe 	:= Nil

	// objetos necess√°rios para a interface	
	Self:oGetData 		:= Nil
	Self:oChart 		:= Nil

	//Self:oSayDescPrd 	:= Nil
	Self:oSayUltCMP 	:= Nil
	Self:oSayUltVND 	:= Nil


End Begin
Return Self

/* ----------------------------------------------------------------------------
TelAcWindow:Show()
Exibe a tela do gestor.
---------------------------------------------------------------------------- */
Method Show() Class TelAcWindow
	Self:oDlg:Activate()
Return

/* ----------------------------------------------------------------------------
TelAcWindow:CreateLeftColumn()
Cria os pain√©is do lado esquerdo, de acordo com o gestor utilizado:
Contas a Receber, Contas a Pagar ou Tesouraria:
---------------------------------------------------------------------------- */
Method CreateLeftColumn() Class TelAcWindow

Begin Sequence
	Self:oArea:AddCollumn(COL_LEFT , 30, .T.)
	Self:oArea:SetColSplit(COL_LEFT, CONTROL_ALIGN_RIGHT)
	// cria a janela de search
	Self:oArea:AddWindow(COL_LEFT, WND_SEARCH, "Previs„o", 100, .T., .F.) //"Pesquisa"
	// cria o panel da pesquisa
	Self:oPanelSearch := Self:oArea:GetWinPanel(COL_LEFT, WND_SEARCH)
    //funcionalidade para carga da tabela tempor√°ria
	DbSelectArea("ZZN")
    //tabela temporaria
    
	Self:_oBrowseZZN:=FWMBrowse():New()
    Self:_oBrowseZZN:SetAlias("ZZN")
	Self:_oBrowseZZN:SetDescription('Previsao')
    Self:_oBrowseZZN:SetOwner(Self:oPanelSearch)
    //Self:_oBrowseZZN:SetUseFilter(.F.)
    //Self:_oBrowseZZN:SetDBFFilter(.F.)                  
    //Self:_oBrowseZZN:DisableConfig() 		// Desabilita a utilizaÁ„o do Browse
	Self:_oBrowseZZN:SetCanSaveArea(.T.)	//abertura de mais de uma  browse
    //Self:_oBrowseZZN:DisableDetails()
	Self:_oBrowseZZN:SetMenuDef('')
    Self:_oBrowseZZN:SetIgnoreARotina(.T.) // Indica que a mbrowse, ira ignorar a variavel private aRotina na construÁ„o das opÁıes de menu.
    Self:_oBrowseZZN:SetWalkThru(.F.)
    Self:_oBrowseZZN:SetAmbiente(.F.) //Habilita a utilizaÁ„o da funcionalidade Ambiente no Browse
    Self:_oBrowseZZN:SetFixedBrowse(.T.)
	Self:_oBrowseZZN:AddLegend("AllTrim(ZZN_STATUS) = 'A'  "  ,"WHITE"     ,"Em Aberto")
	Self:_oBrowseZZN:AddLegend("AllTrim(ZZN_STATUS) = 'L'  "  ,"GREEN"     ,"Liberado Fat")
    Self:_oBrowseZZN:AddLegend("AllTrim(ZZN_STATUS) = 'F'  "  ,"BLUE" 	   	,"Faturado")
	Self:_oBrowseZZN:AddLegend("AllTrim(ZZN_STATUS) = 'C'  "  ,"RED"       ,"Cancelado")
	Self:_oBrowseZZN:AddLegend("AllTrim(ZZN_STATUS) <> ' '  " ,"GRAY"      ,"Pendente")

	Self:_oBrowseZZN:AddButton("Incluir"	, { || Self:MenuPrev(3)	})
	Self:_oBrowseZZN:AddButton("Alterar"	, { || Self:MenuPrev(4)	})
	Self:_oBrowseZZN:AddButton("Faturar"	, { || Self:MenuPrev(1)	})
	Self:_oBrowseZZN:AddButton("Cancelar"	, { || Self:MenuPrev(5)	})
	Self:_oBrowseZZN:AddButton("Visualizar",  { || Self:MenuPrev(2)	})
	//mudanca de linha
	Self:_oBrowseZZN:setChange({||  Self:ZFT25Change(), Self:RefreshPrev()})
	//Self:SetDadosTitle('Consulta Previsao')
	Self:_oBrowseZZN:Activate()
	Self:_oBrowseZZN:GoTop(.T.)
	Self:_oBrowseZZN:Refresh(.T.)
End Sequence
Return


/* ----------------------------------------------------------------------------
TelAcWindow:CreateCenterColumn()
Cria os pain√©is centrais, de acordo com o gestor utilizado: Contas a Receber,
Contas a Pagar ou Tesouraria:
---------------------------------------------------------------------------- */
Method CreateCenterColumn() Class TelAcWindow
//Local _aRelac
Local _oRelac

Begin Sequence
	oArea := Self:oArea
	// cria a coluna do meio	
	Self:oArea:AddCollumn(COL_CENTER, 70, .F.)
	Self:oArea:SetColSplit(COL_CENTER, CONTROL_ALIGN_LEFT)
	// visualiza√ß√£o do planejamento
	Self:oArea:Addwindow(COL_CENTER, WND_VIS, "Consulta Previs„o ", 70, .T., .F.) 
	Self:oPanelBrowse := Self:oArea:GetWinPanel(COL_CENTER, WND_VIS)

	Self:oArea:AddWindow(COL_CENTER, WND_BROWSE, "Totais", 30, .T., .F.)
	Self:oPanelVis := Self:oArea:GetWinPanel(COL_CENTER, WND_BROWSE)
	//Self:oArea:AddWindow(COL_CENTER, WND_BROWSE, "Relacionamento ", 30, .T., .F.)
	//Self:oPanelVis := Self:oArea:GetWinPanel(COL_CENTER, WND_BROWSE)

    //Campos tabela temporaria              
	DbSelectArea("ZZP")
    Self:_oBrowseZZP:= FWMBrowse():New()
	Self:_oBrowseZZP:SetOwner( Self:oPanelBrowse )
	Self:_oBrowseZZP:SetDescription("Previsao")
	Self:_oBrowseZZP:SetMenuDef( '' )
	//Self:_oBrowseZZP:DisableReport()
	Self:_oBrowseZZP:DisableDetails()
	Self:_oBrowseZZP:SetAlias('ZZP')
	//Self:_oBrowseZZP:SetProfileID( '2' )
	Self:_oBrowseZZP:Activate() 
	//-- Relacionamento entre os Paineis
	_oRelac:= FWBrwRelation():New()
	_oRelac:AddRelation(  Self:_oBrowseZZN, Self:_oBrowseZZP ,  {	{"ZZP_FILIAL" , "ZZN_FILIAL" } ,; 
                                        							{"ZZP_CODPRV" , "ZZN_CODPRV" }})  
	_oRelac:Activate()

	// Define o Browse Relacionados carrega _aCliRel
	_aRelac := ZFAT025Total( ZZN->ZZN_FILIAL, ZZN->ZZN_CODPRV,  /*_lCarrega*/)
	Self:_oBrwTotCli := FWBrowse():New()
	Self:_oBrwTotCli:SetDataArray(.T.)
	Self:_oBrwTotCli:SetArray(_aCliRel)
	Self:_oBrwTotCli:DisableConfig(.T.)
	Self:_oBrwTotCli:DisableReport(.T.)
	Self:_oBrwTotCli:DisableLocate(.T.)
	Self:_oBrwTotCli:DisableFilter(.T.)
    Self:_oBrwTotCli:SetOwner(Self:oPanelVis)
	//Self:_oBrwTotCli:SetDoubleClick({ || xfunc(Self:_oBrwTotCli,Self:_oBrwTotCli:nAt) , Self:, Self:_oBrwTotCli:Refresh()    })	

	// Cria uma coluna de status
	// Adiciona as colunas do Browse
	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aCliRel[Self:_oBrwTotCli:nAt,DATA_CLIENTE]})
	_oColumn:SetTitle("Cliente" ) 
	_oColumn:SetSize(Len(SA1->A1_COD))
	Self:_oBrwTotCli:SetColumns({_oColumn})
	
	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aCliRel[Self:_oBrwTotCli:nAt,DATA_LOJA]})
	_oColumn:SetTitle("Loja") 
	_oColumn:SetSize(Len(SA1->A1_LOJA))
	_oColumn:SetDecimal(2)
	//oColumn:SetPicture("@!")
	Self:_oBrwTotCli:SetColumns({_oColumn})

	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aCliRel[Self:_oBrwTotCli:nAt,DATA_CNPJCPF]})
	_oColumn:SetTitle("CNPJ/CPF") 
	_oColumn:SetSize(Len(SA1->A1_CGC))
	_oColumn:SetDecimal(0)
	//_oColumn:SetPicture("@!")
	Self:_oBrwTotCli:SetColumns({_oColumn})

	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aCliRel[Self:_oBrwTotCli:nAt,DATA_NOMCLI]})
	_oColumn:SetTitle("Nome Cliente") 
	_oColumn:SetSize(Len(SA1->A1_NOME))
	_oColumn:SetDecimal(0)
	_oColumn:SetPicture("@!")
	Self:_oBrwTotCli:SetColumns({_oColumn})

	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aCliRel[Self:_oBrwTotCli:nAt,DATA_TOTCLI]})
	_oColumn:SetTitle("Total Pedido") 
	_oColumn:SetSize(15)
	_oColumn:SetDecimal(2)
	_oColumn:SetPicture("@E 9999,999,999.99")
	Self:_oBrwTotCli:SetColumns({_oColumn})

	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aCliRel[Self:_oBrwTotCli:nAt,DATA_TOTFAT]})
	_oColumn:SetTitle("Total Faturamento") 
	_oColumn:SetSize(15)
	_oColumn:SetDecimal(2)
	_oColumn:SetPicture("@E 9999,999,999.99")
	Self:_oBrwTotCli:SetColumns({_oColumn})

	Self:_oBrwTotCli:Activate()
	Self:_oBrwTotCli:GoTop(.T.)
	Self:_oBrwTotCli:Refresh(.T.)
End Begin
 //aRotina := ArotBKP	
Return Nil


/* ----------------------------------------------------------------------------
TelAcWindow:CreateRightColumn()
Cria os pain√©is do lado direito, de acordo com o gestor utilizado:
Contas a Receber, Contas a Pagar ou Tesouraria:
---------------------------------------------------------------------------- */
Method CreateRightColumn() Class TelAcWindow
//Local oTelWindow := Self

Begin Sequence
	//janela estatistica/Detalhes
	Self:oArea:AddCollumn(COL_RIGHT, 15, .F.)
	Self:oArea:SetColSplit(COL_RIGHT, CONTROL_ALIGN_LEFT)
	//Estatistica de vendas	
	Self:oArea:AddWindow(COL_RIGHT, WND_OPERATIONS, "Estatistica Vendas", 50, .T., .F.) 
	Self:oPanelEVenda := Self:oArea:GetWinPanel(COL_RIGHT, WND_OPERATIONS)
	//Detalhes
	Self:oArea:AddWindow(COL_RIGHT, WND_RESUMO, "Detalhes ", 50, .T., .F.)
	Self:oPanelDetalhe := Self:oArea:GetWinPanel(COL_RIGHT, WND_RESUMO )

	oArea := Self:oArea
	
End Sequence
Return Nil




/* ----------------------------------------------------------------------------
TelAcWindow:SetBrowseTitle()
Altera o t√≠tulo do painel de navega√ß√£o para o texto especificado cWindowTitle.
---------------------------------------------------------------------------- */
Method SetBrowseTitle(cWindowTitle) Class TelAcWindow
Return Self:oArea:SetWinTitle(COL_CENTER, WND_BROWSE, cWindowTitle)


/* ----------------------------------------------------------------------------
TelAcWindow:SetDadosTitle()
Altera o t√≠tulo do painel de visualiza√ß√£o para o texto especificado
cWindowTitle.
---------------------------------------------------------------------------- */
Method SetDadosTitle(cWindowTitle) Class TelAcWindow
Return Self:oArea:SetWinTitle(COL_CENTER, WND_VIS, cWindowTitle)

/* ----------------------------------------------------------------------------
TelAcWindow:GetDadosTitle()
M√©todo n√£o implementado ainda.
---------------------------------------------------------------------------- */
Method GetDadosTitle() Class TelAcWindow
Return ""


/* ----------------------------------------------------------------------------
Fun√ß√µes auxiliares
---------------------------------------------------------------------------- */

/* ----------------------------------------------------------------------------
DlgInPanel()
Encaixa Dialog no Panel.
---------------------------------------------------------------------------- */
Static Function DlgInPanel(oParent)
	Local aDim 	:= {}
	Local nTop 	:= 0
	Local nLeft := 0
	oParent:ReadClientCoors( ,.T.)
	_GetXCoors(oParent, @nTop)
	_GetYCoors(oParent, @nLeft)
	aDim := {oParent:oWnd:nTop + nTop, ;
				nLeft + oParent:oWnd:nLeft, ;
				oParent:nBottom + oParent:oWnd:nTop + nTop -40 , ;
				oParent:nRight + nLeft -11 }
Return aDim


/* ----------------------------------------------------------------------------
DlgWidthPanelPanel()
Devolve a largura do painel oParent, utilizando o m√©todo ReadClientCorrs() para
ler as dimens√µes reais do painel.
---------------------------------------------------------------------------- */
Static Function DlgWidthPanel(oParent)
	Local nLargura := 0	
	oParent:ReadClientCoors()	
	nLargura := oParent:nWidth
Return nLargura


/* ----------------------------------------------------------------------------
TelAcWindow:DimObj()
Devolve as dimens√µes do painel de visualiza√ß√£o.
---------------------------------------------------------------------------- */
Method DimObj(cPanel) Class TelAcWindow
	Local oParent := NIL
	Self:oArea:GetWinPanel(COL_CENTER, WND_VIS)
	oParent:FreeChildren()
	aDim := DLGinPANEL(oParent)
Return aDim


/* ----------------------------------------------------------------------------
TelAcWindow:Refresh()
Atualiza os pain√©is de pesquisa e de gr√°ficos (caso o mesmo exista).
---------------------------------------------------------------------------- */
Method RefreshPrev(_lPainel) Class TelAcWindow
	Default _lPainel := .F. 

	//If !_lPainel 
	//Self:_oBrowseZZN:Refresh() 
	//Endif 	
	/*
	If Valtype(Self:oPanelVis) == "O"
		Self:oPanelVis:Refresh(.T.)
	Endif 
	If Valtype(Self:oPanelBrowse) == "O"
		Self:oPanelBrowse:Refresh(.T.)
	Endif
	*/
	/*
	If ValType(Self:_oBrowseZZP) == "O" 
		Self:_oBrowseZZP:Refresh(.T.)
	Endif
	*/

	If ValType(Self:_oBrowseZZN) == "O" 
		Self:_oBrowseZZN:Refresh()
	Endif 

	If ValType(Self:_oBrowseZZP) == "O" 
		Self:_oBrowseZZP:Refresh()
	Endif
	
	If ValType(Self:_oBrwTotCli) == "O" 
		Self:_oBrwTotCli:SetArray(_aCliRel)
		Self:_oBrwTotCli:Refresh(.T.)
	Endif
	
Return Nil

/* ----------------------------------------------------------------------------
TelAcWindow:GetAlias()
Devolve o alias sendo utilizado pelo gestor.
---------------------------------------------------------------------------- */
Method GetAlias() Class TelAcWindow
Return Self:cAliasFile

/* ----------------------------------------------------------------------------
TelAcWindow:SetAlias()
Altera o alias sendo utilizado pelo gestor.
---------------------------------------------------------------------------- */
Method SetAlias(cAlias) Class TelAcWindow
	Self:cAliasFile := cAlias
Return Self:cAliasFile

/* ----------------------------------------------------------------------------
TelAcWindow:SetChartTitle()
Altera o t√≠tulo do painel de de gr√°ficos para o texto especificado
cWindowTitle.
---------------------------------------------------------------------------- */
Method SetChartTitle(cWindowTitle) Class TelAcWindow
Return Self:oArea:SetWinTitle(COL_LEFT, WND_CHART, cWindowTitle)



/* ----------------------------------------------------------------------------
TelAcWindow:Init()
Inicializa o objeto TelWindow criando a interface gr√°fica para o gestor.
---------------------------------------------------------------------------- */
Method Init() Class TelAcWindow
Local aCoors := {}
Local lCloseButt := !(oAPP:lMdi)

Begin Sequence
	// a fun√ß√£o CursorWait() altera o cursor apenas quando a rotina √© chamada
	// pela primeira vez. Nas chamadas seguintes da fun√ß√£o, o cursor n√£o √©
	// alterado. Chamando CursorArrow() for√ßa a CursorWait() mostrar o cursor
	// de ampulheta sempre.
	CursorArrow()
	CursorWait()
	aCoors := FWGetDialogSize(oMainWnd)
	DEFINE MSDIALOG Self:oDlg TITLE "PE√áAS" ; 
		    FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
          OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL

	Self:oDlg:lMaximized := .T.
		
	Self:oArea := FWLayer():New()
	Self:oArea:Init(Self:oDlg, lCloseButt)
			
	If Self:oArea == Nil
		Return Nil
	EndIf

	// cria a coluna da esquerda
	Self:CreateLeftColumn()
		
	// cria a coluna do meio
	Self:CreateCenterColumn()
		
	// cria a coluna da direita
	//Self:CreateRightColumn()

	CursorArrow()
End Sequence	
Return Nil

/* ----------------------------------------------------------------------------
TelAcWindow:GetVisPanel()
Devolve o painel no qual ser√° mostra a visualiza√ß√£o dos registros.
---------------------------------------------------------------------------- */
Method GetVisPanel() Class TelAcWindow
Return Self:oArea:GetWinPanel(COL_CENTER, WND_VIS)

/* ----------------------------------------------------------------------------
ShowViewPanel()
---------------------------------------------------------------------------- */
Method ShowViewPanel() Class TelAcWindow
Begin Sequence
	// verifica se o painel de visualiza√ß√£o
	// est√° sendo mostrado
	If !Self:oArea:WinOpen(COL_CENTER, WND_VIS)
		// se n√£o, mostra a janela
		Self:oArea:WinChgState(COL_CENTER, WND_VIS)
	EndIf
End Sequence	
Return Nil


/*/{Protheus.doc} ZFAT025Total
//Trazer totais dos clientes por previsao
@author DAC denilso
@since 18/04/2024
@version 1.0
@parametro 		_lCarrega - indica se esta realizando o carregamento de variaveis neste momento n√£o mostra  para fazer atualiza√ß√£o no browse
@return _lRet, Logico
@type Static function
/*/
Static Function ZFAT025Total(_cFilPrev, _cCodPrev,_lCarrega)
//Local _cWhere		:= ""
Local _cAliasPesq	:= GetNextAlias()
Local _aRetCli		:= {} 
Local _lRet 		:= .T.

Default _lCarrega	:= .T.

Begin Sequence
	_aCliRel := {}
	If ! _lCarrega
		_lRet := .F. 
		Break 
	Endif		

	BeginSql Alias _cAliasPesq //Define o nome do alias tempor√°rio 
		SELECT  ZZP.ZZP_CODCLI
				, ZZP.ZZP_LOJCLI 
				, ZZP.ZZP_CNPJCP
				, SA1.A1_NOME
				, ISNULL(SUM(ZZP.ZZP_QTEPED),0) TOTAL_CLI
				, ISNULL(SUM(ZZP.ZZP_QTEFAT),0) TOTAL_FAT 
		FROM %Table:ZZP% ZZP		
		LEFT JOIN %Table:SA1% SA1 
			ON  SA1.%notDel%
			AND SA1.A1_FILIAL 	= %xFilial:SA1%
			AND SA1.A1_COD    	= ZZP.ZZP_CODCLI
			AND SA1.A1_LOJA		= ZZP.ZZP_LOJCLI
		WHERE 	ZZP.%notDel%
			AND ZZP.ZZP_FILIAL  = %Exp:_cFilPrev%
			AND	ZZP.ZZP_CODPRV  = %Exp:_cCodPrev%
     	GROUP BY ZZP.ZZP_CODCLI, ZZP.ZZP_LOJCLI, ZZP.ZZP_CNPJCP, SA1.A1_NOME 
		ORDER BY ZZP.ZZP_CODPRV 
	EndSql
	//			AND ZZP.ZZP_FILIAL  = %xFilial:ZZP%
	If (_cAliasPesq)->(!Eof()) 
		//Verificar os itens dos KITs para saber se tem algun zerado caso tenha n√£o ira utilizar o kit
		While (_cAliasPesq)->(!Eof())
			Aadd(_aRetCli,{	;
							(_cAliasPesq)->ZZP_CODCLI,;
							(_cAliasPesq)->ZZP_LOJCLI,;
							(_cAliasPesq)->ZZP_CNPJCP,;
							(_cAliasPesq)->A1_NOME,;
							(_cAliasPesq)->TOTAL_CLI,;
							(_cAliasPesq)->TOTAL_FAT;
							})
			(_cAliasPesq)->(DbSkip())
		EndDo
	Endif	
End Sequence
If Len(_aRetCli) == 0
	_aRetCli	:= {{	Space(Len(ZZP->ZZP_CODCLI)),;
						Space(Len(ZZP->ZZP_LOJCLI)),;
						Space(Len(ZZP->ZZP_CNPJCP)),;
						Space(Len(SA1->A1_NOME)),;
						0,;
						0;
					}}
EndIf

If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
_aCliRel	:= _aRetCli

Return _aRetCli



//Sub menu Previs„o de Vendas
Method MenuPrev(_nOpc) Class TelAcWindow
Local _cFilPrev 	
Local _cCodPrev

	_cFilPrev := ZZN->ZZN_FILIAL
	_cCodPrev := ZZN->ZZN_CODPRV

	//somente liberado para visualizar e ou incluir 
	//If (_nOpc < 2 .Or. _nOpc > 3) .And. ZZN->ZZN_STATUS $ "F"
	If  _nOpc > 3 .And. ZZN->ZZN_STATUS $ "F"
        MsgStop("Previsao jafaturada", "PREVISAO")
		Return Nil
	Endif 
	If (_nOpc < 1 .Or. _nOpc > 3) .And. ZZN->ZZN_STATUS $ "L"
        MsgStop("Previsao liberada para faturamento", "PREVISAO")
		Return Nil
	Endif 
	//somente liberado para visualizar e ou incluir 
	If (_nOpc < 2 .Or. _nOpc > 3) .And. ZZN->ZZN_STATUS == "C"
        MsgStop("Previsao cancelada", "PREVISAO")
		Return Nil
	Endif 
	//Se for inclus„o
	If _nOpc ==  3
		ZFATF025Inclui()
		//If ZFATF025Inclui()
		//	_oBrowseZZN:Refresh()
		//	_oBrowseZZP:Refresh()
		//Endif
	ElseIf _nOpc ==  1
		U_XZFAT9FT(_cFilPrev, _cCodPrev)
	Else	
		FwMsgRun(,{ |_oSay| U_ZFATF026(_nOpc, _cFilPrev, _cCodPrev , @_oSay ) }, "Selecionando dados", "Aguarde...")  
	Endif
	Self:RefreshPrev(.T.)

Return Nil

// Vaidar quando movimentado cursor e ajustar totalizaÁıes
Method ZFT25Change() Class TelAcWindow
Local _aRelac
	If ValType(Self:_oBrwTotCli) == "O"  //Somente quando estiver ativo tela de totalizaÁ„o
		_aRelac	:= ZFAT025Total(ZZN->ZZN_FILIAL, ZZN->ZZN_CODPRV,  /*_lCarrega*/)
	Endif
Return .T.




/*/{Protheus.doc} ZFATF025Inclui
FunÁ„o para inclus„o de nova previsao
@author 	DAC
@since 		10/04/2024
@version 	undefined
@param 		
@type 		Static function
@project    GAP167  Previsao de Faturamento
@ Obs		
@history    
/*/
Static Function ZFATF025Inclui(  )
Local _cChave		:= ""
Local _lRet			:= .T.
Local _aRet 		:= {}
Local _nPos
Local _oSay

Begin Sequence
	//Parametro encontra na funÁ„o ZFATF019
	If !U_XZFAT9PA(@_aRet)
    	_lRet := .F. 
		Break
	Endif
	
	//Garantir que o processamento seja unico
	_cChave		:= AllTrim(FWCodEmp())+"ZFATF025"
	If !LockByName(_cChave,.T.,.T.)  
		//tentar locar por 10 segundos caso n„o consiga n„o prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 3000 ) // Para o processamento por 3 segundos
			If LockByName("_cChave",.T.,.T.)
				_lRet := .T.
			EndIf
		Next		
		If !_lRet
		    ApMsgStop("J· existe um processamento em execuÁ„o rotina para gerar Previsao, aguarde!", "[ZFATF025]Previs„o Faturamento")
			Break
		EndIf
	EndIf
	//MONTA qUERY
	FwMsgRun(,{ |_oSay| ZFATF025Qry(_aRet, @_oSay ) }, "Processando ", "Aguarde...")  
	//ZFT25Change()
End Sequence
//Desbloquear processamento
If !Empty(_cChave)
	UnLockByName(_cChave,.T.,.T.)
Endif
Return _lRet

//Inclus„o de Nova Previs„o

Static Function ZFATF025Qry( _aRet, _oSay )
Local _cAliasPesq 	:= GetNextAlias()
Local _lRet 		:= .T.
Local _lPergunta	:= .T.
Local _cNumPrev		:= ""
Local _cQuery 		:= ""
Local _cCargaQry	:= ""
Local _cOrderTab	:= ""
Local _cWhere		:= ""
Local _cWhereAll  	:= ""
Local _cJoin		:= ""
Local _cGroup		:= ""
Local _aCampos 		:= {}
Local _nPos 
Local _cCliente 	
Local _cLoja   
Local _cCGC 	
Local _cProduto 	
Local _nVlrVen  	
Local _nVlrUnit  	
Local _nQtVen		

Default _aRet 		:= {}

Begin Sequence 
	If !MsgYesNo("Deseja criar nova Previs„o ?") 
		_lRet := .F. 
		Break 
	Endif 

	If Len(_aRet) == 0 
	    ApMsgStop("Nao informado Parametros para a montagem do Select", "Previs„o Faturamento")
	    _lRet := .F.
		Break
	Endif 

	ZZP->(DbSetOrder(1))
	BeginSql Alias _cAliasPesq //Define o nome do alias tempor·rio 
		SELECT 	MAX(ZZP_CODPRV) AS NPREVISAO
		FROM  	%Table:ZZP% ZZP
		WHERE 	ZZP.%notDel% 
			AND ZZP.ZZP_FILIAL 	= %xFilial:ZZP%
	EndSql
	_cNumPrev := Soma1((_cAliasPesq)->NPREVISAO) 
	If Select(_cAliasPesq) <> 0
		(_cAliasPesq)->(DbCloseArea())
	Endif

	Aadd(_aCampos, "C6_OK")
	Aadd(_aCampos, "C6_FILIAL")
	Aadd(_aCampos, "C5_CLIENTE")
	Aadd(_aCampos, "C5_LOJACLI")
	Aadd(_aCampos, "A1_CGC")
	Aadd(_aCampos, "C6_PRODUTO")
	Aadd(_aCampos, "B1_DESC")
	Aadd(_aCampos, "C6_QTDVEN")
	Aadd(_aCampos, "C6_PRCVEN" )
	Aadd(_aCampos, "C6_PRUNIT")
	Aadd(_aCampos, "SC6.R_E_C_N_O_ AS NREGSC6")
	Aadd(_aCampos, "VRJ_PEDIDO")

	//N„o irei utilizar o Group By pois terei que guardar endereÁos do SC6 para gravar dados
	//Aadd(_aCampos, "SUM(C6_QTDVEN) AS QTDVENDIDA")
	//Aadd(_aCampos, "MAX(C6_PRCVEN) AS PRECOCENDA" )
	//Aadd(_aCampos, "MAX(C6_PRUNIT) AS VLSUNTITARIO")

	//_cGroup := "C6_OK, C6_FILIAL, C5_CLIENTE, C5_LOJACLI, C6_PRODUTO, B1_DESC"

	_cOrderTab := " C5_CLIENTE, C5_LOJACLI, C6_PRODUTO"

	_cQuery := CRLF + "SELECT "		
	For _nPos := 1 To Len(_aCampos)
		_cQuery += CRLF + If(_nPos>1,", ","  ")+_aCampos[_nPos]+ " "
	Next 

	/* N√O ESTA UTILIZANDO
	_cQuery += ", SUM(	CASE "  
	_cQuery += " 		WHEN SC6.C6_CHASSI <> ' ' THEN SC6.C6_QTDVEN "
	_cQuery += "    	ELSE "
	_cQuery += "			0 "	 
	_cQuery += "    END	) OVER (ORDER BY SC6.C6_PRODUTO) AS QTD_CHASSI "
	*/
	//aCRESCENTAR CLAUSULA wHERE
	_cWhere := CRLF + " AND SC6.C6_XFILPVR = ' ' "
	_cWhere += CRLF + " AND SC6.C6_XCODPVR = ' ' "

	//Se enviado esta variavel despresara a clausula where na funcionalidade substituindo por esta
	_cWhereAll := ""
	//Caso deseje incluir na queri o Join
	//_cJoin := ZFATF026Chassi(/*_cProduto*/)
	_cCargaQry := U_XZFAT9QY( _cQuery, _cOrderTab, _aRet, _cWhere, /*_cWhereAll*/, _cJoin, _cGroup)
	If Empty(_cCargaQry)
	    ApMsgStop("Problemas na montagem do Select", "Previsao Faturamento")
	    _lRet := .F.
		Break
	Endif
	//Realizar o Select
	_oSay:SetText("Aguarde Selecionando registros ... Hora: "+Time() )
	ProcessMessage()

	TcQuery _cCargaQry new alias (_cAliasPesq)

    (_cAliasPesq)->(DbGoTop())
	If (_cAliasPesq)->(Eof())
	    ApMsgStop("N„o existem registros para os parametros informados", "Previs„o Faturamento")
	    _lRet := .F.
		Break
	Endif

	_oSay:SetText("Aguarde Montando Previs„o ... Hora: "+Time() )
	ProcessMessage()
	Begin Transaction
		If !RecLock("ZZN",.T.) 
			_lRet := .F.
			Disarmtransaction()
			Return _lRet			 
		Endif
		//Gravar Previs„o CabeÁalho
		ZZN->ZZN_FILIAL := FwXFilial("ZZN") 
		ZZN->ZZN_CODPRV := _cNumPrev
		ZZN->ZZN_STATUS := "A"
		ZZN->ZZN_DTINC  := Date()
		ZZN->ZZN_USUINC := RetCodUsr()
		ZZN->(MsUnlock())
		//Gravar Previs„o Itens
    	While (_cAliasPesq)->(!Eof()) 
			_cCliente 	:= (_cAliasPesq)->C5_CLIENTE
			_cLoja    	:= (_cAliasPesq)->C5_LOJACLI
			_cCGC 		:= (_cAliasPesq)->A1_CGC
			_cProduto 	:= (_cAliasPesq)->C6_PRODUTO  
			_nVlrVen  	:= (_cAliasPesq)->C6_PRCVEN
			_nVlrUnit  	:= (_cAliasPesq)->C6_PRUNIT

			_nQtVen		:= 0
			While (_cAliasPesq)->(!Eof()) .And.  _cCliente 	== (_cAliasPesq)->C5_CLIENTE .And. _cLoja == (_cAliasPesq)->C5_LOJACLI .And. _cProduto == (_cAliasPesq)->C6_PRODUTO
				SC6->(DbGoto((_cAliasPesq)->NREGSC6))
				_cMens := ""
				If !Empty(SC6->C6_XCODPVR)
					//Somente perguntar uma vez 
					If _lPergunta .And. !MsgYesNo("Existem registros com Previs„o "+SC6->C6_XCODPVR+" deseje encerralas ?") 
						_lRet := .F. 
						EXIT 
					Endif
					_lPergunta := .F.
					_cMens 	:= "Previs„o Faturamento"+SC6->C6_XFILPVR+"-"+SC6->C6_XCODPVR+" Encerrada, substituida pela "+FwXFilial("ZZP")+"-"+_cNumPrev+", Usuario "+RetCodUsr()+" em "+Date() 	
					_cMens 	+= CRLF + "Referente ao Pedido "+SC6->C6_NUM
				Endif 
				If !RecLock("SC6",.F.)
					_lRet := .F.
					Exit 
				Endif 
				SC6->C6_XFILPVR := FwXFilial("ZZP")
				SC6->C6_XCODPVR := _cNumPrev
				SC6->C6_XDTPVR 	:= Date()
				SC6->C6_XUSUPVR	:= RetCodUsr()
				If !Empty(_cMens)
					SC6->C6_MOPC    := AllTrim(SC6->C6_MOPC) + CRLF + Upper(_cMens) + CRLF 
				Endif
				_nQtVen		+= SC6->C6_QTDVEN
				(_cAliasPesq)->(DbSkip())
			EndDo 	
			//N„o encontrou nenhum
			If _nQtVen == 0
				Loop
			Endif
			If !_lRet .Or.  !RecLock("ZZP",.T.) 
				_lRet := .F.
				Exit 
			Endif
			//Gravar Previs„o 
			ZZP->ZZP_FILIAL := FwXFilial("ZZP") 
			ZZP->ZZP_CODPRV := _cNumPrev
			ZZP->ZZP_CODCLI := _cCliente
			ZZP->ZZP_LOJCLI := _cLoja
			ZZP->ZZP_CNPJCP := _cCGC
			ZZP->ZZP_CODPRD := _cProduto
			ZZP->ZZP_QTEPED := _nQtVen
			ZZP->ZZP_CHSDIS := 0 //CHASSI QTDE
			ZZP->ZZP_QTEDIS := 0 
			ZZP->ZZP_QTELIB := 0 //ZZP->ZZP_QTEPED - ZZP->ZZP_QTEDIS
			ZZP->ZZP_QTEFAT := 0
			ZZP->ZZP_VLRTAB := _nVlrVen
			ZZP->ZZP_TOTLIB := If(ZZP->ZZP_QTELIB > 0, _nVlrVen * ZZP->ZZP_QTELIB, 0)
			ZZP->ZZP_OBS	:= 	AllTrim(ZZP->ZZP_OBS) + CRLF + Upper(_cMens)  
			ZZP->ZZP_STATUS := "A"
			ZZP->ZZP_DTINC  := Date()
			ZZP->ZZP_USUINC := RetCodUsr()
			ZZP->ZZP_DTALT  := Date()
			ZZP->ZZP_USUALT := RetCodUsr()
			ZZP->(MsUnlock())
		EndDo
		If !_lRet 
			Disarmtransaction()
		Endif
	End Transaction

End Sequence 
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif
If _lRet
    ApMsgStop("Gerada previsao "+_cNumPrev, "Previs„o Faturamento")
Endif 

Return _lRet



//Verifica se existem  chassis ver funÁ„o [fAtuPeds ZFATF018]
User Function XZFT25CH(_cProduto, _cLocal)
Local _cQuery 		:= ""

Default _cProduto 	:= "" 
Default _cLocal 	:= ""

	If Empty(_cProduto)
		_cQuery := "LEFT JOIN ( "			+CRLF
	Endif	
	_cQuery += "SELECT A.* "				+CRLF
	_cQuery += "FROM ( SELECT " 			+CRLF
	_cQuery += "	VV1.VV1_FILIAL, "		+CRLF	
	_cQuery += "	SBF.BF_PRODUTO, "		+CRLF
	_cQuery += "	VV1.VV1_CHASSI, "		+CRLF
	_cQuery += "	VV1.VV1_CODMAR, "		+CRLF
	_cQuery += "	VV1.VV1_MODVEI, "		+CRLF
	_cQuery += "	VV1.VV1_SEGMOD, "		+CRLF
	_cQuery += "	VV1.VV1_FABMOD, "		+CRLF
	_cQuery += "	VV1.VV1_CORVEI, "		+CRLF
	_cQuery += "	SBF.BF_LOCAL,   "		+CRLF
	_cQuery += "	SBF.BF_LOCALIZ, "		+CRLF
	_cQuery += "	SBF.BF_QUANT,   "		+CRLF
	_cQuery += "    SUM(SBF.BF_QUANT) OVER (ORDER BY BF_PRODUTO) AS QTDETOT, " 	+CRLF
	_cQuery += " 	(	SELECT MAX(SDB.DB_NUMSEQ) " 	+CRLF
	_cQuery += "  		FROM SDB010 SDB "	+CRLF
	_cQuery += "  		WHERE  SDB.DB_FILIAL       = '"+FwXFilial("SDB") +"' "	+CRLF
	_cQuery += "     		AND SDB.DB_ESTORNO      = ' ' "						+CRLF
	_cQuery += "     		AND SDB.DB_ATUEST       = 'S' "						+CRLF
	_cQuery += "     		AND SDB.DB_LOCAL        = SBF.BF_LOCAL   "			+CRLF
	_cQuery += "     		AND SDB.DB_LOCALIZ      = SBF.BF_LOCALIZ "			+CRLF
	_cQuery += "     		AND SDB.DB_NUMSERI      = SBF.BF_NUMSERI "			+CRLF
	_cQuery += "     		AND SDB.DB_PRODUTO      = SBF.BF_PRODUTO "			+CRLF
	_cQuery += "     		AND SDB.D_E_L_E_T_      = ' ') DB_NUMSEQ, "			+CRLF
	_cQuery += "     		NVL(	(	SELECT VB0_DATDES  "					+CRLF
	_cQuery += "     					FROM VB0010  VB0   "					+CRLF	
	_cQuery += "          				WHERE VB0.VB0_DATBLO||VB0.VB0_HORBLO = ( "	+CRLF
	_cQuery += "                                             					SELECT max(VB0A.VB0_DATBLO||VB0A.VB0_HORBLO) as DATBLOQ  " +CRLF
	_cQuery += "                                             					FROM VB0010  VB0A "	+CRLF
	_cQuery += "                                                				WHERE VB0A.VB0_FILIAL = VB0.VB0_FILIAL   "	+CRLF
	_cQuery += "                                                  					AND VB0A.VB0_CHAINT = VB0.VB0_CHAINT " 	+CRLF
	_cQuery += "                                                  					AND VB0A.D_E_L_E_T_ = ' ')           "	+CRLF
	_cQuery += "         															AND VB0.VB0_FILIAL = '"+FwXFilial("VB0") +"' "	+CRLF 
	_cQuery += "         															AND VB0.VB0_CHAINT = VV1.VV1_CHAINT  "	+CRLF
	_cQuery += "         															AND VB0.D_E_L_E_T_ = ' '             "	+CRLF
	_cQuery += "         														),'99999999' "	+CRLF
	_cQuery += "         				) AS VB0_DATDES "						+CRLF
	_cQuery += "		FROM VV1010 VV1 "										+CRLF
	_cQuery += "		INNER JOIN SBF010 SBF "									+CRLF
	_cQuery += "  			ON  SBF.BF_FILIAL  = '"+FwXFilial("SBF") +"' " 		+CRLF
	_cQuery += "  			AND SBF.BF_NUMSERI = VV1.VV1_CHASSI " 				+CRLF
	_cQuery += "  			AND SBF.D_E_L_E_T_ = VV1.D_E_L_E_T_ "				+CRLF
	_cQuery += "  			AND SBF.BF_QUANT   > 0              "				+CRLF
	_cQuery += "  			AND SBF.BF_EMPENHO = 0              "				+CRLF
	_cQuery += "  			AND SBF.BF_LOCAL   = 'VN '          "				+CRLF
	If !Empty(_cProduto)
		_cQuery += "  		AND SBF.BF_PRODUTO = '" +_cProduto+"' "				+CRLF
	Endif	
	If !Empty(_cLocal)
    	cQuery += CrLf + "  AND SBF.BF_LOCAL   = '" +_cLocal+ "' "				+CRLF
	Endif	

	_cQuery += "		WHERE   VV1.VV1_FILIAL      = '"+FwXFilial("VV1") +"' " +CRLF	
	_cQuery += "			AND VV1.VV1_SITVEI      = '0' 		"				+CRLF
	_cQuery += "			AND VV1.VV1_IMOBI       = '0' 		"				+CRLF
	_cQuery += "		AND VV1.D_E_L_E_T_      = ' '			"				+CRLF
	_cQuery += "		) A 									"				+CRLF
	_cQuery += "	WHERE A.VB0_DATDES > '        ' 			"				+CRLF
	//_cQuery += "	ORDER BY A.VV1_FILIAL,A.BF_PRODUTO,A.DB_NUMSEQ,A.VV1_CHASSI "
	If Empty(_cProduto)
		_cQuery += "			) 	SQLPRD 							"			+CRLF
		_cQuery += "				ON SQLPRD.BF_PRODUTO = SC6.C6_PRODUTO "  	+CRLF
	Endif
Return _cQuery

