#INCLUDE "PROTHEUS.CH"

/*
=====================================================================================
Programa.:              WMSQYSEP
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              22/08/22
Descricao / Objetivo:   Realiza a passagem dos dados do endereço de produção utilizado
                        no processo de emprestimo backflush          
=====================================================================================
*/
User Function WMSQYSEP()
    Local cArmazem  := PARAMIXB[1]
    Local cEndereco := PARAMIXB[2]
    Local cProduto  := PARAMIXB[3]
    Local cPrdOri   := PARAMIXB[4]
    Local cLoteCtl  := PARAMIXB[5]
    Local cNumLote  := PARAMIXB[6]
    Local lCnsPkgFut := PARAMIXB[7]
    Local cQuery    := ""
    Local cAliasD14 := ""
    Local aTamSX3   := TamSx3("D14_QTDEST")

    If !FWIsInCallStack("U_ZPCPJ002") //--Executa somente se a chamada for do Backflush Caoa
        cAliasD14 := 0 //--Grava alias como numerico para forçar o desvio na rotina padrão
        Return cAliasD14
    EndIf

    cAliasD14 := GetNextAlias()

    cQuery := "SELECT DC3_ORDEM,"
    cQuery += " D14_ENDER,"
    cQuery += " D14_ESTFIS,"
    cQuery += " D14_LOTECT,"
    cQuery += " D14_NUMLOT,"
    cQuery += " D14_DTVALD,"
    cQuery += " D14_NUMSER,"

    If lCnsPkgFut == .T.
            cQuery += " (D14_QTDEST+D14_QTPEPR-(D14_QTDEMP+D14_QTDBLQ )) D14_QTDLIB,"
            cQuery += " (D14_QTDEST+D14_QTPEPR-(D14_QTDEMP+D14_QTDBLQ+D14_QTDSPR)) D14_SALDO,"
    Else
            cQuery += " (D14_QTDEST-(D14_QTDEMP+D14_QTDBLQ)) D14_QTDLIB,"
            cQuery += " (D14_QTDEST-(D14_QTDEMP+D14_QTDBLQ+D14_QTDSPR)) D14_SALDO,"
    EndIf

    cQuery += " D14_QTDSPR,"
    cQuery += " D14_IDUNIT,"
    cQuery += " D14_CODUNI,"
    cQuery += " BE_STATUS"
    cQuery += " FROM "+RetSqlName("D14")+" D14"
    cQuery += " INNER JOIN "+RetSqlName("DC3")+" DC3"
    cQuery += " ON DC3.DC3_FILIAL = '"+xFilial("DC3")+"'"
    cQuery += " AND DC3.DC3_LOCAL = D14.D14_LOCAL"
    cQuery += " AND DC3.DC3_CODPRO = D14.D14_PRODUT"
    cQuery += " AND DC3.DC3_TPESTR = D14.D14_ESTFIS"
    cQuery += " AND DC3.D_E_L_E_T_ = ' '"
    cQuery += " INNER JOIN "+RetSqlName("DC8")+" DC8"
    cQuery += " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
    cQuery += " AND DC8.DC8_CODEST = D14.D14_ESTFIS"
    cQuery += " AND DC8.DC8_TPESTR = '7'" //--Filtra apenas estruturas de produção
    cQuery += " AND DC8.D_E_L_E_T_ = ' '"
    cQuery += " INNER JOIN "+RetSqlName("SBE")+" SBE"
    cQuery += " ON SBE.BE_FILIAL  = '"+xFilial("SBE")+"'"
    cQuery += " AND SBE.BE_LOCAL   = D14.D14_LOCAL"
    cQuery += " AND SBE.BE_LOCALIZ = D14.D14_ENDER"
    cQuery += " AND SBE.D_E_L_E_T_ = ' '"
    cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
    cQuery += " AND D14.D14_LOCAL = '"+cArmazem+"'"
    cQuery += " AND D14.D14_PRODUT = '"+cProduto+"'"
    cQuery += " AND D14.D14_PRDORI = '"+cPrdOri+"'"

    // Se foi informado endereço, lote e/ou sublote na inclusão do pedido
    If !Empty(cEndereco)
            cQuery += " AND D14.D14_ENDER = '"+cEndereco+"'"
    EndIf

    If !Empty(cLoteCtl)
            cQuery += " AND D14.D14_LOTECT = '"+cLoteCtl+"'"
    EndIf

    If !Empty(cNumLote)
            cQuery += " AND D14.D14_NUMLOT = '"+cNumLote+"'"
    EndIf

    cQuery += " AND (D14.D14_QTDEST-(D14.D14_QTDEMP+D14.D14_QTDBLQ)) > 0"
    cQuery += " AND D14.D_E_L_E_T_ = ' '"
    cQuery := ChangeQuery(cQuery)

    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD14,.F.,.T.)
    // Ajustando o tamanho dos campos da query
    TcSetField(cAliasD14,'D14_DTVALD','D')
    TcSetField(cAliasD14,'D14_QTDLIB','N',aTamSX3[1],aTamSX3[2])
    TcSetField(cAliasD14,'D14_QTDSPR','N',aTamSX3[1],aTamSX3[2])
    TcSetField(cAliasD14,'D14_QTDPEM','N',aTamSX3[1],aTamSX3[2])
    TcSetField(cAliasD14,'D14_SALDO' ,'N',aTamSX3[1],aTamSX3[2])

Return cAliasD14
