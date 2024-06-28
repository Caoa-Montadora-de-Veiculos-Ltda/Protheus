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

// botÃµes
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
	// painÃ©is esquerdos
	Data oPanelSearch 	As Object
	Data oPanelChart 	As Object
	Data oPanelDados 	As Object 
	Data _oBrowseZZN	As Object

	// painÃ©is centrais
	Data oPanelBrowse 	As Object
	Data oPanelVis 		As Object
	Data _oBrowseZZP	As Object
	Data _oBrwTotCli	As Object
	// painÃ©is direitos	
	Data oPanelEVenda 	As Object
	Data oPanelDetalhe 	As Object


	// objetos necessÃ¡rios para a interface	
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
	// construÃ§Ã£o de tela	
	Method CreateLeftColumn()
	Method CreateRightColumn()
	Method CreateCenterColumn()
	//Method FilterFile()
	// atualizaÃ§Ã£o
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

Cria uma nova instÃ¢ncia da classe TelAcWindow. 

RestriÃ§Ã£o: New() apenas inicializa os atributos. Para a construÃ§Ã£o de
interfaces Ã© necessÃ¡rio a chamada do mÃ©todo Init().

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

	// painÃ©is centrais
	Self:oPanelBrowse	:= Nil
	Self:oPanelVis 		:= Nil
	Self:_oBrowseZZP	:= Nil
	Self:_oBrwTotCli	:= Nil

	// painÃ©is direitos	
	Self:oPanelEVenda 	:= Nil
	Self:oPanelDetalhe 	:= Nil

	// objetos necessÃ¡rios para a interface	
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
Cria os painÃ©is do lado esquerdo, de acordo com o gestor utilizado:
Contas a Receber, Contas a Pagar ou Tesouraria:
---------------------------------------------------------------------------- */
Method CreateLeftColumn() Class TelAcWindow

Begin Sequence
	ZZN->(DbSetOrder(1))
	Self:oArea:AddCollumn(COL_LEFT , 30, .T.)
	Self:oArea:SetColSplit(COL_LEFT, CONTROL_ALIGN_RIGHT)
	// cria a janela de search
	Self:oArea:AddWindow(COL_LEFT, WND_SEARCH, "Previsão", 100, .T., .F.) //"Pesquisa"
	// cria o panel da pesquisa
	Self:oPanelSearch := Self:oArea:GetWinPanel(COL_LEFT, WND_SEARCH)
    //funcionalidade para carga da tabela temporÃ¡ria
	DbSelectArea("ZZN")
    //tabela temporaria
    
	Self:_oBrowseZZN:=FWMBrowse():New()
    Self:_oBrowseZZN:SetAlias("ZZN")
	Self:_oBrowseZZN:SetDescription('Previsao')
    Self:_oBrowseZZN:SetOwner(Self:oPanelSearch)
    //Self:_oBrowseZZN:SetUseFilter(.F.)
    //Self:_oBrowseZZN:SetDBFFilter(.F.)                  
    //Self:_oBrowseZZN:DisableConfig() 		// Desabilita a utilização do Browse
	Self:_oBrowseZZN:SetCanSaveArea(.T.)	//abertura de mais de uma  browse
    //Self:_oBrowseZZN:DisableDetails()
	Self:_oBrowseZZN:SetMenuDef('')
    Self:_oBrowseZZN:SetIgnoreARotina(.T.) // Indica que a mbrowse, ira ignorar a variavel private aRotina na construção das opções de menu.
    Self:_oBrowseZZN:SetWalkThru(.F.)
    Self:_oBrowseZZN:SetAmbiente(.F.) //Habilita a utilização da funcionalidade Ambiente no Browse
    Self:_oBrowseZZN:SetFixedBrowse(.T.)
	Self:_oBrowseZZN:AddLegend("AllTrim(ZZN_STATUS) = 'A'  "  ,"WHITE"     ,"Em Aberto")
	Self:_oBrowseZZN:AddLegend("AllTrim(ZZN_STATUS) = 'L'  "  ,"GREEN"     ,"Liberado Fat")
    Self:_oBrowseZZN:AddLegend("AllTrim(ZZN_STATUS) = 'F'  "  ,"BLUE" 	   	,"Faturado")
	Self:_oBrowseZZN:AddLegend("AllTrim(ZZN_STATUS) = 'C'  "  ,"RED"       ,"Cancelado")
	Self:_oBrowseZZN:AddLegend("AllTrim(ZZN_STATUS) <> ' '  " ,"GRAY"      ,"Pendente")

	Self:_oBrowseZZN:AddButton("Incluir"		, { || Self:MenuPrev(3)	})
	Self:_oBrowseZZN:AddButton("Alterar"		, { || Self:MenuPrev(4)	})
	Self:_oBrowseZZN:AddButton("Faturar"		, { || Self:MenuPrev(1)	})
	Self:_oBrowseZZN:AddButton("Cancelar"		, { || Self:MenuPrev(5)	})
	Self:_oBrowseZZN:AddButton("Visualizar"		, { || Self:MenuPrev(2)})
	Self:_oBrowseZZN:AddButton("Importar CSV"	, { || Self:MenuPrev(6)})

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
Cria os painÃ©is centrais, de acordo com o gestor utilizado: Contas a Receber,
Contas a Pagar ou Tesouraria:
---------------------------------------------------------------------------- */
Method CreateCenterColumn() Class TelAcWindow
Local _oRelac

