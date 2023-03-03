#Include 'Protheus.ch'
/*/{Protheus.doc} MATA094
@author     A.Carlos
@since 		21/10/2020
@param     	 
@return    	Return (cCampos)
@project    CAOA
@version 	1.0
@obs        Chamado pelo PE MATA094 para mostrar campos da SCR na tela
@history 
-----------------------------------------------------------------------
Rabelo -- 16/11/2022
Validação se o campo existe na SX3 por por rodar em mais de uma empresa
o campo pode exsitir somente em uma delas.
-----------------------------------------------------------------------
/*/
User Function MT094CCR()
Local cCampos := ""
Local aCamSCR :={"CR_TIPO","CR_XNOMCOM","CR_XVLLIB" }
Local nX := 1

For nX:= 1 to Len(aCamSCR) 

    If FIELDPOS(aCamSCR[nX]) > 0
        cCampos += "|" + aCamSCR[nX] 
    EndIf    

Next nX

Return (cCampos)
 