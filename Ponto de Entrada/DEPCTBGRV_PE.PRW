#include "Protheus.ch"

// P.E. depois da contabilizacao 
User Function DEPCTBGRV()

   Local _cEmp  := FWCodEmp()
   Local aArea	:= GetArea()
   local nOpc   := PARAMIXB[1]

    If _cEmp == "2010" //Executa o p.e. Anapolis.
        U_CMVSAP09(nOpc)
    Else
        U_ZSAPF009(nOpc)        //Criar SZ7 Integra SAP
    EndIf

   RestArea(aArea)

Return()		
