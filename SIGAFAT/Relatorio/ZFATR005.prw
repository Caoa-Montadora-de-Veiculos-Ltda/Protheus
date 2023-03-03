#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"

/*
=====================================================================================
Programa.:              ZFATR005
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              12/03/20
Descricao / Objetivo:   Relatorio Faturamento Floor Plan
Doc. Origem:            
Solicitante:            Renato Mariano
Uso......:              
Obs......:
=====================================================================================
*/
User Function ZFATR005() // u_ZFATR005()
	Local aPergs   		:= {}
    Local lRet          := .F.
    Local cExtens       := "Arquivo XML | *.XML"
	Local cTitulo	    := "Escolha o caminho para salvar o arquivo!"
	Local cMainPath     := "\"
	Local cArquivo	    := ""

    Private bVldDt      := {|| lRet := Empty(MV_PAR05) .And. Empty(MV_PAR07),; 
                        IIF( !lRet,; 
                        ( MV_PAR01 :=  CtoD(''),; 
                            MV_PAR02 :=  CtoD('') ),;
                        Nil ),;
                        lRet }
    
    Private bVldCli     := {|| lRet := Empty(MV_PAR05) .And. Empty(MV_PAR07),; 
                            IIF( !lRet,; 
                            ( MV_PAR03 :=  Space( TamSX3('A1_COD')[1] ) ),;
                            Nil ),;
                            lRet }

    Private bVldLoj     := {|| lRet := Empty(MV_PAR05) .And. Empty(MV_PAR07),; 
                            IIF( !lRet,; 
                            ( MV_PAR04 :=  Space( TamSX3('A1_LOJA')[1] ) ),;
                            Nil ),;
                            lRet }

    Private aRet        := {}

    aAdd(aPergs, {1 ,"Dt Emissão De (Faturamento) " ,CtoD('')                           ,""	        ,".T."	,""	    ,"Eval(bVldDt)"	    ,50	    ,.F.    })
    aAdd(aPergs, {1 ,"Dt Emissão Até (Faturamento)" ,CtoD('')	                        ,""	        ,".T."	,""	    ,"Eval(bVldDt)"	    ,50	    ,.F.    })
    aAdd(aPergs, {1 ,"Cliente"                      ,Space( TamSX3('A1_COD')[1] )       ,""         ,""     ,"SA1"  ,"Eval(bVldCli)"    ,0      ,.F.    })
    aAdd(aPergs, {1 ,"Loja"                         ,Space( TamSX3('A1_LOJA')[1] )      ,""         ,""     ,""     ,"Eval(bVldLoj)"    ,0      ,.F.    })
    aAdd(aPergs, {1 ,"Num. NF"                      ,Space( TamSX3('VV0_NUMNFI')[1] )   ,""         ,""     ,"VV0"  ,""                 ,0      ,.F.    })
    aAdd(aPergs, {1 ,"Serie NF"                     ,Space( TamSX3('VV0_SERNFI')[1] )   ,""         ,""     ,""     ,VV0->VV0_SERNFI    ,0      ,.F.    })
    aAdd(aPergs, {1 ,"Nr. Chassi"                   ,Space( TamSX3('C6_CHASSI')[1] )    ,""	        ,".T."	,""	    ,".T."	            ,80	    ,.F.    })

    If ParamBox( aPergs ,"Parâmetros Rel Fat Floor Plan" ,aRet )
    	cArquivo := cGetFile(cExtens,cTitulo,,cMainPath,.F.)
		If !Empty(cArquivo)
            Processa({|| zRel0005(cArquivo)}	,"Gerando Relatório Faturamento Floor Plan..."	)
        EndIf
    EndIf


Return()

