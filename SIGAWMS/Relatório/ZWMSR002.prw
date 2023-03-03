#Include "Protheus.ch"
#Include "Topconn.ch"

/*
=====================================================================================
Programa.:              ZWMSR002
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              16/12/2020
Descricao / Objetivo:   Relatorio de conferencia das contagens do inventario  
=====================================================================================
*/
User Function ZWMSR002()
    Private oReport, oSection

    Private cAliasTMP := GetNextAlias()

	ReportDef()
	oReport:PrintDialog()

	If Select( cAliasTMP ) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf

Return

/*
=====================================================================================
Programa.:              ReportDef
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              16/12/2020
Descricao / Objetivo:   Definição da estrutura do relatorio
=====================================================================================
*/
Static Function ReportDef()

	oReport:= TReport():New("ZWMSR002",;
                            "Conferencia de Inventario",;
                            "ZWMSR002",;
                            {|oReport|  ReportPrint(oReport)},;
                            "Este relatorio apresenta as contagens e as quantidades nas tabelas de saldos")
	oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
    oReport:HideHeader() //--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter() //--Define que não será impresso o rodapé padrão da página
    oReport:SetDevice(4) //--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    oReport:SetPreview(.T.) //--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2) //--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
    //oReport:SetEdit(.T.) 
	
    Pergunte(oReport:GetParam(),.F.)
	
	oSection := TRSection():New(oReport    ,"Colunas"    ,{cAliasTMP}) 

    TRCell():New( oSection  ,"ZZK_FILIAL"       ,cAliasTMP      ,"Filial"		)
    TRCell():New( oSection  ,"ZZK_MESTRE"       ,cAliasTMP      ,"Mestre"	    )   
    TRCell():New( oSection  ,"ZZK_LOCAL"        ,cAliasTMP      ,"Armazem"		)
    TRCell():New( oSection  ,"ZZK_LOTE"         ,cAliasTMP      ,"Lote"	        )
    TRCell():New( oSection  ,"ZZK_ENDER"        ,cAliasTMP      ,"Endereco"     )
    TRCell():New( oSection  ,"ZZK_NUMSER"       ,cAliasTMP      ,"NumSerie"		)
    TRCell():New( oSection  ,"ZZK_IDUNIT"       ,cAliasTMP      ,"ID Unitiz"    )
    TRCell():New( oSection  ,"ZZK_PRODUT"       ,cAliasTMP      ,"Produto"		)
    TRCell():New( oSection  ,"B1_DESC"          ,cAliasTMP      ,"Descricao"    )
    TRCell():New( oSection  ,"ZZK_DATA"         ,cAliasTMP      ,"Dt Contagem"  )
    TRCell():New( oSection  ,"ZZK_CONTAG"       ,cAliasTMP      ,"Contagem"	    )
    TRCell():New( oSection  ,"ZZK_QTCONT"       ,cAliasTMP      ,"Quantidade"   )
    TRCell():New( oSection  ,"ZZK_QTDELE"       ,cAliasTMP      ,"Qtd Eleita"	)
    TRCell():New( oSection  ,"D14_QTDEST"       ,cAliasTMP      ,"Saldo Wms"    )
    TRCell():New( oSection  ,"BF_QUANT"         ,cAliasTMP      ,"Saldo Ender"	)
    TRCell():New( oSection  ,"B8_SALDO"         ,cAliasTMP      ,"Saldo Lote"   )
    TRCell():New( oSection  ,"SaldoSB2"         ,cAliasTMP      ,"Saldo Armaz"  )
    TRCell():New( oSection  ,"CustoSB9"         ,cAliasTMP      ,"Custo SB9"    )
    TRCell():New( oSection  ,"DifQtEle"         ,cAliasTMP      ,"Arm x QtEle"  )

    oBreak := TRBreak():New(oSection, oSection:Cell("ZZK_PRODUT"), "Total por Produto",nil,"Produtos")
    TRFunction():New(oSection:Cell("ZZK_QTCONT"),/*cId*/,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,.F.,.F.,oSection)
    TRFunction():New(oSection:Cell("ZZK_QTDELE"),'QTDELE',"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,.F.,.F.,oSection)
    TRFunction():New(oSection:Cell("D14_QTDEST"),/*cId*/,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,.F.,.F.,oSection)
    TRFunction():New(oSection:Cell("BF_QUANT")  ,/*cId*/,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,.F.,.F.,oSection)
    TRFunction():New(oSection:Cell("B8_SALDO")  ,/*cId*/,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,.F.,.F.,oSection)
    TRFunction():New(oSection:Cell("SaldoSB2")  ,'SLDSB2',"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,.F.,.F.,oSection)
    TRFunction():New(oSection:Cell("CustoSB9")  ,/*cId*/,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,.F.,.F.,oSection)
    TRFunction():New(oSection:Cell("DifQtEle")  ,'DIFQTD',"ONPRINT",oBreak,/*cTitle*/,/*cPicture*/,;
    {|| oSection:GetFunction("SLDSB2"):GetValue() - oSection:GetFunction("QTDELE"):GetValue() }/*uFormula*/,.F.,.F.,.F.,oSection)

Return

/*
=====================================================================================
Programa.:              ReportPrint
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              16/12/2020
Descricao / Objetivo:   Carga dos registros no relatorio          
=====================================================================================
*/
Static Function ReportPrint(oReport)
    Local cProduto  := ""
    Local nSaldoSB2 := 0

    //WorkArea ativa
    SB2->( DbSetOrder(1) )

    //Monta Tmp
    zTmpRel()

	oReport:SetMeter( Contar(cAliasTMP,"!Eof()") )
	oSection:Init()

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())
    While (cAliasTMP)->(!EoF()) .And. !oReport:Cancel()

        oReport:IncMeter()

        oSection:Cell( "ZZK_FILIAL" ):SetValue( Alltrim( (cAliasTMP)->ZZK_FILIAL    ) )
        oSection:Cell( "ZZK_MESTRE" ):SetValue( Alltrim( (cAliasTMP)->ZZK_MESTRE    ) )
        oSection:Cell( "ZZK_LOCAL"  ):SetValue( Alltrim( (cAliasTMP)->ZZK_LOCAL     ) )
        oSection:Cell( "ZZK_LOTE"   ):SetValue( Alltrim( (cAliasTMP)->ZZK_LOTE      ) )
        oSection:Cell( "ZZK_ENDER"  ):SetValue( Alltrim( (cAliasTMP)->ZZK_ENDER     ) )
        oSection:Cell( "ZZK_NUMSER" ):SetValue( Alltrim( (cAliasTMP)->ZZK_NUMSER    ) )
        oSection:Cell( "ZZK_IDUNIT" ):SetValue( Alltrim( (cAliasTMP)->ZZK_IDUNIT    ) )
        oSection:Cell( "ZZK_PRODUT" ):SetValue( Alltrim( (cAliasTMP)->ZZK_PRODUT    ) )
        oSection:Cell( "B1_DESC"    ):SetValue( Alltrim( (cAliasTMP)->B1_DESC       ) )
        oSection:Cell( "ZZK_DATA"   ):SetValue( IIF( Empty( SToD( (cAliasTMP)->ZZK_DATA   ) ), "", SToD( (cAliasTMP)->ZZK_DATA ) ) )
        oSection:Cell( "ZZK_CONTAG" ):SetValue( AllTrim( (cAliasTMP)->ZZK_CONTAG    ) )
        oSection:Cell( "ZZK_QTCONT" ):SetValue( (cAliasTMP)->ZZK_QTCONT )
        oSection:Cell( "ZZK_QTDELE" ):SetValue( (cAliasTMP)->ZZK_QTDELE )
        oSection:Cell( "D14_QTDEST" ):SetValue( (cAliasTMP)->D14_QTDEST )
        oSection:Cell( "BF_QUANT"   ):SetValue( (cAliasTMP)->BF_QUANT )
        oSection:Cell( "B8_SALDO"   ):SetValue( (cAliasTMP)->B8_SALDO )

        If cProduto != (cAliasTMP)->ZZK_PRODUT
            
            //--Limpa variavel para receber saldo SB2
            nSaldoSB2 := 0

            //--Grava saldo SB2
            If SB2->( DbSeek( FWxFilial("SB2")+(cAliasTMP)->(ZZK_PRODUT+ZZK_LOCAL) ) )
                oSection:Cell( "SaldoSB2"   ):SetValue( nSaldoSB2 := SaldoSB2() )
                //oSection:Cell( "DifQtEle"   ):SetValue( nSaldoSB2 - (cAliasTMP)->ZZK_QTDELE )
            Else
                oSection:Cell( "SaldoSB2"   ):SetValue( 0 )
                //oSection:Cell( "DifQtEle"   ):SetValue( nSaldoSB2 - (cAliasTMP)->ZZK_QTDELE )
            EndIf

            //--Grava custo SB9
            oSection:Cell( "CustoSB9"   ):SetValue( zCustoSB9( (cAliasTMP)->(ZZK_PRODUT), (cAliasTMP)->(ZZK_LOCAL) ) )

        Else
            oSection:Cell( "SaldoSB2"   ):SetValue( 0 )
            //oSection:Cell( "DifQtEle"   ):SetValue( nSaldoSB2 - (cAliasTMP)->ZZK_QTDELE )
            oSection:Cell( "CustoSB9"   ):SetValue( 0 )
        EndIf

        //--Grava produto para pegar a mudança de produto
        cProduto := (cAliasTMP)->ZZK_PRODUT

        oSection:PrintLine()	

	    (cAliasTMP)->(dbSkip() )
	
	EndDo               
	oSection:Finish()         

Return

/*
=====================================================================================
Programa.:              zTmpRel
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              16/12/2020
Descricao / Objetivo:   Consulta usada para carga dos registros do relatorio     
=====================================================================================
*/
Static Function zTmpRel()
    Local cQuery    	:= ""
    
	If Select( cAliasTMP ) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf

    cQuery := " SELECT ZZK_FILIAL, ZZK_MESTRE, ZZK_LOCAL, ZZK_LOTE, ZZK_ENDER, ZZK_NUMSER, ZZK_IDUNIT, B1_DESC, "   + CRLF
    cQuery += " ZZK_PRODUT, ZZK_DATA, ZZK_CONTAG, ZZK_QTCONT, ZZK_QTDELE, D14_QTDEST, BF_QUANT, B8_SALDO "          + CRLF
    cQuery += " FROM " + RetSQLName( 'ZZK' ) + " ZZK "                                                              + CRLF
    cQuery += " LEFT JOIN " + RetSQLName("D14") + " D14 " 												            + CRLF
    cQuery += "     ON D14.D14_FILIAL   = ZZK.ZZK_FILIAL "                                                          + CRLF
    cQuery += "     AND D14.D14_LOCAL   = ZZK.ZZK_LOCAL "                                                           + CRLF
    cQuery += "     AND D14.D14_LOTECT  = ZZK.ZZK_LOTE  "                                                           + CRLF
    cQuery += "     AND D14.D14_ENDER   = ZZK.ZZK_ENDER "                                                           + CRLF
    cQuery += "     AND D14.D14_IDUNIT  = ZZK.ZZK_IDUNIT "                                                          + CRLF
    cQuery += "     AND D14.D14_PRODUT  = ZZK.ZZK_PRODUT "                                                          + CRLF
    cQuery += "     AND D14.D_E_L_E_T_ = ' '   " 														            + CRLF
    cQuery += " LEFT JOIN " + RetSQLName("SBF") + " SBF " 												            + CRLF
    cQuery += "     ON SBF.BF_FILIAL   = ZZK.ZZK_FILIAL "                                                           + CRLF
    cQuery += "     AND SBF.BF_LOCAL   = ZZK.ZZK_LOCAL "                                                            + CRLF
    cQuery += "     AND SBF.BF_LOTECTL = ZZK.ZZK_LOTE "                                                             + CRLF
    cQuery += "     AND SBF.BF_LOCALIZ = ZZK.ZZK_ENDER "                                                            + CRLF
    cQuery += "     AND SBF.BF_NUMSERI = ZZK.ZZK_NUMSER "                                                           + CRLF
    cQuery += "     AND SBF.BF_PRODUTO = ZZK.ZZK_PRODUT "                                                           + CRLF
    cQuery += "     AND SBF.D_E_L_E_T_ = ' '   " 														            + CRLF
    cQuery += " LEFT JOIN " + RetSQLName("SB8") + " SB8 " 												            + CRLF
    cQuery += "     ON SB8.B8_FILIAL   = ZZK.ZZK_FILIAL "                                                           + CRLF
    cQuery += "     AND SB8.B8_LOCAL = ZZK.ZZK_LOCAL " 												                + CRLF
    cQuery += "     AND SB8.B8_LOTECTL = ZZK.ZZK_LOTE " 												            + CRLF
    cQuery += "     AND SB8.B8_PRODUTO = ZZK.ZZK_PRODUT " 												            + CRLF
    cQuery += "     AND SB8.D_E_L_E_T_ = ' '   " 														            + CRLF
    cQuery += " LEFT JOIN " + RetSQLName("SB1") + " SB1 " 												            + CRLF
    cQuery += "     ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "                                                 + CRLF
    cQuery += "     AND SB1.B1_COD = ZZK.ZZK_PRODUT "                                                               + CRLF
    cQuery += "     AND SB1.D_E_L_E_T_ = ' '   " 														            + CRLF
    cQuery += " WHERE ZZK.ZZK_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "                            + CRLF
    cQuery += "     AND ZZK.ZZK_MESTRE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "                          + CRLF
    cQuery += "     AND ZZK.ZZK_LOCAL BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "                           + CRLF
    cQuery += "     AND ZZK.ZZK_LOTE BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "                            + CRLF
    cQuery += "     AND ZZK.ZZK_ENDER BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "                           + CRLF
    cQuery += "     AND ZZK.ZZK_NUMSER BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "                          + CRLF
    cQuery += "     AND ZZK.ZZK_IDUNIT BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' "                          + CRLF
    cQuery += "     AND ZZK.ZZK_PRODUT BETWEEN '" + MV_PAR15 + "' AND '" + MV_PAR16 + "' "                          + CRLF    
    cQuery += "     AND ZZK.ZZK_CONTAG = (  SELECT MAX(ZZK_CONTAG) " 							                    + CRLF
    cQuery += "                             FROM ZZK010 ZZKB " 							                            + CRLF
    cQuery += "                             WHERE ZZKB.ZZK_MESTRE = ZZK.ZZK_MESTRE  " 				                + CRLF
    cQuery += "                                 AND ZZKB.ZZK_LOCAL  = ZZK.ZZK_LOCAL " 					            + CRLF
    cQuery += "                                 AND ZZKB.ZZK_LOTE   = ZZK.ZZK_LOTE " 					            + CRLF
    cQuery += "                                 AND ZZKB.ZZK_ENDER  = ZZK.ZZK_ENDER " 				                + CRLF
    cQuery += "                                 AND ZZKB.ZZK_NUMSER = ZZK.ZZK_NUMSER " 					            + CRLF
    cQuery += "                                 AND ZZKB.ZZK_IDUNIT = ZZK.ZZK_IDUNIT " 					            + CRLF
    cQuery += "                                 AND ZZKB.ZZK_PRODUT = ZZK.ZZK_PRODUT " 					            + CRLF
    cQuery += "                                 AND ZZKB.D_E_L_E_T_ = ' '   ) " 					                + CRLF
    cQuery += "     AND ZZK.D_E_L_E_T_ = ' '   " 														            + CRLF
    cQuery += " ORDER BY  ZZK_FILIAL, ZZK_MESTRE, ZZK_LOCAL, ZZK_PRODUT, ZZK_CONTAG "                               + CRLF

    cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

Return

/*
=====================================================================================
Programa.:              zTmpRel
Autor....:              CAOA - Fagner Ferraz Barreto
Data.....:              16/12/2020
Descricao / Objetivo:   Consulta usada para carga dos registros do relatorio     
=====================================================================================
*/
Static Function zCustoSB9(cProd, cLocal)
    Local cAliasSB9 := GetNextAlias()
    Local nCusto    := 0
    Local cQuery    := ""
    
    cQuery := " SELECT B9_VINI1 "                                           + CRLF
    cQuery += " FROM " + RetSQLName( 'SB9' ) + " SB9 "                      + CRLF
    cQuery += " WHERE SB9.B9_FILIAL = '" + FWxFilial( 'SB9' ) + "' "        + CRLF
    cQuery += "  AND SB9.B9_COD = '" + cProd + "' "                         + CRLF
    cQuery += "  AND SB9.B9_LOCAL = '" + cLocal + "' "                      + CRLF
    cQuery += "  AND SB9.D_E_L_E_T_ = ' ' "                                 + CRLF
    cQuery += "  AND SB9.R_E_C_N_O_ = (  "                                  + CRLF
    cQuery += "     SELECT MAX(SB9B.R_E_C_N_O_) "                           + CRLF
    cQuery += "     FROM " + RetSQLName( 'SB9' ) + " SB9B "                 + CRLF
    cQuery += "     WHERE SB9B.B9_FILIAL = '" + FWxFilial( 'SB9' ) + "' "   + CRLF
    cQuery += "      AND SB9B.B9_COD = '" + cProd + "' "                    + CRLF
    cQuery += "      AND SB9B.B9_LOCAL = '" + cLocal + "' "                 + CRLF
    cQuery += "      AND SB9B.D_E_L_E_T_ = ' ' ) "                          + CRLF   

    cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSB9, .T., .T. )

    If ( cAliasSB9 )->( !EOF() )
        nCusto := ( cAliasSB9 )->B9_VINI1
    EndIf
    ( cAliasSB9 )->( DbCloseArea() )

Return nCusto
