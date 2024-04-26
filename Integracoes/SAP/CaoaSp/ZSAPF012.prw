#include "topconn.ch"
#include "tbiconn.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#include "protheus.ch"

/*
Integracao de Contas a Receber com SAP
*/

/*-------------------------------------------------------------------------------------
{Protheus.doc} ZSAPF012 
Rdmake 	responsavel Integração SAP Nota Fiscal
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
@table 		VRJ = Pedido Venda Veic. Montadora  	
			VRK = Itens Ped. Venda Veíc. Montad.
			VV0 = Saídas de Veículos            
@history  	Alterado DAC-Denilso 01/06/2020 Chamado CAOA 406846 - Ajustado retorno quando nao localizar Pedido  
--------------------------------------------------------------------------------------*/
User Function ZSAPF012( aParam )

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
Local cOrigEst := ""//GetMv("CAOAORESTR",,"610-019/610-020/610-046/610-047")
Local nOcorGL := 0
Local nOcorEstGL := 0
Local nNumEst := 0
Local nNumAux := 0
Local lContinua := .T.
Local cQ := ""
Local cSD2 := ""
Local nRegSE1 := 0
Local cSeq := ""
Local lDev := .F.
Local cSD1 := ""
Local cFilAntSav := ""
Local cChaveTit := ""
Local nAtiv := 0
//Local nVlrTit := 0
//Local nVlrTitTot := 0
local nTitWT := 0
Local nCountWT := 0
Local lInvSinal := .F.
Local nDiasErro := 0
Local nValRet := 0
Local cOrigRet := ""
Local cDoc := ""
Local nDiasAguar := 0
Local cForma := "" 

Local nRecRep := 0
Local cEmpJob := ""
Local cFilJob := ""
Local cTiposFin := ""
Local cNumAtrib := ""
Local cPrefVei  := ""
Local nPos      := 0
Local xRet      := Nil
Local cCondPag  := ""
Local nCnt	    := 0
Local nCount	:= 0
Local cxEmp 	:= "" 
Local cxFil 	:= "" 
Local cXDiv     := ""
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
	
	If !LockByName("ZSAPF012")
		Alert("JOB já em Execução : ZSAPF012 " + DTOC(dDATABASE) + " - " + TIME() )
		RpcClearEnv()
		Return
	EndIf
EndIF

cxEmp    	:= GetMv("CMV_SAP001") 
cXFil	    := GetMv("CMV_SAP002")
cXDiv       := GetMv("CMV_SAP003")

cUser		:= allTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
cPass		:= allTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP
cURLProxy	:= allTrim( superGetMv( "CAOAPROXY"	, , "proxy.caoa.local"		) )	// Usuario Proxy da Rede Caoa
nPortProxy	:= superGetMv( "CAOAPORT"	, , 8080 )								// Porta Proxy da Rede Caoa
cUserProxy	:= allTrim( superGetMv( "CAOAPROUSE"	, , "T-RODRIGO.SALOMAO"	) )	// Usuario do Proxy
cPassProxy	:= allTrim( superGetMv( "CAOAPROPAS"	, , "caoa2019**"		) )	// Senha do Proxy
cUrl		:= allTrim( superGetMv( "CAOASAP12A"	, , "http://10.120.40.141:53400/dir/wsdl?p=ic/67105a33fc843b8b843c892dae69f375") )
nDiasErro	:= superGetMv( "CAOASAP01C"	, , 3 )  // qtde de dias para reprocessar registros com status de erro
nDiasAguar	:= superGetMv( "CAOASAP01D"	, , 3 )  // qtde de dias para reprocessar registros com status de aguardando
cTiposFin 	:= GetMv("CAOASAP12D",,"NF/DP")
cPrefVei 	:= superGetMv( "CAOASAP17A"	, , "OFI/VEI" )  // prefixos de titulos originados no sigavei

If Select("cAliasNF")   > 0
	(cAliasNF)->(DBCLOSEAREA())
