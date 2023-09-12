#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TOTVS.ch'
#include "topconn.ch"
#include "apwebsrv.ch"
#include "apwebex.ch"
/* =====================================================================================
Programa.:              ZGENSAPF01
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function SAP19TitEEC(lMoeda1,lAdt) //lTit,lAdt,lTx)
User Function ZF01GENSAP(lMoeda1,lAdt) //lTit,lAdt,lTx)

	Local cOriEEC := GetMv("CAOASAP19A",,"SIGAESS/SIGAEIC/SIGAEFF") // rotinas de origem dos titulos a pagar
	Local cTipoEEC := GetMv("CAOASAP19B",,"NF/INV/TX/DP/PA") // tipos de titulos a considerar
	Local cNatTx := GetMv("CAOASAP19C",,"2305") // naturezas para considerar para os titulos tipo TX
	Local lRet := .T.

	Default lAdt := .F.
	Default lMoeda1 := .F.

	If !(Alltrim(SE2->E2_TIPO) $ cTipoEEC .and. IIf(!FWIsInCallStack("FI400GERPA"),Alltrim(SE2->E2_ORIGEM) $ cOriEEC,.T.))
		lRet := .F.
	Endif

	If lRet
		If lMoeda1
			If !SE2->E2_MOEDA == 1
				lRet := .F.
			Endif
		Endif
	Endif

	If lRet
		// tipo PA soh se for moeda 1
		If lAdt
			If !SE2->E2_TIPO == MVPAGANT
				lRet := .F.
			Endif
		Endif
	Endif

	If lRet
		// tipo TX somente os titulos definidos em parametro
		If SE2->E2_TIPO == MVTAXA .and. !Alltrim(SE2->E2_NATUREZ) $ cNatTx
			lRet := .F.
		Endif
	Endif

Return(lRet)

/* =====================================================================================
Programa.:              ZGENSAPF02
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function SAP19ChvCT2(nRecno,cTabOri)
User Function ZF02GENSAP(nRecno,cTabOri)

	Local aArea := {GetArea()}
	Local cQ := ""
	Local cAliasTrb := GetNextAlias()
	Local cSeq := ""
	Local cRet := ""

	cQ := " SELECT MAX(CT2_SEQUEN) CT2_SEQUEN "
	cQ += " FROM " + RetSqlName("CT2") + " CT2 "
	cQ += " INNER JOIN " + RetSqlName("CV3") + " CV3 "
	cQ += " ON TRIM(CV3.CV3_RECDES) = TRIM(CT2.R_E_C_N_O_) "
	cQ += " AND CV3.D_E_L_E_T_ <> '*' "
	cQ += " AND CT2.D_E_L_E_T_ <> '*' "
	cQ += " WHERE "
	cQ += " CV3.CV3_RECORI = '"+Alltrim(Str(nRecno))+"' "
	cQ += " AND CV3.CV3_TABORI = '"+cTabOri+"' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)

	If (cAliasTrb)->(!Eof()) .and. !Empty((cAliasTrb)->CT2_SEQUEN)
		cSeq := (cAliasTrb)->CT2_SEQUEN
	Endif

	(cAliasTrb)->(dbCloseArea())

	cQ := " SELECT DISTINCT "
	cQ += " CT2_DATA, "
	cQ += " CT2_LOTE, "
	cQ += " CT2_SBLOTE, "
	cQ += " CT2_DOC "
	cQ += " FROM " + RetSqlName("CT2") + " CT2 "
	cQ += " INNER JOIN " + RetSqlName("CV3") + " CV3 "
	cQ += " ON TRIM(CV3.CV3_RECDES) = TRIM(CT2.R_E_C_N_O_) "
	cQ += " AND CV3.D_E_L_E_T_ <> '*' "
	cQ += " AND CT2.D_E_L_E_T_ <> '*' "
	cQ += " WHERE "
	cQ += " CV3.CV3_RECORI = '"+Alltrim(Str(nRecno))+"' "
	cQ += " AND CV3.CV3_TABORI = '"+cTabOri+"' "
	cQ += " AND CT2_SEQUEN = '"+cSeq+"' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)

	If (cAliasTrb)->(!Eof())
		cRet := (cAliasTrb)->CT2_DATA+(cAliasTrb)->CT2_LOTE+(cAliasTrb)->CT2_SBLOTE+(cAliasTrb)->CT2_DOC
	Endif

	(cAliasTrb)->(dbCloseArea())

	aEval(aArea,{|x| RestArea(x)})

return(cRet)

/* =====================================================================================
Programa.:              ZF03GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function zTiraZeros(cTexto)
User Function ZF03GENSAP(cTexto)

Local aArea     := GetArea()
Local cRetorno  := ""
Local lContinua := .T.
Default cTexto  := ""
 
//Pegando o texto atual
cRetorno := Alltrim(cTexto)
 
//Enquanto existir zeros a esquerda
While lContinua
    //Se a priemira posição for diferente de 0 ou não existir mais texto de retorno, encerra o laço
    If SubStr(cRetorno, 1, 1) <> "0" .Or. Len(cRetorno) ==0
        lContinua := .f.
    EndIf
     
    //Se for continuar o processo, pega da próxima posição até o fim
    If lContinua
        cRetorno := Substr(cRetorno, 2, Len(cRetorno))
    EndIf
EndDo
 
RestArea(aArea)
    
Return cRetorno

/* =====================================================================================
Programa.:              ZF04GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function xEstZA7(aTab,cChave,aDadosOri,cIndice)
User Function ZF04GENSAP(aTab,cChave,aDadosOri,cIndice)

Local aArea			:= GetArea()
Local aAreaCT2		:= CT2->(GetArea())

//Local cChvCT2		:= CT2->( CT2_FILIAL + DTOS(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC )//Chave para o Wilhe
//Local cChvSZ7		:= ""
//Local cLote			:= ""
Local nCnt := 1

Default cIndice := "1"

dbSelectArea("SZ7")

//dbSelectArea("CT2")
// nao fazer seek no caso de exclusao, pois o ct2 jah esath deletado e nao serah posicionado
//CT2->(dbSetOrder(1))//CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC

//If CT2->(dbSeek(cChvCT2))

//cChvSZ7 := CT2->( DTOS(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC )

For nCnt:=1 To Len(aTab)
	U_ZF11GENSAP(   xFilial("SZ7"),; //Filial
                    aTab[nCnt]			 ,;	//Tabela
                    cIndice				 ,;	//Indice Utilizado
                    cChave				 ,;	//Chave
                    3					 ,;	//Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
                    2				 	,;	//Operação SAP 1=Inclusao;2=cancelamento
                    ,;
                    ,;
                    ,;
                    aDadosOri)
Next

//EndIf

RestArea(aAreaCT2)
RestArea(aArea)

Return()

/* =====================================================================================
Programa.:              ZF05GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function OperIntSAP(nOpc)
User Function ZF05GENSAP(nOpc)

Local aArea := {SZ7->(GetArea()),SE2->(GetArea()),SF1->(GetArea()),SF2->(GetArea()),GetArea()}
Local cQ := ""
Local aRet := {{},"",{},nOpc}
Local lSF1 := IIf(CT2->CT2_LP $ "650/655",.T.,.F.)
Local lSF2 := IIf(CT2->CT2_LP $ "610/630",.T.,.F.)
Local lCT2 := IIf(!CT2->CT2_LP $ "610/650/630/655/510/515/513/514/511/512",.T.,.F.) .and. !Subs(CT2->CT2_LP,1,1) == "5"
Local lSE2 := IIf(CT2->CT2_LP $ "510/515/513/514/511/512",.T.,.F.)
Local lSE1 := IIf(CT2->CT2_LP $ "501/502",.T.,.F.)
Local cAliasTrb := GetNextAlias()
Local lValidGnre := .T.
Local cChaveGnre := ""
Local lSE2Found := .F.
Local cTiposFin := GetMv("CAOASAP12D",,"NF/DP")
Local cKey := ""

// protecao para quando eh um estorno de lancamento via integracao com outros modulos, e a variavel nOpc vem como 3 ( como se fosse uma inclusao )
// neste caso, forca a variavel nOpc para 6, como se fosse um estorno
If !nOpc == 6
//EICPS400
//EECAF500
	If Select("TMP") > 0 .and. TMP->(FieldPos("CT2_HIST")) > 0 .and. Subs(TMP->CT2_HIST,1,4) == "EST."
		//nOpc := 6
		aEval(aArea,{|x| RestArea(x)})
		Return(aRet)
	Endif
Endif	

// desabilitar a inclusao do estorno do lancamento, pois ele estah sendo gerado como se fosse uma inclusao de lancamento e nao uma exclusao e preciso que seja incluido como uma exclusao
If !nOpc == 6 .and. Subs(CT2->CT2_HIST,1,4) == "EST."
	// exclusao de nota de entrada, saida, classificacao da nfe, financeiro, força para tratar como uma exclusao
	If (FWIsInCallStack("MATA140") .or. FWIsInCallStack("MATA103") .or. FWIsInCallStack("MATA520") .or. FWIsInCallStack("FINA050") .or. FWIsInCallStack("FINA040") .or. FWIsInCallStack("GFEA065") .or. FWIsInCallStack("MATA116")) .and. nOpc == 3
		nOpc := 6
		aRet[4] := 6
	Endif	

	If FWIsInCallStack("CTBA102") // 28/09/19
		aEval(aArea,{|x| RestArea(x)})
		Return(aRet)
	Endif	
Endif	

// excessoes da regra
// PA com moeda 1, gera como SE2
If Subs(CT2->CT2_ORIGEM,1,7) $ "501-001/501-002"
	lSE1 := .T.
	lCT2 := .F.
	lValidGnre := .F.
Endif

// PA com moeda 1, gera como SE2
If Subs(CT2->CT2_ORIGEM,1,7) $ "513-001/513-002/514-001/514-002"
	lSE2 := .T.
	lCT2 := .F.
	lValidGnre := .F.
Endif	

// PA com moeda estrangeira, gera como CT2
If Subs(CT2->CT2_ORIGEM,1,7) $ "513-003/513-004/514-003/514-004"
	lSE2 := .F.
	lCT2 := .T.
Endif	
		
// LP 530, gera como CT2
If CT2->CT2_LP == "530"
	lSE2 := .F.
	lCT2 := .T.
Endif	
//	

// titulos do sigaeic ( sem ser PA ) com moeda 2, devem ser CT2
If CT2->CT2_LP $ "510/511"
	If Subs(CT2->CT2_KEY,1,TamSX3("E2_FILIAL")[1]+TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]+TamSX3("E2_FORNECE")[1]+TamSX3("E2_LOJA")[1]) == ;
	SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
		lSE2Found := .T.
	Else	
		SE2->(dbSetOrder(1))
		If SE2->(dbSeek(Subs(CT2->CT2_KEY,1,TamSX3("E2_FILIAL")[1]+TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]+TamSX3("E2_FORNECE")[1]+TamSX3("E2_LOJA")[1])))
			lSE2Found := .T.
		Endif
	Endif
	If lSE2Found
		If !SE2->E2_MOEDA == 1 .and. U_ZF01GENSAP()
			lSE2 := .F.
			lCT2 := .T.
		Endif
	Endif
Endif
// ate aqui, excessoes da regra

If nOpc == 3
	If lSE2
		If lValidGnre
			cQ := " SELECT SF6.*" 																									+ CRLF
			cQ += " FROM		" + retSQLName("SE2") + " SE2"																	+ CRLF
			cQ += " INNER JOIN"																								+ CRLF
			cQ += " 	("																										+ CRLF
			cQ += " 		SELECT MAX(SUBCV3.R_E_C_N_O_), SUBCV3.CV3_RECORI, SUBCV3.CV3_TABORI, SUBCV3.CV3_FILIAL, CV3_RECDES"	+ CRLF
			cQ += " 		FROM " + retSQLName("CV3") + " SUBCV3"																+ CRLF
			cQ += " 		WHERE"																								+ CRLF
			cQ += " 			SUBCV3.CV3_TABORI	=	'SE2'"																	+ CRLF
			cQ += " 		AND	SUBCV3.CV3_FILIAL	=	'" + xFilial("CV3") + "'"												+ CRLF
			cQ += " 		AND	SUBCV3.D_E_L_E_T_	<>	'*'"																	+ CRLF
			cQ += " 		GROUP BY SUBCV3.CV3_RECORI, SUBCV3.CV3_TABORI, SUBCV3.CV3_FILIAL, CV3_RECDES"						+ CRLF
			cQ += " 	) CV3"																									+ CRLF
			cQ += " ON"																										+ CRLF
			cQ += " 		TRIM(CV3_RECORI)	=	TRIM(SE2.R_E_C_N_O_)"																	+ CRLF
			cQ += " 	AND	CV3_TABORI	=	'SE2'"																			+ CRLF
			cQ += " 	AND	CV3_FILIAL	=	'" + xFilial("CV3") + "'"														+ CRLF
			cQ += " INNER JOIN	" + retSQLName("CT2") + " CT2"																	+ CRLF
			cQ += " ON"																										+ CRLF
			cQ += " 		TRIM(CT2.R_E_C_N_O_)	=	TRIM(CV3_RECDES)"																	+ CRLF
			cQ += " 	AND	CT2_FILIAL	=	'" + xFilial('CT2') + "'"														+ CRLF
			cQ += " 	AND	CT2.D_E_L_E_T_	<>	'*'"																			+ CRLF
			cQ += " INNER JOIN	" + retSQLName("SF6") + " SF6"																											+ CRLF
			cQ += " ON"																															+ CRLF
			cQ += " 		F6_OPERNF	= 	'2'"																						+ CRLF
			cQ += " 	AND F6_NUMERO	= E2_PREFIXO || E2_NUM"																						+ CRLF
			cQ += " 	AND	F6_FILIAL	=	'" + xFilial("SF6") + "'"																			+ CRLF
			cQ += " 	AND	SF6.D_E_L_E_T_	<>	'*'"																								+ CRLF
			cQ += " WHERE"																										+ CRLF
			cQ += " 		SE2.R_E_C_N_O_	=	'" + allTrim( str( SE2->( RECNO() ) ) ) + "'"									+ CRLF
			cQ += " 	AND	E2_EMIS1  	<>	' '"																			+ CRLF
			cQ += " 	AND	E2_TIPO		=	'TX'"																							+ CRLF
			cQ += " 	AND E2_FILIAL	=	'" + xFilial('SE2') + "'"														+ CRLF
			cQ += " 	AND	SE2.D_E_L_E_T_	<>	'*'"																			+ CRLF
			
			//memoWrite( "C:\TEMP\ZSAPF009.txt", cQ )
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
			
			cChaveGnre := (cAliasTrb)->F6_CLIFOR+(cAliasTrb)->F6_LOJA+(cAliasTrb)->F6_DOC+(cAliasTrb)->F6_SERIE+Subs((cAliasTrb)->F6_TIPODOC,1,TamSX3("F2_TIPO")[1])
			
			(cAliasTrb)->(dbCloseArea())
		Endif	
	Endif
	
	If lSF2
		If !SF2->F2_TIPO $ ("D/B") .and. !Empty(SF2->F2_DUPL) .and. U_ZF21GENSAP("R",SF2->F2_SERIE+SF2->F2_DUPL+SF2->F2_CLIENTE+SF2->F2_LOJA,cTiposFin)
			aAdd(aRet[1],"SF2")
			aRet[2] := SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO)
		Elseif SF2->F2_TIPO == "D" .and. !Empty(SF2->F2_DUPL) .and. U_ZF21GENSAP("P",SF2->F2_SERIE+SF2->F2_DUPL+SF2->F2_CLIENTE+SF2->F2_LOJA,"NDF")
			aAdd(aRet[1],"SF2")
			aRet[2] := SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO)
		Elseif !SF2->F2_TIPO $ ("D/B") .and. Empty(SF2->F2_DUPL) .and. (FWIsInCallStack("VEIA060") .or. ; // rotina de faturamento do sigavei, gera a nota de saida mas nao grava o campo f2_dupl antes da contabilizacao, o campo f2_dupl eh gravado somente depois da contabilizacao	
			U_ZF21GENSAP("R",SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA,cTiposFin)) // contabilização offline para casos onde gerou duplicata e esta com o campo f2_dupl vazio
			aAdd(aRet[1],"SF2")
			aRet[2] := SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO)
		Else
			aAdd(aRet[1],"CT2")
			aRet[2] := CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)
		Endif
	Endif
	
	If lSF1 
		If !SF1->F1_TIPO $ ("D/B") .and. !Empty(SF1->F1_DUPL) .and. U_ZF21GENSAP("P",SF1->F1_SERIE+SF1->F1_DUPL+SF1->F1_FORNECE+SF1->F1_LOJA,Alltrim(MVNOTAFIS))
			aAdd(aRet[1],"SF1")
			aRet[2] := SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL+F1_TIPO)
		Elseif SF1->F1_TIPO == "D" .and. !Empty(SF1->F1_DUPL) .and. U_ZF21GENSAP("R",SF1->F1_SERIE+SF1->F1_DUPL+SF1->F1_FORNECE+SF1->F1_LOJA,"NCC")
			aAdd(aRet[1],"SF1")
			aRet[2] := SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL+F1_TIPO)
		Else
			aAdd(aRet[1],"CT2")
			aRet[2] := CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)
		Endif
	Endif
	
	If lCT2
		aRet[2] := CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)
		aAdd(aRet[1],"CT2")
	Endif

    //Tituloa Receber usado para RA
    If lSE1 .and. !Empty(cChaveGnre)
		SE1->(dbSetOrder(2))
		If SE1->(!dbSeek(xFilial("SF2")+cChaveGnre))
			aEval(aArea,{|x| RestArea(x)})
			Return(aRet)
		Endif
		aAdd(aRet[1],"SE1")
		aRet[2] := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
	Elseif lSE1
		// posiciona no titulo para verificar a origem e tipo
		IF SE1->E1_TIPO = 'RA ' .AND. SE2->E2_MOEDA == 1           //If U_ZF01GENSAP()
			aAdd(aRet[1],"SE1")
			aRet[2] := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+E1_CLIENTE+E1_LOJA
		Endif
	Endif
	
	If lSE2 .and. !Empty(cChaveGnre)
		SF2->(dbSetOrder(2))
		If SF2->(!dbSeek(xFilial("SF2")+cChaveGnre))
			aEval(aArea,{|x| RestArea(x)})
			Return(aRet)
		Endif
		aAdd(aRet[1],"SE2")
		aRet[2] := SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO)
	Elseif lSE2
		// posiciona no titulo para verificar a origem e tipo
		If U_ZF01GENSAP()
			aAdd(aRet[1],"SE2")
			aRet[2] := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
		Endif
	Endif
Endif

If nOpc == 5 .or. nOpc == 6
	// para sf1 e sf2, verifica se tem registro na sz7 relacionado a tabela ct2, neste caso eh documento sem financeiro
	If lSF1 .or. lSF2
		cQ := "SELECT MAX(R_E_C_N_O_) SZ7_RECNO "
		cQ += "FROM "+retSQLName("SZ7")+" SZ7 "
		cQ += "WHERE "
		cQ += "Z7_FILIAL = '"+xFilial("SZ7")+"' "
		cQ += "AND Z7_XTABELA = 'CT2' "
		cQ += "AND Z7_XCHAVE = '"+CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)+"' "
		cQ += "AND Z7_XOPEPRO <> '3' "
		cQ += "AND Z7_XOPESAP = '1' "
		cQ += "AND SZ7.D_E_L_E_T_ = ' ' "
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
		
		If (cAliasTrb)->(!Eof()) .and. !Empty((cAliasTrb)->SZ7_RECNO)
			lSF1 := .F.
			lSF2 := .F.
			lCT2 := .T.
		Endif
		(cAliasTrb)->(dbCloseArea())
	Endif			
	
	If lSF1
		aRet := U_ZF06GENSAP("SF1",Subs(CT2->CT2_KEY,TamSX3("F1_FILIAL")[1]+1,TamSX3("F1_DOC")[1]+TamSX3("F1_SERIE")[1]+TamSX3("F1_FORNECE")[1]+TamSX3("F1_LOJA")[1]),nOpc)
	Endif
	
	If lSF2
		cKey := CT2->CT2_KEY
		If Empty(cKey)
			cKey := U_ZF22GENSAP("610",CT2->CT2_DATA,CT2->CT2_SEQUEN)
		Endif
		If !Empty(cKey)
			aRet := U_ZF06GENSAP("SF2",Subs(cKey,TamSX3("F2_FILIAL")[1]+1,TamSX3("F2_DOC")[1]+TamSX3("F2_SERIE")[1]+TamSX3("F2_CLIENTE")[1]+TamSX3("F2_LOJA")[1]),nOpc)
		Endif	
	Endif

    //Gravar daos originais p/ título a receber de RA
    If lSE1
		/*If Subs(CT2->CT2_KEY,TamSX3("E1_FILIAL")[1]+1,TamSX3("E1_PREFIXO")[1]) == "ICM" // titulos de gnre
			aRet := U_ZF06GENSAP("SE1",Subs(CT2->CT2_KEY,TamSX3("E1_FILIAL")[1]+1,TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]),nOpc)
		Else // demais titulos RA
			aRet := U_ZF06GENSAP("SE1",Subs(CT2->CT2_KEY,TamSX3("E1_FILIAL")[1]+1,TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+TamSX3("E1_TIPO")[1]+TamSX3("E1_FORNECE")[1]+TamSX3("E1_LOJA")[1]),nOpc)
		Endif*/
	Endif
	
	If lSE2
		If Subs(CT2->CT2_KEY,TamSX3("E2_FILIAL")[1]+1,TamSX3("E2_PREFIXO")[1]) == "ICM" // titulos de gnre
			aRet := U_ZF06GENSAP("SE2",Subs(CT2->CT2_KEY,TamSX3("E2_FILIAL")[1]+1,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]),nOpc)
		Else // demais titulos
			aRet := U_ZF06GENSAP("SE2",Subs(CT2->CT2_KEY,TamSX3("E2_FILIAL")[1]+1,TamSX3("E2_PREFIXO")[1]+TamSX3("E2_NUM")[1]+TamSX3("E2_PARCELA")[1]+TamSX3("E2_TIPO")[1]+TamSX3("E2_FORNECE")[1]+TamSX3("E2_LOJA")[1]),nOpc)
		Endif	
	Endif
	
	If lCT2
		aRet := U_ZF06GENSAP("CT2",CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC),nOpc)
	Endif
