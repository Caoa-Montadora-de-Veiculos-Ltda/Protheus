#Include "Protheus.ch"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"

static _aErr

/*
=============================================================================================================
Programa.:              CMVSAP06
Autor....:              Julio Sousa
Data.....:              25/09/18
Descricao / Objetivo:   WS Server de Retorno das Integrações
Doc. Origem:            MIT044 - R03PT - Especificação de Personalização - SAP - 06 - Retorno das Integrações
Solicitante:            CAOA
Uso......:              
Obs......:				11/04/22 - A.Carlos - _cFilial Filial p/ acesso a Base da Empresa
==============================================================================================================
*/                     

WSSTRUCT SAP06_RETORNO
	WSDATA STATUS  as String
	WSDATA MSG	   as String
ENDWSSTRUCT


*************************************************************************************************************************************
WSStruct SAP06_DADOS
	*************************************************************************************************************************************
	WsData Usuario					As String OPTIONAL
	WsData Senha					As String OPTIONAL
	WsData Empresa					As String
	WsData Exercicio 				As String
	WsData Filial					As String
	WsData Divisao					As String
	WsData DocumentoIdentificador	As String
	WsData Interface			    As String			//1=Cliente 2=Fornecedor 3=Contas Receber 4=Contas Pagar
	WsData CodigoParceiro			As String
	WsData CodigoSAP				As String
	WsData Status					As String			//1=Sucesso 2=Erro
	WsData Mensagem					As String
	WsData Tipo 					As String OPTIONAL
	WsData Data            			As String OPTIONAL
	WsData Lote            			As String OPTIONAL
	WsData Valor                    As Float  OPTIONAL

EndWSStruct


*************************************************************************************************************************************
WSService CMVSAP06 Description "Retorno de Integração SAP" namespace "http://www.totvs.com.br/CMVSAP06"
*************************************************************************************************************************************
	WSDATA WSDADOS	 as SAP06_DADOS
	WSDATA WSRETORNO as SAP06_RETORNO
	WSMETHOD RetornoSAP DESCRIPTION "Executa o retorno da informações do SAP"

EndWsService

WsMethod RetornoSAP WsReceive WSDADOS WsSend WSRETORNO WsService CMVSAP06
	Local _cEmpresa  := ""   // Código da Empresa que deseja manipular
	Local _cFilial   := ""   // Código da Filial que deseja manipular
	Local _nMat      := 0    //Controlar qtde de Empresas a varrer p/ Clientes/Fornecedores
    Local _aMatriz   := {}  
    Local bError     := ErrorBlock( { |oError| MyError( oError ) } )
    Private aRetorno := {}

    AADD(_aMatriz,{"01","2010022001"}) //--Montadora
	AADD(_aMatriz,{"02","2020012001"}) //--Barueri

	IF ::WSDADOS:Interface $ "1|2|"

		FOR _nMat := 1 to Len(_aMatriz)

          	_cEmpresa := _aMatriz[_nMat][1]
		    _cFilial  := _aMatriz[_nMat][2]

            xAbrEmp(_cEmpresa,_cFilial) //Abertura de Empresa

			BEGIN SEQUENCE

				//Retorno de Integração
				If ::WSDADOS:Interface $ "1|2|3|4|5|6" .AND. ::WSDADOS:Status $ "0|1|2" //1=Sucesso, 2=Erro
					AaDD( aRetorno, U_ZF16GENSAP(_cFilial,;				
									::WSDADOS:CodigoParceiro,;
									::WSDADOS:Status        ,;
									::WSDADOS:CodigoSAP     ,;
									::WSDADOS:Mensagem      ,;
									::WSDADOS:Interface      ) )
				EndIf

				//Baixa de Titulos
				If ::WSDADOS:Interface $ "7|8"
					AaDD( aRetorno, xBaixTit(_cFilial,;//Filial Chumabada para POC
									::WSDADOS:CodigoParceiro,;
									::WSDADOS:Interface) )
				EndIf
				RECOVER
				Conout('Problema Ocorreu as Horas: ' + TIME() )
			END SEQUENCE

			ErrorBlock( bError )

		NEXT

    ELSE

		If ::WSDADOS:Divisao = '0177'       //Montadora Anápolis
			_cEmpresa := "01"
			_cFilial  := "2010022001"
		ELSEIf ::WSDADOS:Divisao = '0509'   //Distribuidora Barueri
			_cEmpresa := "02"
			_cFilial  := "2020012001"
		Endif

		xAbrEmp(_cEmpresa,_cFilial) //Abertura de Empresa

		BEGIN SEQUENCE

			//Retorno de Integração
			If ::WSDADOS:Interface $ "1|2|3|4|5|6" .AND. ::WSDADOS:Status $ "0|1|2" //1=Sucesso, 2=Erro
				aRetorno := U_ZF16GENSAP(_cFilial,;				
							::WSDADOS:CodigoParceiro,;
							::WSDADOS:Status        ,;
							::WSDADOS:CodigoSAP     ,;
							::WSDADOS:Mensagem      ,;
							::WSDADOS:Interface      )
			EndIf

			//Baixa de Titulos
			If ::WSDADOS:Interface $ "7|8"
				aRetorno := xBaixTit(_cFilial,;//Filial Chumabada para POC
				::WSDADOS:CodigoParceiro,;
				::WSDADOS:Interface)
			EndIf
			RECOVER
			Conout('Problema Ocorreu as Horas: ' + TIME() )
		END SEQUENCE

		ErrorBlock( bError )

	ENDIF

	If ValType(_aErr) == 'A'
		aRetorno := _aErr
	EndIf

	::WSRETORNO := WSClassNew( "SAP06_RETORNO")

	If Len(aRetorno[1]) > 1

		If aRetorno[1][1] == aRetorno[2][1]		
			::WSRETORNO:STATUS  := aRetorno[1][1]
			::WSRETORNO:MSG	    := aRetorno[1][2]
		ElseIf aRetorno[1][1] == "1"
			::WSRETORNO:STATUS  := aRetorno[1][1]
			::WSRETORNO:MSG	    := aRetorno[1][2]
		ElseIf aRetorno[2][1] == "1"		
			::WSRETORNO:STATUS  := aRetorno[2][1]
			::WSRETORNO:MSG	    := aRetorno[2][2]
		EndIf

	ElseIf !Empty(aRetorno)
		::WSRETORNO:STATUS  := aRetorno[1]
		::WSRETORNO:MSG	    := aRetorno[2]
	EndIf

