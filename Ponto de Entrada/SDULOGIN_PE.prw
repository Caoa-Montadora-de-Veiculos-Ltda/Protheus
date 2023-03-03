#include "protheus.ch"

/*
=====================================================================================
Programa.:              SduLogin
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              03/03/2020
Descricao / Objetivo:   Ponto de Entrada que permite acessar APSDU
Doc. Origem:            
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              APSDU
Obs......:
=====================================================================================
*/

User Function SduLogin()

Local cUsrLogin := ""
Local cAutoriz  := ""
Local lUserAut  := .F.
Local lAdmin    := .F.
Local cQry01	:= ""
Local cTabSql   := ""

cUsrLogin   := RetCodUsr()
cAutoriz    := "000000*000095*000009*000356" //"evandro.mariano; fabio.giacomozzi; antonio.poliveira"
lUserAut    := .F.
lAdmin      := FwIsAdmin(RetCodUsr())
cTabSql     := GetNextAlias()


If lAdmin
    If "_PRD" $ AllTrim(GetEnvServer()) .OR. AllTrim(GetEnvServer()) == "PRIME"

        If Select((cTabSql)) > 0
            (cTabSql)->(DbCloseArea())
        EndIf

        //==============================================================================================================
        // Busca informações na tabela de Usuários
        //==============================================================================================================    
        cQry01 := ""
        cQry01 += " SELECT * FROM (
        cQry01 += "                 SELECT USR_ACESSO ACESSO FROM ABDHDU_PROT.SYS_USR_ACCESS "  + CRLF
        cQry01 += "                 WHERE  D_E_L_E_T_ = ' ' "                                   + CRLF
        cQry01 += "                 AND USR_ID = '" + cUsrLogin + "' "                          + CRLF
        cQry01 += "                 AND USR_ACESSO = 'T' "                                      + CRLF
        cQry01 += "                 AND USR_CODACESSO = '173' "                                 + CRLF
    
        cQry01 += " UNION ALL "                                                                 + CRLF
    
        cQry01 += " SELECT GR__ACESSO ACESSO FROM ABDHDU_PROT.SYS_GRP_ACCESS "                  + CRLF
        cQry01 += " WHERE D_E_L_E_T_ = ' ' "                                                    + CRLF
        cQry01 += " AND GR__CODACESSO = '173' "                                                 + CRLF
        cQry01 += " AND GR__ACESSO = 'T' "                                                      + CRLF
        cQry01 += " AND GR__ID IN ( SELECT USR_GRUPO FROM ABDHDU_PROT.SYS_USR_GROUPS "          + CRLF
        cQry01 += "                 WHERE  D_E_L_E_T_ = ' ' "                                   + CRLF
        cQry01 += "                 AND USR_ID = '" + cUsrLogin + "' "                          + CRLF
        cQry01 += "                 AND USR_GRUPO <> ' ') "                                     + CRLF
        cQry01 += " )USRACESS "
        
        cQry01  := ChangeQuery(cQry01)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry01),cTabSql,.T.,.T.)

        DbSelectArea((cTabSql))
        (cTabSql)->(dbGoTop())
        If !(cTabSql)->(Eof())
            If (cTabSql)->ACESSO == "T" //"Se acessa APSDU, é Read-Write"
                If cUsrLogin $ cAutoriz
                    lUserAut := .T.
                Else
                    ApMsgInfo( "Você tem acesso ao APSDU, mas não tem autorização para acessar nesse ambiente, procure o adminstrador do ambiente" , "[ SDULOGIN_PE ] - Finalizado" )
                    lUserAut := .F.
                EndIf
            Else
                ApMsgInfo( "Você esta acessando o APSDU como Somente Leitura" , "[ SDULOGIN_PE ] - Finalizado" )
                lUserAut := .T.
            EndIf
        Else
            ApMsgInfo( "Você esta acessando o APSDU como Somente Leitura" , "[ SDULOGIN_PE ] - Finalizado" )
            lUserAut := .T.
        EndIf
        (cTabSql)->(DbCloseArea())
    Else
        lUserAut := .T.
    EndIf
Else
  ApMsgInfo( "Você precisa pertencer ao Grupo de Administradores - 000000 " , "[ SDULOGIN_PE ] - Finalizado" )
  lUserAut := .F.
EndIf

Return(lUserAut)
