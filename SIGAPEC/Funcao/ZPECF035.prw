#Include "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "TOTVS.ch"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWBROWSE.CH"
#Include "FWMVCDEF.CH"

#define CRLF chr(13) + chr(10)  

/*/{Protheus.doc} ZPECF035
Localção WIS
@author     DAC - Denilso 
@since      05/07/2023
@version    1.0
@obs        Tela esta relacionada com a funcionalidade ZPECF030 a mesma poderá ser colocada também no menu com a chamada ZPECF032 caso seja necessário adaptar parametros para a procura  
/*/

User Function ZPECF035(_cCodProd)
Local _aArea := GetArea()
Local _cCodProdDe   := Space(Len(SB1->B1_COD))
Local _cCodProdAte  := Space(Len(SB1->B1_COD))
Local _cCadastro    := OemToAnsi("Locação Wis")   
Local _cTitle  	    := OemToAnsi("Locação Wis")   
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
	    aAdd(_aSays,OemToAnsi("Este Programa tem  como objetivo mostrar os os saldos existentes no WIS.")) 
	    aAdd(_aSays,OemToAnsi("Sendo possível verificar as notas pendentes em relação as quantidades entre")) 
	    aAdd(_aSays,OemToAnsi("WIS e Protheus relativos a conferência de mercadorias")) 

	    aAdd(_aButtons, { 1,.T.,{|o| FechaBatch(),_nRet:=1											}})
	    aAdd(_aButtons, { 2,.T.,{|o| FechaBatch()													}})
	    aAdd(_aButtons, { 5,.T.,{|o| ParamBox(_aPar,_cTitle,@_aRet,,,.T.,,,,"ZPECF035",.T.,.T.) 	}})

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

	FwMsgRun(,{ |_oSay| ZPECF035PR(_aRet, _cCodProd, @_oSay ) }, "Selecionando dados para a Montagem Saldos Wis", "Aguarde...")  

    RestArea(_aArea)
End Sequence
Return Nil

/*/{Protheus.doc} ZPECF035PR
Processar Localção WIS
@author     DAC - Denilso 
@since      26/06/2023
@version    1.0
@obs        
/*/
Static Function ZPECF035PR(_aRet, _cCodProd, _oSay)
Local _cCodProdDe   := _aRet[1]
Local _cCodProdAte  := _aRet[2]
Local _cAliasPesq   //:= GetNextAlias()
Local _cWhere       := ""
Local _cConectWis  := AllTrim(SuperGetMV( "CMV_PEC031"  ,,"WIS.V_ENDERECO_ESTOQUE@DBLINK_WISPROD")) 

Local _nPos
Local _aBrwCab
Local _aStru
Local _oTable
Local _aCpoCab
Local _cQuery
   
