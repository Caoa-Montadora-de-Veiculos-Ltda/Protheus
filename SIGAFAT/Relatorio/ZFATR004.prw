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
	Private cCfop		:= SuperGetMv('CMV_FAT010',.F.,'') //Parametro com as CFOP que serão ignorados pelo relatorio
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
    aAdd(aPergs, {2 ,"Situaçãp dos titulos"         ,"Ambos"                            ,aCombo     ,50     ,""     ,.F.                                })
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

    /*
	If !ApOleClient( "MSExcel" )
		MsgAlert( "Microsoft Excel n„o instalado!!" )
		Return
	EndIf
    */
	If Select( (cAliasTRB) ) > 0
		(cAliasTRB)->(DbCloseArea())
	EndIf

	cQuery := fQuery()
	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

	DbSelectArea((cAliasTRB))
	nTotReg := Contar(cAliasTRB,"!Eof()")
	(cAliasTRB)->(dbGoTop())
	If (cAliasTRB)->(!Eof())

		// Criando o objeto que ir· gerar o conte?do do Excel.
		oFWMsExcel := FWMSExcelEx():New()

		// Aba 01
		oFWMsExcel:AddworkSheet(cAba1) // N„o utilizar n?mero junto com sinal de menos. Ex.: 1-.

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
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Forma. Pagto"                 ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Desc. Forma. Pagto"           ,1	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt Emissão Tit."              ,2	,4	,.F.	) // Center - Data
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt Vencimento Tit."           ,2	,4	,.F.	) // Center - Data
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Dt Baixa Financeira"          ,2	,4	,.F.	) // Center - Data
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Valor Tit."                   ,3	,2	,.F.	) // Right - Number
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Parcela"                      ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Saldo"                        ,3	,2	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"CPF/CNPJ"                     ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nome"                         ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Municipio"                    ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Estado"                       ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Devolução"                    ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"NF Devolucao"                 ,2	,1	,.F.	) // Center - Texto
        oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Serie NF Devolução"           ,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Data NF Devolução"            ,2	,4	,.F.	) // Center - Data
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Cód. Marca"                   ,2	,1	,.F.	) // Center - Texto
		oFWMsExcel:AddColumn( cAba1	,cTabela1	,"Nome Fantasia"                ,2	,1	,.F.	) // Center - Texto
		
		// Conta quantos registros existem, e seta no tamanho da rÈgua.
		ProcRegua( nTotReg )

		DbSelectArea((cAliasTRB))
		(cAliasTRB)->(dbGoTop())
		While (cAliasTRB)->(!EoF())

			// Incrementa a mensagem na rÈgua.
			IncProc("Exportando informaÁ?es para Excel...")

			oFWMSExcel:AddRow( cAba1	,cTabela1	,{ 	IIF( !EMPTY((cAliasTRB)->VRJ_PEDIDO) , (cAliasTRB)->VRJ_PEDIDO , (cAliasTRB)->D2_PEDIDO ),;    //--Num. Pedido
														(cAliasTRB)->VV3_DESCRI,;    //--Rede
                                                        (cAliasTRB)->VRK_CHASSI,;    //--Chassi
                                                        (cAliasTRB)->VV2_OPCION,;    //--Opcional	
                                                        (cAliasTRB)->VX5_DESCRI,;    //--Descr. Opcional	
                                                        (cAliasTRB)->COREXT,;    //--Descr. Cor Externa
                                                        IIF(!Empty( (cAliasTRB)->VRK_MODVEI ) , (cAliasTRB)->VRK_MODVEI , (cAliasTRB)->C6_XMODVEI ) ,;    //--Modelo           
                                                        IIF(!Empty( (cAliasTRB)->VRK_FABMOD ) , (cAliasTRB)->VRK_FABMOD , (cAliasTRB)->C6_XFABMOD ) ,;    //--Ano Fabr/Mod
                                                        (cAliasTRB)->VV0_NUMNFI,;    //--Numero NF             
                                                        (cAliasTRB)->VV0_SERNFI,;    //--Serie NF                
                                                        IIF( Empty( SToD( (cAliasTRB)->VV0_DATEMI ) ), "", SToD( (cAliasTRB)->VV0_DATEMI ) ),;    //--Dt Emiss„o Pedido
                                                        (cAliasTRB)->VRK_VALTAB,;    //--Vlr Tabela
                                                        (cAliasTRB)->F2_VALFAT,;    //--Vlr Faturado
                                                        (cAliasTRB)->F2_CHVNFE,;    //--Chave NF
                                                        IIF( Empty( SToD( (cAliasTRB)->F2_EMISSAO ) ), "", SToD( (cAliasTRB)->F2_EMISSAO ) ),;  //--Dt Emiss„o Nota Fiscal
                                                        (cAliasTRB)->VRJ_FORPAG,;
                                                        (cAliasTRB)->E4_DESCRI,;
														(cAliasTRB)->VRL_XFORPA,;
														(cAliasTRB)->DESCRI,;                                                        
                                                        IIF( Empty( SToD( (cAliasTRB)->E1_EMISSAO ) ), "", SToD( (cAliasTRB)->E1_EMISSAO ) ),;    //--Dt Emiss„o Tit.
                                                        IIF( Empty( SToD( (cAliasTRB)->E1_VENCTO  ) ), "", SToD( (cAliasTRB)->E1_VENCTO  ) ),;    //--Dt Vencimento Tit.
                                                        IIF( Empty( SToD( (cAliasTRB)->E1_BAIXA   ) ), "", SToD( (cAliasTRB)->E1_BAIXA   ) ),;    //--Dt Baixa Financeira  
                                                        (cAliasTRB)->E1_VALOR,;    //--Valor Tit.
                                                        (cAliasTRB)->E1_PARCELA,;    //--Parcela
                                                        (cAliasTRB)->E1_SALDO,;    //--Saldo
                                                        (cAliasTRB)->A1_CGC,;    //--CPF/CNPJ
                                                        (cAliasTRB)->A1_NOME,;    //--Nome
                                                        (cAliasTRB)->A1_MUN,;   //--Municipio
                                                        (cAliasTRB)->A1_EST,;   //--Estado
                                                        IIF( !Empty( (cAliasTRB)->D1_NFORI ), "Sim", "Não" ),;  //--DevoluÁ„o
                                                        (cAliasTRB)->D1_DOC,;   //--NF Devolucao
                                                        (cAliasTRB)->D1_SERIE,;  //--Serie NF Devolucao
														IIF( Empty( SToD( (cAliasTRB)->D1_EMISSAO ) ), "", SToD( (cAliasTRB)->D1_EMISSAO ) ),;    //--Dt NF Devolucao
														(cAliasTRB)->VV0_CODMAR,;  //--CÛd. Marca
														(cAliasTRB)->A1_NREDUZ })  //--Nome Fantasia
			(cAliasTRB)->(DbSkip())
		EndDo

		// Ativando o arquivo e gerando o xml.
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)

		oFWMsExcel:DeActivate()
		FreeObj(oFWMsExcel)

		// Abrindo o excel e abrindo o arquivo xml.
		oExcel := MsExcel():New()           // Abre uma nova conex„o com Excel.
		oExcel:WorkBooks:Open(cArquivo)     // Abre uma planilha.
		oExcel:SetVisible(.T.)              // Visualiza a planilha.
		oExcel:Destroy()                    // Encerra o processo do gerenciador de tarefas.

	Else
		ApMsgAlert( "Não foi encontrado nenhuma nota fiscal com os parametros informados!!" )
	EndIf

	(cAliasTRB)->(DbCloseArea())