endif

VRJ->(dbSetOrder(1))
cQ := "SELECT SZ7.*,SZ7.R_E_C_N_O_ SZ7_RECNO "
cQ += "FROM "+RetSqlName("SZ7")+" SZ7 "
cQ += "WHERE (Z7_XSTATUS = 'P' OR (Z7_XSTATUS = 'E' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasErro)+"')) "
cQ += "AND ((Z7_XTABELA = 'SF2' AND Z7_TIPONF NOT IN ('B','D')) "
cQ += "OR (Z7_XTABELA = 'SF1' AND Z7_TIPONF = 'D')) "  
cQ += "AND D_E_L_E_T_ <> '*' "

If nRecRep > 0
	cQ += " AND SZ7.R_E_C_N_O_ = " + AllTrim(Str(nRecRep))
EndIf

cQ += " ORDER BY SZ7.R_E_C_N_O_ "

cAliasNF := GetNextAlias()
cQ := ChangeQuery(cQ)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQ), cAliasNF, .F., .T.)

cFilAntSav := cFilAnt

while !(cAliasNF)->(Eof())
	cFilAnt := (cAliasNF)->Z7_FILIAL
	nNum :=0
	nNumEst := 0
	nNumAux := 0
	lContinua := .T.
	lDev := .F.
	nRegSE1 := 0
	nAtiv := 0
	//nVlrTit := 0
	//nVlrTitTot := 0
	oWsdl := Nil
	cSeq := ""
	cSD1 := ""
	cSD2 := ""
	nTit := 0
	nTitWT := 0
	nCountWT := 0
	lInvSinal := .F.
	nValRet := 0
	cDoc := ""
	cNumAtrib := ""
	cCondPag := ""
	
	// verifica se trata-se de nota de devolucao de vendas
	If (cAliasNF)->Z7_XTABELA == "SF1" .and. (cAliasNF)->Z7_TIPONF == "D"
		lDev := .T.
		cOrigEst := GetMv("CAOAORESTP",,"650-004/650-005")
		cOrigRet := GetMv("CAOAORRETP",,"650-222/650-223/650-224/650-225")
	Else
		cOrigEst := GetMv("CAOAORESTR",,"610-019/610-020/610-046/610-047")
		cOrigRet := GetMv("CAOAORRETR",,"610-221/610-222")	
	Endif	

	/*	
	//Exclusão SAP
	If (cAliasNF)->Z7_XOPESAP == 2 // 05/09/19
		If (cAliasNF)->Z7_XSEQUEN <> '001' .and. !U_ZF13GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN)
			(cAliasNF)->(dbSkip())
			LOOP
		EndIf
	Endif	
	*/
//Exclusão SAP
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

//Exclusão SAP
If (cAliasNF)->Z7_XOPESAP == 2
	//cMsgSoap := U_ZF14GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,{{"motivoOperacao","2"}})
	cMsgSoap := U_ZF15GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,{{"motivoOperacao","2"}})
ENDIF

If !lDev
	// posiciona SF2, usar goto pois registro pode estar deletado
	// Valida se possui SEFAZ
	SF2->(dbGoto((cAliasNF)->Z7_RECORI))
	If !U_ZF08GENSAP(SF2->F2_ESPECIE,SF2->F2_CHVNFE,SF2->F2_FIMP,SF2->F2_DOC,SF2->F2_SERIE)
		(cAliasNF)->(dbSkip())
		LOOP
	Endif
Else
	// posiciona SF1, usar goto pois registro pode estar deletado
	SF1->(dbGoto((cAliasNF)->Z7_RECORI))
	If SF1->F1_FORMUL == "S"
		If !U_ZF08GENSAP(SF1->F1_ESPECIE,SF1->F1_CHVNFE,SF1->F1_FIMP,SF1->F1_DOC,SF1->F1_SERIE)
			(cAliasNF)->(dbSkip())
			LOOP
		Endif
	Endif
