#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#define CRLF chr(13) + chr(10)

/*
======================================================================================
Programa.:              ZWSR013
Autor....:              CAOA - Fagner Barreto
Data.....:              
Descricao / Objetivo:   Schedule de integra��o de faturamento para RGLOG
======================================================================================
*/
User Function ZWSR013()
	Local aErrRg     := {}
	Local cQry       := '' 
	Local _cUsua     := Alltrim(Getmv("CMV_WSR016")) // Usu�rio
	Local _cSenha    := Alltrim(Getmv("CMV_WSR017")) // Senha encodada no Postman com o tipo Basic
	Local oJsConFat
	Local _cAlias 	 := GetNextAlias()   
	Local aResRg	 := { .F. } 
    Local FlagLoc    := .F.
    Local cDataEmis  := ""
	Local cDataBase  := ""
	Local __oJson

	Default cNota	 := ""
	Default cSerie	 := ""
	Default cForn	 := ""
	Default cLoja	 := ""

	Private oJsRet    := JsonObject():New()
	Private __cArqTxt   := "\spool\JSON_ZWSR013_" + cValToChar(ThreadID()) + ".txt"

	//--Filtra apenas por Barueri
	IF !( FWCodEmp() = '2020' .And. FWFilial() = '2001' )
		Return
	EndIf

    Conout("ZWSR013 - Integra�ao de confirmacao de faturamento para RGLOG - Inicio "+DtoC(date())+" "+Time())

    cQry := " SELECT "  + CRLF 
    cQry += "   SF2.R_E_C_N_O_ AS RECSF2, "   + CRLF 
    cQry += "   F2_DOC, " + CRLF 
    cQry += "   F2_SERIE, " + CRLF 
    cQry += "   F2_CHVNFE, " + CRLF 
    cQry += "   F2_EMISSAO, " + CRLF
    cQry += "   A1_CGC, " + CRLF 
	cQry += "   VS1_XMARCA, " + CRLF 
    cQry += "   VS1_XPICKI, " + CRLF 
    cQry += "   VS1_XTPPED " + CRLF
    cQry += " FROM "       + RetSqlName("SF2") + " SF2 "    + CRLF
    cQry += " INNER JOIN " + RetSqlName("VS1") + " VS1 "    + CRLF
	cQry += "   ON VS1.VS1_FILIAL = '" + FWxFilial("VS1") + "' "    + CRLF
	cQry += "   AND VS1.VS1_NUMNFI = SF2.F2_DOC "   + CRLF
	cQry += "   AND VS1.VS1_SERNFI = SF2.F2_SERIE " + CRLF
	cQry += "   AND VS1.D_E_L_E_T_ = ' ' "  + CRLF
    cQry += " INNER JOIN " + RetSqlName("SA1") + " SA1 "    + CRLF
	cQry += "   ON SA1.A1_FILIAL = '" + FWxFilial("SA1") + "' "    + CRLF
    cQry += "   AND SA1.A1_COD = SF2.F2_CLIENTE "    + CRLF
	cQry += "   AND SA1.A1_LOJA = SF2.F2_LOJA "    + CRLF
	cQry += "   AND SA1.D_E_L_E_T_ = ' ' "    + CRLF
    cQry += " INNER JOIN " + RetSqlName("SF3") + " SF3 "    + CRLF
	cQry += "   ON SF3.F3_FILIAL = '" + FWxFilial("SF3") + "' " + CRLF
	cQry += "   AND SF3.F3_CLIEFOR = SF2.F2_CLIENTE "   + CRLF
	cQry += "   AND SF3.F3_LOJA = SF2.F2_LOJA "   + CRLF
	cQry += "   AND SF3.F3_NFISCAL = SF2.F2_DOC "   + CRLF
	cQry += "   AND SF3.F3_SERIE = SF2.F2_SERIE "   + CRLF
	cQry += "   AND SF3.F3_CODRSEF = '100' "   + CRLF //-- Autorizado o uso da NF-e
	cQry += "   AND SF3.F3_DTCANC = ' ' "   + CRLF
	cQry += "   AND SF3.D_E_L_E_T_ = ' ' "   + CRLF
    cQry += " INNER JOIN " + RetSqlName("SZK") + " SZK "    + CRLF
    cQry += "   ON SZK.ZK_FILIAL = '" + FWxFilial("SZK") + "' " + CRLF
	cQry += "   AND SZK.ZK_XPICKI = VS1.VS1_XPICKI " + CRLF
	cQry += "   AND SZK.ZK_NF = VS1.VS1_NUMNFI " + CRLF
	cQry += "   AND SZK.ZK_SERIE = VS1.VS1_SERNFI " + CRLF
	cQry += "   AND SZK.D_E_L_E_T_ = ' ' " + CRLF
    cQry += " WHERE SF2.F2_FILIAL = '" + FWxFilial("SF2") + "' " + CRLF
	cQry += "   	AND SF2.F2_CHVNFE <> ' ' "   + CRLF
	cQry += "   	AND SF2.F2_XINTEG <> 'X' "   + CRLF
    cQry += "   	AND SF2.D_E_L_E_T_ = ' ' "   + CRLF
    cQry += " GROUP BY SF2.R_E_C_N_O_, F2_DOC, F2_SERIE, "   + CRLF
    cQry += "   F2_CHVNFE, F2_EMISSAO, A1_CGC, VS1_XMARCA, VS1_XPICKI, VS1_XTPPED "   + CRLF

    If Select(_cAlias) > 0
		(_cAlias)->(dbCloseArea())
	EndIf

	cQry  := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cAlias,.T.,.F.)
	dbSelectArea(_cAlias)
	(_cAlias)->(dbGoTop())

    If (_cAlias)->(!EOF())

        WHILE ((_cAlias)->( !Eof() ))

            cDataEmis   :=  SubStr( (_cAlias)->F2_EMISSAO ,1 ,4) + '-' +;
                            SubStr( (_cAlias)->F2_EMISSAO ,5 ,2 ) + '-' +;
                            SubStr( (_cAlias)->F2_EMISSAO ,7 ,2 )

			cDataBase := 	Substr(DTOC(dDatabase),7,4) +'-'+;
							Substr(DTOC(dDatabase),4,2) +'-'+;
							Substr(DTOC(dDatabase),1,2)
            
			FreeObj(oJsConFat)                     
			oJsConFat := JsonObject():new()
			oJsConFat["usuario"]    := _cUsua    // Usu�rio
            oJsConFat["senha"]      := _cSenha   // Senha encodada no Postman com o tipo Basic
            oJsConFat['faturamento']:=JsonObject():New()
            oJsConFat['faturamento']['nu_pedido']           := AllTrim( (_cAlias)->VS1_XPICKI )
            oJsConFat['faturamento']['cd_cliente']          := (_cAlias)->A1_CGC 
			oJsConFat['faturamento']['cd_empresa']          := 1	//SM0->M0_CGC Sidnei ira verificar e retornar ser� c�digo fixo
            oJsConFat['faturamento']['cd_roteiro']          := ""  
            oJsConFat['faturamento']['cd_deposito']         := IiF( (_cAlias)->VS1_XMARCA == "CHE", "002", "006" )
            oJsConFat['faturamento']['nu_serie_nota'] 	    := ""
            oJsConFat['faturamento']['nu_serie_nf'] 	    := AllTrim( (_cAlias)->F2_SERIE )
            oJsConFat['faturamento']['nu_documento']        := ""
            oJsConFat['faturamento']['dt_emissao_nf']       := cDataEmis
            oJsConFat['faturamento']['dt_addrow']           := cDataBase
            oJsConFat['faturamento']['dt_processado']       := ""
            oJsConFat['faturamento']['id_processado']       := "N" //-- Fixo pelo Exemplo RGLOG
			oJsConFat['faturamento']['dt_emissao']          := cDataEmis 
            oJsConFat['faturamento']['user_emissao']        := ""
            oJsConFat['faturamento']['vl_nf']               := ""
            oJsConFat['faturamento']['nu_danfe']            := (_cAlias)->F2_CHVNFE   
			oJsConFat['faturamento']['cd_modelo_nf'] 	    := ""
            oJsConFat['faturamento']['nu_nota_fiscal']      := Val(AllTrim( (_cAlias)->F2_DOC ))
            oJsConFat['faturamento']['cd_transportadora']   := ""
			oJsConFat['faturamento']['cd_cgc_cliente']      := (_cAlias)->A1_CGC 
            oJsConFat['faturamento']['nu_separacao'] 	    := "" //--Verificar
			oJsConFat['faturamento']['ps_liquido'] 	        := ""
            oJsConFat['faturamento']['vl_nota']   	  	    := ""
            oJsConFat['faturamento']['ps_bruto'] 	  	    := ""
			oJsConFat['faturamento']['tp_pedido'] 	  	    := zBuscaTp( AllTrim( (_cAlias)->VS1_XTPPED ) )
            oJsConFat['faturamento']['id_nota_cancelada']   := ""

			If IsBlind()
				aResRg := zPostRg(oJsConFat, @__oJson)
			Else
				FWMsgRun(, {|| aResRg := zPostRg(oJsConFat, @__oJson) }, "Envio de Confirma��o de Faturamento", "Por favor aguarde...")
			EndIf

            FlagLoc := .F.  //--Reinicializa variavel

            If !aResRg[1]

				zCriaAnexo(__oJson) //--Cria TXT com o json para envio como anexo do e-mail de falha

				Aadd(aErrRg, aResRg[2]) 
				NotificaFalha(aResRg[2])

            Else

                SF2->( DbGoTo( (_cAlias)->RECSF2 ) )

                While !FlagLoc

                    FlagLoc := RecLock( "SF2", .F. ) 

                    If FlagLoc 
                        SF2->F2_XINTEG := "X" //-- X = Integrado RgLog
                        SF2->( MsUnLock() )
                    Else
                        Sleep(10000)
                    EndIf

                EndDo

            EndIf
			
            (_cAlias)->(DbSkip())

		ENDDO

    ENDIF

	If Select(_cAlias) <> 0
		(_cAlias)->(DbCloseArea())
		Ferase(_cAlias+GetDBExtension())
	Endif 

    Conout("ZWSR013 - Integra�ao de confirmacao de faturamento para RGLOG - Final "+DtoC(date())+" "+Time())

