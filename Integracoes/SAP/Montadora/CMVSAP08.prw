#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "xmlxfun.ch"

/*
Integracao de Lancamento Contabil com SAP
*/
user function CMVSAP08( aParam )

	local oWsdl
	local cQry			:= ""
	local cAliasQry		:= ""
	local cAliasCT2		:= ""
	local aOps			:= {}
	local cUser			:= ""//allTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
	local cPass			:= ""//allTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP
	local cURLProxy		:= ""//allTrim( superGetMv( "CAOAPROXY"	, , "proxy.caoa.local"		) )	// Usuario Proxy da Rede Caoa
	local nPortProxy	:= ""//superGetMv( "CAOAPORT"	, , 8080 )								// Porta Proxy da Rede Caoa
	local cUserProxy	:= ""//allTrim( superGetMv( "CAOAPROUSE"	, , "T-RODRIGO.SALOMAO"	) )	// Usuario do Proxy
	local cPassProxy	:= ""//allTrim( superGetMv( "CAOAPROPAS"	, , "caoa2019**"		) )	// Senha do Proxy
	local cUrl			:= ""//allTrim( superGetMv( "CAOASAP08A"	, , "http://10.120.40.140:51400/dir/wsdl?p=ic/7cd73db8a3283b5cbbbf1fe55d2f205c") )
	local aHeadOut		:= {}
	local cHeadRet		:= ""
	local cAutorizat	:= ""
	local cTimeIni		:= ""
	local cTimeFin		:= ""
	local cTimeProc		:= ""
	local xPostRet		:= nil
	local nStatuHttp	:= 0
	local nTimeOut		:= 120
	Local nz			:= 1
	Local cNota := ""
	Local cSerie := ""
	Local cUsu := ""
	Local cTipoDoc := ""
	Local nDiasErro	:= 0
	Local nDiasProces 	:= 30
	Local nPos := 0
	Local xRet := Nil
	
	Local nRecRep := 0
	Local cEmpJob := ""
	Local cFilJob := ""

	private lIsBlind := (IsBlind() .OR. Type("__LocalDriver") == "U") .and. type('httpheadin->main') == 'U' 
	//Para previnir erro quando for chamado via webservice valida se a variavel httpheadin->main existe 

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

		If !LockByName("CMVSAP08")
			Alert("JOB já em Execução : CMVSAP08 " + DTOC(dDATABASE) + " - " + TIME() )
			RpcClearEnv()
			Return
		Else
			Conout("Conexão realizada com sucesso : CMVSAP08 " + DTOC(dDATABASE) + " - " + TIME() )
		EndIf
	EndIF
	
	cUser		:= allTrim( superGetMv( "CAOASAPUSE"	, , "USER_TOTVS"		) )	// Usuario para autenticacao no WS SAP
	cPass		:= allTrim( superGetMv( "CAOASAPPAS"	, , "Assa@caoa1"		) )	// Senha para autenticao no WS SAP
	cURLProxy	:= allTrim( superGetMv( "CAOAPROXY"	, , "proxy.caoa.local"		) )	// Usuario Proxy da Rede Caoa
	nPortProxy	:= superGetMv( "CAOAPORT"	, , 8080 )								// Porta Proxy da Rede Caoa
	cUserProxy	:= allTrim( superGetMv( "CAOAPROUSE"	, , "T-RODRIGO.SALOMAO"	) )	// Usuario do Proxy
	cPassProxy	:= allTrim( superGetMv( "CAOAPROPAS"	, , "caoa2019**"		) )	// Senha do Proxy
	cUrl		:= allTrim( superGetMv( "CAOASAP08A"	, , "http://10.120.40.141:53400/dir/wsdl?p=ic/7cd73db8a3283b5cbbbf1fe55d2f205c") )
	nDiasErro	:= superGetMv( "CAOASAP01C"	, , 3 )  // qtde de dias para reprocessar registros com status de erro, após tera que verificar manualnente
	nDiasProces	:= superGetMv( "CAOASAP01D"	, , 3 )  // qtde de dias para processar registros não processados
		
	//Montagem da Query para pegar Itens da Fila

	//********************************************************************************************************************

	cQry := " SELECT " + CRLF
	cQry += " 	* FROM ( " + CRLF
	cQry += " 		SELECT  " + CRLF
	cQry += " 			SZ7.Z7_FILIAL " + CRLF
	cQry += " 			,SZ7.Z7_XLOTE " + CRLF
	cQry += " 			,SZ7.Z7_XSEQUEN " + CRLF
	cQry += " 			,SZ7.Z7_XTABELA " + CRLF
	cQry += " 			,SZ7.Z7_OPERACA " + CRLF
	cQry += " 			,SZ7.Z7_XINDICE " + CRLF
	cQry += " 			,SZ7.Z7_XCHAVE " + CRLF
	cQry += " 			,SZ7.Z7_XSTATUS " + CRLF
	cQry += " 			,SZ7.Z7_XOPEPRO " + CRLF
	cQry += " 			,SZ7.Z7_XOPESAP " + CRLF
	cQry += " 			,SZ7.Z7_XIDSAP " + CRLF
	cQry += " 			,SZ7.Z7_ORIGEM " + CRLF
	cQry += " 			,SZ7.Z7_DOCORI " + CRLF
	cQry += " 			,SZ7.Z7_SERORI " + CRLF
	cQry += " 			,SZ7.Z7_CLIFOR " + CRLF
	cQry += " 			,SZ7.Z7_LOJA " + CRLF
	cQry += " 			,SZ7.Z7_XDTINC " + CRLF
	cQry += "			,SZ7.Z7_TIPONF " + CRLF
	cQry += "			,SZ7.Z7_LOTEINC " + CRLF
	cQry += " 			,COALESCE ( " + CRLF
	cQry += " 					(select SZ7B.Z7_XSTATUS  " + CRLF
	cQry += " 						from " + RetSqlName("SZ7") + " SZ7B " + CRLF
	cQry += " 						WHERE   SZ7B.Z7_FILIAL  = SZ7.Z7_FILIAL " + CRLF
	cQry += " 							AND	SZ7B.Z7_XTABELA = SZ7.Z7_XTABELA   " + CRLF
	cQry += " 							AND SZ7B.Z7_DOCORI  = SZ7.Z7_DOCORI   " + CRLF
	cQry += " 							AND SZ7B.Z7_SERORI  = SZ7.Z7_SERORI  " + CRLF
	cQry += " 							AND SZ7B.Z7_CLIFOR  = SZ7.Z7_CLIFOR   " + CRLF
	cQry += " 							AND SZ7B.Z7_LOJA    = SZ7.Z7_LOJA " + CRLF
	cQry += "							AND SZ7B.Z7_XCHAVE  = SZ7.Z7_XCHAVE " + CRLF
	cQry += " 							AND SZ7B.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " 							AND SZ7B.Z7_XSTATUS = 'E' " + CRLF
	cQry += " 							AND ROWNUM = 1 ) " + CRLF
	cQry += " 					, ' ' ) STATUS " + CRLF
	cQry += " 			,SZ7.R_E_C_N_O_ SZ7_RECNO  " + CRLF
	cQry += " 		from " + RetSqlName("SZ7") + " SZ7  " + CRLF
	cQry += " 			WHERE   SZ7.Z7_XSTATUS in ('P','E') " + CRLF
	cQry += " 				AND SZ7.Z7_FILIAL  = '" + xFILIAL("SZ7") + "' " + CRLF
	cQry += " 				AND SZ7.Z7_XDTINC >= '" + dTos(dDataBase - nDiasProcess) + "'  " + CRLF
	cQry += " 				AND SZ7.Z7_XTABELA = 'CT2' " + CRLF
	cQry += " 				AND SZ7.D_E_L_E_T_ = ' ' " + CRLF

	If nRecRep > 0
		cQry += " AND SZ7.R_E_C_N_O_ = " + AllTrim(Str(nRecRep))
	EndIf

	cQry += " ) TDD " + CRLF
	cQry += " 	WHERE STATUS = ' ' OR (STATUS = 'E' AND  Z7_XDTINC >= '" + dTos(dDataBase - nDiasErro) + "' ) " + CRLF
	cQry += " ORDER BY SZ7_RECNO "
	
	//********************************************************************************************************************

	cAliasQry := GetNextAlias()
	cQry := ChangeQuery(cQry)     

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAliasQry, .F., .T.)

	cAutorizat := encode64( allTrim( cUser ) + ":" + allTrim( cPass ) )

	aadd( aHeadOut	, 'Content-Type: text/xml; charset=UTF-8'								)
	aadd( aHeadOut	, 'SOAPAction: http://sap.com/xi/WebService/soap1.1'					)
	aadd( aHeadOut	, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')'	)
	aadd( aHeadOut	, 'Authorization: Basic ' + cAutorizat									)
	
	while !(cAliasQry)->(Eof())
		cNota := ""
		cSerie := ""
		
		/*
		//Exclusão SAP
		If (cAliasQry)->Z7_XOPESAP == 2 // 05/09/19
			If (cAliasQry)->Z7_XSEQUEN <> '001' .and. !U_ZF13GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN)
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf
		Endif	
		*/	
		If (cAliasQry)->Z7_XOPESAP == 2 // 05/09/19
			If (cAliasQry)->Z7_XSEQUEN <> '001' .and. !U_ZF13GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,(cAliasQry)->Z7_LOTEINC,.T.,,,,,,(cAliasQry)->SZ7_RECNO)
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf
		Else
			//If (cAliasQry)->Z7_XSEQUEN <> '001' .and. !U_ZF13GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,,.F.,(cAliasQry)->Z7_DOCORI,(cAliasQry)->Z7_SERORI,(cAliasQry)->Z7_TIPONF,(cAliasQry)->Z7_CLIFOR,(cAliasQry)->Z7_LOJA,(cAliasQry)->SZ7_RECNO)
			// para lancamento contabil, deve-se verificar todas as sequencias, pois um segundo envio para o mesmo lancamento estarah 
			// gravado na sz7 com sequencia 001, uma vez que eh uma nova chave para cada exclusao e inclusao de lancamento, jah que o 
			// lancamento contabil eh outro numero de documento
			If !U_ZF13GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,,.F.,(cAliasQry)->Z7_DOCORI,(cAliasQry)->Z7_SERORI,(cAliasQry)->Z7_TIPONF,(cAliasQry)->Z7_CLIFOR,(cAliasQry)->Z7_LOJA,(cAliasQry)->SZ7_RECNO)
				(cAliasQry)->(dbSkip())
				LOOP
			EndIf

			If U_ZF18GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XLOTE,(cAliasQry)->SZ7_RECNO)
				(cAliasQry)->(dbSkip())
				LOOP
			Endif	
		Endif	
		
		//Exclusão SAP
		If (cAliasQry)->Z7_XOPESAP == 2
			//cMsgSoap := U_ZF14GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,{{"motivoOperacao","2"}})
			cMsgSoap := U_ZF15GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,{{"motivoOperacao","2"}})
		EndIf
		
		// para lancamentos originados a partir de notas fiscais, verifica se estao autorizadas na sefaz
		DBSELECTAREA('CT2')
		CT2->(dbSetOrder(1))
		If CT2->(dbSeek((cAliasQry)->Z7_FILIAL+Subs((cAliasQry)->Z7_XCHAVE,1,8)+Subs((cAliasQry)->Z7_XCHAVE,9,TamSX3("CT2_LOTE")[1])+Subs((cAliasQry)->Z7_XCHAVE,15,TamSX3("CT2_SBLOTE")[1])+Subs((cAliasQry)->Z7_XCHAVE,18,TamSX3("CT2_DOC")[1])))
			If CT2->CT2_LP $ "610/650" // lancamentos de faturamento e compras
				// posicionar pela CV3, pois para notas de saida geradas pelo sigavei o campo ct2_key estah vindo em branco
				// problema deverah ser corrigido, mas enquanto estah assim...
				CV3->(dbSetOrder(1))
				If CV3->(dbSeek(xFilial("CV3")+dTos(CT2->CT2_DATA)+CT2->CT2_SEQUEN))
					If CT2->CT2_LP $ "610"
						//SF2->(dbSetOrder(1))
						//If SF2->(dbSeek(Subs(CT2->CT2_KEY,1,TamSX3("F2_FILIAL")[1]+TamSX3("F2_DOC")[1]+TamSX3("F2_SERIE")[1]+TamSX3("F2_CLIENTE")[1]+TamSX3("F2_LOJA")[1])))
						SD2->(dbGoto(Val(CV3->CV3_RECORI)))
						If SD2->(Recno()) == Val(CV3->CV3_RECORI)
							cNota := SD2->D2_DOC
							cSerie := SD2->D2_SERIE
						
							SF2->(dbSetOrder(1))
							//If SF2->(dbSeek(Subs(CT2->CT2_KEY,1,TamSX3("F2_FILIAL")[1]+TamSX3("F2_DOC")[1]+TamSX3("F2_SERIE")[1]+TamSX3("F2_CLIENTE")[1]+TamSX3("F2_LOJA")[1])))
							If SF2->(dbSeek(SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))
								If !U_ZF09GENSAP(SF2->F2_ESPECIE,SF2->F2_CHVNFE,SF2->F2_FIMP,SF2->F2_DOC,SF2->F2_SERIE)
									U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","[CMVSAP08] - Envio movimento SAP, Nota Fiscal não autorizada na Sefaz. NF :"+Alltrim(SF2->F2_DOC)+"/"+Alltrim(SF2->F2_SERIE)," ")
									(cAliasQry)->(dbSkip())
									Loop
								Endif
							Endif
						Endif
					Elseif CT2->CT2_LP $ "650"
						//SF1->(dbSetOrder(1))
						//If SF1->(dbSeek(Subs(CT2->CT2_KEY,1,TamSX3("F1_FILIAL")[1]+TamSX3("F1_DOC")[1]+TamSX3("F1_SERIE")[1]+TamSX3("F1_FORNECE")[1]+TamSX3("F1_LOJA")[1])))
						SD1->(dbGoto(Val(CV3->CV3_RECORI)))
						If SD1->(Recno()) == Val(CV3->CV3_RECORI)
							cNota := SD1->D1_DOC
							cSerie := SD1->D1_SERIE
						
							If SD1->D1_FORMUL == "S"
								SF1->(dbSetOrder(1))
								If SF1->(dbSeek(SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
									If !U_ZF09GENSAP(SF1->F1_ESPECIE,SF1->F1_CHVNFE,SF1->F1_FIMP,SF1->F1_DOC,SF1->F1_SERIE)
										U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","[CMVSAP08] - Envio movimento SAP, Nota Fiscal não autorizada na Sefaz. NF :"+Alltrim(SF1->F1_DOC)+"/"+Alltrim(SF1->F1_SERIE)," ")
										(cAliasQry)->(dbSkip())
										Loop
									Endif
								EndIf	
							Endif	
						Endif
					Endif
				Endif	
			Endif
		Endif			
		
		cTimeIni 	:= time()
		xPostRet	:= httpQuote( cUrl /*<cUrl>*/, "GET" /*<cMethod>*/, /*[cGETParms]*/, /*[cPOSTParms]*/, nTimeOut /*[nTimeOut]*/, aHeadOut /*[aHeadStr]*/, @cHeadRet /*[@cHeaderRet]*/ )

		nStatuHttp	:= 0
		nStatuHttp	:= httpGetStatus()

		cTimeFin	:= time()
		cTimeProc	:= elapTime( cTimeIni, cTimeFin )

		Conout(" [SAP] [CMVSAP08] * * * * * Status da integracao * * * * *"									)
		Conout(" [SAP] [CMVSAP08] Inicio.......................: " + cTimeIni + " - " + dToC( dDataBase ) 	)
		Conout(" [SAP] [CMVSAP08] Fim..........................: " + cTimeFin + " - " + dToC( dDataBase ) 	)
		Conout(" [SAP] [CMVSAP08] Tempo de Processamento.......: " + cTimeProc 								)
		Conout(" [SAP] [CMVSAP08] URL..........................: " + cUrl									)
		Conout(" [SAP] [CMVSAP08] HTTP Method..................: " + "GET" 									)
		Conout(" [SAP] [CMVSAP08] Status Http (200 a 299 ok)...: " + allTrim( str( nStatuHttp ) ) 			)
		Conout(" [SAP] [CMVSAP08] Retorno......................: " + allTrim( xPostRet ) 					)
		Conout(" [SAP] [CMVSAP08] * * * * * * * * * * * * * * * * * * * * "									)

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
			//xRet := oWsdl:ParseFile("\WSDL\Fornecedor_OutService.wsdl" )
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
			xRet := oWsdl:SetOperation( aOps[1][1] ) // "Contabil_Out"
			If !xRet 
				Conout("SetOperation ERROR: "  + oWsdl:cError)
				return
			EndIf
			
			//Realizar Query na CT2
			cAliasCT2 := xQryCt2((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XCHAVE)
			
			aComplex := oWsdl:NextComplex()
			while ValType( aComplex ) == "A"
				//varinfo( "aComplex", aComplex )
				
				If aComplex[2] == "documentos"
					nOccurs := 1
				ElseIf aComplex[2] == "DocumentHeader"
					nOccurs := 1
				ElseIf aComplex[2] == "AccountGL"
					nOccurs := xTotCT2(cAliasCT2)//Pega o Total de Registro
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
				
			If (cAliasQry)->Z7_XOPESAP <> 2 
				If (cAliasCT2)->(!Eof())
				
					//--------------------------------------------------------Adicionar campos Nescessarios
					cXDiv := Right( AllTrim(xEncCGC((cAliasCT2)->CT2_FILIAL)), 4 )
					
					// Define o valor de cada parâmeto necessário
					nPos := aScan( aSimple, {|aVet| aVet[2] == "sistema" } )
					xRet := oWsdl:SetValue( aSimple[nPos][1], "TOTVS" )	//sistema
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","sistema Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
		
					nPos := aScan( aSimple, {|aVet| aVet[2] == "data" } )
					xRet := oWsdl:SetValue( aSimple[nPos][1], left( fwTimeStamp( 5 ) , 10 ) )	//data
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","data Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
		
					nPos := aScan( aSimple, {|aVet| aVet[2] == "hora" } )
					xRet := oWsdl:SetValue( aSimple[nPos][1], Time() )	//hora
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","hora Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
		
					nPos := aScan( aSimple, {|aVet| aVet[2] == "idLote" } )
					xRet := oWsdl:SetValue( aSimple[nPos][1], AllTrim(Str(Val((cAliasQry)->Z7_XLOTE))))	//idLote
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","idLote Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
		
					nPos := aScan( aSimple, {|aVet| aVet[2] == "empresa" } )
					xRet := oWsdl:SetValue( aSimple[nPos][1], SUBSTR((cAliasCT2)->CT2_FILIAL,1,4) )	//empresa
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","empresa Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
		
					nPos := aScan( aSimple, {|aVet| aVet[2] == "divisao" } )
					xRet := oWsdl:SetValue( aSimple[nPos][1], cXDiv )	//divisao ???
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","divisao Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
		
					nPos := aScan( aSimple, {|aVet| aVet[2] == "filial" } )
					xRet := oWsdl:SetValue( aSimple[nPos][1], RIGHT((cAliasCT2)->CT2_FILIAL, 4) )	//filial
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","filial Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
		
					nPos := aScan( aSimple, {|aVet| aVet[2] == "dataDocumento" } )
					xRet := oWsdl:SetValue( aSimple[nPos][1], xDtSap((cAliasCT2)->CT2_DATA))	//dataDocumento
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","dataDocumento Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf

					cTipoDoc := IIf((cAliasCT2)->CT2_LOTE == "008820","OS","IS")
					nPos := aScan( aSimple, {|aVet| aVet[2] == "tipoDocumento" } )
					xRet := oWsdl:SetValue( aSimple[nPos][1], cTipoDoc) 	//tipoDocumento
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","tipoDocumento Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
		
					nPos := aScan( aSimple, {|aVet| aVet[2] == "dataLancamentoDocumento" } )
					xRet := oWsdl:SetValue( aSimple[nPos][1], xDtSap((cAliasCT2)->CT2_DATA) )	//dataLancamentoDocumento
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","dataLancamentoDocumento Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
					
					//cNota := Subs((cAliasCT2)->CT2_KEY,FWGETTAMFILIAL+1,TamSX3("F1_DOC")[1]) 
					//cSerie := Subs((cAliasCT2)->CT2_KEY,FWGETTAMFILIAL+TamSX3("F1_DOC")[1]+1,TamSX3("F1_SERIE")[1])
					nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroDocumentoReferencia" } )
					//xRet := oWsdl:SetValue( aSimple[nPos][1], IIf((cAliasCT2)->CT2_LOTE $ "008810/008820",Alltrim(cNota)+IIf(Empty(cSerie),"","/"+Alltrim(cSerie)),(cAliasCT2)->(CT2_LOTE+CT2_SBLOTE+CT2_DOC)) )	//numeroDocumentoReferencia
					xRet := oWsdl:SetValue( aSimple[nPos][1], IIf((cAliasCT2)->CT2_LOTE $ "008810/008820",Alltrim(cNota)+IIf(Empty(cSerie),"","/"+Alltrim(cSerie)),Subs((cAliasCT2)->CT2_DATA,3,6)+(cAliasCT2)->CT2_LOTE+Right((cAliasCT2)->CT2_DOC,4)) )	//numeroDocumentoReferencia 
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","numeroDocumentoReferencia Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
		
					nPos := aScan( aSimple, {|aVet| aVet[2] == "chaveCabecalho1" } )
					xRet := oWsdl:SetValue( aSimple[nPos][1], " " )	//chaveCabecalho1 - EM BRANCO 
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","chaveCabecalho1 Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
		
					nPos := aScan( aSimple, {|aVet| aVet[2] == "chaveCabecalho2" } )
					//xRet := oWsdl:SetValue( aSimple[nPos][1], "T" + (cAliasCT2)->(CT2_LOTE+CT2_SBLOTE+CT2_DOC) )	//chaveCabecalho2
					xRet := oWsdl:SetValue( aSimple[nPos][1], "T" + allTrim(str((cAliasQry)->SZ7_RECNO)) )	//chaveCabecalho2
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","chaveCabecalho2 Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
		
					cUsu := Alltrim(Subs((cAliasCT2)->CT2_ORIGEM,9,15)) 
					nPos := aScan( aSimple, {|aVet| aVet[2] == "textoCabecalhoDocumento" } )
					xRet := oWsdl:SetValue( aSimple[nPos][1] , Substr( IIf(!Empty((cAliasCT2)->CT2_XNOME),Alltrim((cAliasCT2)->CT2_XNOME),IIf(!Empty(cUsu),cUsu,Embaralha((cAliasCT2)->CT2_USERGI))),1,25))
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","textoCabecalhoDocumento Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
		
					nPos := aScan( aSimple, {|aVet| aVet[2] == "motivoOperacao" } )//"1" - Lançamento / "2" Estorno/Cancelamento
					xRet := oWsdl:SetValue( aSimple[nPos][1], "1" )
					If !xRet
						U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","motivoOperacao Erro: " + oWsdl:cError)
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
					
					lContCT2 := .T.
					nz		 := 1
					While (cAliasCT2)->(!Eof()) .and. lContCT2
	
						nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroItemDocumentoContabilidade" .and. aVet[5] == "ContabilRequest#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } )//numeroItemDocumentoContabilidade
						xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim(Str(Val((cAliasCT2)->CT2_LINHA))) )	
						If !xRet
							U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","numeroItemDocumentoContabilidade Erro: " + oWsdl:cError)
							lContCT2 := .F.
							Exit
						EndIf
	
						nPos := aScan( aSimple, {|aVet| aVet[2] == "contaRazaoContabilidadeGeral" .and. aVet[5] == "ContabilRequest#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } )//contaRazaoContabilidadeGeral EM BRanco
						xRet := oWsdl:SetValue( aSimple[nPos][1], " " )	
						If !xRet
							U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","contaRazaoContabilidadeGeral Erro: " + oWsdl:cError)
							lContCT2 := .F.
							Exit
						EndIf
	
						nPos := aScan( aSimple, {|aVet| aVet[2] == "divisao" .and. aVet[5] == "ContabilRequest#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } )// divisao DE X PARA – TOTVS FILIAL X DIVISÃO ????
						xRet := oWsdl:SetValue( aSimple[nPos][1], cXDiv   )
						If !xRet
							U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","divisao Erro: " + oWsdl:cError)
							lContCT2 := .F.
							Exit
						EndIf
	
						nPos := aScan( aSimple, {|aVet| aVet[2] == "textoItem" .and. aVet[5] == "ContabilRequest#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } )//textoItem
						xRet := oWsdl:SetValue( aSimple[nPos][1], (cAliasCT2)->CT2_HIST )	
						If !xRet
							U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","textoItem Erro: " + oWsdl:cError)
							lContCT2 := .F.
							Exit
						EndIf
	
						nPos := aScan( aSimple, {|aVet| aVet[2] == "tipoDocumento" .and. aVet[5] == "ContabilRequest#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } )//tipoDocumento Será herdado do cabeçalho ???
						xRet := oWsdl:SetValue( aSimple[nPos][1], cTipoDoc)
						If !xRet
							U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","tipoDocumento Erro: " + oWsdl:cError)
							lContCT2 := .F.
							Exit
						EndIf
	
						If (cAliasCT2)->CT2_DC == "1"//Debito	
			
							nPos := aScan( aSimple, {|aVet| aVet[2] == "ContaRazaoDebito" .and. aVet[5] == "ContabilRequest#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } ) //ContaRazaoDebito
							xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim((cAliasCT2)->CT2_DEBITO) )
							If !xRet
								U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","ContaRazaoDebito Erro: " + oWsdl:cError)
								lContCT2 := .F.
								Exit
							EndIf
							
							If !Empty((cAliasCT2)->CT2_CCD)
								nPos := aScan( aSimple, {|aVet| aVet[2] == "centroCusto" .and. aVet[5] == "ContabilRequest#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } )//centroCusto
								xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim((cAliasCT2)->CT2_CCD))	
								If !xRet
									U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","centroCusto Erro: " + oWsdl:cError)
									lContCT2 := .F.
									Exit
								EndIf
							EndIf
							
							If !Empty((cAliasCT2)->CT2_CLVLDB)
								nPos := aScan( aSimple, {|aVet| aVet[2] == "centroLucro" .and. aVet[5] == "ContabilRequest#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } )//centroLucro
								xRet := oWsdl:SetValue( aSimple[nPos][1], IIf(Empty((cAliasCT2)->CT2_CCD),Alltrim((cAliasCT2)->CT2_CLVLDB)," "))	
								If !xRet
									U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","centroLucro Erro: " + oWsdl:cError)
									lContCT2 := .F.
									Exit
								EndIf
							EndIf
							
							nPos := aScan( aSimple, {|aVet| aVet[2] == "montanteMoedaDocumento" .and. aVet[5] == "ContabilRequest#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } )//montanteMoedaPagamento
							xRet := oWsdl:SetValue( aSimple[nPos][1], allTrim( str( (cAliasCT2)->CT2_VALOR )))	
							If !xRet
								U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","montanteMoedaDocumento Erro: " + oWsdl:cError)
								lContCT2 := .F.
								Exit
							EndIf
			
						EndIf
	
						If (cAliasCT2)->CT2_DC == "2"//Credito
							
							nPos := aScan( aSimple, {|aVet| aVet[2] == "ContaRazaoCredito" .and. aVet[5] == "ContabilRequest#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } )//ContaRazaoCredito
							xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim((cAliasCT2)->CT2_CREDIT) )
							If !xRet
								U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","ContaRazaoCredito Erro: " + oWsdl:cError)
								lContCT2 := .F.
								Exit
							EndIf
							
							If !Empty((cAliasCT2)->CT2_CCC)
								nPos := aScan( aSimple, {|aVet| aVet[2] == "centroCusto" .and. aVet[5] == "ContabilRequest#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } )//centroCusto
								xRet := oWsdl:SetValue( aSimple[nPos][1], Alltrim((cAliasCT2)->CT2_CCC))	//
								If !xRet
									U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","centroCusto Erro: " + oWsdl:cError)
									lContCT2 := .F.
									Exit
								EndIf
							EndIf
							
							If !Empty((cAliasCT2)->CT2_CLVLCR)
								nPos := aScan( aSimple, {|aVet| aVet[2] == "centroLucro" .and. aVet[5] == "ContabilRequest#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } )//centroLucro
								xRet := oWsdl:SetValue( aSimple[nPos][1], IIf(Empty((cAliasCT2)->CT2_CCC),Alltrim((cAliasCT2)->CT2_CLVLCR)," "))	
								If !xRet
									U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","centroLucro Erro: " + oWsdl:cError)
									lContCT2 := .F.
									Exit
								EndIf
							EndIf
			
							nPos := aScan( aSimple, {|aVet| aVet[2] == "montanteMoedaDocumento" .and. aVet[5] == "ContabilRequest#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } )//montanteMoedaPagamento
							xRet := oWsdl:SetValue( aSimple[nPos][1], allTrim( str( (cAliasCT2)->CT2_VALOR * -1 )))	
							If !xRet
								U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","montanteMoedaDocumento Erro: " + oWsdl:cError)
								lContCT2 := .F.
								Exit
							EndIf
			
						EndIf
	
						nPos := aScan( aSimple, {|aVet| aVet[2] == "numeroAtribuicao" .and. aVet[5] == "ContabilRequest#1.documentos#1.AccountGL#" + Alltrim(Str(nz)) } )//numeroAtribuicao
						//xRet := oWsdl:SetValue( aSimple[nPos][1], IIf((cAliasCT2)->CT2_LOTE $ "008810/008820",cNota+IIf(Empty(cSerie),"","/"+cSerie),(cAliasCT2)->(CT2_LOTE+CT2_SBLOTE+CT2_DOC)))
						xRet := oWsdl:SetValue( aSimple[nPos][1], IIf((cAliasCT2)->CT2_LOTE $ "008810/008820",cNota+IIf(Empty(cSerie),"","/"+cSerie),Subs((cAliasCT2)->CT2_DATA,3,6)+(cAliasCT2)->CT2_LOTE+Right((cAliasCT2)->CT2_DOC,4)))
						If !xRet
							U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","numeroAtribuicao Erro: " + oWsdl:cError)
							lContCT2 := .F.
							Exit
						EndIf
						nz ++
						(cAliasCT2)->(dbSkip())
					EndDo
					
					If !lContCt2
						(cAliasQry)->(dbSkip())
						Loop
					EndIf
					//--------------------------------------------------------Fim Campos
				Else
					Help("",1,"Envio movimento SAP",,"Movimento contabilizado com inconsistência.",1,0)	
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","[CMVSAP08] - Envio movimento SAP, Movimento contabilizado com inconsistência."," ")
					(cAliasQry)->(dbSkip())
					Loop
				EndIf
				//Tratamento do XML de Envio
				cMsgSoap := oWsdl:GetSoapMsg()
				cMsgSoap	:= fwNoAccent( cMsgSoap )
				cMsgSoap	:= encodeUtf8( cMsgSoap )				
	
			EndIf
			
			if !empty( cMsgSoap )
				// Envia a mensagem SOAP ao servidor
				xRet := oWsdl:SendSoapMsg( cMsgSoap /*cMsg*/)
				
				If !xRet 
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"E","SendSoapMsg Erro: " + oWsdl:cError,cMsgSoap)
					(cAliasQry)->(dbSkip())
					Loop
				Else
					// Recupera os elementos de retorno, já parseados
					cResp := oWsdl:GetParsedResponse()				
					U_ZF12GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,"A",cResp,cMsgSoap)
					
					//Exclusão SAP
					If !(cAliasQry)->Z7_XOPESAP == 2
						// se envio foi com sucesso, verifica se jah tem registro gerado de cancelamento na sz7, e caso tenha grava o xml para envio
						U_ZF17GENSAP((cAliasQry)->Z7_FILIAL,(cAliasQry)->Z7_XTABELA,(cAliasQry)->Z7_XCHAVE,(cAliasQry)->Z7_XSEQUEN,cMsgSoap)
					Endif	
				EndIf
			EndIf
		else
			If lIsBlind
				Conout("Erro de Conexão CMVSAP08 Error Http: " + Str(nStatuHttp) )
			else
				Alert("Erro de Conexão Error Http: " + Str(nStatuHttp) )
			endif
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	
	IF lIsBlind
		RpcClearEnv()
		Conout("Conexão finalizada com sucesso : CMVSAP08 " + DTOC(dDATABASE) + " - " + TIME() )
	Endif	
	
return

/*
=======================================================================================
Programa.:              xQryCt2
Autor....:              CAOA
Data.....:                /  /   
Descricao / Objetivo:   
=======================================================================================
*/

Static Function xQryCt2(cxFil,cxChav)
	
	Local cNextAlias := GetNextAlias()
	local cQry		 := ""
	
	//Montagem da Query para Extração dos dados
	cQry := " SELECT " + CRLF
	cQry += " CT2.CT2_CCC    , " + CRLF
	cQry += " CT2.CT2_CCD    , " + CRLF
	cQry += " CT2.CT2_CLVLCR , " + CRLF
	cQry += " CT2.CT2_CLVLDB , " + CRLF
	cQry += " CT2.CT2_CREDIT , " + CRLF
	cQry += " CT2.CT2_DATA   , " + CRLF
	cQry += " CT2.CT2_DC     , " + CRLF
	cQry += " CT2.CT2_DEBITO , " + CRLF
	cQry += " CT2.CT2_DOC    , " + CRLF
	cQry += " CT2.CT2_FILIAL , " + CRLF
	cQry += " CT2.CT2_HIST   , " + CRLF
	cQry += " CT2.CT2_LINHA  , " + CRLF
	cQry += " CT2.CT2_LOTE   , " + CRLF
	cQry += " CT2.CT2_SBLOTE , " + CRLF
	cQry += " CT2.CT2_VALOR  , " + CRLF
	cQry += " CT2.CT2_XNOME  , " + CRLF
	cQry += " CT2.CT2_KEY  	 , " + CRLF
	cQry += " CT2.CT2_ORIGEM , " + CRLF
	cQry += " CT2.CT2_USERGI   " + CRLF
	cQry += " FROM " + RetSqlName("CT2") + " CT2  " + CRLF
	cQry += " WHERE  " + CRLF
	cQry += " CT2.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " 	AND CT2.CT2_FILIAL = '" + cxFil + "' "
	cQry += " 	AND CT2.CT2_DATA || CT2.CT2_LOTE || CT2.CT2_SBLOTE || CT2.CT2_DOC = '" + Alltrim(cxChav)  + "' "
	cQry += " 	AND CT2.CT2_TPSALD = '1' " 
	cQry += " ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA "

	cQry := ChangeQuery(cQry)     

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cNextAlias, .F., .T.)
	
Return cNextAlias

/*
=======================================================================================
Programa.:              xTotCT2
Autor....:              CAOA
Data.....:                /  /   
Descricao / Objetivo:   
=======================================================================================
*/

Static Function xTotCT2(cQry)
	
	Local nRet := 0
	
	(cQry)->(dbGoTop())
	While (cQry)->(!Eof())
		nRet ++
		(cQry)->(dbSkip())
	EndDo
	
	(cQry)->(dbGoTop())
	
	if nRet <= 0
		nRet := 1	
	endIf
	
return nRet


/*
=======================================================================================
Programa.:              xDtSap
Autor....:              CAOA
Data.....:                /  /   
Descricao / Objetivo:   Tratar data de AAAAMMDD para AAAA-MM-DD
=======================================================================================
*/

Static Function xDtSap(cData)
	cRet := SubStr(cData,1,4) + "-" + SubStr(cData,5,2) + "-" + SubStr(cData,7,2)
return cRet


/*
=======================================================================================
Programa.:              xEncCGC
Autor....:              CAOA
Data.....:                /  /   
Descricao / Objetivo:   Encontra o CGC da Filial
=======================================================================================
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

/*
=======================================================================================
Programa.:              xCMVSA08
Autor....:              CAOA
Data.....:                /  /   
Descricao / Objetivo:   chamada via job por arquivo .INI
=======================================================================================
*/
user function xCMVSA08(xParam1,xParam2,xParam3)
// PARA REALIZAR TESTES
 //U_xCMVSA08(xParam1,xParam2,xParam3)
xParam1 := '01'
xParam2 := '2010022001'
xParam3 := '0'

U_CMVSAP08({{xParam1,xParam2,Val(xParam3)}})

Return()
