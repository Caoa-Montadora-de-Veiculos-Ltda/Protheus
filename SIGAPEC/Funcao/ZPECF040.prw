#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "totvs.ch"

Static _oBrw := Nil

/*/{Protheus.doc} ZPECF040
Calculo Curva ABC 
@param  	
@author 	DAC - Denilso
@version  	P12.1.25
@since  	15/07/2023
@return  	NIL
@obs
@project    GAP014 | Cálculo da Curva ABC
			PEC057 - Cálculo da Curva ABC
@history    
/*/
User Function ZPECF040
Local _oSay

//Private aRotina := {}

Begin Sequence
	DbSelectarea("SZO")
	SZO->(DbSetOrder(1))
    _oBrw := FWMBrowse():New()
    _oBrw:SetAlias("SZO")
	//_oBrw:SetMenuDef('ZPECF040')
    //_oBrw:SetIgnoreARotina(.T.) // Indica que a mbrowse, ira ignorar a variavel private aRotina na construção das opções de menu.
    _oBrw:SetDescription("Curva ABC CAOA")
	_oBrw:DisableDetails()
	_oBrw:SetAmbiente(.F.)
	_oBrw:SetWalkThru(.F.)
    _oBrw:ForceQuitButton()    
 
	_oBrw:AddButton("Processar"  	, { || FwMsgRun(,{ | _oSay | ZPECF040PR_ProcessaCurvaABC( @_oSay) }, "Processando Curva ABC", "Aguarde...")  },,,, .F., 2 )  
	_oBrw:AddButton("Gerar Excel"  	, { || FwMsgRun(,{ | _oSay | ZPECF40PL_PlanilhaCurvaABC( @_oSay) }, "Gerar Excel Curva ABC", "Aguarde...")  },,,, .F., 2 )  
	_oBrw:AddButton("Visualizar"  	, { || FwMsgRun(,{ | _oSay | ZPECF40VI_RegistroCurvaABC( ) }, "Gerar Excel Curva ABC", "Aguarde...")  },,,, .F., 2 )  

	_oBrw:Refresh(.T.)

    _oBrw:Activate()
	//_oTimer := TTimer():New(30000, {|| _oBrw:ForceRefresh() }, _oBrw )
	//_oTimer:Activate()

End Sequence
Return Nil 


//Visualizar Curva ABC
Static Function ZPECF40VI_RegistroCurvaABC()
Private  cCadastro := "Dados referente Curva ABC"
DbSelectArea("SZO")
AxVisual("SZO",SZO->( RecNo() ),2)
Return Nil


/*/{Protheus.doc} ZPECF040PR_ProcessaCurvaABC
Função para processar Curva
@author 	DAC
@since 		15/07/2023
@version 	undefined
@param 		
@type 		Static function
@project    GAP014 | Cálculo da Curva ABC
			PEC057 - Cálculo da Curva ABC
@ Obs		
@history    
/*/
Static Function ZPECF040PR_ProcessaCurvaABC( _oSay )
Local _aSays	    := {}
Local _aButtons	    := {}
Local _cCadastro    := OemToAnsi("Curva ABC CAOA")   
Local _cTitle  	    := OemToAnsi("Curva ABC CAOA")   
Local _aPar    	    := {}
Local _aRet    	    := {}
Local _nRet			:= 0
Local _cCodProdDe	:= Space(TamSx3("B1_COD")[1]) 
Local _cCodProdAte	:= Space(TamSx3("B1_COD")[1]) 
Local _cMarca	    := Space(TamSx3("BM_CODMAR")[1])   
Local _dDataCurva   := Date()
Local _nMesExcesso  := 0

Local _cChave		:= ""
Local _lRet			:= .T.
Local _nPos

Begin Sequence
	//_lRet := U_ZGENUSER( RetCodUsr() ,"ZPECF040PR" ,.T.)	
	If !_lRet
		Break
	EndIf
		//Garantir que o processamento seja unico
	_cChave		:= AllTrim(FWCodEmp())+"ZPECF040"
	If !LockByName(_cChave,.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 3000 ) // Para o processamento por 3 segundos
			If LockByName("_cChave",.T.,.T.)
				_lRet := .T.
			EndIf
		Next		
		If !_lRet
			MSGINFO("Já existe um processamento em execução rotina ZPECF040, aguarde!", "[ZPECF040] - Atenção" )
			Break
		EndIf
	EndIf

	DbSelectArea("SZO")
	aAdd(_aPar,{1,OemToAnsi("Produto de     : ") ,_cCodProdDe			,"@!"		,".T."	,"SB1" 	,".T."	,100,.F.}) 
	aAdd(_aPar,{1,OemToAnsi("Produto ate    : ") ,_cCodProdAte		    ,"@!"		,".T."	,"SB1"	,".T."	,100,.T.}) 
	aAdd(_aPar,{1,OemToAnsi("Marca          : ") ,_cMarca		        ,"@!"		,".T."	,"VE1"	,".T."	,100,.F.}) 
	aAdd(_aPar,{1,OemToAnsi("Data Curva     : ") ,_dDataCurva		    ,"@D"		,".T."	,	    ,".T."	,100,.T.}) 
	aAdd(_aPar,{1,OemToAnsi("Meses Excesso  : ") ,_nMesExcesso		    ,"@E 99,999",".T."	,	    ,".T."	,100,.F.}) 

	//aAdd(_aPar,{3,OemToAnsi("Atualiza Base: ") ,2 ,{"SIM","NAO"}	,80,"",.F.})  

	// Monta Tela principal
	aAdd(_aSays,OemToAnsi("Este Programa tem  como  a visualização da Curva ABC CAOA")) 
	aAdd(_aSays,OemToAnsi("podendo ser reprocessada esta Curva com todos os Parametros.")) 
	aAdd(_aSays,OemToAnsi("Também Será possivel Gerar Excel dos dados processados para a Curva.")) 

	aAdd(_aButtons, { 1,.T.,{|o| FechaBatch(),_nRet:=1											}})
	aAdd(_aButtons, { 2,.T.,{|o| FechaBatch()													}})
	aAdd(_aButtons, { 5,.T.,{|o| ParamBox(_aPar,_cTitle,@_aRet,,,.T.,,,,"ZPECF040",.T.,.T.) 	}})

	FormBatch( _cCadastro, _aSays, _aButtons )
	If _nRet <> 1
		Break
	Endif
	If Len(_aRet) == 0
		Help( , ,OemToAnsi("Atenção"),,OemToAnsi("Necessário informar os parâmetros"),4,1)   
		Break 
	Endif

	_cCodProdDe		:= _aRet[1]
	_cCodProdAte	:= _aRet[2]
	_cMarca			:= _aRet[3]

	SB1->(DbSetOrder(1))
	If !Empty(_cCodProdDe) .And. !SB1->(DbSeek(FwXFilial("SB1")+_cCodProdDe))
		Help( , ,OemToAnsi("Atenção"),,OemToAnsi("Código Produto "+AllTrim(_cCodProdDe)+" não cadastrado"),4,1)   
		Break 
	Endif
	If !Empty(_cCodProdAte) .And. AllTrim(_cCodProdAte) <> Replicate("Z",Len(AllTrim(_cCodProdAte))) 
		If !SB1->(DbSeek(FwXFilial("SB1")+_cCodProdAte))
			Help( , ,OemToAnsi("Atenção"),,OemToAnsi("Código Produto "+AllTrim(_cCodProdAte)+" não cadastrado"),4,1)   
			Break 
		Endif
	Endif
	VE1->(DbSetOrder(1))
	If !Empty(_cMarca) .And. !VE1->(DbSeek(FwXFilial("VE1")+_cMarca))
		Help( , ,OemToAnsi("Atenção"),,OemToAnsi("Código Veículo "+AllTrim(_cMarca)+" não cadastrado"),4,1)   
		Break 
	Endif 
	FwMsgRun(,{ |_oSay| ZPECF040QY(_aRet, @_oSay ) }, "Selecionando dados para a Montagem Curva ABC", "Aguarde...")  
	//Libera para utilização de outros usuarios
	_oBrw:Refresh(.T.)
End Sequence
//Desbloquear processamento
If !Empty(_cChave)
	UnLockByName(_cChave,.T.,.T.)
Endif
Return Nil


/*/{Protheus.doc} ZPECF040QY
Query de processamento Curva
@author 	DAC
@since 		15/07/2023
@version 	undefined
@param 		
@type 		Static function
@project    GAP014 | Cálculo da Curva ABC
			PEC057 - Cálculo da Curva ABC
@ Obs		
@history    
/*/
Static Function ZPECF040QY(_aRet, _oSay)
Local _cTable 		:= RetSqlName("SZO")
Local _cProdutoDe 	:= _aRet[1]
Local _cProdutoAte 	:= _aRet[2]
Local _cMarca 		:= _aRet[3]
Local _dDataCurva	:= _aRet[4]
Local _nMesExcesso  := _aRet[5]
Local _cAliasPesq   := GetNextAlias()      
Local _cFilDe		:= Space(TamSx3("B1_FILIAL")[1])
Local _cFilAte		:= Repl("Z",TamSx3("B1_FILIAL")[1])  
//Local _cCFVenda     := AllTrim(SuperGetMV( "CMV_PEC047" , ,"5102;5152;5403;6102;6110;6403" ))   //Parâmetro para indicação CF de Venda, para controlar select da curva ABC para notas de saida
//Local _cCFCompra    := AllTrim(SuperGetMV( "CMV_PEC048" , ,"1102;2102;3102" ))   ///Parâmetro para indicação CF de Compras, para controlar select da curva ABC para notas de Compras
//Local _nMesRef      := (SuperGetMV( "CMV_PEC049" , ,12 ))   		//meses referencias para calculo cruva ABC
Local _cCFVenda     := AllTrim(SuperGetMV( "CMV_PEC047" , ,"" ))   //Parâmetro para indicação CF de Venda, para controlar select da curva ABC para notas de saida
Local _cCFCompra    := AllTrim(SuperGetMV( "CMV_PEC048" , ,"" ))   ///Parâmetro para indicação CF de Compras, para controlar select da curva ABC para notas de Compras
Local _nMesRef      := (SuperGetMV( "CMV_PEC049" , ,0 ))   			//meses referencias para calculo cruva ABC
Local _aPontos		:= {}
Local _aStruct 		:= {}	//SZO->(DbStruct())
Local _aPontoCurva	:= {}
//Local _nPontosCurva := 150 //pontuação maxima na curva ABC
Local _cCurvaFim    := " "  //indica a ultima informação para definir curva a que não foi detectada e ou maior tempo de todas
Local _cQuery 		:= ""
Local _cTititulo  	:= '<font color="#FF0000"><b>IMPORTANTE</b></font>' 

