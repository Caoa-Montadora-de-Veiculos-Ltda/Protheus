#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#include "rwmake.ch"
/*/{Protheus.doc} ZCOMF028 
@author     A.Carlos 
@since 		21/10/2020
@param     	 
@return    	Logico
@project    CAOA
@version 	1.0
@obs        Chamado pelo PE MTA120G2 salvar dados no PC
@history    Gravando dados específicos do PC e vindo do EIC 
/*/   
User Function ZCOMF028()
Local aArea := GetArea()

IF IsInCallStack("EICPO400")    

   SC7->C7_XFORMAI := UPPER(SW2->W2_XFORMAI)
   SC7->C7_XOBSCOM := "Pedido de Compras gerado pelo módulo de Importação"
   SC7->C7_XOBSFOR := "EIC"
   SC7->C7_XOBSTST := "EIC"  
   SC7->C7_XTPPED  := "ZNOR"

Else
 
   SC7->C7_XOBSCOM := cC7_SCOM
   SC7->C7_XOBSFOR := UPPER(cC7_SFOR)
   SC7->C7_XOBSTST := UPPER(cC7_XOCOM)  
   SC7->C7_XTPPED  := UPPER(cC7_XTPREQ) 
   SC7->C7_XFCA    := cXFCA

EndIf

RestArea( aArea )
     
Return
