#Include "PROTHEUS.CH"
#Include "TopConn.ch"

#Define STR0077 "Or�amento Oficina Digitado"
#Define STR0078 "Or�amento Digitado"
#Define STR0079 "Or�amento Margem Pendente"
#Define STR0080 "Or�amento Avalia��o de Cr�dito"
#Define STR0081 "Or�amento Aguardando Separa��o"
#Define STR0082 "Or�amento Aguardando Lib.Diverg."
#Define STR0083 "Or�amento Aguardando Reserva"
#Define STR0093 "Or�amento Aguardando outro Or�amento"
#Define STR0084 "Or�amento Liberado p/ Faturamento"
#Define STR0085 "Or�amento Oficina Liberado p/ Exporta��o"
#Define STR0086 "Or�amento Oficina Pendente para O.S."
#Define STR0087 "Or�amento Oficina Liberado para O.S."
#Define STR0088 "Or�amento Oficina Importado para O.S."
#Define STR0089 "Or�amento Oficina Cancelado"
#Define STR0090 "Or�amento Cancelado"
#Define STR0091 "Or�amento Faturado"
#Define STR0092 "Or�amento Faturado S/ Financeiro"

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
			cCondicao := STR0077 // Or�amento Oficina Digitado
		Case cStatus == "0" .AND. cTpOrc == "1"
			cCondicao := STR0078 // Or�amento Balc�o Digitado
		Case cStatus == "2" .AND. cTpOrc == "1"
			cCondicao := STR0079 // Or�amento Balc�o Margem Pendente
		Case cStatus == "3"
			cCondicao := STR0080 // Or�amento Balc�o Avalia��o de Cr�dito
		Case cStatus == cFaseConfer
			cCondicao := STR0081 // Or�amento Balc�o Aguardando Separa��o
		Case cStatus == "5"
			cCondicao := STR0082 // Or�amento Balc�o Aguardando Lib.Diverg.
		Case cStatus $ "RT"
			cCondicao := STR0083 // Or�amento Balc�o Aguardando Reserva
		Case cStatus == "G"
			cCondicao := STR0093 // Or�amento Balc�o aguardando outro Or�amento
		Case cStatus == "F" .AND. cTpOrc == "1"
			cCondicao := STR0084 // Or�amento Balc�o Liberado p/ Faturamento
		Case cStatus == "F" .AND. cTpOrc == "2"
			cCondicao := STR0085 // Or�amento Oficina Liberado p/ Exporta��o
		Case cStatus == "P" .OR. (cStatus == "2" .AND. cTpOrc == "2")
			cCondicao := STR0086 // Or�amento Oficina Pendente para O.S.
		Case cStatus == "L"
			cCondicao := STR0087 // Or�amento Oficina Liberado para O.S.
		Case cStatus == "I"
			cCondicao := STR0088 // Or�amento Oficina Importado para O.S.
		Case cStatus == "C" .AND. VS1->VS1_TIPORC == "2"
			cCondicao := STR0089 // Or�amento Oficina Cancelado
		Case cStatus == "C" .AND. VS1->VS1_TIPORC == "1"
			cCondicao := STR0090 // Or�amento Balc�o Cancelado
		Case cStatus == "X" .AND. cGerFin <> "0"
			cCondicao := STR0091 // Or�amento Balc�o Faturado
		Case cStatus == "X" .AND. cGerFin == "0"
			cCondicao := STR0092 // Or�amento Balc�o Faturado S/ Financeiro
	EndCase

Return(cCondicao)
