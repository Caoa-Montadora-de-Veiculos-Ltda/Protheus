#Include "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "TOTVS.ch"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWBROWSE.CH"
#Include "FWMVCDEF.CH"

//Browse Relacionados
#define DATA_CLIENTE  	1
#define DATA_LOJA  		2
#define DATA_CNPJCPF  	3
#define DATA_NOMCLI  	4
#define DATA_LC 		5
#define DATA_TOTCLI 	6
#define DATA_SALDOLC 	7

#define DATA_PRODUTO 	1
#define DATA_DESCPRD	2
#define DATA_QTDEPRD    3
#define DATA_QTDEPREV	4
#define DATA_SALDOPRD	5

Static _cAliasZF026
Static _aPrevisao    := {}


/*/{Protheus.doc} ZFATF026
Previsão de Faturamento
@author     DAC - Denilso 
@since      26/06/2023
@version    1.0
@obs        Tela esta relacionada com a funcionalidade ZPECF030 a mesma poderá ser colocada também no menu com a chamada ZPECF032 caso seja necessário adaptar parametros para a procura  
/*/

User Function ZFATF026(_nOpc, _cFilPrev, _cCodPrev)
Local _aArea        := GetArea()
Local _cTitulo      := "Previsão Faturamento "
Local _aCoors 		:= FWGetDialogSize( oMainWnd )
//Local _cAliasZF026   := ""
Local _aEdit  		:= {}
Local _oDlgPrev
Local _oFWLayer
Local _oPanelUp
Local _oPanelDow
Local _oFolder
Local _oColumn
Local _nPos
Local _aFolders
Local _aButtons

Private _oBrw
Private _oBrWCli
Private _oBrWPrd
Private _oBrWRes
Private _AREFCLI
Private _AREFPRD
Private _AREFRES

Default _cFilPrev 		:= FwXFilial("ZZP") 
Default _cCodPrev  		:= ""
Default _nOpc			:= 0

//Private M->ZZP_QTELIB	:= 0

Begin Sequence 
	If _nOpc == 0 .Or. Empty(_cCodPrev)
		Break
	Endif
 	FwMsgRun(,{ |_oSay| ZFATF026PR(_cFilPrev, _cCodPrev, @_oSay ) }, "Selecionando dados para a Montagem Previsao", "Aguarde...")  
	//acrescentar campos editaveis
	Aadd( _aEdit,"ZZP_QTELIB")
    //Abre arquivo selecionado
	DbSelectArea(_cAliasZF026)
	Define MsDialog _oDlgPrev Title _cTitulo From _aCoors[1], _aCoors[2] To _aCoors[3], _aCoors[4] Pixel
		
	//-- Cria o conteiner
	_oFWLayer := FWLayer():New()
	_oFWLayer:Init( _oDlgPrev, .F.)

	//-- Define Painel Superior
	_oFWLayer:AddLine( 'UP', 60, .F. )
	_oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	_oPanelUp := _oFWLayer:GetColPanel( 'ALL', 'UP' )
	
	//-- Define Painel inferior
	_oFWLayer:AddLine( 'DOW', 40, .F. )
	_oFWLayer:AddCollumn( 'ALL', 100, .T., 'DOW' )
	_oPanelDow := _oFWLayer:GetColPanel( 'ALL', 'DOW' )

 	DbSelectArea(_cAliasZF026)
 	_oBrw := FWMBrowse():New()
	_oBrw:SetCanSaveArea(.T.)	//abertura de mais de uma  browse
	_oBrw:SetTemporary(.T.)
    //_oBrw:SetOwner(_oTPanel01)
    _oBrw:SetAlias(_cAliasZF026)	
	_oBrw:SetMenuDef('')
	//_oBrw:SetFields(_aPrevisao)
    _oBrw:SetOwner(_oPanelUp)
    _oBrw:SetIgnoreARotina(.T.) // Indica que a mbrowse, ira ignorar a variavel private aRotina na construção das opções de menu.
    _oBrw:SetWalkThru(.F.)
    _oBrw:DisableConfig() // Desabilita a utilização do Browse
    _oBrw:SetAmbiente(.F.) //Habilita a utilização da funcionalidade Ambiente no Browse
    _oBrw:SetFixedBrowse(.T.)
	_oBrw:DisableDetails()
    //_ObrW:ForceQuitButton()     
	//Definimos o título que será exibido como método SetDescription
	_oBrw:SetDescription(_cTitulo + _cCodPrev)
    //Definimos a tabela que será exibida na Browse utilizando o método SetAlias
    //Legenda da grade, é obrigatório carregar antes de montar as colunas
    //A=ABERTO;F=FATURADO;C=CANCELADO
	
	_oBrw:AddLegend("AllTrim(ZZP_STATUS) = 'A'  "  ,"WHITE"     ,"Em Aberto")
	_oBrw:AddLegend("AllTrim(ZZP_STATUS) = 'L'  "  ,"GREEN"     ,"Liberado Fat")
    _oBrw:AddLegend("AllTrim(ZZP_STATUS) = 'F'  "  ,"BLUE" 	   	,"Faturado")
	_oBrw:AddLegend("AllTrim(ZZP_STATUS) = 'C'  "  ,"RED"       ,"Cancelado")
	_oBrw:AddLegend("AllTrim(ZZP_STATUS) <> ' '  " ,"GRAY"      ,"Pendente")
	
	_oBrw:SetPreEditCell({|| DbSelectArea(_cAliasZF026), .T.})
    _oBrw:SetEditCell( .T. , { || .T. } )
    _oBrw:lHeaderClick := .F.
    For _nPos := 1 To Len(_aPrevisao)
        _xValor := _aPrevisao[_nPos,2]
        _oColumn := FWBrwColumn():New()
        //oColumn:SetData({||_aFil[Self:_OBrPlan:nAt,_aColuna[_nPos,2]]})
        _oColumn:SetData(&("{ ||" + _xValor + " }"))
        _oColumn:SetTitle(_aPrevisao[_nPos,1])
        _oColumn:SetSize(_aPrevisao[_nPos,4])
        _oColumn:SetDecimal(_aPrevisao[_nPos,5])
        _oColumn:SetPicture(_aPrevisao[_nPos,6])
        _oColumn:SetEdit(.T.)
        //Habilita a edicao dos campos quando for alteração
        If _nOpc == 4 .And. Ascan(_aEdit,_xValor) > 0   
            (_cAliasZF026)->(_oColumn:SetReadVar(_aPrevisao[_nPos,2]))
            //_oColumn:SetValid({|| ValidCampo(Str(_nPos), _cAliasZF026, _ObrW ),_ObrW:Refresh() })
            _oColumn:SetValid({|| ValidCampo(Str(_nPos), _ObrW ) })
       //     oColumn:SetValid({|| ValidCampo(Str(_nPos),Self:_OBrPlan) })
        EndIf
        _ObrW:SetColumns({_oColumn})
    Next
	//mudanca de linha
	_ObrW:setChange({ || ZFT26Change() })

   //Ativamos a classe
    _ObrW:Refresh(.T.)
	_ObrW:Activate()

    //Carregar valores totais ZFATF015
	_aPosSize := {0,0,0,0}
	_aPosSize[3] := 670
	_aPosSize[4] := 85
	_aFolders := {"Resumo","Totais Cliente","Totais Produto"}
	_oFolder := TFolder():New(_aPosSize[1],_aPosSize[2],_aFolders,_aFolders,_oPanelDow,,,,.T.,.T.,_aPosSize[3],_aPosSize[4])

	ZFAT026Total(_cFilPrev, _cCodPrev, /*_lCarrega*/)
	// Define o Browse Relacionados Produto
	_oBrWRes := FWBrowse():New()
	_oBrWRes:SetDataArray(.T.)
	_oBrWRes:SetArray(_aRefRes)
	_oBrWRes:DisableConfig(.T.)
	_oBrWRes:DisableReport(.T.)
	_oBrWRes:DisableLocate(.T.)
	_oBrWRes:DisableFilter(.T.)
    _oBrWRes:SetOwner(_oFolder:aDialogs[1])
	ZFAT026MRes()
	_oBrWRes:Activate()
	_oBrWRes:GoTop(.T.)
	_oBrWRes:Refresh(.T.)

	// Define o Browse Relacionados
	_oBrWCli := FWBrowse():New(_oPanelDow)
	_oBrWCli:SetDataArray(.T.)
	_oBrWCli:SetArray(_aRefCli)
	_oBrWCli:DisableConfig(.T.)
	_oBrWCli:DisableReport(.T.)
	_oBrWCli:DisableLocate(.T.)
	_oBrWCli:DisableFilter(.T.)
    _oBrWCli:SetOwner(_oFolder:aDialogs[2])
	ZFAT026MCli()
	_oBrWCli:Activate()
	_oBrWCli:GoTop(.T.)
	_oBrWCli:Refresh(.T.)

	// Define o Browse Relacionados Produto
	_oBrWPrd := FWBrowse():New(_oPanelDow)
	_oBrWPrd:SetDataArray(.T.)
	_oBrWPrd:SetArray(_aRefPrd)
	_oBrWPrd:DisableConfig(.T.)
	_oBrWPrd:DisableReport(.T.)
	_oBrWPrd:DisableLocate(.T.)
	_oBrWPrd:DisableFilter(.T.)
    _oBrWPrd:SetOwner(_oFolder:aDialogs[3])
	ZFAT026MPrd()
	_oBrWPrd:Activate()
	_oBrWPrd:GoTop(.T.)
	_oBrWPrd:Refresh(.T.)

    //_oDlgPrev:Activate()
	_aButtons := {}
	Activate MsDialog _oDlgPrev On Init EnchoiceBar(_oDlgPrev,{	|| ZFATF026End(_nOpc, _cFilPrev, _cCodPrev), _oDlgPrev:End() },;
																{||If(ZFATF026End(_nOpc, _cFilPrev, _cCodPrev, .T.),_oDlgPrev:End(), .T.)},,_aButtons)

