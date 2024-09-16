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
Private CrLf      := (Chr(13)+Chr(10))


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
	DbSelectArea("ZZP")
	DbSelectArea("ZZN")

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
	__oColumn := FWBrwColumn():New()
	__oColumn:SetData({||_aCliRel[Self:_oBrwTotCli:nAt,DATA_CLIENTE]})
	__oColumn:SetTitle("Cliente" ) 
	__oColumn:SetSize(Len(SA1->A1_COD))
	Self:_oBrwTotCli:SetColumns({__oColumn})
	
	__oColumn := FWBrwColumn():New()
	__oColumn:SetData({||_aCliRel[Self:_oBrwTotCli:nAt,DATA_LOJA]})
	__oColumn:SetTitle("Loja") 
	__oColumn:SetSize(Len(SA1->A1_LOJA))
	__oColumn:SetDecimal(2)
	//_oColumn:SetPicture("@!")
	Self:_oBrwTotCli:SetColumns({__oColumn})

	__oColumn := FWBrwColumn():New()
	__oColumn:SetData({||_aCliRel[Self:_oBrwTotCli:nAt,DATA_CNPJCPF]})
	__oColumn:SetTitle("CNPJ/CPF") 
	__oColumn:SetSize(Len(SA1->A1_CGC))
	__oColumn:SetDecimal(0)
	//__oColumn:SetPicture("@!")
	Self:_oBrwTotCli:SetColumns({__oColumn})

	__oColumn := FWBrwColumn():New()
	__oColumn:SetData({||_aCliRel[Self:_oBrwTotCli:nAt,DATA_NOMCLI]})
	__oColumn:SetTitle("Nome Cliente") 
	__oColumn:SetSize(Len(SA1->A1_NOME))
	__oColumn:SetDecimal(0)
	__oColumn:SetPicture("@!")
	Self:_oBrwTotCli:SetColumns({__oColumn})

	__oColumn := FWBrwColumn():New()
	__oColumn:SetData({||_aCliRel[Self:_oBrwTotCli:nAt,DATA_TOTCLI]})
	__oColumn:SetTitle("Total Pedido") 
	__oColumn:SetSize(15)
	__oColumn:SetDecimal(2)
	__oColumn:SetPicture("@E 9999,999,999.99")
	Self:_oBrwTotCli:SetColumns({__oColumn})

	__oColumn := FWBrwColumn():New()
	__oColumn:SetData({||_aCliRel[Self:_oBrwTotCli:nAt,DATA_TOTFAT]})
	__oColumn:SetTitle("Total Faturamento R$") 
	__oColumn:SetSize(15)
	__oColumn:SetDecimal(2)
	__oColumn:SetPicture("@E 9999,999,999.99")
	Self:_oBrwTotCli:SetColumns({__oColumn})

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

	_cFilPrev := ZZN->ZZN_FILIAL
	_cCodPrev := ZZN->ZZN_CODPRV

	//somente liberado para visualizar e ou incluir 
	//If (_nOpc < 2 .Or. _nOpc > 3) .And. ZZN->ZZN_STATUS $ "F"
	If  (_nOpc < 2 .Or. _nOpc > 3) .And. _nOpc <> 6 .And. ZZN->ZZN_STATUS $ "F"  
        MsgStop("Previsao ja faturada", "PREVISAO")
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
		ZFATF025Inclui()
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
Static Function ZFATF025Inclui(  )
Local _cChave		:= ""
Local _lRet			:= .T.
Local _nPos
Local _oSay

Begin Sequence
	
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
	If FwMsgRun(,{ |_oSay| ZFATF025Qry(@_oSay ) }, "Processando ", "Aguarde...")  
    	ApMsgStop("Gerada previsao "+ZZN->ZZN_CODPRV, "Previsão Faturamento")
	Endif 

	//ZFT25Change()
End Sequence
//Desbloquear processamento
If !Empty(_cChave)
	UnLockByName(_cChave,.T.,.T.)
