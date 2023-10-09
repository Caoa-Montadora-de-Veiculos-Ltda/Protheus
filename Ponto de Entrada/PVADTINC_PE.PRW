#include "Protheus.ch"
// P.E. na inclusao do titulo a receber de RA p/ mostrar o N. do PV gerado
User Function PVADTINC()

	Local _cEmp := FWCodEmp()

	Public aClieLoj := {}


	If _cEmp == "2010" //Executa o p.e. Anapolis.

        IF SE4->E4_CTRADT == '1'    //Adiantamento
		    M->C5_XPREFIX := 'PVF'
		ENDIF

		DbSelectArea("ZZM")
	    DbSetOrder(1)  //Filial + Documento

		if ZZM->( DbSeek(xFilial("ZZM") + M->C5_NUM) )
			RecLock("ZZM", .F.)
			ZZM->ZZM_CLIENT := M->C5_CLIENTE
			ZZM->ZZM_LOJA   := M->C5_LOJACLI
			ZZM->ZZM_NATURE := M->C5_NATUREZ
			ZZM->(MsUnLock())
		else
			RecLock("ZZM", .T.)
			ZZM->ZZM_FILIAL := cFilant
			ZZM->ZZM_NUM    := M->C5_NUM
			ZZM->ZZM_CLIENT := M->C5_CLIENTE
			ZZM->ZZM_LOJA   := M->C5_LOJACLI
			ZZM->ZZM_NATURE := M->C5_NATUREZ
			ZZM->(MsUnLock())			
		EndIf	
	
    	MSGINFO( "Anote o número do Pedido: " + M->C5_NUM  , "[PVADTINC] " + M->C5_NUM )

	EndIf

Return()
