#Include "Protheus.ch"
#Include "RestFul.ch"
#include "topconn.ch"
#Include "tbiconn.ch"
#include "fileio.ch"
#INCLUDE "FWMVCDEF.CH"
 
#define CRLF chr(13) + chr(10)

/*WSRESTFUL WSR008 DESCRIPTION " SERVIÇO REST DE MANIPULAÇÃO DA MOVIMENTAÇÃO INTERNA" FORMAT  "application/json"
	WSDATA cCodProd		AS STRING 	
	WSDATA SearchKey 	AS STRING	OPTIONAL
	WSDATA Page		    AS INTEGER	OPTIONAL
	WSDATA PageSize		AS INTEGER	OPTIONAL
    WSDATA cSearchKey   AS STRING   OPTIONAL

ENDWSRESTFUL

//-------------------------------------------------------------------
Exemplo do layout de envio em JSON confirmação de movimentação de estoques   //Exemplo do layout de retorno em JSON
{
    "usuario":"interfacewis",
	"senha":"sythex@123",
	"nu_doc_erp":null
{
	"cd_empresa”:”1",
	"cd_produto”:”PROD001",
	“qt_movimento”:”1”,
	“dt_movimento”:null,
	“nu_movimento”:”11”,
	“cd_local_ori”:”ERP”,
	“cd_local_des”:”WMS”,
	“dt_procesado”:null,
	“id_procesado”:”N”,
	“dt_addrow”:null,
	“cd_registro”:”888”,
	“cd_funcionario”:”1”,
	“cd_deposito”:”001”,
	“tp_movimento”:”T”,
	“cd_faixa”:”111”,
	“tp_tipo”:”WIS”,
	“tp_ajuste”:”M”,
	“id_avariado”:”N”,
	“id_calidad”:null,
	“qt_ajustada”:null,
	“nu_seq”:null,
	“cd_tipo”:null,
	“nu_lote”:null,
	“nu_documento”:”7777”,
	“nu_pedido_origem”:null,
	“cd_error”:null,
	“id_fim”:null,
	“id_sequencia”:null,
	“cd_motivo”:null,
	“cd_drop_origem”:null,
	“cd_drop_destino”:null,
	“nm_funcionario”:null,
	“id_operacao”:null,
	“qt_saldo_origem”:null,
	“qt_saldo_destino”:null,
	“nu_interface”:null,
	“id_processado”:”N”,
	“dt_processado”:null,
	“nu_serie_produto”:null
	}
}
*/
/*{Protheus.doc} Post
 MOVIMENTAÇÃO INTERNA
@return lRet			, caracter, JSON com os Produtos.
@author		A.Carlos
@since		07/12/2021
@version	12.1.27
*/
User FUNCTION ZWSR008()     //cEndPoint, oJson
Local cQrySD3    := ""
Local cSitua     := "" 
Local FlagLoc    := .F.
Local aErrRg     := {}
Local aResRg     := {}

