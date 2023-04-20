#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_SPOOL 2

#DEFINE VBOX      080
#DEFINE HMARGEM   030
#DEFINE MAXBOXH   860 //800 // Tamanho maximo do box Horizontal
#DEFINE MAXBOXV   600
#DEFINE INIBOXH   010

#DEFINE ALIGNLEFT 000 // ALINHAMENTO A ESQUERDA
#DEFINE ALIGRIGHT 001 // ALINHAMENTO A DIREITA
#DEFINE ALIGNCENT 002 // ALINHAMENTO CENTRALIZADO

#DEFINE VALIGCENT 000 // ALINHAMENTO MEIO / CENTRALIZADO
#DEFINE VALIGSUP  001 // ALINHAMENTO SUPERIOR
#DEFINE VALIGBOT  002 // ALINHAMENTO INFERIOR

#DEFINE TYPE_BOX  "BOX"
#DEFINE TYPE_TXT  "TEXTALIGN"
#DEFINE TYPE_SAY  "SAY"
#DEFINE TYPE_IMG  "IMAGE"
#DEFINE TYPE_LIN  "LINE"
#DEFINE PAGE_END  "PAGE_END"
#DEFINE ATT_NAME  001
#DEFINE ATT_TYPE  002
#DEFINE ATT_TEXT  003
#DEFINE ATT_POSV  004
#DEFINE ATT_POSH  005
#DEFINE ATT_FONT  006
#DEFINE ATT_TAMH  007
#DEFINE ATT_TAMV  008
#DEFINE ATT_CLRT  009
#DEFINE ATT_ALGH  010
#DEFINE ATT_ALGV  011
#DEFINE ATT_GIRO  012
#DEFINE ATT_PAGE  013

#DEFINE DOCSPEC   "F0764701"

/** MATA120.PRX ** A120Refresh(aValores) **/
#DEFINE VALMERC   001  // Valor total do mercadoria
#DEFINE VALDESC   002  // Valor total do desconto
#DEFINE FRETE     003  // Valor total do Frete
#DEFINE VALDESP   004  // Valor total da despesa
#DEFINE TOTF1     005  // Total de Despesas Folder 1
#DEFINE TOTPED    006  // Total do Pedido
#DEFINE SEGURO    007  // Valor total do seguro
#DEFINE TOTF3     008  // Total utilizado no Folder 3
#DEFINE IMPOSTOS  009  // Array contendo Os Valores de Impostos Exibidos no ListBox
#DEFINE NTRIB     010 // Valor das despesas nao tributadas - Portugal
#DEFINE TARA      011 // Valor da Tara - Portugal

#DEFINE MB_YESNO         004
#DEFINE MB_ICONQUESTION  032
#DEFINE IDYES            006
#DEFINE IDNO             007

