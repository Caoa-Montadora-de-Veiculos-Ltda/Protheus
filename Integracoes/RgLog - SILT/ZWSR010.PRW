#INCLUDE "TOTVS.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "RESTFUL.CH"
#define CRLF chr(13) + chr(10)

/*
======================================================================================
Programa.:              ZWSR010
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:   Integração de recebimento para RGLOG
======================================================================================
*/
User Function ZWSR010(cNota, cSerie, cForn, cLoja, lBotao, cTpNf)
	Local aErrRg     	:= {}
	Local cQry       	:= ''  
	Local _cUsua     	:= Alltrim(Getmv("CMV_WSR016")) // Usuário
	Local _cSenha    	:= Alltrim(Getmv("CMV_WSR017")) // Senha encodada no Postman com o tipo Basic
	Local _cCnpjTransf  := AllTrim(SuperGetMV( "CMV_WSR019"  ,,"03471344"))	//Raiz CNPJ de transferencia
	Local oJsEnt
	Local _cAlias 	 	:= GetNextAlias()   
	Local aResRg	 	:= { .F. } 
	Local _lRet			:= .T.
	
	Default cNota	 	:= ""
	Default cSerie	 	:= ""
	Default cForn	 	:= ""
	Default cLoja	 	:= ""
	Default lBotao	 	:= .F.

	Private cXTipo		:= ""
	Private oJsRet    := JsonObject():New()

	DbSelectArea("SA1")
	DbSelectArea("SA2")

	//--Filtra apenas por Barueri
	IF !( FWCodEmp() = '2020' .And. FWFilial() = '2001' )
		Return
	EndIf

	cQry := " SELECT"													+ CRLF
	cQry += " 	D1_DOC      					,"						+ CRLF
	cQry += " 	D1_SERIE      					,"						+ CRLF
	cQry += " 	D1_COD      					,"						+ CRLF
	cQry += " 	D1_CONHEC						,"						+ CRLF
	cQry += " 	D1_XCASE						,"						+ CRLF
	cQry += " 	F1_FORNECE						,"						+ CRLF
	cQry += " 	F1_LOJA							,"						+ CRLF
	cQry += " 	F1_EMISSAO  					,"						+ CRLF
	cQry += " 	SUBSTR(F1_HORA,1,4)||'0:00' F1_HORA	,"						+ CRLF
	cQry += " 	F1_TIPO     					,"						+ CRLF
	cQry += " 	F1_EST      					,"						+ CRLF
	cQry += " 	D1_LOCAL   						," 						+ CRLF
	cQry += " 	SUM(D1_QUANT)     	AS D1_QUANT "						+ CRLF
	cQry += " FROM "       + retSQLName("SF1") + " F1"					+ CRLF
    cQry += " 	INNER JOIN " + RetSqlName("SD1") + " SD1 "              + CRLF
	cQry += "		ON SD1.D1_FILIAL = '" + FWxFilial("SD1") + "' " 	+ CRLF
	cQry += "   	AND SD1.D1_DOC = F1.F1_DOC "                        + CRLF
	cQry += "   	AND SD1.D1_SERIE = F1.F1_SERIE "                    + CRLF
	cQry += "   	AND SD1.D1_FORNECE = F1.F1_FORNECE "                + CRLF
	cQry += "   	AND SD1.D1_LOJA = F1.F1_LOJA "                      + CRLF
	cQry += "   	AND SD1.D1_TES <> ' ' " 		                    + CRLF
	cQry += "   	AND SD1.D_E_L_E_T_ = ' ' "                          + CRLF
	cQry += " 	INNER JOIN " + RetSqlName("SF4") + " F4 "				+ CRLF
    cQry += "		ON F4.F4_FILIAL = '" + FWxFilial("SF4") +"' "  		+ CRLF
    cQry += "   	AND F4.F4_CODIGO = SD1.D1_TES "                  	+ CRLF
	cQry += "   	AND F4.F4_ESTOQUE = 'S' "                  			+ CRLF
	cQry += "   	AND F4.D_E_L_E_T_ =	' ' "							+ CRLF
	cQry += " WHERE F1.F1_FILIAL = '" + FWxFilial("SF1") + "'" 	    	+ CRLF
 	cQry += " AND	F1.F1_DOC =  '"  + alltrim(cNota)  + "'"   	        + CRLF
	cQry += " AND F1.F1_SERIE =  '"  + alltrim(cSerie)  + "'"   	    + CRLF
	cQry += " AND F1.F1_FORNECE =  '"  + alltrim(cForn)  + "'"   	   	+ CRLF
	cQry += " AND F1.F1_LOJA =  '"  + alltrim(cLoja)  + "'"   	    	+ CRLF
	cQry += " AND F1.F1_XINTEG <> 'X'"       				        	+ CRLF
	cQry += " AND F1.F1_ESPECIE NOT IN('CTE','NFST') "					+ CRLF
    cQry += " AND F1.D_E_L_E_T_ =	' '"                                + CRLF
	cQry += " GROUP BY D1_DOC, D1_SERIE, D1_COD, D1_CONHEC, D1_XCASE, F1_FORNECE, F1_LOJA, F1_EMISSAO, SUBSTR(F1_HORA,1,4), F1_TIPO,F1_EST, D1_LOCAL "+ CRLF //, D1_PEDIDO"		+ CRLF

    If Select(_cAlias) > 0
		(_cAlias)->(dbCloseArea())
	EndIf

	cQry  := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cAlias,.T.,.F.)
	dbSelectArea(_cAlias)
	(_cAlias)->(dbGoTop())

    If (_cAlias)->(!EOF())

		If (_cAlias)->F1_TIPO == "D"
					
			cXTipo := "DEV"

			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+(_cAlias)->F1_FORNECE+(_cAlias)->F1_LOJA))

				SA2->(dbSetOrder(3))
				If SA2->(dbSeek(xFilial("SA2")+SA1->A1_CGC))

					cForn := SA2->A2_COD
					cLoja := SA2->A2_LOJA
					cCnpj := SA2->A2_CGC
				Else
					_lRet := .F.
				EndIf

			EndIf

		Else

			SA2->(dbSetOrder(1))
			If SA2->(dbSeek(xFilial("SA2") + (_cAlias)->F1_FORNECE + (_cAlias)->F1_LOJA) )

				cForn := SA2->A2_COD
				cLoja := SA2->A2_LOJA
				cCnpj := SA2->A2_CGC

			EndIf
				
			If Substring(SA2->A2_CGC,1,8) == _cCnpjTransf //'03471344'
				cXTipo := "TRF"
			ElseIf (_cAlias)->F1_TIPO $ "C|N"
				cXTipo := "FOR"
			Else
				cXTipo := "OUT"
			EndIf	

		EndIf

		If _lRet

			While ((_cAlias)->( !Eof() ))

				FreeObj(oJsEnt)                     
				oJsEnt := JsonObject():new()
				oJsEnt["usuario"]    := _cUsua    // Usuário
				oJsEnt["senha"]      := _cSenha   // Senha encodada no Postman com o tipo Basic
				oJsEnt['recebimento']:=JsonObject():New()
				oJsEnt['recebimento']['cd_fornecedor']        := "9"+cForn+cLoja
				oJsEnt['recebimento']['nu_nota_fiscal']       := Alltrim((_cAlias)->D1_DOC)
				oJsEnt['recebimento']['nu_serie_nf']          := ALLTRIM((_cAlias)->D1_SERIE)
				oJsEnt['recebimento']['nu_agenda'] 	          := ""   
				oJsEnt['recebimento']['dt_emissao']           := Substr((_cAlias)->F1_EMISSAO,7,2)+"/"+Substr((_cAlias)->F1_EMISSAO,5,2)+"/"+Substr((_cAlias)->F1_EMISSAO,1,4)+" "+(_cAlias)->F1_HORA
				oJsEnt['recebimento']['cd_situacao'] 	      := "3"       //Fixo pelo exemplo RgLog
				oJsEnt['recebimento']['cd_empresa'] 	      := "1"       //Fixo pelo exemplo RgLog
				oJsEnt['recebimento']['importe_nf']           := ""
				oJsEnt['recebimento']['id_autorizacao']       := ""       //Fixo pelo exemplo RgLog
				oJsEnt['recebimento']['cd_func_autorizacion'] := ""
				oJsEnt['recebimento']['id_procesado']         := "N"
				oJsEnt['recebimento']['cd_error'] 	  	      := ""       //Fixo pelo exemplo RgLog
				oJsEnt['recebimento']['dt_procesado']         := "" 
				oJsEnt['recebimento']['nu_cgc_fornecedor']    := IiF( (_cAlias)->F1_EST == "EX", "9"+AllTrim( cForn )+AllTrim( cLoja ), Alltrim( cCnpj ) )
				oJsEnt['recebimento']['ds_arquivo']           := ""       //Fixo pelo exemplo RgLog
				oJsEnt['recebimento']['id_nota_fiscal']       := ""        
				oJsEnt['recebimento']['cd_placa'] 	  	      := ""
				oJsEnt['recebimento']['dt_addrow'] 	          := DtoC(dDatabase)+' '+Time()
				oJsEnt['recebimento']['tp_nota']              := cXTipo
				oJsEnt['recebimento']['cd_porta'] 	     	  := ""      //Fixo pelo exemplo RgLog
				oJsEnt['recebimento']['nu_doc_erp'] 	  	  := Alltrim((_cAlias)->D1_DOC)
				oJsEnt['recebimento']['cd_registro'] 	  	  := ""
				oJsEnt['recebimento']['qt_itens']   	  	  := "" //--Fixo Cirilo
				oJsEnt['recebimento']['cd_deposito'] 	  	  := zBuscaCd( (_cAlias)->D1_COD )
				oJsEnt['recebimento']['cd_motorista'] 	  	  := ""
				oJsEnt['recebimento']['dt_agenda'] 	          := ""
				oJsEnt['recebimento']['ds_transportadora']    := ""       //Fixo pelo exemplo RgLog
				oJsEnt['recebimento']['cd_loja'] 	          := ""
				oJsEnt['recebimento']['id_leva_devolucao']    := ""
				oJsEnt['recebimento']['nu_invoice']    	      := IiF( (_cAlias)->F1_TIPO == 'N' , zBuscaInv( (_cAlias)->D1_CONHEC, cForn, cLoja, Alltrim((_cAlias)->D1_DOC) ), Alltrim((_cAlias)->D1_DOC) )
				oJsEnt['recebimento']['detalhe']              := ZWSR007ITE(oJsEnt, Alltrim((_cAlias)->D1_DOC), Alltrim((_cAlias)->D1_SERIE), cForn , cLoja ,_cAlias)
		
				FWMsgRun(, {|| aResRg := zPostRg(oJsEnt) }, "Envio de Receb. Nf de Entrada", "Por favor aguarde...")

				If aResRg[1]
				
					If  RecLock("SF1",.F.)
						SF1->F1_XINTEG := "X" //-- X = Integrado RgLog
						//SF1->F1_XDTINT := DDataBase
						//SF1->F1_XHRINT := Time()
						//SF1->F1_XJSON  := AllTrim(oJsEnt:toJson())
						SF1->( MsUnLock() )
					EndIf

				Else

					Aadd(aErrRg, aResRg[2]) 
					NotificaFalha(aResRg[2])
				
				EndIf
				
				//-- Skip comentado porque o _calias é desposicionado pela função ZWSR007ITE
				//(_cAlias)->(DbSkip())

			ENDDO

			If lBotao
				If aResRg[1]
					Help( ,, "[ ZWSR010 ]" ,,"Integração da Nota Fiscal de Entrada enviada com sucesso para RgLog." ,1 ,0)
				Else
					Help( ,, "[ ZWSR010 ]" ,,"Não foi possivel integrar a Nota Fiscal de Entrada com a RGLog. Erro: " + aResRg[2] ,1 ,0)
				EndIf
			EndIf
		Else

			If lBotao
				MsgInfo("Necessário a inclusão desse Cliente como Fornecedor para enviar a Integração para RgLog.","[ ZWSR010 ]")
			EndIf

		EndIf

	Else
		
		If lBotao
			Help( ,, "[ ZWSR010 ]" ,,"Não foi possivel integrar a Nota Fiscal de Entrada com a RGLog" ,1 ,0 ,,,,,, {	"" + CRLF,;
																				"Por favor, verifique os pontos abaixo: " + CRLF + CRLF,;
																				"** Nota fiscal ja enviada para a RGLOG, verifique o campo F1_XINTEG." + CRLF,;
																				"** Nota fiscal pendente de classificação." + CRLF,;
																				"** TES utilizada na classificação deve estar marcada para atualizar estoque."})
		EndIf
		
    ENDIF

	If Select(_cAlias) <> 0
		(_cAlias)->(DbCloseArea())
		Ferase(_cAlias+GetDBExtension())
	Endif 

