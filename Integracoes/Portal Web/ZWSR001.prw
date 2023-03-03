#Include 'RestFul.CH'
#INCLUDE "TOTVS.CH"

/*=====================================================================================
Programa.:              ZGNEF006
Autor....:              CAOA - Valter Carvalho
Data.....:              17/08/2020
Descricao / Objetivo:   EndPoint Rest para consulta dos dados CPF cliente no Protheus.
Solicitante:            Barbara
Uso......:              
===================================================================================== */

WSRESTFUL CAOA_INF_CLIENTE DESCRIPTION "Serviço CAOA Informação clientes" FORMAT  "application/json"
    WsData cCPF_CNPJ                as String
    WSMETHOD GET DESCRIPTION "Retorna json com o nome do usuario a partir de CPF/CNPJ" WSSYNTAX "/cpf_cnpj"
END WSRESTFUL

// testes em  des_comp_fluig

WsMethod GET wsReceive cCPF_CNPJ wsService CAOA_INF_CLIENTE
     Local oJson  := JsonObject():New()
     Local cCgc   := ::cCPF_CNPJ

     DbSelectArea("SA1")
     SA1->(DbSetOrder(3)) // A1_FILIAL + A1_CGC
     
    ::SetContentType("application/json")
     
     If (Vazio(cCgc) = .T.) .or.  (SA1->(DbSeek(Xfilial("SA1") + cCgc )) = .F.)
          oJson['cCPF_CNPJ']     := ""
          oJson['cNome']         := ""
          oJson['cEnd']          := ""
          oJson['fone']          := ""
          oJson['email']         := ""
          oJson['cErr']          := "Sem cadastro para esse CPF " + Transform( cCgc, "@R 99999999999" ) 
     Else
          oJson['cCPF_CNPJ']     := Iif( SA1->A1_PESSOA = "F", Transform( SA1->A1_CGC, "@R 999.999.999-99" ), Transform( SA1->A1_CGC, "@R 99.999.999/9999-99" ))
          oJson['cNome']         := SA1->A1_NOME
          oJson['cEnd']          := Alltrim(SA1->A1_END) + " " + Alltrim(SA1->A1_MUN) + " " + Alltrim(SA1->A1_EST)
          oJson['fone']          := SA1->A1_TEL
          oJson['email']         := SA1->A1_EMAIL
          oJson['cErr']          := ""

     EndIf
     
     ::SetResponse( oJson:ToJson() )
     
     SA1->(DbCloseArea())

return .T.
