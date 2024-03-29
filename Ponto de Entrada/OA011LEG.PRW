#Include "PROTHEUS.CH"
#Include "TopConn.ch"

#Define STR0110 "Or�amento Digitado"
#Define STR0111 "Or�amento Margem Pendente"
#Define STR0112 "Or�amento Avalia��o de Cr�dito"
#Define STR0113 "Or�amento Aguardando Separa��o"
#Define STR0114 "Or�amento Aguardando Lib.Diverg."
#Define STR0115 "Or�amento Liberado p/ Faturamento"
#Define STR0127 "Or�amento Aguardando outro Or�amento"
#Define STR0116 "Or�amento Faturado"
#Define STR0117 "Or�amento Faturado S/ Financeiro"
#Define STR0118 "Or�amento Cancelado"
#Define STR0119 "Or�amento Aguardando Reserva"
#Define STR0121 "Or�amento Oficina Digitado"
#Define STR0122 "Or�amento Oficina Pendente para O.S.
#Define STR0123 "Or�amento Oficina Liberado para O.S."
#Define STR0124 "Or�amento Oficina Importado para O.S."
#Define STR0125 "r�amento Oficina Cancelado"

************************
User Function OA011LEG()
************************

Local aLegenda  As Array

aLegenda := {}
Aadd(aLegenda, {'BR_VERDE'      ,   STR0110})                                           // 01 - Or�amento Balc�o Digitado
Aadd(aLegenda, {'BR_PINK'       ,   STR0111})                                           // 02 - Or�amento Balc�o Margem Pendente
Aadd(aLegenda, {'BR_BRANCO'     ,   STR0112})                                           // 03 - Or�amento Balc�o Avalia��o de Cr�dito
Aadd(aLegenda, {'BR_AZUL'       ,   STR0113})                                           // 04 - Or�amento Balc�o Aguardando Separa��o
Aadd(aLegenda, {'BR_MARROM'     ,   STR0114})                                           // 05 - Or�amento Balc�o Aguardando Lib.Diverg.
Aadd(aLegenda, {'BR_AMARELO'    ,   STR0115})                                           // 06 - Or�amento Balc�o Liberado p/ Faturamento
Aadd(aLegenda, {'BR_AZUL_CLARO' ,   STR0127})                                           // 07 - Or�amento Balc�o aguardando outro Or�amento
Aadd(aLegenda, {'BR_PRETO'      ,   STR0116})                                           // 08 - Or�amento Balc�o Faturado
Aadd(aLegenda, {'lbok_ocean'    ,   STR0117})                                           // 09 - Or�amento Balc�o Faturado S/ Financeiro
Aadd(aLegenda, {'BR_VERMELHO'   ,   STR0118})                                           // 10 - Or�amento Balc�o Cancelado
Aadd(aLegenda, {'BR_CINZA'      ,   STR0119})                                           // 11 - Or�amento Balc�o Aguardando Reserva
Aadd(aLegenda, {''              ,   "----------------------------------------------"})  // 12
Aadd(aLegenda, {'f10_verd'      ,   STR0121})                                           // 13 - Or�amento Oficina Digitado
Aadd(aLegenda, {'f12_azul'      ,   STR0122})                                           // 14 - Or�amento Oficina Pendente para O.S.
Aadd(aLegenda, {'f5_amar'       ,   STR0123})                                           // 15 - Or�amento Oficina Liberado para O.S.
Aadd(aLegenda, {'f14_cinz'      ,   STR0124})                                           // 16 - Or�amento Oficina Importado para O.S.
Aadd(aLegenda, {'f7_verm'       ,   STR0125})                                           // 17 - Or�amento Oficina Cancelado

Return(aLegenda)