Return

//Busca o tipo de pedido de acordo com o De/Para RgLog
Static Function zBuscaTp(_cTpPedido)

Local _cRet		:= "C"
Local _cQry      := '' 
Local _cAlsVX5 	:= GetNextAlias()  

	If Select(_cAlsVX5) > 0
		(_cAlsVX5)->(dbCloseArea())
	EndIf

	_cQry := " SELECT VX5_DESCRI FROM "+RetSqlName("VX5")+" VX5 "
	_cQry += " WHERE VX5.VX5_FILIAL = '" + FWxFilial("VX5") +"' "
	_cQry += " AND VX5.VX5_CHAVE = 'Z04' "
	_cQry += " AND VX5.VX5_CODIGO = '"  + AllTrim(_cTpPedido)  + "' "
	_cQry += " AND VX5.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlsVX5,.T.,.F.)
	
	dbSelectArea(_cAlsVX5)
	(_cAlsVX5)->(dbGoTop())

    If (_cAlsVX5)->(!EOF())
		
		_cRet := AllTrim((_cAlsVX5)->VX5_DESCRI)

	EndIf

	(_cAlsVX5)->(dbCloseArea())

Return(_cRet)

Static Function zPostRg(oJsConFat, __oJson)
	Local cUrl          := Alltrim(Getmv("CMV_WSR011"))   //-- http://wmsapi.rgtracking.com.br:8080/
	Local cPathUrR      := "interfacewis/entrada/conffaturamento" //-- Criar parametro semelhante a Alltrim(Getmv("CMV_WSR018"))
	Local aHeader       := {"Content-Type: application/json; charset=utf-8"} //"Content-Type: application/json" 
	Local cRes          := Nil
	Local cHeaderGet    := ""  
	Local nCont		    := 0

	cUrl := cUrl+cPathUrR
	__oJson := oJsConFat:toJson() //--Guarda json de envio para anexar ao e-mail de notifica��o de falha

	While Valtype(cRes) = "U"
		nCont++
		cRes := HttpPost( cUrl, "", oJsConFat:toJson(), 60, aheader, @cHeaderGet)

		If nCont == 10
			Exit
		EndIf 
	EndDo

	if Valtype(cRes) = "U"
		Return {.f., "N�o existe retorno do Host, excedido o numero de tentativas de conex�o"}
	EndIf

	oJsRet:FromJSON(cRes)

	if oJsRet:hasProperty("status") = .F.
		Return { .F., "N�o retornou Status de Processamento:" + cRes}
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
Static Function NotificaFalha(cMsgErr)  	// (cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,Rotina,	Observa��o	, cReplyTo	)Local aMailDest     := StrTokArr( Alltrim(Getmv("CMV_WMS024")),  ";" )
//******************************************
	Local aMailDest     := StrTokArr( Alltrim(Getmv("CMV_WSR013")),  ";" )
	Local cMailDestino  := aMailDest[1]
	Local cMailCopia    := ""
	Local cAssunto	    := "Falha no envio do arquivo de integracao de Conf Faturamento com RGLog"
	Local cHtml         := ""
	Local aAttach       := ""
	Local lMsgErro      := .F.
	Local lMsgOK        := .F.
	Local cObservacao   := ""
	Local cReplyTo	    := ""
	Local cRotina       := "E NF"

    If File(__cArqTxt) //--Verifica existencia do arquivo
        aAttach := __cArqTxt
    EndIf

    Aeval(aMailDest, {|cIt| cMailCopia += cIT + ";"}, 2, Len(aMailDest))

    cHtml := "<h2>"                                                                       
    cHtml +=    "  Ol� " + cMailCopia +                                              "<br/>" 
    cHtml +=    "  Houve uma falha no envio dos arquivos de integra��o com a RG.      <br/>" 
    cHtml +=    "  Data da execu��o: " + dtoc(date())  + " " + time() + "             <br/>" 
    cHtml +=   "  Por favor, informe ao setor de T.I.                                 <br/>" 
    cHtml +=    "  Detalhe do erro:                                                   <br/>" 
    cHtml +=    "</h2>"                                                                                                                                   
    cHtml +=    "" +  cMsgErr  + "                                                    <br/>" 
    cHtml +=    " <h5>Esse email foi gerado pela rotina " + FunName() + " </h5>"       

    lRes := u_ZGENMAIL(cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,cRotina,	cObservacao	, cReplyTo	)

	If File(__cArqTxt) //--Verifica existencia do arquivo
        FErase( __cArqTxt ) //--Apaga arquivo da pasta origem
    EndIf

