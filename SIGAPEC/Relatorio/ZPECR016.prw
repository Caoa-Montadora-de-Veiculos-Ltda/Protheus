#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"
/*
=====================================================================================
Programa.:              ZPECR016
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              08/12/21
Descricao / Objetivo:   Relatorio de Picking
Doc. Origem:            
Solicitante:            Logistica
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZPECR016()

	Processa({|| zRel0016()}	,"Gerando Relatório..."	)

Return()

/*
=====================================================================================
Programa.:              zRel0016
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              08/12/21
Descricao / Objetivo:   Gera relatorio
Doc. Origem:            
Solicitante:            Logistica
Uso......:              ZPECR016
Obs......:
=====================================================================================
*/
Static Function zRel0016()

	Local aArea		  	:= GetArea()
	Local cAliasQry		:= GetNextAlias()
	Local _cQuery	  	:= ""
	Local cArquivo	  	:= GetTempPath()+'PedVenda'+SUBSTRING(dtoc(date()),1,2)+SUBSTRING(dtoc(date()),4,2)+SUBSTRING(dtoc(date()),9,2)+'_'+SUBSTRING(time(),1,2) +SUBSTRING(time(),4,2) +SUBSTRING(time(),7,2)+'.xml'
	Local oFWMsExcel
	Local oExcel
	Local aPergs 		:= {}
	Local nTotReg		:= 0
	Local nCont			:= 0
	Local cAba			:= "Pedido Vendas"
	Local cTabela		:= " "

	Local cPedAw        := SPACE(20)
	Local cNota         := SPACE(09)
	Local cGupo         := SPACE(04)
	Local cOrc          := SPACE(08)
	Local cCod          := SPACE(23)
	Local cTp_Ped       := space(03)
	Local _aCombo    	:= {"CHE", "HYN", "SUB","   "}
	Local _aCmboSts  	:= {"NAO", "SIM"}
	Local _aST_Item   	:= {"EM ANALISE","BLOQUEADO POR CRÉDITO","B.O.","FATURADO","SEPARAÇÃO","CANCELADO","   "}
	
	Private MV_PAR01    := ""
	Private dDataI      := Date()
	Private dDataF      := Date()
	Private aRetP       := {}

	aAdd( aPergs ,{1,	"Pedido AW"				,cPedAw		,"@!", 		, "VS1AW"	,'.T.'	,60	,.F.	})
	aAdd( aPergs ,{1,	"Nota Fiscal"			,cNota 		,"@!", 		, "SF2"  	,'.T.'	,20	,.F.	})
	aadd( aPergs, {1,	"Data Inicial"			,dDataI		,"@D", 		, ""     	,  "" 	,60	,.T.	})
	aadd( aPergs, {1,	"Data Final"			,dDataF		,"@D", 		, ""     	,  "" 	,60	,.T.	})
	aAdd( aPergs ,{1,	"Orçamento" 			,cOrc  		,"@!", 		,"VS1ORC"	,'.T.'	,20	,.F.	})  //5
	aAdd( aPergs ,{1,	"Código" 				,cCod  		,"@!", 		, "SB1"  	,'.T.'	,50	,.F.	})  //6
	aAdd( aPergs ,{2,	"Marca" 				,"Marca" 	,_aCombo 	, 30 		,  "" 	,	.F.		})  //7
	aAdd( aPergs ,{1,	"Tipo Pedido"  			,cTp_Ped	,"@!", 		, "Z00"  	,'.T.'	,20	,.F.	})  //8
	aAdd( aPergs ,{1,	"Grupo" 				,cGupo 		,"@!", 		, "SBM"  	,'.T.'	,20	,.F.	})  //9
	aAdd( aPergs ,{2,	"Status do Item"		,"StatusI"	,_aST_Item	, 100 		, ""	,	.F.		})  //10
	aAdd( aPergs ,{2,	"Impr Status Pedido" 	,"StatusC" 	,_aCmboSts 	, 30 		,  "" 	,	.F.		})  //7
	
	If ParamBox(aPergs, "Parâmetros p/ Relatório", aRetP, , , , , , , , ,.T.) 

		//Criando o objeto que irá gerar o conteúdo do Excel
		oFWMsExcel := FWMSExcel():New()

		//Aba - Gympass
		oFWMsExcel:AddworkSheet(cAba)
	
		//Criando a Tabela
		oFWMsExcel:AddTable(cAba,cTabela)

		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Cnpj"           	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Nome Fantasia"  	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Estado"            ,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Pedido Web"        ,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Data Pedido"       ,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Hora Pedido"       ,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Marca"          	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Orcamento"     	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Data Orc"       	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Hora Orc"       	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Tipo Pedido"      	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Transporte"      	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Picking"        	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Data Pick"      	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Hora Pick"       	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Aglutina"       	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Nota Fiscal"       ,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Serie"          	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Emissao"        	,1	,1	,.F.	)
		//oFWMsExcel:AddColumn(cAba	, cTabela	,	"Item"        		,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Produto"        	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Descricao"         ,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Linha"          	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Sub Linha"       	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Grupo"          	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Chassis"        	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Tes"            	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Valor"  			,3	,2	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Qtde Pedido"       ,3	,2	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Qtde Reservada"    ,3	,2	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Qtde Atendida"     ,3	,2	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Status Item"    	,1	,1	,.F.	)
		oFWMsExcel:AddColumn(cAba	, cTabela	,	"Status Pedido"     ,1	,1	,.F.	)

		If Select( (cAliasQry) ) > 0
			(cAliasQry)->(DbCloseArea())
		EndIf

        _cQuery := ""
		_cQuery += " SELECT SA1.A1_CGC      					AS CNPJ "+ CRLF
		_cQuery += " 		, SA1.A1_NREDUZ   					AS NOME_FANTASIA "+ CRLF
		_cQuery += " 		, SA1.A1_EST      					AS UF "+ CRLF
		_cQuery += " 		, VS1LEG.VS1_XPVAW       			AS PED_WEB "+ CRLF  
		_cQuery += " 		, VS1LEG.VS1_XDTIMP					AS DATA_PED "+ CRLF
		_cQuery += " 		, VS1LEG.VS1_XHSIMP      			AS HORA_PED "+ CRLF    
		_cQuery += " 		, VS1LEG.VS1_XMARCA      			AS MARCA "+ CRLF
		_cQuery += " 		, VS1LEG.VS1_XDESMB      			AS DESMEB "+ CRLF
		_cQuery += " 		, VS1LEG.VS1_NUMORC      			AS ORCAMENTO "+ CRLF
		_cQuery += " 		, VS1LEG.VS1_DATORC					AS DATA_ORC "+ CRLF
		_cQuery += " 		, SUBSTR(LPAD(VS1LEG.VS1_HORORC,4,0),1,2)||':'||SUBSTR(LPAD(VS1LEG.VS1_HORORC,4,0),3,2)	     			AS HORA_ORC "+ CRLF
		_cQuery += " 		, NVL(RTRIM(VX5A.VX5_DESCRI),'-') 	AS DESC_TP_PEDIDO "+ CRLF
		_cQuery += " 		, NVL(RTRIM(VX5B.VX5_DESCRI),'-') 	AS MOD_TRANS "+ CRLF
		_cQuery += " 		, VS1LEG.VS1_XPICKI      			AS PICKING "+ CRLF
		_cQuery += " 		, VS1LEG.VS1_XDTEPI					AS DATA_PICK "+ CRLF
		_cQuery += " 		, VS1LEG.VS1_XHSPIC  	 			AS HORA_PIC "+ CRLF
		_cQuery += " 		, VS1LEG.VS1_XAGLU       			AS AGLUTINA "+ CRLF                                       
		_cQuery += " 		, VS1LEG.VS1_NUMNFI      			AS NOTA "+ CRLF                                         
		_cQuery += " 		, VS1LEG.VS1_SERNFI      			AS SERIE "+ CRLF  
		_cQuery += " 		, SF2.F2_CLIENTE					AS CLIENTE "+ CRLF
		_cQuery += " 		, SF2.F2_LOJA						AS LOJA "+ CRLF                                 
		_cQuery += " 		, SF2.F2_EMISSAO					AS EMISSAO "+ CRLF
		_cQuery += " 		, VS3LEG.VS3_CODITE  				AS PRODUTO "+ CRLF
		_cQuery += " 		, Trim(SB1.B1_DESC)     			AS DESCRI "+ CRLF
		_cQuery += " 		, SB1.B1_TIPO     					AS LINHA "+ CRLF
		_cQuery += " 		, NVL(SB5.B5_CODLIN,'-') 			AS SUBLINHA "+ CRLF
		_cQuery += " 		, SB1.B1_GRUPO    					AS GRUPO "+ CRLF
		_cQuery += " 		, VS1LEG.VS1_XCHASS     			AS CHASSIS "+ CRLF
		_cQuery += " 		, VS3LEG.VS3_CODTES  				AS TIPO_TES "+ CRLF
		_cQuery += " 		, NVL(ROUND(VS3LEG.VS3_VALTOT+VS3LEG.VS3_VICMSB+VS3LEG.VS3_VALPIS+VS3LEG.VS3_VALCOF,2),0) AS TOTAL_LINHA "+ CRLF
		_cQuery += " 		, NVL(VS3LEG.VS3_QTDITE,0) 			AS QTD_PED "+ CRLF
		_cQuery += " 		, CASE "+ CRLF
		_cQuery += " 			WHEN (VS1LEG.VS1_STATUS IN ('4','F'))						THEN (VS3LEG.VS3_QTDITE) "+ CRLF
		_cQuery += " 			ELSE 0 "+ CRLF
		_cQuery += " 		  END								AS QTD_RES "+ CRLF
		_cQuery += " 		, CASE "+ CRLF
		_cQuery += " 			WHEN (VS1LEG.VS1_STATUS IN ('X'))	        				THEN (VS3LEG.VS3_QTDITE) "+ CRLF
		_cQuery += " 			ELSE 0 "+ CRLF
		_cQuery += " 		  END								AS QTD_ATEND "+ CRLF
		_cQuery += " 		, CASE "+ CRLF
		_cQuery += " 			WHEN (VS1LEG.VS1_STATUS = '0' AND VS1LEG.VS1_XBO = ' ')		THEN 'EM ANALISE' "+ CRLF
		_cQuery += " 			WHEN (VS1LEG.VS1_STATUS = '3')								THEN 'BLOQUEADO POR CRÉDITO' "+ CRLF
		_cQuery += " 			WHEN (VS1LEG.VS1_STATUS = '0' AND VS1LEG.VS1_XBO = 'S')		THEN 'B.O.' "+ CRLF
		_cQuery += " 			WHEN (VS1LEG.VS1_STATUS IN ('X'))							THEN 'FATURADO' "+ CRLF
		_cQuery += " 			WHEN (VS1LEG.VS1_STATUS IN ('4','F'))						THEN 'SEPARAÇÃO' "+ CRLF
		_cQuery += " 			WHEN (VS1LEG.VS1_STATUS = 'C')								THEN 'CANCELADO' "+ CRLF
		_cQuery += " 			ELSE 'AG.REPROC' "+ CRLF
		_cQuery += " 		  END 								AS STATUS_ITEM "+ CRLF
		_cQuery += " FROM " + RetSqlName("VS1") + " VS1LEG "+ CRLF
		_cQuery += " 	INNER JOIN " + RetSqlName("VS3") + " VS3LEG "+ CRLF
		_cQuery += " 		ON VS3LEG.VS3_FILIAL = VS1LEG.VS1_FILIAL "+ CRLF
		_cQuery += " 		AND VS3LEG.VS3_NUMORC = VS1LEG.VS1_NUMORC "+ CRLF
		_cQuery += " 		AND VS3LEG.D_E_L_E_T_ = ' ' "+ CRLF
		_cQuery += " 	LEFT JOIN " + RetSqlName("SB1") + " SB1 "+ CRLF
		_cQuery += " 		ON TRIM(SB1.B1_FILIAL) = '" + AllTrim(xFilial("SB1")) + "'  "+ CRLF
		_cQuery += " 		AND SB1.B1_COD = VS3LEG.VS3_CODITE "+ CRLF
		_cQuery += " 		AND SB1.D_E_L_E_T_ = ' ' "+ CRLF
		_cQuery += " 	LEFT JOIN " + RetSqlName("SA1") + " SA1 "+ CRLF
		_cQuery += " 		ON SA1.A1_FILIAL = '" + xFilial("SA1") + "'   "+ CRLF
		_cQuery += " 		AND SA1.A1_COD = VS1LEG.VS1_CLIFAT "+ CRLF
		_cQuery += " 		AND SA1.A1_LOJA = VS1LEG.VS1_LOJA "+ CRLF
		_cQuery += " 		AND SA1.D_E_L_E_T_ = ' ' "+ CRLF
		_cQuery += " 	LEFT JOIN " + RetSqlName("VX5") + " VX5A "+ CRLF
		_cQuery += " 		ON VX5A.VX5_FILIAL = '" + xFilial("VX5") + "' "+ CRLF
		_cQuery += " 		AND VX5A.VX5_CHAVE = 'Z00' "+ CRLF
		_cQuery += " 		AND VX5A.VX5_CODIGO = VS1LEG.VS1_XTPPED "+ CRLF
		_cQuery += " 		AND VX5A.D_E_L_E_T_ = ' ' "+ CRLF
		_cQuery += " 	LEFT JOIN " + RetSqlName("VX5") + " VX5B "+ CRLF
		_cQuery += " 		ON VX5B.VX5_FILIAL = '" + xFilial("VX5") + "' "+ CRLF
		_cQuery += " 		AND VX5B.VX5_CHAVE = 'Z01' "+ CRLF
		_cQuery += " 		AND VX5B.VX5_CODIGO = VS1LEG.VS1_XTPTRA "+ CRLF
		_cQuery += " 		AND VX5B.D_E_L_E_T_ = ' ' "+ CRLF
		_cQuery += " 	LEFT JOIN " + RetSqlName("SB5") + " SB5 "+ CRLF
		_cQuery += " 		ON TRIM(SB5.B5_FILIAL) = TRIM(SB1.B1_FILIAL) "+ CRLF
		_cQuery += " 		AND SB5.B5_COD = SB1.B1_COD "+ CRLF
		_cQuery += " 		AND SB5.D_E_L_E_T_ = ' ' "+ CRLF
		_cQuery += " 	LEFT JOIN " + RetSqlName("SF2") + " SF2 "+ CRLF
		_cQuery += " 		ON SF2.F2_FILIAL = VS1LEG.VS1_FILIAL "+ CRLF
		_cQuery += " 		AND SF2.F2_DOC = VS1LEG.VS1_NUMNFI "+ CRLF
		_cQuery += " 		AND SF2.F2_SERIE = VS1LEG.VS1_SERNFI "+ CRLF
		_cQuery += " 		AND SF2.D_E_L_E_T_ = ' ' "+ CRLF
		_cQuery += " WHERE VS1LEG.VS1_FILIAL = '" + xFilial("VS1") + "' "+ CRLF
		_cQuery += " AND VS1LEG.D_E_L_E_T_ = ' ' "+ CRLF
		_cQuery += " AND VS1LEG.VS1_DATORC BETWEEN '" + DTos(aRetP[03]) + "' AND '" + DTos(aRetP[04]) + "'" + CRLF
		If !Empty(aRetP[01]) 
			_cQuery += " AND VS1LEG.VS1_XPVAW = '" + aRetP[01] + "' "        + CRLF
		EndIf
		If !Empty(aRetP[02])
			_cQuery += " AND SF2.F2_DOC = '" + aRetP[02] + "' "               + CRLF  
		EndIf
		If !Empty(aRetP[05])
			_cQuery += " AND VS1LEG.VS1_NUMORC = '" + aRetP[05] + "' "        + CRLF
		EndIf
		If !Empty(aRetP[06])
			_cQuery += " AND VS3LEG.VS3_CODITE = '" + aRetP[06] + "' "        + CRLF
		EndIf
		If !Empty(aRetP[07])
			_cQuery += " AND VS1LEG.VS1_XMARCA = '" + aRetP[07] + "' "        + CRLF
		EndIf
		If !Empty(aRetP[08])
			_cQuery += " AND VS1LEG.VS1_XTPPED = '" + aRetP[08] + "' "        + CRLF
		EndIf
		If !Empty(aRetP[09])
			_cQuery += " AND SB1.B1_GRUPO = '" + aRetP[09] + "' "             + CRLF
		EndIf
		If !Empty(aRetP[10])
			If AllTrim(aRetP[10]) == "EM ANALISE"
				_cQuery += " AND VS1LEG.VS1_STATUS = '0' AND VS1LEG.VS1_XBO = ' ' "     + CRLF
			ElseIf AllTrim(aRetP[10]) == "BLOQUEADO POR CRÉDITO"
				_cQuery += " AND VS1LEG.VS1_STATUS = '3' "        						+ CRLF
			ElseIf AllTrim(aRetP[10]) == "B.O."
				_cQuery += " AND VS1LEG.VS1_STATUS = '0' AND VS1LEG.VS1_XBO = 'S' "     + CRLF
			ElseIf AllTrim(aRetP[10]) == "CANCELADO"
				_cQuery += " AND VS1LEG.VS1_STATUS = 'C' "        						+ CRLF
			ElseIf AllTrim(aRetP[10]) == "SEPARAÇÃO"
				_cQuery += " AND VS1LEG.VS1_STATUS IN ('4','F') "        				+ CRLF
			ElseIf AllTrim(aRetP[10]) == "FATURADO"
				_cQuery += " AND VS1LEG.VS1_STATUS = 'X'  "        						+ CRLF
			EndIf
		EndIf
		_cQuery += " ORDER BY VS1LEG.VS1_NUMORC, VS1LEG.VS1_DATORC "+ CRLF
   
		// Executa a consulta.
		DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQuery), cAliasQry, .F., .T. )
		
		DbSelectArea((cAliasQry))
		nTotReg := Contar(cAliasQry,"!Eof()")
		
		ProcRegua(nTotReg)
		nCont := 1
		
		(cAliasQry)->(dbGoTop())
   		While !(cAliasQry)->(EoF())

			IncProc("Gerando Excel... " + cValToChar(nCont) + " de " + cValToChar(nTotReg) + " registros, Aguarde....")
			
			oFWMsExcel:AddRow(	cAba,cTabela,{	(cAliasQry)->CNPJ,;
												(cAliasQry)->NOME_FANTASIA,;
												(cAliasQry)->UF,;
												(cAliasQry)->PED_WEB,;
												SToD((cAliasQry)->DATA_PED),;
												(cAliasQry)->HORA_PED,;
												(cAliasQry)->MARCA,;
												(cAliasQry)->ORCAMENTO,;
												SToD((cAliasQry)->DATA_ORC),;
												(cAliasQry)->HORA_ORC,;
												(cAliasQry)->DESC_TP_PEDIDO,;
												(cAliasQry)->MOD_TRANS,;
												(cAliasQry)->PICKING,;
												SToD((cAliasQry)->DATA_PICK),;
												(cAliasQry)->HORA_PIC,;
												(cAliasQry)->AGLUTINA,;
												(cAliasQry)->NOTA,;
												(cAliasQry)->SERIE,;
												SToD((cAliasQry)->EMISSAO),;
												(cAliasQry)->PRODUTO,;
												(cAliasQry)->DESCRI,;
												(cAliasQry)->LINHA,;
												(cAliasQry)->SUBLINHA,;
												(cAliasQry)->GRUPO,;
												(cAliasQry)->CHASSIS,;
												(cAliasQry)->TIPO_TES,;
												zValItem( (cAliasQry)->NOTA, (cAliasQry)->SERIE, (cAliasQry)->CLIENTE, (cAliasQry)->LOJA, (cAliasQry)->EMISSAO, (cAliasQry)->PRODUTO, (cAliasQry)->TIPO_TES, (cAliasQry)->QTD_ATEND, (cAliasQry)->TOTAL_LINHA),;
												(cAliasQry)->QTD_PED,;
												(cAliasQry)->QTD_RES,;
												(cAliasQry)->QTD_ATEND,;
												(cAliasQry)->STATUS_ITEM,;
												IIF(AllTrim(aRetP[11]) == "SIM" , PQry01((cAliasQry)->DESMEB) ," ")	})
	
			(cAliasQry)->(DbSkip()) 
			nCont++
		EndDo
	
		//Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)
		
		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New() 			    //Abre uma nova conexão com Excel
		oExcel:WorkBooks:Open(cArquivo) 	    //Abre uma planilha
		oExcel:SetVisible(.T.) 				    //Visualiza a planilha
		oExcel:Destroy()						//Encerra o processo do gerenciador de tarefas
	
		(cAliasQry)->(DbCloseArea())
		
	EndIf