/*
=====================================================================================
Programa.:              ZCOMR001
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Descricao / Objetivo:   Relatorio - Pedido de Compra
Doc. Origem:            GAP_COM007 - Customizar impressão do PC conforme layout da
						ISO enviado. O layout considerado deve ser o do SAP.
Solicitante:            CAOA
Uso......:              Pedido de Compra > Browse > Outras Acoes > Impr.PC.CAOA
Obs......:              Modelo especifico. Padrao CAOA. Modelo atual SAP
=====================================================================================
*/
USER FUNCTION ZCOMR001(	cAlias, nReg, nOpcx, oReport, oSetup, lIsLoja, lServer, aEmails )
	LOCAL aArea     := GetArea()
	LOCAL lEnd		:= .T.
	LOCAL cFilePrt  := SubStr(ProcName(),3)

	LOCAL nRet
	LOCAL lSendMail
	LOCAL lCpyErr
	LOCAL lAdjustToLegacy := .F.
	LOCAL lDisableSetup   := .T.
	// LOCAL lTReport        := .F.
	// LOCAL lPDFAsPNG       := .T. // PROTEGER CONTEUDO
	// LOCAL cPathPDF        := "C:\Projetos"
	LOCAL aDest        := {}
	Local i            := 0

	DEFAULT lServer    := .F.
	PRIVATE PixelX
	PRIVATE PixelY

	PRIVATE cNumPc
	PRIVATE aElements
	PRIVATE lAuto      := (nReg!=NIL)
	PRIVATE aColsMail  := {} //-- aCols RETORNA COM DADOS DO GRID DO PEDIDO

	PRIVATE cPictCabec := "LGRL" + FWGrpCompany() + ".BMP"
	
	PRIVATE cAliasSC1  := GetNextAlias()
	PRIVATE cAliasSC7  := GetNextAlias()
	PRIVATE cAliasSZV  := GetNextAlias()

	//Private cPathInServer   := IIF( ValType(aEmails) <> "U", GetTempPath(), "" )
	PRIVATE cPathInServer   := SuperGetMV( "CMV_COM002" ,,"\spool\")  //Local de armazenamento do arquivo pdf - \Cons_Compras\ 

	DEFAULT cAlias     	:= "SC7"
	DEFAULT aEmails		:= {}

	/** =================================================================== **/
	/** ==================== MARCA D'AGUA DE IMPRESSAO ==================== **/
	/** =================================================================== **/
	/** = OBRIGATORIO IMAGEM EXTENSAO .BMP                                = **/
	/** = =>> IMAGEM marca-dagua-rascunho PNG COM EXTENSAO BMP            = **/
	/** = =>> TEXTO: FONTE "Londrina Outline"                             = **/
	/** = =>> IMAGEM GERADA VIA Sketchpad - https://sketch.io/sketchpad/  = **/
	/** =================================================================== **/
	DEFAULT cPictMarca := "/templates/compras/marca-dagua-rascunho.bmp"
	DEFAULT lMarcaImpr := File(cPictMarca) // ARQUIVO MARCA D'AGUA EXISTE PARA IMPRESSAO
	PRIVATE lRascunho  := (lMarcaImpr .AND. "RASCUNHO" $ Upper(cPictMarca))
	
	If !ExistDir(cPathInServer)
	   MakeDir(cPathInServer)
	EndIf

	/** =================================================================================================================================== **/
	/** = Confere existencia da rotina para envio de emails, caso contrario nao apresenta opcao de envio                                    **/
	/** =================================================================================================================================== **/
	If !Empty(cPathInServer)
		lSendMail  := .T.	
	ElseIf FindFunction("U_ZGENMAIL")
		nRet := MESSAGEBOX( "Enviar Pedido de Compra gerado por e-mail?", "", MB_ICONQUESTION+MB_YESNO )
		If nRet == IDYES
			lSendMail := .T.
		ElseIf nRet == IDNO
			lSendMail := .F.
		EndIf
	Else
		lSendMail  := .F.
	EndIf


	If Alltrim(Funname()) = "MATA121"
		lAuto  := .T.
		cAlias := "SC7"
		nReg   := SC7->(RECNO())
		nOpcx  := 1
	Endif

	If Select(cAlias) == 0
		DBSelectArea(cAlias)
	EndIf
	cNumPc := (cAlias)->C7_NUM

	cNumPc := PadL("0",TamSX3("C7_NUM")[1],"0")
	If !Empty(cNumPc)
		cNumPc   := (cAlias)->C7_NUM
		cFilePrt := "PC_" + AllTrim(cNumPc) + "_" + strtran(time(),":","")
		cFilePrt := cFilePrt + IIF(lRascunho,"_RASCUNHO","")
		// cFilePrt := cFilePrt + "_" + DtoS(Date())
		// cFilePrt := cFilePrt + "_" + SubStr( Time(), 1, 2 ) + SubStr( Time(), 4, 2 )
	EndIf

	/** =================================================================================================================================== **/
	/** = Inicializacao do objeto grafico                                                                                                   **/
	/** =================================================================================================================================== **/
	If Type("oReport") == "U" //NIL
		If !Empty(cPathInServer)
			lViewPDF := .F.
		Else
			lViewPDF := .T.
		EndIf

		oReport  := FWMSPrinter():New(cFilePrt, IMP_PDF, lAdjustToLegacy, cPathInServer, lDisableSetup, ,,, .T. ,,, lViewPDF)

		oReport:SetResolution(78) //-- FwMsPrinter : SetResolution - Atualmente a versão da Totvsprinter somente trabalha com o valor fixo de 72. #TODO VERIFICAR
		oReport:SetLandscape()
		oReport:SetPaperSize(DMPAPER_A4)
		oReport:SetMargin(60,60,60,60)
		// nEsquerda, nSuperior, nDireita, nInferior
		oReport:cPathPDF := IIF( !Empty(cPathInServer), cPathInServer, "C:\\spool\\" ) // "c:\projetos\"

		// ----------------------------------------------
		// Salva impressora selecionada
		// ----------------------------------------------
		// fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
	EndIf

	PixelX := oReport:nLogPixelX()
	PixelY := oReport:nLogPixelY()

	// GERAR DADOS PARA IMPRESSAO
	If !Empty(cPathInServer)
		REPORTProc(@oReport, @aElements, .F., cNumPc, lIsLoja)
	Else
		RptStatus( {|lEnd| REPORTProc(@oReport, @aElements, @lEnd, cNumPc, lIsLoja)}, "Gerando Pedido de Compras..." )
	EndIf

	MS_Flush()

	If !Empty(cPathInServer)
		oReport:Print()
	Else
		If oReport:GetViewPDF()
			oReport:Preview()	// VISUALIZAR DOCUMENTO GERADO
		EndIf
	EndIf

	If lSendMail .And. File(oReport:cPathPDF + cFilePrt + ".pdf")
		
		If !Empty(cPathInServer)

       	    If Alltrim(Funname()) <> "MATA094" .AND. !FWIsInCallStack("POST")

			   lRet := DlgSendMail(aElements, @aColsMail)

				If lRet .And. Len(aColsMail) > 0 

					For i := 1 To Len(aColsMail)
						If !aColsMail[i][4] .And. !Empty(aColsMail[i][3]) ;
							.AND. AScan(aDest,{|cMail| cMail == AllTrim(aColsMail[i][3]) }) < 1
							Aadd(aDest, AllTrim(aColsMail[i][3]))
						EndIf
					Next i

					//RptSendMail(aElements, aEmails, ( cPathInServer + cFilePrt + ".pdf") )
					RptSendMail(aElements, aDest, ( cPathInServer + cFilePrt + ".pdf") )

				Endif

            Else

                lRet := DlgSendMa(aElements, @aColsMail)
				
				If  Len(aColsMail) > 0 

					For i := 1 To Len(aColsMail)
						If !aColsMail[i][4] .And. !Empty(aColsMail[i][3]) ;
							.AND. AScan(aDest,{|cMail| cMail == AllTrim(aColsMail[i][3]) }) < 1
							Aadd(aDest, AllTrim(aColsMail[i][3]))
						EndIf
					Next i

					RptSendMail(aElements, aDest, ( cPathInServer + cFilePrt + ".pdf") )

				Endif
				

            Endif


		Else
			
			lRet := DlgSendMail(aElements, @aColsMail)

			If lRet .And. Len(aColsMail) > 0 .And. Len(aColsMail[1]) == 4
				For i := 1 To Len(aColsMail)
					If !aColsMail[i][4] .And. !Empty(aColsMail[i][3]) ;
						.AND. AScan(aDest,{|cMail| cMail == AllTrim(aColsMail[i][3]) }) < 1
						Aadd(aDest, AllTrim(aColsMail[i][3]))
					EndIf
				Next i
		
				If !ExistDir("\spool\")
					MakeDir("\spool\")
				EndIf

				lCpyErr := CpyT2S( oReport:cPathPDF+cFilePrt + ".pdf", "\spool\" )
				If !lCpyErr
					MESSAGEBOX( "Erro ao copiar arquivo (Client -> Server).", "Falha na cópia do arquivo", MB_OK )
				Else
					RptSendMail(aElements, aDest, ("\spool\" + cFilePrt + ".pdf") )

					// REMOVER ARQUIVO DO SERVIDOR APOS TENTATIVA / ENVIO REALIZADO
					FErase("\spool\" + cFilePrt + ".pdf") // RETORNO = 0 EXCLUSAO REALIZADA COM SUCESSO
					FErase("\spool\" + cFilePrt + ".rel") // RETORNO = -1 EXCLUSAO NAO REALIZADA, ARQUIVO NAO ENCONTRADO
				EndIf
			EndIf

		EndIf

	EndIf

	FreeObj(aElements)
	aElements := NIL

	FreeObj(oReport)
	oReport := NIL
	
	If Select((cAliasSC7)) > 0
		(cAliasSC7)->(DBCloseArea())
	EndIf
	If Select((cAliasSZV)) > 0
		(cAliasSZV)->(DBCloseArea())
	EndIf

	RestArea(aArea)
RETURN()


/*
=====================================================================================
Programa.:              REPORTProc
-------------------------------------------------------------------------------------
Parametros:             Arg01 - Objeto grafico de impressao (FwTReport)
						ArgA2 - Elementos para impressao, imagem, campos e valores
						ArgL3 - Controle de impressao, cancelamento
						ArgC4 - Numero do Pedido de Compra
                        ArgL5 - 
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
=====================================================================================
*/
STATIC FUNCTION REPORTProc(	oReport	, aElements, lEnd , cNumPc , lIsLoja )
	LOCAL aArea      := GetArea()
	LOCAL aAreaSC7   := SC7->(GetArea())

	LOCAL cCampos 	 := "" //C7_XDESCL1,C7_XDESCL2" /* CAMPOS ESPECIFICOS */
	LOCAL aCampos	 := StrToArray(cCampos,",")

	LOCAL cOrigem    := "PC"
	// LOCAL cNumero    := cNumPC
		
	DEFAULT lIsLoja	   := .F.

	If lEnd
		RETURN(.F.)
	EndIf

	// TOTAL DE SECOES DO TEMPLATE DO RELATORIO
	If Empty(cPathInServer)
		SetRegua( 8 )
	EndIf

	/** =================================================================================================================================== **/
	/** = Campos que serao adicionados a query somente se existirem na base                                                                 **/
	/** =================================================================================================================================== **/
	/* VALIDA EXISTENCIA DE CAMPOS ESPECIFICO / USUARIO     */
	/* TESTAR CAMPOS CUSTOMIZADOS ANTES DE ADCIONAR A QUERY */
	cCampos := ""
	AScan(aCampos, {|userField| cCampos := cCampos + IIF(SC7->(FieldPos(userField))>0,userField+",","") })


	If Empty(cCampos)
		cCampos := "%%"
	Endif

	If Select((cAliasSC7)) > 0
		(cAliasSC7)->(DbCloseArea())
	EndIf

	/* ORACLE :: CAMPOS MEMO DEVE SER ULTIMO DA LISTA DE CAMPOS SELECT */
	//-- SELECT - PEDIDO DE COMPRA (SC7)
	BeginSQL Alias cAliasSC7

		COLUMN C7_EMISSAO  AS DATE
		COLUMN C7_DATPRF   AS DATE

		SELECT C7_FILIAL, C7_NUM, C7_EMISSAO, C7_FORNECE, C7_LOJA,
			C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_QUANT, C7_UM,
			C7_TEC, B1_POSIPI, C7_PRECO,
			C7_BASEICM, C7_PICM, C7_VALICM,
			C7_IPI, C7_VALIPI,
			C7_BASESOL, C7_VALSOL,
			C7_MSG, C7_VLDESC, C7_VALFRE, C7_TOTAL,
			C7_DATPRF, C7_OBS,
			C7_APROV, C7_USER, C7_MOEDA, C7_TXMOEDA,
			C7_LOCAL, C7_COND, C7_CONTRA, C7_CONTREV,
			C7_ENCER, C7_FILENT, C7_FISCORI,
			C7_TPFRETE, C7_FRETE, C7_FRETCON,C7_XFORMAI,C7_XFCA,
			%Exp:cCampos%
			SC7.R_E_C_N_O_ AS SC7RECNO
		FROM %Table:SC7% SC7
		INNER JOIN %Table:SB1% SB1 ON
				SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.%notDel%
			AND SB1.B1_COD = SC7.C7_PRODUTO
		WHERE
				SC7.C7_FILIAL = %xFilial:SC7%
			AND SC7.%notdel%
			AND SC7.C7_NUM = %Exp:cNumPc%
		ORDER BY %Order:SC7%

	EndSQL

	(cAliasSC7)->(DBGoTop())
	/** =================================================================================================================================== **/
	/** ======================= TABELA AUXILIAR DE COMPRAS (SZV) - BUSCAR ULTIMA REVISAO, OBSERVACOES GERAIS DO PC ======================== **/
	/** =================================================================================================================================== **/
	If Select((cAliasSC1)) > 0
		(cAliasSC1)->(DbCloseArea())
	EndIf

	BeginSQL Alias cAliasSC1

		SELECT C1_XREQMAI
			FROM %Table:SC1% SC1 
		WHERE 
				SC1.C1_FILIAL = %xFilial:SC1% 
			AND SC1.C1_PEDIDO = %Exp:cNumPC% 
			AND SC1.%NOTDEL%
		ORDER BY SC1.C1_NUM, SC1.C1_PEDIDO

	EndSQL
	
	(cAliasSC1)->(DBGoTop())

	
	/** =================================================================================================================================== **/
	/** ======================= TABELA AUXILIAR DE COMPRAS (SZV) - BUSCAR ULTIMA REVISAO, OBSERVACOES GERAIS DO PC ======================== **/
	/** =================================================================================================================================== **/
	If Select((cAliasSZV)) > 0
		(cAliasSZV)->(DbCloseArea())
	EndIf

	BeginSQL Alias cAliasSZV

		SELECT ZV_FILIAL, ZV_ORIGEM, ZV_TPREG, ZV_NUMERO, ZV_REVISAO, 
			ZV_REQUISI, ZV_REQFONE, ZV_REQMAIL, 
			UTL_RAW.CAST_TO_VARCHAR2(dbms_lob.substr(ZV_OBSGRPC, 2000, 1)) AS OBSGRPC
		FROM %Table:SZV% SZV 
		WHERE 
				SZV.ZV_FILIAL = %xFilial:SZV% 
			AND SZV.ZV_ORIGEM = %Exp:cOrigem%
			AND SZV.ZV_NUMERO = %Exp:cNumPC% 
			AND SZV.%NOTDEL%
		ORDER BY SZV.ZV_NUMERO, SZV.ZV_REVISAO DESC

	EndSQL
	
	(cAliasSZV)->(DBGoTop())


	ImpDet(@oReport,@aElements,lEnd)

	If !Empty(cPathInServer)
		Imprimir( @oReport, aElements, @lEnd ) 
	Else
		RptStatus( {|lEnd| Imprimir( @oReport, aElements, @lEnd ) }, "Imprimindo Pedido..." )
	EndIf

	RestArea(aArea)
	RestArea(aAreaSC7)
RETURN()


/*
=====================================================================================
Programa.:              Imprimir
-------------------------------------------------------------------------------------
Parametros:             ExpO1: Objeto grafico de impressao
                        ExpA2: Elementos para impressao, imagem, campos e valores
                        ExpL3: Cancelado pelo utilizador
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              24/07/19
Manutencao efetuada:    Criacao
=====================================================================================
*/
STATIC FUNCTION Imprimir(oReport,aElements,lEnd)
	LOCAL i //i, j, iBox, iObj, iPageBreak

	LOCAL nRow
	LOCAL nCol
	LOCAL cText
	LOCAL oFont
	LOCAL nWidth
	LOCAL nHeight
	LOCAL nClrText
	LOCAL nAlignHorz
	LOCAL nAlignVert
	LOCAL cPixel     := "-2" // DEFAULT -2
	
	// LOCAL oFontWMark
	// LOCAL nMarkRow
	// LOCAL nMarkCol

	LOCAL nPagePrint := 001
	LOCAL nNumPages  := 001

	LOCAL aBoxObjs   := {}
	LOCAL aGrapObjs  := {}

	/** =================================================================== **/
	/** ==================== MARCA D'AGUA DE IMPRESSAO ==================== **/
	/** =================================================================== **/
	LOCAL nMarcaTamH := 508
	LOCAL nMarcaTamV := 506
	LOCAL nMarcaPosH, nMarcaPosV, nWidthWM, nHeightWM
	/** =================================================================== **/
	/** = OBRIGATORIO IMAGEM EXTENSAO .BMP                                = **/
	/** = =>> IMAGEM marca-dagua-rascunho PNG COM EXTENSAO BMP            = **/
	/** = =>> TEXTO: FONTE "Londrina Outline"                             = **/
	/** = =>> IMAGEM GERADA VIA Sketchpad - https://sketch.io/sketchpad/  = **/
	/** =================================================================== **/
	DEFAULT cPictMarca := "/spool/marca-dagua-rascunho.bmp"
	DEFAULT lMarcaImpr := File(cPictMarca) // ARQUIVO MARCA D'AGUA EXISTE PARA IMPRESSAO
	DEFAULT lRascunho  := (lMarcaImpr .AND. "RASCUNHO" $ Upper(cPictMarca))

	If Empty(cPathInServer)
		SetRegua( Len(aElements) )
	EndIf

	/** =================================================================================================================================== **/
	/** ================================================== PROPRIEDADES DE MARCA D'AGUA  ================================================== **/
	/** == CALCULAR CENTRO VERTICAL E HORIZONTAL DA PAGINA DE ACORDO COM TAMANHO DA IMAGEM E ORIENTACAO DA PAGINA ========================= **/
	/** =================================================================================================================================== **/
	If lMarcaImpr
		nMarcaPosV := (oReport:nHorzSize - nMarcaTamH) / 02
		nMarcaPosH := (oReport:nVertSize - nMarcaTamV) / 02
		nWidthWM   := nMarcaTamH
		nHeightWM  := nMarcaTamV
	EndIf
	
	/** =================================================================================================================================== **/
	/** = CONTAGEM DE QUEBRA DE PAGINA ==================================================================================================== **/
	/** =================================================================================================================================== **/
	nNumPages  := 001
	For i := 1 To Len(aElements)
		If lEnd
			Exit
		EndIf

		If lMarcaImpr .AND. aElements[i][ATT_TYPE][02] == PAGE_END
			Aadd(aBoxObjs , {nNumPages, -1})
			Aadd(aGrapObjs, {nNumPages, -1})
		EndIf

		If aElements[i][ATT_TYPE][02] == PAGE_END
			nNumPages := nNumPages + 001
		EndIf

		If lMarcaImpr
			If aElements[i][ATT_TYPE][02] == TYPE_BOX
				Aadd(aBoxObjs , {nNumPages, i})
			Else
				Aadd(aGrapObjs, {nNumPages, i})
			EndIf
		EndIf
	Next i

	/** =================================================================================================================================== **/
	/** ==================================== CRIACAO DE COMPOMENTES DE ACORDO COM MAPA DE PROPRIEDADES ==================================== **/
	/** =================================================================================================================================== **/

	For i := 1 To Len(aElements)
		If lEnd
			Exit
		EndIf

		DO CASE
			CASE .NOT. (ValType(aElements[i][ATT_TEXT][2]) $ "CB") //-- NAO BLOCO OU NAO CARACTERE
				cText  := NIL
			CASE ValType(aElements[i][ATT_TEXT][2]) == "C"
				cText  := aElements[i][ATT_TEXT][2]
			CASE ValType(aElements[i][ATT_TEXT][2]) == "B"
				cText  := Eval(aElements[i][ATT_TEXT][2],nPagePrint,nNumPages)
		ENDCASE
		nRow       := aElements[i][ATT_POSV][2]
		nCol       := aElements[i][ATT_POSH][2]
		oFont      := aElements[i][ATT_FONT][2]
		nWidth     := aElements[i][ATT_TAMH][2]
		nHeight    := aElements[i][ATT_TAMV][2]
		If (ValType(aElements[i][ATT_TAMV][2]) == "C" .And. aElements[i][ATT_TAMV][2] $ "oFont")
			nHeight:= &("oFont"+SubStr(aElements[i][ATT_TAMV][2],6))
		EndIf
		nClrText   := aElements[i][ATT_CLRT][2]
		nAlignHorz := aElements[i][ATT_ALGH][2]
		nAlignVert := aElements[i][ATT_ALGV][2]
		nAngle     := aElements[i][ATT_GIRO][2]

		DO CASE
			CASE (aElements[i][ATT_TYPE][02] == TYPE_TXT)         // SayAlign
				/* FWMsPrinter(): SayAlign ( < nRow>, < nCol>, < cText>, [ oFont], [ nWidth], [ nHeigth], [ nClrText], [ nAlignHorz], [ nAlignVert ] ) */
				oReport:SayAlign(nRow, nCol, cText, oFont, nWidth, nHeight, nClrText, nAlignHorz, nAlignVert)
			CASE (aElements[i][ATT_TYPE][02] == TYPE_BOX)         // QUADRO // Box
				/* FWMsPrinter(): Box ( < nRow>, < nCol>, < nBottom>, < nRight>, [ cPixel] )                      */
				oReport:Box(nRow, nCol, nHeight, nWidth, cPixel)
			CASE (aElements[i][ATT_TYPE][02] == TYPE_IMG)         // Bitmap
				/* FWMsPrinter(): SayBitmap ( < nRow>, < nCol>, < cBitmap>, [ nWidth], [ nHeight] )               */
				oReport:SayBitmap(nRow, nCol, cText, nWidth, nHeight)
			CASE (aElements[i][ATT_TYPE][02] == TYPE_SAY)         // Say
				/* FWMsPrinter(): Say ( < nRow>, < nCol>, < cText>, [ oFont], [ nWidth], [ nClrText], [ nAngle] ) */
				oReport:Say(nRow, nCol, cText, oFont, nWidth, nClrText, nAngle)
			CASE (aElements[i][ATT_TYPE][02] == TYPE_LIN)         // QUADRO // Line
				/* FWMsPrinter(): Box ( < nRow>, < nCol>, < nBottom>, < nRight>, [ cPixel] )                      */
				oReport:Box(nRow, nCol, nHeight, nWidth)
			CASE (aElements[i][ATT_TYPE][02] == PAGE_END)
				// MARCA D'AGUA - RASCUNHO
				If lMarcaImpr
					oReport:SayBitmap(nMarcaPosV, nMarcaPosH, cPictMarca, nWidthWM, nHeightWM)
				EndIf

				// QUEBRA DE PAGINA
				oReport:EndPage()
				oReport:StartPage()
				nPagePrint := nPagePrint + 001
		ENDCASE

	Next i

	// MARCA D'AGUA - RASCUNHO - ULTIMA PAGINA
	If lMarcaImpr
		oReport:SayBitmap(nMarcaPosV, nMarcaPosH, cPictMarca, nWidthWM, nHeightWM)
	EndIf

RETURN()


/*
=====================================================================================
Programa.:              ImpDet
-------------------------------------------------------------------------------------
Parametros:             ExpO1: Objeto grafico de impressao
                        ExpA2: Elementos para impressao, imagem, campos e valores
                        ExpL3: Cancelado pelo utilizador
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
=====================================================================================
*/
STATIC FUNCTION ImpDet(oReport,aElements,lEnd)
	PRIVATE oFont07    := TFontEx():New(oReport,"Arial",07,07,.F.,.T.,.F.)
	PRIVATE oFont09    := TFontEx():New(oReport,"Arial",08,08,.F.,.T.,.F.)
	PRIVATE oFont10    := TFontEx():New(oReport,"Arial",10,10,.F.,.T.,.F.)
	PRIVATE oFont10N   := TFontEx():New(oReport,"Arial",10,10,.T.,.T.,.F.)
	PRIVATE oFont12    := TFontEx():New(oReport,"Arial",11,11,.F.,.T.,.F.)
	PRIVATE oFont12N   := TFontEx():New(oReport,"Arial",11,11,.T.,.T.,.F.)
	PRIVATE oFont14    := TFontEx():New(oReport,"Arial",13,13,.F.,.T.,.F.)
	PRIVATE oFont14N   := TFontEx():New(oReport,"Arial",13,13,.T.,.T.,.F.)
	PRIVATE oFont18N   := TFontEx():New(oReport,"Arial",21,21,.T.,.T.,.F.)
	PRIVATE oFont22N   := TFontEx():New(oReport,"Arial",23,23,.T.,.T.,.F.)

	PrtReport(@oReport,@aElements,@lEnd) //,@nLine

RETURN()


/*
=====================================================================================
Programa.:              PrtReport
-------------------------------------------------------------------------------------
Parametros:             ExpO1: Objeto grafico de impressao
                        ExpA2: Elementos para impressao, imagem, campos e valores
						ExpL3: Cancelado pelo utilizador
						ExpN4: Posicao vertical / linha de inicio
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
=====================================================================================
*/
STATIC FUNCTION PrtReport(oReport,aElements,lEnd,nLine)
	LOCAL nHPage       := 000
	LOCAL nVPage       := 000
	LOCAL nPosV        := 000
	LOCAL nFolha       := 001
	LOCAL nFolhas      := 000

	PRIVATE nBaseTxt
	PRIVATE nBaseCol
	DEFAULT nLine      := 000

	/** =================================================================================================================================== **/
	/** = Inicializacao da pagina do objeto grafico                                                                                         **/
	/** =================================================================================================================================== **/
	oReport:StartPage()
	nHPage   := oReport:nHorzRes()
	nHPage   *= (300/PixelX)
	nHPage   -= HMARGEM
	nVPage   := oReport:nVertRes()
	nVPage   *= (300/PixelY)
	nVPage   -= VBOX
	nLine    := 000 //-42
	nBaseTxt := 180
	nBaseCol := 70

	ReportCab(@oReport,@aElements,@lEnd,nPosV,nFolha,nFolhas,@nLine,@nBaseCol,@nBaseTxt)
	
RETURN()


/*
=====================================================================================
Programa.:              ReportCab
-------------------------------------------------------------------------------------
Parametros:             ExpO1: Objeto grafico de impressao
                        ExpA2:
                        ExpL3: 
                        ExpN4:
                        ExpN5:
                        ExpN6:
                        ExpN7:
						ExpN8:
						ExpN9:
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
=====================================================================================
*/
STATIC FUNCTION ReportCab(oReport,aElements,lEnd,nPosV,nFolha,nFolhas,nLine,nBaseCol,nBaseTxt)

	// LOCAL nHPage      := 0
	// LOCAL nVPage      := 0

	// LOCAL cGrpCompany := cEmpAnt

	LOCAL cPictCabec
	LOCAL lNewPage    := .F.
	// LOCAL i
	LOCAL nItRef
	LOCAL nSpace      := 002 //_nSpaceLine
	LOCAL nMargin     := 004
	LOCAL nTamCell    := 005
	LOCAL nRow
	LOCAL nCol
	LOCAL cText
	LOCAL cAux
	LOCAL oFont
	LOCAL nHeight
	LOCAL nWidth
	LOCAL nClrText
	LOCAL nAlignH
	LOCAL nAlignV
	LOCAL aUltComp
	LOCAL cPicture

	LOCAL aInfSM0
	LOCAL nEmpFil
	LOCAL cM0Nome
	LOCAL cM0NomeRed
	LOCAL cM0NomeCom
	LOCAL cM0Cgc
	LOCAL cM0Insc
	LOCAL xM4EmpCob
	// LOCAL cM4EndCob
	LOCAL cM0EndCob
	LOCAL cM0CplCob
	LOCAL cM0BaiCob
	LOCAL cM0CidCob
	LOCAL cM0EstCob
	LOCAL cM0CepCob
	LOCAL cM0EndEnt
	LOCAL cM0CplEnt
	LOCAL cM0BaiEnt
	LOCAL cM0CidEnt
	LOCAL cM0EstEnt
	LOCAL cM0CepEnt
	LOCAL xM4EmpEnt
	LOCAL cM4EndEnt
	LOCAL aCBoxFrete
	LOCAL nOptFrete
	LOCAL cXFCA
	Local nX := 1
	Local aMAux := {}
	PRIVATE oColumns   := {}
	PRIVATE nTamVCabIt := 123 //-- ALTURA DOS CABECALHO / TITULOS DE COLUNAS DOS ITENS

	DEFAULT aElements  := {}
	

	cPictCabec := "LGRL" + FWGrpCompany() + ".BMP"
	nRow       := nLine


	PrtHeader(@oReport,@aElements)   //-- INICIA NOVA PAGINA E IMPRIME CABECALHO


	/** =================================================================================================================================== **/
	/** ======================================================= DADOS DO FORNECEDOR ======================================================= **/
	/** =================================================================================================================================== **/
	If Empty(cPathInServer)
		IncRegua()
	EndIf

	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "ReportHeaderBox"})
	nLine    := aElements[nItRef][ATT_TAMV][02] // - nHeight
	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** ==================================================== MOLDURA CABECALHO - QUADRO =================================================== **/
	nRow     := nLine + nMargin
	nCol     := INIBOXH
	oFont    := oFont14N:oFont
	nWidth   := MAXBOXH
	nHeight  := nRow + oFont:nHeight *1.2
	aUltComp := AAddComponent(oReport,@aElements,"BoxHeaderSupplier",TYPE_BOX,,nRow,nCol,oFont,nWidth,nHeight)

	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** ============================================================= TITULO ============================================================== **/
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "BoxHeaderSupplier"})
	cText    := "Dados do Fornecedor"
	nRow     := aUltComp[ATT_POSV][02]
	nCol     := aUltComp[ATT_POSH][02]
	oFont    := oFont12N:oFont
	nWidth   := aUltComp[ATT_TAMH][02]
	nHeight  := nRow + oFont:nHeight *1.2
	nAlignH  := ALIGNCENT
	nAlignV  := VALIGCENT
	aUltComp := AAddComponent(oReport,@aElements,"BoxHeaderSupplierTitle",TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV,nClrText)

	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** ====================================================== MOLDURA DETALHES - QUADRO ================================================== **/
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "BoxHeaderSupplier"})
	nRow     := aElements[nItRef][ATT_TAMV][02]
	nCol     := aElements[nItRef][ATT_POSH][02]
	oFont    := oFont12:oFont
	nWidth   := aElements[nItRef][ATT_TAMH][02]
	nHeight  := nRow + oFont:nHeight *1.2 * 03 + nSpace                   // 03 LINHAS DE DADOS
	aUltComp := AAddComponent(oReport,@aElements,"DetailBoxSupplier",TYPE_BOX,,nRow,nCol,oFont,nWidth,nHeight)

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** ======================================================= DETALHE - RAZAO SOCIAL ==================================================== **/
	cText    := "Razão Social:" + Space(1)
	cText    := cText + AllTrim( Posicione("SA2", 01, xFilial("SA2")+(cAliasSC7)->(C7_FORNECE+C7_LOJA), "A2_NOME") ) // 01 - A2_FILIAL+A2_COD+A2_LOJA
	nRow     := aUltComp[ATT_POSV][02] + nSpace   /* 47.2 + 2.0 = 49.2 */                             // REFERENCE DetailBoxSupplier
	nCol     := aUltComp[ATT_POSH][02] + nMargin                                                      // REFERENCE DetailBoxSupplier
	oFont    := aUltComp[ATT_FONT][02]                                                                // REFERENCE DetailBoxSupplier
	nWidth   := nTamCell * 070
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellSupplierName",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** =========================================================== DETALHE - CNPJ ======================================================== **/
	cText    := "CNPJ:" + Space(1)
	cText    := cText + Transform( Posicione("SA2", 01, xFilial("SA2")+(cAliasSC7)->(C7_FORNECE+C7_LOJA),"A2_CGC"), PesqPict("SA2","A2_CGC"))
	nRow     := aUltComp[ATT_POSV][02]                                                                // REFERENCE DetailCellSupplierName
	nCol     := aUltComp[ATT_TAMH][02] + nMargin                                                      // REFERENCE DetailCellSupplierName
	oFont    := aUltComp[ATT_FONT][02]                                                                // REFERENCE DetailCellSupplierName
	nWidth   := nTamCell * 035 /* 115 */
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellSupplierCGC",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** ================================================= INSCRICAO ESTADUAL DO FORNECEDOR ================================================ **/
	cText    := "IE:" + Space(1)
	cText    := cText + AllTrim( Transform( Posicione("SA2", 01, xFilial("SA2")+(cAliasSC7)->(C7_FORNECE+C7_LOJA),"A2_INSCR"), PesqPict("SA2","A2_INSCR")) )
	nRow     := aUltComp[ATT_POSV][02]                                                                // REFERENCE DetailCellSupplierCGC
	nCol     := aUltComp[ATT_POSH][02] + aUltComp[ATT_TAMH][02] + nMargin                             // REFERENCE DetailCellSupplierCGC
	oFont    := aUltComp[ATT_FONT][02]                                                                // REFERENCE DetailCellSupplierCGC
	nWidth   := nTamCell * 027 /* 140 */                                                              // REFERENCE DetailCellSupplierCGC
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellSupplierIE",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** ======================================================= CODIGO DO FORNECEDOR ====================================================== **/
	cPicture := "@R " + Replicate("9", TamSX3("A2_COD")[1]) + "-" + Replicate("9", TamSX3("A2_LOJA")[1])
	cText    := "Código do Fornecedor:" + Space(1)
	cText    := cText + Transform( (cAliasSC7)->(C7_FORNECE + C7_LOJA), cPicture) // MAX CODIGO 17 CARACTERES
	nRow     := aUltComp[ATT_POSV][02]                                                                 // REFERENCE DetailCellSupplierIE
	nCol     := aUltComp[ATT_POSH][02] + aUltComp[ATT_TAMH][02] + nMargin                              // REFERENCE DetailCellSupplierIE
	oFont    := aUltComp[ATT_FONT][02]                                                                 // REFERENCE DetailCellSupplierIE
	nWidth   := nTamCell * 037 /* 180 */                                                               // REFERENCE DetailCellSupplierIE
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellSupplierCode",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 002 ======================================================================================================================= **/
	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** ======================================================= TELEFONE DO FORNECEDOR ==================================================== **/
	cPicture := PesqPict("SA2", "A2_DDD")
	cAux     := Posicione("SA2", 01, xFilial("SA2")+(cAliasSC7)->(C7_FORNECE+C7_LOJA), "A2_DDD")
	cAux     := AllTrim( Transform(cAux, cPicture) )
	cAux     := IIF(!Empty(cAux), "(" + cAux + ")" + Space(1), "")
	cPicture := PesqPict("SA2","A2_TEL")
	cAux     := cAux + Transform( Posicione("SA2", 01, xFilial("SA2")+(cAliasSC7)->(C7_FORNECE+C7_LOJA), "A2_TEL"), cPicture )
	cText    := "Telefone:" + Space(1)
	cText    := cText + AllTrim( cAux )                                                                // Telefone: (00) 9999-9999
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellSupplierName"})
	nRow     := aElements[nItRef][ATT_POSV][02] + aElements[nItRef][ATT_FONT][02]:nHeight + nSpace     // REFERENCE DetailCellSupplierName
	nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                        // REFERENCE DetailCellSupplierName
	oFont    := aElements[nItRef][ATT_FONT][02]                                                        // REFERENCE DetailCellSupplierName
	nWidth   := nTamCell * 070                                                                         // REFERENCE DetailCellSupplierName
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellSupplierPhone",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 002 ======================================================================================================================= **/
	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** ========================================= ENDERECO EMAIL DO FORNECEDOR -- Pedido de Compra ======================================== **/
	cPicture := PesqPict("SA2","A2_EMAIL")
	cText    := "E-mail:" + Space(1)
	if !Empty((cAliasSC7)->C7_XFORMAI)
		cAux     := Transform(strtran((cAliasSC7)->C7_XFORMAI,' ',''), cPicture )
	Else
		cAux     := Transform( Posicione("SA2", 01, xFilial("SA2")+(cAliasSC7)->(C7_FORNECE+C7_LOJA), "A2_EMAIL"), cPicture )
	endif
	cAux   :=  AllTrim(cAux)
	if !(cAliasSC1)->(EOF())
		aMAux   := strtokarr((cAliasSC1)->C1_XREQMAI,';')
		nX := 1
		For nX := 1 to Len(aMAux)
							
			if !(alltrim(aMaux[nX]) $ cAux)
				If SubStr(cAux, len(cAux), 1) <>';'
					cAux += ';' 
				Endif
				
				cAux += alltrim(aMaux[nX])
			EndIf
			//cAux    := Alltrim(cAux) + Alltrim(Transform((cAliasSC1)->C1_XREQMAI, cPicture ))
		Next nX
	EndIf

	cText    := cText + AllTrim(cAux)
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellSupplierCGC"})
	nRow     := aElements[nItRef][ATT_POSV][02] + aElements[nItRef][ATT_FONT][02]:nHeight + nSpace     // REFERENCE DetailCellSupplierCGC
	nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                        // REFERENCE DetailCellSupplierCGC
	oFont    := aElements[nItRef][ATT_FONT][02]                                                        // REFERENCE DetailCellSupplierCGC
	nWidth   := nTamCell * 070                                                                         // REFERENCE DetailCellSupplierCGC
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellSupplierMail",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)
	
	/** = LINHA 002 ======================================================================================================================= **/
	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** ======================================================= CONTRATO DO FORNECEDOR ==================================================== **/
	cPicture := PesqPict("SA2","C7_CONTRA")
	cText    := "Contrato do Fornecedor:" + Space(1)
	cAux     := Transform((cAliasSC7)->(C7_CONTRA), cPicture)
	cText    := cText + AllTrim(cAux)
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellSupplierCode"})
	nRow     := aElements[nItRef][ATT_POSV][02] + aElements[nItRef][ATT_FONT][02]:nHeight + nSpace     // REFERENCE DetailCellSupplierCode
	nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                        // REFERENCE DetailCellSupplierCode
	oFont    := aElements[nItRef][ATT_FONT][02]                                                        // REFERENCE DetailCellSupplierCode
	nWidth   := nTamCell * 037 /* 180 */                                                               // REFERENCE DetailCellSupplierCode
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellSupplierContract",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 003 ======================================================================================================================= **/
	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** ======================================================= ENDERECO DO FORNECEDOR ==================================================== **/
	cAux     := Posicione("SA2", 01, xFilial("SA2")+(cAliasSC7)->(C7_FORNECE+C7_LOJA), "A2_END")
	cAux     := AllTrim(cAux) + Space(1) + Posicione("SA2", 01, xFilial("SA2")+(cAliasSC7)->(C7_FORNECE+C7_LOJA), "A2_COMPLEM")
	cText    := "Endereço:" + Space(1)
	cText    := cText + AllTrim( cAux )
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellSupplierPhone"})
	nRow     := aElements[nItRef][ATT_POSV][02] + aElements[nItRef][ATT_FONT][02]:nHeight + nSpace     // REFERENCE DetailCellSupplierPhone
	nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                        // REFERENCE DetailCellSupplierPhone
	oFont    := aElements[nItRef][ATT_FONT][02]                                                        // REFERENCE DetailCellSupplierPhone
	nWidth   := nTamCell * 070                                                                         // REFERENCE DetailCellSupplierPhone
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellSupplierAddress",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 003 ======================================================================================================================= **/
	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** ================================================== BAIRRO DO ENDERECO DO FORNECEDOR =============================================== **/
	cPicture := PesqPict("SA2","A2_BAIRRO")
	cText    := "Bairro:" + Space(1)
	cAux     := Transform( Posicione("SA2", 01, xFilial("SA2")+(cAliasSC7)->(C7_FORNECE+C7_LOJA), "A2_BAIRRO"), cPicture )
	cText    := cText + AllTrim(cAux)
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellSupplierMail"})
	nRow     := aElements[nItRef][ATT_POSV][02] + aElements[nItRef][ATT_FONT][02]:nHeight + nSpace     // REFERENCE DetailCellSupplierMail
	nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                        // REFERENCE DetailCellSupplierMail
	oFont    := aElements[nItRef][ATT_FONT][02]                                                        // REFERENCE DetailCellSupplierMail
	nWidth   := nTamCell * 070                                                                         // REFERENCE DetailCellSupplierMail
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellSupplierDistrict",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 003 ======================================================================================================================= **/
	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** ================================================= CIDADE DO ENDERECO DO FORNECEDOR ================================================ **/
	cText    := "Cidade:" + Space(1)
	cText    := cText + AllTrim( Transform( Posicione("SA2", 01, xFilial("SA2")+(cAliasSC7)->(C7_FORNECE+C7_LOJA), "A2_MUN"), PesqPict("SA2","A2_MUN")) )
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellSupplierIE"})
	//-- REFENCIA ALTURA DO ELEMENTO "IE", MULTIPLICA ALTURA (PRIMEIRA LINHA) x2 PARA LINHA ATUAL
	// nRow     := aElements[nItRef][ATT_POSV][02] + ((aElements[nItRef][ATT_FONT][02]:nHeight + nSpace) * 002   // REFERENCE DetailCellSupplierIE
	//-- REFENCIA ALTURA DA LINHA DO ELEMENTO ANTERIOR "Bairro"
	nRow     := aUltComp[ATT_POSV][02]                                                                 // REFERENCE DetailCellSupplierDistrict
	nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                        // REFERENCE DetailCellSupplierIE
	oFont    := aElements[nItRef][ATT_FONT][02]                                                        // REFERENCE DetailCellSupplierIE
	nWidth   := nTamCell * 027 /* 135 */                                                               // REFERENCE DetailCellSupplierIE
	If Len(cText) > 24 /* "Cidade: ..." MUNICIPIO MAIOR QUE 15 CARACTERES AUMENTA CAMPO */
		nWidth := nTamCell * (027 + 008) /* 175 */
	EndIf
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellSupplierCity",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 003 ======================================================================================================================= **/
	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** ================================================= ESTADO DO ENDERECO DO FORNECEDOR ================================================ **/
	cPicture := PesqPict("SA2","A2_EST")
	cText    := "Estado:" + Space(1)
	cAux     := Transform( Posicione("SA2", 01, xFilial("SA2")+(cAliasSC7)->(C7_FORNECE+C7_LOJA), "A2_EST"), cPicture )
	cText    := cText + AllTrim(cAux)
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellSupplierContract"})
	nRow     := aElements[nItRef][ATT_POSV][02] + aElements[nItRef][ATT_FONT][02]:nHeight + nSpace     // REFERENCE DetailCellSupplierContract
	// nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */  /* 672 */                          // REFERENCE DetailCellSupplierContract
	nCol     := aUltComp[ATT_POSH][02] + aUltComp[ATT_TAMH][02] + nMargin /* 672 .OR. 712 */           // REFERENCE DetailCellSupplierCity
	oFont    := aElements[nItRef][ATT_FONT][02]                                                        // REFERENCE DetailCellSupplierContract
	nWidth   := nTamCell * 015 /* 075 */
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellSupplierState",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 003 ======================================================================================================================= **/
	/** = BOX - SUPPLIER ================================================================================================================== **/
	/** =================================================== CEP DO ENDERECO DO FORNECEDOR ================================================= **/
	cPicture := PesqPict("SA2","A2_CEP")
	cText    := "CEP:" + Space(1)
	cText    := cText + AllTrim( Transform( Posicione("SA2", 01, xFilial("SA2")+(cAliasSC7)->(C7_FORNECE+C7_LOJA), "A2_CEP"), cPicture ) )
	nRow     := aUltComp[ATT_POSV][02]                                                                 // REFERENCE DetailCellSupplierState
	nCol     := 785
	oFont    := aUltComp[ATT_FONT][02]                                                                 // REFERENCE DetailCellSupplierState
	nWidth   := nTamCell * 015 /* 075 */
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellSupplierCep",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)


	/** =================================================================================================================================== **/
	/** ====================================================== DADOS DE FATURAMENTO ======================================================= **/
	/** =================================================================================================================================== **/
	If Empty(cPathInServer)
		IncRegua()
	EndIf

	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailBoxSupplier"})
	nLine    := aElements[nItRef][ATT_TAMV][02] // - nHeight                                           // REFERENCE DetailBoxSupplier
	/** = BOX - BILLING =================================================================================================================== **/
	/** ==================================================== MOLDURA CABECALHO - QUADRO =================================================== **/
	nRow     := nLine /* + nMargin */
	nCol     := aElements[nItRef][ATT_POSH][02] // INIBOXH
	oFont    := aElements[nItRef][ATT_FONT][02] // oFont14N:oFont
	nWidth   := aElements[nItRef][ATT_TAMH][02] // MAXBOXH
	nHeight  := nRow + oFont:nHeight *1.2
	aUltComp := AAddComponent(oReport,@aElements,"BoxHeaderBilling",TYPE_BOX,,nRow,nCol,oFont,nWidth,nHeight)

	/** = BOX - BILLING =================================================================================================================== **/
	/** ============================================================= TITULO ============================================================== **/
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "BoxHeaderSupplier"})
	cText    := "Dados de Faturamento"
	nRow     := aUltComp[ATT_POSV][02]
	nCol     := aUltComp[ATT_POSH][02]
	oFont    := oFont12N:oFont
	nWidth   := aUltComp[ATT_TAMH][02]
	nHeight  := nRow + oFont:nHeight //*1.2
	nAlignH  := ALIGNCENT
	nAlignV  := VALIGCENT
	aUltComp := AAddComponent(oReport,@aElements,"BoxHeaderBillingTitle",TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV,nClrText)

	/** = BOX - BILLING =================================================================================================================== **/
	/** ====================================================== MOLDURA DETALHES - QUADRO ================================================== **/
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "BoxHeaderBilling"})
	nRow     := aElements[nItRef][ATT_TAMV][02]
	nCol     := aElements[nItRef][ATT_POSH][02]
	oFont    := oFont12:oFont
	nWidth   := aElements[nItRef][ATT_TAMH][02]
	nHeight  := nRow + oFont:nHeight *1.2 * 03 + nSpace                   // 03 LINHAS DE DADOS
	aUltComp := AAddComponent(oReport,@aElements,"DetailBoxBilling",TYPE_BOX,,nRow,nCol,oFont,nWidth,nHeight)

	/** = BOX - BILLING =================================================================================================================== **/
	/** =================================================== DADOS DA EMPRESA FATURAMENTO ================================================== **/
	aInfSM0    := FWLoadSM0()
	nEmpFil    := ASCAN(aInfSM0, { |x| UPPER(x[01]) == cEmpAnt .And. UPPER(x[02]) == (cAliasSC7)->(C7_FILIAL) })
	nEmpFil    := IIF(nEmpFil == 0, ASCAN(aInfSM0, { |x| UPPER(x[01]) == cEmpAnt .And. UPPER(x[02]) == cFilAnt }), nEmpFil)
	cM0Nome    := aInfSM0[nEmpFil][06]
	cM0NomeRed := aInfSM0[nEmpFil][07]
	cM0NomeCom := aInfSM0[nEmpFil][17]
	cM0Cgc     := aInfSM0[nEmpFil][18]
	//-- DADOS ADICIONAIS NAO RETORNADOS POR FWLoadSM0()
	OpenSM0()
	DbSelectArea("SM0")
	DbSetOrder(1) // M0_CODIGO+M0_CODFIL
	DbSeek(cEmpAnt + (cAliasSC7)->(C7_FILIAL))
	cM0Cgc     := SM0->M0_CGC
	cM0Insc    := SM0->M0_INSC
	cM0EndCob  := SM0->M0_ENDCOB
	cM0CplCob  := SM0->M0_COMPCOB
	cM0BaiCob  := SM0->M0_BAIRCOB
	cM0CidCob  := SM0->M0_CIDCOB
	cM0EstCob  := SM0->M0_ESTCOB
	cM0CepCob  := SM0->M0_CEPCOB

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - BILLING =================================================================================================================== **/
	/** ======================================================= DETALHE - RAZAO SOCIAL ==================================================== **/
	cText    := "Razão Social:" + Space(1)
	cText    := cText + AllTrim( cM0NomeCom )
	nRow     := aUltComp[ATT_POSV][02] + nSpace                                                        // REFERENCE DetailBoxBilling
	nCol     := aUltComp[ATT_POSH][02] + nMargin                                                       // REFERENCE DetailBoxBilling
	oFont    := aUltComp[ATT_FONT][02]                                                                 // REFERENCE DetailBoxBilling
	nWidth   := nTamCell * 070
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellBillingName",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - BILLING =================================================================================================================== **/
	/** ========================================================= DETALHE - CNPJ ========================================================== **/
	cPicture := PesqPict("SA2","A2_CGC") //-- MASCARA CNPJ EMPRESA (SM0)
	cText    := "CNPJ:" + Space(1)
	cText    := cText + AllTrim( Transform( cM0Cgc,  cPicture) )
	nRow     := aUltComp[ATT_POSV][02]                                                                 // REFERENCE DetailCellSupplierName
	nCol     := aUltComp[ATT_TAMH][02] + nMargin                                                       // REFERENCE DetailCellSupplierName
	oFont    := aUltComp[ATT_FONT][02]                                                                 // REFERENCE DetailCellSupplierName
	nWidth   := nTamCell * 025 /* 125 */
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellBillingCgc",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - BILLING =================================================================================================================== **/
	/** ================================================== INSCRICAO ESTADUAL DA EMPRESA ================================================== **/
	cPicture := PesqPict("SA2","A2_INSCR") //-- MASCARA CNPJ EMPRESA (SM0)
	cText    := "IE:" + Space(1)
	cText    := cText + AllTrim( Transform( cM0Insc, cPicture) )
	nRow     := aUltComp[ATT_POSV][02]                                                                // REFERENCE DetailCellSupplierCGC
	nCol     := aUltComp[ATT_POSH][02] + aUltComp[ATT_TAMH][02] + nMargin                             // REFERENCE DetailCellSupplierCGC
	oFont    := aUltComp[ATT_FONT][02]                                                                // REFERENCE DetailCellSupplierCGC
	nWidth   := nTamCell * 020 /* 100 */
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellBillingIE",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - BILLING =================================================================================================================== **/
	/** ================================================ MOEDA VALORES DO PEDIDO DE COMPRA ================================================ **/
	cText    := "Moeda:" + Space(1)
	cText    := cText + "BRL"
	nRow     := aUltComp[ATT_POSV][02]                                                                // REFERENCE DetailCellBillingIE
	nCol     := aUltComp[ATT_POSH][02] + aUltComp[ATT_TAMH][02] + nMargin                             // REFERENCE DetailCellBillingIE
	oFont    := aUltComp[ATT_FONT][02]                                                                // REFERENCE DetailCellBillingIE
	nWidth   := nTamCell * 020 /* 100 */
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellBillingCurrency",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - BILLING =================================================================================================================== **/
	/** ====================================================== CONDICAO DE PAGAMENTO ====================================================== **/
	cPicture := PesqPict("SE4","E4_DESCRI")
	cText    := "Cond.de Pagto.:" + Space(1)
	cAux     := Posicione("SE4", 01, xFilial("SE4")+(cAliasSC7)->(C7_COND), "E4_DESCRI")
	cAux     := Transform( cAux, cPicture )
	cText    := cText + AllTrim( cAux )
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellSupplierCode"})
	nRow     := aUltComp[ATT_POSV][02]                                                                // REFERENCE DetailCellBillingCurrency
	nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                       // REFERENCE DetailCellSupplierCode
	oFont    := aElements[nItRef][ATT_FONT][02]                                                       // REFERENCE DetailCellSupplierCode
	nWidth   := nTamCell * 037 /* 185 */
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellBillingPaymentTerm",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 002 ======================================================================================================================= **/
	/** = BOX - BILLING =================================================================================================================== **/
	/** ====================================================== ENDERECO DE FATURAMENTO ==================================================== **/
	cPicture := PesqPict("SA1", "A1_CEP")
	cAux     := AllTrim(cM0EndCob)
	cAux     := cAux + IIF(!Empty(cM0CplCob)," / "  + AllTrim(cM0CplCob),"")
	cAux     := cAux + Space(2) + AllTrim(cM0BaiCob)
	cAux     := cAux +   ", "   + AllTrim(cM0CidCob)
	cAux     := cAux +   " - "  + AllTrim(cM0EstCob)
	cAux     := cAux + Space(2) + "CEP:"
	cAux     := cAux + Space(1) + Transform(cM0CepCob,cPicture)
	cText    := "Endereço:" + Space(1)
	cText    := cText + AllTrim( cAux )
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellBillingName"})
	nRow     := aElements[nItRef][ATT_POSV][02] + aElements[nItRef][ATT_FONT][02]:nHeight + nSpace    // REFERENCE DetailCellBillingName
	nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                       // REFERENCE DetailCellBillingName
	oFont    := aElements[nItRef][ATT_FONT][02]                                                       // REFERENCE DetailCellBillingName
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellBillingPaymentTerm"})
	nWidth   := aElements[nItRef][ATT_POSH][02] - nCol - nMargin                                      // REFERENCE DetailCellBillingPaymentTerm
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellBillingAddress",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 002 ======================================================================================================================= **/
	/** = BOX - BILLING =================================================================================================================== **/
	/** ============================================================ FRETE (TIPO) ========================================================= **/
	aCBoxFrete := {                    ;
		{"C", "CIF"}                    , ;
		{"F", "FOB"}                    , ;
		{"T", "Por Conta Terceiros"}    , ;
		{"R", "Por Conta Remetente"}    , ;
		{"D", "Por Conta Destinatário"} , ;
		{"S", "Sem Frete"}                ;
		}
	cXFCA := (cAliasSC7)->C7_XFCA
    cText := "Frete: " + Space(1)
	IF cXFCA = 'S'
		cText += "FCA"
	ELSE
		cText += IIF(nOptFrete > 0, aCBoxFrete[nOptFrete][02] ,"")
	ENDIF
		nOptFrete := AScan(aCBoxFrete, {|x| x[1] == (cAliasSC7)->(C7_TPFRETE)})
		//cText    := "Frete:" + Space(1)
		//cText    := cText + IIF(nOptFrete > 0, aCBoxFrete[nOptFrete][02] ,"")
		nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellBillingName"})
		nRow     := aElements[nItRef][ATT_POSV][02] + aElements[nItRef][ATT_FONT][02]:nHeight + nSpace    // REFERENCE DetailCellBillingName
		oFont    := aElements[nItRef][ATT_FONT][02]                                                       // REFERENCE DetailCellBillingName
		nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellBillingPaymentTerm"})
		nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                       // REFERENCE DetailCellBillingPaymentTerm
		nWidth   := aElements[nItRef][ATT_TAMH][02]                                                       // REFERENCE DetailCellBillingPaymentTerm
		aUltComp := AAddComponent(oReport,@aElements,"DetailCellBillingFreightType",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)
	

	/** = LINHA 003 ======================================================================================================================= **/
	/** = BOX - BILLING =================================================================================================================== **/
	/** ============================================================== COMPRADOR ========================================================== **/
	cPicture := PesqPict("SY1","Y1_NOME")
	cAux     := Transform( Posicione("SY1", 03, xFilial("SY1")+(cAliasSC7)->(C7_USER), "Y1_NOME"), cPicture ) // 03 - Y1_FILIAL+Y1_USER
	cText    := "Comprador:" + Space(1)
	cText    := cText + AllTrim( cAux )
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellBillingAddress"})
	nRow     := aElements[nItRef][ATT_POSV][02] + aElements[nItRef][ATT_FONT][02]:nHeight + nSpace    // REFERENCE DetailCellBillingAddress
	nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                       // REFERENCE DetailCellBillingAddress
	oFont    := aElements[nItRef][ATT_FONT][02]                                                       // REFERENCE DetailCellBillingAddress
	nWidth   := nTamCell * 070
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellBillingPurchaser",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 003 ======================================================================================================================= **/
	/** = BOX - BILLING =================================================================================================================== **/
	/** =================================================== ENDERECO EMAIL DO COMPRADOR =================================================== **/
	cPicture := PesqPict("SY1","Y1_EMAIL")
	cAux     := Transform( Posicione("SY1", 03, xFilial("SY1")+(cAliasSC7)->(C7_USER), "Y1_EMAIL"), cPicture )
	cText    := "E-mail:" + Space(1)
	cText    := cText + AllTrim( cAux )
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellSupplierMail"})
	nRow     := aUltComp[ATT_POSV][02]                                                                // REFERENCE DetailCellBillingPurchaser
	nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                       // REFERENCE DetailCellSupplierMail
	oFont    := aElements[nItRef][ATT_FONT][02]                                                       // REFERENCE DetailCellSupplierMail
	nWidth   := nTamCell * 070
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellBillingPurchaserMail",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 003 ======================================================================================================================= **/
	/** = BOX - BILLING =================================================================================================================== **/
	/** ===================================================== TELEFONE CONTATO COMPRADOR ================================================== **/
	cPicture := PesqPict("SY1","Y1_TEL")
	cAux     := Posicione("SY1", 03, xFilial("SY1")+(cAliasSC7)->(C7_USER), "Y1_TEL")
	cAux     := Iif(!Empty(cAux), Transform( cAux, cPicture ) , Space(0))
	cText    := "Telefone:" + Space(1)
	cText    := cText + AllTrim(cAux)
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellBillingFreightType"})
	nRow     := aElements[nItRef][ATT_POSV][02] + aElements[nItRef][ATT_FONT][02]:nHeight + nSpace    // REFERENCE DetailCellBillingFreightType
	oFont    := aElements[nItRef][ATT_FONT][02]                                                       // REFERENCE DetailCellBillingFreightType
	nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                       // REFERENCE DetailCellBillingFreightType
	nWidth   := aElements[nItRef][ATT_TAMH][02]                                                       // REFERENCE DetailCellBillingFreightType
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellBillingPurchaserPhone",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)


	/** =================================================================================================================================== **/
	/** ======================================================== DADOS DE ENTREGA ========================================================= **/
	/** =================================================================================================================================== **/
	If Empty(cPathInServer)
		IncRegua()
	EndIf

	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailBoxBilling"})
	nLine    := aElements[nItRef][ATT_TAMV][02] // - nHeight                                          // REFERENCE DetailBoxBilling
	/** = BOX - DELIVERY ================================================================================================================== **/
	/** ==================================================== MOLDURA CABECALHO - QUADRO =================================================== **/
	nRow     := nLine /* + nMargin */
	nCol     := aElements[nItRef][ATT_POSH][02] // INIBOXH
	oFont    := aElements[nItRef][ATT_FONT][02] // oFont14N:oFont
	nWidth   := aElements[nItRef][ATT_TAMH][02] // MAXBOXH
	nHeight  := nRow + oFont:nHeight *1.2
	aUltComp := AAddComponent(oReport,@aElements,"BoxHeaderDelivery",TYPE_BOX,,nRow,nCol,oFont,nWidth,nHeight)

	/** = BOX - DELIVERY ================================================================================================================== **/
	/** ============================================================= TITULO ============================================================== **/
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "BoxHeaderDelivery"})
	cText    := "Dados de Entrega"
	nRow     := aUltComp[ATT_POSV][02]
	nCol     := aUltComp[ATT_POSH][02]
	oFont    := oFont12N:oFont
	nWidth   := aUltComp[ATT_TAMH][02]
	nHeight  := nRow + oFont:nHeight //*1.2
	nAlignH  := ALIGNCENT
	nAlignV  := VALIGCENT
	aUltComp := AAddComponent(oReport,@aElements,"BoxHeaderDeliveryTitle",TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV,nClrText)

	/** = BOX - DELIVERY ================================================================================================================== **/
	/** ==================================================== MOLDURA DETALHES - QUADRO ==================================================== **/
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "BoxHeaderDelivery"})
	nRow     := aElements[nItRef][ATT_TAMV][02]
	nCol     := aElements[nItRef][ATT_POSH][02]
	oFont    := oFont12:oFont
	nWidth   := aElements[nItRef][ATT_TAMH][02]
	nHeight  := nRow + oFont:nHeight *1.2 * 03 + nSpace                   // 03 LINHAS DE DADOS
	aUltComp := AAddComponent(oReport,@aElements,"DetailBoxDelivery",TYPE_BOX,,nRow,nCol,oFont,nWidth,nHeight)

	/** = BOX - DELIVERY ================================================================================================================== **/
	/** ==================================================== DADOS DA EMPRESA - ENTREGA ==================================================== **/
	//-- DADOS ADICIONAIS NAO RETORNADOS POR FWLoadSM0()
	OpenSM0()
	DbSelectArea("SM0")
	DbSetOrder(1) // M0_CODIGO+M0_CODFIL
	DbSeek(cEmpAnt + (cAliasSC7)->(C7_FILIAL))
	cM0EndEnt := SM0->M0_ENDENT
	cM0CplEnt := SM0->M0_COMPENT
	cM0BaiEnt := SM0->M0_BAIRENT
	cM0CidEnt := SM0->M0_CIDENT
	cM0EstEnt := SM0->M0_ESTENT
	cM0CepEnt := SM0->M0_CEPENT

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - DELIVERY ================================================================================================================== **/
	/** ======================================================== ENDERECO DE ENTREGA ====================================================== **/
	//-- FORMULAS (SM4) - BUSCA INFORMACOES DADOS DE ENTREGA
	xM4EmpEnt := Posicione("SM4", 01, xFilial("SM4")+"D"+cEmpAnt, "M4_FORMULA") // 01 - M4_FILIAL+M4_CODIGO
	xM4EmpEnt := &(xM4EmpEnt)
	cAux      := ""
	cM4EndEnt := ""
	nItRef    := AScan(xM4EmpEnt,{|x|x[1]=="M0_ENDENT"})
	If nItRef > 0
		cM4EndEnt := xM4EmpEnt[nItRef][02]
	EndIf
	//-- REOTORNA DADOS DE ENTREGA - PREFERENCIA CADASTRO DE FORMULAS (SM4)
	If nItRef == 0 .Or. Empty(cM4EndEnt)
		cPicture := PesqPict("SA1", "A1_CEP")

		cAux := AllTrim(cM0EndEnt)
		If !Empty(cM0CplEnt)
			cAux := cAux +   " / "  + AllTrim(cM0CplEnt)
		EndIf
		cAux := cAux + Space(2) + AllTrim(cM0BaiEnt)
		cAux := cAux +   ",  "  + AllTrim(cM0CidEnt)
		cAux := cAux +   " - "  + AllTrim(cM0EstEnt)
		If !Empty(cM0CepEnt)
			cAux := cAux + Space(2) + "CEP:"
			cAux := cAux + Space(1) + Transform(cM0CepEnt,cPicture)
		EndIf
	ELSE
		cAux  := cM4EndEnt
	EndIf

	cText    := "Endereço:" + Space(1)
	cText    := cText + AllTrim( cAux )
	nRow     := aUltComp[ATT_POSV][02] + nSpace                                                        // REFERENCE DetailBoxDelivery
	nCol     := aUltComp[ATT_POSH][02] + nMargin                                                       // REFERENCE DetailBoxDelivery
	oFont    := aUltComp[ATT_FONT][02]                                                                 // REFERENCE DetailBoxDelivery
	nWidth   := aUltComp[ATT_TAMH][02] - nCol - nMargin                                                // REFERENCE DetailBoxDelivery
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellDeliveryAddress",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 002 ======================================================================================================================= **/
	/** = BOX - DELIVERY ================================================================================================================== **/
	/** ==================================================== ENDERECO EMAIL DE ENTREGA ==================================================== **/
	//-- FORMULAS (SM4) - BUSCA INFORMACOES DADOS DE ENTREGA
	// cAux     := ""
	// nItRef   := AScan(xM4EmpEnt,{|x|x[1]=="M0_MAILENT"})
	// If nItRef > 0
	// 	cAux := xM4EmpEnt[nItRef][02]
	// EndIf
	cAux     := (cAliasSZV)->ZV_REQMAIL
		
	cText    := "E-mail:" + Space(1)
	cText    := cText + AllTrim( cAux )
	nRow     := aUltComp[ATT_POSV][02] + aUltComp[ATT_FONT][02]:nHeight + nSpace                       // REFERENCE DetailCellDeliveryAddress
	nCol     := aUltComp[ATT_POSH][02] /* + nMargin */                                                 // REFERENCE DetailCellDeliveryAddress
	oFont    := aUltComp[ATT_FONT][02]                                                                 // REFERENCE DetailCellDeliveryAddress
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellBillingIE"})
	nWidth   := aElements[nItRef][ATT_POSH][02] - nCol - nMargin                                      // REFERENCE DetailCellBillingIE
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellDeliveryMail",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 002 ======================================================================================================================= **/
	/** = BOX - DELIVERY ================================================================================================================== **/
	/** ================================================ TELEFONE DE CONTATO PARA ENTREGA ================================================= **/
	//-- FORMULAS (SM4) - BUSCA INFORMACOES DADOS DE ENTREGA
	// cAux     := ""
	// nItRef   := AScan(xM4EmpEnt,{|x|x[1]=="M0_TELENT"})
	// If nItRef > 0
	// 	cAux := xM4EmpEnt[nItRef][02]
	// EndIf
	cAux     := (cAliasSZV)->ZV_REQFONE
	cAux     := Iif(!Empty(cAux), Transform( cAux, PesqPict("SZV","ZV_REQFONE") ), Space(0))

	cText    := "Telefone:" + Space(1)
	cText    := cText + AllTrim(cAux)
	nRow     := aUltComp[ATT_POSV][02]                                                                // REFERENCE DetailCellDeliveryMail
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellBillingIE"})
	nCol     := aElements[nItRef][ATT_POSH][02]                                                       // REFERENCE DetailCellBillingIE
	oFont    := aUltComp[ATT_FONT][02]                                                                // REFERENCE DetailCellDeliveryMail
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailBoxBilling"})
	nWidth   := aElements[nItRef][ATT_TAMH][02] - nCol - nMargin                                      // REFERENCE DetailBoxBilling
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellDeliveryPhone",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 003 ======================================================================================================================= **/
	/** = BOX - DELIVERY ================================================================================================================== **/
	/** ====================================================== CONTATO PARA ENTREGA ======================================================= **/
	//-- FORMULAS (SM4) - BUSCA INFORMACOES DADOS DE ENTREGA
	// cAux     := ""
	// nItRef   := AScan(xM4EmpEnt,{|x|x[1]=="M0_CNTTENT"})
	// If nItRef > 0
	// 	cAux := xM4EmpEnt[nItRef][02]
	// EndIf
	cAux     := (cAliasSZV)->ZV_REQUISI

	cText    := "Contato de Entrega:" + Space(1)
	cText    := cText + AllTrim(cAux)
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellDeliveryMail"})
	nRow     := aElements[nItRef][ATT_POSV][02] + aElements[nItRef][ATT_FONT][02]:nHeight + nSpace    // REFERENCE DetailCellDeliveryMail
	nCol     := aElements[nItRef][ATT_POSH][02]                                                       // REFERENCE DetailCellDeliveryMail
	oFont    := aElements[nItRef][ATT_FONT][02]                                                       // REFERENCE DetailCellDeliveryMail
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailBoxBilling"})
	nWidth   := aElements[nItRef][ATT_TAMH][02] - nCol - nMargin                                      // REFERENCE DetailBoxBilling
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellDeliveryContact",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)


	/** =================================================================================================================================== **/
	/** ======================================================== DADOS DE COBRANCA ======================================================== **/
	/** =================================================================================================================================== **/
	If Empty(cPathInServer)
		IncRegua()
	EndIf
	
	//-- DADOS ADICIONAIS NAO RETORNADOS POR FWLoadSM0()
	OpenSM0()
	DbSelectArea("SM0")
	DbSetOrder(1) // M0_CODIGO+M0_CODFIL
	DbSeek(cEmpAnt + (cAliasSC7)->(C7_FILIAL))
	cM0EndCOB := SM0->M0_ENDCOB
	cM0CplCOB := SM0->M0_COMPCOB
	cM0BaiCOB := SM0->M0_BAIRCOB
	cM0CidCOB := SM0->M0_CIDCOB
	cM0EstCOB := SM0->M0_ESTCOB
	cM0CepCOB := SM0->M0_CEPCOB

	oJsonCob := JsonObject():New()
	// oJsonCob:fromJson('{' ;
    //     + 	'"number": "2822",' ;
    //     + 	'"address": "Av. Ibirapuera",' ;
    //     + 	'"zipCode": "04028002",' ;
    //     + 	'"state": {' ;
    //     + 	'  "stateId": "SP"' ;
    //     + 	'},' ;
    //     + 	'"complement": "",' ;
    //     + 	'"district": "Moema",' ;
    //     + 	'"city": {' ;
    //     + 	'  "cityDescription": "SAO PAULO"' ;
    //     + 	'},' ;
    //     + 	'"billingMail": "CAOA.PAGADORIA@CAOA.COM.BR",' ;
    //     + 	'"billingPhone": "+55 (11) 5538-1181"' ;
    //     + '}')

	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailBoxDelivery"})
	nLine    := aElements[nItRef][ATT_TAMV][02] // - nHeight                                          // REFERENCE DetailBoxDelivery
	xM4EmpCob := Posicione("SM4", 01, xFilial("SM4")+"P"+cEmpAnt, "M4_FORMULA")                       // 01 - M4_FILIAL+M4_CODIGO
	xM4EmpCob := SubStr(xM4EmpCob,2,Len(AllTrim(xM4EmpCob))-2) // REMOVER ASPAS SIMPLES DO INICIO E FIM DA FORMULA // xM4EmpCob := &(xM4EmpCob)
	oJsonCob:fromJson(xM4EmpCob)
	/** = BOX - PAYMENT =================================================================================================================== **/
	/** ==================================================== MOLDURA CABECALHO - QUADRO =================================================== **/
	nRow     := nLine /* + nMargin */
	nCol     := aElements[nItRef][ATT_POSH][02] // INIBOXH
	oFont    := aElements[nItRef][ATT_FONT][02] // oFont14N:oFont
	nWidth   := aElements[nItRef][ATT_TAMH][02] // MAXBOXH
	nHeight  := Round( nRow + oFont:nHeight *1.2 , 0)
	aUltComp := AAddComponent(oReport,@aElements,"BoxHeaderPayment",TYPE_BOX,,nRow,nCol,oFont,nWidth,nHeight)

	/** = BOX - PAYMENT =================================================================================================================== **/
	/** ==================================================== DADOS DE COBRANCA - TITULO =================================================== **/
	cText    := "Dados de Cobrança"
	nRow     := aUltComp[ATT_POSV][02]
	nCol     := aUltComp[ATT_POSH][02]
	oFont    := oFont12N:oFont
	nWidth   := aUltComp[ATT_TAMH][02]
	nHeight  := nRow + oFont:nHeight //*1.2
	nAlignH  := ALIGNCENT
	nAlignV  := VALIGCENT
	aUltComp := AAddComponent(oReport,@aElements,"BoxHeaderPaymentTitle",TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV,nClrText)

	/** = BOX - PAYMENT =================================================================================================================== **/
	/** ==================================================== MOLDURA DETALHES - QUADRO ==================================================== **/
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "BoxHeaderPayment"})
	nRow     := aElements[nItRef][ATT_TAMV][02]
	nCol     := aElements[nItRef][ATT_POSH][02]
	oFont    := oFont12:oFont
	nWidth   := aElements[nItRef][ATT_TAMH][02]
	nHeight  := nRow + oFont:nHeight *1.2 * 02 + nSpace                   // 03 LINHAS DE DADOS
	aUltComp := AAddComponent(oReport,@aElements,"DetailBoxPayment",TYPE_BOX,,nRow,nCol,oFont,nWidth,nHeight)

	/** = BOX - PAYMENT =================================================================================================================== **/
	/** =================================================== DADOS DA EMPRESA - COBRANCA =================================================== **/
	//-- FORMULAS (SM4) - BUSCA INFORMACOES DADOS DE ENTREGA - CADASTRO DE FORMULAS
	cAux     := AllTrim(cM0EndCob) + IIF(!Empty(cM0CplCob)," / " + AllTrim(cM0CplCob),"")
	If !Empty(oJsonCob:GetJsonText("address"))
		cAux := oJsonCob:GetJsonText("address")
		cAux += IIF(!Empty(oJsonCob:GetJsonText("number")),","+Space(1),"") + oJsonCob:GetJsonText("number")
		cAux += IIF(!Empty(oJsonCob:GetJsonText("complement")),Space(1)+"/"+Space(1),"") + oJsonCob:GetJsonText("complement")
	EndIf
	// nItRef   := AScan(xM4EmpCob,{|x|x[1]=="M0_ENDCOB"})
	// If nItRef > 0
	// 	cAux := xM4EmpCob[nItRef][02]
	// EndIf

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - PAYMENT =================================================================================================================== **/
	/** ======================================================== ENDERECO DE COBRANCA ===================================================== **/
	cText    := "Endereço:" + Space(1)
	cText    := cText + AllTrim( cAux )
	nRow     := aUltComp[ATT_POSV][02] + nSpace                                                        // REFERENCE DetailBoxPayment
	nCol     := aUltComp[ATT_POSH][02] + nMargin                                                       // REFERENCE DetailBoxPayment
	oFont    := aUltComp[ATT_FONT][02]                                                                 // REFERENCE DetailBoxPayment
	nWidth   := nTamCell * 070
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellPaymentAddress",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - PAYMENT =================================================================================================================== **/
	/** ======================================================== DETALHE - BAIRRO ========================================================= **/
	cAux     := cM0BaiCob
	If !Empty(oJsonCob:GetJsonText("district"))
		cAux := oJsonCob:GetJsonText("district")
	EndIf
	// nItRef := AScan(xM4EmpCob,{|x|x[1]=="M0_BAIRCOB"})
	// If nItRef > 0 .And. !Empty(xM4EmpCob[nItRef][02])
	// 	cAux := xM4EmpCob[nItRef][02]
	// EndIf
	cText    := "Bairro:" + Space(1)
	cText    := cText + AllTrim( cAux )
	nRow     := aUltComp[ATT_POSV][02]                                                                 // REFERENCE DetailCellPaymentAddress
	nCol     := aUltComp[ATT_TAMH][02] + nMargin                                                       // REFERENCE DetailCellPaymentAddress
	oFont    := aUltComp[ATT_FONT][02]                                                                 // REFERENCE DetailCellPaymentAddress
	nWidth   := nTamCell * 025 /* 125 */
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellPaymentDistrict",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - PAYMENT =================================================================================================================== **/
	/** ================================================= CIDADE DO ENDERECO DE COBRANCA ================================================== **/
	cAux     := cM0CidCob
	If ValType(oJsonCob:GetJsonObject("city")) == "J" .AND. !Empty(oJsonCob:GetJsonObject("city"):GetJsonText("cityDescription"))
		cAux := oJsonCob:GetJsonObject("city"):GetJsonText("cityDescription")
	EndIf
	// nItRef   := AScan(xM4EmpCob,{|x|x[1]=="M0_CIDCOB"})
	// If nItRef > 0 .And. !Empty(xM4EmpCob[nItRef][02])
	// 	cAux := xM4EmpCob[nItRef][02]
	// EndIf
	cText    := "Cidade:" + Space(1)
	cText    := cText + AllTrim( cAux )
	nRow     := aUltComp[ATT_POSV][02]                                                                 // REFERENCE DetailCellPaymentDistrict
	oFont    := aUltComp[ATT_FONT][02]                                                                 // REFERENCE DetailCellPaymentDistrict
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellSupplierCity"})
	nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                       // REFERENCE DetailCellSupplierCity
	nWidth   := nTamCell * 027 /* 135 */                                                               // REFERENCE DetailCellSupplierIE
	If Len(cText) > 24 /* "Cidade: ..." MUNICIPIO MAIOR QUE 15 CARACTERES AUMENTA CAMPO */
		nWidth := nTamCell * (027 + 008) /* 175 */
	EndIf
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellPaymentCity",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - PAYMENT =================================================================================================================== **/
	/** ================================================== ESTADO DO ENDERECO DO COBRANCA ================================================= **/
	cAux     := cM0EstCob
	If ValType(oJsonCob:GetJsonObject("state")) == "J" .AND. !Empty(oJsonCob:GetJsonObject("state"):GetJsonText("stateId"))
		cAux := oJsonCob:GetJsonObject("state"):GetJsonText("stateId")
	EndIf
	// nItRef   := AScan(xM4EmpCob,{|x|x[1]=="M0_ESTCOB"})
	// If nItRef > 0 .And. !Empty(xM4EmpCob[nItRef][02])
	// 	cAux := xM4EmpCob[nItRef][02]
	// EndIf
	cText    := "Estado:" + Space(1)
	cText    := cText + AllTrim( cAux )
	nRow     := aUltComp[ATT_POSV][02]                                                                 // REFERENCE DetailCellPaymentDistrict
	oFont    := aUltComp[ATT_FONT][02]                                                                 // REFERENCE DetailCellPaymentDistrict
	nCol     := aUltComp[ATT_POSH][02] + aUltComp[ATT_TAMH][02] + nMargin /* 672 .OR. 712 */           // REFERENCE DetailCellPaymentCity
	nWidth   := nTamCell * 015 /* 075 */
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellPaymentState",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 001 ======================================================================================================================= **/
	/** = BOX - PAYMENT =================================================================================================================== **/
	/** ==================================================== CEP DO ENDERECO DE COBRANCA ================================================== **/
	cAux     := cM0CepCob
	If !Empty(oJsonCob:GetJsonText("zipCode"))
		cAux := oJsonCob:GetJsonText("zipCode")
	EndIf
	cPicture := PesqPict("SA1", "A1_CEP") 
	cAux     := Transform(cAux, cPicture)
	// nItRef   := AScan(xM4EmpCob,{|x|x[1]=="M0_CEPCOB"})
	// If nItRef > 0 .And. !Empty(xM4EmpCob[nItRef][02])
	// 	cAux := xM4EmpCob[nItRef][02]
	// EndIf
	cText    := "CEP:" + Space(1)
	cText    := cText + AllTrim( cAux )
	nRow     := aUltComp[ATT_POSV][02]                                                                 // REFERENCE DetailCellPaymentState
	nCol     := 785
	oFont    := aUltComp[ATT_FONT][02]                                                                 // REFERENCE DetailCellPaymentState
	nWidth   := nTamCell * 015 /* 075 */
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellPaymentCep",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 002 ======================================================================================================================= **/
	/** = BOX - PAYMENT =================================================================================================================== **/
	/** ============================================================== TELEFONE =========================================================== **/
	cAux     := ""
	If !Empty(oJsonCob:GetJsonText("billingPhone"))
		cAux := oJsonCob:GetJsonText("billingPhone")
	EndIf
	// nItRef   := AScan(xM4EmpCob,{|x|x[1]=="M0_TELCOB"})
	// If nItRef > 0 .And. !Empty(xM4EmpCob[nItRef][02])
	// 	cAux := xM4EmpCob[nItRef][02]
	// EndIf
	cText    := "Telefone:" + Space(1)
	cText    := cText + AllTrim( cAux )
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellPaymentAddress"})
	nRow     := aElements[nItRef][ATT_POSV][02] + aElements[nItRef][ATT_FONT][02]:nHeight + nSpace   // REFERENCE DetailCellPaymentAddress
	nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                       // REFERENCE DetailCellPaymentAddress
	oFont    := aElements[nItRef][ATT_FONT][02]                                                       // REFERENCE DetailCellPaymentAddress
	nWidth   := nTamCell * 070
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellPaymentPhone",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)

	/** = LINHA 002 ======================================================================================================================= **/
	/** = BOX - PAYMENT =================================================================================================================== **/
	/** =================================================== ENDERECO EMAIL DE COBRANCA ==================================================== **/
	cAux     := ""
	If !Empty(oJsonCob:GetJsonText("billingMail"))
		cAux := oJsonCob:GetJsonText("billingMail")
	EndIf
	// nItRef   := AScan(xM4EmpCob,{|x|x[1]=="M0_MAILCOB"})
	// If nItRef > 0 .And. !Empty(xM4EmpCob[nItRef][02])
	// 	cAux := xM4EmpCob[nItRef][02]
	// EndIf
	cText    := "E-mail:" + Space(1)
	cText    := cText + AllTrim( cAux )
	nRow     := aUltComp[ATT_POSV][02]                                                                 // REFERENCE DetailCellPaymentPhone
	oFont    := aUltComp[ATT_FONT][02]                                                                 // REFERENCE DetailCellPaymentPhone
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailCellSupplierMail"})
	nCol     := aElements[nItRef][ATT_POSH][02] /* + nMargin */                                       // REFERENCE DetailCellSupplierMail
	nWidth   := nTamCell * 070
	aUltComp := AAddComponent(oReport,@aElements,"DetailCellPaymentMail",TYPE_TXT,cText,nRow,nCol,oFont,nWidth)


	/** =================================================================================================================================== **/
	/** ===================================================== SECAO - ITENS DO PEDIDO ===================================================== **/
	/** =================================================================================================================================== **/
	If Empty(cPathInServer)
		IncRegua()
	EndIf

	// (@oReport, @aElements, @oColumns, @nLine, .T.)
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "DetailBoxPayment"})
	nLine    := aElements[nItRef][ATT_TAMV][02]
	nLine    := nLine + nMargin
	If nLine > (MAXBOXV - nTamVCabIt)
		lNewPage := .T.
	EndIf
	aTotals  := {}
	SecItems(@oReport,@lEnd,@aElements,@oColumns,aTotals,@nLine,lNewPage,NIL,NIL,aElements[nItRef][ATT_PAGE][02])


	/** =================================================================================================================================== **/
	/** ==================================================== SECAO - TOTAIS DO PEDIDO ===================================================== **/
	/** =================================================================================================================================== **/
	If Empty(cPathInServer)
		IncRegua()
	EndIf
	
	SecTotals(@oReport,@lEnd,@aElements,@oColumns,aTotals,@nLine) //,lNewPage,nPageCount)


	/** =================================================================================================================================== **/
	/** =================================================== SECAO - OBSERVACOES GERAIS ==================================================== **/
	/** =================================================================================================================================== **/
	If Empty(cPathInServer)
		IncRegua()
	EndIf
	
	SecObsPC(@oReport,@lEnd,@aElements,@nLine) //,lNewPage,nPageCount)


	/** =================================================================================================================================== **/
	/** ==================================================== SECAO - TERMOS E CONDICOES =================================================== **/
	/** =================================================================================================================================== **/
	If Empty(cPathInServer)
		IncRegua()
	EndIf
	
	PrtTermsPC(@oReport,@lEnd,@aElements) //,nPageCount)