End Sequence
If ValType(_cAliasZF026) == "C" .And. Select((_cAliasZF026)) <> 0
	(_cAliasZF026)->(DbCloseArea())
	//Ferase(_cTable+GetDBExtension())
    //_oTable:Delete()
Endif      

RestArea(_aArea)
Return Nil


// Cria uma coluna de Clientes com totais
// Adiciona as colunas do Browse
Static Function ZFAT026MCli()
//Local _oColumn
	_oBrWCli:SetColumns({ ZFT26StruCpo("ZZP_CODCLI"	, {||_aRefCli[_oBrWCli:nAt,DATA_CLIENTE]},	"Cliente") })
	_oBrWCli:SetColumns({ ZFT26StruCpo("ZZP_LOJCLI"	, {||_aRefCli[_oBrWCli:nAt,DATA_LOJA]},		"Loja") })
	_oBrWCli:SetColumns({ ZFT26StruCpo("ZZP_CNPJCP"	, {||_aRefCli[_oBrWCli:nAt,DATA_CNPJCPF]}, 	"CNPJ/CPF") })
	_oBrWCli:SetColumns({ ZFT26StruCpo("A1_NOME"	, {||_aRefCli[_oBrWCli:nAt,DATA_NOMCLI]}, 	"Razao Social") })
	_oBrWCli:SetColumns({ ZFT26StruCpo("ZZP_TOTLIB"	, {||_aRefCli[_oBrWCli:nAt,DATA_LC]}, 		"Limite Credito R$") })
	_oBrWCli:SetColumns({ ZFT26StruCpo("ZZP_QTELIB"	, {||_aRefCli[_oBrWCli:nAt,DATA_TOTCLI]},	"Total Cliente") })
	_oBrWCli:SetColumns({ ZFT26StruCpo("ZZP_TOTLIB"	, {||_aRefCli[_oBrWCli:nAt,DATA_SALDOLC]},	"Saldo Credito R$") })
Return Nil

//Cria cabeçalho e coluna totalização por produto
Static Function ZFAT026MPrd()
	_oBrWPrd:SetColumns({ ZFT26StruCpo("ZZP_CODPRD"	, {||_aRefPrd[_oBrWPrd:nAt,DATA_PRODUTO]},	"Produto") })
	_oBrWPrd:SetColumns({ ZFT26StruCpo("B1_DESC"	, {||_aRefPrd[_oBrWPrd:nAt,DATA_DESCPRD]}, 	"Desc Prd") })
	_oBrWPrd:SetColumns({ ZFT26StruCpo("ZZP_QTELIB"	, {||_aRefPrd[_oBrWPrd:nAt,DATA_QTDEPRD]},	"Estoque") })
	_oBrWPrd:SetColumns({ ZFT26StruCpo("ZZP_QTELIB"	, {||_aRefPrd[_oBrWPrd:nAt,DATA_QTDEPREV]}, "Em Previsao") })
	_oBrWPrd:SetColumns({ ZFT26StruCpo("ZZP_QTELIB"	, {||_aRefPrd[_oBrWPrd:nAt,DATA_SALDOPRD]},	"Saldo") })
Return Nil


//Cria cabeçalho e coluna totalização por produto
//ZFT26StruCpo(_xCampo, _bCampo, _cTitulo, _nSize, _nDecimal, _cPicture )
Static Function ZFAT026MRes()
	_oBrWRes:SetColumns({ ZFT26StruCpo("ZZP_CODPRD"	, {||_aRefRes[_oBrWRes:nAt,DATA_PRODUTO]}	,"Referencia") })
	_oBrWRes:SetColumns({ ZFT26StruCpo("B1_DESC"	, {||_aRefRes[_oBrWRes:nAt,DATA_DESCPRD]}	,"Desc Prd") })
	_oBrWRes:SetColumns({ ZFT26StruCpo("ZZP_QTELIB"	, {||_aRefRes[_oBrWRes:nAt,DATA_QTDEPRD]}	,"Estoque") })
	_oBrWRes:SetColumns({ ZFT26StruCpo("ZZP_QTELIB"	, {||_aRefRes[_oBrWRes:nAt,DATA_QTDEPREV]}	,"Em Previsao") })
	_oBrWRes:SetColumns({ ZFT26StruCpo("ZZP_QTELIB"	, {||_aRefRes[_oBrWRes:nAt,DATA_SALDOPRD]}	,"Saldo") })
	
