//Bibliotecas
#Include "TOTVS.ch"
#Include "Protheus.ch"

/*
=====================================================================================
Programa.:              ZWSR017.PRW
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              26/04/24
Descricao / Objetivo:   Integração com API Rest Users padrão do Protheus para consultar dados de determinado
                        usuário e posterirmente realizar o bloqueio deste usuário.
Doc. Origem:            GAP153
Solicitante:            Evandro Mariano
Uso......:              JOB que valida usuário inativo nos último xx dias.
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

    Default cCodUsr       := "" //Código do usuários a ser bloqueado.
    
    cEnd := AllTrim(SuperGetMv("CMV_ZGNF02", .F., "http://172.28.35.142:34286"))
    cUrl := AllTrim(SuperGetMv("CMV_ZGNF03", .F., "/rest_caoasp01/users/")) 

    Begin Sequence
      
      If Empty(Alltrim(cCodUsr))
        //Return
        Break
      EndIf
      
      //Endereço da API
      oRestClient := FWRest():New(AllTrim(cEnd))

      //chamada de classe REST com retorno de dados do usuário - Verbo GET
      oRestClient:setPath(cUrl+cCodUsr)
      //Consulta - Verbo GET, para obter informações do usuário.
      If oRestClient:Get(aHeadStr)
        //Deserealiza o Json
        If !FWJsonDeserialize(oRestClient:GetResult(),@oObjJson)
            Conout("[ZWSR017] Ocorreu erro no processamento do Json.")
            //Return
            Break
        ElseIf AttIsMemberOf(oObjJson,"errorCode")
            Conout("[ZWSR017] Código de erro: " + DecodeUTF8(oObjJson:errorCode) + " - Mensagem de erro: " + DecodeUTF8(oObjJson:errorMessage))
            //Return
            Break
        Else
            //Recebe Dados do Json
            cStrResul := oRestClient:GetResult()
            Conout("[ZWSR017] Método GET realizado com sucesso, dados da operação: " + cStrResul)
            lContinua := .T.
        EndIf

        //Grava informaçõs para o método PUT para bloquear o usuário.
        cEmail    := oObjJson:EMAILS[1]:VALUE
        cDispName := oObjJson:DISPLAYNAME
        lAtivUsr  := oObjJson:ACTIVE //Se for false o usuário já está bloqueado.
      
        //Se conseguiu obter os dados de usuários, procede para bloqueio.
        If lContinua
          If Empty(AllTrim(cCodUsr)) .and. Empty(AllTrim(cDispName))
            Conout("[ZWSR017] Problema com código do usuário: " + cCodUsr + " - ou Nome do usuário: " + cDispName + " .")
            Break
          EndIf

          If Empty(AllTrim(cEmail))
            cEmail := "@"
          EndIf
        
          //BODY - estrutura basica para update de usuário, mais informação ler documentação.
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

          //Bloqueio do usuário - Verbo PUT.
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
              //Obtém o resultado da operação 
              cStrResul := oRestClient:GetResult()
              Conout("[ZWSR017] Bloqueio realizado, dados da operação: " + cStrResul + CRLF;
                + " body do json, método PUT: " + cjSon + " ") 
              lRet := .T.
            EndIf
          EndIf
        
        Else
          //Obtém o erro e adiciona ao LOG
          cStrResul := oRestClient:GetLastError()
          Conout("[ZWSR017] Erro ao executar método GET, verifique dados: " + cStrResul)
        EndIf
      EndIf

    End Sequence

  //Libera os objetos
  FreeObj(oRestClient)     
  FreeObj(oObjJson)

Return lRet

