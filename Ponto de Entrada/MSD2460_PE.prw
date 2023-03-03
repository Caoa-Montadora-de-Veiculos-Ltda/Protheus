#Include "Totvs.ch"
#Include "Protheus.ch"

//Ponto de Entrada criado na grava��o dos Itens da NF, para executar um execblock criado pelo usu�rio ap�s a grava��o da tabela SD2.

User Function MSD2460()
//ExecBlock("MSD2460",.F.,.F.,{cAliasSD2,lForceEst})
	
	If Findfunction("U_CMVEST04")
		U_CMVEST04()
	EndIf
	
	// Grava��o de CD9 para NFS de Imobiliza��o de Ve�culos
	If Findfunction("U_CMVVEI03")
		U_CMVVEI03()
	EndIf

Return()