#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

/*
=====================================================================================
Programa.:              ZFISR001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              12/06/19
Descricao / Objetivo:   Relatorio Analitico de Notas Fiscais de Entrada e Saida
Doc. Origem:            GAP EST007 E GAP FAT022
Solicitante:            Fiscal
Uso......:              
Obs......:
=====================================================================================
*/
User Function ZFISR012() // u_ZFISR001()

	Local aOpcRadio	:= {	"Relatório Notas Fiscais de Entrada (Excel)"	,;
							"Relatório Notas Fiscais de Saida (Excel)"		}
	Local nRadio	:=	1

	DEFINE MSDIALOG opPar TITLE "Relatórios de Conferência" FROM 100,0 TO 300,400 PIXEL of oMainWnd STYLE DS_MODALFRAME

	oRadio1:=tRadMenu():New( 010	,010	,aOpcRadio		,{|u|if(PCount()>0,nRadio:=u,nRadio)}	,opPar	,,,,,,,	,290	,50,,,,.T.	)
	oBotao2:=tButton():New(  070	,030	,"Imprimir"		,opPar	,{|| zSelect(nRadio)   }		,050	,011	,,,,.T.	) // "Imprimir"
	oBotao1:=tButton():New(  070	,120	,"Fechar"		,opPar	,{|| opPar:End()}				,050	,011	,,,,.T.	) // "Fechar"

	ACTIVATE MSDIALOG opPar

Return()

/*
=====================================================================================
Programa.:              zSelect
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              13/06/19
Descricao / Objetivo:   Seleciona o relatorio para impressao
Doc. Origem:            GAP EST007 E GAP FAT022
Solicitante:            Fiscal
Uso......:              ZFISR001
Obs......:
=====================================================================================
*/
Static Function zSelect(nRadio)
	Local cExtens   := "Arquivo XML | *.XML"
	Local cTitulo	:= "Escolha o caminho para salvar o arquivo!"
	Local cMainPath := "\"
	Local cArquivo	:= ""
	Private cPergR1	:= "ZFISR001R1"
	Private cPergR2	:= "ZFISR001R2"

	If nRadio == 1
		If Pergunte( cPergR1	,.T.	)
			cArquivo := cGetFile(cExtens,cTitulo,,cMainPath,.F.,)
			If !Empty(cArquivo)
				Processa({|| zRel0001(cArquivo)}	,"Gerando Relatório de Notas Fiscais de Entrada..."	)
			EndIf
		EndIf
	Else
		If Pergunte( cPergR2	,.T.	)
			cArquivo := cGetFile(cExtens,cTitulo,,cMainPath,.F.,)
			If !Empty(cArquivo)
				Processa({|| zRel0002(cArquivo)}	,"Gerando Relatório de Notas Fiscais de Saída..."	)
			EndIf
		EndIf
	EndIf

Return()

