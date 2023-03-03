#Include "Protheus.ch"
#Include "Topconn.ch"

/*
=====================================================================================
Programa.:              ZCOMR005
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              23/06/2022
Descricao / Objetivo:   Relatorio de Conferencia
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
User Function ZCOMR005()
    
    Local oReport 
    Local oSection

    Private cAliasTMP := GetNextAlias()

	oReport:= TReport():New("ZCOMR005",;
                            "Entradas Canc.",;
                            Padr("ZCOMR005",10),;
                            {|oReport|  ReportPrint(oReport)},;
                            "Este relatorio realiza a conferencia de Recebimento RgLog")
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
    oReport:HideHeader() //--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter() //--Define que não será impresso o rodapé padrão da página
    oReport:SetDevice(4) //--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    oReport:SetPreview(.T.) //--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2) //--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
    //oReport:SetEdit(.T.) 
	
	//Verifica os parâmetros selecionados via Pergunte
    Pergunte(oReport:GetParam(),.F.)
	
	oSection := TRSection():New(oReport    ,"Colunas"    ,{cAliasTMP}) 
    
    TRCell():New( oSection  ,"F1_TIPO"	        ,cAliasTMP  ,'Tipo da Nota'	                ,PesqPict("SF1","F1_TIPO")      ,TamSx3("F1_TIPO")[1] 	    ,/*lPixel*/,{|| (cAliasTMP)->F1_TIPO            })
    TRCell():New( oSection  ,"F1_DTDIGIT"	    ,cAliasTMP  ,'Data de Digitação'	        ,                               ,TamSx3("F1_DTDIGIT")[1] 	,/*lPixel*/,{|| SToD((cAliasTMP)->F1_DTDIGIT)   })
    TRCell():New( oSection  ,"F1_EMISSAO"	    ,cAliasTMP  ,'Data de Emissão'  	        ,                               ,TamSx3("F1_EMISSAO")[1] 	,/*lPixel*/,{|| SToD((cAliasTMP)->F1_EMISSAO)   })
    TRCell():New( oSection  ,"F1_DOC"	        ,cAliasTMP  ,'Nota Fiscal'  	            ,PesqPict("SF1","F1_DOC")       ,TamSx3("F1_DOC")[1] 	    ,/*lPixel*/,{|| (cAliasTMP)->F1_DOC             })
    TRCell():New( oSection  ,"F1_SERIE"	        ,cAliasTMP  ,'Serie'          	            ,PesqPict("SF1","F1_SERIE")     ,TamSx3("F1_SERIE")[1] 	    ,/*lPixel*/,{|| (cAliasTMP)->F1_SERIE           })
    TRCell():New( oSection  ,"F1_FORNECE"       ,cAliasTMP  ,'Cod. Fornecedor' 	            ,PesqPict("SF1","F1_FORNECE")   ,TamSx3("F1_FORNECE")[1]    ,/*lPixel*/,{|| (cAliasTMP)->F1_FORNECE         })
    TRCell():New( oSection  ,"F1_LOJA"          ,cAliasTMP  ,'Loja'         	            ,PesqPict("SF1","F1_LOJA")      ,TamSx3("F1_LOJA")[1]       ,/*lPixel*/,{|| (cAliasTMP)->F1_LOJA            })
    TRCell():New( oSection  ,"A2_NREDUZ"        ,cAliasTMP  ,'Razão Social'    	            ,PesqPict("SA2","A2_NREDUZ")    ,TamSx3("A2_NREDUZ")[1]     ,/*lPixel*/,{|| (cAliasTMP)->A2_NREDUZ          })
    TRCell():New( oSection  ,"D1_COD"           ,cAliasTMP  ,'Produto'    	                ,PesqPict("SD1","D1_COD")       ,TamSx3("D1_COD")[1]        ,/*lPixel*/,{|| (cAliasTMP)->D1_COD             })
    TRCell():New( oSection  ,"B1_DESC"          ,cAliasTMP  ,'Descrição'    	            ,PesqPict("SB1","B1_DESC")      ,TamSx3("B1_DESC")[1]       ,/*lPixel*/,{|| (cAliasTMP)->B1_DESC            })
    TRCell():New( oSection  ,"D1_QUANT"         ,cAliasTMP  ,'Qtde NFiscal'    	            ,PesqPict("SD1","D1_QUANT")     ,TamSx3("D1_QUANT")[1]      ,/*lPixel*/,{|| (cAliasTMP)->D1_QUANT           })
    TRCell():New( oSection  ,"ZD1_QTCONF"       ,cAliasTMP  ,'Qtde Conferida'  	            ,PesqPict("SD1","D1_QUANT")     ,TamSx3("ZD1_QTCONF")[1]    ,/*lPixel*/,{|| (cAliasTMP)->ZD1_QTCONF         })    
    TRCell():New( oSection  ,"ZD1_SLDIT"        ,cAliasTMP  ,'Saldo a Conferir'	            ,PesqPict("SD1","D1_QUANT")     ,TamSx3("ZD1_SLDIT")[1]     ,/*lPixel*/,{|| (cAliasTMP)->ZD1_SLDIT          })    
    
    oReport:PrintDialog()

