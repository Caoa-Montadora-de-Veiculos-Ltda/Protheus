#Include 'Protheus.ch'
#Include 'TopConn.ch'
/*/{Protheus.doc} ZPECF003
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	08/09/2021
@return  	NIL
@obs        Atualizar preço via Tabela para itens em orçamento BackOrder
@project
@history    
/*/
User Function ZPECF003(_cCodPro)
Local _aArea  := GetArea()

    DbSelectArea("VS3")
    VS3->(dbSetOrder(4))   //Filial+Codite
    IF VS3->( dbSeek( xFilial("VS3") + _cCodPro ) )
        DbSelectArea("VS1")
        VS1->(dbSetOrder(1))   //Filial+Orçamento
        IF VS1->( dbSeek( xFilial("VS1") + VS3->VS3_NUMORC ) )
            IF VS1_STATUS <> 'F'
                VS3->(RecLock("VS3",.F.))
                VS3->VS3_VALPEC := _nPrcv  
                VS3->VS3_VALTOT := _nPrcv * VS3->VS3_QTDITE
                VS3->VS3_VALDES := (VS3->VS3_VALTOT * VS3->VS3_PERDES) / 100
                VS3->(MsUnlock())
            ENDIF
        ENDIF
    ENDIF

RestArea(_aArea)

Return()