Return()
//-------------------------------------------------
//--------------------------------------------------
Static Function fQuery()
	Local cQuery := ""	

	cQuery += CRLF + " SELECT  DISTINCT "
	cQuery += CRLF + " 			SD2.D2_FILIAL AS E1_FILIAL,   "
	cQuery += CRLF + "          COALESCE(VRK.VRK_PEDIDO, '   ')  AS VRJ_PEDIDO, "
	cQuery += CRLF + "          SD2.D2_PEDIDO ,  "
	cQuery += CRLF + "          SF2.F2_COND AS VRJ_FORPAG,  "
	cQuery += CRLF + "          COALESCE(VV3.VV3_DESCRI,'  ' ) AS VV3_DESCRI,  "
	cQuery += CRLF + "          SD2.D2_NUMSERI AS VRK_CHASSI,  "
	cQuery += CRLF + "          COALESCE( VV2.VV2_OPCION, ' ') AS VV2_OPCION,   "
	cQuery += CRLF + "          COALESCE( VX5.VX5_DESCRI, ' ') AS VX5_DESCRI,   "
	cQuery += CRLF + "          COALESCE(VX5B.VX5_DESCRI, ' ') AS COREXT,  "
	cQuery += CRLF + "          COALESCE(VRK.VRK_MODVEI,VV1.VV1_MODVEI,' ' ) AS VRK_MODVEI,   "
	cQuery += CRLF + "          SC6.C6_XMODVEI,   "
	cQuery += CRLF + "          COALESCE(VRK.VRK_FABMOD, VV1.VV1_FABMOD,' ') AS VRK_FABMOD,   "
	cQuery += CRLF + "          SC6.C6_XFABMOD,   "
	cQuery += CRLF + "          SF2.F2_DOC     AS VV0_NUMNFI,  "
	cQuery += CRLF + "          SF2.F2_SERIE   AS VV0_SERNFI,  "
	cQuery += CRLF + "          SF2.F2_EMISSAO AS VV0_DATEMI,   "
	cQuery += CRLF + "          COALESCE(VRK.VRK_VALTAB, SC6.C6_XPRCTAB) AS VRK_VALTAB ,  "
	cQuery += CRLF + "          SF2.F2_VALFAT,  "
	cQuery += CRLF + "          SF2.F2_CHVNFE,  "
	cQuery += CRLF + "          COALESCE(SE1.E1_EMISSAO,' ') AS E1_EMISSAO,  "
	cQuery += CRLF + "          COALESCE(SE1.E1_VENCTO ,' ') AS E1_VENCTO,  "
	cQuery += CRLF + "          COALESCE(SE1.E1_BAIXA  ,' ') AS E1_BAIXA,  "
	cQuery += CRLF + "          COALESCE(SE1.E1_VALOR  , 0 ) AS E1_VALOR,  "
	cQuery += CRLF + "          COALESCE(SE1.E1_PARCELA,' ') AS E1_PARCELA,   "
	cQuery += CRLF + "          COALESCE(SE1.E1_SALDO  ,0  ) AS E1_SALDO,  "
	cQuery += CRLF + "          SA1.A1_CGC, "
	cQuery += CRLF + "          SA1.A1_NOME, "
	cQuery += CRLF + "          SA1.A1_MUN, "
	cQuery += CRLF + "          SA1.A1_EST, "
	cQuery += CRLF + "          SE4.E4_DESCRI, "
	cQuery += CRLF + "          COALESCE( SD1.D1_NFORI,'         ') AS D1_NFORI, "
	cQuery += CRLF + "          COALESCE( SD1.D1_DOC  ,'         ') AS D1_DOC, "
	cQuery += CRLF + "          COALESCE( SD1.D1_SERIE,'   '      ) AS D1_SERIE, "
	cQuery += CRLF + "          SF2.F2_EMISSAO, "
	cQuery += CRLF + "          COALESCE(VV1.VV1_CODMAR, SC6.C6_XCODMAR) AS VV0_CODMAR,  "
	cQuery += CRLF + "          SA1.A1_NREDUZ, "
	cQuery += CRLF + "          COALESCE( SD1.D1_EMISSAO,'      ') AS D1_EMISSAO,  "
	cQuery += CRLF + "          SD2.D2_COD,	"
	cQuery += CRLF + "          COALESCE (VRL.VRL_XFORPA, '  ') AS VRL_XFORPA,  "
	cQuery += CRLF + "          COALESCE ((SELECT E4.E4_DESCRI FROM " + RetSqlName( "SE4" ) + " E4 WHERE E4.E4_FILIAL = '" + xFilial("SE4") + "' AND  E4.E4_CODIGO = VRL.VRL_XFORPA AND E4.D_E_L_E_T_ = ' ' ), ' ') AS DESCRI  "

	cQuery += CRLF + " FROM " + RetSqlName( "SD2" ) + " SD2 "
	cQuery += CRLF + "		JOIN " + RetSqlName( "SF2" ) + " SF2   "
	cQuery += CRLF + "          ON  SF2.F2_FILIAL  = '" + xFilial("SF2") + "'   "
	cQuery += CRLF + "          AND SF2.F2_DOC     = SD2.D2_DOC   "
	cQuery += CRLF + "          AND SF2.F2_SERIE   = SD2.D2_SERIE "
	cQuery += CRLF + "          AND SF2.F2_CLIENTE = SD2.D2_CLIENTE   "
	cQuery += CRLF + "          AND SF2.F2_LOJA    = SD2.D2_LOJA   "
	cQuery += CRLF + "          AND SF2.D_E_L_E_T_ = ' '  "

	cQuery += CRLF + "		JOIN " + RetSqlName( "SC6" ) + " SC6   "
	cQuery += CRLF + "  		ON  SC6.C6_FILIAL   = '" + xFilial("SC6") + "'  "
	cQuery += CRLF + "  		AND SC6.C6_NUM      = SD2.D2_PEDIDO   "
	cQuery += CRLF + "  		AND SC6.C6_ITEM     = SD2.D2_ITEMPV   "
	cQuery += CRLF + "  		AND SC6.D_E_L_E_T_  = ' '   "

	cQuery += CRLF + "		JOIN " + RetSqlName( "SC5" ) + " SC5   "
	cQuery += CRLF + "          ON  SC5.C5_FILIAL  = '" + xFilial("SC5") + "'   "
	cQuery += CRLF + "          AND SC5.C5_NUM     = SC6.C6_NUM  "
	cQuery += CRLF + "          AND SC5.D_E_L_E_T_ = ' ' "

	cQuery += CRLF + "		JOIN " + RetSqlName( "SA1" ) + " SA1   "
	cQuery += CRLF + "         	ON  SA1.A1_FILIAL = '" + xFilial("SA1") + "'   "
	cQuery += CRLF + "          AND SA1.A1_COD   = SD2.D2_CLIENTE  "
	cQuery += CRLF + "          AND SA1.A1_LOJA  = SD2.D2_LOJA   "
	cQuery += CRLF + "   	    AND SA1.D_E_L_E_T_ = ' '   "

	cQuery += CRLF + " 		JOIN " + RetSqlName( "SE4" ) + " SE4   "
	cQuery += CRLF + "         	ON  SE4.E4_FILIAL  = '" + xFilial("SE4") + "'   "
	cQuery += CRLF + "         	AND SE4.E4_CODIGO  = SF2.F2_COND   "
	cQuery += CRLF + "         	AND SE4.D_E_L_E_T_ = ' '   "

	cQuery += CRLF + "		LEFT JOIN " + RetSqlName( "VV0" ) + " VV0   "
	cQuery += CRLF + "         	ON  VV0.VV0_FILIAL = '" + xFilial("VV0") + "'   "
	cQuery += CRLF + "         	AND VV0.VV0_CODCLI = SD2.D2_CLIENTE   "
	cQuery += CRLF + "         	AND VV0.VV0_LOJA   = SD2.D2_LOJA   "
	cQuery += CRLF + "         	AND VV0.VV0_SERNFI = SD2.D2_SERIE "
	cQuery += CRLF + "         	AND VV0.VV0_NUMNFI = SD2.D2_DOC "
	cQuery += CRLF + "         	AND VV0.D_E_L_E_T_ = ' '      "

	cQuery += CRLF + "		LEFT JOIN " + RetSqlName( "VV1" ) + " VV1    "
	cQuery += CRLF + "         	ON  VV1.VV1_FILIAL = '" + xFilial("VV1") + "'  "
	cQuery += CRLF + "         	AND VV1.VV1_CHASSI = SD2.D2_NUMSERI   "
	cQuery += CRLF + "         	AND VV1.D_E_L_E_T_ = ' '  "

	cQuery += CRLF + " 		LEFT JOIN " + RetSqlName( "VV2" ) + " VV2     "
	cQuery += CRLF + "         	ON  VV2.VV2_FILIAL = '" + xFilial("VV2") + "'  "
	cQuery += CRLF + "         	AND VV2.VV2_CODMAR = VV1.VV1_CODMAR     "
	cQuery += CRLF + "         	AND VV2.VV2_MODVEI = VV1.VV1_MODVEI    "
	cQuery += CRLF + "         	AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD    "
	cQuery += CRLF + "         	AND VV2.D_E_L_E_T_ = ' '   "

	cQuery += CRLF + "   	LEFT JOIN " + RetSqlName( "VRK" ) + " VRK   "
	cQuery += CRLF + "         	ON  VRK.VRK_FILIAL = '" + xFilial("VRK") + "' "
	cQuery += CRLF + "         	AND VRK.VRK_NUMTRA = VV0.VV0_NUMTRA  "
	cQuery += CRLF + "         	AND VRK.D_E_L_E_T_ = ' ' "

	cQuery += CRLF + "   	LEFT JOIN " + RetSqlName( "VRJ" ) + " VRJ  "
	cQuery += CRLF + "         	ON  VRJ.VRJ_FILIAL = VRK.VRK_FILIAL  "
	cQuery += CRLF + "     		AND VRJ.VRJ_PEDIDO = VRK.VRK_PEDIDO  "
	cQuery += CRLF + "         	AND VRJ.D_E_L_E_T_ = ' '   "

	cQuery += CRLF + "		JOIN " + RetSqlName( "VV3" ) + " VV3   "
	cQuery += CRLF + "         	ON  VV3.VV3_FILIAL  = '" + xFilial("VV3") + "'   "
	cQuery += CRLF + "			AND VV3.D_E_L_E_T_  = ' ' "
	cQuery += CRLF + "         	AND (VV3.VV3_TIPVEN = SC5.C5_XTIPVEN OR VV3.VV3_TIPVEN = VRJ.VRJ_TIPVEN) "

	cQuery += CRLF + " 		LEFT JOIN " + RetSqlName( "SD1" ) + " SD1   "
	cQuery += CRLF + "         	ON  SD1.D1_FILIAL  = '" + xFilial("SD1") + "'   "
	cQuery += CRLF + "         	AND SD1.D1_TIPO    = 'D'   "
	cQuery += CRLF + "         	AND SD1.D1_NFORI   = SF2.F2_DOC   "
	cQuery += CRLF + "         	AND SD1.D1_SERIORI = SF2.F2_SERIE   "
	cQuery += CRLF + "         	AND SD1.D_E_L_E_T_ = ' '   "

	cQuery += CRLF + "   	LEFT JOIN " + RetSqlName( "VX5" ) + " VX5  ON  VX5.VX5_FILIAL = '" + xFilial("VX5") + "' AND  VX5.VX5_CHAVE = '068' AND  VX5.VX5_CODIGO = VV2.VV2_OPCION AND  VX5.D_E_L_E_T_ = ' ' "
	cQuery += CRLF + "   	LEFT JOIN " + RetSqlName( "VX5" ) + " VX5B ON VX5B.VX5_FILIAL = '" + xFilial("VX5") + "' AND VX5B.VX5_CHAVE = '067' AND VX5B.VX5_CODIGO = VV2.VV2_COREXT AND VX5B.D_E_L_E_T_ = ' ' "

	cQuery += CRLF + "		LEFT JOIN " + RetSqlName( "SE1" ) + " SE1   "
	cQuery += CRLF + "          ON  SE1.E1_FILIAL  = '" + xFilial("SE1") + "'   "
	cQuery += CRLF + "          AND SE1.E1_NUM     = SD2.D2_DOC   "
	cQuery += CRLF + "          AND SE1.E1_PREFIXO = SD2.D2_SERIE   "
	cQuery += CRLF + "          AND SE1.E1_CLIENTE = SD2.D2_CLIENTE   "
	cQuery += CRLF + "          AND SE1.E1_LOJA    = SD2.D2_LOJA "

	cQuery += CRLF + "		LEFT  JOIN " + RetSqlName( "VRL" ) + " VRL  "
	cQuery += CRLF + "      	ON  VRL.VRL_FILIAL = '" + xFilial("VRL") + "' "
	cQuery += CRLF + "          AND VRL.VRL_PEDIDO = VRK.VRK_PEDIDO "
	cQuery += CRLF + "          AND VRL.VRL_ITEPED = VRK.VRK_ITEPED "
	cQuery += CRLF + "          AND VRL.VRL_E1NUM  = VRK.VRK_PEDIDO "
	cQuery += CRLF + "          AND VRL.VRL_XFORMA = SE1.E1_XFORMA "
	cQuery += CRLF + "          AND VRL.VRL_E1PREF = 'PVM' "
	cQuery += CRLF + "          AND VRL.D_E_L_E_T_ = ' '  "

	cQuery += CRLF + "	WHERE   SD2.D2_FILIAL    = '" + xFilial("SD2") + "' "
	cQuery += CRLF + " 		AND SD2.D_E_L_E_T_   = ' ' "


	If Empty( aRet[6] ) 
		If  !Empty( aRet[1] )   
			cQuery +=  CRLF + "		AND SE1.E1_EMISSAO BETWEEN '" + DToS( aRet[1] ) + "' AND '" + DToS( aRet[2] ) + "' "
		EndIf   
	Else    
		cQuery += CRLF + "		AND SE1.E1_NUM     = '" + aRet[6] + "' "
		cQuery += CRLF + "		AND SE1.E1_PREFIXO = '" + aRet[7] + "' "
	EndIf   

	If !Empty(aRet[3])  
		cQuery += CRLF + "     	AND SD2.D2_CLIENTE = '" + aRet[3] + "' "
		cQuery += CRLF + "     	AND SD2.D2_LOJA    = '" + aRet[4] + "' "
	EndIf   
	
	If aRet[5] == "Em aberto"   
		cQuery += CRLF + "         AND SE1.E1_BAIXA = ' ' "
	ElseIf aRet[5] == "Liquidados"  
		cQuery += CRLF + "         AND SE1.E1_BAIXA <> ' ' "
	EndIf   

	If !Empty( aRet[8] )    
    	cQuery += CRLF + " 	    AND SD2.D2_NUMSERI   = '" + aRet[8] + "' "
    EndIf

	cQuery += CRLF + " ORDER BY 1,2, 11,12 ,25 "


Return cQuery
