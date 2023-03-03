#Include "PROTHEUS.CH"
#Include "TOTVS.ch"

/*=====================================================================================/  
|   Funções chamadas via colunas adicionadas no browse da rotina de Romaneios de carga |
|   para retorno de codigo e nome do destinatario                                      | 
/=====================================================================================*/

/*
===========================================================================================
Programa.: ZGFEF004
Autor....: CAOA - Fagner Barreto
Data.....: 11/04/2022
Descricao / Objetivo: Retorna código do destinatario
===========================================================================================
*/
User Function ZGFEF004()
    Local cRet := ""

    GW1->( DbSetOrder(9) )

    If GWN->GWN_CDTPOP = "LOCACAO"
        cRet := "Varios"
    Else
        If GW1->( MsSeek( FWxFilial("GW1") + GWN->GWN_NRROM ) )
            cRet := GW1->GW1_CDDEST
        EndIf
    EndIf

Return cRet

/*
===========================================================================================
Programa.: ZGFEF4NM
Autor....: CAOA - Fagner Barreto
Data.....: 11/04/2022
Descricao / Objetivo: Retorna nome do destinatario
===========================================================================================
*/
User Function ZGFEF4NM()
    Local cRet := ""

    GW1->( DbSetOrder(9) )

    If GWN->GWN_CDTPOP = "LOCACAO"
        cRet := "Varios"
    Else
        If GW1->( MsSeek( FWxFilial("GW1") + GWN->GWN_NRROM ) )
            cRet := POSICIONE("GU3",1,FWxFilial("GU3")+GW1->GW1_CDDEST,"GU3_NMEMIT")
        EndIf
    EndIf

Return cRet
