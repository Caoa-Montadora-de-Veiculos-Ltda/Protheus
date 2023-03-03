#Include "TOTVS.CH"
#Include "Protheus.CH"
#Include "topconn.CH"

// #DEFINE VW_SEC_HEAD   1
#DEFINE VW_SEC_MIDDLE 1 //2
#DEFINE VW_SEC_FOOTER 2 //3

/*/{Protheus.doc} CONSCLI
	Função de Consulta de Cliente - CAOA
	@type 		function
	@author 	TOTVS - FSW - DWC Consult
	@since 		24/02/2019
	@version 	1.0
	// @param 		param_name, param_type	, param_description
	@return 	NIL			, Nulo *(nenhum)*
	@history 	22/08/2020	, denis.galvani, Inclusão/padronização de documentação de cabeçalho
/*/
User Function CONSCLI()

   Local _cEmp    := FWCodEmp()
   
   If _cEmp == "2010" //Executa o p.e. Anapolis.
     u_ZFINF001()
   Else
     u_ZFINF002()
   EndIf

Return()
