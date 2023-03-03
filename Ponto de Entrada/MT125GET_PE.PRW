#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#include "rwmake.ch"
/*/{Protheus.doc} MT125GET_PE
@author     A.Carlos
@since 		21/10/2020
@param     	 
@return    	
@project    CAOA
@version 	1.0
@obs        Redimensiona a Dialog
@history    
/*/

User Function MT125GET()
Local aRet:= PARAMIXB[1]

//Abaixando o começo da linha da getdados
aRet[2,1] := 110 
// Abaixando a linha de contorno dos campos do cabeçalho
aRet[1,3] := 105 

Return(aRet) 
