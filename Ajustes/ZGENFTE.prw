#Include "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "TOTVS.ch"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWBROWSE.CH"
#Include "FWMVCDEF.CH"
#Include "RwMake.ch"
#Include "TbiConn.ch"

/*/{Protheus.doc} ZGENFTE
Geração de Doc.Entrada na Empresa Hyunday 
@author     A.Carlos 
@since      11/04/2024
@project    GAP160  OneGate  Hyundai  Entrada
@version    1.0
/*/
User Function ZGENFTE()
Local _aSays	    := {}
Local _aButtons	    := {}
Local _cCadastro    := OemToAnsi("Recebimento de Produto na empresa (HD)")   
Local _cTitle  	    := OemToAnsi("Recebimento de Produto na empresa (HD)")   
Local _aPar    	    := {}
Local _aRet    	    := {}
Local _nRet			:= 0

Local _cCodCli		:= Space(TamSx3("A1_COD")[1])
Local _cLoja		:= Space(TamSx3("A1_LOJA")[1])
Local _cDocumDe    	:= Space(TamSx3("D1_DOC")[1])
Local _cDocumAte   	:= Space(TamSx3("D1_DOC")[1])
Local _cSerieori   	:= Space(TamSx3("D1_SERIE")[1])
Local _cTES     	:= Space(TamSx3("D1_TES")[1])

Local _cChave		:= AllTrim(FWCodEmp())+"ZGENFTSE"
Local _lRet			:= .T.
Local _lSerieObr	:= If(FWCodEmp() == '2020', .F., .T.)  //indicar para obrigatório quando embpresa for diferente de 020 na serie  

Local _oSay
Local _nPos

Private _cFilial  	:= cFilant

Begin Sequence
	//_lRet := U_ZGENUSER( RetCodUsr() ,"ZGENFTSE" ,.T.)	
	If !_lRet
		Break
	EndIf
	/*
	IF FWCodEmp() <> '2020' //Verificar Empresa Peças, somente rodar em Peças
		Help( , ,OemToAnsi("Atenção"),,OemToAnsi("Esta rotina não é valida para esta empresa"),4,1)   
	    Break
	ENDIF
	*/

	aAdd(_aPar,{1,OemToAnsi("Cliente  : ") 	,_cCodCli	, "@!"	,".T."	,"SA1", ".T.", 100,.T.}) 
	aAdd(_aPar,{1,OemToAnsi("Loja  	  : ")	,_cLoja 	, "@!"	,".T."	,""	  , ".T.", 100,.T.}) 
	aAdd(_aPar,{1,OemToAnsi("Nota  de : ") 	,_cDocumDe	, "@!"	,".T."	,"SF2", ".T.", 100,.F.}) 
	aAdd(_aPar,{1,OemToAnsi("Nota ate : ") 	,_cDocumAte	, "@!"	,".T."	,"SF2", ".T.", 100,.T.}) 
    aAdd(_aPar,{1,OemToAnsi("Série 	  : ") 	,_cSerieori	, "@!"	,".T."	,""   , ".T.", 100,.T.}) 

	// Monta Tela principal
	aAdd(_aSays,OemToAnsi("Este Programa tem  como  Objetivo realizar a integração de Produto")) 
	aAdd(_aSays,OemToAnsi("da empresa CAOA PEÇAS para um determinado Cliente (HD).")) 
	aAdd(_aSays,OemToAnsi("Será gerado nota fiscal de Entrada com os respectivos Produtos")) 
	aAdd(_aSays,OemToAnsi("por parâmetro, e aprovada no SEFAZ ! ")) 

	aAdd(_aButtons, { 1,.T.,{|o| FechaBatch(),_nRet:=1											}})
	aAdd(_aButtons, { 2,.T.,{|o| FechaBatch()													}})
	aAdd(_aButtons, { 5,.T.,{|o| ParamBox(_aPar,_cTitle,@_aRet,,,.T.,,,,"ZGENFTE",.T.,.T.) 		}})

	FormBatch( _cCadastro, _aSays, _aButtons )
	If _nRet <> 1
		Break
	Endif
	If Len(_aRet) == 0
		Help( , ,OemToAnsi("Atenção"),,OemToAnsi("Necessário informar os parâmetros"),4,1)   
		Break 
	Endif

	//Garantir que o processamento seja unico
	//_cChave		:= AllTrim(FWCodEmp())+"ZGENFTE"+_cGrupo
	If !LockByName(_cChave,.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 3000 ) // Para o processamento por 3 segundos
			If LockByName(_cChave,.T.,.T.)
				_lRet := .T.
			EndIf
		Next		
		If !_lRet
			MSGINFO("Já existe um processamento em execução rotina ZGENFTE, aguarde o término!", "[ZGENFTE] - Atenção" )
			Break
		EndIf
	EndIf

	FwMsgRun(,{ |_oSay| ZGENFTEPR(_aRet, @_oSay ) }, "Integração de Produtos para Cliente 90", "Aguarde...")  //Integração / Aguarde
	//Libera para utilização de outros usuarios
	UnLockByName(_cChave,.T.,.T.)
