#Include 'Protheus.ch'
#Include 'TopConn.ch'
/*/{Protheus.doc} ZCOMF054
@param  	
@author 	Sandro Ferreira
@version  	P12.1.23
@since  	27/09/2023
@return  	NIL
@obs        Desbloqueia produto do SB1
@project
@history    
/*/ 
User Function ZCOMF054()
Local _aArea  := GetArea()
IF FWCodEmp() <> "2010"
    If U_ZGENUSER( RetCodUsr() ,"ZCOMF054" ,.T.)
        If APMsgYesNo("Deseja realmente desbloquear o Produto: " + SB1->B1_COD +  "  ?")
            IF SB1->B1_MSBLQL = '1'
                SB1->(RecLock("SB1",.F.))
                SB1->B1_MSBLQL := "2"
                SB1->(MsUnlock())
                //Atualiza a tabela de log de alteração/inclusão de produtos
                RecLock('ZZN', .T.)
                ZZN_FILIAL := xFILIAL("ZZN")
                ZZN_COD    := SB1->B1_COD
                ZZN_DESCR  := SB1->B1_DESC
                ZZN_DATA   := DATE()
                ZZN_HORA   := TIME()
                ZZN_INIC   := "2"
                ZZN_FINAL  := "1"
                ZZN_USUR   := __cUserID + " - " + cUserName
                ZZN_CAMPO  := "B1_MSBLQL"
                ZZN_MOVTO  := "PRODUTO DESBLOQUEADO MANUALMENTE PELO USUÁRIO"
                ZZN->(MsUnlock())
                MSGINFO( "Produto Desbloqueado com Sucesso!", "Atenção" )
            ELSE
                MSGINFO( "Esse Produto não pode ser desbloqueado, pois já se encontra desbloqueado!", "Atenção" )
            ENDIF
        ENDIF
    ELSE
        MSGINFO( "Usuário sem permissão para executar essa rotina!", "Atenção" )
    ENDIF
ENDIF
RestArea(_aArea)

Return()