DbSelectArea("SD3")

    IF nOpcx == 5
        cSitua := '16'
    ELSE
        cSitua := '15'    
    ENDIF
 
	cQrySD3 := "SELECT"													        + CRLF
	cQrySD3 += " D3_FILIAL,D3_COD,D3_TM,D3_EMISSAO,D3_DOC,D3_USUARIO,D3_QUANT," + CRLF
	cQrySD3 += " SD3.R_E_C_N_O_ RECNO,D3_LOCALIZ,D3_UM"                         + CRLF
	cQrySD3 += " FROM "	+ retSQLName("SD3") + " SD3"					        + CRLF
	cQrySD3 += " WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'" 		        + CRLF										
	cQrySD3 += " 	AND	SD3.D3_TM IN ('499','999')"	       				        + CRLF
	cQrySD3 += " 	AND	SD3.D_E_L_E_T_	<>	'*'"						        + CRLF
    cQrySD3 += " 	AND	SD3.D3_COD   = '" + alltrim(cCodProd) + "'"		        + CRLF

	If Select("QRY_MVI") > 0
		QRY_MVI->(dbCloseArea())
	EndIf

	cQrySD3  := ChangeQuery(cQrySD3)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySD3),"QRY_MVI",.T.,.F.)
	dbSelectArea("QRY_MVI")
	QRY_MVI->(dbGoTop())

	WHILE (QRY_MVI->( !Eof() ))
        oJsMovI:=JsonObject():New()
	    oJsMovI["cd_empresa"]           := "1"
		oJsMovI["cd_produto"]           := Alltrim(SUBSTR(QRY_MVI->D3_COD,1,23))
		oJsMovI["qt_movimento"]         := QRY_MVI->D3_QUANT
		oJsMovI["dt_movimento"]         := QRY_MVI->D3_EMISSAO
		oJsMovI["nu_movimento"]         := "11"
		oJsMovI["cd_local_ori"]         := "ERP"	
		oJsMovI["cd_local_des"]         := "WMS"             
		oJsMovI["dt_procesado"]         := ""                 
		oJsMovI["id_procesado"]         := "N"               //Fixo pelo exemplo da RgLog
        oJsMovI["dt_addrow"]            := ""
        oJsMovI["cd_registro"]          := "888"
        oJsMovI["cd_funcionario"]       := "1"                //Fixo pelo exemplo da RgLog
        oJsMovI["cd_deposito"]          := "001"              //Fixo pelo exemplo da RgLog
        oJsMovI["tp_movimento"]         := "T"                //Fixo pelo exemplo da RgLog
        oJsMovI["cd_faixa"]             := "111"              //Fixo pelo exemplo da RgLog
        oJsMovI["tp_tipo"]              := "WIS"              //Fixo pelo exemplo da RgLog
        oJsMovI["tp_ajuste"]            := "M"                //Fixo pelo exemplo da RgLog
        oJsMovI["id_avariado"]          := "N"                //Fixo pelo exemplo da RgLog
        oJsMovI["id_calidad"]           := ""                 //Fixo pelo exemplo da RgLog
        oJsMovI["qt_ajustada"]          := ""                 //Fixo pelo exemplo da RgLog
        oJsMovI["nu_seq"]               := "" 
        oJsMovI["cd_tipo"]              := "" 
        oJsMovI["nu_lote"]              := "" 
        oJsMovI["nu_documento"]         := "777"              //Fixo pelo exemplo da RgLog
        oJsMovI["nu_pedido_origem"]     := "" 
        oJsMovI["cd_error"]             := "" 
        oJsMovI["id_fim"]               := "" 
        oJsMovI["id_sequencia"]         := ""                  //Fixo pelo exemplo da RgLog
        oJsMovI["cd_motivo"]            := ""                  //Fixo pelo exemplo da RgLog
        oJsMovI["cd_drop_origem"]       := ""                  //Fixo pelo exemplo da RgLog
        oJsMovI["cd_drop_destino"]      := "" 
        oJsMovI["nm_funcionario"]       := "" 
        oJsMovI["id_operacao"]          := "" 
        oJsMovI["qt_saldo_origem"]      := "" 
    	oJsMovI["qt_saldo_destino"]     := "" 
        oJsMovI["nu_interface"]         := "" 
        oJsMovI["id_procesado"]         := "N" 
        oJsMovI["dt_procesado"]         := "" 
        oJsMovI["nu_serie_produto"]     := "" 

		FWMsgRun(, {|| aResRg := zPostRg(oJsMovI) }, "Envio de Mov. Interna", "Por favor aguarde...")

		If aResRg[1] = .F.
			Aadd(aErrRg, aResRg[2]) 
			NotificaFalha(aResRg[2])
		Else

            SD3->(DbGoTo(QRY_MVI->RECNO))
			WHILE FlagLoc  = .F.

				FlagLoc := RecLock("SD3",.F.) 
				If  FlagLoc = .T. 
					//SD3->D3_XINTEG := "S"
					SD3->( MsUnLock() )
				ELSE
				    SLEEP(10000)
				EndIf

            ENDDO
		
		EndIf

		QRY_MVI->(DbSkip())

    ENDDO

    QRY_MVI->(DBCLOSEAREA())

RETURN()


//******************************************
Static Function zPostRg(oJsMovI)  
//******************************************
Local cUrl      := Alltrim(Getmv("CMV_WMS020"))
//Local cPathUrl  := Alltrim(Getmv("CMV_WMS023")) 
Local oJsRet    := JsonObject():New()
Local oJsonEnv  := JsonObject():New()  
Local aHeader   := {"Content-Type: application/json; charset=utf-8"}  //"Content-Type: application/json"
Local cRes      := Nil
Local cHeaderGet:= ""
Local nCont		:= 0

oJsonEnv["usuario"]    := Alltrim(Getmv("CMV_WMS021")) // Usuário
oJsonEnv["senha"]      := Alltrim(Getmv("CMV_WMS022")) // Senha encodada no Postman com o tipo Basic
oJsonEnv["nu_doc_erp"] := oJsMovI

While Valtype(cRes) = "U"
   nCont++
   cRes := HttpPost( cUrl, "", oJsonEnv:toJson(), 60, aheader, @cHeaderGet)

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

if  oJsRet["status"] >= 400 .AND. oJsRet["status"] < 500 
    Return { .F., "Erro no corpo" + cRes}
EndIF

if  oJsRet["status"] >= 500 .AND. oJsRet["status"] < 600 
    Return { .F., "Erro interno do servidor RgLog" + cRes}
EndIF

Return

//******************************************
Static Function NotificaFalha(cMsgErr)  	// (cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,Rotina,	Observação	, cReplyTo	)Local aMailDest     := StrTokArr( Alltrim(Getmv("CMV_WMS024")),  ";" )
//******************************************
Local aMailDest     := StrTokArr( Alltrim(Getmv("CMV_WMS024")),  ";" )
Local cMailDestino  := aMailDest[1]
Local cMailCopia    := ""
Local cAssunto	    := "Falha no envio do arquivo de integração de Movimento Interno com a RgLog"
Local cHtml         := ""
Local aAttach       := ""
Local lMsgErro      := .F.
Local lMsgOK        := .F.
Local cObservacao   := ""
Local cReplyTo	    := ""
Local cRotina       := "I/A MVI"

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
