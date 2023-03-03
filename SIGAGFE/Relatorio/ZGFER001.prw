#Include "Protheus.ch"
#Include "Topconn.ch"

/*
===========================================================================================
Programa.:              ZGFER001
Autor....:              CAOA - Fagner Barreto
Data.....:              06/09/2022
Descricao / Objetivo:   Relatorio de Amarrações do SIGAGFE      
===========================================================================================
*/
User Function ZGFER001() //--U_ZGFER001()

	Local oReport,  oSection

    Private cAliasTMP := GetNextAlias()

	oReport:= TReport():New("ZGFER001",; //--Nome do relatório
                            "Amarracoes GFE",; //--Título do relatório
                            "ZGFER001",; //--Parâmetros do relatório cadastrado no Dicionário de Perguntas (SX1)
                            {|oReport|  ReportPrint(oReport)},; //--Bloco de código que será executado quando o usuário confirmar a impressão do relatório
                            "Este relatorio efetua a impressão das amarrações do GFE") //--Descrição do relatório
	oReport:HideParamPage()   //--Desabilita a impressao da pagina de parametros.
    oReport:HideHeader()      //--Define que não será impresso o cabeçalho padrão da página
    oReport:HideFooter()      //--Define que não será impresso o rodapé padrão da página
    oReport:SetDevice(4)      //--Define o tipo de impressão selecionado. Opções: 1-Arquivo,2-Impressora,3-Email,4-Planilha, 5-Html e 6-PDF
    oReport:SetPreview(.T.)   //--Define se será apresentada a visualização do relatório antes da impressão física
    oReport:SetEnvironment(2) //--Define o ambiente para impressão 	Ambiente: 1-Server e 2-Client
    //oReport:SetEdit(.T.) 
	
	//Verifica os parâmetros selecionados via Pergunte
    Pergunte(oReport:GetParam(),.F.)
	
	oSection := TRSection():New(oReport    ,"Colunas"    ,{cAliasTMP}) 

    TRCell():New( oSection	,"DC_FILIAL"  	,cAliasTMP	,'DC_FILIAL'	)
    TRCell():New( oSection	,"DC_DANFE"   	,cAliasTMP	,'DC_DANFE'		)
    TRCell():New( oSection	,"DC_DTEMIS"  	,cAliasTMP	,'DC_DTEMIS'	)
    TRCell():New( oSection	,"DC_NRDC"    	,cAliasTMP	,'DC_NRDC'		)
    TRCell():New( oSection	,"DC_SERDC"   	,cAliasTMP	,'DC_SERDC'		)
    TRCell():New( oSection	,"DC_CDTPDC"  	,cAliasTMP	,'DC_CDTPDC'	)
    TRCell():New( oSection	,"DC_SIT"     	,cAliasTMP	,'DC_SIT'   	)
    TRCell():New( oSection	,"DC_NRROM"   	,cAliasTMP	,'DC_NRROM'		)
    TRCell():New( oSection	,"ROM_SIT"    	,cAliasTMP	,'ROM_SIT'    	)
    TRCell():New( oSection	,"ROM_OPER"   	,cAliasTMP	,'ROM_OPER'		)
    TRCell():New( oSection	,"ROM_CLASS"  	,cAliasTMP	,'ROM_CLASS' 	)
    TRCell():New( oSection	,"ROM_DTCRIA" 	,cAliasTMP	,'ROM_DTCRIA'	)
    TRCell():New( oSection	,"ROM_DTSAID" 	,cAliasTMP	,'ROM_DTSAID'	)
	TRCell():New( oSection	,"IMP_SEQ_OCOR"	,cAliasTMP	,'IMP_SEQ_OCOR'	)
    TRCell():New( oSection	,"ARQ_OCOR"   	,cAliasTMP	,'IMP_ARQ_OCOR'	)
    TRCell():New( oSection	,"IMP_DTOCOR" 	,cAliasTMP	,"IMP_DTOCOR"	)
    TRCell():New( oSection	,"OCO_NROCO"  	,cAliasTMP	,"OCO_NROCO"	)
    TRCell():New( oSection	,"OCO_SIT"    	,cAliasTMP	,"OCO_SIT"     	)
    TRCell():New( oSection	,"OCO_DESCR"  	,cAliasTMP	,"OCO_DESCR"   	)
    TRCell():New( oSection	,"OCO_TIPO"   	,cAliasTMP	,"OCO_TIPO"    	)
    TRCell():New( oSection	,"ARQ_CTE"    	,cAliasTMP	,"IMP_ARQ_CTE"	)
    TRCell():New( oSection	,"IMP_CTESIT" 	,cAliasTMP	,"IMP_CTESIT"   )
    TRCell():New( oSection	,"IMP_CHVCTE" 	,cAliasTMP	,"IMP_CHVCTE"   )
    TRCell():New( oSection	,"IMP_NRCTE"  	,cAliasTMP	,"IMP_NRCTE"    )
    TRCell():New( oSection	,"IMP_DTEMIS" 	,cAliasTMP	,"IMP_DTEMIS"   )
    TRCell():New( oSection	,"IMP_VLDF"   	,cAliasTMP	,"IMP_VLDF"     )
    TRCell():New( oSection	,"IMP_PESOR"  	,cAliasTMP	,"IMP_PESOR"    )
    TRCell():New( oSection	,"CAL_NR"     	,cAliasTMP	,"CAL_NR"       )
    TRCell():New( oSection	,"CAL_BASICM" 	,cAliasTMP	,"CAL_BASICM"	)
    TRCell():New( oSection	,"CAL_BASISS" 	,cAliasTMP	,"CAL_BASISS"   )
    TRCell():New( oSection	,"DF_SIT"     	,cAliasTMP	,"DF_SIT"       )
    TRCell():New( oSection	,"DF_NRDF"    	,cAliasTMP	,"DF_NRDF"      )
    TRCell():New( oSection	,"DF_SER"     	,cAliasTMP	,"DF_SER"       )
    TRCell():New( oSection	,"DF_VLDF"    	,cAliasTMP	,"DF_VLDF"      )
    TRCell():New( oSection	,"DF_SITFIS"  	,cAliasTMP	,"DF_SITFIS"    )
    TRCell():New( oSection	,"DF_DTFIS"   	,cAliasTMP	,"DF_DTFIS"     )
    TRCell():New( oSection	,"DF_SITREC"  	,cAliasTMP	,"DF_SITREC"    )
    TRCell():New( oSection	,"DF_DTREC"   	,cAliasTMP	,"DF_DTREC"     )
    TRCell():New( oSection	,"DF_VLDIV"   	,cAliasTMP	,"DF_VLDIV"     )
    TRCell():New( oSection	,"DF_PESO"    	,cAliasTMP	,"DF_PESO"      )
    TRCell():New( oSection	,"NF_PESOB"   	,cAliasTMP	,"NF_PESOB"     )
    TRCell():New( oSection	,"DC_PESOB"   	,cAliasTMP	,"DC_PESOB"     )
	TRCell():New( oSection	,"SEP_PESOB"  	,cAliasTMP	,"SEP_PESOB"   	)
    TRCell():New( oSection	,"NF_PESOC"   	,cAliasTMP	,"NF_PESOC"     )
    TRCell():New( oSection	,"DC_PESOC"   	,cAliasTMP	,"DC_PESOC"     )
	TRCell():New( oSection	,"SEP_PESOC"  	,cAliasTMP	,"SEP_PESOC"    )
    TRCell():New( oSection	,"NF_VALBRUT" 	,cAliasTMP	,"NF_VALBRUT"   )
    TRCell():New( oSection	,"DC_VALBRUT" 	,cAliasTMP	,"DC_VALBRUT"   )
    TRCell():New( oSection	,"SEP_MARCA"  	,cAliasTMP	,"SEP_MARCA"    )
    TRCell():New( oSection	,"SEP_PICKING"	,cAliasTMP	,"SEP_PICKING"  )
    TRCell():New( oSection	,"NF_MENNOTA" 	,cAliasTMP	,"NF_MENNOTA"   )
    oReport:PrintDialog()

