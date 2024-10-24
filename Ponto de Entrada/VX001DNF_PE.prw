#Include "Protheus.ch"
#Include "Topconn.ch"

User Function VX001DNF()

Local lRet := .T.

lRet := GrvCD9()

Return()

Static Function GrvCD9()

	Local aArea		:= GetArea()     
	Local cEstadoVei:= ""

	VV0->(dbSetOrder(4))
	If ! VV0->(dbSeek(xFilial( "VV0" ) + SF2->F2_DOC + SF2->F2_SERIE))
		CONOUT("Atendimento nao encontrado")
		RestArea(aArea)
		Return
	EndIf

	SD2->(dbSetOrder(3))
	If ! SD2->(dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ))
		CONOUT("Item da Nota fiscal n�o encontrada")
		RestArea(aArea)
		Return
	EndIf

	//If VV0->VV0_TIPFAT  == "1"
	//	cEstadoVei := "9" // Usado
	//Else
	//	cEstadoVei := "0" //Novo
	//Endif
	cEstadoVei := tpvenda(VV0->VV0_NUMTRA)

	VVA->(dbSetOrder(1))
	If ! VVA->(dbSeek(xFilial("VVA") + VV0->VV0_NUMTRA))
		Conout("Item do atendimento nao encontrado.")
		Return .f.
	EndIf

	DbSelectArea( "VV1" )
	VV1->( DbSetOrder(1) )
	If ! VV1->( DbSeek( xFilial("VV1") + VVA->VVA_CHAINT ) )
		Conout("Item do atendimento nao encontrado.")
		Return .f.
	EndIf

	FGX_VV2() // Posiciona na tabela de modelos 

	DbSelectArea( "CD9" )
	DbSetOrder(1)

	If !(DbSeek(SD2->D2_FILIAL + "S" + SD2->D2_SERIE + SD2->D2_DOC + SD2->D2_CLIENTE + SD2->D2_LOJA + Padr(SD2->D2_ITEM,TamSx3("CD9_ITEM")[1]) + SD2->D2_COD)) //CD9_FILIAL+CD9_TPMOV+CD9_SERIE+CD9_DOC+CD9_CLIFOR+CD9_LOJA+CD9_ITEM+CD9_COD    

		RecLock( "CD9", .T. )
		CD9->CD9_FILIAL := SD2->D2_FILIAL
		CD9->CD9_TPMOV  := "S"
		CD9->CD9_DOC    := SD2->D2_DOC
		CD9->CD9_SERIE  := SD2->D2_SERIE
		CD9->CD9_ESPEC  := SF2->F2_ESPECIE
		CD9->CD9_CLIFOR := SD2->D2_CLIENTE
		CD9->CD9_LOJA   := SD2->D2_LOJA
		CD9->CD9_ITEM   := SD2->D2_ITEM
		CD9->CD9_COD    := SD2->D2_COD
		CD9->CD9_TPOPER := cEstadoVei//Tipo de Opera��o
		CD9->CD9_CHASSI := VV1->VV1_CHASSI //Chassi
		CD9->CD9_CORDE  := AllTrim( POSICIONE( "VVC", 1, xFilial( "VVC" ) + VV1->VV1_CODMAR + VV1->VV1_CORVEI, "VVC_GRUCOR" ) ) //C�digo da Cor segundo as regras de pr�-cadastro do DENATRAN.
		CD9->CD9_CODCOR := ALLTRIM(VV2->VV2_COREXT) + SUBSTR(VV2->VV2_CORINT,1,1)
		//CD9->CD9_CODCOR := AllTrim( POSICIONE( "VVC", 1, xFilial( "VVC" ) + VV1->VV1_CODMAR + VV1->VV1_CORVEI, "VVC_GRUCOR" ) ) //Codigo da cor definido pela montadora
		CD9->CD9_DSCCOR := AllTrim( POSICIONE( "VVC", 1, xFilial( "VVC" ) + VV1->VV1_CODMAR + VV1->VV1_CORVEI, "VVC_DESCRI" ) ) //Descri��o da Cor
		CD9->CD9_POTENC := cValToChar( VV2->VV2_POTMOT ) //Pot�ncia m�xima do motor do ve�culo em cavalo vapor (CV - pot�ncia ve�culo).
		CD9->CD9_CM3POT := VV2->VV2_CM3 //Capacidade volunt�ria do motor expressa em cent�metros c�bicos (CC - cilindradas).
		CD9->CD9_PESOLI := SF2->F2_PLIQUI //Peso Liquido
		CD9->CD9_PESOBR := SF2->F2_PBRUTO //Peso Bruto
		CD9->CD9_SERIAL := VV1->VV1_SERMOT //Serial (s�rie)
		CD9->CD9_TPCOMB := DeParaComb( VV1->VV1_COMVEI ) //Tipo Combust�vel
		CD9->CD9_NMOTOR := VV1->VV1_NUMMOT //Numero do Motor
		CD9->CD9_CMKG   := cValToChar( VV2->VV2_CAPTRA ) //CMT - Capacidade m�xima de tra��o - em toneladas.
		CD9->CD9_DISTEI := cValToChar( VV2->VV2_DISEIX ) //Distancia entre eixos
		CD9->CD9_RENAVA := Val( VV1->VV1_RENAVA ) //Renavam
		CD9->CD9_ANOMOD := Val( AllTrim( SubStr( VV1->VV1_FABMOD, 5, 4 ) ) ) //Ano Modelo
		CD9->CD9_ANOFAB := Val( AllTrim( SubStr( VV1->VV1_FABMOD, 1, 4 ) ) ) //Ano Frabrica��o
		CD9->CD9_TPPINT := AllTrim( POSICIONE( "VVC", 1, xFilial( "VVC" ) + VV1->VV1_CODMAR + VV1->VV1_CORVEI, "VVC_TIPCOR" ) ) //Tipo de Pintura 1 = Solida; 2 = Metalica
		CD9->CD9_TPVEIC := VV2->VV2_TIPVEI //Tipo de Ve�culo 06 = Automovel; 14 = Caminhao; 07 = Microonibus; 08 = Onibus; 10 = Reboque; 17 = C Trator
		CD9->CD9_ESPVEI := AllTrim( POSICIONE( "VVE", 1, xFilial( "VVE" ) + VV2->VV2_ESPVEI, "VVE_ESPREN") ) //Esp�cie de Ve�culo 02 = Carga; 04 = Corrida; 06 = Especial; 03 = Misto; 01 = Passageiro; 05 = Tracao
		CD9->CD9_CONVIN := IIF( VV1->VV1_PROVEI $ "01", "N", "R" ) //Informe se o ve�culo tem VIN (chassi) remarcado. 1 = Importado; 2 = Nacional
		CD9->CD9_CONVEI := "1" //Condi��o do Ve�culo 1 = Acabado; 2 = Inacabado; 3 = Semi-acabado
		CD9->CD9_CODMOD := VV2->VV2_MODFAB
		CD9->CD9_CILIND := cValToChar( VV2->VV2_CILMOT ) //Cilindradas
		CD9->CD9_TRACAO := cValToChar( VV2->VV2_CAPTRA ) //M�xima Tra��o
		CD9->CD9_LOTAC  := VV2->VV2_QTDPAS //Quantidade m�xima permitida de passageiros sentados, inclusive motorista.
		CD9->CD9_RESTR  := "0" //Restri��o
		CD9->( MsUnLock() )
	
	EndIf

	RestArea(aArea)