Return Nil


/*/{Protheus.doc} ZFATF026PR
Processar Pedido 
@author     DAC - Denilso 
@since      
@version    1.0
@obs        
/*/

Static Function ZFATF026PR(_cFilPrev, _cCodPrev, _oSay)
Local _cWhere       := ""
Local _nPos
Local _aStru
Local _oTable
Local _cQuery
Local _aCpoCab
   
Begin Sequence
    _aCpoCab := {}
    Aadd( _aCpoCab, {"ZZP", "ZZP_FILIAL"  	,.T.})		//filial
    Aadd( _aCpoCab, {"ZZP", "ZZP_CODPRV"  	,.T.})		//cod previsao
    Aadd( _aCpoCab, {"ZZP", "ZZP_CODCLI"  	,.T.})		//cod cliente
    Aadd( _aCpoCab, {"ZZP", "ZZP_LOJCLI"   	,.T.})		//loja cliente
    Aadd( _aCpoCab, {"SA1", "A1_NOME"  	    ,.T.}) 		//Nome cliente
    Aadd( _aCpoCab, {"ZZP", "ZZP_CNPJCP"  	,.T.}) 		//cnpj cpf
    Aadd( _aCpoCab, {"ZZP", "ZZP_CODPRD"  	,.T.}) 		//cod produto
    Aadd( _aCpoCab, {"SB1", "B1_DESC"  	    ,.T.}) 		//descricao produto
    Aadd( _aCpoCab, {"ZZP", "ZZP_MODVEI"  	,.T.}) 		//modelo do veiculo
    Aadd( _aCpoCab, {"ZZP", "ZZP_FABMOD"  	,.T.}) 		//Ano do veiculo
    Aadd( _aCpoCab, {"ZZP", "ZZP_QTEPED"  	,.T.}) 		//qtde pedido
    Aadd( _aCpoCab, {"ZZP", "ZZP_QTELIB"  	,.T.}) 		//qtde liberada
    Aadd( _aCpoCab, {"ZZP", "ZZP_QTEFAT"  	,.T.}) 		//qtde faturada
    Aadd( _aCpoCab, {"ZZP", "ZZP_VLRTAB"  	,.T.}) 		//valor unitario
    Aadd( _aCpoCab, {"ZZP", "ZZP_TOTLIB"  	,.T.}) 		//valor unitario
    Aadd( _aCpoCab, {"ZZP", "ZZP_STATUS"  	,.F.}) 		//STATUS
	aAdd( _aCpoCab, {"ZZP", "NREGZZP"     	, "N","Recno"    , 10, 0, "@!",.F. /*não ncluir no browse*/})

    _aPrevisao    := {}
    _aStru      := {}  //Estrutura do Banco
    For _nPos := 1 To Len(_aCpoCab)
        If Len(_aCpoCab[_nPos]) == 3
            _aTamSx3 := TamSX3(_aCpoCab[_nPos,2])
            If _aCpoCab[_nPos,Len(_aCpoCab[_nPos])]  //Valida se a coluna irá para o Browse
                Aadd(_aPrevisao,{ RetTitle(_aCpoCab[_nPos,2]),;    //titulo
                                _aCpoCab[_nPos,2],;             //campo
                                _aTamSx3[03],;                  //tipo
                                _aTamSx3[01],;                  //tamanho
                                _aTamSx3[02],;                  //decimal
                                PesqPict(_aCpoCab[_nPos,1],_aCpoCab[_nPos,2]),;  //pict
                                AllTrim(SX3->(X3Cbox())) ;                  //Combo
                          })
            Endif
            Aadd(_aStru, {_aCpoCab[_nPos,02], _aTamSx3[03], _aTamSx3[01], _aTamSx3[02] })
        Else  
            If _aCpoCab[_nPos,Len(_aCpoCab[_nPos])]  //Valida se a coluna irá para o Browse
                Aadd(_aPrevisao,{ _aCpoCab[_nPos,4],;             //titulo
                                _aCpoCab[_nPos,2],;             //campo
                                _aCpoCab[_nPos,3],;             //tipo
                                _aCpoCab[_nPos,5],;             //tamanho    
                                _aCpoCab[_nPos,6],;             //decimal
                                _aCpoCab[_nPos,7],;             //pict
                                "";                             //Combo
                                })
            Endif
            Aadd(_aStru, { _aCpoCab[_nPos,02], _aCpoCab[_nPos,03], _aCpoCab[_nPos,05], _aCpoCab[_nPos,06] })
        Endif
    Next

    _oTable := FWTemporaryTable():New()
    _oTable:SetFields(_aStru)
    _oTable:AddIndex("INDZFT261", {"ZZP_CODPRV", "ZZP_CODCLI", "ZZP_LOJCLI", "ZZP_CODPRD"} )
    _oTable:Create()
    _cAliasZF026 := _oTable:GetAlias()

    _cTable := _oTable:GetRealName()
	_cWhere     := ""

    _cQuery := " INSERT INTO "+_cTable+"                                                                                    "+(Chr(13)+Chr(10))
    _cQuery += " ("
    For _nPos := 01 To Len(_aStru)
        _cQuery += _aStru[_nPos,1]
        _cQuery += ", "
    NEXT _nPos
    _cQuery += " D_E_L_E_T_, R_E_C_N_O_ "  
    _cQuery += " )"+ CRLF
    //Carrega campos
    _cQuery += " SELECT   "                                               	+ CRLF                    
    For _nPos := 01 To Len(_aStru)
		If _aStru[_nPos,1] == "NREGZZP"
     	   _cQuery += "      "+If(_nPos > 1,","," ")+" ZZP.R_E_C_N_O_"         + CRLF                    
		Else 
        	_cQuery += "      "+If(_nPos > 1,","," ")+_aStru[_nPos,1]           + CRLF                    
		Endif
    Next
    _cQuery += "        ,' '                 AS  D_E_L_E_T_ "				+ CRLF       
    _cQuery += "        , ZZP.R_E_C_N_O_     AS  R_E_C_N_O_ "				+ CRLF        
    _cQuery += " FROM "+RetSqlName("ZZP")+" ZZP "                           + CRLF                    
    _cQuery += " LEFT JOIN "+RetSqlName("SA1")+" SA1 "                      + CRLF 
    _cQuery += "   	ON  SA1.D_E_L_E_T_ = '  '  "					        + CRLF                  
    _cQuery += "    AND SA1.A1_FILIAL   = '"+FwXFilial("SA1")+"' " 	        + CRLF               
    _cQuery += "    AND SA1.A1_COD      = ZZP.ZZP_CODCLI "			        + CRLF            
    _cQuery += "    AND SA1.A1_LOJA     = ZZP.ZZP_LOJCLI "				    + CRLF             
    _cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 "                      + CRLF 
    _cQuery += "   	ON  SB1.D_E_L_E_T_ = '  '  "					        + CRLF                  
    _cQuery += "    AND SB1.B1_FILIAL   = '"+FwXFilial("SB1")+"' " 	        + CRLF               
    _cQuery += "    AND SB1.B1_COD      = ZZP.ZZP_CODPRD "			        + CRLF            
    _cQuery += " WHERE ZZP.D_E_L_E_T_ = '  ' "						  	    + CRLF                   
    _cQuery += "    AND ZZP.ZZP_FILIAL  = '"+ _cFilPrev  +"' " 	  	        + CRLF              
    _cQuery += "    AND ZZP.ZZP_CODPRV  = '"+ _cCodPrev +"' "	            + CRLF             
    _cQuery += " ORDER BY ZZP.ZZP_CODPRV "                                  + CRLF
    _cQuery += "        , ZZP.ZZP_CODCLI "                                  + CRLF
    _cQuery += "        , ZZP.ZZP_LOJCLI "                                  + CRLF
    _cQuery += "        , ZZP.ZZP_CODPRD "                                  + CRLF

	nStatus := TCSqlExec(_cQuery)
    If (nStatus < 0)
        MsgStop("TCSQLError() " + TCSQLError(), "Registros Cabeçalho")
        Break    
    Endif

    (_cAliasZF026)->(DbGoTop())
	If (_cAliasZF026)->(Eof())
		MSGINFO( "Não existem dados para visualizar", "Atencao" )
		Break
	Endif
	//RegToMemory (_cAliasZF026, .T. /*lInclui*/, .F. /*lDic*/)
