#include "protheus.ch"
#include "parmtype.ch"
#include 'Fwmvcdef.CH'
/*/{Protheus.doc} MATA120
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	21/07/2021
@return  	NIL
@obs        Ponto de entrada do MATA120
@project
@history    Gatilhar a TES do CP p/ AE
*/
USER Function ZCOMF040()
Local aArea    := GetArea()  
Local y        := 0
Local _nPosTes := aScan(aHeader,{|x|upper(alltrim(x[2]))=="C7_TES"})
                   
For y := 1 to Len(aCols)
         
    //If aCols[y][Len(aHeader)+1] := .F. // não deletado
        DbSelectArea('SC3')
        DbSetOrder(1)
        IF DbSeek(xFilial('SC3') + aCols[y][19] + aCols[y][20] )  //Na DES aCols[y][14] + aCols[y][15]
            aCols[y][_nPosTes] := SC3->C3_XTES 
        ENDIF                 
    //endif

Next y

RestArea( aArea )

Return()