RETURN()


/*
=====================================================================================
Programa.:              SecItems
-------------------------------------------------------------------------------------
Parametros:             ExpO1: Objeto grafico de impressao
                        ExpL2: Cancelado pelo utilizador
						ExpA3: Elementos para impressao, imagem, campos e valores
						ExpO4: Objeto de propriedades dos itens, detalhe
                        ExpA5: Vetor valores e impostos dos itens
                        ExpL6: Posicao vertical / linha de inicio
                        ExpL7: Quebra de pagina, iniciar em nova pagina
                        ExpA8: Array valores no item para impressao, paginacao
                        ExpN9: Contador de numero de itens detalhe do documento
                        ExpN10: Numero da pagina de inclusao dos elementos da secao
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
=====================================================================================
*/
STATIC FUNCTION SecItems(oReport,lEnd,aElements,oColumns,aTotals,nLine,lNewPage,aItemPC,nItemCount,nPageCount)
	LOCAL nBoxItems
	LOCAL oBoxItems

	LOCAL nMargin    := 005
	// LOCAL nCellSize  := 005 //-- TAMANHO DA CELULA DE ESPACAMENTO //-- 172 CELULAS
	LOCAL nSpaceLine := 002

	LOCAL aUltComp

	LOCAL nCellLeft  := 000
	LOCAL nCellCount := 000

	// LOCAL aItCabL1   := {}
	// LOCAL aItCabL2   := {}

	LOCAL aIt_IPI    := {}
	LOCAL aIt_ICMSST := {}
	LOCAL aIt_TOTAL  := {}
	LOCAL aIt_DESC   := {}
	LOCAL aIt_FRETE  := {}
	LOCAL aIt_PRUICM := {}

	LOCAL cAux
	LOCAL nCol
	LOCAL cText
	// LOCAL oFontDef   := oFont12:oFont
	LOCAL oFontItem  := oFont07:oFont
	LOCAL oFont
	LOCAL nWidth
	LOCAL nHeight
	LOCAL nClrText   := NIL
	LOCAL nAlignH    := ALIGNCENT
	LOCAL nAlignV    := VALIGSUP

	// LOCAL nTamVMinIt := (oFontItem:nHeight * 02) + nSpaceLine // 024 // ITEM SEM COMENTARIOS FONT12
	LOCAL nTamVItem
	Local i          := 0

	LOCAL nItRef     := 000
	LOCAL nItemCol   := 000
	LOCAL nCalcVal   := 000
	LOCAL nLnTamChar := 195
	LOCAL nTotLnObs  := 000
	LOCAL cItemObsM  := ""
	LOCAL cObsLinha  := ""

	DEFAULT aItemPC    := {}
	DEFAULT oColumns   := {}
	DEFAULT aTotals    := {}
	DEFAULT nItemCount := 000
	DEFAULT nLine      := 000 //aElements[nItBoxHead][08][02] + 004
	DEFAULT lNewPage   := .F.
	DEFAULT nPageCount := 001

	If !lNewPage
		If nLine > MAXBOXV
			lNewPage := .T.
		EndIf

		//== VERIFICAR PAGINA ATUAL POSSUI MARCA ISO RODAPE
		nItRef   := AScan(aElements, {|aItem| aItem[01][02] == "ReportFooterISORegister" .AND. aItem[13][02] == nPageCount})
		If nItRef < 1
			PrtFooter(@oReport,@aElements)   //-- IMPRIMIR RODAPE DA PAGINA ATUAL
		EndIf

		nPageCount := ATail(aElements)[13][02]
	Else // lNewPage == .T.
		// oReport:EndPage() //-- QUEBRA DE PAGINA DEVE SER INSERIDA NA LISTAGEM DE ELEMENTOS. PARA CORRETA PAGINACAO E IMPRESSAO
		cAux       := "PageBreak" + PadL(nPageCount,2,"0")
		AAddComponent(oReport,@aElements,cAux,PAGE_END)

		PrtHeader(@oReport,@aElements)   //-- INICIA NOVA PAGINA E IMPRIME CABECALHO
		PrtFooter(@oReport,@aElements)   //-- IMPRIME RODAPE DA PAGINA, NOVA

		//-- AJUSTAR LINHA DO COMPONENTE REFERENCIA NA CONSTRUCAO DOS ITENS
		nPageCount := ATail(aElements)[13][02] + 01

		nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "ReportHeaderBox" .And. aItem[13][02] == nPageCount})
		nLine    := aElements[nItRef][ATT_TAMV][02]
		nLine    := nLine + nMargin
	EndIf

	/** =================================================================================================================================== **/
	/** ============================================== COLUNAS - PARAMETROS TAMANHO E POSICAO ============================================= **/
	/** =================================================================================================================================== **/
	If Len(oColumns) < 1
		//-- oColumns { nRow, nCol, nHeight, nWidth, nCell, nAlignHorz }
		Aadd(oColumns, {000, (nCellLeft += 000), 006, (nCellCount += 006), 006, ALIGNCENT }) // Item
		Aadd(oColumns, {000, (nCellLeft += 006), 006, (nCellCount += 040), 040, ALIGNLEFT }) // Material/Serviço
		Aadd(oColumns, {000, (nCellLeft += 040), 006, (nCellCount += 007), 007, ALIGNCENT }) // NCM / ISS
		Aadd(oColumns, {000, (nCellLeft += 007), 006, (nCellCount += 010), 010, ALIGRIGHT }) // Quant.
		Aadd(oColumns, {000, (nCellLeft += 010), 006, (nCellCount += 005), 005, ALIGNCENT }) // UM
		Aadd(oColumns, {000, (nCellLeft += 005), 006, (nCellCount += 012), 012, ALIGRIGHT }) // Preço Unit. PIS/COFINS
		Aadd(oColumns, {000, (nCellLeft += 012), 006, (nCellCount += 011), 011, ALIGRIGHT }) // Preço Unit. c/ ICMS
		Aadd(oColumns, {000, (nCellLeft += 011), 006, (nCellCount += 010), 010, ALIGRIGHT }) // Base ICMS
		Aadd(oColumns, {000, (nCellLeft += 010), 006, (nCellCount += 007), 007, ALIGRIGHT }) // % ICMS
		Aadd(oColumns, {000, (nCellLeft += 007), 006, (nCellCount += 011), 011, ALIGRIGHT }) // Valor ICMS
		Aadd(oColumns, {000, (nCellLeft += 011), 006, (nCellCount += 006), 006, ALIGRIGHT }) // % IPI
		Aadd(oColumns, {000, (nCellLeft += 006), 006, (nCellCount += 011), 011, ALIGRIGHT }) // Valor IPI
		Aadd(oColumns, {000, (nCellLeft += 011), 006, (nCellCount += 011), 011, ALIGRIGHT }) // Base ICMSST
		Aadd(oColumns, {000, (nCellLeft += 011), 006, (nCellCount += 010), 010, ALIGRIGHT }) // Valor ICMSST
		Aadd(oColumns, {000, (nCellLeft += 010), 006, (              013), 013, ALIGRIGHT }) // Preço Total c/ ICMS
	EndIf

	/** =================================================================================================================================== **/
	/** ===================================================== SECAO - ITENS DO PEDIDO ===================================================== **/
	/** =================================================================================================================================== **/
	SecItemTit(@oReport,@lEnd,@aElements,oColumns,@nLine,lNewPage)
	nBoxItems  := AScan(aElements, {|aItem| "BoxItems" $ aItem[01][02] .And. aItem[13][02] == nPageCount})
	oBoxItems  := aElements[nBoxItems]

	/** =================================================================================================================================== **/
	/** ========================================================= ITENS DO PEDIDO ========================================================= **/
	/** =================================================================================================================================== **/
	If Len(aItemPC) == 0
		//-- ABRIR TABELA DE PEDIDO, MODO PADRAO, PARA OBTER DADOS DO CAMPO TIPO "MEMO"
		//-- PROBLEMA: CORRIGIR PROBLEMA NA SELECT CAMPO NAO PREENCHIDO RETORNA 65535 CARACTERES VAZIOS
		//--           FUNCAO "EMPTY" NAO RETORNA .T. CAMPO VAZIO (NAO PREENCHIDOS INICIALMENTE)
		//--           FUNCAO "ALLTRIM" NAO REMOVE CARACTERES VAZIOS NESTES CAMPOS NAO PREENCHIDOS INICIALMENTE
		//--           FUNCAO "LEN" CONTA OS CARACTERES EM BRANCO
		//-- SOLUCAO:  POSICIONAR REGISTRO E OBTER VALOR DO CAMPO TIPO "MEMO"
		If Select("SC7") == 0
			DBSelectArea("SC7")
		EndIf

		DBSelectArea(cAliasSC7)
		DBGoTop()
		lFirstItem   := .T.

		//-- VETORES COM VALORES DOS IMPOSTOS DOS ITENS
		aIt_IPI    := {}
		aIt_ICMSST := {}
		aIt_TOTAL  := {}
		aIt_DESC   := {}
		aIt_FRETE  := {}
		aIt_PRUICM := {}
	EndIf

	/** =================================================================================================================================== **/
	/** ================================================= ITENS DO PEDIDO - PERCORRE ITENS ================================================ **/
	/** =================================================================================================================================== **/
	While !lEnd .And. .NOT. (cAliasSC7)->(EOF())
		nItemCount:= nItemCount + 001
		aItemPC   := {}

		/** =================================================================================================================================== **/
		/** ========================================================= ITEM - VALORES ========================================================== **/
		/** = FRETE =========================================================================================================================== **/
		Aadd(aIt_FRETE , (cAliasSC7)->(C7_FRETE ) )
		/** = DESCONTO ======================================================================================================================== **/
		Aadd(aIt_DESC  , (cAliasSC7)->(C7_VLDESC) )
		/** = VALOR IPI ======================================================================================================================= **/
		Aadd(aIt_IPI   , (cAliasSC7)->(C7_VALIPI) )
		/** = VALOR ICMSST ==================================================================================================================== **/
		Aadd(aIt_ICMSST, (cAliasSC7)->(C7_VALSOL) )
		/** = PRECO TOTAL (C/IMPOSTOS) ======================================================================================================== **/
		Aadd(aIt_TOTAL , (cAliasSC7)->(C7_TOTAL ) )

		/** = ITEM ============================================================================================================================ **/
		Aadd(aItemPC   , (cAliasSC7)->(C7_ITEM  ) )

		/** ========================================================= ITEM - LINHA 01 ========================================================= **/
		/** = MATERIAL/SERVICO ================================================================================================================ **/
		cPicture := PesqPict("SC7", "C7_PRODUTO")
		cText    := AllTrim( Transform((cAliasSC7)->(C7_PRODUTO),cPicture) )
		cText    := cText + Space(1) + "-" + Space(1)
		cText    := cText + AllTrim( (cAliasSC7)->(C7_DESCRI) )
		Aadd(aItemPC   , cText                                                                  )

		/** = NCM / ISS ======================================================================================================================= **/
		cText     := ""
		//-- C7_TEC - SEMPRE VAZIO - MESMA DESCRICAO DO B1_POSIPI. CAMPO DEVE SER UTILIZADO POR ALGUM MODULO/SEGMENTO ESPECIFICO
		// If !Empty((cAliasSC7)->(C7_TEC))
		// 	cText     := Transform( (cAliasSC7)->(C7_TEC    ) , PesqPict("SC7", "C7_TEC    ") )
		// ElseIf !Empty((cAliasSC7)->(B1_POSIPI))
			cText     := Transform( (cAliasSC7)->(B1_POSIPI ) , PesqPict("SB1", "B1_POSIPI ") )
		// EndIf
		Aadd(aItemPC   , cText                                                                  )

		/** = QUANT. ========================================================================================================================== **/
		cText     := LTrim( Transform( (cAliasSC7)->(C7_QUANT  ) , PesqPict("SC7", "C7_QUANT"  ) ) )
		Aadd(aItemPC   , cText                                                                  )

		/** = UM ============================================================================================================================== **/
		Aadd(aItemPC   , (cAliasSC7)->(C7_UM     )                                              )

		/** = PRECO UNIT. PIS/COFINS ========================================================================================================== **/
		nCalcVal  := ( (cAliasSC7)->(C7_PRECO  ) * (1 - (cAliasSC7)->(C7_PICM   )/100) )
		cText     := LTrim( Transform( Round( nCalcVal, 02 )     , "@E 99,999,999.99"       ) )
		Aadd(aItemPC   , cText                                                                  )

		/** = PRECO UNIT. C/ ICMS ============================================================================================================= **/
		// nCalcVal  := ( (cAliasSC7)->(C7_VALICM) / (cAliasSC7)->(C7_QUANT) )
		// nCalcVal  := nCalcVal + (cAliasSC7)->(C7_PRECO)
		// cText     := LTrim( Transform( nCalcVal                  , "@E 99,999,999.99"       ) )
		cText     := LTrim( Transform( (cAliasSC7)->(C7_PRECO  ) , "@E 99,999,999.99"       ) )
		Aadd(aIt_PRUICM, nCalcVal )
		Aadd(aItemPC   , cText                                                                  )

		/** = BASE ICMS ======================================================================================================================= **/
		cText     := LTrim( Transform( (cAliasSC7)->(C7_BASEICM) , "@E 99,999,999.99"       ) )
		Aadd(aItemPC   , cText                                                                  )

		/** = % ICMS ========================================================================================================================== **/
		cText     := LTrim( Transform( (cAliasSC7)->(C7_PICM   ) , "@E 99,999,999.99"       ) )
		Aadd(aItemPC   , cText                                                                  )

		/** = VALOR ICMS ====================================================================================================================== **/
		cText     := LTrim( Transform( (cAliasSC7)->(C7_VALICM ) , "@E 99,999,999.99"       ) )
		Aadd(aItemPC   , cText                                                                  )

		/** = % IPI =========================================================================================================================== **/
		cText     := LTrim( Transform( (cAliasSC7)->(C7_IPI    ) , "@E 99,999,999.99"       ) )
		Aadd(aItemPC   , cText                                                                  )

		/** = VALOR IPI ======================================================================================================================= **/
		cText     := LTrim( Transform( (cAliasSC7)->(C7_VALIPI ) , "@E 99,999,999.99"       ) )
		Aadd(aItemPC   , cText                                                                  )

		/** = BASE ICMSST ===================================================================================================================== **/
		cText     := LTrim( Transform( (cAliasSC7)->(C7_BASESOL) , "@E 99,999,999.99"       ) )
		Aadd(aItemPC   , cText                                                                  )

		/** = VALOR ICMSST ==================================================================================================================== **/
		cText     := LTrim( Transform( (cAliasSC7)->(C7_VALSOL ) , "@E 99,999,999.99"       ) )
		Aadd(aItemPC   , cText                                                                  )

		/** = PRECO TOTAL (C/IMPOSTOS) ======================================================================================================== **/
		cText     := LTrim( Transform( (cAliasSC7)->(C7_TOTAL  ) , "@E 99,999,999.99"       ) )
		Aadd(aItemPC   , cText                                                                  )

		/** ========================================================= ITEM - LINHA 02 ========================================================= **/
		/** = DATA DE ENTREGA ================================================================================================================= **/
		cText      := DtoC((cAliasSC7)->(C7_DATPRF ))
		cText      := Replace( cText , "/", ".")
		Aadd(aItemPC   , "Data de entrega:" + Space(1) + cText                                  )

		/** ========================================================= ITEM - LINHA 03 ========================================================= **/
		/** = OBSERVACOES / DESCRICAO LONGA =================================================================================================== **/
		//  === CAMPO CUSTOMIZADO ==============================  //
		//  ===== C7_XDESCL1 C 254, 000 Descricao Longa 1 ======  //
		If ((cAliasSC7)->(FieldPos("C7_XDESCL1")) > 0)
			Aadd(aItemPC   , AllTrim( (cAliasSC7)->(C7_XDESCL1) )                               )
		EndIf

		/** ========================================================= ITEM - LINHA 04 ========================================================= **/
		/** = OBSERVACOES / DESCRICAO LONGA =================================================================================================== **/
		//  === CAMPO CUSTOMIZADO ==============================  //
		//  ===== C7_XDESCL2 C 254, 000 Descricao Longa 2 ======  //
		If ((cAliasSC7)->(FieldPos("C7_XDESCL2")) > 0)
			Aadd(aItemPC   , AllTrim( (cAliasSC7)->(C7_XDESCL2) )                               )
		EndIf

		/** ========================================================= ITEM - LINHA 05 ========================================================= **/
		/** = OBSERVACOES DO ITEM ============================================================================================================= **/
		//  ===== C7_OBSM    M 050, 000 Observacoes do item ====  //
		SC7->( DBGoTo( (cAliasSC7)->(SC7RECNO) ) )
		Aadd(aItemPC   , AllTrim(SC7->C7_OBSM   )                                               )

		/** =================================================================================================================================== **/
		/** =============================================== ITEM - ESPACO DISPONIVEL NA PAGINA ================================================ **/
		/** =================================================================================================================================== **/
		oFont      := oFontItem // Qtd.Linhas.Item * ( Alt.Font. + Espacamento.de.Linha )
		nTamVItem  := (Len(aItemPC) - 14) * (oFont:nHeight + nSpaceLine)
		nRow       := nLine + nTamVItem
		If nRow > oBoxItems[ATT_TAMV][02]
			lNewPage  := .T.

			/** =================================================================================================================================== **/
			/** =================================== PAGINACAO - NOVA PAGINA, CABECALHO, RODAPE, QUADRO DE ITENS =================================== **/
			/** =================================================================================================================================== **/
			nPageCount := nPageCount + 01
			SecItemTit(@oReport,@lEnd,@aElements,oColumns,@nLine,lNewPage,nPageCount)
			nBoxItems  := AScan(aElements, {|aItem| "BoxItems" $ aItem[01][02]})
			oBoxItems  := aElements[nBoxItems]

			lNewPage   := .F.
		EndIf

		/** =================================================================================================================================== **/
		/** ===================================================== ELEMENTOS DE IMPRESSAO ====================================================== **/
		/** =================================================================================================================================== **/
		/** ========================================================= ITEM - LINHA 01 ========================================================= **/
		For i := 01 To (Len(oColumns))
			nRow    := nLine
			nCol    := oBoxItems[ATT_POSH][02]
			nCol    := nCol              + (nMargin * oColumns[i][02])
			nHeight := NIL
			nAlignH := oColumns[i][06]
			nAlignV := NIL

			nWidth  := (nMargin * oColumns[i][05])
			If oColumns[i][06] == ALIGRIGHT
				nCol   := nCol   - nMargin + 002
			EndIf

			/* FWMsPrinter(): SayAlign ( < nRow>, < nCol>, < cText>, [ oFont], [ nWidth], [ nHeigth], [ nClrText], [ nAlignHorz], [ nAlignVert ] ) */
			// oReport:SayAlign(nRow, nCol, aItemPC[i], oFont, nWidth, nHeight, nClrText, nAlignH, nAlignV)
			cAux    := "Item" + StrZero(nItemCount,4) + "Line01Cell" + StrZero(i,2) + "Page" + StrZero(nPageCount,3)
			cText   := aItemPC[i]
			aUltComp := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
		Next i
		/** ========================================================= ITEM - LINHA 02 ========================================================= **/
		/** = DATA DE ENTREGA ================================================================================================================= **/
		nLine       := nLine + oFont:nHeight + nSpaceLine

		nRow        := nLine
		nCol        := oBoxItems[ATT_POSH][02] + (nMargin * (oColumns[02][02] +07))
		nHeight     := NIL
		nWidth      := MAXBOXH - nCol - nMargin
		nClrText    := NIL
		nAlignH     := ALIGNLEFT
		nAlignV     := NIL
		nItemCol    := Len(oColumns) + 01 // LINHA 02 ITEM - COLUNA 16
		cText       := aItemPC[nItemCol]
		// oReport:SayAlign(nRow, nCol, cText, oFont, nWidth, nHeight, nClrText, nAlignH, nAlignV)
		cAux     := "LineItem" + StrZero(nItemCount,4) + "Line02Cell" + StrZero(nItemCol,2) + "Page" + StrZero(nPageCount,3)
		aUltComp := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)

		/** ===================================================== ITEM - LINHA 03, 04, 05 ===================================================== **/
		/** = OBSERVACOES / DESCRICAO LONGA = LINHA 03, 04 = CAMPO PREENCHIDO ================================================================= **/
		/** = OBSERVACOES DO ITEM = LINHA 05 = CAMPO PREENCHIDO =============================================================================== **/
		/**
		* LINHA 195 CARACTERES LIMITE
		* - CARACTERES MAIUSCULAS E MINUSCULAS
		* - FONT ARIAL 10
		*/
		nLnTamChar := 195
		nTotLnObs  := 000

		//-- PARAMETROS DO OBJETO DA LINHA DE OBSERVACAO
		nCol       := aUltComp[ATT_POSH][02]
		oFont      := oFontItem
		nWidth     := oBoxItems[ATT_TAMH][02] - nCol - nMargin
		nHeight    := NIL
		nClrText   := NIL
		nAlignH    := ALIGNLEFT
		nAlignV    := NIL

		//-- LINHA 03 - "COLUNA" 17 - DESCRICAO LONGA 1 - CAMPO C7_XDESCL1
		//-- LINHA 04 - "COLUNA" 18 - DESCRICAO LONGA 2 - CAMPO C7_XDESCL2
		//-- LINHA 05 - "COLUNA" 19 - OBSERVACAO ITEM   - CAMPO C7_OBSM
		nItemCol   := Len(oColumns) + 02

		While !lEnd .And. nItemCol <= Len(aItemPC)
			cItemObsM  := aItemPC[nItemCol]
			nTotLnObs  := MLCount(cItemObsM, nLnTamChar) // TODO LINHA VAZIA RETORNA > 0 (?)

			//-- LINHA 195 CARACTERES
			For i := 1 To nTotLnObs
				//-- RETORNA LINHA SEM QUEBRAR PALAVRA
				cObsLinha  := MemoLine(cItemObsM, nLnTamChar, i)

				//-- NOVA LINHA DE IMPRESSAO
				nLine      := nLine + nSpaceLine + oFont:nHeight
				nRow       := nLine

				/* oReport:SayAlign(nLine, nCol, cObsLinha, oFont, nWidth, nHeight, nClrText, nAlignH, nAlignV) */
				cAux       := "LineItem" + StrZero(nItemCount,4) + "Cell" + StrZero(nItemCol,2) + "Page" + StrZero(nPageCount,3)
				aUltComp   := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cObsLinha,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV,nClrText)
			Next i

			nItemCol := nItemCol + 01
		EndDo

		/** ===================================================== ITEM - LINHA SEPARADORA ===================================================== **/
		nLine      := nLine + nSpaceLine + oFont:nHeight

		nRow     := nLine
		nCol     := oBoxItems[ATT_POSH][02]
		cAux     := "ItemsLine" + StrZero(nItemCount,4)
		nWidth   := oBoxItems[ATT_TAMH][02]
		nHeight  := nLine
		/** FWMsPrinter(): Line ( < nTop>, < nLeft>, < nBottom>, < nRight>, [ nColor], [ cPixel] ) **/
		// oReport:Line(_nLine, aElements[nItem][05][02], _nLine, aElements[nItem][07][02])
		aUltComp := AAddComponent(oReport,@aElements,cAux,TYPE_LIN,NIL,nRow,nCol,NIL,nWidth,nHeight)

		(cAliasSC7)->(DBSkip())

	EndDo

	aTotals := { aIt_IPI, aIt_ICMSST, aIt_PRUICM, aIt_DESC, aIt_FRETE }
