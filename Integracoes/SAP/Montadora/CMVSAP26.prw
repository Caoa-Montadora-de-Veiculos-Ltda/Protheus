#include "topconn.ch"
#include "tbiconn.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#include "protheus.ch"

/*
Integracao de Contas a Receber RA com SAP
*/

/*-------------------------------------------------------------------------------------
{Protheus.doc} CMVSAP26 
Rdmake 	responsavel Integração SAP Contas a Receber RA 
@class    	Nao Informado
@from       Nao Informado
@param      Nao Informado
@attrib    	Nao Informado
@protected  Nao Informado
@author     Glesele 
@single		Nao Informado
@version    Nao Informado
@since      Nao Informado  
@return    	Nao Informado
@sample     Nao Informado
@obs        Nao Informado
@project    CAOA
@menu       Nao Informado
@table 		SE1 - Contas a Receber           
@history  	
--------------------------------------------------------------------------------------*/

User Function CMVSAP12( aParam )

local oWsdl
local cAliasCtb		:= ""
local cAliasNF		:= ""
local aOps			:= {}
local cUser			:= ""//allTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
local cPass			:= ""//allTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP
local cURLProxy		:= ""//allTrim( superGetMv( "CAOAPROXY"	, , "proxy.caoa.local"		) )	// Usuario Proxy da Rede Caoa
local nPortProxy	:= ""//superGetMv( "CAOAPORT"	, , 8080 )								// Porta Proxy da Rede Caoa
local cUserProxy	:= ""//allTrim( superGetMv( "CAOAPROUSE"	, , "T-RODRIGO.SALOMAO"	) )	// Usuario do Proxy
local cPassProxy	:= ""//allTrim( superGetMv( "CAOAPROPAS"	, , "caoa2019**"		) )	// Senha do Proxy
local cUrl			:= ""//allTrim( superGetMv( "CAOASAP12A"	, , "http://10.120.40.140:51400/dir/wsdl?p=ic/67105a33fc843b8b843c892dae69f375") )
local aHeadOut		:= {}
local cHeadRet		:= ""
local cAutorizat	:= ""
local cTimeIni		:= ""
local cTimeFin		:= ""
local cTimeProc		:= ""
local xPostRet		:= nil
local nStatuHttp	:= 0
local nTimeOut		:= 120
LOCAL nz			:= 0
local nNum			:= 0
local nTit			:= 0
local cLucro		:=""
Local cOrigEst      := ""//GetMv("CAOAORESTR",,"610-019/610-020/610-046/610-047")
Local nOcorGL       := 0
Local nOcorEstGL    := 0
Local nNumEst       := 0
Local nNumAux       := 0
Local lContinua     := .T.
Local cQ            := ""
Local cSD2          := ""
Local nRegSE1       := 0
Local cSeq          := ""
Local lDev          := .F.
Local cSD1          := ""
Local cFilAntSav    := ""
Local cChaveTit     := ""
Local nAtiv         := 0
//Local nVlrTit := 0
//Local nVlrTitTot := 0
local nTitWT        := 0
Local nCountWT      := 0
Local lInvSinal     := .F.
Local nDiasErro     := 0
Local nValRet       := 0
Local cOrigRet      := ""
Local cDoc          := ""
Local nDiasAguar    := 0
Local cForma        := "" 

Local nRecRep       := 0
Local cEmpJob       := ""
Local cFilJob       := ""
Local cTiposFin     := ""
Local cNumAtrib     := ""
Local cPrefVei      := ""
Local nPos          := 0
Local xRet          := Nil
Local cCondPag      := ""
Local nCnt	        := 0
Local nCount	    := 0
//Local cDescErro	:= ""

private lIsBlind := IsBlind() .OR. Type("__LocalDriver") == "U"

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
	
	If !LockByName("CMVSAP26")
		Alert("JOB já em Execução : CMVSAP26 " + DTOC(dDATABASE) + " - " + TIME() )
		RpcClearEnv()
		Return
	Else
		Conout("Conexão realizada com sucesso : CMVSAP26 " + DTOC(dDATABASE) + " - " + TIME() )
	EndIf
EndIF

cUser		:= allTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
cPass		:= allTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP
cURLProxy	:= allTrim( superGetMv( "CAOAPROXY"	, , "proxy.caoa.local"		) )	// Usuario Proxy da Rede Caoa
nPortProxy	:= superGetMv( "CAOAPORT"	, , 8080 )								// Porta Proxy da Rede Caoa
cUserProxy	:= allTrim( superGetMv( "CAOAPROUSE"	, , "T-RODRIGO.SALOMAO"	) )	// Usuario do Proxy
cPassProxy	:= allTrim( superGetMv( "CAOAPROPAS"	, , "caoa2019**"		) )	// Senha do Proxy
cUrl		:= allTrim( superGetMv( "CAOASAP12A"	, , "http://10.120.40.141:53400/dir/wsdl?p=ic/67105a33fc843b8b843c892dae69f375") )
nDiasErro	:= superGetMv( "CAOASAP01C"	, , 3 )  // qtde de dias para reprocessar registros com status de erro
nDiasAguar	:= superGetMv( "CAOASAP01D"	, , 3 )  // qtde de dias para reprocessar registros com status de aguardando
cTiposFin 	:= GetMv("CAOASAP26",,"RA")
cPrefVei 	:= superGetMv( "CAOASAP17A"	, , "OFI/VEI" )  // prefixos de titulos originados no sigavei

If Select("cAliasNF")   > 0
	(cAliasNF)->(DBCLOSEAREA())
endif

VRJ->(dbSetOrder(1))
cQ := "SELECT SZ7.*,SZ7.R_E_C_N_O_ SZ7_RECNO "
cQ += "FROM "+RetSqlName("SZ7")+" SZ7 "
//cQ += "WHERE (Z7_XSTATUS = 'P' OR (Z7_XSTATUS = 'E' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasErro)+"') OR (Z7_XSTATUS = 'A' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasAguar)+"' AND Z7_XDTINC < '"+dTos(dDataBase-1)+"')) "
cQ += "WHERE ((Z7_XTABELA = 'SE1' AND Z7_TIPONF NOT IN ('B','D')) "
cQ += "   AND Z7_SERORI = 'PVF' "
cQ += "   AND (Z7_XSTATUS = 'P' OR (Z7_XSTATUS = 'E' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasErro)+"')) "
//cQ += "WHERE Z7_XSTATUS = 'P' "
cQ += "   AND D_E_L_E_T_ = ' ' "

If nRecRep > 0
	cQ += " AND SZ7.R_E_C_N_O_ = " + AllTrim(Str(nRecRep))
EndIf

cQ += " ORDER BY SZ7.R_E_C_N_O_ "

cAliasNF := GetNextAlias()
cQ := ChangeQuery(cQ)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQ), cAliasNF, .F., .T.)

cFilAntSav := cFilAnt