Return .T.

//Preparar a abertura da Empresa
Static Function xAbrEmp(_cEmpresa,_cFilial)

	RpcClearEnv()
	RPCSetType(3)
	RpcSetEnv(_cEmpresa, _cFilial,,,,GetEnvServer(),{ })

Return

Static Function xBaixTit(cxFil,cChave,cInterface)

	Local aArea := {GetArea()}
	Local aRet := {"1","OK"}
	Local nRecSZ7 := 0
	Local cPref := ""
	Local cTit := ""
	Local cParc := Space(TamSX3("E1_PARCELA")[1])
	Local cCliFor := ""
	Local cLoja := ""
	Local lFound := .F.
	Local nRecTit := 0
	Local cTiposFin := GetMv("CAOASAP12D",,"NF/DP")

	If SubStr(cChave,1,1) == "T"
		//nRecSZ7 := cValToChar(SubStr(cChave,2))
		nRecSZ7 := Val(Subs(cChave,2,IIf(At("P",cChave)>0,At("P",cChave)-2,TamSX3("Z7_XCHAVE")[1])))

		// tratamento para parcela do contas a receber, pois no envio a parcela eh sempre enviada com 0 a esquerda
		If cInterface == "7"
			If At("P",cChave) > 0
				cParc := StrZero(Val(Subs(cChave,At("P",cChave)+1,TamSX3("E1_PARCELA")[1])),TamSX3("E1_PARCELA")[1])
			Endif
		Endif
	Else
		nRecSZ7 := Val(cChave)
	EndIf

	If !Empty(nRecSZ7)
		SZ7->(dbGoto(nRecSZ7))
		If SZ7->(Recno()) == nRecSZ7
			If SZ7->Z7_XTABELA $ "SE1/SE2"
				nRecTit := SZ7->Z7_RECORI
			Else
				cTit := Subs(SZ7->Z7_XCHAVE,1,TamSX3("E1_NUM")[1])
				cPref := Subs(SZ7->Z7_XCHAVE,TamSX3("E1_NUM")[1]+1,TamSX3("E1_PREFIXO")[1])
				cCliFor := Subs(SZ7->Z7_XCHAVE,TamSX3("E1_NUM")[1]+TamSX3("E1_PREFIXO")[1]+1,TamSX3("E1_CLIENTE")[1])
				cLoja := Subs(SZ7->Z7_XCHAVE,TamSX3("E1_NUM")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_CLIENTE")[1]+1,TamSX3("E1_LOJA")[1])
			Endif

			If cInterface == "7"
				SE1->(dbSetOrder(2))
				If !Empty(nRecTit)
					SE1->(dbGoto(nRecTit))
				Endif
				If IIf(!Empty(nRecTit),SE1->(Recno()) == nRecTit,.T.)
					If !Empty(nRecTit)
						cTit := SE1->E1_NUM
						cPref := SE1->E1_PREFIXO
						cCliFor := SE1->E1_CLIENTE
						cLoja := SE1->E1_LOJA
					Endif
					If SE1->(dbSeek(SZ7->Z7_FILIAL+cCliFor+cLoja+cPref+cTit))
						While SE1->(!Eof()) .and. SZ7->Z7_FILIAL+cCliFor+cLoja+cPref+cTit == ;
								SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
							If cParc == IIf(Empty(cParc),SE1->E1_PARCELA,StrZero(Val(SE1->E1_PARCELA),TamSX3("E1_PARCELA")[1]))
								//If SE1->E1_TIPO == MVNOTAFIS .or. SE1->E1_TIPO == "NCC" // .or. SE1->E1_TIPO $ MVPROVIS
								If Alltrim(SE1->E1_TIPO) $ cTiposFin .or. SE1->E1_TIPO == "NCC" // .or. SE1->E1_TIPO $ MVPROVIS
									lFound := .T.

									If !Empty(SE1->E1_BAIXA)
										aRet := {"2","Título a receber já baixado anteriormente."}
										Exit
									Endif

									If RecLock("SE1", .F.)
										SE1->E1_BAIXA := dDataBase
										SE1->E1_SALDO := 0
										SE1->E1_MOVIMEN := dDataBase
										SE1->E1_STATUS := "B"
										SE1->(msUnLock())
									EndIf

									U_ZF11GENSAP(cxFil			 ,; //Filial
									"SE1"			 ,;	//Tabela
									"2"				 ,;	//Indice Utilizado
									SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO		 ,;	//Chave
									4				 ,;	//Operação Protheus 1=Inclusao/2=Alteração/3=exclusao/4=Baixa
									3				 ,;	//Operação SAP 1=Inclusao/2=cancelamento/3=Baixa
										/*cXMLSZ7*/		 ,;
									"O"				 ,;
										""				 ,;
										{"CMVSAP06",SZ7->Z7_DOCORI,SZ7->Z7_SERORI,SZ7->Z7_RECORI,"",0,"",SZ7->Z7_XLOTE,SZ7->Z7_CLIFOR,SZ7->Z7_LOJA})
									Exit
								Elseif SE1->E1_TIPO == MVPROVIS .or. SE1->E1_TIPO == MVRECANT
									lFound := .T.

									If !Empty(SE1->E1_BAIXA)
										aRet := {"2","Título a receber já baixado anteriormente."}
										Exit
									Endif

									If !Empty(SE1->E1_MOVIMEN)
										If RecLock("SE1", .F.)
											SE1->E1_BAIXA := dDataBase
											SE1->E1_SALDO := 0
											SE1->E1_STATUS := "B"
											SE1->(msUnLock())
										EndIf
									Else
										// atualizacao de dados no sigavei, chamar esta rotina antes de alterar o tipo da SE1,
										// pois o tipo atual eh campo chave para identificar o registro no sigavei
										AtuVei()
										If RecLock("SE1", .F.)
											SE1->E1_MOVIMEN := dDataBase
											SE1->E1_TIPO := "RA "
											SE1->(msUnLock())
										EndIf
									Endif

									U_ZF11GENSAP(cxFil			 ,; //Filial
									"SE1"			 ,;	//Tabela
									"2"				 ,;	//Indice Utilizado
									SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+/*SE1->E1_TIPO*/"PR "		 ,;	//Chave //OBS: forcar o tpo "PR " na chave, pois o titulo muda de tipo e no segundo registro a ser gravado na sz7 o tipo ficaria "RA "
									4				 ,;	//Operação Protheus 1=Inclusao/2=Alteração/3=exclusao/4=Baixa
									3				 ,;	//Operação SAP 1=Inclusao/2=cancelamento/3=Baixa
										/*cXMLSZ7*/		 ,;
									"O"				 ,;
										IIf(Empty(SE1->E1_BAIXA),"Retorno da baixa do RA.","Retorno da compensação do RA."),;
										{"CMVSAP06",SZ7->Z7_DOCORI,SZ7->Z7_SERORI,SZ7->Z7_RECORI,"",0,"",SZ7->Z7_XLOTE,SZ7->Z7_CLIFOR,SZ7->Z7_LOJA})
									Exit
								Endif
							Endif
							SE1->(dbSkip())
						Enddo
					Endif
				Endif
			ElseIf cInterface == "8"
				SE2->(dbSetOrder(6))
				If !Empty(nRecTit)
					SE2->(dbGoto(nRecTit))
				Endif
				If IIf(!Empty(nRecTit),SE2->(Recno()) == nRecTit,.T.)
					If !Empty(nRecTit)
						cTit := SE2->E2_NUM
						cPref := SE2->E2_PREFIXO
						cCliFor := SE2->E2_FORNECE
						cLoja := SE2->E2_LOJA
					Endif
					If SE2->(dbSeek(SZ7->Z7_FILIAL+cCliFor+cLoja+cPref+cTit))
						While SE2->(!Eof()) .and. SZ7->Z7_FILIAL+cCliFor+cLoja+cPref+cTit == ;
								SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM
							If SE2->E2_TIPO == MVNOTAFIS ; // titulos normais
								.or. SE2->E2_TIPO == "NDF" ; // devolucao
								.or. U_ZF01GENSAP() ; // origem modulos average
								.or. (SE2->E2_PREFIXO == "ICM" .and. Alltrim(SE2->E2_TIPO) == "TX") // GNRE

								lFound := .T.

								If !Empty(SE2->E2_BAIXA)
									aRet := {"2","Título a pagar já baixado anteriormente."}
									Exit
								Endif

								If RecLock("SE2", .F.)
									SE2->E2_BAIXA := dDataBase
									SE2->E2_SALDO := 0
									SE2->E2_MOVIMEN := dDataBase
									SE2->(msUnLock())
								EndIf

								U_ZF11GENSAP(cxFil			 ,; //Filial
								"SE2"			 ,;	//Tabela
								"1"				 ,;	//Indice Utilizado
								SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA		 ,;	//Chave
								4				 ,;	//Operação Protheus 1=Inclusao/2=Alteração/3=exclusao/4=Baixa
								3				 ,;	//Operação SAP 1=Inclusao/2=cancelamento/3=Baixa
									/*cXMLSZ7*/		 ,;
								"O"				 ,;
									""				 ,;
									{"CMVSAP06",SZ7->Z7_DOCORI,SZ7->Z7_SERORI,SZ7->Z7_RECORI,"",0,"",SZ7->Z7_XLOTE,SZ7->Z7_CLIFOR,SZ7->Z7_LOJA})

								Exit
							Elseif SE2->E2_TIPO == MVPAGANT
								lFound := .T.

								If !Empty(SE2->E2_BAIXA)
									aRet := {"2","Título a pagar já baixado anteriormente."}
									Exit
								Endif

								If !Empty(SE2->E2_MOVIMEN)
									If RecLock("SE2", .F.)
										SE2->E2_BAIXA := dDataBase
										SE2->E2_SALDO := 0
										//SE2->E2_MOVIMEN := dDataBase
										SE2->(msUnLock())
									EndIf
								Else
									If RecLock("SE2", .F.)
										SE2->E2_MOVIMEN := dDataBase
										SE2->(msUnLock())
									EndIf
								Endif

								U_ZF11GENSAP(cxFil			 ,; //Filial
								"SE2"			 ,;	//Tabela
								"1"				 ,;	//Indice Utilizado
								SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA		 ,;	//Chave
								4				 ,;	//Operação Protheus 1=Inclusao/2=Alteração/3=exclusao/4=Baixa
								3				 ,;	//Operação SAP 1=Inclusao/2=cancelamento/3=Baixa
									/*cXMLSZ7*/		 ,;
								"O"				 ,;
									IIf(Empty(SE2->E2_BAIXA),"Retorno da baixa do PA.","Retorno da compensação do PA."),;
									{"CMVSAP06",SZ7->Z7_DOCORI,SZ7->Z7_SERORI,SZ7->Z7_RECORI,"",0,"",SZ7->Z7_XLOTE,SZ7->Z7_CLIFOR,SZ7->Z7_LOJA})
								Exit
							Endif
							SE2->(dbSkip())
						Enddo
					Endif
				Endif
			Endif
		Endif
		If !lFound
			aRet := {"2","Não foi possível encontrar o título "+IIf(cInterface == "7","a receber","a pagar")+". Chave: Cliente/Fornecedor: "+cCliFor+", Loja: "+cLoja+", Prefixo: "+cPref+", Numero: "+cTit+", Parcela: "+cParc}
		Endif
	Else
		aRet := {"2","Não foi possível encontrar o Recno do registro no XML."}
	EndIf

	aEval(aArea,{|x| RestArea(x)})

Return aRet

/*
=========================================================================================
Função:              	MyError
Data.....:           	20/02/2019
Descricao / Objetivo:   Função que retorna Error Log de rotina caso ocorra algum) 
==========================================================================================
*/
Static Function MyError(oError)

	Local nQtd := MLCount(oError:ERRORSTACK)
	Local ni
	Local cEr := ''

	nQtd := IIF(nQtd > 4,4,nQtd) //Retorna as 4 linhas

	For ni:=1 to nQTd
		cEr += MemoLine(oError:ERRORSTACK,,ni)
	Next ni

	Conout( oError:Description + "Deu Erro" )
	_aErr := {'ERROR',cEr}
	BREAK

Return .T.


Static Function AchaUniNeg(cEmp,cFil)

	Local aArea := {GetArea()}
	Local cQ := ""
	Local cAliasTrb := GetNextAlias()
	Local aRet := {"",.F.}

	cQ := "SELECT XX8_UNID "
	cQ += "FROM SYS_COMPANY_CFG XX8 "
	cQ += "WHERE "
	cQ += "XX8_TIPO = '3' "
	cQ += "AND XX8_GRPEMP = '"+FWGrpCompany()+"' "
	cQ += "AND XX8_EMPR = '"+cEmp+"' "
	cQ += "AND XX8_CODIGO = '"+cFil+"' "
	cQ += "AND XX8.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)

	If (cAliasTrb)->(!Eof())
		//cRet := Alltrim((cAliasTrb)->XX8_UNID)
		aRet := {cEmp+Alltrim((cAliasTrb)->XX8_UNID)+cFil,.T.}
	Endif

	(cAliasTrb)->(dbCloseArea())

	aEval(aArea,{|x| RestArea(x)})

Return(aRet)


// rotina para atualizar dados no sigavei
// SE1 estah posicionado
Static Function AtuVei()

	Local aArea := {GetArea()}
	Local cQ := ""
	Local cAliasTrb := GetNextAlias()

	cQ := "SELECT VRL.R_E_C_N_O_ VRL_RECNO "
	cQ += "FROM "+RetSqlName("VRL")+" VRL, "+RetSqlName("SE1")+" SE1 "
	cQ += "WHERE "
	cQ += "SE1.R_E_C_N_O_ = "+Alltrim(Str(SE1->(Recno())))+" "
	cQ += "AND E1_FILIAL = VRL_FILIAL "
	cQ += "AND E1_NUM = VRL_E1NUM "
	cQ += "AND E1_PREFIXO = VRL_E1PREF "
	cQ += "AND E1_TIPO = VRL_E1TIPO "
	cQ += "AND E1_PARCELA = VRL_E1PARC "
	cQ += "AND E1_NATUREZ = VRL_E1NATU "
	cQ += "AND E1_CLIENTE = VRL_E1CLIE "
	cQ += "AND E1_LOJA = VRL_E1LOJA "
	cQ += "AND SE1.D_E_L_E_T_ = ' ' "
	cQ += "AND VRL.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)

	If (cAliasTrb)->(!Eof())
		VRL->(dbGoto((cAliasTrb)->VRL_RECNO))
		If VRL->(Recno()) == (cAliasTrb)->VRL_RECNO
			VRL->(RecLock("VRL",.F.))
			VRL->VRL_E1TIPO := "RA "
			VRL->(msUnLock())
		EndIf
	Endif

	(cAliasTrb)->(dbCloseArea())

	aEval(aArea,{|x| RestArea(x)})

Return()
