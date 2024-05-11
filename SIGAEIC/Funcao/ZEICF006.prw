#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"
#DEFINE  CRLF Char(13) + Char(10)


/* =====================================================================================
Programa.:              ZEICF006
Autor....:              CAOA - Valter Carvalho
Data.....:              15/12/2020
Descricao / Objetivo:   Efetua o ajuste dos campos da SB1 no momento que o cadastro de NCM sofre atualização
Doc. Origem:            
Solicitante:            CAOA - Montadora - Anápolis
Uso......:              EICA130
Obs......:				ponto de entrada usado ao montar a tela de despesas.	
===================================================================================== */
User Function ZEICF006()
    Local aRegs := {}

    FWMsgRun(, {|| aRegs := zGetItens() }, "", "Verificando itens passíveis de atualização...")
    If Len(aRegs) = 0
        Return 
    EndIf

	Processa({|| zProcessa(aRegs) }, "[ZEICF006]", "Atualizando Campos produtos" )
Return

Static Function zGetItens()
    Local aRegs   := {}
    Local cQr     := GetNextAlias()
    Local cmd     := ""
   
    cmd += CRLF + " SELECT B1_COD, B1_DESC, R_E_C_N_O_ AS RECNO "
    cmd += CRLF + " FROM " + RetSqlName("SB1") 
    cmd += CRLF + " WHERE  "
    cmd += CRLF + "     D_E_L_E_T_ = ' ' "  
    cmd += CRLF + " AND B1_FILIAL  = '" + Xfilial("SB1") + "' "
    cmd += CRLF + " AND B1_POSIPI  = '" + SYD->YD_TEC     + "' "  
    cmd += CRLF + " AND B1_EX_NCM  = '" + SYD->YD_EX_NCM  + "' "  

    TcQuery cmd new alias (cQr)

    (cQr)->(DbEval({|| Aadd(aRegs, {(cQr)->B1_COD, (cQr)->B1_DESC, (cQr)->RECNO})}   ))
    
    (cQr)->(DbCloseArea())

    If Len(aRegs) = 0
        Return {}
    EndIf

    cmd := ""
    cmd += CRLF + "Existem " + PadL(Len(aRegs), 5, "0") + " produto(s) com esse NCM/Ex"
    cmd += CRLF + "Campos que serão atualizados: "
    cmd += CRLF +  " - Retem PIS."       
    cmd += CRLF +  " - Retem COFINS."    
    cmd += CRLF +  " - Grupo tributário."
    cmd += CRLF +  " - IPI."
    cmd += CRLF + "Deseja atualizar esses campos nos produtos ? "
    
    If MsgYesNo(cmd, "ZEICF006") = .F.
        Return {}
    Endif

    ApMsgInfo(cmd, "ZEICF006")

Return aRegs


Static Function zProcessa(aRegs)
    Local cMsg    := ""
    Local i       := 1
    Local oMdl

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))

    ProcRegua(Len(aRegs))

    For i:=1 to Len(aRegs)
        oMdl := FWLoadModel('MATA010')
	    
        IncProc("Item: " + PadL(i, 5, "0") + " de " + PadL(Len(aRegs), 5, "0"))

        SB1->(DbGoTo(aRegs[i, 3]))

        oMdl:SetOperation(MODEL_OPERATION_UPDATE)
        oMdl:Activate()
        oMdl:SetValue("SB1MASTER", "B1_PIS"   , SYD->YD_XRETPIS)
        oMdl:SetValue("SB1MASTER", "B1_COFINS", SYD->YD_XRETCOF)
        oMdl:SetValue("SB1MASTER", "B1_GRTRIB", SYD->YD_XGRPTRI)
        oMdl:SetValue("SB1MASTER", "B1_IPI"   , SYD->YD_PER_IPI)

        If oMdl:VldData()
            oMdl:CommitData()
            cMsg += CRLF + "OK   Cod:" + Alltrim(aRegs[i, 1]) + " " + Substr(aRegs[i, 2], 1, 25) 
        Else
            cMsg += CRLF + "ERRO Cod:" + Alltrim(aRegs[i, 1]) + " " + Substr(aRegs[i, 2], 1, 25) + " Inconsistência no cadastro: " +  oMdl:GetErrorMessage()[6]
        Endif

        oMdl:DeActivate()
    Next

    SB1->(DbCloseArea())

    EecView("*** Resumo da atualização ***" + CRLF + cMsg, "ZEICF006")

Return
