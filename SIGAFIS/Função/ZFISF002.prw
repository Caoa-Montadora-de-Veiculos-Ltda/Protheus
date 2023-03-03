#include 'parmtype.ch'
#include 'TOPCONN.CH'
#include 'protheus.ch'
#INCLUDE "TBICONN.CH"

/*
=====================================================================================
Programa.:              ZFISF002
Autor....:              CAOA - Valter Carvalho
Data.....:              29/01/2019
Descricao / Objetivo:   Gerar arquivos com dados do fiscal, para a Audito 
Doc. Origem:
Solicitante:            Fabio Giacomozzi <fabio@caoa.com.br>
Uso......:              
Obs......:              
=====================================================================================
*/

 User Function ZFISF002(aParam, oProcess)   // campos do parametro cEmpr, cFil, dData, oProcess
    Local i             := 1
    Local aFiles        := {}
    Local cRes          := ""
    Local bBlock        := ErrorBlock()
    Local aTarefas      := {}
    Private cHrGer      := Time()
    Private cDtGer      := Dtos(date())
    Private cEmpr       := aParam[1]
    Private cUo         := aParam[2]  // FILIAL 2010022001

    Logar("ZFISF002 - Inicio da Rotina, Empresa:" +  cEmpr + " Filial:" + cUo)

    If Vazio(oProcess)   
        Logar("ZFISF002 - Preparar o enviroment" )

        PREPARE ENVIRONMENT EMPRESA cEmpr FILIAL cUo MODULO "SIGAFIS"

        cDtOp := Dtos(getmv("MV_ULMES")+1)
    else
        Logar("ZFISF002 - Ambiente já preparado" )
        cDtOp := aParam[3]
    EndIf

    OpenSm0("01", .F.)

    Aadd(aTarefas, "Dados Documentos Recebidos" )
    Aadd(aTarefas, "Itens das Notas Recebidas" )
    Aadd(aTarefas, "Dados das Notas Recebidas" )
    Aadd(aTarefas, "Relacao de produtos" )
    Aadd(aTarefas, "Notas De Servicos Tomados")
    Aadd(aTarefas, "Notas De Servicos Prestados" )

    If !Vazio(oProcess)   // setar as reguas
        oProcess:SetRegua1(len(aTarefas) +1)
    EndIf

    ErrorBlock( {|e| CheckErro(e, @cRes)})

    Begin Sequence

        For i:=1 to len(aTarefas)
            If !Empty(oProcess)
                oProcess:IncRegua1(aTarefas[i])
            EndIf

            cRes := GerarArq(aTarefas[i], oProcess)  // chama a execucao da tarefa

            Aadd(aFiles, cRes) // Adiciona o arquivo array para enviar via FTP
        Next

        If !Empty(oProcess)
            oProcess:IncRegua1("Enviar os arquivos para o FTP Caoa")
        EndIf

        cRes := SndFtpCaoa(aFiles, cRes, oProcess)      // pega nome do arquivos para o FTP Caoa
        Aadd(aFiles, cRes)              // Adiciona o arquivo array para enviar via FTP        

    Recover
        ErrorBlock(bBlock)
    End Sequence

    SM0->(DbCloseArea())

    aEval(aFiles, {|cFile| cRes += cFile + CRLF })

    if Substr(cRes,1,6) = "ERROR:"  // envia um email notificando a falha
        if FindFunction("U_ZGENMAIL")
            NotificaFalha(cRes)
        EndIf

        cRes := "Erro na execução da rotina: " + CRLF + cRes
    else
        cRes := "Arquivos gerados: " + CRLF + cRes
    EndIf

    RESET ENVIRONMENT
    Logar("ZFISF002 - Final da Rotina")
Return cRes


/*
=====================================================================================
Programa.:              CheckErro
Autor....:              CAOA - Valter Carvalho
Data.....:              29/01/2019
Descricao / Objetivo:   verificar se ha erros de execucao
Doc. Origem:
Solicitante:            Fabio Giacomozzi <fabio@caoa.com.br>
Uso......:              
Obs......:              
=====================================================================================
*/
Static Function CheckErro(e, cRes )
    If e:gencode > 0
        Logar("Erro na ZFISF002:" + e:Description)
        Alert(e:Description)
        cRes := "ERROR:" +  e:Description
        Logar("ZFISF002 - " + cRes)
    Endif
    Break
Return


