#Include 'Protheus.ch'
#Include 'Topconn.ch'
#Include "TOTVS.CH"
/*
=====================================================================================
Programa.:              ZESTR001
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              23/10/2023
Descricao / Objetivo:   Relatorio de Conferencia de inventario.
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/

User Function ZESTR001(_cMestre, _cLocal, _cProduto)

	Local aArea		  	:= GetArea()
	Local aParamBox 	:= {}
	Local aRet 			:= {}

	aAdd(aParamBox,{2 ,"Diferença ?:" ,"Saldo Protheus x Saldo Wis",{"Saldo Protheus x Saldo Wis","Saldo Protheus x Contagem Mestre","Contagem Mestre x Contagem Eleita", "Saldo Protheus x Contagem Eleita", "Contagem Eleita x Saldo Wis", "Completo"},100,"",.F.})
    
	If ParamBox(aParamBox,"Parametros para geração do Arquivo...",@aRet)

        Processa( {|| zProcRel(aRet, _cMestre, _cLocal, _cProduto) }, "Imprimindo Relatório", "Processando aguarde...", .f.)
		
	EndIf

RestArea(aArea)

Return()

/*
=====================================================================================
Programa.:              zProcRel
Autor....:              CAOA - Evandro A Mariano dos Santos 
Data.....:              23/10/2023
Descricao / Objetivo:   Relatorio de divergencia
Doc. Origem:            
Solicitante:            
Uso......:              
Obs......:
=====================================================================================
*/

