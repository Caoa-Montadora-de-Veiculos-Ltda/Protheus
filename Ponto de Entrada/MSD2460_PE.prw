#Include "Totvs.ch"
#Include "Protheus.ch"

//Ponto de Entrada criado na gravação dos Itens da NF, para executar um execblock criado pelo usuário após a gravação da tabela SD2.

User Function MSD2460()
//ExecBlock("MSD2460",.F.,.F.,{cAliasSD2,lForceEst})
	
	If Findfunction("U_CMVEST04")
		U_CMVEST04()
	EndIf
	
	// Gravação de CD9 para NFS de Imobilização de Veículos
	If Findfunction("U_CMVVEI03")
		U_CMVVEI03()
	EndIf

Return()