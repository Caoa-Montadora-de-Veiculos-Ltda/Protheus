#Include "Protheus.ch"

/*/{Protheus.doc} MS520DEL
//TODO Descrição auto-gerada.
@author rafael.melo
@since 08/06/2017
@version undefined

@type function
/*/

User Function MS520DEL()

	Local _cEmp		:= FWCodEmp()
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local nStatus 	:= 0

	If _cEmp == "2010" //Executa o p.e. Anapolis.
		If Findfunction("U_CMVSAP14")
			U_CMVSAP14("0")
		EndIf

        SDB->(DbSetOrder(1))
        If SDB->(DbSeek(xFilial("SDB")+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ))
            VV1->(DbSetOrder(2))
            If VV1->(DbSeek(xFilial("VV1")+SDB->DB_NUMSERI))
                VV1->(RecLock("VV1",.F.))
                VV1->VV1_SITVEI := "0"
                VV1->VV1_ULTMOV := "E"
                VV1->(MsUnLock())

				SC6->(DbSetOrder(1))
				If SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV)) .And. !Empty(Alltrim(SC6->C6_PEDCLI))
                	
					cQuery := "  UPDATE " + RetSqlName("VRK") + " VRK "
					cQuery += " 	SET VRK.VRK_ITETRA = ' ', "
					cQuery += "			VRK.VRK_NUMTRA = ' ' "
                    cQuery += " WHERE   VRK.VRK_CHASSI = '" + SDB->DB_NUMSERI + "' "
                    cQuery += "     AND VRK.VRK_ITETRA <> ' ' "
                    cQuery += "     AND VRK.VRK_PEDIDO = (SELECT VRJ.VRJ_PEDIDO "
                    cQuery += "                             FROM " + RetSqlName("VRJ") + " VRJ "
                    cQuery += "                             WHERE  VRJ.VRJ_PEDCOM = '" + SC6->C6_PEDCLI + "')"
                    nStatus := TCSqlExec(cQuery)
 					If (nStatus < 0)
                        MsgStop("TCSQLError() " + TCSQLError(), "Erro atualizacao VRK")                                    
                    EndIf

					if U_fPedZero(SC6->C6_PEDCLI)
						cQuery := ""
						cQuery += " UPDATE "+RetSqlName("VRJ")
						cQuery += " SET VRJ_STATUS = 'A' ,"
						cQuery += "     VRJ_XINTEG = ' ' "
						cQuery += " WHERE  VRJ_FILIAL = '" + xFilial("VRJ") + "'" 
						cQuery += "    AND VRJ_PEDCOM = '" + SC6->C6_PEDCLI + "'"
						cQuery += "    AND D_E_L_E_T_ = ' '"
						nStatus := TCSqlExec(cQuery)

						If (nStatus < 0)
							MsgStop("TCSQLError() " + TCSQLError(), "Erro atualizacao VRJ")                                    
						EndIf
					EndIf
				EndIf
            EndIf
        EndIf
	Else
		If Findfunction("U_ZSAPF014")
			U_ZSAPF014("0")
		EndIf
	EndIf

	RestArea(aArea)

Return()