Endif

// para inclusao no sap eh obrigatorio que esteja contabilizado, para exclusao nao precisa desta verificacao, pois se presume que a contabilizacao jah tenha sido excluida
If (cAliasNF)->Z7_XOPESAP == 1 .and. Empty(IIf(!lDev,SF2->F2_DTLANC,SF1->F1_DTLANC))
	(cAliasNF)->(dbSkip())
	Help("",1,"Envio movimento SAP",,"Nota Fiscal não contabilizada.",1,0)
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

Conout(" [SAP] [ZSAPF012] * * * * * Status da integracao * * * * *"									)
Conout(" [SAP] [ZSAPF012] Inicio.......................: " + cTimeIni + " - " + dToC( dDataBase ) 	)
Conout(" [SAP] [ZSAPF012] Fim..........................: " + cTimeFin + " - " + dToC( dDataBase ) 	)
Conout(" [SAP] [ZSAPF012] Tempo de Processamento.......: " + cTimeProc 								)
Conout(" [SAP] [ZSAPF012] URL..........................: " + cUrl									)
Conout(" [SAP] [ZSAPF012] HTTP Method..................: " + "GET" 									)
Conout(" [SAP] [ZSAPF012] Status Http (200 a 299 ok)...: " + allTrim( str( nStatuHttp ) ) 			)
Conout(" [SAP] [ZSAPF012] Retorno......................: " + allTrim( xPostRet ) 					)
Conout(" [SAP] [ZSAPF012] * * * * * * * * * * * * * * * * * * * * "									)

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

		If !lDev
			// verifica se gerou financeiro
			SE1->(dbSetOrder(2))
			If !Empty(SF2->F2_DUPL)
				If SE1->(dbSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DUPL))
					While SE1->(!Eof()) .and. xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DUPL == ;
							SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
						//If SE1->E1_TIPO == MVNOTAFIS
						If Alltrim(SE1->E1_TIPO) $ cTiposFin
							lContinua := .T.
							If Empty(nRegSE1)
								nRegSE1 := SE1->(Recno())
							Endif
							nTit++
						Endif
						SE1->(dbSkip())
					Enddo
					// reposiciona no 1 registro novamente
					SE1->(dbGoto(nRegSE1))

					// verifica retencao
					While SE1->(!Eof()) .and. xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DUPL == ;
							SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
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
			Endif

			If !lContinua
				(cAliasNF)->(dbSkip())
				Loop
			Endif

			// posiciona cliente
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))

			// verifica se cliente jah foi enviado ao sap
			If Empty(SA1->A1_XCDSAP)
				U_ZF12GENSAP(	(cAliasNF)->Z7_FILIAL		,;	// Filial
				(cAliasNF)->Z7_XTABELA		,;	// Tabela
				(cAliasNF)->Z7_XCHAVE		,;	// Chave
				(cAliasNF)->Z7_XSEQUEN		,;	// Sequencia
				"E"				,;	// Status
				"Cliente sem código SAP gravado."+CRLF	,;	// Retorno
				""		)	// XML Envio
				(cAliasNF)->(dbSkip())
				Help("",1,"Envio movimento SAP",,"Cliente sem código SAP gravado.",1,0)
				Loop
			Endif

			// posiciona vendedor
			If !Empty(SF2->F2_VEND1)
				SA3->(dbSetOrder(1))
				SA3->(dbSeek(xFilial("SA3")+SF2->F2_VEND1))
			Endif

			// posiciona itens da nota
			SD2->(dbSetOrder(3))
			If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
				While SD2->(!Eof()) .and. xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
					cSD2 := cSD2+Alltrim(Str(SD2->(Recno())))+"/"
					SD2->(dbSkip())
				Enddo
				cSD2 := Subs(cSD2,1,Len(cSD2)-1)
				// reposiciona no 1 registro
				SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
				// posiciona pedido
				SC6->(dbSetOrder(1))
				SC6->(xFilial("SC6")+SD2->D2_PEDIDO)
			Endif
		Else
			// verifica se gerou financeiro
			SE1->(dbSetOrder(2))
			If !Empty(SF1->F1_DUPL)
				If SE1->(dbSeek(xFilial("SE1")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DUPL))
					While SE1->(!Eof()) .and. xFilial("SE1")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DUPL == ;
							SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
						If SE1->E1_TIPO == "NCC" //MV_CRNEG
							lContinua := .T.
							If Empty(nRegSE1)
								nRegSE1 := SE1->(Recno())
							Endif
							nTit++
						Endif
						SE1->(dbSkip())
					Enddo
					// reposiciona no 1 registro novamente
					SE1->(dbGoto(nRegSE1))

					// verifica retencao
					While SE1->(!Eof()) .and. xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DUPL == ;
							SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
						If !Empty(SE1->E1_IRRF)
							nTitWT++
						Endif
						If !Empty(SE1->E1_ISS)
							nTitWT++
						Endif
						If !Empty(SE1->E1_INSS)
							nTitWT++
						Endif
						If !Empty(SE1->E1_PIS)
							nTitWT++
						Endif
						If !Empty(SE1->E1_COFINS)
							nTitWT++
						Endif
						If !Empty(SE1->E1_CSLL)
							nTitWT++
						Endif
						SE1->(dbSkip())
					Enddo
					// reposiciona no 1 registro novamente
					SE1->(dbGoto(nRegSE1))
				Endif
			Endif

			If !lContinua
				(cAliasNF)->(dbSkip())
				Loop
			Endif

			// posiciona cliente
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))

			// verifica se cliente jah foi enviado ao sap
			If Empty(SA1->A1_XCDSAP)
				U_ZF12GENSAP(	(cAliasNF)->Z7_FILIAL		,;	// Filial
				(cAliasNF)->Z7_XTABELA		,;	// Tabela
				(cAliasNF)->Z7_XCHAVE		,;	// Chave
				(cAliasNF)->Z7_XSEQUEN		,;	// Sequencia
				"E"				,;	// Status
				"Cliente sem código SAP gravado."+CRLF	,;	// Retorno
				""		)	// XML Envio
				(cAliasNF)->(dbSkip())
				Help("",1,"Envio movimento SAP",,"Cliente sem código SAP gravado.",1,0)
				Loop
			Endif

			// posiciona itens da nota
			SD1->(dbSetOrder(1))
			If SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
				While SD1->(!Eof()) .and. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == ;
						SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
					cSD1 := cSD1+Alltrim(Str(SD1->(Recno())))+"/"
					SD1->(dbSkip())
				Enddo
				cSD1 := Subs(cSD1,1,Len(cSD1)-1)
				// reposiciona no 1 registro
				SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

				// posiciona sd2 e sf2 de origem, pois algumas tags precisam de informacoes destes campos
				SD2->(dbSetOrder(3))
				SD2->(dbSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD+SD1->D1_ITEMORI))
				If Empty(SD1->D1_NFORI) .or. SD2->(!Found())
					Help("",1,"Envio movimento SAP",,"Não foi localizada a nota de saída de origem. Série: "+Alltrim(SD1->D1_SERIORI)+", Documento: "+Alltrim(SD1->D1_NFORI)+" .",1,0)
					(cAliasNF)->(dbSkip())
					Loop
				Else
					SF2->(dbSetOrder(1))
					SF2->(dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_FORMUL+SD2->D2_TIPO))
					If SF2->(!Found())
						Help("",1,"Envio movimento SAP",,"Não foi localizada a nota de saída de origem. Série: "+Alltrim(SD1->D1_SERIORI)+", Documento: "+Alltrim(SD1->D1_NFORI)+" .",1,0)
						(cAliasNF)->(dbSkip())
						Loop
					Endif
				Endif
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
			cQ += " CV3.CV3_RECORI IN "+FormatIn(cSD2,"/")+" "
			cQ += " AND CV3.CV3_TABORI = 'SD2' "
			cQ += " AND CT2.CT2_TPSALD = '1' "
			cQ += " AND CT2_LP = '610' "
		Else
			cQ += " CV3.CV3_RECORI IN "+FormatIn(cSD1,"/")+" "
			cQ += " AND CV3.CV3_TABORI = 'SD1' "
			cQ += " AND CT2.CT2_TPSALD = '1' "
			cQ += " AND CT2_LP = '650' "
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
			cQ += " CV3.CV3_RECORI IN "+FormatIn(cSD2,"/")+" "
			cQ += " AND CV3.CV3_TABORI = 'SD2' "
			cQ += " AND CT2.CT2_TPSALD = '1' "
			cQ += " AND CT2_LP = '610' "
		Else
			cQ += " CV3.CV3_RECORI IN "+FormatIn(cSD1,"/")+" "
			cQ += " AND CV3.CV3_TABORI = 'SD1' "
			cQ += " AND CT2.CT2_TPSALD = '1' "
			cQ += " AND CT2_LP = '650' "
		Endif
		cQ += " AND CT2_SEQUEN = '"+cSeq+"' "
		cQ += " AND SUBSTR(CT2_ORIGEM,1,7) NOT IN "+FormatIn(cOrigRet,"/")+" "
		cQ += " ORDER BY CT2_LINHA "
		//Fim query

		cAliasCtb := GetNextAlias()
		cQ := ChangeQuery(cQ)

		memoWrite( "C:\TEMP\ZSAPF012.TXT",cQ )

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQ), cAliasCtb, .F., .T.)

		// se nao achar contabilizacao, nao prossegue
		If (cAliasCtb)->(Eof())
			(cAliasCtb)->(dbCloseArea())
			//U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","Não encontrado contabilização com saldo tipo 1 ( Real ), para este documento."+CRLF)
			(cAliasNF)->(dbSkip())
			Help("",1,"Envio movimento SAP",,"Movimento contabilizado com inconsistência.",1,0)
			LOOP
		EndIf

		nOcorGL := 0
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
		//cXDiv := Right( AllTrim(xEncCGC(SE1->E1_FILIAL)), 4 )

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
			xRet := oWsdl:SetValue( aSimple[nPos][1], cxEmp )	//empresa
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
			xRet := oWsdl:SetValue( aSimple[nPos][1], cXFil )	//filial do parametro
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
				If lDev
					//cNumAtrib := SD1->D1_PEDIDO
					If SF2->F2_PREFORI $ cPrefVei
						cNumAtrib := NumAtribVei(SF2->(Recno()),"0")
					Else
						cNumAtrib := SD2->D2_PEDIDO
					Endif
				Elseif SF2->F2_PREFORI $ cPrefVei
					cNumAtrib := NumAtribVei(SF2->(Recno()),"0")
				Else
					cNumAtrib := SD2->D2_PEDIDO
				Endif
				//Caso não tenha localizado o numero do pedido assumir o numero da nota
				//DAC 01/06/2020 chamado 406846 CAOA
				If Empty(cNumAtrib)
					cNumAtrib := SF2->F2_DOC
				Endif

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

		//while !(cAliasTit)->(eof())
		cChaveTit := IIf(!lDev,xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DUPL,xFilial("SE1")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DUPL)
		While SE1->(!Eof()) .and. cChaveTit == SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
			If !lContinua
				Exit
			Endif

			//If !SE1->E1_TIPO == IIf(!lDev,MVNOTAFIS,"NCC")
			If !Alltrim(SE1->E1_TIPO) $ IIf(!lDev,cTiposFin,"NCC")
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

			If ( SE1->E1_CLIENTE == "000387" .And. SE1->E1_LOJA == "02" ) .And. AllTrim(SE1->E1_TIPO) == "NF"
				xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR(IIf(lInvSinal,SE1->E1_VALOR - (SE1->E1_PIS + SE1->E1_COFINS) * -1, SE1->E1_VALOR - (SE1->E1_PIS + SE1->E1_COFINS))))) //###LINHA ORIGINAL
			Else
				xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR(IIf(lInvSinal,SE1->E1_VALOR * -1,SE1->E1_VALOR)))) //###LINHA ORIGINAL
			EndIf

			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","montanteMoedaPagamento Erro: " + oWsdl:cError)
				lContinua := .F.
				SE1->(dbSkip())
				Loop
			EndIf
			//ENDIF

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

			If SF2->F2_PREFORI $ cPrefVei
				cCondPag := NumAtribVei(SF2->(Recno()),"1")
			Endif

			If Empty(cCondPag)
				cCondPag := SF2->F2_COND
			Endif

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
		enddo
		//------------------------------------------------------------------AccountWT
			/*
			// reposiciona no 1 registro novamente
			SE1->(dbSetOrder(2))
			SE1->(dbGoto(nRegSE1))
			While SE1->(!Eof()) .and. cChaveTit == SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
				If !lContinua
					Exit
				Endif
				
				//If !SE1->E1_TIPO == IIf(!lDev,MVNOTAFIS,"NCC")
				If !Alltrim(SE1->E1_TIPO) $ IIf(!lDev,cTiposFin,"NCC")
					SE1->(dbSkip())
					Loop
				Endif	
				
				//IF SE1->E1_IRRF==0 .and. SE1->E1_ISS==0 .and. SE1->E1_INSS==0 .and. SE1->E1_PIS==0 .and. ;
				//	SE1->E1_COFINS==0 .and. SE1->E1_CSLL==0 .and. lContinua
				IF !Empty(SE1->E1_IRRF) .and. lContinua

					nNumAux++

					nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroItemDocumentoContabilidade" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountWT#1" } )//numeroItemDocumentoContabilidade
					xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR(nNumAux)))
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","numeroItemDocumentoContabilidade Erro: " + oWsdl:cError)
						lContinua := .F.
						SE1->(dbSkip())
						Loop
					EndIf
					
					nPos := aScan( aSimple, {|aVet| aVet[2] == "CodCategoriaImpostoRF"} )//CodCategoriaImpostoRF
					xRet := oWsdl:SetValue( aSimple[nPos][1], SED->ED_XCATIM)
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","CodCategoriaImpostoRF Erro: " + oWsdl:cError)
						lContinua := .F.
						SE1->(dbSkip())
						Loop
					EndIf
					
					nPos := aScan( aSimple, {|aVet| aVet[2] == "CodImpostoRF"} )//CodImpostoRF
					xRet := oWsdl:SetValue( aSimple[nPos][1],SED->ED_XCODIM)
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","CodImpostoRF Erro: " + oWsdl:cError)
						lContinua := .F.
						SE1->(dbSkip())
						Loop
					EndIf
					
					nPos := aScan( aSimple, {|aVet| aVet[2] == "MontanteBaseIRF"} )//MontanteBaseIRF
					xRet := oWsdl:SetValue( aSimple[nPos][1],alltrim(str(SE1->E1_BASEIRF)))
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","MontanteBaseIRF Erro: " + oWsdl:cError)
						lContinua := .F.
						SE1->(dbSkip())
						Loop
					EndIf
					
					nPos := aScan( aSimple, {|aVet| aVet[2] == "MontanteIRFManualmente"} )//MontanteIRFManualmente
					xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(Str(SE1->E1_IRRF)))
					If !xRet
						U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","MontanteIRFManualmente Erro: " + oWsdl:cError)
						lContinua := .F.
						SE1->(dbSkip())
						Loop
					EndIf
				endif
				SE1->(dbSkip())
			Enddo
			*/
		//--------------------------------------------------------Fim Campos
		If lContinua
			oWsdl:lRemEmptyTags := .T. // remove tags vazias

			//Tratamento do XML de Envio
			cMsgSoap := oWsdl:GetSoapMsg()
			cMsgSoap	:= fwNoAccent( cMsgSoap )
			cMsgSoap	:= encodeUtf8( cMsgSoap )
		Endif
	EndIf
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
user function xZSAPF12(xParam1,xParam2,xParam3)

	U_ZSAPF012({{xParam1,xParam2,Val(xParam3)}})

