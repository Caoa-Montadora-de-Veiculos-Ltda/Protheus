#Include 'Protheus.ch'
/*/{Protheus.doc} MATA094
@author     A.Carlos
@since 		21/10/2020
@param     	 
@return    	Return (cCampos)
@project    CAOA
@version 	1.0
@obs        Chamado pelo PE MATA094 para mostrar campos da SC7 na tela
@history    
/*/
User Function MT094CPC()
Local cCampos := "|C7_COND|C7_COMPRA|C7_DATPRF|" //  A separação dos campos devem ser feitos com uma barra vertical ( | ), igual é demonstrado no exemplo. 

Return (cCampos)
 