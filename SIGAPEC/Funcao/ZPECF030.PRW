#include "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "DBINFO.CH"


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

// botões
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
#define DATA_FILIAL  	1
#define DATA_CODPRD  	2
#define DATA_DESPRD  	3
#define DATA_GRUPO  	4

//Estatistica de Vendas
#define DATA_MESREF  	1
#define DATA_QUANT  	2
#define DATA_FATURADO  	3
//Detalhes
#define DATA_DETDESC  	1
#define DATA_DETREF  	2


Static oZPEC08Peca  := DMS_Peca():New()
Static cSayDescPrd 	:= ""
//Static cSayUltCMP	:= ""
//Static cSayUltVND   := ""

//====================================

User Function ZPECF030
Begin Sequence
	Private FreWindow := FreAcWindow():New("SB1")	
	Private _cAliasPlan := ""
	Private _aFil     	 := {}
	//Private _OBrPlaneja
	Private oArea    
	Private oPanelVis
	Private _oBrRelac   
	Private	_aPrdREL 
	Private _oBrEstVenda   
	Private	_aPrdEstVenda
	Private _oBrDetalhe   
	Private	_aDetalhe

	//lPanel := .T.
	
	FreWindow:Init()
	FreWindow:Show()
End Sequence
If Select(_cAliasPlan) <> 0
	(_cAliasPlan)->(DbCloseArea())
	Ferase(_cAliasPlan+GetDBExtension())
Endif      
Return .T.


Static lFWCodFil 	:= .T.
//Static _cAliasPlan 	:= {}
Static _aColuna		:= {}
Class FreAcWindow
	Data oArea 			As Object
	// largura x altura
	Data nWidth 		As Object
	Data nHeight 		As Object
	// objetos auxiliares de interface
	Data oLayout 		As Object
	Data oSidebar 		As Object
	// painéis esquerdos
	Data oPanelSearch 	As Object
	Data oPanelChart 	As Object
	Data oPanelDados 	As Object // exclusivo para SE5
	// painéis centrais
	Data oPanelBrowse 	As Object
	Data oPanelVis 		As Object
	// painéis direitos	
	Data oPanelEVenda 	As Object
	Data oPanelDetalhe 	As Object
	// objetos necessários para a interface	
	Data oGetData 		As Object
	Data oPrn 			As Object
	Data _oBrPlan 		As Object
	Data oTOleContainer As Object
	Data oOle 			As Object
	Data oScroll 		As Object
	Data oBrwse 		AS Object
	Data oDlg 			As Object
	Data oTreeAccounts 	As Object

	Data aPergunte 		As Array
	Data oChart 		As Array

	Data oSayDescPrd 	As Object
	Data oSayUltCMP 	As Object
	Data oSayUltVND 	As Object

	Data cSayDescPrd 	As String
	//Data cSayUltCMP		As String
	//Data cSayUltVND 	As String

	// alias de trabalho	
	Data cAliasFile 	As String
	// construtor
	Method New() Constructor
	// construção de tela	
	Method CreateLeftColumn()
	Method CreateRightColumn()
	Method CreateCenterColumn()
	//Method FilterFile()
	// atualização
	Method Refresh()	
	Method RefreshSearch()
	Method RefreshPrd()
	// métodos accessors (get-set)
	Method GetPergSize()
	Method GetPerg()

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
	Method PesqSKU()

EndClass

/* ----------------------------------------------------------------------------

FreAcWindow:New()

Cria uma nova instância da classe FreAcWindow. 

Restrição: New() apenas inicializa os atributos. Para a construção de
interfaces é necessário a chamada do método Init().

---------------------------------------------------------------------------- */
Method New(cAliasFile) Class FreAcWindow
Begin Sequence
	Self:oDlg 			:= Nil
	Self:oArea 			:= Nil

	Self:nWidth  		:= GetScreenRes()[1] - 40
	Self:nHeight 		:= GetScreenRes()[2] - 200
	
	Self:oLayout 		:= Nil
	Self:oSidebar		:= Nil
		
	Self:cAliasFile 	:= cAliasFile
	Self:aPergunte 		:= {}

	Self:oPanelSearch 	:= Nil
	Self:oPanelChart 	:= Nil
	Self:oPanelDados 	:= Nil // Ferramentas

	// painéis centrais
	Self:oPanelBrowse	:= Nil
	Self:oPanelVis 		:= Nil

	// painéis direitos	
	Self:oPanelEVenda 	:= Nil
	Self:oPanelDetalhe 	:= Nil

	// objetos necessários para a interface	
	Self:oGetData 		:= Nil
	Self:oPrn 	    	:= Nil
	Self:_oBrPlan   	:= Nil 
	Self:oBrwse			:= Nil
	Self:oTOleContainer := Nil
	Self:oOle			:= Nil	
	Self:oScroll		:= Nil
	Self:aPergunte 		:= Nil
	Self:oChart 		:= Nil

	Self:oSayDescPrd 	:= Nil
	Self:oSayUltCMP 	:= Nil
	Self:oSayUltVND 	:= Nil


End Begin
Return Self

/* ----------------------------------------------------------------------------
FreAcWindow:Show()
Exibe a tela do gestor.
---------------------------------------------------------------------------- */
Method Show() Class FreAcWindow
	Self:oDlg:Activate()
Return

/* ----------------------------------------------------------------------------
FreAcWindow:CreateLeftColumn()
Cria os painéis do lado esquerdo, de acordo com o gestor utilizado:
Contas a Receber, Contas a Pagar ou Tesouraria:
---------------------------------------------------------------------------- */
Method CreateLeftColumn() Class FreAcWindow
Local _cPerg := "ZPECF030"

Begin Sequence
 	AjustaSX1(_cPerg)  //Verificar e ou criar o grupo de perguntas
	Self:oArea:AddCollumn(COL_LEFT , 20, .T.)
	Self:oArea:SetColSplit(COL_LEFT, CONTROL_ALIGN_RIGHT)
	// cria a janela de search
	Self:oArea:AddWindow(COL_LEFT, WND_SEARCH, "Pesquisa", 50, .T., .F.) //"Pesquisa"
	// cria o panel da pesquisa
	Self:oPanelSearch := Self:oArea:GetWinPanel(COL_LEFT, WND_SEARCH)
	Pergunte(Self:GetPerg(1), .T., , , Self:oPanelSearch, , @Self:aPergunte, .T., .F.)	
	FaMyBar(Self:oPanelSearch, , , , ;
          {{"Pesquisar", "Pesquisar", {||Self:PesqSKU(_cPerg)}}}, .F., .F.)	 //"Pesquisar"###"Pesquisar"
	//localiza faturamento, compras e produto
	LocFCP()
	Self:cSayDescPrd := SB1->B1_DESC //cSayDescPrd
	//Self:cSayUltCMP	 := cSayUltCMP
	//Self:cSayUltVND  := cSayUltVND

	_nLin1 := 30
	_nCol1 := 07
	_nCol2 := 65

	@ _nLin1, _nCol1 Say Self:oSayDescPrd Var Self:cSayDescPrd Size 200, 012 PIXEL OF Self:oPanelSearch
	_nLin1 += 20

	//@ _nLin1, _nCol1 Say "Ultima Compra" Size 71, 10 PIXEL OF Self:oPanelSearch 
	//@ _nLin1, _nCol2 Say Self:oSayUltCMP Var Self:cSayUltCMP Size 200, 012 PIXEL OF Self:oPanelSearch
	//_nLin1 += 10
	//@ _nLin1, _nCol1 Say "Ultima Venda" Size 71, 10 PIXEL OF Self:oPanelSearch 
	//@ _nLin1, _nCol2 Say Self:oSayUltVND Var Self:cSayUltVND Size 200, 012 PIXEL OF Self:oPanelSearch

	// Outras Ações
	Self:oArea:AddWindow(COL_LEFT, WND_TOOLS, "Ferramentas", 50, .T., .T.) 
	Self:oPanelDados := Self:oArea:GetWinPanel(COL_LEFT, WND_TOOLS)
	FaMyBar(Self:oPanelDados, , , {{1, "Pedido de Compras"		, {||ZPECF30CMP()},"PEDIDO"}}	, 	, .F., .F.)	 
	FaMyBar(Self:oPanelDados, , , {{2, "Listagem Entrada/Saida"	, {||ZPECF30KAR()},"FATIMG32"}}	, 	, .F., .F.)	 
	FaMyBar(Self:oPanelDados, , , {{3, "Invoice"				, {||ZPECF30INV()},"AVIAO"}}	,  	, .F., .F.)	 				  
  	FaMyBar(Self:oPanelDados, , , {{4, "Orçamento"				, {||ZPECF30ORC()},"PRECO"}} ,  	, .F., .F.)	 
	FaMyBar(Self:oPanelDados, , , {{5, "Picking"				, {||ZPECF30PIK()},"TMSIMG32"}}	,   , .F., .F.)	 
  	FaMyBar(Self:oPanelDados, , , {{6, "Saldo WIS"				, {||ZPECF30WIS()},"CONTAINR"}} ,  	, .F., .F.)	 

End Sequence
Return


/* ----------------------------------------------------------------------------
FreAcWindow:CreateCenterColumn()
Cria os painéis centrais, de acordo com o gestor utilizado: Contas a Receber,
Contas a Pagar ou Tesouraria:
---------------------------------------------------------------------------- */
Method CreateCenterColumn() Class FreAcWindow
Local _cPerg := "ZPECF030"
Local oColumn 	:= Nil
Local _aEdit	:= {}
Local _nPos

Begin Sequence
	oArea := Self:oArea
	// cria a coluna do meio	
	Self:oArea:AddCollumn(COL_CENTER, 65, .F.)
	Self:oArea:SetColSplit(COL_CENTER, CONTROL_ALIGN_LEFT)

	// visualização do planejamento
	Self:oArea:Addwindow(COL_CENTER, WND_VIS, "Consulta de Peças ", 70, .T., .F.) 
	Self:oPanelBrowse := Self:oArea:GetWinPanel(COL_CENTER, WND_VIS)

