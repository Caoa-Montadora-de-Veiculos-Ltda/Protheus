#include 'protheus.ch'
#include 'parmtype.ch'

// rotina chamada pelo ponto de entrada FA040B01
User function CMVSAP16()

Local lRet := .T.
Local aArea := {GetArea()}
Local cAliasTrb := GetNextAlias()
Local cAliasTrb1 := GetNextAlias()
Local cQ := ""
Local cChave := SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
Local aRet := {}
Local cPrefVei := superGetMv( "CAOASAP17A"	, , "OFI/VEI" )  // prefixos de titulos originados no sigavei
Local lIntSAP := GetMv("CMV_INTSAP",,.T.)
Local lIntSAP16	:= GetMv("CAOASAP16A",,.T.)

// verifica se integracao com SAP estah ativa
If !lIntSAP
	Return(lRet)
Endif

// verifica se deve executar este fonte
If !lIntSAP16
	Return(lRet)
Endif

If SE1->E1_TIPO $ MVPROVIS .and. Alltrim(SE1->E1_PREFORI) $ cPrefVei
	// verifica se tem registro de envio para este titulo
	cQ := "SELECT MAX(R_E_C_N_O_) SZ7_RECNO,Z7_XSTATUS "
	cQ += "FROM "+retSQLName("SZ7")+" SZ7 "
	cQ += "WHERE "
	cQ += "Z7_FILIAL = '"+xFilial("SZ7")+"' "
	cQ += "AND Z7_XTABELA = 'SE1' "
	cQ += "AND SUBSTR(Z7_XCHAVE,1,"+Alltrim(Str(TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]))+") || SUBSTR(Z7_XCHAVE,"+Alltrim(Str(TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+1))+","+Alltrim(Str(TamSX3("E1_TIPO")[1]))+") = '"+Subs(cChave,1,TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1])+Subs(cChave,TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+1,TamSX3("E1_TIPO")[1])+"' "
	//cQ += "AND Z7_XOPEPRO IN ('1','2') "
	cQ += "AND Z7_XOPEPRO IN ('1') " // sempre verificar pelo registro de inclusao, ele eh a referencia
	cQ += "AND Z7_XOPESAP = '1' "
	cQ += "AND SZ7.D_E_L_E_T_ = ' ' "
	cQ += "GROUP BY Z7_XSTATUS "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
	
	// este registro nao pode estar com o status = N e M ( que indica que nao serah enviado ao SAP )
	If (cAliasTrb)->(!Eof()) .and. !Empty((cAliasTrb)->SZ7_RECNO) .and. !((cAliasTrb)->Z7_XSTATUS $ "N/M") 
		// verifica se este titulo jah estah na sz7 como cancelamento
		cQ := "SELECT SZ7.R_E_C_N_O_ SZ7_RECNO "
		cQ += "FROM "+retSQLName("SZ7")+" SZ7 "
		cQ += "WHERE "
		cQ += "Z7_FILIAL = '"+xFilial("SZ7")+"' "
		cQ += "AND Z7_XTABELA = 'SE1' "
		cQ += "AND SUBSTR(Z7_XCHAVE,1,"+Alltrim(Str(TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]))+") || SUBSTR(Z7_XCHAVE,"+Alltrim(Str(TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+1))+","+Alltrim(Str(TamSX3("E1_TIPO")[1]))+") = '"+Subs(cChave,1,TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1])+Subs(cChave,TamSX3("E1_CLIENTE")[1]+TamSX3("E1_LOJA")[1]+TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+1,TamSX3("E1_TIPO")[1])+"' "
		cQ += "AND Z7_XOPEPRO = '3' "
		cQ += "AND Z7_XOPESAP = '2' "
		cQ += "AND SZ7.D_E_L_E_T_ = ' ' "
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb1,.T.,.T.)
	
		If (cAliasTrb1)->(Eof())
			SZ7->(dbGoto((cAliasTrb)->SZ7_RECNO))
			aRet := U_ZF06GENSAP("SE1",SZ7->Z7_XCHAVE)
			If !Empty(aRet)
				U_ZF04GENSAP({"SE1"},aRet[2],aRet[3],"2")
			Endif
		Endif	
		(cAliasTrb1)->(dbCloseArea())	
	Endif
	(cAliasTrb)->(dbCloseArea())
Endif

aEval(aArea,{|x| RestArea(x)})

return(lRet)