Endif
Return _lRet




//Localizar quantos chassis disponíveis possuem para o Produto
Static Function ZFATF025QChassi(_cCodProd, _cFabMod)
Local _cAlias 		:= GetNextAlias()
Local _cQuery 		:= ""
Local _nQtdeChassi  := 0
	_cQuery  := U_XZFT30CH(_cCodProd, /*_cLocal*/, /*_cNumSerie*/, /*cChassi*/, _cFabMod, /*_aCampos*/)
	TcQuery _cQuery new alias (_cAlias)
	DbSelectArea(_cAlias)
	If (_cAlias)->(!Eof())
		(_cAlias)->(DbGotop())
		Count To _nQtdeChassi	  //Conta quantos chassis estão disponiveis
		(_cAlias)->(DbGotop())
	Endif
If Select(_cAlias) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif
Return _nQtdeChassi



//=======================================================================================

/*
Programa.:              NotificaDiv -Função para envio de E-mail 
@param 					_aDivergencia  	= Matriz com dados dos erros no processo 
Autor....:              CAOA - DAC Denilso 
Data		            06/07/2024
Descricao / Objetivo	Funcionalidade responsável por enviar e-mail aos responsaveis (cadastro SX5 e-mail) referente a problemas com a integração de transferência 
Doc. Origem            	
Solicitante            	CAOA
Uso              		ZFATF025
Obs
@menu       			Nao Informado
@return					_lRet 		- Verdadeiro ou falso
@history 					
=====================================================================================
*/
//******************************************
//Função para envio de E-mail  
Static Function NotificaDiv(_cFile, _aDivergencia)  	// (cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,Rotina,	Observação	, cReplyTo	)Local aMailDest     := StrTokArr( Alltrim(Getmv("CMV_WMS024")),  ";" )
//******************************************
Local _cEmailDest   := ""  
Local _cMailCopia   := ""
Local _cAssunto	    := "Ocorrencias no recebimento CSV Previsao "
Local _cHtml        := ""
Local _cAttach      := ""
Local _lMsgErro     := .F.
Local _lMsgOK       := .F.
Local _cObservacao  := ""
Local _cReplyTo	    := ""
Local _cRotina      := "ZFATF025"
Local _cAliasPesq	:= GetNextAlias()
Local _cMens        := ""
Local _lRet			:= .T.
Local _cChaveSX5	:= "1D"
Local _nPos

Default _aDivergencia	:= {}
Default _cFile			:= ""