Local _nPos
Local _nCount
Local _nStatus
Local _cMens
Local _nPontos
Local _cHoraIni
Local _cHoraFim
Local _xValor
//Local _nRegProcess
Local _lExclusive
Local _cTimeCalc
Begin Sequence
	_cMens 			:= '<h1>Confirma?</h1><br>Tem certeza que deseja processar Curva ABC ? Os dados atuais serão Apagador ! <font color="#FF0000"><b>  Processar Curva ABC  </b></font>. '
	If !MsgYesNo( _cMens, _cTititulo )
		Break
	Endif	

	If Empty(_cCFVenda)
		_cMens 		:= "Necessário informar parâmetros CF Vendas CMV_PEC047"
		MSGINFO(_cMens , "Atenção" )
		Break
	Endif 
	
	If Empty(_cCFCompra)
		_cMens 		:= "Necessário informar parâmetros CF Compras CMV_PEC048"
		MSGINFO(_cMens , "Atenção" )
		Break
	Endif 

	If _nMesRef <= 0
		_cMens 		:= "Necessário informar quantidade de meses para calculo Curva CMV_PEC049"
		MSGINFO(_cMens , "Atenção" )
		Break
	Endif 

	_cHoraIni := Time()
	_oSay:SetText("Aguarde preparando informações "+Time())
	ProcessMessage()

	//montar regra procura de pontos
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT 	SX5.X5_CHAVE 			CHAVE,
				TRIM(SX5.X5_DESCRI) 	TIPO,
				TRIM(SX5.X5_DESCSPA) 	INICIAL,
				TRIM(SX5.X5_DESCENG)	FINAL
		FROM  %Table:SX5% SX5 
		WHERE 	SX5.X5_FILIAL 	=  %xFilial:SX5% 
			AND SX5.X5_TABELA   = '2A' 
			AND SX5.%notDel%
		ORDER BY SX5.X5_CHAVE	
	EndSql
	(_cAliasPesq)->(DbGoTop())
	If (_cAliasPesq)->(Eof())
		_cMens := "Não existe tabela informada para Curva Quantidade, deseja continuar ?"  
		MSGINFO(_cMens , "Atenção" )
		Break
	Endif
	While (_cAliasPesq)->(!Eof())
		AAdd(_aPontos, { AllTrim((_cAliasPesq)->CHAVE),;  
			  			 AllTrim((_cAliasPesq)->TIPO),;
						 AllTrim((_cAliasPesq)->INICIAL),;
						 AllTrim((_cAliasPesq)->FINAL);
						})
		(_cAliasPesq)->(DbSkip())				
	EndDo
	//Criar select para pegar as pontuações por movimentação vendas tabela SX5 2B
	If Select(_cAliasPesq) <> 0
		(_cAliasPesq)->(DbCloseArea())
	Endif  
	_aPontoCurva := {}
	_nPontos     := 0
	//montar regra procura de pontos
	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT 	SX5.X5_CHAVE 			CHAVE,
				TRIM(SX5.X5_DESCRI) 	TIPO,
				TRIM(SX5.X5_DESCSPA) 	INICIAL,
				TRIM(SX5.X5_DESCENG)	FINAL
		FROM  %Table:SX5% SX5 
		WHERE 	SX5.X5_FILIAL 	=  %xFilial:SX5% 
			AND SX5.X5_TABELA   = '2B' 
			AND SX5.%notDel%
		ORDER BY SX5.X5_CHAVE	
	EndSql
	(_cAliasPesq)->(DbGoTop())
	If (_cAliasPesq)->(Eof())
		_cMens := "Não existe tabela informada para Curva Quantidade, deseja continuar ?"  
		MSGINFO(_cMens , "Atenção" )
	Endif
	While (_cAliasPesq)->(!Eof())
		_nPontos ++
		AAdd(_aPontoCurva, { AllTrim((_cAliasPesq)->CHAVE),;  
			  				 AllTrim((_cAliasPesq)->TIPO),;
							 AllTrim((_cAliasPesq)->INICIAL),;
							 AllTrim((_cAliasPesq)->FINAL);
							})
		(_cAliasPesq)->(DbSkip())				
	EndDo
	//a quantidade de pontos tem que ser igual ao mes referencia para os calculos da curva pois os mesmos são pelo mes referencia
	If _nPontos <> _nMesRef
		_cMens := "Quantidade informada referente a pontuação no cadastro (SX5) esta de desacordo com a quantidade do meses de referencia !"  
		MSGINFO(_cMens , "Atenção" )
		Break
	Endif
	aSort( _aPontoCurva , , , { |x,y| x[3] > y[3] } )  //para organiar de acordo com os meses
	//Apaga arquivo temporario
	If Select(_cAliasPesq) <> 0
		(_cAliasPesq)->(DbCloseArea())
		Ferase(_cAliasPesq+GetDBExtension())
	Endif  

	_oSay:SetText("Aguarde Calculando CURVA ... Hora Inicial "+Time() )
	ProcessMessage()

	SZO->(DbSetOrder(1))
	SZO->(DbGoTop())


	//Campos constantes na Query
	Aadd(_aStruct, "ZO_FILIAL") 
	Aadd(_aStruct, "ZO_COD")
	Aadd(_aStruct, "ZO_DESCPRD")
	Aadd(_aStruct, "ZO_MARCA")  
	Aadd(_aStruct, "ZO_CURVQTD") 
	Aadd(_aStruct, "ZO_CURVCUS") 
	Aadd(_aStruct, "ZO_SALDOES") 
	Aadd(_aStruct, "ZO_CUSTUNI") 
	Aadd(_aStruct, "ZO_CUSTTOT") 
	Aadd(_aStruct, "ZO_DTPRDCA") 
	Aadd(_aStruct, "ZO_DTPRCMP") 
	Aadd(_aStruct, "ZO_DTULCMP") 
	Aadd(_aStruct, "ZO_DTPRVND") 
	Aadd(_aStruct, "ZO_DTULVND") 
	Aadd(_aStruct, "ZO_TOTVEND")
	Aadd(_aStruct, "ZO_MEDIADE")  //media de venda
	Aadd(_aStruct, "ZO_MOS")
	Aadd(_aStruct, "ZO_EXQTDE")
	Aadd(_aStruct, "ZO_EXCUSTO")

	Aadd(_aStruct, "ZO_MESINCL")   	//CURVA_INCLUSAO
	Aadd(_aStruct, "ZO_MESPVEN")   	//CURVA_PVENDA
	Aadd(_aStruct, "ZO_MESUVEN")   	//CURVA_UVENDA	  
	Aadd(_aStruct, "ZO_MESPCMP")   	//CURVA_PCOMPRA	
	Aadd(_aStruct, "ZO_MESUCMP") 	//CURVA_UCOMPRA
	Aadd(_aStruct, "ZO_PONTOS") 	//CURVA_PONTOS

	Aadd(_aStruct, "ZO_DTBASEC")
	Aadd(_aStruct, "ZO_CODUSU")
	Aadd(_aStruct, "ZO_NOMEUSU")
	Aadd(_aStruct, "ZO_DTCALC")
	Aadd(_aStruct, "ZO_HSCALC")      

	_aStru := {}
    For _nPos := 1 To Len(_aStruct)
        _aTamSx3 := TamSX3(_aStruct[_nPos])
        Aadd(_aStru, {_aStruct[_nPos], _aTamSx3[03], _aTamSx3[01], _aTamSx3[02] })
    Next

    _cTable := GetNextAlias()
    _oTable := FWTemporaryTable():New()
    _oTable:SetFields(_aStru)
    _oTable:AddIndex("INDEX1", {"ZO_COD"} )
    _oTable:Create()
    _cAliasPesq := _oTable:GetAlias()

    _cTable := _oTable:GetRealName()
	
	_cQuery := " INSERT INTO "+_cTable+CRLF
    _cQuery += " ( "
    For _nPos := 01 To Len(_aStruct)
        _cQuery += _aStruct[_nPos]
   	    _cQuery += ", "
    Next _nPos
    _cQuery += " D_E_L_E_T_, R_E_C_N_O_ "   //campos que não aparecem no browse e devem ser preenchidos
    _cQuery += " ) "+ CRLF

    _cQuery += " WITH "+ CRLF
    _cQuery += " 	MES_PONTOS AS( "+ CRLF   
    _cQuery += "    		 SELECT SD2.D2_COD "+ CRLF
    _cQuery += "     		, CASE "+ CRLF
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 <=  "+AllTrim(Str(_nMesRef))+" AND SUM(NVL(SD2.D2_QUANT,0)) > 0 "+ CRLF	
    _cQuery += "     			THEN NVL(SUM(SD2.D2_QUANT),0) "+ CRLF    
    _cQuery += "     			ELSE 0 "+ CRLF
    _cQuery += " 			  END AS TOT_QTDECURVA "+ CRLF
    _cQuery += " 			, MAX(TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1) AS MESES "+ CRLF
    _cQuery += "     		, CASE "+ CRLF
	//Montar primeiro curva de pontos
	/*  iplementar
	For _nPos := 1 To Len(_aPontoCurva) 
    	_cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  "+StrZero(_nPos,3)+" AND SUM(NVL(SD2.D2_QUANT,0)) > 0 	THEN "+_aPontoCurva[_nPos,1]+" "+ CRLF  	
	Next
	//após montar as demais pontuações 
	If Len(_aPontos) > 0
    	_cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 <= 24 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 24 "+ CRLF    	
	Endif
	*/
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  01 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 18 "+ CRLF  	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  02 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 17 "+ CRLF   	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  03 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 16 "+ CRLF  	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  04 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 15 "+ CRLF   	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  05 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 14 "+ CRLF   	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  06 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 13 "+ CRLF   	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  07 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 12 "+ CRLF   	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  06 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 11 "+ CRLF   	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  09 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 10 "+ CRLF   	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  10 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 09 "+ CRLF   	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  11 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 08 "+ CRLF   	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  12 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 07 "+ CRLF   	
	/*
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 <= 24 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 00 "+ CRLF    	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 <= 36 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 00 "+ CRLF    	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 <= 48 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 00 "+ CRLF    	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 <= 60 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 00 "+ CRLF    	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 <= 72 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 00 "+ CRLF    	
    _cQuery += "     			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 >  72 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 00 "+ CRLF    	
	*/
    _cQuery += "    			ELSE 0 "+ CRLF
    _cQuery += "     		END PONTOS "+ CRLF
    _cQuery += "     	FROM "+RetSqlName("SD2")+" SD2 "+ CRLF 
    _cQuery += " 		WHERE SD2.D_E_L_E_T_ = ' ' "+ CRLF
    _cQuery += " 			AND SD2.D2_FILIAL BETWEEN '"+_cFilDe+"' AND '"+_cFilAte+"'  "+ CRLF
	_cQuery += "    		AND SD2.D2_COD BETWEEN '" +_cProdutoDe+ "' AND '" +_cProdutoAte+ "' " + CRLF 
    _cQuery += " 			AND SD2.D2_CF IN "+ FormatIn(_cCFVenda,";") + " "+ CRLF
    _cQuery += " 			GROUP BY D2_COD , TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD'))) "+ CRLF
    _cQuery += "     		ORDER BY D2_COD "+ CRLF
    _cQuery += "  		) , "+ CRLF
    _cQuery += " 	MEDIAS AS ( "+ CRLF  
    _cQuery += " 		SELECT   MES_PONTOS.D2_COD "+ CRLF
    _cQuery += " 				, SUM(MES_PONTOS.TOT_QTDECURVA) 					AS TOT_CURVA "		+ CRLF
    _cQuery += " 				, (SUM(MES_PONTOS.TOT_QTDECURVA) / "+StrZero(_nMesRef,3)+")		AS DEMANDA_MEDIA"	+ CRLF
    _cQuery += " 				, AVG(SB2JOIN.SALDO_ESTOQUE)  						AS SALDO_ESTOQUE "	+ CRLF
    _cQuery += " 				, AVG(SB2JOIN.CUSTO_UNITARIO) 						AS CUSTO_UNITARIO "	+ CRLF
    _cQuery += " 		FROM MES_PONTOS "+ CRLF
    _cQuery += " 		LEFT JOIN	(	SELECT 	 B2_COD  "+ CRLF
    _cQuery += "  							,  	SUM(NVL(B2_QATU,0)) AS SALDO_ESTOQUE "+ CRLF 
    _cQuery += "  							,	( SUM(NVL(B2_VATU1,0)) / SUM(NVL(B2_QATU,0)) ) AS CUSTO_UNITARIO "+ CRLF
    _cQuery += "  				FROM "+RetSqlName("SB2")+" SB2 " + CRLF 
    _cQuery += "  				WHERE 	SB2.D_E_L_E_T_ 	= ' ' "+ CRLF
    _cQuery += "  					AND SB2.B2_FILIAL BETWEEN '"+_cFilDe+"' AND '"+_cFilAte+"' " + CRLF
    _cQuery += "  					AND SB2.B2_QATU 	<> 0 " + CRLF
    _cQuery += "  				GROUP BY B2_COD " + CRLF
    _cQuery += "  			) SB2JOIN " + CRLF
    _cQuery += "  			ON SB2JOIN.B2_COD = MES_PONTOS.D2_COD " + CRLF
    _cQuery += " 		WHERE MES_PONTOS.MESES <= "+AllTrim(Str(_nMesRef)) + CRLF
    _cQuery += " 			AND NVL(MES_PONTOS.TOT_QTDECURVA,0) > 0 " + CRLF
    _cQuery += " 		GROUP BY MES_PONTOS.D2_COD " + CRLF
    _cQuery += " 		) " + CRLF
   	_cQuery += " SELECT  '"+FwXFilial("SZO")+"' AS ZO_FILIAL" + CRLF						//--ZO_FILIAL							//--TMPFILIAL
    _cQuery += " 		,SB1.B1_COD	 AS ZO_COD" + CRLF   									//--ZO_COD
    _cQuery += " 		,SB1.B1_DESC    AS DESCRICAO " + CRLF								//--ZO_DESCPRD
    _cQuery += " 		,COALESCE(SBM.BM_CODMAR,' ')	AS MARCA " + CRLF					//--ZO_MARCA
	//montar informações curva ABC pontos	
	If Len(_aPontos) == 0
    	_cQuery += "' ' AS  CURVA_PONTOS " + CRLF											//--ZO_CURVQTD
	Else
    	_cQuery += " 		, (	SELECT CASE " + CRLF
		For _nPos := 1 To Len(_aPontos)
			If AllTrim(_aPontos[_nPos,2])  == "P"  	//PONTOS
     			_cQuery += " 	WHEN NVL(SUM(MES_PONTOS.PONTOS),0) BETWEEN " +_aPontos[_nPos,3]+" AND "+_aPontos[_nPos,4]+" 	THEN '"+_aPontos[_nPos,1]+"' " + CRLF
			ElseIf AllTrim(_aPontos[_nPos,2])  == "N"  //NOVO tem que avaliar se tem menos de um ano
    			_cQuery += "	WHEN COALESCE(SB1.B1_XDTINC,'        ') <> ' ' " + CRLF 
    			_cQuery += " 		AND TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(SB1.B1_XDTINC, 'YYYYMMDD'))) <= "+StrZero(_nMesRef,3) + " "
    			_cQuery += " 		AND NVL(SUM(MES_PONTOS.PONTOS),0) = 0 THEN '"+_aPontos[_nPos,1]+"' " + CRLF //--No periodo de 1 ano a partir da data de cadastro não possuir nenhuma venda
    			_cQuery += "	WHEN COALESCE(SB1.B1_XUCLEG,'        ') <> ' ' " + CRLF 
    			_cQuery += " 		AND TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(SB1.B1_XUCLEG, 'YYYYMMDD'))) <= "+StrZero(_nMesRef,3) + " "
    			_cQuery += " 		AND NVL(SUM(MES_PONTOS.PONTOS),0) = 0 THEN '"+_aPontos[_nPos,1]+"' " + CRLF //--No periodo de 1 ano a partir da data de cadastro não possuir nenhuma venda
    			_cQuery += "	WHEN COALESCE(SD1SQL.DT_ULTCMP,'        ') <> ' ' " + CRLF 
    			_cQuery += " 		AND TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(SD1SQL.DT_ULTCMP, 'YYYYMMDD'))) <= "+StrZero(_nMesRef,3) + " "
    			_cQuery += " 		AND NVL(SUM(MES_PONTOS.PONTOS),0) = 0 THEN '"+_aPontos[_nPos,1]+"' " + CRLF //--No periodo de 1 ano a partir da data de cadastro não possuir nenhuma venda
			ElseIf AllTrim(_aPontos[_nPos,2])  == "Q"   //QUANTIDADE
				//MONTAR AS PRIMEIRAS LINHAS OBEDECER ORDEM
				//If _aPontos[_nPos,3] = "0"  //ATIVO significa que ainda esta em uma contagem de até com meses fora da curva
    				//_cQuery += " 	WHEN NVL(MIN(MES_PONTOS.MESES),0) <= "+AllTrim((_aPontos[_nPos,4]))+" AND NVL(SUM(MES_PONTOS.PONTOS),0) > "+Str(_nPontosCurva)+" THEN '"+AllTrim(_aPontos[_nPos,1])+"' " + CRLF
				_cQuery += " 	WHEN NVL(MIN(MES_PONTOS.MESES),0) > 0 AND NVL(MIN(MES_PONTOS.MESES),0)  "+AllTrim((_aPontos[_nPos,3]))+ "  " +AllTrim((_aPontos[_nPos,4]))+" THEN '"+AllTrim(_aPontos[_nPos,1])+"' " + CRLF
				_cQuery += " 	WHEN COALESCE(SB1.B1_XUVLEG,'        ') > ' ' AND TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(SB1.B1_XUVLEG, 'YYYYMMDD')))+1 "+AllTrim((_aPontos[_nPos,3]))+ "  "+AllTrim((_aPontos[_nPos,4]))+" THEN '"+AllTrim(_aPontos[_nPos,1])+"' " + CRLF 
				_cQuery += " 	WHEN COALESCE(SB1.B1_XUCLEG,'        ') > ' ' AND TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(SB1.B1_XUCLEG, 'YYYYMMDD')))+1 "+AllTrim((_aPontos[_nPos,3]))+ "  "+AllTrim((_aPontos[_nPos,4]))+" THEN '"+AllTrim(_aPontos[_nPos,1])+"' " + CRLF 
					//_cQuery += " 	WHEN COALESCE(SB1.B1_XDTINC,'        ') = ' ' AND COALESCE(SB1.B1_XUVLEG,'        ') > ' ' AND TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(SB1.B1_XUVLEG, 'YYYYMMDD')))+1  <= "+AllTrim((_aPontos[_nPos,4]))+" THEN '"+AllTrim(_aPontos[_nPos,1])+"' " + CRLF 
					//_cQuery += " 	WHEN COALESCE(SB1.B1_XDTINC,'        ') = ' ' AND COALESCE(SB1.B1_XUCLEG,'        ') > ' ' AND TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(SB1.B1_XUCLEG, 'YYYYMMDD')))+1  <= "+AllTrim((_aPontos[_nPos,4]))+" THEN '"+AllTrim(_aPontos[_nPos,1])+"' " + CRLF 
				//ElseIf _aPontos[_nPos,3] = "I"  //INATIVO significa que ainda esta em uma contagem de até com meses fora da curva
				//	_cQuery += " 	WHEN COALESCE(SB1.B1_XDTINC,'        ') = ' ' AND NVL(MIN(MES_PONTOS.MESES),0) > 0 AND NVL(MIN(MES_PONTOS.MESES),0) <= "+AllTrim((_aPontos[_nPos,4]))+" THEN '"+AllTrim(_aPontos[_nPos,1])+"' " + CRLF
				//	_cQuery += " 	WHEN COALESCE(SB1.B1_XDTINC,'        ') = ' ' AND COALESCE(SB1.B1_XUVLEG,'        ') > ' ' AND TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(SB1.B1_XUVLEG, 'YYYYMMDD')))+1  <= "+AllTrim((_aPontos[_nPos,4]))+" THEN '"+AllTrim(_aPontos[_nPos,1])+"' " + CRLF 
				//	_cQuery += " 	WHEN COALESCE(SB1.B1_XDTINC,'        ') = ' ' AND COALESCE(SB1.B1_XUCLEG,'        ') > ' ' AND TRUNC(MONTHS_BETWEEN(TO_DATE('"+DtOs(_dDataCurva)+"', 'YYYYMMDD'), TO_DATE(SB1.B1_XUCLEG, 'YYYYMMDD')))+1  <= "+AllTrim((_aPontos[_nPos,4]))+" THEN '"+AllTrim(_aPontos[_nPos,1])+"' " + CRLF 

				//Else  //quando o inicial estiver igual a 0 (zero) significa que é o ultimo valor a ser considderado e sera maior que o mesmo
   				//	_cQuery += " 	WHEN NVL(MIN(MES_PONTOS.MESES),0) >=  "+AllTrim(_aPontos[_nPos,4])+"   THEN '"+AllTrim(_aPontos[_nPos,1])+"' " + CRLF
				//EndIf 	
			ElseIf AllTrim(_aPontos[_nPos,2])  == "S"   //ULTIMA POSIÇÃO DA CURVA
 				_cQuery += " 	WHEN TRUNC(NVL(SB2SQL.SALDO_ESTOQUE,0)) > 0 	THEN 'I' "
			ElseIf AllTrim(_aPontos[_nPos,2])  == "F"   //ULTIMA POSIÇÃO DA CURVA
					_cCurvaFim := _aPontos[_nPos,1]
			EndIf 
		Next _nPos 
	EndIf 		
    _cQuery += " 				ELSE '"+_cCurvaFim+"' " + CRLF
    _cQuery += " 				END " + CRLF	
    _cQuery += " 			FROM MES_PONTOS " + CRLF
    _cQuery += " 			WHERE MES_PONTOS.D2_COD =  SB1.B1_COD " + CRLF
    _cQuery += " 			) AS  CURVA_PONTOS " + CRLF												//--ZO_CURVQTD
    _cQuery += " 		, COALESCE( ( 	SELECT TRIM(SX5.X5_CHAVE) " + CRLF
    _cQuery += " 						FROM "+RetSqlName("SX5")+" SX5 " + CRLF  
    _cQuery += " 						WHERE SX5.D_E_L_E_T_ 	= ' ' " + CRLF
    _cQuery += " 							AND SX5.X5_FILIAL 	= '"+FwXFilial("SX5")+"' " + CRLF
    _cQuery += "   							AND SX5.X5_TABELA   = '2C' " + CRLF