Return 

//----------------------------------------------------------
// Impressão do relatório
//----------------------------------------------------------
Static Function  ReportPrint(oReport)
    Local oSection      := oReport:Section(1)

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

        oSection:Cell( "DC_FILIAL"    ):SetValue( (cAliasTMP)->DC_FILIAL  	)
        oSection:Cell( "DC_DANFE"     ):SetValue( (cAliasTMP)->DC_DANFE   	) 
        oSection:Cell( "DC_DTEMIS"    ):SetValue( (cAliasTMP)->DC_DTEMIS  	) 
        oSection:Cell( "DC_NRDC"      ):SetValue( (cAliasTMP)->DC_NRDC		)	 
        oSection:Cell( "DC_SERDC"     ):SetValue( (cAliasTMP)->DC_SERDC		)
        oSection:Cell( "DC_CDTPDC"    ):SetValue( (cAliasTMP)->DC_CDTPDC  	)
        oSection:Cell( "DC_SIT"       ):SetValue( (cAliasTMP)->DC_SIT     	)
        oSection:Cell( "DC_NRROM"     ):SetValue( (cAliasTMP)->DC_NRROM		)
        oSection:Cell( "ROM_SIT"      ):SetValue( (cAliasTMP)->ROM_SIT		)
        oSection:Cell( "ROM_OPER"     ):SetValue( (cAliasTMP)->ROM_OPER		)
        oSection:Cell( "ROM_CLASS"    ):SetValue( (cAliasTMP)->ROM_CLASS  	)
        oSection:Cell( "ROM_DTCRIA"   ):SetValue( (cAliasTMP)->ROM_DTCRIA 	)
        oSection:Cell( "ROM_DTSAID"   ):SetValue( (cAliasTMP)->ROM_DTSAID 	) 
		oSection:Cell( "IMP_SEQ_OCOR" ):SetValue( (cAliasTMP)->IMP_SEQ_OCOR ) 
        oSection:Cell( "ARQ_OCOR"     ):SetValue( (cAliasTMP)->ARQ_OCOR		)
        oSection:Cell( "IMP_DTOCOR"   ):SetValue( (cAliasTMP)->IMP_DTOCOR 	)
        oSection:Cell( "OCO_NROCO"    ):SetValue( (cAliasTMP)->OCO_NROCO  	)  
        oSection:Cell( "OCO_SIT"      ):SetValue( (cAliasTMP)->OCO_SIT    	)
        oSection:Cell( "OCO_DESCR"    ):SetValue( (cAliasTMP)->OCO_DESCR  	)
        oSection:Cell( "OCO_TIPO"     ):SetValue( (cAliasTMP)->OCO_TIPO		)
        oSection:Cell( "ARQ_CTE"      ):SetValue( (cAliasTMP)->ARQ_CTE		)
        oSection:Cell( "IMP_CTESIT"   ):SetValue( (cAliasTMP)->IMP_CTESIT 	)
        oSection:Cell( "IMP_CHVCTE"   ):SetValue( (cAliasTMP)->IMP_CHVCTE 	)
        oSection:Cell( "IMP_NRCTE"    ):SetValue( (cAliasTMP)->IMP_NRCTE  	)
        oSection:Cell( "IMP_DTEMIS"   ):SetValue( (cAliasTMP)->IMP_DTEMIS	)
        oSection:Cell( "IMP_VLDF"     ):SetValue( (cAliasTMP)->IMP_VLDF		)
        oSection:Cell( "IMP_PESOR"    ):SetValue( (cAliasTMP)->IMP_PESOR  	)
        oSection:Cell( "CAL_NR"       ):SetValue( (cAliasTMP)->CAL_NR     	)
        oSection:Cell( "CAL_BASICM"   ):SetValue( (cAliasTMP)->CAL_BASICM 	)
        oSection:Cell( "CAL_BASISS"   ):SetValue( (cAliasTMP)->CAL_BASISS 	)
        oSection:Cell( "DF_SIT"       ):SetValue( (cAliasTMP)->DF_SIT     	)
        oSection:Cell( "DF_NRDF"      ):SetValue( (cAliasTMP)->DF_NRDF    	)
        oSection:Cell( "DF_SER"       ):SetValue( (cAliasTMP)->DF_SER     	)
        oSection:Cell( "DF_VLDF"      ):SetValue( (cAliasTMP)->DF_VLDF    	)
        oSection:Cell( "DF_SITFIS"    ):SetValue( (cAliasTMP)->DF_SITFIS  	)
        oSection:Cell( "DF_DTFIS"     ):SetValue( (cAliasTMP)->DF_DTFIS   	)
        oSection:Cell( "DF_SITREC"    ):SetValue( (cAliasTMP)->DF_SITREC  	)
        oSection:Cell( "DF_DTREC"     ):SetValue( (cAliasTMP)->DF_DTREC   	)
        oSection:Cell( "DF_VLDIV"     ):SetValue( (cAliasTMP)->DF_VLDIV   	)
        oSection:Cell( "DF_PESO"      ):SetValue( (cAliasTMP)->DF_PESO    	)
        oSection:Cell( "NF_PESOB"     ):SetValue( (cAliasTMP)->NF_PESOB + (cAliasTMP)->NF_PESOBE	)
        oSection:Cell( "DC_PESOB"     ):SetValue( (cAliasTMP)->DC_PESOB   	)
		oSection:Cell( "SEP_PESOB"    ):SetValue( (cAliasTMP)->SEP_PESOB   	)
        oSection:Cell( "NF_PESOC"     ):SetValue( (cAliasTMP)->NF_PESOC   	)
        oSection:Cell( "DC_PESOC"     ):SetValue( (cAliasTMP)->DC_PESOC   	)
		oSection:Cell( "SEP_PESOC"    ):SetValue( (cAliasTMP)->SEP_PESOC   	)
        oSection:Cell( "NF_VALBRUT"   ):SetValue( (cAliasTMP)->NF_VALBRUT + (cAliasTMP)->NF_VALBRUE	)
        oSection:Cell( "DC_VALBRUT"   ):SetValue( (cAliasTMP)->DC_VALBRUT 	)
        oSection:Cell( "SEP_MARCA"    ):SetValue( (cAliasTMP)->SEP_MARCA  	)
        oSection:Cell( "SEP_PICKING"  ):SetValue( (cAliasTMP)->SEP_PICKING	)
        oSection:Cell( "NF_MENNOTA"   ):SetValue( AllTrim((cAliasTMP)->NF_MENNOTA)+AllTrim((cAliasTMP)->NF_MENENT)	)
        oSection:PrintLine()	

	    (cAliasTMP)->(dbSkip() )
	
	EndDo               
	oSection:Finish()	           

