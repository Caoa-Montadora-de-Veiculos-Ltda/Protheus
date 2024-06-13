#include 'protheus.ch'
#include 'parmtype.ch'

// rotina chamada pelo ponto de entrada MSD2460
// Gravação de registro em CD9 para NFS de Imobilização de Veículos
User function CMVVEI03()

	Local aArea := {SB1->(GetArea()),GetArea()}
	Local cVeiTes	:= SuperGetMv('CMV_VEITS1',.F.,"703/699/")
	Local cChassi

	If SD2->D2_TES $ cVeiTes 
		cChassi := GetAdvFVal("SC6","C6_CHASSI",xFilial("SC6")+SD2->(D2_PEDIDO+D2_ITEMPV+D2_COD),1,"")
		VV1->( dbSetOrder(2) ) // VV1_FILIAL + VV1_CHASSI
		If VV1->( dbSeek(xFilial("VV1")+cChassi) )
			//VV2->(DbSetOrder(2)) //VV2_FILIAL+VV2_CODMAR+VV2_SEGMOD
			//If VV2->( DbSeek( xFilial("VV2") + VV1->(VV1_CODMAR+VV1_SEGMOD) ))
			
			FGX_VV2() // Posiciona na tabela de modelos
			
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
				CD9->CD9_TPOPER := "0" // ou "3" 0=Venda concessionária;3=Venda da concessionária 
				CD9->CD9_CHASSI := VV1->VV1_CHASSI //Chassi
				CD9->CD9_CORDE  := AllTrim( GetAdvFVal("VVC","VVC_GRUCOR",xFilial( "VVC" ) + VV1->VV1_CODMAR + VV1->VV1_CORVEI,1,"") ) //Código da Cor segundo as regras de pré-cadastro do DENATRAN.
				CD9->CD9_CODCOR := ALLTRIM(VV2->VV2_COREXT) + SUBSTR(VV2->VV2_CORINT,1,1) //AllTrim( GetAdvFVal("VVC","VVC_GRUCOR",xFilial( "VVC" ) + VV1->VV1_CODMAR + VV1->VV1_CORVEI,1,"") ) //Codigo da cor definido pela montadora
				CD9->CD9_DSCCOR := AllTrim( GetAdvFVal("VVC","VVC_DESCRI",xFilial( "VVC" ) + VV1->VV1_CODMAR + VV1->VV1_CORVEI,1,"") ) //Descrição da Cor
				CD9->CD9_POTENC := cValToChar( VV2->VV2_POTMOT ) //Potência máxima do motor do veículo em cavalo vapor (CV - potência veículo).
				CD9->CD9_CM3POT := VV2->VV2_CM3 //Capacidade voluntária do motor expressa em centímetros cúbicos (CC - cilindradas).
				CD9->CD9_PESOLI := SF2->F2_PLIQUI //Peso Liquido
				CD9->CD9_PESOBR := SF2->F2_PBRUTO //Peso Bruto
				CD9->CD9_SERIAL := VV1->VV1_SERMOT //Serial (série)
				CD9->CD9_TPCOMB := DeParaComb( VV1->VV1_COMVEI ) //Tipo Combustível
				CD9->CD9_NMOTOR := VV1->VV1_NUMMOT //Numero do Motor
				CD9->CD9_CMKG   := cValToChar( VV2->VV2_CAPTRA ) //CMT - Capacidade máxima de tração - em toneladas.
				CD9->CD9_DISTEI := cValToChar( VV2->VV2_DISEIX ) //Distancia entre eixos
				CD9->CD9_RENAVA := Val( VV1->VV1_RENAVA ) //Renavam
				CD9->CD9_ANOMOD := Val( AllTrim( SubStr( VV1->VV1_FABMOD, 5, 4 ) ) ) //Ano Modelo
				CD9->CD9_ANOFAB := Val( AllTrim( SubStr( VV1->VV1_FABMOD, 1, 4 ) ) ) //Ano Frabricação
				CD9->CD9_TPPINT := AllTrim( POSICIONE( "VVC", 1, xFilial( "VVC" ) + VV1->VV1_CODMAR + VV1->VV1_CORVEI, "VVC_TIPCOR" ) ) //Tipo de Pintura 1 = Solida; 2 = Metalica
				CD9->CD9_TPVEIC := VV2->VV2_TIPVEI //Tipo de Veículo 06 = Automovel; 14 = Caminhao; 07 = Microonibus; 08 = Onibus; 10 = Reboque; 17 = C Trator
				CD9->CD9_ESPVEI := AllTrim( POSICIONE( "VVE", 1, xFilial( "VVE" ) + VV2->VV2_ESPVEI, "VVE_ESPREN") ) //Espécie de Veículo 02 = Carga; 04 = Corrida; 06 = Especial; 03 = Misto; 01 = Passageiro; 05 = Tracao
				CD9->CD9_CONVIN := IIF( VV1->VV1_PROVEI $ "01", "N", "R" ) //Informe se o veículo tem VIN (chassi) remarcado. 1 = Importado; 2 = Nacional
				CD9->CD9_CONVEI := "1" //Condição do Veículo 1 = Acabado; 2 = Inacabado; 3 = Semi-acabado
				CD9->CD9_CODMOD := VV2->VV2_MODFAB
				CD9->CD9_CILIND := cValToChar( VV2->VV2_CILMOT ) //Cilindradas
				CD9->CD9_TRACAO := cValToChar( VV2->VV2_CAPTRA ) //Máxima Tração
				CD9->CD9_LOTAC  := VV2->VV2_QTDPAS //Quantidade máxima permitida de passageiros sentados, inclusive motorista.
				CD9->CD9_RESTR  := "0" //Restrição
				CD9->( MsUnLock() )

			//EndIf
		EndIf

	Endif

	aEval(aArea,{|x| RestArea(x)})
 
return()

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
