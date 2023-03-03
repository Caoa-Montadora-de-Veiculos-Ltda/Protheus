#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} MT150GET
P.E. - Incluir botão na atualização de cotação
@author
@since 21/10/2020

@version 1.0
@type function
/*/
User Function MT150GET()

    Local aCols := Paramixb[1] 
    Public _NumCot := Space(6)

Return(aCols)
