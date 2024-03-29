/*/{Protheus.doc} CRM980MDef
 Ponto de Entrada - Adicionar bot�es no cadastro de clientes, bot�o *"Outras A��es"*.
 @type       Function
 @author     CAOA - DAC Denilso
 @since      10/04/2023
 @version 
 @param      
 @return     aRotina , array     , Vetor com defini��es dos bot�es - `{"character",codeBlock,"Numeric",Numeric}`
 @project	GRUPO CAOA GAP FIN108 - Revitaliza��o Credito [ Montadora ]
 @example
 @history 	04/04/2023	, DAC, Revitaliza��o Limite de Cr�dito, alterado chamada de funcionalidade ZFATF017 para ZFATF014  
 @see TDN - https://tdn.totvs.com/pages/releaseview.action?pageId=285649735
 @Obs       CRM980MDef Substitui MA030BUT
/*/

#Include "Totvs.Ch"
#INCLUDE "FWMVCDEF.CH"

User Function CRM980MDef()
Local aRotina := {}
//----------------------------------------------------------------------------------------------------------
// [n][1] - Nome da Funcionalidade
// [n][2] - Fun��o de Usu�rio
// [n][3] - Opera��o (1-Pesquisa; 2-Visualiza��o; 3-Inclus�o; 4-Altera��o; 5-Exclus�o)
// [n][4] - Acesso relacionado a rotina, se esta posi��o n�o for informada nenhum acesso ser� validado
//----------------------------------------------------------------------------------------------------------
aAdd(aRotina,{"Log de Altera��o","U_ZCRMFLLC",MODEL_OPERATION_VIEW,0})
Return( aRotina )





