#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

Static _aMsgRet := {}

/*
===================================================================================================
Programa.:              ZWSR014
Autor....:              CAOA - Evandro Mariano
Data.....:              30/10/2023
Descricao / Objetivo:   Rotina responsavel por enviar os fornecedores para a RgLog
Historico: 				
====================================================================================================
*/
User Function ZWSR014( _cCodigo , _cLoja )

Local _cQrySA2      := ""
Local _cAlsSA2      := GetNextAlias()
Local _aEmpWis      := {}
Local _nX           := 0
Local _cSituacao    := ""
Local _lJob         := IsBlind()
Local _aRetJson     := { .F. } 
Private oJson       := JsonObject():New()

Default _cCodigo    := ""
Default _cLoja      := ""

    DbSelectArea("SA2")

    If _lJob //-- Chamada via schedule
        _cSituacao := '15'
    ElseIf nOpcx == 5
        _cSituacao := '16'
    Else
        _cSituacao := '15'    
    EndIf

    If _lJob
        Conout("ZWSR014 - Integraçao de envio do fornecedor para RGLOG - Inicio: "+DtoC(date())+" "+Time())
    EndIf

    AADD(_aEmpWis, "1002" )
    AADD(_aEmpWis, "1006" )
    AADD(_aEmpWis, "1007" )

    _aMsgRet 	:= {}

    If Select( (_cAlsSA2) ) > 0
        (_cAlsSA2)->(DbCloseArea())
    EndIf

    _cQrySA2 := " "
    _cQrySA2 += "SELECT A2_CGC, A2_COD, A2_LOJA, A2_NOME, A2_NREDUZ, A2_END, A2_BAIRRO, A2_MUN, A2_EST, A2_TEL ,A2_CEP ,A2_CODPAIS "    + CRLF 
    _cQrySA2 += ",A2_INSCR, A2_NREDUZ, A2_TIPO, A2_COD_MUN, A2_MSBLQL, R_E_C_N_O_  AS RECSA2 "                                          + CRLF
    _cQrySA2 += " FROM " + RetSQLName("SA2") + " SA2 "                                                                                  + CRLF
    _cQrySA2 += " WHERE SA2.A2_FILIAL = '" + FwXFilial("SA2") + "' "                                                                    + CRLF
    If !Empty(_cCodigo)                                             
        _cQrySA2 += " 	AND	SA2.A2_COD = '"  + AllTrim(_cCodigo ) + "' "                                                                + CRLF
        _cQrySA2 += " 	AND	SA2.A2_LOJA = '"  + AllTrim(_cLoja ) + "' "                                                                 + CRLF
    EndIf                                               
    _cQrySA2 += " AND SA2.D_E_L_E_T_ = ' ' "                                                                                            + CRLF
    _cQrySA2 += " ORDER BY SA2.A2_COD, A2_LOJA "                                                                                        + CRLF

    DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQrySA2), _cAlsSA2, .T., .T. )

    DbSelectArea(_cAlsSA2)
    (_cAlsSA2)->(dbGoTop())

    If (_cAlsSA2)->( !Eof() )

        While (_cAlsSA2)->( !Eof() )

            If !( (_cAlsSA2)->A2_XINTEG == 'N') //Só realiza a integração para fornecedores permitidos.

                For _nX := 1 to Len(_aEmpWis)

                    oJson := JsonObject():New()

                    oJson['cd_empresa'          ] := _aEmpWis[_nX]
                    oJson['cd_fornecedor'       ] := "9" + AllTrim( (_cAlsSA2)->A2_COD ) + AllTrim( (_cAlsSA2)->A2_LOJA )
                    oJson['cd_uf'               ] := (_cAlsSA2)->A2_EST
                    oJson['cd_municipio'        ] := AllTrim( U_zGENIBGEUF( AllTrim((_cAlsSA2)->A2_EST) ) + (_cAlsSA2)->A2_COD_MUN )
                    oJson['ds_municipio'        ] := AllTrim( (_cAlsSA2)->A2_MUN )
                    oJson['nm_municipio'        ] := AllTrim( (_cAlsSA2)->A2_MUN )
                    oJson['cd_cgc_fornecedor'   ] := IiF( AllTrim( (_cAlsSA2)->A2_TIPO ) == 'X', "9" + AllTrim( (_cAlsSA2)->A2_COD ) + AllTrim( (_cAlsSA2)->A2_LOJA ), (_cAlsSA2)->A2_CGC )
                    oJson['ds_razao_social'     ] := AllTrim( (_cAlsSA2)->A2_NOME )
                    oJson['ds_endereco'         ] := AllTrim( (_cAlsSA2)->A2_END )
                    oJson['ds_bairro'           ] := AllTrim( (_cAlsSA2)->A2_BAIRRO )
                    oJson['nu_telefone'         ] := ""
                    oJson['nm_gerente'          ] := ""         //Buscar no cadastro de gerentes
                    oJson['nu_inscricao'        ] := AllTrim( (_cAlsSA2)->A2_INSCR )
                    oJson['fg_devolucao'        ] := ""
                    oJson['cd_situacao'         ] := IiF( (_cAlsSA2)->A2_MSBLQL == "1", "16" , _cSituacao )
                    oJson['dt_situacao'         ] := ""
                    oJson['cd_postal'           ] := ""
                    oJson['cd_pais'             ] := ""
                    oJson['cd_empresa_sap'      ] := ""
                    oJson['nm_fantasia'         ] := AllTrim( (_cAlsSA2)->A2_NREDUZ )
                    oJson['cd_cep'              ] := AllTrim( (_cAlsSA2)->A2_CEP )
                    oJson['nu_fax'              ] := ""
                    oJson['nu_telefone2'        ] := ""
                    oJson['tp_fornecedor'       ] := ""
                    oJson['dt_addrow'           ] := DtoC( dDataBase )+' '+Time()
                    oJson['nu_interface'        ] := ""
                    oJson['dt_procesado'        ] := ""
                    oJson['cd_registro'         ] := ""
                    oJson['id_procesado'        ] := "N"
                    oJson['cd_deposito'         ] := IiF( _aEmpWis[01] == "1002" ,"PREP" ,"RGLOG" )
                    oJson['cd_fornecedor_erp'   ] := "9" + AllTrim( (_cAlsSA2)->A2_COD ) + AllTrim( (_cAlsSA2)->A2_LOJA )
                    oJson['id_nacional'         ] := ""
                    oJson['cd_placa'            ] := ""
                    oJson['cd_tipo_veiculo'     ] := ""
                    oJson['id_proprio'          ] := ""

                    If _lJob
                        _aRetJson := zEnviaJson(oJson)
                    Else
                        FWMsgRun(, {|| _aRetJson := zEnviaJson(oJson) }, "Envio do fornecedor", "Enviando, aguarde por favor...")
                    EndIf

                    If _aRetJson[1]
            
                        SA2->(DbGoTo((_cAlsSA2)->RECSA2))
                        RecLock("SA2",.F.) 
                            SA2->A2_XINTEG := "X"   //-- X = Integrado RgLog
                        SA2->( MsUnLock() )

                    Else
                        
                        If _lJob
                            Conout("ZWSR014 - Erro no envio do fornecedor retorno do Json: " + Alltrim(_aRetJson[2]) +" - "+DtoC(date())+" "+Time())
                        Else
                            MsgInfo("Erro no envio do fornecedor retorno do Json: " + Alltrim(_aRetJson[2]), "ZWSR014")
                        EndIf

                    EndIf
                    
                Next _nX
            Else
                If _lJob
                    Conout("ZWSR014 - Fornecedor está cadastrado para não enviar integração para a RgLog - "+DtoC(date())+" "+Time())
                Else
                    MsgInfo("Fornecedor está cadastrado para não enviar integração para a RgLog", "ZWSR014")
                EndIf
            EndIf
            (_cAlsSA2)->(DbSkip())
        EndDo
        (_cAlsSA2)->(DbCloseArea())
    Else
        If _lJob
            Conout("ZWSR014 - Não localizado fornecedor para envio - "+DtoC(date())+" "+Time())
        Else
            MsgInfo("Não localizado fornecedor para envio", "ZWSR014")
        EndIf
    EndIf

    If _lJob
        Conout("ZWSR014 - Integraçao de envio do fornecedor para RGLOG - Termino: "+DtoC(date())+" "+Time())
    EndIf

