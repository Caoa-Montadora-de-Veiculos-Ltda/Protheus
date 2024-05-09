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
Local _cCadastro    := OemToAnsi("Nota Fiscal de Entrada")   
Local _cTitle  	    := OemToAnsi("NF Caoa >> HMB")   
Local _aPar    	    := {}
Local _aRet    	    := {}
Local _nRet			:= 0

Local _cCodCli		:= Space(TamSx3("A1_COD")[1])
Local _cLoja		:= Space(TamSx3("A1_LOJA")[1])
Local _cDocumDe    	:= Space(TamSx3("D1_DOC")[1])
Local _cDocumAte   	:= Space(TamSx3("D1_DOC")[1])
Local _cSerieori   	:= Space(TamSx3("D1_SERIE")[1])
Local _cTES     	:= Space(TamSx3("D1_TES")[1])
Local _cArmazem		:= Space(TamSx3("D1_LOCAL")[1]) 
Local _cCCusto		:= Space(TamSx3("D1_CC")[1]) 
Local _cCCond		:= Space(TamSx3("F2_COND")[1])  
Local _cCodFor		:= Space(TamSx3("F2_CLIENTE")[1])  
Local _cLojaFor		:= Space(TamSx3("F2_LOJA")[1])  

Local _oSay

Private lMsErroAuto := .F.

Begin Sequence

	aAdd(_aPar,{1,OemToAnsi("Cliente Origem  : ") 	,_cCodCli	, "@!"	,".T."	,""   , ".T.", 100,.T.}) 
	aAdd(_aPar,{1,OemToAnsi("Loja Origem     : ")	,_cLoja 	, "@!"	,".T."	,""	  , ".T.", 100,.T.}) 
	aAdd(_aPar,{1,OemToAnsi("Nota Origem de  : ") 	,_cDocumDe	, "@!"	,".T."	,""   , ".T.", 100,.F.}) 
	aAdd(_aPar,{1,OemToAnsi("Nota Origem ate : ") 	,_cDocumAte	, "@!"	,".T."	,""   , ".T.", 100,.T.}) 
    aAdd(_aPar,{1,OemToAnsi("Série Origem	 : ") 	,_cSerieori	, "@!"	,".T."	,""   , ".T.", 100,.T.}) 
    aAdd(_aPar,{1,OemToAnsi("TES Entrada     : ") 	,_cTes   	, "@!"	,".T."	,"SF4", ".T.", 100,.T.}) 
    aAdd(_aPar,{1,OemToAnsi("CCusto Entrada  : ") 	,_cCCusto	, "@!"	,".T."	,"CTT", ".T.", 100,.T.}) 
    aAdd(_aPar,{1,OemToAnsi("Cond.Pagto Entrada: ") ,_cCCond	, "@!"	,".T."	,"SE4", ".T.", 100,.T.}) 
    aAdd(_aPar,{1,OemToAnsi("Local Entrada   : ")   ,_cArmazem	, "@!"	,".T."	,"NNR", ".T.", 100,.T.})
	aAdd(_aPar,{1,OemToAnsi("Fornecedor Entrada : "),_cCodFor	, "@!"	,".T."	,"SA2", ".T.", 100,.T.}) 
	aAdd(_aPar,{1,OemToAnsi("Loja Entrada    : ")	,_cLojaFor 	, "@!"	,".T."	,"SA2", ".T.", 100,.T.}) 

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

	FwMsgRun(,{ |_oSay| ZGENFTEPR(_aRet, @_oSay ) }, "Gerando Notas Fiscais de Entada", "Aguarde...")  //Integração / Aguarde
	
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
Local _cTES     	:= _aRet[06]
Local _cCCusto     	:= _aRet[07]
Local _cCPgto     	:= _aRet[08]
//Local _cLocal     	:= _aRet[09]
Local _cCodFor     	:= _aRet[10]
Local _cLojaFor    	:= _aRet[11]
Local _cSerie		:= ""
Local _cCliente		:= ""
Local _cLojaCli		:= ""

Local _cNumNFE   	:= CriaVar("F1_DOC")
Local _aCabNFE		:= {}
Local _aItemNFE		:= {}
Local _aItens       := {}
Local _cDoc         := Space(TamSx3("D1_DOC")[1])
Local _nLidos       := 0

Local _cTipoCli
Local _nCont
Local _cUpdate

Local cUpdSB1P01	:= ""
Local cUpdSB1P02	:= ""

DbSelectArea("SA1")
DbSelectArea("SA2")

