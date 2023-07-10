#INCLUDE "TOTVS.CH"
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} MA140BUT_PE
P.E. - Adiciona botões no Pre-Nota                
@author CAOA - A.Carlos
@since 19/04/2023
@version 1.0
@type function
/*/
USER FUNCTION MA140BUT()
LOCAL aBotao := {}

u_ZGENLOG( ProcName() ) //Grava log de execução de fontes     

IF FWCodEmp() <> '2020' .AND. FWFilial() <> '2020012001'

     If FindFunction("U_ZCOMF051") .AND. INCLUI
          Aadd(aBotao, {'', {|| FWMsgRun(, {|| U_ZCOMF051() }, "", "Importar Itens..." ) }, 'Importar Itens'})
     Endif

ENDIF

RETURN(aBotao)
