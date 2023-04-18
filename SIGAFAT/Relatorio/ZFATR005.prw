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

	cQuery := CRLF + " SELECT "
    cQuery += CRLF + "      VV1.VV1_CORVEI, "
    cQuery += CRLF + "      SUBSTR(VX5.VX5_DESCRI,1,10) AS VX5_DESCRI, "
    cQuery += CRLF + "      SUBSTR(VVC.VVC_DESCRI,1,20) AS COR, "
    cQuery += CRLF + "      SC6.C6_CHASSI, "
    cQuery += CRLF + "      VV1.VV1_NUMMOT, "
    cQuery += CRLF + "      VV1.VV1_MODVEI, "
    cQuery += CRLF + "      VV1.VV1_SEGMOD, "
    cQuery += CRLF + "      VV2.VV2_MODFAB, "
    cQuery += CRLF + "      SUBSTR(VV1.VV1_FABMOD,5,8) AS ANO_MOD, "
    cQuery += CRLF + "      SUBSTR(VV1.VV1_FABMOD,1,4) AS ANO_FAB, "
    cQuery += CRLF + "      SF2.F2_DOC, "
    cQuery += CRLF + "      SF2.F2_VALFAT, "
    cQuery += CRLF + "      SF2.F2_EMISSAO, "
    cQuery += CRLF + "      SA1.A1_NOME, "
    cQuery += CRLF + "      SA1.A1_CGC, "
    cQuery += CRLF + "      SA1.A1_END, "
    cQuery += CRLF + "      SE1.E1_BAIXA, "
    cQuery += CRLF + "      SF2.F2_CHVNFE, "
    cQuery += CRLF + "      CASE "
    cQuery += CRLF + "          WHEN NVL(VRK.VRK_CODMAR,SC6.C6_XCODMAR) = 'CHE' THEN 'CHERY' "
    cQuery += CRLF + "          WHEN NVL(VRK.VRK_CODMAR,SC6.C6_XCODMAR) = 'HYU' THEN 'HYUNDAI' "
    cQuery += CRLF + "          WHEN NVL(VRK.VRK_CODMAR,SC6.C6_XCODMAR) = 'SBR' THEN 'SUBARU' "
    cQuery += CRLF + "          WHEN NVL(VRK.VRK_CODMAR,SC6.C6_XCODMAR) = 'OUT' THEN 'OUTROS' "
    cQuery += CRLF + "          WHEN NVL(VRK.VRK_CODMAR,SC6.C6_XCODMAR) = '   ' THEN 'INDEFINIDO'"
    cQuery += CRLF + "          ELSE 'VERIFICAR'"
    cQuery += CRLF + "      END AS MARCA"
    
    cQuery += CRLF + " FROM " + RetSQLName('SE1') + " SE1"
    
    cQuery += CRLF + " 	JOIN " + RetSQLName('SF2') + " SF2  "
    cQuery += CRLF + "         ON  SF2.F2_FILIAL  = '" + FWxFilial('SF2') + "'  "
    cQuery += CRLF + "         AND SF2.F2_DOC     = SE1.E1_NUM  "
    cQuery += CRLF + "         AND SF2.F2_SERIE   = SE1.E1_PREFIXO  "
    cQuery += CRLF + "         AND SF2.F2_CLIENTE = SE1.E1_CLIENTE  "
    cQuery += CRLF + "         AND SF2.F2_LOJA    = SE1.E1_LOJA"
    cQuery += CRLF + "         AND SF2.F2_COND     IN " + FormatIn(SuperGetMV("CMV_VEI007", ,"005" ), "/")
    cQuery += CRLF + "         AND SF2.D_E_L_E_T_ = ' ' "
    
    cQuery += CRLF + " 	JOIN " + RetSQLName('SD2') + " SD2 "
    cQuery += CRLF + "         ON  SD2.D2_FILIAL  = '" + FWxFilial('SD2') + "' "
    cQuery += CRLF + "         AND SD2.D2_DOC     = SF2.F2_DOC  "
    cQuery += CRLF + "         AND SD2.D2_SERIE   = SF2.F2_SERIE  "
    cQuery += CRLF + "         AND SD2.D2_CLIENTE = SF2.F2_CLIENTE  "
    cQuery += CRLF + "         AND SD2.D2_LOJA    = SF2.F2_LOJA "
    cQuery += CRLF + "         AND SD2.D2_NUMSERI <>  ' ' "
    cQuery += CRLF + "         AND SD2.D_E_L_E_T_ = ' ' "
    
    cQuery += CRLF + " 	JOIN " + RetSQLName('SA1') + " SA1  "
    cQuery += CRLF + "         ON  SA1.A1_FILIAL  = '" + FWxFilial('SA1') + "'  "
    cQuery += CRLF + "         AND SA1.A1_COD     = SE1.E1_CLIENTE "
    cQuery += CRLF + "         AND SA1.A1_LOJA    = SE1.E1_LOJA  "
    cQuery += CRLF + "   	   AND SA1.D_E_L_E_T_ = ' '  "
    
    cQuery += CRLF + " 	JOIN " + RetSQLName('SC6') + " SC6  "
    cQuery += CRLF + " 		   ON  SC6.C6_FILIAL   = '" + FWxFilial('SC6') + "' "
    cQuery += CRLF + "  	   AND SC6.C6_NUM      = SD2.D2_PEDIDO  "
    cQuery += CRLF + "  	   AND SC6.C6_ITEM     = SD2.D2_ITEMPV"
    cQuery += CRLF + " 		   AND SC6.C6_PRODUTO  = SD2.D2_COD"
    cQuery += CRLF + "  	   AND SC6.D_E_L_E_T_  = ' '  "
    
    If !Empty( aRet[7] )
        cQuery +=  CRLF + "     AND SC6.C6_CHASSI = '" + aRet[7] + "' " 
    EndIf
    
    cQuery += CRLF + " 	JOIN " + RetSQLName('SC5') + " SC5  "
    cQuery += CRLF + "         ON  SC5.C5_FILIAL  = '" + FWxFilial('SC5') + "'  "
    cQuery += CRLF + "         AND SC5.C5_NUM     = SC6.C6_NUM "
    cQuery += CRLF + "         AND SC5.D_E_L_E_T_ = ' ' "
    
    cQuery += CRLF + " 	LEFT JOIN " + RetSQLName('VV0') + " VV0  "
    cQuery += CRLF + "         ON  VV0.VV0_FILIAL = '" + FWxFilial('VV0') + "'  "
    cQuery += CRLF + "         AND VV0.VV0_CODCLI = SE1.E1_CLIENTE  "
    cQuery += CRLF + "         AND VV0.VV0_LOJA   = SE1.E1_LOJA  "
    cQuery += CRLF + "         AND VV0.VV0_SERNFI = SE1.E1_PREFIXO  "
    cQuery += CRLF + "         AND VV0.VV0_NUMNFI = SE1.E1_NUM  "
    cQuery += CRLF + " 		   AND VV0.D_E_L_E_T_ = ' '"
    
    cQuery += CRLF + " 	LEFT JOIN " + RetSQLName('VV1') + " VV1   "
    cQuery += CRLF + "  	   ON  VV1.VV1_FILIAL = '" + FWxFilial('VV1') + "'  "
    cQuery += CRLF + "         AND VV1.VV1_CHASSI = SD2.D2_NUMSERI  "
    cQuery += CRLF + "         AND VV1.D_E_L_E_T_ = ' '  "
    
    cQuery += CRLF + " 	LEFT JOIN " + RetSQLName('VV2') + " VV2    "
    cQuery += CRLF + "         ON  VV2.VV2_FILIAL  = '" + FWxFilial('VV2') + "'  "
    cQuery += CRLF + "         AND VV2.VV2_CODMAR  = VV1.VV1_CODMAR    "
    cQuery += CRLF + "         AND VV2.VV2_MODVEI  = VV1.VV1_MODVEI   "
    cQuery += CRLF + "         AND VV2.VV2_SEGMOD  = VV1.VV1_SEGMOD   "
    cQuery += CRLF + "         AND VV2.D_E_L_E_T_  = ' '  "
    
    cQuery += CRLF + " 	LEFT JOIN " + RetSQLName('VRK') + " VRK  "
    cQuery += CRLF + "         ON  VRK.VRK_FILIAL  = '" + FWxFilial('VRK') + "'  "
    cQuery += CRLF + "         AND VRK.VRK_NUMTRA  = VV0.VV0_NUMTRA"
    cQuery += CRLF + " 	       AND VRK.D_E_L_E_T_  = ' '"
    
    cQuery += CRLF + " 	LEFT JOIN " + RetSQLName('VVC') + " VVC "
    cQuery += CRLF + " 		   ON  VVC.VVC_FILIAL = '" + FWxFilial('VVC') + "' "
    cQuery += CRLF + " 		   AND VVC.VVC_CODMAR = VV1.VV1_CODMAR "
    cQuery += CRLF + " 		   AND VVC.VVC_CORVEI = VV1.VV1_CORVEI "
    cQuery += CRLF + " 		   AND VVC.D_E_L_E_T_ = ' ' 		"
    
    cQuery += CRLF + " 	LEFT JOIN  " + RetSQLName('VRJ') + " VRJ "
    cQuery += CRLF + "    	   ON  VRJ.VRJ_FILIAL  = '" + FWxFilial('VRJ') + "' "
    cQuery += CRLF + "     	   AND (VRJ.VRJ_PEDIDO = VRK.VRK_PEDIDO OR VRJ.VRJ_PEDCOM = SC6.C6_PEDCLI)"
    cQuery += CRLF + "         AND VRJ.VRJ_STATUS  IN " + FormatIn(SuperGetMV("CMV_VEI006", ,"F" ), "/")
    cQuery += CRLF + "         AND VRJ.D_E_L_E_T_  = ' ' "
    
    cQuery += CRLF + " 	LEFT JOIN " + RetSQLName('VX5') + " VX5 "
    cQuery += CRLF + " 		   ON VX5.VX5_FILIAL  = '" + FWxFilial('VX5') + "' "
    cQuery += CRLF + " 		   AND VX5.VX5_CHAVE  = '076' "
    cQuery += CRLF + " 		   AND VX5.VX5_CODIGO = VV1.VV1_COMVEI "
    cQuery += CRLF + " 		   AND VX5.D_E_L_E_T_ = ' '"
    
    cQuery += CRLF + " WHERE SE1.E1_FILIAL = '" + FWxFilial('SE1') + "' "
    cQuery += CRLF + "     AND SE1.E1_NATUREZ IN " + FormatIn(SuperGetMV( "CMV_VEI005", ,"1101" ), "/" )
    
    If !Empty(aRet[3])
        cQuery += CRLF + "     AND SE1.E1_CLIENTE = '" + aRet[3] + "' "
        cQuery += CRLF + "     AND SE1.E1_LOJA    = '" + aRet[4] + "' "
    EndIf  
    
    If Empty( aRet[5] )
        If  !Empty( aRet[1] )
            cQuery += CRLF + "     AND SE1.E1_EMISSAO BETWEEN '" + DToS( aRet[1] ) + "' AND '" + DToS( aRet[2] ) + "' "
        EndIf 
    Else 
        cQuery += CRLF + "     AND SE1.E1_NUM    = '" + aRet[5] + "' "
        cQuery += CRLF + "     AND SE1.E1PREFIXO = '" + aRet[6] + "' "
    EndIf

    cQuery += CRLF + " GROUP BY "
    cQuery += CRLF + "      VV1.VV1_CORVEI, "
    cQuery += CRLF + "      VX5.VX5_DESCRI, "
    cQuery += CRLF + "      VVC.VVC_DESCRI, "
    cQuery += CRLF + "      SC6.C6_CHASSI, "
    cQuery += CRLF + "      VV1.VV1_NUMMOT, "
    cQuery += CRLF + "      VV1.VV1_MODVEI, "
    cQuery += CRLF + "      VV1.VV1_SEGMOD, "
    cQuery += CRLF + "      VV2.VV2_MODFAB, "
    cQuery += CRLF + "      VV1.VV1_FABMOD, "
    cQuery += CRLF + "      SF2.F2_DOC, "
    cQuery += CRLF + "      SF2.F2_VALFAT, "
    cQuery += CRLF + "      SF2.F2_EMISSAO, "
    cQuery += CRLF + "      SA1.A1_NOME, "
    cQuery += CRLF + "      SA1.A1_CGC, "
    cQuery += CRLF + "      SA1.A1_END, "
    cQuery += CRLF + "      SE1.E1_BAIXA, "
    cQuery += CRLF + "      SF2.F2_CHVNFE, "
    cQuery += CRLF + "      VRK.VRK_CODMAR,"
    cQuery += CRLF + "      SC6.C6_XCODMAR"
    cQuery += CRLF + "  ORDER BY F2_EMISSAO, F2_DOC, A1_CGC "

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
