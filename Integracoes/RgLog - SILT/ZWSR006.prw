#Include "Protheus.ch"
#Include "RestFul.ch"
#include "topconn.ch"
#Include "tbiconn.ch"
#include "fileio.ch"
#define CRLF chr(13) + chr(10)
	
/*/{Protheus.doc} ZWSR006
Serviço de integração  para integração clientes, fornecedores e transportadoras com execauto
@author 	   A.Carlos
@since 		08/12/2021
@version 	P12
@param		
@type class
@client    
@project 	
/*/

/*WSRESTFUL ZWSR006 DESCRIPTION "Serviço para integração das Entidades (clientes/Fornecedores/Transportadoras)." FORMAT "application/json"
   WSDATA ccNpJcpf      As String
   WSDATA xTipo         AS String
  	WSDATA SearchKey    	AS STRING	OPTIONAL
	WSDATA Page		      AS INTEGER	OPTIONAL
	WSDATA PageSize		AS INTEGER	OPTIONAL
   WSDATA cSearchKey    AS STRING   OPTIONAL

   WSMETHOD GET DESCRIPTION "Realiza a consulta Entidades, Informe o CNPJ." WSSYNTAX "/cCNPJ/Tipo"
ENDWSRESTFUL
 
WSMETHOD GET WSRECEIVE ccNpJcpf, xTipo, cSearchKey, page, pageSize WSSERVICE ZWSR006
*/
USER FUNCTION ZWSR006(_xTipo  ,cCodigo ,cLoja   ,cCGCClifor)        //_xTipo C/F o código pode ser Cliente/Fornecedor
Local cQuery     := ""
Local cAlsQry    := GetNextAlias()
Local cSitua     := ""
Local FlagLoc    := .F.
Local aErrRg     := {}
Local aResRg     := { .F. } 

Default cCodigo      := ""
Default cLoja      := ""
Default cCGCClifor   := ""

Conout("ZWSR006 - Integraçao de envio de entidades para RGLOG - Inicio "+DtoC(date())+" "+Time())

If Empty(cCodigo) //-- Chamada via schedule
   cSitua := '15'
  // _xTipo := 'F'
Else

   IF nOpcx == 5
      cSitua := '16'
   ELSE
      cSitua := '15'    
   ENDIF

EndIF

