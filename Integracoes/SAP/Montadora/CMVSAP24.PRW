#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*
=========================================================================================================
Programa.................: CMVSAP24
Autor:...................: Totvs
Data.....................: Jul/19
Descrição / Objetivo.....: Gravacao de campos de entidades contabeis
Doc. Origem..............: 
Solicitante..............: Cliente
Uso......................: Caoa
Obs......................: Rotina chamada pelo ponto de entrada MT460FIM
=========================================================================================================
*/
User Function CMVSAP24()

Local aArea := {SD2->(GetArea()),SE2->(GetArea()),GetArea()}
Local cQ := ""
Local cAliasTrb := GetNextAlias()
Local aSE2 := {}
Local nCnt := 0

If !Empty(SF2->F2_NFICMST) .or. !Empty(SF2->F2_GNRDIF)
	cQ := "SELECT SE2.R_E_C_N_O_ SE2_RECNO "
	cQ += "FROM "+retSQLName("SE2")+" SE2 "
	cQ += "WHERE "
	cQ += "E2_FILIAL = '"+xFilial("SE2")+"' "
	cQ += "AND (E2_PREFIXO || SE2->E2_NUM = '"+SF2->F2_NFICMST+"' "
	cQ += "OR E2_PREFIXO || SE2->E2_NUM = '"+SF2->F2_GNRDIF+"') "
	cQ += "AND E2_TIPO = 'TX' "
	cQ += "AND E2_EMISSAO = '"+dTos(SF2->F2_EMISSAO)+"' "
	cQ += "AND E2_BAIXA = ' ' " 
	cQ += "AND SE2.D_E_L_E_T_ = ' ' "
			
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
			
	While (cAliasTrb)->(!Eof())
		aAdd(aSE2,(cAliasTrb)->SE2_RECNO)
		(cAliasTrb)->(dbSkip())
	Enddo
	
	(cAliasTrb)->(dbCloseArea())
	
	If !Empty(aSE2)
		SD2->(dbSetOrder(3))
		If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
			For nCnt:=1 To Len(aSE2)
				SE2->(dbGoto(aSE2[nCnt]))
				If SE2->(Recno()) == aSE2[nCnt]
					SE2->(RecLock("SE2",.F.))
					If Empty(SE2->E2_CONTAD) .and. !Empty(SD2->D2_CONTA)
						SE2->E2_CONTAD = SD2->D2_CONTA
					Endif
					If Empty(SE2->E2_CCUSTO) .and. !Empty(SD2->D2_CCUSTO)	
						SE2->E2_CCUSTO = SD2->D2_CCUSTO
					Endif
					If Empty(SE2->E2_CLVL) .and. !Empty(SD2->D2_CLVL)	
						SE2->E2_CLVL = SD2->D2_CLVL
					Endif
					If Empty(SE2->E2_ITEMCTA) .and. !Empty(SD2->D2_ITEMCC)	
						SE2->E2_ITEMCTA = SD2->D2_ITEMCC
					Endif	
					SE2->(MsUnlock())	
				Endif
			Next
		Endif
	Endif
Endif					

aEval(aArea,{|x| RestArea(x)})
	
Return()