#INCLUDE "PROTHEUS.CH"
 
/*
==============================================================================================
Programa.:              OX001TOK
Autor....:              Sandro Ferreira
Data.....:              22/09/21
Descricao / Objetivo:   Ponto de Entrada inserindo a regra proposta na MIT044-GAP_PECCD14
Doc. Origem:
Solicitante:            sigapec
Uso......:              CAOA Montadora de VeiculoS
Obs......:              Regras para o faturamento minímo dos orçamentos por fases
===============================================================================================
*/
User Function OX001TOK(nOpcx)

   Local _lRet	   := .F.
   Local aArea	   := GetArea()

   If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
        _lRet	   := .F. 
    Else
      //Executa o p.e. Barueri
        _lRet  := zFBarueri()
    EndIf

RestArea(aArea)

Return(_lRet)

/*
=====================================================================================
Programa.:              zFBarueri
Autor....:              TOTVS
Data.....:              03/02/2022
Descricao / Objetivo:   Executa o P.e. empresa Barueri
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/
Static Function zFBarueri()

Local lRet	   := .F.
Local nVLMINF  := SuperGetMV( "CAOAFTMNOR" ,,"")    //Valor numérico mínimo para faturamento
Local cTPPEDE  := SuperGetMV( "CAOAFTMNEX" ,,"")    //Tipos de orçamento (VS1_XTPPED) que terão exceção à regra (003=Emergencial)
Local cIDEXEC  := SuperGetMV( "CAOAFTMNUS" ,,"")    //IDs dos usuários que terão exceção à regra
Local cCODUSR  := RetCodUsr()
//Local cNONUSR  := UsrRetName(__cUserId)
//Local lUSR     := .T.
//Local lORC     := .T.
//Local nTPPED   := 0
//Local nUSER    := 0
Local cPesq1   := ","
Local cPesq2   := ";"
Local nPos     := 0

//Testa a regra das exceções dos tipos de orcamentos 
    //Procura por virgula separando os tipos de pedidos
    nLop := 1
    nPos := 0
    nPos := AT( cPesq1, cTPPEDE )
    IF nPos > 0 .or. Len(cTPPEDE) = 3
       While nLop < Len(cTPPEDE) //.or. lRet = .F.
          //If VS1->VS1_XTPPED == SUBSTRING(cTPPEDE,nLop,3)
          If M->VS1_XTPPED == SUBSTRING(cTPPEDE,nLop,3)     //Ainda n�o gravou  no caso de inclus�o DAC 28/05/2022
             lRet := .T.
             Exit
          Endif
          nLop := nLop + 4
       End
    Endif
    //Procura por ponto e virgula separando os tipos de pedidos
    nLop := 1
    nPos := 0
    nPos := AT( cPesq2, cTPPEDE )
    IF nPos > 0 .or. Len(cTPPEDE) = 3
       While nLop < Len(cTPPEDE) //.or. lRet = .F.
          //If VS1->VS1_XTPPED == SUBSTRING(cTPPEDE,nLop,3)
          If M->VS1_XTPPED == SUBSTRING(cTPPEDE,nLop,3)  //Ainda n�o gravou  no caso de inclus�o DAC 28/05/2022
             lRet := .T.
             Exit
          Endif
          nLop  := nLop + 4
       End
    Endif
//Next

//Testa a regra das exceções dos usuários 
   //Procura por virgula separando os usuarios
    nLop := 1
    nPos := 0
    nPos := AT( cPesq1, cIDEXEC )
    IF nPos > 0 .or. Len(cIDEXEC) = 6
       While nLop < Len(cIDEXEC) //.or. lRet = .F.
          If cCODUSR == SUBSTRING(cIDEXEC,nLop,6)
             lRet := .T.
             Exit
          Endif
          nLop := nLop + 7
       End
    Endif

    //Procura por ponto e virgula separando os usuarios
    nLop := 1
    nPos := 0
    nPos := AT( cPesq2, cIDEXEC )
    IF nPos > 0 .or. Len(cIDEXEC) = 6
       While nLop < Len(cIDEXEC) //.or. lRet = .F.
          If cCODUSR == SUBSTRING(cIDEXEC,nLop,6)
             lRet := .T.
             Exit
          Endif
          nLop := nLop + 7
       End
    Endif
//Next

//Testa Valor Minimo
IF !lRet 
   IF M->VS3_VALPEC < nVLMINF 
      ALERT("Valor inferior ao valor minimo para faturaremnto - parametro CAOAFTMNOR")
   ELSE
      lRet := .T.
   ENDIF
Endif

Return lRet