If  _xTipo = 'F' .or. _xTipo = 'C'     //_xTipo = 'T' .or.
   
   If _xTipo = 'F'       //Fornecedor
      cQuery := "SELECT"															      + CRLF
      cQuery += " A2_CGC        AS cCGC,"										   + CRLF
      cQuery += " A2_COD        AS cCod,"										   + CRLF
      cQuery += " A2_LOJA       AS cLoja,"										   + CRLF
      cQuery += " A2_NOME       AS cNome,"										   + CRLF
      cQuery += " A2_NREDUZ     AS cFantas,"   								   + CRLF
      cQuery += " A2_END        AS cEnder,"   								      + CRLF
      cQuery += " A2_BAIRRO     AS cBai,"	    								   + CRLF
      cQuery += " A2_MUN        AS cMun,"	    								   + CRLF
      cQuery += " A2_EST        AS cEst,"	    								   + CRLF
      cQuery += " A2_TEL        AS cTel,"	    								   + CRLF
      cQuery += " A2_CEP        AS cCep,"	    								   + CRLF
      cQuery += " A2_CODPAIS    AS cdPais,"	    							      + CRLF
      cQuery += " A2_INSCR      AS cInsc,"										   + CRLF
      cQuery += " A2_NREDUZ     AS cNRedz,"										   + CRLF
      cQuery += " A2_TIPO       AS cTipo,"										   + CRLF
      cQuery += " A2_COD_MUN    AS cCodMun, "                               + CRLF
      cQuery += " R_E_C_N_O_  AS cRecno"										      + CRLF
      cQuery += " FROM "	+ retSQLName("SA2") + " SA2"					      + CRLF
      cQuery += " WHERE SA2.A2_FILIAL = '" + xFilial("SA2") + "'" 	      + CRLF
      cQuery += " 	AND	SA2.A2_XINTEG <> 'N'"	       				         + CRLF
      cQuery += " 	AND	SA2.D_E_L_E_T_ = ' '"						      	+ CRLF
      
      If !Empty(cCodigo)
         cQuery += " 	AND	SA2.A2_COD = '"  + alltrim(cCodigo )  + "'"   	+ CRLF
         cQuery += " 	AND	SA2.A2_LOJA = '"  + alltrim(cLoja )  + "'"   	+ CRLF
      EndIf

   Endif

   If _xTipo = 'C'       //Cliente
      cQuery := "SELECT"															      + CRLF
      cQuery += " A1_CGC      AS cCGC ,"										      + CRLF
      cQuery += " A1_COD      AS cCod ,"										      + CRLF
      cQuery += " A1_LOJA     AS cLoja,"										      + CRLF
      cQuery += " A1_NOME     AS cNome,"										      + CRLF
      cQuery += " A1_NREDUZ   AS cFantas,"   								      + CRLF
      cQuery += " A1_END      AS cEnder,"   								      + CRLF
      cQuery += " A1_BAIRRO   AS cBai,"	    								      + CRLF
      cQuery += " A1_MUN      AS cMun,"	    								      + CRLF
      cQuery += " A1_EST      AS cEst,"	    								      + CRLF
      cQuery += " A1_TEL      AS cTel,"	    								      + CRLF
      cQuery += " A1_CEP      AS cCep,"	    								      + CRLF
      cQuery += " A1_CODPAIS  AS cdPais,"	    							      + CRLF
      cQuery += " A1_INSCR    AS cInsc,"										      + CRLF
      cQuery += " A1_NREDUZ   AS cNRedz,"										   + CRLF
      cQuery += " R_E_C_N_O_  AS cRecno,"										      + CRLF
      cQuery += " A1_COD_MUN    AS cCodMun "                               + CRLF
      cQuery += " FROM "	+ retSQLName("SA1") + " SA1"					      + CRLF
      cQuery += " WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "'" 	      + CRLF
      cQuery += " 	AND	SA1.A1_XINTEG <> 'N'"	       				         + CRLF
      cQuery += " 	AND	SA1.D_E_L_E_T_ = ' '"						      	+ CRLF

      If !Empty(cCodigo)
         cQuery += " 	AND	SA1.A1_COD = '"  + alltrim(cCodigo )  + "'"	   + CRLF
         cQuery += " 	AND	SA1.A1_LOJA = '"  + alltrim(cLoja )  + "'"	   + CRLF
      EndIf

   Endif

   If Select(cAlsQry) > 0
		(cAlsQry)->(dbCloseArea())
	EndIf

   // Executa a consulta.
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlsQry, .T., .T. )

	dbSelectArea(cAlsQry)
	(cAlsQry)->(dbGoTop())

   If (cAlsQry)->(!EOF())

      WHILE (cAlsQry)->( !Eof() )
         oJsEnt:=JsonObject():New()

         If _xTipo = 'C'       //Cliente
            oJsEnt['cd_empresa'] 	   := "1"
            oJsEnt['cd_cliente']       := "92"       //Fixo pelo exemplo RgLog
            oJsEnt['ds_cliente']       := Alltrim( (cAlsQry)->cNome)
            oJsEnt['id_filial_cliente']:= "S"       //(cAlsQry)->cLoja   Fixo pelo exemplo RgLog
            oJsEnt['cd_rota']      	   := "2"       //Fixo pelo exemplo RgLog
            oJsEnt['ds_trato'] 	      := ""
            oJsEnt['ds_nombre'] 	      := ""
            oJsEnt['ds_apelido'] 		:= Alltrim((cAlsQry)->cFantas)
            oJsEnt['ds_rubro'] 		   := ""
            oJsEnt['cd_cargo'] 	   	:= ""
            oJsEnt['ds_cargo'] 	      := ""
            oJsEnt['ds_direccion']     := ""
            oJsEnt['cd_postal'] 	  	   := ""       //Fixo pelo exemplo RgLog
            oJsEnt['ds_bairro'] 	  	   := Alltrim((cAlsQry)->cBai)
            oJsEnt['ds_localidad'] 	  	:= Alltrim((cAlsQry)->cEst)
            oJsEnt['ds_ddd'] 	  	      := "11"             //tem que existir
            oJsEnt['ds_telefono'] 	  	:= "35097700"       //tem que existir
            oJsEnt['ds_fax'] 	  	      := ""
            oJsEnt['cd_cgc_cliente'] 	:= (cAlsQry)->cCGC
            oJsEnt['nu_inscricao'] 	  	:= Alltrim((cAlsQry)->cInsc)
            oJsEnt['cd_situacao'] 	  	:= cSitua          //15-Ativo   16-Não
            oJsEnt['dt_situacao'] 	  	:= ""
            oJsEnt['cd_uf'] 	  	      := (cAlsQry)->cEst
            oJsEnt['cd_municipio'] 	  	:= AllTrim(U_zGENIBGEUF(AllTrim((cAlsQry)->cEst))+(cAlsQry)->cCodMun)       //08 CARACTERES buscar tabela de municipios IBGE   35001 SP
            oJsEnt['nu_prior_carga'] 	:= ""
            oJsEnt['dt_addrow'] 	  	   := ""               //dToC(date()) + Time()
            oJsEnt['nu_interface'] 	  	:= ""
            oJsEnt['dt_procesado']  	:= ""               //dToC(date()) + Time()
            oJsEnt['cd_registro'] 	  	:= ""
            oJsEnt['id_procesado'] 	   := ""
            oJsEnt['cd_deposito'] 	  	:= "RGLOG"
            oJsEnt['cd_cliente_erp'] 	:= (cAlsQry)->cCGC// Alterado: ZWSR007 busca CNPJ nesta TAG -> Alltrim((cAlsQry)->cCod)+Alltrim((cAlsQry)->cLoja)
            oJsEnt['nm_municipio'] 	  	:= Alltrim((cAlsQry)->cMun)
         
         elseIf _xTipo = 'F'       //Fortnecedor
            If (cAlsQry)->CTIPO == 'X'
               lPause := .T.
            EndIf
            oJsEnt['cd_empresa'] 	   := "1"
            oJsEnt['cd_fornecedor']    := "9"+Alltrim((cAlsQry)->cCod)+Alltrim((cAlsQry)->cLoja)
            oJsEnt['cd_uf'] 	  	      := (cAlsQry)->cEst
            oJsEnt['cd_municipio'] 	  	:= AllTrim(U_zGENIBGEUF(AllTrim((cAlsQry)->cEst))+(cAlsQry)->cCodMun)       //08 CARACTERES buscar tabela de municipios IBGE   35001 SP
            oJsEnt['ds_municipio']     := Alltrim((cAlsQry)->cMun)
            oJsEnt['nm_municipio'] 	  	:= Alltrim((cAlsQry)->cMun)
            oJsEnt['cd_cgc_fornecedor']:= IiF(AllTrim((cAlsQry)->CTIPO) == 'X', "9"+Alltrim((cAlsQry)->cCod)+Alltrim((cAlsQry)->cLoja), (cAlsQry)->cCGC)
            oJsEnt['ds_razao_social']  := Alltrim((cAlsQry)->cNome)
            oJsEnt['ds_endereco'] 	  	:= Alltrim((cAlsQry)->cEnder)
            oJsEnt['ds_bairro'] 	  	   := Alltrim((cAlsQry)->cBai)
            oJsEnt['nu_telefone'] 	  	:= ""
            oJsEnt['nm_gerente'] 	  	:= ""         //Buscar no cadastro de gerentes
            oJsEnt['nu_inscricao'] 	  	:= Alltrim((cAlsQry)->cInsc)
            oJsEnt['fg_devolucao'] 	  	:= ""
            oJsEnt['cd_situacao'] 	  	:= cSitua    //15-Ativo   16-Não
            oJsEnt['dt_situacao'] 	  	:= ""
            oJsEnt['cd_postal'] 	  	   := ""
            oJsEnt['cd_pais']      	   := ""
            oJsEnt['cd_empresa_sap']   := ""
            oJsEnt['nm_fantasia'] 	  	:= Alltrim((cAlsQry)->cFantas)
            oJsEnt['cd_cep'] 	  	      := Alltrim((cAlsQry)->cCep)
            oJsEnt['nu_fax'] 	  	      := ""
            oJsEnt['nu_telefone2']     := ""
            oJsEnt['tp_fornecedor']    := ""
            oJsEnt['dt_addrow'] 	  	   := DtoC(dDatabase)+' '+Time()
            oJsEnt['nu_interface'] 	  	:= ""
            oJsEnt['dt_procesado']  	:= ""          //dToC(date()) + Space(1) + Time()
            oJsEnt['cd_registro'] 	  	:= ""
            oJsEnt['id_procesado']   	:= "N"
            oJsEnt['cd_deposito'] 	  	:= "RGLOG"
            oJsEnt['cd_fornecedor_erp']:= "9"+Alltrim((cAlsQry)->cCod)+Alltrim((cAlsQry)->cLoja)
            oJsEnt['id_nacional']    	:= ""
            oJsEnt['cd_placa'] 	  	   := ""
            oJsEnt['cd_tipo_veiculo'] 	:= ""
            oJsEnt['id_proprio']      	:= ""
         endif
         
         If IsBlind()
            aResRg := zPostRg(oJsEnt,_xTipo)
         Else
            FWMsgRun(, {|| aResRg := zPostRg(oJsEnt,_xTipo) }, "Envio de entidades", "Por favor aguarde...")
         EndIf

        FlagLoc := .F.  //--Reinicializa variavel
        
         If aResRg[1]
            
            IF _xTipo == 'C'

               SA1->(DbGoTo((cAlsQry)->cRecno))
               
               WHILE !FlagLoc

                  FlagLoc := RecLock("SA1",.F.) 

                  If FlagLoc
                     SA1->A1_XINTEG := "X"   //-- X = Integrado RgLog
                     SA1->( MsUnLock() )
                  ELSE
                     SLEEP(10000)
                  EndIf

               ENDDO

            ELSEIF _xTipo == 'F'

               SA2->(DbGoTo((cAlsQry)->cRecno))
               
               WHILE !FlagLoc

                  FlagLoc := RecLock("SA2",.F.) 
                  
                  If FlagLoc
                     SA2->A2_XINTEG := "X"   //-- X = Integrado RgLog
                     SA2->( MsUnLock() )
                  ELSE
                     SLEEP(10000)
                  EndIf

               ENDDO

            ENDIF

         Else
            
            Aadd(aErrRg, aResRg[2]) 
            NotificaFalha(aResRg[2])

         EndIf

      	(cAlsQry)->(DbSkip())

		ENDDO

   ENDIF

