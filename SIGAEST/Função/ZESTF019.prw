#Include "PROTHEUS.CH"
#include 'topconn.ch'
#INCLUDE "FWMVCDEF.CH"

/*
=====================================================================================
Programa.:              ZESTF019
Autor....:              Evandro Mariano
Data.....:              08/02/2024
Descricao / Objetivo:   Bloqueio de Estoque
Doc. Origem:
Solicitante:            Montadora/Peças
Uso......:              CAOA Montadora de Veiculos
Obs......:
=====================================================================================
*/
User Function ZESTF019(_cMestre, _cTipo)

Local lErro     := .T.
Local _cMsgn    := iIF(_cTipo == "1", "Deseja bloquear o armazem do mestre: ", "Deseja desbloquear o armazem do mestre: " )

    If FWAlertYesNo( _cMsgn +AllTrim(_cMestre), 'ZESTF019' )

        DbSelectArea( "ZZI" )
        ZZI->( DbSetOrder( 1 ) )
        If ZZI->(DbSeek(xFilial("ZZI")+_cMestre))
            If ( _cTipo == "1" .And. ZZI->ZZI_STATUS $ "1|2|3|4" ) .Or. ( _cTipo == "2" .And. ZZI->ZZI_STATUS == "5" )
                Processa( { || lErro := zProcUpdate(_cTipo) }, "Realizando bloqueio/desbloqueio do armazem", "Aguarde ...." )
                If lErro
                    
                    RecLock("ZZI", .F.)
                        ZZI->ZZI_STATUS := iIF(_cTipo == "1", "5", "6" )
                    ZZI->( MsUnlock())

                    If _cTipo == "1"
                        FWAlertSuccess("Bloqueio feito com sucesso", "ZESTF019")
                    Else
                        FWAlertSuccess("Desbloqueio feito com sucesso", "ZESTF019")
                    EndIf
                Else
                    FWAlertError("Erro ao executar o bloqueio/desbloqueio, analise o erro e processe novamente", "ZESTF019")
                EndIf
            Else
                FWAlertError("Permitido bloqueio/desbloqueio do armazem com o Status 3|6 ", "ZESTF019")
            EndIf    

        Else         
            FWAlertError("Mestre não encontrado", "ZESTF019")
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
Static Function zProcUpdate(_cTipo)

Local cUpdate       := ""
Local lRet          := .T.
Private cAliasSB2   := GetNextAlias()

    Begin Transaction
        //--Limpa os campos de empenho/reserva/
        cUpdate :=  " UPDATE " + RetSqlName("SB2")                                              + CRLF
        If _cTipo == "1"
            cUpdate	+=  " SET B2_DTINV = '" + DToS( ZZI->ZZI_DATA ) + "' "                      + CRLF
        Else
        cUpdate	+=  " SET B2_DTINV = ' ' "                                                      + CRLF
        EndIf
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

    End Transaction
   
Return(lRet)
