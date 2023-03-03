#INCLUDE "PROTHEUS.CH"

User Function CMVWMS01(cEmbarque,cIdUnit)

	Local cSeekZZZ  := ""
	Local aItensUni := {}
	Local aItem     := {}
	Local cLote		:= Subs(cIdUnit,01,10)
	Local cCase		:= Subs(cIdUnit,11,03)
	Local cAlias	:= GetNextAlias()
	Local aArea		:= GetArea()
	Local lPE		:= GetMV("CMV_WMS01A",,.T.)
	Local nTamPrd   := TamSX3("DCZ_PROD"  )[1]
	Local nTamLot   := TamSX3("DCZ_LOTE"  )[1]
	Local nTamSub   := TamSX3("DCZ_SUBLOT")[1]
	Local cNotas, cSerie, cFornece, cLoja


	If lPE

		// Busca o documento que faz parte da conferência

		DCX->(DbSetOrder(1))
		If DCX->(DbSeek(xFilial("DCX")+cEmbarque))
			
			cNotas	:= ""
			cSerie	:= DCX->DCX_SERIE
			cFornece:= DCX->DCX_FORNEC
			cLoja	:= DCX->DCX_LOJA
			
			While !DCX->( eof() ) .And. DCX->(DCX_FILIAL+DCX_EMBARQ) == xFilial("DCX")+cEmbarque
			
				cNotas += IIF(Empty(cNotas),"",",") + "'" + DCX->DCX_DOC + "'"

				DCX->( dbSkip() )
			
			EndDo

			cNotas := "%("+cNotas+")%"

			BeginSql Alias cAlias

				SELECT WN_PRODUTO, B1_RASTRO, SUM(WN_QUANT) WN_QUANT

				FROM %table:SWN% SWN

				INNER JOIN %table:SB5% SB5 ON SB5.%NotDel%
					AND B5_FILIAL = %xFilial:SB5%
					AND B5_COD = WN_PRODUTO
					AND B5_CTRWMS = '1'

				INNER JOIN %table:SB1% SB1 ON SB1.%NotDel%
					AND B1_FILIAL = %xFilial:SB1%
					AND B1_COD = WN_PRODUTO

				WHERE SWN.%NotDel%
					AND WN_FILIAL = %xFilial:SWN%
					AND WN_DOC IN %Exp:cNotas%
					AND WN_SERIE = %Exp:cSerie%
					AND WN_FORNECE = %Exp:cFornece%
					AND WN_LOJA = %Exp:cLoja%
					AND WN_XLOTE = %Exp:cIdUnit%
				
				GROUP BY WN_PRODUTO, B1_RASTRO

			EndSql

			While !(cAlias)->( eof() )

				aItem     := {}
				
				// Adiciona o item relacionado à etiqueta no array auxiliar
				AAdd(aItem,(cAlias)->WN_PRODUTO	,nTamPrd)
				AAdd(aItem,(cAlias)->WN_PRODUTO	,nTamPrd)
				If (cAlias)->B1_RASTRO $ "N "
					AAdd(aItem,CriaVar("DCZ_LOTE")	,nTamLot)
				Else
					AAdd(aItem,cLote				,nTamLot)
				EndIf
				AAdd(aItem,CriaVar("DCZ_SUBLOT"),nTamSub)
				AAdd(aItem,(cAlias)->WN_QUANT)
				// Adiciona o item no array principal de retorno
				AAdd(aItensUni,aItem)

				(cAlias)->( dbSkip() )
			
			EndDo

			dbSelectArea(cAlias)
			dbCloseArea()

			RestArea( aArea )

		EndIf

	EndIf

Return aItensUni