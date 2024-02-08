#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWPRINTSETUP.CH"

#DEFINE IMP_SPOOL 2
#DEFINE IMP_PDF   6

#DEFINE VBOX      080
#DEFINE VBOX      080
#DEFINE VSPACE    008
#DEFINE HSPACE    010
#DEFINE SAYVSPACE 008
#DEFINE SAYHSPACE 008
#DEFINE HMARGEM   030
#DEFINE VMARGEM   030

/*
=====================================================================================
Programa.:              ZMNTR001
Autor....:              CAOA - Evandro A M Santos
Data.....:              12/08/19
Descricao / Objetivo:   Impressão Ordem de Serviço Manutenção
Doc. Origem:            GAP_MNT001
						
Solicitante:            CAOA - Montadora de Veiculos
Uso......:              
Obs......:              SASAS
=====================================================================================
*/
User Function ZMNTR001()
	Local lCont			:= .T.
	Private oPrint		:= Nil // Objeto FWMSPrinter
	Private cPictCabec 	:= "LGRL" + FWGrpCompany() + ".BMP"
	Private nLinIni		:= 0
	Private nColIni		:= 10
	Private nColFim		:= 582
	Private nPgLargura 	:= 597
	Private nLinMax		:= 800
	Private nLinRet		:= 0
	Private nLinRodape	:= 0
	Private cQuery		:= ""
	Private cAliasTRB	:= GetNextAlias()
	Private lImpEtapa 	:= .F.
	Private cDescManut 	:= ""

	Private cCodOs		:= ""
	Private lHabPerg	:= .F.
	Private cPerg		:= "ZMNTR001"

	Private cTitulo		:= "ORDEM DE SERVIÇO DE MANUTENÇÃO"
	Private cFilName	:=  AllTrim( SM0->M0_FILIAL )

	Private oBrush  	:= TBrush():New(	,CLR_HGRAY	,	,	)
	Private oFont07  	:= TFont():New(	"Arial"	,	,06	,	,.F.	,	,	,	,	,.F.	,.F.	)
	Private oFont07N  	:= TFont():New(	"Arial"	,	,06	,	,.T.	,	,	,	,	,.F.	,.F.	)
	Private oFont08  	:= TFont():New(	"Arial"	,	,08	,	,.F.	,	,	,	,	,.F.	,.F.	)
	Private oFont08N  	:= TFont():New(	"Arial"	,	,08	,	,.T.	,	,	,	,	,.F.	,.F.	)
	Private oFont10		:= TFont():New(	"Arial"	,	,10	,	,.F.	,	,	,	,	,.F.	,.F.	)
	Private oFont10N  	:= TFont():New(	"Arial"	,	,10	,	,.T.	,	,	,	,	,.F.	,.F.	)
	Private oFont10NS  	:= TFont():New(	"Arial"	,	,10	,	,.T.	,	,	,	,	,.T.	,.F.	)
	Private oFont12  	:= TFont():New(	"Arial"	,	,12	,	,.F.	,	,	,	,	,.F.	,.F.	)
	Private oFont12N  	:= TFont():New(	"Arial"	,	,12	,	,.T.	,	,	,	,	,.F.	,.F.	)
	Private oFont14  	:= TFont():New(	"Arial"	,	,14	,	,.F.	,	,	,	,	,.F.	,.F.	)
	Private oFont14N  	:= TFont():New(	"Arial"	,	,14	,	,.T.	,	,	,	,	,.F.	,.F.	)
	Private oFont16N  	:= TFont():New(	"Arial"	,	,16	,	,.T.	,	,	,	,	,.F.	,.F.	)
	Private oFont18  	:= TFont():New(	"Arial"	,	,18	,	,.F.	,	,	,	,	,.F.	,.F.	)
	Private oFont18N  	:= TFont():New(	"Arial"	,	,18	,	,.T.	,	,	,	,	,.F.	,.F.	)


	// Valida os fontes que irÃ£o chamar a rotina de impressÃ£o customizada.
	If AllTrim( FunName() ) $ "MNTA265|MNTA990"
		lHabPerg 	:= .F.
		cCodOs 		:= cInQry
	ElseIf AllTrim( FunName() ) $ "MNTA291|MNTA400|MNTA435|MNTA902"
		lHabPerg 	:= .F.
		cCodOs 		:=  cOrdemPE
	ElseIf AllTrim( FunName() ) $ "MNTA420"
		lHabPerg 	:= .F.
		cCodOs 		:=  STJ->TJ_ORDEM
	Else
		lHabPerg := .T.
	EndIf

	If lHabPerg
		while lCont = .T.
			if Pergunte( cPerg	,.T.	)  = .F.
				lCont := .F.
				Return
			endif

			If Vazio(MV_PAR04) .or. Vazio(MV_PAR05)
				MsgStop("O intevalo de datas não pode ser vazio", " ")
				Return
			EndIf

			If Vazio(MV_PAR02) .or. Vazio(MV_PAR03)
				MsgStop("O intevalo de ordens ser vazio", " ")
				Return
			endif

			Processa({||ZImpRel() }, "Realizando a Impressão da Ordem de Serviço...") // Processa o Inicio da Impressão
		EndDo
	Else
		Processa({||ZImpRel() }, "Realizando a Impressão da Ordem de Serviço...") // Processa o Inicio da Impressão
	EndIf


Return

/*
=====================================================================================
Programa.:              ZImpRel
Autor....:              CAOA - Evandro A M Santos
Data.....:              12/08/19
Descricao / Objetivo:   Realiza a Impressão do Relatório
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos
Uso......:				ZMNTR001              
Obs......:              
=====================================================================================
*/
Static Function ZImpRel()
	Local nQtRegs			:= 0
	Local lAdjustToLegacy 	:= .F.
	Local lDisableSetup		:= .T.
	Local lViewPDF			:= .T.
	Local cFileOP			:= "OrdServico_CAOA.pdf"

	// Ordem obrigátoria de configuração do relatório
	oPrint := 	FWMSPrinter():New(cFileOP	,IMP_PDF	,lAdjustToLegacy	,	,lDisableSetup	,	,	,	,	,	,	,lViewPDF	)

	oPrint:SetResolution(72)				// Resolução Padrão
	oPrint:SetPortrait() 					// Seta modo retrato como padrão
	oPrint:SetPaperSize(9) 					// Seta o tipo de folha para impressão
	oPrint:SetMargin(05	,05	,05	,05	) 		// Seta as margens
	oPrint:cPathPDF := GetTempPath()

	FErase(oPrint:cPathPDF + cFileOP, nil, .F. ) // remover o arquivo antigo

	DbSelectArea("STJ")
	STJ->(DbSetOrder(01))

	If Select((cAliasTRB)) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf

	If lHabPerg
		If MV_PAR01 == 1 // Por Plano de Manutenção
			cQuery := ""
			cQuery += " SELECT * FROM " + RetSqlName("STJ") + " STJ "														+ CRLF
			cQuery += " WHERE STJ.D_E_L_E_T_ = ' ' "																		+ CRLF
			cQuery += " AND STJ.TJ_ORDEM IN ( 	SELECT TT2_ORDEM FROM " + RetSqlName("TT2") + " TT2 "						+ CRLF
			cQuery += " 						WHERE TT2.D_E_L_E_T_ = ' ' "												+ CRLF
			cQuery += " 						AND TT2.TT2_CODIGO BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "		+ CRLF
			cQuery += " 						AND TT2.TT2_TIPO = '2' "													+ CRLF
			cQuery += " 					) "																				+ CRLF
			cQuery += " AND STJ.TJ_DTORIGI BETWEEN '" + Dtos(MV_PAR04) + "' AND '" + Dtos(MV_PAR05) + "' "					+ CRLF
			cQuery += " ORDER BY STJ.TJ_ORDEM "																				+ CRLF
		Else // Por ordem de Serviço
			cQuery := ""
			cQuery += " SELECT * FROM " + RetSqlName("STJ") + " STJ " 														+ CRLF
			cQuery += " WHERE STJ.D_E_L_E_T_ = ' ' " 																		+ CRLF
			cQuery += " AND STJ.TJ_ORDEM BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "								+ CRLF
			cQuery += " AND STJ.TJ_DTORIGI BETWEEN '" + Dtos(MV_PAR04) + "' AND '" + Dtos(MV_PAR05) + "' "					+ CRLF
		EndIf
	Else
		cQuery := ""
		cQuery += " SELECT * FROM " + RetSqlName("STJ") + " STJ " 															+ CRLF
		cQuery += " WHERE STJ.D_E_L_E_T_ = ' ' " 																			+ CRLF
		If AllTrim( FunName() ) $ "MNTA265|MNTA990"
			cQuery += " AND STJ.TJ_ORDEM IN (" + cCodOs + ") "																+ CRLF
		Else
			cQuery += " AND STJ.TJ_ORDEM = '" + cCodOs + "' " 																+ CRLF
		EndIf
	EndIf

	cQuery := ChangeQuery(cQuery)
	//Executa a consulta
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

	DbSelectArea((cAliasTRB))

	DbEval( {||nQtRegs++}, {||1=1} ) //conte quantos registro a consulta retornou
	If nQtRegs = 0
		MsgStop("A consulta não retornou nenhum registro.", "ZMNTR001")
		Return
	EndIf

	(cAliasTRB)->(dbGoTop())
	If (cAliasTRB)->(!Eof())
		While (cAliasTRB)->(!Eof())
			If STJ->( DbSeek( (cAliasTRB)->TJ_FILIAL + (cAliasTRB)->TJ_ORDEM + (cAliasTRB)->TJ_PLANO  ) )

				oPrint:StartPage() 			// Inicia a Página

				nLinRet := zImpCabec() 		// Imprime CABEÇALHO.

				nLinRet := zImpQdr01() 		// Imprime ORDEM DE SERVIÇO

				nLinRet := zImpQdr02() 		// Imprime BEM/LOCALIZAÇÃO

				If ( nLinRet + 030 ) < nLinMax
					nLinRet := zImpQdr03()	// Imprime ESPECIALIDADE/MÃO DE OBRA
				Else
					nLinIni := 0
					oPrint:EndPage()
					oPrint:StartPage()
					zImpCabec()
					nLinRet := zImpQdr03()	// Imprime ESPECIALIDADE/MÃO DE OBRA
				EndIf

				If ( nLinRet + 030 ) < nLinMax
					nLinRet := zImpQdr04()	// Imprime MANUTENÇÃO
				Else
					nLinIni := 0
					oPrint:EndPage()
					oPrint:StartPage()
					zImpCabec()
					nLinRet := zImpQdr04()	// Imprime MANUTENÇÃO
				EndIf

				If ( nLinRet + 030 ) < nLinMax
					nLinRet := zImpQdr05()	// Imprime ETAPAS
				Else
					nLinIni := 0
					oPrint:EndPage()
					oPrint:StartPage()
					zImpCabec()
					nLinRet := zImpQdr05()	// Imprime ETAPAS
				EndIf

				If ( nLinRet + 030 ) < nLinMax
					nLinRet := zImpQdr06()	// Imprime PROCEDIMENTO DE MANUTENÇÃO
				Else
					nLinIni := 0
					oPrint:EndPage()
					oPrint:StartPage()
					zImpCabec()
					nLinRet := zImpQdr06()	// Imprime PROCEDIMENTO DE MANUTENÇÃO
				EndIf

				If ( nLinRet + 080 ) < nLinMax
					nLinRet := zImpQdr07()	// Imprime HISTORICO MANUTENCAO REALIZADA
				Else
					nLinIni := 0
					oPrint:EndPage()
					oPrint:StartPage()
					zImpCabec()
					nLinRet := zImpQdr07()	// Imprime HISTORICO DA MANUTENCAO REALIZADA
				EndIf

				If  ( nLinRet + 095 ) < nLinMax
					nLinRet := zImpQdr08()	// Imprime MAO DE OBRA
				Else
					nLinIni := 0
					oPrint:EndPage()
					oPrint:StartPage()
					zImpCabec()
					nLinRet := zImpQdr08()	// Imprime MAO DE OBRA
				EndIf

				If nLinRet < nLinMax
					nLinRodape := 745
					nLinRet := zImpRodape()	// Imprime RODAPÉ
				Else
					nLinIni 	:= 0
					nLinRodape 	:= 0
					oPrint:EndPage()
					oPrint:StartPage()
					nLinRet := zImpRodape()	// Imprime RODAPÉ
				EndIf

			EndIf

			oPrint:EndPage()
			oPrint:StartPage()

			// Imprime folha adicional
			zImpAux()
			oPrint:EndPage()

			(cAliasTRB)->(DbSkip())
		EndDo
	EndIf

	If oPrint:GetViewPDF()
		oPrint:Preview()	// VISUALIZAR DOCUMENTO GERADO
	EndIf

	oPrint := Nil