/*
=====================================================================================
Programa.:              GerarArq
Autor....:              CAOA - Valter Carvalho
Data.....:              29/01/2019
Descricao / Objetivo:   Efetua a geracao dos arquivos
Doc. Origem:
Solicitante:            Fabio Giacomozzi <fabio@caoa.com.br>
Uso......:              
Obs......:              
=====================================================================================
*/
Static Function GerarArq(cConsulta, oProcess)
    Local cFile     := ""
    Local aAjustes  := {}
    Local aArqRecs  := ""
    Local cQuery    := ""

    Logar("ZFISF002 - GerarArq - Inicio da rotina")


    If !Empty(oProcess)   // setar as reguas
        oProcess:SetRegua2(4)
    EndIf

    If !Empty(oProcess)
        oProcess:IncRegua2("Obtendo dados...")
        Sleep(300)
    EndIf
    GetDadCons(cConsulta, @cQuery, @aAjustes, @cFile) // pegar os dados para realizar a consulta

    If !Empty(oProcess)
        oProcess:IncRegua2("Formatando os dados...")
        Sleep(300)
    EndIf
    aArqRecs := ExportaDados(cQuery, aAjustes, cFile)  //Retorna um array com os dados

    If !Empty(oProcess)
        oProcess:IncRegua2("Gravando arquivo...")
        Sleep(300)
    EndIf
    GravarArq(aArqRecs[1], cFile, .T.)    //Grava array1 (dados) no arquivo

    If !Empty(oProcess)
        oProcess:IncRegua2("Gravando reg exportacao...")
        Sleep(300)
    EndIf
    UpRegExp(aArqRecs[2])    //Atualizar a SF3 atualizando a dta de exportacao

    Logar("ZFISF002 - GerarArq - Final da rotina")    
Return cFile

/*
=====================================================================================
Programa.:              ExportaDados
Autor....:              CAOA - Valter Carvalho
Data.....:              29/01/2019
Descricao / Objetivo:   Consulta os dados e grava em array
Doc. Origem:
Solicitante:            Fabio Giacomozzi <fabio@caoa.com.br>
Uso......:              
Obs......:              
=====================================================================================
*/
Static Function ExportaDados(cQuery, aAjustes, cFile)
    Local xAux      := nil
    Local i         := nil
    Local aStru     := nil
    Local cAlias    := GetNextAlias()
    Local cDelimit  := ";"
    Local iDAjuste  := 0
    Local aFile     := {}
    Local aRecnos   := {}
    Local cLin      := ""

    Logar("ZFISF002 - ExportaDados - Inicio")
    TcQuery cQuery new alias (cAlias)

    DbSelectArea(cAlias)

    aStru :=  (cAlias)->(DBStruct())

    // Gravar os campos do cabecalho
    For i:= 1 to len(aStru)-2
        cLin += aStru[i,1] + ";"
    Next
    cLin += aStru[len(aStru)-1, 1]

    Aadd(aFile, cLin + CRLF)

    // Preparar o array com o dados
    (cAlias)->(DbGoTop())
    While (cAlias)->(Eof()) = .F.
        cLin := ""
        For i:= 1 to len(aStru)-1 // o ultimo campo é o recno da sf3, nao gravar no arquivo

            cDelimit := iif((i= len(aStru)-1), CRLF, ";")

            iDAjuste := Ascan(aAjustes, {|x| x[1] == aStru[i,1]})  // Se o campo esta no ajuste, então grava a expressao do ajuste,  do contrário, grava o campo

            If iDAjuste > 0
                cLin +=  &( aAjustes[iDAjuste,2] ) + cDelimit
            Else
                xAux := (cAlias)-> &(aStru[i,1])

                cLin +=  iif((ValType(xAux) == "C"), AllTrim(xAux),  cValToCHar(xAux) ) + cDelimit
            Endif
        Next

        Aadd(aFile, cLin) //adicionar a linha

        if aStru[Len(aStru),1] == "RECNO"  // tratamento para retornar o RECNO no array de atualizações
            iDAjuste :=  Ascan(aAjustes, {|x| x[1] == aStru[Len(aStru),1]})

            If iDAjuste > 0
                Aadd(aRecnos,  &(aAjustes[iDAjuste,2] )    )
            Else
                Aadd(aRecnos, (cAlias)-> &(aStru[len(aStru),1]) )
            EndIf
        EndIf

        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())
    
    Logar("ZFISF002 - ExportaDados - Fim")    

Return {aFile, aRecnos}

/*
=====================================================================================
Programa.:              UpRegExp
Autor....:              CAOA - Valter Carvalho
Data.....:              29/01/2019
Descricao / Objetivo:   Atualiza o registro da exportacao das notas na SF3
Doc. Origem:
Solicitante:            Audito
Uso......:              
=====================================================================================
*/
Static Function UpRegExp(aFile)    //Grava array no arquivo
    Local i := 1
    

    Logar("ZFISF002 - GravarArq - Inicio")

    DbSelectArea("SF3")

    For i:=1 to len(aFile)
        If aFile[i] > 0
            SF3->(DbGoTo(aFile[i]))
            RecLock("SF3", .F.)
            SF3->F3_MSEXP := cDtGer
            SF3->F3_HREXP := cHrGer
            SF3->(MsUnlock())
        EndIf
    Next

    SF3->(DbCloseArea())

    Logar("ZFISF002 - UpRegExp - Fim")    
Return


