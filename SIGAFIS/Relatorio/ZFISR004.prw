#Include "Protheus.ch"
#Include "Topconn.ch"

//---------------------------------------------------------------------------
User Function ZFISR004()
    Local oReport,  oSection

    Private cAliasTMP := GetNextAlias()
    Private __cSelNfs := ""

	oReport:= TReport():New("ZFISR004",;
                            "Entradas Canc.",;
                            "ZFISR001R1",;
                            {|oReport|  ReportPrint(oReport)},;
                            "Este relatorio efetua a impressão das notas fiscais de entrada canceladas")
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

    TRCell():New( oSection  ,"F3_FILIAL"       ,cAliasTMP  ,"Empresa"		)
    TRCell():New( oSection  ,"F3_OBSERV"       ,cAliasTMP  ,"Observação"	)
    TRCell():New( oSection  ,"F3_ESPECIE"      ,cAliasTMP  ,"Especie"		)
    TRCell():New( oSection  ,"F3_NFISCAL"      ,cAliasTMP  ,"Nota Fiscal"	)
    TRCell():New( oSection  ,"F3_SERIE"        ,cAliasTMP  ,"Serie"		    )
    TRCell():New( oSection  ,"F3_CLIEFOR"      ,cAliasTMP  ,"Cliente"		)
    TRCell():New( oSection  ,"A2_GRPTRIB"      ,cAliasTMP  ,"GRP. TRIB"		)
    TRCell():New( oSection  ,"F3_LOJA"         ,cAliasTMP  ,"Loja/Cli"	    )
    TRCell():New( oSection  ,"F3_EMISSAO"      ,cAliasTMP  ,"Emissão"		)
    TRCell():New( oSection  ,"F3_ENTRADA"      ,cAliasTMP  ,"Dt Digitação"  )
    TRCell():New( oSection  ,"F3_CHVNFE"       ,cAliasTMP  ,"Chave NFe"	    )
    TRCell():New( oSection  ,"F3_DESCRET"      ,cAliasTMP  ,"Descrição"	    )
    TRCell():New( oSection  ,"D1_CHASSI"       ,cAliasTMP  ,"Chassi"	    )

    //TRPosition():New( oSection,"SA2",1,{|| xFilial("SA2")+DCX->DCX_FORNEC+DCX->DCX_LOJA})	
    oReport:PrintDialog()

Return

//----------------------------------------------------------
Static Function  ReportPrint(oReport)
    Local oSection     := oReport:Section(1)

    //Monta Tmp
    zTmpRadio2()

	oReport:SetMeter( Contar(cAliasTMP,"!Eof()") )
	// Secção 1
	oSection:Init()

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())
    While (cAliasTMP)->(!EoF()) .And. !oReport:Cancel()

        // Incrementa a mensagem na régua.
        oReport:IncMeter()

        oSection:Cell( "F3_FILIAL"  ):SetValue( Alltrim( (cAliasTMP)->F3_FILIAL    ) )   //--Empresa
        oSection:Cell( "F3_OBSERV"  ):SetValue( Alltrim( (cAliasTMP)->F3_OBSERV    ) )   //--Observação
        oSection:Cell( "F3_ESPECIE" ):SetValue( Alltrim( (cAliasTMP)->F3_ESPECIE   ) )   //--Especie
        oSection:Cell( "F3_NFISCAL" ):SetValue( Alltrim( (cAliasTMP)->F3_NFISCAL   ) )   //--Nota Fiscal
        oSection:Cell( "F3_SERIE"   ):SetValue( Alltrim( (cAliasTMP)->F3_SERIE     ) )   //--Serie
        oSection:Cell( "F3_CLIEFOR" ):SetValue( Alltrim( (cAliasTMP)->F3_CLIEFOR   ) )   //--Cliente
        oSection:Cell( "A2_GRPTRIB" ):SetValue( Alltrim( (cAliasTMP)->A2_GRPTRIB   ) )   //--Cliente   
        oSection:Cell( "F3_LOJA"    ):SetValue( Alltrim( (cAliasTMP)->F3_LOJA      ) )   //--Loja/Cli
        oSection:Cell( "F3_EMISSAO" ):SetValue( IIF( Empty( SToD( (cAliasTMP)->F3_EMISSAO ) ), "", SToD( (cAliasTMP)->F3_EMISSAO ) ) )   //--Emissão
        oSection:Cell( "F3_ENTRADA" ):SetValue( IIF( Empty( SToD( (cAliasTMP)->F3_ENTRADA ) ), "", SToD( (cAliasTMP)->F3_ENTRADA ) ) )   //--Dt Digitação
        oSection:Cell( "F3_CHVNFE"  ):SetValue( AllTrim( (cAliasTMP)->F3_CHVNFE ) )  //--Chave NFe
        oSection:Cell( "F3_DESCRET" ):SetValue( AllTrim( (cAliasTMP)->F3_DESCRET ) ) //--Descrição
        oSection:Cell( "D1_CHASSI" ):SetValue( AllTrim( (cAliasTMP)->D1_CHASSI ) ) //--Descrição

        oSection:PrintLine()	

	    (cAliasTMP)->(dbSkip() )
	
	EndDo               
	oSection:Finish()	           