//    _cQuery += "   							AND (SB2SQL.SALDO_ESTOQUE * SB2SQL.CUSTO_UNITARIO) BETWEEN TO_NUMBER(SX5.X5_DESCSPA) AND TO_NUMBER(SX5.X5_DESCENG) " + CRLF
    _cQuery += "   							AND ( SB2SQL.CUSTO_UNITARIO ) BETWEEN TO_NUMBER(SX5.X5_DESCSPA) AND TO_NUMBER(SX5.X5_DESCENG) " + CRLF
    _cQuery += "         	  		) ,' ') AS CURVA_VALORES " + CRLF								//--ZO_CURVCUS
    _cQuery += "   		, TRUNC(NVL(SB2SQL.SALDO_ESTOQUE,0)) AS SALDO_ESTOQUE " + CRLF				//--ZO_SALDOES 
    _cQuery += "  		, NVL(SB2SQL.CUSTO_UNITARIO,0)      AS CUSTO_UNITARIO 	" + CRLF			//--ZO_CUSTUNI
    _cQuery += "  		, NVL(SB2SQL.SALDO_ESTOQUE * SB2SQL.CUSTO_UNITARIO, 0)	AS CUSTO_TOTAL" + CRLF //--ZO_CUSTTOT
    _cQuery += "  		, COALESCE(B1_XDTINC,' ')  AS DT_CAD_PRD " + CRLF							//--ZO_DTPRDCA  DATA da inclusão cadastro SB1

    _cQuery += " 	    , 	CASE " + CRLF
	//Caso esteja preenchida a do legado a prioridade é dela
    _cQuery += " 	    		WHEN COALESCE(SB1.B1_X1CLEG,' ') 	 <> ' '	THEN SB1.B1_X1CLEG " 		+ CRLF		//--Ultima Compra Legado
    _cQuery += " 	    		WHEN COALESCE(SD1SQL.DT_PRIMCMP,' ') <> ' ' THEN SD1SQL.DT_PRIMCMP " 	+ CRLF
    _cQuery += " 	    	ELSE ' ' " + CRLF
    _cQuery += " 	    	END AS DT_PRI_CMP " + CRLF												//--ZO_DTULCMP
    _cQuery += " 	    , 	CASE " + CRLF
    _cQuery += " 	    		WHEN COALESCE(SD1SQL.DT_ULTCMP,' ') <> ' ' 	THEN SD1SQL.DT_ULTCMP " + CRLF
    _cQuery += " 	    		WHEN COALESCE(SB1.B1_XUCLEG,' ') 	<> ' '	THEN SB1.B1_XUCLEG " + CRLF		//--Ultima Compra Legado
    _cQuery += " 	    	ELSE ' ' " + CRLF
    _cQuery += " 	    	END AS DT_ULT_CMP " + CRLF												//--ZO_DTULCMP
	//Caso esteja preenchida a do legado a prioridade é dela
    _cQuery += " 	    , 	CASE " + CRLF
    _cQuery += " 	    		WHEN COALESCE(SB1.B1_X1VLEG,' ') 		<> ' '	THEN SB1.B1_X1VLEG	" 		+ CRLF		//--Ultima Venda Legado
    _cQuery += " 	    		WHEN COALESCE(SD2SQLPRD.NF_PRIVND,' ') 	<> ' ' 	THEN SD2SQLPRD.NF_PRIVND " 	+ CRLF
    _cQuery += " 	    	ELSE ' ' " + CRLF
    _cQuery += " 	    	END AS DT_PRI_FAT " + CRLF												//--TMPDTULVND
    _cQuery += " 	    , 	CASE " + CRLF
    _cQuery += " 	    		WHEN COALESCE(SD2SQLPRD.NF_ULTVND,' ') 	<> ' ' 	THEN SD2SQLPRD.NF_ULTVND " + CRLF
    _cQuery += " 	    		WHEN COALESCE(SB1.B1_XUVLEG,' ') 			<> ' '	THEN SB1.B1_XUVLEG	" + CRLF		//--Ultima Venda Legado
    _cQuery += " 	    	ELSE ' ' " + CRLF
    _cQuery += " 	    	END AS DT_ULT_FAT " + CRLF												//--ZO_DTULVND
    _cQuery += " 	    , NVL(SD2SQLPRD.TOT_PECAS,0) AS TOT_PECAS " + CRLF				//--ZO_TOTVEND	
    _cQuery += " 		, NVL( (SELECT MEDIAS.DEMANDA_MEDIA " + CRLF
    _cQuery += " 				FROM MEDIAS " + CRLF
    _cQuery += " 				WHERE MEDIAS.D2_COD = SB1.B1_COD),0) 	AS DEMANDA_MEDIA " + CRLF	//--ZO_MEDIADE
    _cQuery += " 		, NVL( (SELECT NVL(MEDIAS.SALDO_ESTOQUE / MEDIAS.DEMANDA_MEDIA,0) " + CRLF
    _cQuery += " 				FROM MEDIAS " + CRLF
    _cQuery += " 				WHERE MEDIAS.D2_COD = SB1.B1_COD ),0) AS MOS " + CRLF				//--TMPMOS
 
    _cQuery += " 		, NVL( (SELECT (NVL(SB2SQL.SALDO_ESTOQUE / MEDIAS.DEMANDA_MEDIA,0 ) - "+StrZero(_nMesExcesso,3)+" ) *	MEDIAS.DEMANDA_MEDIA " + CRLF
    _cQuery += " 				FROM MEDIAS " + CRLF
    _cQuery += " 				WHERE MEDIAS.D2_COD = SB1.B1_COD
    _cQuery += " 					AND MEDIAS.SALDO_ESTOQUE / MEDIAS.DEMANDA_MEDIA >= "+AllTrim(Str(_nMesExcesso))
    _cQuery += " 				) ,0)  AS EXCESSO_QTDE " + CRLF		//--ZO_EXQTDE
    _cQuery += " 		, NVL( (SELECT ( (NVL(SB2SQL.SALDO_ESTOQUE / MEDIAS.DEMANDA_MEDIA,0 ) - "+StrZero(_nMesExcesso,3)+" ) *	MEDIAS.DEMANDA_MEDIA) * MEDIAS.CUSTO_UNITARIO " + CRLF
    _cQuery += " 				FROM MEDIAS " + CRLF
    _cQuery += " 				WHERE MEDIAS.D2_COD = SB1.B1_COD
    _cQuery += " 					AND MEDIAS.SALDO_ESTOQUE / MEDIAS.DEMANDA_MEDIA >= "+AllTrim(Str(_nMesExcesso))
    _cQuery += " 				),0)  AS CUSTO_EXCESSO " + CRLF		//--ZO_EXCUSTO 

    _cQuery += "     	, CASE	WHEN COALESCE(SB1.B1_XDTINC,'        ') <> ' ' " + CRLF
    _cQuery += "     	  		THEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230731', 'YYYYMMDD'), TO_DATE(SB1.B1_XDTINC, 'YYYYMMDD')))+1 " + CRLF
    _cQuery += "     	 		ELSE 0 " + CRLF
    _cQuery += "     	 		END AS CURVA_INCLUSAO " + CRLF

    _cQuery += "     	, CASE	WHEN COALESCE(SB1.B1_X1VLEG,'        ') <> ' ' " + CRLF
    _cQuery += "     	  		THEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230731', 'YYYYMMDD'), TO_DATE(SB1.B1_X1VLEG, 'YYYYMMDD')))+1 " + CRLF
    _cQuery += "     	 		ELSE 0 " + CRLF
    _cQuery += "     	 		END AS CURVA_PVENDA " + CRLF

    _cQuery += "     	, CASE	WHEN COALESCE(SB1.B1_XUVLEG,'        ') <> ' ' " + CRLF
    _cQuery += "     	  		THEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230731', 'YYYYMMDD'), TO_DATE(SB1.B1_XUVLEG, 'YYYYMMDD')))+1 " + CRLF
    _cQuery += "     	 		ELSE 0 " + CRLF
    _cQuery += "     	 		END AS CURVA_UVENDA " + CRLF

    _cQuery += "     	, CASE	WHEN COALESCE(SB1.B1_X1CLEG,'        ') <> ' ' " + CRLF
    _cQuery += "     	  		THEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230731', 'YYYYMMDD'), TO_DATE(SB1.B1_X1CLEG, 'YYYYMMDD')))+1 " + CRLF
    _cQuery += "     	 		ELSE 0 " + CRLF
    _cQuery += "     	 		END AS CURVA_PCOMPRA " + CRLF

    _cQuery += "     	, CASE	WHEN COALESCE(SB1.B1_XUCLEG,'        ') <> ' ' " + CRLF
    _cQuery += "     	  		THEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230731', 'YYYYMMDD'), TO_DATE(SB1.B1_XUCLEG, 'YYYYMMDD')))+1 " + CRLF
    _cQuery += "     	 		ELSE 0 " + CRLF
    _cQuery += "     	 		END AS CURVA_UCOMPRA " + CRLF

    _cQuery += "     	 , (SELECT NVL(SUM(MES_PONTOS.PONTOS),0) FROM MES_PONTOS	WHERE MES_PONTOS.D2_COD =  SB1.B1_COD) AS PONTOS " + CRLF	

    _cQuery += "     	,'"+DtOs(_dDataCurva)+"' AS DTBASEC " + CRLF							//--ZO_DTBASEC
    _cQuery += "     	,'"+RetCodUsr()+"' 	AS CODUSU " + CRLF									//--ZO_CODUSU 
   	_cQuery += "     	,'"+Upper(UsrRetName(RetCodUsr()))+"' 	AS NOMUSU " + CRLF				//--ZO_NOMUSU
    _cQuery += "     	,'"+DtOs(Date())+"' AS DTCALC " + CRLF									//--ZO_DTCALC 
    _cQuery += "     	,'"+SubsTr(Time(),1,5)+"' 	AS HSCALC " + CRLF 							//--ZO_HSCALC 

    _cQuery += "   		,' '        AS  D_E_L_E_T_ " + CRLF
