#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TOTVS.ch'
#include "topconn.ch"
#include "tbiconn.ch"
#include "apwebsrv.ch"
#include "apwebex.ch"

static _aErr

/*
=====================================================================================
Programa.:              CMVSAP07
Autor....:              Joni Lima do Carmo
Data.....:              20/02/2019
Descricao / Objetivo:   WS Server de Inclusão de Lancto Contabil 
Doc. Origem:            MIT044 - R03PT - Especificação de Personalização - SAP - 07 - Contábil SAP x Protheus V3
Solicitante:            CAOA
Uso......:              Integrações SAP vs Protheus
Obs......:				WS ja deve estar com alguma filial Aberta
=====================================================================================
*/
 
WSSERVICE CMVSAP07 DESCRIPTION "Inclusão Lancto Contabil" NAMESPACE "http://www.totvs.com.br/CMVSAP07"
	
	WSDATA WSDADOS 	 as SAP07_LANCTO
	WSDATA WSRETORNO as SAP07_RETORNO
	
	WSMETHOD IncLancto DESCRIPTION "Inclusão Lancto Contabil"
	
ENDWSSERVICE


/*
=====================================================================================
Metodo:              	IncLancto
Data.....:           	20/02/2019
Descricao / Objetivo:   Metodo para Inclusão do Lancto contabil vindos do SAP
=====================================================================================
*/
WSMETHOD IncLancto WSRECEIVE WSDADOS WSSEND WSRETORNO WSSERVICE CMVSAP07
	
	Local bError 	:= ErrorBlock( { |oError| MyError( oError ) } )
	Local aRetorno	:= {}
	Local _cEmpresa := "01"
	Local _cFilAtu	:= ::WSDADOS:cabecalho:FilialProtheus
	Local cxFilial	:= "2010022001"

	BEGIN SEQUENCE
		
		cFilAnt := cxFilial
		if _cFilAtu == cxFilial

			RpcClearEnv()
			RPCSetType(3)
			RpcSetEnv(_cEmpresa, _cFilAtu,,,,GetEnvServer(),{ })
			
			Conout("[CMVSAP07] Conectando " + DTOC(dDATABASE) + " - " + TIME() )
			
			aRetorno := xIncCT2(::WSDADOS)

			Conout("[CMVSAP07] Disconetando  " + DTOC(dDATABASE) + " - " + TIME() )		
		else
		
			AADD(aRetorno, "3"	 )//Status
			AADD(aRetorno, "Empresa Protheus não encontrada" )//Msg
		
		ENDIF
	RECOVER
		Conout('Problema Ocorreu as Horas: ' + TIME() )
	END SEQUENCE
	
	ErrorBlock( bError )

	If ValType(_aErr) == 'A'
		aRetorno := _aErr
	EndIf	

	If !Empty(aRetorno)  
		::WSRETORNO:STATUS  := aRetorno[1]
		::WSRETORNO:MSG	    := aRetorno[2]
	EndIf
		
Return .T.