/*
=====================================================================================
Programa.:              GravarArq
Autor....:              CAOA - Valter Carvalho
Data.....:              29/01/2019
Descricao / Objetivo:   Efetua a gravação dos dados no arquivo
Doc. Origem:
Solicitante:            Audito
Uso......:              
=====================================================================================
*/
Static Function GravarArq(aLinhas, cArquivo, lApagaArq)

    local nArq := 0
    local cCamArq := cArquivo
    Local _nI := 0

    Logar("ZFISF002 - GravarArq - Inicio")

    If (File(cCamArq) = .T.) .and. lApagaArq
        FErase(cCamArq)
    EndIf

    // CRIA O ARQUIVO se nao existir
    If !file(cCamArq)
        nArq := FCreate(cCamArq)
    Else
        nArq := FT_FUse(cCamArq)
    EndIf

    If nArq <= 0
        Logar("Erro ao tentar criar ou abrir o arquivo " + cArquivo)
        Return .F.
    EndIf

    ProcRegua(Len(aLinhas))

    // GRAVA NO ARQUIVO TXT
    For _nI:=1 to len(aLinhas) step 1
        FWrite( nArq, aLinhas[_nI], len(aLinhas[_nI]))
    Next

    // FECHA O ARQUIVO
    FClose(nArq)

    Logar("ZFISF002 - GravarArq - Fim")    
Return .T.


/*
=====================================================================================
Programa.:              getDadCons
Autor....:              CAOA - Valter Carvalho
Data.....:              29/01/2019
Descricao / Objetivo:   Preenche as variáveis para geracao da consulta
Doc. Origem:
Solicitante:            Audito
Uso......:              
=====================================================================================
*/

