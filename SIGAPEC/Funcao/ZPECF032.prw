#Include "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "TOTVS.ch"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWBROWSE.CH"
#Include "FWMVCDEF.CH"

#define CRLF chr(13) + chr(10)  

/*/{Protheus.doc} ZPECF032
Viualizar Orçamentos de Itens 
@author     DAC - Denilso 
@since      26/05/2023
@version    1.0
@obs        Tela esta relacionada com a funcionalidade ZPECF030 a mesma poderá ser colocada também no menu com a chamada ZPECF032 caso seja necessário adaptar parametros para a procura  
/*/



User Function ZPECF032(_cCodProd, _lPickAll, _lMostraCF)
Local _aArea := GetArea()

Default _cCodProd   := Space(Len(VS3->VS3_CODITE))
Default _lPickAll   := .T.
Default _lMostraCF  := .T.

    ZPECF032PR(_cCodProd, _lPickAll, _lMostraCF)

RestArea(_aArea)
Return Nil



Static Function ZPECF032PR(_cCodProd, _lPickAll, _lMostraCF)
Local _aBrwFil		:= {}
Local _aStru         := {}
Local _aCampos      := {}
Local _cWhere       := ""
Local _cWherevs1    := ""
Local _cQuery       := ""
Local _cTitulo      := ""
Local _cFaseConf 	:= Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Local _cFaseOrc 	:= AllTrim(GetNewPar("MV_FASEORC","023R45F"))
Local _cFase
Local _cFasePrc
Local _aTamSx3
Local _cAliasPesq    //:= GetNextAlias()
Local _ObrW         
Local _nPos
Local _nPosCpo
Local _lInicio

Default _cCodProd   := Space(Len(VS3->VS3_CODITE))
Default _lPickAll   := .T.
Default _lMostraCF  := .T.
    
