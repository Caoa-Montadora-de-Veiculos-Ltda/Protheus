#include 'protheus.ch'

// rotina chamada pelo ponto de entrada FLTESTLT / VLCPLOTE
User function ZSAPF018()   

Local lRet := .T.
Local aArea := {GetArea()}
Local cAliasTrb := GetNextAlias()
Local cAliasTrb1 := GetNextAlias()
Local cQ := ""
Local lExecuta1 := GetMv("CAOASAP18A",,.T.)
Local lExecuta2 := GetMv("CAOASAP18B",,.T.)
Local lExecuta3 := GetMv("CAOASAP18C",,.T.)
Local cLoteSap := GetMv("CMV_LCTSAP")
Local cRotSap := Alltrim(superGetMv("CAOASAP09A"))
Local dData := IIf(Type("ParamIxb[1]")!="U",ParamIxb[1],CT2->CT2_DATA)
Local cLote := IIf(Type("ParamIxb[2]")!="U",ParamIxb[2],CT2->CT2_LOTE)
Local cSbLote := IIf(Type("ParamIxb[3]")!="U",ParamIxb[3],CT2->CT2_SBLOTE)
Local cDoc := IIf(Type("ParamIxb[4]")!="U",ParamIxb[4],CT2->CT2_DOC)
Local nOpc := IIf(Type("ParamIxb[5]")!="U",ParamIxb[5],0)  
Local lExecOpc := (nOpc == 3 .or. nOpc == 4 .or. nOpc == 5 .or. nOpc == 6 .or. nOpc == 7 .or. nOpc == 0)
Local cMsgLote := ""
Local lIntSAP := GetMv("CMV_INTSAP",,.T.)
Local lIntSAP18	:= GetMv("CAOASAP18D",,.T.)
Local cRotPodeExc := GetMv("CAOASAP18E",,"") // rotinas que podem ser excluidas via lancamento contabil
Local cKey := ""
Local lPosCT2 := IIf(Type("ParamIxb[3]")!="U",.F.,.T.) // indica se ct2 jah estah posicionado
Local nLenSF1 := TamSX3("F1_DOC")[1]+TamSX3("F1_SERIE")[1]+TamSX3("F1_FORNECE")[1]+TamSX3("F1_LOJA")[1]
Local nLenSF2 := nLenSF1

// verifica se integracao com SAP estah ativa
If !lIntSAP
	Return(lRet)
Endif

// verifica se deve executar este fonte
If !lIntSAP18
	Return(lRet)
Endif

