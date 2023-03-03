#Include "Protheus.ch"
#Include "Topconn.ch"

/*
==========================================================================
Programa...:    ZPECR007
Autor......:    CAOA - Fagner Barreto
Data.......:    20/06/2022
==========================================================================
*/
User Function ZPECR014()
    Local oReport,  oSection

    Private cAliasTMP := GetNextAlias()

	oReport:= TReport():New("ZPECR014", "Relatorio de Divergencia - Pedido x Cadastro.", , {|oReport|  ReportPrint(oReport)})
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

    TRCell():New( oSection  ,"DATA_IMPORTACAO"   ,cAliasTMP ,"Data de Importação"       , PesqPict("VS1","VS1_XDTIMP")   ,TamSx3("VS1_XDTIMP")[1] 	,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"MARCA"            ,cAliasTMP  ,"Marca"                    , PesqPict("VS1","VS1_XMARCA")   ,TamSx3("VS1_XMARCA")[1] 	,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"NUM_ORC"          ,cAliasTMP  ,"Orçamento"                , PesqPict("VS1","VS1_NUMORC")   ,TamSx3("VS1_NUMORC")[1] 	,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"PED_AW"           ,cAliasTMP  ,"Pedido Web"               , PesqPict("VS1","VS1_XPVAW")    ,TamSx3("VS1_XPVAW")[1] 	,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"ORC_DESM"         ,cAliasTMP  ,"Orc. Desmembramento"      , PesqPict("VS1","VS1_XDESMB")   ,TamSx3("VS1_XDESMB")[1] 	,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"TIPO_PEDIDO"      ,cAliasTMP  ,"Tipo Pedido"              , PesqPict("VX5","VX5_DESCRI")   ,20                        ,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"COND_PGTO"        ,cAliasTMP  ,"Cond.Pagto"               , PesqPict("VS1","VS1_FORPAG")   ,TamSx3("VS1_FORPAG")[1] 	,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"DESC_COND_PGTO"   ,cAliasTMP  ,"Desc.Cond.Pagto"          , PesqPict("SE4","E4_DESCRI")    ,TamSx3("E4_DESCRI")[1] 	,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"PROD_SOLIC"       ,cAliasTMP  ,"Produto"                  , PesqPict("VS3","VS3_XITSUB")   ,TamSx3("VS3_XITSUB")[1]   ,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"DESC_SOLIC"       ,cAliasTMP  ,"Descrição Produto"        , PesqPict("SB1","B1_DESC")      ,TamSx3("B1_DESC")[1]      ,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"GRUPO_TRIB"       ,cAliasTMP  ,"Grp Tributação"           , PesqPict("SB1","B1_GRTRIB")    ,TamSx3("B1_GRTRIB")[1]    ,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"TES"              ,cAliasTMP  ,"TES"                      , PesqPict("VS3","VS3_CODTES")   ,TamSx3("VS3_CODTES")[1]   ,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"VALOR"            ,cAliasTMP  ,"Valor"                    , PesqPict("VS3","VS3_VALTOT")   ,TamSx3("VS3_VALTOT")[1]   ,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"ERRO01"           ,cAliasTMP  ,"ERRO01"                   , PesqPict("SB1","B1_DESC")      ,30                        ,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"ERRO02"           ,cAliasTMP  ,"ERRO02"                   , PesqPict("SB1","B1_DESC")      ,30                        ,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"ERRO03"           ,cAliasTMP  ,"ERRO03"                   , PesqPict("SB1","B1_DESC")      ,30                        ,/*lPixel*/,/* {|| }*/)
    TRCell():New( oSection  ,"ERRO04"           ,cAliasTMP  ,"ERRO04"                   , PesqPict("SB1","B1_DESC")      ,30                        ,/*lPixel*/,/* {|| }*/)

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
      
        oSection:Cell( "DATA_IMPORTACAO" ):SetValue( Alltrim( SToD((cAliasTMP)->DATA_IMPORTACAO )) ) 
        oSection:Cell( "MARCA" ):SetValue( Alltrim( (cAliasTMP)->MARCA ) )           
        oSection:Cell( "NUM_ORC" ):SetValue( Alltrim( (cAliasTMP)->NUM_ORC  ) )        
        oSection:Cell( "PED_AW" ):SetValue( Alltrim( (cAliasTMP)->PED_AW  ) )         
        oSection:Cell( "ORC_DESM" ):SetValue( Alltrim( (cAliasTMP)->ORC_DESM   ) )      
        oSection:Cell( "TIPO_PEDIDO" ):SetValue( Alltrim( (cAliasTMP)->TIPO_PEDIDO ) )     
        oSection:Cell( "COND_PGTO" ):SetValue( Alltrim( (cAliasTMP)->COND_PGTO ) )        
        oSection:Cell( "DESC_COND_PGTO" ):SetValue( Alltrim( (cAliasTMP)->DESC_COND_PGTO  ) ) 
        oSection:Cell( "PROD_SOLIC" ):SetValue( Alltrim( (cAliasTMP)->PROD_SOLIC ) )      
        oSection:Cell( "DESC_SOLIC" ):SetValue( Alltrim( (cAliasTMP)->DESC_SOLIC ) )      
        oSection:Cell( "GRUPO_TRIB" ):SetValue( Alltrim( (cAliasTMP)->GRUPO_TRIB  ) )     
        oSection:Cell( "TES" ):SetValue( Alltrim( (cAliasTMP)->TES ) )             
        oSection:Cell( "VALOR" ):SetValue( Alltrim( (cAliasTMP)->VALOR  ) )          
        oSection:Cell( "ERRO01" ):SetValue( Alltrim( (cAliasTMP)->ERRO01 ) )          
        oSection:Cell( "ERRO02" ):SetValue( Alltrim( (cAliasTMP)->ERRO02  ) )         
        oSection:Cell( "ERRO03" ):SetValue( Alltrim( (cAliasTMP)->ERRO03  ) )         
        oSection:Cell( "ERRO04" ):SetValue( Alltrim( (cAliasTMP)->ERRO04   ) )        

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

