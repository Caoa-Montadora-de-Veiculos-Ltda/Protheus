#Include "Protheus.Ch" 
#Include "TopConn.Ch" 
#Include 'RwMake.Ch'
#Include 'Font.Ch'
#Include 'Colors.Ch'
#Include "TbiConn.CH"
//------------------------------------------------------------------------------------------
/* 
{Protheus.doc} M460FIM
Ponto de Entrada Depois da Gravacao da Nota Fiscal
@author    Leonardo Miranda
@version   12.1.27
@since     07/06/2022 
@History   Incluído a chamda da função para emissão de Boleto qdo RA 
*/ //    U_RF01B062(E1_PORTADO,E1_AGEDEP,E1_CONTA,'001',/*lSetup*/,/*cNotIni*/,/*cNotFim*/,/*cSerie*///,SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM))
//------------------------------------------------------------------------------------------
User Function M460FIM()

    Local _cEmp		    := FWCodEmp()
    Local _cQuery       := ""
    Local _cChave       := xFilial("SE1") + "5  " + SC5->C5_NOTA
    Local _cTmpAlias    := GetNextAlias()
    Local _nRecSE1      := 0    
    Local _nRecBol      := 0   
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

        IF SC5->C5_XPREFIX == 'PVF'

            SE1->(dbSetOrder(1))
            SE1->(dbGoTop())
            If SE1->(dbSeek(xFilial("SE1")+SC5->C5_XPREFIX+SC5->C5_NUM+'   '+'1 '+'RA '))   //+ '   '+ '1 ' + 'RA '   //Parcela+Tipo 
                _cBanco := SE1->E1_PORTADO
                _cAge   := SE1->E1_AGEDEP
                _cConta := SE1->E1_CONTA 
            ENDIF

            //chamda da função para emissão de Boleto qdo RA 
            DbSelectArea("SE1")
            SE1->(dbGoTop())
            SE1->(DbSetOrder(1))       //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
            If SE1->(DbSeek(_cChave))
                _nRecSE1 := SE1->(Recno()) 
                WHILE SE1->( !EOF() .AND. (xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM) = _cChave ) 
                    RecLock("SE1",.F.)
                    SE1->E1_PEDIDO  := SC5->C5_NUM
                    SE1->E1_PORTADO := _cBanco 
                    SE1->E1_AGEDEP  := _cAge
                    SE1->E1_CONTA   := _cConta
                    MsUnlock()
                    
                    //emissão de Boleto
                    IF SE1->E1_XFORMA $ 'BOL_VFP_TED' 
                        IF SE1->E1_XFORMA <> 'TED' .AND. SE1->E1_XFORMA <> 'VFP'
                            U_RF01B062(E1_PORTADO,E1_AGEDEP,E1_CONTA,'001',/*lSetup*/,/*cNotIni*/,/*cNotFim*/,/*cSerie*/,_cChave)
                        ENDIF
                    	_nRecBol := SE1->(Recno()) 

                        SE1->(dbGoTo(_nRecSE1))
                        If Findfunction("U_ZFINF006") .AND. SE1->E1_PARCELA ='1 ' .AND. SE1->E1_TIPO = 'NF '
                            U_ZFINF006()
                        EndIf
                        SE1->(dbGoTo(_nRecBol))
                    ENDIF

                    SE1->(DbSkip())
                END
            EndIf

        ENDIF

    else
        If FindFunction("U_ZFATF018")
			U_ZFATF018()
		EndIf
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
