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

Static _oBrw
Static _oBrWCli
Static _oBrWPrd
Static _AREFCLI
Static _AREFPRD
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
Local _cAliasPesq   := ""
Local _aPrevisao    := {}
Local _aEdit  		:= {}
Local _oDlgPrev
Local _oFWLayer
Local _oPanelUp
Local _oPanelDow
Local _oFolder
Local _oColumn
Local _aRelac
Local _nPos
Local _aFolders
Local _aButtons


Default _cFilPrev 		:= FwXFilial("ZZP") 
Default _cCodPrev  		:= ""
Default _nOpc			:= 0

//Private M->ZZP_QTELIB	:= 0

Begin Sequence 
	If _nOpc == 0 .Or. Empty(_cCodPrev)
		Break
	Endif
 	FwMsgRun(,{ |_oSay| ZFATF026PR(_cFilPrev, _cCodPrev, @_cAliasPesq, @_aPrevisao, @_oSay ) }, "Selecionando dados para a Montagem Previsao", "Aguarde...")  
	//acrescentar campos editaveis
	Aadd( _aEdit,"ZZP_QTELIB")
    //Abre arquivo selecionado
	DbSelectArea(_cAliasPesq)
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

 	DbSelectArea(_cAliasPesq)
 	_oBrw := FWMBrowse():New()
	_oBrw:SetCanSaveArea(.T.)	//abertura de mais de uma  browse
	_oBrw:SetTemporary(.T.)
    //_oBrw:SetOwner(_oTPanel01)
    _oBrw:SetAlias(_cAliasPesq)	
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
    _oBrw:AddLegend("AllTrim(ZZP_STATUS) = 'F'  "  ,"BLUE" 	   	,"Faturado")
	_oBrw:AddLegend("AllTrim(ZZP_STATUS) = 'A'  "  ,"GREEN"     ,"Em Aberto")
	_oBrw:AddLegend("AllTrim(ZZP_STATUS) = 'C'  "  ,"RED"       ,"Cancelado")
	_oBrw:AddLegend("AllTrim(ZZP_STATUS) <> ' '  " ,"GRAY"      ,"Pendente")
	_oBrw:SetPreEditCell({|| DbSelectArea(_cAliasPesq), .T.})
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
            (_cAliasPesq)->(_oColumn:SetReadVar(_aPrevisao[_nPos,2]))
            _oColumn:SetValid({|| ValidCampo(Str(_nPos), _cAliasPesq, _ObrW ),_ObrW:Refresh() })
       //     oColumn:SetValid({|| ValidCampo(Str(_nPos),Self:_OBrPlan) })
        EndIf
        _ObrW:SetColumns({_oColumn})
    Next

   //Ativamos a classe
    _ObrW:Refresh(.T.)
	_ObrW:Activate()

    //Carregar valores totais ZFATF015
	_aPosSize := {0,0,0,0}
	_aPosSize[3] := 670
	_aPosSize[4] := 85
	_aFolders := {"Totais Cliente","Totais Produto"}
	_oFolder := TFolder():New(_aPosSize[1],_aPosSize[2],_aFolders,_aFolders,_oPanelDow,,,,.T.,.T.,_aPosSize[3],_aPosSize[4])

	_aRelac 	:= ZFAT026Total(_cFilPrev, _cCodPrev, /*_lCarrega*/)
	_aRefCli	:= _aRelac[1]
	_aRefPrd	:= _aRelac[2]

	// Define o Browse Relacionados
	_oBrWCli := FWBrowse():New(_oPanelDow)
	_oBrWCli:SetDataArray(.T.)
	_oBrWCli:SetArray(_aRefCli)
	_oBrWCli:DisableConfig(.T.)
	_oBrWCli:DisableReport(.T.)
	_oBrWCli:DisableLocate(.T.)
	_oBrWCli:DisableFilter(.T.)
    _oBrWCli:SetOwner(_oFolder:aDialogs[1])
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
    _oBrWPrd:SetOwner(_oFolder:aDialogs[2])
	ZFAT026MPrd()
	_oBrWPrd:Activate()
	_oBrWPrd:GoTop(.T.)
	_oBrWPrd:Refresh(.T.)
    //_oDlgPrev:Activate()
	_aButtons := {}
	Activate MsDialog _oDlgPrev On Init EnchoiceBar(_oDlgPrev,{	|| ZFATF026End(_nOpc, _cAliasPesq, _cFilPrev, _cCodPrev), _oDlgPrev:End() },;
																{||If(ZFATF026End(_nOpc, _cAliasPesq, _cFilPrev, _cCodPrev, .T.),_oDlgPrev:End(), .T.)},,_aButtons)