//    _cQuery += "  		,ROW_NUMBER() OVER (ORDER BY SZO.ZO_COD)     AS  R_E_C_N_O_ " + CRLF
//		Estava dando erro no update constraint
//    _cQuery += "  		,	(	SELECT NVL(MAX(SZO.R_E_C_N_O_),0)+1   " + CRLF
//    _cQuery += "  				FROM "+RetSqlName("SZO")+" SZO "+ CRLF 
//	_cQuery += " 			) AS  R_E_C_N_O_ "+ CRLF
    _cQuery += "  		,SB1.R_E_C_N_O_  " + CRLF

    _cQuery += " FROM "+RetSqlName("SB1")+" SB1 " + CRLF 
 //   _cQuery += " LEFT JOIN "+RetSqlName("SZO")+" SZO " + CRLF 	
//    _cQuery += "  	ON  SZO.ZO_FILIAL 	= '"+FwXFilial("SZO")+"' " + CRLF
//    _cQuery += "     AND SZO.ZO_COD 	= SB1.B1_COD " + CRLF
//    _cQuery += "     AND SZO.D_E_L_E_T_ = ' ' " + CRLF
    _cQuery += " LEFT JOIN "+RetSqlName("SBM")+" SBM " + CRLF 	
    _cQuery += "  	ON  SBM.BM_FILIAL 	= '"+FwXFilial("SBM")+"' " + CRLF
    _cQuery += "     AND SBM.BM_GRUPO 	= SB1.B1_GRUPO " + CRLF
    _cQuery += "     AND SBM.D_E_L_E_T_ = ' ' " + CRLF
    _cQuery += " LEFT JOIN	(	SELECT 	 B2_COD " + CRLF
    _cQuery += "  						,  SUM(NVL(B2_QATU,0)) AS SALDO_ESTOQUE " + CRLF
    _cQuery += "  						,( SUM(NVL(B2_VATU1,0)) / SUM(NVL(B2_QATU,0)) ) AS CUSTO_UNITARIO " + CRLF
    _cQuery += "  				FROM "+RetSqlName("SB2")+" SB2 " + CRLF 
    _cQuery += "  				WHERE 	SB2.D_E_L_E_T_ 	= ' ' "  + CRLF
    _cQuery += "  					AND SB2.B2_FILIAL BETWEEN '"+_cFilDe+"' AND '"+_cFilAte+"'  "+ CRLF
    _cQuery += "  					AND SB2.B2_QATU 	<> 0 " + CRLF
    _cQuery += "  				GROUP BY B2_COD " + CRLF
    _cQuery += "  			) SB2SQL " + CRLF
    _cQuery += "  			ON SB2SQL.B2_COD = SB1.B1_COD " + CRLF 
    _cQuery += "  LEFT JOIN (	SELECT 	SD1.D1_COD " + CRLF
    _cQuery += "  						,COALESCE( MIN(  SD1.D1_DTDIGIT),'        ' ) AS DT_PRIMCMP " + CRLF
    _cQuery += "  						,COALESCE( MAX(  SD1.D1_DTDIGIT),'        ' ) AS DT_ULTCMP " + CRLF
    _cQuery += "  				FROM "+RetSqlName("SD1")+" SD1 " + CRLF 
    _cQuery += "  				LEFT JOIN "+RetSqlName("SF4")+" SF4 " + CRLF 
    _cQuery += " 	 	   			ON  SF4.D_E_L_E_T_ 	= ' ' " + CRLF
    _cQuery += "  					AND SF4.F4_FILIAL 	= '"+FwXFilial("SF4")+"' " + CRLF 
    _cQuery += "     				AND SF4.F4_CODIGO  	= SD1.D1_TES " + CRLF
    _cQuery += "     				AND SF4.F4_ESTOQUE 	= 'S' " + CRLF
    _cQuery += "  				WHERE SD1.D_E_L_E_T_ 	= ' ' " + CRLF
    _cQuery += "  					AND SD1.D1_FILIAL BETWEEN '"+_cFilDe+"' AND '"+_cFilAte+"'  "+ CRLF
    _cQuery += "  					AND SD1.D1_CF IN "+ FormatIn(_cCFCompra,";") + " "+ CRLF
    _cQuery += "  				GROUP BY SD1.D1_COD " + CRLF
    _cQuery += "  			) SD1SQL " + CRLF												//--ZO_DTULCMP
    _cQuery += "  			ON SD1SQL.D1_COD = SB1.B1_COD " + CRLF
    _cQuery += "  LEFT JOIN (	SELECT SD2.D2_COD " + CRLF
    _cQuery += "  					,MIN(SD2.D2_EMISSAO) AS NF_PRIVND " + CRLF
    _cQuery += "  					,MAX(SD2.D2_EMISSAO) AS NF_ULTVND " + CRLF
    _cQuery += "  					,SUM(NVL(SD2.D2_VALBRUT,0))  AS TOT_FATURAMENTO " + CRLF
    _cQuery += "  					,SUM(NVL(SD2.D2_QUANT,0))  AS TOT_PECAS " + CRLF
    _cQuery += "  				FROM "+RetSqlName("SD2")+" SD2 " + CRLF 
    _cQuery += "  				WHERE SD2.D_E_L_E_T_ = ' ' "     + CRLF
    _cQuery += "  					AND SD2.D2_FILIAL BETWEEN  '"+_cFilDe+"' AND '"+_cFilAte+"'  "+ CRLF 
    _cQuery += "  					AND SD2.D2_CF IN "+ FormatIn(_cCFVenda,";") + " "+ CRLF"
    _cQuery += "  					AND D2_EMISSAO BETWEEN '"+DtOs(_dDataCurva - 365)+"' AND '"+DtOs(_dDataCurva)+ "' " 

    _cQuery += "  				GROUP BY SD2.D2_COD " + CRLF
    _cQuery += "  			) SD2SQLPRD " + CRLF
    _cQuery += "  			ON SD2SQLPRD.D2_COD = SB1.B1_COD " + CRLF 
	_cQuery += " WHERE SB1.B1_FILIAL 	= '"+FwXFilial("SB1")+"' "					+ CRLF 
	_cQuery += "    AND SB1.B1_MSBLQL 	= '2' "										+ CRLF
	_cQuery += "    AND SB1.B1_COD BETWEEN '" +_cProdutoDe+ "' AND '" +_cProdutoAte+ "' " + CRLF 
	If !Empty(_cMarca)
		_cQuery += "    AND SBM.BM_CODMAR = '"+_cMarca+"' "							+ CRLF
	Endif 
	_cQuery += "    AND SB1.D_E_L_E_T_ 	= ' ' "										+ CRLF
	_cQuery += " ORDER BY SB1.B1_COD "												+ CRLF

	_nStatus := TCSqlExec(_cQuery)
    If (_nStatus < 0)
        MsgStop("TCSQLError() " + TCSQLError(), "Registros Cabeçalho")
		_lRet := .F.
        Break    
    Endif

	_cTimeCalc := Time()
	
	_oSay:SetText("Aguarde atualizando registros ... Hora Inicial "+Time() )
	ProcessMessage()
	
	DbSelectArea(_cAliasPesq)
	(_cAliasPesq)->(DbGotop())
	//Count To _nRegProcess	
	//(_cAliasPesq)->(DbGotop())
	
	If (_cAliasPesq)->(Eof())
		_cMens := "Não foi Calculado Curva para nenhum item !"  
		MSGINFO(_cMens , "Atenção" )
		Break
	Endif
	_nCount := 0
	While (_cAliasPesq)->(!Eof())
		//_nCount ++
		//_oSay:SetText("Aguarde atualizando registros "+STRZero(_nCount,7)+" de "+STRZero(_nRegProcess,7)+" ... Hora Inicial "+Time() )

		//ProcessMessage()

		_lExclusive := !SZO->(DbSeek(FWxFilial("SZO")+(_cAliasPesq)->ZO_COD))
		If ! RecLock("SZO",_lExclusive)
			_cMens := "Não foi possivel INCLUIR item !"  
			MSGINFO(_cMens , "Atenção" )
			Break
		Endif
		For _nPos := 1 To Len(_aStruct)
			_xValor	:= (_cAliasPesq)->(FieldGet(FieldPos(_aStruct[_nPos])))
			SZO->(FieldPut(FieldPos(_aStruct[_nPos]), _xValor))
			If AllTrim(_aStruct[_nPos]) $ "ZO_MESPVEN|ZO_MESUVEN|ZO_MESPCMP|ZO_MESUCMP"
				If ZPECF040AV( _aStruct[_nPos], @_xValor, _dDataCurva)  //regravo caso exista alterações de dados
					SZO->(FieldPut(FieldPos(_aStruct[_nPos]), _xValor))
				Endif
			Endif
		Next
		SZO->(MSUnlock())
		//_ObrW:Refresh()
		(_cAliasPesq)->(DbSkip())
	EndDo	
	_ObrW:Refresh()
	If Select((_cAliasPesq)) <> 0
		(_cAliasPesq)->(DbCloseArea())
		//Ferase(_cTable+GetDBExtension())
   		 _oTable:Delete()
	Endif      

	DbSelectArea("SZO")
	//TCRefresh("SZO")
    SZO->(DbGoTop())
	If SZO->(Eof())
		MSGINFO( "Não existe dados para a Geração da Curva ABC !", "Atenção" )
		_lRet := .F.
		Break
	Endif
	_cHoraFim := Time()
	MSGINFO( "Termino do processamento iniciado as : "+_cHoraIni+" Calculado em "+_cTimeCalc+" finalizado as "+_cHoraFim+" !", "Atenção" )
