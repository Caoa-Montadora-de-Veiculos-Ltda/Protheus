#Include 'Protheus.ch'
#Include 'TopConn.ch'
/*/{Protheus.doc} User Function ZPECF002 (_cCodPro)

@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	08/09/2021
@return  	NIL
@obs        Atualizar preço via Tabela para itens na SB1
@project
@history    
/*/
User Function ZPECF002(_cCodPro)
Local _aArea  := GetArea()

    SB1->(dbSetOrder(1))
    If SB1->( dbSeek( xFilial("SB1") + _cCodPro ) )
        SB1->(RecLock("SB1",.F.))
        SB1->SB1_PRV1 := _nPrcv   
        SB1->(MsUnlock())
    ENDIF

RestArea(_aArea)

Return()