End Sequence
If ValType(_cAliasPesq) == "C" .And. Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	//Ferase(_cTable+GetDBExtension())
    //_oTable:Delete()
Endif      

RestArea(_aArea)
Return Nil


// Cria uma coluna de Clientes com totais
// Adiciona as colunas do Browse
Static Function ZFAT026MCli()
Local _oColumn

	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aRefCli[_oBrWCli:nAt,DATA_CLIENTE]})
	_oColumn:SetTitle("Cliente" ) 
	_oColumn:SetSize(Len(SA1->A1_COD))
	_oColumn:SetDecimal(0)
	//_oColumn:SetPicture("@!")
	_oBrWCli:SetColumns({_oColumn})
	
	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aRefCli[_oBrWCli:nAt,DATA_LOJA]})
	_oColumn:SetTitle("Loja") 
	_oColumn:SetSize(Len(SA1->A1_LOJA))
	_oColumn:SetDecimal(0)
	//_oColumn:SetPicture("@!")
	_oBrWCli:SetColumns({_oColumn})

	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aRefCli[_oBrWCli:nAt,DATA_CNPJCPF]})
	_oColumn:SetTitle("CNPJ/CPF") 
	_oColumn:SetSize(14)
	_oColumn:SetDecimal(0)
	//_oColumn:SetPicture("@!")
	_oBrWCli:SetColumns({_oColumn})

	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aRefCli[_oBrWCli:nAt,DATA_NOMCLI]})
	_oColumn:SetTitle("Razao Social") 
	_oColumn:SetSize(Len(SA1->A1_NOME))
	_oColumn:SetDecimal(0)
	_oColumn:SetPicture("@!")
	_oBrWCli:SetColumns({_oColumn})

	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aRefCli[_oBrWCli:nAt,DATA_LC]})
	_oColumn:SetTitle("Limite Credito") 
	_oColumn:SetSize(14)
	_oColumn:SetDecimal(2)
	_oColumn:SetPicture("@E 999,999,999.99")
	_oBrWCli:SetColumns({_oColumn})

	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aRefCli[_oBrWCli:nAt,DATA_TOTCLI]})
	_oColumn:SetTitle("Total Cliente") 
	_oColumn:SetSize(14)
	_oColumn:SetDecimal(2)
	_oColumn:SetPicture("@E 999,999,999.99")
	_oBrWCli:SetColumns({_oColumn})

	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aRefCli[_oBrWCli:nAt,DATA_SALDOLC]})
	_oColumn:SetTitle("Saldo Credito") 
	_oColumn:SetSize(14)
	_oColumn:SetDecimal(2)
	_oColumn:SetPicture("@E 999,999,999.99")
	_oBrWCli:SetColumns({_oColumn})

Return Nil

