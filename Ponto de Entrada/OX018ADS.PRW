#Include "PROTHEUS.CH"
#Include "TopConn.ch"

#Define STR0077 "Orçamento Oficina Digitado"
#Define STR0078 "Orçamento Digitado"
#Define STR0079 "Orçamento Margem Pendente"
#Define STR0080 "Orçamento Avaliação de Crédito"
#Define STR0081 "Orçamento Aguardando Separação"
#Define STR0082 "Orçamento Aguardando Lib.Diverg."
#Define STR0083 "Orçamento Aguardando Reserva"
#Define STR0093 "Orçamento Aguardando outro Orçamento"
#Define STR0084 "Orçamento Liberado p/ Faturamento"
#Define STR0085 "Orçamento Oficina Liberado p/ Exportação"
#Define STR0086 "Orçamento Oficina Pendente para O.S."
#Define STR0087 "Orçamento Oficina Liberado para O.S."
#Define STR0088 "Orçamento Oficina Importado para O.S."
#Define STR0089 "Orçamento Oficina Cancelado"
#Define STR0090 "Orçamento Cancelado"
#Define STR0091 "Orçamento Faturado"
#Define STR0092 "Orçamento Faturado S/ Financeiro"

************************
User Function OX018ADS()
************************

Local cFaseConfer   As Character
Local cStatus       As Character
Local cTpOrc        As Character
Local cGerFin       As Character
Local cCondicao		As Character

cCondicao   := " "
cFaseConfer := Alltrim(GetNewPar("MV_MIL0095", "4"))
cStatus     := ParamIxb[01]
cTpOrc      := ParamIxb[02]
cGerFin     := ParamIxb[03]
cCondicao	:= ParamIxb[04]

Default cGerFin := " "

	Do Case
		Case cStatus == "0" .AND. cTpOrc == "2"
			cCondicao := STR0077 // Orçamento Oficina Digitado
		Case cStatus == "0" .AND. cTpOrc == "1"
			cCondicao := STR0078 // Orçamento Balcão Digitado
		Case cStatus == "2" .AND. cTpOrc == "1"
			cCondicao := STR0079 // Orçamento Balcão Margem Pendente
		Case cStatus == "3"
			cCondicao := STR0080 // Orçamento Balcão Avaliação de Crédito
		Case cStatus == cFaseConfer
			cCondicao := STR0081 // Orçamento Balcão Aguardando Separação
		Case cStatus == "5"
			cCondicao := STR0082 // Orçamento Balcão Aguardando Lib.Diverg.
		Case cStatus $ "RT"
			cCondicao := STR0083 // Orçamento Balcão Aguardando Reserva
		Case cStatus == "G"
			cCondicao := STR0093 // Orçamento Balcão aguardando outro Orçamento
		Case cStatus == "F" .AND. cTpOrc == "1"
			cCondicao := STR0084 // Orçamento Balcão Liberado p/ Faturamento
		Case cStatus == "F" .AND. cTpOrc == "2"
			cCondicao := STR0085 // Orçamento Oficina Liberado p/ Exportação
		Case cStatus == "P" .OR. (cStatus == "2" .AND. cTpOrc == "2")
			cCondicao := STR0086 // Orçamento Oficina Pendente para O.S.
		Case cStatus == "L"
			cCondicao := STR0087 // Orçamento Oficina Liberado para O.S.
		Case cStatus == "I"
			cCondicao := STR0088 // Orçamento Oficina Importado para O.S.
		Case cStatus == "C" .AND. VS1->VS1_TIPORC == "2"
			cCondicao := STR0089 // Orçamento Oficina Cancelado
		Case cStatus == "C" .AND. VS1->VS1_TIPORC == "1"
			cCondicao := STR0090 // Orçamento Balcão Cancelado
		Case cStatus == "X" .AND. cGerFin <> "0"
			cCondicao := STR0091 // Orçamento Balcão Faturado
		Case cStatus == "X" .AND. cGerFin == "0"
			cCondicao := STR0092 // Orçamento Balcão Faturado S/ Financeiro
	EndCase

Return(cCondicao)
