//Bibliotecas
#Include "TOTVS.ch"
#Include "Protheus.ch"

/*
=====================================================================================
Programa.:              ZWSR017.PRW
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              26/04/24
Descricao / Objetivo:   Integra��o com API Rest Users padr�o do Protheus para consultar dados de determinado
                        usu�rio e posterirmente realizar o bloqueio deste usu�rio.
Doc. Origem:            GAP153
Solicitante:            Evandro Mariano
Uso......:              JOB que valida usu�rio inativo nos �ltimo xx dias.
Obs......:              https://github.com/jerfweb/API-REST-PROTHEUS/blob/master/API%20PADRAO/API%20USER/fAlterarUsuario.prw
Obs......:              https://api.totvs.com.br/
Obs......:              https://api.totvs.com.br/apidetails/User_v1_000.json
=====================================================================================
*/
User Function ZWSR017(cCodUsr)

    Local oRestClient   := Nil
    Local cUrl		      := ""
    Local cEnd          := ""
    Local aHeadStr		  := {"Content-Type: application/json"}
    Local oObjJson		  := Nil
    Local cStrResul		  := ""
    Local cEmail        := ""
    Local cDispName     := "" 
    Local lAtivUsr      := ""
    Local lContinua     := .F.
    Local lRet          := .F.

    Default cCodUsr       := "" //C�digo do usu�rios a ser bloqueado.
    
    cEnd := AllTrim(SuperGetMv("CMV_ZGNF02", .F., "http://172.28.35.142:34286"))
    cUrl := AllTrim(SuperGetMv("CMV_ZGNF03", .F., "/rest_caoasp01/users/")) 

    Begin Sequence
      
      If Empty(Alltrim(cCodUsr))
        //Return
        Break
      EndIf
      
      //Endere�o da API
      oRestClient := FWRest():New(AllTrim(cEnd))

      //chamada de classe REST com retorno de dados do usu�rio - Verbo GET
      oRestClient:setPath(cUrl+cCodUsr)
      //Consulta - Verbo GET, para obter informa��es do usu�rio.
      If oRestClient:Get(aHeadStr)
        //Deserealiza o Json
        If !FWJsonDeserialize(oRestClient:GetResult(),@oObjJson)
            Conout("[ZWSR017] Ocorreu erro no processamento do Json.")
            //Return
            Break
        ElseIf AttIsMemberOf(oObjJson,"errorCode")
            Conout("[ZWSR017] C�digo de erro: " + DecodeUTF8(oObjJson:errorCode) + " - Mensagem de erro: " + DecodeUTF8(oObjJson:errorMessage))
            //Return
            Break
        Else
            //Recebe Dados do Json
            cStrResul := oRestClient:GetResult()
            Conout("[ZWSR017] M�todo GET realizado com sucesso, dados da opera��o: " + cStrResul)
            lContinua := .T.
        EndIf

        //Grava informa��s para o m�todo PUT para bloquear o usu�rio.
        cEmail    := oObjJson:EMAILS[1]:VALUE
        cDispName := oObjJson:DISPLAYNAME
        lAtivUsr  := oObjJson:ACTIVE //Se for false o usu�rio j� est� bloqueado.
      
        //Se conseguiu obter os dados de usu�rios, procede para bloqueio.
        If lContinua
          If Empty(AllTrim(cCodUsr)) .and. Empty(AllTrim(cDispName))
            Conout("[ZWSR017] Problema com c�digo do usu�rio: " + cCodUsr + " - ou Nome do usu�rio: " + cDispName + " .")
            Break
          EndIf

          If Empty(AllTrim(cEmail))
            cEmail := "@"
          EndIf
        
          //BODY - estrutura basica para update de usu�rio, mais informa��o ler documenta��o.
          cJSon := ' { '
          cJSon += '    "userName":"' + cDispName + '", '
          cJSon += '    "emails":[ '
          cJSon += '       { '
          cJSon += '          "value":"' + cEmail + '", '
          cJSon += '          "primary":true '
          cJSon += '       } '
          cJSon += '    ], '
          cJSon += '    "active":false'
          cJSon += ' } '

          //Bloqueio do usu�rio - Verbo PUT.
          If oRestClient:Put(aHeadStr, cJSon)
            If !FWJsonDeserialize(oRestClient:GetResult(),@oObjJson)
              Conout("[ZWSR017] Ocorreu erro no processamento do Json.")
              //return
              Break
            ElseIf AttIsMemberOf(oObjJson,"errorCode")
              Conout("[ZWSR017] errorCode: " + DecodeUTF8(oObjJson:errorCode) + " - errorMessage: " + DecodeUTF8(oObjJson:errorMessage))
              //return
              Break
            Else
              //Obt�m o resultado da opera��o 
              cStrResul := oRestClient:GetResult()
              Conout("[ZWSR017] Bloqueio realizado, dados da opera��o: " + cStrResul + CRLF;
                + " body do json, m�todo PUT: " + cjSon + " ") 
              lRet := .T.
            EndIf
          EndIf
        
        Else
          //Obt�m o erro e adiciona ao LOG
          cStrResul := oRestClient:GetLastError()
          Conout("[ZWSR017] Erro ao executar m�todo GET, verifique dados: " + cStrResul)
        EndIf
      EndIf

    End Sequence

  //Libera os objetos
  FreeObj(oRestClient)     
  FreeObj(oObjJson)

Return lRet