Begin Sequence
	//Definir as fases que serão atendidas no processo
	_nPosCpo := AT(_cFaseConf, _cFaseOrc)
	If _nPosCpo == 0 
		MSGINFO( "Não existe fase de orçamento no parâmetro indicativo de Fase", "[ZPECF032PR] - Atenção" )
		Break
	Endif
	//identifico os status do orçamento (fase) para trazer na tela
	_cFase := SubsTr(_cFaseOrc, 1, _nPosCpo -1)
	If Empty(_cFase) 
		MSGINFO( "Não localizado fase de orçamento no parâmetro indicação de Fase", "[ZPECF032PR] - Atenção" )
		Break
	Endif
    _cFasePrc   := ""
    For _nPos := 1 To LEN( _cFase )
        _cFasePrc   += SubsTr(_cFase,_nPos,1)+";"
    Next _nPos
    //_cFasePrc := SubsTr(_cFasePrc,1, Len(_cFasePrc)-1)
    _cFasePrc := SubsTr(_cFasePrc,1, Len(_cFasePrc))

    _cTitulo      := "Posição Orçamento por Produto"
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
    Aadd( _aCampos, {"VS3", "VS3_QTDINI" ,.T.})
    Aadd( _aCampos, {"VS1", "VS1_STATUS" ,.F.})
    Aadd( _aCampos, {"VS3", "VS3_NUMORC" ,.T.})
    Aadd( _aCampos, {"VS3", "VS3_SEQUEN" ,.T.})
    Aadd( _aCampos, {"VS1", "VS1_XTPPED" ,.F.})
    Aadd( _aCampos, {"VS1", "VS1_DATORC" ,.T.})
    Aadd( _aCampos, {"VS1", "VS1_XPVAW"  ,.T.})
    //Campos que serao incluídos no browse mas criados na tabela
   	aAdd( _aCampos, {"VS1", "ORC_STATUS" , "C","Status Orc.", 30, 0, "@!",.T.})
 	aAdd( _aCampos, {"VS1", "RECNOVS1"   , "N","Recno VS1"  , 10, 0, "@!",.F. /*não ncluir no browse*/})
   	aAdd( _aCampos, {"VX5", "VX5_DESCRI" , "C","Tipo"       , 30, 0, "@!",.T.})
    
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
    _oTable:AddIndex("INDEX1", {"VS3_NUMORC", "VS3_SEQUEN"} )
    _oTable:Create()
    _cAliasPesq := _oTable:GetAlias()

    _cTable := _oTable:GetRealName()

	_cWhere     := ""
    _cWhereVS1  := ""
    //Somente picking deste produto
   
	If !Empty(_cCodProd) .And. !_lPickAll
		_cWhere +=   " AND VS3.VS3_CODITE = '"+_cCodProd+"'"+ CRLF
	//indica se trara todos os demais produtos do Pincking quando estiver indicado produto
    ElseIf !Empty(_cCodProd) .And. _lPickAll
        _cWhereVS1 += "AND  (   SELECT DISTINCT VS3A.VS3_CODITE "+ CRLF
        _cWhereVS1 += "         FROM VS3020 VS3A " + CRLF
        _cWhereVS1 += "         WHERE VS3A.VS3_NUMORC  =  VS1.VS1_NUMORC "+ CRLF
        _cWhereVS1 += "             AND VS3A.VS3_CODITE =  '"+_cCodProd+"') <> ' ' "+ CRLF
	Endif
    //indica que mostra cancelado e faturado
    If !_lMostraCF
        _cFasePrc += "C;F" 
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
	_cQuery += "             WHEN  VS1.VS1_STATUS = '0'   THEN '"+Upper("Digitado")                 +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = '2'   THEN '"+Upper("Margem Pendente")          +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = '3'   THEN '"+Upper("Avaliacao de Credito")     +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = '4'   THEN '"+Upper("Carregamento")             +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = 'S'   THEN '"+Upper("Aguardando Lib.Diverg.")   +"' "+ CRLF
	_cQuery += "             WHEN  VS1.VS1_STATUS = 'RT'  THEN '"+Upper("Aguardando Reserva")       +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = 'F'   THEN '"+Upper("liberação p/ faturamento") +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = 'P'   THEN '"+Upper("Pendente para O.S.")       +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = 'L'   THEN '"+Upper("Liberado para O.S.")       +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = 'I'   THEN '"+Upper("Importado para O.S.")      +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = 'C'   THEN '"+Upper("cancelado")                +"' "+ CRLF
    _cQuery += "             WHEN  VS1.VS1_STATUS = 'X'   THEN '"+Upper("Faturado")                 +"' "+ CRLF
    _cQuery += "         ELSE 'STATUS NÃO INFORMADO' "+ CRLF
    _cQuery += "         END AS ORC_STATUS "+ CRLF
    _cQuery += "        ,SUBSTR(VX5.VX5_DESCRI,1,30)   AS  VX5_DESCRI "  + CRLF
    _cQuery += "        ,VS1.R_E_C_N_O_     AS  RECNOVS1 "  + CRLF
    _cQuery += "        ,' '                AS  D_E_L_E_T_ "+ CRLF
    _cQuery += "        ,ROW_NUMBER() OVER (ORDER BY VS3_XPICKI, VS3_NUMORC, VS3_SEQUEN)     AS  R_E_C_N_O_ "+ CRLF    
	_cQuery += "FROM "+RetSqlName("VS3")+" VS3 "+ CRLF
	_cQuery += "JOIN "+RetSqlName("VS1")+" VS1 "+ CRLF
	_cQuery += "	ON 	VS1.D_E_L_E_T_ = ' ' "+ CRLF
	_cQuery += "	AND VS1.VS1_FILIAL	= '"+FwXFilial("VS1")+"' " + CRLF
	_cQuery += "	AND VS1.VS1_NUMORC 	= VS3.VS3_NUMORC "+ CRLF
	_cQuery += "	AND VS1.VS1_TIPORC 	= '1' "+ CRLF
	_cQuery += "	AND VS1.VS1_STATUS IN "+ FormatIn(_cFasePrc,";") +" "+ CRLF
    _cQuery +=      _cWhereVS1
	_cQuery += "JOIN "+RetSqlName("SA1")+" SA1 "+ CRLF
	_cQuery += "	ON 	SA1.D_E_L_E_T_ = ' ' "+ CRLF
	_cQuery += "	AND SA1.A1_FILIAL	= '"+FwXFilial("SA1")+"' "+ CRLF
	_cQuery += "	AND SA1.A1_COD 	    = VS1.VS1_CLIFAT "+ CRLF
	_cQuery += "	AND SA1.A1_LOJA 	= VS1.VS1_LOJA "+ CRLF
    _cQuery += "LEFT JOIN "+RetSqlName("VX5")+" VX5 "+ CRLF
	_cQuery += "	ON 	VX5.D_E_L_E_T_ = ' ' " + CRLF
	_cQuery += "	AND VX5.VX5_FILIAL = '"+FwXFilial("SA1")+"' "+ CRLF
	_cQuery += "	AND VX5.VX5_CHAVE = 'Z03' "+ CRLF
	_cQuery += "	AND VX5.VX5_CODIGO = VS1.VS1_XTPPED "
	_cQuery += "WHERE  VS3.D_E_L_E_T_ = ' ' "
	_cQuery += "	AND VS3.VS3_FILIAL	= '"+FwXFilial("VS3")+"' "+ CRLF
	_cQuery += "	AND VS3.VS3_XPICKI 	<> ' ' "+ CRLF
    _cQuery +=      _cWhere
    _cQuery += "ORDER BY VS3.VS3_NUMORC, VS3.VS3_SEQUEN"    

	nStatus := TCSqlExec(_cQuery)
    If (nStatus < 0)
        MsgStop("TCSQLError() " + TCSQLError(), "Registros Cabeçalho")
        Break    
    Endif
    
    (_cAliasPesq)->(DbGoTop())
	If (_cAliasPesq)->(Eof())
		MSGINFO( "Não existe Orçamento pendente para este item", "Atenção" )
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
	_ObrW:AddLegend("VS1_STATUS = '0' "  ,"YELLOW" 	   	,"Digitado")
	_ObrW:AddLegend("VS1_STATUS = '2'"   ,"RED"   		,"Margem Pendente")
	_ObrW:AddLegend("VS1_STATUS = '3'"   ,"BLACK"   	,"Avaliacao de Credito")
	_ObrW:AddLegend("VS1_STATUS = 'F'"   ,"GREEN"       ,"liberação p/ faturamento")
	_ObrW:AddLegend("VS1_STATUS = 'C' "  ,"BLUE" 	   	,"cancelado")
	_ObrW:AddLegend("VS1_STATUS = 'X ' " ,"WHITE" 	   	,"Sem Faturado")

	_ObrW:AddButton("Visualiza Orçamento"  	, { || FWMsgRun(, {|oSay| ZPECF032OP(_cAliasPesq,@_ObrW) }, "Orçamento", "Localizando Orçamento") },,,, .F., 2 )

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