End Sequence
Return Nil


/*/{Protheus.doc} ValidCampo
//Valida para verificar se liber ou não a Previsão
@author denilso.almeida
@since 
@version 1.0
@return 
@param 
@type function
/*/
Static Function ValidCampo(_cCol, _oBrW)
Local _lRet := .T. 
Local _nPos := (_cAliasZF026)->(Recno())
 //Guarda o posicionamento do temporÃ¡rio
//Local _aOrd 	:= SaveOrd(_cAliasPlan)
//Local _nPosLin 	:= Self:_oBrPlan:nAt
//Local _nCol     	:= Val(_cCol)
Local _xRead    	:= TRIM(READVAR())
Local _xConteudo	:= &_xRead
Local _nQtdEmpenho	:= 0
Local _nQtdeLib    
Local _nQtdePed
Local _nRegZZP
Local _nQtdeLZZP

Begin Sequence
	_nQtdeLib	:= _xConteudo
	_nQtdePed 	:= (_cAliasZF026)->(FieldGet(FieldPos("ZZP_QTEPED")))
	_nRegZZP	:= (_cAliasZF026)->(FieldGet(FieldPos("NREGZZP")))
	
	//Verificar quantidades para avaliar se possui chassis
	ZZP->( DbGoto(_nRegZZP) )
	//neste caso não foi alterado
	If ZZP->ZZP_QTELIB  == _nQtdeLib
		Return .T.
	Endif 
	_nQtdeLZZP 	:= ZZP->ZZP_QTELIB
	_nQtde 		:= ZZP->ZZP_QTELIB   //sempre deixar quantidade anterior caso não execute o calculo volta para anterior
	//Não deixar liberar mas que existe em pedido
	If _nQtdeLib > _nQtdePed
		MSGINFO( "Quantidade liberada não pode ser maior que quantidade do Pedido", "Atencao" )
		_lRet 	:= .F.
		Break  
	Endif 
	//Caso seja o mesmo valor  não precisa alterar
	If _nQtdeLZZP == _nQtdeLib
		Return .T.
	Endif
	//Caso qtde existente no Sistema maior que a quantidade liberada (ja foi selecionado anteriormente uma qtde)
	If _nQtdeLZZP > _nQtdeLib
		_nQtde := ZFATF026RE( _nQtdeLZZP, _nQtdeLib)
		If _nQtde < 0
			Return .F.
		Endif	
	Else 
		//deve ser verificada a diferença para calcular o empenho caso seja maior que zero
		_nQtdeCalc := _nQtdeLib - _nQtdeLZZP 
		iF _nQtdeCalc > 0
			//Qtde utilizada na previsão (com Chassi) e qtde empenho Disponivel
			_nQtdeChassi := ZFATF026AV(ZZP->ZZP_CODPRD, ZZP->ZZP_CODPRV, _nQtdeLZZP, _nQtdeLib, @_nQtdEmpenho) 
			If _nQtdeChassi >= _nQtdeCalc 	
				_lRet := ZFATF26EMP( 1, ZZP->ZZP_FILIAL, ZZP->ZZP_CODPRV, ZZP->ZZP_CODCLI, ZZP->ZZP_LOJCLI, ZZP->ZZP_CODPRD, _nQtdeCalc, /*_lMens*/ )
				If _lRet
					_nQtde	:= _nQtdeCalc + _nQtdeLZZP
				Endif 	
			Else 
				MSGINFO( "Quantidade de chassi nao Empenhada  "+AllTrim(Str(_nQtdeChassi))+" disponivel, nao atende a necessidade ", "Atencao" )
				_lRet 	:= .F. 
			Endif
		Endif
	Endif

End Sequence 
//_oBrW:FWBrowse(): ColPos 
//Atualizar para que possa ser dado o refresh 
//Sempre deixar atualiza com a quantidade
If !_lRet  //Caso de problemas na atualização voltar a qtde anterior 
	_nQtde 	:= _nQtdeLZZP
Endif 
If RecLock(_cAliasZF026,.F.)
	(_cAliasZF026)->(FieldPut(FieldPos("ZZP_QTELIB"),_nQtde))
	(_cAliasZF026)->(MsUnLock())
Endif		
ZZP->( DbGoto(_nRegZZP) )
//Grava tabela Principal pelo motivo de estar empenhando direto
If RecLock("ZZP",.F.)
	ZZP->(FieldPut(FieldPos("ZZP_QTELIB"),_nQtde))
	ZZP->(MsUnLock())
Endif

If _lRet  
	//Atualizar dados
	ZFAT026Total(ZZP->ZZP_FILIAL, ZZP->ZZP_CODPRV, /*_lCarrega*/)
Endif
_oBrW:Refresh()
Return _lRet

//Função que verifica se possui mais empenho que o solicitado e retira o empenho caso confirmado
//Caso 1 qtde existente no Sistema maior que a quantidade liberada (ja foi selecionado anteriormente uma qtde)
Static Function ZFATF026RE( _nQtdeLZZP, _nQtdeLib)
Local _nQtdeCalc := _nQtdeLib  
Begin Sequence 
	If !MsgYesNo("Quantidade liberada "+AllTrim(Str(_nQtdeLZZP))+" anterior maior que "+AllTrim(Str(_nQtdeLib))+" atual, confirma ?") 
		_nQtdeCalc := -1
		Break 
	Endif
	_nQtdeCalc := _nQtdeLZZP - _nQtdeLib  
	//montar regra 	retornar caso de certo a quantidade a ser liberada
	ZFATF26EMP( 2, ZZP->ZZP_FILIAL, ZZP->ZZP_CODPRV, ZZP->ZZP_CODCLI, ZZP->ZZP_LOJCLI, ZZP->ZZP_CODPRD, _nQtdeCalc, /*_lMens*/ )
End Sequence
Return _nQtdeLib


