#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

/*
=====================================================================================
Programa.:              ZFISR008
Autor....:              CAOA - Sandro Ferreira
Data.....:              05/04/2022
Descricao / Objetivo:   Relatorio Analitico de Notas Fiscais de Entrada e Saida
Doc. Origem:            GAP EST007 E GAP FAT022
Solicitante:            Fiscal
Uso......:              
Obs......:
=====================================================================================
*/
User Function ZFISR008() // u_ZFISR008()

	Local aOpcRadio	:= {	"Relat�rio Notas Fiscais de Entrada (Excel)"	,;
							"Relat�rio Notas Fiscais de Saida (Excel)"		}
	Local nRadio	:=	1

	DEFINE MSDIALOG opPar TITLE "Relat�rios de Confer�ncia" FROM 100,0 TO 300,400 PIXEL of oMainWnd STYLE DS_MODALFRAME

	oRadio1:=tRadMenu():New( 010	,010	,aOpcRadio		,{|u|if(PCount()>0,nRadio:=u,nRadio)}	,opPar	,,,,,,,	,290	,50,,,,.T.	)
	oBotao2:=tButton():New(  070	,030	,"Imprimir"		,opPar	,{|| zSelect2(nRadio)   }		,050	,011	,,,,.T.	) // "Imprimir"
	oBotao1:=tButton():New(  070	,120	,"Fechar"		,opPar	,{|| opPar:End()}				,050	,011	,,,,.T.	) // "Fechar"

	ACTIVATE MSDIALOG opPar

Return()

/*
=====================================================================================
Programa.:              zSelect2
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              13/06/19
Descricao / Objetivo:   Seleciona o relatorio para impressao
Doc. Origem:            GAP EST007 E GAP FAT022
Solicitante:            Fiscal
Uso......:              ZFISR001
Obs......:
=====================================================================================
*/
Static Function zSelect2(nRadio)
	Local cExtens   := "Arquivo XML | *.XML"
	Local cTitulo	:= "Escolha o caminho para salvar o arquivo!"
	Local cMainPath := "\"
	Local cArquivo	:= ""
	Private cPergR1	:= "ZFISR008R1"
	Private cPergR2	:= "ZFISR008R2"

	If nRadio == 1
		If Pergunte( cPergR1	,.T.	)
			cArquivo := cGetFile(cExtens,cTitulo,,cMainPath,.F.)
			If !Empty(cArquivo)
				Processa({|| zRel001B(cArquivo)}	,"Gerando Relat�rio de Notas Fiscais de Entrada..."	)
			EndIf
		EndIf
	Else
		If Pergunte( cPergR2	,.T.	)
			cArquivo := cGetFile(cExtens,cTitulo,,cMainPath,.F.)
			If !Empty(cArquivo)
				Processa({|| zRel002B(cArquivo)}	,"Gerando Relat�rio de Notas Fiscais de Sa�da..."	)
			EndIf
		EndIf
	EndIf
Return()