Return

//----------------------------------------------------------
Static Function zTmpRadio2()
    Local cQuery    	:= ""

    If MV_PAR25 == 1
	  zSelNfs4()
    EndIf	

	If Select( cAliasTMP ) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf

    cQuery := " SELECT F3_FILIAL, F3_OBSERV, F3_ESPECIE, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, A2_GRPTRIB,"	+ CRLF
    cQuery += " F3_EMISSAO, F3_CHVNFE, F3_DESCRET, F3_ENTRADA, D1_CHASSI "											+ CRLF
    cQuery += " FROM " + RetSQLName( 'SF3' ) + " SF3 " 													+ CRLF
    cQuery += " INNER JOIN " + RetSQLName( 'SF1' ) + " SF1 "											+ CRLF
    cQuery += " 	ON SF1.F1_FILIAL = '" + FWxFilial('SF1') + "' "	 								    + CRLF
    cQuery += " 	AND SF1.F1_DOC = SF3.F3_NFISCAL "													+ CRLF
    cQuery += " 	AND SF1.F1_SERIE = SF3.F3_SERIE "													+ CRLF
    cQuery += " 	AND SF1.F1_FORNECE = SF3.F3_CLIEFOR "												+ CRLF
    cQuery += " 	AND SF1.F1_LOJA = SF3.F3_LOJA "														+ CRLF

    cQuery += " INNER JOIN " + RetSQLName( 'SD1' ) + " SD1 "											+ CRLF
    cQuery += " 	ON SD1.D1_FILIAL = '" + FWxFilial('SD1') + "' "	 								    + CRLF
    cQuery += " 	AND SD1.D1_DOC = SF3.F3_NFISCAL "													+ CRLF
    cQuery += " 	AND SD1.D1_SERIE = SF3.F3_SERIE "													+ CRLF
    cQuery += " 	AND SD1.D1_FORNECE = SF3.F3_CLIEFOR "												+ CRLF
    cQuery += " 	AND SD1.D1_LOJA = SF3.F3_LOJA "														+ CRLF
    cQuery += " 	AND SD1.D1_COD BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR16 + "' " 					+ CRLF

    cQuery += " INNER JOIN " + RetSQLName("SA2") + " SA2 " 												+ CRLF
    cQuery += "		ON SA2.A2_FILIAL = '" + FWxFilial('SA2') + "' "									    + CRLF
    cQuery += "		AND SA2.A2_COD = SF3.F3_CLIEFOR  "	 												+ CRLF
    cQuery += "		AND SA2.A2_LOJA = SF3.F3_LOJA "	 									    			+ CRLF    
    cQuery += "		AND SA2.D_E_L_E_T_ = ' ' " 															+ CRLF


    cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 " 												+ CRLF
    cQuery += "		ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "									    + CRLF
    cQuery += "		AND SB1.B1_COD = SD1.D1_COD   "	 													+ CRLF
    cQuery += "		AND SB1.D_E_L_E_T_ = ' ' " 															+ CRLF

    cQuery += " WHERE  SF3.F3_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "				+ CRLF
    cQuery += " 	AND SF3.F3_ESPECIE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "				+ CRLF
    cQuery += " 	AND SF3.F3_NFISCAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "				+ CRLF
    cQuery += " 	AND SF3.F3_SERIE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "				+ CRLF
    cQuery += " 	AND SF3.F3_CLIEFOR BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' " 				+ CRLF
    cQuery += " 	AND SF3.F3_ENTRADA BETWEEN '" + DToS(MV_PAR11) + "' AND '" + DToS(MV_PAR12) + "' "	+ CRLF
    cQuery += " 	AND SF3.F3_EMISSAO BETWEEN '" + DToS(MV_PAR13) + "' AND '" + DToS(MV_PAR14) + "' " 	+ CRLF
    cQuery += " 	AND SF3.F3_DTCANC != ' ' " 															+ CRLF
    cQuery += " 	AND SF3.D_E_L_E_T_ = ' '   " 														+ CRLF

    If !Empty( MV_PAR17 )
        cQuery += " 	AND SD1.D1_TES = '" + MV_PAR17 + "' " 											+ CRLF
    EndIf

    If !Empty( MV_PAR18 )
        cQuery += " 	AND SD1.D1_CF = '" + MV_PAR18 + "' " 											+ CRLF
    EndIf


    If !Empty( MV_PAR19 )
        cQuery += " 	AND SF1.F1_EST = '" + MV_PAR19 + "' " 											+ CRLF
    EndIf

    If !Empty( MV_PAR20 )
        cQuery += " 	AND SB1.B1_GRUPO = '" + MV_PAR20 + "' "											+ CRLF
    EndIf

    If !Empty( MV_PAR21 )
        cQuery += " 	AND SB1.B1_POSIPI = '" + MV_PAR21 + "' "										+ CRLF
    EndIf

    If !Empty( __cSelNfs )
		cQuery += " AND SD1.D1_DOC IN " + FormatIn(__cSelNfs, ";")   	+ CRLF
    Else
    	cQuery += " 	AND SD1.D1_DOC     BETWEEN '" +       MV_PAR05   + "' AND '" +       MV_PAR06   + "' " 												
	EndIf
    
    If !Empty( alltrim(MV_PAR23)) .OR. !Empty( alltrim(MV_PAR24) )
       cQuery += " 	AND SD1.D1_CHASSI BETWEEN '" + MV_PAR23 + "' AND '" + MV_PAR24 + "' " 
    ENDIF

    cQuery += " GROUP BY F3_FILIAL, F3_OBSERV, F3_ESPECIE, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, A2_GRPTRIB ," + CRLF
    cQuery += " F3_EMISSAO, F3_CHVNFE, F3_DESCRET, F3_ENTRADA, D1_CHASSI "											+ CRLF

    cQuery += " ORDER BY SF3.F3_FILIAL, SF3.F3_NFISCAL, SF3.F3_SERIE, SF3.F3_CLIEFOR, SF3.F3_LOJA "		+ CRLF															+ CRLF

    cQuery := ChangeQuery(cQuery)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

