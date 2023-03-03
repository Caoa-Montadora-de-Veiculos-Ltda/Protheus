#include "Protheus.ch"
#include "totvs.ch"
#include "parmtype.ch"
#include "fwmvcdef.ch"
#INCLUDE "RESTFUL.CH"
/*/{Protheus.doc} ZPECF999
@param  	
@author 	Antonio Oliveira
@version  	P12.1.23
@since  	20/04/2022
@return  	NIL
@obs        Ponto de entrada 
@project
@history    Uso da função MATESINT p/ replicar a operação e TES aos registros do orçamento
*/
User Function ZPECF999()
Local _cTes         := Space(TamSx3("F4_CODIGO")[1])
Local _cTipoOper    := "90"  		//Tipo operação
Local _lRet         := .T.
Local cQuery        := " "
Local cAliasSQL		:= GetNextAlias()
//PUBLIC z01PECF999   := " "
//PUBLIC z02PECF999   := " "

ApMsgInfo("Para usar essa rotina, as variaveis z01PECF999 e z02PECF999 precisam estar descomentadas.")

/* *** IMPORTANTE ****
PARA ESSA ROTINA FUNCIONAR, PRECISA QUE NO FONTE MT089CD_PE AS VARIAVEIS PUBLICAS ESTEJAM SENDO CONSIDERADAS.
*/

If !U_ZGENUSER( RetCodUsr() ,"ZPECF999" ,.T.)
    Return Nil
EndIf

DbSelectArea('VS3')
VS3->(DbSetOrder(4))   //Filial + Codite
VS3->(DbGoTop())

    If Select( (cAliasSQL) ) > 0
          (cAliasSQL)->(DbCloseArea())
    EndIf

cQuery := ""
cQuery += " SELECT VS1_CLIFAT,VS1_LOJA, VS3.VS3_CODITE PRODUTO, VS3.VS3_XPICKI, VS3.VS3_NUMORC, VS3.VS3_OPER, VS3.R_E_C_N_O_ RECNOVS3 " 
cQuery += " 	FROM " + RetSQLName('VS3') + " VS3 "
cQuery += " 		INNER JOIN " + RetSQLName('VS1') + " VS1 "
cQuery += " 		ON VS3.VS3_FILIAL = VS1.VS1_FILIAL AND VS3.VS3_NUMORC = VS1.VS1_NUMORC AND VS1.D_E_L_E_T_  = ' ' "
cQuery += " 	WHERE VS3.D_E_L_E_T_ = ' ' "
cQuery += " 	AND VS1.VS1_STATUS IN ('0','3','4','F') "
//cQuery += " 	AND VS1.VS1_NUMORC IN ('00743940','00743136') "
//cQuery += " 	AND VS1.VS1_NUMORC = '00705233' "
cQuery += " 		AND VS3_OPER = '90' "

cQuery := ChangeQuery(cQuery)

DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSQL, .T., .T. )

    DbSelectArea(cAliasSQL)
    (cAliasSQL)->(dbGoTop())

    While (cAliasSQL)->(!Eof())

        z01PECF999 := (cAliasSQL)->VS1_CLIFAT
        z02PECF999 := (cAliasSQL)->VS1_LOJA

        //A TES muda de acordo com o código do produto DAC 25/04/2022
        _cTes := MaTesInt(2,    AllTrim(_cTipoOper) ,z01PECF999    ,z02PECF999  ,"C",(cAliasSQL)->PRODUTO   ,/*"VS3_CODTES"*/)

        //If VS3->(DbSeek(xFilial("VS3") +  (cAliasSQL)->PRODUTO ))
            VS3->(DbGoto((cAliasSQL)->RECNOVS3))
            RecLock("VS3", .F.)
            VS3->VS3_CODTES := _cTes   
            VS3->(MsUnlock())
        //EndIf

        (cAliasSQL)->(DbSkip())
    EndDo

Return(_lRet)