Return .T.	


/*
	Tabela de Combustivel RENAVAN 
	01 ALCOOL
	02 GASOLINA
	03 DIESEL
	04 GASOGENIO
	05 GAS METANO
	06 ELETRICO/FONTE INTERNA
	07 ELETRICO/FONTE EXTERNA
	08 GASOL/GAS NATURAL COMBUSTIVEL
	09 ALCOOL/GAS NATURAL COMBUSTIVEL
	10 DIESEL/GAS NATURAL COMBUSTIVEL
	11 VIDE/CAMPO/OBSERVACAO
	12 ALCOOL/GAS NATURAL VEICULAR
	13 GASOLINA/GAS NATURAL VEICULAR
	14 DIESEL/GAS NATURAL VEICULAR
	15 GAS NATURAL VEICULAR
	16 ALCOOL/GASOLINA
	17 GASOLINA/ALCOOL/GAS NATURAL
	18 GASOLINA/ELETRICOGASOLINA/ALCOOL/GAS NATURAL


*/
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

Static Function tpvenda(cNumtra)

	Local cRetorno := ""
	Local cQuery   := ""
	Local cTipo    := ""
	Local aAreaAtu := GetArea()
	
	Conout(" ")
	Conout(" tpvenda ")
	Conout(" ")

	cQuery := " SELECT VV0_NUMTRA, VRK_PEDIDO, VRJ_TIPVEN "
    cQuery += " FROM " +RetSqlTab("VV0")
    cQuery += " INNER JOIN " + RetSqlTab("VRK")+ " ON VV0.VV0_FILIAL = VRK.VRK_FILIAL "
    cQuery += " AND VV0.VV0_NUMTRA = VRK.VRK_NUMTRA AND VRK.D_E_L_E_T_ <> '*' "
    cQuery += " INNER JOIN "+ RetSqlTab("VRJ") 
    cQuery += " ON VRK.VRK_FILIAL = VRJ.VRJ_FILIAL " 
    cQuery += " AND VRK.VRK_PEDIDO = VRJ.VRJ_PEDIDO AND VRJ.D_E_L_E_T_ <> '*' "
    cQuery += " WHERE VV0.D_E_L_E_T_ <> '*' AND VV0_NUMTRA = '"+cNumtra+"'  

	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery New Alias "TMPAP"

	dbSelectArea("TMPAP")
	TMPAP->(dbGotop())
	cTipo := TMPAP->VRJ_TIPVEN
	
	If cTipo $ "02/03" ///04"
		cRetorno := "1"
	Else
		cRetorno := "0"
	Endif

	dbSelectArea("TMPAP")
	dbCloseArea()
	
	RestArea(aAreaAtu)
	
Return cRetorno
