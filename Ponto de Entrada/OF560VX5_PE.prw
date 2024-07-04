#include "totvs.ch"

User Function OF560VX5()

	Local _xRet 	

	If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
		_xRet := zFMontadora()
    Else
        //Retorna os valores padrões quando Barueri
        _xRet := zFBarueri()
    EndIf

Return(_xRet)

/*
=====================================================================================
Programa.:              zFMontadora
Autor....:              TOTVS
Data.....:              03/02/2022
Descricao / Objetivo:   Executa o P.e. empresa Montadora
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/
Static Function zFMontadora()
	
	Local cChamada 		:= ParamIxb[1]
	Local cAuxReadVar 	:= ParamIxb[2] // ReadVar()
	Local cAuxFiltro 	:= ""

	If cChamada == "2"
		Do Case
			Case cAuxReadVar == "M->C1_CORINT" // Cor Interna
				cAuxFiltro := "066"
			Case cAuxReadVar == "M->C1_COREXT" // Cor Externa
				cAuxFiltro := "067"
			Case cAuxReadVar == "M->C1_OPCION" // Opcional
				cAuxFiltro := "068"
		EndCase
	EndIf
	If IsInCallStack("U_CMVAUT05")
		Do Case
			Case cAuxReadVar == "MV_PAR03"
				cAuxFiltro := "067"
			Case cAuxReadVar == "MV_PAR04"
				cAuxFiltro := "066"
			Case cAuxReadVar == "MV_PAR05"
				cAuxFiltro := "068"
		EndCase
    EndIF
Return(cAuxFiltro)

/*
=====================================================================================
Programa.:              zFBarueri
Autor....:              TOTVS
Data.....:              03/02/2022
Descricao / Objetivo:   Executa o P.e. empresa Barueri
Doc. Origem:            GAP
Solicitante:            Cliente
Uso......:              CAOA Montadora de Veiculos
Obs......:              
=====================================================================================
*/
Static Function zFBarueri()

	Local cTipo  := ParamIXB[01] // Tipo de Chamada
	//Local cCampo := ParamIXB[02] // Campo que disparou o F3
	Local xRet

	If cTipo == "1" // Tabelas Customizadas no VX5 //
   		xRet := {}

   		aAdd(xRet,{"Z00","Tipo de Pedido" , "" , 20})               // Tabela do Tipo de Pedido
   		aAdd(xRet,{"Z01","Tipo de Modal"  , "" , 12})               // Tabela do Modal de carga
		aAdd(xRet,{"Z02","Tp.Pedido X Tp.Operação "  , "" , 12})    // Tabela do Tipo de Pedido X Tipo de Operação TES Intelig
		aAdd(xRet,{"Z03","Tp.Pedido X Priorização "  , "" , 12})    // Tabela do Tipo de Pedido X Priorização
		aAdd(xRet,{"Z04","Tp.Pedido X Tp RgLog "  , "" , 12})    		// Tabela do Tipo de Pedido X Tipo de Pedido RgLog


	ElseIf cTipo == "2" // Qual tabela VX5 deve ser utilizada no F3 de um determinado campo ? //

   		xRet := ""

	EndIf

Return(xRet)