/*
=====================================================================================
Programa.:              zRel001B
Autor....:              CAOA - Sandro Ferreira 
Data.....:              01/04/2022
Descricao / Objetivo:   Gera Excel Notas de Entrada
Doc. Origem:            GAP EST007 E GAP FAT022
Solicitante:            Fiscal
Uso......:              zSelect
Obs......:
=====================================================================================
*/
Static Function zRel001B(cArquivo)
	Local cQuery		:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cTMPCanc		:= GetNextAlias()
	Local cAba1			:= "Notas Fiscais de Entrada"
	Local cAba2			:= "Notas Fiscais Canceladas"
	Local cTabela1		:= "Rela��o de Notas Fiscais de Entrada"
	Local cTabela2		:= "Rela��o de Notas Fiscais Canceladas"
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
	Local cNF           := " "
	Local cTes          := " "
	Local nTot01        := nTot02   := nTot03   := nTot04   := nTot05   := nTot06   := nTot07   := nTot08   := nTot09   := nTot10    := 0
	Local nTot11        := nTot12   := nTot13   := nTot14   := nTot15   := nTot16   := nTot17   := nTot18   := nTot19   := nTot20    := 0
	Local nTot21        := nTot22   := nTot23   := nTot24   := nTot25   := nTot26   := nTot27   := nTot28   := nTot29   := nTot30    := 0
	Local nTot31        := nTot32   := nTot33   := nTot34   := nTot35   := nTot36   := nTot37   := nTot38   := nTot39   := nTot40    := 0
	Local nTot41        := nTot42   := nTot43   := nTot44   := nTot45   := nTot46   := nTot47   := nTot48                            := 0
	Local aCAMPO01      := aCAMPO02 := aCAMPO03 := aCAMPO04 := aCAMPO05 := aCAMPO06 := aCAMPO07 := aCAMPO08 := aCAMPO09 := aCAMPO10  := " "
	Local aCAMPO11      := aCAMPO12 := aCAMPO13 := aCAMPO14 := aCAMPO15 := aCAMPO16 := aCAMPO17 := aCAMPO18 := aCAMPO19 := aCAMPO20  := " "
	Local aCAMPO21      := aCAMPO22 := aCAMPO23 := aCAMPO24 := aCAMPO25 := aCAMPO26 := aCAMPO27 := aCAMPO28 := aCAMPO29 := aCAMPO30  := " "
	Local aCAMPO31      := aCAMPO32 := aCAMPO33 := aCAMPO34 := aCAMPO35 := aCAMPO36 := aCAMPO37 := aCAMPO38 := aCAMPO39 := aCAMPO40  := " "
	Local aCAMPO41      := aCAMPO42 := aCAMPO43 := aCAMPO44 := aCAMPO45 := aCAMPO46 := aCAMPO47 := aCAMPO48 := aCAMPO49 := aCAMPO50  := " "
	Local aCAMPO51      := aCAMPO52 := aCAMPO53 := aCAMPO54 := aCAMPO55 := aCAMPO56 := aCAMPO57 := aCAMPO58 := aCAMPO59 := aCAMPO60  := " "
	Local aCAMPO61      := aCAMPO62 := aCAMPO63 := aCAMPO64 := aCAMPO65 := aCAMPO66 := aCAMPO67 := aCAMPO68 := aCAMPO69 := aCAMPO70  := " " 
	Local aCAMPO71      := aCAMPO72 := aCAMPO73 := aCAMPO74 := aCAMPO75 := aCAMPO76 := aCAMPO77 := aCAMPO78 := aCAMPO79 := aCAMPO80  := " " 
	Local aCAMPO81      := aCAMPO82 := aCAMPO83 := aCAMPO84 := aCAMPO85 := aCAMPO86 := aCAMPO87 := aCAMPO88 := aCAMPO89 := aCAMPO90  := " "
	Local aCAMPO91      := aCAMPO92 := aCAMPO93 := aCAMPO94 := aCAMPO95 := aCAMPO96 := aCAMPO97 := aCAMPO98 := aCAMPO99 := aCAMPO100 := " "  
	    
	If !ApOleClient( "MSExcel" )
		MsgAlert( "Microsoft Excel n�o instalado!!" )
		Return
	EndIf

	If Select( (cAliasTRB) ) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf

	cQuery += " SELECT 	D1_FILIAL, D1_COD, D1_DOC, D1_SERIE, D1_TES, D1_CF, D1_FORNECE, D1_LOJA, D1_EMISSAO, D1_DTDIGIT, " 			+ CRLF
	cQuery += " D1_ITEM, F4_FINALID, F4_TEXTO, FT_CTIPI, FT_CSTPIS, FT_CSTCOF, F4_ICM, F4_IPI, F4_CREDICM, F4_CREDIPI, F4_DUPLIC, "	+ CRLF
	cQuery += "	B1_DESC, B1_XDESCL1, B1_GRUPO, B1_POSIPI, B1_CEST, B1_ORIGEM, B1_EX_NBM, "								  			+ CRLF
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
	cQuery += " B1_DESC, B1_XDESCL1, B1_GRUPO, B1_POSIPI, B1_CEST, B1_ORIGEM, B1_EX_NBM, "											+ CRLF
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
	cQuery += " ORDER BY SD1.D1_FILIAL, SD1.D1_EMISSAO, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_TES, SD1.D1_ITEM, SD1.D1_FORNECE, SD1.D1_LOJA "		+ CRLF
	cQuery := ChangeQuery(cQuery)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

	DbSelectArea((cAliasTRB))
	nTotReg := Contar(cAliasTRB,"!Eof()")
	(cAliasTRB)->(dbGoTop())
	If (cAliasTRB)->(!Eof())

		// Criando o objeto que ir� gerar o conte�do do Excel.
		oFWMsExcel := FWMSExcelEx():New()

		// Aba 01
		oFWMsExcel:AddworkSheet(cAba1) // N�o utilizar n�mero junto com sinal de menos. Ex.: 1-.

		// Criando a Tabela.
		oFWMsExcel:AddTable( cAba1	,cTabela1	)

		// Criando Colunas.
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cnpj/Cpf"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Insc.Estadual"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Pessoa Fisica/Juridica"		,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"UF"							,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tes"							,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Finalidade TES"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Total Item"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cfop"							,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Cont�bil"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base ICMS"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. ICMS"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor ICMS"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Comiss�o"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base IPI"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. IPI"					,2	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor IPI"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Credito_Presumido IPI/Frete"	,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Credito_Regional IPI"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Subst"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Subst"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Pis Apura��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Pis Apura��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Pis Apura��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Cofins Apura��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Cofins Apura��o"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Cofins Apura��o"		,3	,2	,.F.	) // Right - Number
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
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"S�rie"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Esp�cie"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Modelo"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt. de Entrada"				,2	,4	,.F.	) // Center - Data
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt. de Emiss�o"				,2	,4	,.F.	) // Center - Data
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Fornecedor\Cliente"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Loja"							,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nome"							,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Frete"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Despesas Acessorias"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Seguro"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Acrescimo"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Custo"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor do Dif. de Aliq."		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. II"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor II"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Num. Conhecimento"			,2	,3	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Num. DI"						,2	,3	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Data DI"						,2	,4	,.F.	) // Center - Data
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Empresa"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Situa��o"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tipo Nota Fiscal"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Formulario"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Chave Nota Fiscal"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Protocolo"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nota Fiscal Origem"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tipo Cli\For"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cli\For"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Estado"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Munic�pio"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descri��o CFOP"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"C�d.Verifica��o"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Ambiente"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Irrf Reten��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Irrf Reten��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Irrf Reten��o"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Inss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Inss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Inss Recolhido"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Inss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Iss"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Iss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Iss Servi�os"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Iss Materiais"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Iss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Inss Servi�os"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Csll"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Csll"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Csll"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Pis Reten��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Pis Reten��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Pis Reten��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Cofins Reten��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Cofins Reten��o"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Cofins Reten��o"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Msgn Nota Fiscal"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Log. de Inclus�o"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Log. de Altera��o"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt. Log. de Altera��o"		,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Num. Pedido Compra"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Natureza Financeira"			,1	,1	,.F.	) // Left - Texto
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
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Gera Duplicata"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Taxa Cambial"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Chassi"				    	,1	,1	,.F.	) // Right - Number
		
		// Conta quantos registros existem, e seta no tamanho da r�gua.
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
		cNF  := (cAliasTRB)->D1_DOC
		cTes := (cAliasTRB)->D1_TES
		While (cAliasTRB)->(!EoF())

			// Incrementa a mensagem na r�gua.
			IncProc("Exportando informa��es para Excel...")

			// TRATAMENTO PARA BUSCAR O LOG DO USU�RIO.
			cLogInc 	:= ""
			cLogAlt		:= ""
			cDtLogAlt 	:= "" 
			If SF1->(dbSeek( (cAliasTRB)->D1_FILIAL + (cAliasTRB)->D1_DOC + (cAliasTRB)->D1_SERIE + (cAliasTRB)->D1_FORNECE + (cAliasTRB)->D1_LOJA ))
				cLogInc		:= FWLeUserLg("F1_USERLGI")
				cLogAlt		:= FWLeUserLg("F1_USERLGA")
				cDtLogAlt	:= FWLeUserLg("F1_USERLGA", 2)
			EndIf

			// Busca informa��es da Nota Fiscal no servidor TSS.
			cAmbiente 	:= ""
			cProtocolo	:= ""
			cMsgSefaz 	:= ""
			aInfNfe		:= {}

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
			If (cAliasTRB)->F1_TIPO $ "B|D" // Benefeciamento ou devolu��o
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
						//--Posiciono no primeiro registro l�gico porque mesmo que existam parcelas a natureza ira se repetir nos demais registros
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
					cCliFor		:= "CLIENTE N�O ENCONTRADO NA BASE DE DADOS"
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
						//--Posiciono no primeiro registro l�gico porque mesmo que existam parcelas a natureza ira se repetir nos demais registros
						SE2->( DbGoTop() )
						cCodNatur := SE2->E2_NATUREZ
					EndIf 
					
				Else
					cCliFor		:= "FORNECEDOR N�O ENCONTRADO NA BASE DE DADOS"
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
					cTpNF	:= "Tipo n�o encontrado"
			EndCase

			nVlIPIRegi := 0
			nVlIPIPres := 0
			//-- Retorna Valor de IPI regional e presumido
			zRel003B(@nVlIPIRegi, @nVlIPIPres, (cAliasTRB)->F1_ESPECIE, (cAliasTRB)->F1_DOC, (cAliasTRB)->F1_SERIE,;
					(cAliasTRB)->D1_FORNECE, (cAliasTRB)->D1_LOJA, (cAliasTRB)->D1_ITEM )

            //Acumula Totais
			aCampo01 :=	cCgcCpf
			aCampo02 := cIncEst                                                                   				//--Insc.Estadual
			aCampo03 :=	cTpPessoa                                                                 				//--Pessoa Fisica/Juridica
			aCampo04 :=	cEstCli                                                                   				//--UF
			aCampo05 := (cAliasTRB)->D1_TES                                                       				//--Tes
			aCampo06 :=	Alltrim( (cAliasTRB)->F4_FINALID )                                        				//--Finalidade TES
			nTot01   +=  iif(valtype((cAliasTRB)->D1_TOTAL)    = "N", (cAliasTRB)->D1_TOTAL   ,0) 				//--Valor Total Item
            aCampo07 :=   (cAliasTRB)->D1_CF                                                      				//--Cfop
			nTot02   +=  iif(valtype((cAliasTRB)->FT_VALCONT)  = "N", (cAliasTRB)->FT_VALCONT ,0) 				//--Valor Cont�bil
			nTot03   +=  iif(valtype((cAliasTRB)->FT_BASEICM)  = "N", (cAliasTRB)->FT_BASEICM ,0) 				//--Base ICMS
			aCampo08 := (cAliasTRB)->FT_ALIQICM                                                   				//--Aliq. ICMS
			nTot04   +=  iif(valtype((cAliasTRB)->FT_VALICM)   = "N", (cAliasTRB)->FT_VALICM  ,0) 				//--Valor ICMS
			aCampo09 := IIF( (cAliasTRB)->F1_TIPO $ "B|D" , nVlCom , 0 )                          				//--Comiss�o
			nTot05   +=  iif(valtype((cAliasTRB)->FT_BASEIPI)  = "N", (cAliasTRB)->FT_BASEIPI ,0) 				//--Base IPI
			aCampo10 := (cAliasTRB)->FT_ALIQIPI                                                   				//--Aliq. IPI	
			nTot06   +=  iif(valtype((cAliasTRB)->FT_VALIPI)   = "N", (cAliasTRB)->FT_VALIPI  ,0) 				//--Valor IPI
			nTot07   +=  iif(valtype(nVlIPIPres)               = "N", nVlIPIPres              ,0) 				//--Credito_Presumido IPI/Frete
			nTot08   +=  iif(valtype(nVlIPIRegi)               = "N", nVlIPIRegi              ,0) 				//--Credito_Regional IPI
			nTot09   +=  iif(valtype((cAliasTRB)->FT_BASERET)  = "N", (cAliasTRB)->FT_BASERET ,0) 				//--Base Subst
			nTot10   +=  iif(valtype((cAliasTRB)->FT_ICMSRET)  = "N", (cAliasTRB)->FT_ICMSRET ,0) 				//--Valor Subst
			nTot11   +=  iif(valtype((cAliasTRB)->FT_BASEPIS)  = "N", (cAliasTRB)->FT_BASEPIS ,0) 				//--Base Pis Apura��o
			aCampo11 := (cAliasTRB)->FT_ALIQPIS                                                   				//--Aliq. Pis Apura��o
			nTot12   +=  iif(valtype((cAliasTRB)->FT_VALPIS)   = "N", (cAliasTRB)->FT_VALPIS  ,0) 				//--Valor Pis Apura��o
			nTot13   +=  iif(valtype((cAliasTRB)->FT_BASECOF)  = "N", (cAliasTRB)->FT_BASECOF ,0) 				//--Base Cofins Apura��o
		    aCampo12 := 	(cAliasTRB)->FT_ALIQCOF                                               				//--Aliq. Cofins Apura��o
			nTot14   +=  iif(valtype((cAliasTRB)->FT_VALCOF)   = "N", (cAliasTRB)->FT_VALCOF  ,0) 				//--Valor Cofins Apura��o
			nTot15   +=  iif(valtype((cAliasTRB)->FT_BASEPS3)  = "N", (cAliasTRB)->FT_BASEPS3 ,0) 				//--Base Pis ST ZFM
			aCampo13 := (cAliasTRB)->FT_ALIQPS3                                                   				//--Aliq. Pis ST ZFM
			nTot16   +=  iif(valtype((cAliasTRB)->FT_VALPS3) = "N", (cAliasTRB)->FT_VALPS3  ,0)  				//--Vl. Pis ST ZFM
			nTot17   +=  iif(valtype((cAliasTRB)->FT_BASECF3)  = "N", (cAliasTRB)->FT_BASECF3 ,0) 				//--Base Cof ST ZFM
		    aCampo14 := (cAliasTRB)->FT_ALIQCF3                                                  			    //--Aliq. Cof ST ZFM
			nTot18   +=  iif(valtype((cAliasTRB)->FT_VALCF3) = "N", (cAliasTRB)->FT_VALCF3  ,0)  				//--Vl. Cof ST ZFM
			nTot19   +=  iif(valtype((cAliasTRB)->FT_DIFAL)    = "N", (cAliasTRB)->FT_DIFAL   ,0) 				//--ICMS Difal
			aCampo15 := (cAliasTRB)->FT_CLASFIS    												  				//--CST ICMS
			aCampo16 := (cAliasTRB)->FT_CTIPI    												  				//--CST IPI
			aCampo17 := (cAliasTRB)->FT_CSTPIS    												  				//--CST PIS
			aCampo18 := (cAliasTRB)->FT_CSTCOF    												  				//--CST COFINS
			aCampo19 := (cAliasTRB)->F4_ICM   													  				//--Calcula ICMS
			aCampo20 := (cAliasTRB)->F4_CREDICM    												  				//--Credita ICMS
			aCampo21 := (cAliasTRB)->F4_IPI                                                      				//--Calcula IPI
			aCampo22 := (cAliasTRB)->F4_CREDIPI                                                   				//--Credita IPI
			aCampo23 := (cAliasTRB)->D1_DOC                                                       				//--Nota Fiscal
			aCampo24 := IIF( AllTrim( (cAliasTRB)->F1_ESPECIE )== "NFS", (cAliasTRB)->D1_DOC, "") 				//--Nf. Prefeitura
			aCampo25 := (cAliasTRB)->D1_SERIE                                                     				//--S�rie
			aCampo26 := (cAliasTRB)->F1_ESPECIE                                                   				//--Esp�cie
			aCampo27 := AModNot( (cAliasTRB)->F1_ESPECIE )                                        				//--Modelo
	        aCampo28 := IIF(Empty(SToD((cAliasTRB)->D1_DTDIGIT)),"",SToD((cAliasTRB)->D1_DTDIGIT))				//--Dt. de Entrada
			aCampo29 := IIF(Empty(SToD((cAliasTRB)->D1_EMISSAO)),"",SToD((cAliasTRB)->D1_EMISSAO))				//--Dt. de Emiss�o
			aCampo30 := (cAliasTRB)->D1_FORNECE    												  				//--Fornecedor\Cliente
			aCampo31 := (cAliasTRB)->D1_LOJA    												 				//--Loja
			aCampo32 :=	cCliFor   																  				//--Nome
			nTot22   +=  iif(valtype((cAliasTRB)->D1_VALFRE)   = "N", (cAliasTRB)->D1_VALFRE  ,0) 				//--Frete
			nTot23   +=  iif(valtype((cAliasTRB)->D1_DESPESA)  = "N", (cAliasTRB)->D1_DESPESA ,0) 				//--Despesas Acessorias
			nTot24   +=  iif(valtype((cAliasTRB)->D1_SEGURO)   = "N", (cAliasTRB)->D1_SEGURO  ,0) 				//--Seguro
			nTot25   +=  iif(valtype((cAliasTRB)->D1_VALACRS)  = "N", (cAliasTRB)->D1_VALACRS ,0) 				//--Acrescimo
			nTot26   +=  iif(valtype((cAliasTRB)->D1_CUSTO)    = "N", (cAliasTRB)->D1_CUSTO   ,0) 				//--Custo
	        nTot27   +=  iif(valtype((cAliasTRB)->FT_ICMSCOM)  = "N", (cAliasTRB)->FT_ICMSCOM ,0)				//--Valor do Dif. de Aliq.
            aCampo33 :=	(cAliasTRB)->YD_PER_II   												  				//--Aliq. II
            nTot28   +=  iif(valtype((cAliasTRB)->D1_II)       = "N", (cAliasTRB)->D1_II      ,0) 				//--Valor II
			aCampo34 := (cAliasTRB)->D1_CONHEC   												 				//--Num. Conhecimento
			aCampo35 := (cAliasTRB)->W6_DI_NUM   												 				//--Num. DI
			aCampo36 := IIF( Empty( SToD( (cAliasTRB)->W6_DTREG_D ) ), "", SToD( (cAliasTRB)->W6_DTREG_D ) )    //--Data DI
			aCampo37 := AllTrim( (cAliasTRB)->D1_FILIAL )    													//--Empresa
			aCampo38 := cSituacao  																				//--Situa��o
			aCampo39 := cTpNF   																			    //--Tipo Nota Fiscal
			aCampo40 := (cAliasTRB)->FT_FORMUL   																//--Formulario
			aCampo41 := (cAliasTRB)->FT_CHVNFE   																//--Chave Nota Fiscal
			aCampo42 := cProtocolo    																			//--Protocolo
			aCampo43 := AllTrim( (cAliasTRB)->D1_NFORI ) + " - " + AllTrim( (cAliasTRB)->D1_SERIORI )    		//--Nota Fiscal Origem
			aCampo44 := cDescTipo    																			//--Tipo Cli\For
			aCampo45 := cTpCliFor   																			//--Cli\For
			aCampo46 := AllTrim(Posicione("SX5",1, xFilial("SX5")+"12"+ cEstCli ,"X5_DESCRI"))    				//--Estado
			aCampo47 := AllTrim(Posicione("CC2",1, xFilial("CC2")+ cEstCli +PadR( cCodMun ,TamSx3("CC2_CODMUN")[1]) , "CC2_MUN"))    //--Munic�pio
			aCampo48 := AllTrim( (cAliasTRB)->F4_TEXTO )   														//--Descri��o CFOP
			aCampo49 := (cAliasTRB)->F1_CODNFE    																//--C�d.Verifica��o
			aCampo50 := cAmbiente    																			//--Ambiente
			nTot29   +=  iif(valtype((cAliasTRB)->FT_BASEIRR)  = "N", (cAliasTRB)->FT_BASEIRR ,0) 				//--Base Irrf Reten��o
			aCampo51 := (cAliasTRB)->FT_ALIQIRR   																//--Aliq. Irrf Reten��o
	        nTot30   +=  iif(valtype((cAliasTRB)->FT_VALIRR)   = "N", (cAliasTRB)->FT_VALIRR  ,0) 				//--Irrf Reten��o
			nTot31   +=  iif(valtype((cAliasTRB)->FT_BASEINS)  = "N", (cAliasTRB)->FT_BASEINS ,0)				//--Base Inss
			aCampo52 := (cAliasTRB)->FT_ALIQINS    																//--Aliq. Inss
	        nTot32   +=  iif(valtype((cAliasTRB)->D1_ABATINS)  = "N", (cAliasTRB)->D1_ABATINS ,0) 				//--Inss Recolhido
			nTot33   +=  iif(valtype((cAliasTRB)->FT_VALINS)   = "N", (cAliasTRB)->FT_VALINS  ,0) 				//--Valor Inss
			nTot34   +=  iif(valtype((cAliasTRB)->D1_BASEISS)  = "N", (cAliasTRB)->D1_BASEISS ,0) 				//--Base Iss
			aCampo53 := (cAliasTRB)->D1_ALIQISS   																//--Aliq. Iss
			nTot35   +=  iif(valtype((cAliasTRB)->D1_ABATISS)  = "N", (cAliasTRB)->D1_ABATISS ,0)			    //--Iss Servi�os
			nTot36   +=  iif(valtype((cAliasTRB)->D1_ABATMAT)  = "N", (cAliasTRB)->D1_ABATMAT ,0) 				//--Iss Materiais
			nTot37   +=  iif(valtype((cAliasTRB)->D1_VALISS)   = "N", (cAliasTRB)->D1_VALISS  ,0) 				//--Valor Iss 
			nTot38   +=  iif(valtype((cAliasTRB)->D1_AVLINSS)  = "N", (cAliasTRB)->D1_AVLINSS ,0) 				//--Inss Servi�os
			nTot39   +=  iif(valtype((cAliasTRB)->FT_BASECSL)  = "N", (cAliasTRB)->FT_BASECSL ,0) 				//--Base Csll
		    aCampo54 := (cAliasTRB)->FT_ALIQCSL    																//--Aliq. Csll
			nTot40   +=  iif(valtype((cAliasTRB)->FT_VALCSL)   = "N", (cAliasTRB)->FT_VALCSL  ,0) 				//--Valor Csll
			nTot41   +=  iif(valtype((cAliasTRB)->FT_BRETPIS)  = "N", (cAliasTRB)->FT_BRETPIS ,0) 				//--Base Pis Reten��o
			aCampo55 := 	(cAliasTRB)->FT_ARETPIS   															//--Aliq. Pis Reten��o
	        nTot42   +=  iif(valtype((cAliasTRB)->FT_VRETPIS)  = "N", (cAliasTRB)->FT_VRETPIS ,0) 				//--Valor Pis Reten��o
			nTot43   +=  iif(valtype((cAliasTRB)->FT_BRETCOF)  = "N", (cAliasTRB)->FT_BRETCOF ,0) 				//--Base Cofins Reten��o    
		    aCampo56 := (cAliasTRB)->FT_ARETCOF    																//--Aliq. Cofins Reten��o
			nTot44   +=  iif(valtype((cAliasTRB)->FT_VRETCOF)  = "N", (cAliasTRB)->FT_VRETCOF ,0) 				//--Valor Cofins Reten��o
			aCampo57 := (cAliasTRB)->F1_MENNOTA    																//--Msgn Nota Fiscal
			aCampo58 :=	cLogInc    																				//--Log. de Inclus�o
			aCampo59 :=	cLogAlt    																				//--Log. de Altera��o
			aCampo60 :=	cDtLogAlt    																			//--Dt. Log. de Altera��o
			aCampo61 :=	(cAliasTRB)->C7_NUM   																	//--Num. Pedido Compra
			aCampo62 :=	cCodNatur   																			//--Natureza Financeira		
	        nTot45   +=  iif(valtype((cAliasTRB)->F3_ISENICM)  = "N", (cAliasTRB)->F3_ISENICM ,0) 				//--ICMS Isento
			nTot46   +=  iif(valtype((cAliasTRB)->F3_OUTRICM)  = "N", (cAliasTRB)->F3_OUTRICM ,0) 				//--ICMS Outros
			nTot47   +=  iif(valtype((cAliasTRB)->F3_ISENIPI)  = "N", (cAliasTRB)->F3_ISENIPI ,0) 				//--IPI Isento
			nTot48   +=  iif(valtype((cAliasTRB)->F3_OUTRIPI)  = "N", (cAliasTRB)->F3_OUTRIPI ,0) 				//--IPI Outros
			aCampo63 := (cAliasTRB)->D1_PESO   																	//--Peso Total
			aCampo64 := (cAliasTRB)->FT_CODBCC    																//--Natureza Base de Calculo
			aCampo65 := (cAliasTRB)->FT_INDNTFR    																//--Natureza Frete
			aCampo66 := (cAliasTRB)->F1_UFORITR    																//--UF Origem do Transporte
			aCampo67 := (cAliasTRB)->F1_MUORITR    																//--Mun. Orig. do Transporte
			aCampo68 := (cAliasTRB)->F1_UFDESTR   																//--UF Destino do Transporte
			aCampo69 := (cAliasTRB)->F1_MUDESTR    																//--Mun. Dest. do Transporte
			aCampo70 := Alltrim( (cAliasTRB)->F4_DUPLIC )														//--Gera Duplicata 
			aCampo71 := (cAliasTRB)->W9_TX_FOB 																	//--Taxa Cambial  		
			aCampo72 := (cAliasTRB)->D1_CHASSI 																	//--Taxa Cambial  		

			nTot20 +=  iif(valtype((cAliasTRB)->D1_VUNIT)    = "N", (cAliasTRB)->D1_VUNIT   ,0)					//--Valor Unit. Item
			nTot21 +=  iif(valtype((cAliasTRB)->D1_DESC)     = "N", (cAliasTRB)->D1_DESC    ,0) 				//--Desconto Item
		
			(cAliasTRB)->(DbSkip())
			IF ( (cAliasTRB)->D1_DOC <> 	cNF ) .OR.  ( (cAliasTRB)->D1_DOC =	cNF .AND. (cAliasTRB)->D1_TES <> cTES )
			    //Imprimi totais
				oFWMSExcel:AddRow( cAba1	,cTabela1	,{ 	aCampo01,;    //--Cnpj/Cpf 
															aCampo02,;    //--Insc.Estadual
															aCampo03,;    //--Pessoa Fisica/Juridica
															aCampo04,;    //--UF
															aCampo05,;    //--Tes
															aCampo06,;    //--Finalidade TES
															nTot01  ,;    //--Valor Total Item
															aCampo07,;    //--Cfop
															nTot02  ,;    //--Valor Cont�bil
															nTot03  ,;    //--Base ICMS
															aCampo08,;    //--Aliq. ICMS
															nTot04  ,;    //--Valor ICMS
															aCampo09,;    //--Comiss�o
															nTot05  ,;    //--Base IPI					
															aCampo10,;    //--Aliq. IPI			
															nTot06  ,;    //--Valor IPI
															nTot07  ,;    //--Credito_Presumido IPI/Frete
															nTot08  ,;    //--Credito_Regional IPI
															nTot09  ,;    //--Base Subst
															nTot10  ,;    //--Valor Subst
															nTot11  ,;    //--Base Pis Apura��o
															aCampo11,;    //--Aliq. Pis Apura��o
															nTot12  ,;    //--Valor Pis Apura��o
															nTot13  ,;    //--Base Cofins Apura��o
															aCampo12,;    //--Aliq. Cofins Apura��o
															nTot14  ,;    //--Valor Cofins Apura��o
															nTot15  ,;    //--Base Pis ST ZFM
															aCampo13,;    //--Aliq. Pis ST ZFM
															nTot16  ,;	  //--Vl. Pis ST ZFM
															nTot17  ,;    //--Base Cof ST ZFM
															aCampo14,;    //--Aliq. Cof ST ZFM
															nTot18  ,;	  //--Vl. Cof ST ZFM
															nTot19  ,;    //--ICMS Difal
															aCampo15,;    //--CST ICMS
															aCampo16,;    //--CST IPI
															aCampo17,;    //--CST PIS
															aCampo18,;    //--CST COFINS
															aCampo19,;    //--Calcula ICMS
															aCampo20,;    //--Credita ICMS
															aCampo21,;    //--Calcula IPI
															aCampo22,;    //--Credita IPI
															aCampo23,;    //--Nota Fiscal
															aCampo24,;    //--Nf. Prefeitura
															aCampo25,;    //--S�rie
															aCampo26,;    //--Esp�cie
															aCampo27,;    //--Modelo
															aCampo28,;    //--Dt. de Entrada
															aCampo29,;    //--Dt. de Emiss�o
															aCampo30,;    //--Fornecedor\Cliente
															aCampo31,;    //--Loja
															aCampo32,;    //--Nome
															nTot22  ,;    //--Frete
															nTot23  ,;    //--Despesas Acessorias
															nTot24  ,;    //--Seguro
															nTot25  ,;    //--Acrescimo
															nTot26  ,;    //--Custo
															nTot27  ,;    //--Valor do Dif. de Aliq.
															aCampo33,;    //--Aliq. II
															nTot28  ,;    //--Valor II
															aCampo34,;    //--Num. Conhecimento
															aCampo35,;    //--Num. DI
															aCampo36,;    //--Data DI
															aCampo37,;    //--Empresa
															aCampo38,;    //--Situa��o
															aCampo39,;    //--Tipo Nota Fiscal
															aCampo40,;    //--Formulario
															aCampo41,;    //--Chave Nota Fiscal
															aCampo42,;    //--Protocolo
															aCampo43,;    //--Nota Fiscal Origem
															aCampo44,;    //--Tipo Cli\For
															aCampo45,;    //--Cli\For
															aCampo46,;    //--Estado
															aCampo47,;    //--Munic�pio
															aCampo48,;    //--Descri��o CFOP
															aCampo49,;    //--C�d.Verifica��o
															aCampo50,;    //--Ambiente
															nTot29  ,;    //--Base Irrf Reten��o
															aCampo51,;    //--Aliq. Irrf Reten��o
															nTot30  ,;    //--Irrf Reten��o
															nTot31  ,;    //--Base Inss
															aCampo52,;    //--Aliq. Inss
															nTot32  ,;    //--Inss Recolhido
															nTot33  ,;    //--Valor Inss
															nTot34  ,;    //--Base Iss
														    aCampo53,;    //--Aliq. Iss
															nTot35  ,;    //--Iss Servi�os
															nTot36  ,;    //--Iss Materiais
															nTot37  ,;    //--Valor Iss
															nTot38  ,;    //--Inss Servi�os
															nTot39  ,;    //--Base Csll
															aCampo54,;    //--Aliq. Csll
												    		nTot40  ,;    //--Valor Csll
															nTot41  ,;    //--Base Pis Reten��o
															aCampo55,;    //--Aliq. Pis Reten��o
															nTot42  ,;    //--Valor Pis Reten��o
															nTot43  ,;    //--Base Cofins Reten��o
															aCampo56,;    //--Aliq. Cofins Reten��o
															nTot44  ,;    //--Valor Cofins Reten��o
															aCampo57,;    //--Msgn Nota Fiscal
															aCampo58,;    //--Log. de Inclus�o
													    	aCampo59,;    //--Log. de Altera��o
															aCampo60,;    //--Dt. Log. de Altera��o
															aCampo61,;    //--Num. Pedido Compra
															aCampo62,;    //--Natureza Financeira
															nTot45  ,;    //--ICMS Isento
															nTot46  ,;    //--ICMS Outros
															nTot47  ,;    //--IPI Isento
												    		nTot48  ,;    //--IPI Outros
															aCampo63,;    //--Peso Total
															aCampo64,;    //--Natureza Base de Calculo
															aCampo65,;    //--Natureza Frete
															aCampo66,;    //--UF Origem do Transporte
															aCampo67,;    //--Mun. Orig. do Transporte
															aCampo68,;    //--UF Destino do Transporte
															aCampo69,;    //--Mun. Dest. do Transporte
															aCampo70,;	  //--Gera Duplicata 
															aCampo71,;    //--Taxa Cambial  		
															aCampo72 })	  //--Taxa Cambial  		

				//Zerar Acumulador
				nTot01   := nTot02   := nTot03   := nTot04   := nTot05   := nTot06   := nTot07   := nTot08   := nTot09   := nTot10    := 0
				nTot11   := nTot12   := nTot13   := nTot14   := nTot15   := nTot16   := nTot17   := nTot18   := nTot19   := nTot20    := 0
				nTot21   := nTot22   := nTot23   := nTot24   := nTot25   := nTot26   := nTot27   := nTot28   := nTot29   := nTot30    := 0
				nTot31   := nTot32   := nTot33   := nTot34   := nTot35   := nTot36   := nTot37   := nTot38   := nTot39   := nTot40    := 0
				nTot41   := nTot42   := nTot43   := nTot44   := nTot45   := nTot46   := nTot47   := nTot48                            := 0
				aCAMPO01 := aCAMPO02 := aCAMPO03 := aCAMPO04 := aCAMPO05 := aCAMPO06 := aCAMPO07 := aCAMPO08 := aCAMPO09 := aCAMPO10  := " "
	 			aCAMPO11 := aCAMPO12 := aCAMPO13 := aCAMPO14 := aCAMPO15 := aCAMPO16 := aCAMPO17 := aCAMPO18 := aCAMPO19 := aCAMPO20  := " "
	 			aCAMPO21 := aCAMPO22 := aCAMPO23 := aCAMPO24 := aCAMPO25 := aCAMPO26 := aCAMPO27 := aCAMPO28 := aCAMPO29 := aCAMPO30  := " "
	 			aCAMPO31 := aCAMPO32 := aCAMPO33 := aCAMPO34 := aCAMPO35 := aCAMPO36 := aCAMPO37 := aCAMPO38 := aCAMPO39 := aCAMPO40  := " "
	 			aCAMPO41 := aCAMPO42 := aCAMPO43 := aCAMPO44 := aCAMPO45 := aCAMPO46 := aCAMPO47 := aCAMPO48 := aCAMPO49 := aCAMPO50  := " "
	 			aCAMPO51 := aCAMPO52 := aCAMPO53 := aCAMPO54 := aCAMPO55 := aCAMPO56 := aCAMPO57 := aCAMPO58 := aCAMPO59 := aCAMPO60  := " "
	 			aCAMPO61 := aCAMPO62 := aCAMPO63 := aCAMPO64 := aCAMPO65 := aCAMPO66 := aCAMPO67 := aCAMPO68 := aCAMPO69 := aCAMPO70  := " " 
	 			aCAMPO71 := aCAMPO72 := aCAMPO73 := aCAMPO74 := aCAMPO75 := aCAMPO76 := aCAMPO77 := aCAMPO78 := aCAMPO79 := aCAMPO80  := " " 
	 			aCAMPO81 := aCAMPO82 := aCAMPO83 := aCAMPO84 := aCAMPO85 := aCAMPO86 := aCAMPO87 := aCAMPO88 := aCAMPO89 := aCAMPO90  := " "
	 			aCAMPO91 := aCAMPO92 := aCAMPO93 := aCAMPO94 := aCAMPO95 := aCAMPO96 := aCAMPO97 := aCAMPO98 := aCAMPO99 := aCAMPO100 := " "  

				//Proxima nota fiscal
				cNF :=  (cAliasTRB)->D1_DOC
				cTES := (cAliasTRB)->D1_TES 
			ENDIF
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
			oFWMsExcel:AddworkSheet(cAba2) //N�o utilizar n�mero junto com sinal de menos. Ex.: 1-.

			// Criando a Tabela.
			oFWMsExcel:AddTable( cAba2	,cTabela2	)

			// Criando Colunas.
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Empresa"				,1	,1	,.F.	) // Left - Texto	
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Observa��o"			,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Especie"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Nota Fiscal"			,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Serie"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Cliente"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Loja/Cli"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Emiss�o"				,2	,4	,.F.	) // Center - Data
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Dt Digita��o"			,2	,4	,.F.	) // Center - Data
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Chave NFe"			,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Descri��o"			,2	,1	,.F.	) // Center - Texto

			While (cTMPCanc)->(!EoF())
				
				oFWMSExcel:AddRow( cAba2	, cTabela2	, { Alltrim( (cTMPCanc)->F3_FILIAL ),;    //--Empresa
															Alltrim( (cTMPCanc)->F3_OBSERV ),;    //--Observa��o
															Alltrim( (cTMPCanc)->F3_ESPECIE ),;    //--Especie
															Alltrim( (cTMPCanc)->F3_NFISCAL ),;    //--Nota Fiscal
															Alltrim( (cTMPCanc)->F3_SERIE ),;    //--Serie
															Alltrim( (cTMPCanc)->F3_CLIEFOR ),;    //--Cliente
															Alltrim( (cTMPCanc)->F3_LOJA ),;    //--Loja/Cli
															IIF( Empty( SToD( (cTMPCanc)->F3_EMISSAO ) ), "", SToD( (cTMPCanc)->F3_EMISSAO ) ),;    //--Emiss�o
															IIF( Empty( SToD( (cTMPCanc)->F3_ENTRADA ) ), "", SToD( (cTMPCanc)->F3_ENTRADA ) ),;    //--Dt Digita��o
															AllTrim( (cTMPCanc)->F3_CHVNFE ),;    //--Chave NFe
															AllTrim( (cTMPCanc)->F3_DESCRET ) } )    //--Descri��o
				(cTMPCanc)->(DbSkip())
			EndDo

		EndIf

		// Ativando o arquivo e gerando o xml.
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)

		oFWMsExcel:DeActivate()
		FreeObj(oFWMsExcel)

		// Abrindo o excel e abrindo o arquivo xml.
		oExcel := MsExcel():New()           // Abre uma nova conex�o com Excel.
		oExcel:WorkBooks:Open(cArquivo)     // Abre uma planilha.
		oExcel:SetVisible(.T.)              // Visualiza a planilha.
		oExcel:Destroy()                    // Encerra o processo do gerenciador de tarefas.

	Else
		ApMsgAlert( "N�o foi encontrado nenhuma nota fiscal com os par�metros informados!!" )
	EndIf

	opPar:End()
	(cAliasTRB)->(DbCloseArea())
	IIF( Select( cTMPCanc ) > 0, (cTMPCanc)->( DbCloseArea() ), Nil )
	DbSelectArea("SA2")

