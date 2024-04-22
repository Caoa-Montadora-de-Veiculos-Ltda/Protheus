#Include "Protheus.ch"
#Include "RestFul.ch"
#include "topconn.ch"
#Include "tbiconn.ch"
#include "fileio.ch"
#INCLUDE "FWMVCDEF.CH"
#define CRLF chr(13) + chr(10)

/*WSRESTFUL ZWSR004 DESCRIPTION " SERVIÇO REST DE MANIPULAÇÃO DO CADASTRO DE PRODUTOS " FORMAT  "application/json"
	WSDATA cCodProd		AS STRING 	
	WSDATA SearchKey 	AS STRING	OPTIONAL
	WSDATA Page		    AS INTEGER	OPTIONAL
	WSDATA PageSize		AS INTEGER	OPTIONAL
    WSDATA cSearchKey   AS STRING   OPTIONAL
	WSMETHOD GET 	DESCRIPTION "INFORME O CÓDIGO DO PRODUTO OU * PARA TODOS"	WSSYNTAX "/CodProd" 	// " Retorna Dados do Produto "
ENDWSRESTFUL

//-------------------------------------------------------------------
http://abdhdu-des-protheus.totvscloud.com.br:45486/rest_des01/ZWSR004?cCodProd=815215H510
[
    {
        "cd_empresa": 1,
        "cd_produto": "815215H510             ",
		"sg_produto": "VIDRO",
        "ds_produto": "VIDRO PORTA LD   -ALTERADO                                  ",
		"ds_reduzida": "VIDRO 1",
        "cd_unidade_medida": "UN",
		"cd_familia_produto": "H-09",
		"cd_rotatividade": null,
		"cd_classe": "NC",
        "ps_liquido": "1",
        "ps_bruto": "1",
        "cd_unid_emb": "UN",
		"qt_unid_emb": "10",
		"cd_ean_basico": "1232355",
        "tp_produto": "MP",
		"id_pesagem": "",
    	"ft_conversao": "4444",
        "vl_cubagem": "4444",
        "pr_venta": "4444",
        "pr_costo": "4444",
	    "cd_situacao": "15",
		"dt_situacao": "",	
	    "qt_dias_validade": null,
        "qt_dias_duracao": null,
        "id_arred_validade": null,
		"tp_peso": null,
        "dif_peso": null,
		"vl_altura": "1",
        "vl_largura": "1",
        "vl_profundidade": "1",
		"dt_addrow": null,
        "nu_interface": null,
        "tp_armazenagem": null,
		"cd_produto_master": "P001000",
        "qt_palete": null,
        "qt_pecas": null,
        "tp_palete": null,
        "id_linha": null,
        "id_processado": null,
        "qt_min_dias_validade": null,
        "id_validade": null,
        "id_numero_serie": null,
        "dt_processado": null,
        "cd_registro": null,
        "cd_fornecedor": null,
        "cd_departamento": null,
		"cd_grupo": "20",
        "cd_linha": "1",
		"cd_grupo_4": null,
        "cd_grupo_5": null,
        "cd_deposito": "12001",
        "ds_cor_produto": null,
        "cd_composicao": null,
        "ds_departamento": "",
        "ds_grupo": "PERSONAGENS",
        "ds_linha": "BRINQUEDOS",
        "ds_composicao": null,
        "cd_produto_antigo": null,
        "cd_produto_capta": null,
        "id_procesado": "N",
        "dt_procesado": null,
        "qt_lastro": null,
        "cd_cgc_fornecedor": null,
        "qt_altura_palete": null,
        "id_controle_sequencia": null,
        "ds_complemento": null
    }
]
*/
//------------------------------------------------------------------------------
//WSMETHOD GET WSRECEIVE cCodProd,  cSearchKey, page, pageSize WSSERVICE ZWSR004
//------------------------------------------------------------------------------
/*{Protheus.doc} Post
 Retorna dados dos Produtos
@return lRet			, caracter, JSON com os Produtos.
@author		A.Carlos
@since		07/12/2021
@version	12.1.27
*/

User Function ZWSR004(cCodProd,_lVisual)     //cEndPoint, oJson
Local cQrySB1    := ""
Local _cAlsSB1 	 := GetNextAlias()   
Local cSitua     := "" 
Local FlagLoc    := .F.
Local aErrRg     := {}
Local aResRg     := { .F. } 
Private _nEmpWis := 1006
Private _cDepWis := "RGLOG"

Default cCodProd    := ""

