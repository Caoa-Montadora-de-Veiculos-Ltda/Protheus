#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"
/*
=====================================================================================
Programa.:              ZEICR001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              08/12/21
Descricao / Objetivo:   Relatorio de Picking
Doc. Origem:            
Solicitante:            Logistica
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZEICR001()

	If ( AllTrim(FwCodEmp()) == "2010" .And. AllTrim(FwFilial()) == "2001" ) //Empresa Anapolis
		Processa({|| zMontadora()}	,"Gerando Relatório..."	)
	Else
		Processa({|| zCaoaSp()}	,"Gerando Relatório..."	)
	EndIf

Return()

/*
=====================================================================================
Programa.:              zRel0001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              08/12/21
Descricao / Objetivo:   Gera relatorio
Doc. Origem:            
Solicitante:            Logistica
Uso......:              ZEICR001
Obs......:
=====================================================================================
*/
Static Function zMontadora()

	Local aArea		  	:= GetArea()
	Local cQuery	  	:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cArquivo	  	:= GetTempPath()+'Packing'+SUBSTRING(dtoc(date()),1,2)+SUBSTRING(dtoc(date()),4,2)+SUBSTRING(dtoc(date()),9,2)+'_'+SUBSTRING(time(),1,2) +SUBSTRING(time(),4,2) +SUBSTRING(time(),7,2)+'.xml'
	Local oFWMsExcel
	Local oExcel
	Local aParamBox 	:= {}
	Local aRet 			:= {}
	Local nTotReg		:= 0

	aAdd(aParamBox,{1 ,"Invoice De:" 	,Space(TamSX3("ZM_INVOICE")[1])	,"@!","","SW9_1","",80	,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Invoice Ate:" 	,Space(TamSX3("ZM_INVOICE")[1])	,"@!","","SW9_1","",80	,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Lote:" 			,Space(TamSX3("ZM_LOTE")[1])	,"@!","","","",80		,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"BL:" 			,Space(TamSX3("ZM_BL")[1])		,"@!","","","",80		,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Produto:" 		,Space(TamSX3("ZM_PROD")[1])	,"@!","","","",80		,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Processo:" 		,Space(TamSX3("W9_HAWB")[1])	,"@!","","","",80		,.F.}) // Tipo caractere


	If ParamBox(aParamBox,"Parametros para geração do Arquivo...",@aRet)

		//Criando o objeto que irá gerar o conteúdo do Excel
		oFWMsExcel := FWMSExcel():New()

		//Aba - Gympass
		oFWMsExcel:AddworkSheet("Packing List")

		//Criando a Tabela
		oFWMsExcel:AddTable("Packing List","Packing")
		oFWMsExcel:AddColumn("Packing List","Packing","INVOICE"              	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","NAVIO"                	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","BL"                   	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","CONTAINER"            	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","LOTE"                 	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","CASE"                 	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","PRODUTO"              	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","DESCRIÇÃO DO PRODUTO" 	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","QUANTIDADE"           	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","UNITIZADOR" 	        	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","DATA DE EMISSAO"      	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","PROCESSO"      		    ,1)
		oFWMsExcel:AddColumn("Packing List","Packing","ARMAZEM_ATUAL"   	    ,1)
		oFWMsExcel:AddColumn("Packing List","Packing","ENDERECO_ATUAL"  	    ,1)
		oFWMsExcel:AddColumn("Packing List","Packing","QTD_END_ATUAL"      		,1)
		oFWMsExcel:AddColumn("Packing List","Packing","ENDERECO_D12"      		,1)
		oFWMsExcel:AddColumn("Packing List","Packing","DATA_ENDER"      	    ,1)

		If Select( (cAliasTRB) ) > 0
			(cAliasTRB)->(DbCloseArea())
		EndIf

		cQuery := "	"
		cQuery += " SELECT RTRIM(SZM.ZM_INVOICE) 											AS INVOICE, "
		cQuery += " 		RTRIM(SZM.ZM_NAVIO)  											AS NAVIO, "
		cQuery += " 		RTRIM(SZM.ZM_BL)     											AS BL, "
		cQuery += " 		RTRIM(SZM.ZM_CONT)   											AS CONTAINER, "
		cQuery += " 		RTRIM(SZM.ZM_LOTE)   											AS LOTE, "
		cQuery += " 		RTRIM(SZM.ZM_CASE)   											AS XCASE, "
		cQuery += " 		RTRIM(SZM.ZM_PROD)   											AS PRODUTO, "
		cQuery += " 		SB1.B1_DESC      	 											AS DESCRICAO, "
		cQuery += " 		SZM.ZM_QTDE      	 											AS QUANTIDADE, "
		cQuery += " 		RTRIM(SZM.ZM_UNIT)   											AS UNITIZADOR, "
		cQuery += " 		TO_CHAR(TO_DATE(SW9.W9_DT_EMIS, 'YYYY/MM/DD'), 'DD/MM/YYYY')	AS EMISSAO, "
		cQuery += " 		RTRIM(SW9.W9_HAWB) 	 											AS PROCESSO, "
		cQuery += " 		NVL(RTRIM(D14.D14_LOCAL), ' ')									AS ARMAZEM_ATUAL, "
		cQuery += " 		NVL(RTRIM(D14.D14_ENDER), ' ')									AS ENDERECO_ATUAL, "
		cQuery += " 		NVL(D14.D14_QTDEST, 0) 											AS QTD_END_ATUAL, "
		cQuery += " 		NVL(RTRIM(D12.D12_ENDDES), ' ') 								AS ENDERECO_D12, "
		cQuery += " 		D12.D12_DTGERA													AS DATA_ENDER "
		cQuery += " FROM " +  RetSQLName("SZM") +" SZM "
		cQuery += " 	LEFT JOIN " +  RetSQLName("SW9") +" SW9 "
		cQuery += " 	ON SW9.W9_FILIAL = SZM.ZM_FILIAL "
		cQuery += " 	AND SW9.W9_INVOICE = SZM.ZM_INVOICE "
		cQuery += " 	AND SW9.D_E_L_E_T_ = ' ' "
		cQuery += " INNER JOIN " +  RetSQLName("SB1") +" SB1 "
		cQuery += " 	ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "
		cQuery += " 	AND SB1.B1_COD =  SZM.ZM_PROD "
		cQuery += " 	AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " LEFT JOIN " +  RetSQLName("D14") +" D14 "
		cQuery += " 	ON D14.D14_FILIAL = '" + FWxFilial('D14') + "' "
		cQuery += " 	AND D14.D14_IDUNIT =  SZM.ZM_UNIT "
		cQuery += " 	AND D14.D14_PRODUT =  SZM.ZM_PROD "
		cQuery += " 	AND D14.D_E_L_E_T_ = ' ' "
		cQuery += " LEFT JOIN " +  RetSQLName("D12") +" D12 "
		cQuery += " 	ON D12.D12_FILIAL = '" + FWxFilial('D12') + "' "
		cQuery += " 	AND D12.D12_IDUNIT =  SZM.ZM_UNIT "
		cQuery += " 	AND D12.D12_SERVIC = '101' "
		cQuery += " 	AND D12.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE SZM.ZM_FILIAL = '" + FWxFilial('SZM') + "' "
		cQuery += " AND SZM.ZM_INVOICE BETWEEN '" + aRet[1] + "' AND '" + aRet[2] + "' "
		If !Empty(aRet[3])
			cQuery += " AND SZM.ZM_LOTE = '" + aRet[3] + " ' "
		EndIf
		If !Empty(aRet[4])
			cQuery += " AND SZM.ZM_BL = '" + aRet[4] + " ' "
		EndIf
		If !Empty(aRet[5])
			cQuery += " AND SZM.ZM_PROD = '" + aRet[5] + " ' "
		EndIf
		If !Empty(aRet[6])
			cQuery += " AND SW9.W9_HAWB = '" + aRet[6] + " ' "
		EndIf
		cQuery += " AND SZM.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)

		// Executa a consulta.
		DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

		DbSelectArea((cAliasTRB))
		nTotReg := Contar(cAliasTRB,"!Eof()")
		(cAliasTRB)->(dbGoTop())

		While !(cAliasTRB)->(EoF())

			// Incrementa a mensagem na régua.
			IncProc("Exportando informações para Excel...")

			oFWMsExcel:AddRow(	"Packing List","Packing",{;
				(cAliasTRB)->INVOICE,;
				(cAliasTRB)->NAVIO,;
				(cAliasTRB)->BL,;
				(cAliasTRB)->CONTAINER,;
				(cAliasTRB)->LOTE,;
				(cAliasTRB)->XCASE,;
				(cAliasTRB)->PRODUTO,;
				(cAliasTRB)->DESCRICAO,;
				(cAliasTRB)->QUANTIDADE,;
				(cAliasTRB)->UNITIZADOR,;
				(cAliasTRB)->EMISSAO,;
				(cAliasTRB)->PROCESSO,;
				(cAliasTRB)->ARMAZEM_ATUAL,;
				(cAliasTRB)->ENDERECO_ATUAL,;
				(cAliasTRB)->QTD_END_ATUAL,;
				(cAliasTRB)->ENDERECO_D12,;
				SToD((cAliasTRB)->DATA_ENDER)	})

			(cAliasTRB)->(DbSkip())
		EndDo

		//Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)

		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New() 			    //Abre uma nova conexão com Excel
		oExcel:WorkBooks:Open(cArquivo) 	    //Abre uma planilha
		oExcel:SetVisible(.T.) 				    //Visualiza a planilha
		oExcel:Destroy()						//Encerra o processo do gerenciador de tarefas

		(cAliasTRB)->(DbCloseArea())

	EndIf

	RestArea(aArea)

Return()

/*
=====================================================================================
Programa.:              zRel0001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              08/12/21
Descricao / Objetivo:   Gera relatorio
Doc. Origem:            
Solicitante:            Logistica
Uso......:              ZEICR001
Obs......:
=====================================================================================
*/
Static Function zCaoaSp()

	Local aArea		  	:= GetArea()
	Local cQuery	  	:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cArquivo	  	:= GetTempPath()+'Packing'+SUBSTRING(dtoc(date()),1,2)+SUBSTRING(dtoc(date()),4,2)+SUBSTRING(dtoc(date()),9,2)+'_'+SUBSTRING(time(),1,2) +SUBSTRING(time(),4,2) +SUBSTRING(time(),7,2)+'.xml'
	Local oFWMsExcel
	Local oExcel
	Local aParamBox 	:= {}
	Local aRet 			:= {}
	Local nTotReg		:= 0

	aAdd(aParamBox,{1 ,"Invoice De:" 	,Space(TamSX3("ZM_INVOICE")[1])	,"@!","","SW9_1","",80	,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Invoice Ate:" 	,Space(TamSX3("ZM_INVOICE")[1])	,"@!","","SW9_1","",80	,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Lote:" 			,Space(TamSX3("ZM_LOTE")[1])	,"@!","","","",80		,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"BL:" 			,Space(TamSX3("ZM_BL")[1])		,"@!","","","",80		,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Produto:" 		,Space(TamSX3("ZM_PROD")[1])	,"@!","","","",80		,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Processo:" 		,Space(TamSX3("W9_HAWB")[1])	,"@!","","","",80		,.F.}) // Tipo caractere


	If ParamBox(aParamBox,"Parametros para geração do Arquivo...",@aRet)

		//Criando o objeto que irá gerar o conteúdo do Excel
		oFWMsExcel := FWMSExcel():New()

		//Aba - Gympass
		oFWMsExcel:AddworkSheet("Packing List")
	
		//Criando a Tabela
		oFWMsExcel:AddTable("Packing List","Packing")
		oFWMsExcel:AddColumn("Packing List","Packing","INVOICE"              	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","NAVIO"                	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","BL"                   	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","CONTAINER"            	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","LOTE"                 	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","CASE"                 	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","PRODUTO"              	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","DESCRIÇÃO DO PRODUTO" 	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","QUANTIDADE"           	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","UNITIZADOR" 		,1)
		oFWMsExcel:AddColumn("Packing List","Packing","DATA DE EMISSAO"      	,1)
		oFWMsExcel:AddColumn("Packing List","Packing","PROCESSO"      		,1)
		oFWMsExcel:AddColumn("Packing List","Packing","DATA_ENDER"      	,1)
		
		If Select( (cAliasTRB) ) > 0
			(cAliasTRB)->(DbCloseArea())
		EndIf

		cQuery := "	"
		cQuery += " SELECT SZM.ZM_INVOICE		AS INVOICE, "
		cQuery += " 		SZM.ZM_NAVIO     	AS NAVIO, "
		cQuery += " 		SZM.ZM_BL        	AS BL, "   
		cQuery += " 		SZM.ZM_CONT      	AS CONTAINER, "
		cQuery += " 		SZM.ZM_LOTE      	AS LOTE, "
		cQuery += " 		SZM.ZM_CASE      	AS XCASE, "
		cQuery += " 		SZM.ZM_PROD      	AS PRODUTO, "
		cQuery += " 		SB1.B1_DESC      	AS DESCRICAO, "
		cQuery += " 		SZM.ZM_QTDE      	AS QUANTIDADE, "
		cQuery += " 		SZM.ZM_UNIT      	AS UNITIZADOR, "
		cQuery += " 		SW9.W9_DT_EMIS   	AS EMISSAO, "
		cQuery += " 		SW9.W9_HAWB 	   	AS PROCESSO, "
		cQuery += " 		(SELECT DCF.DCF_DATA "
		cQuery += "			FROM " +  RetSQLName("DCF") +" DCF "
		cQuery += "			WHERE DCF.DCF_UNITIZ = SZM.ZM_UNIT " 
		cQuery += "				AND DCF.D_E_L_E_T_= ' ' "
		cQuery += "				AND DCF.DCF_FILIAL = SZM.ZM_FILIAL " 
		cQuery += "				AND DCF.DCF_CLIFOR = SZM.ZM_FORNEC "
		cQuery += "				AND DCF.DCF_LOCAL = '907') AS DATA_ENDER "
		cQuery += " FROM " +  RetSQLName("SZM") +" SZM "
		cQuery += " 	LEFT JOIN " +  RetSQLName("SW9") +" SW9 "
		cQuery += " 	ON SW9.W9_FILIAL = SZM.ZM_FILIAL "
		cQuery += " 	AND SW9.W9_INVOICE = SZM.ZM_INVOICE "
		cQuery += " 	AND SW9.D_E_L_E_T_ = ' ' "
		cQuery += " INNER JOIN " +  RetSQLName("SB1") +" SB1 "
		cQuery += " 	ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "
		cQuery += " 	AND SB1.B1_COD =  SZM.ZM_PROD "
		cQuery += " 	AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE SZM.ZM_FILIAL = '" + FWxFilial('SZM') + "' "
		cQuery += " AND SZM.ZM_INVOICE BETWEEN '" + aRet[1] + "' AND '" + aRet[2] + "' "
		If !Empty(aRet[3])
			cQuery += " AND SZM.ZM_LOTE = '" + aRet[3] + " ' "
		EndIf
		If !Empty(aRet[4])
			cQuery += " AND SZM.ZM_BL = '" + aRet[4] + " ' "
		EndIf
		If !Empty(aRet[5])
			cQuery += " AND SZM.ZM_PROD = '" + aRet[5] + " ' "
		EndIf
		If !Empty(aRet[6])
			cQuery += " AND SW9.W9_HAWB = '" + aRet[6] + " ' "
		EndIf
		cQuery += " AND SZM.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)

		// Executa a consulta.
		DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

		DbSelectArea((cAliasTRB))
		nTotReg := Contar(cAliasTRB,"!Eof()")
		(cAliasTRB)->(dbGoTop())
   
		While !(cAliasTRB)->(EoF())

			// Incrementa a mensagem na régua.
			IncProc("Exportando informações para Excel...")

			oFWMsExcel:AddRow(	"Packing List","Packing",{;
								(cAliasTRB)->INVOICE,;
								(cAliasTRB)->NAVIO,;
								(cAliasTRB)->BL,;
								(cAliasTRB)->CONTAINER,;
								(cAliasTRB)->LOTE,;
								(cAliasTRB)->XCASE,;
								(cAliasTRB)->PRODUTO,;
								(cAliasTRB)->DESCRICAO,;
								(cAliasTRB)->QUANTIDADE,;
								(cAliasTRB)->UNITIZADOR,;
								(cAliasTRB)->EMISSAO,;
								(cAliasTRB)->PROCESSO,;
								SToD((cAliasTRB)->DATA_ENDER)	})
		
			(cAliasTRB)->(DbSkip()) 
		EndDo
	
		//Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)
		
		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New() 			    //Abre uma nova conexão com Excel
		oExcel:WorkBooks:Open(cArquivo) 	    //Abre uma planilha
		oExcel:SetVisible(.T.) 				    //Visualiza a planilha
		oExcel:Destroy()						//Encerra o processo do gerenciador de tarefas
	
		(cAliasTRB)->(DbCloseArea())
		
	EndIf

RestArea(aArea)

Return()