/*/{Protheus.doc} ZFAT026Total
//Trazer totais dos clientes por previsao
@author DAC denilso
@since 18/04/2024
@version 1.0
@parametro 		_lCarrega - indica se esta realizando o carregamento de variaveis neste momento nÃ£o mostra  para fazer atualizaÃ§Ã£o no browse
@return _lRet, Logico
@type Static function
/*/
Static Function ZFAT026Total(_cFilPrev, _cCodPrev, _lCarrega)
//Local _cWhere		:= ""
Local _cAlias		:= GetNextAlias()
Local _ARETCLI		:= {} 
Local _ARETPRD    	:= {}
Local _ARETRES    	:= {}

Local _lRet 		:= .T.
Local _nQtdeChassi	:= 0
Local _nQtdeTotal	:= 0
//Local _cCoPrddRes	:= ""

Default _lCarrega	:= .T.

Begin Sequence
	If ! _lCarrega
		_lRet := .F. 
		Break 
	Endif		

	BeginSql Alias _cAlias //Define o nome do alias temporÃ¡rio 
		SELECT  ZZP.ZZP_CODCLI
				, ZZP.ZZP_LOJCLI 
				, ZZP.ZZP_CNPJCP
				, SA1.A1_NOME
				, ISNULL(SUM(ZZP.ZZP_QTEPED),0) TOTAL_CLI
				, ISNULL(SUM(ZZP.ZZP_QTELIB),0) TOTAL_LIB 
				, ISNULL(SUM(ZZP.ZZP_QTEFAT),0) TOTAL_FAT 
				, ISNULL(SUM(ZZP.ZZP_QTELIB * ZZP.ZZP_VLRTAB),0) VALOR_TOT
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
	If (_cAlias)->(!Eof()) 
		//Verificar os itens dos KITs para saber se tem algun zerado caso tenha nÃ£o ira utilizar o kit
		While (_cAlias)->(!Eof())
			//_nTotaFat 	:= If((_cAlias)->TOTAL_TOTFAT > 0, (_cAlias)->TOTAL_TOTFAT*(_cAlias)->TOTAL_LIB,0)
			Aadd(_ARETCLI,{	;
							(_cAlias)->ZZP_CODCLI,;
							(_cAlias)->ZZP_LOJCLI,;
							(_cAlias)->ZZP_CNPJCP,;
							(_cAlias)->A1_NOME,;
							0,;								//LIMITE DE CRÉDITO
							(_cAlias)->TOTAL_LIB,;
							(_cAlias)->VALOR_TOT ;
							})
			(_cAlias)->(DbSkip())
		EndDo
	Endif	
	_AREFCLI := _ARETCLI
	//Preparar a pesquisa por Produto
	If Select((_cAlias)) <> 0
		(_cAlias)->(DbCloseArea())
	Endif 

	//Pegar o código Posicionado
	//_cCoPrddRes	:= (_cAliasZF026)->(FieldGet(FieldPos( "ZZP_CODPRD")))

	BeginSql Alias _cAlias //Define o nome do alias temporÃ¡rio 
		SELECT  ZZP.ZZP_CODPRD
				, SB1.B1_DESC 
				, ISNULL(SUM(CASE WHEN ZZP.ZZP_QTEPED > 0 THEN ZZP.ZZP_QTEPED ELSE 0 END),0) TOTAL_PED
				, ISNULL(SUM(CASE WHEN ZZP.ZZP_QTELIB > 0 THEN ZZP.ZZP_QTELIB ELSE 0 END),0) TOTAL_LIB
				, ISNULL(SUM(CASE WHEN ZZP.ZZP_QTEFAT > 0 THEN ZZP.ZZP_QTEFAT ELSE 0 END),0) TOTAL_FAT
		FROM %Table:ZZP% ZZP		
		LEFT JOIN %Table:SB1% SB1 
			ON  SB1.%notDel%
			AND SB1.B1_FILIAL 	= %xFilial:SB1%
			AND SB1.B1_COD    	= ZZP.ZZP_CODPRD
		WHERE 	ZZP.%notDel%
			AND ZZP.ZZP_FILIAL  = %Exp:_cFilPrev%
			AND	ZZP.ZZP_CODPRV  = %Exp:_cCodPrev%
     	GROUP BY ZZP.ZZP_CODPRD, SB1.B1_DESC 
		ORDER BY ZZP.ZZP_CODPRV 
	EndSql
	//			AND ZZP.ZZP_FILIAL  = %xFilial:ZZP%
	If (_cAlias)->(!Eof()) 
		//Verificar os itens dos KITs para saber se tem algun zerado caso tenha nÃ£o ira utilizar o kit
		While (_cAlias)->(!Eof())
			_nQtdeChassi := ZFATF026QChassi((_cAlias)->ZZP_CODPRD)  //Verifica quantos chassis tem disponiveis
			_nQtdeChassi += (_cAlias)->TOTAL_LIB  //Somo pois querem ver o total disponivel no Chassi na Previsao ainda não foi faturado mas se existem itens liberados estão presos os chassis a estes itens
			_nQtdeTotal	 := _nQtdeChassi - (_cAlias)->TOTAL_LIB 	//- (_cAlias)->TOTAL_LIB	 	//solicitado para não deixar numetro negativo no total 
			Aadd(_ARETPRD,{	;
							(_cAlias)->ZZP_CODPRD,;
							(_cAlias)->B1_DESC,;
							_nQtdeChassi ,;   							
							(_cAlias)->TOTAL_LIB,;
							If(_nQtdeTotal > 0, _nQtdeTotal,0) ;    //saldo disponivel 
							})
			/*
				Aadd(_ARETRES,{	;
							(_cAlias)->ZZP_CODPRD,;
							(_cAlias)->B1_DESC,;
							_nQtdeChassi,;
							(_cAlias)->TOTAL_LIB,;
							_nQtdeChassi - (_cAlias)->TOTAL_LIB ;
							})
			Endif
			*/
			(_cAlias)->(DbSkip())
		EndDo
		_AREFPRD := _ARETPRD
	Endif	

	//Para gravar em Resumo
	ZFT26Change()
	_ARETRES := _AREFRES

End Sequence
If Len(_AREFCLI) == 0
	_ARETCLI	:= {{	Space(Len(ZZP->ZZP_CODCLI)),;
						Space(Len(ZZP->ZZP_LOJCLI)),;
						Space(Len(ZZP->ZZP_CNPJCP)),;
						Space(Len(SA1->A1_NOME)),;
						0,;
						0,;
						0;
					}}
EndIf
If Len(_AREFPRD) == 0
	Aadd(_ARETPRD,{	;
					Space(Len(ZZP->ZZP_CODPRD)),;
					Space(Len(SB1->B1_DESC)),;
					0,;
					0,;
					0 ;
					})
Endif
/*
If Len(_ARETRES) == 0
	Aadd(_ARETRES,{	;
					Space(Len(ZZP->ZZP_CODPRD)),;
					Space(Len(SB1->B1_DESC)),;
					0,;
					0,;
					0 ;
					})
Endif
*/
If Select((_cAlias)) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif 
	If ValType(_oBrWCli) == "O"
		_oBrWCli:SetArray(_aRefCli)
		_oBrWCli:GoTop(.T.)
		_oBrWCli:Refresh(.T.)
	Endif 	
	If ValType(_oBrWPrd) == "O"
		_oBrWPrd:SetArray(_aRefPrd)
		_oBrWPrd:GoTop(.T.)
		_oBrWPrd:Refresh(.T.)
	Endif 	
	If ValType(_oBrWRes) == "O"
		_oBrWRes:SetArray(_aRefRes)
		_oBrWRes:GoTop(.T.)
		_oBrWRes:Refresh(.T.)
	Endif	
