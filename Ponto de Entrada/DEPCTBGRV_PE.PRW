#include "Protheus.ch"

// P.E. depois da contabilizacao 
User Function DEPCTBGRV()

   Local aArea	:= GetArea()
   local nOpc   := PARAMIXB[1]

    If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
        U_CMVSAP09(nOpc)
    ElseIf ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Franco da Rocha | Caoa
        U_ZSAPF009(nOpc)        //Criar SZ7 Integra SAP
    EndIf

   RestArea(aArea)

Return()		