Return

/*
=====================================================================================
Programa.:              zImpCabec
Autor....:              CAOA - Evandro A M Santos
Data.....:              12/08/19
Descricao / Objetivo:   Impressão Do Cabeçalho
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos
Uso......:              ZMNTR001
Obs......:              
=====================================================================================
*/
Static Function zImpCabec()

	nLinIni := 0

	//Monta quadro superior
	// 				Lin Inicial	  , Col Inicial	, Lin Final			, Col Final	, Espesura.
	oPrint:Box( ( nLinIni + 015 )	,( nColIni )		,( nLinIni + 055 )	,( nColFim )		,"+1"	)

	//Logotipo
	oPrint:SayBitmap( ( nLinIni + 020 )	,( nColIni + 005 )	,cPictCabec	,075	,028	)

	//Titulo do relatório: ORDEM DE SERVIÇO DE MANUTENÇÃO
	oPrint:SayAlign( ( nLinIni + 028 )	,( nColIni )	,cTitulo	,oFont16N	,( nColFim )	,( nLinIni + 25 )	,CLR_BLACK	,2	,2	)
	nLa  := 32
	nLb  := 42
	nCoA := 449
	nCoB := 420
	//Nome da Empresa
	oPrint:Say( ( nLinIni + nLa )	,( nColIni + nCoA )	,PadC(Substr( AllTrim( cFilName ),1 ,At( " ",cFilName )-1 )                 ,30 ) ,oFont10N )
	oPrint:Say( ( nLinIni + nLb )	,( nColIni + nCoB )	,PadC(Substr( AllTrim( cFilName ),	At( " ",cFilName )+1 , Len( cFilName ) ),30 ) ,oFont10N )

	//Ultima linha dessa seção
	nLinIni += 055 // Ultima linha dessa seção
	nLinIni += 005 // Recuo para próxima impressão

Return(nLinIni)

/*
=====================================================================================
Programa.:              zImpQdr01
Autor....:              CAOA - Evandro A M Santos
Data.....:              12/08/19
Descricao / Objetivo:   Impressão do Quadro ORDEM DE MANUTENÇÃO
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos
Uso......:              ZMNTR001
Obs......:              
=====================================================================================
*/
Static Function zImpQdr01()
	Local dDtIni := nil
	Local dDtFim := nil


	//Numero da ordem de serviço - ORDEM DE SERVIÇO
	oPrint:Say( ( nLinIni + 003 )	,( nColIni + 005 )	,cFilName																,oFont10N	)
	oPrint:Say( ( nLinIni + 003 )	,( nColIni + 323 )	,"ORDEM DE SERVIÇO DE MANUTENÇÃO:"										,oFont10N	)
	oPrint:Say( ( nLinIni + 003 )	,( nColIni + 482 )	,AllTrim( (cAliasTRB)->TJ_ORDEM )										,oFont10	)

	If !Empty( (cAliasTRB)->TJ_SOLICI )

		//Numero da Solicitação - ORDEM DE SERVIÇO
		oPrint:Say( ( nLinIni + 014 )	,( nColIni + 370 )	,"SOLICITAÇÃO DE SERVIÇO:"												,oFont10N	)
		oPrint:Say( ( nLinIni + 014 )	,( nColIni + 482 )	,AllTrim( (cAliasTRB)->TJ_SOLICI )										,oFont10	)

		// Solicitante - ORDEM DE SERVIÇO
		oPrint:Say( ( nLinIni + 025 )	,( nColIni + 005 )	,"SOLICITANTE:"															,oFont10N	)
		oPrint:Say( ( nLinIni + 025 )	,( nColIni + 064 )	,Upper( SubStr( UsrRetName( NGSEEK('TQB',(cAliasTRB)->TJ_SOLICI,1,'TQB->TQB_CDSOLI' ) ),1,15 ) )	,oFont10	)

		// Data Solicitação - ORDEM DE SERVIÇO
		oPrint:Say( ( nLinIni + 025 )	,( nColIni + 239 )	,"DATA SOLIC.:"															,oFont10N	)
		oPrint:Say( ( nLinIni + 025 )	,( nColIni + 298 )	,DtoC( NGSEEK('TQB',(cAliasTRB)->TJ_SOLICI,1,'TQB->TQB_DTABER' ) )		,oFont10	)

		// Hora Solicitação - ORDEM DE SERVIÇO
		oPrint:Say( ( nLinIni + 025 )	,( nColIni + 422 )	,"HORA SOLIC.:"															,oFont10N	)
		oPrint:Say( ( nLinIni + 025 )	,( nColIni + 482 )	,NGSEEK('TQB',(cAliasTRB)->TJ_SOLICI,1,'TQB->TQB_HOABER' )				,oFont10	)

	EndIf

	// tratamento para  data inicio e fim

	GetDtIniFim((cAliasTRB)->TJ_ORDEM, @dDtIni, @dDtFim)

	Iif( Empty(dDtIni) = .T.,  dDtIni := Stod((cAliasTRB)->TJ_DTMPINI), "")
	Iif( Empty(dDtFim) = .T.,  dDtFim := Stod((cAliasTRB)->TJ_DTMPFIM), "")


	// Data  Ínicio - ORDEM DE SERVIÇO
	oPrint:Say( ( nLinIni + 036 )	,( nColIni + 005 )	,"SIGA/MNTR675             INÍCIO:"											,oFont10N	)
//	oPrint:Say( ( nLinIni + 036 )	,( nColIni + 120 )	,DToC( SToD( (cAliasTRB)->TJ_DTMPINI) ) /* + " - " + (cAliasTRB)->TJ_HOMPINI */	,oFont10	)
	oPrint:Say( ( nLinIni + 036 )	,( nColIni + 120 )	,DToC( dDtIni ) /* + " - " + (cAliasTRB)->TJ_HOMPINI */	,oFont10	)

	// Data e Horário Fim - ORDEM DE SERVIÇO
	oPrint:Say( ( nLinIni + 036 )	,( nColIni + 239 )	,"FIM:"																		,oFont10N	)
//	oPrint:Say( ( nLinIni + 036 )	,( nColIni + 256 )	,DToC( SToD( (cAliasTRB)->TJ_DTMPFIM) ) /* + " - " + (cAliasTRB)->TJ_HOMPFIM */	,oFont10	)
	oPrint:Say( ( nLinIni + 036 )	,( nColIni + 256 )	,DToC( dDtFim ) /* + " - " + (cAliasTRB)->TJ_HOMPFIM */	,oFont10	)

	// Emissão - ORDEM DE SERVIÇO
	oPrint:Say( ( nLinIni + 036 )	,( nColIni + 437 )	,"EMISSÃO:"																,oFont10N	)
	oPrint:Say( ( nLinIni + 036 )	,( nColIni + 482 )	,DToC( Date() )															,oFont10	)

	// Plano  - ORDEM DE SERVIÇO
	oPrint:Say( ( nLinIni + 047 )	,( nColIni + 005 )	,"PLANO:"																,oFont10N	)
	oPrint:Say( ( nLinIni + 047 )	,( nColIni + 038 )	,(cAliasTRB)->TJ_PLANO 													,oFont10	)

	If (cAliasTRB)->TJ_TIPOOS == "B"
		// Prioridade - ORDEM DE SERVIÇO
		oPrint:Say( ( nLinIni + 047 )	,( nColIni + 239 )	,"PRIORIDADE MANUT.:"												,oFont10N	)
		oPrint:Say( ( nLinIni + 047 )	,( nColIni + 328 )	,(cAliasTRB)->TJ_PRIORID											,oFont10	)
	EndIf

	// Descrição do Plano - ORDEM DE SERVIÇO
	oPrint:Say( ( nLinIni + 047 )	,( nColIni + 370 )	,AllTrim( NGSEEK('STI',(cAliasTRB)->TJ_PLANO,1,'SubStr(STI->TI_DESCRIC,1,39)')	)	,oFont10N	)

	nLinIni += 047 // Ultima linha dessa seção
	nLinIni += 005 // Recuo para próxima impressão

Return(nLinIni)

/* =====================================================================================
Programa.:              GetDtIniFim
Autor....:              CAOA - Valter Carvalho
Data.....:              12/08/19
Descricao / Objetivo:   Pesquisa A DATA INICIAL R FINAL DO DETALHE da Ordem de Servico   
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos
Uso......:              zImpQdr01
===================================================================================== */
Static Function GetDtIniFim(cOrdem, dDtIni, dDtFim)
	Local aAreaStl := STL->(GetArea())

	DbSelectArea("STL")
	DbSetOrder(1)

	If STL->(DbSeek(cFilAnt + cOrdem  ))

		While  STL->TL_FILIAL + STL->TL_ORDEM  ==  cFilAnt + cOrdem

			If STL->TL_DTINICI < dDtIni
			dDtIni := STL->TL_DTINICI
			EndIf

			If STL->TL_DTFIM > dDtFim
			dDtFim := STL->TL_DTFIM
			EndIf

		STL->(DbSkip())
		EndDo
		
	EndIf
	STL->(RestArea(aAreaStl))