RestArea(aArea)

Return()

Static Function zValItem( _cNota, _cSerie, _cCliente, _cLoja,  _dEmissao, _cProduto, _cTes, _nQtde, _nValPed)

	Local _cAlsSD2	:= GetNextAlias()
	Local _cQrySD2	:= ""
	Local _nRet		:= 0

	_nRet := _nValPed

	If !Empty(_cNota) 
		If Select( (_cAlsSD2) ) > 0
			(_cAlsSD2)->(DbCloseArea())
		EndIf

		_cQrySD2 := ""
		_cQrySD2 += " SELECT D2_VALBRUT FROM " + RetSqlName("SD2") + " SD2 "	+ CRLF
		_cQrySD2 += " WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "' "     		+ CRLF
		_cQrySD2 += " AND SD2.D2_DOC = '" +_cNota + "' "        				+ CRLF
		_cQrySD2 += " AND SD2.D2_SERIE = '" + _cSerie + "' "        			+ CRLF
		_cQrySD2 += " AND SD2.D2_CLIENTE = '" + _cCliente + "' "        		+ CRLF
		_cQrySD2 += " AND SD2.D2_LOJA = '" + _cLoja + "'"        				+ CRLF
		_cQrySD2 += " AND SD2.D2_COD = '" + _cProduto + "' "        			+ CRLF
		_cQrySD2 += " AND SD2.D2_TES = '" + _cTes + "' "        				+ CRLF
		_cQrySD2 += " AND SD2.D2_EMISSAO = '" + _dEmissao + "' "       			+ CRLF
		_cQrySD2 += " AND SD2.D2_QUANT = " + CValToChar(_nQtde)					+ CRLF 
		_cQrySD2 += " AND ROWNUM = 1 "         									+ CRLF
		_cQrySD2 += " ORDER BY SD2.R_E_C_N_O_ "         						+ CRLF

		DbUseArea( .T., "TOPCONN", TcGenQry(,,_cQrySD2), _cAlsSD2, .T., .T. )

		DbSelectArea((_cAlsSD2))
		(_cAlsSD2)->(dbGoTop())
   
		If !(_cAlsSD2)->(EoF())
			_nRet := (_cAlsSD2)->D2_VALBRUT
		EndIf

		(_cAlsSD2)->(DbCloseArea())

	EndIf

