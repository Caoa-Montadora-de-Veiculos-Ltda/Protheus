#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

/*
=====================================================================================
Programa.:              ZFISR007
Autor....:              CAOA - Fagner Ferraz Barreto 
Data.....:              13/09/21
Descricao / Objetivo:   Relatorio de status sefaz para notas de entrada e saida
=====================================================================================
*/
User Function ZFISR007() // u_ZFISR007()

	Local aOpcRadio	:= {	"Relatório Status Sefaz Entradas (Excel)"	,;
							"Relatório Status Sefaz Saidas (Excel)"		}
	Local nRadio	:=	1

	DEFINE MSDIALOG opPar TITLE "Relatório Status SEFAZ" FROM 100,0 TO 300,400 PIXEL of oMainWnd STYLE DS_MODALFRAME

	oRadio1:=tRadMenu():New( 010	,010	,aOpcRadio		,{|u|if(PCount()>0,nRadio:=u,nRadio)}	,opPar	,,,,,,,	,290	,50,,,,.T.	)
	oBotao2:=tButton():New(  070	,030	,"Imprimir"		,opPar	,{|| zSelect(nRadio)   }		,050	,011	,,,,.T.	) // "Imprimir"
	oBotao1:=tButton():New(  070	,120	,"Fechar"		,opPar	,{|| opPar:End()}				,050	,011	,,,,.T.	) // "Fechar"

	ACTIVATE MSDIALOG opPar

Return()

/*
=====================================================================================
Programa.:              zSelect
Autor....:              CAOA - Fagner Ferraz Barreto 
Data.....:              13/09/21
Descricao / Objetivo:   Seleciona o relatorio para impressao
=====================================================================================
*/
Static Function zSelect(nRadio)
	Local cExtens   := "Arquivo XML | *.XML"
	Local cTitulo	:= "Escolha o caminho para salvar o arquivo!"
	Local cMainPath := "\"
	Local cArquivo	:= ""
	Private cPergR1	:= "ZFISR007R1"
	Private cPergR2	:= "ZFISR007R2"

	If nRadio == 1

		If Pergunte( cPergR1	,.T.	)
			cArquivo := cGetFile(cExtens,cTitulo,,cMainPath,.F.)
			If !Empty(cArquivo)
				Processa({|| zRel0001(cArquivo)}	,"Gerando Relatório de Status de NFs de Entrada..."	)
			EndIf
		EndIf

	Else

		If Pergunte( cPergR2	,.T.	)
			cArquivo := cGetFile(cExtens,cTitulo,,cMainPath,.F.)
			If !Empty(cArquivo)
				Processa({|| zRel0002(cArquivo)}	,"Gerando Relatório de Status de NFs de Saída..."	)
			EndIf
		EndIf

	EndIf

Return()