/*
=====================================================================================
Programa.:              zRel0005
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              12/03/2020
Descricao / Objetivo:   Gera Excel 
Doc. Origem:            
Uso......:              ZFATR005
Obs......:
=====================================================================================
*/
Static Function zRel0005(cArquivo)

	Local cQuery		:= ""
	Local cAliasTRB		:= GetNextAlias()
	Local cAba1			:= "Faturamento Floor Plan"
	Local cTabela1		:= "Relação Faturamento Floor Plan"
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

	cQuery := " SELECT " + CRLF
    cQuery += "     VV1_CORVEI, " + CRLF
    cQuery += "     VX5_DESCRI, " + CRLF
    cQuery += "     SUBSTR(VVC_DESCRI,1,20) AS COR, " + CRLF
    cQuery += "     C6_CHASSI, " + CRLF
    cQuery += "     VV1_NUMMOT, " + CRLF
    cQuery += "     VV1_MODVEI, " + CRLF
    cQuery += "     VV1_SEGMOD, " + CRLF
    cQuery += "     VV2_MODFAB, " + CRLF
    cQuery += "     SUBSTR(VV1_FABMOD,5,8) AS ANO_MOD, " + CRLF
    cQuery += "     SUBSTR(VV1_FABMOD,1,4) AS ANO_FAB, " + CRLF
    cQuery += "     F2_DOC, " + CRLF
    cQuery += "     F2_VALFAT, " + CRLF
    cQuery += "     F2_EMISSAO, " + CRLF
    cQuery += "     A1_NOME, " + CRLF
    cQuery += "     A1_CGC, " + CRLF
    cQuery += "     A1_END, " + CRLF
	cQuery += "     E1_BAIXA, " + CRLF
    cQuery += "     F2_CHVNFE, " + CRLF
    cQuery += "     CASE " + CRLF
    cQuery += "         WHEN VRK_CODMAR = 'CHE' THEN 'CHERY' " + CRLF
    cQuery += "         WHEN VRK_CODMAR = 'HYU' THEN 'HYUNDAI' " + CRLF
    cQuery += "         WHEN VRK_CODMAR = 'SBR' THEN 'SUBARU' " + CRLF
    cQuery += "         WHEN VRK_CODMAR = 'OUT' THEN 'OUTROS' " + CRLF
    cQuery += "     END AS MARCA " + CRLF

	cQuery += " FROM " + RetSQLName('VRJ') + " VRJ " + CRLF

	cQuery += " INNER JOIN " + RetSQLName('VRK') + " VRK " + CRLF
	cQuery += "     ON VRK_FILIAL = '" + FWxFilial('VRK') + "' " + CRLF	
	cQuery += "     AND VRK_PEDIDO = VRJ_PEDIDO " + CRLF
	cQuery += "     AND VRK.D_E_L_E_T_ = ' ' " + CRLF

    cQuery += " INNER JOIN " + RetSQLName('VV0') + " VV0 " + CRLF
    cQuery += "     ON VV0_FILIAL = '" + FWxFilial('VV0') + "' " + CRLF
    cQuery += "     AND VV0_NUMTRA = VRK_NUMTRA " + CRLF
	cQuery += "     AND VV0.D_E_L_E_T_ = ' ' " + CRLF

    If Empty( aRet[5] )
        If  !Empty( aRet[1] )
            cQuery += "     AND VV0_DATEMI BETWEEN '" + DToS( aRet[1] ) + "' AND '" + DToS( aRet[2] ) + "' " + CRLF
        EndIf 
    Else 
        cQuery += "     AND VV0_NUMNFI = '" + aRet[5] + "' " + CRLF
        cQuery += "     AND VV0_SERNFI = '" + aRet[6] + "' " + CRLF
    EndIf

    cQuery += " INNER JOIN " + RetSQLName('SF2') + " SF2 " + CRLF
    cQuery += "     ON F2_FILIAL = '" + FWxFilial('SF2') + "' " + CRLF	
	cQuery += "     AND F2_DOC = VV0_NUMNFI " + CRLF
	cQuery += "     AND F2_SERIE = VV0_SERNFI " + CRLF
    cQuery += "     AND F2_CLIENTE = VV0_CODCLI " + CRLF
    cQuery += "     AND F2_LOJA = VV0_LOJA " + CRLF
	cQuery += "     AND SF2.D_E_L_E_T_ = ' ' " + CRLF

    cQuery += " INNER JOIN " + RetSQLName('SD2') + " SD2 " + CRLF
    cQuery += "		ON SD2.D2_FILIAL = '" + FWxFilial('SD2') + "' " + CRLF
	cQuery += "		AND SD2.D2_DOC = SF2.F2_DOC   " + CRLF
	cQuery += "		AND SD2.D2_SERIE = SF2.F2_SERIE   " + CRLF
	cQuery += "		AND SD2.D2_CLIENTE = SF2.F2_CLIENTE   " + CRLF
	cQuery += "		AND SD2.D2_LOJA = SF2.F2_LOJA   " + CRLF
	cQuery += "		AND SD2.D2_EMISSAO = SF2.F2_EMISSAO   " + CRLF
	cQuery += "		AND SD2.D_E_L_E_T_ = ' '   " + CRLF

	cQuery += " INNER JOIN " + RetSQLName("SC6") + " SC6 " + CRLF
	cQuery += "		ON SC6.C6_FILIAL = '" + FWxFilial('SC6') + "' " + CRLF
	cQuery += "		AND SC6.C6_NUM = SD2.D2_PEDIDO  " + CRLF
	cQuery += "		AND SC6.C6_ITEM = SD2.D2_ITEM  " + CRLF
	cQuery += "		AND SC6.C6_PRODUTO = SD2.D2_COD " + CRLF
	cQuery += "     AND SC6.D_E_L_E_T_ = ' '   " + CRLF
	
    If !Empty( aRet[7] )
        cQuery += "     AND SC6.C6_CHASSI = '" + aRet[7] + "' " + CRLF
    EndIf

    cQuery += " INNER JOIN " + RetSQLName('VV1') + " VV1 " + CRLF
    cQuery += "     ON VV1_FILIAL = '" + FWxFilial('VV1') + "' " + CRLF
    cQuery += "     AND VV1_CHAINT = VRK_CHAINT " + CRLF
    cQuery += "     AND VV1.D_E_L_E_T_ = ' ' " + CRLF

    cQuery += " INNER JOIN " + RetSQLName('VV2') + " VV2 " + CRLF
    cQuery += "     ON VV2_FILIAL = '" + FWxFilial('VV2') + "' " + CRLF
    cQuery += "     AND VV2_CODMAR = VV1_CODMAR " + CRLF
    cQuery += "     AND VV2_MODVEI = VV1_MODVEI " + CRLF
    cQuery += "     AND VV2_SEGMOD = VV1_SEGMOD " + CRLF
    cQuery += "     AND VV1.D_E_L_E_T_ = ' ' " + CRLF

    cQuery += " INNER JOIN " + RetSQLName('VVC') + " VVC " + CRLF
    cQuery += "     ON VVC_FILIAL = '" + FWxFilial('VVC') + "' " + CRLF
    cQuery += "     AND VVC_CODMAR = VV1_CODMAR " + CRLF
    cQuery += "     AND VVC_CORVEI = VV1_CORVEI " + CRLF
    cQuery += "     AND VVC.D_E_L_E_T_ = ' ' " + CRLF

    cQuery += " INNER JOIN " + RetSQLName('SA1') + " SA1 " + CRLF
    cQuery += "     ON A1_FILIAL = '" + FWxFilial('SA1') + "' " + CRLF
    cQuery += "     AND A1_COD = VV0_CODCLI " + CRLF
    cQuery += "     AND A1_LOJA = VV0_LOJA " + CRLF
    cQuery += "     AND SA1.D_E_L_E_T_ = ' ' " + CRLF
	
	cQuery += " INNER JOIN " + RetSQLName('SE1') + " SE1 "  + CRLF
    cQuery += "         ON E1_FILIAL = '" + FWxFilial('SE1') + "' " + CRLF	
	cQuery += "         AND E1_CLIENTE = VV0_CODCLI " + CRLF
    cQuery += "         AND E1_LOJA = VV0_LOJA " + CRLF
    cQuery += "         AND E1_PREFIXO = VV0_SERNFI " + CRLF
    cQuery += "         AND E1_NUM = VV0_NUMNFI " + CRLF
	cQuery += " 	    AND SE1.D_E_L_E_T_ = ' ' " + CRLF

    cQuery += " INNER JOIN " + RetSQLName('VX5') + " VX5 " + CRLF
    cQuery += "     ON VX5.VX5_FILIAL = '" + FWxFilial('VX5') + "' " + CRLF
    //-- Tabela Genérica SIGAVEI <-> Cód 076 - Tipos de combustiveis		
	cQuery += "     AND VX5.VX5_CHAVE = '076' " + CRLF
	cQuery += "     AND VX5.VX5_CODIGO = VV1_COMVEI " + CRLF
	cQuery += "     AND VX5.D_E_L_E_T_ = ' ' " + CRLF

	cQuery += " WHERE VRJ_FILIAL = '" + FWxFilial('VRJ') + "' " + CRLF
	cQuery += "     AND VRJ_NATURE IN " + FormatIn(SuperGetMV("CMV_VEI005", ,"1101" ), "/") + CRLF
    cQuery += "     AND VRJ_STATUS IN " + FormatIn(SuperGetMV("CMV_VEI006", ,"F" ), "/") + CRLF
    cQuery += "     AND VRJ_FORPAG IN " + FormatIn(SuperGetMV("CMV_VEI007", ,"005" ), "/") + CRLF

    If !Empty(aRet[3])
        cQuery += "     AND VRJ_CODCLI = '" + aRet[3] + "' " + CRLF
        cQuery += "     AND VRJ_LOJA = '" + aRet[4] + "' " + CRLF
    EndIf  

	cQuery += "     AND VRJ.D_E_L_E_T_ = ' ' " + CRLF

    cQuery += " GROUP BY " + CRLF
    cQuery += "     VV1_CORVEI, " + CRLF
    cQuery += "     VX5_DESCRI, " + CRLF
    cQuery += "     VVC_DESCRI, " + CRLF
    cQuery += "     C6_CHASSI, " + CRLF
    cQuery += "     VV1_NUMMOT, " + CRLF
    cQuery += "     VV1_MODVEI, " + CRLF
    cQuery += "     VV1_SEGMOD, " + CRLF
    cQuery += "     VV2_MODFAB, " + CRLF
    cQuery += "     VV1_FABMOD, " + CRLF
    cQuery += "     F2_DOC, " + CRLF
    cQuery += "     F2_VALFAT, " + CRLF
    cQuery += "     F2_EMISSAO, " + CRLF
    cQuery += "     A1_NOME, " + CRLF
    cQuery += "     A1_CGC, " + CRLF
    cQuery += "     A1_END, " + CRLF
	cQuery += "     E1_BAIXA, " + CRLF
    cQuery += "     F2_CHVNFE, " + CRLF
    cQuery += "     VRK_CODMAR " + CRLF

	cQuery += " ORDER BY F2_EMISSAO, F2_DOC, A1_CGC " + CRLF

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
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nome_montadora"               ,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cnpj_montadora"               ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Marca"			            ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Combustivel"  	            ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Código do Modelo"             ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Segmento"                     ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cor Veiculo"		            ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Descrição Cor"                ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Chassi"                       ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Motor"                        ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Renavam"                      ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Ano_modelo"                   ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Ano_fabricação"               ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nota Fiscal"                  ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor"                        ,3	,2	,.F.	) // Right - Number
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Emissão"                      ,2	,4	,.F.	) // Center - Data
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nome Concessionaria"          ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cnpj"                         ,1	,1	,.F.	) // Left - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Endereço"                     ,1	,1	,.F.	) // Left - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt Baixa Financeira"          ,2	,4	,.F.	) // Center - Data
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Chave NFe"                    ,1	,1	,.F.	) // Left - Texto
		
		// Conta quantos registros existem, e seta no tamanho da régua.
		ProcRegua( nTotReg )

		DbSelectArea((cAliasTRB))
		(cAliasTRB)->(dbGoTop())
		While (cAliasTRB)->(!EoF())

			// Incrementa a mensagem na régua.
			IncProc("Exportando informações para Excel...")

			oFWMSExcel:AddRow( cAba1	,cTabela1	,{ 	AllTrim( SM0->M0_FILIAL ),;    //--Nome_montadora
														Transform( AllTrim( SM0->M0_CGC ), "@R 99.999.999/9999-99" ),;    //--Cnpj_montadora
                                                        (cAliasTRB)->MARCA,;    //--Marca	
                                                        (cAliasTRB)->VX5_DESCRI,;    //--Combustivel
                                                        (cAliasTRB)->VV1_MODVEI,;    //--Código do Modelo
                                                        (cAliasTRB)->VV1_SEGMOD,;    //--Segmento
                                                        (cAliasTRB)->VV1_CORVEI,;    //--Cor Veiculo    	
                                                        (cAliasTRB)->COR,;    //--Descrição Cor
                                                        (cAliasTRB)->C6_CHASSI,;    //--Chassi       
                                                        (cAliasTRB)->VV1_NUMMOT,;    //--Motor
                                                        (cAliasTRB)->VV2_MODFAB,;    //--Renavam             
                                                        (cAliasTRB)->ANO_MOD,;    //--Ano_modelo               
                                                        (cAliasTRB)->ANO_FAB,;    //--Ano_fabricação
                                                        (cAliasTRB)->F2_DOC,;    //--Nota Fiscal
                                                        (cAliasTRB)->F2_VALFAT,;    //--Valor
                                                        IIF( Empty( SToD( (cAliasTRB)->F2_EMISSAO ) ), "", SToD( (cAliasTRB)->F2_EMISSAO ) ),;    //--Emissão
                                                        (cAliasTRB)->A1_NOME,;    //--Nome Concessionaria
                                                        (cAliasTRB)->A1_CGC,;    //--Cnpj
                                                        (cAliasTRB)->A1_END,;    //--Endereço
														IIF( Empty( SToD( (cAliasTRB)->E1_BAIXA ) ), "", SToD( (cAliasTRB)->E1_BAIXA ) ),;    //--Dt Baixa Financeira
                                                        (cAliasTRB)->F2_CHVNFE })    //--Chave NFe
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