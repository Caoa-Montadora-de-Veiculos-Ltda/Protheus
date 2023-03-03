#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "xmlxfun.ch"

/*
Integracao de Clientes com SAP
*/
user function CMVSAP02( aParam )
	local oWsdl
	local cQry 		    := ""
	local cAliasQry     := ""
	local aOps			:= {}
	local cUser			:= ""//allTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
	local cPass			:= ""//allTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP
	local cURLProxy		:= ""//allTrim( superGetMv( "CAOAPROXY"	, , "proxy.caoa.local"		) )	// Usuario Proxy da Rede Caoa
	local nPortProxy	:= ""//superGetMv( "CAOAPORT"	, , 8080 )								// Porta Proxy da Rede Caoa
	local cUserProxy	:= ""//allTrim( superGetMv( "CAOAPROUSE"	, , "T-RODRIGO.SALOMAO"	) )	// Usuario do Proxy
	local cPassProxy	:= ""//allTrim( superGetMv( "CAOAPROPAS"	, , "caoa2019**"		) )	// Senha do Proxy
	//local cUrl		:= allTrim( superGetMv( "CAOASAP02A"	, , "http://srvtvt05caoa.caoa.com.br:51400/dir/wsdl?p=ic/97d120e0442d33278268b0eccac3643c") )
	local cUrl			:= ""//allTrim( superGetMv( "CAOASAP02A"	, , "http://10.120.40.140:51400/dir/wsdl?p=ic/97d120e0442d33278268b0eccac3643c") )
	local aHeadOut		:= {}
	local cHeadRet		:= ""
	local cAutorizat	:= ""
	local cTimeIni		:= ""
	local cTimeFin		:= ""
	local cTimeProc		:= ""
	local xPostRet		:= nil
	local nStatuHttp	:= 0
	local nTimeOut		:= 120
	Local nDiasErro 	:= 0
	Local nDiasAguar 	:= 0
	
	Local nRecRep := 0
	Local cEmpJob := ""
	Local cFilJob := ""

	Private lIsBlind := IsBlind() .OR. Type("__LocalDriver") == "U"

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

		If !LockByName("CMVSAP02")
			Conout("JOB já em Execução : CMVSAP02 " + DTOC(dDATABASE) + " - " + TIME() )
			RpcClearEnv()
			Return
		Else
			Conout("Conexão realizada com sucesso : CMVSAP02 " + DTOC(dDATABASE) + " - " + TIME() )
		EndIf
	EndIF

	cUser		:= allTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
	cPass		:= allTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP
	cURLProxy	:= allTrim( superGetMv( "CAOAPROXY"	, , "proxy.caoa.local"		) )	// Usuario Proxy da Rede Caoa
	nPortProxy	:= superGetMv( "CAOAPORT"	, , 8080 )								// Porta Proxy da Rede Caoa
	cUserProxy	:= allTrim( superGetMv( "CAOAPROUSE"	, , "T-RODRIGO.SALOMAO"	) )	// Usuario do Proxy
	cPassProxy	:= allTrim( superGetMv( "CAOAPROPAS"	, , "caoa2019**"		) )	// Senha do Proxy
	cUrl		:= allTrim( superGetMv( "CAOASAP02A"	, , "http://10.120.40.141:53400/dir/wsdl?p=ic/97d120e0442d33278268b0eccac3643c") )
	nDiasErro	:= superGetMv( "CAOASAP01C"	, , 3 )  // qtde de dias para reprocessar registros com status de erro
	nDiasAguar	:= superGetMv( "CAOASAP01D"	, , 3 )  // qtde de dias para reprocessar registros com status de aguardando
		
	/*
	cQry := " SELECT SA1.R_E_C_N_O_ SA1RECNO, A1_FILIAL  , A1_COD    , A1_LOJA   ," + CRLF
	cQry += "                  A1_CGC   	, A1_INSCR   , A1_NOME   , A1_TEL    ," + CRLF
	cQry += "                  A1_EMAIL 	, A1_END     , A1_COMPLEM, A1_BAIRRO ," + CRLF
	cQry += "                  A1_CEP   	, A1_MUN     , A1_EST    , A1_PAIS   ," + CRLF
	cQry += "                  A1_DTNASC	, A1_SUFRAMA , A1_CONTA  , A1_PESSOA ," + CRLF
	cQry += "                  A1_CODSEG	, YA_SIGLA" 							+ CRLF
	cQry += " FROM "		+ RetSqlName("SA1") + " SA1"							+ CRLF
	cQry += " LEFT JOIN "	+ retSQLName("SYA") + " SYA"							+ CRLF
	cQry += " ON"																	+ CRLF
	cQry += "		SYA.YA_CODGI	=	A1_PAIS"									+ CRLF
	cQry += " 	AND SYA.YA_FILIAL	=	'" + xFilial("SYA") + "'"					+ CRLF
	cQry += " 	AND SYA.D_E_L_E_T_	<>	'*'"										+ CRLF
	cQry += " WHERE"																+ CRLF
	cQry += "		SA1.A1_XFLGSAP  =	'P'"										+ CRLF
	cQry += "	AND	SA1.A1_MSBLQL   <>	'1'"										+ CRLF
	cQry += "	AND	SA1.D_E_L_E_T_  <>	'*'"										+ CRLF
	*/
	
	cQry := "SELECT SZ7.*,SZ7.R_E_C_N_O_ SZ7_RECNO "
	cQry += "FROM "+RetSqlName("SZ7")+" SZ7 "
	//cQry += "WHERE (Z7_XSTATUS = 'P' OR (Z7_XSTATUS = 'E' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasErro)+"') OR (Z7_XSTATUS = 'A' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasAguar)+"' AND Z7_XDTINC < '"+dTos(dDataBase-1)+"')) "
	cQry += "WHERE (Z7_XSTATUS = 'P' OR (Z7_XSTATUS = 'E' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasErro)+"')) "
	//cQry += "WHERE Z7_XSTATUS = 'P' "
	cQry += "AND Z7_XTABELA = 'SA1' "
	cQry += "AND D_E_L_E_T_ <> '*' "

	If nRecRep > 0
		cQry += " AND SZ7.R_E_C_N_O_ = " + AllTrim(Str(nRecRep))
	EndIf

	cAliasQry := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAliasQry, .F., .T.)

	While !(cAliasQry)->(Eof())
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

		conout(" [SAP] [CMVSAP02] * * * * * Status da integracao * * * * *")
		conout(" [SAP] [CMVSAP02] Inicio.......................: " + cTimeIni + " - " + dToC( dDataBase ) )
		conout(" [SAP] [CMVSAP02] Fim..........................: " + cTimeFin + " - " + dToC( dDataBase ) )
		conout(" [SAP] [CMVSAP02] Tempo de Processamento.......: " + cTimeProc )
		conout(" [SAP] [CMVSAP02] URL..........................: " + cUrl)
		conout(" [SAP] [CMVSAP02] HTTP Method..................: " + "GET" )
		conout(" [SAP] [CMVSAP02] Status Http (200 a 299 ok)...: " + allTrim( str( nStatuHttp ) ) )
		conout(" [SAP] [CMVSAP02] Retorno......................: " + allTrim( xPostRet ) )
		conout(" [SAP] [CMVSAP02] * * * * * * * * * * * * * * * * * * * * ")
		//alert(nStatuHttp)
		if nStatuHttp >= 200 .and. nStatuHttp <= 299
			memoWrite( "\" + funName() + ".wsdl", xPostRet )

			// Cria o objeto da classe TWsdlManager
			oWsdl := TWsdlManager():New()

			oWsdl:bNoCheckPeerCert := .T.

			oWsdl:lEnableOptAttr	:= .T.	// Habilita no comando SOAP de envio os atributos opcionais.
			oWsdl:lCheckInput		:= .F.	// Define se vai verificar as ocorrências dos parâmetros de entrada da mensagem SOAP que será enviada, quando essa não for uma mensagem personalizada.
			oWsdl:lUseNSPrefix		:= .T.	// Define se vai usar prefixo de namespace antes dos nomes das tags na mensagem SOAP que será enviada.

			// Utilizar SetProxy / SetCredentials dentro da rede Caoa
			/*oWsdl:SetProxy( cURLProxy, nPortProxy )
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
			endif*/

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
			xRet := oWsdl:SetOperation( aOps[3][1] ) // "CriaCliente"
			If !xRet 
				conout( "Erro: " + oWsdl:cError )
				Return
			EndIf

			//			oWsdl:cLocation := cURL

			aComplex := oWsdl:NextComplex()
			while ValType( aComplex ) == "A"
				//varinfo( "aComplex", aComplex )

				nOccurs := 1

				xRet := oWsdl:SetComplexOccurs( aComplex[1], nOccurs )
				If xRet == .F.
					conout( "Erro ao definir elemento " + aComplex[2] + ", ID " + cValToChar( aComplex[1] ) + ", com " + cValToChar( nOccurs ) + " ocorrencias" )
					Return
				EndIf

				aComplex := oWsdl:NextComplex()
			EndDo

			aSimple := oWsdl:SimpleInput()
			//varinfo( "", aSimple )

			// posiciona cliente
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+Alltrim((cAliasQry)->Z7_XCHAVE)))
				If SA1->A1_MSBLQL == "1"
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Atenção, Cliente não esta bloqueado, código: " + alltrim((cAliasQry)->Z7_XCHAVE))
					(cAliasQry)->(dbSkip())
					LOOP
				Endif
			Else
				//U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Atenção, Cliente não encontrado, código: " + alltrim((cAliasQry)->Z7_XCHAVE))
				U_ZF19GENSAP((cAliasQry)->Z7_XCHAVE,"N","Cliente excluído: " + alltrim((cAliasQry)->Z7_XCHAVE),"SA1")
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf
			
			SYA->(dbSetOrder(1))
			SYA->(dbSeek(xFilial("SYA")+SA1->A1_PAIS))
			
			// Define o valor de cada parâmeto necessário
			nPos := aScan( aSimple, {|aVet| aVet[2] == "sistema" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], "TOTVS" )	//sistema
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/	
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "data" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], left( fwTimeStamp( 5 ) , 10 ) )	//data
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/	
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "hora" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], Time() )	//hora
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "idLote" } )
			//xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA1->A1_COD + SA1->A1_LOJA))	//idLote
			xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(Str(Val((cAliasQry)->Z7_XLOTE))))	//idLote
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			// TAG grupoDeClientes AGUARDANDO DEFINICAO
			nPos := aScan( aSimple, {|aVet| aVet[2] == "grupoDeClientes" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim( SA1->A1_CODSEG ))	//grupoDeClientes
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "codigoClienteParceiro" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA1->A1_COD + SA1->A1_LOJA))	//codigoClienteParceiro
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf			

			nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroAntigoConta" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], " ")	//numeroAntigoConta
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "grupoContasCliente" } )

			if SA1->A1_PESSOA == "F"
				xRet := oWsdl:SetValue( aSimple[nPos][1], "ZCPF")	//grupoContasCliente
			else
				xRet := oWsdl:SetValue( aSimple[nPos][1], "ZCPJ")	//grupoContasCliente
			endif

			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "CNPJ" } )
			if SA1->A1_PESSOA == "J"
				xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(SA1->A1_CGC ))
			else
				xRet := oWsdl:SetValue( aSimple[nPos][1], " " )
			endif
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "CPF" } )
			if SA1->A1_PESSOA == "F"
				xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(SA1->A1_CGC ))
			else
				xRet := oWsdl:SetValue( aSimple[nPos][1], "***" )
			endif
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "inscricaoEstadual" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], Iif(Empty(SA1->A1_INSCR),'ISENTO',AllTrim(SA1->A1_INSCR)))	//inscricaoEstadual
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf	

			nPos := aScan( aSimple, {|aVet| aVet[2] == "registroEstrangeiro" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], IIf(SA1->A1_PESSOA == "F" .and. SA1->A1_TIPO=="X","01"," "))	//registroEstrangeiro
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf	

			nPos := aScan( aSimple, {|aVet| aVet[2] == "nome1" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], Substr(SA1->A1_NOME,1,35))	//nome1
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf										

			nPos := aScan( aSimple, {|aVet| aVet[2] == "nome2" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], Substr(SA1->A1_NOME,36,(TamSX3("A1_NOME")[1]-35)))	//nome2
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf										

			nPos := aScan( aSimple, {|aVet| aVet[2] == "telefone1" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], SA1->A1_TEL )	//telefone1
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			//If !Empty( SA1->A1_TEL )
				nPos := aScan( aSimple, {|aVet| aVet[2] == "telefoneCelular" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], SA1->A1_TEL)	//telefoneCelular
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
					"SA1"			 										,;	// Tabela
					"1"				 										,;	// Indice Utilizado
					(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
					1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
					1														,;	// Operação SAP 1=Inclusao;2=cancelamento
					,;	// XML Envio
					"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
					"Erro no campo: " + aSimple[nPos][2]+ " Erro: " + oWsdl:cError	)	// Retorno
					*/
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			//EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "email" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], SA1->A1_EMAIL)	//email
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			if !empty( SA1->A1_END )
				nPos := aScan( aSimple, {|aVet| aVet[2] == "rua" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(SA1->A1_END))	//rua
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
					"SA1"			 										,;	// Tabela
					"1"				 										,;	// Indice Utilizado
					(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
					1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
					1														,;	// Operação SAP 1=Inclusao;2=cancelamento
					,;	// XML Envio
					"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
					"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
					*/
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroRua" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], xNumRua(SA1->A1_END))	//numeroRua 
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf	

			nPos := aScan( aSimple, {|aVet| aVet[2] == "complemento" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], Substr(SA1->A1_COMPLEM,1,10))	//complemento 
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf	

			nPos := aScan( aSimple, {|aVet| aVet[2] == "bairro" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(SA1->A1_BAIRRO))	//bairro 
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf	

			//if !empty( SA1->A1_CEP )
				nPos := aScan( aSimple, {|aVet| aVet[2] == "codigoPostal" } )
				//xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim( SA1->A1_CEP))	//codigoPostal 
				xRet := oWsdl:SetValue( aSimple[nPos][1], TRANSFORM( SA1->A1_CEP , PesqPict( 'SA1' , 'A1_CEP' ) ) )	//codigoPostal 
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
					"SA1"			 										,;	// Tabela
					"1"				 										,;	// Indice Utilizado
					(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
					1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
					1														,;	// Operação SAP 1=Inclusao;2=cancelamento
					,;	// XML Envio
					"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
					"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
					*/
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			//EndIf

			if !empty( SA1->A1_MUN )
				nPos := aScan( aSimple, {|aVet| aVet[2] == "cidade" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(SA1->A1_MUN))	//cidade 
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
					"SA1"			 										,;	// Tabela
					"1"				 										,;	// Indice Utilizado
					(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
					1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
					1														,;	// Operação SAP 1=Inclusao;2=cancelamento
					,;	// XML Envio
					"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
					"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
					*/
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			if !empty( SA1->A1_EST )
				nPos := aScan( aSimple, {|aVet| aVet[2] == "regiao" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(SA1->A1_EST))	//regiao 
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
					"SA1"			 										,;	// Tabela
					"1"				 										,;	// Indice Utilizado
					(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
					1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
					1														,;	// Operação SAP 1=Inclusao;2=cancelamento
					,;	// XML Envio
					"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
					"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
					*/
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			if !empty( SA1->A1_PAIS )
				nPos := aScan( aSimple, {|aVet| aVet[2] == "pais" } )
				if SA1->A1_EST <> "EX"
					xRet := oWsdl:SetValue( aSimple[nPos][1], left( SYA->YA_SIGLA , 2 ) )	//pais
				else
					xRet := oWsdl:SetValue( aSimple[nPos][1], SYA->YA_SIGLA )	//pais
				endif
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
					"SA1"			 										,;	// Tabela
					"1"				 										,;	// Indice Utilizado
					(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
					1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
					1														,;	// Operação SAP 1=Inclusao;2=cancelamento
					,;	// XML Envio
					"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
					"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
					*/
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "classificacaoClientes" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], "01")	//classificacaoClientes 
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf		

			nPos := aScan( aSimple, {|aVet| aVet[2] == "idioma" } )
			//xRet := oWsdl:SetValue( aSimple[nPos][1], Iif(!Empty(SA1->A1_CGC),"PT"," "))	//idioma 

			if SA1->A1_EST <> "EX"
				xRet := oWsdl:SetValue( aSimple[nPos][1], "P")	//idioma
			else
				xRet := oWsdl:SetValue( aSimple[nPos][1], " ")	//idioma
			endif
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf				

			if SA1->A1_PESSOA == "F" .AND. !empty( SA1->A1_DTNASC )
				nPos := aScan( aSimple, {|aVet| aVet[2] == "dataNascimento" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], left( fwTimeStamp( 5 , SA1->A1_DTNASC ) , 10 ) )	//dataNascimento
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
					"SA1"			 										,;	// Tabela
					"1"				 										,;	// Indice Utilizado
					(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
					1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
					1														,;	// Operação SAP 1=Inclusao;2=cancelamento
					,;	// XML Envio
					"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
					"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
					*/
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf				
			endif

			if !empty( SA1->A1_SUFRAMA )
				nPos := aScan( aSimple, {|aVet| aVet[2] == "suframa" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(SA1->A1_SUFRAMA))	//suframa 
				//xRet := oWsdl:SetValue( aSimple[nPos][1], " ")	//suframa
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
					"SA1"			 										,;	// Tabela
					"1"				 										,;	// Indice Utilizado
					(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
					1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
					1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																			,;	// XML Envio
					"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
					"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
					*/
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "moeda" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], "BRL")	//moeda 
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf	

			nPos := aScan( aSimple, {|aVet| aVet[2] == "contribuinteICMS" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], Iif(SA1->A1_PESSOA == 'J','1','9')) //contribuinteICMS 
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf		

			if !empty( SA1->A1_CONTA )
				nPos := aScan( aSimple, {|aVet| aVet[2] == "contaCliente" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(SA1->A1_CONTA)) //contaCliente 
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
					"SA1"			 										,;	// Tabela
					"1"				 										,;	// Indice Utilizado
					(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
					1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
					1														,;	// Operação SAP 1=Inclusao;2=cancelamento
					,;	// XML Envio
					"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
					"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
					*/
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

//			VER REGRA NO CLIENTE
			nPos := aScan( aSimple, {|aVet| aVet[2] == "classificacaoFiscalCliente" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], "1") //classificacaoFiscalCliente 
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)					,;	// Filial
				"SA1"			 										,;	// Tabela
				"1"				 										,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)						,;	// Chave
				1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1														,;	// Operação SAP 1=Inclusao;2=cancelamento
				,;	// XML Envio
				"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro no campo: " + aSimple[nPos][2] + " Erro: " + oWsdl:cError	)	// Retorno
				*/
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf			

			// Exibe a mensagem que será enviada
			cMsgSoap := ""
			cMsgSoap := oWsdl:GetSoapMsg()

			memoWrite( "\cSoapSA1.txt", cMsgSoap )

			conout( cMsgSoap )

			cMsgSoap	:= strTran( cMsgSoap , '<CPF>***</CPF>'	, '<CPF/>' )
			cMsgSoap	:= fwNoAccent( cMsgSoap )
			cMsgSoap	:= encodeUtf8( cMsgSoap )
			//cMsgSoap	:= strTran( cMsgSoap , ' />'	, '/>' )

			// Envia a mensagem SOAP ao servidor
			xRet := oWsdl:SendSoapMsg( cMsgSoap /*cMsg*/)

			//xRet := oWsdl:SendSoapMsg( /*cMsg*/ )
			if !xRet 
				conout( "Erro: " + oWsdl:cError )
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro: " + oWsdl:cError,cMsgSoap)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)						,;	// Filial
				"SA1"			 								,;	// Tabela
				"1"				 								,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)				,;	// Chave
				1												,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1												,;	// Operação SAP 1=Inclusao;2=cancelamento
				cMsgSoap										,;	// XML Envio
				"E"												,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				"Erro: " + oWsdl:cError							)	// Retorno
				*/
			else
				// Recupera os elementos de retorno, já parseados
				cResp := ""
				cResp := oWsdl:GetParsedResponse()
				memoWrite( "\response.txt", cResp )

				//updSA1( (cAliasQry)->SA1RECNO )
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"A",cResp,cMsgSoap)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A1_FILIAL)						,;	// Filial
				"SA1"			 								,;	// Tabela
				"1"				 								,;	// Indice Utilizado
				(cAliasQry)->( A1_COD + A1_LOJA)				,;	// Chave
				1												,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
				1												,;	// Operação SAP 1=Inclusao;2=cancelamento
				cMsgSoap										,;	// XML Envio
				"A"												,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
				cResp											)	// Retorno
				*/
			endif
		endif
		(cAliasQry)->(dbSkip())	
	EndDo

	IF lIsBlind
		Conout("Conexão finalizada com sucesso : CMVSAP02 " + DTOC(dDATABASE) + " - " + TIME() )
		RpcClearEnv()
	Endif	

Return

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
/*
static function updSA1( nSA1RECNO )
	local cUpdTbl	:= ""
	local aAreaX	:= getArea()

	cUpdTbl	:= ""

	cUpdTbl := "UPDATE " + retSQLName("SA1")								+ CRLF
	cUpdTbl += "	SET"													+ CRLF
	cUpdTbl += " 		A1_XFLGSAP = 'I'"									+ CRLF
	cUpdTbl += " WHERE"														+ CRLF
	cUpdTbl += " 		R_E_C_N_O_ = " + allTrim( str( nSA1RECNO ) ) + ""	+ CRLF

	if tcSQLExec( cUpdTbl ) < 0
		conout("Não foi possível executar UPDATE." + CRLF + tcSqlError())
	endif

	restArea( aAreaX )
return
*/

//-------------------------------------------------------------------
//TRATAMENTO DE CAMPO DATA
//-------------------------------------------------------------------
/*
Static Function xDtSap(cData)
	cRet := SubStr(cData,1,4) + "-" + SubStr(cData,5,2) + "-" + SubStr(cData,7,2)
return cRet
*/

//-------------------------------------------------------------------
//TRATAMENTO DE CAMPO DATA
//-------------------------------------------------------------------
Static Function xNumRua(cCpoRua)

	aStr := StrTokArr2(cCpoRua, ",")
	If Len(aStr)>1
		cText := Alltrim(aStr[2])
	Else
		cText:= "SN"
	EndIf

Return (cText)


// chamada via job por arquivo .INI
user function xCMVSA02(xParam1,xParam2,xParam3)

U_CMVSAP02({{xParam1,xParam2,Val(xParam3)}})

Return()
