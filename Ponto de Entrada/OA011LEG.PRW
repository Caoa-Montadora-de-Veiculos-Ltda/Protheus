#Include "PROTHEUS.CH"
#Include "TopConn.ch"

#Define STR0110 "Orçamento Digitado"
#Define STR0111 "Orçamento Margem Pendente"
#Define STR0112 "Orçamento Avaliação de Crédito"
#Define STR0113 "Orçamento Aguardando Separação"
#Define STR0114 "Orçamento Aguardando Lib.Diverg."
#Define STR0115 "Orçamento Liberado p/ Faturamento"
#Define STR0127 "Orçamento Aguardando outro Orçamento"
#Define STR0116 "Orçamento Faturado"
#Define STR0117 "Orçamento Faturado S/ Financeiro"
#Define STR0118 "Orçamento Cancelado"
#Define STR0119 "Orçamento Aguardando Reserva"
#Define STR0121 "Orçamento Oficina Digitado"
#Define STR0122 "Orçamento Oficina Pendente para O.S.
#Define STR0123 "Orçamento Oficina Liberado para O.S."
#Define STR0124 "Orçamento Oficina Importado para O.S."
#Define STR0125 "Orçamento Oficina Cancelado"

************************
User Function OA011LEG()
************************

Local aLegenda  As Array

aLegenda := {}
Aadd(aLegenda, {'BR_VERDE'      ,   STR0110})                                           // 01 - Orçamento Balcão Digitado
Aadd(aLegenda, {'BR_PINK'       ,   STR0111})                                           // 02 - Orçamento Balcão Margem Pendente
Aadd(aLegenda, {'BR_BRANCO'     ,   STR0112})                                           // 03 - Orçamento Balcão Avaliação de Crédito
Aadd(aLegenda, {'BR_AZUL'       ,   STR0113})                                           // 04 - Orçamento Balcão Aguardando Separação
Aadd(aLegenda, {'BR_MARROM'     ,   STR0114})                                           // 05 - Orçamento Balcão Aguardando Lib.Diverg.
Aadd(aLegenda, {'BR_AMARELO'    ,   STR0115})                                           // 06 - Orçamento Balcão Liberado p/ Faturamento
Aadd(aLegenda, {'BR_AZUL_CLARO' ,   STR0127})                                           // 07 - Orçamento Balcão aguardando outro Orçamento
Aadd(aLegenda, {'BR_PRETO'      ,   STR0116})                                           // 08 - Orçamento Balcão Faturado
Aadd(aLegenda, {'lbok_ocean'    ,   STR0117})                                           // 09 - Orçamento Balcão Faturado S/ Financeiro
Aadd(aLegenda, {'BR_VERMELHO'   ,   STR0118})                                           // 10 - Orçamento Balcão Cancelado
Aadd(aLegenda, {'BR_CINZA'      ,   STR0119})                                           // 11 - Orçamento Balcão Aguardando Reserva
Aadd(aLegenda, {''              ,   "----------------------------------------------"})  // 12
Aadd(aLegenda, {'f10_verd'      ,   STR0121})                                           // 13 - Orçamento Oficina Digitado
Aadd(aLegenda, {'f12_azul'      ,   STR0122})                                           // 14 - Orçamento Oficina Pendente para O.S.
Aadd(aLegenda, {'f5_amar'       ,   STR0123})                                           // 15 - Orçamento Oficina Liberado para O.S.
Aadd(aLegenda, {'f14_cinz'      ,   STR0124})                                           // 16 - Orçamento Oficina Importado para O.S.
Aadd(aLegenda, {'f7_verm'       ,   STR0125})                                           // 17 - Orçamento Oficina Cancelado

Return(aLegenda)
