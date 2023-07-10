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
User Function ZPECF032(_cCodProd)
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
	    aAdd(_aPar,{3,OemToAnsi("Mostra Canc/Fatur") ,2 ,{"1=Sim","2=Não"}	,80,"",.T.})  //Mostra Canc/Fatur / 1=Sim 2=Não

	    // Monta Tela principal
	    aAdd(_aSays,OemToAnsi("Este Programa tem  como objetivo mostrar os Orçamentos.")) 
	    aAdd(_aSays,OemToAnsi("aos quais estão pendentes, sendo que os mesmos estão na")) 
	    aAdd(_aSays,OemToAnsi("fase antes do carregamento")) 

	    aAdd(_aButtons, { 1,.T.,{|o| FechaBatch(),_nRet:=1											}})
	    aAdd(_aButtons, { 2,.T.,{|o| FechaBatch()													}})
	    aAdd(_aButtons, { 5,.T.,{|o| ParamBox(_aPar,_cTitle,@_aRet,,,.T.,,,,"ZPECF032",.T.,.T.) 	}})

	    FormBatch( _cCadastro, _aSays, _aButtons )
	    If _nRet <> 1
		    Break
	    Endif
	    If Len(_aRet) == 0
    		Help( , ,OemToAnsi("Atenção"),,OemToAnsi("Necessário informar os parâmetros"),4,1)   
    		Break 
    	Endif
	Else
		Aadd(_aRet, _cCodProd )  //De		
		Aadd(_aRet, _cCodProd )  //Ate	
		Aadd(_aRet, 2 )	         //Imprime cancelado e faturado	
    Endif
	FwMsgRun(,{ |_oSay| ZPECF032PR(_aRet, _cCodProd, @_oSay ) }, "Selecionando dados Referente Orçamento", "Aguarde...")  

    RestArea(_aArea)
End Sequence
Return Nil


/*/{Protheus.doc} ZPECF032PR
Processa visualização Orçamentos de Itens 
@author     DAC - Denilso 
@since      26/05/2023
@version    1.0
/*/
Static Function ZPECF032PR(_aRet, _cCodProd, _oSay)
Local _cCodProdDe   := _aRet[1]
Local _cCodProdAte  := _aRet[2]
Local _lMostraCF    := _aRet[3] == 1
Local _aBrwFil		:= {}
Local _aStru        := {}
Local _aCampos      := {}
Local _cQuery       := ""
Local _cTitulo      := ""
Local _cFaseConf 	:= Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Local _cFaseOrc 	:= AllTrim(GetNewPar("MV_FASEORC","023R45F"))
Local _cFase
Local _cFasePrc
Local _cWhereVS1
Local _aTamSx3
Local _cAliasPesq    //:= GetNextAlias()
Local _ObrW         
Local _nPos
Local _nPosCpo
Local _lInicio