while !(cAliasNF)->(Eof())
	cFilAnt   := (cAliasNF)->Z7_FILIAL
	nNum      := 0
	nNumEst   := 0
	nNumAux   := 0
	lContinua := .T.
	lDev      := .F.
	nRegSE1   := 0
	nAtiv     := 0
	//nVlrTit := 0
	//nVlrTitTot := 0
	oWsdl     := Nil
	cSeq      := ""
	cSD1      := ""
	cSD2      := ""
	nTit      := 0
	nTitWT    := 0
	nCountWT  := 0
	lInvSinal := .F.
	nValRet   := 0
	cDoc      := ""
	cNumAtrib := ""
	cCondPag  := ""

	//Fontes 13 e 18 não chamam outros
	
	// verifica se trata-se de nota de devolucao de vendas por LP
	If (cAliasNF)->Z7_XTABELA == "SE1" .and. (cAliasNF)->Z7_TIPONF == "N"
		cOrigRet := GetMv("CAOAORESTR",,"510-001/510-002")
	Endif	

	//Exclusão SAP
	/*  // Tratar
	If (cAliasNF)->Z7_XOPESAP == 2 // 05/09/19
		If (cAliasNF)->Z7_XSEQUEN <> '001' .and. !U_ZF13GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,(cAliasNF)->Z7_LOTEINC,.T.,,,,,,(cAliasNF)->SZ7_RECNO)
			(cAliasNF)->(dbSkip())
			LOOP
		EndIf
	Else	
		If (cAliasNF)->Z7_XSEQUEN <> '001' .and. !U_ZF13GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,,.F.,(cAliasNF)->Z7_DOCORI,(cAliasNF)->Z7_SERORI,(cAliasNF)->Z7_TIPONF,(cAliasNF)->Z7_CLIFOR,(cAliasNF)->Z7_LOJA,(cAliasNF)->SZ7_RECNO)
			(cAliasNF)->(dbSkip())
			LOOP
		EndIf

		If U_ZF18GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XLOTE,(cAliasNF)->SZ7_RECNO)
			(cAliasNF)->(dbSkip())
			LOOP
		EndIf
	Endif	
	*/

	//Exclusão SAP
	/*Tratar
	If (cAliasNF)->Z7_XOPESAP == 2
		//cMsgSoap := U_ZF14GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,{{"motivoOperacao","2"}})
		cMsgSoap := U_ZF15GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,{{"motivoOperacao","2"}})
	ENDIF
	*/

	// para inclusao no sap eh obrigatorio que esteja contabilizado, 
	//para exclusao nao precisa desta verificacao, pois se presume que a contabilizacao jah tenha sido excluida
	If (cAliasNF)->Z7_XOPESAP == 1 .AND. SE1->E1_LA <> 'S'  //Verificar se o título está contabilizado
		(cAliasNF)->(dbSkip())
		Help("",1,"Envio movimento SAP",,"RA não contabilizado.",1,0)
		LOOP
	EndIf
	
	cAutorizat := encode64( allTrim( cUser ) + ":" + allTrim( cPass ) )
	
	aadd( aHeadOut	, 'Content-Type: text/xml; charset=UTF-8'								)
	aadd( aHeadOut	, 'SOAPAction: http://sap.com/xi/WebService/soap1.1'					)
	aadd( aHeadOut	, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')'	)
	aadd( aHeadOut	, 'Authorization: Basic ' + cAutorizat									)
	
	cTimeIni 	:= time()
	xPostRet	:= httpQuote( cUrl /*<cUrl>*/, "GET" /*<cMethod>*/, /*[cGETParms]*/, /*[cPOSTParms]*/, nTimeOut /*[nTimeOut]*/, aHeadOut /*[aHeadStr]*/, @cHeadRet /*[@cHeaderRet]*/ )
	
	nStatuHttp	:= 0
	nStatuHttp	:= httpGetStatus()

	cTimeFin	:= time()
	cTimeProc	:= elapTime( cTimeIni, cTimeFin )
	
	Conout(" [SAP] [CMVSAP12] * * * * * Status da integracao * * * * *"									)
	Conout(" [SAP] [CMVSAP12] Inicio.......................: " + cTimeIni + " - " + dToC( dDataBase ) 	)
	Conout(" [SAP] [CMVSAP12] Fim..........................: " + cTimeFin + " - " + dToC( dDataBase ) 	)
	Conout(" [SAP] [CMVSAP12] Tempo de Processamento.......: " + cTimeProc 								)
	Conout(" [SAP] [CMVSAP12] URL..........................: " + cUrl									)
	Conout(" [SAP] [CMVSAP12] HTTP Method..................: " + "GET" 									)
	Conout(" [SAP] [CMVSAP12] Status Http (200 a 299 ok)...: " + allTrim( str( nStatuHttp ) ) 			)
	Conout(" [SAP] [CMVSAP12] Retorno......................: " + allTrim( xPostRet ) 					)
	Conout(" [SAP] [CMVSAP12] * * * * * * * * * * * * * * * * * * * * "									)
	
	if nStatuHttp >= 200 .and. nStatuHttp <= 299
		memoWrite( "\" + funName() + ".wsdl", xPostRet )
		
		// Cria o objeto da classe TWsdlManager
		oWsdl := TWsdlManager():New()

		oWsdl:bNoCheckPeerCert := .T.
		
		oWsdl:lUseNSPrefix := .T. //Define se vai usar prefixo de namespace antes dos nomes das tags na mensagem SOAP que será enviada.
		
		oWsdl:SetAuthentication( cUser, cPass )
		lOk := oWsdl:GetAuthentication( cUser, cPass )
		if !lOk
			Conout("SetAuthentication/GetAuthentication ERROR: "  + oWsdl:cError)
			return
		endif
		
		// Faz o parse de uma URL
		xRet := oWsdl:ParseFile( "\" + funName() + ".wsdl" )
		If !xRet
			Conout("ParseFile ERROR: "  + oWsdl:cError)
			return
		EndIf
		
		aOps := oWsdl:ListOperations()
		If Len( aOps ) == 0
			Conout("ListOperations ERROR: "  + oWsdl:cError)
			return
		EndIf
		//varinfo( "", aOps )
		
		// protecao para erro de array out of bounds
		If Len(aOps) > 2
			If !Len(aOps[3]) > 0	
				Conout("ListOperations ERROR: "  + oWsdl:cError)
				Return()
			Endif	
		Else
			Conout("ListOperations ERROR: "  + oWsdl:cError)
			Return()
		Endif	

		// Define a operação
		xRet := oWsdl:SetOperation( aOps[3][1] )
		If !xRet
			Conout("SetOperation ERROR: "  + oWsdl:cError)
			return
		EndIf
		
		If (cAliasNF)->Z7_XOPESAP <> 2
			lContinua := .F.

			// verifica se gerou financeiro
			SE1->(dbSetOrder(1))
			If SE1->(dbSeek(xFilial("SE1")+SZ7->Z7_XCHAVE))
				If Alltrim(SE1->E1_TIPO) $ cTiposFin
					lContinua := .T.
					If Empty(nRegSE1)
						nRegSE1 := SE1->(Recno())
					Endif
					nTit++
				Endif

				// reposiciona no 1 registro novamente
				SE1->(dbGoto(nRegSE1))
					
				// verifica retencao
				While SE1->(!Eof()) .and. xFilial("SE1") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA;
					== SZ7->Z7_FILIAL + SZ7->Z7_XCHAVE
					If !Empty(SE1->E1_IRRF)
						nTitWT++
						nValRet += SE1->E1_IRRF
					Endif
					If !Empty(SE1->E1_ISS)
						nTitWT++
						nValRet += SE1->E1_ISS
					Endif
					If !Empty(SE1->E1_INSS)
						nTitWT++
						nValRet += SE1->E1_INSS
					Endif
					If !Empty(SE1->E1_PIS)
						nTitWT++
						nValRet += SE1->E1_PIS
					Endif
					If !Empty(SE1->E1_COFINS)
						nTitWT++
						nValRet += SE1->E1_COFINS
					Endif
					If !Empty(SE1->E1_CSLL)
						nTitWT++
						nValRet += SE1->E1_CSLL
					Endif
					SE1->(dbSkip())
				Enddo
				// reposiciona no 1 registro novamente
				SE1->(dbGoto(nRegSE1))
			Endif
				
			If !lContinua
				(cAliasNF)->(dbSkip())
				Loop
			Endif
				
			// posiciona cliente
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1_LOJA))
		
			// verifica se cliente jah foi enviado ao sap
			If Empty(SA1->A1_XCDSAP)
				U_ZF12GENSAP(	(cAliasNF)->Z7_FILIAL		,;	// Filial
								(cAliasNF)->Z7_XTABELA		,;	// Tabela
								(cAliasNF)->Z7_XCHAVE		,;	// Chave
								(cAliasNF)->Z7_XSEQUEN		,;	// Sequencia
								"E"				            ,;	// Status
								"Cliente sem código SAP gravado."+CRLF	,;	// Retorno
									""		)	                    // XML Envio
				(cAliasNF)->(dbSkip())
				Help("",1,"Envio movimento SAP",,"Cliente sem código SAP gravado.",1,0)
				Loop
			Endif
				
		Endif
		
		// posiciona natureza
		SED->(dbSetOrder(1))
		SED->(dbSeek(xFilial("SED")+SE1->E1_NATUREZ))
		
		If Select("cAliasCtb")   > 0
			(cAliasCtb)->(DBCLOSEAREA())
		endif
		
		cQ := " SELECT MAX(CT2_SEQUEN) CT2_SEQUEN "
		cQ += " FROM " + RetSqlName("CT2") + " CT2 " + CRLF
		cQ += " INNER JOIN " + RetSqlName("CV3") + " CV3 " + CRLF
		cQ += " ON TRIM(CV3.CV3_RECDES) = TRIM(CT2.R_E_C_N_O_) "
		cQ += " AND CV3.D_E_L_E_T_ <> '*' "
		cQ += " AND CT2.D_E_L_E_T_ <> '*' " + CRLF
		cQ += " WHERE " + CRLF
		//cQ += " CV3.CV3_RECORI='"+ALLTRIM(STR((cAliasTit)->SD2_RECNO))+"' AND CV3.CV3_TABORI='SD2' AND CT2.CT2_AT01DB=' ' AND CT2.CT2_TPSALD = '1' "
		//cQ += " CV3.CV3_RECORI = '"+ALLTRIM(STR((cAliasTit)->SD2_RECNO))+"' AND CV3.CV3_TABORI = 'SD2' AND CT2.CT2_TPSALD = '1' "
		If !lDev
			cQ += " CV3.CV3_RECORI     = "+(cAliasNF)->Z7_RECORI+" "
			cQ += " AND CV3.CV3_TABORI = 'SE1' "
			cQ += " AND CT2.CT2_TPSALD = '1' "
			cQ += " AND CT2_LP = '510' "
		Endif
		cQ += " AND SUBSTR(CT2_ORIGEM,1,7) NOT IN "+FormatIn(cOrigRet,"/")+" "	

		cAliasCtb := GetNextAlias()
		cQ := ChangeQuery(cQ)
		
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQ), cAliasCtb, .F., .T.)
		
		If (cAliasCtb)->(!Eof()) .and. !Empty((cAliasCtb)->CT2_SEQUEN)
			cSeq := (cAliasCtb)->CT2_SEQUEN
		Endif
		
		(cAliasCtb)->(dbCloseArea())	
		
		cQ := " SELECT DISTINCT				  " + CRLF
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
		//cQ += " CV3.CV3_RECORI='"+ALLTRIM(STR((cAliasTit)->SD2_RECNO))+"' AND CV3.CV3_TABORI='SD2' AND CT2.CT2_AT01DB=' ' AND CT2.CT2_TPSALD = '1' "
		//cQ += " CV3.CV3_RECORI = '"+ALLTRIM(STR((cAliasTit)->SD2_RECNO))+"' AND CV3.CV3_TABORI = 'SD2' AND CT2.CT2_TPSALD = '1' "
		If !lDev
			cQ += " CV3.CV3_RECORI     = "+(cAliasNF)->Z7_RECORI+" "
			cQ += " AND CV3.CV3_TABORI = 'SE1' "
			cQ += " AND CT2.CT2_TPSALD = '1' "
			cQ += " AND CT2_LP = '510' "
		Endif	
		cQ += " AND CT2_SEQUEN = '"+cSeq+"' "
		cQ += " AND SUBSTR(CT2_ORIGEM,1,7) NOT IN "+FormatIn(cOrigRet,"/")+" "
		cQ += " ORDER BY CT2_LINHA "
		//Fim query
		
		cAliasCtb := GetNextAlias()
		cQ := ChangeQuery(cQ)
		
		memoWrite( "C:\TEMP\CMVSAP12.TXT",cQ )
			
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQ), cAliasCtb, .F., .T.)
			
		// se nao achar contabilizacao, nao prossegue
		If (cAliasCtb)->(Eof())
			(cAliasCtb)->(dbCloseArea())
			//U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","Não encontrado contabilização com saldo tipo 1 ( Real ), para este documento."+CRLF)
			(cAliasNF)->(dbSkip())
			Help("",1,"Envio movimento SAP",,"Movimento contabilizado com inconsistência.",1,0)
			LOOP
		EndIf
		
		nOcorGL    := 0
		nOcorEstGL := 0
		While (cAliasCtb)->(!Eof())
			// desconsidera esta linha/valor do accountgl pois deverah aparecer no AccountReceivable
			If !Empty((cAliasCtb)->CT2_AT01CR) .or. !Empty((cAliasCtb)->CT2_AT01DB)
				nAtiv := (cAliasCtb)->CT2_VALOR+nValRet
				If !Empty((cAliasCtb)->CT2_AT01CR)
					lInvSinal := .T.
				//	nAtiv := (cAliasCtb)->CT2_VALOR * -1
				//ElseIf !Empty((cAliasCtb)->CT2_AT01DB)
				//	nAtiv := (cAliasCtb)->CT2_VALOR
				Endif	
				(cAliasCtb)->(DBSkip())
				Loop
			Endif
			
			If !Subs((cAliasCtb)->CT2_ORIGEM,1,7) $ cOrigEst
				nOcorGL++
			Else
				nOcorEstGL++
			Endif
			(cAliasCtb)->(dbSkip())
		EndDo

		(cAliasCtb)->(dbGoTop())
			
		aComplex := oWsdl:NextComplex()
		while ValType( aComplex ) == "A"
			//varinfo( "aComplex", aComplex )
			
			If aComplex[2] == "documentos"
				nOccurs := IIf(!Empty(nOcorEstGL) .and. !Empty(nOcorGL),2,1) //1
			ElseIf aComplex[2] == "DocumentHeader"
				nOccurs := 1
			ElseIf aComplex[2] == "AccountGL"
				If !Empty(nOcorEstGL) .and. !Empty(nOcorGL)
					If aComplex[5] == "ContasAReceberRequest#1.documentos#1"
						nOccurs := nOcorGL
					Elseif aComplex[5] == "ContasAReceberRequest#1.documentos#2"
						nOccurs := nOcorEstGL
					Endif
				Elseif !Empty(nOcorGL)
					nOccurs := nOcorGL
				Elseif !Empty(nOcorEstGL)
					nOccurs := nOcorEstGL
				Endif
			elseIf aComplex[2] == "AccountReceivable"
				If aComplex[5] == "ContasAReceberRequest#1.documentos#1"
					nOccurs := nTit
				Else
					nOccurs := 0
				Endif
			elseIf aComplex[2] == "AccountWT"
				If aComplex[5] == "ContasAReceberRequest#1.documentos#1"
					/*
					IF SE1->E1_IRRF==0 .and. SE1->E1_ISS==0 .and. SE1->E1_INSS==0 .and. SE1->E1_PIS==0 .and. ;
						SE1->E1_COFINS==0 .and. SE1->E1_CSLL==0
						nOccurs := 0
					ELSE
						nOccurs := 1 //após POC precisa ser revalidado
					endif
					*/
					nOccurs := nTitWT
				Else
					nOccurs := 0
				Endif
			EndIf
				
				xRet := oWsdl:SetComplexOccurs( aComplex[1], nOccurs )
				If xRet == .F.
					Conout( "Erro ao definir elemento " + aComplex[2] + ", ID " + cValToChar( aComplex[1] ) + ", com " + cValToChar( nOccurs ) + " ocorrencias" )
					Return
				EndIf
				
			aComplex := oWsdl:NextComplex()
		EndDo
			
		aSimple := oWsdl:SimpleInput()
		//varinfo( "", aSimple )
		
		nCount := IIf(!Empty(nOcorGL) .and. !Empty(nOcorEstGL),2,1)
		
		//--------------------------------------------------------Adicionar campos Necessarios
		cXDiv := Right( AllTrim(xEncCGC(SE1->E1_FILIAL)), 4 )
		
		// Define o valor de cada parâmeto necessário
		nPos := aScan( aSimple, {|aVet| aVet[2] == "sistema" } )
		xRet := oWsdl:SetValue( aSimple[nPos][1], "TOTVS" )	//sistema
		If !xRet
			U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","sistema Erro: " + oWsdl:cError)
			(cAliasNF)->(dbSkip())
			Loop
		EndIf
		
		nPos := aScan( aSimple, {|aVet| aVet[2] == "data" } )
		xRet := oWsdl:SetValue( aSimple[nPos][1], left( fwTimeStamp( 5 ) , 10 ) )	//data
		If !xRet
			U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","data Erro: " + oWsdl:cError)
			(cAliasNF)->(dbSkip())
			Loop
		EndIf
		
		nPos := aScan( aSimple, {|aVet| aVet[2] == "hora" } )
		xRet := oWsdl:SetValue( aSimple[nPos][1], Time() )	//hora
		If !xRet
			U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","hora Erro: " + oWsdl:cError)
			(cAliasNF)->(dbSkip())
			Loop
		EndIf
		
		nPos := aScan( aSimple, {|aVet| aVet[2] == "idLote" } )
		xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(Str(Val((cAliasNF)->Z7_XLOTE))))	//idLote
		If !xRet
			U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","idLote Erro: " + oWsdl:cError)
			(cAliasNF)->(dbSkip())
			Loop
		EndIf
		//-----------------------------------------------DocumentHeader
		For nCnt:=1 To nCount
			If !lContinua
				Exit
			Endif
			If nCnt == 1
				cDoc := "1"
			Else
				cDoc := "2"
			Endif
			
			nPos := aScan( aSimple, {|aVet| aVet[2] == "empresa" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".DocumentHeader#1" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], SUBSTR(SE1->E1_FILIAL,1,4) )	//empresa
			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","empresa Erro: " + oWsdl:cError)
				lContinua := .F.
				(cAliasNF)->(dbSkip())
				Loop
			EndIf
			
			nPos := aScan( aSimple, {|aVet| aVet[2] == "divisao" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".DocumentHeader#1" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], cXDiv )	//divisao ???
			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","divisao Erro: " + oWsdl:cError)
				lContinua := .F.
				(cAliasNF)->(dbSkip())
				Loop
			EndIf
			
			nPos := aScan( aSimple, {|aVet| aVet[2] == "filial" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".DocumentHeader#1" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], RIGHT(SE1->E1_FILIAL, 4) )	//filial
			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","filial Erro: " + oWsdl:cError)
				lContinua := .F.
				(cAliasNF)->(dbSkip())
				Loop
			EndIf
			
			nPos := aScan( aSimple, {|aVet| aVet[2] == "dataDocumento" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".DocumentHeader#1" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], xDtSap(dTos(SE1->E1_EMISSAO)))	//dataDocumento
			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","dataDocumento Erro: " + oWsdl:cError)
				lContinua := .F.
				(cAliasNF)->(dbSkip())
				Loop
			EndIf
			
			nPos := aScan( aSimple, {|aVet| aVet[2] == "tipoDocumento" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".DocumentHeader#1" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1],IIf(nCnt==1,SED->ED_XTIPO,"WS")) 	//tipoDocumento
			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","tipoDocumento Erro: " + oWsdl:cError)
				lContinua := .F.
				(cAliasNF)->(dbSkip())
				Loop
			EndIf
			
			nPos := aScan( aSimple, {|aVet| aVet[2] == "dataLancamentoDocumento" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".DocumentHeader#1" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], xDtSap(dTos(SE1->E1_EMIS1)) )	//dataLancamentoDocumento
			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","dataLancamentoDocumento Erro: " + oWsdl:cError)
				lContinua := .F.
				(cAliasNF)->(dbSkip())
				Loop
			EndIf
			
			nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroDocumentoReferencia" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".DocumentHeader#1" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], IIf(!lDev,Alltrim(SD2->D2_DOC)+IIf(!Empty(SD2->D2_SERIE),"/"+Alltrim(SD2->D2_SERIE),""),Alltrim(SD1->D1_DOC)+IIf(!Empty(SD1->D1_SERIE),"/"+Alltrim(SD1->D1_SERIE),"")))	//numeroDocumentoReferencia ???
			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","numeroDocumentoReferencia Erro: " + oWsdl:cError)
				lContinua := .F.
				(cAliasNF)->(dbSkip())
				Loop
			EndIf
			
			nPos := aScan( aSimple, {|aVet| aVet[2] == "chaveCabecalho1" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".DocumentHeader#1" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], IIf(!lDev,IIf(Empty(SC6->C6_CHASSI),Alltrim(SD2->D2_DOC)+IIf(!Empty(SD2->D2_SERIE),"/"+Alltrim(SD2->D2_SERIE),""),Alltrim(SC6->C6_CHASSI)),IIf(Empty(SD1->D1_CHASSI),Alltrim(SD1->D1_DOC)+IIf(!Empty(SD1->D1_SERIE),"/"+Alltrim(SD1->D1_SERIE),""),Alltrim(SD1->D1_CHASSI))))	//chaveCabecalho1
			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","chaveCabecalho1 Erro: " + oWsdl:cError)
				lContinua := .F.
				(cAliasNF)->(dbSkip())
				Loop
			EndIf
			
			nPos := aScan( aSimple, {|aVet| aVet[2] == "chaveCabecalho2" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".DocumentHeader#1" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1]," "  )	//chaveCabecalho2
			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","chaveCabecalho2 Erro: " + oWsdl:cError)
				lContinua := .F.
				(cAliasNF)->(dbSkip())
				Loop
			EndIf
			
			nPos := aScan( aSimple, {|aVet| aVet[2] == "textoCabecalhoDocumento" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".DocumentHeader#1" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1],IIf(!lDev,IIf(Empty(SA3->A3_NOME)," ",SUBSTR(SA3->A3_NOME,1,25))," "))	//textoCabecalhoDocumento - Nome do usuário que efetuou o lançamento
			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","textoCabecalhoDocumento Erro: " + oWsdl:cError)
				lContinua := .F.
				(cAliasNF)->(dbSkip())
				Loop
			EndIf
			
			nPos := aScan( aSimple, {|aVet| aVet[2] == "motivoOperacao" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".DocumentHeader#1" } )//"1" - Lançamento / "2" Estorno/Cancelamento
			xRet := oWsdl:SetValue( aSimple[nPos][1], "1" )
			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","motivoOperacao Erro: " + oWsdl:cError)
				lContinua := .F.
				(cAliasNF)->(dbSkip())
				Loop
			EndIf
		Next
		//--------------------------------------------------------------------------------AccountGL
		For nCnt:=1 To nCount
			If !lContinua
				Exit
			Endif
			If nCnt == 1
				cDoc := "1"
			Else
				cDoc := "2"
			Endif
			nz:=1

			(cAliasCtb)->(dbGoTop())
			While (cAliasCtb)->(!Eof())
				If !lContinua
					Exit
				Endif
				// desconsidera esta linha/valor do accountgl pois deverah aparecer no AccountReceivable
				If IIf(!lDev,!Empty((cAliasCtb)->CT2_AT01DB),!Empty((cAliasCtb)->CT2_AT01CR))
					(cAliasCtb)->(DBSkip())
					Loop
				Endif
				If nCnt == 1 .and. Subs((cAliasCtb)->CT2_ORIGEM,1,7) $ cOrigEst
					(cAliasCtb)->(dbSkip())
					Loop
				Endif
				If nCnt == 2 .and. !Subs((cAliasCtb)->CT2_ORIGEM,1,7) $ cOrigEst
					(cAliasCtb)->(dbSkip())
					Loop
				Endif
				
				If Subs((cAliasCtb)->CT2_ORIGEM,1,7) $ cOrigEst
					nNumEst++
					nNumAux := nNumEst
				Else
					nNum++
					nNumAux := nNum
				Endif
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroItemDocumentoContabilidade" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".AccountGL#" + Alltrim(Str(nz)) } )//numeroItemDocumentoContabilidade
				xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR(nNumAux)) )
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","numeroItemDocumentoContabilidade Erro: " + oWsdl:cError)
					lContinua := .F.
					(cAliasCtb)->(dbSkip())
					Loop
				EndIf
				
				if (cAliasCtb)->CT2_DC=='1'
					nPos := aScan( aSimple, {|aVet| aVet[2] == "contaRazaoContabilidadeGeral" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".AccountGL#" + Alltrim(Str(nz))} )//contaRazaoContabilidadeGeral EM BRanco
					xRet := oWsdl:SetValue( aSimple[nPos][1],alltrim((cAliasCtb)->CT2_DEBITO) )
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","contaRazaoContabilidadeGeral Erro: " + oWsdl:cError)
						lContinua := .F.
						(cAliasCtb)->(dbSkip())
						Loop
					EndIf
				ELSE
					nPos := aScan( aSimple, {|aVet| aVet[2] == "contaRazaoContabilidadeGeral" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".AccountGL#" + Alltrim(Str(nz)) } )//contaRazaoContabilidadeGeral EM BRanco
					xRet := oWsdl:SetValue( aSimple[nPos][1],alltrim((cAliasCtb)->CT2_CREDIT))
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","contaRazaoContabilidadeGeral Erro: " + oWsdl:cError)
						lContinua := .F.
						(cAliasCtb)->(dbSkip())
						Loop
					EndIf
				ENDIF
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "textoItem" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".AccountGL#" + Alltrim(Str(nz))} )//textoItem
				xRet := oWsdl:SetValue( aSimple[nPos][1], (cAliasCtb)->CT2_HIST )
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","textoItem Erro: " + oWsdl:cError)
					lContinua := .F.
					(cAliasCtb)->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "tipoDocumento" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".AccountGL#" + Alltrim(Str(nz))} )//tipoDocumento Será herdado do cabeçalho ???
				xRet := oWsdl:SetValue( aSimple[nPos][1],IIf(nCnt==1,SED->ED_XTIPO,"WS"))
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","tipoDocumento Erro: " + oWsdl:cError)
					lContinua := .F.
					(cAliasCtb)->(dbSkip())
					Loop
				EndIf
				cNumAtrib := ""  //iniciar DAC
				cNumAtrib := SZ7->Z7_DOCORI

				nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroAtribuicao" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".AccountGL#" + Alltrim(Str(nz))} )//Nº atribuição
				//xRet := oWsdl:SetValue( aSimple[nPos][1],IIf(!lDev,SD2->D2_PEDIDO,SD1->D1_PEDIDO))
				xRet := oWsdl:SetValue( aSimple[nPos][1],cNumAtrib)
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","numeroAtribuicao Erro: " + oWsdl:cError)
					lContinua := .F.
					(cAliasCtb)->(dbSkip())
					Loop
				EndIf
				If (cAliasCtb)->CT2_DC == "1"//Debito
					nPos := aScan( aSimple, {|aVet| aVet[2] == "centroCusto" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".AccountGL#" + Alltrim(Str(nz))} )//CentroCusto
					xRet := oWsdl:SetValue( aSimple[nPos][1],IIf(!Empty((cAliasCtb)->CT2_CCD),Alltrim((cAliasCtb)->CT2_CCD)," "))
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","centroCusto Erro: " + oWsdl:cError)
						lContinua := .F.
						(cAliasCtb)->(dbSkip())
						Loop
					EndIf
						
					cLucro := Alltrim((cAliasCtb)->CT2_CLVLDB)
					nPos := aScan( aSimple, {|aVet| aVet[2] == "centroLucro" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".AccountGL#" + Alltrim(Str(nz))} ) //CentroLucro
					xRet := oWsdl:SetValue( aSimple[nPos][1], IIf(Empty((cAliasCtb)->CT2_CCD),Alltrim((cAliasCtb)->CT2_CLVLDB)," "))
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","centroLucro Erro: " + oWsdl:cError)
						lContinua := .F.
						(cAliasCtb)->(dbSkip())
						Loop
					EndIf
						
					nPos := aScan( aSimple, {|aVet| aVet[2] == "montanteMoedaPagamento" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".AccountGL#" + Alltrim(Str(nz))} )//montanteMoedaPagamento
					xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR((cAliasCtb)->CT2_VALOR)) )
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","montanteMoedaPagamento Erro: " + oWsdl:cError)
						lContinua := .F.
						(cAliasCtb)->(dbSkip())
						Loop
					EndIf
				ELSE
					nPos := aScan( aSimple, {|aVet| aVet[2] == "centroCusto" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".AccountGL#" + Alltrim(Str(nz))} )//CentroCusto
					xRet := oWsdl:SetValue( aSimple[nPos][1],IIf(!Empty((cAliasCtb)->CT2_CCC),Alltrim((cAliasCtb)->CT2_CCC)," "))
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","centroCusto Erro: " + oWsdl:cError)
						lContinua := .F.
						(cAliasCtb)->(dbSkip())
						Loop
					EndIf
						
					cLucro := Alltrim((cAliasCtb)->CT2_CLVLCR)
					nPos := aScan( aSimple, {|aVet| aVet[2] == "centroLucro" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".AccountGL#" + Alltrim(Str(nz))} ) //CentroLucro
					xRet := oWsdl:SetValue( aSimple[nPos][1], IIf(Empty((cAliasCtb)->CT2_CCC),Alltrim((cAliasCtb)->CT2_CLVLCR)," "))
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","centroLucro Erro: " + oWsdl:cError)
						lContinua := .F.
						(cAliasCtb)->(dbSkip())
						Loop
					EndIf
					
					nPos := aScan( aSimple, {|aVet| aVet[2] == "montanteMoedaPagamento" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".AccountGL#" + Alltrim(Str(nz))} )//montanteMoedaPagamento
					xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR((cAliasCtb)->CT2_VALOR * -1)) )
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","montanteMoedaPagamento Erro: " + oWsdl:cError)
						lContinua := .F.
						(cAliasCtb)->(dbSkip())
						Loop
					EndIf
				ENDIF
					
				nPos := aScan( aSimple, {|aVet| aVet[2] == "montanteDescontoMoedaTipoMoeda" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".AccountGL#" + Alltrim(Str(nz))} )//montanteMoedaPagamento
				xRet := oWsdl:SetValue( aSimple[nPos][1], "0.00")
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","montanteDescontoMoedaTipoMoeda Erro: " + oWsdl:cError)
					lContinua := .F.
					(cAliasCtb)->(dbSkip())
					Loop
				EndIf
				nz++
				
				(cAliasCtb)->(dbSkip())
			enddo
		Next
			//----------------------------------AccountReceivable
			//(cAliasTit)->(dbgotop())
			nz:=1
			// reposiciona no 1 registro novamente
			SE1->(dbSetOrder(2))
			SE1->(dbGoto(nRegSE1))
			nNumAux := nNum
			//nVlrTit := NoRound(nAtiv/nTit,2)
			
			cChaveTit := IIf(!lDev,xFilial("SZ7")+SZ7->Z7_PREFIXO+SZ7->Z7_NUM+SZ7->Z7_PARCELA+SZ7->Z7_TIPO,xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
			
			While SE1->(!Eof()) .and. cChaveTit == SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
				If !lContinua
					Exit
				Endif
				
				If Alltrim(SE1->E1_TIPO) <> "RA"
					SE1->(dbSkip())
					Loop
				Endif	
				
				nNumAux++

				nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroItemDocumentoContabilidade" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )//numeroItemDocumentoContabilidade
				xRet := oWsdl:SetValue( aSimple[nPos][1],ALLTRIM(STR(nNumAux)))
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","numeroItemDocumentoContabilidade Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroCliente" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )//numeroCliente
				xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(SA1->A1_CGC))
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","numeroCliente Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "chaveReferenciaParceiroNegocios1" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )//chaveReferenciaParceiroNegocios1
				xRet := oWsdl:SetValue( aSimple[nPos][1], IIf(Empty(SE1->E1_XPLACA)," ",Alltrim(SE1->E1_XPLACA)))
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","chaveReferenciaParceiroNegocios1 Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "chaveReferenciaParceiroNegocios2".and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )//chaveReferenciaParceiroNegocios2
				xRet := oWsdl:SetValue( aSimple[nPos][1]," ")
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","chaveReferenciaParceiroNegocios2 Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				IF SUBSTR(SE1->E1_NATUREZ,1,2)=="11"
					nPos := aScan( aSimple, {|aVet| aVet[2] == "chaveReferenciaItemDocumento".and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )//chaveReferenciaItemDocumento
					xRet := oWsdl:SetValue( aSimple[nPos][1], SE1->E1_NUMBCO)
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","chaveReferenciaItemDocumento Erro: " + oWsdl:cError)
						lContinua := .F.
						SE1->(dbSkip())
						Loop
					EndIf
				ELSE
					nPos := aScan( aSimple, {|aVet| aVet[2] == "chaveReferenciaItemDocumento" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )//chaveReferenciaItemDocumento
					xRet := oWsdl:SetValue( aSimple[nPos][1], " ")
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","chaveReferenciaItemDocumento Erro: " + oWsdl:cError)
						lContinua := .F.
						SE1->(dbSkip())
						Loop
					EndIf
				ENDIF
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "dataBaseParaCalculoVencimento" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )//chaveReferenciaItemDocumento
				xRet := oWsdl:SetValue( aSimple[nPos][1], xDtSap(dTos(SE1->E1_EMISSAO)))
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","chaveReferenciaItemDocumento Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "diasDeDesconto1" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )//diasDesconto1
				xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR(SE1->E1_VENCTO - SE1->E1_EMISSAO)))
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","diasDesconto1 Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "formaDePagamento".and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )//diasDesconto1
				xRet := oWsdl:SetValue( aSimple[nPos][1], " ")
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","formaDePagamento Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf

				nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroAtribuicao" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
				//xRet := oWsdl:SetValue( aSimple[nPos][1], IIf(!lDev,SD2->D2_PEDIDO,SD1->D1_PEDIDO)+IIf(!Empty(SE1->E1_PARCELA),"/"+Alltrim(SE1->E1_PARCELA),""))
