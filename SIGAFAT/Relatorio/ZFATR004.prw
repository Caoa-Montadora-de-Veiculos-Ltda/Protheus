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
    aAdd(aPergs, {1 ,"Num. NF"                      ,Space( TamSX3('F2_DOC'    )[1] )   ,""         ,""     ,"SF2"  ,""                 ,0      ,.F.    })
    aAdd(aPergs, {1 ,"Serie NF"                     ,Space( TamSX3('F2_SERIE'  )[1] )   ,""         ,""     ,""     ,SF2->F2_SERIE      ,0      ,.F.    })
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
Local dVVoEmiss := Stod("")
Local dSF2Emiss := Stod("")
Local dSE1Emiss := Stod("")
Local dSE1Venct := Stod("")
Local dSE1Baixa := Stod("")
Local dSD1Emiss := Stod("")
Local cSD1NFOri := ""

If !ApOleClient( "MSExcel" )
	MsgAlert( "Microsoft Excel não instalado!!" )
	Return
EndIf

If Select( (cAliasTRB) ) > 0
	(cAliasTRB)->(DbCloseArea())
EndIf

	cQuery += " SELECT  VRJ_FILIAL                  , " + CRLF
    cQuery += "         VRJ_PEDIDO                  , " + CRLF
    cQuery += "         F2_COND                     , " + CRLF
    cQuery += "         VV3_DESCRI                  , " + CRLF
    cQuery += "         VRK_CHASSI                  , " + CRLF
    cQuery += "         VRK_OPCION                  , " + CRLF 
    cQuery += "         VX5.VX5_DESCRI              , " + CRLF
    cQuery += "         VX5B.VX5_DESCRI AS COREXT   , " + CRLF 
    cQuery += "         VRK_MODVEI                  , " + CRLF
    cQuery += "         VRK_FABMOD                  , " + CRLF
    cQuery += "         SDB.DB_DOC                  , " + CRLF
    cQuery += "         SDB.DB_SERIE                , " + CRLF
    cQuery += "         SDB.DB_DATA                 , " + CRLF
    cQuery += "         VRK_VALTAB                  , " + CRLF
    cQuery += "         F2_VALFAT                   , " + CRLF
    cQuery += "         F2_CHVNFE                   , " + CRLF
    cQuery += "         E1_EMISSAO                  , " + CRLF
    cQuery += "         E1_VENCTO                   , " + CRLF
    cQuery += "         E1_BAIXA                    , " + CRLF
    cQuery += "         E1_VALOR                    , " + CRLF 
    cQuery += "         E1_PARCELA                  , " + CRLF
    cQuery += "         E1_SALDO                    , " + CRLF
    cQuery += "         A1_CGC                      , " + CRLF
    cQuery += "         A1_NOME                     , " + CRLF
    cQuery += "         A1_MUN                      , " + CRLF
    cQuery += "         A1_EST                      , " + CRLF
    cQuery += "         E4_DESCRI                   , " + CRLF
    cQuery += "         D1_NFORI                    , " + CRLF
    cQuery += "         D1_DOC                      , " + CRLF
    cQuery += "         D1_SERIE                    , " + CRLF
    cQuery += "         F2_EMISSAO                  , " + CRLF
	cQuery += "         VRK_CODMAR                  , " + CRLF
    cQuery += "         A1_NREDUZ                   , " + CRLF 
    cQuery += "         D1_EMISSAO					  " + CRLF
	cQuery += " FROM " + RetSQLName('VRJ') + " VRJ "														            + CRLF
	cQuery += " INNER JOIN " + RetSQLName('VRK') + " VRK ON VRK_FILIAL      = '" + FWxFilial('VRK') + "' "              + CRLF	
	cQuery += "                                         AND VRK_PEDIDO      = VRJ_PEDIDO " 							    + CRLF
	cQuery += "                                         AND VRK.D_E_L_E_T_  = ' ' " 			        				+ CRLF
    If !Empty( aRet[8] )
        cQuery += " 	    AND VRK_CHASSI = '" + aRet[8] + "' "	                                                    + CRLF
    EndIf   
    
    //-- Tabela Genérica SIGAVEI <-> Cód 068 - Opcional	
    cQuery += " INNER JOIN " + RetSQLName('VX5') + " VX5 ON VX5.VX5_FILIAL = '" + FWxFilial('VX5') + "' "               + CRLF
	cQuery += "                                         AND VX5.VX5_CHAVE  = '068' "                                    + CRLF
	cQuery += " 	                                    AND VX5.VX5_CODIGO = VRK_OPCION " 								+ CRLF
	cQuery += " 	                                    AND VX5.D_E_L_E_T_ = ' ' " 			        					+ CRLF

    //-- Tabela Genérica SIGAVEI <-> Cód 067 - Cor Externa  
    cQuery += " INNER JOIN " + RetSQLName('VX5') + " VX5B ON VX5.VX5_FILIAL  = '" + FWxFilial('VX5') + "' "             + CRLF
	cQuery += "                                          AND VX5B.VX5_CHAVE  = '067' "                                  + CRLF 
	cQuery += " 	                                     AND VX5B.VX5_CODIGO = VRK_COREXT " 							+ CRLF
	cQuery += " 	                                     AND VX5B.D_E_L_E_T_ = ' ' " 			        				+ CRLF

    cQuery += " INNER JOIN " + RetSqlName("SDB") + " SDB ON SDB.DB_FILIAL   = '" + FWxFilial('SDB') + "' "              + CRLF
    cQuery += "                                          AND LTRIM(RTRIM(VRK.VRK_MODVEI))||LTRIM(RTRIM(VRK.VRK_SEGMOD)) = LTRIM(RTRIM(SDB.DB_PRODUTO))"              + CRLF
    cQuery += "                                          AND VRK.VRK_CHASSI   = SDB.DB_NUMSERI"                         + CRLF
    cQuery += "                                          AND ' '              = SDB.DB_ESTORNO"                         + CRLF
    cQuery += "                                          AND 'SC6'            = SDB.DB_ORIGEM"                          + CRLF
    cQuery += "                                          AND SDB.D_E_L_E_T_   = ' '     
    If Empty( aRet[6] ) 
        If  !Empty( aRet[1] )   
            cQuery += " 	    AND SDB.DB_DATA BETWEEN '" + DToS( aRet[1] ) + "' AND '" + DToS( aRet[2] ) + "' "	    + CRLF
        EndIf   
    Else    
        cQuery += " 	    AND SDB.DB_DOC   = '" + aRet[6] + "' "	                                                    + CRLF
        cQuery += " 	    AND SDB.DB_SERIE = '" + aRet[7] + "' "	                                                    + CRLF
    EndIf   
        
    cQuery += " INNER JOIN " + RetSQLName('SF2') + " SF2 ON F2_FILIAL       = '" + FWxFilial('SF2') + "' "              + CRLF	
	cQuery += "                                         AND F2_DOC          = SDB.DB_DOC"                               + CRLF
	cQuery += "                                         AND F2_SERIE        = SDB.DB_SERIE"                             + CRLF
    cQuery += "                                         AND F2_CLIENTE      = SDB.DB_CLIFOR"                            + CRLF
    cQuery += "                                         AND F2_LOJA         = SDB.DB_LOJA"                              + CRLF
	cQuery += " 	                                    AND SF2.D_E_L_E_T_  = ' ' " 			        				+ CRLF
    
    cQuery += " INNER JOIN " + RetSQLName('SA1') + " SA1 ON A1_FILIAL       = '" + FWxFilial('SA1') + "' "              + CRLF
    cQuery += "                                         AND A1_COD          = SDB.DB_CLIFOR"                            + CRLF
    cQuery += "                                         AND A1_LOJA         = SDB.DB_LOJA"                              + CRLF
    cQuery += " 	                                    AND SA1.D_E_L_E_T_  = ' ' " 			        				+ CRLF
    
    cQuery += " INNER JOIN " + RetSQLName('SE1') + " SE1 ON E1_FILIAL       = '" + FWxFilial('SE1') + "' "              + CRLF	
	cQuery += "                                         AND E1_CLIENTE      = SDB.DB_CLIFOR"                            + CRLF
    cQuery += "                                         AND E1_LOJA         = SDB.DB_LOJA"                              + CRLF
    cQuery += "                                         AND E1_PREFIXO      = SDB.DB_SERIE"                             + CRLF
    cQuery += "                                         AND E1_NUM          = SDB.DB_DOC "                              + CRLF
	cQuery += " 	                                    AND SE1.D_E_L_E_T_  = ' ' " 			        				+ CRLF
    
    cQuery += " INNER JOIN " + RetSQLName('SE4') + " SE4 ON E4_FILIAL       = '" + FWxFilial('SE4') + "' "              + CRLF	
	cQuery += "                                         AND E4_CODIGO       = VRJ_FORPAG "                              + CRLF
	cQuery += " 	                                    AND SE4.D_E_L_E_T_  = ' ' " 			        				+ CRLF
    
    If aRet[5] == "Em aberto"   
        cQuery += "         AND E1_BAIXA = ' ' "                                                                        + CRLF
    ElseIf aRet[5] == "Liquidados"  
        cQuery += "         AND E1_BAIXA <> ' ' "                                                                       + CRLF
    EndIf   
    
    cQuery += " LEFT JOIN " + RetSQLName('VV3') + " VV3 ON  VV3_FILIAL      = '" + FWxFilial('VV3') + "' "              + CRLF	
	cQuery += "                                         AND VV3_TIPVEN      = VRJ_TIPVEN "                              + CRLF
	cQuery += " 	                                    AND VV3.D_E_L_E_T_  = ' ' " 			        			    + CRLF
    
    cQuery += " LEFT JOIN " + RetSQLName('SD1') + " SD1 ON  D1_FILIAL       = '" + FWxFilial('SD1') + "' "              + CRLF
    cQuery += "                                         AND D1_TIPO         = 'D' "                                     + CRLF	
    cQuery += "                                         AND D1_NFORI        = SDB.DB_DOC"                               + CRLF
    cQuery += "                                         AND D1_SERIORI      = SDB.DB_SERIE"                             + CRLF
    cQuery += " 	                                    AND SD1.D_E_L_E_T_  = ' ' " 			        				+ CRLF
    
	cQuery += " WHERE   VRJ_FILIAL = '" + FWxFilial('VRJ') + "' "                                                       + CRLF
        
    If !Empty(aRet[3])  
        cQuery += "         AND VRJ_CODCLI = '" + aRet[3] + "' "                                                        + CRLF
        cQuery += "         AND VRJ_LOJA = '" + aRet[4] + "' "                                                          + CRLF
    EndIf   
    
	cQuery += "     AND VRJ.D_E_L_E_T_ = ' ' "	 														                + CRLF
	cQuery += " GROUP BY    VRJ_FILIAL      , VRJ_PEDIDO, F2_COND   , VV3_DESCRI, VRK_CHASSI  , VRK_OPCION , VX5.VX5_DESCRI, "+ CRLF
    cQuery += "             VX5B.VX5_DESCRI , VRK_MODVEI, VRK_FABMOD, SDB.DB_DOC, SDB.DB_SERIE, SDB.DB_DATA, VRK_VALTAB    , "+ CRLF
    cQuery += "             F2_VALFAT       , F2_CHVNFE , E1_EMISSAO, E1_VENCTO , E1_BAIXA    , E1_VALOR   , E1_PARCELA    , "+ CRLF
    cQuery += "             E1_SALDO        , A1_CGC    , A1_NOME   , A1_MUN    , A1_EST      , E4_DESCRI  , D1_NFORI      , "+ CRLF 
    cQuery += "             D1_DOC          , D1_SERIE  , F2_EMISSAO, VRK_CODMAR, A1_NREDUZ   , D1_EMISSAO				     "+ CRLF
	cQuery += " ORDER BY VRJ_FILIAL, VRJ_PEDIDO, SDB.DB_DOC, SDB.DB_SERIE "		                                              + CRLF

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

            dVVoEmiss := If( Empty(Stod((cAliasTRB)->DB_DATA   )), "", Stod( (cAliasTRB)->DB_DATA    ))
            dSF2Emiss := If( Empty(Stod((cAliasTRB)->F2_EMISSAO)), "", Stod( (cAliasTRB)->F2_EMISSAO ))
            dSE1Emiss := If( Empty(Stod((cAliasTRB)->E1_EMISSAO)), "", Stod( (cAliasTRB)->E1_EMISSAO ))
            dSE1Venct := If( Empty(Stod((cAliasTRB)->E1_VENCTO )), "", Stod( (cAliasTRB)->E1_VENCTO  ))
            dSE1Baixa := If( Empty(Stod((cAliasTRB)->E1_BAIXA  )), "", Stod( (cAliasTRB)->E1_BAIXA   ))
			dSD1Emiss := If( Empty(Stod((cAliasTRB)->D1_EMISSAO)), "", Stod( (cAliasTRB)->D1_EMISSAO ))
            cSD1NFOri := IF(!Empty((cAliasTRB)->D1_NFORI ), "Sim", "Não"                              )

			oFWMSExcel:AddRow(cAba1 ,cTabela1 ,{(cAliasTRB)->VRJ_PEDIDO ,;  //--Num. Pedido
												(cAliasTRB)->VV3_DESCRI ,;  //--Rede
                                                (cAliasTRB)->VRK_CHASSI ,;  //--Chassi
                                                (cAliasTRB)->VRK_OPCION ,;  //--Opcional	
                                                (cAliasTRB)->VX5_DESCRI ,;  //--Descr. Opcional	
                                                (cAliasTRB)->COREXT     ,;  //--Descr. Cor Externa
                                                (cAliasTRB)->VRK_MODVEI ,;  //--Modelo           
                                                (cAliasTRB)->VRK_FABMOD ,;  //--Ano Fabr/Mod
                                                (cAliasTRB)->DB_DOC     ,;  //--Numero NF             
                                                (cAliasTRB)->DB_SERIE   ,;  //--Serie NF                
                                                dVVoEmiss               ,;  //--Dt Emissão Pedido
                                                (cAliasTRB)->VRK_VALTAB ,;  //--Vlr Tabela
                                                (cAliasTRB)->F2_VALFAT  ,;  //--Vlr Faturado
                                                (cAliasTRB)->F2_CHVNFE  ,;  //--Chave NF
                                                dSF2Emiss               ,;  //--Dt Emissão Nota Fiscal
                                                (cAliasTRB)->F2_COND    ,;
                                                (cAliasTRB)->E4_DESCRI  ,;                                                        
                                                dSE1Emiss               ,;  //--Dt Emissão Tit.
                                                dSE1Venct               ,;  //--Dt Vencimento Tit.
                                                dSE1Baixa               ,;  //--Dt Baixa Financeira  
                                                (cAliasTRB)->E1_VALOR   ,;  //--Valor Tit.
                                                (cAliasTRB)->E1_PARCELA ,;  //--Parcela
                                                (cAliasTRB)->E1_SALDO   ,;  //--Saldo
                                                (cAliasTRB)->A1_CGC     ,;  //--CPF/CNPJ
                                                (cAliasTRB)->A1_NOME    ,;  //--Nome
                                                (cAliasTRB)->A1_MUN     ,;  //--Municipio
                                                (cAliasTRB)->A1_EST     ,;  //--Estado
                                                cSD1NFOri               ,;  //--Devolução
                                                (cAliasTRB)->D1_DOC     ,;  //--NF Devolucao
                                                (cAliasTRB)->D1_SERIE   ,;  //--Serie NF Devolucao
												dSD1Emiss               ,;  //--Dt NF Devolucao
												(cAliasTRB)->VRK_CODMAR ,;  //--Cód. Marca
												(cAliasTRB)->A1_NREDUZ })   //--Nome Fantasia
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
