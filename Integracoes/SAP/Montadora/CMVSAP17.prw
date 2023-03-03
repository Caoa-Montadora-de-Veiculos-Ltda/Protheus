#include "topconn.ch"
#include "tbiconn.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#include "protheus.ch"

/*
Integracao de Contas a Receber com SAP - titulos a receber provisorios 
*/
user function CMVSAP17( aParam )

local oWsdl
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
Local nNumAux := 0
Local lContinua := .T.
Local nRegSE1 := 0
Local cQ := ""
Local cFilAntSav := ""
Local cChaveTit := ""
Local lInvSinal := .F.
Local nDiasErro := 0
Local nTit := 0
Local cDoc := ""
Local nRecEnvio := 0
Local nDiasAguar := 0
Local cPrefVei := ""
Local cFormaBol := ""
Local nPos := 0
Local xRet := Nil

Local nRecRep := 0
Local cEmpJob := ""
Local cFiJob := ""

private lIsBlind := IsBlind() .OR. Type("__LocalDriver") == "U"

If !Empty(aParam)
	If ValType(aParam[1][1]) == "C"
		cEmpJob := aParam[1][1]
	Endif	
	If ValType(aParam[1][2]) == "C"
		cFiJob := aParam[1][2]
	Endif
	If ValType(aParam[1][3] ) == "N"
		nRecRep := aParam[1][3]
	Endif
Endif		 

IF lIsBlind
	RpcSetType(3)
	RpcSetEnv( cEmpJob , cFiJob )
	
	If !LockByName("CMVSAP17")
		Alert("JOB já em Execução : CMVSAP17 " + DTOC(dDATABASE) + " - " + TIME() )
		RpcClearEnv()
		Return
	Else
		Conout("Conexão realizada com sucesso : CMVSAP17 " + DTOC(dDATABASE) + " - " + TIME() )
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
cPrefVei 	:= superGetMv( "CAOASAP17A"	, , "OFI/VEI" )  // prefixos de titulos originados no sigavei
cFormaBol 	:= superGetMv( "CAOASAP17B"	, , "BOL/" )  // formas de recebimento por boleto

If Select("cAliasNF")   > 0
	(cAliasNF)->(DBCLOSEAREA())
endif