//Cria cabeçalho e coluna totalização por produto
Static Function ZFAT026MPrd()
Local _oColumn
	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aRefPrd[_oBrWPrd:nAt,DATA_PRODUTO]})
	_oColumn:SetTitle("Produto" ) 
	_oColumn:SetSize(Len(SB1->B1_COD))
	_oColumn:SetDecimal(0)
	//_oColumn:SetPicture("@!")
	_oBrWPrd:SetColumns({_oColumn})
	
	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aRefPrd[_oBrWPrd:nAt,DATA_DESCPRD]})
	_oColumn:SetTitle("Descrição") 
	_oColumn:SetSize(Len(SB1->B1_DESC))
	_oColumn:SetDecimal(0)
	_oColumn:SetPicture("@!")
	_oBrWPrd:SetColumns({_oColumn})

	//Qtde de Chassis disponivel
	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aRefPrd[_oBrWPrd:nAt,DATA_QTDEPRD]})
	_oColumn:SetTitle("Estoque")   
	_oColumn:SetSize(14)
	_oColumn:SetDecimal(0)
	_oColumn:SetPicture("@E 9,999,999")
	_oBrWPrd:SetColumns({_oColumn})

	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aRefPrd[_oBrWPrd:nAt,DATA_QTDEPREV]})
	_oColumn:SetTitle("Em Previsao") 
	_oColumn:SetSize(15)
	_oColumn:SetDecimal(2)
	_oColumn:SetPicture("@E 9,999,999")
	_oBrWPrd:SetColumns({_oColumn})

	_oColumn := FWBrwColumn():New()
	_oColumn:SetData({||_aRefPrd[_oBrWPrd:nAt,DATA_SALDOPRD]})
	_oColumn:SetTitle("Saldo") 
	_oColumn:SetSize(15)
	_oColumn:SetDecimal(2)
	_oColumn:SetPicture("@E 9,999,999")
	_oBrWPrd:SetColumns({_oColumn})
Return Nil



/*/{Protheus.doc} ZFATF026PR
Processar Pedido de Compras Pendentes
@author     DAC - Denilso 
@since      26/06/2023
@version    1.0
@obs        
/*/

Static Function ZFATF026PR(_cFilPrev, _cCodPrev, _cAliasPesq, _aPrevisao, _oSay)
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
    _cAliasPesq := _oTable:GetAlias()

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

    (_cAliasPesq)->(DbGoTop())
	If (_cAliasPesq)->(Eof())
		MSGINFO( "Não existem dados para visualizar", "Atencao" )
		Break
	Endif
	//RegToMemory (_cAliasPesq, .T. /*lInclui*/, .F. /*lDic*/)
End Sequence
Return Nil


/*/{Protheus.doc} ValidCampo
//TODO EdiÃ§Ã£o da tela de planejamento para gravar quando alterar.
@author denilso.almeida
@since 14/10/2019
@version 1.0
@return ${return}, ${return_description}
@param _oBrW, , descricao
@param _cCol, , descricao
@type function
/*/
Static Function ValidCampo(_cCol, _cAliasPesq, _oBrW)
Local _lRet := .T. 
Local _nPos := (_cAliasPesq)->(Recno())
 //Guarda o posicionamento do temporÃ¡rio
//Local _aOrd 	:= SaveOrd(_cAliasPlan)
//Local _nPosLin 	:= Self:_oBrPlan:nAt
Local _nCol     := Val(_cCol)
Local _xRead    := TRIM(READVAR())
Local _xConteudo:= &_xRead
Local _nQtdeLib    
Local _nQtdePed
Local _nRegZZP
Local _nQtdeLZZP

Begin Sequence
	_nQtdeLib	:= _xConteudo
	_nQtdePed 	:= (_cAliasPesq)->(FieldGet(FieldPos("ZZP_QTEPED")))
	_nRegZZP	:= (_cAliasPesq)->(FieldGet(FieldPos("NREGZZP")))
	
	//Verificar quantidades para avaliar se possui chassis
	ZZP->( DbGoto(_nRegZZP) )
	_nQtdeLZZP 	:= ZZP->ZZP_QTELIB
	_nQtde 		:= ZZP->ZZP_QTELIB   //sempre deixar quantidade anterior caso não execute o calculo volta para anterior

	If _nQtdeLib > _nQtdePed
		MSGINFO( "Quantidade liberada não pode ser maior que quantidade do Pedido", "Atencao" )
		_lRet 	:= .F. 
	Endif 
	//Ja validou
	If _lRet 
		If _nQtdeLZZP > _nQtdeLib
			_nQtde := ZFATF026RE(ZZP->ZZP_CODPRD, ZZP->ZZP_CODPRV, _nQtdeLZZP, _nQtdeLib)
		Else 
			_nQtdEmpenho := ZFATF026AV(ZZP->ZZP_CODPRD, ZZP->ZZP_CODPRV, _nQtdeLZZP, _nQtdeLib) 
			If _nQtdEmpenho >= _nQtdeLib 	
				_nQtde :=  _nQtdeLib
			Else 
				MSGINFO( "Quantidade de chassi nao Empenhada  "+AllTrim(Str(_nQtdEmpenho))+" disponivel, nao atende a necessidade ", "Atencao" )
				_lRet 	:= .F. 
			Endif
		Endif
	Endif 
	//_oBrW:FWBrowse(): ColPos 
   	//Atualizar para que possa ser dado o refresh
   	If RecLock(_cAliasPesq,.F.)
		(_cAliasPesq)->(FieldPut(FieldPos("ZZP_QTELIB"),_nQtde))
   		(_cAliasPesq)->(MsUnLock())
   	Endif		