Static Function getDadCons(cConsulta, cQuery, aAjustes, cFile)
    Logar("ZFISF002 - getDadCons - Inicio")

    If cConsulta = 'Dados Documentos Recebidos'
        cQuery := ""
        cQuery += " SELECT "                                                          + CRLF
        cQuery += "   0                               AS CONTA_ID"                    + CRLF
        cQuery += " , F1_ESPECIE                      AS MODELO_ID"                   + CRLF
        cQuery += " , F1_CHVNFE                       AS CHAVE"                       + CRLF
        cQuery += " , CONCAT(F1_CHVNFE, '-nfe.xml')   AS ARQUIVONOME"                 + CRLF
        cQuery += " , ''                              AS ARQUIVOCONTEUDO"             + CRLF
        cQuery += " , F1_RECBMTO                      AS ENTRADADATA"                 + CRLF
        cQuery += " , F1_DTDIGIT                      AS CADASTRODATA"                + CRLF
        cQuery += " , SF3.R_E_C_N_O_                  AS RECNO"                       + CRLF

        cQuery += " FROM " + RetSQLName('SF1') + " SF1 "                              + CRLF

        cQuery += "INNER JOIN " + RetSQLName('SF3') + " SF3"                          + CRLF
        cQuery += "     ON  SF1.F1_FILIAL = SF3.F3_FILIAL   "                         + CRLF
        cQuery += "     AND SF1.F1_DOC	  = SF3.F3_NFISCAL  "                         + CRLF
        cQuery += "     AND SF1.F1_SERIE  = SF3.F3_SERIE    "                         + CRLF
        cQuery += "     AND SF3.D_E_L_E_T_ = ' '            "                         + CRLF
        cQuery += "	    AND SF3.F3_MSEXP = ' '              "                         + CRLF

        cQuery += " WHERE "                                                           + CRLF
        cQuery += "         SF1.F1_FILIAL = '" + cUo + "' "                           + CRLF
        cQuery += "     AND SF1.F1_DTLANC > '" + cDtOp + "' "                         + CRLF
        cQuery += "     AND SF1.F1_COND <> ' ' "                                      + CRLF
        cQuery += "     AND SF1.F1_ESPECIE <> 'NFS' "                                 + CRLF
        cQuery += "     AND SF1.D_E_L_E_T_ = ' ' "                                    + CRLF

        
        aAjustes := {} // array com os campos que serão substituidos, o valor da query pelo valor do campo[2] do array
        Aadd(aAjustes, {"CONTA_ID",  "SM0->M0_CGC" })
        Aadd(aAjustes, {"MODELO_ID", 'iif((Empty(AMODNOT((cAlias)->MODELO_ID))), "01", AMODNOT((cAlias)->MODELO_ID))' })
        Aadd(aAjustes, {"CHAVE"    , 'iif(Empty((cAlias)->CHAVE), "", (cAlias)->CHAVE + "-NFE.XML" )' })
        Aadd(aAjustes, {"RECNO"    , 'iif(Alltrim((cAlias)->MODELO_ID) $ "CTE", (cAlias)->RECNO, -1 )' }) //so atualizar o recno do CTE, as de nota atualizam depois


    elseIf cConsulta = 'Itens das Notas Recebidas'

        cQuery := ""
        cQuery += " SELECT DISTINCT "                                               + CRLF
        cQuery += "   0                               AS CONTA_ID"                  + CRLF
        cQuery += " , F1_CHVNFE                       AS CHAVE"                     + CRLF
        cQuery += " , D1_ITEM                         AS NITEM"                     + CRLF
        cQuery += " , D1_COD                          AS CODIGO"                    + CRLF
        cQuery += " , D1_COD                          AS CODIGOINTERNO"             + CRLF
        cQuery += " , D1_CF                           AS CFOPENTRADA"               + CRLF
        cQuery += " , ''                              AS USOITEM"                   + CRLF

        cQuery += " FROM " + RetSQLName('SF1') + " SF1 "                            + CRLF

        cQuery += " INNER JOIN " + RetSQLName('SD1') + " SD1 "                      + CRLF
        cQuery += "     ON  SF1.F1_DOC = SD1.D1_DOC "                               + CRLF
        cQuery += "     AND SF1.F1_SERIE = SD1.D1_SERIE "                           + CRLF
        cQuery += "     AND SF1.F1_FORNECE = SD1.D1_FORNECE "                       + CRLF
        cQuery += "     AND SF1.F1_LOJA = SD1.D1_LOJA "                             + CRLF
        cQuery += "     AND SD1.D_E_L_E_T_ = ' ' "                                  + CRLF

        cQuery += "INNER JOIN " + RetSQLName("SF3") + " SF3"                        + CRLF
        cQuery += "     ON  SF1.F1_FILIAL = SF3.F3_FILIAL"                          + CRLF
        cQuery += "     AND SF1.F1_DOC	  = SF3.F3_NFISCAL"                         + CRLF
        cQuery += "     AND SF1.F1_SERIE  = SF3.F3_SERIE"                           + CRLF
        cQuery += "     AND SF3.D_E_L_E_T_ = ' '  "                                 + CRLF
        cQuery += "     AND SF3.F3_MSEXP = ' ' "                                    + CRLF

        cQuery += " WHERE "                                                         + CRLF
        cQuery += "         SF1.F1_FILIAL = '" + cUo + "' "                         + CRLF
        cQuery += "     AND SF1.F1_DTLANC > '" + cDtOp + "' "                       + CRLF
        cQuery += "     AND SF1.F1_COND <> ' ' "                                    + CRLF
        cQuery += "     AND SF1.D_E_L_E_T_ = ' ' "                                  + CRLF


        // array com os campos que serão substituidos, o valor da query pelo valor do campo[2] do array
        aAjustes := {}
        Aadd(aAjustes, {"CONTA_ID",  "SM0->M0_CGC" })


    ElseIf cConsulta = "Dados das Notas Recebidas"
        cQuery := ""
        cQuery += " SELECT "                                                  + CRLF
        cQuery += " ''                             AS CONTA_ID"               + CRLF
        cQuery += " , A2_CGC                       AS FORNECEDOR_DOCUMENTO"   + CRLF
        cQuery += " , F1_CHVNFE                    AS CHAVE"                  + CRLF
        cQuery += " , F1_EMISSAO                   AS EMISSAO_DATA"           + CRLF
        cQuery += " , F1_DTLANC                    AS ENTRADA_DATA"           + CRLF
        cQuery += " , F1_DTLANC                    AS CADASTRO_DATA"          + CRLF
        cQuery += " , SF3.R_E_C_N_O_               AS RECNO  "                + CRLF

        cQuery += " FROM " + RetSQLName('SF1') + " SF1 "                      + CRLF

        cQuery += "INNER JOIN " + RetSQLName("SF3") + " SF3"                  + CRLF
        cQuery += "     ON  SF1.F1_FILIAL = SF3.F3_FILIAL   "                 + CRLF
        cQuery += "     AND SF1.F1_DOC	  = SF3.F3_NFISCAL  "                 + CRLF
        cQuery += "     AND SF1.F1_SERIE  = SF3.F3_SERIE    "                 + CRLF
        cQuery += "     AND SF3.D_E_L_E_T_ = ' '            "                 + CRLF
        cQuery += "     AND SF3.F3_MSEXP = ' ' "                              + CRLF

        cQuery += " INNER JOIN " + RetSQLName("SA2") + " SA2"                 + CRLF
        cQuery += "     ON  SF1.F1_FORNECE = SA2.A2_COD"                      + CRLF
        cQuery += "     AND SF1.F1_LOJA = SA2.A2_LOJA"                        + CRLF
        cQuery += "     AND SA2.D_E_L_E_T_ = ' '   "                          + CRLF

        cQuery += " WHERE "                                                   + CRLF
        cQuery += "         SF1.F1_FILIAL = '" + cUo + "' "                   + CRLF
        cQuery += "     AND SF1.F1_DTLANC > '" + cDtOp + "' "                 + CRLF
        cQuery += "     AND SF1.F1_COND <> ' ' "                              + CRLF
        cQuery += "     AND SF1.F1_ESPECIE <> 'NFS' "                         + CRLF
        cQuery += "     AND SF1.D_E_L_E_T_ = ' ' "                            + CRLF

        aAjustes := {} // array com os campos que serão substituidos, o valor da query pelo valor do campo[2] do array
        Aadd(aAjustes, {"CONTA_ID",  "SM0->M0_CGC" })


    ElseIf cConsulta = 'Relacao de produtos'
        cQuery := ""
        cQuery += " SELECT DISTINCT"                                          + CRLF
        cQuery += "   0                               AS CONTA_ID"            + CRLF
        cQuery += " , D1_COD                          AS CODIGO"              + CRLF
        cQuery += " , B1_DESC                         AS DESCRICAO"           + CRLF
        cQuery += " , B1_CODBAR                       AS EAN"                 + CRLF
        cQuery += " , B1_POSIPI                       AS NCM"                 + CRLF
        cQuery += " , F1_DTLANC                       AS CADASTRODATA"        + CRLF

        cQuery += " FROM " + RetSQLName('SF1') + " SF1 "                      + CRLF

        cQuery += " INNER JOIN " + RetSQLName('SD1') + " SD1 "                + CRLF
        cQuery += "     ON SF1.F1_DOC = SD1.D1_DOC "                          + CRLF
        cQuery += "     AND SF1.F1_SERIE = SD1.D1_SERIE "                     + CRLF
        cQuery += "     AND SF1.F1_FORNECE = SD1.D1_FORNECE "                 + CRLF
        cQuery += "     AND SF1.F1_LOJA = SD1.D1_LOJA "                       + CRLF
        cQuery += "     AND SD1.D_E_L_E_T_ = ' ' "                            + CRLF

        cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1  "               + CRLF
        cQuery += "     ON  SB1.B1_COD = SD1.D1_COD  "                        + CRLF
        cQuery += "     AND SB1.D_E_L_E_T_ = ' '   "                          + CRLF

        cQuery += " WHERE "                                                   + CRLF
        cQuery += "         SF1.F1_FILIAL = '" + cUo + "' "                   + CRLF
        cQuery += "     AND SF1.F1_DTLANC > '" + cDtOp + "' "                 + CRLF
        cQuery += "     AND SF1.F1_COND <> ' ' "                              + CRLF
        cQuery += "     AND SF1.D_E_L_E_T_ = ' ' "                            + CRLF

        
        aAjustes := {} // array com os campos que serão substituidos, o valor da query pelo valor do campo[2] do array
        Aadd(aAjustes, {"CONTA_ID",  "SM0->M0_CGC" })


    ElseIf cConsulta = 'Notas De Servicos Tomados'
        cQuery := ""
        cQuery += " SELECT"                                                                       + CRLF
        cQuery += "   F1_DOC                        AS NUMERO_DA_NOTA_FISCAL"                     + CRLF
        cQuery += " , F1_SERIE                      AS SERIE"                                     + CRLF
        cQuery += " , F1_SUBSERI                    AS SUB_SERIE"                                 + CRLF
        cQuery += " , ''                            AS NUMERO_DO_RPS"                             + CRLF
        cQuery += " , F1_DTDIGIT                    AS DATA_DE_EXECUCAO_DO_SERVICO"               + CRLF
        cQuery += " , F1_DTLANC                     AS ENTRADADATA"                               + CRLF
        cQuery += " , F1_DTLANC                     AS DATA_LANCAMENTO_SISTEMA"                   + CRLF
        cQuery += " , F1_CODNFE                     AS CODIGO_DE_VERIFICACAO"                     + CRLF
        cQuery += " , F1_CHVNFE                     AS CHAVE_DE_ACESSO"                           + CRLF
        cQuery += " , 'REGULAR'                     AS SITUACAO_DOCUMENTO"                        + CRLF
        cQuery += " , B1_COD                        AS CODIGO_DO_SERVICO"                         + CRLF
        cQuery += " , B1_DESC                       AS DESCRICAO_DO_SERVICO"                      + CRLF
        cQuery += " , F1_VALBRUT                    AS VALOR_TOTAL_DA_NOTA"                       + CRLF
        cQuery += " , F1_DESCONT                    AS VALOR_TOTAL_DE_DEDUCAO"                    + CRLF
        cQuery += " , F1_VALMERC                    AS VALOR_DO_SERVICO"                          + CRLF
        cQuery += " , D1_ALIQISS                    AS ALIQUOTA_DE_ISS"                           + CRLF
        cQuery += " , D1_VALISS                     AS D1_VALISS"                                 + CRLF
        cQuery += " , ''                            AS VALOR_DE_ISS_RETIDO"                       + CRLF
        cQuery += " , ''                            AS VALOR_DE_IR_RETIDO"                        + CRLF
        cQuery += " , ''                            AS VALOR_DE_PIS_RETIDO"                       + CRLF
        cQuery += " , ''                            AS VALOR_DE_COFINS_RETIDO"                    + CRLF
        cQuery += " , ''                            AS VALOR_DO_CSLL_RETIDO"                      + CRLF
        cQuery += " , ''                            AS VALOR_DE_INSS_RETIDO"                      + CRLF
        cQuery += " , A2_CGC                        AS CNPJ_CPF"                                  + CRLF
        cQuery += " , A2_NOME                       AS NOME_RAZAO_SOCIAL"                         + CRLF
        cQuery += " , A2_CODMUN                     AS SUFRAMA"                                   + CRLF
        cQuery += " , A2_INSCR                      AS INSCRICAO_ESTADUAL"                        + CRLF
        cQuery += " , A2_INSCRM                     AS INSCRICAO_MUNICIPAL"                       + CRLF
        cQuery += " , A2_END                        AS RUA_AVENIDA"                               + CRLF
        cQuery += " , A2_COMPLEM                    AS COMPLEMENTO"                               + CRLF
        cQuery += " , ''                            AS NUMERO"                                    + CRLF
        cQuery += " , A2_BAIRRO                     AS BAIRRO"                                    + CRLF
        cQuery += " , A2_MUN                        AS MUNICIPIO"                                 + CRLF
        cQuery += " , A2_COD_MUN                    AS COD_MUNICIPIO"                             + CRLF
        cQuery += " , A2_EST                        AS UF"                                        + CRLF
        cQuery += " , A2_TEL                        AS TELEFONE"                                  + CRLF
        cQuery += " , A2_EMAIL                      AS EMAIL"                                     + CRLF
        cQuery += " , A2_CONTA                      AS CLASSIFICACAO_CONTABIL"                    + CRLF
        cQuery += " , ''                            AS CNPJ_TOMADOR"                              + CRLF
        cQuery += " , ''                            AS NOME_RAZAO_SOCIAL_TOMADOR"                 + CRLF
        cQuery += " , ''                            AS INSCRICAO_MUNICIPAL_TOMADOR"               + CRLF
        cQuery += " , SF3.R_E_C_N_O_                AS RECNO  "                                   + CRLF

        cQuery += " FROM " + RetSQLName('SF1') + " SF1 "                                          + CRLF

        cQuery += " INNER JOIN " + RetSQLName('SD1') + " SD1"                                     + CRLF
        cQuery += "     ON SF1.F1_DOC = SD1.D1_DOC"                                               + CRLF
        cQuery += "     AND SF1.F1_SERIE = SD1.D1_SERIE "                                         + CRLF
        cQuery += "     AND SF1.F1_FORNECE = SD1.D1_FORNECE"                                      + CRLF
        cQuery += "     AND SF1.F1_LOJA = SD1.D1_LOJA "                                           + CRLF
        cQuery += "     AND SD1.D_E_L_E_T_ = ' ' "                                                + CRLF

        cQuery += "INNER JOIN " + RetSQLName("SF3") + " SF3"                                      + CRLF
        cQuery += "     ON  SF1.F1_FILIAL = SF3.F3_FILIAL   "                                     + CRLF
        cQuery += "     AND SF1.F1_DOC	  = SF3.F3_NFISCAL    "                                   + CRLF
        cQuery += "     AND SF1.F1_SERIE  = SF3.F3_SERIE     "                                    + CRLF
        cQuery += "     AND SF3.D_E_L_E_T_ = ' '            "                                     + CRLF
        cQuery += "     AND SF3.F3_MSEXP = ' ' "                                                  + CRLF

        cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1"                                     + CRLF
        cQuery += "     ON  SB1.B1_COD = SD1.D1_COD  "                                            + CRLF
        cQuery += "     AND SB1.D_E_L_E_T_ = ' '   "                                              + CRLF

        cQuery += " INNER JOIN " + RetSQLName("SA2") + " SA2"                                     + CRLF
        cQuery += "     ON  SF1.F1_FORNECE = SA2.A2_COD"                                          + CRLF
        cQuery += "     AND SF1.F1_LOJA = SA2.A2_LOJA"                                            + CRLF
        cQuery += "     AND SB1.D_E_L_E_T_ = ' '   "                                              + CRLF

        cQuery += " WHERE "                                                                       + CRLF
        cQuery += "         SF1.F1_FILIAL = '" + cUo + "' "                                       + CRLF
        cQuery += "     AND SF1.F1_DTLANC > '" + cDtOp + "' "                                     + CRLF
        cQuery += "     AND SF1.F1_COND <> ' ' "                                                  + CRLF
        cQuery += "     AND SF1.F1_ESPECIE = 'NFS' "                                              + CRLF
        cQuery += "     AND SF1.D_E_L_E_T_ = ' ' "                                                + CRLF

        aAjustes := {} // array com os campos que serão substituidos, o valor da query pelo valor do campo[2] do array
        Aadd(aAjustes, {"CNPJ_TOMADOR",  "SM0->M0_CGC" })
        Aadd(aAjustes, {"NOME_RAZAO_SOCIAL_TOMADOR",  "SM0->M0_NOMECOM"})
        Aadd(aAjustes, {"INSCRICAO_MUNICIPAL_TOMADOR",  "SM0->M0_INSCM" })
    
    
    ElseIf cConsulta = 'Notas De Servicos Prestados'
        cQuery := ""

        cQuery += " SELECT"                                                                                                       + CRLF
        cQuery += "   F2_NFELETR                    AS NUMERO_DA_NOTA_FISCAL"                                                     + CRLF
        cQuery += " , F2_SERIE                      AS SERIE"                                                                     + CRLF
        cQuery += " , ''                            AS SUBSERIE"                                                                  + CRLF
        cQuery += " , F2_DOC                        AS NUMERO_RPS"                                                                + CRLF
        cQuery += " , F2_EMISSAO                    AS DATA_EMISSAO"                                                              + CRLF
        cQuery += " , F2_DTLANC                     AS DATA_EXECUCAO_SERVICO"                                                     + CRLF
        cQuery += " , F2_DTLANC                     AS DATA_LANCAMENTO_SERVICO"                                                   + CRLF
        cQuery += " , F2_CODNFE                     AS CODIGO_VERIFICACAO"                                                        + CRLF
        cQuery += " , F2_CHVNFE                     AS CHAVE_DE_ACESSO"                                                           + CRLF
        cQuery += " , F3_DTCANC                     AS SIT_DOCUMENTO"                                                             + CRLF
        cQuery += " , D2_COD                        AS COD_SERVICO"                                                               + CRLF
        cQuery += " , B1_DESC                       AS DESC_SERVICO"                                                              + CRLF
        cQuery += " , F2_VALFAT                     AS VAL_TOTAL_NOTA"                                                            + CRLF
        cQuery += " , F2_DESCONT                    AS DESC_SERVICO"                                                              + CRLF
        cQuery += " , F2_VALMERC                    AS VALOR_SERVICO"                                                             + CRLF
        cQuery += " ,''                             AS ISS_RETIDO"                                                                + CRLF
        cQuery += " ,''	                            AS IR_RETIDO"                                                                 + CRLF
        cQuery += " ,''	                            AS PIS_RETIDO"                                                                + CRLF
        cQuery += " ,''	                            AS COFINS_RETIDO"                                                             + CRLF
        cQuery += " ,''                             AS CSLL_RETIDO"                                                               + CRLF
        cQuery += " ,''                             AS INSS_RETIDO"                                                               + CRLF
        cQuery += " ,'' 							AS PREST_CNPJ"                                                                + CRLF
        cQuery += " ,'' 							AS PREST_RAZSOC"                                                              + CRLF
        cQuery += " ,'' 							AS PREST_INSCMUN"                                                             + CRLF
        cQuery += " , A1_CGC                        AS CPJ_CPF"                                                                   + CRLF
        cQuery += " , A1_NOME                       AS NOME_CLIENTE"                                                              + CRLF
        cQuery += " , A1_SUFRAMA                    AS SUFRAMA"                                                                   + CRLF
        cQuery += " , A1_INSCR                      AS INSC_ESTADUAL"                                                             + CRLF
        cQuery += " , A1_INSCRM                     AS INSC_MUNICIPAL"                                                            + CRLF
        cQuery += " , A1_END                        AS END_RUA"                                                                   + CRLF
        cQuery += " , A1_COMPLEM                    AS END_COMPLEMENTO"                                                           + CRLF
        cQuery += " , ''                            AS END_NUM"                                                                   + CRLF
        cQuery += " , A1_BAIRRO                     AS END_BAIRRO"                                                                + CRLF
        cQuery += " , A1_MUN                        AS END_MUN"                                                                   + CRLF
        cQuery += " , A1_COD_MUN                    AS END_COD_MUN"                                                               + CRLF
        cQuery += " , A1_EST                        AS END_EST"                                                                   + CRLF
        cQuery += " , A1_TEL                        AS END_TEL"                                                                   + CRLF
        cQuery += " , A1_EMAIL                      AS END_EST"                                                                   + CRLF
        cQuery += " , SF3.R_E_C_N_O_                AS RECNO"                                                                     + CRLF

        cQuery += "FROM " + RetSQLName("SF2") + " SF2"                                                                            + CRLF

        cQuery += " INNER JOIN " + RetSQLName('SD2') + " SD2"                                                                     + CRLF
        cQuery += "     ON SF2.F2_DOC = SD2.D2_DOC"                                                                               + CRLF
        cQuery += "     AND SF2.F2_SERIE = SD2.D2_SERIE "                                                                         + CRLF
        cQuery += "     AND SF2.F2_LOJA = SD2.D2_LOJA "                                                                           + CRLF
        cQuery += "     AND SD2.D_E_L_E_T_ = ' ' "                                                                                + CRLF

        cQuery += "INNER JOIN " + RetSQLName("SF3") + " SF3"                                                                      + CRLF
        cQuery += "     ON  SF2.F2_FILIAL = SF3.F3_FILIAL   "                                                                     + CRLF
        cQuery += "     AND SF2.F2_DOC	= SF3.F3_NFISCAL    "                                                                     + CRLF
        cQuery += "     AND SF2.F2_SERIE = SF3.F3_SERIE     "                                                                     + CRLF
        cQuery += "     AND SF3.D_E_L_E_T_ = ' '            "                                                                     + CRLF
        cQuery += "     AND SF3.F3_MSEXP = ' ' "                                                                                  + CRLF

        cQuery += " LEFT JOIN " + RetSQLName("SB1") + " SB1"                                                                      + CRLF
        cQuery += "     ON  SB1.B1_COD = SD2.D2_COD  "                                                                            + CRLF
        cQuery += "     AND SB1.D_E_L_E_T_ = ' '   "                                                                              + CRLF

        cQuery += " INNER JOIN " + RetSQLName("SA1") + " SA1"                                                                     + CRLF
        cQuery += "     ON  SF2.F2_CLIENTE = SA1.A1_COD"                                                                          + CRLF
        cQuery += "     AND SF2.F2_LOJA = SA1.A1_LOJA"                                                                            + CRLF

        cQuery += "WHERE "                                                                                                        + CRLF
        cQuery += "         SF2.F2_FILIAL = '" + cUo + "' "                                                                       + CRLF
        cQuery += "     AND SF2.F2_ESPECIE <> 'SPED' "                                                                            + CRLF
        cQuery += "     AND SF2.F2_EMISSAO > '" + cDtOp + "' "

        aAjustes := {} // array com os campos que serão substituidos, o valor da query pelo valor do campo[2] do array
        Aadd(aAjustes, {"SIT_DOCUMENTO",    "iif((Empty((cAlias)->SIT_DOCUMENTO)), 'REGULAR', 'CANCELADA')" })
        Aadd(aAjustes, {"PREST_CNPJ",       "SM0->M0_CGC"})
        Aadd(aAjustes, {"PREST_RAZSOC",     "SM0->M0_NOMECOM"})
        Aadd(aAjustes, {"PREST_INSCMUN",    "SM0->M0_INSCM"})

    EndIf

    cQuery := ChangeQuery(cQuery)
    cFile  := "\auditto\Protheus_Auditto_" + StrTran(cConsulta, " ", "" ) + "_" + Alltrim(SM0->M0_CGC) + "_" + cDtOp + "_" + StrTran(cHrGer, ":", "") + ".csv"

    Logar("ZFISF002 - getDadCons - Fim")    