RETURN()


/*
=====================================================================================
Programa.:              SecItemTit
-------------------------------------------------------------------------------------
Parametros:             ExpO1: Objeto grafico de impressao
                        ExpL2: Cancelamento da execucao
                        ExpA3: Relacao de Elementos com as propriedades de impressao
                        ExpO4: Objeto de propriedades dos itens, detalhe
                        ExpL5: Posicao vertical / linha de inicio
                        ExpL6: Quebra de pagina, iniciar em nova pagina
                        ExpN7: Numero da pagina de inclusao dos elementos da secao
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
=====================================================================================
*/
STATIC FUNCTION SecItemTit(oReport,lEnd,aElements,oColumns,nLine,lNewPage,nPageCount)
    LOCAL oBoxItems

	LOCAL nMargin    := 005
	// LOCAL nCellSize  := 005 //-- TAMANHO DA CELULA DE ESPACAMENTO //-- 172 CELULAS
	// LOCAL nSpaceLine := 002

	LOCAL aUltComp

	// LOCAL nCellLeft  := 000
	// LOCAL nCellCount := 000

	LOCAL aItCabL1   := {}
	LOCAL aItCabL2   := {}

	// LOCAL aIt_IPI    := {}
	// LOCAL aIt_ICMSST := {}
	// LOCAL aIt_TOTAL  := {}
	// LOCAL aIt_DESC   := {}
	// LOCAL aIt_FRETE  := {}
	// LOCAL aIt_PRUICM := {}

	LOCAL cAux
	LOCAL nCol
	LOCAL cText
	LOCAL oFontDef   := oFont12:oFont
	// LOCAL oFontItem  := oFont07:oFont
	LOCAL oFont
	LOCAL nWidth
	LOCAL nHeight
	// LOCAL nClrText   := NIL
	LOCAL nAlignH    := ALIGNCENT
	LOCAL nAlignV    := VALIGSUP

	// LOCAL nTamVMinIt := (oFontItem:nHeight * 02) + nSpaceLine // 024 // ITEM SEM COMENTARIOS FONT12
	// LOCAL nTamVItem

	LOCAL nItRef     := 000
	Local i          := 0
	// LOCAL nItemCol   := 000
	// LOCAL nCalcVal   := 000
	// LOCAL nLnTamChar := 195
	// LOCAL nTotLnObs  := 000
	// LOCAL cItemObsM  := ""
	// LOCAL cObsLinha  := ""

	DEFAULT aElements  := {}
	DEFAULT oColumns   := {}
	DEFAULT nLine      := 000 //aElements[nItBoxHead][08][02] + 004
	DEFAULT lNewPage   := .F.
	DEFAULT nPageCount := 001

	If lNewPage
		// oReport:EndPage() //-- QUEBRA DE PAGINA DEVE SER INSERIDA NA LISTAGEM DE ELEMENTOS. PARA CORRETA PAGINACAO E IMPRESSAO
		cAux       := "PageBreak" + PadL(nPageCount,2,"0")
		AAddComponent(oReport,@aElements,cAux,PAGE_END)

		//-- AJUSTAR LINHA DO COMPONENTE REFERENCIA NA CONSTRUCAO DOS ITENS
		nPageCount := ATail(aElements)[13][02] + 01 // nPageCount := oReport:nPageCount

		PrtHeader(@oReport,@aElements)   //-- INICIA NOVA PAGINA E IMPRIME CABECALHO
		PrtFooter(@oReport,@aElements)   //-- IMPRIME RODAPE DA PAGINA, NOVA

		nItRef   := AScanX(aElements, {|aItem| aItem[ATT_NAME][02] == "ReportHeaderBox"}, 10) //-- PESQUISAR NOS ULTIMOS 10 ELEMENTOS
		nLine    := aElements[nItRef][ATT_TAMV][02]
		nLine    := nLine + nMargin
	EndIf

	/** =================================================================================================================================== **/
	/** ===================================================== SECAO - ITENS DO PEDIDO ===================================================== **/
	/** =================================================================================================================================== **/

	/** = BOX - SECTION =================================================================================================================== **/
	/** ========================================================= MOLDURA - QUADRO ======================================================== **/
	nRow      := nLine
	nCol      := INIBOXH
	nWidth    := MAXBOXH
	nHeight   := MAXBOXV
	cAux      := "BoxItems" + "Page" + PadL(nPageCount,2,"0")
	aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_BOX,,nRow,nCol,,nWidth,nHeight)
    oBoxItems := ATail(aElements)

	// /** =================================================================================================================================== **/
	// /** ============================================== COLUNAS - PARAMETROS TAMANHO E POSICAO ============================================= **/
	// /** =================================================================================================================================== **/
	// If Len(oColumns) < 1
	// 	//-- oColumns { nRow, nCol, nHeight, nWidth, nCell, nAlignHorz }
	// 	Aadd(oColumns, {000, (nCellLeft += 000), 006, (nCellCount += 006), 006, ALIGNCENT }) // Item
	// 	Aadd(oColumns, {000, (nCellLeft += 006), 006, (nCellCount += 040), 040, ALIGNLEFT }) // Material/Serviço
	// 	Aadd(oColumns, {000, (nCellLeft += 040), 006, (nCellCount += 007), 007, ALIGNCENT }) // NCM / ISS
	// 	Aadd(oColumns, {000, (nCellLeft += 007), 006, (nCellCount += 010), 010, ALIGRIGHT }) // Quant.
	// 	Aadd(oColumns, {000, (nCellLeft += 010), 006, (nCellCount += 005), 005, ALIGNCENT }) // UM
	// 	Aadd(oColumns, {000, (nCellLeft += 005), 006, (nCellCount += 012), 012, ALIGRIGHT }) // Preço Unit. PIS/COFINS
	// 	Aadd(oColumns, {000, (nCellLeft += 012), 006, (nCellCount += 011), 011, ALIGRIGHT }) // Preço Unit. c/ ICMS
	// 	Aadd(oColumns, {000, (nCellLeft += 011), 006, (nCellCount += 010), 010, ALIGRIGHT }) // Base ICMS
	// 	Aadd(oColumns, {000, (nCellLeft += 010), 006, (nCellCount += 007), 007, ALIGRIGHT }) // % ICMS
	// 	Aadd(oColumns, {000, (nCellLeft += 007), 006, (nCellCount += 011), 011, ALIGRIGHT }) // Valor ICMS
	// 	Aadd(oColumns, {000, (nCellLeft += 011), 006, (nCellCount += 006), 006, ALIGRIGHT }) // % IPI
	// 	Aadd(oColumns, {000, (nCellLeft += 006), 006, (nCellCount += 011), 011, ALIGRIGHT }) // Valor IPI
	// 	Aadd(oColumns, {000, (nCellLeft += 011), 006, (nCellCount += 011), 011, ALIGRIGHT }) // Base ICMSST
	// 	Aadd(oColumns, {000, (nCellLeft += 011), 006, (nCellCount += 010), 010, ALIGRIGHT }) // Valor ICMSST
	// 	Aadd(oColumns, {000, (nCellLeft += 010), 006, (              013), 013, ALIGRIGHT }) // Preço Total c/ ICMS
	// EndIf

	aItCabL1    := {                                                                                                   ;
		"Item"	, "Material/Serviço", "NCM / "	, "Quant."	 , "UM"		, "Preço Unit. ", "Preço Unit. ", "Base ICMS", ;
		"% ICMS", "Valor ICMS"		, "% IPI"	, "Valor IPI", "Base "	, "Valor "		, "Preço Total "               ;
		}
	aItCabL2    := {                                                                                                   ;
		""		, ""				, "ISS"		, ""		 , ""		, "PIS/COFINS"	, "c/ ICMS"		, ""		 , ;
		""		, ""				, ""		, ""		 , "ICMSST"	, "ICMSST"		, "c/ ICMS"                    ;
		}

    For i := 01 To (Len(oColumns))
        If lEnd
            Exit // RETURN()
        EndIf

		/** =================================================================================================================================== **/
		/** ================================================= CABECALHO DOS ITENS - TITULOS =================================================== **/
		/** = COLUNAS - LINHA DIVISORIA ======================================================================================================= **/
		nRow    := oBoxItems[ATT_POSV][02] + (nMargin * oColumns[i][01])
		nCol    := oBoxItems[ATT_POSH][02] + (nMargin * oColumns[i][02])
		nHeight := nRow                    + (nMargin * oColumns[i][03])
		nWidth  := nCol                    + (nMargin * oColumns[i][04])

		If nWidth > oBoxItems[ATT_TAMH][2]
			nWidth := oBoxItems[ATT_TAMH][2]
		EndIf

		cAux    := "ItemsTitleTableLine" + "Page" + PadL(nPageCount,2,"0")
		aUltComp := AAddComponent(oReport,@aElements,cAux,TYPE_LIN,NIL,nRow,nCol,NIL,nWidth,nHeight)

		nLine    := Max(nLine, nHeight)

		//== PARAMETROS COMUM PROXIMOS OBJETOS DAS COLUNAS
		oFont    := oFontDef
		nHeight  := NIL
		nAlignH  := ALIGNCENT
		nAlignV  := VALIGSUP

		/** =================================================================================================================================== **/
		/** ================================================= CABECALHO DOS ITENS - TITULOS =================================================== **/
		/** = COLUNAS - LINHA 001 ============================================================================================================= **/
		nRow     := nRow + 02
		nWidth   := (nMargin * oColumns[i][05])
		cText    := aItCabL1[i]
		cAux     := "ItemsTitleColumn" + PadL(i,2,"0") + "Line01" + "Page" + PadL(nPageCount,2,"0")
		aUltComp := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)

		/** = COLUNAS - LINHA 002 ============================================================================================================= **/
		nRow     := nRow + oFont:nHeight //-- SOMA UMA LINHA - ESCREVER SEGUNDA LINHA
		nRow     := nRow + 02
		cText    := aItCabL2[i]
		cAux     := "ItemsTitleColumn" + PadL(i,2,"0") + "Line02" + "Page" + PadL(nPageCount,2,"0")
		aUltComp := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
		/** =================================================================================================================================== **/
	Next i

