#Include "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#include "TOTVS.ch"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "FWBROWSE.CH"
#Include "FWMVCDEF.CH"

#define CRLF chr(13) + chr(10)  

Static  _cAlias := ""
Static  _cTable := ""

/*/{Protheus.doc} ZPECAJ01
Ajuste da tabela ZD1 e saldos do armazem recebimento e Padrão 
@author     DAC - Denilso 
@since      02/06/2023
@version    1.0
/*/

User Function ZPECAJ01()
Local _aSays	    := {}
Local _aButtons	    := {}
Local _cCadastro    := OemToAnsi("Ajuste tabela Separação ZD1")   
Local _cTitle  	    := OemToAnsi("Ajusta armazém de Separação e Padrão")   
Local _aPar    	    := {}
Local _aRet    	    := {}
Local _nRet			:= 0
Local _cCodProdDe	:= Space(TamSx3("B1_COD")[1]) 
Local _cCodProdAte	:= Space(TamSx3("B1_COD")[1]) 
Local _cChave		:= AllTrim(FWCodEmp())+"ZPECAJ01"
Local _lRet			:= .T.
Local _oSay
Local _nPos

Begin Sequence
	_lRet := U_ZGENUSER( RetCodUsr() ,"ZPECAJ01" ,.T.)	
	If !_lRet
		Break
	EndIf
	IF !( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
		Help( , ,OemToAnsi("Atenção"),,OemToAnsi("Esta rotina não é valida para esta empresa"),4,1)   
	    Break
	ENDIF
	//Garantir que o processamento seja unico
	If !LockByName(_cChave,.T.,.T.)  
		//tentar locar por 10 segundos caso não consiga não prosseguir
		_lRet := .F.
		For _nPos := 1 To 10
			Sleep( 3000 ) // Para o processamento por 3 segundos
			If LockByName("ZPCPJ001",.T.,.T.)
				_lRet := .T.
			EndIf
		Next		
		If !_lRet
			MSGINFO("Já existe um processamento em execução rotina ZFATJ001, aguarde!", "[ZPECAJ01] - Atenção" )
			Break
		EndIf
	EndIf

	aAdd(_aPar,{1,OemToAnsi("Produto de   : ") ,_cCodProdDe			,"@!"		,".T."	,"SB1" 	,".T."	,100,.F.}) 
	aAdd(_aPar,{1,OemToAnsi("Produto ate  : ") ,_cCodProdAte		,"@!"		,".T."	,"SB1"	,".T."	,100,.F.}) 
	//aAdd(_aPar,{3,OemToAnsi("Atualiza Base: ") ,2 ,{"SIM","NAO"}	,80,"",.F.})  

	// Monta Tela principal
	aAdd(_aSays,OemToAnsi("Este Programa tem  como  Objetivo de ajustar a tabela de confirmação")) 
	aAdd(_aSays,OemToAnsi("de conferência (ZD1).")) 
	aAdd(_aSays,OemToAnsi("Bem como fazer ajustes nos saldos dos armazéns de conferências contidos")) 
	aAdd(_aSays,OemToAnsi("Armazem 80 e 90, e também fazer ajustes nos saldos do Padrão relativos aos")) 
	aAdd(_aSays,OemToAnsi("armazens 01 e 11.")) 
	aAdd(_aSays,OemToAnsi("Esta rotina não poderá ser utilizada sem autorização prévia dos responsáveis !")) 

	aAdd(_aButtons, { 1,.T.,{|o| FechaBatch(),_nRet:=1											}})
	aAdd(_aButtons, { 2,.T.,{|o| FechaBatch()													}})
	aAdd(_aButtons, { 5,.T.,{|o| ParamBox(_aPar,_cTitle,@_aRet,,,.T.,,,,"ZPECAJ1",.T.,.T.) 			}})

	FormBatch( _cCadastro, _aSays, _aButtons )
	If _nRet <> 1
		Break
	Endif
	If Len(_aRet) == 0
		Help( , ,OemToAnsi("Atenção"),,OemToAnsi("Necessário informar os parâmetros"),4,1)   
		Break 
	Endif
	FwMsgRun(,{ |_oSay| ZPECAJ01PR(_aRet, @_oSay ) }, "Ajuste armazém de Recebimento ZD1", "Aguarde...")  //Separação Orçamentos / Aguarde
	//Libera para utilização de outros usuarios
	UnLockByName(_cChave,.T.,.T.)
End Sequence
Return Nil


Static Function ZPECAJ01PR(_aRet, _oSay)
Local _cCodProdDe   := _aRet[01]
Local _cCodProdAte  := _aRet[02]
Local _aStru		:= {}
Local _aCampos		:= {}
Local _cTitulo		:= "Itens a serem ajustados Tabela ZD1"
Local _nPos
Local _ObrW

Begin SEQUENCE
	//Cria Bco temporario
	ZPECAJ01TB(@_aStru)  
	If Empty(_cAlias)
		MSGINFO( "Não foi possivel criar banco temporario", "Atenção" )
		Break
	Endif
	_oSay:SetText("Montando tabela para dados")
	ProcessMessage() 
	//Preparar strutura do FWMBrowse
	_aCampos := {}
    For _nPos := 1 To Len(_aStru)
		If _aStru[_nPos,Len(_aStru[_nPos])]  //Valida se a coluna irá para o Browse
            Aadd(_aCampos,{ _aStru[_nPos,2],;             //titulo
                            _aStru[_nPos,1],;             //campo
                            _aStru[_nPos,3],;             //tipo
                            _aStru[_nPos,4],;             //tamanho    
                            _aStru[_nPos,5],;             //decimal
                            _aStru[_nPos,6];              //pict
                        	})
        Endif
    Next
	_oSay:SetText("Aguarde... Selecionando dados")
	ProcessMessage() 
	If !ZPECAJ01QU(_aStru, _cCodProdDe, _cCodProdAte)
		Break
	Endif

	DbSelectArea (_cAlias)
	//Count To _nRegProcess
    (_cAlias)->(DbGoTop())
	_ObrW := FWMBrowse():New()
	_ObrW:SetCanSaveArea(.T.)	//abertura de mais de uma  browse
	_ObrW:SetTemporary(.T.)
    _oBrw:SetAlias(_cAlias)	
	_ObrW:SetMenuDef('')
	_ObrW:SetFields(_aCampos)
    _ObrW:SetIgnoreARotina(.T.) // Indica que a mbrowse, ira ignorar a variavel private aRotina na construção das opções de menu.
    _ObrW:SetWalkThru(.F.)
    _ObrW:DisableConfig() // Desabilita a utilização do Browse
    _ObrW:SetAmbiente(.F.) //Habilita a utilização da funcionalidade Ambiente no Browse
    _ObrW:SetFixedBrowse(.T.)
	_ObrW:DisableDetails()

	//Definimos o título que será exibido como método SetDescription
	_ObrW:SetDescription(_cTitulo)

	_ObrW:AddLegend("STATUS = ' ' "  ,"WHITE" 	   	,"Não Processado")
	_ObrW:AddLegend("STATUS = 'P' "  ,"BLUE" 	   	,"Processado Sem Erros")
	_ObrW:AddLegend("STATUS = 'E'"   ,"RED"   		,"Processado Com  Erros")

//	_ObrW:bLDblClick 	:=  {|| ZPECAJ01AV(_ObrW,.F.), _ObrW:Refresh(.T.) } 
//		oBrowse:bLDblClick 	:= {|| ZPECAJ01AV(_ObrW:nAt,01][14],.F.) }                               
	//_ObrW:AddButton("Atualizar Saldos"  	, { || ZPECAJ01AV(@_ObrW)  },,,, .F., 2 )  //função no ZPECFUNA
	_ObrW:bLDblClick 	:=  {|| FwMsgRun(,{ | _oSay | ZPECAJ01AV(_ObrW,.F., @_oSay) }, "Ajustustando armazém de Recebimento ZD1", "Aguarde..."), _ObrW:Refresh(.T.) } 
	_ObrW:AddButton("Atualizar Saldos"  	, { || FwMsgRun(,{ | _oSay | ZPECAJ01AV(_ObrW, ,@_oSay) }, "Ajustustando armazém de Recebimento ZD1", "Aguarde...")  },,,, .F., 2 )  //função no ZPECFUNA
   
  			  
 
   
   //Ativamos a classe
    _ObrW:Refresh(.T.)
	_ObrW:Activate()
End SEQUENCE
Return Nil


//Monta query e tabela pra Browse
Static Function ZPECAJ01QU(_aStru, _cCodProdDe, _cCodProdAte)
Local _cQuery 	:= ""
Local _lRet		:= .T.
Local _nPos
Local _nStatus

Begin SEQUENCE
    _cQuery := " INSERT INTO "+_cTable+"                                                                                    "+(Chr(13)+Chr(10))
    _cQuery += " ("
    For _nPos := 01 To Len(_aStru)
		If _aStru[_nPos,Len(_aStru[_nPos])]  //Valida se a coluna irá para o Browse
	        _cQuery += _aStru[_nPos,1]
    	    _cQuery += ", "
		Endif
    NEXT _nPos
    _cQuery += " D_E_L_E_T_, R_E_C_N_O_ "   //campos que não aparecem no browse e devem ser preenchidos
    _cQuery += " )"+ CRLF
    _cQuery += "SELECT DISTINCT " + CRLF
	_cQuery += "	ZD1.ZD1_DOC"+ CRLF
	_cQuery += "	,ZD1.ZD1_SERIE"+ CRLF
	_cQuery += "	,ZD1.ZD1_FORNEC"+ CRLF
	_cQuery += "	,ZD1.ZD1_LOJA"+ CRLF
	_cQuery += "	,ZD1.ZD1_COD"+ CRLF
	_cQuery += "	,SB2.B2_LOCAL"+ CRLF
	_cQuery += "	,ZD1.ZD1_QUANT"+ CRLF
	_cQuery += "	,ZD1.ZD1_QTCONF"+ CRLF
	_cQuery += "	,ZD1.ZD1_SLDIT"+ CRLF
	_cQuery += "	,SB2.B2_QATU SLDB2REC"+ CRLF
	//_cQuery += "	,COALESCE(TMPSD3.SLD,0) QTDINTEG"+ CRLF
	_cQuery += "	,COALESCE(TMPWISARM.QTDE,0) TOT_ARMAZENADA_WIS"+ CRLF 
	_cQuery += "	,COALESCE(tMPWISARM.QTDE-ZD1.ZD1_QTCONF,0) DIFERENCA"+ CRLF
	_cQuery += "	,CASE "+ CRLF
	_cQuery += "		WHEN COALESCE(tMPWISARM.QTDE-ZD1.ZD1_QTCONF,0) > 0 "+ CRLF
	_cQuery += "		THEN COALESCE(tMPWISARM.QTDE-ZD1.ZD1_QTCONF,0)+ZD1.ZD1_QTCONF "+ CRLF
	_cQuery += "	END  AS UPD_QTCONF "+ CRLF

	_cQuery += "	,CASE "+ CRLF
	_cQuery += "		WHEN COALESCE(tMPWISARM.QTDE-ZD1.ZD1_QTCONF,0) > 0 "+ CRLF
	_cQuery += "		THEN ZD1.ZD1_QUANT - (COALESCE(tMPWISARM.QTDE-ZD1.ZD1_QTCONF,0)+ZD1.ZD1_QTCONF) "+ CRLF
	_cQuery += "		ELSE ZD1.ZD1_QUANT "+ CRLF
	_cQuery += "	END  AS UPD_SLDIT "+ CRLF
	//_cQuery += "	,COALESCE(ZD1_QUANT - (TMPWISARM.QTDE-ZD1.ZD1_QTCONF),0) UPD_SLDIT"+ CRLF
	
	_cQuery += "	,CASE "+ CRLF
	_cQuery += "		WHEN SB2.B2_QATU < COALESCE(tMPWISARM.QTDE-ZD1.ZD1_QTCONF,0) "+ CRLF
	_cQuery += "		THEN SB2.B2_QATU "+ CRLF
	_cQuery += "	ELSE COALESCE(tMPWISARM.QTDE-ZD1.ZD1_QTCONF,0) "+ CRLF
	_cQuery += "	END  AS UPD_B2REC "+ CRLF

	_cQuery += "	,COALESCE(ZD1.ZD1_QTCONF + COALESCE(tMPWISARM.QTDE-ZD1.ZD1_QTCONF,0),0) ALT_QTCONF"+ CRLF
	_cQuery += "	,COALESCE(ZD1.ZD1_QUANT  - TMPWISARM.QTDE,0) ALT_SLDIT"+ CRLF
	_cQuery += "	,SB2.B2_QATU - COALESCE(TMPWISARM.QTDE - ZD1.ZD1_QTCONF,0) ALT_B2REC"+ CRLF
	_cQuery += "	,ZD1.R_E_C_N_O_ ZD1_RECNO"+ CRLF
	_cQuery += "	,' ' STATUS "+ CRLF
	_cQuery += "	,'"+Space(200)+"' HISTORICO "+ CRLF
// 	_cQuery	+=  "  	,utl_raw.cast_to_raw('" + Space(200) + "') HISTORICO " + CRLF
    _cQuery += "  	,' '                AS  D_E_L_E_T_ "+ CRLF
    _cQuery += " 	,ROW_NUMBER() OVER (ORDER BY ZD1_COD)     AS  R_E_C_N_O_ "+ CRLF    
    _cQuery += "FROM "+RetSqlName("ZD1")+" ZD1 " + CRLF
    _cQuery += "LEFT JOIN "+RetSqlName("SF1")+" SF1 " 				+ CRLF
    _cQuery += "	ON  SF1.D_E_L_E_T_ 	= ' ' " 					+ CRLF
    _cQuery += "	AND SF1.F1_FILIAL 	= '"+FwXFilial("SF1")+"' " 	+ CRLF
    _cQuery += "	AND SF1.F1_DOC 		= ZD1.ZD1_DOC " 			+ CRLF
    _cQuery += "	AND SF1.F1_SERIE 	= ZD1.ZD1_SERIE " 			+ CRLF
    _cQuery += "	AND SF1.F1_FORNECE 	= ZD1.ZD1_FORNEC " 			+ CRLF
    _cQuery += "	AND SF1.F1_TIPO 		<> 'D' " 				+ CRLF
    _cQuery += "LEFT JOIN "+RetSqlName("SB2")+ " SB2 " 					+ CRLF 
    _cQuery += "	ON SB2.D_E_L_E_T_ 	= ' ' " 					+ CRLF 
    _cQuery += "	AND SB2.B2_FILIAL 	= '"+FwXFilial("SB2")+"' " 	+ CRLF
    _cQuery += "	AND SB2.B2_COD 		= ZD1.ZD1_COD "				+ CRLF
    _cQuery += "	AND SB2.B2_LOCAL 	= ZD1.ZD1_LOCAL " 			+ CRLF
/*
    _cQuery += "LEFT JOIN (SELECT 	SD3.D3_FILIAL FIL " 			+ CRLF
    _cQuery += "					,SD3.D3_COD COD " 				+ CRLF
    _cQuery += "					,SD3.D3_LOCAL LOC " 			+ CRLF
    _cQuery += "					,SD3.D3_OBSERVA OBS" 			+ CRLF
    _cQuery += "					,SUM(SD3.D3_QUANT) SLD " 		+ CRLF 
    _cQuery += "			FROM "+RetSqlName("SD3")+ " SD3 " 		+ CRLF 
    _cQuery += "			WHERE  SD3.D_E_L_E_T_ = ' ' " 			+ CRLF 
    _cQuery += "				AND SD3.D3_FILIAL = '"+FwXFilial("SD3")+"' " + CRLF
    _cQuery += "				AND SD3.D3_TM = '999' " 			+ CRLF
    _cQuery += "			GROUP BY SD3.D3_FILIAL, SD3.D3_COD, SD3.D3_LOCAL, SD3.D3_OBSERVA " + CRLF
    _cQuery += "			HAVING SUM(SD3.D3_QUANT) = 0 )  TMPSD3 " + CRLF
    _cQuery += "	ON TMPSD3.FIL = ZD1.ZD1_FILIAL " 				+ CRLF
    _cQuery += "		AND TMPSD3.COD = ZD1.ZD1_COD " 				+ CRLF
    _cQuery += "		AND TMPSD3.LOC = ZD1.ZD1_LOCAL " 			+ CRLF
    _cQuery += "		AND RTRIM(REGEXP_SUBSTR(TMPSD3.OBS , '[^|]+' , INSTR(TMPSD3.OBS , ':')+1 , 1)) = RTRIM(ZD1.ZD1_DOC)" + CRLF 
    _cQuery += "		AND RTRIM(REGEXP_SUBSTR(TMPSD3.OBS , '[^|]+' , 1 , 2)) = RTRIM(ZD1.ZD1_SERIE) " + CRLF
    _cQuery += "		AND SUBSTR((REGEXP_SUBSTR(TMPSD3.OBS , '[^|]+' , 1 , 3)) , 1 , 6) = ZD1.ZD1_FORNEC " + CRLF
 */
    _cQuery += "LEFT JOIN (SELECT 	ARM.CD_PRODUTO PROD " 						+ CRLF
    _cQuery += "					,NFF.NU_FACTURA NF " 						+ CRLF
    _cQuery += "					,NFF.NU_SERIE_FACTURA SERIE" 				+ CRLF
    _cQuery += "					,NFF.CD_FORNECEDOR FORN" 					+ CRLF
    _cQuery += "					,SUM(DISTINCT(ARM.QT_ARMAZENADA)) QTDE " 	+ CRLF
    _cQuery += "			FROM WIS.T_HIST_ARMAZENAGEM@DBLINK_WISPROD ARM "	 + CRLF
    _cQuery += "			LEFT JOIN WIS.T_DET_ETIQUETA_LOTE@DBLINK_WISPROD ELT " + CRLF
    _cQuery += "                ON (ELT.NU_ETIQUETA_LOTE 	= ARM.NU_ETIQUETA " + CRLF
    _cQuery += "                AND ELT.CD_PRODUTO 			= ARM.CD_PRODUTO " 	+ CRLF
    _cQuery += "                AND ELT.CD_EMPRESA 			= ARM.CD_EMPRESA " 	+ CRLF
    _cQuery += "                AND ELT.CD_FAIXA 			= ARM.CD_FAIXA) " 	+ CRLF
    _cQuery += "            LEFT JOIN WIS.T_AGENDA@DBLINK_WISPROD TA " 			+ CRLF
    _cQuery += "                ON (TA.NU_AGENDA 			= ELT.NU_AGENDA) " 	+ CRLF
    _cQuery += "            LEFT JOIN WIS.T_NFACTURA@DBLINK_WISPROD NFF " + CRLF
    _cQuery += "                ON (NFF.NU_AGENDA 			= TA.NU_AGENDA) " 	+ CRLF
    _cQuery += "            GROUP BY ARM.CD_PRODUTO, NFF.NU_FACTURA, NFF.NU_SERIE_FACTURA, NFF.CD_FORNECEDOR " + CRLF   	
    _cQuery += "        ) TMPWISARM " 											+ CRLF
    _cQuery += "	ON LTRIM(RTRIM(TMPWISARM.PROD)) 		= LTRIM(RTRIM(ZD1.ZD1_COD)) " + CRLF
    _cQuery += "     	AND LTRIM(RTRIM(TMPWISARM.NF)) 		= LTRIM(RTRIM(ZD1.ZD1_DOC)) " + CRLF
    _cQuery += "   		AND LTRIM(RTRIM(TMPWISARM.SERIE)) 	= LTRIM(RTRIM(ZD1.ZD1_SERIE)) " + CRLF
    _cQuery += "        AND TMPWISARM.FORN = 9||SF1.F1_FORNECE||SF1.F1_LOJA " 	+ CRLF		  
    _cQuery += "WHERE ZD1.D_E_L_E_T_ 	= ' ' " 								+ CRLF
    _cQuery += "	AND ZD1.ZD1_FILIAL	= '"+FwXFilial("ZD1")+"' " 				+ CRLF
    _cQuery += " 	AND TMPWISARM.QTDE <> 0 " 									+ CRLF
    _cQuery += "    AND ZD1.ZD1_QTCONF <> ZD1.ZD1_QUANT " 						+ CRLF
    _cQuery += "  	AND ZD1.ZD1_QTCONF < TMPWISARM.QTDE  " 						+ CRLF
    _cQuery += " 	AND ZD1.ZD1_COD BETWEEN '"+_cCodProdDe+"' AND '"+_cCodProdAte+"' " + CRLF
    _cQuery += "ORDER BY ZD1.ZD1_SLDIT DESC " 									+ CRLF

	_nStatus := TCSqlExec(_cQuery)
    If (_nStatus < 0)
        MsgStop("TCSQLError() " + TCSQLError(), "Registros Cabeçalho")
		_lRet := .F.
        Break    
    Endif
    
    (_cAlias)->(DbGoTop())
	If (_cAlias)->(Eof())
		MSGINFO( "Não existe Orçamento pendente para este item", "Atenção" )
		_lRet := .F.
		Break
	Endif

End SEQUENCE
Return _lRet


//Avaliar se deverá ser alterado ZD1
Static Function ZPECAJ01AV(_ObrW, _lGeral,_oSay)
Local _nRegProcessado 	:= 0
Local _cMens 			:= '<h1>Confirma?</h2><br>Tem certeza que deseja alterar os valores do armazen recebimento ? <font color="#FF0000"><b>Alterara os saldos do armazém</b></font>. '
Local _cTititulo  		:= '<font color="#FF0000"><b>IMPORTANTE</b></font>' 
Local _aMsgErro			:= {}
Local _lRet				:= .T. 
Local _cId 				:= ""
Local _cMsgErro			:= ""
Local _cMsg
Local _nPos
Local _dDataIni 
Local _cHsIni

Default _lGeral  		:= .T.

Begin Sequence
	//If !MsgYesNo( "Tem certeza que deseja alterar os valores do armazen recebimento ? " )
	If !MsgYesNo( _cMens, _cTititulo )
		Break
	Endif	
	//Se for todos
	If _lGeral
		(_cAlias)->(DbGotop())
	Endif
	While (_cAlias)->(!Eof())
		_dDataIni 	:= Date()
		_cHsIni		:= Time()
		_nRegProcessado ++
		_oSay:SetText("Avaliando registro "+ StrZero(_nRegProcessado,7))
		ProcessMessage() 

		If (_cAlias)->STATUS == "P"
			If !_lGeral
				MSGINFO( "Item ja Processado", "Atenção" )
				Break
			Endif
			(_cAlias)->(DbSkip())
			Loop 
		Endif 	

		_nReg 		:= (_cAlias)->ZD1_RECNO
		_aMsgErro 	:= {}
		//Preparar numeração do ID
		_cId 		:= "ZPECAJ01"+;
						"|"+Alltrim((_cAlias)->ZD1_DOC)+;
						"|"+Alltrim((_cAlias)->ZD1_SERIE)+;
						"|"+Alltrim((_cAlias)->ZD1_FORNEC)+;
						"|"+Alltrim((_cAlias)->ZD1_LOJA)+;
						"|"+Alltrim((_cAlias)->ZD1_COD)+;
						"|"+Alltrim((_cAlias)->B2_LOCAL)+;
						"|"+AllTrim(STR((_cAlias)->ZD1_QUANT))
		Begin Transaction
			//FwMsgRun(,{ |_oSay | _lRet := ZPECAJ01TR(_nReg, (_cAlias)->UPD_B2REC, (_cAlias)->ZD1_COD, (_cAlias)->UPD_QTCONF, (_cAlias)->UPD_SLDIT,  _nRegProcessado, @_cId, @_aMsgErro, @_oSay) }, "Ajustustando armazém de Recebimento ZD1", "Aguarde...")  
			_lRet := ZPECAJ01TR(_nReg, (_cAlias)->UPD_B2REC, (_cAlias)->ZD1_COD, (_cAlias)->UPD_QTCONF, (_cAlias)->UPD_SLDIT,  _nRegProcessado, @_cId, @_aMsgErro, @_oSay) 

			If !_lRet
				Disarmtransaction()
			EndIf	
		End Transaction

		If Len(_aMsgErro) > 0
			_cMsg := ""
			For _nPos := 1 To Len(_aMsgErro)
				_cMsg += Upper(AllTrim(_aMsgErro[_nPos]))+ " " + CRLF
			Next
		Endif 

		If _nReg <> (_cAlias)->ZD1_RECNO
			(_cAlias)->(_nReg)
		Endif	
		RecLock(_cAlias, .F. )
		If !_lRet
			(_cAlias)->STATUS := "E"
			_cMsgErro := "ZPECAJ01 ERRO ATUALIZAÇÃO"
		Else
			(_cAlias)->STATUS := "P"
			_cMsgErro := "ZPECAJ01 ATUALIZADO COM SUCESSO"
		EndIf	
		(_cAlias)->HISTORICO := _cMsg
		(_cAlias)->(MsUnlock())
		//gravar logs
		ZPECAJ01Monitor(If(_lRet,"1","2")	, "ZD1", (_cAlias)->ZD1_DOC	, _cMsg, _cMsgErro, _dDataIni, _cHsIni, If(_lRet,100,400) /*_nErro*/, _nReg, (_cAlias)->ZD1_COD, _cId, (_cAlias)->UPD_B2REC )	
		If !_lGeral
			_ObrW:Refresh()
			Break
		Endif
		If _nReg <> (_cAlias)->ZD1_RECNO
			(_cAlias)->(_nReg)
		Endif	
		(_cAlias)->(DbSkip())
	EndDo
	//(_cAlias)->(DbGotop())
	_ObrW:Refresh(.T.)
End Sequence    
Return Nil



//Efetuar a Transferência
Static Function ZPECAJ01TR(_nReg, _nQtdeConf, _cProduto, _nQTCONF, _nSLDIT,  _nRegProcessado, _cId, _aMsgErro, _oSay)
Local _lRet := 		.T.				
Local _aLinha       := {}
Local _aAuto        := {}
Local _aSaldoDest   := {}
Local _nQtdeTec		:= 0
Local _nSaldoTec    := 0
Local _nSaldoSB2    := 0
Local _nSLdSB2REC	:= 0
Local _nSLdSB2DES	:= 0
Local _nSB2DES		:= 0
Local _nOpcAuto     := 3
Local _cArmOrig
Local _cArmDes
Local _cArmTec
Local _aArmDes
Local _cErro
Local _cDocumento
Local _aError 
Local _nQtde
Local _nPos

Begin SEQUENCE
	_oSay:SetText("Processando registro "+ StrZero(_nRegProcessado,7))
	ProcessMessage() 

	// Verificar se não será gravado antes este campo ou se ja vou mandar os valores corretos da função anterior e gravar aqui
	//Posicino o Registro para atualizar
	ZD1->(DbGoto(_nReg))
	//Guarda alterações
	_cErro := "Campo  ZD1_QTCONF: " +AllTrim(Str(ZD1->ZD1_QTCONF)) +" atualizado para: " +AllTrim(Str(_nQTCONF))+ " " 
	Aadd(_aMsgErro,_cErro)
	_cErro += "Campo  Z1_SLDITA : " +AllTrim(Str(ZD1->ZD1_SLDIT))  +" atualizado para: " +AllTrim(Str(_nSLDIT)) + " " 
	Aadd(_aMsgErro,_cErro)
	//gRAVAR NO ID
	_cId += "|ZD1_QTCONF|"+AllTrim(Str(ZD1->ZD1_QTCONF))+"|"+AllTrim(Str(_nQTCONF)) 
	_cId += "|ZD1_SLDIT|" +AllTrim(Str(ZD1->ZD1_SLDIT))  +"|"+AllTrim(Str(_nSLDIT)) 
	RecLock("ZD1", .F.)
	ZD1->ZD1_QTCONF := _nQTCONF 
	ZD1->ZD1_SLDIT	:= _nSLDIT
	ZD1->( MsUnLock() )

	if _nQtdeConf == 0
		Break
	Endif
    If AllTrim(ZD1->ZD1_LOCAL) == "90"
		_cArmOrig	:= "90"
		_cArmDes	:= "11"
		_cArmTec	:= AllTrim( GetNewPar( "CMV_PEC028", "02" ) )
		_aArmDes	:=	{_cArmTec,_cArmDes}
	Else
		_cArmOrig	:= "80"
		_cArmDes	:= "01"
		_cArmTec	:= AllTrim( GetNewPar( "CMV_PEC028", "02" ) )
		_aArmDes	:=	{_cArmTec,_cArmDes}
	EndIf

	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(FWxFilial("SB1")+PadR(_cProduto, TamSx3('B1_COD') [1])))
		_cErro := "Produto "+AllTrim(_cProduto)+"  nao cadastrado no Totvs." 
		Aadd(_aMsgErro,_cErro)
		_lRet := .F.
		Break
	Else
		If SB1->B1_MSBLQL == "1"
    		_cErro := "Produto "+AllTrim(_cProduto)+"  bloqueado no cadastrado Totvs." 
			Aadd(_aMsgErro,_cErro)
    		_lRet := .F.
    		Break
		EndIf
	Endif	
	_nQtdeTec := SB1->B1_XRESTEC

	NNR->(DbSetOrder(1))
	NNR->(DbSeek(FWxFilial("SB2")))
	While NNR->(!Eof()) .And. NNR->NNR_FILIAL == FWxFilial("SB2")
		SB2->(DbSetOrder(1))
		If !SB2->(DbSeek(FWxFilial("SB2")+PadR(_cProduto, TamSx3('B2_COD') [1])+PadR(NNR->NNR_CODIGO,TamSx3('B2_LOCAL') [1])))
			CriaSB2(Alltrim(_cProduto),Alltrim(NNR->NNR_CODIGO))
		EndIf
		NNR->(DbSkip())
	EndDo

	_nSLdSB2REC := 0
	SB2->(DbSetOrder(1))
	If SB2->(DbSeek(FWxFilial("SB2")+PadR(_cProduto, TamSx3('B2_COD') [1])+PadR(_cArmOrig, TamSx3('B2_LOCAL') [1])))
		_nSaldoSB2 := SB2->(SaldoSb2())
		If _nSaldoSB2 < _nQtdeConf
			_cErro := "Qtde conferida maior que Saldo do Totvs." 
			Aadd(_aMsgErro,_cErro)
			_lRet := .F.
			Break
		EndIf
	Else
		CriaSB2(AllTrim(_cProduto),AllTrim(_cArmOrig))
	EndIf

	// Valida se o Produto tem Quantidade minima para saldo no armazem tecnico	
	_nSaldoTec := 0
	if _nQtdeTec > 0
		SB2->(DbSetOrder(1))
		If SB2->(DbSeek(FWxFilial("SB2")+PadR(_cProduto, TamSx3('B2_COD') [1])+PadR(_cArmTec, TamSx3('B2_LOCAL') [1])))				
			_nSaldoTec := SB2->(SaldoSb2())
			_nSaldoTec := _nQtdeTec - _nSaldoTec
		Else
			CriaSB2(AllTrim(_cProduto),AllTrim(_cArmTec))
	    EndIf
	Endif	
	_nSLdSB2DES := 0 		
	If !SB2->(DbSeek(FWxFilial("SB2")+PadR(_cProduto, TamSx3('B2_COD') [1])+PadR(_cArmDes, TamSx3('B2_LOCAL') [1])))
		CriaSB2(AllTrim(_cProduto),AllTrim(_cArmDes))
	else
		_nSLdSB2DES := SB2->B2_QATU		
	EndIf
	//não vai validar pois para atualizar a movimentação pode estar menor a qtde qtdconf
	//If _nQtdeConf > ZD1->ZD1_SLDIT
	//	_cErro := "Qtde conferida maior que o saldo a conferir - ZD1." 
	//	_lRet := .F.
	//	Break
	//EndIf
 	//criavar('D3_DOC')  
	
    _aAuto      := {}

	//Implementado pois em alguns casos não esta conseguindo localizar numera~]ap
	_cDocumento := ""
	For _nPos := 1 To 10
		_cDocumento  := Criavar("D3_DOC")
		_cDocumento	:= IIf(Empty(_cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),_cDocumento)
		If !Empty(_cDocumento)
			Exit
		Endif 
	Next 	
	If Empty(_cDocumento)
		_cErro := "Não foi possivel montar numeração SD3, para gerar movimentação." 
		Aadd(_aMsgErro,_cErro)
		_lRet := .F.
		Break
	Endif
	_cDocumento	:= A261RetINV(_cDocumento)
	aAdd(_aAuto,{_cDocumento , dDataBase})    //Cabecalho
	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(FWxFilial("SB1")+PadR(_cProduto , TamSx3('B1_COD') [1])))
		_lRet := .F.
		Break
	EndIf

	If _nQtdeConf <= _nSaldoTec
		_aSaldoDest := {_nQtdeConf}
	Else
       	_aSaldoDest := {_nSaldoTec, _nQtdeConf - _nSaldoTec}
	Endif
    _aLinha     := {}
	For _nPos := 1 To Len(_aSaldoDest)
		_aLinha := {}
		if _aSaldoDest[_nPos] <= 0
			Loop
		Endif 
		_nQtde := _aSaldoDest[_nPos]
		//Origem
		aAdd(_aLinha,{"D3_COD"    	, SB1->B1_COD 																						, Nil} ) //Cod Produto origem
		aAdd(_aLinha,{"D3_DESCRI" 	, SB1->B1_DESC 																						, Nil} ) //descr produto origem
		aAdd(_aLinha,{"D3_UM"     	, SB1->B1_UM																						, Nil} ) //unidade medida origem
		aAdd(_aLinha,{"D3_LOCAL"  	, AllTrim(_cArmOrig)																				, Nil} ) //armazem origem
		aAdd(_aLinha,{"D3_LOCALIZ"	, IIf(Localiza(SB1->B1_COD),FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ"),Space(15))					, Nil} ) //Informar endereço origem

		//Destino			
		aAdd(_aLinha,{"D3_COD"		, SB1->B1_COD																						, Nil}) //cod produto destino
		aAdd(_aLinha,{"D3_DESCRI"	, SB1->B1_DESC																						, Nil}) //descr produto destino
		aAdd(_aLinha,{"D3_UM"		, SB1->B1_UM																						, Nil}) //unidade medida destino					
		aAdd(_aLinha,{"D3_LOCAL"	, AllTrim( _aArmDes[_nPos] )																			, Nil}) //armazem destino  era  SB1->B1_LOCPAD
		aAdd(_aLinha,{"D3_LOCALIZ"	, IIf(Localiza(SB1->B1_COD),FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ"),Space(15))					, Nil}) //Informar endereço destino

		aAdd(_aLinha,{"D3_NUMSERI"	, CriaVar('D3_NUMSERI')																				, Nil}) //Numero serie
		aAdd(_aLinha,{"D3_LOTECTL"	, CriaVar('D3_LOTECTL')																				, Nil}) //Lote Origem
		aAdd(_aLinha,{"D3_NUMLOTE"	, CriaVar("D3_NUMLOTE")																				, Nil}) //sublote Origem
		aAdd(_aLinha,{"D3_DTVALID"	, CriaVar("D3_DTVALID")																				, Nil}) //data validade
		aAdd(_aLinha,{"D3_POTENCI"	, CriaVar('D3_POTENCI')																				, Nil}) // Potencia
		aAdd(_aLinha,{"D3_QUANT"	, _nQtde																						, Nil}) //Quantidade
		aAdd(_aLinha,{"D3_QTSEGUM"	, CriaVar("D3_QTSEGUM") 																			, Nil}) //Seg unidade medida
		aAdd(_aLinha,{"D3_ESTORNO"	, CriaVar("D3_ESTORNO")																				, Nil}) //Estorno
		aAdd(_aLinha,{"D3_LOTECTL"	, CriaVar('D3_LOTECTL')	 																			, Nil}) //Lote destino
		aAdd(_aLinha,{"D3_DTVALID"	, CriaVar("D3_DTVALID")																				, Nil}) //data validade Destino
		aAdd(_aLinha,{"D3_ITEMGRD"	, CriaVar("D3_ITEMGRD")																				, Nil})	//Item Grade 
		aAdd(_aLinha,{"D3_OBSERVA"	, "AJUSTE DE CONFERENCIA REALIZADO NA QUANTIDADE "+AllTrim(Str(_nQtdeConf))+" ZPECAJ01" 		, Nil})	//Observacao
		aAdd(_aAuto, _aLinha)
	Next _nPos

	If Len(_aLinha) == 0
		_cErro := "Não foi selecionado nenhum item para atualizar a movimentação ! [ZPECAJ01]"
		Aadd(_aMsgErro,_cErro)
		_lRet := .F.
		Break
    Endif 
	Private lMsErroAuto 	:= .F.	// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
	//Private lMsHelpAuto 	:= .T.  // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
	Private lAutoErrNoFile 	:= .T.  //Variavel de Controle do GetAutoGRLog
    //ExecAuto
	MSExecAuto({|x,y| mata261(x,y)}, _aAuto, _nOpcAuto)

	If lMsErroAuto
		_cErro := "Problemas no execauto MATA261, ZPECAJ01 para transferencia de armazém !" + CRLF
		// se estiver em debug, pega o log inteiro do erro para uma analise mais detalhada
		_aError := GetAutoGRLog()
		For _nPos := 1 To Len(_aError)
			If !Empty((AllTrim(_aError[_nPos])))  	
				_cErro	+= 	AllTrim(_aError[_nPos]) + CRLF
			EndIf		
		Next _nPos			
		Aadd(_aMsgErro,_cErro)
		_cId += "|ERRO MATA261|"+AllTrim(Str(_nQtdeConf))
		_lRet := .F.
		Break
	Else
		_nSB2DES := 0
		If SB2->(DbSeek(FWxFilial("SB2")+PadR(_cProduto, TamSx3('B2_COD') [1])+PadR(_cArmDes, TamSx3('B2_LOCAL') [1])))
			_nSB2DES := SB2->B2_QATU	
		Endif
		_cErro := "Atualizado saldo B2 Armazém destino "+AllTrim(_cArmDes)+" Saldo anterior "+AllTrim(Str(_nSLdSB2DES))+" para "+AllTrim(Str(_nSB2DES))+" de acordo com o valor de conferencia "+ AllTrim(Str(_nQtdeConf))	
		Aadd(_aMsgErro,_cErro)
		_cId += "|B2_LOC|"+_cArmDes+"|"+AllTrim(Str(_nSLdSB2DES))+"|"+AllTrim(Str(_nSB2DES))+"|"+AllTrim(Str(_nQtdeConf))
	EndIf	
End SEQUENCE

DbSelectArea(_cAlias)
Return _lRet    



/*
=====================================================================================
Programa.:              ZPECAJ01Monitor
@param 					_cStatus   	= Status que será gerado no SZ1 1-OK 2-Divergência 
						_cTab		= Tabela principal que esta sendo gravada na integração
						_cDoc   	= Numero do Cocumento a ser gravado, ja contém a série 
						_cErro    	= mensagem a ser gravada podendo ser de erro e ou exito 
						_dDataIni	= data inicial da importação 
						_cHsIni 	= hora inicial da importação 
						_cJson    	= Json para importação
						_nErro		= numero de retorno que ocasionou erro e ou exito
Autor....:              CAOA - DAC Denilso 
Data		            14/11/2022
Descricao / Objetivo	Funcionalidade que efetuara a gravação de dados no monitor 
Doc. Origem            	PEC020 - Monitor de Integrações WIS
Solicitante            	CAOA
Uso              		ZWSR012
Obs
@menu       			Nao Informado
@return					_lRet 		- Verdadeiro ou falso
@history 				DAC - 	15/02/2023 
								Implementação de envio de campos a serem gravados para SZ1	
=====================================================================================
*/
Static Function	ZPECAJ01Monitor(_cStatus, _cTab, _cDoc, _cMens, _cErro, _dDataIni, _cHsIni, _nErro, _nReg, _cProduto, _cIdJson, _nQtdeConf )	
Local _lJob      := IsBlind()
Local _cUserName := If( _lJob,"AJ CONF. ZPECJA01", Nil)   
Local _aCampos	 := {}  //Adicionar campos a serem gravador na tabela DAC  15/02/2023 

Begin SEQUENCE
	AAdd(_aCampos,{"Z1_COD"		, _cProduto 	})
	AAdd(_aCampos,{"Z1_IDJSON"	, _cIdJson 		})
	AAdd(_aCampos,{"Z1_QTCONF"	, _nQtdeConf 	})
	AAdd(_aCampos,{"Z1_NTPINTG"	, "ZPECAJ01" 	})

	U_CAOA_GRVMONITOR(XFilial(_cTab),;		//Filail
				_cStatus,;				//Status
				"011",;					//Código do Processo
				/*cCodtpint*/,;			//Código do tipo
				Upper(_cErro),;			//Mensagem de retorno
				_cDoc,;					//Documento
				_dDataIni,;				//Data Inicio
				_cHsIni,;				//Hora Final
				Upper(_cMens),;			//Json
				If(_cStatus=="1", (_cTab)->(Recno()),0),; //Numero do Registro
				_cUserName,;			//Nome do Usuário na inclusão
				_nErro,;				//Retorno código
				_aCampos)				//Campos pré definidos para gravar no SZ1 
End Sequence
Return Nil



//Cria Tabela Temporária para gravar dados
Static Function ZPECAJ01TB(_aStru)
Local _oTable
Local _aCampos
Local _nPos

//ZD1_DOC	ZD1_SERIE	ZD1_FORNEC	ZD1_LOJA	ZD1_COD	ZD1_QUANT	ZD1_QTCONF	ZD1_SLDIT	SLDB2REC	QTDINTEG	TOT_ARMAZENADA_WIS
Begin SEQUENCE
	_aStru := {}
	aAdd( _aStru, { "ZD1_DOC"   ,	RetTitle("ZD1_DOC")		, TamSX3("ZD1_DOC")[3]		, TamSX3("ZD1_DOC")[1]		, TamSX3("ZD1_DOC")[2]		,PesqPict("ZD1","ZD1_DOC")	, .T.	})
	aAdd( _aStru, { "ZD1_SERIE" ,	RetTitle("ZD1_SERIE")	, TamSX3("ZD1_SERIE")[3]	, TamSX3("ZD1_SERIE")[1]	, TamSX3("ZD1_SERIE")[2]	,PesqPict("ZD1","ZD1_SERIE"), .T.  	})
	aAdd( _aStru, { "ZD1_FORNEC",	RetTitle("ZD1_FORNEC")	, TamSX3("ZD1_FORNEC")[3]	, TamSX3("ZD1_FORNEC")[1]	, TamSX3("ZD1_FORNEC")[2]	,PesqPict("ZD1","ZD1_FORNEC"), .T.	})
	aAdd( _aStru, { "ZD1_LOJA"  ,	RetTitle("ZD1_LOJA")	, TamSX3("ZD1_LOJA")[3]		, TamSX3("ZD1_LOJA")[1]		, TamSX3("ZD1_LOJA")[2]		,PesqPict("ZD1","ZD1_LOJA")	, .T.	})
	aAdd( _aStru, { "ZD1_COD"   ,	RetTitle("ZD1_COD")		, TamSX3("ZD1_COD")[3]		, TamSX3("ZD1_COD")[1]		, TamSX3("ZD1_COD")[2]		,PesqPict("ZD1","ZD1_COD")	, .T.	})
	aAdd( _aStru, { "B2_LOCAL" 	,	RetTitle("B2_LOCAL")	, TamSX3("B2_LOCAL")[3]		, TamSX3("B2_LOCAL")[1]		, TamSX3("B2_LOCAL")[2]		,PesqPict("SB2","B2_LOCAL")	, .T.	})
	aAdd( _aStru, { "ZD1_QUANT" ,	RetTitle("ZD1_QUANT")	, TamSX3("ZD1_QUANT")[3]	, TamSX3("ZD1_QUANT")[1]	, TamSX3("ZD1_QUANT")[2]	,PesqPict("ZD1","ZD1_QUANT"), .T.	})
	aAdd( _aStru, { "ZD1_QTCONF",	RetTitle("ZD1_QTCONF")	, TamSX3("ZD1_QTCONF")[3]	, TamSX3("ZD1_QTCONF")[1]	, TamSX3("ZD1_QTCONF")[2]	,PesqPict("ZD1","ZD1_QTCONF"), .T.	})
	aAdd( _aStru, { "ZD1_SLDIT" ,	RetTitle("ZD1_SLDIT")	, TamSX3("ZD1_SLDIT")[3]	, TamSX3("ZD1_SLDIT")[1]	, TamSX3("ZD1_SLDIT")[2]	,PesqPict("ZD1","ZD1_SLDIT"), .T.	})
	aAdd( _aStru, { "SLDB2REC"  ,	"SL.DB2 REC"			, TamSX3("ZD1_QUANT")[3]	, TamSX3("ZD1_QUANT")[1]	, TamSX3("ZD1_QUANT")[2]	,PesqPict("ZD1","ZD1_QUANT"), .T.	})
	//aAdd( _aStru, { "QTDINTEG"	, 	"Qtde Integrada"		, TamSX3("ZD1_QUANT")[3]	, TamSX3("ZD1_QUANT")[1]	, TamSX3("ZD1_QUANT")[2]	,PesqPict("ZD1","ZD1_QUANT"), .T.	})
	aAdd( _aStru, { "QTDWIS"	,	"Saldo Wis"				, TamSX3("ZD1_QUANT")[3]	, TamSX3("ZD1_QUANT")[1]	, TamSX3("ZD1_QUANT")[2]	,PesqPict("ZD1","ZD1_DOC")	, .T.	})
	aAdd( _aStru, { "DIFERENCA"	,	"Diferença Saldos"		, TamSX3("ZD1_QUANT")[3]	, TamSX3("ZD1_QUANT")[1]	, TamSX3("ZD1_QUANT")[2]	,PesqPict("ZD1","ZD1_DOC")	, .T.	})
	aAdd( _aStru, { "UPD_QTCONF",	"UPD ZD1_QTDCONF"		, TamSX3("ZD1_QUANT")[3]	, TamSX3("ZD1_QUANT")[1]	, TamSX3("ZD1_QUANT")[2]	,PesqPict("ZD1","ZD1_DOC")	, .T.	})
	aAdd( _aStru, { "UPD_SLDIT"	,	"UPD ZD1_SLDIT"			, TamSX3("ZD1_SLDIT")[3]	, TamSX3("ZD1_SLDIT")[1]	, TamSX3("ZD1_SLDIT")[2]	,PesqPict("ZD1","ZD1_SLDIT"), .T.	})
	aAdd( _aStru, { "UPD_B2REC"	,	"TRANSF-B2_REC"			, TamSX3("ZD1_QUANT")[3]	, TamSX3("ZD1_QUANT")[1]	, TamSX3("ZD1_QUANT")[2]	,PesqPict("ZD1","ZD1_DOC")	, .T.	})
	aAdd( _aStru, { "ALT_QTCONF",	"Qtde Conf Atu"			, TamSX3("ZD1_QUANT")[3]	, TamSX3("ZD1_QUANT")[1]	, TamSX3("ZD1_QUANT")[2]	,PesqPict("ZD1","ZD1_DOC")	, .T.	})
	aAdd( _aStru, { "ALT_SLDIT"	, 	"Sld Item Atu"			, TamSX3("ZD1_QUANT")[3]	, TamSX3("ZD1_QUANT")[1]	, TamSX3("ZD1_QUANT")[2]	,PesqPict("ZD1","ZD1_DOC")	, .T.	})
	aAdd( _aStru, { "ALTB2REC"	, 	"SB2 Arm. Atu"			, TamSX3("ZD1_QUANT")[3]	, TamSX3("ZD1_QUANT")[1]	, TamSX3("ZD1_QUANT")[2]	,PesqPict("ZD1","ZD1_DOC")	, .T.	})
	aAdd( _aStru, { "ZD1_RECNO" ,	"Registro ZD1"			, "N"						, 10						, 0							,							, .T.	})
	aAdd( _aStru, { "STATUS" 	,	"Status"				, "C"						, 1							, 0							,"@!"						, .T.	})
	aAdd( _aStru, { "HISTORICO" ,	"Historico"				, "C"						, 200						, 0							,"@!"						, .T.	})

	_aCampos := {}
	For _nPos := 1 To Len(_aStru)
         Aadd(_aCampos, {_aStru[_nPos,01], _aStru[_nPos,3], _aStru[_nPos,4], _aStru[_nPos,5] })
	Next _nPos
    _oTable := FWTemporaryTable():New()
    _oTable:SetFields(_aCampos)
    _oTable:AddIndex("INDEX1", {"ZD1_COD","B2_LOCAL","ZD1_FORNEC","ZD1_LOJA","ZD1_DOC"} )
    _oTable:Create()
    _cAlias 	:= _oTable:GetAlias()
    _cTable 	:= _oTable:GetRealName()
End SEQUENCE
Return Nil
