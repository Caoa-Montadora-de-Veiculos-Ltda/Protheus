#Include "Protheus.ch"
#Include "Topconn.ch"

/*
=====================================================================================
Programa.:              ZPECR019
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              04/07/2022
Descricao / Objetivo:   Relatorio de Estoque Geral
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
User Function ZPECR019()
    
    Local oReport 
    Local oSection

    Private cAliasTMP := GetNextAlias()

	oReport:= TReport():New("ZPECR019",;
                            "Relatorio de Estoque Geral",;
                            Padr("ZPECR019",10),;
                            {|oReport|  ReportPrint(oReport)},;
                            "Relatorio de Estoque Geral")
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
    
    TRCell():New( oSection  ,"PRODUTO"	        ,cAliasTMP  ,'Produto'	                    ,PesqPict("SB1","B1_COD")       ,TamSx3("B1_COD")[1] 	    ,/*lPixel*/ ,)
    TRCell():New( oSection  ,"DESCRICAO"	    ,cAliasTMP  ,'Descrição'	                ,                               ,TamSx3("B1_DESC")[1] 	    ,/*lPixel*/ ,)
    TRCell():New( oSection  ,"ARM01"	        ,cAliasTMP  ,'Saldo 01'  	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"ARM55"	        ,cAliasTMP  ,'Saldo 55'  	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"ARM61"	        ,cAliasTMP  ,'Saldo 61'  	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"ARM62"	        ,cAliasTMP  ,'Saldo 62'  	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"ARM65"	        ,cAliasTMP  ,'Saldo 65'  	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"ARM80"	        ,cAliasTMP  ,'Saldo 80'  	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"ARM81"	        ,cAliasTMP  ,'Saldo 81'  	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"CONSOLIDADO"      ,cAliasTMP  ,'Consolidado'	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    
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
    cQuery += " SELECT 	SB1.B1_COD				AS PRODUTO, "	+ CRLF 
    cQuery += "         SB1.B1_DESC				AS DESCRICAO, "	+ CRLF
    cQuery += "         NVL(SB201.B2_QATU,0)	AS ARM01, "	+ CRLF
    cQuery += "         NVL(SB255.B2_QATU,0)	AS ARM55, "	+ CRLF
    cQuery += "         NVL(SB261.B2_QATU,0)	AS ARM61, "	+ CRLF
    cQuery += "         NVL(SB262.B2_QATU,0)	AS ARM62, "	+ CRLF
    cQuery += "         NVL(SB265.B2_QATU,0)	AS ARM65, "	+ CRLF
    cQuery += "         NVL(SB280.B2_QATU,0)	AS ARM80, "	+ CRLF
    cQuery += "         NVL(SB281.B2_QATU,0)	AS ARM81 "	+ CRLF
    cQuery += "         (NVL(SB201.B2_QATU,0)+NVL(SB255.B2_QATU,0)+NVL(SB261.B2_QATU,0)+NVL(SB262.B2_QATU,0)+NVL(SB265.B2_QATU,0)+NVL(SB280.B2_QATU,0)+NVL(SB281.B2_QATU,0)) AS CONSOLIDADO "	+ CRLF
    cQuery += " FROM " + RetSQLName( 'SB1' ) + " SB1 "	+ CRLF
    cQuery += "     LEFT JOIN " + RetSQLName( 'SB2' ) + " SB201 "	+ CRLF
    cQuery += "         ON SB201.B2_FILIAL = '" + FWxFilial('SB2') + "' "	+ CRLF
    cQuery += "         AND SB201.B2_COD = SB1.B1_COD "	+ CRLF
    cQuery += "         AND SB201.B2_LOCAL = '01' "	+ CRLF
    cQuery += "         AND SB201.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += "     LEFT JOIN " + RetSQLName( 'SB2' ) + " SB255 "	+ CRLF
    cQuery += "         ON SB255.B2_FILIAL = '" + FWxFilial('SB2') + "' "	+ CRLF
    cQuery += "         AND SB255.B2_COD = SB1.B1_COD "	+ CRLF
    cQuery += "         AND SB255.B2_LOCAL = '55' "	+ CRLF
    cQuery += "         AND SB255.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += "     LEFT JOIN " + RetSQLName( 'SB2' ) + " SB261 "	+ CRLF
    cQuery += "         ON SB261.B2_FILIAL = '" + FWxFilial('SB2') + "' "	+ CRLF
    cQuery += "         AND SB261.B2_COD = SB1.B1_COD "	+ CRLF
    cQuery += "         AND SB261.B2_LOCAL = '61' "	+ CRLF
    cQuery += "         AND SB261.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += "     LEFT JOIN " + RetSQLName( 'SB2' ) + " SB262 "	+ CRLF
    cQuery += "         ON SB262.B2_FILIAL = '" + FWxFilial('SB2') + "' "	+ CRLF
    cQuery += "         AND SB262.B2_COD = SB1.B1_COD "	+ CRLF
    cQuery += "         AND SB262.B2_LOCAL = '62' "	+ CRLF
    cQuery += "         AND SB262.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += "     LEFT JOIN " + RetSQLName( 'SB2' ) + " SB265 "	+ CRLF
    cQuery += "         ON SB265.B2_FILIAL = '" + FWxFilial('SB2') + "' "	+ CRLF
    cQuery += "         AND SB265.B2_COD = SB1.B1_COD "	+ CRLF
    cQuery += "         AND SB265.B2_LOCAL = '65' "	+ CRLF
    cQuery += "         AND SB265.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += "     LEFT JOIN " + RetSQLName( 'SB2' ) + " SB280 "	+ CRLF
    cQuery += "         ON SB280.B2_FILIAL = '" + FWxFilial('SB2') + "' "	+ CRLF
    cQuery += "         AND SB280.B2_COD = SB1.B1_COD "	+ CRLF
    cQuery += "         AND SB280.B2_LOCAL = '80' "	+ CRLF
    cQuery += "         AND SB280.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += "     LEFT JOIN " + RetSQLName( 'SB2' ) + " SB281 "	+ CRLF
    cQuery += "         ON SB281.B2_FILIAL = '" + FWxFilial('SB2') + "' "	+ CRLF
    cQuery += "         AND SB281.B2_COD = SB1.B1_COD "	+ CRLF
    cQuery += "         AND SB281.B2_LOCAL = '81' "	+ CRLF
    cQuery += "         AND SB281.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += " WHERE SB1.B1_FILIAL = '" + FWxFilial('SB1') + "' "	+ CRLF
    If !Empty(MV_PAR01) 
        cQuery += " AND SB1.B1_COD = '" + MV_PAR01 + "' "	+ CRLF
    EndIf
    cQuery += " AND ( NVL(SB201.B2_QATU,0) + NVL(SB255.B2_QATU,0) + NVL(SB261.B2_QATU,0) + NVL(SB262.B2_QATU,0) + NVL(SB265.B2_QATU,0) + NVL(SB280.B2_QATU,0) + NVL(SB281.B2_QATU,0) ) <> 0 "	+ CRLF
    cQuery += " AND SB1.D_E_L_E_T_ = ' ' "	+ CRLF

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

        TRCell():New( oSection  ,"PRODUTO"	        ,cAliasTMP  ,'Produto'	                    ,PesqPict("SB1","B1_COD")       ,TamSx3("B1_COD")[1] 	    ,/*lPixel*/ ,)
    TRCell():New( oSection  ,"DESCRICAO"	    ,cAliasTMP  ,'Descrição'	                ,                               ,TamSx3("B1_DESC")[1] 	    ,/*lPixel*/ ,)
    TRCell():New( oSection  ,"ARM01"	        ,cAliasTMP  ,'Saldo 01'  	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"ARM55"	        ,cAliasTMP  ,'Saldo 55'  	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"ARM61"	        ,cAliasTMP  ,'Saldo 61'  	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"ARM62"	        ,cAliasTMP  ,'Saldo 62'  	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"ARM65"	        ,cAliasTMP  ,'Saldo 65'  	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"ARM80"	        ,cAliasTMP  ,'Saldo 80'  	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"ARM81"	        ,cAliasTMP  ,'Saldo 81'  	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"CONSOLIDADO"      ,cAliasTMP  ,'Consolidado'	                ,PesqPict("SB2","B2_QATU")      ,TamSx3("B2_QATU")[1]      	,/*lPixel*/ ,)

        oSection:Cell( "PRODUTO"):SetValue((cAliasTMP)->PRODUTO)
        oSection:Cell( "DESCRICAO"):SetValue(SToD((cAliasTMP)->DESCRICAO))
        oSection:Cell( "ARM01"):SetValue((cAliasTMP)->ARM01)
        oSection:Cell( "ARM55"):SetValue((cAliasTMP)->ARM55)
        oSection:Cell( "ARM61"):SetValue((cAliasTMP)->ARM61)
        oSection:Cell( "ARM62"):SetValue((cAliasTMP)->ARM62)
        oSection:Cell( "ARM65"):SetValue((cAliasTMP)->ARM65)
        oSection:Cell( "ARM80"):SetValue((cAliasTMP)->ARM80)
        oSection:Cell( "ARM81"):SetValue((cAliasTMP)->ARM81)
        oSection:Cell( "CONSOLIDADO"):SetValue((cAliasTMP)->CONSOLIDADO)
        
        oSection:PrintLine()	

	    (cAliasTMP)->(dbSkip() )
	
	EndDo               
	oSection:Finish()	           

Return()
