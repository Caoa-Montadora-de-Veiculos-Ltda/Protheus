#Include 'Protheus.ch'
#Include "TOTVS.CH"

/*
{Protheus.doc} MS520VLD
Validar ou não a exclusão da nota:.

@author  Sandro Gonçalves Ferreira
@version 1.0
@since   07/06/2022
@return  Nil  Sem retorno.
@sample
         MS520VLD()

Campos que serão comparados:
--------------------------------
F2_EMISSAO = DATA DE EMISSAO
F2_HORA    = HORA DE EMISSAO
--------------------------------
F2_DAUTNFE = DATA DA AUTORIZAÇÃO
F2_HAUTNFE = HORA DA AUTORIZAÇÃO
--------------------------------
CMV_FAT007 = Parametro se indica se processa a rotina ou não .T. = Valida a Exclusão ou .F. = Não Valida a Exclusão

*/

User Function MS520VLD()
Local cProcessa  := GetMV("CMV_FAT007",,.T.)
Local cRet       := .F.
Local dDtLim     := DaySum(SF2->F2_DAUTNFE, 1)
Local hHrAtu     := Time()
Local dDtAtu     := Date()

If cProcessa

   //   Se ainda não foi transmitida, pode cancelar
   if EMPTY(SF2->F2_DAUTNFE)  
        cRet := .T.
   endif
   
   //   No mesmo dia pode cancelar, nem precisa ver o horário
   if ( SF2->F2_DAUTNFE =  dDtAtu .and. SF2->F2_DAUTNFE <= dDtLim )  
        cRet := .T.
   endif

   // No dia Seguinte pode cancelar até o horário permitido
   if (  SF2->F2_DAUTNFE <= dDtLim .and. dDtLim >= dDtAtu ) .and. (  hHrAtu  <= SF2->F2_HAUTNFE )
        cRet := .T.
   endif

   If !cRet
      Aviso("Atenção","Documento passa do Prazo de 24 Horas da autorização, não é permitido seguir com o cancelamento!",{"Ok"})
   Endif

Endif
 
Return cRet
