#include 'protheus.ch'
#include 'parmtype.ch'

User Function PS400MNU()
	Local aOpc := {}

    aAdd(aOpc, {"Despesas", "U_DESPSIS", 4, 0})

Return aOpc

//Efetua a chamada do contas a pagar
User Function DespSis()

	Local xRet
	
	//Muda o módulo para o financeiro antes de executar, de forma a não influenciar nos controles da rotina
	nModulo := 6
	
	//Pode-se aplicar um filtro na tabela de títulos do financeiro antes de executar a função, para exibir somente despesas do processo posicionado na tabela EJW
	//Executa a rotina de Contas a Pagar
	xRet := FINA050()
	
	//Volta o módulo para o Siscoserv
	nModulo := 85

Return xRet