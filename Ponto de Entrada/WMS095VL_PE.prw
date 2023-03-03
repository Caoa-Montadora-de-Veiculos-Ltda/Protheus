#Include "PROTHEUS.CH"
#Include "TOTVS.CH"

/*
=====================================================================================
Programa.:              WMS095VL
Autor....:              CAOA - Fagner Barreto
Data.....:              20/01/2020
Descricao / Objetivo:   PE executado na valida��o do endere�o de destino.
Doc. Origem:
=====================================================================================
*/
User Function WMS095VL()
    Local lRet      := .T.
    Local lExec     := GetNewPar( "CMV_WMS017", .F. )
    Local cArmOri   := PARAMIXB[1] //armaz�m origem
    //Local cEnderOri := PARAMIXB[2] //endere�o origem
    Local cArmDes   := PARAMIXB[3] //armaz�m destino
    //Local cEnderDes := PARAMIXB[4] //endere�o destino
    Local cProduto  := PARAMIXB[5] //produto
    
    If FindFunction("U_ZWMSF017")
        
        If lExec
            
            If !Empty( cProduto )
                //--Verifica se existe lock de registro na tabela SB2
                lRet := U_ZWMSF017(cArmOri, cArmDes, cProduto)
            EndIf
            
        EndIf

    Endif

Return lRet