Conout("WSR004 - Integraçao de envio de produto para RGLOG - Inicio "+DtoC(date())+" "+Time())

    SB1->( DbSetOrder(1) )

    If Empty(cCodProd) //-- Chamada via schedule
        cSitua := '15' 
    Else

        If _lVisual == .T.
            cSitua := '15'    
        Else
            IF nOpcx == 5
                cSitua := '16'
            ELSE
                cSitua := '15'    
            ENDIF
        EndIf
 
    EndIf

    If Select(_cAlsSB1) > 0
		(_cAlsSB1)->(dbCloseArea())
	EndIf

	cQrySB1 := "SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_DESC, SB1.B1_TIPO, SB1.B1_UM, SB1.B1_PESO, SB1.B1_PESBRU, SB1.B1_FAMILIA"      + CRLF
	cQrySB1 += ", SB1.B1_CLASSE, SB1.B1_SITPROD, SB1.B1_GRUPO, SB1.B1_XNUMINM, SB1.R_E_C_N_O_ RECNO, SBM.BM_CODMAR "                    + CRLF 
    cQrySB1 += " LEFT JOIN "+RetSqlName("SBM")+" SBM "						                                                            + CRLF
	cQrySB1 += " 		ON SBM.BM_FILIAL = SB1.B1_FILIAL "					                                                            + CRLF
	cQrySB1 += " 		AND SBM.BM_GRUPO = SB1.B1_GRUPO "					                                                            + CRLF
	cQrySB1 += " 		AND SBM.D_E_L_E_T_ = ' ' "
	cQrySB1 += " FROM "	+ RetSqlName("SB1") + " SB1"					                                                                + CRLF
	cQrySB1 += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "'" 		                                                                + CRLF										
	cQrySB1 += " 	AND	SB1.D_E_L_E_T_ = ' '"						                                                                    + CRLF
    cQrySB1 += " 	AND	SB1.B1_XINTEG = 'S'"	       				                                                                    + CRLF

    If Empty(cCodProd) 
        //--Chamada via schedule
        cQrySB1 += "    AND SB1.B1_COD LIKE 'R%' "  + CRLF //--Regra semelhante a utilizada no PE_MATA010
    Else
        cQrySB1 += " 	AND	SB1.B1_COD   = '" + alltrim(cCodProd) + "'"		        + CRLF
    EndIf

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cAlsSB1,.T.,.F.)
	DbSelectArea(_cAlsSB1)
	(_cAlsSB1)->(dbGoTop())

	While ((_cAlsSB1)->( !Eof() ))

        _nEmpWis := 0
		_cDepWis := ""
        If ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa 02-Franco da Rocha
            If AllTrim((_cAlsSB1)->BM_CODMAR) =="CHE"
                _nEmpWis := 1002
			    _cDepWis := "PREP"
            ElseIf AllTrim((_cAlsSB1)->BM_CODMAR) =="SBR"
                _nEmpWis := 1006
			    _cDepWis := "RGLOG"
            ElseIf AllTrim((_cAlsSB1)->BM_CODMAR) =="HYU"
                _nEmpWis := 1006
			    _cDepWis := "RGLOG"
            EndIf
        ElseIf( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) //90- HMB
            If AllTrim((_cAlsSB1)->BM_CODMAR) =="HYU"
                _nEmpWis := 1008
			    _cDepWis := "RGLOG"
            EndIf
		EndIf

        oJsProd:=JsonObject():New()
	    oJsProd["cd_empresa"]           := _nEmpWis
		oJsProd["cd_produto"]           := Alltrim(SUBSTR((_cAlsSB1)->B1_COD,1,23))
		oJsProd["sg_produto"]           := Alltrim(SUBSTR((_cAlsSB1)->B1_COD,1,20))
		oJsProd["ds_produto"]           := ALLTRIM((_cAlsSB1)->B1_DESC)
		oJsProd["ds_reduzida"]          := Alltrim(SUBSTR((_cAlsSB1)->B1_COD,1,20))
		oJsProd["cd_unidade_medida"]    := (_cAlsSB1)->B1_UM	
		oJsProd["cd_familia_produto"]   := "H-09"             //(_cAlsSB1)->B1_FAMILIA Fixo pelo exemplo da RgLog
		oJsProd["cd_rotatividade"]      := ""                 //A definir
		oJsProd["cd_classe"]            := "NC"               //Fixo pelo exemplo da RgLog
        oJsProd["ps_liquido"]           := "0"
        oJsProd["ps_bruto"]             := "0"
        oJsProd["cd_unid_emb"]          := "CX"               //Fixo pelo exemplo da RgLog
        oJsProd["qt_unid_emb"]          := "1"                //Fixo pelo exemplo da RgLog
        oJsProd["cd_ean_basico"]        := "123456"           //Fixo pelo exemplo da RgLog
        oJsProd["tp_produto"]           := "P"                //Fixo pelo exemplo da RgLog
        oJsProd["id_pesagem"]           := ""                 //Fixo pelo exemplo da RgLog
        oJsProd["ft_conversao"]         := "0"                //Fixo pelo exemplo da RgLog
        oJsProd["vl_cubagem"]           := "0"                //Fixo pelo exemplo da RgLog
        oJsProd["pr_venta"]             := "0"                //Fixo pelo exemplo da RgLog
        oJsProd["pr_costo"]             := "0"                //Fixo pelo exemplo da RgLog
        oJsProd["cd_situacao"]          := cSitua 
        oJsProd["dt_situacao"]          := "" 
        oJsProd["qt_dias_validade"]     := "" 
        oJsProd["qt_dias_duracao"]      := "" 
        oJsProd["id_arred_validade"]    := "" 
        oJsProd["tp_peso"]              := "" 
        oJsProd["dif_peso"]             := "" 
        oJsProd["vl_altura"]            := "0"                 //Fixo pelo exemplo da RgLog
        oJsProd["vl_largura"]           := "0"                 //Fixo pelo exemplo da RgLog
        oJsProd["vl_profundidade"]      := "0"                 //Fixo pelo exemplo da RgLog
        oJsProd["dt_addrow"]            := "" 
        oJsProd["nu_interface"]         := "" 
        oJsProd["tp_armazenagem"]       := "" 
        oJsProd["cd_produto_master"]    := ALLTRIM((_cAlsSB1)->B1_COD)
    	oJsProd["qt_palete"]            := "" 
        oJsProd["qt_pecas"]             := "" 
        oJsProd["tp_palete"]            := "" 
        oJsProd["id_linha"]             := "" 
        oJsProd["dt_procesado"]         := "" 
        oJsProd["qt_min_dias_validade"] := "" 
        oJsProd["id_validade"]          := "" 
        oJsProd["id_numero_serie"]      := "" 
        oJsProd["cd_registro"]          := AllTrim((_cAlsSB1)->B1_XNUMINM) 
        oJsProd["cd_fornecedor"]        := "" 
        oJsProd["cd_departamento"]      := "" 
        oJsProd["cd_grupo"]             := "20"                //Fixo pelo exemplo da RgLog
		oJsProd["cd_linha"]             := "1"                 //Fixo pelo exemplo da RgLog
        oJsProd["cd_grupo_4"]           := "" 
        oJsProd["cd_grupo_5"]           := "" 
        oJsProd["cd_deposito"]          := _cDepWis
        oJsProd["ds_cor_produto"]       := "" 
        oJsProd["cd_composicao"]        := "" 
        oJsProd["ds_departamento"]      := "PECAS"           //Fixo pelo exemplo da RgLog
        oJsProd["ds_grupo"]             := "LAPTOP"               //Definir De x Para
        oJsProd["ds_linha"]             := "GAMER"                //Definir De x Para
        oJsProd["ds_composicao"]        := "" 
        oJsProd["cd_produto_antigo"]    := ""         
        oJsProd["cd_produto_capta"]     := ""  
        oJsProd["id_procesado"]         := "N"              //Fixo pelo exemplo da RgLog
        oJsProd["qt_lastro"]            := ""    
        oJsProd["cd_cgc_fornecedor"]    := ""    
        oJsProd["qt_altura_palete"]     := ""    
        oJsProd["id_controle_sequencia"]:= "" 
        oJsProd["ds_complemento"]       := "" 

        If IsBlind()
            aResRg := zPostRg(oJsProd)
        Else
            FWMsgRun(, {|| aResRg := zPostRg(oJsProd) }, "Envio de produto", "Por favor aguarde...")
        EndIf

        FlagLoc := .F.  //--Reinicializa variavel
        
		If aResRg[1]

            SB1->(DbGoTo((_cAlsSB1)->RECNO))

			WHILE !FlagLoc

				FlagLoc := RecLock("SB1",.F.)

				If FlagLoc
					SB1->B1_XINTEG := "X"   //-- X = Integrado RgLog
					SB1->( MsUnLock() )
				ELSE
				    SLEEP(10000)
				EndIf

            ENDDO

            If !IsBlind()  .AND.  Funname() <> "ZPECF023"
                ApMsgInfo("Produto integrado a RgLog com Sucesso")
            EndIf

		Else

			Aadd(aErrRg, aResRg[2]) 
			NotificaFalha(aResRg[2])
            		
		EndIf

		(_cAlsSB1)->(DbSkip())

    ENDDO

    (_cAlsSB1)->(DBCLOSEAREA())

    Conout("WSR004 - Integraçao de envio de produto para RGLOG - Final "+DtoC(date())+" "+Time())

RETURN aResRg[1]


//******************************************
Static Function zPostRg(oJsProd)  //oJsProd
//******************************************
Local cUrl      := Alltrim(Getmv("CMV_WSR007"))
//Local cPathUrl  := Alltrim(Getmv("CMV_WMS023")) //Fora de uso, está tudo na URL
Local oJsRet    := JsonObject():New()
Local oJsonEnv  := JsonObject():New()  
Local aHeader   := {"Content-Type: application/json; charset=utf-8"}  //"Content-Type: application/json"
Local cRes      := Nil
Local cHeaderGet:= ""
Local nCont     := 0

oJsonEnv["usuario"] := Alltrim(Getmv("CMV_WSR009")) // Usuário
oJsonEnv["senha"]   := Alltrim(Getmv("CMV_WSR010")) // Senha encodada no Postman com o tipo Basic
oJsonEnv["produto"] := oJsProd

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
Local cRotina       := "I/A Prod"

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
