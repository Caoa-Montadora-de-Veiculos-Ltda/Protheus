#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} ZPECF005

@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	08/10/2021
@return  	NIL
@obs        
@project
@history    Desmembrar itens do orçamento
/*/
USER Function ZPECF005()
Local nLAcol      := Len(aCols)
Local nPCod       := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})  
Local _cCod       := ALLTRIM(aCols[nLAcol,nPCod])

Local _aArea   := GetArea()

If SB1->(dbSeek(xFilial("SB1")+_cCod))

    IF !Empty(SB1->B1_XNUMINM)
        IF SB1->B1_XVLDINM < Date()
            MsgInfo( "Produto " + _cCod + " possui certificado INMETRO vencido, " + DTOC(SB1->B1_XVLDINM) + " favor validar. " , "Atenção")
            Return(.F.)
        ENDIF
    ENDIF 

ENDIF 

RestArea(_aArea)

Return(.T.)