//				xRet := oWsdl:SetValue( aSimple[nPos][1],cNumAtrib+IIf(!Empty(SE1->E1_PARCELA),"/"+Alltrim(SE1->E1_PARCELA),""))
				xRet := oWsdl:SetValue( aSimple[nPos][1],cNumAtrib+IIf(!Empty(SE1->E1_PARCELA),"/"+Alltrim(U_ZF03GENSAP(SE1->E1_PARCELA)),""))
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","NumeroAtribuicao Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "textoDoItem" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
				//xRet := oWsdl:SetValue( aSimple[nPos][1], " ")
				xRet := oWsdl:SetValue( aSimple[nPos][1], IIf(!lDev," ","DEVOLUÇÃO REF. NF NUM: "+Alltrim(SF2->F2_DOC)+IIF(!Empty(SF2->F2_SERIE),"-"+Alltrim(SF2->F2_SERIE),"")+" DE "+dToc(SF2->F2_EMISSAO)))
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","textoDoItem Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
					nPos := aScan( aSimple, {|aVet| aVet[2] == "montanteMoedaPagamento" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
					//xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR(SE1->E1_VALOR)))
					//xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR((SE1->E1_VALOR-SE1->E1_IRRF-SE1->E1_ISS-SE1->E1_INSS-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL))))
					//xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR(IIf(lInvSinal,nVlrTit * -1,nVlrTit))))
					xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR(IIf(lInvSinal,SE1->E1_VALOR * -1,SE1->E1_VALOR)))) //###LINHA ORIGINAL
