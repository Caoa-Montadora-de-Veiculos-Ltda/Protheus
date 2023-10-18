#include "Protheus.ch"
#include "TOTVS.CH"
#include "RWMAKE.CH"
#include "TOPCONN.CH"
// P.E. na inclusao do titulo a receber de RA p/ mostrar o N. do PV gerado
User Function PVADTINC()

	Local _cEmp := FWCodEmp()

	Public aClieLoj := {}
	Public _nPVF    := ''
	Public _cTpPVF  := ''

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

		IF M->C5_XPREFIX == 'PVF' .AND. INCLUI

		    _cTpPVF  := 'PVF'
	        _nPVF    := M->C5_NUM
    	    //MSGINFO( "Anote o número do Pedido: " + M->C5_NUM  , "[PVADTINC] " + M->C5_NUM )

		ENDIF

	EndIf

Return()


User Function PVAD01()
Local _cEmp   := FWCodEmp()
Local _cCampo := 'E1_NUM'
Local _lRet   := .T.

If _cEmp == "2010" .AND. M->C5_XPREFIX == 'PVF' .AND. FWIsInCallStack("MATA410") .AND. INCLUI   //Executa o p.e. Anapolis.

    IF Type("_nPVF") == 'C' .AND. !Empty(_nPVF) .AND. Empty(M->E1_NUM) 
	 
		M->E1_NUM := _nPVF

    ENDIF

ENDIF

IF ExistTrigger(_cCampo) .AND. Empty(M->E1_TIPO)
	__READVAR := _cCampo
	//&("M->"+__READVAR)   := _nPVF
	//&(GetSx3Cache(__READVAR,"X3_VALID"))
	RunTrigger(2, nil, nil,,__READVAR)
	_lLiga := .F.
ENDIF

Return(_lRet)



User Function PVAD02()
Local _cEmp := FWCodEmp()
Local _lRet := .T.

If _cEmp == "2010" .AND. M->C5_XPREFIX == 'PVF' .AND. FWIsInCallStack("MATA410")  //Executa o p.e. Anapolis.

    IF Type("_cTpPVF") == 'C' .AND. !Empty(_cTpPVF) .AND. Empty(M->E1_PREFIXO) 
	 
		M->E1_PREFIXO := _cTpPVF

    ENDIF

ENDIF

Return(_lRet)