Return()
/*
=====================================================================================
Programa.:              zRel002B
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              13/06/19
Descricao / Objetivo:   Gera Excel Notas de Saida
Doc. Origem:            GAP EST007 E GAP FAT022
Solicitante:            Fiscal
Uso......:              zSelect
Obs......:
=====================================================================================
*/
Static Function zRel002B(cArquivo)

	Local cQuery		:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cTMPCanc		:= GetNextAlias()
	Local cAba1			:= "Notas Fiscais de Sa�da"
	Local cAba2			:= "Notas Fiscais Canceladas"
	Local cTabela1		:= "Rela��o de Notas Fiscais de Sa�da"
	Local cTabela2		:= "Rela��o de Notas Fiscais Canceladas"
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

	Local nTot01 := nTot02 := nTot03 := nTot04 := nTot05 := nTot06 := nTot07 := nTot08 := nTot09 := nTot10  := 0
	Local nTot11 := nTot12 := nTot13 := nTot14 := nTot15 := nTot16 := nTot17 := nTot18 := nTot19 := nTot20  := 0
	Local nTot21 := nTot22 := nTot23 := nTot24 := nTot26 := nTot29 := nTot30 := 0
	Local nTot31 := nTot32 := nTot33 := nTot34 := nTot35 := nTot36 := nTot37 := nTot39 := nTot40 := 0
	Local nTot41 := nTot42 := nTot43 := nTot44 := nTot45 := nTot46 := nTot47 := nTot48 := nTot49 :=0

	Local aCAMPO01 := aCAMPO02 := aCAMPO03 := aCAMPO04 := aCAMPO05 := aCAMPO06 := aCAMPO07 := aCAMPO08 := aCAMPO09 := aCAMPO10  := " "
	Local aCAMPO11 := aCAMPO12 := aCAMPO13 := aCAMPO14 := aCAMPO15 := aCAMPO16 := aCAMPO17 := aCAMPO18 := aCAMPO19 := aCAMPO20  := " "
	Local aCAMPO21 := aCAMPO22 := aCAMPO23 := aCAMPO24 := aCAMPO25 := aCAMPO26 := aCAMPO27 := aCAMPO28 := aCAMPO29 := aCAMPO30  := " "
	Local aCAMPO31 := aCAMPO32 := aCAMPO33 := aCAMPO34 := aCAMPO35 := aCAMPO36 := aCAMPO37 := aCAMPO38 := aCAMPO39 := aCAMPO40  := " "
	Local aCAMPO41 := aCAMPO42 := aCAMPO43 := aCAMPO44 := aCAMPO45 := aCAMPO46 := aCAMPO47 := aCAMPO48 := aCAMPO49 := aCAMPO50  := " "
	Local aCAMPO51 := aCAMPO52 := aCAMPO53 := aCAMPO54 := aCAMPO55 := aCAMPO56 := aCAMPO57 := aCAMPO58 := aCAMPO59 := aCAMPO60  := " "
	Local aCAMPO61 := aCAMPO62 := aCAMPO63 := aCAMPO64 := aCAMPO65 := aCAMPO66 := aCAMPO67 := aCAMPO68 := aCAMPO69 := aCAMPO70  := " " 
	Local aCAMPO71 := aCAMPO72 := aCAMPO73 := aCAMPO74 := aCAMPO75 := aCAMPO76 := aCAMPO77 := aCAMPO78 := aCAMPO79 := aCAMPO80  := " " 
	Local aCAMPO81 := aCAMPO82 := aCAMPO83 := aCAMPO84 := aCAMPO85 := aCAMPO86 := aCAMPO87 := aCAMPO88 := aCAMPO89 := aCAMPO90  := " "
	Local aCAMPO91 := aCAMPO92 := aCAMPO93 := aCAMPO94 := aCAMPO95 := aCAMPO96 := aCAMPO97 := aCAMPO98 := aCAMPO99 := aCAMPO100 := " "  

	If !ApOleClient("MSExcel")
		MsgAlert("Microsoft Excel n�o instalado!")
		Return
	EndIf

	If Select( (cAliasTRB) ) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf

	cQuery += " SELECT D2_FILIAL, D2_COD, D2_DOC,D2_SERIE, D2_TES, D2_CF,D2_CLIENTE,D2_LOJA,D2_EMISSAO, D2_ITEMPV, "		+ CRLF
	cQuery += " F4_FINALID, F4_TEXTO, FT_CTIPI, FT_CSTPIS, FT_CSTCOF, F4_ICM, F4_IPI, F4_CREDICM, F4_CREDIPI, F4_DUPLIC, "	+ CRLF
	cQuery += " B1_DESC, B1_XDESCL1, B1_GRUPO, B1_POSIPI, B1_CEST, B1_ORIGEM, B1_EX_NBM, D2_ITEM, "							+ CRLF
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
	cQuery += " B1_DESC, B1_XDESCL1, B1_GRUPO, B1_POSIPI, B1_CEST, B1_ORIGEM, B1_EX_NBM, D2_ITEM, "							+ CRLF
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

	cQuery += " ORDER BY SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA , SD2.D2_TES" 						+ CRLF

	cQuery := ChangeQuery(cQuery)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

	DbSelectArea((cAliasTRB))
	nTotReg := Contar(cAliasTRB,"!Eof()")
	(cAliasTRB)->(dbGoTop())
	

	If (cAliasTRB)->(!Eof())

		// Criando o objeto que ir� gerar o conte�do do Excel.
		oFWMsExcel := FWMSExcelEx():New()

		// Aba 01
		oFWMsExcel:AddworkSheet(cAba1) //N�o utilizar n�mero junto com sinal de menos. Ex.: 1-.

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
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Total Item"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cfop"							,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Cont�bil"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base ICMS"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. ICMS"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor ICMS"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Comiss�o"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base IPI"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. IPI"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor IPI"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Credito_Regional IPI"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Credito_Presumido IPI/Frete"	,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Subst"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Subst"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Pis Apura��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Pis Apura��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Pis Apura��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Cofins Apura��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Cofins Apura��o"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Cofins Apura��o"		,3	,2	,.F.	) // Right - Number
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
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"S�rie"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Esp�cie"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Modelo"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt. de Emiss�o"				,2	,4	,.F.	) // Center - Data
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cliente\Fornecedor"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Loja"							,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nome"							,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Frete"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Seguro"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Despesas"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Custo"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Empresa"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Situa��o"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tipo Nota Fiscal"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Chave Nota Fiscal"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Protocolo"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nota Fiscal Origem"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tipo Cli\For"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cli\For"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Estado"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Munic�pio"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descri��o CFOP"				,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"C�d.Verifica��o"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Ambiente"						,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Irrf Reten��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Irrf Reten��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Irrf Reten��o"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Inss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Inss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Inss Recolhido"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Inss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Iss"						,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Iss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Iss Servi�os"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Iss Materiais"				,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Iss"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Csll"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Csll"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Csll"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Pis Reten��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Pis Reten��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Pis Reten��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Base Cofins Reten��o"			,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Aliq. Cofins Reten��o"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Cofins Reten��o"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Log. de Inclus�o"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Log. de Altera��o"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt. Log. de Altera��o"		,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tipo Venda"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descr. Tipo Venda"			,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Num. Pedido"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Natureza Financeira"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"ICMS Isento"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"ICMS Outros"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"IPI Isento"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"IPI Outros"					,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"C�d. Transportadora"			,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cat. Local de Entrega"		,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nome Loc. Entr."				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"UF Loc. Entr."				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Msgn Nota Fiscal"				,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Mens.p/Nota"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Mens. Padr�o"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Mensagem NFS"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Vlr. Aprox. dos Tributos"		,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Gera Duplicata"				,2	,1	,.F.	) // Center - Texto

		// Conta quantos registros existem, e seta no tamanho da r�gua.
		ProcRegua( nTotReg )

		VV2->( DbSetOrder(7) ) // VV2_FILIAL+VV2_PRODUT
		SF2->( DbSetOrder(2) ) // F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
		SA1->( DbSetOrder(1) ) // A1_FILIAL+A1_COD+A1_LOJA
		SA2->( DbSetOrder(1) ) // A2_FILIAL+A2_COD+A2_LOJA
		SC5->( DbSetOrder(1) ) // C5_FILIAL+C5_NUM
		CDA->( DbSetOrder(1) ) // CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA+CDA_NUMITE

		DbSelectArea((cAliasTRB))
		(cAliasTRB)->(dbGoTop())
		cNF :=  (cAliasTRB)->D2_DOC
		cTES := (cAliasTRB)->D2_TES
		While (cAliasTRB)->(!EoF())

			// Incrementa a mensagem na r�gua.
			IncProc( "Exportando informa��es para Excel..." )

			// TRATAMENTO PARA BUSCAR O LOG DO USU�RIO.
			cLogInc 	:= ""
			cLogAlt 	:= ""
			cDtLogAlt	:= ""
			If SF2->(dbSeek( (cAliasTRB)->D2_FILIAL + (cAliasTRB)->D2_CLIENTE + (cAliasTRB)->D2_LOJA + (cAliasTRB)->D2_DOC + (cAliasTRB)->D2_SERIE + (cAliasTRB)->F2_TIPO + (cAliasTRB)->F2_ESPECIE))
				cLogInc 	:= FWLeUserlg( "F2_USERLGI" )
				cLogAlt 	:= FWLeUserlg( "F2_USERLGA" )
				cDtLogAlt	:= FWLeUserlg( "F2_USERLGA", 2 )
			EndIf

			// Busca informa��es da Nota Fiscal no servidor TSS.
			cAmbiente 	:= ""
			cProtocolo	:= ""
			cMsgSefaz 	:= ""
			aInfNfe		:= {}
			//--Trecho removido pois estava causando lentid�o, estes campos ser�o utilizados em um relatorio a parte
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
					cSituacao	:= "NF n�o transmitida"
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
			If (cAliasTRB)->F2_TIPO $ "B|D" // Benefeciamento ou devolu��o
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
					cCliFor		:= "FORNECEDOR N�O ENCONTRADO NA BASE DE DADOS"
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
					cCliFor		:= "CLIENTE N�O ENCONTRADO NA BASE DE DADOS"
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

			//--Necessario essa redundancia porque o cliente da nota n�o sera o cliente de retirada na maioria dos casos
			//--Grava registros de cliente/fornecedor quando informados no pedido de venda do SIGAVEI, campo VRJ_CLIRET
			If !Empty( (cAliasTRB)->VRJ_CLIRET )
				If (cAliasTRB)->F2_TIPO $ "B|D" // Benefeciamento ou devolu��o
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
					cTpNF	:= "Tipo n�o encontrado"
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
			zRel003B(@nVlIPIRegi, @nVlIPIPres, (cAliasTRB)->F2_ESPECIE, (cAliasTRB)->F2_DOC, (cAliasTRB)->F2_SERIE,;
					(cAliasTRB)->D2_CLIENTE, (cAliasTRB)->D2_LOJA, (cAliasTRB)->D2_ITEM )	

					aCampo01 :=	cCgcCpf
					aCampo02 :=	cCGCLocEnt
					aCampo03 := cIncEst                              //--Insc.Estadual
					aCampo04 :=	cTpPessoa                            //--Pessoa Fisica/Juridica
					aCampo05 :=	cEstCli                              //--UF
					aCampo06 := (cAliasTRB)->D2_TES                  //--Tes
					aCampo07 :=	Alltrim( (cAliasTRB)->F4_FINALID )   //--Finalidade TES
					nTot01   +=  iif(valtype((cAliasTRB)->D2_TOTAL)    = "N", (cAliasTRB)->D2_TOTAL   ,0) //--Valor Total Item
					aCampo08 := (cAliasTRB)->D2_CF    //--Cfop
					nTot02   +=  iif(valtype((cAliasTRB)->FT_VALCONT)  = "N", (cAliasTRB)->FT_VALCONT ,0) //--Valor Cont�bil
					nTot03   +=  iif(valtype((cAliasTRB)->FT_BASEICM)  = "N", (cAliasTRB)->FT_BASEICM ,0) //--Base ICMS
					aCAmpo09 := (cAliasTRB)->FT_ALIQICM   //--Aliq. ICMS
					nTot04   +=  iif(valtype((cAliasTRB)->FT_VALICM)   = "N", (cAliasTRB)->FT_VALICM  ,0) //--Valor ICMS
					aCAmpo10 := (cAliasTRB)->C6_XVLCOM    //--Comiss�o
					nTot05   +=  iif(valtype((cAliasTRB)->FT_BASEIPI)  = "N", (cAliasTRB)->FT_BASEIPI ,0) //--Base IPI
					aCampo11 := (cAliasTRB)->FT_ALIQIPI    //--Aliq. IPI
					nTot06   +=  iif(valtype((cAliasTRB)->FT_VALIPI)   = "N", (cAliasTRB)->FT_VALIPI  ,0) //--Valor IPI
					nTot07   +=  iif(valtype(nVlIPIRegi)               = "N", nVlIPIRegi              ,0) //--Credito_Regional IPI
					nTot08   +=  iif(valtype(nVlIPIPres)               = "N", nVlIPIPres              ,0) //--Credito_Presumido IPI/Frete
   					nTot09   +=  iif(valtype((cAliasTRB)->FT_BASERET)  = "N", (cAliasTRB)->FT_BASERET ,0) //--Base Subst
					nTot10   +=  iif(valtype((cAliasTRB)->FT_ICMSRET)  = "N", (cAliasTRB)->FT_ICMSRET ,0) //--Valor Subst
					nTot11   +=  iif(valtype((cAliasTRB)->FT_BASEPIS)  = "N", (cAliasTRB)->FT_BASEPIS ,0) //--Base Pis Apura��o
					aCampo12 := (cAliasTRB)->FT_ALIQPIS    //--Aliq. Pis Apura��o
					nTot12   +=  iif(valtype((cAliasTRB)->FT_VALPIS)   = "N", (cAliasTRB)->FT_VALPIS  ,0) //--Valor Pis Apura��o
					nTot13   +=  iif(valtype((cAliasTRB)->FT_BASECOF)  = "N", (cAliasTRB)->FT_BASECOF ,0) //--Base Cofins Apura��o
					aCampo13 := (cAliasTRB)->FT_ALIQCOF	//--Aliq. Cofins Apura��o
					nTot14   +=  iif(valtype((cAliasTRB)->FT_VALCOF)   = "N", (cAliasTRB)->FT_VALCOF  ,0) //--Valor Cofins Apura��o
					nTot15   +=  iif(valtype((cAliasTRB)->FT_BASEPS3)  = "N", (cAliasTRB)->FT_BASEPS3 ,0) //--Base Pis ST ZFM
					aCampo14 := (cAliasTRB)->FT_ALIQPS3    //--Aliq. Pis ST ZFM
					nTot16   +=  iif(valtype((cAliasTRB)->FT_VALPS3)	 = "N", (cAliasTRB)->FT_VALPS3  ,0) //--Vl. Pis ST ZFM
					nTot17   +=  iif(valtype((cAliasTRB)->FT_BASECF3)  = "N", (cAliasTRB)->FT_BASECF3 ,0) //--Base Cof ST ZFM
					aCAmpo15 := (cAliasTRB)->FT_ALIQCF3    //--Aliq. Cof ST ZFM
					nTot18   +=  iif(valtype((cAliasTRB)->FT_VALCF3)	 = "N", (cAliasTRB)->FT_VALCF3  ,0) //--Vl. Cof ST ZFM
					nTot19   +=  iif(valtype((cAliasTRB)->FT_DIFAL)    = "N", (cAliasTRB)->FT_DIFAL   ,0) //--ICMS Difal
					aCAmpo16 := (cAliasTRB)->FT_CLASFIS    //--CST ICMS
					aCAmpo17 := (cAliasTRB)->FT_CTIPI  //--CST IPI
					aCAmpo18 := (cAliasTRB)->FT_CSTPIS    //--CST PIS
					aCAmpo19 := (cAliasTRB)->FT_CSTCOF   //--CST COFINS
					aCAmpo20 := (cAliasTRB)->F4_ICM  //--Calcula ICMS
					aCAmpo21 := (cAliasTRB)->F4_CREDICM   //--Credita ICMS
					aCAmpo22 := (cAliasTRB)->F4_IPI   //--Calcula IPI
					aCAmpo23 := (cAliasTRB)->F4_CREDIPI    //--Credita IPI
					aCAmpo24 := (cAliasTRB)->D2_DOC  //--Nota Fiscal
					aCAmpo25 := IIF( AllTrim( (cAliasTRB)->F2_ESPECIE ) == 'NFS', (cAliasTRB)->D2_DOC, "")   //--Nf. Prefeitura
					aCAmpo26 := (cAliasTRB)->D2_SERIE   //--S�rie
					aCAmpo27 := (cAliasTRB)->F2_ESPECIE    //--Esp�cie
					aCAmpo28 := AModNot( (cAliasTRB)->F2_ESPECIE )    //--Modelo
					aCAmpo29 := IIF( Empty( SToD( (cAliasTRB)->D2_EMISSAO ) ), "", SToD( (cAliasTRB)->D2_EMISSAO ) )    //--Dt. de Emiss�o
					aCAmpo30 := (cAliasTRB)->D2_CLIENTE   //--Cliente\Fornecedor
					aCAmpo31 := (cAliasTRB)->D2_LOJA    //--Loja
					aCAmpo32 := cCliFor  //--Nome
					nTot22   +=  iif(valtype(nVlrFrete)                = "N", nVlrFrete               ,0) //--Frete
					nTot23   +=  iif(valtype(nVlrSeguro)               = "N", nVlrSeguro              ,0) //--Seguro
					nTot24   +=  iif(valtype(nVlrDesp)                 = "N", nVlrDesp                ,0) //--Despesas Acessorias
					nTot26   +=  iif(valtype((cAliasTRB)->D2_CUSTO1)   = "N", (cAliasTRB)->D2_CUSTO1 ,0) //--Custo
					aCAmpo33 := AllTrim( (cAliasTRB)->D2_FILIAL )   //--Empresa
					aCAmpo34 := cSituacao   //--Situa��o
					aCAmpo35 := cTpNF  //--Tipo Nota Fiscal
					aCAmpo36 := (cAliasTRB)->FT_CHVNFE    //--Chave Nota Fiscal
					aCAmpo37 := cProtocolo    //--Protocolo
					aCAmpo38 := AllTrim( (cAliasTRB)->D2_NFORI ) + " - " + AllTrim( (cAliasTRB)->D2_SERIORI )   //--Nota Fiscal Origem
					aCAmpo39 := cDescTipo   //--Tipo Cli\For
					aCAmpo40 := cTpCliFor   //--Cli\For
					aCAmpo41 := AllTrim( Posicione("SX5" ,1 ,xFilial("SX5") + "12" + cEstCli,"X5_DESCRI") )     //--Estado
					aCAmpo42 := AllTrim( Posicione("CC2" ,1 ,xFilial("CC2") + cEstCli + PadR( cCodMun ,TamSx3("CC2_CODMUN")[1] ) , "CC2_MUN" ) )   //--Munic�pio
					aCAmpo43 := AllTrim( (cAliasTRB)->F4_TEXTO )   //--Descri��o CFOP
					aCAmpo44 := (cAliasTRB)->F2_CODNFE   //--C�d.Verifica��o
					aCAmpo45 := cAmbiente   //--Ambiente
					nTot29   +=  iif(valtype((cAliasTRB)->FT_BASEIRR)  = "N", (cAliasTRB)->FT_BASEIRR ,0) //--Base Irrf Reten��o
					aCAmpo46 := (cAliasTRB)->FT_ALIQIRR   //--Aliq. Irrf Reten��o
					nTot30   +=  iif(valtype((cAliasTRB)->FT_VALIRR)   = "N", (cAliasTRB)->FT_VALIRR  ,0) //--Irrf Reten��o
					nTot31   +=  iif(valtype((cAliasTRB)->FT_BASEINS)  = "N", (cAliasTRB)->FT_BASEINS ,0) //--Base Inss
					aCampo47 := (cAliasTRB)->FT_ALIQINS   //--Aliq. Inss
					nTot32   +=  iif(valtype((cAliasTRB)->D2_ABATINS)  = "N", (cAliasTRB)->D2_ABATINS ,0) //--Inss Recolhido
					nTot33   +=  iif(valtype((cAliasTRB)->FT_VALINS)   = "N", (cAliasTRB)->FT_VALINS  ,0) //--Valor Inss
					nTot34   +=  iif(valtype((cAliasTRB)->D2_BASEISS)  = "N", (cAliasTRB)->D2_BASEISS ,0) //--Base Iss
					aCampo48 := (cAliasTRB)->D2_ALIQISS    //--Aliq. Iss
					nTot35   +=  iif(valtype((cAliasTRB)->D2_ABATISS)  = "N", (cAliasTRB)->D2_ABATISS ,0) //--Iss Servi�os
					nTot36   +=  iif(valtype((cAliasTRB)->D2_ABATMAT)  = "N", (cAliasTRB)->D2_ABATMAT ,0) //--Iss Materiais
					nTot37   +=  iif(valtype((cAliasTRB)->D2_VALISS)   = "N", (cAliasTRB)->D2_VALISS  ,0) //--Valor Iss 
					nTot39   +=  iif(valtype((cAliasTRB)->FT_BASECSL)  = "N", (cAliasTRB)->FT_BASECSL ,0) //--Base Csll
					aCampo49 := IIF( (cAliasTRB)->FT_BASECSL > 0, (cAliasTRB)->FT_ALIQCSL, 0 )   //--Aliq. Csll
					nTot40   +=  iif(valtype((cAliasTRB)->FT_VALCSL)   = "N", (cAliasTRB)->FT_VALCSL  ,0) //--Valor Csll
					nTot41   +=  iif(valtype((cAliasTRB)->FT_BRETPIS)  = "N", (cAliasTRB)->FT_BRETPIS ,0) //--Base Pis Reten��o
        			aCampo50 :=	IIF( (cAliasTRB)->FT_BRETPIS > 0, (cAliasTRB)->FT_ARETPIS, 0 )    //--Aliq. Pis Reten��o
    				nTot42   +=  iif(valtype((cAliasTRB)->FT_VRETPIS)  = "N", (cAliasTRB)->FT_VRETPIS ,0) //--Valor Pis Reten��o
					nTot43   +=  iif(valtype((cAliasTRB)->FT_BRETCOF)  = "N", (cAliasTRB)->FT_BRETCOF ,0) //--Base Cofins Reten��o    
					aCampo51 := IIF( (cAliasTRB)->FT_BRETCOF > 0, (cAliasTRB)->FT_ARETCOF, 0 )    //--Aliq. Cofins Reten��o
 					nTot44   +=  iif(valtype((cAliasTRB)->FT_VRETCOF)  = "N", (cAliasTRB)->FT_VRETCOF ,0) //--Valor Cofins Reten��o
					aCampo52 := cLogInc   //--Log. de Inclus�o
					aCampo53 := cLogAlt    //--Log. de Altera��o
					aCampo54 := cDtLogAlt    //--Dt. Log. de Altera��o
					aCampo55 := AllTrim( (cAliasTRB)->VV3_TIPVEN )    //--Tipo Venda
					aCampo56 := AllTrim( (cAliasTRB)->VV3_DESCRI )   //--Descr. Tipo Venda
					aCampo57 := cNumPed   //--Num. Pedido
					aCampo58 := cNaturez   //--Natureza Financeira
					nTot45   +=  iif(valtype((cAliasTRB)->F3_ISENICM)  = "N", (cAliasTRB)->F3_ISENICM ,0) //--ICMS Isento
					nTot46   +=  iif(valtype((cAliasTRB)->F3_OUTRICM)  = "N", (cAliasTRB)->F3_OUTRICM ,0) //--ICMS Outros
					nTot47   +=  iif(valtype((cAliasTRB)->F3_ISENIPI)  = "N", (cAliasTRB)->F3_ISENIPI ,0) //--IPI Isento
					nTot48   +=  iif(valtype((cAliasTRB)->F3_OUTRIPI)  = "N", (cAliasTRB)->F3_OUTRIPI ,0) //--IPI Outros
					aCampo59 := cTransp    //--C�d. Transportadora
					aCampo60 := (cAliasTRB)->VRJ_CLIRET //--Cat. Local de Entrega
					aCampo61 := cNomLocEnt   //--Nome Loc. Entr.
					aCampo62 := cUFLocEnt    //--UF Loc. Entr.
					aCampo63 := (cAliasTRB)->F2_MENNOTA    //--Msgn Nota Fiscal   
					aCampo64 := cMenNota   //--Mens.p/Nota
					aCamps65 := cMenPad    //--Mens. Padr�o
					aCampo66 := cMensNFS   //--Mensagem NFS	
					nTot49   +=  iif(valtype((cAliasTRB)->F2_TOTFED)   = "N", (cAliasTRB)->( F2_TOTFED + F2_TOTEST ) ,0) //--IPI Outros
					aCampo67 := Alltrim( (cAliasTRB)->F4_DUPLIC ) 	//--Gera Duplicata   	
					nTot20   +=  iif(valtype((cAliasTRB)->D2_PRUNIT)   = "N", (cAliasTRB)->D2_PRUNIT   ,0) //--Valor Unit. Item
					nTot21   +=  iif(valtype((cAliasTRB)->D2_DESC)     = "N", (cAliasTRB)->D2_DESC    ,0) //--Desconto Item

			(cAliasTRB)->(DbSkip())

			IF ( (cAliasTRB)->D2_DOC <> 	cNF ) .or. ((cAliasTRB)->D2_DOC = cNF .and. (cAliasTRB)->D2_TES <> 	cTES )
                //Imprimi os totais

				oFWMSExcel:AddRow( cAba1	, cTabela1	, { aCampo01,;    //--Cnpj/Cpf
														    aCampo02,;    //--CNPJ Loc. Entr.
														    aCampo03,;    //--Insc.Estadual
													        aCampo04,;    //--Pessoa Fisica/Juridica
															aCampo05,;    //--UF
															aCampo06,;    //--Tes
															aCampo07,;    //--Finalidade TES
															nTot01  ,;    //--Valor Total Item
															aCampo08,;    //--Cfop
															nTot02  ,;    //--Valor Cont�bil
															nTot03  ,;    //--Base ICMS
															aCampo09,;    //--Aliq. ICMS
															nTot04  ,;    //--Valor ICMS
															aCampo10,;    //--Comiss�o
															nTot05  ,;    //--Base IPI
															aCampo11,;    //--Aliq. IPI
															nTot06  ,;    //--Valor IPI
															nTot07  ,;    //--Credito_Regional IPI
															nTot08  ,;    //--Credito_Presumido IPI/Frete
															nTot09  ,;    //--Base Subst
															nTot10  ,;    //--Valor Subst
															nTot11  ,;    //--Base Pis Apura��o
															aCampo12,;    //--Aliq. Pis Apura��o
															nTot12  ,;    //--Valor Pis Apura��o
															nTot13  ,;    //--Base Cofins Apura��o
															aCampo13,;	  //--Aliq. Cofins Apura��o
															nTot14  ,;	  //--Valor Cofins Apura��o
															nTot15  ,;    //--Base Pis ST ZFM
															aCampo14,;    //--Aliq. Pis ST ZFM
															nTot16  ,;	  //--Vl. Pis ST ZFM
															nTot17  ,;    //--Base Cof ST ZFM
															aCampo15,;    //--Aliq. Cof ST ZFM
															nTot18  ,;	  //--Vl. Cof ST ZFM
															nTot19  ,;    //--ICMS Difal
															aCampo16,;    //--CST ICMS
															aCampo17,;    //--CST IPI
															aCampo18,;    //--CST PIS
															aCampo19,;    //--CST COFINS
															aCampo20,;    //--Calcula ICMS
															aCampo21,;    //--Credita ICMS
															aCampo22,;    //--Calcula IPI
															aCampo23,;    //--Credita IPI
															aCampo24,;    //--Nota Fiscal
															aCampo25,;    //--Nf. Prefeitura
															aCampo26,;    //--S�rie
															aCAmpo27,;    //--Esp�cie
															aCampo28,;    //--Modelo
															aCampo29,;    //--Dt. de Emiss�o
															aCampo30,;    //--Cliente\Fornecedor
															aCampo31,;    //--Loja
															aCampo32,;    //--Nome
															nTot22  ,;    //--Frete
															nTot23  ,;    //--Seguro
															nTot24  ,;    //--Despesas
															nTot26  ,;    //--Custo
															aCampo33,;    //--Empresa
															aCampo34,;    //--Situa��o
															aCampo35,;    //--Tipo Nota Fiscal
															aCampo36,;    //--Chave Nota Fiscal
															aCampo37,;    //--Protocolo
															aCampo38,;    //--Nota Fiscal Origem
															aCampo39,;    //--Tipo Cli\For
															aCampo40,;    //--Cli\For
															aCampo41,;    //--Estado
															aCampo42,;    //--Munic�pio
															aCampo43,;    //--Descri��o CFOP
															aCampo44,;    //--C�d.Verifica��o
															aCampo45,;    //--Ambiente
															nTot29  ,;    //--Base Irrf Reten��o
															aCampo46,;    //--Aliq. Irrf Reten��o
															nTot30  ,;    //--Irrf Reten��o
															nTot31  ,;    //--Base Inss
															aCampo47,;    //--Aliq. Inss
															nTot32  ,;    //--Inss Recolhido
															nTot33  ,;    //--Valor Inss
															nTot34  ,;    //--Base Iss
															aCampo48,;    //--Aliq. Iss
															nTot35  ,;    //--Iss Servi�os
															nTot36  ,;    //--Iss Materiais
															nTot37  ,;	  //--Valor Iss
															nTot39  ,;    //--Base Csll
															aCampo49,;    //--Aliq. Csll
															nTot40  ,;    //--Valor Csll
															nTot41  ,;    //--Base Pis Reten��o
															aCampo50,;    //--Aliq. Pis Reten��o
															nTot42  ,;    //--Valor Pis Reten��o
															nTot43  ,;    //--Base Cofins Reten��o
															aCampo51,;    //--Aliq. Cofins Reten��o
															nTot44  ,;    //--Valor Cofins Reten��o
															aCampo52,;    //--Log. de Inclus�o
															aCampo53,;    //--Log. de Altera��o
															aCampo54,;    //--Dt. Log. de Altera��o
															aCampo55,;    //--Tipo Venda
															aCampo56,;    //--Descr. Tipo Venda
															aCampo57,;    //--Num. Pedido
															aCampo58,;    //--Natureza Financeira
															nTot45  ,;    //--ICMS Isento
															nTot46  ,;    //--ICMS Outros
															nTot47  ,;    //--IPI Isento
															nTot48  ,;    //--IPI Outros
															aCampo59,;    //--C�d. Transportadora
															aCampo60,;    //--Cat. Local de Entrega
															aCampo61,;    //--Nome Loc. Entr.
															aCampo62,;    //--UF Loc. Entr.
															aCampo63,;    //--Msgn Nota Fiscal   
															aCampo64,;    //--Mens.p/Nota
															aCampo65,;    //--Mens. Padr�o
															aCampo66,;    //--Mensagem NFS	
															nTot49  ,;	  //--Vlr. Aprox. dos Tributos	
															aCampo67 })	  //--Gera Duplicata   		

                //Zera os acumuladores
				nTot01 := nTot02 := nTot03 := nTot04 := nTot05 := nTot06 := nTot07 := nTot08 := nTot09 := nTot10  := 0
				nTot11 := nTot12 := nTot13 := nTot14 := nTot15 := nTot16 := nTot17 := nTot18 := nTot19 := nTot20  := 0
				nTot21 := nTot22 := nTot23 := nTot24 := nTot26 := nTot29 := nTot30 := 0
				nTot31 := nTot32 := nTot33 := nTot34 := nTot35 := nTot36 := nTot37 := nTot39 := nTot40 := 0
				nTot41 := nTot42 := nTot43 := nTot44 := nTot45 := nTot46 := nTot47 := nTot48 := nTot49 :=0
				
			    aCAMPO01 := aCAMPO02 := aCAMPO03 := aCAMPO04 := aCAMPO05 := aCAMPO06 := aCAMPO07 := aCAMPO08 := aCAMPO09 := aCAMPO10  := " "
	 			aCAMPO11 := aCAMPO12 := aCAMPO13 := aCAMPO14 := aCAMPO15 := aCAMPO16 := aCAMPO17 := aCAMPO18 := aCAMPO19 := aCAMPO20  := " "
	 			aCAMPO21 := aCAMPO22 := aCAMPO23 := aCAMPO24 := aCAMPO25 := aCAMPO26 := aCAMPO27 := aCAMPO28 := aCAMPO29 := aCAMPO30  := " "
	 			aCAMPO31 := aCAMPO32 := aCAMPO33 := aCAMPO34 := aCAMPO35 := aCAMPO36 := aCAMPO37 := aCAMPO38 := aCAMPO39 := aCAMPO40  := " "
	 			aCAMPO41 := aCAMPO42 := aCAMPO43 := aCAMPO44 := aCAMPO45 := aCAMPO46 := aCAMPO47 := aCAMPO48 := aCAMPO49 := aCAMPO50  := " "
	 			aCAMPO51 := aCAMPO52 := aCAMPO53 := aCAMPO54 := aCAMPO55 := aCAMPO56 := aCAMPO57 := aCAMPO58 := aCAMPO59 := aCAMPO60  := " "
	 			aCAMPO61 := aCAMPO62 := aCAMPO63 := aCAMPO64 := aCAMPO65 := aCAMPO66 := aCAMPO67 := aCAMPO68 := aCAMPO69 := aCAMPO70  := " " 
	 			aCAMPO71 := aCAMPO72 := aCAMPO73 := aCAMPO74 := aCAMPO75 := aCAMPO76 := aCAMPO77 := aCAMPO78 := aCAMPO79 := aCAMPO80  := " " 
	 			aCAMPO81 := aCAMPO82 := aCAMPO83 := aCAMPO84 := aCAMPO85 := aCAMPO86 := aCAMPO87 := aCAMPO88 := aCAMPO89 := aCAMPO90  := " "
	 			aCAMPO91 := aCAMPO92 := aCAMPO93 := aCAMPO94 := aCAMPO95 := aCAMPO96 := aCAMPO97 := aCAMPO98 := aCAMPO99 := aCAMPO100 := " "  

	            //Processa pr�xima nf
		        cNF  :=  (cAliasTRB)->D2_DOC
				cTES := (cAliasTRB)->D2_TES
			
			Endif
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
			oFWMsExcel:AddworkSheet(cAba2) //N�o utilizar n�mero junto com sinal de menos. Ex.: 1-.

			// Criando a Tabela.
			oFWMsExcel:AddTable( cAba2	,cTabela2	)

			// Criando Colunas.
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Empresa"				,1	,1	,.F.	) // Left - Texto	
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Observa��o"			,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Especie"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Nota Fiscal"			,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Serie"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Cliente"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Loja/Cli"				,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Emiss�o"				,2	,4	,.F.	) // Center - Data
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Chave NFe"			,2	,1	,.F.	) // Center - Texto
			oFWMsExcel:AddColumn( cAba2	,cTabela2	,"Descri��o"			,2	,1	,.F.	) // Center - Texto


			While (cTMPCanc)->(!EoF())
				
				oFWMSExcel:AddRow( cAba2	, cTabela2	, { Alltrim( (cTMPCanc)->F3_FILIAL ),;    //--Empresa
															Alltrim( (cTMPCanc)->F3_OBSERV ),;    //--Observa��o
															Alltrim( (cTMPCanc)->F3_ESPECIE ),;    //--Especie
															Alltrim( (cTMPCanc)->F3_NFISCAL ),;    //--Nota Fiscal
															Alltrim( (cTMPCanc)->F3_SERIE ),;    //--Serie
															Alltrim( (cTMPCanc)->F3_CLIEFOR ),;    //--Cliente
															Alltrim( (cTMPCanc)->F3_LOJA ),;    //--Loja/Cli
															IIF( Empty( SToD( (cTMPCanc)->F3_EMISSAO ) ), "", SToD( (cTMPCanc)->F3_EMISSAO ) ),;    //--Emiss�o
															AllTrim( (cTMPCanc)->F3_CHVNFE ),;    //--Chave NFe
															AllTrim( (cTMPCanc)->F3_DESCRET ) } )    //--Descri��o
				(cTMPCanc)->(DbSkip())
			EndDo

		EndIf
		
		// Ativando o arquivo e gerando o xml.
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile( cArquivo )

		oFWMsExcel:DeActivate()
		FreeObj(oFWMsExcel)

		// Abrindo o excel e abrindo o arquivo xml.
		oExcel := MsExcel():New()           // Abre uma nova conex�o com Excel.
		oExcel:WorkBooks:Open( cArquivo )   // Abre uma planilha.
		oExcel:SetVisible(.T.)              // Visualiza a planilha.
		oExcel:Destroy()                    // Encerra o processo do gerenciador de tarefas.

	Else
		ApMsgAlert( "N�o foi encontrado nenhuma nota fiscal com os par�metros informados!!" )
	EndIf

	opPar:End()
	(cAliasTRB)->(DbCloseArea())
	IIF( Select( cTMPCanc ) > 0, (cTMPCanc)->( DbCloseArea() ), Nil )
	DbSelectArea("SA1")

Return()

/*
=====================================================================================
Programa.:              zRel003B
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              26/02/20
Descricao / Objetivo:   Realiza consulta na tabela CDA e alimenta as variaveis de IPI
Doc. Origem:            
Solicitante:            
Uso......:              zRel002B
Obs......:
=====================================================================================
*/
Static Function zRel003B( nVlIPIRegi, nVlIPIPres, cEspecie, cDoc, cSerie, cCodCli, cCodLoja, cItem )
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
		
		If AllTrim( ( cAliasTMP )->CDA_CODLAN ) == '012' //-- Credito Regional IPI, com base nos registros atuais, n�o h� registro para este c�digo na tabela CC6
			nVlIPIRegi := ( cAliasTMP )->CDA_VALOR
		ElseIf AllTrim( ( cAliasTMP )->CDA_CODLAN ) == '013' //-- Credito presumido IPI, com base nos registros atuais, n�o h� registro para este c�digo na tabela CC6
			nVlIPIPres := ( cAliasTMP )->CDA_VALOR
		EndIf

		( cAliasTMP )->( DbSkip() )
	EndDo
	
	( cAliasTMP )->( DbCloseArea() )
	RestArea( aArea )
Return()
