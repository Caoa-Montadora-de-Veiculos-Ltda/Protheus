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
    
    Local _cEmp		        := FWCodEmp()
	Local aArea		        := GetArea()
    Private cAliasFiltro    := ""
    Private cQuery          := ""
    Private cCliente        := ""
    Private cLoja           := ""

    If _cEmp == "2020" //Executa o p.e. Anapolis.

        cQuery := U_ZPECF018()
    
    EndIf

    RestArea(aArea)

Return(cQuery)
