#Include "Protheus.ch"
#Include "Topconn.ch"

/*
=====================================================================================
Programa.:              ZPECR018
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              04/07/2022
Descricao / Objetivo:   Kardex Notas de Entrada
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/
User Function ZPECR018()
    
    Local oReport 
    Local oSection

    Private cAliasTMP := GetNextAlias()

	oReport:= TReport():New("ZPECR018",;
                            "Kardex de Conferencia de nota fiscal de entrada",;
                            Padr("ZPECR018",10),;
                            {|oReport|  ReportPrint(oReport)},;
                            "Kardex de Conferencia de nota fiscal de entrada")
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
    
    TRCell():New( oSection  ,"NFORIGEM"	        ,cAliasTMP  ,'Origem'	                    ,                               ,15	                        ,/*lPixel*/ ,)
    TRCell():New( oSection  ,"D3_EMISSAO"	    ,cAliasTMP  ,'Data'	                        ,                               ,TamSx3("D3_EMISSAO")[1] 	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"TIPO"	            ,cAliasTMP  ,'Movimentação'  	            ,                               ,10                     	,/*lPixel*/ ,)
    TRCell():New( oSection  ,"D3_LOCAL"	        ,cAliasTMP  ,'Armazem'  	                ,PesqPict("SD3","D3_LOCAL")     ,TamSx3("D3_LOCAL")[1] 	    ,/*lPixel*/ ,)
    TRCell():New( oSection  ,"NFISCAL"	        ,cAliasTMP  ,'Nota Fiscal'     	            ,PesqPict("SF1","F1_DOC")       ,TamSx3("F1_DOC")[1] 	    ,/*lPixel*/ ,)
    TRCell():New( oSection  ,"SERIE"	        ,cAliasTMP  ,'Serie'        	            ,PesqPict("SF1","F1_SERIE")     ,TamSx3("F1_SERIE")[1] 	    ,/*lPixel*/ ,)
    TRCell():New( oSection  ,"FORNECEDOR"       ,cAliasTMP  ,'Cod. Fornecedor' 	            ,PesqPict("SF1","F1_FORNECE")   ,TamSx3("F1_FORNECE")[1]    ,/*lPixel*/ ,)
    TRCell():New( oSection  ,"LOJA"             ,cAliasTMP  ,'Loja'         	            ,PesqPict("SF1","F1_LOJA")      ,TamSx3("F1_LOJA")[1]       ,/*lPixel*/ ,)
    TRCell():New( oSection  ,"D3_COD"           ,cAliasTMP  ,'Produto'    	                ,PesqPict("SD3","D3_COD")       ,TamSx3("D3_COD")[1]        ,/*lPixel*/ ,)
    TRCell():New( oSection  ,"D3_QUANT"         ,cAliasTMP  ,'Qtde'         	            ,PesqPict("SD3","D3_QUANT")     ,TamSx3("D3_QUANT")[1]      ,/*lPixel*/ ,)
    
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

    cQuery += " SELECT 	SD3.D3_EMISSAO, "	+ CRLF
    cQuery += "         CASE "	+ CRLF
    cQuery += "             WHEN SD3.D3_OBSERVA LIKE '%TOTVS%' 	THEN 'TOTVS' "	+ CRLF
    cQuery += "             WHEN SD3.D3_OBSERVA LIKE '%SINC%' 	THEN 'SINC' "	+ CRLF
    cQuery += "             ELSE 'NAO ENCONTRADO' "	+ CRLF
    cQuery += "         END AS NFORIGEM, "	+ CRLF
    cQuery += "         CASE "	+ CRLF 
    cQuery += "             WHEN SD3.D3_TM IN ('010','001') THEN 'AJUSTE' "	+ CRLF
    cQuery += "             WHEN SD3.D3_TM = '999' THEN 'SAIDA' "	+ CRLF
    cQuery += "             WHEN SD3.D3_TM = '499' THEN 'ENTRADA' "	+ CRLF
    cQuery += "             ELSE 'NAO ENCONTRADO' "	+ CRLF
    cQuery += "         END AS TIPO, "	+ CRLF
    cQuery += "         SD3.D3_LOCAL, "	+ CRLF
    cQuery += "         RTRIM(REGEXP_SUBSTR(SD3.D3_OBSERVA, '[^|]+', INSTR(SD3.D3_OBSERVA,':')+1, 1)) 	AS NFISCAL, "	+ CRLF
    cQuery += "         RTRIM(REGEXP_SUBSTR(SD3.D3_OBSERVA, '[^|]+', 1, 2))								AS SERIE, "	+ CRLF
    cQuery += "         SUBSTR((REGEXP_SUBSTR(SD3.D3_OBSERVA, '[^|]+', 1, 3)),1,6)						AS FORNECEDOR, "	+ CRLF
    cQuery += "         SUBSTR((REGEXP_SUBSTR(SD3.D3_OBSERVA, '[^|]+', 1, 4)),1,2)						AS LOJA, "	+ CRLF
    cQuery += "         SD3.D3_COD, "	+ CRLF 
    cQuery += "         SD3.D3_QUANT "	+ CRLF
    cQuery += " FROM " + RetSQLName( 'SD3' ) + " SD3 "	+ CRLF
    cQuery += " WHERE SD3.D3_FILIAL = '" + FWxFilial('SD3') + "' "	+ CRLF
    cQuery += " AND SD3.D3_TM IN ('001','010','499','999') "	+ CRLF
    cQuery += " AND SD3.D3_LOCAL IN ('80','01') "	+ CRLF
    cQuery += " AND SD3.D3_OBSERVA <> ' ' "	+ CRLF
    If !(Empty(MV_PAR01) .And. Empty(MV_PAR02))
        cQuery += " AND SD3.D3_EMISSAO BETWEEN '" + DToS(MV_PAR01) + "'  AND '" + DToS(MV_PAR02) + "' "	+ CRLF
    EndIf
     If !( Empty(MV_PAR03) .And. Empty(MV_PAR04) .And. Empty(MV_PAR05) .And. Empty(MV_PAR06) )
        cQuery += " 	AND RTRIM(REGEXP_SUBSTR(SD3.D3_OBSERVA, '[^|]+', INSTR(SD3.D3_OBSERVA,':')+1, 1)) BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "	+ CRLF 
        cQuery += " 	AND RTRIM(REGEXP_SUBSTR(SD3.D3_OBSERVA, '[^|]+', 1, 2))	 BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "	+ CRLF 
    EndIf
    If !Empty(MV_PAR07)
        cQuery += " AND SD3.D3_COD = '" + MV_PAR07 + "'  "	+ CRLF
    EndIf
    cQuery += " AND SD3.D3_ESTORNO = ' ' "	+ CRLF
    If MV_PAR08 == 2 //TOTVS
        cQuery += " 	AND SD3.D3_OBSERVA LIKE '%SINC%'  "	+ CRLF 
    ElseIf MV_PAR08 == 3 //SINC
        cQuery += " 	AND SD3.D3_OBSERVA LIKE '%TOTVS%' "	+ CRLF 
    EndIf
    cQuery += " AND SD3.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += " ORDER BY D3_COD, SD3.D3_EMISSAO, D3_TM DESC "	+ CRLF
    	
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

        oSection:Cell( "NFORIGEM"):SetValue((cAliasTMP)->NFORIGEM)
        oSection:Cell( "D3_EMISSAO"):SetValue(SToD((cAliasTMP)->D3_EMISSAO))
        oSection:Cell( "TIPO"):SetValue((cAliasTMP)->TIPO)
        oSection:Cell( "D3_LOCAL"):SetValue((cAliasTMP)->D3_LOCAL)
        oSection:Cell( "NFISCAL"):SetValue((cAliasTMP)->NFISCAL)
        oSection:Cell( "SERIE"):SetValue((cAliasTMP)->SERIE)
        oSection:Cell( "FORNECEDOR"):SetValue((cAliasTMP)->FORNECEDOR)
        oSection:Cell( "LOJA"):SetValue((cAliasTMP)->LOJA)
        oSection:Cell( "D3_QUANT"):SetValue((cAliasTMP)->D3_QUANT)
        
        oSection:PrintLine()	

	    (cAliasTMP)->(dbSkip() )
	
	EndDo               
	oSection:Finish()	           

Return()