/*
===========================================================================================================================================
Função:              	xIncCT2 //CMVIDSAP
Data.....:           	20/02/2019
Descricao / Objetivo:   Função que recebe/Trata as informações para chamada do Execauto CTBA102 (Inclusão de lancto contabil) 
============================================================================================================================================
*/
Static Function xIncCT2(oDados)

	Local aRet		:= {}
	
	Local cLote 	:= SUPERGETMV("CMV_LCTSAP", Nil, "009900")
	Local cSubLote	:= "001"
	Local cDoc		:= ""
	Local cDocCTF	:= ""
	Local cDocCTFX  := "000001"
	Local cDocCT2	:= "000001"
	Local cErro 	:= ""
	//Local CTF_LOCK	:= 0
	
	Local nTamHis 	:= TamSX3("CT2_HIST")[1] 
	
	Local nI 		:= 0

	Local aErro 	:= {}
	Local aItem		:= {}
	Local aItens 	:= {}
	Local aCab 		:= {}
	
	//Local oSubLote
	//Local oDoc
	//Local oLote

	Local dDataLanc := StoD(oDados:cabecalho:DataLancto) 
	Local aCont		:= nil
	
	Private cFilCT1	:= "          " // xFilial("CT1")
	Private cFilCTT	:= "2010      " // xFilial("CTT")
	Private cFilCTH	:= "2010      " // xFilial("CTH")
	Private cFilCTF	:= "2010022001" // xFilial("CTF")
	Private cFilCTD := "2010      " // xFilial("CTD")
	private lMsHelpAuto     := .T. // Se .T. direciona as mensagens de help para o arq. de log
	private lMsErroAuto     := .F.
	private lAutoErrNoFile  := .T. // Precisa estar como .T. para GetAutoGRLog() retornar o array com erros
	Private lSubLote 		:= Empty(cSubLote)

	aCont := xValGer(oDados)//Validações para processeguir com o lançamento
	
	If Empty(aCont) //se a Função retornar um array em branco quer dizer que não encontrou nenhum erro
	
		//FWLogMsg("INFO", /*cTransactionId*/, "LOGSAP07", /*cCategory*/, /*cStep*/, /*cMsgId*/, CTOD(Date()) + " - Hora: " + Time() + " - Iniciando interação", /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
	
		//C050Next(dDataLanc,@cLote,@cSubLote,@cDoc,oLote,oSubLote,oDoc,@CTF_LOCK,3,1)//Função padrão para retornar SubLote e Documento		
		/*
		cQuery := "SELECT Max(CTF_DOC) MAXDOC "
		cQuery += "FROM "+RetSqlName("CTF")+" CTF "
		cQuery += "WHERE CTF_FILIAL='"+xFilial("CTF")+"' AND "
		cQuery += "CTF_DATA = '"+DTOS(dDataLanc)+"' AND "
		cQuery += "CTF_LOTE = '"+cLote+"' AND "
		cQuery += "CTF_SBLOTE = '"+cSubLote+"' AND "
		cQuery += "D_E_L_E_T_=' ' "
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPPRXDOC")

		cDoc := ("TMPPRXDOC")->MAXDOC

		dbSelectArea("TMPPRXDOC")
		("TMPPRXDOC")->(dbCloseArea())

		if empty(cDoc)
			cDoc := "000001"
		else
			cDoc := StrZero(Val(cDoc)+1,6)
		endif
		
		CT2->(DbSetOrder(1))
		While CT2->(DbSeek(FwxFilial("CT2")+oDados:cabecalho:DataLancto+cLote+cSubLote+cDoc))
			cDoc := StrZero(Val(cDoc)+1,6)
			CT2->(DbSkip())
		End
		*/

		CT2->(DbSetOrder(1))
		If CT2->(DbSeek(FwxFilial("CT2")+oDados:cabecalho:DataLancto+cLote+cSubLote))
			While CT2->CT2_FILIAL		== xFilial("CT2")						.And. ;
				  CT2->CT2_DATA			== Stod(oDados:cabecalho:DataLancto)	.And. ;
				  CT2->CT2_LOTE			== cLote								.And. ;
				  CT2->CT2_SBLOTE		== cSubLote				  
				cDocCT2 := CT2->CT2_DOC
				CT2->(DbSkip())
			EndDo
			cDocCT2 := StrZero(Val(cDocCT2)+1,6)
		Else
			cDocCT2 := "000001"
		EndIf
			
		CTF->(DbSetOrder(1))
		If CTF->(DbSeek(cFilCTF+oDados:cabecalho:DataLancto+cLote+cSubLote))
			While CTF->CTF_FILIAL		== cFilCTF      						.And. ;
				  CTF->CTF_DATA			== Stod(oDados:cabecalho:DataLancto)	.And. ;
				  CTF->CTF_LOTE			== cLote								.And. ;
				  CTF->CTF_SBLOTE		== cSubLote
				
				If CTF->CTF_USADO == 'X'
					cDocCTF := CTF->CTF_DOC
					Exit
				EndIf
				
				cDocCTFX  := CTF->CTF_DOC
				CTF->(DbSkip())
				
			EndDo
			if Empty(cDocCTF)
				cDocCTF := StrZero(Val(cDocCTFX)+1,6)
			EndIf
		Else
			cDocCTF := "000001"
		EndIf
		cDoc := If(cDocCT2 < cDocCTF , cDocCT2, cDocCTF)

		//FWLogMsg("INFO", /*cTransactionId*/, "LOGSAP07", /*cCategory*/, /*cStep*/, /*cMsgId*/, CTOD(Date()) + " - Hora: " + Time() + " - Pegando a numeraçao do cDoc: " + cDoc, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)		
		
		//Dados Cabeçalho
		AADD(aCab,{'DDATALANC' 	, dDataLanc 							,NIL})
		AADD(aCab,{'CLOTE' 		, cLote 								,NIL})
		AADD(aCab,{'CSUBLOTE' 	, cSubLote 								,NIL})
		AADD(aCab,{'CDOC' 		, cDoc									,NIL})
		AADD(aCab,{'CPADRAO' 	, '' 									,NIL})
		AADD(aCab,{'NTOTINF' 	, 0 									,NIL})
		AADD(aCab,{'NTOTINFLOT' , 0 									,NIL})		
		
		For nI := 1 to len( oDados:itens )
			
			aItem := {}
			
			//AADD(aItem,{'CT2_FILIAL' 	 , oDados:cabecalho:FilialProtheus 						, NIL})
			AADD(aItem,{'CT2_FILIAL' 	 , '2010022001' 										, NIL})
			AADD(aItem,{'CT2_LINHA'  	 , oDados:itens[nI]:Item 		   						, NIL})
			AADD(aItem,{'CT2_DC'  	 	 , oDados:itens[nI]:TipoLancto	   						, NIL})
			AADD(aItem,{'CT2_MOEDLC'	 ,'01' 							   						, NIL})
			AADD(aItem,{'CT2_TPSALD'	 ,'1' 							   						, NIL})
			AADD(aItem,{'CT2_VALOR'	  	 , oDados:itens[nI]:Valor	   			   				, NIL})
			AADD(aItem,{'CT2_ORIGEM'  	 , "INTSAP - " + dToc(dDataBase) + " - " + Time()		, NIL})
			AADD(aItem,{'CT2_XSAP' 	 	 , oDados:cabecalho:LoteSAP		 						, NIL})
			AADD(aItem,{'CT2_XANOSA' 	 , Substr(AllTrim(oDados:cabecalho:DataLancto),1,4) 	, NIL})
			AADD(aItem,{'CT2_HIST'  	 , SubStr(oDados:itens[nI]:Historico,1,nTamHis) 		, NIL})
			
			If !Empty(oDados:itens[nI]:ContaDebito)
				AADD(aItem,{'CT2_DEBITO'  , oDados:itens[nI]:ContaDebito		   	, NIL})
				
				If !Empty(oDados:itens[nI]:CNPJCliForDebito)
					AADD(aItem,{'CT2_AT01DB'  	 , xEncCod(Alltrim(oDados:itens[nI]:CNPJCliForDebito),Iif(SubStr(oDados:itens[nI]:ContaDebito,1,1) == "1","C","F"))	   , NIL})
				EndIf
			EndIf
			
			If !Empty(oDados:itens[nI]:ContaCredito)
				AADD(aItem,{'CT2_CREDIT'  , oDados:itens[nI]:ContaCredito	   		, NIL})
				
				If !Empty(oDados:itens[nI]:CNPJCliForCredito)
					AADD(aItem,{'CT2_AT01CR'  	 , xEncCod(Alltrim(oDados:itens[nI]:CNPJCliForCredito),Iif(SubStr(oDados:itens[nI]:ContaCredito,1,1) == "1","C","F"))	   , NIL})
				EndIf				
			EndIf
			
			If !Empty(oDados:itens[nI]:CentroCustoDebito)
				AADD(aItem,{'CT2_CCD'	  , oDados:itens[nI]:CentroCustoDebito		, NIL})
			EndIf
			
			If !Empty(oDados:itens[nI]:CentroCustoCredito)
				AADD(aItem,{'CT2_CCC'	  , oDados:itens[nI]:CentroCustoCredito		, NIL})
			EndIf
			If !Empty(oDados:itens[nI]:ItemContaDebito)
				AADD(aItem,{'CT2_ITEMD'   , oDados:itens[nI]:ItemContaDebito		, NIL})
			EndIf
			
			If !Empty(oDados:itens[nI]:ItemContaCredito)
				AADD(aItem,{'CT2_ITEMC'  	 , oDados:itens[nI]:ItemContaCredito	, NIL})
			EndIf
			
			If !Empty(oDados:itens[nI]:ClasseValorDebito)
				AADD(aItem,{'CT2_CLVLDB'  	 , oDados:itens[nI]:ClasseValorDebito	, NIL})
			EndIf
			
			If !Empty(oDados:itens[nI]:ClasseValorCredito)
				AADD(aItem,{'CT2_CLVLCR'  	 , oDados:itens[nI]:ClasseValorCredito	, NIL})
			EndIf
				
			AADD(aItens,aItem)
					
		Next nI
	
		//FWLogMsg("INFO", /*cTransactionId*/, "LOGSAP07", /*cCategory*/, /*cStep*/, /*cMsgId*/, CTOD(Date()) + " - Hora: " + Time() + " - Iniciando ExecAuto CTBA102", /*nMensure*/, /*nElapseTime*/, /*aMessage*/)		
	
		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)
		If lMsErroAuto <> Nil 
			If !lMsErroAuto
				CTF->(DbSetOrder(1))
			/*	If !CTF->(DbSeek(cFilCTF+oDados:cabecalho:DataLancto+cLote+cSubLote+cDoc))
				    CTF->(RecLock("CTF",.T.))
					CTF->CTF_FILIAL		:= xFilial("CTF")
					CTF->CTF_DATA		:= dDataLanc
					CTF->CTF_LOTE		:= cLote
					CTF->CTF_SBLOTE		:= cSubLote
					CTF->CTF_DOC		:= cDoc				
					CTF->(MsUnLock())
				EndIf*/	
				AADD(aRet, "1"	 )//Status
				AADD(aRet, "Lancto Incluido com Sucesso" )//Msg
				//FWLogMsg("INFO", /*cTransactionId*/, "LOGSAP07", /*cCategory*/, /*cStep*/, /*cMsgId*/, CTOD(Date()) + " - Hora: " + Time() + " - Lançamento ExecAuto CTBA102 concluido com sucesso!", /*nMensure*/, /*nElapseTime*/, /*aMessage*/)		
			Else
				aErro := GetAutoGRLog() // Retorna erro em array
				cErro := ""

				//FWLogMsg("INFO", /*cTransactionId*/, "LOGSAP07", /*cCategory*/, /*cStep*/, /*cMsgId*/, CTOD(Date()) + " - Hora: " + Time() + " - Erro no ExecAuto CTBA102", /*nMensure*/, /*nElapseTime*/, /*aMessage*/)		
		
				for nI := 1 to len(aErro)
					cErro += aErro[ nI ] + CRLF
					//FWLogMsg("INFO", /*cTransactionId*/, "LOGSAP07", /*cCategory*/, /*cStep*/, /*cMsgId*/, CTOD(Date()) + " - Hora: " + Time() + " - Erro linha: " + nI + " - Problema encontrado: " + aErro[ nI ] , /*nMensure*/, /*nElapseTime*/, /*aMessage*/)		
				next nI
				
				IF "AJUDA:" $ cErro
					AADD(aRet, "1"	 )//Status
					AADD(aRet, "Lancto Incluido com Sucesso" )//STUFF( cErro, 1, 5, "Aviso" ) )//Msg
				ELSE
					AADD(aRet, "2"	 )//Status
					AADD(aRet, cErro )//Msg
				EndIf
				Memowrite('\Data\' + cDoc + '_' + Dtos(Date()) + ".log",cErro )
	
			EndIf
		EndIf
	Else
		aRet := aCont
	EndIf

Return aRet

Static Function xValGer(oDados)
	
	Local aArea 	:= GetArea()
	Local aAreaCT1	:= CT1->(GetArea())
	
	Local lRet		:= .T.
	Local cMsgErro	:= "Erro: " + CRLF
	Local cMsgAviso	:= "Aviso: " + CRLF
	
	Local lAviso    := .F.
	Local aRet 		:= {}
	Local ni		:= 1
	Local qtdReg	:= 0
	
	Local nValDeb	:= 0
	Local nValCre	:= 0
	Local nNumLin	:= SUPERGETMV("MV_NUMLIN",Nil,996)
	
	//Variaveis para auxiliar na validação contabil
	Local cContaDebito  := ""
	Local cCustoDebito  := ""
	Local cItemDebito   := ""
	Local cCLVLDebito	:= ""
	
	Local cContaCredito := ""
	Local cCustoCredito := ""
	Local cItemCredito  := ""
	Local cCLVLCredito	:= ""
	
	dbSelectArea("CT1")
	dbSelectArea("CTT")
	dbSelectArea("CTD")
	dbSelectArea("CT2")
	dbSelectArea("CTH")

	CT2->(DbOrderNickName("CMVIDSAP"))//CT2_FILIAL+CT2_XSAP

	If Empty(oDados:cabecalho:LoteSAP)
		cMsgErro += "Lote SAP não informado" + CRLF 
		lRet	:= .F.	
	EndIf

	If Empty(oDados:cabecalho:DataLancto)
		cMsgErro += "Data do lançamento não informada" + CRLF 
		lRet	:= .F.
	EndIf

	If lRet
		If (CT2->(DbSeek( xFilial("CT2") + oDados:cabecalho:LoteSAP + Substr(AllTrim(oDados:cabecalho:DataLancto),1,4) )))
			//cMsgErro += "Lancto Contabil Já existe na base, Lote: " + Alltrim(oDados:cabecalho:LoteSAP) + CRLF 
			cMsgAviso += "Lancto Contabil Já existe na base, Lote: " + Alltrim(oDados:cabecalho:LoteSAP) + CRLF 
			lRet	:= .F.
			lAviso  := .T.
		EndIf
	EndIf
	
	If lRet
		If !(CtbValiDt( nil , StoD(oDados:cabecalho:DataLancto) ))
			cMsgErro += "O Status deste período não permite digitação. Verifique o status do calendário para essa data" + CRLF 
			lRet	:= .F.
		EndIf	
	EndIf
	
	For nI := 1 to Len( oDados:itens )
		
		//Quantidade de Linhas
		qtdReg++

		If Empty(oDados:itens[nI]:Item)
			cMsgErro += "Item não informado" + CRLF
			lRet	:= .F.			
		EndIf

		If Empty(oDados:itens[nI]:TipoLancto)
			cMsgErro += "Tipo de Lançamento não informado" + CRLF
			lRet	:= .F.			
		Else
			If !(oDados:itens[nI]:TipoLancto $ "1|2")
				cMsgErro += "Tipo de Lançamento Inconsistente, deve ser 1=Debito ou 2=Credito" + CRLF
				lRet	:= .F.					
			Else
				If oDados:itens[nI]:TipoLancto == "1"
					nValDeb	+= oDados:itens[nI]:Valor
				ElseIf oDados:itens[nI]:TipoLancto == "2"
					nValCre	+= oDados:itens[nI]:Valor
				EndIf
			EndIf  
		EndIf
		
		If oDados:itens[nI]:Valor <= 0
			cMsgErro += "Valor do lançamento deve ser maior que Zero" + CRLF
			lRet	:= .F.
		EndIf
		
		//Validação conta Debito
		If !Empty(oDados:itens[nI]:ContaDebito)
			//Para o Texto ficar no tamanho certo do dicionario para evitar falha no Seek
			cContaDebito := oDados:itens[nI]:ContaDebito
			cContaDebito := fTamSx3(cContaDebito,"CT1_CONTA")
			
			CT1->(dbSetOrder(1))//CT1_FILIAL+CT1_CONTA
			//If CT1->(dbSeek(cFilCT1 + oDados:itens[nI]:ContaDebito))
			If CT1->(dbSeek(cFilCT1 + cContaDebito))
				If CT1->CT1_BLOQ == "1"//Bloqueado
					cMsgErro += "Conta Debito Esta Bloqueada Conta:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
					lRet	:= .F.							
				EndIf
				
				If AllTrim(CT1->CT1_CONTA) $ '1120101001|1120101008|2110101001|2110101003|2110101004'
					If Empty(oDados:itens[nI]:CNPJCliForDebito)
						cMsgErro 	+= "CNPJ não informado para conta de cliente/fornecedor" + CRLF
						lRet		:= .F.					
					EndIf
				EndIf
				
				If CT1->CT1_CCOBRG == "1"
					If Empty(oDados:itens[nI]:CentroCustoDebito)
						cMsgErro += "CC está vazio, CC é Obrigatorio Nessa Conta Contabil, conta Debito:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_ITOBRG == "1"
					If Empty(oDados:itens[nI]:ItemContaDebito)
						cMsgErro += "Item Contabil está vazio, Item Contabil é Obrigatorio Nessa Conta Contabil, conta Debito:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_CLOBRG == "1"
					If Empty(oDados:itens[nI]:ClasseValorDebito)
						cMsgErro += "Classe está vazia, Classe é Obrigatorio Nessa Conta Contabil, conta Debito:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf			

				If CT1->CT1_ACCUST == "2"
					If !Empty(oDados:itens[nI]:CentroCustoDebito)
						cMsgErro += "CC está preenchido, Conta Contábil não aceita Centro de Custo, conta Debito:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_ACITEM == "2"
					If !Empty(oDados:itens[nI]:ItemContaDebito)
						cMsgErro += "Item Contabil está preenchido, Conta Contábil não aceita Item Contabil, conta Debito:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_ACCLVL == "2"
					If !Empty(oDados:itens[nI]:ClasseValorDebito)
						cMsgErro += "Classe está preenchido, Conta Contábil não aceita Classe, conta Debito:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf			
			
			Else
				cMsgErro += "Conta Debito Não Existe Conta:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
				lRet	 := .F.
			EndIf
		Else
			If oDados:itens[nI]:TipoLancto == "1"
				cMsgErro += "Conta Debito Não Informada:" + CRLF 
				lRet	 := .F.
			EndIf
		EndIf

		//Validação conta Credito
		If !Empty(oDados:itens[nI]:ContaCredito)
			//Para o Texto ficar no tamanho certo do dicionario para evitar falha no Seek
			cContaCredito := oDados:itens[nI]:ContaCredito
			cContaCredito := fTamSx3(cContaCredito,"CT1_CONTA")
			
			CT1->(dbSetOrder(1))//CT1_FILIAL+CT1_CONTA
			//If CT1->(dbSeek(cFilCT1 + oDados:itens[nI]:ContaCredito))
			If CT1->(dbSeek(cFilCT1 + cContaCredito))
				If CT1->CT1_BLOQ == "1"//Bloqueado
					cMsgErro 	+= "Conta Credito Esta Bloqueada Conta:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF
					lRet		:= .F.
				EndIf

				If AllTrim(CT1->CT1_CONTA) $ '1120101001|1120101008|2110101001|2110101003|2110101004'
					If Empty(oDados:itens[nI]:CNPJCliForCredito)
						cMsgErro 	+= "CNPJ não informado para conta de cliente/fornecedor" + CRLF
						lRet		:= .F.					
					EndIf
				EndIf

				If CT1->CT1_CCOBRG == "1"
					If Empty(oDados:itens[nI]:CentroCustoCredito)
						cMsgErro += "CC está vazio, CC é Obrigatorio Nessa Conta Contabil, conta Credito:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_ITOBRG == "1"
					If Empty(oDados:itens[nI]:ItemContaCredito)
						cMsgErro += "Item Contabil está vazio, Item Contabil é Obrigatorio Nessa Conta Contabil, conta Credito:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_CLOBRG == "1"
					If Empty(oDados:itens[nI]:ClasseValorCredito)
						cMsgErro += "Classe está vazia, Classe é Obrigatorio Nessa Conta Contabil, conta Credito:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_ACCUST == "2"
					If !Empty(oDados:itens[nI]:CentroCustoCredito)
						cMsgErro += "CC está preenchido, Conta Contábil não aceita Centro de Custo, conta Credito:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_ACITEM == "2"
					If !Empty(oDados:itens[nI]:ItemContaCredito)
						cMsgErro += "Item Contabil está preenchido, Conta Contábil não aceita Item Contabil, conta Credito:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_ACCLVL == "2"
					If !Empty(oDados:itens[nI]:ClasseValorCredito)
						cMsgErro += "Classe está preenchido, Conta Contábil não aceita Classe, conta Credito:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf			

			Else
				cMsgErro 	+= "Conta Credito Não Existe Conta:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF
				lRet		:= .F.		
			EndIf
		Else
			If oDados:itens[nI]:TipoLancto == "2"
				cMsgErro += "Conta Credito Não Informada:" + CRLF 
				lRet	 := .F.
			EndIf
		EndIf
		
		//Validação CC de Debito
		If !Empty(oDados:itens[nI]:CentroCustoDebito)
			//Para o Texto ficar no tamanho certo do dicionario para evitar falha no Seek
			cCustoDebito := oDados:itens[nI]:CentroCustoDebito
			cCustoDebito := fTamSx3(cCustoDebito,"CTT_CUSTO")

			CTT->(dbSetOrder(1))//CTT_FILIAL+CTT_CUSTO
			//If CTT->(dbSeek(cFilCTt + oDados:itens[nI]:CentroCustoDebito))
			If CTT->(dbSeek(cFilCTt + cCustoDebito))
				If CTT->CTT_BLOQ == "1"//Bloqueado
					cMsgErro 	+= "Centro Custo Debito Esta Bloqueado CC:" + Alltrim(oDados:itens[nI]:CentroCustoDebito) + CRLF
					lRet		:= .F.
				EndIf
			Else
				cMsgErro 	+= "Centro Custo Debito Não Existe CC:" + Alltrim(oDados:itens[nI]:CentroCustoDebito) + CRLF
				lRet		:= .F.
			EndIf
		EndIf

		//Validação CC de Credito
		If !Empty(oDados:itens[nI]:CentroCustoCredito)
			//Para o Texto ficar no tamanho certo do dicionario para evitar falha no Seek
			cCustoCredito := oDados:itens[nI]:CentroCustoCredito
			cCustoCredito := fTamSx3(cCustoCredito,"CTT_CUSTO")

			CTT->(dbSetOrder(1))//CTT_FILIAL+CTT_CUSTO
			//If CTT->(dbSeek(cFilCTt + oDados:itens[nI]:CentroCustoCredito))
			If CTT->(dbSeek(cFilCTt + cCustoCredito))
				If CTT->CTT_BLOQ == "1"//Bloqueado
					cMsgErro 	+= "Centro Custo Credito Esta Bloqueado CC:" + Alltrim(oDados:itens[nI]:CentroCustoCredito) + CRLF
					lRet		:= .F.
				EndIf
			Else
				cMsgErro 	+= "Centro Custo Credito Não Existe CC:" + Alltrim(oDados:itens[nI]:CentroCustoCredito) + CRLF
				lRet		:= .F.
			EndIf
		EndIf		

		//Validação Item Contabil de Debito
		If !Empty(oDados:itens[nI]:ItemContaDebito)
			//Para o Texto ficar no tamanho certo do dicionario para evitar falha no Seek
			cItemDebito := oDados:itens[nI]:ItemContaDebito
			cItemDebito := fTamSx3(cItemDebito,"CTD_ITEM")
			
			CTD->(dbSetOrder(1))//CTD_FILIAL+CTD_ITEM
			//If CTD->( dbSeek(cFilCTD + oDados:itens[nI]:ItemContaDebito ))
			If CTD->( dbSeek(cFilCTD + cItemDebito ))
				If CTD->CTD_BLOQ == "1"//Bloqueado
					cMsgErro 	+= "Item Contabil Debito Esta Bloqueado Item:" + Alltrim(oDados:itens[nI]:ItemContaDebito) + CRLF
					lRet		:= .F.
				EndIf
			Else
				cMsgErro 	+= "Item Contabil Debito Não Existe Item:" + Alltrim(oDados:itens[nI]:ItemContaDebito) + CRLF
				lRet		:= .F.
			EndIf
		EndIf

		//Validação Item Contabil de Credito
		If !Empty(oDados:itens[nI]:ItemContaCredito)
			//Para o Texto ficar no tamanho certo do dicionario para evitar falha no Seek
			cItemCredito := oDados:itens[nI]:ItemContaCredito
			cItemCredito := fTamSx3(cItemCredito,"CTD_ITEM")

			CTD->(dbSetOrder(1))//CTD_FILIAL+CTD_ITEM
			//If CTD->(dbSeek(cFilCTD + oDados:itens[nI]:ItemContaCredito))
			If CTD->(dbSeek(cFilCTD + cItemCredito))
				If CTD->CTD_BLOQ == "1"//Bloqueado
					cMsgErro 	+= "Item Contabil Credito Esta Bloqueado Item:" + Alltrim(oDados:itens[nI]:ItemContaCredito) + CRLF
					lRet		:= .F.
				EndIf
			Else
				cMsgErro 	+= "Item Contabil Credito Não Existe Item:" + Alltrim(oDados:itens[nI]:ItemContaCredito) + CRLF
				lRet		:= .F.
			EndIf
		EndIf		

		//Validação Item Contabil de Debito
		If !Empty(oDados:itens[nI]:ClasseValorDebito)
			//Para o Texto ficar no tamanho certo do dicionario para evitar falha no Seek
			cCLVLDebito := oDados:itens[nI]:ClasseValorDebito
			cCLVLDebito := fTamSx3(cCLVLDebito,"CTH_CLVL")
			
			CTH->(dbSetOrder(1))//CTH_FILIAL+CTH_CLVL
			//If CTH->(dbSeek(cFilCTH + oDados:itens[nI]:ClasseValorDebito))
			If CTH->(dbSeek(cFilCTH + cCLVLDebito))
				If CTH->CTH_BLOQ == "1"//Bloqueado
					cMsgErro 	+= "Classe Valor Debito Esta Bloqueado Item:" + Alltrim(oDados:itens[nI]:ClasseValorDebito) + CRLF
					lRet		:= .F.
				EndIf
			Else
				cMsgErro 	+= "Classe Valor Debito Não Existe Item:" + Alltrim(oDados:itens[nI]:ClasseValorDebito) + CRLF
				lRet		:= .F.
			EndIf
		EndIf

		//Validação Item Contabil de Credito
		If !Empty(oDados:itens[nI]:ClasseValorCredito)
			//Para o Texto ficar no tamanho certo do dicionario para evitar falha no Seek
			cCLVLCredito := oDados:itens[nI]:ClasseValorCredito
			cCLVLCredito := fTamSx3(cCLVLCredito,"CTH_CLVL")

			CTH->(dbSetOrder(1))//CTH_FILIAL+CTH_CLVL
			//If CTH->(dbSeek(cFilCTH + oDados:itens[nI]:ClasseValorCredito))
			If CTH->(dbSeek(cFilCTH + cCLVLCredito))
				If CTH->CTH_BLOQ == "1"//Bloqueado
					cMsgErro 	+= "Classe Valor Credito Esta Bloqueado Classe:" + Alltrim(oDados:itens[nI]:ClasseValorCredito) + CRLF
					lRet		:= .F.
				EndIf
			Else
				cMsgErro 	+= "Classe Valor Credito Não Existe Classe:" + Alltrim(oDados:itens[nI]:ClasseValorCredito) + CRLF
				lRet		:= .F.
			EndIf
		EndIf
		
		If Empty(oDados:itens[nI]:Historico)
			cMsgErro 	+= "Campo histórico obrigatório" + CRLF
			lRet		:= .F.
		EndIf
		
	Next nI
	
	//If nValDeb <> nValCre 
	If Abs(nValDeb - nValCre) >= 0.01
		cMsgErro 	+= "Lançamento com diferença de débito/crédito" + CRLF
		lRet		:= .F.
	EndIf
	
	If qtdReg > nNumLin
		cMsgErro 	+=  "Lançamento com mais de " + AllTrim(Str(nNumLin)) + " linhas" + CRLF
		lRet		:= .F.		
	Endif 
	
	If !lRet
		if lAviso
			AADD(aRet, "1"	 		)//Status
			AADD(aRet, cMsgAviso 	)//Msg
		else
			AADD(aRet, "3"	 		)//Status
			AADD(aRet, cMsgErro  	)//Msg
		EndIf	
		
	EndIf

	
	RestArea(aAreaCT1)
	RestArea(aArea)
	
return aRet

/*
===========================================================================================================================================
Função:              	xEncCod
Data.....:           	20/02/2019
Descricao / Objetivo:   Função que recebe Cnpj e Tipo (C=Cliente/F=Fornecedor), e descobre o código/loja correspondente (SA1/SA2) 
============================================================================================================================================
*/
Static Function xEncCod(cCgc,cTp)
	
	Local aArea 	:= GetArea()
	Local aAreaSA1	:= SA1->(GetArea())	
	Local aAreaSA2	:= SA2->(GetArea())
	Local cRet := ""
	
	If cTp == "C"
		dbSelectArea("SA1")
		SA1->(dbSetOrder(3))//A1_FILIAL+A1_CGC
		If SA1->(dbSeek(FwxFilial("SA1") + cCgc))
			cRet := SA1->A1_COD + SA1->A1_LOJA
		EndIf
	Else
		dbSelectArea("SA2")
		SA2->(dbSetOrder(3))//A2_FILIAL+A2_CGC
		If SA2->(dbSeek(FwxFilial("SA2") + cCgc))
			cRet := SA2->A2_COD + SA2->A2_LOJA	
		EndIf		
	EndIf
	
	RestArea(aAreaSA2)
	RestArea(aAreaSA1)	
	RestArea(aArea)
	
Return cRet

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


/*
=========================================================================================
Função:              	fTamSx3
Data.....:           	09/10/2022
Descricao / Objetivo:   Função que retorna o Texto no tamanho do campo do Dicionario
						para auxiliar no Seek.
==========================================================================================
*/
Static Function fTamSx3(cTexto,cCampo)
Local cRet := ""
Local nTam := 10//TAMSX3(cCampo)[1]

Do CASE
	
	Case alltrim(cCampo) == "CT1_CONTA"
		nTam := Len(CT1->CT1_CONTA)
	
	Case alltrim(cCampo) == "CTT_CUSTO"
		nTam := Len(CTT->CTT_CUSTO)
	
	Case alltrim(cCampo) == "CTD_ITEM"
		nTam := Len(CTD->CTD_ITEM)
	
	Case alltrim(cCampo) == "CTH_CLVL"
		nTam := Len(CTH->CTH_CLVL)
	
	OtherWise
		nTam := Len(cTexto)

EndCase

cRet := Pad(cTexto,nTam)

Return cRet
