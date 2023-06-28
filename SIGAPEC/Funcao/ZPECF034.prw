#Include "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "TOTVS.ch"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWBROWSE.CH"
#Include "FWMVCDEF.CH"

#define CRLF chr(13) + chr(10)  

/*/{Protheus.doc} ZPECF034
Pedido de Compras Pendentes
@author     DAC - Denilso 
@since      26/06/2023
@version    1.0
@obs        Tela esta relacionada com a funcionalidade ZPECF030 a mesma poderá ser colocada também no menu com a chamada ZPECF032 caso seja necessário adaptar parametros para a procura  
/*/

User Function ZPECF034(_cCodProd)
Local _aArea := GetArea()
Local _cCodProdDe   := Space(Len(SB1->B1_COD))
Local _cCodProdAte  := Space(Len(SB1->B1_COD))
Local _cCadastro    := OemToAnsi("Pedido de Compras")   
Local _cTitle  	    := OemToAnsi("Pedido de Compras Pendentes")   
Local _aSays	    := {}
Local _aButtons	    := {}
Local _aPar    	    := {}
Local _aRet    	    := {}
Local _nRet			:= 0

Default _cCodProd   := Space(Len(SB1->B1_COD))

Begin Sequence 
    //quando não informado cod produto solicitar de / ate
    If Empty(_cCodProd)
    	aAdd(_aPar,{1,OemToAnsi("Produto de     : ") ,_cCodProdDe			,"@!"		,".T."	,"SB1" 	,".T."	,100,.F.}) 
    	aAdd(_aPar,{1,OemToAnsi("Produto ate    : ") ,_cCodProdAte		    ,"@!"		,".T."	,"SB1"	,".T."	,100,.T.}) 

	    // Monta Tela principal
	    aAdd(_aSays,OemToAnsi("Este Programa tem  como objetivo mostrar os Pedidos de Compras.")) 
	    aAdd(_aSays,OemToAnsi("que estão pendentes ou com atendimento parcial.")) 
	    aAdd(_aSays,OemToAnsi("Nos casos de Pedido de Importação é necessário observar que a quantidade")) 
	    aAdd(_aSays,OemToAnsi("entregue é no momento da emissão da nota de entrada, existindo assim   um")) 
	    aAdd(_aSays,OemToAnsi("delay entre a geração da nota e a entrada de material no estoque.")) 

	    aAdd(_aButtons, { 1,.T.,{|o| FechaBatch(),_nRet:=1											}})
	    aAdd(_aButtons, { 2,.T.,{|o| FechaBatch()													}})
	    aAdd(_aButtons, { 5,.T.,{|o| ParamBox(_aPar,_cTitle,@_aRet,,,.T.,,,,"ZPECF034",.T.,.T.) 	}})

	    FormBatch( _cCadastro, _aSays, _aButtons )
	    If _nRet <> 1
		    Break
	    Endif
	    If Len(_aRet) == 0
    		Help( , ,OemToAnsi("Atenção"),,OemToAnsi("Necessário informar os parâmetros"),4,1)   
    		Break 
    	Endif
	Else
		Aadd(_aRet,_cCodProd )   //De		
		Aadd(_aRet,_cCodProd )	 //Ate	
    Endif

	FwMsgRun(,{ |_oSay| ZPECF034PR(_aRet, _cCodProd, @_oSay ) }, "Selecionando dados para a Montagem Pedidos Pendentes", "Aguarde...")  

    RestArea(_aArea)
End Sequence
Return Nil


Static Function ZPECF034PR(_aRet, _cCodProd, _oSay)
Local _cCodProdDe   := _aRet[1]
Local _cCodProdAte  := _aRet[2]
Local _cAliasPesq   //:= GetNextAlias()
Local _cWhere       := ""
Local _nPos
Local _aBrwCab
Local _aStru
Local _oTable
Local _aCpoCab
Local _cQuery
   