Begin Sequence
    _aCpoCab := {}
    Aadd( _aCpoCab, {"WIS", "CODEMPRE"      , "C","Empresa"         , 06, 0, "@!",.T. })  //Empresa Wis
    Aadd( _aCpoCab, {"WIS", "DESCEMPRE"     , "C","Desc. Empresa"   , 06, 0, "@!",.T. })  //Descrição Empresa Wis
    Aadd( _aCpoCab, {"WIS", "ARMAZEM"  	    , "C","Armazém"         , 03, 0, "@!",.T. })  //Armazém Wis
    Aadd( _aCpoCab, {"WIS", "DESCARMAZ"     , "C","Descr. Armazém"  , 20, 0, "@!",.T. })  //Descrição Armazém Wis
    Aadd( _aCpoCab, {"WIS", "ENDERECO" 	    , "C","Endereço"        , 15, 0, "@!",.T. })  //Endereço Armazém Wis
    Aadd( _aCpoCab, {"WIS", "QTDISPON" 	    , "N","Qtde Disponivel" , 14, 0, "@!",.T. })  //Qtde Disponivel Wis
    Aadd( _aCpoCab, {"WIS", "QTESTOQUE"     , "N","Qtde Estoque"    , 14, 0, "@!",.T. })  //Qtde Estoque Wis
    Aadd( _aCpoCab, {"WIS", "QTRESERVA"     , "N","Qtde Reserva"    , 14, 0, "@!",.T. })  //Qtde Reserva Wis
    Aadd( _aCpoCab, {"WIS", "QTTRANSIT"     , "N","Qtde Transito"   , 14, 0, "@!",.T. })  //Qtde Transito Wis

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
    _oTable:AddIndex("INDEX1", {"CODEMPRE", "ARMAZEM", "ENDERECO"} )
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
 
    _cQuery += " SELECT  ESTWIS.CD_EMPRESA AS EMPRESA "+ CRLF 
    _cQuery += "        ,CASE ESTWIS.CD_EMPRESA WHEN 1006 THEN 'HYU/SBR' ELSE 'CHE' END    AS DESCRICAO_EMPRESA "+ CRLF 
    _cQuery += "        ,ESTWIS.ARMAZEM	AS ARMAZEM "+ CRLF 
    _cQuery += "        ,CASE ESTWIS.ARMAZEM WHEN 'BAR' THEN 'BARUERI' ELSE 'FRANCO DA ROCHA' END    AS DESCRICAO_ARMAZEM "+ CRLF 
    _cQuery += "        ,ESTWIS.CD_ENDERECO	AS ENDERECO "+ CRLF 
    _cQuery += "        ,(NVL(ESTWIS.QT_ESTOQUE,0) - ( NVL(ESTWIS.QT_RESERVA_SAIDA,0) + NVL(ESTWIS.QT_TRANSITO_SAIDA,0) ) ) AS QTDE_DISPONIVEL "+ CRLF 
    _cQuery += "        ,NVL(ESTWIS.QT_ESTOQUE,0) 			AS QTDE_ESTOQUE "+ CRLF 
    _cQuery += "        ,NVL(ESTWIS.QT_RESERVA_SAIDA,0) 	AS QTDE_RESERVA "+ CRLF 
    _cQuery += "        ,NVL(ESTWIS.QT_TRANSITO_SAIDA,0)	AS QTDE_TRANSITO "+ CRLF 
     _cQuery += "        ,' '                AS  D_E_L_E_T_ "+ CRLF
    _cQuery += "        ,ROW_NUMBER() OVER (ORDER BY ESTWIS.CD_EMPRESA, ESTWIS.ARMAZEM, ESTWIS.CD_ENDERECO)     AS  R_E_C_N_O_ "+ CRLF    
	_cQuery += " FROM " + _cConectWis + " ESTWIS "+ CRLF
	_cQuery += " WHERE RTRIM(LTRIM(ESTWIS.CD_PRODUTO)) BETWEEN '"+_cCodProdDe+"'  AND '"+_cCodProdAte+"' "+ CRLF
	_cQuery += " ORDER BY ESTWIS.CD_EMPRESA, ESTWIS.ARMAZEM, ESTWIS.CD_ENDERECO "+ CRLF

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

    ZPECF035BW(_cCodProd,  _cAliasPesq, _aBrwCab)

End Sequence
If Select((_cAliasPesq)) <> 0
	(_cAliasPesq)->(DbCloseArea())
	//Ferase(_cTable+GetDBExtension())
    _oTable:Delete()
Endif      
Return Nil


/*/{Protheus.doc} ZPECF035BW
Visualizar Locação WIS
@author     DAC - Denilso 
@since      26/06/2023
@version    1.0
@obs        
/*/
Static Function ZPECF035BW(_cCodProd,  _cAliasPesq, _aBrwCab)
Local _cTitulo      := "Locação WIS "
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
	
   //Ativamos a classe
    _ObrW:Refresh(.T.)
	_ObrW:Activate()
End Sequence 
Return Nil