Conout("ZWSR006 - Integraçao de envio de entidades para RGLOG - Final "+DtoC(date())+" "+Time())

ENDIF

RETURN aResRg[1]


//******************************************
Static Function zPostRg(oJsEnt,_xTipo)
//******************************************
Local cUrl      := Alltrim(Getmv("CMV_WSR011"))  
Local cUsua     := Alltrim(Getmv("CMV_WSR009")) // Usuário
Local cSenha    := Alltrim(Getmv("CMV_WSR010")) // Senha encodada no Postman com o tipo Basic
Local cPathUrF  := Alltrim(Getmv("CMV_WSR008")) 
Local cPathUrC  := Alltrim(Getmv("CMV_WSR012")) 
Local aHeader   := {"Content-Type: application/json; charset=utf-8"} //"Content-Type: application/json" 
Local cRes      := Nil
Local cHeaderGet:= ""  
Local oJsRet    := JsonObject():New()
Local cEntidade := ""
Local nCont		 := 0

Private _cErrPost:=""

IF _xTipo = 'F'
   cUrl := cUrl+cPathUrF
   cEntidade := "fornecedor"
ELSEIF _xTipo = 'C'
   cUrl := cUrl+cPathUrC
   cEntidade := "cliente"
ENDIF

oJsonEnv:=JsonObject():New()