/*/{Protheus.doc} ZPECF032OP
Mostrat Orçamento 
@author DAC - Denilso 
@since 31/05/2023
@version 1.0
/*/
Static Function ZPECF032OP(_cAliasPesq,_ObrW)
Local _lRet     := .T.
Local _nOpc     := 2
Local _aArea := GetArea()
Local _nReg
//infelizmente é necessário carregar as variaveis abaixo para que abra a tela de orçamento DAC
Private cCadastro := "Orçamento"
Private aItensKit := {}
Private aPedTransf := {}
Private cGruFor   := "04" 										// Grupo de Formulas que podem ser utilizadas nos orcamentos
Private lVAMCid  		:= GetNewPar("MV_CADCVAM","S") == "S" 	// Utiliza VAM (Cidades)?
Private lRecompra  	:= .F.										// Indica se eh um orcamento para recompra
Private lPassou := .f.											// Tratamento da mudanca de aba na funcao OX001MUDFOL()
Private aIteRel := {{"","","",0,0,"","",""}}					// Vetor contendo os itens relacionados da listbox oLItRel
Private aMemos1   := {{"VS1_OBSMEM","VS1_OBSERV"}}				// Observacao do Orcamento
Private lAbortPrint	:= .f.										// Variavel de Aborto de Operacao
Private lOrcJaRes := .f.
Private dDatOrc := ctod("")
//
Private cMV_VERIORC := Alltrim(GetNewPar("MV_VERIORC","1"))
Private lPediVenda := .f.
Private lCancParc := .f.
Private lAltPedVda := .f.
Private lPVP := .f.
Private lCancelPVP := .f.
Private lFaturaPVP := .f.
Private nUsadoPX01 := 0
Private oPedido := DMS_Pedido():New()
Private oSqlHlp := DMS_SqlHelper():New()
Private oDpm    := DMS_Dpm():New()
Private aNATrf  := {}
Private	cVS1Status := VS1->VS1_STATUS
Private cFaseOrc
Private lInconveniente := (GetNewPar("MV_INCORC","N") == "S")
Private lInconvObr     := (GetNewPar("MV_INCOBR","N") == "S")
Private cIncDefault    := Alltrim(GetNewPar("MV_MIL0094",""))	// SEM INSTALAR
// Variaveis de integracao
Private aAutoCab := {} 											// Cabecalho do Orcamento (VS1)
Private aAutoPecas := {}										// Pecas do Orcamento (VS3)
Private aAutoServ := {}											// Servicos do Orcamento (VS4)
Private aAutoInco := {}											// Inconvenientes do Orcamento
// 'lOX001Auto' indica se todos os vetores de integracao foram preenchidos
Private lOX001Auto := .f. //( xAutoCab <> NIL  .and. xAutoPecas <> NIL .and. xAutoServ <> NIL )
// Variaveis de Controle de tela (OBJETOS)
Private aTitulo := {"STR0136","STR0134","STR0135"}
Private nFolderI := 1 // Numero da Folder de Inconveniente
Private nFolderP := 2 // Numero da Folder de Pecas
Private nFolderS := 3 // Numero da Folder de Servicos
Private aNewBot := {}
Private nMaxItNF  := GetMv("MV_NUMITEN")
Private lAprMsg   := GetNewPar("MV_MIL0151",.T.)
Private lMsg0268 := .f. // Controle de Msg de Pedido Gravado
Private cVK_F := {}

