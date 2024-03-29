#Include "Protheus.ch"
#Include "Topconn.ch"

//---------------------------------------------------------------------------
User Function ZFISR014()
    Local oReport,  oSection

    Private cAliasTMP := GetNextAlias()

	oReport:= TReport():New("ZFISR006",;
                            "Saidas Canc.",;
                            "ZFISR001R2",;
                            {|oReport|  ReportPrint(oReport)},;
                            "Este relatorio efetua a impress�o das notas fiscais de saida canceladas")
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
    oReport:HideHeader() //--Define que n�o ser� impresso o cabe�alho padr�o da p�gina
    oReport:HideFooter() //--Define que n�o ser� impresso o rodap� padr�o da p�gina
    oReport:SetDevice(4) //--Define o tipo de impress�o selecionado. Op��es: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    oReport:SetPreview(.T.) //--Define se ser� apresentada a visualiza��o do relat�rio antes da impress�o f�sica
    oReport:SetEnvironment(2) //--Define o ambiente para impress�o 	Ambiente: 1-Server e 2-Client
    //oReport:SetEdit(.T.) 
	
	//Verifica os par�metros selecionados via Pergunte
    Pergunte(oReport:GetParam(),.F.)
	
	oSection := TRSection():New(oReport    ,"Colunas"    ,{cAliasTMP}) 
    
    TRCell():New( oSection  ,"F3_FILIAL"  ,cAliasTMP  ,"Empresa"        )
    TRCell():New( oSection  ,"F3_OBSERV"  ,cAliasTMP  ,"Observa��o"	    )
    TRCell():New( oSection  ,"F3_ESPECIE" ,cAliasTMP  ,"Especie"        )
    TRCell():New( oSection  ,"F3_NFISCAL" ,cAliasTMP  ,"Nota Fiscal"    )
    TRCell():New( oSection  ,"F3_SERIE"   ,cAliasTMP  ,"Serie"		    )
    TRCell():New( oSection  ,"F3_CLIEFOR" ,cAliasTMP  ,"Cliente"		)
    TRCell():New( oSection  ,"F3_LOJA"    ,cAliasTMP  ,"Loja/Cli"		)
    TRCell():New( oSection  ,"F3_EMISSAO" ,cAliasTMP  ,"Emiss�o"		)
    TRCell():New( oSection  ,"F3_ENTRADA" ,cAliasTMP  ,"Dt Digita��o"	)
    TRCell():New( oSection  ,"F3_CHVNFE"  ,cAliasTMP  ,"Chave NFe"	    )
    TRCell():New( oSection  ,"F3_DESCRET" ,cAliasTMP  ,"Descri��o"	    )

    oReport:PrintDialog()

Return


//----------------------------------------------------------
Static Function  ReportPrint(oReport)
    Local oSection     := oReport:Section(1)

    //Monta Tmp
    zTmpRadio4()

	oReport:SetMeter( Contar(cAliasTMP,"!Eof()") )
	// Sec��o 1
	oSection:Init()

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())
    While (cAliasTMP)->(!EoF()) .And. !oReport:Cancel()

        // Incrementa a mensagem na r�gua.
        oReport:IncMeter()
      
        oSection:Cell( "F3_FILIAL"  ):SetValue( Alltrim( (cAliasTMP)->F3_FILIAL    ) ) //--Empresa
        oSection:Cell( "F3_OBSERV"  ):SetValue( Alltrim( (cAliasTMP)->F3_OBSERV    ) ) //--Observa��o
        oSection:Cell( "F3_ESPECIE" ):SetValue( Alltrim( (cAliasTMP)->F3_ESPECIE   ) ) //--Especie
        oSection:Cell( "F3_NFISCAL" ):SetValue( Alltrim( (cAliasTMP)->F3_NFISCAL   ) ) //--Nota Fiscal
        oSection:Cell( "F3_SERIE"   ):SetValue( Alltrim( (cAliasTMP)->F3_SERIE     ) ) //--Serie
        oSection:Cell( "F3_CLIEFOR" ):SetValue( Alltrim( (cAliasTMP)->F3_CLIEFOR   ) ) //--Cliente
        oSection:Cell( "F3_LOJA"    ):SetValue( Alltrim( (cAliasTMP)->F3_LOJA      ) ) //--Loja/Cli
        oSection:Cell( "F3_EMISSAO" ):SetValue( IIF( Empty( SToD( (cAliasTMP)->F3_EMISSAO ) ), "", SToD( (cAliasTMP)->F3_EMISSAO ) ) ) //--Emiss�o
        oSection:Cell( "F3_ENTRADA" ):SetValue( IIF( Empty( SToD( (cAliasTMP)->F3_ENTRADA ) ), "", SToD( (cAliasTMP)->F3_ENTRADA ) ) ) //--Dt Digita��o
        oSection:Cell( "F3_CHVNFE"  ):SetValue( AllTrim( (cAliasTMP)->F3_CHVNFE     ) ) //--Chave NFe
        oSection:Cell( "F3_DESCRET" ):SetValue( AllTrim( (cAliasTMP)->F3_DESCRET    ) ) //--Descri��o

        oSection:PrintLine()	

	    (cAliasTMP)->(dbSkip() )
	
	EndDo               
	oSection:Finish()	           