// TODO RETURN devolver apenas elementos do cabecalho/titulos
RETURN(aElements)


/*
=====================================================================================
Programa.:              SecTotals
-------------------------------------------------------------------------------------
Parametros:             ExpO1: Objeto grafico de impressao
                        ExpL2: Cancelamento da execucao
                        ExpA3: Relacao de Elementos com as propriedades de impressao
                        ExpO4: Objeto de propriedades dos itens, detalhe
                        ExpA5: Matriz de valores (Impostos, Frete, Despesa, Val.Item)
                        ExpN6: Posicao vertical / linha de inicio
                        ExpL7: Quebra de pagina, iniciar em nova pagina
                        ExpN8: Numero da pagina de inclusao dos elementos da secao
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
=====================================================================================
*/
STATIC FUNCTION SecTotals(oReport,lEnd,aElements,oColumns,aTotals,nLine,lNewPage,nPageCount,aHeader,aCols)
	LOCAL nTotIPI    := 0
	LOCAL nTotICMST  := 0
	LOCAL nTotItems  := 0
	LOCAL nTotDesc   := 0
	LOCAL nTotFrete  := 0
	LOCAL nValTotPC  := 0

	LOCAL nItRef     := 000
    LOCAL aUltComp
    LOCAL oBoxItems
	LOCAL nBoxItems   := AScan(aElements, {|aItem| aItem[01][02] == "BoxItems"})

	LOCAL nMargin    := 004
	LOCAL nCellSize  := 005 //-- TAMANHO DA CELULA DE ESPACAMENTO //-- 172 CELULAS
	LOCAL nSpaceLine := 002
	// LOCAL nColPerLin := 003 //-- QUANTIDADE DE QUADROS TOTALIZADORES NA LINHA
	LOCAL nTamBoxTot := 045 //-- TAMANHO DA CAIXA DO TOTALIZADOR (CELULAS DE ESPACAMENTO)
	LOCAL nBoxSpace  := (nCellSize * 008)

	LOCAL nBoxVSize  := 123

    LOCAL oFontLabel := oFont14N:oFont
    LOCAL oFontValue := oFont14:oFont

	LOCAL cAux
	LOCAL nCol
	LOCAL cText
	LOCAL oFont      := oFontValue
	LOCAL nWidth
	LOCAL nHeight
	LOCAL nClrText
	LOCAL nAlignH    := ALIGNLEFT
	LOCAL nAlignV    := VALIGSUP
	
	LOCAL cMoedaSimb

	LOCAL oSecTotals := {}

	/** MATA120 **/
	LOCAL aValores   := {}
	LOCAL aRefImpos  := MaFisRelImp('MT100',{"SC7"})

	LOCAL nOpcX      := 2 //-- VISUALIZACAO
	LOCAL cAliasC7   := "SC7"
	LOCAL nOrderC7   := 1
	Local nX	     := 0
	Local nY	     := 0
	Local i		     := 0

	DEFAULT lNewPage   := .F.
	DEFAULT nLine      := 000
	DEFAULT nPageCount := 000
	DEFAULT aHeader    := {}
	DEFAULT aCols      := {}

	If (cAliasSC7)->C7_MOEDA < 1
		cMoedaSimb := MV_SIMB1
	Else
		cMoedaSimb := &("MV_SIMB" + Str((cAliasSC7)->C7_MOEDA,01))
	EndIf

	/** =================================================================================================================================== **/
	/** ============================================= EXECUTA REFRESH NOS VALORES DE IMPOSTOS ============================================= **/
	/** =================================================================================================================================== **/
	If !lEnd
		If Len(aValores) != 14
			aValores := Array(14)
		EndIf
		If (cAliasSC7)->(EOF())
			(cAliasSC7)->(DBGoTop())
		EndIf

		/** MATA120 ** CALCULA TOTAIS E IMPOSTOS **/
		// MaFisEnd()
		If ! MaFisFound("NF")
			/** =================================================================================================================================== **/
			/** =================================== MONTAGEM DO aHeader E aCols ATRAVES DA FUNCAO FillGetDados ==================================== **/
			/** =================================================================================================================================== **/
			cSeek  := (cAliasSC7)->(C7_FILIAL + C7_NUM)
			cWhile := "SC7->C7_FILIAL+SC7->C7_NUM"
			/** SINTAXE DA FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry,bCriaVar,lUserFields,aYesUsado) **/
			FillGetDados(nOpcX, cAliasC7, nOrderC7,cSeek,{|| &cWhile },,,,,,,.F.,aHeader,aCols)

			//-- CARREGA O CABECALHO DO DOCUMENTO FISCAL NO aNFCab MATXFIS
			MaFisIni((cAliasSC7)->(C7_FORNECE),;                   // 1-Codigo Cliente/Fornecedor
				(cAliasSC7)->(C7_LOJA),;                           // 2-Loja do Cliente/Fornecedor
				"F",;                                              // 3-C:Cliente , F:Fornecedor
				"N",;                                              // 4-Tipo da NF
				Nil,;                                              // 5-Tipo do Cliente/Fornecedor
				aRefImpos,;                                        // 6-Relacao de Impostos que suportados no arquivo
				,;                                                 // 7-Tipo de complemento
				.T.)                                               // 8-Permite Incluir Impostos no Rodape .T./.F.
				                                                   // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
				                                                   // 10-Nome da rotina que esta utilizando a funcao

			For nX := 1 To Len(aCols)                              //-- RODA TODOS OS ITENS DO PEDIDO DE COMPRAS
				MaFisIniLoad(nX,,.T.)                              //-- nX REPRESENTA O ITEM DO aCols LIDO DENTRO DO LACO E ACRESCENTA O ITEM EM BRANCO NO aNFItem MATXFIS
				For nY := 1 To Len(aHeader)                        //-- RODA TODOS OS CAMPOS DO aCols ATRAVES DO aHeader PARA CARREGAR CADA UM PARA O aNFItem
					cValid := AllTrim(UPPER(aHeader[nY][06]))
					cRefCols := MaFisGetRf(cValid)[01]             //-- ARMAZENA A REFERENCIA FISCAL DO CAMPO NA VARIAVEL cRefCols
					If !Empty(cRefCols) .And. MaFisFound("IT",nX)  //-- VERIFICA A EXISTENCIA DO ITEM NO aNFItem DA MATXFIS
						MaFisLoad(cRefCols,aCols[nX][nY],nX)       //-- CARREGA O VALOR DO CAMPO DO aCols PARA A REFERENCIA NO aNFItem DA MATXFIS
					EndIf
				Next nY
				MaFisEndLoad(nX,02)                                //-- ENCERRA A CARGA DO ITEM
			Next nX

		EndIf

		/** =============================================== */
		/** === MATA120.PRX Executa o Refresh do Folder === */
		/** === ExpA1 = Array com os valores do Rodape  === */
		/** =============================================== */
		A120Refresh(@aValores)

		MaFisEnd()
	EndIf

    If nPageCount == 000
        nPageCount := ATail(aElements)[ATT_PAGE][02]
        If lNewPage
            nPageCount := nPageCount + 001
        EndIf
    EndIf

	/** ===================================== SECAO - VALORES TOTAIS DO PEDIDO - TAMANHO E PAGINACAO ====================================== **/
	If nLine > (MAXBOXV - nBoxVSize)
		lNewPage := .T.
	EndIf

	If lNewPage
		PrtFooter(@oReport,@aElements) //-- IMPRIMIR RODAPE DA PAGINA ATUAL

        // oReport:EndPage()   //-- QUEBRA DE PAGINA DEVE SER INSERIDA NA LISTAGEM DE ELEMENTOS. PARA CORRETA PAGINACAO E IMPRESSAO
        cAux       := "PageBreak" + PadL(nPageCount,2,"0")
		AAddComponent(oReport,@aElements,cAux,PAGE_END)

        //-- AJUSTAR LINHA DO COMPONENTE REFERENCIA NA CONSTRUCAO DOS ITENS
		nPageCount := ATail(aElements)[13][02] + 01 // nPageCount := oReport:nPageCount

		PrtHeader(@oReport,@aElements)   //-- INICIA NOVA PAGINA E IMPRIME CABECALHO
		PrtFooter(@oReport,@aElements)   //-- IMPRIME RODAPE DA PAGINA, NOVA

		nItRef   := AScanX(aElements, {|aItem| aItem[ATT_NAME][02] == "ReportHeaderBox"}, 10) //-- PESQUISAR NOS ULTIMOS 10 ELEMENTOS
		nLine    := aElements[nItRef][ATT_TAMV][02]
		nLine    := nLine + nMargin
    EndIf

    /** =================================================================================================================================== **/
	/** ===================================================== SECAO - ITENS DO PEDIDO ===================================================== **/
	/** =================================================================================================================================== **/
    If lNewPage
        /** ========================================================= MOLDURA - QUADRO ======================================================== **/
        nRow      := nLine
        nCol      := INIBOXH
        nWidth    := MAXBOXH
        nHeight   := MAXBOXV
        cAux      := "BoxItems" + "Page" + PadL(nPageCount,2,"0")
        aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_BOX,,nRow,nCol,,nWidth,nHeight)
        nBoxItems := Len(aElements)
        oBoxItems := ATail(aElements)
    Else
        nBoxItems  := AScan(aElements, {|aItem| "BoxItems" $ aItem[01][02] .And. aItem[13][02] == nPageCount})
        oBoxItems  := aElements[nBoxItems]
    EndIf
    Aadd(oSecTotals, oBoxItems)

	/** =================================================================================================================================== **/
	/** ============================================= TOTALIZACAO - VALORES TOTAL DO PEDIDO =============================================== **/
	/** =================================================================================================================================== **/

    /* ------------------------ VALOR TOTAL IPI ------------------------ */
	AScan(aTotals[01], {|nValIPI   | nTotIPI   := nTotIPI   + nValIPI    })

    /* ---------------------- VALOR TOTAL ICMSST ----------------------- */
	AScan(aTotals[02], {|nValICMSST| nTotICMST := nTotICMST + nValICMSST })

    /* ------------------- VALOR TOTAL DOS PRODUTOS -------------------- */
	AScan(aTotals[03], {|nValItem  | nTotItems := nTotItems + nValItem   })

    /* --------------------- VALOR TOTAL DESCONTO ---------------------- */
	AScan(aTotals[04], {|nValDesc  | nTotDesc  := nTotDesc  + nValDesc   })

    /* ----------------------- VALOR TOTAL FRETE ----------------------- */
	AScan(aTotals[05], {|nValFrete | nTotFrete := nTotFrete + nValFrete  })

    // ===================== VALOR TOTAL DO PEDIDO ===================== //
	nValTotPC := nTotItems + nTotIPI + nTotICMST + nTotFrete - nTotDesc


	/** =================================================================================================================================== **/
	/** ======================================== BOX - TOTAIS DO PEDIDO DE COMPRA - LINHA SUPERIOR ======================================== **/
	/** =================================================================================================================================== **/
    // oReport:Line(nLine, aElements[nBoxItems][05][02], nLine, aElements[nBoxItems][07][02])
    //-- TODO: CONFERIR POSICAO ULTIMO ELEMENTO DA PAGINA QUANDO NAO HA QUEBRA DE PAGINA, lNewPage = .F.
    nRow     := nLine
    nCol     := oBoxItems[ATT_POSH][02]
    nHeight  := nRow
    nWidth   := oBoxItems[ATT_TAMH][02]
    cAux     := "BoxItemsTotalsLineTop"
    aUltComp := AAddComponent(oReport,@aElements,cAux,TYPE_LIN,NIL,nRow,nCol,NIL,nWidth,nHeight)
    Aadd(oSecTotals, aUltComp)

	/** =================================================================================================================================== **/
    /** =================================================== TOTAIS DO PEDIDO DE COMPRA ==================================================== **/
	/** =================================================================================================================================== **/
    /** ===================================================== VALOR TOTAL IPI - QUADRO ==================================================== **/
	/** =================================================================================================================================== **/
	// oFont     := oFontLabel
	nLine     := nLine + oFont:nHeight + nSpaceLine

	nRow      := nLine
	nCol      := oBoxItems[ATT_POSH][02] + nBoxSpace //(nCellSize * 008)
	nHeight   := nRow + oFont:nHeight * 003
	nWidth    := nCol + (nTamBoxTot * nCellSize) //(nCellSize * 045)
	nClrText  := Nil
	nAlignH   := ALIGNLEFT
	nAlignV   := Nil

    // oReport:Box(nRow, nCol, nHeight, nWidth)
    cAux      := "BoxTotalsValueIPI"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_BOX,NIL,nRow,nCol,NIL,nWidth,nHeight)
    Aadd(oSecTotals, aUltComp)

	/** =================================================================================================================================== **/
    /** ===================================================== VALOR TOTAL IPI - TEXTO ===================================================== **/
	/** --- TITULO ------------------------------------------------------------------------------------------------------------------------ **/
	/** =================================================================================================================================== **/
	//-- REFERENCIA: PROPRIEDADES ELEMENTO ANTERIOR - QUADRO
	nItRef    := AScan(oSecTotals, {|aItem| aItem[ATT_NAME][02] == "BoxTotalsValueIPI"})
    nRow      := nRow + nSpaceLine
	nCol      := nCol + nMargin
    // oFont     := oFontLabel
    cText     := "Valor total do IPI:"
    nHeight   := Nil
    // nWidth    := oSecTotals[nItRef][ATT_TAMH][02] - oSecTotals[nItRef][ATT_POSH][02] - nMargin
    nWidth    := oSecTotals[nItRef][ATT_TAMH][02] - nCol - nMargin
    // oReport:SayAlign(nRow, nCol, cText, oFont, nTextWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueTitleIPI"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)

    /** --- VALOR - SIMBOLO MOEDA --------------------------------------------------------------------------------------------------------- **/
	//-- REFERENCIA: PROPRIEDADES ELEMENTO ANTERIOR - TITULO
    // nRow      := nRow + (oFont:nHeight *1.2)
    nRow      := nRow + (oFont:nHeight * 1.3)
    // nRow      := oSecTotals[nItRef][ATT_TAMV][02] - oFont:nHeight - nSpaceLine
	// oFont     := oFontValue
	cText     := cMoedaSimb //"R$"
	// oReport:SayAlign(nRow, nCol, cText, oFont, nWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueCurrencyIPI"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)

	//** --- VALOR - TOTAL IPI ------------------------------------------------------------------------------------------------------------- **/
	//-- ALINHAMENTO A DIREITA
	nAlignH   := ALIGRIGHT
	// nItRef    := AScan(aValores[IMPOSTOS], {|aImposto| aImposto[01] == 'IPI'})
	// nTotIPI   := aValores[IMPOSTOS][nItRef][05]
	nTotIPI   := 000
	For i := 1 To Len(aValores[IMPOSTOS])
		If aValores[IMPOSTOS][i][01] == 'IPI'
			nTotIPI   := nTotIPI + aValores[IMPOSTOS][i][05]
		EndIf
	Next i
	cText     := Transform(nTotIPI, "@E 99,999,999.99")
	// oReport:SayAlign(nRow, nCol, cText, oFont, nTextWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueSumIPI"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)


    /** =================================================================================================================================== **/
    /** =================================================== VALOR TOTAL ICMSST - QUADRO =================================================== **/
	/** =================================================================================================================================== **/
	nRow      := nLine
	nItRef    := AScan(oSecTotals, {|aItem| aItem[ATT_NAME][02] == "BoxTotalsValueIPI"})
	// nCol      := nWidth + (nCellSize * 009) //-- REFERENCIA: Box "Valor total do IPI"
	nCol      := oSecTotals[nItRef][ATT_TAMH][02] + (oSecTotals[nItRef][ATT_POSH][02] - oBoxItems[ATT_POSH][02])
    nHeight   := nRow + oFont:nHeight *3
    nWidth    := nCol + (nTamBoxTot * nCellSize) //+ (nCellSize * 045)
    // oFont     := oFontLabel
    //-- ALINHAMENTO A ESQUERDA
	nAlignH   := ALIGNLEFT
    nAlignV   := Nil
    cText     := NIL
    // oReport:Box(nRow, nCol, nHeight, nWidth)
    cAux      := "BoxTotalsValueICMSST"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_BOX,NIL,nRow,nCol,NIL,nWidth,nHeight)
    Aadd(oSecTotals, aUltComp)

	/** --- TITULO ------------------------------------------------------------------------------------------------------------------------ **/
	nRow      := nRow + nSpaceLine // nRow = 391 // *1.1 = 430.1 // nRow *1.01 = 394.91
	nCol      := nCol + nMargin
	cText     := "Valor total ICMSST:"
	nHeight   := Nil
	nWidth    := nWidth - nCol - nMargin
	// oReport:SayAlign(nRow, nCol, cText, oFont, nTextWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueTitleICMSST"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)

    /** --- VALOR - SIMBOLO MOEDA --------------------------------------------------------------------------------------------------------- **/
	//-- REFERENCIA: PROPRIEDADES ELEMENTO ANTERIOR - TITULO
	// nRow      := nRow + (oFont:nHeight *1.2)
    nRow      := nRow + (oFont:nHeight * 1.3)
    // nItRef    := AScan(oSecTotals, {|aItem| aItem[ATT_NAME][02] == "BoxTotalsValueICMSST"})
	// nRow      := oSecTotals[nItRef][ATT_TAMV][02] - oFont:nHeight - nSpaceLine
	// oFont     := oFontValue
	cText     := cMoedaSimb //"R$"
	// oReport:SayAlign(nRow, nCol, cText, oFont, nWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueCurrencyICMSST"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)

    //** --- VALOR - TOTAL ICMSST ---------------------------------------------------------------------------------------------------------- **/
	//-- ALINHAMENTO A DIREITA
	nAlignH   := ALIGRIGHT
	//** aValores[IMPOSTOS] = MaFisRet(,"NF_IMPOSTOS") // TOTAL IMPOSTO ICMS (NAO ST) **/
	/* nItRef := AScan(aValores[IMPOSTOS], {|aImposto| aImposto[01] == 'ICM'})         */
	/* nTotICMST := aValores[IMPOSTOS][nItRef][05]                                     */
	cText     := Transform(nTotICMST, "@E 99,999,999.99")
	// oReport:SayAlign(nRow, nCol, cText, oFont, nTextWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueSumICMSST"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)


    /** =================================================================================================================================== **/
    /** ================================================== VALOR TOTAL PRODUTOS - QUADRO ================================================== **/
	/** =================================================================================================================================== **/
	nRow      := nLine
    nItRef    := AScan(oSecTotals, {|aItem| aItem[ATT_NAME][02] == "BoxTotalsValueICMSST"})
	// nCol      := nWidth + (nCellSize * 009) //-- REFERENCIA: Box "Valor total do ICMSST"
	// nCol      := oSecTotals[nItRef][ATT_TAMH][02] + (oSecTotals[nItRef][ATT_POSH][02] - oBoxItems[ATT_POSH][02])
	nCol      := oSecTotals[nItRef][ATT_TAMH][02] + nBoxSpace
    nHeight   := nRow + oFont:nHeight *3
    nWidth    := nCol + (nTamBoxTot * nCellSize) //+ (nCellSize * 045)
    // oFont     := oFontLabel
    //-- ALINHAMENTO A ESQUERDA
    nAlignH   := ALIGNLEFT
    nAlignV   := Nil
    cText     := NIL
    // oReport:Box(nRow, nCol, nHeight, nWidth)
    cAux      := "BoxTotalsValueProdutos"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_BOX,NIL,nRow,nCol,NIL,nWidth,nHeight)
    Aadd(oSecTotals, aUltComp)

    /** --- TITULO ------------------------------------------------------------------------------------------------------------------------ **/
	nRow      := nRow + nSpaceLine // nRow = 391 // *1.1 = 430.1 // nRow *1.01 = 394.91
	nCol      := nCol + nMargin
    cText     := "Valor total dos produtos:"
	nHeight   := Nil
	nWidth    := nWidth - nCol - nMargin
	// oReport:SayAlign(nRow, nCol, cText, oFont, nTextWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueTitleProdutos"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)

    /** --- VALOR - SIMBOLO MOEDA --------------------------------------------------------------------------------------------------------- **/
	//-- REFERENCIA: PROPRIEDADES ELEMENTO ANTERIOR - TITULO
    // nRow      := nRow + (oFont:nHeight *1.2)
    nRow      := nRow + (oFont:nHeight * 1.3)
    // nItRef    := AScan(oSecTotals, {|aItem| aItem[ATT_NAME][02] == "BoxTotalsValueProdutos"})
	// nRow      := oSecTotals[nItRef][ATT_TAMV][02] - oFont:nHeight - nSpaceLine
	// oFont     := oFontValue
	cText     := cMoedaSimb //"R$"
	// oReport:SayAlign(nRow, nCol, cText, oFont, nWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueCurrencyProdutos"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)

    //** --- VALOR - TOTAL PRODUTOS ------------------------------------------------------------------------------------------------------- **/
	//-- ALINHAMENTO A DIREITA
	nAlignH   := ALIGRIGHT
	nTotItems := aValores[VALMERC]
	cText     := Transform(nTotItems, "@E 99,999,999.99")
	// oReport:SayAlign(nRow, nCol, cText, oFont, nTextWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueSumProdutos"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)


    /** =================================================================================================================================== **/
    /** ================================================== VALOR TOTAL DESCONTO - QUADRO ================================================== **/
	/** =================================================================================================================================== **/
	// oFont     := oFontLabel
    nLine     := nLine + oFont:nHeight + nSpaceLine + (oFont:nHeight *3)

	nRow      := nLine
	nCol      := oBoxItems[ATT_POSH][02] + nBoxSpace //(nCellSize * 008)
	nHeight   := nRow + oFont:nHeight * 003
	nWidth    := nCol + (nTamBoxTot * nCellSize) //(nCellSize * 045)
	nClrText  := Nil
	nAlignH   := ALIGNLEFT
	nAlignV   := Nil

    // oReport:Box(nRow, nCol, nHeight, nWidth)
    cAux      := "BoxTotalsValueDesconto"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_BOX,NIL,nRow,nCol,NIL,nWidth,nHeight)
    Aadd(oSecTotals, aUltComp)

	/** =================================================================================================================================== **/
    /** ================================================== VALOR TOTAL DESCONTO - TEXTO =================================================== **/
	/** --- TITULO ------------------------------------------------------------------------------------------------------------------------ **/
	/** =================================================================================================================================== **/
	//-- REFERENCIA: PROPRIEDADES ELEMENTO ANTERIOR - QUADRO
    nItRef    := AScan(oSecTotals, {|aItem| aItem[ATT_NAME][02] == "BoxTotalsValueDesconto"})
    nRow      := nRow + nSpaceLine
	nCol      := nCol + nMargin
    // oFont     := oFontLabel
    cText     := "Desconto:"
    nHeight   := Nil
    // nWidth    := nWidth - nCol - nMargin
    nWidth    := oSecTotals[nItRef][ATT_TAMH][02] - nCol - nMargin
    // oReport:SayAlign(nRow, nCol, cText, oFont, nTextWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueTitleDesconto"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, oBoxItems)

    /** --- VALOR - SIMBOLO MOEDA --------------------------------------------------------------------------------------------------------- **/
	//-- REFERENCIA: PROPRIEDADES ELEMENTO ANTERIOR - TITULO
    // nRow      := nRow + (oFont:nHeight *1.2)
    nRow      := nRow + (oFont:nHeight * 1.3)
    // nItRef    := AScan(oSecTotals, {|aItem| aItem[ATT_NAME][02] == "BoxTotalsValueDesconto"})
	// nRow      := oSecTotals[nItRef][ATT_TAMV][02] - oFont:nHeight - nSpaceLine
	// oFont     := oFontValue
	cText     := cMoedaSimb //"R$"
	// oReport:SayAlign(nRow, nCol, cText, oFont, nWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueCurrencyDesconto"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, oBoxItems)

	//** --- VALOR - TOTAL DESCONTO -------------------------------------------------------------------------------------------------------- **/
	//-- ALINHAMENTO A DIREITA
	nAlignH   := ALIGRIGHT
	nTotDesc  := aValores[VALDESC]
	cText     := Transform(nTotDesc, "@E 99,999,999.99")
	// oReport:SayAlign(nRow, nCol, cText, oFont, nTextWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueSumDesconto"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, oBoxItems)


    /** =================================================================================================================================== **/
    /** ==================================================== VALOR TOTAL FRETE - QUADRO =================================================== **/
	/** =================================================================================================================================== **/
	nRow      := nLine
    nItRef    := AScan(oSecTotals, {|aItem| aItem[ATT_NAME][02] == "BoxTotalsValueDesconto"})
	// nCol      := nWidth + (nCellSize * 009) //-- REFERENCIA: Box "Valor total do Desconto"
	nCol      := oSecTotals[nItRef][ATT_TAMH][02] + (oSecTotals[nItRef][ATT_POSH][02] - oBoxItems[ATT_POSH][02])
    nHeight   := nRow + oFont:nHeight *3
    nWidth    := nCol + (nTamBoxTot * nCellSize) //+ (nCellSize * 045)
    // oFont     := oFontLabel
    //-- ALINHAMENTO A ESQUERDA
	nAlignH   := ALIGNLEFT
    nAlignV   := Nil
    cText     := NIL
    // oReport:Box(nRow, nCol, nHeight, nWidth)
    cAux      := "BoxTotalsValueFrete"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_BOX,NIL,nRow,nCol,NIL,nWidth,nHeight)
    Aadd(oSecTotals, aUltComp)

	/** --- TITULO ------------------------------------------------------------------------------------------------------------------------ **/
	nRow      := nRow + nSpaceLine // nRow = 391 // *1.1 = 430.1 // nRow *1.01 = 394.91
	nCol      := nCol + nMargin
	cText     := "Frete:"
	nHeight   := Nil
	nWidth    := nWidth - nCol - nMargin
	// oReport:SayAlign(nRow, nCol, cText, oFont, nTextWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueTitleFrete"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)

    /** --- VALOR - SIMBOLO MOEDA --------------------------------------------------------------------------------------------------------- **/
	//-- REFERENCIA: PROPRIEDADES ELEMENTO ANTERIOR - TITULO
    // nRow      := nRow + (oFont:nHeight *1.2)
    nRow      := nRow + (oFont:nHeight * 1.3)
    // nItRef    := AScan(oSecTotals, {|aItem| aItem[ATT_NAME][02] == "BoxTotalsValueFrete"})
	// nRow      := oSecTotals[nItRef][ATT_TAMV][02] - oFont:nHeight - nSpaceLine
	// oFont     := oFontValue
	cText     := cMoedaSimb //"R$"
	// oReport:SayAlign(nRow, nCol, cText, oFont, nWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueCurrencyFrete"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)

    //** --- VALOR - TOTAL FRETE ----------------------------------------------------------------------------------------------------------- **/
	//-- ALINHAMENTO A DIREITA
	nAlignH   := ALIGRIGHT
	nTotFrete := aValores[FRETE]
	cText     := Transform(nTotFrete, "@E 99,999,999.99")
	// oReport:SayAlign(nRow, nCol, cText, oFont, nTextWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueSumFrete"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)


    /** =================================================================================================================================== **/
    /** =================================================== VALOR TOTAL PEDIDO - QUADRO =================================================== **/
	/** =================================================================================================================================== **/
	nRow      := nLine
    nItRef    := AScan(oSecTotals, {|aItem| aItem[ATT_NAME][02] == "BoxTotalsValueFrete"})
	// nCol      := nWidth + (nCellSize * 009) //-- REFERENCIA: Box "Valor total do Frete"
	// nCol      := oSecTotals[nItRef][ATT_TAMH][02] + (oSecTotals[nItRef][ATT_POSH][02] - aUltComp[ATT_POSH][02])
    nCol      := oSecTotals[nItRef][ATT_TAMH][02] + nBoxSpace
    nHeight   := nRow + oFont:nHeight *3
    nWidth    := nCol + (nTamBoxTot * nCellSize) //+ (nCellSize * 045)
    oFont     := oFontLabel
    //-- ALINHAMENTO A ESQUERDA
    nAlignH   := ALIGNLEFT
    nAlignV   := Nil
    cText     := NIL
    // oReport:Box(nRow, nCol, nHeight, nWidth)
    cAux      := "BoxTotalsValuePedido"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_BOX,NIL,nRow,nCol,NIL,nWidth,nHeight)
    Aadd(oSecTotals, aUltComp)

    /** --- TITULO ------------------------------------------------------------------------------------------------------------------------ **/
	nRow      := nRow + nSpaceLine // nRow = 391 // *1.1 = 430.1 // nRow *1.01 = 394.91
	nCol      := nCol + nMargin
    oFont     := oFontLabel
    cText     := "Valor total do pedido:"
	nHeight   := Nil
	nWidth    := nWidth - nCol - nMargin
	// oReport:SayAlign(nRow, nCol, cText, oFont, nTextWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueTitlePedido"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)

    /** --- VALOR - SIMBOLO MOEDA --------------------------------------------------------------------------------------------------------- **/
	//-- REFERENCIA: PROPRIEDADES ELEMENTO ANTERIOR - TITULO
    // nRow      := nRow + (oFont:nHeight *1.2)
	oFont     := oFontLabel
    nRow      := nRow + (oFont:nHeight * 1.3)
    // nItRef    := AScan(oSecTotals, {|aItem| aItem[ATT_NAME][02] == "BoxTotalsValuePedido"})
	// nRow      := oSecTotals[nItRef][ATT_TAMV][02] - oFont:nHeight - nSpaceLine
	cText     := cMoedaSimb //"R$"
	// oReport:SayAlign(nRow, nCol, cText, oFont, nWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueCurrencyPedido"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)

    //** --- VALOR - TOTAL PEDIDO --------------------------------------------------------------------------------------------------------- **/
	//-- ALINHAMENTO A DIREITA
	nAlignH   := ALIGRIGHT
	oFont     := oFontLabel
	nTotItems := aValores[TOTPED]
	cText     := Transform(nTotItems, "@E 99,999,999.99")
	// oReport:SayAlign(nRow, nCol, cText, oFont, nTextWidth, nHeight, nClrText, nAlignH, nAlignV)
    cAux      := "TotalsValueSumPedido"
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTotals, aUltComp)


	/** =================================================================================================================================== **/
    /** ===================================================== ITEM - LINHA SEPARADORA ===================================================== **/
	/** =================================================================================================================================== **/
	//-- NOVA LINHA DE IMPRESSAO
	oFont     := oFontLabel
	nLine     := nLine + oFont:nHeight + nSpaceLine + (oFont:nHeight * 003)
	oFont     := NIL

	//-- TODO: VERIFICAR ESPACO DISPONIVEL NA PAGINA, CRIAR NOVA PAGINA

	/** FWMsPrinter(): Line ( < nTop>, < nLeft>, < nBottom>, < nRight>, [ nColor], [ cPixel] ) **/
	// oReport:Line(nLine, aElements[nItem][05][02], nLine, aElements[nItem][07][02])

	nRow     := nLine
    nCol     := oBoxItems[ATT_POSH][02]
    nHeight  := nRow
    nWidth   := oBoxItems[ATT_TAMH][02]
    cAux     := "BoxItemsTotalsLineBottom"
    aUltComp := AAddComponent(oReport,@aElements,cAux,TYPE_LIN,NIL,nRow,nCol,NIL,nWidth,nHeight)
	Aadd(oSecTotals, aUltComp)

