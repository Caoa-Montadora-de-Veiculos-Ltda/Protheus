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
User Function  ZWSR017()

    Local oRestClient   := Nil
    Local cUrl		    := "/rest_caoasp01/users/" 
    Local aHeadStr		:= {"Content-Type: application/json"}
    Local oObjJson		:= Nil
    Local cStrResul		:= ""
    Local cCodUsr       := "001256" //Código do usuários a ser bloqueado.
    Local cEmail        := ""
    Local cDispName     := "" 
    Local lAtivUsr      := ""
    Local lContinua     := .F.

    Begin Sequence
      
      If Empty(Alltrim(cCodUsr))
        Break
      EndIf
      
      //Endereço do EndPoint REST
      oRestClient := FWRest():New(AllTrim("http://172.28.35.142:34286"))

      // chamada de classe REST com retorno de dados do usuário - Verbo GET
      oRestClient:setPath(cUrl+cCodUsr)
      
      //Consulta - Verbo GET, para obter informações do usuário.
      If oRestClient:Get(aHeadStr)
        //Deserealiza o Json
        If !FWJsonDeserialize(oRestClient:GetResult(),@oObjJson)
            MsgStop("Ocorreu erro no processamento do Json.")
            Break
        ElseIf AttIsMemberOf(oObjJson,"errorCode")
            MsgStop("errorCode: " + DecodeUTF8(oObjJson:errorCode) + " - errorMessage: " + DecodeUTF8(oObjJson:errorMessage))
            Break
        Else
            //Recebe Dados do Json
            cStrResul := oRestClient:GetResult()
            Conout("Dados da operação: " + cStrResul)
            lContinua := .T.
        EndIf

        //Grava informaçõs para o método PUT para bloquear o usuário.
        cEmail    := oObjJson:EMAILS[1]:VALUE
        cDispName := oObjJson:DISPLAYNAME
        lAtivUsr  := oObjJson:ACTIVE //Se for false o usuário já está bloqueado.
      
        //Se conseguiu obter os dados de usuários, procede para bloqueio.
        If lContinua
          If Empty(AllTrim(cCodUsr)) .and. Empty(AllTrim(cDispName))
            Break
          EndIf

          If Empty(lAtivUsr) .or. lAtivUsr == .F.
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
              MsgStop("Ocorreu erro no processamento do Json.")
              Break
            ElseIf AttIsMemberOf(oObjJson,"errorCode")
              MsgStop("errorCode: " + DecodeUTF8(oObjJson:errorCode) + " - errorMessage: " + DecodeUTF8(oObjJson:errorMessage))
              Break
            Else
              cStrResul := oRestClient:GetResult()
              Conout("Dados da operação: " + cStrResul)
            EndIf
          EndIf

        EndIf

      Else
        cStrResul := oRestClient:GetLastError()
        Conout("Dados da operação: " + cStrResul)
      EndIf

    End Sequence
    
Return
