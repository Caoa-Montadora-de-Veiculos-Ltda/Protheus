
/* =====================================================================================
Programa.:              EICEI100
Autor....:              CAOA - Valter Carvalho
Data.....:              23/06/2021
Descricao / Objetivo:   Ponto de entrada executado na tela Int.despachante do modulo EIC
Doc. Origem:
Solicitante:            CAOA -  - Anápolis
Uso......:              
===================================================================================== */

User Function EICEI100()
   Local cParamIXB := Iif(ValType(ParamIXB) == "A", cParamIXB:= ParamIXB[1], cParamIXB:= ParamIXB)
       
   If cParamIXB = "ADICIONA_ACOES"
      If findfunction("U_ZEICF010")
         U_ZEICF010()
      Endif
   EndIf

Return
