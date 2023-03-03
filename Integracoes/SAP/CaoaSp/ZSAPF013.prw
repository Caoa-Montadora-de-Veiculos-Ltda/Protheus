#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "xmlxfun.ch"

/*
Integracao de Contas a Pagar com SAP ( GNRE sobre faturamento )
*/
user function ZSAPF013( aParam )
local oWsdl
local aOps			:= {}
local cUser			:= ""//allTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
local cPass			:= ""//allTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP
local cURLProxy		:= ""//allTrim( superGetMv( "CAOAPROXY"	, , "proxy.caoa.local"		) )	// Usuario Proxy da Rede Caoa
local nPortProxy	:= ""//superGetMv( "CAOAPORT"	, , 8080 )								// Porta Proxy da Rede Caoa
local cUserProxy	:= ""//allTrim( superGetMv( "CAOAPROUSE"	, , "T-RODRIGO.SALOMAO"	) )	// Usuario do Proxy
local cPassProxy	:= ""//allTrim( superGetMv( "CAOAPROPAS"	, , "caoa2019**"		) )	// Senha do Proxy
local cUrl			:= ""//allTrim( superGetMv( "CAOASAP03D")) //allTrim( superGetMv( "CAOASAP03A"	, , "http://10.120.40.140:51400/dir/wsdl?p=ic/7e57f79630be3849a4ebcfa108259ed4") )
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
local cIDLote		:= ""
local cFilAtu		:= ""
local cCT2Atu		:= ""
local cUltimoCT2	:= ""
local cGeraPorNF	:= ""//allTrim( superGetMv( "CAOASAP03B"	, , "SPED|RPS") )
local cFrete		:= ""//allTrim( superGetMv( "CAOASAP03C"	, , "CTE") )

local _cEmpresa		:= ""  
local _cFilial		:= ""
local _cDivisao		:= ""

local cZ7Filial		:= ""
local cZ7Tabela		:= ""
local cZ7Chave		:= ""
local cZ7Sequen		:= ""
Local nNum := 0
Local nNumEst := 0
Local cOrigEst := "" //GetMv("CAOAORESTR",,"610-019/610-020/610-046/610-047")
Local aAccountEstGL := {}
Local nAtiv := 0
Local cRequest := ""
//Local lGNRE := .F.
Local lContinua := .F.
Local cQ := ""
Local cAliasTrb := ""//GetNextAlias()
Local cSeq := ""
Local cFilAntSav := ""
Local lInvSinal := .F.
Local nDiasErro := 0
Local nDiasAguar := 0

Local nRecRep := 0
Local cEmpJob := ""
Local cFilJob := ""
Local cDocSAP := ""
Local nPos := 0
Local xRet := Nil
Local nCnt	:=1
private cAliasQry	:= ""//GetNextAlias()
private cAliasQry1	:= ""//GetNextAlias()
private lIsBlind	:= IsBlind() .OR. Type("__LocalDriver") == "U"

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
	
	If !LockByName("ZSAPF013")
		Conout("JOB já em Execução : ZSAPF013 " + DTOC(dDATABASE) + " - " + TIME() )
		RpcClearEnv()
		Return
	EndIf
EndIF

_cEmpresa	:= GetMv("CMV_SAP001")   
_cFilial	:= GetMv("CMV_SAP002")
_cDivisao	:= GetMv("CMV_SAP003")

cUser		:= allTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
cPass		:= allTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP
cURLProxy	:= allTrim( superGetMv( "CAOAPROXY"	, , "proxy.caoa.local"		) )	// Usuario Proxy da Rede Caoa
nPortProxy	:= superGetMv( "CAOAPORT"	, , 8080 )								// Porta Proxy da Rede Caoa
cUserProxy	:= allTrim( superGetMv( "CAOAPROUSE"	, , "T-RODRIGO.SALOMAO"	) )	// Usuario do Proxy
cPassProxy	:= allTrim( superGetMv( "CAOAPROPAS"	, , "caoa2019**"		) )	// Senha do Proxy
cUrl		:= allTrim( superGetMv( "CAOASAP03D")) //allTrim( superGetMv( "CAOASAP03A"	, , "http://10.120.40.140:51400/dir/wsdl?p=ic/7e57f79630be3849a4ebcfa108259ed4") )
cDivisao	:= _cDivisao  //right( allTrim( xEncCGC( xFilial("SZ7") ) ) , 4 )
cGeraPorNF	:= allTrim( superGetMv( "CAOASAP03B"	, , "SPED|RPS") )
cFrete		:= allTrim( superGetMv( "CAOASAP03C"	, , "CTE") )
cAliasTrb 	:= GetNextAlias()
cAliasQry	:= GetNextAlias()
cAliasQry1	:= GetNextAlias()
nDiasErro	:= superGetMv( "CAOASAP01C"	, , 3 )  // qtde de dias para reprocessar registros com status de erro
nDiasAguar	:= superGetMv( "CAOASAP01D"	, , 3 )  // qtde de dias para reprocessar registros com status de aguardando