Begin Sequence

	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT 	SX5.X5_DESCRI 
		FROM  	%Table:SX5% SX5
		WHERE 		SX5.X5_FILIAL 	= %xFilial:SX5%
				AND SX5.X5_TABELA 	= %Exp:_cChaveSX5%
				AND SX5.%notDel%
	EndSql
	If (_cAliasPesq)->(Eof())
		Conout("ZFATF025 - Não informado e-mail na tabela SX5, referentes a inconsistencias para envio de e-mail ! Verificar com ADM Sistemas")
		_lRet := .F.
		Break
	EndIf
	(_cAliasPesq)->(DbGotop())
	_cEmailDest	:= ""
	While (_cAliasPesq)->(!Eof())
		If !Empty((_cAliasPesq)->X5_DESCRI)
			_cEmailDest	+= AllTrim((_cAliasPesq)->X5_DESCRI)+","
		EndIf	
		(_cAliasPesq)->(DbSkip())
	EndDo
	If Empty(_cEmailDest)
		Conout(_cRotina+" - Não informado e-mail na tabela SX5, referentes a inconsistencias para envio de e-mail ! Verificar com ADM Sistemas")
		_lRet := .F.
		Break
	EndIf
	//_cEmailDest := SubsTr(_cEmailDest,1,Len(_cEmailDest)-1)  //retirar a virgula do final
	//Fechar arquivo temporario para novo select
	(_cAliasPesq)->(DbCloseArea())

	If Len(_aDivergencia) == 0
		Conout(_cRotina+" - Não foi recebido dados referentes a inconsistencias para envio de e-mail ! Verificar com ADM Sistemas")
		_lRet := .F.
		Break
	EndIf

	//If !Empty(_cFile)	
	//	_cAssunto += " arquivo "+_cFile
	//Endif 	
	_cHtml := "<h3>"                                                                       
    _cHtml +=    "  Ocorreram divergências no recebimento integração arquivo tipo CSV. 	<br/>" 
    _cHtml +=    "  importacao referente a Previsao de Faturamento. <br/>" 
    _cHtml +=    "  Data do processament: " + dtoc(date())  + " " + time() + "      		<br/><br/>" 
    _cHtml +=    "  Detalhe :                                                   		<br/>" 
    _cHtml +=    "</h4>"     

	/*		add(_aDivergencia, {_cProduto,;				//1
								Alltrim(_cFornec),;		//2
								Alltrim(_cLoja ),; 		//3
								Alltrim(_cSerFor),; 	//4
								Alltrim(_cNfFor),; 		//5
								_cArmOrig,;				//6
								_nQtdeDiverge,;			//7
								_nQtdeConf,;			//8
								_nSaldoSB2,;			//9
								_cErro} )				//10
	*/
	For _nPos := 1 To Len(_aDivergencia)
		_cMens			:=  Upper(AllTrim(_aDivergencia[_nPos]))
    	_cHtml += "<br/>"
    	_cHtml += "Ocorrencia...: "+ _cMens //+"<br/>"
    	_cHtml += "<br/>"
	Next	 
   	_cHtml += "<br/><br/>"
    _cHtml +=    " <h5>Esse email foi gerado pela rotina " + _cRotina + " </h5>"    
   	_cHtml += "<br/>"
	_cHtml += 	" <h5>arquivo recebido "+_cFile + " </h5>"   
   	_cHtml += "<br/><br/>"
    _lRet := U_ZGENMAIL(_cEmailDest,;
						_cMailCopia,; 
						_cAssunto,;
						_cHtml,;
						_cAttach,;
						_lMsgErro,;
						_lMsgOK,;
						_cRotina,;	
						_cObservacao,; 
						_cReplyTo	)

	If !_lRet
		Conout(_cRotina+" - Problemas com Envio de Email "+cHtml)
	Endif
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet



/*
=====================================================================================
Programa.:              ZWSR012Monitor
@param 					_cStatus   	= Status que será gerado no SZ1 1-OK 2-Divergência 
						_cTab		= Tabela principal que esta sendo gravada na integração
						_cDoc   	= Numero do Cocumento a ser gravado, ja contém a série 
						_cErro    	= mensagem a ser gravada podendo ser de erro e ou exito 
						_dDataIni	= data inicial da importação 
						_cHsIni 	= hora inicial da importação 
						_cJson    	= Json para importação
						_nErro		= numero de retorno que ocasionou erro e ou exito
Autor....:              CAOA - DAC Denilso 
Data		            14/11/2022
Descricao / Objetivo	Funcionalidade que efetuara a gravação de dados no monitor 
Doc. Origem            	PEC020 - Monitor de Integrações WIS
Solicitante            	CAOA
Uso              		ZWSR012
Obs
@menu       			Nao Informado
@return					_lRet 		- Verdadeiro ou falso
@history 				DAC - 	15/02/2023 
								Implementação de envio de campos a serem gravados para SZ1	
=====================================================================================
*/
Static Function	ZWSR012Monitor(_cStatus, _cTab, _cDoc, _cErro, _dDataIni, _cHsIni, _cJson, _nErro )	
Local _lJob      := IsBlind()
Local _cUserName := If( _lJob,"INT_CSV", Nil)   
Local _aCampos	 := {}  //Adicionar campos a serem gravador na tabela DAC  15/02/2023 
Local _cId	 := ""
Local _cProduto	 := ""
Local _nQtdeConf := 0
Local _nPos

