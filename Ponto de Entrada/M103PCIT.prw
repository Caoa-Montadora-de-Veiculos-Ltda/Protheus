#Include "Totvs.ch"

//-------------------------------------------------------------------
/* {Protheus.doc} M103PCIT
	Ponto de Entrada Doc. Entrada - Manipulacao aCol apos vinculo com pedido

	@author    Cintia Araujo
	@since     23/07/2024

*/
//-------------------------------------------------------------------
User Function M103PCIT()
	Local nPosPrd     := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_COD"   })
	Local nPosTES     := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_TES"   })
	Local nPosPc      := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_PEDIDO"})
	Local nPosItPc    := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_ITEMPC"})
	Local aAreaX      := GetArea( )
	Local aAreaSB1    := SB1->( GetArea( ) )
	Local nPosBkp     := n
	Local cReadVarBkp := __ReadVar
	Local nPosX       := 0
 	 
	SB1->( dbSetOrder(1) )
 	For nPosX := 1 To Len(aCols)
		If AllTrim(aCols[nPosX, nPosPc]) == AllTrim(SC7->C7_NUM) .And. aCols[nPosX, nPosItPc] == AllTrim(SC7->C7_ITEM)
			SB1->( DbSeek(FWxFilial("SB1")+PadR(aCols[nPosX, nPosPrd], TamSx3('B1_COD') [1])) )
			n         := nPosX
			__ReadVar := PADR("D1_TES", 10)
			&("M->"+__ReadVar) :=  aCols[nPosX, nPosTES]
			&(GetSx3Cache(__ReadVar, "X3_VALID"))
			RunTrigger(2, n, Nil,, __ReadVar) 
	 	EndIf
 	Next nPosX
 
	n         := nPosBkp
	__ReadVar := cReadVarBkp

	RestArea(aAreaSB1)
	RestArea(aAreaX)

Return 