cQ := "SELECT SZ7.*,SZ7.R_E_C_N_O_ SZ7_RECNO "
cQ += "FROM "+RetSqlName("SZ7")+" SZ7 "
//cQ += "WHERE (Z7_XSTATUS = 'P' OR (Z7_XSTATUS = 'E' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasErro)+"') OR (Z7_XSTATUS = 'A' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasAguar)+"' AND Z7_XDTINC < '"+dTos(dDataBase-1)+"')) "
cQ += "WHERE (Z7_XSTATUS = 'P' OR (Z7_XSTATUS = 'E' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasErro)+"')) "
//cQ += "WHERE Z7_XSTATUS = 'P' "
cQ += "AND Z7_XTABELA = 'SE1' "
//cQ += " AND Z7_XLOTE = '0000240802' "
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
	nNumAux := 0
	lContinua := .T.
	nRegSE1 := 0
	oWsdl := Nil
	lInvSinal := .F.
	nTit := 0
	cChaveTit := ""
	cDoc := ""
	nRecEnvio := 0
	
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

	If (cAliasNF)->Z7_XOPESAP == 1 .and. (cAliasNF)->Z7_XOPEPRO == 1 // envio da inclusao
		nRecEnvio := (cAliasNF)->SZ7_RECNO
	ElseIf (cAliasNF)->Z7_XOPESAP == 1 .and. (cAliasNF)->Z7_XOPEPRO == 2 // envio da alteracao 	 
		nRecEnvio := RecEnvioSZ7((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE)
	Endif	

	If (cAliasNF)->Z7_XOPESAP <> 2
		If Empty(nRecEnvio)
			U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","Não encontrado o Recno de envio da SZ7")
			(cAliasNF)->(dbSkip())
			Loop
		Endif
	Endif		
	
	// posiciona SE1, usar goto pois registro pode estar deletado
	SE1->(dbGoto((cAliasNF)->Z7_RECORI))

	// titulos do sigavei com forma de pagamento boleto, devem ter os campos de banco informados	
	// verificar todas as parcelas, pois se tiver alguma parcela que nao atende a condicao, o arquivo nao deve ser gerado
	If (cAliasNF)->Z7_XOPESAP == 1 .and. Alltrim(SE1->E1_PREFORI) $ cPrefVei
		cChaveTit := SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
		While SE1->(!Eof()) .and. cChaveTit == SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
			If SE1->E1_TIPO $ MVPROVIS .and. Alltrim(SE1->E1_XFORMA) $ cFormaBol
				If Empty(SE1->E1_PORTADO) .or. Empty(SE1->E1_NUMBCO)
					lContinua := .F.
					Exit
				Endif	
			Endif
			SE1->(dbSkip())
		Enddo	
		If !lContinua
			(cAliasNF)->(dbSkip())
			Loop
		Endif	
		SE1->(dbGoto((cAliasNF)->Z7_RECORI))
	Endif	

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
	
	Conout(" [SAP] [CMVSAP17] * * * * * Status da integracao * * * * *"									)
	Conout(" [SAP] [CMVSAP17] Inicio.......................: " + cTimeIni + " - " + dToC( dDataBase ) 	)
	Conout(" [SAP] [CMVSAP17] Fim..........................: " + cTimeFin + " - " + dToC( dDataBase ) 	)
	Conout(" [SAP] [CMVSAP17] Tempo de Processamento.......: " + cTimeProc 								)
	Conout(" [SAP] [CMVSAP17] URL..........................: " + cUrl									)
	Conout(" [SAP] [CMVSAP17] HTTP Method..................: " + "GET" 									)
	Conout(" [SAP] [CMVSAP17] Status Http (200 a 299 ok)...: " + allTrim( str( nStatuHttp ) ) 			)
	Conout(" [SAP] [CMVSAP17] Retorno......................: " + allTrim( xPostRet ) 					)
	Conout(" [SAP] [CMVSAP17] * * * * * * * * * * * * * * * * * * * * "									)
	
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
		
		// Define a operação
		xRet := oWsdl:SetOperation( aOps[3][1] )
		If !xRet
			Conout("SetOperation ERROR: "  + oWsdl:cError)
			return
		EndIf
		
		If (cAliasNF)->Z7_XOPESAP <> 2
			cChaveTit := SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM

			While SE1->(!Eof()) .and. cChaveTit == SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
				If SE1->E1_TIPO $ MVPROVIS .and. Alltrim(SE1->E1_PREFORI) $ cPrefVei 
					If Empty(nRegSE1)
						nRegSE1 := SE1->(Recno())
					Endif
					nTit++
				Endif
				SE1->(dbSkip())
			Enddo

			// reposiciona no 1 registro novamente
			SE1->(dbGoto(nRegSE1))

			// posiciona cliente
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))

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
			
			// posiciona natureza
			SED->(dbSetOrder(1))
			SED->(dbSeek(xFilial("SED")+SE1->E1_NATUREZ))
			
			aComplex := oWsdl:NextComplex()
			while ValType( aComplex ) == "A"
				//varinfo( "aComplex", aComplex )
				
				If aComplex[2] == "documentos"
					nOccurs := 1
				ElseIf aComplex[2] == "DocumentHeader"
					nOccurs := 1
				ElseIf aComplex[2] == "AccountGL"
						nOccurs := 0
				elseIf aComplex[2] == "AccountReceivable"
					nOccurs := nTit
				elseIf aComplex[2] == "AccountWT"
					nOccurs := 0
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
			cDoc := "1"
				
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
			xRet := oWsdl:SetValue( aSimple[nPos][1],SED->ED_XTIPO) 	//tipoDocumento
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
			xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(SE1->E1_NUM)+IIf(!Empty(SE1->E1_PREFIXO),"/"+Alltrim(SE1->E1_PREFIXO),""))	//numeroDocumentoReferencia ???
			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","numeroDocumentoReferencia Erro: " + oWsdl:cError)
				lContinua := .F.
				(cAliasNF)->(dbSkip())
				Loop
			EndIf
				
			nPos := aScan( aSimple, {|aVet| aVet[2] == "chaveCabecalho1" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".DocumentHeader#1" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(SE1->E1_NUM))	//chaveCabecalho1
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
			xRet := oWsdl:SetValue( aSimple[nPos][1]," ")	//textoCabecalhoDocumento - Nome do usuário que efetuou o lançamento
			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","textoCabecalhoDocumento Erro: " + oWsdl:cError)
				lContinua := .F.
				(cAliasNF)->(dbSkip())
				Loop
			EndIf
				
			nPos := aScan( aSimple, {|aVet| aVet[2] == "motivoOperacao" .and. aVet[5] == "ContasAReceberRequest#1.documentos#"+cDoc+".DocumentHeader#1" } )//"1" - Lançamento / "2" Estorno/Cancelamento
			If (cAliasNF)->Z7_XOPEPRO == 1 .and. (cAliasNF)->Z7_XOPESAP == 1
				xRet := oWsdl:SetValue( aSimple[nPos][1], "1" )
			Endif	

			If (cAliasNF)->Z7_XOPEPRO == 2 .and. (cAliasNF)->Z7_XOPESAP == 1
				xRet := oWsdl:SetValue( aSimple[nPos][1], "4" )
			Endif	
			If !xRet
				U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","motivoOperacao Erro: " + oWsdl:cError)
				lContinua := .F.
				(cAliasNF)->(dbSkip())
				Loop
			EndIf

			//----------------------------------AccountReceivable
			//(cAliasTit)->(dbgotop())
			nz:=1
			// reposiciona no 1 registro novamente
			SE1->(dbSetOrder(2))
			SE1->(dbGoto(nRegSE1))
			nNumAux := nNum
			
			While SE1->(!Eof()) .and. cChaveTit == SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
				If !lContinua
					Exit
				Endif
				
				If !(SE1->E1_TIPO $ MVPROVIS .and. Alltrim(SE1->E1_PREFORI) $ cPrefVei)
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
				xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(SA1->A1_CGC))	//
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","numeroCliente Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "chaveReferenciaParceiroNegocios1" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )//chaveReferenciaParceiroNegocios1
				xRet := oWsdl:SetValue( aSimple[nPos][1], "0")//???????????????????????
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
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "dataBaseParaCalculoVencimento" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
				xRet := oWsdl:SetValue( aSimple[nPos][1], xDtSap(dTos(SE1->E1_EMISSAO)))
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","dataBaseParaCalculoVencimento Erro: " + oWsdl:cError)
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
				xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(SE1->E1_NUM)+IIf(!Empty(SE1->E1_PARCELA),"/"+Alltrim(U_ZF03GENSAP(SE1->E1_PARCELA)),""))
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","NumeroAtribuicao Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "textoDoItem" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
				xRet := oWsdl:SetValue( aSimple[nPos][1], " ")
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","textoDoItem Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "montanteMoedaPagamento" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
				xRet := oWsdl:SetValue( aSimple[nPos][1], ALLTRIM(STR(SE1->E1_VALOR)))
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
				xRet := oWsdl:SetValue( aSimple[nPos][1], "F")
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","chaveBreveUmBancoDaEmpresa Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "centroLucro" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
				xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(SE1->E1_CLVL))
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
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "codigoBancoCentral" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
				xRet := oWsdl:SetValue( aSimple[nPos][1], SE1->E1_XFORMA)
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","codigoBancoCentral Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
				
				nPos := aScan( aSimple, {|aVet| aVet[2] == "idExterno" .and. aVet[5] == "ContasAReceberRequest#1.documentos#1.AccountReceivable#" + Alltrim(Str(nz))} )
				//xRet := oWsdl:SetValue( aSimple[nPos][1], "T"+allTrim(str((cAliasNF)->SZ7_RECNO))+IIf(!Empty(SE1->E1_PARCELA),"P"+Alltrim(StrZero(Val(SE1->E1_PARCELA),TamSX3("E1_PARCELA")[1])),"")) // mandar a parcela, pois se1 poderah ter mais de uma parcela e este campo nao pode se repetir
				xRet := oWsdl:SetValue( aSimple[nPos][1], "T"+allTrim(str(nRecEnvio))+IIf(!Empty(SE1->E1_PARCELA),"P"+Alltrim(StrZero(Val(SE1->E1_PARCELA),TamSX3("E1_PARCELA")[1])),"")) // mandar a parcela, pois se1 poderah ter mais de uma parcela e este campo nao pode se repetir
				If !xRet
					U_ZF12GENSAP((cAliasNF)->Z7_FILIAL,(cAliasNF)->Z7_XTABELA,(cAliasNF)->Z7_XCHAVE,(cAliasNF)->Z7_XSEQUEN,"E","idExterno Erro: " + oWsdl:cError)
					lContinua := .F.
					SE1->(dbSkip())
					Loop
				EndIf
					
				SE1->(dbSkip())
				nz++
			enddo

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
If Select("cAliasNF")   > 0
	(cAliasNF)->(DbCloseArea())
