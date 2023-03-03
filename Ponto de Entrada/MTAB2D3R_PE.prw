#Include "Totvs.ch"
#Include "Protheus.ch"

//LOCALIZAÇÃO : Localizado na função B2AtuComD3 - Atualiza os dados do SB2  baseado no SD3 (movimentação).
//EM QUE PONTO: O ponto de entrada MTAB2D3R é executado no final da função B2AtuComD3, APÓS todas as gravações e pode ser utilizado para complementar a gravação no arq. de Saldos (SB2) ou outras atualizações de arquivos e campos do usuário.

User Function MTAB2D3R()
//ExecBlock("MTAB2D3R",.F.,.F.,{SD3->D3_COD, SD3->D3_LOCAL, nMultiplic})

If Findfunction("U_CMVEST01")
	U_CMVEST01()
EndIf

Return()