Endif

aEval(aArea,{|x| RestArea(x)})

Return(aRet)


/* =====================================================================================
Programa.:              ZF06GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function RecEnvSZ7(cTab,cKey,nOpc)
User Function ZF06GENSAP(cTab,cKey,nOpc)

Local aArea := {SZ7->(GetArea()),GetArea()}
Local cQ := ""
Local cAliasTrb := GetNextAlias()
Local aRet := {} //{{},"",{}}
Local nLen := 0

Default nOpc := 3

aRet := {{},"",{},nOpc}

If cTab == "SE2" .and. !IsInCallStack("MATA520")
	cQ := "SELECT F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,F2_FORMUL,F2_TIPO "
	cQ += "FROM "+retSQLName("SF2")+" SF2 "
	cQ += "WHERE "
	cQ += "F2_FILIAL = '"+xFilial("SF2")+"' "
	cQ += "AND (F2_NFICMST = '"+cKey+"' "
	cQ += "OR F2_GNRDIF = '"+cKey+"') "
	cQ += "ORDER BY SF2.R_E_C_N_O_ "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
	
	While (cAliasTrb)->(!Eof())
		cKey := (cAliasTrb)->F2_DOC+(cAliasTrb)->F2_SERIE+(cAliasTrb)->F2_CLIENTE+(cAliasTrb)->F2_LOJA+(cAliasTrb)->F2_FORMUL+(cAliasTrb)->F2_TIPO
		(cAliasTrb)->(dbSkip())
	Enddo
	(cAliasTrb)->(dbCloseArea())

Endif

nLen := Len(cKey)

cQ := "SELECT MAX(R_E_C_N_O_) SZ7_RECNO "
cQ += "FROM "+retSQLName("SZ7")+" SZ7 "
cQ += "WHERE "
cQ += "Z7_FILIAL = '"+xFilial("SZ7")+"' "
cQ += "AND Z7_XTABELA = '"+cTab+"' "
cQ += "AND LPAD(Z7_XCHAVE,"+Alltrim(Str(nLen))+") = '"+cKey+"' "
cQ += "AND Z7_XOPEPRO IN ('1') " // sempre verificar pelo registro de inclusao, ele eh a referencia
cQ += "AND SZ7.D_E_L_E_T_ = ' ' "
		
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
		
If (cAliasTrb)->(!Eof()) .and. !Empty((cAliasTrb)->SZ7_RECNO) 
	SZ7->(dbGoto((cAliasTrb)->SZ7_RECNO))
	// ultima operacao da sz7 nao pode ser exclusao ao sap
	// tem que ter o campo de xml jah preenchido, pois se o campo xml estiver em branco, a exclusao nao conseguirah buscar o xml do envio, para copiar o mesmo conteudo
	aAdd(aRet[1],SZ7->Z7_XTABELA)
	aRet[2] := SZ7->Z7_XCHAVE
	If !Empty(SZ7->Z7_XXML)
		aRet[3] := {SZ7->Z7_ORIGEM,SZ7->Z7_DOCORI,SZ7->Z7_SERORI,SZ7->Z7_RECORI,"",0,SZ7->Z7_TIPONF,SZ7->Z7_XLOTE,SZ7->Z7_CLIFOR,SZ7->Z7_LOJA}
	Else
		aRet[3] := {SZ7->Z7_ORIGEM,SZ7->Z7_DOCORI,SZ7->Z7_SERORI,SZ7->Z7_RECORI,"N",SZ7->(Recno()),SZ7->Z7_TIPONF,SZ7->Z7_XLOTE,SZ7->Z7_CLIFOR,SZ7->Z7_LOJA}
	Endif		
Endif
(cAliasTrb)->(dbCloseArea())

aEval(aArea,{|x| RestArea(x)})

Return(aRet)

/* =====================================================================================
Programa.:              ZF07GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function FormatDocSAP(cDoc)
User Function ZF07GENSAP(cDoc)

Local nCnt := 0
Local lIsDigit := .T.

For nCnt := 1 To Len(cDoc)
	If !IsDigit(Subs(cDoc,nCnt,1))
		lIsDigit := .F.
		Exit
	Endif
Next

If lIsDigit
	cDoc := Alltrim(Str(Val(cDoc)))
Endif

Return(cDoc)

/* =====================================================================================
Programa.:              ZF08GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function VerAutNf(cEsp,cChave,cAut,cDoc,cSerie)
User Function ZF08GENSAP(cEsp,cChave,cAut,cDoc,cSerie)

Local lRet := .T.

If Alltrim(cEsp) == allTrim(superGetMv("CAOASAP03K",,"SPED"))
	If !(!Empty(cChave) .and. cAut == "S")
		lRet := .F.
		Help("",1,"Envio movimento SAP",,"Nota Fiscal não autorizada na Sefaz. NF :"+Alltrim(cDoc)+"/"+Alltrim(cSerie),1,0)
	Endif
Endif

Return(lRet)

/* =====================================================================================
Programa.:              ZF09GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function VerAutNf(cEsp,cChave,cAut,cDoc,cSerie,cFilLoc,cCliFor,cLoja,lDelete)
User Function ZF09GENSAP(cEsp,cChave,cAut,cDoc,cSerie,cFilLoc,cCliFor,cLoja,lDelete)

Local lRet := .T.
Local aArea := GetArea()
Local dDtCancel := SToD("  /  /  ")

	Default cFilLoc := ""
	Default cCliFor := ""
	Default cLoja   := ""
	Default lDelete := .F.

	IF lDelete
		dbSelectArea('SF3')
		SF3->(DbSetOrder(4))
		if SF3->(DBSEEK(cFilLoc + cCliFor + cLoja + cDoc + cSerie ) )
			cChave := SF3->F3_CHVNFE
			dDtCancel := SF3->F3_DTCANC
		ENDIF

	ENDIF

	If Alltrim(cEsp) == allTrim(superGetMv("CAOASAP03K",,"SPED")) .and. Empty(dDtCancel)
		If Empty(cChave) .and. cAut <> "S"
			lRet := .F.
			Help("",1,"Envio movimento SAP",,"Nota Fiscal não autorizada na Sefaz. NF :"+Alltrim(cDoc)+"/"+Alltrim(cSerie),1,0)
		Endif
	Endif

	RestArea(aArea)

Return(lRet)

/* =====================================================================================
Programa.:              ZF10GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function IncSZ7Cad(cTab,cChave,cCmpCodSap,nOper)
User Function ZF10GENSAP(cTab,cChave,cCmpCodSap,nOper)

Local _cFilial  := ""
Local aArea     := {SZ7->(GetArea()),GetArea()}
Local lContinua := .T.
Local cQ        := ""
Local cAliasTrb := GetNextAlias()
Local cPref     := ""

IF FWCodEmp() = '2010' 
	_cFilial := '2010022001'
ELSEIF FWCodEmp() = '2020' 
	_cFilial := '2020012001'
ENDIF

If Empty(cChave) // protecao para o caso do registro vir em eof() ou bof()
	lContinua := .F.
Endif
	
If lContinua
	If cTab == "SA1" .and. !IsInCallStack("MATA030")
		lContinua := .F.
	Endif
Endif		

If lContinua
	If cTab == "SA2" .and. !IsInCallStack("MATA020")
		lContinua := .F.
	Endif
Endif	

If cTab == "SA1"
	cPref := "A1_"
Elseif cTab == "SA2"
	cPref := "A2_"
Endif
 	
// cliente/fornecedor exportacao nao vai para o sap
If lContinua	
	If &('(cTab)->'+&('cPref+"TIPO"')) == "X"
		lContinua := .F.
	Endif
Endif		

// inclusao com campo de codigo sap preenchido nao vai para o sap, pois eh inclusao via carga de dados
If lContinua	
	If nOper == 3
		If !Empty(&('(cTab)->'+&('cCmpCodSap')))
			lContinua := .F.
		Endif
	Endif		
Endif		

If lContinua
	// verifica se tem algum registro pendente de envio ao sap
	cQ := "SELECT SZ7.R_E_C_N_O_ SZ7_RECNO "
	cQ += "FROM "+RetSQLName("SZ7")+" SZ7 "
	cQ += "WHERE "
	//cQ += "Z7_FILIAL = '"+xFilial(cTab)+"' " // obs: nao colocar a filial para cliente e fornecedor, pois estao compartilhados
	cQ += "Z7_XTABELA = '"+cTab+"' "
	cQ += "AND Z7_XCHAVE = '"+cChave+"' "
	cQ += "AND Z7_XOPEPRO = '"+IIf(Type("Inclui")<>"U" .and. Inclui,"1",IIf(Type("Altera")<>"U" .and. Altera,"2","1"))+"' "
	cQ += "AND Z7_XOPESAP = '1' "
	cQ += "AND Z7_XSTATUS NOT IN ('O','N','M') "
	cQ += "AND SZ7.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
	
	If (cAliasTrb)->(!Eof())
		lContinua := .F.
	Endif
	
	(cAliasTrb)->(dbCloseArea())	

	If lContinua
        //Mandar a filial fixa, pois na rotina de retorno, ZSAPF006, para cliente e fornecedor a filial estah fixa no retorno, pois como os cadastros sao compartilhados por filial, estah sendo gravado uma filial apenas para o registro aparecer na consulta padrao, uma vez que a tabela sz7 eh exclusiva por filial

		U_ZF11GENSAP(   _cFilial/*xFilial("SZ7")*/,;	
                        cTab			 								,;	// Tabela
                        "1"				 								,;	// Indice Utilizado
                        cChave											,;	// Chave
                        IIf(Type("Inclui")<>"U" .and. Inclui,1,IIf(Type("Altera")<>"U" .and. Altera,2,1))								,;	// Operação Protheus 1=Inclusao/2=Alteração/3=exclusao
                        1												,;	// Operação SAP 1=Inclusao;2=cancelamento
                        ""												,;	// XML Envio
                        "P"												,;	// Status - P=Pendente;A=Aguardando;O=OK;E=Erro
                        ""												,;	// Retorno
                        {FunName(),"","",(cTab)->(Recno()),"",0,"","","",""})
	Endif
