#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "xmlxfun.ch"

/*
Integracao de Contas a Pagar com SA
*/
user function CMVSAP03( aParam )
local oWsdl
local aOps			:= {}
local cUser			:= ""//allTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
local cPass			:= ""//allTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP
local cURLProxy		:= ""//allTrim( superGetMv( "CAOAPROXY"	, , "proxy.caoa.local"		) )	// Usuario Proxy da Rede Caoa
local nPortProxy	:= ""//superGetMv( "CAOAPORT"	, , 8080 )								// Porta Proxy da Rede Caoa
local cUserProxy	:= ""//allTrim( superGetMv( "CAOAPROUSE"	, , "T-RODRIGO.SALOMAO"	) )	// Usuario do Proxy
local cPassProxy	:= ""//allTrim( superGetMv( "CAOAPROPAS"	, , "caoa2019**"		) )	// Senha do Proxy
local cUrl			:= ""//allTrim( superGetMv( "CAOASAP03A"	, , "http://10.120.40.140:51400/dir/wsdl?p=ic/7e57f79630be3849a4ebcfa108259ed4") )
local aHeadOut		:= {}
local cHeadRet		:= ""
local cAutorizat	:= ""
local cTimeIni		:= ""
local cTimeFin		:= ""
local cTimeProc		:= ""
local xPostRet		:= nil
local nStatuHttp	:= 0
local nTimeOut		:= 120

local aAux			:= {}
local aDocHeader	:= {}
local aAccountGL	:= {}
local aAccPayabl	:= {}
local aAccountWT	:= {}
local nI			:= 0
local nJ			:= 0
local cDivisao		:= ""//right( allTrim( xEncCGC( xFilial("SZ7") ) ) , 4 )
local cIDLote		:= ""
//local nSZ7Recno		:= 0
//local cFilAtu		:= ""
//local cCT2Atu		:= ""
local cUltimoCT2	:= ""
local cGeraPorNF	:= ""//allTrim( superGetMv( "CAOASAP03B"	, , "SPED|RPS") )
local cFrete		:= ""//allTrim( superGetMv( "CAOASAP03C"	, , "CTE") )

local cZ7Filial		:= ""
local cZ7Tabela		:= ""
local cZ7Chave		:= ""
local cZ7Sequen		:= ""
Local nNum := 0
Local nNumEst := 0
Local cOrigEst := ""//GetMv("CAOAORESTP",,"650-004/650-005")
Local aAccountEstGL := {}
//Local nAtiv := 0
Local cRequest := ""
Local lContinua := .F.
Local cQ := ""
Local cSD1 := ""
//Local lFornece := .T.
Local cSeq := ""
Local lDev := .F.
Local cSD2 := ""
Local cFilAntSav := ""
Local nDiasErro 	:= 0
Local lInvSinal := .F.
//local nTitWT := 0
//Local nCountWT := 0
Local nCount := 0
Local nValRet := 0
Local cOrigRet := ""
Local nDiasAguar := 0
Local aAreaSE2 := {}
Local lSE2 := .F.
Local lAdt := .F.

Local nRecRep := 0
Local cEmpJob := ""
Local cFilJob := ""
Local cDocSAP := ""
//Local cTiposFin := ""
//local nTit := 0
Local nRegSE2 := 0
Local cChaveTit := ""
Local cParc := ""
Local nCnt := 0
Local lIsDigParc := .T.
Local nPos := 0
Local xRet := Nil
Local cDocSAPDev := ""
Local cRefSAP := ""

private cAliasQry	:= ""//GetNextAlias()
private cAliasQry1	:= ""//GetNextAlias()
private lIsBlind	:=  (IsBlind() .OR. Type("__LocalDriver") == "U") .and. type('httpheadin->main') == 'U'  //IsBlind() .OR. Type("__LocalDriver") == "U"

If !Empty(aParam)
	If ValType(aParam[1][1]) == "C"
		cEmpJob := aParam[1][1]
	Endif
	If ValType(aParam[1][2]) == "C"
		cFilJob := aParam[1][2]
	Endif
	If ValType(aParam[1][3] ) == "N"
		nRecRep := aParam[1][3]
	Endif
Endif

IF lIsBlind
	RpcSetType(3)
	RpcSetEnv( cEmpJob , cFilJob )
	
	If !LockByName("CMVSAP03")
		Conout("JOB já em Execução : CMVSAP03 " + DTOC(dDATABASE) + " - " + TIME() )
		RpcClearEnv()
		Return
	Else 
		Conout("Conexão realizada com sucesso : CMVSAP03 " + DTOC(dDATABASE) + " - " + TIME() )
	EndIf
EndIF

cUser		:= allTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
cPass		:= allTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP
cURLProxy	:= allTrim( superGetMv( "CAOAPROXY"	, , "proxy.caoa.local"		) )	// Usuario Proxy da Rede Caoa
nPortProxy	:= superGetMv( "CAOAPORT"	, , 8080 )								// Porta Proxy da Rede Caoa
cUserProxy	:= allTrim( superGetMv( "CAOAPROUSE"	, , "T-RODRIGO.SALOMAO"	) )	// Usuario do Proxy
cPassProxy	:= allTrim( superGetMv( "CAOAPROPAS"	, , "caoa2019**"		) )	// Senha do Proxy
cDivisao	:= right( allTrim( xEncCGC( xFilial("SZ7") ) ) , 4 )
cGeraPorNF	:= allTrim( superGetMv( "CAOASAP03B"	, , "SPED|RPS") )
cFrete		:= allTrim( superGetMv( "CAOASAP03C"	, , "CTE") )
cAliasQry	:= GetNextAlias()
cAliasQry1	:= GetNextAlias()
nDiasErro	:= superGetMv( "CAOASAP01C"	, , 3 )  // qtde de dias para reprocessar registros com status de erro
nDiasAguar	:= superGetMv( "CAOASAP01D"	, , 3 )  // qtde de dias para reprocessar registros com status de aguardando
//cTiposFin 	:= GetMv("CAOASAP12D",,"NF/DP")

cQ := "SELECT SZ7.*,SZ7.R_E_C_N_O_ SZ7_RECNO "
cQ += "FROM "+RetSqlName("SZ7")+" SZ7 "
//cQ += "WHERE (Z7_XSTATUS = 'P' OR (Z7_XSTATUS = 'E' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasErro)+"') OR (Z7_XSTATUS = 'A' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasAguar)+"' AND Z7_XDTINC < '"+dTos(dDataBase-1)+"')) "
cQ += "WHERE (Z7_XSTATUS = 'P' OR (Z7_XSTATUS = 'E' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasErro)+"')) "
//cQ += "WHERE Z7_XSTATUS = 'P' "
cQ += "AND ( "
cQ += "(Z7_XTABELA = 'SF1' AND Z7_TIPONF NOT IN ('B','D')) "
cQ += "OR (Z7_XTABELA = 'SF2' AND Z7_TIPONF = 'D') "
cQ += "OR Z7_XTABELA = 'SE2' "
cQ += ") "
cQ += " AND NOT (Z7_XCHAVE LIKE '%TX %' AND Z7_XCHAVE LIKE '%EIC%') " //Não será integrado as TX vinda do EIC até o momento
cQ += "AND D_E_L_E_T_ <> '*' "

If nRecRep > 0
	cQ += " AND SZ7.R_E_C_N_O_ = " + AllTrim(Str(nRecRep))
EndIf

cQ += " ORDER BY SZ7.R_E_C_N_O_ "

tcQuery cQ new Alias (cAliasQry)

cAutorizat := encode64( allTrim( cUser ) + ":" + allTrim( cPass ) )

aadd( aHeadOut	, 'Content-Type: text/xml; charset=UTF-8'								)
aadd( aHeadOut	, 'SOAPAction: http://sap.com/xi/WebService/soap1.1'					)
aadd( aHeadOut	, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')'	)
aadd( aHeadOut	, 'Authorization: Basic ' + cAutorizat									)

cFilAntSav := cFilAnt