return

/*
=====================================================================================
Programa.:              Scheddef
Autor....:              CAOA - Fagner Barreto
Data.....:              16/02/2021
Descricao / Objetivo:   Fun��o padr�o para habilitar perguntes e inicializar
                        empresa diretamente pela rotina de schedule
=====================================================================================
*/
Static Function Scheddef()
    Local aParam
    Local aOrd   := {}

    aParam := { "P",;
                "PARAMDEF",; //Usado quando n�o ha pergunte
                "",;
                aOrd,;
              }

Return aParam

/*
=====================================================================================
Programa.:              zCriaAnexo
Autor....:              CAOA - Fagner Barreto
Data.....:              07/06/2022
Descricao / Objetivo:   Realiza cria��o de arquivo txt para grava��o do Json de envio 
						que sera anexado ao e-mail de notifica��o de falha
=====================================================================================
*/
Static Function zCriaAnexo(cTxt)
    Local nHandle := FCreate(__cArqTxt)
  
    If nHandle = -1
        conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
    Else
        FWrite(nHandle, cTxt)
        FClose(nHandle)
    EndIf
 
Return

/*Exemplo Json passado pelo Sidney: Envio de Confirma��o de faturamento
{
    "usuario": "caoa.totvs",
	"senha": "CAgka2694X*",
	"faturamento": {
		"nu_pedido": "00000545",
		"cd_cliente": "0",
		"cd_empresa": 1,
		"cd_roteiro": null,
		"cd_deposito": "006",
		"nu_serie_nota": 7,
		"nu_serie_nf": "7",
		"nu_documento": null,
		"dt_emissao_nf": null,
		"dt_addrow": null,
		"dt_processado": null,
		"id_processado": "N",
		"dt_emissao": "2021-01-05",
		"user_emissao": null,
		"vl_nf": null,
		"nu_danfe": "35210929402622004972550010000065601781085960",
		"cd_modelo_nf": null,
		"nu_nota_fiscal": "6560",
		"cd_transportadora": null,
		"cd_cgc_cliente": "010510247000101",
		"nu_separacao": "26757",
		"ps_liquido": null,
		"vl_nota": null,
		"ps_bruto": null,
		"tp_pedido": "C",
		"id_nota_cancelada": null
    }
}
*/
	