Begin Sequence
    _aCpoCab := {}
    Aadd( _aCpoCab, {"SC7", "C7_PRODUTO"  	,If(Empty(_cCodProd),.T.,.F.)})		//Quantidade
    Aadd( _aCpoCab, {"SC7", "C7_QUANT"  	,.T.})		//Quantidade
    Aadd( _aCpoCab, {"SC7", "C7_QUJE"   	,.T.})		//Quantidade Entregue
    Aadd( _aCpoCab, {"SC7", "QTDE_PEND" 	, TamSX3("C7_QUANT")[03],"Qtde Pendente"  , TamSX3("C7_QUANT")[01]   , TamSX3("C7_QUANT")[02], PesqPict("SC7","C7_QUANT"),.T.})	//Quantidade Entregue
    Aadd( _aCpoCab, {"SC7", "C7_FORNECE"  	,.T.}) 		//Fornecedor
    Aadd( _aCpoCab, {"SC7", "C7_LOJA"  		,.T.}) 		//Fornecedor
    Aadd( _aCpoCab, {"SA2", "A2_NOME"  		,.T.}) 		//Fornecedor
   	aAdd( _aCpoCab, {"SC7", "NAC_IMP"       , "C","Nacional/Importado"   , 003        , 0, "@!",.T.})  //Nacional ou importado
    Aadd( _aCpoCab, {"SC7", "C7_NUM"   		,.T.})		//Pedido
    Aadd( _aCpoCab, {"SC7", "C7_ITEM"   	,.T.})		//Item Pedido
    Aadd( _aCpoCab, {"SC7", "C7_PO_EIC"   	,.T.})		//PO
    Aadd( _aCpoCab, {"SC7", "C7_DATPRF"  ,.T.})  //Previsão de Entrega
 	aAdd( _aCpoCab, {"SC7","NRECNO"     , "N","Recno Pedido"            , 10, 0, "@!",.F. /*não ncluir no browse*/})

    _aBrwCab    := {}
    _aStru      := {}  //Estrutura do Banco
    For _nPos := 1 To Len(_aCpoCab)
        If Len(_aCpoCab[_nPos]) == 3
            _aTamSx3 := TamSX3(_aCpoCab[_nPos,2])
            If _aCpoCab[_nPos,Len(_aCpoCab[_nPos])]  //Valida se a coluna irá para o Browse
                Aadd(_aBrwCab,{ RetTitle(_aCpoCab[_nPos,2]),;    //titulo
                                _aCpoCab[_nPos,2],;             //campo
                                _aTamSx3[03],;                  //tipo
                                _aTamSx3[01],;                  //tamanho
                                _aTamSx3[02],;                  //decimal
                             PesqPict(_aCpoCab[_nPos,1],_aCpoCab[_nPos,2]);  //pict
                          })
            Endif
            Aadd(_aStru, {_aCpoCab[_nPos,02], _aTamSx3[03], _aTamSx3[01], _aTamSx3[02] })
        Else  
            If _aCpoCab[_nPos,Len(_aCpoCab[_nPos])]  //Valida se a coluna irá para o Browse
                Aadd(_aBrwCab,{ _aCpoCab[_nPos,4],;             //titulo
                                _aCpoCab[_nPos,2],;             //campo
                                _aCpoCab[_nPos,3],;             //tipo
                                _aCpoCab[_nPos,5],;             //tamanho    
                                _aCpoCab[_nPos,6],;             //decimal
                                _aCpoCab[_nPos,7];              //pict
                                })
            Endif
            Aadd(_aStru, { _aCpoCab[_nPos,02], _aCpoCab[_nPos,03], _aCpoCab[_nPos,05], _aCpoCab[_nPos,06] })
        Endif
    Next

    _oTable := FWTemporaryTable():New()
    _oTable:SetFields(_aStru)
    _oTable:AddIndex("INDEX1", {"C7_DATPRF", "C7_PRODUTO"} )
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
    _cQuery += " SELECT   SC7.C7_PRODUTO CODPROD"							+ CRLF                    
    _cQuery += "        , SC7.C7_QUANT QUANT "								+ CRLF                      
    _cQuery += "        , SC7.C7_QUJE QUJE "								+ CRLF                      
    _cQuery += "        , (SC7.C7_QUANT - SC7.C7_QUJE)  QTDE_PEND "			+ CRLF                
    _cQuery += "     	, SC7.C7_FORNECE FORNECE "							+ CRLF                     
    _cQuery += "     	, SC7.C7_LOJA LOJA "								+ CRLF                         
    _cQuery += "     	, SA2.A2_NOME NOME "								+ CRLF                      
    _cQuery += "     	, CASE WHEN SC7.C7_ORIGEM  = 'EICPO400' THEN 'IMP' ELSE 'NAC' END NAC_IMP "									+ CRLF
    _cQuery += "     	, SC7.C7_NUM  PEDIDO "					            + CRLF                          
    _cQuery += "     	, SC7.C7_ITEM ITEM "								+ CRLF                        
    _cQuery += "     	, SC7.C7_PO_EIC NUMPO "					    		+ CRLF                        
    _cQuery += "     	, SC7.C7_DATPRF DATPRF "							+ CRLF                   
    _cQuery += "        , SC7.R_E_C_N_O_   AS  NRECNO "						+ CRLF           
    _cQuery += "        ,' '                 AS  D_E_L_E_T_ "				+ CRLF       
    _cQuery += "        , SC7.R_E_C_N_O_     AS  R_E_C_N_O_ "				+ CRLF        
    _cQuery += " FROM ABDHDU_PROT.SC7020 SC7 "						+ CRLF                  
    _cQuery += " LEFT JOIN ABDHDU_PROT.SA2020 SA2 "					+ CRLF              
    _cQuery += "   	ON SA2.D_E_L_E_T_ = '  '  "						+ CRLF                  
    _cQuery += "    AND SA2.A2_FILIAL   = '"+FwXFilial("SA2")+"' " 	+ CRLF               
    _cQuery += "    AND SA2.A2_COD      = SC7.C7_FORNECE "			+ CRLF            
    _cQuery += "    AND SA2.A2_LOJA     = SC7.C7_LOJA "				+ CRLF             
    _cQuery += " WHERE SC7.D_E_L_E_T_ = '  ' "						+ CRLF                   
    _cQuery += "    AND SC7.C7_FILIAL  = '"+FwXFilial("SC7")+"' " 	+ CRLF              
    _cQuery += "    AND SC7.C7_PRODUTO   BETWEEN '"+_cCodProdDe+"'  AND '"+_cCodProdAte+"' "+ CRLF        
    _cQuery += "    AND SC7.C7_QUANT    <> '0' "					+ CRLF                   
    _cQuery += "    AND SC7.C7_QUANT    >  SC7.C7_QUJE "			+ CRLF                   
    _cQuery += "    AND SC7.C7_RESIDUO = ' ' "						+ CRLF  
    _cQuery += " ORDER BY DATPRF, CODPROD "+ CRLF

	nStatus := TCSqlExec(_cQuery)
    If (nStatus < 0)
        MsgStop("TCSQLError() " + TCSQLError(), "Registros Cabeçalho")
        Break    
    Endif

    (_cAliasPesq)->(DbGoTop())
	If (_cAliasPesq)->(Eof())
		MSGINFO( "Não existem dados para visualizar", "Atenção" )
		Break
	Endif

    ZPECF034BW(_cCodProd,  _cAliasPesq, _aBrwCab)