Return

/*
=====================================================================================
Programa.:              zImpQdr02
Autor....:              CAOA - Evandro A M Santos
Data.....:              12/08/19
Descricao / Objetivo:   Impressão Dos BEM/LOCALIZAÇÃO
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos
Uso......:              ZMNTR001
Obs......:              
=====================================================================================
*/
Static Function zImpQdr02()
	Local nY		:= 1
	Local cCodBemPai:= ""
	Local cLocaliz	:= ""
	Local cDesQdr02	:= ""
	Local cDescCod	:= ""
	Local nTamLin	:= 0

	DbSelectArea("ST9")
	ST9->(DbSetOrder(01))

	// Linha: OBSERVAÇÃO
	oPrint:Line( ( nLinIni )		,( nColIni )		,( nLinIni )		,( nColFim )		,	,"+1"		)
	oPrint:Line( ( nLinIni + 013 )	,( nColIni )		,( nLinIni + 013 )	,( nColFim )		,	,"+1"		)
	oPrint:SayAlign( ( nLinIni  )	,( nColIni )		,"BEM/LOCALIZAÇÃO"	,oFont12N	,( nColFim )	,( nLinIni )	,CLR_BLACK	,2	,2	)

	// Tratamento para buscar a Localização - BEM/LOCALIZAÇÃO

	/*	If !Vazio(Posicione("TAF", 8, Xfilial("STJ") + (cAliasTRB)->TJ_CODBEM, "TAF_FILIAL")) */ 

	If (cAliasTRB)->TJ_TIPOOS == "B"

//		If ZMNTBINT(cCodCon) = .T. // verificar se o bem está na arvore
		cLocaliz := NGLocComp((cAliasTRB)->TJ_CODBEM,'1') //Bem

		If AllTrim( cLocaliz ) == AllTrim( (cAliasTRB)->TJ_CODBEM ) // NÃO cadastrado na arvore
			cCodBemPai := NGBEMPAI((cAliasTRB)->TJ_CODBEM)

			if Empty(cCodBemPai)
				cLocaliz := "Localização não cadastrada"
			Else
				cLocaliz := "Bem Pai:" + NGLocComp(AllTrim(cCodBemPai),'1') //Estrutura de Bem pai
			EndIf

		EndIf
	Else
		cLocaliz := NGLocComp((cAliasTRB)->TJ_CODBEM,'2') //Localização
	EndIf

/*	If Empty(cLocaliz)
		cLocaliz := "Localização não cadastrada"
Endif */

	// Descrição - BEM/LOCALIZAÇÃO
	cDesQdr02 := AllTrim( Substr( ST9->T9_DESCRIC ,300 ,070 ) )

	// Localização - BEM/LOCALIZAÇÃO
	oPrint:Say( ( nLinIni + 023 )	,( nColIni + 005 )	,"LOCALIZAÇÃO:"															,oFont10N	)

If !Empty(cLocaliz)
	For nY := 1 To MLCount( cLocaliz, 115,,.T. )

			// Localização - BEM/LOCALIZAÇÃO
			oPrint:Say( ( ( nLinIni + 023 ) + nTamLin )	,( nColIni + 068 )	,AllTrim( MemoLine( cLocaliz, 115, nY ) )			,oFont10	)
			nTamLin	+= 011

	Next nY
EndIf

	// Define a váriavel como 0 para iniciar novamente a impressão
	nLinIni := ( nLinIni + 023 ) + nTamLin
	nTamLin := 0

	cDescCod := AllTrim(SubStr((cAliasTRB)->TJ_CODBEM,1,20))
If (cAliasTRB)->TJ_TIPOOS == "B"
		//Adiciona a Descrição quando o Tipo == B
		cDescCod += " - "+ AllTrim( SubStr( NGSEEK('ST9',(cAliasTRB)->TJ_CODBEM,1,'ST9->T9_NOME') ,01 ,40 ) )
EndIf

	// Código - BEM/LOCALIZAÇÃO
	oPrint:Say( ( nLinIni )			,( nColIni + 005 )	,"CÓDIGO:"																,oFont10N	)
	oPrint:Say( ( nLinIni )			,( nColIni + 045 )	,cDescCod 																,oFont10	)

	// Prioridade - BEM/LOCALIZAÇÃO
	oPrint:Say( ( nLinIni )			,( nColIni + 425 )	,"PRIORIDADE:"															,oFont10N	)
	oPrint:Say( ( nLinIni )			,( nColIni + 480 )	,If( Empty( ST9->T9_LOCAL ), NGSEEK('ST9',(cAliasTRB)->TJ_CODBEM , 1,'ST9->T9_PRIORID'), "") ,oFont10	)

	// Pai - BEM/LOCALIZAÇÃO
	oPrint:Say( ( nLinIni + 011 )	,( nColIni + 005 )	,"PAI:"																	,oFont10N	)
	oPrint:Say( ( nLinIni + 011 )	,( nColIni + 024 )	,If( !Empty( AllTrim( NGBEMPAI((cAliasTRB)->TJ_CODBEM))),AllTrim( NGBEMPAI( (cAliasTRB)->TJ_CODBEM) ) + " - " + AllTrim( NGSEEK('ST9',AllTrim( NGBEMPAI((cAliasTRB)->TJ_CODBEM) ),1,'ST9->T9_NOME') )," - ")	,oFont10	)

	// Centro de Custo - BEM/LOCALIZAÇÃO
	oPrint:Say( ( nLinIni + 022 )	,( nColIni + 005 )	,"C.CUSTO:"																,oFont10N	)
	oPrint:Say( ( nLinIni + 022 )	,( nColIni + 048 )	,AllTrim( SubStr( (cAliasTRB)->TJ_CCUSTO,1,20) ) + " - " + AllTrim( SubStr( NGSEEK('SI3',(cAliasTRB)->TJ_CCUSTO,1,'SI3->I3_DESC'),1,30) )	,oFont10	)

	nLinIni += 022 // Ultima linha dessa seção
	nLinIni += 005 // Recuo para próxima impressão

Return(nLinIni)

/*
=====================================================================================
Programa.:              zImpQdr03
Autor....:              CAOA - Evandro A M Santos
Data.....:              13/08/19
Descricao / Objetivo:   Impressão ESPECIALIDADE/MÃO DE OBRA
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos
Uso......:              ZMNTR001
Obs......:              
=====================================================================================
*/
Static Function zImpQdr03()

	Local aNome		:= {}
	Local nTamLin	:= 0

	// Linha: OBSERVAÇÃO
	oPrint:Line( ( nLinIni )		,( nColIni )		,( nLinIni )		,( nColFim )		, 	,"+1"		)
	oPrint:Line( ( nLinIni + 013 )	,( nColIni )		,( nLinIni + 013 )	,( nColFim ) 		,	,"+1"		)
	oPrint:SayAlign( ( nLinIni  )	,( nColIni )	,"ESPECIALIDADE/MÃO DE OBRA"	,oFont12N	,( nColFim )	,( nLinIni )	,CLR_BLACK	,2	,2	)


	oPrint:Line( ( nLinIni + 018 )	,( nColIni + 290 )	,( nLinIni + 018 )	,( nColIni + 378 )	,	,"-1"		) // Horizontal Esquerda
	oPrint:Line( ( nLinIni + 018 )	,( nColIni + 413 )	,( nLinIni + 018 )	,( nColIni + 488 )	,	,"-1"		) // Horizontal Direita
	oPrint:Line( ( nLinIni + 018 )	,( nColIni + 290 )	,( nLinIni + 026 )	,( nColIni + 290 )	,	,"-1"		) // Vertical Esquerda
	oPrint:Line( ( nLinIni + 018 )	,( nColIni + 488 )	,( nLinIni + 026 )	,( nColIni + 488 )	,	,"-1"		) // Vertical Direita
	oPrint:Say(  ( nLinIni + 020 )	,( nColIni + 381 )	,"PREVISTO"																,oFont07N	)

	// Cabeçalho da ESPECIALIDADE/MÃO DE OBRA
	oPrint:Say( ( nLinIni + 035 )	,( nColIni + 010 )	,"NOME"																	,oFont08N	)
	oPrint:Say( ( nLinIni + 035 )	,( nColIni + 083 )	,"CÓDIGO"																,oFont08N	)
	oPrint:Say( ( nLinIni + 035 )	,( nColIni + 200 )	,"DESCRIÇÃO"															,oFont08N	)