End Sequence 
//(_cAliasPlan)->(DbGotop())
//(_cAliasPesq)->(DbGoto(_nPos))
_oBrW:Refresh()
Return _lRet

//Função que verifica se possui mais empenho que o solicitado e retira o empenho caso confirmado
Static Function ZFATF026RE(_cCodProd, _cCodPrev, _nQtdeLZZP, _nQtdeLib)
Local _nQtdeCalc := _nQtdeLZZP  //deixa a que foi liberada anteriorment
Begin Sequence 
	If !MsgYesNo("Quantidade liberada "+AllTrim(Str(_nQtdeLZZP))+" anterior maior que "+AllTrim(Str(_nQtdeLib))+" atual, confirma ?") 
		Break 
	Endif
	//montar regra 	
	//_nQtdeCalc := _nQtdeLZZP - _nQtdeLib  //tem que retirar chassi e emprnho
	//If  //Funcao para retirar empenho
	//	_nQtdeCalc 	:= _nQtdeLib  //Assumira a quantidade de estiver ok
	//Endif
End Sequence
Return _nQtdeCalc


/*/{Protheus.doc} ZFAT026Total
//Trazer totais dos clientes por previsao
@author DAC denilso
@since 18/04/2024
@version 1.0
@parametro 		_lCarrega - indica se esta realizando o carregamento de variaveis neste momento nÃ£o mostra  para fazer atualizaÃ§Ã£o no browse
@return _lRet, Logico
@type Static function
/*/
Static Function ZFAT026Total(_cFilPrev, _cCodPrev,_lCarrega)
//Local _cWhere		:= ""
Local _cAlias		:= GetNextAlias()
Local _AREFCLI		:= {} 
Local _AREFPRD    	:= {}
Local _lRet 		:= .T.
Local _nQtdeChassi	:= 0

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
				, ISNULL(MAX(ZZP.ZZP_VLRTAB),0) VALOR_TAB
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
			Aadd(_AREFCLI,{	;
							(_cAlias)->ZZP_CODCLI,;
							(_cAlias)->ZZP_LOJCLI,;
							(_cAlias)->ZZP_CNPJCP,;
							(_cAlias)->A1_NOME,;
							0,;								//LIMITE DE CRÉDITO
							(_cAlias)->TOTAL_LIB,;
							(_cAlias)->TOTAL_LIB * (_cAlias)->VALOR_TAB;
							})
			(_cAlias)->(DbSkip())
		EndDo
	Endif	

	//Preparar a pesquisa por Produto
	If Select((_cAlias)) <> 0
		(_cAlias)->(DbCloseArea())
	Endif 

	BeginSql Alias _cAlias //Define o nome do alias temporÃ¡rio 
		SELECT  ZZP.ZZP_CODPRD
				, SB1.B1_DESC 
				, ISNULL(SUM(ZZP.ZZP_QTEPED),0) TOTAL_PED
				, ISNULL(SUM(ZZP.ZZP_QTELIB),0) TOTAL_LIB
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
		_nQtdeChassi := ZFATF026QChassi((_cAlias)->ZZP_CODPRD)  //Verifica quantos chassis tem disponiveis
		//Verificar os itens dos KITs para saber se tem algun zerado caso tenha nÃ£o ira utilizar o kit
		While (_cAlias)->(!Eof())
			Aadd(_AREFPRD,{	;
							(_cAlias)->ZZP_CODPRD,;
							(_cAlias)->B1_DESC,;
							_nQtdeChassi,;
							(_cAlias)->TOTAL_LIB,;
							_nQtdeChassi - (_cAlias)->TOTAL_LIB ;
							})
			(_cAlias)->(DbSkip())
		EndDo
	Endif	

