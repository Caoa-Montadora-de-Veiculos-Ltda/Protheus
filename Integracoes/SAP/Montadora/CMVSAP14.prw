#include 'protheus.ch'
#include 'parmtype.ch'

// rotina chamada pelo ponto de entrada MS520DEL
user function CMVSAP14(cTipo)

Local aArea := {SF6->(GetArea()),GetArea()}
Local cQ := ""
Local cAliasTrb := GetNextAlias()
Local aTab := {}
Local cDoc := ""
Local cSerie := ""
Local nCnt := 0
Local aRet := {}
Local cSerieGnre := ""
Local cDocGnre := ""
Local lIntSAP := GetMv("CMV_INTSAP",,.T.)
Local lIntSAP14	:= GetMv("CAOASAP14A",,.T.)

// verifica se integracao com SAP estah ativa
If !lIntSAP
	Return()
Endif

// verifica se deve executar este fonte
If !lIntSAP14
	Return()
Endif

If cTipo == "0" // saida
	If !Empty(SF2->F2_DUPL)
		aAdd(aTab,"SF2")
	Else
		aAdd(aTab,"CT2")
	Endif
	
	If !Empty(SF2->F2_NFICMST) .or. !Empty(SF2->F2_GNRDIF) 
		/*
		// obs: nao usar seek na sf6, pois registro estah deletado
		SF6->(dbSetOrder(3))
		If SF6->(dbSeek(xFilial("SF6")+"2"+Padr(SF2->F2_TIPO,TamSX3("F6_TIPODOC")[1])+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
			While SF6->(!Eof()) .and. xFilial("SF6")+"2"+Padr(SF2->F2_TIPO,TamSX3("F6_TIPODOC")[1])+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA == ;
			SF6->F6_FILIAL+SF6->F6_OPERNF+SF6->F6_TIPODOC+SF6->F6_DOC+SF6->F6_SERIE+SF6->F6_CLIFOR+SF6->F6_LOJA
				If SF6->F6_NUMERO == SF2->F2_NFICMST
					aAdd(aTab,"SE2")
					Exit
				Endif
				SF6->(dbSkip())
			Enddo
		Endif
		*/
		cQ := "SELECT 1 "
		cQ += "FROM "+retSQLName("SF6")+" SF6, "+retSQLName("SF2")+" SF2 "
		cQ += "WHERE "
		cQ += "SF6.D_E_L_E_T_ = '*' " // OBS: aqui deve ser o registro deletado mesmo da sf6
		cQ += "AND SF2.D_E_L_E_T_ = ' ' "  	
		cQ += "AND F6_FILIAL = '"+xFilial("SF6")+"' "
		cQ += "AND F2_FILIAL = '"+xFilial("SF2")+"' "
		cQ += "AND F6_OPERNF = '2' "
		cQ += "AND F6_TIPODOC = F2_TIPO "
		cQ += "AND F6_DOC = F2_DOC "
		cQ += "AND F6_SERIE = F2_SERIE "
		cQ += "AND F6_CLIFOR = F2_CLIENTE "
		cQ += "AND F6_LOJA = F2_LOJA "
		cQ += "AND (F6_NUMERO = F2_NFICMST "
		cQ += "OR F6_NUMERO = F2_GNRDIF) "
		cQ += "AND SF2.R_E_C_N_O_ = '"+Alltrim(Str(SF2->(Recno())))+"' "
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)

		If (cAliasTrb)->(!Eof())
			aAdd(aTab,"SE2")
			If !Empty(SF2->F2_NFICMST)
				cSerieGnre := Subs(SF2->F2_NFICMST,1,TamSX3("E2_PREFIXO")[1])
				cDocGnre := Subs(SF2->F2_NFICMST,TamSX3("E2_PREFIXO")[1]+1,TamSX3("E2_NUM")[1])
			Elseif !Empty(SF2->F2_GNRDIF)
				cSerieGnre := Subs(SF2->F2_GNRDIF,1,TamSX3("E2_PREFIXO")[1])
				cDocGnre := Subs(SF2->F2_GNRDIF,TamSX3("E2_PREFIXO")[1]+1,TamSX3("E2_NUM")[1])
			Endif	
		Endif
		(cAliasTrb)->(dbCloseArea())
	Endif
	
	cSerie := SF2->F2_SERIE
	cDoc := SF2->F2_DOC
Endif		

If cTipo == "1" // entrada
	If !Empty(SF1->F1_DUPL)
		aAdd(aTab,"SF1")
	Else
		aAdd(aTab,"CT2")
	Endif
	cSerie := SF1->F1_SERIE
	cDoc := SF1->F1_DOC
Endif		

For nCnt:=1 To Len(aTab)
	cQ := "SELECT MAX(R_E_C_N_O_) SZ7_RECNO "
	cQ += "FROM "+retSQLName("SZ7")+" SZ7 "
	cQ += "WHERE "
	cQ += "Z7_FILIAL = '"+xFilial("SZ7")+"' "
	cQ += "AND Z7_XTABELA = '"+aTab[nCnt]+"' "
	If aTab[nCnt] == "SE2" 
		cQ += "AND Z7_SERORI = '"+cSerieGnre+"' "
		cQ += "AND Z7_DOCORI = '"+cDocGnre+"' "
	Else	
		cQ += "AND Z7_SERORI = '"+cSerie+"' "
		cQ += "AND Z7_DOCORI = '"+cDoc+"' "
	Endif	
	cQ += "AND Z7_XOPEPRO IN ('1','2') "
	cQ += "AND Z7_XOPESAP = '1' "
	cQ += "AND SZ7.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
	
	If (cAliasTrb)->(!Eof()) .and. !Empty((cAliasTrb)->SZ7_RECNO)
		SZ7->(dbGoto((cAliasTrb)->SZ7_RECNO))
		aRet := U_ZF06GENSAP(aTab[nCnt],SZ7->Z7_XCHAVE)
		If !Empty(aRet)
			U_ZF04GENSAP({aTab[nCnt]},aRet[2],aRet[3])
		Endif	
	Endif
	(cAliasTrb)->(dbCloseArea())
Next		

aEval(aArea,{|x| RestArea(x)})

return()