Endif

aEval(aArea,{|x| RestArea(x)})

Return()

/* =====================================================================================
Programa.:              ZF11GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function xC99IEN(cxFil,cTab,cIndice,cChave,nOperPro,nOperSAP,cXMLSZ7,cStatusSZ7,cRetSZ7,aDadosOri)
User Function ZF11GENSAP(cxFil,cTab,cIndice,cChave,nOperPro,nOperSAP,cXMLSZ7,cStatusSZ7,cRetSZ7,aDadosOri)

    Local aArea 	:= GetArea()
    Local aAreaSZ7	:= SZ7->(GetArea())
    Local cLote		:= ""
    Local cSequen	:= ""
    Local lNaoProcEnvio := .F.
    //Local cUltStatus := ""
    Local aOcor := {}
    Local nOperSZ7 := 0
    Local nRecStatusExc := 0
	Local _cEmp    := FWCodEmp()

    Default cXMLSZ7		:= ""
    Default cRetSZ7		:= ""
    Default cStatusSZ7	:= "P"
    Default aDadosOri := {}

    // verifica se jah tem registro de inclusao pendente ainda, nos status pendente, aguardando ou erro, pois nestes status ainda nao foi finalizado o envio deste registro
    SZ7->(dbSetOrder(2))
    If SZ7->(dbSeek(cxFil+cTab+cChave))
        While SZ7->(!Eof()) .and. cxFil+cTab+Alltrim(cChave) == SZ7->Z7_FILIAL+SZ7->Z7_XTABELA+Alltrim(SZ7->Z7_XCHAVE)
        
            nOperSZ7 := SZ7->Z7_XOPEPRO
            SZ7->(dbSkip())
        Enddo
        // se o ultimo registro estiver com status N e for exclusao tb nao grava novo registro
        // a verificacao do status N deve ser feita somente se for o ultimo registro, pois pode haver de ter varias inclusoes e exclusoes para a mesma chave
        // e somente deve ser valido se o status N for para o ultimo registro
        If nOperSZ7 == nOperPro .and. !(cTab $ "SA1/SA2") //(cUltStatus == "N" .and. nOperSAP == 2) // cliente/fornecedor pode enviar o mesmo registro N vezes
            SZ7->(RestArea(aAreaSZ7))
            RestArea(aArea)

            Return()
        Endif
    Endif

    If cStatusSZ7 == "E" .and. !Empty(cRetSZ7)
        aOcor := U_ZF24GENSAP(cRetSZ7)
    Endif

    If SZ7->(RecLock("SZ7",.T.))

        cLote 	:= GetSxeNum("SZ7","Z7_XLOTE")
        cSequen	:= U_ZF20GENSAP(cxFil , cTab , cChave)
        If nOperSAP == 2//Cancelamento
            SZ7->Z7_XXML := U_ZF23GENSAP(cxFil,cTab,cChave)
        EndIf

        SZ7->Z7_FILIAL 	:= cxFil
        SZ7->Z7_XLOTE 	:= cLote
        SZ7->Z7_XTABELA := cTab
        SZ7->Z7_XINDICE := cIndice
        SZ7->Z7_XCHAVE 	:= cChave
        SZ7->Z7_XSEQUEN := cSequen
        SZ7->Z7_XSTATUS := cStatusSZ7 //IIf(FWIsInCallStack("xBaixTit"),"O",cStatusSZ7)
        SZ7->Z7_XOPEPRO	:= nOperPro //1=Inclusao/2=Alteracao/3=Exclusao
        SZ7->Z7_XOPESAP	:= nOperSAP //1=Inclusao/2=Cancelamento
        SZ7->Z7_XDTINC	:= dDataBase
        SZ7->Z7_XHRINC	:= Time()
		If _cEmp == "2010" //Executa o p.e. Anapolis.
     		SZ7->Z7_ORIGEM  := IIf(IsInCallStack("MATA020") .or. IsInCallStack("MATA030"),FunName(),IIf(Len(aDadosOri) > 1 .and. !Empty(aDadosOri[1]),aDadosOri[1],IIf(FWIsInCallStack("xBaixTit"),"CMVSAP06",IIf(FWIsInCallStack("FINA040"),"FINA040",IIf(FWIsInCallStack("FINA050"),"FINA050",CT2->CT2_ROTINA)))))
   		Else
     		SZ7->Z7_ORIGEM  := IIf(IsInCallStack("MATA020") .or. IsInCallStack("MATA030"),FunName(),IIf(Len(aDadosOri) > 1 .and. !Empty(aDadosOri[1]),aDadosOri[1],IIf(FWIsInCallStack("xBaixTit"),"ZSAPF006",IIf(FWIsInCallStack("FINA040"),"FINA040",IIf(FWIsInCallStack("FINA050"),"FINA050",CT2->CT2_ROTINA)))))
   		EndIf
        SZ7->Z7_LOTEINC := IIf(!Empty(aDadosOri) .and. Len(aDadosOri) > 7,aDadosOri[8],"")

        If !Empty(aOcor)
            If aOcor[2] == "1" // erro protheus
                SZ7->Z7_ERROPRO := aOcor[1]
            Elseif aOcor[2] == "2" // erro sap
                SZ7->Z7_ERROSAP := aOcor[1]
            Endif
        Endif

        If IsInCallStack("CTBANFS") .or. IsInCallStack("MATA460") .or. IsInCallStack("MATA460A") .or. IsInCallStack("MATA460B") .or. IsInCallStack("MaPvlNfs") .or. IsInCallStack("MaPvlNfs2")
            SZ7->Z7_DOCORI := SF2->F2_DOC
            SZ7->Z7_SERORI := SF2->F2_SERIE
            If (Len(aDadosOri) > 1 .and. Empty(aDadosOri[4])) .or. Empty(aDadosOri)
                SZ7->Z7_RECORI := SF2->(Recno())
            Endif
            SZ7->Z7_TIPONF := SF2->F2_TIPO
            SZ7->Z7_CLIFOR := SF2->F2_CLIENTE
            SZ7->Z7_LOJA := SF2->F2_LOJA
        Elseif IsInCallStack("CTBANFE") .or. IsInCallStack("MATA103") .or. IsInCallStack("GFEA065") .or. IsInCallStack("MATA140") .or. IsInCallStack("MATA116")
            SZ7->Z7_DOCORI := SF1->F1_DOC
            SZ7->Z7_SERORI := SF1->F1_SERIE
            If (Len(aDadosOri) > 1 .and. Empty(aDadosOri[4])) .or. Empty(aDadosOri)
                SZ7->Z7_RECORI := SF1->(Recno())
            Elseif Len(aDadosOri) > 1 .and. !Empty(aDadosOri[4])
                SZ7->Z7_RECORI := aDadosOri[4]
            Endif
            SZ7->Z7_TIPONF := SF1->F1_TIPO
            SZ7->Z7_CLIFOR := SF1->F1_FORNECE
            SZ7->Z7_LOJA := SF1->F1_LOJA
        Elseif cTab == "SE2" .and. !FWIsInCallStack("xBaixTit") .and. !nOperPro == 3
            SZ7->Z7_DOCORI := SE2->E2_NUM
            SZ7->Z7_SERORI := SE2->E2_PREFIXO
            If (Len(aDadosOri) > 1 .and. Empty(aDadosOri[4])) .or. Empty(aDadosOri)
                SZ7->Z7_RECORI := SE2->(Recno())
            Endif
            SZ7->Z7_CLIFOR := SE2->E2_FORNECE
            SZ7->Z7_LOJA := SE2->E2_LOJA
        Elseif cTab == "CT2" .and. (FWIsInCallStack("FINA050") .or. FWIsInCallStack("CTBAFIN")  .or. FWIsInCallStack("FINA370"))
            SZ7->Z7_DOCORI := SE2->E2_NUM
            SZ7->Z7_SERORI := SE2->E2_PREFIXO
            SZ7->Z7_RECORI := SE2->(Recno())
            SZ7->Z7_CLIFOR := SE2->E2_FORNECE
            SZ7->Z7_LOJA := SE2->E2_LOJA
        Elseif cTab == "SE1" .and. FWIsInCallStack("FINA040") //.and. nOperPro == 1
            SZ7->Z7_DOCORI := SE1->E1_NUM
            SZ7->Z7_SERORI := SE1->E1_PREFIXO
            //If (Len(aDadosOri) > 1 .and. Empty(aDadosOri[4])) .or. Empty(aDadosOri)
                SZ7->Z7_RECORI := SE1->(Recno())
            //Endif
            SZ7->Z7_TIPONF := "N"
            SZ7->Z7_CLIFOR := SE1->E1_CLIENTE
            SZ7->Z7_LOJA   := SE1->E1_LOJA

        // contabilizacao de movimentos de estoque, excluindo nota de entrada e saida
//        Elseif cTab == "CT2" .and. "MATA" $ Alltrim(SZ7->Z7_ORIGEM) .and. SD3->(!Eof()) .and. SD3->(!Bof()) ;
//        .and. !"MATA103/GFEA065/MATA140/MATA460/MATA460A/MATA460B/MATA116" $ Alltrim(SZ7->Z7_ORIGEM)
        Elseif cTab == "CT2" .and. "MATA" $ Alltrim(SZ7->Z7_ORIGEM) .and. SD3->(!Eof()) .and. SD3->(!Bof()) ;
        .and. !(Alltrim(SZ7->Z7_ORIGEM) $ "MATA103/GFEA065/MATA140/MATA460/MATA460A/MATA460B/MATA116")
            If !Alltrim(SZ7->Z7_ORIGEM) == "MATA330"
                SZ7->Z7_DOCORI := IIf(!Empty(SD3->D3_OP),SD3->D3_OP,SD3->D3_DOC)
                SZ7->Z7_RECORI := SD3->(Recno())
            Endif
        Else
            If Len(aDadosOri) > 1
                SZ7->Z7_DOCORI := aDadosOri[2]
                SZ7->Z7_SERORI := aDadosOri[3]
                SZ7->Z7_RECORI := aDadosOri[4]
                SZ7->Z7_TIPONF := aDadosOri[7]
                SZ7->Z7_CLIFOR := aDadosOri[9]
                SZ7->Z7_LOJA := aDadosOri[10]
            Endif
            //SZ7->Z7_RECORI := CT2->(Recno()) // nao gravar, pois ct2 tem varios registros
        Endif

        If !( Empty( cXMLSZ7 ) )
            SZ7->Z7_XXML := cXMLSZ7
        EndIf

        If !( Empty( cRetSZ7 ) )
            SZ7->Z7_XRETORN := cRetSZ7
        EndIf

        // tratamento para quando vier status "N" no quinto elemento do array adadosori,
        // neste caso indica que o registro de exclusao nao deve ser processado, pois o registro de inclusao ainda nao foi
        // enviado, e tambem o registro de inclusao nao deve ser processado
        If nOperSAP == 2 .and. Len(aDadosOri) > 1 .and. aDadosOri[5] == "N" .and. !Empty(aDadosOri[6])
            lNaoProcEnvio := .T.
            SZ7->Z7_XSTATUS := "N"
            nRecStatusExc := SZ7->(Recno())
        Endif

        //SZ7->Z7_OPERACA := IIf(cTab$"SA2","CAD. FORNECEDOR",IIf(cTab$"SA1","CAD. CLIENTE",IIf(cTab$"SF1/SE2","CONTAS A PAGAR",IIf(cTab$"SF2/SE1","CONTAS A RECEBER",IIf(cTab$"CT2","LANC. CONTABIL","")))))
        SZ7->Z7_OPERACA := IIf(cTab$"SA2","1",IIf(cTab$"SA1","2",IIf(cTab$"SF1/SE2","3",IIf(cTab$"SF2/SE1","4",IIf(cTab$"CT2","5","")))))

        SZ7->(MsUnLock())
        ConfirmSX8()
    EndIf

    If lNaoProcEnvio
        SZ7->(dbGoto(aDadosOri[6]))
        If SZ7->(Recno()) == aDadosOri[6]
            SZ7->(RecLock("SZ7",.F.))
            SZ7->Z7_XSTATUS := "N"
            SZ7->(MsUnLock())

            // tratamento para movimentos de adiantamentos a receber, que tem operacao de inclusao/alteracao/exclusao, neste cenario, eh necessario verificar tambem o status do registro de inclusao
            If !Empty(nRecStatusExc)
                If cTab == "SE1"
                    SE1->(dbGoto(SZ7->Z7_RECORI))
                    If SE1->(Recno()) == SZ7->Z7_RECORI
                        If SE1->E1_TIPO $ MVPROVIS
                            If SZ7->(dbSeek(cxFil+cTab+cChave))
                                While SZ7->(!Eof()) .and. cxFil+cTab+Alltrim(cChave) == SZ7->Z7_FILIAL+SZ7->Z7_XTABELA+Alltrim(SZ7->Z7_XCHAVE)
                                    If (SZ7->Z7_XOPEPRO == 1 .or. SZ7->Z7_XOPEPRO == 2) .and. SZ7->Z7_XSTATUS $ "P/E" .and. SZ7->(Recno()) < nRecStatusExc // garante que este registro de inclusao eh anterior ao de alteracao
                                        SZ7->(RecLock("SZ7",.F.))
                                        SZ7->Z7_XSTATUS := "N"
                                        SZ7->(MsUnLock())
                                    Endif
                                    SZ7->(dbSkip())
                                Enddo
                            Endif
                        Endif
                    Endif
                Endif
            Endif
        Endif
    Endif

    RestArea(aAreaSZ7)
    RestArea(aArea)

return()

/* =====================================================================================
Programa.:              ZF12GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Grava a Mensagem de Erro ns SZ7
===================================================================================== */
//User Function xC99AEN(cxFil,cTab,cChav,cSeq,cStatus,cMsg,cXml)
User Function ZF12GENSAP(cxFil,cTab,cChav,cSeq,cStatus,cMsg,cXml)

    Local aArea 	:= GetArea()
    Local aAreaSZ7	:= SZ7->(GetArea())
    Local nTamChv	:= TamSx3("Z7_XCHAVE")[1]
    Local aOcor := {}

    Default cXml := ""

    cChav := SubStr((cChav + Space(nTamChv)),1,nTamChv)

    DbSelectArea("SZ7")
    SZ7->(dbSetOrder(2))//Z7_FILIAL+Z7_XTABELA+Z7_XCHAVE+Z7_XSEQUENC

    If SZ7->(dbSeek(cxFil + cTab + cChav + cSeq))
        If cStatus == "E" .and. !Empty(cMsg)
            aOcor := U_ZF24GENSAP(cMsg)
        Endif

        If SZ7->(RecLock("SZ7",.F.))

            SZ7->Z7_XSTATUS := cStatus //A=Aguardando | E=Erro
            SZ7->Z7_XRETORN := "Ret. Env.: "+dToc(dDataBase)+" - "+Time()+CRLF+cMsg+CRLF+Alltrim(SZ7->Z7_XRETORN)+CRLF
            SZ7->Z7_XXML 	:= cXml
            SZ7->Z7_XDTENV	:= dDatabase
            SZ7->Z7_XHRENV	:= Time()
            If !Empty(aOcor)
                If aOcor[2] == "1" // erro protheus
                    SZ7->Z7_ERROPRO := aOcor[1]
                Elseif aOcor[2] == "2" // erro sap
                    SZ7->Z7_ERROSAP := aOcor[1]
                Endif
            Endif
            SZ7->(MsUnLock())
        Endif
    EndIf

    RestArea(aAreaSZ7)
    RestArea(aArea)

