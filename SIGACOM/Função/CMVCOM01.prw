#include 'protheus.ch'
#include 'parmtype.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CMVCOM01   º Autor ³ TOTVS             º Data ³  16/05/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função para Gravar a Forma de Pagamento no SE1             º±±
±±º          ³ E4_XFORMA nas Notas de Devolução                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CAOA                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User function CMVCOM01()

Local aArea    := GetArea()
Local cTipo    := SF1->F1_TIPO 
Local cDoc     := SF1->F1_DOC
Local cSerie   := SF1->F1_SERIE
Local cFornece := SF1->F1_FORNECE
Local cLoja    := SF1->F1_LOJA
Local cCodForm := " " //Forma de pagamento da Nota Original
Local cNotaOr  := " "
Local cSeriOr  := " "
Local aAreaSE1 := {}
Local aAreaSD1 := {}
Local aAreaSF2 := {}

If cTipo == "D"

	// Busca a NF Original
	dbSelectArea("SD1")
	aAreaSD1 := SD1->(GetArea())
	SD1->(dbSetOrder(1))
	If dbSeek(xFilial("SD1")+cDoc+cSerie+cFornece+cLoja)
		cNotaOr  := SD1->D1_NFORI
		cSeriOr  := SD1->D1_SERIORI
	Endif
	RestArea(aAreaSD1)
	
	dbSelectArea("SF2")
	aAreaSF2 := SF2->(GetArea())
	SF2->(dbSetOrder(1))
	If dbSeek(xFilial("SF2")+cNotaOr+cSeriOr+cFornece+cLoja)
		cCodForm := Posicione("SE4",1,xFilial("SE4")+SF2->F2_COND,"E4_XFORMA")
	Endif
	RestArea(aAreaSF2)

	If !Empty(cCodForm)
		dbSelectArea("SE1")
		aAreaSE1 := SE1->(GetArea())
		SE1->(dbSetOrder(2))
		If dbSeek(xFilial("SE1")+cFornece+cLoja+cSerie+cDoc)
			While !Eof() .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)==;
				xFilial("SE1")+cFornece+cLoja+cSerie+cDoc				
				RecLock("SE1",.F.)
				SE1->E1_XFORMA := cCodForm	
				MsUnlock()	
				SE1->(dbSkip())
			Enddo
		Endif
	
		RestArea(aAreaSE1)
	Endif			

Endif


RestArea(aArea)
	
Return()
