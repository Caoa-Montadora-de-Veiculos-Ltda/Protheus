#include "totvs.ch"
#include "protheus.ch"

User function MT103FIM()

   Local aArea	  := GetArea()

   If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
      zMontadora()
   Else
      zCaoaSp() //Executa o p.e. CaoaSp
   EndIf

   RestArea(aArea)

Return()

/*
==============================================================================================
Programa.:              zMontadora
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada Montadora
===============================================================================================
*/
Static Function zMontadora()

	Local nOpcao		:= ParamIxb[1]
	Local nConfirma		:= ParamIxb[2]
	Local aArea			:= GetArea()
	Local ctpImp        := ""

	ConOut("MT103FIM - INICIO")

	If FindFunction("U_CMVCOMVE") .And. nOpcao == 4 .And. nConfirma == 1 .And. MV_PAR17 == 2

		ctpImp := Posicione("SW6", 1, SF1->F1_FILIAL + SF1->F1_HAWB, "W6_XTIPIMP")		

		If Posicione("ZZ8", 1, FwxFilial("ZZ8") + ctpImp, "ZZ8_TIPO") = "000005"

			Processa({||U_CMVCOMVE(SF1->F1_FILIAL,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)},'Integrações','Concluindo Integrações - CAOA')
		EndIf
	EndIf
	
	// tratamento para exclusao para o SAP
	If findfunction("U_CMVSAP14")
		If PARAMIXB[1] == 5 .and. PARAMIXB[2] == 1 // exclusao e usuario confirmou a operacao
			U_CMVSAP14("1")
		Endif	
	endif

	If findfunction("U_CMVCOM01")
		If (PARAMIXB[1] == 3 .or. PARAMIXB[1] == 4) .and. PARAMIXB[2] == 1 // (inclusao ou classificacao da nota) e usuario confirmou a operacao
			U_CMVCOM01()
		Endif
	Endif	

	// tratamento para gravacao das entidades contabeis
	If findfunction("U_CMVSAP23")
		If (PARAMIXB[1] == 3 .or. PARAMIXB[1] == 4) .and. PARAMIXB[2] == 1 // (inclusao ou classificacao da nota) e usuario confirmou a operacao
			U_CMVSAP23()
		Endif
	Endif	
	
	// Insere dados adicionais da nota de entrada quando for nota de importacao cbu
	// EIC 108
	If findfunction("U_ZEICF009") .and. nConfirma = 1 .And. nOpcao <> 5
		Processa({|| U_ZEICF009() }, 'EIC', 'Dados adicionais Doc Entrada (CD9)')		
	Endif


	// Insere dados adicionais da nota de entrada quando for nota DE CONTAINER "filha"
	// EIC 108
	If Vazio(SF1->F1_XMSGADI) = .F. .AND. nConfirma = 1
		If Findfunction("U_ZEICF017") 
			Processa({|| U_ZEICF017() }, 'EIC', 'Dados adicionais Doc Entrada (CD5)')		
		Endif
	Endif

	If findfunction("U_ZEICF033") .and. nConfirma = 1 .And. nOpcao <> 5 
        Processa({|| U_ZEICF033() }, 'EIC', 'Dados adicionais Doc Entrada (ICMS)')
    ENDIF

	ConOut("MT103FIM - FIM")
	RestArea(aArea)
Return

/*
==============================================================================================
Programa.:              zCaoaSp
Autor....:              Evandro Mariano
Data.....:              08/11/2022
Descricao / Objetivo:   Executa chamada CaoaSp
===============================================================================================
*/
Static Function zCaoaSp()

	Local nOpcao		:= ParamIxb[1]
	Local nConfirma		:= ParamIxb[2]
	Local aArea			:= GetArea()
	Local ctpImp        := ""
	Local _cEnvRgLog    := Alltrim(Getmv("CMV_WSR034")) // Envia para RgLog - S/N (SIM/NAO)

	ConOut("MT103FIM - INICIO")

	If FindFunction("U_CMVCOMVE") .And. nOpcao == 4 .And. nConfirma == 1 .And. MV_PAR17 == 2

		ctpImp := Posicione("SW6", 1, SF1->F1_FILIAL + SF1->F1_HAWB, "W6_XTIPIMP")		

		If Posicione("ZZ8", 1, FwxFilial("ZZ8") + ctpImp, "ZZ8_TIPO") = "000005"

			Processa({||U_CMVCOMVE(SF1->F1_FILIAL,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)},'Integrações','Concluindo Integrações - CAOA')
		EndIf
	EndIf
	
	// tratamento para exclusao para o SAP
	If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
		If findfunction("U_ZSAPF014")
			If PARAMIXB[1] == 5 .and. PARAMIXB[2] == 1 // exclusao e usuario confirmou a operacao
				U_ZSAPF014("1")
			Endif	
		Endif
	EndIf

	If findfunction("U_CMVCOM01")
		If (PARAMIXB[1] == 3 .or. PARAMIXB[1] == 4) .and. PARAMIXB[2] == 1 // (inclusao ou classificacao da nota) e usuario confirmou a operacao
			U_CMVCOM01()
		Endif
	Endif	

	// tratamento para gravacao das entidades contabeis
	If ( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
		If findfunction("U_ZSAPF023")
			If (PARAMIXB[1] == 3 .or. PARAMIXB[1] == 4) .and. PARAMIXB[2] == 1 // (inclusao ou classificacao da nota) e usuario confirmou a operacao
				U_ZSAPF023()
			Endif
		Endif	
	EndIf
	
	// Insere dados adicionais da nota de entrada quando for nota de importacao cbu
	// EIC 108
	If findfunction("U_ZEICF009") .and. nConfirma = 1 .And. nOpcao <> 5
		Processa({|| U_ZEICF009() }, 'EIC', 'Dados adicionais Doc Entrada (CD9)')		
	Endif


	// Insere dados adicionais da nota de entrada quando for nota DE CONTAINER "filha"
	// EIC 108
	If Vazio(SF1->F1_XMSGADI) = .F. .AND. nConfirma = 1
		If Findfunction("U_ZEICF017") 
			Processa({|| U_ZEICF017() }, 'EIC', 'Dados adicionais Doc Entrada (CD5)')		
		Endif
	Endif

	If ( ( FwCodEmp() == "2020" .And. FwFilial() == "2001" ) .Or. ( FwCodEmp() == "9010" .And. FwFilial() == "HAD1" ) ) .And. nConfirma == 1 .And. _cEnvRgLog == "S" //Executa o p.e. somente para Barueri.
    	If findfunction("U_ZWSR010")
			Processa({|| U_ZWSR010(SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, .F., SF1->F1_TIPO) }, 'Doc Entrada', 'Envia Integração RgLog')		
		Endif
	EndIf

	ConOut("MT103FIM - FIM")
	RestArea(aArea)
Return
