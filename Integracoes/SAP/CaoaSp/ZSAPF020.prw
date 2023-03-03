#include 'protheus.ch'
#include 'parmtype.ch'

// rotina chamada pelo ponto de entrada FA050B01
User function ZSAPF020()

Local lRet := .T.
Local aArea := {SE2->(GetArea()),GetArea()}
Local cAliasTrb := GetNextAlias()
Local cAliasTrb1 := GetNextAlias()
Local cQ := ""
Local cChavePai := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
Local aRet := {}
Local cTabSAP := "SE2"
Local cChaveSZ7 := ""
Local lIntSAP := GetMv("CMV_INTSAP",,.T.)
Local lIntSAP20	:= GetMv("CAOASAP20A",,.T.)

// verifica se integracao com SAP estah ativa
If !lIntSAP
	Return(lRet)
Endif

// verifica se deve executar este fonte
If !lIntSAP20
	Return(lRet)
Endif

If U_ZF01GENSAP()
	// carrega titulo principal e de impostos gerados por este
	cQ := "SELECT R_E_C_N_O_ SE2_RECNO "
	cQ += "FROM "+retSQLName("SE2")+" SE2 "
	cQ += "WHERE "
	cQ += "E2_FILIAL = '"+xFilial("SE2")+"' "
	cQ += "AND (SE2.R_E_C_N_O_ = '"+Alltrim(Str(SE2->(Recno())))+"' "
	cQ += "OR E2_TITPAI = '"+cChavePai+"') "
	cQ += "AND SE2.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
	
	While (cAliasTrb)->(!Eof())
		SE2->(dbGoto((cAliasTrb)->SE2_RECNO))

		If !U_ZF01GENSAP()
			(cAliasTrb)->(dbSkip())
			Loop
		Endif
		
		cChaveSZ7 := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA 
		
		// trata o campo de tabela a ser gravado na sz7, pois moeda estrangeira deve gerar como CT2
		//If SE2->E2_TIPO == MVPAGANT .and. !SE2->E2_MOEDA == 1
		If !SE2->E2_MOEDA == 1
		 	If SE2->E2_LA == "S"
		 		cChaveSZ7 := U_ZF02GENSAP(SE2->(Recno()),"SE2")
		 		If Empty(cChaveSZ7)
		 			(cAliasTrb)->(dbSkip())
		 			Loop
		 		Else
		 			cTabSAP := "CT2"
		 		Endif	
		 	Else // nao gera sz7 neste momento, pois como nao estah contabilizado, nao tem a chave da ct2
		 		(cAliasTrb)->(dbSkip())
		 		Loop
		 	Endif	
		Endif
		
		// verifica se tem registro de envio para este titulo
		cQ := "SELECT MAX(R_E_C_N_O_) SZ7_RECNO "
		cQ += "FROM "+retSQLName("SZ7")+" SZ7 "
		cQ += "WHERE "
		cQ += "Z7_FILIAL = '"+xFilial("SZ7")+"' "
		cQ += "AND Z7_XTABELA = '"+cTabSAP+"' "
		cQ += "AND Z7_XCHAVE = '"+cChaveSZ7+"' "
		cQ += "AND Z7_XOPEPRO IN ('1') "
		cQ += "AND Z7_XOPESAP = '1' "
		cQ += "AND SZ7.D_E_L_E_T_ = ' ' "
			
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb1,.T.,.T.)
			
		If (cAliasTrb1)->(!Eof()) .and. !Empty((cAliasTrb1)->SZ7_RECNO)
			SZ7->(dbGoto((cAliasTrb1)->SZ7_RECNO))
			aRet := U_ZF06GENSAP(cTabSAP,cChaveSZ7)
			If !Empty(aRet)
				U_ZF04GENSAP({cTabSAP},aRet[2],aRet[3],"1")
			Endif
		Endif
		(cAliasTrb1)->(dbCloseArea())
			
		(cAliasTrb)->(dbSkip())
	Enddo
	(cAliasTrb)->(dbCloseArea())
Endif

aEval(aArea,{|x| RestArea(x)})

return(lRet)