End Sequence
/*
If Select(_cAliasPesq) <> 0
	(_cAliasPesq)->(DbCloseArea())
	Ferase(_cAliasPesq+GetDBExtension())
Endif
*/  
DbSelectArea("SZO")
//_ObrW:Refresh(.T.)
Return Nil


//Funcionalidade responsável por ajustar meses referente ao tempo que foi realizado compra/venda a base de calculo
Static Function ZPECF040AV( _cCampo, _xValor, _dDataCurva)
Local _nMes := 0
Local _lRet := .T.
Begin Sequence
	If !AllTrim(_cCampo) $ "ZO_MESPVEN|ZO_MESUVEN|ZO_MESPCMP|ZO_MESUCMP"
		_lRet := .F.
		Break
	Endif 
	If AllTrim(_cCampo) == "ZO_MESPVEN" .And. !Empty( SZO->ZO_DTPRVND )
		_nMes := DateDiffMonth( _dDataCurva , SZO->ZO_DTPRVND ) +1 //Apura Diferenca em Meses entre duas Datas(_cAliasPesq)->DT_PRI_FAT    
		If _xValor <> _nMes
			_xValor := _nMes
			Break
		Endif	
	ElseIf AllTrim(_cCampo) == "ZO_MESUVEN" .And. !Empty( SZO->ZO_DTULVND )
		_nMes := DateDiffMonth( _dDataCurva , SZO->ZO_DTULVND ) +1  //Apura Diferenca em Meses entre duas Datas(_cAliasPesq)->DT_PRI_FAT    
		If _xValor <> _nMes
			_xValor := _nMes
			Break
		Endif	
	ElseIf AllTrim(_cCampo) == "ZO_MESPCMP" .And. !Empty( SZO->ZO_DTPRCMP )
		_nMes := DateDiffMonth(_dDataCurva , SZO->ZO_DTPRCMP ) +1  //Apura Diferenca em Meses entre duas Datas(_cAliasPesq)->DT_PRI_FAT    
		If _xValor <> _nMes
			_xValor := _nMes
			Break
		Endif	
	ElseIf AllTrim(_cCampo) == "ZO_MESUCMP" .And. !Empty( SZO->ZO_DTULCMP )
		_nMes := DateDiffMonth( _dDataCurva , SZO->ZO_DTULCMP) +1 //Apura Diferenca em Meses entre duas Datas(_cAliasPesq)->DT_PRI_FAT    
		If _xValor <> _nMes
			_xValor := _nMes
			Break
		Endif	
	Endif
	_lRet := .F.
