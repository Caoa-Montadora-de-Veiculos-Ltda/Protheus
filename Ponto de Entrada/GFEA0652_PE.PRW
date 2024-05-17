#INCLUDE "PROTHEUS.CH"



User function GFEA0652()
Local cTes      := GW3->GW3_TES
Local cTpImp   	:= Posicione("GVT", 1, xFilial("GVT") + GW3->GW3_CDESP, "GVT_TPIMP")	
Local aForLoj   := GFEA055GFL(GW3->GW3_EMISDF)
Local cPrdFrete := GW3->GW3_PRITDF
Local cFGer     := ""
    
    If GFXCP12123("GW3_USO")
		cFGer := GFEA065FGER(GW3->GW3_NATFRE, GW3->GW3_USO)
	EndIf
    
    cTes := GFE065TES(cTes, cTpImp, GW3->GW3_TRBIMP, GW3->GW3_CRDICM, GW3->GW3_CRDPC, aForLoj, cFGer, GW3->GW3_TPCTB, cPrdFrete, GW3->GW3_CFOP)
    
    if !Empty(cTes) .and. cTes <> GW3->GW3_TES
		RecLock("GW3",.F.)
			GW3->GW3_TES := cTes
		GW3->(MsUnLock())
	EndIf

Return cTes

