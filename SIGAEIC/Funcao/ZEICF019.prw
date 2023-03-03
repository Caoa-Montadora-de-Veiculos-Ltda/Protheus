#INCLUDE "TOTVS.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH" 
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TBICONN.CH' 
#INCLUDE "MSGRAPHI.CH"
/*/{Protheus.doc} EICSI400
@author A.Carlos
@since 18/08/2022
@version 1.0
    @return Nil, Ponto de entrada executado no browse da manutenção da SI c/ retorno da posição do item
    @return Nil, Retorno da posição do item na Grid da SI
    @example
/*/
User Function ZEICF019()
Local nLin       := 0
Local nCol       := 0
Local _cItem     := Space(23)
Local aParamBox  := {}
Private aRetPer  := {}
Private _cSI_NUM := SW1->W1_SI_NUM
Private _cCC     := SW1->W1_CC

   aAdd(aParamBox,{ 1, "Item ", _cItem, "@!", "", "SW1A","", 60,.T.})

   If !ParamBox(aParamBox, " " + SW1->W1_SI_NUM, @aRetPer, , , , , , , , ,.T.)
      Return Nil
   EndIf

   TRB->(dbGoTop())    
    
   While TRB->(!EOF())

      nLin++

      IF Alltrim(aRetPer[1]) = Alltrim(TRB->W1_COD_I)

         nCol := 02
          
         Return {nLin, nCol}    //Retorna a primeira ocorrência, se comentado retornará a última ocorrência.
          
      EndIF

      TRB->(DbSkip())

   End

// Se não encontrou retorna {0, 0}
Return {nLin, nCol}
