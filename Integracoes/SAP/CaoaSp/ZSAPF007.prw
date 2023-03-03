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
Programa.:              ZSAPF007
Autor....:              Joni Lima do Carmo
Data.....:              20/02/2019
Descricao / Objetivo:   WS Server de Inclus�o de Lancto Contabil 
Doc. Origem:            MIT044 - R03PT - Especifica��o de Personaliza��o - SAP - 07 - Cont�bil SAP x Protheus V3
Solicitante:            CAOA
Uso......:              Integra��es SAP vs Protheus
Obs......:				WS ja deve estar com alguma filial Aberta
=====================================================================================
*/ 

WSSERVICE ZSAPF007 DESCRIPTION "Inclus�o Lancto Contabil" NAMESPACE "http://www.totvs.com.br/ZSAPF007"
	
	WSDATA WSDADOS 	as SAP07_LANCTO
	WSDATA WSRETORNO as SAP07_RETORNO
	
	WSMETHOD IncLancto DESCRIPTION "Inclus�o Lancto Contabil"
	
ENDWSSERVICE

/*
=====================================================================================
Metodo:              	IncLancto
Data.....:           	20/02/2019
Descricao / Objetivo:   Metodo para Inclus�o do Lancto contabil vindos do SAP
=====================================================================================
*/
WSMETHOD IncLancto WSRECEIVE WSDADOS WSSEND WSRETORNO WSSERVICE ZSAPF007
	
	Local bError 	:= ErrorBlock( { |oError| MyError( oError ) } )
	Local aRetorno	:= {}
	
	//Local cxFilial	:= ::WSDADOS:cabecalho:FilialProtheus
	Private cxFilial	:= ""    //"2010022001"

	IF _cEmp = '2010' 
		cxFilial = '2010022001'
	ELSEIF _cEmp = '2020' 
		cxFilial := '2020012001'
	ENDIF
	
	BEGIN SEQUENCE
		
		cFilAnt := cxFilial 
		
		aRetorno := xIncCT2(::WSDADOS)
		
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
Fun��o:              	xIncCT2 //CMVIDSAP
Data.....:           	20/02/2019
Descricao / Objetivo:   Fun��o que recebe/Trata as informa��es para chamada do Execauto CTBA102 (Inclus�o de lancto contabil) 
============================================================================================================================================
*/
Static Function xIncCT2(oDados)

	Local aRet		:= {}
	
	Local cLote 	:= SUPERGETMV("CMV_LCTSAP", Nil, "009900")
	Local cSubLote	:= ""
	Local cDoc		:= ""
	Local cErro 	:= ""
	Local CTF_LOCK	:= 0
	
	Local nTamHis 	:= TamSX3("CT2_HIST")[1] 
	
	Local nI 		:= 0

	Local aErro 	:= {}
	Local aItem		:= {}
	Local aItens 	:= {}
	Local aCab 		:= {}
	
	Local oSubLote
	Local oDoc
	Local oLote

	Local dDataLanc := StoD(oDados:cabecalho:DataLancto) 
	Local aCont		:= nil
		
	private lMsHelpAuto     := .T. // Se .T. direciona as mensagens de help para o arq. de log
	private lMsErroAuto     := .F.
	private lAutoErrNoFile  := .T. // Precisa estar como .T. para GetAutoGRLog() retornar o array com erros
	Private lSubLote 	:= Empty(cSubLote)
		
	aCont := xValGer(oDados)//Valida��es para processeguir com o lan�amento
	
	If Empty(aCont) //se a Fun��o retornar um array em branco quer dizer que n�o encontrou nenhum erro
	
		C050Next(dDataLanc,@cLote,@cSubLote,@cDoc,oLote,oSubLote,oDoc,@CTF_LOCK,3,1)//Fun��o padr�o para retornar SubLote e Documento
		
		//Dados Cabe�alho
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
			AADD(aItem,{'CT2_FILIAL' 	 , cxFilial              								, NIL})
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
	
		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)
		If lMsErroAuto <> Nil 
			If !lMsErroAuto
				AADD(aRet, "1"	 )//Status
				AADD(aRet, "Lancto Incluido com Sucesso" )//Msg
			Else
				aErro := GetAutoGRLog() // Retorna erro em array
				cErro := ""
		
				for nI := 1 to len(aErro)
					cErro += aErro[ nI ] + CRLF
				next nI
				
				AADD(aRet, "2"	 )//Status
				AADD(aRet, cErro )//Msg
	
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
	
	Local aRet 		:= {}
	Local ni		:= 1
	Local qtdReg	:= 0
	
	Local nValDeb	:= 0
	Local nValCre	:= 0
	Local nNumLin	:= SUPERGETMV("MV_NUMLIN",Nil,996)
	
	dbSelectArea("CT1")
	dbSelectArea("CTT")
	dbSelectArea("CTD")
	dbSelectArea("CT2")
	CT2->(DbOrderNickName("CMVIDSAP"))//CT2_FILIAL+CT2_XSAP

	If Empty(oDados:cabecalho:LoteSAP)
		cMsgErro += "Lote SAP n�o informado" + CRLF 
		lRet	:= .F.	
	EndIf

	If Empty(oDados:cabecalho:DataLancto)
		cMsgErro += "Data do lan�amento n�o informada" + CRLF 
		lRet	:= .F.
	EndIf

	If lRet
		If (CT2->(DbSeek( xFilial("CT2") + oDados:cabecalho:LoteSAP + Substr(AllTrim(oDados:cabecalho:DataLancto),1,4) )))
			cMsgErro += "Lancto Contabil J� existe na base, Lote: " + Alltrim(oDados:cabecalho:LoteSAP) + CRLF 
			lRet	:= .F.
		EndIf
	EndIf
	
	If lRet
		If !(CtbValiDt( nil , StoD(oDados:cabecalho:DataLancto) ))
			cMsgErro += "O Status deste per�odo n�o permite digita��o. Verifique o status do calend�rio para essa data" + CRLF 
			lRet	:= .F.
		EndIf	
	EndIf
	
	For nI := 1 to Len( oDados:itens )
		
		//Quantidade de Linhas
		qtdReg++

		If Empty(oDados:itens[nI]:Item)
			cMsgErro += "Item n�o informado" + CRLF
			lRet	:= .F.			
		EndIf

		If Empty(oDados:itens[nI]:TipoLancto)
			cMsgErro += "Tipo de Lan�amento n�o informado" + CRLF
			lRet	:= .F.			
		Else
			If !(oDados:itens[nI]:TipoLancto $ "1|2")
				cMsgErro += "Tipo de Lan�amento Inconsistente, deve ser 1=Debito ou 2=Credito" + CRLF
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
			cMsgErro += "Valor do lan�amento deve ser maior que Zero" + CRLF
			lRet	:= .F.
		EndIf
		
		//Valida��o conta Debito
		If !Empty(oDados:itens[nI]:ContaDebito)
			CT1->(dbSetOrder(1))//CT1_FILIAL+CT1_CONTA
			If CT1->(dbSeek(xFilial("CT1") + oDados:itens[nI]:ContaDebito))
				If CT1->CT1_BLOQ == "1"//Bloqueado
					cMsgErro += "Conta Debito Esta Bloqueada Conta:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
					lRet	:= .F.							
				EndIf
				
				If AllTrim(CT1->CT1_CONTA) $ '1120101001|1120101008|2110101001|2110101003|2110101004'
					If Empty(oDados:itens[nI]:CNPJCliForDebito)
						cMsgErro 	+= "CNPJ n�o informado para conta de cliente/fornecedor" + CRLF
						lRet		:= .F.					
					EndIf
				EndIf
				
				If CT1->CT1_CCOBRG == "1"
					If Empty(oDados:itens[nI]:CentroCustoDebito)
						cMsgErro += "CC est� vazio, CC � Obrigatorio Nessa Conta Contabil, conta Debito:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_ITOBRG == "1"
					If Empty(oDados:itens[nI]:ItemContaDebito)
						cMsgErro += "Item Contabil est� vazio, Item Contabil � Obrigatorio Nessa Conta Contabil, conta Debito:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_CLOBRG == "1"
					If Empty(oDados:itens[nI]:ClasseValorDebito)
						cMsgErro += "Classe est� vazia, Classe � Obrigatorio Nessa Conta Contabil, conta Debito:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf			

				If CT1->CT1_ACCUST == "2"
					If !Empty(oDados:itens[nI]:CentroCustoDebito)
						cMsgErro += "CC est� preenchido, Conta Cont�bil n�o aceita Centro de Custo, conta Debito:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_ACITEM == "2"
					If !Empty(oDados:itens[nI]:ItemContaDebito)
						cMsgErro += "Item Contabil est� preenchido, Conta Cont�bil n�o aceita Item Contabil, conta Debito:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_ACCLVL == "2"
					If !Empty(oDados:itens[nI]:ClasseValorDebito)
						cMsgErro += "Classe est� preenchido, Conta Cont�bil n�o aceita Classe, conta Debito:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf			
			
			Else
				cMsgErro += "Conta Debito N�o Existe Conta:" + Alltrim(oDados:itens[nI]:ContaDebito) + CRLF 
				lRet	 := .F.
			EndIf
		Else
			If oDados:itens[nI]:TipoLancto == "1"
				cMsgErro += "Conta Debito N�o Informada:" + CRLF 
				lRet	 := .F.
			EndIf
		EndIf

		//Valida��o conta Credito
		If !Empty(oDados:itens[nI]:ContaCredito)
			CT1->(dbSetOrder(1))//CT1_FILIAL+CT1_CONTA
			If CT1->(dbSeek(xFilial("CT1") + oDados:itens[nI]:ContaCredito))
				If CT1->CT1_BLOQ == "1"//Bloqueado
					cMsgErro 	+= "Conta Credito Esta Bloqueada Conta:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF
					lRet		:= .F.
				EndIf

				If AllTrim(CT1->CT1_CONTA) $ '1120101001|1120101008|2110101001|2110101003|2110101004'
					If Empty(oDados:itens[nI]:CNPJCliForCredito)
						cMsgErro 	+= "CNPJ n�o informado para conta de cliente/fornecedor" + CRLF
						lRet		:= .F.					
					EndIf
				EndIf

				If CT1->CT1_CCOBRG == "1"
					If Empty(oDados:itens[nI]:CentroCustoCredito)
						cMsgErro += "CC est� vazio, CC � Obrigatorio Nessa Conta Contabil, conta Credito:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_ITOBRG == "1"
					If Empty(oDados:itens[nI]:ItemContaCredito)
						cMsgErro += "Item Contabil est� vazio, Item Contabil � Obrigatorio Nessa Conta Contabil, conta Credito:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_CLOBRG == "1"
					If Empty(oDados:itens[nI]:ClasseValorCredito)
						cMsgErro += "Classe est� vazia, Classe � Obrigatorio Nessa Conta Contabil, conta Credito:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_ACCUST == "2"
					If !Empty(oDados:itens[nI]:CentroCustoCredito)
						cMsgErro += "CC est� preenchido, Conta Cont�bil n�o aceita Centro de Custo, conta Credito:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_ACITEM == "2"
					If !Empty(oDados:itens[nI]:ItemContaCredito)
						cMsgErro += "Item Contabil est� preenchido, Conta Cont�bil n�o aceita Item Contabil, conta Credito:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf

				If CT1->CT1_ACCLVL == "2"
					If !Empty(oDados:itens[nI]:ClasseValorCredito)
						cMsgErro += "Classe est� preenchido, Conta Cont�bil n�o aceita Classe, conta Credito:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF 
						lRet	:= .F.							
					EndIf
				EndIf			

			Else
				cMsgErro 	+= "Conta Credito N�o Existe Conta:" + Alltrim(oDados:itens[nI]:ContaCredito) + CRLF
				lRet		:= .F.		
			EndIf
		Else
			If oDados:itens[nI]:TipoLancto == "2"
				cMsgErro += "Conta Credito N�o Informada:" + CRLF 
				lRet	 := .F.
			EndIf
		EndIf
		
		//Valida��o CC de Debito
		If !Empty(oDados:itens[nI]:CentroCustoDebito)
			CTT->(dbSetOrder(1))//CTT_FILIAL+CTT_CUSTO
			If CTT->(dbSeek(xFilial("CTT") + oDados:itens[nI]:CentroCustoDebito))
				If CTT->CTT_BLOQ == "1"//Bloqueado
					cMsgErro 	+= "Centro Custo Debito Esta Bloqueado CC:" + Alltrim(oDados:itens[nI]:CentroCustoDebito) + CRLF
					lRet		:= .F.
				EndIf
			Else
				cMsgErro 	+= "Centro Custo Debito N�o Existe CC:" + Alltrim(oDados:itens[nI]:CentroCustoDebito) + CRLF
				lRet		:= .F.
			EndIf
		EndIf

		//Valida��o CC de Credito
		If !Empty(oDados:itens[nI]:CentroCustoCredito)
			CTT->(dbSetOrder(1))//CTT_FILIAL+CTT_CUSTO
			If CTT->(dbSeek(xFilial("CTT") + oDados:itens[nI]:CentroCustoCredito))
				If CTT->CTT_BLOQ == "1"//Bloqueado
					cMsgErro 	+= "Centro Custo Credito Esta Bloqueado CC:" + Alltrim(oDados:itens[nI]:CentroCustoCredito) + CRLF
					lRet		:= .F.
				EndIf
			Else
				cMsgErro 	+= "Centro Custo Credito N�o Existe CC:" + Alltrim(oDados:itens[nI]:CentroCustoCredito) + CRLF
				lRet		:= .F.
			EndIf
		EndIf		

		//Valida��o Item Contabil de Debito
		If !Empty(oDados:itens[nI]:ItemContaDebito)
			CTD->(dbSetOrder(1))//CTD_FILIAL+CTD_ITEM
			If CTD->(dbSeek(xFilial("CTD") + oDados:itens[nI]:ItemContaDebito))
				If CTD->CTD_BLOQ == "1"//Bloqueado
					cMsgErro 	+= "Item Contabil Debito Esta Bloqueado Item:" + Alltrim(oDados:itens[nI]:ItemContaDebito) + CRLF
					lRet		:= .F.
				EndIf
			Else
				cMsgErro 	+= "Item Contabil Debito N�o Existe Item:" + Alltrim(oDados:itens[nI]:ItemContaDebito) + CRLF
				lRet		:= .F.
			EndIf
		EndIf

		//Valida��o Item Contabil de Credito
		If !Empty(oDados:itens[nI]:ItemContaCredito)
			CTD->(dbSetOrder(1))//CTD_FILIAL+CTD_ITEM
			If CTD->(dbSeek(xFilial("CTD") + oDados:itens[nI]:ItemContaCredito))
				If CTD->CTD_BLOQ == "1"//Bloqueado
					cMsgErro 	+= "Item Contabil Credito Esta Bloqueado Item:" + Alltrim(oDados:itens[nI]:ItemContaCredito) + CRLF
					lRet		:= .F.
				EndIf
			Else
				cMsgErro 	+= "Item Contabil Credito N�o Existe Item:" + Alltrim(oDados:itens[nI]:ItemContaCredito) + CRLF
				lRet		:= .F.
			EndIf
		EndIf		

		//Valida��o Item Contabil de Debito
		If !Empty(oDados:itens[nI]:ClasseValorDebito)
			CTH->(dbSetOrder(1))//CTH_FILIAL+CTH_CLVL
			If CTH->(dbSeek(xFilial("CTH") + oDados:itens[nI]:ClasseValorDebito))
				If CTH->CTH_BLOQ == "1"//Bloqueado
					cMsgErro 	+= "Classe Valor Debito Esta Bloqueado Item:" + Alltrim(oDados:itens[nI]:ClasseValorDebito) + CRLF
					lRet		:= .F.
				EndIf
			Else
				cMsgErro 	+= "Classe Valor Debito N�o Existe Item:" + Alltrim(oDados:itens[nI]:ClasseValorDebito) + CRLF
				lRet		:= .F.
			EndIf
		EndIf

		//Valida��o Item Contabil de Credito
		If !Empty(oDados:itens[nI]:ClasseValorCredito)
			CTH->(dbSetOrder(1))//CTH_FILIAL+CTH_CLVL
			If CTH->(dbSeek(xFilial("CTH") + oDados:itens[nI]:ClasseValorCredito))
				If CTH->CTH_BLOQ == "1"//Bloqueado
					cMsgErro 	+= "Classe Valor Credito Esta Bloqueado Classe:" + Alltrim(oDados:itens[nI]:ClasseValorCredito) + CRLF
					lRet		:= .F.
				EndIf
			Else
				cMsgErro 	+= "Classe Valor Credito N�o Existe Classe:" + Alltrim(oDados:itens[nI]:ClasseValorCredito) + CRLF
				lRet		:= .F.
			EndIf
		EndIf
		
		If Empty(oDados:itens[nI]:Historico)
			cMsgErro 	+= "Campo hist�rico obrigat�rio" + CRLF
			lRet		:= .F.
		EndIf
		
	Next nI
	
	//If nValDeb <> nValCre 
	If Abs(nValDeb - nValCre) >= 0.01
		cMsgErro 	+= "Lan�amento com diferen�a de d�bito/cr�dito" + CRLF
		lRet		:= .F.
	EndIf
	
	If qtdReg > nNumLin
		cMsgErro 	+=  "Lan�amento com mais de " + AllTrim(Str(nNumLin)) + " linhas" + CRLF
		lRet		:= .F.		
	Endif 
	
	If !lRet
		AADD(aRet, "3"	 		)//Status
		AADD(aRet, cMsgErro  	)//Msg					
	EndIf

	
	RestArea(aAreaCT1)
	RestArea(aArea)
	
return aRet

/*
===========================================================================================================================================
Fun��o:              	xEncCod
Data.....:           	20/02/2019
Descricao / Objetivo:   Fun��o que recebe Cnpj e Tipo (C=Cliente/F=Fornecedor), e descobre o c�digo/loja correspondente (SA1/SA2) 
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
		If SA1->(dbSeek(xFilial("SA1") + cCgc))
			cRet := SA1->A1_COD + SA1->A1_LOJA
		EndIf
	Else
		dbSelectArea("SA2")
		SA2->(dbSetOrder(3))//A2_FILIAL+A2_CGC
		If SA2->(dbSeek(xFilial("SA2") + cCgc))
			cRet := SA2->A2_COD + SA2->A2_LOJA	
		EndIf		
	EndIf
	
	RestArea(aAreaSA2)
	RestArea(aAreaSA1)	
	RestArea(aArea)
	
Return cRet

/*
=========================================================================================
Fun��o:              	MyError
Data.....:           	20/02/2019
Descricao / Objetivo:   Fun��o que retorna Error Log de rotina caso ocorra algum) 
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