Return(_nRet)

/*/{Protheus.doc} ZPECR016
//Rodar query para legenda de pedido	
@author Antonio Oliveira
@since 05/07/2022
@version 2.0
/*/
Static Function PQry01(_cDesmeb)

	Local _cQryTMP 	:= GetNextAlias()
	Local _cRet     := " "
	Local _cQuery   := ""

	If Empty(_cDesmeb)
    	Return(_cDesmeb)   
	endif

	If Select( (_cQryTMP) ) > 0
		(_cQryTMP)->(DbCloseArea())
	EndIf

	_cQuery := " "

	_cQuery += " WITH DESMB AS 	( SELECT "	+ CRLF         
 	_cQuery += "					VS1A.VS1_FILIAL, "	+ CRLF
 	_cQuery += "					VS1A.VS1_XDESMB, "	+ CRLF
 	_cQuery += "					MIN(VS1A.VS1_STATUS) AS MIN_ST, "	+ CRLF
 	_cQuery += "					(SELECT MAX(VS1B.VS1_STATUS) "	+ CRLF   	       
 	_cQuery += "			 FROM "+RetSqlName("VS1") + " VS1B "	+ CRLF       			   
	_cQuery += " 				 WHERE VS1B.D_E_L_E_T_ = ' ' "	+ CRLF         
	_cQuery += " 				 AND VS1B.VS1_STATUS != 'C' "	+ CRLF                       
	_cQuery += " 				 AND VS1B.VS1_FILIAL = VS1A.VS1_FILIAL "	+ CRLF                       
	_cQuery += " 				 AND VS1B.VS1_XDESMB  = VS1A.VS1_XDESMB "	+ CRLF        			    
	_cQuery += " 			 GROUP BY VS1B.VS1_FILIAL, VS1B.VS1_XDESMB) AS MAX_ST "	+ CRLF       			  
 	_cQuery += "			 FROM "+RetSqlName("VS1") + " VS1A "	+ CRLF				   	
	_cQuery += " 				 WHERE VS1A.VS1_FILIAL = '" + xFilial("VS1") + "' "	+ CRLF 					
	_cQuery += " 				 AND VS1A.D_E_L_E_T_ = ' ' "	+ CRLF				    
	_cQuery += " 				 AND VS1A.VS1_STATUS != 'C' "	+ CRLF 				  
 	_cQuery += "			 GROUP BY VS1A.VS1_FILIAL, VS1A.VS1_XDESMB) "	+ CRLF     
 	_cQuery += "			 SELECT "	+ CRLF     
 	_cQuery += "			 	CASE "	+ CRLF        
	_cQuery += " 				 	WHEN (DESMB.MIN_ST = '0' AND (DESMB.MAX_ST = '0' OR DESMB.MAX_ST IS NULL) AND VS1INI.VS1_XBO = ' ')     THEN 'EM ANALISE' "	+ CRLF        
	_cQuery += " 				 	WHEN (DESMB.MIN_ST <= '3' AND DESMB.MAX_ST = '3')						                               	THEN 'BLOQUEADO POR CRÉDITO'  "	+ CRLF       
	_cQuery += " 				 	WHEN (DESMB.MIN_ST = '0' AND (DESMB.MAX_ST = '0' OR DESMB.MAX_ST IS NULL) AND VS1INI.VS1_XBO = 'S') 	THEN 'B.O.' "	+ CRLF       
	_cQuery += " 				 	WHEN (DESMB.MIN_ST IN ('4','F') AND DESMB.MAX_ST IN ('4','F'))                              			THEN 'SEPARAÇÃO TOTAL'  "	+ CRLF       
	_cQuery += " 				 	WHEN (DESMB.MIN_ST < '4' AND (DESMB.MAX_ST = '4' OR DESMB.MAX_ST = 'F'))								THEN 'SEPARAÇÃO PARCIAL' "	+ CRLF        
	_cQuery += " 				 	WHEN (DESMB.MIN_ST = 'X' AND DESMB.MAX_ST = 'X')  			                         				   	THEN 'FATURADO TOTAL' "	+ CRLF        
	_cQuery += " 				 	WHEN (DESMB.MIN_ST != 'X' AND DESMB.MAX_ST = 'X')                        	  						   	THEN 'FATURADO PARCIAL'  "	+ CRLF       
	_cQuery += " 				 	WHEN (VS1INI.VS1_STATUS = 'C' AND (MIN_ST IS NULL OR MIN_ST = 'C'))                                     THEN 'CANCELADO'  "	+ CRLF
	_cQuery += " 				 END AS LEG_AW "	+ CRLF
	_cQuery += " 			FROM "+RetSqlName("VS1") + " VS1INI "	+ CRLF        
	_cQuery += " 			LEFT JOIN DESMB "	+ CRLF          
	_cQuery += " 				ON DESMB.VS1_FILIAL = VS1INI.VS1_FILIAL  "	+ CRLF           
	_cQuery += " 				AND DESMB.VS1_XDESMB = VS1INI.VS1_XDESMB  "	+ CRLF    
	_cQuery += " 				WHERE VS1INI.VS1_FILIAL = '" + xFilial("VS1") + "'  "	+ CRLF     
	_cQuery += " 				AND VS1INI.D_E_L_E_T_ = ' ' "	+ CRLF    
	_cQuery += " 				AND VS1INI.VS1_XDESMB = VS1INI.VS1_XDESMB "	+ CRLF
	_cQuery += " 				AND ROWNUM = 1 "	+ CRLF
	_cQuery += "				AND VS1INI.VS1_XDESMB = '" + _cDesmeb + "' "	+ CRLF

	DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,_cQuery), (_cQryTMP) , .F., .T. )

	If !(_cQryTMP)->(EoF())
		_cRet := AllTrim((_cQryTMP)->LEG_AW)
	Else
		_cRet := "AG.REPROC"
	EndIf

	If Select(_cQryTMP) <> 0
		(_cQryTMP)->(DbCloseArea())
		Ferase(_cQryTMP+GetDBExtension())
	Endif  

Return(_cRet)
