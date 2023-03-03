#include "protheus.ch"
#include "tbiconn.ch"

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} CRIASDBD
Ponto de Entrada para gravação da tabela SDB.
Será gravado o campo customizado C6_CHASSI no campo DB_NUMSERI
@type Fu nction
@author Ronaldo Carvalho
@since 09/03/2021
@version 12.1.23
/*/
//+----------------------------------------------------------------------------------------

User Function CRIASDBD
 
    Local aAreaSDB        := SDB->(GetArea())
    Local nRecno          := SDB->(Recno())

    DbSelectArea("SDB")
    If SDB->(DbGoTo(nRecno))
        If !Empty(SC6->C6_CHASSI)
            Reclock( 'SDB' , .F.)
                SDB->DB_NUMSERI := SC6->C6_CHASSI
            SDB->(MsUnLock())
        Endif
    EndIf

RestArea(aAreaSDB)
		
Return