//tenho que verificar nos itens se veio o ID, gravara item a item para o monitor
If Len(_aMsg) > 0
	For _nPos := 1 To Len(_aMsg)
		_aCampos    := {}
		_cId		:= AllTrim("id")
		_cProduto	:= AllTrim("CSV")
		_nQtdeConf	:= 0
		//AAdd(_aCampos,{"Z1_IDJSON"	, _cIdJson 	, "id"   		})
		//AAdd(_aCampos,{"Z1_COD"		, _cProduto , "cd_produto" 	})
		//AAdd(_aCampos,{"Z1_QTCONF"	, _nQtdeConf, "qt_conf" 	})
		U_CAOA_GRVMONITOR(XFilial(_cTab),;		//Filail
						_cStatus,;				//Status
						"013",;					//Código do Processo
						/*cCodtpint*/,;			//Código do tipo
						_cErro,;				//Mensagem de retorno
						_cDoc,;					//Documento
						_dDataIni,;				//Data Inicio
						_cHsIni,;				//Hora Final
						_cJson,;				//Json
						If(_cStatus=="1", (_cTab)->(Recno()),0),; //Numero do Registro
						_cUserName,;			//Nome do Usuário na inclusão
						_nErro,;				//Retorno código
						_aCampos)				//Campos pré definidos para gravar no SZ1 
	Next _nPos					
Else
	U_CAOA_GRVMONITOR(XFilial(_cTab),;		//Filail
				_cStatus,;				//Status
				"013",;					//Código do Processo
				/*cCodtpint*/,;			//Código do tipo
				_cErro,;				//Mensagem de retorno
				_cDoc,;					//Documento
				_dDataIni,;				//Data Inicio
				_cHsIni,;				//Hora Final
				_cJson,;				//Json
				If(_cStatus=="1", (_cTab)->(Recno()),0),; //Numero do Registro
				_cUserName,;			//Nome do Usuário na inclusão
				_nErro,;				//Retorno código
				_aCampos)				//Campos pré definidos para gravar no SZ1 
Endif
Return Nil



//Inclusão de Nova Previsão
Static Function ZFATF025Qry( _oSay, _nRegZZN )
Local _cAliasPesq 	AS Character
Local _cAliasPrev 	AS Character
Local _cNumPrev		AS Character
Local _cMens		AS Character
Local _cCodImpPrev	AS Character
Local _cQuery		AS Character
Local _lRet 		AS Logical
Local _lJob			AS Logical	
Local _lGrava		AS Logical
Local _aMsg 		AS Array
Local _aCab			AS Array
Local _aItens		AS Array
Local _aAux			AS Array
Local _nStatus		AS Numeric
Local _nOper		AS Numeric
Local _nQtdeLib		AS Numeric

//Default _cOrderTab	:
Default _nRegZZN	:= 0  
Default _aMsgErro  	:= {}
Default _lMens		:= .T.