Begin Sequence
	oArea := Self:oArea
	// cria a coluna do meio	
	Self:oArea:AddCollumn(COL_CENTER, 70, .F.)
	Self:oArea:SetColSplit(COL_CENTER, CONTROL_ALIGN_LEFT)
	// visualizaÃ§Ã£o do planejamento
	Self:oArea:Addwindow(COL_CENTER, WND_VIS, "Consulta Previsão ", 70, .T., .F.) 
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
Cria os painÃ©is do lado direito, de acordo com o gestor utilizado:
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
Altera o tÃ­tulo do painel de navegaÃ§Ã£o para o texto especificado cWindowTitle.
---------------------------------------------------------------------------- */
Method SetBrowseTitle(cWindowTitle) Class TelAcWindow
Return Self:oArea:SetWinTitle(COL_CENTER, WND_BROWSE, cWindowTitle)


/* ----------------------------------------------------------------------------
TelAcWindow:SetDadosTitle()
Altera o tÃ­tulo do painel de visualizaÃ§Ã£o para o texto especificado
cWindowTitle.
---------------------------------------------------------------------------- */
Method SetDadosTitle(cWindowTitle) Class TelAcWindow
Return Self:oArea:SetWinTitle(COL_CENTER, WND_VIS, cWindowTitle)

/* ----------------------------------------------------------------------------
TelAcWindow:GetDadosTitle()
MÃ©todo nÃ£o implementado ainda.
---------------------------------------------------------------------------- */
Method GetDadosTitle() Class TelAcWindow
Return ""


/* ----------------------------------------------------------------------------
FunÃ§Ãµes auxiliares
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
Devolve a largura do painel oParent, utilizando o mÃ©todo ReadClientCorrs() para
ler as dimensÃµes reais do painel.
---------------------------------------------------------------------------- */
Static Function DlgWidthPanel(oParent)
	Local nLargura := 0	
	oParent:ReadClientCoors()	
	nLargura := oParent:nWidth
Return nLargura


/* ----------------------------------------------------------------------------
TelAcWindow:DimObj()
Devolve as dimensÃµes do painel de visualizaÃ§Ã£o.
---------------------------------------------------------------------------- */
Method DimObj(cPanel) Class TelAcWindow
	Local oParent := NIL
	Self:oArea:GetWinPanel(COL_CENTER, WND_VIS)
	oParent:FreeChildren()
	aDim := DLGinPANEL(oParent)
Return aDim


/* ----------------------------------------------------------------------------
TelAcWindow:Refresh()
Atualiza os painÃ©is de pesquisa e de grÃ¡ficos (caso o mesmo exista).
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
Altera o tÃ­tulo do painel de de grÃ¡ficos para o texto especificado
cWindowTitle.
---------------------------------------------------------------------------- */
Method SetChartTitle(cWindowTitle) Class TelAcWindow
Return Self:oArea:SetWinTitle(COL_LEFT, WND_CHART, cWindowTitle)



