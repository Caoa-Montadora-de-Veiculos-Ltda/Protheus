#include 'TOPCONN.CH'

#Define CRLF CHAR(13) + CHAR(10)

//  SJL e SJK
User Function ZEICF008()
	Local aPergs    := {}
	Local aRetP     := {}
	Private aCampos := SetCampos()

	aAdd(aPergs, {6, "Arquivo", Space(1024), "", "", "", 90, .F., "Planilha Excel|*.xlsx|Arquivo Excel 2003|*.xls", Strtran(GetTempPath(), "\AppData\Local\Temp\", "")})

	If ParamBox(aPergs, "Informe o arquivo:", aRetP, , , , , , , , 50, .T.) = .T.
		Processa({|| zAtualizar() }, "[ZEICF008]", "Processando planilha" )
	EndIf
Return

Static Function GetCp(cCampo)
	Local oVal  := Nil
	Local oHash := Nil

	oHash := AToHM( aCampos )

	HMGet(oHash, cCampo, oVal)
Return (oVal[1,3])

Static Function SetCampos()
	Local aRes := {}
	Aadd(aRes, {"cod",   "produto",          01})
	Aadd(aRes, {"ncm",    "NCM",             02})
	Aadd(aRes, {"nve_aa",  "nive aa",         03})
	Aadd(aRes, {"es_aa",  "esp aa",          04})
	Aadd(aRes, {"nve_ab",  "nive ab",         05})
	Aadd(aRes, {"es_ab",  "esp ab",          06})
	Aadd(aRes, {"nve_ac",  "nive ac",         07})
	Aadd(aRes, {"es_ac",  "esp ac",          08})
	Aadd(aRes, {"nve_ad",  "nive ad",         09})
	Aadd(aRes, {"es_ad",  "esp ad",          10})
	Aadd(aRes, {"nv_class",  "nivel",           11})
Return aRes


Static Function zAtualizar()
     Local cVlNve    := ""
	Local cErr      := ""
	Local i         := 1
	Local aIt       := u_XlsxToArr(Alltrim(MV_PAR01), "1", Nil, .T.)

     ProcRegua( Len(aIt) )
	
     For i:=2 to Len(aIt)

          IncProc("Item..." + CvalToChar(i))

		If Len(aIt[i]) < 11
			Loop
		EndIf

		If Vazio(Posicione("SB1", 1, Xfilial("SB1") + aIt[i, GetCp("cod")], "B1_COD"))
			cErr += "Linha " + Padl(i, 5, "0") + " - " + aIt[i, GetCp("cod")] + " não é cadastrado"  + Char(13) + Char(10)
			Loop
		Endif

		If Vazio(Posicione("SYD",1, Xfilial("SYD") + aIt[i, GetCp("ncm")] , "YD_TEC")) = .T.
               cErr += " - " + CvalToChar(i) + " Erro: NCM não existe no cadastro NCM: " + aIt[i, GetCp("ncm")] + Char(13) + Char(10)
			Loop
		EndIf

          cNvClass := zGetCodNv(i, aIt[i, GetCp("nv_class")])
          If cNvClass = ""  
               cErr += " - " + "Linha:" + PadL(i, 5, "0") + " Nao previsto,  valor: " + cNvClass  + Char(13) + Char(10)
			Loop
		EndIf


          // AA
          If Vazio(aIt[i, GetCp("nve_aa")]) = .F.
               
               cVlNve := PadL( Alltrim(aIt[i, GetCp("nve_aa")]), 4, "0")

               zChkSJK(PadR(aIt[i, GetCp("ncm")], TamSx3("JK_NCM")[1], " "), "AA", Upper(aIt[i, GetCp("es_aa")]),  cNvClass )

               zChkSJL(PadR(aIt[i, GetCp("ncm")], TamSx3("JK_NCM")[1], " "), "AA", Upper(aIt[i, GetCp("es_aa")]), cVlNve, cNvClass )
          
               ZchkEIM(i, aIt[i, GetCp("cod")], aIt[i, GetCp("ncm")], "AA", cVlNve, aIt[i, GetCp("es_aa")], cNvClass  )
          EndIf

          // AB
          If Vazio(aIt[i, GetCp("nve_ab")]) = .F.
               
               cVlNve := PadL( Alltrim(aIt[i, GetCp("nve_ab")]), 4, "0")

               zChkSJK(PadR(aIt[i, GetCp("ncm")], TamSx3("JK_NCM")[1], " "), "AB", Upper(aIt[i, GetCp("es_ab")]),  cNvClass )

               zChkSJL(PadR(aIt[i, GetCp("ncm")], TamSx3("JK_NCM")[1], " "), "AB", Upper(aIt[i, GetCp("es_ab")]),  cVlNve, cNvClass )
          
               ZchkEIM(i, aIt[i, GetCp("cod")], aIt[i, GetCp("ncm")], "AB", cVlNve, aIt[i, GetCp("es_ab")], cNvClass  )               
          EndIf

          // AC
          If Vazio(aIt[i, GetCp("nve_ac")]) = .F.

               cVlNve := PadL( Alltrim(aIt[i, GetCp("nve_ac")]), 4, "0")

               zChkSJK(PadR(aIt[i, GetCp("ncm")], TamSx3("JK_NCM")[1], " "), "AC", Upper(aIt[i, GetCp("es_ac")]),  cNvClass )

               zChkSJL(PadR(aIt[i, GetCp("ncm")], TamSx3("JK_NCM")[1], " "), "AC", Upper(aIt[i, GetCp("es_ac")]),  cVlNve, cNvClass )
          
               ZchkEIM(i, aIt[i, GetCp("cod")], aIt[i, GetCp("ncm")], "AC", cVlNve, aIt[i, GetCp("es_ac")], cNvClass  )               
          EndIf

          // AD
          If Vazio(aIt[i, GetCp("nve_ad")]) = .F.

               cVlNve := PadL( Alltrim(aIt[i, GetCp("nve_ad")]), 4, "0")

               zChkSJK(PadR(aIt[i, GetCp("ncm")], TamSx3("JK_NCM")[1], " "), "AD", Upper(aIt[i, GetCp("es_ad")]),  cNvClass )

               zChkSJL(PadR(aIt[i, GetCp("ncm")], TamSx3("JK_NCM")[1], " "), "AD", Upper(aIt[i, GetCp("es_ad")]),  cVlNve, cNvClass )
          
               ZchkEIM(i, aIt[i, GetCp("cod")], aIt[i, GetCp("ncm")], "AD", cVlNve, aIt[i, GetCp("es_ad")], cNvClass  )               
          EndIf
	Next

     If cErr <> ""
          EecView(cErr, "Problemas encontrados na leitura do arquivo:")
     EndIf

Return


/*
     Verifica o cadastro da SJK, se não houver, inclui 
*/
Static Function ZchkEIM(nLinha, cCod, cNCM, cAtrib, cVlAtrib, cDescAtr, cVlnivel)
     Local lExiste := .F.
     Local cTb := GetNextAlias()      
     Local cmd := ""

     cmd += CRLF + " SELECT R_E_C_N_O_ AS REC FROM " + RetSqlName("EIM") + " EIM "
     cmd += CRLF + " WHERE "
     cmd += CRLF + "     D_E_L_E_T_ = ' ' "
     cmd += CRLF + " AND EIM_FILIAL = '" + Xfilial("EIM") + "' "
     cmd += CRLF + " AND EIM_HAWB   = '" + cCod    + "' "
     cmd += CRLF + " AND EIM_ATRIB  = '" + cAtrib  + "' "

     TcQuery cmd new alias (cTb)

     lExiste := !(Vazio((cTb)->REC))

     (cTb)->(DbCloseArea())

     If lExiste = .T.     
          Return
     EndIf

     RecLock("EIM", .T.)
     EIM->EIM_FILIAL     := Xfilial("EIM")
     EIM->EIM_HAWB       := cCod
     EIM->EIM_NIVEL      := cVlnivel
     EIM->EIM_ATRIB      := cAtrib
     EIM->EIM_DES_AT     := Upper(cDescAtr)
     EIM->EIM_ESPECI     := cVlAtrib
     EIM->EIM_DES_ES     := Upper(cDescAtr)
     EIM->EIM_ADICAO     := Space(TamSx3("EIM_ADICAO")[1])
     EIM->EIM_CODIGO     := "001"
     EIM->EIM_NCM        := cNCM
     EIM->EIM_FASE       := "CD"

     EIM->(MsUnlock())

Return


/*
     Verifica o cadastro da SJK, se não houver, inclui 
*/
Static Function ZchkSJK(cNCM, cAtrib, cDescAtr, cNivel)

     If Vazio(Posicione("SJK", 1, Xfilial("SJK") + cNCM + cAtrib, "JK_NCM" )) = .T.   // JK_FILIAL+JK_NCM+JK_ATRIB
          RecLock("SJK", .T.)
          JK_FILIAL  := Xfilial("SJK")
          JK_NCM     := cNCM 
          JK_ATRIB   := cAtrib 
          JK_DES_ATR := cDescAtr
          JK_MULTIPL := 'N'
          JK_NIVEL   := "2"

          SJK->(MsUnLock())
     EndIf
Return


/*
     Verifica o cadastro da SJL, se não houver, inclui 
*/
Static function ZchkSJL(cNCM, cAtrib, cVlAtrib, cDesc, cNivel)

     If Vazio(Posicione("SJL", 1, Xfilial("SJL") + cNCM + cAtrib, "JL_NCM" )) = .T.   // JK_FILIAL+JK_NCM+JK_ATRIB
          RecLock("SJL", .T.)     
          SJL->JL_FILIAL := Xfilial("SJL")
          SJL->JL_NCM    := cNCM
          SJL->JL_ATRIB  := cAtrib
          SJL->JL_ESPECIF:= cDesc
          SJL->JL_DES_ESP:= cVlAtrib
          SJL->JL_NIVEL  := cNivel
          SJL->(MsUnLock())
     EndIf
Return


Static Function zGetCodNv(nLinha, cNivel)
     cRes := ""
     // 1=C-Capitulo;2=P-Posicion;3=U-SubItem;4=AS-SubPosicion Nivel 1;5=BS-SubPosicion Nivel2;6=N-Item
     If cNivel = "C"
          cRes := "1"
     ElseIf cNivel = "P"      
          cRes := "2"
     ElseIf cNivel = "U"      
          cRes := "3"
     ElseIf (cNivel = "AS") .or. (cNivel = "SA")
          cRes := "4"
     ElseIf (cNivel = "SB") .or. (cNivel = "BS")      
          cRes := "5"
     ElseIf cNivel = "N"      
          cRes := "6"
     EndIF
Return cRes