Begin Sequence 
	_lJob	:= IsBlind()
	If ! _lJob .And. !MsgYesNo("Deseja criar nova Previsão dos Pedidos Autoware Importados?") 
		Break 
	Endif 
	
	If ! _lJob
		_oSay:SetText("Aguarde Selecionando registros ... Hora: "+Time() )
		ProcessMessage()
	Endif
	_cCodImpPrev	:= "PREVISAO"  //Codigo gravado no momento da importação
	_cQuery			:= ""
	_lRet			:= .F. 
	_aMsg			:= {}
	_nOper			:= 3
	
	ZZN->(DbSetOrder(1))
	ZZP->(DbSetOrder(1))
	If !Softlock("ZZN") // Travar  ZZN
		_cMens := "Não foi possivel passar ZZN para exclusivo"
		Aadd(_aMsgErro,_cMens)
		Break	
	EndIf

	If _nRegZZN == 0
		_cAliasPesq 	:= GetNextAlias()
		BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
			SELECT 	MAX(ZZN.ZZN_CODPRV) AS NPREVISAO
			FROM  	%Table:ZZN% ZZN
			WHERE 	ZZN.%notDel% 
				AND ZZN.ZZN_FILIAL 	= %xFilial:ZZN%
		EndSql
		_cNumPrev := Soma1((_cAliasPesq)->NPREVISAO) 
		If Select(_cAliasPesq) <> 0
			(_cAliasPesq)->(DbCloseArea())
		Endif
	Else
		ZZN->(DbGoto(_nRegZZN))
		_cNumPrev := ZZN->ZZN_CODPRV
	Endif	

	If ! _lJob
		_oSay:SetText("Aguarde Atualizando itens Pedido de Venda ... Hora: "+Time() )
		ProcessMessage()
	Endif 
	_lGrava := .T.
	Begin Transaction
    	_cQuery := " UPDATE " + RetSqlName("SC6")+ " SC6 " 					+CrLf
    	_cQuery += " SET SC6.C6_XCODPVR = 	'" + _cNumPrev + "' "			+CrLf
		_cQuery += " 	,SC6.C6_XDTPVR = 	'" + DtOs(Date()) + "' "		+CrLf
		_cQuery += " 	,SC6.C6_XUSUPVR = 	'" + RetCodUsr() + "' "			+CrLf
    	_cQuery += " WHERE SC6.D_E_L_E_T_  	= ' ' "							+CrLf
		_cQuery += " 	AND SC6.C6_XFILPVR 	= '" + FwXFilial("ZZP") + "' "	+CrLf
    	_cQuery += "    AND SC6.C6_XCODPVR	= '" + _cCodImpPrev + "' "		+CrLf
    	_cQuery += "    AND SC6.C6_PEDCLI	<> ' ' "						+CrLf
    	_cQuery += "    AND SC6.C6_QTDVEN  	> SC6.C6_QTDENT "				+CrLf
    	_cQuery += "    AND SC6.C6_PEDCLI 	<> ' ' "						+CrLf
    	_cQuery += "    AND SC6.C6_NOTA     =  ' ' "						+CrLf
    	_cQuery += "    AND SC6.C6_BLQ      =  ' ' "						+CrLf

		_nStatus := TCSqlExec(_cQuery)
		If (_nStatus < 0)
			_cMens := "Problemas na Atualização dos itens (SC6) "+CrLf+TCSQLError() 
			Aadd(_aMsg,_cMens)
			_lGrava := .F.
		EndIf
		If _lGrava
			If ! _lJob
				_oSay:SetText("Aguarde Selecionando itens Previsao ... Hora: "+Time() )
				ProcessMessage()
			Endif
			_cAliasPrev 	:= GetNextAlias()
			BeginSql Alias _cAliasPrev //Define o nome do alias temporário 
    		    %NoParser%
				SELECT 	SC6.C6_CLI
						,SC6.C6_LOJA
						,SA1.A1_CGC
						,SC6.C6_PRODUTO
						,SC6.C6_XFABMOD
						,SC6.C6_XOPCION
						,SC6.C6_XMODVEI
						,SC6.C6_XSEGMOD
						,SC6.C6_XPRCTAB
						,SUM(SC6.C6_QTDVEN) AS QTPEDIDO
				FROM  	%Table:SC6% SC6 
   				JOIN 	%Table:SC5% SC5
					ON  SC5.%notDel% 
					AND SC5.C5_FILIAL 	= %xFilial:SC5%  
					AND SC5.C5_NUM 		= SC6.C6_NUM 	  
    		  	JOIN %Table:SA1% SA1
   					ON  SA1.%notDel%
					AND SA1.A1_FILIAL  	= %xFilial:SA1% 
   					AND SA1.A1_COD     	= SC6.C6_CLI 
   					AND SA1.A1_LOJA    	= SC6.C6_LOJA 
    			JOIN %Table:SB1% SB1
   					ON  SB1.%notDel%
    			    AND SB1.B1_FILIAL  	=  %xFilial:SB1% 
    			    AND SB1.B1_COD     	= SC6.C6_PRODUTO 
    			    AND SB1.B1_GRUPO   	= 'VEIA' 
				WHERE  	SC6.%notDel% 
					AND SC6.C6_XFILPVR 	= %xFilial:ZZP%  
					AND SC6.C6_XCODPVR 	= %Exp:_cNumPrev% 
    		 		AND SC6.C6_QTDVEN  	> SC6.C6_QTDENT 
    		 		AND SC6.C6_NOTA     = ' ' 
    		 		AND SC6.C6_BLQ      = ' ' 
				GROUP BY SC6.C6_CLI
						,SC6.C6_LOJA
						,SA1.A1_CGC
						,SC6.C6_PRODUTO
						,SC6.C6_XFABMOD
						,SC6.C6_XOPCION
						,SC6.C6_XMODVEI
						,SC6.C6_XSEGMOD
						,SC6.C6_XPRCTAB
				ORDER BY SC6.C6_CLI
						,SC6.C6_LOJA
						,SC6.C6_PRODUTO
						,SC6.C6_XFABMOD				
			EndSql
			If (_cAliasPrev)->(Eof())
				_cMens := "Nao localizado item do Pedido de Venda para a Previsao gerar Previsao" 
				Aadd(_aMsg,_cMens)
    		    _lGrava := .F. 
			Endif 
		Endif 
		If _lGrava	
			If ! _lJob
				_oSay:SetText("Aguarde Gravando itens Previsao ... Hora: "+Time() )
				ProcessMessage()
			Endif
			//Efetua a gravação ZZN e ZZP
			_aCab	:= {}
			_aItens := {}
			_cMens	:= ""
		
			Aadd(_aCab , {"ZZN_FILIAL"  , FwXFilial("ZZN") })	
			Aadd(_aCab , {"ZZN_CODPRV"  , _cNumPrev })	
			Aadd(_aCab , {"ZZN_STATUS"  , "A" 	})
			Aadd(_aCab , {"ZZN_DTINC"   , Date() })	
			Aadd(_aCab , {"ZZN_USUINC"  , RetCodUsr() })	
		
			While (_cAliasPrev)->(!Eof())
				_aAux := Aclone({})
				_nQtdeLib := (_cAliasPrev)->QTPEDIDO  * (_cAliasPrev)->C6_XPRCTAB 
				Aadd( _aAux, {"ZZP_FILIAL" , FwXFilial("ZZP") }) 
				Aadd( _aAux, {"ZZP_CODPRV" , _cNumPrev }) 
				Aadd( _aAux, {"ZZP_CODCLI" , (_cAliasPrev)->C6_CLI }) 
				Aadd( _aAux, {"ZZP_LOJCLI" , (_cAliasPrev)->C6_LOJA }) 
				Aadd( _aAux, {"ZZP_CNPJCP" , (_cAliasPrev)->A1_CGC }) 
				Aadd( _aAux, {"ZZP_CODPRD" , (_cAliasPrev)->C6_PRODUTO }) 
				Aadd( _aAux, {"ZZP_QTEPED" , (_cAliasPrev)->QTPEDIDO }) 
				Aadd( _aAux, {"ZZP_CHSDIS" , 0 }) 				//CHASSI QTDE
				Aadd( _aAux, {"ZZP_QTEDIS" , 0 }) 
				Aadd( _aAux, {"ZZP_QTELIB" , 0 }) 				//ZZP->ZZP_QTEPED - ZZP->ZZP_QTEDIS
				Aadd( _aAux, {"ZZP_QTEFAT" , 0 }) 
				Aadd( _aAux, {"ZZP_VLRTAB" , (_cAliasPrev)->C6_XPRCTAB }) 
				Aadd( _aAux, {"ZZP_TOTLIB" , _nQtdeLib }) 
				Aadd( _aAux, {"ZZP_MODVEI" ,  (_cAliasPrev)->C6_XMODVEI}) 
				Aadd( _aAux, {"ZZP_FABMOD" ,  (_cAliasPrev)->C6_XFABMOD}) 
				Aadd( _aAux, {"ZZP_OBS"    , Upper(_cMens) }) 
				Aadd( _aAux, {"ZZP_STATUS" , "A" }) 
				Aadd( _aAux, {"ZZP_DTINC"  ,  Date()}) 
				Aadd( _aAux, {"ZZP_USUINC" ,  RetCodUsr()}) 
				Aadd( _aAux, {"ZZP_DTALT"  ,  Date()}) 
				Aadd( _aAux, {"ZZP_USUALT" ,  RetCodUsr()}) 
				Aadd(_aItens, _aAux)
				(_cAliasPrev)->(DbSkip())
			EndDo 
			_lGrava := ZFAT25MVC( _cNumPrev, _aCab, _aItens, _nOper, _aMsg )
			If _lGrava
				_lRet := .T.
			Else
				DisarmTransaction()
			Endif	
		Endif
	End Transaction