End Sequence
If Len(_AREFCLI) == 0
	_AREFCLI	:= {{	Space(Len(ZZP->ZZP_CODCLI)),;
						Space(Len(ZZP->ZZP_LOJCLI)),;
						Space(Len(ZZP->ZZP_CNPJCP)),;
						Space(Len(SA1->A1_NOME)),;
						0,;
						0,;
						0;
					}}
EndIf
If Len(_AREFPRD) == 0
	Aadd(_AREFPRD,{	;
					Space(Len(ZZP->ZZP_CODPRD)),;
					Space(Len(SB1->B1_DESC)),;
					0,;
					0,;
					0 ;
					})
Endif

If Select((_cAlias)) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif 
Return {_AREFCLI, _AREFPRD}



//VERIFICA OS EMPENHOS NO PEDIDO E DISPONIVEIS AINDA NÃO PENHORADOS
Static Function ZFATF026AV( _cCodProd, _cCodPrev, _nQtdeLZZP, _nQtdeLib)
Local _cAlias 		:= GetNextAlias()
Local _nQtdeChassi  := 0
Local _nQtdeCalc    := 0
Local _nQtdePedEmp  := 0
Local _nQtdeDif		:= 0

Default _cCodProd 	:= "" 
Default _cCodPrev 	:= ""
Default _nQtdeLZZP	:= 0
Default _nQtdeLZZP	:= 0

	BeginSql Alias _cAlias //Define o nome do alias temporário 
		SELECT 	  SC6.C6_PRODUTO
				, SUM(SC6.C6_QTDVEN)  	AS NQTDEVEN
				, SUM(SC6.C6_QTDEMP) 	AS NqTDEEMP
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
	If Select(_cAlias) <> 0
		(_cAlias)->(DbCloseArea())
	Endif
	//diferença de quantidade Calculada ja existente e empenhada com necessidade de liberação 
	_nQtdeDif 		:= _nQtdeLib - _nQtdePedEmp
	_nQtdeChassi 	:= ZFATF026QChassi(_cCodProd)  //Verifica quantos chassis tem disponiveis
	_nQtdeCalc 		:= _nQtdeChassi + _nQtdePedEmp  //somatoria do que possui no SC6 e chassi disponivel

If Select(_cAlias) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif
Return _nQtdeCalc


//Localizar quantos chassis disponíveis possuem para o Produto
Static Function ZFATF026QChassi(_cCodProd)
Local _cAlias 		:= GetNextAlias()
Local _cQuery 		:= ""
Local _nQtdeChassi  := 0
	_cQuery  := U_XZFT25CH(_cCodProd)
	TcQuery _cQuery new alias (_cAlias)
	DbSelectArea(_cAlias)
	(_cAlias)->(DbGotop())
	Count To _nQtdeChassi	  //Conta quantos chassis estão disponiveis
	(_cAlias)->(DbGotop())
If Select(_cAlias) <> 0
	(_cAlias)->(DbCloseArea())
	Ferase(_cAlias+GetDBExtension())
Endif
Return _nQtdeChassi


//Verifica dados alterados para ajustar posicionamento e retirar os não preenchidos
Static Function ZFATF026End( _nOpc, _cAliasPesq, _cFilPrev, _cCodPrev, _lCancel)
Local _aReg 		:= {}
Local _lLiberado	:= .F. 
Local _lProcessa 	:= .F.
Local _lRet 		:= .T.