RETURN()

Static Function ZWSR007ITE( _oJsEnt, cNota, cSerie, cForn, cLoja ,_cAlias )
	Local _nPos   	:= 0
	Local cCodFor	:= ""
	Local cLojaFor	:= ""
	Local cCodProd	:= ""
	Local _nItem		:= 1

	Private _aItens := {}

	Begin Sequence

		(_cAlias)->(dbGoTop())
		
		If (_cAlias)->(Eof())  
			//adiciono retorno em branco
			Aadd(_aItens,JsonObject():new())
			Break	
		Endif

		ZD1->( DbSetOrder(1) )

		While (_cAlias)->(!Eof())

			cNota    := PadR( Alltrim((_cAlias)->D1_DOC), TamSX3("ZD1_DOC")[1] )
			cSerie 	 := PadR( Alltrim((_cAlias)->D1_SERIE), TamSX3("ZD1_SERIE")[1] )
			cCodFor  := PadR( cForn, TamSX3("ZD1_FORNEC")[1] )
			cLojaFor := PadR( cLoja, TamSX3("ZD1_LOJA")[1] )
			cCodProd :=	PadR( (_cAlias)->D1_COD, TamSX3("ZD1_COD")[1] )

			Aadd(_aItens,JsonObject():new())
			_nPos := Len(_aItens)
			//_aItens[_nPos]['nu_nota_fiscal']  :=  cNota
			_aItens[_nPos]['cd_empresa'] 	  	:= "1"      //Fixo pelo exemplo RgLog
			_aItens[_nPos]['cd_fornecedor'] 	:= "9"+cForn+cLoja
			_aItens[_nPos]['nu_nota_fiscal'] 	:= Alltrim((_cAlias)->D1_DOC)
			_aItens[_nPos]['nu_serie_nf'] 	    := Alltrim((_cAlias)->D1_SERIE)
			_aItens[_nPos]['nu_agenda'] 	    := ""
			_aItens[_nPos]['nu_item'] 	        := _nItem
			_aItens[_nPos]['cd_situacao'] 	    := "3"	//Fixo pelo exemplo RgLog
			_aItens[_nPos]['cd_produto'] 	    := Alltrim((_cAlias)->D1_COD)
			_aItens[_nPos]['cd_faixa'] 	        := ""
			_aItens[_nPos]['qt_produto']        := Alltrim(STR((_cAlias)->D1_QUANT))
			_aItens[_nPos]['dt_fabricacao']     := ""
			_aItens[_nPos]['id_sofre_inspecao'] := ""
			_aItens[_nPos]['nu_ar'] 	  	    := ""
			_aItens[_nPos]['nu_seq_ar'] 	    := ""
			_aItens[_nPos]['nu_cgc_fornecedor'] := IiF( (_cAlias)->F1_EST == "EX", "9"+AllTrim( cForn )+AllTrim( cLoja ), Alltrim(cCnpj ) )
			_aItens[_nPos]['id_skip_lote'] 	    := ""
			_aItens[_nPos]['nu_ordem_compra']   := ""
			_aItens[_nPos]['cfop'] 	            := ""
			_aItens[_nPos]['nu_lote']    	    := ""
			_aItens[_nPos]['nu_lote_fornecedor']:= ""
			_aItens[_nPos]['nu_serie_produto']  := ""
			_aItens[_nPos]['dt_addrow']    	    := ""
			_aItens[_nPos]['nu_interface'] 	    := ""
			_aItens[_nPos]['dt_processado']      := ""
			_aItens[_nPos]['tp_nota']           := cXTipo
			_aItens[_nPos]['nu_doc_erp']   	    := Alltrim((_cAlias)->D1_DOC)
			_aItens[_nPos]['cd_registro']  	    := ""
			_aItens[_nPos]['id_processado']     := "N"	//Fixo pelo exemplo RgLog 
			_aItens[_nPos]['nu_doc_erp_cdk']    := ""
			_aItens[_nPos]['ds_loja']    	    := ""
			_aItens[_nPos]['nu_pedido']    	    := ""
			_aItens[_nPos]['cd_deposito']    	:= zBuscaCd( Alltrim((_cAlias)->D1_COD) )
			_aItens[_nPos]['qt_transferencia']  := ""
			_aItens[_nPos]['loja']    	        := ""
			_aItens[_nPos]['qt_cross_docking']  := ""
			_aItens[_nPos]['qt_unidade_embalag']:= ""
			_aItens[_nPos]['cd_filial']    	    := ""
			_aItens[_nPos]['cd_embalagem']      := ""
			_aItens[_nPos]['dt_validade']  	    := ""
			_aItens[_nPos]['nu_volume']    	    := Alltrim((_cAlias)->D1_XCASE)

			_nItem++

			//-- Grava tabela de conferencia RGLOG
			If !( ZD1->( DbSeek( FWxFilial("ZD1") + cNota + cSerie + cCodFor + cLojaFor + cCodProd ) ) )

				RecLock("ZD1", .T.)
				
				ZD1->ZD1_FILIAL := FWxFilial("ZD1")
				ZD1->ZD1_XCASE  := Alltrim((_cAlias)->D1_XCASE)
				ZD1->ZD1_DOC	:= Alltrim(cNota)
				ZD1->ZD1_SERIE 	:= Alltrim(cSerie)
				ZD1->ZD1_FORNEC	:= cCodFor
				ZD1->ZD1_LOJA	:= cLojaFor
				ZD1->ZD1_COD	:= Alltrim((_cAlias)->D1_COD)
				ZD1->ZD1_SLDIT	:= (_cAlias)->D1_QUANT
				ZD1->ZD1_QUANT	:= (_cAlias)->D1_QUANT
				ZD1->ZD1_LOCAL	:= (_cAlias)->D1_LOCAL
				ZD1->( MsUnLock() )
			EndIf

			(_cAlias)->(DbSkip())
		EndDo

	End Sequence

