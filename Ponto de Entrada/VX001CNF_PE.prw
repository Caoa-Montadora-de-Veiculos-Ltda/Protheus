#Include 'Protheus.ch'
#Include "TOTVS.CH"

/*
{Protheus.doc} VX001CNF
Validar ou n�o a exclus�o da nota:.

@author  Sandro Gon�alves Ferreira
@version 1.0
@since   07/06/2022
@return  Nil  Sem retorno.
@sample
VX001CNF()

Campos que ser�o comparados:
--------------------------------
F2_EMISSAO = DATA DE EMISSAO
F2_HORA    = HORA DE EMISSAO
--------------------------------
F2_DAUTNFE = DATA DA AUTORIZA��O
F2_HAUTNFE = HORA DA AUTORIZA��O
--------------------------------
CMV_FAT008 = Parametro se indica se processa a rotina ou n�o .T. = Valida a Exclus�o ou .F. = N�o Valida a Exclus�o

*/

User Function VX001CNF()
Local cProcessa  := GetMV("CMV_FAT008",,.T.)
Local cRet       := .F.
Local dDtLim     := (GetMV("MV_SPEDEXC",,.T.)/24)//DaySum(SF2->F2_DAUTNFE, 1)'
Local hHrAtu     := Time()
Local dDtAtu     := Date()

If cProcessa

   //   Se ainda n�o foi transmitida(ou n�o autorizada), pode cancelar
   if SF2->F2_FIMP $ 'N' .Or. EMPTY(SF2->F2_DAUTNFE)  
        cRet := .T.
        dDtLim := (dDtLim+dDtAtu)
   else
        dDtLim := (dDtLim+SF2->F2_DAUTNFE)
   endif
   
   //   At� dia anterior do prazo pode cancelar sem precisar ver o hor�rio
   if ( dDtAtu < dDtLim  .and. SF2->F2_DAUTNFE < dDtLim )  
        cRet := .T.
   endif

   // No dia do prazo pode cancelar at� o hor�rio permitido
   if ( dDtLim = dDtAtu ) .and. (  hHrAtu  <= SF2->F2_HAUTNFE )
         cRet := .T.
   endif

   If !cRet
      Aviso("Aten��o","Documento passa do Prazo de 24 Horas da autoriza��o, n�o � permitido seguir com o cancelamento!",{"Ok"})
   Endif

Endif
 
Return cRet
