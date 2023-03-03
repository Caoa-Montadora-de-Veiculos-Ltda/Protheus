#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*
=====================================================================================
Programa.:              zFATF001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              24/06/19
Descricao / Objetivo:   Informações do TSS a partir da Serie+Doc.
Doc. Origem:            
Solicitante:            
Uso......:              Faturamento
Obs......:
=====================================================================================
*/
User Function ZFATF001(cParam01, cParam02)

Local cIdEnt     	:= ""
Local cURL       	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cAviso		:= ""
Local cSerie		:= cParam01
Local cDoc			:= cParam02
Local aParam		:= {}
Local aColab		:= {}
Local aRetorno		:= {}
Local oWS
Private lUsaColab 	:= UsaColaboracao("1")

If zIsReady(,,,lUsaColab)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem o codigo da entidade                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIdEnt := zGetIdEnt(lUsaColab)

	If !Empty(cIdEnt)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Instancia a classe                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lUsaColab

			aadd(aParam,{cSerie+cDoc})

			aColab := colNfeMonProc(aParam, 2, "55", .F., @cAviso)
			
			If Len(aColab) > 0
				If !Empty(Alltrim(aColab[1][5])) .And. !Empty(Alltrim(aColab[1][6]))
					If Empty(Alltrim(aColab[1][4]))
						Aadd( aRetorno, { 	.F.	,;													//.T. ou .F.
											""	,; 													//Versão da Mensagem de Retorno
											IIf(aColab[1][7]==1,"Produção","Homologação")	,; 		//Ambiente de Retorno
											aColab[1][5]	,; 										//Codigo de Retorno
											AllTrim(aColab[1][5])+"-"+AllTrim(aColab[1][6])	,; 		//Mensagem de Retorno
											aColab[1][4]	}) 										// Protocolo de Retorno
					Else
						Aadd( aRetorno, { 	.T.	,;													//.T. ou .F.	
											""	,; 													//Versão da Mensagem de Retorno
											IIf(aColab[1][7]==1,"Produção","Homologação")	,; 		//Ambiente de Retorno
											aColab[1][5]	,; 										//Codigo de Retorno
											AllTrim(aColab[1][5])+"-"+AllTrim(aColab[1][6])	,; 		//Mensagem de Retorno
											aColab[1][4]	}) 										// Protocolo de Retorno
					EndIf
				Else
					Aadd( aRetorno, { 	.F.	,; //.T. ou .F.
										""	,; //Versão da Mensagem de Retorno
										""	,; //Ambiente de Retorno
										""	,; //Codigo de Retorno
										"Retorno e código não encontrado no servidor TSS"	,; //Mensagem de Retorno
										""	}) // Protocolo de Retorno
				EndIf
			Else
				Aadd( aRetorno, { 	.F.	,; //.T. ou .F.
									""	,; //Versão da Mensagem de Retorno
									""	,; //Ambiente de Retorno
									""	,; //Codigo de Retorno
									"Nota fiscal não encontrado no servidor TSS"	,; //Mensagem de Retorno
									""	}) // Protocolo de Retorno
			Endif
		Else
			If !Empty(cIdEnt)

				oWs:= WsNFeSBra():New()
				oWs:cUserToken   := "TOTVS"
				oWs:cID_ENT      := cIdEnt
				oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
				oWs:cNFECONSULTAPROTOCOLOID := cDoc+cSerie
			
				If oWs:ConsultaProtocoloNfe()
					Aadd( aRetorno, { 	.T.	,;
										oWs:oWSCONSULTAPROTOCOLONFERESULT:cVERSAO	,; 		//Versão da Mensagem de Retorno
										IIf(oWs:oWSCONSULTAPROTOCOLONFERESULT:nAMBIENTE==1,"Produção","Homologação")	,;	//Ambiente de Retorno
										oWs:oWSCONSULTAPROTOCOLONFERESULT:cCODRETNFE	,; 	//Codigo de Retorno
										oWs:oWSCONSULTAPROTOCOLONFERESULT:cMSGRETNFE	,; 	//Mensagem de Retorno
										oWs:oWSCONSULTAPROTOCOLONFERESULT:cPROTOCOLO	}) 	// Protocolo de Retorno
				Else
					Aadd( aRetorno, { 	.F.	,;
										""	,; //Versão da Mensagem de Retorno
										""	,; //Ambiente de Retorno
										""	,; //Codigo de Retorno
										"Protocolo não encontrado"	,; //Mensagem de Retorno
										""	}) // Protocolo de Retorno

					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"ERRO"},3)
				EndIf
			Endif

		EndIf
	Else
		Aadd( aRetorno, { 	.F.	,;
							""	,; //Versão da Mensagem de Retorno
							""	,; //Ambiente de Retorno
							""	,; //Codigo de Retorno
							"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"	,; //Mensagem de Retorno
							""	}) // Protocolo de Retorno
	EndIf
