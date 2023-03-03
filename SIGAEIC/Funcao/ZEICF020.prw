#INCLUDE "TOTVS.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH" 
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TBICONN.CH' 
#INCLUDE "MSGRAPHI.CH"
/*/{Protheus.doc} EICPO400_MVC
@author A.Carlos
@since 18/08/2022
@version 1.0
    @return Nil, Ponto de entrada executado no browse da manutenção da PO c/ retorno da posição do item
    @return Nil, Retorno da posição do item na Grid da PO
    @example
/*/
User Function ZEICF020()
Local nLin       := 0
Local nCol       := 0
Local _cItem     := Space(23)
Local aParamBox  := {}
Private aRetPer  := {}  
Private _cPO_NUM := SW3->W3_PO_NUM
Private _cCC_PO  := SW3->W3_CC

   aAdd(aParamBox,{ 1, "Item ", _cItem, "@!", "", "SW3","", 60,.T.})

   If !ParamBox(aParamBox, " " + SW2->W2_PO_NUM, @aRetPer, , , , , , , , ,.T.)
      Return Nil
   EndIf

   Work->(dbGoTop())  

   While Work->(!EOF())

     nLin++

    IF Alltrim(aRetPer[1]) = Alltrim(Work->WKCOD_I)

        nCol := 02
          
        Return {nLin, nCol}    // Retorna a primeira ocorrência, se comentado retornará a última ocorrência.
          
    EndIF

    Work->(DbSkip())

   End

Return {nLin, nCol}