End Sequence
Return Nil


Static Function ZGENFTEPR(_aRet, _oSay)
Local _cAliasPesq   := GetNextAlias()      
Local _lRet			:= .T.
Local _cCodCli		:= _aRet[01]
Local _cLoja		:= _aRet[02]
Local _cDocumDe 	:= _aRet[03]
Local _cDocumAte	:= _aRet[04]
Local _cSerieori   	:= _aRet[05]
//Local _cTES     	:= _aRet[06]

Local _cNumNFE   	:= CriaVar("F1_DOC")
Local _aCabNFE		:= {}
Local _aItemNFE		:= {}
Local _aItens       := {}
Local _cDoc         := Space(TamSx3("D1_DOC")[1])
Local _cSerie       := Space(TamSx3("D1_SERIE")[1])
Local _nLidos       := 0
Local _nI           := 0
Local _cTesClas		:= Alltrim(SuperGetMV("ES_TESNE90",,"001")) //TES a ser utilizada para a geração do Doc.Entrada
Local _cTipo 		:= Alltrim(SuperGetMV("ES_CTPNE90",,"N")) //Tipo da Nota Fiscal Entrada 
Local _cArmazem		:= Alltrim(SuperGetMV("ES_ARMNE90",,'90')) //verificar se sera paremetrizado 

Local _cTipoCli
Local _nPos
Local _nRegNFOri

DbSelectArea("SA1")
DbSelectArea("SA2")

