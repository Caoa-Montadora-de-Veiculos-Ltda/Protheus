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
		
	EndCase
	
	
return nil