Return

//----------------------------------------------------------
Static Function zTmpRadio4()
    Local cQuery    	:= ""
    
	If Select( cAliasTMP ) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf

    cQuery := " SELECT F3_FILIAL, F3_OBSERV, F3_ESPECIE, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, "	+ CRLF
    cQuery += " F3_EMISSAO, F3_CHVNFE, F3_DESCRET, F3_ENTRADA "											+ CRLF
    cQuery += " FROM " + RetSQLName( 'SF3' ) + " SF3 " 													+ CRLF
    cQuery += " INNER JOIN " + RetSQLName( 'SF2' ) + " SF2 "											+ CRLF
    cQuery += " 	ON SF2.F2_FILIAL = '" + FWxFilial('SF2') + "' "	 								    + CRLF
    cQuery += " 	AND SF2.F2_DOC = SF3.F3_NFISCAL "													+ CRLF
    cQuery += " 	AND SF2.F2_SERIE = SF3.F3_SERIE "													+ CRLF
    cQuery += " 	AND SF2.F2_CLIENTE = SF3.F3_CLIEFOR "												+ CRLF
    cQuery += " 	AND SF2.F2_LOJA = SF3.F3_LOJA "														+ CRLF

    If !Empty( MV_PAR17 )
        cQuery += " 	AND SF2.F2_EST = '" + MV_PAR17 + "' " 											+ CRLF
    EndIf

    cQuery += " INNER JOIN " + RetSQLName( 'SD2' ) + " SD2 "											+ CRLF
    cQuery += " 	ON SD2.D2_FILIAL = '" + FWxFilial('SD2') + "' "	 								    + CRLF
    cQuery += " 	AND SD2.D2_DOC = SF3.F3_NFISCAL "													+ CRLF
    cQuery += " 	AND SD2.D2_SERIE = SF3.F3_SERIE "													+ CRLF
    cQuery += " 	AND SD2.D2_CLIENTE = SF3.F3_CLIEFOR "												+ CRLF
    cQuery += " 	AND SD2.D2_LOJA = SF3.F3_LOJA "														+ CRLF
    cQuery += " 	AND SD2.D2_COD BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' " 					+ CRLF

    If !Empty( MV_PAR15 )
        cQuery += " 	AND SD2.D2_TES = '" + MV_PAR15 + "' " 											+ CRLF
    EndIf

    If !Empty( MV_PAR16 )
        cQuery += " 	AND SD2.D2_CF = '" + MV_PAR16 + "' " 											+ CRLF
    EndIf

    cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 " 												+ CRLF
    cQuery += "		ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "									    + CRLF
    cQuery += "		AND SB1.B1_COD = SD2.D2_COD   "	 													+ CRLF
    cQuery += "		AND SB1.D_E_L_E_T_ = ' ' " 															+ CRLF

    If !Empty( MV_PAR18 )
        cQuery += " 	AND SB1.B1_GRUPO = '" + MV_PAR18 + "' "											+ CRLF
    EndIf

    If !Empty( MV_PAR19 )
        cQuery += " 	AND SB1.B1_POSIPI = '" + MV_PAR19 + "' "										+ CRLF
    EndIf

    cQuery += " WHERE  SF3.F3_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "				+ CRLF
    cQuery += " 	AND SF3.F3_ESPECIE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "				+ CRLF
    cQuery += " 	AND SF3.F3_NFISCAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "				+ CRLF
    cQuery += " 	AND SF3.F3_SERIE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "				+ CRLF
    cQuery += " 	AND SF3.F3_CLIEFOR BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' " 				+ CRLF
    cQuery += " 	AND SF3.F3_EMISSAO BETWEEN '" + DToS(MV_PAR11) + "' AND '" + DToS(MV_PAR12) + "' " 	+ CRLF
    cQuery += " 	AND SF3.F3_DTCANC != ' ' " 															+ CRLF
    cQuery += " 	AND SF3.D_E_L_E_T_ = ' '   " 														+ CRLF

    cQuery += " GROUP BY F3_FILIAL, F3_OBSERV, F3_ESPECIE, F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_LOJA, " + CRLF
    cQuery += " F3_EMISSAO, F3_CHVNFE, F3_DESCRET, F3_ENTRADA  "										+ CRLF

    cQuery += " ORDER BY SF3.F3_FILIAL, SF3.F3_NFISCAL, SF3.F3_SERIE, SF3.F3_CLIEFOR, SF3.F3_LOJA "		+ CRLF	

    cQuery := ChangeQuery(cQuery)

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

Return
