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
	ZFAT025Total( ZZN->ZZN_FILIAL, ZZN->ZZN_CODPRV,  /*_lCarrega*/)
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
	_oColumn:SetTitle("Total Faturamento R$") 
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
Local _nRegZZN

	_cFilPrev := ZZN->ZZN_FILIAL
	_cCodPrev := ZZN->ZZN_CODPRV

	//somente liberado para visualizar e ou incluir 
	//If (_nOpc < 2 .Or. _nOpc > 3) .And. ZZN->ZZN_STATUS $ "F"
	If  (_nOpc < 2 .Or. _nOpc > 3) .And. ZZN->ZZN_STATUS $ "F"
        MsgStop("Previsao jafaturada", "PREVISAO")
		Return Nil
	Endif
	 
	If _nOpc == 1 .And. !ZZN->ZZN_STATUS $ "L"
        MsgStop("Previsao tem que possuir status liberada para faturamento", "PREVISAO")
		Return Nil
	Endif 
	
	//somente liberado para visualizar e ou incluir 
	If (_nOpc < 2 .Or. _nOpc > 3) .And. ZZN->ZZN_STATUS == "C"
        MsgStop("Previsao cancelada", "PREVISAO")
		Return Nil
	Endif 
	//Se for inclus„o
	If _nOpc ==  3
		_nRegZZN := 0
		ZFATF025Inclui(@_nRegZZN)
		//If ValType(_nRegZZN) == "N"
		//	ZZN->(DbGoto(_nRegZZN))
		//	_cFilPrev := ZZN->ZZN_FILIAL
		//	_cCodPrev := ZZN->ZZN_CODPRV
		//Endif	
		//_nRegZZN := ZZN->(Recno())
		Self:_oBrowseZZN:GoTop(.T.)
		Self:_oBrowseZZN:Refresh(.T.)
		//ZZN->(DbSetOrder(1))
		//ZZN->(DbSeek(_cFilPrev+_cCodPrev))
		ZFAT025Total( ZZN->ZZN_FILIAL, ZZN->ZZN_CODPRV,  /*_lCarrega*/)
		//If ZFATF025Inclui()
		//	_oBrowseZZN:Refresh()
		//	_oBrowseZZP:Refresh()
		//Endif
	ElseIf _nOpc ==  1
		FwMsgRun(,{ |_oSay| U_XZFT19FT(_cFilPrev, _cCodPrev, @_oSay) }, "Selecionando dados", "Aguarde...")  
	Else	
		FwMsgRun(,{ |_oSay| U_ZFATF026(_nOpc, _cFilPrev, _cCodPrev , @_oSay ) }, "Selecionando dados", "Aguarde...")  
	Endif
	Self:RefreshPrev(.T.)

Return Nil

// Vaidar quando movimentado cursor e ajustar totalizaÁıes
Method ZFT25Change() Class TelAcWindow
	If ValType(Self:_oBrwTotCli) == "O"  //Somente quando estiver ativo tela de totalizaÁ„o
		ZFAT025Total(ZZN->ZZN_FILIAL, ZZN->ZZN_CODPRV,  /*_lCarrega*/)
		Self:RefreshPrev(.T.)
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
Static Function ZFATF025Inclui( _nRegZZN  )
Local _cChave		:= ""
Local _lRet			:= .T.
Local _aRet 		:= {}
Local _nPos
Local _oSay

Begin Sequence
	//Parametro encontra na funÁ„o ZFATF019
	If !U_XZFT19PA(@_aRet)
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
	FwMsgRun(,{ |_oSay| ZFATF025Qry(_aRet, @_nRegZZN, @_oSay ) }, "Processando ", "Aguarde...")  
	//ZFT25Change()
End Sequence
//Desbloquear processamento
If !Empty(_cChave)
	UnLockByName(_cChave,.T.,.T.)
Endif
Return _lRet

//Inclus„o de Nova Previs„o

Static Function ZFATF025Qry( _aRet, _nRegZZN, _oSay )
Local _cAliasPesq 	:= GetNextAlias()
Local _lRet 		:= .T.
//Local _lPergunta	:= .T.
Local _cNumPrev		:= ""
Local _cQuery 		:= ""
Local _cWhere 		:= ""
Local _cJoin 		:= ""
Local _aMsg 		:= {}

