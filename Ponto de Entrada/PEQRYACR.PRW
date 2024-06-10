#Include 'Protheus.ch'
#Include 'TopConn.ch'
#include "rwmake.ch"
#include "TOTVS.ch"
/*/{Protheus.doc} ZPECF013
@param  	
@author 	CAOA - A.Carlos
@version  	P12.1.23
@since  	06/05/2022
@return  	NIL
@obs         
@project
@history    Alterar a query da analise de crédito.   
/*/	
User Function PEQRYACR()
    
	Local aArea		        := GetArea()
    Private cAliasFiltro    := ""
    Private cQuery          := ""
    Private cCliente        := ""
    Private cLoja           := ""

    If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB

        cQuery := U_ZPECF018()
    
    EndIf

    RestArea(aArea)

Return(cQuery)
