#Include 'Protheus.ch'
#include "TbiConn.ch"
#INCLUDE "TOPCONN.CH"
#include "Fileio.ch"

/*
=====================================================================================
Programa.:              ZGENF005
Autor....:              CAOA - Fagner Barreto
Data.....:              05/08/2021
Descricao / Objetivo:   Função usada para alteração de registros das tabelas SB2, SB8, 
D14 e execução da rotina refaz saldos via schedule.
Doc. Origem:
Solicitante:            Nata e Wallison    
=====================================================================================
*/
User Function ZGENF005()
    Local lAuto     := .T. //-- Caso a rotina seja rodada em batch(.T.), senão (.F.)  
    Local lRefSaldo := GetNewPar("CMV_GEN001", .F.)
    Local cDtValid  := GetNewPar("CMV_GEN002", '20210930')
    Local cUpdate   := ""     

    Conout( "INICIO | ZGENF005" )

    cUpdate :=  " UPDATE " + RetSqlName("SB8") + CRLF
    cUpdate +=  " SET B8_DTVALID = '" + cDtValid + "' " + CRLF
    cUpdate +=  " WHERE B8_FILIAL = '" + FWxFilial("D14")  + "' " + CRLF
    cUpdate +=  " AND B8_DTVALID <> ' ' " + CRLF
    cUpdate +=  " AND B8_DTVALID < '" + DToS( dDatabase ) + "' " + CRLF
    cUpdate +=  " AND D_E_L_E_T_ = ' ' " + CRLF

    If TcSqlExec(cUpdate) < 0
        Conout("Falha na execução do UPD da tabela SB8 dt validade, erro :" + TcSqlError() )
    EndIf

    cUpdate :=  " UPDATE " + RetSqlName("D14") + CRLF
    cUpdate +=  " SET D14_DTVALD = '" + cDtValid + "' " + CRLF
    cUpdate +=  " WHERE D14_FILIAL = '" + FWxFilial("D14") + "' " + CRLF
    cUpdate +=  " AND D14_DTVALD <> ' ' " + CRLF
    cUpdate +=  " AND D14_DTVALD < '" + DToS( dDatabase ) + "' " + CRLF
    cUpdate +=  " AND D_E_L_E_T_ = ' ' " + CRLF

    If TcSqlExec(cUpdate) < 0
        Conout("Falha na execução do UPD da tabela D14 dt validade, erro :" + TcSqlError() )
    EndIf

    cUpdate :=  " UPDATE " + RetSqlName("SB2") + CRLF
    cUpdate +=  " SET B2_RESERVA = 0 " + CRLF
    cUpdate +=  " WHERE B2_FILIAL = '" + FWxFilial("SB2") + "' " + CRLF
    cUpdate +=  " AND B2_LOCAL IN ('220','907','909','180','001','040','182','011') " + CRLF //--> Mudar para Parametro??
    cUpdate +=  " AND B2_RESERVA <> 0 " + CRLF
    cUpdate +=  " AND D_E_L_E_T_ = ' ' " + CRLF

    If TcSqlExec(cUpdate) < 0
        Conout("Falha na execução do UPD da tabela SB2 reserva, erro :" + TcSqlError() )
    EndIf

    cUpdate :=  " UPDATE " + RetSqlName("D14") + CRLF
    cUpdate +=  " SET D14_QTDSPR = 0 " + CRLF
    cUpdate +=  " WHERE D14_FILIAL = '" + FWxFilial("D14") + "' " + CRLF
    cUpdate +=  " AND D14_QTDSPR <> 0 " + CRLF
    cUpdate +=  " AND D_E_L_E_T_ = ' ' " + CRLF

    If TcSqlExec(cUpdate) < 0
        Conout("Falha na execução do UPD da tabela D14 saida prevista, erro :" + TcSqlError() )
    EndIf

    cUpdate :=  " UPDATE " + RetSqlName("D14") + CRLF
    cUpdate +=  " SET D_E_L_E_T_ = '*' " + CRLF
    cUpdate +=  " WHERE D14_FILIAL = '" + FWxFilial("D14") + "'" + CRLF
    cUpdate +=  " AND D14_QTDEST = 0 " + CRLF
    cUpdate +=  " AND D14_QTDEPR = 0 " + CRLF
    cUpdate +=  " AND D14_QTDSPR = 0 " + CRLF
    cUpdate +=  " AND D_E_L_E_T_ = ' ' " + CRLF

    If TcSqlExec(cUpdate) < 0
        Conout("Falha na execução do UPD da tabela D14 saldo zero, erro :" + TcSqlError() )
    EndIf

    cUpdate :=  " UPDATE " + RetSqlName("SB2") + CRLF
    cUpdate +=  " SET B2_VATU1 = 0 " + CRLF
    cUpdate +=  " WHERE B2_FILIAL = '" + FWxFilial("SB2") + "'" + CRLF
    cUpdate +=  " AND B2_VATU1 < 0 " + CRLF
    cUpdate +=  " AND D_E_L_E_T_ = ' ' " + CRLF

    If TcSqlExec(cUpdate) < 0
        Conout("Falha na execução do UPD da tabela SB2 zerar VATU, erro :" + TcSqlError() )
    EndIf

    cUpdate :=  " UPDATE " + RetSqlName("SB2") + CRLF
    cUpdate +=  " SET B2_VATU2 = 0 " + CRLF
    cUpdate +=  " WHERE B2_FILIAL = '" + FWxFilial("SB2") + "'" + CRLF
    cUpdate +=  " AND B2_VATU2 < 0 " + CRLF
    cUpdate +=  " AND D_E_L_E_T_ = ' ' " + CRLF

    If TcSqlExec(cUpdate) < 0
        Conout("Falha na execução do UPD da tabela SB2 zerar VATU, erro :" + TcSqlError() )
    EndIf

    cUpdate :=  " UPDATE " + RetSqlName("SB2") + CRLF
    cUpdate +=  " SET B2_VATU3 = 0 " + CRLF
    cUpdate +=  " WHERE B2_FILIAL = '" + FWxFilial("SB2") + "'" + CRLF
    cUpdate +=  " AND B2_VATU3 < 0 " + CRLF
    cUpdate +=  " AND D_E_L_E_T_ = ' ' " + CRLF

    If TcSqlExec(cUpdate) < 0
        Conout("Falha na execução do UPD da tabela SB2 zerar VATU, erro :" + TcSqlError() )
    EndIf

    cUpdate :=  " UPDATE " + RetSqlName("SB2") + CRLF
    cUpdate +=  " SET B2_VATU4 = 0 " + CRLF
    cUpdate +=  " WHERE B2_FILIAL = '" + FWxFilial("SB2") + "'" + CRLF
    cUpdate +=  " AND B2_VATU4 < 0 " + CRLF
    cUpdate +=  " AND D_E_L_E_T_ = ' ' " + CRLF

    If TcSqlExec(cUpdate) < 0
        Conout("Falha na execução do UPD da tabela SB2 zerar VATU, erro :" + TcSqlError() )
    EndIf

    cUpdate :=  " UPDATE " + RetSqlName("SB2") + CRLF
    cUpdate +=  " SET B2_VATU5 = 0 " + CRLF
    cUpdate +=  " WHERE B2_FILIAL = '" + FWxFilial("SB2") + "'" + CRLF
    cUpdate +=  " AND B2_VATU5 < 0 " + CRLF
    cUpdate +=  " AND D_E_L_E_T_ = ' ' " + CRLF

    If TcSqlExec(cUpdate) < 0
        Conout("Falha na execução do UPD da tabela SB2 zerar VATU, erro :" + TcSqlError() )
    EndIf

    cUpdate :=  " UPDATE " + RetSqlName("D14") + CRLF 
    cUpdate +=  " SET D_E_L_E_T_ = '*' " + CRLF
    cUpdate +=  " WHERE D14_FILIAL = '" + FWxFilial("D14") + "'" + CRLF
    cUpdate +=  "   AND R_E_C_N_O_ IN ( " + CRLF
    cUpdate +=  "   SELECT R_E_C_N_O_ FROM ( " + CRLF
    cUpdate +=  "       SELECT uniti UNITIZADOR, count(*) QTD FROM ( " + CRLF
    cUpdate +=  "           SELECT d14_idunit uniti, d14_local arm, d14_ender ende " + CRLF
    cUpdate +=  "           FROM " + RetSqlName("D14") + " d14 " + CRLF
    cUpdate +=  "           WHERE d14_idunit <> ' ' and D_E_L_E_T_ = ' ' " + CRLF
    cUpdate +=  "               and ( d14.d14_qtdspr = 0 and d14.d14_qtdepr = 0 ) " + CRLF
    cUpdate +=  "               and d14.d14_qtdest > 0  " + CRLF
    cUpdate +=  "               GROUP BY d14_idunit, d14_ender, d14_local ) " + CRLF
    cUpdate +=  "       having count(*) > 1 " + CRLF
    cUpdate +=  "       group by uniti ) x, ABDHDU_PROT.D14010 d14 " + CRLF
    cUpdate +=  "   WHERE x.unitizador = d14.d14_idunit and D_E_L_E_T_ = ' ' " + CRLF
    cUpdate +=  "   and d14_ender = 'DCE01' )" + CRLF

    If TcSqlExec(cUpdate) < 0
        Conout("Falha na execução do UPD de correção de unitizador fracionado, erro :" + TcSqlError() )
    EndIf

    cUpdate :=  " UPDATE " + RetSqlName("D14") + CRLF
    cUpdate +=  " SET D_E_L_E_T_ = '*' " + CRLF
    cUpdate +=  " WHERE D14_FILIAL = '" + FWxFilial("D14") + "'" + CRLF
    cUpdate +=  "   AND D14_PRODUT = ' ' " + CRLF
    cUpdate +=  "   AND D_E_L_E_T_ = ' ' " + CRLF

    If TcSqlExec(cUpdate) < 0
        Conout("Falha na execução do UPD de produto em branco, erro :" + TcSqlError() )
    EndIf

    If lRefSaldo
        Conout( "ZGENF005 | Acionou a execução do refaz saldo " )
        Conout( "Empresa logada " + cEmpAnt)
        Conout( "Filial logada " + cFilAnt)
        VarInfo( "MV_PAR01", MV_PAR01)
        VarInfo( "MV_PAR02", MV_PAR02)
        VarInfo( "MV_PAR03", MV_PAR03)
        VarInfo( "MV_PAR04", MV_PAR04)
        VarInfo( "MV_PAR05", MV_PAR05)
        VarInfo( "MV_PAR06", MV_PAR06)
        VarInfo( "MV_PAR07", MV_PAR07)
        VarInfo( "MV_PAR08", MV_PAR08)

        MSExecAuto({|x| mata300(x)}, lAuto)

        Conout( "ZGENF005 | Saida da execução do refaz saldo " )
    EndIf

    //--CORRIGE O B2_QEMPSA
    // RETIRADO O UPDATE DIÁRIO PARA LIMPEZA DO B2_QEMPSA
    // 07/12/2021 - Solicitação Emanuel e Thiago
    // 
    //UPSACAOA()

    Conout( "FIM | ZGENF005" )