Return(_aItens)

Static Function zBuscaCd(_cCodProduto)

Local _cRet		:= "RGLOG"
Local cQry      := '' 
Local _cAlsSBM 	:= GetNextAlias()  

	If Select(_cAlsSBM) > 0
		(_cAlsSBM)->(dbCloseArea())
	EndIf

	cQry := " SELECT BM_CODMAR  FROM "+RetSqlName("SB1")+" SB1 "
	cQry += " 	INNER JOIN "+RetSqlName("SBM")+" SBM "
	cQry += " 	ON SBM.BM_FILIAL = SB1.B1_FILIAL "
	cQry += " 	AND SBM.BM_GRUPO = SB1.B1_GRUPO "
	cQry += " 	AND SBM.D_E_L_E_T_ = ' ' "
	cQry += " WHERE SB1.B1_FILIAL = '" + FWxFilial("SB1") +"' "
	cQry += " AND SB1.B1_COD = '"  + alltrim(_cCodProduto)  + "' "
	cQry += " AND SB1.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cAlsSBM,.T.,.F.)
	
	dbSelectArea(_cAlsSBM)
	(_cAlsSBM)->(dbGoTop())

    If (_cAlsSBM)->(!EOF())

		If (_cAlsSBM)->BM_CODMAR == "CHE"
		
			_cRet := "PREP"

		Else
			
			_cRet := "RGLOG"

		EndIf

	EndIf

	(_cAlsSBM)->(dbCloseArea())

