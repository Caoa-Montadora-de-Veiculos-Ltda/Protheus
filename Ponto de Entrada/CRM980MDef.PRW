/*/{Protheus.doc} CRM980MDef
 Ponto de Entrada - Adicionar botões no cadastro de clientes, botão *"Outras Ações"*.
 @type       Function
 @author     CAOA - DAC Denilso
 @since      10/04/2023
 @version 
 @param      
 @return     aRotina , array     , Vetor com definições dos botões - `{"character",codeBlock,"Numeric",Numeric}`
 @project	GRUPO CAOA GAP FIN108 - Revitalização Credito [ Montadora ]
 @example
 @history 	04/04/2023	, DAC, Revitalização Limite de Crédito, alterado chamada de funcionalidade ZFATF017 para ZFATF014  
 @see TDN - https://tdn.totvs.com/pages/releaseview.action?pageId=285649735
 @Obs       CRM980MDef Substitui MA030BUT
/*/

#Include "Totvs.Ch"
#INCLUDE "FWMVCDEF.CH"

User Function CRM980MDef()
Local aRotina := {}
//----------------------------------------------------------------------------------------------------------
// [n][1] - Nome da Funcionalidade
// [n][2] - Função de Usuário
// [n][3] - Operação (1-Pesquisa; 2-Visualização; 3-Inclusão; 4-Alteração; 5-Exclusão)
// [n][4] - Acesso relacionado a rotina, se esta posição não for informada nenhum acesso será validado
//----------------------------------------------------------------------------------------------------------
aAdd(aRotina,{"Log de Alteração","U_ZCRMFLLC",MODEL_OPERATION_VIEW,0})
Return( aRotina )