//	Self:oArea:AddWindow(COL_CENTER, WND_BROWSE, "Relacionamento", 25, .T., .F.)
//	Self:oPanelVis := Self:oArea:GetWinPanel(COL_CENTER, WND_BROWSE)
	//Carregar tela de saldos 
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(FwXFilial("SB1")+AllTrim(MV_PAR01)))
	_cDescr := AllTrim(SB1->B1_DESC)
	Self:oArea:AddWindow(COL_CENTER, WND_BROWSE, "Relacionamento ", 30, .T., .F.)
	Self:oPanelVis := Self:oArea:GetWinPanel(COL_CENTER, WND_BROWSE)

    //Campos tabela temporaria              
	_aColuna := {}
	//Campos que serão editados 
	Aadd(_aEdit,"TRB_QTDE") 
	 
    //funcionalidade para carga da tabela temporária
	LoadPlan()
    //aRotina := MenuDef2()
    //(_cAliasPlan)->(DbGotop()) 
    //tabela temporaria
    Self:_OBrPlan:=FWMBrowse():New(Self:oPanelBrowse)
    Self:_OBrPlan:SetTemporary(.T.) //Indica que o Browse utiliza tabela temporária
    //descrição do browse
   // Self:_OBrPlan:SetDescription('Consulta Produto Saldos')
    //tabela temporaria
    Self:_OBrPlan:SetAlias(_cAliasPlan)
    Self:_OBrPlan:SetUseFilter(.F.)
    Self:_OBrPlan:SetDBFFilter(.F.)                  
    Self:_OBrPlan:DisableDetails()
    Self:_OBrPlan:lHeaderClick:=.T.
    //Self:_OBrPlan:SetFields(_aColuna)
    //Self:_OBrPlan:DisableReport()
    Self:_OBrPlan:SetOwner(Self:oPanelBrowse)
	Self:_OBrPlan:SetPreEditCell({|| DbSelectArea(_cAliasPlan), .T.})
	//Self:_OBrPlan:SetEditCell(.T.)
	//Self:_OBrPlan:SetEditCell (.T., {|| .T. })
    Self:_OBrPlan:SetMenuDef('ZPECF30P') //funcionalidade corrente                        // Nome do fonte onde esta a função MenuDef
	//Self:_OBrPlan:lMaximized := .T.
	Self:_OBrPlan:AddButton("Itens Relacionados"  	, { || FWMsgRun(, {|| ZPECF30ITR() }, "Itens Relacionados"	, "Localizando") },,,, .F., 2 )  
	Self:_OBrPlan:AddButton("KIT"  					, { || FWMsgRun(, {|| ZPECF30KIT() }, "KIT"					, "Localizando") },,,, .F., 2 )  
	Self:_OBrPlan:AddButton("Visualizar Produto" 	, { || FWMsgRun(, {|| ZPECF30PRD() }, "Visualizar Produto"	, "Localizando") },,,, .F., 2 )  
    //Cria as colunas com base no array aCampos

    For _nPos := 1 To Len(_aColuna)
        xValor := _aColuna[_nPos,2]
        oColumn := FWBrwColumn():New()
        //oColumn:SetData({||_aFil[Self:_OBrPlan:nAt,_aColuna[_nPos,2]]})
        oColumn:SetData(&("{ ||" + xValor + " }"))
        oColumn:SetTitle(_aColuna[_nPos,1])
        oColumn:SetSize(_aColuna[_nPos,4])
        oColumn:SetDecimal(_aColuna[_nPos,5])
        oColumn:SetPicture(_aColuna[_nPos,6])
        oColumn:SetEdit(.T.)
        //Habilita a edição dos campos definidos no array aEditaveis
       // If aScan(_aEdit, _aColuna[_nPos,2]) > 0  
       //     oColumn:SetReadVar("M->"+_aColuna[_nPos,2])
       //     //oColumn:SetValid({|| ValidCampo(Str(_nPos)),Self:_OBrPlan:Refresh() })
       //     oColumn:SetValid({|| ValidCampo(Str(_nPos),Self:_OBrPlan) })
       // EndIf
        Self:_OBrPlan:SetColumns({oColumn})
    Next
	Self:SetDadosTitle('Consulta Produto '+If(Type("MV_PAR01") == "C" .And. !Empty(MV_PAR01),Alltrim(SB1->B1_DESC),""))
    //_OBrPlaneja := Self:_OBrPlan
	Self:_OBrPlan:Activate(Self:oPanelBrowse)
	Self:_OBrPlan:GoTop(.T.)
	Self:_OBrPlan:Refresh(.T.)

	ZPECF30KIT(.F.)
	// Define o Browse Relacionados
	_oBrRelac := FWBrowse():New(Self:oPanelVis)
	_oBrRelac:SetDataArray(.T.)
	_oBrRelac:SetArray(_aPrdREL)
	_oBrRelac:DisableConfig(.T.)
	_oBrRelac:DisableReport(.T.)
	_oBrRelac:DisableLocate(.T.)
	_oBrRelac:DisableFilter(.T.)
    _oBrRelac:SetOwner(Self:oPanelVis)

	_oBrRelac:SetDoubleClick({ || ZPECF30RE(_oBrRelac,_oBrRelac:nAt) , Self:PesqSKU(_cPerg), _oBrRelac:Refresh()    })	
	// Cria uma coluna de status
	// Adiciona as colunas do Browse
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||_aPrdREL[_oBrRelac:nAt,DATA_FILIAL]})
	oColumn:SetTitle("Filial" ) 
	oColumn:SetSize(4)
	_oBrRelac:SetColumns({oColumn})
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||_aPrdREL[_oBrRelac:nAt,DATA_CODPRD]})
	oColumn:SetTitle("Código Produto") 
	oColumn:SetSize(15)
	oColumn:SetDecimal(2)
	//oColumn:SetPicture("@!")
	_oBrRelac:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||_aPrdREL[_oBrRelac:nAt,DATA_DESPRD]})
	oColumn:SetTitle("Descrição Produto") 
	oColumn:SetSize(15)
	oColumn:SetDecimal(2)
	//oColumn:SetPicture("@!")
	_oBrRelac:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||_aPrdREL[_oBrRelac:nAt,DATA_GRUPO]})
	oColumn:SetTitle("Grupo Produto") 
	oColumn:SetSize(15)
	oColumn:SetDecimal(2)
	//oColumn:SetPicture("@!")
	_oBrRelac:SetColumns({oColumn})

	_oBrRelac:Activate()
	_oBrRelac:GoTop(.T.)
	_oBrRelac:Refresh(.T.)

End Begin
 //aRotina := ArotBKP	
Return Nil


/* ----------------------------------------------------------------------------
FreAcWindow:CreateRightColumn()
Cria os painéis do lado direito, de acordo com o gestor utilizado:
Contas a Receber, Contas a Pagar ou Tesouraria:
---------------------------------------------------------------------------- */
Method CreateRightColumn() Class FreAcWindow
Local oColumn := Nil
//Local oFREWINDOW := Self

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

	// Define o Browse Estatistica de Venda
	ZPECF30EVM()
	_oBrEstVenda := FWBrowse():New(Self:oPanelEVenda)
	_oBrEstVenda:SetDataArray(.T.)
	_oBrEstVenda:SetArray(_aPrdEstVenda)
	_oBrEstVenda:DisableConfig(.T.)
	_oBrEstVenda:DisableReport(.T.)
	_oBrEstVenda:DisableLocate(.T.)
	_oBrEstVenda:DisableFilter(.T.)
    _oBrEstVenda:SetOwner(Self:oPanelEVenda)
 	_oBrEstVenda:SetBlkBackColor({|| IIf(ZPEC30MCOR(_oBrEstVenda:nAt) , CLR_YELLOW , Nil )})
	//_oBrRelac:SetDoubleClick({ || lRet := .T., __cRet := aBrwData[_oBrRelac:nAt,2], oModal:DeActivate()    })	
	// Cria uma coluna de status
	// Adiciona as colunas do Browse

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||_aPrdEstVenda[_oBrEstVenda:nAt,DATA_MESREF]})
	oColumn:SetTitle("Ano/Mes" ) 
	oColumn:SetSize(6)
	oColumn:SetPicture("@R 9999/99")
	_oBrEstVenda:SetColumns({oColumn})
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||_aPrdEstVenda[_oBrEstVenda:nAt,DATA_QUANT]})
	oColumn:SetTitle("Quantidade") 
	oColumn:SetSize(TamSx3("D2_QUANT")[1])
	oColumn:SetDecimal(TamSx3("D2_QUANT")[2])
	oColumn:SetPicture("@E 99,999,999,999")  //PesqPict("SD2","D2_QUANT") conforme solicitação Vandre 07/07/2023
	_oBrEstVenda:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||_aPrdEstVenda[_oBrEstVenda:nAt,DATA_FATURADO]})
	oColumn:SetTitle("Faturamento") 
	oColumn:SetSize(TamSx3("D2_TOTAL")[1])
	oColumn:SetDecimal(TamSx3("D2_TOTAL")[1])
	oColumn:SetPicture(PesqPict("SD2","D2_TOTAL"))
	_oBrEstVenda:SetColumns({oColumn})

	_oBrEstVenda:Activate()
	_oBrEstVenda:GoTop(.T.)
	_oBrEstVenda:Refresh(.T.)

	//Detalhes
	ZPECF30DET()
	_oBrDetalhe := FWBrowse():New(Self:oPanelDetalhe)
	_oBrDetalhe:SetDataArray(.T.)
	_oBrDetalhe:SetArray(_aDetalhe)
	_oBrDetalhe:DisableConfig(.T.)
	//_oBrDetalhe:DisableReport(.T.)
	_oBrDetalhe:DisableLocate(.T.)
	_oBrDetalhe:DisableFilter(.T.)
    _oBrDetalhe:SetOwner(Self:oPanelDetalhe)

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||_aDetalhe[_oBrDetalhe:nAt,DATA_DETDESC]})
	oColumn:SetTitle("Descrição" ) 
	oColumn:SetSize(15)
	oColumn:SetPicture("@!")
	_oBrDetalhe:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||_aDetalhe[_oBrDetalhe:nAt,DATA_DETREF]})
	oColumn:SetTitle("Conteúdo" ) 
	oColumn:SetSize(30)
	oColumn:SetPicture("@!")
	_oBrDetalhe:SetColumns({oColumn})

	_oBrDetalhe:Activate()
	_oBrDetalhe:GoTop(.T.)
	_oBrDetalhe:Refresh(.T.)


End Sequence
Return Nil

/*/{Protheus.doc} ZPEC30MCOR
//Mudar a cor do registro de totalização na Estatistica de Vendas
@author DAC denilso
@since 04/07/2023
@version 1.0
@return Nil
@type Static function
/*/
Static Function ZPEC30MCOR(_nLinha)
Local _lRet := .F. 
//Tratar para ler como ultimo registro e registro onde esta a totalização
If Len(_aPrdEstVenda) > 0 .and. Len(_aPrdEstVenda) <= _nLinha .And. _aPrdEstVenda[_nLinha,2] > 0 .and. _aPrdEstVenda[_nLinha,4] == 0
	_lRet := .T.
Endif
Return _lRet

/* ----------------------------------------------------------------------------
FreAcWindow:SetBrowseTitle()
Altera o título do painel de navegação para o texto especificado cWindowTitle.
---------------------------------------------------------------------------- */
Method SetBrowseTitle(cWindowTitle) Class FreAcWindow
Return Self:oArea:SetWinTitle(COL_CENTER, WND_BROWSE, cWindowTitle)


/* ----------------------------------------------------------------------------
FreAcWindow:SetDadosTitle()
Altera o título do painel de visualização para o texto especificado
cWindowTitle.
---------------------------------------------------------------------------- */
Method SetDadosTitle(cWindowTitle) Class FreAcWindow
Return Self:oArea:SetWinTitle(COL_CENTER, WND_VIS, cWindowTitle)

