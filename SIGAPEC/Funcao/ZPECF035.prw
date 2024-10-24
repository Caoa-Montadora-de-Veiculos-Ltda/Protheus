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
Local _cCodProdDe     := _aRet[1]
Local _cCodProdAte    := _aRet[2]
Local _cAliasPesq   //:= GetNextAlias()
Local _cAliasInfo
Local _cWhere         := ""
Local _cConectWis  	  := AllTrim(SuperGetMV( "CMV_PEC031"  ,,""))  //WIS.V_ENDERECO_ESTOQUE@DBLINK_WISPROD
Local _cConectArmWis  := AllTrim(SuperGetMV( "CMV_PEC043"  ,,""))  //WIS.RV_HIST_ARMAZENADO@DBLINK_WISPROD
Local _nPos
Local _aBrwCab
Local _aStru
Local _oTable
Local _aCpoCab
Local _aBrwInf 
Local _aCpoInf 
Local _cQuery
   
Begin Sequence
	If Empty(_cConectWis)
		MSGINFO( "Link de conexão WIS Estoque não habilitado, comumicar ADM Sistemas", "Atenção" )
		Break
	Endif
	If Empty(_cConectArmWis)
		MSGINFO( "Link de conexão WIS Armazenagem não habilitado, comumicar ADM Sistemas", "Atenção" )
		Break
	Endif

    _aCpoCab := {}
    Aadd( _aCpoCab, {"WIS", "CODEMPRE"      , "C","Empresa"         , 15, 0, "@!",.T. })  //Empresa Wis
    Aadd( _aCpoCab, {"WIS", "DESCEMPRE"     , "C","Desc. Empresa"   , 30, 0, "@!",.T. })  //Descrição Empresa Wis
    Aadd( _aCpoCab, {"WIS", "ARMAZEM"  	    , "C","Armazém"         , 10, 0, "@!",.T. })  //Armazém Wis
    Aadd( _aCpoCab, {"WIS", "DESCARMAZ"     , "C","Descr. Armazém"  , 20, 0, "@!",.T. })  //Descrição Armazém Wis
    Aadd( _aCpoCab, {"WIS", "ENDERECO" 	    , "C","Endereço"        , 15, 0, "@!",.T. })  //Endereço Armazém Wis
    Aadd( _aCpoCab, {"WIS", "QTDISPON" 	    , "N","Qtde Disponivel" , 14, 0, "@!",.T. })  //Qtde Disponivel Wis
    Aadd( _aCpoCab, {"WIS", "QTESTOQUE"     , "N","Qtde Estoque"    , 14, 0, "@!",.T. })  //Qtde Estoque Wis
    Aadd( _aCpoCab, {"WIS", "QTRESERVA"     , "N","Qtde Reserva"    , 14, 0, "@!",.T. })  //Qtde Reserva Wis
    Aadd( _aCpoCab, {"WIS", "QTTRANSIT"     , "N","Qtde Transito"   , 14, 0, "@!",.T. })  //Qtde Transito Wis

    _aBrwCab    := {}
    _aStru      := {}  //Estrutura do Banco
    For _nPos := 1 To Len(_aCpoCab)
        If _aCpoCab[_nPos,Len(_aCpoCab[_nPos])]  //Valida se a coluna irá para o Browse
            Aadd(_aBrwCab,{ _aCpoCab[_nPos,4],;             //titulo
                            _aCpoCab[_nPos,2],;             //campo
                            _aCpoCab[_nPos,3],;             //tipo
                            _aCpoCab[_nPos,5],;             //tamanho    
                            _aCpoCab[_nPos,6],;             //decimal
                            _aCpoCab[_nPos,7];              //pict
                                })
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
    If ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa 02-Franco da Rocha
        _cQuery += "        ,CASE ESTWIS.CD_EMPRESA WHEN 1006 THEN 'HYU/SBR' ELSE 'CHE' END    AS DESCRICAO_EMPRESA "+ CRLF 
    ElseIf( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) //90- HMB
        _cQuery += "        ,CASE ESTWIS.CD_EMPRESA WHEN 1008 THEN 'HYU' ELSE 'CHE' END    AS DESCRICAO_EMPRESA "+ CRLF 
    EndIf
    _cQuery += "        ,ESTWIS.ARMAZEM	AS ARMAZEM "+ CRLF 
    _cQuery += "        ,CASE ESTWIS.ARMAZEM WHEN 'BAR' THEN 'BARUERI' ELSE 'FRANCO DA ROCHA' END    AS DESCRICAO_ARMAZEM "+ CRLF 
    _cQuery += "        ,' '	AS ENDERECO "+ CRLF 
    _cQuery += "        ,(NVL(ESTWIS.QT_ESTOQUE,0) - ( NVL(ESTWIS.QT_RESERVA_SAIDA,0) + NVL(ESTWIS.QT_TRANSITO_SAIDA,0) ) ) AS QTDE_DISPONIVEL "+ CRLF 
    _cQuery += "        ,NVL(ESTWIS.QT_ESTOQUE,0) 			AS QTDE_ESTOQUE "+ CRLF 
    _cQuery += "        ,NVL(ESTWIS.QT_RESERVA_SAIDA,0) 	AS QTDE_RESERVA "+ CRLF 
    _cQuery += "        ,NVL(ESTWIS.QT_TRANSITO_SAIDA,0)	AS QTDE_TRANSITO "+ CRLF 
    _cQuery += "        ,' '                AS  D_E_L_E_T_ "+ CRLF
    _cQuery += "        ,ROW_NUMBER() OVER (ORDER BY ESTWIS.CD_EMPRESA, ESTWIS.ARMAZEM)     AS  R_E_C_N_O_ "+ CRLF    
	_cQuery += " FROM " + _cConectWis + " ESTWIS "+ CRLF
	_cQuery += " WHERE RTRIM(LTRIM(ESTWIS.CD_PRODUTO)) BETWEEN '"+AllTrim(_cCodProdDe)+"'  AND '"+AllTrim(_cCodProdAte)+"' "+ CRLF
    If ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa 02-Franco da Rocha
            _cQuery += " AND ESTWIS.CD_EMPRESA IN (1002,1006) "
    ElseIf ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) //90- HMB
            _cQuery += " AND ESTWIS.CD_EMPRESA = 1008 "
    EndIf
	_cQuery += " ORDER BY ESTWIS.CD_EMPRESA, ESTWIS.ARMAZEM "+ CRLF

    
	nStatus := TCSqlExec(_cQuery)
    If (nStatus < 0)
        MsgStop("TCSQLError() " + TCSQLError(), "Registros Cabeçalho")
        Break    
    Endif

    (_cAliasPesq)->(DbGoTop())
	If (_cAliasPesq)->(Eof())
		//MSGINFO( "Não existem dados para visualizar", "Atenção" )
		//Break
	Endif

    _aBrwInf := {}
    _aCpoInf := {}
    _aStru   := {}  //Estrutura do Banco

    Aadd( _aCpoInf, {"ZD1", "ZD1_FILIAL"   	,.F. })  //Filial
    Aadd( _aCpoInf, {"ZD1", "ZD1_DOC"      	,.T. })  //Nota
    Aadd( _aCpoInf, {"ZD1", "ZD1_SERIE"     ,.T. })  //Serie
    Aadd( _aCpoInf, {"ZD1", "ZD1_FORNEC"  	,.T. })  //Cod Fornecedor
    Aadd( _aCpoInf, {"ZD1", "ZD1_LOJA"  	,.T. })  //Loja Fornecedor
    Aadd( _aCpoInf, {"SA2", "A2_NREDUZ"  	,.T. })  //Nome Reduzido Fornecedor
    Aadd( _aCpoInf, {"ZD1", "ZD1_COD"  	    ,.T. })  //Cod Produto
    Aadd( _aCpoInf, {"ZD1", "ZD1_QUANT"  	,.T. })  //Quantidade ZD1
    Aadd( _aCpoInf, {"ZD1", "ZD1_QTCONF"  	,.T. })  //!tde Conferida
    Aadd( _aCpoInf, {"ZD1", "ZD1_SLDIT"  	,.T. })  //Saldo a conferir
    Aadd( _aCpoInf, {"WIS", "QTDARMAZE"     , "N","WIS Qtde Armazenada " , 12						, 0, "@E 9999,999,999",.T. })  //Empresa Wis
    Aadd( _aCpoInf, {"WIS", "CODEMPRE"      , "C","WIS Empresa"         , 15						, 0, "@!",.T. })  //Empresa Wis
    Aadd( _aCpoInf, {"WIS", "DESCEMPRE"     , "C","WIS Desc. Empresa"   , 30						, 0, "@!",.T. })  //Descrição Empresa Wis
    Aadd( _aCpoInf, {"WIS", "NOTA"          , "C","WIS Nota Fiscal"     , TamSX3("ZD1_DOC")[1]		, 0, "@!",.F. })  //Nota
    Aadd( _aCpoInf, {"WIS", "SERIE"         , "C","WIS Serie Fiscal"    , TamSX3("ZD1_SERIE")[1]	, 0, "@!",.F. })  //serie
    Aadd( _aCpoInf, {"WIS", "FORNEC"        , "C","WIS Fornecedor"      , TamSX3("ZD1_FORNEC")[1]	, 0, "@!",.F. })  //Cod Fornecedro
    Aadd( _aCpoInf, {"WIS", "LOJA"          , "C","WIS Loja"    		, TamSX3("ZD1_LOJA")[1]		, 0, "@!",.F. })  //Loja Fornecedor
    Aadd( _aCpoInf, {"WIS", "PRODUTO"       , "C","WIS Cod Prd"    		, TamSX3("ZD1_COD")[1]		, 0, "@!",.F. })  //cod Produto

    For _nPos := 1 To Len(_aCpoInf)
        If Len(_aCpoInf[_nPos]) == 3
            _aTamSx3 := TamSX3(_aCpoInf[_nPos,2])
            If _aCpoInf[_nPos,Len(_aCpoInf[_nPos])]  //Valida se a coluna irá para o Browse
                Aadd(_aBrwInf,{ RetTitle(_aCpoInf[_nPos,2]),;    //titulo
                                _aCpoInf[_nPos,2],;             //campo
                                _aTamSx3[03],;                  //tipo
                                _aTamSx3[01],;                  //tamanho
                                _aTamSx3[02],;                  //decimal
                             	PesqPict(_aCpoInf[_nPos,1],_aCpoInf[_nPos,2]);  //pict
                          })
            Endif
            Aadd(_aStru, {_aCpoInf[_nPos,02], _aTamSx3[03], _aTamSx3[01], _aTamSx3[02] })
        Else  
		    If _aCpoInf[_nPos,Len(_aCpoInf[_nPos])]  //Valida se a coluna irá para o Browse
		        Aadd(_aBrwInf,{ _aCpoInf[_nPos,4],;             //titulo
		                        _aCpoInf[_nPos,2],;             //campo
		                        _aCpoInf[_nPos,3],;             //tipo
		                        _aCpoInf[_nPos,5],;             //tamanho    
		                        _aCpoInf[_nPos,6],;             //decimal
		                        _aCpoInf[_nPos,7];              //pict
		                            })
        	Endif
	        Aadd(_aStru, { _aCpoInf[_nPos,02], _aCpoInf[_nPos,03], _aCpoInf[_nPos,05], _aCpoInf[_nPos,06] })
        Endif
	Next

    _oTableInf := FWTemporaryTable():New()
    _oTableInf:SetFields(_aStru)
    _oTableInf:AddIndex("INDEX1", {"CODEMPRE","ZD1_COD","ZD1_DOC", "ZD1_SERIE","ZD1_FORNEC"} )
    _oTableInf:Create()
    _cAliasInfo := _oTableInf:GetAlias()

    _cTableInf := _oTableInf:GetRealName()

	_cWhere     := ""

    _cQuery := " INSERT INTO "+_cTableInf+"                                                                                    "+(Chr(13)+Chr(10))
    _cQuery += " ("
    For _nPos := 01 To Len(_aStru)
        _cQuery += _aStru[_nPos,1]
        _cQuery += ", "
    NEXT _nPos
    _cQuery += " D_E_L_E_T_, R_E_C_N_O_ "  
    _cQuery += " )"+ CRLF

    _cQuery += " SELECT * FROM ( "										                                                                                                + CRLF
    _cQuery += " 				SELECT   ZD1.ZD1_FILIAL "				                                                                                                + CRLF
    _cQuery += " 						,ZD1.ZD1_DOC "					                                                                                                + CRLF
    _cQuery += " 						,ZD1.ZD1_SERIE "				                                                                                                + CRLF
    _cQuery += " 						,ZD1.ZD1_FORNEC "				                                                                                                + CRLF
    _cQuery += " 						,ZD1.ZD1_LOJA  "				                                                                                                + CRLF
    _cQuery += " 						,SA2.A2_NREDUZ "				                                                                                                + CRLF
    _cQuery += " 						,ZD1.ZD1_COD "					                                                                                                + CRLF
    _cQuery += " 						,ZD1.ZD1_QUANT "				                                                                                                + CRLF
    _cQuery += " 						,ZD1.ZD1_QTCONF "				                                                                                                + CRLF
    _cQuery += " 						,ZD1.ZD1_SLDIT  "				                                                                                                + CRLF
    _cQuery += " 						,NVL(WIS.QT_ARMAZENADA,0) 	AS QT_ARMAZENADA "                                                                                  + CRLF
    _cQuery += " 						,WIS.EMPRESA "					                                                                                                + CRLF
    _cQuery += " 						,WIS.DESCRICAO "				                                                                                                + CRLF
    _cQuery += " 						,WIS.NOTA "						                                                                                                + CRLF
    _cQuery += " 						,WIS.SERIE "					                                                                                                + CRLF
    _cQuery += " 						,WIS.FORNCECEDOR "				                                                                                                + CRLF
    _cQuery += " 						,WIS.LOJA "						                                                                                                + CRLF
    _cQuery += " 						,WIS.PRODUTO "					                                                                                                + CRLF
    _cQuery += " 						,' '                AS  D_E_L_E_T_ "                                                                                            + CRLF
    _cQuery += " 						, ZD1.R_E_C_N_O_    AS  R_E_C_N_O_ "                                                                                            + CRLF    
    _cQuery += " 				FROM  "+RetSqlName("ZD1")+" ZD1 "                                                                                                       + CRLF
    _cQuery += " 					FULL JOIN	(	SELECT 	 ARMWIS.CD_EMPRESA			AS EMPRESA "						                                            + CRLF
    If ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa 02-Franco da Rocha           
        _cQuery += " 											,CASE ARMWIS.CD_EMPRESA WHEN 1006 THEN 'HYU/SBR' ELSE 'CHE' END    AS DESCRICAO "                       + CRLF
    ElseIf( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) //90- HMB           
        _cQuery += " 											,CASE ARMWIS.CD_EMPRESA WHEN 1008 THEN 'HYU' ELSE 'CHE' END    AS DESCRICAO "                           + CRLF
    EndIf           
    _cQuery += " 											,LPAD(ARMWIS.NU_NOTA_FISCAL, 9, '0')	AS NOTA "							                                + CRLF
    _cQuery += " 											,ARMWIS.NU_SERIE_NF					AS SERIE "							                                    + CRLF
    _cQuery += " 											,SUBSTR(ARMWIS.CD_FORNECEDOR,2,6) 		AS FORNCECEDOR "					                                + CRLF
    _cQuery += " 											,SUBSTR(ARMWIS.CD_FORNECEDOR,8,2) 		AS LOJA "							                                + CRLF
    _cQuery += " 											,ARMWIS.CD_PRODUTO						AS PRODUTO "						                                + CRLF
    _cQuery += " 											,SUM(ARMWIS.QT_ARMAZENADA) 			AS QT_ARMAZENADA "					                                    + CRLF
	_cQuery += " 									FROM " + _cConectArmWis + " ARMWIS "                                                                                + CRLF
    _cQuery += " 									WHERE ARMWIS.CD_FORNECEDOR IS NOT NULL "											                                + CRLF
    If ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa 02-Franco da Rocha           
            _cQuery += "                            AND ARMWIS.CD_EMPRESA IN (1002,1006) "                                                                              + CRLF
    ElseIf ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) //90- HMB          
            _cQuery += "                            AND ARMWIS.CD_EMPRESA = 1008 "                                                                                      + CRLF
    EndIf
    _cQuery += " 									GROUP BY ARMWIS.CD_EMPRESA, ARMWIS.NU_NOTA_FISCAL, ARMWIS.NU_SERIE_NF, ARMWIS.CD_FORNECEDOR, ARMWIS.CD_PRODUTO "    + CRLF
    _cQuery += " 									ORDER BY ARMWIS.CD_EMPRESA, ARMWIS.NU_NOTA_FISCAL, ARMWIS.NU_SERIE_NF, ARMWIS.CD_FORNECEDOR, ARMWIS.CD_PRODUTO "    + CRLF
    _cQuery += " 				 			) WIS  "											                                                                        + CRLF
    _cQuery += " 				 	ON 	RTRIM(ZD1.ZD1_DOC) 		=  RTRIM(WIS.NOTA) "			                                                                        + CRLF
    _cQuery += " 					AND RTRIM(ZD1.ZD1_SERIE) 	= RTRIM(WIS.SERIE) "			                                                                        + CRLF
    _cQuery += " 					AND RTRIM(ZD1.ZD1_FORNEC) 	= RTRIM(WIS.FORNCECEDOR)	"	                                                                        + CRLF
    _cQuery += " 					AND RTRIM(ZD1.ZD1_LOJA) 	= RTRIM(WIS.LOJA) "				                                                                        + CRLF
    _cQuery += " 					AND RTRIM(ZD1.ZD1_COD) 		= RTRIM(WIS.PRODUTO) "			                                                                        + CRLF
    _cQuery += " 				LEFT JOIN "+RetSqlName("SA2")+" SA2 "                                                                                                   + CRLF 
    _cQuery += " 					ON ZD1.D_E_L_E_T_ 	= ' ' "                                                                                                         + CRLF
    _cQuery += " 					AND SA2.A2_FILIAL 	= '"+FwXFilial("SA2")+"' "			                                                                            + CRLF
    _cQuery += " 					AND SA2.A2_COD 		= ZD1.ZD1_FORNEC "                                                                                              + CRLF
    _cQuery += " 					AND SA2.A2_LOJA 	= ZD1.ZD1_LOJA "                                                                                                + CRLF
    _cQuery += " 				WHERE ZD1.D_E_L_E_T_ = ' ' "                                                                                                            + CRLF
    _cQuery += " 					AND ZD1.ZD1_FILIAL = '"+FwXFilial("ZD1")+"' "			                                                                            + CRLF
    _cQuery += " 					AND ZD1.ZD1_COD BETWEEN '"+_cCodProdDe+"'  AND '"+_cCodProdAte+"' "                                                                 + CRLF
    _cQuery += " 				) TMP "														                                                                            + CRLF
    _cQuery += " WHERE TMP.QT_ARMAZENADA < TMP.ZD1_QUANT "									                                                                            + CRLF

	nStatus := TCSqlExec(_cQuery)
    If (nStatus < 0)
        MsgStop("TCSQLError() " + TCSQLError(), "Registros Cabeçalho")
        Break    
    Endif

    (_cAliasInfo)->(DbGoTop())
	If (_cAliasInfo)->(Eof())
		//MSGINFO( "Não existem dados para visualizar", "Atenção" )
		//Break
	Endif


    ZPECF035BW(_cCodProd,  _cAliasPesq, _aBrwCab, _cAliasInfo, _aBrwInf)

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
Static Function ZPECF035BW(_cCodProd,  _cAliasPesq, _aBrwCab, _cAliasInfo, _aBrwInf)
Local _cTitulo      	:= "Locação WIS "
Local _aSizeAut     	:= MsAdvSize(.f.)
Local _oWis      		
Local _oTPanel01    		
Local _oTPanel02    
Local oBtn	 
Local _oBrw
Local _oBrwInf