cQuery := " "
cQuery += " SELECT * FROM ( "    + CRLF
cQuery += " 				SELECT 	VS1.VS1_XDTIMP				AS	DATA_IMPORTACAO, "    + CRLF
cQuery += " 					VS1.VS1_XMARCA					AS 	MARCA, "    + CRLF
cQuery += " 					VS1.VS1_NUMORC					AS 	NUM_ORC, "    + CRLF
cQuery += " 					VS1.VS1_XPVAW					AS 	PED_AW,"    + CRLF
cQuery += " 					VS1.VS1_XDESMB					AS	ORC_DESM,"    + CRLF
cQuery += " 					RTRIM(VX5_DESCRI)				AS	TIPO_PEDIDO,"    + CRLF
cQuery += " 					VS1.VS1_FORPAG					AS	COND_PGTO,"    + CRLF
cQuery += " 					SE4.E4_DESCRI					AS	DESC_COND_PGTO,"    + CRLF
cQuery += " 					VS3.VS3_XITSUB					AS	PROD_SOLIC, "    + CRLF
cQuery += " 					SB1.B1_DESC						AS	DESC_SOLIC,"    + CRLF
cQuery += " 			       	SB1.B1_GRTRIB				    AS GRUPO_TRIB,"    + CRLF
cQuery += " 			       	VS3.VS3_CODTES					AS TES,"    + CRLF
cQuery += " 			       	VS3.VS3_VALTOT					AS VALOR,"    + CRLF
cQuery += " 			       	CASE "    + CRLF
cQuery += " 			            WHEN SB1.B1_MSBLQL = '1' 	THEN 'ERRO01: PRODUTO BLOQUEADO' "    + CRLF
cQuery += " 			            ELSE ' ' "    + CRLF
cQuery += " 			        END AS ERRO01,"    + CRLF
cQuery += " 			        CASE "    + CRLF
cQuery += " 			            WHEN SB1.B1_GRTRIB = ' ' 	THEN 'ERRO02: GRUPO DE TRIBUTAÇÃO NÃO INFORMADO NO PRODUTO' "    + CRLF
cQuery += " 			            ELSE ' ' "    + CRLF
cQuery += " 			        END AS ERRO02,"    + CRLF
cQuery += " 			        CASE "    + CRLF
cQuery += " 			            WHEN VS3.VS3_CODTES = ' ' 	THEN 'ERRO03: TES NÃO PREENCHIDA'"    + CRLF
cQuery += " 			            ELSE ' ' "    + CRLF
cQuery += " 			        END AS ERRO03,"    + CRLF
cQuery += " 					CASE "    + CRLF
cQuery += " 			            WHEN VS3.VS3_VALTOT = 0 	THEN 'ERRO03: PREÇO NÃO PREENCHIDO'"    + CRLF
cQuery += " 			            ELSE ' ' "    + CRLF
cQuery += " 			        END AS ERRO04"    + CRLF
cQuery += " 			FROM " + RetSQLName( 'VS1' ) + " VS1"    + CRLF
cQuery += " 				INNER JOIN " + RetSQLName( 'VS3' ) + " VS3"    + CRLF
cQuery += " 					ON VS3.VS3_FILIAL = VS1.VS1_FILIAL"    + CRLF
cQuery += " 					AND VS3.VS3_NUMORC = VS1.VS1_NUMORC "    + CRLF
cQuery += " 					AND VS3.D_E_L_E_T_ = ' '"    + CRLF
cQuery += " 				INNER JOIN " + RetSQLName( 'SB1' ) + " SB1"    + CRLF
cQuery += " 					ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "'"    + CRLF
cQuery += " 					AND SB1.B1_COD = VS3.VS3_XITSUB"    + CRLF
cQuery += " 					AND SB1.D_E_L_E_T_ = ' '"    + CRLF
cQuery += " 				LEFT JOIN " + RetSQLName( 'VX5' ) + " VX5"    + CRLF
cQuery += " 					ON VX5.VX5_FILIAL = '" + FWxFilial('VX5') + "'"    + CRLF
cQuery += " 					AND VX5.VX5_CHAVE = 'Z00' "    + CRLF
cQuery += " 					AND VX5.VX5_CODIGO =  VS1.VS1_XTPPED"    + CRLF
cQuery += " 					AND VX5.D_E_L_E_T_ = ' '"    + CRLF
cQuery += " 				LEFT JOIN " + RetSQLName( 'SE4' ) + " SE4"    + CRLF
cQuery += " 					ON SE4.E4_FILIAL = '" + FWxFilial('SE4') + "'"    + CRLF
cQuery += " 					AND SE4.E4_CODIGO = VS1.VS1_FORPAG"    + CRLF
cQuery += " 					AND	SE4.D_E_L_E_T_ = ' '"    + CRLF
cQuery += " 			WHERE VS1.VS1_FILIAL = '" + FWxFilial('VS1') + "'"    + CRLF
cQuery += " 			AND VS1.VS1_STATUS <> 'C' "    + CRLF
cQuery += " 			AND VS1.D_E_L_E_T_ = ' '"    + CRLF
cQuery += " 			ORDER BY VS1_XPVAW DESC "    + CRLF
cQuery += " 			)TMP"    + CRLF
cQuery += " WHERE TMP.ERRO01 <> ' ' OR TMP.ERRO02 <> ' ' OR TMP.ERRO03 <> ' ' OR TMP.ERRO04 <> ' '"    + CRLF

    // Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

Return