/* ----------------------------------------------------------------------------
FreAcWindow:GetDadosTitle()
Método não implementado ainda.
---------------------------------------------------------------------------- */
Method GetDadosTitle() Class FreAcWindow
Return ""


/* ----------------------------------------------------------------------------
Funções auxiliares
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
Devolve a largura do painel oParent, utilizando o método ReadClientCorrs() para
ler as dimensões reais do painel.
---------------------------------------------------------------------------- */
Static Function DlgWidthPanel(oParent)
	Local nLargura := 0	
	oParent:ReadClientCoors()	
	nLargura := oParent:nWidth
Return nLargura


/* ----------------------------------------------------------------------------

FaMyBar()

Barra de botões padrão

---------------------------------------------------------------------------- */
Static Function FaMyBar(oDlg , bOk, bCancel, aButtons, aButText, lIsEnchoice, lSplitBar,lLegenda)
Local _nPos := 0
Local _nLin := 22
Local _nCol := 10
//Local _nLin2:= 12
Local _cVar := ""

DEFAULT aButtons	:= {}
DEFAULT aButText	:= {}
DEFAULT lIsEnchoice := .T.
DEFAULT lSplitBar 	:= .T.
DEFAULT lLegenda  	:= .F.

oButtonBar := FWFormBar():New(oDlg)
//Criacao dos botoes de Texto OK e Cancela quando nao for enchoicebar
If !Empty(bOk)
	oButtonBar:addOK(bOk, "Confirmar") //"Confirmar"
Endif
If !Empty(bCancel)
	oButtonBar:addClose(bCancel,"Fechar") //"Fechar"
Endif
//Criacao dos botoes de texto do usuario ou complementares
If Len(aButText) > 0
	For _nPos := 1 to Len(aButText)
		oButtonBar:AddUserBtn("",aButText[_nPos,2],aButText[_nPos,3],aButText[_nPos,2])
	Next
Endif
//Se a FAMYBAR esta sendo montada num browse e este tiver legenda alguns botoes padrao sao criados
If lLegenda
	oButtonBar:AddUserBtn("","Legenda",{|| U_FLegenda(FREWINDOW:cAliasFile, (FREWINDOW:cAliasFile)->(RECNO()))},"Legenda")
Endif
// criacao dos botoes de imagem do usuario ou complementares
If Len(aButtons) > 0
	//ASORT(aButtons,,, { |x, y| x[2] > y[2] } ) 
	_nLin := 10
	_nCol := 02
	For _nPos := 1 To Len(aButtons)
		If ValType(aButtons[_nPos,1]) == "N" .And. aButtons[_nPos,1] > 1
			//_nLin  := 40 * aButtons[_nPos,1]
			//_nLin2 := 20 * aButtons[_nPos,1]
			_nCol := (40 * aButtons[_nPos,1]) - 40
		ElseIf _nPos > 1
			//_nLin2 := 40 * _nPos
		Endif
		
		_cVar := aButtons[_nPos,2]
		//TBtnBmp2():New( 02,02,26,26		,'copyuser'			,,,,{||Alert("Botão 01")},oDlg,,,.T. )
 		TBtnBmp2():New( _nLin,_nCol,26,26,aButtons[_nPos,4]	,,,,aButtons[_nPos,3],oDlg,_cVar,,.T. )
		//oSay := TSay():New( _nLin2, _nCol+18,      { || _cVar        },  oDlg,,,,,,.T.)		
		//@ _nLin, _nCol+20 SAY _cVar  SIZE 025, 012 OF oDlg //COLORS 0, 16777215 PIXEL
		//@ _nLin, _nCol Say _cVar Size 200, 018 PIXEL OF oDlg
		//oButtonBar:AddUserBtn("MAGIC_BMP", aButtons[_nPos,2],aButtons[_nPos,3], "MAGIC_BMP","MAGIC_BMP")
	Next
EndIf
	//oView := FWFormView()
   //bBlocoMagic := {|oView| Myfunction(oView)}
   //oView:AddUserButton("Texto abaixo do botão","MAGIC_BMP",bBlocoMagic,"Comentário do botão")
If lIsEnchoice
	oButtonBar:addCalc()    
	oButtonBar:addSpool()  
//			oButtonBar:addImpCad()
//			oButtonBar:AddWalkThrough()
//			oButtonBar:AddAmbiente()
//			oButtonBar:AddMashup()  
//			oButtonBar:AddHelp()
Endif
oButtonBar:Activate()
Return Nil

/* ----------------------------------------------------------------------------
FreAcWindow:DimObj()
Devolve as dimensões do painel de visualização.
---------------------------------------------------------------------------- */
Method DimObj(cPanel) Class FreAcWindow
	Local oParent := NIL
	Self:oArea:GetWinPanel(COL_CENTER, WND_VIS)
	oParent:FreeChildren()
	aDim := DLGinPANEL(oParent)
Return aDim




/* ----------------------------------------------------------------------------
FreAcWindow:GetPerg()
Devolve o grupo de perguntas correspondente ao alias do painel.
---------------------------------------------------------------------------- */
Method GetPerg(_nPerg) Class FreAcWindow
Local _cPerg := ""
If _nPerg == 1
	_cPerg := "ZPECF030" 
Endif
Return _cPerg


/* ----------------------------------------------------------------------------
FreAcWindow:RefreshSearch()
Atualiza o painel de pesquisa caso o alias cAlias seja diferente do alias do
painel ou caso cAlias não seja passado.
---------------------------------------------------------------------------- */
Method RefreshSearch(cAlias) Class FreAcWindow
Local _cPerg := "ZPECF030"

Default cAlias := ""

Begin Sequence
	If Self:cAliasFile != cAlias
		Self:aPergunte := {}
		Self:oPanelSearch:FreeChildren()
		ResetMVRange()
		If !Empty(Self:GetPerg())				
			Pergunte(Self:GetPerg(), .T., , , Self:oPanelSearch, , ;
			         @Self:aPergunte, .T., .F.)
			FaMyBar(Self:oPanelSearch, , , , ;
			        {{"Pesquisar", "Pesquisar", {|| FwMsgRun(,{ || Self:PesqSKU(_cPerg)}, "Selecionando dados Referente Produto", "Aguarde...") }}}, .F.,.F.)	
		EndIf
	Endif
End Sequence	
Return Nil

/* ----------------------------------------------------------------------------
FreAcWindow:GetPergSize()
Devolve um array de duas dimensões no qual cada elemento do mesmo contém o
nome e tamanho de cada pergunta pertencente ao grupo de perguntas
associado ao alias do gestor.
---------------------------------------------------------------------------- */
Method GetPergSize() Class FreAcWindow
Local aSize := {}
aSize := FinReadSx1("ZPECF030")
Return aSize

/* ----------------------------------------------------------------------------
FinReadSx1()
Devolve um array de duas dimensões no qual cada elemento do mesmo contém o
nome e tamanho de cada pergunta pertencente ao grupo de perguntas cPerg
---------------------------------------------------------------------------- */
Static Function FinReadSx1(cPerg)
Local aArea := GetArea()
Local aAreaSX1 := SX1->(GetArea())
Local aSize := {}
Begin Sequence
	SX1->(dbSelectArea("SX1"))
	SX1->(dbSetOrder(1))
	SX1->(MsSeek(cPerg))
	While !SX1->(Eof()) .And. SX1->X1_GRUPO == PadR(cPerg, Len(SX1->X1_GRUPO))
		Aadd(aSize, {Upper(SX1->X1_VAR01), SX1->X1_TAMANHO})		
		SX1->(dbSkip())
	EndDo	
End Sequence	
SX1->(RestArea(aAreaSX1))
RestArea(aArea)
Return aSize


/* ----------------------------------------------------------------------------
FreAcWindow:Refresh()
Atualiza os painéis de pesquisa e de gráficos (caso o mesmo exista).
---------------------------------------------------------------------------- */
Method Refresh() Class FreAcWindow
	Self:RefreshSearch()
	Self:RefreshPrd()
Return Nil

/* ----------------------------------------------------------------------------
FreAcWindow:GetAlias()
Devolve o alias sendo utilizado pelo gestor.
---------------------------------------------------------------------------- */
Method GetAlias() Class FreAcWindow
Return Self:cAliasFile

/* ----------------------------------------------------------------------------
FreAcWindow:SetAlias()
Altera o alias sendo utilizado pelo gestor.
---------------------------------------------------------------------------- */
Method SetAlias(cAlias) Class FreAcWindow
	Self:cAliasFile := cAlias
Return Self:cAliasFile

/* ----------------------------------------------------------------------------
FreAcWindow:SetChartTitle()
Altera o título do painel de de gráficos para o texto especificado
cWindowTitle.
---------------------------------------------------------------------------- */
Method SetChartTitle(cWindowTitle) Class FreAcWindow
Return Self:oArea:SetWinTitle(COL_LEFT, WND_CHART, cWindowTitle)



/* ----------------------------------------------------------------------------
FreAcWindow:Init()
Inicializa o objeto FREWINDOW criando a interface gráfica para o gestor.
---------------------------------------------------------------------------- */
Method Init() Class FreAcWindow
Local aCoors := {}
Local lCloseButt := !(oAPP:lMdi)

Begin Sequence
	// a função CursorWait() altera o cursor apenas quando a rotina é chamada
	// pela primeira vez. Nas chamadas seguintes da função, o cursor não é
	// alterado. Chamando CursorArrow() força a CursorWait() mostrar o cursor
	// de ampulheta sempre.
	CursorArrow()
	CursorWait()
	aCoors := FWGetDialogSize(oMainWnd)
	DEFINE MSDIALOG Self:oDlg TITLE "PEÇAS" ; 
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
	Self:CreateRightColumn()

	CursorArrow()
End Sequence	
Return Nil

/* ----------------------------------------------------------------------------
FreAcWindow:GetVisPanel()
Devolve o painel no qual será mostra a visualização dos registros.
---------------------------------------------------------------------------- */
Method GetVisPanel() Class FreAcWindow
Return Self:oArea:GetWinPanel(COL_CENTER, WND_VIS)



/* ----------------------------------------------------------------------------
FreAcWindow:RefreshPrd()
Atualiza o painel de saldos. Não efetua nenhum recálculo de valores.
---------------------------------------------------------------------------- */
Method RefreshPrd() Class FreAcWindow
	Self:cSayDescPrd := cSayDescPrd
	//Self:cSayUltCMP	 := cSayUltCMP
	//Self:cSayUltVND  := cSayUltVND

	Self:oSayDescPrd:Refresh()
	//Self:oSayUltCMP:Refresh()
	//Self:oSayUltVND:Refresh()
Return Nil



/* ----------------------------------------------------------------------------
ShowViewPanel()
---------------------------------------------------------------------------- */
Method ShowViewPanel() Class FreAcWindow
Begin Sequence
	// verifica se o painel de visualização
	// está sendo mostrado
	If !Self:oArea:WinOpen(COL_CENTER, WND_VIS)
		// se não, mostra a janela
		Self:oArea:WinChgState(COL_CENTER, WND_VIS)
	EndIf
