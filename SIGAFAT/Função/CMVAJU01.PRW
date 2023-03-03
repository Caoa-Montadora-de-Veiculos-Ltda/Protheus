#include "totvs.ch"
#include "rwmake.ch"
#include "Protheus.ch"

/*
ajuste para correcao dos valores de nota fiscal de zona franca
*/

User Function CMVAJU01

Local aArea := {GetArea()}
Local cAliasTrb := GetNextAlias()
Local cQ := ""
local cPass := Space(50)
Local nPis := 0
Local nIcmDeson := 0
Local cTes := GetMv("CAOAAJU012",,"709/718")
//Local cTesDeson := GetMv("CAOAAJU014",,"718")
Local nTotalNf := 0
Local nAntPis := 0
Local nAntBasePis := 0
Local nAntTotalNf := 0
Local nBasePis := 0
Local aRet := {}
Local cSerie := Space(tamSx3("F2_SERIE")[1])
Local cNota := Space(tamSx3("F2_DOC")[1])
Local lRet := .F.
Local cRoot := GetSrvProfString( "RootPath" , "" )
Local cDir := "\AJUSTE_NF_ZF\"
Local cLog := ""
Local nDif := GetMv("CAOAAJU013",,200)
Local aParamBox := {}
Local nParc := 0

@ 067,020 To 169,312 Dialog oDlg Title OemToAnsi("Liberação de Acesso")
@ 015,005 Say OemToAnsi("Informe a senha para o acesso ?") Size 80,8
@ 015,089 Get cPass Size 50,10 Password
@ 037,055 BmpButton Type 1 Action fOK(oDlg,@lRet,cPass)
@ 037,106 BmpButton Type 2 Action (lRet:=.F.,Close(oDlg))
Activate Dialog oDlg CENTERED

If !lRet
	Return()
Endif

AAdd(aParamBox	, {1, "Serie Nota:",cSerie,"@!",,"",, 070	, .T.	})
AAdd(aParamBox	, {1, "Numero Nota",cNota,"@!",,"SF2",, 070	, .T.	})
//AAdd(aParamBox	, {1, "Valor Total NF:",nTotalNf,PesqPict("SF2","F2_VALBRUT"),,,, 070, .T.	})
AAdd(aParamBox	, {1, "Valor PIS:",nPis,PesqPict("SF2","F2_VALPS3"),,,, 070, .T.	})
AAdd(aParamBox	, {1, "Valor ICMS Desonerado:",nIcmDeson,PesqPict("CD2","CD2_DESONE") ,,,, 070, .F.	})

