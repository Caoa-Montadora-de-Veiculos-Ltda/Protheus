#Include "Totvs.ch"
#Include "Protheus.ch"

//LOCALIZA��O : Localizado na fun��o B2AtuComD3 - Atualiza os dados do SB2  baseado no SD3 (movimenta��o).
//EM QUE PONTO: O ponto de entrada MTAB2D3R � executado no final da fun��o B2AtuComD3, AP�S todas as grava��es e pode ser utilizado para complementar a grava��o no arq. de Saldos (SB2) ou outras atualiza��es de arquivos e campos do usu�rio.

User Function MTAB2D3R()
//ExecBlock("MTAB2D3R",.F.,.F.,{SD3->D3_COD, SD3->D3_LOCAL, nMultiplic})

If Findfunction("U_CMVEST01")
	U_CMVEST01()
EndIf

Return()