Begin Sequence

	SA2->( DBSetOrder(01) )
	if !SA2->( MsSeek(FwXFilial("SA2") + _cCodFor + _cLojaFor ))
		Help( " ", 1,"ZGENFTEPR", ,'Fornecedor '+_cCodFor+'-'+_cLojaFor+' não cadastrado não será gerado o Doc.Entrada. ',1)  
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
				,SF2.F2_CHVNFE
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
		FROM abdhdu_prot.SF2020 SF2 
		INNER JOIN abdhdu_prot.SD2020 SD2
		ON SD2.D2_FILIAL   = '2020012001'	
		AND SD2.D2_DOC     = SF2.F2_DOC 
		AND SD2.D2_SERIE   = SF2.F2_SERIE
		AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
		AND SD2.D2_LOJA    = SF2.F2_LOJA
		AND SD2.%notDel%
		WHERE 
		SF2.F2_FILIAL  = '2020012001'
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

	If !MsgYesNo( "Confirma Entrada das Notas ?" )
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
		_nCont++
        _cDoc    	:= (_cAliasPesq)->F2_DOC
		_cNumNFE 	:= (_cAliasPesq)->F2_DOC
		_cSerie		:= (_cAliasPesq)->F2_SERIE
		_cCliente	:= (_cAliasPesq)->F2_CLIENTE
		_cLojaCli	:= (_cAliasPesq)->F2_LOJA
        _nRecSF2 	:= (_cAliasPesq)->NREGSF2	

		Aadd(_aCabNFE,{"F1_FILIAL"  , xFilial('SF1')           	,  nil })
		aadd(_aCabNFE,{"F1_TIPO"   	, "N"                      	,  nil })    
		aadd(_aCabNFE,{"F1_FORMUL" 	, "N"                      	,  nil })
		aadd(_aCabNFE,{"F1_DOC"    	, _cNumNFE                 	,  nil })    
		aadd(_aCabNFE,{"F1_SERIE"  	, (_cAliasPesq)->F2_SERIE  	,  nil })    
		aadd(_aCabNFE,{"F1_EMISSAO"	, dDataBase                	,  nil })
		aadd(_aCabNFE,{"F1_FORNECE"	, SA2->A2_COD              	,  nil })    
		aadd(_aCabNFE,{"F1_LOJA"   	, SA2->A2_LOJA             	,  nil })     
		aadd(_aCabNFE,{"F1_ESPECIE"	, "SPED"                   	,  nil })    
		aadd(_aCabNFE,{"F1_COND"	, _cCPgto                  	,  nil })
		aadd(_aCabNFE,{"F1_EST"		, SA2->A2_EST              	,  nil })    
		aadd(_aCabNFE,{"F1_DESCONT" , 0				           	,  nil })
		aadd(_aCabNFE,{"F1_DESPESA" , 0				           	,  nil })
		aadd(_aCabNFE,{"F1_SEGURO"  , (_cAliasPesq)->F2_SEGURO 	,  nil })    
		aadd(_aCabNFE,{"F1_FRETE"   , (_cAliasPesq)->F2_FRETE  	,  nil })    
		aadd(_aCabNFE,{"F1_CHVNFE"  , (_cAliasPesq)->F2_CHVNFE 	,  nil })    
		aadd(_aCabNFE,{"F1_IMP"  	, "S" 						,  nil })
		aadd(_aCabNFE,{"F1_XINTEG"	, "X"                      	,  nil })	

		//Faz update na SB1 para trocar o local de recebimento.
		cUpdSB1P01 := ""
		cUpdSB1P01 := "UPDATE " + RetSQLName('SB1') + " SB1 SET B1_LOCREC = '11' "
		cUpdSB1P01 += "WHERE SB1.B1_FILIAL = '" + FWxFilial("SB1") + "' "
		cUpdSB1P01 += "AND SB1.B1_COD IN ( SELECT D2_COD FROM ABDHDU_PROT.SD2020 SD2 "
		cUpdSB1P01 += "						WHERE SD2.D2_FILIAL = '2020012001' "
		cUpdSB1P01 += "						AND SD2.D2_DOC = '" + (_cAliasPesq)->F2_DOC + "' "
		cUpdSB1P01 += "						AND SD2.D2_SERIE = '" + (_cAliasPesq)->F2_SERIE + "'  "
		cUpdSB1P01 += "						AND SD2.D2_CLIENTE = '" + (_cAliasPesq)->F2_CLIENTE + "'  "
		cUpdSB1P01 += "						AND SD2.D2_LOJA = '" + (_cAliasPesq)->F2_LOJA + "'  "
		cUpdSB1P01 += "						AND SD2.D_E_L_E_T_ = ' ') "
		cUpdSB1P01 += "AND SB1.D_E_L_E_T_ = ' ' "

		If TcSqlExec(cUpdSB1P01) < 0
			Conout("Falha na execução do UPD de NF integrada, erro :" + TcSqlError() )
		EndIf		

		//Carregar Itens
		While (_cAliasPesq)->(!Eof()) .AND. (_cAliasPesq)->F2_CLIENTE = _cCodCli .AND. (_cAliasPesq)->F2_LOJA = _cLoja;
		    .AND. (_cAliasPesq)->D2_DOC = _cDoc .AND. (_cAliasPesq)->D2_SERIE = _cSerieori

			_aItemNFE := {}
			_nLidos ++
			_oSay:SetText("Processando "+StrZero(_nLidos,7)+" de "+StrZero(_nRegistros,7))
			ProcessMessage() 

			Aadd(_aItemNFE, {"D1_FILIAL"    , xFilial('SD1')            ,Nil})
			Aadd(_aItemNFE, {"D1_TIPO"      , "N"    	                ,NIL})
			Aadd(_aItemNFE,	{"D1_FORMUL"	, 'N'                   	,NIL})
			Aadd(_aItemNFE,	{"D1_COD"		, (_cAliasPesq)->D2_COD   	,NIL})
			Aadd(_aItemNFE,	{"D1_UM"    	, (_cAliasPesq)->D2_UM    	,NIL})
			Aadd(_aItemNFE,	{"D1_CC"        , _cCCusto   				,Nil})    //_cCusto
			Aadd(_aItemNFE,	{"D1_LOCAL"		, "11"	        	        ,NIL})
			Aadd(_aItemNFE,	{"D1_QUANT"		, (_cAliasPesq)->D2_QUANT	,NIL})
			Aadd(_aItemNFE,	{"D1_VUNIT"		, (_cAliasPesq)->D2_PRCVEN	,NIL})
			Aadd(_aItemNFE,	{"D1_TOTAL"		, (_cAliasPesq)->D2_TOTAL	,NIL})
			Aadd(_aItemNFE,	{"D1_TES"	   	, _cTes                  	,NIL})
			Aadd(_aItemNFE,	{"D1_DOC"       , _cNumNFE	                ,NIL})	
			Aadd(_aItemNFE,	{"D1_SERIE"     , (_cAliasPesq)->F2_SERIE   ,NIL})	
			Aadd(_aItemNFE,	{"D1_FORNECE"	, SA2->A2_COD               ,NIL})    
			Aadd(_aItemNFE,	{"D1_LOJA"   	, SA2->A2_LOJA              ,NIL})      
	        Aadd(_aItemNFE, {"D1_EMISSAO"   , dDataBase    		        ,Nil})
            Aadd(_aItemNFE, {"D1_DTDIGIT"   , dDataBase					,Nil})

			Aadd(_aItens,_aItemNFE)
			
			(_cAliasPesq)->(Dbskip())

			_nPasso:=1
		
		End

		MSExecAuto( {|a,b,c|MATA103(a,b,c)}, _aCabNFE, _aItens, 3,/*lWhenGet*/,/*xAutoImp*/,/*xAutoAFN*/,/*_aParamAuto*/,/*xRateioCC*/,/*lGravaAuto*/,/*xCodRSef*/,/*xCodRet*/,/*xAposEsp*/,/*xNatRend*/,/*xAutoPFS*/,/*xCompDKD*/,/*lGrvGF*/,/*xAutoCSD*/)

		If lMsErroAuto
			DisarmTransaction()
			Mostraerro()
			_lRet := .F.
			Break	
		Else

			_cUpdate := " UPDATE ABDHDU_PROT.SF2020 "                        
			_cUpdate += " SET F2_XINT90 = 'S' "                    
			_cUpdate += " WHERE d_e_l_e_t_ = ' '"                      
			_cUpdate += "    AND r_e_c_n_o_ = " + AllTrim( Str( _nRecSF2 ))+" "

			If TcSqlExec(_cUpdate) < 0
				Conout("Falha na execução do UPD de NF integrada, erro :" + TcSqlError() )
			EndIf

			//Volta o local de recebimento para 90
			cUpdSB1P02 := ""
			cUpdSB1P02 := "UPDATE " + RetSQLName('SB1') + " SB1 SET B1_LOCREC = '90' "
			cUpdSB1P02 += "WHERE SB1.B1_FILIAL = '" + FWxFilial("SB1") + "' "
			cUpdSB1P02 += "AND SB1.B1_COD IN ( SELECT D2_COD FROM ABDHDU_PROT.SD2020 SD2 "
			cUpdSB1P02 += "						WHERE SD2.D2_FILIAL = '2020012001' "
			cUpdSB1P02 += "						AND SD2.D2_DOC = '" + _cDoc + "' "
			cUpdSB1P02 += "						AND SD2.D2_SERIE = '" + _cSerie + "' "
			cUpdSB1P02 += "						AND SD2.D2_CLIENTE = '" + _cCliente + "'  "
			cUpdSB1P02 += "						AND SD2.D2_LOJA = '" + _cLojaCli + "'  "
			cUpdSB1P02 += "						AND SD2.D_E_L_E_T_ = ' ') "
			cUpdSB1P02 += "AND SB1.D_E_L_E_T_ = ' ' "

			If TcSqlExec(cUpdSB1P02) < 0
				Conout("Falha na execução do UPD de NF integrada, erro :" + TcSqlError() )
			EndIf
	

	    EndIf
		
		IF _nPasso = 0
		    (_cAliasPesq)->(Dbskip())
        ENDIF
	EndDo

	MSGInfo(" Doc.Entrada incluido com sucesso. ","ATENCAO!")

End Begin

If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif 

Return _lRet