Default _cCodProd   := Space(Len(VS3->VS3_CODITE))
    
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
   	aAdd( _aCampos, {"VX5", "ORC_TIPO"   , "C","Tipo"       , 30, 0, "@!",.T.})
 	aAdd( _aCampos, {"VS1", "RECNOVS1"   , "N","Recno VS1"  , 10, 0, "@!",.F. /*não ncluir no browse*/})
    
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

    //indica que mostra cancelado e faturado
    _cWhereVS1 := ""
    If !_lMostraCF
     	_cWhereVS1 += "	AND VS1.VS1_STATUS IN "+ FormatIn(_cFasePrc,";") +" "+ CRLF
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
    _cQuery += "        ,SUBSTR(VX5.VX5_DESCRI,1,30)   AS  ORC_TIPO "  + CRLF
    _cQuery += "        ,VS1.R_E_C_N_O_     AS  RECNOVS1 "  + CRLF
    _cQuery += "        ,' '                AS  D_E_L_E_T_ "+ CRLF
    _cQuery += "        ,ROW_NUMBER() OVER (ORDER BY VS3_XPICKI, VS3_NUMORC, VS3_SEQUEN)     AS  R_E_C_N_O_ "+ CRLF    
	_cQuery += "FROM "+RetSqlName("VS3")+" VS3 "+ CRLF
	_cQuery += "JOIN "+RetSqlName("VS1")+" VS1 "+ CRLF
	_cQuery += "	ON 	VS1.D_E_L_E_T_  = ' ' "+ CRLF
	_cQuery += "	AND VS1.VS1_FILIAL	= '"+FwXFilial("VS1")+"' " + CRLF
	_cQuery += "	AND VS1.VS1_NUMORC 	= VS3.VS3_NUMORC "+ CRLF
	_cQuery += "	AND VS1.VS1_TIPORC 	= '1' "+ CRLF
	//_cQuery += "	AND VS1.VS1_STATUS IN "+ FormatIn(_cFasePrc,";") +" "+ CRLF
	_cQuery +=      _cWhereVS1 
	_cQuery += "JOIN "+RetSqlName("SA1")+" SA1 "+ CRLF
	_cQuery += "	ON 	SA1.D_E_L_E_T_  = ' ' "+ CRLF
	_cQuery += "	AND SA1.A1_FILIAL	= '"+FwXFilial("SA1")+"' "+ CRLF
	_cQuery += "	AND SA1.A1_COD 	    = VS1.VS1_CLIFAT "+ CRLF
	_cQuery += "	AND SA1.A1_LOJA 	= VS1.VS1_LOJA "+ CRLF
    _cQuery += "LEFT JOIN "+RetSqlName("VX5")+" VX5 "+ CRLF
	_cQuery += "	ON 	VX5.D_E_L_E_T_  = ' ' " + CRLF
	_cQuery += "	AND VX5.VX5_FILIAL  = '"+FwXFilial("VX5")+"' "+ CRLF
	_cQuery += "	AND VX5.VX5_CHAVE   = 'Z00' "+ CRLF
	_cQuery += "	AND VX5.VX5_CODIGO  = VS1.VS1_XTPPED "+ CRLF
	_cQuery += "WHERE  VS3.D_E_L_E_T_   = ' ' "+ CRLF
	_cQuery += "	AND VS3.VS3_FILIAL	= '"+FwXFilial("VS3")+"' "+ CRLF
    _cQuery += "    AND VS3.VS3_CODITE  BETWEEN '"+_cCodProdDe+"'  AND '"+_cCodProdAte+"' "+ CRLF    
    _cQuery += "ORDER BY VS3.VS3_NUMORC, VS3.VS3_SEQUEN "+ CRLF    

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
    _ObrW:ForceQuitButton()     

	//Definimos o título que será exibido como método SetDescription
	_ObrW:SetDescription(_cTitulo)
//	//Legenda da grade, é obrigatório carregar antes de montar as colunas
	_ObrW:AddLegend("VS1_STATUS = '0' "  ,"YELLOW" 	   	,"Digitado")
	_ObrW:AddLegend("VS1_STATUS = '2'"   ,"RED"   		,"Margem Pendente")
	_ObrW:AddLegend("VS1_STATUS = '3'"   ,"BLACK"   	,"Avaliacao de Credito")
	_ObrW:AddLegend("VS1_STATUS = 'F'"   ,"GREEN"       ,"liberação p/ faturamento")
	_ObrW:AddLegend("VS1_STATUS = 'C' "  ,"BLUE" 	   	,"cancelado")
	_ObrW:AddLegend("VS1_STATUS = 'X ' " ,"WHITE" 	   	,"Sem Faturado")

	_ObrW:AddButton("Visualiza Orçamento"  	, { || FWMsgRun(, {|oSay| U_XFVERORC(_cAliasPesq,@_ObrW) }, "Orçamento", "Localizando Orçamento") },,,, .F., 2 )  //função no ZPECFUNA

   //Ativamos a classe
    _ObrW:Refresh(.T.)
	_ObrW:Activate()
End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	//Ferase(_cTable+GetDBExtension())
    _oTable:Delete()
Endif      
Return Nil