/*
=====================================================================================
Programa.:              zRel0001
Autor....:              CAOA - Fagner Ferraz Barreto 
Data.....:              13/09/21
Descricao / Objetivo:   Gera Excel Notas de Entrada
=====================================================================================
*/
Static Function zRel0001(cArquivo)
	Local cQuery		:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cAba1			:= "Status Notas Fiscais de Entrada"
	Local cTabela1		:= "Status de Notas Fiscais de Entrada"
	Local cAmbiente 	:= ""
	Local cProtocolo	:= ""
	Local cMsgSefaz 	:= ""
	Local cCliFor		:= ""
	Local cCgcCpf		:= ""
	Local oFWMsExcel
	Local oExcel

	If !ApOleClient( "MSExcel" )
		MsgAlert( "Microsoft Excel não instalado!!" )
		Return
	EndIf

	If Select( (cAliasTRB) ) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf

	cQuery += " SELECT  D1_FILIAL, D1_DOC, D1_TES, D1_FORNECE, D1_LOJA, D1_EMISSAO, " 		                   						+ CRLF
	cQuery += "	F1_ESPECIE, F1_DOC, F1_SERIE, F1_TIPO "								                                                + CRLF

	cQuery += " FROM " + RetSQLName('SD1') + " SD1 "																				+ CRLF

	cQuery += " INNER JOIN " + RetSQLName('SF1') + " SF1 "			 																+ CRLF
	cQuery += " 	ON SF1.F1_FILIAL = '" + FWxFilial('SF1') + "' "																	+ CRLF
	cQuery += " 	AND SF1.F1_DOC = SD1.D1_DOC " 																					+ CRLF
	cQuery += " 	AND SF1.F1_SERIE = SD1.D1_SERIE " 																				+ CRLF
	cQuery += " 	AND SF1.F1_FORNECE = SD1.D1_FORNECE " 																			+ CRLF
	cQuery += " 	AND SF1.F1_LOJA = SD1.D1_LOJA " 																				+ CRLF
	cQuery += " 	AND SF1.D_E_L_E_T_ = ' ' " 																						+ CRLF	

	cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1  " 																		+ CRLF
	cQuery += " 	ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "'  "																+ CRLF
	cQuery += "		AND SB1.B1_COD = SD1.D1_COD  "	 																				+ CRLF
	cQuery += "     AND SB1.D_E_L_E_T_ = ' '   " 																					+ CRLF

	cQuery += " INNER JOIN " + RetSQLName("SF4") + " SF4 " 																			+ CRLF
	cQuery += " 	ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "'  "																+ CRLF
	cQuery += "		AND SF4.F4_CODIGO = SD1.D1_TES  "	 																			+ CRLF
	cQuery += "     AND SF4.D_E_L_E_T_ = ' '   " 																					+ CRLF

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

	cQuery += " WHERE SD1.D1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "    											+ CRLF
	cQuery += " 	AND SD1.D1_DOC BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' " 												+ CRLF
	//cQuery += " 	AND SD1.D1_SERIE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " 											+ CRLF
	cQuery += " 	AND SD1.D1_FORNECE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' " 											+ CRLF
	cQuery += " 	AND SD1.D1_EMISSAO BETWEEN '" + DToS( MV_PAR08 ) + "' AND '" + DToS( MV_PAR09 ) + "' " 							+ CRLF
	cQuery += " 	AND SD1.D_E_L_E_T_ = ' ' "	 																					+ CRLF

	If !Empty( MV_PAR03 )
		cQuery += " 	AND SD1.D1_TES = '" + MV_PAR03 + "' " 																		+ CRLF
	EndIf

	cQuery += " GROUP BY 	D1_FILIAL, D1_DOC, D1_TES, D1_FORNECE, D1_LOJA, D1_EMISSAO, " 		                                    + CRLF
	cQuery += "	F1_ESPECIE, F1_DOC, F1_SERIE, F1_TIPO "								                                                + CRLF

	cQuery += " ORDER BY SD1.D1_FILIAL, SD1.D1_EMISSAO, SD1.D1_DOC, SD1.D1_FORNECE, SD1.D1_LOJA "		                            + CRLF

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
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Empresa"						,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tes"							,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cnpj/Cpf"						,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Destinatario"                 ,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nota Fiscal"					,2	,1	,.F.	) // Center - Texto      
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt. de Emissão"				,2	,4	,.F.	) // Center - Data  
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Msgn Sefaz"					,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Protocolo"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Ambiente"						,2	,1	,.F.	) // Center - Texto
		
		// Conta quantos registros existem, e seta no tamanho da régua.
		ProcRegua( nTotReg )

		SA1->( DbSetOrder(1) ) // A1_FILIAL+A1_COD+A1_LOJA
		SA2->( DbSetOrder(1) ) // A2_FILIAL+A2_COD+A2_LOJA

		DbSelectArea((cAliasTRB))
		(cAliasTRB)->(dbGoTop())
		While (cAliasTRB)->(!EoF())

			// Incrementa a mensagem na régua.
			IncProc("Exportando informações para Excel...")

			// Busca informações da Nota Fiscal no servidor TSS.
			cAmbiente 	:= ""
			cProtocolo	:= ""
			cMsgSefaz 	:= ""
			aInfNfe		:= {}

			If AllTrim( (cAliasTRB)->F1_ESPECIE ) $ "SPED"
				aInfNfe 	:= U_zFATF001( (cAliasTRB)->F1_SERIE	,(cAliasTRB)->F1_DOC )
				cAmbiente 	:= AllTrim( aInfNfe[1,3] )
				cProtocolo 	:= AllTrim( aInfNfe[1,6] )
				cMsgSefaz 	:= AllTrim( aInfNfe[1,5] )
			EndIf

			cCliFor 	:= ""
			cCgcCpf		:= ""
			If (cAliasTRB)->F1_TIPO $ "B|D" // Benefeciamento ou devolução
				If SA1->(DbSeek( xFilial("SA1") + (cAliasTRB)->D1_FORNECE + (cAliasTRB)->D1_LOJA ))
					cCliFor		:= SA1->A1_NOME
					cCgcCpf 	:= IIF( Len( Alltrim( SA1->A1_CGC) )>11 ,Transform( SA1->A1_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA1->A1_CGC ,"@R 999.999.999-99" ) ) 
				Else
					cCliFor		:= "CLIENTE NÃO ENCONTRADO NA BASE DE DADOS"
					cCgcCpf 	:= ""
				EndIf

			Else
				If SA2->(DbSeek( xFilial("SA2") + (cAliasTRB)->D1_FORNECE + (cAliasTRB)->D1_LOJA ))
					cCliFor		:= SA2->A2_NOME
					cCgcCpf 	:= IIF( Len( Alltrim( SA2->A2_CGC) )>11 ,Transform( SA2->A2_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA2->A2_CGC ,"@R 999.999.999-99" ) ) 
				Else
					cCliFor		:= "FORNECEDOR NÃO ENCONTRADO NA BASE DE DADOS"
					cCgcCpf		:= ""
				EndIf
			EndIf

			oFWMSExcel:AddRow( cAba1	,cTabela1	,{ 	AllTrim( (cAliasTRB)->D1_FILIAL ),;    //--Empresa
                                                        (cAliasTRB)->D1_TES,;    //--Tes
                                                        cCgcCpf,;    //--Cnpj/Cpf 
														cCliFor,;    //--Destinatario														
														(cAliasTRB)->D1_DOC,;    //--Nota Fiscal
														IIF( Empty( SToD( (cAliasTRB)->D1_EMISSAO ) ), "", SToD( (cAliasTRB)->D1_EMISSAO ) ),;    //--Dt. de Emissão
														cMsgSefaz,;    //--Msgn Sefaz	
														cProtocolo,;    //--Protocolo
														cAmbiente })	//--Ambiente													     														 
			(cAliasTRB)->(DbSkip())
		EndDo

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
	DbSelectArea("SA2")