Return

/*
=======================================================================================
Programa.:              zSelNfs4
Autor....:              CAOA - Sandro Ferreira
Data.....:              26/06/2024
Descricao / Objetivo:   Monta markbrowse para seleção de notas fiscais   
Solicitante:			Thaynara
Gap:					    
=======================================================================================
*/
Static Function zSelNfs4()
    Local oMarkBrw  := Nil
    Local cMark     := GetMark()
	Local cAliasQry	:= GetNextAlias()

    oMarkBrw := FWMarkBrowse():New()
    oMarkBrw:SetDescription("Selecionar Notas Fiscais")
    oMarkBrw:SetAlias("SF3")
    oMarkBrw:SetFieldMark( "F3_OK" )
    oMarkBrw:SetMark( cMark, "SF3", "F3_OK" )
    oMarkBrw:SetMenuDef('')
	oMarkBrw:SetFilterDefault("@"+zFilNf4())
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
Programa.:              zFilNf4
Autor....:              CAOA - Sandro Ferreira
Data.....:              26/06/2024
Descricao / Objetivo:   Filtra notas fiscais
=======================================================================================
*/
Static Function zFilNf4()
	Local cFiltro := ""

	cFiltro  +=  "      F3_FILIAL  BETWEEN  '" + MV_PAR01         + "'  AND '" + MV_PAR02        + "' " + CRLF
	cFiltro  +=  "  AND F3_ESPECIE BETWEEN  '" + MV_PAR03         + "'  AND '" + MV_PAR04        + "' " + CRLF
   	cFiltro  +=  "  AND F3_NFISCAL BETWEEN  '" + MV_PAR05         + "'  AND '" + MV_PAR06        + "' " + CRLF
	cFiltro  +=  "  AND F3_SERIE   BETWEEN  '" + MV_PAR07         + "'  AND '" + MV_PAR08        + "' " + CRLF
	cFiltro  +=  "  AND F3_CLIEFOR BETWEEN  '" + MV_PAR09         + "'  AND '" + MV_PAR10        + "' " + CRLF
	cFiltro  +=  "	AND F3_ENTRADA BETWEEN '" + DToS( MV_PAR11 )  + "' AND '" + DToS( MV_PAR12 )  + "' " +CRLF
	cFiltro  +=  "	AND F3_EMISSAO BETWEEN '" + DToS( MV_PAR13 )  + "' AND '" + DToS( MV_PAR14 )  + "' " +CRLF
    cFiltro  += " 	AND F3_DTCANC != ' ' "
 	cFiltro  +=  "	AND D_E_L_E_T_ = ' ' " + CRLF

Return cFiltro