Return(_cRet)

Static Function zBuscaInv(_cHawb, _cFornec, _cLjFornec, cNota)

Local _cRet		:= cNota
Local cQry      := '' 
Local _cAlsSW9 	:= GetNextAlias()  

	If Select(_cAlsSW9) > 0
		(_cAlsSW9)->(dbCloseArea())
	EndIf

	cQry := " SELECT W9_INVOICE FROM " +RetSqlName("SW9")+" SW9 "
	cQry += " 	WHERE SW9.W9_FILIAL = '" + FWxFilial("SW9") +"' "
 	cQry += " 	AND SW9.W9_HAWB	= '"  + alltrim(_cHawb)  + "' "
 	cQry += " 	AND SW9.W9_FORN = '"  + alltrim(_cFornec)  + "' "
 	cQry += " 	AND SW9.W9_FORLOJ = '"  + alltrim(_cLjFornec)  + "' "
  	cQry += " 	AND SW9.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cAlsSW9,.T.,.F.)
	
	dbSelectArea(_cAlsSW9)
	(_cAlsSW9)->(dbGoTop())

    If !(_cAlsSW9)->(!EOF())

		_cRet := (_cAlsSW9)->W9_INVOICE

	EndIf

	If Empty(_cRet)
		_cRet := cNota
	EndIf


	(_cAlsSW9)->(dbCloseArea())