Else
	Aadd( aRetorno, { 	.F.	,;
						""	,; //Versão da Mensagem de Retorno
						""	,; //Ambiente de Retorno
						""	,; //Codigo de Retorno
						"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"	,; //Mensagem de Retorno
						""	}) // Protocolo de Retorno
EndIf

Return(aRetorno)

/*
=====================================================================================
Programa.:              zIsReady
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              24/06/19
Descricao / Objetivo:   Valida Url do TSS.
Doc. Origem:            
Solicitante:            Faturamento
Uso......:              ZGenF001
Obs......:
=====================================================================================
*/
Static Function zIsReady(cURL,nTipo,lHelp,lUsaColab)

Local cHelp    		:= ""
local cError		:= ""
Local lRetorno 		:= .F.
DEFAULT nTipo 		:= 1
DEFAULT lHelp 		:= .F.
DEFAULT lUsaColab 	:= .F.

If !lUsaColab
   If FunName() <> "LOJA701"
   		If !Empty(cURL) .And. !PutMV("MV_SPEDURL",cURL)

		   RecLock("SX6",.T.)
				SX6->X6_FIL     := xFilial( "SX6" )
				SX6->X6_VAR     := "MV_SPEDURL"
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := "URL SPED NFe"
			SX6->(MsUnLock())
			
			PutMV("MV_SPEDURL",cURL)
		EndIf
		
		SuperGetMv() //Limpa o cache de parametros - nao retirar
		DEFAULT cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Else
		If !Empty(cURL) .And. !PutMV("MV_NFCEURL",cURL)

			RecLock("SX6",.T.)
				SX6->X6_FIL     := xFilial("SX6")
				SX6->X6_VAR     := "MV_NFCEURL"
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := "URL de comunicação com TSS"
			SX6->(MsUnLock())

			PutMV("MV_NFCEURL",cURL)
		EndIf
		SuperGetMv() //Limpa o cache de parametros - nao retirar
		DEFAULT cURL      := PadR(GetNewPar("MV_NFCEURL","http://"),250)
	EndIf
	//Verifica se o servidor da Totvs esta no ar
	If (isConnTSS(@cError))
		lRetorno := .T.
	Else
		If lHelp
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"ERRO Static Function zIsReady"},3)
		EndIf
		lRetorno := .F.
	EndIf


	//Verifica se Há Certificado configurado
	If nTipo <> 1 .And. lRetorno

		If (isCfgReady(, @cError) )
			lRetorno := .T.
		Else
			If nTipo == 3

				cHelp := cError
			
				If lHelp .And. !"003" $ cHelp
					Aviso("SPED",cHelp,{"ERRO Static Function zIsReady"},3)
					lRetorno := .F.
				EndIf
			Else
				lRetorno := .F.
			EndIf
		Endif
	EndIf

	//Verifica Validade do Certificado
	If nTipo == 2 .And. lRetorno
		isValidCert(, @cError)
	EndIf
Else
	lRetorno := ColCheckUpd()
	If lHelp .And. !lRetorno .And. !lAuto
		MsgInfo("UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0")
	EndIf
EndIf

Return(lRetorno)

/*
=====================================================================================
Programa.:              zGetIdEnt
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              24/06/19
Descricao / Objetivo:   Valida Url do TSS.
Doc. Origem:            
Solicitante:            Faturamento
Uso......:              ZGenF001
Obs......:
=====================================================================================
*/
Static Function zGetIdEnt(lUsaColab)

local cIdEnt := ""
local cError := ""

Default lUsaColab := .F.

If !lUsaColab

	cIdEnt := getCfgEntidade(@cError)

	If (Empty(cIdEnt))
		Aviso("SPED", cError, {"Erro TSS - Static Function zGetIdEnt"}, 3)
	Endif
Else
	If !( ColCheckUpd() )
		Aviso("SPED","UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0",{"Erro TSS - Static Function zGetIdEnt"},3)
	Else
		cIdEnt := "000000"
	EndIf
EndIf

Return(cIdEnt)
