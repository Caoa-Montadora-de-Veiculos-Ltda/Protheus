#Include "Totvs.ch"
#Include "Protheus.ch"

/*
=======================================================================================
Programa.:              SD1140I
Autor....:              TOTVS - Reinaldo Rabelo da Silva
Data.....:              07/12/23
Descricao / Objetivo:   Ponto de Entrada após a Inclusão da SD1 na Pré-Nota de Entrada
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=======================================================================================
*/

User Function SD1140I()

If Findfunction("U_fValiNUmSeq")
    U_fValiNUmSeq()
EndIf

Return nil

/*
=======================================================================================
Programa.:              fValiNUmSeq
Autor....:              TOTVS - Reinaldo Rabelo da Silva
Data.....:              07/12/23
Descricao / Objetivo:   Rotina Para prevenir a Duplicação da D1_NUMSEQ
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:              Chamado pelos Pontos de Entradas SD1140I e SD1100I
=======================================================================================
*/

User Function fValiNUmSeq()

if Type('cValNumSeq') <> "C"
    Public cValNumSeq := ""
EndIF

//Verifica se existe Numero de Sequencia Dulpicado
If SD1->D1_NUMSEQ $ cValNumSeq
    //Caso existe Duplicado pega um numero novo para o registro
    SD1->D1_NUMSEQ := ProxNum()

EndIf

cValNumSeq += SD1->D1_NUMSEQ + "|"

Return