Return Nil //{_ARETCLI, _ARETPRD, _ARETRES}



//VERIFICA OS EMPENHOS NO PEDIDO E DISPONIVEIS AINDA NÃO PENHORADOS
Static Function ZFATF026AV( _cCodProd, _cCodPrev, _nQtdeLZZP, _nQtdeLib, _nQtdEmpenho)
Local _cAlias 		:= GetNextAlias()
Local _nQtdePedEmp  := 0
Local _nQtdeChassi  := 0

Default _cCodProd 	:= "" 
Default _cCodPrev 	:= ""
Default _nQtdeLZZP	:= 0
Default _nQtdeLZZP	:= 0

	BeginSql Alias _cAlias //Define o nome do alias temporário 
		SELECT 	  SC6.C6_PRODUTO
				, SUM(SC6.C6_QTDVEN)  	AS NQTDEVEN
				, SUM(SC6.C6_QTDEMP) 	AS NQTDEEMP
		FROM  	%Table:SC6% SC6 
		WHERE SC6.%notDel%	
			AND SC6.C6_FILIAL 	= %xFilial:SC6%
			AND SC6.C6_PRODUTO  = %Exp:_cCodProd%
			AND SC6.C6_XCODPVR 	= %Exp:_cCodPrev%
			AND SC6.C6_CHASSI  <> ' '
		GROUP BY SC6.C6_PRODUTO 	
	EndSql
	iF (_cAlias)->(!Eof()) .and. (_cAlias)->NQTDEVEN > 0  
		_nQtdePedEmp := (_cAlias)->NQTDEVEN
	Endif
	_nQtdEmpenho := _nQtdePedEmp
	If Select(_cAlias) <> 0
		(_cAlias)->(DbCloseArea())
	Endif
	If _nQtdeLib > 0 
		_nQtdeChassi 	:= ZFATF026QChassi(_cCodProd)  //Verifica quantos chassis tem disponiveis
	Endif
	//_nQtdeCalc 		:= _nQtdeChassi + _nQtdePedEmp  //somatoria do que possui no SC6 e chassi disponivel
If Select(_cAlias) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif
Return _nQtdeChassi  //Qtde de chacssi disponivel para gerar empenho


//Realiza o Empenho 
//_nOpc == 1 Criar Empenho
//_nOpc == 2 Retirar Empenho

Static Function ZFATF26EMP( _nOpcEmp, _cFilPrev, _cCodPrev, _cCodCli, _cLojaCli, _cCodProd,  _nQtde, _lMens )
Local _cAliasEmp	:= GetNextAlias()
Local _lRet 		:= .T.
Local _cCampos		:= ""
Local _cWhere		:= ""
Local _cJoin 		:= ""
Local _nRow			:= 0 
Local _aCampos 		:= {}
Local _aPrevisao 	:= {}
Local _nPos

Default _nOpcEmp	:= 0
Default	_cFilPrev   := FwxFilial("ZZP")
Default _cCodPrev   := ""
Default _cCodCli 	:= ""
Default _cLojaCli	:= "" 
Default _cCodProd   := ""
Default _nQtde		:= 0
Default _lMens 		:= .T. 

Begin Sequence
	//nao pode vir em branco
	iF Empty(_cCodPrev)
		If _lMens
	    	ApMsgStop("Codigo previsao em branco, verificar com ADM Sistemas", "Previsão Faturamento")
		Endif	
		_lRet	:=  .F.
		Break 
	Endif

	_aCampos 	:=   U_XZFT19CP()
	_cCampos 	:= CRLF +" 'F' AS LUPD "
	For _nPos := 1 To Len( _aCampos )	
		If SubsTr(_aCampos[_nPos],1,3) == "C6_"
			_cCampos += CRLF + ", "+_aCampos[_nPos]
		ElseIf SubsTr(_aCampos[_nPos],1,3) == "C5_"
			_cCampos += CRLF + ", "+_aCampos[_nPos]
		ElseIf  _nOpcEmp == 2 .And. SubsTr(_aCampos[_nPos],1,4) == "VRJ_"
			_cCampos += CRLF + ", "+_aCampos[_nPos]
		Endif
	Next _nPos
	_cCampos := "%"+_cCampos+"%"

	If  _nOpcEmp == 2
	/*
		_cJoin 	+= " JOIN "+RetSqlName("SC5")+" SC5 "
		_cJoin 	+= " ON  SC5.D_E_L_E_T_  	= ' ' 	"
		_cJoin 	+= " AND SC5.C5_FILIAL		= '" + FWxFilial("SC5") + "' "
		_cJoin 	+= " AND SC5.C5_NUM 		= SC6.C6_NUM "
		_cJoin 	:= "%"+_cJoin+"%"
	*/
		_cJoin 	+=  CRLF +" JOIN " + RetSqlName("VRJ") + " VRJ "
		_cJoin 	+=  CRLF +"	ON  VRJ.VRJ_FILIAL = '" + xFilial("VRJ") + "' "
		_cJoin 	+=  CRLF +" AND VRJ.VRJ_PEDCOM = SC6.C6_PEDCLI "
		_cJoin 	+= 	CRLF +"	AND VRJ.VRJ_STATUS in ('A','F') "
		_cJoin 	+= 	CRLF +"	AND VRJ.D_E_L_E_T_ = ' ' "
	Endif 
	_cJoin 	:= "%"+_cJoin+"%"

	//Cliente ou todos
	If !Empty(_cCodCli)
		_cWhere	+= " AND SC6.C6_CLI  = '"+_cCodCli+"' "
	Endif 
	//loja ou todos
	If !Empty(_cLojaCli)
		_cWhere	+= " AND SC6.C6_LOJA  = '"+_cLojaCli+"' "
	Endif 
	//Produto ou todos
	If !Empty(_cCodProd)
		_cWhere	+= " AND SC6.C6_PRODUTO  = '"+_cCodProd+"' "
	Endif 
	//incluir empenho 
	If _nOpcEmp == 1  
		_cWhere	+= " AND SC6.C6_CHASSI  = ' ' "
	//Retirar empenho 
	ElseIf  _nOpcEmp == 2
		_cWhere	+= " AND SC6.C6_CHASSI  <> ' ' "
	Endif 
	//Qtde de colunas, quando informado este campo será validado até a quantidade enviada
	//Acrescentar  + 1 no select não valida = somente > ou <
	If _nQtde > 0
		_nRow		:= Str(_nQtde + 1)
		//_nRow 		:= "%"+_nRow+"%"
		_cWhere	+= "AND ROWNUM 	< "+_nRow
	Endif 
	_cWhere := "%"+_cWhere+"%"

	BeginSql Alias _cAliasEmp //Define o nome do alias temporário 
		SELECT 	%Exp:_cCampos% 
		FROM  	%Table:SC6% SC6 
 		JOIN 	%Table:SC5% SC5 
	 		ON  SC5.%notDel% 	
	 		AND SC5.C5_FILIAL	= %xFilial:SC5%
	 		AND SC5.C5_NUM 		= SC6.C6_NUM
			AND SC5.C5_CLIENTE 	= SC6.C6_CLI
			AND SC5.C5_LOJACLI 	= SC6.C6_LOJA
		%Exp:_cJoin%
		WHERE SC6.%notDel%	
			AND SC6.C6_FILIAL 	= %xFilial:SC6%
			AND SC6.C6_XFILPVR	= %Exp:_cFilPrev%
			AND SC6.C6_XCODPVR 	= %Exp:_cCodPrev%
			AND SC6.C6_NOTA    	= ' '
			%Exp:_cWhere%
			ORDER BY SC6.C6_NUM 
	EndSql
	iF (_cAliasEmp)->(Eof()) 
		If _lMens
	    	ApMsgStop("Não localizado registros para serem empenhados nos pedidos", "Previsão Faturamento")
		Endif	
		_lRet	:=  .F.
		Break 
	Endif  
	If _nOpcEmp == 1
		_aPrevisao := U_XZFT19EP(_cAliasEmp)   //localizado em ZFATF019
		If Len(_aPrevisao) == 0 
	    	ApMsgStop("Não foi possivel realizar empenho XZFT19EP, verificar com ADM Sistemas", "Previsao Faturamento")
			_lRet := .F. 
		Endif  
	ElseIf _nOpcEmp == 2
		U_XZFT19ET(_cAliasEmp)   //localizado em ZFATF019
	Endif
