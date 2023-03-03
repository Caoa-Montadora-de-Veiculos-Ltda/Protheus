#INCLUDE "TOTVS.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"

#define lDebug .f.

User Function PROPOSTA(cChamada, cFilAte, cNumAte, oModelImp)

	Local cRelName   := "PROPOSTA"
	Local cSession
	Local lAdjust    := .F.
	Local nFlags     := PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE
	Local nLocal     := 1
	Local nOrient    := 1
	Local nPrintType := 6

	Private oPrintAtend    := Nil
	Private oSetupImpr     := Nil

	Private cStartPath
	Private nLin            := 0

	Private nMargemL        := 30
	Private nMargemR        := 30
	Private nMargemT        := 30
	Private nMargemB        := 30

	Private nCenterPg       := 1200
	Private nPag            := 0
	Private nLinRodPe   	:= 3400

	Private nHorzSize,nVertSize
	
	Private nColIni, nColFim
	
	Private nDiv_2_C_1, nDiv_2_C_2
	Private nDiv_3_C_1, nDiv_3_C_2, nDiv_3_C_3
	Private nDiv_4_C_1, nDiv_4_C_2, nDiv_4_C_3, nDiv_4_C_4
	Private nDiv_5_C_1, nDiv_5_C_2, nDiv_5_C_3, nDiv_5_C_4, nDiv_5_C_5
	Private nDiv_6_C_1, nDiv_6_C_2, nDiv_6_C_3, nDiv_6_C_4, nDiv_6_C_5, nDiv_6_C_6
	Private nDiv_7_C_1, nDiv_7_C_2, nDiv_7_C_3, nDiv_7_C_4, nDiv_7_C_5, nDiv_7_C_6, nDiv_7_C_7
	
	Private nLargPadrao
	Private nPropPixel
	Private nMaisAltura
	Private nAltPadrao

	//Variaveis de Tipos de fontes que podem ser utilizadas no relatório
	Private oFont6      := TFONT():New("ARIAL",6 ,6 ,,.F.,,,,,.F.,.F.) ///Fonte 6 Normal
	Private oFont6N     := TFONT():New("ARIAL",6 ,6 ,,.T.,,,,,.T.,.F.) ///Fonte 6 Negrito
	Private oFont8      := TFONT():New("ARIAL",8 ,8 ,,.F.,,,,,.F.,.F.) ///Fonte 8 Normal
	Private oFont8N     := TFONT():New("ARIAL",8 ,8 ,,.T.,,,,,.F.,.F.) ///Fonte 8 Negrito
	Private oFont9      := TFONT():New("ARIAL",9 ,9 ,,.F.,,,,,.F.,.F.) ///Fonte 9 Normal
	Private oFont9N     := TFONT():New("ARIAL",9 ,9 ,,.T.,,,,,.F.,.F.) ///Fonte 9 Negrito
	Private oFont10     := TFONT():New("ARIAL",10,10,,.F.,,,,,.F.,.F.) ///Fonte 10 Normal
	Private oFont10S    := TFONT():New("ARIAL",10,10,,.F.,,,,,.T.,.F.) ///Fonte 10 Sublinhando
	Private oFont10N    := TFONT():New("ARIAL",10,10,,.T.,,,,,.F.,.F.) ///Fonte 10 Negrito
	Private oFont12     := TFONT():New("ARIAL",12,12,,.F.,,,,,.F.,.F.) ///Fonte 12 Normal
	Private oFont12NS   := TFONT():New("ARIAL",12,12,,.T.,,,,,.T.,.F.) ///Fonte 12 Negrito e Sublinhado
	Private oFont12N    := TFONT():New("ARIAL",12,12,,.T.,,,,,.F.,.F.) ///Fonte 12 Negrito
	Private oFont14     := TFONT():New("ARIAL",14,14,,.F.,,,,,.F.,.F.) ///Fonte 14 Normal
	Private oFont14NS   := TFONT():New("ARIAL",14,14,,.T.,,,,,.T.,.F.) ///Fonte 14 Negrito e Sublinhado
	Private oFont14N    := TFONT():New("ARIAL",14,14,,.T.,,,,,.F.,.F.) ///Fonte 14 Negrito
	Private oFont16     := TFONT():New("ARIAL",16,16,,.F.,,,,,.F.,.F.) ///Fonte 16 Normal
	Private oFont16N    := TFONT():New("ARIAL",16,16,,.T.,,,,,.F.,.F.) ///Fonte 16 Negrito
	Private oFont16NS   := TFONT():New("ARIAL",16,16,,.T.,,,,,.T.,.F.) ///Fonte 16 Negrito e Sublinhado
	Private oFont16I    := TFONT():New("ARIAL",16,16,,.F.,,,,,.F.,.T.) ///Fonte 16 Itálico
	Private oFont20N    := TFONT():New("ARIAL",20,20,,.T.,,,,,.F.,.F.) ///Fonte 20 Negrito
	Private oFont22N    := TFONT():New("ARIAL",22,22,,.T.,,,,,.F.,.F.) ///Fonte 22 Negrito

	nOpc := 2
	VISUALIZA := ( nOpc == 2 )
	INCLUI 	 := ( nOpc == 3 )
	ALTERA 	 := ( nOpc == 4 )
	EXCLUI 	 := ( nOpc == 5 )

	// Informações da Filial Corrente
	aInfFilial := FWSM0Util():GetSM0Data()
	oInfFilial := DMS_DataContainer():New( aClone(aInfFilial) )
	//

	If cChamada == "ATENDVEI"
		cRelName := "ATENDVEI_" + cFilAte + "_" + cNumAte + "_" + StrTran(Time(),":","")
	Else
		cRelName := "PROPOSTA_" + oModelImp:GetValue("MODEL_VRJ","VRJ_FILIAL") + "_" + oModelImp:GetValue("MODEL_VRJ","VRJ_PEDIDO")
	EndIf

	cSession   := GetPrinterSession()
	//cDevice    := If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
	nOrient    := 1 // If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
	//nLocal     := If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
	nLocal     := 2
	//nPrintType := aScan(aDevice,{|x| x == cDevice })
	nPrintType := IMP_PDF

	oSetupImpr := FWPrintSetup():New(nFlags,cRelName)

	oSetupImpr:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetupImpr:SetPropert(PD_ORIENTATION , nOrient)
	oSetupImpr:SetPropert(PD_PAPERSIZE , DMPAPER_A4)
	oSetupImpr:SetPropert(PD_DESTINATION , nLocal)
	oSetupImpr:SetPropert(PD_MARGIN , {nMargemL,nMargemT,nMargemR,nMargemB})

	oSetupImpr:aOptions[PD_VALUETYPE] := fwGetProfString(cSession,"PATHPDF","C:\",.T.)

	If oSetupImpr:Activate() == PD_OK 

		fwWriteProfString(cSession, "LOCAL"      , If(oSetupImpr:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )	
		fwWriteProfString(cSession, "PRINTTYPE"  , If(oSetupImpr:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )	

		oPrintAtend := FWMSPrinter():New(cRelName, nPrintType, lAdjust, /*cPathDest*/, .T., /*lTReport*/ ,/* oPrintSetup */,/*cPrinter*/, (oSetupImpr:GetProperty(PD_DESTINATION) == AMB_SERVER ) )
		oPrintAtend:SetPortrait()
		oPrintAtend:SetPaperSize(oSetupImpr:GetProperty(PD_PAPERSIZE))
		oPrintAtend:setCopies(Val(oSetupImpr:cQtdCopia))

		FS_SetVar()

		If oSetupImpr:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
			fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetupImpr:aOptions[PD_VALUETYPE], .T.)
			oPrintAtend:cPrinter		:= oSetupImpr:aOptions[PD_VALUETYPE]
		Else 
			oPrintAtend:cPathPDF		:= oSetupImpr:aOptions[PD_VALUETYPE]
			fwWriteProfString(GetPrinterSession(),"PATHPDF", oSetupImpr:aOptions[PD_VALUETYPE], .T.)
		Endif

		If cChamada == "ATENDVEI"
			ImpAtend(cFilAte, cNumAte)
		Else
			ImpProp(oModelImp)
		EndIf

	EndIf

Return

Static Function ImpAtend(cFilAte, cNumAte)

	// Posicionamento nas tabelas envolvidas na impressao 
	FS_POSTABELAS("ATENDVEI", cFilAte, cNumAte)
	
	If lDebug
		FS_ImpDebug()
	Else
		FS_ImpProp()
	EndIf

	oPrintAtend:EndPage()
	oPrintAtend:Preview()

Return


Static Function ImpProp(oModelImp)

	Local nLinVRK
	Local oModelVRK := oModelImp:GetModel("MODEL_VRK")

	For nLinVRK := 1 to oModelVRK:Length()

		If oModelVRK:GetValue("SEL_PROPOSTA", nLinVRK)
		
			oModelVRK:GoLine(nLinVRK)
			// Posicionamento nas tabelas envolvidas na impressao 
			FS_POSTABELAS("PROPPED", , , oModelImp)
			
			If lDebug
				FS_ImpDebug()
			Else
				FS_ImpProp()
			EndIf

			oPrintAtend:EndPage()
		EndIf
	Next nLinVRK

	oPrintAtend:Preview()

Return

Static Function FS_ImpProp()

	FS_Cabecalho()
	
	FS_Proposta_Quadro()
	FS_PULALINHA(.5)
	
	FS_Cliente_Quadro()
	FS_PULALINHA(.5)
	
	FS_Observacao_Quadro()
	FS_PULALINHA(.5)
	
	FS_Irregularidade_Quadro()
	FS_PULALINHA(.5)
	
	FS_Total_Quadro()
	FS_CortAcess_Quadro()
	FS_PULALINHA(2)
	FS_PULALINHA(.5)

	FS_FormaPgto_Quadro()
	FS_PULALINHA(.5)

	FS_Autorizacao_Quadro()

Return

/*/{Protheus.doc} FS_Autorizacao_Quadro
	(long_description)
	@type  Static Function
	@author MIL
	@since 18/11/2019
	@version 1.0
	/*/
Static Function FS_Autorizacao_Quadro()

	oPrintAtend:Box(nLin - 10 , nColIni, nLin + (FS_AltLinha() * 10) - 8 , nColFim )
	oPrintAtend:Say(nLin, nColIni + 5, "AUTORIZAÇÃO DE FATURAMENTO", oFont10N )
	oPrintAtend:Line(nLin + 4, nColIni , nLin + 4 , nColFim )
	FS_PULALINHA()
	oPrintAtend:Say(nLin, nColIni + 5, "Autorizo o faturamento do veiculo em referencia, pelos valores contantes na presente proposta de venda.", oFont10 )
	FS_PULALINHA(2)

	oPrintAtend:Line( nLin , nDiv_3_C_1 + 30 , nLin , nDiv_3_C_2 - 30 )
	oPrintAtend:Line( nLin , nDiv_3_C_2 + 30 , nLin , nDiv_3_C_3 - 30 )
	oPrintAtend:Line( nLin , nDiv_3_C_3 + 30 , nLin , nColFim    - 30 )
	FS_PULALINHA()
	FS_PrintAlign("Cliente", , nDiv_3_C_1, oFont10,2,0,nDiv_3_C_2 - nDiv_3_C_1)
	FS_PrintAlign("Vendedor", , nDiv_3_C_2, oFont10,2,0,nDiv_3_C_3 - nDiv_3_C_2)
	FS_PrintAlign("Autorizante", , nDiv_3_C_3, oFont10,2,0,nColFim - nDiv_3_C_3)
	FS_PULALINHA(3)

	oPrintAtend:Line( nLin , nDiv_3_C_1 + 30 , nLin , nDiv_3_C_2 - 30 )
	oPrintAtend:Line( nLin , nDiv_3_C_2 + 30 , nLin , nDiv_3_C_3 - 30 )
	oPrintAtend:Line( nLin , nDiv_3_C_3 + 30 , nLin , nColFim    - 30 )
	FS_PULALINHA()
	FS_PrintAlign("Despachante", , nDiv_3_C_1, oFont10,2,0,nDiv_3_C_2 - nDiv_3_C_1)
	FS_PrintAlign("Seguros", , nDiv_3_C_2, oFont10,2,0,nDiv_3_C_3 - nDiv_3_C_2)
	FS_PrintAlign("Acessórios", , nDiv_3_C_3, oFont10,2,0,nColFim - nDiv_3_C_3)
	FS_PULALINHA()
	FS_PrintAlign("Proposta sujeita à aprovação", , nColIni, oFont10N , 2 , 0 , nColFim)

Return

/*/{Protheus.doc} FS_FormaPgto_Quadro
	(long_description)
	@type  Static Function
	@author MIL
	@since 18/11/2019
	@version 1.0
	/*/
Static Function FS_FormaPgto_Quadro()

	Local nCntParc := 0
	Local cSQL
	Local cVRLAlias := "TAUXVRL"

	nFPagFimColTab := 415
	nFPagCol1 := nColIni
	nFPagAlt1 := (FS_AltLinha() * 10)
	nFPagAlt2 := (FS_AltLinha() * 07)
	nTFPCol_1_Data      := nColIni + 005
	nTFPCol_2_FormaPag  := nColIni + 050
	nTFPCol_3_Documento := nColIni + 140
	nTFPCol_4_Banco     := nColIni + 220
	nTFPCol_5_Valor     := nColIni + 335

	oPrintAtend:Line(nLin - 10 , nColIni, nLin - 10 , nFPagFimColTab )
	oPrintAtend:Line(nLin - 10 , nColIni, nLin + nFPagAlt1 - 8 , nColIni )
	oPrintAtend:Line(nLin - 10 , nFPagFimColTab, nLin + nFPagAlt2 - 8 , nFPagFimColTab )
	oPrintAtend:Line(nLin + nFPagAlt2 - 8 , nFPagFimColTab, nLin + nFPagAlt2 - 8 , nColFim )
	oPrintAtend:Line(nLin + nFPagAlt2 - 8 , nColFim, nLin + nFPagAlt1 - 8 , nColFim )
	oPrintAtend:Line(nLin + 4, nColIni , nLin + 4 , nFPagFimColTab )
	oPrintAtend:Line(nLin + nFPagAlt1 - 8, nColIni , nLin + nFPagAlt1 - 8 , nColFim )
	oPrintAtend:Say(nLin, nColIni + 005, "FORMA DE PAGAMENTO", oFont10N )

	FS_PULALINHA()
	oPrintAtend:Say(nLin, nTFPCol_1_Data      , "Data", oFont10N )
	oPrintAtend:Say(nLin, nTFPCol_2_FormaPag  , "Forma de Pagamento", oFont10N )
	oPrintAtend:Say(nLin, nTFPCol_3_Documento , "Documento", oFont10N )
	oPrintAtend:Say(nLin, nTFPCol_4_Banco     , "Banco / Descrição", oFont10N )
	oPrintAtend:Say(nLin, nTFPCol_5_Valor     , "Valor da Parcela", oFont10N )

	FS_PULALINHA()
	cSQL := ;
		"SELECT * " +;
		 " FROM " + RetSQLName("VRL") + " VRL " +;
		" WHERE VRL.VRL_FILIAL = '" + xFilial("VRL") + "' " +;
		  " AND VRL.VRL_PEDIDO = '" + VRJ->VRJ_PEDIDO + "' " +;
		  " AND VRL.VRL_ITEPED = '" + VRK->VRK_ITEPED + "' " +;
		  " AND VRL.VRL_CANCEL = '0' " +;
		  " AND VRL.D_E_L_E_T_ = ' ' " +;
		" ORDER BY VRL.VRL_E1DTVR, VRL.VRL_E1PARC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cVRLAlias , .F., .T. )
	(cVRLAlias)->(DbgoTop())
	Do while !(cVRLAlias)->(Eof())
		
		nCntParc++

		cNumTit := (cVRLAlias)->VRL_E1PREF + "-" +(cVRLAlias)->VRL_E1NUM  + "-" +(cVRLAlias)->VRL_E1PARC

		oPrintAtend:Say(nLin, nTFPCol_1_Data      , DtoC(Stod( (cVRLAlias)->VRL_E1DTVR )), oFont10 )
		oPrintAtend:Say(nLin, nTFPCol_2_FormaPag  , (cVRLAlias)->VRL_E1TIPO              , oFont10 )
		oPrintAtend:Say(nLin, nTFPCol_3_Documento , cNumTit , oFont10 )
		oPrintAtend:Say(nLin, nTFPCol_4_Banco     , " ", oFont10 )
		FS_PrintAlign("R$ " + Transform((cVRLAlias)->VRL_E1VALO, X3Picture("VRL_E1VALO")), , nTFPCol_5_Valor, oFont10,1,0,nFPagFimColTab - nTFPCol_5_Valor - 5, nAltPadrao)
		FS_PULALINHA()

		(cVRLAlias)->(DbSkip())
	End
	(cVRLAlias)->(DbCloseArea())
	dbSelectArea("VST")

	If nCntParc < 5
		FS_PULALINHA(5 - nCntParc)
	EndIf

	FS_PRINT("Desc. Fin.:"," ",,nDiv_5_C_1)
	FS_PRINT("Troco:"," ",,nDiv_5_C_2)
	FS_PRINT("Desc. (%):"," ",,nDiv_5_C_3)
	FS_PRINT("Repasse:"," ",,nDiv_5_C_4)
	FS_PRINT("Com. (%):"," ",,nDiv_5_C_5)
	FS_PULALINHA()
	FS_PRINT("Financiamento (Meses):"," ",,nDiv_5_C_1,90)
	FS_PRINT("Parcela:"," ",,nDiv_5_C_2)
	FS_PRINT("Banco:"," ",,nDiv_5_C_3)
	FS_PRINT("Fator:"," ",,nDiv_5_C_4)
	FS_PRINT("Liq.:"," ",,nDiv_5_C_5)
	FS_PULALINHA()
	FS_PRINT("Valor:" ,"",,nDiv_5_C_1)
	FS_PRINT("Tarifa:","",,nDiv_5_C_2)
	FS_PRINT("Carne:" ,"",,nDiv_5_C_3)
	FS_PRINT("Total Financ.:","",,nDiv_5_C_4)
	FS_PRINT("Ped.:" ,"",,nDiv_5_C_5)
	FS_PULALINHA()
Return

/*/{Protheus.doc} FS_CortAcess_Quadro
	(long_description)
	@type  Static Function
	@author MIL
	@since 18/11/2019
	@version 1.0
	/*/
Static Function FS_CortAcess_Quadro()
	nColTabCorAces := 420
	nTabCorAces := nColFim - nColTabCorAces
	nColTCortesia := nColTabCorAces + 5
	nColTAcessorios := nColTabCorAces + Round(nTabCorAces / 2, 0 ) + 5
	oPrintAtend:Box(nLin - 10 , nColTabCorAces, nLin + (FS_AltLinha() * 09) - 8 , nColFim )
	oPrintAtend:Say(nLin, nColTCortesia  , "CORTESIAS" , oFont10N )
	oPrintAtend:Say(nLin, nColTAcessorios , "ACESSÓRIOS", oFont10N )
	oPrintAtend:Line(nLin + 4, nColTabCorAces , nLin + 4 , nColFim )
	oPrintAtend:Line(nLin - 10 , nColTAcessorios - 5 , nLin + (FS_AltLinha() * 09) - 8 , nColTAcessorios - 5 )

Return

/*/{Protheus.doc} FS_Total_Quadro
	(long_description)
	@type  Static Function
	@author MIL
	@since 18/11/2019
	@version 1.0
	/*/
Static Function FS_Total_Quadro()
	nTotalFimColTab := 415
	oPrintAtend:Box(nLin - 10 , nColIni, nLin + (FS_AltLinha() * 2) - 8 , nTotalFimColTab )
	oPrintAtend:Say(nLin, nColIni + 5, "TOTAL", oFont10N )
	oPrintAtend:Line(nLin + 4, nColIni , nLin + 4 , nTotalFimColTab )

	FS_PRINT("Data da Negociação: ",, nLin + FS_AltLinha() , nColIni + 5 )
	FS_PRINT("Valor da nota: "     ,"R$ " + Transform(VRK->VRK_VALVDA, X3Picture("VRK_VALVDA")), nLin + FS_AltLinha() , nColIni + 5 + (nTotalFimColTab / 2) )

Return

/*/{Protheus.doc} FS_Cabecalho
	(long_description)
	@type  Static Function
	@author Rubens Takahashi
	@since 09/09/2010
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function FS_Cabecalho()

	oPrintAtend:StartPage() // Inicia uma nova pagina

	cStartPath := GetSrvProfString("Startpath","")

	cLogo := cStartPath + "LGRL" + FWCodEmp() + FWCodFil() + ".BMP" 	// Empresa+Filial
	If ! File( cLogo )
		cLogo := cStartPath + "LGRL" + FWCodEmp() + ".BMP" // Empresa
	EndIf

	FS_PULALINHA()
	//oPrintAtend:SayBitmap(nLin, nMargemL, cStartPath + "lgmid.png", 50, 94)
	oPrintAtend:SayBitmap(nLin, nMargemL, cLogo, 50, 94)
	FS_PrintAlign("PEDIDO DE VENDA " + CHR(13) + CHR(10) + "DE VEÍCULO", , nDiv_5_C_2, oFont20N,0,0,nDiv_5_C_4 - nDiv_5_C_2,FS_AltLinha() * 5)
	oPrintAtend:Line(nLin - 10 , nDiv_5_C_5 + 10 , FS_AltLinha() * 5, nDiv_5_C_5 + 10 )
	// 

	FS_PrintAlign(Alltrim(oInfFilial:GetValue("M0_NOMECOM")), , nDiv_5_C_4, oFont9,,,nDiv_5_C_5 - nDiv_5_C_4)
	FS_PrintAlign("Data: " + Alltrim(DTOC(dDatabase)), , nDiv_5_C_5, oFont9,,, nColFim - nDiv_5_C_5 )
	FS_PULALINHA(.8)
	FS_PrintAlign(Alltrim(oInfFilial:GetValue("M0_ENDCOB")) + IIf( ! Empty(Alltrim(oInfFilial:GetValue("M0_COMPCOB"))), "," + Alltrim(oInfFilial:GetValue("M0_COMPCOB")), "") , , nDiv_5_C_4, oFont9,,,nDiv_5_C_5 - nDiv_5_C_4)
	FS_PrintAlign("Emissão: " + Left(Time(),5), , nDiv_5_C_5, oFont9,,, nColFim - nDiv_5_C_5 )
	FS_PULALINHA(.8)
	FS_PrintAlign(Alltrim(oInfFilial:GetValue("M0_BAIRCOB")), , nDiv_5_C_4, oFont9,,,nDiv_5_C_5 - nDiv_5_C_4)
	FS_PULALINHA(.8)
	FS_PrintAlign(Alltrim(oInfFilial:GetValue("M0_CIDCOB")) + " / " + Alltrim(oInfFilial:GetValue("M0_ESTCOB")) , , nDiv_5_C_4, oFont9,,,nDiv_5_C_5 - nDiv_5_C_4)
	FS_PULALINHA(.8)
	FS_PrintAlign("CNPJ: " + Transform(oInfFilial:GetValue("M0_CGC"),"@R 99.999.999/9999-99"), , nDiv_5_C_4, oFont9,,,nDiv_5_C_5 - nDiv_5_C_4)
	FS_PULALINHA(.8)
	FS_PrintAlign("+55" + AllTrim(oInfFilial:GetValue("M0_TEL")), , nDiv_5_C_4, oFont9,,,nDiv_5_C_5 - nDiv_5_C_4)
	FS_PULALINHA(.8)
	FS_PrintAlign("www.caoa.com.br", , nDiv_5_C_4, oFont9,,,nDiv_5_C_5 - nDiv_5_C_4)
	FS_PULALINHA()
	FS_PULALINHA()
Return

/*/{Protheus.doc} FS_Proposta_Quadro
	(long_description)
	@type  Static Function
	@author MIL
	@since 18/11/2019
	@version 1.0
	/*/
Static Function FS_Proposta_Quadro()
	oPrintAtend:Box(nLin - 10 , nColIni, nLin + ((nAltPadrao + nMaisAltura) * 7) - 8 , nColFim )
	oPrintAtend:Say(nLin, nColIni + 5, "PROPOSTA / VEICULO", oFont10N )
	oPrintAtend:Line(nLin + 4, nColIni , nLin + 4 , nColFim )
	FS_PULALINHA()
	FS_PRINT("Atendimento:",VV9->VV9_NUMATE,,nDiv_2_C_1)
	FS_PRINT("Pedido:",VRJ->VRJ_PEDIDO,,nDiv_4_C_2)
	FS_PRINT("Chassi:",VVA->VVA_CHASSI,,nDiv_2_C_2)
	FS_PULALINHA()
	FS_PRINT("Modelo:",AllTrim(VV2->VV2_DESMOD),,nDiv_2_C_1)
	FS_PRINT("Código:",VV2->VV2_MODVEI,,nDiv_4_C_2)
	FS_PRINT("Opcionais:","",,nDiv_2_C_2)
	FS_PULALINHA()
	FS_PRINT("Ano:",VV1->VV1_FABMOD,,nDiv_2_C_1)
	FS_PRINT("Combustivel:",X3CBOXDESC("VV1_COMVEI", VV1->VV1_COMVEI),,nDiv_2_C_2)
	FS_PULALINHA()
	FS_PRINT("Cor:",OFIOA560DS("067", VV2->VV2_COREXT),,nDiv_2_C_1)
	FS_PRINT("Acabamento:","",,nDiv_2_C_2)
	FS_PULALINHA()
	FS_PRINT("Motor:",VV1->VV1_NUMMOT,,nDiv_2_C_1)
	FS_PRINT("Renavam:",VV1->VV1_RENAVA,,nDiv_2_C_2)
	FS_PULALINHA()
	FS_PRINT("Complemento:","",,nDiv_2_C_1)
	FS_PRINT("Local:","",,nDiv_2_C_2)
	FS_PULALINHA()
Return

/*/{Protheus.doc} FS_Cliente_Quadro
	(long_description)
	@type  Static Function
	@author MIL
	@since 18/11/2019
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function FS_Cliente_Quadro()

	RegToMemory("SA1")
	oPrintAtend:Box(nLin - 10 , nColIni, nLin + ((nAltPadrao + nMaisAltura) * 9) - 8 , nColFim )
	oPrintAtend:Say(nLin, nColIni + 5, "CLIENTE", oFont10N )
	oPrintAtend:Line(nLin + 4, nColIni , nLin + 4 , nColFim )
	FS_PULALINHA()
	FS_PRINT("Vendedor:",SA3->A3_NOME,,nDiv_2_C_1)
	//FS_PRINT("CPF/CNPJ:","<CPF/CNPJ>",,nDiv_2_C_2)
	FS_PULALINHA()
	FS_PRINT("Cliente:",SA1->A1_NOME,,nDiv_2_C_1)
	FS_PRINT("CPF/CNPJ:",Transform(AllTrim(SA1->A1_CGC),IIf(Len(AllTrim(M->A1_CGC)) == 14, "@R 99.999.999/9999-99", "@R 999.999.999-99")),,nDiv_2_C_2)
	FS_PULALINHA()
	FS_PRINT("Endereço:",AllTrim(SA1->A1_END),,nDiv_2_C_1)
	FS_PRINT("R.G. / I.E.:",IIf( ! Empty(SA1->A1_RG), SA1->A1_RG, SA1->A1_INSCR ),,nDiv_2_C_2)
	FS_PULALINHA()
	FS_PRINT("Bairro:",AllTrim(SA1->A1_BAIRRO),,nDiv_2_C_1)
	FS_PRINT("CEP:",Transform(SA1->A1_CEP, X3Picture("A1_CEP")),,nDiv_2_C_2)
	FS_PULALINHA()
	FS_PRINT("Municipio:",SA1->A1_MUN,,nDiv_2_C_1)
	//FS_PRINT("say:","<say>",,nDiv_2_C_2)
	FS_PULALINHA()
	FS_PRINT("Telefone:",SA1->A1_TEL,,nDiv_2_C_1)
	//FS_PRINT("Celular:","<CELULAR>",,nDiv_2_C_2)
	FS_PULALINHA()
	FS_PRINT("Email:",SA1->A1_EMAIL,,nDiv_2_C_1)
	//FS_PRINT("say:","<say>",,nDiv_2_C_2)
	FS_PULALINHA()
	FS_PRINT("Arrendatário:","",,nDiv_2_C_1)
	FS_PRINT("CPF/CNPJ:","",,nDiv_2_C_2)
	FS_PULALINHA()

Return

/*/{Protheus.doc} FS_Observacao_Quadro
	(long_description)
	@type  Static Function
	@author MIL
	@since 18/11/2019
	@version 1.0
	/*/
Static Function FS_Observacao_Quadro()
	oPrintAtend:Box(nLin - 10 , nColIni, nLin + ((nAltPadrao + nMaisAltura) * 5) - 8 , nColFim )
	oPrintAtend:Say(nLin, nColIni + 5, "OBSERVACAO", oFont10N )
	oPrintAtend:Line(nLin + 4, nColIni , nLin + 4 , nColFim )
	FS_PULALINHA()
	FS_PULALINHA()
	FS_PULALINHA()
	FS_PULALINHA()
	FS_PULALINHA()

Return

/*/{Protheus.doc} FS_Irregularidade_Quadro()
	(long_description)
	@type  Static Function
	@author MIL
	@since 18/11/2019
	@version 1.0
	/*/
Static Function FS_Irregularidade_Quadro()
	oPrintAtend:Box(nLin - 10 , nColIni, nLin + ((nAltPadrao + nMaisAltura) * 3) - 8 , nColFim )
	oPrintAtend:Say(nLin, nColIni + 5, "IRREGULARIDADES NO VEÍCULO", oFont10N )
	oPrintAtend:Line(nLin + 4, nColIni , nLin + 4 , nColFim )
	FS_PULALINHA()
	FS_PULALINHA()
	FS_PULALINHA()

Return

Static Function FS_Teste(nAuxLinha)
	oPrintAtend:Say(nAuxLinha , 0 , "+", oFont10)
	oPrintAtend:Say(nAuxLinha , 10 , "+", oFont10)
	oPrintAtend:Say(nAuxLinha , 20 , "+", oFont10)
	oPrintAtend:Say(nAuxLinha , 30 , "+", oFont10)
	oPrintAtend:Say(nAuxLinha , 200 , "+", oFont10)
	oPrintAtend:Say(nAuxLinha , 210 , "+", oFont10)
	oPrintAtend:Say(nAuxLinha , 220 , "+", oFont10)
	oPrintAtend:Say(nAuxLinha , 230 , "+", oFont10)
	oPrintAtend:Say(nAuxLinha , 300 , "-", oFont10)
	oPrintAtend:Say(nAuxLinha , 310 , "-", oFont10)
	oPrintAtend:Say(nAuxLinha , 320 , "-", oFont10)
	oPrintAtend:Say(nAuxLinha , 330 , "-", oFont10)
	oPrintAtend:Say(nAuxLinha , 500 , ".", oFont10)
	oPrintAtend:Say(nAuxLinha , 510 , ".", oFont10)
	oPrintAtend:Say(nAuxLinha , 520 , ".", oFont10)
	oPrintAtend:Say(nAuxLinha , 530 , ".", oFont10)
	oPrintAtend:Say(nAuxLinha , 600 , "#", oFont10)
	oPrintAtend:Say(nAuxLinha , 610 , "#", oFont10)
	oPrintAtend:Say(nAuxLinha , 620 , "#", oFont10)
	oPrintAtend:Say(nAuxLinha , 630 , "#", oFont10)
Return


Static Function FS_Print(cLabel, cField, nAuxLin, nAuxCol, nAuxLargura)
	Default cField := ""
	Default nAuxLin := nLin
	Default nAuxCol := nColIni
	Default nAuxLargura := nLargPadrao

	oPrintAtend:Say( nAuxLin, nAuxCol,cLabel,oFont10,,,, )
	If ! Empty(cField)
		oPrintAtend:Say( nAuxLin, nAuxCol + nAuxLargura,cField,oFont10,,,, )
	EndIf

Return

Static Function FS_PulaLinha(nLinhas)
	Default nLinhas := 1
	nLin += NoRound((nAltPadrao + nMaisAltura) * nLinhas, 0)
Return

Static Function FS_AltLinha()
Return nAltPadrao + nMaisAltura

Static Function FS_PrintAlign(cText, nAuxLin, nAuxCol, oAuxFont, nAlignHorz , nAlignVert, nAuxWidth, nAuxHeight)

	Default nAuxLin := nLin - 8.5
	Default oAuxFont := oFont10
	Default nAlignHorz := 1 // 0 - Alinhamento à esquerda / 1 - Alinhamento à direita / 2 - Alinhamento centralizado
	Default nAlignVert := 1 // 0 - Alinhamento centralizado / 1 - Alinhamento superior / 2 - Alinhamento inferior
	Default nAuxWidth := oPrintAtend:GetTextWidth(cText,oAuxFont) * nPropPixel + 1
	Default nAuxHeight := NIL

	oPrintAtend:SayAlign( nAuxLin , nAuxCol , cText , oAuxFont ,nAuxWidth ,nAuxHeight, , nAlignHorz, nAlignVert )
	//oPrintAtend:SayAlign( nLin , nDiv_6_C_6 , "Data: " + DTOC(dDatabase),oFont9   ,oPrintAtend:GetTextWidth("Data: " + DTOC(dDatabase),oFont9) * nPropPixel + 1 ,, , 1, 1 )

	//ConOut( cValToChar(nAuxLin) + " - " + cValToChar(nAuxCol) + " - " + cValToChar(nAuxWidth) + " - " + cText)

Return

Static Function FS_POSTABELAS(cChamada, cFilAte, cNumAte, oModelImp)

	If cChamada == "PROPPED"

		VRJ->(dbGoTo(oModelImp:GetModel("MODEL_VRJ"):GetDataID()))

		VRK->(dbGoTo(oModelImp:GetModel("MODEL_VRK"):GetDataID(oModelImp:GetModel("MODEL_VRK"):GetLine())))

		VV9->(DbSetOrder(1))
		VV9->(DbSeek( xFilial("VV9") + VRK->VRK_NUMTRA))
	EndIf

	If cChamada == 'ATENDVEI"
		VV9->(DbSetOrder(1))
		VV9->(DbSeek( cFilAte + cNumAte ))
	EndIf
	
	VV0->(DbSetOrder(1))
	VV0->(DbSeek(VV9->VV9_FILIAL+VV9->VV9_NUMATE))
	
	VVA->(DbSetOrder(1))
	VVA->(DbSeek(VV9->VV9_FILIAL+VV9->VV9_NUMATE))

	VV1->(dbSetOrder(1))
	VV1->(dbSeek(xFilial("VV1") + VVA->VVA_CHAINT))
	
	SA1->(dbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+VV9->VV9_CODCLI+VV9->VV9_LOJA))
	
	VAM->(dbSetOrder(1))
	VAM->(DbSeek(xFilial("VAM")+SA1->A1_IBGE))
	
	SA3->(dbSetOrder(1))
	SA3->(DbSeek(xFilial("SA3")+VV0->VV0_CODVEN))

	FGX_VV2(VVA->VVA_CODMAR, VVA->VVA_MODVEI, VVA->VVA_SEGMOD)

	If cChamada == "ATENDVEI"

		cSQL := "SELECT R_E_C_N_O_" +;
			" FROM " + RetSQLName("VRK") + " VRK " +;
			" WHERE VRK.VRK_FILIAL = '" + xFilial("VRK") + "'" +;
			" AND VRK.VRK_NUMTRA = '" + VVA->VVA_NUMTRA + "'" +;
			" AND VRK.VRK_ITETRA = '" + VVA->VVA_ITETRA + "'" + ;
			" AND VRK.VRK_CANCEL <> '1'" + ;
			" AND VRK.D_E_L_E_T_ = ' '"
		nRecVRK := FM_SQL(cSQL)
		If nRecVRK <> 0

			VRK->(dbSetOrder(1))
			VRK->(dbGoTo(nRecVRK))

			// Pedido de Venda
			VRJ->(dbSetOrder(1))
			VRJ->(dbSeek(xFilial("VRJ") + VRK->VRK_PEDIDO ))

			VRK->(dbSeek(xFilial("VRK") + "000000022" + "001"))
			//
		EndIf
	EndIf

Return

Static Function FS_SetVar()

	nMargemL := oSetupImpr:GetProperty( PD_MARGIN )[PD_MARGIN_LEFT]
	nMargemR := oPrintAtend:nHorzRes() - oSetupImpr:GetProperty( PD_MARGIN )[PD_MARGIN_RIGHT]
	nMargemT := oSetupImpr:GetProperty( PD_MARGIN )[PD_MARGIN_TOP]
	nMargemB := oPrintAtend:nVertRes() - oSetupImpr:GetProperty( PD_MARGIN )[PD_MARGIN_BOTTOM]

	nHorzSize := oPrintAtend:nHorzSize()
	nVertSize := oPrintAtend:nVertSize()

	nColIni := 15
	nColFim := nHorzSize - 40
	nCenterPg := Round( nHorzSize / 2 ,0)
	nSpaceDiv := nHorzSize - nColIni - 40

	nAuxCol := Round( nSpaceDiv / 2 ,0)
	nDiv_2_C_1 := nColIni + 5
	nDiv_2_C_2 := nDiv_2_C_1 + nAuxCol

	nAuxCol := Round( nSpaceDiv / 3 ,0)
	nDiv_3_C_1 := nColIni + 5
	nDiv_3_C_2 := nDiv_3_C_1 + nAuxCol
	nDiv_3_C_3 := nDiv_3_C_2 + nAuxCol

	nAuxCol := Round( nSpaceDiv / 4 ,0)
	nDiv_4_C_1 := nColIni + 5
	nDiv_4_C_2 := nDiv_4_C_1 + nAuxCol
	nDiv_4_C_3 := nDiv_4_C_2 + nAuxCol
	nDiv_4_C_4 := nDiv_4_C_3 + nAuxCol

	nAuxCol := Round( nSpaceDiv / 5 ,0)
	nDiv_5_C_1 := nColIni + 5
	nDiv_5_C_2 := nDiv_5_C_1 + nAuxCol
	nDiv_5_C_3 := nDiv_5_C_2 + nAuxCol
	nDiv_5_C_4 := nDiv_5_C_3 + nAuxCol
	nDiv_5_C_5 := nDiv_5_C_4 + nAuxCol

	nAuxCol := Round( nSpaceDiv / 6 ,0)
	nDiv_6_C_1 := nColIni + 5
	nDiv_6_C_2 := nDiv_6_C_1 + nAuxCol
	nDiv_6_C_3 := nDiv_6_C_2 + nAuxCol
	nDiv_6_C_4 := nDiv_6_C_3 + nAuxCol
	nDiv_6_C_5 := nDiv_6_C_4 + nAuxCol
	nDiv_6_C_6 := nDiv_6_C_5 + nAuxCol

	nAuxCol := Round( nSpaceDiv / 7 ,0)
	nDiv_7_C_1 := nColIni + 5
	nDiv_7_C_2 := nDiv_7_C_1 + nAuxCol
	nDiv_7_C_3 := nDiv_7_C_2 + nAuxCol
	nDiv_7_C_4 := nDiv_7_C_3 + nAuxCol
	nDiv_7_C_5 := nDiv_7_C_4 + nAuxCol
	nDiv_7_C_6 := nDiv_7_C_5 + nAuxCol
	nDiv_7_C_7 := nDiv_7_C_6 + nAuxCol

	nLin := 5
	nLargPadrao := 50
	nPropPixel := 72 / 300
	nMaisAltura := 4
	nAltPadrao := Round(oPrintAtend:GetTextHeight("T",oFont10) * nPropPixel , 0)

Return

Static Function FS_ImpDebug()

	Local oFileDbg
	Local cAuxFile := "D:\source\mil\protheus-dms-caoa\rdmakespessoais\ATENDVEI.txt"

	oPrintAtend:StartPage() // Inicia uma nova pagina

	cStartPath := GetSrvProfString("Startpath","")

	RegToMemory("SA1")

	oFileDbg := FWFileReader():New(cAuxFile)

	if (oFileDbg:Open())
		while (oFileDbg:hasLine())

			cComando := oFileDbg:GetLine()
			If ! Empty(cComando) .and. left(alltrim(cComando),2) <> "//"
				&(cComando)
			EndIf
			
		end
		oFileDbg:Close()
	endif
Return