Return

//----------------------------------------------------------
Static Function  ReportPrint(oReport)

    Local oSection     := oReport:Section(1)
    Local cQuery    	:= ""
    
	If Select( cAliasTMP ) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf

    cQuery := " "

    cQuery += " SELECT "	+ CRLF
    cQuery += " 	TMP02.F1_TIPO,  "	+ CRLF
    cQuery += " 	TMP02.F1_DTDIGIT,  "	+ CRLF
    cQuery += " 	TMP02.F1_EMISSAO,  "	+ CRLF
    cQuery += " 	TMP02.F1_DOC,  "	+ CRLF
    cQuery += " 	TMP02.F1_SERIE, "	+ CRLF
    cQuery += " 	TMP02.FORNECEDOR 		AS F1_FORNECE, "	+ CRLF
    cQuery += " 	TMP02.LOJA				AS F1_LOJA, "	+ CRLF
    cQuery += " 	NVL(SA2.A2_NREDUZ,'-') 	AS A2_NREDUZ, "	+ CRLF
    cQuery += " 	TMP02.D1_COD, "	+ CRLF
    cQuery += " 	NVL(SB1.B1_DESC,'-') 	AS B1_DESC, "	+ CRLF
    cQuery += " 	TMP02.D1_QUANT, "	+ CRLF
    cQuery += " 	NVL(ZD1.ZD1_QUANT,0) 	AS ZD1_QUANT, "	+ CRLF
    cQuery += " 	NVL(ZD1.ZD1_QTCONF,0) 	AS ZD1_QTCONF, "	+ CRLF
    cQuery += " 	NVL(ZD1.ZD1_SLDIT,0) 	AS ZD1_SLDIT "	+ CRLF
    cQuery += " 	FROM ( "	+ CRLF
    cQuery += " 			SELECT  TMP01.F1_TIPO,  "	+ CRLF
    cQuery += " 					TMP01.F1_DTDIGIT,  "	+ CRLF
    cQuery += " 					TMP01.F1_EMISSAO,  "	+ CRLF
    cQuery += " 					TMP01.F1_DOC,  "	+ CRLF
    cQuery += " 					TMP01.F1_SERIE, "	+ CRLF
    cQuery += " 					TMP01.FORNECEDOR, "	+ CRLF
    cQuery += " 					TMP01.LOJA, "	+ CRLF
    cQuery += " 					TMP01.D1_COD, "	+ CRLF
    cQuery += " 					SUM(TMP01.D1_QUANT) AS D1_QUANT "	+ CRLF
    cQuery += " 			FROM 	( "	+ CRLF
    cQuery += " 						SELECT	F1_TIPO,  "	+ CRLF
    cQuery += " 								F1_DTDIGIT,  "	+ CRLF
    cQuery += " 								F1_EMISSAO,  "	+ CRLF
    cQuery += " 								F1_DOC,  "	+ CRLF
    cQuery += " 								F1_SERIE,  "	+ CRLF
    cQuery += " 								CASE  "	+ CRLF
    cQuery += " 						            WHEN SF1.F1_TIPO = 'D' THEN SA2D.A2_COD  "	+ CRLF
    cQuery += " 						            ELSE SA2N.A2_COD "	+ CRLF
    cQuery += " 						        END AS FORNECEDOR, "	+ CRLF
    cQuery += " 						        CASE  "	+ CRLF
    cQuery += " 						            WHEN SF1.F1_TIPO = 'D' THEN SA2D.A2_LOJA  "	+ CRLF
    cQuery += " 						            ELSE SA2N.A2_LOJA "	+ CRLF
    cQuery += " 						        END AS LOJA, "	+ CRLF
    cQuery += " 								D1_COD,  "	+ CRLF
    cQuery += " 								D1_QUANT "	+ CRLF
    cQuery += " 						FROM " + RetSQLName( 'SF1' ) + " SF1	 "	+ CRLF
    cQuery += " 							INNER JOIN " + RetSQLName( 'SD1' ) + " SD1 "	+ CRLF
    cQuery += " 								ON SD1.D1_FILIAL = SF1.F1_FILIAL  "	+ CRLF
    cQuery += " 								AND SD1.D1_DOC = SF1.F1_DOC  "	+ CRLF
    cQuery += " 								AND SD1.D1_SERIE = SF1.F1_SERIE  "	+ CRLF
    cQuery += " 								AND SD1.D1_FORNECE = SF1.F1_FORNECE  "	+ CRLF
    cQuery += " 								AND SD1.D1_LOJA = SF1.F1_LOJA  "	+ CRLF
    cQuery += " 								AND SD1.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += " 							LEFT JOIN " + RetSQLName( 'SA1' ) + " SA1D  "	+ CRLF
    cQuery += " 								ON SA1D.A1_FILIAL = '" + FWxFilial('SA1') + "' "	+ CRLF
    cQuery += " 								AND SA1D.A1_COD = SF1.F1_FORNECE  "	+ CRLF
    cQuery += " 								AND SA1D.A1_LOJA = SF1.F1_LOJA "	+ CRLF
    cQuery += " 								AND SA1D.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += " 							LEFT JOIN " + RetSQLName( 'SA2' ) + " SA2D  "	+ CRLF
    cQuery += " 								ON SA2D.A2_FILIAL = '" + FWxFilial('SA2') + "' "	+ CRLF
    cQuery += " 								AND SA2D.A2_CGC =  SA1D.A1_CGC "	+ CRLF
    cQuery += " 								AND SA2D.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += " 							LEFT JOIN " + RetSQLName( 'SA2' ) + " SA2N  "	+ CRLF
    cQuery += " 								ON SA2N.A2_FILIAL = '" + FWxFilial('SA2') + "' "	+ CRLF
    cQuery += " 								AND SA2N.A2_COD = SF1.F1_FORNECE  "	+ CRLF
    cQuery += " 								AND SA2N.A2_LOJA = SF1.F1_LOJA  "	+ CRLF
    cQuery += " 								AND SA2N.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += " 							INNER JOIN " + RetSQLName( 'SF4' ) + " SF4  "	+ CRLF
    cQuery += " 								ON SF4.F4_FILIAL = '" + FWxFilial('SF4') + "' "	+ CRLF
    cQuery += " 								AND SF4.F4_CODIGO = SD1.D1_TES "	+ CRLF
    cQuery += " 								AND SF4.F4_ESTOQUE = 'S' "	+ CRLF
    cQuery += " 								AND SF4.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += " 						WHERE SF1.F1_FILIAL = '" + FWxFilial('SF1') + "' "	+ CRLF
    cQuery += " 					)TMP01 "	+ CRLF
    cQuery += " 			GROUP BY TMP01.F1_TIPO, TMP01.F1_DTDIGIT, TMP01.F1_EMISSAO, TMP01.F1_DOC, TMP01.F1_SERIE, TMP01.FORNECEDOR, TMP01.LOJA, TMP01.D1_COD "	+ CRLF
    cQuery += " 			ORDER BY TMP01.F1_TIPO, TMP01.F1_DTDIGIT, TMP01.F1_EMISSAO, TMP01.F1_DOC, TMP01.F1_SERIE, TMP01.FORNECEDOR, TMP01.LOJA, TMP01.D1_COD "	+ CRLF
    cQuery += " 	)TMP02 "	+ CRLF
    cQuery += " LEFT JOIN " + RetSQLName( 'ZD1' ) + " ZD1 "	+ CRLF
    cQuery += " 	ON ZD1.ZD1_FILIAL = '" + FWxFilial('ZD1') + "' "	+ CRLF
    cQuery += " 	AND ZD1.ZD1_DOC = TMP02.F1_DOC  "	+ CRLF
    cQuery += " 	AND ZD1.ZD1_SERIE = TMP02.F1_SERIE "	+ CRLF
    cQuery += " 	AND	ZD1.ZD1_FORNEC = TMP02.FORNECEDOR "	+ CRLF
    cQuery += " 	AND ZD1.ZD1_LOJA = TMP02.LOJA "	+ CRLF
    cQuery += " 	AND ZD1.ZD1_COD = TMP02.D1_COD "	+ CRLF
    cQuery += " 	AND ZD1.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += " LEFT JOIN " + RetSQLName( 'SA2' ) + " SA2  "	+ CRLF
    cQuery += " 	ON SA2.A2_FILIAL = '" + FWxFilial('SA2') + "' "	+ CRLF
    cQuery += " 	AND SA2.A2_COD = TMP02.FORNECEDOR  "	+ CRLF
    cQuery += " 	AND SA2.A2_LOJA = TMP02.LOJA "	+ CRLF
    cQuery += " 	AND SA2.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += " LEFT JOIN " + RetSQLName( 'SB1' ) + " SB1  "	+ CRLF
    cQuery += " 	ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "	+ CRLF
    cQuery += " 	AND SB1.B1_COD = TMP02.D1_COD "	+ CRLF
    cQuery += " 	AND SB1.D_E_L_E_T_ = ' ' "	+ CRLF 
    cQuery += " 	WHERE TMP02.F1_TIPO <> ' ' "	+ CRLF 
    
    If !( Empty(MV_PAR03) .And. Empty(MV_PAR04) .And. Empty(MV_PAR05) .And. Empty(MV_PAR06) )
        cQuery += " 	AND TMP02.F1_DOC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "	+ CRLF 
        cQuery += " 	AND TMP02.F1_SERIE BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "	+ CRLF 
    EndIf
    
    If !(Empty(MV_PAR01) .And. Empty(MV_PAR02))
        cQuery += " 	AND TMP02.F1_DTDIGIT BETWEEN '" + DToS(MV_PAR01) + "'  AND '" + DToS(MV_PAR02) + "'  "	+ CRLF 
    EndIf

    If MV_PAR07 == 1 //CONFERIDO
        cQuery += " 	AND NVL(ZD1.ZD1_SLDIT,0) = 0  "	+ CRLF 
    ElseIf MV_PAR07 == 2 //A CONFERIR
        cQuery += " 	AND NVL(ZD1.ZD1_SLDIT,0) <> 0 "	+ CRLF 
    EndIf
    	
    // Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

	oReport:SetMeter( Contar(cAliasTMP,"!Eof()") )
	// Secção 1
	oSection:Init()

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())
    While (cAliasTMP)->(!EoF()) .And. !oReport:Cancel()

        // Incrementa a mensagem na régua.
        oReport:IncMeter()

        oSection:Cell( "F1_TIPO"    ):SetHeaderAlign("CENTER")
        oSection:Cell( "F1_DTDIGIT" ):SetHeaderAlign("CENTER")
        oSection:Cell( "F1_EMISSAO" ):SetHeaderAlign("CENTER")
        oSection:Cell( "F1_DOC"     ):SetHeaderAlign("LEFT")
        oSection:Cell( "F1_SERIE"   ):SetHeaderAlign("LEFT")
        oSection:Cell( "F1_FORNECE" ):SetHeaderAlign("LEFT")
        oSection:Cell( "F1_LOJA"    ):SetHeaderAlign("LEFT")
        oSection:Cell( "A2_NREDUZ"  ):SetHeaderAlign("LEFT")
        oSection:Cell( "D1_COD"     ):SetHeaderAlign("LEFT")
        oSection:Cell( "B1_DESC"    ):SetHeaderAlign("LEFT")
        oSection:Cell( "D1_QUANT"   ):SetHeaderAlign("RIGHT")
        oSection:Cell( "ZD1_QTCONF" ):SetHeaderAlign("RIGHT")
        oSection:Cell( "ZD1_SLDIT"  ):SetHeaderAlign("RIGHT")
  
        oSection:PrintLine()	

	    (cAliasTMP)->(dbSkip() )
	
	EndDo               
	oSection:Finish()	           

Return()
