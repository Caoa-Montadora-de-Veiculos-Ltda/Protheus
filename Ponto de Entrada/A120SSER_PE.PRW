#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} A120SSER
Este Ponto de Entrada tem por finalidade manipular o conteúdo do Pedido de Compras que será atualizado ao Pedido de Serviços através das variáveis aCab e aItens.
https://tdn.totvs.com/display/public/PROT/TUYGXF_DT_PONTO_ENTRADA_A120SSER
@type Function

@author Joni Lima do Carmo
@since 12/09/2019
@version P12
/*/
User Function A120SSER()

	Local aArea 	:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())

	Local nPosFil := 0
	Local nPosPed := 0
	Local nPosIte := 0
	Local nPosField := 0

	Local nI      := 0

	//nPos1 := Ascan(aCab,{|x| x[1] == "EJW_EXPORT"}) //Exemplo para pegar dados do cabecalho

	dbSelectArea("SC7")
	SC7->(dbSetOrder(1))//C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	For nI := 1 to Len(aItens)

		nPosFil := Ascan(aItens[ni],{|x| x[1] == "EJX_FILIAL"})
		nPosPed := Ascan(aItens[ni],{|x| x[1] == "EJX_PROCES"})
		nPosIte := Ascan(aItens[ni],{|x| x[1] == "EJX_SEQPRC"})

		If SC7->(dbSeek(aItens[ni,nPosFil,2] + aItens[ni,nPosPed,2] + aItens[ni,nPosIte,2]))

			nPosField := Ascan(aItens[ni],{|x| x[1] == "EJX_XCONTA"})
			If nPosField == 0
				If !Empty(SC7->C7_CONTA)
					AADD(aItens[ni],{"EJX_XCONTA"		,SC7->C7_CONTA		,Nil})
				EndIf
			EndIf

			nPosField := Ascan(aItens[ni],{|x| x[1] == "EJX_XCCUST"})
			If nPosField == 0
				If !Empty(SC7->C7_CONTA)
					AADD(aItens[ni],{"EJX_XCCUST"		,SC7->C7_CC		,Nil})
				EndIf
			EndIf

			nPosField := Ascan(aItens[ni],{|x| x[1] == "EJX_XITEM"})
			If nPosField == 0
				If !Empty(SC7->C7_CONTA)
					AADD(aItens[ni],{"EJX_XITEM"		,SC7->C7_ITEMCTA		,Nil})
				Endif
			EndIf

			nPosField := Ascan(aItens[ni],{|x| x[1] == "EJX_XCLVL"})
			If nPosField == 0
				If !Empty(SC7->C7_CONTA)
					AADD(aItens[ni],{"EJX_XCLVL"		,SC7->C7_CLVL		,Nil})
				EndIf
			EndIf

		Endif
	Next nI

	RestArea(aAreaSC7)
	RestArea(aArea)

Return .T.