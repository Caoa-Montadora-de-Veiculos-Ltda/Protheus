#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

#DEFINE CRLF  Char(13) + Char(10)

/*
	Inclusão do registro da CD9 na emissao da nota de entrada de importacao,
	importacao d o tipo cbu
	Gap:EIC 108
*/
User Function ZEICF009()
	Local aStru    := {}
     Local cAux     := ""
	Local cQr      := getNextAlias() 
	Local cmd      := "" 
	Local i        := 1
	Local cErr     := ""	

     If Vazio(SF1->F1_HAWB) = .T.
          Return
     EndIf     

     cAux := Posicione("SW6", 1, Xfilial("SW6") + SF1->F1_HAWB, "W6_XTIPIMP") //W6_FILIAL+W6_HAWB   
	If Vazio(cAux) = .T.
		FWAlertError("Processo de inclusão dos dados complementares de produtos na nota não pode ser executado, pois falta o tipo de importação na SW6->W6_XTIPIMP", "ZEICF009")
		Return
	EndIf

	cAux := Posicione("ZZ8", 1, Xfilial("ZZ8") + cAux, "ZZ8_TIPO") //W6_FILIAL+W6_HAWB   
	If Alltrim(cAux) <> "000005" // nao é importacao de CBU (veiculos), então não precisa fazer nada 
		Return
	EndIf

	cmd := CRLF + "SELECT SB1.B1_GRTRIB, SB1.B1_LOCPAD, SB1.B1_ORIGEM, SB1.B1_PESO, SB1.B1_POSIPI, SD1.D1_BASEICM, SD1.D1_BASEIPI, "
	cmd += CRLF + "  SD1.D1_CHASSI, SD1.D1_CLASFIS, SD1.D1_FILIAL, SD1.D1_COD, SD1.D1_ITEM, SD1.D1_FILIAL, SD1.D1_ITEMPC, SD1.D1_LOCAL, "
	cmd += CRLF + "  SD1.D1_PEDIDO ,SD1.D1_TES, SD1.D1_TOTAL, SD1.D1_VALICM, SD1.D1_VUNIT, SF1.F1_BASEICM, SF1.F1_COND, SF1.F1_DOC, "
	cmd += CRLF + "  SF1.F1_DTDIGIT, SF1.F1_EMISSAO, SF1.F1_ESPECIE, SF1.F1_FILIAL, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_SERIE, SF1.F1_VALBRUT, "
	cmd += CRLF + "  SF1.F1_VALICM, SF1.F1_VALMERC, SF1.F1_TIPO, SF1.R_E_C_N_O_ RECSF1, SWN.WN_ANOFAB, SWN.WN_ANOMOD, SWV.WV_XMOTOR, "
	cmd += CRLF + "  VV2.VV2_CODMAR, VV2.VV2_MODVEI, VV2.VV2_COREXT, VV2.VV2_COMVEI, VV2.VV2_CILMOT, VV2.VV2_POTMOT, VV2.VV2_SEGMOD, VV2.VV2_CM3, "
	cmd += CRLF + "  VV2.VV2_PESBRU, VV2.VV2_PESLIQ, VV2.VV2_CAPTRA, VV2.VV2_QTDCIL, VV2.VV2_CILMOT, VV2.VV2_QTDEIX, VV2.VV2_DISEIX, VV2.VV2_PORTAS, "
	cmd += CRLF + "  VV2.VV2_TIPVEI, VV2.VV2_ESPVEI, VV2.VV2_MODFAB, VV2.VV2_QTDPAS "
	cmd += CRLF + "  FROM " + RetSqlName("SF1") + " SF1 "
	cmd += CRLF + "  INNER JOIN " + RetSqlName("SD1") + " SD1 ON SD1.D_E_L_E_T_ = ' ' AND SD1.D1_FILIAL = SF1.F1_FILIAL AND SD1.D1_DOC = SF1.F1_DOC AND SD1.D1_SERIE = SF1.F1_SERIE AND SD1.D1_FORNECE = SF1.F1_FORNECE AND	SD1.D1_LOJA = SF1.F1_LOJA "
	cmd += CRLF + "  left  JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '" + FwXfilial("SB1") + "' AND SB1.B1_COD = SD1.D1_COD "
	cmd += CRLF + "  left  JOIN " + RetSqlName("SWN") + " SWN ON SWN.D_E_L_E_T_ = ' ' AND SWN.WN_FILIAL = SF1.F1_FILIAL AND SWN.WN_DOC = SF1.F1_DOC AND SWN.WN_SERIE = SF1.F1_SERIE AND SWN.WN_FORNECE = SF1.F1_FORNECE  AND SWN.WN_LOJA = SF1.F1_LOJA "
	cmd += CRLF + "  left  JOIN " + RetSqlName("SWV") + " SWV ON SWV.D_E_L_E_T_ = ' ' AND SWV.WV_FILIAL = SWN.WN_FILIAL AND SWV.WV_HAWB = SWN.WN_HAWB AND SWV.WV_XVIN = SWN.WN_XVIN "
	cmd += CRLF + "  left  JOIN " + RetSqlName("VV2") + " VV2 ON VV2.D_E_L_E_T_ = ' ' AND VV2.VV2_FILIAL = '" + FwXfilial("VV2") + "' AND VV2.VV2_PRODUT = SWV.WV_COD_I "
	cmd += CRLF + "  WHERE "
	cmd += CRLF + "      SF1.F1_FILIAL  = '" + FwXfilial("SF1")+ "' "
	cmd += CRLF + "  AND SF1.F1_DOC	    = '" + SF1->F1_DOC     + "' "
	cmd += CRLF + "  AND SF1.F1_SERIE   = '" + SF1->F1_SERIE   + "' "
	cmd += CRLF + "  AND SF1.F1_FORNECE = '" + SF1->F1_FORNECE + "' "  
	cmd += CRLF + "  AND SF1.F1_LOJA    = '" + SF1->F1_LOJA    + "' "
	cmd += CRLF + "  AND SD1.D1_CHASSI <> ' ' "

	TcQuery cmd new alias (cQr)

	(cQr)->(Dbgotop())

	aStru := (cQr)->(DbSTruct())
	
	For i:=1 to Len(aStru)
		If Empty((cQr)->&(aStru[i,1]))
			cErr += CRLF + " - " + AllTrim(GetSx3Cache(aStru[i,1], "X3_TITULO")) + " (" + aStru[i,1] + ")"
		EndIf
	Next
	
	If !Empty(cErr)
		cErr := "Alguns campos necessários não estão preenchidos, solicite a correção antes de transmitir a nota fiscal." + CRLF + "Doc: " + SF1->F1_SERIE + "/" + SF1->F1_DOC + CRLF + cErr
		FWAlertError(cErr, "ZEICF009")
	EndIf

	DbSelectArea("CD9")
	DbSetOrder(1)

	if CD9->( DbSeek((cQr)->F1_FILIAL + "E" + (cQr)->F1_SERIE + (cQr)->F1_DOC + (cQr)->F1_FORNECE + (cQr)->F1_LOJA + (cQr)->D1_ITEM + (cQr)->D1_COD)) = .T.
		RecLock("CD9", .F.)
		CD9->(DbDelete())
		CD9->(MsUnLock())
	EndIf		

	RecLock( "CD9", .T. )
		CD9->CD9_FILIAL := (cQr)->D1_FILIAL
		CD9->CD9_TPMOV  := "E"
		CD9->CD9_DOC    := (cQr)->F1_DOC
		CD9->CD9_SERIE  := (cQr)->F1_SERIE
		CD9->CD9_ESPEC  := (cQr)->F1_ESPECIE
		CD9->CD9_CLIFOR := (cQr)->F1_FORNECE
		CD9->CD9_LOJA   := (cQr)->F1_LOJA
		CD9->CD9_ITEM   := (cQr)->D1_ITEM
		CD9->CD9_COD    := (cQr)->D1_COD
		CD9->CD9_TPOPER := "0"      // 0=Venta concesionaria;1=Facturacion directo;2=Venta directa;3=Venta de la concesionaria;9=Otros                                 
		CD9->CD9_CHASSI := (cQr)->D1_CHASSI //Chassi
		CD9->CD9_CORDE  := AllTrim( GetAdvFVal("VVC","VVC_GRUCOR",xFilial( "VVC" ) + (cQr)->VV2_CODMAR + (cQr)->VV2_COREXT, 1, "") ) //Código da Cor segundo as regras de pré-cadastro do DENATRAN.
		CD9->CD9_CODCOR := AllTrim( GetAdvFVal("VVC","VVC_GRUCOR",xFilial( "VVC" ) + (cQr)->VV2_CODMAR + (cQr)->VV2_COREXT, 1, "") ) //Codigo da cor definido pela montadora
		CD9->CD9_DSCCOR := AllTrim( GetAdvFVal("VVC","VVC_DESCRI",xFilial( "VVC" ) + (cQr)->VV2_CODMAR + (cQr)->VV2_COREXT, 1, "") ) //Descrição da Cor
		CD9->CD9_POTENC := cValToChar( VV2->VV2_POTMOT ) //Potência máxima do motor do veículo em cavalo vapor (CV - potência veículo).
		CD9->CD9_CM3POT := (cQr)->VV2_CM3 //Capacidade voluntária do motor expressa em centímetros cúbicos (CC - cilindradas).
		CD9->CD9_PESOLI := (cQr)->VV2_PESLIQ //Peso Liquido
		CD9->CD9_PESOBR := (cQr)->VV2_PESBRU //Peso Bruto
		CD9->CD9_SERIAL := (cQr)->WV_XMOTOR //Serial (série)
		CD9->CD9_TPCOMB := DeParaComb( (cQr)->VV2_COMVEI ) //Tipo Combustível
		CD9->CD9_NMOTOR := (cQr)->WV_XMOTOR //Numero do Motor
		CD9->CD9_CMKG   := cValToChar( (cQr)->VV2_CAPTRA ) //CMT - Capacidade máxima de tração - em toneladas.
		CD9->CD9_DISTEI := cValToChar( (cQr)->VV2_DISEIX ) //Distancia entre eixos
		CD9->CD9_RENAVA := Val( "0" ) //Renavam
		CD9->CD9_ANOMOD := Val( AllTrim( SubStr( (cQr)->WN_ANOMOD, 1, 4 ) ) ) //Ano Modelo
		CD9->CD9_ANOFAB := Val( AllTrim( SubStr( (cQr)->WN_ANOFAB, 1, 4 ) ) ) //Ano Frabricação
		CD9->CD9_TPPINT := AllTrim( GetAdvFVal("VVC","VVC_TIPCOR",xFilial( "VVC" ) + (cQr)->VV2_CODMAR + (cQr)->VV2_COREXT, 1, "") ) 
		CD9->CD9_TPVEIC := VV2->VV2_TIPVEI //Tipo de Veículo 06 = Automovel; 14 = Caminhao; 07 = Microonibus; 08 = Onibus; 10 = Reboque; 17 = C Trator
		CD9->CD9_ESPVEI := AllTrim( GetAdvFVal("VVE", "VVE_ESPREN", xFilial( "VVE" ) + (cQr)->VV2_ESPVEI, 1, "") )
		CD9->CD9_CONVIN := "R"  // IIF( VV1->VV1_PROVEI $ "01", "N", "R" ) //Informe se o veículo tem VIN (chassi) remarcado. 1 = Importado; 2 = Nacional
		CD9->CD9_CONVEI := "1"  //Condição do Veículo 1 = Acabado; 2 = Inacabado; 3 = Semi-acabado
		CD9->CD9_CODMOD := (cQr)->VV2_MODFAB
		CD9->CD9_CILIND := cValToChar( (cQr)->VV2_CILMOT ) //Cilindradas
		CD9->CD9_TRACAO := cValToChar( (cQr)->VV2_CAPTRA ) //Máxima Tração
		CD9->CD9_LOTAC  := (cQr)->VV2_QTDPAS //Quantidade máxima permitida de passageiros sentados, inclusive motorista.
		CD9->CD9_RESTR  := "0" //Restrição
	CD9->( MsUnLock() )

	(cQr)->(DbCloseArea())
 Return

