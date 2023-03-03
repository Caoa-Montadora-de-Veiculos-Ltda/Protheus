#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

/*
===========================================================================================
Programa.:  ZEICR002              
Autor....:  CAOA - Fagner Barreto
Data.....:  07/04/2022
Descricao / Objetivo: Relatório de Pedidos para Fornecedor
Solicitante: Takahashi-TOTVS     
===========================================================================================
*/
User Function ZEICR002() // u_ZEICR002()

	Processa({|| ImpEICR002()}	,"Gerando Relatório de Pedidos para Fornecedor..."	)

Return

/*
======================================================================
Programa.:  ImpEICR002
Autor....:  CAOA - Fagner Barreto
Data.....:  07/04/2022
Descricao / Objetivo: Processamento e impressão do relatório em excel      
======================================================================
*/
Static Function ImpEICR002()
	Local cQuery		:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cAba			:= "Pedidos para Fornecedor"
	Local cTabela		:= " "
	//Local cTabela		:= "Relação de Pedidos para Fornecedor"
	Local oFWMsExcel    := Nil
	Local oExcel        := Nil
	Local nTotReg		:= 0
    Local cDescProd     := ""
	Local cArquivo		:= GetTempPath()+'PedidoFornecedor'+SUBSTRING(dtoc(date()),1,2)+SUBSTRING(dtoc(date()),4,2)+SUBSTRING(dtoc(date()),9,2)+'_'+SUBSTRING(time(),1,2) +SUBSTRING(time(),4,2) +SUBSTRING(time(),7,2)+'.xml'

	SB1->( DbSetOrder(1) )

	If !ApOleClient( "MSExcel" )
		MsgAlert( "Microsoft Excel não instalado!!" )
		Return
	EndIf

	If Select( (cAliasTRB) ) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf

    cQuery := " SELECT W3_PART_N, W3_COD_I, SUM( W3_QTDE ) AS QTD "	        + CRLF
    cQuery += " FROM " + RetSQLName( 'SW3' ) + " SW3 "              + CRLF
    cQuery += " WHERE SW3.W3_FILIAL = '" + FWxFilial('SW3') + "' "  + CRLF
	cQuery += "		AND W3_PO_NUM = '" + SW2->W2_PO_NUM + "' "  + CRLF
	cQuery += "     AND W3_SEQ = '0' "  + CRLF //--Definido por Takahashi-TOTVS
    cQuery += "     AND D_E_L_E_T_ = ' ' "  + CRLF
    cQuery += " GROUP BY W3_PART_N, W3_COD_I  "  + CRLF

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
		oFWMsExcel:AddworkSheet(cAba) // Não utilizar número junto com sinal de menos. Ex.: 1-.

		// Criando a Tabela.
		oFWMsExcel:AddTable( cAba	,cTabela	)

		// Criando Colunas.
		oFWMsExcel:AddColumn( cAba	,cTabela	,"Part Number"		            ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba	,cTabela	,"Quantidade"			        ,3	,2	,.F.	) // Right - Number
		oFWMsExcel:AddColumn( cAba	,cTabela	,"Descrição"				    ,2	,1	,.F.	) // Center - Texto
		
		// Conta quantos registros existem, e seta no tamanho da régua.
		ProcRegua( nTotReg )

		DbSelectArea((cAliasTRB))
		(cAliasTRB)->(dbGoTop())
		While (cAliasTRB)->(!EoF())

			// Incrementa a mensagem na régua.
			IncProc("Exportando informações para Excel...")

			cDescProd := ""
            If SB1->( MsSeek( FWxFilial("SB1") + (cAliasTRB)->W3_COD_I ) )
                cDescProd := AllTrim(MSMM(SB1->B1_DESC_P))
            EndIf

			oFWMSExcel:AddRow( cAba	,cTabela	,{  (cAliasTRB)->W3_PART_N,;    //--Part Number
														(cAliasTRB)->QTD ,;  //--Quantidade
													    cDescProd})   //--Descrição													     														 
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
		ApMsgAlert( "Nenhum registro encontrado para impressão do relatorio!!" )
	EndIf
	
	(cAliasTRB)->(DbCloseArea())


Return