/*
=====================================================================================
Programa.:              zRel0001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              13/06/19
Descricao / Objetivo:   Gera Excel Notas de Entrada
Doc. Origem:            GAP EST007 E GAP FAT022
Solicitante:            Fiscal
Uso......:              zSelect
Obs......:
=====================================================================================
*/
Static Function zRel0001(cArquivo)

	Local cQuery		:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cTMPCanc		:= GetNextAlias()
	Local cAba1			:= "Notas Fiscais de Entrada"
	Local cAba2			:= "Notas Fiscais Canceladas"
	Local cTabela1		:= "Relação de Notas Fiscais de Entrada"
	Local cTabela2		:= "Relação de Notas Fiscais Canceladas"
	Local cDescTipo		:= ""
	Local cLogInc		:= ""
	Local cLogAlt		:= ""
	Local cDtLogAlt		:= ""
	Local cAmbiente 	:= ""
	Local cProtocolo	:= ""
	Local cMsgSefaz 	:= ""
	Local cSituacao		:= ""
	Local cComVei		:= ""
	Local cModVei		:= ""
	Local cDesMod		:= ""
	Local cCliFor		:= ""
	Local cCgcCpf		:= ""
	Local cIncEst		:= ""
	Local cEstCli		:= ""
	Local cCodMun		:= ""
	Local cTpCliFor		:= ""
	Local cTpPessoa		:= ""
	Local cTpNF			:= ""
	Local oFWMsExcel
	Local oExcel
	Local nTotReg		:= 0
	Local nVlIPIRegi	:= 0
	Local nVlIPIPres	:= 0
	Local cCodNatur		:= ""
	Local cCodChassi	:= ""
	Local nVlCom		:= 0

	If !ApOleClient( "MSExcel" )
		MsgAlert( "Microsoft Excel não instalado!!" )
		Return
	EndIf

	If Select( (cAliasTRB) ) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf

	cQuery += " SELECT 	D1_FILIAL, D1_COD, D1_DOC, D1_SERIE, D1_TES, D1_CF, D1_FORNECE, D1_LOJA, D1_EMISSAO, D1_DTDIGIT, " 			+ CRLF
	cQuery += " D1_ITEM, F4_FINALID, F4_TEXTO, FT_CTIPI, FT_CSTPIS, FT_CSTCOF, F4_ICM, F4_IPI, F4_CREDICM, F4_CREDIPI, F4_DUPLIC, "	+ CRLF
	cQuery += "	B1_DESC, B1_XDESCL1, B1_GRUPO, B1_POSIPI, B1_CEST, B1_ORIGEM, B1_EX_NCM, "								  			+ CRLF
	cQuery += "	F1_ESPECIE, F1_CODNFE, F1_MENNOTA, F1_DOC, F1_SERIE, F1_STATUS, F1_TIPO, FT_CHVNFE, "								+ CRLF
	cQuery += " FT_VALCONT, D1_CONTA, D1_ITEMCTA, D1_NFORI, D1_SERIORI, D1_VUNIT, D1_TOTAL, "										+ CRLF
	cQuery += " D1_DESC, FT_CLASFIS, FT_BASERET, FT_ICMSRET, D1_DESCZFP, D1_DESCZFC,  "												+ CRLF
	cQuery += " F1_UFORITR, F1_MUORITR, F1_UFDESTR, F1_MUDESTR,  "																	+ CRLF
	cQuery += " FT_BASEICM, FT_ALIQICM, FT_VALICM, "																				+ CRLF
	cQuery += " FT_BASEIPI, FT_ALIQIPI, FT_VALIPI, FT_ARETPIS, FT_ARETCOF, FT_VRETPIS, FT_VRETCOF, FT_BRETPIS, " 					+ CRLF
	cQuery += " D1_BASIMP6, D1_ALQIMP6, D1_VALIMP6, FT_BRETCOF, " 																	+ CRLF
	cQuery += " D1_BASIMP5, D1_ALQIMP5, D1_VALIMP5, " 																				+ CRLF
	cQuery += " FT_BASEPIS, FT_ALIQPIS, FT_VALPIS, FT_ALIQPS3, FT_VALPS3, "															+ CRLF
	cQuery += " FT_BASECOF, FT_ALIQCOF, FT_VALCOF, FT_DIFAL, FT_BASECF3, FT_ALIQCF3, FT_VALCF3, FT_BASEPS3, "						+ CRLF
	cQuery += " FT_BASEIRR, FT_ALIQIRR, FT_VALIRR, F3_OUTRIPI, F3_ISENIPI, F3_OUTRICM, F3_ISENICM, " 								+ CRLF
	cQuery += " FT_BASECSL, FT_ALIQCSL, FT_VALCSL, D1_UM, D1_QUANT, D1_CHASSI, "													+ CRLF
	cQuery += " FT_BASEINS, FT_ALIQINS, D1_ABATINS, D1_AVLINSS, FT_VALINS, C7_NUM, FT_FORMUL, "										+ CRLF
	cQuery += " D1_BASEISS, D1_ALIQISS, D1_ABATISS, D1_ABATMAT, D1_VALISS, FT_CODBCC, FT_INDNTFR, "									+ CRLF
	cQuery += " D1_VALFRE, D1_DESPESA, D1_CUSTO, D1_SEGURO, D1_VALACRS, D1_II, FT_ICMSCOM, D1_TNATREC, D1_CONHEC, "					+ CRLF
	cQuery += " D1_PESO, FT_MVALPIS, FT_MVALCOF, W6_DTREG_D, W6_DI_NUM, YD_PER_II, VRK_OPCION, W9_TX_FOB, D1_CHASSI "							+ CRLF

	cQuery += " FROM " + RetSQLName('SD1') + " SD1 "																				+ CRLF

	cQuery += " INNER JOIN " + RetSQLName('SF1') + " SF1 "			 																+ CRLF
	cQuery += " 	ON SF1.F1_FILIAL = '" + FWxFilial('SF1') + "' "																	+ CRLF
	cQuery += " 	AND SF1.F1_DOC = SD1.D1_DOC " 																					+ CRLF
	cQuery += " 	AND SF1.F1_SERIE = SD1.D1_SERIE " 																				+ CRLF
	cQuery += " 	AND SF1.F1_FORNECE = SD1.D1_FORNECE " 																			+ CRLF
	cQuery += " 	AND SF1.F1_LOJA = SD1.D1_LOJA " 																				+ CRLF
	cQuery += " 	AND SF1.F1_ESPECIE BETWEEN '" +MV_PAR03+ "' AND '" +MV_PAR04+ "' " 												+ CRLF
	cQuery += " 	AND SF1.D_E_L_E_T_ = ' ' " 																						+ CRLF	

	If !Empty(MV_PAR19)
		cQuery += " 	AND SF1.F1_EST = '" + MV_PAR19 + "' "																		+ CRLF
	EndIf 

	cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1  " 																		+ CRLF
	cQuery += " 	ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "'  "																+ CRLF
	cQuery += "		AND SB1.B1_COD = SD1.D1_COD  "	 																				+ CRLF
	cQuery += "     AND SB1.D_E_L_E_T_ = ' '   " 																					+ CRLF
	
	If !Empty( MV_PAR20 )
		cQuery += " 	AND SB1.B1_GRUPO = '" + MV_PAR20 + "' "																		+ CRLF
	EndIf

	If !Empty( MV_PAR21 )
		cQuery += " 	AND SB1.B1_POSIPI = '" + MV_PAR21 + "' "																	+ CRLF
	EndIf

	cQuery += " INNER JOIN " + RetSQLName("SF4") + " SF4 " 																			+ CRLF
	cQuery += " 	ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "'  "																+ CRLF
	cQuery += "		AND SF4.F4_CODIGO = SD1.D1_TES  "	 																			+ CRLF
	cQuery += "     AND SF4.D_E_L_E_T_ = ' '   " 																					+ CRLF

	cQuery += " LEFT JOIN " + RetSQLName("SW6") + " SW6  " 																			+ CRLF
	cQuery += " 	ON SW6.W6_FILIAL = '" + FWxFilial('SW6') + "' "																	+ CRLF
	cQuery += "		AND SW6.W6_HAWB = SD1.D1_CONHEC  "	 																			+ CRLF
	cQuery += "     AND SW6.D_E_L_E_T_ = ' '   " 																					+ CRLF

	cQuery += " LEFT JOIN " + RetSQLName("SW9") + " SW9  " 																			+ CRLF
	cQuery += " 	ON SW9.W9_FILIAL = '" + FWxFilial('SW9') + "' "																	+ CRLF
	cQuery += "		AND SW9.W9_HAWB = SD1.D1_CONHEC  "	 																			+ CRLF
	cQuery += "     AND SW9.D_E_L_E_T_ = ' '   " 																					+ CRLF

	cQuery += " LEFT JOIN " + RetSQLName("SYD") + " SYD  " 																			+ CRLF
	cQuery += " 	ON SYD.YD_FILIAL = '" + FWxFilial('SYD') + "' "																	+ CRLF
	cQuery += "		AND SYD.YD_TEC = SB1.B1_POSIPI "	 																			+ CRLF
	cQuery += "		AND SYD.YD_EX_NCM = SB1.B1_EX_NCM  "	 																		+ CRLF
	cQuery += "		AND SYD.YD_EX_NBM = SB1.B1_EX_NBM  "	 																		+ CRLF
	cQuery += "     AND SYD.D_E_L_E_T_ = ' '   " 																					+ CRLF

	cQuery += " LEFT JOIN " + RetSQLName("VVF") + " VVF "																			+ CRLF
	cQuery += "		ON VVF.VVF_FILIAL = '" + FWxFilial('VVF') + "' "																+ CRLF
	cQuery += " 	AND VVF.VVF_NUMNFI = SF1.F1_DOC "																				+ CRLF
	cQuery += " 	AND VVF.VVF_SERNFI = SF1.F1_SERIE " 																			+ CRLF
	cQuery += " 	AND VVF.VVF_CODFOR = SF1.F1_FORNECE " 																			+ CRLF
	cQuery += " 	AND VVF.VVF_LOJA = SF1.F1_LOJA " 																				+ CRLF
	cQuery += " 	AND VVF.D_E_L_E_T_ = ' ' "																	 					+ CRLF

	cQuery += " LEFT JOIN " + RetSQLName("SC7") + " SC7 "																			+ CRLF
	cQuery += " 	ON SC7.C7_FILIAL = '" + FWxFilial('SC7') + "' "																	+ CRLF
	cQuery += "		AND SC7.C7_NUM = SD1.D1_PEDIDO "																				+ CRLF
	cQuery += "		AND SC7.C7_ITEM = SD1.D1_ITEMPC "												 								+ CRLF
	cQuery += "		AND SC7.D_E_L_E_T_ = ' ' "																						+ CRLF
	
	cQuery += " LEFT JOIN " + RetSQLName("VRK") + " VRK "																			+ CRLF
	cQuery += " 	ON VRK.VRK_FILIAL = '" + FWxFilial('VRK') + "' "  																+ CRLF
	cQuery += "		AND VRK.VRK_PEDIDO = SD1.D1_PEDIDO	"																			+ CRLF
    cQuery += "     AND VRK.VRK_ITEPED = SD1.D1_ITEMPC	"																			+ CRLF
	cQuery += "     AND VRK.D_E_L_E_T_ = ' '   " 																					+ CRLF

	cQuery += " INNER JOIN " + RetSQLName("SFT") + " SFT " 																			+ CRLF
	cQuery += "		ON SFT.FT_FILIAL = '" + FWxFilial('SFT') + "' "																	+ CRLF
	cQuery += "		AND SFT.FT_TIPOMOV = 'E' "																						+ CRLF
	cQuery += "		AND SFT.FT_SERIE = SD1.D1_SERIE "																				+ CRLF
	cQuery += " 	AND SFT.FT_NFISCAL = SD1.D1_DOC "																				+ CRLF
	cQuery += "		AND SFT.FT_CLIEFOR = SD1.D1_FORNECE " 																			+ CRLF
	cQuery += "		AND SFT.FT_LOJA = SD1.D1_LOJA " 																				+ CRLF
	cQuery += "		AND SFT.FT_ITEM = SD1.D1_ITEM " 																				+ CRLF
	cQuery += "		AND SFT.FT_PRODUTO = SD1.D1_COD " 																				+ CRLF	
	cQuery += "		AND SFT.D_E_L_E_T_ = ' ' "																						+ CRLF

	cQuery += " INNER JOIN " + RetSQLName("SF3") + " SF3 " 																			+ CRLF
	cQuery += "		ON SF3.F3_FILIAL = '" + FWxFilial('SF3') + "' "																	+ CRLF
	cQuery += "		AND SF3.F3_SERIE = SFT.FT_SERIE "																				+ CRLF
	cQuery += "		AND SF3.F3_NFISCAL = SFT.FT_NFISCAL "																			+ CRLF
	cQuery += " 	AND SF3.F3_CLIEFOR = SFT.FT_CLIEFOR "																			+ CRLF
	cQuery += "		AND SF3.F3_LOJA = SFT.FT_LOJA " 																				+ CRLF
	cQuery += "		AND SF3.F3_IDENTFT = SFT.FT_IDENTF3 " 																			+ CRLF
	cQuery += "		AND SF3.D_E_L_E_T_ = ' ' "																						+ CRLF

	cQuery += " WHERE SD1.D1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " 											+ CRLF
	cQuery += " 	AND SD1.D1_DOC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " 												+ CRLF
	cQuery += " 	AND SD1.D1_SERIE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " 											+ CRLF
	cQuery += " 	AND SD1.D1_FORNECE BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' " 											+ CRLF
	cQuery += " 	AND SD1.D1_DTDIGIT BETWEEN '" + DToS( MV_PAR11 ) + "' AND '" + DToS( MV_PAR12 ) + "' " 							+ CRLF
	cQuery += " 	AND SD1.D1_EMISSAO BETWEEN '" + DToS( MV_PAR13 ) + "' AND '" + DToS( MV_PAR14 ) + "' " 							+ CRLF
	cQuery += " 	AND SD1.D1_COD BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR16 + "' " 												+ CRLF
	cQuery += " 	AND SD1.D_E_L_E_T_ = ' ' "	 																					+ CRLF

	If !Empty( MV_PAR17 )
		cQuery += " 	AND SD1.D1_TES = '" + MV_PAR17 + "' " 																		+ CRLF
	EndIf

	If !Empty( MV_PAR18 )
		cQuery += " 	AND SD1.D1_CF = '" + MV_PAR18 + "' " 																		+ CRLF
	EndIf  


    If !Empty( MV_PAR23) .OR. !Empty( MV_PAR24 )
	   cQuery += " 	AND SD1.D1_CHASSI BETWEEN '" + MV_PAR23 + "' AND '" + MV_PAR24 + "' " 												+ CRLF
    EndIf

	cQuery += " GROUP BY 	D1_FILIAL, D1_COD, D1_DOC, D1_SERIE, D1_TES, D1_CF, D1_FORNECE, D1_LOJA, D1_EMISSAO, D1_DTDIGIT, " 		+ CRLF
	cQuery += " D1_ITEM, F4_FINALID, F4_TEXTO, FT_CTIPI, FT_CSTPIS, FT_CSTCOF,  F4_ICM, F4_IPI, F4_CREDICM, F4_CREDIPI, F4_DUPLIC, "+ CRLF
	cQuery += " B1_DESC, B1_XDESCL1, B1_GRUPO, B1_POSIPI, B1_CEST, B1_ORIGEM, B1_EX_NCM, "											+ CRLF
	cQuery += "	F1_ESPECIE, F1_CODNFE, F1_MENNOTA, F1_DOC, F1_SERIE, F1_STATUS, F1_TIPO, FT_CHVNFE,"								+ CRLF
	cQuery += " FT_VALCONT, D1_CONTA, D1_ITEMCTA, D1_NFORI, D1_SERIORI, D1_VUNIT, D1_TOTAL, "										+ CRLF
	cQuery += " D1_DESC, FT_CLASFIS, FT_BASERET, FT_ICMSRET, D1_DESCZFP, D1_DESCZFC,  "												+ CRLF
	cQuery += " F1_UFORITR, F1_MUORITR, F1_UFDESTR, F1_MUDESTR,  "																	+ CRLF
	cQuery += " FT_BASEICM, FT_ALIQICM, FT_VALICM, "																				+ CRLF
	cQuery += " FT_BASEIPI, FT_ALIQIPI, FT_VALIPI, FT_ARETPIS, FT_ARETCOF, FT_VRETPIS, FT_VRETCOF, FT_BRETPIS, " 					+ CRLF
	cQuery += " D1_BASIMP6, D1_ALQIMP6, D1_VALIMP6, FT_BRETCOF, " 																	+ CRLF
	cQuery += " D1_BASIMP5, D1_ALQIMP5, D1_VALIMP5, " 																				+ CRLF
	cQuery += " FT_BASEPIS, FT_ALIQPIS, FT_VALPIS, FT_ALIQPS3, FT_VALPS3, "															+ CRLF
	cQuery += " FT_BASECOF, FT_ALIQCOF, FT_VALCOF, FT_DIFAL, FT_BASECF3, FT_ALIQCF3, FT_VALCF3, FT_BASEPS3, "						+ CRLF
	cQuery += " FT_BASEIRR, FT_ALIQIRR, FT_VALIRR, F3_OUTRIPI, F3_ISENIPI, F3_OUTRICM, F3_ISENICM, " 								+ CRLF
	cQuery += " FT_BASECSL, FT_ALIQCSL, FT_VALCSL, D1_UM, D1_QUANT, D1_CHASSI, "													+ CRLF
	cQuery += " FT_BASEINS, FT_ALIQINS, D1_ABATINS, D1_AVLINSS, FT_VALINS, C7_NUM, FT_FORMUL, "										+ CRLF
	cQuery += " D1_BASEISS, D1_ALIQISS, D1_ABATISS, D1_ABATMAT, D1_VALISS, FT_CODBCC, FT_INDNTFR, "									+ CRLF
	cQuery += " D1_VALFRE, D1_DESPESA, D1_CUSTO, D1_SEGURO, D1_VALACRS, D1_II, FT_ICMSCOM, D1_TNATREC, D1_CONHEC,  "				+ CRLF
	cQuery += " D1_PESO, FT_MVALPIS, FT_MVALCOF, W6_DTREG_D, W6_DI_NUM, YD_PER_II, VRK_OPCION, W9_TX_FOB, D1_CHASSI "							+ CRLF

	cQuery += " ORDER BY SD1.D1_FILIAL, SD1.D1_EMISSAO, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_ITEM, SD1.D1_FORNECE, SD1.D1_LOJA "		+ CRLF

	cQuery := ChangeQuery(cQuery)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

	DbSelectArea((cAliasTRB))
	nTotReg := Contar(cAliasTRB,"!Eof()")
	(cAliasTRB)->(dbGoTop())
	If (cAliasTRB)->(!Eof())

		// Criando o objeto que irá gerar o conteúdo do Excel.
		oFWMsExcel := FWMSExcelEx():New()

		// Aba 01
		oFWMsExcel:AddworkSheet(cAba1) // Não utilizar número junto com sinal de menos. Ex.: 1-.

		// Criando a Tabela.
		oFWMsExcel:AddTable( cAba1	,cTabela1	)

		// Criando Colunas.
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cnpj/Cpf"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Insc.Estadual"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Pessoa Fisica/Juridica"		,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"UF"							,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tes"							,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Finalidade TES"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Origem do Produto"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"NCM"							,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Ex-NBM"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Modelo Veículo"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Opcional"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Grupo\Linha"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descrição do Grupo"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Total Item"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cfop"							,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Contábil"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base ICMS"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. ICMS"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor ICMS"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Comissão"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base IPI"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. IPI"					,2	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor IPI"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Credito_Presumido IPI/Frete"	,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Credito_Regional IPI"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Subst"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Subst"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Pis Apuração"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Pis Apuração"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Pis Apuração"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Cofins Apuração"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Cofins Apuração"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Cofins Apuração"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base PIS ST ZFM"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. PIS ST ZFM"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Vl. PIS ST ZFM"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base COF ST ZFM"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. COF ST ZFM"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Vl. COF ST ZFM"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"ICMS Difal"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"CST ICMS"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"CST IPI"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"CST PIS"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"CST COFINS"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Calcula ICMS"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Credita ICMS"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Calcula IPI"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Credita IPI"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nota Fiscal"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nf. Prefeitura"				,1	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Série"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Espécie"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Modelo"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt. de Entrada"				,2	,4	,.F.	) // Center - Data
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt. de Emissão"				,2	,4	,.F.	) // Center - Data
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Fornecedor\Cliente"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Loja"							,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nome"							,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Chassi"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cód.Produto"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descrição do Produto"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descrição Científico"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descrição Longa"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Un Medida"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Quant."						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Unit. Item"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Desconto Item"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Frete"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Despesas Acessorias"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Seguro"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Acrescimo"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Custo"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor do Dif. de Aliq."		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. II"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor II"						,3	,2	,.F.	) // Right - Number
		//oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base PIS Importação"			,3	,2	,.F.	) // Right - Number
		//oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. PIS Importação"			,3	,2	,.F.	) // Right - Number
		//oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor PIS Importação"			,3	,2	,.F.	) // Right - Number
		//oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Cofins Importação"		,3	,2	,.F.	) // Right - Number
		//oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Cofins Importação"		,3	,2	,.F.	) // Right - Number
		//oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Cofins Importação"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Num. Conhecimento"			,2	,3	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Num. DI"						,2	,3	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Data DI"						,2	,4	,.F.	) // Center - Data
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Conta Contábil"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Desc.Conta Contábil"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Empresa"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Situação"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tipo Nota Fiscal"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Formulario"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Chave Nota Fiscal"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Protocolo"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nota Fiscal Origem"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tipo Cli\For"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cli\For"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Estado"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Município"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"CEST"							,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descr. Modelo Veículo"		,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Combustível Veículo"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descrição CFOP"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cód.Verificação"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Ambiente"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Irrf Retenção"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Irrf Retenção"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Irrf Retenção"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Inss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Inss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Inss Recolhido"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Inss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Iss"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Iss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Iss Serviços"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Iss Materiais"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Iss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Inss Serviços"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Csll"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Csll"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Csll"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Pis Retenção"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Pis Retenção"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Pis Retenção"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Cofins Retenção"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Cofins Retenção"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Cofins Retenção"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Msgn Nota Fiscal"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Log. de Inclusão"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Log. de Alteração"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt. Log. de Alteração"		,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Num. Pedido Compra"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Natureza Financeira"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tab. Nat. Receita"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Item Contábil"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"ICMS Isento"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"ICMS Outros"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"IPI Isento"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"IPI Outros"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Peso Total"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Natureza Base de Calculo"		,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Natureza Frete"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"UF Origem do Transporte"		,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Mun. Orig. do Transporte"		,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"UF Destino do Transporte"		,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Mun. Dest. do Transporte"		,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Msgn Sefaz"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Gera Duplicata"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Taxa Cambial"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Chassi"				    	,1	,1	,.F.	) // Right - Number
		
		// Conta quantos registros existem, e seta no tamanho da régua.
		ProcRegua( nTotReg )

		SF1->( DbSetOrder(1) ) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		VV2->( DbSetOrder(7) ) // VV2_FILIAL+VV2_PRODUT
		SA1->( DbSetOrder(1) ) // A1_FILIAL+A1_COD+A1_LOJA
		SA2->( DbSetOrder(1) ) // A2_FILIAL+A2_COD+A2_LOJA
		CDA->( DbSetOrder(1) ) // CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA+CDA_NUMITE
		SE1->( DbSetOrder(2) ) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		SE2->( DbSetOrder(6) ) // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		SC6->( DbSetOrder(4) ) // C6_FILIAL+C6_NOTA+C6_SERIE

		DbSelectArea((cAliasTRB))
		(cAliasTRB)->(dbGoTop())
		While (cAliasTRB)->(!EoF())

			// Incrementa a mensagem na régua.
			IncProc("Exportando informações para Excel...")

			// TRATAMENTO PARA BUSCAR O LOG DO USUÁRIO.
			cLogInc 	:= ""
			cLogAlt		:= ""
			cDtLogAlt 	:= "" 
			If SF1->(dbSeek( (cAliasTRB)->D1_FILIAL + (cAliasTRB)->D1_DOC + (cAliasTRB)->D1_SERIE + (cAliasTRB)->D1_FORNECE + (cAliasTRB)->D1_LOJA ))
				cLogInc		:= FWLeUserLg("F1_USERLGI")
				cLogAlt		:= FWLeUserLg("F1_USERLGA")
				cDtLogAlt	:= FWLeUserLg("F1_USERLGA", 2)
			EndIf

			// Busca informações da Nota Fiscal no servidor TSS.
			cAmbiente 	:= ""
			cProtocolo	:= ""
			cMsgSefaz 	:= ""
			aInfNfe		:= {}
			//--Trecho removido pois estava causando lentidão, estes campos serão utilizados em um relatorio a parte
			/*If AllTrim( (cAliasTRB)->F1_ESPECIE ) $ "SPED"
				aInfNfe 	:= U_zFATF001( (cAliasTRB)->F1_SERIE	,(cAliasTRB)->F1_DOC )
				cAmbiente 	:= AllTrim( aInfNfe[1,3] )
				cProtocolo 	:= AllTrim( aInfNfe[1,6] )
				cMsgSefaz 	:= AllTrim( aInfNfe[1,5] )
			EndIf*/

			// Busca o Status da Nota Fiscal.
			cSituacao	:= ""
			Do Case
				Case Empty( (cAliasTRB)->F1_STATUS )
					cSituacao	:= "Docto. nao Classificado"
				Case (cAliasTRB)->F1_STATUS == "B"
					cSituacao	:= "Docto. Bloqueado"
				Case (cAliasTRB)->F1_STATUS == "C"
					cSituacao	:= "Doc. C/Bloq. de Mov."
				Case (cAliasTRB)->F1_TIPO == "N"
					cSituacao	:= "Docto. Normal"
				Case (cAliasTRB)->F1_TIPO == "P"
					cSituacao	:= "Docto. de Compl. IPI"
				Case (cAliasTRB)->F1_TIPO == "I"
					cSituacao	:= "Docto. de Compl. ICMS"
				Case (cAliasTRB)->F1_TIPO == "C"
					cSituacao	:= "Docto. de Compl. Preco/Frete/Desp. Imp."
				Case (cAliasTRB)->F1_TIPO == "B"
					cSituacao	:= "Docto. de Beneficiamento"
				Case (cAliasTRB)->F1_TIPO == "D"
					cSituacao	:= "Docto. de Devolucao"
				OtherWise
					cSituacao	:= ""
			EndCase
	
			// Busca o Modelo do Veiculo
			cModVei		:= ""
			cDesMod		:= ""
			cComVei 	:= ""
			If VV2->(DbSeek( xFilial("VV2") + (cAliasTRB)->D1_COD ))
				cModVei	:= AllTrim( VV2->VV2_MODVEI )
				cDesMod	:= AllTrim( VV2->VV2_DESMOD )
				cComVei	:= X3Combo( "VV2_COMVEI"	,VV2->VV2_COMVEI	)
			Endif

			cCliFor 	:= ""
			cCgcCpf		:= ""
			cIncEst		:= ""
			cDescTipo	:= ""
			cTpCliFor	:= ""
			cTpPessoa	:= ""
			If (cAliasTRB)->F1_TIPO $ "B|D" // Benefeciamento ou devolução
				If SA1->(DbSeek( xFilial("SA1") + (cAliasTRB)->D1_FORNECE + (cAliasTRB)->D1_LOJA ))
					cCliFor		:= SA1->A1_NOME
					cIncEst 	:= SA1->A1_INSCR
					cCgcCpf 	:= IIF( Len( Alltrim( SA1->A1_CGC) )>11 ,Transform( SA1->A1_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA1->A1_CGC ,"@R 999.999.999-99" ) ) 
					cEstCli 	:= SA1->A1_EST
					cCodMun		:= SA1->A1_COD_MUN
					cTpCliFor	:= "Cliente"

					If SA1->A1_PESSOA == "J"
						cTpPessoa := "Juridico"
					ElseIf SA1->A1_PESSOA == "F"
						cTpPessoa := "Fisico"
					Else
						cTpPessoa := ""
					Endif

					// Busca o Tipo do Cliente.
					Do Case
						Case SA1->A1_TIPO == "F"
							cDescTipo	:= "Cons.Final"
						Case SA1->A1_TIPO == "L"
							cDescTipo	:= "Produtor Rural"
						Case SA1->A1_TIPO == "R"
							cDescTipo	:= "Revendedor"
						Case SA1->A1_TIPO == "S"
							cDescTipo	:= "Solidario"
						Case SA1->A1_TIPO == "X"
							cDescTipo	:= "Exportacao"
						OtherWise
							cDescTipo	:= ""
					EndCase

					//--Posiciono no titulo a receber para pegar a natureza financeira
					cCodNatur := ""
					If SE1->( DbSeek( FWxFilial('SE1') + (cAliasTRB)->( D1_FORNECE + D1_LOJA + D1_SERIE + D1_DOC  ) ) )
						//--Posiciono no primeiro registro lógico porque mesmo que existam parcelas a natureza ira se repetir nos demais registros
						SE1->( DbGoTop() )
						cCodNatur := SE1->E1_NATUREZ
					EndIf

					cCodChassi 	:= ""
					nVlCom		:= 0
					If SC6->( DbSeek(FWxFilial('SC6') + (cAliasTRB)->D1_NFORI + (cAliasTRB)->D1_SERIORI ) )
						cCodChassi 	:= SC6->C6_CHASSI
						nVlCom		:= SC6->C6_XVLCOM
					EndIf
				Else
					cCliFor		:= "CLIENTE NÃO ENCONTRADO NA BASE DE DADOS"
					cIncEst 	:= ""
					cCgcCpf 	:= ""
					cDescTipo	:= ""
					cEstCli		:= ""
					cCodMun		:= ""
					cTpCliFor	:= "Cliente"
					cTpPessoa	:= ""
				EndIf
			Else
				If SA2->(DbSeek( xFilial("SA2") + (cAliasTRB)->D1_FORNECE + (cAliasTRB)->D1_LOJA ))
					cCliFor		:= SA2->A2_NOME
					cIncEst 	:= SA2->A2_INSCR
					cCgcCpf 	:= IIF( Len( Alltrim( SA2->A2_CGC) )>11 ,Transform( SA2->A2_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA2->A2_CGC ,"@R 999.999.999-99" ) ) 
					cEstCli		:= SA2->A2_EST
					cCodMun		:= SA2->A2_COD_MUN
					cTpCliFor	:= "Fornecedor"

					// Busca o Tipo do Fornecedor.
					If SA2->A2_TIPO == "J"
						cDescTipo := "Juridico"
					ElseIf SA2->A2_TIPO == "F"
						cDescTipo := "Fisico"
					ElseIf SA2->A2_TIPO == "X"
						cDescTipo := "Outros"
					Else
						cDescTipo := ""
					Endif

					cTpPessoa := cDescTipo

					//--Posiciono no titulo a pagar para pegar a natureza financeira
					cCodNatur := ""
					If SE2->( DbSeek( FWxFilial('SE2') + (cAliasTRB)->( D1_FORNECE + D1_LOJA + D1_SERIE + D1_DOC  ) ) )
						//--Posiciono no primeiro registro lógico porque mesmo que existam parcelas a natureza ira se repetir nos demais registros
						SE2->( DbGoTop() )
						cCodNatur := SE2->E2_NATUREZ
					EndIf 
					
				Else
					cCliFor		:= "FORNECEDOR NÃO ENCONTRADO NA BASE DE DADOS"
					cIncEst 	:= ""
					cCgcCpf		:= ""
					cDescTipo	:= ""
					cEstCli		:= ""
					cCodMun		:= ""
					cTpCliFor	:= "Fornecedor"
					cTpPessoa	:= ""
				EndIf
			EndIf

			//Verifica o tipo da Nota Fiscal
			cTpNF := ""
			Do Case
				Case (cAliasTRB)->F1_TIPO == "N"
					cTpNF	:= "NF Normal"
				Case (cAliasTRB)->F1_TIPO == "P"
					cTpNF	:= "NF de Compl. IPI"
				Case (cAliasTRB)->F1_TIPO== "I"
					cTpNF	:= "NF de Compl. ICMS"
				Case (cAliasTRB)->F1_TIPO == "C"
					cTpNF	:= "NF de Compl. Preco/Frete"
				Case (cAliasTRB)->F1_TIPO == "B"
					cTpNF	:= "NF de Beneficiamento"
				Case (cAliasTRB)->F1_TIPO == "D"
					cTpNF	:= "NF de Devolucao"
				OtherWise
					cTpNF	:= "Tipo não encontrado"
			EndCase

			nVlIPIRegi := 0
			nVlIPIPres := 0
			//-- Retorna Valor de IPI regional e presumido
			zRel0003(@nVlIPIRegi, @nVlIPIPres, (cAliasTRB)->F1_ESPECIE, (cAliasTRB)->F1_DOC, (cAliasTRB)->F1_SERIE,;
					(cAliasTRB)->D1_FORNECE, (cAliasTRB)->D1_LOJA, (cAliasTRB)->D1_ITEM )

			oFWMSExcel:AddRow( cAba1	,cTabela1	,{ 	cCgcCpf,;    //--Cnpj/Cpf 
														cIncEst,;    //--Insc.Estadual
														cTpPessoa,;    //--Pessoa Fisica/Juridica
														cEstCli,;    //--UF
														(cAliasTRB)->D1_TES,;    //--Tes
														Alltrim( (cAliasTRB)->F4_FINALID ),;    //--Finalidade TES
														AllTrim( (cAliasTRB)->B1_ORIGEM ),;    //--Origem do Produto
														AllTrim( (cAliasTRB)->B1_POSIPI ),;    //--NCM
														AllTrim( (cAliasTRB)->B1_EX_NCM ),;    //--Ex-NBM
														AllTrim( cModVei ),;    //--Modelo Veículo
														AllTrim( (cAliasTRB)->VRK_OPCION ),;    //--Opcional
														AllTrim( (cAliasTRB)->B1_GRUPO ),;    //--Grupo\Linha
														AllTrim( Posicione("SBM",1,xFilial("SBM")+(cAliasTRB)->B1_GRUPO,"BM_DESC") ),;    //--Descrição do Grupo
														(cAliasTRB)->D1_TOTAL,;    //--Valor Total Item
														(cAliasTRB)->D1_CF,;    //--Cfop
														(cAliasTRB)->FT_VALCONT,;    //--Valor Contábil
														(cAliasTRB)->FT_BASEICM,;    //--Base ICMS
														(cAliasTRB)->FT_ALIQICM,;    //--Aliq. ICMS
														(cAliasTRB)->FT_VALICM,;    //--Valor ICMS
														IIF( (cAliasTRB)->F1_TIPO $ "B|D" , nVlCom , 0 ),;    //--Comissão
														(cAliasTRB)->FT_BASEIPI,;    //--Base IPI					
														(cAliasTRB)->FT_ALIQIPI,;    //--Aliq. IPI			
														(cAliasTRB)->FT_VALIPI,;    //--Valor IPI
														nVlIPIPres,;    //--Credito_Presumido IPI/Frete
														nVlIPIRegi,;    //--Credito_Regional IPI
														(cAliasTRB)->FT_BASERET,;    //--Base Subst
														(cAliasTRB)->FT_ICMSRET,;    //--Valor Subst
														(cAliasTRB)->FT_BASEPIS,;    //--Base Pis Apuração
														(cAliasTRB)->FT_ALIQPIS,;    //--Aliq. Pis Apuração
														(cAliasTRB)->FT_VALPIS,;    //--Valor Pis Apuração
														(cAliasTRB)->FT_BASECOF,;    //--Base Cofins Apuração
														(cAliasTRB)->FT_ALIQCOF,;    //--Aliq. Cofins Apuração
														(cAliasTRB)->FT_VALCOF,;    //--Valor Cofins Apuração
														(cAliasTRB)->FT_BASEPS3,;    //--Base Pis ST ZFM
														(cAliasTRB)->FT_ALIQPS3,;    //--Aliq. Pis ST ZFM
														(cAliasTRB)->FT_VALPS3,;	//--Vl. Pis ST ZFM
														(cAliasTRB)->FT_BASECF3,;    //--Base Cof ST ZFM
														(cAliasTRB)->FT_ALIQCF3,;    //--Aliq. Cof ST ZFM
														(cAliasTRB)->FT_VALCF3,;	//--Vl. Cof ST ZFM
														(cAliasTRB)->FT_DIFAL,;    //--ICMS Difal
														(cAliasTRB)->FT_CLASFIS,;    //--CST ICMS
														(cAliasTRB)->FT_CTIPI,;    //--CST IPI
														(cAliasTRB)->FT_CSTPIS,;    //--CST PIS
														(cAliasTRB)->FT_CSTCOF,;    //--CST COFINS
														(cAliasTRB)->F4_ICM,;    //--Calcula ICMS
														(cAliasTRB)->F4_CREDICM,;    //--Credita ICMS
														(cAliasTRB)->F4_IPI,;    //--Calcula IPI
														(cAliasTRB)->F4_CREDIPI,;    //--Credita IPI
														(cAliasTRB)->D1_DOC,;    //--Nota Fiscal
														IIF( AllTrim( (cAliasTRB)->F1_ESPECIE ) == "NFS", (cAliasTRB)->D1_DOC, ""),;    //--Nf. Prefeitura
														(cAliasTRB)->D1_SERIE,;    //--Série
														(cAliasTRB)->F1_ESPECIE,;    //--Espécie
														AModNot( (cAliasTRB)->F1_ESPECIE ),;    //--Modelo
														IIF( Empty( SToD( (cAliasTRB)->D1_DTDIGIT ) ), "", SToD( (cAliasTRB)->D1_DTDIGIT ) ),;    //--Dt. de Entrada
														IIF( Empty( SToD( (cAliasTRB)->D1_EMISSAO ) ), "", SToD( (cAliasTRB)->D1_EMISSAO ) ),;    //--Dt. de Emissão
														(cAliasTRB)->D1_FORNECE,;    //--Fornecedor\Cliente
														(cAliasTRB)->D1_LOJA,;    //--Loja
														cCliFor,;    //--Nome
														IIF( (cAliasTRB)->F1_TIPO $ "B|D" , cCodChassi ,AllTrim( (cAliasTRB)->D1_CHASSI ) ),;    //--Chassi
														(cAliasTRB)->D1_COD,;    //--Cód.Produto
														Substr( (cAliasTRB)->B1_DESC ,01 ,15 ),;    //--Descrição do Produto
														AllTrim( Posicione("SB5",1,xFilial("SB5")+(cAliasTRB)->D1_COD,"B5_CEME") ),;    //--Descrição Científico
														AllTrim( (cAliasTRB)->B1_XDESCL1 ),;    //--Descrição Longa
														AllTrim( (cAliasTRB)->D1_UM ),;    //--Un Medida
														(cAliasTRB)->D1_QUANT,;    //--Quant.
														(cAliasTRB)->D1_VUNIT,;    //--Valor Unit. Item
														(cAliasTRB)->D1_DESC,;    //--Desconto Item
														(cAliasTRB)->D1_VALFRE,;    //--Frete
														(cAliasTRB)->D1_DESPESA,;    //--Despesas Acessorias
														(cAliasTRB)->D1_SEGURO,;    //--Seguro
														(cAliasTRB)->D1_VALACRS,;    //--Acrescimo
														(cAliasTRB)->D1_CUSTO,;    //--Custo
														(cAliasTRB)->FT_ICMSCOM,;    //--Valor do Dif. de Aliq.
														(cAliasTRB)->YD_PER_II,;    //--Aliq. II
														(cAliasTRB)->D1_II,;    //--Valor II
														(cAliasTRB)->D1_CONHEC,;    //--Num. Conhecimento
														(cAliasTRB)->W6_DI_NUM,;    //--Num. DI
														IIF( Empty( SToD( (cAliasTRB)->W6_DTREG_D ) ), "", SToD( (cAliasTRB)->W6_DTREG_D ) ),;    //--Data DI
														(cAliasTRB)->D1_CONTA,;    //--Conta Contábil
														AllTrim( Posicione("CT1",1,xFilial("CT1")+(cAliasTRB)->D1_CONTA,"CT1_DESC01") ),;    //--Desc.Conta Contábil
														AllTrim( (cAliasTRB)->D1_FILIAL ),;    //--Empresa
														cSituacao,;    //--Situação
														cTpNF,;    //--Tipo Nota Fiscal
														(cAliasTRB)->FT_FORMUL,;    //--Formulario
														(cAliasTRB)->FT_CHVNFE,;    //--Chave Nota Fiscal
														cProtocolo,;    //--Protocolo
														AllTrim( (cAliasTRB)->D1_NFORI ) + " - " + AllTrim( (cAliasTRB)->D1_SERIORI ),;    //--Nota Fiscal Origem
														cDescTipo,;    //--Tipo Cli\For
														cTpCliFor,;    //--Cli\For
														AllTrim(Posicione("SX5",1, xFilial("SX5")+"12"+ cEstCli ,"X5_DESCRI")),;    //--Estado
														AllTrim(Posicione("CC2",1, xFilial("CC2")+ cEstCli +PadR( cCodMun ,TamSx3("CC2_CODMUN")[1]) , "CC2_MUN")),;    //--Município
														AllTrim( (cAliasTRB)->B1_CEST ),;    //--CEST
														AllTrim( cDesMod ),;    //--Descr. Modelo Veículo
														AllTrim( cComVei ),;    //--Combustível Veículo
														AllTrim( (cAliasTRB)->F4_TEXTO ),;    //--Descrição CFOP
														(cAliasTRB)->F1_CODNFE,;    //--Cód.Verificação
														cAmbiente,;    //--Ambiente
														(cAliasTRB)->FT_BASEIRR,;    //--Base Irrf Retenção
														(cAliasTRB)->FT_ALIQIRR,;    //--Aliq. Irrf Retenção
														(cAliasTRB)->FT_VALIRR,;    //--Irrf Retenção
														(cAliasTRB)->FT_BASEINS,;    //--Base Inss
														(cAliasTRB)->FT_ALIQINS,;    //--Aliq. Inss
														(cAliasTRB)->D1_ABATINS,;    //--Inss Recolhido
														(cAliasTRB)->FT_VALINS,;    //--Valor Inss
														(cAliasTRB)->D1_BASEISS,;    //--Base Iss
														(cAliasTRB)->D1_ALIQISS,;    //--Aliq. Iss
														(cAliasTRB)->D1_ABATISS,;    //--Iss Serviços
														(cAliasTRB)->D1_ABATMAT,;    //--Iss Materiais
														(cAliasTRB)->D1_VALISS,;    //--Valor Iss
														(cAliasTRB)->D1_AVLINSS,;    //--Inss Serviços
														(cAliasTRB)->FT_BASECSL,;    //--Base Csll
														(cAliasTRB)->FT_ALIQCSL,;    //--Aliq. Csll
														(cAliasTRB)->FT_VALCSL,;    //--Valor Csll
														(cAliasTRB)->FT_BRETPIS,;    //--Base Pis Retenção
														(cAliasTRB)->FT_ARETPIS,;    //--Aliq. Pis Retenção
														(cAliasTRB)->FT_VRETPIS,;    //--Valor Pis Retenção
														(cAliasTRB)->FT_BRETCOF,;    //--Base Cofins Retenção
														(cAliasTRB)->FT_ARETCOF,;    //--Aliq. Cofins Retenção
														(cAliasTRB)->FT_VRETCOF,;    //--Valor Cofins Retenção
														(cAliasTRB)->F1_MENNOTA,;    //--Msgn Nota Fiscal
														cLogInc,;    //--Log. de Inclusão
														cLogAlt,;    //--Log. de Alteração
														cDtLogAlt,;    //--Dt. Log. de Alteração
														(cAliasTRB)->C7_NUM,;    //--Num. Pedido Compra
														cCodNatur,;    //--Natureza Financeira
														(cAliasTRB)->D1_TNATREC,;    //--Tab. Nat. Receita
														(cAliasTRB)->D1_ITEMCTA,;    //--Item Contábil
														(cAliasTRB)->F3_ISENICM,;    //--ICMS Isento
														(cAliasTRB)->F3_OUTRICM,;    //--ICMS Outros
														(cAliasTRB)->F3_ISENIPI,;    //--IPI Isento
														(cAliasTRB)->F3_OUTRIPI,;    //--IPI Outros
														(cAliasTRB)->D1_PESO,;    //--Peso Total
														(cAliasTRB)->FT_CODBCC,;    //--Natureza Base de Calculo
														(cAliasTRB)->FT_INDNTFR,;    //--Natureza Frete
														(cAliasTRB)->F1_UFORITR,;    //--UF Origem do Transporte
														(cAliasTRB)->F1_MUORITR,;    //--Mun. Orig. do Transporte
														(cAliasTRB)->F1_UFDESTR,;    //--UF Destino do Transporte
														(cAliasTRB)->F1_MUDESTR,;    //--Mun. Dest. do Transporte
														cMsgSefaz,;    //--Msgn Sefaz		
														Alltrim( (cAliasTRB)->F4_DUPLIC ),;	//--Gera Duplicata 
														(cAliasTRB)->W9_TX_FOB ,;	//--Taxa Cambial  		
														(cAliasTRB)->D1_CHASSI })	//--Taxa Cambial  												     														 
			(cAliasTRB)->(DbSkip())
		EndDo

		If Select( (cTMPCanc) ) > 0
			(cTMPCanc)->(DbCloseArea())
		EndIf

		//-- Verifica notas canceladas
		cQuery := " SELECT F3_FILIAL, F3_OBSERV, F3_ESPECIE, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, "	+ CRLF
		cQuery += " F3_EMISSAO, F3_CHVNFE, F3_DESCRET, F3_ENTRADA "											+ CRLF
		cQuery += " FROM " + RetSQLName( 'SF3' ) + " SF3 " 													+ CRLF
		cQuery += " INNER JOIN " + RetSQLName( 'SF1' ) + " SF1 "											+ CRLF
		cQuery += " 	ON SF1.F1_FILIAL = '" + FWxFilial('SF1') + "' "	 									+ CRLF
		cQuery += " 	AND SF1.F1_DOC = SF3.F3_NFISCAL "													+ CRLF
		cQuery += " 	AND SF1.F1_SERIE = SF3.F3_SERIE "													+ CRLF
		cQuery += " 	AND SF1.F1_FORNECE = SF3.F3_CLIEFOR "												+ CRLF
		cQuery += " 	AND SF1.F1_LOJA = SF3.F3_LOJA "														+ CRLF

		If !Empty( MV_PAR19 )
			cQuery += " 	AND SF1.F1_EST = '" + MV_PAR19 + "' " 											+ CRLF
		EndIf

		cQuery += " INNER JOIN " + RetSQLName( 'SD1' ) + " SD1 "											+ CRLF
		cQuery += " 	ON SD1.D1_FILIAL = '" + FWxFilial('SD1') + "' "	 									+ CRLF
		cQuery += " 	AND SD1.D1_DOC = SF3.F3_NFISCAL "													+ CRLF
		cQuery += " 	AND SD1.D1_SERIE = SF3.F3_SERIE "													+ CRLF
		cQuery += " 	AND SD1.D1_FORNECE = SF3.F3_CLIEFOR "												+ CRLF
		cQuery += " 	AND SD1.D1_LOJA = SF3.F3_LOJA "														+ CRLF
		cQuery += " 	AND SD1.D1_COD BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR16 + "' " 					+ CRLF

		If !Empty( MV_PAR17 )
			cQuery += " 	AND SD1.D1_TES = '" + MV_PAR17 + "' " 											+ CRLF
		EndIf

		If !Empty( MV_PAR18 )
			cQuery += " 	AND SD1.D1_CF = '" + MV_PAR18 + "' " 											+ CRLF
		EndIf

		cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 " 												+ CRLF
		cQuery += "		ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "										+ CRLF
		cQuery += "		AND SB1.B1_COD = SD1.D1_COD   "	 													+ CRLF
		cQuery += "		AND SB1.D_E_L_E_T_ = ' ' " 															+ CRLF

		If !Empty( MV_PAR20 )
			cQuery += " 	AND SB1.B1_GRUPO = '" + MV_PAR20 + "' "											+ CRLF
		EndIf

		If !Empty( MV_PAR21 )
			cQuery += " 	AND SB1.B1_POSIPI = '" + MV_PAR21 + "' "										+ CRLF
		EndIf

		cQuery += " WHERE  SF3.F3_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "				+ CRLF
		cQuery += " 	AND SF3.F3_ESPECIE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "				+ CRLF
		cQuery += " 	AND SF3.F3_NFISCAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "				+ CRLF
		cQuery += " 	AND SF3.F3_SERIE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "				+ CRLF
		cQuery += " 	AND SF3.F3_CLIEFOR BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' " 				+ CRLF
		cQuery += " 	AND SF3.F3_ENTRADA BETWEEN '" + DToS(MV_PAR11) + "' AND '" + DToS(MV_PAR12) + "' "	+ CRLF
		cQuery += " 	AND SF3.F3_EMISSAO BETWEEN '" + DToS(MV_PAR13) + "' AND '" + DToS(MV_PAR14) + "' " 	+ CRLF
		cQuery += " 	AND SF3.F3_DTCANC != ' ' " 															+ CRLF
		cQuery += " 	AND SF3.D_E_L_E_T_ = ' '   " 														+ CRLF

		cQuery += " GROUP BY F3_FILIAL, F3_OBSERV, F3_ESPECIE, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, " + CRLF
		cQuery += " F3_EMISSAO, F3_CHVNFE, F3_DESCRET, F3_ENTRADA "											+ CRLF

		cQuery += " ORDER BY SF3.F3_FILIAL, SF3.F3_NFISCAL, SF3.F3_SERIE, SF3.F3_CLIEFOR, SF3.F3_LOJA "		+ CRLF															+ CRLF

		cQuery := ChangeQuery(cQuery)

		// Executa a consulta.
		DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cTMPCanc, .T., .T. )

		DbSelectArea((cTMPCanc))
		(cTMPCanc)->(dbGoTop())
		If (cTMPCanc)->(!Eof())

			// Aba 02
			oFWMsExcel:AddworkSheet(cAba2) //Não utilizar número junto com sinal de menos. Ex.: 1-.

			// Criando a Tabela.
			oFWMsExcel:AddTable( cAba2	,cTabela2	)

			// Criando Colunas.
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Empresa"				,1	,1	,.F.	) // Left - Texto	
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Observação"			,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Especie"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Nota Fiscal"			,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Serie"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Cliente"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Loja/Cli"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Emissão"				,2	,4	,.F.	) // Center - Data
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Dt Digitação"			,2	,4	,.F.	) // Center - Data
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Chave NFe"			,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Descrição"			,2	,1	,.F.	) // Center - Texto


			While (cTMPCanc)->(!EoF())
				
				oFWMSExcel:AddRow( cAba2	, cTabela2	, { Alltrim( (cTMPCanc)->F3_FILIAL ),;    //--Empresa
															Alltrim( (cTMPCanc)->F3_OBSERV ),;    //--Observação
															Alltrim( (cTMPCanc)->F3_ESPECIE ),;    //--Especie
															Alltrim( (cTMPCanc)->F3_NFISCAL ),;    //--Nota Fiscal
															Alltrim( (cTMPCanc)->F3_SERIE ),;    //--Serie
															Alltrim( (cTMPCanc)->F3_CLIEFOR ),;    //--Cliente
															Alltrim( (cTMPCanc)->F3_LOJA ),;    //--Loja/Cli
															IIF( Empty( SToD( (cTMPCanc)->F3_EMISSAO ) ), "", SToD( (cTMPCanc)->F3_EMISSAO ) ),;    //--Emissão
															IIF( Empty( SToD( (cTMPCanc)->F3_ENTRADA ) ), "", SToD( (cTMPCanc)->F3_ENTRADA ) ),;    //--Dt Digitação
															AllTrim( (cTMPCanc)->F3_CHVNFE ),;    //--Chave NFe
															AllTrim( (cTMPCanc)->F3_DESCRET ) } )    //--Descrição
				(cTMPCanc)->(DbSkip())
			EndDo

		EndIf

		// Ativando o arquivo e gerando o xml.
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)

		oFWMsExcel:DeActivate()
		FreeObj(oFWMsExcel)

		// Abrindo o excel e abrindo o arquivo xml.
		oExcel := MsExcel():New()           // Abre uma nova conexão com Excel.
		oExcel:WorkBooks:Open(cArquivo)     // Abre uma planilha.
		oExcel:SetVisible(.T.)              // Visualiza a planilha.
		oExcel:Destroy()                    // Encerra o processo do gerenciador de tarefas.

	Else
		ApMsgAlert( "Não foi encontrado nenhuma nota fiscal com os parâmetros informados!!" )
	EndIf

	opPar:End()
	(cAliasTRB)->(DbCloseArea())
	IIF( Select( cTMPCanc ) > 0, (cTMPCanc)->( DbCloseArea() ), Nil )
	DbSelectArea("SA2")

