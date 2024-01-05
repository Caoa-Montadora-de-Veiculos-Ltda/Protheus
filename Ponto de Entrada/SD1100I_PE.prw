#Include "Totvs.ch"
#Include "Protheus.ch"

/*
=======================================================================================
Programa.:              SD1100I
Autor....:              
Data.....:              
Descricao / Objetivo:   Ponto de Entrada ap�s a Inclus�o da SD1 no Documento de Entrada
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:              Este Ponto de entrada � executado durante a inclus�o do Documento de Entrada, 
                        ap�s a inclus�o do item na tabela SD1. O registro no SD1 j� se encontra travado (Lock). 
                        Ser� executado uma vez para cada item do Documento de Entrada que est� sendo inclu�da.
=======================================================================================
*/

User Function SD1100I()
//ExecBlock("SD1100I",.F.,.F.,{lConFrete,lConImp,nOper})

If Findfunction("U_CMVEST03")
	U_CMVEST03()
EndIf

// Fun��o para validar D1_NUMSEQ duplicado. Se Encontra no Fonte SD1140I_PE.PRW
If Findfunction("U_fValiNUmSeq")
    U_fValiNUmSeq()
EndIf

Return()