Static Function DeParaComb( cCombVV1 )

	Local cRetorno := ""

	Conout(" ")
	Conout(" DeParaComb ")
	Conout(" ")

	Do Case
	Case cCombVV1 == "0" ; cRetorno := "02" // Gasolina
	Case cCombVV1 == "1" ; cRetorno := "01" // Alcool
	Case cCombVV1 == "2" ; cRetorno := "03" // Diesel
	Case cCombVV1 == "3" ; cRetorno := "15" // Gas Natural
	Case cCombVV1 == "4" ; cRetorno := "16" // Alcool/Gasolina
	Case cCombVV1 == "5" ; cRetorno := "17" // Alcool/Gasolina/GNV
	Case cCombVV1 == "9" ; cRetorno := ""// Sem Combustivel
	Case cCombVV1 == "A" ; cRetorno := "04" // Gasogenio
	Case cCombVV1 == "B" ; cRetorno := "05" // Gas Metano
	Case cCombVV1 == "C" ; cRetorno := "06" // Eletrico/Fonte Interna
	Case cCombVV1 == "D" ; cRetorno := "07" // Eletrico/Fonte Externa
	Case cCombVV1 == "E" ; cRetorno := "08" // Gasol/Gas Natural Combustivel
	Case cCombVV1 == "F" ; cRetorno := "09" // Alcool/Gas Natural Combustivel
	Case cCombVV1 == "G" ; cRetorno := "10" // Diesel/Gas Natural Combustivel
	Case cCombVV1 == "H" ; cRetorno := "12" // Alcool/Gas Natural Veicular
	Case cCombVV1 == "I" ; cRetorno := "13" // Gasolina/Gas Natural Veicular
	Case cCombVV1 == "J" ; cRetorno := "14" // Diesel/Gas Natural Veicular    
	Case cCombVV1 == "K" ; cRetorno := "18" // Gasolina/Eletrico
	Case cCombVV1 == "L" ; cRetorno := "19" // Gasolina/Alcool/Eletrico
	EndCase 

Return cRetorno