Return()
/*
=====================================================================================
Programa.:              zRel0002
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              13/06/19
Descricao / Objetivo:   Gera Excel Notas de Saida
Doc. Origem:            GAP EST007 E GAP FAT022
Solicitante:            Fiscal
Uso......:              zSelect
Obs......:
=====================================================================================
*/
Static Function zRel0002(cArquivo)

	Local cQuery		:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cTMPCanc		:= GetNextAlias()
	Local cAba1			:= "Notas Fiscais de Saída"
	Local cAba2			:= "Notas Fiscais Canceladas"
	Local cTabela1		:= "Relação de Notas Fiscais de Saída"
	Local cTabela2		:= "Relação de Notas Fiscais Canceladas"
	Local cDescTipo		:= ""
	Local cLogInc 		:= ""
	Local cLogAlt 		:= ""
	Local cDtLogAlt		:= ""
	Local cAmbiente		:= ""
	Local cProtocolo	:= ""
	Local cMsgSefaz		:= ""
	Local cSituacao		:= ""
	Local cComVei		:= ""
	Local cModVei		:= ""
	Local cDesMod		:= ""
	Local cCliFor		:= ""
	Local cCgcCpf		:= ""
	Local cIncEst		:= ""
	Local cEstCli		:= ""
	Local cCodMun		:= ""
	Local cTpCliFor		:= ""
	Local cTpPessoa		:= ""
	Local cTpNF			:= ""			
	Local aInfNfe		:= {}
	Local cNumPed 		:= ""
	Local nVlrFrete 	:= 0
	Local nVlrSeguro	:= 0
	Local nVlrDesp		:= 0
	Local cMenNota		:= ""
	Local cMenPad		:= ""
	Local cNaturez		:= ""
	Local cTransp		:= ""
	Local cMensNFS		:= ""
	Local oFWMsExcel
	Local oExcel
	Local cCGCLocEnt	:= ""
	Local cNomLocEnt	:= ""
	Local cUFLocEnt		:= "" 
	Local nTotReg		:= ""
	Local nVlIPIRegi	:= 0
	Local nVlIPIPres	:= 0
	

	If !ApOleClient("MSExcel")
		MsgAlert("Microsoft Excel não instalado!")
		Return
	EndIf

	If Select( (cAliasTRB) ) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf

	cQuery += " SELECT D2_FILIAL, D2_COD, D2_DOC,D2_SERIE, D2_TES, D2_CF,D2_CLIENTE,D2_LOJA,D2_EMISSAO, D2_ITEMPV, "		+ CRLF
	cQuery += " F4_FINALID, F4_TEXTO, FT_CTIPI, FT_CSTPIS, FT_CSTCOF, F4_ICM, F4_IPI, F4_CREDICM, F4_CREDIPI, F4_DUPLIC, "	+ CRLF
	cQuery += " B1_DESC, B1_XDESCL1, B1_GRUPO, B1_POSIPI, B1_CEST, B1_ORIGEM, B1_EX_NCM, D2_ITEM, "							+ CRLF
	cQuery += " F2_ESPECIE,F2_CODNFE,F2_MENNOTA,F2_USERLGI,F2_USERLGA,F2_TIPO, FT_CHVNFE,F2_DOC, F2_SERIE, F2_FIMP,  " 		+ CRLF
	cQuery += " FT_VALCONT, F2_FORMUL, D2_CONTA, D2_NFORI, D2_SERIORI, D2_PRUNIT,D2_TOTAL, "								+ CRLF
	cQuery += " D2_DESC, FT_CLASFIS, D2_DESCZFP, D2_DESCZFC, D2_TIPO, "														+ CRLF
	cQuery += " FT_BASEICM, FT_ALIQICM, FT_VALICM, C6_CHASSI, "																+ CRLF
	cQuery += " FT_BASEIPI, FT_ALIQIPI, FT_VALIPI, FT_ARETPIS, FT_ARETCOF, FT_VRETPIS, FT_VRETCOF, FT_BRETPIS, "			+ CRLF
	cQuery += " FT_BASERET, FT_ICMSRET, FT_DIFAL, FT_BRETCOF, "																+ CRLF
	cQuery += " D2_BASIMP6,D2_ALQIMP6,D2_VALIMP6,   " 																		+ CRLF
	cQuery += " D2_BASIMP5,D2_ALQIMP5,D2_VALIMP5,   " 																		+ CRLF
	cQuery += " FT_BASEPIS,FT_ALIQPIS,FT_VALPIS, F2_TOTFED, F2_TOTEST, "													+ CRLF
	cQuery += " FT_BASECOF,FT_ALIQCOF,FT_VALCOF, FT_BASECF3, FT_ALIQCF3, FT_VALCF3, FT_BASEPS3, FT_ALIQPS3, FT_VALPS3, "	+ CRLF
	cQuery += " FT_BASEIRR,FT_ALIQIRR,FT_VALIRR, F3_OUTRIPI, F3_ISENIPI, F3_OUTRICM, F3_ISENICM,  "							+ CRLF
	cQuery += " FT_BASEINS,FT_ALIQINS,D2_ABATINS,FT_VALINS, D2_UM, D2_QUANT, "												+ CRLF
	cQuery += " D2_BASEISS,D2_ALIQISS,D2_ABATISS,D2_ABATMAT,D2_VALISS, D2_ITEMCC, "											+ CRLF
	cQuery += " FT_BASECSL,FT_ALIQCSL,FT_VALCSL, D2_CUSTO1, VRK_CHASSI, VRJ_CODCLI, VRJ_LOJA, C6_XVLCOM, "					+ CRLF
	cQuery += " C6_TNATREC, C6_NFORI, C6_FILIAL, C6_NUM, VV3_TIPVEN, VV3_DESCRI, VRJ_CLIRET, VRK_OPCION "					+ CRLF
	cQuery += " FROM   " + RetSQLName("SD2") + " SD2 " 																		+ CRLF
	
	cQuery += "	INNER JOIN " + RetSQLName("SF2") + " SF2 "																+ CRLF
	cQuery += "		ON SF2.F2_FILIAL = '" + FWxFilial('SF2') + "' "														+ CRLF
	cQuery += "		AND SD2.D2_DOC = SF2.F2_DOC   " 																	+ CRLF
	cQuery += "		AND SD2.D2_SERIE = SF2.F2_SERIE   " 																+ CRLF
	cQuery += "		AND SD2.D2_CLIENTE = SF2.F2_CLIENTE   " 															+ CRLF
	cQuery += "		AND SD2.D2_LOJA = SF2.F2_LOJA   " 																	+ CRLF
	cQuery += "		AND SD2.D2_EMISSAO = SF2.F2_EMISSAO   " 															+ CRLF
	cQuery += "		AND SF2.F2_ESPECIE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " 								+ CRLF
	cQuery += "		AND SF2.D_E_L_E_T_ = ' '   "	 																	+ CRLF

	If !Empty( MV_PAR17 )
		cQuery += " 	AND SF2.F2_EST = '" + MV_PAR17 + "' " 															+ CRLF
	EndIf
	
	cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 " 												 				+ CRLF
	cQuery += "		ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "														+ CRLF
	cQuery += "		AND SB1.B1_COD = SD2.D2_COD   "	 																	+ CRLF
	cQuery += "		AND SB1.D_E_L_E_T_ = ' ' " 																			+ CRLF

	If !Empty( MV_PAR18 )
		cQuery += " 	AND SB1.B1_GRUPO = '" + MV_PAR18 + "' "															+ CRLF
	EndIf

	If !Empty( MV_PAR19 )
		cQuery += " 	AND SB1.B1_POSIPI = '" + MV_PAR19 + "' "														+ CRLF
	EndIf

	cQuery += " INNER JOIN " + RetSQLName("SF4") + " SF4 "																+ CRLF
	cQuery += "		ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "'  "													+ CRLF
	cQuery += "		AND SF4.F4_CODIGO = SD2.D2_TES  "	 																+ CRLF
	cQuery += "     AND SF4.D_E_L_E_T_ = ' '   " 																		+ CRLF
	
	cQuery += " LEFT JOIN " + RetSQLName("SC6") + " SC6 "																+ CRLF
	cQuery += "		ON SC6.C6_FILIAL = '" + FWxFilial('SC6') + "' "														+ CRLF
	cQuery += "		AND SC6.C6_NUM = SD2.D2_PEDIDO  "																	+ CRLF
	cQuery += "		AND SC6.C6_ITEM = SD2.D2_ITEMPV  "		 															+ CRLF
	cQuery += "		AND SC6.C6_PRODUTO = SD2.D2_COD "		 															+ CRLF
	cQuery += "     AND SC6.D_E_L_E_T_ = ' '   " 																		+ CRLF
	
	cQuery += " LEFT JOIN " + RetSQLName("VV0") + " VV0 "																+ CRLF
	cQuery += "		ON VV0.VV0_FILIAL = '" + FWxFilial('VV0') + "' "													+ CRLF
	cQuery += "		AND VV0.VV0_NUMNFI = SF2.F2_DOC  "	 																+ CRLF
	cQuery += "		AND VV0.VV0_SERNFI = SF2.F2_SERIE  "																+ CRLF
	cQuery += "     AND VV0.D_E_L_E_T_ = ' '   " 																		+ CRLF
	
	cQuery += " LEFT JOIN " + RetSQLName("VV3") + " VV3 "																+ CRLF
	cQuery += "		ON VV3.VV3_FILIAL = '" + FWxFilial('VV3') + "' " 													+ CRLF
	cQuery += " 	AND VV3.VV3_TIPVEN = VV0.VV0_TIPVEN  "			 													+ CRLF
	cQuery += "     AND VV3.D_E_L_E_T_ = ' '   " 																		+ CRLF

	cQuery += " LEFT JOIN " + RetSQLName("VRK") + " VRK "																+ CRLF
	cQuery += " 	ON VRK.VRK_FILIAL = '" + FWxFilial('VRK') + "' "  													+ CRLF
	cQuery += " 	AND VRK.VRK_NUMTRA = VV0.VV0_NUMTRA  "			 													+ CRLF
	cQuery += "     AND VRK.D_E_L_E_T_ = ' '   " 																		+ CRLF

	cQuery += " LEFT JOIN " + RetSQLName("VRJ") + " VRJ "																+ CRLF
	cQuery += " 	ON VRJ.VRJ_FILIAL = '" + FWxFilial('VRJ') + "' "  													+ CRLF
	cQuery += " 	AND VRJ.VRJ_PEDIDO = VRK.VRK_PEDIDO  "			 													+ CRLF
	cQuery += "     AND VRJ.D_E_L_E_T_ = ' '   " 																		+ CRLF

	cQuery += " INNER JOIN " + RetSQLName("SFT") + " SFT " 																+ CRLF
	cQuery += "		ON SFT.FT_FILIAL = '" + FWxFilial('SFT') + "' "														+ CRLF
	cQuery += "		AND SFT.FT_TIPOMOV = 'S' "																			+ CRLF
	cQuery += "		AND SFT.FT_SERIE = SD2.D2_SERIE "																	+ CRLF
	cQuery += " 	AND SFT.FT_NFISCAL = SD2.D2_DOC "																	+ CRLF
	cQuery += "		AND SFT.FT_CLIEFOR = SD2.D2_CLIENTE " 																+ CRLF
	cQuery += "		AND SFT.FT_LOJA = SD2.D2_LOJA " 																	+ CRLF
	cQuery += "		AND SFT.FT_ITEM = SD2.D2_ITEM " 																	+ CRLF
	cQuery += "		AND SFT.FT_PRODUTO = SD2.D2_COD " 																	+ CRLF	
	cQuery += "		AND SFT.D_E_L_E_T_ = ' ' "																			+ CRLF

	cQuery += " INNER JOIN " + RetSQLName("SF3") + " SF3 " 																+ CRLF
	cQuery += "		ON SF3.F3_FILIAL = '" + FWxFilial('SF3') + "' "	 													+ CRLF
	cQuery += "		AND SF3.F3_SERIE = SFT.FT_SERIE "																	+ CRLF
	cQuery += "		AND SF3.F3_NFISCAL = SFT.FT_NFISCAL "																+ CRLF
	cQuery += " 	AND SF3.F3_CLIEFOR = SFT.FT_CLIEFOR "																+ CRLF
	cQuery += "		AND SF3.F3_LOJA = SFT.FT_LOJA " 																	+ CRLF
	cQuery += "		AND SF3.F3_IDENTFT = SFT.FT_IDENTF3 " 																+ CRLF
	cQuery += "		AND SF3.D_E_L_E_T_ = ' ' "																			+ CRLF

	cQuery += " WHERE  SD2.D2_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "								+ CRLF
	cQuery += " 	AND SD2.D2_DOC BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " 									+ CRLF
	cQuery += " 	AND SD2.D2_SERIE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " 								+ CRLF
	cQuery += " 	AND SD2.D2_CLIENTE BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' " 								+ CRLF
	cQuery += " 	AND SD2.D2_EMISSAO BETWEEN '" + DToS(MV_PAR11) + "' AND '" + DToS(MV_PAR12) + "' " 					+ CRLF
	cQuery += " 	AND SD2.D2_COD BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' " 									+ CRLF
	cQuery += " 	AND SD2.D_E_L_E_T_ = ' ' " 																			+ CRLF

	If !Empty( MV_PAR15 )
		cQuery += " 	AND SD2.D2_TES = '" + MV_PAR15 + "' " 															+ CRLF
	EndIf

	If !Empty( MV_PAR16 )
		cQuery += " 	AND SD2.D2_CF = '" + MV_PAR16 + "' " 															+ CRLF
	EndIf  

    If !Empty( MV_PAR20 ) .OR. !Empty( MV_PAR21 )
	   cQuery += " 	AND SC6.C6_CHASSI BETWEEN '" + MV_PAR20 + "' AND '" + MV_PAR21 + "' " 	
    Endif

	cQuery += " GROUP BY D2_FILIAL, D2_COD, D2_DOC,D2_SERIE, D2_TES, D2_CF,D2_CLIENTE,D2_LOJA,D2_EMISSAO, D2_ITEMPV, "		+ CRLF
	cQuery += " F4_FINALID, F4_TEXTO, FT_CTIPI, FT_CSTPIS, FT_CSTCOF, F4_ICM, F4_IPI, F4_CREDICM, F4_CREDIPI, F4_DUPLIC, "	+ CRLF
	cQuery += " B1_DESC, B1_XDESCL1, B1_GRUPO, B1_POSIPI, B1_CEST, B1_ORIGEM, B1_EX_NCM, D2_ITEM, "							+ CRLF
	cQuery += " F2_ESPECIE,F2_CODNFE,F2_MENNOTA,F2_USERLGI,F2_USERLGA,F2_TIPO, FT_CHVNFE,F2_DOC, F2_SERIE, F2_FIMP,  " 		+ CRLF
	cQuery += " FT_VALCONT, F2_FORMUL, D2_CONTA, D2_NFORI, D2_SERIORI, D2_PRUNIT,D2_TOTAL, "								+ CRLF
	cQuery += " D2_DESC, FT_CLASFIS, D2_DESCZFP, D2_DESCZFC, D2_TIPO, "														+ CRLF
	cQuery += " FT_BASEICM, FT_ALIQICM, FT_VALICM, C6_CHASSI, "																+ CRLF
	cQuery += " FT_BASEIPI, FT_ALIQIPI, FT_VALIPI, FT_ARETPIS, FT_ARETCOF, FT_VRETPIS, FT_VRETCOF, FT_BRETPIS, "			+ CRLF
	cQuery += " FT_BASERET, FT_ICMSRET, FT_DIFAL, FT_BRETCOF, "																+ CRLF
	cQuery += " D2_BASIMP6,D2_ALQIMP6,D2_VALIMP6,   " 																		+ CRLF
	cQuery += " D2_BASIMP5,D2_ALQIMP5,D2_VALIMP5,   " 																		+ CRLF
	cQuery += " FT_BASEPIS,FT_ALIQPIS,FT_VALPIS, F2_TOTFED, F2_TOTEST, " 													+ CRLF
	cQuery += " FT_BASECOF,FT_ALIQCOF,FT_VALCOF, FT_BASECF3, FT_ALIQCF3, FT_VALCF3, FT_BASEPS3, FT_ALIQPS3, FT_VALPS3, "	+ CRLF
	cQuery += " FT_BASEIRR,FT_ALIQIRR,FT_VALIRR, F3_OUTRIPI, F3_ISENIPI, F3_OUTRICM, F3_ISENICM,  "							+ CRLF
	cQuery += " FT_BASEINS,FT_ALIQINS,D2_ABATINS,FT_VALINS, D2_UM, D2_QUANT, "												+ CRLF
	cQuery += " D2_BASEISS,D2_ALIQISS,D2_ABATISS,D2_ABATMAT,D2_VALISS, D2_ITEMCC, "											+ CRLF
	cQuery += " FT_BASECSL,FT_ALIQCSL,FT_VALCSL, D2_CUSTO1, VRK_CHASSI, VRJ_CODCLI, VRJ_LOJA, C6_XVLCOM,  "					+ CRLF
	cQuery += " C6_TNATREC, C6_NFORI, C6_FILIAL, C6_NUM, VV3_TIPVEN, VV3_DESCRI, VRJ_CLIRET, VRK_OPCION "					+ CRLF

	cQuery += " ORDER BY SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA " 						+ CRLF

	cQuery := ChangeQuery(cQuery)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

	DbSelectArea((cAliasTRB))
	nTotReg := Contar(cAliasTRB,"!Eof()")
	(cAliasTRB)->(dbGoTop())
	
	If (cAliasTRB)->(!Eof())

		// Criando o objeto que irá gerar o conteúdo do Excel.
		oFWMsExcel := FWMSExcelEx():New()

		// Aba 01
		oFWMsExcel:AddworkSheet(cAba1) //Não utilizar número junto com sinal de menos. Ex.: 1-.

		// Criando a Tabela.
		oFWMsExcel:AddTable( cAba1	,cTabela1	)

		// Criando Colunas.	
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cnpj/Cpf"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"CNPJ Loc. Entr."				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Insc.Estadual"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Pessoa Fisica/Juridica"		,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"UF"							,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tes"							,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Finalidade TES"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Origem do Produto"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"NCM"							,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Ex-NBM"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Modelo Veículo"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Opcional"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Grupo\Linha"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descrição do Grupo"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Total Item"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cfop"							,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Contábil"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base ICMS"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. ICMS"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor ICMS"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Comissão"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base IPI"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. IPI"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor IPI"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Credito_Regional IPI"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Credito_Presumido IPI/Frete"	,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Subst"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Subst"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Pis Apuração"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Pis Apuração"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Pis Apuração"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Cofins Apuração"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Cofins Apuração"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Cofins Apuração"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base PIS ST ZFM"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. PIS ST ZFM"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Vl. PIS ST ZFM"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base COF ST ZFM"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. COF ST ZFM"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Vl. COF ST ZFM"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"ICMS Difal"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"CST ICMS"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"CST IPI"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"CST PIS"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"CST COFINS"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Calcula ICMS"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Credita ICMS"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Calcula IPI"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Credita IPI"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nota Fiscal"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nf. Prefeitura"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Série"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Espécie"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Modelo"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt. de Emissão"				,2	,4	,.F.	) // Center - Data
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cliente\Fornecedor"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Loja"							,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nome"							,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Chassi"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cód.Produto"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descrição do Produto"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descrição Científico"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descrição Longa"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Un Medida"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Quant."						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Unit. Item"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Desconto Item"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Frete"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Seguro"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Despesas"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Custo"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Conta Contábil"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Desc.Conta Contábil"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Empresa"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Situação"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tipo Nota Fiscal"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Chave Nota Fiscal"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Protocolo"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nota Fiscal Origem"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tipo Cli\For"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cli\For"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Estado"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Município"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"CEST"							,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descr. Modelo Veículo"		,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Combustível Veículo"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descrição CFOP"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cód.Verificação"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Ambiente"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Irrf Retenção"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Irrf Retenção"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Irrf Retenção"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Inss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Inss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Inss Recolhido"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Inss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Iss"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Iss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Iss Serviços"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Iss Materiais"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Iss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Csll"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Csll"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Csll"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Pis Retenção"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Pis Retenção"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Pis Retenção"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Cofins Retenção"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Cofins Retenção"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Cofins Retenção"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Log. de Inclusão"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Log. de Alteração"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt. Log. de Alteração"		,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tipo Venda"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descr. Tipo Venda"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Num. Pedido"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Natureza Financeira"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tab. Nat. Receita"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Item Contábil"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"ICMS Isento"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"ICMS Outros"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"IPI Isento"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"IPI Outros"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cód. Transportadora"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cat. Local de Entrega"		,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nome Loc. Entr."				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"UF Loc. Entr."				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Msgn Sefaz"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Msgn Nota Fiscal"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Mens.p/Nota"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Mens. Padrão"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Mensagem NFS"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Vlr. Aprox. dos Tributos"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Gera Duplicata"				,2	,1	,.F.	) // Center - Texto

		// Conta quantos registros existem, e seta no tamanho da régua.
		ProcRegua( nTotReg )

		VV2->( DbSetOrder(7) ) // VV2_FILIAL+VV2_PRODUT
		SF2->( DbSetOrder(2) ) // F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
		SA1->( DbSetOrder(1) ) // A1_FILIAL+A1_COD+A1_LOJA
		SA2->( DbSetOrder(1) ) // A2_FILIAL+A2_COD+A2_LOJA
		SC5->( DbSetOrder(1) ) // C5_FILIAL+C5_NUM
		CDA->( DbSetOrder(1) ) // CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA+CDA_NUMITE

		DbSelectArea((cAliasTRB))
		(cAliasTRB)->(dbGoTop())
		While (cAliasTRB)->(!EoF())

			// Incrementa a mensagem na régua.
			IncProc( "Exportando informações para Excel..." )

			// TRATAMENTO PARA BUSCAR O LOG DO USUÁRIO.
			cLogInc 	:= ""
			cLogAlt 	:= ""
			cDtLogAlt	:= ""
			If SF2->(dbSeek( (cAliasTRB)->D2_FILIAL + (cAliasTRB)->D2_CLIENTE + (cAliasTRB)->D2_LOJA + (cAliasTRB)->D2_DOC + (cAliasTRB)->D2_SERIE + (cAliasTRB)->F2_TIPO + (cAliasTRB)->F2_ESPECIE))
				cLogInc 	:= FWLeUserlg( "F2_USERLGI" )
				cLogAlt 	:= FWLeUserlg( "F2_USERLGA" )
				cDtLogAlt	:= FWLeUserlg( "F2_USERLGA", 2 )
			EndIf

			// Busca informações da Nota Fiscal no servidor TSS.
			cAmbiente 	:= ""
			cProtocolo	:= ""
			cMsgSefaz 	:= ""
			aInfNfe		:= {}
			//--Trecho removido pois estava causando lentidão, estes campos serão utilizados em um relatorio a parte
			/*If AllTrim( (cAliasTRB)->F2_ESPECIE ) $ "SPED|CTE|RPS|NFS"
				aInfNfe 	:= U_zFATF001( (cAliasTRB)->F2_SERIE	,(cAliasTRB)->F2_DOC	)
				cAmbiente 	:= AllTrim( aInfNfe[1,3] )
				cProtocolo 	:= AllTrim( aInfNfe[1,6] )
				cMsgSefaz 	:= AllTrim( aInfNfe[1,5] )
			EndIf*/

			// Busca o Status da Nota Fiscal.
			cSituacao	:= ""
			Do Case
				Case (cAliasTRB)->F2_FIMP == " " .And. AllTrim( (cAliasTRB)->F2_ESPECIE ) == "SPED"
					cSituacao	:= "NF não transmitida"
				Case (cAliasTRB)->F2_FIMP == "S"
					cSituacao	:= "NF Autorizada"
				Case (cAliasTRB)->F2_FIMP == "T"
					cSituacao	:= "NF Transmitida"
				Case (cAliasTRB)->F2_FIMP == "D"
					cSituacao	:= "NF Uso Denegado"
				Case (cAliasTRB)->F2_FIMP == "N"
					cSituacao	:= "NF nao autorizada"
				OtherWise
					cSituacao	:= ""
			EndCase

			// Busca o Modelo do Veiculo
			cModVei		:= ""
			cDesMod		:= ""
			cComVei 	:= ""
			If VV2->(DbSeek( xFilial("VV2") + (cAliasTRB)->D2_COD ))
				cModVei	:= AllTrim( VV2->VV2_MODVEI )
				cDesMod	:= AllTrim( VV2->VV2_DESMOD )
				cComVei	:= X3Combo( "VV2_COMVEI"	,VV2->VV2_COMVEI	)			
			Endif

			cCliFor 	:= ""
			cCgcCpf		:= ""
			cIncEst		:= ""
			cDescTipo	:= ""
			cTpCliFor	:= ""
			cTpPessoa	:= ""
			If (cAliasTRB)->F2_TIPO $ "B|D" // Benefeciamento ou devolução
				If SA2->(DbSeek( xFilial("SA2") + (cAliasTRB)->D2_CLIENTE + (cAliasTRB)->D2_LOJA ))
					cCliFor		:= SA2->A2_NOME
					cIncEst 	:= SA2->A2_INSCR
					cCgcCpf 	:= IIF( Len( Alltrim( SA2->A2_CGC) )>11 ,Transform( SA2->A2_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA2->A2_CGC ,"@R 999.999.999-99" ) ) 
					cEstCli 	:= SA2->A2_EST
					cCodMun		:= SA2->A2_COD_MUN
					cTpCliFor	:= "Fornecedor"

					// Busca o Tipo do Fornecedor.
					If SA2->A2_TIPO == "J"
						cDescTipo := "Juridico"
					ElseIf SA2->A2_TIPO == "F"
						cDescTipo := "Fisico"
					ElseIf SA2->A2_TIPO == "X"
						cDescTipo := "Outros"
					Else
						cDescTipo := ""
					Endif

					cTpPessoa := cDescTipo

				Else
					cCliFor		:= "FORNECEDOR NÃO ENCONTRADO NA BASE DE DADOS"
					cIncEst 	:= ""
					cCgcCpf 	:= ""
					cDescTipo	:= ""
					cEstCli		:= ""
					cCodMun		:= ""
					cTpCliFor	:= "Fornecedor"
					cTpPessoa	:= ""
				EndIf
			Else
				If SA1->(DbSeek( xFilial("SA1") + (cAliasTRB)->D2_CLIENTE + (cAliasTRB)->D2_LOJA ))
					cCliFor		:= SA1->A1_NOME
					cIncEst 	:= SA1->A1_INSCR
					cCgcCpf 	:= IIF( Len( Alltrim( SA1->A1_CGC) )>11 ,Transform( SA1->A1_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA1->A1_CGC ,"@R 999.999.999-99" ) ) 
					cEstCli		:= SA1->A1_EST
					cCodMun		:= SA1->A1_COD_MUN
					cTpCliFor	:= "Cliente"

					If SA1->A1_PESSOA == "J"
						cTpPessoa := "Juridico"
					ElseIf SA1->A1_PESSOA == "F"
						cTpPessoa := "Fisico"
					Else
						cTpPessoa := ""
					Endif

					// Busca o Tipo do Cliente.
					Do Case
						Case SA1->A1_TIPO == "F"
							cDescTipo	:= "Cons.Final"
						Case SA1->A1_TIPO == "L"
							cDescTipo	:= "Produtor Rural"
						Case SA1->A1_TIPO == "R"
							cDescTipo	:= "Revendedor"
						Case SA1->A1_TIPO == "S"
							cDescTipo	:= "Solidario"
						Case SA1->A1_TIPO == "X"
							cDescTipo	:= "Exportacao"
						OtherWise
							cDescTipo	:= ""
					EndCase

				Else
					cCliFor		:= "CLIENTE NÃO ENCONTRADO NA BASE DE DADOS"
					cIncEst 	:= ""
					cCgcCpf		:= ""
					cDescTipo	:= ""
					cEstCli		:= ""
					cCodMun		:= ""
					cTpCliFor	:= "Cliente"
					cTpPessoa	:= ""
				EndIf
			EndIf

			cCGCLocEnt := ""
			cNomLocEnt := ""
			cUFLocEnt  := ""

			//--Necessario essa redundancia porque o cliente da nota não sera o cliente de retirada na maioria dos casos
			//--Grava registros de cliente/fornecedor quando informados no pedido de venda do SIGAVEI, campo VRJ_CLIRET
			If !Empty( (cAliasTRB)->VRJ_CLIRET )
				If (cAliasTRB)->F2_TIPO $ "B|D" // Benefeciamento ou devolução
					If SA2->( DbSeek( FWxFilial('SA2') + (cAliasTRB)->VRJ_CODCLI + (cAliasTRB)->VRJ_LOJA ) )
						cCGCLocEnt := IIF( Len( Alltrim( SA2->A2_CGC) )>11 ,Transform( SA2->A2_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA2->A2_CGC ,"@R 999.999.999-99" ) ) 
						cNomLocEnt := SA2->A2_NOME
						cUFLocEnt  := SA2->A2_EST
					EndIf
				Else
					If SA1->( DbSeek( FWxFilial('SA1') + (cAliasTRB)->VRJ_CODCLI + (cAliasTRB)->VRJ_LOJA ) )	
						cCGCLocEnt := IIF( Len( Alltrim( SA1->A1_CGC) )>11 ,Transform( SA1->A1_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA1->A1_CGC ,"@R 999.999.999-99" ) ) 
						cNomLocEnt := SA1->A1_NOME
						cUFLocEnt  := SA2->A2_EST
					EndIf
				EndIf
			EndIf

			//Verifica o tipo da Nota Fiscal
			cTpNF := ""
			Do Case
				Case (cAliasTRB)->F2_TIPO == "N"
					cTpNF	:= "NF Normal"
				Case (cAliasTRB)->F2_TIPO == "P"
					cTpNF	:= "NF de Compl. IPI"
				Case (cAliasTRB)->F2_TIPO== "I"
					cTpNF	:= "NF de Compl. ICMS"
				Case (cAliasTRB)->F2_TIPO == "C"
					cTpNF	:= "NF de Complemento"
				Case (cAliasTRB)->F2_TIPO == "B"
					cTpNF	:= "NF de Beneficiamento"
				Case (cAliasTRB)->F2_TIPO == "D"
					cTpNF	:= "NF de Devolucao"
				OtherWise
					cTpNF	:= "Tipo não encontrado"
			EndCase

			//-- Retorna dados do pedido
			cNumPed 	:= ""
			nVlrFrete 	:= 0
			nVlrSeguro	:= 0
			nVlrDesp	:= 0
			cMenNota	:= ""
			cMenPad		:= ""
			cNaturez	:= ""
			cTransp		:= ""
			cMensNFS	:= ""

			If SC5->( DbSeek( (cAliasTRB)->C6_FILIAL + (cAliasTRB)->C6_NUM ) )
				cNumPed 	:= SC5->C5_NUM
				nVlrFrete 	:= SC5->C5_FRETE
				nVlrSeguro	:= SC5->C5_SEGURO
				nVlrDesp	:= SC5->C5_DESPESA
				cMenNota	:= AllTrim( SC5->C5_MENNOTA )
				cMenPad		:= AllTrim( SC5->C5_MENPAD )
				cNaturez	:= AllTrim( SC5->C5_NATUREZ )
				cTransp		:= AllTrim( SC5->C5_TRANSP )
				cMensNFS	:= AllTrim( SC5->C5_XMENSER )	
			EndIf

			nVlIPIRegi := 0
			nVlIPIPres := 0
			//-- Retorna Valor de IPI regional e presumido
			zRel0003(@nVlIPIRegi, @nVlIPIPres, (cAliasTRB)->F2_ESPECIE, (cAliasTRB)->F2_DOC, (cAliasTRB)->F2_SERIE,;
					(cAliasTRB)->D2_CLIENTE, (cAliasTRB)->D2_LOJA, (cAliasTRB)->D2_ITEM )	

			oFWMSExcel:AddRow( cAba1	, cTabela1	, { cCgcCpf,;    //--Cnpj/Cpf
														cCGCLocEnt,;    //--CNPJ Loc. Entr.
														cIncEst,;    //--Insc.Estadual
														cTpPessoa,;    //--Pessoa Fisica/Juridica
														cEstCli,;    //--UF
														(cAliasTRB)->D2_TES,;    //--Tes
														Alltrim( (cAliasTRB)->F4_FINALID ),;    //--Finalidade TES
														AllTrim( (cAliasTRB)->B1_ORIGEM ),;    //--Origem do Produto
														AllTrim( (cAliasTRB)->B1_POSIPI ),;    //--NCM
														AllTrim( (cAliasTRB)->B1_EX_NCM ),;    //--Ex-NBM
														AllTrim( cModVei ),;    //--Modelo Veículo
														AllTrim( (cAliasTRB)->VRK_OPCION ),;    //--Opcional
														AllTrim( (cAliasTRB)->B1_GRUPO ),;    //--Grupo\Linha
														AllTrim( Posicione("SBM",1,xFilial("SBM")+(cAliasTRB)->B1_GRUPO,"BM_DESC") ),;    //--Descrição do Grupo
														(cAliasTRB)->D2_TOTAL,;    //--Valor Total Item
														(cAliasTRB)->D2_CF,;    //--Cfop
														(cAliasTRB)->FT_VALCONT,;    //--Valor Contábil
														(cAliasTRB)->FT_BASEICM,;    //--Base ICMS
														(cAliasTRB)->FT_ALIQICM,;    //--Aliq. ICMS
														(cAliasTRB)->FT_VALICM,;    //--Valor ICMS
														(cAliasTRB)->C6_XVLCOM,;    //--Comissão
														(cAliasTRB)->FT_BASEIPI,;    //--Base IPI
														(cAliasTRB)->FT_ALIQIPI,;    //--Aliq. IPI
														(cAliasTRB)->FT_VALIPI,;    //--Valor IPI
														nVlIPIRegi,;    //--Credito_Regional IPI
														nVlIPIPres,;    //--Credito_Presumido IPI/Frete
														(cAliasTRB)->FT_BASERET,;    //--Base Subst
														(cAliasTRB)->FT_ICMSRET,;    //--Valor Subst
														(cAliasTRB)->FT_BASEPIS,;    //--Base Pis Apuração
														(cAliasTRB)->FT_ALIQPIS,;    //--Aliq. Pis Apuração
														(cAliasTRB)->FT_VALPIS,;    //--Valor Pis Apuração
														(cAliasTRB)->FT_BASECOF,;    //--Base Cofins Apuração
														(cAliasTRB)->FT_ALIQCOF,;	//--Aliq. Cofins Apuração
														(cAliasTRB)->FT_VALCOF,;	//--Valor Cofins Apuração
														(cAliasTRB)->FT_BASEPS3,;    //--Base Pis ST ZFM
														(cAliasTRB)->FT_ALIQPS3,;    //--Aliq. Pis ST ZFM
														(cAliasTRB)->FT_VALPS3,;	//--Vl. Pis ST ZFM
														(cAliasTRB)->FT_BASECF3,;    //--Base Cof ST ZFM
														(cAliasTRB)->FT_ALIQCF3,;    //--Aliq. Cof ST ZFM
														(cAliasTRB)->FT_VALCF3,;	//--Vl. Cof ST ZFM
														(cAliasTRB)->FT_DIFAL,;    //--ICMS Difal
														(cAliasTRB)->FT_CLASFIS,;    //--CST ICMS
														(cAliasTRB)->FT_CTIPI,;    //--CST IPI
														(cAliasTRB)->FT_CSTPIS,;    //--CST PIS
														(cAliasTRB)->FT_CSTCOF,;    //--CST COFINS
														(cAliasTRB)->F4_ICM,;    //--Calcula ICMS
														(cAliasTRB)->F4_CREDICM,;    //--Credita ICMS
														(cAliasTRB)->F4_IPI,;    //--Calcula IPI
														(cAliasTRB)->F4_CREDIPI,;    //--Credita IPI
														(cAliasTRB)->D2_DOC,;    //--Nota Fiscal
														IIF( AllTrim( (cAliasTRB)->F2_ESPECIE ) == 'NFS', (cAliasTRB)->D2_DOC, ""),;    //--Nf. Prefeitura
														(cAliasTRB)->D2_SERIE,;    //--Série
														(cAliasTRB)->F2_ESPECIE,;    //--Espécie
														AModNot( (cAliasTRB)->F2_ESPECIE ),;    //--Modelo
														IIF( Empty( SToD( (cAliasTRB)->D2_EMISSAO ) ), "", SToD( (cAliasTRB)->D2_EMISSAO ) ),;    //--Dt. de Emissão
														(cAliasTRB)->D2_CLIENTE,;    //--Cliente\Fornecedor
														(cAliasTRB)->D2_LOJA,;    //--Loja
														cCliFor,;    //--Nome
														AllTrim( (cAliasTRB)->C6_CHASSI ),;    //--Chassi
														(cAliasTRB)->D2_COD,;    //--Cód.Produto
														Substr( (cAliasTRB)->B1_DESC,1,20 ),;    //--Descrição do Produto
														AllTrim( Posicione("SB5",1,xFilial("SB5")+(cAliasTRB)->D2_COD,"B5_CEME") ),;    //--Descrição Científico
														AllTrim( (cAliasTRB)->B1_XDESCL1 ),;    //--Descrição Longa
														(cAliasTRB)->D2_UM,;    //--Un Medida
														(cAliasTRB)->D2_QUANT,;    //--Quant
														(cAliasTRB)->D2_PRUNIT,;    //--Valor Unit. Item
														(cAliasTRB)->D2_DESC,;    //--Desconto Item
														nVlrFrete,;    //--Frete
														nVlrSeguro,;    //--Seguro
														nVlrDesp,;    //--Despesas
														(cAliasTRB)->D2_CUSTO1,;    //--Custo
														(cAliasTRB)->D2_CONTA,;    //--Conta Contábil
														AllTrim( Posicione("CT1",1,xFilial("CT1")+(cAliasTRB)->D2_CONTA,"CT1_DESC01") ),;    //--Desc.Conta Contábil
														AllTrim( (cAliasTRB)->D2_FILIAL ),;    //--Empresa
														cSituacao,;    //--Situação
														cTpNF,;    //--Tipo Nota Fiscal
														(cAliasTRB)->FT_CHVNFE,;    //--Chave Nota Fiscal
														cProtocolo,;    //--Protocolo
														AllTrim( (cAliasTRB)->D2_NFORI ) + " - " + AllTrim( (cAliasTRB)->D2_SERIORI ),;    //--Nota Fiscal Origem
														cDescTipo,;    //--Tipo Cli\For
														cTpCliFor,;    //--Cli\For
														AllTrim( Posicione("SX5" ,1 ,xFilial("SX5") + "12" + cEstCli,"X5_DESCRI") ) ,;    //--Estado
														AllTrim( Posicione("CC2" ,1 ,xFilial("CC2") + cEstCli + PadR( cCodMun ,TamSx3("CC2_CODMUN")[1] ) , "CC2_MUN" ) ),;    //--Município
														AllTrim( (cAliasTRB)->B1_CEST ),;    //--CEST
														AllTrim( cDesMod ),;    //--Descr. Modelo Veículo
														AllTrim( cComVei ),;    //--Combustível Veículo
														AllTrim( (cAliasTRB)->F4_TEXTO ),;    //--Descrição CFOP
														(cAliasTRB)->F2_CODNFE,;    //--Cód.Verificação
														cAmbiente,;    //--Ambiente
														(cAliasTRB)->FT_BASEIRR,;    //--Base Irrf Retenção
														(cAliasTRB)->FT_ALIQIRR,;    //--Aliq. Irrf Retenção
														(cAliasTRB)->FT_VALIRR,;    //--Irrf Retenção
														(cAliasTRB)->FT_BASEINS,;    //--Base Inss
														(cAliasTRB)->FT_ALIQINS,;    //--Aliq. Inss
														(cAliasTRB)->D2_ABATINS,;    //--Inss Recolhido
														(cAliasTRB)->FT_VALINS,;    //--Valor Inss
														(cAliasTRB)->D2_BASEISS,;    //--Base Iss
														(cAliasTRB)->D2_ALIQISS,;    //--Aliq. Iss
														(cAliasTRB)->D2_ABATISS,;    //--Iss Serviços
														(cAliasTRB)->D2_ABATMAT,;    //--Iss Materiais
														(cAliasTRB)->D2_VALISS,;	//--Valor Iss
														(cAliasTRB)->FT_BASECSL,;    //--Base Csll
														IIF( (cAliasTRB)->FT_BASECSL > 0, (cAliasTRB)->FT_ALIQCSL, 0 ),;    //--Aliq. Csll
														(cAliasTRB)->FT_VALCSL,;    //--Valor Csll
														(cAliasTRB)->FT_BRETPIS,;    //--Base Pis Retenção
														IIF( (cAliasTRB)->FT_BRETPIS > 0, (cAliasTRB)->FT_ARETPIS, 0 ),;    //--Aliq. Pis Retenção
														(cAliasTRB)->FT_VRETPIS,;    //--Valor Pis Retenção
														(cAliasTRB)->FT_BRETCOF,;    //--Base Cofins Retenção
														IIF( (cAliasTRB)->FT_BRETCOF > 0, (cAliasTRB)->FT_ARETCOF, 0 ),;    //--Aliq. Cofins Retenção
														(cAliasTRB)->FT_VRETCOF,;    //--Valor Cofins Retenção
														cLogInc,;    //--Log. de Inclusão
													  	cLogAlt,;    //--Log. de Alteração
														cDtLogAlt,;    //--Dt. Log. de Alteração
														AllTrim( (cAliasTRB)->VV3_TIPVEN ),;    //--Tipo Venda
														AllTrim( (cAliasTRB)->VV3_DESCRI ),;    //--Descr. Tipo Venda
														cNumPed,;    //--Num. Pedido
														cNaturez,;    //--Natureza Financeira
														AllTrim( (cAliasTRB)->C6_TNATREC ),;    //--Tab. Nat. Receita
														AllTrim( (cAliasTRB)->D2_ITEMCC ),;    //--Item Contábil
														(cAliasTRB)->F3_ISENICM,;    //--ICMS Isento
														(cAliasTRB)->F3_OUTRICM,;    //--ICMS Outros
														(cAliasTRB)->F3_ISENIPI,;    //--IPI Isento
														(cAliasTRB)->F3_OUTRIPI,;    //--IPI Outros
														cTransp,;    //--Cód. Transportadora
														(cAliasTRB)->VRJ_CLIRET,; //--Cat. Local de Entrega
														cNomLocEnt,;    //--Nome Loc. Entr.
														cUFLocEnt,;    //--UF Loc. Entr.
														cMsgSefaz,;    //--Msgn Sefaz
														(cAliasTRB)->F2_MENNOTA,;    //--Msgn Nota Fiscal   
														cMenNota,;    //--Mens.p/Nota
														cMenPad,;    //--Mens. Padrão
														cMensNFS,;   //--Mensagem NFS	
														(cAliasTRB)->( F2_TOTFED + F2_TOTEST ),;	//--Vlr. Aprox. dos Tributos	
														Alltrim( (cAliasTRB)->F4_DUPLIC ) })	//--Gera Duplicata   												    
			(cAliasTRB)->(DbSkip())
		EndDo

		If Select( (cTMPCanc) ) > 0
			(cTMPCanc)->(DbCloseArea())
		EndIf

		//-- Verifica notas canceladas
		cQuery := " SELECT F3_FILIAL, F3_OBSERV, F3_ESPECIE, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, "	+ CRLF
		cQuery += " F3_EMISSAO, F3_CHVNFE, F3_DESCRET "														+ CRLF
		cQuery += " FROM " + RetSQLName( 'SF3' ) + " SF3 " 													+ CRLF
		cQuery += " INNER JOIN " + RetSQLName( 'SF2' ) + " SF2 "											+ CRLF
		cQuery += " 	ON SF2.F2_FILIAL = '" + FWxFilial('SF2') + "' "	 									+ CRLF
		cQuery += " 	AND SF2.F2_DOC = SF3.F3_NFISCAL "													+ CRLF
		cQuery += " 	AND SF2.F2_SERIE = SF3.F3_SERIE "													+ CRLF
		cQuery += " 	AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR "												+ CRLF
		cQuery += " 	AND SF2.F2_LOJA = SF3.F3_LOJA "														+ CRLF

		If !Empty( MV_PAR17 )
			cQuery += " 	AND SF2.F2_EST = '" + MV_PAR17 + "' " 											+ CRLF
		EndIf

		cQuery += " INNER JOIN " + RetSQLName( 'SD2' ) + " SD2 "											+ CRLF
		cQuery += " 	ON SD2.D2_FILIAL = '" + FWxFilial('SD2') + "' "	 									+ CRLF
		cQuery += " 	AND SD2.D2_DOC = SF3.F3_NFISCAL "													+ CRLF
		cQuery += " 	AND SD2.D2_SERIE = SF3.F3_SERIE "													+ CRLF
		cQuery += " 	AND SD2.D2_CLIENTE = SF3.F3_CLIEFOR "												+ CRLF
		cQuery += " 	AND SD2.D2_LOJA = SF3.F3_LOJA "														+ CRLF
		cQuery += " 	AND SD2.D2_COD BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' " 					+ CRLF

		If !Empty( MV_PAR15 )
			cQuery += " 	AND SD2.D2_TES = '" + MV_PAR15 + "' " 											+ CRLF
		EndIf

		If !Empty( MV_PAR16 )
			cQuery += " 	AND SD2.D2_CF = '" + MV_PAR16 + "' " 											+ CRLF
		EndIf

		cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 " 												+ CRLF
		cQuery += "		ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "										+ CRLF
		cQuery += "		AND SB1.B1_COD = SD2.D2_COD   "	 													+ CRLF
		cQuery += "		AND SB1.D_E_L_E_T_ = ' ' " 															+ CRLF

		If !Empty( MV_PAR18 )
			cQuery += " 	AND SB1.B1_GRUPO = '" + MV_PAR18 + "' "											+ CRLF
		EndIf

		If !Empty( MV_PAR19 )
			cQuery += " 	AND SB1.B1_POSIPI = '" + MV_PAR19 + "' "										+ CRLF
		EndIf

		cQuery += " WHERE  SF3.F3_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "				+ CRLF
		cQuery += " 	AND SF3.F3_ESPECIE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "				+ CRLF
		cQuery += " 	AND SF3.F3_NFISCAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "				+ CRLF
		cQuery += " 	AND SF3.F3_SERIE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "				+ CRLF
		cQuery += " 	AND SF3.F3_CLIEFOR BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' " 				+ CRLF
		cQuery += " 	AND SF3.F3_EMISSAO BETWEEN '" + DToS(MV_PAR11) + "' AND '" + DToS(MV_PAR12) + "' " 	+ CRLF
		cQuery += " 	AND SF3.F3_DTCANC != ' ' " 															+ CRLF
		cQuery += " 	AND SF3.D_E_L_E_T_ = ' '   " 														+ CRLF

		cQuery += " GROUP BY F3_FILIAL, F3_OBSERV, F3_ESPECIE, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, " + CRLF
		cQuery += " F3_EMISSAO, F3_CHVNFE, F3_DESCRET "														+ CRLF

		cQuery += " ORDER BY SF3.F3_FILIAL, SF3.F3_NFISCAL, SF3.F3_SERIE, SF3.F3_CLIEFOR, SF3.F3_LOJA "		+ CRLF															+ CRLF

		cQuery := ChangeQuery(cQuery)

		// Executa a consulta.
		DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cTMPCanc, .T., .T. )

		DbSelectArea((cTMPCanc))
		(cTMPCanc)->(dbGoTop())
		If (cTMPCanc)->(!Eof())

			// Aba 02
			oFWMsExcel:AddworkSheet(cAba2) //Não utilizar número junto com sinal de menos. Ex.: 1-.

			// Criando a Tabela.
			oFWMsExcel:AddTable( cAba2	,cTabela2	)

			// Criando Colunas.
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Empresa"				,1	,1	,.F.	) // Left - Texto	
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Observação"			,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Especie"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Nota Fiscal"			,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Serie"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Cliente"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Loja/Cli"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Emissão"				,2	,4	,.F.	) // Center - Data
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Chave NFe"			,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Descrição"			,2	,1	,.F.	) // Center - Texto


			While (cTMPCanc)->(!EoF())
				
				oFWMSExcel:AddRow( cAba2	, cTabela2	, { Alltrim( (cTMPCanc)->F3_FILIAL ),;    //--Empresa
															Alltrim( (cTMPCanc)->F3_OBSERV ),;    //--Observação
															Alltrim( (cTMPCanc)->F3_ESPECIE ),;    //--Especie
															Alltrim( (cTMPCanc)->F3_NFISCAL ),;    //--Nota Fiscal
															Alltrim( (cTMPCanc)->F3_SERIE ),;    //--Serie
															Alltrim( (cTMPCanc)->F3_CLIEFOR ),;    //--Cliente
															Alltrim( (cTMPCanc)->F3_LOJA ),;    //--Loja/Cli
															IIF( Empty( SToD( (cTMPCanc)->F3_EMISSAO ) ), "", SToD( (cTMPCanc)->F3_EMISSAO ) ),;    //--Emissão
															AllTrim( (cTMPCanc)->F3_CHVNFE ),;    //--Chave NFe
															AllTrim( (cTMPCanc)->F3_DESCRET ) } )    //--Descrição
				(cTMPCanc)->(DbSkip())
			EndDo

		EndIf
		
		// Ativando o arquivo e gerando o xml.
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile( cArquivo )

		oFWMsExcel:DeActivate()
		FreeObj(oFWMsExcel)

		// Abrindo o excel e abrindo o arquivo xml.
		oExcel := MsExcel():New()           // Abre uma nova conexão com Excel.
		oExcel:WorkBooks:Open( cArquivo )   // Abre uma planilha.
		oExcel:SetVisible(.T.)              // Visualiza a planilha.
		oExcel:Destroy()                    // Encerra o processo do gerenciador de tarefas.

	Else
		ApMsgAlert( "Não foi encontrado nenhuma nota fiscal com os parâmetros informados!!" )
	EndIf

	opPar:End()
	(cAliasTRB)->(DbCloseArea())
	IIF( Select( cTMPCanc ) > 0, (cTMPCanc)->( DbCloseArea() ), Nil )
	DbSelectArea("SA1")