return

/* =====================================================================================
Programa.:              ZF13GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function xC99Pros(cxFil,cTab,cChave,cSeq,cLoteInc,lEnvCanc,cDocOri,cSerOri,cTipoNF,cCliFor,cLoja,nRecnoSZ7)
User Function ZF13GENSAP(cxFil,cTab,cChave,cSeq,cLoteInc,lEnvCanc,cDocOri,cSerOri,cTipoNF,cCliFor,cLoja,nRecnoSZ7)

    Local aArea			:= GetArea()
    Local aAreaSZ7		:= SZ7->(GetArea())
    local lRet 			:= .F.
    Local cNextAlias 	:= GetNextAlias()
    Local cLotePendente := ""
    Local cMovAnt       := ""
    Local lAcertoMan    := .F.
    Local cObs          := ""
    Local cLote         := ""

    If lEnvCanc // envio do cancelamento
        If !Empty(cLoteInc) // se localizar registro referente a inclusao, valida se ele foi enviado ao sap
            SZ7->(dbSetOrder(1))
            If SZ7->(dbSeek(cxFil+cLoteInc))
                //If !Empty(SZ7->Z7_XIDSAP)
                If SZ7->Z7_XSTATUS == "O"
                    lRet := .T.
                Else
                    cLotePendente := SZ7->Z7_XLOTE
                    cMovAnt := IIf(SZ7->Z7_XOPEPRO==1,"inclusão",IIf(SZ7->Z7_XOPEPRO==2,"alteração",IIf(SZ7->Z7_XOPEPRO==3,"estorno","")))
                    If SZ7->Z7_XSTATUS == "M"
                        cLote := SZ7->Z7_XLOTE
                        lAcertoMan := .T.
                    Endif
                Endif
            Endif
        Else
            BeginSql Alias cNextAlias
                SELECT MAX(SZ7.R_E_C_N_O_) SZ7_RECNO
                FROM %Table:SZ7% SZ7
                WHERE
                SZ7.%NotDel%
                AND SZ7.Z7_FILIAL = %Exp:cxFil%
                AND SZ7.Z7_XTABELA = %Exp:cTab%
                AND SZ7.Z7_XCHAVE = %Exp:cChave%
                AND SZ7.Z7_XSEQUEN < %Exp:cSeq%
                AND SZ7.Z7_XOPESAP <> 2
                AND SZ7.Z7_XSTATUS NOT IN ('N')
            EndSql
            //AND SZ7.Z7_XSTATUS NOT IN ('N','M')

            If (cNextAlias)->(!EOF()) .and. !Empty((cNextAlias)->SZ7_RECNO)
                SZ7->(dbGoto((cNextAlias)->SZ7_RECNO))
                If SZ7->(Recno()) == (cNextAlias)->SZ7_RECNO
                    // ultimo envio de inclusao tem que estar nos status abaixo
                    //If !SZ7->Z7_XSTATUS $ "O/N/M" // ok/cancelado/acerto manual
                    //If SZ7->Z7_XSTATUS == "O" // ok
                    //If !Empty(SZ7->Z7_XIDSAP) // 09/10/19
                    If SZ7->Z7_XSTATUS == "O"
                        lRet := .T.
                    Else
                        cLotePendente := SZ7->Z7_XLOTE
                        cMovAnt := IIf(SZ7->Z7_XOPEPRO==1,"inclusão",IIf(SZ7->Z7_XOPEPRO==2,"alteração",IIf(SZ7->Z7_XOPEPRO==3,"estorno","")))
                        If SZ7->Z7_XSTATUS == "M"
                            cLote := SZ7->Z7_XLOTE
                            lAcertoMan := .T.
                        Endif
                    Endif
                Endif
            Endif
            (cNextAlias)->(DbClosearea())
        Endif
        If !lRet .and. lAcertoMan
            SZ7->(dbGoto(nRecnoSZ7))
            If SZ7->(Recno()) == nRecnoSZ7
                cObs := "Lote "+Alltrim(cLote)+" de inclusão acertado manualmente."
                SZ7->(RecLock("SZ7",.F.))
                SZ7->Z7_XSTATUS := "M"
                SZ7->Z7_XRETORN := "Acerto Manual: "+dToc(dDataBase)+" - "+Time()+CRLF+Upper(cObs)+CRLF+Alltrim(SZ7->Z7_XRETORN)+CRLF
                SZ7->(MsUnlock())
                Help("",1,"Acerto Manual",,cObs,1,0)
            Endif
        ElseIf !lRet
            Help("",1,"Envio movimento SAP",,"Existe movimento de "+cMovAnt+" anterior pendente de envio ao SAP."+IIF(!Empty(cLotePendente)," Lote pendente: "+cLotePendente,""),1,0)
        Endif
    Else // envio de inclusao / alteracao
        lRet := .T. // altera variavel para .T., pois caso nao haja cancelamento ou alteracao, o envio da inclusao deverah ser feito
        If !cTab ==  "CT2" // para tabelas diferentes de ct2, as chaves de todos os envios sao iguais
            BeginSql Alias cNextAlias
                SELECT MAX(SZ7.R_E_C_N_O_) SZ7_RECNO
                FROM %Table:SZ7% SZ7
                WHERE
                SZ7.%NotDel%
                AND SZ7.Z7_FILIAL = %Exp:cxFil%
                AND SZ7.Z7_XTABELA = %Exp:cTab%
                AND SZ7.Z7_XCHAVE = %Exp:cChave%
                AND SZ7.Z7_XSEQUEN < %Exp:cSeq%
                AND SZ7.Z7_XSTATUS NOT IN ('N','M')
            EndSql
           
        Else // tabela ct2

            BeginSql Alias cNextAlias
                SELECT MAX(SZ7.R_E_C_N_O_) SZ7_RECNO
                FROM %Table:SZ7% SZ7
                WHERE
                SZ7.%NotDel%
                AND SZ7.Z7_FILIAL = %Exp:cxFil%
                AND SZ7.Z7_XTABELA = %Exp:cTab%
                AND SZ7.Z7_DOCORI = %Exp:cDocOri%
                AND SZ7.Z7_SERORI = %Exp:cSerOri%
                AND SZ7.Z7_TIPONF = %Exp:cTipoNF%
                AND SZ7.Z7_CLIFOR = %Exp:cCliFor%
                AND SZ7.Z7_LOJA = %Exp:cLoja%
                AND SZ7.Z7_XSTATUS NOT IN ('N','M')
                AND SZ7.R_E_C_N_O_ < %Exp:nRecnoSZ7%
                AND SZ7.Z7_DOCORI <> ' '
            EndSql
            //AND SZ7.Z7_XSEQUEN < %Exp:cSeq% // nao verificar sequencia para ct2, pois todo novo lancamento inicia da sequencia 001
            //AND (SZ7.Z7_XOPEPRO = 2 OR SZ7.Z7_XOPEPRO = 3)
        Endif

        If (cNextAlias)->(!EOF()) .and. !Empty((cNextAlias)->SZ7_RECNO)
            lRet := .F. // altera variavel para .F., pois caso haja cancelamento ou alteracao, deverah satisfazer a condicao abaixo para validar
            SZ7->(dbGoto((cNextAlias)->SZ7_RECNO))
            If SZ7->(Recno()) == (cNextAlias)->SZ7_RECNO
                // ultimo envio de exclusao tem que estar nos status abaixo
                //If !SZ7->Z7_XSTATUS $ "O/N/M" // ok/cancelado/acerto manual
                //If !Empty(SZ7->Z7_XIDSAP) // 09/10/19
                If SZ7->Z7_XSTATUS == "O"
                    lRet := .T.
                Else
                    cLotePendente := SZ7->Z7_XLOTE
                    cMovAnt := IIf(SZ7->Z7_XOPEPRO==1,"inclusão",IIf(SZ7->Z7_XOPEPRO==2,"alteração",IIf(SZ7->Z7_XOPEPRO==3,"estorno","")))
                Endif
            Endif
         Endif
        (cNextAlias)->(DbClosearea())
        If !lRet
            Help("",1,"Envio movimento SAP",,"Existe movimento de "+cMovAnt+" anterior pendente de envio ao SAP."+IIF(!Empty(cLotePendente)," Lote pendente: "+cLotePendente,""),1,0)
        Endif
    Endif

    SZ7->(RestArea(aAreaSZ7))
    RestArea(aArea)

Return lRet
/* =====================================================================================
Programa.:              ZF14GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function xC99XmlE(cZ7Fil,cZ7Tab,cZ7Chav,cZ7Seq,aTags)
User Function ZF14GENSAP(cZ7Fil,cZ7Tab,cZ7Chav,cZ7Seq,aTags)

    Local aArea		:= getArea()
    Local aAreaSZ7 	:= SZ7->(getArea())
    Local nTamChv	:= TamSx3("Z7_XCHAVE")[1]
    local cXMl		:= ""
    Local oXML  := Nil
    Local aAtt	:= {}
    Local ni	:= 0

    local lContinua := .T.
    Local lEncontra	:= .T.
    Local lRet1		:= .T.
    Local lRet2		:= .T.
    Local cRet		:= ""

    cZ7Chav := SubStr((cZ7Chav + Space(nTamChv)),1,nTamChv)

    dbSelectArea("SZ7")
    SZ7->(dbSetorder(2))//SZ7->(dbSetOrder(2))//Z7_FILIAL+Z7_XTABELA+Z7_XCHAVE+Z7_XSEQUENC

    If SZ7->(dbSeek(cZ7Fil + cZ7Tab + cZ7Chav + cZ7Seq))
        cXMl 	:= SZ7->Z7_XXML
        //C:=STRTRAN(C,"<motivoOperacao>1</motivoOperacao>","<motivoOperacao>2</motivoOperacao>")
        oXML:= TXmlManager():New()
        if oXML:Parse( cXML )

            For ni:= 1 to len(aTags)

                While lContinua

                    //Traz os campos Filhos/ verifica se a tag a ser atualizada existe
                    aAtt	:= oXml:DOMGetChildArray()
                    If Len(aAtt)>0
                        If aScan( aAtt, { |x| Alltrim(x[1]) == Alltrim(aTags[ni][1]) }) > 0
                            oXML:DOMChildNode()
                            While lEncontra
                                If Alltrim(oXML:cName) ==  Alltrim(aTags[ni][1])
                                    oXML:DOMSetNode( aTags[ni][1], aTags[ni][2])
                                    //lContinua := .F.
                                    lEncontra := .F.
                                Else
                                    oXML:DOMNextNode()
                                EndIf
                            EndDo
                            lEncontra := .T.
                            Exit
                        EndIf
                    EndIf

                    If oXML:DOMHasChildNode()//verifica se existe proximo Filho
                        oXML:DOMChildNode()//vai para proximo Filho
                    ElseIf oXML:DOMHasNextNode()//vai para o Proximo No mesmo nivel
                        oXML:DOMNextNode()
                    Else
                        lRet1 := oXML:DOMParentNode()
                        if lRet1
                            lRet2 := oXML:DOMNextNode()
                            While !lRet2
                                lRet1 := oXML:DOMParentNode()
                                lRet2 := oXML:DOMNextNode()

                                If !lRet1 .And. !lRet2
                                    lContinua := .F.
                                    Exit
                                EndIf
                            EndDo
                            loop
                        Else
                            Exit
                        EndIf
                    Endif
                EndDo
            Next ni
        endif
    EndIf

    cRet := oXML:Save2String()

    RestArea(aAreaSZ7)
    RestArea(aArea)

Return cRet
/* =====================================================================================
Programa.:              ZF15GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function xxC99XmlE(cZ7Fil,cZ7Tab,cZ7Chav,cZ7Seq,aTags)
User Function ZF15GENSAP(cZ7Fil,cZ7Tab,cZ7Chav,cZ7Seq,aTags)

    Local aArea		:= getArea()
    Local aAreaSZ7 	:= SZ7->(getArea())
    Local nTamChv	:= TamSx3("Z7_XCHAVE")[1]
    local cXMl		:= ""
    Local cRet		:= ""

    cZ7Chav := SubStr((cZ7Chav + Space(nTamChv)),1,nTamChv)

    dbSelectArea("SZ7")
    SZ7->(dbSetorder(2))//SZ7->(dbSetOrder(2))//Z7_FILIAL+Z7_XTABELA+Z7_XCHAVE+Z7_XSEQUENC

    If SZ7->(dbSeek(cZ7Fil + cZ7Tab + cZ7Chav + cZ7Seq))
        // buscar o ultimo envio, antes deste, com sucesso e que nao seja de exclusao de movimento // 04/09/19
        While SZ7->(!Bof()) .and. cZ7Fil + cZ7Tab + cZ7Chav == SZ7->Z7_FILIAL + SZ7->Z7_XTABELA + SZ7->Z7_XCHAVE
            // se encontrar algum envio, diferente de exclusao e que nao tenha sido concluido com sucesso, aborta, pois o envio
            // correto do cancelamento tem que ser sobre o ultimo envio correto, diferente de cancelamento
            If !SZ7->Z7_XOPESAP == 2 .and. !SZ7->Z7_XSTATUS == "O" // 08/10/19
                RestArea(aAreaSZ7)
                RestArea(aArea)

                Return(cRet)
            Endif

    		If !SZ7->Z7_XOPESAP == 2 .and. SZ7->Z7_XSTATUS == "O"
		        cXMl := SZ7->Z7_XXML
		        If FWIsInCallStack("U_CMVSAP17") .Or. FWIsInCallStack("U_ZSAPF017")
		            If At("<motivoOperacao>1</motivoOperacao>",cXMl) > 0 // ultima operacao foi a inclusao do provisorio
		                cXMl := StrTran(cXMl,"<motivoOperacao>1</motivoOperacao>","<motivoOperacao>2</motivoOperacao>")
		            Elseif At("<motivoOperacao>4</motivoOperacao>",cXMl) > 0 // ultima operacao foi a alteracao do provisorio
		                cXMl := StrTran(cXMl,"<motivoOperacao>4</motivoOperacao>","<motivoOperacao>2</motivoOperacao>")
		            Endif
		        Elseif FWIsInCallStack("U_CMVSAP03") .Or.  FWIsInCallStack("U_ZSAPF003")
		            If At("<motivoOperacao>3</motivoOperacao>",cXMl) > 0 // titulos em moeda diferente da 1
		                cXMl := StrTran(cXMl,"<motivoOperacao>3</motivoOperacao>","<motivoOperacao>2</motivoOperacao>")
		            Elseif At("<motivoOperacao>1</motivoOperacao>",cXMl) > 0 // demais
		                cXMl := StrTran(cXMl,"<motivoOperacao>1</motivoOperacao>","<motivoOperacao>2</motivoOperacao>")
		            Endif
		        Else
		            cXMl := StrTran(cXMl,"<motivoOperacao>1</motivoOperacao>","<motivoOperacao>2</motivoOperacao>")
		        Endif
                cRet := cXMl
                Exit
		    Endif
		    SZ7->(dbSkip(-1))
	    Enddo
    Endif

    RestArea(aAreaSZ7)
    RestArea(aArea)

Return cRet
/* =====================================================================================
Programa.:              ZF16GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function xC99ART(cxFil,cChave,cStatus,cIDSAP,cMsg,cTipo)
User Function ZF16GENSAP(cxFil,cChave,cStatus,cIDSAP,cMsg,cTipo)

    Local aArea 	:= GetArea()
    Local aAreaSZ7	:= SZ7->(GetArea())
    Local aRet		:= {"1","Retorno: OK"}
    local cTab		:= ""
    Local nInd		:= 0
    Local lContinua := .T.
    Local cQ 		:= ""
    Local cNextAlias 	:= GetNextAlias()
    Local cAliasTrb 	:= GetNextAlias()
    Local nRecno := 0
    Local cChaveExc := ""
    Local lExc := .F.
    Local aOcor := {}
    Local cTiposFin := GetMv("CAOASAP12D",,"NF/DP")
    Local cUpdate   := ""
    Local nOk1      := 0 //Variavel para tratar Update na SA1 e SA2
    Local nOk2      := 0 //Variavel para tratar Update na SA1 e SA2
    
    If cTipo == "1" //Clientes
        cTab:= "SA1"
        //cxFil := xFilial("SA1",cxFil)
    ElseIf cTipo == "2" //Fornecedor
        cTab:= "SA2"
        //cxFil := xFilial("SA2",cxFil)
    ElseIf cTipo == "3" //Documento Saida(Contas a Receber)
		/*
        If Subs(cChave,5,1) == "D"
		  	cTab := "SF1"
        Else
			cTab:= "SF2"
        Endif
		nRecno := Val(Subs(cChave,8))
		*/
        nRecno := Val(Subs(cChave,2,IIf(At("P",cChave)>0,At("P",cChave)-2,20)))
        //cxFil := xFilial("SF2",cxFil)
    ElseIf cTipo == "4" //Documento Entrada(Contas a Pagar)
		/*
        If Subs(cChave,5,1) == "D"
		  	cTab := "SF2"
        Elseif Subs(cChave,5,1) == " "
		  	cTab := "SE2"
        Else
			cTab:= "SF1"
        Endif
		nRecno := Val(Subs(cChave,8))
		*/
        nRecno := Val(Subs(cChave,2))
        //cxFil := xFilial("SF1",cxFil)
    ElseIf cTipo == "5" //Documento Entrada(Contas a Pagar - Frete/Garantia/GNRE(FG))
        nRecno := Val(Subs(cChave,2))
        //cxFil := xFilial("SF1",cxFil)
    ElseIf cTipo == "6" //Contabilizacao
        cTab:= "CT2"
        //cxFil := xFilial("CT2",cxFil)
        nRecno := Val(Subs(cChave,2))
    Else
        aRet := {"2","Retorno: Interface: " + cTipo + ", Não é Válida " }
        Return aRet
    EndIf

    cChave := Alltrim(cChave)

    cQ := " SELECT MIN(SZ7.R_E_C_N_O_) SZ7_RECNO " // sempre pega o registro mais antigo pra atualizar o retorno
    cQ += " FROM "+retSQLName("SZ7")+" SZ7 "
    cQ += " WHERE "
    cQ += " Z7_FILIAL = '"+cxFil+"' "
    If cTipo $ "3/4/5"
        //cQ += "AND Z7_RECORI = '"+Alltrim(Str(nRecno))+"' "
        cQ += " AND SZ7.R_E_C_N_O_ = '"+Alltrim(Str(nRecno))+"' "
    Elseif cTipo == "6"
        cQ += " AND Z7_XTABELA = '"+cTab+"' "
        //cQ += "AND Z7_XCHAVE = '"+Subs(cChave,2)+"' " // retira caracter "T" da chave enviada ao sap
        cQ += " AND SZ7.R_E_C_N_O_ = '"+Alltrim(Str(nRecno))+"' "
    Else // cliente/fornecedor
        cQ += " AND Z7_XTABELA = '"+cTab+"' "
        cQ += " AND Z7_XCHAVE = '"+cChave+"' "
    Endif
    cQ += " AND Z7_XSTATUS IN ('A','E','O') " // processa status 'O' tb, pois no envio da exclusao, eh enviado o recno da sz7 da inclusao, e no retorno este registro jah foi processado
    cQ += " AND Z7_XSTATUS NOT IN ('P','N','M') " // linha sem efeito, pois filtro eh feito na linha de cima
    cQ += " AND SZ7.D_E_L_E_T_ = ' ' "

    //memoWrite( "C:\TEMP\xC99ART.txt",cQ)

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cNextAlias,.T.,.T.)

    //While (cNextAlias)->(!EOF())
    If (cNextAlias)->(!EOF()) .and. !Empty((cNextAlias)->SZ7_RECNO)
        //If SZ7->(dbSeek((cNextAlias)->Z7_FILIAL + (cNextAlias)->Z7_XLOTE))
        SZ7->(dbSetOrder(2)) // OBS: nao retirar este dbsetorder() daqui, pois serah feito um while logo abaixo, que necessita deste indice
        SZ7->(dbGoto((cNextAlias)->SZ7_RECNO))

        // se retorno do envio jah foi processado antes, localiza registro do envio da exclusao ou proximo envio
        If SZ7->Z7_XSTATUS == "O"
            lContinua := .F.
            cChaveExc := SZ7->Z7_FILIAL+SZ7->Z7_XTABELA+SZ7->Z7_XCHAVE
            While SZ7->(!Eof()) .and. cChaveExc == SZ7->Z7_FILIAL+SZ7->Z7_XTABELA+SZ7->Z7_XCHAVE
                If SZ7->Z7_XSTATUS == "P"
                    SZ7->(dbSkip())
                    Loop
                Endif
                If !SZ7->Z7_XSTATUS $ "O/N" .and. SZ7->Z7_XOPEPRO == 3 .and. SZ7->Z7_XOPESAP == 2 // localizou exclusao pendente
                    lContinua := .T.
                    lExc := .T.
                    Exit
                Endif
                If !SZ7->Z7_XSTATUS $ "O/N" .and. (SZ7->Z7_XOPEPRO == 1 .or. SZ7->Z7_XOPEPRO == 2) .and. SZ7->Z7_XOPESAP == 1 // localizou registro pendente de envio, que nao eh de exclusao
                    lContinua := .T.
                    Exit
                Endif
                SZ7->(dbSkip())
            Enddo
            If !lContinua
                aRet := {"2","Retorno: Não foi Encontrado o Registro SZ7 para a Filial: " + cxFil + ", Chave: " + cChave }
            Endif
        Endif

        If SZ7->Z7_XOPESAP == 1 .and. !lExc .and. lContinua // somente grava codigo sap nas tabelas, na inclusao da integracao
            If cTipo $ "3/4/5" // encontra a tabela correta, pois quando eh devolucao ou se2, tem que fazer este tratamento
                cTab := SZ7->Z7_XTABELA
            Endif

            If cStatus=="1"//Se OK
                If cTipo == "1" //Clientes
                    nInd := Val(SZ7->Z7_XINDICE)
                    SA1->(dbSetOrder(nInd))
                    If SA1->(dbSeek(xFilial("SA1") + Alltrim(SZ7->Z7_XCHAVE)))
                    
                        cUpdate := " UPDATE SA1010 "
                        cUpdate += " SET A1_XCDSAP = '" + cIDSAP + "' "
                        cUpdate += " WHERE "
                        cUpdate += " A1_CGC = '" + SA1->A1_CGC + "' "
                        
                        nOk1 := TcSQLExec(cUpdate)

                        cUpdate := " UPDATE SA1020 "
                        cUpdate += " SET A1_XCDSAP = '" + cIDSAP + "' "
                        cUpdate += " WHERE "
                        cUpdate += " A1_CGC = '" + SA1->A1_CGC + "' "
                        
                        nOk2 := TcSQLExec(cUpdate)
                        
                        // Tratamento de erro de execução do TcSQLExec se for menor que 0(Zero) porque não foi executado
                        if nOk1 < 0 .or. nOk2 < 0 
                            aRet := {"2","Retorno: Não foi Possivel o Atualizar o Registro SA1 para a Filial: " + cxFil + ", Chave: " + cChave }
                            lContinua := .F.    
                        endif
                    Else
                        lContinua := .F.
                        aRet := {"2","Retorno: Não foi Encontrado o Registro SA1 para a Filial: " + cxFil + ", Chave: " + cChave }
                    EndIf

                ElseIf cTipo == "2" //Fornecedor
                    
                    nInd := Val(SZ7->Z7_XINDICE)
                    SA2->(dbSetOrder(nInd))
                    If SA2->(dbSeek(xFilial("SA2") + Alltrim(SZ7->Z7_XCHAVE)))

                        cUpdate := " UPDATE SA2010 "
                        cUpdate += " SET A2_XCDSAP = '"+cIDSAP+"' "
                        cUpdate += " WHERE "
                        cUpdate += " A2_CGC = '" + SA2->A2_CGC + "' "
                        
                        nOk1 := TcSQLExec(cUpdate)

                        cUpdate := " UPDATE SA2020 "
                        cUpdate += " SET A2_XCDSAP = '" + cIDSAP + "' "
                        cUpdate += " WHERE "
                        cUpdate += " A2_CGC = '" + SA2->A2_CGC + "' "
                        
                        nOk2 :=  TcSQLExec(cUpdate)

                        // Tratamento de erro de execução do TcSQLExec se for menor que 0(Zero) porque não foi executado    
                        if nOk1 < 0 .or. nOk2 < 0
                            aRet := {"2","Retorno: Não foi Possivel o Atualizar o Registro SA2 para a Filial: " + cxFil + ", Chave: " + cChave }
                            lContinua := .F.    
                        endif
                    Else
                        lContinua := .F.
                        aRet := {"2","Retorno: Não foi Encontrado o Registro SA2 para a Filial: " + cxFil + ", Chave: " + cChave }
                    EndIf

                ElseIf cTipo $ "3/4/5" //Documento Saida(Contas a Receber)
                    (cTab)->(dbGoto(SZ7->Z7_RECORI)) // obs: nao usar seek, pois registro pode estar deletado
                    If (cTab)->(Recno()) == SZ7->Z7_RECORI
                        If (cTab)->(RecLock(cTab,.F.))
                            (cTab)->&(Subs(cTab,2,2)+"_XCODSAP") := cIDSAP
                            (cTab)->(MsUnLock())
                        EndIf

                        // grava id no financeiro
                        If cTab == "SF1"
                            If !SF1->F1_TIPO $ ("D/B") .and. !Empty(SF1->F1_DUPL)
                                U_ZF25GENSAP("P",SF1->F1_SERIE+SF1->F1_DUPL+SF1->F1_FORNECE+SF1->F1_LOJA,cIDSAP,Alltrim(MVNOTAFIS))
                            Elseif SF1->F1_TIPO == "D" .and. !Empty(SF1->F1_DUPL)
                                U_ZF25GENSAP("R",SF1->F1_SERIE+SF1->F1_DUPL+SF1->F1_FORNECE+SF1->F1_LOJA,cIDSAP,"NCC")
                            Endif
                        Endif
                        If cTab == "SF2"
                            If !SF2->F2_TIPO $ ("D/B") .and. !Empty(SF2->F2_DUPL)
                                U_ZF25GENSAP("R",SF2->F2_SERIE+SF2->F2_DUPL+SF2->F2_CLIENTE+SF2->F2_LOJA,cIDSAP,cTiposFin)
                            Elseif SF2->F2_TIPO == "D" .and. !Empty(SF2->F2_DUPL)
                                U_ZF25GENSAP("P",SF2->F2_SERIE+SF2->F2_DUPL+SF2->F2_CLIENTE+SF2->F2_LOJA,cIDSAP,"NDF")
                            Endif
                        Endif
                    Else
                        lContinua := .F.
                        aRet := {"2","Retorno: Não foi Encontrado o Registro "+cTab+" para a Filial: " + cxFil + ", Chave: " + cChave }
                    EndIf
					/*
                ElseIf cTipo == "4" //Documento Entrada(Contas a Pagar)
						(cTab)->(dbGoto(SZ7->Z7_RECORI)) // obs: nao usar seek, pois registro pode estar deletado
                    If (cTab)->(Recno()) == SZ7->Z7_RECORI
                        If (cTab)->(RecLock(cTab,.F.))
								(cTab)->&(Subs(cTab,2,2)+"_XCODSAP") := cIDSAP 
								(cTab)->(MsUnLock())
                        EndIf
                    Else
							lContinua := .F.
							aRet := {"2","Retorno: Não foi Encontrado o Registro "+cTab+" para a Filial: " + cxFil + ", Chave: " + cChave }
                    EndIf
					*/	
                ElseIf cTipo == "6" //Contabilidade
                    //If CT2->(dbSeek(xFilial("CT2") + Alltrim(SZ7->Z7_XCHAVE)))
                    //While CT2->(!Eof()) .and. Alltrim(SZ7->(Z7_FILIAL + Z7_XCHAVE)) == CT2->(CT2_FILIAL + DTOS(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC )
                    cQ := "SELECT CT2.R_E_C_N_O_ CT2_RECNO "
                    cQ += "FROM "+retSQLName("CT2")+" CT2 "
                    cQ += "WHERE "
                    cQ += "CT2_FILIAL = '"+cxFil+"' "
                    cQ += "AND CT2_DATA || CT2_LOTE || CT2_SBLOTE || CT2_DOC = '"+SZ7->Z7_XCHAVE+"' "
                    //cQ += "AND CT2.D_E_L_E_T_ = ' ' " // obs: ler registros deletados tambem, pois lancamentos podem jah ter sido deletados

                    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)

                    If (cAliasTrb)->(!Eof())
                        While (cAliasTrb)->(!Eof())
                            CT2->(dbGoto((cAliasTrb)->CT2_RECNO))
                            If CT2->(Recno()) == (cAliasTrb)->CT2_RECNO
                                If CT2->(RecLock("CT2",.F.))
                                    CT2->CT2_XCODSA := cIDSAP
                                    CT2->(MsUnLock())
                                EndIf
                            Endif
                            (cAliasTrb)->(dbSkip())
                        EndDo
                    Else
                        lContinua := .F.
                        aRet := {"2","Retorno: Não foi Encontrado o Registro CT2 para a Filial: " + cxFil + ", Chave: " + cChave }
                    EndIf
                    (cAliasTrb)->(dbCloseArea())
                EndIf
            EndIf
        Endif

        If lContinua
            If SZ7->(RecLock("SZ7",.F.))

                SZ7->Z7_XSTATUS := IIF(cStatus=="1","O","E") //O=OK | E=Erro
                SZ7->Z7_XRETORN := "Ret. Proc.: "+dToc(dDataBase)+" - "+Time()+CRLF+cMsg+CRLF+Alltrim(SZ7->Z7_XRETORN)+CRLF
                SZ7->Z7_XIDSAP 	:= cIDSAP
                SZ7->Z7_XDTRET	:= dDatabase
                SZ7->Z7_XHRRET	:= Time()

                If SZ7->Z7_XSTATUS == "E" .and. !Empty(cMsg)
                    aOcor := U_ZF24GENSAP(cMsg)
                Endif

                If !Empty(aOcor)
                    If aOcor[2] == "1" // erro protheus
                        SZ7->Z7_ERROPRO := aOcor[1]
                    Elseif aOcor[2] == "2" // erro sap
                        SZ7->Z7_ERROSAP := aOcor[1]
                    Endif
                Endif

                SZ7->(MsUnLock())
            Endif
        EndIf
        //Else
        //	aRet := {"2","Retorno: Não foi Encontrado o Registro para a Filial: " + cxFil + ", Chave: " + cChave }
        //EndIf

        //(cNextAlias)->(dbSkip())
    Else
        aRet := {"2","Retorno: Não foi Encontrado o Registro SZ7 para a Filial: " + cxFil + ", Chave: " + cChave }
    EndIf

    (cNextAlias)->(DbClosearea())

    RestArea(aAreaSZ7)
    RestArea(aArea)

