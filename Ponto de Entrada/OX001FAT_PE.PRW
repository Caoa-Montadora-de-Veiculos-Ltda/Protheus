/*/{Protheus.doc} XFASLIMCRE
Ponto de entrada antes de iniciar faturamento OX001FAT_PE
@author 	DAC-Denilso
@since 		25/03/2022
@version 	undefined
@param 		 
@type 		user function
@project    CAOA Barueri
@menu       Nao Informado
@return		Valor lógico
@ Obs		Ponto de entrada utilizado para na alteração e ou inclusão não solicitar a realização do faturamento 
            mudando de fase no processo ao qual não pode devido ao processo de aglutinação, retornando como 
            falso e fechando a janela de alteração o mesmo não será executado mas gravara os dados  conforme 
            abaixo
@history    
/*/


User Function OX001FAT
Local _lRet     := .T.
Local _nOpc

Begin Sequence
    if ALTERA .or. INCLUI 
        _nOpc := If(ALTERA,4,3)
        OX001GRV(_nOpc)
        _lRet := .F. 
        oDlgXX001:end()   //Finaliza objeto criado para tela
    Endif  
End Sequence   
oGetPecas:oBrowse:Refresh()   
Return _lRet