End Sequence	
Return Nil


/*/{Protheus.doc} PesqSKU
//TODO Função para localizar o SKU
@author denilso.almeida
@since 25/04/2024/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Method PesqSKU(_cPerg) Class FreAcWindow
Local _lRet    := .T.
Begin Sequence
	If Type("MV_PAR01") <> "C" .Or. Empty(MV_PAR01)
		_lRet := .F.
		Help( ,,"Atenção", , "Parametro referente a Produto não informado !",1,0)
		Break
	Endif 
	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(XFilial("SB1")+AllTrim(AllTrim(MV_PAR01))))
		Help( ,,"Atenção", , "Produto "+MV_PAR01+" não Locallizado !",1,0)
		_lRet := .F.
		Break
	Endif 
	//Atualizo o X1 para deixar sempre o ultimo registro selecionado
  	If SX1->(DbSeek( Padr(_cPerg,Len(SX1->X1_GRUPO))+"01")) 
  		RecLock("SX1",.F.)
  		SX1->X1_CNT01 := MV_PAR01
  		SX1->(MsUnlock()) 
  	Endif	
   	//Self:_OBrPlan:SetDescription('Consulta Produto '+If(Type("MV_PAR01") == "C" .And. !Empty(MV_PAR01),Alltrim(SB1->B1_DESC),""))
	Self:SetDadosTitle('Consulta Produto '+If(Type("MV_PAR01") == "C" .And. !Empty(MV_PAR01),Alltrim(SB1->B1_DESC),""))

  	//chamar funcao para carregar dados
  	LoadPlan()  //carrega planejamento
  	ZPECF30KIT(.F.)
	ZPECF30EVM()  //CARREGA ESTATISTICA DE VENDAS
	ZPECF30DET()  //CARREGA DETALHES
	LocFCP()  //carregar ultimo faturamento e compras, descrição produto
	
	//_oBrRelac:setArray(_aPrdREL)	
  	//_oBrRelac:refresh()
  	Self:_OBrPlan:GoTop(.T.)
	Self:_OBrPlan:Refresh(.T.)
	Self:oPanelVis:Refresh(.T.)
	Self:oPanelBrowse:Refresh(.T.) 
	Self:oPanelEVenda:Refresh(.T.)
	Self:oPanelDetalhe:Refresh(.T.)
	Self:oArea:Refresh(.T.) 
	Self:RefreshPrd()
End Sequence
Return _lRet





//Popular Tabrla Temporária
//============================================================================
Static Function LoadPlan()
//============================================================================
Local _cAliasTRB:= GetNextAlias()      
Local _aArea	:= GetArea()
Local _aCampos  := {}
Local _lRet   	:= .T.
Local _cCodProd := "" 
Local _cFilBK   := cFilAnt
Local _cFilDe	:= Replicate(" ",TamSx3("B1_FILIAL")[1])
Local _cFilAte	:= Replicate("Z",TamSx3("B1_FILIAL")[1])
Local cPerg 	:= "ZPECF030"
Local _cStatus	:= ""
Local _cWhereVS1:= ""
Local _cFaseOrc 	:= AllTrim(GetNewPar("MV_FASEORC","023R45F"))
Local _cFaseConf 	:= Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Local _cArmazemPad 	:= "11"  //este armazem sempre deve trazer
Local _cIndice1
Local _nPos
Local _lArmazemPad

//Local _aFil 	 := {}

Begin Sequence
	Pergunte(cPerg,.f.)
 	If Type("MV_PAR01") == "C"
 		_cCodProd  := AllTrim(MV_PAR01)
	Else
 		_cCodProd  := Space(Len(SB1->B1_COD))
 	Endif

 	//If Type("MV_PAR02") == "N"
	//	If MV_PAR02 == 2 //Todas as Filiais 1=Sim 2=Não
 	//		_cFilDe	 := FwXFilial("SB2")
 	//		_cFilAte := _cFilDe
	//	Endif
 	//Endif

 	SB1->(DbSetOrder(1))
  	If ValType(_aColuna) <> "A" .or. Len(_aColuna) == 0
  		_aColuna := {}
  		Aadd(_aColuna, {"Filial"		,"TRB_FILIAL"	,"C",Len(SB1->B1_FILIAL)	,00	,"@!" })
  		Aadd(_aColuna, {"Armazém"		,"TRB_LOCAL"	,"C",Len(SB1->B1_LOCPAD)	,00	,"@!" })
  		Aadd(_aColuna, {"Nome Armazém"	,"TRB_NOMELO"	,"C",Len(NNR->NNR_DESCRI)	,00	,"@!" })
  		Aadd(_aColuna, {"Qtde"			,"TRB_QTDE" 	,"N",TamSx3("B2_QATU")[1]	,02	,"@E 9999,999,999.99" })
  		Aadd(_aColuna, {"Orçamento"		,"TRB_ORC" 		,"N",TamSx3("B2_QATU")[1]	,02	,"@E 9999,999,999.99" })
  		Aadd(_aColuna, {"Picking"		,"TRB_PICKIN" 	,"N",TamSx3("B2_QATU")[1]	,02	,"@E 9999,999,999.99" })
  		Aadd(_aColuna, {"Disponível"	,"TRB_SALDOE"	,"N",TamSx3("B2_QATU")[1]	,02	,"@E 9999,999,999.99" })
  	Endif	
	//dados para tabela temporária
	//reorganizar posis rsta colocado como acols de browse
	For _nPos := 1 To Len(_aColuna)
		Aadd(_aCampos, {_aColuna[_nPos,2],;  //nome do campo
						_aColuna[_nPos,3],;	//tipo de compo
						_aColuna[_nPos,4],;	//tamanho do campo						
						_aColuna[_nPos,5],;	//decimal
						_aColuna[_nPos,1],;	//Descrição
						_aColuna[_nPos,6];	//pict
						})												  
	Next

	If !Empty(_cAliasPlan) .and. Select(_cAliasPlan) <> 0
		(_cAliasPlan)->(__dbZap())
		//Ferase(_cAliasPlan+GetDBExtension())
	Else
		//criar tabela temporaria
		_cAliasPlan   := CriaTrab(_aCampos,.T.)
		//Criar indices
		_cIndice1 := Alltrim(CriaTrab(,.F.))
		_cIndice1 := Left(_cIndice1,5) + Right(_cIndice1,2) + "A"

		//Se indice existir excluir
		If File(_cIndice1+OrdBagExt())
			FErase(_cIndice1+OrdBagExt())
			EndIf
		//A função dbUseArea abre uma tabela de dados na área de trabalho atual ou na primeira área de trabalho disponível
		DbUseArea(.T.,,_cAliasPlan,_cAliasPlan,.F.,.F.)
		//A função IndRegua cria um índice temporário para o alias especificado, podendo ou não ter um filtro
		IndRegua(_cAliasPlan, _cIndice1, "TRB_LOCAL+TRB_FILIAL"	,,, "Armazém...")
		//Fecha todos os índices da área de trabalho corrente.
		DbClearIndex()
		//Acrescenta uma ou mais ordens de determinado índice de ordens ativas da área de trabalho.
		DbSetIndex(_cIndice1+OrdBagExt())
	Endif	
    //Popular tabela temporária, irei colocar apenas um unico registro
	//verificar as fases até o processamento da fase de conferencia
	_cStatus := ""
	//_cFaseOrc := "023RTZ"  //tratar somente as fase 0, 2, R no momento
	For _nPos := 1 to Len(_cFaseOrc)
		If SubsTr(_cFaseOrc,_nPos,1) == _cFaseConf
			Exit
		Endif
		//Não colocar item ja reservado
		If SubsTr(_cFaseOrc,_nPos,1) <> "R"
			_cStatus += "'" +SubsTr(_cFaseOrc,_nPos,1)+ "',"
		Endif
	Next
	_cStatus := SubsTr(_cStatus,1,Len(_cStatus)-1)
	If Empty(_cStatus)
		MSGINFO( "Não existe fase de orçamento no parâmetro Fase", "[ZPECF030] - Atenção" )
		_lRet := .F.
		Break
	EndIf
	_cWhereVS1 += 	" AND VS1.VS1_STATUS IN  (" +_cStatus+ ") " 
	_cWhereVS1 := "%"+_cWhereVS1+"%"

	BeginSql Alias _cAliasTRB //Define o nome do alias temporário 
		SELECT 	  ISNULL(SB1.R_E_C_N_O_,0) NREGSB1
				, ISNULL(SB2.R_E_C_N_O_,0) NREGSB2
				, NNR.NNR_DESCRI DESCRI_LOCAL
				, (	SELECT SUM(VS3.VS3_QTDITE)
					FROM %Table:VS1% VS1 
					JOIN  %Table:VS3% VS3
						ON  VS3.%notDel%
						AND VS3.VS3_FILIAL 	= %xFilial:VS3%
						AND VS3.VS3_NUMORC 	= VS1.VS1_NUMORC
						AND VS3.VS3_CODITE  = SB1.B1_COD
					WHERE  VS1.%notDel%
						AND VS1.VS1_FILIAL = %xFilial:VS1%
						AND VS1.VS1_TIPORC 	= '1' 
						%Exp:_cWhereVS1%
				  ) AS ITENSORC	
				, (	SELECT SUM(VS3.VS3_QTDITE)
					FROM %Table:SZK% SZK 
					JOIN %Table:VS1% VS1			
						ON	VS1.%notDel%	
						AND	VS1.VS1_FILIAL  = %xFilial:VS1%
						AND VS1.VS1_XPICKI	= SZK.ZK_XPICKI 
						AND VS1.VS1_TIPORC 	= '1' 
           				AND VS1.%notDel%
					JOIN  %Table:VS3% VS3
						ON  VS3.%notDel%
						AND VS3.VS3_FILIAL 	= %xFilial:VS3%
						AND VS3.VS3_NUMORC 	= VS1.VS1_NUMORC
						AND VS3.VS3_CODITE  = SB1.B1_COD
					WHERE  SZK.%notDel%
						AND	SZK.ZK_NF		= ' '
						AND SZK.ZK_STATUS   NOT IN ('B','C','F')
						AND SZK.ZK_STREG	<> ' '
				  ) AS ITENSPIC	
		FROM 	%Table:SB1% SB1  
		JOIN 	%Table:SB2% SB2
			ON  SB2.B2_FILIAL 	BETWEEN %Exp:_cFilDe% AND %Exp:_cFilAte%
			AND SB2.B2_COD		= SB1.B1_COD  
			AND SB2.%notDel% 
			AND ( ( NVL( SB2.B2_QATU -  SB2.B2_RESERVA - SB2.B2_QACLASS  , 0) > 0 AND SB2.B2_LOCAL <> %Exp:_cArmazemPad%) OR 
					SB2.B2_LOCAL = %Exp:_cArmazemPad% )
		LEFT JOIN  %Table:NNR% NNR
			ON  NNR.%notDel%
			AND NNR.NNR_FILIAL 	= %xFilial:NNR%
			AND NNR.NNR_CODIGO 	= SB2.B2_LOCAL
    	WHERE 	SB1.B1_FILIAL 	= %Exp:FwXFilial("SB1")% 	  
    		AND SB1.B1_COD  	= %Exp:_cCodProd%
			AND SB1.%notDel% 
  	EndSql //Gera a consulta no alias informado anteriormente 
	//TCSetField(_cAliasTRB,'DATA','D',8,0)
	If (_cAliasTRB)->(Eof())  .Or. Empty(_cCodProd)
		_lRet := .F.
		Break
	Endif
	//Carregar as filiais 
	(_cAliasTRB)->(DbGotop())
	_lArmazemPad := .F. 
    While (_cAliasTRB)->(!Eof())
		SB1->(DbGoto((_cAliasTRB)->NREGSB1))
		SB2->(DbGoto((_cAliasTRB)->NREGSB2))
		cFilAnt 	:= SB2->B2_FILIAL
		_nSaldoSB2 	:= SB2->(SaldoSB2()) //FUNÇÃO PARA CALCULO EM ESTOQUE
   		If RecLock(_cAliasPlan,.T.)
   			_nSaldo := ( _nSaldoSB2 - ((_cAliasTRB)->ITENSORC ) )
			(_cAliasPlan)->TRB_FILIAL 	:= SB2->B2_FILIAL
   	   		(_cAliasPlan)->TRB_LOCAL 	:= SB2->B2_LOCAL
  	   		(_cAliasPlan)->TRB_NOMELO 	:= (_cAliasTRB)->DESCRI_LOCAL
   	   		(_cAliasPlan)->TRB_QTDE  	:= _nSaldoSB2
   	   		(_cAliasPlan)->TRB_ORC  	:= If(AllTrim(SB2->B2_LOCAL) == _cArmazemPad,(_cAliasTRB)->ITENSORC,0)
   	   		(_cAliasPlan)->TRB_PICKIN	:= If(AllTrim(SB2->B2_LOCAL) == _cArmazemPad,(_cAliasTRB)->ITENSPIC,0)
   	   		(_cAliasPlan)->TRB_SALDOE  	:= If(AllTrim(SB2->B2_LOCAL) == _cArmazemPad,_nSaldo, _nSaldoSB2)
   	   		(_cAliasPlan)->(MsUnLock())
			//caso possa não existir o armazem padrão a ser verificado devo preencher os valores de orçamento e picking no primeiro armazem 
			If SB2->B2_LOCAL == _cArmazemPad
				_lArmazemPad  := .T.
			Endif	
   		Endif
    	(_cAliasTRB)->(DbSkip())
    EndDo
	If _lRet .And. !_lArmazemPad 
		(_cAliasPlan)->(DbGotop())
		(_cAliasTRB)->(DbGotop())
		If (_cAliasTRB)->(!Eof()) .And. RecLock(_cAliasPlan,.F.)
   			_nSaldo := ( (_cAliasPlan)->TRB_QTDE - ((_cAliasTRB)->ITENSORC ) )
   	   		(_cAliasPlan)->TRB_ORC  	:= (_cAliasTRB)->ITENSORC
   	   		(_cAliasPlan)->TRB_PICKIN	:= (_cAliasTRB)->ITENSPIC
   	   		(_cAliasPlan)->TRB_SALDOE  	:= _nSaldo
   	   		(_cAliasPlan)->(MsUnLock())
		Endif
	Endif
	//Volto a filial pocicionada
	cFilAnt := _cFilBk
End Sequence
If ! _lRet
	//Adiciono o Saldo Inicial
  	If RecLock(_cAliasPlan,.T.)
		(_cAliasPlan)->TRB_FILIAL  	:= ""
   	   	(_cAliasPlan)->TRB_LOCAL 	:= ""
   	   	(_cAliasPlan)->TRB_QTDE  	:= 0
   	   	(_cAliasPlan)->TRB_ORC  	:= 0
   	   	(_cAliasPlan)->TRB_PICKIN	:= 0
   	   	(_cAliasPlan)->TRB_SALDOE  	:= 0 //_nSaldoSB2
   	   	(_cAliasPlan)->(MsUnLock())
   	Endif
EndIf
If Select(_cAliasTRB) <> 0
	(_cAliasTRB)->(DbCloseArea())
	Ferase(_cAliasTRB+GetDBExtension())
Endif      
RestArea(_aArea)
cFilAnt := _cFilBK
Return _lRet  





//==========================================================================
//funcionalidade para retornar as Pedido de Compras de acordo com o período
//==========================================================================
Static Function CalcEmpen()
Local _cAliasPesq 	:= GetNextAlias()
Local _cFilDe		:= Replicate(" ",TamSx3("ZD0_FILIAL")[1])
Local _cFilAte		:= Replicate("Z",TamSx3("ZD0_FILIAL")[1])
Local _nTotEmp  	:= 0
Local _cParTipo     := AllTrim(SuperGetMV('QA_PLANNFS', .F., "N"))
Local _cPerg 	 	:= "ZPECF030"
Local _cCodProd     := "  "
Local _dDataRes		:= dDataBase
Local _cVarTipo
Local _cVar
Local _nPos

Begin Sequence
	Pergunte(_cPerg,.f.)
 	If Type("MV_PAR01") == "C"
 		_cCodProd  := AllTrim(MV_PAR01)
 	Endif	
	_dDataRes := Date()
 	//If Type("MV_PAR02") == "N"
 		//pegar a data de acordo com a quantidade de dias  
 	//	_dDataRes := dDatabase + MV_PAR02
 	//Endif	 
 	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+_cCodProd))
	//atualizar para codigo chave B1_XCHAVE
	//_cCodBase  := SB1->B1_XCHAVE  //AllTrim(SubsTr(MV_PAR01,1,Len(ZD0->ZD0_CODBAS)))  
	_cCodBase  := AllTrim(SubsTr(MV_PAR01,1,Len(ZD0->ZD0_CODBAS)))  
	
	_nTotFat   	:= 0
	//Montar o tipo de taturamento
	_cVar 		:= ""
	_cVarTipo 	:= "'"

	For _nPos := 1 To Len(_cParTipo)
		If SubsTr(_cParTipo,_nPos,1) == ","
			_cVarTipo += (_cVar+"','")
			_cVar 		:= ""
		Endif
		_cVar 	+= SubsTr(_cParTipo,_nPos,1)
	Next 
	_cVarTipo	+= SubsTr(_cParTipo,_nPos,1)
	BeginSql Alias _cAliasPesq
 		SELECT  SC7.C7_PRODUTO,
 				SUM(SC7.C7_QUANT) C7_QUANT,
 				SUM(SC7.C7_QUJE)  C7_QUJE
    	FROM %Table:SC7% SC7                        
    	WHERE 	SC7.C7_FILIAL 	BETWEEN %Exp:_cFilDe% AND %Exp:_cFilAte% 	  
    		AND SC7.C7_EMISSAO 	<= %Exp:_dDataRes%    
    		AND SC7.C7_PRODUTO 	=  %Exp:_cCodProd%
    		AND SC7.C7_QUANT    >  0	
    		AND SC7.C7_QUJE 	< SC7.C7_QUANT
    		AND SC7.C7_RESIDUO 	=  ' '
    		AND SC7.C7_DATPRF   >= %Exp:dDataBase%
      		AND SC7.%notDel%
      	GROUP BY SC7.C7_PRODUTO	      
	EndSql  
	
	If	(_cAliasPesq)->(Eof())
		Break
	Endif		
	_nTotEmp += ( (_cAliasPesq)->C7_QUANT - (_cAliasPesq)->C7_QUJE)	
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif      

Return _nTotEmp



/*/{Protheus.doc} ValidCampo
//TODO Edição da tela de planejamento para gravar quando alterar.
@author denilso.almeida
@since 14/10/2019
@version 1.0
@return ${return}, ${return_description}
@param _oBrW, , descricao
@param _cCol, , descricao
@type function
/*/
Static Function ValidCampo(_cCol,_oBr)
Local _nPos := (_cAliasPlan)->(Recno())
 //Guarda o posicionamento do temporário
Local _aOrd 	:= SaveOrd(_cAliasPlan)
//Local _nPosLin 	:= Self:_oBrPlan:nAt
Local _nCol     := Val(_cCol)
Local _xRead    := TRIM(READVAR())
Local _xConteudo:= &_xRead
Begin Sequence
	//_oBrW:FWBrowse(): ColPos 
   	//Atualizar para que possa ser dado o refresh
   	If RecLock(_cAliasPlan,.F.)
   		If _xRead == "M->TRB_" 
   			(_cAliasPlan)->TRB_ := _xConteudo
   		Else
   			Break
   		Endif	
   	Endif		
   	(_cAliasPlan)->(MsUnLock())
End Sequence 
//(_cAliasPlan)->(DbGotop())
(_cAliasPlan)->(DbGoto(_nPos))
_oBr:Refresh()

 //Restaura o posicionamento da tabela
//Restord(_aOrd, .T.)
//Atualiza a tela/browse

 //oFinWindow:oPanelBrowse()
Return .T.


//Solicita a seleção do arquivo           
Static Function PesqAXLS(oPanelVis)
Local _cTipoArq	 := "Arquivos Texto (*.XLS)     | *.XLS |"
Local _cDirXls    := AllTrim(SuperGetMV( "IQA_XLSIORI"  ,,"Planejamento\xls" ))       //processamento
//Local _cArqXLS	:= 	cGetFile(_cTipoArq,"Selecione o arquivo que será analisado.",0,"SERVIDOR\"+_cDirXls,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE )
Local _cArqXLS	:= 	""

Begin Sequence
		_cArqXLS := cGetFile(_cTipoArq,"Selecione o arquivo que será analisado.",0,_cDirXls,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD , )
		If !Empty(_cArqXLs)
			oOle:= TOleContainer():New( 2, 2,560 ,284 ,oPanelVis,.T.,_cArqXLS )
			If !oOle:OpenFromFile(Alltrim(_cArqXLS),.F.)
				If File(_cArqXLS)
					oOle:DoVerbDefault()
				Endif
			Endif
		EndIF 
		
End Begin

Return .T. 


/*/{Protheus.doc} GravacPerg
//Gravar o Grupo de Perguntas do SX1
@author denilso.almeida
@since 11/10/2019
@version 1.0
@return ${return}, ${return_description}
@param _cPerg, , descricao
@type function
/*/
//ZPECF030
//Preparar/Carregar perguntas
//=============================================================================
Static Function AjustaSX1(_cPerg)
//=============================================================================
Local _aPerg    := {}
Local _aHelpPor := {}
Local _aHelpSpa := {}
Local _aHelpEng := {}   
Local _nPosHelp := 1 
Local _cChave
Begin Sequence
//  	DbSelectArea('SX1')
  	SX1->(DbSetOrder(1))
//  SX1->(DbSeek(_cPerg))   
//                0123456789012345678901234567890123456780   
	_cChave := PadR(_cPerg,Len(SX1->X1_GRUPO)) + "09"   //ajustar campo para não solicitar sem ser selecionado
	If SX1->(DbSeek(_cChave))
	    SX1->( RecLock( "SX1", .F. ) )
    	SX1->X1_PRESEL := 1
	Endif

  	Aadd(_aHelpPor,{ "Informar código do Produto     ",;
    	             ""})
  	//Aadd(_aHelpPor,{ "Mostrar todas as Filiais       ",;
    //	             "1=Sim 2=Não"})
  	_aHelpSpa := _aHelpPor
  	_aHelpEng := _aHelpPor
 
	//      X1_GRUPO         ,X1_ORDEM,X1_PERGUNT                ,X1_PERSPA,X1_PERENG,X1_VARIAVL,X1_TIPO ,X1_TAMANHO                    ,X1_DECIMAL                        ,X1_PRESEL ,X1_GSC,X1_VALID          ,X1_F3     ,X1_GRPSXG,X1_PYME,X1_VAR01   ,X1_DEF01     ,X1_DEFSPA1,X1_DEFENG1  ,X1_CNT01  ,X1_VAR02,X1_DEF02           ,X1_DEFSPA2   ,X1_DEFENG2   ,X1_CNT02 ,X1_VAR03, X1_DEF03         ,X1_DEFSPA3,X1_DEFENG3 ,X1_CNT03 ,X1_VAR04,X1_DEF04       ,X1_DEFSPA4,X1_DEFENG4,X1_CNT04,X1_VAR05 ,X1_DEF05             ,X1_DEFSPA5,X1_DEFENG5,X1_CNT05,HELP PORT     ,HELP SPANH          ,HELP INGLES        
  	Aadd(_aPerg, { _cPerg    ,"01"    ,"Informe o Produto ?"  ,""       ,""       ,"mv_ch1"  ,"C"     ,Round(TamSX3("B1_COD")[1],0)  ,Round(TamSX3("B1_COD")[2],0)      ,0         ,"G"   ,                  ,"SB1"     ,""       ,"S"    ,"mv_par01",""           ,""        ,""          ,""        ,""      ,""                 ,""           ,""           ,""       ,""      ,""                ,""        ,""         ,""       ,""      ,""             ,""        ,""        ,""      ,""       ,""                   ,""        ,""        ,""      ,_aHelpPor[_nPosHelp],_aHelpSpa[_nPosHelp],_aHelpEng[_nPosHelp]})
  	_nPosHelp ++
 //	Aadd(_aPerg, { _cPerg    ,"02"    ,"Todas as  Filiais ?"  ,""       ,""       ,"mv_ch2"  ,"N"     ,1  							,0      							,0         ,"C"   ,                  ,          ,""       ,"S"    ,"mv_par02","1=Sim"      ,""        ,""          ,""        ,""      ,"2=Não"                 ,""           ,""           ,""       ,""      ,""                ,""        ,""         ,""       ,""      ,""             ,""        ,""        ,""      ,""       ,""                   ,""        ,""        ,""      ,_aHelpPor[_nPosHelp],_aHelpSpa[_nPosHelp],_aHelpEng[_nPosHelp]})
  //	_nPosHelp ++

  	//Aadd(_aPerg, { _cPerg    ,"02"    ,"Período Planejamento ?"  ,""       ,""       ,"mv_ch2"  ,"N"     ,06  							,0                                 ,0         ,"G"   ,  				,          ,""       ,"S"    ,"mv_par02",""           ,""        ,""          ,""        ,""      ,""                 ,""           ,""           ,""       ,""      ,""                ,""        ,""         ,""       ,""      ,""             ,""        ,""        ,""      ,""       ,""                   ,""        ,""        ,""      ,_aHelpPor[_nPosHelp],_aHelpSpa[_nPosHelp],_aHelpEng[_nPosHelp]})
    //Verificar se existe grupo de perguntas caso não cadastrar
	ReplSx1(_cPerg,_aPerg)
End Begin  	
Return Nil
                       

/*---------------------------------------------------------------------------------------
{Protheus.doc} ReplSx1
Rdmake Responsável pela Gravação das perguntas referente a tabela SX1
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     DAC - Denilso Almeida Carvalho 20/04/2017
@version    Nao Informado
@since      Nao Informado  
@return    	Nil
@sample     Nao Informado
@obs        A Array _aPergs deve vir com duas posições a primeira com o nome do campo e a segunda com o conteúdo
@project    
@menu       Nao Informado
@history    PASSAR FUNCIONALIDADE PARA APLICAÇÕES GERAIS 
---------------------------------------------------------------------------------------*/
Static Function ReplSx1(_cPerg,_aPergs)		
Local _lNovo
LoCal _nPos
Local _nPosCol        
Local _nPosOrd
Local _nPosHlp
Local _nCol               
Local _cKey
Local _aHelpP := {}
Local _aHelpI := {}
Local _aHelpS := {}
Local _aEstru := {}

