#Include "Protheus.ch"
#Include "Topconn.ch"

//---------------------------------------------------------------------------
User Function ZFISR006()
    Local oReport,  oSection

    Private cAliasTMP := GetNextAlias()
    Private __cSelNfs := ""

	oReport:= TReport():New("ZFISR006",;
                            "Saidas Canc.",;
                            "ZFISR001R2",;
                            {|oReport|  ReportPrint(oReport)},;
                            "Este relatorio efetua a impressão das notas fiscais de saida canceladas")
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
    oReport:HideHeader() //--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter() //--Define que não será impresso o rodapé padrão da página
    oReport:SetDevice(4) //--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    oReport:SetPreview(.T.) //--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2) //--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
    //oReport:SetEdit(.T.) 
	
	//Verifica os parâmetros selecionados via Pergunte
    Pergunte(oReport:GetParam(),.T.)
	
	oSection := TRSection():New(oReport    ,"Colunas"    ,{cAliasTMP}) 
    
    TRCell():New( oSection  ,"F3_FILIAL"  ,cAliasTMP  ,"Empresa"        )
    TRCell():New( oSection  ,"F3_OBSERV"  ,cAliasTMP  ,"Observação"	    )
    TRCell():New( oSection  ,"F3_ESPECIE" ,cAliasTMP  ,"Especie"        )
    TRCell():New( oSection  ,"F3_NFISCAL" ,cAliasTMP  ,"Nota Fiscal"    )
    TRCell():New( oSection  ,"F3_SERIE"   ,cAliasTMP  ,"Serie"		    )
    TRCell():New( oSection  ,"F3_CLIEFOR" ,cAliasTMP  ,"Cliente"		)
    TRCell():New( oSection  ,"A1_GRPTRIB" ,cAliasTMP  ,"GRP. TRIB"		)
    TRCell():New( oSection  ,"F3_LOJA"    ,cAliasTMP  ,"Loja/Cli"		)
    TRCell():New( oSection  ,"F3_EMISSAO" ,cAliasTMP  ,"Emissão"		)
    TRCell():New( oSection  ,"F3_ENTRADA" ,cAliasTMP  ,"Dt Digitação"	)
    TRCell():New( oSection  ,"F3_CHVNFE"  ,cAliasTMP  ,"Chave NFe"	    )
    TRCell():New( oSection  ,"F3_DESCRET" ,cAliasTMP  ,"Descrição"	    )
    TRCell():New( oSection  ,"C6_CHASSI" ,cAliasTMP   ,"Chassi"	        )


    oReport:PrintDialog()

Return