RETURN(oSecTotals)


/*
=====================================================================================
Programa.:              SecObsPC
-------------------------------------------------------------------------------------
Parametros:             ExpO1: Objeto grafico de impressao
                        ExpL2: Cancelamento da execucao
                        ExpA3: Relacao de Elementos com as propriedades de impressao
                        ExpN4: Posicao vertical / linha de inicio
                        ExpL5: Quebra de pagina, iniciar em nova pagina
                        ExpN6: Numero da pagina de inclusao dos elementos da secao
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
=====================================================================================
*/
STATIC FUNCTION SecObsPC(oReport,lEnd,aElements,nLine,lNewPage,nPageCount)
	LOCAL oBoxObsPC
	LOCAL oSecObsPC  := {}

	LOCAL nMargin    := 005
	// LOCAL nCellSize  := 005 //-- TAMANHO DA CELULA DE ESPACAMENTO //-- 172 CELULAS
	LOCAL nSpaceLine := 002

	LOCAL aUltComp

	LOCAL cAux
	LOCAL nCol
	LOCAL cText
	LOCAL oFont
	LOCAL nWidth
	LOCAL nHeight
	LOCAL nClrText   := NIL
	LOCAL nAlignH    := ALIGNCENT
	LOCAL nAlignV    := VALIGSUP

	LOCAL nTamVMin

	LOCAL nItRef     := 000
	
	LOCAL cItemObsM
	LOCAL nTotLnObs
	LOCAL cObsLinha

	LOCAL nLnTamChar := 195
	Local i          := 0

	DEFAULT aElements  := {}
	DEFAULT nLine      := 000 //aElements[nItBoxHead][08][02] + 004
	DEFAULT lNewPage   := .F.
	DEFAULT nPageCount := 001

	If lNewPage
		// oReport:EndPage() //-- QUEBRA DE PAGINA DEVE SER INSERIDA NA LISTAGEM DE ELEMENTOS. PARA CORRETA PAGINACAO E IMPRESSAO
		cAux       := "PageBreak" + PadL(nPageCount,2,"0")
		AAddComponent(oReport,@aElements,cAux,PAGE_END)

		//-- AJUSTAR LINHA DO COMPONENTE REFERENCIA NA CONSTRUCAO DOS ITENS
		nPageCount := ATail(aElements)[13][02] + 01 // nPageCount := oReport:nPageCount

		PrtHeader(@oReport,@aElements)   //-- INICIA NOVA PAGINA E IMPRIME CABECALHO
		PrtFooter(@oReport,@aElements)   //-- IMPRIME RODAPE DA PAGINA, NOVA

		nItRef   := AScanX(aElements, {|aItem| aItem[ATT_NAME][02] == "ReportHeaderBox"}, 10) //-- PESQUISAR NOS ULTIMOS 10 ELEMENTOS
		nLine    := aElements[nItRef][ATT_TAMV][02]
		nLine    := nLine + nMargin
	EndIf

	/** =================================================================================================================================== **/
	/** ================================================== SECAO - OBSERVACOES DO PEDIDO ================================================== **/
	/** =================================================================================================================================== **/

    /** === CONFERIR SE EXISTE ESPACO PARA INCLUSAO DA SECAO COM UMA LINHA MINIMA === **/
    nTamVMin  := (oFont14N:oFont:nHeight * 1.2) + (+ oFont12:oFont:nHeight * 1.2 * 01 + nSpaceLine)
    If (nLine + nTamVMin) > MAXBOXV
        nLine     := NIL
        lNewPage  := .T.
		oSecObsPC := SecObsPC(@oReport,@lEnd,@aElements,nLine,lNewPage)
		
		RETURN(oSecObsPC)
    EndIf

	If lNewPage
		/** = BOX - SECTION =================================================================================================================== **/
		/** ========================================================= MOLDURA - QUADRO ======================================================== **/
		nRow      := nLine
		nCol      := INIBOXH
		nWidth    := MAXBOXH
		nHeight   := MAXBOXV
		cAux      := "BoxObsPC"
		aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_BOX,NIL,nRow,nCol,NIL,nWidth,nHeight)
		oBoxObsPC := ATail(aElements)
	Else
		nItRef    := AScan(aElements, {|aItem| "BoxItems" $ aItem[ATT_NAME][02] .And. aItem[ATT_PAGE][02] == nPageCount})
		oBoxObsPC := Aclone(aElements[nItRef])
		oBoxObsPC[ATT_POSV][02] := nLine
	EndIf
	Aadd(oSecObsPC, oBoxObsPC)

    nLine    := oBoxObsPC[ATT_POSV][02]
	/** = BOX - OBSERVACOES PEDIDO ======================================================================================================== **/
	/** ==================================================== MOLDURA CABECALHO - QUADRO =================================================== **/
	nRow     := nLine //+ nMargin
	nCol     := INIBOXH
	oFont    := oFont14N:oFont
	nWidth   := MAXBOXH
	nHeight  := nRow + oFont:nHeight * 1.2
	aUltComp := AAddComponent(oReport,@aElements,"BoxHeaderObsPC",TYPE_BOX,,nRow,nCol,oFont,nWidth,nHeight)
	Aadd(oSecObsPC, aUltComp)

    /** = BOX - OBSERVACOES PEDIDO ======================================================================================================== **/
	/** ============================================================= TITULO ============================================================== **/
    cText    := "Observações Gerais"
    nRow     := aUltComp[ATT_POSV][02] + nSpaceLine
    nCol     := aUltComp[ATT_POSH][02]
    oFont    := oFont12N:oFont
    nWidth   := aUltComp[ATT_TAMH][02]
    nHeight  := nRow + oFont:nHeight *1.2
    nAlignH  := ALIGNCENT
    nAlignV  := VALIGCENT
	aUltComp := AAddComponent(oReport,@aElements,"BoxHeaderObsPCTitle",TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV,nClrText)
	Aadd(oSecObsPC, aUltComp)

    /** = BOX - OBSERVACOES PEDIDO ======================================================================================================== **/
	/** ====================================================== MOLDURA DETALHES - QUADRO ================================================== **/
	nItRef   := AScanX(aElements, {|aItem| aItem[ATT_NAME][02] == "BoxHeaderObsPC"}, 10)
	nRow     := aElements[nItRef][ATT_TAMV][02]
	nCol     := oBoxObsPC[ATT_POSH][02]
	oFont    := oFont12:oFont
	nWidth   := oBoxObsPC[ATT_TAMH][02]
	nHeight  := oBoxObsPC[ATT_TAMV][02]
	aUltComp := AAddComponent(oReport,@aElements,"DetailBoxObsPC",TYPE_BOX,,nRow,nCol,oFont,nWidth,nHeight)
	Aadd(oSecObsPC, aUltComp)

	/** ============================================ OBSERVACOES PEDIDO DE COMPRA - TABELA SZV ============================================ **/
	/** = OBSERVACOES PEDIDO - CONFIGURACAO PADRAO DE IMPRESSAO DA LINHA ================================================================== **/
	nLine      := nLine + nMargin
	nCol       := oBoxObsPC[ATT_POSH][02] + nMargin
	nWidth     := oBoxObsPC[ATT_TAMH][02]
	nAlignH    := ALIGNLEFT
	nAlignV    := NIL // VALIGSUP
	nClrText   := NIL

	If !lEnd
		cItemObsM  := AllTrim( (cAliasSZV)->OBSGRPC )
		nTotLnObs  := MLCount(cItemObsM, nLnTamChar) // TODO LINHA VAZIA RETORNA > 0 (?)

		//-- LINHA 195 CARACTERES
		For i := 1 To nTotLnObs
			//-- RETORNA LINHA SEM QUEBRAR PALAVRA
			cObsLinha  := MemoLine(cItemObsM, nLnTamChar, i)

			//-- NOVA LINHA DE IMPRESSAO
			nLine      := nLine + nSpaceLine + oFont:nHeight
			nRow       := nLine

			/* oReport:SayAlign(nLine, nCol, cObsLinha, oFont, nWidth, nHeight, nClrText, nAlignH, nAlignV) */
			cAux       := "LineObs" + PadL(i,2,"0")
			// aUltComp   := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cObsLinha,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV,nClrText)
			aUltComp   := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cObsLinha,nRow,nCol,oFont,nWidth)
			
			Aadd(oSecObsPC, aUltComp)
		Next i
	EndIf

