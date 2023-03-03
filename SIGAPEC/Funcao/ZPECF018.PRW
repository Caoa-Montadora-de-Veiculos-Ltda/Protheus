#Include 'Protheus.ch'
#Include 'TopConn.ch'
#include "rwmake.ch"
#include "TOTVS.ch"
/*/{Protheus.doc} ZPECF018
@param  	
@author 	CAOA - A.Carlos
@version  	P12.1.23
@since  	09/05/2022
@return  	NIL
@obs        Chamado pelo PE PEQRYACR 
@project
@history    Alterar a query da analise de crédito.   
/*/	
User Function ZPECF018()
cAliasFiltro := ParamIXB[1]
cQuery       := ParamIXB[2]
cCliente     := ParamIXB[3]
cLoja        := ParamIXB[4]
nPosGru      := 0

if cAliasFiltro == "VS1"
    nPosGru := At("GROUP BY ",cQuery)
    IF nPosGru > 0
        cQuery  := STUFF(cQuery, nPosGru, 0, " AND VS1.VS1_STATUS NOT IN ('3') ")
    else
        cQuery  += " AND VS1.VS1_STATUS NOT IN ('3') "
    ENDIF
Endif

Return(cQuery)