Begin Sequence
	_oWis  				:= MSDIALOG() :New(_aSizeAut[7],0,_aSizeAut[6],_aSizeAut[5],"Locação WIS",,,,128,,,,,.T.)
	_oTPanel01    		:= TPanel():New(0,0,"",_oWis,NIL,.T.,.F.,NIL,NIL,100,(_oWis:nClientHeight/4)-10,.F.,.F.)
	_oTPanel01:Align 	:=  CONTROL_ALIGN_TOP
	_oTPanel02    		:= TPanel():New(0,0,"Informações Wis",_oWis,NIL,.T.,.F.,NIL,NIL,100,(_oWis:nClientHeight/4)-10,.F.,.F.)
	_oTPanel02:Align 	:= CONTROL_ALIGN_BOTTOM
	oBtn := TButton():New( 005, _aSizeAut[6],'Sair'            , _oWis,{|| _oWis:End()}     ,50, 011,,,.F.,.T.,.F.,,.F.,,,.F. )                                                                                            

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
    _oBrw:SetOwner(_oTPanel01)
    _oBrw:SetAlias(_cAliasPesq)	
	_ObrW:SetMenuDef('')
	_ObrW:SetFields(_aBrwCab)
    _ObrW:SetIgnoreARotina(.T.) // Indica que a mbrowse, ira ignorar a variavel private aRotina na construção das opções de menu.
    _ObrW:SetWalkThru(.F.)
    _ObrW:DisableConfig() // Desabilita a utilização do Browse
    _ObrW:SetAmbiente(.F.) //Habilita a utilização da funcionalidade Ambiente no Browse
    _ObrW:SetFixedBrowse(.T.)
	_ObrW:DisableDetails()
	_ObrW:SetCanSaveArea(.T.)	//abertura de mais de uma  browse
    //_ObrW:ForceQuitButton()     
	//Definimos o título que será exibido como método SetDescription
	_ObrW:SetDescription(_cTitulo)
    _ObrW:ForceQuitButton()     
	_ObrW:SetProfileID( 'SALDOS' )
  
   //Ativamos a classe
    _ObrW:Refresh(.T.)
	_ObrW:Activate()

    //preparo Informações gerais

    _oBrwInf := FWMBrowse():New()
    _oBrwInf:SetAlias(_cAliasInfo)
    _oBrwInf:SetOwner(_oTPanel02)
    _oBrwInf:SetDescription("Armazem WIS")
    _oBrwInf:SetMenuDef('')
    _oBrwInf:SetTemporary(.T.)
	_oBrwInf:SetFields(_aBrwInf)
    _oBrwInf:SetIgnoreARotina(.T.) // Indica que a mbrowse, ira ignorar a variavel private aRotina na construção das opções de menu.
    _oBrwInf:SetWalkThru(.F.)
    _oBrwInf:DisableConfig() // Desabilita a utilização do Browse
    _oBrwInf:SetAmbiente(.F.) //Habilita a utilização da funcionalidade Ambiente no Browse
    _oBrwInf:SetFixedBrowse(.T.)
    _oBrwInf:SetUseFilter(.F.)
	_oBrwInf:SetCanSaveArea(.T.)	//abertura de mais de uma  browse
	_oBrwInf:SetDescription("Armazem WIS")
    _oBrwInf:ForceQuitButton()     
	_oBrwInf:SetProfileID( 'ARMAZEM' )
    //_oBrwInf:OptionReport(.F.)

    _oBrwInf:DisableDetails()
    //_oBrwInf:DisableReport()
    _oBrwInf:Activate()
    _oBrwInf:Refresh(.T.)
    _oBrwInf:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

    _oWis:Activate()

End Sequence 
Return Nil



