#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"
/*
=====================================================================================
Programa.:              ZPECR025
Autor....:              TOTVS - Reinaldo Rabelo
Data.....:              29/02/24
Descricao / Objetivo:   Relatorio de Divergencia Protheus x WIS
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZPECR025()
    
	Local oReport
	Local aArea 	:= FwGetArea()
	Local cPedAw    := SPACE(20)
	Local cOrc      := SPACE(08)
	Local cPedWeb   := SPACE(08)
	Local cCod      := SPACE(23)
	Local cTp_Ped	:= space(03)
	Local _aCombo	:= {"   ","CHE", "HYU", "SUB"}
	Local cCNPJ		:= SPACE(14)
	Local aPergs 	:={}
		
	Private MV_PAR01    := ""
	Private aRetP       := {}
	Private dDataI      := Date()
	Private dDataF      := Date()

	Private cTabela 	:= GetNextAlias()
	Private cDtPickIni  
	Private cDtPickFim
	Private cOrcamento
	Private cPed_Web
	Private cProduto
	Private cMarca
	Private cTipo
	Private cGrupo
	Private cStatusPed
	Private cCodCliente
	Private cLojaCliente

	//Relatório disponível apenas para Franco da Rocha
	IF !( ( AllTrim(FwCodEmp()) == "2020" .And. AllTrim(FwFilial()) == "2001" ) .Or. ( AllTrim(FwCodEmp()) == "9010" .And. AllTrim(FwFilial()) == "HAD1" ) ) //Empresa 02-Franco da Rocha | 90- HMB
		Help( , ,OemToAnsi("Atenção"),,OemToAnsi("Este relatório não é valido para esta empresa."),4,1)   
	    Break
	EndIf
	//Array para montagem do ParamBox	
	aAdd( aPergs ,{1,	"Pedido"				,cPedAw		 ,"@!", 		, ""	    ,'.T.'	,50	,.F.	})	//1
	aAdd( aPergs ,{1,	"Orçamento" 			,cOrc  		 ,"@!", 		, "VS1ORC"	,'.T.'	,20	,.F.	})  //2
	aAdd( aPergs ,{1,	"Pedido Web" 			,cPedWeb	 ,"@!", 		, ""	    ,'.T.'	,20	,.F.	})  //3
	aadd( aPergs, {1,	"Data Inicial"			,dDataI		 ,"@D", 		, ""     	,  "" 	,60	,.T.	})	//4
	aadd( aPergs, {1,	"Data Final"			,dDataF		 ,"@D", 		, ""     	,  "" 	,60	,.T.	})	//5
	aAdd( aPergs ,{1,	"Código" 				,cCod  		 ,"@!", 		, "SB1"  	,'.T.'	,90	,.F.	})  //6
	aAdd( aPergs ,{2,	"Marca" 				,_aCombo[1]	 ,_aCombo 	    , 30 		,  "" 	,	.F.		})  //7
	aAdd( aPergs ,{1,	"Tipo Pedido"  			,cTp_Ped	 ,"@!", 		, "Z00"  	,'.T.'	,20	,.F.	})  //8
	aAdd( aPergs ,{1,	"CNPJ Cliente"			,cCNPJ  	 ,"@!", 		, "CLICGC"	,'.T.'	,90	,.F.	})  //11
	
	//Monta o ParamBox
	If ParamBox(aPergs, "Parâmetros p/ Relatório", @aRetP, , , , , , , , ,.T.) 
		
		cPickIni  	:= IIF( !Empty(aRetP[01]) , aRetP[01] , '00070400')
		cPickFim  	:= IIF( !Empty(aRetP[01]) , aRetP[01] , 'ZZZZZZZZ')
		cOrcamento  := Alltrim(aRetP[02])
		cPed_Web    := Alltrim(aRetP[03])
		cDtPickIni  := IIF( !Empty(aRetP[04]) , DToS(aRetP[04]) , "20220101"  )
		cDtPickFim	:= IIF( !Empty(aRetP[05]) , DToS(aRetP[05]) , DToS(Date()))
		cProduto    := alltrim( aRetP[06] )
		cMarca		:= alltrim( aRetP[07] )
		cTipo       := Alltrim( aRetP[08] )
		cCodCliente := posicione('SA1' , 3 , XFilial('SA1') + aRetP[09] ,"A1_COD"   )
		cLojaCliente:= posicione('SA1' , 3 , XFilial('SA1') + aRetP[09] , "A1_LOJA" )
		
		oReport := fReportDef()
		oReport:PrintDialog()
	EndIf

	FWRestArea(aArea)

Return

/*
=====================================================================================
Programa.:              fReportDef
Autor....:              TOTVS - Reinaldo Rabelo
Data.....:              29/02/24
Descricao / Objetivo:   Monta as Definições para geração do Relatrório
Doc. Origem:            
Solicitante:           
Uso......:              ZPECR025
Obs......:
=====================================================================================
*/
Static Function fReportDef() //Definições do relatório

	Local oReport
	Local oSection	:= Nil
		
	oReport:= TReport():New("ZPECR025",;							// --Nome da impressão
                            "Cortes",;  					        // --Título da tela de parâmetros
                            ,;      								// --Grupo de perguntas na SX1
                            {|oReport|  ReportPrint(oReport),};
                            ) 										// --Descrição do relatório
	
	oReport:SetLandScape(.T.)										//--Orientação do relatório como paisagem.
	oReport:HideParamPage(.T.)      								//--Desabilita a impressao da pagina de parametros.
    oReport:HideHeader()        									//--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter()        									//--Define que não será impresso o rodapé padrão da página
    oReport:SetDevice(4)        									//--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    //oReport:SetPreview(.T.)   									//--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2)   									//--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
	oReport:oPage:SetPaperSize(9)									//--Define impressão no papel A4
	oReport:SetLineHeight(50) 										//--Espaçamento entre linhas
	oReport:SetRightAlignPrinter(.T.)								//--Seta que será utilizado o componente do binário para realizar o alinhamento das células que estejam à direita.

	oReport:nFontBody := 12											//--Tamanho da fonte
	//oReport:SetEdit(.T.) 
	//Pergunte(oReport:GetParam(),.F.) 								//--Adicionar as perguntas na SX1

	oSection := TRSection():New(oReport,; 							//--Criando a seção de dados
							OEMToAnsi("Cortes"),;
							{cTabela}) 
	oReport:SetTotalInLine(.F.) 									//--Desabilita o total de linhas
	
	//TRCell():New(oSection2,"CR_DATALIB"	,"SCR"	,'Data Aprov SC'	,/*Picture*/,TamSx3("CR_DATALIB")[1] 	,/*lPixel*/,/* {|| }*/)
	//--Colunas do relatório
	TRCell():New( oSection  ,"MOTIVO_CORTE" ,cTabela ,"Motivo"			,/*cPicture*/,20					  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"PEDIDO"       ,cTabela ,"Pedido"			,/*cPicture*/,TamSx3("VS3_XPICKI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
    TRCell():New( oSection  ,"DATA_PICKING" ,cTabela ,"Data Picking"	,/*cPicture*/,10					  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"PEDIDO_WEB"   ,cTabela ,"Pedido WEB"		,/*cPicture*/,TamSx3("VS1_XPVAW" )[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"ORCAMENTO"    ,cTabela ,"Orçamento"		,/*cPicture*/,TamSx3("VS1_NUMORC")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"DATA_ORC"     ,cTabela ,"Data Orçamento"	,/*cPicture*/,10					  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
    TRCell():New( oSection  ,"DATA_WIS"     ,cTabela ,"Data WIS"		,/*cPicture*/,10					  , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"TIPO_PEDIDO"  ,cTabela ,"Tipo de Pedido"	,/*cPicture*/,TamSx3("VX5_DESCRI")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"MARCA"      	,cTabela ,"Marca"			,/*cPicture*/,TamSx3("VS1_XMARCA")[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"PRODUTO"  	,cTabela ,"Produto"			,/*cPicture*/,TamSx3("B1_COD"    )[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"DESCRICAO"  	,cTabela ,"Descrição"		,/*cPicture*/,TamSx3("B1_DESC"   )[1] , /*lPixel*/, /*{|| code-block de impressao }*/, "LEFT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"QT_PICKING"   ,cTabela ,"Quant. Picking"	,/*cPicture*/,14	                  , /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)	
	TRCell():New( oSection  ,"QT_PROTHEUS"  ,cTabela ,"Quant. Protheus"	,/*cPicture*/,14	                  , /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	TRCell():New( oSection  ,"QT_WIS"      	,cTabela ,"Quant. WIS"		,/*cPicture*/,10	                  , /*lPixel*/, /*{|| code-block de impressao }*/, "RIGHT", /*lLineBreak*/, "LEFT", /*lCellBreak*/, /*nColSpace*/, /*lAutoSize*/, /*nClrBack*/, /*nClrFore*/, .F.)
	
Return oReport
/*
=====================================================================================
Programa.:              ReportPrint()
Autor....:              TOTVS - Reinaldo Rabelo
Data.....:              29/02/24
Descricao / Objetivo:   Gera relatório
Doc. Origem:            
Solicitante:           
Uso......:              ZPECR025
Obs......:
=====================================================================================
*/
Static Function ReportPrint(oReport)

	Local aArea 	:= FWGetArea()
	Local cQry		:= ""
	Local oSectDad  := Nil
	Local nAtual	:= 0
	Local nTotal	:= 0

	//Pegando as secoes do relatório
	oSectDad := oReport:Section(1) //Primeira seção disponível

	//Consulta Principal do Relatrório
	cQry :=  CONS_SEPARACAO()

	//Executando a conulta
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cTabela, .T., .T. )
	
	Count to nTotal					// Pega o Total de Registros
	oReport:SetMeter(nTotal) 		// setando o total da régua.
	
	//Enquanto houver dados
	oSectDad:Init() 
	
	DbSelectArea(cTabela)
	(cTabela)->(DbGotop())
	
	While (cTabela)->(!EoF())
			
			//Incrementando a regua
		nAtual++

		oReport:SetMsgPrint("Imprimindo registo " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + " ...")
		oReport:IncMeter()
		
		oSectDad:Cell("PEDIDO"        ):SetValue(      (cTabela)->PEDIDO        )
		oSectDad:Cell("DATA_ORC"      ):SetValue(StoD( (cTabela)->DATA_ORC    ) )
		oSectDad:Cell("DATA_PICKING"  ):SetValue(StoD( (cTabela)->DATA_PICKING) )
		oSectDad:Cell("DATA_WIS"      ):SetValue(StoD( (cTabela)->DATA_WIS    ) )
		oSectDad:Cell("PEDIDO_WEB"    ):SetValue(      (cTabela)->PEDIDO_WEB    )
		oSectDad:Cell("TIPO_PEDIDO"   ):SetValue(      (cTabela)->TIPO_PEDIDO   )
		oSectDad:Cell("ORCAMENTO"     ):SetValue(      (cTabela)->ORCAMENTO     )
		oSectDad:Cell("MARCA"         ):SetValue(      (cTabela)->MARCA         )
		oSectDad:Cell("PRODUTO"       ):SetValue(      (cTabela)->PRODUTO       )
		oSectDad:Cell("DESCRICAO"     ):SetValue(      (cTabela)->DESCRICAO     )
		oSectDad:Cell("QT_PICKING"    ):SetValue(      (cTabela)->QT_PICKING    )
		oSectDad:Cell("QT_PROTHEUS"   ):SetValue(      (cTabela)->QT_PROTHEUS   )
		oSectDad:Cell("QT_WIS"        ):SetValue(      (cTabela)->QT_WIS        )
		oSectDad:Cell("MOTIVO_CORTE"  ):SetValue(      (cTabela)->MOTIVO_CORTE  )
	
		//Imprimindo a linha atual
		oSectDad:PrintLine()

		(cTabela)->(DbSkip())
	EndDo
	
	oSectDad:Finish()
	
	(cTabela)->(DbCloseArea())

	FwRestArea(aArea)
Return

/*
=====================================================================================
Programa.:              CONS_SEPARACAO()
Autor....:              TOTVS - Reinaldo Rabelo
Data.....:              29/02/24
Descricao / Objetivo:   Consulta base para a Geração do Relatório de Divergencia Protheus X WIS
Doc. Origem:            
Solicitante:           
Uso......:              ZPECR025
Obs......:
=====================================================================================
*/

Static Function CONS_SEPARACAO()
Local cQuery :=  ""

	cQuery += CRLF + WIS_SEPARACAO()                // View que pega a Separação do WIS
	cQuery += CRLF + PROT_SEPARACAO()				// View que pega os Picking da Seperação Protheus

	cQuery += CRLF + " SELECT DISTINCT "
	cQuery += CRLF + "      MRG_PED.PEDIDO                                     , "
	cQuery += CRLF + "      NVL(SEP_PROT.DT_ENTR , '        ')    AS DATA_ORC , "
	cQuery += CRLF + "      NVL(HIST_PROT.DT_PICK, '        ')    AS DATA_PICKING , "
	cQuery += CRLF + "      NVL(SEP_WIS.DT_UPROW , '        ')    AS DATA_WIS     , "
	cQuery += CRLF + "      NVL(HIST_PROT.PED_WEB, 'ND PROTHEUS') AS PEDIDO_WEB   , "
	cQuery += CRLF + "      NVL( "
	cQuery += CRLF + "      ( "
	cQuery += CRLF + "          SELECT  SUBSTR(VX5A.VX5_DESCRI, 1, 20) "
	cQuery += CRLF + "          FROM " + RetSqlName("VX5") + " VX5A "
	cQuery += CRLF + "          WHERE  VX5A.VX5_FILIAL = '" + xFilial('VX5') + "' "
	cQuery += CRLF + "            AND  VX5A.VX5_CHAVE  = 'Z00' "
	cQuery += CRLF + "            AND  VX5A.VX5_CODIGO = HIST_PROT.TP_PED "
	cQuery += CRLF + "      	  AND  VX5A.D_E_L_E_T_ = ' ' ), 'ND PROTHEUS') AS TIPO_PEDIDO , "
	cQuery += CRLF + "      NVL(HIST_PROT.ORCAM, 'ND PROTHEUS') AS ORCAMENTO               , "
	cQuery += CRLF + "      NVL(HIST_PROT.MARCA, 'ND PROTHEUS') AS MARCA                   , "
	cQuery += CRLF + "      MRG_PED.PRODUTO                                                , "
	cQuery += CRLF + "      B1.B1_DESC DESCRICAO                                           , "
	cQuery += CRLF + "		CASE 
	cQuery += CRLF + "			WHEN NVL(HIST_PROT.QT_ORIG, 0) = 0 THEN NVL(SEP_WIS.QT_ORIG,0) "
	cQuery += CRLF + "      ELSE "
	cQuery += CRLF + "            NVL(HIST_PROT.QT_ORIG,0) "
	cQuery += CRLF + "      END                 AS QT_PICKING  , "
	cQuery += CRLF + "      NVL(SEP_PROT.QT, 0) AS QT_PROTHEUS , "
	cQuery += CRLF + "      NVL(SEP_WIS.CONF, 0) QT_WIS        , "
	cQuery += CRLF + "		CASE "
	cQuery += CRLF + "      	WHEN SEP_WIS.CORTE_AUT <> ' '  THEN 'CORTE AUT' "
	cQuery += CRLF + "      	WHEN SEP_WIS.CORTE_MAN <> ' '  THEN 'CORTE MAN' "
	cQuery += CRLF + "      	WHEN SEP_WIS.PED_CANC  <> ' '  THEN 'PED CANC'  "
	cQuery += CRLF + "      	ELSE 'DIVERGENCIA QT' "
	cQuery += CRLF + "		END AS MOTIVO_CORTE "
	cQuery += CRLF + "        "
	cQuery += CRLF + " FROM "

	cQuery += CRLF + MRG_PED()    //Tabela temporaria formada pelas Views das funções PROT_SEPARACAO() e WIS_SEPARACAO() 

	cQuery += CRLF + " LEFT JOIN SEP_WIS "
	cQuery += CRLF + " 		ON  LTRIM(RTRIM(SEP_WIS.PROD)) = LTRIM(RTRIM(MRG_PED.PRODUTO)) "
	cQuery += CRLF + " 		AND SEP_WIS.PED                = MRG_PED.PEDIDO "
	cQuery += CRLF + " LEFT JOIN SEP_PROT "
	cQuery += CRLF + " 		ON  LTRIM(RTRIM(SEP_PROT.PROD)) = LTRIM(RTRIM(MRG_PED.PRODUTO)) "
	cQuery += CRLF + " 		AND SEP_PROT.PED                = MRG_PED.PEDIDO "
	cQuery += CRLF + " LEFT JOIN " + RetSqlName("SB1") + " B1 "
	cQuery += CRLF + " 		ON  B1.D_E_L_E_T_ = ' ' "
	cQuery += CRLF + " 		AND B1.B1_COD     = MRG_PED.PRODUTO "
	cQuery += CRLF + " LEFT JOIN "

	cQuery += CRLF + HIST_PROT() 			//Tabela Temporaia que pega Historico do Pedido Protheus

	cQuery += CRLF + " 		ON  HIST_PROT.PEDIDO  = MRG_PED.PEDIDO "
	cQuery += CRLF + " 		AND HIST_PROT.PRODUTO = MRG_PED.PRODUTO "
	cQuery += CRLF + " WHERE "
	cQuery += CRLF + "        NVL(SEP_WIS.CONF, '0')  != NVL(SEP_PROT.QT, '0') " //Soemnte as divergências de separaçãoo WIS x Protheus "
	
	//Filtros dos Parametros informado no ParamBox
	//-------------------------------------------------------------------------------------
	if !Empty(cOrcamento)
		cQuery += CRLF + "		AND HIST_PROT.ORCAM LIKE '%" + cOrcamento + "%'" 
	EndIf

	if !Empty(cProduto) 
		cQuery += CRLF + "		AND MRG_PED.PRODUTO = '" + cProduto + "' "
	EndIf

	if !Empty(cMarca)
		cQuery += CRLF + "		AND HIST_PROT.MARCA  = '" + cMarca + "' "
	EndIf

	if !Empty(cTipo)
		cQuery += CRLF + "		AND HIST_PROT.TP_PED = '" + cTipo + "' "
	EndIf

	IF !Empty(cPed_Web)
		cQuery += CRLF + "		AND HIST_PROT.PED_WEB LIKE '%" + cPed_Web + "%' "
	EndIf

	if !Empty(cCodCliente)
		cQuery += CRLF + "		AND HIST_PROT.CLIENTE = '" + cCodCliente + "' "
	EndIf

	if !Empty(cLojaCliente) 
        cQuery += CRLF + "		AND HIST_PROT.LOJA = '" + cLojaCliente + "' "
	EndIf
	
	//---------------------------------------------------------------------------------
	
	cQuery += CRLF + " ORDER BY "
	cQuery += CRLF + "        MRG_PED.PEDIDO "

Return cQuery       

/*
=====================================================================================
Programa.:              WIS_SEPARACAO
Autor....:              TOTVS - Reinaldo Rabelo
Data.....:              29/02/24
Descricao / Objetivo:   View que pega a Separação do WIS
Doc. Origem:            
Solicitante:           
Uso......:              ZPECR025
Obs......:
=====================================================================================
*/
Static Function WIS_SEPARACAO()
Local cQuery :=  ""

//CONSULTA DIVERGENCIAS E LINHAS CORTADAS SIGAPEC X WIS
	cQuery += CRLF + " WITH SEP_WIS AS"  //SEPARACAO_WIS"
	cQuery += CRLF + "     ("
	cQuery += CRLF + "         SELECT"
	cQuery += CRLF + "				CASE  "
 	cQuery += CRLF + "                   WHEN LENGTH(CAST(CABWIS.NU_PEDIDO AS VARCHAR(8))) = 6  THEN '00'||CAST(CABWIS.NU_PEDIDO AS VARCHAR(8)) "
 	cQuery += CRLF + "                   WHEN LENGTH(CAST(CABWIS.NU_PEDIDO AS VARCHAR(8))) = 7  THEN '0' ||CAST(CABWIS.NU_PEDIDO AS VARCHAR(8)) "
 	cQuery += CRLF + "                   ELSE CAST(CABWIS.NU_PEDIDO AS VARCHAR(8)) "
 	cQuery += CRLF + "               END AS PED, "
	cQuery += CRLF + "               CAST(DETWIS.CD_PRODUTO AS CHAR(27)) PROD ,"
	cQuery += CRLF + "               CAST(TO_CHAR(DETWIS.DT_UPROW ,'YYYYMMDD') AS VARCHAR(8)) AS DT_UPROW,"
	cQuery += CRLF + "               CASE"
	cQuery += CRLF + "                    WHEN QT_SEPARAR = 0"
	cQuery += CRLF + "                    THEN QT_ORIGINAL"
	cQuery += CRLF + "                    ELSE QT_SEPARAR"
	cQuery += CRLF + "                END AS QT_ORIG ,"
	cQuery += CRLF + "                DETWIS.QT_SEPARAR -"
	cQuery += CRLF + "                CASE"
	cQuery += CRLF + "                    WHEN ( DETWIS.QT_CANCELADA IS NOT NULL OR DETWIS.ID_CORTE    = 'X' OR CABWIS.CD_SITUACAO = 68 )"
	cQuery += CRLF + "                    THEN DETWIS.QT_SEPARAR"
	cQuery += CRLF + "                    ELSE 0"
	cQuery += CRLF + "                END AS CONF                         ,"
	cQuery += CRLF + "                NVL(DETWIS.ID_CORTE, ' ') CORTE_AUT ,"
	cQuery += CRLF + "                CASE"
	cQuery += CRLF + "                    WHEN (DETWIS.QT_CANCELADA IS NOT NULL)"
	cQuery += CRLF + "                    THEN  'X'"
	cQuery += CRLF + "                    ELSE  ' '"
	cQuery += CRLF + "                    END AS CORTE_MAN ,"
	cQuery += CRLF + "                CASE"
	cQuery += CRLF + "                    WHEN (CABWIS.CD_SITUACAO = 68)"
	cQuery += CRLF + "                    THEN 'X'"
	cQuery += CRLF + "                    ELSE ' '"
	cQuery += CRLF + "                END AS PED_CANC"
	cQuery += CRLF + "         FROM WIS.T_DET_PEDIDO_SAIDA@DBLINK_WISPROD DETWIS"
	cQuery += CRLF + "         INNER JOIN  WIS.T_CAB_PEDIDO_SAIDA@DBLINK_WISPROD CABWIS"
	cQuery += CRLF + "             ON     CABWIS.CD_EMPRESA = DETWIS.CD_EMPRESA"
	cQuery += CRLF + "             AND    DETWIS.NU_PEDIDO  = CABWIS.NU_PEDIDO"
	cQuery += CRLF + "             AND    CABWIS.CD_CLIENTE = DETWIS.CD_CLIENTE"
	cQuery += CRLF + "         WHERE"
	cQuery += CRLF + "                    DETWIS.DT_UPROW  BETWEEN TO_DATE('" + cDtPickIni + "', 'YYYYMMDD') and TO_DATE('" + cDtPickFim + "', 'YYYYMMDD')
	cQuery += CRLF + "             AND    CABWIS.NU_PEDIDO BETWEEN " + cPickIni + " AND " + iif(cPickFim < '99999999',cPickFim,'999999999') + " " //--928699--(CORTE AUTOM)--965866--(SEM CORTE)--853656--(CORTE MANUAL) --"
	cQuery += CRLF + "     ) ,"
	
Return cQuery

/*
=====================================================================================
Programa.:              PROT_SEPARACAO()
Autor....:              TOTVS - Reinaldo Rabelo
Data.....:              29/02/24
Descricao / Objetivo:   View que pega os Picking da Seperação Protheus
Doc. Origem:            
Solicitante:           
Uso......:              ZPECR025
Obs......:
=====================================================================================
*/

Static Function PROT_SEPARACAO()
Local cQuery :=  ""
	 
	cQuery += CRLF + "	 SEP_PROT AS " //SEPARA??O PROTHEUS "
	cQuery += CRLF + "     ( "
	cQuery += CRLF + "         SELECT "
	cQuery += CRLF + "                VS3.VS3_XPICKI           AS PED  , "
	cQuery += CRLF + "                VS3.VS3_CODITE           AS PROD , "
	cQuery += CRLF + "                SUM(VS3.VS3_QTDITE)      AS QT, "
	cQuery += CRLF + "                VS1.VS1_DATORC           AS DT_ENTR "
	cQuery += CRLF + "         FROM  " + RetSqlName("VS3") + " VS3 "
	cQuery += CRLF + "         INNER JOIN  " + RetSqlName("VS1") + " VS1 "
	cQuery += CRLF + "             ON     VS1.VS1_FILIAL = VS3.VS3_FILIAL "
	cQuery += CRLF + "             AND    VS1.VS1_NUMORC = VS3.VS3_NUMORC "
	cQuery += CRLF + "             AND    VS1.D_E_L_E_T_ = ' ' "
	cQuery += CRLF + "             AND    VS1.VS1_STATUS NOT IN ( '0' , '3' , 'C' ) "
	cQuery += CRLF + "             AND    VS1.VS1_DATORC BETWEEN '" + cDtPickIni + "' AND '" + cDtPickFim + "' "
	cQuery += CRLF + "         WHERE      VS3.D_E_L_E_T_ = ' ' "
	cQuery += CRLF + "             AND    VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
	cQuery += CRLF + "             AND    VS3.VS3_XPICKI BETWEEN '" + cPickIni + "' AND '" + cPickFim + "' "  "
	cQuery += CRLF + "         GROUP BY "
	cQuery += CRLF + "                VS3.VS3_XPICKI , "
	cQuery += CRLF + "                VS3.VS3_CODITE , "
	cQuery += CRLF + "                VS1.VS1_DATORC) "

Return cQuery

/*
=====================================================================================
Programa.:              MRG_PED()
Autor....:              TOTVS - Reinaldo Rabelo
Data.....:              29/02/24
Descricao / Objetivo:   Tabela Temporaria Faz UNION Protheus X WIS 
						utiliza as View das funções PROT_SEPARACAO() e WIS_SEPARACAO() 
Doc. Origem:            
Solicitante:           
Uso......:              ZPECR025
Obs......:
=====================================================================================
*/

Static Function MRG_PED()
Local cQuery := ""

	cQuery += CRLF + "( "
	cQuery += CRLF + "  SELECT "
	cQuery += CRLF + " 		CASE "
	cQuery += CRLF + "            WHEN LENGTH(CAST(DETWIS.NU_PEDIDO AS VARCHAR(8))) = 6  THEN '00'||CAST(DETWIS.NU_PEDIDO AS VARCHAR(8)) "
	cQuery += CRLF + "            WHEN LENGTH(CAST(DETWIS.NU_PEDIDO AS VARCHAR(8))) = 7  THEN '0' ||CAST(DETWIS.NU_PEDIDO AS VARCHAR(8)) "
	cQuery += CRLF + "            ELSE CAST(DETWIS.NU_PEDIDO AS VARCHAR(8)) "
	cQuery += CRLF + "        END AS PEDIDO , "
	cQuery += CRLF + "      CAST(DETWIS.CD_PRODUTO AS CHAR(27))  AS PRODUTO "
	cQuery += CRLF + "  FROM "
	cQuery += CRLF + "  	WIS.T_DET_PEDIDO_SAIDA@DBLINK_WISPROD DETWIS "
	cQuery += CRLF + "  WHERE "
	cQuery += CRLF + "              DETWIS.DT_UPROW  BETWEEN TO_DATE('" + cDtPickIni + "', 'YYYYMMDD') and TO_DATE('" + cDtPickFim + "', 'YYYYMMDD')
	cQuery += CRLF + "       AND    DETWIS.NU_PEDIDO BETWEEN " + cPickIni + " AND " + iif(cPickFim < '99999999',cPickFim,'999999999') + " "
	cQuery += CRLF + " "
	cQuery += CRLF + " UNION " //--VALIDA??O DE PARIDADE DE LINHAS 
	cQuery += CRLF + "	SELECT DISTINCT "
	cQuery += CRLF + "		VS3.VS3_XPICKI AS PED_PROT , "
	cQuery += CRLF + "      VS3.VS3_CODITE AS PROD_PROT "
	cQuery += CRLF + " FROM " + RetSqlName("VS3") + " VS3 "
	cQuery += CRLF + " WHERE "
	cQuery += CRLF + " 				VS3.D_E_L_E_T_ = ' ' "
	cQuery += CRLF + "      AND     VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
	cQuery += CRLF + "      AND		VS3.VS3_XPICKI BETWEEN '" + cPickIni + "' AND '" + cPickFim + "' "  "
	cQuery += CRLF + " GROUP BY "
	cQuery += CRLF + "		VS3.VS3_XPICKI , "
	cQuery += CRLF + "		VS3.VS3_CODITE ) MRG_PED "

Return cQuery

/*
=====================================================================================
Programa.:              HIST_PROT()
Autor....:              TOTVS - Reinaldo Rabelo
Data.....:              29/02/24
Descricao / Objetivo:   Sub Consulta para pegar Historico do Pedido
Doc. Origem:            
Solicitante:           
Uso......:              ZPECR025
Obs......:
=====================================================================================
*/

Static Function HIST_PROT()
Local cQuery := ""

	cQuery += CRLF + "( "
	cQuery += CRLF + "          SELECT DISTINCT "
	cQuery += CRLF + "                 VS3.VS3_XPICKI                       AS PEDIDO  , "
	cQuery += CRLF + "                 VS3.VS3_CODITE                       AS PRODUTO , "
	cQuery += CRLF + "                 SUM(VS3.VS3_QTDITE)                  AS QT_ORIG , "
	cQuery += CRLF + "                 VS1.VS1_XDTEPI                       AS DT_PICK , "
	cQuery += CRLF + "                 VS1.VS1_XTPPED                       AS TP_PED  , "
	cQuery += CRLF + "                 VS1.VS1_XMARCA                       AS MARCA   , "
	cQuery += CRLF + "                 LISTAGG(RTRIM(VS1.VS1_XPVAW), ', ')  AS PED_WEB , "
	cQuery += CRLF + "                 LISTAGG(RTRIM(VS1.VS1_NUMORC), ', ') AS ORCAM, "
	cQuery += CRLF + "                 VS1.VS1_CLIFAT AS CLIENTE, "
    cQuery += CRLF + "                 VS1.VS1_LOJA   AS LOJA "
	cQuery += CRLF + "          FROM " + RetSqlName("VS3") + " VS3 "
	cQuery += CRLF + "          INNER JOIN " + RetSqlName("VS1") + " VS1 "
	cQuery += CRLF + "          	ON 	VS1.VS1_FILIAL = VS3.VS3_FILIAL "
	cQuery += CRLF + "          	AND VS1.VS1_NUMORC = VS3.VS3_NUMORC "
	cQuery += CRLF + "          WHERE "
	cQuery += CRLF + "                  VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
	cQuery += CRLF + "      	    AND VS3.VS3_XPICKI BETWEEN '" + cPickIni + "' AND '" + cPickFim + "' "  "
	cQuery += CRLF + "          GROUP BY "
	cQuery += CRLF + "                 VS3.VS3_XPICKI , "
	cQuery += CRLF + "                 VS3.VS3_CODITE , "
	cQuery += CRLF + "                 VS1.VS1_XDTEPI , "
	cQuery += CRLF + "                 VS1.VS1_XTPPED , "
	cQuery += CRLF + "                 VS1.VS1_XMARCA , "
	cQuery += CRLF + "                 VS1.VS1_CLIFAT, "
	cQuery += CRLF + "                 VS1.VS1_LOJA   ) HIST_PROT "

Return cQuery
