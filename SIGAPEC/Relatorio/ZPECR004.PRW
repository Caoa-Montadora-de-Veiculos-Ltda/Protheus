// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 12     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "Ofipr120.ch"
#include "Protheus.ch"
#include 'TOPCONN.CH'
#include 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ZPECR004 ³ Autor ³  Sandro        ³ Data ³ 05/10/21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Demonstrativo de Metas de Vendas - Graficos         |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ZPECR004()
Private cNomeProg  := "OFIPR120"
Private cNomeRel   := "OFIPR120"
Private aReturn    := { STR0002, 1,STR0003, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cTamanho   := "M"           // P/M/G
Private nCaracter  := 18
Private cStr       := ""
Private nTotal     := 0
Private nTotalGeral:= 0
Private nOpca      := 2
Private cMes       := strzero(month(dDataBase),2)
Private cAno       := strzero(year(dDataBase),4)
Private cPrefix    := STR0004
Private aPrefix    := {STR0004,STR0005,STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014}
Private cTipo      := STR0015
Private aTipo      := {STR0016}   //{STR0015,STR0016}  // Mensal / Anual
Private cSabDom    := STR0018
Private aSabado    := {STR0017,STR0018,STR0019}
Private cmodelo    := "Vendas"
Private aModelo    := {"Vendas","Vendas Perdidas","Vendas Previstas x Realizadas"}
Private lOk        := .t.
Private nMetMes    := 0
Private nDias      := 0
Private nPercDia   := 0
Private nPercMet   := 0
Private nPercEqui  := 0
Private nTotEqui   := 0
Private nTotMet    := 0
Private nTotPDia   := 0
Private nTotPMet   := 0
Private nTotReal   := 0
Private nTotPEqui  := 0
Private nTotalD2   := 0
Private nTMetMes   := 0
Private nTPonEqui  := 0
Private nAMetMes   := 0
Private nAotReal   := 0
Private nAPonEqui  := 0
Private aDias      := {}
Private aVend      := {}
Private aTotMes	   := {}
Private cPerg      := nil
Private nTotRec    := 0
Private cPref      := space(3)
Private nPonEqui   := 0
Private aFeriados  := {}
Private nQtdVei    := 0
Private nQtd       := 0
Private cDia       := 0
Private nCont      := 0
Private nTQtdDia   := 0
Private nTotMes    := 0
Private nQtdReal   := 0
Private nTotRea    := 0

u_OFPR120R() // Executa versão anterior do fonte

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFPR120R3³ Autor ³  Thiago        ³ Data ³ 21/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Demonstrativo de Metas de Vendas                    |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER Function OFPR120R()

Private cAlias     := "VER"
Private cDesc1     := STR0001
Private cDesc2     := ""
Private cDesc3     := ""
Private cCabec1    := ""
Private cCabec2    := ""
Private aReturn    := { STR0002, 1,STR0003, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cTamanho   := "M"           // P/M/G
Private Limite     := 132           // 80/132/220
Private cTitulo    := STR0001

nOpca   := 2
cMes    := strzero(month(dDataBase),2)
cAno    := strzero(year(dDataBase),4)
cPrefix := STR0004
aPrefix := {STR0004,STR0005,STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014}
cTipo   := STR0015
aTipo   := {STR0016} //{STR0015,STR0016}  // Mensal / Anual
cSabDom := STR0018
aSabado := {STR0017,STR0018,STR0019}
lOk     := .t.
FS_TELAX(nOpca)

If nOpca == 1
	If cTipo == STR0016 // Anual
		cMes := "  "
	EndIf
	aFeriados := {}
	DbSelectArea("SX5")
	DbSetOrder(1)
	DbSeek(xFilial("SX5")+"63")
	While !Eof() .and. SX5->X5_TABELA == "63"  // Feriados
		If Empty(Alltrim(Substr(SX5->X5_DESCRI,7,2))) .or. Substr(SX5->X5_DESCRI,7,2) == right(cAno,2)
			If cMes # "  "
				If Substr(SX5->X5_DESCRI,4,2) == cMes
					Aadd(aFeriados,{left(SX5->X5_DESCRI,5)} )  //  Formato: DD/MM
				EndIf
			Else
				Aadd(aFeriados,{left(SX5->X5_DESCRI,5)} )  //  Formato: DD/MM
			EndIf
		EndIf
		DbSelectArea("SX5")
		DbSkip()
	EndDo
	cTitulo := STR0001+" "+If(cTipo#STR0016,cMes+"/","")+cAno+" "+left(cPrefix,3)

	FS_IMPRIMEX()
Endif

Return

Static Function FS_IMPRIMEX()

//Local oSection1 := Nil
Local ni := 0
Local x  := 0
Local y  := 0
Local cQAlVER := "SQLVER"
Local cQAlSF2 := "SQLSF2"
Local cQAlSD2 := "SQLSD2"
Local CQALVE6 := "SQLVE6"
Local w  := 0
Local i  := 0
Local nMes := 0
Local nIni := 0
Local nFin := 0
Local oChart
Local oDlgx
//Local oDlgy
Local cQuery	 := ""

//Local cVdaPerd   := GetNextAlias()
Local meta1, meta2, meta3, meta4, meta5, meta6, meta7, meta8, meta9, meta10, meta11, meta12 := 0
Local vend1, vend2, vend3, vend4, vend5, vend6, vend7, vend8, vend9, vend10, vend11, vend12 := 0
//Local aRand := {}
Private oSqlHlp := DMS_SqlHelper():New()
M_PAG := 1
nLin  := 80
aPag  := 1
clin  := 1
aTipo := {{"PCA"},{"PCV"},{"PCO"},{"SRV"},{"VEN"},{"VEU"},{"BAL","PCA","PCV"},{"OFI","PCO","SRV"},{"VEI","VEN","VEU"},{"PEC","BAL","PCO"},{"EMP","BAL","OFI","VEI"}}

dbSelectArea("VAI")
dbSetOrder(1)
dbGotop()
While !Eof()
	Aadd(aVend,{VAI->VAI_CODVEN,VAI->VAI_CC} )
	dbSkip()
Enddo


If cTipo == STR0016 // Anual
	nIni := Val("01")
	nFin := Val("12")
Else  // Mensal
	nIni := Val(cMes)
	nFin := Val(cMes)
EndIf
nCont:= 0
nMes := 0
For nMes:=nIni to nFin
	nCont++

	If cTipo # STR0016
		For ni:=1 to 8
			nCont++
		Next
	EndIf
	dDia := cTod("01/"+strzero(nMes,2)+"/"+cAno)
	aDias:= {}
	While strzero(Month(dDia),2) == strzero(nMes,2)
		If !Dow(dDia) == 1 .or. left(cSabDom,1) == "3" 		// "3 - Considerar de Segunda a Domingo"
			If !Dow(dDia) == 7 .or. left(cSabDom,1) >= "2" 	// "2 - Considerar de Segunda a Sabado"
				nPos := 0
				nPos := ascan(aFeriados,{|x| x[1] == strzero(day(dDia),2)+"/"+strzero(Month(dDia),2) })
				If nPos == 0
					Aadd(aDias,{day(dDia),0,0,0,0,0,0,0,0,0} )
				EndIf
			EndIf
		EndIf
		dDia++
	EndDo
	
	nPos1 := 0
	nPos2 := 0
	lRet  := .f.
	For x:=1 to Len(aTipo)
		For y:=1 to Len(aTipo[x])
			if aTipo[x,y] == Left(cPrefix,3)
				nPos1 := x
				nPos2 := y
				lRet := .t.
				Exit
			Endif
		Next
		if lRet
			Exit
		Endif
	Next
	if nPos1 == 0  .or. nPos2 == 0
		Return(.f.)
	Endif
	
	lAchou := .f.
	dbSelectArea("VER")
	dbSetOrder(1)
	lAchou := dbSeek(xFilial("VER")+aTipo[nPos1,nPos2]+cAno+strzero(nMes,2),.f.)
	If nPos2 <> 1 .and. !lAchou
		Return(.f.)
	Endif
	
	/////////////////////////// Andre Luis Almeida 07/02/03 /////////////////////////////
	
	cPesquisa := ""
	If lAchou
		cPesquisa := aTipo[nPos1,nPos2]
	Else
		For w:=2 to Len(aTipo[npos1])
			DbSelectArea("VER")
			DbSetOrder(1)
			If DbSeek(xFilial("VER")+aTipo[nPos1,w]+cAno+strzero(nMes,2),.f.)
				if w == Len(aTipo[npos1])
					cPesquisa += aTipo[nPos1,w]
				Else
					cPesquisa += aTipo[nPos1,w]+"','"
				Endif
			Else
				If aTipo[nPos1,w] == "BAL"
					cPesquisa += "PCA"+"','"+"PCV"
				ElseIf aTipo[nPos1,w] == "OFI"
					cPesquisa += "PCO"+"','"+"SRV"
				ElseIf aTipo[nPos1,w] == "VEI"
					cPesquisa += "VEN"+"','"+"VEU"
				EndIf
			EndIf
		Next
	EndIf
	
	cQuery := "SELECT VER.VER_FILIAL, VER.VER_PREFIX, VER.VER_ANO, VER.VER_MES, VER.VER_VALOR, VER.VER_PE, VER.VER_QTDVEI "
	cQuery += "FROM " + RetSqlName("VER") + " VER "
	cQuery += "WHERE VER.VER_FILIAL = '" + xFilial("VER") + "' AND VER.VER_PREFIX IN ('" + IIf(Empty(cPesquisa), " ", cPesquisa) + "') "
	cQuery += "  AND VER.VER_ANO = '" + cAno + "' AND VER.VER_MES = '" + strzero(nMes, 2) + "' AND VER.D_E_L_E_T_=' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVER , .F., .T. )
	
	While !( cQAlVER )->( Eof() )
		
		nMetMes  := ( cQAlVER )->VER_VALOR
		nPonEqui := ( cQAlVER )->VER_VALOR*(( cQAlVER )->VER_PE/100)
		
		nTMetMes += nMetMes
		nTQtdDia += ( cQAlVER )->VER_QTDVEI
		nTPonEqui+= nPonEqui
		nQtdVei  := ( cQAlVER )->VER_QTDVEI
		
		For i:=1 to len(aDias)
			aDias[i,2]  += nMetMes/len(aDias)
			aDias[i,3]  += nPonEqui/len(aDias)
			aDias[i,10] += nQtdVei/len(aDias)
		Next
		
		cQuery := "SELECT SF2.F2_FILIAL, SF2.F2_EMISSAO, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_PREFORI, SF2.F2_VEND1 "
		cQuery += "FROM " + RetSqlName("SF2") + " SF2 "
		cQuery += "WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' "

		If cTipo == STR0016 // Anual
			cQuery += "  AND " + oSqlHlp:CompatFunc('SUBSTR') + "(SF2.F2_EMISSAO, 1, 4) = '" + cAno + "' "
		Else
			cQuery += "  AND " + oSqlHlp:CompatFunc('SUBSTR') + "(SF2.F2_EMISSAO, 1, 6) = '" + cAno + cMes + "' "
		EndIf

		cQuery += "  AND " + oSqlHlp:CompatFunc('SUBSTR') + "(SF2.F2_EMISSAO, 1, 6) = '" + cAno + strzero(nMes, 2) + "' AND SF2.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSF2 , .F., .T. )
		
		While !( cQAlSF2 )->( Eof() )
			
			cQuery := "SELECT SD2.D2_FILIAL,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_TIPO,SD2.D2_TES,SD2.D2_TOTAL,SD2.D2_LOCAL,SD2.D2_EMISSAO "
			cQuery += "FROM "+RetSqlName("SD2")+" SD2 WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
			cQuery += "SD2.D2_DOC = '"+( cQAlSF2 )->F2_DOC+"' AND SD2.D2_SERIE = '"+( cQAlSF2 )->F2_SERIE+"' AND SD2.D2_CLIENTE = '"+( cQAlSF2 )->F2_CLIENTE+"' AND SD2.D2_LOJA = '"+( cQAlSF2 )->F2_LOJA+"' AND SD2.D_E_L_E_T_=' ' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSD2 , .F., .T. )
			
			While !( cQAlSD2 )->( Eof() )
				
				if ( cQAlSD2 )->D2_TIPO == "N"
					DbSelectArea("SF4")
					DbSetOrder(1)
					DbSeek(xFilial("SF4")+( cQAlSD2 )->D2_TES)
					
					if SF4->F4_DUPLIC == "S" .and. Alltrim(SF4->F4_ATUATF) <> "S"
						nTotalD2 := 0
						nQtd     := 0
						If "BAL" $ ( cQAlVER )->VER_PREFIX
							if ( cQAlSF2 )->F2_PREFORI ==  GetNewPar("MV_PREFBAL","BAL")
								if SF4->F4_ESTOQUE == "S"
									nTotalD2 := ( cQAlSD2 )->D2_TOTAL
								Endif
							Endif
						EndIf
						If "OFI" $ ( cQAlVER )->VER_PREFIX
							if ( cQAlSF2 )->F2_PREFORI == GetNewPar("MV_PREFOFI","OFI")
								nTotalD2 := ( cQAlSD2 )->D2_TOTAL
							Endif
						EndIf
						If "VEI" $ ( cQAlVER )->VER_PREFIX
							if ( cQAlSF2 )->F2_PREFORI == GetNewPar("MV_PREFVEI","VEI")
								if SF4->F4_ESTOQUE == "S"
									nTotalD2 := ( cQAlSD2 )->D2_TOTAL
									nQtd  := 1
								Endif
							Endif
						EndIf
						If "EMP" $ ( cQAlVER )->VER_PREFIX
							If ( cQAlSF2 )->F2_PREFORI == GetNewPar("MV_PREFBAL","BAL") .or. ( cQAlSF2 )->F2_PREFORI == GetNewPar("MV_PREFVEI","VEI")
								if SF4->F4_ESTOQUE == "S"
									nTotalD2 := ( cQAlSD2 )->D2_TOTAL
								Endif
							ElseIf ( cQAlSF2 )->F2_PREFORI == GetNewPar("MV_PREFOFI","OFI")
								nTotalD2 := ( cQAlSD2 )->D2_TOTAL
								nQtd  := 1
							Endif
						EndIf
						If "PEC" $ ( cQAlVER )->VER_PREFIX
							if ( cQAlSF2 )->F2_PREFORI == GetNewPar("MV_PREFBAL","BAL") .or. ( cQAlSF2 )->F2_PREFORI ==GetNewPar("MV_PREFOFI","OFI")
								if SF4->F4_ESTOQUE == "S"
									nTotalD2 := ( cQAlSD2 )->D2_TOTAL
								Endif
							Endif
						EndIf
						If "PCA" $ ( cQAlVER )->VER_PREFIX
							if ( cQAlSF2 )->F2_PREFORI == GetNewPar("MV_PREFBAL","BAL")
								if SF4->F4_ESTOQUE == "S"
									nPos := ascan(aVend,{|x| x[1] == ( cQAlSF2 )->F2_VEND1})
									dbSelectArea("VS1")
									dbSetOrder(3)
									dbSeek(xFilial("VS1")+( cQAlSF2 )->F2_DOC+( cQAlSF2 )->F2_SERIE)
									nTotalD2 := ( cQAlSD2 )->D2_TOTAL
								Endif
							Endif
						EndIf
						If "PCV" $ ( cQAlVER )->VER_PREFIX
							if ( cQAlSF2 )->F2_PREFORI == GetNewPar("MV_PREFBAL","BAL")
								if SF4->F4_ESTOQUE == "S"
									nPos := ascan(aVend,{|x| x[1] == ( cQAlSF2 )->F2_VEND1})
									dbSelectArea("VS1")
									dbSetOrder(3)
									dbSeek(xFilial("VS1")+( cQAlSF2 )->F2_DOC+( cQAlSF2 )->F2_SERIE)
									nTotalD2 := ( cQAlSD2 )->D2_TOTAL
								Endif
							Endif
						EndIf
						If "PCO" $ ( cQAlVER )->VER_PREFIX
							if ( cQAlSF2 )->F2_PREFORI == GetNewPar("MV_PREFOFI","OFI")
								if SF4->F4_ESTOQUE == "S"
									///////////// Brindes - Desconsiderar /////////////
									DbSelectArea( "VOO")
									DbSetOrder(4)
									If !DbSeek( xFilial("VOO") + ( cQAlSF2 )->F2_DOC+( cQAlSF2 )->F2_SERIE)
										DbSelectArea("SD2")
										Dbskip()
										Loop
									Endif
									nTotalD2 := ( cQAlSD2 )->D2_TOTAL
								Endif
							Endif
						EndIf
						If "SRV" $ ( cQAlVER )->VER_PREFIX
							if ( cQAlSF2 )->F2_PREFORI == GetNewPar("MV_PREFOFI","OFI")
								if SF4->F4_ESTOQUE == "N"
									nTotalD2 := ( cQAlSD2 )->D2_TOTAL
								Endif
							Endif
						EndIf
						If "VEN" $ ( cQAlVER )->VER_PREFIX
							if ( cQAlSF2 )->F2_PREFORI == GetNewPar("MV_PREFVEI","VEI") .and. ( cQAlSD2 )->D2_LOCAL == "VN"
								if SF4->F4_ESTOQUE == "S"
									nTotalD2 := ( cQAlSD2 )->D2_TOTAL
									nQtd  := 1
								Endif
							Endif
						EndIf
						If "VEU" $ ( cQAlVER )->VER_PREFIX
							if ( cQAlSF2 )->F2_PREFORI == GetNewPar("MV_PREFVEI","VEI") .and. ( cQAlSD2 )->D2_LOCAL == "VU"
								if SF4->F4_ESTOQUE == "S"
									nTotalD2 := ( cQAlSD2 )->D2_TOTAL
									nQtd  := 1
								Endif
							Endif
						EndIf
						cDiaEmi := day(stod(( cQAlSD2 )->D2_EMISSAO))
						nPos := ascan(aDias,{|x| x[1] == cDiaEmi })
						if nPos == 0
							nPos := len(aDias)
						Endif
						aDias[nPos,4] += nTotalD2
						aDias[nPos,9] += nQtd
					Endif
				Endif
				
				DbSelectArea(cQAlSD2)
				( cQAlSD2 )->( DbSkip() )
			EndDo
			( cQAlSD2 )->( dbCloseArea() )
			
			DbSelectArea(cQAlSF2)
			( cQAlSF2 )->( DbSkip() )
		EndDo
		( cQAlSF2 )->( dbCloseArea() )
		
		DbSelectArea(cQAlVER)
		( cQAlVER )->( DbSkip() )
	EndDo
	( cQAlVER )->( dbCloseArea() )
	
	//////////////////////////////////////////////////////////////////////////////////
	
	nCont++
	//IncRegua()
	
	If cTipo # STR0016
		For ni:=1 to 8
			nCont++
		Next
	EndIf
	
	nTotReal := 0
	nTotMeta := 0
	nTotPont := 0
	For i := 1 to len(aDias)
		nTotMeta += aDias[i,2]
		nTotPont += aDias[i,3]
		nTotReal += aDias[i,4]
		nQtdReal += aDias[i,9]
	Next
	nAcumulado := 0
	For i := 1 to len(aDias)
		nAcumulado += aDias[i,4]
		aDias[i,5] := (aDias[i,4]/aDias[i,2])*100
		aDias[i,6] := (nAcumulado/nTotMeta)*100
		aDias[i,7] := (nAcumulado/nTotPont)*100
		aDias[i,8] := (aDias[i,4]/aDias[i,3])*100
	Next
	If cTipo # STR0016
		nlin++
		nTotal := 0
		For x := 1 to len(aDias)
			if substr(cPrefix,1,3) $ "VEI/VEN/VEU/EMP"
				@ nLin++, 001 pSay strzero(aDias[x,1],2)+transform(aDias[x,2], "@E 99999,999,999.99")+transform(aDias[x,4], "@E 9999,999,999.99")+space(4)+transform(aDias[x,10], "999")+space(10)+transform(aDias[x,9], "@E 999")+"  "+transform(aDias[x,5], "@E 999999.9")+transform((aDias[x,6]), "@E 999999.9")+transform(aDias[x,3], "@E 999,999,999.99")+transform((aDias[x,8]), "@E 999999.9")+transform((aDias[x,7]), "@E 999999.9")
				nTotal += aDias[x,9]
			Else
				@ nLin++, 001 pSay strzero(aDias[x,1],2)+transform(aDias[x,2], "@E 99999,999,999.99")+transform(aDias[x,4], "@E 9999,999,999.99")+transform(aDias[x,5], "@E 9999999.9")+transform((aDias[x,6]), "@E 999999.9")+transform(aDias[x,3], "@E 999,999,999.99")+transform((aDias[x,8]), "@E 999999.9")+transform((aDias[x,7]), "@E 999999.9")
			Endif
		Next
		nLin+=2
		@ nLin++, 000 pSay left(replic("-",150),len(cCabec2))
		if substr(cPrefix,1,3) $ "VEI/VEN/VEU/EMP"
			@ nLin++, 000 pSay transform(nTMetMes, "@E 99999999,999,999.99")+transform(nTotReal, "@E 9999,999,999.99")+"    "+transform(nQtdVei, "@E 999")+space(10)+transform(nTotal, "@E 999")+space(10)+transform(((nTotReal/nTMetMes)*100), "@E 999999.9")+transform(nTPonEqui, "@E 999,999,999.99")+space(08)+transform(((nTotReal/nTPonEqui)*100), "@E 999999.9")
		Else
			@ nLin++, 000 pSay transform(nTMetMes, "@E 99999999,999,999.99")+transform(nTotReal, "@E 9999,999,999.99")+space(09)+transform(((nTotReal/nTMetMes)*100), "@E 999999.9")+transform(nTPonEqui, "@E 999,999,999.99")+space(08)+transform(((nTotReal/nTPonEqui)*100), "@E 999999.9")
		Endif
		@ nLin++, 000 pSay left(replic("-",150),len(cCabec2))
	Else
		Aadd(aTotMes,{strzero(nMes,2),transform(nTMetMes,"@E 99999,999,999.99"),nTotReal,transform(((nTotReal/nTMetMes)*100),"@E 999999.9"),transform(nTPonEqui,"@E 999,999,999.99"),transform(((nTotReal/nTPonEqui)*100),"@E 999999.9"),ntqtddia,nQtdReal} )
		nTotMes  += nTQtdDia
		nTotRea  += nQtdReal
		nTQtdDia := 0
		nQtdReal := 0
		nAMetMes += nTMetMes
		nAotReal += nTotReal
		nAPonEqui+= nTPonEqui
		nTMetMes := 0
		nTotReal := 0
		nTPonEqui:= 0
	EndIf
Next

if substr(cPrefix,1,3) $ "VEI/VEN/VEU/EMP"
	If cTipo == STR0016 // Anual
		//nAcumulado := 0
		For ni:=1 to len(aTotMes)
			nLin++
			nAcumulado += aTotMes[ni,3]
			@ nLin++, 001 pSay aTotMes[ni,1]+aTotMes[ni,2]+transform(aTotMes[ni,3],"@E 9999,999,999.99")+"    "+transform(aTotMes[ni,7],"9999")+"       "+transform(aTotMes[ni,8],"9999")+"   "+aTotMes[ni,4]+transform(((nAcumulado/nAMetMes)*100),"@E 999999.9")+aTotMes[ni,5]+aTotMes[ni,6]+transform(((nAcumulado/nAPonEqui)*100), "@E 999999.9")
		Next
	Endif
Else 
	If cTipo == STR0016 //Anual
		//Cria a Janela
		If cModelo == "Vendas"
		   //Seta o título do gráfico
	    	DEFINE MSDIALOG oDlgx PIXEL FROM 0,0 TO 400,600
		   		//Instância a classe
				oChart := FWChartBar():New()
				//Inicializa pertencendo a janela
				oChart:Init(oDlgx, .T., .T. )
				oChart:SetTitle("Vendas nos Últimos 12 Meses - R$(MM)", CONTROL_ALIGN_CENTER)

			    //Busca valores das Metas e vendas
				For ni:=1 to len(aTotMes)
					oChart:addSerie(aTotMes[ni,1], aTotMes[ni,3])
				Next

				//Define que a legenda será mostrada na esquerda
				oChart:setLegend( CONTROL_ALIGN_LEFT )

				//Constrói o gráfico
				oChart:Build()
    		ACTIVATE MSDIALOG oDlgx CENTERED

		ElseIF cModelo == "Vendas Perdidas"
			     DEFINE MSDIALOG oDlgx PIXEL FROM 0,0 TO 400,600
		   		 //Instância a classe
				 oChart := FWChartBar():New()

				 //Inicializa pertencendo a janela
				 oChart:Init(oDlgx, .T., .T. )
				 oChart:SetTitle("Vendas Perdidas nos Últimos 12 Meses - R$ (MM)", CONTROL_ALIGN_CENTER)


			cQuery := " SELECT " 
			cQuery += " VE6_DATREG, VE6_VALPEC" 
			cQuery += " FROM " + RetSQLName("VE6") + "  WHERE D_E_L_E_T_=' ' AND VE6_ORIREQ = '3' " 
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVE6 , .F., .T. )

                oChart:addSerie("01", 0)
                oChart:addSerie("02", 0)
                oChart:addSerie("03", 0)
                oChart:addSerie("04", 0)
                oChart:addSerie("05", 0)
                oChart:addSerie("06", 0)
				oChart:addSerie("07", 0)
				oChart:addSerie("08", 0)
				oChart:addSerie("09", 0)
				oChart:addSerie("10", 0)
				oChart:addSerie("11", 0)
				oChart:addSerie("12", 0)
	    		 While !(cQAlVE6)->(EOF())

				    If SUBSTRING(( cQAlVE6 )->VE6_DATREG,1,4) == cAno .and. SUBSTRING(( cQAlVE6 )->VE6_DATREG,5,2) = '01'
				       oChart:addSerie("01", (cQAlVE6)->VE6_VALPEC)
					Endif   
				    If SUBSTRING(( cQAlVE6 )->VE6_DATREG,1,4) == cAno .and. SUBSTRING(( cQAlVE6 )->VE6_DATREG,5,2) = '02'
				       oChart:addSerie("02", (cQAlVE6)->VE6_VALPEC)
					Endif   
					If SUBSTRING(( cQAlVE6 )->VE6_DATREG,1,4) == cAno .and. SUBSTRING(( cQAlVE6 )->VE6_DATREG,5,2) = '03'
				       oChart:addSerie("03", (cQAlVE6)->VE6_VALPEC)
					Endif   
				    If SUBSTRING(( cQAlVE6 )->VE6_DATREG,1,4) == cAno .and. SUBSTRING(( cQAlVE6 )->VE6_DATREG,5,2) = '04'
				       oChart:addSerie("04", (cQAlVE6)->VE6_VALPEC)
					Endif   
				    If SUBSTRING(( cQAlVE6 )->VE6_DATREG,1,4) == cAno .and. SUBSTRING(( cQAlVE6 )->VE6_DATREG,5,2) = '05'
				       oChart:addSerie("05", (cQAlVE6)->VE6_VALPEC)
					Endif   
					If SUBSTRING(( cQAlVE6 )->VE6_DATREG,1,4) == cAno .and. SUBSTRING(( cQAlVE6 )->VE6_DATREG,5,2) = '06'
				       oChart:addSerie("06", (cQAlVE6)->VE6_VALPEC)
					Endif   
					If SUBSTRING(( cQAlVE6 )->VE6_DATREG,1,4) == cAno .and. SUBSTRING(( cQAlVE6 )->VE6_DATREG,5,2) = '07'
				       oChart:addSerie("07", (cQAlVE6)->VE6_VALPEC)
					Endif   
					If SUBSTRING(( cQAlVE6 )->VE6_DATREG,1,4) == cAno .and. SUBSTRING(( cQAlVE6 )->VE6_DATREG,5,2) = '08'
				       oChart:addSerie("08", (cQAlVE6)->VE6_VALPEC)
					Endif   
					If SUBSTRING(( cQAlVE6 )->VE6_DATREG,1,4) == cAno .and. SUBSTRING(( cQAlVE6 )->VE6_DATREG,5,2) = '09'
				       oChart:addSerie("09", (cQAlVE6)->VE6_VALPEC)
					Endif   
				    If SUBSTRING(( cQAlVE6 )->VE6_DATREG,1,4) == cAno .and. SUBSTRING(( cQAlVE6 )->VE6_DATREG,5,2) = '10'
				       oChart:addSerie("10", (cQAlVE6)->VE6_VALPEC)
					Endif   
				    If SUBSTRING(( cQAlVE6 )->VE6_DATREG,1,4) == cAno .and. SUBSTRING(( cQAlVE6 )->VE6_DATREG,5,2) = '11'
				       oChart:addSerie("11", (cQAlVE6)->VE6_VALPEC)
					Endif   
				    If SUBSTRING(( cQAlVE6 )->VE6_DATREG,1,4) == cAno .and. SUBSTRING(( cQAlVE6 )->VE6_DATREG,5,2) = '12'
				       oChart:addSerie("12", (cQAlVE6)->VE6_VALPEC)
					Endif   
					(cQAlVE6)->(DbSkip()) 
 			 EndDo


			//If Select(cQAlVE6) > 0
		       //Seta o título do gráfico


				 //Define que a legenda será mostrada na esquerda
				 oChart:setLegend( CONTROL_ALIGN_LEFT )

				 //Constrói o gráfico
				 oChart:Build()
    		   ACTIVATE MSDIALOG oDlgx CENTERED
			//else
			//   Alert("Registro não encontrado na tabela VE6...")   
            //Endif
		Else

			DEFINE MSDIALOG oDlgx PIXEL FROM 0,0 TO 400,600

	   		//Instância a classe
			oChart := FWChartBarComp():New()

			//Inicializa pertencendo a janela
			oChart:Init(oDlgx, .T. )
			
		    oChart:SetTitle("Resultado de Vendas Previstas x Realizadas dos Últimos 12 Meses - R$ (MM)", CONTROL_ALIGN_CENTER)
  
            //Busca valores das Metas e vendas
			For ni:=1 to len(aTotMes)
			    if  ni     = 1
					    meta1 := aTotMes[ni,2]
					    meta1 := Val(StrTran(StrTran(meta1,".",""),",","."))
					    vend1 := transform( aTotMes[ni,3] , "@E 9999,999,999.99")
    				    vend1 := Val(StrTran(StrTran(vend1,".",""),",","."))
                ElseIf ni = 2 
					   meta2 := aTotMes[ni,2]
                       meta2 := Val(StrTran(StrTran(meta2,".",""),",","."))
					   vend2 := transform( aTotMes[ni,3] , "@E 9999,999,999.99")
					   vend2 := Val(StrTran(StrTran(vend2,".",""),",","."))
				ElseIf ni = 3
					   meta3 := aTotMes[ni,2]
					   meta3 := Val(StrTran(StrTran(meta3,".",""),",","."))
					   vend3 := transform( aTotMes[ni,3] , "@E 9999,999,999.99")
					   vend3 := Val(StrTran(StrTran(vend3,".",""),",","."))
				ElseIf ni = 4
					   meta4 := aTotMes[ni,2]
					   meta4 := Val(StrTran(StrTran(meta4,".",""),",","."))
					   vend4 := transform( aTotMes[ni,3] , "@E 9999,999,999.99")
					   vend4 := Val(StrTran(StrTran(vend4,".",""),",","."))
				ElseIf ni = 5
					   meta5 := aTotMes[ni,2]
					   meta5:= Val(StrTran(StrTran(meta5,".",""),",","."))
					   vend5 := transform( aTotMes[ni,3] , "@E 9999,999,999.99")
					   vend5 := Val(StrTran(StrTran(vend5,".",""),",","."))
				ElseIf ni = 6
					   meta6 := aTotMes[ni,2]
					   meta6 := Val(StrTran(StrTran(meta6,".",""),",","."))
					   vend6 := transform( aTotMes[ni,3] , "@E 9999,999,999.99")
					   vend6 := Val(StrTran(StrTran(vend6,".",""),",","."))
				ElseIf ni = 7
					   meta7 := aTotMes[ni,2]
					   meta7 := Val(StrTran(StrTran(meta7,".",""),",","."))
					   vend7 := transform( aTotMes[ni,3] , "@E 9999,999,999.99")
					   vend7 := Val(StrTran(StrTran(vend7,".",""),",",".")) 
				ElseIf ni = 8
					   meta8 := aTotMes[ni,2]
					   meta8 := Val(StrTran(StrTran(meta8,".",""),",","."))
					   vend8 := transform( aTotMes[ni,3] , "@E 9999,999,999.99")
					   vend8 := Val(StrTran(StrTran(vend8,".",""),",","."))
				ElseIf ni = 9
					   meta9 := aTotMes[ni,2]
					   meta9 := Val(StrTran(StrTran(meta9,".",""),",","."))
					   vend9 := transform( aTotMes[ni,3] , "@E 9999,999,999.99")
					   vend9 := Val(StrTran(StrTran(vend9,".",""),",","."))
				ElseIf ni = 10
					   meta10 := aTotMes[ni,2]
					   meta10 := Val(StrTran(StrTran(meta10,".",""),",","."))
					   vend10 := transform( aTotMes[ni,3] , "@E 9999,999,999.99")
					   vend10 := Val(StrTran(StrTran(vend10,".",""),",","."))
				ElseIf ni = 11
					   meta11 := aTotMes[ni,2]
					   meta11 := Val(StrTran(StrTran(meta11,".",""),",","."))
					   vend11 := transform( aTotMes[ni,3] , "@E 9999,999,999.99")
					   vend11 := Val(StrTran(StrTran(vend11,".",""),",","."))
				ElseIf ni = 12
					   meta12 := aTotMes[ni,2]
					   meta12 := Val(StrTran(StrTran(meta12,".",""),",","."))
					   vend12 := transform( aTotMes[ni,3] , "@E 9999,999,999.99")
					   vend12 := Val(StrTran(StrTran(vend12,".",""),",",".")) 
				EndIf
			Next

        	//Adicionando variaveis para o grafico
			oChart:addSerie( "Previsto",   { {"Jan", meta1}, {"Fev", meta2}, {"Mar", meta3}, {"Abr", meta4}, {"Mai", meta5}, {"Jun", meta6}, {"Jul", meta7}, {"Ago", meta8}, {"Set", meta9}, {"Out", meta10}, {"Nov", meta11}, {"Dez", meta12} } ) 
			oChart:addSerie( "Realizado",  { {"Jan", vend1}, {"Fev", vend2}, {"Mar", vend3}, {"Abr", vend4}, {"Mai", vend5}, {"Jun", vend6}, {"Jul", vend7}, {"Ago", vend8}, {"Set", vend9}, {"Out", vend10}, {"Nov", vend11}, {"Dez", vend12} } )


			//Define que a legenda será mostrada na esquerda
			oChart:setLegend( CONTROL_ALIGN_LEFT )
			
			//Constrói o gráfico
			oChart:Build()
    		ACTIVATE MSDIALOG oDlgx CENTERED

		Endif

	EndIf
Endif


Return

Static Function FS_TELAX(nOpca)

STR0023 := "Modelo"

DEFINE MSDIALOG oDlg1 FROM 000,000 TO 017,040 TITLE STR0020 OF oMainWnd

@ 013,018 SAY STR0021 SIZE 30,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 014,038 MSCOMBOBOX oPrefix VAR cPrefix SIZE 105,08 ITEMS aPrefix OF oDlg1 PIXEL COLOR CLR_BLUE

@ 028,018 SAY STR0022 SIZE 30,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 027,038 MSCOMBOBOX oTipo VAR cTipo SIZE 105,08 ITEMS aTipo VALID If(cTipo==STR0016,cMes:="  ",If(cMes=="  ",cMes := strzero(month(dDataBase),2),.t.)) OF oDlg1 PIXEL COLOR CLR_BLUE

//@ 043,018 SAY STR0023 SIZE 30,08 OF oDlg1 PIXEL COLOR CLR_BLUE
//@ 042,038 MSGET oMes VAR cMes PICTURE "99" SIZE 105,08 VALID If(((Val(cMes)>0).and.(Val(cMes)<13)),cMes:=strzero(Val(cMes),2),.f.) OF oDlg1 PIXEL COLOR CLR_BLUE WHEN cTipo==STR0015

@ 043,018 SAY STR0023 SIZE 30,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 042,038 MSCOMBOBOX oModelo VAR cModelo SIZE 105,08 ITEMS aModelo OF oDlg1 PIXEL COLOR CLR_BLUE


@ 058,018 SAY STR0024 SIZE 30,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 057,038 MSGET oAno VAR cAno PICTURE "9999" VALID IIf(len(Alltrim(cAno))==2,(cAno:=left(strzero(year(dDataBase),4),2)+cAno),.t.) SIZE 105,08 OF oDlg1 PIXEL COLOR CLR_BLUE

@ 073,018 SAY STR0025 SIZE 30,08 OF oDlg1 PIXEL COLOR CLR_BLUE
@ 072,038 MSCOMBOBOX oSabado VAR cSabDom SIZE 105,08 ITEMS aSabado OF oDlg1 PIXEL COLOR CLR_BLUE

DEFINE SBUTTON FROM 106,095 TYPE 1 ACTION ( nOpca:=1 , oDlg1:End()) ENABLE OF oDlg1 PIXEL
DEFINE SBUTTON FROM 106,035 TYPE 2 ACTION ( nOpca:=2 , oDlg1:End()) ENABLE OF oDlg1 PIXEL

ACTIVATE MSDIALOG oDlg1 CENTER

Return(nOpca)
