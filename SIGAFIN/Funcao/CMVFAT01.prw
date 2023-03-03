#include 'protheus.ch'
#include 'parmtype.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CMVFAT01   º Autor ³ TOTVS             º Data ³  16/05/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função para Gravar a Forma de Pagamento no SE1             º±±
±±º          ³ E4_XFORMA                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CAOA                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CMVFAT01()

Local aArea   := GetArea()	
Local cDoc    := SF2->F2_DOC
Local cSerie  := SF2->F2_SERIE
Local cCliente:= SF2->F2_CLIENTE
Local cLoja   := SF2->F2_LOJA
Local cTipo   := SF2->F2_TIPO
Local cCodPag := Posicione("SE4",1,xFilial("SE4")+SF2->F2_COND,"E4_XFORMA")
Local cPrefOr := SF2->F2_PREFORI
Local aAreaSE1:= {}    

If cTipo $ "NIP" .And. Empty(cPrefOr)   
	dbSelectArea("SE1")
	aAreaSE1 := GetArea()
	SE1->(DbSetOrder(2))
	If dbSeek(xFilial("SE1")+cCliente+cLoja+cSerie+cDoc)
		While !Eof() .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)==;
		 	xFilial("SE1")+cCliente+cLoja+cSerie+cDoc
		 	RecLock("SE1",.F.)
		 	SE1->E1_XFORMA := cCodPag	
		 	MsUnlock()	
			SE1->(dbskip())
		Enddo
	Endif
	RestArea(aAreaSE1)
Endif


RestArea(aArea)

Return