//----------------------------------------------------------
Static Function  ReportPrint(oReport)
    Local oSection     := oReport:Section(1)

    //Monta Tmp
    zTmpRadio4()

	oReport:SetMeter( Contar(cAliasTMP,"!Eof()") )
	// Secção 1
	oSection:Init()

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())
    While (cAliasTMP)->(!EoF()) .And. !oReport:Cancel()

        // Incrementa a mensagem na régua.
        oReport:IncMeter()
      
        oSection:Cell( "F3_FILIAL"  ):SetValue( Alltrim( (cAliasTMP)->F3_FILIAL    ) ) //--Empresa
        oSection:Cell( "F3_OBSERV"  ):SetValue( Alltrim( (cAliasTMP)->F3_OBSERV    ) ) //--Observação
        oSection:Cell( "F3_ESPECIE" ):SetValue( Alltrim( (cAliasTMP)->F3_ESPECIE   ) ) //--Especie
        oSection:Cell( "F3_NFISCAL" ):SetValue( Alltrim( (cAliasTMP)->F3_NFISCAL   ) ) //--Nota Fiscal
        oSection:Cell( "F3_SERIE"   ):SetValue( Alltrim( (cAliasTMP)->F3_SERIE     ) ) //--Serie
        oSection:Cell( "F3_CLIEFOR" ):SetValue( Alltrim( (cAliasTMP)->F3_CLIEFOR   ) ) //--Cliente
        oSection:Cell( "A1_GRPTRIB" ):SetValue( Alltrim( (cAliasTMP)->A1_GRPTRIB   ) )   //--Cliente   
        oSection:Cell( "F3_LOJA"    ):SetValue( Alltrim( (cAliasTMP)->F3_LOJA      ) ) //--Loja/Cli
        oSection:Cell( "F3_EMISSAO" ):SetValue( IIF( Empty( SToD( (cAliasTMP)->F3_EMISSAO ) ), "", SToD( (cAliasTMP)->F3_EMISSAO ) ) ) //--Emissão
        oSection:Cell( "F3_ENTRADA" ):SetValue( IIF( Empty( SToD( (cAliasTMP)->F3_ENTRADA ) ), "", SToD( (cAliasTMP)->F3_ENTRADA ) ) ) //--Dt Digitação
        oSection:Cell( "F3_CHVNFE"  ):SetValue( AllTrim( (cAliasTMP)->F3_CHVNFE     ) ) //--Chave NFe
        oSection:Cell( "F3_DESCRET" ):SetValue( AllTrim( (cAliasTMP)->F3_DESCRET    ) ) //--Descrição
        oSection:Cell( "C6_CHASSI" ):SetValue( AllTrim( (cAliasTMP)->C6_CHASSI    ) ) //--Descrição

        oSection:PrintLine()	

	    (cAliasTMP)->(dbSkip() )
	
	EndDo               
	oSection:Finish()	           

Return