Return()

/*
=====================================================================================
Programa.:              zRel0003
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              26/02/20
Descricao / Objetivo:   Realiza consulta na tabela CDA e alimenta as variaveis de IPI
Doc. Origem:            
Solicitante:            
Uso......:              zRel0002
Obs......:
=====================================================================================
*/
Static Function zRel0003( nVlIPIRegi, nVlIPIPres, cEspecie, cDoc, cSerie, cCodCli, cCodLoja, cItem )
	Local aArea		:= GetArea() 
	Local cAliasTMP	:= GetNextAlias()
	Local cQry 		:= ""

	Default cEspecie	:= ""
	Default cDoc 		:= ""
	Default cSerie 		:= ""
	Default cCodCli		:= ""
	Default cCodLoja	:= ""
	Default cItem		:= ""

	If Select( cAliasTMP ) > 0
		( cAliasTMP )->( DbCloseArea() )
	EndIf

	cQry := " SELECT CDA_CODLAN, CDA_VALOR " 					+ CRLF
	cQry += " FROM " + RetSQLName( 'CDA' ) + ' CDA ' 			+ CRLF
	cQry += " WHERE CDA_FILIAL = '" + FWxFilial('SF2') + "' "	+ CRLF
	cQry += " 	AND CDA_ESPECI = '" + cEspecie + "' "			+ CRLF
	cQry += " 	AND CDA_NUMERO = '" + cDoc + "' "				+ CRLF
	cQry += " 	AND CDA_SERIE = '" + cSerie + "' "				+ CRLF
	cQry += " 	AND CDA_CLIFOR = '" + cCodCli + "' "			+ CRLF
	cQry += " 	AND CDA_LOJA = '" + cCodLoja + "' "				+ CRLF
	cQry += " 	AND CDA_NUMITE = '" + cItem + "' "				+ CRLF
	cQry += " 	AND D_E_L_E_T_ = ' ' "							+ CRLF

	cQry := ChangeQuery(cQry)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasTMP, .T., .T. )

	DbSelectArea( cAliasTMP )
	( cAliasTMP )->( dbGoTop() )	
	While ( cAliasTMP )->( !Eof() )
		
		If AllTrim( ( cAliasTMP )->CDA_CODLAN ) == '012' //-- Credito Regional IPI, com base nos registros atuais, não há registro para este código na tabela CC6
			nVlIPIRegi := ( cAliasTMP )->CDA_VALOR
		ElseIf AllTrim( ( cAliasTMP )->CDA_CODLAN ) == '013' //-- Credito presumido IPI, com base nos registros atuais, não há registro para este código na tabela CC6
			nVlIPIPres := ( cAliasTMP )->CDA_VALOR
		EndIf

		( cAliasTMP )->( DbSkip() )
	EndDo
	
	( cAliasTMP )->( DbCloseArea() )
	RestArea( aArea )
Return()
