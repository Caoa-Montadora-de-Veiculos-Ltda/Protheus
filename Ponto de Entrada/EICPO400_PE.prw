#include 'protheus.ch'
#include 'parmtype.ch'

user function EICPO400 ()

	Do Case 

		CASE ParamIXB == Upper("GRV_WORK_COM_SW1")
			RecLock("WORK",.F.)
			WORK->W3_CORINT := SW1->W1_CORINT
			WORK->W3_COREXT := SW1->W1_COREXT
			WORK->W3_OPCION := SW1->W1_OPCION
			WORK->W3_ANOFAB := SW1->W1_ANOFAB
			WORK->W3_ANOMOD := SW1->W1_ANOMOD
			WORK->(MsUnLock())

		Case ParamIXB == "DEPOIS_GRAVA_INC_PO" 
			If lDepoisGrvIncPO

				If findfunction("u_ZEICF014") 
					u_ZEICF014()
				Endif

				U_xGRVP400()
			Else 
				MsgInfo("Operação de gravação cancelada!") 
			Endif

		Case ParamIXB == "DEPOIS_ALTERA_INC_PO" 
			If findfunction("u_ZEICF014") 
				u_ZEICF014()
			Endif

        /*Case ParamIXB == "PO_PesqSI_Sel"
			For i:=1 to Len(oPanel:OWND:aControls)
				xBtn := oPanel:OWND:aControls[i]
				If AllTrim(xBtn:cTitle) == "Busca Item"
					xBtn:lActive := .F.
					i := Len(oPanel:OWND:aControls)+1
				Endif
			Next*/

	    Case Paramixb == "BROWSE_VISUALIZAR" 

			IF ALTERA = .T. .OR. nOpcaux = 2 
				SetKey (VK_F4,{||U_ZEICF020()})
				//SetKey (VK_F4,{||})
			ENDIF

		Case ParamIXB == "ALTERAR" 

		    SetKey (VK_F4,{||U_ZEICF020()})
			//SetKey (VK_F4,{||})

		Case Paramixb == "ANTES_ELIMINA" 
 			 
			 SetKey (VK_F4,{||U_ZEICF020()})

		Case Paramixb == "VAL_GRAVA_PO"
			
			If EMPTY(SW0->W0_XCLAIMP) .OR. EMPTY(SW0->W0_TIPIMP)
				lGravaPO := fTela()
				//lGravaPO := .F.
			Else
				lGravaPO := .T.
				M->W2_XTIPIMP:= SW0->W0_TIPIMP
				M->W2_XCLAIMP := SW0->W0_XCLAIMP
			
			EndIf
			
			
	EndCase
	
	
return nil



Static Function fTela()

Local aArea := GetArea()
Local aParamBox := {}
Local aMvPar	:= {}
Local cZZ8   := Space(15)
Local cTipo  := ""
Local cTexto := "Tipo de Importação não foi salvo corretamente, selecione o Tipo de Importação:"
Local lRet   := .T.
Local lOk    := .T.
Local nMv    := 0
DbSelectArea('ZZ8')
ZZ8->(DbSetOrder(1))

aAdd(aParamBox,{9,cTexto,200,14,.T.})
//aAdd(aParamBox,{9,Space(10),200,14,.T.})
aAdd(aParamBox,{1,"Tipo de Importação",cZZ8,"","","ZZ8","",0,.T.}) 

For nMv := 1 To 40
    aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
Next nMv

While lOk
	
	If ParamBox(aParamBox, "Atenção")
		lOk := !(ZZ8->(DbSeek(xFilial('ZZ8') + MV_PAR02 )))
		cZZ8  := MV_PAR02
		cTipo := ZZ8->ZZ8_TIPO
		lRet := .T.
		If lOk 
			MSGALERT( "Tipo de Importação não encontrado, verifique!", "Atenção" )
		EndIf 
	Else
		lRet := .F.
		lOk := .F.
	EndIf

EndDo

If lRet 
	M->W2_XTIPIMP:= cZZ8
	M->W2_XCLAIMP := cTipo
	
	RECLOCK( 'SW0', .F. )
		SW0->W0_TIPIMP  := M->W2_XTIPIMP
	 	SW0->W0_XCLAIMP := M->W2_XCLAIMP
	SW0->(MsUnlock())
EndIf

For nMv := 1 To Len( aMvPar )
    &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
Next nMv

RestArea(aArea)

Return lRet
