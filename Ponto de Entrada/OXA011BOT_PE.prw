#Include "TOTVS.CH"
#Include "rwmake.ch"
#Include 'Fwmvcdef.CH'
/*/                                                             {Protheus.doc} OXA011BOT_PE
P.E. - Adiciona botões no Orçamento Fases.
@author CAOA - A.Carlos
@since 27/09/2021
@version 1.0
@type function
/*/
User Function OXA011BOT()
Local 	aRotina := ParamIXB[1]

   If FindFunction("U_ZPECR003")
	   aadd(aRotina, {"Imprimir Substituídos", "U_ZPECR003()", 0, 0})
	EndIf

   If FindFunction("U_ZPECF006")
	   aadd(aRotina, {"Desmembrar Itens"     , "U_ZPECF006()", 0, 0})
	EndIf
   //Acrescentado conforme solicitação Zé TOTVS - DAC 21/12/2021
   If FindFunction("U_ZPECF008")
	   aadd(aRotina, {"Separação Orçamentos" , "U_ZPECF008"  , 0, 0})
   EndIf

 	//aguardar verificar se sera reprocessado desta forma  DAC 21/02/2022
   	//Reprocessar envio separação para orçamentos que não gerarão picking - DAC 29/12/2021
    // temporariamente DAC 26/05/2022 - liberado conforme solicitação Fabio 12/07/2022

   	If FindFunction("U_ZWSR007R")   //função encontrada em ZWSR007
	   aAdd( aRotina, { "Repr. Picking RG envio"  , "U_ZWSR007R" , 0 , 0 } )	
	EndIf
	
   //Acrescentado conforme solicitação Zé TOTVS - DAC 26/05/2022
   If FindFunction("U_ZPF8REV1")  //ZPECF008
	   aadd(aRotina, {"Retornar Fase Inicial" , "U_ZPF8REV1"  , 0, 0})
   EndIf

Return(aRotina)
