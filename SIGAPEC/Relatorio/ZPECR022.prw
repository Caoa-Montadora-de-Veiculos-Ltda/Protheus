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

	Processa({|| U_RZPECR022()}	,"Aguarde... Geração do Relatório")

Return

User Function RZPECR022()
	Local aArea		  	:= GetArea()
	Local cQuery	  	:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cArquivo	  	:= GetTempPath()+'Invoice_itens_'+SUBSTRING(dtoc(date()),1,2)+SUBSTRING(dtoc(date()),4,2)+SUBSTRING(dtoc(date()),9,2)+'_'+SUBSTRING(time(),1,2) +SUBSTRING(time(),4,2) +SUBSTRING(time(),7,2)+'.xml'
	Local oFWMsExcel
	Local oExcel
	Local aParamBox 	:= {}
	Local aRet 			:= {}
	Local nTotReg		:= 0
	Local nRegAtual		:= 0
	Local cDescri 		:=  ""
	Local aSituacao     := {"Pendentes","Todos"}

	aAdd(aParamBox, {1 ,"Data De:" 		,cTod("")						,""  ,"",""   ,"", 80	,.T.}) // Tipo caractere
	aAdd(aParamBox, {1 ,"Data Ate:" 	,cTod("")						,""  ,"",""   ,"", 80	,.T.}) // Tipo caractere
	aAdd(aParamBox, {1 ,"Produto:" 		,Space(TamSX3("B1_COD"    )[1])	,"@!","","SB1","", 80	,.F.}) // Tipo caractere
	aAdd(aParamBox, {1 ,"Nota Fiscal:"	,Space(TamSX3("D1_DOC"    )[1])	,"@!","","SD1","", 80	,.F.}) // Tipo caractere
	aAdd(aParamBox, {1 ,"Serie:"		,Space(TamSX3("D1_SERIE"  )[1])	,"@!","",""   ,"", 80	,.F.}) // Tipo caractere
	aAdd(aParamBox, {1 ,"Invoice:"		,Space(TamSX3("W9_INVOICE")[1])	,"@!","","SW9","", 80	,.F.}) // Tipo caractere
	aAdd(aParamBox, {1 ,"Caixa:"		,Space(TamSX3("ZD1_XCASE" )[1])	,"@!","",""   ,"", 80	,.F.}) // Tipo caractere
	aAdd(aParamBox, {1 ,"Container:"	,Space(TamSX3("D1_XCONT"  )[1])	,"@!","",""   ,"", 80	,.F.}) // Tipo caractere
	AAdd(aParamBox, {2, "Situação"	    , aSituacao[1], aSituacao                        , 70, , .T.})

	If ParamBox(aParamBox,"Parametros para geração do Arquivo...",@aRet)

		//Criando o objeto que irá gerar o conteúdo do Excel
		oFWMsExcel := FWMSExcel():New()

		//Aba - Gympass
		oFWMsExcel:AddworkSheet("Relatorio")
	
		//Criando a Tabela

		oFWMsExcel:AddTable( "Relatorio" ,"Planilha01")
		oFWMsExcel:AddColumn( "Relatorio" , "Planilha01" , "Produto"             , 1 )
		oFWMsExcel:AddColumn( "Relatorio" , "Planilha01" , "Descricao"           , 1 )
		oFWMsExcel:AddColumn( "Relatorio" , "Planilha01" , "Qtde NFiscal"        , 1 )
		oFWMsExcel:AddColumn( "Relatorio" , "Planilha01" , "Qtde Pendente"       , 1 )
		oFWMsExcel:AddColumn( "Relatorio" , "Planilha01" , "Nota Fiscal"         , 1 )
		oFWMsExcel:AddColumn( "Relatorio" , "Planilha01" , "Serie"               , 1 )
		oFWMsExcel:AddColumn( "Relatorio" , "Planilha01" , "Emissao NFiscal"     , 1 )
		oFWMsExcel:AddColumn( "Relatorio" , "Planilha01" , "Digitacao NFiscal"   , 1 )
		oFWMsExcel:AddColumn( "Relatorio" , "Planilha01" , "Invoice"             , 1 )
		oFWMsExcel:AddColumn( "Relatorio" , "Planilha01" , "Data Invoice"        , 1 )
		oFWMsExcel:AddColumn( "Relatorio" , "Planilha01" , "Caixa"               , 1 )
		oFWMsExcel:AddColumn( "Relatorio" , "Planilha01" , "Container"           , 1 )
		oFWMsExcel:AddColumn( "Relatorio" , "Planilha01" , "Armaz Rec"           , 1 )
		oFWMsExcel:AddColumn( "Relatorio" , "Planilha01" , "Saldo Armaz Rec"     , 1 )

		If Select( (cAliasTRB) ) > 0
			(cAliasTRB)->(DbCloseArea())
		EndIf

		cQuery := "	"
		cQuery += " SELECT 	DISTINCT NVL(ZD1.ZD1_COD,' ') 	AS COD  				"
		cQuery += " 		, NVL(ZD1.ZD1_QUANT,0) 			AS QTD  				"
		cQuery += " 		, NVL(ZD1_SLDIT,0)				AS QTD_PEND  			"	
		cQuery += " 		, ZD1.ZD1_DOC 					AS NF  					"
		cQuery += " 		, ZD1.ZD1_SERIE 				AS SERIE      			"
		cQuery += " 		, NVL(W9.W9_DT_EMIS, '' ) 		AS DT_INV      			"
		cQuery += " 		, NVL(D1.D1_EMISSAO, '' ) 		AS DT_EMIS      		"	
		cQuery += " 		, NVL(D1.D1_DTDIGIT, '' ) 		AS DT_ENT  				"
		cQuery += " 		, NVL(W9.W9_INVOICE,'ND') 		AS INVOICE  			"	
		cQuery += " 		, NVL(ZD1.ZD1_XCASE,' ') 		AS CAIXA  				"
		cQuery += " 		, NVL(D1.D1_XCONT,' ') 			AS CONT  				"
		cQuery += " 		, ZD1.ZD1_LOCAL 				AS ARMZ_REC  			"	
		cQuery += " 		, NVL(B2.B2_QATU,0) 			AS SLD_ARMZ_REC  		"
		cQuery += " FROM " +  RetSQLName("ZD1") +" ZD1 "
		cQuery += " LEFT JOIN " +  RetSQLName("SD1") +" D1 "
		cQuery += " 	ON  D1.D_E_L_E_T_ = ' ' "
		cQuery += " 	AND D1.D1_FILIAL  = ZD1.ZD1_FILIAL "
		cQuery += " 	AND D1.D1_DOC     = ZD1.ZD1_DOC "
		cQuery += " 	AND D1.D1_SERIE   = ZD1.ZD1_SERIE "
		cQuery += "     AND D1.D1_COD     = ZD1.ZD1_COD "
		cQuery += "     AND D1.D1_FORNECE = ZD1.ZD1_FORNEC "
		cQuery += " 	AND D1.D1_LOJA    = ZD1.ZD1_LOJA "
		cQuery += "     AND D1.D1_XCASE   = ZD1.ZD1_XCASE "
		cQuery += " LEFT JOIN " +  RetSQLName("SW9") +" W9 "
		cQuery += " 	ON  W9.D_E_L_E_T_ = ' ' "
		cQuery += " 	AND W9.W9_FILIAL  = ZD1.ZD1_FILIAL "
		cQuery += " 	AND W9.W9_HAWB    = D1.D1_XCONHEC "
		cQuery += " LEFT JOIN " +  RetSQLName("SB2") +" B2 "
		cQuery += " 	ON  B2.D_E_L_E_T_ = ' ' "
		cQuery += " 	AND B2.B2_FILIAL  = ZD1.ZD1_FILIAL "
		cQuery += " 	AND B2.B2_COD     = ZD1.ZD1_COD "
		cQuery += " 	AND B2.B2_LOCAL   = ZD1.ZD1_LOCAL "
		cQuery += " WHERE ZD1.ZD1_FILIAL = '" + FWxFilial('SZM') + "' "
		cQuery += "   AND ZD1.D_E_L_E_T_ = ' ' "
		//cQuery += "   AND ZD1.ZD1_SLDIT  > 0 "
		cQuery += "   AND  B2.B2_QATU    > 0 "
		cQuery += "   AND  D1.D1_DTDIGIT BETWEEN '" + DTos(aRet[1]) + "' AND '" + DToS(aRet[2]) + "' "

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
		If aRet[9] == aSituacao[1]
			cQuery += "   AND ZD1.ZD1_SLDIT  > 0 "
		Else
			cQuery += "   AND ZD1.ZD1_SLDIT  >= 0 "
		Endif
		
		cQuery += " ORDER BY 3,6"

		cQuery := ChangeQuery(cQuery)

		// Executa a consulta.
		DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

		DbSelectArea((cAliasTRB))
		nTotReg := Contar(cAliasTRB,"!Eof()")
		ProcRegua(nTotReg)
		(cAliasTRB)->(dbGoTop())
   
		While !(cAliasTRB)->(EoF())
			cDescri := Posicione("SB1",1,FWxFilial('SB1') + (cAliasTRB)->COD,"B1_DESC")
			// Incrementa a mensagem na régua.
			nRegAtual++
			IncProc("Exportando informações para Excel... Registo:" + alltrim(Str(nRegAtual)) + " de "+ alltrim(Str(nTotReg)) )

			oFWMsExcel:AddRow(	"Relatorio","Planilha01",{;
								(cAliasTRB)->COD,;
								cDescri,;
								(cAliasTRB)->QTD,;
								(cAliasTRB)->QTD_PEND,;
								(cAliasTRB)->NF,;
								(cAliasTRB)->SERIE,;
								STod((cAliasTRB)->DT_EMIS),;
								STod((cAliasTRB)->DT_ENT),;
								(cAliasTRB)->INVOICE,;
								STod((cAliasTRB)->DT_INV),;
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

