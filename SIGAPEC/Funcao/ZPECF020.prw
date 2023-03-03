#Include 'Protheus.ch'
#Include 'TopConn.ch'
#include 'rwmake.ch'
#include 'TOTVS.ch'
/*/{Protheus.doc} ZPECF020
@param  	
@author 	CAOA - A.Carlos
@version  	P12.1.23
@since  	11/05/2022
@return  	NIL
@obs        
@project
@history    Mostrar saldo de crédito do cliente no campo Saldo LC Disponível.   
/*/	
User Function ZPECF020()
Local cQuery     := ""
Local nResultado := 0
Local TEMP20     := GetNextAlias()

cQuery := " SELECT A1_LC, "  
cQuery += " COALESCE((SELECT SUM(E1_SALDO)    " 
cQuery += " FROM " + RetSqlName("SE1") + " E1 " 
cQuery += " INNER JOIN " + RetSqlName("SC5") + " C5 " 
cQuery += " ON C5.C5_FILIAL = E1_FILIAL "
cQuery += " AND C5.C5_NOTA = E1.E1_NUM "
cQuery += " WHERE E1.E1_SALDO > 0  "
cQuery += "      AND E1.D_E_L_E_T_ = ' '  "
cQuery += "      AND E1.E1_FILIAL  = '" + xFilial("SE1") + "'" 
cQuery += "		 AND E1.E1_CLIENTE = A1.A1_COD "
cQuery += "		 AND E1.E1_LOJA    = A1.A1_LOJA   "
cQuery += "		 AND C5.C5_CONDPAG <> '005'), 0) AS SALDUP "
cQuery += "      ,COALESCE((SELECT SUM(C9_PRCVEN)           "  
cQuery += "          FROM " + RetSqlName("SC9") + " C9  " 
cQuery += "          INNER JOIN " + RetSqlName("SC5") + " C5 "
cQuery += "              ON C5.C5_FILIAL = C9.C9_FILIAL "
cQuery += "              AND C5.C5_NOTA  = C9.C9_PEDIDO "
cQuery += "              AND C5.C5_CONDPAG <> '005'     "
cQuery += "          WHERE C9.D_E_L_E_T_   = ' '        "
cQuery += "              AND C9.C9_FILIAL  = '" + xFilial("SE1") + "'" 
cQuery += "              AND C9.C9_CLIENTE = A1.A1_COD  "
cQuery += "              AND C9.C9_LOJA    = A1.A1_LOJA "
cQuery += "              AND C9.C9_BLEST   ='10'        "
cQuery += "              AND C9.C9_BLCRED  = '10'       "
cQuery += "              AND C9.C9_NFISCAL = ' ' ) ,0 ) AS SALPEDL  " 
cQuery += "     ,COALESCE((SELECT SUM(VS3.VS3_VALTOT) " 
cQuery += "  		FROM " + RetSqlName("VS3") + " VS3 " 
cQuery += "  		INNER JOIN " + RetSqlName("VS1") + " VS1 " 
cQuery += "  		ON VS1_FILIAL = '" + xFilial("SE1") + "'"
cQuery += "  		AND VS1_NUMORC = VS3_NUMORC      " 
cQuery += "  		AND VS1.VS1_STATUS IN ('4','F')  "
cQuery += "  		AND VS1.VS1_FORPAG <> '005'      "
cQuery += "  		AND VS1.VS1_CLIFAT = A1.A1_COD   " 
cQuery += "          AND VS1.VS1_LOJA  = A1.A1_LOJA  "
cQuery += "  		AND VS3.D_E_L_E_T_ = ' ' ) , 0 ) AS SALORCL  "
cQuery += "     ,A1_XLC                                          "
cQuery += "     ,COALESCE((SELECT SUM(E1_SALDO)                  "
cQuery += "     FROM " + RetSqlName("SE1") + " E1 " 
cQuery += "         INNER JOIN " + RetSqlName("SC5") + " C5 "
cQuery += "             ON C5.C5_FILIAL = E1_FILIAL              "
cQuery += "             AND C5.C5_NOTA  = E1.E1_NUM              "
cQuery += "         WHERE E1.E1_SALDO > 0                        "
cQuery += "             AND E1.D_E_L_E_T_ = ' '                  "
cQuery += "             AND E1.E1_FILIAL = '" + xFilial("SE1") + "'"
cQuery += "             AND E1.E1_CLIENTE = A1.A1_COD            "
cQuery += "             AND E1.E1_LOJA    = A1.A1_LOJA           "
cQuery += "             AND C5.C5_CONDPAG = '005'                "
cQuery += "             AND E1.E1_LOJA = '01'), 0 ) AS SALDUP_FP "
cQuery += "     ,COALESCE((SELECT SUM(E1_SALDO)                  "
cQuery += "     FROM " + RetSqlName("SE1") + " E1 " 
cQuery += "         INNER JOIN " + RetSqlName("SC5") + " C5 "
cQuery += "             ON C5.C5_FILIAL = E1_FILIAL              "
cQuery += "             AND C5.C5_NOTA  = E1.E1_NUM              "
cQuery += "             WHERE E1.E1_SALDO > 0                    "
cQuery += "             AND E1.D_E_L_E_T_ = ' '                  "
cQuery += "             AND E1.E1_FILIAL = '" + xFilial("SE1") + "'"
cQuery += "             AND E1.E1_CLIENTE = A1.A1_COD            "
cQuery += "             AND E1.E1_LOJA    = A1.A1_LOJA           "
cQuery += "             AND TO_DATE(E1.E1_VENCREA ,'yyyymmdd') < ROUND(SYSDATE) "
cQuery += "             AND C5.C5_CONDPAG = '005'                "
cQuery += "             AND E1.E1_LOJA = '01'), 0 ) AS SALDUP_FP_ATRAS "
cQuery += "     ,COALESCE((SELECT SUM(C9_PRCVEN)                 "
cQuery += "     FROM " + RetSqlName("SC9") + " C9  " 
cQuery += "     INNER JOIN " + RetSqlName("SC5") + " C5 " 
cQuery += "         ON C5.C5_FILIAL = C9.C9_FILIAL                " 
cQuery += "         AND C5.C5_NOTA  = C9.C9_PEDIDO                "
cQuery += "         AND C5.C5_CONDPAG <> '005'                    "
cQuery += "         WHERE C9.D_E_L_E_T_ = ' '                     "
cQuery += "         AND C9.C9_FILIAL = '" + xFilial("SE1") + "'"
cQuery += "         AND C9.C9_CLIENTE = A1.A1_COD                 "
cQuery += "         AND C9.C9_LOJA    = A1.A1_LOJA                "
cQuery += "         AND C9.C9_BLEST   = '10'                      "
cQuery += "         AND C9.C9_BLCRED  = '10'                      "
cQuery += "         AND C9.C9_NFISCAL = ' '),0) AS SALPEDL_FP     "
cQuery += "     ,COALESCE((SELECT SUM(VS3.VS3_VALTOT)             "
cQuery += "     FROM " + RetSqlName("VS3") + " VS3 "            
cQuery += "     INNER JOIN " + RetSqlName("VS1") + " VS1 "
cQuery += "     ON VS1_FILIAL  = VS3_FILIAL                       "
cQuery += "     AND VS1_NUMORC = VS3_NUMORC                       "
cQuery += "     AND VS1.VS1_STATUS IN ('4','F')                   "
cQuery += "     AND VS1.VS1_FORPAG = '005'                        "                      
cQuery += "     AND VS1.VS1_CLIFAT = A1.A1_COD                    "
cQuery += "     AND VS1.VS1_LOJA = '01'                           "
cQuery += "     AND VS3.D_E_L_E_T_ = ' '),0) AS SALORCL_FP        "
cQuery += " FROM " + RetSqlName("SA1") + " A1 "
cQuery += " WHERE A1.A1_COD    = '" + M->A1_COD  + "'" 
cQuery += "     AND A1.A1_LOJA = '" + M->A1_LOJA + "'" 
cQuery += "     AND A1.D_E_L_E_T_ = ' ' "

//cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TEMP20",.T.,.F.)
dbSelectArea("TEMP20")    
TEMP20->(dbGoTop())

While TEMP20->(!Eof())

    nResultado = SA1->A1_LC-(TEMP20->SALDUP+TEMP20->SALPEDL+TEMP20->SALORCL)   

    TEMP20->(dbSKIP())

EndDo 

If Select("TEMP20") <> 0
	TEMP20->(DbCloseArea())
	Ferase(TEMP20+GetDBExtension())
Endif 

//Ajusta Liberaçao de Crédito FP caso exista
//U_ZFATF017(M->A1_COD)

Return(nResultado)