cQ := "SELECT SZ7.*,SZ7.R_E_C_N_O_ SZ7_RECNO "
cQ += "FROM "+RetSqlName("SZ7")+" SZ7 "
//cQ += "WHERE (Z7_XSTATUS = 'P' OR (Z7_XSTATUS = 'E' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasErro)+"') OR (Z7_XSTATUS = 'A' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasAguar)+"' AND Z7_XDTINC < '"+dTos(dDataBase-1)+"')) "
cQ += "WHERE (Z7_XSTATUS = 'P' OR (Z7_XSTATUS = 'E' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasErro)+"')) "
//cQ += "WHERE Z7_XSTATUS = 'P' "
cQ += "AND Z7_XTABELA = 'SE2' "
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
	cSeq := ""
	nAtiv := 0
	lInvSinal := .F.
	
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
	
	// posiciona SE2, usar goto pois registro pode estar deletado
	SE2->(dbGoto((cAliasQry)->Z7_RECORI))

	// se for exclusao e titulo for do EEC, nao prossegue, pois serah enviado pelo ZSAPF003
	If (cAliasQry)->Z7_XOPESAP == 2
		If U_ZF01GENSAP()
			(cAliasQry)->(dbSkip())
			LOOP
		Endif
	Endif		
	
	// para inclusao no sap, posiciona tabelas
	If (cAliasQry)->Z7_XOPESAP == 1
		// titulos de gnre
		If SE2->E2_PREFIXO == "ICM" .and. SE2->E2_TIPO == "TX " .and. Alltrim(SE2->E2_ORIGEM) == "MATA460A"
			cQ := "SELECT SF2.R_E_C_N_O_ SF2_RECNO "
			cQ += "FROM "+retSQLName("SF2")+" SF2 "
			cQ += "WHERE "
			cQ += "F2_FILIAL = '"+xFilial("SF2")+"' "
			cQ += "AND (F2_NFICMST = '"+SE2->E2_PREFIXO+SE2->E2_NUM+"' "
			cQ += "OR F2_GNRDIF = '"+SE2->E2_PREFIXO+SE2->E2_NUM+"') "
			cQ += "AND SF2.D_E_L_E_T_ = ' ' "
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
			
			If (cAliasTrb)->(!Eof())
				SF2->(dbGoto((cAliasTrb)->SF2_RECNO))
				If !U_ZF08GENSAP(SF2->F2_ESPECIE,SF2->F2_CHVNFE,SF2->F2_FIMP,SF2->F2_DOC,SF2->F2_SERIE)
					(cAliasTrb)->(dbCloseArea())
					(cAliasQry)->(dbSkip())
					LOOP
				Endif	
						
				lContinua := .T.
			Endif
			(cAliasTrb)->(dbCloseArea())
			
			If lContinua
				lContinua := .F.
				SF6->(dbSetOrder(3))
				If SF6->(dbSeek(xFilial("SF6")+"2"+Padr(SF2->F2_TIPO,TamSX3("F6_TIPODOC")[1])+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					While SF6->(!Eof()) .and. xFilial("SF6")+"2"+Padr(SF2->F2_TIPO,TamSX3("F6_TIPODOC")[1])+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == ;
						SF6->F6_FILIAL+SF6->F6_OPERNF+SF6->F6_TIPODOC+SF6->F6_DOC+SF6->F6_SERIE+SF6->F6_CLIFOR+SF6->F6_LOJA
						If SF6->F6_NUMERO == SE2->E2_PREFIXO+SE2->E2_NUM
							lContinua := .T.
							Exit
						Endif
						SF6->(dbSkip())
					Enddo
				Endif
			Endif
		Endif
		
		If lContinua
			// posiciona cliente
			//SA1->(dbSetOrder(1))
			//SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))

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
			
			// posiciona natureza
			SED->(dbSetOrder(1))
			SED->(dbSeek(xFilial("SED")+SE2->E2_NATUREZ))
		
			// para inclusao no sap eh obrigatorio que esteja contabilizado, para exclusao nao precisa desta verificacao, pois se presume que a contabilizacao jah tenha sido excluida
			If (cAliasQry)->Z7_XOPESAP == 1 .and. !SE2->E2_LA == "S"
				(cAliasQry)->(dbSkip())
				Help("",1,"Envio movimento SAP",,"Título não contabilizado.",1,0)
				LOOP
			EndIf
		Else
			(cAliasQry)->(dbSkip())
			LOOP
		Endif	
	Endif
	
	cTimeIni 	:= time()
	xPostRet	:= httpQuote( cUrl /*<cUrl>*/, "GET" /*<cMethod>*/, /*[cGETParms]*/, /*[cPOSTParms]*/, nTimeOut /*[nTimeOut]*/, aHeadOut /*[aHeadStr]*/, @cHeadRet /*[@cHeaderRet]*/ )
	
	nStatuHttp	:= 0
	nStatuHttp	:= httpGetStatus()
	
	cTimeFin	:= time()
	cTimeProc	:= elapTime( cTimeIni, cTimeFin )
	
	conout(" [SAP] [ZSAPF013] * * * * * Status da integracao * * * * *"									)
	conout(" [SAP] [ZSAPF013] Inicio.......................: " + cTimeIni + " - " + dToC( dDataBase ) 	)
	conout(" [SAP] [ZSAPF013] Fim..........................: " + cTimeFin + " - " + dToC( dDataBase ) 	)
	conout(" [SAP] [ZSAPF013] Tempo de Processamento.......: " + cTimeProc 								)
	conout(" [SAP] [ZSAPF013] URL..........................: " + cUrl									)
	conout(" [SAP] [ZSAPF013] HTTP Method..................: " + "GET" 									)
	conout(" [SAP] [ZSAPF013] Status Http (200 a 299 ok)...: " + allTrim( str( nStatuHttp ) ) 			)
	conout(" [SAP] [ZSAPF013] Retorno......................: " + allTrim( xPostRet ) 					)
	conout(" [SAP] [ZSAPF013] * * * * * * * * * * * * * * * * * * * * "									)
	
	if nStatuHttp >= 200 .and. nStatuHttp <= 299
		memoWrite( "\" + funName() + ".wsdl", xPostRet )
		
		// Cria o objeto da classe TWsdlManager
		oWsdl := TWsdlManager():New()
		oWsdl:bNoCheckPeerCert  := .T.
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
		
		aOps := oWsdl:ListOperations()
		If Len( aOps ) == 0
			conout( "Erro: " + oWsdl:cError )
			Return
		EndIf
		//varinfo( "", aOps )
		
		// Define a operação
		xRet := oWsdl:SetOperation( aOps[1][1]) // "CriaDocumento"
		If !xRet
			conout( "Erro: " + oWsdl:cError )
			Return
		EndIf

		cUltimoCT2	:= ""
		cZ7Filial	:= (cAliasQry)->Z7_FILIAL
		cZ7Tabela	:= (cAliasQry)->Z7_XTABELA
		cZ7Chave	:= (cAliasQry)->Z7_XCHAVE
		cZ7Sequen	:= (cAliasQry)->Z7_XSEQUEN
		
		If (cAliasQry)->Z7_XOPESAP <> 2
			
			cIDLote		:= (cAliasQry)->Z7_XLOTE
			cFilAtu		:= SE2->E2_FILIAL
			cCT2Atu		:= SE2->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA+E2_TIPO)
			
			aAux		:= {}
			aDocHeader	:= {} // tag DocumentHeader
			aAccountGL	:= {} // tag AccountGL
			aAccPayabl	:= {} // tag AccountPayable
			aAccountWT	:= {} // tag AccountWT -> Sera preenchido apenas em casos de retencao
			aAccountEstGL := {}
			
			cDocSAP := U_ZF07GENSAP(SE2->E2_NUM)

			aadd( aAux , { "empresa"					, _cEmpresa/*left( allTrim( SE2->E2_FILIAL ) , 4 )*/ }  )	// tag empresa
			aadd( aAux , { "divisao"					, _cDivisao } )											// tag divisao
			aadd( aAux , { "filial"						, _cFilial /*right( allTrim( SE2->E2_FILIAL ) , 4 )*/ } )				// tag filial
			aadd( aAux , { "dataDocumento"				, left( fwTimeStamp( 5 , SE2->E2_EMISSAO ) , 10 ) } )	// tag dataDocumento
			aadd( aAux , { "tipoDocumento"				, SED->ED_XTIPO } )														// tag TipoDocumento
			aadd( aAux , { "dataLancamentoDocumento"	, left( fwTimeStamp( 5 , SE2->E2_EMIS1 ) , 10 ) } )		// tag dataLancamentoDocumento
			//aadd( aAux , { "numeroDocumentoReferencia"	, Alltrim(SE2->E2_NUM)+IIf(!Empty(SE2->E2_PREFIXO),"/"+Alltrim(SE2->E2_PREFIXO),"") } )							// tag numeroDocumentoReferencia
			aadd( aAux , { "numeroDocumentoReferencia"	, Alltrim(cDocSAP)+IIf(!Empty(SE2->E2_PREFIXO),"/"+Alltrim(SE2->E2_PREFIXO),"") } )							// tag numeroDocumentoReferencia
			aadd( aAux , { "chaveCabecalho1"			, " "/*(cAliasQry)->D1_CHASSI*/ } )											// tag chaveCabecalho1
			aadd( aAux , { "chaveCabecalho2"			, " " } )																// tag chaveCabecalho2
			aadd( aAux , { "textoCabecalhoDocumento"	, " " } )																// tag textoCabecalhoDocumento
			aadd( aAux , { "motivoOperacao"				, "1" } )																// tag motivoOperacao
			
			if SE2->E2_MOEDA <> 1
				aadd( aAux , { "dataconversao" , left( fwTimeStamp( 5 , SE2->E2_EMIS1 ) , 10 ) } )				// tag dataconversao
			endif
			
			aadd( aDocHeader , aAux )
			
			nNum := 0
			nNumEst := 0

			cQ := " SELECT MAX(CT2_SEQUEN) CT2_SEQUEN "
			cQ += " FROM " + RetSqlName("CT2") + " CT2 " + CRLF
			cQ += " INNER JOIN " + RetSqlName("CV3") + " CV3 " + CRLF
			cQ += " ON TRIM(CV3.CV3_RECDES) = TRIM(CT2.R_E_C_N_O_) "
			cQ += " AND CV3.D_E_L_E_T_ <> '*' "
			cQ += " AND CT2.D_E_L_E_T_ <> '*' " + CRLF
			cQ += " WHERE " + CRLF
			cQ += " CV3.CV3_RECORI = '"+ALLTRIM(STR(SE2->(Recno())))+"' "
			cQ += " AND CV3.CV3_TABORI = 'SE2' "
			cQ += " AND CT2.CT2_TPSALD = '1' "
			//cQ += " AND CT2_LP IN ('510','513') " 
			cQ += " AND CT2_LP IN ('510','511') "
			
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
			cQ += " CT2.CT2_AT01DB				, " + CRLF
			cQ += " CT2.CT2_AT01CR				  " + CRLF
			cQ += " FROM " + RetSqlName("CT2") + " CT2 " + CRLF
			cQ += " INNER JOIN " + RetSqlName("CV3") + " CV3 " + CRLF
			cQ += " ON TRIM(CV3.CV3_RECDES) = TRIM(CT2.R_E_C_N_O_) "
			cQ += " AND CV3.D_E_L_E_T_ <> '*' "
			cQ += " AND CT2.D_E_L_E_T_ <> '*' " + CRLF
			cQ += " WHERE " + CRLF
			cQ += " CV3.CV3_RECORI = '"+ALLTRIM(STR(SE2->(Recno())))+"' "
			cQ += " AND CV3.CV3_TABORI = 'SE2' "
			cQ += " AND CT2.CT2_TPSALD = '1' "
			//cQ += " AND CT2_LP IN ('510','513') "
			cQ += " AND CT2_LP IN ('510','511') "
			cQ += " AND CT2_SEQUEN = '"+cSeq+"' "
			cQ += " ORDER BY CT2_LINHA " 
			
			memoWrite( "C:\TEMP\ZSAPF013.TXT",cQ )
			
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
				If !Empty((cAliasQry1)->CT2_AT01CR) .or. !Empty((cAliasQry1)->CT2_AT01DB)
					// titulo tipo PA, contabilizado pelo LP 513, se for a debito, mantem o lancamento no accountgl
					//If !(SE2->E2_TIPO == MVPAGANT .and. CT2->CT2_LP == "513" .and. !Empty((cAliasQry1)->CT2_AT01DB))
						nAtiv := (cAliasQry1)->CT2_VALOR
						If !Empty((cAliasQry1)->CT2_AT01CR)
							lInvSinal := .T.
						//	nAtiv := (cAliasQry1)->CT2_VALOR * -1
						//ElseIf !Empty((cAliasQry1)->CT2_AT01DB)
						//	nAtiv := (cAliasQry1)->CT2_VALOR
						Endif	
						(cAliasQry1)->(DBSkip())
						Loop
					//Endif	
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
				
				aadd( aAux , { "divisao"		, _cDivisao } )										// divisao
				aadd( aAux , { "textoItem"	, (cAliasQry1)->CT2_HIST } )											// textoItem
				
				//if allTrim( (cAliasQry1)->F1_ESPECIE ) $ cGeraPorNF
				//	aadd( aAux , { "numeroAtribuicao"						, (cAliasQry1)->F1_DOC } )											//	numeroAtribuicao
				//else
				//aadd( aAux , { "numeroAtribuicao"		, Alltrim(SE2->E2_NUM) } )
				aadd( aAux , { "numeroAtribuicao"		, Alltrim(cDocSAP) } )
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
			
			nNum++
			
			//****************************************
			// Inicio aAccPayabl
			//****************************************
			aAux := {}
			//aadd( aAux , { "idExterno"								, "T"+(cAliasQry)->Z7_XTABELA+(cAliasQry)->Z7_TIPONF+SE2->E2_PARCELA+allTrim( str( SE2->(Recno()) ) ) } )
			aadd( aAux , { "idExterno"								, "T"+allTrim(str((cAliasQry)->SZ7_RECNO))})
			//aadd( aAux , { "numeroItemDocumentoContabilidade"		, allTrim( str( (cAliasQry)->CT2RECNO ) ) } )
			aadd( aAux , { "numeroItemDocumentoContabilidade"		, ALLTRIM(STR(nNum)) } )
			aadd( aAux , { "numeroContaFornecedor"					, allTrim( SA2->A2_CGC ) } )
			aadd( aAux , { "chaveReferenciaParceiroNegocios1"		, " "/*(cAliasQry)->D1_PLACA*/ } )
			aadd( aAux , { "chaveReferenciaParceiroNegocios2"		, " " } )
			aadd( aAux , { "chaveReferenciaParceiroNegocios3"		, left( " " , 20 ) } )
			aadd( aAux , { "empresa"								, _cEmpresa /*left( allTrim( SE2->E2_FILIAL ) , 4 )*/ } )
			aadd( aAux , { "divisao"								, _cDivisao } )											//	divisao
			aadd( aAux , { "dataBaseCalculoVencimento"				, left( fwTimeStamp( 5 , SE2->E2_EMISSAO ) , 10 ) } )	//	dataBaseCalculoVencimento
			aadd( aAux , { "diasDesconto1"							, allTrim( str( SE2->E2_VENCTO - SE2->E2_EMISSAO ) ) } )	//	diasDesconto1
			aadd( aAux , { "formaPagamento"							, " " } )																//	formaPagamento
			aadd( aAux , { "chaveBloqueioPagamento"					, "A" } )																//	chaveBloqueioPagamento
			
			//if allTrim( (cAliasQry)->F1_ESPECIE ) $ cFrete .or. lGNRE
			//	aadd( aAux , { "numeroAtribuicao"		, (cAliasQry)->D1_PEDIDO } )
			//else
			//aadd( aAux , { "numeroAtribuicao"		, Alltrim(SE2->E2_NUM) } )
			aadd( aAux , { "numeroAtribuicao"		, Alltrim(cDocSAP) } )
			//endif
			
			aadd( aAux , { "textoITem"								, " " } )																//	textoITem
			aadd( aAux , { "filial"									, _cFilial/*right( allTrim( SE2->E2_FILIAL ) , 4 )*/ } )				//	filial
			
			//if SE2->E2_TIPO == "NDF"
			//	//aadd( aAux , { "montanteMoedaPagamento"	, allTrim( str( ( SE2->E2_VALOR * -1 ) ) ) } )											//	montanteMoedaPagamento
			//	aadd( aAux , { "montanteMoedaPagamento"	, allTrim( str( ( nAtiv * -1 ) ) ) } )											//	montanteMoedaPagamento
			//else
			//aadd( aAux , { "montanteMoedaPagamento"	, allTrim( str( SE2->E2_VALOR ) ) } )														//	montanteMoedaPagamento
			aadd( aAux , { "montanteMoedaPagamento"	, allTrim( str(IIf(lInvSinal,nAtiv * -1,nAtiv) ) ) } )														//	montanteMoedaPagamento
			//endif
			
			//if SE2->E2_TIPO == MVPAGANT
			//	aadd( aAux , { "codigoRazaoEspecial"	, "F" } )																			//	codigoRazaoEspecial
			//else
			aadd( aAux , { "codigoRazaoEspecial"	, " " } )																			//	codigoRazaoEspecial
			//endif
			
			if SE2->E2_MOEDA <> 1
				aadd( aAux , { "moeda"	, " " } )																						//	moeda
			endif
			
			if SE2->E2_MOEDA <> 1
				aadd( aAux , { "taxacambio"	, Alltrim(Str(SE2->E2_TXMOEDA)) } )																// taxacambio
			endif
			
			aadd( aAccPayabl , aAux )
			//****************************************
			// Fim aAccPayabl
			//****************************************
			
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
					Endif
				ElseIf aComplex[2] == "AccountPayable"
					//nOccurs := len( aAccPayabl )
					If aComplex[5] == "ContasAPagar"+cRequest+"#1.documentos#1"
						nOccurs := len( aAccPayabl )
					Else
						nOccurs := 0
					Endif
				ElseIf aComplex[2] == "AccountWT"
					nOccurs := 0 //len( aAccountWT )
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
			
			If !lContinua
				(cAliasQry)->(dbSkip())
				LOOP
			Endif
				
			//cMsgSoap1 := " "
			//cMsgSoap1 := oWsdl:GetSoapMsg()
			
			//memoWrite( "\cMsgSoap1.txt", cMsgSoap1 )
			
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
			
			//cMsgSoap3 := " "
			//cMsgSoap3 := oWsdl:GetSoapMsg()
			
			//memoWrite( "\cMsgSoap3.txt", cMsgSoap3 )
			/*
			lContCT2 := .T.
			nz		 := 1
			While (cAliasCT2)->(!Eof()) .and. lContCT2
			
			nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroItemDocumentoContabilidade" .and. aVet[5] == "Contabil"+cRequest+"#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } )//numeroItemDocumentoContabilidade
			xRet := oWsdl:SetValue( aSimple[nPos][1], (cAliasCT2)->CT2_LINHA )
			If !xRet
			U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","numeroItemDocumentoContabilidade Erro: " + oWsdl:cError)
			lContCT2 := .F.
			Exit
			EndIf
			*/
			
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
			
			memoWrite( "\cMsgSoap.txt", cMsgSoap )
			
			conout( cMsgSoap )
			
			cMsgSoap	:= fwNoAccent( cMsgSoap )
			cMsgSoap	:= encodeUtf8( cMsgSoap )
			
		Endif
		
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
	endif
	(cAliasQry)->(DBSkip())
Enddo
(cAliasQry)->(DbClosearea())

cFilAnt := cFilAntSav

IF lIsBlind
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
user function xZSAPF13(xParam1,xParam2,xParam3)

U_ZSAPF013({{xParam1,xParam2,Val(xParam3)}})

Return()