Return


/*
=====================================================================================
Programa.:              NotificaFalha
Autor....:              CAOA - Valter Carvalho
Data.....:              29/01/2019
Descricao / Objetivo:   Envia um email para usuário em caso de falha da JOB
Doc. Origem:
Solicitante:            Audito
Uso......:              
=====================================================================================
*/
Static Function NotificaFalha(cRes)  	// (cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,Rotina,	Observação	, cReplyTo	)
    Local cMailDestino  := Alltrim(Getmv("CMV_FIS002")) //usuario que vai receber o emmail co ma falha
    Local cMailCopia    := ""
    Local cAssunto	    := "Falha no envio dos arquivo de integração da Auditto"
    Local cHtml         := ""
    Local aAttach       := ""
    Local lMsgErro      := .F.
    Local lMsgOK        := .F.
    Local Rotina        := "ZFISF002"
    Local Observação    := ""
    lOCAL cReplyTo	    := "valter.carvalho@caoa.com.br"


    cHtml := ;
        "<h2>"                                                                       + CRLF +;
        "  Houve uma falha no envio dos arquivos de integração com a Auditto. <br/>" + CRLF +;
        "  Data da execução: " + dtoc(date())  + " " + time() + "             <br/>" + CRLF +;
        "  Por favor, informe ao setor de T.i.                                <br/>" + CRLF +;
        "  Detalhe do erro:                                                   <br/>" + CRLF +;
        "</h2>"                                                                      + CRLF +;
        "" +  cRes  + "                                                       <br/>" + CRLF +;
        " <h5>Esse email fo igerado pela rotina ZFISF002 </h5>"

    lRes := u_ZGENMAIL(cMailDestino	,cMailCopia	,cAssunto	,cHtml		,aAttach	,lMsgErro  ,lMsgOK		,Rotina,	Observação	, cReplyTo	)
