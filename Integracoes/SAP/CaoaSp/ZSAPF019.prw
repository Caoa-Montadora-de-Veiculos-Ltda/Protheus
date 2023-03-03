#include 'protheus.ch'
#include 'parmtype.ch'

// rotina chamada pelo ponto de entrada FA050FIN
User function ZSAPF019(nOper)

Local aArea := {SE2->(GetArea()),GetArea()}
Local cChavePai := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
Local cTabSAP := "SE2"
Local cQ := ""
Local cAliasTrb := GetNextAlias()
Local cChaveSZ7 := ""
Local lIntSAP := GetMv("CMV_INTSAP",,.T.)
Local lIntSAP19	:= GetMv("CAOASAP19D",,.T.)

// verifica se integracao com SAP estah ativa
If !lIntSAP
	Return()
Endif

// verifica se deve executar este fonte
If !lIntSAP19
	Return()
Endif

//If IIf((SE2->E2_TIPO == MVPAGANT .and. !SE2->E2_MOEDA == 1),SAP19TitEEC("1"),SAP19TitEEC("0"))
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

		//If !IIf((SE2->E2_TIPO == MVPAGANT .and. !SE2->E2_MOEDA == 1),SAP19TitEEC("1"),SAP19TitEEC("0"))
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
						
		U_ZF11GENSAP(xFilial("SZ7")									,;	// Filial
					cTabSAP			 								,;	// Tabela
					"1"				 								,;	// Indice Utilizado
					cChaveSZ7										,;	// Chave
					IIf(nOper==3,1,IIf(nOper==4,2,1))				,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
					1												,;	// Operação SAP 1=Inclusao;2=cancelamento
					""												,;	// XML Envio
					"P"												,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
					"")													// Retorno
					//{FunName(),"","",nRecSE2,"",0,""})
					
		(cAliasTrb)->(dbSkip())
	Enddo
	(cAliasTrb)->(dbCloseArea())
Endif

aEval(aArea,{|x| RestArea(x)})

return()
			