End Sequence 

//Para liberar tabela pode estar presa no softlock
ZZN->(MsUnlock())

If !Empty(_cAliasPesq) .And. Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif
If !Empty(_cAliasPrev) .And. Select(_cAliasPrev) <> 0
	(_cAliasPrev)->(DbCloseArea())
	Ferase(_cAliasPrev+GetDBExtension())
Endif

Return _lRet



/*/{Protheus.doc} ZFAT25MVC
Modelo de Dados Gravar ZZP		
@author 	DAC CAOA
@since 		
@version 	undefined
@param 		
@type 		Static function
@ Obs		
@history    
*/
Static Function ZFAT25MVC( _cNumPrev, _aCab, _aItens, _nOper, _aMsg )
Local _nPos 		AS Numeric
Local _nCount 		AS Numeric
Local _oModel		AS Object
Local _oModelZZP	AS Object
Local _aLog			AS Array
Local _cLog			AS Character
Local _lRet 		AS Logical

Default _nOper 		:= 3
Default _cNumPrev	:= ""

Begin Sequence 
    // Capturando submodelos que possuem grid para preenchimento dos itens
    //_oModelZZN := oModel:GetModel("ZZNMASTER")
    //_oModelZZP := oModel:GetModel("ZZPDETAIL")
	//    _oModel:SetOperation(MODEL_OPERATION_INSERT)
	//Gravar dados 
	_lRet := .F. 
    _oModel := FWLoadModel( 'ZFATF025' )
    _oModel:SetOperation( _nOper )
    _oModel:Activate()

    For _nPos := 1 To Len( _aCab )       
        If !( _oModel:SetValue("ZZNMASTER", _aCab[_nPos,1], _aCab[_nPos,2] ) ) 
			Break 
        EndIf
    Next
	//Capiturar o grid
	DbSelectArea("ZZP")
	_oModelZZP := _oModel:GetModel("ZZPDETAIL")
	For _nPos := 1 To Len(_aItens)
		If _nPos > 1
         	 _oModelZZP:AddLine() //--Quando possui grid no modelo é necessario adicionar linha a linha
		Endif

		For _nCount := 1 To Len(_aItens[_nPos])
      		If !( _oModelZZP:SetValue(_aItens[_nPos, _nCount, 1], _aItens[_nPos, _nCount, 2] ) ) 
				_nReg := FieldPos(_aItens[_nPos, _nCount, 1])
        		Break
			Endif 
		Next _nCount
	Next _nPos

    If _oModel:VldData()
        _oModel:CommitData()
		_lRet := .T.
    Else
        _aLog  	:= _oModel:GetErrorMessage()
        _cLog 	:= ""
        For _nPos := 1 To Len(_aLog)
        	If !Empty(_aLog[_nPos]) .AND. _nPos = 6
                _cLog += Alltrim(_aLog[_nPos]) +  CRLF
            EndIf
        Next
		If !Empty(_cLog)
			Aadd(_aMsg, _cLog)
		Endif 
    EndIf       
