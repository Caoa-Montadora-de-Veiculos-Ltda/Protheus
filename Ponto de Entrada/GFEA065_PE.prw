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
	Local cTes       := ""	

	If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
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
			Case cIdPonto == "FORMCOMMITTTSPOS"
				
				If FWIsInCallStack("GFEA065IN")
					
					cTes := posicione('SD1',1,GW3->GW3_FILIAL+substr(GW3->GW3_NRDF,1,9)+SUBSTR(GW3->GW3_SERDF,1,3),"D1_TES")
					if !Empty(cTes)
						RecLock("GW3",.F.)
							GW3->GW3_TES := cTes
						GW3->(MsUnLock())
					EndIf
				EndIf

			EndCase
		EndIf
	EndIf

RestArea(aArea)

Return xRet
