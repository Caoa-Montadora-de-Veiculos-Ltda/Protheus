#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "xmlxfun.ch"

/*
Integracao de Fornecedores com SAP
*/
user function CMVSAP01( aParam )
	local oWsdl
	local cQry			:= ""
	local aOps			:= {}
	local cUser			:= ""//allTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
	local cPass			:= ""//allTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP
	local cURLProxy		:= ""//allTrim( superGetMv( "CAOAPROXY"	, , "proxy.caoa.local"		) )	// Usuario Proxy da Rede Caoa
	local nPortProxy	:= ""//superGetMv( "CAOAPORT"	, , 8080 )								// Porta Proxy da Rede Caoa
	local cUserProxy	:= ""//allTrim( superGetMv( "CAOAPROUSE"	, , "T-RODRIGO.SALOMAO"	) )	// Usuario do Proxy
	local cPassProxy	:= ""//allTrim( superGetMv( "CAOAPROPAS"	, , "caoa2019**"		) )	// Senha do Proxy
	local cUrl			:= ""//allTrim( superGetMv( "CAOASAP01A"	, , "http://10.120.40.140:51400/dir/wsdl?p=ic/9f324344323d391792946bbd98bd4139") )
	//local cUrl		:= allTrim( superGetMv( "CAOASAP01B"	, , "http://srvtvt05caoa.caoa.com.br:51400/dir/wsdl?p=ic/9f324344323d391792946bbd98bd4139") )
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
	
	private cAliasQry	:= ""
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

		If !LockByName("CMVSAP01")
			Conout("JOB já em Execução : CMVSAP01 " + DTOC(dDATABASE) + " - " + TIME() )
			RpcClearEnv()
			Return
		Else
			Conout("Conexão realizada com sucesso : CMVSAP01 " + DTOC(dDATABASE) + " - " + TIME() )
		EndIf
	EndIF

	cUser		:= allTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
	cPass		:= allTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP
	cURLProxy	:= allTrim( superGetMv( "CAOAPROXY"	, , "proxy.caoa.local"		) )	// Usuario Proxy da Rede Caoa
	nPortProxy	:= superGetMv( "CAOAPORT"	, , 8080 )								// Porta Proxy da Rede Caoa
	cUserProxy	:= allTrim( superGetMv( "CAOAPROUSE"	, , "T-RODRIGO.SALOMAO"	) )	// Usuario do Proxy
	cPassProxy	:= allTrim( superGetMv( "CAOAPROPAS"	, , "caoa2019**"		) )	// Senha do Proxy
	cUrl		:= allTrim( superGetMv( "CAOASAP01A"	, , "http://10.120.40.141:53400/dir/wsdl?p=ic/9f324344323d391792946bbd98bd4139") )
	nDiasErro	:= superGetMv( "CAOASAP01C"	, , 3 )  // qtde de dias para reprocessar registros com status de erro
	nDiasAguar	:= superGetMv( "CAOASAP01D"	, , 3 )  // qtde de dias para reprocessar registros com status de aguardando

	/*
	cQry := " SELECT R_E_C_N_O_ SA2RECNO	,	A2_FILIAL	,"					+ CRLF
	cQry += " A2_COD		,	A2_LOJA		,	A2_CGC		,	A2_NOME		,"	+ CRLF
	cQry += " A2_NREDUZ		,	A2_END		,	A2_NR_END	,	A2_BAIRRO	,"	+ CRLF
	cQry += " A2_CEP		,	A2_MUN		,	A2_EST		,	A2_TEL		,"	+ CRLF
	cQry += " A2_DDD		,	A2_FAX		,	A2_EMAIL	,	A2_TIPO		,"	+ CRLF
	cQry += " A2_INSCR		,	A2_INSCRM"										+ CRLF
	cQry += " FROM " + RetSqlName("SA2") + " SA2"								+ CRLF
	cQry += " WHERE"															+ CRLF
	cQry += "		A2_XFLGSAP	=	'P'"										+ CRLF
	cQry += "	AND	A2_MSBLQL	<>	'1'"										+ CRLF
	cQry += "	AND	D_E_L_E_T_	=	' '"										+ CRLF
	*/
	
	cQry := "SELECT SZ7.*,SZ7.R_E_C_N_O_ SZ7_RECNO "
	cQry += "FROM "+RetSqlName("SZ7")+" SZ7 "
	//cQry += "WHERE (Z7_XSTATUS = 'P' OR (Z7_XSTATUS = 'E' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasErro)+"') OR (Z7_XSTATUS = 'A' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasAguar)+"' AND Z7_XDTINC < '"+dTos(dDataBase-1)+"')) "
	cQry += "WHERE (Z7_XSTATUS = 'P' OR (Z7_XSTATUS = 'E' AND Z7_XDTINC >= '"+dTos(dDataBase-nDiasErro)+"')) "
	//cQry += "WHERE Z7_XSTATUS = 'P' "
	cQry += "AND Z7_XTABELA = 'SA2' "
	cQry += "AND D_E_L_E_T_ <> '*' "
	
	If nRecRep > 0
		cQry += " AND SZ7.R_E_C_N_O_ = " + AllTrim(Str(nRecRep))
	EndIf
	
	cAliasQry := GetNextAlias()
	cQry := ChangeQuery(cQry)
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAliasQry, .F., .T.)

	cAutorizat := encode64( allTrim( cUser ) + ":" + allTrim( cPass ) )

	aadd( aHeadOut	, 'Content-Type: text/xml; charset=UTF-8'								)
	aadd( aHeadOut	, 'SOAPAction: http://sap.com/xi/WebService/soap1.1'					)
	aadd( aHeadOut	, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')'	)
	aadd( aHeadOut	, 'Authorization: Basic ' + cAutorizat									)

	while !(cAliasQry)->(Eof())

		cTimeIni 	:= time()
		xPostRet	:= httpQuote( cUrl /*<cUrl>*/, "GET" /*<cMethod>*/, /*[cGETParms]*/, /*[cPOSTParms]*/, nTimeOut /*[nTimeOut]*/, aHeadOut /*[aHeadStr]*/, @cHeadRet /*[@cHeaderRet]*/ )

		nStatuHttp	:= 0
		nStatuHttp	:= httpGetStatus()

		cTimeFin	:= time()
		cTimeProc	:= elapTime( cTimeIni, cTimeFin )

		conout(" [SAP] [CMVSAP01] * * * * * Status da integracao * * * * *"									)
		conout(" [SAP] [CMVSAP01] Inicio.......................: " + cTimeIni + " - " + dToC( dDataBase ) 	)
		conout(" [SAP] [CMVSAP01] Fim..........................: " + cTimeFin + " - " + dToC( dDataBase ) 	)
		conout(" [SAP] [CMVSAP01] Tempo de Processamento.......: " + cTimeProc 								)
		conout(" [SAP] [CMVSAP01] URL..........................: " + cUrl									)
		conout(" [SAP] [CMVSAP01] HTTP Method..................: " + "GET" 									)
		conout(" [SAP] [CMVSAP01] Status Http (200 a 299 ok)...: " + allTrim( str( nStatuHttp ) ) 			)
		conout(" [SAP] [CMVSAP01] Retorno......................: " + allTrim( xPostRet ) 					)
		conout(" [SAP] [CMVSAP01] * * * * * * * * * * * * * * * * * * * * "									)

		if nStatuHttp >= 200 .and. nStatuHttp <= 299
			memoWrite( "\" + funName() + ".wsdl", xPostRet )

			// Cria o objeto da classe TWsdlManager
			oWsdl := TWsdlManager():New()

			oWsdl:bNoCheckPeerCert := .T.

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
			xRet := oWsdl:SetOperation( aOps[3][1] ) // "CriaFornecedor"
			If !xRet 
				conout( "Erro: " + oWsdl:cError )
				Return
			EndIf

			//oWsdl:cLocation := cURL//"http://srvtvt05caoa.caoa.com.br:51400/XISOAPAdapter/MessageServlet?channel=B2B_Partner:B2B_ERP:SOAPSenderFornecedor"

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

			// posiciona fornecedor
			SA2->(dbSetOrder(1))
			If SA2->(dbSeek(xFilial("SA2")+Alltrim((cAliasQry)->Z7_XCHAVE)))
				If SA2->A2_MSBLQL == "1"
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Atenção, Fornecedor não esta bloqueado, código: " + alltrim((cAliasQry)->Z7_XCHAVE))
					(cAliasQry)->(dbSkip())
					LOOP
				Endif
			Else
				//U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Atenção, Fornecedor não encontrado, código: " + alltrim((cAliasQry)->Z7_XCHAVE))
				U_ZF19GENSAP((cAliasQry)->Z7_XCHAVE,"N","Fornecedor excluído: " + alltrim((cAliasQry)->Z7_XCHAVE),"SA2")
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf
				
			// Define o valor de cada parâmeto necessário
			nPos := aScan( aSimple, {|aVet| aVet[2] == "sistema" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], "TOTVS" )	//sistema
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
							"SA2"			 										,;	// Tabela
							"1"				 										,;	// Indice Utilizado
							(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
							1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
							1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																					,;	// XML Envio
							"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
							"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
				*/			
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "data" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], left( fwTimeStamp( 5 ) , 10 ) )	//data
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
							"SA2"			 										,;	// Tabela
							"1"				 										,;	// Indice Utilizado
							(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
							1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
							1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																					,;	// XML Envio
							"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
							"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
				*/				
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "hora" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], Time() )	//hora
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
							"SA2"			 										,;	// Tabela
							"1"				 										,;	// Indice Utilizado
							(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
							1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
							1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																					,;	// XML Envio
							"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
							"Erro no campo: " + aSimple[nPos][2]  + "Erro: " + oWsdl:cError	)	// Retorno
				*/			
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "idLote" } )
			//xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_COD) + AllTrim(SA2->A2_LOJA))	//idLote
			xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(Str(Val((cAliasQry)->Z7_XLOTE))))	//idLote
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
							"SA2"			 										,;	// Tabela
							"1"				 										,;	// Indice Utilizado
							(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
							1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
							1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																					,;	// XML Envio
							"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
							"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
				*/				
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "codigoFornecedorParceiro" } )
			xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_COD) + AllTrim(SA2->A2_LOJA) )	//codigoFornecedorParceiro
			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
							"SA2"			 										,;	// Tabela
							"1"				 										,;	// Indice Utilizado
							(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
							1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
							1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																					,;	// XML Envio
							"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
							"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
				*/			
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			If !SA2->A2_EST == "EX"
				If !Empty(SA2->A2_CGC)
					nPos := aScan( aSimple, {|aVet| aVet[2] == "CPFCNPJ" } )
					xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_CGC) )	//CPFCNPJ
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
						/*
						U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
									"SA2"			 										,;	// Tabela
									"1"				 										,;	// Indice Utilizado
									(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
									1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
									1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																							,;	// XML Envio
									"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
									"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
						*/			
						(cAliasQry)->(dbSkip())
						LOOP
					EndIf
				EndIf
			Else
				If !Empty(SA2->A2_NIFEX)
					nPos := aScan( aSimple, {|aVet| aVet[2] == "CPFCNPJ" } )
					xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_NIFEX) )	//CPFCNPJ
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
						/*
						U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
									"SA2"			 										,;	// Tabela
									"1"				 										,;	// Indice Utilizado
									(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
									1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
									1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																							,;	// XML Envio
									"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
									"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
						*/			
						(cAliasQry)->(dbSkip())
						LOOP
					EndIf
				EndIf
				
			Endif	

			If !Empty(SA2->A2_NOME)
				nPos := aScan( aSimple, {|aVet| aVet[2] == "nome1" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_NOME) )	//nome1
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
								"SA2"			 										,;	// Tabela
								"1"				 										,;	// Indice Utilizado
								(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
								1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
								1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																						,;	// XML Envio
								"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
								"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
					*/			
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			If !Empty(SA2->A2_NREDUZ)
				nPos := aScan( aSimple, {|aVet| aVet[2] == "nome2" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_NREDUZ) )	//nome2
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
								"SA2"			 										,;	// Tabela
								"1"				 										,;	// Indice Utilizado
								(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
								1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
								1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																						,;	// XML Envio
								"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
								"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
					*/			
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			If !Empty(SA2->A2_END)
				nPos := aScan( aSimple, {|aVet| aVet[2] == "endereco" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_END) )	//endereco
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
								"SA2"			 										,;	// Tabela
								"1"				 										,;	// Indice Utilizado
								(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
								1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
								1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																						,;	// XML Envio
								"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
								"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
					*/			
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			if !empty( SA2->A2_NR_END )
				nPos := aScan( aSimple, {|aVet| aVet[2] == "numero" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], SA2->A2_NR_END )//numero
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
								"SA2"			 										,;	// Tabela
								"1"				 										,;	// Indice Utilizado
								(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
								1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
								1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																						,;	// XML Envio
								"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
								"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
					*/			
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			If !Empty(SA2->A2_BAIRRO)
				nPos := aScan( aSimple, {|aVet| aVet[2] == "bairro" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_BAIRRO) )	//bairro
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
								"SA2"			 										,;	// Tabela
								"1"				 										,;	// Indice Utilizado
								(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
								1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
								1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																						,;	// XML Envio
								"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
								"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
					*/			
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			If !Empty(SA2->A2_CEP)
				nPos := aScan( aSimple, {|aVet| aVet[2] == "CEP" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], TRANSFORM( SA2->A2_CEP , PesqPict( 'SA2' , 'A2_CEP' ) ) )	//CEP
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
								"SA2"			 										,;	// Tabela
								"1"				 										,;	// Indice Utilizado
								(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
								1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
								1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																						,;	// XML Envio
								"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
								"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
					*/			
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			If !Empty(SA2->A2_MUN)
				nPos := aScan( aSimple, {|aVet| aVet[2] == "cidade" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_MUN) )	//cidade
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
								"SA2"			 										,;	// Tabela
								"1"				 										,;	// Indice Utilizado
								(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
								1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
								1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																						,;	// XML Envio
								"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
								"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
					*/			
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			If !Empty(SA2->A2_EST)
				nPos := aScan( aSimple, {|aVet| aVet[2] == "regiao" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_EST) )	//regiao
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
								"SA2"			 										,;	// Tabela
								"1"				 										,;	// Indice Utilizado
								(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
								1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
								1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																						,;	// XML Envio
								"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
								"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
					*/			
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			If !Empty(SA2->A2_TEL)
				nPos := aScan( aSimple, {|aVet| aVet[2] == "telefoneFixo" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_DDD) + AllTrim(SA2->A2_TEL) )	//telefoneFixo
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
								"SA2"			 										,;	// Tabela
								"1"				 										,;	// Indice Utilizado
								(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
								1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
								1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																						,;	// XML Envio
								"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
								"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
					*/			
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			If !Empty(SA2->A2_FAX)
				nPos := aScan( aSimple, {|aVet| aVet[2] == "telefoneCelular" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_DDD) + AllTrim(SA2->A2_FAX) )	//telefoneCelular
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*	
					U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
								"SA2"			 										,;	// Tabela
								"1"				 										,;	// Indice Utilizado
								(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
								1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
								1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																						,;	// XML Envio
								"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
								"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
					*/			
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			If !Empty(SA2->A2_EMAIL)
				nPos := aScan( aSimple, {|aVet| aVet[2] == "email" } )
				xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_EMAIL) )	//email
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
								"SA2"			 										,;	// Tabela
								"1"				 										,;	// Indice Utilizado
								(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
								1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
								1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																						,;	// XML Envio
								"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
								"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
					*/			
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			nPos := aScan( aSimple, {|aVet| aVet[2] == "marcacaoFornecedorPessoaFisica" } )

			if !empty( SA2->A2_TIPO ) .AND. SA2->A2_TIPO == "F"
				xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim( SA2->A2_TIPO ) )	//marcacaoFornecedorPessoaFisica
			else
				xRet := oWsdl:SetValue( aSimple[nPos][1], "*" )	//marcacaoFornecedorPessoaFisica
			endif

			If !xRet
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
							"SA2"			 										,;	// Tabela
							"1"				 										,;	// Indice Utilizado
							(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
							1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
							1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																					,;	// XML Envio
							"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
							"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
				*/			
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			If !Empty(SA2->A2_INSCR)
				nPos := aScan( aSimple, {|aVet| aVet[2] == "inscricaoEstadual" } )

				if SA2->A2_TIPO == "F"
					xRet := oWsdl:SetValue( aSimple[nPos][1], "ISENTO" )	//inscricaoEstadual
				else
					xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_INSCR) )	//inscricaoEstadual
				endif

				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
								"SA2"			 										,;	// Tabela
								"1"				 										,;	// Indice Utilizado
								(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
								1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
								1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																						,;	// XML Envio
								"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
								"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
					*/			
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			If !Empty(SA2->A2_INSCRM)
				nPos := aScan( aSimple, {|aVet| aVet[2] == "inscricaoMunicipal" } )
				if SA2->A2_TIPO == "F"
					xRet := oWsdl:SetValue( aSimple[nPos][1], "ISENTO" )	//inscricaoMunicipal
				else
					xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(SA2->A2_INSCRM) )	//inscricaoMunicipal
				endif
				If !xRet
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError)
					/*
					U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)								,;	// Filial
								"SA2"			 										,;	// Tabela
								"1"				 										,;	// Indice Utilizado
								(cAliasQry)->(A2_COD + A2_LOJA)							,;	// Chave
								1														,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
								1														,;	// Operação SAP 1=Inclusao;2=cancelamento
																						,;	// XML Envio
								"E"														,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
								"Erro no campo: " + aSimple[nPos][2] + "Erro: " + oWsdl:cError	)	// Retorno
					*/			
					(cAliasQry)->(dbSkip())
					LOOP
				EndIf
			EndIf

			// Exibe a mensagem que será enviada
			cMsgSoap := ""
			cMsgSoap := oWsdl:GetSoapMsg()

			memoWrite( "\cMsgSoap.txt", cMsgSoap )

			conout( cMsgSoap )

			cMsgSoap	:= strTran( cMsgSoap , '<marcacaoFornecedorPessoaFisica>*</marcacaoFornecedorPessoaFisica>' , '<marcacaoFornecedorPessoaFisica/>' )
			cMsgSoap	:= fwNoAccent( cMsgSoap )
			cMsgSoap	:= encodeUtf8( cMsgSoap )

			// Envia a mensagem SOAP ao servidor
			xRet := oWsdl:SendSoapMsg( cMsgSoap /*cMsg*/)
			//xRet := oWsdl:SendSoapMsg( /*cMsg*/ )
			if !xRet 
				conout( "Erro: " + oWsdl:cError )
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","Erro: " + oWsdl:cError,cMsgSoap)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)						,;	// Filial
							"SA2"			 								,;	// Tabela
							"1"				 								,;	// Indice Utilizado
							(cAliasQry)->(A2_COD + A2_LOJA)					,;	// Chave
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

				//updSA2( (cAliasQry)->SA2RECNO )
				U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"A",cResp,cMsgSoap)
				/*
				U_ZF11GENSAP(	(cAliasQry)->(A2_FILIAL)						,;	// Filial
							"SA2"			 								,;	// Tabela
							"1"				 								,;	// Indice Utilizado
							(cAliasQry)->(A2_COD + A2_LOJA)					,;	// Chave
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
		Conout("Conexão finalizada com sucesso : CMVSAP01 " + DTOC(dDATABASE) + " - " + TIME() )
		RpcClearEnv()
	Endif	
	
Return

// chamada via job por arquivo .INI
user function xCMVSA01(xParam1,xParam2,xParam3)

U_CMVSAP01({{xParam1,xParam2,Val(xParam3)}})

Return()
