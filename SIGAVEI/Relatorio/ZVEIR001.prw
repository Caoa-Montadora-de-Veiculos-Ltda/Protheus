#Include "Protheus.ch"
#Include "Topconn.ch"

//---------------------------------------------------------------------------
User Function ZVEIR001()
    
    Local oReport,  oSection

    Private cAliasTMP := GetNextAlias()

	oReport:= TReport():New("ZVEIR001",;
                            "Posição Estoque Chery",;
                            "ZVEIR001R1",;
                            {|oReport|  ReportPrint(oReport)},;
                            "Este relatorio efetua a impressão dos veiculos em estoque.")
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
    oReport:HideHeader() //--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter() //--Define que não será impresso o rodapé padrão da página
    oReport:SetDevice(4) //--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    oReport:SetPreview(.T.) //--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2) //--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
    //oReport:SetEdit(.T.) 
	
	//Verifica os parâmetros selecionados via Pergunte
    //Pergunte(oReport:GetParam(),.F.)
	
	oSection := TRSection():New(oReport    ,"Colunas"    ,{cAliasTMP}) 
    
    TRCell():New( oSection  ,"VV1_CHAINT"   ,cAliasTMP  ,"Chassi Interno."  )
    TRCell():New( oSection  ,"VV1_CODMAR"   ,cAliasTMP  ,"Marca."	        )
    TRCell():New( oSection  ,"B1_COD"       ,cAliasTMP  ,"Produto."         )
    TRCell():New( oSection  ,"B1_DESC"      ,cAliasTMP  ,"Descr. Produto."  )
    TRCell():New( oSection  ,"VV1_CHASSI"   ,cAliasTMP  ,"Chassi"		    )
    TRCell():New( oSection  ,"VV1_SITVEI"   ,cAliasTMP  ,"Sit.Veiculo"		)
    TRCell():New( oSection  ,"VV1_IMOBI"    ,cAliasTMP  ,"Imobilizado?"		)
    TRCell():New( oSection  ,"VV1_FABMOD"   ,cAliasTMP  ,"Fab/Mod"		    )
 
    oReport:PrintDialog()

Return


//----------------------------------------------------------
Static Function  ReportPrint(oReport)
    Local oSection     := oReport:Section(1)

    //Monta Tmp
    zTmpSQL()

	oReport:SetMeter( Contar(cAliasTMP,"!Eof()") )
	// Secção 1
	oSection:Init()

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())
    While (cAliasTMP)->(!EoF()) .And. !oReport:Cancel()

        // Incrementa a mensagem na régua.
        oReport:IncMeter()
     
        oSection:Cell( "VV1_CHAINT" ):SetValue( Alltrim( (cAliasTMP)->VV1_CHAINT    ) ) //--Empresa
        oSection:Cell( "VV1_CODMAR" ):SetValue( Alltrim( (cAliasTMP)->VV1_CODMAR    ) ) //--Observação
        oSection:Cell( "B1_COD"     ):SetValue( Alltrim( (cAliasTMP)->B1_COD   ) ) //--Especie
        oSection:Cell( "B1_DESC"    ):SetValue( Alltrim( (cAliasTMP)->B1_DESC   ) ) //--Nota Fiscal
        oSection:Cell( "VV1_CHASSI" ):SetValue( Alltrim( (cAliasTMP)->VV1_CHASSI     ) ) //--Serie
        oSection:Cell( "VV1_SITVEI" ):SetValue( Alltrim( X3Combo( "VV1_SITVEI"	,(cAliasTMP)->VV1_SITVEI )  ) ) //--Cliente
        oSection:Cell( "VV1_IMOBI"  ):SetValue( Alltrim( X3Combo( "VV1_IMOBI"	,(cAliasTMP)->VV1_IMOBI  )  ) )  //--Loja/Cli
        oSection:Cell( "VV1_FABMOD" ):SetValue( Alltrim( (cAliasTMP)->VV1_FABMOD      ) ) //--Loja/Cli
        
        oSection:PrintLine()	

	    (cAliasTMP)->(dbSkip() )
	
	EndDo               
	oSection:Finish()	           

Return

//----------------------------------------------------------
Static Function zTmpSQL()

    Local cQuery    	:= ""
    
	If Select( cAliasTMP ) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf

    cQuery := " 
    cQuery += " SELECT  VV1.VV1_CHAINT, "                                                   + CRLF
    cQuery += "         VV1.VV1_CODMAR, "                                                   + CRLF
    cQuery += "         SB1.B1_COD, "                                                       + CRLF
    cQuery += "         SB1.B1_DESC, "                                                      + CRLF
    cQuery += "         VV1.VV1_CHASSI, "                                                   + CRLF
    cQuery += "         VV1.VV1_SITVEI, "                                                   + CRLF
    cQuery += "         VV1.VV1_IMOBI, "                                                    + CRLF
    cQuery += "         VV1.VV1_FABMOD "                                                    + CRLF
    cQuery += " FROM " + RetSQLName( 'VV1' ) + " VV1 "                                      + CRLF
    cQuery += "     INNER JOIN " + RetSQLName( 'SB1' ) + " SB1 "                            + CRLF
    cQuery += "     ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "                         + CRLF
    cQuery += "     AND RTRIM(SB1.B1_COD) = RTRIM(VV1_MODVEI) || RTRIM(VV1_SEGMOD) "        + CRLF
    cQuery += "     AND SB1.D_E_L_E_T_ = ' ' "                                              + CRLF
    cQuery += " WHERE VV1.D_E_L_E_T_ = ' ' "                                                + CRLF
    cQuery += " AND VV1.VV1_FILIAL = '" + FWxFilial('VV1') + "' "                           + CRLF
    cQuery += " AND VV1.VV1_SITVEI = '0' "                                                  + CRLF
    cQuery += " AND VV1.VV1_CODMAR = 'CHE' "                                                + CRLF
    cQuery += " AND VV1_CHASSI NOT LIKE 'LVT%' "                                            + CRLF
    cQuery += " AND VV1_CHASSI NOT LIKE 'LVV%' "                                    

    cQuery := ChangeQuery(cQuery)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

Return
