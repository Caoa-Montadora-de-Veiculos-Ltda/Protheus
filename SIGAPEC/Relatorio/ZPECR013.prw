#Include "Protheus.ch"
#Include "Topconn.ch"

/*
==========================================================================
Programa...:    ZPECR007
Autor......:    CAOA - Fagner Barreto
Data.......:    20/06/2022
==========================================================================
*/
User Function ZPECR013()
    Local oReport,  oSection

    Private cAliasTMP := GetNextAlias()

	oReport:= TReport():New("ZPECR013", "Relatorio Corte Automatico", , {|oReport|  ReportPrint(oReport)})
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
    oReport:HideHeader() //--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter() //--Define que não será impresso o rodapé padrão da página
    //oReport:SetDevice(1) //--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    oReport:SetPreview(.T.) //--Define se será apresentada a visualização do relatório antes da impressão física
    //oReport:SetEnvironment(2) //--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
    //oReport:SetEdit(.T.) 
	
	//Verifica os parâmetros selecionados via Pergunte
    Pergunte(oReport:GetParam(),.F.)
	
	oSection := TRSection():New(oReport    ,"Colunas"    ,{cAliasTMP}) 
    
    TRCell():New( oSection  ,"VS1_XMARCA"   ,cAliasTMP  ,"Marca"        )
    TRCell():New( oSection  ,"VS3_XPICKI"   ,cAliasTMP  ,"Picking"      )
    TRCell():New( oSection  ,"VS1_XDTEPI"   ,cAliasTMP  ,"Dt_picking"   )
    TRCell():New( oSection  ,"VS3_CODITE"   ,cAliasTMP  ,"CodIte"       )
    TRCell():New( oSection  ,"QT_SEPARAR"   ,cAliasTMP  ,"Qt_separar"   )
    TRCell():New( oSection  ,"QTD_SOLIC"    ,cAliasTMP  ,"Qtd_solic"    )

    oReport:PrintDialog()

Return

//----------------------------------------------------------
Static Function  ReportPrint(oReport)
    Local oSection     := oReport:Section(1)

    //Monta Tmp
    zTmpQry()

	oReport:SetMeter( Contar(cAliasTMP,"!Eof()") )
	// Secção 1
	oSection:Init()

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())
    While (cAliasTMP)->(!EoF()) .And. !oReport:Cancel()

        // Incrementa a mensagem na régua.
        oReport:IncMeter()
      
        oSection:Cell( "VS1_XMARCA" ):SetValue( Alltrim( (cAliasTMP)->VS1_XMARCA    ) ) //--Marca
        oSection:Cell( "VS3_XPICKI" ):SetValue( Alltrim( (cAliasTMP)->VS3_XPICKI    ) ) //--Picking
        oSection:Cell( "VS1_XDTEPI" ):SetValue( IIF( Empty( SToD( (cAliasTMP)->VS1_XDTEPI ) ), "", SToD( (cAliasTMP)->VS1_XDTEPI ) ) ) //--Dt_picking
        oSection:Cell( "VS3_CODITE" ):SetValue( Alltrim( (cAliasTMP)->VS3_CODITE    ) ) //--CodIte
        oSection:Cell( "QT_SEPARAR" ):SetValue( (cAliasTMP)->QT_SEPARAR ) //--Qt_separar
        oSection:Cell( "QTD_SOLIC"  ):SetValue( (cAliasTMP)->QTD_SOLIC ) //--Qtd_solic

        oSection:PrintLine()	

	    (cAliasTMP)->(dbSkip() )
	
	EndDo               
	oSection:Finish()	           

Return

//----------------------------------------------------------
Static Function zTmpQry()
    Local cQuery    := ""
    
	If Select( cAliasTMP ) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf

    cQuery := " SELECT VS1.VS1_XMARCA, VS3.VS3_XPICKI,  "                       + CRLF
    cQuery += "     VS1.VS1_XDTEPI, VS3.VS3_CODITE,           "                 + CRLF              
    cQuery += "      (DETWIS.QT_SEPARAR), SUM(VS3.VS3_QTDITE) AS QTD_SOLIC  "   + CRLF        
    cQuery += " FROM " + RetSQLName( 'VS3' ) + " VS3 "                          + CRLF
    cQuery += " INNER JOIN " + RetSQLName( 'VS1' ) + " VS1 "		            + CRLF
    cQuery += "     ON VS1_FILIAL = '" + FWxFilial('VS1') + "' "	            + CRLF
    cQuery += "     AND VS1_NUMORC = VS3_NUMORC "	                            + CRLF
    cQuery += "     AND VS1.D_E_L_E_T_ = ' ' "	                                + CRLF
    cQuery += " LEFT JOIN " + RetSQLName( 'SZK' ) + " SZK "		                + CRLF
    cQuery += "     ON ZK_FILIAL = '" + FWxFilial('SZK') + "' "	                + CRLF
    cQuery += "     AND ZK_XPICKI = VS3_XPICKI "	                            + CRLF
    cQuery += "     AND ZK_SEQREG = 1 "	                                        + CRLF
    cQuery += "     AND SZK.D_E_L_E_T_ = ' ' "	                                + CRLF
    
    If  "_PRD" $ AllTrim(GetEnvServer())  //"PRODUÇÃO"  //.or. AllTrim(GetEnvServer()) == "PRIME" 
        cQuery += " LEFT JOIN WIS.T_DET_PEDIDO_SAIDA@DBLINK_WISPROD DETWIS "    + CRLF  
    Else
        cQuery += " LEFT JOIN WIS.T_DET_PEDIDO_SAIDA@DBLINK_WISHML DETWIS "    + CRLF  
    EndIf

    cQuery += "     ON NU_PEDIDO_ORIGEM = VS3.VS3_XPICKI    "                   + CRLF     
    cQuery += "     AND CAST(DETWIS.CD_PRODUTO AS CHAR(27)) = VS3.VS3_CODITE "  + CRLF 
    cQuery += " WHERE VS3.D_E_L_E_T_ = ' ' "  + CRLF 
    cQuery += " GROUP BY VS3.VS3_XPICKI, VS1.VS1_XMARCA, VS1.VS1_XDTEPI, "      + CRLF 
    cQuery += "     VS3.VS3_CODITE, DETWIS.QT_SEPARAR "                         + CRLF 
    cQuery += " HAVING (DETWIS.QT_SEPARAR) != SUM(VS3.VS3_QTDITE) "             + CRLF
    cQuery += " ORDER BY VS3.VS3_XPICKI "                                       + CRLF

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

Return
