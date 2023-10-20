#Include 'Protheus.ch'
#Include "TOTVS.CH"

/*
{Protheus.doc} VX001CNF
Validar ou não a exclusão da nota:.

@author  Sandro Gonçalves Ferreira
@version 1.0
@since   07/06/2022
@return  Nil  Sem retorno.
@sample
VX001CNF()

Campos que serão comparados:
--------------------------------
F2_EMISSAO = DATA DE EMISSAO
F2_HORA    = HORA DE EMISSAO
--------------------------------
F2_DAUTNFE = DATA DA AUTORIZAÇÃO
F2_HAUTNFE = HORA DA AUTORIZAÇÃO
--------------------------------
CMV_FAT008 = Parametro se indica se processa a rotina ou não .T. = Valida a Exclusão ou .F. = Não Valida a Exclusão

*/

User Function VX001CNF()
Local cProcessa  := GetMV("CMV_FAT008",,.T.)
Local cRet       := .F.
Local dDtLim     := (GetMV("MV_SPEDEXC",,.T.)/24)//DaySum(SF2->F2_DAUTNFE, 1)'
Local hHrAtu     := Time()
Local dDtAtu     := Date()

If cProcessa

   //   Se ainda não foi transmitida(ou não autorizada), pode cancelar
   if SF2->F2_FIMP $ 'N' .Or. EMPTY(SF2->F2_DAUTNFE)  
        cRet := .T.
        dDtLim := (dDtLim+dDtAtu)
   else
        dDtLim := (dDtLim+SF2->F2_DAUTNFE)
   endif
   
   //   Até dia anterior do prazo pode cancelar sem precisar ver o horário
   if ( dDtAtu < dDtLim  .and. SF2->F2_DAUTNFE < dDtLim )  
        cRet := .T.
   endif

   // No dia do prazo pode cancelar até o horário permitido
   if ( dDtLim = dDtAtu ) .and. (  hHrAtu  <= SF2->F2_HAUTNFE )
         cRet := .T.
   endif

   If !cRet
      Aviso("Atenção","Documento passa do Prazo de 24 Horas da autorização, não é permitido seguir com o cancelamento!",{"Ok"})
   Endif

Endif
 
Return cRet