Local _nPos 
Local _cCliente 	
Local _cLoja   
Local _cCGC 	
Local _cProduto 	
Local _nVlrVen  	
Local _nVlrUnit  	
Local _nQtVen		
Local _cModelo
Local _cFabAno 
Local _aRegSC6
Local _nQtdeReg
Local _nQtdeLidos
Local _aSelect
Local _cSelect
Local _cOrderTab  

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
		SELECT 	MAX(ZZN_CODPRV) AS NPREVISAO
		FROM  	%Table:ZZN% ZZN
		WHERE 	ZZN.%notDel% 
			AND ZZN.ZZN_FILIAL 	= %xFilial:ZZN%
	EndSql
	_cNumPrev := Soma1((_cAliasPesq)->NPREVISAO) 
	If Select(_cAliasPesq) <> 0
		(_cAliasPesq)->(DbCloseArea())
	Endif
	
	//pREPARAR CAMPOS DO sELECT
	_aSelect	:= {}		    
	Aadd(_aSelect,"C6_OK")
	Aadd(_aSelect,"C6_FILIAL" )
	Aadd(_aSelect,"C6_CLI")
	Aadd(_aSelect,"C6_LOJA")
	Aadd(_aSelect,"A1_CGC")
	Aadd(_aSelect,"C6_PRODUTO")
	Aadd(_aSelect,"B1_DESC")
	Aadd(_aSelect,"C6_QTDVEN")
	Aadd(_aSelect,"C6_PRCVEN")
	Aadd(_aSelect,"C6_PRUNIT")
	Aadd(_aSelect,"C6_PEDCLI")
	Aadd(_aSelect,"C6_ITEM")
	Aadd(_aSelect,"C6_CHASSI")
	Aadd(_aSelect,"VRK_MODVEI")
	Aadd(_aSelect,"VRK_FABMOD")
	Aadd(_aSelect,"VRK_VALTAB")
	Aadd(_aSelect,"VRK_CODMAR")
	Aadd(_aSelect,"VV2_DESMOD")
	Aadd(_aSelect,"VRJ_PEDIDO")
	Aadd(_aSelect,"VRK_MODVEI")
	Aadd(_aSelect,"VRK_CORINT")
	Aadd(_aSelect,"VRK_COREXT")
	Aadd(_aSelect,"VRK_SEGMOD")
	Aadd(_aSelect,"VVX_DESSEG")

	Aadd(_aSelect,"VRK_VALTAB")  	//Valor de Tabela          
	Aadd(_aSelect,"VRK_VALPRE") 	//Valor Pretendido         
	Aadd(_aSelect,"VRK_VALMOV") 	//VALOR DO MOVIMENTO
	Aadd(_aSelect,"VRK_XBASST") 	//Valor Base ICMS ST	
	Aadd(_aSelect,"VRK_VALVDA") 	//vALOR DA vENDA          

	Aadd(_aSelect,"VE1_DESMAR")

	_cSelect := CRLF +" SELECT "
	For _nPos := 1 To Len(_aSelect)
		_cSelect += CRLF +If(_nPos > 1,", "," ")+_aSelect[_nPos]+" "
	Next
	_cSelect += CRLF +", SC6.R_E_C_N_O_ AS NREGSC6 "
	_cSelect += CRLF +", VRK.R_E_C_N_O_ AS NREGVRK "
	
	/*
    _cQuery += CRLF + " WITH PEDIDOS_FAT AS ( 	SELECT "
    _cQuery += CRLF + " 						SC6.C6_OK " 
    _cQuery += CRLF + " 						, SC6.C6_FILIAL "
    _cQuery += CRLF + " 						, SC6.C6_CLI "
    _cQuery += CRLF + " 						, SC6.C6_LOJA "
    _cQuery += CRLF + " 						, SA1.A1_CGC "
    _cQuery += CRLF + " 						, SC6.C6_PRODUTO "
    _cQuery += CRLF + " 						, SB1.B1_DESC "
    _cQuery += CRLF + " 						, SC6.C6_QTDVEN "
    _cQuery += CRLF + " 						, SC6.C6_PRCVEN "
    _cQuery += CRLF + " 						, SC6.C6_PRUNIT "
    _cQuery += CRLF + " 						, SC6.C6_PEDCLI "
    _cQuery += CRLF + " 						, SC6.C6_ITEM "
    _cQuery += CRLF + " 						, SC6.C6_XMODVEI "
    _cQuery += CRLF + " 						, SC6.C6_XFABMOD "
	_cQuery += CRLF + " 						, SC6.C6_XPRCTAB "
	_cQuery += CRLF + " 						, SC6.C6_CHASSI "
    _cQuery += CRLF + " 						, SC6.R_E_C_N_O_ AS NREGSC6  "
	_cQuery += CRLF + " 						, VV2.VV2_CODMAR "
	_cQuery += CRLF + " 						, VV2.VV2_DESMOD "
    _cQuery += CRLF +  "        FROM  " + RetSqlName("SC6") + " SC6 " 
    _cQuery += CRLF + "         JOIN " + RetSqlName("SC5") + " SC5 
    _cQuery += CRLF + "             ON  SC5.C5_FILIAL  = '" + FwxFilial("SC5") + "' "
    _cQuery += CRLF + "             AND SC5.C5_NUM     = SC6.C6_NUM "
    _cQuery += CRLF + "             AND SC5.C5_CLIENTE = SC6.C6_CLI "
    _cQuery += CRLF + "             AND SC5.C5_LOJACLI = SC6.C6_LOJA "
    _cQuery += CRLF + "             AND SC5.D_E_L_E_T_ = ' ' "

    _cQuery += CRLF + "         JOIN " + RetSqlName("VV2") + "  VV2 "
    _cQuery += CRLF + "             ON  VV2.VV2_FILIAL  = '" + FwxFilial("VV2") + "' "
    _cQuery += CRLF + "             AND VV2.VV2_PRODUT  = SC6.C6_PRODUTO
    _cQuery += CRLF + "             and VV2.VV2_OPCION  BETWEEN '" + _aRet[16] + "' AND '" + _aRet[17] + "' "
    _cQuery += CRLF + "             AND VV2.VV2_CORINT  BETWEEN '" + _aRet[20] + "' AND '" + _aRet[21] + "' "
    _cQuery += CRLF + "             AND VV2.VV2_COREXT  BETWEEN '" + _aRet[22] + "' AND '" + _aRet[23] + "' " 
    _cQuery += CRLF + "             AND VV2.D_E_L_E_T_  = ' ' "

    _cQuery += CRLF + "         JOIN " + RetSqlName("SF4") + " SF4 "
    _cQuery += CRLF + "             ON  SF4.F4_FILIAL  =  '" + FwxFilial("SF4") + "' "
    _cQuery += CRLF + "             AND SF4.F4_CODIGO  = SC6.C6_TES "
    _cQuery += CRLF + "             AND SF4.F4_DUPLIC  = 'S' "
    _cQuery += CRLF + "             AND SF4.D_E_L_E_T_ = ' ' "

    _cQuery += CRLF + "         JOIN " + RetSqlName("SA1") + " SA1 "
    _cQuery += CRLF + "             ON  SA1.A1_FILIAL  = '" + FwxFilial("SA1") + "' "
    _cQuery += CRLF + "             AND SA1.A1_COD     = SC6.C6_CLI "
    _cQuery += CRLF + "             AND SA1.A1_LOJA    = SC6.C6_LOJA "
    _cQuery += CRLF + "             AND SA1.D_E_L_E_T_ = ' ' "

    _cQuery += CRLF + "         JOIN " + RetSqlName("SB1") + " SB1 "
    _cQuery += CRLF + "             ON  SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
    _cQuery += CRLF + "             AND SB1.B1_COD     = SC6.C6_PRODUTO "
    _cQuery += CRLF + "             AND SB1.B1_GRUPO   = 'VEIA' "
    _cQuery += CRLF + "             AND SB1.D_E_L_E_T_ = ' ' "

    _cQuery += CRLF + "     WHERE SC6.C6_FILIAL	= '" + xFilial("SC6") + "' "  
    _cQuery += CRLF + "         AND SC6.C6_CLI     	BETWEEN '" +      _aRet[01]  + "' AND '" +      _aRet[03]  + "' "
    _cQuery += CRLF + "         AND SC6.C6_LOJA    	BETWEEN '" +      _aRet[02]  + "' AND '" +      _aRet[04]  + "' "
    _cQuery += CRLF + "         AND SC6.C6_PRODUTO 	BETWEEN '" +      _aRet[05]  + "' AND '" +      _aRet[06]  + "' "
    _cQuery += CRLF + "         AND SC6.C6_PEDCLI  	BETWEEN '" +      _aRet[08]  + "' AND '" +      _aRet[09]  + "' "
    //_cQuery += CRLF + "         AND SC6.C6_XCODMAR 	BETWEEN '" +      _aRet[10]  + "' AND '" +      _aRet[11]  + "' "
    _cQuery += CRLF + "         AND VV2.VV2_CODMAR 	BETWEEN '" +      _aRet[10]  + "' AND '" +      _aRet[11]  + "' "
    _cQuery += CRLF + "         AND SC6.C6_XGRPMOD 	BETWEEN '" +      _aRet[12]  + "' AND '" +      _aRet[13]  + "' "
    _cQuery += CRLF + "         AND SC6.C6_XMODVEI 	BETWEEN '" +      _aRet[14]  + "' AND '" +      _aRet[15]  + "' "
    //_cQuery += CRLF +     "     AND SC6.C6_XSEGMOD   BETWEEN '" +      _aRet[16]  + "' AND '" +      _aRet[17]  + "' "
 
	//MUDAR PARA VRK DAC***
    _cQuery += CRLF + "         AND SC6.C6_XFABMOD 	BETWEEN '" +      _aRet[18]  + "' AND '" +      _aRet[19]  + "' "

    //_cQuery += CRLF +     "     AND SC6.C6_XCORINT   BETWEEN '" +      _aRet[20]  + "' AND '" +      _aRet[21]  + "' "
    //_cQuery += CRLF +     "     AND SC6.C6_XCOREXT   BETWEEN '" +      _aRet[22]  + "' AND '" +      _aRet[23]  + "' "
    _cQuery += CRLF + "         AND SC5.C5_EMISSAO 	BETWEEN '" + DtoS(_aRet[24]) + "' AND '" + DtoS(_aRet[25]) + "' "
    _cQuery += CRLF + "         AND SC6.C6_QTDVEN 	> SC6.C6_QTDENT "
    _cQuery += CRLF + "         AND SC5.C5_TIPO   	= 'N' "
    _cQuery += CRLF + "         AND SC6.C6_PEDCLI  	<> ' ' "
    _cQuery += CRLF + "         AND SC6.C6_NOTA    	= '" + Space(9) + "' "
    _cQuery += CRLF + "         AND SC6.C6_BLQ     	= ' ' "
	_cQuery += CRLF + " 		AND SC6.C6_XFILPVR 	= ' ' "
	_cQuery += CRLF + " 		AND SC6.C6_XCODPVR 	= ' ' "
	//AtualizaÁ„o realizada pela Totvs, acrescentada na lÛgica DAC 14/05/2024
	_cQuery += CRLF + " 	    AND SC6.C6_CHASSI    = ' ' "  //<=====
	_cQuery += CRLF + " 		AND SC6.D_E_L_E_T_ 	= ' ' "
    _cQuery += CRLF + "          )"       

    _cQuery += CRLF + " SELECT PEDIDOS_FAT.* "
    _cQuery += CRLF +"		, VRJ.VRJ_PEDIDO "
	_cQuery += CRLF + " 	, VRK.VRK_MODVEI "
	_cQuery += CRLF + " 	, VRK.VRK_FABMOD "
 	_cQuery += CRLF + " 	, VRK.VRK_CODMAR "
 	_cQuery += CRLF + " 	, VRK.VRK_CORINT "
 	_cQuery += CRLF + " 	, VRK.VRK_COREXT "
 	_cQuery += CRLF + " 	, VRK.VRK_SEGMOD "
 	_cQuery += CRLF + " 	, VVX.VVX_DESSEG "
 	_cQuery += CRLF + " 	, VE1.VE1_DESMAR "
   
    _cQuery += CRLF + " FROM PEDIDOS_FAT  "    

    _cQuery += CRLF + " JOIN " + RetSqlName("VRJ") + " VRJ "
    _cQuery += CRLF + "     ON  VRJ.VRJ_FILIAL = '" + FWxFilial("VRJ") + "' "
    _cQuery += CRLF + "     AND VRJ.VRJ_PEDCOM = PEDIDOS_FAT.C6_PEDCLI "
    _cQuery += CRLF + "     AND VRJ.VRJ_STATUS in ('A','F') "
    _cQuery += CRLF + "     AND VRJ.D_E_L_E_T_ = ' ' "

    _cQuery += CRLF + " JOIN " + RetSqlName("VRK") + " VRK "
    _cQuery += CRLF + "     ON  VRK.VRK_FILIAL = '" + FWxFilial("VRK") + "' "
    _cQuery += CRLF + "     AND VRK.VRK_PEDIDO = VRJ.VRJ_PEDIDO "
    _cQuery += CRLF + "     AND VRK.VRK_ITEPED = LPad(PEDIDOS_FAT.C6_ITEM,3,'0') "
	//AtualizaÁ„o realizada pela Totvs, acrescentada na lÛgica DAC 14/05/2024
    _cQuery += CRLF + "     AND VRK.VRK_CHASSI = PEDIDOS_FAT.C6_CHASSI "
    _cQuery += CRLF + "     AND VRK.VRK_ITETRA = ' ' "
    _cQuery += CRLF + "     AND VRK.D_E_L_E_T_ = ' ' "

    _cQuery += CRLF + " LEFT JOIN " + RetSqlName("VE1") + " VE1  "
    _cQuery += CRLF + "      ON  VE1.VE1_FILIAL  = '" + xFilial("VE1") + "'  "
    _cQuery += CRLF + "      AND VE1.VE1_CODMAR  = VRK.VRK_CODMAR   "
    _cQuery += CRLF + "      AND VE1.D_E_L_E_T_  = ' ' "

    _cQuery += CRLF + " LEFT JOIN " + RetSqlName("VVX") + " VVX  "
    _cQuery += CRLF + "      ON  VVX.VVX_FILIAL  = '" + xFilial("VVX") + "' "
    _cQuery += CRLF + "      AND VVX.VVX_CODMAR  = VRK.VRK_CODMAR "
    _cQuery += CRLF + "      AND VVX.VVX_SEGMOD  = VRK.VRK_SEGMOD "
    _cQuery += CRLF + "      AND VVX.D_E_L_E_T_  = ' ' "

	_cQuery += CRLF + " ORDER BY  C6_CLI, C6_LOJA, C6_PRODUTO, C6_XMODVEI, C6_XFABMOD
*/    

	//Tem que estar sem chassis e sem previs„o
	_cWhere := CRLF + " 		AND SC6.C6_XFILPVR 	= ' ' "
	_cWhere += CRLF + " 		AND SC6.C6_XCODPVR 	= ' ' "
	_cWhere += CRLF + " 	    AND SC6.C6_CHASSI    = ' ' "  
	//Ordem do Select 
	_cOrderTab   := "SC6.C6_FILIAL, SC6.C6_PEDCLI, SC6.C6_ITEM, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC6.C6_PRODUTO"

	_cQuery := U_XZFT19QY(_cSelect, _cOrderTab, _aRet, _cWhere, /*_cWhereAll*/, _cJoin, /*_cGroup*/)

	//Realizar o Select
	_oSay:SetText("Aguarde Selecionando registros ... Hora: "+Time() )
	ProcessMessage()

	TcQuery _cQuery new alias (_cAliasPesq)

	DbSelectArea(_cAliasPesq)
    (_cAliasPesq)->(DbGoTop())
	If (_cAliasPesq)->(Eof())
	    ApMsgStop("N„o existem registros para os parametros informados", "Previs„o Faturamento")
	    _lRet := .F.
		Break
	Endif
	Count To _nQtdeReg	  //Conta quantos chassis est„o disponiveis
    (_cAliasPesq)->(DbGoTop())

	_oSay:SetText("Aguarde Montando Previs„o de "+StrZero(_nQtdeReg,6)+" registros ... Hora: "+Time() )
	ProcessMessage()
	//Gravar Previs„o Itens
    _nRegZZN 	:= 0
	_nQtdeLidos	:= 0
	While (_cAliasPesq)->(!Eof()) 
		_cCliente 	:= (_cAliasPesq)->C6_CLI
		_cLoja    	:= (_cAliasPesq)->C6_LOJA
		_cCGC 		:= (_cAliasPesq)->A1_CGC
		_cProduto 	:= (_cAliasPesq)->C6_PRODUTO  
		_nVlrVen  	:= (_cAliasPesq)->VRK_VALTAB	//C6_XPRCTAB   //C6_PRCVEN
		_nVlrUnit  	:= (_cAliasPesq)->C6_PRUNIT
		_cModelo 	:= (_cAliasPesq)->VRK_MODVEI //iF( !Empty((_cAliasPesq)->C6_XMODVEI), (_cAliasPesq)->C6_XMODVEI, (_cAliasPesq)->VRK_MODVEI)
		_cFabAno 	:= (_cAliasPesq)->VRK_FABMOD //If( !Empty((_cAliasPesq)->C6_XFABMOD), (_cAliasPesq)->C6_XFABMOD, (_cAliasPesq)->VRK_FABMOD)
		_nQtVen		:= 0
		_aRegSC6	:= {}
		While (_cAliasPesq)->(!Eof()) .And. _cCliente 	== (_cAliasPesq)->C6_CLI 		.And. ;
											_cLoja 		== (_cAliasPesq)->C6_LOJA 		.And. ;
											_cProduto 	== (_cAliasPesq)->C6_PRODUTO	.And. ;
											_cModelo 	== (_cAliasPesq)->VRK_MODVEI	.And. ;
											_cFabAno 	== (_cAliasPesq)->VRK_FABMOD
			_nQtdeLidos ++
			_oSay:SetText("Aguarde Montando Previs„o lidos "+StrZero(_nQtdeLidos,6)+" de "+StrZero(_nQtdeReg,6)+" registros ... ")
			ProcessMessage()

			SC6->(DbGoto((_cAliasPesq)->NREGSC6))
			VRK->(DbGoto((_cAliasPesq)->NREGVRK))
			_cMens := ""
			//somente incluir se tiver quantidade
			If SC6->C6_QTDVEN <= 0
				(_cAliasPesq)->(DbSkip())
				Loop	
			Endif	
			//N„o permitir incus„o de previsao com chassi
			If !Empty(SC6->C6_CHASSI)
				_cMens += " Pedido "+SC6->C6_NUM+" Produto "+AllTrim(SC6->C6_PRODUTO)+" com numero de Chassim "+AllTrim(SC6->C6_CHASSI)+ " nao sera utilizado na Previsao "+SC6->C6_XCODPVR
				Aadd(_aMsg,_cMens)
				(_cAliasPesq)->(DbSkip())
				Loop	
			Endif	
			//Pedido ja posui uma previsao verificar se o usuario deseja trocar
			If !Empty(SC6->C6_XCODPVR)
				if SC6->C6_XCODPVR == _cNumPrev
					(_cAliasPesq)->(DbSkip())
					Loop
				Endif 
			Endif 
			_nQtVen			+= SC6->C6_QTDVEN
			Aadd(_aRegSC6, (_cAliasPesq)->NREGSC6)
			//Atualizar descriÁıes
            If SC6->(RecLock("SC6",.F.))
            	SC6->C6_XCODMAR	:= (_cAliasPesq)->VRK_CODMAR  
            	SC6->C6_XDESMAR	:= (_cAliasPesq)->VE1_DESMAR
            	SC6->C6_XCORINT	:= (_cAliasPesq)->VRK_CORINT
            	SC6->C6_XCOREXT	:= (_cAliasPesq)->VRK_COREXT 
            	SC6->C6_XMODVEI	:= (_cAliasPesq)->VRK_MODVEI
            	SC6->C6_XDESMOD	:= (_cAliasPesq)->VV2_DESMOD
            	SC6->C6_XSEGMOD	:= (_cAliasPesq)->VRK_SEGMOD 
            	SC6->C6_XDESSEG	:= (_cAliasPesq)->VVX_DESSEG
            	SC6->C6_XFABMOD	:= (_cAliasPesq)->VRK_FABMOD
				SC6->C6_XPRCTAB := (_cAliasPesq)->VRK_VALTAB	//Valor de Tabela          
				SC6->C6_XVLRPRD := (_cAliasPesq)->VRK_VALPRE  	//Valor Pretendido         
				SC6->C6_XVLRMVT := (_cAliasPesq)->VRK_VALMOV  	//VALOR DO MOVIMENTO
				SC6->C6_XBASST 	:= (_cAliasPesq)->VRK_XBASST	//Valor Base ICMS ST	
        		SC6->C6_XVLRVDA  = (_cAliasPesq)->VRK_VALVDA  	//vALOR DA vENDA          


            	SC6->(MsUnLock())
				(_cAliasPesq)->(DbSkip())
			Endif
		EndDo 	

		//If !_lRet  
		//Endif
		//N„o encontrou nenhum
		If _nQtVen == 0 .Or. Len(_aRegSC6) == 0
			Loop
		Endif

		//Begin Transaction
		//Criar CabeÁalho
		If _nRegZZN == 0
			If !RecLock("ZZN",.T.) 
				_lRet := .F.
				Exit
			Endif
			//Gravar Previs„o CabeÁalho
			ZZN->ZZN_FILIAL := FwXFilial("ZZN") 
			ZZN->ZZN_CODPRV := _cNumPrev
			ZZN->ZZN_STATUS := "A"
			ZZN->ZZN_DTINC  := Date()
			ZZN->ZZN_USUINC := RetCodUsr()
			ZZN->(MsUnlock())
			_nRegZZN		:= ZZN->(Recno())
		Endif
		If ! RecLock("ZZP",.T.)
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
		ZZP->ZZP_MODVEI	:= _cModelo
		ZZP->ZZP_FABMOD	:= _cFabAno
		ZZP->(MsUnlock())
		
		//Atualizar SC6
		For _nPos := 1 To Len(_aRegSC6) 
			SC6->(DbGoto(_aRegSC6[_nPos]))
			If !RecLock("SC6",.F.)
				_lRet := .F.
				Exit 
			Endif 
			SC6->C6_XFILPVR := FwXFilial("ZZP")
			SC6->C6_XCODPVR := _cNumPrev
			SC6->C6_XDTPVR 	:= Date()
			SC6->C6_XUSUPVR	:= RetCodUsr()
			_cMens := "Pedido incluido na Previsao "+_cNumPrev
			If !Empty(_cMens)
				SC6->C6_MOPC    := AllTrim(SC6->C6_MOPC) + CRLF + Upper(_cMens) + CRLF 
			Endif
			SC6->(MsUnLock())
		Next	
		If !_lRet  
			Exit 
		Endif
	EndDo
	//If !_lRet 
		//	Disarmtransaction()
	//Endif
	//End Transaction

End Sequence 
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif
//Gravar msg
ZZN->(DbGotop())
ZZN->(DbGoto(_nRegZZN))
If Len(_aMsg) > 0
	For _nPos := 1 To Len(_aMsg)
		If !RecLock("ZZN",.F.)
			Exit
		Endif
		ZZN->ZZN_OBS := AllTrim(ZZN->ZZN_OBS) + CRLF +Upper(AllTrim(_aMsg[_nPos])) + CRLF
		ZZN->(MsUnlock())
	Next
Endif 

If _lRet
    ApMsgStop("Gerada previsao "+_cNumPrev, "Previs„o Faturamento")
Endif 

Return _lRet


/* substituido por U_XZFAT9CH
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
    	cQuery += CRLF + "  AND SBF.BF_LOCAL   = '" +_cLocal+ "' "				+CRLF
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
*/