Private n														// Controle do Fiscal para linha da aCols
Private aNumP := {}		  										// Controle do Fiscal para aCols de Pecas
Private aNumS := {}												// Controle do Fiscal para aCols de Servicos
Private nTotFis := 0											// Numero total de itens do Fiscal (pecas + servicos)
Private bRefresh := { || .t. } 									// Variavel necessaria ao MAFISREF
Private aCodErro := {"",""}										// Variavel de Codigo de Erro na Importacao de OS
Private aItensNImp := {}										// Variavel de retorno de importacao de pecas p/ O.S.
Private lJaPerg := .t. 											// Variavel necessaria ao OFIOC040

VISUALIZA := ( _nOpc == 2 )
INCLUI 	  := ( _nOpc == 3 )
ALTERA 	  := ( _nOpc == 4 )
EXCLUI 	  := ( _nOpc == 5 )
FECHA  	  := ( _nOpc == 6 )
//    _nPos := _ObrW:nat 
    _nReg := (_cAliasPesq)->RECNOVS1
    VS1->(DbGoto(_nReg))
    cVS1Status := VS1->VS1_STATUS
    cFaseOrc := OI001GETFASE(VS1->VS1_NUMORC)
    If _lRet 
        //OXA012V("VS1",_nReg,2)
        OX001EXEC("VS1",_nReg,2, /*lLibPV*/)
    EndIf
    RestArea(_aArea)
Return Nil