End Sequence
If Select(_cAliasEmp) <> 0
	(_cAliasEmp)->(DbCloseArea())
	Ferase(_cAliasEmp+GetDBExtension())
Endif

Return _lRet 

//Localizar quantos chassis disponíveis possuem para o Produto
Static Function ZFATF026QChassi(_cCodProd)
Local _cAlias 		:= GetNextAlias()
Local _cQuery 		:= ""
Local _nQtdeChassi  := 0

	//_cQuery  := U_XZFT25CH(_cCodProd)
	_cQuery  := U_XZFT19CH(_cCodProd, /*_cLocal*/, /*_cNumSerie*/, /*_aCampos*/)
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


//Verifica dados alterados para ajustar posicionamento e retirar os não preenchidos
Static Function ZFATF026End( _nOpc, _cFilPrev, _cCodPrev, _lCancel)
Local _lRet 		:= .T.
Local _oSay

Default _nOpc  		:= 0
Default _cFilPrev   := FwxFilial("SZN")
Default _cCodPrev 	:= ""
Default	_lCancel    := .F. 

	If _nOpc <= 0 .Or. Empty(_cCodPrev)
	    ApMsgStop("Problemas com parametros ZFATF026End, verificar com ADM Sistemas", "Previsao Faturamento")
		Return .F.
	Endif
	If _nOpc == 2  //Vizualizar
		Return _lRet
	Endif 
	FwMsgRun(, {|_oSay| _lRet := ZFTF26PrcEnd( _nOpc, _cFilPrev, _cCodPrev, _lCancel, @_oSay) }, "Avaliando Registros Previsao", "Por favor aguarde...")

Return _lRet	


//Processar Previsao de acordo com opcao
Static Function ZFTF26PrcEnd( _nOpc, _cFilPrev, _cCodPrev, _lCancel, _oSay)
Local _aReg 		:= {}
Local _aLiberado 	:= {}
Local _lLiberado	:= .F. 
Local _lProcessa 	:= .F.
Local _lRet 		:= .T.
Local _nRegZZN

Begin Sequence
	_oSay:SetText("Aguarde Analisado informações - Hora: "+Time())
	ProcessMessage()
	(_cAliasZF026)->(DbGotop())
	While (_cAliasZF026)->(!Eof())
		//Caso os valores de liberação não preenchidos e ou for deleção informar
		If (_cAliasZF026)->ZZP_QTELIB == 0 .Or. _nOpc == 5
			Aadd(_aReg, (_cAliasZF026)->NREGZZP)
		ElseIf _nOpc <> 5
			_lLiberado := .T.  //indica que ao menos um foi liberado
		Endif 
		(_cAliasZF026)->(DbSkip())
	EndDo 		 
	//Se existe um Registro e esta solicitando cancelamento não deixar não pode ser cancelado somente confirmado
	If _lLiberado .And. _lCancel .And. _nOpc <> 5 .And. Len(_aReg) > 0 
	    ApMsgStop("Existem registros com informacao de liberado não podera ser cancelada operacao", "Previsao Faturamento")
		_oBrW:Refresh(.T.)
		_lRet := .F.
		Break
	//Caso tenha seja apertado botão cancelar	
	ElseIf _lCancel  
		Break	
	Endif
    //Caso não tenha selecionado nenhum registro	
	If _nOpc == 5  
		_lProcessa 	:= .T.  //indica que ira refazer browser
    //Caso não tenha registros e não tenha liberação
	ElseIf Len(_aReg) == 0  .And. !_lLiberado
		Break 
	//se existir registros verificar os que estão zerados e retirar ou validar Cancelamento
	ElseIf _lLiberado  //.And. Len(_aReg) > 0 
		_lProcessa 	:= .T.  //indica que ira refazer browser
	Endif

	If _lProcessa 
		If _nOpc == 5 
			//Confirmar o cancelamento total da previsão 
			If !MsgYesNo("Deseja Cancelar Previsao "+_cCodPrev+" ?") 
				_lRet := .F. 
				_oBrW:Refresh(.T.)
				Break
			Endif	
			//somente em alteração validar
		ElseIf _nOpc <> 4
			Break
		Endif
		_oSay:SetText("Aguarde Atualizando informações - Hora: "+Time())
		ProcessMessage()
		//Guardar registro do  ZZN para atuaizar
		ZZN->(DbSetOrder(1))
		If !ZZN->(DbSeek(_cFilPrev+_cCodPrev)) 
	    	ApMsgStop("Não localizado Cabecalho Previsao "+_cFilPrev+"-"+_cCodPrev, "Previsao Faturamento")
			Break 
		Endif	
		_nRegZZN := ZZN->(Recno())
		//Funcionalidade para liberar o SC6 da previsão pode ser UPD
		AjustaZZP(_aReg, _cFilPrev, _cCodPrev, _nOpc, _aLiberado)
		//Atualizar Cabeçalho
		If RecLock("ZZN",.F.)
			If _nOpc == 5  
				ZZN->ZZN_STATUS := "C"
			Else 
				ZZN->ZZN_STATUS := "L"
			Endif
			ZZN->(MsUnlock())
		Endif 
		//If _nOpc <> 5  //Não fazer refresh na exclusão pois não abre tela
		ZFAT026Total( _cFilPrev, _cCodPrev, /*_lCarrega*/)
		_oBrW:Refresh()
	Endif
End Sequence 

Return _lRet	

//funcionalidade responsavel por apagar os dados que não foram indicados para liberação
Static Function AjustaZZP(_aReg, _cFilPrev, _cCodPrev, _nOpc, _aLiberado)
Local _cStatus 	:= " "
Local _cWhere	:= ""
//Local _nQtde	:= 0