While !(cAliasQry)->(EOF())
	cFilAnt := (cAliasQry)->Z7_FILIAL
	lContinua := .F.
	//lFornece := .T.
	lDev := .F.
	cSeq := ""
	cSD1 := ""
	cSD2 := ""
	//nAtiv := 0
	lInvSinal := .F.
	//nTitWT := 0
	//nCountWT := 0
	nCount := 0
	nValRet := 0
	lSE2 := .F.
	cRequest := ""
	lAdt := .F.
	//nTit := 0
	nRegSE2 := 0
	cChaveTit := ""
	cParc := ""
	lIsDigParc := .T.
	cDocSAP := ""
	cDocSAPDev := ""
	cRefSAP    := ""
	
	// verifica se trata-se de nota de devolucao de compras
	If (cAliasQry)->Z7_XTABELA == "SF2" .and. (cAliasQry)->Z7_TIPONF == "D"
		//lFornece := .F.
		lDev := .T.
		cOrigEst := GetMv("CAOAORESTR",,"610-019/610-020/610-046/610-047")
		cOrigRet := GetMv("CAOAORRETR",,"610-221/610-222")
	Elseif (cAliasQry)->Z7_XTABELA == "SF1" .and. !(cAliasQry)->Z7_TIPONF $ ("B/D")
		cOrigEst := GetMv("CAOAORESTP",,"650-004/650-005")
		cOrigRet := GetMv("CAOAORRETP",,"650-222/650-223/650-224/650-225")
	Elseif (cAliasQry)->Z7_XTABELA == "SE2"
		lSE2 := .T.
	Endif
	
	/*	
	//Exclusão SAP
	If (cAliasQry)->Z7_XOPESAP == 2 // 05/09/19
		If (cAliasQry)->Z7_XSEQUEN <> '001' .and. !U_ZF13GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN)
			(cAliasQry)->(dbSkip())
			LOOP
		EndIf
	Endif	
	*/	
	//Exclusão SAP
	If (cAliasQry)->Z7_XOPESAP == 2 // 05/09/19
		If (cAliasQry)->Z7_XSEQUEN <> '001' .and. !U_ZF13GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,(cAliasQry)->Z7_LOTEINC,.T.,,,,,,(cAliasQry)->SZ7_RECNO)
			(cAliasQry)->(dbSkip())
			LOOP
		EndIf
	Else
		If (cAliasQry)->Z7_XSEQUEN <> '001' .and. !U_ZF13GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,,.F.,(cAliasQry)->Z7_DOCORI,(cAliasQry)->Z7_SERORI,(cAliasQry)->Z7_TIPONF,(cAliasQry)->Z7_CLIFOR,(cAliasQry)->Z7_LOJA,(cAliasQry)->SZ7_RECNO)
			(cAliasQry)->(dbSkip())
			LOOP
		EndIf

		// verifica se tem registro de cancelamento associado com esta inclusao e neste caso, marca este e o registro de cancelamento
		// para nao ser enviado, pois se o registro jah foi cancelado/deletado, pode nao encontrar a contabilizacao e ate mesmo 
		// o proprio registro de inclusao
		If U_ZF18GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XLOTE,(cAliasQry)->SZ7_RECNO)
			(cAliasQry)->(dbSkip())
			LOOP
		EndIf
	Endif	
	
	//Exclusão SAP
	If (cAliasQry)->Z7_XOPESAP == 2
		//cMsgSoap := U_ZF14GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,{{"motivoOperacao","2"}})
		cMsgSoap := U_ZF15GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,{{"motivoOperacao","2"}})
	EndIf
	
	If !lDev
		If !lSE2
			// posiciona SF1, usar goto pois registro pode estar deletado
			SF1->(dbGoto((cAliasQry)->Z7_RECORI))
			If SF1->F1_FORMUL == "S"
				If !U_ZF09GENSAP(SF1->F1_ESPECIE,SF1->F1_CHVNFE,SF1->F1_FIMP,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FILIAL,SF1->F1_FORNECE,SF1->F1_LOJA, SF1->(DELETED()) )
					(cAliasQry)->(dbSkip())
					LOOP
				Endif
			Endif
		Else
			SE2->(dbGoto((cAliasQry)->Z7_RECORI))
			// titulos do eec, somente com moeda 1
			//If !U_ZGENSAPF01(.T.)
			If !U_ZF01GENSAP()
				(cAliasQry)->(dbSkip())
				LOOP
			Endif
			If SE2->E2_TIPO == MVPAGANT
				lAdt := .T.
			Endif
		Endif
	Else
		// posiciona SF2, usar goto pois registro pode estar deletado
		SF2->(dbGoto((cAliasQry)->Z7_RECORI))
		If !U_ZF09GENSAP(SF2->F2_ESPECIE,SF2->F2_CHVNFE,SF2->F2_FIMP,SF2->F2_DOC,SF2->F2_SERIE ,SF2->F2_FILIAL, SF2->F2_CLIENTE , SF2->F2_LOJA , SF2->(DELETED()) )
			(cAliasQry)->(dbSkip())
			LOOP
		Endif
	Endif
	
	// para inclusao no sap eh obrigatorio que esteja contabilizado, para exclusao nao precisa desta verificacao, pois se presume que a contabilizacao jah tenha sido excluida
	If !lSE2
		If (cAliasQry)->Z7_XOPESAP == 1 .and. Empty(IIf(!lDev,SF1->F1_DTLANC,SF2->F2_DTLANC))
			(cAliasQry)->(dbSkip())
			Help("",1,"Envio movimento SAP",,"Nota Fiscal não contabilizada.",1,0)
			LOOP
		EndIf
	Else
		// PA com moeda estrangeira nao necessita de contabilizacao para envio ao SAP
		//If (cAliasQry)->Z7_XOPESAP == 1 .and. !SE2->E2_LA == "S"
		//	(cAliasQry)->(dbSkip())
		//	LOOP
		//Endif
		
		// PA nao necessita de contabilizacao para envio ao SAP
		If (cAliasQry)->Z7_XOPESAP == 1 .and. !lAdt .and. !SE2->E2_LA == "S"
			(cAliasQry)->(dbSkip())
			Help("",1,"Envio movimento SAP",,"Título não contabilizado.",1,0)
			LOOP
		Endif
	Endif
	
	cTimeIni 	:= time()
	
	// verifica o titulo, se teve retencao, pois neste caso, a url de envio deve ser a mesma do cte. Somente titulos normais tem retencao, as devolucoes nao tem.
	If !lDev .and. !lSE2
		If !Empty(SF1->F1_DUPL)
			aAreaSE2 := SE2->(GetArea())
			// usar query, pois registro pode estar deletado na se2
			cQ := "SELECT MAX(SE2.R_E_C_N_O_) SE2_RECNO "
			cQ += "FROM "+retSQLName("SE2")+" SE2 "
			cQ += "WHERE "
			cQ += "E2_FILIAL = '"+SF1->F1_FILIAL+"' "
			cQ += "AND E2_FORNECE = '"+SF1->F1_FORNECE+"' "
			cQ += "AND E2_LOJA = '"+SF1->F1_LOJA+"' "
			cQ += "AND E2_PREFIXO = '"+SF1->F1_SERIE+"' "
			cQ += "AND E2_NUM = '"+SF1->F1_DUPL+"' "
			cQ += "AND E2_TIPO = '"+MVNOTAFIS+"' "
			if (cAliasQry)->Z7_XOPESAP == 2 //Se for exclusao, deve considerar somente os deletados
				cQ += "AND D_E_L_E_T_ = '*' "
			endif
			//cQ += "AND TRIM(E2_TIPO) IN "+FormatIn(cTiposFin,"/")+" "
			//cQ += "AND SE2.D_E_L_E_T_ = ' ' " // obs: ler registros deletados, pois titulo pode ter sido deletado jah
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasQry1,.T.,.T.)
			
			If (cAliasQry1)->(!Eof()) .and. !Empty((cAliasQry1)->SE2_RECNO)
				SE2->(dbGoto((cAliasQry1)->SE2_RECNO))
				if !(Alltrim(SF1->F1_ESPECIE) $ "SPED/NFE")
					nValRet += SE2->E2_IRRF+SE2->E2_ISS+SE2->E2_INSS+SE2->E2_PIS+SE2->E2_COFINS+SE2->E2_CSLL
				Endif
			Endif
			
			(cAliasQry1)->(dbCloseArea())
			SE2->(RestArea(aAreaSE2))
			/*
			SE2->(dbSetOrder(6))
			If SE2->(dbSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DUPL))
				While SE2->(!Eof()) .and. xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DUPL == ;
				SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM
					If SE2->E2_TIPO == MVNOTAFIS
					//If Alltrim(SE2->E2_TIPO) $ cTiposFin
						nValRet += SE2->E2_IRRF+SE2->E2_ISS+SE2->E2_INSS+SE2->E2_PIS+SE2->E2_COFINS+SE2->E2_CSLL
						Exit
					Endif
					SE2->(dbSkip())
				Enddo
			Endif
			*/
		Endif
	Endif
	
	If !lSE2
		If (Alltrim(SF1->F1_ESPECIE) $ cFrete .or. !Empty(nValRet)) .and. !lDev
			cRequest := ""
		Else
			cRequest := "Request"
		Endif
	Else
		cRequest := "Request"
	Endif
	
	cUrl 		:= IIf((!lDev .and. !lSE2 .and. (Alltrim(SF1->F1_ESPECIE) $ cFrete .or. !Empty(nValRet))),allTrim(superGetMv("CAOASAP03D")),allTrim( superGetMv( "CAOASAP03A", , "http://10.120.40.141:53400/dir/wsdl?p=ic/7e57f79630be3849a4ebcfa108259ed4")))
	xPostRet	:= httpQuote( cUrl /*<cUrl>*/, "GET" /*<cMethod>*/, /*[cGETParms]*/, /*[cPOSTParms]*/, nTimeOut /*[nTimeOut]*/, aHeadOut /*[aHeadStr]*/, @cHeadRet /*[@cHeaderRet]*/ )
	
	nStatuHttp	:= 0
	nStatuHttp	:= httpGetStatus()
	
	cTimeFin	:= time()
	cTimeProc	:= elapTime( cTimeIni, cTimeFin )
	
	conout(" [SAP] [CMVSAP03] * * * * * Status da integracao * * * * *"									)
	conout(" [SAP] [CMVSAP03] Inicio.......................: " + cTimeIni + " - " + dToC( dDataBase ) 	)
	conout(" [SAP] [CMVSAP03] Fim..........................: " + cTimeFin + " - " + dToC( dDataBase ) 	)
	conout(" [SAP] [CMVSAP03] Tempo de Processamento.......: " + cTimeProc 								)
	conout(" [SAP] [CMVSAP03] URL..........................: " + cUrl									)
	conout(" [SAP] [CMVSAP03] HTTP Method..................: " + "GET" 									)
	conout(" [SAP] [CMVSAP03] Status Http (200 a 299 ok)...: " + allTrim( str( nStatuHttp ) ) 			)
	conout(" [SAP] [CMVSAP03] Retorno......................: " + allTrim( xPostRet ) 					)
	conout(" [SAP] [CMVSAP03] * * * * * * * * * * * * * * * * * * * * "									)
	
	if nStatuHttp >= 200 .and. nStatuHttp <= 299
		memoWrite( "\" + funName() + ".wsdl", xPostRet )
		
		// Cria o objeto da classe TWsdlManager
		oWsdl := TWsdlManager():New()

		oWsdl:bNoCheckPeerCert := .T.
		
		oWsdl:lEnableOptAttr	:= .T.	// Habilita no comando SOAP de envio os atributos opcionais.
		oWsdl:lCheckInput		:= .F.	// Define se vai verificar as ocorrências dos parâmetros de entrada da mensagem SOAP que será enviada, quando essa não for uma mensagem personalizada.
		oWsdl:lUseNSPrefix		:= .T.	// Define se vai usar prefixo de namespace antes dos nomes das tags na mensagem SOAP que será enviada.
		
		// Utilizar SetProxy / SetCredentials dentro da rede Caoa
		/*
		oWsdl:SetProxy( cURLProxy, nPortProxy )
		lOk := oWsdl:GetProxy( cURLProxy, nPortProxy )
		if !lOk
			MsgStop( oWsdl:cError , "GetProxy ERROR")
			Return
		endif
		
		oWsdl:SetCredentials( cUserProxy, cPassProxy )
		lOk := oWsdl:GetCredentials( cUserProxy, cPassProxy )
		if !lOk
			MsgStop( oWsdl:cError , "GetCredentials ERROR")
			Return
		endif
		*/
		
		oWsdl:SetAuthentication( cUser, cPass )
		lOk := oWsdl:GetAuthentication( cUser, cPass )
		if !lOk
			MsgStop( oWsdl:cError , "SetAuthentication ERROR" )
			Return
		endif
		
		// Faz o parse de uma URL
		//xRet := oWsdl:ParseFile("\WSDL\Fornecedor_OutService.wsdl" )
		xRet := oWsdl:ParseFile( "\" + funName() + ".wsdl" )
		If !xRet
			conout( "Erro: " + oWsdl:cError )
			Return
		EndIf
		
		cZ7Filial	:= (cAliasQry)->Z7_FILIAL
		cZ7Tabela	:= (cAliasQry)->Z7_XTABELA
		cZ7Chave	:= (cAliasQry)->Z7_XCHAVE
		cZ7Sequen	:= (cAliasQry)->Z7_XSEQUEN
		
		aOps := oWsdl:ListOperations()
		If Len( aOps ) == 0
			conout( "Erro: " + oWsdl:cError )
			Return
		EndIf
		//varinfo( "", aOps )
		
		// Define a operação
		xRet := oWsdl:SetOperation( IIf((!lDev .and. (Alltrim(SF1->F1_ESPECIE) $ cFrete .or. !Empty(nValRet))),aOps[1][1],aOps[3][1])) // "CriaDocumento"
		If !xRet
			conout( "Erro: " + oWsdl:cError )
			Return
		EndIf
		
		If (cAliasQry)->Z7_XOPESAP <> 2
			If !lDev
				If !lSE2
					// verifica se gerou financeiro
					SE2->(dbSetOrder(6))
					If !Empty(SF1->F1_DUPL)
						If SE2->(dbSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DUPL))
							While SE2->(!Eof()) .and. xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DUPL == ;
								SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM
								If SE2->E2_TIPO == MVNOTAFIS
									//If Alltrim(SE2->E2_TIPO) $ cTiposFin
									lContinua := .T.
									if !(Alltrim(SF1->F1_ESPECIE) $ "SPED/NFE")
										nValRet += SE2->E2_IRRF+SE2->E2_ISS+SE2->E2_INSS+SE2->E2_PIS+SE2->E2_COFINS+SE2->E2_CSLL
									endif
									/*
									If !Empty(SE2->E2_IRRF)
									nTitWT++
									Endif
									If !Empty(SE2->E2_ISS)
									nTitWT++
									Endif
									If !Empty(SE2->E2_INSS)
									nTitWT++
									Endif
									If !Empty(SE2->E2_PIS)
									nTitWT++
									Endif
									If !Empty(SE2->E2_COFINS)
									nTitWT++
									Endif
									If !Empty(SE2->E2_CSLL)
									nTitWT++
									Endif
									*/
									//Exit
									If Empty(nRegSE2)
										nRegSE2 := SE2->(Recno())
									Endif
									//nTit++
								Endif
								SE2->(dbSkip())
							Enddo
						Endif
						// reposiciona no 1 registro novamente
						If !Empty(nRegSE2)
							SE2->(dbGoto(nRegSE2))
						Endif	
					Endif
					
					If !lContinua
						(cAliasQry)->(dbSkip())
						Loop
					Endif
					
					// posiciona fornecedor
					SA2->(dbSetOrder(1))
					SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
					
					// verifica se fornecedor jah foi enviado ao sap
					If Empty(SA2->A2_XCDSAP)
						U_ZF12GENSAP(	(cAliasQry)->Z7_FILIAL		,;	// Filial
						(cAliasQry)->Z7_XTABELA		,;	// Tabela
						(cAliasQry)->Z7_XCHAVE		,;	// Chave
						(cAliasQry)->Z7_XSEQUEN		,;	// Sequencia
						"E"				,;	// Status
						"Fornecedor sem código SAP gravado."+CRLF	,;	// Retorno
						""		)	// XML Envio
						(cAliasQry)->(dbSkip())
						Help("",1,"Envio movimento SAP",,"Fornecedor sem código SAP gravado.",1,0)
						Loop
					Endif
					
					// posiciona itens da nota
					SD1->(dbSetOrder(1))
					If SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
//						While SD1->(!Eof()) .and. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == ;
//							SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
//							cSD1 := cSD1+Alltrim(Str(SD1->(Recno())))+"/"
//							SD1->(dbSkip())
//						Enddo
//						cSD1 := Subs(cSD1,1,Len(cSD1)-1)  //alteração Ac.Fin
                        cSD1 := SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
						// reposiciona no 1 registro
						SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
					Endif
				Else
					nRegSE2 := SE2->(Recno())
					lContinua := .T.
					//nTit++
					
					// posiciona fornecedor
					SA2->(dbSetOrder(1))
					SA2->(dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
					
					// verifica se fornecedor jah foi enviado ao sap
					If Empty(SA2->A2_XCDSAP)
						U_ZF12GENSAP(	(cAliasQry)->Z7_FILIAL		,;	// Filial
						(cAliasQry)->Z7_XTABELA		,;	// Tabela
						(cAliasQry)->Z7_XCHAVE		,;	// Chave
						(cAliasQry)->Z7_XSEQUEN		,;	// Sequencia
						"E"				,;	// Status
						"Fornecedor sem código SAP gravado."+CRLF	,;	// Retorno
						""		)	// XML Envio
						(cAliasQry)->(dbSkip())
						Help("",1,"Envio movimento SAP",,"Fornecedor sem código SAP gravado.",1,0)
						Loop
					Endif
				Endif
			Else
				// verifica se gerou financeiro
				SE2->(dbSetOrder(6))
				If !Empty(SF2->F2_DUPL)
					If SE2->(dbSeek(xFilial("SE2")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DUPL))
						While SE2->(!Eof()) .and. xFilial("SE2")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DUPL == ;
							SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM
							If SE2->E2_TIPO == "NDF" //MV_CPNEG // nao usar mv_cpneg, pois vem mais de um tipo nesta variavel
								lContinua := .T.
								/*
								If !Empty(SE2->E2_IRRF)
								nTitWT++
								Endif
								If !Empty(SE2->E2_ISS)
								nTitWT++
								Endif
								If !Empty(SE2->E2_INSS)
								nTitWT++
								Endif
								If !Empty(SE2->E2_PIS)
								nTitWT++
								Endif
								If !Empty(SE2->E2_COFINS)
								nTitWT++
								Endif
								If !Empty(SE2->E2_CSLL)
								nTitWT++
								Endif
								*/
								//Exit
								If Empty(nRegSE2)
									nRegSE2 := SE2->(Recno())
								Endif
								//nTit++
							Endif
							SE2->(dbSkip())
						Enddo
					Endif
					// reposiciona no 1 registro novamente
					If !Empty(nRegSE2)
						SE2->(dbGoto(nRegSE2))
					Endif	
				Endif
				
				If !lContinua
					(cAliasQry)->(dbSkip())
					Loop
				Endif
				
				// posiciona fornecedor
				SA2->(dbSetOrder(1))
				SA2->(dbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA))
				
				// verifica se fornecedor jah foi enviado ao sap
				If Empty(SA2->A2_XCDSAP)
					U_ZF12GENSAP(	(cAliasQry)->Z7_FILIAL		,;	// Filial
					(cAliasQry)->Z7_XTABELA		,;	// Tabela
					(cAliasQry)->Z7_XCHAVE		,;	// Chave
					(cAliasQry)->Z7_XSEQUEN		,;	// Sequencia
					"E"				,;	// Status
					"Fornecedor sem código SAP gravado."+CRLF	,;	// Retorno
					""		)	// XML Envio
					(cAliasQry)->(dbSkip())
					Help("",1,"Envio movimento SAP",,"Fornecedor sem código SAP gravado.",1,0)
					Loop
				Endif
				
				// posiciona itens da nota
				SD2->(dbSetOrder(3))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
//					While SD2->(!Eof()) .and. xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
//						cSD2 := cSD2+Alltrim(Str(SD2->(Recno())))+"/"
//						SD2->(dbSkip())
//					Enddo
//					cSD2 := Subs(cSD2,1,Len(cSD2)-1)  //alteração Ac.Fin
					cSD2 := SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
					// reposiciona no 1 registro
					SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					// posiciona pedido
					SC6->(dbSetOrder(1))
					SC6->(xFilial("SC6")+SD2->D2_PEDIDO)
				Endif
			Endif
			
			// posiciona natureza
			SED->(dbSetOrder(1))
			SED->(dbSeek(xFilial("SED")+SE2->E2_NATUREZ))
			
			cIDLote		:= (cAliasQry)->Z7_XLOTE
			//cFilAtu		:= IIf(!lDev,IIf(!lSE2,SF1->F1_FILIAL,SE2->E2_FILIAL),SF2->F2_FILIAL)
			//cCT2Atu		:= IIf(!lDev,SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_FORMUL ),SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL ))
			//nSZ7Recno	:= (cAliasQry)->SZ7_RECNO
			
			aAux		:= {}
			aDocHeader	:= {} // tag DocumentHeader
			aAccountGL	:= {} // tag AccountGL
			aAccPayabl	:= {} // tag AccountPayable
			aAccountWT	:= {} // tag AccountWT -> Sera preenchido apenas em casos de retencao
			aAccountEstGL := {}
			
			If !lSE2
				If !lDev
					cDocSAP := U_ZF07GENSAP(IIf(!Empty(SD1->D1_PEDIDO),SD1->D1_PEDIDO,SF1->F1_DOC))
					cRefSAP := U_ZF07GENSAP(SF1->F1_DOC)
				Else
					cDocSAP := U_ZF07GENSAP(SD2->D2_NFORI)
					cRefSAP := cDocSAP
					cDocSAPDev := U_ZF07GENSAP(SF2->F2_DOC) //FormatDocSAP(SF2->F2_DOC)
				Endif
			Else
				cDocSAP := U_ZF07GENSAP(SE2->E2_NUM)
				cRefSAP := cDocSAP
			Endif
						
			aadd( aAux , { "empresa"					, left( allTrim( IIf(!lDev,IIf(!lSE2,SF1->F1_FILIAL,SE2->E2_FILIAL),SF2->F2_FILIAL) ) , 4 ) }  )				// tag empresa
			//aadd( aAux , { "divisao"					, left( allTrim( (cAliasQry)->F1_FILIAL ) , 5 ) } )											// tag divisao
			aadd( aAux , { "divisao"					, cDivisao } )											// tag divisao
			aadd( aAux , { "filial"						, right( allTrim( IIf(!lDev,IIf(!lSE2,SF1->F1_FILIAL,SE2->E2_FILIAL),SF2->F2_FILIAL) ) , 4 ) } )				// tag filial
			aadd( aAux , { "dataDocumento"				, left( fwTimeStamp( 5 , SE2->E2_EMISSAO ) , 10 ) } )	// tag dataDocumento
			aadd( aAux , { "tipoDocumento"				, SED->ED_XTIPO } )														// tag TipoDocumento
			aadd( aAux , { "dataLancamentoDocumento"	, left( fwTimeStamp( 5 , SE2->E2_EMIS1 )  , 10 ) } )		// tag dataLancamentoDocumento
			//aadd( aAux , { "numeroDocumentoReferencia"	, IIf(!lDev,IIf(!lSE2,Alltrim(SF1->F1_DOC)+IIf(!Empty(SF1->F1_SERIE),"/"+Alltrim(SF1->F1_SERIE),""),Alltrim(SE2->E2_NUM)+IIf(!Empty(SE2->E2_PREFIXO),"/"+Alltrim(SE2->E2_PREFIXO),"")),Alltrim(SF2->F2_DOC)+IIf(!Empty(SF2->F2_SERIE),"/"+Alltrim(SF2->F2_SERIE),"")) } )							// tag numeroDocumentoReferencia
			//aadd( aAux , { "numeroDocumentoReferencia"	, IIf(!lDev,IIf(!lSE2,Alltrim(cDocSAP)+IIf(!Empty(SF1->F1_SERIE),"/"+Alltrim(SF1->F1_SERIE),""),Alltrim(cDocSAP)+IIf(!Empty(SE2->E2_PREFIXO),"/"+Alltrim(SE2->E2_PREFIXO),"")),Alltrim(cDocSAPDev)+IIf(!Empty(SF2->F2_SERIE),"/"+Alltrim(SF2->F2_SERIE),"")) } )							// tag numeroDocumentoReferencia
			aadd( aAux , { "numeroDocumentoReferencia"	, IIf(!lDev,IIf(!lSE2,Alltrim(cRefSAP)+IIf(!Empty(SF1->F1_SERIE),"/"+Alltrim(SF1->F1_SERIE),""),Alltrim(cRefSAP)+IIf(!Empty(SE2->E2_PREFIXO),"/"+Alltrim(SE2->E2_PREFIXO),"")),Alltrim(cDocSAPDev)+IIf(!Empty(SF2->F2_SERIE),"/"+Alltrim(SF2->F2_SERIE),"")) } )							// tag numeroDocumentoReferencia
			//aadd( aAux , { "chaveCabecalho1"			, IIf(!lDev,SD1->D1_CHASSI,SC6->C6_CHASSI) } )											// tag chaveCabecalho1
			//aadd( aAux , { "chaveCabecalho1"			, IIf(!lDev,IIf(!lSE2,IIf(Empty(SD1->D1_CHASSI),Alltrim(SF1->F1_DOC)+IIf(!Empty(SF1->F1_SERIE),"/"+Alltrim(SF1->F1_SERIE),""),Alltrim(SD1->D1_CHASSI)),Alltrim(SE2->E2_NUM)+IIf(!Empty(SE2->E2_PREFIXO),"/"+Alltrim(SE2->E2_PREFIXO),"")),IIf(Empty(SC6->C6_CHASSI),Alltrim(SF2->F2_DOC)+IIf(!Empty(SF2->F2_SERIE),"/"+Alltrim(SF2->F2_SERIE),""),Alltrim(SC6->C6_CHASSI))) } )											// tag chaveCabecalho1
			aadd( aAux , { "chaveCabecalho1"			, IIf(!lDev,IIf(!lSE2,IIf(Empty(SD1->D1_CHASSI),Alltrim(cDocSAP)+IIf(!Empty(SF1->F1_SERIE),"/"+Alltrim(SF1->F1_SERIE),""),Alltrim(SD1->D1_CHASSI)),Alltrim(cDocSAP)+IIf(!Empty(SE2->E2_PREFIXO),"/"+Alltrim(SE2->E2_PREFIXO),"")),IIf(Empty(SC6->C6_CHASSI),Alltrim(cDocSAP)+IIf(!Empty(SD2->D2_SERIORI),"/"+Alltrim(SD2->D2_SERIORI),""),Alltrim(SC6->C6_CHASSI))) } )											// tag chaveCabecalho1
			aadd( aAux , { "chaveCabecalho2"			, " " } )																// tag chaveCabecalho2
			aadd( aAux , { "textoCabecalhoDocumento"	, " " } )																// tag textoCabecalhoDocumento
			//aadd( aAux , { "motivoOperacao"				, IIf(!lSE2,"1","3") } )																// tag motivoOperacao
			aadd( aAux , { "motivoOperacao"				, IIf(!lAdt,"1","3") } )																// tag motivoOperacao
			
			if SE2->E2_MOEDA <> 1
				aadd( aAux , { "dataconversao" , left( fwTimeStamp( 5 , SE2->E2_EMIS1 ) , 10 ) } )				// tag dataconversao
			endif
			
			aadd( aDocHeader , aAux )
			
			cUltimoCT2	:= ""
			
			nNum := 0
			nNumEst := 0
			
			//If !lSE2
			If !lAdt
				cQ := " SELECT MAX(CT2_SEQUEN) CT2_SEQUEN "
				cQ += " FROM " + RetSqlName("CT2") + " CT2 " + CRLF
				cQ += " INNER JOIN " + RetSqlName("CV3") + " CV3 " + CRLF
				cQ += " ON TRIM(CV3.CV3_RECDES) = TRIM(CT2.R_E_C_N_O_) "
				cQ += " AND CV3.D_E_L_E_T_ <> '*' "
				cQ += " AND CT2.D_E_L_E_T_ <> '*' " + CRLF
				cQ += " WHERE " + CRLF
				//cQ += " CV3.CV3_RECORI = '"+ALLTRIM(STR(SD1->(Recno())))+"' AND CV3.CV3_TABORI='SD2' AND CT2.CT2_TPSALD = '1' "
				If !lSE2
					If !lDev
//						cQ += " CV3.CV3_RECORI IN "+FormatIn(cSD1,"/")+" "  //Ac.Fin
						cQ += " CV3.CV3_KEY LIKE '" + cSD1 + "%'  "
						cQ += " AND CV3.CV3_TABORI = 'SD1' "
						cQ += " AND CT2.CT2_TPSALD = '1' "
						cQ += " AND CT2_LP = '650' "
					Else
//						cQ += " CV3.CV3_RECORI IN "+FormatIn(cSD2,"/")+" "
						cQ += " CV3.CV3_KEY LIKE '" + cSD2 + "%'  "
						cQ += " AND CV3.CV3_TABORI = 'SD2' "
						cQ += " AND CT2.CT2_TPSALD = '1' "
						cQ += " AND CT2_LP = '610' "
					Endif
				Else
					cQ += " CV3.CV3_RECORI = '"+Alltrim(Str(SE2->(Recno())))+"' "
					cQ += " AND CV3.CV3_TABORI = 'SE2' "
					cQ += " AND CT2.CT2_TPSALD = '1' "
					cQ += " AND CT2_LP IN ('510','511') "
				Endif
				If !lSE2
					cQ += " AND SUBSTR(CT2_ORIGEM,1,7) NOT IN "+FormatIn(cOrigRet,"/")+" "
				Endif
				
				tcQuery cQ new Alias (cAliasQry1)
				
				If !(cAliasQry1)->(EOF()) .and. !Empty((cAliasQry1)->CT2_SEQUEN)
					cSeq := (cAliasQry1)->CT2_SEQUEN
				Endif
				
				(cAliasQry1)->(dbCloseArea())
				
				cQ := " SELECT DISTINCT " + CRLF
				cQ += " CT2.CT2_LINHA				, " + CRLF
				cQ += " CT2.CT2_DC					, " + CRLF
				cQ += " CT2.CT2_DEBITO				, " + CRLF
				cQ += " CT2.CT2_CREDIT				, " + CRLF
				cQ += " CT2.CT2_HIST 				, " + CRLF
				cQ += " CT2.CT2_CLVLDB				, " + CRLF
				cQ += " CT2.CT2_CLVLCR				, " + CRLF
				cQ += " CT2.CT2_VALOR				, " + CRLF
				cQ += " CT2.CT2_HIST 				, " + CRLF
				cQ += " CT2.CT2_CCC  				, " + CRLF
				cQ += " CT2.CT2_CCD  				, " + CRLF
				cQ += " CT2.CT2_ORIGEM				, " + CRLF
				cQ += " CT2.CT2_AT01CR				, " + CRLF
				cQ += " CT2.CT2_AT01DB				  " + CRLF
				cQ += " FROM " + RetSqlName("CT2") + " CT2 " + CRLF
				cQ += " INNER JOIN " + RetSqlName("CV3") + " CV3 " + CRLF
				cQ += " ON TRIM(CV3.CV3_RECDES) = TRIM(CT2.R_E_C_N_O_) "
				cQ += " AND CV3.D_E_L_E_T_ <> '*' "
				cQ += " AND CT2.D_E_L_E_T_ <> '*' " + CRLF
				cQ += " WHERE " + CRLF
				//cQ += " CV3.CV3_RECORI = '"+ALLTRIM(STR(SD1->(Recno())))+"' AND CV3.CV3_TABORI='SD2' AND CT2.CT2_TPSALD = '1' "
				If !lSE2
					If !lDev
//						cQ += " CV3.CV3_RECORI IN "+FormatIn(cSD1,"/")+" "  //Ac.Fin
						cQ += " CV3.CV3_KEY LIKE '" + cSD1 + "%'  "
						cQ += " AND CV3.CV3_TABORI = 'SD1' "
						cQ += " AND CT2.CT2_TPSALD = '1' "
						cQ += " AND CT2_LP = '650' "
					Else
//						cQ += " CV3.CV3_RECORI IN "+FormatIn(cSD2,"/")+" "   //Ac. Fin
						cQ += " CV3.CV3_KEY LIKE '" + cSD2 + "%'  "
						cQ += " AND CV3.CV3_TABORI = 'SD2' "
						cQ += " AND CT2.CT2_TPSALD = '1' "
						cQ += " AND CT2_LP = '610' "
					Endif
				Else
					cQ += " CV3.CV3_RECORI = '"+Alltrim(Str(SE2->(Recno())))+"' "
					cQ += " AND CV3.CV3_TABORI = 'SE2' "
					cQ += " AND CT2.CT2_TPSALD = '1' "
					cQ += " AND CT2_LP IN ('510','511') "
				Endif
				cQ += " AND CT2_SEQUEN = '"+cSeq+"' "
				If !lSE2
					cQ += " AND SUBSTR(CT2_ORIGEM,1,7) NOT IN "+FormatIn(cOrigRet,"/")+" "
				Endif
				cQ += " ORDER BY CT2_LINHA "
				
				//memoWrite( "C:\TEMP\CMVSAP03.TXT",cQ )
				
				tcQuery cQ new Alias (cAliasQry1)
				
				// se nao achar contabilizacao, nao prossegue
				If (cAliasQry1)->(Eof())
					(cAliasQry1)->(dbCloseArea())
					//U_ZF12GENSAP(	cZ7Filial		,;	// Filial
					//			cZ7Tabela		,;	// Tabela
					//			cZ7Chave		,;	// Chave
					//			cZ7Sequen		,;	// Sequencia
					//			"E"				,;	// Status
					//			"Não encontrado contabilização com saldo tipo 1 ( Real ), para este documento."+CRLF	,;	// Retorno
					//			""		)	// XML Envio
					(cAliasQry)->(dbSkip())
					Help("",1,"Envio movimento SAP",,"Movimento contabilizado com inconsistência.",1,0)
					LOOP
				EndIf
				
				while !(cAliasQry1)->(EOF())
					
					//****************************************
					// Inicio aAccountGL
					//****************************************
					aAux := {}
					
					// desconsidera esta linha/valor do accountgl pois deverah aparecer no aAccPayabl
					//If IIf(!lDev,!Empty((cAliasQry1)->CT2_AT01CR),!Empty((cAliasQry1)->CT2_AT01DB))
					If !Empty((cAliasQry1)->CT2_AT01CR) .or. !Empty((cAliasQry1)->CT2_AT01DB)
						//nAtiv := (cAliasQry1)->CT2_VALOR+nValRet
						If !Empty((cAliasQry1)->CT2_AT01CR)
							lInvSinal := .T.
							//nAtiv := (cAliasQry1)->CT2_VALOR * -1
							//ElseIf !Empty((cAliasQry1)->CT2_AT01DB)
							//nAtiv := (cAliasQry1)->CT2_VALOR
						Endif
						(cAliasQry1)->(DBSkip())
						Loop
					Endif
					
					If !Subs((cAliasQry1)->CT2_ORIGEM,1,7) $ cOrigEst
						nNum++
					Else
						nNumEst++
					Endif
					//aadd( aAux , { "numeroItemDocumentoContabilidade" , allTrim( str( (cAliasQry1)->CT2RECNO ) ) } )	// numeroItemDocumentoContabilidade
					aadd( aAux , { "numeroItemDocumentoContabilidade" , ALLTRIM(STR(IIf(!Subs((cAliasQry1)->CT2_ORIGEM,1,7) $ cOrigEst,nNum,nNumEst))) } )	// numeroItemDocumentoContabilidade
					
					if (cAliasQry1)->CT2_DC == "1"
						aadd( aAux , { "contaRazaoContabilidadeGeral" , allTrim( (cAliasQry1)->CT2_DEBITO ) } )					// contaRazaoContabilidadeGeral
					elseif (cAliasQry1)->CT2_DC == "2"
						aadd( aAux , { "contaRazaoContabilidadeGeral" , allTrim( (cAliasQry1)->CT2_CREDIT ) } )					// contaRazaoContabilidadeGeral
					endif
					
					aadd( aAux , { "divisao"		, cDivisao } )										// divisao
					aadd( aAux , { "textoItem"	, (cAliasQry1)->CT2_HIST } )											// textoItem
					
					//if (!lDev .and. allTrim( SF1->F1_ESPECIE ) $ cGeraPorNF) .or. lDev
					//aadd( aAux , { "numeroAtribuicao"						, Alltrim(IIf(!lDev,SF1->F1_DOC,SF2->F2_DOC)) } )											//	numeroAtribuicao
					aadd( aAux , { "numeroAtribuicao"						, Alltrim(cDocSAP) } )											//	numeroAtribuicao
					//else
					//	aadd( aAux , { "numeroAtribuicao"		, "" } )
					//endif
					
					if (cAliasQry1)->CT2_DC == "1"
						if !empty( (cAliasQry1)->CT2_CCD )
							aadd( aAux , { "centroCusto"		, allTrim( (cAliasQry1)->CT2_CCD ) } )
						else
							aadd( aAux , { "centroCusto"		, " " } )
						endif
					elseif (cAliasQry1)->CT2_DC == "2"
						if !empty( (cAliasQry1)->CT2_CCC )
							aadd( aAux , { "centroCusto"		, allTrim( (cAliasQry1)->CT2_CCC ) } )
						else
							aadd( aAux , { "centroCusto"		, " " } )
						endif
					endif
					
					if (cAliasQry1)->CT2_DC == "1"
						if !empty( (cAliasQry1)->CT2_CLVLDB ) .and. Empty((cAliasQry1)->CT2_CCD)
							aadd( aAux , { "centroLucro"		, allTrim( (cAliasQry1)->CT2_CLVLDB ) } )
						else
							aadd( aAux , { "centroLucro"		, " " } )
						endif
					elseif (cAliasQry1)->CT2_DC == "2"
						if !empty( (cAliasQry1)->CT2_CLVLCR ) .and. Empty((cAliasQry1)->CT2_CCC)
							aadd( aAux , { "centroLucro"		, allTrim( (cAliasQry1)->CT2_CLVLCR ) } )
						else
							aadd( aAux , { "centroLucro"		, " " } )
						endif
					endif
					
					aadd( aAux , { "tipoDocumento"				, SED->ED_XTIPO } )														// tag TipoDocumento
					
					aadd( aAux , { "numeroOrdem"			, " " } )													// numeroOrdem
					aadd( aAux , { "segmento"				, " " } )													// segmento
					
					if (cAliasQry1)->CT2_DC == "1"
						aadd( aAux , { "montanteMoedaPagamento"	, allTrim( str( (cAliasQry1)->CT2_VALOR ) ) } )						// montanteMoedaPagamento
					elseif (cAliasQry1)->CT2_DC == "2"
						aadd( aAux , { "montanteMoedaPagamento"	, allTrim( str( ( (cAliasQry1)->CT2_VALOR * -1 ) ) ) } )				// montanteMoedaPagamento
					endif
					
					If !Subs((cAliasQry1)->CT2_ORIGEM,1,7) $ cOrigEst
						aadd( aAccountGL , aAux )
					Else
						aadd( aAccountEstGL , aAux )
					Endif
					
					//****************************************
					// Fim aAccountGL
					//****************************************
					
					cUltimoCT2 := (cAliasQry1)->CT2_LINHA
					
					(cAliasQry1)->(DBSkip())
				enddo
				
				(cAliasQry1)->(dbCloseArea())
				
				// nao encontrou contabilizacao, ou a mesma nao atendeu a regra
				If Empty(aAccountGL) .and. Empty(aAccountEstGL)
					(cAliasQry)->(dbSkip())
					Help("",1,"Envio movimento SAP",,"Movimento contabilizado com inconsistência.",1,0)
					LOOP
				EndIf
				
			Endif
			
			//nNum++ // 05/09/19
			
			//****************************************
			// Inicio aAccPayabl
			//****************************************
			// reposiciona no 1 registro novamente
			SE2->(dbSetOrder(6))
			If !Empty(nRegSE2)
				SE2->(dbGoto(nRegSE2))
			Endif	
			cChaveTit := IIf(lSE2,SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM,IIf(!lDev,xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DUPL,xFilial("SE2")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DUPL))
			While SE2->(!Eof()) .and. cChaveTit == SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM
				If !lSE2 // para titulo nao precisa fazer a verificao abaixo, pois o registro a ser processado eh o que estah posicionado, nao serao todas as parcelas
					If !SE2->E2_TIPO == IIf(!lDev,MVNOTAFIS,"NDF")
						SE2->(dbSkip())
						Loop
					Endif
				Endif		
			
				nNum++
				aAux := {}
				//aadd( aAux , { "idExterno"								, "T"+(cAliasQry)->Z7_XTABELA+(cAliasQry)->Z7_TIPONF+SE2->E2_PARCELA+allTrim(str(IIf(!lDev,SF1->(Recno()),SF2->(Recno()))))})
				aadd( aAux , { "idExterno"								, "T"+allTrim(str((cAliasQry)->SZ7_RECNO))})
				//aadd( aAux , { "numeroItemDocumentoContabilidade"		, allTrim( str( (cAliasQry)->CT2RECNO ) ) } )
				aadd( aAux , { "numeroItemDocumentoContabilidade"		, ALLTRIM(STR(nNum)) } )
				aadd( aAux , { "numeroContaFornecedor"					, allTrim( SA2->A2_CGC ) } )
				aadd( aAux , { "chaveReferenciaParceiroNegocios1"		, IIf(!lDev,IIf(!lSE2,SD1->D1_PLACA," ")," ") } )
				aadd( aAux , { "chaveReferenciaParceiroNegocios2"		, " " } )
				aadd( aAux , { "chaveReferenciaParceiroNegocios3"		, left( IIf(!lDev,IIf(!lSE2,SF1->F1_XUSR," ")," ") , 20 ) } )
				aadd( aAux , { "empresa"								, left( allTrim( IIf(!lDev,IIf(!lSE2,SF1->F1_FILIAL,SE2->E2_FILIAL),SF2->F2_FILIAL) ) , 4 ) } )
				aadd( aAux , { "divisao"								, cDivisao } )											//	divisao
				aadd( aAux , { "dataBaseCalculoVencimento"				, left( fwTimeStamp( 5 , SE2->E2_EMISSAO ) , 10 ) } )	//	dataBaseCalculoVencimento
				aadd( aAux , { "diasDesconto1"							, allTrim( str( SE2->E2_VENCTO - SE2->E2_EMISSAO ) ) } )	//	diasDesconto1
				aadd( aAux , { "formaPagamento"							, " " } )																//	formaPagamento
				aadd( aAux , { "chaveBloqueioPagamento"					, "A" } )																//	chaveBloqueioPagamento
				
				// tratamento para campo de parcela
				//cParc := IIf(Empty(SE2->E2_PARCELA),"1",Alltrim(Str(Val(SE2->E2_PARCELA))))
				If Empty(SE2->E2_PARCELA)
					cParc := "1"
				Else	
					For nCnt := 1 To Len(SE2->E2_PARCELA)
						If !IsDigit(Subs(SE2->E2_PARCELA,nCnt,1))
							lIsDigParc := .F.
							Exit
						Endif
						If lIsDigParc
							cParc := IIf(Empty(SE2->E2_PARCELA),"1",Alltrim(Str(Val(SE2->E2_PARCELA))))
						Else
							cParc := SE2->E2_PARCELA
						Endif	
					Next
				Endif	
				
				aadd( aAux , { "numeroAtribuicao"		, Alltrim(cDocSAP)+"-"+cParc } )				
				aadd( aAux , { "textoITem"								, " " } )																//	textoITem
				aadd( aAux , { "filial"									, right( allTrim( IIf(!lDev,IIf(!lSE2,SF1->F1_FILIAL,SE2->E2_FILIAL),SF2->F2_FILIAL) ) , 4 ) } )				//	filial
				
				//If !lSE2
				If !lAdt
					if !lSE2 .and. Alltrim(SF1->F1_ESPECIE) $ "SPED/NFE"
						aadd( aAux , { "montanteMoedaPagamento"	, allTrim( str( IIf(lInvSinal,(SE2->E2_VALOR)*-1,SE2->E2_VALOR)) ) } )														//	montanteMoedaPagamento
					else
						//aadd( aAux , { "montanteMoedaPagamento"	, allTrim( str( IIf(lInvSinal,nAtiv * -1,nAtiv)) ) } )														//	montanteMoedaPagamento
						aadd( aAux , { "montanteMoedaPagamento"	, allTrim( str( IIf(lInvSinal,(SE2->E2_VALOR+SE2->E2_IRRF+SE2->E2_ISS+SE2->E2_INSS+SE2->E2_PIS+SE2->E2_COFINS+SE2->E2_CSLL)*-1,(SE2->E2_VALOR+SE2->E2_IRRF+SE2->E2_ISS+SE2->E2_INSS+SE2->E2_PIS+SE2->E2_COFINS+SE2->E2_CSLL))) ) } )														//	montanteMoedaPagamento
					endif
				Else
					//aadd( aAux , { "montanteMoedaPagamento"	, allTrim( str( (SE2->E2_VALOR+nValRet) ) ) } )														//	montanteMoedaPagamento
					aadd( aAux , { "montanteMoedaPagamento"	, allTrim( str( (SE2->E2_VALOR+SE2->E2_IRRF+SE2->E2_ISS+SE2->E2_INSS+SE2->E2_PIS+SE2->E2_COFINS+SE2->E2_CSLL) ) ) } )														//	montanteMoedaPagamento
				Endif
				
				//if lSE2 //Alltrim(SE2->E2_TIPO) == MVPAGANT
				if lAdt
					aadd( aAux , { "codigoRazaoEspecial"	, "F" } )																			//	codigoRazaoEspecial
				else
					aadd( aAux , { "codigoRazaoEspecial"	, " " } )																			//	codigoRazaoEspecial
				endif
				
				if SE2->E2_MOEDA <> 1
					aadd( aAux , { "moeda"	, " " } )																						//	moeda
					aadd( aAux , { "taxacambio"	, Alltrim(Str(SE2->E2_TXMOEDA)) } )																// taxacambio
				endif
				
				If lSE2
					if !empty(SE2->E2_CLVL)
						aadd( aAux , { "centroLucro"		, allTrim(SE2->E2_CLVL) } )
					else
						aadd( aAux , { "centroLucro"		, " " } )
					endif
				Endif
				
				aadd( aAccPayabl , aAux )
				//****************************************
				// Fim aAccPayabl
				//****************************************
				
				// AccountWT
				IF !Empty(SE2->E2_IRRF)
					TagAccWT(nNum,"TX ",SE2->E2_BASEIRF,SE2->E2_IRRF,@aAccountWT,GetMv("CAOASAP03E",,"2305"),lSE2)
				Endif
				
				IF !Empty(SE2->E2_ISS)
					TagAccWT(nNum,"ISS",SE2->E2_BASEISS,SE2->E2_ISS,@aAccountWT,GetMv("CAOASAP03F",,"2304"),lSE2)
				Endif
				
				IF !Empty(SE2->E2_INSS)
					TagAccWT(nNum,"INS",SE2->E2_BASEINS,SE2->E2_INSS,@aAccountWT,GetMv("CAOASAP03G",,"2306"),lSE2)
				Endif
				
				IF !Empty(SE2->E2_PIS)
					TagAccWT(nNum,"TX ",SE2->E2_BASEPIS,SE2->E2_PIS,@aAccountWT,GetMv("CAOASAP03H",,"2301"),lSE2)
				Endif
				
				IF !Empty(SE2->E2_COFINS)
					TagAccWT(nNum,"TX ",SE2->E2_BASECOF,SE2->E2_COFINS,@aAccountWT,GetMv("CAOASAP03I",,"2302"),lSE2)
				Endif
				
				IF !Empty(SE2->E2_CSLL)
					TagAccWT(nNum,"TX ",SE2->E2_BASECSL,SE2->E2_CSLL,@aAccountWT,GetMv("CAOASAP03J",,"2303"),lSE2)
				Endif

				If lSE2 // para titulo, considerar somente a parcela que estah gerada na sz7
					Exit
				Endif	
			
				SE2->(dbSkip())
		
			enddo
			
			aComplex := oWsdl:NextComplex()
			while ValType( aComplex ) == "A"
				//varinfo( "aComplex", aComplex )
				
				nOccurs := 1
				
				If aComplex[2] == "documentos"
					nOccurs := IIf(!Empty(aAccountGL) .and. !Empty(aAccountEstGL),2,1) //1
				ElseIf aComplex[2] == "DocumentHeader"
					nOccurs := 1
				ElseIf aComplex[2] == "AccountGL"
					If !Empty(aAccountGL) .and. !Empty(aAccountEstGL)
						If aComplex[5] == "ContasAPagar"+cRequest+"#1.documentos#1"
							nOccurs := len( aAccountGL )
						Elseif aComplex[5] == "ContasAPagar"+cRequest+"#1.documentos#2"
							nOccurs := len( aAccountEstGL )
						Endif
					Elseif !Empty(aAccountGL)
						nOccurs := len( aAccountGL )
					Elseif !Empty(aAccountEstGL)
						nOccurs := len( aAccountEstGL )
					Else
						nOccurs := 0
					Endif
				ElseIf aComplex[2] == "AccountPayable"
					If aComplex[5] == "ContasAPagar"+cRequest+"#1.documentos#1"
						nOccurs := len( aAccPayabl ) //nTit
					Else
						nOccurs := 0
					Endif
				ElseIf aComplex[2] == "AccountWT"
					//nOccurs := len( aAccountWT )
					If aComplex[5] == "ContasAPagar"+cRequest+"#1.documentos#1"
						nOccurs := len( aAccountWT )
					Else
						nOccurs := 0
					Endif
				EndIf
				
				xRet := oWsdl:SetComplexOccurs( aComplex[1], nOccurs )
				If xRet == .F.
					conout( "Erro ao definir elemento " + aComplex[2] + ", ID " + cValToChar( aComplex[1] ) + ", com " + cValToChar( nOccurs ) + " ocorrencias" )
					Return
				EndIf
				
				aComplex := oWsdl:NextComplex()
			EndDo
			
			aSimple := oWsdl:SimpleInput()
			//varinfo( " ", aSimple )
			
			cMsgLogs	:= " "
			
			//cMsgLogs += varinfo( "aDocHeader"	, aDocHeader )
			//cMsgLogs += varinfo( "aAccountGL"	, aAccountGL )
			//cMsgLogs += varinfo( "aAccPayabl"	, aAccPayabl )
			//cMsgLogs += varinfo( "aAccountWT"	, aAccountWT )
			//cMsgLogs += varinfo( "aSimple"		, aSimple )
			memoWrite( "\cMsgLogs.txt", cMsgLogs )
			
			lContinua := .T.
			
			nCount := IIf(!Empty(aAccountGL) .and. !Empty(aAccountEstGL),2,1)
			For nCnt:=1 To nCount
				for nI := 1 to len( aDocHeader )
					for nJ := 1 to len( aDocHeader[ nI ] )
						If nCnt == 2
							If aDocHeader[nI][nJ][1] == "tipoDocumento"
								aDocHeader[nI][nJ][2] := "WZ"
							Endif
						Endif
						nPos := 0
						If nCnt == 1
							nPos := aScan( aSimple, {|aVet| aVet[2] == aDocHeader[ nI , nJ, 1 ] .and. aVet[5] == "ContasAPagar"+cRequest+"#1.documentos#1.DocumentHeader#" + allTrim( str( nI ) ) } )
						Else
							nPos := aScan( aSimple, {|aVet| aVet[2] == aDocHeader[ nI , nJ, 1 ] .and. aVet[5] == "ContasAPagar"+cRequest+"#1.documentos#2.DocumentHeader#" + allTrim( str( nI ) ) } )
						Endif
						if nPos > 0
							xRet := oWsdl:SetValue( aSimple[nPos][1], aDocHeader[ nI , nJ, 2 ] )
							
							If !xRet
								U_ZF12GENSAP(	cZ7Filial		,;	// Filial
								cZ7Tabela		,;	// Tabela
								cZ7Chave		,;	// Chave
								cZ7Sequen		,;	// Sequencia
								"E"				,;	// Status
								"Erro no campo: " + aDocHeader[ nI , nJ, 1 ] + " Conteudo: " + aDocHeader[ nI , nJ, 2 ] + " Erro: " + oWsdl:cError	,;	// Retorno
								""		)	// XML Envio
								
								lContinua := .F.
							EndIf
						endif
					next
				next
			Next
			
			//cMsgSoap1 := " "
			//cMsgSoap1 := oWsdl:GetSoapMsg()
			
			//memoWrite( "\cMsgSoap1.txt", cMsgSoap1 )
			
			If !lContinua
				(cAliasQry)->(dbSkip())
				LOOP
			Endif
			
			//If !lSE2
			If !lAdt
				aAccountSavGL := aClone(aAccountGL)
				For nCnt:=1 To nCount
					If nCnt == 2
						aAccountGL := aClone(aAccountEstGL)
					Endif
					for nI := 1 to len( aAccountGL )
						for nJ := 1 to len( aAccountGL[ nI ] )
							If nCnt == 2
								If aAccountGL[nI][nJ][1] == "tipoDocumento"
									aAccountGL[nI][nJ][2] := "WZ"
								Endif
							Endif
							nPos := 0
							//nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroItemDocumentoContabilidade" .and. aVet[5] == "ContasAPagar"+cRequest+"#1.documentos#1.AccountGL#" + allTrim( str( nI ) ) } )	// numeroItemDocumentoContabilidade
							If nCnt == 1
								nPos := aScan( aSimple, {|aVet| aVet[2] == aAccountGL[ nI , nJ, 1 ] .and. aVet[5] == "ContasAPagar"+cRequest+"#1.documentos#1.AccountGL#" + allTrim( str( nI ) ) } )
							Else
								nPos := aScan( aSimple, {|aVet| aVet[2] == aAccountGL[ nI , nJ, 1 ] .and. aVet[5] == "ContasAPagar"+cRequest+"#1.documentos#2.AccountGL#" + allTrim( str( nI ) ) } )
							Endif
							if nPos > 0
								xRet := oWsdl:SetValue( aSimple[nPos][1], aAccountGL[ nI , nJ, 2 ] )
								
								If !xRet
									U_ZF12GENSAP(	cZ7Filial		,;	// Filial
									cZ7Tabela		,;	// Tabela
									cZ7Chave		,;	// Chave
									cZ7Sequen		,;	// Sequencia
									"E"				,;	// Status
									"Erro no campo: " + aAccountGL[ nI , nJ, 1 ] + " Conteudo: " + aAccountGL[ nI , nJ, 2 ] + " Erro: " + oWsdl:cError	,;	// Retorno
									""				)	// XML Envio
									
									lContinua := .F.
								EndIf
							EndIf
						next
					next
				Next
				aAccountGL := aClone(aAccountSavGL)
				
				If !lContinua
					(cAliasQry)->(dbSkip())
					LOOP
				Endif
				
			Endif
			
			//cMsgSoap2 := " "
			//cMsgSoap2 := oWsdl:GetSoapMsg()
			
			//memoWrite( "\cMsgSoap2.txt", cMsgSoap2 )
			
			for nI := 1 to len( aAccPayabl )
				for nJ := 1 to len( aAccPayabl[ nI ] )
					nPos := 0
					nPos := aScan( aSimple, {|aVet| aVet[2] == aAccPayabl[ nI , nJ, 1 ] .and. aVet[5] == "ContasAPagar"+cRequest+"#1.documentos#1.AccountPayable#" + allTrim( str( nI ) ) } )
					
					if nPos > 0
						// Tratamento para a tag numeroItemDocumentoContabilidade do nó AccountPayable ficar na sequencia do nó AccountGL
						//if aAccPayabl[ nI , nJ, 1 ] == "numeroItemDocumentoContabilidade"
						//	cUltimoCT2 := soma1( cUltimoCT2 )
						//	aAccPayabl[ nI , nJ, 2 ] := cUltimoCT2
						//endif
						
						xRet := oWsdl:SetValue( aSimple[nPos][1], aAccPayabl[ nI , nJ, 2 ] )
						If !xRet
							U_ZF12GENSAP(	cZ7Filial		,;	// Filial
							cZ7Tabela		,;	// Tabela
							cZ7Chave		,;	// Chave
							cZ7Sequen		,;	// Sequencia
							"E"				,;	// Status
							"Erro no campo: " + aAccPayabl[ nI , nJ, 1 ] + " Conteudo: " + aAccPayabl[ nI , nJ, 2 ] + " Erro: " + oWsdl:cError	,;	// Retorno
							""				)	// XML Envio
							
							lContinua := .F.
						EndIf
					EndIf
				next
			next
			
			If !lContinua
				(cAliasQry)->(dbSkip())
				LOOP
			Endif
			
			for nI := 1 to len( aAccountWT )
				for nJ := 1 to len( aAccountWT[ nI ] )
					nPos := 0
					nPos := aScan( aSimple, {|aVet| aVet[2] == aAccountWT[ nI , nJ, 1 ] .and. aVet[5] == "ContasAPagar"+cRequest+"#1.documentos#1.AccountWT#" + allTrim( str( nI ) ) } )
					if nPos > 0
						xRet := oWsdl:SetValue( aSimple[nPos][1], aAccountWT[ nI , nJ, 2 ] )
						
						If !xRet
							U_ZF12GENSAP(	cZ7Filial		,;	// Filial
							cZ7Tabela		,;	// Tabela
							cZ7Chave		,;	// Chave
							cZ7Sequen		,;	// Sequencia
							"E"				,;	// Status
							"Erro no campo: " + aAccountWT[ nI , nJ, 1 ] + " Conteudo: " + aAccountWT[ nI , nJ, 2 ] + " Erro: " + oWsdl:cError	,;	// Retorno
							""				)	// XML Envio
							
							lContinua := .F.
						EndIf
					EndIf
				next
			next
			
			If !lContinua
				(cAliasQry)->(dbSkip())
				LOOP
			Endif
			
			//cMsgSoap3 := " "
			//cMsgSoap3 := oWsdl:GetSoapMsg()
			
			//memoWrite( "\cMsgSoap3.txt", cMsgSoap3 )
			
			// Define o valor de cada parâmeto necessário
			nPos := 0
			nPos := aScan( aSimple, {|aVet| aVet[2] == "sistema" } )
			if nPos > 0 .and. lContinua
				xRet := oWsdl:SetValue( aSimple[nPos][1], "TOTVS" )	//sistema
				If !xRet
					U_ZF12GENSAP(	cZ7Filial										,;	// Filial
					cZ7Tabela										,;	// Tabela
					cZ7Chave										,;	// Chave
					cZ7Sequen										,;	// Sequencia
					"E"												,;	// Status
					"Erro no campo: sistema Erro: " + oWsdl:cError	,;	// Retorno
					""												)	// XML Envio
					
					lContinua := .F.
				EndIf
			EndIf
			
			nPos := 0
			nPos := aScan( aSimple, {|aVet| aVet[2] == "data" } )
			if nPos > 0 .and. lContinua
				xRet := oWsdl:SetValue( aSimple[nPos][1], left( fwTimeStamp( 5 ) , 10 ) )	//data
				If !xRet
					U_ZF12GENSAP(	cZ7Filial										,;	// Filial
					cZ7Tabela										,;	// Tabela
					cZ7Chave										,;	// Chave
					cZ7Sequen										,;	// Sequencia
					"E"												,;	// Status
					"Erro no campo: data Conteudo: " + left( fwTimeStamp( 5 ) , 10 ) + " Erro: " + oWsdl:cError	,;	// Retorno
					""												)	// XML Envio
					
					lContinua := .F.
				EndIf
			EndIf
			
			nPos := 0
			nPos := aScan( aSimple, {|aVet| aVet[2] == "hora" } )
			if nPos > 0 .and. lContinua
				xRet := oWsdl:SetValue( aSimple[nPos][1], Time() )	//hora
				If !xRet
					U_ZF12GENSAP(	cZ7Filial									,;	// Filial
					cZ7Tabela									,;	// Tabela
					cZ7Chave									,;	// Chave
					cZ7Sequen									,;	// Sequencia
					"E"											,;	// Status
					"Erro no campo: hora Erro: " + oWsdl:cError	,;	// Retorno
					""											)	// XML Envio
					
					lContinua := .F.
				EndIf
			EndIf
			
			nPos := 0
			nPos := aScan( aSimple, {|aVet| aVet[2] == "idLote" } )
			if nPos > 0 .and. lContinua
				xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(Str(Val(cIDLote))) )	//idLote
				If !xRet
					U_ZF12GENSAP(	cZ7Filial										,;	// Filial
					cZ7Tabela										,;	// Tabela
					cZ7Chave										,;	// Chave
					cZ7Sequen										,;	// Sequencia
					"E"												,;	// Status
					"Erro no campo: idLote Erro: " + oWsdl:cError	,;	// Retorno
					""												)	// XML Envio
					
					lContinua := .F.
				EndIf
			EndIf
			
			If !lContinua
				(cAliasQry)->(dbSkip())
				LOOP
			Endif
			
			oWsdl:lRemEmptyTags := .T. // remove tags vazias
			
			// Exibe a mensagem que será enviada
			cMsgSoap := ""
			cMsgSoap := oWsdl:GetSoapMsg()
			
			//memoWrite( "\cMsgSoap.txt", cMsgSoap )
			
			//conout( cMsgSoap )
			
			cMsgSoap	:= fwNoAccent( cMsgSoap )
			cMsgSoap	:= encodeUtf8( cMsgSoap )
			
		Endif
		
		memoWrite( "\cMsgSoap.txt", cMsgSoap )
		
		conout( cMsgSoap )
		
		If !Empty(cMsgSoap)
			
			// Envia a mensagem SOAP ao servidor
			xRet := oWsdl:SendSoapMsg( cMsgSoap /*cMsg*/)
			//xRet := oWsdl:SendSoapMsg( /*cMsg*/ )
			if !xRet
				conout( "Erro: " + oWsdl:cError )
				
				U_ZF12GENSAP(	cZ7Filial		,;	// Filial
				cZ7Tabela		,;	// Tabela
				cZ7Chave		,;	// Chave
				cZ7Sequen		,;	// Sequencia
				"E"				,;	// Status
				oWsdl:cError	,;	// Retorno
				cMsgSoap		)	// XML Envio
			else
				// Recupera os elementos de retorno, já parseados
				cResp := ""
				cResp := oWsdl:GetParsedResponse()
				memoWrite( "\response.txt", cResp )
				
				U_ZF12GENSAP(	cZ7Filial	,;	// Filial
				cZ7Tabela	,;	// Tabela
				cZ7Chave	,;	// Chave
				cZ7Sequen	,;	// Sequencia
				"A"			,;	// Status
				cResp		,;	// Retorno
				cMsgSoap	)	// XML Envio
				
				//Exclusão SAP
				If !(cAliasQry)->Z7_XOPESAP == 2
					// se envio foi com sucesso, verifica se jah tem registro gerado de cancelamento na sz7, e caso tenha grava o xml para envio
					U_ZF17GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,cMsgSoap)
				Endif
			endif
		Endif
	endif
	(cAliasQry)->(DBSkip())