//	oPrint:Say( ( nLinIni + 035 )	,( nColIni + 300 )	,"DATA" 																,oFont08N	)
//	oPrint:Say( ( nLinIni + 035 )	,( nColIni + 340 )	,"HORA"																	,oFont08N	)
	oPrint:Say( ( nLinIni + 035 )	,( nColIni + 378 )	,"QUANTID"																,oFont08N	)
	oPrint:Say( ( nLinIni + 035 )	,( nColIni + 417 )	,"CONSUMO"																,oFont08N	)
	oPrint:Say( ( nLinIni + 035 )	,( nColIni + 463 )	,"UNID"																	,oFont08N	)

	DbSelectArea("STL")
	STL->(DbSetOrder(03))
	If STL->( DbSeek(xFilial("STL") + (cAliasTRB)->TJ_ORDEM + (cAliasTRB)->TJ_PLANO + "0  " ) )
		While STL->(!Eof()) .And. (cAliasTRB)->TJ_ORDEM == STL->TL_ORDEM .And. (cAliasTRB)->TJ_PLANO == STL->TL_PLANO

			If STL-> TL_TIPOREG $ "M|E" .And. STL->TL_REPFIM <> 'S'

				nTamLin += 011

				// Tratamento do campo NOME
				aNome := {}
				aNome := NGNOMINSUM( STL->TL_TIPOREG , STL->TL_CODIGO , 30 )

				If Len(aNome) > 0
					// Conteúdo NOME
					oPrint:Say( (( nLinIni + 033 ) + nTamLin )	,( nColIni + 007 )	,Substr( aNome[1][1],1,4 )						,oFont08	)
				EndIf

				// Conteúdo CÓDIGO
				oPrint:Say( (( nLinIni + 033 ) + nTamLin )	,( nColIni + 044 )	,Substr( STL->TL_CODIGO,1,30 )						,oFont08	)


				If Len(aNome) > 0
					// Conteúdo Descrição
					oPrint:Say( (( nLinIni + 033 ) + nTamLin )	,( nColIni + 152 )	,SubStr( aNome[1][2],1,30 )						,oFont08	)
				EndIf

				// Conteúdo Data Previsão
				//oPrint:Say( (( nLinIni + 033 ) + nTamLin )	,( nColIni + 292 )	,DToC( STL->TL_DTINICI )							,oFont08	)

				// Conteúdo Hora Previsão
				//oPrint:Say( (( nLinIni + 033 ) + nTamLin )	,( nColIni + 342 )	,STL->TL_HOINICI									,oFont08	)

				// Conteúdo Quantidade Previsão
				oPrint:Say( (( nLinIni + 033 ) + nTamLin )	,( nColIni + 388 )	,Str( STL->TL_QUANREC,3 )							,oFont08	)

				If STL->TL_TIPOREG <> "P"
					// Conteúdo Consumo Previsão
					oPrint:Say( (( nLinIni + 033 ) + nTamLin )	,( nColIni + 418 )	,Str( ZMNTCONV( STL->TL_QUANTID, STL->TL_TIPOHOR),9,2 )	,oFont08	)
				Else
					// Conteúdo Consumo Previsão
					oPrint:Say( (( nLinIni + 033 ) + nTamLin )	,( nColIni + 418 )	,Str( STL->TL_QUANTID,9,2 )						,oFont08	)
				EndIf

				// Conteúdo Unidade Previsão
				oPrint:Say( (( nLinIni + 033 ) + nTamLin )	,( nColIni + 470 )	,STL->TL_UNIDADE									,oFont08	)
			EndIf
			STL->(DbSkip())
		EndDo
	EndIf

	oPrint:Line( ( nLinIni + 036 )	,( nColIni + 005 )	,( nLinIni + 036 )					,( nColFim - 010 )	,	,"-1"	)
	oPrint:Line( ( nLinIni + 029 )	,( nColIni + 042 )	,( ( nLinIni + 033 ) + nTamLin )	,( nColIni + 042 )	,	,"-1"	)
	oPrint:Line( ( nLinIni + 026 )	,( nColIni + 150 )	,( ( nLinIni + 033 ) + nTamLin )	,( nColIni + 150 )	,	,"-1"	)
	oPrint:Line( ( nLinIni + 029 )	,( nColIni + 290 )	,( ( nLinIni + 033 ) + nTamLin )	,( nColIni + 290 )	,	,"-1"	)
	oPrint:Line( ( nLinIni + 029 )	,( nColIni + 332 )	,( ( nLinIni + 033 ) + nTamLin )	,( nColIni + 332 )	,	,"-1"	)
	oPrint:Line( ( nLinIni + 029 )	,( nColIni + 374 )	,( ( nLinIni + 033 ) + nTamLin )	,( nColIni + 374 )	,	,"-1"	)
	oPrint:Line( ( nLinIni + 029 )	,( nColIni + 416 )	,( ( nLinIni + 033 ) + nTamLin )	,( nColIni + 416 )	,	,"-1"	)
	oPrint:Line( ( nLinIni + 029 )	,( nColIni + 458 )	,( ( nLinIni + 033 ) + nTamLin )	,( nColIni + 458 )	,	,"-1"	)

	nLinIni := ( nLinIni + 033 ) + nTamLin // Ultima linha dessa seção
	nLinIni += 005 // Recuo para próxima impressão

Return(nLinIni)

/*
=====================================================================================
Programa.:              zImpQdr04
Autor....:              CAOA - Evandro A M Santos
Data.....:              13/08/19
Descricao / Objetivo:   Impressão MANUTENÇÃO
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos
Uso......:              ZMNTR001
Obs......:              
=====================================================================================
*/
Static Function zImpQdr04()
/* 	Local i			:= 1 		
	Local aPerMan	:= StrTokArr(AllTrim(GETSX3CACHE("TF_UNENMAN", "X3_CBOX")),";")
	Local cNmPer 	:= ""
 */

	cDescManut 	:= ""
	// Linha: OBSERVAÇÃO
	oPrint:Line( ( nLinIni )		,( nColIni )		,( nLinIni )		,( nColFim )		,	,"+1"	)
	oPrint:Line( ( nLinIni + 013 )	,( nColIni )		,( nLinIni + 013 )	,( nColFim )		,	,"+1"	)
	oPrint:SayAlign( ( nLinIni  )	,( nColIni )	,"MANUTENÇÃO"	,oFont12N	,( nColFim )	,( nLinIni )	,CLR_BLACK	,2	,2	)

	// Serviço - MANUTENÇÃO
	oPrint:Say( ( nLinIni + 023 )	,( nColIni + 005 )	,"SERVIÇO:"																,oFont10N	)
	oPrint:Say( ( nLinIni + 023 )	,( nColIni + 045 )	,AllTrim( (cAliasTRB)->TJ_SERVICO ) + " - " + AllTrim( NGSEEK('ST4',(cAliasTRB)->TJ_SERVICO,1,'Substr(ST4->T4_NOME,1,40)'))	,oFont10	)


   
/*   Usuário DIon pediu oara
	// Manutenção Anterior - MANUTENÇÃO
 	If (cAliasTRB)->TJ_TIPOOS == "B" .Or. (cAliasTRB)->TJ_TIPOOS == "L"
			DbSelectArea("STF")
			STF->(DbSetOrder(01))
			If STF->( DbSeek( xFilial('STF') + (cAliasTRB)->TJ_CODBEM + (cAliasTRB)->TJ_SERVICO + (cAliasTRB)->TJ_SEQRELA )	)

				For i:= 1 to Len(aPerMan)
					If Alltrim(STF->TF_UNENMAN) = Substr(Alltrim(aPerMan[i]), 1, Len(Alltrim(STF->TF_UNENMAN)))
						cNmPer := Substr(aPerMan[i], At("=", aPerMan[i]) + 1, Len(aPerMan[i]))
						Exit
					EndIf
				Next

				oPrint:Say( ( nLinIni + 023 )	,( nColIni + 395 )	, "Periodicidade.:"													, oFont10N	)
				oPrint:Say( ( nLinIni + 023 )	,( nColIni + 478 )	, PadL(STF->TF_TEENMAN, 2, "0") + " " + cNmPer                      , oFont10	)

			EndIf
	EndIf 

 	If (cAliasTRB)->TJ_TIPOOS == "B"
		// Manutenção Anterior - MANUTENÇÃO

		//oPrint:Say( ( nLinIni + 023 )	,( nColIni + 395 )	,"MANUTENÇÃO ANT.:"													,oFont10N	)
		//oPrint:Say( ( nLinIni + 023 )	,( nColIni + 478 )	,DToC( SToD( (cAliasTRB)->TJ_DTULTMA ) )							,oFont10	)
		oPrint:Say( ( nLinIni + 023 )	,( nColIni + 395 )	, "Periodicidade.:"													, oFont10N	)
		oPrint:Say( ( nLinIni + 023 )	,( nColIni + 478 )	, STF->TF_TEENMAN + " " + cNmPer                                    , oFont10	)
	EndIf
 */
	// Sequencia - MANUTENÇÃO
	oPrint:Say( ( nLinIni + 034 )	,( nColIni + 005 )	,"SEQUÊNCIA:"															,oFont10N	)
	oPrint:Say( ( nLinIni + 034 )	,( nColIni + 060 )	,(cAliasTRB)->TJ_SEQRELA 												,oFont10	)

	// Tratamento para Nome da Manutenção
	If (cAliasTRB)->TJ_TIPOOS == "B"

		// Nome da Manutenção - MANUTENÇÃO
		oPrint:Say( ( nLinIni + 034 )	,( nColIni + 186 )	,"NOME MANUT.:"														,oFont10N	)

		If (cAliasTRB)->TJ_PLANO == "000000"
			oPrint:Say( ( nLinIni + 034 )	,( nColIni + 248 )	,"CORRETIVA"													,oFont10	)
		Else
			DbSelectArea("STF")
			STF->(DbSetOrder(01))
			If STF->( DbSeek( xFilial('STF') + (cAliasTRB)->TJ_CODBEM + (cAliasTRB)->TJ_SERVICO + (cAliasTRB)->TJ_SEQRELA )	)
				// Nome da Manutenção - MANUTENÇÃO
				oPrint:Say( ( nLinIni + 034 )	,( nColIni + 248 ), Substr(STF->TF_NOMEMAN,01,050)	,oFont10	)
				oPrint:Say( ( nLinIni + 044 )	,( nColIni + 248 ), Substr(STF->TF_NOMEMAN,51,100)	,oFont10	)
			EndIf
		EndIf
	EndIf

	// Busca a descrição da Manutenção
	If (cAliasTRB)->TJ_TIPOOS == "B" .Or. (cAliasTRB)->TJ_TIPOOS == "L"

		If (cAliasTRB)->TJ_PLANO == "000000"
			cDescManut := AllTrim(STJ->TJ_OBSERVA)
		Else
			DbSelectArea("STF")
			STF->(DbSetOrder(01))
			If STF->( DbSeek( xFilial('STF') + (cAliasTRB)->TJ_CODBEM + (cAliasTRB)->TJ_SERVICO + (cAliasTRB)->TJ_SEQRELA )	)
				cDescManut := AllTrim(STF->TF_DESCRIC)
			EndIf
		EndIf
	EndIf

	// Area - MANUTENÇÃO
	oPrint:Say( ( nLinIni + 045 )	,( nColIni + 005 )	,"ÁREA:"																,oFont10N	)
	oPrint:Say( ( nLinIni + 045 )	,( nColIni + 035 )	,AllTrim( (cAliasTRB)->TJ_CODAREA) + " - " + AllTrim( NGSEEK('STD',(cAliasTRB)->TJ_CODAREA,1,'STD->TD_NOME') )	,oFont10	)

	// Tipo - MANUTENÇÃO
	oPrint:Say( ( nLinIni + 056 )	,( nColIni + 005 )	,"TIPO:"																,oFont10N	)
	oPrint:Say( ( nLinIni + 056 )	,( nColIni + 029 )	,AllTrim( (cAliasTRB)->TJ_TIPO) + " - " + AllTrim( NGSEEK('STE',(cAliasTRB)->TJ_TIPO,1,'STE->TE_NOME') ),oFont10	)

	nLinIni += 056 // Ultima linha dessa seção
	nLinIni += 005 // Recuo para próxima impressão

Return(nLinIni)