/* ----------------------------------------------------------------------------
TelAcWindow:Init()
Inicializa o objeto TelWindow criando a interface grÃ¡fica para o gestor.
---------------------------------------------------------------------------- */
Method Init() Class TelAcWindow
Local aCoors := {}
Local lCloseButt := !(oAPP:lMdi)

Begin Sequence
	// a funÃ§Ã£o CursorWait() altera o cursor apenas quando a rotina Ã© chamada
	// pela primeira vez. Nas chamadas seguintes da funÃ§Ã£o, o cursor nÃ£o Ã©
	// alterado. Chamando CursorArrow() forÃ§a a CursorWait() mostrar o cursor
	// de ampulheta sempre.
	CursorArrow()
	CursorWait()
	aCoors := FWGetDialogSize(oMainWnd)
	DEFINE MSDIALOG Self:oDlg TITLE "PEÃ‡AS" ; 
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
Devolve o painel no qual serÃ¡ mostra a visualizaÃ§Ã£o dos registros.
---------------------------------------------------------------------------- */
Method GetVisPanel() Class TelAcWindow
Return Self:oArea:GetWinPanel(COL_CENTER, WND_VIS)

/* ----------------------------------------------------------------------------
ShowViewPanel()
---------------------------------------------------------------------------- */
Method ShowViewPanel() Class TelAcWindow
Begin Sequence
	// verifica se o painel de visualizaÃ§Ã£o
	// estÃ¡ sendo mostrado
	If !Self:oArea:WinOpen(COL_CENTER, WND_VIS)
		// se nÃ£o, mostra a janela
		Self:oArea:WinChgState(COL_CENTER, WND_VIS)
	EndIf
End Sequence	
Return Nil


/*/{Protheus.doc} ZFAT025Total
//Trazer totais dos clientes por previsao
@author DAC denilso
@since 18/04/2024
@version 1.0
@parametro 		_lCarrega - indica se esta realizando o carregamento de variaveis neste momento nÃ£o mostra  para fazer atualizaÃ§Ã£o no browse
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

	BeginSql Alias _cAliasPesq //Define o nome do alias temporÃ¡rio 
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
		//Verificar os itens dos KITs para saber se tem algun zerado caso tenha nÃ£o ira utilizar o kit
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



//Sub menu Previsão de Vendas
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
	If (_nOpc == 1 .Or. _nOpc == 4 .Or. _nOpc == 5 ) .And. ZZN->ZZN_STATUS == "C"   //(_nOpc < 2 .Or. _nOpc > 3) .And. ZZN->ZZN_STATUS == "C"  	
        MsgStop("Previsao cancelada", "PREVISAO")
		Return Nil
	Endif 
	
	If _nOpc ==  1  	//Faturamento
		FwMsgRun(,{ |_oSay| U_XZFT19FT(_cFilPrev, _cCodPrev, @_oSay) }, "Selecionando dados", "Aguarde...")  
	ElseIf _nOpc ==  3  //inclusão
		_nRegZZN := 0
		ZFATF025Inclui(@_nRegZZN)
		Self:_oBrowseZZN:GoTop(.T.)
		Self:_oBrowseZZN:Refresh(.T.)
		ZFAT025Total( ZZN->ZZN_FILIAL, ZZN->ZZN_CODPRV,  /*_lCarrega*/)
	ElseIf _nOpc ==  6 	//Importar CSV
		_nRegZZN := 0
		ZFATF025ICSV(@_nRegZZN)
		Self:_oBrowseZZN:GoTop(.T.)
		Self:_oBrowseZZN:Refresh(.T.)
		ZFAT025Total( ZZN->ZZN_FILIAL, ZZN->ZZN_CODPRV,  /*_lCarrega*/)
	Else	
		FwMsgRun(,{ |_oSay| U_ZFATF026(_nOpc, _cFilPrev, _cCodPrev , @_oSay ) }, "Selecionando dados", "Aguarde...")  
	Endif
	Self:RefreshPrev(.T.)

Return Nil

// Vaidar quando movimentado cursor e ajustar totalizações
Method ZFT25Change() Class TelAcWindow
	If ValType(Self:_oBrwTotCli) == "O"  //Somente quando estiver ativo tela de totalização
		ZFAT025Total(ZZN->ZZN_FILIAL, ZZN->ZZN_CODPRV,  /*_lCarrega*/)
		Self:RefreshPrev(.T.)
	Endif