Enddo
(cAliasQry)->(DbClosearea())

cFilAnt := cFilAntSav

IF lIsBlind
	Conout("Conexão finalizada com sucesso : CMVSAP03 " + DTOC(dDATABASE) + " - " + TIME() )
	RpcClearEnv()
Endif

return

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
Static Function xEncCGC(cxFil)

Local cRet := ""
Local cNextAlias := GetNextAlias()

If Select(cNextAlias) > 0
	(cNextAlias)->(DbClosearea())
Endif

BeginSql Alias cNextAlias
	SELECT SM0.M0_CGC
	FROM SYS_COMPANY SM0
	WHERE SM0.%NotDel%
	AND SM0.M0_CODFIL = %Exp:cxFil%
	ORDER BY M0_CGC
EndSql

While (cNextAlias)->(!EOF())
	cRet := (cNextAlias)->M0_CGC
	Exit
	(cNextAlias)->(dbSkip())
EndDo

(cNextAlias)->(DbClosearea())

return cRet


// chamada via job por arquivo .INI
user function xCMVSA03(xParam1,xParam2,xParam3)

U_CMVSAP03({{xParam1,xParam2,Val(xParam3)}})

Return()


Static Function TagAccWT(nNum,cImp,nBaseImp,nValImp,aAccountWT,cNat,lSE2)