Return()

/*
=====================================================================================
Programa.:              zRel0002
Autor....:              CAOA - Fagner Ferraz Barreto 
Data.....:              13/09/21
Descricao / Objetivo:   Gera Excel Notas de Saida
=====================================================================================
*/
Static Function zRel0002(cArquivo)

	Local cQuery		:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cAba1			:= "Status Notas Fiscais de Saída"
	Local cTabela1		:= "Status de Notas Fiscais de Saída"
	Local cAmbiente		:= ""
	Local cProtocolo	:= ""
	Local cMsgSefaz		:= ""
	Local cCliFor		:= ""
	Local cCgcCpf		:= ""
	Local aInfNfe		:= {}
	Local oFWMsExcel
	Local oExcel
	Local nTotReg		:= ""	

	If !ApOleClient("MSExcel")
		MsgAlert("Microsoft Excel não instalado!")
		Return
	EndIf

	If Select( (cAliasTRB) ) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf

	cQuery += " SELECT D2_FILIAL, D2_DOC, D2_TES,D2_CLIENTE,D2_LOJA,D2_EMISSAO, "										+ CRLF
	cQuery += " F2_ESPECIE, F2_DOC, F2_SERIE, F2_TIPO"	+ CRLF
	cQuery += " FROM   " + RetSQLName("SD2") + " SD2 " 																	+ CRLF
	
	cQuery += "	INNER JOIN " + RetSQLName("SF2") + " SF2 "																+ CRLF
	cQuery += "		ON SF2.F2_FILIAL = '" + FWxFilial('SF2') + "' "														+ CRLF
	cQuery += "		AND SD2.D2_DOC = SF2.F2_DOC   " 																	+ CRLF
	cQuery += "		AND SD2.D2_SERIE = SF2.F2_SERIE   " 																+ CRLF
	cQuery += "		AND SD2.D2_CLIENTE = SF2.F2_CLIENTE   " 															+ CRLF
	cQuery += "		AND SD2.D2_LOJA = SF2.F2_LOJA   " 																	+ CRLF
	cQuery += "		AND SD2.D2_EMISSAO = SF2.F2_EMISSAO   " 															+ CRLF
	//cQuery += "		AND SF2.F2_ESPECIE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " 								+ CRLF
	cQuery += "		AND SF2.D_E_L_E_T_ = ' '   "	 																	+ CRLF
	
	cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 " 												 				+ CRLF
	cQuery += "		ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "														+ CRLF
	cQuery += "		AND SB1.B1_COD = SD2.D2_COD   "	 																	+ CRLF
	cQuery += "		AND SB1.D_E_L_E_T_ = ' ' " 																			+ CRLF

	cQuery += " INNER JOIN " + RetSQLName("SF4") + " SF4 "																+ CRLF
	cQuery += "		ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "'  "													+ CRLF
	cQuery += "		AND SF4.F4_CODIGO = SD2.D2_TES  "	 																+ CRLF
	cQuery += "     AND SF4.D_E_L_E_T_ = ' '   " 																		+ CRLF
	
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
	cQuery += " 	AND SD2.D2_DOC BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' " 									+ CRLF
	//cQuery += " 	AND SD2.D2_SERIE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' " 								+ CRLF
	cQuery += " 	AND SD2.D2_CLIENTE BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' " 								+ CRLF
	cQuery += " 	AND SD2.D2_EMISSAO BETWEEN '" + DToS( MV_PAR08 ) + "' AND '" + DToS( MV_PAR09 ) + "' " 				+ CRLF
	//cQuery += " 	AND SD2.D2_COD BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' " 									+ CRLF
	cQuery += " 	AND SD2.D_E_L_E_T_ = ' ' " 																			+ CRLF

	If !Empty( MV_PAR03 )
		cQuery += " 	AND SD2.D2_TES = '" + MV_PAR03 + "' " 															+ CRLF
	EndIf  

	cQuery += " GROUP BY D2_FILIAL, D2_DOC, D2_TES,D2_CLIENTE,D2_LOJA,D2_EMISSAO, "		+ CRLF
	cQuery += " F2_ESPECIE, F2_DOC, F2_SERIE, F2_TIPO"	+ CRLF

	cQuery += " ORDER BY SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_CLIENTE, SD2.D2_LOJA "       + CRLF

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
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Empresa"						,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Tes"							,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cnpj/Cpf"						,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Destinatario"                 ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nota Fiscal"					,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt. de Emissão"				,2	,4	,.F.	) // Center - Data
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Msgn Sefaz"					,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Protocolo"					,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Ambiente"						,2	,1	,.F.	) // Center - Texto     

		// Conta quantos registros existem, e seta no tamanho da régua.
		ProcRegua( nTotReg )

		SA1->( DbSetOrder(1) ) // A1_FILIAL+A1_COD+A1_LOJA
		SA2->( DbSetOrder(1) ) // A2_FILIAL+A2_COD+A2_LOJA

		DbSelectArea((cAliasTRB))
		(cAliasTRB)->(dbGoTop())
		While (cAliasTRB)->(!EoF())

			// Incrementa a mensagem na régua.
			IncProc( "Exportando informações para Excel..." )

			// Busca informações da Nota Fiscal no servidor TSS.
			cAmbiente 	:= ""
			cProtocolo	:= ""
			cMsgSefaz 	:= ""
			aInfNfe		:= {}
			
			If AllTrim( (cAliasTRB)->F2_ESPECIE ) $ "SPED|CTE|RPS|NFS"
				aInfNfe 	:= U_zFATF001( (cAliasTRB)->F2_SERIE	,(cAliasTRB)->F2_DOC	)
				cAmbiente 	:= AllTrim( aInfNfe[1,3] )
				cProtocolo 	:= AllTrim( aInfNfe[1,6] )
				cMsgSefaz 	:= AllTrim( aInfNfe[1,5] )
			EndIf

			cCliFor 	:= ""
			cCgcCpf		:= ""
			If (cAliasTRB)->F2_TIPO $ "B|D" // Benefeciamento ou devolução
				If SA2->(DbSeek( xFilial("SA2") + (cAliasTRB)->D2_CLIENTE + (cAliasTRB)->D2_LOJA ))
					cCliFor		:= SA2->A2_NOME
					cCgcCpf 	:= IIF( Len( Alltrim( SA2->A2_CGC) )>11 ,Transform( SA2->A2_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA2->A2_CGC ,"@R 999.999.999-99" ) ) 
				Else
					cCliFor		:= "FORNECEDOR NÃO ENCONTRADO NA BASE DE DADOS"
					cCgcCpf 	:= ""
				EndIf
			Else
				If SA1->(DbSeek( xFilial("SA1") + (cAliasTRB)->D2_CLIENTE + (cAliasTRB)->D2_LOJA ))
					cCliFor		:= SA1->A1_NOME
					cCgcCpf 	:= IIF( Len( Alltrim( SA1->A1_CGC) )>11 ,Transform( SA1->A1_CGC ,"@R 99.999.999/9999-99" ) ,Transform( SA1->A1_CGC ,"@R 999.999.999-99" ) )
				Else
					cCliFor		:= "CLIENTE NÃO ENCONTRADO NA BASE DE DADOS"
					cCgcCpf		:= ""
				EndIf
			EndIf

			oFWMSExcel:AddRow( cAba1	, cTabela1	, { AllTrim( (cAliasTRB)->D2_FILIAL ),;    //--Empresa
                                                        (cAliasTRB)->D2_TES,;    //--Tes
                                                        cCgcCpf,;    //--Cnpj/Cpf
                                                        cCliFor,;    //--Destinatario
                                                        (cAliasTRB)->D2_DOC,;    //--Nota Fiscal
                                                        IIF( Empty( SToD( (cAliasTRB)->D2_EMISSAO ) ), "", SToD( (cAliasTRB)->D2_EMISSAO ) ),;    //--Dt. de Emissão
                                                        cMsgSefaz,;    //--Msgn Sefaz
                                                        cProtocolo,;    //--Protocolo
														cAmbiente })	//--Ambiente   												    
			(cAliasTRB)->(DbSkip())
		EndDo
		
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
	DbSelectArea("SA1")

Return()
