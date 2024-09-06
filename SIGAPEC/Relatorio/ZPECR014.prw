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
	oReport:HideParamPage()     // Desabilita a impressao da pagina de parametros.
    oReport:HideHeader()        //--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter()        //--Define que não será impresso o rodapé padrão da página
    //oReport:SetDevice(1)      //--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    oReport:SetPreview(.T.)     //--Define se será apresentada a visualização do relatório antes da impressão física
    //oReport:SetEnvironment(2) //--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
    //oReport:SetEdit(.T.) 
	
	//Verifica os parâmetros selecionados via Pergunte
    Pergunte(oReport:GetParam(),.F.)
	
	oSection := TRSection():New(oReport    ,"Colunas"    ,{cAliasTMP}) 

    TRCell():New( oSection ,"DATA_IMPORTACAO" ,cAliasTMP ,"Data de Importação"  , PesqPict( "VS1" , "VS1_XDTIMP" ) , TamSx3("VS1_XDTIMP")[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"MARCA"           ,cAliasTMP ,"Marca"               , PesqPict( "VS1" , "VS1_XMARCA" ) , TamSx3("VS1_XMARCA")[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"NUM_ORC"         ,cAliasTMP ,"Orçamento"           , PesqPict( "VS1" , "VS1_NUMORC" ) , TamSx3("VS1_NUMORC")[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"PED_AW"          ,cAliasTMP ,"Pedido Web"          , PesqPict( "VS1" , "VS1_XPVAW"  ) , TamSx3("VS1_XPVAW" )[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"ORC_DESM"        ,cAliasTMP ,"Orc. Desmembramento" , PesqPict( "VS1" , "VS1_XDESMB" ) , TamSx3("VS1_XDESMB")[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"TIPO_PEDIDO"     ,cAliasTMP ,"Tipo Pedido"         , PesqPict( "VX5" , "VX5_DESCRI" ) , 20                      , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"COD_CLI"         ,cAliasTMP ,"Cliente"             , PesqPict( "VS1" , "VS1_CLIFAT" ) , TamSx3("VS1_CLIFAT")[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"LOJA"            ,cAliasTMP ,"Loja"                , PesqPict( "VS1" , "VS1_LOJA"   ) , TamSx3("VS1_LOJA"  )[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"NOME_CLI"        ,cAliasTMP ,"Nome"                , PesqPict( "VS1" , "VS1_NCLIFT" ) , TamSx3("VS1_NCLIFT")[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"ESTADO"          ,cAliasTMP ,"UF"                  , PesqPict( "SA1" , "A1_EST"     ) , TamSx3("A1_EST")[1]     , /*lPixel*/ , /* {|| }*/ )    
    TRCell():New( oSection ,"COND_PGTO"       ,cAliasTMP ,"Cond.Pagto"          , PesqPict( "VS1" , "VS1_FORPAG" ) , TamSx3("VS1_FORPAG")[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"DESC_COND_PGTO"  ,cAliasTMP ,"Desc.Cond.Pagto"     , PesqPict( "SE4" , "E4_DESCRI"  ) , TamSx3("E4_DESCRI" )[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"PROD_SOLIC"      ,cAliasTMP ,"Produto"             , PesqPict( "VS3" , "VS3_XITSUB" ) , TamSx3("VS3_XITSUB")[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"DESC_SOLIC"      ,cAliasTMP ,"Descrição Produto"   , PesqPict( "SB1" , "B1_DESC"    ) , TamSx3("B1_DESC"   )[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"GRUPO_TRIB"      ,cAliasTMP ,"Grp Tributação"      , PesqPict( "SB1" , "B1_GRTRIB"  ) , TamSx3("B1_GRTRIB" )[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"TES"             ,cAliasTMP ,"TES"                 , PesqPict( "VS3" , "VS3_CODTES" ) , TamSx3("VS3_CODTES")[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"VALOR"           ,cAliasTMP ,"Valor"               , PesqPict( "VS3" , "VS3_VALTOT" ) , TamSx3("VS3_VALTOT")[1] , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"STATUS"          ,cAliasTMP ,"Status"              ,                                  , 30                      , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"ERRO01"          ,cAliasTMP ,"ERRO01"              , PesqPict( "SB1" , "B1_DESC"    ) , 30                      , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"ERRO02"          ,cAliasTMP ,"ERRO02"              , PesqPict( "SB1" , "B1_DESC"    ) , 30                      , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"ERRO03"          ,cAliasTMP ,"ERRO03"              , PesqPict( "SB1" , "B1_DESC"    ) , 30                      , /*lPixel*/ , /* {|| }*/ )
    TRCell():New( oSection ,"ERRO04"          ,cAliasTMP ,"ERRO04"              , PesqPict( "SB1" , "B1_DESC"    ) , 30                      , /*lPixel*/ , /* {|| }*/ )

    oReport:PrintDialog()

Return

//----------------------------------------------------------
Static Function  ReportPrint(oReport)
    Local oSection     := oReport:Section(1)
    Local cStatus := ""
    //Monta Tmp
    zTmpQry()

	oReport:SetMeter( Contar(cAliasTMP,"!Eof()") )
	// Secção 1
	oSection:Init()

    DbSelectArea((cAliasTMP))
    (cAliasTMP)->(dbGoTop())
    While (cAliasTMP)->(!EoF()) .And. !oReport:Cancel()

        // Incrementa a mensagem na régua.
        cStatus := alltrim((cAliasTMP)->STATUS) + " - " + alltrim((cAliasTMP)->DESC_STATUS)
        oReport:IncMeter()
      
        oSection:Cell( "DATA_IMPORTACAO" ):SetValue( Alltrim( SToD((cAliasTMP)->DATA_IMPORTACAO ) ) )
        oSection:Cell( "MARCA"           ):SetValue( Alltrim(      (cAliasTMP)->MARCA             ) )
        oSection:Cell( "NUM_ORC"         ):SetValue( Alltrim(      (cAliasTMP)->NUM_ORC           ) )
        oSection:Cell( "PED_AW"          ):SetValue( Alltrim(      (cAliasTMP)->PED_AW            ) )
        oSection:Cell( "ORC_DESM"        ):SetValue( Alltrim(      (cAliasTMP)->ORC_DESM          ) )
        oSection:Cell( "TIPO_PEDIDO"     ):SetValue( Alltrim(      (cAliasTMP)->TIPO_PEDIDO       ) )
        oSection:Cell( "COD_CLI"         ):SetValue( Alltrim(      (cAliasTMP)->COD_CLI           ) )
        oSection:Cell( "LOJA"            ):SetValue( Alltrim(      (cAliasTMP)->LOJA              ) )
        oSection:Cell( "NOME_CLI"        ):SetValue( Alltrim(      (cAliasTMP)->NOME_CLI          ) )
        oSection:Cell( "ESTADO"          ):SetValue( AllTrim(      (cAliasTMP)->ESTADO            ) )
        oSection:Cell( "COND_PGTO"       ):SetValue( Alltrim(      (cAliasTMP)->COND_PGTO         ) )
        oSection:Cell( "DESC_COND_PGTO"  ):SetValue( Alltrim(      (cAliasTMP)->DESC_COND_PGTO    ) )
        oSection:Cell( "PROD_SOLIC"      ):SetValue( Alltrim(      (cAliasTMP)->PROD_SOLIC        ) )
        oSection:Cell( "DESC_SOLIC"      ):SetValue( Alltrim(      (cAliasTMP)->DESC_SOLIC        ) )
        oSection:Cell( "GRUPO_TRIB"      ):SetValue( Alltrim(      (cAliasTMP)->GRUPO_TRIB        ) )
        oSection:Cell( "TES"             ):SetValue( Alltrim(      (cAliasTMP)->TES               ) )
        oSection:Cell( "VALOR"           ):SetValue( Alltrim(      (cAliasTMP)->VALOR             ) )
        oSection:Cell( "STATUS"          ):SetValue(                cStatus                         )
        oSection:Cell( "ERRO01"          ):SetValue( Alltrim(      (cAliasTMP)->ERRO01            ) )
        oSection:Cell( "ERRO02"          ):SetValue( Alltrim(      (cAliasTMP)->ERRO02            ) )
        oSection:Cell( "ERRO03"          ):SetValue( Alltrim(      (cAliasTMP)->ERRO03            ) )
        oSection:Cell( "ERRO04"          ):SetValue( Alltrim(      (cAliasTMP)->ERRO04            ) )

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
    cQuery += CRLF + " SELECT * FROM ( "
    cQuery += CRLF + " 			SELECT 	VS1.VS1_XDTIMP		AS	DATA_IMPORTACAO, "
    cQuery += CRLF + " 					VS1.VS1_XMARCA		AS 	MARCA, "
    cQuery += CRLF + " 					VS1.VS1_NUMORC		AS 	NUM_ORC, "
    cQuery += CRLF + "                  VS1.VS1_STATUS      AS  STATUS, "
    cQuery += CRLF + "                  SX5.X5_DESCRI       AS  DESC_STATUS, "
    cQuery += CRLF + " 					VS1.VS1_XPVAW		AS 	PED_AW,"
    cQuery += CRLF + " 					VS1.VS1_XDESMB		AS	ORC_DESM,"
    cQuery += CRLF + " 					VS1.VS1_CLIFAT      AS  COD_CLI, "
    cQuery += CRLF + " 					VS1.VS1_LOJA        AS  LOJA, "
    cQuery += CRLF + " 					VS1.VS1_NCLIFT      AS  NOME_CLI,"
    cQuery += CRLF + "                  SA1.A1_EST          AS  ESTADO,"
    cQuery += CRLF + " 					RTRIM(VX5_DESCRI)	AS	TIPO_PEDIDO,"
    cQuery += CRLF + " 					VS1.VS1_FORPAG		AS	COND_PGTO,"
    cQuery += CRLF + " 					SE4.E4_DESCRI		AS	DESC_COND_PGTO,"
    cQuery += CRLF + " 					VS3.VS3_XITSUB		AS	PROD_SOLIC, "
    cQuery += CRLF + " 					SB1.B1_DESC			AS	DESC_SOLIC,"
    cQuery += CRLF + " 			       	SB1.B1_GRTRIB		AS GRUPO_TRIB,"
    cQuery += CRLF + " 			       	VS3.VS3_CODTES		AS TES,"
    cQuery += CRLF + " 			       	VS3.VS3_VALTOT		AS VALOR,"
    cQuery += CRLF + " 			       	CASE "
    cQuery += CRLF + " 			            WHEN SB1.B1_MSBLQL = '1' 	THEN 'ERRO01: PRODUTO BLOQUEADO' "
    cQuery += CRLF + " 			            ELSE ' ' "
    cQuery += CRLF + " 			        END AS ERRO01,"
    cQuery += CRLF + " 			        CASE "
    cQuery += CRLF + " 			            WHEN SB1.B1_GRTRIB = ' ' 	THEN 'ERRO02: GRUPO DE TRIBUTAÇÃO NÃO INFORMADO NO PRODUTO' "
    cQuery += CRLF + " 			            ELSE ' ' "
    cQuery += CRLF + " 			        END AS ERRO02,"
    cQuery += CRLF + " 			        CASE "
    cQuery += CRLF + " 			            WHEN VS3.VS3_CODTES = ' ' 	THEN 'ERRO03: TES NÃO PREENCHIDA'"
    cQuery += CRLF + " 			            ELSE ' ' "
    cQuery += CRLF + " 			        END AS ERRO03,"
    cQuery += CRLF + " 					CASE "
    cQuery += CRLF + " 			            WHEN VS3.VS3_VALTOT = 0 	THEN 'ERRO03: PREÇO NÃO PREENCHIDO'"
    cQuery += CRLF + " 			            ELSE ' ' "
    cQuery += CRLF + " 			        END AS ERRO04"
    
    cQuery += CRLF + " 			FROM " + RetSQLName( 'VS1' ) + " VS1"
    
    cQuery += CRLF + " 				INNER JOIN " + RetSQLName( 'VS3' ) + " VS3"
    cQuery += CRLF + " 					ON  VS3.VS3_FILIAL = VS1.VS1_FILIAL"
    cQuery += CRLF + " 					AND VS3.VS3_NUMORC = VS1.VS1_NUMORC "
    cQuery += CRLF + " 					AND VS3.D_E_L_E_T_ = ' '"
    
    cQuery += CRLF + " 				INNER JOIN " + RetSQLName( 'SB1' ) + " SB1"
    cQuery += CRLF + " 					ON  SB1.B1_FILIAL = '" + FWxFilial('SB1') + "'"
    cQuery += CRLF + " 					AND SB1.B1_COD = VS3.VS3_XITSUB"
    cQuery += CRLF + " 					AND SB1.D_E_L_E_T_ = ' '"

    cQuery += CRLF + " 				INNER JOIN " + RetSQLName( 'SA1' ) + " SA1"
    cQuery += CRLF + " 					ON  SA1.A1_FILIAL = '" + FWxFilial('SA1') + "' "
    cQuery += CRLF + " 					AND SA1.A1_COD = VS1.VS1_CLIFAT "
    cQuery += CRLF + "                  AND SA1.A1_LOJA = VS1.VS1_LOJA "
    cQuery += CRLF + " 					AND SA1.D_E_L_E_T_ = ' ' "
    
    cQuery += CRLF + " 				LEFT JOIN " + RetSQLName( 'SE4' ) + " SE4"
    cQuery += CRLF + " 					ON SE4.E4_FILIAL = '" + FWxFilial('SE4') + "'"
    cQuery += CRLF + " 					AND SE4.E4_CODIGO = VS1.VS1_FORPAG"
    cQuery += CRLF + " 					AND	SE4.D_E_L_E_T_ = ' '"
    
    cQuery += CRLF + " 				LEFT JOIN " + RetSQLName( 'VX5' ) + " VX5"
    cQuery += CRLF + " 					ON  VX5.VX5_FILIAL = '" + FWxFilial('VX5') + "'"
    cQuery += CRLF + " 					AND VX5.VX5_CHAVE = 'Z00' "
    cQuery += CRLF + " 					AND VX5.VX5_CODIGO =  VS1.VS1_XTPPED"
    cQuery += CRLF + " 					AND VX5.D_E_L_E_T_ = ' '"
    
    cQuery += CRLF + "              LEFT JOIN " + RetSQLName( 'SX5' ) + " SX5  "
    cQuery += CRLF + " 					ON  SX5.X5_FILIAL = '" + FWxFilial('SX5') + "'"
    cQuery += CRLF + "                  AND SX5.X5_TABELA = 'VU' "
    cQuery += CRLF + "                  AND SX5.X5_CHAVE  = VS1.VS1_STATUS "

    cQuery += CRLF + " 			WHERE   VS1.VS1_FILIAL = '" + FWxFilial('VS1') + "'"
    cQuery += CRLF + " 			    AND VS1.VS1_STATUS <> 'C' "
    cQuery += CRLF + " 			    AND VS1.D_E_L_E_T_ = ' '"
    cQuery += CRLF + "              AND VS1.VS1_NUMNFI = ' '"
    cQuery += CRLF + " 			ORDER BY VS1_XPVAW DESC "
    cQuery += CRLF + " 			)TMP"
    cQuery += CRLF + " WHERE TMP.ERRO01 <> ' ' OR TMP.ERRO02 <> ' ' OR TMP.ERRO03 <> ' ' OR TMP.ERRO04 <> ' '"

    // Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

Return
