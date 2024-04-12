#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

/*
=====================================================================================
Programa.:              GFEA042_PE.PRW
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              05/01/24
Descricao / Objetivo:   Ponto de entrada para Inclusão de Nova Opção no Menu (menudef)
Doc. Origem:            GAP032
Solicitante:            Micaellen Leal
Uso......:              Inserir opçãono menu de outras ações.
Obs......:              https://tdn.totvs.com/pages/releaseview.action?pageId=239034846
=====================================================================================
*/

User Function GFEA0442()
 
    Local aRotina
    
    // Posições do Array
    // 1. Nome da opção no menu   
    // 2. Nome da Rotina associada                                
    // 3. Usado pela rotina                                       
    // 4. Tipo de Operação a ser efetuada
    aRotina :=  {{"Alterar Peso de NF", "u_zMsg()", 0, 4}}
 
Return aRotina

User Function zMsg()
    Local aArea := FWGetArea()
    //Local nPosAtual := aArea[3] //Recno GW1 Posicionado.
    //Local nTipoDoc := ""
    Local aDadosGW1 := {} //[1] - recno, [2] Tipo documento, [3] Número documento
    Local cQry := " "
    Local cAliasTemp := GetNextAlias()

    AADD(aDadosGW1, aArea[3])
    
    //Garante posição do RECNO atual
    GW1->(DbGoTo(aDadosGW1[1]))//RECNO GW1
    
    AADD(aDadosGW1, GW1->GW1_CDTPDC) //[2] Tipo documento
    AADD(aDadosGW1, GW1->GW1_NRDC)   //[3] Número documento

    DBSelectArea("CKQ")
    CKQ->(DbSetOrder(1)) //CKQ_FILIAL + CKQ_MODELO + CKQ_TP_MOV + CKQ_IDERP
     
    cQry  := " SELECT CKQ_MODELO "                               + CRLF
    cQry  += "  , CKQ_NUMERO "                                   + CRLF
    cQry  += " FROM " + RetSqlName("CKQ") + " CKQ"               + CRLF
    cQry  += " WHERE CKQ_FILIAL = '" + FWxFilial('CKQ') + "' "   + CRLF
    cQry  += "  AND CKQ_MODELO = 'CCE' "                         + CRLF
    cQry  += "  AND CKQ_NUMERO = '" + aDadosGW1[3] +"' "         + CRLF
    cQry  += "  AND CKQ.D_E_L_E_T_ = ' ' "                       + CRLF
 
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cAliasTemp, .T., .T.)

	DbSelectArea((cAliasTemp))
	(cAliasTemp)->(dbGoTop())
	
    
    If !(cAliasTemp)->(Eof())
        If Alltrim(aDadosGW1[2]) $ "NFS" .and. FindFunction("ZEXECVIEW")
            zExecView(aDadosGW1)
        Else
            MsgStop("Função não encontrada, contate ADM Sistemas.","Atenção.")
        EndIf
    Else
        MsgInfo("Carta de correção não enviada.","Atenção.")
    EndIF
     
    FwRestArea(aArea)
Return
 
Static Function zExecView(aDadosGW1)
    Local aArea     := GetArea()
    Local cFunBkp   := FunName()

    Default aDadosGW1 := {}

    SetFunName("ZGFEF008")
    
    DbSelectArea('SF2')
    DbSelectArea('GW8')
    
    If !empty(aDadosGW1) .and. SF2->(DbSeek(FWxFilial("SF2") + Alltrim(aDadosGW1[3]))) 
        //Índice[1] SF2 -> F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                  
        //Chama o fonte MVC desejado com a operação indicada (4 - Alteração)
        FWExecView("Alterar peso cubado.", "ZGFEF008", 4)
    Else
        MsgStop("Número de documento não encontrado.","Atenção")
    EndIf

    SetFunName(cFunBkp)
    RestArea(aArea)
Return
    
    