Return .T.




/*/{Protheus.doc} ZFATF025Inclui
Função para inclusão de nova previsao
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
	//Parametro encontra na função ZFATF019
	If !U_XZFT19PA(@_aRet)
    	_lRet := .F. 
		Break
	Endif
	
	//Garantir que o processamento seja unico
	_cChave		:= AllTrim(FWCodEmp())+"ZFATF025"
	If !LockByName(_cChave,.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 3000 ) // Para o processamento por 3 segundos
			If LockByName("_cChave",.T.,.T.)
				_lRet := .T.
			EndIf
		Next		
		If !_lRet
		    ApMsgStop("Já existe um processamento em execução rotina para gerar Previsao, aguarde!", "[ZFATF025]Previsão Faturamento")
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

//Inclusão de Nova Previsão

Static Function ZFATF025Qry( _aRet, _nRegZZN, _oSay )
Local _cAliasPesq 	:= GetNextAlias()
Local _lRet 		:= .T.
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
Local _cSegMod
Local _cFabAno 
Local _aRegSC6
Local _nQtdeReg
Local _nQtdeLidos
Local _aSelect
Local _cSelect
Local _cOrderTab  

Default _aRet 		:= {}

Begin Sequence 
	If !MsgYesNo("Deseja criar nova Previsão ?") 
		_lRet := .F. 
		Break 
	Endif 

	If Len(_aRet) == 0 
	    ApMsgStop("Nao informado Parametros para a montagem do Select", "Previsão Faturamento")
	    _lRet := .F.
		Break
	Endif 

	ZZP->(DbSetOrder(1))
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
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

	//Montagem campos para select
	_cSelect := CRLF +" SELECT "
	For _nPos := 1 To Len(_aSelect)
		_cSelect += CRLF +If(_nPos > 1,", "," ")+_aSelect[_nPos]+" "
	Next
	_cSelect += CRLF +", SC6.R_E_C_N_O_ AS NREGSC6 "
	_cSelect += CRLF +", VRK.R_E_C_N_O_ AS NREGVRK "
	
	//Tem que estar sem chassis e sem previsão
	_cWhere := CRLF + " 		AND SC6.C6_XFILPVR 	= ' ' "
	_cWhere += CRLF + " 		AND SC6.C6_XCODPVR 	= ' ' "
	_cWhere += CRLF + " 	    AND SC6.C6_CHASSI   = ' ' "  
	//Ordem do Select 
	//_cOrderTab   := "SC6.C6_FILIAL, SC6.C6_PEDCLI, SC6.C6_ITEM, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC6.C6_PRODUTO "
	_cOrderTab   := "SC6.C6_FILIAL, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC6.C6_PRODUTO, VRK.VRK_FABMOD, VRK.VRK_MODVEI, VRK.VRK_SEGMOD,  SC6.C6_PEDCLI, SC6.C6_ITEM

	_cQuery := U_XZFT19QY(_cSelect, _cOrderTab, _aRet, _cWhere, /*_cWhereAll*/, _cJoin, /*_cGroup*/)

	//Realizar o Select
	_oSay:SetText("Aguarde Selecionando registros ... Hora: "+Time() )
	ProcessMessage()

	TcQuery _cQuery new alias (_cAliasPesq)

	DbSelectArea(_cAliasPesq)
    (_cAliasPesq)->(DbGoTop())
	If (_cAliasPesq)->(Eof())
	    ApMsgStop("Não existem registros para os parametros informados", "Previsão Faturamento")
	    _lRet := .F.
		Break
	Endif
	Count To _nQtdeReg	  //Conta quantos chassis estão disponiveis
    (_cAliasPesq)->(DbGoTop())

	_oSay:SetText("Aguarde Montando Previsão de "+StrZero(_nQtdeReg,6)+" registros ... Hora: "+Time() )
	ProcessMessage()
	//Gravar Previsão Itens
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
		_cSegMod 	:= (_cAliasPesq)->VRK_SEGMOD
		_cFabAno 	:= (_cAliasPesq)->VRK_FABMOD //If( !Empty((_cAliasPesq)->C6_XFABMOD), (_cAliasPesq)->C6_XFABMOD, (_cAliasPesq)->VRK_FABMOD)
		_nQtVen		:= 0
		_aRegSC6	:= {}
		While (_cAliasPesq)->(!Eof()) .And. _cCliente 	== (_cAliasPesq)->C6_CLI 		.And. ;
											_cLoja 		== (_cAliasPesq)->C6_LOJA 		.And. ;
											_cProduto 	== (_cAliasPesq)->C6_PRODUTO	.And. ;
											_cModelo 	== (_cAliasPesq)->VRK_MODVEI	.And. ;
											_cSegMod 	== (_cAliasPesq)->VRK_SEGMOD	.And. ;
											_cFabAno 	== (_cAliasPesq)->VRK_FABMOD
			_nQtdeLidos ++
			_oSay:SetText("Aguarde Montando Previsão lidos "+StrZero(_nQtdeLidos,6)+" de "+StrZero(_nQtdeReg,6)+" registros ... ")
			ProcessMessage()

			SC6->(DbGoto((_cAliasPesq)->NREGSC6))
			VRK->(DbGoto((_cAliasPesq)->NREGVRK))
			_cMens := ""
			//somente incluir se tiver quantidade
			If SC6->C6_QTDVEN <= 0
				(_cAliasPesq)->(DbSkip())
				Loop	
			Endif	
			//Não permitir incusão de previsao com chassi
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
			//Atualizar descrições
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
		//Não encontrou nenhum
		If _nQtVen == 0 .Or. Len(_aRegSC6) == 0
			Loop
		Endif

		//Begin Transaction
		//Criar Cabeçalho
		If _nRegZZN == 0
			If !RecLock("ZZN",.T.) 
				_lRet := .F.
				Exit
			Endif
			//Gravar Previsão Cabeçalho
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
		//Gravar Previsão 
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
		ZZP->ZZP_SEGMOD	:= _cSegMod
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
    ApMsgStop("Gerada previsao "+_cNumPrev, "Previsão Faturamento")