//----------------------------------------------------------
Static Function zTmpRadio4()
    Local cQuery    	:= ""

    If MV_PAR22 == 1
	  zSelNfs6()
    EndIf
    
	If Select( cAliasTMP ) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf 

    cQuery := " SELECT F3_FILIAL, F3_OBSERV, F3_ESPECIE, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, A1_GRPTRIB,"	+ CRLF
    cQuery += " F3_EMISSAO, F3_CHVNFE, F3_DESCRET, F3_ENTRADA, C6_CHASSI "											+ CRLF
    cQuery += " FROM " + RetSQLName( 'SF3' ) + " SF3 " 													+ CRLF
    cQuery += " INNER JOIN " + RetSQLName( 'SF2' ) + " SF2 "											+ CRLF
    cQuery += " 	ON SF2.F2_FILIAL = '" + FWxFilial('SF2') + "' "	 								    + CRLF
    cQuery += " 	AND SF2.F2_DOC = SF3.F3_NFISCAL "													+ CRLF
    cQuery += " 	AND SF2.F2_SERIE = SF3.F3_SERIE "													+ CRLF
    cQuery += " 	AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR "												+ CRLF
    cQuery += " 	AND SF2.F2_LOJA = SF3.F3_LOJA "														+ CRLF

    cQuery += " INNER JOIN " + RetSQLName( 'SD2' ) + " SD2 "											+ CRLF
    cQuery += " 	ON SD2.D2_FILIAL = '" + FWxFilial('SD2') + "' "	 								    + CRLF
    cQuery += " 	AND SD2.D2_DOC = SF3.F3_NFISCAL "													+ CRLF
    cQuery += " 	AND SD2.D2_SERIE = SF3.F3_SERIE "													+ CRLF
    cQuery += " 	AND SD2.D2_CLIENTE = SF3.F3_CLIEFOR "												+ CRLF
    cQuery += " 	AND SD2.D2_LOJA = SF3.F3_LOJA "														+ CRLF
    cQuery += " 	AND SD2.D2_COD BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' " 					+ CRLF

	cQuery += " LEFT JOIN " + RetSQLName("SC6") + " SC6 "																    + CRLF
	cQuery += "		ON SC6.C6_FILIAL = '" + FWxFilial('SC6') + "' "													        + CRLF
	cQuery += "		AND SC6.C6_NUM = SD2.D2_PEDIDO  "																	    + CRLF
	cQuery += "		AND SC6.C6_ITEM = SD2.D2_ITEMPV  "		 															    + CRLF
	cQuery += "		AND SC6.C6_PRODUTO = SD2.D2_COD "		 															    + CRLF
	cQuery += "     AND SC6.D_E_L_E_T_ = ' '   " 																		    + CRLF

    cQuery += " INNER JOIN " + RetSQLName("SA1") + " SA1 " 												+ CRLF
    cQuery += "		ON SA1.A1_FILIAL = '" + FWxFilial('SA1') + "' "									    + CRLF
    cQuery += "		AND SA1.A1_COD = SF3.F3_CLIEFOR  "	 												+ CRLF
    cQuery += "		AND SA1.A1_LOJA = SF3.F3_LOJA "	 									    			+ CRLF    
    cQuery += "		AND SA1.D_E_L_E_T_ = ' ' " 															+ CRLF


    cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 " 												+ CRLF
    cQuery += "		ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "									    + CRLF
    cQuery += "		AND SB1.B1_COD = SD2.D2_COD   "	 													+ CRLF
    cQuery += "		AND SB1.D_E_L_E_T_ = ' ' " 															+ CRLF

    cQuery += " WHERE  SF3.F3_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "				+ CRLF
    cQuery += " 	AND SF3.F3_ESPECIE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "				+ CRLF
    cQuery += " 	AND SF3.F3_NFISCAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "				+ CRLF
    cQuery += " 	AND SF3.F3_SERIE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "				+ CRLF
    cQuery += " 	AND SF3.F3_CLIEFOR BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' " 				+ CRLF
    cQuery += " 	AND SF3.F3_EMISSAO BETWEEN '" + DToS(MV_PAR11) + "' AND '" + DToS(MV_PAR12) + "' " 	+ CRLF
    cQuery += " 	AND SF3.F3_DTCANC != ' ' " 															+ CRLF

    If !Empty( MV_PAR20 ) .OR. !Empty( MV_PAR21)
	    cQuery += " 	AND SC6.C6_CHASSI  BETWEEN '" + MV_PAR20 + "' AND '" + MV_PAR21 + "' " 															    + CRLF
    ENDIF

    If !Empty( MV_PAR18 )
        cQuery += " 	AND SB1.B1_GRUPO = '" + MV_PAR18 + "' "											+ CRLF
    EndIf

    If !Empty( MV_PAR17 )
        cQuery += " 	AND SF2.F2_EST = '" + MV_PAR17 + "' " 											+ CRLF
    EndIf

    If !Empty( MV_PAR15 )
        cQuery += " 	AND SD2.D2_TES = '" + MV_PAR15 + "' " 											+ CRLF
    EndIf

    If !Empty( MV_PAR16 )
        cQuery += " 	AND SD2.D2_CF = '" + MV_PAR16 + "' " 											+ CRLF
    EndIf

    If !Empty( MV_PAR19 )
        cQuery += " 	AND SB1.B1_POSIPI = '" + MV_PAR19 + "' "										+ CRLF
    EndIf

    If !Empty( __cSelNfs )
		cQuery += " AND SD2.D2_DOC IN " + FormatIn(__cSelNfs, ";")   	+ CRLF
    Else
    	cQuery += " 	AND SD2.D2_DOC     BETWEEN '" +       MV_PAR05   + "' AND '" +       MV_PAR06   + "' " 												
	EndIf

    cQuery += " 	AND SF3.D_E_L_E_T_ = ' '   " 														+ CRLF






    cQuery += " GROUP BY F3_FILIAL, F3_OBSERV, F3_ESPECIE, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, A1_GRPTRIB, " + CRLF
    cQuery += " F3_EMISSAO, F3_CHVNFE, F3_DESCRET, F3_ENTRADA, C6_CHASSI  "										+ CRLF

    cQuery += " ORDER BY SF3.F3_FILIAL, SF3.F3_NFISCAL, SF3.F3_SERIE, SF3.F3_CLIEFOR, SF3.F3_LOJA "		+ CRLF	

    cQuery := ChangeQuery(cQuery)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