Default _cPerg   := ""
Default _aPergs  := {}

Begin Sequence
	If Len(_aPergs) == 0 .or. Empty(_cPerg) 
		Break	
	Endif

	 _aEstru := {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG", "X1_VARIAVL", "X1_TIPO" , "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL",;
				 "X1_GSC"  , "X1_VALID", "X1_F3"     , "X1_GRPSXG" , "X1_PYME"  , "X1_VAR01"  , "X1_DEF01", "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01" ,;
				 "X1_VAR02", "X1_DEF02", "X1_DEFSPA2", "X1_DEFENG2", "X1_CNT02" , "X1_VAR03"  , "X1_DEF03", "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03" ,;
				 "X1_VAR04", "X1_DEF04", "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04" , "X1_VAR05"  , "X1_DEF05", "X1_DEFSPA5", "X1_DEFENG5", "X1_CNT05" ,;
				 "HELPP"   ,"HELPS"    , "HELPI" }       

	For _nPos := 1 To Len(_aPergs)
        _aGrava  := _aPergs[_nPos]
		_nPosOrd := Ascan( _aEstru,  "X1_ORDEM"   ) 
		If _nPosOrd == 0  //Se não indicou a ordem não grava
		 	Loop		
		Endif 
		If SX1->(DbSeek( Padr(_cPerg,Len(SX1->X1_GRUPO))+ _aGrava[_nPosOrd])) 
			//_lNovo	:= .F.  
			Loop
		Else
			_lNovo	:= .T.  
		Endif	

		RecLock("SX1",_lNovo)
		_aHelpP := {}
		_aHelpI := {}
		_aHelpS := {}
    	For _nCol := 1 To Len(_aGrava) //A gravação é pelo tamanho informado mas segue a posição dos dados da estrutura
			//Não gravar quando não informado o dado
			If Valtype(_aGrava[_nCol]) == "U"
				Loop			
			Endif

			If ( _nPosCol := SX1->(FieldPos(AllTrim(_aEstru[_nCol]))) ) == 0 
				Loop
			Endif	

			SX1->( FieldPut(_nPosCol,_aGrava[_nCol]) )
		Next _nCol

		//Gravar o Help
		_nPosHlp := Ascan(_aEstru,"HELPP")		
		If _nPosHlp > 0 .and. Len(_aGrava) >= _nPosHlp
			_aHelpP := Aclone(_aGrava[_nPosHlp])			
		Endif
		_nPosHlp := Ascan(_aEstru,"HELPS")		
		If _nPosHlp > 0 .and. Len(_aGrava) >= _nPosHlp
			_aHelpS := Aclone(_aGrava[_nPosHlp])			
		Endif
		_nPosHlp := Ascan(_aEstru,"HELPI")		
		If _nPosHlp > 0 .and. Len(_aGrava) >= _nPosHlp
			_aHelpI := Aclone(_aGrava[_nPosHlp])			
		Endif
        If Len(_aHelpP) > 0
			_cKey := "P." + AllTrim( SX1->X1_GRUPO ) + AllTrim( SX1->X1_ORDEM ) + "." 
  			SX1->X1_HELP := _cKey 
		 	PutSX1Help(_cKey,_aHelpP,_aHelpI,_aHelpS,.T.) 
			//PutHelp( _cKey, _aHelpP, _aHelpI, _aHelpS, .T. )
		Endif
		SX1->(dbCommit())
		SX1->(MsUnLock())
		
	Next _nPos