Default	_lCancel    := .F. 

Begin Sequence
	(_cAliasPesq)->(DbGotop())
	While (_cAliasPesq)->(!Eof())
		//Caso os valores de liberação não preenchidos e ou for deleção informar
		If (_cAliasPesq)->ZZP_QTELIB == 0 .Or. _nOpc == 5
			Aadd(_aReg, (_cAliasPesq)->NREGZZP)
		ElseIf _nOpc <> 5
			_lLiberado := .T.  //indica que elo menos um foi liberado
		Endif 
		(_cAliasPesq)->(DbSkip())
	EndDo 		 
	//Se existe um Registro e esta solicitando cancelamento não deixar não pode ser cancelado somente confirmado
	If _lLiberado .And. _lCancel  
	    ApMsgStop("Existem registros com informacao de liberado não podera ser cancelada operacao", "Previsao Faturamento")
		_lRet := .F.
		Break
	ElseIf _lCancel  
		_lRet 	:= .T.	
	Endif
	
	If Len(_aReg) == 0 
		Break 
	Endif 

	If _nOpc == 5  
		_lProcessa 	:= .T.  //indica que ira refazer browser
	ElseIf _lLiberado .And. Len(_aReg) > 0 
		_lProcessa 	:= .T.  //indica que ira refazer browser
	Endif

	If _lProcessa 
		//Funcionalidade para liberar o SC6 da previsão pode ser UPD
		AjustaZZP(_aReg, _cFilPrev, _cCodPrev, _nOpc)
		U_XZFAT25AP()
	Endif
End Sequence 

Return _lRet	

//funcionalidade esponsavel por apagar os dados que não foram indicados para liberação
Static Function AjustaZZP(_aReg, _cFilPrev, _cCodPrev, _nOpc)
Local _nPos 
	//Se for deletar retirar empenho 
	If _nOpc == 5
		//DACXXX
	Endif
	For _nPos := 1 To Len(_aReg)
		ZZP->(DbGoto(_aReg[_nPos]))
	   	If RecLock("ZZP",.F.)
			ZZP->(DbDelete())
			ZZP->(MsUnlock())
		Endif 
	Next
	//Colocar depois para aplicar update em observação no SC6 retirado
	//SC6->C6_MOPC    := AllTrim(SC6->C6_MOPC) + CRLF + Upper(_cMens) + CRLF 
	//Exemplo SET VS1.VS1_OBSAGL = RAWTOHEX('ALTERADO FORMAG ANTERIOR' || VS1.VS1_FORPAG || ' GMUD NR. ' ||  NVL(UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(VS1.VS1_OBSAGL , 2000, 1)),' ') ) ,

    //Limpa os Campos  do Pedido todos que estiverem sem chassi serão apagados
    _cQuery := " UPDATE " + RetSqlName("SC6")+ " SC6 "
    _cQuery += " SET SC6.C6_XFILPVR 	= '" + Criavar("C6_XFILPVR") + "' "
    _cQuery += "    ,SC6.C6_XCODPVR  	= '" + Criavar("C6_XCODPVR" ) + "' "
    _cQuery += " WHERE D_E_L_E_T_  = ' ' "
	_cQuery += " 	AND SC6.C6_FILIAL 	= '" + FWxFilial("SC6") + "' "
    //_cQuery += "   	AND SC6.C6_PRODUTO	= '" +ZZP->ZZP_CODPRD+ "' "  //não colocar produto na teoria quem não possui chassi não foi selecionado na previsão
    _cQuery += "   	AND SC6.C6_XFILPVR	= '" +_cFilPrev+ "' "
    _cQuery += "    AND SC6.C6_XCODPVR	= '" +_cCodPrev+ "' "
    _cQuery += "    AND SC6.C6_CHASSI	= '" +Space(Len(SC6->C6_CHASSI))+ "' "
	_nStatus := TCSqlExec(_cQuery)
	If (_nStatus < 0)
    	MsgStop("TCSQLError() " + TCSQLError(), "Atualizacao Empenho SC6")
	EndIf

Return Nil