Local aAreaSE2 := SE2->(GetArea())
Local aAreaSED := SED->(GetArea())
Local cChave := SE2->E2_PREFIXO+SE2->E2_NUM
Local cChavePai := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
Local aAux := {}
Local cParc := ""

//Só considera retenção para notas entrada com especie diferente de SPED 
if !lSE2 .and. Alltrim(SF1->F1_ESPECIE) $ "SPED/NFE"
	Return
endif

If cNat == GetMv("CAOASAP03E",,"2305") // ir
	cParc := SE2->E2_PARCIR
Elseif cNat == GetMv("CAOASAP03F",,"2304") // iss
	cParc := SE2->E2_PARCISS
Elseif cNat == GetMv("CAOASAP03G",,"2306") // inss
	cParc := SE2->E2_PARCINS
Elseif cNat == GetMv("CAOASAP03H",,"2301") // pis
	cParc := SE2->E2_PARCPIS
Elseif cNat == GetMv("CAOASAP03I",,"2302") // cofins
	cParc := SE2->E2_PARCCOF
Elseif cNat == GetMv("CAOASAP03J",,"2303") // csll
	cParc := SE2->E2_PARCSLL
Endif

SED->(dbSetOrder(1))
SE2->(dbSetOrder(1))
If SE2->(dbSeek(xFilial("SE2")+cChave+cParc))
	While SE2->(!Eof()) .and. xFilial("SE2")+cChave+cParc == SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA
		If SE2->E2_TIPO == cImp .and. Alltrim(SE2->E2_NATUREZ) == Alltrim(cNat) .and. Subs(SE2->E2_TITPAI,1,Len(cChavePai)) == cChavePai
			If SED->(dbSeek(xFilial("SED")+SE2->E2_NATUREZ))
				aadd(aAux,{"numeroItemDocumentoContabilidade"		, ALLTRIM(STR(nNum))})
				aadd(aAux,{"CodCategoriaImpostoRF"					, SED->ED_XCATIM})
				aadd(aAux,{"CodImpostoRF"							, SED->ED_XCODIM})
				aadd(aAux,{"MontanteBaseIRF"						, alltrim(str(nBaseImp))})
				aadd(aAux,{"MontanteIRFManualmente"					, Alltrim(Str(nValImp))})
				aadd(aAccountWT,aAux )
				Exit
			Endif
		Endif
		SE2->(dbSkip())
	Enddo
Endif

SED->(RestArea(aAreaSED))
SE2->(RestArea(aAreaSE2))

Return()

