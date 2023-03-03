#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

/*
=====================================================================================
Programa.:              ZFATR004
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              26/02/20
Descricao / Objetivo:   Relatorio de Faturamento x Titulos Pendentes
Doc. Origem:            
Solicitante:            Comercial
Uso......:              
Obs......:
=====================================================================================
*/
User Function ZFATR004() // u_ZFATR004()
	Local aPergs   		:= {}
    Local aCombo        := {"Em aberto", "Liquidados", "Ambos"}
    Local lRet          := .F.
    Local cExtens       := "Arquivo XML | *.XML"
	Local cTitulo	    := "Escolha o caminho para salvar o arquivo!"
	Local cMainPath     := "\"
	Local cArquivo	    := ""

    Private bVldDt      := {|| lRet := Empty(MV_PAR06) .And. Empty(MV_PAR08),; 
                            IIF( !lRet,; 
                            ( MV_PAR01 :=  CtoD(''),; 
                              MV_PAR02 :=  CtoD('') ),;
                            Nil ),;
                            lRet }
    
    Private bVldCli     := {|| lRet := Empty(MV_PAR06) .And. Empty(MV_PAR08),; 
                            IIF( !lRet,; 
                            ( MV_PAR03 :=  Space( TamSX3('A1_COD')[1] ) ),;
                            Nil ),;
                            lRet }

    Private bVldLoj     := {|| lRet := Empty(MV_PAR06) .And. Empty(MV_PAR08),; 
                            IIF( !lRet,; 
                            ( MV_PAR04 :=  Space( TamSX3('A1_LOJA')[1] ) ),;
                            Nil ),;
                            lRet }

    Private aRet        := {}

    aAdd(aPergs, {1 ,"Dt Emissão De (Faturamento) " ,CtoD('')                           ,""	        ,".T."	,""	    ,"Eval(bVldDt)"	    ,50	    ,.F.    })
    aAdd(aPergs, {1 ,"Dt Emissão Até (Faturamento)" ,CtoD('')	                        ,""	        ,".T."	,""	    ,"Eval(bVldDt)"	    ,50	    ,.F.    })
    aAdd(aPergs, {1 ,"Cliente"                      ,Space( TamSX3('A1_COD')[1] )       ,""         ,""     ,"SA1"  ,"Eval(bVldCli)"    ,0      ,.F.    })
    aAdd(aPergs, {1 ,"Loja"                         ,Space( TamSX3('A1_LOJA')[1] )      ,""         ,""     ,""     ,"Eval(bVldLoj)"    ,0      ,.F.    })
    aAdd(aPergs, {2 ,"Situação dos titulos"         ,"Ambos"                            ,aCombo     ,50     ,""     ,.F.                                })
    aAdd(aPergs, {1 ,"Num. NF"                      ,Space( TamSX3('VV0_NUMNFI')[1] )   ,""         ,""     ,"VV0"  ,""                 ,0      ,.F.    })
    aAdd(aPergs, {1 ,"Serie NF"                     ,Space( TamSX3('VV0_SERNFI')[1] )   ,""         ,""     ,""     ,VV0->VV0_SERNFI    ,0      ,.F.    })
    aAdd(aPergs, {1 ,"Nr. Chassi"                   ,Space( TamSX3('VRK_CHASSI')[1] )   ,""	        ,".T."	,""	    ,".T."	            ,80	    ,.F.    })

    If ParamBox( aPergs ,"Parametros ZFISR004" ,aRet )
    	cArquivo := cGetFile(cExtens,cTitulo,,cMainPath,.F.)
		If !Empty(cArquivo)
            Processa({|| zRel0004(cArquivo)}	,"Gerando Relatório de Titulos Liquidados..."	)
        EndIf
    EndIf

Return()