End Sequence 
If ValType(_oModel) == "O"
	_oModel:DeActivate()
	_oModel:Destroy()
	_oModel := NIL
Endif
Return .T. 


/*/{Protheus.doc} MenuModelDef
Modelo de Dados 		
@author 	DAC
@since 		
@version 	undefined
@param 		
@type 		Static function
@ Obs		GAP228 -Integração Faturamento Autoware
@history    
/*/
Static Function ModelDef()
Local _oModel    := Nil
Local _oStruZZN  := FWFormStruct(1, "ZZN")
Local _oStruZZP  := FWFormStruct(1, "ZZP")

	_oModel := FWModelActive()
	// Cria o objeto do Modelo de Dados
	_oModel := MPFormModel():New('ZPF25MDL',  /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	_oModel:AddFields( 'ZZNMASTER', /*cOwner*/, _oStruZZN, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
   	_oModel:AddGrid('ZZPDETAIL','ZZNMASTER',_oStruZZP,/*bLinePreValid*/,/*bLinePosValid*/,/*bPreValid*/,/*bPosValid*/, /*bCarga*/)
 	_oModel:SetRelation("ZZPDETAIL",{{"ZZP_FILIAL","xFilial('ZZP')"},{"ZZP_CODPRV", "ZZN_CODPRV"}},ZZP->(IndexKey(1)))
	//_oModel:SetPrimaryKey({'ZO_FILIAL', 'ZO_CODIGO' })
    _oModel:SetPrimaryKey({})

   	//_oModel:GetModel( 'ZZNMASTER' ):SetOnlyQuery ( .T. )
   	//_oModel:GetModel( 'ZZPDETAIL' ):SetOnlyQuery ( .T. )

	// Adiciona a descricao do Modelo de Dados
    //_oModel:SetDescription("Previsão Faturamento")
	// Adiciona a descricao do Componente do Modelo de Dados
    _oModel:GetModel("ZZNMASTER"):SetDescription("Previsao Faturamento")

    // É necessário que haja alguma alteração na estrutura Field
    //_oModel:setActivate({ |_oModel| onActivate(_oModel)})
	/*
	If _oModel:IsActive() 
		_oModel:DeActivate() 
	EndIf
	_oModel:Activate()
	*/
Return _oModel


/*/{Protheus.doc} ViewDef
View 		
@author 	DAC
@since 		15/07/2023
@version 	undefined
@param 		
@type 		Static function
@ Obs		GAP228 -Integração Faturamento Autoware
@history    
/*/
Static Function ViewDef()
    Local _oModel       := ModelDef()                       // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    Local _oStruZZN     := FWFormStruct(2, "ZZN")           // Cria a estrutura a ser usada na View
    Local _oStruZZP     := FWFormStruct(2, "ZZP")           // Cria a estrutura a ser usada na View
    Local _oView         := Nil

	_oView:SetModel(_oModel)
	_oView:addField('ZA1MASTER', _oStruZZN)
	_oView:addGrid('ZA2DETAIL', _oStruZZP)

/*
    _oView := FWFormView():New()
    _oView:SetModel(_oModel)
    _oView:AddField("VIEW_ZZN" , _oStruZZN , "ZZNMASTER")
    _oView:AddGrid("VIEW_ZZP"  , _oStruZZP , "ZZPDETAIL")
    //Setando o dimensionamento de tamanho
    _oView:CreateHorizontalBox('PAI' ,20)
    _oView:CreateHorizontalBox('FILHO',80)

    //Amarrando a view com as box
    _oView:SetOwnerView('VIEW_ZZN','PAI')
    _oView:SetOwnerView('VIEW_ZZP','FILHO')

    //Habilitando título
    _oView:EnableTitleView('VIEW_ZZN','Cabeçalho - Previsão Faturamento')
    _oView:EnableTitleView('VIEW_ZZP','Itens - Previsão Faturamento')
*/
Return _oView