Return

/*
=====================================================================================
Programa.:              Scheddef
Autor....:              CAOA - Fagner Barreto
Data.....:              05/08/2021
Descricao / Objetivo:   Função usada para habilitar a tela de perguntes e seleção
da empresa diretamente na rotina de schedule
=====================================================================================
*/
Static Function Scheddef()
    Local aParam
    Local aOrd   := {}

    aParam := { "P",;
                "MTA300",; //--Carrega Pergunte
                "",;
                aOrd,;
              }

Return aParam

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³UPSACAOA  ³ Autor ³ SAULO                 ³ Data ³ 30.09.21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³UPDATE EM LINHA B2_QEMPSA.                                   ±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function UPSACAOA()

Local _cQuery  := ""  

//CORRIGE O B2_QEMPSA

_cQuery  := " SELECT TRB.B2_QEMPSA,TRB.CP_QEMPSA,TRB.B2RECNO, 
_cQuery  += " 'UPDATE ABDHDU_PROT.SB2010 SET B2_QEMPSA='||TRB.CP_QEMPSA||' WHERE R_E_C_N_O_ = '||TRB.B2RECNO||'' AS LINHA
_cQuery  += " FROM (  
_cQuery  += "   SELECT 
_cQuery  += "   SB2.R_E_C_N_O_ B2RECNO, B2_FILIAL,B2_COD,B2_LOCAL,B2_QATU,B2_QACLASS,B2_RESERVA,B2_QEMPSA
_cQuery  += "   ,(B2_QATU-B2_QACLASS-B2_RESERVA-B2_QEMPSA) B2QDISP
_cQuery  += "   ,(SELECT CASE WHEN SUM(CP_QUANT-CP_QUJE) IS NULL THEN 0 ELSE SUM(CP_QUANT-CP_QUJE) END CP_QEMPSA 
_cQuery  += "                                             FROM ABDHDU_PROT.SCP010 SCP 
_cQuery  += "                                             INNER JOIN ABDHDU_PROT.SCQ010 CQ ON
_cQuery  += "                                             CQ_FILIAL = CP_FILIAL
_cQuery  += "                                             AND CQ_NUM = CP_NUM
_cQuery  += "                                             AND CQ_PRODUTO = CP_PRODUTO
_cQuery  += "                                             AND CQ_ITEM = CP_ITEM
_cQuery  += "                                             AND CQ_LOCAL = CP_LOCAL   
_cQuery  += "                                             AND CQ_NUMREQ='      '
_cQuery  += "                                             AND CQ.D_E_L_E_T_ <> '*'
_cQuery  += "                                             WHERE 
_cQuery  += "                                             CP_FILIAL = B2_FILIAL 
_cQuery  += "                                             AND CP_PRODUTO = B2_COD
_cQuery  += "                                             AND CP_LOCAL = B2_LOCAL
_cQuery  += "                                             AND CP_QUJE < CP_QUANT
_cQuery  += "                                             AND CP_PREREQU='S'
_cQuery  += "                                             AND CP_STATUS <> 'E' 
_cQuery  += "                                             AND SCP.D_E_L_E_T_ <> '*') AS CP_QEMPSA
_cQuery  += "   FROM ABDHDU_PROT.SB2010 SB2
_cQuery  += "   WHERE 
_cQuery  += "   B2_FILIAL='2010022001'
_cQuery  += "   AND SB2.D_E_L_E_T_ <> '*'
_cQuery  += "   GROUP BY SB2.R_E_C_N_O_,B2_FILIAL,B2_COD,B2_LOCAL,B2_QATU,B2_QACLASS,B2_RESERVA,B2_QEMPSA
_cQuery  += "   ORDER BY B2_FILIAL,B2_COD,B2_LOCAL,B2_QEMPSA
_cQuery  += "   ) TRB
_cQuery  += "   WHERE TRB.B2_QEMPSA <> TRB.CP_QEMPSA OR TRB.CP_QEMPSA IS NULL "

dBUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"TRB0",.F.,.T.)
TRB0->(DbGotop())
_nLinhas := 0
	
While TRB0->(!Eof())
	TCSQLExec(TRB0->LINHA) //Executa update em linha
	_nLinhas++
	
	If _nLinhas == 1024
		TcSqlExec("COMMIT")
		_nLinhas := 0
	Endif
	TRB0->(DbSkip())
End
TRB0->(DbCloseArea())

TcSqlExec("COMMIT")

Return
