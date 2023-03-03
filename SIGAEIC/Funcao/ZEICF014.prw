#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH" 

/*=====================================================================================
Programa.:              ZEICF014
Autor....:              CAOA - Valter Carvalho
Data.....:              14/10/2021
Descricao / Objetivo:   efetua a replicação da observação da PO para o Pedido de compra
Solicitante:            Julia Alcantara / Aide
Uso......:              EICPO400_MVC          
===================================================================================== */

User Function ZEICF014()
    Local cmd := ""

    cmd += CRLF + " UPDATE " + RetSqlName("SC7")
    cmd += CRLF + " SET C7_XOBSTST = '" + SW2->W2_XOBSPED + "' "
    cmd += CRLF + " ,   C7_XOBSCOM = '" + MSMM(SW2->W2_OBS) + "' "
    cmd += CRLF + " WHERE "
    cmd += CRLF + " D_E_L_E_T_ = ' ' "
    cmd += CRLF + " AND C7_FILIAL = '" + FwXfilial("SC7") + "' " 
    cmd += CRLF + " AND C7_NUM    = '" + SW2->W2_PO_SIGA + "' "

    if TcSqlExec(cmd) < 0
        FWAlertError("Erro ao Atualizar mensagem do pedido de compra: " + TCSQLError(), "ZEICF014")
    Endif

Return


user function zAtuc7()
    DbSelectArea("SW2")
    DbSetOrder(1)

    SW2->(DbGoTop())

    While SW2->(Eof()) = .F.
        u_ZEICF014()

        SW2->(DbSkip())
    EndDo
        
    SW2->(DbCloseArea())

return
