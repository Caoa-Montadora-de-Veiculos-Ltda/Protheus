
#include "protheus.ch"
#include "parmtype.ch"

User Function CRMA980()

   Local _cEmp    := FWCodEmp()
   Local _lRet	   := .T.
   Local aArea	   := GetArea()

   If _cEmp == "2010" //Executa o p.e. Anapolis.
      _lRet := zMontadora()
   Else
      _lRet := zCaoaSp() //Executa o p.e. CaoaSp
   EndIf

   RestArea(aArea)

Return(_lRet)

/*
==============================================================================================
Programa.:              zMontadora
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada Montadora
===============================================================================================
*/
Static Function zMontadora()

    Local aParam := PARAMIXB
    Local xRet := .T.
    Local oObj := ""
    Local cIdPonto := ""
    Local cIdModel := ""

    If (aParam <> NIL)
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]

        nOpc := oObj:GetOperation() // PEGA A OPERAÇÃO

        If (cIdPonto =="MODELCOMMITNTTS")
            IF FWCodEmp() = '2020' .AND. FWFilial() = '2001'
                If nOpcx == 3  .or.  nOpcx == 4   .or.  nOpcx == 5   //Inclusão ou Alteração ou Excluir
			        _xTipo  := "C"           //Clientes
                    cCodCad := M->A1_COD     //Código
		            U_WSR006(_xTipo,cCodCad)
                EndIf
		    Else
                If nOpc == 3            
                    U_ZF10GENSAP("SA1",SA1->A1_COD+SA1->A1_LOJA,"A1_XCDSAP",3)
                Elseif nOpc == 4
                    U_ZF10GENSAP("SA1",SA1->A1_COD+SA1->A1_LOJA,"A1_XCDSAP",4)
                EndIf
            EndIf
        EndIf
    EndIf

Return(xRet)


/*
==============================================================================================
Programa.:              zCaoaSp
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada CaoaSp
===============================================================================================
*/
Static Function zCaoaSp()

    Local aParam    := PARAMIXB
    Local xRet      := .T.
    Local oObj      := ""
    Local cIdPonto  := ""
    Local cIdModel  := ""

    Private nOpcx             //opção da manutenção do cadastro (I,A,E)

    If (aParam <> NIL)
        oObj           := aParam[1]
        cIdPonto       := aParam[2]
        cIdModel       := aParam[3]

        nOpcx          := oObj:GetOperation() // PEGA A OPERAÇÃO

        If (cIDPonto == 'MODELVLDACTIVE')
            IF FWCodEmp() = '2020' .AND. FWFilial() = '2001'
                MsgRun("Atualizando Limite de Crédito Caoa","Aguarde...",{|| u_ZFATF017() })
            EndIf
        ElseIf (cIdPonto =="MODELCOMMITNTTS")
            IF FWCodEmp() = '2020' .AND. FWFilial() = '2001'
                If nOpcx == 3 .or. nOpcx == 4 .or. nOpcx == 5 //Inclusão ou Alteração ou Excluir
			        U_ZWSR006("C"    ,M->A1_COD  ,M->A1_LOJA )
                    U_ZF10GENSAP("SA1",SA1->A1_COD+SA1->A1_LOJA,"A1_XCDSAP",nOpcx)
                EndIf
                If FWCodEmp() = '2020' .AND. FWFilial() = '2001' 
                    If nOpcx == 3 .or. nOpcx == 4
                        MsgRun("Atualizando Limite de Crédito Caoa","Aguarde...",{|| u_ZFATF017() })
                    EndIf
                EndIf
		    EndIf
        EndIf

    EndIf

Return(xRet)
