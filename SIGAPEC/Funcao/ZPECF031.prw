#Include "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "TOTVS.ch"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWBROWSE.CH"
#Include "FWMVCDEF.CH"

#define CRLF chr(13) + chr(10)  

/*/{Protheus.doc} ZPECF031
Visualizar Picking de itens 
@author     DAC - Denilso 
@since      26/05/2023
@version    1.0
@obs        Tela esta relacionada com a funcionalidade ZPECF030 a mesma poderá ser colocada também no menu com a chamada ZPECF032 caso seja necessário adaptar parametros para a procura  

/*/



User Function ZPECF031(_cCodProd, _lPickAll, _lMostraCF)
Local _aArea := GetArea()

Default _cCodProd   := Space(Len(VS3->VS3_CODITE))
Default _lPickAll   := .T.
Default _lMostraCF  := .T.

    ZPECF031PR(_cCodProd, _lPickAll, _lMostraCF)

RestArea(_aArea)
Return Nil



Static Function ZPECF031PR(_cCodProd, _lPickAll, _lMostraCF)
Local _aBrwFil		:= {}
Local _aStru         := {}
Local _aCampos      := {}
Local _cWhere       := ""
Local _cWhereSZK    := ""
Local _cQuery       := ""
Local _cTitulo      := ""
Local _aTamSx3
Local _cAliasPesq    //:= GetNextAlias()
Local _ObrW         
Local _nPos
Local _lInicio

Default _cCodProd   := Space(Len(VS3->VS3_CODITE))
Default _lPickAll   := .T.
Default _lMostraCF  := .T.
    