Endif 
Return _lRet

//Importar CSV ja Montado
Static Function ZFATF025ICSV(_nRegZZN)
Local _cTitulo1  := "Selecione o arquivo para Carga "
Local _cExtens   := "Arquivo CSV | *.CSV"
Local _cMainPath := Nil //"C:\"
Local _cFileOpen := ""
Local _oSay

Begin Sequence 

	//If U_ZGENUSER( RetCodUsr() ,"ZFATF025IC" ,.T.)
	//	Break 
	//Endif
    
    _cFileOpen := cGetFile(_cExtens, _cTitulo1, , _cMainPath, .T.)
	If Empty(_cFileOpen)
		Break 
	Endif 
    If !File(_cFileOpen)
	    ApMsgStop("Não localizado arquivo "+_cFileOpen, "Previsão Faturamento")
		Break 
	Endif	
	FwMsgRun(,{ |_oSay| ZFATF025Ler(_cFileOpen, _oSay) }, "Selecionando dados", "Aguarde...")  
End Sequence 
//apagar arquivo para não permitir utilizar o mesmo
//	        fErase(_nAqr+GetDbExtension())
//	        fErase(cSysPath+AllTrim(_nAqr))
Return Nil

//Ler o arquivo CSv
Static Function ZFATF025Ler(_cFileOpen, _oSay)
Local _cLinha      	:= ""
Local _cSeparador	:= ";"  // Separador do arquivo 
Local _aDados 		:= {}   // Array dos dados da linha do laco
Local _aDadosZZP  	:= {}	
Local _aMsgErro		:= {}
Local _nLinha		:= 0
Local _nLinTot		:= 0
Local _aEstruCSV	
Local _nPos

	//adiciono a estrutura do CSV 
	//Nome;CNPJ;Cod Produto;Modelo;Segmento Modelo;Descri‡Æo;Ano/Mod;Qtd Liberada
	_aEstruCSV 	:= {}
	Aadd(_aEstruCSV,{"ZZP_RAZSOC", 		,			, .F.})
	Aadd(_aEstruCSV,{"ZZP_CNPJCP", "SA1", "A1_CGC"	, .T.})
	Aadd(_aEstruCSV,{"ZZP_CODPRD", "SB1", "B1_COD"	, .T.})
	Aadd(_aEstruCSV,{"ZZP_MODVEI", 		,			, .T.})
	Aadd(_aEstruCSV,{"ZZP_SEGMOD", 		,			, .T.})
	Aadd(_aEstruCSV,{"ZZP_DESPRD", 		,			, .F.})
	Aadd(_aEstruCSV,{"ZZP_FABMOD", 		,			, .T.})
	Aadd(_aEstruCSV,{"ZZP_QTELIB", 		,			, .T.})
   
    FT_FUSE(_cFileOpen)
    FT_FGOTOP()
    FT_FSKIP()
    _nLinTot 	:= FT_FLastRec()-1      //total de linhas do arquivo
    FT_FGOTOP()
    FT_FSKIP(1)  //Linhas a saltar

	While !FT_FEOF()
    	_nLinha ++
		_oSay:SetText("Aguarde Lendo linha "+StrZero(_nLinha,5)+" de "+ StrZero(_nLinTot,5))
		ProcessMessage()
	    _cLinha := FT_FREADLN()
        _aDados := Separa(_cLinha, _cSeparador)
		//Verificar se os dados estão consistentes
		If ZValidCSV(_aDados, _aEstruCSV, _nLinha, @_aMsgErro)
			Aadd(_aDadosZZP, _aDados)
		Endif 
        FT_FSKIP(1)
    END
    FT_FUSE()

	If Len(_aDadosZZP) == 0
		Return Nil
	Endif 
    ProcRegua( Len(_aDadosZZP) )
    Begin Transaction
        For _nPos := 1 To Len(_aDadosZZP)
			_oSay:SetText("Aguarde Efetuando gravação linha "+StrZero(_nPos,5)+" de "+ StrZero(_nLinha,_nLinTot))
			ProcessMessage()
        Next
		//Gravar o nome do arquivo recebido na mensagem ZZP para poder ser validado posteriormente
    End Transaction
			/*
            cProduto := StrTran(AllTrim(aDadosLi[nI][6]),"-","")

            If SB1->( DbSeek( FwXFilial("SB1") + Padr(cProduto, TamSX3("B1_COD")[1]) ) )

                If ZZH->( DbSeek( FwXFilial("ZZH") +;
                        PadR(aDadosLi[nI][2]    ,TamSX3("ZZH_CODBID")[1])   +;
                        PadR(aDadosLi[nI][5]    ,TamSX3("ZZH_CODBOX")[1])   +;
                        PadR(cProduto           ,TamSX3("ZZH_PRODUT")[1])   +;
                        PadR(aDadosLi[nI][7]    ,TamSX3("ZZH_QTD")[1]) ) )

                    cLog := "Registro Cod. Bar. Unit: " + aDadosLi[nI][2] +;
                            " Cod. Bar. Box: " + aDadosLi[nI][5] +;
                            " Produto: " + cProduto +;
                            " Qtd: " + aDadosLi[nI][7] +;
                            " ja existe no sistema!"
                    GrvLog(cArqLog, cLog)
                Else
                    //-- Gravação dos dados	
                    RecLock("ZZH",.T.)
                        ZZH->ZZH_FILIAL :=  FwXFilial()
                        ZZH->ZZH_CONTAI :=  aDadosLi[nI][1]
                        ZZH->ZZH_CODBID :=  aDadosLi[nI][2]
                        ZZH->ZZH_IDUNIT :=  aDadosLi[nI][3]
                        ZZH->ZZH_BOX    :=  aDadosLi[nI][4] 
                        ZZH->ZZH_CODBOX :=  aDadosLi[nI][5]
                        ZZH->ZZH_PRODUT :=  cProduto
                        ZZH->ZZH_QTD    :=  Val(aDadosLi[nI][7]) 
                        ZZH->ZZH_RANGE	:=  SB1->B1_XRANGE
                        ZZH->ZZH_DESPRD :=  SB1->B1_DESC
                        ZZH->ZZH_DATA   :=  dDataBase
                        ZZH->ZZH_HORA   :=  Time()
                        ZZH->ZZH_USRIMP :=  cUserName
                    ZZH->( MsUnLock() )	

                EndIf

            Else
                cLog := "Produto " + cProduto + " não foi localizado no Protheus!"
                GrvLog(cArqLog, cLog)
            EndIf
			*/
		/*
        If !Empty(cLog)
            MsgAlert("Falha na importação dos registros, por favor, consulte arquivo de log!")
            Disarmtransaction()
        EndIf
		*/