return aRet

/* =====================================================================================
Programa.:              ZF17GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function GrvSZ7XMLCanc(cFil,cTab,cChave,cSeq,cXML)
User Function ZF17GENSAP(cFil,cTab,cChave,cSeq,cXML)

    Local aArea := {SZ7->(GetArea()),GetArea()}
    Local cQ := ""
    Local cAliasTrb := GetNextAlias()

    cQ := " SELECT MIN(R_E_C_N_O_) SZ7_RECNO " // pega o primeiro registro com a sequencia maior que a do envio
    cQ += " FROM "+retSQLName("SZ7")+" SZ7 "
    cQ += " WHERE "
    cQ += " Z7_FILIAL = '"+cFil+"' "
    cQ += " AND Z7_XTABELA = '"+cTab+"' "
    cQ += " AND Z7_XCHAVE = '"+cChave+"' "
    cQ += " AND Z7_XSEQUEN > '"+cSeq+"' " // sequencia tem que ser maior que a do registro corrente
    cQ += " AND Z7_XOPEPRO = 3 " // 3-exclusao protheus
    cQ += " AND Z7_XOPESAP = 2 " // 2-exclusao sap
    cQ += " AND Z7_XSTATUS IN ('P','E') "
    cQ += " AND SZ7.D_E_L_E_T_ = ' ' "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)

    If (cAliasTrb)->(!Eof()) .and. !Empty((cAliasTrb)->SZ7_RECNO)
        SZ7->(dbGoto((cAliasTrb)->SZ7_RECNO))
        //If Empty(SZ7->Z7_XXML)
            SZ7->(Reclock("SZ7",.F.))
            SZ7->Z7_XXML := cXML
            SZ7->(MsUnLock())
        //Endif
    Endif

    (cAliasTrb)->(dbCloseArea())

    aEval(aArea,{|x| RestArea(x)})

return()
/* =====================================================================================
Programa.:              ZF18GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function Int99TemRegCan(cxFil,cLote,nRecInc)
User Function ZF18GENSAP(cxFil,cLote,nRecInc)

Local aArea	:= {SZ7->(GetArea()),GetArea()}
local lRet := .F.
Local cNextAlias := GetNextAlias()
Local nCnt := 0
Local lExecuta := GetMv("CAOASAP99A",,.T.)

If !lExecuta
    Return(lRet)
Endif

// soh faz este processamento se estiver na rotina de reprocessamento do monitor
If !FWIsInCallStack("U_xCMVREP")
    Return(lRet)
Endif

BeginSql Alias cNextAlias
    SELECT SZ7.R_E_C_N_O_ SZ7_RECNO,Z7_XLOTE
    FROM %Table:SZ7% SZ7
    WHERE
    SZ7.%NotDel%
    AND Z7_FILIAL = %Exp:cxFil%
    AND Z7_LOTEINC = %Exp:cLote%
    AND Z7_XOPESAP = 2
    AND Z7_XSTATUS NOT IN ('O','M','N')
EndSql

If (cNextAlias)->(!EOF())
    lRet := .T.
    Help("",1,"Envio movimento SAP",,"Este movimento já foi estornado no lote: "+(cNextAlias)->Z7_XLOTE+", será marcado para não ser enviado, com seu respectivo movimento de estorno.",1,0)
    For nCnt:=1 To 2
        If nCnt == 1
            SZ7->(dbGoto((cNextAlias)->SZ7_RECNO))
            If !SZ7->(Recno()) == (cNextAlias)->SZ7_RECNO
                Exit
            Endif
        Endif
        If nCnt == 2
            SZ7->(dbGoto(nRecInc))
            If !SZ7->(Recno()) == nRecInc
                Exit
            Endif
        Endif
        SZ7->(RecLock("SZ7",.F.))
        SZ7->Z7_XSTATUS := "N"
        SZ7->(MsUnlock())
    Next
Endif

(cNextAlias)->(dbCloseArea())

aEval(aArea,{|x| RestArea(x)})

Return(lRet)

/* =====================================================================================
Programa.:              ZF19GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function xC99A1A2(cChave,cStatus,cMsg,cTabela)
User Function ZF19GENSAP(cChave,cStatus,cMsg,cTabela)

Local aArea    := GetArea()
local aAreaSZ7 := SZ7->(GetArea())

cTabela := PadR(cTabela,TAMSX3("Z7_XTABELA")[1])
cChave  := PadR(cChave,TAMSX3("Z7_XCHAVE")[1])

SZ7->(dbSetOrder(2))
If SZ7->(dbSeek(xFilial("SZ7")+cTabela+cChave))

	While !SZ7->(EOF()) .AND. SZ7->Z7_XTABELA == cTabela .and. SZ7->Z7_XCHAVE==cChave

		IF ALLTRIM(SZ7->Z7_XSTATUS) $ "P/E"
            SZ7->(RecLock("SZ7",.F.))
            SZ7->Z7_XSTATUS := "N"
            SZ7->Z7_XRETORN := Alltrim(cMsg)
            SZ7->Z7_XDTENV	:= dDatabase
            SZ7->Z7_XHRENV	:= Time()
            SZ7->(MsUnLock())
		ENDIF

		SZ7->(DBSKIP())
	Enddo

ENDIF

RestArea(aAreaSZ7)
RestArea(aArea)

return

/* =====================================================================================
Programa.:              ZF20GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//Static Function xEncSeq(cxFil, cTab, cChav)
User Function ZF20GENSAP(cxFil, cTab, cChav)

    Local aArea 	:= GetArea()
    Local aAreaSZ7	:= SZ7->(GetArea())
    local cRet		:= "001"

    DbSelectArea("SZ7")
    SZ7->(dbSetOrder(2))//Z7_FILIAL+Z7_XTABELA+Z7_XCHAVE+Z7_XSEQUENC

    If SZ7->(dbSeek(cxFil + cTab + cChav))
        While SZ7->(!EOF()) .and. Alltrim(SZ7->(Z7_FILIAL + Z7_XTABELA + Z7_XCHAVE)) == Alltrim(cxFil + cTab + cChav)
            cRet := SZ7->Z7_XSEQUEN
            SZ7->(dbSkip())
        EndDo
        cRet := Soma1(cRet)
    EndIf

    RestArea(aAreaSZ7)
    RestArea(aArea)

return cRet

/* =====================================================================================
Programa.:              ZF21GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//Static Function PesqTit(cCarteira,cChave,cTiposFin)
User Function ZF21GENSAP(cCarteira,cChave,cTiposFin)

Local aArea := {GetArea()}
Local cQ := ""
Local cAliasTrb := GetNextAlias()
Local lRet := .F.

If cCarteira == "P"
	cQ := "SELECT 1 "
	cQ += "FROM "+retSQLName("SE2")+" SE2 "
	cQ += "WHERE "
	cQ += "E2_FILIAL = '"+xFilial("SE2")+"' "
	//cQ += "AND E2_PREFIXO || E2_NUM || E2_TIPO || E2_FORNECE || E2_LOJA = '"+cChave+"' "	
	cQ += "AND E2_PREFIXO || E2_NUM || E2_FORNECE || E2_LOJA = '"+cChave+"' "
	cQ += "AND TRIM(E2_TIPO) IN "+FormatIn(cTiposFin,"/")+" "
	If !(FWIsInCallStack("MATA103") .or. FWIsInCallStack("MATA140") .or. FWIsInCallStack("GFEA065") .or. FWIsInCallStack("MATA116")) // nestas rotinas, o titulo jah estah deletado neste momento do estorno do lancamento contabil
		cQ += "AND SE2.D_E_L_E_T_ = ' ' "
	Endif	
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
	
	If (cAliasTrb)->(!Eof())
		lRet := .T.
	Endif
	
	(cAliasTrb)->(dbCloseArea())
Endif

If cCarteira == "R"
	cQ := "SELECT 1 "
	cQ += "FROM "+retSQLName("SE1")+" SE1 "
	cQ += "WHERE "
	cQ += "E1_FILIAL = '"+xFilial("SE1")+"' "
	//cQ += "AND E1_PREFIXO || E1_NUM || E1_TIPO || E1_CLIENTE || E1_LOJA = '"+cChave+"' "
	cQ += "AND E1_PREFIXO || E1_NUM || E1_CLIENTE || E1_LOJA = '"+cChave+"' "
	cQ += "AND TRIM(E1_TIPO) IN "+FormatIn(cTiposFin,"/")+" "
	If !(FWIsInCallStack("MATA520")) // nestas rotinas, o titulo jah estah deletado neste momento do estorno do lancamento contabil
		cQ += "AND SE1.D_E_L_E_T_ = ' ' "
	Endif	
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
	
	If (cAliasTrb)->(!Eof())
		lRet := .T.
	Endif
	
	(cAliasTrb)->(dbCloseArea())
Endif

aEval(aArea,{|x| RestArea(x)})

Return(lRet)

/* =====================================================================================
Programa.:              ZF22GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//Static Function SAP09Key(cLP,dData,cSeq)
User Function ZF22GENSAP(cLP,dData,cSeq)

Local aArea := {SD2->(GetArea()),CV3->(GetArea()),GetArea()}
Local cRet := ""

CV3->(dbSetOrder(1))
If CV3->(dbSeek(xFilial("CV3")+dTos(dData)+cSeq))
	If cLP $ "610"
		SD2->(dbGoto(Val(CV3->CV3_RECORI)))
		If SD2->(Recno()) == Val(CV3->CV3_RECORI)
			cRet := SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD+SD2->D2_ITEM
		Endif
	Endif
Endif					

aEval(aArea,{|x| RestArea(x)})

Return(cRet)

/* =====================================================================================
Programa.:              ZF23GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//User Function xEncXmlAnt(cxFil,cTab,cChav)
User Function ZF23GENSAP(cxFil,cTab,cChav)


    Local aArea 	:= GetArea()
    Local aAreaSZ7	:= SZ7->(GetArea())
    local cRet		:= ""

    //Encontra o XML anterior
    DbSelectArea("SZ7")
    SZ7->(dbSetOrder(2))//Z7_FILIAL+Z7_XTABELA+Z7_XCHAVE+Z7_XSEQUENC

    If SZ7->(dbSeek(cxFil + cTab + cChav))
        While SZ7->(!EOF()) .and. Alltrim(SZ7->(Z7_FILIAL + Z7_XTABELA + Z7_XCHAVE)) == Alltrim(cxFil + cTab + cChav)
            If SZ7->Z7_XOPEPRO <> 3 .and. SZ7->Z7_XOPESAP == 1 // somente operacoes diferentes de exclusao
                cRet := SZ7->Z7_XXML
            Endif
            SZ7->(dbSkip())
        EndDo
    EndIf

    RestArea(aAreaSZ7)
    RestArea(aArea)

return cRet

/* =====================================================================================
Programa.:              ZF24GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:  Seleciona a Mensagem de Erro na Tabela SZF 
===================================================================================== */
//User Function Int99OcoErro(cRetSZ7)
User Function ZF24GENSAP(cRetSZ7)

    Local aArea := {GetArea()}
    Local cQ := ""
    Local cAliasTrb := GetNextAlias()
    Local aRet := {}

    cQ := "SELECT ZF_COD,ZF_ORIGEM,R_E_C_N_O_ SZF_RECNO "
    cQ += "FROM "+retSQLName("SZF")+" SZF "
    cQ += "WHERE "
    cQ += "ZF_FILIAL = '"+xFilial("SZF")+"' "
    cQ += "AND INSTR('"+StrTran(Upper(Alltrim(FWNoAccent(cRetSZ7))),"'","")+"',UPPER(TRIM(ZF_MENSAGE))) > 0 "
    cQ += "AND "
    cQ += "( "
    cQ += "CASE "
    cQ += "WHEN ZF_MENSAG2 <> ' ' "
    cQ += "THEN INSTR('"+StrTran(Upper(Alltrim(FWNoAccent(cRetSZ7))),"'","")+"',UPPER(TRIM(ZF_MENSAG2))) "
    cQ += "ELSE "
    cQ += "1 "
    cQ += "END "
    cQ += ") > 0 "
    cQ += "AND SZF.D_E_L_E_T_ = ' ' "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)

    While (cAliasTrb)->(!Eof())
        aRet := {(cAliasTrb)->ZF_COD,(cAliasTrb)->ZF_ORIGEM}
        Exit
    Enddo

    (cAliasTrb)->(dbCloseArea())

    aEval(aArea,{|x| RestArea(x)})

