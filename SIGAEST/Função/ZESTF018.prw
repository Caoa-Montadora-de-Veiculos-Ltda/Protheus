#Include "PROTHEUS.CH"
#include 'topconn.ch'
#INCLUDE "FWMVCDEF.CH"

/*
=====================================================================================
Programa.:              ZESTF018
Autor....:              Evandro Mariano
Data.....:              08/02/2024
Descricao / Objetivo:   Limpeza dos Empenhos/Reserva
Doc. Origem:
Solicitante:            Montadora/Peças
Uso......:              CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/
User Function ZESTF018(_cMestre)

Local lErro := .T.

    If FWAlertYesNo( "Deseja limpar o empenho/reserva para o mestre: " +AllTrim(_cMestre), 'ZESTF017' )

        DbSelectArea( "ZZI" )
        ZZI->( DbSetOrder( 1 ) )
        If ZZI->(DbSeek(xFilial("ZZI")+_cMestre))
            If ZZI->ZZI_STATUS $ "1|2|3|4" //"2 | Contagem Importada" - "3 | Refaz Saldo Processado"
                Processa( { || lErro := zProcUpdate() }, "Realizando a limpeza dos Empenhos/Reservas", "Aguarde ...." )
                If lErro
                    RecLock("ZZI", .F.)
                        ZZI->ZZI_STATUS := '4' //"4 | Limpeza dos Empenhos/Reserva realizada"
                    ZZI->( MsUnlock())
                    FWAlertSuccess("Limpeza Feita com sucesso", "ZESTF018")
                Else
                    FWAlertError("Erro ao executar a limpeza dos Empenhos/Reserva, analise o erro e processe novamente", "ZESTF018")
                EndIf
            Else
                FWAlertError("Permitido Limpeza dos Empenho/Reserva com o Status 1|2|3|4 ", "ZESTF018")
            EndIf    

        Else         
            FWAlertError("Mestre não encontrado", "ZESTF018")
        EndIf
    EndIf

Return()

/*
=====================================================================================
Programa.:              zProcUpdate
Autor....:              Evandro Mariano
Data.....:              08/02/2024
Descricao / Objetivo:   Processa os Updates
Doc. Origem:
Solicitante:            Montadora/Peças
Uso......:              CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/
Static Function zProcUpdate()

Local cUpdate       := ""
Local lRet          := .T.
Private cAliasSBF   := GetNextAlias()
Private cAliasSB8   := GetNextAlias()
Private cAliasSB2   := GetNextAlias()

    Begin Transaction
        //--Limpa os campos de empenho/reserva/
        cUpdate :=  " UPDATE " + RetSqlName("SB2")                                              + CRLF
        cUpdate	+=  " SET B2_QEMP = 0 "                                                         + CRLF
        cUpdate +=  "   , B2_QEMPN = 0 "                                                        + CRLF
        cUpdate +=  "   , B2_RESERVA = 0 "                                                      + CRLF
        cUpdate +=  "   , B2_QPEDVEN = 0 "                                                      + CRLF
        cUpdate +=  "   , B2_NAOCLAS = 0 "                                                      + CRLF
        cUpdate +=  "   , B2_SALPEDI = 0 "                                                      + CRLF
        cUpdate +=  "   , B2_QTNP = 0 "                                                         + CRLF
        cUpdate +=  "   , B2_QNPT = 0 "                                                         + CRLF
        cUpdate +=  "   , B2_QTER = 0 "                                                         + CRLF
        cUpdate +=  "   , B2_QACLASS = 0 "                                                      + CRLF
        cUpdate +=  "   , B2_QEMPSA = 0 "                                                       + CRLF
        cUpdate +=  "   , B2_QEMPPRE = 0 "                                                      + CRLF
        cUpdate +=  "   , B2_SALPPRE = 0 "                                                      + CRLF
        cUpdate +=  " WHERE B2_FILIAL = '" + FWxFilial("SB2") + "'"                             + CRLF    
        cUpdate +=  " AND B2_LOCAL = '" + ZZI->ZZI_LOCAL + "'"                                  + CRLF
        cUpdate +=  " AND B2_COD IN ( SELECT B7_COD FROM " + RetSQLName('SB7') + " "            + CRLF
        cUpdate +=  "                   WHERE D_E_L_E_T_ = ' ' "                                + CRLF
        cUpdate +=  "                   AND B7_DOC = '" + ZZI->ZZI_MESTRE + "'   "              + CRLF
        cUpdate +=  "                   AND B7_DATA = '" + DToS(ZZI->ZZI_DATA) + "' ) "         + CRLF
        cUpdate +=  " AND D_E_L_E_T_ = ' ' "                                                    + CRLF

        If TcSqlExec(cUpdate) < 0
            lRet := .F.
            Help( ,, "Caoa",, TcSqlError() , 1, 0)
            Disarmtransaction()
        EndIf

        If lRet
            cUpdate :=  " UPDATE " + RetSqlName("SBF")                                                  + CRLF
            cUpdate	+=  " SET BF_EMPENHO = 0 "                                                          + CRLF
            cUpdate +=  "   , BF_QEMPPRE = 0 "                                                          + CRLF
            cUpdate +=  "   , BF_EMPEN2 = 0 "                                                           + CRLF
            cUpdate +=  "   , BF_QEPRE2 = 0 "                                                           + CRLF
            cUpdate +=  " WHERE BF_FILIAL = '" + FWxFilial("SBF") + "'"                                 + CRLF    
            cUpdate +=  " AND BF_LOCAL = '" + ZZI->ZZI_LOCAL + "'"                                      + CRLF
            cUpdate +=  " AND BF_PRODUTO IN ( SELECT B7_COD FROM " + RetSQLName('SB7') + " "            + CRLF
            cUpdate +=  "                   WHERE D_E_L_E_T_ = ' ' "                                    + CRLF
            cUpdate +=  "                   AND B7_DOC = '" + ZZI->ZZI_MESTRE + "'   "                  + CRLF
            cUpdate +=  "                   AND B7_DATA = '" + DToS(ZZI->ZZI_DATA) + "' ) "             + CRLF
            cUpdate +=  " AND D_E_L_E_T_ = ' ' "                                                        + CRLF

            If TcSqlExec(cUpdate) < 0
                lRet := .F.
                Help( ,, "Caoa",, TcSqlError() , 1, 0)
                Disarmtransaction()
            EndIf
        EndIf

        If lRet
            cUpdate :=  " UPDATE " + RetSqlName("SB8")                                                  + CRLF
            cUpdate	+=  " SET B8_EMPENHO = 0 "                                                          + CRLF
            cUpdate +=  "   , B8_QEMPPRE = 0 "                                                          + CRLF
            cUpdate +=  "   , B8_QACLASS = 0 "                                                          + CRLF
            cUpdate +=  "   , B8_EMPENH2 = 0 "                                                          + CRLF
            cUpdate +=  "   , B8_QEPRE2 = 0 "                                                           + CRLF
            cUpdate +=  "   , B8_QACLAS2 = 0 "                                                          + CRLF
            cUpdate +=  " WHERE B8_FILIAL = '" + FWxFilial("SB8") + "'"                                 + CRLF    
            cUpdate +=  " AND B8_LOCAL = '" + ZZI->ZZI_LOCAL + "'"                                      + CRLF
            cUpdate +=  " AND B8_PRODUTO IN ( SELECT B7_COD FROM " + RetSQLName('SB7') + " "            + CRLF
            cUpdate +=  "                   WHERE D_E_L_E_T_ = ' ' "                                    + CRLF
            cUpdate +=  "                   AND B7_DOC = '" + ZZI->ZZI_MESTRE + "'   "                  + CRLF
            cUpdate +=  "                   AND B7_DATA = '" + DToS(ZZI->ZZI_DATA) + "' ) "             + CRLF
            cUpdate +=  " AND D_E_L_E_T_ = ' ' "                                                        + CRLF

            If TcSqlExec(cUpdate) < 0
                lRet := .F.
                Help( ,, "Caoa",, TcSqlError() , 1, 0)
                Disarmtransaction()
            EndIf
        EndIf

    End Transaction
   
Return(lRet)
