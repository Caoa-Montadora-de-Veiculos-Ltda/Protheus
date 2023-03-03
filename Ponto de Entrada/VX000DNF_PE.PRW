#include "totvs.ch"

User Function VX000DNF()

	Local nOpcAux      := PARAMIXB[1]
	//Local cX0OpeMovAux := PARAMIXB[2]

	If nOpcAux <> 3
		Return
	EndIf
	
	If VVF->VVF_TIPDOC <> "1"
		Return
	EndIf

	DBSelectArea("SF1")
	DBSetOrder(1)
	DbSeek(xFilial("SF1") + VVF->VVF_NUMNFI + VVF->VVF_SERNFI + VVF->VVF_CODFOR + VVF->VVF_LOJA)

	xEndProd()

Return


Static Function xEndProd()
	
	Local aArea 	:= GetArea()
	local aAreaSF1	:= SF1->(GetArea())
	Local aAreaSDA	:= SDA->(GetArea())
	Local aAreaSDB	:= SDB->(GetArea())
	
	Local cAlias := ""
	Local aCabSDA := {}
	Local aItSDB := {}
	Local aItensSDB := {}
	Local nCount := 0
	local cLocal		:= allTrim( superGetMv( "CMV_VE1LOC"	, , "VEICULO NOVO"		) )	// Natureza para Nota fiscal SIGAVEI
	
	Private lMsErroAuto := .F.
	
	cAlias := getNextAlias()
	BeginSql Alias cAlias
		SELECT
			SD1.D1_COD,
			SD1.D1_CHASSI , 
			SDA.DA_NUMSEQ,
			SDA.DA_LOCAL,
			SD1.D1_QUANT, 
			SDA.DA_SALDO
		FROM
		%TABLE:SD1% SD1
		INNER JOIN %TABLE:SDA% SDA 
			ON SDA.DA_FILIAL = SD1.D1_FILIAL
			AND SDA.DA_DOC = SD1.D1_DOC
			AND SDA.DA_SERIE = SD1.D1_SERIE
			AND SDA.DA_CLIFOR = SD1.D1_FORNECE
			AND SDA.DA_LOJA = SD1.D1_LOJA
			AND SDA.DA_LOCAL = SD1.D1_LOCAL
			AND SDA.DA_ORIGEM = %EXP:"SD1"%
			AND SDA.DA_SALDO > %EXP:0%
			AND SDA.%NOTDEL%
		WHERE
			SD1.D1_FILIAL = %EXP:SF1->F1_FILIAL%
		AND SD1.D1_DOC = %EXP:SF1->F1_DOC%
		AND SD1.D1_SERIE = %EXP:SF1->F1_SERIE%
		AND SD1.D1_FORNECE = %EXP:SF1->F1_FORNECE%
		AND SD1.D1_LOJA = %EXP:SF1->F1_LOJA%
		AND SD1.%NOTDEL%
	EndSQl
	
	(cAlias)->(dbEval( { || nCount++ } ))
	(cAlias)->(dbGoTop())
	
	if nCount == 0
		alert("Sem itens disponíveis para o endereçamento!")
	else
		dbSelectArea("SDA")
		SDA->(dbSetOrder(1))
		
		ProcRegua( nCount )
		processMessage()
		
		While !(cAlias)->(EOF())
			incProc("Produto: " + allTrim((cAlias)->D1_COD) + " – Sequencial:"  + (cAlias)->DA_NUMSEQ )
			processMessage()
		
			SDA->(dbGoTop()) // posiciona o cabeçalho
			if SDA->(dbSeek( xfilial("SDA") + (cAlias)->D1_COD + (cAlias)->DA_LOCAL + (cAlias)->DA_NUMSEQ + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ))
				if SDA->DA_SALDO > 0
					lMsErroAuto := .F.
		
					aCabSDA := {}
					aAdd( aCabSDA, {"DA_PRODUTO" 	,SDA->DA_PRODUTO	, Nil} )
					aAdd( aCabSDA, {"DA_NUMSEQ" 	,SDA->DA_NUMSEQ 	, Nil} )
					
					aItSDB := {}
					aAdd( aItSDB, {"DB_ITEM" 	, '0001' 				, Nil} )
					aAdd( aItSDB, {"DB_ESTORNO"	, " " 					, Nil} )
					aAdd( aItSDB, {"DB_LOCALIZ"	, cLocal				, Nil} )
					aAdd( aItSDB, {"DB_DATA" 	, dDataBase 			, Nil} )
					aAdd( aItSDB, {"DB_QUANT" 	, SDA->DA_SALDO 		, Nil} )
					aAdd( aItSDB, {"DB_NUMSERI" , (cAlias)->D1_CHASSI 	, Nil} )
					
					aItensSDB := {}
					aadd( aItensSDB, aitSDB )
					MATA265( aCabSDA, aItensSDB, 3)
				endif
			endif
		
			(cAlias)->(dbSkip())
		enddo
	endif
	(cAlias)->(dbCloseArea())
	
	RestArea(aAreaSDB)
	RestArea(aAreaSDA)
	RestArea(aAreaSF1)
	RestArea(aArea)
	
Return