End Sequence  
Return Nil





/*/{Protheus.doc} ZPECF30KIT
//Mostrar Kits
@author DAC denilso
@since 05/05/2023
@version 1.0
@parametro 				_lCarrega - indica se esta realizando o carregamento de variaveis neste momento não mostra kits utilizado para fazer atualização no browse
@return _lRet, Logico
@type Static function
/*/
Static Function ZPECF30KIT(_lCarrega)
Local _cCodItem		:= MV_PAR01
Local _cCodKit 		:= ""  	//verificar se o codigo do kit será o mesmo código com final KIT - CONFORME ALINHADO COM ZÉ SERA INCLUÍDO NO CADASTRO COM MESMO CÓDIGO DE PRODUTO ACRESCENTANDO NO FINAL KIT
Local _cGrupoKit	:= ""	//verificar se o grupo do kit sera o mesmo do grupo do produto normal - CONFORME ALINHADO COM ZÉ SIM DEVERÁ SER O MESMO GRUPO DO PRODUTO ORIGINAL	
Local _cTipo		:= "" 	//"1"  //tipo VEH = ITEM
Local _cWhere		:= ""
Local _cAliasPesq	:= GetNextAlias()
Local _lRet 		:= .T.

Default _lCarrega	:= .T.

Begin Sequence
	If !_lCarrega
		_lRet := .F.
		Break
	Endif
 	If ValType(_cCodItem) <> "C"
		_lRet := .F.
		Break
	Endif		
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+AllTrim(_cCodItem)))
	_cCodKit 	:= AllTrim(_cCodItem) //+"KIT"  	//verificar se o codigo do kit será o mesmo código com final KIT - CONFORME ALINHADO COM ZÉ SERA INCLUÍDO NO CADASTRO COM MESMO CÓDIGO DE PRODUTO ACRESCENTANDO NO FINAL KIT
 	_cGrupoKit	:= SB1->B1_GRUPO								//verificar se o grupo do kit sera o mesmo do grupo do produto normal - CONFORME ALINHADO COM ZÉ SIM DEVERÁ SER O MESMO GRUPO DO PRODUTO ORIGINAL	

	//_aPrdREL	:= {{Space(Len(SB1->B1_FILIAL)),Space(Len(SB1->B1_COD)),Space(Len(SB1->B1_DESC)),Space(Len(SB1->B1_GRUPO))}}
	_cWhere 	:= ""
	If VEH->(FieldPos("VEH_MSBLQL")) > 0
		_cWhere +=   " AND VEH.VEH_MSBLQL <> '1' "
	Endif
	If !Empty(_cTipo)
		_cWhere +=   " AND VEH.VEH_TIPO = '"+_cTipo+"'"
	Endif
	_cWhere := "%"+_cWhere+"%"

	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT 	ISNULL(VE8.R_E_C_N_O_,0)  NREGVE8
				,ISNULL(SB1.R_E_C_N_O_,0) NREGSB1
		FROM %Table:VE8% VE8	
		JOIN %Table:SB1% SB1
			ON	SB1.%notDel%
			AND SB1.B1_FILIAL 	= %XFilial:SB1%
			AND SB1.B1_COD		= VE8.VE8_CODITE
			AND SB1.B1_GRUPO    = VE8.VE8_GRUITE
		WHERE	VE8.%notDel% 	
			AND VE8.VE8_FILIAL 	= %XFilial:VE8%
			AND VE8.VE8_GRUKIT	= %Exp:_cGrupoKit% 
			AND VE8.VE8_CODKIT	= %Exp:_cCodKit%
		ORDER BY VE8.VE8_TIPO	
	EndSql
	//			AND (VEH.VEH_TIPO	= '1' OR VEH.VEH_TIPO	= '2')
	If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NREGVE8 == 0
		//MsgInfo("Não existe kit para o produto " +AllTrim(_cCodItem))	
		_lRet := .F.
		Break	
	EndIf	   
	_aPrdREL := {}
	//Verificar os itens dos KITs para saber se tem algun zerado caso tenha não ira utilizar o kit
	While (_cAliasPesq)->(!Eof())
		VE8->(DbGoto((_cAliasPesq)->NREGVE8))
		If (_cAliasPesq)->NREGSB1 > 0
			SB1->(DbGoto((_cAliasPesq)->NREGSB1))
		EndIf	
		Aadd(_aPrdREL,{	;
						VE8->VE8_FILIAL,;
						VE8->VE8_CODITE,;
						SB1->B1_DESC,;
						VE8->VE8_GRUITE;
						})
		(_cAliasPesq)->(DbSkip())
	EndDo