/*
=====================================================================================
Programa.:              zImpQdr05
Autor....:              CAOA - Evandro A M Santos
Data.....:              13/08/19
Descricao / Objetivo:   Impressão ETAPAS
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos
Uso......:              ZMNTR001
Obs......:              
=====================================================================================
*/
Static Function zImpQdr05()

	Local nTamLin := 0

	// Linha: OBSERVAÇÃO
	oPrint:Line( ( nLinIni )		,( nColIni )		,( nLinIni )		,( nColFim )		,	,"+1"	)
	oPrint:Line( ( nLinIni + 013 )	,( nColIni )		,( nLinIni + 013 )	,( nColFim )		,	,"+1"	)
	oPrint:SayAlign( ( nLinIni  )	,( nColIni )	,"ETAPAS"	,oFont12N	,( nColFim )	,( nLinIni )	,CLR_BLACK	,2	,2	)

	DbSelectArea("TPA")
	TPA->(DbSetOrder(01))

	DbSelectArea("STQ")
	STQ->(DbSetOrder(01))
	If STQ->( DbSeek( xFilial("STQ") + (cAliasTRB)->TJ_ORDEM + (cAliasTRB)->TJ_PLANO )	)
		While !STQ->(EoF()) .And. STQ->TQ_FILIAL == (cAliasTRB)->TJ_FILIAL 	;
				.And. STQ->TQ_ORDEM  == (cAliasTRB)->TJ_ORDEM 	;
				.And. STQ->TQ_PLANO  == (cAliasTRB)->TJ_PLANO

			If ( ( nLinIni + 011 ) + nTamLin ) <= nLinMax
				If TPA->( DbSeek( xFilial("TPA") + STQ->TQ_ETAPA) )

					// Conteúdo NOME
					lImpEtapa := .T.
					nTamLin += 011
					oPrint:Say( ( ( nLinIni + 011 ) + nTamLin )	,( nColIni + 007 )	,AllTrim( TPA->TPA_ETAPA ) + " - " + AllTrim( TPA->TPA_DESCRI )	,oFont08	)

				EndIf
				STQ->(DbSkip())
			Else
				nTamLin := -11
				oPrint:EndPage()
				oPrint:StartPage()
				zImpCabec()
				nTamLin := -0
				oPrint:Line( ( nLinIni )		,( nColIni )		,( nLinIni )		,( nColFim )		,	,"+1"	)
				oPrint:Line( ( nLinIni + 013 )	,( nColIni )		,( nLinIni + 013 )	,( nColFim )		,	,"+1"	)
				oPrint:SayAlign( ( nLinIni  )	,( nColIni )	,"ETAPAS"	,oFont12N	,( nColFim )	,( nLinIni )	,CLR_BLACK	,2	,2	)
			EndIf
		EndDo
	EndIf

	If lImpEtapa == .F.
		// Conteúdo NOME
		nTamLin += 011
		oPrint:Say( ( ( nLinIni + 011 ) + nTamLin )	,( nColIni + 007 )	, "*** ETAPA NÃO INFORMADA ***"							,oFont08	)
	EndIf

	lImpEtapa := .F.
	nLinIni :=  ( nLinIni + 011 ) + nTamLin // Ultima linha dessa seção
	nLinIni += 005 // Recuo para próxima impressão

Return(nLinIni)

/*
=====================================================================================
Programa.:              zImpQdr06
Autor....:              CAOA - Evandro A M Santos
Data.....:              13/08/19
Descricao / Objetivo:   Impressão PROCEDIMENTO DE MANUTENÇÃO
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos
Uso......:              ZMNTR001
Obs......:              
=====================================================================================
*/
Static Function zImpQdr06()
	Local nCaractLn := 130
	Local cDesQdr06	:= ""
	Local cObsQdr06	:= ""
	Local nY		:= 0
	Local nTamLin 	:= 0

	// Linha: PROCEDIMENTO DE MANUTENÇÃO
	oPrint:Line( ( nLinIni )		,( nColIni )		,( nLinIni )		,( nColFim )		,	,"+1"	)
	oPrint:Line( ( nLinIni + 013 )	,( nColIni )		,( nLinIni + 013 )	,( nColFim )		,	,"+1"	)
	oPrint:SayAlign( ( nLinIni  )	,( nColIni )	, "PROCEDIMENTO DE MANUTENÇÃO"	,oFont12N	,( nColFim )	,( nLinIni )	,CLR_BLACK	,2	,2	)

	// Descrição - OBSERVAÇÃO
	//cDesQdr06 	:= SubStr( cDescManut , AT( "1.",AllTrim( cDescManut ) ) , Len( AllTrim( cDescManut ) ) )
	cDesQdr06 	:= Upper(cDescManut)

	cDesQdr06 	:= strTran(cDesQdr06, char(13) , "    -")
	cDesQdr06 	:= strTran(cDesQdr06, char(10) , "    ")

	If !Empty( cDesQdr06 )

		For nY := 1 To MLCount( cDesQdr06, nCaractLn,,.T. )
			If ( nLinIni + nTamLin ) <= nLinMax

				nTamLin += 011    // Descrição - OBSERVAÇÃO
				oPrint:Say( ( ( nLinIni + 011 ) + nTamLin )	,( nColIni + 007 )	,AllTrim( MemoLine( cDesQdr06, nCaractLn, nY ) ), oFont08	)

			Else

				nTamLin	:= -11
				oPrint:EndPage()
				oPrint:StartPage()

				zImpCabec()

				nTamLin	:= 0
				oPrint:Line( ( nLinIni )		, ( nColIni )	, ( nLinIni )		,( nColFim )		,	,"+1"	)
				oPrint:Line( ( nLinIni + 013 )	, ( nColIni )	, ( nLinIni + 013 )	,( nColFim )		,	,"+1"	)
				oPrint:SayAlign( ( nLinIni  )	, ( nColIni )	, "PROCEDIMENTO DE MANUTENÇÃO"	,oFont12N	,( nColFim )	,( nLinIni )	,CLR_BLACK	,2	,2	)
			EndIf
		Next nY

	EndIf

	If Empty( cDesQdr06 ) .And. Empty( cObsQdr06 )

		nTamLin += 011
		oPrint:Say( ( ( nLinIni + 011 ) + nTamLin )	,( nColIni + 007 )	,"*** PROCEDIMENTO NÃO INFORMADO ***"						,oFont10	)
	EndIf

	nLinIni :=  ( nLinIni + 011 ) + nTamLin // Ultima linha dessa seção
	nLinIni += 005 // Recuo para próxima impressão

Return(nLinIni)

/*
=====================================================================================
Programa.:              zImpQdr07
Autor....:              CAOA - Evandro A M Santos
Data.....:              13/08/19
Descricao / Objetivo:   Impressão HISTORICO DA MANUTENCAO REALIZADA
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos
Uso......:              ZMNTR001
Obs......:              
=====================================================================================
*/
Static Function zImpQdr07()

// Linha: OBSERVAÇÃO
	oPrint:Line( ( nLinIni )		,( nColIni )		,( nLinIni )		,( nColFim )		,	,"+1"	)
	oPrint:SayAlign( ( nLinIni  )	,( nColIni )	,"HISTÓRICO DA MANUTENÇÃO REALIZADA"	,oFont12N	,( nColFim )	,( nLinIni )	,CLR_BLACK	,2	,2	)
	oPrint:Line( ( nLinIni + 013 )	,( nColIni )		,( nLinIni + 013 )	,( nColFim )		,	,"+1"	)

	oPrint:Line( ( nLinIni + 026 )	,( nColIni )		,( nLinIni + 026 )	,( nColFim )		,	,"-1"	)

	oPrint:SayAlign( ( nLinIni + 015 )	,( nColIni )	,"1. Informar as atividades desempenhadas durante a intervenção, evidenciar como o equipamento ficou após sanar as anomalias indentificadas."	,oFont08	,( nColFim )	,( nLinIni + 014 )	,CLR_BLACK	,2 ,2	)

	oPrint:Line( ( nLinIni + 041 )	,( nColIni )		,( nLinIni + 041 )	,( nColFim )		,	,"-1"	)

	oPrint:Line( ( nLinIni + 056 )	,( nColIni )		,( nLinIni + 056 )	,( nColFim )		,	,"-1"	)

	oPrint:Line( ( nLinIni + 071 )	,( nColIni )		,( nLinIni + 071 )	,( nColFim )		,	,"-1"	)

	oPrint:Line( ( nLinIni + 086 )	,( nColIni )		,( nLinIni + 086 )	,( nColFim )		,	,"-1"	)

	nLinIni :=  ( nLinIni + 083 + 015 ) // Ultima linha dessa seção Recebe
	//nLinIni += 005 // Recuo para próxima impressão

Return(nLinIni)

/*
=====================================================================================
Programa.:              zImpQdr08
Autor....:              CAOA - Evandro A M Santos
Data.....:              13/08/19
Descricao / Objetivo:   Impressão APONTAMENTO MÃO DE OBRA
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos
Uso......:              ZMNTR001
Obs......:              
=====================================================================================
*/
Static Function zImpQdr08()

	// Linha: OBSERVAÇÃO
	oPrint:Line( ( nLinIni )		,( nColIni )		,( nLinIni )		,( nColFim )		,	,"+1"	)
	oPrint:Line( ( nLinIni + 013 )	,( nColIni )		,( nLinIni + 013 )	,( nColFim )		,	,"+1"	)
	oPrint:SayAlign( ( nLinIni  )	,( nColIni )		,"APONTAMENTO DA MÃO DE OBRA"	,oFont12N	,( nColFim )	,( nLinIni )	,CLR_BLACK	,2	,2	)

	oPrint:Line( ( nLinIni + 026 )	,( nColIni )		,( nLinIni + 026 )	,( nColFim )		,	,"+1"	) // Linha 01 Tabela
	oPrint:Line( ( nLinIni + 046 )	,( nColIni )		,( nLinIni + 046 )	,( nColFim )		,	,"+1"	) // Linha 02 Tabela
	oPrint:Line( ( nLinIni + 066 )	,( nColIni )		,( nLinIni + 066 )	,( nColFim )		,	,"+1"	) // Linha 03 Tabela
	oPrint:Line( ( nLinIni + 086 )	,( nColIni )		,( nLinIni + 086 )	,( nColFim )		,	,"+1"	) // Linha 04 Tabela
	oPrint:Line( ( nLinIni + 106 )	,( nColIni )		,( nLinIni + 106 )	,( nColFim )		,	,"+1"	) // Linha 05 Tabela
	oPrint:Line( ( nLinIni + 126 )	,( nColIni )		,( nLinIni + 126 )	,( nColFim )		,	,"+1"	) // Linha 06 Tabela
	oPrint:Line( ( nLinIni + 146 )	,( nColIni )		,( nLinIni + 146 )	,( nColFim )		,	,"+1"	) // Linha 07 Tabela
	//oPrint:Line( ( nLinIni + 166 )	,( nColIni )		,( nLinIni + 166 )	,( nColFim )		,	,"-1"	) // Linha 08 Tabela
	//oPrint:Line( ( nLinIni + 186 )	,( nColIni )		,( nLinIni + 186 )	,( nColFim )		,	,"-1"	) // Linha 09 Tabela

	oPrint:Line( ( nLinIni + 016 )	,( 130 )			,( nLinIni + 146 )	,( 130 )			,	,"-1"	) // Coluna 02 Tabela
	oPrint:Line( ( nLinIni + 016 )	,( 262 )			,( nLinIni + 146 )	,( 262 )			,	,"-1"	) // Coluna 03 Tabela
	oPrint:Line( ( nLinIni + 016 )	,( 342 )			,( nLinIni + 146 )	,( 342 )			,	,"-1"	) // Coluna 04 Tabela
	oPrint:Line( ( nLinIni + 016 )	,( 422 )			,( nLinIni + 146 )	,( 422 )			,	,"-1"	) // Coluna 05 Tabela
	oPrint:Line( ( nLinIni + 016 )	,( 502 )			,( nLinIni + 146 )	,( 502 )			,	,"-1"	) // Coluna 06 Tabela

	oPrint:Say( ( nLinIni + 024  )	,( nColIni + 035 )	,"MATRÍCULA"															,oFont10n	)
	oPrint:Say( ( nLinIni + 024  )	,( nColIni + 158 )	,"EXECUTANTE"															,oFont10n	)
	oPrint:Say( ( nLinIni + 024  )	,( nColIni + 282 )	,"DATA"																	,oFont10n	)
	oPrint:Say( ( nLinIni + 024  )	,( nColIni + 350 )	,"HR.INICIAL"															,oFont10n	)
	oPrint:Say( ( nLinIni + 024  )	,( nColIni + 435 )	,"HR. FIM"																,oFont10n	)
	oPrint:Say( ( nLinIni + 024  )	,( nColIni + 505 )	,"STATUS SERV."															,oFont10n	)

	nLinIni :=  ( nLinIni + 146 ) // Ultima linha dessa seção
	nLinIni += 005 // Recuo para próxima impressão

