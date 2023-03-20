#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"
/*
=====================================================================================
Programa.:              ZPECR022
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              08/12/21
Descricao / Objetivo:   Relatorio Invoice x itens
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZPECR022()

	Local aArea		  	:= GetArea()
	Local cQuery	  	:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cArquivo	  	:= GetTempPath()+'Invoice_itens_'+SUBSTRING(dtoc(date()),1,2)+SUBSTRING(dtoc(date()),4,2)+SUBSTRING(dtoc(date()),9,2)+'_'+SUBSTRING(time(),1,2) +SUBSTRING(time(),4,2) +SUBSTRING(time(),7,2)+'.xml'
	Local oFWMsExcel
	Local oExcel
	Local aParamBox 	:= {}
	Local aRet 			:= {}
	Local nTotReg		:= 0

	aAdd(aParamBox,{1 ,"Data De:" 		,Space(TamSX3("D1_DTDIGIT")[1])	,"@!","","SD1",""	,80	,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Data Ate:" 		,Space(TamSX3("D1_DTDIGIT")[1])	,"@!","","SD1",""	,80	,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Produto:" 		,Space(TamSX3("B1_COD")[1])		,"@!","","",""		,80	,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Nota Fiscal:"	,Space(TamSX3("D1_DOC")[1])		,"@!","","",""		,80	,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Serie:"			,Space(TamSX3("D1_SERIE")[1])	,"@!","","",""		,80	,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Invoice:"		,Space(TamSX3("W9_INVOICE")[1])	,"@!","","",""		,80	,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Caixa:"			,Space(TamSX3("ZD1_XCASE")[1])	,"@!","","",""		,80	,.F.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"Container:"		,Space(TamSX3("D1_XCONT")[1])	,"@!","","",""		,80	,.F.}) // Tipo caractere

	If ParamBox(aParamBox,"Parametros para geração do Arquivo...",@aRet)

		//Criando o objeto que irá gerar o conteúdo do Excel
		oFWMsExcel := FWMSExcel():New()

		//Aba - Gympass
		oFWMsExcel:AddworkSheet("Relatorio")
	
		//Criando a Tabela

		oFWMsExcel:AddTable("Relatorio","Planilha01")
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Produto"              		,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Qtde NFiscal"                ,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Qtde Pendente"               ,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Nota Fiscal"                	,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Serie"                		,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Emissao NFiscal"             ,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Digitacao NFiscal"           ,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Invoice"                		,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Data Invoice"                ,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Caixa"                		,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Container"                	,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Armaz Rec"                	,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Saldo Armaz Rec"             ,1)
		
		If Select( (cAliasTRB) ) > 0
			(cAliasTRB)->(DbCloseArea())
		EndIf

		cQuery := "	"
		cQuery += " SELECT DISTINCT REPLACE(ZD1.ZD1_COD,' ','') AS COD "
		cQuery += " 				, ZD1.ZD1_QUANT QTD "
		cQuery += " 				, ZD1_SLDIT QTD_PEND "
		cQuery += " 				, ZD1.ZD1_DOC NF "
		cQuery += " 				, ZD1.ZD1_SERIE SERIE "
		cQuery += "     			, TO_DATE(W9.W9_DT_EMIS, 'YYYYMMDD' ) AS DT_INV "
		cQuery += "     			, TO_DATE(D1.D1_EMISSAO, 'YYYYMMDD' ) AS DT_EMIS "
		cQuery += "     			, TO_DATE(D1.D1_DTDIGIT, 'YYYYMMDD' ) AS DT_ENT "
		cQuery += " 				, REPLACE(NVL(W9.W9_INVOICE,'ND'),' ','') AS INVOICE "
		cQuery += " 				, REPLACE(ZD1.ZD1_XCASE,' ','') AS CAIXA "
		cQuery += " 				, REPLACE(D1.D1_XCONT,' ','') AS CONT "
		cQuery += " 				, ZD1.ZD1_LOCAL ARMZ_REC "
		cQuery += " 				, B2.B2_QATU SLD_ARMZ_REC "
		cQuery += " FROM " +  RetSQLName("ZD1") +" ZD1 "
		cQuery += " LEFT JOIN " +  RetSQLName("SD1") +" D1 "
		cQuery += " 	ON D1.D_E_L_E_T_ = ' ' "
		cQuery += " 	AND D1.D1_FILIAL = ZD1.ZD1_FILIAL "
		cQuery += " 	AND D1.D1_DOC = ZD1.ZD1_DOC "
		cQuery += " 	AND D1.D1_SERIE = ZD1.ZD1_SERIE "
		cQuery += "     AND D1.D1_COD = ZD1.ZD1_COD "
		cQuery += "     AND D1.D1_FORNECE = ZD1.ZD1_FORNEC "
		cQuery += " 	AND D1.D1_LOJA = ZD1.ZD1_LOJA "
		cQuery += "     AND D1.D1_XCASE = ZD1.ZD1_XCASE "
		cQuery += " LEFT JOIN " +  RetSQLName("SW9") +" W9 "
		cQuery += " 	ON W9.D_E_L_E_T_ = ' ' "
		cQuery += " 	AND W9.W9_FILIAL = ZD1.ZD1_FILIAL "
		cQuery += " 	AND W9.W9_HAWB = D1.D1_XCONHEC "
		cQuery += " LEFT JOIN " +  RetSQLName("SB2") +" B2 "
		cQuery += " 	ON B2.D_E_L_E_T_ = ' ' "
		cQuery += " 	AND B2.B2_FILIAL = ZD1.ZD1_FILIAL "
		cQuery += " 	AND B2.B2_COD = ZD1.ZD1_COD "
		cQuery += " 	AND B2.B2_LOCAL = ZD1.ZD1_LOCAL "
		cQuery += " WHERE ZD1.ZD1_FILIAL = '" + FWxFilial('SZM') + "' "
		cQuery += " AND ZD1.D_E_L_E_T_ = ' ' "
		cQuery += " AND ZD1.ZD1_SLDIT >= 0 "
		cQuery += " AND B2.B2_QATU > 0 "
		cQuery += " AND D1.D1_DTDIGIT BETWEEN '" + aRet[1] + "' AND '" + aRet[2] + "' "
		If !Empty(aRet[3])
			cQuery += " AND ZD1.ZD1_COD = '" + aRet[3] + " ' "
		EndIf
		If !Empty(aRet[4])
			cQuery += " AND ZD1.ZD1_DOC = '" + aRet[4] + " ' "
		EndIf
		If !Empty(aRet[5])
			cQuery += " AND ZD1.ZD1_SERIE = '" + aRet[5] + " ' "
		EndIf
		If !Empty(aRet[6])
			cQuery += " AND W9.W9_INVOICE = '" + aRet[6] + " ' "
		EndIf
		If !Empty(aRet[7])
			cQuery += " AND ZD1.ZD1_XCASE = '" + aRet[7] + " ' "
		EndIf
		If !Empty(aRet[8])
			cQuery += " AND D1.D1_XCONT = '" + aRet[8] + " ' "
		EndIf
		cQuery += " ORDER BY ZD1.ZD1_SLDIT DESC, TO_DATE(W9.W9_DT_EMIS, 'YYYYMMDD' ) "

		cQuery := ChangeQuery(cQuery)

		// Executa a consulta.
		DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

		DbSelectArea((cAliasTRB))
		nTotReg := Contar(cAliasTRB,"!Eof()")
		(cAliasTRB)->(dbGoTop())
   
		While !(cAliasTRB)->(EoF())

			// Incrementa a mensagem na régua.
			IncProc("Exportando informações para Excel...")

		oFWMsExcel:AddColumn("Relatorio","Planilha01","Produto"              		,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Qtde NFiscal"                ,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Qtde Pendente"               ,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Nota Fiscal"                	,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Serie"                		,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Emissao NFiscal"             ,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Digitacao NFiscal"           ,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Invoice"                		,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Data Invoice"                ,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Caixa"                		,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Container"                	,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Armaz Rec"                	,1)
		oFWMsExcel:AddColumn("Relatorio","Planilha01","Saldo Armaz Rec"             ,1)

			oFWMsExcel:AddRow(	"Relatorio","Planilha01",{;
								(cAliasTRB)->COD,;
								(cAliasTRB)->QTD,;
								(cAliasTRB)->QTD_PEND,;
								(cAliasTRB)->NF,;
								(cAliasTRB)->SERIE,;
								(cAliasTRB)->DT_EMIS,;
								(cAliasTRB)->DT_ENT,;
								(cAliasTRB)->INVOICE,;
								(cAliasTRB)->DT_INV,;
								(cAliasTRB)->CAIXA,;
								(cAliasTRB)->CONT,;
								(cAliasTRB)->ARMZ_REC,;
								(cAliasTRB)->SLD_ARMZ_REC})
		
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