return


/*
=====================================================================================
Programa.:              SndFtpCaoa
Autor....:              CAOA - Valter Carvalho
Data.....:              29/01/2019
Descricao / Objetivo:   Envia os arquivos gerados para o FTP da Caoa
Doc. Origem:
Solicitante:            Audito
Uso......:              
=====================================================================================
*/
static Function SndFtpCaoa(aFiles, cRes, oProcess)
    Local i
    Local cDrive
    Local cDir
    Local cNome
    Local cExt
    Local cftpSrv   := Getmv("CMV_FTPSRV")
    Local nFtpPor   := Getmv("CMV_FTPPOR")  
    Local cFtpUsr   := Getmv("CMV_FTPUSR")
    Local cFTpPss   := Getmv("CMV_FTPPSS")
    Local cFtpDir   := Getmv("CMV_FTPDIR") 
    Local oFTP      := TFtpClient():New()
    Local nRet      := 0

    oFtp:nConnectTimeout    := 10   // 
    oFTP:bFireWallMode      := .T.  // .T. = passivo
    oFTP:nTransferType      := 0    // ascii

    nRet := oFTP:FTPConnect(cftpSrv, nFtpPor, cFtpUsr, cFTpPss)

    nRet := oFTP:ChDir(cFtpDir)

    for i:= 1 to len(aFiles)
        SplitPath( aFiles[i], @cDrive, @cDir, @cNome, @cExt )
        
        If !Empty(oProcess)
            oProcess:IncRegua2("Arquivo: " + cNome + cExt)
        EndIf

        nRet := oFTP:SendFile(aFiles[i], cNome + cExt )     // enviar os arquivos
    Next

    oFTP:Close()

    If (nRet != 0)
        cRes := "ERROR: Erro ao transmitir os aquivos para o host FTP Caoa, erro: " + CRLF + oFTP:GetLastResponse()
        Logar(cRes)        
    else
        cRes := "OK"
    EndIf

Return cRes

Static Function Logar(cMsg)
    conOut(cMsg + ' ' + Time())
return