oJsonEnv["usuario"] := cUsua    // Usuário
oJsonEnv["senha"]   := cSenha   // Senha encodada no Postman com o tipo Basic
oJsonEnv[cEntidade] := oJsEnt

//oRest:SetPostParams( FWJsonSerialize(oJson) )
//oRest:nTimeOut := 10
_cErrPost:=oJsonEnv:toJson()

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

if  oJsRet["status"] >= 500 .AND. oJsRet["status"] < 600 
    Return { .F., "Erro interno do servidor RgLog" + cRes}
EndIF

if  oJsRet["status"] >= 400 .AND. oJsRet["status"] < 500 
    Return { .F., "Erro no corpo" + cRes}
EndIF

Return 


//******************************************
Static Function NotificaFalha(cMsgErr)  	// (cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,Rotina,	Observação	, cReplyTo	)Local aMailDest     := StrTokArr( Alltrim(Getmv("CMV_WMS024")),  ";" )
//******************************************
Local aMailDest     := StrTokArr( Alltrim(Getmv("CMV_WSR013")),  ";" )
Local cMailDestino  := aMailDest[1]
Local cMailCopia    := ""
Local cAssunto	     := "Falha no envio do arquivo de integração de Produto com RGLog"
Local cHtml         := ""
Local aAttach       := ""
Local lMsgErro      := .F.
Local lMsgOK        := .F.
Local cObservacao   := ""
Local cReplyTo	     := ""
Local cRotina       := "I/A Entidade"

    Aeval(aMailDest, {|cIt| cMailCopia += cIT + ";"}, 2, Len(aMailDest))

    cHtml := "<h2>"                                                                       
    cHtml +=    "  Olá " + cMailCopia +                                              "<br/>" 
    cHtml +=    "  Houve uma falha no envio dos arquivos de integração com a RG.      <br/>" 
    cHtml +=    "  Data da execução: " + dtoc(date())  + " " + time() + "             <br/>" 
    cHtml +=   "  Por favor, informe ao setor de T.I.                                 <br/>" 
    cHtml +=    "  Detalhe do erro:                                                   <br/>" 
    cHtml +=    "</h2>"                                                                                                                                   
    cHtml +=    "" +  cMsgErr +                                                       "<br/>" 
    cHtml +=    " <h5>Esse email foi gerado pela rotina " + FunName() + " </h5>"       

    lRes := u_ZGENMAIL(cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,cRotina,	cObservacao	, cReplyTo	)
return
