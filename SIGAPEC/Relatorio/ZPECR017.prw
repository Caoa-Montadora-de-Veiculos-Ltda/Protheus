#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"
/*
=====================================================================================
Programa.:              ZPECR017
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              05/05/2023
Descricao / Objetivo:   Relatorio de Cadastro de Produto.
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZPECR017()

	Local aArea		  	:= GetArea()
	Local aParamBox 	:= {}
	Local aRet 			:= {}

	aAdd(aParamBox,{1 ,"Produto De:" 		,Space(TamSX3("B1_COD")[1])		,"@!","","SB1",""	,80	,.F.}) // Tipo caractere
    aAdd(aParamBox,{1 ,"Produto Ate:" 		,Space(TamSX3("B1_COD")[1])		,"@!","","SB1",""	,80	,.F.}) // Tipo caractere
    aAdd(aParamBox,{1 ,"Grupo:" 		    ,Space(TamSX3("BM_GRUPO")[1])	,"@!","","SBM",""	,80	,.F.}) // Tipo caractere
    aAdd(aParamBox,{1 ,"NCM:" 		        ,Space(TamSX3("YD_TEC")[1])	    ,"@!","","SYD",""	,80	,.F.}) // Tipo caractere

	If ParamBox(aParamBox,"Parametros para geração do Arquivo...",@aRet)

        Processa( {|| zProcRel(aRet) }, "Imprimindo Relatório", "Processando aguarde...", .f.)
		
	EndIf

RestArea(aArea)

Return()

/*
=====================================================================================
Programa.:              zProcRel
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              05/05/2023
Descricao / Objetivo:   Relatorio de Cadastro de Produto.
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/

Static Function zProcRel(_aRetParam)

	Local cQuery	  	:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cArquivo	  	:= GetTempPath()+'Cadproduto_'+SUBSTRING(dtoc(date()),1,2)+SUBSTRING(dtoc(date()),4,2)+SUBSTRING(dtoc(date()),9,2)+'_'+SUBSTRING(time(),1,2) +SUBSTRING(time(),4,2) +SUBSTRING(time(),7,2)+'.xml'
	Local oFWMsExcel
	Local oExcel
  	Local nTotReg		:= 0
    Local nProc         := 1
    Local cTxPis        := GETMV("MV_TXPIS")
    Local cTxCofins     := GETMV("MV_TXCOFIN")

//Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()

    //Aba - Gympass
    oFWMsExcel:AddworkSheet("Relatorio")

    //Criando a Tabela

    oFWMsExcel:AddTable("Relatorio","Planilha01")
    //FWMsExcel():AddColumn(< cWorkSheet >, < cTable >, < cColumn >, < nAlign >, < nFormat >, < lTotal >)-> NIL
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Filial"              		,1  ,1  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Produto"                     ,1  ,1  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Descrição"                   ,1  ,1  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Saldo"                	    ,3  ,2  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Custo"                		,3  ,3  ) 
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Linha"                		,2  ,1  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Sub Linha"                   ,1  ,1  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Marca"                       ,1  ,1  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","NCM"                         ,1  ,1  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Ex NCM"                		,1  ,1  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Aliq. II"                	,1  ,2  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Aliq. IPI"                	,1  ,2  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Aliq. PIS"                	,1  ,2  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Aliq. COFINS"               	,1  ,2  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Dt. Cadastro"                ,2  ,4  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Dt. Ult. Alteração"          ,2  ,4  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","1a. Compra"                  ,2  ,4  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","1a. Venda"                   ,2  ,4  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Ult. Compra"                 ,2  ,4  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Ult. Venda"                  ,2  ,4  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Prc FOB"                		,3  ,3  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Peso"                       	,1  ,2  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Comprimento"                	,1  ,2  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Largura"                    	,1  ,2  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Altura"                    	,1  ,2  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Embalagem"                  	,1  ,2  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Origem"                		,1  ,1  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Descr. Origem"          		,1  ,1  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Grupo"                		,1  ,1  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Descr. Grupo"          		,1  ,1  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","Fornecedor"             		,1  ,1  )
    oFWMsExcel:AddColumn("Relatorio","Planilha01","CNPJ"                		,1  ,1  )	
    
    If Select( (cAliasTRB) ) > 0
        (cAliasTRB)->(DbCloseArea())
    EndIf

    cQuery += " SELECT SB1.B1_FILIAL " + CRLF
    cQuery += "         , SB1.B1_COD " + CRLF
    cQuery += "         , SB1.B1_DESC " + CRLF
    cQuery += " 	    , NVL(SB2SQL.SALDO,0)         	AS SALDO_ESTOQUE " + CRLF
    cQuery += " 	    , NVL(SB2SQL.CUSTO,0)         	AS CUSTO_MEDIO " + CRLF
    cQuery += "         , SB1.B1_TIPO " + CRLF
    cQuery += "         , SB5.B5_CODLIN " + CRLF
    cQuery += "         , SBM.BM_CODMAR " + CRLF
    cQuery += "         , SBM.BM_GRUPO " + CRLF
    cQuery += "         , SBM.BM_DESC " + CRLF
    cQuery += "         , SB5.B5_LARG " + CRLF
    cQuery += "         , SB5.B5_ALTURA " + CRLF
    cQuery += "         , SB5.B5_COMPR " + CRLF
    cQuery += "         , SB1.B1_LOTVEN " + CRLF
    cQuery += "         , SB1.B1_ORIGEM " + CRLF
    cQuery += "         , SX5.X5_DESCRI " + CRLF
    cQuery += "         , SB1.B1_XDTINC " + CRLF
    cQuery += "         , SB1.B1_XDTULT " + CRLF
    cQuery += "         , SB1.B1_X1CLEG " + CRLF
    cQuery += "         , SB1.B1_XUCLEG " + CRLF
    cQuery += "         , SB1.B1_X1VLEG " + CRLF
    cQuery += "         , SB1.B1_XUVLEG " + CRLF
    cQuery += "         , SB1.B1_POSIPI " + CRLF
    cQuery += "         , SYD.YD_EX_NCM " + CRLF
    cQuery += "         , SYD.YD_PER_II " + CRLF
    cQuery += "         , SYD.YD_PER_IPI " + CRLF
    cQuery += "         , SB1.B1_XPRCFOB " + CRLF
    cQuery += "         , SB1.B1_UCOM " + CRLF
    cQuery += "         , SB1.B1_PESO " + CRLF
    cQuery += "         , SA2.A2_CGC " + CRLF
    cQuery += "         , SA2.A2_NREDUZ " + CRLF
    cQuery += "         ,(	SELECT MAX(SD1.D1_DTDIGIT)       " + CRLF
    cQuery += " 			FROM " +  RetSQLName("SD1") +" SD1 " + CRLF
    cQuery += " 				LEFT JOIN " +  RetSQLName("SF4") +" SF4  " + CRLF
    cQuery += " 				ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "' " + CRLF
    cQuery += " 				AND SF4.F4_CODIGO = SD1.D1_TES " + CRLF
    cQuery += " 				AND SF4.F4_ESTOQUE = 'S' " + CRLF
    cQuery += " 				AND SF4.D_E_L_E_T_ = ' '  " + CRLF
    cQuery += " 			WHERE SD1.D1_FILIAL = '" + FWxFilial('SD1') + "' " + CRLF
    cQuery += " 			AND SD1.D1_CF IN ('1102','2102','3102') " + CRLF
    cQuery += " 			AND SD1.D1_COD = SB1.B1_COD " + CRLF
    cQuery += " 			AND SD1.D_E_L_E_T_ = ' ' ) 		AS DT_ULT_COMPRA " + CRLF
    cQuery += "         ,(	SELECT MIN(SD1.D1_DTDIGIT)       " + CRLF
    cQuery += " 			FROM " +  RetSQLName("SD1") +" SD1 " + CRLF
    cQuery += " 				LEFT JOIN " +  RetSQLName("SF4") +" SF4  " + CRLF
    cQuery += " 				ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "' " + CRLF
    cQuery += " 				AND SF4.F4_CODIGO = SD1.D1_TES " + CRLF
    cQuery += " 				AND SF4.F4_ESTOQUE = 'S' " + CRLF
    cQuery += " 				AND SF4.D_E_L_E_T_ = ' '  " + CRLF
    cQuery += " 			WHERE SD1.D1_FILIAL = '" + FWxFilial('SD1') + "' " + CRLF
    cQuery += " 			AND SD1.D1_CF IN ('1102','2102','3102') " + CRLF
    cQuery += " 			AND SD1.D1_COD = SB1.B1_COD " + CRLF
    cQuery += " 			AND SD1.D_E_L_E_T_ = ' ' ) 		AS DT_PRI_COMPRA " + CRLF
    cQuery += "         , (	SELECT MAX(SD2.D2_EMISSAO)       " + CRLF
    cQuery += " 			FROM " +  RetSQLName("SD2") +" SD2 " + CRLF
    cQuery += " 				LEFT JOIN " +  RetSQLName("SF4") +" SF4  " + CRLF
    cQuery += " 				ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "' " + CRLF
    cQuery += " 				AND SF4.F4_CODIGO = SD2.D2_TES " + CRLF
    cQuery += " 				AND SF4.F4_ESTOQUE = 'S' " + CRLF
    cQuery += " 				AND SF4.D_E_L_E_T_ = ' '  " + CRLF
    cQuery += " 			WHERE SD2.D2_FILIAL = '" + FWxFilial('SD2') + "' " + CRLF
    cQuery += " 			AND SD2.D2_CF IN ('5102','5152','5403','6102','6110','6403') " + CRLF
    cQuery += " 			AND SD2.D2_COD = SB1.B1_COD " + CRLF
    cQuery += " 			AND SD2.D_E_L_E_T_ = ' ' ) 		AS DT_ULT_VENDA " + CRLF
    cQuery += "         , (	SELECT MIN(SD2.D2_EMISSAO)       " + CRLF
    cQuery += " 			FROM " +  RetSQLName("SD2") +" SD2 " + CRLF
    cQuery += " 				LEFT JOIN " +  RetSQLName("SF4") +" SF4  " + CRLF
    cQuery += " 				ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "' " + CRLF
    cQuery += " 				AND SF4.F4_CODIGO = SD2.D2_TES " + CRLF
    cQuery += " 				AND SF4.F4_ESTOQUE = 'S' " + CRLF
    cQuery += " 				AND SF4.D_E_L_E_T_ = ' '  " + CRLF
    cQuery += " 			WHERE SD2.D2_FILIAL = '" + FWxFilial('SD2') + "' " + CRLF
    cQuery += " 			AND SD2.D2_CF IN ('5102','5152','5403','6102','6110','6403') " + CRLF
    cQuery += " 			AND SD2.D2_COD = SB1.B1_COD " + CRLF
    cQuery += " 			AND SD2.D_E_L_E_T_ = ' ' ) 		AS DT_PRI_VENDA " + CRLF
    cQuery += " FROM " +  RetSQLName("SB1") +" SB1 " + CRLF
    cQuery += "     LEFT JOIN " +  RetSQLName("SB5") +" SB5 " + CRLF
    cQuery += "         ON SB5.B5_FILIAL = '" + FWxFilial('SB5') + "' " + CRLF
    cQuery += "         AND SB5.B5_COD = SB1.B1_COD " + CRLF
    cQuery += "         AND SB5.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "     LEFT JOIN " +  RetSQLName("SA2") +" SA2 " + CRLF
    cQuery += "         ON SA2.A2_FILIAL = '" + FWxFilial('SA2') + "' " + CRLF
    cQuery += "         AND SA2.A2_COD  = SB1.B1_PROC " + CRLF
    cQuery += "         AND SA2.A2_LOJA = SB1.B1_LOJPROC " + CRLF
    cQuery += "         AND SA2.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "     LEFT JOIN " +  RetSQLName("SYD") +" SYD " + CRLF
    cQuery += "         ON SYD.YD_FILIAL = '" + FWxFilial('SYD') + "' " + CRLF
    cQuery += "         AND SYD.YD_TEC     = SB1.B1_POSIPI " + CRLF
    cQuery += "         AND SYD.YD_EX_NCM  = SB1.B1_EX_NCM " + CRLF
    cQuery += "         AND SYD.YD_DESTAQU <> ' ' " + CRLF
    cQuery += "         AND SYD.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "     LEFT JOIN " +  RetSQLName("SX5") +" SX5 " + CRLF
    cQuery += "         ON SX5.X5_FILIAL 	=  '" + FWxFilial('SX5') + "' " + CRLF
    cQuery += "         AND SX5.X5_TABELA 	=  'S0' " + CRLF
    cQuery += "         AND SX5.X5_CHAVE	=  SB1.B1_ORIGEM " + CRLF
    cQuery += "         AND SX5.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "     LEFT JOIN " +  RetSQLName("SBM") +" SBM " + CRLF
    cQuery += "         ON SBM.BM_FILIAL = '" + FWxFilial('SBM') + "' " + CRLF
    cQuery += "         AND SBM.BM_GRUPO = SB1.B1_GRUPO " + CRLF
    cQuery += "         AND SBM.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " 	LEFT JOIN ( " + CRLF
    cQuery += " 				SELECT B2_COD,  CAST(SUM(NVL(B2_QATU,0)) AS NUMBER (8, 2)) AS SALDO, ( SUM(NVL(B2_VATU1,0)) / SUM(NVL(B2_QATU,0)) ) AS CUSTO FROM " +  RetSQLName("SB2") +" " + CRLF
    cQuery += " 				WHERE B2_FILIAL = '" + FWxFilial('SB2') + "' " + CRLF
    cQuery += " 				AND D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " 				AND B2_QATU <> 0 " + CRLF
    cQuery += " 				GROUP BY B2_COD " + CRLF
    cQuery += " 			) SB2SQL " + CRLF
    cQuery += " 	ON SB1.B1_COD = SB2SQL.B2_COD " + CRLF
    cQuery += " WHERE SB1.B1_FILIAL = '" + FWxFilial('SB1') + "'  " + CRLF
    cQuery += " AND SB1.B1_MSBLQL = '2' " + CRLF

    If _aRetParam[01] <> " "
        cQuery += " AND SB1.B1_COD >= '" + _aRetParam[01] + "' " + CRLF
    EndIf

    If _aRetParam[02] <> " "
        cQuery += " AND SB1.B1_COD <= '" + _aRetParam[02] + "' " + CRLF   
    EndIf

    If !Empty(_aRetParam[03])
        cQuery += " AND SB1.B1_GRUPO = '" + _aRetParam[03] + "' " + CRLF        
    EndIf

    If !Empty(_aRetParam[04]) 
        cQuery += " AND SB1.B1_NCM = '" + _aRetParam[04] + "' " + CRLF    
    EndIf

    cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  ORDER BY B1_COD "

    // Executa a consulta.
    DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

    DbSelectArea((cAliasTRB))
    nTotReg := Contar(cAliasTRB,"!Eof()")
    (cAliasTRB)->(dbGoTop())

    Procregua(nTotReg)

    If (cAliasTRB)->(EoF())
        FWAlertWarning("Não existe dados para serem exibidos, verifique os parametros iniciais.", "Atenção")
        (cAliasTRB)->(DbCloseArea())
        Return()
    Endif

    While !(cAliasTRB)->(EoF())

        // Incrementa a mensagem na régua.
        IncProc("Imprimindo: " + cValToChar(nProc) + " - " + cValToChar(nTotReg) + "...")

        oFWMsExcel:AddRow(	"Relatorio","Planilha01",{;
                                                        (cAliasTRB)->B1_FILIAL,;
                                                        (cAliasTRB)->B1_COD,;
                                                        (cAliasTRB)->B1_DESC,;
                                                        (cAliasTRB)->SALDO_ESTOQUE,;
                                                        (cAliasTRB)->CUSTO_MEDIO,;
                                                        (cAliasTRB)->B1_TIPO,;
                                                        (cAliasTRB)->B5_CODLIN,;
                                                        (cAliasTRB)->BM_CODMAR,;
                                                        (cAliasTRB)->B1_POSIPI,;
                                                        (cAliasTRB)->YD_EX_NCM,;
                                                        (cAliasTRB)->YD_PER_II,;
                                                        (cAliasTRB)->YD_PER_IPI,;
                                                        cTxPis,;
                                                        cTxCofins,;
                                                        STod((cAliasTRB)->B1_XDTINC),;
                                                        STod((cAliasTRB)->B1_XDTULT),;
                                                        IIf( Empty((cAliasTRB)->DT_PRI_COMPRA)  ,(cAliasTRB)->B1_X1CLEG ,(cAliasTRB)->DT_PRI_COMPRA ),;
                                                        IIf( Empty((cAliasTRB)->DT_PRI_VENDA)   ,(cAliasTRB)->B1_X1VLEG ,(cAliasTRB)->DT_PRI_VENDA  ),;
                                                        IIf( Empty((cAliasTRB)->DT_ULT_COMPRA)  ,(cAliasTRB)->B1_XUCLEG ,(cAliasTRB)->DT_ULT_COMPRA ),;
                                                        IIf( Empty((cAliasTRB)->DT_ULT_VENDA)   ,(cAliasTRB)->B1_XUVLEG ,(cAliasTRB)->DT_ULT_VENDA  ),;
                                                        (cAliasTRB)->B1_XPRCFOB,;
                                                        (cAliasTRB)->B1_PESO,;
                                                        (cAliasTRB)->B5_COMPR,;
                                                        (cAliasTRB)->B5_LARG,;
                                                        (cAliasTRB)->B5_ALTURA,;
                                                        (cAliasTRB)->B1_LOTVEN,;
                                                        (cAliasTRB)->B1_ORIGEM,;
                                                        (cAliasTRB)->X5_DESCRI,;
                                                        (cAliasTRB)->BM_GRUPO,;
                                                        (cAliasTRB)->BM_DESC,;
                                                        (cAliasTRB)->A2_NREDUZ,;
                                                        (cAliasTRB)->A2_CGC})
    
        (cAliasTRB)->(DbSkip()) 
        nProc++
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

Return()

