#Include 'Protheus.ch'
/*/{Protheus.doc} ZCOMF041
@author     A.Carlos
@since 		21/10/2020
@param     	 
@return    	Return (cCampos)
@project    CAOA
@version 	1.0
@obs        Chamado pelo PE MTALCDOC para gravar campos na SCR 
@history    
/*/ 
User Function ZCOMF041()
Local aDoc  := PARAMIXB[1]
Local aArea   := GetArea()
Local cCompra := SC7->C7_USER  //PARAMIXB[5]
Local cNome   := Alltrim(UsrRetName( cCompra ))  //UsrFullName(RetCodUsr())   
Local cNumPed := aDoc[1]
Local cCodFil := cFilAnt

//Customizações do cliente
DbSelectArea("SCR")
dbsetorder(2) //CR_FILIAL+CR_TIPO+CR_NUM+CR_USER
dbgotop()
IF dbseek(xfilial("SCR") + "PC" + cNumPed)
    Do while xfilial("SCR") = cCodFil .AND. SCR->CR_TIPO = "PC" .AND. SCR->CR_NUM = cNumPed 
        RecLock("SCR",.F.)
        SCR->CR_XCOMPRA := cCompra
        SCR->CR_XNOMCOM := cNome 
        SCR->CR_XFORN   := SC7->C7_FORNECE
        SCR->CR_XCNPJ   := POSICIONE("SA2",1,xFilial("SA2")+SC7->C7_FORNECE,"A2_CGC")
        SCR->CR_XSOLIC  := POSICIONE("SC1",1,xFilial("SC1")+SC7->C7_NUMSC,"C1_SOLICIT")                     
        SCR->(MsUnLock())
        SCR->(dbSkip())
    EndDo
ENDIF
 
IF dbseek(xfilial("SCR") + "CP" + cNumPed)
    cCompra := __cUserId                        
    cNome   := Alltrim(UsrRetName( cCompra ))   
    Do while xfilial("SCR") = cCodFil .AND. SCR->CR_TIPO = "CP" .AND. SCR->CR_NUM = cNumPed 
        RecLock("SCR",.F.)
        SCR->CR_XCOMPRA := cCompra
        SCR->CR_XNOMCOM := cNome 
        SCR->CR_XFORN   := SC3->C3_FORNECE
        SCR->CR_XCNPJ   := POSICIONE("SA2",1,xFilial("SA2")+SC3->C3_FORNECE,"A2_CGC")
        //SCR->CR_XSOLIC  := SC3->C3_SOLICIT                     
        SCR->(MsUnLock())
        SCR->(dbSkip())
    EndDo
ENDIF
 
RestArea(aArea)
Return