//					xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR(IIf(lInvSinal,(SE1->E1_VALOR-SE1->E1_DECRESC) * -1,(SE1->E1_VALOR-SE1->E1_DECRESC))))) 
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","montanteMoedaPagamento Erro: " + oWsdl:cError)
						lContinua := .F.
						SE1->(dbSkip())
						Loop
					EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "chaveBreveUmBancoDaEmpresa" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
				xRet := oWsdl:SetValue( aSimple[nPos][1], SE1->E1_PORTADO)
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","chaveBreveUmBancoDaEmpresa Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				//SE FOR PEDIDO?????
				nPos := aScan( aSimple, {|aVet| aVet[2] == "codigoDoRazaoEspecial" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
				xRet := oWsdl:SetValue( aSimple[nPos][1], " ")
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","chaveBreveUmBancoDaEmpresa Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "centroLucro" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
				xRet := oWsdl:SetValue( aSimple[nPos][1], cLucro)
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","centroLucro Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "montanteDescontoMoedaTipoMoeda" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
				xRet := oWsdl:SetValue( aSimple[nPos][1], "0.00")
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","montanteDescontoMoedaTipoMoeda Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
		

				//cForma := IIf(!Empty(SE1->E1_XFORMA),SE1->E1_XFORMA,IIf(!Empty(GetAdvFVal("SE4","E4_XFORMA",xFilial("SE4")+IIf(!lDev,SF2->F2_COND,SF1->F1_COND),1," ")),Alltrim(GetAdvFVal("SE4","E4_XFORMA",xFilial("SE4")+IIf(!lDev,SF2->F2_COND,SF1->F1_COND),1," "))," ")) 
				cForma := IIf(!Empty(SE1->E1_XFORMA),SE1->E1_XFORMA,IIf(!Empty(GetAdvFVal("SE4","E4_XFORMA",xFilial("SE4")+IIf(!lDev,cCondPag,SF1->F1_COND),1," ")),Alltrim(GetAdvFVal("SE4","E4_XFORMA",xFilial("SE4")+IIf(!lDev,cCondPag,SF1->F1_COND),1," "))," ")) 
				nPos := aScan( aSimple, {|aVet| aVet[2] == "codigoBancoCentral" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
				xRet := oWsdl:SetValue( aSimple[nPos][1], cForma)
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","codigoBancoCentral Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "idExterno" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
				//xRet := oWsdl:SetValue( aSimple[nPos][1], "T"+(cAliasNF)->Z7_XTABELA+(cAliasNF)->Z7_TIPONF+SE1->E1_PARCELA+ALLTRIM(STR(IIf(!lDev,SF2->(Recno()),SF1->(Recno())))))
				xRet := oWsdl:SetValue( aSimple[nPos][1], "T"+allTrim(str((cAliasNF)->SZ7_RECNO))+IIf(!Empty(SE1->E1_PARCELA),"P"+Alltrim(StrZero(Val(SE1->E1_PARCELA),TamSX3("E1_PARCELA")[1])),"")) // mandar a parcela, pois se1 poderah ter mais de uma parcela e este campo nao pode se repetir
				//xRet := oWsdl:SetValue( aSimple[nPos][1], "T"+ALLTRIM(STR(SE1->(Recno()))))
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","idExterno Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf

				// retencao
				IF !Empty(SE1->E1_IRRF) .and. lContinua
					TagAccWT(@lContinua,aSimple,oWsdl,nNumAux,cAliasNF,nZ,"IR-",SE1->E1_BASEIRF,SE1->E1_IRRF,@nCountWT)
					If !lContinua
						SE1->(dbSkip())
						Loop
					Endif	
					
					/*	
					nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroItemDocumentoContabilidade" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountWT#" + Alltrim(Str(nz))} )//numeroItemDocumentoContabilidade
					xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR(nNumAux)))
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","numeroItemDocumentoContabilidade Erro: " + oWsdl:cError)
						lContinua := .F.
						SE1->(dbSkip())
						Loop
					EndIf
					
					nPos := aScan( aSimple, {|aVet| aVet[2] == "CodCategoriaImpostoRF" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountWT#" + Alltrim(Str(nz))} )//CodCategoriaImpostoRF
					xRet := oWsdl:SetValue( aSimple[nPos][1], SED->ED_XCATIM)
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","CodCategoriaImpostoRF Erro: " + oWsdl:cError)
						lContinua := .F.
						SE1->(dbSkip())
						Loop
					EndIf
					
					nPos := aScan( aSimple, {|aVet| aVet[2] == "CodImpostoRF" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountWT#" + Alltrim(Str(nz))} )//CodImpostoRF
					xRet := oWsdl:SetValue( aSimple[nPos][1],SED->ED_XCODIM)
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","CodImpostoRF Erro: " + oWsdl:cError)
						lContinua := .F.
						SE1->(dbSkip())
						Loop
					EndIf
					
					nPos := aScan( aSimple, {|aVet| aVet[2] == "MontanteBaseIRF" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountWT#" + Alltrim(Str(nz))} )//MontanteBaseIRF
					xRet := oWsdl:SetValue( aSimple[nPos][1],alltrim(str(SE1->E1_BASEIRF)))
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","MontanteBaseIRF Erro: " + oWsdl:cError)
						lContinua := .F.
						SE1->(dbSkip())
						Loop
					EndIf
					
					nPos := aScan( aSimple, {|aVet| aVet[2] == "MontanteIRFManualmente" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountWT#" + Alltrim(Str(nz))} )//MontanteIRFManualmente
					xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(Str(SE1->E1_IRRF)))
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","MontanteIRFManualmente Erro: " + oWsdl:cError)
						lContinua := .F.
						SE1->(dbSkip())
						Loop
					EndIf
					*/
				endif
				
				IF !Empty(SE1->E1_ISS) .and. lContinua
					TagAccWT(@lContinua,aSimple,oWsdl,nNumAux,cAliasNF,nZ,"IS-",SE1->E1_BASEISS,SE1->E1_ISS,@nCountWT)
					If !lContinua
						SE1->(dbSkip())
						Loop
					Endif	
				Endif	

				IF !Empty(SE1->E1_INSS) .and. lContinua
					TagAccWT(@lContinua,aSimple,oWsdl,nNumAux,cAliasNF,nZ,"IN-",SE1->E1_BASEINS,SE1->E1_INSS,@nCountWT)
					If !lContinua
						SE1->(dbSkip())
						Loop
					Endif	
				Endif	

				IF !Empty(SE1->E1_PIS) .and. lContinua
					TagAccWT(@lContinua,aSimple,oWsdl,nNumAux,cAliasNF,nZ,"PI-",SE1->E1_BASEPIS,SE1->E1_PIS,@nCountWT)
					If !lContinua
						SE1->(dbSkip())
						Loop
					Endif	
				Endif	

				IF !Empty(SE1->E1_COFINS) .and. lContinua
					TagAccWT(@lContinua,aSimple,oWsdl,nNumAux,cAliasNF,nZ,"CF-",SE1->E1_BASECOF,SE1->E1_COFINS,@nCountWT)
					If !lContinua
						SE1->(dbSkip())
						Loop
					Endif	
				Endif	

				IF !Empty(SE1->E1_CSLL) .and. lContinua
					TagAccWT(@lContinua,aSimple,oWsdl,nNumAux,cAliasNF,nZ,"CS-",SE1->E1_BASECSL,SE1->E1_CSLL,@nCountWT)
					If !lContinua
						SE1->(dbSkip())
						Loop
					Endif	
				Endif	
					
				SE1->(dbSkip())
				nz++
			enddo//Fim remover

			If lContinua
				oWsdl:lRemEmptyTags := .T. // remove tags vazias
				
				//Tratamento do XML de Envio
				cMsgSoap := oWsdl:GetSoapMsg()
				cMsgSoap	:= fwNoAccent( cMsgSoap )
				cMsgSoap	:= encodeUtf8( cMsgSoap )
			Endif
	endif
	
	If lContinua
		// Envia a mensagem SOAP ao servidor
		xRet := oWsdl:SendSoapMsg( cMsgSoap /*cMsg*/)
		
		If !xRet
			U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","SendSoapMsg Erro: " + oWsdl:cError,cMsgSoap)
			(cAliasNF)->(dbSkip())
			Loop
		Else
			// Recupera os elementos de retorno, já parseados
			cResp := oWsdl:GetParsedResponse()
			U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"A",cResp,cMsgSoap)
			
			//Exclusão SAP
			If !(cAliasNF)->Z7_XOPESAP == 2
				// se envio foi com sucesso, verifica se jah tem registro gerado de cancelamento na sz7, e caso tenha grava o xml para envio
				U_ZF17GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,cMsgSoap)
			Endif	
		EndIf
	Endif
	
	(cAliasNF)->(dbSkip())
ENDDO
If Select("cAliasCtb")   > 0
	(cAliasCtb)->(DbCloseArea())
ENDIF
If Select("cAliasNF")   > 0
	(cAliasNF)->(DbCloseArea())
ENDIF

cFilAnt := cFilAntSav

IF lIsBlind
	Conout("Conexão finalizada com sucesso : CMVSAP12 " + DTOC(dDATABASE) + " - " + TIME() )
	RpcClearEnv()
Endif	

return


Static Function TagAccWT(lContinua,aSimple,oWsdl,nNumAux,cAliasNF,nZ,cImp,nBaseImp,nValImp,nCountWT)

Local nPos := 0
Local xRet := Nil
Local aAreaSE1 := SE1->(GetArea())
Local aAreaSED := SED->(GetArea())
Local cChave := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA

SED->(dbSetOrder(1))
SE1->(dbSetOrder(1))
If SE1->(dbSeek(xFilial("SE1")+cChave+cImp))
	If SED->(dbSeek(xFilial("SED")+SE1->E1_NATUREZ))
		nCountWT++
		nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroItemDocumentoContabilidade" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountWT#" + Alltrim(Str(nCountWT))} )//numeroItemDocumentoContabilidade
		xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR(nNumAux)))
		If !xRet
			U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","numeroItemDocumentoContabilidade Erro: " + oWsdl:cError)
			lContinua := .F.
		EndIf
		
		nPos := aScan( aSimple, {|aVet| aVet[2] == "CodCategoriaImpostoRF" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountWT#" + Alltrim(Str(nCountWT))} )//CodCategoriaImpostoRF
		If !cImp == "IR-"
			xRet := oWsdl:SetValue( aSimple[nPos][1], SED->ED_XCATIM)
		Else
			xRet := oWsdl:SetValue( aSimple[nPos][1], allTrim(superGetMv("CAOASAP12B",,"IC")))
		Endif	
		If !xRet
			U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","CodCategoriaImpostoRF Erro: " + oWsdl:cError)
			lContinua := .F.
		EndIf
		
		nPos := aScan( aSimple, {|aVet| aVet[2] == "CodImpostoRF" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountWT#" + Alltrim(Str(nCountWT))} )//CodImpostoRF
		If !cImp == "IR-"
			xRet := oWsdl:SetValue( aSimple[nPos][1],SED->ED_XCODIM)
		Else
			xRet := oWsdl:SetValue( aSimple[nPos][1],allTrim(superGetMv("CAOASAP12C",,"S0")))
		Endif	
		If !xRet
			U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","CodImpostoRF Erro: " + oWsdl:cError)
			lContinua := .F.
		EndIf
		
		nPos := aScan( aSimple, {|aVet| aVet[2] == "MontanteBaseIRF" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountWT#" + Alltrim(Str(nCountWT))} )//MontanteBaseIRF
		xRet := oWsdl:SetValue( aSimple[nPos][1],alltrim(str(nBaseImp)))
		If !xRet
			U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","MontanteBaseIRF Erro: " + oWsdl:cError)
			lContinua := .F.
		EndIf
		
		nPos := aScan( aSimple, {|aVet| aVet[2] == "MontanteIRFManualmente" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountWT#" + Alltrim(Str(nCountWT))} )//MontanteIRFManualmente
		xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(Str(nValImp)))
		If !xRet
			U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","MontanteIRFManualmente Erro: " + oWsdl:cError)
			lContinua := .F.
		EndIf
	Endif
Endif

SED->(RestArea(aAreaSED))
SE1->(RestArea(aAreaSE1))

Return()


/*
Tratar data de AAAAMMDD para AAAA-MM-DD
*/
Static Function xDtSap(cData)
cRet := SubStr(cData,1,4) + "-" + SubStr(cData,5,2) + "-" + SubStr(cData,7,2)
return cRet

/*
Encontra o CGC da Filial
*/
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
user function xCMVSA12(xParam1,xParam2,xParam3)

U_CMVSAP12({{xParam1,xParam2,Val(xParam3)}})

Return()