Return()


/*-------------------------------------------------------------------------------------
{Protheus.doc} NumAtribVeil 
Rdmake 	responsavel pela inclusão/visualização de historicos
@class    	Nao Informado
@from       Nao Informado
@param      nRecSF2=Reg SF2,cTipo =0-Pedido/1-Condição
@attrib    	Nao Informado
@protected  Nao Informado
@author     Glesele 
@single		Nao Informado
@version    Nao Informado
@since      Nao Informado  
@return    	cRet
@sample     Nao Informado
@obs        Chamado pelo Ponto de Entrada MT120OK,MT11TOK e via menu
@project    CAOA
@menu       Nao Informado
@table 		VRJ = Pedido Venda Veic. Montadora  	
			VRK = Itens Ped. Venda Veíc. Montad.
			VV0 = Saídas de Veículos            
@history  	Alterado DAC-Denilso 01/06/2020 Chamado CAOA 406846 - Ajustado retorno quando nao localizar Pedido  
--------------------------------------------------------------------------------------*/
Static Function NumAtribVei(nRecSF2,cTipo)
Local aArea 		:= {GetArea()}
Local cRet 			:= ""
Local cNextAlias 	:= GetNextAlias()
Local cFilSF2 		:= xFilial("SF2")
Local cNextAlia1 	:= GetNextAlias()