Return(aRet)

/* =====================================================================================
Programa.:              ZF25GENSAP
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
//Static Function PesqTit(cCarteira,cChave,cIdSap,cTiposFin)
User Function ZF25GENSAP(cCarteira,cChave,cIdSap,cTiposFin)

    Local aArea := {GetArea()}
    Local cQ := ""
    Local cAliasTrb := GetNextAlias()

    If cCarteira == "P"
        cQ := "SELECT R_E_C_N_O_ SE2_RECNO "
        cQ += "FROM "+retSQLName("SE2")+" SE2 "
        cQ += "WHERE "
        cQ += "E2_FILIAL = '"+xFilial("SE2")+"' "
        //cQ += "AND E2_PREFIXO || E2_NUM || E2_TIPO || E2_FORNECE || E2_LOJA = '"+cChave+"' "
        cQ += "AND E2_PREFIXO || E2_NUM || E2_FORNECE || E2_LOJA = '"+cChave+"' "
        cQ += "AND TRIM(E2_TIPO) IN "+FormatIn(cTiposFin,"/")+" "
        cQ += "AND SE2.D_E_L_E_T_ = ' ' "

        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)

        While (cAliasTrb)->(!Eof())
            SE2->(dbGoto((cAliasTrb)->SE2_RECNO))
            SE2->(RecLock("SE2",.F.))
            SE2->E2_XCODSAP := cIdSap
            SE2->(MsUnLock())
            (cAliasTrb)->(dbSkip())
        Enddo

        (cAliasTrb)->(dbCloseArea())
    Endif

    If cCarteira == "R"
        cQ := "SELECT R_E_C_N_O_ SE1_RECNO "
        cQ += "FROM "+retSQLName("SE1")+" SE1 "
        cQ += "WHERE "
        cQ += "E1_FILIAL = '"+xFilial("SE1")+"' "
        //cQ += "AND E1_PREFIXO || E1_NUM || E1_TIPO || E1_CLIENTE || E1_LOJA = '"+cChave+"' "
        cQ += "AND E1_PREFIXO || E1_NUM || E1_CLIENTE || E1_LOJA = '"+cChave+"' "
        cQ += "AND TRIM(E1_TIPO) IN "+FormatIn(cTiposFin,"/")+" "
        cQ += "AND SE1.D_E_L_E_T_ = ' ' "

        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)

        While (cAliasTrb)->(!Eof())
            SE1->(dbGoto((cAliasTrb)->SE1_RECNO))
            SE1->(RecLock("SE1",.F.))
            SE1->E1_XCODSAP := cIdSap
            SE1->(MsUnLock())
            (cAliasTrb)->(dbSkip())
        Enddo

        (cAliasTrb)->(dbCloseArea())
    Endif

    aEval(aArea,{|x| RestArea(x)})

Return()

/* =====================================================================================
Programa.:              xSAP12
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   
===================================================================================== */
User Function xSAP12()