/*
=====================================================================================
Programa.:              zRel0004
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              26/02/2020
Descricao / Objetivo:   Gera Excel 
Doc. Origem:            
Solicitante:            Comercial
Uso......:              ZFISR004
Obs......:
=====================================================================================
*/
Static Function zRel0004(cArquivo)

	Local cQuery		:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cAba1			:= "Titulos Liquidados"
	Local cTabela1		:= "Relação de Titulos Liquidados"
	Local oFWMsExcel
	Local oExcel
	Local nTotReg		:= 0

	If !ApOleClient( "MSExcel" )
		MsgAlert( "Microsoft Excel não instalado!!" )
		Return
	EndIf

	If Select( (cAliasTRB) ) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf

	cQuery += " SELECT  VRJ_FILIAL, VRJ_PEDIDO, VRJ_FORPAG, VV3_DESCRI, VRK_CHASSI, VRK_OPCION, VX5.VX5_DESCRI, "       + CRLF
    cQuery += "         VX5B.VX5_DESCRI AS COREXT, VRK_MODVEI, VRK_FABMOD, VV0_NUMNFI, VV0_SERNFI, VV0_DATEMI, "        + CRLF
    cQuery += "         VRK_VALTAB, F2_VALFAT, F2_CHVNFE, E1_EMISSAO, E1_VENCTO, E1_BAIXA, E1_VALOR, E1_PARCELA, "      + CRLF
    cQuery += "         E1_SALDO, A1_CGC, A1_NOME, A1_MUN, A1_EST, E4_DESCRI, D1_NFORI, D1_DOC, D1_SERIE, F2_EMISSAO,"  + CRLF
	cQuery += "         VV0_CODMAR, A1_NREDUZ, D1_EMISSAO															 "  + CRLF

	cQuery += " FROM " + RetSQLName('VRJ') + " VRJ "														            + CRLF
    
	cQuery += " INNER JOIN " + RetSQLName('VRK') + " VRK "                                                              + CRLF
	cQuery += "         ON VRK_FILIAL = '" + FWxFilial('VRK') + "' "                                                    + CRLF	
	cQuery += "         AND VRK_PEDIDO = VRJ_PEDIDO " 														            + CRLF
	cQuery += "         AND VRK.D_E_L_E_T_ = ' ' " 			        										            + CRLF
    
    If !Empty( aRet[8] )    
        cQuery += " 	    AND VRK_CHASSI = '" + aRet[8] + "' "	                                                    + CRLF
    EndIf   
    
    cQuery += " INNER JOIN " + RetSQLName('VX5') + " VX5 "                                                              + CRLF
    cQuery += "         ON VX5.VX5_FILIAL = '" + FWxFilial('VX5') + "' "                                                + CRLF
    //-- Tabela Genérica SIGAVEI <-> Cód 068 - Opcional		    
	cQuery += "         AND VX5.VX5_CHAVE = '068' "                                                                     + CRLF
	cQuery += " 	    AND VX5.VX5_CODIGO = VRK_OPCION " 													            + CRLF
	cQuery += " 	    AND VX5.D_E_L_E_T_ = ' ' " 			        										            + CRLF
    
    cQuery += " INNER JOIN " + RetSQLName('VX5') + " VX5B "                                                             + CRLF
    cQuery += "         ON VX5.VX5_FILIAL = '" + FWxFilial('VX5') + "' "                                                + CRLF
    //-- Tabela Genérica SIGAVEI <-> Cód 067 - Cor Externa  
	cQuery += "         AND VX5B.VX5_CHAVE = '067' "                                                                    + CRLF 
	cQuery += " 	    AND VX5B.VX5_CODIGO = VRK_COREXT " 													            + CRLF
	cQuery += " 	    AND VX5B.D_E_L_E_T_ = ' ' " 			        									            + CRLF
    
    cQuery += " INNER JOIN " + RetSQLName('VV0') + " VV0 "                                                              + CRLF
    cQuery += "         ON VV0_FILIAL = '" + FWxFilial('VV0') + "' "                                                    + CRLF
    cQuery += "         AND VV0_NUMTRA = VRK_NUMTRA "                                                                   + CRLF
    
    If Empty( aRet[6] ) 
        If  !Empty( aRet[1] )   
            cQuery += " 	    AND VV0_DATEMI BETWEEN '" + DToS( aRet[1] ) + "' AND '" + DToS( aRet[2] ) + "' "	    + CRLF
        EndIf   
    Else    
        cQuery += " 	    AND VV0_NUMNFI = '" + aRet[6] + "' "	                                                    + CRLF
        cQuery += " 	    AND VV0_SERNFI = '" + aRet[7] + "' "	                                                    + CRLF
    EndIf   
    
	cQuery += " 	    AND VV0.D_E_L_E_T_ = ' ' " 			        										            + CRLF
    
    cQuery += " INNER JOIN " + RetSQLName('SF2') + " SF2 "                                                              + CRLF
    cQuery += "         ON F2_FILIAL = '" + FWxFilial('SF2') + "' "                                                     + CRLF	
	cQuery += "         AND F2_DOC = VV0_NUMNFI "                                                                       + CRLF
	cQuery += "         AND F2_SERIE = VV0_SERNFI "                                                                     + CRLF
    cQuery += "         AND F2_CLIENTE = VV0_CODCLI "                                                                   + CRLF
    cQuery += "         AND F2_LOJA = VV0_LOJA "                                                                        + CRLF
	cQuery += " 	    AND SF2.D_E_L_E_T_ = ' ' " 			        										            + CRLF
    
    cQuery += " INNER JOIN " + RetSQLName('SA1') + " SA1 "                                                              + CRLF
    cQuery += "         ON A1_FILIAL = '" + FWxFilial('SA1') + "' "                                                     + CRLF
    cQuery += "         AND A1_COD = VV0_CODCLI "                                                                       + CRLF
    cQuery += "         AND A1_LOJA = VV0_LOJA "                                                                        + CRLF
    cQuery += " 	    AND SA1.D_E_L_E_T_ = ' ' " 			        										            + CRLF
    
    cQuery += " INNER JOIN " + RetSQLName('SE1') + " SE1 "                                                              + CRLF
    cQuery += "         ON E1_FILIAL = '" + FWxFilial('SE1') + "' "                                                     + CRLF	
	cQuery += "         AND E1_CLIENTE = VV0_CODCLI "                                                                   + CRLF
    cQuery += "         AND E1_LOJA = VV0_LOJA "                                                                        + CRLF
    cQuery += "         AND E1_PREFIXO = VV0_SERNFI "                                                                   + CRLF
    cQuery += "         AND E1_NUM = VV0_NUMNFI "                                                                       + CRLF
	cQuery += " 	    AND SE1.D_E_L_E_T_ = ' ' " 			        										            + CRLF
    
    cQuery += " INNER JOIN " + RetSQLName('SE4') + " SE4 "                                                              + CRLF
    cQuery += "         ON E4_FILIAL = '" + FWxFilial('SE4') + "' "                                                     + CRLF	
	cQuery += "         AND E4_CODIGO = VRJ_FORPAG "                                                                    + CRLF
	cQuery += " 	    AND SE4.D_E_L_E_T_ = ' ' " 			        										            + CRLF
    
    If aRet[5] == "Em aberto"   
        cQuery += "         AND E1_BAIXA = ' ' "                                                                        + CRLF
    ElseIf aRet[5] == "Liquidados"  
        cQuery += "         AND E1_BAIXA <> ' ' "                                                                       + CRLF
    EndIf   
    
    cQuery += " LEFT JOIN " + RetSQLName('VV3') + " VV3 "                                                               + CRLF
    cQuery += "         ON VV3_FILIAL = '" + FWxFilial('VV3') + "' "                                                    + CRLF	
	cQuery += "         AND VV3_TIPVEN = VV0_TIPVEN "                                                                   + CRLF
	cQuery += " 	    AND VV3.D_E_L_E_T_ = ' ' " 			        										            + CRLF
    
    cQuery += " LEFT JOIN " + RetSQLName('SD1') + " SD1 "                                                               + CRLF
    cQuery += "         ON D1_FILIAL = '" + FWxFilial('SD1') + "' "                                                     + CRLF
    cQuery += "         AND D1_TIPO = 'D' "                                                                             + CRLF	
    cQuery += "         AND D1_NFORI = VV0_NUMNFI "                                                                     + CRLF
    cQuery += "         AND D1_SERIORI = VV0_SERNFI "                                                                   + CRLF
    cQuery += " 	    AND SD1.D_E_L_E_T_ = ' ' " 			        										            + CRLF
    
	cQuery += " WHERE VRJ_FILIAL = '" + FWxFilial('VRJ') + "' "                                                         + CRLF
        
    If !Empty(aRet[3])  
        cQuery += "         AND VRJ_CODCLI = '" + aRet[3] + "' "                                                        + CRLF
        cQuery += "         AND VRJ_LOJA = '" + aRet[4] + "' "                                                          + CRLF
    EndIf   
    
	cQuery += " 	    AND VRJ.D_E_L_E_T_ = ' ' "	 														            + CRLF
    
	cQuery += " GROUP BY VRJ_FILIAL, VRJ_PEDIDO, VRJ_FORPAG, VV3_DESCRI, VRK_CHASSI, VRK_OPCION, VX5.VX5_DESCRI, "      + CRLF
    cQuery += "         VX5B.VX5_DESCRI, VRK_MODVEI, VRK_FABMOD, VV0_NUMNFI, VV0_SERNFI, VV0_DATEMI, VRK_VALTAB, "      + CRLF
    cQuery += "         F2_VALFAT, F2_CHVNFE, E1_EMISSAO, E1_VENCTO, E1_BAIXA, E1_VALOR, E1_PARCELA, E1_SALDO, "        + CRLF
    cQuery += "         A1_CGC, A1_NOME, A1_MUN, A1_EST, E4_DESCRI, D1_NFORI, D1_DOC, D1_SERIE, F2_EMISSAO,"            + CRLF
	cQuery += "         VV0_CODMAR, A1_NREDUZ, D1_EMISSAO												   "            + CRLF

	cQuery += " ORDER BY VRJ_FILIAL, VRJ_PEDIDO, VV0_NUMNFI, VV0_SERNFI "		                                    + CRLF

	//cQuery := ChangeQuery(cQuery)

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
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Num. Pedido"					,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Rede"				            ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Chassi"			            ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Opcional"			            ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descr. Opcional"	            ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descr. Cor Externa"           ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Modelo"                       ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Ano Fabr/Mod"                 ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Numero NF"                    ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Serie NF"                     ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt Emissão Pedido"            ,2	,4	,.F.	) // Center - Data
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Vlr Tabela"                   ,3	,2	,.F.	) // Right - Number
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Vlr Faturado"                 ,3	,2	,.F.	) // Right - Number
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Chave NF"                     ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1 ,cTabela1   ,"Dt Emissão Nota Fiscal"       ,2	,4	,.F.	) // Center - Data
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cond. Pagto"                  ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Desc. Cond. Pagto"            ,1	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt Emissão Tit."              ,2	,4	,.F.	) // Center - Data
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt Vencimento Tit."           ,2	,4	,.F.	) // Center - Data
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt Baixa Financeira"          ,2	,4	,.F.	) // Center - Data
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Tit."                   ,3	,2	,.F.	) // Right - Number
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Parcela"                      ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Saldo"                        ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"CPF/CNPJ"                     ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nome"                         ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Municipio"                    ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Estado"                       ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Devolução"                    ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"NF Devolucao"                 ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Serie NF Devolucao"           ,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Data NF Devolucao"            ,2	,4	,.F.	) // Center - Data
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cód. Marca"                   ,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nome Fantasia"                ,2	,1	,.F.	) // Center - Texto
		
		// Conta quantos registros existem, e seta no tamanho da régua.
		ProcRegua( nTotReg )

		DbSelectArea((cAliasTRB))
		(cAliasTRB)->(dbGoTop())
		While (cAliasTRB)->(!EoF())

			// Incrementa a mensagem na régua.
			IncProc("Exportando informações para Excel...")

			oFWMSExcel:AddRow( cAba1	,cTabela1	,{ 	(cAliasTRB)->VRJ_PEDIDO,;    //--Num. Pedido
														(cAliasTRB)->VV3_DESCRI,;    //--Rede
                                                        (cAliasTRB)->VRK_CHASSI,;    //--Chassi
                                                        (cAliasTRB)->VRK_OPCION,;    //--Opcional	
                                                        (cAliasTRB)->VX5_DESCRI,;    //--Descr. Opcional	
                                                        (cAliasTRB)->COREXT,;    //--Descr. Cor Externa
                                                        (cAliasTRB)->VRK_MODVEI,;    //--Modelo           
                                                        (cAliasTRB)->VRK_FABMOD,;    //--Ano Fabr/Mod
                                                        (cAliasTRB)->VV0_NUMNFI,;    //--Numero NF             
                                                        (cAliasTRB)->VV0_SERNFI,;    //--Serie NF                
                                                        IIF( Empty( SToD( (cAliasTRB)->VV0_DATEMI ) ), "", SToD( (cAliasTRB)->VV0_DATEMI ) ),;    //--Dt Emissão Pedido
                                                        (cAliasTRB)->VRK_VALTAB,;    //--Vlr Tabela
                                                        (cAliasTRB)->F2_VALFAT,;    //--Vlr Faturado
                                                        (cAliasTRB)->F2_CHVNFE,;    //--Chave NF
                                                        IIF( Empty( SToD( (cAliasTRB)->F2_EMISSAO ) ), "", SToD( (cAliasTRB)->F2_EMISSAO ) ),;  //--Dt Emissão Nota Fiscal
                                                        (cAliasTRB)->VRJ_FORPAG,;
                                                        (cAliasTRB)->E4_DESCRI,;                                                        
                                                        IIF( Empty( SToD( (cAliasTRB)->E1_EMISSAO ) ), "", SToD( (cAliasTRB)->E1_EMISSAO ) ),;    //--Dt Emissão Tit.
                                                        IIF( Empty( SToD( (cAliasTRB)->E1_VENCTO ) ), "", SToD( (cAliasTRB)->E1_VENCTO ) ),;    //--Dt Vencimento Tit.
                                                        IIF( Empty( SToD( (cAliasTRB)->E1_BAIXA ) ), "", SToD( (cAliasTRB)->E1_BAIXA ) ),;    //--Dt Baixa Financeira  
                                                        (cAliasTRB)->E1_VALOR,;    //--Valor Tit.
                                                        (cAliasTRB)->E1_PARCELA,;    //--Parcela
                                                        (cAliasTRB)->E1_SALDO,;    //--Saldo
                                                        (cAliasTRB)->A1_CGC,;    //--CPF/CNPJ
                                                        (cAliasTRB)->A1_NOME,;    //--Nome
                                                        (cAliasTRB)->A1_MUN,;   //--Municipio
                                                        (cAliasTRB)->A1_EST,;   //--Estado
                                                        IIF( !Empty( (cAliasTRB)->D1_NFORI ), "Sim", "Não" ),;  //--Devolução
                                                        (cAliasTRB)->D1_DOC,;   //--NF Devolucao
                                                        (cAliasTRB)->D1_SERIE,;  //--Serie NF Devolucao
														IIF( Empty( SToD( (cAliasTRB)->D1_EMISSAO ) ), "", SToD( (cAliasTRB)->D1_EMISSAO ) ),;    //--Dt NF Devolucao
														(cAliasTRB)->VV0_CODMAR,;  //--Cód. Marca
														(cAliasTRB)->A1_NREDUZ })  //--Nome Fantasia
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

	(cAliasTRB)->(DbCloseArea())

Return()
