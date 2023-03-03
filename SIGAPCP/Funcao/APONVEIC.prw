#Include "Protheus.Ch"
#Include "TOTVS.Ch"

/*/{Protheus.doc} APONVEIC
Função responsavel peloas apontamentos customizados na produção de veiculos - SIGAVEI x PCP.
@author FSW - DWC Consult
@since 02/04/2019
@version 1.0
@type function
/*/
User Function APONVEIC()
	Local cValidaSB2	:= SuperGetMV("MV_XVLDSB2",.F.,"0")  //1=Valida B2_VATU1,2=Alerta B2_VATU1
	Local cChassi		:= ""
	Local lRet 			:= ParamIxb[1]
	Local aAreaVV1		:= {}
	Local aAreaSB2		:= {}
	
	If Type("M->D3_OP")<>"U"
		If Subs( M->D3_OP , 9 , 3 ) == "001"

			If lRet 
				If Type("M->D3_XVIN")<>"U"
					If !Empty(M->D3_XVIN)
						aAreaVV1:=VV1->(GetArea())
		
						cChassi:=PadR(Subs(M->D3_XVIN,1,Len(VV1->VV1_CHASSI)),Len(VV1->VV1_CHASSI))
		
						VV1->(dbSetOrder(2))  //VV1_FILIAL+VV1_CHASSI
						VV1->(dbSeek(xFilial("VV1")+M->D3_XVIN))  //Posiciona no VV1
						If VV1->(!Eof())
							MsgAlert("Chassi "+AllTrim(M->D3_XVIN)+" já cadastrado !!","CAOA")
							lRet := .F.
						EndIf
		
						VV1->(RestArea(aAreaVV1))
					EndIf
				EndIf
			EndIf
		
			If lRet 
				If Type("M->D3_COD")<>"U" .And. Type("M->D3_LOCAL")<>"U" 
					If cValidaSB2 == "1" .Or. cValidaSB2 == "2"  //1=Valida B2_VATU1,2=Alerta B2_VATU1
						aAreaSB2 := SB2->(GetArea())
		
						SB2->(DbSetOrder(1))  //B2_FILIAL+B2_COD+B2_LOCAL
						If SB2->(dbSeek(xFilial("SB2")+M->D3_COD+M->D3_LOCAL))  //Posiciona no SB2
							If SB2->B2_VATU1 == 0 
								MsgAlert("Não é possível incluir veículo com valor unitário zero.","CAOA")
								If cValidaSB2 == "1"  //1=Valida B2_VATU1,2=Alerta B2_VATU1
									lRet := .F.
								EndIf
							EndIf
						EndIf
		
						SB2->(RestArea(aAreaSB2))
					EndIf
				EndIf
			EndIf

		EndIf
	EndIf

Return( lRet )