Return(_aRetJson[1])


/*
===================================================================================================
Programa.:              ZWSR014
Autor....:              CAOA - Evandro Mariano
Data.....:              30/10/2023
Descricao / Objetivo:   Rotina responsavel por enviar os fornecedores para a RgLog
Historico: 				
====================================================================================================
*/
Static Function zEnviaJson(oJson)

Local _cUrl         := Alltrim(Getmv("CMV_WSR011")) + Alltrim(Getmv("CMV_WSR008")) 
Local _cUsuario     := Alltrim(Getmv("CMV_WSR009")) // Usuário
Local _cSenha       := Alltrim(Getmv("CMV_WSR010")) // Senha encodada no Postman com o tipo Basic
Local _cEntidade    := "fornecedor"
Local _aHeader      := {"Content-Type: application/json; charset=utf-8"} //"Content-Type: application/json" 
Local _cHeaderGet   := ""  
Local _cRetRest     := Nil
Local _nCont		:= 0
Local oJsRet        := JsonObject():New()

Private _cErrPost   :=""

oJsonEnv:=JsonObject():New()

oJsonEnv["usuario"      ] := _cUsuario
oJsonEnv["senha"        ] := _cSenha
oJsonEnv[_cEntidade     ] := oJson

_cErrPost := oJsonEnv:toJson()

While Valtype(_cRetRest) = "U"
   _nCont++
   _cRetRest := HttpPost( _cUrl, "", oJsonEnv:toJson(), 60, _aHeader, @_cHeaderGet)

   If _nCont == 10
      Exit
   EndIf 
EndDo

If Valtype(_cRetRest) = "U"
    Return {.f., "Não existe retorno do Host, excedido o numero de tentativas de conexão"}
EndIf

oJsRet:FromJSON(_cRetRest)

If oJsRet:hasProperty("status") = .F.
    Return { .F., "Não retornou Status de Processamento:" + _cRetRest}
EndIf

If  oJsRet["status"] = 201 
    Return { .T., "Ok, processado" + _cRetRest}
EndIf

If  oJsRet["status"] >= 500 .AND. oJsRet["status"] < 600 
    Return { .F., "Erro interno do servidor RgLog" + _cRetRest}
EndIf

If  oJsRet["status"] >= 400 .AND. oJsRet["status"] < 500 
    Return { .F., "Erro no corpo" + _cRetRest}
EndIf

Return() 
