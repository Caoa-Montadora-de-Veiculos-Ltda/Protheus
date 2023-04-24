#Include "Protheus.Ch" 
#Include "TopConn.Ch" 

//------------------------------------------------------------------------------------------
/* 
{Protheus.doc} M460FIM
Ponto de Entrada Depois da Gravacao da Nota Fiscal
@author    Leonardo Miranda
@version   12.1.27
@since     07/06/2022
@param     CMV_FAT012 Liga a geração de NF automatica de entrada emergencial
*/
//------------------------------------------------------------------------------------------

User Function M460FIM()
    Local _cProcessa    := GetMV("CMV_FAT012",,.T.)
    Local _cEmp		    := FWCodEmp()
    Local _cQuery       := ""
    Local _cTmpAlias    := GetNextAlias()
    Local aArea         := GetArea()
    Local aAreaSF2      := SF2->(GetArea())
    Local aAreaVV0      := VV0->(GetArea())
    Local aAreaVV9      := VV9->(GetArea())
    Local aAreaSD2      := SD2->(GetArea())
    Local aAreaSC5      := SC5->(GetArea())
    Local aAreaSE1      := SE1->(GetArea())
    Local aAreaSA1      := SA1->(GetArea())

	If _cEmp == "2010" //Executa o p.e. Anapolis.

        _cQuery := ""
        _cQuery += " SELECT * "
        _cQuery += " FROM "+RetSqlName("VV0")+" VV0"
        _cQuery += " WHERE  VV0.VV0_FILIAL  = '"+xFilial("VV0")+"'"
        _cQuery += " AND    VV0.VV0_NUMPED  = '"+SC5->C5_NUM+"'"
        _cQuery += " AND    VV0.D_E_L_E_T_  = ' '"

        If Select(_cTmpAlias) <> 0
            (_cTmpAlias)->(DbCloseArea())
        EndIf

        DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cTmpAlias,.F.,.T.)

        If (_cTmpAlias)->(!Eof())
            VV0->(DbGoTo((_cTmpAlias)->R_E_C_N_O_))
            VV9->(DbSetOrder(1))
            If VV9->(Dbseek(xfilial("VV0")+VV0->VV0_NUMTRA))
                VV9->(RecLock("VV9",.F.))
                VV9->VV9_XUMNFI := SF2->F2_DOC
                VV9->(MsUnLock())
            EndIf
        EndIf

        If Select(_cTmpAlias) <> 0
            (_cTmpAlias)->(DbCloseArea())
        EndIf
    else 

        IF  _cProcessa 

            If FindFunction("U_ZFATF018")
                U_ZFATF018()
            EndIf

        ENDIF
        
    EndIf

    RestArea(aArea   )
    RestArea(aAreaSF2)
    RestArea(aAreaVV0)
    RestArea(aAreaVV9)
    RestArea(aAreaSD2)
    RestArea(aAreaSC5)
    RestArea(aAreaSE1)
    RestArea(aAreaSA1)

Return()