Begin Sequence

	SA1->( DBSetOrder(01) )
	if !SA1->( MsSeek(FwXFilial("SA1") + _cCodCli+_cLoja ))
		Help( " ", 1,"ZGENFTEPR", ,'Cliente '+_cCodCli+'-'+_cLoja+' não cadastrado não será gerado o Doc.Entrada. ',1)  
		_lRet := .F.
		Break
	Endif

	SA2->( DBSetOrder(03) )
	if !SA2->( MsSeek(FwXFilial("SA2") + SA1->A1_CGC ))
		Help( " ", 1,"ZGENFTEPR", ,'Fornecedor '+_cCodCli+'-'+_cLoja+' não cadastrado não será gerado o Doc.Entrada. ',1)  
		_lRet := .F.
		Break
	Endif
	_cTipoCli := SA2->A2_TIPO

	BeginSql Alias _cAliasPesq
		SELECT SF2.F2_CLIENTE
				,SF2.F2_LOJA
				,SF2.F2_DOC
				,SF2.F2_SERIE
				,SF2.F2_ESPECIE
				,SF2.F2_SEGURO 
				,SF2.F2_FRETE
				,SD2.D2_DOC
				,SD2.D2_SERIE
				,SD2.D2_ITEM
				,SD2.D2_COD
				,SD2.D2_UM
				,SD2.D2_QUANT
				,SD2.D2_PRCVEN
				,SD2.D2_TOTAL
				,SF2.R_E_C_N_O_ NREGSF2
				,SD2.R_E_C_N_O_ NREGSD2
		FROM %table:SF2% SF2 
		INNER JOIN %table:SD2% SD2
		ON SD2.D2_FILIAL   = %xFilial:SD2%	
		AND SD2.D2_DOC     = SF2.F2_DOC 
		AND SD2.D2_SERIE   = SF2.F2_SERIE
		AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
		AND SD2.D2_LOJA    = SF2.F2_LOJA
		AND SD2.%notDel%
		WHERE 
		SF2.F2_FILIAL  = %xFilial:SF2%
		AND SF2.F2_DOC BETWEEN %Exp:_cDocumDe% AND %Exp:_cDocumAte%
		AND SF2.F2_SERIE   = %Exp:_cSerieori%
		AND SF2.F2_CLIENTE = %Exp:_cCodCli%
		AND SF2.F2_LOJA    = %Exp:_cLoja%
		AND SF2.F2_FIMP    = 'S'
		AND SF2.F2_XINT90 <> 'S'
		AND	SF2.%notDel%
		ORDER BY SF2.F2_CLIENTE,SF2.F2_LOJA,SF2.F2_DOC,SF2.F2_SERIE,SD2.D2_ITEM
	EndSql

	If (_cAliasPesq)->(Eof())
		Help( , ,OemToAnsi("Atenção"),,OemToAnsi("Não existem notas a integrarem para o Fornecdor."),4,1)   
		Break 
	EndIf	

	If !MsgYesNo( "Confirma gerar nota de Entrada para o Fornecdor "+AllTrim(SA2->A2_NREDUZ)+" ? " )
		_lRet := .F.
		Break 
	Endif	
	
	(_cAliasPesq)->( DbGotop()) 
	 Count To _nRegistros 	
	(_cAliasPesq)->(DbGotop()) 
	_nPasso:=0
	
	While (_cAliasPesq)->(!Eof()) .AND. (_cAliasPesq)->F2_CLIENTE = _cCodCli .AND. (_cAliasPesq)->F2_LOJA = _cLoja;
		.AND. (_cAliasPesq)->D2_DOC >= _cDocumDe .AND. (_cAliasPesq)->D2_DOC <= _cDocumAte .AND. (_cAliasPesq)->D2_SERIE = _cSerieori

		_oSay:SetText("Selecionando dados")
		ProcessMessage() 

		_aCabNFE	:= {}	
		_aItemNFE	:= {}
		_aItens     := {}
        _cDoc    := (_cAliasPesq)->F2_DOC
		_cNumNFE := GetSxeNum("SF1","F1_DOC") 
		ConfirmSX8()
       // _nRegNFOri   := (_cAliasPesq)->NREGSF2

		/*SF1->(dbSetOrder(1)) 
		While SF1->(dbSeek(xFilial("SF1")+_cNumNFE)) 
			ConfirmSX8() 
			_cNumNFE := GetSxeNum("SF1","F1_DOC") 
		EndDo*/

		aadd(_aCabNFE,{"F1_TIPO"   	, _cTipo                   ,  nil })    
		aadd(_aCabNFE,{"F1_FORMUL" 	, "N"                      ,  nil })
		aadd(_aCabNFE,{"F1_DOC"    	, _cNumNFE                 ,  nil })    
		aadd(_aCabNFE,{"F1_SERIE"  	, (_cAliasPesq)->F2_SERIE  ,  nil })    
		aadd(_aCabNFE,{"F1_EMISSAO"	, dDataBase                ,  nil })
		aadd(_aCabNFE,{"F1_FORNECE"	, SA2->A2_COD              ,  nil })    
		aadd(_aCabNFE,{"F1_LOJA"   	, SA2->A2_LOJA             ,  nil })     
		aadd(_aCabNFE,{"F1_ESPECIE"	, (_cAliasPesq)->F2_ESPECIE,  nil })    
		aadd(_aCabNFE,{"F1_COND"	, '003'                    ,  nil })
		aadd(_aCabNFE,{"F1_EST"		, SA2->A2_EST              ,  nil })    
		aadd(_aCabNFE,{"F1_DESCONT" , 0				           ,  nil })
		aadd(_aCabNFE,{"F1_DESPESA" , 0				           ,  nil })
		aadd(_aCabNFE,{"F1_SEGURO"  , (_cAliasPesq)->F2_SEGURO ,  nil })    
		aadd(_aCabNFE,{"F1_FRETE"   , (_cAliasPesq)->F2_FRETE  ,  nil })    
		//aadd(_aCabNFE,{"F1_VALICM"	, (_cAliasPesq)->F2_VALICM,  nil })
		//aadd(_aCabNFE,{"F1_VALIPI"	, (_cAliasPesq)->F2_VALIPI,  nil })
		//aadd(_aCabNFE,{"F1_BRICMS"	, (_cAliasPesq)->F2_BRICMS,  nil })
		//aadd(_aCabNFE,{"F1_ICMSRET"	, (_cAliasPesq)->F2_ICMSRET, nil })
		//aadd(_aCabNFE,{"F1_RECBMTO"	, dDataBase, nil })
		aadd(_aCabNFE,{"F1_XINTEG"	, 'X'                      , nil })		

		//Carregar Itens
		While (_cAliasPesq)->(!Eof()) .AND. (_cAliasPesq)->F2_CLIENTE = _cCodCli .AND. (_cAliasPesq)->F2_LOJA = _cLoja;
		    .AND. (_cAliasPesq)->D2_DOC = _cDoc .AND. (_cAliasPesq)->D2_SERIE = _cSerieori

			_aItemNFE := {}
			_nLidos ++
			_oSay:SetText("Lendo Registro "+StrZero(_nLidos,7)+" de "+StrZero(_nRegistros,7))
			ProcessMessage() 

			Aadd(_aItemNFE, {"D1_FILIAL"    , xFilial("SF1")            ,Nil})
			Aadd(_aItemNFE, {"D1_TIPO"      , "N"    	                ,NIL})
			Aadd(_aItemNFE, {"D1_PEDIDO"    , "000090"	                ,NIL})
			Aadd(_aItemNFE,	{"D1_FORMUL"	, 'S'                   	,NIL})
			Aadd(_aItemNFE,	{"D1_COD"		, (_cAliasPesq)->D2_COD   	,NIL})
			Aadd(_aItemNFE,	{"D1_ITEM"		, (_cAliasPesq)->D2_ITEM   	,NIL})   
			Aadd(_aItemNFE,	{"D1_UM"    	, (_cAliasPesq)->D2_UM    	,NIL})
			Aadd(_aItemNFE,	{"D1_CC"        , "53020509MA "				,Nil})    //_cCusto
			Aadd(_aItemNFE,	{"D1_LOCAL"		, _cArmazem      	        ,NIL})
			Aadd(_aItemNFE,	{"D1_QUANT"		, (_cAliasPesq)->D2_QUANT	,NIL})
			Aadd(_aItemNFE,	{"D1_VUNIT"		, (_cAliasPesq)->D2_PRCVEN	,NIL})
			Aadd(_aItemNFE,	{"D1_TOTAL"		, (_cAliasPesq)->D2_TOTAL	,NIL})
			Aadd(_aItemNFE,	{"D1_TES"	   	, _cTesClas             	,NIL})
			Aadd(_aItemNFE,	{"D1_DOC"       , _cNumNFE	                ,NIL})	
			Aadd(_aItemNFE,	{"D1_SERIE"     , (_cAliasPesq)->F2_SERIE   ,NIL})	
			Aadd(_aItemNFE,	{"D1_FORNECE"	, SA2->A2_COD               ,NIL})    
			Aadd(_aItemNFE,	{"D1_LOJA"   	, SA2->A2_LOJA              ,NIL})      
            Aadd(_aItemNFE, {"D1_EMISSAO"   , Date()    		        ,Nil})
            Aadd(_aItemNFE, {"D1_DTDIGIT"   , dDataBase					,Nil})

			Aadd(_aItens,_aItemNFE)
			
			(_cAliasPesq)->(Dbskip())

			_nPasso:=1
		
		End

		//Gravar os dados
	    GrvDEntr(_oSay, _aCabNFE, _aItens, _nLidos)

		//(_cAliasPesq)->(DbGoto(_nRegNFOri))
		
		IF _nPasso = 0
		    (_cAliasPesq)->(Dbskip())
        ENDIF
	EndDo



	//lMsErroAuto := .F.

	//_oSay:SetText("Gravando os " + StrZero(_nRegistros,7) + " Registros. ")
	//ProcessMessage() 