//If lExecuta .and. lRet .and. lExecOpc
If lRet .and. lExecOpc
	// exclusao ou estorno por lote
	If FWIsInCallStack("Ct102EstLt")
		cMsgLote := CRLF+"Data Lancto: "+dtoc(dData)+", Lote: "+cLote+", SubLote: "+cSbLote+", Documento: "+cDoc
	Else
		// se for estorno de lancamento sem ser por lote, refaz variaveis do lancamento, para carregar o lancamento posicionado no browse
		If nOpc == 6 
			dData := CT2->CT2_DATA
			cLote := CT2->CT2_LOTE
			cSbLote := CT2->CT2_SBLOTE
			cDoc := CT2->CT2_DOC
		Endif	
	Endif	

	If nOpc == 3 .or. nOpc == 7
		If lExecuta1
			If !(FWIsInCallStack("CTBA280") .or. FWIsInCallStack("U_CMVCTBROF")) // rotinas de rateio off-line padrao e customizado
				If !Alltrim(cLote) == Alltrim(cLoteSap)
					Help("",1,"Lançamento Contábil",,"Inclusão/Cópia manual de lançamento contábil não permitida.",1,0)
					lRet := .F.
				Endif	
			Endif		
		Endif	
	Else
		If Alltrim(cLote) == Alltrim(cLoteSap)
			If lExecuta2
				Help("",1,"Lançamento Contábil",,"Manutenção de lançamento contábil com origem no SAP não permitida.",1,0)
				lRet := .F.
			Endif	
		Else
			If lExecuta3
				// verifica se lancamento integra com o sap
				cQ := "SELECT 1 "
				cQ += "FROM "+RetSqlName("CT2")+" CT2 "
				cQ += "WHERE "
				cQ += "CT2_FILIAL = '"+xFilial("CT2")+"' "
				cQ += "AND CT2_DATA = '"+dTos(dData)+"' "
				cQ += "AND CT2_LOTE = '"+cLote+"' "
				cQ += "AND CT2_SBLOTE = '"+cSbLote+"' "
				cQ += "AND CT2_DOC = '"+cDoc+"' "
				cQ += "AND CT2_ROTINA IN "+FormatIn(cRotSap,"|")+" "
				cQ += "AND CT2_TPSALD = '1' "
				cQ += "AND CT2.D_E_L_E_T_ = ' ' "
				cQ += "AND CT2_ROTINA NOT IN "+FormatIn(cRotPodeExc,"|")+" "
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
		
				If (cAliasTrb)->(!Eof())
					If !lPosCT2
						cKey := GetAdvfVal("CT2","CT2_KEY",xFilial("CT2")+dTos(dData)+cLote+cSbLote+cDoc,1,"")
					Else
						cKey := CT2->CT2_KEY
					Endif
							
					// verifica se lancamento foi enviado ao sap
					cQ := "SELECT MAX(R_E_C_N_O_) SZ7_RECNO "
					cQ += "FROM "+RetSqlName("SZ7")+" SZ7 "
					cQ += "WHERE "
					cQ += "Z7_FILIAL = '"+xFilial("SZ7")+"' "
					cQ += "AND Z7_XTABELA = 'CT2' "
					cQ += "AND Z7_XCHAVE = '"+dTos(dData)+cLote+cSbLote+cDoc+"' "
					cQ += "AND Z7_XSTATUS IN ('A','O') "
					cQ += "AND SZ7.D_E_L_E_T_ = ' ' "

 					// inicia analise para outras tabelas gravadas no sz7
					If cLote == "008810" // notas de entrada
						cQ += "UNION ALL "
						cQ += "SELECT MAX(R_E_C_N_O_) SZ7_RECNO "
						cQ += "FROM "+RetSqlName("SZ7")+" SZ7 "
						cQ += "WHERE "
						cQ += "Z7_FILIAL = '"+xFilial("SZ7")+"' "
						cQ += "AND Z7_XTABELA = 'SF1' "
						cQ += "AND SUBSTR(Z7_XCHAVE,1,"+Alltrim(Str(nLenSF1))+") = '"+Subs(cKey,TamSX3("F1_FILIAL")[1]+1,TamSX3("F1_DOC")[1]+TamSX3("F1_SERIE")[1]+TamSX3("F1_FORNECE")[1]+TamSX3("F1_LOJA")[1])+"' "
						cQ += "AND Z7_XSTATUS IN ('A','O') "
						cQ += "AND SZ7.D_E_L_E_T_ = ' ' "
					Endif

					If cLote == "008820" // notas de saida
						cQ += "UNION ALL "
						cQ += "SELECT MAX(R_E_C_N_O_) SZ7_RECNO "
						cQ += "FROM "+RetSqlName("SZ7")+" SZ7 "
						cQ += "WHERE "
						cQ += "Z7_FILIAL = '"+xFilial("SZ7")+"' "
						cQ += "AND Z7_XTABELA = 'SF2' "
						cQ += "AND SUBSTR(Z7_XCHAVE,1,"+Alltrim(Str(nLenSF2))+") = '"+Subs(cKey,TamSX3("F2_FILIAL")[1]+1,TamSX3("F2_DOC")[1]+TamSX3("F2_SERIE")[1]+TamSX3("F2_CLIENTE")[1]+TamSX3("F2_LOJA")[1])+"' "
						cQ += "AND Z7_XSTATUS IN ('A','O') "
						cQ += "AND SZ7.D_E_L_E_T_ = ' ' "
					Endif	

					If cLote == "008850" // contas a pagar
						cQ += "UNION ALL "
						cQ += "SELECT MAX(R_E_C_N_O_) SZ7_RECNO "
						cQ += "FROM "+RetSqlName("SZ7")+" SZ7 "
						cQ += "WHERE "
						cQ += "Z7_FILIAL = '"+xFilial("SZ7")+"' "
						cQ += "AND Z7_XTABELA = 'SE2' "
						cQ += "AND Z7_XCHAVE = '"+Subs(cKey,TamSX3("E2_FILIAL")[1]+1,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]+TamSX3("E2_FORNECE")[1]+TamSX3("E2_LOJA")[1])+"' "
						cQ += "AND Z7_XSTATUS IN ('A','O') "
						cQ += "AND SZ7.D_E_L_E_T_ = ' ' "
					Endif	

					If cLote == "008850" // contas a pagar - gnre, nao pesquisa pelo campo chave, pois a chave da sz7 contem o numero da nota de saida
						cQ += "UNION ALL "
						cQ += "SELECT MAX(R_E_C_N_O_) SZ7_RECNO "
						cQ += "FROM "+RetSqlName("SZ7")+" SZ7 "
						cQ += "WHERE "
						cQ += "Z7_FILIAL = '"+xFilial("SZ7")+"' "
						cQ += "AND Z7_XTABELA = 'SE2' "
						cQ += "AND Z7_DOCORI = '"+Subs(cKey,TamSX3("E2_FILIAL")[1]+TamSX3("E2_PREFIXO")[1]+1,TamSX3("E2_NUM")[1])+"' "
						cQ += "AND Z7_SERORI = '"+Subs(cKey,TamSX3("E2_FILIAL")[1]+1,TamSX3("E2_PREFIXO")[1])+"' "
						cQ += "AND Z7_CLIFOR = '"+Subs(cKey,TamSX3("E2_FILIAL")[1]+TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]+1,TamSX3("E2_FORNECE")[1])+"' "
						cQ += "AND Z7_LOJA = '"+Subs(cKey,TamSX3("E2_FILIAL")[1]+TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]+TamSX3("E2_FORNECE")[1]+1,TamSX3("E2_LOJA")[1])+"' "
						cQ += "AND Z7_XSTATUS IN ('A','O') "
						cQ += "AND SZ7.D_E_L_E_T_ = ' ' "
					Endif	
					
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb1,.T.,.T.)
					
					While (cAliasTrb1)->(!Eof())
						If !Empty((cAliasTrb1)->SZ7_RECNO)
							Help("",1,"Lançamento Contábil",,"Manutenção de lançamento contábil com envio ao SAP não permitida."+cMsgLote,1,0)
							lRet := .F.
						Endif
						(cAliasTrb1)->(dbSkip())
					Enddo
					
					(cAliasTrb1)->(dbCloseArea())
				Endif
				
				(cAliasTrb)->(dbCloseArea())
			Endif					
		Endif
	Endif
Endif		

aEval(aArea,{|x| RestArea(x)})

return(lRet)