RETURN(oSecObsPC)


/*
=====================================================================================
Programa.:              PrtFooter
-------------------------------------------------------------------------------------
Parametros:             ExpO1: Objeto grafico de impressao
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
-------------------------------------------------------------------------------------
Descricao:              Numero de registro do modelo homologado na ISO do formulario
=====================================================================================
*/
STATIC FUNCTION PrtHeader(oReport, aElements)
	LOCAL nLine
	LOCAL nMargin

	LOCAL cText
	LOCAL nRow
	LOCAL nCol
	LOCAL oFont
	LOCAL nWidth
	LOCAL nHeight
	// LOCAL nClrText
	LOCAL nAlignH
	LOCAL nAlignV
	// LOCAL nAngle

	LOCAL aUltComp

	// LOCAL cPictCabec

	LOCAL xReportPage

	// oReport:StartPage() //-- QUEBRA DE PAGINA DEVE SER INSERIDA NA LISTAGEM DE ELEMENTOS. PARA CORRETA PAGINACAO E IMPRESSAO

	If ValType(aElements) == "A" .AND. Len(aElements) > 0
		xReportPage := MAX( aElements[01][ATT_PAGE][02], ATail(aElements)[ATT_PAGE][02] )
	Else
		xReportPage := 001
	EndIf

	// cPictCabec := "LGRL" + FWGrpCompany() + ".BMP"
	nLine      := 000   // INIBOXV
	nMargin    := 002
	nRow       := nLine

	/** = BOX - HEADER ==================================================================================================================== **/
	/** ============================================== MOLDURA CABECALHO - QUADRO ========================================================= **/
	cText    := NIL
	nCol     := INIBOXH
	nWidth   := MAXBOXH
	nHeight  := oFont22N:oFont:nHeight *1.2
	aUltComp := AAddComponent(xReportPage,@aElements,"ReportHeaderBox",TYPE_BOX,cText,nRow,nCol,,nWidth,nHeight) // NIL == ,nClrText,nAlignH,nAlignV,nAngle

	/** = BOX - HEADER ==================================================================================================================== **/
	/** ============================================ LOGOMARCA DA EMPRESA DO PEDIDO ======================================================= **/
	cText    := cPictCabec                                          // 075 x 028
	nRow     := nRow + nMargin
	nCol     := nCol + nMargin
	nHeight  := aUltComp[ATT_TAMV][02] - (nMargin * 2)               // 021 => 028%
	nWidth   := (nHeight * 100) / 28                                // 075 => 100%
	aUltComp := AAddComponent(xReportPage,@aElements,"ReportImage",TYPE_IMG,cText,nRow,nCol,,nWidth,nHeight)

	/** = BOX - HEADER ==================================================================================================================== **/
	/** ============================================================= TITULO ============================================================== **/
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "ReportHeaderBox"})
	cText    := "PEDIDO DE COMPRA Nº:" + Space(1)
	cText    := cText + (cAliasSC7)->(C7_NUM)
	nRow     := aElements[nItRef][ATT_POSV][02] + nMargin
	nCol     := aElements[nItRef][ATT_POSH][02]
	oFont    := oFont18N:oFont
	nWidth   := aElements[nItRef][ATT_TAMH][02]
	nHeight  := aElements[nItRef][ATT_TAMV][02]
	nAlignH  := ALIGNCENT
	nAlignV  := VALIGCENT
	aUltComp := AAddComponent(xReportPage,@aElements,"ReportTitle",TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)

	/** = BOX - HEADER ==================================================================================================================== **/
	/** ============================================================ PAGINACAO ============================================================ **/
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "ReportHeaderBox"})
	cText    := {|nPage,nPages| "Página:" + Space(1) + PadL(nPage ,2,"0") + Space(1) + "/" + ;
	                                        Space(1) + PadL(nPages,2,"0")}
	nRow     := aElements[nItRef][ATT_POSV][02] + nMargin
	nCol     := aElements[nItRef][ATT_POSH][02]
	oFont    := oFont12:oFont
	nWidth   := aElements[nItRef][ATT_TAMH][02] - aElements[nItRef][ATT_POSH][02] - nMargin
	nAlignH  := ALIGRIGHT
	aUltComp := AAddComponent(xReportPage,@aElements,"HeaderPagenation",TYPE_TXT,cText,nRow,nCol,oFont,nWidth,,nAlignH)

	/** = BOX - HEADER ==================================================================================================================== **/
	/** =========================================================== DATA EMISSAO ========================================================== **/
	nItRef   := AScan(aElements, {|aItem| aItem[ATT_NAME][02] == "HeaderPagenation"})
	cText    := "Data Emissão:" + Space(1)
	cText    := cText + DtoC((cAliasSC7)->(C7_EMISSAO))
	cText    := Replace( cText , "/", ".")
	nRow     := aElements[nItRef][ATT_POSV][02] + aElements[nItRef][ATT_FONT][02]:nHeight + nMargin //oFont12:oFont:nHeight
	nCol     := aElements[nItRef][ATT_POSH][02]
	oFont    := aElements[nItRef][ATT_FONT][02] //oFont12:oFont
	nWidth   := aElements[nItRef][ATT_TAMH][02] // - nMargin
	nAlignH  := ALIGRIGHT
	aUltComp := AAddComponent(xReportPage,@aElements,"HeaderIssueDate",TYPE_TXT,cText,nRow,nCol,oFont,nWidth,,nAlignH)

RETURN(.T.)


/*
=====================================================================================
Programa.:              PrtFooter
-------------------------------------------------------------------------------------
Parametros:             ExpO1: Objeto grafico de impressao
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
-------------------------------------------------------------------------------------
Descricao:              Numero de registro do modelo homologado na ISO do formulario
=====================================================================================
*/
STATIC FUNCTION PrtFooter(oReport,aElements)
	LOCAL oFont := oFont07:oFont
	// ISO REGISTER "F0764701"

	AAddComponent(oReport, @aElements, "ReportFooterISORegister", TYPE_TXT, DOCSPEC, MAXBOXV, INIBOXH, oFont, MAXBOXH, (MAXBOXV + oFont:nHeight))
RETURN(.T.)


/*
=====================================================================================
Programa.:              AAddComponent
-------------------------------------------------------------------------------------
Parametros:             ExpX1: Objeto grafico de impressao / Numero da pagina
						ExpA2: Relacao de Elementos com as propriedades de impressao
						ExpC3: Nome identificador do elemento grafico no relatorio
						ExpC4: Tipo do elemento grafico (BOX, SAY, LINE, ...)
						ExpC5: Texto contido no elemento (SAY, SAYALIGN)
						ExpN6: Posição vertical / linha do elemento na pagina
						ExpN7: Posição horizontal / coluna do elemento na pagina
						ExpO8: Objeto TFont formatacao do texto
						ExpN9: Posição vertical final / largura do elemento
						ExpN10: Posição horizontal final / altura do elemento
						ExpN11: Alinhamento horizontal do texto (esq., dir., centr.)
						ExpN12: Alinhamento vertical do texto (topo, meio, baixo)
						ExpC13: Cor do elemento grafico (CLR_BLACK, CLR_HRED)
						ExpN14: Angulo de rotacao do elemento
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
-------------------------------------------------------------------------------------
Descricao:              Numero de registro do modelo homologado na ISO do formulario
=====================================================================================
*/
STATIC FUNCTION AAddComponent(xReportPage,aElements,cCompName,cType,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV,nClrText,nAngle)
	LOCAL aObjetoRpt := {}
	LOCAL nPageCount := IIF(ValType(xReportPage)=="O",001,xReportPage)

	Aadd(aObjetoRpt , {"componentName" , cCompName  }) // 01
	Aadd(aObjetoRpt , {"componentType" , cType      }) // 02
	Aadd(aObjetoRpt , {"cText"         , cText      }) // 03
	Aadd(aObjetoRpt , {"nRow"          , nRow       }) // 04
	Aadd(aObjetoRpt , {"nCol"          , nCol       }) // 05
	Aadd(aObjetoRpt , {"oFont"         , oFont      }) // 06
	Aadd(aObjetoRpt , {"nWidth"        , nWidth     }) // 07
	Aadd(aObjetoRpt , {"nHeight"       , nHeight    }) // 08
	Aadd(aObjetoRpt , {"nClrText"      , nClrText   }) // 09
	Aadd(aObjetoRpt , {"nAlignHorz"    , nAlignH    }) // 10
	Aadd(aObjetoRpt , {"nAlignVert"    , nAlignV    }) // 11
	Aadd(aObjetoRpt , {"nAngle"        , nAngle     }) // 12
	Aadd(aObjetoRpt , {"nPageCount"    , nPageCount }) // 13

	Aadd(aElements , aObjetoRpt)

RETURN(ATail(aElements))

/*
=====================================================================================
Programa.:              PrtTermsPC
-------------------------------------------------------------------------------------
Parametros:             ExpO1: Objeto grafico de impressao
                        ExpL2: Cancelamento da execucao
                        ExpA3: Relacao de Elementos com as propriedades de impressao
                        ExpN4: Numero da pagina de inclusao dos elementos da secao
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
-------------------------------------------------------------------------------------
Descricao:              Texto longo multilinhas com Termos e Condicoes da Compra
=====================================================================================
*/
STATIC FUNCTION PrtTermsPC(oReport,lEnd,aElements,nPageCount)
	LOCAL nLine       := 000
	LOCAL mTermsPC    := ""
	LOCAL nItRef
	LOCAL xAux
	LOCAL cAux
	LOCAL cParC7Num   := " "

	LOCAL lPrintTerms := .F.

	LOCAL nMargin     := 005
	LOCAL nSpaceLine  := 002

	LOCAL mTerms
    LOCAL nLineSize   := 204 // 243
    LOCAL oFontTitle  := oFont14N:oFont
    LOCAL oFontBold   := oFont10N:oFont
    LOCAL oFontTerms  := oFont10:oFont
	LOCAL nNumLnObs
	LOCAL nCountLine

	LOCAL nCol
	LOCAL cText
	LOCAL oFont
	LOCAL nWidth
	LOCAL nHeight
	LOCAL nClrText
	LOCAL nAlignH
	LOCAL nAlignV

	LOCAL lColored    := .F.
    LOCAL lTxtBold    := .F.

    LOCAL nTxtSizeV
    LOCAL nMaxLines

    LOCAL oBoxTerms   := {}
    LOCAL oSecTerms   := {}

    DEFAULT nPageCount := 000


    If lEnd
        RETURN {{}}
    EndIf


    /** === PAGINACAO - AJUSTE DE NUMERACAO - INICIO EM NOVA PAGINA A PARTIR DO ULTIMO ELEMENTO INSERIDO ================================== **/
	If nPageCount == 000
        nPageCount := ATail(aElements)[ATT_PAGE][02]
        nPageCount := nPageCount + 001
    EndIf

	/** === PARAMETROS ${CODIGO} - PREPARAR VALORES PARA SUBSTITUICAO NO TEXTO ============================================================ **/
	nItRef  := AScan(aElements, {|aElem| aElem[ATT_NAME][02] == "ReportTitle"})
	If nItRef > 0
		xAux   := Len(aElements[nItRef][ATT_TEXT][02]) - TamSX3("C7_NUM")[1] + 01
		cParC7Num := SubStr(aElements[nItRef][ATT_TEXT][02], xAux)
	EndIf
	

    /** =================================================================================================================================== **/
	/** ======================================== TERMOS E CONDICOES DE COMPRAS - TEXTO CADASTRADO ========================================= **/
	/** =================================================================================================================================== **/
    /** === FORMULAS - CONSULTA TEXTO EM CAMPO MEMO PERSONALIZADO NO CADASTRO DE FORMULAS ================================================= **/
	xAux       := Posicione("SM4", 01, xFilial("SM4")+"T"+cEmpAnt, "M4_FORMULA")   // 01 - M4_FILIAL+M4_CODIGO
	xAux       := &(xAux)
	If ValType(xAux) == "L"
		lPrintTerms := xAux
	EndIf
	If lPrintTerms
		mTermsPC    := Posicione("SM4", 01, xFilial("SM4")+"T"+cEmpAnt, "M4_XMSG") // 01 - M4_FILIAL+M4_CODIGO
	EndIf


    /** =================================================================================================================================== **/
	/** ======================================== TERMOS E CONDICOES DE COMPRAS - QUEBRA DE PAGINA ========================================= **/
	/** =================================================================================================================================== **/
    cAux     := "PageBreak" + PadL(nPageCount,2,"0")
    AAddComponent(oReport,@aElements,cAux,PAGE_END)

    //-- AJUSTAR LINHA DO COMPONENTE REFERENCIA NA CONSTRUCAO DOS ITENS
    nPageCount := ATail(aElements)[13][02] + 01 // nPageCount := oReport:nPageCount

    PrtHeader(@oReport,@aElements)   //-- INICIA NOVA PAGINA E IMPRIME CABECALHO
    PrtFooter(@oReport,@aElements)   //-- IMPRIME RODAPE DA PAGINA, NOVA

    nItRef   := AScanX(aElements, {|aItem| aItem[ATT_NAME][02] == "ReportHeaderBox"}, 10) //-- PESQUISAR NOS ULTIMOS 10 ELEMENTOS
    nLine    := aElements[nItRef][ATT_TAMV][02]
    nLine    := nLine + nMargin


	/** =================================================================================================================================== **/
	/** ========================================= SECAO - TERMOS E CONDICOES DE COMPRAS - QUADRO ========================================== **/
    /** =================================================================================================================================== **/
    nRow      := nLine
    nCol      := INIBOXH
    nWidth    := MAXBOXH
    nHeight   := MAXBOXV
    cAux      := "BoxTerms" + "Page" + PadL(nPageCount,2,"0")
    aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_BOX,,nRow,nCol,,nWidth,nHeight)
    oBoxTerms := ATail(aElements)
    Aadd(oSecTerms, aUltComp)


	/** =================================================================================================================================== **/
	/** =========================================== TERMOS E CONDICOES DE COMPRAS - BOX TITULO ============================================ **/
	/** =================================================================================================================================== **/
	oFont    := oFontTitle

	nRow     := nLine
	nCol     := oBoxTerms[ATT_POSH][02]
	nHeight  := nLine + oFont:nHeight * 1.2
	nWidth   := oBoxTerms[ATT_TAMH][02]
	nClrText := Nil
	nAlignH  := Nil
	nAlignV  := Nil

    cAux     := "TermsTitleBox" + "Page" + PadL(nPageCount,2,"0")
    aUltComp := AAddComponent(oReport,@aElements,cAux,TYPE_BOX,NIL,nRow,nCol,NIL,nWidth,nHeight)
    Aadd(oSecTerms, aUltComp)


	/** =================================================================================================================================== **/
	/** ============================================= TERMOS E CONDICOES DE COMPRAS - TITULO ============================================== **/
	/** =================================================================================================================================== **/
	oFont    := oFontTitle

	nRow     := nLine
	nCol     := oBoxTerms[ATT_POSH][02] // INIBOXH
	cText    := "Termos e Condições de Compras"
	nHeight  := nRow + oFont:nHeight * 1.2
	nWidth   := oBoxTerms[ATT_TAMH][02] // MAXBOXH +60
	nTextWidth := nWidth - nCol - nMargin
	nClrText := Nil
	nAlignH  := ALIGNCENT
	nAlignV  := VALIGCENT

	cAux     := "TermsTitle"
    aUltComp := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nRow,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV)
    Aadd(oSecTerms, aUltComp)
    // oReport:SayAlign(nRow, nCol, cText, oFont, nTextWidth, nHeight, nClrText, nAlignH, nAlignV)


	/** =================================================================================================================================== **/
	/** ============================================== TERMOS E CONDICOES DE COMPRAS - TEXTO ============================================== **/
	/** =================================================================================================================================== **/
	nLine    := nLine + oFont:nHeight + nSpaceLine

    If lPrintTerms .Or. !Empty(mTermsPC)

		//-- TOTAL DE LINHAS
		//	nNumLnObs := MLCount(mTermsPC, nLineSize)
		//-- REMOVER CHAVE DE FORMATACAO DE TEXTO
		mTerms    := Replace(mTermsPC, "{{RED}}"  , "")
		mTerms    := Replace(mTerms  , "{{/RED}}" , "")
		mTerms    := Replace(mTerms  , "{{BOLD}}" , "")
		mTerms    := Replace(mTerms  , "{{/BOLD}}", "")
		nNumLnObs := MLCount(mTerms  , nLineSize      )

		//-- PARAMETROS CAIXA DE TEXTO
		nCol      := oBoxTerms[ATT_POSH][02]                                   //-- INIBOXH + nMargin
		oFont     := oFontTerms                                                //-- oFont10:oFont
		nWidth    := oBoxTerms[ATT_TAMH][02] - nCol - nMargin                  //-- MAXBOXH - nCol - nMargin //-- 850 - 05 = 845
		nHeight   := oReport:GetTextHeight(Space(nLineSize), oFont)            //-- aElements[nItem][08][02] - nLine   //-- MAXBOXV
		nClrText  := Nil                                                       //-- CLR_BLACK
		nAlignH   := ALIGNLEFT                                                 // ALIGRIGHT
		nAlignV   := Nil                                                       // VALIGBOT

		//-- CALCULA NUMERO MAXIMO DE LINHAS POR PAGINA PARA FONTE / ALTURA DA LINHA ATUAL
		nTxtSizeV  := oBoxTerms[ATT_TAMV][02] - nLine // MAXBOXV - nLine
		nMaxLines  := nTxtSizeV / (nSpaceLine + oFont:nHeight)
		nMaxLines  := Round(nMaxLines, 0)

		lColored   := .F.
		lTxtBold   := .F.
		//-- LINHA 215 CARACTERES
        For nCountLine := 1 To nNumLnObs

            If lEnd
                RETURN {{}}
            EndIf

			//-- RETORNA LINHA SEM QUEBRAR PALAVRA
			cText  := MemoLine(mTermsPC, nLineSize, nCountLine)

			//-- NOVA LINHA DE IMPRESSAO
			If nCountLine > 1
				nLine  := nSpaceLine + nLine + oFont:nHeight
			EndIf

			//-- LINHA ANTERIOR MULTIPLO DO MAXIMO DE LINHAS POR PAGINA
			//-- REALIZA PAGINACAO
            If nCountLine > 1 .And. ((nCountLine -1) % nMaxLines) == 0

                // oReport:EndPage() //-- QUEBRA DE PAGINA DEVE SER INSERIDA NA LISTAGEM DE ELEMENTOS. PARA CORRETA PAGINACAO E IMPRESSAO
                cAux     := "PageBreak" + PadL(nPageCount,2,"0")
                AAddComponent(oReport,@aElements,cAux,PAGE_END)

                //-- AJUSTAR LINHA DO COMPONENTE REFERENCIA NA CONSTRUCAO DOS ITENS
                nPageCount := ATail(aElements)[13][02] + 01 // nPageCount := oReport:nPageCount

                PrtHeader(@oReport,@aElements)   //-- INICIA NOVA PAGINA E IMPRIME CABECALHO
                PrtFooter(@oReport,@aElements)   //-- IMPRIME RODAPE DA PAGINA, NOVA

                nItRef   := AScanX(aElements, {|aItem| aItem[ATT_NAME][02] == "ReportHeaderBox"}, 10) //-- PESQUISAR NOS ULTIMOS 10 ELEMENTOS
                nLine    := aElements[nItRef][ATT_TAMV][02]
                nLine    := nLine + nMargin

                /** =================================================================================================================================== **/
                /** ========================================= SECAO - TERMOS E CONDICOES DE COMPRAS - QUADRO ========================================== **/
                /** =================================================================================================================================== **/
                nRow      := nLine
                nCol      := INIBOXH
                nWidth    := MAXBOXH
                nHeight   := MAXBOXV
                cAux      := "BoxTerms" + "Page" + PadL(nPageCount,2,"0")
                aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_BOX,,nRow,nCol,,nWidth,nHeight)
                oBoxTerms := ATail(aElements)
                Aadd(oSecTerms, aUltComp)
			EndIf

			//-- COR DA FONTE PARA IMPRESSAO
			//-- INCISO / ALINEA DESTAQUE VERMELHO
			If SubStr(cText,1,7) == "{{RED}}" .OR. lColored
				nClrText  := CLR_HRED
				lColored  := .T.
			Else
				nClrText  := Nil
				lColored  := .F.
			EndIf

			//-- ESTILO DA FONTE PARA IMPRESSAO
			//-- PRIMEIRA LINHA EM NEGRITO
			// TITULO Departamento de Compras - CAOA / S'Motors / Elivel
			//-- FONTE EM NEGRITO PODE SUPRIMIR ULTIMA PALAVRA MAIS PROXIMA AO LIMITE DA AREA / BOX
			If SubStr(cText,1,8) == "{{BOLD}}" .OR. lTxtBold
                oFont     := oFontBold // oFont10N:oFont
				lTxtBold  := .T.
			Else
				oFont     := oFontTerms // oFont10:oFont
				lTxtBold  := .F.
			EndIf

			//-- REMOVER MARCACOES DE FORMATACAO ANTES DA IMPRESSAO
			xAux      := cText
			If !Empty(cText) .And. (lColored .Or. lTxtBold)
				cText     := Replace(cText, "{{RED}}" , "")
				cText     := Replace(cText, "{{/RED}}", "")

				cText     := Replace(cText, "{{BOLD}}" , "")
				cText     := Replace(cText, "{{/BOLD}}", "")
			EndIf
			
			//-- SUBSTITUIR CHAVES/PARAMETROS ${CODIGO}
			cText     := Replace(cText, "${CODIGO_PEDIDO}", cParC7Num)

			
			//-- INCLUIR ELEMENTO NA IMPRESSAO
            nCol      := oBoxTerms[ATT_POSH][02] + nMargin
            cAux      := "TermsTextLine" + PadL(nCountLine,2,"0")
            aUltComp  := AAddComponent(oReport,@aElements,cAux,TYPE_TXT,cText,nLine,nCol,oFont,nWidth,nHeight,nAlignH,nAlignV,nClrText)
            Aadd(oSecTerms, aUltComp)

			cText      := xAux
			xAux       := Nil

			//-- FORMATACAO FINALIZADA
			If !Empty(cText) .And. RAT("{{/BOLD}}",cText) > 0
				lTxtBold  := .F.
			EndIf
			If !Empty(cText) .And. RAT("{{/RED}}",cText) > 0
				lColored  := .F.
			EndIf

		Next nCountLine

	EndIf //-- lPrintTerms .AND. !Empty(mTermsPC)