//MSExecAuto( {|a,b,c|MATA103(a,b,c)}, _aCabNFE, _aItens, 3,/*lWhenGet*/,/*xAutoImp*/,/*xAutoAFN*/,/*_aParamAuto*/,/*xRateioCC*/,;
//*lGravaAuto*/,/*xCodRSef*/,/*xCodRet*/,/*xAposEsp*/,/*xNatRend*/,/*xAutoPFS*/,/*xCompDKD*/,/*lGrvGF*/,/*xAutoCSD*/)

	//If !lMsErroAuto
	//    MSGInfo(" Incluido Doc.Entrada com sucesso. ","ATENCAO!")
	//Else
	//	DisarmTransaction()
    //	Mostraerro()
	//	_lRet := .F.
	//	Break	
	//EndIf

End Begin

If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 

Return _lRet


Static Function GrvDEntr(_oSay, _aCabNFE, _aItens, _nLidos)
Local lMsErroAuto := .F.

	_oSay:SetText("Gravando os " + StrZero(_nLidos,7) + " Registros. ")
	ProcessMessage() 

MSExecAuto( {|a,b,c|MATA103(a,b,c)}, _aCabNFE, _aItens, 3,/*lWhenGet*/,/*xAutoImp*/,/*xAutoAFN*/,/*_aParamAuto*/,/*xRateioCC*/,;
/*lGravaAuto*/,/*xCodRSef*/,/*xCodRet*/,/*xAposEsp*/,/*xNatRend*/,/*xAutoPFS*/,/*xCompDKD*/,/*lGrvGF*/,/*xAutoCSD*/)

	If !lMsErroAuto
	    MSGInfo(" Doc.Entrada incluido com sucesso. ","ATENCAO!")
	Else
		DisarmTransaction()
    	Mostraerro()
		_lRet := .F.
		Break	
	EndIf

Return()