Return(nLinIni)

/*
=====================================================================================
Programa.:              zImpRodape
Autor....:              CAOA - Evandro A M Santos
Data.....:              13/08/19
Descricao / Objetivo:   Impressão do Rodapé
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos
Uso......:              ZMNTR001
Obs......:              
=====================================================================================
*/
Static Function zImpRodape()

	nLinIni := nLinRodape

	oPrint:Line( ( nLinIni + 040 )	,( 215 )			,( nLinIni + 040 )	,( 391 )			,	,"-1"	) // Linha Assinatura

	oPrint:SayAlign( ( nLinIni + 043 )	,( nColIni )	,"ACEITE DO SERVIÇO"	,oFont08	,( nColFim )	,( nLinIni + 050 )	,CLR_BLACK	,2	,2	)

	oPrint:FillRect( { ( ( nLinIni + 081 ) - 009 )	,( nColIni )		,( ( nLinIni + 081 ) + 003 )	,( nColFim ) }	,oBrush	)

	oPrint:Line( ( nLinIni + 060 )	,( nColIni )		,( nLinIni + 060 )	,( nColFim )		,	,"+1"	)
	oPrint:Line( ( nLinIni + 072 )	,( nColIni )		,( nLinIni + 072 )	,( nColFim )		,	,"+1"	)

	oPrint:Line( ( nLinIni + 084 )	,( nColIni )		,( nLinIni + 084 )	,( nColFim )		,	,"+1"	)

	oPrint:SayAlign( ( nLinIni + 062 )	,( nColIni )	,'TIPO DE STATUS         | "C" - CONCLUÍDO    | "A" - EM ANDAMENTO | "R" - REPROGRAMADO | "F" - FALTA        | "CC" - CANCELADO   | '	,oFont08	,( nColFim)	,( nLinIni + 25 )	,CLR_BLACK	,2	,2	)

	oPrint:SayAlign( ( nLinIni + 074 )	,( nColIni )	,'"A segurança e a qualidade de vida de todos, dependem das ações seguras de cada um." USE SEMPRE EPIS' + "          | Emissão: " + DToC( Date() ) + " - " + Time() + " ( ZMNTR001 ) |"	,oFont08N	,( nColFim )	,( nLinIni + 074 )	,CLR_BLACK	,2	,2	)

	nLinIni := nLinIni + 120

Return(nLinIni)

