#Include "PROTHEUS.CH"
#Include 'topconn.ch'

/*
=====================================================================================
Programa.:              ZCOMF016
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              07/04/2020
Descricao / Objetivo:   Realiza a exclusão de registros da tela reprocessar do Totvs Colaboração
Doc. Origem:            GAP COM107
Solicitante:            Luanna Florencio
=====================================================================================
*/
User Function ZCOMF016() // u_ZCOMF016()
    Local aSays         := {}
    Local aButtons      := {} 
    Local cCadastro     := "Excluir Docs Tela Reprocessar Totvs Colaboração"
    Local nOpcA         := 0

    If U_ZGENUSER( RetCodUsr() ,"ZCOMF016" ,.T.)

        AADD(aSays,"Esta rotina tem o objetivo de realizar a exclusão dos documentos com erro da tela ")
        AADD(aSays,"reprocessar do Totvs Colaboração.")
        AADD(aSays,"Clique em OK para confirmar a exclusão.")

        AADD(aButtons, { 1,.T.,{|o| nOpca := 1, o:oWnd:End() }} )
        AADD(aButtons, { 2,.T.,{|o| nOpca := 2, o:oWnd:End() }} )
                    
        FormBatch( cCadastro, aSays, aButtons )

        If nOpca == 1
            FWMsgRun( ,{|| ZCOMPROC() } ,"Excluir Docs Tela Reprocessar Totvs Colaboração",;
                                         "Por favor aguarde... Efetuando a exclusão dos registros da tela reprocessar...")
        EndIf    

    EndIf

Return

/*
=====================================================================================
Programa.:              ZCOMPROC
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              05/03/2020
Descricao / Objetivo:   Realiza a exclusão de registros na tabela CKOCOL
Solicitante:            Luanna Florencio
=====================================================================================
*/
Static Function ZCOMPROC()
    Local cUpdate   := ""

    cUpdate := " UPDATE " + RetSqlName("CKOCOL") + CRLF
    cUpdate	+= " SET D_E_L_E_T_ = '*' " + CRLF        
    cUpdate += " WHERE D_E_L_E_T_ = ' ' " + CRLF
    cUpdate += "    AND CKO_FILIAL = '" + FWxFilial("CKOCOL") + "' " + CRLF
    cUpdate += "    AND CKO_IDERP = ' ' " + CRLF
    cUpdate += "    AND CKO_FLAG = '2' " + CRLF
    cUpdate += "    AND CKO_CODEDI IN " + FormatIn(SuperGetMV("CMV_COL002"), "/") + " " + CRLF
    cUpdate += "    AND CKO_CODERR NOT IN " + FormatIn(SuperGetMV("CMV_COL003"), "/") + " " + CRLF

    If TcSqlExec(cUpdate) < 0
        Help( ,, "CaoaTec",, TcSqlError() , 1, 0)
    Else
        MsgInfo("Exclusão realizada com sucesso!", "CaoaTec")
    EndIf

Return