Return(_cRet)


//******************************************
Static Function zPostRg(oJsEnt)
//******************************************
	Local cUrl      := Alltrim(Getmv("CMV_WSR011"))   //http://wmsapi.rgtracking.com.br:8080/interfacewis/entrada/recebimento
	Local cPathUrR  := Alltrim(Getmv("CMV_WSR018"))   // Recebimento NF entrada
	Local aHeader   := {"Content-Type: application/json; charset=utf-8"} //"Content-Type: application/json" 
	Local cRes      := Nil
	Local cHeaderGet:= ""  
	Local nCont		:= 0

	cUrl := cUrl+cPathUrR

	While Valtype(cRes) = "U"
		nCont++
		cRes := HttpPost( cUrl, "", oJsEnt:toJson(), 60, aheader, @cHeaderGet)

		If nCont == 10
			Exit
		EndIf 
	EndDo

	if Valtype(cRes) = "U"
		Return {.f., "Não existe retorno do Host, excedido o numero de tentativas de conexão"}
	EndIf

	oJsRet:FromJSON(cRes)

	if oJsRet:hasProperty("status") = .F.
		Return { .F., "Não retornou Status de Processamento:" + cRes}
	Endif

	if  oJsRet["status"] = 201 
		Return { .T., "Ok, processado" + cRes}
	EndIF

	if  oJsRet["status"] >= 500 .AND. oJsRet["status"] < 600 
		Return { .F., "Erro interno do servidor RgLog" + cRes}
	EndIF

	if  oJsRet["status"] >= 400 .AND. oJsRet["status"] < 500 
		Return { .F., "Erro no corpo" + cRes}
	EndIF