End Sequence
If !_lRet .Or. Len(_aPrdREL) == 0
	_aPrdREL	:= {{	Space(Len(SB1->B1_FILIAL)),;
						Space(Len(SB1->B1_COD)),;
						Space(Len(SB1->B1_DESC)),;
						Space(Len(SB1->B1_GRUPO));
					}}
EndIf
If Type("_oBrRelac") == "O"
	_oBrRelac:setArray(_aPrdREL)	
	_oBrRelac:GoTop(.T.)
	_oBrRelac:refresh(.T.)
Endif	
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 
Return _lRet



/*/{Protheus.doc} ZPECF30ITR
//itens relacionados
@author DAC denilso
@since 05/05/2023
@version 1.0
@parametro 				_lCarrega - indica se esta realizando o carregamento de variaveis neste momento não mostra kits utilizado para fazer atualização no browse
@return _lRet, Logico
@type Static function
/*/
Static Function ZPECF30ITR(_lCarrega)
Local _lRet			:= .T.
Local _cCodItem		:= MV_PAR01
Local _cDescPRd		:= ""
Local _aItemRelac	
Local _cCodSubst
Local _cGrupoSubst 
Local _nPos

Default _lCarrega	:= .T.

Begin Sequence
 	If ValType(_cCodItem) <> "C"
		_lRet := .F.
		Break
	Endif		
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+AllTrim(_cCodItem)))
	oZPEC08Peca:SetGrupo(SB1->B1_GRUPO)
	oZPEC08Peca:SetCodigo(_cCodItem)
	_aItemRelac := oZPEC08Peca:ItensSubstituidos()

	If Len(_aItemRelac) == 0 .or. Empty(AllTrim(_aItemRelac[1,2]))
		//	"Não existe item Substitutos para o produto " +AllTrim(_cCodItem)
		_lRet := .F.
		Break	
	Endif
	_aPrdREL 	:= {}
	_cDescPRd 	:= SB1->B1_DESC
	For _nPos := 1 To Len(_aItemRelac)
		_cGrupoSubst	:= _aItemRelac[_nPos,1]
		_cCodSubst 		:= AllTrim(_aItemRelac[_nPos,2])
		_nSaldoSB2 		:= _aItemRelac[_nPos,7]
		Aadd(_aPrdREL,{	;
						FwXFilial("VE9"),;
						_cCodSubst,;
						SB1->B1_DESC,;
						_cGrupoSubst;
						})
	Next
End Sequence
If !_lRet .Or. Len(_aPrdREL) == 0
	_aPrdREL	:= {{	Space(Len(FwXFilial("VE9"))),;
						Space(Len(SB1->B1_COD)),;
						Space(Len(SB1->B1_DESC)),;
						Space(Len(SB1->B1_GRUPO));
					}}
EndIf
If Type("_oBrRelac") == "O"
	_oBrRelac:SetDescription( "Itens Relacionados Produto "+_cCodItem+" "+_cDescPRd )
	_oBrRelac:setArray(_aPrdREL)	
	_oBrRelac:GoTop(.T.)
	_oBrRelac:refresh()
Endif	

Return _lRet




/*/{Protheus.doc} ZPECF30PRD
//Mostrar Produto
@author DAC denilso
@since 12/05/2023
@version 1.0
@return Nil
@type Static function
/*/
Static Function ZPECF30PRD()
Private cCadastro := "Consulta Produto "+MV_PAR01
SB1->(dbSetOrder(1))
SB1->(DbSeek(FwXFilial("SB1")+AllTrim(MV_PAR01)))
FWMsgRun(, {|oSay| AxVisual("SB1", SB1->(Recno()),2) }) 
Return NIL


/*/{Protheus.doc} ZPECF30EVM
//Mostrar Estatisticas de vendas
@author DAC denilso
@since 24/05/2023
@version 1.0
@return Nil
@type Static function
/*/
Static Function ZPECF30EVM()
Local _cAliasPesq 	:= GetNextAlias()
Local _cCodProd     := AllTrim(MV_PAR01)
Local _dDataIni		:= dDatabase
Local _dDataFim		:= dDatabase
Local _cFilDe		:= Replicate(" ",TamSx3("D2_FILIAL")[1])
Local _cFilAte		:= Replicate("Z",TamSx3("D2_FILIAL")[1])
Local _nPeriodo     := SuperGetMV('CMV_PEC042', .F., 365)
Local _lRet 		:= .T.
Local _nTotFat 		:= 0
Local _nTotQuant	:= 0
Local _nRegistros 	:= 0							

Begin Sequence
	_aPrdEstVenda 	:= {}

	//retiro o periodo de avaliação da data inicial
	_dDataIni -= _nPeriodo
    //pegar a data de acordo com a quantidade de dias  
	//Montar o tipo de taturamento
	BeginSql Alias _cAliasPesq
 		SELECT  SUBSTR(SD2.D2_EMISSAO,1,6) D2_EMISSAO
				, SUM(SD2.D2_QUANT) QUANT
				, SUM(SD2.D2_TOTAL) NTOTMESFAT
				, MAX(SD2.R_E_C_N_O_) NREGSD2
    	FROM %Table:SD2% SD2        
		JOIN  %Table:SF4% SF4  
			ON	SF4.F4_FILIAL  	= %xFilial:SF4%
			AND SF4.F4_CODIGO  	= SD2.D2_TES
			AND SF4.F4_ESTOQUE 	= 'S'
			AND SF4.F4_DUPLIC 	= 'S'
			AND SF4.%notDel%
    	WHERE 	SD2.D2_FILIAL 	BETWEEN %Exp:_cFilDe% AND %Exp:_cFilAte% 	  
    		AND SD2.D2_COD  	= %Exp:_cCodProd%
			AND SD2.D2_EMISSAO  BETWEEN %Exp:_dDataIni% AND %Exp:_dDataFim%
      		AND SD2.%notDel%      
		GROUP BY SUBSTR(D2_EMISSAO,1,6)
		ORDER BY SUBSTR(D2_EMISSAO,1,6) DESC
	EndSql

	If	(_cAliasPesq)->(Eof())
		_lRet := .F.
		Break
	Endif		

	_nTotFat 	:= 0
	_nTotQuant	:= 0
	_nRegistros := 0							

	While (_cAliasPesq)->(!Eof())
		Aadd(_aPrdEstVenda,{	(_cAliasPesq)->D2_EMISSAO,;
								(_cAliasPesq)->QUANT,;	
								(_cAliasPesq)->NTOTMESFAT,;
								(_cAliasPesq)->NREGSD2 ;
						})
		_nTotFat 	+= (_cAliasPesq)->NTOTMESFAT
		_nTotQuant	+= (_cAliasPesq)->QUANT
		_nRegistros ++							
		(_cAliasPesq)->(DbSkip())
	EndDo	
	Aadd(_aPrdEstVenda,{	StrZero(_nRegistros,6),;
							Round(_nTotQuant/_nRegistros,3),;	
							Round(_nTotFat/_nRegistros,2),;
							0 ;
						})

End Sequence

If !_lRet 
	Aadd(_aPrdEstVenda,{	Space(TamSx3("D2_EMISSAO")[1]) ,;
							0,;
							0;
						})
Endif						
If Type("_oBrEstVenda") == "O"
	_oBrEstVenda:setArray(_aPrdEstVenda)	
	_oBrEstVenda:GoTop(.T.)
	_oBrEstVenda:refresh(.T.)
EndIf
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif      
Return Nil



/*/{Protheus.doc} ZPECF30DET
//Mostrar Detalhes
@author DAC denilso
@since 03/07/2023
@version 1.0
@return Nil
@type Static function
/*/
Static Function ZPECF30DET()
Local _cAliasPesq 	:= GetNextAlias()
Local _cCodProd     := MV_PAR01
Local _lRet 		:= .T.
Local _cFilDe		:= Replicate(" ",TamSx3("D2_FILIAL")[1])
Local _cFilAte		:= Replicate("Z",TamSx3("D2_FILIAL")[1])
Local _dDataFAT  	:= CtoD(Space(08))
Local _dDataCMP  	:= CtoD(Space(08))
Local _nDiasFat     := 0
Local _nQtdeFat 	:= 0 
Local _nValFat  	:= 0
Local _nValTab 		:= 0
Local _lProcUF 		:= .T.  ////indica que deve procurar a UF para verificação valores customizados
Local _cAtivo		:= "1"
Local _cCurvaABC	:= ""
Local _aArmazen		:= {"01","11"}
Local _nSaldoWis01	:= 0
Local _nSaldoWis11 	:= 0
Local _nCustoMedio	:= 0
Local _cMarca		:= ""
Local _nRegSD2
Local _cCampo
Local _lRetUsu
Local _nPos

