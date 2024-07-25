#INCLUDE "PROTHEUS.CH"

user function GFEA0651()
Local cPrdFrete := " "

U_ZGFEF005()
cPrdFrete := GW3->GW3_PRITDF //"FR002"

Return cPrdFrete