ENDIF

cFilAnt := cFilAntSav

IF lIsBlind
	Conout("Conexão Finalizada com sucesso : CMVSAP17 " + DTOC(dDATABASE) + " - " + TIME() )
	RpcClearEnv()
Endif	

return


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
user function xCMVSA17(xParam1,xParam2,xParam3)

U_CMVSAP17({{xParam1,xParam2,Val(xParam3)}})

Return()


Static Function RecEnvioSZ7(cFil,cTab,cChave)

Local aArea := {GetArea()}
Local cAliasTrb := GetNextAlias()
Local cQ := ""
Local nRet := 0

cQ := "SELECT MAX(SZ7.R_E_C_N_O_) SZ7_RECNO "
cQ += "FROM "+retSQLName("SZ7")+" SZ7 "
cQ += "WHERE "
cQ += "Z7_FILIAL = '"+cFil+"' "
cQ += "AND Z7_XTABELA = '"+cTab+"' "
cQ += "AND Z7_XCHAVE = '"+cChave+"' "
cQ += "AND Z7_XSTATUS IN ('A','O') "
cQ += "AND SZ7.D_E_L_E_T_ = ' ' "
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
	
If (cAliasTrb)->(!Eof()) .and. !Empty((cAliasTrb)->SZ7_RECNO)
 	nRet := (cAliasTrb)->SZ7_RECNO
Endif	

(cAliasTrb)->(dbCloseArea())

aEval(aArea,{|x| RestArea(x)})
	
Return(nRet)
