
/* =====================================================================================
Programa.:              ZEICF010
Autor....:              CAOA - Valter Carvalho
Data.....:              23/06/2021
Descricao / Objetivo:   Efetua a limpeza ta tabela EWZ, mapeamento das tabelas do EIC
Doc. Origem:
Solicitante:            CAOA -  - Anápolis
Uso......:              IN100CLI_PE
Obs......:
===================================================================================== */
User Function ZEICF010()

     If MsgYesNo( "Deseja remover os arquivos de nota e despesas não processados?", "ZEICF010") = .T.
          zRemover()
     EndIF

Return

Static Function zRemover()
     Local cPath := "/comex/intdespachante/recebidos/"
     Local bCond := {|| EWZ->EWZ_SERVIC $ "RNF|RDE" }
     Local bAct  := {|| FErase( cPath + Alltrim(EWZ->EWZ_ARQUIV), Nil, .F. ), RecLock("EWZ", .F.), EWZ->(DbDelete()), EWZ->(MsUnLock()) }

     DbSelectArea("EWZ")
     DbSetOrder(1)
     EWZ->(DbGoTop())
     EWZ->(DbEval( bAct, bCond))

Return