Local _cEmp 	:= FWCodEmp()
Local _cEmpSap 	:= "" 
local _cFilSap	:= "" 
local _cDivSap	:= "" 

IF _cEmp = '2010' 
	U_CMVSAP12({"01","2010022001",20167})   
Else
	_cEmpSap 	:= GetMv("CMV_SAP001") 
	_cFilSap	:= GetMv("CMV_SAP002")
	_cDivSap	:= GetMv("CMV_SAP002")
    U_ZSAPF012({{_cEmpSap,_cFilSap,20167}})    //"01","2010022001"                                              
EndIf

Return()

/* =====================================================================================
Programa.:              SAP07_RETORNO
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Usado: ZSAPF007 e CMVSAP07
===================================================================================== */
WSSTRUCT SAP07_RETORNO
	WSDATA STATUS  as String
	WSDATA MSG	   as String
ENDWSSTRUCT

/* =====================================================================================
Programa.:              SAP07_LANCTO
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Usado: ZSAPF007 e CMVSAP07
===================================================================================== */
WSStruct SAP07_LANCTO
	
	WSDATA cabecalho	as SAP07_DADOS_CAB
	WSDATA itens		as array of SAP07_DADOS_ITENS
	
EndWSStruct

/* =====================================================================================
Programa.:              SAP07_DADOS_CAB
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Usado: ZSAPF007 e CMVSAP07
===================================================================================== */
WSStruct SAP07_DADOS_CAB
	
	WsData FilialProtheus			As String
	WsData LoteSAP					As String
	WsData DataLancto				As String

EndWSStruct

/* =====================================================================================
Programa.:              SAP07_DADOS_ITENS
Autor....:              Evandro Mariano
Data.....:              16/11/2022
Descricao / Objetivo:   Usado: ZSAPF007 e CMVSAP07
===================================================================================== */
WSStruct SAP07_DADOS_ITENS
	
	WsData Item					As String
	WsData TipoLancto			As String
	WsData ContaDebito			As String OPTIONAL
	WsData ContaCredito			As String OPTIONAL
	WsData Valor				As Float
	WsData Historico			As String
	WsData CentroCustoDebito	As String OPTIONAL
	WsData CentroCustoCredito	As String OPTIONAL
	WsData ItemContaDebito 		As String OPTIONAL
	WsData ItemContaCredito		As String OPTIONAL
	WsData ClasseValorDebito	As String OPTIONAL
	WsData ClasseValorCredito	As String OPTIONAL
	WsData CNPJCliForDebito		As String OPTIONAL
	WsData CNPJCliForCredito	As String OPTIONAL
	
EndWSStruct