/*
=====================================================================================
Programa.:              zImpRodape
Autor....:              CAOA - Evandro A M Santos
Data.....:              13/08/19
Descricao / Objetivo:   Impressão do Rodapé
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos
Uso......:              ZMNTR001
Obs......:              
=====================================================================================
*/
Static Function zImpAux()

	Local nLinIni := 015

	// Monta quadro superior
	// 				Lin Inicial	  , Col Inicial	, Lin Final			, Col Final	, Espesura.
	oPrint:Box( ( nLinIni + 015 )	,( nColIni )	,( nLinIni + 055 )	,( nColFim )	,"+1"	)

	//Logotipo
	oPrint:SayBitmap( ( nLinIni + 020 )	,( nColIni + 005 )	,cPictCabec	,075	,028	)

	//Titulo do relatório: ANÁLISE PRELIMINAR DE RISCOS
	oPrint:SayAlign( ( nLinIni + 028 )	,( nColIni )	,"ANÁLISE PRELIMINAR DE RISCOS"	,oFont16N	,( nColFim )	,( nLinIni + 25 )	,CLR_BLACK	,2	,2	)

	//Nome da Empresa
	nLa  := 32
	nLb  := 42
	nCoA := 449
	nCoB := 420
	//Nome da Empresa
	oPrint:Say( ( nLinIni + nLa )	,( nColIni + nCoA )	,PadC(Substr( AllTrim( cFilName ),1 ,At( " ",cFilName )-1 )                 ,30 ) ,oFont10N )
	oPrint:Say( ( nLinIni + nLb )	,( nColIni + nCoB )	,PadC(Substr( AllTrim( cFilName ),	At( " ",cFilName )+1 , Len( cFilName ) ),30 ) ,oFont10N )

	//oPrint:Say( (nLinIni + 032)	,(nColIni + 472)	,Substr( AllTrim( cFilName ),1	,At( " ",cFilName )-1)						,oFont18N	)
	//oPrint:Say( (nLinIni + 049)	,(nColIni + 482)	,Substr( AllTrim( cFilName ), 	At( " ",cFilName )+1 , LEN( cFilName ) )		,oFont18N	)

	oPrint:Say( (nLinIni + 062)	,(nColIni + 005)	,"PREPARANDO-SE PARA O TRABALHO:"											,oFont07n	)

	oPrint:Say( (nLinIni + 069)	,(nColIni + 005)	,"1 – Todo colaborador só pode executar atividades para as quais foi treinado "		+ ;
		"nos respectivos padrões operacionais e gerenciais referente à suas respectivas "	+ ;
		"áreas de atuação."															,oFont07	)

	oPrint:Say( (nLinIni + 076)	,(nColIni + 005)	,"2 – Todo colaborador deve ter sido treinado nos Riscos Críticos e Regras de "		+ ;
		"mandamento de segurança da Caoa Montadora de Veículos."					,oFont07	)

	oPrint:Say( (nLinIni + 083)	,(nColIni + 005)	,"3 – Todo colaborador de Manutenção só poderá iniciar suas atividades "			+ ;
		"mediante ordem de manutenção com esta análise pré-eliminar de riscos "				+ ;
		"preenchida obrigatoriamente."												,oFont07	)

	oPrint:Say( (nLinIni + 090)	,(nColIni + 005)	,"4 – Fica  sujeito a receber aplicação de penalidade conforme rege a Ordem "		+ ;
		"de Serviço – F0600700 o colaborador que infringir as observações acima."	,oFont07	)

	oPrint:Line( (nLinIni + 097)	,( nColIni )		,( nLinIni + 097 )	,( nColFim )		,	,"+1"	)

	oPrint:Say( (nLinIni + 104)	,(nColIni + 005)	,"ANTES DE INICIAR A ATIVIDADE:"											,oFont07n	)

	oPrint:Say( (nLinIni + 111)	,(nColIni + 005)	,"1 - Inspecione e providencie ferramentas e materiais necessários conforme "		+ ;
		"procedimento referente a cada atividade."									,oFont07	)

	oPrint:Say( (nLinIni + 118)	,(nColIni + 005)	,"2 – Garantir o estado de energia zero do equipamento conforme padrões."			+ ;
		"Utilizar os Epi’s indicados para cada atividade ou área de risco."			,oFont07	)

	oPrint:Say( (nLinIni + 125)	,(nColIni + 005)	,"3 – Identifique abaixo marcando um “X” nos riscos relacionados à "				+ ;
		"atividade e/ou área, tomando as ações preventivas indicadas "						+ ;
		"nas principais ações."														,oFont07	)

	oPrint:Line( (nLinIni + 132)	,( nColIni )		,(nLinIni + 132)	,( nColFim )		,	,"+1"	)

	oPrint:Say( (nLinIni + 142)	,(nColIni + 010)	,"MARQUE X"																	,oFont08n	)
	oPrint:Say( (nLinIni + 142)	,(nColIni + 105)	,"RISCOS"																	,oFont08n	)
	oPrint:Say( (nLinIni + 142)	,(nColIni + 186)	,"PADRÃO CORRESPONDENTE"													,oFont08n	)
	oPrint:Say( (nLinIni + 142)	,(nColIni + 370)	,"PRINCIPAIS AÇÕES PREVENTIVAS"												,oFont08n	)

	oPrint:Line( (nLinIni + 145)	,( nColIni )		,(nLinIni + 145)	,( nColFim )		,	,"+1"	)

	oPrint:Say( (nLinIni + 155)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															,oFont08n	)
	oPrint:Say( (nLinIni + 155)	,(nColIni + 062)	,"Trabalho em altura"														,oFont08	)
	oPrint:Say( (nLinIni + 155)	,(nColIni + 182)	,"OS - Integração - F0600700"												,oFont08	)
	oPrint:Say( (nLinIni + 155)	,(nColIni + 302)	,"Usar cinto de segurança. Usar capacete com jugular e isolar a área."		,oFont08	)

	oPrint:Line( (nLinIni + 161)	,( nColIni )		,(nLinIni + 161)	,( nColFim )		,	,"-1"	)

	oPrint:Say( (nLinIni + 171)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															,oFont08n	)
	oPrint:Say( (nLinIni + 171)	,(nColIni + 062)	,"Trabalho em espaço confinado"												,oFont08	)
	oPrint:Say( (nLinIni + 171)	,(nColIni + 182)	,"PET AC - F0603900"														,oFont08	)
	oPrint:Say( (nLinIni + 171)	,(nColIni + 302)	,"Emitir formulário de permissão de trabalho  e permissão de entrada,"		,oFont08	)
	oPrint:Say( (nLinIni + 179)	,(nColIni + 302)	,"solicitar medição de gases."												,oFont08	)

	oPrint:Line( (nLinIni + 185)	,( nColIni )		,(nLinIni + 185)	,( nColFim )		,	,"-1"	)

	//Sim/Não
	oPrint:Say( (nLinIni + 195)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															,oFont08n	)
	//Riscos
	oPrint:Say( (nLinIni + 195)	,(nColIni + 062)	,"Substancias químicas diversas e"											,oFont08	)
	oPrint:Say( (nLinIni + 203)	,(nColIni + 062)	,"perigosas como ácido sulfúrico,"											,oFont08	)
	oPrint:Say( (nLinIni + 211)	,(nColIni + 062)	,"ácido muriático, gases CO e CO2,"											,oFont08	)
	oPrint:Say( (nLinIni + 219)	,(nColIni + 062)	,"solução amoniacal entre outros."											,oFont08	)
	// Padrão Correspondente
	oPrint:Say( (nLinIni + 195)	,(nColIni + 182)	,"POP - 06101XX"															,oFont08	)
	oPrint:Say( (nLinIni + 203)	,(nColIni + 182)	,"POP - 0655XX"																,oFont08	)

	oPrint:Say( (nLinIni + 195)	,(nColIni + 302)	,"Usar EPI’s específicos como luvas, bota de PVC e conjunto impermeável,"	,oFont08	)
	oPrint:Say( (nLinIni + 203)	,(nColIni + 302)	,"proteção respiratoria contra gases observando se o tipo do filtro é compatível",oFont08	)
	oPrint:Say( (nLinIni + 211)	,(nColIni + 302)	,"com o gás exposto. Evitar derramamentos ou emissões e seguir as recomendações",oFont08	)
	oPrint:Say( (nLinIni + 219)	,(nColIni + 302)	,"descritas na FISPQ do produto utilizado realizar o descarte adequadamente.",oFont08	)

	oPrint:Line( (nLinIni + 225)	,( nColIni )		,(nLinIni + 225)	,( nColFim )		,	,"-1"	)

	// Sim/Não
	oPrint:Say( (nLinIni + 235)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															,oFont08n	)
	// Riscos
	oPrint:Say( (nLinIni + 235)	,(nColIni + 062)	,"Equipamento que pode ser"													,oFont08	)
	oPrint:Say( (nLinIni + 243)	,(nColIni + 062)	,"acionado a distância."													,oFont08	)
	// Principais Ações Preventivas
	oPrint:Say( (nLinIni + 235)	,(nColIni + 302)	,"Fazer bloqueio e etiquetagem."											,oFont08	)

	// Linha de separação
	oPrint:Line( (nLinIni + 249)	,( nColIni )		,(nLinIni + 249)	,( nColFim )		,	,"-1"	)

	// Sim/Não
	oPrint:Say( (nLinIni + 259)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															,oFont08n	)
	// Riscos
	oPrint:Say( (nLinIni + 259)	,(nColIni + 062)	,"Trabalhos a quente "														,oFont08	)
	oPrint:Say( (nLinIni + 267)	,(nColIni + 062)	,"(Maçarico e solda.)"														,oFont08	)
	// Padrão Correspondente
	oPrint:Say( (nLinIni + 259)	,(nColIni + 182)	,"POP - 060300"																,oFont08	)
	// Principais Ações Preventivas
	oPrint:Say( (nLinIni + 259)	,(nColIni + 302)	,"Medir limite de explosividade no local, usar roupas de raspa ou vaqueta"	,oFont08	)
	oPrint:Say( (nLinIni + 267)	,(nColIni + 302)	,"(luva, avental, mangote e perneira) somente utilizar máquina de solda"	,oFont08	)
	oPrint:Say( (nLinIni + 275)	,(nColIni + 302)	,"e conjunto oxi-acetileno que estiver inspecionado."						,oFont08	)

	oPrint:Line( (nLinIni + 281)	,( nColIni )		,(nLinIni + 281)	,( nColFim )		,	,"-1"	)

	// Sim/Não
	oPrint:Say( (nLinIni + 291)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															,oFont08n	)
	// Riscos
	oPrint:Say( (nLinIni + 291)	,(nColIni + 062)	,"Equipamentos/Instalações"													,oFont08	)
	oPrint:Say( (nLinIni + 299)	,(nColIni + 062)	,"Elétricas."																,oFont08	)
	// Padrão Correspondente
	oPrint:Say( (nLinIni + 291)	,(nColIni + 182)	,"POP - 060500"																,oFont08	)
	// Principais Ações Preventivas
	oPrint:Say( (nLinIni + 291)	,(nColIni + 302)	,"Utilizar EPI’s especiais e estarem atento as normas da NR – 10"			,oFont08	)

	oPrint:Line( (nLinIni + 305)	,( nColIni )		,(nLinIni + 305)	,( nColFim )		,	,"-1"	)

	// Sim/Não
	oPrint:Say( (nLinIni + 315)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															,oFont08n	)
	// Riscos
	oPrint:Say( (nLinIni + 315)	,(nColIni + 062)	,"Cargas suspensas/Içamento."												,oFont08	)
	// Principais Ações Preventivas
	oPrint:Say( (nLinIni + 315)	,(nColIni + 302)	,"Só usar cintas e talhas inspecionadas (lacres coloridos), verificar"		,oFont08	)
	oPrint:Say( (nLinIni + 323)	,(nColIni + 302)	,"capacidade de peso e isolar a área."										,oFont08	)

	oPrint:Line( (nLinIni + 329)	,( nColIni )		,(nLinIni + 329)	,( nColFim )		,	,"-1"	)

	// Sim/Não
	oPrint:Say( (nLinIni + 339)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															,oFont08n	)
	// Riscos
	oPrint:Say( (nLinIni + 339)	,(nColIni + 062)	,"Movimentação manual de peso"												,oFont08	)
	// Principais Ações Preventivas
	oPrint:Say( (nLinIni + 339)	,(nColIni + 302)	,"Levantar peso observando as recomendações de ergonomia."					,oFont08	)

	oPrint:Line( (nLinIni + 345)	,( nColIni )		,(nLinIni + 345)	,( nColFim )		,	,"-1"	)

	// Sim/Não
	oPrint:Say( (nLinIni + 355)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															,oFont08n	)
	// Riscos
	oPrint:Say( (nLinIni + 355)	,(nColIni + 062)	,"Serviço em sistemas"														,oFont08	)
	oPrint:Say( (nLinIni + 363)	,(nColIni + 062)	,"pressurizados."															,oFont08	)
	// Principais Ações Preventivas
	oPrint:Say( (nLinIni + 355)	,(nColIni + 302)	,"Aguardar liberação da operação e fazer os bloqueios necessários."			,oFont08	)

	oPrint:Line( (nLinIni + 369)	,( nColIni )		,(nLinIni + 369)	,( nColFim )		,	,"-1"	)

	// Sim/Não
	oPrint:Say( (nLinIni + 379)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															,oFont08n	)
	// Riscos
	oPrint:Say( (nLinIni + 379)	,(nColIni + 062)	,"Veículos leves e"															,oFont08	)
	oPrint:Say( (nLinIni + 387)	,(nColIni + 062)	,"equipamentos móveis."														,oFont08	)
	// Padrão Correspondente
	oPrint:Say( (nLinIni + 379)	,(nColIni + 182)	,"POP - 060600"																,oFont08	)
	// Principais Ações Preventivas
	oPrint:Say( (nLinIni + 379)	,(nColIni + 302)	,"Só opere veículos e equipamentos móveis que você é autorizado."			,oFont08	)
	oPrint:Say( (nLinIni + 387)	,(nColIni + 302)	,"Verifique se o veículo / equipamento está em boas condições sem"			,oFont08	)
	oPrint:Say( (nLinIni + 395)	,(nColIni + 302)	,"vazamentos diversos."														,oFont08	)

	oPrint:Line( (nLinIni + 401)	,( nColIni )		,(nLinIni + 401)	,( nColFim )		,	,"-1"	)

	// Sim/Não
	oPrint:Say( (nLinIni + 411)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															, oFont08n	)
	// Riscos
	oPrint:Say( (nLinIni + 411)	,(nColIni + 062)	,"Ferramentas manuais"														,oFont08	)
	// Padrão Correspondente
	oPrint:Say( (nLinIni + 411)	,(nColIni + 182)	,"OS - Integração - F0600700"												,oFont08	)
	// Principais Ações Preventivas
	oPrint:Say( (nLinIni + 411)	,(nColIni + 302)	,"Somente utilize ferramentas em perfeito estado de conservação e que"		,oFont08	)
	oPrint:Say( (nLinIni + 419)	,(nColIni + 302)	,"estejam no sistema formal de inspeção. Não improvise ferramentas."		,oFont08	)

	oPrint:Line( (nLinIni + 425)	,( nColIni )		,(nLinIni + 425)	,( nColFim )		,	,"-1"	)

	// Sim/Não
	oPrint:Say( (nLinIni + 435)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															,oFont08n	)
	// Riscos
	oPrint:Say( (nLinIni + 435)	,(nColIni + 062)	,"Ruído."																	,oFont08	)
	// Padrão Correspondente
	oPrint:Say( (nLinIni + 435)	,(nColIni + 182)	,"OS - Integração - F0600700"												,oFont08	)
	// Principais Ações Preventivas
	oPrint:Say( (nLinIni + 435)	,(nColIni + 302)	,"Usar protetor auricular."													,oFont08	)

	oPrint:Line( (nLinIni + 441)	,( nColIni )		,(nLinIni + 441)	,( nColFim )		,	,"-1"	)

	// Sim/Não
	oPrint:Say( (nLinIni + 451)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															,oFont08n	)
	// Riscos
	oPrint:Say( (nLinIni + 451)	,(nColIni + 062)	,"Emanação de gás."															,oFont08	)
	// Padrão Correspondente
	oPrint:Say( (nLinIni + 451)	,(nColIni + 182)	,"PET - F0604000"															,oFont08	)
	// Principais Ações Preventivas
	oPrint:Say( (nLinIni + 451)	,(nColIni + 302)	,"Portar e usar máscara respiratória."										,oFont08	)

	oPrint:Line( (nLinIni + 457)	,( nColIni )		,(nLinIni + 457)	,( nColFim )		,	,"-1"	)

	// Sim/Não
	oPrint:Say( (nLinIni + 467)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															,oFont08n	)
	// Riscos
	oPrint:Say( (nLinIni + 467)	,(nColIni + 062)	,"Pó em suspensão"															,oFont08	)
	oPrint:Say( (nLinIni + 475)	,(nColIni + 062)	,"(partículas de qualquer natureza,"										,oFont08	)
	oPrint:Say( (nLinIni + 483)	,(nColIni + 062)	,"podem ser explosivas.)"													,oFont08	)
	// Principais Ações Preventivas
	oPrint:Say( (nLinIni + 467)	,(nColIni + 302)	,"Portar e usar máscara descartável apropriada e realizar em local"							,oFont08	)
	oPrint:Say( (nLinIni + 475)	,(nColIni + 302)	,"adequado para evitar a contaminação ambiental."							,oFont08	)

	oPrint:Line( (nLinIni + 489)	,( nColIni )		,(nLinIni + 489)	,( nColFim )		,	,"-1"	)

	// Sim/Não
	oPrint:Say( (nLinIni + 499)	,(nColIni + 004)	,"SIM(  ) NÃO(  )"															,oFont08n	)
	// Riscos
	oPrint:Say( (nLinIni + 499)	,(nColIni + 062)	,"Óleo, graxa (Lubrificante.)"												,oFont08	)
	// Padrão Correspondente
	oPrint:Say( (nLinIni + 499)	,(nColIni + 182)	,"POP - 06101XX"															,oFont08	)
	oPrint:Say( (nLinIni + 507)	,(nColIni + 182)	,"POP - 0655XX"																,oFont08	)
	// Principais Ações Preventivas
	oPrint:Say( (nLinIni + 499)	,(nColIni + 302)	,"Usar luvas de PVC ou látex nitrílicas para proteção contra graxa e"		,oFont08	)
	oPrint:Say( (nLinIni + 507)	,(nColIni + 302)	,"solvente, creme protetor de pele para proteção contra graxas e solventes.",oFont08	)
	oPrint:Say( (nLinIni + 515)	,(nColIni + 302)	,"Evitar derramamentos e seguir as recomendações descritas na FISPQ do"		,oFont08	)
	oPrint:Say( (nLinIni + 523)	,(nColIni + 302)	,"produto utilizado e realizar o descarte adequadamente."					,oFont08	)

	oPrint:Line( (nLinIni + 533)	,( nColIni )		,(nLinIni + 533)	,( nColFim )		,	,"+1"	)

	oPrint:Line( (nLinIni + 543)	,( nColIni )		,(nLinIni + 543)	,( nColFim )		,	,"+1"	)

	oPrint:Line( (nLinIni + 132)	,(nColIni + 060)	,(nLinIni + 533)	,(nColIni + 060)	,	,"+1"	)
	oPrint:Line( (nLinIni + 132)	,(nColIni + 180)	,(nLinIni + 533)	,(nColIni + 180)	,	,"+1"	)
	oPrint:Line( (nLinIni + 132)	,(nColIni + 300)	,(nLinIni + 533)	,(nColIni + 300)	,	,"+1"	)

	oPrint:Line( (nLinIni + 560)	,( nColIni )		,(nLinIni + 560)	,( nColFim )		,	,"+1"	)

	oPrint:Line( (nLinIni + 575)	,( nColIni )		,(nLinIni + 575)	,( nColFim )		,	,"+1"	)

	oPrint:Say( (nLinIni + 555)	,(nColIni + 080)	,"OUTROS RISCOS NÃO PREVISTOS"												,oFont08n	)
	oPrint:Say( (nLinIni + 555)	,(nColIni + 270)	,"TRABALHOS DE RISCOS NOS SECADORES"										,oFont08n	)
	oPrint:Say( (nLinIni + 555)	,(nColIni + 478)	,"RISCOS CRÍTICOS"															,oFont08n	)

	oPrint:Say( (nLinIni + 570)	,(nColIni + 085)	,"Durante a execução de atividade"											,oFont08n	)
	oPrint:Say( (nLinIni + 570)	,(nColIni + 295)	,"Observação do risco no Trabalho"											,oFont08n	)
	oPrint:Say( (nLinIni + 570)	,(nColIni + 488)	,"Bloqueio"																	,oFont08n	)

	oPrint:Say( (nLinIni + 585)	,(nColIni + 004)	,"1-Manter a área limpa e organizada; 2-Destine corretamente os"			,oFont08	)
	oPrint:Say( (nLinIni + 593)	,(nColIni + 004)	,"resíduos gerados (coleta seletiva); 3-Relate as não conformidades;"		,oFont08	)
	oPrint:Say( (nLinIni + 601)	,(nColIni + 004)	,"4-Tenha comportamentos seguros e prevencionista."							,oFont08	)

	oPrint:Line( (nLinIni + 606)	,( nColIni )		,(nLinIni + 606)	,(nColIni + 250)	,	,"-1"	)

	oPrint:Say( (nLinIni + 616)	,(nColIni + 004)	,"Em caso de atividade não rotineira e / ou que envolva terceiros,"			,oFont08	)
	oPrint:Say( (nLinIni + 624)	,(nColIni + 004)	,"é necessário fazer analise de risco."										,oFont08	)

	oPrint:Line( (nLinIni + 629)	,( nColIni )		,(nLinIni + 629)	,(nColIni + 250)	,	,"-1"	)

	oPrint:Say( (nLinIni + 639)	,(nColIni + 004)	,"Data: _______ /_______ /_______    Hora: _______:_______"					,oFont08	)
	oPrint:Say( (nLinIni + 654)	,(nColIni + 004)	,"Assinatura do Executante: ______________________________"					,oFont08	)

	oPrint:Line( (nLinIni + 659)	,( nColIni )		,(nLinIni + 659)	,(nColIni + 250)	,	,"-1"	)

	oPrint:Say( (nLinIni + 669)	,(nColIni + 004)	,"Bloqueio de Energia"														,oFont08n	)
	oPrint:Say( (nLinIni + 684)	,(nColIni + 004)	,"Data: _______ /_______ /_______    Hora: _______:_______"					,oFont08	)
	oPrint:Say( (nLinIni + 699)	,(nColIni + 004)	,"Tempo previsto: ____________ Segurança do Trabalho: ____________"			,oFont08	)
	oPrint:Say( (nLinIni + 714)	,(nColIni + 004)	,"Manutenção: ____________"													,oFont08	)

	oPrint:Line( (nLinIni + 719)	,( nColIni )		,(nLinIni + 719)	,(nColIni + 250)	,	,"-1"	)

	oPrint:Say( (nLinIni + 729)	,(nColIni + 004)	,"Desbloqueio de Energia"													,oFont08n	)
	oPrint:Say( (nLinIni + 744)	,(nColIni + 004)	,"Data: _______ /_______ /_______    Hora: _______:_______"					,oFont08	)
	oPrint:Say( (nLinIni + 759)	,(nColIni + 004)	,"Tempo previsto: ____________ Segurança do Trabalho: ____________"			,oFont08	)
	oPrint:Say( (nLinIni + 774)	,(nColIni + 004)	,"Manutenção: ____________"													,oFont08	)

	oPrint:Say( (nLinIni + 616)	,(nColIni + 254)	,"Observação do risco no Trabalho"											,oFont08n	)
	oPrint:Say( (nLinIni + 634)	,(nColIni + 254)	,"Ferramenta que consiste na observação de"									,oFont08	)
	oPrint:Say( (nLinIni + 642)	,(nColIni + 254)	,"uma tarefa sendo executada com o"											,oFont08	)
	oPrint:Say( (nLinIni + 650)	,(nColIni + 254)	,"objetivo de identificar desvios de"										,oFont08	)
	oPrint:Say( (nLinIni + 658)	,(nColIni + 254)	,"comportamento de segurança, sendo os"										,oFont08	)
	oPrint:Say( (nLinIni + 666)	,(nColIni + 254)	,"mesmos corrigidos de imediato. Tem"										,oFont08	)
	oPrint:Say( (nLinIni + 674)	,(nColIni + 254)	,"propriedade preventiva, pois atuando nos"									,oFont08	)
	oPrint:Say( (nLinIni + 682)	,(nColIni + 254)	,"desvios comportamentais evita-se que"										,oFont08	)
	oPrint:Say( (nLinIni + 690)	,(nColIni + 254)	,"estes venham a se transformar em"											,oFont08	)
	oPrint:Say( (nLinIni + 698)	,(nColIni + 254)	,"incidentes, acidentes ou sinistros de"									,oFont08	)
	oPrint:Say( (nLinIni + 706)	,(nColIni + 254)	,"grande monta."															,oFont08	)

	oPrint:Say( (nLinIni + 616)	,(nColIni + 454)	,"Espaço Confinado"															,oFont08	)
	oPrint:Say( (nLinIni + 624)	,(nColIni + 454)	,"Instalações Elétricas"													,oFont08	)
	oPrint:Say( (nLinIni + 632)	,(nColIni + 454)	,"Proteção de Máquinas"														,oFont08	)
	oPrint:Say( (nLinIni + 640)	,(nColIni + 454)	,"Veículos Leves e Equip. Móveis"											,oFont08	)
	oPrint:Say( (nLinIni + 648)	,(nColIni + 454)	,"Substancias Perigosas"													,oFont08	)
	oPrint:Say( (nLinIni + 656)	,(nColIni + 454)	,"Ferramentas Manuais"														,oFont08	)
	oPrint:Say( (nLinIni + 664)	,(nColIni + 454)	,"Gases Pressurizados"														,oFont08	)
	oPrint:Say( (nLinIni + 672)	,(nColIni + 454)	,"Animais Peçonhentos"														,oFont08	)
	oPrint:Say( (nLinIni + 680)	,(nColIni + 454)	,"Trabalho em Altura"														,oFont08	)

	oPrint:Line( (nLinIni + 779)	,( nColIni )		,(nLinIni + 779)	,(nColFim)			,	,"+1"	)

	oPrint:Say(	(nLinIni + 795)	,(nColIni+020)	,'“Obrigatório o preenchimento da análise preliminar de riscos antes da execução das atividades relacionadas na OS”'	, oFont12N	)
	oPrint:Say( (nLinIni + 805)	,(nColIni+450)	,"| Emissão: " + DToC( Date() ) + " - " + Time() + " ( ZMNTR001 ) |"			, oFont07n	)

	oPrint:Line( (nLinIni + 543)	,(nColIni + 250)	,(nLinIni + 779)	,(nColIni + 250)	,	,"+1"	)
	oPrint:Line( (nLinIni + 543)	,(nColIni + 450)	,(nLinIni + 779)	,(nColIni + 450)	,	,"+1"	)