End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	//Ferase(_cTable+GetDBExtension())
    _oTable:Delete()
Endif      
Return Nil


//gerar browse com informações Kardex
Static Function ZPECF034BW(_cCodProd,  _cAliasPesq, _aBrwCab)
Local _cTitulo      := "Pedidos de Compra "
Local _oBrw
//Local _oBrwInf
//Local _nPos

Begin Sequence

    //implemento com o nome e o codigo do produto 
    If !Empty(_cCodProd)
        SB1->(DbSetOrder(1)) 
        SB1->(DbSeek(FwXFilial("SB1")+_cCodProd))
        _cTitulo += " Produto: "
        _cTitulo += AllTrim(_cCodProd)
        _cTitulo += " - "
        _cTitulo += AllTrim(SB1->B1_DESC)
    //Caso não tenha informado o produto tenho que incluir o código do produto para visualizar
    Endif


	DbSelectArea(_cAliasPesq)
 	_oBrw := FWMBrowse():New()
	_oBrw:SetCanSaveArea(.T.)	//abertura de mais de uma  browse
	_oBrw:SetTemporary(.T.)
    //_oBrw:SetOwner(_oTPanel01)
    _oBrw:SetAlias(_cAliasPesq)	
	_ObrW:SetMenuDef('')
	_ObrW:SetFields(_aBrwCab)
    _ObrW:SetIgnoreARotina(.T.) // Indica que a mbrowse, ira ignorar a variavel private aRotina na construção das opções de menu.
    _ObrW:SetWalkThru(.F.)
    _ObrW:DisableConfig() // Desabilita a utilização do Browse
    _ObrW:SetAmbiente(.F.) //Habilita a utilização da funcionalidade Ambiente no Browse
    _ObrW:SetFixedBrowse(.T.)
	_ObrW:DisableDetails()
    //_ObrW:ForceQuitButton()     
	//Definimos o título que será exibido como método SetDescription
	_ObrW:SetDescription(_cTitulo)
    //Definimos a tabela que será exibida na Browse utilizando o método SetAlias
    //Legenda da grade, é obrigatório carregar antes de montar as colunas
	
    _ObrW:AddLegend("AllTrim(NAC_IMP) = 'IMP'  "  ,"BLUE" 	   	,"Importado")
	_ObrW:AddLegend("AllTrim(NAC_IMP) = 'NAC'    "  ,"GREEN"     ,"Nacional")

	_ObrW:AddButton("Pedido de Compra" 	, { || FWMsgRun(, {|| ZPEC34PC(_cAliasPesq) }, "Pedido de Compra", "Localizando Pedido de Compra") },,,, .F., 2 )  //função no ZPECFUNA
  
   //Ativamos a classe
    _ObrW:Refresh(.T.)
	_ObrW:Activate()
End Sequence 
Return Nil



/*/{Protheus.doc} ZPEC34PC
//Mostrar PC e ou PO
@author DAC denilso
@since 27/05/2023
@version 1.0
@return Nil
@type User function
/*/

Static Function ZPEC34PC(_cAliasPesq)
Local _nTipo := 1
Local _nOpc  := 2
//vISUALIZAR pEDIDO DE cOMPRAS
  //Mata120(ExpN1,ExpA1,ExpA2,ExpN2,ExpA1)
    /*
    ExpN1 = 1-Pedido de compras ou 2-Autorizacao de entrega
    ExpA1 = Array Cabecalho para Rotina Automatica 
    ExpA2 = Array Itens para Rotina Automatica 
    ExpN2 = Opcao do aRotina para Rotina Automatica 
    ExpA1 = Apresenta a Dialog da Rotina em Rotina Automatica (.T. ou .F.)
    */
//nota fiscal de Saida
    SC7->(DBGOTO((_cAliasPesq)->NRECNO))
   	SC7->(Mata120(_nTipo,/*aCabec*/,/*aItens*/,_nOpc,.T.)) 
Return Nil	