Return Nil 

//Validar CSV
Static Function ZValidCSV(_aDados, _aEstruCSV, _nLinha, _aMsgErro)
Local _lRet	:= .F.
Local _cAliasPesq	:= GetNextAlias()
Local _nPos
Local _cMens
Local _nPosCpo
Local _cAlias  
Local _cCond 
Local _cCond2 
Local _aTamSx3

Default _aDados 	:= {}
Default _aEstruCSV 	:= {}

Begin Sequence 
	If Len(_aDados)  == 0
		_cMens := "Linha "+StrZero(_nLinha,5)+" não preenchida com as informações"
		Aadd(_aMsgErro, _cMens)
		Break
	Endif 

	If Len(_aDados)  <> Len(_aEstruCSV)  
		_cMens := "Linha "+StrZero(_nLinha,5)+" com tamanho diferente da estrutura, estrutura "+StrZero(Len(_aEstruCSV),2) + " posicoes e Linha "+StrZero(Len(_aDados),2)+" posicoes"
		Aadd(_aMsgErro,_cMens)
		Break
	Endif 

	//Validar existencisas do campo
	For _nPos := 1 To Len(_aDados)
		_cAlias := "" 
		_cCond 	:= ""
        _aTamSx3 := TamSX3(_aEstruCSV[_nPos,1])
		If _aTamSx3[3] == "N" .And. Val(_aDados[_nPos]) == 0 .And. Len(_aEstruCSV[_nPos])  //a ultima posição de _aEstruCSV indica se o campo vai ser ou não utiizado
			_cMens := "Linha "+StrZero(_nLinha,5)+" Campo "+_aEstruCSV[_nPos,1]+" obrigatorio preenchimento"
			Aadd(_aMsgErro,_cMens)
			Loop
		ElseIf Empty(_aDados[_nPos]) .And. Len(_aEstruCSV[_nPos])  //se estiver vazio e o uso for obrigatório
			_cMens := "Linha "+StrZero(_nLinha,5)+" Campo "+_aEstruCSV[_nPos,1]+" obrigatorio preenchimento"
			Aadd(_aMsgErro,_cMens)
			Loop
		//Validar tamanho do campo recebido	
		ElseIf Len(_aDados[_nPos]) > _aTamSx3[01]   
			_cMens := "Linha "+StrZero(_nLinha,5)+" Campo "+_aEstruCSV[_nPos,1]+" com tamanho maior que na base de dados"
			Aadd(_aMsgErro,_cMens)
			Loop
		Endif 
		//Verificar tabelas relacionadas
		If ValType(_aEstruCSV[_nPos,2]) == "C" 
			_cAlias := _aEstruCSV[_nPos,2]
		Endif 
		If ValType(_aEstruCSV[_nPos,3]) == "C" 
			_cCond 	:= _aEstruCSV[_nPos,3] 
			_cCond2	:= _aDados[_nPos]
			_nPosCpo:= At("_",_cCond)
			_cFilial:= SubsTr(_cCond,1,_nPosCpo)+"FILIAL"
		Endif 
		//Valida Existencia do Processo
		If !Empty(_cAlias) .And. !Empty(_cCond)
			If Select((_cAliasPesq)) <> 0
				(_cAliasPesq)->(DbCloseArea())
			Endif
			BeginSql Alias _cAliasPesq //Define o nome do alias temporÃ¡rio 
				SELECT  %Exp:_cCond%
				FROM %Table:%Exp:_cAlias%%		
				WHERE 	%notDel%
					AND %Exp:_cFilial%  = %xFilial:%Exp:_cAlias%%
					AND	%Exp:_cCond%  	= %Exp:_cCond2%
			EndSql
			If (_cAliasPesq)->(Eof())
				_cMens := "Linha "+StrZero(_nLinha,5)+" não localizado na tabela de relacionamento a chave "+_cCond
				Aadd(_aMsgErro,_cMens)
				Break
			Endif 
		Endif
	Next
	If Len(_aMsgErro)  
		Break 
	Endif 
	_lRet := .T.
End Sequence 
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet









/* substituido por U_XZFAT9CH
//Verifica se existem  chassis ver função [fAtuPeds ZFATF018]
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