Return()

/*
=====================================================================================
Function.:              ZMNTCONV
Autor....:              CAOA - Evandro A M Santos
Data.....:              13/08/19
Descricao / Objetivo:   Conversão Quantidade Ord. de Serviço.
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos
Uso......:              ZMNTR001
Obs......:              
=====================================================================================
*/
Static Function ZMNTConv(nQtde, cTipoHr)

	Local cNgUnidt := AllTrim( GetNewPar( "MV_NGUNIDT" ) )
	Local nRetHr   := 0.0

	If cTipoHr != cNgUnidt
		nRetHr := NGCONVERHORA( nQtde	,cTipoHr	,cNgUnidt	)
	Else
		nRetHr := nQtde
	EndIf

Return(nRetHr)

/*
=====================================================================================
Programa.:              ZMNTCONV
Autor....:              CAOA - Valter Carvalho
Data.....:              13/08/19
Descricao / Objetivo:   Verifica se um bem está na Arvore TAF
Doc. Origem:            GAP_MNT001
Solicitante:            CAOA - Montadora de Veiculos, Julia 
Uso......:              ZMNTR001
Obs......:              
=====================================================================================

Static Function ZMNTBINT(cCodCon)
	Local cmd 
	Local lRes

	cmd :=	" SELECT * FROM " + RetSqlName("TAF") + " TAF WHERE TAF.TAF_CODCON = '" + cCodCon + "' AND D_E_L_E_T_ = ' ' "
	TcQuery cmd New Alias "ZZZ"

	lRes := (Vazio(ZZZ->TAF_CODCON) = .F.)

	ZZZ->(DbCloseArea())
return lRes
*/