Local _nPos 
Begin Sequence
	//Se for Cancelar retirar empenho caso exista
	If _nOpc == 5   
		//Verifica se tem empenho para retirar
		ZFATF26EMP( 2, _cFilPrev, _cCodPrev, /*_cCodCli*/, /*_cLojaCli*/, /*_cCodProd*/,  /*_nQtde*/, .F. /*_lMens*/ )
	Endif 
	//Apagar registros que estão zerados
	For _nPos := 1 To Len(_aReg)
		ZZP->(DbGoto(_aReg[_nPos]))
	   	If !RecLock("ZZP",.F.)
			Break 
		Endif	
		If _nOpc == 5
			ZZP->ZZP_STATUS := "C"	
			ZZP->ZZP_QTELIB := 0
		ElseIf ZZP->ZZP_QTELIB == 0
			ZZP->(DbDelete())
		Endif	
		ZZP->(MsUnlock())
	Next

	//Colocar depois para aplicar update em observação no SC6  ==> retirado
	//SC6->C6_MOPC    := AllTrim(SC6->C6_MOPC) + CRLF + Upper(_cMens) + CRLF 
	//Exemplo SET VS1.VS1_OBSAGL = RAWTOHEX('ALTERADO FORMAG ANTERIOR' || VS1.VS1_FORPAG || ' GMUD NR. ' ||  NVL(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(VS1.VS1_OBSAGL , 2000, 1)),' ') ) ,

    //Limpa os Campos  do Pedido todos que estiverem sem chassi serão apagados
    _cQuery := " UPDATE " + RetSqlName("SC6")+ " SC6 "
    _cQuery += " SET SC6.C6_XFILPVR 	= '" + Criavar("C6_XFILPVR") + "' "
    _cQuery += "    ,SC6.C6_XCODPVR  	= '" + Criavar("C6_XCODPVR" ) + "' "
    _cQuery += " WHERE D_E_L_E_T_  		= ' ' "
	_cQuery += " 	AND SC6.C6_FILIAL 	= '" + FWxFilial("SC6") + "' "
    //_cQuery += "   	AND SC6.C6_PRODUTO	= '" +ZZP->ZZP_CODPRD+ "' "  //não colocar produto na teoria quem não possui chassi não foi selecionado na previsão
    _cQuery += "   	AND SC6.C6_XFILPVR	= '" +_cFilPrev+ "' "
    _cQuery += "    AND SC6.C6_XCODPVR	= '" +_cCodPrev+ "' "
    _cQuery += "    AND SC6.C6_CHASSI	= '" +Space(Len(SC6->C6_CHASSI))+ "' "
	_cQuery += _cWhere


	_nStatus := TCSqlExec(_cQuery)
	If (_nStatus < 0)
    	MsgStop("TCSQLError() " + TCSQLError(), "Atualizacao Empenho SC6")
	EndIf
	//Caso seja delecao posso sair
	If _nOpc == 5	
		_cStatus := "C"
		Break
	Endif

    //Atualiza Status dos registros que ficaram no ZZP para liberado Faturamento
    _cQuery := " UPDATE " + RetSqlName("ZZP")+ " ZZP "
    _cQuery += " SET ZZP.ZZP_STATUS 	= 'L' "
    _cQuery += " WHERE ZZP.D_E_L_E_T_  	= ' ' "
	_cQuery += " 	AND ZZP.ZZP_FILIAL 	= '" + _cFilPrev + "' "
    _cQuery += "    AND ZZP.ZZP_CODPRV	= '" + _cCodPrev + "' "
    _cQuery += "   	AND ZZP.ZZP_QTELIB	> 0 "
	_nStatus := TCSqlExec(_cQuery)
	If (_nStatus < 0)
    	MsgStop("TCSQLError() " + TCSQLError(), "Atualizacao Empenho SC6")
	EndIf
	_cStatus := "L"
End Sequence

Return Nil



//Ajustar por produto a visualização conforme muda de linha
Static Function ZFT26Change()
Local _nPos 
Local _aRet 
Local _lAtualiza := .F.

	_AREFRES := {}
	If ValType(_AREFPRD) == "A" .And. ValType(_cAliasZF026) == "C"  
		_nPos := Ascan(_AREFPRD,{|x| AllTrim(x[1]) == AllTrim((_cAliasZF026)->ZZP_CODPRD)})
		If _nPos > 0 
			_aRet 	:= _AREFPRD[_nPos]
		Else 
			_aRet	:= {	;
							Space(Len(ZZP->ZZP_CODPRD)),;
							Space(Len(SB1->B1_DESC)),;
							0,;
							0,;
							0 ;
							}

		Endif
		Aadd(_AREFRES, _aRet)
		_lAtualiza := .T.
	Endif
	If ValType(_AREFCLI) == "A" .And. ValType(_cAliasZF026) == "C" 
		_nPos := Ascan(_AREFCLI,{|x| x[1]+X[2] == (_cAliasZF026)->ZZP_CODCLI+(_cAliasZF026)->ZZP_LOJCLI})
		If _nPos > 0 
			_aRet := {}
			Aadd(_aRet,"CNPJ : "+ _AREFCLI[_nPos, 3] )  //CGC
			Aadd(_aRet,_AREFCLI[_nPos, 1]+" - "+_AREFCLI[_nPos, 2]+" : "+ _AREFCLI[_nPos, 4] )  //Nome
			Aadd(_aRet,0)  //Qtde liberadoa
			Aadd(_aRet,0)  //Total liberado  
			Aadd(_aRet,_AREFCLI[_nPos, 7])  //Total liberado  
			Aadd(_AREFRES, _aRet)
			_lAtualiza := .T.
		Endif
	Endif 
	If ValType(_oBrWRes)=="O" .And. _lAtualiza
		_oBrWRes:SetArray(_aRefRes)
		_oBrWRes:Refresh(.T.)
	Endif

Return .T.



Static Function ZFT26StruCpo(_xCampo, _bCampo, _cTitulo, _nSize, _nDecimal, _cPicture )
Local _nPos 
Local _oColumn

Default _cTitulo 	:= ""
Default _nSize 		:= 0
Default _nDecimal   := 0
Default _cPicture   := ""

Begin Sequence 
	If _bCampo == Nil
		Break
	Endif 
	_nPos := Ascan( _aPrevisao,{|x| AllTrim(x[2]) == AllTrim(_xCampo)})
	If _nPos == 0
		Break 
	Endif 	
	If Empty(_cTitulo)
		_cTitulo := _aPrevisao[_nPos,1]
	Endif
	If Empty(_nSize)
		_nSize	:= _aPrevisao[_nPos,4]
	Endif
	If Empty(_nDecimal)
		_nDecimal := _aPrevisao[_nPos,5]
	Endif 
	If Empty(_cPicture)
		_cPicture := _aPrevisao[_nPos,6]
	Endif 
	_oColumn := FWBrwColumn():New()
	_oColumn:SetData(_bCampo)
	_oColumn:SetTitle(_cTitulo) 
	_oColumn:SetSize(_nSize)
	_oColumn:SetDecimal(_nDecimal)
	_oColumn:SetPicture(_cPicture)

End Sequence 
Return _oColumn

