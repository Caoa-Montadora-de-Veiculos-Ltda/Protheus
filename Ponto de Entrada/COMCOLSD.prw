#Include "Totvs.ch"

//-------------------------------------------------------------------
/* {Protheus.doc} COMCOLSD
	Ponto de Entrada Monitor Totvs Colaboração. Após gravar SDS e SDT.

	@author    Cintia Araujo
	@since     23/07/2024

*/
//-------------------------------------------------------------------
User Function COMCOLSD()
	//Local _aCols   := ParamIXB[1]
	//Local _aHeader := ParamIXB[2]
	Local aAreaX   := GetArea( ) 
	Local aAreaSB1 := SB1->( GetArea( ) )
	Local aAreaSF4 := Sf4->( GetArea( ) ) 
	   
	SB1->(dBSetOrder(1)) 
	SF4->(dBSetOrder(1))
	SDT->(dBSetOrder(1))
	If SDT->(MsSeek(xFilial("SDT")+SDS->DS_CNPJ+SDS->DS_FORNEC+SDS->DS_LOJA+SDS->DS_DOC+SDS->DS_SERIE))
		Do While (SDS->DS_CNPJ == SDT->DT_CNPJ) .And. (SDS->DS_FORNEC == SDT->DT_FORNEC) .And. ;
				 (SDS->DS_LOJA == SDT->DT_LOJA) .And. (SDS->DS_DOC == SDT->DT_DOC)
			If !Empty(SDT->DT_TES) .And. Len(AllTrim(SDT->DT_CLASFIS)) < 3
				SB1->( MsSeek(xFilial("SB1")+SDT->DT_COD) )
				SF4->( MsSeek(xFilial("SF4")+SDT->DT_TES) )

				RecLock("SDT",.F.)
				SDT->DT_CLASFIS := SubStr(SB1->B1_ORIGEM,1,1)+SF4->F4_SITTRIB
				MsUnLock()
			EndIF
			SDT->( DbSkip() )
		EndDo
	EndIf

 	RestArea(aAreaSF4)
 	RestArea(aAreaSB1)
	RestArea(aAreaX)
 
Return
