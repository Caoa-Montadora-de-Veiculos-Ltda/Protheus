#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"


#Define CRLF Chr(13) + Chr(10)

/*/{Protheus.doc} ZFATF010.PRW
Função de Consulta do Faturamento - CAOA
@author Sandro Ferreira
@since 13/04/2021
@version 1.0
@type function
/*/
User Function ZFISR018()
Local _lJob := If( IsBlind(),.T.,.F.)
Local _lAbre		:= .F.
Local _lRet
Local _nPos   
Local _cEmpresa	
Local _cFilial 

Begin Sequence

	FWMsgRun(,{|| ZFATF018PRC(_lJob) },,"Realizando a consulta do faturamento, aguarde...")

End Sequence

Return Nil


/*/{Protheus.doc} ZFATF010PRC
Função para consulta do Faturamento e envia por email, destinatários no parametro: CMV_FAT002 E CMV_FAT003.
@author Sandro Ferreira 
@since 13/04/2021
@version 1.0
@type function
/*/
Static Function ZFATF018PRC(_lJob)

    Default _lJob       := .F.
	Private cCadastro	:= "Consulta o Faturamento"
	
	//Função para consultar e carregar os dados da consulta.
	CarregaDados3()
	
Return
 
/*/{Protheus.doc} CarDados
Função para carregar as informações da Consulta do Faturamento.
@author FSW - DWC Consult
@since 24/02/2019
@version 1.0
@type function
/*/  
Static Function CarregaDados3()
    Local _cPasta    := SuperGetMV( "CMV_FIS004" ,,"\temp\")  //Local de armazenamento do arquivo
	Local cFaturamento   := GetNextAlias()
	Local cQuery	 := ""
	Local cArquivo	 := _cPasta + 'NOTASENTRADAS.xml'
	Local _cRot      := "ZFISR018" 
   	Local aAnexos    := {}
    Local cHtml      := ""
	Local cObsMail	 := ""
    Local cReplyTo   := ""
	Local nAux       := 0
    Local cMailCC    := ""
    Local lMsgErro 	 := .T.
	Local aColunas   := {}
	Local aDetalhes  := {}
	Local lMsgOK 	 := .F.
	Local cSituacao  := ""  
	Local cPesq1     := "D21"
	Local cPesq2     := "YELLOW"
	Local cPesq3     := "HYUNDAI CAOA DO BRAS"
	Local cPesq4     := "YELLOW"
	Local cPesq5     := "HY21"
	Local cRetPesq1  := 0
	Local cRetPesq2  := 0
	Local cRetPesq3  := 0
	Local cRetPesq4  := 0
	Local cRetPesq5  := 0
	Local dData1     := DtoS(FirstDate(dDataBase)) 
	Local dData2     := DtoS(dDataBase - 1)
	Local oFWMsExcel

    if day(dDatabase) == 01
	   dData1 := DtoS(FirstDate(monthsub(dDataBase,1)))
	endif
	
    //Criar Colunas da Planilha
	aAdd(aColunas, "CNPJ")
	aAdd(aColunas, "INS_EST")
	aAdd(aColunas, "CODIGO")
	aAdd(aColunas, "LOJA")
	aAdd(aColunas, "FORNECEDOR")
	aAdd(aColunas, "ESTADO")
	aAdd(aColunas, "NOTA_FISCAL")
	aAdd(aColunas, "SERIE")
	aAdd(aColunas, "FORMUL")
	aAdd(aColunas, "ESPECIE")
	aAdd(aColunas, "CFOP")
	aAdd(aColunas, "DT_ENTRADA")
	aAdd(aColunas, "DATA LANC / DATA CANC")
	aAdd(aColunas, "VALOR_CONTABIL")
	aAdd(aColunas, "BASE_ICMS")
	aAdd(aColunas, "VAL_ICMS")
	aAdd(aColunas, "ICMS_ISENTO")
	aAdd(aColunas, "CMS_OUTROS")
	aAdd(aColunas, "BASE_SUBST ")
	aAdd(aColunas, " VALOR_SUBST")
	aAdd(aColunas, "BASE_IPI ")
	aAdd(aColunas, "VAL_IPI ")
	aAdd(aColunas, "IPI_ISENTO ")
	aAdd(aColunas, "IPI_OUTROS ")
	aAdd(aColunas, " OUTRAS_DESPESAS")
	aAdd(aColunas, " DESCONTO")
	aAdd(aColunas, "BASE_PIS ")
	aAdd(aColunas, "VALOR_PIS ")
	aAdd(aColunas, "BASE_COF ")
	aAdd(aColunas, "VALOR_COF ")
	aAdd(aColunas, "CHAVE ")
	aAdd(aColunas, "PIS_ST_ZFM ")
	aAdd(aColunas, "VAL_PISSTZFM ")
	aAdd(aColunas, " COF_ST_ZFM")
	aAdd(aColunas, "VAL_COFST_ZFM ")
	aAdd(aColunas, " OBSERVACAO")
	aAdd(aColunas, "USERINC ")
	aAdd(aColunas, "USERALT ")


	If Select(cFaturamento) > 0
		(cFaturamento)->(DbCloseArea())
	EndIf


    cQuery := " "                                                       + CRLF
    cQuery += " WITH NOTA AS ( "                                        + CRLF
    cQuery += "     SELECT "                                            + CRLF
    cQuery += "         SF1.F1_FILIAL    AS FILIAL "                    + CRLF
    cQuery += "         , SA2.A2_CGC   	 AS CNPJ "                      + CRLF
    cQuery += "         , SA2.A2_INSCR 	 AS INS_EST "                   + CRLF
    cQuery += "         , SA2.A2_COD   	 AS CODIGO "                    + CRLF  
    cQuery += "         , SA2.A2_LOJA  	 AS LOJA "                      + CRLF       
    cQuery += "         , SA2.A2_NOME    AS FORNECEDOR "                + CRLF
    cQuery += "         , SA2.A2_EST     AS ESTADO "                    + CRLF
    cQuery += "         , SF1.F1_DOC     AS NOTA_FISCAL "               + CRLF 
    cQuery += "         , SF1.F1_SERIE   AS SERIE "                     + CRLF
    cQuery += "         , SF1.F1_DTDIGIT AS DT_ENTRADA "                + CRLF
    cQuery += "         , SF1.F1_CHVNFE  AS CHAVE "                     + CRLF
    cQuery += "         , SF1.F1_USERLGI AS UINCLUI" 		            + CRLF
    cQuery += "         , SF1.F1_USERLGA AS UALTERA" 		            + CRLF
    cQuery += "         , SD1.D1_CF      AS CFOP "                      + CRLF
    cQuery += "         , SUM(FT_VALPIS) AS VALOR_PIS "                 + CRLF
    cQuery += "         , SUM(FT_VALCOF) AS VALOR_COF "                 + CRLF
    cQuery += " FROM "       + RetSQLName( 'SF1' ) + " SF1 "            + CRLF //-- CAB. NOTA FISCAL DE ENTRADA
    cQuery += " LEFT JOIN "  + RetSQLName( 'SA2' ) + " SA2 "            + CRLF //-- FORNECEDORES
    cQuery += "     ON SA2.A2_FILIAL  = '" + FWxFilial('SA2') + "' "    + CRLF 
    cQuery += "    AND SA2.A2_COD     = SF1.F1_FORNECE"                 + CRLF 
    cQuery += "    AND SA2.A2_LOJA    = SF1.F1_LOJA "                   + CRLF 
    cQuery += "    AND SA2.D_E_L_E_T_ = ' ' "	                        + CRLF
	cQuery += " LEFT JOIN "  + RetSQLName( 'SD1' ) + " SD1 "            + CRLF //-- ITENS DOCUMENTO DE ENTRADA
    cQuery += "     ON SD1.D1_FILIAL  = '" + FWxFilial('SD1') + "' "    + CRLF
    cQuery += "    AND SD1.D1_DOC     = SF1.F1_DOC"                     + CRLF
    cQuery += "    AND SD1.D1_SERIE   = SF1.F1_SERIE"                   + CRLF
    cQuery += "    AND SD1.D1_FORNECE = SF1.F1_FORNECE"                 + CRLF
    cQuery += "    AND SD1.D1_LOJA    = SF1.F1_LOJA"                    + CRLF
    cQuery += "    AND SD1.D1_EMISSAO = SF1.F1_EMISSAO"                 + CRLF
//    cQuery += "    AND SD1.D_E_L_E_T_ = ' ' "	                        + CRLF
    cQuery += " LEFT JOIN "  + RetSQLName( 'SFT' ) + " SFT "            + CRLF //-- ITENS LIVROS FISCAIS
	cQuery += "     ON SFT.FT_FILIAL  = '" + FWxFilial('SFT') + "' "    + CRLF 
    cQuery += "    AND SFT.FT_NFISCAL = SF1.F1_DOC"                     + CRLF
    cQuery += "    AND SFT.FT_SERIE   = SF1.F1_SERIE"                   + CRLF
    cQuery += "    AND SFT.FT_CLIEFOR = SF1.F1_FORNECE"                 + CRLF
    cQuery += "    AND SFT.FT_LOJA	  = SF1.F1_LOJA"                    + CRLF
    cQuery += "    AND SFT.FT_PRODUTO = SD1.D1_COD"                     + CRLF
//    cQuery += "    AND SFT.D_E_L_E_T_ = ' ' "	                        + CRLF
    cQuery += " WHERE  "	                                            + CRLF         
    cQuery += "    SF1.F1_FILIAL 		= '" + FWxFilial('SF1') + "' "  + CRLF
	
    If !Empty(DtoS(MV_PAR02)) //DATA EMISSAO ATE
		cQuery += " AND SF1.F1_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'"   + CRLF //--DATA DE EMISSAO
	EndIf

    If !Empty(MV_PAR04) //NOTA FISCAL
		cQuery += " AND SF1.F1_DOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"                   + CRLF //--NOTA FISCAL
	EndIf
    
    If !Empty(MV_PAR05) // NUM SERIE NF
		cQuery += "	AND SF1.F1_SERIE = '" + MV_PAR05 + "'"                                              + CRLF //--SERIE
	EndIf

    If !Empty(MV_PAR07) //FORNECEDOR
		cQuery += " AND SF1.F1_FORNECE BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"               + CRLF //--FORNECEDOR
	EndIf

 //   cQuery += "    AND SF1.D_E_L_E_T_ 	= ' ' "                         + CRLF
    cQuery += " GROUP BY  "	                                            + CRLF 
    cQuery += "         SF1.F1_FILIAL "                                 + CRLF    
    cQuery += "         , SD1.D1_CF "                                   + CRLF  
    cQuery += "         , SA2.A2_CGC "                                  + CRLF     
	cQuery += "         , SA2.A2_INSCR "                                + CRLF  	   
    cQuery += "         , SA2.A2_COD "                                  + CRLF 
    cQuery += "         , SA2.A2_LOJA "                                 + CRLF
    cQuery += "         , SA2.A2_NOME "                                 + CRLF  
    cQuery += "         , SA2.A2_EST "                                  + CRLF  	   
    cQuery += "         , SF1.F1_DOC "                                  + CRLF 
    cQuery += "         , SF1.F1_SERIE  "                               + CRLF
    cQuery += "         , SF1.F1_DTDIGIT "                              + CRLF 
    cQuery += "         , SF1.F1_CHVNFE "                               + CRLF        
    cQuery += "         , SF1.F1_USERLGI "                              + CRLF
    cQuery += "         , SF1.F1_USERLGA )"                             + CRLF      
    cQuery += " SELECT "                                                + CRLF     
    cQuery += "     FILIAL, CNPJ, INS_EST, CODIGO "                     + CRLF 
    cQuery += "     , LOJA, FORNECEDOR, ESTADO "                        + CRLF 
	cQuery += "  	, NOTA_FISCAL, SERIE, CHAVE, DT_ENTRADA "           + CRLF
    cQuery += "     , CFOP, VALOR_PIS, VALOR_COF "                      + CRLF 
	cQuery += "	    , SF3.F3_ESPECIE    AS ESPECIE "                    + CRLF 
	cQuery += "		, SF3.F3_CFO 		AS CFOP "                       + CRLF 
	cQuery += "		, SF3.F3_ENTRADA    AS DT_LANC "                    + CRLF 
	cQuery += "		, SF3.F3_VALCONT 	AS VALOR_CONTABIL "             + CRLF 
	cQuery += "		, SF3.F3_BASEICM 	AS BASE_ICMS "                  + CRLF 
	cQuery += "		, SF3.F3_VALICM 	AS VAL_ICMS "                   + CRLF 
	cQuery += "		, SF3.F3_ISENICM 	AS ICMS_ISENTO "                + CRLF 
	cQuery += "		, SF3.F3_OUTRICM 	AS ICMS_OUTROS  "               + CRLF 
    cQuery += "		, SF3.F3_BASERET 	AS BASE_SUBST  "                + CRLF 
    cQuery += "		, SF3.F3_ICMSRET 	AS VALOR_SUBST   "              + CRLF 
    cQuery += "		, SF3.F3_BASEIPI 	AS BASE_IPI  "                  + CRLF 
    cQuery += "		, SF3.F3_VALIPI 	AS VAL_IPI  "                   + CRLF 
    cQuery += "		, SF3.F3_ISENIPI 	AS IPI_ISENTO  "                + CRLF 
    cQuery += "		, SF3.F3_OUTRIPI 	AS IPI_OUTROS  "                + CRLF 
    cQuery += "		, SF3.F3_DESPESA 	AS OUTRAS_DESPESAS  "           + CRLF 
    cQuery += "		, SF3.F3_VALOBSE 	AS DESCONTO  "                  + CRLF 
    cQuery += "		, SF3.F3_BASIMP6	AS BASE_PIS  "                  + CRLF 
    cQuery += "		, SF3.F3_BASIMP5	AS BASE_COF  "                  + CRLF 
    cQuery += "		, SF3.F3_BASEPS3 	AS PIS_ST_ZFM  "                + CRLF 
    cQuery += "		, SF3.F3_VALPS3 	AS VAL_PISSTZFM  "              + CRLF     
    cQuery += "		, SF3.F3_BASECF3 	AS COF_ST_ZFM  "                + CRLF 
    cQuery += "		, SF3.F3_VALCF3     AS VAL_COFST_ZFM  "             + CRLF 
    cQuery += "		, SF3.F3_OBSERV 	AS OBSERVACAO  "                + CRLF
    cQuery += "		, SF3.F3_DTCANC "                                   + CRLF
    cQuery += " FROM ABDHDU_PROT.NOTA "                                 + CRLF //-- TEMP NOTA
    cQuery += " LEFT JOIN "  + RetSQLName( 'SF3' ) + " SF3 "            + CRLF //-- LIVROS FISCAIS CABEÇALHO
    cQuery += "     ON SF3.F3_FILIAL  = '" + FWxFilial('SF3') + "' "    + CRLF 
    cQuery += "    AND SF3.F3_NFISCAL = NOTA.NOTA_FISCAL"               + CRLF
    cQuery += "    AND SF3.F3_SERIE   = NOTA.SERIE "                    + CRLF
    cQuery += "    AND SF3.F3_EMISSAO = NOTA.DT_ENTRADA "               + CRLF
    cQuery += "    AND SF3.F3_CFO     = NOTA.CFOP "                     + CRLF
    cQuery += "    AND SF3.D_E_L_E_T_ = ' ' "	                        + CRLF

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cFaturamento,.F.,.T.)

 
	If Select(cFaturamento) > 0
        //Criando o objeto que irá gerar o conteúdo do Excel
	    oFWMsExcel := FWMSExcel():New()

	    //Criando a Aba - Posição de Faturamento
	    oFWMsExcel:AddworkSheet("Notas Fiscais Entradas")
		oFWMsExcel:AddworkSheet("Notas Fiscais Canceladas")
    
 	    //Criando a Tabela
	    oFWMsExcel:AddTable("Notas Fiscais Entradas"        ,"Notas Fiscais Entradas")
        For nAux := 1 To Len(aColunas)
            oFWMsExcel:AddColumn("Notas Fiscais Entradas","Notas Fiscais Entradas", aColunas[nAux], 1, 1)
        Next

 		(cFaturamento)->(DbGoTop())
		While !(cFaturamento)->(EOF())
        
            IF Empty((cAliasTMP)->F3_DTCANC) 
           		   oFWMsExcel:AddRow("Notas Fiscais Entradas","Notas Fiscais Entradas",{;
		             (cFaturamento)->CNPJ  ,;
                     (cFaturamento)->INS_EST  ,;
                     (cFaturamento)->CODIGO  ,;
                     (cFaturamento)->LOJA  ,;
                     (cFaturamento)->FORNECEDOR  ,;
                     (cFaturamento)->ESTADO  ,;
                     (cFaturamento)->NOTA_FISCAL  ,;
                     (cFaturamento)->SERIE  ,;
                     (cFaturamento)->FORMUL  ,;
                     (cFaturamento)->ESPECIE  ,;
                     (cFaturamento)->CFOP  ,;
                     (cFaturamento)->DT_ENTRADA  ,;
                     (cFaturamento)->DT_LANC  ,;
                     (cFaturamento)->VALOR_CONTABIL  ,;
                     (cFaturamento)->BASE_ICMS  ,;
                     (cFaturamento)->VAL_ICMS  ,;					
                     (cFaturamento)->ICMS_ISENTO  ,;
                      (cFaturamento)->CMS_OUTROS  ,;
                     (cFaturamento)->BASE_SUBST  ,;
                     (cFaturamento)->VALOR_SUBST  ,;
                     (cFaturamento)->BASE_IPI  ,;
                     (cFaturamento)->VAL_IPI  ,;
                     (cFaturamento)->IPI_ISENTO  ,;					
                     (cFaturamento)->IPI_OUTROS  ,;
                     (cFaturamento)->OUTRAS_DESPESAS  ,;
                     (cFaturamento)->DESCONTO  ,;
                     (cFaturamento)->BASE_PIS  ,;					
                     (cFaturamento)->VALOR_PIS  ,;
                     (cFaturamento)->BASE_COF  ,;
                     (cFaturamento)->VALOR_COF  ,;
                     (cFaturamento)->CHAVE  ,;					
                     (cFaturamento)->PIS_ST_ZFM  ,;
                     (cFaturamento)->VAL_PISSTZFM  ,;
                     (cFaturamento)->COF_ST_ZFM  ,;
                     (cFaturamento)->VAL_COFST_ZFM  ,;					
                     (cFaturamento)->OBSERVACAO  ,;
                     (cFaturamento)->USERINC  ,;
                     (cFaturamento)->USERALT   })    
			EndIF
			(cFaturamento)->(DbSkip()) 
		EndDo

        oFWMsExcel:AddTable("Notas Fiscais Canceladas" ,"Notas Fiscais Canceladas")
		For nAux := 1 To Len(aColunas)
            oFWMsExcel:AddColumn("Notas Fiscais Canceladas","Notas Fiscais Canceladas", aColunas[nAux], 1, 1)
        Next
 		(cFaturamento)->(DbGoTop())
		While !(cFaturamento)->(EOF())
            IF !Empty((cAliasTMP)->F3_DTCANC) 
            	oFWMsExcel:AddRow("Notas Fiscais Canceladas","Notas Fiscais Canceladas",{;
		             (cFaturamento)->CNPJ  ,;
                     (cFaturamento)->INS_EST  ,;
                     (cFaturamento)->CODIGO  ,;
                     (cFaturamento)->LOJA  ,;
                     (cFaturamento)->FORNECEDOR  ,;
                     (cFaturamento)->ESTADO  ,;
                     (cFaturamento)->NOTA_FISCAL  ,;
                     (cFaturamento)->SERIE  ,;
                     (cFaturamento)->FORMUL  ,;
                     (cFaturamento)->ESPECIE  ,;
                     (cFaturamento)->CFOP  ,;
                     (cFaturamento)->DT_ENTRADA  ,;
                     (cFaturamento)->DT_LANC  ,;
                     (cFaturamento)->VALOR_CONTABIL  ,;
                     (cFaturamento)->BASE_ICMS  ,;
                     (cFaturamento)->VAL_ICMS  ,;					
                     (cFaturamento)->ICMS_ISENTO  ,;
                     (cFaturamento)->CMS_OUTROS  ,;
                     (cFaturamento)->BASE_SUBST  ,;
                     (cFaturamento)->VALOR_SUBST  ,;
                     (cFaturamento)->BASE_IPI  ,;
                     (cFaturamento)->VAL_IPI  ,;
                     (cFaturamento)->IPI_ISENTO  ,;					
                     (cFaturamento)->IPI_OUTROS  ,;
                     (cFaturamento)->OUTRAS_DESPESAS  ,;
                     (cFaturamento)->DESCONTO  ,;
                     (cFaturamento)->BASE_PIS  ,;					
                     (cFaturamento)->VALOR_PIS  ,;
                     (cFaturamento)->BASE_COF  ,;
                     (cFaturamento)->VALOR_COF  ,;
                     (cFaturamento)->CHAVE  ,;					
                     (cFaturamento)->PIS_ST_ZFM  ,;
                     (cFaturamento)->VAL_PISSTZFM  ,;
                     (cFaturamento)->COF_ST_ZFM  ,;
                     (cFaturamento)->VAL_COFST_ZFM  ,;					
                     (cFaturamento)->OBSERVACAO  ,;
                     (cFaturamento)->USERINC  ,;
                     (cFaturamento)->USERALT   })    
			EndIF

			(cFaturamento)->(DbSkip()) 
		EndDo
		  
    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)


	If Select(cFaturamento) > 0
		(cFaturamento)->(DbCloseArea())
	EndIf

Return