End Sequence 
Return _lRet 


/*
---------------------------------------------------------------------
Geração da Planilha com os dados da Consulta.
---------------------------------------------------------------------
*/
/*/{Protheus.doc} User Function ZPECF40PL_PlanilhaCurvaABC
Gera planilha do browse curva ABC
@param  	
@author 	DAC - Denilso
@version  	P12.1.33
@since  	28/09/2023
@return  	NIL
@obs        
@project    GAP014 | Cálculo da Curva ABC
			PEC057 - Cálculo da Curva ABC
@history    
/*/
Static Function ZPECF40PL_PlanilhaCurvaABC( _oSay )
Local _lRet 		:= .T.
Local _cSheet 		:= "Curva ABC"
Local _cTable 		:= "CURVA ABC"
Local _cDir   		:=  ""
Local _cNomeArqXML	:= "ZPECF040 Curva ABC"+DtoS(Date())+SubsTr(Time(),1,2)+SubsTr(Time(),4,2)
Local _nColunas 	:= 0
Local _lTotalizar 	:= .F.
Local _cType 		:= OemToAnsi("Todos") + "(*.*) |*.*|"
Local _aLinha		:= {}
Local _nRegProcess	:= 0
Local _nReg 		:= SZO->(Recno())
Local _cAliasPesq   := GetNextAlias()

Local _oExcel
Local _oFwExcel
//Local _nUltimoReg
Local _cTipo
Local _nPos
Local _nCount 
Local _cArqXML