BeginSql Alias cNextAlias
	SELECT VRK_PEDIDO
	FROM %Table:VRK% VRK, %Table:VV0% VV0, %Table:SF2% SF2
	WHERE
	VRK.%NotDel%
	AND VV0.%NotDel%
	AND SF2.%NotDel%
	AND F2_FILIAL = %Exp:cFilSF2%
	AND F2_FILIAL = VRK_FILIAL
	AND F2_FILIAL = VV0_FILIAL
	AND F2_DOC = VV0_NUMNFI
	AND VV0_NUMTRA = VRK_NUMTRA
	AND SF2.R_E_C_N_O_ = %Exp:nRecSF2%
EndSql

IF VRJ->(dbSeek(cFilSF2+(cNextAlias)->VRK_PEDIDO))
  	IF VRJ->VRJ_TIPVEN <> '01'
	  	If cTipo == "0"
			cRet := (cNextAlias)->VRK_PEDIDO
		Endif	
	Else	      
		BeginSql Alias cNextAlia1
			SELECT VV0_NUMTRA
			FROM %Table:VV0% VV0, %Table:SF2% SF2
			WHERE
			VV0.%NotDel%
			AND SF2.%NotDel%
			AND F2_FILIAL = %Exp:cFilSF2%
			AND F2_FILIAL = VV0_FILIAL
			AND F2_DOC = VV0_NUMNFI
			AND SF2.R_E_C_N_O_ = %Exp:nRecSF2%
		EndSql
		
		While (cNextAlia1)->(!Eof())
			//cRet := (cNextAlia1)->VRK_PEDIDO
			If cTipo == "0"
				cRet := (cNextAlia1)->VV0_NUMTRA
			Endif	
			Exit
		EndDo
		(cNextAlia1)->(DbClosearea())
	EndIF
	If cTipo == "1"
		cRet := VRJ->VRJ_FORPAG
	Endif	
EndIF

(cNextAlias)->(DbClosearea())

aEval(aArea,{ |x| RestArea(x)})

Return(cRet)