If ParamBox(aParambox,"Ajuste NF´s zona franca", @aRet, , , .T. /*lCentered*/, 0, 0, , , .T. /*lCanSave*/, .F. /*lUserSave*/)
	
	cSerie := aRet[1]
	cNota := aRet[2]
	//nTotalNf := aRet[3]
	nPis := aRet[3]
	nIcmDeson := aRet[4]

	cLog := "Ajuste_NF_ZF_"+Alltrim(cSerie)+"_"+Alltrim(cNota)+"_"+dTos(dDataBase)+"_"+StrTran(Time(),":","")+".txt"

	If !ExistDir(cRoot+cDir)
		If !MakeDir(cRoot+cDir) == 0
			Help( ,, "Help",, "Não foi criar diretório de LOG: "+cRoot+cDir, 1, 0 )
			
			Return()
		EndIf
	EndIF

	Begin Transaction 

	// sd2
	cQ := "SELECT R_E_C_N_O_ SD2_RECNO "
	cQ += "FROM "+RetSqlName("SD2")+" SD2 "
	cQ += "WHERE "
	cQ += "D2_FILIAL = '"+xFilial("SD2")+"' "
	cQ += "AND D2_SERIE = '"+cSerie+"' "
	cQ += "AND D2_DOC = '"+cNota+"' "
	cQ += "AND SD2.D_E_L_E_T_ = ' ' "
					
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
					
	If (cAliasTrb)->(!Eof())
		SD2->(dbGoto((cAliasTrb)->SD2_RECNO))
		If SD2->(Recno()) == (cAliasTrb)->SD2_RECNO
			
			// encontra valor total correto da nota
			nTotalNf := SD2->D2_VALBRUT-SD2->D2_VALPS3+nPis

			If !(SD2->D2_TES $ cTes)
				Help( ,, "Help",, "TES da nota não contido no parâmetro 'CAOAAJU012'.", 1, 0 )
				lRet := .F.
			Endif

			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
			//If (SD2->D2_TES $ cTesDeson) .and. Empty(nIcmDeson)
			If !Empty(SF4->F4_MOTICMS) .and. Empty(nIcmDeson)
				Help( ,, "Help",, "Icms Desonerado não informado no parâmetro.", 1, 0 )
				lRet := .F.
			Endif

			//If !(SD2->D2_TES $ cTesDeson) .and. !Empty(nIcmDeson)
			If Empty(SF4->F4_MOTICMS) .and. !Empty(nIcmDeson)
				Help( ,, "Help",, "Icms Desonerado informado indevidamente no parâmetro.", 1, 0 )
				lRet := .F.
			Endif
			
			If SD2->D2_BASEPS3 == SD2->D2_BASECF3 .or. SD2->D2_VALPS3 == nPis .or. SD2->D2_VALBRUT == nTotalNf
				Help( ,, "Help",, "Ajuste já foi executado anteriormente.", 1, 0 )
				lRet := .F.
			Endif	

			If SD2->D2_VALPS3 >= nPis
				Help( ,, "Help",, "Valor do PIS informado no parâmetro inválido.", 1, 0 )
				lRet := .F.
			Endif	

			If SD2->D2_VALBRUT >= nTotalNf
				Help( ,, "Help",, "Valor Total da NF informado no parâmetro inválido.", 1, 0 )
				lRet := .F.
			Endif	

			// diferenca entre valores nao pode ser maior que a do parametro
			If nTotalNf > (SD2->D2_VALBRUT+nDif)
				Help( ,, "Help",, "Verificar valor Total da Nf informado nos parâmetros, está acima do parâmetro 'CAOAAJU013'.", 1, 0 )
				lRet := .F.
			Endif	

			// diferenca entre valores nao pode ser maior que a do parametro
			If nPis > (SD2->D2_VALPS3+nDif)
				Help( ,, "Help",, "Verificar valor do PIS informado nos parâmetros, está acima do parâmetro 'CAOAAJU013'.", 1, 0 )
				lRet := .F.
			Endif	

			If lRet
				// guarda valores anteriores, caso precise restaurar
				nAntBasePis := SD2->D2_BASEPS3
				nAntPis := SD2->D2_VALPS3
				nAntTotalNf := SD2->D2_VALBRUT
				nBasePis := SD2->D2_BASECF3

				SD2->(RecLock("SD2",.F.))
				SD2->D2_VALBRUT := nTotalNf
				SD2->D2_BASEPS3 := SD2->D2_BASECF3
				SD2->D2_VALPS3 := nPis
				SD2->(MsUnLock())
			Endif	
		Endif	
	Else
		Help( ,, "Help",, "NF não localizada.", 1, 0 )
		lRet := .F.
	Endif			
	(cAliasTrb)->(dbCloseArea())

	If lRet
		// sf2
		cQ := "SELECT R_E_C_N_O_ SF2_RECNO "
		cQ += "FROM "+RetSqlName("SF2")+" SF2 "
		cQ += "WHERE "
		cQ += "F2_FILIAL = '"+xFilial("SF2")+"' "
		cQ += "AND F2_SERIE = '"+cSerie+"' "
		cQ += "AND F2_DOC = '"+cNota+"' "
		cQ += "AND SF2.D_E_L_E_T_ = ' ' "
						
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
						
		If (cAliasTrb)->(!Eof())
			SF2->(dbGoto((cAliasTrb)->SF2_RECNO))
			If SF2->(Recno()) == (cAliasTrb)->SF2_RECNO
				If !Empty(SF2->F2_CHVNFE)
					Help( ,, "Help",, "Nota já transmitida ao Sefaz.", 1, 0 )
					lRet := .F.
				Endif	

				If lRet
					SF2->(RecLock("SF2",.F.))
					SF2->F2_VALBRUT := nTotalNf
					SF2->F2_VALFAT := nTotalNf
					SF2->F2_BASEPS3 := SF2->F2_BASECF3
					SF2->F2_VALPS3 := nPis
					SF2->(MsUnLock())

					MemoWrite(cRoot+cDir+cLog,"nAntBasePis := "+Str(nAntBasePis)+"	"+"nAntPis := "+Str(nAntPis)+"	"+"nAntTotalNf := "+Str(nAntTotalNf))
				Endif	
			Endif	
		Endif			
		(cAliasTrb)->(dbCloseArea())

		If lRet
			// cd2
			cQ := "SELECT R_E_C_N_O_ CD2_RECNO "
			cQ += "FROM "+RetSqlName("CD2")+" CD2 "
			cQ += "WHERE "
			cQ += "CD2_FILIAL = '"+xFilial("CD2")+"' "
			cQ += "AND CD2_SERIE = '"+cSerie+"' "
			cQ += "AND CD2_DOC = '"+cNota+"' "
			cQ += "AND CD2_CODCLI <> ' ' "
			cQ += "AND CD2.D_E_L_E_T_ = ' ' "
							
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
							
			While (cAliasTrb)->(!Eof())
				CD2->(dbGoto((cAliasTrb)->CD2_RECNO))
				If CD2->(Recno()) == (cAliasTrb)->CD2_RECNO
					CD2->(RecLock("CD2",.F.))
					If Alltrim(CD2->CD2_IMP) == "SOL"
						CD2->CD2_DESONE := nIcmDeson
					Endif	
					If Alltrim(CD2->CD2_IMP) == "PS3"
						CD2->CD2_BC := nBasePis
						CD2->CD2_VLTRIB := nPis
					Endif	
					CD2->(MsUnLock())
				Endif	
				(cAliasTrb)->(dbSkip())
			Enddo
			(cAliasTrb)->(dbCloseArea())

			// sf3
			cQ := "SELECT R_E_C_N_O_ SF3_RECNO "
			cQ += "FROM "+RetSqlName("SF3")+" SF3 "
			cQ += "WHERE "
			cQ += "F3_FILIAL = '"+xFilial("SF3")+"' "
			cQ += "AND F3_SERIE = '"+cSerie+"' "
			cQ += "AND F3_NFISCAL = '"+cNota+"' "
			cQ += "AND F3_CFO >= '5' "
			cQ += "AND SF3.D_E_L_E_T_ = ' ' "
							
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
							
			If (cAliasTrb)->(!Eof())
				SF3->(dbGoto((cAliasTrb)->SF3_RECNO))
				If SF3->(Recno()) == (cAliasTrb)->SF3_RECNO
					SF3->(RecLock("SF3",.F.))
					SF3->F3_VALCONT := nTotalNf
					SF3->F3_BASEPS3 := SF3->F3_BASECF3
					SF3->F3_VALPS3 := nPis
					SF3->(MsUnLock())
				Endif	
			Endif			
			(cAliasTrb)->(dbCloseArea())

			// sft
			cQ := "SELECT R_E_C_N_O_ SFT_RECNO "
			cQ += "FROM "+RetSqlName("SFT")+" SFT "
			cQ += "WHERE "
			cQ += "FT_FILIAL = '"+xFilial("SFT")+"' "
			cQ += "AND FT_SERIE = '"+cSerie+"' "
			cQ += "AND FT_NFISCAL = '"+cNota+"' "
			cQ += "AND FT_CFOP >= '5' "
			cQ += "AND SFT.D_E_L_E_T_ = ' ' "
							
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
							
			If (cAliasTrb)->(!Eof())
				SFT->(dbGoto((cAliasTrb)->SFT_RECNO))
				If SFT->(Recno()) == (cAliasTrb)->SFT_RECNO
					SFT->(RecLock("SFT",.F.))
					SFT->FT_VALCONT := nTotalNf
					SFT->FT_BASEPS3 := SFT->FT_BASECF3
					SFT->FT_VALPS3 := nPis
					SFT->(MsUnLock())
				Endif	
			Endif			
			(cAliasTrb)->(dbCloseArea())

			// se1
			cQ := "SELECT R_E_C_N_O_ SE1_RECNO "
			cQ += "FROM "+RetSqlName("SE1")+" SE1 "
			cQ += "WHERE "
			cQ += "E1_FILIAL = '"+xFilial("SE1")+"' "
			cQ += "AND E1_PREFIXO = '"+cSerie+"' "
			cQ += "AND E1_NUM = '"+cNota+"' "
			cQ += "AND SE1.D_E_L_E_T_ = ' ' "
							
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
							
			While (cAliasTrb)->(!Eof())
				nParc++
				If nParc > 1 // nao pode ter mais de 1 parcela, senao ajusta fura
					lRet := .F.
				Endif
				If lRet	
					SE1->(dbGoto((cAliasTrb)->SE1_RECNO))
					If SE1->(Recno()) == (cAliasTrb)->SE1_RECNO
						SE1->(RecLock("SE1",.F.))
						SE1->E1_VALOR := nTotalNf
						SE1->E1_SALDO := nTotalNf
						SE1->E1_VLCRUZ := nTotalNf
						SE1->E1_VALJUR := nTotalNf*(SE1->E1_PORCJUR/100)
						SE1->(MsUnLock())
					Endif	
				Endif	
				(cAliasTrb)->(dbSkip())
			Enddo
			(cAliasTrb)->(dbCloseArea())

			If lRet
				// ct2
				cQ := "SELECT R_E_C_N_O_ CT2_RECNO "
				cQ += "FROM "+RetSqlName("CT2")+" CT2 "
				cQ += "WHERE "
				cQ += "CT2_FILIAL = '"+xFilial("CT2")+"' "
				cQ += "AND CT2_LOTE = '008820' "
				cQ += "AND CT2_HIST LIKE '%"+cNota+"%' "
				cQ += "AND CT2_TPSALD = '1' "
				cQ += "AND CT2_LP = '610' "
				cQ += "AND SUBSTR(CT2_ORIGEM,1,7) IN ('610-001','610-002','610-013','610-014') "
				cQ += "AND CT2.D_E_L_E_T_ = ' ' "
								
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
								
				While (cAliasTrb)->(!Eof())
					CT2->(dbGoto((cAliasTrb)->CT2_RECNO))
					If CT2->(Recno()) == (cAliasTrb)->CT2_RECNO
						CT2->(RecLock("CT2",.F.))
						If Subs(CT2->CT2_ORIGEM,1,7) == '610-001' .or. Subs(CT2->CT2_ORIGEM,1,7) == '610-002'
							CT2->CT2_VALOR := nTotalNf
						Endif	
						If Subs(CT2->CT2_ORIGEM,1,7) == '610-013' .or. Subs(CT2->CT2_ORIGEM,1,7) == '610-014'
							CT2->CT2_VALOR := nPis
						Endif	
						CT2->(MsUnLock())
					Endif	
					(cAliasTrb)->(dbSkip())
				Enddo
				(cAliasTrb)->(dbCloseArea())

				// cv3
				cQ := "SELECT R_E_C_N_O_ CV3_RECNO "
				cQ += "FROM "+RetSqlName("CV3")+" CV3 "
				cQ += "WHERE "
				cQ += "CV3_FILIAL = '"+xFilial("CV3")+"' "
				cQ += "AND CV3_LP = '610' "
				cQ += "AND CV3_HIST LIKE '%"+cNota+"%' "
				cQ += "AND CV3_LPSEQ IN ('001','002','013','014') "
				cQ += "AND CV3_TABORI = 'SD2' "
				cQ += "AND CV3.D_E_L_E_T_ = ' ' "
								
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
								
				While (cAliasTrb)->(!Eof())
					CV3->(dbGoto((cAliasTrb)->CV3_RECNO))
					If CV3->(Recno()) == (cAliasTrb)->CV3_RECNO
						CV3->(RecLock("CV3",.F.))
						If CV3->CV3_LPSEQ $ "001/002"
							CV3->CV3_VLR01 := nTotalNf
						Endif	
						If CV3->CV3_LPSEQ $ "013/014"
							CV3->CV3_VLR01 := nPis
						Endif	
						CV3->(MsUnLock())
					Endif	
					(cAliasTrb)->(dbSkip())
				Enddo
				(cAliasTrb)->(dbCloseArea())

				// ctk
				cQ := "SELECT R_E_C_N_O_ CTK_RECNO "
				cQ += "FROM "+RetSqlName("CTK")+" CTK "
				cQ += "WHERE "
				cQ += "CTK_FILIAL = '"+xFilial("CTK")+"' "
				cQ += "AND CTK_LP = '610' "
				cQ += "AND CTK_HIST LIKE '%"+cNota+"%' "
				cQ += "AND CTK_LPSEQ IN ('001','002','013','014') "
				cQ += "AND CTK_TABORI = 'SD2' "
				cQ += "AND CTK_LOTE = '8820' "
				cQ += "AND CTK_TPSALD = '1' "
				cQ += "AND CTK.D_E_L_E_T_ = ' ' "
								
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),cAliasTrb,.T.,.T.)
								
				While (cAliasTrb)->(!Eof())
					CTK->(dbGoto((cAliasTrb)->CTK_RECNO))
					If CTK->(Recno()) == (cAliasTrb)->CTK_RECNO
						CTK->(RecLock("CTK",.F.))
						If CTK->CTK_LPSEQ $ "001/002"
							CTK->CTK_VLR01 := nTotalNf
						Endif	
						If CTK->CTK_LPSEQ $ "013/014"
							CTK->CTK_VLR01 := nPis
						Endif	
						CTK->(MsUnLock())
					Endif	
					(cAliasTrb)->(dbSkip())
				Enddo
				(cAliasTrb)->(dbCloseArea())
				Help( ,, "Help",, "Ajuste finalizado com sucesso.", 1, 0 )
			Else
				DisarmTransaction()
			Endif	
		Else
			DisarmTransaction()
		Endif
	Else
		DisarmTransaction()
	Endif	
			
	End Transaction 

Endif	

aEval(aArea,{|x| RestArea(x)})

Return()


Static Function fOK(oDlg,lRet,cPass)

local cPassRot := GetMv("CAOAAJU011",,"ZF")

If ALLTRIM(cPass) <> cPassRot
	Help( ,, "Help",, "Senha não confere com a do parâmetro 'CAOAAJU011'.", 1, 0 )
   	cPass := Space(50)
   	lRet := .F.
   	dlgRefresh(oDlg)
Else
   	Close(oDlg)
   	lRet := .T.
Endif

Return()