RETURN(oSecTerms)

/*
=====================================================================================
Programa.:              RptSendMail
-------------------------------------------------------------------------------------
Parametros:             ExpA1: Relacao de Elementos com as propriedades de impressao
						ExpA2: Listagem de destinatarios
                        ExpC3: Lista de arquivos anexo
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
-------------------------------------------------------------------------------------
Descricao:              Cria template de email para envio com PC anexado
=====================================================================================
*/
STATIC FUNCTION RptSendMail(aElements,aDest,cArqPedido)
	LOCAL lEnvia
	LOCAL cMailTo    := ""
	LOCAL cMailCC	 := ""
	LOCAL cReplyTo
	LOCAL cSubject
	LOCAL cHtml      := ""
	LOCAL aAnexos    := {}
	LOCAL lMsgErro 	 := .T.
	LOCAL lMsgOK 	 := .T.
	LOCAL cMsgTitle  := "CAOA"
	LOCAL cMsgSending := "Enviando e-mail de notificação. Aguarde!!!"
	LOCAL nItRef
	LOCAL nAux
	LOCAL cNumPC     := ""
	// LOCAL cNomForn   := ""
	// LOCAL cFornCGC   := ""
	// LOCAL cCliNom    := ""
	// LOCAL cCmprNom   := ""
	LOCAL cCmprMail  := ""
	LOCAL cPictImg   := "lg_caoa.png"
	LOCAL cRotina	 := "ZCOMR001"
	LOCAL cObsMail	 := ""
	LOCAL oFile      := FWFileReader():New("/templates/compras/pedido_zcomr001.html")
	LOCAL aLinhas
	Local i          := 0
	
	DEFAULT aDest      := {}
	DEFAULT lEnvPrd    := ("_PRD" $ Upper(GetEnvServer())) //-- ENVIAR PARA EMAIL EXTERNO, COMO PRODUCAO

	// ** ************************************************************ ** //
	// ** VERIFICAR EXISTENCIA DO TEMPLATE DE EMAIL ****************** ** //
	// ** ************************************************************ ** //
	If !FindFunction("H_ZCOMR001") .AND. !oFile:Open()
		MsgStop("Operação cancelada!" + CRLF + CRLF + "Nenhuma mensagem enviada." + CRLF + ;
			"Template de e-mail indisponível.", "[ZCOMR001] - Pedido de Compras")
		RETURN()
	EndIf

	// ** ************************************************************ ** //
	// ** TEMPLATE - CORPO DE EMAIL HTML PEDIDO DE COMPRA ************ ** //
	// ** ---------- ARQUIVO - ARRAY DE LINHAS DO TEMPLATE PARA STRING ** //
	// ** ************************************************************ ** //
	If oFile:Open()
		aLinhas    := oFile:GetAllLines()
		oFile:Close()
		Aeval(aLinhas, {|cLinha| cHtml += cLinha + Char(13) + Char(10) })
	Else
		// ** ************************************************************ ** //
		// ** ---------- RPO - CORPO DE EMAIL HTML PEDIDO DE COMPRA ****** ** //
		// ** ************************************************************ ** //
		cHtml      := H_ZCOMR001()
	EndIf
	
	//  INSERIR NO HTML OS DADOS DE MENSAGEM ADICIONAIS
	cHtml := Stuff( cHtml, At("${DADOS_ADICIONAIS}", cHtml), Len("${DADOS_ADICIONAIS}"), Alltrim(SC7->C7_XOBSFOR))

	// ** ************************************************************ ** //
	// ** ANEXOS DE EMAIL ******************************************** ** //
	// ** IMAGENS COM REFERENCIA NO TEMPLATE NAO FICAM ENTRE OS ANEXOS ** //
	// ** ************************************************************ ** //
	Aadd(aAnexos, "/templates/compras/" + cPictImg)
	Aadd(aAnexos, "/templates/compras/" + "Comunicado a Fornecedores e Bancos.pdf")
	Aadd(aAnexos, "/templates/compras/" + "Instrução de pagamento - compras indiretas.pdf")

	// ** ************************************************************ ** //
	// ** DADOS DO PEDIDO ******************************************** ** //
	// ** ************************************************************ ** //
	nItRef  := AScan(aElements, {|aElem| aElem[ATT_NAME][02] == "ReportTitle"})
	If nItRef > 0
		nAux   := Len(aElements[nItRef][ATT_TEXT][02])
		cNumPC := AllTrim(SubStr(aElements[nItRef][ATT_TEXT][02], nAux - 06))
	EndIf

	//-- ENDERECO EMAIL DO COMPRADOR - IMPRESSO NO RELATORIO
	nItRef  := AScan(aElements, {|aElem| aElem[ATT_NAME][02] == "DetailCellBillingPurchaserMail"})
	If nItRef > 0
		cAux := AllTrim(ATail(StrTokArr(aElements[nItRef][ATT_TEXT][02],":")))
		If !Empty(cAux)
			cCmprMail := cAux
		EndIf
	EndIf

	// ** ************************************************************ ** //
	// ** PARAMETROS DE EMAIL **************************************** ** //
	// ** ************************************************************ ** //
	// cMailTo := "denis.galvani@caoa.com.br"
	cMailCC    := "" //NIL
	cSubject   := "Pedido de Compra:" + Space(1) + cNumPC
	//-- RESPOSTA PARA EMAIL COMPRADOR
	cReplyTo   := IIF(!Empty(cCmprMail),cCmprMail,NIL)
	//-- cMailTo - ERRO 67 - CONTA NAO EXISTE / DIFERENTE DO From: caoa_totvs_protheus_tst@caoa.com.br
	//** ************************************************************************************* ** //
	//** BLOQUEAR ENVIO DE EMAILS PARA ENDERECOS DIFERENTES DE ...@CAOA... ******************* ** //
	//** -- ALTERA ENDERECO DE ...@... PARA ...@TESTE-... PARA INVALIDAR DESTINATARIO EXTERNO. ** //
	//** ************************************************************************************* ** //
	For i := 1 To Len(aDest)
		//-- IMPEDIR ENVIO PARA DOMINIOS NAO CAOA - ALTERAR DOMINIO - AMBIENTE DESENVOLVIMENTO
		//If !lEnvPrd .AND. At("@CAOA",Upper(aDest[i])) == 0 
		//	cMailTo += IIF(!Empty(cMailTo),";","") + AllTrim(StrTran(aDest[i],"@","@TESTE-"))
		//Else
			If !( AllTrim(UPPER(aDest[i])) $ UPPER(cMailTo) )
				cMailTo += IIF(!Empty(cMailTo),";","") + AllTrim(aDest[i])
			EndIf
		//EndIf
	Next i
	
	i := 0
	if empty(cMailCC)
		i := 1
	Endif
	
	if len(cMailTo) >= 300
		cMailCC += substr(cMailTo,rat(';',substr(cMailTo,1,300)) + i )
		cMailto := substr(cMailTo,1,rat(';',substr(cMailTo,1,300))-1)
	endIf
	//-- REGISTRO DE HISTORICO (TABELA SZU)
	cObsMail := "ENVIO PEDIDO DE COMPRAS: " + cNumPC
	
	//-- INCLUIR PEDIDO GERADO COMO ANEXO
	Aadd(aAnexos, cArqPedido)

	If !Empty(cPathInServer)											
		U_ZGENMAIL(cMailTo,cMailCC,cSubject,cHtml,aAnexos,.F.,lMsgOK,cRotina,cObsMail,cReplyTo)
	Else
		MsgRun(cMsgSending, cMsgTitle, {|| lEnvia := U_ZGENMAIL(cMailTo,cMailCC,cSubject,cHtml,aAnexos,lMsgErro,lMsgOK,cRotina,cObsMail,cReplyTo) })
	EndIf

RETURN()


/*
=====================================================================================
Programa.:              DlgSendMail
-------------------------------------------------------------------------------------
Parametros:             ExpA1: Relacao de Elementos com as propriedades de impressao
						ExpA2: Vetor de dados dos contatos para envio
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
-------------------------------------------------------------------------------------
Descricao:              Tela de seleção, edição de email para envio PC anexado
=====================================================================================
*/
STATIC FUNCTION DlgSendMail(aElements,aColsMail)
	LOCAL cTitulo       := "Enviar e-mail - Listagem de destinatários"
	LOCAL cAux
	LOCAL lRet
	LOCAL aACampos  	:= {"CONTATO","EMAIL"} 	// Variável contendo o campo editável no Grid
	LOCAL aBotoes		:= {}         			// Variável onde será incluido o botão para a legenda
	PRIVATE oLista                    			// Declarando o objeto do Browser
	PRIVATE aCabecalho  := {}         			// Variável que montará o aHeader do Grid
	DEFAULT aColsMail 	:= {}         			// Variável que receberá os dados

	PRIVATE cFornMail := ""						// DEFAULT
	PRIVATE cCmprMail := ""						// DEFAULT
	PRIVATE cUserMail := AllTrim(UsrRetMail(RetCodUsr()))
	
	//-- ENDERECO EMAIL DO FORNECEDOR - IMPRESSO NO RELATORIO
	nItRef  := AScan(aElements, {|aElem| aElem[ATT_NAME][02] == "DetailCellSupplierMail"})
	If nItRef > 0
		cAux := AllTrim(ATail(StrTokArr(aElements[nItRef][ATT_TEXT][02],":")))
		If !Empty(cAux)
			cFornMail := cAux
		EndIf
	EndIf

	//-- ENDERECO EMAIL DO COMPRADOR - IMPRESSO NO RELATORIO
	nItRef  := AScan(aElements, {|aElem| aElem[ATT_NAME][02] == "DetailCellBillingPurchaserMail"})
	If nItRef > 0
		cAux := AllTrim(ATail(StrTokArr(aElements[nItRef][ATT_TEXT][02],":")))
		If !Empty(cAux)
			cCmprMail := cAux
		EndIf
	EndIf

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000, 000  TO 300, 700  PIXEL
		//-- CRIAR ESTRUTURA aHeader
		CriaCabec()

		//-- BROWSER PARA INCLUSAO, REMOCAO E ATUALIZACAO
		oLista := MsNewGetDados():New( 053, 078, 415, 775, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,1, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aCabecalho, aColsMail)

		//-- CARGA DOS ITENS DO GRID, ENDERECOS EMAIL PRINCIPAIS
		Carregar(@aColsMail)

		//-- ALINHAMENTO PARA OCUPACAO DE ESPACO DISPONIVEL
		oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		//-- DEFINIR FOCO NO BROWSER NA ABERTURA
		oLista:oBrowse:SetFocus()

		//-- BOTAO ACOES RELACIONADAS
		// Aadd(aBotoes,{"NG_ICO_LEGENDA", {||Legenda()},"Legenda","Legenda"})

		EnchoiceBar(oDlg, {|| lRet:=.T.,oDlg:End() }, {|| lRet:=.F.,oDlg:End() },,aBotoes)

	ACTIVATE MSDIALOG oDlg CENTERED

	//-- ATUALIZAR VALORES DO GRID
	aColsMail := oLista:aCols

RETURN(lRet)


/*
=====================================================================================
Programa.:              CriaCabec
-------------------------------------------------------------------------------------
Parametros:             
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
-------------------------------------------------------------------------------------
Descricao:              Cria config. colunas da grid (MsNewGetDados), aHeader
=====================================================================================
*/
STATIC FUNCTION CriaCabec()
    Aadd(aCabecalho, {;
                  "Item",;					// X3Titulo()
                  "ITEM",;  				// X3_CAMPO
                  "@!",;					// X3_PICTURE
                  005,;						// X3_TAMANHO
                  000,;						// X3_DECIMAL
                  "",;						// X3_VALID
                  "",;						// X3_USADO
                  "C",;						// X3_TIPO
                  "",; 						// X3_F3
                  "V",;						// X3_CONTEXT
                  "",;						//X3_CBOX
                  "Soma1(StrZero(N,3))",;	//X3_RELACAO
                  ""})						// X3_WHEN

	Aadd(aCabecalho, {;
                  "Contato",;				// X3Titulo()
                  "CONTATO",;  				// X3_CAMPO
                  "@!",;					// X3_PICTURE
                  1,;						// X3_TAMANHO
                  0,;						// X3_DECIMAL
                  "NaoVazio()",;			// X3_VALID
                  "",;						// X3_USADO
                  "C",;						// X3_TIPO
                  "",;						// X3_F3
                  "V",;						// X3_CONTEXT
				  "F=Fornecedor;C=Comprador;R=Requisitante;U=Usuário;X=Cópia",;			//X3_CBOX
                  "",;						// X3_RELACAO
				  ""})						// X3_WHEN
				  
    Aadd(aCabecalho, {;
                  "E-mail",;				// X3Titulo()
                  "EMAIL",;  				// X3_CAMPO
                  "@!",;					// X3_PICTURE
                  500,;						// X3_TAMANHO
                  0,;						// X3_DECIMAL
                  "IsEmail(M->EMAIL)",;		// X3_VALID
                  "",;						// X3_USADO
                  "C",;						// X3_TIPO
                  "",;						// X3_F3
                  "V",;						// X3_CONTEXT
                  "",;						// X3_CBOX
                  "",;						// X3_RELACAO
                  ""})						// X3_WHEN
RETURN()


/*
=====================================================================================
Programa.:              Carregar
-------------------------------------------------------------------------------------
Parametros:             ExpA1: Grid de dados dos contatos para envio, aCols
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
-------------------------------------------------------------------------------------
Descricao:              Constroi grid de destinatários (MsNewGetDados), aCols
=====================================================================================
*/
STATIC FUNCTION Carregar(aColsMail)
    LOCAL aContatos  := {}
	LOCAL cMail      := ""
	LOCAL lSend      := .T.
	Local i          := 0

	DEFAULT lEnvPrd    := ("_PRD" $ Upper(GetEnvServer())) //-- ENVIAR PARA EMAIL EXTERNO, COMO PRODUCAO
 
    Aadd(aContatos,{"F",cFornMail})
    Aadd(aContatos,{"C",cCmprMail})
    Aadd(aContatos,{"R",(cAliasSZV)->ZV_REQMAIL})
    Aadd(aContatos,{"U",cUserMail})
 
    For i := 1 to len(aContatos)
		cMail := aContatos[i,2]
		//-- IMPEDIR ENVIO PARA DOMINIOS NAO CAOA - ALTERAR DOMINIO - AMBIENTE DESENVOLVIMENTO
		//If !lEnvPrd .AND. At("@CAOA",Upper(cMail)) == 0
		//	cMail := StrTran(cMail,"@","@TESTE-")
		//	lSend := .F. //-- MARCAR COMO EXCLUIDO
		//EndIf
		Aadd(aColsMail,{StrZero(i,3),aContatos[i,1],PadR(cMail,aCabecalho[3,4]),(Empty(cMail).OR.!lSend)})
		lSend := .T.
    Next
 
    //-- SETAR aCols DE DADOS NO OBJETO
    oLista:SetArray(aColsMail,.T.)
 
    //-- ATUALIZAR INFORMACOES PARA EXIBICAO
    oLista:Refresh()
RETURN()



/*
=====================================================================================
Programa.:              DlgSendMa
-------------------------------------------------------------------------------------
Parametros:             ExpA1: Relacao de Elementos com as propriedades de impressao
						ExpA2: Vetor de dados dos contatos para envio
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
-------------------------------------------------------------------------------------
Descricao:              Tela de seleção, edição de email para envio PC anexado
=====================================================================================
*/
STATIC FUNCTION DlgSendMa(aElements,aColsMail)
	LOCAL cTitulo       := "Enviar e-mail - Listagem de destinatários"
	LOCAL cAux
	LOCAL lRet
	Local oDlg
	LOCAL aACampos  	:= {"CONTATO","EMAIL"} 	// Variável contendo o campo editável no Grid
	LOCAL aBotoes		:= {}         			// Variável onde será incluido o botão para a legenda
	PRIVATE oLista                    			// Declarando o objeto do Browser
	PRIVATE aCabecalho  := {}         			// Variável que montará o aHeader do Grid
	DEFAULT aColsMail 	:= {}         			// Variável que receberá os dados

	PRIVATE cFornMail := ""						// DEFAULT
	PRIVATE cCmprMail := ""						// DEFAULT
	//PRIVATE cUserMail := AllTrim(UsrRetMail(RetCodUsr()))
	PRIVATE cUserMail := alltrim(SC1->C1_XREQMAI)
	//-- ENDERECO EMAIL DO FORNECEDOR - IMPRESSO NO RELATORIO
	nItRef  := AScan(aElements, {|aElem| aElem[ATT_NAME][02] == "DetailCellSupplierMail"})
	If nItRef > 0
		cAux := AllTrim(ATail(StrTokArr(aElements[nItRef][ATT_TEXT][02],":")))
		If !Empty(cAux)
			cFornMail := cAux
		EndIf
	EndIf

	//-- ENDERECO EMAIL DO COMPRADOR - IMPRESSO NO RELATORIO
	nItRef  := AScan(aElements, {|aElem| aElem[ATT_NAME][02] == "DetailCellBillingPurchaserMail"})
	If nItRef > 0
		cAux := AllTrim(ATail(StrTokArr(aElements[nItRef][ATT_TEXT][02],":")))
		If !Empty(cAux)
			cCmprMail := cAux
		EndIf
	EndIf

	//DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000, 000  TO 300, 700  PIXEL
		//-- CRIAR ESTRUTURA aHeader
		CriaCabec()

		//-- BROWSER PARA INCLUSAO, REMOCAO E ATUALIZACAO
		//oLista := MsNewGetDados():New( 053, 078, 415, 775, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,1, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aCabecalho, aColsMail)

		//-- CARGA DOS ITENS DO GRID, ENDERECOS EMAIL PRINCIPAIS
		Carrega(@aColsMail)

		//-- ALINHAMENTO PARA OCUPACAO DE ESPACO DISPONIVEL
		//oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		//-- DEFINIR FOCO NO BROWSER NA ABERTURA
		//oLista:oBrowse:SetFocus()

		//-- BOTAO ACOES RELACIONADAS
		// Aadd(aBotoes,{"NG_ICO_LEGENDA", {||Legenda()},"Legenda","Legenda"})

		//EnchoiceBar(oDlg, {|| lRet:=.T.,oDlg:End() }, {|| lRet:=.F.,oDlg:End() },,aBotoes)

	//ACTIVATE MSDIALOG oDlg CENTERED

	//-- ATUALIZAR VALORES DO GRID
	//aColsMail := oLista:aCols

RETURN(lRet)




/*
=====================================================================================
Programa.:              Carregar
-------------------------------------------------------------------------------------
Parametros:             ExpA1: Grid de dados dos contatos para envio, aCols
-------------------------------------------------------------------------------------
Autor....:              Denis Amaral Galvani
Data.....:              20/05/19
Manutencao efetuada:    Criacao
-------------------------------------------------------------------------------------
Descricao:              Constroi grid de destinatários (MsNewGetDados), aCols
=====================================================================================
*/
STATIC FUNCTION Carrega(aColsMail)
    LOCAL aContatos  := {}
	LOCAL cMail      := ""
	LOCAL lSend      := .T.
	Local i          := 0

	DEFAULT lEnvPrd    := ("_PRD" $ Upper(GetEnvServer())) //-- ENVIAR PARA EMAIL EXTERNO, COMO PRODUCAO
 
    Aadd(aContatos,{"F",cFornMail})
    Aadd(aContatos,{"C",cCmprMail})
    Aadd(aContatos,{"R",(cAliasSZV)->ZV_REQMAIL})
    Aadd(aContatos,{"U",cUserMail})
 
    For i := 1 to len(aContatos)
		cMail := aContatos[i,2]
		//-- IMPEDIR ENVIO PARA DOMINIOS NAO CAOA - ALTERAR DOMINIO - AMBIENTE DESENVOLVIMENTO
		//If !lEnvPrd .AND. At("@CAOA",Upper(cMail)) == 0
		//	cMail := StrTran(cMail,"@","@TESTE-")
		//	lSend := .F. //-- MARCAR COMO EXCLUIDO
		//EndIf
		Aadd(aColsMail,{StrZero(i,3),aContatos[i,1],PadR(cMail,aCabecalho[3,4]),(Empty(cMail).OR.!lSend)})
		lSend := .T.
    Next
 
    //-- SETAR aCols DE DADOS NO OBJETO
    //oLista:SetArray(aColsMail,.T.)
 
    //-- ATUALIZAR INFORMACOES PARA EXIBICAO
    //oLista:Refresh()
RETURN()