Begin Sequence
    _cTitulo      := "Posição Picking por Produto"
    //implemento com o nome e o codigo do produto 
    If !Empty(_cCodProd)
        SB1->(DbSetOrder(1)) 
        SB1->(DbSeek(FwXFilial("SB1")+_cCodProd))
        _cTitulo += " "
        _cTitulo += AllTrim(_cCodProd)
        _cTitulo += " - "
        _cTitulo += AllTrim(SB1->B1_DESC)
    //Caso não tenha informado o produto tenho que incluir o código do produto para visualizar
    Endif

    _aCampos := {}
    Aadd( _aCampos, {"VS3", "VS3_QTDITE" ,.T.})
    Aadd( _aCampos, {"VS3", "VS3_NUMORC" ,.T.})
    Aadd( _aCampos, {"VS3", "VS3_SEQUEN" ,.T.})
    Aadd( _aCampos, {"VS3", "VS3_XPICKI" ,.T.})
    Aadd( _aCampos, {"SZK", "ZK_SEQREG"  ,.T.})
    If SZK->(FieldPos("ZK_DTGERPI")) > 0
        Aadd( _aCampos, {"SZK", "ZK_DTGERPI",.T.})
    EndIf
    Aadd( _aCampos, {"SZK", "ZK_DTRECPI" ,.T.})
 	If SZK->(FieldPos("ZK_USGERPI")) > 0
        Aadd( _aCampos, {"SZK", "ZK_USGERPI",.T.})
    EndIf
    Aadd( _aCampos, {"SA1", "A1_COD"     ,.F.})
    Aadd( _aCampos, {"SA1", "A1_LOJA"    ,.F.})
    Aadd( _aCampos, {"SA1", "A1_NREDUZ"  ,.T.})
    Aadd( _aCampos, {"SZK", "ZK_STATUS"  ,.F.})
    Aadd( _aCampos, {"VS3", "VS3_CODITE" ,If( Empty(_cCodProd),.T.,.F.) })
    Aadd( _aCampos, {"VS3", "VS3_FILIAL" ,.F.})
    //Campos não constantes no dicionário
 	aAdd( _aCampos, {"SZK","PK_STATUS", "C","Status Picking", 10, 0, "@!",.T.})
    //Campos que serao incluídos no browse mas criados na tabela
 	aAdd( _aCampos, {"VS1","RECNOVS1" , "N","Recno VS1"     , 10, 0, "@!",.F. /*não ncluir no browse*/})
    
    _aBrwFil    := {}
    _aStru      := {}  //Estrutura do Banco
    For _nPos := 1 To Len(_aCampos)
        If Len(_aCampos[_nPos]) == 3
            _aTamSx3 := TamSX3(_aCampos[_nPos,2])
            If _aCampos[_nPos,Len(_aCampos[_nPos])]  //Valida se a coluna irá para o Browse
                Aadd(_aBrwFil,{ RetTitle(_aCampos[_nPos,2]),;    //titulo
                                _aCampos[_nPos,2],;             //campo
                                _aTamSx3[03],;                  //tipo
                                _aTamSx3[01],;                  //tamanho
                                _aTamSx3[02],;                  //decimal
                             PesqPict(_aCampos[_nPos,1],_aCampos[_nPos,2]);  //pict
                          })
            Endif
            Aadd(_aStru, {_aCampos[_nPos,02], _aTamSx3[03], _aTamSx3[01], _aTamSx3[02] })
        Else  
            If _aCampos[_nPos,Len(_aCampos[_nPos])]  //Valida se a coluna irá para o Browse
                Aadd(_aBrwFil,{ _aCampos[_nPos,4],;             //titulo
                                _aCampos[_nPos,2],;             //campo
                                _aCampos[_nPos,3],;             //tipo
                                _aCampos[_nPos,5],;             //tamanho    
                                _aCampos[_nPos,6],;             //decimal
                                _aCampos[_nPos,7];              //pict
                                })
            Endif
            Aadd(_aStru, { _aCampos[_nPos,02], _aCampos[_nPos,03], _aCampos[_nPos,05], _aCampos[_nPos,06] })
        Endif
    Next

    _oTable := FWTemporaryTable():New()
    _oTable:SetFields(_aStru)
    _oTable:AddIndex("INDEX1", {"VS3_XPICKI", "VS3_NUMORC", "VS3_SEQUEN"} )
    _oTable:Create()
    _cAliasPesq := _oTable:GetAlias()

    _cTable := _oTable:GetRealName()

	_cWhere     := ""
    _cWhereSZK  := ""
    //Somente picking deste produto
   
	If !Empty(_cCodProd) .And. !_lPickAll
		_cWhere +=   " AND VS3.VS3_CODITE = '"+_cCodProd+"'"+ CRLF
	//indica se trara todos os demais produtos do Pincking quando estiver indicado produto
    ElseIf !Empty(_cCodProd) .And. _lPickAll
        _cWhereSZK += "AND  (   SELECT DISTINCT VS3A.VS3_CODITE "+ CRLF
        _cWhereSZK += "         FROM VS3020 VS3A " + CRLF
        _cWhereSZK += "         WHERE VS3A.VS3_XPICKI  =  SZK.ZK_XPICKI "+ CRLF
        _cWhereSZK += "             AND VS3A.VS3_CODITE =  '"+_cCodProd+"') <> ' ' "+ CRLF
	Endif
    //indica que mostra cancelado e faturado
    If !_lMostraCF
		_cWhereSZK += "	AND SZK.ZK_STATUS NOT IN ('C','F') "
    EndIf

    _cQuery := " INSERT INTO "+_cTable+"                                                                                    "+(Chr(13)+Chr(10))
    _cQuery += " ("
    For _nPos := 01 To Len(_aStru)
        _cQuery += _aStru[_nPos,1]
        _cQuery += ", "
    NEXT _nPos
    _cQuery += " D_E_L_E_T_, R_E_C_N_O_ "  
    _cQuery += " )"+ CRLF
    _cQuery += "SELECT  "
    //montar os campos que possuem no dicionário os demais que não estão no dicionário devem ser os ultimos e implemeentados conforme select
    _lInicio:= .T.
    For _nPos := 1 To Len(_aCampos)   
        If Len(_aCampos[_nPos]) == 3
            If !_lInicio
 	            _cQuery +=  "   ,"+_aCampos[_nPos,1] +"." +_aCampos[_nPos,2]+ " AS "+ _aCampos[_nPos,2] +CRLF
            Else
 	            _cQuery +=  "    "+_aCampos[_nPos,1] +"." +_aCampos[_nPos,2]+ " AS "+ _aCampos[_nPos,2] +CRLF
                _lInicio:= .F.
            Endif
        Endif 
    Next _nPos       
    //Campos não normatizados pelo dicionário 
    _cQuery += "        , CASE "+ CRLF
	_cQuery += "             WHEN  SZK.ZK_STATUS = 'A'   THEN 'ABERTO   ' "+ CRLF
    _cQuery += "             WHEN  SZK.ZK_STATUS = 'B'   THEN 'BLOQUEADO' "+ CRLF
    _cQuery += "             WHEN  SZK.ZK_STATUS = 'C'   THEN 'CANCELADO' "+ CRLF
	_cQuery += "             WHEN  SZK.ZK_STATUS = 'E'   THEN 'ENVIADO  ' "+ CRLF
    _cQuery += "             WHEN  SZK.ZK_STATUS = 'F'   THEN 'FATURADO ' "+ CRLF
    _cQuery += "         ELSE 'STATUS NÃO INFORMADO' "+ CRLF
    _cQuery += "         END AS PK_STATUS "+ CRLF
    _cQuery += "        ,VS1.R_E_C_N_O_     AS  RECNOVS1 "  + CRLF
    _cQuery += "        ,' '                AS  D_E_L_E_T_ "+ CRLF
    _cQuery += "        ,ROW_NUMBER() OVER (ORDER BY VS3_XPICKI, VS3_NUMORC, VS3_SEQUEN)     AS  R_E_C_N_O_ "+ CRLF    
    
	_cQuery += "FROM "+RetSqlName("VS3")+" VS3 "+ CRLF
	_cQuery += "JOIN "+RetSqlName("VS1")+" VS1 "+ CRLF
	_cQuery += "	ON 	VS1.D_E_L_E_T_ = ' ' "+ CRLF
	_cQuery += "	AND VS1.VS1_FILIAL	= '"+FwXFilial("VS1")+"' " + CRLF
	_cQuery += "	AND VS1.VS1_NUMORC 	= VS3.VS3_NUMORC "+ CRLF
	_cQuery += "	AND VS1.VS1_TIPORC 	= '1' "+ CRLF
	_cQuery += "JOIN "+RetSqlName("SA1")+" SA1 "+ CRLF
	_cQuery += "	ON 	SA1.D_E_L_E_T_ = ' ' "+ CRLF
	_cQuery += "	AND SA1.A1_FILIAL	= '"+FwXFilial("SA1")+"' "+ CRLF
	_cQuery += "	AND SA1.A1_COD 	    = VS1.VS1_CLIFAT "+ CRLF
	_cQuery += "	AND SA1.A1_LOJA 	= VS1.VS1_LOJA "+ CRLF
	_cQuery += "JOIN "+RetSqlName("SZK")+" SZK "+ CRLF
	_cQuery += "	ON 	SZK.D_E_L_E_T_ = ' ' " + CRLF
	_cQuery += "	AND SZK.ZK_FILIAL	= '"+FwXFilial("SZK")+"' "+ CRLF
	_cQuery += "	AND SZK.ZK_XPICKI 	= VS3.VS3_XPICKI "+ CRLF
	_cQuery += "	AND SZK.ZK_NF 		= ' ' "+ CRLF
	_cQuery +=      _cWhereszk 
	_cQuery += "WHERE  VS3.D_E_L_E_T_ = ' ' "
	_cQuery += "	AND VS3.VS3_FILIAL	= '"+FwXFilial("VS3")+"' "+ CRLF
	_cQuery += "	AND VS3.VS3_XPICKI 	<> ' ' "+ CRLF
    _cQuery +=      _cWhere
    _cQuery += "ORDER BY VS3.VS3_XPICKI, VS3.VS3_NUMORC, VS3.VS3_SEQUEN"    

	nStatus := TCSqlExec(_cQuery)
    If (nStatus < 0)
        MsgStop("TCSQLError() " + TCSQLError(), "Registros Cabeçalho")
        Break    
    Endif
    
    (_cAliasPesq)->(DbGoTop())
	If (_cAliasPesq)->(Eof())
		MSGINFO( "Não existe Picking pendente para este item", "Atenção" )
		Break
	Endif
	DbSelectArea(_cAliasPesq)

 	_ObrW := FWMBrowse():New()
	_ObrW:SetCanSaveArea(.T.)	//abertura de mais de uma  browse
	_ObrW:SetTemporary(.T.)
    _oBrw:SetAlias(_cAliasPesq)	
	_ObrW:SetMenuDef('')
	_ObrW:SetFields(_aBrwFil)
    _ObrW:SetIgnoreARotina(.T.) // Indica que a mbrowse, ira ignorar a variavel private aRotina na construção das opções de menu.
    _ObrW:SetWalkThru(.F.)
    _ObrW:DisableConfig() // Desabilita a utilização do Browse
    _ObrW:SetAmbiente(.F.) //Habilita a utilização da funcionalidade Ambiente no Browse
    _ObrW:SetFixedBrowse(.T.)
	_ObrW:DisableDetails()
    _ObrW:ForceQuitButton()     

    //_ObrW:DisableReport() // Desabilita a impressão das informações disponíveis no Browse

	//_ObrW:SetSeek(.T.,_aSeek)
   	//_ObrW:SetUseFilter(.T.)  //Habilita a utilização do filtro no Browse
     //_ObrW:SetDBFFilter(.T.)
    //_ObrW:SetFilterDefault( "" ) //Indica o filtro padrão do Browse //Exemplo de como inserir um filtro padrão >>> "TR_ST == ‘A‘"
    //_ObrW:SetFieldFilter(_aFieFilter)
	//_ObrW:SetLocate()
	//_ObrW:SetAmbiente(.F.)
	//_ObrW:SetWalkThru(.F.)
	//Adiciona um filtro ao browse
    //	_ObrW:SetFilterDefault( "A1_COD = '"+Space(8)+"' " ) //Exemplo de como inserir um filtro padrão >>> "TR_ST == 'A'"
	//Desliga a exibição dos detalhes
	/*
    //_ObrW:SetColumns(MBColumn(_aCols)) //Adiciona uma coluna no Browse em tempo de execução    
	_ObrW:SetOnlyFields( {	"VS3_CODITE"	,;//Cód Produto
							"VS3_QTDEIT"	,;//Descrição Produto
							"VS3_VALPEC"	;//Embalagem Primária
							 } )
    */
	//Definimos o título que será exibido como método SetDescription
	_ObrW:SetDescription(_cTitulo)
    //Definimos a tabela que será exibida na Browse utilizando o método SetAlias
