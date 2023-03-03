#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"
/*
=====================================================================================
Programa.:              ZFATR007
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              23/09/2022
Descricao / Objetivo:   Relatorio Limite de Crédito
Doc. Origem:            
Solicitante:            Financeiro.
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZFATR007()

	Processa({|| zRel0001()}	,"Gerando Relatório..."	)

Return()

/*
=====================================================================================
Programa.:              zRel0001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              26/09/2022
Descricao / Objetivo:   Gera relatorio
Doc. Origem:            
Solicitante:            Financeiro.
Uso......:              ZFATR007
Obs......:
=====================================================================================
*/
Static Function zRel0001()

	Local aArea		  	:= GetArea()
	Local cQuery	  	:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cArquivo	  	:= GetTempPath()+'Credito'+SUBSTRING(dtoc(date()),1,2)+SUBSTRING(dtoc(date()),4,2)+SUBSTRING(dtoc(date()),9,2)+'_'+SUBSTRING(time(),1,2) +SUBSTRING(time(),4,2) +SUBSTRING(time(),7,2)+'.xml'
	Local oFWMsExcel
	Local oExcel
	Local aParamBox 	:= {}
	Local aRet 			:= {}
	Local nTotReg		:= 0

	aAdd(aParamBox,	{1 ,"Raiz CNPJ De:" 				,Space(08)	,"@!","",,"",80	,.F.}) // Tipo caractere
	aAdd(aParamBox,	{1 ,"Raiz CNPJ Ate:" 				,Space(08)	,"@!","",,"",80	,.F.}) // Tipo caractere
	aAdd(aParamBox,	{2, "Tipo de Crédito ?"      		, "TODOS"   , {"TODOS","1 - FLOOR PLAN","2 - CAOA"}    ,     100, ".T.", .F.})
	

	If ParamBox(aParamBox,"Parametros para geração do Arquivo...",@aRet)

		//Criando o objeto que irá gerar o conteúdo do Excel
		oFWMsExcel := FWMSExcel():New()

		//Adiciona uma Worksheet ( Planilha )
		oFWMsExcel:AddworkSheet("Limite de Credito")
	
		//Criando a Tabela
		oFWMsExcel:AddTable( "Limite de Credito","Relacao credito Caoa",.T.)

		//Adiciona uma coluna a tabela de uma Worksheet.
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Cod.Cliente"              			,1,1)
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Loja Cliente"                		,1,1)
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Razao Social"                 		,1,1)
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Cnpj"            					,1,1)
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Tipo Credito"                 		,1,1)
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Lim. Concedido"                	,3,3)
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Vencimento"              			,2,1)
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Tit.Fin. Em Atraso" 				,3,3)
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Tit.Fin. Em Aberto"           		,3,3)
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Pedidos em Aberto/Reserv/Fatur"	,3,3)
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Pedidos em B.o."      				,3,3)
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Lim. Cred. Disponivel"      		,3,3)
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Bloqueia por Atraso Fin."      	,1,1)
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Status Cliente"      				,1,1)
		oFWMsExcel:AddColumn("Limite de Credito",	"Relacao credito Caoa",	"Status Credito"      				,1,1)
		
		If Select( (cAliasTRB) ) > 0
			(cAliasTRB)->(DbCloseArea())
		EndIf

		cQuery := "	"
		cQuery += " SELECT 	 SA1.A1_COD 				AS CLIENTE							" + CRLF
		cQuery += "			, SA1.A1_LOJA 				AS LOJA								" + CRLF
		cQuery += "			, SA1.A1_NOME 				AS NOME								" + CRLF
		cQuery += "			, SUBSTR(SA1.A1_CGC,1,8)	AS CNPJ								" + CRLF
		cQuery += "			, CASE															" + CRLF 
		cQuery += "				WHEN SA1.A1_XTPCRED = '0' THEN '0 - NAO POSSUI' 			" + CRLF
		cQuery += "				WHEN SA1.A1_XTPCRED = '1' THEN '1 - FLOOR PLAN' 			" + CRLF
		cQuery += "				WHEN SA1.A1_XTPCRED = '2' THEN '2 - CAOA' 					" + CRLF
		cQuery += "				WHEN SA1.A1_XTPCRED = ' ' THEN '0 - NAO POSSUI'				" + CRLF 
		cQuery += "				ELSE '0 - NAO POSSUI' 										" + CRLF
		cQuery += "			END 						AS TPCREDITO						" + CRLF
		cQuery += "			, SA1.A1_XLC				AS LIMITE							" + CRLF
		cQuery += "			, SA1.A1_XDTLC				AS VENCIMENTO						" + CRLF
		cQuery += "			, SA1.A1_XFPATR				AS TITULO_ATRASO					" + CRLF 
		cQuery += "			, SA1.A1_XLMUSA				AS TITULO_ABERTO					" + CRLF
		cQuery += "			, SA1.A1_XPEDFP				AS PEDIDOS_ABERTO					" + CRLF
		cQuery += "			, SA1.A1_XVALBO				AS PEDIDOS_BO						" + CRLF
		cQuery += "			, SA1.A1_XFPSAL				AS SALDO							" + CRLF
		cQuery += "			, CASE															" + CRLF 
		cQuery += "				WHEN SA1.A1_XBLQVEN = '1' THEN '1 - SIM'					" + CRLF 
		cQuery += "				WHEN SA1.A1_XBLQVEN = '2' THEN '2 - NÃO'					" + CRLF 
		cQuery += "			END 						AS BLOQUEIA_ATRASO					" + CRLF
		cQuery += "			,CASE															" + CRLF 
		cQuery += "				WHEN SA1.A1_XSTAFP = '1' THEN '1 - CREDITO DISPONIVEL'		" + CRLF 
		cQuery += "				WHEN SA1.A1_XSTAFP = '2' THEN '2 - FALTA DE SALDO'			" + CRLF 
		cQuery += "				WHEN SA1.A1_XSTAFP = '3' THEN '3 - TITULOS EM ATRASO'		" + CRLF 
		cQuery += "				WHEN SA1.A1_XSTAFP = '4' THEN '4 - CREDITO VENCIDO'			" + CRLF 
		cQuery += "				WHEN SA1.A1_XSTAFP = '5' THEN '5 - BLOQUEADO'				" + CRLF
		cQuery += "			END 						AS STATUS_CREDITO					" + CRLF
		cQuery += "			, CASE															" + CRLF 
		cQuery += "				WHEN SA1.A1_XBLQLC = '0' THEN '0 - ATIVO'					" + CRLF 
		cQuery += "				WHEN SA1.A1_XBLQLC = '1' THEN '1 - BLOQUEIO MANUAL'			" + CRLF 
		cQuery += "				WHEN SA1.A1_XBLQLC = '2' THEN '2 - DESCREDENCIADO'			" + CRLF
		cQuery += "			END 						AS STATUS_CLIENTE					" + CRLF
		cQuery += " FROM " +  RetSQLName("SA1") +" SA1										" + CRLF
		cQuery += " WHERE SA1.A1_FILIAL = '" + FWxFilial('SA1') + "'						" + CRLF
		If !Empty(aRet[1]) .Or. !Empty(aRet[2])
			cQuery += "	AND SUBSTR(SA1.A1_CGC,1,8) BETWEEN '" + aRet[1] + " ' AND '" + aRet[2] + " '	" + CRLF
		EndIf
		If aRet[3] == "1 - FLOOR PLAN"
			cQuery += "	AND A1_XTPCRED = '1'												" + CRLF
		ElseIf aRet[3] == "2 - CAOA"
			cQuery += "	AND A1_XTPCRED = '2'												" + CRLF
		EndIf
		cQuery += " AND D_E_L_E_T_ = ' '													" + CRLF
		cQuery += " ORDER BY SA1.A1_COD, SA1.A1_LOJA										" + CRLF 

		// Executa a consulta.
		DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

		DbSelectArea((cAliasTRB))
		nTotReg := Contar(cAliasTRB,"!Eof()")
		(cAliasTRB)->(dbGoTop())
   
		While !(cAliasTRB)->(EoF())

			// Incrementa a mensagem na régua.
			IncProc("Exportando informações para Excel...")

			oFWMsExcel:AddRow(	"Limite de Credito","Relacao credito Caoa",{;
								(cAliasTRB)->CLIENTE,;
								(cAliasTRB)->LOJA,;
								(cAliasTRB)->NOME,;
								(cAliasTRB)->CNPJ,;
								(cAliasTRB)->TPCREDITO,;
								(cAliasTRB)->LIMITE,;
								SToD((cAliasTRB)->VENCIMENTO),;
								(cAliasTRB)->TITULO_ATRASO,;
								(cAliasTRB)->TITULO_ABERTO,;
								(cAliasTRB)->PEDIDOS_ABERTO,;
								(cAliasTRB)->PEDIDOS_BO,;
								(cAliasTRB)->SALDO,;
								(cAliasTRB)->BLOQUEIA_ATRASO,;
								(cAliasTRB)->STATUS_CREDITO,;
								(cAliasTRB)->STATUS_CLIENTE})
		
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