Return

/*
=======================================================================================
Programa.:              zSelNfs6
Autor....:              CAOA - Sandro Ferreira
Data.....:              28/06/2024
Descricao / Objetivo:   Monta markbrowse para seleção de notas fiscais   
Solicitante:			Thaynara
Gap:					    
=======================================================================================
*/
Static Function zSelNfs6()
    Local oMarkBrw  := Nil
    Local cMark     := GetMark()
	Local cAliasQry	:= GetNextAlias()

    oMarkBrw := FWMarkBrowse():New()
    oMarkBrw:SetDescription("Selecionar Notas Fiscais")
    oMarkBrw:SetAlias("SF3")
    oMarkBrw:SetFieldMark( "F3_OK" )
    oMarkBrw:SetMark( cMark, "SF3", "F3_OK" )
    oMarkBrw:SetMenuDef('')
	oMarkBrw:SetFilterDefault("@"+zFilNf6())
    oMarkBrw:DisableReport()
    oMarkBrw:AddButton( "Confirmar", {|| Self:End()} )
    oMarkBrw:Activate()

    BeginSql Alias cAliasQry
        SELECT R_E_C_N_O_ AS RECSF3, F3_NFISCAL
        FROM %Table:SF3% SF3
        WHERE SF3.F3_OK = %Exp:cMark%
        AND SF3.%NotDel%
    EndSql
    
    (cAliasQry)->( DbGoTop() )
    While (cAliasQry)->( !Eof() )

		//--Carrega notas fiscais selecionadas
        If Empty(__cSelNfs)
            __cSelNfs := AllTrim( ( cAliasQry )->F3_NFISCAL )
        Else
            __cSelNfs := __cSelNfs + ";" + AllTrim( ( cAliasQry )->F3_NFISCAL )
        EndIf
        
        //--Limpa marcação
        SF3->( DbGoTo( ( cAliasQry )->RECSF3 ) )
        RecLock("SF3", .F.)
        SF3->F3_OK := ""
        SF3->( MsUnLock() )

        (cAliasQry)->( DbSkip() )

    EndDo

    (cAliasQry)->( DbCloseArea() )
    oMarkBrw:DeActivate()

Return

/*
=======================================================================================
Programa.:              zFilNf6
Autor....:              CAOA - Sandro Ferreira
Data.....:              28/06/2024
Descricao / Objetivo:   Filtra notas fiscais
=======================================================================================
*/
Static Function zFilNf6()
	Local cFiltro := ""

	cFiltro  +=  "      F3_FILIAL  BETWEEN  '" + MV_PAR01         + "'  AND '" + MV_PAR02        + "' " + CRLF
	cFiltro  +=  "  AND F3_ESPECIE BETWEEN  '" + MV_PAR03         + "'  AND '" + MV_PAR04        + "' " + CRLF
   	cFiltro  +=  "  AND F3_NFISCAL BETWEEN  '" + MV_PAR05         + "'  AND '" + MV_PAR06        + "' " + CRLF
	cFiltro  +=  "  AND F3_SERIE   BETWEEN  '" + MV_PAR07         + "'  AND '" + MV_PAR08        + "' " + CRLF
	cFiltro  +=  "  AND F3_CLIEFOR BETWEEN  '" + MV_PAR09         + "'  AND '" + MV_PAR10        + "' " + CRLF
	cFiltro  +=  "	AND F3_EMISSAO BETWEEN '" + DToS( MV_PAR11 )  + "' AND '" + DToS( MV_PAR12 )  + "' " +CRLF
    cFiltro  += " 	AND F3_DTCANC != ' ' "
 	cFiltro  +=  "	AND D_E_L_E_T_ = ' ' " + CRLF

Return cFiltro