Return

//----------------------------------------------------------
// Consulta do relatório
//----------------------------------------------------------
Static Function zTmpQry()
    Local cQuery    := ""
    
	If Select( cAliasTMP ) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf

    cQuery := " SELECT DISTINCT DC_FILIAL, DC_DANFE, DC_DTEMIS, DC_NRDC, DC_SERDC, DC_CDTPDC, DC_SIT, " + CRLF
    cQuery += "     DC_NRROM, ROM_SIT, ROM_OPER, ROM_CLASS, ROM_DTCRIA, ROM_DTSAID, IMP_SEQ_OCOR, "		+ CRLF
    cQuery += "     ARQ_OCOR, IMP_DTOCOR, OCO_NROCO, OCO_SIT, OCO_DESCR, OCO_TIPO, ARQ_CTE, IMP_CTESIT,"+ CRLF
    cQuery += "     IMP_CHVCTE, IMP_NRCTE, IMP_DTEMIS, IMP_VLDF, IMP_PESOR, CAL_NR, CAL_BASICM, "       + CRLF
    cQuery += "     CAL_BASISS, DF_SIT, DF_NRDF, DF_SER, DF_VLDF, DF_SITFIS, DF_DTFIS, DF_SITREC, "     + CRLF
    cQuery += "     DF_DTREC, DF_VLDIV, DF_PESO, NF_PESOB,NF_PESOBE, DC_PESOB, SUM(ZK_PBRUTO) AS SEP_PESOB, "     + CRLF
    cQuery += "     NF_PESOC, DC_PESOC, SUM(ZK_XPESOC) AS SEP_PESOC, NF_VALBRUT, NF_VALBRUE, DC_VALBRUT, "          + CRLF
    cQuery += "     ZK_XMARCA AS SEP_MARCA, ZK_XPICKI AS SEP_PICKING, F2_MENNOTA AS NF_MENNOTA, F1_MENNOTA AS NF_MENENT "       	+ CRLF
	cQuery += " FROM( "                                                                                 + CRLF
	cQuery += " SELECT GW1_FILIAL AS DC_FILIAL, TRIM(GW1_DANFE) AS DC_DANFE, GW1_DTEMIS AS DC_DTEMIS, " + CRLF
    cQuery += "     GW1_NRDC AS DC_NRDC, GW1_SERDC AS DC_SERDC, GW1_CDTPDC AS DC_CDTPDC, "              + CRLF
	cQuery += " CASE GW1_SIT "                                                                          + CRLF
	cQuery += "     WHEN '1' THEN 'Digitado' "                                                          + CRLF
	cQuery += " 	WHEN '2' THEN 'Bloqueado' "                                                         + CRLF
	cQuery += " 	WHEN '3' THEN 'Liberado' "                                                          + CRLF
	cQuery += " 	WHEN '4' THEN 'Embarcado' "                                                         + CRLF
	cQuery += " 	WHEN '5' THEN 'Entregue' "                                                          + CRLF
	cQuery += " 	WHEN '6' THEN 'Retornado' "                                                         + CRLF
	cQuery += " 	WHEN '7' THEN 'Cancelado' "                                                         + CRLF
	cQuery += " 	WHEN '8' THEN 'Sinistrado' "                                                        + CRLF
	cQuery += " END DC_SIT, "                                                                           + CRLF
	cQuery += " GWN_NRROM AS DC_NRROM, "                                                                + CRLF
	cQuery += " CASE GWN_SIT "                                                                          + CRLF
	cQuery += " 	WHEN '1' THEN 'Digitado' "                                                          + CRLF
	cQuery += " 	WHEN '2' THEN 'Emitido' "                                                           + CRLF
	cQuery += " 	WHEN '3' THEN 'Liberado' "                                                          + CRLF
	cQuery += " 	WHEN '4' THEN 'Encerrado' "                                                         + CRLF
	cQuery += " END ROM_SIT, "                                                                          + CRLF
	cQuery += " GWN_CDTPOP AS ROM_OPER, "                                                               + CRLF 
	cQuery += " GWN_CDCLFR AS ROM_CLASS, "                                                              + CRLF 
	cQuery += " GWN_DTIMPL AS ROM_DTCRIA, "                                                             + CRLF 
	cQuery += " GWN_DTSAI AS ROM_DTSAID, "                                                              + CRLF 
	cQuery += " GXL_NRIMP AS IMP_SEQ_OCOR, "                                                           	+ CRLF 
	cQuery += " GXL_EDIARQ AS ARQ_OCOR, "                                                               + CRLF 
	cQuery += " GXL_DTOCOR AS IMP_DTOCOR, "                                                             + CRLF 
	cQuery += " GWD_NROCO AS OCO_NROCO, "                                                               + CRLF 
	cQuery += " CASE GWD_SIT "                                                                          + CRLF
	cQuery += " 	WHEN '1' THEN 'Pendente' "                                                          + CRLF
	cQuery += " 	WHEN '2' THEN 'Aprovada' "                                                          + CRLF
	cQuery += " 	WHEN '3' THEN 'Reprovada' "                                                         + CRLF
	cQuery += " END OCO_SIT, "                                                                          + CRLF 
	cQuery += " GWD_DSOCOR AS OCO_DESCR, "                                                              + CRLF 
	cQuery += " CASE GWD_CDTIPO "                                                                       + CRLF 
	cQuery += " 	WHEN '000001' THEN 'ENTREGA REALIZADA' "                                            + CRLF
	cQuery += " 	WHEN '000002' THEN 'REENTREGA SEM CUSTO' "                                          + CRLF
	cQuery += " 	WHEN '000003' THEN 'DEVOLUCAO - CAOA' "                                             + CRLF
	cQuery += " 	WHEN '000004' THEN 'SINISTRO DE CARGA  - RG' "                                      + CRLF
	cQuery += " 	WHEN '000004' THEN 'PROBLEMAS DIVERSOS' "                                           + CRLF
	cQuery += " 	WHEN '000006' THEN 'SINISTRO DE CARGA - SIMPLES REGISTRO' "                         + CRLF
	cQuery += " 	WHEN '000007' THEN 'DEVOLUCAO - DESTINATARIO' "                                     + CRLF
	cQuery += " 	WHEN '000008' THEN 'DEVOLUCAO - TRANSPORTADORA' "                                   + CRLF
	cQuery += " 	WHEN '000009' THEN 'REENTREGA - CLIENTE' "                                          + CRLF
	cQuery += " END OCO_TIPO, "                                                                         + CRLF
	cQuery += " GXG_EDIARQ AS ARQ_CTE, "                                                                + CRLF
	cQuery += " CASE GXG_EDISIT "                                                                       + CRLF
	cQuery += " 	WHEN '1' THEN 'Importado' "                                                         + CRLF
	cQuery += " 	WHEN '2' THEN 'Importado com erro' "                                                + CRLF
	cQuery += " 	WHEN '3' THEN 'Rejeitado' "                                                         + CRLF
	cQuery += " 	WHEN '4' THEN 'Processado' "                                                        + CRLF
	cQuery += " 	WHEN '5' THEN 'Erro impeditivo' "                                                   + CRLF
	cQuery += " END IMP_CTESIT, "                                                                       + CRLF 
	cQuery += " GXG_CTE AS IMP_CHVCTE, "                                                                + CRLF 
	cQuery += " GXG_NRDF AS IMP_NRCTE, "                                                                + CRLF 
	cQuery += " GXG_DTEMIS AS IMP_DTEMIS, "                                                             + CRLF 
	cQuery += " GXG_VLDF AS IMP_VLDF, "                                                                 + CRLF 
	cQuery += " GXG_PESOR AS IMP_PESOR, "                                                               + CRLF
	cQuery += " GWF_NRCALC AS CAL_NR, "                                                                 + CRLF 
	cQuery += " GWF_BASICM AS CAL_BASICM, "                                                             + CRLF 
	cQuery += " GWF_BASISS AS CAL_BASISS, "                                                             + CRLF
	cQuery += " CASE GW3_SIT "                                                                          + CRLF
	cQuery += " 	WHEN '1' THEN 'Recebido' "                                                          + CRLF
	cQuery += " 	WHEN '2' THEN 'Bloqueado' "                                                         + CRLF
	cQuery += " 	WHEN '3' THEN 'Aprovado pelo Sistema' "                                             + CRLF
	cQuery += " 	WHEN '4' THEN 'Aprovado pelo Usuario' "                                             + CRLF
	cQuery += " 	WHEN '5' THEN 'Bloqueado por Entrega' "                                             + CRLF
	cQuery += " END DF_SIT, "                                                                           + CRLF 
	cQuery += " GW3_NRDF AS DF_NRDF, "                                                                  + CRLF 
	cQuery += " GW3_SERDF AS DF_SER, "                                                                  + CRLF 
	cQuery += " GW3_VLDF AS DF_VLDF, "                                                                  + CRLF 
	cQuery += " CASE GW3_SITFIS "                                                                       + CRLF
	cQuery += " 	WHEN '1' THEN '1=Nao Enviado' "                                                     + CRLF
	cQuery += " 	WHEN '2' THEN '2=Pendente' "                                                        + CRLF
	cQuery += " 	WHEN '3' THEN '3=Rejeitado' "                                                       + CRLF
	cQuery += " 	WHEN '4' THEN '4=Atualizado' "                                                      + CRLF
	cQuery += " 	WHEN '5' THEN '5=Pendente Desatualizacao' "                                         + CRLF
	cQuery += " 	WHEN '6' THEN '6=Nao se Aplica' "                                                   + CRLF
	cQuery += " END DF_SITFIS, "                                                                        + CRLF 
	cQuery += " GW3_DTFIS AS DF_DTFIS, "                                                                + CRLF 
	cQuery += " CASE GW3_SITREC "                                                                       + CRLF 
	cQuery += " 	WHEN '1' THEN '1=Não Enviado' "                                                     + CRLF
	cQuery += " 	WHEN '2' THEN '2=Pendente' "                                                        + CRLF
	cQuery += " 	WHEN '3' THEN '3=Rejeitado' "                                                       + CRLF
	cQuery += " 	WHEN '4' THEN '4=Atualizado' "                                                      + CRLF
	cQuery += " 	WHEN '5' THEN '5=Pendente Desatualização' "                                         + CRLF
	cQuery += " 	WHEN '6' THEN '6=Não se Aplica' "                                                   + CRLF
	cQuery += " END DF_SITREC, "                                                                        + CRLF 
	cQuery += " GW3_DTREC AS DF_DTREC, "                                                                + CRLF 
	cQuery += " GW3_VLDIV AS DF_VLDIV, "                                                                + CRLF 
	cQuery += " GW3_PESOR AS DF_PESO, "                                                                 + CRLF 
	cQuery += " F2_PBRUTO AS NF_PESOB, "                                                                + CRLF 
	cQuery += " F1_PBRUTO AS NF_PESOBE, "                                                                + CRLF 
	cQuery += " SUM(GW8_PESOR) AS DC_PESOB, "                                                           + CRLF 
	cQuery += " F2_XPESOC AS NF_PESOC, "                                                                + CRLF 
	cQuery += " SUM(GW8_PESOC) AS DC_PESOC, "                                                           + CRLF 
	cQuery += " F2_VALBRUT AS NF_VALBRUT, "                                                             + CRLF 
	cQuery += " F1_VALBRUT AS NF_VALBRUE, "                                                             + CRLF 
	cQuery += " SUM(GW8_VALOR) AS DC_VALBRUT "                                                          + CRLF
	cQuery += " FROM " + RetSQLName( 'GWN' ) + " GWN "                                                  + CRLF
	cQuery += " LEFT JOIN " + RetSQLName( 'GW1' ) + " GW1 "                                             + CRLF
	cQuery += " 	ON GW1.D_E_L_E_T_ = ' '	"                                                           + CRLF 
	cQuery += " 	AND GW1.GW1_FILIAL = GWN.GWN_FILIAL "                                               + CRLF 
	cQuery += " 	AND GW1.GW1_NRROM = GWN.GWN_NRROM "                                                 + CRLF
	cQuery += " LEFT JOIN " + RetSQLName( 'GW8' ) + " GW8 "                                             + CRLF 
	cQuery += " 	ON GW8.D_E_L_E_T_ = ' ' "                                                           + CRLF
	cQuery += " 	AND GW8.GW8_FILIAL = GW1.GW1_FILIAL "                                               + CRLF 
	cQuery += " 	AND GW8.GW8_NRDC = GW1.GW1_NRDC "                                                   + CRLF 
	cQuery += " 	AND GW8.GW8_SERDC = GW1.GW1_SERDC "                                                 + CRLF
	cQuery += " LEFT OUTER JOIN " + RetSQLName( 'SF2' ) + " SF2 "                                             + CRLF 
	cQuery += " 	ON SF2.D_E_L_E_T_ = ' ' "                                                           + CRLF 
	cQuery += " 	AND SF2.F2_FILIAL = GW1.GW1_FILIAL "                                                + CRLF 
	cQuery += " 	AND SF2.F2_DOC = GW1.GW1_NRDC "                                                     + CRLF 
	cQuery += " 	AND SF2.F2_SERIE = GW1.GW1_SERDC "                                                  + CRLF

	//Teste rapido
	cQuery += " LEFT OUTER JOIN " + RetSQLName( 'SF1' ) + " SF1 "                                             + CRLF 
	cQuery += " 	ON SF1.D_E_L_E_T_ = ' ' "                                                           + CRLF 
	cQuery += " 	AND SF1.F1_FILIAL = GW1.GW1_FILIAL "                                                + CRLF 
	cQuery += " 	AND SF1.F1_DOC = GW1.GW1_NRDC "                                                     + CRLF 
	cQuery += " 	AND SF1.F1_SERIE = GW1.GW1_SERDC "                                                  + CRLF
	
	cQuery += " LEFT JOIN " + RetSQLName( 'GWH' ) + " GWH "                                             + CRLF
	cQuery += " 	ON GWH.D_E_L_E_T_ = ' ' "                                                           + CRLF
	cQuery += " 	AND GWH.GWH_FILIAL = GW1.GW1_FILIAL "                                               + CRLF 
	cQuery += " 	AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC "                                               + CRLF 
	cQuery += " 	AND GWH.GWH_EMISDC = GW1.GW1_EMISDC "                                               + CRLF 
	cQuery += " 	AND GWH.GWH_SERDC = GW1.GW1_SERDC "                                                 + CRLF 
	cQuery += " 	AND GWH.GWH_NRDC = GW1.GW1_NRDC "                                                   + CRLF 
	cQuery += " LEFT JOIN " + RetSQLName( 'GWF' ) + " GWF "                                             + CRLF 
	cQuery += " 	ON GWF.D_E_L_E_T_ = ' ' "                                                           + CRLF
	cQuery += " 	AND GWF.GWF_FILIAL = GWH.GWH_FILIAL "                                               + CRLF 
	cQuery += " 	AND GWF.GWF_NRCALC = GWH.GWH_NRCALC "                                               + CRLF  
	cQuery += " LEFT JOIN " + RetSQLName( 'GW3' ) + " GW3 "                                             + CRLF
	cQuery += " 	ON GW3.D_E_L_E_T_ = ' ' "                                                           + CRLF
	cQuery += " 	AND GW3.GW3_FILIAL = GWF.GWF_FILIAL "                                               + CRLF                             
	cQuery += " 	AND GW3.GW3_EMISDF = GWF.GWF_EMISDF	"                                               + CRLF 
	cQuery += " 	AND GW3.GW3_SERDF = GWF.GWF_SERDF "                                                 + CRLF 
	cQuery += " 	AND GW3.GW3_NRDF = GWF.GWF_NRDF "                                                   + CRLF
	cQuery += " LEFT JOIN " + RetSQLName( 'GXL' ) + " GXL "                                             + CRLF
	cQuery += " 	ON GXL.D_E_L_E_T_ = ' ' "                                                           + CRLF
	cQuery += " 	AND GXL.GXL_FILIAL = GW1.GW1_FILIAL "                                               + CRLF 
	cQuery += " 	AND GXL.GXL_NRDC = GW1.GW1_NRDC "                                                   + CRLF 
	cQuery += " 	AND GXL.GXL_SERDC = GW1.GW1_SERDC "                                                 + CRLF 
	cQuery += " 	AND GXL.GXL_EMISDC = GW1.GW1_EMISDC "                                               + CRLF
	cQuery += " LEFT JOIN " + RetSQLName( 'GXH' ) + " GXH "                                             + CRLF	 
	cQuery += " 	ON GXH.D_E_L_E_T_ = ' ' "                                                           + CRLF
	cQuery += " 	AND GXH.GXH_FILIAL = GW1.GW1_FILIAL "                                               + CRLF 
	cQuery += " 	AND GXH.GXH_NRDC = GW1.GW1_NRDC "                                                   + CRLF 
	cQuery += " 	AND GXH.GXH_SERDC = GW1.GW1_SERDC "                                                 + CRLF 
	cQuery += " 	AND GXH.GXH_EMISDC = GW1.GW1_EMISDC "                                               + CRLF 
	cQuery += " LEFT JOIN " + RetSQLName( 'GWL' ) + " GWL "                                             + CRLF
	cQuery += " 	ON GWL.D_E_L_E_T_ = ' ' "                                                           + CRLF
	cQuery += " 	AND GWL.GWL_FILIAL = GW1.GW1_FILIAL "                                               + CRLF 
	cQuery += " 	AND GWL.GWL_NRDC = GW1.GW1_NRDC "                                                   + CRLF  
	cQuery += " LEFT JOIN " + RetSQLName( 'GWD' ) + " GWD "                                             + CRLF
	cQuery += " 	ON GWD.D_E_L_E_T_ = ' ' "                                                           + CRLF
	cQuery += " 	AND GWD.GWD_FILIAL = GWL.GWL_FILIAL "                                               + CRLF 
	cQuery += " 	AND GWD.GWD_NROCO = GWL.GWL_NROCO "                                                 + CRLF
	cQuery += " LEFT JOIN " + RetSQLName( 'GXG' ) + " GXG "                                             + CRLF
	cQuery += " 	ON GXG.D_E_L_E_T_ = ' ' "                                                           + CRLF
	cQuery += " 	AND GXG.GXG_FILIAL = GXH.GXH_FILIAL "                                               + CRLF 
	cQuery += " 	AND GXG.GXG_NRIMP = GXH.GXH_NRIMP "                                                 + CRLF  
	cQuery += " WHERE GWN.GWN_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "                + CRLF
	cQuery += " 	AND GWN.GWN_DTIMPL BETWEEN '" + DToS(MV_PAR03) + "' AND '" + DToS(MV_PAR04) + "' "  + CRLF
	cQuery += " 	AND GWN.GWN_NRROM BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " 		        + CRLF
	cQuery += " 	AND GWN.D_E_L_E_T_ = ' ' "	 												        + CRLF
	cQuery += " GROUP BY GW1_FILIAL, GW1_DANFE, GW1_SIT, GW1_CDTPDC, GW1_DTEMIS, GW1_NRDC, F2_DOC,F1_DOC, "    + CRLF
    cQuery += "     GW1_SERDC, GWN_NRROM, GWN_SIT, GWN_CDTPOP, GWN_CDCLFR, GWN_DTIMPL, GXL_EDIARQ, "    + CRLF
	cQuery += "     GXL_DTOCOR, GWD_NROCO, GWD_SIT, GWD_DSOCOR, GWD_CDTIPO, GWN_DTSAI, GXL_NRIMP, "    	+ CRLF
    cQuery += "     GXG_EDIARQ, GXG_CTE, GXG_NRDF, GXG_DTEMIS, GXG_VLDF, GXG_PESOR, GWF_NRCALC, "       + CRLF
	cQuery += "     GWF_BASICM, GWF_BASISS, GW3_SIT, GW3_NRDF, GW3_SERDF, GW3_VLDF, GW3_PESOR, "        + CRLF
    cQuery += "     GW3_SITFIS, GW3_DTFIS, GW3_SITREC, GW3_DTREC, GW3_VLDIV, F2_PBRUTO, F2_XPESOC, "    + CRLF
    cQuery += "     F2_VALBRUT, GXG_EDISIT, F1_PBRUTO, F1_VALBRUT "                                                         	+ CRLF
    cQuery += "     ) ROMAN"                                                                            + CRLF
	cQuery += " LEFT JOIN " + RetSQLName( 'SZK' ) + " SZK "                                             + CRLF 
    cQuery += "     ON SZK.ZK_NF = ROMAN.DC_NRDC "                                                      + CRLF  
	cQuery += "	    AND SZK.ZK_SERIE = ROMAN.DC_SERDC "                                                 + CRLF  
    cQuery += "	    AND SZK.D_E_L_E_T_ = ' ' "                                                          + CRLF 
	cQuery += " LEFT OUTER JOIN " + RetSQLName( 'SF2' ) + " F2ZK "                                            + CRLF 
	cQuery += "     ON F2ZK.F2_FILIAL = SZK.ZK_FILIAL "                                                 + CRLF  
	cQuery += "	    AND F2ZK.F2_DOC = SZK.ZK_NF "                                                       + CRLF  
	cQuery += "	    AND F2ZK.F2_SERIE = SZK.ZK_SERIE "                                                  + CRLF  
	cQuery += "	    AND F2ZK.D_E_L_E_T_ = ' ' "                                                         + CRLF

	cQuery += " LEFT OUTER JOIN " + RetSQLName( 'SF1' ) + " F1ZK "                                            + CRLF 
	cQuery += "     ON F1ZK.F1_FILIAL = SZK.ZK_FILIAL "                                                 + CRLF  
	cQuery += "	    AND F1ZK.F1_DOC = SZK.ZK_NF "                                                       + CRLF  
	cQuery += "	    AND F1ZK.F1_SERIE = SZK.ZK_SERIE "                                                  + CRLF  
	cQuery += "	    AND F1ZK.D_E_L_E_T_ = ' ' "                                                         + CRLF

	cQuery += " GROUP BY DC_FILIAL, DC_DANFE, DC_DTEMIS, DC_NRDC, DC_SERDC, DC_CDTPDC, DC_SIT, "        + CRLF
    cQuery += "     DC_NRROM, ROM_SIT, ROM_OPER, ROM_CLASS, ROM_DTCRIA, ROM_DTSAID, IMP_SEQ_OCOR, "		+ CRLF
    cQuery += "     ARQ_OCOR, IMP_DTOCOR, OCO_NROCO, OCO_SIT, OCO_DESCR, OCO_TIPO, ARQ_CTE, IMP_CTESIT,"+ CRLF
    cQuery += "     IMP_CHVCTE, IMP_NRCTE, IMP_DTEMIS, IMP_VLDF, IMP_PESOR, CAL_NR, CAL_BASICM, "       + CRLF
    cQuery += "     CAL_BASISS, DF_SIT, DF_NRDF, DF_SER, DF_VLDF, DF_SITFIS, DF_DTFIS, DF_SITREC, "     + CRLF
    cQuery += "     DF_DTREC, DF_VLDIV, DF_PESO, NF_PESOB,NF_PESOBE, DC_PESOB, NF_PESOC, DC_PESOC, NF_VALBRUT, NF_VALBRUE,"  + CRLF
    cQuery += "     DC_VALBRUT, ZK_XMARCA, ZK_XPICKI, F2_MENNOTA, F1_MENNOTA "                                       + CRLF
	cQuery += " ORDER BY 31 "                                                                           + CRLF

	// Executa a consulta.
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T. )

Return