Return { .T. }


//******************************************
Static Function NotificaFalha(cMsgErr)  	// (cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,Rotina,	Observação	, cReplyTo	)Local aMailDest     := StrTokArr( Alltrim(Getmv("CMV_WMS024")),  ";" )
//******************************************
	Local aMailDest     := StrTokArr( Alltrim(Getmv("CMV_WSR013")),  ";" )
	Local cMailDestino  := aMailDest[1]
	Local cMailCopia    := ""
	Local cAssunto	    := "Falha no envio do arquivo de integração de Produto com RGLog"
	Local cHtml         := ""
	Local aAttach       := ""
	Local lMsgErro      := .F.
	Local lMsgOK        := .F.
	Local cObservacao   := ""
	Local cReplyTo	    := ""
	Local cRotina       := "E NF"

    Aeval(aMailDest, {|cIt| cMailCopia += cIT + ";"}, 2, Len(aMailDest))

    cHtml := "<h2>"                                                                       
    cHtml +=    "  Olá " + cMailCopia +                                              "<br/>" 
    cHtml +=    "  Houve uma falha no envio dos arquivos de integração com a RG.      <br/>" 
    cHtml +=    "  Data da execução: " + dtoc(date())  + " " + time() + "             <br/>" 
    cHtml +=   "  Por favor, informe ao setor de T.I.                                 <br/>" 
    cHtml +=    "  Detalhe do erro:                                                   <br/>" 
    cHtml +=    "</h2>"                                                                                                                                   
    cHtml +=    "" +  cMsgErr  + "                                                    <br/>" 
    cHtml +=    " <h5>Esse email foi gerado pela rotina " + FunName() + " </h5>"       

    lRes := u_ZGENMAIL(cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,cRotina,	cObservacao	, cReplyTo	)
