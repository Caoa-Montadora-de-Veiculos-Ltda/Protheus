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

	Local aArea		:= GetArea()

	If findfunction("U_XMT460UPD")
		U_XMT460UPD()
	Endif

	If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
		If findfunction("U_CMVSAP24")
			U_CMVSAP24()
		Endif
	ElseIf ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
		If findfunction("U_ZSAPF024")
			U_ZSAPF024()
		Endif
	EndIf

	RestArea(aArea)

Return()