Begin Sequence
	If _oBrw:LogicLen() <= 0
		Break
	EndIf

	If !MsgYesNo("Deseja gerar arquivo em Excel para Curva ABC ?") 
		Break 
	Endif 

	//Selecionar pasta para geração
	_cDir := cGetFile(_cType, OemToAnsi("Selecione a Pasta "), 0,, .T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY)
	//³ Parametro: GETF_LOCALFLOPPY - Inclui o floppy drive local.   ³
	//³            GETF_LOCALHARD - Inclui o Harddisk local.         ³
	If Empty(_cDir)
		MSGInfo("Necessário informar uma pasta para a geração do arquivo  !","ATENCAO")
		Break
	Endif
	_cArqXML := _cDir + If(SubsTr(_cDir,Len(_cDir),1) <> "\","\","")+_cNomeArqXML
	If File(_cArqXML+".xml")
		If !MsgYesNo("Arquivo ja existe deseja sobrepor "+_cArqXML+".xml ?") 
			_lRet := .F.
			Break 
		Endif 
		If Ferase(_cArqXML+".xml") == -1	
			MSGInfo("Não foi possivel apagar arquivo "+_cArqXML+"  !","ATENCAO")
			_lRet := .F.
			Break
		EndIf
	Endif

	_oSay:SetText( "Verificando registros aguarde..." ) 
	ProcessMessage()
	_oFwExcel := FWMSEXCEL():New()
	_oFwExcel:AddworkSheet(_cSheet)
	_oFwExcel:AddTable(_cSheet,_cTable)


	BeginSql Alias _cAliasPesq //Define o nome do alias temporário 
		SELECT 	NVL(SZO.R_E_C_N_O_,0) NREGSZO
		FROM  	%Table:SZO% SZO
		WHERE 	SZO.ZO_FILIAL 	= %xFilial:SZO%
		ORDER BY SZO.ZO_COD	
	EndSql
	If (_cAliasPesq)->(Eof()) .or. (_cAliasPesq)->NREGSZO == 0
		MSGInfo("Não Existem Registros para gerar Planilha  !","ATENCAO")
		Break
	Endif


	DbSelectArea(_cAliasPesq)
	(_cAliasPesq)->(DbGotop())
	Count To _nRegProcess	
	(_cAliasPesq)->(DbGotop())

	//montar o cabeçalho
	_nColunas	:= Len(_oBrw:aColumns)
	_lTotalizar := .F.
	lExit := .F.
	For _nPos := 1 to _nColunas
		_cTipo      := _oBrw:GetColumn(_nPos):GetType()
		_oFwExcel:AddColumn( ;
						_cSheet, ;
						_cTable , ;
						_oBrw:GetColumn(_nPos):GetTitle() , ;
												If( _cTipo == "N" , 3 , 1 ) , ; // Alinhamento da coluna ( 1-Left,2-Center,3-Right )
												If( _cTipo == "N" , 2 , If(_cTipo == "D" ,4 ,1) ) , ; // Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
												_lTotalizar )
	Next _nPos

	_oBrw:GoTop()
	_nUltimoReg	:= _oBrw:LogicLen()
	_nReg 		:= _oBrw:At()
	_oBrw:GoTop()
	lExit := .F.

	For _nPos := 1 To _nUltimoReg
		_aLinha := Aclone(Array(_nColunas))
		For _nCount := 1 To Len(_aLinha)
			//cIdField := oBrwPEC23:GetColumn(nPosCol):GetID()
			_aLinha[_nCount] := AllTrim(_oBrw:GetColumnData(_nCount))
		Next _nCount
		_oFwExcel:AddRow(_cSheet ,_cTable, _aLinha) 
		_oSay:SetText( "Lendo Registo " +cValToChar(_nPos) + " de "+cValToChar(_nUltimoReg)+" aguarde..." ) 
		ProcessMessage()
		_oBrw:GoDown()
		If lExit
			Exit
		Endif
	Next _nPos
	_oSay:SetText( "Gravando Planilha com "+cValToChar(_nUltimoReg)+" registro(s) aguarde..." ) 
	ProcessMessage()
	_oFwExcel:AddRow(_cSheet ,_cTable, _aLinha) 
	_oFwExcel:Activate()
	_oFwExcel:GetXMLFile(AllTrim(_cArqXML)+".xml")
	_oFwExcel:DeActivate()
	_oBrw:GoTo( _nReg, .T. )
	FreeObj(_oFwExcel)

	// Abrindo o excel e abrindo o arquivo xml.
	_oSay:SetText( "Abrindo Planilha com "+cValToChar(_nUltimoReg)+" registro(s) aguarde..." ) 
	ProcessMessage()
	_oExcel := MsExcel():New()           // Abre uma nova conex„o com Excel.
	_oExcel:WorkBooks:Open(_cArqXML+".xml")     // Abre uma planilha.
	_oExcel:SetVisible(.T.)              // Visualiza a planilha.
	_oExcel:Destroy()                    // Encerra o processo do gerenciador de tarefas.
End Sequence 
SZO->(DbGoto(_nReg))
_oBrw:Refresh()
Return _lRet 



/*/{Protheus.doc} MenuDef
Inclusão dados no menu 		
@author 	DAC
@since 		15/07/2023
@version 	undefined
@param 		
@type 		Static function
@ Obs		
@history    
/*/
Static Function MenuDef()
Local _aRotina := {}
	ADD OPTION _aRotina TITLE 'Visualizar'     ACTION 'VIEWDEF.ZPECF040' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
	//ADD OPTION _aRotina TITLE 'Visualizar' 		ACTION 'VIEWDEF.GenToCad' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 2
Return _aRotina


/*/{Protheus.doc} MenuModelDefDef
Modelo de Dados 		
@author 	DAC
@since 		15/07/2023
@version 	undefined
@param 		
@type 		Static function
@ Obs		
@history    
/*/
Static Function ModelDef()
    Local oModel    := Nil
    Local _oStruSZO  := FWFormStruct(1, "SZO")
	oModel := FWModelActive()
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('ZPF40MDL',  /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'SZOMASTER', /*cOwner*/, _oStruSZO, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	// Adiciona a descricao do Modelo de Dados
    oModel:SetDescription("Curva ABC CAOA")
	// Adiciona a descricao do Componente do Modelo de Dados
    oModel:GetModel("SZOMASTER"):SetDescription("Curva ABC CAOA")
	//oModel:SetPrimaryKey({'ZO_FILIAL', 'ZO_CODIGO' })
    oModel:SetPrimaryKey({})
	/*
	If oModel:IsActive() 
		oModel:DeActivate() 
	EndIf
	oModel:Activate()
	*/
Return oModel


/*/{Protheus.doc} ViewDef
View 		
@author 	DAC
@since 		15/07/2023
@version 	undefined
@param 		
@type 		Static function
@ Obs		
@history    
/*/
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    Local oModel        := ModelDef()
	// Cria a estrutura a ser usada na View
    Local _oStruSZO     := FWFormStruct(2, "SZO")
    Local oView         := Nil

    //-- Cria View e seta o modelo de dados
    oView := FWFormView():New()
    oView:SetModel(oModel)
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('VIEW_SZO',_oStruSZO,'SZOMASTER')

    //-- Seta o dimensionamento de tamanho
    oView:CreateHorizontalBox('BOX_SZO',100)
    //--Amarra a view com as box
    oView:SetOwnerView('VIEW_SZO','BOX_SZO')
	//-- Define os títulos do cabeçalho
    oView:EnableTitleView('VIEW_SZO', "Curva ABC CAOA") 
Return oView



/*
INSERT INTO ABDHDU_PROT.SZO020
 ( 	ZO_FILIAL
 	, ZO_COD
 	, ZO_DESCPRD
 	, ZO_MARCA
 	, ZO_CURVQTD
 	, ZO_CURVCUS
	, ZO_SALDOES
 	, ZO_CUSTUNI
 	, ZO_CUSTTOT
 	, ZO_DTPRDCA
 	, ZO_DTULCMP
 	, ZO_DTULVND
 	, ZO_TOTVEND
 	, ZO_MEDIADE
 	, ZO_MOS
 	, ZO_EXQTDE
 	, ZO_EXCUSTO
 	, ZO_DTBASEC
 	, ZO_CODUSU
 	, ZO_DTCALC
 	, ZO_HSCALC
 	,  D_E_L_E_T_
 	, R_E_C_N_O_  ) 
WITH 
	MES_PONTOS AS(    
   		 SELECT SD2.D2_COD
    		, CASE 
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 <=  12 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	
    			THEN NVL(SUM(SD2.D2_QUANT),0)    
    			ELSE 0
			  END AS TOT_QTDECURVA
   		 --,SD2.D2_EMISSAO AS DT_NF_SAIDA
			--,SUM(NVL(SD2.D2_QUANT,0))  AS TOT_QTDE
			, MAX(TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1) AS MESES
    		, CASE 
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  01 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 18    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  02 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 17    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  03 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 16    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  04 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 15    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  05 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 14    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  06 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 13    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  07 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 12    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  06 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 11    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  09 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 10    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  10 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 09    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  11 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 08    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 =  12 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 07    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 <= 24 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 240    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 <= 36 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 360    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 <= 48 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 480    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 <= 60 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 600    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 <= 72 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 720    	
    			WHEN TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))+1 >  72 AND SUM(NVL(SD2.D2_QUANT,0)) >0 	THEN 990    	
   			ELSE 0
    		END PONTOS
    	FROM ABDHDU_PROT.SD2020  SD2 
		WHERE SD2.D_E_L_E_T_ = ' ' 
			AND SD2.D2_FILIAL BETWEEN '          ' AND 'ZZZZZZZZZZ' 
			AND SD2.D2_CF IN ('5102','5152','5403','6102','6110','6403')
			AND SD2.D_E_L_E_T_  = ' ' 
			--AND SD2.D2_COD =    'R-224412E000' 
			GROUP BY D2_COD , TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(D2_EMISSAO, 'YYYYMMDD')))
    		ORDER BY D2_COD
 		),
	MEDIAS AS (  
		SELECT   MES_PONTOS.D2_COD
				, SUM(MES_PONTOS.TOT_QTDECURVA) 					AS TOT_CURVA 
				, (SUM(MES_PONTOS.TOT_QTDECURVA) / 12) 				AS DEMANDA_MEDIA
				, AVG(SB2JOIN.SALDO_ESTOQUE)  						AS SALDO_ESTOQUE 
				, AVG(SB2JOIN.CUSTO_UNITARIO) 						AS CUSTO_UNITARIO 
		FROM MES_PONTOS
		LEFT JOIN	(	SELECT 	 B2_COD 
 						,  SUM(NVL(B2_QATU,0)) AS SALDO_ESTOQUE 
 						,( SUM(NVL(B2_VATU1,0)) / SUM(NVL(B2_QATU,0)) ) AS CUSTO_UNITARIO 
 				FROM ABDHDU_PROT.SB2020 SB2
 				WHERE 	SB2.D_E_L_E_T_ 	= ' ' 
 					AND SB2.B2_FILIAL BETWEEN '          ' AND 'ZZZZZZZZZZ'
 					AND SB2.B2_QATU 	<> 0 
 				GROUP BY B2_COD 
 			) SB2JOIN 
 			ON SB2JOIN.B2_COD = MES_PONTOS.D2_COD 
		WHERE MES_PONTOS.MESES <= 12
			AND NVL(MES_PONTOS.TOT_QTDECURVA,0) > 0
			--AND MES_PONTOS.D2_COD =    'R-224412E000'
		GROUP BY MES_PONTOS.D2_COD 
		)
SELECT  '2020'  														--ZO_FILIAL
		,SB1.B1_COD	    												--ZO_COD
		,SB1.B1_DESC    AS DESCRICAO									--ZO_DESCPRD
		,COALESCE(SBM.BM_CODMAR,' ')	AS MARCA										--ZO_MARCA
		, (	SELECT CASE 
					WHEN NVL(MIN(MES_PONTOS.MESES),0) <= 12 AND NVL(SUM(MES_PONTOS.PONTOS),0) BETWEEN  101 AND 150 	THEN 'A'
					WHEN NVL(MIN(MES_PONTOS.MESES),0) <= 12 AND NVL(SUM(MES_PONTOS.PONTOS),0) BETWEEN  51  AND 100 	THEN 'B'
					WHEN NVL(MIN(MES_PONTOS.MESES),0) <= 12 AND NVL(SUM(MES_PONTOS.PONTOS),0) BETWEEN  7   AND 50  	THEN 'C'
					WHEN COALESCE(SB1.B1_XDTINC,' ') <> ' '  
						AND TRUNC(MONTHS_BETWEEN(TO_DATE('20230531', 'YYYYMMDD'), TO_DATE(SB1.B1_XDTINC, 'YYYYMMDD'))) <= 12
						AND NVL(SUM(MES_PONTOS.PONTOS),0) = 0  														THEN 'N'  --No periodo de 1 ano a partir da data de cadastro não possuir nenhuma venda
					WHEN NVL(MIN(MES_PONTOS.MESES),0) <= 24 AND NVL(SUM(MES_PONTOS.PONTOS),0) > 150  				THEN 'D'
					WHEN NVL(MIN(MES_PONTOS.MESES),0) <= 36 AND NVL(SUM(MES_PONTOS.PONTOS),0) > 150  				THEN 'E'
					WHEN NVL(MIN(MES_PONTOS.MESES),0) <= 48 AND NVL(SUM(MES_PONTOS.PONTOS),0) > 150  				THEN 'F'
					WHEN NVL(MIN(MES_PONTOS.MESES),0) <= 60 AND NVL(SUM(MES_PONTOS.PONTOS),0) > 150					THEN 'G'
					WHEN NVL(MIN(MES_PONTOS.MESES),0) <= 72 AND NVL(SUM(MES_PONTOS.PONTOS),0) > 150					THEN 'H'
					WHEN NVL(MIN(MES_PONTOS.MESES),0) >  72    											 			THEN 'I'
				ELSE 'I'
				END 	
			FROM MES_PONTOS
			WHERE MES_PONTOS.D2_COD =  SB1.B1_COD
			) AS  CURVA_PONTOS											--ZO_CURVQTD
		, COALESCE( ( 	SELECT TRIM(SX5.X5_CHAVE) 
						FROM ABDHDU_PROT.SX5020 SX5 
						WHERE SX5.D_E_L_E_T_ 	= ' ' 
							AND SX5.X5_FILIAL 	= '          ' 
  							AND SX5.X5_TABELA   = '2C'
  							AND (SB2SQL.SALDO_ESTOQUE * SB2SQL.CUSTO_UNITARIO) BETWEEN TO_NUMBER(SX5.X5_DESCSPA) AND TO_NUMBER(SX5.X5_DESCENG)
        	  		) ,' ') AS CURVA_VALORES 							--ZO_CURVCUS
  		, TRUNC(NVL(SB2SQL.SALDO_ESTOQUE,0)) AS SALDO_ESTOQUE 			--ZO_SALDOES 
 		, NVL(SB2SQL.CUSTO_UNITARIO,0)      AS CUSTO_UNITARIO 			--ZO_CUSTUNI
 		, NVL(SB2SQL.SALDO_ESTOQUE * SB2SQL.CUSTO_UNITARIO, 0)	AS CUSTO_TOTAL		--ZO_CUSTTOT
 		, COALESCE(B1_XDTINC,' ')  AS DT_CAD_PRD						--ZO_DTPRDCA  DATA da inclusão cadastro SB1
	    , 	CASE 
	    		WHEN COALESCE(SD1SQL.DT_ULTCMP,' ') <> ' ' 	THEN SD1SQL.DT_ULTCMP
	    		WHEN COALESCE(SB1.B1_XUCLEG,' ') 	<> ' '	THEN SB1.B1_XUCLEG			--Ultima Compra Legado
	    	ELSE ' '
	    	END AS DT_ULT_CMP														--ZO_DTULCMP
	    , 	CASE 
	    		WHEN COALESCE(SD2SQLPRD.DT_NF_SAIDA,' ') 	<> ' ' 	THEN SD2SQLPRD.DT_NF_SAIDA
	    		WHEN COALESCE(SB1.B1_XUVLEG,' ') 			<> ' '	THEN SB1.B1_XUVLEG			--Ultima Venda Legado
	    	ELSE ' '
	    	END AS DT_ULT_CMP														--ZO_DTULVND
	    , NVL(SD2SQLPRD.TOT_FATURAMENTO,0) AS TOT_FATURAMENTO						--ZO_TOTVEND	
		, NVL( (SELECT MEDIAS.DEMANDA_MEDIA 
				FROM MEDIAS
				WHERE MEDIAS.D2_COD = SB1.B1_COD),0) 	AS DEMANDA_MEDIA			--ZO_MEDIADE
		, NVL( (SELECT NVL(MEDIAS.SALDO_ESTOQUE / MEDIAS.DEMANDA_MEDIA,0) 
				FROM MEDIAS
				WHERE MEDIAS.D2_COD = SB1.B1_COD),0) AS MOS							--ZO_MOS
		, NVL( (SELECT NVL(SB2SQL.SALDO_ESTOQUE / MEDIAS.DEMANDA_MEDIA,0 ) - 12 *	MEDIAS.DEMANDA_MEDIA 
				FROM MEDIAS
				WHERE MEDIAS.D2_COD = SB1.B1_COD),0)  AS EXCESSO_QTDE				--ZO_EXQTDE
		, NVL( (SELECT (NVL(SB2SQL.SALDO_ESTOQUE / MEDIAS.DEMANDA_MEDIA,0 ) - 12 *	MEDIAS.DEMANDA_MEDIA) * MEDIAS.CUSTO_UNITARIO
				FROM MEDIAS
				WHERE MEDIAS.D2_COD = SB1.B1_COD),0)  AS CUSTO_EXCESSO				--ZO_EXCUSTO 
    	,'20230531' AS ZO_DTBASEC
    	,'000390' 	AS ZO_CODUSU 
    	,'20230619' AS ZO_DTCALC 
    	,'17:58' 	AS ZO_HSCALC 
  		,' '        AS  D_E_L_E_T_ 
 		,ROW_NUMBER() OVER (ORDER BY B1_COD)     AS  R_E_C_N_O_ 
FROM ABDHDU_PROT.SB1020 SB1
LEFT JOIN ABDHDU_PROT.SBM020 SBM 	--
 	ON  SBM.BM_FILIAL 	= '202001    ' 
    AND SBM.BM_GRUPO 	= SB1.B1_GRUPO 
    AND SBM.D_E_L_E_T_ 	= ' ' 
LEFT JOIN	(	SELECT 	 B2_COD 
 						,  SUM(NVL(B2_QATU,0)) AS SALDO_ESTOQUE 
 						,( SUM(NVL(B2_VATU1,0)) / SUM(NVL(B2_QATU,0)) ) AS CUSTO_UNITARIO 
 				FROM ABDHDU_PROT.SB2020 SB2
 				WHERE 	SB2.D_E_L_E_T_ 	= ' ' 
 					AND SB2.B2_FILIAL BETWEEN '          ' AND 'ZZZZZZZZZZ'
 					AND SB2.B2_QATU 	<> 0 
 				GROUP BY B2_COD 
 			) SB2SQL 
 			ON SB2SQL.B2_COD = SB1.B1_COD 
 LEFT JOIN (	SELECT 	SD1.D1_COD
 						,COALESCE( MAX(  SD1.D1_DTDIGIT),'        ' ) AS DT_ULTCMP 
 				FROM ABDHDU_PROT.SD1020 SD1 
 				LEFT JOIN ABDHDU_PROT.SF4020 SF4 
	 	   			ON  SF4.D_E_L_E_T_ 	= ' ' 
 					AND SF4.F4_FILIAL 	= '202001    ' 
    				AND SF4.F4_CODIGO  	= SD1.D1_TES 
    				AND SF4.F4_ESTOQUE 	= 'S' 
 				WHERE SD1.D_E_L_E_T_ 	= ' ' 
 					AND SD1.D1_FILIAL BETWEEN '          ' AND 'ZZZZZZZZZZ' 
 					--AND SD1.D1_COD 		= SB1.B1_COD 
 					AND SD1.D1_CF IN ('1102','2102','3102') 
 				GROUP BY SD1.D1_COD
 			) SD1SQL 												--ZO_DTULCMP
 			ON SD1SQL.D1_COD = SB1.B1_COD 
 LEFT JOIN (	SELECT SD2.D2_COD
 					,MAX(SD2.D2_EMISSAO) AS DT_NF_SAIDA
 					,SUM(NVL(SD2.D2_VALBRUT,0))  AS TOT_FATURAMENTO
 				FROM ABDHDU_PROT.SD2020  SD2
 				WHERE SD2.D_E_L_E_T_ = ' '
 					AND SD2.D2_FILIAL BETWEEN  '          ' AND 'ZZZZZZZZZZ' 
 					AND SD2.D2_CF IN ('5102','5152','5403','6102','6110','6403')
 				GROUP BY SD2.D2_COD
 			) SD2SQLPRD 
 			ON SD2SQLPRD.D2_COD = SB1.B1_COD 
WHERE SB1.D_E_L_E_T_ = ' ' 
--AND SB1.B1_COD =    'R-224412E000' 
ORDER BY SB1.B1_COD

COMMIT;

*/