return




/*Exemplo Json: Interface de Recebimento de Entrada
{ 
	"usuario":"interfacewis",
	"senha":"sythex@123",
	"recebimento":
{
		"cd_fornecedor":"27",
		"nu_nota_fiscal":"0078002",
		“nu_agenda”:null,
		“nu_serie_nf”:”124”,
		"dt_emissao":"22/05/2014 00:00:00",
		"cd_situacao":"1",
		"cd_empresa":"1",
		“importe_nf”:null,
		“id_autorizacao”:null,
		“cd_func_autorizacion”:null,
		“id_procesado”:”N”,
		“cd_error”:null,
		“dt_procesado”:null,
		“nu_cgc_fornecedor”:null,
		“ds_arquivo”:null,
		“id_nota_fiscal”:null,
		“cd_placa”:null,
		“dt_addrow”:null,
		“tp_nota”:”FOR”,
		"cd_porta":"2",
		"nu_doc_erp":"222AAB500",
		“cd_registro”:null,
		“qt_itens”:111,
		"cd_deposito":"400",
		“cd_motorista”:null,
		“dt_agenda”:null,
		"ds_transportadora":null,
		“cd_loja”:null,
		“id_leva_devolucao”:null,
		“nu_invoice”: “Teste122”,

		"detalhe":
		[
			{
				"cd_empresa":"1",
				"cd_fornecedor":"27",
				“nu_nota_fiscal”:”NF123”,
				“nu_agenda”:null,
				“nu_item”: 111,
				"cd_situacao":"1",
				"cd_produto":"4385165",
				“cd_faixa”:null,
				"qt_produto":"10",
				"dt_fabricacao":null,
				“id_sofre_inspecao”:null,
				“nu_ar”:null,
				“nu_seq_ar”:null,
				“nu_serie_nf”:”123”,
				“nu_cgc_fornecedor”:null,
				“id_skip_lote”:null,
				“nu_ordem_compra”:null,
				“cfop”:null,
				"nu_lote":null,
				"nu_lote_fornecedor":null,
				“nu_serie_produto”:null,
				“dt_addrow”:null,
				“nu_interface”:null,
				“dt_processado”:null,
				“tp_nota”:”FOR”,
				“cd_situacao”:15,
				“nu_doc_erp”: null,
				“cd_registro”:null,
				“id_processado”:null,
				“nu_doc_erp_cdk”:null,
				“ds_loja”:null,
				“nu_pedido”:null,
				“cd_deposito":"400",
				“qt_transferencia”:null,
				“loja”:null,
				“qt_cross_docking”:null,
				“qt_unidade_embalag”:null;
				“cd_filial”:null,
				“nu_cgc_fornecedor”:null,
				“cd_embalagem”:null,
				“dt_validade”:null,
				“nu_volume”: 50
			}
}
*/
	