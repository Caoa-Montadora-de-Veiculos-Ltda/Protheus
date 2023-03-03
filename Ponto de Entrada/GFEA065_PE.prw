#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

User Function GFEA065()

	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oObj       := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local aArea      := GetArea()
	Local aAreaGU3   := {}
	Local _cEmp		:= FWCodEmp()

	If _cEmp == "2020" //Executa CaoaSp.
		If aParam <> NIL
			oObj     := aParam[1]
			cIdPonto := aParam[2]
			cIdModel := aParam[3]
			nOpcx := oObj:GetOperation()
			Do Case
			Case cIdPonto ==  'MODELCOMMITTTS'
				If cIdModel == "GFEA065"
					cEmit  := GW3->GW3_EMISDF
					dbSelectArea("GU3")
					aAreaGU3 := GetArea()
					dbSetOrder(1)
					If dbSeek(xFilial("GU3")+cEmit)
						cCond  := Posicione("SA2",1,xFilial("SA2")+GU3->GU3_CDERP+GU3->GU3_CDCERP,"A2_COND")
						If !Empty(cCond)
							RecLock("GW3",.F.)
							GW3->GW3_CPDGFE := cCond
							MsUnlock()
						Endif
					Endif
					RestArea(aAreaGU3)
				Endif
			Case cIdPonto == "FORMPOS"
				If nOpcx == 4

					/* Realiza validação e preenchimento automatico do custo somente se a chamada for da função
					de integração que engloba as rotinas Atualizar Fiscal ERP e Atualizar Aprop Desp ERP */
					If FWIsInCallStack("GFEA065IN") 	
						xRet := U_ZGFEF005()

						If !xRet
							Help( ,, "CaoaTec",, "Falha no preenchimento do custo via rotina ZGFEF005" , 1, 0)
						EndIf
					EndIf
				EndIf		
			EndCase
		EndIf
	EndIf

RestArea(aArea)

Return xRet