//	//Legenda da grade, é obrigatório carregar antes de montar as colunas
	_ObrW:AddLegend("ZK_STATUS = 'A' "  ,"YELLOW" 	   	,"Aberto")
	_ObrW:AddLegend("ZK_STATUS = 'B'"   ,"RED"   		,"Boqueado")
	_ObrW:AddLegend("ZK_STATUS = 'C'"   ,"BLACK"   		,"Cancelado")
	_ObrW:AddLegend("ZK_STATUS = 'E'"   ,"GREEN"   	    ,"Enviado")
	_ObrW:AddLegend("ZK_STATUS = 'F' "  ,"BLUE" 	   	,"Faturado")
	_ObrW:AddLegend("ZK_STATUS = ' ' "  ,"WHITE" 	   	,"Sem Informação")

	_ObrW:AddButton("Visualiza Picking"		, { || FWMsgRun(, {|oSay| ZPECF031PK(_cAliasPesq,@_ObrW) }, "Picking"	, "Localizando Picking") },,,, .F., 2 )
	_ObrW:AddButton("Visualiza Orçamento"  	, { || FWMsgRun(, {|oSay| U_XFVERORC(_cAliasPesq,@_ObrW) }, "Orçamento", "Localizando Orçamento") },,,, .F., 2 )  //função no ZPECFUNA

   //Ativamos a classe
    _ObrW:Refresh(.T.)
	_ObrW:Activate()


//           		WHEN  ZK.ZK_STATUS = 'A' THEN 'ABERTO' 
//           		WHEN  ZK.ZK_STATUS = 'B' THEN 'BLOQUEADO' 
//           		WHEN  ZK.ZK_STATUS = 'C' THEN 'CANCELADO' 
//           		WHEN  ZK.ZK_STATUS = 'E' THEN 'ENVIADO' 
//           		WHEN  ZK.ZK_STATUS = 'F' THEN 'FATURADO' 
		

End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	//Ferase(_cTable+GetDBExtension())
    _oTable:Delete()
Endif      
Return Nil

/*/{Protheus.doc} ZPECF031PK
Mostrat Picking 
@author DAC - Denilso 
@since 26/05/2023
@version 2.0
/*/
Static Function ZPECF031PK(_cAliasPesq,_ObrW)
Local _lRet     := .T.
Local _aArea := GetArea()
//    _nPos := _ObrW:nat 
    If _lRet 
        U_ZPECF013(FWxFilial("SZK"),(_cAliasPesq)->VS3_XPICKI)
    EndIf
    RestArea(_aArea)
Return Nil





