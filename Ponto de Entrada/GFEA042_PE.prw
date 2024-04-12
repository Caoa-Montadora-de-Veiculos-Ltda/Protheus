#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"

/*
=====================================================================================
Programa.:              GFEA042_PE.PRW
Autor....:              CAOA - Nicolas C Lima Santos 
Data.....:              05/01/24
Descricao / Objetivo:   Ponto de entrada para Inclus�o de Nova Op��o no Menu (menudef)
Doc. Origem:            GAP032
Solicitante:            Micaellen Leal
Uso......:              Inserir op��ono menu de outras a��es.
Obs......:              https://tdn.totvs.com/pages/releaseview.action?pageId=239034846
=====================================================================================
*/

User Function GFEA0442()
 
    Local aRotina
    
    // Posi��es do Array
    // 1. Nome da op��o no menu   
    // 2. Nome da Rotina associada                                
    // 3. Usado pela rotina                                       
    // 4. Tipo de Opera��o a ser efetuada
    aRotina :=  {{"Alterar Peso de NF", "u_zMsg()", 0, 4}}
 
Return aRotina

User Function zMsg()
    Local aArea := FWGetArea()
    //Local nPosAtual := aArea[3] //Recno GW1 Posicionado.
    //Local nTipoDoc := ""
    Local aDadosGW1 := {} //[1] - recno, [2] Tipo documento, [3] N�mero documento
    Local cQry := " "
    Local cAliasTemp := GetNextAlias()

    AADD(aDadosGW1, aArea[3])
    
    //Garante posi��o do RECNO atual
    GW1->(DbGoTo(aDadosGW1[1]))//RECNO GW1
    
    AADD(aDadosGW1, GW1->GW1_CDTPDC) //[2] Tipo documento
    AADD(aDadosGW1, GW1->GW1_NRDC)   //[3] N�mero documento

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
            MsgStop("Fun��o n�o encontrada, contate ADM Sistemas.","Aten��o.")
        EndIf
    Else
        MsgInfo("Carta de corre��o n�o enviada.","Aten��o.")
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
        //�ndice[1] SF2 -> F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                  
        //Chama o fonte MVC desejado com a opera��o indicada (4 - Altera��o)
        FWExecView("Alterar peso cubado.", "ZGFEF008", 4)
    Else
        MsgStop("N�mero de documento n�o encontrado.","Aten��o")
    EndIf

    SetFunName(cFunBkp)
    RestArea(aArea)
Return
    
    
