#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
* Programa..............: mt460fim
* Author................: Edson Deluca
* Data..................: 08/11/2018
* Descrição / Objetivo..: Ponto de entrada atualizar as tabelas Floor Plan
* Doc. Origem...........: Contrato - GAP FIS46
* Solicitante...........: CAOA             
* USO...................:
* Observação............: Verificar se já não existe o PE
*/

User Function MT460FIM()

	Local _cEmp		:= FWCodEmp()
	Local aArea		:= GetArea()

	If findfunction("U_XMT460UPD")
		U_XMT460UPD()
	Endif

	If _cEmp == "2010" //Executa o p.e. Anapolis.
		If findfunction("U_CMVSAP24")
			U_CMVSAP24()
		Endif
	Else
		If findfunction("U_ZSAPF024")
			U_ZSAPF024()
		Endif
	EndIf

	RestArea(aArea)

Return()