Begin Sequence
	//Verifico se possuo vendas dentro da estatistica de vendas ja foi selecionado
	If Len(_aPrdEstVenda) > 0 .and. !Empty(_aPrdEstVenda[1,1]) 
		_nRegSD2  := _aPrdEstVenda[1,4]
		SD2->(DbGoto(_nRegSD2))
 		_dDataFAT := SD2->D2_EMISSAO
		_nQtdeFat := SD2->D2_QUANT
		_nValFat  := SD2->D2_TOTAL
	    _nDiasFat := Date() - _dDataFAT
	Endif		
	//procurar compras
	BeginSql Alias _cAliasPesq
 		SELECT MAX(SD1.D1_EMISSAO)  DATA_CMP 
    	FROM %Table:SD1% SD1  
     	INNER JOIN %Table:SF4% SF4  
            ON  SF4.%notDel%
            AND SF4.F4_FILIAL = %xFilial:SF4%
     		AND SF4.F4_CODIGO = SD1.D1_TES 
     		AND SF4.F4_ESTOQUE= 'S'
     	WHERE SF4.%notDel% 
            AND SD1.D1_FILIAL   BETWEEN %Exp:_cFilDe% AND %Exp:_cFilAte%
     		AND SD1.D1_COD      = %Exp:_cCodProd%
     		AND SD1.D1_QUANT    <> '0' 
	EndSql  
	If	(_cAliasPesq)->(!Eof())
		_dDataCMP := StoD((_cAliasPesq)->DATA_CMP)
	Endif		
	(_cAliasPesq)->(DbCloseArea())
	//Procurar Preço de Venda
	_cData := DtoS(Date()) //DtOS(_dDataFAT)  //ultimo valor de vendas
    BeginSql Alias _cAliasPesq
        SELECT 	DA1_PRCVEN 
				, DA1.R_E_C_N_O_ AS NREGDA1
        FROM %Table:DA0% DA0
        INNER JOIN %Table:DA1% DA1
            ON  DA1.DA1_FILIAL = %xFilial:DA1%
            AND DA1.DA1_CODTAB = DA0_CODTAB
            AND DA1.DA1_CODPRO = %Exp:_cCodProd%
            AND DA1.%NotDel%
        WHERE DA0.DA0_FILIAL = %xFilial:DA0%
			AND DA0.DA0_ATIVO	= %Exp:_cAtivo%
			AND %Exp:_cData% BETWEEN DA0.DA0_DATDE AND DA0.DA0_DATATE
			AND DA0.%notDel%
    EndSql
	//AND DA0.DA0_ATIVO	= %Exp:_cAtivo%	  //não utilizar ativo pois é o ultimo valor faturamento
	//	LEFT JOIN %Table:SA2% SA2	
    //        ON  SA2.%notDel%
    //        AND SA2.A2_FILIAL = %xFilial:SA2%
	//		AND SA2.A2_COD    = %Exp:SD2->D2_CLIENTE%
	//		AND SA2.A2_LOJA   = %Exp:SD2->D2_LOJA%

	If (_cAliasPesq)->(!Eof()) .and. (_cAliasPesq)->NREGDA1 > 0
		DA1->(DbGoto((_cAliasPesq)->NREGDA1))
		If _lProcUF
			_cCampo 	:= "DA1_X"+SD2->D2_EST
			_nValTab 	:= DA1->(FieldGet(FieldPos(_cCampo)))
		Else
			_nValTab 	:= DA1->DA1_PRCVEN	
		EndIf	
	EndIf
	(_cAliasPesq)->(DbCloseArea())
	//Localizar a curva ABC
	BeginSql Alias _cAliasPesq
 		SELECT  NVL(SZO.R_E_C_N_O_,0) AS NREGSZO
				,COALESCE(SBM.BM_CODMAR,' ') AS MARCA
    	FROM %Table:SB1% SB1
		LEFT JOIN %Table:SZO% SZO
			ON  SZO.%notDel%   
			AND SZO.ZO_FILIAL   BETWEEN %Exp:_cFilDe% AND %Exp:_cFilAte%
			AND SZO.ZO_COD      = SB1.B1_COD
    	LEFT JOIN %Table:SBM% SBM	
    		ON  SBM.%notDel%
			AND SBM.BM_FILIAL 	= %xFilial:SBM%
    		AND SBM.BM_GRUPO 	= SB1.B1_GRUPO 
     	WHERE   SB1.%notDel% 
            AND SB1.B1_FILIAL 	= %xFilial:SB1%
     		AND SB1.B1_COD      = %Exp:_cCodProd%
	EndSql  
	If (_cAliasPesq)->(!Eof())  
		If (_cAliasPesq)->NREGSZO > 0
			SZO->(DbGoto((_cAliasPesq)->NREGSZO))
			_cCurvaABC 	:= AllTrim(SZO->ZO_CURVQTD) + AllTrim(SZO->ZO_CURVCUS)
			_cMarca   	:= SZO->ZO_MARCA 
		Endif 
		/*If (_cAliasPesq)->CUSTO_MEDIO > 0
			_nCustoMedio := (_cAliasPesq)->CUSTO_MEDIO
		Endif	*/
	EndIf
	//prioridade marca encontrada no select SBM
	If !Empty((_cAliasPesq)->MARCA)
		_cMarca := (_cAliasPesq)->MARCA
	Endif

	_nCustoMedio := NoRound(U_ZGENCST(_cCodProd),TamSx3("B2_CM1")[02])

	_nSaldoWis01 := 0
	_nSaldoWis11 := 0

	For _nPos := 1 To Len(_aArmazen)
		If _aArmazen[_nPos] == "01"
			_nSaldoWis01 += U_zSaldoWis(_cCodProd, _cMarca, _aArmazen[_nPos])
		Else	
			_nSaldoWis11 += U_zSaldoWis(_cCodProd, _cMarca, _aArmazen[_nPos])
		Endif
	Next

	_aDetalhe 	:= {}
	Aadd(_aDetalhe,{"Cod.  Produto"		, _cCodProd})
	Aadd(_aDetalhe,{"Desc. Produto"		, SB1->B1_DESC})
	Aadd(_aDetalhe,{"Data Inclusão"		, DtoC(SB1->B1_XDTINC)})
	Aadd(_aDetalhe,{"Ultima Compra"		, DtoC(_dDataCMP) })
	Aadd(_aDetalhe,{"Ultima Venda"		, DtoC(_dDataFAT) })
	Aadd(_aDetalhe,{"Dias sem movto"	, Transform(_nDiasFat		, "@E 999,999,999,999" )})
	Aadd(_aDetalhe,{"Curva ABC"			, _cCurvaABC})
	Aadd(_aDetalhe,{"Minimo Venda"		, Transform(SB1->B1_LOTVEN	,PesqPict("SB1","B1_LOTVEN") )})
	Aadd(_aDetalhe,{"Saldo Wis BAR"		, Transform(_nSaldoWis01	,PesqPict("SB2","B2_QATU") )})
	Aadd(_aDetalhe,{"Saldo Wis FDR"		, Transform(_nSaldoWis11	,PesqPict("SB2","B2_QATU") )})
	Aadd(_aDetalhe,{"Preço de Venda"	, Transform(_nValTab		, "@E 999,999,999.99")})
	_lRetUsu :=  U_ZGENUSER( RetCodUsr() ,"ZPECF30DET" ,.F.)
	//somente se possuir alteração
	If _lRetUsu
		Aadd(_aDetalhe,{"Custo Médio"	, Transform(_nCustoMedio				, "@E 9999,999,999.99")})
	EndIf

End Sequence

If !_lRet 
	Aadd(_aDetalhe,{"", ""})
Endif						
If Type("_oBrDetalhe") == "O"
	_oBrDetalhe:setArray(_aDetalhe)	
	_oBrDetalhe:GoTop(.T.)
	_oBrDetalhe:refresh(.T.)
EndIf
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif      
Return Nil


/*/{Protheus.doc} ZPECF30PIK
//Mostrar Picking de itens
@author DAC denilso
@since 26/05/2023
@version 1.0
@return Nil
@type Static function
/*/
Static Function ZPECF30PIK()
Local _cCodProd     := AllTrim(MV_PAR01)
	FWMsgRun(, {|oSay| U_ZPECF031(_cCodProd) }) 
	MV_PAR01 		:= _cCodProd
Return Nil



/*/{Protheus.doc} ZPECF30ORC
//Mostrar Orcamentos de itens
@author DAC denilso
@since 01/06/2023
@version 1.0
@return Nil
@type Static function
/*/
Static Function ZPECF30ORC()
Local _cCodProd     := MV_PAR01
	FWMsgRun(, {|oSay| U_ZPECF032(_cCodProd) }) 
	MV_PAR01 		:= _cCodProd

Return Nil



/*/{Protheus.doc} ZPECF30INV
//Mostrar Invoices
@author DAC denilso
@since 01/06/2023
@version 1.0
@return Nil
@type Static function
/*/
Static Function ZPECF30INV()
Local _cCodProd     := MV_PAR01
	FWMsgRun(, {|| U_ZPECF027(_cCodProd) }) 
	MV_PAR01 		:= _cCodProd

Return Nil


/*/{Protheus.doc} ZPECF30KAR
//Listagem Entrada e Saida
@author DAC denilso
@since 01/06/2023
@version 1.0
@return Nil
@type Static function
/*/
Static Function ZPECF30KAR()
Local _cCodProd     := MV_PAR01
	U_ZPECF033(_cCodProd) 
	MV_PAR01 		:= _cCodProd
Return Nil


/*/{Protheus.doc} ZPECF30CMP
//Mostrar pendencias PC e ou PO
@author DAC denilso
@since 01/06/2023
@version 1.0
@return Nil
@type Static function
/*/
Static Function ZPECF30CMP()
Local _cCodProd     := MV_PAR01
	FWMsgRun(, {|| U_ZPECF034(_cCodProd) }) 
	MV_PAR01 		:= _cCodProd
Return Nil


/*/{Protheus.doc} ZPECF30RE
//Modificar código de pesquisa com duplo click
@author DAC denilso
@since 01/06/2023
@version 1.0
@return Nil
@type Static function
/*/
Static Function ZPECF30RE(_oBrRelac,_nPos)
Local _cCodProd := ""
_cCodProd 	:= _aPrdREL[_nPos,2]
MV_PAR01 	:= _cCodProd
Return .T.



//==========================================================================
//funcionalidade para retornar data da ultima Fatura
//==========================================================================
Static Function LocFCP()
Local _cAliasPesq 	:= GetNextAlias()
//Local _dDataFAT  	:= CtoD(Space(08))
//Local _dDataCMP  	:= CtoD(Space(08))
Local _cDescri      := Space(30)
Local _cCodProd     := MV_PAR01
//Local _cVar
//Local _nPos
Begin Sequence
	//procurar produto
    SB1->(DbSetOrder(1)) 
    SB1->(DbSeek(FwXFilial("SB1")+_cCodProd))
	_cDescri := SB1->B1_DESC
	cSayDescPrd := _cDescri
	//cSayUltCMP	 := DtoC(_dDataCMP)
	//cSayUltVND  := DtoC(_dDataFAT)
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif      
Return Nil


/*/{Protheus.doc} ZPECF30WIS
//Mostrar Saldos Wis
@author DAC denilso
@since 05/06/2023
@version 1.0
@return Nil
@type Static function
/*/
Static Function ZPECF30WIS
Local _cCodProd     := MV_PAR01
	FWMsgRun(, {|| U_ZPECF035(_cCodProd) }) 
	MV_PAR01 		:= _cCodProd
Return Nil