Static Function zProcRel(_aRetParam, _cMestre, _cLocal, _cProduto)

	Local cQuery	  	:= ""
    Local nOpcFile	    := GETF_LOCALHARD+GETF_RETDIRECTORY+GETF_NETWORKDRIVE
    Local cArquivo         := ""
	Local cAliasTRB		:= GetNextAlias()
	//Local cArquivo	  	:= GetTempPath()+'inventario'+SUBSTRING(dtoc(date()),1,2)+SUBSTRING(dtoc(date()),4,2)+SUBSTRING(dtoc(date()),9,2)+'_'+SUBSTRING(time(),1,2) +SUBSTRING(time(),4,2) +SUBSTRING(time(),7,2)+'.xml'
	Local oFWMsExcel
	Local oExcel
  	Local nTotReg		:= 0
    Local nProc         := 1

    cArquivo := AllTrim(cGetFile("*.*","Local para salvar o relatorio",,,.F.,nOpcFile,.F.,))
    If !Empty(cArquivo)
        cArquivo := cArquivo + "relatorio_inventario_mestre_"+Alltrim(_cMestre)+"_"+AllTrim(_cLocal)+"_" + StrTran(DTOC(Date()),'/','-') + "_" + StrTran(TIME(),':','_') + ".xml"

    //Criando o objeto que irá gerar o conteúdo do Excel
        oFWMsExcel := FWMSExcel():New()

        //Aba - Gympass
        oFWMsExcel:AddworkSheet("Relatorio")

        //Criando a Tabela

        oFWMsExcel:AddTable("Relatorio","Planilha01")
        //FWMsExcel():AddColumn(< cWorkSheet >, < cTable >, < cColumn >, < nAlign >, < nFormat >, < lTotal >)-> NIL
        oFWMsExcel:AddColumn("Relatorio","Planilha01","Empresa Wis"            		,1  ,1  )
        oFWMsExcel:AddColumn("Relatorio","Planilha01","Produto"                     ,1  ,1  )
        oFWMsExcel:AddColumn("Relatorio","Planilha01","Descrição"                   ,1  ,1  )
        oFWMsExcel:AddColumn("Relatorio","Planilha01","Local"                       ,1  ,1  )
        oFWMsExcel:AddColumn("Relatorio","Planilha01","Saldo Protheus (SB2)"   	    ,3  ,2  )
        oFWMsExcel:AddColumn("Relatorio","Planilha01","Contagem (SBK)"              ,3  ,2  )
        oFWMsExcel:AddColumn("Relatorio","Planilha01","Contagem Efetiva (SB7)" 	    ,3  ,2  )
        oFWMsExcel:AddColumn("Relatorio","Planilha01","Saldo Wis (RgLog)"           ,3  ,2  )
        
        If Select( (cAliasTRB) ) > 0
            (cAliasTRB)->(DbCloseArea())
        EndIf

        cQuery := " "
        cQuery += " SELECT 	VIEW_GERAL.EMP_WIS " + CRLF
        cQuery += " 		,VIEW_GERAL.B2_COD " + CRLF
        cQuery += " 		,VIEW_GERAL.B1_DESC " + CRLF
        cQuery += " 		,VIEW_GERAL.B2_LOCAL " + CRLF
        cQuery += " 		,VIEW_GERAL.SB2 " + CRLF
        cQuery += " 		,VIEW_GERAL.ZZK " + CRLF
        cQuery += " 		,VIEW_GERAL.SB7 " + CRLF
        cQuery += " 		,NVL(VIEW_GERAL.QTDE_WIS,0) AS SALDO_WIS " + CRLF
        cQuery += " FROM ( " + CRLF
        cQuery += " 				SELECT * FROM (	SELECT	DECODE " + CRLF
        cQuery += " 										( " + CRLF
        cQuery += " 											TRIM(SBM.BM_CODMAR), " + CRLF
        cQuery += " 											'HYU', 1006, " + CRLF
        cQuery += " 											'SBR', 1006, " + CRLF
        cQuery += " 											'CHE', 1002 " + CRLF
        cQuery += " 										)                    AS EMP_WIS " + CRLF
        cQuery += " 										,SB2.B2_COD " + CRLF
        cQuery += " 										,SB1.B1_DESC " + CRLF
        cQuery += " 										,SB2.B2_LOCAL " + CRLF
        cQuery += " 										,NVL(SB2.B2_QATU,0)  AS SB2 " + CRLF
        cQuery += " 										,NVL(ZZK.QTDEZZK,0)  AS ZZK " + CRLF
        cQuery += " 										,NVL(SB7.QTDESB7,0)  AS SB7  " + CRLF
        cQuery += " 								FROM " +  RetSQLName("SB2") +" SB2 " + CRLF
        cQuery += " 									INNER JOIN " +  RetSQLName("SB1") +" SB1  " + CRLF
        cQuery += " 								     	ON SB1.B1_FILIAL = '" + FWxFilial('SB1') + "'  " + CRLF
        cQuery += " 									    AND SB1.B1_COD = SB2.B2_COD  " + CRLF
        cQuery += " 								    	AND SB1.D_E_L_E_T_ = ' '  " + CRLF
        cQuery += " 									LEFT JOIN " +  RetSQLName("SBM") +" SBM  " + CRLF
        cQuery += " 										ON SB1.B1_FILIAL = SBM.BM_FILIAL " + CRLF
        cQuery += " 										AND SBM.BM_GRUPO = SB1.B1_GRUPO " + CRLF
        cQuery += " 										AND SBM.D_E_L_E_T_ = ' '      " + CRLF
        cQuery += " 									FULL JOIN ( " + CRLF
        cQuery += " 												 SELECT ZZKA.ZZK_PRODUT, ZZKA.ZZK_LOCAL, SUM(ZZKA.ZZK_QTCONT) QTDEZZK FROM " +  RetSQLName("ZZK") +" ZZKA " + CRLF
        cQuery += " 												 WHERE ZZKA.D_E_L_E_T_ = ' ' " + CRLF
        cQuery += " 												 AND ZZKA.ZZK_MESTRE = '"+_cMestre+"' " + CRLF
        cQuery += " 												 AND ZZKA.ZZK_STATUS IN ('3','6')                          " + CRLF
        cQuery += " 												 GROUP BY ZZKA.ZZK_PRODUT, ZZKA.ZZK_LOCAL " + CRLF
        cQuery += " 												)ZZK " + CRLF
        cQuery += " 									ON SB2.B2_COD = ZZK.ZZK_PRODUT " + CRLF
        cQuery += " 									AND SB2.B2_LOCAL = ZZK.ZZK_LOCAL " + CRLF
        cQuery += " 									FULL JOIN ( " + CRLF
        cQuery += " 												 SELECT SB7A.B7_COD, SB7A.B7_LOCAL, SUM(SB7A.B7_QUANT) QTDESB7 FROM " +  RetSQLName("SB7") +" SB7A " + CRLF
        cQuery += " 												 WHERE SB7A.D_E_L_E_T_ = ' ' " + CRLF
        cQuery += " 												 AND SB7A.B7_DOC = '"+_cMestre+"' " + CRLF
        cQuery += " 												 GROUP BY SB7A.B7_COD, SB7A.B7_LOCAL " + CRLF
        cQuery += " 												)SB7 " + CRLF
        cQuery += " 									ON SB2.B2_COD = SB7.B7_COD " + CRLF
        cQuery += " 									AND SB2.B2_LOCAL = SB7.B7_LOCAL " + CRLF
        cQuery += " 								WHERE SB2.B2_FILIAL = '" + FWxFilial('SB2') + "' " + CRLF
        cQuery += " 								AND SB2.B2_LOCAL = '"+_cLocal+"'   " + CRLF
        cQuery += " 								AND SB2.D_E_L_E_T_ = ' ' " + CRLF
        cQuery += " 							) VIEW_PROTHEUS " + CRLF
        cQuery += " 				FULL JOIN (	SELECT 	WIS.CD_PRODUTO, " + CRLF
        cQuery += " 									WIS.CD_EMPRESA, " + CRLF
        cQuery += " 									NVL((SUM(WIS.QT_ESTOQUE - WIS.QT_RESERVA_SAIDA - WIS.QT_TRANSITO_SAIDA)),0) AS QTDE_WIS " + CRLF
        cQuery += " 							FROM WIS.V_ENDERECO_ESTOQUE@DBLINK_WISPROD WIS " + CRLF
        cQuery += " 							GROUP BY WIS.CD_PRODUTO, WIS.CD_EMPRESA " + CRLF
        cQuery += " 						) VIEW_WIS  " + CRLF
        cQuery += " 				ON RTRIM(LTRIM(VIEW_WIS.CD_PRODUTO)) = RTRIM(LTRIM(VIEW_PROTHEUS.B2_COD)) " + CRLF
        cQuery += " 				AND VIEW_WIS.CD_EMPRESA = VIEW_PROTHEUS.EMP_WIS " + CRLF
        cQuery += " 			) VIEW_GERAL " + CRLF
        cQuery += " WHERE VIEW_GERAL.B2_COD <> ' ' " + CRLF
        If !Empty(_cProduto)
            cQuery += " AND VIEW_GERAL.B2_COD = '"+_cProduto+"'   " + CRLF
        EndIf

        If _aRetParam[01] == "Saldo Protheus x Saldo Wis"
            cQuery += " AND VIEW_GERAL.SB2 <> VIEW_GERAL.QTDE_WIS " + CRLF
        EndIf

        If _aRetParam[01] == "Saldo Protheus x Contagem Mestre"
            cQuery += " AND VIEW_GERAL.SB2 <> VIEW_GERAL.ZZK " + CRLF
        EndIf
    
        If _aRetParam[01] == "Contagem Mestre x Contagem Eleita"
            cQuery += " AND VIEW_GERAL.SZK <> VIEW_GERAL.SB7" + CRLF
        EndIf

        If _aRetParam[01] == "Saldo Protheus x Contagem Eleita"
            cQuery += " AND VIEW_GERAL.SB2 <> VIEW_GERAL.SB7" + CRLF
        EndIf

        If _aRetParam[01] == "Contagem Eleita x Saldo Wis"
            cQuery += " AND VIEW_GERAL.SB7 <> VIEW_GERAL.QTDE_WIS" + CRLF
        EndIf
        
        cQuery += "  ORDER BY VIEW_GERAL.B2_COD "

        // Executa a consulta.
        DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTRB, .T., .T. )

        DbSelectArea((cAliasTRB))
        nTotReg := Contar(cAliasTRB,"!Eof()")
        (cAliasTRB)->(dbGoTop())

        Procregua(nTotReg)

        If (cAliasTRB)->(EoF())
            FWAlertWarning("Não existe dados para serem exibidos, verifique os parametros iniciais.", "Atenção")
            (cAliasTRB)->(DbCloseArea())
            Return()
        Endif

        While !(cAliasTRB)->(EoF())

            // Incrementa a mensagem na régua.
            IncProc("Imprimindo: " + cValToChar(nProc) + " - " + cValToChar(nTotReg) + "...")       

            oFWMsExcel:AddRow(	"Relatorio","Planilha01",{;
                                                            (cAliasTRB)->EMP_WIS,;
                                                            (cAliasTRB)->B2_COD,;
                                                            (cAliasTRB)->B1_DESC,;
                                                            (cAliasTRB)->B2_LOCAL,;
                                                            (cAliasTRB)->SB2,;
                                                            (cAliasTRB)->ZZK,;
                                                            (cAliasTRB)->SB7,;
                                                            (cAliasTRB)->SALDO_WIS})
        
            (cAliasTRB)->(DbSkip()) 
            nProc++
        EndDo

        //Ativando o arquivo e gerando o xml
        oFWMsExcel:Activate()
        oFWMsExcel:GetXMLFile(cArquivo)
        
        //Abrindo o excel e abrindo o arquivo xml
        oExcel := MsExcel():New() 			    //Abre uma nova conexão com Excel
        oExcel:WorkBooks:Open(cArquivo) 	    //Abre uma planilha
        oExcel:SetVisible(.T.) 				    //Visualiza a planilha
        oExcel:Destroy()						//Encerra o processo do gerenciador de tarefas

        (cAliasTRB)->(DbCloseArea())
    Else
            Help( ,, "Inventario Pecas",, 'É necessario informar o local para gravação do relatorio!', 1, 0 )
    EndIF

Return()

