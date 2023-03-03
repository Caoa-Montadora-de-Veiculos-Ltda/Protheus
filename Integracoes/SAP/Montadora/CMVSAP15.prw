#include 'protheus.ch'
#include 'parmtype.ch'

Static _dVenc := cTod("")

// rotina chamada pelo ponto de entrada F040ALTR / F040FCR / FA040ALT
User function CMVSAP15(nOper)

Local aArea := {GetArea()}
Local cChave := SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
Local cQ := ""
Local cAliasTrb := GetNextAlias()
Local cAliasTrb1 := GetNextAlias()
Local lContinua := .T.
Local nRecSE1 := 0
Local cPrefVei := superGetMv( "CAOASAP17A"	, , "OFI/VEI" )  // prefixos de titulos originados no sigavei
Local lIntSAP := GetMv("CMV_INTSAP",,.T.)
Local lIntSAP15	:= GetMv("CAOASAP15A",,.T.)
Local cLoteInc := ""
Local cFornece := ""
Local cLoja := ""

// verifica se integracao com SAP estah ativa
If !lIntSAP
	Return()
Endif

// verifica se deve executar este fonte
If !lIntSAP15
	Return()
Endif

If SE1->E1_TIPO $ MVPROVIS .and. Alltrim(SE1->E1_PREFORI) $ cPrefVei
	If nOper == 4  // alteracao
		If FWIsInCallStack("U_FA040ALT")
			_dVenc := SE1->E1_VENCTO
			aEval(aArea,{|x| RestArea(x)})
			Return()
		Endif	
		If FWIsInCallStack("U_F040ALTR")
			If _dVenc == SE1->E1_VENCTO // nao houve alteracao de vencimento
				lContinua := .F.
			Else
				lContinua := .T.
			Endif
			_dVenc := cTod("") // zera variavel
		Endif
		
		If !lContinua
			aEval(aArea,{|x| RestArea(x)})
			Return()
		Endif	
	Endif		

	// verifica se este titulo jah estah na sz7
	// esta verificacao eh necessaria, pois deve ser gerado um unico registro na sz7 independente da quantidade de parcelas geradas de titulos provisorios
	cQ := "SELECT SZ7.R_E_C_N_O_ SZ7_RECNO "
	cQ += "FROM "+retSQLName("SZ7")+" SZ7 "
	cQ += "WHERE "
	cQ += "Z7_FILIAL = '"+xFilial("SZ7")+"' "
	cQ += "AND Z7_XTABELA = 'SE1' "
	cQ += "AND SUBSTR(Z7_XCHAVE,1,"+Alltrim(Str(TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]))+") || SUBSTR(Z7_XCHAVE,"+Alltrim(Str(TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+1))+","+Alltrim(Str(TamSX3("E1_TIPO")[1]))+") = '"+Subs(cChave,1,TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1])+Subs(cChave,TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+1,TamSX3("E1_TIPO")[1])+"' "
	If nOper == 3
		cQ += "AND Z7_XOPEPRO IN ('1') "
	Endif	
	If nOper == 4
		cQ += "AND Z7_XOPEPRO IN ('2') "
	Endif	
	cQ += "AND Z7_XOPESAP = '1' "
	cQ += "AND Z7_XSTATUS NOT IN ('N','M') "
	cQ += "AND SZ7.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
	
	If (cAliasTrb)->(Eof())
		If nOper == 3
			nRecSE1 := SE1->(Recno())
		Elseif nOper == 4
			// localiza registro do envio para gerar os dados da alteracao
			cQ := "SELECT Z7_XCHAVE,Z7_RECORI,Z7_XLOTE,Z7_CLIFOR,Z7_LOJA "
			cQ += "FROM "+retSQLName("SZ7")+" SZ7 "
			cQ += "WHERE "
			cQ += "Z7_FILIAL = '"+xFilial("SZ7")+"' "
			cQ += "AND Z7_XTABELA = 'SE1' "
			cQ += "AND SUBSTR(Z7_XCHAVE,1,"+Alltrim(Str(TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]))+") || SUBSTR(Z7_XCHAVE,"+Alltrim(Str(TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+1))+","+Alltrim(Str(TamSX3("E1_TIPO")[1]))+") = '"+Subs(cChave,1,TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1])+Subs(cChave,TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+1,TamSX3("E1_TIPO")[1])+"' "
			cQ += "AND Z7_XOPEPRO IN ('1') "
			cQ += "AND Z7_XOPESAP = '1' "
			cQ += "AND SZ7.D_E_L_E_T_ = ' ' "
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb1,.T.,.T.)
			
			If (cAliasTrb1)->(!Eof())
				cChave := (cAliasTrb1)->Z7_XCHAVE
				nRecSE1 := (cAliasTrb1)->Z7_RECORI
				cLoteInc := (cAliasTrb1)->Z7_XLOTE
				cFornece := (cAliasTrb1)->Z7_CLIFOR
				cLoja := (cAliasTrb1)->Z7_LOJA
			Endif
			(cAliasTrb1)->(dbCloseArea())
		Endif	
			
		U_ZF11GENSAP(xFilial("SZ7")									,;	// Filial
					"SE1"			 								,;	// Tabela
					"2"				 								,;	// Indice Utilizado
					cChave											,;	// Chave
					IIf(nOper==3,1,IIf(nOper==4,2,1))				,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
					1												,;	// Operação SAP 1=Inclusao;2=cancelamento
					""												,;	// XML Envio
					"P"												,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
					""												,;	// Retorno
					{FunName(),"","",nRecSE1,"",0,"",cLoteInc,cFornece,cLoja})
	Endif
	(cAliasTrb)->(dbCloseArea())				
Endif

aEval(aArea,{|x| RestArea(x)})

return()
